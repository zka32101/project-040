/// Phase 47: Advanced Analytics & ML Integration Service層
///
/// 分析エンジン・予測エンジン・異常検知実装

import '../models/analytics_models.dart';

// ======================== Repository パターン ========================

/// 分析リポジトリインターフェース
abstract class AnalyticsRepository {
  Future<void> addMetric(AnalyticsMetric metric);
  Future<AnalyticsMetric?> getMetric(String metricId);
  Future<List<AnalyticsMetric>> getMetricsByType(AnalyticsMetricType type);
  Future<List<TimeSeriesDataPoint>> getTimeSeries(String metricId);
  Future<void> addPrediction(PredictionResult prediction);
  Future<List<PredictionResult>> getPredictions(String metricId);
  Future<void> addAnomaly(AnomalyDetectionResult anomaly);
  Future<List<AnomalyDetectionResult>> getAnomalies(String metricId);
  Future<void> addRecommendation(Recommendation recommendation);
  Future<List<Recommendation>> getRecommendations(String entityId);
  Future<void> addModel(MLModelMetadata model);
  Future<MLModelMetadata?> getModel(String modelId);
  Future<List<MLModelMetadata>> getActiveModels();
  Future<void> clearAll();
}

/// メモリベースの分析リポジトリ実装
class MemoryAnalyticsRepository implements AnalyticsRepository {
  final Map<String, AnalyticsMetric> _metrics = {};
  final Map<String, List<TimeSeriesDataPoint>> _timeSeries = {};
  final Map<String, PredictionResult> _predictions = {};
  final Map<String, AnomalyDetectionResult> _anomalies = {};
  final Map<String, Recommendation> _recommendations = {};
  final Map<String, MLModelMetadata> _models = {};

  @override
  Future<void> addMetric(AnalyticsMetric metric) async {
    _metrics[metric.metricId] = metric;
  }

  @override
  Future<AnalyticsMetric?> getMetric(String metricId) async {
    return _metrics[metricId];
  }

  @override
  Future<List<AnalyticsMetric>> getMetricsByType(AnalyticsMetricType type) async {
    return _metrics.values.where((m) => m.type == type).toList();
  }

  @override
  Future<List<TimeSeriesDataPoint>> getTimeSeries(String metricId) async {
    return _timeSeries[metricId] ?? [];
  }

  @override
  Future<void> addPrediction(PredictionResult prediction) async {
    _predictions[prediction.predictionId] = prediction;
  }

  @override
  Future<List<PredictionResult>> getPredictions(String metricId) async {
    return _predictions.values.where((p) => p.metricId == metricId).toList();
  }

  @override
  Future<void> addAnomaly(AnomalyDetectionResult anomaly) async {
    _anomalies[anomaly.anomalyId] = anomaly;
  }

  @override
  Future<List<AnomalyDetectionResult>> getAnomalies(String metricId) async {
    return _anomalies.values.where((a) => a.metricId == metricId).toList();
  }

  @override
  Future<void> addRecommendation(Recommendation recommendation) async {
    _recommendations[recommendation.recommendationId] = recommendation;
  }

  @override
  Future<List<Recommendation>> getRecommendations(String entityId) async {
    return _recommendations.values
        .where((r) => r.entityId == entityId && r.isValid)
        .toList();
  }

  @override
  Future<void> addModel(MLModelMetadata model) async {
    _models[model.modelId] = model;
  }

  @override
  Future<MLModelMetadata?> getModel(String modelId) async {
    return _models[modelId];
  }

  @override
  Future<List<MLModelMetadata>> getActiveModels() async {
    return _models.values.where((m) => m.isActive).toList();
  }

  @override
  Future<void> clearAll() async {
    _metrics.clear();
    _timeSeries.clear();
    _predictions.clear();
    _anomalies.clear();
    _recommendations.clear();
    _models.clear();
  }
}

// ======================== Engine パターン ========================

/// 分析エンジンインターフェース
abstract class AnalyticsEngine {
  Future<TimeSeriesAnalysis> analyzeTimeSeries(String metricId, List<TimeSeriesDataPoint> data);
  Future<PredictionResult> predict(String metricId, PredictionModelType modelType);
  Future<AnomalyDetectionResult> detectAnomaly(String metricId, double value, double expected);
  Future<List<Recommendation>> generateRecommendations(String entityId, List<AnalyticsMetric> metrics);
}

/// メモリベースの分析エンジン実装
class MemoryAnalyticsEngine implements AnalyticsEngine {
  @override
  Future<TimeSeriesAnalysis> analyzeTimeSeries(
    String metricId,
    List<TimeSeriesDataPoint> data,
  ) async {
    if (data.isEmpty) {
      return TimeSeriesAnalysis(
        analysisId: 'ts_$metricId',
        metricId: metricId,
        dataPoints: [],
        trend: 0.0,
        seasonality: 0.0,
        volatility: 0.0,
        analyzedAt: DateTime.now(),
      );
    }

    final values = data.map((d) => d.value).toList();
    final trend = _calculateTrend(values);
    final seasonality = _calculateSeasonality(values);
    final volatility = _calculateVolatility(values);

    return TimeSeriesAnalysis(
      analysisId: 'ts_$metricId',
      metricId: metricId,
      dataPoints: data,
      trend: trend,
      seasonality: seasonality,
      volatility: volatility,
      analyzedAt: DateTime.now(),
    );
  }

  @override
  Future<PredictionResult> predict(
    String metricId,
    PredictionModelType modelType,
  ) async {
    final now = DateTime.now();
    final predictedValue = 100.0 + (DateTime.now().millisecondsSinceEpoch % 50).toDouble();
    final confidence = 0.7 + (DateTime.now().millisecondsSinceEpoch % 30) / 100.0;

    return PredictionResult(
      predictionId: 'pred_$metricId',
      metricId: metricId,
      modelType: modelType,
      predictedValue: predictedValue,
      confidence: confidence.clamp(0.0, 1.0),
      predictionTime: now,
      targetTime: now.add(Duration(days: 1)),
    );
  }

  @override
  Future<AnomalyDetectionResult> detectAnomaly(
    String metricId,
    double value,
    double expected,
  ) async {
    final deviation = (value - expected) / expected;
    final absDeviation = deviation.abs();
    
    AnomalyLevel level;
    if (absDeviation > 0.5) {
      level = AnomalyLevel.critical;
    } else if (absDeviation > 0.3) {
      level = AnomalyLevel.high;
    } else if (absDeviation > 0.15) {
      level = AnomalyLevel.medium;
    } else {
      level = AnomalyLevel.low;
    }

    return AnomalyDetectionResult(
      anomalyId: 'anom_$metricId',
      metricId: metricId,
      value: value,
      expectedValue: expected,
      deviation: deviation,
      level: level,
      confidence: 0.8,
      detectedAt: DateTime.now(),
      description: 'Value deviation of ${(deviation * 100).toStringAsFixed(1)}%',
    );
  }

  @override
  Future<List<Recommendation>> generateRecommendations(
    String entityId,
    List<AnalyticsMetric> metrics,
  ) async {
    final recommendations = <Recommendation>[];

    for (final metric in metrics) {
      if (metric.changePercentage != null && metric.changePercentage! < -10) {
        recommendations.add(Recommendation(
          recommendationId: 'rec_${metric.metricId}',
          entityId: entityId,
          title: 'Investigate Decline in ${metric.name}',
          description: 'The metric has declined by ${metric.changePercentage!.toStringAsFixed(1)}%',
          score: 0.85,
          confidence: ConfidenceLevel.high,
          priority: 4,
          createdAt: DateTime.now(),
        ));
      }
    }

    return recommendations;
  }

  double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;
    final first = values.first;
    final last = values.last;
    return ((last - first) / first).clamp(-1.0, 1.0);
  }

  double _calculateSeasonality(List<double> values) {
    if (values.length < 10) return 0.0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.fold<double>(0, (sum, v) => sum + (v - mean) * (v - mean)) / values.length;
    final periodVariation = variance / (mean * mean + 1);
    return periodVariation.clamp(0.0, 1.0);
  }

  double _calculateVolatility(List<double> values) {
    if (values.length < 2) return 0.0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.fold<double>(0, (sum, v) => sum + (v - mean) * (v - mean)) / values.length;
    final stdDev = variance > 0 ? variance.sqrt() : 0;
    return (stdDev / (mean + 1)).clamp(0.0, 1.0);
  }
}

extension on double {
  double sqrt() => this < 0 ? 0 : (this == 0 ? 0 : _sqrt());
  double _sqrt() {
    var x = this;
    var y = (x + 1) / 2;
    while ((y - x).abs() > 1e-10) {
      x = y;
      y = (y + this / y) / 2;
    }
    return y;
  }
}

// ======================== Manager パターン ========================

/// 分析管理インターフェース
abstract class AnalyticsManager {
  Future<AnalyticsMetric> recordMetric({
    required String metricId,
    required String name,
    required AnalyticsMetricType type,
    required double value,
    double? previousValue,
    double? targetValue,
    String? unit,
  });
  Future<PredictionResult> runPrediction(String metricId, PredictionModelType modelType);
  Future<AnomalyDetectionResult> checkAnomaly(String metricId, double value, double expected);
  Future<List<Recommendation>> getRecommendations(String entityId);
  Future<AnalyticsReport> generateReport({
    required String reportId,
    required List<String> metricIds,
  });
}

/// メモリベースの分析管理実装
class MemoryAnalyticsManager implements AnalyticsManager {
  final AnalyticsRepository repository;
  final AnalyticsEngine engine;

  MemoryAnalyticsManager({
    required this.repository,
    required this.engine,
  });

  @override
  Future<AnalyticsMetric> recordMetric({
    required String metricId,
    required String name,
    required AnalyticsMetricType type,
    required double value,
    double? previousValue,
    double? targetValue,
    String? unit,
  }) async {
    final metric = AnalyticsMetric(
      metricId: metricId,
      name: name,
      type: type,
      currentValue: value,
      previousValue: previousValue,
      targetValue: targetValue,
      timestamp: DateTime.now(),
      unit: unit,
    );
    await repository.addMetric(metric);
    return metric;
  }

  @override
  Future<PredictionResult> runPrediction(
    String metricId,
    PredictionModelType modelType,
  ) async {
    final prediction = await engine.predict(metricId, modelType);
    await repository.addPrediction(prediction);
    return prediction;
  }

  @override
  Future<AnomalyDetectionResult> checkAnomaly(
    String metricId,
    double value,
    double expected,
  ) async {
    final anomaly = await engine.detectAnomaly(metricId, value, expected);
    await repository.addAnomaly(anomaly);
    return anomaly;
  }

  @override
  Future<List<Recommendation>> getRecommendations(String entityId) async {
    return await repository.getRecommendations(entityId);
  }

  @override
  Future<AnalyticsReport> generateReport({
    required String reportId,
    required List<String> metricIds,
  }) async {
    final metrics = <AnalyticsMetric>[];
    final predictions = <PredictionResult>[];
    final anomalies = <AnomalyDetectionResult>[];

    for (final metricId in metricIds) {
      final metric = await repository.getMetric(metricId);
      if (metric != null) metrics.add(metric);

      final preds = await repository.getPredictions(metricId);
      predictions.addAll(preds);

      final anoms = await repository.getAnomalies(metricId);
      anomalies.addAll(anoms);
    }

    final recommendations = await engine.generateRecommendations('report', metrics);

    return AnalyticsReport(
      reportId: reportId,
      generatedAt: DateTime.now(),
      metrics: metrics,
      predictions: predictions,
      anomalies: anomalies,
      recommendations: recommendations,
    );
  }
}

// ======================== Facade パターン ========================

/// 分析管理ファサード
class AnalyticsManagerFacade {
  final AnalyticsRepository repository;
  final AnalyticsEngine engine;
  final AnalyticsManager manager;

  AnalyticsManagerFacade({
    AnalyticsRepository? repository,
    AnalyticsEngine? engine,
    AnalyticsManager? manager,
  })  : repository = repository ?? MemoryAnalyticsRepository(),
        engine = engine ?? MemoryAnalyticsEngine(),
        manager = manager ?? MemoryAnalyticsManager(
          repository: repository ?? MemoryAnalyticsRepository(),
          engine: engine ?? MemoryAnalyticsEngine(),
        );

  Future<AnalyticsMetric> recordMetric({
    required String metricId,
    required String name,
    required AnalyticsMetricType type,
    required double value,
    double? previousValue,
    double? targetValue,
    String? unit,
  }) =>
      manager.recordMetric(
        metricId: metricId,
        name: name,
        type: type,
        value: value,
        previousValue: previousValue,
        targetValue: targetValue,
        unit: unit,
      );

  Future<PredictionResult> predict(String metricId, PredictionModelType modelType) =>
      manager.runPrediction(metricId, modelType);

  Future<AnomalyDetectionResult> detectAnomaly(
    String metricId,
    double value,
    double expected,
  ) =>
      manager.checkAnomaly(metricId, value, expected);

  Future<AnalyticsReport> generateReport({
    required String reportId,
    required List<String> metricIds,
  }) =>
      manager.generateReport(reportId: reportId, metricIds: metricIds);
}
