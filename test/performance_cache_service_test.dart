import 'package:flutter_test/flutter_test.dart';

import 'package:bike_license_kore/models/user.dart';
import 'package:bike_license_kore/models/user_answer_log.dart';
import 'package:bike_license_kore/models/bike_unlock_progress.dart';
import 'package:bike_license_kore/services/performance_cache_service.dart';

void main() {
  group('PerformanceCacheService', () {
    late PerformanceCacheService cacheService;

    setUp(() {
      cacheService = PerformanceCacheService(
        maxCacheSize: 100,
        defaultTtlSeconds: 60,
      );
    });

    tearDown(() {
      cacheService.dispose();
    });

    test('should cache and retrieve user', () {
      // Arrange
      final user = AppUser(uid: 'test_user_12345678901234567890');

      // Act
      cacheService.cacheUser(user);
      final cached = cacheService.getCachedUser('test_user_12345678901234567890');

      // Assert
      expect(cached, isNotNull);
      expect(cached!.uid, equals('test_user_12345678901234567890'));
    });

    test('should return null for non-cached user', () {
      // Act
      final cached = cacheService.getCachedUser('non_existent_user_1234567890');

      // Assert
      expect(cached, isNull);
    });

    test('should expire cache after TTL', () async {
      // Arrange
      final user = AppUser(uid: 'test_user_12345678901234567890');

      // Act
      cacheService.cacheUser(user, ttlSeconds: 1);
      var cached = cacheService.getCachedUser('test_user_12345678901234567890');
      expect(cached, isNotNull);

      // Wait for expiration
      await Future.delayed(Duration(seconds: 2));
      cached = cacheService.getCachedUser('test_user_12345678901234567890');

      // Assert
      expect(cached, isNull);
    });

    test('should cache answer logs', () {
      // Arrange
      const logs = [
        UserAnswerLog(
          id: 'log_1',
          uid: 'test_user_12345678901234567890',
          questionId: 'q_1',
          selectedAnswer: 1,
          isCorrect: true,
          answeredAt: null,
        ),
      ];

      // Act
      cacheService.cacheAnswerLogs('test_user_12345678901234567890', logs);
      final cached =
          cacheService.getCachedAnswerLogs('test_user_12345678901234567890');

      // Assert
      expect(cached, isNotNull);
      expect(cached!.length, equals(1));
      expect(cached.first.id, equals('log_1'));
    });

    test('should cache bike unlock progress', () {
      // Arrange
      final progress = BikeUnlockProgress(
        uid: 'test_user_12345678901234567890',
        bikeCategory: 'gentsuki',
        unlockedAt: DateTime.now(),
        unlockedPercentage: 50,
      );

      // Act
      cacheService.cacheBikeUnlockProgress('test_user_12345678901234567890', [progress]);
      final cached = cacheService
          .getCachedBikeUnlockProgress('test_user_12345678901234567890');

      // Assert
      expect(cached, isNotNull);
      expect(cached!.length, equals(1));
      expect(cached.first.bikeCategory, equals('gentsuki'));
    });

    test('should cache prediction score', () {
      // Arrange
      final score = PassPredictionScore(
        uid: 'test_user_12345678901234567890',
        score: 85.5,
        calculatedAt: DateTime.now(),
      );

      // Act
      cacheService.cachePredictionScore('test_user_12345678901234567890', score);
      final cached =
          cacheService.getCachedPredictionScore('test_user_12345678901234567890');

      // Assert
      expect(cached, isNotNull);
      expect(cached!.score, equals(85.5));
    });

    test('should track hit rate correctly', () {
      // Arrange
      final user = AppUser(uid: 'test_user_12345678901234567890');
      cacheService.cacheUser(user);

      // Act - 3 hits, 2 misses
      cacheService.getCachedUser('test_user_12345678901234567890'); // hit
      cacheService.getCachedUser('test_user_12345678901234567890'); // hit
      cacheService.getCachedUser('test_user_12345678901234567890'); // hit
      cacheService.getCachedUser('non_existent_1_1234567890'); // miss
      cacheService.getCachedUser('non_existent_2_1234567890'); // miss

      // Assert
      final hitRate = cacheService.getHitRate();
      expect(hitRate, equals(0.6)); // 3 hits / 5 total
    });

    test('should enforce max cache size with LRU', () {
      // Arrange - Create cache service with small max size
      final smallCache = PerformanceCacheService(maxCacheSize: 3);

      // Act - Add 4 users
      for (int i = 1; i <= 4; i++) {
        final user = AppUser(uid: 'user_$i' + '0' * (24 - i.toString().length));
        smallCache.cacheUser(user);
      }

      // Assert - Only 3 most recent should exist
      expect(smallCache.getMetrics()['cacheSize'], equals(3));

      // Oldest entry should be evicted
      final oldestUser = smallCache.getCachedUser('user_1' + '0' * 23);
      expect(oldestUser, isNull);

      // Newest entry should exist
      final newestUser = smallCache.getCachedUser('user_4' + '0' * 23);
      expect(newestUser, isNotNull);

      smallCache.dispose();
    });

    test('should clear cache', () {
      // Arrange
      final user = AppUser(uid: 'test_user_12345678901234567890');
      cacheService.cacheUser(user);
      expect(cacheService.getCachedUser('test_user_12345678901234567890'),
          isNotNull);

      // Act
      cacheService.clearCache();

      // Assert
      expect(cacheService.getCachedUser('test_user_12345678901234567890'),
          isNull);
      expect(cacheService.getMetrics()['cacheSize'], equals(0));
    });

    test('should clear cache for specific user', () {
      // Arrange
      final user1 = AppUser(uid: 'user_1_1234567890123456789012');
      final user2 = AppUser(uid: 'user_2_1234567890123456789012');
      cacheService.cacheUser(user1);
      cacheService.cacheUser(user2);

      // Act
      cacheService.clearCacheForUser('user_1_1234567890123456789012');

      // Assert
      expect(
        cacheService.getCachedUser('user_1_1234567890123456789012'),
        isNull,
      );
      expect(
        cacheService.getCachedUser('user_2_1234567890123456789012'),
        isNotNull,
      );
    });

    test('should provide detailed metrics', () {
      // Arrange
      final user = AppUser(uid: 'test_user_12345678901234567890');
      cacheService.cacheUser(user);
      cacheService.getCachedUser('test_user_12345678901234567890');
      cacheService.getCachedUser('non_existent_1234567890');

      // Act
      final metrics = cacheService.getMetrics();

      // Assert
      expect(metrics.containsKey('cacheSize'), isTrue);
      expect(metrics.containsKey('maxCacheSize'), isTrue);
      expect(metrics.containsKey('hits'), isTrue);
      expect(metrics.containsKey('misses'), isTrue);
      expect(metrics.containsKey('totalRequests'), isTrue);
      expect(metrics.containsKey('hitRate'), isTrue);
      expect(metrics.containsKey('averageHitRate'), isTrue);
      expect(metrics.containsKey('entries'), isTrue);
      expect(metrics['hits'], equals(1));
      expect(metrics['misses'], equals(1));
    });

    test('should update access order on cache hit', () {
      // Arrange
      final cacheSmall = PerformanceCacheService(maxCacheSize: 3);
      final user1 = AppUser(uid: 'user_1_1234567890123456789012');
      final user2 = AppUser(uid: 'user_2_1234567890123456789012');
      final user3 = AppUser(uid: 'user_3_1234567890123456789012');
      final user4 = AppUser(uid: 'user_4_1234567890123456789012');

      // Act - Add users 1, 2, 3
      cacheSmall.cacheUser(user1);
      cacheSmall.cacheUser(user2);
      cacheSmall.cacheUser(user3);

      // Access user 1 to make it recently used
      cacheSmall.getCachedUser('user_1_1234567890123456789012');

      // Add user 4 (should evict user 2 since user 1 was recently accessed)
      cacheSmall.cacheUser(user4);

      // Assert
      expect(
        cacheSmall.getCachedUser('user_1_1234567890123456789012'),
        isNotNull,
      );
      expect(
        cacheSmall.getCachedUser('user_2_1234567890123456789012'),
        isNull, // Should be evicted
      );
      expect(
        cacheSmall.getCachedUser('user_3_1234567890123456789012'),
        isNotNull,
      );

      cacheSmall.dispose();
    });
  });

  group('StubPerformanceCacheService', () {
    late StubPerformanceCacheService cacheService;

    setUp(() {
      cacheService = StubPerformanceCacheService();
    });

    test('should not cache anything', () {
      // Arrange
      final user = AppUser(uid: 'test_user_12345678901234567890');

      // Act
      cacheService.cacheUser(user);
      final cached = cacheService.getCachedUser('test_user_12345678901234567890');

      // Assert
      expect(cached, isNull);
    });

    test('should return empty metrics', () {
      // Act
      final metrics = cacheService.getMetrics();

      // Assert
      expect(metrics['cacheSize'], equals(0));
      expect(metrics['hits'], equals(0));
      expect(metrics['misses'], equals(0));
      expect(metrics['hitRate'], equals(0.0));
    });
  });

  group('CacheEntry', () {
    test('should determine expiration correctly', () {
      // Arrange
      final entry = CacheEntry<String>(
        value: 'test',
        createdAt: DateTime.now().subtract(Duration(seconds: 10)),
        ttlSeconds: 5,
      );

      // Assert
      expect(entry.isExpired, isTrue);
    });

    test('should not expire before TTL', () {
      // Arrange
      final entry = CacheEntry<String>(
        value: 'test',
        createdAt: DateTime.now().subtract(Duration(seconds: 2)),
        ttlSeconds: 5,
      );

      // Assert
      expect(entry.isExpired, isFalse);
    });

    test('should calculate age correctly', () {
      // Arrange
      final entry = CacheEntry<String>(
        value: 'test',
        createdAt: DateTime.now().subtract(Duration(seconds: 3)),
        ttlSeconds: 60,
      );

      // Assert
      expect(entry.ageSeconds, greaterThanOrEqualTo(3));
      expect(entry.ageSeconds, lessThan(5));
    });
  });
}
