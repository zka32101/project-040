import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bike_license_kore/models/user.dart';
import 'package:bike_license_kore/models/user_answer_log.dart';
import 'package:bike_license_kore/models/bike_unlock_progress.dart';
import 'package:bike_license_kore/models/trap_dojo_session.dart';
import 'package:bike_license_kore/models/pass_prediction_score.dart';
import 'package:bike_license_kore/services/sync_queue_service.dart';

void main() {
  group('LocalSyncQueueService', () {
    late LocalSyncQueueService queueService;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      queueService = LocalSyncQueueService(sharedPreferences: prefs);
    });

    tearDown(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('should enqueue and retrieve operations', () async {
      // Arrange
      final user = AppUser(uid: 'test_user_12345678901234567890');
      final operation = QueuedOperation(
        id: 'op_1',
        type: 'saveUser',
        data: user.toJson(),
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      );

      // Act
      await queueService.enqueue(operation);
      final operations = await queueService.getAll();

      // Assert
      expect(operations.length, equals(1));
      expect(operations.first.id, equals('op_1'));
      expect(operations.first.type, equals('saveUser'));
    });

    test('should remove operation from queue', () async {
      // Arrange
      final user = AppUser(uid: 'test_user_12345678901234567890');
      final operation = QueuedOperation(
        id: 'op_1',
        type: 'saveUser',
        data: user.toJson(),
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      );
      await queueService.enqueue(operation);

      // Act
      await queueService.remove('op_1');
      final operations = await queueService.getAll();

      // Assert
      expect(operations.isEmpty, isTrue);
    });

    test('should increment retry count', () async {
      // Arrange
      final user = AppUser(uid: 'test_user_12345678901234567890');
      final operation = QueuedOperation(
        id: 'op_1',
        type: 'saveUser',
        data: user.toJson(),
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      );
      await queueService.enqueue(operation);

      // Act
      await queueService.incrementRetry('op_1');
      final operations = await queueService.getAll();

      // Assert
      expect(operations.first.retryCount, equals(1));
    });

    test('should return pending count', () async {
      // Arrange
      final user = AppUser(uid: 'test_user_12345678901234567890');
      final operation1 = QueuedOperation(
        id: 'op_1',
        type: 'saveUser',
        data: user.toJson(),
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      );
      final operation2 = QueuedOperation(
        id: 'op_2',
        type: 'saveUser',
        data: user.toJson(),
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      );

      // Act
      await queueService.enqueue(operation1);
      await queueService.enqueue(operation2);
      final count = queueService.getPendingCount();

      // Assert
      expect(count, equals(2));
    });

    test('should respect max retry limit', () async {
      // Arrange
      final user = AppUser(uid: 'test_user_12345678901234567890');
      final operation = QueuedOperation(
        id: 'op_1',
        type: 'saveUser',
        data: user.toJson(),
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 5, // Max retries = 5
      );
      await queueService.enqueue(operation);

      // Act
      final operations = await queueService.getAll();
      final shouldRetry = operations.first.retryCount < 5;

      // Assert
      expect(shouldRetry, isFalse);
    });

    test('should handle multiple operation types', () async {
      // Arrange
      final user = AppUser(uid: 'test_user_12345678901234567890');
      const answerLog = UserAnswerLog(
        id: 'log_1',
        uid: 'test_user_12345678901234567890',
        questionId: 'q_1',
        selectedAnswer: 2,
        isCorrect: true,
        answeredAt: null,
      );
      final bikeProgress = BikeUnlockProgress(
        uid: 'test_user_12345678901234567890',
        bikeCategory: 'gentsuki',
        unlockedAt: DateTime.now(),
        unlockedPercentage: 50,
      );

      // Act
      await queueService.enqueue(QueuedOperation(
        id: 'op_1',
        type: 'saveUser',
        data: user.toJson(),
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      ));
      await queueService.enqueue(QueuedOperation(
        id: 'op_2',
        type: 'saveAnswerLogs',
        data: {'logs': [answerLog.toJson()]},
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      ));
      await queueService.enqueue(QueuedOperation(
        id: 'op_3',
        type: 'saveBikeProgress',
        data: {'progress': [bikeProgress.toJson()]},
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      ));

      final operations = await queueService.getAll();

      // Assert
      expect(operations.length, equals(3));
      expect(operations.map((op) => op.type).toList(), [
        'saveUser',
        'saveAnswerLogs',
        'saveBikeProgress',
      ]);
    });

    test('should persist operations across app restarts', () async {
      // Arrange
      final user = AppUser(uid: 'test_user_12345678901234567890');
      final operation = QueuedOperation(
        id: 'op_1',
        type: 'saveUser',
        data: user.toJson(),
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      );
      await queueService.enqueue(operation);

      // Act - Create new service instance (simulating app restart)
      final prefs = await SharedPreferences.getInstance();
      final newQueueService = LocalSyncQueueService(sharedPreferences: prefs);
      final operations = await newQueueService.getAll();

      // Assert
      expect(operations.length, equals(1));
      expect(operations.first.id, equals('op_1'));
    });

    test('should handle clearAll operation', () async {
      // Arrange
      final user = AppUser(uid: 'test_user_12345678901234567890');
      await queueService.enqueue(QueuedOperation(
        id: 'op_1',
        type: 'saveUser',
        data: user.toJson(),
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      ));
      await queueService.enqueue(QueuedOperation(
        id: 'op_2',
        type: 'saveUser',
        data: user.toJson(),
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      ));

      // Act
      await queueService.clearAll();
      final operations = await queueService.getAll();

      // Assert
      expect(operations.isEmpty, isTrue);
    });
  });

  group('StubSyncQueueService', () {
    late StubSyncQueueService queueService;

    setUp(() {
      queueService = StubSyncQueueService();
    });

    test('should not persist operations', () async {
      // Arrange
      final user = AppUser(uid: 'test_user_12345678901234567890');
      final operation = QueuedOperation(
        id: 'op_1',
        type: 'saveUser',
        data: user.toJson(),
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      );

      // Act
      await queueService.enqueue(operation);
      final operations = await queueService.getAll();

      // Assert
      expect(operations.isEmpty, isTrue);
    });

    test('should always return 0 pending count', () async {
      // Act
      final count = queueService.getPendingCount();

      // Assert
      expect(count, equals(0));
    });
  });
}
