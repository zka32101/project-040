/// Advanced Analytics & Insights Models
///
/// Comprehensive data models for:
/// - Data aggregation and summarization
/// - Trend analysis and forecasting
/// - Anomaly detection
/// - Performance analytics
/// - User behavior analysis
/// - Custom insights generation

// ============================================================================
// ENUMS
// ============================================================================

/// Metric aggregation types
enum AggregationType {
  sum('sum'),
  average('average'),
  minimum('minimum'),
  maximum('maximum'),
  count('count'),
  stdDeviation('std_deviation'),
  percentile('percentile');

  final String value;
  const AggregationType(this.value);
}

/// Time period granularity
enum TimePeriod {
  minute('minute'),
  hour('hour'),
  day('day'),
  week('week'),
  month('month'),
  quarter('quarter'),
  year('year');

  final String value;
  const TimePeriod(this.value);
}

/// Trend direction
enum TrendDirection {
  upward('upward'),
  downward('downward'),
  stable('stable'),
  volatile('volatile');

  final String value;
  const TrendDirection(this.value);
}

/// Anomaly severity level
enum AnomalySeverity {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  final String value;
  const AnomalySeverity(this.value);
}

/// Report type classification
enum ReportType {
  summary('summary'),
  detailed('detailed'),
  executive('executive'),
  technical('technical'),
  custom('custom');

  final String value;
  const ReportType(this.value);
}

/// Insight category
enum InsightCategory {
  performance('performance'),
  behavior('behavior'),
  trend('trend'),
  anomaly('anomaly'),
  prediction('prediction'),
  recommendation('recommendation');

  final String value;
  const InsightCategory(this.value);
}

// ============================================================================
// MODELS
// ============================================================================

/// Represents a data point for analytics
class DataPoint {
  final String dataPointId;
  final String metricName;
  final double value;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final String? category;

  DataPoint({
    required this.dataPointId,
    required this.metricName,
    required this.value,
    required this.timestamp,
    this.metadata,
    this.category,
  });

  bool get isRecent => DateTime.now().difference(timestamp).inHours < 24;
  int get ageInHours => DateTime.now().difference(timestamp).inHours;
}

/// Represents aggregated metric data
class AggregatedMetric {
  final String metricId;
  final String metricName;
  final AggregationType aggregationType;
  final double aggregatedValue;
  final int dataPointCount;
  final DateTime periodStart;
  final DateTime periodEnd;
  final TimePeriod period;

  AggregatedMetric({
    required this.metricId,
    required this.metricName,
    required this.aggregationType,
    required this.aggregatedValue,
    required this.dataPointCount,
    required this.periodStart,
    required this.periodEnd,
    required this.period,
  });

  bool get isRecent => DateTime.now().difference(periodEnd).inDays < 7;
  int get periodLengthInDays => periodEnd.difference(periodStart).inDays;
  bool get hasSignificantData => dataPointCount > 100;
}

/// Represents a trend in data
class Trend {
  final String trendId;
  final String metricName;
  final TrendDirection direction;
  final double changePercentage;
  final double slope;
  final DateTime analysisDate;
  final int dataPointsAnalyzed;
  final double confidence;

  Trend({
    required this.trendId,
    required this.metricName,
    required this.direction,
    required this.changePercentage,
    required this.slope,
    required this.analysisDate,
    required this.dataPointsAnalyzed,
    required this.confidence,
  });

  bool get isSignificant => confidence > 0.85;
  bool get isHighConfidence => confidence > 0.95;
  bool get isIncreasing => direction == TrendDirection.upward;
  bool get isDecreasing => direction == TrendDirection.downward;
}

/// Represents an anomaly in data
class Anomaly {
  final String anomalyId;
  final String metricName;
  final double anomalyValue;
  final double expectedValue;
  final double deviationPercentage;
  final AnomalySeverity severity;
  final DateTime detectedAt;
  final String? description;
  final bool isResolved;

  Anomaly({
    required this.anomalyId,
    required this.metricName,
    required this.anomalyValue,
    required this.expectedValue,
    required this.deviationPercentage,
    required this.severity,
    required this.detectedAt,
    this.description,
    this.isResolved = false,
  });

  bool get isRecent => DateTime.now().difference(detectedAt).inHours < 24;
  bool get isCritical => severity == AnomalySeverity.critical;
  int get ageInHours => DateTime.now().difference(detectedAt).inHours;
}

/// Represents a forecast/prediction
class Forecast {
  final String forecastId;
  final String metricName;
  final double predictedValue;
  final double confidenceInterval;
  final DateTime forecastDate;
  final DateTime generatedAt;
  final String forecastingMethod;
  final int dataPointsUsed;

  Forecast({
    required this.forecastId,
    required this.metricName,
    required this.predictedValue,
    required this.confidenceInterval,
    required this.forecastDate,
    required this.generatedAt,
    required this.forecastingMethod,
    required this.dataPointsUsed,
  });

  bool get hasHighConfidence => confidenceInterval < 0.1;
  int get daysUntilForecast => forecastDate.difference(DateTime.now()).inDays;
  bool get isFuture => forecastDate.isAfter(DateTime.now());
}

/// Represents an insight from analysis
class Insight {
  final String insightId;
  final InsightCategory category;
  final String title;
  final String description;
  final double impact;
  final bool isActionable;
  final DateTime generatedAt;
  final String? recommendation;
  final Map<String, dynamic>? metadata;

  Insight({
    required this.insightId,
    required this.category,
    required this.title,
    required this.description,
    required this.impact,
    required this.isActionable,
    required this.generatedAt,
    this.recommendation,
    this.metadata,
  });

  bool get isHighImpact => impact > 0.75;
  bool get isRecent => DateTime.now().difference(generatedAt).inDays < 7;
  int get ageInDays => DateTime.now().difference(generatedAt).inDays;
}

/// Represents performance metrics
class PerformanceMetrics {
  final String metricsId;
  final double averageResponseTime;
  final double p95ResponseTime;
  final double p99ResponseTime;
  final double throughput;
  final double errorRate;
  final double availabilityPercentage;
  final DateTime measurementStart;
  final DateTime measurementEnd;

  PerformanceMetrics({
    required this.metricsId,
    required this.averageResponseTime,
    required this.p95ResponseTime,
    required this.p99ResponseTime,
    required this.throughput,
    required this.errorRate,
    required this.availabilityPercentage,
    required this.measurementStart,
    required this.measurementEnd,
  });

  bool get isHealthy => errorRate < 0.01 && availabilityPercentage > 99.5;
  bool get hasAcceptablePerformance => averageResponseTime < 500;
  bool get hasHighThroughput => throughput > 1000;
  int get measurementDurationInHours => measurementEnd.difference(measurementStart).inHours;
}

/// Represents user behavior analysis
class UserBehaviorAnalysis {
  final String analysisId;
  final int totalUsers;
  final int activeUsers;
  final double engagementRate;
  final double conversionRate;
  final double churnRate;
  final double averageSessionDuration;
  final int totalSessions;
  final DateTime analysisDate;

  UserBehaviorAnalysis({
    required this.analysisId,
    required this.totalUsers,
    required this.activeUsers,
    required this.engagementRate,
    required this.conversionRate,
    required this.churnRate,
    required this.averageSessionDuration,
    required this.totalSessions,
    required this.analysisDate,
  });

  bool get hasHighEngagement => engagementRate > 0.6;
  bool get hasAcceptableChurn => churnRate < 0.05;
  double get activeUserPercentage => (activeUsers / totalUsers) * 100;
  bool get isRecent => DateTime.now().difference(analysisDate).inDays < 7;
}

/// Represents a custom analysis result
class CustomAnalysis {
  final String analysisId;
  final String analysisName;
  final String description;
  final Map<String, dynamic> results;
  final DateTime createdAt;
  final DateTime completedAt;
  final String status;

  CustomAnalysis({
    required this.analysisId,
    required this.analysisName,
    required this.description,
    required this.results,
    required this.createdAt,
    required this.completedAt,
    required this.status,
  });

  bool get isCompleted => status == 'completed';
  int get durationInSeconds => completedAt.difference(createdAt).inSeconds;
  bool get isRecent => DateTime.now().difference(completedAt).inDays < 7;
}

/// Represents analytics report
class AnalyticsReport {
  final String reportId;
  final ReportType reportType;
  final String title;
  final DateTime generatedAt;
  final List<AggregatedMetric> metrics;
  final List<Trend> trends;
  final List<Anomaly> anomalies;
  final List<Insight> insights;
  final Map<String, dynamic>? customData;

  AnalyticsReport({
    required this.reportId,
    required this.reportType,
    required this.title,
    required this.generatedAt,
    required this.metrics,
    required this.trends,
    required this.anomalies,
    required this.insights,
    this.customData,
  });

  bool get hasAnomalies => anomalies.isNotEmpty;
  bool get hasCriticalAnomalies => anomalies.any((a) => a.isCritical);
  int get totalInsights => insights.length;
  bool get hasActionableInsights => insights.any((i) => i.isActionable);

  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# $title');
    buffer.writeln('Generated: ${generatedAt.toIso8601String()}\n');

    buffer.writeln('## Summary');
    buffer.writeln('- Metrics: ${metrics.length}');
    buffer.writeln('- Trends: ${trends.length}');
    buffer.writeln('- Anomalies: ${anomalies.length}');
    buffer.writeln('- Insights: ${insights.length}\n');

    if (anomalies.isNotEmpty) {
      buffer.writeln('## Anomalies');
      for (final anomaly in anomalies) {
        buffer.writeln('- ${anomaly.metricName}: ${anomaly.deviationPercentage.toStringAsFixed(2)}% deviation');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }
}

/// Represents dashboard data
class DashboardData {
  final String dashboardId;
  final String dashboardName;
  final DateTime lastUpdated;
  final List<AggregatedMetric> keyMetrics;
  final List<Trend> recentTrends;
  final List<Insight> topInsights;
  final PerformanceMetrics? performanceMetrics;

  DashboardData({
    required this.dashboardId,
    required this.dashboardName,
    required this.lastUpdated,
    required this.keyMetrics,
    required this.recentTrends,
    required this.topInsights,
    this.performanceMetrics,
  });

  bool get isStale => DateTime.now().difference(lastUpdated).inMinutes > 60;
  bool get isRecent => DateTime.now().difference(lastUpdated).inMinutes < 5;
  int get minutesSinceUpdate => DateTime.now().difference(lastUpdated).inMinutes;
}

/// Represents analytics configuration
class AnalyticsConfig {
  final String configId;
  final bool isEnabled;
  final List<String> trackedMetrics;
  final TimePeriod defaultPeriod;
  final int retentionDays;
  final double anomalyThreshold;
  final DateTime createdAt;

  AnalyticsConfig({
    required this.configId,
    required this.isEnabled,
    required this.trackedMetrics,
    required this.defaultPeriod,
    required this.retentionDays,
    required this.anomalyThreshold,
    required this.createdAt,
  });

  bool get isConfigured => trackedMetrics.isNotEmpty && anomalyThreshold > 0;
  int get metricCount => trackedMetrics.length;
  bool get isRecent => DateTime.now().difference(createdAt).inDays < 30;
}
