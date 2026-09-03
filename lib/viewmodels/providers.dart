import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/analytics_events.dart';
import '../core/constants/license_category.dart';
import '../models/analytics_snapshot.dart';
import '../models/bike_unlock_progress.dart';
import '../models/pass_prediction_score.dart';
import '../models/question.dart';
import '../models/achievement_badge.dart';
import '../models/question_mastery_status.dart';
import '../models/trap_dojo_session.dart';
import '../models/user.dart';
import '../models/user_answer_log.dart';
import '../services/ad_gate_service.dart';
import '../services/analytics_cache_service.dart';
import '../services/analytics_isolate_service.dart';
import '../services/analytics_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_sync_service.dart';
import '../services/local_data_service.dart';
import '../services/achievement_service.dart';
import '../services/mastery_service.dart';
import '../services/prediction_score_service.dart';
import '../services/purchase_service.dart';
import '../services/notification_service.dart';
import '../services/question_index.dart';
import '../services/sound_effects_service.dart';
import '../services/study_analytics_service.dart';
import '../services/sync_queue_service.dart';
import '../services/connectivity_service.dart';
import '../services/conflict_resolution_service.dart';
import '../services/user_deletion_service.dart';
import '../services/network_queue_processor.dart';
import '../services/report_service.dart';
import '../services/export_service.dart';
import '../models/report_model.dart';

// ---------------------------------------------------------------------------
// Service層 Provider（差し替え可能。main.dart の overrides で本番実装に切替）
// ---------------------------------------------------------------------------

final dataServiceProvider = Provider<DataService>((ref) => LocalDataService());

final analyticsServiceProvider =
    Provider<AnalyticsService>((ref) => DebugAnalyticsService());

final purchaseServiceProvider =
    Provider<PurchaseService>((ref) => StubPurchaseService());

final adGateServiceProvider = Provider<AdGateService>((ref) => AdGateService());

final predictionScoreServiceProvider =
    Provider<PredictionScoreService>((ref) => PredictionScoreService());

final masteryServiceProvider = Provider<MasteryService>((ref) => LocalMasteryService());

final achievementServiceProvider =
    Provider<AchievementService>((ref) => LocalAchievementService());

final soundEffectsServiceProvider = FutureProvider<SoundEffectsService>((ref) async {
  final service = LocalSoundEffectsService();
  await service.initialize();
  return service;
});

final notificationServiceProvider =
    Provider<NotificationService>((ref) => LocalNotificationService());

final fireStoreSyncServiceProvider =
    Provider<FirestoreSyncService>((ref) => LocalFirestoreSyncService());

final syncQueueServiceProvider = FutureProvider<LocalSyncQueueService>((ref) async {
  final service = LocalSyncQueueService();
  await service.initialize();
  return service;
});

final connectivityServiceProvider = FutureProvider<ConnectivityService>((ref) async {
  final service = LocalConnectivityService();
  await service.initialize();
  return service;
});

// 同期ステータスをUIで監視するためのプロバイダー
final syncStatusProvider = StreamProvider<SyncStatus>((ref) async* {
  final queueService = await ref.watch(syncQueueServiceProvider.future);
  yield* queueService.statusStream();
});

final conflictResolutionServiceProvider =
    Provider<ConflictResolutionService>((ref) => DefaultConflictResolutionService());

final userDeletionServiceProvider =
    Provider<UserDeletionService>((ref) => FirebaseUserDeletionService());

final networkQueueProcessorProvider =
    FutureProvider<NetworkQueueProcessor>((ref) async {
  final queueService = await ref.watch(syncQueueServiceProvider.future);
  final connectivityService = await ref.watch(connectivityServiceProvider.future);
  final processor = DefaultNetworkQueueProcessor(
    syncQueueService: queueService,
    connectivityService: connectivityService,
    firestoreSyncService: ref.read(fireStoreSyncServiceProvider),
    localDataService: LocalDataService(),
  );
  await processor.start();
  return processor;
});

// ---------------------------------------------------------------------------
// Authentication
// ---------------------------------------------------------------------------

/// ユーザー認証準備（アプリ起動時に一度だけ実行）
/// Firebase 初期化は main.dart で既に済んでいる前提
/// app.dart でこのプロバイダーを ref.read() して、Auth初期化を保証する
final authReadyProvider = FutureProvider<String>((ref) async {
  // Firebase Auth Service を初期化し、匿名ログインを実行
  final authService = FirebaseAuthService();
  await authService.initialize();

  final uid = authService.currentUid;
  if (uid == null) {
    throw Exception('Failed to get UID after Firebase Auth initialization');
  }

  return uid;
});

/// Auth状態の変化を監視（StreamProvider）
final authStateProvider = StreamProvider<User?>((ref) async* {
  yield* FirebaseAuth.instance.authStateChanges();
});

/// 現在ログイン中のユーザーUID
/// 同期的にアクセス。authReadyProvider が初期化を保証していること前提。
final currentUidProvider = Provider<String>((ref) {
  final currentUser = FirebaseAuth.instance.currentUser;
  return currentUser?.uid ?? 'unknown_uid';
});

// ---------------------------------------------------------------------------
// User
// ---------------------------------------------------------------------------

class UserController extends AsyncNotifier<AppUser> {
  @override
  Future<AppUser> build() async {
    final uid = ref.read(currentUidProvider);
    return ref.read(dataServiceProvider).loadUser(uid);
  }

  /// ユーザー情報を保存（ローカル＋キューイング）
  Future<void> _saveUserToLocalAndFirestore(AppUser user) async {
    // ローカル保存
    await ref.read(dataServiceProvider).saveUser(user);

    // Firestore 同期をキューに登録
    try {
      final queueService = await ref.read(syncQueueServiceProvider.future);
      final operation = QueuedOperation(
        id: 'user_${user.uid}_${DateTime.now().millisecondsSinceEpoch}',
        type: 'saveUser',
        data: user.toJson(),
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      );
      await queueService.enqueue(operation);
    } catch (e) {
      debugPrint('Failed to queue user save operation: $e');
    }
  }

  Future<void> setLicenseCategories(List<String> categories) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.copyWith(licenseCategories: categories);
    state = AsyncData(updated);
    await _saveUserToLocalAndFirestore(updated);
  }

  Future<void> setTrainingStage(String? stage) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.copyWith(trainingStage: stage);
    state = AsyncData(updated);
    await _saveUserToLocalAndFirestore(updated);
  }

  Future<void> setExamDate(DateTime? date) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.copyWith(examDate: date);
    state = AsyncData(updated);
    await _saveUserToLocalAndFirestore(updated);
  }

  Future<void> setPurchaseStatus(PurchaseStatus status) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.copyWith(purchaseStatus: status);
    state = AsyncData(updated);
    await _saveUserToLocalAndFirestore(updated);
  }
}

final userControllerProvider =
    AsyncNotifierProvider<UserController, AppUser>(UserController.new);

// ---------------------------------------------------------------------------
// Questions
// ---------------------------------------------------------------------------

class QuestionQuery {
  const QuestionQuery({required this.licenseCategory, this.stageTag});
  final String licenseCategory;
  final String? stageTag;

  @override
  bool operator ==(Object other) =>
      other is QuestionQuery &&
      other.licenseCategory == licenseCategory &&
      other.stageTag == stageTag;

  @override
  int get hashCode => Object.hash(licenseCategory, stageTag);
}

final questionsProvider =
    FutureProvider.family<List<Question>, QuestionQuery>((ref, query) {
  return ref
      .read(dataServiceProvider)
      .loadQuestions(licenseCategory: query.licenseCategory, stageTag: query.stageTag);
});

// ---------------------------------------------------------------------------
// Answer logs & Prediction score
// ---------------------------------------------------------------------------

final answerLogsProvider = FutureProvider<List<UserAnswerLog>>((ref) {
  final uid = ref.read(currentUidProvider);
  return ref.read(dataServiceProvider).loadAnswerLogs(uid);
});

/// ホーム画面で表示する、直近で保存された合格予測スコア（未達成ならnull）。
final savedPredictionScoreProvider =
    FutureProvider<PassPredictionScore?>((ref) {
  final uid = ref.read(currentUidProvider);
  return ref.read(dataServiceProvider).loadPredictionScore(uid);
});

/// ユーザーが「記憶した」フラグを持つ問題のリスト。
final masteredQuestionsProvider =
    FutureProvider<List<QuestionMasteryStatus>>((ref) {
  final uid = ref.read(currentUidProvider);
  return ref.read(masteryServiceProvider).loadMasteredQuestions(uid);
});

/// ユーザーが獲得したバッジのリスト。
final unlockedBadgesProvider = FutureProvider<List<AchievementBadge>>((ref) {
  final uid = ref.read(currentUidProvider);
  return ref.read(achievementServiceProvider).loadUnlockedBadges(uid);
});

// ---------------------------------------------------------------------------
// Daily Quota / 出題フロー（Aha Moment最短動線の心臓部）
// ---------------------------------------------------------------------------

enum AnswerResult { none, correct, incorrect }

class DailyQuotaState {
  const DailyQuotaState({
    this.questions = const [],
    this.currentIndex = 0,
    this.correctCount = 0,
    this.lastResult = AnswerResult.none,
    this.ahaMomentShown = false,
    this.predictionScore,
    this.loading = true,
  });

  final List<Question> questions;
  final int currentIndex;
  final int correctCount;
  final AnswerResult lastResult;
  final bool ahaMomentShown;
  final PassPredictionScore? predictionScore;
  final bool loading;

  Question? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  bool get isQuotaCompleted =>
      questions.isNotEmpty && currentIndex >= questions.length;

  DailyQuotaState copyWith({
    List<Question>? questions,
    int? currentIndex,
    int? correctCount,
    AnswerResult? lastResult,
    bool? ahaMomentShown,
    PassPredictionScore? predictionScore,
    bool? loading,
  }) {
    return DailyQuotaState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      lastResult: lastResult ?? this.lastResult,
      ahaMomentShown: ahaMomentShown ?? this.ahaMomentShown,
      predictionScore: predictionScore ?? this.predictionScore,
      loading: loading ?? this.loading,
    );
  }
}

/// 無料枠：1日ノルマ10問まで（実装引き継ぎ書 R④ 参照）。
const int freeDailyQuotaLimit = 10;

class DailyQuotaController extends FamilyNotifier<DailyQuotaState, String> {
  late String _licenseCategory;

  @override
  DailyQuotaState build(String licenseCategory) {
    _licenseCategory = licenseCategory;
    Future.microtask(_load);
    return const DailyQuotaState();
  }

  Future<void> _load() async {
    ref.read(adGateServiceProvider).enterContext(AdBlockingContext.answeringQuestion);

    final user = ref.read(userControllerProvider).valueOrNull;
    final uid = ref.read(currentUidProvider);

    final all = await ref.read(
      questionsProvider(
        QuestionQuery(
          licenseCategory: _licenseCategory,
          stageTag: user?.trainingStage,
        ),
      ).future,
    );

    // マスター済み問題を除外
    final masteredIds = await ref.read(masteryServiceProvider).loadMasteredQuestions(uid);
    final masteredIdSet = {for (final m in masteredIds) m.questionId};
    final filtered = all.where((q) => !masteredIdSet.contains(q.id)).toList();

    // マスター済み問題が全てなら、全問題から開始
    final questionsList = filtered.isEmpty ? all : filtered;

    questionsList.shuffle();
    final quota = questionsList.take(freeDailyQuotaLimit).toList();
    state = state.copyWith(questions: quota, loading: false);
  }

  /// 回答ログをローカル＆キューに保存
  Future<void> _appendAnswerLogToLocalAndFirestore(UserAnswerLog log) async {
    final uid = ref.read(currentUidProvider);

    // ローカル保存
    await ref.read(dataServiceProvider).appendAnswerLog(log);

    // 全ログを取得してキューに登録（エラーが出てもアプリは続行）
    try {
      final allLogs = await ref.read(dataServiceProvider).loadAnswerLogs(uid);
      final queueService = await ref.read(syncQueueServiceProvider.future);
      final operation = QueuedOperation(
        id: 'answerLogs_${uid}_${DateTime.now().millisecondsSinceEpoch}',
        type: 'saveAnswerLogs',
        data: {
          'uid': uid,
          'logs': allLogs.map((l) => l.toJson()).toList(),
        },
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      );
      await queueService.enqueue(operation);
    } catch (e) {
      debugPrint('Failed to queue answer logs operation: $e');
    }
  }

  Future<void> answer(int choiceIndex) async {
    final question = state.currentQuestion;
    if (question == null) return;

    final isCorrect = choiceIndex == question.answer;
    final uid = ref.read(currentUidProvider);
    final now = DateTime.now();

    // ハプティクスフィードバック
    try {
      if (isCorrect) {
        await HapticFeedback.mediumImpact();
      } else {
        await HapticFeedback.lightImpact();
      }
    } catch (_) {
      // Haptics not available on this device
    }

    await _appendAnswerLogToLocalAndFirestore(
      UserAnswerLog(
        uid: uid,
        questionId: question.id,
        isCorrect: isCorrect,
        answeredAt: now,
      ),
    );

    final newCorrectCount = state.correctCount + (isCorrect ? 1 : 0);
    state = state.copyWith(
      lastResult: isCorrect ? AnswerResult.correct : AnswerResult.incorrect,
      correctCount: newCorrectCount,
    );

    // Aha Moment: 初回3問正解 → 合格予測メーター初表示。
    if (!state.ahaMomentShown && newCorrectCount >= 3) {
      await _revealPredictionMeter();
    }

    // バッジチェック：新しく獲得したバッジを自動的にロック解除
    await _checkAndUnlockBadges();
  }

  Future<void> _revealPredictionMeter() async {
    final uid = ref.read(currentUidProvider);
    final logs = await ref.read(dataServiceProvider).loadAnswerLogs(uid);
    final questionsById = {for (final q in state.questions) q.id: q};

    final score = ref.read(predictionScoreServiceProvider).calculate(
          uid: uid,
          logs: logs,
          questionsById: questionsById,
          now: DateTime.now(),
        );

    // ローカル＆キューに保存
    await ref.read(dataServiceProvider).savePredictionScore(score);
    try {
      final queueService = await ref.read(syncQueueServiceProvider.future);
      final operation = QueuedOperation(
        id: 'predictionScore_${uid}_${DateTime.now().millisecondsSinceEpoch}',
        type: 'savePredictionScore',
        data: {
          'uid': uid,
          'score': score.score,
          'calculatedAt': score.calculatedAt.toIso8601String(),
          'breakdown': score.breakdown,
        },
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      );
      await queueService.enqueue(operation);
    } catch (e) {
      debugPrint('Failed to queue prediction score operation: $e');
    }

    state = state.copyWith(ahaMomentShown: true, predictionScore: score);

    await ref.read(analyticsServiceProvider).logEvent(
          AnalyticsEvents.ahaMomentReached,
          parameters: {'license_category': _licenseCategory},
        );

    // Aha Moment直後は課金導線を優先＝広告表示を禁止するガードを明示的にON。
    ref
        .read(adGateServiceProvider)
        .enterContext(AdBlockingContext.justShowedPredictionMeter);
  }

  void advanceToNextQuestion() {
    if (state.isQuotaCompleted) return;
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      lastResult: AnswerResult.none,
    );

    if (state.isQuotaCompleted) {
      _onQuotaCompleted();
    } else {
      ref
          .read(adGateServiceProvider)
          .enterContext(AdBlockingContext.answeringQuestion);
    }
  }

  Future<void> _checkAndUnlockBadges() async {
    try {
      final uid = ref.read(currentUidProvider);
      final logs = await ref.read(dataServiceProvider).loadAnswerLogs(uid);

      // 質問メタデータを構築：全トレーニング段階から問題をロード
      final trapQuestionIds = <String>[];
      final stageMap = <String, List<String>>{
        '第一段階': <String>[],
        '第二段階': <String>[],
      };
      final categoryMap = <String, List<String>>{
        'futsuuNirin': <String>[],
        'gentsuki': <String>[],
        'ogataNirin': <String>[],
      };

      // 各カテゴリ×各段階で問題をロード
      for (final category in ['futsuuNirin', 'gentsuki', 'ogataNirin']) {
        for (final stage in ['第一段階', '第二段階']) {
          try {
            final questions = await ref
                .read(dataServiceProvider)
                .loadQuestions(licenseCategory: category, stageTag: stage);

            for (final q in questions) {
              // トラップ問題を記録
              if (q.isTrapQuestion) {
                trapQuestionIds.add(q.id);
              }
              // ステージごとに記録
              if (stageMap.containsKey(stage)) {
                stageMap[stage]!.add(q.id);
              }
              // カテゴリごとに記録
              if (q.licenseCategory.contains(category)) {
                categoryMap[category]!.add(q.id);
              }
            }
          } catch (e) {
            // 個別の問題読み込みエラーはスキップ
          }
        }
      }

      final questionMetadata = <String, dynamic>{
        'trapQuestions': trapQuestionIds,
        'stages': stageMap,
        'categories': categoryMap,
      };

      final newBadges = await ref.read(achievementServiceProvider)
          .checkAndUnlockBadges(uid, logs, questionMetadata);

      if (newBadges.isNotEmpty) {
        // バッジプロバイダーを無効化して再読み込みをトリガー
        ref.invalidate(unlockedBadgesProvider);

        // アナリティクスに送信
        for (final badge in newBadges) {
          await ref.read(analyticsServiceProvider).logEvent(
                'badge_unlocked',
                parameters: {
                  'badge_type': badge.badgeType.name,
                  'badge_name': badge.badgeType.displayName,
                  'criteria': badge.criteria,
                },
              );
        }
      }
    } catch (e) {
      // バッジチェック失敗はスキップ（ゲームプレイを妨害しない）
    }
  }

  Future<void> _onQuotaCompleted() async {
    ref.read(adGateServiceProvider).exitContext();
    ref.read(adGateServiceProvider).markDailyQuotaCompleted();
    await ref
        .read(analyticsServiceProvider)
        .logEvent(AnalyticsEvents.dailyQuotaCompleted, parameters: {
      'license_category': _licenseCategory,
      'correct_count': state.correctCount,
      'total': state.questions.length,
    });
  }
}

final dailyQuotaControllerProvider =
    NotifierProvider.family<DailyQuotaController, DailyQuotaState, String>(
  DailyQuotaController.new,
);

// ---------------------------------------------------------------------------
// Bike Unlock（憧れバイク解放）
// ---------------------------------------------------------------------------

class BikeUnlockController extends AsyncNotifier<List<BikeUnlockProgress>> {
  @override
  Future<List<BikeUnlockProgress>> build() async {
    final uid = ref.read(currentUidProvider);
    final saved = await ref.read(dataServiceProvider).loadBikeUnlockProgress(uid);
    final savedIds = saved.map((p) => p.bikeId).toSet();

    // 未保存のTierは未解放状態で補完して常に全Tierを返す。
    final all = [
      ...saved,
      for (final tier in BikeTier.values)
        if (!savedIds.contains(tier.name))
          BikeUnlockProgress(
            uid: uid,
            bikeId: tier.name,
            requiredCorrectCount: tier.requiredCorrectCount,
          ),
    ];
    all.sort((a, b) => BikeTier.values
        .indexWhere((t) => t.name == a.bikeId)
        .compareTo(BikeTier.values.indexWhere((t) => t.name == b.bikeId)));
    return all;
  }

  /// 通算正解数から到達可能なTierを解放する。バイク解放を1段階早める
  /// リワード広告の分だけ `bonusCorrectCount` を上乗せできる。
  Future<void> refreshFromTotalCorrectCount(
    int totalCorrectCount, {
    int bonusCorrectCount = 0,
  }) async {
    final uid = ref.read(currentUidProvider);
    final current = state.valueOrNull ?? await build();
    final effectiveCount = totalCorrectCount + bonusCorrectCount;

    final updated = <BikeUnlockProgress>[];
    for (final progress in current) {
      if (!progress.isUnlocked &&
          effectiveCount >= progress.requiredCorrectCount) {
        final unlocked = BikeUnlockProgress(
          uid: uid,
          bikeId: progress.bikeId,
          unlockedAt: DateTime.now(),
          requiredCorrectCount: progress.requiredCorrectCount,
        );
        await ref.read(dataServiceProvider).saveBikeUnlockProgress(unlocked);

        // キューに登録（エラーが出てもアプリは続行）
        try {
          final queueService = await ref.read(syncQueueServiceProvider.future);
          final operation = QueuedOperation(
            id: 'bikeProgress_${uid}_${DateTime.now().millisecondsSinceEpoch}',
            type: 'saveBikeProgress',
            data: {
              'uid': uid,
              'progress': (updated + [unlocked]).map((p) => p.toJson()).toList(),
            },
            queuedAt: DateTime.now(),
            lastAttemptAt: DateTime.now(),
            retryCount: 0,
          );
          await queueService.enqueue(operation);
        } catch (e) {
          debugPrint('Failed to queue bike progress operation: $e');
        }

        await ref.read(analyticsServiceProvider).logEvent(
          AnalyticsEvents.bikeUnlocked,
          parameters: {'bike_id': progress.bikeId},
        );

        // バイク解放時のハプティクスフィードバック
        try {
          await HapticFeedback.heavyImpact();
        } catch (_) {
          // Haptics not available on this device
        }

        updated.add(unlocked);
      } else {
        updated.add(progress);
      }
    }
    state = AsyncData(updated);

    // 全バイク進捗をキューに登録
    try {
      final queueService = await ref.read(syncQueueServiceProvider.future);
      final operation = QueuedOperation(
        id: 'bikeProgressFull_${uid}_${DateTime.now().millisecondsSinceEpoch}',
        type: 'saveBikeProgress',
        data: {
          'uid': uid,
          'progress': updated.map((p) => p.toJson()).toList(),
        },
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      );
      await queueService.enqueue(operation);
    } catch (e) {
      debugPrint('Failed to queue bike progress full sync: $e');
    }
  }
}

final bikeUnlockControllerProvider =
    AsyncNotifierProvider<BikeUnlockController, List<BikeUnlockProgress>>(
  BikeUnlockController.new,
);

// ---------------------------------------------------------------------------
// Trap Dojo（ひっかけ道場）
// ---------------------------------------------------------------------------

class TrapDojoController extends AsyncNotifier<List<TrapDojoSession>> {
  @override
  Future<List<TrapDojoSession>> build() async {
    final uid = ref.read(currentUidProvider);
    return ref.read(dataServiceProvider).loadTrapDojoSessions(uid);
  }

  Future<void> recordAnswer({
    required Question bossQuestion,
    required bool isCorrect,
  }) async {
    final uid = ref.read(currentUidProvider);
    final current = state.valueOrNull ?? [];
    final existing = current.firstWhere(
      (s) => s.bossQuestionId == bossQuestion.id,
      orElse: () => TrapDojoSession(uid: uid, bossQuestionId: bossQuestion.id),
    );

    final updatedSession = isCorrect
        ? existing.copyAsDefeated(DateTime.now())
        : existing.copyWithRetry();

    await ref.read(dataServiceProvider).saveTrapDojoSession(updatedSession);

    final updatedList = [
      ...current.where((s) => s.bossQuestionId != bossQuestion.id),
      updatedSession,
    ];

    // キューに登録（エラーが出てもアプリは続行）
    try {
      final queueService = await ref.read(syncQueueServiceProvider.future);
      final operation = QueuedOperation(
        id: 'trapDojo_${uid}_${DateTime.now().millisecondsSinceEpoch}',
        type: 'saveTrapDojoSessions',
        data: {
          'uid': uid,
          'sessions': updatedList.map((s) => s.toJson()).toList(),
        },
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      );
      await queueService.enqueue(operation);
    } catch (e) {
      debugPrint('Failed to queue trap dojo sessions operation: $e');
    }

    if (isCorrect) {
      await ref
          .read(analyticsServiceProvider)
          .logEvent(AnalyticsEvents.trapBossDefeated, parameters: {
        'question_id': bossQuestion.id,
        'trap_number_type': bossQuestion.trapNumberType.name,
      });
    }

    state = AsyncData(updatedList);
  }
}

final trapDojoControllerProvider =
    AsyncNotifierProvider<TrapDojoController, List<TrapDojoSession>>(
  TrapDojoController.new,
);

// ---------------------------------------------------------------------------
// Phase 3 Analytics Dashboard (分析ダッシュボード)
// ---------------------------------------------------------------------------

final questionIndexProvider = FutureProvider<QuestionIndex>((ref) async {
  final builder = LocalQuestionIndexBuilder(ref.read(dataServiceProvider));
  return builder.build();
});

final studyAnalyticsServiceProvider =
    Provider<StudyAnalyticsService>((ref) => DefaultStudyAnalyticsService());

final analyticsCacheServiceProvider =
    Provider<AnalyticsCacheService>((ref) => LocalAnalyticsCacheService());

class AnalyticsController extends AsyncNotifier<AnalyticsSnapshot> {
  @override
  Future<AnalyticsSnapshot> build() async {
    final uid = ref.read(currentUidProvider);
    final cacheService = ref.read(analyticsCacheServiceProvider);
    final range = ref.watch(analyticsRangeProvider);

    // 期間に応じてログを読み込む（since パラメータ）
    final sinceDate = _calculateSinceDate(range, DateTime.now());
    final logs = await ref
        .read(dataServiceProvider)
        .loadAnswerLogs(uid, since: sinceDate);

    // キャッシュを確認（ログの指紋を自動確認）
    final cached = await cacheService.getCachedIfValid(uid, logs);
    if (cached != null) {
      // ログが変わっていない：キャッシュを返す
      return cached;
    }

    // キャッシュなし or 指紋が異なる：新規計算
    final index = await ref.watch(questionIndexProvider.future);

    // 大規模ログセットの場合は isolate に移譲（UI ブロッキング回避）
    final snapshot = await AnalyticsIsolateService.aggregateWithThreshold(
      uid: uid,
      logs: logs,
      index: index,
      now: DateTime.now(),
    );

    // 新しいスナップショットをキャッシュに保存
    await cacheService.cache(uid, snapshot, logs);

    return snapshot;
  }

  /// 期間に応じて since 日付を計算
  static DateTime? _calculateSinceDate(AnalyticsRange range, DateTime now) {
    switch (range) {
      case AnalyticsRange.days7:
        return now.subtract(const Duration(days: 7));
      case AnalyticsRange.days30:
        return now.subtract(const Duration(days: 30));
      case AnalyticsRange.allTime:
        return null; // 全期間：制限なし
    }
  }

  /// 分析スナップショットを明示的に再計算
  Future<void> refresh({bool force = false}) async {
    // force=true の場合は強制的に再計算
    if (force) {
      state = const AsyncValue.loading();
    }
    state = await AsyncValue.guard(() => build());
  }
}

final analyticsSnapshotProvider =
    AsyncNotifierProvider<AnalyticsController, AnalyticsSnapshot>(
  AnalyticsController.new,
);

/// 弱点一覧（読み取り専用セレクター）
final weakAreasProvider = Provider<List<WeakArea>>((ref) {
  final snapshot = ref.watch(analyticsSnapshotProvider);
  return snapshot.maybeWhen(
    data: (data) => data.weakAreas,
    orElse: () => const [],
  );
});

/// ステージ別パフォーマンス（読み取り専用セレクター）
final stagePerformanceProvider = Provider<List<StagePerformance>>((ref) {
  final snapshot = ref.watch(analyticsSnapshotProvider);
  return snapshot.maybeWhen(
    data: (data) => data.stages,
    orElse: () => const [],
  );
});

/// カテゴリ別パフォーマンス（読み取り専用セレクター）
final categoryPerformanceProvider = Provider<List<CategoryPerformance>>((ref) {
  final snapshot = ref.watch(analyticsSnapshotProvider);
  return snapshot.maybeWhen(
    data: (data) => data.categories,
    orElse: () => const [],
  );
});

/// 復習推奨（読み取り専用セレクター）
final reviewRecommendationsProvider =
    Provider<List<ReviewRecommendation>>((ref) {
  final snapshot = ref.watch(analyticsSnapshotProvider);
  return snapshot.maybeWhen(
    data: (data) => data.recommendations,
    orElse: () => const [],
  );
});

/// 日別学習進捗（読み取り専用セレクター）
final dailyHistoryProvider = Provider<List<DailyPerformancePoint>>((ref) {
  final snapshot = ref.watch(analyticsSnapshotProvider);
  return snapshot.maybeWhen(
    data: (data) => data.dailyHistory,
    orElse: () => const [],
  );
});

/// 分析期間の選択（7日、30日、全期間）
enum AnalyticsRange {
  days7,
  days30,
  allTime,
}

final analyticsRangeProvider =
    StateProvider<AnalyticsRange>((ref) => AnalyticsRange.days30);

/// 音声効果のミュート状態
/// 設定画面で切り替え可能
final soundMutedProvider = StateProvider<bool>((ref) => false);

/// 通知が有効か確認（OS権限レベル）
final notificationEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(notificationServiceProvider);
  return service.isNotificationEnabled();
});

// ---------------------------------------------------------------------------
// Phase 18: Reporting & Export System Providers
// ---------------------------------------------------------------------------

/// レポート生成サービスプロバイダ
final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService();
});

/// データエクスポートサービスプロバイダ
final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

/// レポート生成パラメータ用クラス
class ReportGenerationParams {
  final String templateId;
  final String reportType;
  final String format;
  final DateTime startDate;
  final DateTime endDate;
  final String title;
  final String generatedBy;
  final Map<String, dynamic> dataSource;

  ReportGenerationParams({
    required this.templateId,
    required this.reportType,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.title,
    required this.generatedBy,
    required this.dataSource,
  });
}

/// レポート生成プロバイダ
final reportGenerationProvider =
    FutureProvider.family<GeneratedReport, ReportGenerationParams>(
  (ref, params) async {
    final service = ref.watch(reportServiceProvider);
    final config = ReportConfig(
      id: 'config_${DateTime.now().millisecondsSinceEpoch}',
      templateId: params.templateId,
      reportType: params.reportType,
      format: params.format,
      startDate: params.startDate,
      endDate: params.endDate,
    );
    return service.generateReport(
      templateId: params.templateId,
      config: config,
      title: params.title,
      generatedBy: params.generatedBy,
      dataSource: params.dataSource,
    );
  },
);

/// エクスポートデータパラメータ用クラス
class ExportDataParams {
  final String exportId;
  final String dataType;
  final String format;
  final DateTime startDate;
  final DateTime endDate;
  final List<String>? includedFields;
  final bool maskPersonalData;
  final bool includePersonalInfo;
  final String? encryptionType;
  final List<Map<String, dynamic>> dataRecords;

  ExportDataParams({
    required this.exportId,
    required this.dataType,
    required this.format,
    required this.startDate,
    required this.endDate,
    this.includedFields,
    this.maskPersonalData = false,
    this.includePersonalInfo = true,
    this.encryptionType,
    required this.dataRecords,
  });
}

/// データエクスポートプロバイダ
final exportDataProvider =
    FutureProvider.family<ExportResult, ExportDataParams>(
  (ref, params) async {
    final service = ref.watch(exportServiceProvider);
    final config = ExportConfig(
      id: params.exportId,
      dataType: params.dataType,
      format: params.format,
      startDate: params.startDate,
      endDate: params.endDate,
      includedFields: params.includedFields,
      maskPersonalData: params.maskPersonalData,
      includePersonalInfo: params.includePersonalInfo,
      encryptionType: params.encryptionType,
    );
    return service.exportData(
      exportId: params.exportId,
      config: config,
      dataRecords: params.dataRecords,
    );
  },
);

/// スケジュール配信パラメータ用クラス
class ScheduleDeliveryParams {
  final String templateId;
  final String deliveryType;
  final String frequency;
  final String time;
  final List<String> recipientEmails;
  final String? dayOfWeek;
  final int? dayOfMonth;

  ScheduleDeliveryParams({
    required this.templateId,
    required this.deliveryType,
    required this.frequency,
    required this.time,
    required this.recipientEmails,
    this.dayOfWeek,
    this.dayOfMonth,
  });
}

/// レポート配信スケジュール設定プロバイダ
final scheduleReportDeliveryProvider =
    FutureProvider.family<ReportDeliverySchedule, ScheduleDeliveryParams>(
  (ref, params) async {
    final service = ref.watch(reportServiceProvider);
    return service.scheduleReportDelivery(
      templateId: params.templateId,
      deliveryType: params.deliveryType,
      frequency: params.frequency,
      time: params.time,
      recipientEmails: params.recipientEmails,
      dayOfWeek: params.dayOfWeek,
      dayOfMonth: params.dayOfMonth,
    );
  },
);

/// クラス管理ビュー生成パラメータ用クラス
class ClassViewParams {
  final String classId;
  final String className;
  final List<StudentPerformanceAnalysis> studentAnalyses;

  ClassViewParams({
    required this.classId,
    required this.className,
    required this.studentAnalyses,
  });
}

/// クラス管理ビュー生成プロバイダ
final classManagementViewProvider =
    FutureProvider.family<ClassManagementView, ClassViewParams>(
  (ref, params) async {
    final service = ref.watch(reportServiceProvider);
    return service.generateClassView(
      classId: params.classId,
      className: params.className,
      studentAnalyses: params.studentAnalyses,
    );
  },
);
