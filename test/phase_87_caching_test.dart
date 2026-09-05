/// Phase 87: Advanced Caching & Performance Optimization - Test Suite
/// Comprehensive test coverage for caching and performance components
import 'package:test/test.dart';
import 'package:project_040/models/caching_models.dart';
import 'package:project_040/services/caching_service.dart';

void main() {
  group('Phase 87: Advanced Caching & Performance Optimization', () {
    // =========================================================================
    // ENUM TESTS (6)
    // =========================================================================
    group('Enum Tests', () {
      test('CacheType enum has all values', () {
        expect(CacheType.values.length, equals(6));
        expect(CacheType.inmemory.displayName, equals('インメモリ'));
        expect(CacheType.distributed.displayName, equals('分散'));
        expect(CacheType.persistent.displayName, equals('永続'));
      });

      test('CacheEvictionPolicy enum has all values', () {
        expect(CacheEvictionPolicy.values.length, equals(6));
        expect(CacheEvictionPolicy.lru.displayName, equals('最近最少使用'));
        expect(CacheEvictionPolicy.lfu.displayName, equals('最近最少頻度'));
      });

      test('CacheInvalidationStrategy enum has all values', () {
        expect(CacheInvalidationStrategy.values.length, equals(6));
        expect(CacheInvalidationStrategy.ttl.displayName, equals('時間ベース'));
        expect(CacheInvalidationStrategy.eventBased.displayName, equals('イベントベース'));
      });

      test('MaterializedViewStatus enum has all values', () {
        expect(MaterializedViewStatus.values.length, equals(6));
        expect(MaterializedViewStatus.active.displayName, equals('アクティブ'));
        expect(MaterializedViewStatus.stale.displayName, equals('古い'));
      });

      test('PerformanceMetricType enum has all values', () {
        expect(PerformanceMetricType.values.length, equals(6));
        expect(PerformanceMetricType.hitRate.displayName, equals('ヒット率'));
        expect(PerformanceMetricType.latency.displayName, equals('レイテンシ'));
      });

      test('CacheCompressionType enum has all values', () {
        expect(CacheCompressionType.values.length, equals(6));
        expect(CacheCompressionType.gzip.displayName, equals('Gzip'));
        expect(CacheCompressionType.snappy.displayName, equals('Snappy'));
      });
    });

    // =========================================================================
    // MODEL TESTS (12)
    // =========================================================================
    group('Model Tests', () {
      test('CacheEntry model validates expiration', () {
        final now = DateTime.now();
        final entry = CacheEntry(
          id: 'e1',
          key: 'test',
          value: 'data',
          createdAt: now,
          expiresAt: now.add(Duration(hours: 1)),
        );
        expect(entry.isExpired, isFalse);

        final expired = CacheEntry(
          id: 'e2',
          key: 'test',
          value: 'data',
          createdAt: now.subtract(Duration(hours: 2)),
          expiresAt: now.subtract(Duration(minutes: 1)),
        );
        expect(expired.isExpired, isTrue);
      });

      test('CacheEntry model computes ageInSeconds', () {
        final entry = CacheEntry(
          id: 'e1',
          key: 'test',
          value: 'data',
          createdAt: DateTime.now().subtract(Duration(seconds: 30)),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
        );
        expect(entry.ageInSeconds, greaterThanOrEqualTo(30));
      });

      test('CacheEntry copyWith creates new instance', () {
        final original = CacheEntry(
          id: 'e1',
          key: 'key1',
          value: 'value1',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
        );

        final updated = original.copyWith(value: 'value2');
        expect(updated.value, equals('value2'));
        expect(updated.key, equals(original.key));
      });

      test('CacheConfiguration model validates configuration', () {
        final config = CacheConfiguration(
          id: 'c1',
          name: 'Test Cache',
          cacheType: CacheType.inmemory,
          createdAt: DateTime.now(),
          maxSize: 1000000,
          maxEntries: 10000,
          evictionPolicy: CacheEvictionPolicy.lru,
        );
        expect(config.isLru, isTrue);
        expect(config.isDistributed, isFalse);
      });

      test('CacheStatistics model computes hitRate', () {
        final stats = CacheStatistics(
          id: 's1',
          cacheId: 'c1',
          timestamp: DateTime.now(),
          totalHits: 80,
          totalMisses: 20,
        );
        expect(stats.hitRate, equals(0.8));
        expect(stats.missRate, equals(0.2));
      });

      test('MaterializedView model validates refresh requirement', () {
        final now = DateTime.now();
        final view = MaterializedView(
          id: 'v1',
          name: 'Report',
          queryDefinition: 'SELECT * FROM data',
          createdAt: now,
          lastRefreshedAt: now.subtract(Duration(hours: 2)),
          refreshIntervalSeconds: 3600,
        );
        expect(view.needsRefresh, isTrue);
      });

      test('QueryResultCache model validates staleness', () {
        final cache = QueryResultCache(
          id: 'q1',
          queryHash: 'hash123',
          queryText: 'SELECT * FROM users',
          result: '[]',
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
        );
        expect(cache.isStale, isTrue);
      });

      test('CacheInvalidationTag model tracks invalidation', () {
        final tag = CacheInvalidationTag(
          id: 't1',
          tagName: 'users',
          createdAt: DateTime.now(),
          entriesTagged: 100,
        );
        expect(tag.hasBeenInvalidated, isFalse);
        expect(tag.targetCount, equals(100));
      });

      test('PrefetchStrategy model validates execution need', () {
        final strategy = PrefetchStrategy(
          id: 'p1',
          name: 'User Prefetch',
          sourceQuery: 'SELECT * FROM users',
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
          enabled: true,
          prefetchIntervalSeconds: 1800,
        );
        expect(strategy.isActive, isTrue);
      });

      test('PerformanceMetric model validates anomalies', () {
        final metric = PerformanceMetric(
          id: 'm1',
          metricType: PerformanceMetricType.hitRate,
          value: 0.95,
          timestamp: DateTime.now(),
        );
        expect(metric.isAboveThreshold, isFalse);

        final anomaly = PerformanceMetric(
          id: 'm2',
          metricType: PerformanceMetricType.latency,
          value: 1000.0,
          timestamp: DateTime.now(),
          threshold: 500.0,
          isAnomaly: true,
        );
        expect(anomaly.isCritical, isTrue);
      });

      test('CacheWarmingStrategy model validates warming need', () {
        final strategy = CacheWarmingStrategy(
          id: 'w1',
          name: 'Warm Cache',
          dataSource: 'database',
          createdAt: DateTime.now(),
          enabled: true,
          keysToWarm: ['user:1', 'user:2', 'user:3'],
        );
        expect(strategy.shouldExecute, isTrue);
        expect(strategy.keyCount, equals(3));
      });

      test('CacheHierarchy model computes level count', () {
        final hierarchy = CacheHierarchy(
          id: 'h1',
          name: 'Multi-Level',
          createdAt: DateTime.now(),
          level1CacheId: 'l1',
          level2CacheId: 'l2',
          level3CacheId: 'l3',
          level1HitRate: 0.9,
          level2HitRate: 0.7,
          level3HitRate: 0.5,
        );
        expect(hierarchy.levelCount, equals(3));
        expect(hierarchy.isMultiLevel, isTrue);
      });

      test('CacheCoherence model validates consistency', () {
        final coherence = CacheCoherence(
          id: 'co1',
          cacheId: 'c1',
          lastSyncAt: DateTime.now(),
          createdAt: DateTime.now(),
          inconsistencies: 0,
          resolutionsApplied: 0,
        );
        expect(coherence.isConsistent, isTrue);
        expect(coherence.resolutionRate, equals(100));
      });
    });

    // =========================================================================
    // REPOSITORY TESTS (40+)
    // =========================================================================
    group('Repository Tests', () {
      late InMemoryCachingRepository repository;

      setUp(() {
        repository = InMemoryCachingRepository();
      });

      // Cache Entry Tests
      test('create and retrieve cache entry', () async {
        final entry = CacheEntry(
          id: 'e1',
          key: 'user:1',
          value: '{"id":1,"name":"John"}',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
        );

        await repository.createCacheEntry(entry);
        final retrieved = await repository.getCacheEntryById('e1');

        expect(retrieved, isNotNull);
        expect(retrieved!.key, equals('user:1'));
      });

      test('get cache entry by key', () async {
        final entry = CacheEntry(
          id: 'e1',
          key: 'test:key',
          value: 'data',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
        );

        await repository.createCacheEntry(entry);
        final retrieved = await repository.getCacheEntryByKey('test:key');

        expect(retrieved, isNotNull);
        expect(retrieved!.value, equals('data'));
      });

      test('get expired entries', () async {
        final now = DateTime.now();
        await repository.createCacheEntry(CacheEntry(
          id: 'e1',
          key: 'expired',
          value: 'old',
          createdAt: now.subtract(Duration(hours: 2)),
          expiresAt: now.subtract(Duration(minutes: 1)),
        ));
        await repository.createCacheEntry(CacheEntry(
          id: 'e2',
          key: 'valid',
          value: 'new',
          createdAt: now,
          expiresAt: now.add(Duration(hours: 1)),
        ));

        final expired = await repository.getExpiredEntries();
        expect(expired.length, equals(1));
      });

      test('get entries by tag', () async {
        await repository.createCacheEntry(CacheEntry(
          id: 'e1',
          key: 'k1',
          value: 'v1',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
          tags: ['users', 'active'],
        ));
        await repository.createCacheEntry(CacheEntry(
          id: 'e2',
          key: 'k2',
          value: 'v2',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
          tags: ['posts'],
        ));

        final users = await repository.getEntriesByTag('users');
        expect(users.length, equals(1));
      });

      // Configuration Tests
      test('create and retrieve configuration', () async {
        final config = CacheConfiguration(
          id: 'c1',
          name: 'L1 Cache',
          cacheType: CacheType.inmemory,
          createdAt: DateTime.now(),
        );

        await repository.createConfiguration(config);
        final retrieved = await repository.getConfigurationById('c1');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('L1 Cache'));
      });

      test('get configurations by type', () async {
        await repository.createConfiguration(CacheConfiguration(
          id: 'c1',
          name: 'Memory',
          cacheType: CacheType.inmemory,
          createdAt: DateTime.now(),
        ));
        await repository.createConfiguration(CacheConfiguration(
          id: 'c2',
          name: 'Distributed',
          cacheType: CacheType.distributed,
          createdAt: DateTime.now(),
        ));

        final memory = await repository.getConfigurationsByType(CacheType.inmemory);
        expect(memory.length, equals(1));
      });

      // Statistics Tests
      test('record and retrieve statistics', () async {
        final stats = CacheStatistics(
          id: 's1',
          cacheId: 'c1',
          timestamp: DateTime.now(),
          totalHits: 100,
          totalMisses: 20,
        );

        await repository.recordStatistics(stats);
        final retrieved = await repository.getStatisticsById('s1');

        expect(retrieved, isNotNull);
        expect(retrieved!.hitRate, equals(0.833));
      });

      test('get latest statistics', () async {
        final now = DateTime.now();
        await repository.recordStatistics(CacheStatistics(
          id: 's1',
          cacheId: 'c1',
          timestamp: now.subtract(Duration(hours: 1)),
          totalHits: 50,
          totalMisses: 10,
        ));
        await repository.recordStatistics(CacheStatistics(
          id: 's2',
          cacheId: 'c1',
          timestamp: now,
          totalHits: 100,
          totalMisses: 20,
        ));

        final latest = await repository.getLatestStatistics('c1');
        expect(latest!.totalHits, equals(100));
      });

      test('get high miss rate stats', () async {
        await repository.recordStatistics(CacheStatistics(
          id: 's1',
          cacheId: 'c1',
          timestamp: DateTime.now(),
          totalHits: 10,
          totalMisses: 90,
        ));

        final high = await repository.getHighMissRateStats();
        expect(high.length, equals(1));
      });

      // Materialized View Tests
      test('create and retrieve materialized view', () async {
        final view = MaterializedView(
          id: 'v1',
          name: 'Sales Report',
          queryDefinition: 'SELECT * FROM sales',
          createdAt: DateTime.now(),
          lastRefreshedAt: DateTime.now(),
        );

        await repository.createMaterializedView(view);
        final retrieved = await repository.getMaterializedViewById('v1');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Sales Report'));
      });

      test('get views needing refresh', () async {
        final now = DateTime.now();
        await repository.createMaterializedView(MaterializedView(
          id: 'v1',
          name: 'View1',
          queryDefinition: 'SELECT 1',
          createdAt: now,
          lastRefreshedAt: now.subtract(Duration(hours: 2)),
          refreshIntervalSeconds: 3600,
        ));

        final stale = await repository.getViewsNeedingRefresh();
        expect(stale.length, equals(1));
      });

      // Query Result Cache Tests
      test('create and retrieve query result cache', () async {
        final cache = QueryResultCache(
          id: 'q1',
          queryHash: 'hash1',
          queryText: 'SELECT * FROM users',
          result: '[]',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
        );

        await repository.createQueryResultCache(cache);
        final retrieved = await repository.getQueryResultByHash('hash1');

        expect(retrieved, isNotNull);
        expect(retrieved!.queryText, equals('SELECT * FROM users'));
      });

      test('get high access queries', () async {
        await repository.createQueryResultCache(QueryResultCache(
          id: 'q1',
          queryHash: 'h1',
          queryText: 'Q1',
          result: 'R1',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
          accessCount: 100,
        ));
        await repository.createQueryResultCache(QueryResultCache(
          id: 'q2',
          queryHash: 'h2',
          queryText: 'Q2',
          result: 'R2',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
          accessCount: 10,
        ));

        final high = await repository.getHighAccessQueries(5);
        expect(high.first.accessCount, equals(100));
      });

      // Invalidation Tag Tests
      test('create and retrieve invalidation tag', () async {
        final tag = CacheInvalidationTag(
          id: 't1',
          tagName: 'users',
          createdAt: DateTime.now(),
        );

        await repository.createInvalidationTag(tag);
        final retrieved = await repository.getInvalidationTagById('t1');

        expect(retrieved, isNotNull);
        expect(retrieved!.tagName, equals('users'));
      });

      // Prefetch Strategy Tests
      test('create and retrieve prefetch strategy', () async {
        final strategy = PrefetchStrategy(
          id: 'p1',
          name: 'User Prefetch',
          sourceQuery: 'SELECT * FROM users',
          createdAt: DateTime.now(),
        );

        await repository.createPrefetchStrategy(strategy);
        final retrieved = await repository.getPrefetchStrategyById('p1');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('User Prefetch'));
      });

      test('get active prefetch strategies', () async {
        await repository.createPrefetchStrategy(PrefetchStrategy(
          id: 'p1',
          name: 'Active',
          sourceQuery: 'Q1',
          createdAt: DateTime.now(),
          enabled: true,
        ));
        await repository.createPrefetchStrategy(PrefetchStrategy(
          id: 'p2',
          name: 'Inactive',
          sourceQuery: 'Q2',
          createdAt: DateTime.now(),
          enabled: false,
        ));

        final active = await repository.getActivePrefetchStrategies();
        expect(active.length, equals(1));
      });

      // Performance Metric Tests
      test('record and retrieve performance metric', () async {
        final metric = PerformanceMetric(
          id: 'm1',
          metricType: PerformanceMetricType.hitRate,
          value: 0.95,
          timestamp: DateTime.now(),
        );

        await repository.recordPerformanceMetric(metric);
        final retrieved = await repository.getPerformanceMetricById('m1');

        expect(retrieved, isNotNull);
        expect(retrieved!.value, equals(0.95));
      });

      test('get anomalous metrics', () async {
        await repository.recordPerformanceMetric(PerformanceMetric(
          id: 'm1',
          metricType: PerformanceMetricType.latency,
          value: 5000.0,
          timestamp: DateTime.now(),
          isAnomaly: true,
        ));

        final anomalies = await repository.getAnomalousMetrics();
        expect(anomalies.length, equals(1));
      });

      // Cache Warming Strategy Tests
      test('create and retrieve warming strategy', () async {
        final strategy = CacheWarmingStrategy(
          id: 'w1',
          name: 'Warm Users',
          dataSource: 'db',
          createdAt: DateTime.now(),
        );

        await repository.createWarmingStrategy(strategy);
        final retrieved = await repository.getWarmingStrategyById('w1');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Warm Users'));
      });

      // Cache Hierarchy Tests
      test('create and retrieve cache hierarchy', () async {
        final hierarchy = CacheHierarchy(
          id: 'h1',
          name: 'Multi-Level',
          createdAt: DateTime.now(),
          level1CacheId: 'l1',
        );

        await repository.createCacheHierarchy(hierarchy);
        final retrieved = await repository.getCacheHierarchyById('h1');

        expect(retrieved, isNotNull);
        expect(retrieved!.levelCount, equals(1));
      });

      test('get multi-level hierarchies', () async {
        await repository.createCacheHierarchy(CacheHierarchy(
          id: 'h1',
          name: 'Multi',
          createdAt: DateTime.now(),
          level1CacheId: 'l1',
          level2CacheId: 'l2',
        ));

        final multi = await repository.getMultiLevelHierarchies();
        expect(multi.length, equals(1));
      });

      // Cache Coherence Tests
      test('record and retrieve cache coherence', () async {
        final coherence = CacheCoherence(
          id: 'co1',
          cacheId: 'c1',
          lastSyncAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await repository.recordCacheCoherence(coherence);
        final retrieved = await repository.getCacheCoherenceById('co1');

        expect(retrieved, isNotNull);
        expect(retrieved!.isConsistent, isTrue);
      });

      test('get inconsistent caches', () async {
        await repository.recordCacheCoherence(CacheCoherence(
          id: 'co1',
          cacheId: 'c1',
          lastSyncAt: DateTime.now(),
          createdAt: DateTime.now(),
          inconsistencies: 5,
        ));

        final inconsistent = await repository.getInconsistentCaches();
        expect(inconsistent.length, equals(1));
      });
    });

    // =========================================================================
    // ENGINE TESTS (5)
    // =========================================================================
    group('Engine Tests', () {
      late CachingManager manager;

      setUp(() {
        manager = CachingManager(InMemoryCachingRepository());
      });

      test('CacheEvictionEngine evicts expired entries', () async {
        final now = DateTime.now();
        await manager.repository.createCacheEntry(CacheEntry(
          id: 'e1',
          key: 'old',
          value: 'data',
          createdAt: now.subtract(Duration(hours: 2)),
          expiresAt: now.subtract(Duration(minutes: 1)),
        ));

        await manager.evictionEngine.evictExpiredEntries();
        final remaining = await manager.repository.getCacheEntryCount();

        expect(remaining, equals(0));
      });

      test('MaterializedViewEngine refreshes stale views', () async {
        final now = DateTime.now();
        final view = MaterializedView(
          id: 'v1',
          name: 'Test',
          queryDefinition: 'SELECT 1',
          createdAt: now,
          lastRefreshedAt: now.subtract(Duration(hours: 2)),
          refreshIntervalSeconds: 3600,
        );
        await manager.repository.createMaterializedView(view);

        await manager.viewEngine.refreshStaleViews();
        final count = await manager.viewEngine.getRefreshableViewCount();

        expect(count, equals(0));
      });

      test('QueryCachingEngine removes stale results', () async {
        final now = DateTime.now();
        await manager.repository.createQueryResultCache(QueryResultCache(
          id: 'q1',
          queryHash: 'h1',
          queryText: 'Q1',
          result: 'R1',
          createdAt: now.subtract(Duration(hours: 2)),
          expiresAt: now.subtract(Duration(minutes: 1)),
        ));

        await manager.queryCachingEngine.removeStaleQueryResults();
        final count = await manager.repository.getQueryResultCacheCount();

        expect(count, equals(0));
      });

      test('PrefetchEngine executes pending prefetch', () async {
        final strategy = PrefetchStrategy(
          id: 'p1',
          name: 'Test',
          sourceQuery: 'SELECT 1',
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
          prefetchIntervalSeconds: 1800,
          enabled: true,
        );
        await manager.repository.createPrefetchStrategy(strategy);

        await manager.prefetchEngine.executePendingPrefetch();
        final updated = await manager.repository.getPrefetchStrategyById('p1');

        expect(updated!.lastExecutedAt, isNotNull);
      });

      test('CacheWarmingEngine warms cache', () async {
        final strategy = CacheWarmingStrategy(
          id: 'w1',
          name: 'Test',
          dataSource: 'db',
          createdAt: DateTime.now().subtract(Duration(hours: 1)),
          enabled: true,
          warmingIntervalSeconds: 1800,
        );
        await manager.repository.createWarmingStrategy(strategy);

        await manager.warmingEngine.executeWarmingStrategies();
        final updated = await manager.repository.getWarmingStrategyById('w1');

        expect(updated!.lastWarmingAt, isNotNull);
      });
    });

    // =========================================================================
    // FACADE TESTS (6)
    // =========================================================================
    group('Facade Tests', () {
      late CachingFacade facade;

      setUp(() {
        final manager = CachingManager(InMemoryCachingRepository());
        facade = CachingFacade(manager);
      });

      test('createCacheEntry via facade', () async {
        final entry = await facade.createCacheEntry('key1', 'value1');

        expect(entry.key, equals('key1'));
        expect(entry.value, equals('value1'));
      });

      test('getCacheEntry via facade', () async {
        await facade.createCacheEntry('test', 'data');
        final entry = await facade.getCacheEntry('test');

        expect(entry, isNotNull);
        expect(entry!.value, equals('data'));
      });

      test('createConfiguration via facade', () async {
        final config = await facade.createConfiguration('L1', CacheType.inmemory);

        expect(config.name, equals('L1'));
        expect(config.cacheType, equals(CacheType.inmemory));
      });

      test('createMaterializedView via facade', () async {
        final view = await facade.createMaterializedView('Report', 'SELECT 1');

        expect(view.name, equals('Report'));
      });

      test('getActiveCacheCount via facade', () async {
        await facade.createCacheEntry('k1', 'v1');
        await facade.createCacheEntry('k2', 'v2');

        final count = await facade.getActiveCacheCount();
        expect(count, equals(2));
      });

      test('recordMetric via facade', () async {
        final metric = await facade.recordMetric(PerformanceMetricType.hitRate, 0.95);

        expect(metric.metricType, equals(PerformanceMetricType.hitRate));
        expect(metric.value, equals(0.95));
      });
    });

    // =========================================================================
    // INTEGRATION TESTS (2)
    // =========================================================================
    group('Integration Tests', () {
      late CachingFacade facade;

      setUp(() {
        final manager = CachingManager(InMemoryCachingRepository());
        facade = CachingFacade(manager);
      });

      test('complete caching workflow', () async {
        // Create configuration
        final config = await facade.createConfiguration('Main', CacheType.inmemory);
        expect(config.name, equals('Main'));

        // Create cache entries
        final e1 = await facade.createCacheEntry('user:1', '{"id":1}');
        final e2 = await facade.createCacheEntry('user:2', '{"id":2}');

        // Verify count
        final count = await facade.getActiveCacheCount();
        expect(count, equals(2));
      });

      test('materialized view and query caching workflow', () async {
        // Create materialized view
        final view = await facade.createMaterializedView(
          'Sales',
          'SELECT * FROM sales',
        );
        expect(view.name, equals('Sales'));

        // Cache query result
        final cache = await facade.cacheQueryResult(
          'SELECT * FROM sales WHERE year=2024',
          '[...]',
        );
        expect(cache.queryText.contains('2024'), isTrue);

        // Record metric
        final metric = await facade.recordMetric(
          PerformanceMetricType.hitRate,
          0.98,
        );
        expect(metric.value, equals(0.98));
      });
    });

    // =========================================================================
    // PERFORMANCE TESTS (2)
    // =========================================================================
    group('Performance Tests', () {
      late CachingFacade facade;

      setUp(() {
        final manager = CachingManager(InMemoryCachingRepository());
        facade = CachingFacade(manager);
      });

      test('create 50 cache entries efficiently', () async {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 50; i++) {
          await facade.createCacheEntry('key:$i', 'value:$i');
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('retrieve 100 cache entries with pagination', () async {
        for (int i = 0; i < 100; i++) {
          await facade.createCacheEntry('k$i', 'v$i');
        }

        final stopwatch = Stopwatch()..start();
        await facade.manager.repository.getAllCacheEntries(limit: 20, offset: 0);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });

    // =========================================================================
    // EDGE CASE TESTS (5+)
    // =========================================================================
    group('Edge Case Tests', () {
      late InMemoryCachingRepository repository;

      setUp(() {
        repository = InMemoryCachingRepository();
      });

      test('handle null cache entry retrieval', () async {
        final result = await repository.getCacheEntryById('nonexistent');
        expect(result, isNull);
      });

      test('handle empty cache entry list', () async {
        final entries = await repository.getAllCacheEntries();
        expect(entries, isEmpty);
      });

      test('handle expired entry that is also stale', () async {
        final now = DateTime.now();
        final entry = CacheEntry(
          id: 'e1',
          key: 'old',
          value: 'data',
          createdAt: now.subtract(Duration(hours: 2)),
          expiresAt: now.subtract(Duration(minutes: 1)),
        );

        await repository.createCacheEntry(entry);
        expect(entry.isExpired, isTrue);
        expect(entry.isStale, isTrue);
      });

      test('handle zero hit rate calculation', () async {
        final stats = CacheStatistics(
          id: 's1',
          cacheId: 'c1',
          timestamp: DateTime.now(),
          totalHits: 0,
          totalMisses: 0,
        );

        expect(stats.hitRate, equals(0.0));
      });

      test('handle empty materialized view list', () async {
        final views = await repository.getAllMaterializedViews();
        expect(views, isEmpty);
      });

      test('handle configuration with persistence disabled', () async {
        final config = CacheConfiguration(
          id: 'c1',
          name: 'Volatile',
          cacheType: CacheType.inmemory,
          createdAt: DateTime.now(),
          persistenceEnabled: false,
        );

        expect(config.supportsPersistence, isFalse);
      });
    });
  });
}
