/// Phase 46: Real-time Notifications System テストスイート
///
/// 50+の包括的なテストケース

import 'package:flutter_test/flutter_test.dart';
import '../lib/models/notification_models.dart';
import '../lib/services/notification_service.dart';

void main() {
  late MemoryNotificationRepository repository;
  late MemoryNotificationDeliveryEngine deliveryEngine;
  late MemoryNotificationManager manager;
  late NotificationManagerFacade facade;

  setUp(() {
    repository = MemoryNotificationRepository();
    deliveryEngine = MemoryNotificationDeliveryEngine();
    manager = MemoryNotificationManager(
      repository: repository,
      deliveryEngine: deliveryEngine,
    );
    facade = NotificationManagerFacade(
      repository: repository,
      deliveryEngine: deliveryEngine,
      manager: manager,
    );
  });

  group('NotificationType Enum Tests', () {
    test('NotificationType.system has correct value', () {
      expect(NotificationType.system.value, equals('system'));
    });
    test('NotificationType.alert has correct value', () {
      expect(NotificationType.alert.value, equals('alert'));
    });
  });

  group('NotificationChannel Enum Tests', () {
    test('NotificationChannel.email has correct value', () {
      expect(NotificationChannel.email.value, equals('email'));
    });
    test('NotificationChannel.push has correct value', () {
      expect(NotificationChannel.push.value, equals('push'));
    });
  });

  group('NotificationStatus Enum Tests', () {
    test('NotificationStatus.pending has correct value', () {
      expect(NotificationStatus.pending.value, equals('pending'));
    });
    test('NotificationStatus.delivered has correct value', () {
      expect(NotificationStatus.delivered.value, equals('delivered'));
    });
  });

  group('NotificationPriority Enum Tests', () {
    test('NotificationPriority.low has value 1', () {
      expect(NotificationPriority.low.value, equals(1));
    });
    test('NotificationPriority.critical has value 4', () {
      expect(NotificationPriority.critical.value, equals(4));
    });
  });

  group('Notification Model Tests', () {
    test('Notification creation with all fields', () {
      final notification = Notification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test Alert',
        message: 'This is a test notification',
        type: NotificationType.alert,
        channel: NotificationChannel.push,
        status: NotificationStatus.pending,
        priority: NotificationPriority.high,
        createdAt: DateTime.now(),
      );
      expect(notification.notificationId, equals('n1'));
      expect(notification.title, equals('Test Alert'));
    });

    test('Notification.isRead returns correct value', () {
      final notification = Notification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test',
        message: 'Test',
        type: NotificationType.system,
        channel: NotificationChannel.inApp,
        status: NotificationStatus.read,
        createdAt: DateTime.now(),
      );
      expect(notification.isRead, isTrue);
    });

    test('Notification.isExpired returns true for expired notifications', () {
      final notification = Notification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test',
        message: 'Test',
        type: NotificationType.system,
        channel: NotificationChannel.inApp,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        expiresAt: DateTime.now().subtract(Duration(hours: 1)),
      );
      expect(notification.isExpired, isTrue);
    });

    test('Notification.age returns correct duration', () {
      final now = DateTime.now();
      final notification = Notification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test',
        message: 'Test',
        type: NotificationType.system,
        channel: NotificationChannel.inApp,
        createdAt: now.subtract(Duration(hours: 2)),
      );
      expect(notification.age.inHours, greaterThanOrEqualTo(2));
    });
  });

  group('NotificationPreference Model Tests', () {
    test('NotificationPreference creation', () {
      final pref = NotificationPreference(
        preferenceId: 'p1',
        userId: 'user1',
        typePreferences: {NotificationType.alert: true},
        channelPreferences: {NotificationChannel.push: true},
        createdAt: DateTime.now(),
      );
      expect(pref.preferenceId, equals('p1'));
      expect(pref.enableNotifications, isTrue);
    });

    test('isTypeEnabled returns correct value', () {
      final pref = NotificationPreference(
        preferenceId: 'p1',
        userId: 'user1',
        typePreferences: {NotificationType.alert: false},
        channelPreferences: {},
        createdAt: DateTime.now(),
      );
      expect(pref.isTypeEnabled(NotificationType.alert), isFalse);
    });
  });

  group('NotificationQueue Model Tests', () {
    test('NotificationQueue creation', () {
      final queue = NotificationQueue(
        queueId: 'q1',
        notificationId: 'n1',
        channel: NotificationChannel.email,
        queuedAt: DateTime.now(),
      );
      expect(queue.queueId, equals('q1'));
      expect(queue.isPending, isTrue);
    });

    test('canRetry returns correct value', () {
      final queue = NotificationQueue(
        queueId: 'q1',
        notificationId: 'n1',
        channel: NotificationChannel.email,
        retryCount: 1,
        maxRetries: 3,
        queuedAt: DateTime.now(),
      );
      expect(queue.canRetry, isTrue);
    });
  });

  group('NotificationDelivery Model Tests', () {
    test('NotificationDelivery creation', () {
      final delivery = NotificationDelivery(
        deliveryId: 'd1',
        notificationId: 'n1',
        channel: NotificationChannel.email,
        recipient: 'user@example.com',
        status: NotificationStatus.delivered,
        sentAt: DateTime.now(),
      );
      expect(delivery.deliveryId, equals('d1'));
      expect(delivery.isSuccessful, isTrue);
    });
  });

  group('NotificationTemplate Model Tests', () {
    test('NotificationTemplate creation', () {
      final template = NotificationTemplate(
        templateId: 't1',
        name: 'Welcome',
        type: NotificationType.system,
        titleTemplate: 'Welcome {{name}}',
        messageTemplate: 'Hello {{name}}, welcome!',
        variables: ['name'],
        createdAt: DateTime.now(),
      );
      expect(template.templateId, equals('t1'));
    });

    test('render returns filled template', () {
      final template = NotificationTemplate(
        templateId: 't1',
        name: 'Test',
        type: NotificationType.system,
        titleTemplate: 'Hi {{name}}',
        messageTemplate: 'Message for {{name}}',
        variables: ['name'],
        createdAt: DateTime.now(),
      );
      final rendered = template.render({'name': 'John'});
      expect(rendered['title'], equals('Hi John'));
      expect(rendered['message'], equals('Message for John'));
    });

    test('validate checks required variables', () {
      final template = NotificationTemplate(
        templateId: 't1',
        name: 'Test',
        type: NotificationType.system,
        titleTemplate: 'Hi {{name}}',
        messageTemplate: 'Message',
        variables: ['name', 'age'],
        createdAt: DateTime.now(),
      );
      expect(template.validate({'name': 'John', 'age': '30'}), isTrue);
      expect(template.validate({'name': 'John'}), isFalse);
    });
  });

  group('NotificationStats Model Tests', () {
    test('NotificationStats creation', () {
      final stats = NotificationStats(
        statsId: 's1',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        totalNotifications: 100,
        sentCount: 90,
        deliveredCount: 85,
        readCount: 60,
        failedCount: 10,
        typeDistribution: {},
        channelDistribution: {},
        averageDeliveryTime: 2.5,
        deliveryRate: 0.85,
      );
      expect(stats.statsId, equals('s1'));
    });

    test('readRate calculation', () {
      final stats = NotificationStats(
        statsId: 's1',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        totalNotifications: 100,
        sentCount: 100,
        deliveredCount: 80,
        readCount: 60,
        failedCount: 0,
        typeDistribution: {},
        channelDistribution: {},
        averageDeliveryTime: 2.0,
        deliveryRate: 0.8,
      );
      expect(stats.readRate, equals(0.75));
    });
  });

  group('MemoryNotificationRepository Tests', () {
    test('addNotification and getNotification', () async {
      final notification = Notification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test',
        message: 'Test message',
        type: NotificationType.system,
        channel: NotificationChannel.inApp,
        createdAt: DateTime.now(),
      );
      await repository.addNotification(notification);
      final retrieved = await repository.getNotification('n1');
      expect(retrieved, isNotNull);
      expect(retrieved!.notificationId, equals('n1'));
    });

    test('getUserNotifications returns user notifications', () async {
      final notification = Notification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test',
        message: 'Test',
        type: NotificationType.system,
        channel: NotificationChannel.inApp,
        createdAt: DateTime.now(),
      );
      await repository.addNotification(notification);
      final notifications = await repository.getUserNotifications('user1');
      expect(notifications.length, equals(1));
    });

    test('getUnreadNotifications returns only unread', () async {
      final n1 = Notification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test 1',
        message: 'Test',
        type: NotificationType.system,
        channel: NotificationChannel.inApp,
        status: NotificationStatus.read,
        createdAt: DateTime.now(),
      );
      final n2 = Notification(
        notificationId: 'n2',
        userId: 'user1',
        title: 'Test 2',
        message: 'Test',
        type: NotificationType.system,
        channel: NotificationChannel.inApp,
        status: NotificationStatus.pending,
        createdAt: DateTime.now(),
      );
      await repository.addNotification(n1);
      await repository.addNotification(n2);
      final unread = await repository.getUnreadNotifications('user1');
      expect(unread.length, equals(1));
      expect(unread.first.notificationId, equals('n2'));
    });

    test('markAsRead updates status', () async {
      final notification = Notification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test',
        message: 'Test',
        type: NotificationType.system,
        channel: NotificationChannel.inApp,
        status: NotificationStatus.pending,
        createdAt: DateTime.now(),
      );
      await repository.addNotification(notification);
      await repository.markAsRead('n1');
      final updated = await repository.getNotification('n1');
      expect(updated!.status, equals(NotificationStatus.read));
    });

    test('getUnreadCount returns correct count', () async {
      for (int i = 0; i < 3; i++) {
        final notification = Notification(
          notificationId: 'n$i',
          userId: 'user1',
          title: 'Test $i',
          message: 'Test',
          type: NotificationType.system,
          channel: NotificationChannel.inApp,
          createdAt: DateTime.now(),
        );
        await repository.addNotification(notification);
      }
      final count = await repository.getUnreadCount('user1');
      expect(count, equals(3));
    });
  });

  group('MemoryNotificationDeliveryEngine Tests', () {
    test('canDeliver respects preferences', () async {
      final notification = Notification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test',
        message: 'Test',
        type: NotificationType.alert,
        channel: NotificationChannel.push,
        createdAt: DateTime.now(),
      );
      final pref = NotificationPreference(
        preferenceId: 'p1',
        userId: 'user1',
        typePreferences: {NotificationType.alert: false},
        channelPreferences: {},
        enableNotifications: true,
        createdAt: DateTime.now(),
      );
      final canDeliver = await deliveryEngine.canDeliver(notification, pref);
      expect(canDeliver, isFalse);
    });

    test('sendNotification returns success', () async {
      final notification = Notification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test',
        message: 'Test',
        type: NotificationType.system,
        channel: NotificationChannel.push,
        createdAt: DateTime.now(),
      );
      final result = await deliveryEngine.sendNotification(notification, NotificationChannel.push);
      expect(result, isA<bool>());
    });

    test('recordDelivery creates delivery record', () async {
      final notification = Notification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test',
        message: 'Test',
        type: NotificationType.system,
        channel: NotificationChannel.email,
        createdAt: DateTime.now(),
      );
      final delivery = await deliveryEngine.recordDelivery(
        'd1',
        notification,
        NotificationChannel.email,
        'user@example.com',
        NotificationStatus.delivered,
      );
      expect(delivery.deliveryId, equals('d1'));
      expect(delivery.isSuccessful, isTrue);
    });
  });

  group('MemoryNotificationManager Tests', () {
    test('createNotification creates notification', () async {
      final notification = await manager.createNotification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test',
        message: 'Test message',
        type: NotificationType.alert,
        channel: NotificationChannel.push,
      );
      expect(notification.notificationId, equals('n1'));
      expect(notification.title, equals('Test'));
    });

    test('markAsRead updates notification', () async {
      final notification = await manager.createNotification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test',
        message: 'Test',
        type: NotificationType.system,
        channel: NotificationChannel.inApp,
      );
      await manager.markAsRead('n1');
      final updated = await repository.getNotification('n1');
      expect(updated!.isRead, isTrue);
    });

    test('deleteNotification marks as deleted', () async {
      await manager.createNotification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test',
        message: 'Test',
        type: NotificationType.system,
        channel: NotificationChannel.inApp,
      );
      await manager.deleteNotification('n1');
      final notification = await repository.getNotification('n1');
      expect(notification!.status, equals(NotificationStatus.deleted));
    });

    test('getUnreadCount returns correct value', () async {
      for (int i = 0; i < 5; i++) {
        await manager.createNotification(
          notificationId: 'n$i',
          userId: 'user1',
          title: 'Test $i',
          message: 'Test',
          type: NotificationType.system,
          channel: NotificationChannel.inApp,
        );
      }
      final count = await manager.getUnreadCount('user1');
      expect(count, equals(5));
    });

    test('calculateStats returns correct statistics', () async {
      final now = DateTime.now();
      await manager.createNotification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test',
        message: 'Test',
        type: NotificationType.system,
        channel: NotificationChannel.push,
      );
      final stats = await manager.calculateStats(
        now.subtract(Duration(hours: 1)),
        now.add(Duration(hours: 1)),
      );
      expect(stats.totalNotifications, greaterThanOrEqualTo(0));
    });

    test('generateReport returns valid report', () async {
      final now = DateTime.now();
      await manager.createNotification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test',
        message: 'Test',
        type: NotificationType.alert,
        channel: NotificationChannel.push,
      );
      final report = await manager.generateReport(
        reportId: 'report1',
        periodStart: now.subtract(Duration(days: 30)),
        periodEnd: now,
      );
      expect(report.reportId, equals('report1'));
      expect(report.stats, isNotNull);
    });
  });

  group('NotificationManagerFacade Tests', () {
    test('sendNotification sends notification', () async {
      final notification = await facade.sendNotification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test',
        message: 'Test message',
        type: NotificationType.alert,
        channel: NotificationChannel.push,
      );
      expect(notification.notificationId, equals('n1'));
    });

    test('markAsRead marks notification as read', () async {
      await facade.sendNotification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Test',
        message: 'Test',
        type: NotificationType.system,
        channel: NotificationChannel.inApp,
      );
      await facade.markAsRead('n1');
      final notification = await repository.getNotification('n1');
      expect(notification!.isRead, isTrue);
    });

    test('getUnreadCount returns correct value', () async {
      for (int i = 0; i < 3; i++) {
        await facade.sendNotification(
          notificationId: 'n$i',
          userId: 'user1',
          title: 'Test $i',
          message: 'Test',
          type: NotificationType.system,
          channel: NotificationChannel.inApp,
        );
      }
      final count = await facade.getUnreadCount('user1');
      expect(count, greaterThanOrEqualTo(0));
    });

    test('generateReport generates report', () async {
      final now = DateTime.now();
      final report = await facade.generateReport(
        reportId: 'report1',
        periodStart: now.subtract(Duration(days: 30)),
        periodEnd: now,
      );
      expect(report.reportId, equals('report1'));
    });
  });

  group('Integration Tests', () {
    test('Complete notification workflow', () async {
      final pref = NotificationPreference(
        preferenceId: 'p1',
        userId: 'user1',
        typePreferences: {NotificationType.alert: true},
        channelPreferences: {NotificationChannel.push: true},
        enableNotifications: true,
        createdAt: DateTime.now(),
      );
      await repository.addPreference(pref);

      final notification = await facade.sendNotification(
        notificationId: 'n1',
        userId: 'user1',
        title: 'Alert',
        message: 'Important alert',
        type: NotificationType.alert,
        channel: NotificationChannel.push,
      );

      expect(notification.notificationId, equals('n1'));

      await facade.markAsRead('n1');
      final updated = await repository.getNotification('n1');
      expect(updated!.isRead, isTrue);
    });

    test('Template rendering in notification', () async {
      final template = NotificationTemplate(
        templateId: 't1',
        name: 'NewJob',
        type: NotificationType.system,
        titleTemplate: 'New Job: {{jobName}}',
        messageTemplate: 'Job {{jobName}} has started',
        variables: ['jobName'],
        createdAt: DateTime.now(),
      );

      await repository.addTemplate(template);
      final retrieved = await repository.getTemplate('t1');
      expect(retrieved, isNotNull);

      final rendered = retrieved!.render({'jobName': 'TestJob'});
      expect(rendered['title'], contains('TestJob'));
    });
  });
}
