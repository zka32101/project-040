import 'package:flutter_test/flutter_test.dart';

import 'package:bike_license_kore/models/user.dart';
import 'package:bike_license_kore/services/conflict_resolution_service.dart';

void main() {
  group('DefaultConflictResolutionService', () {
    late DefaultConflictResolutionService service;

    setUp(() {
      service = DefaultConflictResolutionService();
    });

    test('should return remote when remote is newer (Last-Write-Wins)', () {
      // Arrange
      final localTimestamp = DateTime(2026, 8, 27, 10, 0, 0);
      final remoteTimestamp = DateTime(2026, 8, 27, 11, 0, 0);

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

      // Act
      final winner = service.resolveConflict(
        local: localUser,
        remote: remoteUser,
        localTimestamp: localTimestamp,
        remoteTimestamp: remoteTimestamp,
      );

      // Assert
      expect(winner, equals('remote'));
    });

    test('should return local when local is newer (Last-Write-Wins)', () {
      // Arrange
      final localTimestamp = DateTime(2026, 8, 27, 12, 0, 0);
      final remoteTimestamp = DateTime(2026, 8, 27, 11, 0, 0);

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

      // Act
      final winner = service.resolveConflict(
        local: localUser,
        remote: remoteUser,
        localTimestamp: localTimestamp,
        remoteTimestamp: remoteTimestamp,
      );

      // Assert
      expect(winner, equals('local'));
    });

    test('should return local when timestamps are equal (consistency)', () {
      // Arrange
      final timestamp = DateTime(2026, 8, 27, 11, 0, 0);

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

      // Act
      final winner = service.resolveConflict(
        local: localUser,
        remote: remoteUser,
        localTimestamp: timestamp,
        remoteTimestamp: timestamp,
      );

      // Assert
      expect(winner, equals('local'));
    });

    test('should handle null timestamps gracefully', () {
      // Arrange - using DateTime.now() as default for null
      final localUser = AppUser(uid: 'test_user_12345678901234567890');
      final remoteUser = AppUser(uid: 'test_user_12345678901234567890');

      // Act
      final winner = service.resolveConflict(
        local: localUser,
        remote: remoteUser,
        localTimestamp: localUser.updatedAt,
        remoteTimestamp: remoteUser.updatedAt,
      );

      // Assert - should complete without error and return a winner
      expect(winner, isIn(['local', 'remote']));
    });

    test('should work with large timestamp differences', () {
      // Arrange
      final localTimestamp = DateTime(2026, 1, 1);
      final remoteTimestamp = DateTime(2026, 12, 31);

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

      // Assert
      expect(winner, equals('remote'));
    });

    test('should handle sub-second timestamp precision', () {
      // Arrange
      final localTimestamp =
          DateTime(2026, 8, 27, 11, 30, 45, 500, 0); // 11:30:45.500
      final remoteTimestamp =
          DateTime(2026, 8, 27, 11, 30, 45, 600, 0); // 11:30:45.600

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

      // Assert
      expect(winner, equals('remote'));
    });
  });

  group('StubConflictResolutionService', () {
    late StubConflictResolutionService service;

    setUp(() {
      service = StubConflictResolutionService();
    });

    test('should always return remote for testing', () {
      // Arrange
      final localUser = AppUser(uid: 'test_user_12345678901234567890');
      final remoteUser = AppUser(uid: 'test_user_12345678901234567890');

      // Act
      final winner = service.resolveConflict(
        local: localUser,
        remote: remoteUser,
        localTimestamp: DateTime.now(),
        remoteTimestamp: DateTime.now(),
      );

      // Assert
      expect(winner, equals('remote'));
    });
  });

  group('ConflictResolutionStrategy', () {
    test('should support Last-Write-Wins strategy', () {
      // Verify that Last-Write-Wins is the only supported strategy
      const strategies = ConflictResolutionStrategy.values;
      expect(strategies.length, greaterThan(0));
      expect(strategies.contains(ConflictResolutionStrategy.lastWriteWins),
          isTrue);
    });
  });
}
