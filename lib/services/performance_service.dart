/// Phase 53: Performance Monitoring & Optimization Service
/// パフォーマンス監視・最適化サービス

import '../models/performance_models.dart';

/// パフォーマンスリポジトリ インターフェース
abstract class PerformanceRepository {
  Future<PerformanceData> addMetric(PerformanceData data);
  Future<PerformanceData?> getMetric(String metricId);
  Future<List<PerformanceData>> getMetricsByType(PerformanceMetricType type);
  Future<List<PerformanceData>> getMetricsByTimeRange(DateTime start, DateTime end);
  Future<CacheEntry> addCacheEntry(CacheEntry entry);
  Future<CacheEntry?> getCacheEntry(String entryId);
  Future<List<CacheEntry>> getAllCacheEntries();
  Future<void> removeCacheEntry(String entryId);
  Future<OptimizationRecommendation> addRecommendation(OptimizationRecommendation rec);
  Future<List<OptimizationRecommendation>> getPendingRecommendations();
  Future<BottleneckAnalysis> addBottleneck(BottleneckAnalysis analysis);
  Future<List<BottleneckAnalysis>> getActiveBottlenecks();
  Future<void> clearAll();
}

/// メモリパフォーマンスリポジトリ実装
class MemoryPerformanceRepository implements PerformanceRepository {
  final Map<String, PerformanceData> _metrics = {};
  final Map<String, CacheEntry> _cacheEntries = {};
  final Map<String, OptimizationRecommendation> _recommendations = {};
  final Map<String, BottleneckAnalysis> _bottlenecks = {};

  @override
  Future<PerformanceData> addMetric(PerformanceData data) async {
    _metrics[data.metricId] = data;
    return data;
  }

  @override
  Future<PerformanceData?> getMetric(String metricId) async {
    return _metrics[metricId];
  }

  @override
  Future<List<PerformanceData>> getMetricsByType(PerformanceMetricType type) async {
    return _metrics.values.where((m) => m.metricType == type).toList();
  }

  @override
  Future<List<PerformanceData>> getMetricsByTimeRange(DateTime start, DateTime end) async {
    return _metrics.values
        .where((m) => m.recordedAt.isAfter(start) && m.recordedAt.isBefore(end))
        .toList();
  }

  @override
  Future<CacheEntry> addCacheEntry(CacheEntry entry) async {
    _cacheEntries[entry.entryId] = entry;
    return entry;
  }

  @override
  Future<CacheEntry?> getCacheEntry(String entryId) async {
    return _cacheEntries[entryId];
  }

  @override
  Future<List<CacheEntry>> getAllCacheEntries() async {
    return _cacheEntries.values.toList();
  }

  @override
  Future<void> removeCacheEntry(String entryId) async {
    _cacheEntries.remove(entryId);
  }

  @override
  Future<OptimizationRecommendation> addRecommendation(OptimizationRecommendation rec) async {
    _recommendations[rec.recommendationId] = rec;
    return rec;
  }

  @override
  Future<List<OptimizationRecommendation>> getPendingRecommendations() async {
    return _recommendations.values.where((r) => !r.isApplied).toList();
  }

  @override
  Future<BottleneckAnalysis> addBottleneck(BottleneckAnalysis analysis) async {
    _bottlenecks[analysis.bottleneckId] = analysis;
    return analysis;
  }

  @override
  Future<List<BottleneckAnalysis>> getActiveBottlenecks() async {
    return _bottlenecks.values.where((b) => b.isCritical).toList();
  }

  @override
  Future<void> clearAll() async {
    _metrics.clear();
    _cacheEntries.clear();
    _recommendations.clear();
    _bottlenecks.clear();
  }
}

/// 最適化エンジン インターフェース
abstract class OptimizationEngine {
  Future<PerformanceAnalysis> analyzeMetrics(List<PerformanceData> metrics);
  Future<List<BottleneckAnalysis>> detectBottlenecks(List<PerformanceData> metrics);
  Future<List<OptimizationRecommendation>> generateRecommendations(PerformanceAnalysis analysis);
  Future<CacheStats> calculateCacheStats(List<CacheEntry> entries, int hits, int misses);
  Future<PerformanceStats> calculateStats(List<PerformanceData> metrics, CacheStats cacheStats);
}

/// メモリ最適化エンジン実装
class MemoryOptimizationEngine implements OptimizationEngine {
  @override
  Future<PerformanceAnalysis> analyzeMetrics(List<PerformanceData> metrics) async {
    if (metrics.isEmpty) {
      return PerformanceAnalysis(
        analysisId: 'analysis_${DateTime.now().millisecondsSinceEpoch}',
        dataPoints: [],
        periodStart: DateTime.now(),
        periodEnd: DateTime.now(),
        averageValue: 0.0,
        peakValue: 0.0,
        minValue: 0.0,
        standardDeviation: 0.0,
      );
    }

    final values = metrics.map((m) => m.value).toList();
    final average = values.fold<double>(0, (s, v) => s + v) / values.length;
    final peak = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);

    final variance = values.fold<double>(0, (s, v) => s + (v - average) * (v - average)) / values.length;
    final stdDev = variance > 0 ? (variance.sqrt() as double) : 0.0;

    return PerformanceAnalysis(
      analysisId: 'analysis_${DateTime.now().millisecondsSinceEpoch}',
      dataPoints: metrics,
      periodStart: metrics.first.recordedAt,
      periodEnd: metrics.last.recordedAt,
      averageValue: average,
      peakValue: peak,
      minValue: min,
      standardDeviation: stdDev,
    );
  }

  @override
  Future<List<BottleneckAnalysis>> detectBottlenecks(List<PerformanceData> metrics) async {
    final bottlenecks = <BottleneckAnalysis>[];

    for (final metricType in PerformanceMetricType.values) {
      final typeMetrics = metrics.where((m) => m.metricType == metricType).toList();
      if (typeMetrics.isEmpty) continue;

      final values = typeMetrics.map((m) => m.value).toList();
      final average = values.fold<double>(0, (s, v) => s + v) / values.length;

      if (average > 75.0) {
        final severity = (average - 50) / 50.0;
        bottlenecks.add(
          BottleneckAnalysis(
            bottleneckId: 'bn_${DateTime.now().millisecondsSinceEpoch}',
            resourceName: metricType.value,
            metricType: metricType,
            severity: severity.clamp(0.0, 1.0),
            description: 'High ${ metricType.value}: ${ average.toStringAsFixed(1) }%',
            detectedAt: DateTime.now(),
            recommendations: [],
          ),
        );
      }
    }

    return bottlenecks;
  }

  @override
  Future<List<OptimizationRecommendation>> generateRecommendations(PerformanceAnalysis analysis) async {
    final recommendations = <OptimizationRecommendation>[];

    if (analysis.hasHighVariance) {
      recommendations.add(
        OptimizationRecommendation(
          recommendationId: 'rec_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Implement Request Batching',
          description: 'High variance detected. Consider batching requests.',
          level: OptimizationLevel.medium,
          estimatedImprovement: 15.0,
          createdAt: DateTime.now(),
        ),
      );
    }

    if (analysis.averageValue > 70.0) {
      recommendations.add(
        OptimizationRecommendation(
          recommendationId: 'rec_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Optimize Query Performance',
          description: 'Average usage is high. Optimize database queries.',
          level: OptimizationLevel.high,
          estimatedImprovement: 25.0,
          createdAt: DateTime.now(),
        ),
      );
    }

    return recommendations;
  }

  @override
  Future<CacheStats> calculateCacheStats(List<CacheEntry> entries, int hits, int misses) async {
    final validEntries = entries.where((e) => e.isValid).length;
    final expiredEntries = entries.where((e) => e.isExpired).length;
    final totalSize = entries.fold<int>(0, (sum, e) => sum + (e.sizeByte ?? 0));

    return CacheStats(
      statsId: 'cs_${DateTime.now().millisecondsSinceEpoch}',
      totalEntries: entries.length,
      validEntries: validEntries,
      expiredEntries: expiredEntries,
      hits: hits,
      misses: misses,
      totalSizeBytes: totalSize,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<PerformanceStats> calculateStats(List<PerformanceData> metrics, CacheStats cacheStats) async {
    final averageMetrics = <PerformanceMetricType, double>{};
    final peakMetrics = <PerformanceMetricType, double>{};

    for (final metricType in PerformanceMetricType.values) {
      final typeMetrics = metrics.where((m) => m.metricType == metricType).toList();
      if (typeMetrics.isEmpty) continue;

      final values = typeMetrics.map((m) => m.value).toList();
      final average = values.fold<double>(0, (s, v) => s + v) / values.length;
      final peak = values.reduce((a, b) => a > b ? a : b);

      averageMetrics[metricType] = average;
      peakMetrics[metricType] = peak;
    }

    final overallAverage = averageMetrics.values.fold<double>(0, (s, v) => s + v) / (averageMetrics.length > 0 ? averageMetrics.length : 1);
    final healthScore = 1.0 - (overallAverage / 100.0);

    return PerformanceStats(
      statsId: 'ps_${DateTime.now().millisecondsSinceEpoch}',
      periodStart: DateTime.now().subtract(Duration(hours: 1)),
      periodEnd: DateTime.now(),
      averageMetrics: averageMetrics,
      peakMetrics: peakMetrics,
      overallHealthScore: healthScore.clamp(0.0, 1.0),
      totalAnomalies: metrics.where((m) => m.isAnomalous).length,
      cacheHitRate: cacheStats.hitRate,
    );
  }
}

/// パフォーマンスマネージャー インターフェース
abstract class PerformanceManager {
  Future<PerformanceData> recordMetric(PerformanceMetricType type, double value);
  Future<void> updateCache(String key, dynamic value, CacheStrategy strategy);
  Future<void> invalidateCache(String key);
  Future<PerformanceReport> generateReport(String reportId, DateTime start, DateTime end);
  Future<List<OptimizationRecommendation>> getRecommendations();
}

/// メモリパフォーマンスマネージャー実装
class MemoryPerformanceManager implements PerformanceManager {
  final PerformanceRepository repository;
  final OptimizationEngine engine;
  int cacheHits = 0;
  int cacheMisses = 0;

  MemoryPerformanceManager({
    required this.repository,
    required this.engine,
  });

  @override
  Future<PerformanceData> recordMetric(PerformanceMetricType type, double value) async {
    final data = PerformanceData(
      metricId: 'metric_${DateTime.now().millisecondsSinceEpoch}',
      metricType: type,
      value: value,
      recordedAt: DateTime.now(),
    );
    return repository.addMetric(data);
  }

  @override
  Future<void> updateCache(String key, dynamic value, CacheStrategy strategy) async {
    final entry = CacheEntry(
      entryId: 'cache_${DateTime.now().millisecondsSinceEpoch}',
      key: key,
      value: value,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(hours: 1)),
      strategy: strategy,
    );
    await repository.addCacheEntry(entry);
    cacheHits++;
  }

  @override
  Future<void> invalidateCache(String key) async {
    final entries = await repository.getAllCacheEntries();
    for (final entry in entries.where((e) => e.key == key)) {
      await repository.removeCacheEntry(entry.entryId);
    }
    cacheMisses++;
  }

  @override
  Future<PerformanceReport> generateReport(String reportId, DateTime start, DateTime end) async {
    final metrics = await repository.getMetricsByTimeRange(start, end);
    final cacheEntries = await repository.getAllCacheEntries();
    final bottlenecks = await repository.getActiveBottlenecks();

    final analysis = await engine.analyzeMetrics(metrics);
    final cacheStats = await engine.calculateCacheStats(cacheEntries, cacheHits, cacheMisses);
    final stats = await engine.calculateStats(metrics, cacheStats);
    final recommendations = await engine.generateRecommendations(analysis);

    return PerformanceReport(
      reportId: reportId,
      generatedAt: DateTime.now(),
      periodStart: start,
      periodEnd: end,
      stats: stats,
      bottlenecks: bottlenecks,
      recommendations: recommendations,
    );
  }

  @override
  Future<List<OptimizationRecommendation>> getRecommendations() async {
    return repository.getPendingRecommendations();
  }
}

/// パフォーマンス管理ファサード
class PerformanceFacade {
  late final PerformanceRepository repository;
  late final OptimizationEngine engine;
  late final MemoryPerformanceManager manager;

  PerformanceFacade({
    PerformanceRepository? customRepository,
    OptimizationEngine? customEngine,
  }) {
    repository = customRepository ?? MemoryPerformanceRepository();
    engine = customEngine ?? MemoryOptimizationEngine();
    manager = MemoryPerformanceManager(repository: repository, engine: engine);
  }

  Future<PerformanceData> recordMetric(PerformanceMetricType type, double value) async {
    return manager.recordMetric(type, value);
  }

  Future<void> updateCache(String key, dynamic value, CacheStrategy strategy) async {
    return manager.updateCache(key, value, strategy);
  }

  Future<void> invalidateCache(String key) async {
    return manager.invalidateCache(key);
  }

  Future<PerformanceReport> generateReport(String reportId, DateTime start, DateTime end) async {
    return manager.generateReport(reportId, start, end);
  }

  Future<List<OptimizationRecommendation>> getRecommendations() async {
    return manager.getRecommendations();
  }

  Future<List<CacheEntry>> getAllCacheEntries() async {
    return repository.getAllCacheEntries();
  }

  Future<PerformanceData?> getMetric(String metricId) async {
    return repository.getMetric(metricId);
  }
}
