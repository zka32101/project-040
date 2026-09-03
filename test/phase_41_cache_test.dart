import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/cache_models.dart';
import 'package:project_040/services/cache_service.dart';

void main() {
  group('Phase 41: Advanced Caching Strategies', () {
    // ==================== モデルテスト ====================
    group('CacheStrategy Enum', () {
      test('LRU strategy has correct value', () {
        expect(CacheStrategy.lru.value, equals('lru'));
      });

      test('LFU strategy has correct value', () {
        expect(CacheStrategy.lfu.value, equals('lfu'));
      });

      test('TTL strategy has correct value', () {
        expect(CacheStrategy.ttl.value, equals('ttl'));
      });

      test('ARC strategy has correct value', () {
        expect(CacheStrategy.arc.value, equals('arc'));
      });

      test('Distributed strategy has correct value', () {
        expect(CacheStrategy.distributed.value, equals('distributed'));
      });
    });

    group('CacheEntry', () {
      test('CacheEntry creation with TTL', () {
        final now = DateTime.now();
        final entry = CacheEntry(
          key: 'key1',
          value: 'value1',
          ttlSeconds: 3600,
          createdAt: now,
          lastAccessedAt: now,
          accessCount: 0,
        );

        expect(entry.key, equals('key1'));
        expect(entry.value, equals('value1'));
        expect(entry.ttlSeconds, equals(3600));
        expect(entry.accessCount, equals(0));
      });

      test('CacheEntry with no TTL never expires', () {
        final now = DateTime.now();
        final entry = CacheEntry(
          key: 'key1',
          value: 'value1',
          ttlSeconds: null,
          createdAt: now,
          lastAccessedAt: now,
        );

        expect(entry.isExpired, isFalse);
      });

      test('CacheEntry expires after TTL', () async {
        final now = DateTime.now().subtract(const Duration(seconds: 3700));
        final entry = CacheEntry(
          key: 'key1',
          value: 'value1',
          ttlSeconds: 3600,
          createdAt: now,
          lastAccessedAt: now,
        );

        expect(entry.isExpired, isTrue);
      });

      test('CacheEntry withAccess increments count', () {
        final now = DateTime.now();
        final entry = CacheEntry(
          key: 'key1',
          value: 'value1',
          ttlSeconds: 3600,
          createdAt: now,
          lastAccessedAt: now,
          accessCount: 5,
        );

        final updated = entry.withAccess();
        expect(updated.accessCount, equals(6));
      });
    });

    group('CachePolicy', () {
      test('LRU policy creation', () {
        final now = DateTime.now();
        final policy = CachePolicy(
          policyId: 'policy1',
          name: 'LRU Policy',
          strategy: CacheStrategy.lru,
          maxSize: 1000,
          maxMemoryMB: 512,
          evictionPolicy: EvictionPolicy.lru,
          createdAt: now,
          updatedAt: now,
        );

        expect(policy.policyId, equals('policy1'));
        expect(policy.strategy, equals(CacheStrategy.lru));
        expect(policy.maxSize, equals(1000));
      });

      test('Policy with TTL configuration', () {
        final now = DateTime.now();
        final policy = CachePolicy(
          policyId: 'ttl_policy',
          name: 'TTL Policy',
          strategy: CacheStrategy.ttl,
          maxSize: 500,
          maxMemoryMB: 256,
          ttlSeconds: 300,
          evictionPolicy: EvictionPolicy.ttl,
          createdAt: now,
          updatedAt: now,
        );

        expect(policy.ttlSeconds, equals(300));
      });
    });

    group('CacheMetrics', () {
      test('Hit rate calculation', () {
        final now = DateTime.now();
        final metrics = CacheMetrics(
          metricsId: 'metrics1',
          policyId: 'policy1',
          totalHits: 95,
          totalMisses: 5,
          evictedEntries: 10,
          currentSize: 500,
          createdAt: now,
          measuredAt: now,
        );

        expect(metrics.hitRate, closeTo(0.95, 0.01));
        expect(metrics.hitRatePercentage, equals(95));
      });

      test('Miss rate calculation', () {
        final now = DateTime.now();
        final metrics = CacheMetrics(
          metricsId: 'metrics1',
          policyId: 'policy1',
          totalHits: 95,
          totalMisses: 5,
          evictedEntries: 10,
          currentSize: 500,
          createdAt: now,
          measuredAt: now,
        );

        expect(metrics.missRate, closeTo(0.05, 0.01));
      });

      test('Zero metrics handling', () {
        final now = DateTime.now();
        final metrics = CacheMetrics(
          metricsId: 'metrics1',
          policyId: 'policy1',
          totalHits: 0,
          totalMisses: 0,
          evictedEntries: 0,
          currentSize: 0,
          createdAt: now,
          measuredAt: now,
        );

        expect(metrics.hitRate, equals(0.0));
        expect(metrics.missRate, equals(0.0));
      });
    });

    group('LRUCache', () {
      test('LRU basic get and set', () {
        final cache = LRUCache(cacheId: 'lru1', maxSize: 100);
        final now = DateTime.now();
        final entry = CacheEntry(
          key: 'key1',
          value: 'value1',
          createdAt: now,
          lastAccessedAt: now,
        );

        cache.set('key1', entry);
        final retrieved = cache.get('key1');

        expect(retrieved, isNotNull);
        expect(retrieved!.value, equals('value1'));
      });

      test('LRU evicts least recently used', () {
        final cache = LRUCache(cacheId: 'lru1', maxSize: 3);
        final now = DateTime.now();

        cache.set('key1', CacheEntry(key: 'key1', value: 'value1', createdAt: now, lastAccessedAt: now));
        cache.set('key2', CacheEntry(key: 'key2', value: 'value2', createdAt: now, lastAccessedAt: now));
        cache.set('key3', CacheEntry(key: 'key3', value: 'value3', createdAt: now, lastAccessedAt: now));

        // Access key1 and key2 to make key3 least recently used
        cache.get('key1');
        cache.get('key2');

        // Add new entry, should evict key3
        cache.set('key4', CacheEntry(key: 'key4', value: 'value4', createdAt: now, lastAccessedAt: now));

        expect(cache.get('key3'), isNull);
      });

      test('LRU respects max size', () {
        final cache = LRUCache(cacheId: 'lru1', maxSize: 2);
        final now = DateTime.now();

        cache.set('key1', CacheEntry(key: 'key1', value: 'value1', createdAt: now, lastAccessedAt: now));
        cache.set('key2', CacheEntry(key: 'key2', value: 'value2', createdAt: now, lastAccessedAt: now));

        expect(cache.currentSize, equals(2));
      });
    });

    group('LFUCache', () {
      test('LFU basic get and set', () {
        final cache = LFUCache(cacheId: 'lfu1', maxSize: 100);
        final now = DateTime.now();
        final entry = CacheEntry(
          key: 'key1',
          value: 'value1',
          createdAt: now,
          lastAccessedAt: now,
          accessCount: 0,
        );

        cache.set('key1', entry);
        final retrieved = cache.get('key1');

        expect(retrieved, isNotNull);
        expect(retrieved!.accessCount, greaterThan(0));
      });

      test('LFU tracks access count', () {
        final cache = LFUCache(cacheId: 'lfu1', maxSize: 100);
        final now = DateTime.now();
        final entry = CacheEntry(
          key: 'key1',
          value: 'value1',
          createdAt: now,
          lastAccessedAt: now,
          accessCount: 0,
        );

        cache.set('key1', entry);
        cache.get('key1');
        cache.get('key1');

        final retrieved = cache.get('key1');
        expect(retrieved!.accessCount, greaterThan(1));
      });
    });

    group('TTLCache', () {
      test('TTL cache stores and retrieves', () {
        final cache = TTLCache(cacheId: 'ttl1', maxSize: 100, ttlSeconds: 3600);
        final now = DateTime.now();
        final entry = CacheEntry(
          key: 'key1',
          value: 'value1',
          ttlSeconds: 3600,
          createdAt: now,
          lastAccessedAt: now,
        );

        cache.set('key1', entry);
        final retrieved = cache.get('key1');

        expect(retrieved, isNotNull);
      });

      test('TTL cache respects max size', () {
        final cache = TTLCache(cacheId: 'ttl1', maxSize: 2, ttlSeconds: 3600);
        final now = DateTime.now();

        cache.set('key1', CacheEntry(key: 'key1', value: 'value1', createdAt: now, lastAccessedAt: now));
        cache.set('key2', CacheEntry(key: 'key2', value: 'value2', createdAt: now, lastAccessedAt: now));

        expect(cache.currentSize, equals(2));
      });
    });

    group('ARCCache', () {
      test('ARC cache initialization', () {
        final cache = ARCCache(cacheId: 'arc1', maxSize: 100);
        final now = DateTime.now();
        final entry = CacheEntry(
          key: 'key1',
          value: 'value1',
          createdAt: now,
          lastAccessedAt: now,
        );

        cache.set('key1', entry);
        expect(cache.currentSize, equals(1));
      });
    });

    group('DistributedCache', () {
      test('Distributed cache basic operations', () {
        final cache = DistributedCache(
          cacheId: 'dist1',
          maxSize: 100,
          replicationFactor: 3,
        );
        final now = DateTime.now();
        final entry = CacheEntry(
          key: 'key1',
          value: 'value1',
          createdAt: now,
          lastAccessedAt: now,
        );

        cache.set('key1', entry);
        final retrieved = cache.get('key1');

        expect(retrieved, isNotNull);
      });
    });

    group('CacheHotspot', () {
      test('CacheHotspot creation', () {
        final now = DateTime.now();
        final spot = CacheHotspot(
          key: 'hot_key',
          accessCount: 100,
          firstAccessedAt: now.subtract(const Duration(hours: 1)),
          lastAccessedAt: now,
          accessFrequencyPerSecond: 1.5,
        );

        expect(spot.key, equals('hot_key'));
        expect(spot.accessCount, equals(100));
      });
    });

    // ==================== リポジトリテスト ====================
    group('MemoryCacheRepository', () {
      late MemoryCacheRepository repository;

      setUp(() {
        repository = MemoryCacheRepository();
      });

      test('save and retrieve entry', () async {
        final now = DateTime.now();
        final entry = CacheEntry(
          key: 'key1',
          value: 'value1',
          createdAt: now,
          lastAccessedAt: now,
        );

        await repository.set('key1', entry);
        final retrieved = await repository.get('key1');

        expect(retrieved, isNotNull);
        expect(retrieved!.value, equals('value1'));
      });

      test('delete entry', () async {
        final now = DateTime.now();
        final entry = CacheEntry(
          key: 'key1',
          value: 'value1',
          createdAt: now,
          lastAccessedAt: now,
        );

        await repository.set('key1', entry);
        await repository.delete('key1');
        final retrieved = await repository.get('key1');

        expect(retrieved, isNull);
      });

      test('get all entries', () async {
        final now = DateTime.now();
        await repository.set('key1', CacheEntry(key: 'key1', value: 'value1', createdAt: now, lastAccessedAt: now));
        await repository.set('key2', CacheEntry(key: 'key2', value: 'value2', createdAt: now, lastAccessedAt: now));

        final all = await repository.getAll();

        expect(all.length, equals(2));
      });

      test('clear all entries', () async {
        final now = DateTime.now();
        await repository.set('key1', CacheEntry(key: 'key1', value: 'value1', createdAt: now, lastAccessedAt: now));
        await repository.clear();

        final all = await repository.getAll();
        expect(all.isEmpty, isTrue);
      });
    });

    // ==================== エンジンテスト ====================
    group('MemoryCacheEngine', () {
      late CacheRepository repository;
      late CachePolicy policy;
      late MemoryCacheEngine engine;

      setUp(() {
        repository = MemoryCacheRepository();
        policy = CachePolicy(
          policyId: 'policy1',
          name: 'Test Policy',
          strategy: CacheStrategy.lru,
          maxSize: 100,
          maxMemoryMB: 512,
          evictionPolicy: EvictionPolicy.lru,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        engine = MemoryCacheEngine(repository, policy);
      });

      test('set and get values', () async {
        await engine.set('key1', 'value1');
        final value = await engine.get('key1');

        expect(value, equals('value1'));
      });

      test('track cache hits', () async {
        await engine.set('key1', 'value1');
        await engine.get('key1');
        await engine.get('key1');

        final metrics = await engine.getMetrics();
        expect(metrics!.totalHits, greaterThan(0));
      });

      test('track cache misses', () async {
        await engine.get('nonexistent');

        final metrics = await engine.getMetrics();
        expect(metrics!.totalMisses, equals(1));
      });

      test('delete key', () async {
        await engine.set('key1', 'value1');
        await engine.delete('key1');
        final value = await engine.get('key1');

        expect(value, isNull);
      });

      test('check key existence', () async {
        await engine.set('key1', 'value1');
        final exists = await engine.exists('key1');

        expect(exists, isTrue);
      });

      test('clear cache', () async {
        await engine.set('key1', 'value1');
        await engine.set('key2', 'value2');
        await engine.clear();

        final value1 = await engine.get('key1');
        final value2 = await engine.get('key2');

        expect(value1, isNull);
        expect(value2, isNull);
      });
    });

    // ==================== マネージャーテスト ====================
    group('MemoryCacheManager', () {
      late CacheRepository repository;
      late MemoryCacheManager manager;

      setUp(() {
        repository = MemoryCacheRepository();
        manager = MemoryCacheManager(repository);
      });

      test('create and get policy', () async {
        final now = DateTime.now();
        final policy = CachePolicy(
          policyId: 'policy1',
          name: 'Test Policy',
          strategy: CacheStrategy.lru,
          maxSize: 100,
          maxMemoryMB: 512,
          evictionPolicy: EvictionPolicy.lru,
          createdAt: now,
          updatedAt: now,
        );

        await manager.createPolicy(policy);
        final retrieved = await manager.getPolicy('policy1');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Test Policy'));
      });

      test('set and get values', () async {
        final now = DateTime.now();
        await manager.createPolicy(
          CachePolicy(
            policyId: 'policy1',
            name: 'Test Policy',
            strategy: CacheStrategy.lru,
            maxSize: 100,
            maxMemoryMB: 512,
            evictionPolicy: EvictionPolicy.lru,
            createdAt: now,
            updatedAt: now,
          ),
        );

        await manager.set('key1', 'value1');
        final value = await manager.get('key1');

        expect(value, equals('value1'));
      });
    });

    // ==================== ファサードテスト ====================
    group('CacheManagerFacade', () {
      late CacheManagerFacade facade;

      setUp(() {
        facade = CacheManagerFacade();
      });

      test('create policy via facade', () async {
        final now = DateTime.now();
        final policy = CachePolicy(
          policyId: 'policy1',
          name: 'Test Policy',
          strategy: CacheStrategy.lru,
          maxSize: 100,
          maxMemoryMB: 512,
          evictionPolicy: EvictionPolicy.lru,
          createdAt: now,
          updatedAt: now,
        );

        await facade.createPolicy(policy);
        final retrieved = await facade.getPolicy('policy1');

        expect(retrieved, isNotNull);
      });

      test('set and get via facade', () async {
        final now = DateTime.now();
        await facade.createPolicy(
          CachePolicy(
            policyId: 'policy1',
            name: 'Test Policy',
            strategy: CacheStrategy.lru,
            maxSize: 100,
            maxMemoryMB: 512,
            evictionPolicy: EvictionPolicy.lru,
            createdAt: now,
            updatedAt: now,
          ),
        );

        await facade.set('key1', 'value1');
        final value = await facade.get('key1');

        expect(value, equals('value1'));
      });

      test('check existence', () async {
        final now = DateTime.now();
        await facade.createPolicy(
          CachePolicy(
            policyId: 'policy1',
            name: 'Test Policy',
            strategy: CacheStrategy.lru,
            maxSize: 100,
            maxMemoryMB: 512,
            evictionPolicy: EvictionPolicy.lru,
            createdAt: now,
            updatedAt: now,
          ),
        );

        await facade.set('key1', 'value1');
        final exists = await facade.exists('key1');

        expect(exists, isTrue);
      });

      test('delete via facade', () async {
        final now = DateTime.now();
        await facade.createPolicy(
          CachePolicy(
            policyId: 'policy1',
            name: 'Test Policy',
            strategy: CacheStrategy.lru,
            maxSize: 100,
            maxMemoryMB: 512,
            evictionPolicy: EvictionPolicy.lru,
            createdAt: now,
            updatedAt: now,
          ),
        );

        await facade.set('key1', 'value1');
        await facade.delete('key1');

        final exists = await facade.exists('key1');
        expect(exists, isFalse);
      });

      test('get metrics', () async {
        final now = DateTime.now();
        await facade.createPolicy(
          CachePolicy(
            policyId: 'policy1',
            name: 'Test Policy',
            strategy: CacheStrategy.lru,
            maxSize: 100,
            maxMemoryMB: 512,
            evictionPolicy: EvictionPolicy.lru,
            createdAt: now,
            updatedAt: now,
          ),
        );

        await facade.set('key1', 'value1');
        final metrics = await facade.getMetrics('policy1');

        expect(metrics, isNotNull);
        expect(metrics!.currentSize, greaterThan(0));
      });

      test('generate report', () async {
        final now = DateTime.now();
        await facade.createPolicy(
          CachePolicy(
            policyId: 'policy1',
            name: 'Test Policy',
            strategy: CacheStrategy.lru,
            maxSize: 100,
            maxMemoryMB: 512,
            evictionPolicy: EvictionPolicy.lru,
            createdAt: now,
            updatedAt: now,
          ),
        );

        await facade.set('key1', 'value1');
        final report = await facade.generateReport();

        expect(report, isNotNull);
        expect(report.metrics.isNotEmpty, isTrue);
      });
    });

    // ==================== 統合テスト ====================
    group('Integration Tests', () {
      test('complete caching workflow', () async {
        final facade = CacheManagerFacade();
        final now = DateTime.now();

        // LRU ポリシー作成
        final lruPolicy = CachePolicy(
          policyId: 'lru_policy',
          name: 'LRU Policy',
          strategy: CacheStrategy.lru,
          maxSize: 100,
          maxMemoryMB: 512,
          evictionPolicy: EvictionPolicy.lru,
          createdAt: now,
          updatedAt: now,
        );
        await facade.createPolicy(lruPolicy);

        // データをセット
        await facade.set('user:1', {'id': 1, 'name': 'Alice'});
        await facade.set('user:2', {'id': 2, 'name': 'Bob'});

        // データを取得
        final user1 = await facade.get('user:1');
        expect(user1, isNotNull);

        // メトリクス確認
        final metrics = await facade.getMetrics('lru_policy');
        expect(metrics!.currentSize, equals(2));
      });

      test('multiple cache strategies', () async {
        final facade = CacheManagerFacade();
        final now = DateTime.now();

        // LFU ポリシー
        await facade.createPolicy(
          CachePolicy(
            policyId: 'lfu_policy',
            name: 'LFU Policy',
            strategy: CacheStrategy.lfu,
            maxSize: 100,
            maxMemoryMB: 512,
            evictionPolicy: EvictionPolicy.lfu,
            createdAt: now,
            updatedAt: now,
          ),
        );

        // TTL ポリシー
        await facade.createPolicy(
          CachePolicy(
            policyId: 'ttl_policy',
            name: 'TTL Policy',
            strategy: CacheStrategy.ttl,
            maxSize: 50,
            maxMemoryMB: 256,
            ttlSeconds: 300,
            evictionPolicy: EvictionPolicy.ttl,
            createdAt: now,
            updatedAt: now,
          ),
        );

        final lfu = await facade.getPolicy('lfu_policy');
        final ttl = await facade.getPolicy('ttl_policy');

        expect(lfu!.strategy, equals(CacheStrategy.lfu));
        expect(ttl!.strategy, equals(CacheStrategy.ttl));
      });

      test('cache warming', () async {
        final facade = CacheManagerFacade();
        final now = DateTime.now();

        await facade.createPolicy(
          CachePolicy(
            policyId: 'policy1',
            name: 'Test Policy',
            strategy: CacheStrategy.lru,
            maxSize: 100,
            maxMemoryMB: 512,
            evictionPolicy: EvictionPolicy.lru,
            createdAt: now,
            updatedAt: now,
          ),
        );

        final warming = CacheWarming(
          warmingId: 'warming1',
          policyId: 'policy1',
          entries: [
            MapEntry('config:app', {'version': '1.0'}),
            MapEntry('config:db', {'host': 'localhost'}),
          ],
          createdAt: now,
        );

        await facade.warmCache(warming);

        final config1 = await facade.get('config:app');
        expect(config1, isNotNull);
      });
    });

    // ==================== レポートテスト ====================
    group('CacheReport', () {
      test('markdown generation', () {
        final now = DateTime.now();
        final report = CacheReport(
          reportId: 'report1',
          generatedAt: now,
          metrics: [],
          hotspots: [],
          totalCacheEntries: 500,
          averageHitRate: 0.92,
        );

        final markdown = report.toMarkdown();
        expect(markdown, contains('Cache Report'));
        expect(markdown, contains('Total Cache Entries'));
      });
    });
  });
}
