import 'package:flutter_test/flutter_test.dart';
import '../lib/models/analytics_models.dart';
import '../lib/services/analytics_models_service.dart';

void main() {
  group('Phase 70: Performance Analytics & Insights', () {
    late AnalyticsRepository repository;
    late AnalyticsFacade facade;

    setUp(() {
      repository = MemoryAnalyticsRepository();
      final metricsEngine = MetricsCollectionEngine(repository: repository);
      final anomalyEngine = AnomalyDetectionEngine(repository: repository);
      final insightEngine = InsightGenerationEngine(repository: repository);
      final trendEngine = TrendAnalysisEngine(repository: repository);
      final alertEngine = AlertManagementEngine(repository: repository);
      final manager = AnalyticsManager(
        repository: repository,
        metricsEngine: metricsEngine,
        anomalyEngine: anomalyEngine,
        insightEngine: insightEngine,
        trendEngine: trendEngine,
        alertEngine: alertEngine,
      );
      facade = AnalyticsFacade(manager: manager);
    });

    // Enum Tests
    group('Enums', () {
      test('MetricType contains all values', () {
        expect(MetricType.values.length, equals(7));
        expect(MetricType.values, contains(MetricType.latency));
        expect(MetricType.values, contains(MetricType.throughput));
      });

      test('AnomalyType contains all values', () {
        expect(AnomalyType.values.length, equals(6));
      });

      test('InsightCategory contains all values', () {
        expect(InsightCategory.values.length, equals(5));
      });

      test('TrendDirection contains all values', () {
        expect(TrendDirection.values.length, equals(4));
      });

      test('AlertPriority contains all values', () {
        expect(AlertPriority.values.length, equals(4));
      });

      test('ReportFrequency contains all values', () {
        expect(ReportFrequency.values.length, equals(6));
      });
    });

    // PerformanceMetric Tests
    group('PerformanceMetric', () {
      test('create metric with required fields', () async {
        final metric = PerformanceMetric(
          metricId: 'metric_1',
          resourceId: 'resource_1',
          metricName: 'Response Time',
          metricType: MetricType.latency,
          value: 150.0,
          unit: 'ms',
          recordedAt: DateTime.now(),
        );

        expect(metric.metricId, equals('metric_1'));
        expect(metric.resourceId, equals('resource_1'));
        expect(metric.value, equals(150.0));
      });

      test('isAnomalous returns true when value exceeds threshold', () {
        final metric = PerformanceMetric(
          metricId: 'metric_2',
          resourceId: 'resource_1',
          metricName: 'Error Rate',
          metricType: MetricType.errorRate,
          value: 15.0,
          unit: '%',
          recordedAt: DateTime.now(),
          threshold: 10.0,
        );

        expect(metric.isAnomalous, isTrue);
      });

      test('isRecent returns true for recent metric', () {
        final metric = PerformanceMetric(
          metricId: 'metric_3',
          resourceId: 'resource_1',
          metricName: 'CPU Usage',
          metricType: MetricType.cpuUsage,
          value: 75.0,
          unit: '%',
          recordedAt: DateTime.now(),
        );

        expect(metric.isRecent, isTrue);
      });

      test('ageInSeconds calculated correctly', () {
        final now = DateTime.now();
        final metric = PerformanceMetric(
          metricId: 'metric_4',
          resourceId: 'resource_1',
          metricName: 'Memory',
          metricType: MetricType.memoryUsage,
          value: 80.0,
          unit: 'GB',
          recordedAt: now.subtract(Duration(seconds: 30)),
        );

        expect(metric.ageInSeconds, greaterThanOrEqualTo(30));
      });

      test('isCritical reflects anomaly status', () {
        final metric = PerformanceMetric(
          metricId: 'metric_5',
          resourceId: 'resource_1',
          metricName: 'Test',
          metricType: MetricType.throughput,
          value: 100.0,
          unit: 'req/s',
          recordedAt: DateTime.now(),
          threshold: 80.0,
        );

        expect(metric.isCritical, isTrue);
      });
    });

    // PerformanceTimeSeries Tests
    group('PerformanceTimeSeries', () {
      test('create empty time series', () {
        final series = PerformanceTimeSeries(
          seriesId: 'series_1',
          resourceId: 'resource_1',
          metricType: MetricType.latency,
          dataPoints: [],
          createdAt: DateTime.now(),
          intervalSeconds: 60,
        );

        expect(series.hasData, isFalse);
        expect(series.dataPointCount, equals(0));
      });

      test('calculate average of data points', () {
        final metric1 = PerformanceMetric(
          metricId: 'metric_1',
          resourceId: 'resource_1',
          metricName: 'Test',
          metricType: MetricType.latency,
          value: 100.0,
          unit: 'ms',
          recordedAt: DateTime.now(),
        );
        final metric2 = PerformanceMetric(
          metricId: 'metric_2',
          resourceId: 'resource_1',
          metricName: 'Test',
          metricType: MetricType.latency,
          value: 200.0,
          unit: 'ms',
          recordedAt: DateTime.now(),
        );

        final series = PerformanceTimeSeries(
          seriesId: 'series_2',
          resourceId: 'resource_1',
          metricType: MetricType.latency,
          dataPoints: [metric1, metric2],
          createdAt: DateTime.now(),
          intervalSeconds: 60,
        );

        expect(series.average, equals(150.0));
      });

      test('find max and min values', () {
        final metric1 = PerformanceMetric(
          metricId: 'metric_1',
          resourceId: 'resource_1',
          metricName: 'Test',
          metricType: MetricType.throughput,
          value: 50.0,
          unit: 'req/s',
          recordedAt: DateTime.now(),
        );
        final metric2 = PerformanceMetric(
          metricId: 'metric_2',
          resourceId: 'resource_1',
          metricName: 'Test',
          metricType: MetricType.throughput,
          value: 200.0,
          unit: 'req/s',
          recordedAt: DateTime.now(),
        );

        final series = PerformanceTimeSeries(
          seriesId: 'series_3',
          resourceId: 'resource_1',
          metricType: MetricType.throughput,
          dataPoints: [metric1, metric2],
          createdAt: DateTime.now(),
          intervalSeconds: 60,
        );

        expect(series.maxValue, equals(200.0));
        expect(series.minValue, equals(50.0));
      });
    });

    // PerformanceAnomaly Tests
    group('PerformanceAnomaly', () {
      test('create anomaly with required fields', () {
        final anomaly = PerformanceAnomaly(
          anomalyId: 'anomaly_1',
          resourceId: 'resource_1',
          seriesId: 'series_1',
          anomalyType: AnomalyType.spike,
          severity: 0.9,
          detectedAt: DateTime.now(),
          context: {'value': 500},
        );

        expect(anomaly.isCritical, isTrue);
      });

      test('isPending returns true for unresolved anomalies', () {
        final anomaly = PerformanceAnomaly(
          anomalyId: 'anomaly_2',
          resourceId: 'resource_1',
          seriesId: 'series_1',
          anomalyType: AnomalyType.drop,
          severity: 0.5,
          detectedAt: DateTime.now(),
          context: {},
        );

        expect(anomaly.isPending, isTrue);
      });

      test('ageInHours calculated correctly', () {
        final now = DateTime.now();
        final anomaly = PerformanceAnomaly(
          anomalyId: 'anomaly_3',
          resourceId: 'resource_1',
          seriesId: 'series_1',
          anomalyType: AnomalyType.trend,
          severity: 0.6,
          detectedAt: now.subtract(Duration(hours: 12)),
          context: {},
        );

        expect(anomaly.ageInHours, greaterThanOrEqualTo(12));
      });

      test('isRecent reflects detection time', () {
        final anomaly = PerformanceAnomaly(
          anomalyId: 'anomaly_4',
          resourceId: 'resource_1',
          seriesId: 'series_1',
          anomalyType: AnomalyType.outlier,
          severity: 0.7,
          detectedAt: DateTime.now().subtract(Duration(hours: 1)),
          context: {},
        );

        expect(anomaly.isRecent, isTrue);
      });
    });

    // PerformanceInsight Tests
    group('PerformanceInsight', () {
      test('create insight with recommendation', () {
        final insight = PerformanceInsight(
          insightId: 'insight_1',
          resourceId: 'resource_1',
          category: InsightCategory.performance,
          title: 'High Latency',
          description: 'Average latency exceeds baseline',
          confidenceScore: 0.95,
          discoveredAt: DateTime.now(),
          recommendation: 'Scale up instances',
        );

        expect(insight.isActionable, isTrue);
        expect(insight.isHighConfidence, isTrue);
      });

      test('hasAction tracks if action was taken', () {
        final insight = PerformanceInsight(
          insightId: 'insight_2',
          resourceId: 'resource_1',
          category: InsightCategory.reliability,
          title: 'Error Rate Increase',
          description: 'Error rate trending upward',
          confidenceScore: 0.85,
          discoveredAt: DateTime.now(),
          actionTakenAt: DateTime.now(),
        );

        expect(insight.hasAction, isTrue);
      });
    });

    // PerformanceTrend Tests
    group('PerformanceTrend', () {
      test('create upward trend', () {
        final trend = PerformanceTrend(
          trendId: 'trend_1',
          resourceId: 'resource_1',
          metricType: MetricType.errorRate,
          direction: TrendDirection.upward,
          slope: 0.5,
          startDate: DateTime.now().subtract(Duration(days: 30)),
          endDate: DateTime.now(),
          dataPoints: 100,
          rSquared: 0.85,
        );

        expect(trend.isGrowing, isTrue);
        expect(trend.isSignificant, isTrue);
      });

      test('create downward trend', () {
        final trend = PerformanceTrend(
          trendId: 'trend_2',
          resourceId: 'resource_1',
          metricType: MetricType.latency,
          direction: TrendDirection.downward,
          slope: -0.3,
          startDate: DateTime.now().subtract(Duration(days: 30)),
          endDate: DateTime.now(),
          dataPoints: 100,
          rSquared: 0.75,
        );

        expect(trend.isDecreasing, isTrue);
        expect(trend.isSignificant, isTrue);
      });

      test('durationInDays calculated correctly', () {
        final start = DateTime.now().subtract(Duration(days: 7));
        final end = DateTime.now();
        final trend = PerformanceTrend(
          trendId: 'trend_3',
          resourceId: 'resource_1',
          metricType: MetricType.cpuUsage,
          direction: TrendDirection.stable,
          slope: 0.0,
          startDate: start,
          endDate: end,
          dataPoints: 50,
          rSquared: 0.95,
        );

        expect(trend.durationInDays, equals(7));
      });
    });

    // PerformanceAlert Tests
    group('PerformanceAlert', () {
      test('create critical alert', () {
        final alert = PerformanceAlert(
          alertId: 'alert_1',
          resourceId: 'resource_1',
          metricName: 'CPU Usage',
          priority: AlertPriority.critical,
          thresholdValue: 85.0,
          actualValue: 95.0,
          triggeredAt: DateTime.now(),
        );

        expect(alert.isCritical, isTrue);
        expect(alert.isPending, isTrue);
      });

      test('resolve alert', () {
        final alert = PerformanceAlert(
          alertId: 'alert_2',
          resourceId: 'resource_1',
          metricName: 'Memory Usage',
          priority: AlertPriority.high,
          thresholdValue: 80.0,
          actualValue: 85.0,
          triggeredAt: DateTime.now(),
          resolvedAt: DateTime.now(),
        );

        expect(alert.isResolved, isTrue);
      });

      test('ageInMinutes for recent alert', () {
        final alert = PerformanceAlert(
          alertId: 'alert_3',
          resourceId: 'resource_1',
          metricName: 'Disk Usage',
          priority: AlertPriority.medium,
          thresholdValue: 90.0,
          actualValue: 92.0,
          triggeredAt: DateTime.now().subtract(Duration(minutes: 5)),
        );

        expect(alert.ageInMinutes, greaterThanOrEqualTo(5));
      });
    });

    // PerformanceReport Tests
    group('PerformanceReport', () {
      test('create healthy report', () {
        final report = PerformanceReport(
          reportId: 'report_1',
          resourceId: 'resource_1',
          frequency: ReportFrequency.daily,
          periodStart: DateTime.now().subtract(Duration(days: 1)),
          periodEnd: DateTime.now(),
          metrics: {'latency': 150.0, 'throughput': 1000.0},
          anomalyCount: 0,
          insightCount: 2,
          averageHealthScore: 95.0,
        );

        expect(report.isHealthy, isTrue);
        expect(report.hasAnomalies, isFalse);
      });

      test('report with anomalies', () {
        final report = PerformanceReport(
          reportId: 'report_2',
          resourceId: 'resource_1',
          frequency: ReportFrequency.weekly,
          periodStart: DateTime.now().subtract(Duration(days: 7)),
          periodEnd: DateTime.now(),
          metrics: {'errorRate': 5.5},
          anomalyCount: 3,
          insightCount: 1,
          averageHealthScore: 80.0,
        );

        expect(report.hasAnomalies, isTrue);
        expect(report.isHealthy, isFalse);
      });

      test('durationInDays of report', () {
        final start = DateTime.now().subtract(Duration(days: 30));
        final end = DateTime.now();
        final report = PerformanceReport(
          reportId: 'report_3',
          resourceId: 'resource_1',
          frequency: ReportFrequency.monthly,
          periodStart: start,
          periodEnd: end,
          metrics: {},
          anomalyCount: 0,
          insightCount: 0,
          averageHealthScore: 92.0,
        );

        expect(report.durationInDays, equals(30));
      });
    });

    // PerformanceBaseline Tests
    group('PerformanceBaseline', () {
      test('create baseline', () {
        final baseline = PerformanceBaseline(
          baselineId: 'baseline_1',
          resourceId: 'resource_1',
          metricType: MetricType.latency,
          normalMin: 100.0,
          normalMax: 200.0,
          mean: 150.0,
          standardDeviation: 20.0,
          createdAt: DateTime.now(),
        );

        expect(baseline.rangeWidth, equals(100.0));
        expect(baseline.mean, equals(150.0));
      });

      test('isRecent for updated baseline', () {
        final baseline = PerformanceBaseline(
          baselineId: 'baseline_2',
          resourceId: 'resource_1',
          metricType: MetricType.throughput,
          normalMin: 800.0,
          normalMax: 1200.0,
          mean: 1000.0,
          standardDeviation: 50.0,
          createdAt: DateTime.now().subtract(Duration(days: 10)),
          lastUpdatedAt: DateTime.now().subtract(Duration(days: 1)),
        );

        expect(baseline.isRecent, isTrue);
      });
    });

    // PerformanceComparison Tests
    group('PerformanceComparison', () {
      test('comparison showing improvement', () {
        final comparison = PerformanceComparison(
          comparisonId: 'comp_1',
          resourceId: 'resource_1',
          periodStart: DateTime.now().subtract(Duration(days: 7)),
          periodEnd: DateTime.now(),
          previousPeriodStart: DateTime.now().subtract(Duration(days: 14)),
          previousPeriodEnd: DateTime.now().subtract(Duration(days: 7)),
          currentMetrics: {'latency': 120.0, 'errorRate': 1.5},
          previousMetrics: {'latency': 180.0, 'errorRate': 3.0},
          percentageChange: {'latency': -33.3, 'errorRate': -50.0},
        );

        expect(comparison.hasImprovement, isTrue);
      });

      test('comparison showing regression', () {
        final comparison = PerformanceComparison(
          comparisonId: 'comp_2',
          resourceId: 'resource_1',
          periodStart: DateTime.now().subtract(Duration(days: 7)),
          periodEnd: DateTime.now(),
          previousPeriodStart: DateTime.now().subtract(Duration(days: 14)),
          previousPeriodEnd: DateTime.now().subtract(Duration(days: 7)),
          currentMetrics: {'cpuUsage': 85.0},
          previousMetrics: {'cpuUsage': 50.0},
          percentageChange: {'cpuUsage': 70.0},
        );

        expect(comparison.hasRegression, isTrue);
      });
    });

    // AnalyticsConfiguration Tests
    group('AnalyticsConfiguration', () {
      test('create configuration', () {
        final config = AnalyticsConfiguration(
          configId: 'config_1',
          resourceId: 'resource_1',
          trackedMetrics: [MetricType.latency, MetricType.throughput],
          metricsRetentionDays: 90,
          anomalyDetectionSensitivity: 75,
          trendAnalysisWindow: 30,
          isEnabled: true,
          createdAt: DateTime.now(),
        );

        expect(config.hasMetrics, isTrue);
        expect(config.metricCount, equals(2));
      });

      test('long retention configuration', () {
        final config = AnalyticsConfiguration(
          configId: 'config_2',
          resourceId: 'resource_1',
          trackedMetrics: [MetricType.errorRate],
          metricsRetentionDays: 730,
          anomalyDetectionSensitivity: 80,
          trendAnalysisWindow: 60,
          isEnabled: true,
          createdAt: DateTime.now(),
        );

        expect(config.isLongRetention, isTrue);
      });
    });

    // PerformanceCorrelation Tests
    group('PerformanceCorrelation', () {
      test('strong positive correlation', () {
        final correlation = PerformanceCorrelation(
          correlationId: 'corr_1',
          resourceId: 'resource_1',
          metricA: 'CPUUsage',
          metricB: 'Throughput',
          correlationCoefficient: 0.85,
          sampleCount: 100,
          calculatedAt: DateTime.now(),
        );

        expect(correlation.hasStrongCorrelation, isTrue);
        expect(correlation.isPositive, isTrue);
      });

      test('strong negative correlation', () {
        final correlation = PerformanceCorrelation(
          correlationId: 'corr_2',
          resourceId: 'resource_1',
          metricA: 'Latency',
          metricB: 'AvailableMemory',
          correlationCoefficient: -0.82,
          sampleCount: 100,
          calculatedAt: DateTime.now(),
        );

        expect(correlation.hasStrongCorrelation, isTrue);
        expect(correlation.isNegative, isTrue);
      });

      test('weak correlation', () {
        final correlation = PerformanceCorrelation(
          correlationId: 'corr_3',
          resourceId: 'resource_1',
          metricA: 'RequestCount',
          metricB: 'DiskSpace',
          correlationCoefficient: 0.35,
          sampleCount: 100,
          calculatedAt: DateTime.now(),
        );

        expect(correlation.hasStrongCorrelation, isFalse);
      });
    });

    // Repository Tests
    group('MemoryAnalyticsRepository', () {
      test('recordMetric and retrieve', () async {
        final metric = PerformanceMetric(
          metricId: 'metric_test_1',
          resourceId: 'resource_1',
          metricName: 'Test Metric',
          metricType: MetricType.latency,
          value: 150.0,
          unit: 'ms',
          recordedAt: DateTime.now(),
        );

        await repository.recordMetric(metric);
        final retrieved = await repository.getMetric('metric_test_1');

        expect(retrieved, isNotNull);
        expect(retrieved?.value, equals(150.0));
      });

      test('getResourceMetrics returns all metrics for resource', () async {
        final metric1 = PerformanceMetric(
          metricId: 'metric_1',
          resourceId: 'resource_1',
          metricName: 'Metric 1',
          metricType: MetricType.latency,
          value: 100.0,
          unit: 'ms',
          recordedAt: DateTime.now(),
        );
        final metric2 = PerformanceMetric(
          metricId: 'metric_2',
          resourceId: 'resource_1',
          metricName: 'Metric 2',
          metricType: MetricType.throughput,
          value: 1000.0,
          unit: 'req/s',
          recordedAt: DateTime.now(),
        );

        await repository.recordMetric(metric1);
        await repository.recordMetric(metric2);
        final metrics = await repository.getResourceMetrics('resource_1');

        expect(metrics.length, equals(2));
      });

      test('recordAnomaly and getUnresolvedAnomalies', () async {
        final anomaly = PerformanceAnomaly(
          anomalyId: 'anomaly_repo_1',
          resourceId: 'resource_1',
          seriesId: 'series_1',
          anomalyType: AnomalyType.spike,
          severity: 0.8,
          detectedAt: DateTime.now(),
          context: {},
        );

        await repository.recordAnomaly(anomaly);
        final unresolved = await repository.getUnresolvedAnomalies();

        expect(unresolved.isNotEmpty, isTrue);
      });

      test('createInsight and getInsightsByCategory', () async {
        final insight = PerformanceInsight(
          insightId: 'insight_repo_1',
          resourceId: 'resource_1',
          category: InsightCategory.performance,
          title: 'High Latency',
          description: 'Latency is high',
          confidenceScore: 0.9,
          discoveredAt: DateTime.now(),
        );

        await repository.createInsight(insight);
        final insights = await repository.getInsightsByCategory(InsightCategory.performance);

        expect(insights.isNotEmpty, isTrue);
      });

      test('createAlert and getPendingAlerts', () async {
        final alert = PerformanceAlert(
          alertId: 'alert_repo_1',
          resourceId: 'resource_1',
          metricName: 'CPU',
          priority: AlertPriority.critical,
          thresholdValue: 85.0,
          actualValue: 95.0,
          triggeredAt: DateTime.now(),
        );

        await repository.createAlert(alert);
        final pending = await repository.getPendingAlerts();

        expect(pending.isNotEmpty, isTrue);
      });
    });

    // Engine Tests
    group('MetricsCollectionEngine', () {
      test('recordMetric creates and stores metric', () async {
        final metric = await facade.recordMetric('resource_1', 'Test', MetricType.latency, 150.0, 'ms');

        expect(metric.metricId, isNotEmpty);
        expect(metric.value, equals(150.0));
      });

      test('getMetrics retrieves stored metrics', () async {
        await facade.recordMetric('resource_1', 'Latency', MetricType.latency, 100.0, 'ms');
        await facade.recordMetric('resource_1', 'Throughput', MetricType.throughput, 1000.0, 'req/s');

        final metrics = await facade.getMetrics('resource_1');
        expect(metrics.length, equals(2));
      });
    });

    // Facade Integration Tests
    group('AnalyticsFacade Integration', () {
      test('create alert through facade', () async {
        final alert = await facade.createAlert('resource_1', 'CPU', AlertPriority.high, 80.0, 85.0);

        expect(alert.alertId, isNotEmpty);
        expect(alert.isPending, isTrue);
      });

      test('generate insight through facade', () async {
        final insight = await facade.generateInsight(
          'resource_1',
          InsightCategory.performance,
          'Test Insight',
          'Test Description',
          0.95,
          recommendation: 'Scale up'
        );

        expect(insight.insightId, isNotEmpty);
        expect(insight.isHighConfidence, isTrue);
      });

      test('analyze trend through facade', () async {
        final trend = await facade.analyzeTrend(
          'resource_1',
          MetricType.errorRate,
          TrendDirection.upward,
          0.5,
          100,
          0.85
        );

        expect(trend.trendId, isNotEmpty);
        expect(trend.isGrowing, isTrue);
      });

      test('get alerts for resource', () async {
        await facade.createAlert('resource_1', 'Metric1', AlertPriority.high, 90.0, 95.0);
        await facade.createAlert('resource_1', 'Metric2', AlertPriority.critical, 80.0, 85.0);

        final alerts = await facade.getAlerts('resource_1');
        expect(alerts.length, equals(2));
      });

      test('resolve alert through facade', () async {
        final alert = await facade.createAlert('resource_1', 'CPU', AlertPriority.medium, 75.0, 80.0);
        await facade.resolveAlert(alert.alertId);

        final resolved = await repository.getAlert(alert.alertId);
        expect(resolved?.isResolved, isTrue);
      });

      test('get anomalies for resource', () async {
        final engine = AnomalyDetectionEngine(repository: repository);
        await engine.detectAnomaly('resource_1', 'series_1', AnomalyType.spike, 0.8);
        await engine.detectAnomaly('resource_1', 'series_1', AnomalyType.drop, 0.6);

        final anomalies = await facade.getAnomalies('resource_1');
        expect(anomalies.length, equals(2));
      });
    });

    // Edge Cases
    group('Edge Cases', () {
      test('metric with null threshold', () {
        final metric = PerformanceMetric(
          metricId: 'metric_edge_1',
          resourceId: 'resource_1',
          metricName: 'Test',
          metricType: MetricType.latency,
          value: 200.0,
          unit: 'ms',
          recordedAt: DateTime.now(),
          threshold: null,
        );

        expect(metric.isAnomalous, isFalse);
      });

      test('empty time series average', () {
        final series = PerformanceTimeSeries(
          seriesId: 'series_empty',
          resourceId: 'resource_1',
          metricType: MetricType.latency,
          dataPoints: [],
          createdAt: DateTime.now(),
          intervalSeconds: 60,
        );

        expect(series.average, equals(0.0));
      });

      test('alert with zero age', () {
        final alert = PerformanceAlert(
          alertId: 'alert_edge_1',
          resourceId: 'resource_1',
          metricName: 'Test',
          priority: AlertPriority.low,
          thresholdValue: 80.0,
          actualValue: 85.0,
          triggeredAt: DateTime.now(),
        );

        expect(alert.ageInMinutes, greaterThanOrEqualTo(0));
      });

      test('correlation coefficient boundary values', () {
        final corr1 = PerformanceCorrelation(
          correlationId: 'corr_edge_1',
          resourceId: 'resource_1',
          metricA: 'A',
          metricB: 'B',
          correlationCoefficient: 0.7,
          sampleCount: 50,
          calculatedAt: DateTime.now(),
        );

        final corr2 = PerformanceCorrelation(
          correlationId: 'corr_edge_2',
          resourceId: 'resource_1',
          metricA: 'C',
          metricB: 'D',
          correlationCoefficient: 0.71,
          sampleCount: 50,
          calculatedAt: DateTime.now(),
        );

        expect(corr1.hasStrongCorrelation, isFalse);
        expect(corr2.hasStrongCorrelation, isTrue);
      });

      test('multiple resources isolation', () async {
        await facade.recordMetric('resource_1', 'Metric', MetricType.latency, 100.0, 'ms');
        await facade.recordMetric('resource_2', 'Metric', MetricType.latency, 200.0, 'ms');

        final metrics1 = await facade.getMetrics('resource_1');
        final metrics2 = await facade.getMetrics('resource_2');

        expect(metrics1.length, equals(1));
        expect(metrics2.length, equals(1));
        expect(metrics1[0].value, equals(100.0));
        expect(metrics2[0].value, equals(200.0));
      });
    });

    // Performance and Stress Tests
    group('Performance', () {
      test('handle large metric volume', () async {
        for (int i = 0; i < 100; i++) {
          await facade.recordMetric('resource_1', 'Metric_$i', MetricType.latency, i.toDouble(), 'ms');
        }

        final metrics = await facade.getMetrics('resource_1');
        expect(metrics.length, equals(100));
      });

      test('rapid alert creation', () async {
        for (int i = 0; i < 50; i++) {
          await facade.createAlert('resource_1', 'Metric_$i', AlertPriority.high, 80.0, 85.0);
        }

        final alerts = await facade.getAlerts('resource_1');
        expect(alerts.length, equals(50));
      });
    });
  });
}
