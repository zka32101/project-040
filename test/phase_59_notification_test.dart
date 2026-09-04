import 'package:flutter_test/flutter_test.dart';
import '../lib/models/notification_models.dart';
import '../lib/services/notification_service.dart';

void main() {
  group('Phase 59: Real-time Notifications & Alerts', () {
    late NotificationFacade notificationFacade;

    setUp(() {
      notificationFacade = NotificationFacade();
    });

    // ===== Enum Tests =====
    group('Enums', () {
      test('NotificationType enum values', () {
        expect(NotificationType.info.value, 'info');
        expect(NotificationType.warning.value, 'warning');
        expect(NotificationType.error.value, 'error');
        expect(NotificationType.success.value, 'success');
        expect(NotificationType.alert.value, 'alert');
      });

      test('DeliveryChannel enum values', () {
        expect(DeliveryChannel.inApp.value, 'in_app');
        expect(DeliveryChannel.email.value, 'email');
        expect(DeliveryChannel.sms.value, 'sms');
        expect(DeliveryChannel.pushNotification.value, 'push');
        expect(DeliveryChannel.slack.value, 'slack');
        expect(DeliveryChannel.webhook.value, 'webhook');
      });

      test('NotificationStatus enum values', () {
        expect(NotificationStatus.pending.value, 'pending');
        expect(NotificationStatus.sent.value, 'sent');
        expect(NotificationStatus.delivered.value, 'delivered');
        expect(NotificationStatus.read.value, 'read');
        expect(NotificationStatus.failed.value, 'failed');
        expect(NotificationStatus.bounced.value, 'bounced');
      });

      test('PriorityLevel enum values', () {
        expect(PriorityLevel.low.value, 'low');
        expect(PriorityLevel.normal.value, 'normal');
        expect(PriorityLevel.high.value, 'high');
        expect(PriorityLevel.critical.value, 'critical');
      });

      test('AlertType enum values', () {
        expect(AlertType.threshold.value, 'threshold');
        expect(AlertType.anomaly.value, 'anomaly');
        expect(AlertType.errorRate.value, 'error_rate');
        expect(AlertType.performanceDegradation.value, 'performance_degradation');
        expect(AlertType.securityEvent.value, 'security_event');
        expect(AlertType.custom.value, 'custom');
      });

      test('AlertStatus enum values', () {
        expect(AlertStatus.active.value, 'active');
        expect(AlertStatus.acknowledged.value, 'acknowledged');
        expect(AlertStatus.resolved.value, 'resolved');
        expect(AlertStatus.silenced.value, 'silenced');
      });
    });

    // ===== Notification Model Tests =====
    group('Notification Model', () {
      test('Notification creation', () {
        final notif = Notification(
          notificationId: 'notif1',
          userId: 'user1',
          title: 'Test',
          message: 'Test message',
          notificationType: NotificationType.info,
          createdAt: DateTime(2026, 9, 1),
        );

        expect(notif.notificationId, 'notif1');
        expect(notif.isDelivered, false);
      });

      test('Notification isRead computed property', () {
        final read = Notification(
          notificationId: 'notif1',
          userId: 'user1',
          title: 'Test',
          message: 'Test message',
          notificationType: NotificationType.info,
          createdAt: DateTime(2026, 9, 1),
          readAt: DateTime(2026, 9, 1, 1, 0, 0),
        );

        expect(read.isRead, true);
      });

      test('Notification isHighPriority computed property', () {
        final highPriority = Notification(
          notificationId: 'notif1',
          userId: 'user1',
          title: 'Critical',
          message: 'Critical message',
          notificationType: NotificationType.error,
          priority: PriorityLevel.critical,
          createdAt: DateTime(2026, 9, 1),
        );

        expect(highPriority.isHighPriority, true);
      });

      test('Notification ageInHours computed property', () {
        final createdAt = DateTime.now().subtract(Duration(hours: 5));
        final notif = Notification(
          notificationId: 'notif1',
          userId: 'user1',
          title: 'Test',
          message: 'Test',
          notificationType: NotificationType.info,
          createdAt: createdAt,
        );

        expect(notif.ageInHours >= 4, true);
        expect(notif.ageInHours <= 6, true);
      });
    });

    // ===== DeliveryLog Tests =====
    group('DeliveryLog Model', () {
      test('DeliveryLog creation', () {
        final log = DeliveryLog(
          logId: 'log1',
          notificationId: 'notif1',
          channel: DeliveryChannel.email,
          sentAt: DateTime.now(),
          status: NotificationStatus.sent,
        );

        expect(log.logId, 'log1');
        expect(log.isPending, false);
      });

      test('DeliveryLog isSuccessful computed property', () {
        final successful = DeliveryLog(
          logId: 'log1',
          notificationId: 'notif1',
          channel: DeliveryChannel.sms,
          sentAt: DateTime.now(),
          deliveredAt: DateTime.now().add(Duration(seconds: 5)),
          status: NotificationStatus.delivered,
        );

        expect(successful.isSuccessful, true);
      });

      test('DeliveryLog deliveryTimeInSeconds computed property', () {
        final sent = DateTime(2026, 9, 1, 10, 0, 0);
        final delivered = DateTime(2026, 9, 1, 10, 0, 30);
        final log = DeliveryLog(
          logId: 'log1',
          notificationId: 'notif1',
          channel: DeliveryChannel.pushNotification,
          sentAt: sent,
          deliveredAt: delivered,
          status: NotificationStatus.delivered,
        );

        expect(log.deliveryTimeInSeconds, 30);
      });
    });

    // ===== Template Tests =====
    group('NotificationTemplate Model', () {
      test('NotificationTemplate creation', () {
        final template = NotificationTemplate(
          templateId: 'template1',
          templateName: 'Welcome',
          titleTemplate: 'Welcome {{name}}',
          messageTemplate: 'Hello {{name}}, welcome to {{app}}',
          notificationType: NotificationType.success,
          channels: [DeliveryChannel.inApp, DeliveryChannel.email],
          createdAt: DateTime(2026, 1, 1),
        );

        expect(template.channelCount, 2);
        expect(template.isEnabled, true);
      });

      test('NotificationTemplate isPopular computed property', () {
        final popular = NotificationTemplate(
          templateId: 'template1',
          templateName: 'Frequent',
          titleTemplate: 'Title',
          messageTemplate: 'Message',
          notificationType: NotificationType.info,
          channels: [DeliveryChannel.inApp],
          createdAt: DateTime(2026, 1, 1),
          usageCount: 15,
        );

        expect(popular.isPopular, true);
      });
    });

    // ===== NotificationPreference Tests =====
    group('NotificationPreference Model', () {
      test('NotificationPreference creation', () {
        final pref = NotificationPreference(
          preferenceId: 'pref1',
          userId: 'user1',
          channelPreferences: {DeliveryChannel.email: true},
          typePreferences: {NotificationType.info: true},
          createdAt: DateTime(2026, 1, 1),
        );

        expect(pref.userId, 'user1');
        expect(pref.isEnabled, true);
      });

      test('NotificationPreference enabledChannelCount computed property', () {
        final pref = NotificationPreference(
          preferenceId: 'pref1',
          userId: 'user1',
          channelPreferences: {},
          typePreferences: {},
          emailNotifications: true,
          smsNotifications: true,
          pushNotifications: false,
          inAppNotifications: true,
          createdAt: DateTime(2026, 1, 1),
        );

        expect(pref.enabledChannelCount, 3);
      });

      test('NotificationPreference isCompletelyDisabled computed property', () {
        final disabled = NotificationPreference(
          preferenceId: 'pref1',
          userId: 'user1',
          channelPreferences: {},
          typePreferences: {},
          emailNotifications: false,
          smsNotifications: false,
          pushNotifications: false,
          inAppNotifications: false,
          createdAt: DateTime(2026, 1, 1),
        );

        expect(disabled.isCompletelyDisabled, true);
      });
    });

    // ===== Alert Tests =====
    group('Alert Model', () {
      test('Alert creation', () {
        final alert = Alert(
          alertId: 'alert1',
          alertName: 'High CPU Usage',
          alertType: AlertType.threshold,
          condition: 'cpu > 90%',
          severity: PriorityLevel.high,
          recipients: ['admin@example.com'],
          notificationChannels: [DeliveryChannel.email],
          createdAt: DateTime(2026, 1, 1),
        );

        expect(alert.alertId, 'alert1');
        expect(alert.isActive, true);
      });

      test('Alert wasRecentlyTriggered computed property', () {
        final recent = Alert(
          alertId: 'alert1',
          alertName: 'Test',
          alertType: AlertType.threshold,
          condition: 'test',
          severity: PriorityLevel.high,
          recipients: [],
          notificationChannels: [],
          createdAt: DateTime(2026, 1, 1),
          lastTriggeredAt: DateTime.now().subtract(Duration(minutes: 30)),
        );

        expect(recent.wasRecentlyTriggered, true);
      });

      test('Alert isFrequent computed property', () {
        final frequent = Alert(
          alertId: 'alert1',
          alertName: 'Frequent',
          alertType: AlertType.anomaly,
          condition: 'condition',
          severity: PriorityLevel.normal,
          recipients: [],
          notificationChannels: [],
          createdAt: DateTime(2026, 1, 1),
          triggerCount: 15,
        );

        expect(frequent.isFrequent, true);
      });
    });

    // ===== AlertEvent Tests =====
    group('AlertEvent Model', () {
      test('AlertEvent creation', () {
        final event = AlertEvent(
          eventId: 'event1',
          alertId: 'alert1',
          occurredAt: DateTime.now(),
          message: 'Alert triggered',
          severity: 'high',
        );

        expect(event.eventId, 'event1');
        expect(event.isConfirmed, false);
      });

      test('AlertEvent isRecent computed property', () {
        final recent = AlertEvent(
          eventId: 'event1',
          alertId: 'alert1',
          occurredAt: DateTime.now().subtract(Duration(minutes: 15)),
          message: 'Alert',
          severity: 'warning',
        );

        expect(recent.isRecent, true);
      });
    });

    // ===== QueueEntry Tests =====
    group('QueueEntry Model', () {
      test('QueueEntry creation', () {
        final entry = QueueEntry(
          entryId: 'entry1',
          notificationId: 'notif1',
          channel: DeliveryChannel.email,
          enqueuedAt: DateTime.now(),
          status: 'queued',
        );

        expect(entry.entryId, 'entry1');
        expect(entry.isProcessing, false);
      });

      test('QueueEntry needsRetry computed property', () {
        final needsRetry = QueueEntry(
          entryId: 'entry1',
          notificationId: 'notif1',
          channel: DeliveryChannel.sms,
          enqueuedAt: DateTime.now(),
          status: 'failed',
          retryCount: 1,
        );

        expect(needsRetry.needsRetry, true);
      });
    });

    // ===== Notification Operations Tests =====
    group('Notification Operations', () {
      test('Send notification', () async {
        final notif = await notificationFacade.sendNotification(
          'user1',
          'Welcome',
          'Welcome to our app',
          NotificationType.success,
        );

        expect(notif.userId, 'user1');
        expect(notif.title, 'Welcome');
      });

      test('Get user notifications', () async {
        await notificationFacade.sendNotification(
          'user1',
          'Notif1',
          'Message1',
          NotificationType.info,
        );
        await notificationFacade.sendNotification(
          'user1',
          'Notif2',
          'Message2',
          NotificationType.warning,
        );

        final notifs = await notificationFacade.getUserNotifications('user1');
        expect(notifs.length, greaterThanOrEqualTo(2));
      });

      test('Mark notification as read', () async {
        final notif = await notificationFacade.sendNotification(
          'user1',
          'Test',
          'Test message',
          NotificationType.info,
        );

        await notificationFacade.markAsRead(notif.notificationId);

        final retrieved = await notificationFacade.getNotification(notif.notificationId);
        expect(retrieved!.isRead, true);
      });
    });

    // ===== Preference Tests =====
    group('User Preference Management', () {
      test('Set and get user preference', () async {
        final pref = NotificationPreference(
          preferenceId: 'pref1',
          userId: 'user1',
          channelPreferences: {
            DeliveryChannel.email: true,
            DeliveryChannel.sms: false,
          },
          typePreferences: {NotificationType.alert: true},
          emailNotifications: true,
          smsNotifications: false,
          createdAt: DateTime.now(),
        );

        await notificationFacade.setUserPreference('user1', pref);
        final retrieved = await notificationFacade.getUserPreference('user1');

        expect(retrieved, isNotNull);
        expect(retrieved!.emailNotifications, true);
      });
    });

    // ===== Alert Tests =====
    group('Alert Management', () {
      test('Create alert', () async {
        await notificationFacade.createAlert(
          'High Error Rate',
          AlertType.errorRate,
          'error_rate > 5%',
        );

        final alerts = await notificationFacade.getAllAlerts();
        expect(alerts.isNotEmpty, true);
      });

      test('Get alert by ID', () async {
        await notificationFacade.createAlert(
          'CPU Alert',
          AlertType.threshold,
          'cpu > 90%',
        );

        final alerts = await notificationFacade.getAllAlerts();
        expect(alerts.isNotEmpty, true);
      });
    });

    // ===== Template Tests =====
    group('Template Management', () {
      test('Create template', () async {
        final template = NotificationTemplate(
          templateId: 'template1',
          templateName: 'Welcome Email',
          titleTemplate: 'Welcome {{userName}}',
          messageTemplate: 'Hello {{userName}}, welcome to {{appName}}!',
          notificationType: NotificationType.success,
          channels: [DeliveryChannel.email, DeliveryChannel.inApp],
          createdAt: DateTime.now(),
        );

        await notificationFacade.createTemplate(template);
        final retrieved = await notificationFacade.getTemplate('template1');

        expect(retrieved, isNotNull);
        expect(retrieved!.templateName, 'Welcome Email');
      });

      test('Get all templates', () async {
        final template1 = NotificationTemplate(
          templateId: 'template1',
          templateName: 'Template1',
          titleTemplate: 'Title1',
          messageTemplate: 'Message1',
          notificationType: NotificationType.info,
          channels: [DeliveryChannel.inApp],
          createdAt: DateTime.now(),
        );

        final template2 = NotificationTemplate(
          templateId: 'template2',
          templateName: 'Template2',
          titleTemplate: 'Title2',
          messageTemplate: 'Message2',
          notificationType: NotificationType.warning,
          channels: [DeliveryChannel.email],
          createdAt: DateTime.now(),
        );

        await notificationFacade.createTemplate(template1);
        await notificationFacade.createTemplate(template2);

        final templates = await notificationFacade.getAllTemplates();
        expect(templates.length, greaterThanOrEqualTo(2));
      });
    });

    // ===== Report Tests =====
    group('Report Generation', () {
      test('Generate notification report', () async {
        final report = await notificationFacade.generateReport();

        expect(report, isNotNull);
        expect(report.reportId, isNotEmpty);
        expect(report.stats.totalNotifications, greaterThanOrEqualTo(0));
      });

      test('Report toMarkdown output', () async {
        final report = await notificationFacade.generateReport();
        final markdown = report.toMarkdown();

        expect(markdown.contains('Notification Report'), true);
        expect(markdown.contains('Summary'), true);
        expect(markdown.contains('Delivery Rate'), true);
      });

      test('Get latest report', () async {
        await notificationFacade.generateReport();
        final latest = await notificationFacade.getLatestReport();

        expect(latest, isNotNull);
      });
    });

    // ===== Channel Configuration Tests =====
    group('Channel Configuration', () {
      test('Configure delivery channel', () async {
        await notificationFacade.configureChannel(
          DeliveryChannel.email,
          {'smtp_server': 'smtp.example.com', 'port': 587},
        );

        final config = await notificationFacade.getChannelConfig(DeliveryChannel.email);
        expect(config, isNotNull);
        expect(config!.channel, DeliveryChannel.email);
      });
    });

    // ===== Integration Tests =====
    group('Integration Tests', () {
      test('Complete notification workflow', () async {
        // Create preference
        final pref = NotificationPreference(
          preferenceId: 'pref1',
          userId: 'user1',
          channelPreferences: {DeliveryChannel.email: true},
          typePreferences: {},
          emailNotifications: true,
          createdAt: DateTime.now(),
        );
        await notificationFacade.setUserPreference('user1', pref);

        // Send notification
        final notif = await notificationFacade.sendNotification(
          'user1',
          'Test',
          'Test message',
          NotificationType.info,
        );

        // Mark as read
        await notificationFacade.markAsRead(notif.notificationId);

        // Verify
        final retrieved = await notificationFacade.getNotification(notif.notificationId);
        expect(retrieved!.isRead, true);
      });

      test('Alert workflow', () async {
        // Create alert
        await notificationFacade.createAlert(
          'Performance Degradation',
          AlertType.performanceDegradation,
          'response_time > 1000ms',
        );

        // Verify
        final alerts = await notificationFacade.getAllAlerts();
        expect(alerts.isNotEmpty, true);
      });

      test('Template and notification with template', () async {
        // Create template
        final template = NotificationTemplate(
          templateId: 'welcome_template',
          templateName: 'Welcome',
          titleTemplate: 'Welcome {{name}}',
          messageTemplate: 'Hello {{name}}!',
          notificationType: NotificationType.success,
          channels: [DeliveryChannel.inApp, DeliveryChannel.email],
          createdAt: DateTime.now(),
        );
        await notificationFacade.createTemplate(template);

        // Verify template
        final retrieved = await notificationFacade.getTemplate('welcome_template');
        expect(retrieved!.isEnabled, true);
      });
    });

    // ===== Edge Cases =====
    group('Edge Cases', () {
      test('Notification with special characters', () async {
        final notif = await notificationFacade.sendNotification(
          'user1',
          'Test "Special" Characters & Symbols',
          'Message with <html> & "quotes"',
          NotificationType.info,
        );

        expect(notif.title.contains('Special'), true);
      });

      test('Multiple notifications for same user', () async {
        for (int i = 0; i < 10; i++) {
          await notificationFacade.sendNotification(
            'user1',
            'Notification $i',
            'Message $i',
            NotificationType.info,
          );
        }

        final notifs = await notificationFacade.getUserNotifications('user1');
        expect(notifs.length, greaterThanOrEqualTo(10));
      });

      test('Alert with many recipients', () {
        final recipients = List.generate(50, (i) => 'user$i@example.com');
        final alert = Alert(
          alertId: 'alert1',
          alertName: 'Broadcast Alert',
          alertType: AlertType.custom,
          condition: 'test',
          severity: PriorityLevel.critical,
          recipients: recipients,
          notificationChannels: [DeliveryChannel.email],
          createdAt: DateTime.now(),
        );

        expect(alert.recipients.length, 50);
      });

      test('Template with many parameters', () {
        final template = NotificationTemplate(
          templateId: 'complex_template',
          templateName: 'Complex',
          titleTemplate: 'Order {{orderId}} for {{customerName}}',
          messageTemplate: '''
            Order ID: {{orderId}}
            Customer: {{customerName}}
            Amount: {{amount}}
            Status: {{status}}
            Delivery: {{deliveryDate}}
          ''',
          notificationType: NotificationType.info,
          channels: [DeliveryChannel.email, DeliveryChannel.sms, DeliveryChannel.pushNotification],
          createdAt: DateTime.now(),
        );

        expect(template.channelCount, 3);
      });

      test('Notification age calculation for very old notification', () {
        final created = DateTime.now().subtract(Duration(days: 30));
        final notif = Notification(
          notificationId: 'notif1',
          userId: 'user1',
          title: 'Old',
          message: 'Old message',
          notificationType: NotificationType.info,
          createdAt: created,
        );

        expect(notif.ageInHours > 700, true);
        expect(notif.isOld, true);
      });
    });

    // ===== Error Handling Tests =====
    group('Error Handling', () {
      test('Get non-existent notification', () async {
        final notif = await notificationFacade.getNotification('nonexistent');
        expect(notif, isNull);
      });

      test('Get non-existent template', () async {
        final template = await notificationFacade.getTemplate('nonexistent');
        expect(template, isNull);
      });

      test('Get non-existent alert', () async {
        final alert = await notificationFacade.getAlert('nonexistent');
        expect(alert, isNull);
      });

      test('Get non-existent preference', () async {
        final pref = await notificationFacade.getUserPreference('nonexistent_user');
        expect(pref, isNull);
      });

      test('Empty notifications list', () async {
        final notifs = await notificationFacade.getUserNotifications('user_with_no_notifications');
        expect(notifs, isEmpty);
      });
    });

    // ===== Stats Tests =====
    group('Notification Statistics', () {
      test('Stats health check', () {
        final healthy = NotificationStats(
          statsId: 'stats1',
          totalNotifications: 1000,
          sentNotifications: 950,
          deliveredNotifications: 900,
          readNotifications: 800,
          failedNotifications: 50,
          periodStart: DateTime.now().subtract(Duration(days: 1)),
          periodEnd: DateTime.now(),
          deliveryRate: 0.95,
          readRate: 0.89,
          averageDeliveryTimeSeconds: 5,
        );

        expect(healthy.isHealthy, true);
        expect(healthy.deliveryRatePercentage, 95.0);
      });

      test('Stats with poor delivery rate', () {
        final poor = NotificationStats(
          statsId: 'stats1',
          totalNotifications: 100,
          sentNotifications: 50,
          deliveredNotifications: 20,
          readNotifications: 10,
          failedNotifications: 50,
          periodStart: DateTime.now().subtract(Duration(days: 1)),
          periodEnd: DateTime.now(),
          deliveryRate: 0.2,
          readRate: 0.1,
          averageDeliveryTimeSeconds: 100,
        );

        expect(poor.isHealthy, false);
        expect(poor.failureRate, 0.5);
      });
    });

    // ===== Delivery Channel Tests =====
    group('Delivery Channel Tests', () {
      test('In-app notification delivery', () async {
        final notif = await notificationFacade.sendNotification(
          'user1',
          'In-App',
          'This is an in-app notification',
          NotificationType.info,
        );

        expect(notif.notificationType, NotificationType.info);
      });

      test('Multi-channel template', () async {
        final template = NotificationTemplate(
          templateId: 'multi_channel',
          templateName: 'Multi-Channel',
          titleTemplate: 'Multi-Channel Notification',
          messageTemplate: 'This goes to multiple channels',
          notificationType: NotificationType.alert,
          channels: [
            DeliveryChannel.email,
            DeliveryChannel.sms,
            DeliveryChannel.pushNotification,
            DeliveryChannel.slack,
          ],
          createdAt: DateTime.now(),
        );

        await notificationFacade.createTemplate(template);
        final retrieved = await notificationFacade.getTemplate('multi_channel');

        expect(retrieved!.channelCount, 4);
      });
    });
  });
}
