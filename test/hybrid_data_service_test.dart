import 'package:flutter_test/flutter_test.dart';

import 'package:bike_license_kore/models/user.dart';
import 'package:bike_license_kore/services/hybrid_data_service.dart';
import 'package:bike_license_kore/services/local_data_service.dart';
import 'package:bike_license_kore/services/firestore_sync_service.dart';
import 'package:bike_license_kore/services/conflict_resolution_service.dart';

/// Mock implementations for testing
class MockLocalDataService extends LocalDataService {
  AppUser? _mockUser;

  MockLocalDataService() : super();

  void setMockUser(AppUser user) {
    _mockUser = user;
  }

  @override
  Future<AppUser?> loadUser(String uid) async {
    return _mockUser;
  }
}

class MockFirestoreSyncService extends FirestoreSyncService {
  AppUser? _mockUser;

  MockFirestoreSyncService() : super();

  void setMockUser(AppUser user) {
    _mockUser = user;
  }

  @override
  Future<AppUser?> loadUser(String uid) async {
    return _mockUser;
  }
}

void main() {
  group('HybridDataService - User Loading', () {
    late HybridDataService hybridService;
    late MockLocalDataService localDataService;
    late MockFirestoreSyncService firestoreSyncService;
    late DefaultConflictResolutionService conflictResolutionService;

    setUp(() {
      localDataService = MockLocalDataService();
      firestoreSyncService = MockFirestoreSyncService();
      conflictResolutionService = DefaultConflictResolutionService();

      hybridService = HybridDataService(
        localDataService: localDataService,
        firestoreSyncService: firestoreSyncService,
        conflictResolutionService: conflictResolutionService,
      );
    });

    test('should load from Firestore when available', () async {
      // Arrange
      final remoteUser = AppUser(
        uid: 'test_user_12345678901234567890',
        createdAt: DateTime(2026, 8, 27),
        updatedAt: DateTime(2026, 8, 27, 12, 0, 0),
      );
      firestoreSyncService.setMockUser(remoteUser);

      // Act
      final user = await hybridService.loadUser('test_user_12345678901234567890');

      // Assert
      expect(user.uid, equals('test_user_12345678901234567890'));
    });

    test('should fallback to local when Firestore unavailable', () async {
      // Arrange
      final localUser = AppUser(
        uid: 'test_user_12345678901234567890',
        createdAt: DateTime(2026, 8, 27),
        updatedAt: DateTime(2026, 8, 27, 10, 0, 0),
      );
      localDataService.setMockUser(localUser);

      // Act
      final user = await hybridService.loadUser('test_user_12345678901234567890');

      // Assert
      expect(user.uid, equals('test_user_12345678901234567890'));
    });

    test('should apply conflict resolution when both exist', () async {
      // Arrange - Local is older
      final localTimestamp = DateTime(2026, 8, 27, 10, 0, 0);
      final remoteTimestamp = DateTime(2026, 8, 27, 12, 0, 0);

      final localUser = AppUser(
        uid: 'test_user_12345678901234567890',
        createdAt: DateTime(2026, 8, 27),
        updatedAt: localTimestamp,
      );

      final remoteUser = AppUser(
        uid: 'test_user_12345678901234567890',
        createdAt: DateTime(2026, 8, 27),
        updatedAt: remoteTimestamp,
      );

      localDataService.setMockUser(localUser);
      firestoreSyncService.setMockUser(remoteUser);

      // Act
      final user = await hybridService.loadUser('test_user_12345678901234567890');

      // Assert - Should return remote (newer)
      expect(user.updatedAt, equals(remoteTimestamp));
    });

    test('should prefer local when local is newer', () async {
      // Arrange - Local is newer
      final localTimestamp = DateTime(2026, 8, 27, 14, 0, 0);
      final remoteTimestamp = DateTime(2026, 8, 27, 12, 0, 0);

      final localUser = AppUser(
        uid: 'test_user_12345678901234567890',
        createdAt: DateTime(2026, 8, 27),
        updatedAt: localTimestamp,
      );

      final remoteUser = AppUser(
        uid: 'test_user_12345678901234567890',
        createdAt: DateTime(2026, 8, 27),
        updatedAt: remoteTimestamp,
      );

      localDataService.setMockUser(localUser);
      firestoreSyncService.setMockUser(remoteUser);

      // Act
      final user = await hybridService.loadUser('test_user_12345678901234567890');

      // Assert - Should return local (newer)
      expect(user.updatedAt, equals(localTimestamp));
    });

    test('should prefer local when timestamps equal', () async {
      // Arrange - Same timestamp
      final timestamp = DateTime(2026, 8, 27, 12, 0, 0);

      final localUser = AppUser(
        uid: 'test_user_12345678901234567890',
        createdAt: DateTime(2026, 8, 27),
        updatedAt: timestamp,
      );

      final remoteUser = AppUser(
        uid: 'test_user_12345678901234567890',
        createdAt: DateTime(2026, 8, 27),
        updatedAt: timestamp,
      );

      localDataService.setMockUser(localUser);
      firestoreSyncService.setMockUser(remoteUser);

      // Act
      final user = await hybridService.loadUser('test_user_12345678901234567890');

      // Assert - Should return local for consistency
      expect(user.updatedAt, equals(timestamp));
    });

    test('should handle both sources being null', () async {
      // Arrange - Both null
      localDataService.setMockUser(null);
      firestoreSyncService.setMockUser(null);

      // Act
      final user = await hybridService.loadUser('test_user_12345678901234567890');

      // Assert - Should create new user
      expect(user.uid, equals('test_user_12345678901234567890'));
    });

    test('should handle only local available', () async {
      // Arrange
      final localUser = AppUser(
        uid: 'test_user_12345678901234567890',
        createdAt: DateTime(2026, 8, 27),
        updatedAt: DateTime(2026, 8, 27, 10, 0, 0),
      );
      localDataService.setMockUser(localUser);
      firestoreSyncService.setMockUser(null);

      // Act
      final user = await hybridService.loadUser('test_user_12345678901234567890');

      // Assert
      expect(user.uid, equals('test_user_12345678901234567890'));
      expect(user.updatedAt, equals(localUser.updatedAt));
    });

    test('should handle only remote available', () async {
      // Arrange
      final remoteUser = AppUser(
        uid: 'test_user_12345678901234567890',
        createdAt: DateTime(2026, 8, 27),
        updatedAt: DateTime(2026, 8, 27, 12, 0, 0),
      );
      localDataService.setMockUser(null);
      firestoreSyncService.setMockUser(remoteUser);

      // Act
      final user = await hybridService.loadUser('test_user_12345678901234567890');

      // Assert
      expect(user.uid, equals('test_user_12345678901234567890'));
      expect(user.updatedAt, equals(remoteUser.updatedAt));
    });
  });

  group('HybridDataService - Consistency', () {
    test('should maintain data consistency across reads', () async {
      // Arrange
      final uid = 'test_user_12345678901234567890';
      final localDataService = MockLocalDataService();
      final firestoreSyncService = MockFirestoreSyncService();
      final conflictResolutionService = DefaultConflictResolutionService();

      final hybridService = HybridDataService(
        localDataService: localDataService,
        firestoreSyncService: firestoreSyncService,
        conflictResolutionService: conflictResolutionService,
      );

      final user = AppUser(
        uid: uid,
        createdAt: DateTime(2026, 8, 27),
        updatedAt: DateTime(2026, 8, 27, 12, 0, 0),
      );
      localDataService.setMockUser(user);
      firestoreSyncService.setMockUser(user);

      // Act - Multiple reads should return same data
      final user1 = await hybridService.loadUser(uid);
      final user2 = await hybridService.loadUser(uid);

      // Assert
      expect(user1.uid, equals(user2.uid));
      expect(user1.updatedAt, equals(user2.updatedAt));
    });
  });

  group('Conflict Resolution Strategy', () {
    test('should use Last-Write-Wins strategy', () async {
      // Arrange
      const service = DefaultConflictResolutionService();
      final localTimestamp = DateTime(2026, 8, 27, 10, 0, 0);
      final remoteTimestamp = DateTime(2026, 8, 27, 11, 0, 0);

      final localUser = AppUser(
        uid: 'test_user_12345678901234567890',
        updatedAt: localTimestamp,
      );

      final remoteUser = AppUser(
        uid: 'test_user_12345678901234567890',
        updatedAt: remoteTimestamp,
      );

      // Act
      final winner = service.resolveConflict(
        local: localUser,
        remote: remoteUser,
        localTimestamp: localTimestamp,
        remoteTimestamp: remoteTimestamp,
      );

      // Assert - Remote is newer, should win
      expect(winner, equals('remote'));
    });

    test('should handle microsecond precision in timestamps', () async {
      // Arrange
      const service = DefaultConflictResolutionService();
      final localTimestamp =
          DateTime(2026, 8, 27, 11, 30, 45, 123, 456); // 11:30:45.123456
      final remoteTimestamp =
          DateTime(2026, 8, 27, 11, 30, 45, 123, 457); // 11:30:45.123457

      final localUser = AppUser(
        uid: 'test_user_12345678901234567890',
        updatedAt: localTimestamp,
      );

      final remoteUser = AppUser(
        uid: 'test_user_12345678901234567890',
        updatedAt: remoteTimestamp,
      );

      // Act
      final winner = service.resolveConflict(
        local: localUser,
        remote: remoteUser,
        localTimestamp: localTimestamp,
        remoteTimestamp: remoteTimestamp,
      );

      // Assert - Remote is newer even by microseconds
      expect(winner, equals('remote'));
    });
  });
}
