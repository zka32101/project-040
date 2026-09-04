/// Performance Analytics & Insights Models

enum MetricType { latency, throughput, errorRate, cpuUsage, memoryUsage, diskUsage, networkUsage }
enum AnomalyType { spike, drop, trend, outlier, pattern, cyclic }
enum InsightCategory { performance, reliability, efficiency, security, cost }
enum TrendDirection { upward, downward, stable, cyclic }
enum AlertPriority { low, medium, high, critical }
enum ReportFrequency { hourly, daily, weekly, monthly, quarterly, yearly }

class PerformanceMetric {
  final String metricId;
  final String resourceId;
  final String metricName;
  final MetricType metricType;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final Map<String, dynamic> tags;
  final double? threshold;

  PerformanceMetric({
    required this.metricId,
    required this.resourceId,
    required this.metricName,
    required this.metricType,
    required this.value,
    required this.unit,
    required this.recordedAt,
    this.tags = const {},
    this.threshold,
  });

  bool get isAnomalous => threshold != null && value > threshold!;
  bool get isCritical => isAnomalous;
  int get ageInSeconds => DateTime.now().difference(recordedAt).inSeconds;
  bool get isRecent => ageInSeconds < 300;
}

class PerformanceTimeSeries {
  final String seriesId;
  final String resourceId;
  final MetricType metricType;
  final List<PerformanceMetric> dataPoints;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;
  final int intervalSeconds;

  PerformanceTimeSeries({
    required this.seriesId,
    required this.resourceId,
    required this.metricType,
    required this.dataPoints,
    required this.createdAt,
    this.lastUpdatedAt,
    required this.intervalSeconds,
  });

  bool get hasData => dataPoints.isNotEmpty;
  double get average => hasData ? dataPoints.map((p) => p.value).reduce((a, b) => a + b) / dataPoints.length : 0.0;
  double get maxValue => hasData ? dataPoints.map((p) => p.value).reduce((a, b) => a > b ? a : b) : 0.0;
  double get minValue => hasData ? dataPoints.map((p) => p.value).reduce((a, b) => a < b ? a : b) : 0.0;
  int get dataPointCount => dataPoints.length;
}

class PerformanceAnomaly {
  final String anomalyId;
  final String resourceId;
  final String seriesId;
  final AnomalyType anomalyType;
  final double severity;
  final DateTime detectedAt;
  final String? description;
  final Map<String, dynamic> context;
  final bool isResolved;

  PerformanceAnomaly({
    required this.anomalyId,
    required this.resourceId,
    required this.seriesId,
    required this.anomalyType,
    required this.severity,
    required this.detectedAt,
    this.description,
    required this.context,
    this.isResolved = false,
  });

  bool get isCritical => severity > 0.8;
  bool get isPending => !isResolved;
  int get ageInHours => DateTime.now().difference(detectedAt).inHours;
  bool get isRecent => ageInHours < 24;
}

class PerformanceInsight {
  final String insightId;
  final String resourceId;
  final InsightCategory category;
  final String title;
  final String description;
  final double confidenceScore;
  final DateTime discoveredAt;
  final DateTime? actionTakenAt;
  final String? recommendation;

  PerformanceInsight({
    required this.insightId,
    required this.resourceId,
    required this.category,
    required this.title,
    required this.description,
    required this.confidenceScore,
    required this.discoveredAt,
    this.actionTakenAt,
    this.recommendation,
  });

  bool get isHighConfidence => confidenceScore > 0.9;
  bool get isActionable => recommendation != null;
  bool get hasAction => actionTakenAt != null;
  int get ageInDays => DateTime.now().difference(discoveredAt).inDays;
}

class PerformanceTrend {
  final String trendId;
  final String resourceId;
  final MetricType metricType;
  final TrendDirection direction;
  final double slope;
  final DateTime startDate;
  final DateTime endDate;
  final int dataPoints;
  final double rSquared;

  PerformanceTrend({
    required this.trendId,
    required this.resourceId,
    required this.metricType,
    required this.direction,
    required this.slope,
    required this.startDate,
    required this.endDate,
    required this.dataPoints,
    required this.rSquared,
  });

  bool get isSignificant => rSquared > 0.7;
  bool get isGrowing => direction == TrendDirection.upward;
  bool get isDecreasing => direction == TrendDirection.downward;
  int get durationInDays => endDate.difference(startDate).inDays;
}

class PerformanceAlert {
  final String alertId;
  final String resourceId;
  final String metricName;
  final AlertPriority priority;
  final double thresholdValue;
  final double actualValue;
  final DateTime triggeredAt;
  final DateTime? resolvedAt;
  final String? message;

  PerformanceAlert({
    required this.alertId,
    required this.resourceId,
    required this.metricName,
    required this.priority,
    required this.thresholdValue,
    required this.actualValue,
    required this.triggeredAt,
    this.resolvedAt,
    this.message,
  });

  bool get isResolved => resolvedAt != null;
  bool get isPending => !isResolved;
  bool get isCritical => priority == AlertPriority.critical;
  int get ageInMinutes => DateTime.now().difference(triggeredAt).inMinutes;
}

class PerformanceReport {
  final String reportId;
  final String resourceId;
  final ReportFrequency frequency;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<String, double> metrics;
  final int anomalyCount;
  final int insightCount;
  final double averageHealthScore;

  PerformanceReport({
    required this.reportId,
    required this.resourceId,
    required this.frequency,
    required this.periodStart,
    required this.periodEnd,
    required this.metrics,
    required this.anomalyCount,
    required this.insightCount,
    required this.averageHealthScore,
  });

  bool get isHealthy => averageHealthScore > 90.0;
  bool get hasAnomalies => anomalyCount > 0;
  bool get hasInsights => insightCount > 0;
  int get durationInDays => periodEnd.difference(periodStart).inDays;
}

class PerformanceBaseline {
  final String baselineId;
  final String resourceId;
  final MetricType metricType;
  final double normalMin;
  final double normalMax;
  final double mean;
  final double standardDeviation;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;

  PerformanceBaseline({
    required this.baselineId,
    required this.resourceId,
    required this.metricType,
    required this.normalMin,
    required this.normalMax,
    required this.mean,
    required this.standardDeviation,
    required this.createdAt,
    this.lastUpdatedAt,
  });

  bool get isRecent => lastUpdatedAt != null && DateTime.now().difference(lastUpdatedAt!).inDays < 7;
  double get rangeWidth => normalMax - normalMin;
  int get ageInDays => lastUpdatedAt != null ? DateTime.now().difference(lastUpdatedAt!).inDays : DateTime.now().difference(createdAt).inDays;
}

class PerformanceComparison {
  final String comparisonId;
  final String resourceId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime previousPeriodStart;
  final DateTime previousPeriodEnd;
  final Map<String, double> currentMetrics;
  final Map<String, double> previousMetrics;
  final Map<String, double> percentageChange;

  PerformanceComparison({
    required this.comparisonId,
    required this.resourceId,
    required this.periodStart,
    required this.periodEnd,
    required this.previousPeriodStart,
    required this.previousPeriodEnd,
    required this.currentMetrics,
    required this.previousMetrics,
    required this.percentageChange,
  });

  bool get hasImprovement => percentageChange.values.any((v) => v < 0);
  bool get hasRegression => percentageChange.values.any((v) => v > 10);
  int get currentDurationInDays => periodEnd.difference(periodStart).inDays;
  int get previousDurationInDays => previousPeriodEnd.difference(previousPeriodStart).inDays;
}

class AnalyticsConfiguration {
  final String configId;
  final String resourceId;
  final List<MetricType> trackedMetrics;
  final int metricsRetentionDays;
  final int anomalyDetectionSensitivity;
  final int trendAnalysisWindow;
  final bool isEnabled;
  final DateTime createdAt;

  AnalyticsConfiguration({
    required this.configId,
    required this.resourceId,
    required this.trackedMetrics,
    required this.metricsRetentionDays,
    required this.anomalyDetectionSensitivity,
    required this.trendAnalysisWindow,
    required this.isEnabled,
    required this.createdAt,
  });

  bool get hasMetrics => trackedMetrics.isNotEmpty;
  int get metricCount => trackedMetrics.length;
  bool get isLongRetention => metricsRetentionDays >= 365;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class PerformanceCorrelation {
  final String correlationId;
  final String resourceId;
  final String metricA;
  final String metricB;
  final double correlationCoefficient;
  final int sampleCount;
  final DateTime calculatedAt;
  final String? interpretation;

  PerformanceCorrelation({
    required this.correlationId,
    required this.resourceId,
    required this.metricA,
    required this.metricB,
    required this.correlationCoefficient,
    required this.sampleCount,
    required this.calculatedAt,
    this.interpretation,
  });

  bool get hasStrongCorrelation => correlationCoefficient.abs() > 0.7;
  bool get isPositive => correlationCoefficient > 0;
  bool get isNegative => correlationCoefficient < 0;
  int get ageInDays => DateTime.now().difference(calculatedAt).inDays;
}
