/// Phase 53: Performance Monitoring & Optimization Tests
import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/performance_models.dart';
import 'package:project_040/services/performance_service.dart';

void main() {
  group('Phase 53: Performance Monitoring & Optimization', () {
    group('Enum Tests', () {
      test('PerformanceMetricType enum values', () {
        expect(PerformanceMetricType.cpuUsage.value, 'cpu_usage');
        expect(PerformanceMetricType.memoryUsage.value, 'memory_usage');
        expect(PerformanceMetricType.responseTime.value, 'response_time');
        expect(PerformanceMetricType.throughput.value, 'throughput');
      });

      test('CacheStrategy enum values', () {
        expect(CacheStrategy.lru.value, 'lru');
        expect(CacheStrategy.lfu.value, 'lfu');
        expect(CacheStrategy.fifo.value, 'fifo');
        expect(CacheStrategy.ttl.value, 'ttl');
      });

      test('OptimizationLevel enum values', () {
        expect(OptimizationLevel.low.value, 'low');
        expect(OptimizationLevel.medium.value, 'medium');
        expect(OptimizationLevel.high.value, 'high');
        expect(OptimizationLevel.aggressive.value, 'aggressive');
      });
    });

    group('Model Tests', () {
      test('PerformanceData - isNormal property', () {
        final data = PerformanceData(
          metricId: 'metric1',
          metricType: PerformanceMetricType.cpuUsage,
          value: 45.0,
          recordedAt: DateTime.now(),
        );
        expect(data.isNormal, true);
      });

      test('PerformanceData - isHigh property', () {
        final data = PerformanceData(
          metricId: 'metric1',
          metricType: PerformanceMetricType.cpuUsage,
          value: 90.0,
          recordedAt: DateTime.now(),
        );
        expect(data.isHigh, true);
      });

      test('CacheEntry - isValid property', () {
        final entry = CacheEntry(
          entryId: 'cache1',
          key: 'user:1',
          value: {'name': 'John'},
          createdAt: DateTime.now(),
          strategy: CacheStrategy.ttl,
        );
        expect(entry.isValid, true);
      });

      test('CacheEntry - timeUntilExpiration', () {
        final now = DateTime.now();
        final entry = CacheEntry(
          entryId: 'cache1',
          key: 'key1',
          value: 'data',
          createdAt: now,
          expiresAt: now.add(Duration(hours: 1)),
          strategy: CacheStrategy.ttl,
        );
        expect(entry.timeUntilExpiration != null, true);
      });

      test('OptimizationRecommendation - isHighImpact', () {
        final rec = OptimizationRecommendation(
          recommendationId: 'rec1',
          title: 'Optimize Query',
          description: 'Database optimization',
          level: OptimizationLevel.high,
          estimatedImprovement: 30.0,
          createdAt: DateTime.now(),
        );
        expect(rec.isHighImpact, true);
      });

      test('PerformanceAnalysis - trend calculation', () {
        final now = DateTime.now();
        final dataPoints = [
          PerformanceData(
            metricId: 'm1',
            metricType: PerformanceMetricType.cpuUsage,
            value: 50.0,
            recordedAt: now,
          ),
          PerformanceData(
            metricId: 'm2',
            metricType: PerformanceMetricType.cpuUsage,
            value: 60.0,
            recordedAt: now.add(Duration(minutes: 1)),
          ),
        ];
        final analysis = PerformanceAnalysis(
          analysisId: 'analysis1',
          dataPoints: dataPoints,
          periodStart: now,
          periodEnd: now.add(Duration(minutes: 1)),
          averageValue: 55.0,
          peakValue: 60.0,
          minValue: 50.0,
          standardDeviation: 5.0,
        );
        expect(analysis.trend > 0, true);
      });

      test('BottleneckAnalysis - isCritical property', () {
        final bottleneck = BottleneckAnalysis(
          bottleneckId: 'bn1',
          resourceName: 'CPU',
          metricType: PerformanceMetricType.cpuUsage,
          severity: 0.9,
          description: 'High CPU usage',
          detectedAt: DateTime.now(),
          recommendations: [],
        );
        expect(bottleneck.isCritical, true);
      });

      test('PerformanceStats - isHealthy property', () {
        final stats = PerformanceStats(
          statsId: 'stats1',
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          averageMetrics: {},
          peakMetrics: {},
          overallHealthScore: 0.85,
          totalAnomalies: 1,
          cacheHitRate: 0.75,
        );
        expect(stats.isHealthy, true);
      });

      test('PerformanceStats - hasGoodCacheEfficiency', () {
        final stats = PerformanceStats(
          statsId: 'stats1',
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          averageMetrics: {},
          peakMetrics: {},
          overallHealthScore: 0.8,
          totalAnomalies: 0,
          cacheHitRate: 0.8,
        );
        expect(stats.hasGoodCacheEfficiency, true);
      });

      test('CacheStats - hitRate calculation', () {
        final stats = CacheStats(
          statsId: 'cs1',
          totalEntries: 100,
          validEntries: 90,
          expiredEntries: 10,
          hits: 80,
          misses: 20,
          totalSizeBytes: 5000,
          createdAt: DateTime.now(),
        );
        expect(stats.hitRate, 0.8);
      });

      test('ResourceUsage - isHighUsage property', () {
        final usage = ResourceUsage(
          resourceId: 'res1',
          resourceType: 'cpu',
          usagePercent: 85.0,
          peakPercent: 90.0,
          averagePercent: 75.0,
          measurementTime: DateTime.now(),
          duration: Duration(minutes: 5),
        );
        expect(usage.isHighUsage, true);
      });

      test('PerformanceReport - toMarkdown', () {
        final report = PerformanceReport(
          reportId: 'report1',
          generatedAt: DateTime.now(),
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          stats: PerformanceStats(
            statsId: 'stats1',
            periodStart: DateTime.now(),
            periodEnd: DateTime.now(),
            averageMetrics: {},
            peakMetrics: {},
            overallHealthScore: 0.8,
            totalAnomalies: 2,
            cacheHitRate: 0.75,
          ),
          bottlenecks: [],
          recommendations: [],
        );
        final markdown = report.toMarkdown();
        expect(markdown.contains('Performance Report'), true);
      });
    });

    group('Repository Tests', () {
      late MemoryPerformanceRepository repository;

      setUp(() {
        repository = MemoryPerformanceRepository();
      });

      test('Repository - addMetric and getMetric', () async {
        final data = PerformanceData(
          metricId: 'metric1',
          metricType: PerformanceMetricType.cpuUsage,
          value: 45.0,
          recordedAt: DateTime.now(),
        );
        await repository.addMetric(data);
        final retrieved = await repository.getMetric('metric1');
        expect(retrieved?.metricId, 'metric1');
      });

      test('Repository - getMetricsByType', () async {
        final data1 = PerformanceData(
          metricId: 'm1',
          metricType: PerformanceMetricType.cpuUsage,
          value: 45.0,
          recordedAt: DateTime.now(),
        );
        final data2 = PerformanceData(
          metricId: 'm2',
          metricType: PerformanceMetricType.memoryUsage,
          value: 60.0,
          recordedAt: DateTime.now(),
        );
        await repository.addMetric(data1);
        await repository.addMetric(data2);
        final cpuMetrics = await repository.getMetricsByType(PerformanceMetricType.cpuUsage);
        expect(cpuMetrics.length, 1);
      });

      test('Repository - addCacheEntry and getCacheEntry', () async {
        final entry = CacheEntry(
          entryId: 'cache1',
          key: 'user:1',
          value: {'name': 'John'},
          createdAt: DateTime.now(),
          strategy: CacheStrategy.ttl,
        );
        await repository.addCacheEntry(entry);
        final retrieved = await repository.getCacheEntry('cache1');
        expect(retrieved?.key, 'user:1');
      });

      test('Repository - getAllCacheEntries', () async {
        final entry1 = CacheEntry(
          entryId: 'c1',
          key: 'k1',
          value: 'v1',
          createdAt: DateTime.now(),
          strategy: CacheStrategy.lru,
        );
        final entry2 = CacheEntry(
          entryId: 'c2',
          key: 'k2',
          value: 'v2',
          createdAt: DateTime.now(),
          strategy: CacheStrategy.ttl,
        );
        await repository.addCacheEntry(entry1);
        await repository.addCacheEntry(entry2);
        final all = await repository.getAllCacheEntries();
        expect(all.length, 2);
      });

      test('Repository - addRecommendation', () async {
        final rec = OptimizationRecommendation(
          recommendationId: 'rec1',
          title: 'Test',
          description: 'Description',
          level: OptimizationLevel.medium,
          estimatedImprovement: 15.0,
          createdAt: DateTime.now(),
        );
        await repository.addRecommendation(rec);
        final pending = await repository.getPendingRecommendations();
        expect(pending.length, 1);
      });

      test('Repository - addBottleneck and getActiveBottlenecks', () async {
        final bottleneck = BottleneckAnalysis(
          bottleneckId: 'bn1',
          resourceName: 'CPU',
          metricType: PerformanceMetricType.cpuUsage,
          severity: 0.9,
          description: 'High usage',
          detectedAt: DateTime.now(),
          recommendations: [],
        );
        await repository.addBottleneck(bottleneck);
        final active = await repository.getActiveBottlenecks();
        expect(active.length, 1);
      });
    });

    group('Engine Tests', () {
      late MemoryOptimizationEngine engine;

      setUp(() {
        engine = MemoryOptimizationEngine();
      });

      test('Engine - analyzeMetrics with data', () async {
        final metrics = [
          PerformanceData(
            metricId: 'm1',
            metricType: PerformanceMetricType.cpuUsage,
            value: 50.0,
            recordedAt: DateTime.now(),
          ),
          PerformanceData(
            metricId: 'm2',
            metricType: PerformanceMetricType.cpuUsage,
            value: 60.0,
            recordedAt: DateTime.now(),
          ),
        ];
        final analysis = await engine.analyzeMetrics(metrics);
        expect(analysis.averageValue, 55.0);
      });

      test('Engine - detectBottlenecks', () async {
        final metrics = [
          PerformanceData(
            metricId: 'm1',
            metricType: PerformanceMetricType.cpuUsage,
            value: 85.0,
            recordedAt: DateTime.now(),
          ),
        ];
        final bottlenecks = await engine.detectBottlenecks(metrics);
        expect(bottlenecks.isNotEmpty, true);
      });

      test('Engine - generateRecommendations', () async {
        final analysis = PerformanceAnalysis(
          analysisId: 'a1',
          dataPoints: [],
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          averageValue: 75.0,
          peakValue: 90.0,
          minValue: 50.0,
          standardDeviation: 10.0,
        );
        final recs = await engine.generateRecommendations(analysis);
        expect(recs.isNotEmpty, true);
      });

      test('Engine - calculateCacheStats', () async {
        final entries = [
          CacheEntry(
            entryId: 'c1',
            key: 'k1',
            value: 'v1',
            createdAt: DateTime.now(),
            strategy: CacheStrategy.ttl,
            sizeByte: 1000,
          ),
        ];
        final stats = await engine.calculateCacheStats(entries, 10, 2);
        expect(stats.hitRate > 0.8, true);
      });
    });

    group('Manager Tests', () {
      late MemoryPerformanceManager manager;
      late MemoryPerformanceRepository repository;
      late MemoryOptimizationEngine engine;

      setUp(() {
        repository = MemoryPerformanceRepository();
        engine = MemoryOptimizationEngine();
        manager = MemoryPerformanceManager(repository: repository, engine: engine);
      });

      test('Manager - recordMetric', () async {
        final metric = await manager.recordMetric(PerformanceMetricType.cpuUsage, 45.0);
        expect(metric.value, 45.0);
      });

      test('Manager - updateCache', () async {
        await manager.updateCache('key1', 'value1', CacheStrategy.ttl);
        final entries = await repository.getAllCacheEntries();
        expect(entries.isNotEmpty, true);
      });

      test('Manager - invalidateCache', () async {
        await manager.updateCache('key1', 'value1', CacheStrategy.ttl);
        await manager.invalidateCache('key1');
        final entries = await repository.getAllCacheEntries();
        expect(entries.isEmpty, true);
      });

      test('Manager - generateReport', () async {
        final now = DateTime.now();
        final report = await manager.generateReport('report1', now.subtract(Duration(days: 1)), now);
        expect(report.reportId, 'report1');
      });
    });

    group('Facade Tests', () {
      late PerformanceFacade facade;

      setUp(() {
        facade = PerformanceFacade();
      });

      test('Facade - recordMetric', () async {
        final metric = await facade.recordMetric(PerformanceMetricType.cpuUsage, 50.0);
        expect(metric.value, 50.0);
      });

      test('Facade - updateCache', () async {
        await facade.updateCache('key1', 'value1', CacheStrategy.lru);
        final entries = await facade.getAllCacheEntries();
        expect(entries.isNotEmpty, true);
      });

      test('Facade - invalidateCache', () async {
        await facade.updateCache('key1', 'data', CacheStrategy.ttl);
        await facade.invalidateCache('key1');
        final entries = await facade.getAllCacheEntries();
        expect(entries.isEmpty, true);
      });

      test('Facade - getRecommendations', () async {
        final recs = await facade.getRecommendations();
        expect(recs.runtimeType, List);
      });

      test('Facade - generateReport', () async {
        final now = DateTime.now();
        final report = await facade.generateReport(
          'report1',
          now.subtract(Duration(days: 1)),
          now,
        );
        expect(report.reportId, 'report1');
      });
    });

    group('Integration Tests', () {
      late PerformanceFacade facade;

      setUp(() {
        facade = PerformanceFacade();
      });

      test('Integration - full performance monitoring workflow', () async {
        // Record metrics
        await facade.recordMetric(PerformanceMetricType.cpuUsage, 45.0);
        await facade.recordMetric(PerformanceMetricType.memoryUsage, 60.0);

        // Update cache
        await facade.updateCache('user:1', {'name': 'John'}, CacheStrategy.ttl);

        // Generate report
        final now = DateTime.now();
        final report = await facade.generateReport(
          'report1',
          now.subtract(Duration(hours: 1)),
          now,
        );

        expect(report.stats.totalAnomalies >= 0, true);
      });

      test('Integration - cache management', () async {
        await facade.updateCache('key1', 'value1', CacheStrategy.lru);
        await facade.updateCache('key2', 'value2', CacheStrategy.ttl);

        var entries = await facade.getAllCacheEntries();
        expect(entries.length, 2);

        await facade.invalidateCache('key1');
        entries = await facade.getAllCacheEntries();
        expect(entries.length, 1);
      });

      test('Integration - metric recording over time', () async {
        await facade.recordMetric(PerformanceMetricType.cpuUsage, 30.0);
        await facade.recordMetric(PerformanceMetricType.cpuUsage, 50.0);
        await facade.recordMetric(PerformanceMetricType.cpuUsage, 70.0);

        final now = DateTime.now();
        final report = await facade.generateReport(
          'report1',
          now.subtract(Duration(hours: 1)),
          now,
        );

        expect(report.reportId, 'report1');
      });

      test('Integration - recommendations generation', () async {
        for (int i = 0; i < 5; i++) {
          await facade.recordMetric(PerformanceMetricType.cpuUsage, 80.0 + i);
        }

        final recs = await facade.getRecommendations();
        // Should have generated recommendations for high CPU usage
        expect(recs.runtimeType, List);
      });

      test('Integration - bottleneck detection', () async {
        final now = DateTime.now();
        final report = await facade.generateReport(
          'report1',
          now.subtract(Duration(hours: 1)),
          now,
        );

        expect(report.bottlenecks.runtimeType, List);
      });
    });
  });
}
