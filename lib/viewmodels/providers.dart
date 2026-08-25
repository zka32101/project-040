import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/analytics_events.dart';
import '../core/constants/license_category.dart';
import '../models/bike_unlock_progress.dart';
import '../models/pass_prediction_score.dart';
import '../models/question.dart';
import '../models/achievement_badge.dart';
import '../models/question_mastery_status.dart';
import '../models/trap_dojo_session.dart';
import '../models/user.dart';
import '../models/user_answer_log.dart';
import '../services/ad_gate_service.dart';
import '../services/analytics_service.dart';
import '../services/local_data_service.dart';
import '../services/achievement_service.dart';
import '../services/mastery_service.dart';
import '../services/prediction_score_service.dart';
import '../services/purchase_service.dart';

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

/// 認証未接続のため固定uid。
/// TODO(firebase-setup): Firebase Auth 匿名認証に差し替え、uidをそこから取得する。
final currentUidProvider = Provider<String>((ref) => 'local_user');

// ---------------------------------------------------------------------------
// User
// ---------------------------------------------------------------------------

class UserController extends AsyncNotifier<AppUser> {
  @override
  Future<AppUser> build() async {
    final uid = ref.read(currentUidProvider);
    return ref.read(dataServiceProvider).loadUser(uid);
  }

  Future<void> setLicenseCategories(List<String> categories) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.copyWith(licenseCategories: categories);
    state = AsyncData(updated);
    await ref.read(dataServiceProvider).saveUser(updated);
  }

  Future<void> setTrainingStage(String? stage) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.copyWith(trainingStage: stage);
    state = AsyncData(updated);
    await ref.read(dataServiceProvider).saveUser(updated);
  }

  Future<void> setExamDate(DateTime? date) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.copyWith(examDate: date);
    state = AsyncData(updated);
    await ref.read(dataServiceProvider).saveUser(updated);
  }

  Future<void> setPurchaseStatus(PurchaseStatus status) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.copyWith(purchaseStatus: status);
    state = AsyncData(updated);
    await ref.read(dataServiceProvider).saveUser(updated);
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

  Future<void> answer(int choiceIndex) async {
    final question = state.currentQuestion;
    if (question == null) return;

    final isCorrect = choiceIndex == question.answer;
    final uid = ref.read(currentUidProvider);
    final now = DateTime.now();

    await ref.read(dataServiceProvider).appendAnswerLog(
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
    await ref.read(dataServiceProvider).savePredictionScore(score);

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

      // 質問メタデータを構築（簡略版）
      // 実装では、全質問から カテゴリ・ステージ情報を抽出する
      final questionMetadata = <String, dynamic>{
        'trapQuestions': <String>[],
        'categories': <String, List<String>>{
          'futsuuNirin': <String>[],
          'gentsuki': <String>[],
          'ogataNirin': <String>[],
        },
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
        await ref.read(analyticsServiceProvider).logEvent(
          AnalyticsEvents.bikeUnlocked,
          parameters: {'bike_id': progress.bikeId},
        );
        updated.add(unlocked);
      } else {
        updated.add(progress);
      }
    }
    state = AsyncData(updated);
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

    if (isCorrect) {
      await ref
          .read(analyticsServiceProvider)
          .logEvent(AnalyticsEvents.trapBossDefeated, parameters: {
        'question_id': bossQuestion.id,
        'trap_number_type': bossQuestion.trapNumberType.name,
      });
    }

    state = AsyncData([
      ...current.where((s) => s.bossQuestionId != bossQuestion.id),
      updatedSession,
    ]);
  }
}

final trapDojoControllerProvider =
    AsyncNotifierProvider<TrapDojoController, List<TrapDojoSession>>(
  TrapDojoController.new,
);
