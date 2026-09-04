/// Phase 47: Advanced Analytics & ML Integration 分析・機械学習モデル定義
///
/// 分析データ、予測、異常検知、レコメンデーション

/// 分析メトリクスタイプ
enum AnalyticsMetricType {
  performance('performance'),
  reliability('reliability'),
  efficiency('efficiency'),
  utilization('utilization'),
  cost('cost');

  final String value;
  const AnalyticsMetricType(this.value);
}

/// 予測モデルタイプ
enum PredictionModelType {
  linearRegression('linear_regression'),
  timeSeriesForecasting('time_series_forecasting'),
  anomalyDetection('anomaly_detection'),
  clustering('clustering'),
  classification('classification');

  final String value;
  const PredictionModelType(this.value);
}

/// 異常レベル
enum AnomalyLevel {
  low(1),
  medium(2),
  high(3),
  critical(4);

  final int value;
  const AnomalyLevel(this.value);
}

/// 信頼度レベル
enum ConfidenceLevel {
  low('low'),
  medium('medium'),
  high('high'),
  veryHigh('very_high');

  final String value;
  const ConfidenceLevel(this.value);
}

/// 分析メトリクス
class AnalyticsMetric {
  final String metricId;
  final String name;
  final AnalyticsMetricType type;
  final double currentValue;
  final double? previousValue;
  final double? targetValue;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final String? unit;

  AnalyticsMetric({
    required this.metricId,
    required this.name,
    required this.type,
    required this.currentValue,
    this.previousValue,
    this.targetValue,
    required this.timestamp,
    this.metadata,
    this.unit,
  });

  /// 目標達成度（%）
  double? get targetAchievement {
    if (targetValue == null) return null;
    return (currentValue / targetValue!) * 100;
  }

  /// 前回比変化率（%）
  double? get changePercentage {
    if (previousValue == null || previousValue == 0) return null;
    return ((currentValue - previousValue!) / previousValue!) * 100;
  }

  /// 目標達成したか
  bool get isOnTarget {
    if (targetValue == null) return false;
    return currentValue >= targetValue!;
  }
}

/// 時系列データポイント
class TimeSeriesDataPoint {
  final DateTime timestamp;
  final double value;
  final Map<String, dynamic>? tags;
  final double? confidence;

  TimeSeriesDataPoint({
    required this.timestamp,
    required this.value,
    this.tags,
    this.confidence,
  });
}

/// 時系列分析
class TimeSeriesAnalysis {
  final String analysisId;
  final String metricId;
  final List<TimeSeriesDataPoint> dataPoints;
  final double trend; // -1.0 ~ 1.0
  final double seasonality; // 0.0 ~ 1.0
  final double volatility; // 0.0 ~ 1.0
  final DateTime analyzedAt;

  TimeSeriesAnalysis({
    required this.analysisId,
    required this.metricId,
    required this.dataPoints,
    required this.trend,
    required this.seasonality,
    required this.volatility,
    required this.analyzedAt,
  });

  /// トレンド方向
  String get trendDirection {
    if (trend > 0.2) return 'Increasing';
    if (trend < -0.2) return 'Decreasing';
    return 'Stable';
  }

  /// 季節性が強いか
  bool get hasStrongSeasonality => seasonality > 0.5;

  /// ボラティリティが高いか
  bool get isHighVolatility => volatility > 0.5;
}

/// 予測結果
class PredictionResult {
  final String predictionId;
  final String metricId;
  final PredictionModelType modelType;
  final double predictedValue;
  final double confidence; // 0.0-1.0
  final DateTime predictionTime;
  final DateTime targetTime;
  final Map<String, dynamic>? metadata;

  PredictionResult({
    required this.predictionId,
    required this.metricId,
    required this.modelType,
    required this.predictedValue,
    required this.confidence,
    required this.predictionTime,
    required this.targetTime,
    this.metadata,
  });

  /// 信頼度レベル
  ConfidenceLevel get confidenceLevel {
    if (confidence >= 0.9) return ConfidenceLevel.veryHigh;
    if (confidence >= 0.7) return ConfidenceLevel.high;
    if (confidence >= 0.5) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }

  /// 信頼できる予測か
  bool get isReliable => confidence >= 0.7;
}

/// 異常検知結果
class AnomalyDetectionResult {
  final String anomalyId;
  final String metricId;
  final double value;
  final double expectedValue;
  final double deviation; // (value - expectedValue) / expectedValue
  final AnomalyLevel level;
  final double confidence; // 0.0-1.0
  final DateTime detectedAt;
  final String? description;

  AnomalyDetectionResult({
    required this.anomalyId,
    required this.metricId,
    required this.value,
    required this.expectedValue,
    required this.deviation,
    required this.level,
    required this.confidence,
    required this.detectedAt,
    this.description,
  });

  /// 逸脱度（%）
  double get deviationPercentage => deviation * 100;

  /// 重大な異常か
  bool get isCritical => level == AnomalyLevel.critical;
}

/// クラスタリング結果
class ClusteringResult {
  final String clusteringId;
  final int numberOfClusters;
  final List<Map<String, dynamic>> clusters;
  final Map<String, int> pointAssignments; // pointId -> clusterId
  final double silhouetteScore; // -1.0 ~ 1.0
  final DateTime analyzedAt;

  ClusteringResult({
    required this.clusteringId,
    required this.numberOfClusters,
    required this.clusters,
    required this.pointAssignments,
    required this.silhouetteScore,
    required this.analyzedAt,
  });

  /// クラスタリングの質
  String get quality {
    if (silhouetteScore > 0.5) return 'Excellent';
    if (silhouetteScore > 0.25) return 'Good';
    if (silhouetteScore > 0) return 'Fair';
    return 'Poor';
  }
}

/// レコメンデーション
class Recommendation {
  final String recommendationId;
  final String entityId;
  final String title;
  final String description;
  final double score; // 0.0-1.0
  final ConfidenceLevel confidence;
  final List<String>? actions;
  final int priority; // 1-5
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;

  Recommendation({
    required this.recommendationId,
    required this.entityId,
    required this.title,
    required this.description,
    required this.score,
    required this.confidence,
    this.actions,
    this.priority = 3,
    required this.createdAt,
    this.expiresAt,
    this.metadata,
  });

  /// 推奨が有効か
  bool get isValid {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// 推奨の重要度
  String get importance {
    if (priority >= 4) return 'Critical';
    if (priority == 3) return 'High';
    if (priority == 2) return 'Medium';
    return 'Low';
  }
}

/// 分析レポート
class AnalyticsReport {
  final String reportId;
  final DateTime generatedAt;
  final List<AnalyticsMetric> metrics;
  final List<PredictionResult> predictions;
  final List<AnomalyDetectionResult> anomalies;
  final List<Recommendation> recommendations;
  final Map<String, dynamic>? insights;

  AnalyticsReport({
    required this.reportId,
    required this.generatedAt,
    required this.metrics,
    required this.predictions,
    required this.anomalies,
    required this.recommendations,
    this.insights,
  });

  /// 異常数
  int get anomalyCount => anomalies.length;

  /// 重大異常数
  int get criticalAnomalyCount => anomalies.where((a) => a.isCritical).length;

  /// 推奨数
  int get recommendationCount => recommendations.where((r) => r.isValid).length;

  /// Markdown形式でレポートを生成
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Advanced Analytics Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');

    buffer.writeln('## Summary');
    buffer.writeln('- Metrics: ${metrics.length}');
    buffer.writeln('- Predictions: ${predictions.length}');
    buffer.writeln('- Anomalies: ${anomalyCount}');
    buffer.writeln('- Critical Anomalies: ${criticalAnomalyCount}');
    buffer.writeln('- Recommendations: ${recommendationCount}');
    buffer.writeln('');

    if (anomalies.isNotEmpty) {
      buffer.writeln('## Anomalies Detected');
      buffer.writeln('');
      for (final anomaly in anomalies.take(5)) {
        buffer.writeln('- **${anomaly.metricId}**: ${anomaly.description}');
        buffer.writeln('  - Level: ${anomaly.level.name}');
        buffer.writeln('  - Deviation: ${anomaly.deviationPercentage.toStringAsFixed(1)}%');
      }
      buffer.writeln('');
    }

    if (recommendations.isNotEmpty) {
      buffer.writeln('## Top Recommendations');
      buffer.writeln('');
      for (final rec in recommendations.take(5)) {
        buffer.writeln('- **${rec.title}** (Priority: ${rec.importance})');
        buffer.writeln('  - ${rec.description}');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}

/// ML モデルメタデータ
class MLModelMetadata {
  final String modelId;
  final String name;
  final PredictionModelType type;
  final String version;
  final double accuracy; // 0.0-1.0
  final int trainingDataSize;
  final DateTime trainedAt;
  final DateTime? updatedAt;
  final bool isActive;
  final Map<String, dynamic>? hyperparameters;

  MLModelMetadata({
    required this.modelId,
    required this.name,
    required this.type,
    required this.version,
    required this.accuracy,
    required this.trainingDataSize,
    required this.trainedAt,
    this.updatedAt,
    this.isActive = true,
    this.hyperparameters,
  });

  /// モデルの信頼度
  ConfidenceLevel get confidenceLevel {
    if (accuracy >= 0.9) return ConfidenceLevel.veryHigh;
    if (accuracy >= 0.7) return ConfidenceLevel.high;
    if (accuracy >= 0.5) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }

  /// モデルが古いか（7日以上）
  bool get isStale {
    final lastUpdateTime = updatedAt ?? trainedAt;
    return DateTime.now().difference(lastUpdateTime).inDays > 7;
  }
}
