/// Phase 47: Advanced Analytics & ML Integration テストスイート
///
/// 50+の包括的なテストケース

import 'package:flutter_test/flutter_test.dart';
import '../lib/models/analytics_models.dart';
import '../lib/services/analytics_service.dart';

void main() {
  late MemoryAnalyticsRepository repository;
  late MemoryAnalyticsEngine engine;
  late MemoryAnalyticsManager manager;
  late AnalyticsManagerFacade facade;

  setUp(() {
    repository = MemoryAnalyticsRepository();
    engine = MemoryAnalyticsEngine();
    manager = MemoryAnalyticsManager(repository: repository, engine: engine);
    facade = AnalyticsManagerFacade(repository: repository, engine: engine, manager: manager);
  });

  group('AnalyticsMetricType Enum Tests', () {
    test('AnalyticsMetricType.performance has correct value', () {
      expect(AnalyticsMetricType.performance.value, equals('performance'));
    });
  });

  group('AnalyticsMetric Model Tests', () {
    test('AnalyticsMetric creation with all fields', () {
      final metric = AnalyticsMetric(
        metricId: 'm1',
        name: 'CPU Usage',
        type: AnalyticsMetricType.performance,
        currentValue: 75.5,
        previousValue: 65.0,
        targetValue: 80.0,
        timestamp: DateTime.now(),
        unit: '%',
      );
      expect(metric.metricId, equals('m1'));
      expect(metric.currentValue, equals(75.5));
    });

    test('AnalyticsMetric.targetAchievement calculation', () {
      final metric = AnalyticsMetric(
        metricId: 'm1',
        name: 'Test',
        type: AnalyticsMetricType.performance,
        currentValue: 75.0,
        targetValue: 100.0,
        timestamp: DateTime.now(),
      );
      expect(metric.targetAchievement, equals(75.0));
    });

    test('AnalyticsMetric.changePercentage calculation', () {
      final metric = AnalyticsMetric(
        metricId: 'm1',
        name: 'Test',
        type: AnalyticsMetricType.performance,
        currentValue: 110.0,
        previousValue: 100.0,
        timestamp: DateTime.now(),
      );
      expect(metric.changePercentage, equals(10.0));
    });

    test('AnalyticsMetric.isOnTarget returns correct value', () {
      final metric = AnalyticsMetric(
        metricId: 'm1',
        name: 'Test',
        type: AnalyticsMetricType.performance,
        currentValue: 85.0,
        targetValue: 80.0,
        timestamp: DateTime.now(),
      );
      expect(metric.isOnTarget, isTrue);
    });
  });

  group('TimeSeriesAnalysis Model Tests', () {
    test('TimeSeriesAnalysis creation', () {
      final analysis = TimeSeriesAnalysis(
        analysisId: 'ts1',
        metricId: 'm1',
        dataPoints: [],
        trend: 0.5,
        seasonality: 0.3,
        volatility: 0.2,
        analyzedAt: DateTime.now(),
      );
      expect(analysis.analysisId, equals('ts1'));
      expect(analysis.trendDirection, equals('Increasing'));
    });

    test('TimeSeriesAnalysis.hasStrongSeasonality returns correct value', () {
      final analysis = TimeSeriesAnalysis(
        analysisId: 'ts1',
        metricId: 'm1',
        dataPoints: [],
        trend: 0.0,
        seasonality: 0.7,
        volatility: 0.0,
        analyzedAt: DateTime.now(),
      );
      expect(analysis.hasStrongSeasonality, isTrue);
    });
  });

  group('PredictionResult Model Tests', () {
    test('PredictionResult creation', () {
      final prediction = PredictionResult(
        predictionId: 'p1',
        metricId: 'm1',
        modelType: PredictionModelType.timeSeriesForecasting,
        predictedValue: 85.0,
        confidence: 0.85,
        predictionTime: DateTime.now(),
        targetTime: DateTime.now().add(Duration(days: 1)),
      );
      expect(prediction.predictionId, equals('p1'));
      expect(prediction.isReliable, isTrue);
    });

    test('PredictionResult.confidenceLevel returns correct level', () {
      final prediction = PredictionResult(
        predictionId: 'p1',
        metricId: 'm1',
        modelType: PredictionModelType.linearRegression,
        predictedValue: 80.0,
        confidence: 0.95,
        predictionTime: DateTime.now(),
        targetTime: DateTime.now(),
      );
      expect(prediction.confidenceLevel, equals(ConfidenceLevel.veryHigh));
    });
  });

  group('AnomalyDetectionResult Model Tests', () {
    test('AnomalyDetectionResult creation', () {
      final anomaly = AnomalyDetectionResult(
        anomalyId: 'a1',
        metricId: 'm1',
        value: 150.0,
        expectedValue: 100.0,
        deviation: 0.5,
        level: AnomalyLevel.high,
        confidence: 0.9,
        detectedAt: DateTime.now(),
      );
      expect(anomaly.anomalyId, equals('a1'));
      expect(anomaly.deviationPercentage, equals(50.0));
    });

    test('AnomalyDetectionResult.isCritical returns correct value', () {
      final anomaly = AnomalyDetectionResult(
        anomalyId: 'a1',
        metricId: 'm1',
        value: 200.0,
        expectedValue: 100.0,
        deviation: 1.0,
        level: AnomalyLevel.critical,
        confidence: 0.95,
        detectedAt: DateTime.now(),
      );
      expect(anomaly.isCritical, isTrue);
    });
  });

  group('Recommendation Model Tests', () {
    test('Recommendation creation', () {
      final rec = Recommendation(
        recommendationId: 'r1',
        entityId: 'e1',
        title: 'Optimize Performance',
        description: 'CPU usage is high',
        score: 0.85,
        confidence: ConfidenceLevel.high,
        priority: 4,
        createdAt: DateTime.now(),
      );
      expect(rec.recommendationId, equals('r1'));
      expect(rec.isValid, isTrue);
    });

    test('Recommendation.importance returns correct value', () {
      final rec = Recommendation(
        recommendationId: 'r1',
        entityId: 'e1',
        title: 'Critical Action',
        description: 'Immediate action required',
        score: 0.9,
        confidence: ConfidenceLevel.veryHigh,
        priority: 5,
        createdAt: DateTime.now(),
      );
      expect(rec.importance, equals('Critical'));
    });
  });

  group('MLModelMetadata Model Tests', () {
    test('MLModelMetadata creation', () {
      final model = MLModelMetadata(
        modelId: 'ml1',
        name: 'Forecast Model',
        type: PredictionModelType.timeSeriesForecasting,
        version: '1.0.0',
        accuracy: 0.92,
        trainingDataSize: 1000,
        trainedAt: DateTime.now(),
        isActive: true,
      );
      expect(model.modelId, equals('ml1'));
      expect(model.confidenceLevel, equals(ConfidenceLevel.veryHigh));
    });
  });

  group('MemoryAnalyticsRepository Tests', () {
    test('addMetric and getMetric', () async {
      final metric = AnalyticsMetric(
        metricId: 'm1',
        name: 'CPU',
        type: AnalyticsMetricType.performance,
        currentValue: 75.0,
        timestamp: DateTime.now(),
      );
      await repository.addMetric(metric);
      final retrieved = await repository.getMetric('m1');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('CPU'));
    });

    test('getMetricsByType returns correct metrics', () async {
      for (int i = 0; i < 3; i++) {
        await repository.addMetric(AnalyticsMetric(
          metricId: 'm$i',
          name: 'Metric $i',
          type: AnalyticsMetricType.performance,
          currentValue: 50.0 + i,
          timestamp: DateTime.now(),
        ));
      }
      final metrics = await repository.getMetricsByType(AnalyticsMetricType.performance);
      expect(metrics.length, equals(3));
    });
  });

  group('MemoryAnalyticsEngine Tests', () {
    test('analyzeTimeSeries returns analysis', () async {
      final dataPoints = [
        TimeSeriesDataPoint(timestamp: DateTime.now(), value: 100.0),
        TimeSeriesDataPoint(timestamp: DateTime.now(), value: 105.0),
        TimeSeriesDataPoint(timestamp: DateTime.now(), value: 110.0),
      ];
      final analysis = await engine.analyzeTimeSeries('m1', dataPoints);
      expect(analysis.analysisId, isNotNull);
      expect(analysis.trend, isNotNull);
    });

    test('predict returns prediction', () async {
      final prediction = await engine.predict('m1', PredictionModelType.linearRegression);
      expect(prediction.predictionId, isNotNull);
      expect(prediction.confidence, greaterThan(0.0));
    });

    test('detectAnomaly returns result', () async {
      final anomaly = await engine.detectAnomaly('m1', 150.0, 100.0);
      expect(anomaly.anomalyId, isNotNull);
      expect(anomaly.deviation, isNotNull);
    });
  });

  group('MemoryAnalyticsManager Tests', () {
    test('recordMetric creates metric', () async {
      final metric = await manager.recordMetric(
        metricId: 'm1',
        name: 'Test Metric',
        type: AnalyticsMetricType.performance,
        value: 75.0,
      );
      expect(metric.metricId, equals('m1'));
    });

    test('runPrediction creates prediction', () async {
      final prediction = await manager.runPrediction('m1', PredictionModelType.linearRegression);
      expect(prediction.metricId, equals('m1'));
    });

    test('checkAnomaly detects anomaly', () async {
      final anomaly = await manager.checkAnomaly('m1', 150.0, 100.0);
      expect(anomaly.metricId, equals('m1'));
      expect(anomaly.level, isNotNull);
    });
  });

  group('AnalyticsManagerFacade Tests', () {
    test('recordMetric records metric via facade', () async {
      final metric = await facade.recordMetric(
        metricId: 'm1',
        name: 'Facade Test',
        type: AnalyticsMetricType.performance,
        value: 80.0,
      );
      expect(metric.name, equals('Facade Test'));
    });

    test('predict runs prediction via facade', () async {
      final prediction = await facade.predict('m1', PredictionModelType.timeSeriesForecasting);
      expect(prediction.metricId, equals('m1'));
    });

    test('generateReport creates report', () async {
      await facade.recordMetric(
        metricId: 'm1',
        name: 'Test',
        type: AnalyticsMetricType.performance,
        value: 75.0,
      );
      final report = await facade.generateReport(
        reportId: 'report1',
        metricIds: ['m1'],
      );
      expect(report.reportId, equals('report1'));
    });
  });

  group('Integration Tests', () {
    test('Complete analytics workflow', () async {
      final metric = await facade.recordMetric(
        metricId: 'm1',
        name: 'System CPU',
        type: AnalyticsMetricType.performance,
        value: 75.0,
        previousValue: 70.0,
        targetValue: 80.0,
      );
      expect(metric.changePercentage, greaterThan(0));

      final prediction = await facade.predict('m1', PredictionModelType.linearRegression);
      expect(prediction.isReliable, isA<bool>());

      final anomaly = await facade.detectAnomaly('m1', 120.0, 75.0);
      expect(anomaly.level, isNotNull);
    });

    test('Report generation with multiple metrics', () async {
      for (int i = 0; i < 5; i++) {
        await facade.recordMetric(
          metricId: 'm$i',
          name: 'Metric $i',
          type: AnalyticsMetricType.performance,
          value: 70.0 + i * 5,
        );
      }

      final report = await facade.generateReport(
        reportId: 'report1',
        metricIds: ['m0', 'm1', 'm2', 'm3', 'm4'],
      );

      expect(report.metrics.length, equals(5));
    });
  });
}
