import 'package:flutter/foundation.dart';
import '../models/ai_recommendation_model.dart';
import 'dart:math' as math;

/// 機械学習ベースの予測エンジン
/// 学習効果、脱落リスク、修了時間を予測
class MLPredictorService {
  // 予測キャッシュ
  final Map<String, LearningEffectPrediction> _predictionCache = {};
  final Map<String, DropoutRiskDetection> _riskCache = {};

  /// 学習効果予測：現在の進捗から修了可能性と修了時期を予測
  Future<LearningEffectPrediction> predictLearningEffect({
    required String studentId,
    required double currentScore,
    required int questionsAttempted,
    required int correctAnswers,
    required int totalQuestions,
    required DateTime enrollmentDate,
    required DateTime? targetDate,
    required Map<String, double> categoryScores,
  }) async {
    // キャッシュから取得
    if (_predictionCache.containsKey(studentId)) {
      return _predictionCache[studentId]!;
    }

    try {
      // 1. 現在の正答率を計算
      final currentAccuracy = correctAnswers / questionsAttempted;

      // 2. 学習速度を計算（1日あたりの進捗）
      final daysEnrolled =
          DateTime.now().difference(enrollmentDate).inDays.toDouble();
      final learningVelocity = questionsAttempted / (daysEnrolled + 1);

      // 3. 合格可能性を計算（ロジスティック回帰モデルのシミュレーション）
      final passLikelihood = _calculatePassLikelihood(
        accuracy: currentAccuracy,
        progress: questionsAttempted / totalQuestions,
        consistency: _calculateConsistency(categoryScores),
      );

      // 4. 修了予定日数を計算
      final remainingQuestions = totalQuestions - questionsAttempted;
      final estimatedDaysToCompletion =
          remainingQuestions / (learningVelocity + 0.1); // 0 divide 防止

      // 5. 修了予定時間を計算（1問あたり平均 4.5 分）
      const minutesPerQuestion = 4.5;
      final estimatedHoursToCompletion =
          (remainingQuestions * minutesPerQuestion) / 60;

      // 6. 完了状態を判定
      final completionStatus = _determineCompletionStatus(
        passLikelihood: passLikelihood,
        daysToCompletion: estimatedDaysToCompletion,
        targetDate: targetDate,
      );

      // 7. リスク要因と成功要因を特定
      final riskFactors = _identifyRiskFactors(
        accuracy: currentAccuracy,
        velocity: learningVelocity,
        categoryScores: categoryScores,
      );
      final successFactors = _identifySuccessFactors(
        accuracy: currentAccuracy,
        velocity: learningVelocity,
        consistency: _calculateConsistency(categoryScores),
      );

      // 8. 信頼度スコアを計算
      final confidenceScore = _calculateConfidence(questionsAttempted);

      final prediction = LearningEffectPrediction(
        studentId: studentId,
        passLikelihood: passLikelihood,
        estimatedDaysToCompletion: estimatedDaysToCompletion,
        estimatedHoursToCompletion: estimatedHoursToCompletion,
        completionStatus: completionStatus,
        riskFactors: riskFactors,
        successFactors: successFactors,
        generatedAt: DateTime.now(),
        confidenceScore: confidenceScore,
      );

      // キャッシュに保存
      _predictionCache[studentId] = prediction;
      return prediction;
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'MLPredictorService.predictEffect');
      rethrow;
    }
  }

  /// 脱落リスク検出：学習を中断する可能性を早期に検出
  Future<DropoutRiskDetection> detectDropoutRisk({
    required String studentId,
    required double currentScore,
    required int daysSinceLastActivity,
    required int missedDays,
    required Map<String, double> categoryScores,
    required int loginStreak,
    required List<String> previousUserFeedback,
  }) async {
    // キャッシュから取得
    if (_riskCache.containsKey(studentId)) {
      return _riskCache[studentId]!;
    }

    try {
      // 1. リスク指標を収集
      final riskIndicators = <String>[];

      if (daysSinceLastActivity > 7) {
        riskIndicators.add('長期非アクティブ（${daysSinceLastActivity}日）');
      }
      if (missedDays > 5) {
        riskIndicators.add('頻繁に予定をスキップ（${missedDays}日間）');
      }
      if (currentScore < 40) {
        riskIndicators.add('低い正答率（${currentScore.toStringAsFixed(1)}%）');
      }
      if (loginStreak == 0) {
        riskIndicators.add('ログインストリーク中断');
      }

      // 2. リスクスコアを計算
      double riskScore = 0;
      riskScore += math.min(daysSinceLastActivity * 3, 30); // 最大 30 点
      riskScore += missedDays * 2; // 最大 20 点
      riskScore += math.max(0, 50 - currentScore); // スコア低いほど高リスク
      if (loginStreak == 0) riskScore += 20;
      riskScore = (riskScore / 100 * 100).clamp(0, 100).toDouble();

      // 3. リスクレベルを判定
      final riskLevel = _determineRiskLevel(riskScore);

      // 4. 介入提案を生成
      final interventions = _generateInterventions(
        riskScore: riskScore,
        riskIndicators: riskIndicators,
        categoryScores: categoryScores,
        feedback: previousUserFeedback,
      );

      final detection = DropoutRiskDetection(
        studentId: studentId,
        riskScore: riskScore,
        riskIndicators: riskIndicators,
        riskLevel: riskLevel,
        interventionSuggestions: interventions,
        detectedAt: DateTime.now(),
      );

      // キャッシュに保存
      _riskCache[studentId] = detection;
      return detection;
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'MLPredictorService.detectDropout');
      rethrow;
    }
  }

  /// 合格可能性を計算（ロジスティック回帰の簡略版）
  double _calculatePassLikelihood({
    required double accuracy,
    required double progress,
    required double consistency,
  }) {
    // 重み付けロジスティック関数
    const accuracyWeight = 0.5;
    const progressWeight = 0.3;
    const consistencyWeight = 0.2;

    final weighted =
        (accuracy * accuracyWeight) + (progress * progressWeight) + (consistency * consistencyWeight);

    // ロジスティック関数で 0-100 に変換
    const intercept = -2.0;
    const scale = 4.0;
    final logit = intercept + (scale * weighted);
    final sigmoid = 1 / (1 + math.exp(-logit));

    return sigmoid * 100;
  }

  /// 一貫性スコアを計算
  double _calculateConsistency(Map<String, double> categoryScores) {
    if (categoryScores.isEmpty) return 50;

    final scores = categoryScores.values.toList();
    final mean = scores.reduce((a, b) => a + b) / scores.length;
    final variance = scores.fold<double>(
      0,
      (sum, score) => sum + math.pow(score - mean, 2),
    ) / scores.length;
    final stdDev = math.sqrt(variance);

    // 標準偏差が小さいほど一貫性が高い
    const maxStdDev = 30;
    final consistency = math.max(0, 1 - (stdDev / maxStdDev)) * 100;

    return consistency.clamp(0, 100);
  }

  /// 完了状態を判定
  String _determineCompletionStatus({
    required double passLikelihood,
    required double daysToCompletion,
    required DateTime? targetDate,
  }) {
    if (passLikelihood < 30) return 'at_risk';
    if (daysToCompletion > 60) return 'slow';
    if (daysToCompletion < 7) return 'fast';
    return 'on_track';
  }

  /// リスク要因を特定
  List<String> _identifyRiskFactors({
    required double accuracy,
    required double velocity,
    required Map<String, double> categoryScores,
  }) {
    final factors = <String>[];

    if (accuracy < 50) factors.add('低い正答率が継続');
    if (velocity < 2) factors.add('学習速度が遅い');

    // 最も低いカテゴリスコアを特定
    final worstCategory = categoryScores.entries
        .fold<MapEntry<String, double>?>(
          null,
          (prev, curr) => prev == null || curr.value < prev.value ? curr : prev,
        );
    if (worstCategory != null && worstCategory.value < 40) {
      factors.add('${worstCategory.key}で特に苦手');
    }

    return factors;
  }

  /// 成功要因を特定
  List<String> _identifySuccessFactors({
    required double accuracy,
    required double velocity,
    required double consistency,
  }) {
    final factors = <String>[];

    if (accuracy > 70) factors.add('高い正答率を維持');
    if (velocity > 5) factors.add('学習ペースが速い');
    if (consistency > 75) factors.add('各分野で安定した成績');

    return factors;
  }

  /// 信頼度スコアを計算（サンプルサイズが大きいほど信頼度が高い）
  double _calculateConfidence(int questionsAttempted) {
    // 最小 50 問で 60% の信頼度、1000 問以上で 95% の信頼度
    const minQuestions = 50;
    const maxQuestions = 1000;
    const minConfidence = 60;
    const maxConfidence = 95;

    if (questionsAttempted < minQuestions) {
      return minConfidence * (questionsAttempted / minQuestions);
    }
    if (questionsAttempted >= maxQuestions) {
      return maxConfidence;
    }

    return minConfidence +
        ((questionsAttempted - minQuestions) / (maxQuestions - minQuestions)) *
            (maxConfidence - minConfidence);
  }

  /// リスクレベルを判定
  String _determineRiskLevel(double riskScore) {
    if (riskScore < 20) return 'low';
    if (riskScore < 40) return 'medium';
    if (riskScore < 70) return 'high';
    return 'critical';
  }

  /// 介入提案を生成
  List<String> _generateInterventions({
    required double riskScore,
    required List<String> riskIndicators,
    required Map<String, double> categoryScores,
    required List<String> feedback,
  }) {
    final interventions = <String>[];

    if (riskScore > 70) {
      interventions.add('緊急サポート：メンターに相談を推奨');
      interventions.add('学習目標を小分けにしての短期目標設定');
    } else if (riskScore > 40) {
      interventions.add('学習ペース調整：1日の勉強時間を減らす');
      interventions.add('弱点分野の集中講座を推奨');
    }

    // 最低スコアのカテゴリに対する介入
    final worstCategory = categoryScores.entries
        .fold<MapEntry<String, double>?>(
          null,
          (prev, curr) => prev == null || curr.value < prev.value ? curr : prev,
        );
    if (worstCategory != null) {
      interventions.add('${worstCategory.key}の補習教材を提供');
    }

    return interventions;
  }

  /// キャッシュのクリア
  void clearCache(String studentId) {
    _predictionCache.remove(studentId);
    _riskCache.remove(studentId);
  }

  /// 全キャッシュのクリア
  void clearAllCache() {
    _predictionCache.clear();
    _riskCache.clear();
  }
}
