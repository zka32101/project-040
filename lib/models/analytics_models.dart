/// Phase 90: Advanced AI-Powered Analytics & Insights
/// Core domain models for AI-powered analytics and predictive systems
library analytics_models;

// ============================================================================
// ENUMS (6 total)
// ============================================================================

enum PredictionType {
  regression('回帰'),
  classification('分類'),
  timeSeries('時系列'),
  anomaly('異常検出'),
  clustering('クラスタリング'),
  forecasting('予測');

  const PredictionType(this.displayName);
  final String displayName;
}

enum AnomalyType {
  outlier('外れ値'),
  trend('トレンド異常'),
  seasonal('季節性異常'),
  collective('集合異常'),
  contextual('文脈異常');

  const AnomalyType(this.displayName);
  final String displayName;
}

enum AlertSeverity {
  critical('クリティカル'),
  high('高'),
  medium('中'),
  low('低'),
  info('情報');

  const AlertSeverity(this.displayName);
  final String displayName;
}

enum PatternType {
  sequential('シーケンシャル'),
  parallel('並列'),
  cyclical('周期的'),
  trending('トレンド'),
  oscillating('振動');

  const PatternType(this.displayName);
  final String displayName;
}

enum CorrelationType {
  strongPositive('強正相関'),
  weakPositive('弱正相関'),
  strongNegative('強負相関'),
  weakNegative('弱負相関'),
  noCorrelation('相関なし');

  const CorrelationType(this.displayName);
  final String displayName;
}

enum FraudRiskLevel {
  critical('クリティカル'),
  high('高'),
  medium('中'),
  low('低'),
  minimal('最小');

  const FraudRiskLevel(this.displayName);
  final String displayName;
}

// ============================================================================
// MODELS (12 total)
// ============================================================================

/// PredictiveModel: 予測モデル
class PredictiveModel {
  PredictiveModel({
    required this.id,
    required this.modelName,
    required this.predictionType,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.accuracy = 0.0,
    this.isActive = true,
    this.lastTrainedAt,
  });

  final String id;
  final String modelName;
  final PredictionType predictionType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final double accuracy;
  final bool isActive;
  final DateTime? lastTrainedAt;

  bool get isAccurate => accuracy > 0.85;
  bool get needsRetraining =>
      lastTrainedAt == null ||
      DateTime.now().difference(lastTrainedAt!).inDays > 30;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  int get daysSinceTraining => lastTrainedAt != null
      ? DateTime.now().difference(lastTrainedAt!).inDays
      : -1;

  PredictiveModel copyWith({
    String? id,
    String? modelName,
    PredictionType? predictionType,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
    double? accuracy,
    bool? isActive,
    DateTime? lastTrainedAt,
  }) {
    return PredictiveModel(
      id: id ?? this.id,
      modelName: modelName ?? this.modelName,
      predictionType: predictionType ?? this.predictionType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
      accuracy: accuracy ?? this.accuracy,
      isActive: isActive ?? this.isActive,
      lastTrainedAt: lastTrainedAt ?? this.lastTrainedAt,
    );
  }
}

/// Prediction: 予測結果
class Prediction {
  Prediction({
    required this.id,
    required this.modelId,
    required this.predictedValue,
    required this.confidence,
    required this.predictionTime,
    required this.createdAt,
    this.actualValue,
    this.features,
    this.error = 0.0,
  });

  final String id;
  final String modelId;
  final dynamic predictedValue;
  final double confidence;
  final DateTime predictionTime;
  final DateTime createdAt;
  final dynamic? actualValue;
  final Map<String, dynamic>? features;
  final double error;

  bool get isHighConfidence => confidence > 0.9;
  bool get hasActualValue => actualValue != null;
  int get ageInMinutes => DateTime.now().difference(predictionTime).inMinutes;
}

/// AnomalyDetection: 異常検出
class AnomalyDetection {
  AnomalyDetection({
    required this.id,
    required this.datasetId,
    required this.anomalyType,
    required this.detectedAt,
    required this.createdAt,
    this.anomalyScore = 0.0,
    this.description,
    this.severity = AnomalyType.outlier,
    this.isInvestigated = false,
  });

  final String id;
  final String datasetId;
  final AnomalyType anomalyType;
  final DateTime detectedAt;
  final DateTime createdAt;
  final double anomalyScore;
  final String? description;
  final AnomalyType severity;
  final bool isInvestigated;

  bool get isCritical => anomalyScore > 0.8;
  int get ageInHours => DateTime.now().difference(detectedAt).inHours;
}

/// PatternAnalysis: パターン分析
class PatternAnalysis {
  PatternAnalysis({
    required this.id,
    required this.datasetId,
    required this.patternType,
    required this.detectedAt,
    required this.createdAt,
    this.confidence = 0.0,
    this.frequency = 0,
    this.description,
  });

  final String id;
  final String datasetId;
  final PatternType patternType;
  final DateTime detectedAt;
  final DateTime createdAt;
  final double confidence;
  final int frequency;
  final String? description;

  bool get isStrong => confidence > 0.8;
  bool get isFrequent => frequency > 10;
  int get ageInDays => DateTime.now().difference(detectedAt).inDays;
}

/// CorrelationAnalysis: 相関分析
class CorrelationAnalysis {
  CorrelationAnalysis({
    required this.id,
    required this.variable1,
    required this.variable2,
    required this.correlationType,
    required this.coefficient,
    required this.analyzedAt,
    required this.createdAt,
    this.pValue = 0.0,
    this.sampleSize = 0,
  });

  final String id;
  final String variable1;
  final String variable2;
  final CorrelationType correlationType;
  final double coefficient;
  final DateTime analyzedAt;
  final DateTime createdAt;
  final double pValue;
  final int sampleSize;

  bool get isSignificant => pValue < 0.05;
  int get ageInDays => DateTime.now().difference(analyzedAt).inDays;
}

/// IntelligentAlert: インテリジェントアラート
class IntelligentAlert {
  IntelligentAlert({
    required this.id,
    required this.alertType,
    required this.severity,
    required this.triggeredAt,
    required this.createdAt,
    this.description,
    this.recommendation,
    this.isResolved = false,
    this.resolvedAt,
  });

  final String id;
  final String alertType;
  final AlertSeverity severity;
  final DateTime triggeredAt;
  final DateTime createdAt;
  final String? description;
  final String? recommendation;
  final bool isResolved;
  final DateTime? resolvedAt;

  bool get isCritical => severity == AlertSeverity.critical;
  int get resolutionTimeMinutes => resolvedAt != null
      ? resolvedAt!.difference(triggeredAt).inMinutes
      : -1;
  int get ageInMinutes => DateTime.now().difference(triggeredAt).inMinutes;
}

/// BehavioralAnalysis: 行動分析
class BehavioralAnalysis {
  BehavioralAnalysis({
    required this.id,
    required this.entityId,
    required this.analyzedAt,
    required this.createdAt,
    this.normalBehavior,
    this.deviationScore = 0.0,
    this.riskLevel = FraudRiskLevel.minimal,
    this.behaviors,
  });

  final String id;
  final String entityId;
  final DateTime analyzedAt;
  final DateTime createdAt;
  final String? normalBehavior;
  final double deviationScore;
  final FraudRiskLevel riskLevel;
  final List<String>? behaviors;

  bool get isAnomalous => deviationScore > 0.7;
  int get ageInDays => DateTime.now().difference(analyzedAt).inDays;
}

/// FraudDetection: 不正検出
class FraudDetection {
  FraudDetection({
    required this.id,
    required this.transactionId,
    required this.riskLevel,
    required this.detectedAt,
    required this.createdAt,
    this.fraudScore = 0.0,
    this.reasoning,
    this.isConfirmed = false,
  });

  final String id;
  final String transactionId;
  final FraudRiskLevel riskLevel;
  final DateTime detectedAt;
  final DateTime createdAt;
  final double fraudScore;
  final String? reasoning;
  final bool isConfirmed;

  bool get isSuspicious => fraudScore > 0.6;
  bool get isCritical => riskLevel == FraudRiskLevel.critical;
  int get ageInSeconds => DateTime.now().difference(detectedAt).inSeconds;
}

/// Recommendation: レコメンデーション
class Recommendation {
  Recommendation({
    required this.id,
    required this.targetId,
    required this.recommendationType,
    required this.confidence,
    required this.generatedAt,
    required this.createdAt,
    this.recommendedValue,
    this.reasoning,
    this.isAccepted = false,
  });

  final String id;
  final String targetId;
  final String recommendationType;
  final double confidence;
  final DateTime generatedAt;
  final DateTime createdAt;
  final dynamic? recommendedValue;
  final String? reasoning;
  final bool isAccepted;

  bool get isHighConfidence => confidence > 0.8;
  int get ageInHours => DateTime.now().difference(generatedAt).inHours;
}

/// InsightGeneration: インサイト生成
class InsightGeneration {
  InsightGeneration({
    required this.id,
    required this.datasetId,
    required this.insightType,
    required this.generatedAt,
    required this.createdAt,
    this.title,
    this.description,
    this.impact = 'medium',
    this.actionable = true,
  });

  final String id;
  final String datasetId;
  final String insightType;
  final DateTime generatedAt;
  final DateTime createdAt;
  final String? title;
  final String? description;
  final String impact;
  final bool actionable;

  bool get isHighImpact => impact == 'high';
  int get ageInDays => DateTime.now().difference(generatedAt).inDays;
}
