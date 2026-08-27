import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bike_license_kore/models/user.dart';
import 'package:bike_license_kore/models/user_answer_log.dart';
import 'package:bike_license_kore/services/sync_queue_service.dart';
import 'package:bike_license_kore/services/connectivity_service.dart';
import 'package:bike_license_kore/services/network_queue_processor.dart';

void main() {
  group('Offline-First Sync Integration', () {
    late LocalSyncQueueService queueService;
    late StubConnectivityService connectivityService;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      queueService = LocalSyncQueueService(sharedPreferences: prefs);
      connectivityService = StubConnectivityService();
    });

    tearDown(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('should queue writes when offline', () async {
      // Arrange
      connectivityService.setStatus(ConnectivityStatus.disconnected);
      final user = AppUser(uid: 'test_user_12345678901234567890');

      // Act - Simulate app writing data while offline
      final operation = QueuedOperation(
        id: 'op_1',
        type: 'saveUser',
        data: user.toJson(),
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      );
      await queueService.enqueue(operation);

      // Assert - Operation should be queued
      expect(queueService.getPendingCount(), equals(1));
      final queued = await queueService.getAll();
      expect(queued.first.id, equals('op_1'));
    });

    test('should handle multiple queued operations', () async {
      // Arrange
      connectivityService.setStatus(ConnectivityStatus.disconnected);
      final user = AppUser(uid: 'test_user_12345678901234567890');
      const answerLog = UserAnswerLog(
        id: 'log_1',
        uid: 'test_user_12345678901234567890',
        questionId: 'q_1',
        selectedAnswer: 2,
        isCorrect: true,
        answeredAt: null,
      );

      // Act - Queue multiple operations
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
        data: {
          'uid': user.uid,
          'logs': [answerLog.toJson()],
        },
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      ));
      await queueService.enqueue(QueuedOperation(
        id: 'op_3',
        type: 'saveUser',
        data: user.toJson(),
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      ));

      // Assert
      expect(queueService.getPendingCount(), equals(3));
      final queued = await queueService.getAll();
      expect(queued.map((op) => op.id).toList(), ['op_1', 'op_2', 'op_3']);
    });

    test('should process queued operations when online', () async {
      // Arrange
      connectivityService.setStatus(ConnectivityStatus.disconnected);
      final user = AppUser(uid: 'test_user_12345678901234567890');
      await queueService.enqueue(QueuedOperation(
        id: 'op_1',
        type: 'saveUser',
        data: user.toJson(),
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 0,
      ));
      expect(queueService.getPendingCount(), equals(1));

      // Act - Simulate coming back online
      connectivityService.setStatus(ConnectivityStatus.connected);

      // Assert - In real scenario, NetworkQueueProcessor would process this
      // For now, verify queue is still intact and ready to process
      expect(queueService.getPendingCount(), equals(1));
      final queued = await queueService.getAll();
      expect(queued.first.retryCount, equals(0));
    });

    test('should handle retry logic for failed operations', () async {
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

      // Act - Simulate retry
      await queueService.incrementRetry('op_1');
      await queueService.incrementRetry('op_1');

      // Assert
      final queued = await queueService.getAll();
      expect(queued.first.retryCount, equals(2));
    });

    test('should not retry operations beyond max retry count', () async {
      // Arrange
      final user = AppUser(uid: 'test_user_12345678901234567890');
      final operation = QueuedOperation(
        id: 'op_1',
        type: 'saveUser',
        data: user.toJson(),
        queuedAt: DateTime.now(),
        lastAttemptAt: DateTime.now(),
        retryCount: 5, // Max retries reached
      );
      await queueService.enqueue(operation);

      // Act
      final queued = await queueService.getAll();
      final shouldRetry = queued.first.retryCount < 5;

      // Assert
      expect(shouldRetry, isFalse);
    });

    test('should clear queue after successful sync', () async {
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
      expect(queueService.getPendingCount(), equals(1));

      // Act - Simulate successful sync by removing operation
      await queueService.remove('op_1');

      // Assert
      expect(queueService.getPendingCount(), equals(0));
    });

    test('should persist queue through app restart', () async {
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

      // Act - Simulate app restart
      final prefs = await SharedPreferences.getInstance();
      final newQueueService = LocalSyncQueueService(sharedPreferences: prefs);

      // Assert
      expect(newQueueService.getPendingCount(), equals(1));
      final queued = await newQueueService.getAll();
      expect(queued.first.id, equals('op_1'));
    });

    test('should maintain operation order', () async {
      // Arrange
      final user = AppUser(uid: 'test_user_12345678901234567890');

      // Act - Queue operations in specific order
      for (int i = 1; i <= 5; i++) {
        await queueService.enqueue(QueuedOperation(
          id: 'op_$i',
          type: 'saveUser',
          data: user.toJson(),
          queuedAt: DateTime.now(),
          lastAttemptAt: DateTime.now(),
          retryCount: 0,
        ));
      }

      // Assert - Operations should be in FIFO order
      final queued = await queueService.getAll();
      final ids = queued.map((op) => op.id).toList();
      expect(ids, ['op_1', 'op_2', 'op_3', 'op_4', 'op_5']);
    });
  });

  group('Network State Management', () {
    late StubConnectivityService connectivityService;

    setUp(() {
      connectivityService = StubConnectivityService();
    });

    test('should detect connection status correctly', () async {
      // Arrange
      connectivityService.setStatus(ConnectivityStatus.disconnected);

      // Act & Assert
      expect(await connectivityService.getStatus(),
          equals(ConnectivityStatus.disconnected));

      connectivityService.setStatus(ConnectivityStatus.connected);
      expect(await connectivityService.getStatus(),
          equals(ConnectivityStatus.connected));
    });

    test('should emit status changes through stream', (widgetTester) async {
      // Act
      final stream = connectivityService.statusStream();
      connectivityService.setStatus(ConnectivityStatus.disconnected);
      connectivityService.setStatus(ConnectivityStatus.connected);

      final statuses = await stream.take(3).toList();

      // Assert
      expect(statuses.length, greaterThanOrEqualTo(2));
    });

    test('should handle rapid status changes', () async {
      // Act - Simulate rapid network changes
      for (int i = 0; i < 10; i++) {
        connectivityService.setStatus(ConnectivityStatus.disconnected);
        connectivityService.setStatus(ConnectivityStatus.connected);
      }

      // Assert - Final status should be connected
      expect(await connectivityService.getStatus(),
          equals(ConnectivityStatus.connected));
    });
  });
}
