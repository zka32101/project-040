import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_recommendation_model.freezed.dart';
part 'ai_recommendation_model.g.dart';

/// AI推奨ロジックのデータモデル集合
/// 適応的学習パスと個別最適化学習を支える

// ============================================================================
// 1. 学習パス・推奨データモデル
// ============================================================================

/// 学習パス要素（単一の学習ステップ）
@freezed
class LearningPathElement with _$LearningPathElement {
  const factory LearningPathElement({
    required String id,
    required String questionId,
    required String categoryId,
    required String subcategoryId,
    required int difficulty, // 1-5 (1=簡単, 5=難しい)
    required String rationale, // なぜこの問題を推奨したのか
    required DateTime recommendedAt,
    DateTime? completedAt,
    bool? passed, // null=未実施, true=正解, false=不正解
  }) = _LearningPathElement;

  factory LearningPathElement.fromJson(Map<String, dynamic> json) =>
      _$LearningPathElementFromJson(json);
}

/// 適応的学習パス（学生ごとの個別学習経路）
@freezed
class AdaptiveLearningPath with _$AdaptiveLearningPath {
  const factory AdaptiveLearningPath({
    required String studentId,
    required List<LearningPathElement> elements,
    required DateTime generatedAt,
    required String generationReason, // パス生成の根拠
    required double estimatedCompletionTime, // 時間（時間単位）
    int? currentElementIndex,
    bool? isActive,
  }) = _AdaptiveLearningPath;

  factory AdaptiveLearningPath.fromJson(Map<String, dynamic> json) =>
      _$AdaptiveLearningPathFromJson(json);
}

/// 学習推奨（特定のトピックや学習方法の推奨）
@freezed
class LearningRecommendation with _$LearningRecommendation {
  const factory LearningRecommendation({
    required String id,
    required String studentId,
    required String type, // 'focus_area', 'review', 'skip', 'group_study'
    required String contentId, // カテゴリID等
    required String contentTitle,
    required String description,
    required int priority, // 1-10 (10=最優先)
    required double effectScore, // この推奨の効果スコア 0-100
    required String reason, // 推奨理由の説明
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    double? userRating, // ユーザーによる評価 0-5
  }) = _LearningRecommendation;

  factory LearningRecommendation.fromJson(Map<String, dynamic> json) =>
      _$LearningRecommendationFromJson(json);
}

// ============================================================================
// 2. 難度調整・スケーリングモデル
// ============================================================================

/// 難度調整エンジンの状態
@freezed
class DifficultyAdjustment with _$DifficultyAdjustment {
  const factory DifficultyAdjustment({
    required String studentId,
    required Map<String, DifficultyLevel> categoryLevels,
    required DateTime lastAdjustedAt,
    required String adjustmentStrategy, // 'aggressive', 'moderate', 'conservative'
  }) = _DifficultyAdjustment;

  factory DifficultyAdjustment.fromJson(Map<String, dynamic> json) =>
      _$DifficultyAdjustmentFromJson(json);
}

/// カテゴリごとの難度レベル
@freezed
class DifficultyLevel with _$DifficultyLevel {
  const factory DifficultyLevel({
    required String categoryId,
    required int currentLevel, // 1-5
    required double accuracyRate, // 現在の正答率
    required int questionCount, // 実施問題数
    required DateTime lastUpdatedAt,
  }) = _DifficultyLevel;

  factory DifficultyLevel.fromJson(Map<String, dynamic> json) =>
      _$DifficultyLevelFromJson(json);
}

// ============================================================================
// 3. 予測・分析モデル
// ============================================================================

/// 学習効果予測
@freezed
class LearningEffectPrediction with _$LearningEffectPrediction {
  const factory LearningEffectPrediction({
    required String studentId,
    required double passLikelihood, // 合格可能性 0-100%
    required double estimatedDaysToCompletion, // 修了予定日数
    required double estimatedHoursToCompletion, // 修了予定時間
    required String completionStatus, // 'on_track', 'at_risk', 'slow', 'fast'
    required List<String> riskFactors, // 脱落リスク要因
    required List<String> successFactors, // 成功要因
    required DateTime generatedAt,
    required double confidenceScore, // 予測の信頼度 0-100%
  }) = _LearningEffectPrediction;

  factory LearningEffectPrediction.fromJson(Map<String, dynamic> json) =>
      _$LearningEffectPredictionFromJson(json);
}

/// 脱落リスク検出
@freezed
class DropoutRiskDetection with _$DropoutRiskDetection {
  const factory DropoutRiskDetection({
    required String studentId,
    required double riskScore, // 0-100 (100=最高リスク)
    required List<String> riskIndicators, // リスク指標のリスト
    required String riskLevel, // 'low', 'medium', 'high', 'critical'
    required List<String> interventionSuggestions, // 介入提案
    required DateTime detectedAt,
  }) = _DropoutRiskDetection;

  factory DropoutRiskDetection.fromJson(Map<String, dynamic> json) =>
      _$DropoutRiskDetectionFromJson(json);
}

// ============================================================================
// 4. スタック・プラトー検出モデル
// ============================================================================

/// スタック検出（成長停滞）
@freezed
class StuckDetection with _$StuckDetection {
  const factory StuckDetection({
    required String studentId,
    required String categoryId,
    required int dayCount, // 停滞日数
    required double accuracyRate, // 停滞中の正答率
    required int problemCount, // 実施問題数
    required DateTime detectedAt,
    required List<String> suggestedInterventions,
  }) = _StuckDetection;

  factory StuckDetection.fromJson(Map<String, dynamic> json) =>
      _$StuckDetectionFromJson(json);
}

/// 代替学習法提案
@freezed
class AlternativeLearningMethod with _$AlternativeLearningMethod {
  const factory AlternativeLearningMethod({
    required String id,
    required String studentId,
    required String categoryId,
    required String methodType, // 'video', 'explanation', 'practice_intensive', 'groupwork'
    required String description,
    required double expectedEffectiveness, // 0-100%
    required String reason,
    DateTime? suggestedAt,
  }) = _AlternativeLearningMethod;

  factory AlternativeLearningMethod.fromJson(Map<String, dynamic> json) =>
      _$AlternativeLearningMethodFromJson(json);
}

// ============================================================================
// 5. 復習スケジューリング・忘却曲線モデル
// ============================================================================

/// 復習予定
@freezed
class ReviewSchedule with _$ReviewSchedule {
  const factory ReviewSchedule({
    required String studentId,
    required String questionId,
    required DateTime nextReviewDate,
    required int reviewCount, // これまでの復習回数
    required String interval, // '1day', '3days', '1week', '2weeks', '1month'
    required double retentionRate, // 保持率 0-100%
    DateTime? lastReviewedAt,
  }) = _ReviewSchedule;

  factory ReviewSchedule.fromJson(Map<String, dynamic> json) =>
      _$ReviewScheduleFromJson(json);
}

// ============================================================================
// 6. グループ学習マッチングモデル
// ============================================================================

/// スタディグループマッチング情報
@freezed
class StudyGroupMatch with _$StudyGroupMatch {
  const factory StudyGroupMatch({
    required String studentId,
    required List<String> suggestedPeerIds, // マッチング対象の学生ID
    required List<String> suggestedTopics, // グループ学習が効果的な単元
    required double compatibilityScore, // マッチング度 0-100%
    required String reason, // マッチング理由
    required DateTime generatedAt,
  }) = _StudyGroupMatch;

  factory StudyGroupMatch.fromJson(Map<String, dynamic> json) =>
      _$StudyGroupMatchFromJson(json);
}

/// グループ学習セッション
@freezed
class GroupLearningSession with _$GroupLearningSession {
  const factory GroupLearningSession({
    required String id,
    required List<String> studentIds,
    required String topicId,
    required String topicName,
    required DateTime scheduledAt,
    DateTime? startedAt,
    DateTime? completedAt,
    required int estimatedDurationMinutes,
    List<String>? resourceUrls,
    String? outcome, // 'completed', 'in_progress', 'cancelled'
    Map<String, double>? studentScores, // 学生ごとのスコア
  }) = _GroupLearningSession;

  factory GroupLearningSession.fromJson(Map<String, dynamic> json) =>
      _$GroupLearningSessionFromJson(json);
}

// ============================================================================
// 7. ピア比較・モチベーションモデル
// ============================================================================

/// ピア比較情報
@freezed
class PeerComparison with _$PeerComparison {
  const factory PeerComparison({
    required String studentId,
    required double studentScore,
    required double cohortAverage,
    required double cohortMedian,
    required int percentileRank, // 0-100
    required int cohortSize,
    required String performanceLevel, // 'top_10%', 'above_average', 'average', 'below_average', 'needs_support'
    required List<String> strengths, // 強み
    required List<String> improvementAreas, // 改善エリア
    required DateTime generatedAt,
  }) = _PeerComparison;

  factory PeerComparison.fromJson(Map<String, dynamic> json) =>
      _$PeerComparisonFromJson(json);
}

/// 励まし・モチベーションメッセージ
@freezed
class MotivationalInsight with _$MotivationalInsight {
  const factory MotivationalInsight({
    required String id,
    required String studentId,
    required String messageType, // 'achievement', 'encouragement', 'milestone', 'comparison'
    required String message,
    required String actionCTA, // Call-to-Action テキスト
    required DateTime generatedAt,
    DateTime? viewedAt,
  }) = _MotivationalInsight;

  factory MotivationalInsight.fromJson(Map<String, dynamic> json) =>
      _$MotivationalInsightFromJson(json);
}
