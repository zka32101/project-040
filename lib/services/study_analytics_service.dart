import '../models/analytics_snapshot.dart';
import '../models/question.dart';
import '../models/user_answer_log.dart';
import 'question_index.dart';

/// 学習分析を計算するサービス（pure & synchronous）
/// SharedPreferencesなし、Future なし、Riverpod依存なし。
abstract class StudyAnalyticsService {
  /// 回答ログから分析スナップショットを生成
  AnalyticsSnapshot aggregate({
    required String uid,
    required List<UserAnswerLog> logs,
    required QuestionIndex index,
    required DateTime now,
    int historyDays = 30,
  });
}

class DefaultStudyAnalyticsService implements StudyAnalyticsService {
  /// 閾値：信頼度のある分析には最低5回の試行が必要
  static const int minAttemptsForWeakArea = 5;

  /// 正答率が低い弱点の判定基準
  static const double weakAreaThreshold = 0.8;

  /// 返す弱点の最大数
  static const int maxWeakAreas = 5;

  /// サンプル問題の最大数
  static const int maxSampleQuestions = 20;

  @override
  AnalyticsSnapshot aggregate({
    required String uid,
    required List<UserAnswerLog> logs,
    required QuestionIndex index,
    required DateTime now,
    int historyDays = 30,
  }) {
    if (logs.isEmpty) {
      return AnalyticsSnapshot(
        uid: uid,
        generatedAt: now,
        sourceLogCount: 0,
        overall: AccuracyStat(attempts: 0, correctCount: 0),
        stages: [],
        categories: [],
        weakAreas: [],
        recommendations: [],
        dailyHistory: [],
      );
    }

    // 累積統計とグループ化
    final byStage = <String, _StatAccumulator>{};
    final byCategory = <String, _StatAccumulator>{};
    final byTrapType = <TrapNumberType, _StatAccumulator>{};
    final byDifficulty = <int, _StatAccumulator>{};
    final byDay = <DateTime, _DailyAccumulator>{};
    final dailyQuestionSamples = <String, List<String>>{};

    var totalAttempts = 0;
    var totalCorrect = 0;
    var orphanCount = 0;

    // 単一パスで全ログを集計
    for (final log in logs) {
      totalAttempts++;
      if (log.isCorrect) totalCorrect++;

      final meta = index[log.questionId];
      if (meta == null) {
        orphanCount++;
        continue;
      }

      // ステージ別
      _addToAccumulator(byStage, meta.stageTag, log.isCorrect);

      // カテゴリ別（1つの問題が複数カテゴリに属する場合、全カテゴリにカウント）
      for (final category in meta.licenseCategory) {
        _addToAccumulator(byCategory, category, log.isCorrect);
      }

      // トラップ問題の種別別
      if (meta.isTrapQuestion) {
        _addToAccumulator(byTrapType, meta.trapNumberType, log.isCorrect);
      }

      // 難易度別
      _addToAccumulator(byDifficulty, meta.difficulty, log.isCorrect);

      // 日別（timestampを日付に丸める）
      final dayKey = DateTime(
        log.answeredAt.year,
        log.answeredAt.month,
        log.answeredAt.day,
      );
      if (!byDay.containsKey(dayKey)) {
        byDay[dayKey] = _DailyAccumulator();
      }
      byDay[dayKey]!.attempts++;
      if (log.isCorrect) byDay[dayKey]!.correctCount++;

      // 弱点分析用のサンプル（トラップ種別ごと）
      if (meta.isTrapQuestion) {
        final key = 'trap:${meta.trapNumberType.name}';
        dailyQuestionSamples
            .putIfAbsent(key, () => [])
            .add(log.questionId);
      }
    }

    final overallAccuracy =
        totalAttempts == 0 ? 0.0 : totalCorrect / totalAttempts;

    // ステージパフォーマンスの構築
    final stages = byStage.entries
        .map((e) => StagePerformance(
          stageTag: e.key,
          stat: AccuracyStat(
            attempts: e.value.attempts,
            correctCount: e.value.correctCount,
          ),
        ))
        .toList();

    // カテゴリパフォーマンスの構築
    final categories = byCategory.entries
        .map((e) => CategoryPerformance(
          categoryId: e.key,
          stat: AccuracyStat(
            attempts: e.value.attempts,
            correctCount: e.value.correctCount,
          ),
        ))
        .toList();

    // 弱点の抽出（複数の角度から）
    final weakAreaCandidates = <WeakArea>[];

    // ステージ別の弱点
    for (final entry in byStage.entries) {
      final stat = entry.value;
      if (stat.attempts >= minAttemptsForWeakArea) {
        final accuracy = stat.correctCount / stat.attempts;
        if (accuracy < weakAreaThreshold) {
          final severity = _calculateSeverity(
            accuracy,
            stat.attempts,
            totalAttempts,
          );
          weakAreaCandidates.add(WeakArea(
            kind: WeakAreaKind.stage,
            key: 'stage:${entry.key}',
            label: entry.key,
            stat: AccuracyStat(
              attempts: stat.attempts,
              correctCount: stat.correctCount,
            ),
            severity: severity,
            sampleQuestionIds: [],
          ));
        }
      }
    }

    // カテゴリ別の弱点
    for (final entry in byCategory.entries) {
      final stat = entry.value;
      if (stat.attempts >= minAttemptsForWeakArea) {
        final accuracy = stat.correctCount / stat.attempts;
        if (accuracy < weakAreaThreshold) {
          final severity = _calculateSeverity(
            accuracy,
            stat.attempts,
            totalAttempts,
          );
          weakAreaCandidates.add(WeakArea(
            kind: WeakAreaKind.category,
            key: 'category:${entry.key}',
            label: entry.key,
            stat: AccuracyStat(
              attempts: stat.attempts,
              correctCount: stat.correctCount,
            ),
            severity: severity,
            sampleQuestionIds: [],
          ));
        }
      }
    }

    // トラップ種別の弱点
    for (final entry in byTrapType.entries) {
      final stat = entry.value;
      if (stat.attempts >= minAttemptsForWeakArea) {
        final accuracy = stat.correctCount / stat.attempts;
        if (accuracy < weakAreaThreshold) {
          final severity = _calculateSeverity(
            accuracy,
            stat.attempts,
            totalAttempts,
          );
          final label = _trapTypeLabel(entry.key);
          weakAreaCandidates.add(WeakArea(
            kind: WeakAreaKind.trapType,
            key: 'trap:${entry.key.name}',
            label: label,
            stat: AccuracyStat(
              attempts: stat.attempts,
              correctCount: stat.correctCount,
            ),
            severity: severity,
            sampleQuestionIds: (dailyQuestionSamples[label] ?? [])
                .take(maxSampleQuestions)
                .toList(),
          ));
        }
      }
    }

    // 難易度別の弱点
    for (final entry in byDifficulty.entries) {
      final stat = entry.value;
      if (stat.attempts >= minAttemptsForWeakArea) {
        final accuracy = stat.correctCount / stat.attempts;
        if (accuracy < weakAreaThreshold) {
          final severity = _calculateSeverity(
            accuracy,
            stat.attempts,
            totalAttempts,
          );
          weakAreaCandidates.add(WeakArea(
            kind: WeakAreaKind.difficulty,
            key: 'difficulty:${entry.key}',
            label: '難易度${entry.key}',
            stat: AccuracyStat(
              attempts: stat.attempts,
              correctCount: stat.correctCount,
            ),
            severity: severity,
            sampleQuestionIds: [],
          ));
        }
      }
    }

    // 重大度でソート、上位を抽出
    weakAreaCandidates.sort((a, b) => b.severity.compareTo(a.severity));
    final weakAreas = weakAreaCandidates.take(maxWeakAreas).toList();

    // 復習推奨の生成
    final recommendations = _generateRecommendations(weakAreas);

    // 日別履歴の構築（日付の昇順、最近のhistoryDaysのみ）
    final cutoffDate = now.subtract(Duration(days: historyDays));
    final dailyHistory = byDay.entries
        .where((e) => e.key.isAfter(cutoffDate))
        .map((e) => DailyPerformancePoint(
          date: e.key,
          attempts: e.value.attempts,
          correctCount: e.value.correctCount,
        ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return AnalyticsSnapshot(
      uid: uid,
      generatedAt: now,
      sourceLogCount: logs.length,
      overall: AccuracyStat(
        attempts: totalAttempts,
        correctCount: totalCorrect,
      ),
      stages: stages,
      categories: categories,
      weakAreas: weakAreas,
      recommendations: recommendations,
      dailyHistory: dailyHistory,
      orphanLogCount: orphanCount,
    );
  }

  /// 重大度スコアを計算
  /// severity = (1 - accuracy) * confidence * volumeWeight
  double _calculateSeverity(
    double accuracy,
    int attempts,
    int totalAttempts,
  ) {
    final gapFromTarget = 1.0 - accuracy; // 0.8（弱点境界）から0.0（完璧）までの距離
    final confidence = (attempts / AccuracyStat.minReliableAttempts).clamp(0.0, 1.0);
    final volumeWeight =
        (attempts / (totalAttempts == 0 ? 1 : totalAttempts) * 5)
            .clamp(0.0, 1.0);
    return gapFromTarget * confidence * volumeWeight;
  }

  /// 復習推奨を生成
  List<ReviewRecommendation> _generateRecommendations(
    List<WeakArea> weakAreas,
  ) {
    final recommendations = <ReviewRecommendation>[];
    for (final area in weakAreas) {
      late ReviewActionType action;
      late String title;
      late String body;
      final payload = <String, String>{};

      switch (area.kind) {
        case WeakAreaKind.trapType:
          // トラップ問題は道場で練習
          action = ReviewActionType.trapDojo;
          title = '${area.label}を克服する';
          body = '${area.label}に特化した問題を道場で練習してみましょう。';
          break;
        case WeakAreaKind.stage:
          // ステージ別は段階別ドリル
          action = ReviewActionType.stageDrill;
          title = '${area.label}を集中練習';
          body = '${area.label}の出題パターンを集中的に学習します。';
          payload['stageTag'] = area.label;
          break;
        case WeakAreaKind.category:
          // カテゴリ別は日々のノルマで集中
          action = ReviewActionType.dailyQuota;
          title = '${area.label}で正答率向上';
          body = '${area.label}の問題を重点的に出題します。';
          payload['licenseCategory'] = area.label;
          break;
        case WeakAreaKind.difficulty:
          // 難問は通常の学習
          action = ReviewActionType.dailyQuota;
          title = '難問への対応力を強化';
          body = 'より難しい問題に挑戦して、合格ラインを目指しましょう。';
          break;
        case WeakAreaKind.topic:
          // トピック別は今後対応
          action = ReviewActionType.masteryReview;
          title = '${area.label}を復習';
          body = 'このテーマについて、詳しく学習してみましょう。';
          break;
      }

      recommendations.add(ReviewRecommendation(
        weakAreaKey: area.key,
        title: title,
        body: body,
        action: action,
        payload: payload,
      ));
    }
    return recommendations;
  }

  /// トラップ問題の種別をラベルに変換
  String _trapTypeLabel(TrapNumberType type) {
    switch (type) {
      case TrapNumberType.none:
        return 'その他のひっかけ';
      case TrapNumberType.twoPersonRiding:
        return '二人乗り条件';
      case TrapNumberType.loadLimit:
        return '積載制限';
      case TrapNumberType.twoStageRightTurn:
        return '二段階右折';
      case TrapNumberType.speedLimit:
        return '速度制限';
      case TrapNumberType.followingDistance:
        return '追従距離';
      case TrapNumberType.other:
        return 'その他のひっかけ';
    }
  }
}

/// 統計値の累積用ヘルパークラス
class _StatAccumulator {
  int attempts = 0;
  int correctCount = 0;
}

/// 日別統計の累積用ヘルパークラス
class _DailyAccumulator {
  int attempts = 0;
  int correctCount = 0;
}
