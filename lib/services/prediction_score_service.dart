import '../models/pass_prediction_score.dart';
import '../models/user_answer_log.dart';
import '../models/question.dart';

/// 合格予測メーターの計算ロジック。
///
/// 【致命的リスク①・実装時に詳細化した設計】
/// 単純な直近正答率だけでは「予測」と名乗るには説得力が弱いとレビューで
/// 指摘されたため、以下の重み付けを行う：
///   1. 区分別正答率（breakdownの元）
///   2. 難易度重み（難問の正解はスコアへの寄与を高くする）
///   3. 直近性重み（直近の回答ほど重みを重くし、学習の伸びを反映）
///   4. 回答数ペナルティ（回答数が少ないうちは信頼区間が広いためスコアを
///      100%側に張り付かせない = `_confidenceFactor`）
///
/// 回答数が `minAnswersForPrediction` 未満の場合、呼び出し側（UI）は
/// 「予測」ではなく「習熟度」表記にフォールバックすること
/// （`PassPredictionScore` 自体はどちらの文言にも使えるよう中立に保つ）。
class PredictionScoreService {
  PredictionScoreService();

  static const int minAnswersForPrediction = 10;

  PassPredictionScore calculate({
    required String uid,
    required List<UserAnswerLog> logs,
    required Map<String, Question> questionsById,
    required DateTime now,
  }) {
    if (logs.isEmpty) {
      return PassPredictionScore(
        uid: uid,
        score: 0,
        calculatedAt: now,
        breakdown: const {},
      );
    }

    // 区分別に重み付き正答率を積み上げる。
    final categoryWeightedCorrect = <String, double>{};
    final categoryWeightedTotal = <String, double>{};

    double totalWeightedCorrect = 0;
    double totalWeight = 0;

    for (final log in logs) {
      final question = questionsById[log.questionId];
      if (question == null) continue;

      final difficultyWeight = 1.0 + (question.difficulty - 1) * 0.25; // 1.0〜2.0
      final daysAgo = now.difference(log.answeredAt).inDays.clamp(0, 60);
      final recencyWeight = 1.0 - (daysAgo / 60) * 0.5; // 0.5〜1.0
      final weight = difficultyWeight * recencyWeight;

      totalWeight += weight;
      if (log.isCorrect) totalWeightedCorrect += weight;

      for (final category in question.licenseCategory) {
        categoryWeightedTotal[category] =
            (categoryWeightedTotal[category] ?? 0) + weight;
        if (log.isCorrect) {
          categoryWeightedCorrect[category] =
              (categoryWeightedCorrect[category] ?? 0) + weight;
        }
      }
    }

    final rawRatio = totalWeight == 0 ? 0.0 : totalWeightedCorrect / totalWeight;

    // 回答数ペナルティ：回答数が少ないうちは0.5(五分五分)に引っ張られる。
    // logs.length が minAnswersForPrediction に達すると confidence=1.0。
    final confidence =
        (logs.length / minAnswersForPrediction).clamp(0.0, 1.0);
    final adjustedRatio = 0.5 + (rawRatio - 0.5) * confidence;

    final breakdown = <String, double>{
      for (final category in categoryWeightedTotal.keys)
        category: categoryWeightedTotal[category] == 0
            ? 0
            : (categoryWeightedCorrect[category] ?? 0) /
                categoryWeightedTotal[category]!,
    };

    return PassPredictionScore(
      uid: uid,
      score: (adjustedRatio * 100).clamp(0, 100),
      calculatedAt: now,
      breakdown: breakdown,
    );
  }

  bool hasEnoughDataForPrediction(int answeredCount) =>
      answeredCount >= minAnswersForPrediction;
}
