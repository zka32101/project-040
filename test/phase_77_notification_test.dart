import 'package:test/test.dart';
import 'package:project_040/models/notification_models.dart';
import 'package:project_040/services/notification_messaging_service.dart';

void main() {
  group('Phase 77: Real-time Notification & Messaging', () {
    late NotificationRepositoryImpl repository;

    setUp(() {
      repository = NotificationRepositoryImpl();
    });

    // Enum Tests
    group('Enum Tests', () {
      test('NotificationChannel has all values', () {
        expect(NotificationChannel.values.length, 7);
        expect(NotificationChannel.values, contains(NotificationChannel.email));
        expect(NotificationChannel.values, contains(NotificationChannel.sms));
        expect(NotificationChannel.values, contains(NotificationChannel.push));
      });

      test('NotificationStatus has all values', () {
        expect(NotificationStatus.values.length, 6);
        expect(NotificationStatus.values, contains(NotificationStatus.pending));
        expect(NotificationStatus.values, contains(NotificationStatus.delivered));
      });

      test('NotificationPriority has all values', () {
        expect(NotificationPriority.values.length, 5);
      });

      test('MessageType has all values', () {
        expect(MessageType.values.length, 6);
      });

      test('SubscriptionStatus has all values', () {
        expect(SubscriptionStatus.values.length, 5);
      });

      test('NotificationTopic has all values', () {
        expect(NotificationTopic.values.length, 6);
      });
    });

    // Model Tests
    group('Model Tests', () {
      test('Notification model creation', () {
        final notif = Notification(
          notificationId: 'n1',
          recipientId: 'user1',
          title: 'Alert',
          message: 'Test message',
          channel: NotificationChannel.email,
          status: NotificationStatus.pending,
          priority: NotificationPriority.high,
          createdAt: DateTime.now(),
          metadata: {},
        );
        expect(notif.isPending, true);
        expect(notif.isUrgent, true);
      });

      test('Message model creation', () {
        final msg = Message(
          messageId: 'm1',
          senderId: 'sender1',
          recipientId: 'recipient1',
          content: 'Hello',
          type: MessageType.alert,
          createdAt: DateTime.now(),
          attachmentIds: [],
          context: {},
        );
        expect(msg.isUnread, true);
      });

      test('Subscription model creation', () {
        final sub = Subscription(
          subscriptionId: 's1',
          userId: 'user1',
          topic: NotificationTopic.incident,
          channels: [NotificationChannel.email],
          status: SubscriptionStatus.active,
          createdAt: DateTime.now(),
        );
        expect(sub.isActive, true);
      });

      test('NotificationTemplate model', () {
        final tpl = NotificationTemplate(
          templateId: 't1',
          name: 'Alert Template',
          title: 'Alert',
          messageTemplate: 'Alert: {{message}}',
          topic: NotificationTopic.incident,
          defaultPriority: NotificationPriority.high,
          supportedChannels: [NotificationChannel.email],
          createdAt: DateTime.now(),
          placeholders: {'message': 'The alert message'},
        );
        expect(tpl.isUsable, true);
      });

      test('NotificationSchedule model', () {
        final schedule = NotificationSchedule(
          scheduleId: 'sch1',
          notificationId: 'n1',
          scheduledTime: DateTime.now().add(Duration(hours: 1)),
          isRecurring: false,
        );
        expect(schedule.isPending, true);
      });

      test('NotificationPreference model', () {
        final pref = NotificationPreference(
          preferenceId: 'p1',
          userId: 'user1',
          channelPreferences: {NotificationChannel.email: true},
          topicPreferences: {NotificationTopic.incident: true},
          lastModified: DateTime.now(),
        );
        expect(pref.enabledChannels, 1);
      });

      test('NotificationBatch model', () {
        final batch = NotificationBatch(
          batchId: 'b1',
          notificationIds: ['n1', 'n2'],
          totalCount: 2,
          successCount: 2,
          failureCount: 0,
          createdAt: DateTime.now(),
          status: 'completed',
        );
        expect(batch.successRate, 100.0);
      });

      test('NotificationLog model', () {
        final log = NotificationLog(
          logId: 'l1',
          notificationId: 'n1',
          timestamp: DateTime.now(),
          eventType: 'sent',
          details: {},
        );
        expect(log.hasError, false);
      });

      test('NotificationAnalytics model', () {
        final analytics = NotificationAnalytics(
          analyticsId: 'a1',
          periodStart: DateTime.now().subtract(Duration(days: 1)),
          periodEnd: DateTime.now(),
          totalSent: 100,
          totalDelivered: 95,
          totalFailed: 5,
          deliveryRate: 95.0,
          channelBreakdown: {},
          topicBreakdown: {},
          averageDeliveryTimeMs: 150.0,
        );
        expect(analytics.failureRate, 5.0);
      });
    });

    // Notification Management Tests
    group('Notification Management', () {
      test('createNotification creates new notification', () async {
        final notif = await repository.createNotification(
          'user1',
          'Test Alert',
          'This is a test',
          NotificationChannel.email,
          NotificationPriority.high,
        );
        expect(notif.recipientId, 'user1');
        expect(notif.status, NotificationStatus.pending);
      });

      test('getNotification retrieves notification', () async {
        final created = await repository.createNotification(
          'user1',
          'Test',
          'Message',
          NotificationChannel.email,
          NotificationPriority.normal,
        );
        final retrieved = await repository.getNotification(created.notificationId);
        expect(retrieved, isNotNull);
      });

      test('updateNotificationStatus changes status', () async {
        final notif = await repository.createNotification(
          'user1',
          'Test',
          'Message',
          NotificationChannel.email,
          NotificationPriority.normal,
        );
        final updated = await repository.updateNotificationStatus(
          notif.notificationId,
          NotificationStatus.sent,
        );
        expect(updated.status, NotificationStatus.sent);
      });

      test('deleteNotification removes notification', () async {
        final notif = await repository.createNotification(
          'user1',
          'Test',
          'Message',
          NotificationChannel.email,
          NotificationPriority.normal,
        );
        await repository.deleteNotification(notif.notificationId);
        final retrieved = await repository.getNotification(notif.notificationId);
        expect(retrieved, isNull);
      });

      test('listNotifications returns limited list', () async {
        for (int i = 0; i < 10; i++) {
          await repository.createNotification(
            'user1',
            'Test',
            'Message',
            NotificationChannel.email,
            NotificationPriority.normal,
          );
        }
        final list = await repository.listNotifications('user1', limit: 5);
        expect(list.length, 5);
      });

      test('getPendingNotifications returns pending', () async {
        await repository.createNotification(
          'user1',
          'Test',
          'Message',
          NotificationChannel.email,
          NotificationPriority.normal,
        );
        final pending = await repository.getPendingNotifications();
        expect(pending.isNotEmpty, true);
      });

      test('getFailedNotifications returns failed', () async {
        final notif = await repository.createNotification(
          'user1',
          'Test',
          'Message',
          NotificationChannel.email,
          NotificationPriority.normal,
        );
        await repository.updateNotificationStatus(
          notif.notificationId,
          NotificationStatus.failed,
        );
        final failed = await repository.getFailedNotifications();
        expect(failed.isNotEmpty, true);
      });

      test('getNotificationsByChannel filters by channel', () async {
        await repository.createNotification(
          'user1',
          'Test',
          'Message',
          NotificationChannel.email,
          NotificationPriority.normal,
        );
        final email = await repository.getNotificationsByChannel(NotificationChannel.email);
        expect(email.isNotEmpty, true);
      });

      test('getNotificationCount returns count', () async {
        final initial = await repository.getNotificationCount();
        await repository.createNotification(
          'user1',
          'Test',
          'Message',
          NotificationChannel.email,
          NotificationPriority.normal,
        );
        final updated = await repository.getNotificationCount();
        expect(updated, greaterThan(initial));
      });

      test('getNotificationsByFilter applies filters', () async {
        await repository.createNotification(
          'user1',
          'Test',
          'Message',
          NotificationChannel.email,
          NotificationPriority.normal,
        );
        final filtered = await repository.getNotificationsByFilter(
          NotificationTopic.incident,
          'user1',
        );
        expect(filtered is List, true);
      });
    });

    // Message Management Tests
    group('Message Management', () {
      test('createMessage creates new message', () async {
        final msg = await repository.createMessage(
          'sender1',
          'recipient1',
          'Hello',
          MessageType.alert,
        );
        expect(msg.content, 'Hello');
        expect(msg.isUnread, true);
      });

      test('getMessage retrieves message', () async {
        final created = await repository.createMessage(
          'sender1',
          'recipient1',
          'Hello',
          MessageType.alert,
        );
        final retrieved = await repository.getMessage(created.messageId);
        expect(retrieved, isNotNull);
      });

      test('markAsRead marks message read', () async {
        final msg = await repository.createMessage(
          'sender1',
          'recipient1',
          'Hello',
          MessageType.alert,
        );
        final read = await repository.markAsRead(msg.messageId);
        expect(read.isRead, true);
      });

      test('deleteMessage removes message', () async {
        final msg = await repository.createMessage(
          'sender1',
          'recipient1',
          'Hello',
          MessageType.alert,
        );
        await repository.deleteMessage(msg.messageId);
        final retrieved = await repository.getMessage(msg.messageId);
        expect(retrieved, isNull);
      });

      test('listMessages returns messages', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createMessage(
            'sender1',
            'user1',
            'Hello $i',
            MessageType.alert,
          );
        }
        final messages = await repository.listMessages('user1');
        expect(messages.isNotEmpty, true);
      });

      test('getUnreadMessages returns unread', () async {
        await repository.createMessage(
          'sender1',
          'user1',
          'Unread',
          MessageType.alert,
        );
        final unread = await repository.getUnreadMessages('user1');
        expect(unread.isNotEmpty, true);
      });

      test('getUnreadCount returns count', () async {
        await repository.createMessage(
          'sender1',
          'user1',
          'Message 1',
          MessageType.alert,
        );
        await repository.createMessage(
          'sender1',
          'user1',
          'Message 2',
          MessageType.alert,
        );
        final count = await repository.getUnreadCount('user1');
        expect(count, greaterThanOrEqualTo(2));
      });

      test('archiveMessage archives message', () async {
        final msg = await repository.createMessage(
          'sender1',
          'user1',
          'Archive me',
          MessageType.alert,
        );
        await repository.archiveMessage(msg.messageId);
        final archived = await repository.getArchivedMessages('user1');
        expect(archived.isNotEmpty, true);
      });

      test('getArchivedMessages returns archived', () async {
        final msg = await repository.createMessage(
          'sender1',
          'user1',
          'Archive',
          MessageType.alert,
        );
        await repository.archiveMessage(msg.messageId);
        final archived = await repository.getArchivedMessages('user1');
        expect(archived.any((m) => m.messageId == msg.messageId), true);
      });
    });

    // Subscription Management Tests
    group('Subscription Management', () {
      test('createSubscription creates subscription', () async {
        final sub = await repository.createSubscription(
          'user1',
          NotificationTopic.incident,
          [NotificationChannel.email],
        );
        expect(sub.userId, 'user1');
        expect(sub.isActive, true);
      });

      test('getSubscription retrieves subscription', () async {
        final created = await repository.createSubscription(
          'user1',
          NotificationTopic.incident,
          [NotificationChannel.email],
        );
        final retrieved = await repository.getSubscription(created.subscriptionId);
        expect(retrieved, isNotNull);
      });

      test('updateSubscriptionStatus changes status', () async {
        final sub = await repository.createSubscription(
          'user1',
          NotificationTopic.incident,
          [NotificationChannel.email],
        );
        final updated = await repository.updateSubscriptionStatus(
          sub.subscriptionId,
          SubscriptionStatus.paused,
        );
        expect(updated.isPaused, true);
      });

      test('deleteSubscription removes subscription', () async {
        final sub = await repository.createSubscription(
          'user1',
          NotificationTopic.incident,
          [NotificationChannel.email],
        );
        await repository.deleteSubscription(sub.subscriptionId);
        final retrieved = await repository.getSubscription(sub.subscriptionId);
        expect(retrieved, isNull);
      });

      test('getUserSubscriptions filters by user', () async {
        await repository.createSubscription(
          'user1',
          NotificationTopic.incident,
          [NotificationChannel.email],
        );
        final subs = await repository.getUserSubscriptions('user1');
        expect(subs.isNotEmpty, true);
      });

      test('getSubscriptionsByTopic filters by topic', () async {
        await repository.createSubscription(
          'user1',
          NotificationTopic.incident,
          [NotificationChannel.email],
        );
        final subs = await repository.getSubscriptionsByTopic(NotificationTopic.incident);
        expect(subs.isNotEmpty, true);
      });

      test('getActiveSubscriptions returns active', () async {
        await repository.createSubscription(
          'user1',
          NotificationTopic.incident,
          [NotificationChannel.email],
        );
        final active = await repository.getActiveSubscriptions();
        expect(active.isNotEmpty, true);
      });

      test('getSubscriptionCount returns count', () async {
        final initial = await repository.getSubscriptionCount();
        await repository.createSubscription(
          'user1',
          NotificationTopic.incident,
          [NotificationChannel.email],
        );
        final updated = await repository.getSubscriptionCount();
        expect(updated, greaterThan(initial));
      });
    });

    // Template Management Tests
    group('Template Management', () {
      test('createTemplate creates template', () async {
        final tpl = await repository.createTemplate(
          'Incident Alert',
          'Alert',
          'New incident detected',
          NotificationTopic.incident,
          NotificationPriority.high,
          [NotificationChannel.email],
        );
        expect(tpl.name, 'Incident Alert');
      });

      test('getTemplate retrieves template', () async {
        final created = await repository.createTemplate(
          'Test',
          'Title',
          'Message',
          NotificationTopic.incident,
          NotificationPriority.high,
          [NotificationChannel.email],
        );
        final retrieved = await repository.getTemplate(created.templateId);
        expect(retrieved, isNotNull);
      });

      test('updateTemplate modifies template', () async {
        final tpl = await repository.createTemplate(
          'Test',
          'Old Title',
          'Old Message',
          NotificationTopic.incident,
          NotificationPriority.high,
          [NotificationChannel.email],
        );
        await repository.updateTemplate(tpl.templateId, title: 'New Title');
        final updated = await repository.getTemplate(tpl.templateId);
        expect(updated!.title, 'New Title');
      });

      test('deleteTemplate removes template', () async {
        final tpl = await repository.createTemplate(
          'Test',
          'Title',
          'Message',
          NotificationTopic.incident,
          NotificationPriority.high,
          [NotificationChannel.email],
        );
        await repository.deleteTemplate(tpl.templateId);
        final retrieved = await repository.getTemplate(tpl.templateId);
        expect(retrieved, isNull);
      });

      test('listTemplates returns templates', () async {
        await repository.createTemplate(
          'Test1',
          'Title1',
          'Message1',
          NotificationTopic.incident,
          NotificationPriority.high,
          [NotificationChannel.email],
        );
        final templates = await repository.listTemplates();
        expect(templates.isNotEmpty, true);
      });

      test('getTemplatesByTopic filters by topic', () async {
        await repository.createTemplate(
          'Incident',
          'Title',
          'Message',
          NotificationTopic.incident,
          NotificationPriority.high,
          [NotificationChannel.email],
        );
        final templates = await repository.getTemplatesByTopic(NotificationTopic.incident);
        expect(templates.isNotEmpty, true);
      });

      test('getTemplateCount returns count', () async {
        final initial = await repository.getTemplateCount();
        await repository.createTemplate(
          'Test',
          'Title',
          'Message',
          NotificationTopic.incident,
          NotificationPriority.high,
          [NotificationChannel.email],
        );
        final updated = await repository.getTemplateCount();
        expect(updated, greaterThan(initial));
      });
    });

    // Schedule Management Tests
    group('Schedule Management', () {
      test('scheduleNotification creates schedule', () async {
        final schedule = await repository.scheduleNotification(
          'notif_123',
          DateTime.now().add(Duration(hours: 1)),
        );
        expect(schedule.notificationId, 'notif_123');
        expect(schedule.isPending, true);
      });

      test('getSchedule retrieves schedule', () async {
        final created = await repository.scheduleNotification(
          'notif_123',
          DateTime.now().add(Duration(hours: 1)),
        );
        final retrieved = await repository.getSchedule(created.scheduleId);
        expect(retrieved, isNotNull);
      });

      test('updateSchedule changes time', () async {
        final schedule = await repository.scheduleNotification(
          'notif_123',
          DateTime.now().add(Duration(hours: 1)),
        );
        final newTime = DateTime.now().add(Duration(hours: 2));
        await repository.updateSchedule(schedule.scheduleId, newTime);
        final updated = await repository.getSchedule(schedule.scheduleId);
        expect(updated!.scheduledTime, newTime);
      });

      test('deleteSchedule removes schedule', () async {
        final schedule = await repository.scheduleNotification(
          'notif_123',
          DateTime.now().add(Duration(hours: 1)),
        );
        await repository.deleteSchedule(schedule.scheduleId);
        final retrieved = await repository.getSchedule(schedule.scheduleId);
        expect(retrieved, isNull);
      });

      test('getUpcomingSchedules returns future schedules', () async {
        await repository.scheduleNotification(
          'notif_123',
          DateTime.now().add(Duration(hours: 1)),
        );
        final upcoming = await repository.getUpcomingSchedules();
        expect(upcoming.isNotEmpty, true);
      });

      test('getExpiredSchedules returns expired', () async {
        final schedule = await repository.scheduleNotification(
          'notif_123',
          DateTime.now().add(Duration(hours: 1)),
          pattern: 'daily',
        );
        final expired = await repository.getExpiredSchedules();
        expect(expired is List, true);
      });

      test('getScheduleCount returns count', () async {
        final initial = await repository.getScheduleCount();
        await repository.scheduleNotification(
          'notif_123',
          DateTime.now().add(Duration(hours: 1)),
        );
        final updated = await repository.getScheduleCount();
        expect(updated, greaterThan(initial));
      });
    });

    // Preference Management Tests
    group('Preference Management', () {
      test('createPreference creates preference', () async {
        final pref = await repository.createPreference('user1');
        expect(pref.userId, 'user1');
      });

      test('getPreference retrieves preference', () async {
        final created = await repository.createPreference('user1');
        final retrieved = await repository.getPreference(created.preferenceId);
        expect(retrieved, isNotNull);
      });

      test('updateChannelPreference modifies channel', () async {
        final pref = await repository.createPreference('user1');
        await repository.updateChannelPreference(
          pref.preferenceId,
          NotificationChannel.email,
          true,
        );
        final updated = await repository.getPreference(pref.preferenceId);
        expect(updated!.enabledChannels, 1);
      });

      test('updateTopicPreference modifies topic', () async {
        final pref = await repository.createPreference('user1');
        await repository.updateTopicPreference(
          pref.preferenceId,
          NotificationTopic.incident,
          true,
        );
        final updated = await repository.getPreference(pref.preferenceId);
        expect(updated!.enabledTopics, 1);
      });

      test('deletePreference removes preference', () async {
        final pref = await repository.createPreference('user1');
        await repository.deletePreference(pref.preferenceId);
        final retrieved = await repository.getPreference(pref.preferenceId);
        expect(retrieved, isNull);
      });

      test('getUserPreferences returns user preferences', () async {
        await repository.createPreference('user1');
        final prefs = await repository.getUserPreferences('user1');
        expect(prefs.isNotEmpty, true);
      });
    });

    // Batch Operations Tests
    group('Batch Operations', () {
      test('createBatch creates batch', () async {
        final batch = await repository.createBatch(['n1', 'n2', 'n3']);
        expect(batch.totalCount, 3);
      });

      test('getBatch retrieves batch', () async {
        final created = await repository.createBatch(['n1', 'n2']);
        final retrieved = await repository.getBatch(created.batchId);
        expect(retrieved, isNotNull);
      });

      test('updateBatchStatus updates counts', () async {
        final batch = await repository.createBatch(['n1', 'n2']);
        final updated = await repository.updateBatchStatus(batch.batchId, 2, 0);
        expect(updated.successRate, 100.0);
      });

      test('deleteBatch removes batch', () async {
        final batch = await repository.createBatch(['n1', 'n2']);
        await repository.deleteBatch(batch.batchId);
        final retrieved = await repository.getBatch(batch.batchId);
        expect(retrieved, isNull);
      });

      test('listBatches returns batches', () async {
        await repository.createBatch(['n1', 'n2']);
        final batches = await repository.listBatches();
        expect(batches.isNotEmpty, true);
      });

      test('getBatchCount returns count', () async {
        final initial = await repository.getBatchCount();
        await repository.createBatch(['n1', 'n2']);
        final updated = await repository.getBatchCount();
        expect(updated, greaterThan(initial));
      });
    });

    // Logging & Analytics Tests
    group('Logging & Analytics', () {
      test('recordLog records event', () async {
        final log = await repository.recordLog('notif_123', 'sent');
        expect(log.eventType, 'sent');
      });

      test('getLog retrieves log', () async {
        final created = await repository.recordLog('notif_123', 'sent');
        final retrieved = await repository.getLog(created.logId);
        expect(retrieved, isNotNull);
      });

      test('getLogsByNotification returns logs', () async {
        await repository.recordLog('notif_123', 'created');
        await repository.recordLog('notif_123', 'sent');
        final logs = await repository.getLogsByNotification('notif_123');
        expect(logs.length, 2);
      });

      test('getErrorLogs returns errors', () async {
        await repository.recordLog('notif_123', 'sent', errorMessage: 'Failed');
        final errors = await repository.getErrorLogs();
        expect(errors.isNotEmpty, true);
      });

      test('getLogCount returns count', () async {
        final initial = await repository.getLogCount();
        await repository.recordLog('notif_123', 'sent');
        final updated = await repository.getLogCount();
        expect(updated, greaterThan(initial));
      });

      test('generateAnalytics creates report', () async {
        final now = DateTime.now();
        await repository.createNotification(
          'user1',
          'Test',
          'Message',
          NotificationChannel.email,
          NotificationPriority.normal,
        );
        final analytics = await repository.generateAnalytics(
          now.subtract(Duration(days: 1)),
          now,
        );
        expect(analytics.totalSent, greaterThanOrEqualTo(1));
      });
    });

    // Engine Tests
    group('Engine Tests', () {
      test('NotificationDistributionEngine distributes', () async {
        final engine = NotificationDistributionEngine();
        final notif = Notification(
          notificationId: 'n1',
          recipientId: 'user1',
          title: 'Test',
          message: 'Message',
          channel: NotificationChannel.email,
          status: NotificationStatus.pending,
          priority: NotificationPriority.normal,
          createdAt: DateTime.now(),
          metadata: {},
        );
        final result = await engine.distributeNotification(notif);
        expect(result.notificationId, 'n1');
      });

      test('MessageQueueEngine queues message', () async {
        final engine = MessageQueueEngine();
        final msg = Message(
          messageId: 'm1',
          senderId: 'sender',
          recipientId: 'recipient',
          content: 'Hello',
          type: MessageType.alert,
          createdAt: DateTime.now(),
          attachmentIds: [],
          context: {},
        );
        final result = await engine.queueMessage(msg);
        expect(result.messageId, 'm1');
      });

      test('SubscriptionEngine evaluates subscriptions', () async {
        final engine = SubscriptionEngine();
        final subs = await engine.evaluateSubscriptions(NotificationTopic.incident);
        expect(subs is List, true);
      });

      test('SchedulingEngine schedules delivery', () async {
        final engine = SchedulingEngine();
        final schedule = NotificationSchedule(
          scheduleId: 'sch1',
          notificationId: 'n1',
          scheduledTime: DateTime.now().add(Duration(hours: 1)),
        );
        final result = await engine.scheduleForDelivery(schedule);
        expect(result.scheduleId, 'sch1');
      });

      test('PreferenceEngine respects preferences', () async {
        final engine = PreferenceEngine();
        final notif = Notification(
          notificationId: 'n1',
          recipientId: 'user1',
          title: 'Test',
          message: 'Message',
          channel: NotificationChannel.email,
          status: NotificationStatus.pending,
          priority: NotificationPriority.normal,
          createdAt: DateTime.now(),
          metadata: {},
        );
        final pref = NotificationPreference(
          preferenceId: 'p1',
          userId: 'user1',
          channelPreferences: {NotificationChannel.email: true},
          topicPreferences: {},
          lastModified: DateTime.now(),
        );
        final respects = await engine.respectsPreferences(notif, pref);
        expect(respects, true);
      });
    });

    // Facade Tests
    group('Facade Tests', () {
      test('Facade sendNotification', () async {
        final manager = NotificationManager(
          repository: repository,
          distributionEngine: NotificationDistributionEngine(),
          messageEngine: MessageQueueEngine(),
          subscriptionEngine: SubscriptionEngine(),
          schedulingEngine: SchedulingEngine(),
          preferenceEngine: PreferenceEngine(),
        );
        final facade = NotificationFacade(repository: repository, manager: manager);
        
        final notif = await facade.sendNotification(
          'user1',
          'Test',
          'Message',
          NotificationChannel.email,
        );
        expect(notif.recipientId, 'user1');
      });

      test('Facade getNotifications', () async {
        final manager = NotificationManager(
          repository: repository,
          distributionEngine: NotificationDistributionEngine(),
          messageEngine: MessageQueueEngine(),
          subscriptionEngine: SubscriptionEngine(),
          schedulingEngine: SchedulingEngine(),
          preferenceEngine: PreferenceEngine(),
        );
        final facade = NotificationFacade(repository: repository, manager: manager);
        
        await repository.createNotification(
          'user1',
          'Test',
          'Message',
          NotificationChannel.email,
          NotificationPriority.normal,
        );
        final notifs = await facade.getNotifications('user1');
        expect(notifs is List<Notification>, true);
      });

      test('Facade sendMessage', () async {
        final manager = NotificationManager(
          repository: repository,
          distributionEngine: NotificationDistributionEngine(),
          messageEngine: MessageQueueEngine(),
          subscriptionEngine: SubscriptionEngine(),
          schedulingEngine: SchedulingEngine(),
          preferenceEngine: PreferenceEngine(),
        );
        final facade = NotificationFacade(repository: repository, manager: manager);
        
        final msg = await facade.sendMessage('sender1', 'recipient1', 'Hello');
        expect(msg.content, 'Hello');
      });

      test('Facade getUnreadMessageCount', () async {
        final manager = NotificationManager(
          repository: repository,
          distributionEngine: NotificationDistributionEngine(),
          messageEngine: MessageQueueEngine(),
          subscriptionEngine: SubscriptionEngine(),
          schedulingEngine: SchedulingEngine(),
          preferenceEngine: PreferenceEngine(),
        );
        final facade = NotificationFacade(repository: repository, manager: manager);
        
        await repository.createMessage('sender', 'user1', 'Msg1', MessageType.alert);
        final count = await facade.getUnreadMessageCount('user1');
        expect(count, greaterThanOrEqualTo(1));
      });
    });

    // Integration Tests
    group('Integration Tests', () {
      test('Complete notification workflow', () async {
        final notif = await repository.createNotification(
          'user1',
          'Alert',
          'Something happened',
          NotificationChannel.email,
          NotificationPriority.high,
        );
        await repository.updateNotificationStatus(
          notif.notificationId,
          NotificationStatus.sent,
        );
        await repository.recordLog(notif.notificationId, 'sent');
        
        final retrieved = await repository.getNotification(notif.notificationId);
        expect(retrieved!.status, NotificationStatus.sent);
      });

      test('Message subscription workflow', () async {
        await repository.createSubscription(
          'user1',
          NotificationTopic.incident,
          [NotificationChannel.email],
        );
        final subs = await repository.getUserSubscriptions('user1');
        expect(subs.isNotEmpty, true);
      });

      test('Template and batch workflow', () async {
        final tpl = await repository.createTemplate(
          'Alert',
          'Alert',
          'Message',
          NotificationTopic.incident,
          NotificationPriority.high,
          [NotificationChannel.email],
        );
        final batch = await repository.createBatch(['n1', 'n2']);
        expect(tpl.isUsable, true);
        expect(batch.totalCount, 2);
      });
    });

    // Edge Case Tests
    group('Edge Case Tests', () {
      test('Empty notification title', () async {
        final notif = await repository.createNotification(
          'user1',
          '',
          'Message',
          NotificationChannel.email,
          NotificationPriority.normal,
        );
        expect(notif.title, '');
      });

      test('Null optional fields', () async {
        final notif = Notification(
          notificationId: 'n1',
          recipientId: 'user1',
          title: 'Test',
          message: 'Message',
          channel: NotificationChannel.email,
          status: NotificationStatus.pending,
          priority: NotificationPriority.normal,
          createdAt: DateTime.now(),
          metadata: {},
        );
        expect(notif.sentAt, isNull);
        expect(notif.relatedEntityId, isNull);
      });

      test('Empty list handling', () async {
        final messages = await repository.listMessages('nonexistent_user');
        expect(messages is List, true);
      });
    });

    // Performance Tests
    group('Performance Tests', () {
      test('Create 100 notifications efficiently', () async {
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 100; i++) {
          await repository.createNotification(
            'user1',
            'Test $i',
            'Message',
            NotificationChannel.email,
            NotificationPriority.normal,
          );
        }
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('List notifications efficiently', () async {
        for (int i = 0; i < 50; i++) {
          await repository.createNotification(
            'user1',
            'Test',
            'Message',
            NotificationChannel.email,
            NotificationPriority.normal,
          );
        }
        final stopwatch = Stopwatch()..start();
        await repository.listNotifications('user1', limit: 25);
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('Batch operations efficiently', () async {
        final stopwatch = Stopwatch()..start();
        await repository.createBatch(
          List.generate(100, (i) => 'notif_$i'),
        );
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}
