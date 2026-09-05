import 'package:flutter_test/flutter_test.dart';
import '../lib/models/analytics_models.dart';
import '../lib/services/analytics_service.dart';

void main() {
  group('Phase 61: Advanced Analytics & Insights', () {
    late AnalyticsFacade analyticsFacade;

    setUp(() {
      analyticsFacade = AnalyticsFacade();
    });

    // Enum Tests
    group('Enums', () {
      test('AggregationType values', () {
        expect(AggregationType.sum.value, 'sum');
        expect(AggregationType.average.value, 'average');
        expect(AggregationType.count.value, 'count');
      });

      test('TimePeriod values', () {
        expect(TimePeriod.hour.value, 'hour');
        expect(TimePeriod.day.value, 'day');
        expect(TimePeriod.month.value, 'month');
      });

      test('TrendDirection values', () {
        expect(TrendDirection.upward.value, 'upward');
        expect(TrendDirection.downward.value, 'downward');
        expect(TrendDirection.stable.value, 'stable');
      });

      test('AnomalySeverity values', () {
        expect(AnomalySeverity.low.value, 'low');
        expect(AnomalySeverity.critical.value, 'critical');
      });

      test('ReportType values', () {
        expect(ReportType.summary.value, 'summary');
        expect(ReportType.detailed.value, 'detailed');
      });

      test('InsightCategory values', () {
        expect(InsightCategory.performance.value, 'performance');
        expect(InsightCategory.trend.value, 'trend');
      });
    });

    // Data Point Tests
    group('Data Points', () {
      test('Record metric', () async {
        await analyticsFacade.recordMetric('cpu_usage', 75.5);
        expect(true, true);
      });

      test('Data point is recent', () async {
        final point = DataPoint(
          dataPointId: 'point_1',
          metricName: 'memory',
          value: 50.0,
          timestamp: DateTime.now(),
        );
        expect(point.isRecent, true);
      });

      test('Data point age calculation', () async {
        final point = DataPoint(
          dataPointId: 'point_2',
          metricName: 'disk',
          value: 80.0,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        );
        expect(point.ageInHours, 2);
      });
    });

    // Aggregated Metric Tests
    group('Aggregated Metrics', () {
      test('Create aggregated metric', () async {
        final metric = AggregatedMetric(
          metricId: 'agg_1',
          metricName: 'cpu_average',
          aggregationType: AggregationType.average,
          aggregatedValue: 65.0,
          dataPointCount: 100,
          periodStart: DateTime.now().subtract(const Duration(days: 1)),
          periodEnd: DateTime.now(),
          period: TimePeriod.day,
        );
        expect(metric.isRecent, true);
      });

      test('Metric has significant data', () async {
        final metric = AggregatedMetric(
          metricId: 'agg_2',
          metricName: 'throughput',
          aggregationType: AggregationType.sum,
          aggregatedValue: 5000.0,
          dataPointCount: 500,
          periodStart: DateTime.now().subtract(const Duration(days: 7)),
          periodEnd: DateTime.now(),
          period: TimePeriod.week,
        );
        expect(metric.hasSignificantData, true);
      });
    });

    // Trend Tests
    group('Trends', () {
      test('Analyze trend', () async {
        final trend = await analyticsFacade.analyzeTrend('response_time');
        expect(trend.isSignificant, true);
      });

      test('Trend direction detection', () async {
        final trend = Trend(
          trendId: 'trend_1',
          metricName: 'cpu',
          direction: TrendDirection.upward,
          changePercentage: 10.0,
          slope: 0.15,
          analysisDate: DateTime.now(),
          dataPointsAnalyzed: 100,
          confidence: 0.95,
        );
        expect(trend.isIncreasing, true);
      });

      test('Trend high confidence', () async {
        final trend = Trend(
          trendId: 'trend_2',
          metricName: 'error_rate',
          direction: TrendDirection.downward,
          changePercentage: 5.0,
          slope: -0.08,
          analysisDate: DateTime.now(),
          dataPointsAnalyzed: 200,
          confidence: 0.98,
        );
        expect(trend.isHighConfidence, true);
      });
    });

    // Anomaly Tests
    group('Anomalies', () {
      test('Detect anomaly', () async {
        final anomaly = await analyticsFacade.detectAnomaly(
          'response_time',
          2500.0,
          500.0,
        );
        expect(anomaly.deviationPercentage, greaterThan(0));
      });

      test('Anomaly is critical', () async {
        final anomaly = Anomaly(
          anomalyId: 'anom_1',
          metricName: 'error_rate',
          anomalyValue: 0.5,
          expectedValue: 0.01,
          deviationPercentage: 4900.0,
          severity: AnomalySeverity.critical,
          detectedAt: DateTime.now(),
        );
        expect(anomaly.isCritical, true);
      });

      test('Anomaly is recent', () async {
        final anomaly = Anomaly(
          anomalyId: 'anom_2',
          metricName: 'memory',
          anomalyValue: 95.0,
          expectedValue: 70.0,
          deviationPercentage: 35.7,
          severity: AnomalySeverity.high,
          detectedAt: DateTime.now(),
        );
        expect(anomaly.isRecent, true);
      });
    });

    // Forecast Tests
    group('Forecasts', () {
      test('Generate forecast', () async {
        final forecast = await analyticsFacade.generateForecast(
          'cpu_usage',
          72.5,
        );
        expect(forecast.isFuture, true);
      });

      test('Forecast high confidence', () async {
        final forecast = Forecast(
          forecastId: 'forecast_1',
          metricName: 'throughput',
          predictedValue: 2500.0,
          confidenceInterval: 0.05,
          forecastDate: DateTime.now().add(const Duration(days: 7)),
          generatedAt: DateTime.now(),
          forecastingMethod: 'arima',
          dataPointsUsed: 365,
        );
        expect(forecast.hasHighConfidence, true);
      });

      test('Days until forecast', () async {
        final forecast = Forecast(
          forecastId: 'forecast_2',
          metricName: 'error_rate',
          predictedValue: 0.008,
          confidenceInterval: 0.02,
          forecastDate: DateTime.now().add(const Duration(days: 3)),
          generatedAt: DateTime.now(),
          forecastingMethod: 'exponential',
          dataPointsUsed: 100,
        );
        expect(forecast.daysUntilForecast, 3);
      });
    });

    // Insight Tests
    group('Insights', () {
      test('Generate insight', () async {
        final insight = await analyticsFacade.generateInsight(
          'High CPU Usage',
          'CPU usage has increased by 25%',
          0.8,
        );
        expect(insight.isActionable, true);
      });

      test('Insight is high impact', () async {
        final insight = Insight(
          insightId: 'insight_1',
          category: InsightCategory.performance,
          title: 'Critical Performance Issue',
          description: 'Response times degraded',
          impact: 0.95,
          isActionable: true,
          generatedAt: DateTime.now(),
        );
        expect(insight.isHighImpact, true);
      });

      test('Insight is recent', () async {
        final insight = Insight(
          insightId: 'insight_2',
          category: InsightCategory.trend,
          title: 'Positive Trend',
          description: 'Error rate decreasing',
          impact: 0.7,
          isActionable: true,
          generatedAt: DateTime.now(),
        );
        expect(insight.isRecent, true);
      });
    });

    // Performance Metrics Tests
    group('Performance Metrics', () {
      test('Analyze performance', () async {
        final metrics = await analyticsFacade.analyzePerformance();
        expect(metrics.isHealthy, true);
      });

      test('Performance is healthy', () async {
        final metrics = PerformanceMetrics(
          metricsId: 'perf_1',
          averageResponseTime: 150.0,
          p95ResponseTime: 300.0,
          p99ResponseTime: 500.0,
          throughput: 5000.0,
          errorRate: 0.005,
          availabilityPercentage: 99.99,
          measurementStart: DateTime.now().subtract(const Duration(hours: 1)),
          measurementEnd: DateTime.now(),
        );
        expect(metrics.isHealthy, true);
      });

      test('Performance has acceptable response time', () async {
        final metrics = PerformanceMetrics(
          metricsId: 'perf_2',
          averageResponseTime: 400.0,
          p95ResponseTime: 800.0,
          p99ResponseTime: 1200.0,
          throughput: 1000.0,
          errorRate: 0.01,
          availabilityPercentage: 99.5,
          measurementStart: DateTime.now().subtract(const Duration(hours: 1)),
          measurementEnd: DateTime.now(),
        );
        expect(metrics.hasAcceptablePerformance, true);
      });
    });

    // User Behavior Tests
    group('User Behavior', () {
      test('User behavior has high engagement', () async {
        final behavior = UserBehaviorAnalysis(
          analysisId: 'uba_1',
          totalUsers: 1000,
          activeUsers: 750,
          engagementRate: 0.75,
          conversionRate: 0.12,
          churnRate: 0.02,
          averageSessionDuration: 15.0,
          totalSessions: 5000,
          analysisDate: DateTime.now(),
        );
        expect(behavior.hasHighEngagement, true);
      });

      test('Active user percentage', () async {
        final behavior = UserBehaviorAnalysis(
          analysisId: 'uba_2',
          totalUsers: 1000,
          activeUsers: 600,
          engagementRate: 0.6,
          conversionRate: 0.08,
          churnRate: 0.03,
          averageSessionDuration: 10.0,
          totalSessions: 3000,
          analysisDate: DateTime.now(),
        );
        expect(behavior.activeUserPercentage, 60.0);
      });
    });

    // Report Tests
    group('Reports', () {
      test('Generate report', () async {
        final report = await analyticsFacade.generateReport(ReportType.summary);
        expect(report.reportType, ReportType.summary);
      });

      test('Report has actionable insights', () async {
        final insights = [
          Insight(
            insightId: 'i1',
            category: InsightCategory.recommendation,
            title: 'Optimize cache',
            description: 'Cache hit rate low',
            impact: 0.85,
            isActionable: true,
            generatedAt: DateTime.now(),
          ),
        ];
        final report = AnalyticsReport(
          reportId: 'report_1',
          reportType: ReportType.detailed,
          title: 'Detailed Analysis',
          generatedAt: DateTime.now(),
          metrics: [],
          trends: [],
          anomalies: [],
          insights: insights,
        );
        expect(report.hasActionableInsights, true);
      });
    });

    // Integration Tests
    group('Integration Tests', () {
      test('Complete analytics workflow', () async {
        await analyticsFacade.recordMetric('response_time', 250.0);
        final trend = await analyticsFacade.analyzeTrend('response_time');
        final report = await analyticsFacade.generateReport(ReportType.summary);

        expect(trend.isSignificant, true);
        expect(report.reportId, isNotEmpty);
      });

      test('Performance monitoring workflow', () async {
        final metrics = await analyticsFacade.analyzePerformance();
        expect(metrics.isHealthy, true);
      });
    });

    // Edge Cases
    group('Edge Cases', () {
      test('Metric with zero value', () async {
        await analyticsFacade.recordMetric('test_metric', 0.0);
        expect(true, true);
      });

      test('Forecast with past date', () async {
        final forecast = Forecast(
          forecastId: 'forecast_past',
          metricName: 'old_metric',
          predictedValue: 100.0,
          confidenceInterval: 0.1,
          forecastDate: DateTime.now().subtract(const Duration(days: 1)),
          generatedAt: DateTime.now(),
          forecastingMethod: 'test',
          dataPointsUsed: 10,
        );
        expect(forecast.isFuture, false);
      });

      test('Anomaly with very high deviation', () async {
        final anomaly = Anomaly(
          anomalyId: 'anom_extreme',
          metricName: 'extreme_metric',
          anomalyValue: 10000.0,
          expectedValue: 100.0,
          deviationPercentage: 9900.0,
          severity: AnomalySeverity.critical,
          detectedAt: DateTime.now(),
        );
        expect(anomaly.isCritical, true);
      });
    });
  });
}
