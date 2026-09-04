import '../models/analytics_models.dart';

abstract class AnalyticsRepository {
  Future<void> recordMetric(PerformanceMetric metric);
  Future<PerformanceMetric?> getMetric(String metricId);
  Future<List<PerformanceMetric>> getResourceMetrics(String resourceId);
  Future<List<PerformanceMetric>> getMetricsByType(MetricType metricType);

  Future<void> createTimeSeries(PerformanceTimeSeries series);
  Future<PerformanceTimeSeries?> getTimeSeries(String seriesId);
  Future<List<PerformanceTimeSeries>> getResourceTimeSeries(String resourceId);

  Future<void> recordAnomaly(PerformanceAnomaly anomaly);
  Future<PerformanceAnomaly?> getAnomaly(String anomalyId);
  Future<List<PerformanceAnomaly>> getResourceAnomalies(String resourceId);
  Future<List<PerformanceAnomaly>> getUnresolvedAnomalies();

  Future<void> createInsight(PerformanceInsight insight);
  Future<PerformanceInsight?> getInsight(String insightId);
  Future<List<PerformanceInsight>> getResourceInsights(String resourceId);
  Future<List<PerformanceInsight>> getInsightsByCategory(InsightCategory category);

  Future<void> recordTrend(PerformanceTrend trend);
  Future<PerformanceTrend?> getTrend(String trendId);
  Future<List<PerformanceTrend>> getResourceTrends(String resourceId);

  Future<void> createAlert(PerformanceAlert alert);
  Future<PerformanceAlert?> getAlert(String alertId);
  Future<List<PerformanceAlert>> getResourceAlerts(String resourceId);
  Future<List<PerformanceAlert>> getPendingAlerts();

  Future<void> saveReport(PerformanceReport report);
  Future<PerformanceReport?> getReport(String reportId);
  Future<List<PerformanceReport>> getResourceReports(String resourceId);

  Future<void> createBaseline(PerformanceBaseline baseline);
  Future<PerformanceBaseline?> getBaseline(String baselineId);
  Future<List<PerformanceBaseline>> getResourceBaselines(String resourceId);

  Future<void> saveComparison(PerformanceComparison comparison);
  Future<PerformanceComparison?> getComparison(String comparisonId);
  Future<List<PerformanceComparison>> getResourceComparisons(String resourceId);

  Future<void> saveConfiguration(AnalyticsConfiguration config);
  Future<AnalyticsConfiguration?> getConfiguration(String configId);
  Future<AnalyticsConfiguration?> getResourceConfiguration(String resourceId);

  Future<void> recordCorrelation(PerformanceCorrelation correlation);
  Future<PerformanceCorrelation?> getCorrelation(String correlationId);
  Future<List<PerformanceCorrelation>> getResourceCorrelations(String resourceId);
}

class MemoryAnalyticsRepository implements AnalyticsRepository {
  final Map<String, PerformanceMetric> _metrics = {};
  final Map<String, PerformanceTimeSeries> _timeSeries = {};
  final Map<String, PerformanceAnomaly> _anomalies = {};
  final Map<String, PerformanceInsight> _insights = {};
  final Map<String, PerformanceTrend> _trends = {};
  final Map<String, PerformanceAlert> _alerts = {};
  final Map<String, PerformanceReport> _reports = {};
  final Map<String, PerformanceBaseline> _baselines = {};
  final Map<String, PerformanceComparison> _comparisons = {};
  final Map<String, AnalyticsConfiguration> _configurations = {};
  final Map<String, PerformanceCorrelation> _correlations = {};

  @override
  Future<void> recordMetric(PerformanceMetric metric) async => _metrics[metric.metricId] = metric;

  @override
  Future<PerformanceMetric?> getMetric(String metricId) async => _metrics[metricId];

  @override
  Future<List<PerformanceMetric>> getResourceMetrics(String resourceId) async =>
      _metrics.values.where((m) => m.resourceId == resourceId).toList();

  @override
  Future<List<PerformanceMetric>> getMetricsByType(MetricType metricType) async =>
      _metrics.values.where((m) => m.metricType == metricType).toList();

  @override
  Future<void> createTimeSeries(PerformanceTimeSeries series) async => _timeSeries[series.seriesId] = series;

  @override
  Future<PerformanceTimeSeries?> getTimeSeries(String seriesId) async => _timeSeries[seriesId];

  @override
  Future<List<PerformanceTimeSeries>> getResourceTimeSeries(String resourceId) async =>
      _timeSeries.values.where((s) => s.resourceId == resourceId).toList();

  @override
  Future<void> recordAnomaly(PerformanceAnomaly anomaly) async => _anomalies[anomaly.anomalyId] = anomaly;

  @override
  Future<PerformanceAnomaly?> getAnomaly(String anomalyId) async => _anomalies[anomalyId];

  @override
  Future<List<PerformanceAnomaly>> getResourceAnomalies(String resourceId) async =>
      _anomalies.values.where((a) => a.resourceId == resourceId).toList();

  @override
  Future<List<PerformanceAnomaly>> getUnresolvedAnomalies() async =>
      _anomalies.values.where((a) => !a.isResolved).toList();

  @override
  Future<void> createInsight(PerformanceInsight insight) async => _insights[insight.insightId] = insight;

  @override
  Future<PerformanceInsight?> getInsight(String insightId) async => _insights[insightId];

  @override
  Future<List<PerformanceInsight>> getResourceInsights(String resourceId) async =>
      _insights.values.where((i) => i.resourceId == resourceId).toList();

  @override
  Future<List<PerformanceInsight>> getInsightsByCategory(InsightCategory category) async =>
      _insights.values.where((i) => i.category == category).toList();

  @override
  Future<void> recordTrend(PerformanceTrend trend) async => _trends[trend.trendId] = trend;

  @override
  Future<PerformanceTrend?> getTrend(String trendId) async => _trends[trendId];

  @override
  Future<List<PerformanceTrend>> getResourceTrends(String resourceId) async =>
      _trends.values.where((t) => t.resourceId == resourceId).toList();

  @override
  Future<void> createAlert(PerformanceAlert alert) async => _alerts[alert.alertId] = alert;

  @override
  Future<PerformanceAlert?> getAlert(String alertId) async => _alerts[alertId];

  @override
  Future<List<PerformanceAlert>> getResourceAlerts(String resourceId) async =>
      _alerts.values.where((a) => a.resourceId == resourceId).toList();

  @override
  Future<List<PerformanceAlert>> getPendingAlerts() async =>
      _alerts.values.where((a) => a.isPending).toList();

  @override
  Future<void> saveReport(PerformanceReport report) async => _reports[report.reportId] = report;

  @override
  Future<PerformanceReport?> getReport(String reportId) async => _reports[reportId];

  @override
  Future<List<PerformanceReport>> getResourceReports(String resourceId) async =>
      _reports.values.where((r) => r.resourceId == resourceId).toList();

  @override
  Future<void> createBaseline(PerformanceBaseline baseline) async => _baselines[baseline.baselineId] = baseline;

  @override
  Future<PerformanceBaseline?> getBaseline(String baselineId) async => _baselines[baselineId];

  @override
  Future<List<PerformanceBaseline>> getResourceBaselines(String resourceId) async =>
      _baselines.values.where((b) => b.resourceId == resourceId).toList();

  @override
  Future<void> saveComparison(PerformanceComparison comparison) async => _comparisons[comparison.comparisonId] = comparison;

  @override
  Future<PerformanceComparison?> getComparison(String comparisonId) async => _comparisons[comparisonId];

  @override
  Future<List<PerformanceComparison>> getResourceComparisons(String resourceId) async =>
      _comparisons.values.where((c) => c.resourceId == resourceId).toList();

  @override
  Future<void> saveConfiguration(AnalyticsConfiguration config) async => _configurations[config.configId] = config;

  @override
  Future<AnalyticsConfiguration?> getConfiguration(String configId) async => _configurations[configId];

  @override
  Future<AnalyticsConfiguration?> getResourceConfiguration(String resourceId) async =>
      _configurations.values.cast<AnalyticsConfiguration?>().firstWhere(
        (c) => c?.resourceId == resourceId,
        orElse: () => null,
      );

  @override
  Future<void> recordCorrelation(PerformanceCorrelation correlation) async =>
      _correlations[correlation.correlationId] = correlation;

  @override
  Future<PerformanceCorrelation?> getCorrelation(String correlationId) async => _correlations[correlationId];

  @override
  Future<List<PerformanceCorrelation>> getResourceCorrelations(String resourceId) async =>
      _correlations.values.where((c) => c.resourceId == resourceId).toList();
}

class MetricsCollectionEngine {
  final AnalyticsRepository repository;

  MetricsCollectionEngine({required this.repository});

  Future<PerformanceMetric> recordMetric(
    String resourceId,
    String metricName,
    MetricType metricType,
    double value,
    String unit,
    {double? threshold, Map<String, dynamic>? tags}
  ) async {
    final metric = PerformanceMetric(
      metricId: 'metric_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      metricName: metricName,
      metricType: metricType,
      value: value,
      unit: unit,
      recordedAt: DateTime.now(),
      tags: tags ?? {},
      threshold: threshold,
    );
    await repository.recordMetric(metric);
    return metric;
  }

  Future<PerformanceTimeSeries> createTimeSeries(
    String resourceId,
    MetricType metricType,
    int intervalSeconds,
  ) async {
    final series = PerformanceTimeSeries(
      seriesId: 'series_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      metricType: metricType,
      dataPoints: [],
      createdAt: DateTime.now(),
      intervalSeconds: intervalSeconds,
    );
    await repository.createTimeSeries(series);
    return series;
  }
}

class AnomalyDetectionEngine {
  final AnalyticsRepository repository;

  AnomalyDetectionEngine({required this.repository});

  Future<PerformanceAnomaly?> detectAnomaly(
    String resourceId,
    String seriesId,
    AnomalyType anomalyType,
    double severity,
    {String? description, Map<String, dynamic>? context}
  ) async {
    if (severity <= 0 || severity > 1) return null;

    final anomaly = PerformanceAnomaly(
      anomalyId: 'anomaly_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      seriesId: seriesId,
      anomalyType: anomalyType,
      severity: severity,
      detectedAt: DateTime.now(),
      description: description,
      context: context ?? {},
    );
    await repository.recordAnomaly(anomaly);
    return anomaly;
  }

  Future<void> resolveAnomaly(String anomalyId) async {
    final anomaly = await repository.getAnomaly(anomalyId);
    if (anomaly != null) {
      final resolved = PerformanceAnomaly(
        anomalyId: anomaly.anomalyId,
        resourceId: anomaly.resourceId,
        seriesId: anomaly.seriesId,
        anomalyType: anomaly.anomalyType,
        severity: anomaly.severity,
        detectedAt: anomaly.detectedAt,
        description: anomaly.description,
        context: anomaly.context,
        isResolved: true,
      );
      await repository.recordAnomaly(resolved);
    }
  }
}

class InsightGenerationEngine {
  final AnalyticsRepository repository;

  InsightGenerationEngine({required this.repository});

  Future<PerformanceInsight> generateInsight(
    String resourceId,
    InsightCategory category,
    String title,
    String description,
    double confidenceScore,
    {String? recommendation}
  ) async {
    final insight = PerformanceInsight(
      insightId: 'insight_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      category: category,
      title: title,
      description: description,
      confidenceScore: confidenceScore,
      discoveredAt: DateTime.now(),
      recommendation: recommendation,
    );
    await repository.createInsight(insight);
    return insight;
  }

  Future<void> recordAction(String insightId) async {
    final insight = await repository.getInsight(insightId);
    if (insight != null) {
      final updated = PerformanceInsight(
        insightId: insight.insightId,
        resourceId: insight.resourceId,
        category: insight.category,
        title: insight.title,
        description: insight.description,
        confidenceScore: insight.confidenceScore,
        discoveredAt: insight.discoveredAt,
        actionTakenAt: DateTime.now(),
        recommendation: insight.recommendation,
      );
      await repository.createInsight(updated);
    }
  }
}

class TrendAnalysisEngine {
  final AnalyticsRepository repository;

  TrendAnalysisEngine({required this.repository});

  Future<PerformanceTrend> analyzeTrend(
    String resourceId,
    MetricType metricType,
    TrendDirection direction,
    double slope,
    int dataPoints,
    double rSquared,
  ) async {
    final now = DateTime.now();
    final trend = PerformanceTrend(
      trendId: 'trend_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      metricType: metricType,
      direction: direction,
      slope: slope,
      startDate: now.subtract(Duration(days: 30)),
      endDate: now,
      dataPoints: dataPoints,
      rSquared: rSquared,
    );
    await repository.recordTrend(trend);
    return trend;
  }
}

class AlertManagementEngine {
  final AnalyticsRepository repository;

  AlertManagementEngine({required this.repository});

  Future<PerformanceAlert> createAlert(
    String resourceId,
    String metricName,
    AlertPriority priority,
    double thresholdValue,
    double actualValue,
    {String? message}
  ) async {
    final alert = PerformanceAlert(
      alertId: 'alert_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      metricName: metricName,
      priority: priority,
      thresholdValue: thresholdValue,
      actualValue: actualValue,
      triggeredAt: DateTime.now(),
      message: message,
    );
    await repository.createAlert(alert);
    return alert;
  }

  Future<void> resolveAlert(String alertId) async {
    final alert = await repository.getAlert(alertId);
    if (alert != null) {
      final resolved = PerformanceAlert(
        alertId: alert.alertId,
        resourceId: alert.resourceId,
        metricName: alert.metricName,
        priority: alert.priority,
        thresholdValue: alert.thresholdValue,
        actualValue: alert.actualValue,
        triggeredAt: alert.triggeredAt,
        resolvedAt: DateTime.now(),
        message: alert.message,
      );
      await repository.createAlert(resolved);
    }
  }
}

class AnalyticsManager {
  final AnalyticsRepository repository;
  final MetricsCollectionEngine metricsEngine;
  final AnomalyDetectionEngine anomalyEngine;
  final InsightGenerationEngine insightEngine;
  final TrendAnalysisEngine trendEngine;
  final AlertManagementEngine alertEngine;

  AnalyticsManager({
    required this.repository,
    required this.metricsEngine,
    required this.anomalyEngine,
    required this.insightEngine,
    required this.trendEngine,
    required this.alertEngine,
  });

  Future<PerformanceMetric> recordMetric(String resourceId, String metricName, MetricType type, double value, String unit) async {
    return await metricsEngine.recordMetric(resourceId, metricName, type, value, unit);
  }

  Future<List<PerformanceMetric>> getMetrics(String resourceId) async {
    return await repository.getResourceMetrics(resourceId);
  }

  Future<PerformanceAlert> createAlert(String resourceId, String metricName, AlertPriority priority, double threshold, double actual) async {
    return await alertEngine.createAlert(resourceId, metricName, priority, threshold, actual);
  }
}

class AnalyticsFacade {
  final AnalyticsManager manager;

  AnalyticsFacade({required AnalyticsManager? manager})
      : manager = manager ??
            AnalyticsManager(
              repository: MemoryAnalyticsRepository(),
              metricsEngine: MetricsCollectionEngine(repository: MemoryAnalyticsRepository()),
              anomalyEngine: AnomalyDetectionEngine(repository: MemoryAnalyticsRepository()),
              insightEngine: InsightGenerationEngine(repository: MemoryAnalyticsRepository()),
              trendEngine: TrendAnalysisEngine(repository: MemoryAnalyticsRepository()),
              alertEngine: AlertManagementEngine(repository: MemoryAnalyticsRepository()),
            );

  Future<PerformanceMetric> recordMetric(String resourceId, String metricName, MetricType type, double value, String unit) async {
    return await manager.recordMetric(resourceId, metricName, type, value, unit);
  }

  Future<List<PerformanceMetric>> getMetrics(String resourceId) async {
    return await manager.getMetrics(resourceId);
  }

  Future<PerformanceAlert> createAlert(String resourceId, String metricName, AlertPriority priority, double threshold, double actual) async {
    return await manager.createAlert(resourceId, metricName, priority, threshold, actual);
  }

  Future<PerformanceInsight> generateInsight(String resourceId, InsightCategory category, String title, String description, double confidence, {String? recommendation}) async {
    return await manager.insightEngine.generateInsight(resourceId, category, title, description, confidence, recommendation: recommendation);
  }

  Future<PerformanceTrend> analyzeTrend(String resourceId, MetricType type, TrendDirection direction, double slope, int dataPoints, double rSquared) async {
    return await manager.trendEngine.analyzeTrend(resourceId, type, direction, slope, dataPoints, rSquared);
  }

  Future<List<PerformanceAnomaly>> getAnomalies(String resourceId) async {
    return await manager.repository.getResourceAnomalies(resourceId);
  }

  Future<List<PerformanceAlert>> getAlerts(String resourceId) async {
    return await manager.repository.getResourceAlerts(resourceId);
  }

  Future<void> resolveAlert(String alertId) async {
    await manager.alertEngine.resolveAlert(alertId);
  }
}
