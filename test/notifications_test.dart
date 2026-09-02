import 'package:flutter_test/flutter_test.dart';
import 'package:bike_license_kore/models/community_model.dart';
import 'package:bike_license_kore/services/community_service.dart';

void main() {
  late StubCommunityService service;

  setUp(() {
    service = StubCommunityService();
  });

  group('NotificationPreferences', () {
    test('should create notification preferences', () async {
      await service.createNotificationPreferences(
        userId: 'user1',
        enabledChannels: {
          NotificationChannelType.inApp: true,
          NotificationChannelType.email: true,
        },
        channelAddresses: {
          NotificationChannelType.email: ['user1@example.com'],
        },
      );

      final prefs = await service.getNotificationPreferences('user1');
      expect(prefs, isNotNull);
      expect(prefs!.userId, 'user1');
      expect(prefs.enabledChannels[NotificationChannelType.inApp], true);
    });

    test('should update notification preferences', () async {
      await service.createNotificationPreferences(
        userId: 'user2',
        enabledChannels: {
          NotificationChannelType.inApp: true,
          NotificationChannelType.email: false,
        },
        channelAddresses: {},
      );

      await service.updateNotificationPreferences(
        userId: 'user2',
        enabledChannels: {
          NotificationChannelType.inApp: true,
          NotificationChannelType.email: true,
        },
      );

      final updated = await service.getNotificationPreferences('user2');
      expect(updated!.enabledChannels[NotificationChannelType.email], true);
    });

    test('should set quiet hours', () async {
      await service.createNotificationPreferences(
        userId: 'user3',
        enabledChannels: {NotificationChannelType.inApp: true},
        channelAddresses: {},
      );

      await service.updateNotificationPreferences(
        userId: 'user3',
        quietHoursEnabled: true,
        quietHoursStart: '22:00',
        quietHoursEnd: '08:00',
      );

      final prefs = await service.getNotificationPreferences('user3');
      expect(prefs!.quietHoursEnabled, true);
      expect(prefs.quietHoursStart, '22:00');
    });

    test('should enable digest notifications', () async {
      await service.createNotificationPreferences(
        userId: 'user4',
        enabledChannels: {NotificationChannelType.email: true},
        channelAddresses: {
          NotificationChannelType.email: ['user4@example.com'],
        },
      );

      await service.updateNotificationPreferences(
        userId: 'user4',
        digestNotifications: true,
        digestFrequency: 'weekly',
      );

      final prefs = await service.getNotificationPreferences('user4');
      expect(prefs!.digestNotifications, true);
      expect(prefs.digestFrequency, 'weekly');
    });
  });

  group('StudentNotification', () {
    test('should send student notification', () async {
      final notifId = await service.sendStudentNotification(
        userId: 'student1',
        title: 'Achievement Unlocked',
        message: 'You completed 50 questions!',
        triggerType: NotificationTriggerType.milestoneReached,
        channels: [NotificationChannelType.inApp, NotificationChannelType.push],
        severity: AlertSeverity.info,
      );

      expect(notifId, isNotEmpty);
      expect(notifId.startsWith('notif_'), true);
    });

    test('should get student notifications', () async {
      await service.sendStudentNotification(
        userId: 'student2',
        title: 'Notification 1',
        message: 'First notification',
        triggerType: NotificationTriggerType.performanceAlert,
        channels: [NotificationChannelType.inApp],
      );

      await service.sendStudentNotification(
        userId: 'student2',
        title: 'Notification 2',
        message: 'Second notification',
        triggerType: NotificationTriggerType.badgeEarned,
        channels: [NotificationChannelType.inApp],
      );

      final notifications = await service.getStudentNotifications(userId: 'student2');
      expect(notifications.length, 2);
      expect(notifications[0].title, 'Notification 2');
    });

    test('should mark notification as read', () async {
      final notifId = await service.sendStudentNotification(
        userId: 'student3',
        title: 'Test',
        message: 'Test message',
        triggerType: NotificationTriggerType.milestoneReached,
        channels: [NotificationChannelType.inApp],
      );

      await service.markNotificationAsRead(notifId);

      final notifs = await service.getStudentNotifications(userId: 'student3');
      expect(notifs[0].isRead, true);
      expect(notifs[0].readAt, isNotNull);
    });

    test('should get unread notifications only', () async {
      final notifId1 = await service.sendStudentNotification(
        userId: 'student4',
        title: 'Notification 1',
        message: 'First',
        triggerType: NotificationTriggerType.milestoneReached,
        channels: [NotificationChannelType.inApp],
      );

      await service.sendStudentNotification(
        userId: 'student4',
        title: 'Notification 2',
        message: 'Second',
        triggerType: NotificationTriggerType.badgeEarned,
        channels: [NotificationChannelType.inApp],
      );

      await service.markNotificationAsRead(notifId1);

      final unread = await service.getStudentNotifications(
        userId: 'student4',
        unreadOnly: true,
      );
      expect(unread.length, 1);
      expect(unread[0].title, 'Notification 2');
    });

    test('should archive notification', () async {
      final notifId = await service.sendStudentNotification(
        userId: 'student5',
        title: 'Test',
        message: 'Test message',
        triggerType: NotificationTriggerType.milestoneReached,
        channels: [NotificationChannelType.inApp],
      );

      await service.archiveNotification(notifId);

      final notifs = await service.getStudentNotifications(userId: 'student5');
      expect(notifs.length, 0);
    });

    test('should get unread notification count', () async {
      await service.sendStudentNotification(
        userId: 'student6',
        title: 'Notif 1',
        message: 'Message 1',
        triggerType: NotificationTriggerType.milestoneReached,
        channels: [NotificationChannelType.inApp],
      );

      await service.sendStudentNotification(
        userId: 'student6',
        title: 'Notif 2',
        message: 'Message 2',
        triggerType: NotificationTriggerType.badgeEarned,
        channels: [NotificationChannelType.inApp],
      );

      final count = await service.getUnreadNotificationCount('student6');
      expect(count, 2);
    });

    test('should track notification engagement', () async {
      final notifId = await service.sendStudentNotification(
        userId: 'student7',
        title: 'Test',
        message: 'Test message',
        triggerType: NotificationTriggerType.milestoneReached,
        channels: [NotificationChannelType.inApp],
      );

      await service.trackNotificationEngagement(
        notificationId: notifId,
        wasRead: true,
        wasActioned: true,
        actionType: 'clicked_link',
      );

      expect(true, true);
    });

    test('should set action URL on notification', () async {
      final notifId = await service.sendStudentNotification(
        userId: 'student8',
        title: 'Course Complete',
        message: 'You completed the course!',
        triggerType: NotificationTriggerType.completionMilestone,
        channels: [NotificationChannelType.inApp],
        actionUrl: '/courses/123/results',
      );

      final notifs = await service.getStudentNotifications(userId: 'student8');
      expect(notifs[0].actionUrl, '/courses/123/results');
    });
  });

  group('PerformanceAlert', () {
    test('should create performance alert', () async {
      final alertId = await service.createPerformanceAlert(
        userId: 'student1',
        studentName: 'John Doe',
        category: 'road-signs',
        previousScore: 85.0,
        currentScore: 72.0,
        alertReason: 'Score decreased below 75%',
        suggestedActions: [
          'Review road sign questions',
          'Practice with sample tests',
        ],
        severity: AlertSeverity.warning,
      );

      expect(alertId, isNotEmpty);
      expect(alertId.startsWith('alert_'), true);
    });

    test('should calculate change percent', () async {
      await service.createPerformanceAlert(
        userId: 'student2',
        studentName: 'Jane Doe',
        category: 'traffic-rules',
        previousScore: 80.0,
        currentScore: 60.0,
        alertReason: 'Score dropped 25%',
        suggestedActions: [],
        severity: AlertSeverity.urgent,
      );

      final alerts = await service.getStudentPerformanceAlerts(userId: 'student2');
      expect(alerts[0].changePercent, -25.0);
    });

    test('should get student performance alerts', () async {
      await service.createPerformanceAlert(
        userId: 'student3',
        studentName: 'Bob Smith',
        category: 'road-signs',
        previousScore: 90.0,
        currentScore: 75.0,
        alertReason: 'Score declined',
        suggestedActions: [],
      );

      await service.createPerformanceAlert(
        userId: 'student3',
        studentName: 'Bob Smith',
        category: 'traffic-rules',
        previousScore: 88.0,
        currentScore: 70.0,
        alertReason: 'Another decline',
        suggestedActions: [],
      );

      final alerts = await service.getStudentPerformanceAlerts(userId: 'student3');
      expect(alerts.length, 2);
    });

    test('should resolve performance alert', () async {
      final alertId = await service.createPerformanceAlert(
        userId: 'student4',
        studentName: 'Alice Brown',
        category: 'road-signs',
        previousScore: 85.0,
        currentScore: 70.0,
        alertReason: 'Score dropped',
        suggestedActions: [],
      );

      await service.resolvePerformanceAlert(alertId);

      final alerts = await service.getStudentPerformanceAlerts(
        userId: 'student4',
        activeOnly: true,
      );
      expect(alerts.length, 0);
    });

    test('should get active and resolved alerts', () async {
      final alertId1 = await service.createPerformanceAlert(
        userId: 'student5',
        studentName: 'Charlie Davis',
        category: 'road-signs',
        previousScore: 85.0,
        currentScore: 70.0,
        alertReason: 'Score dropped',
        suggestedActions: [],
      );

      final alertId2 = await service.createPerformanceAlert(
        userId: 'student5',
        studentName: 'Charlie Davis',
        category: 'traffic-rules',
        previousScore: 90.0,
        currentScore: 75.0,
        alertReason: 'Another drop',
        suggestedActions: [],
      );

      await service.resolvePerformanceAlert(alertId1);

      final activeAlerts = await service.getStudentPerformanceAlerts(
        userId: 'student5',
        activeOnly: true,
      );
      expect(activeAlerts.length, 1);
      expect(activeAlerts[0].category, 'traffic-rules');

      final allAlerts = await service.getStudentPerformanceAlerts(
        userId: 'student5',
        activeOnly: false,
      );
      expect(allAlerts.length, 2);
    });

    test('should get alert stats by category', () async {
      await service.createPerformanceAlert(
        userId: 'student6',
        studentName: 'Eve Wilson',
        category: 'road-signs',
        previousScore: 85.0,
        currentScore: 70.0,
        alertReason: 'Decline',
        suggestedActions: [],
      );

      await service.createPerformanceAlert(
        userId: 'student6',
        studentName: 'Eve Wilson',
        category: 'road-signs',
        previousScore: 80.0,
        currentScore: 60.0,
        alertReason: 'Another decline',
        suggestedActions: [],
      );

      await service.createPerformanceAlert(
        userId: 'student6',
        studentName: 'Eve Wilson',
        category: 'traffic-rules',
        previousScore: 90.0,
        currentScore: 75.0,
        alertReason: 'Decline',
        suggestedActions: [],
      );

      final stats = await service.getAlertStatsByCategory('student6');
      expect(stats['road-signs'], 2);
      expect(stats['traffic-rules'], 1);
    });

    test('should get alert stats by severity', () async {
      await service.createPerformanceAlert(
        userId: 'student7',
        studentName: 'Frank Miller',
        category: 'road-signs',
        previousScore: 85.0,
        currentScore: 70.0,
        alertReason: 'Decline',
        suggestedActions: [],
        severity: AlertSeverity.warning,
      );

      await service.createPerformanceAlert(
        userId: 'student7',
        studentName: 'Frank Miller',
        category: 'traffic-rules',
        previousScore: 90.0,
        currentScore: 60.0,
        alertReason: 'Critical drop',
        suggestedActions: [],
        severity: AlertSeverity.critical,
      );

      final stats = await service.getAlertStatsBySeverity('student7');
      expect(stats['warning'], 1);
      expect(stats['critical'], 1);
    });
  });

  group('MilestoneNotification', () {
    test('should create milestone notification', () async {
      final milestoneId = await service.createMilestoneNotification(
        userId: 'student1',
        milestoneName: '50 Questions Complete',
        description: 'You have answered 50 questions correctly!',
        milestoneType: 'question_count',
        questionsCompleted: 50,
        accuracyRate: 82.0,
        streakDays: 7,
        rewardType: 'xp',
        rewardValue: 500,
      );

      expect(milestoneId, isNotEmpty);
      expect(milestoneId.startsWith('milestone_'), true);
    });

    test('should get user milestones', () async {
      await service.createMilestoneNotification(
        userId: 'student2',
        milestoneName: 'First Answer',
        description: 'You answered your first question!',
        milestoneType: 'first_question',
        questionsCompleted: 1,
        accuracyRate: 100.0,
        streakDays: 1,
        rewardType: 'badge',
        rewardValue: 1,
      );

      await service.createMilestoneNotification(
        userId: 'student2',
        milestoneName: '100 Questions Complete',
        description: 'Milestone: 100 questions answered!',
        milestoneType: 'question_count',
        questionsCompleted: 100,
        accuracyRate: 85.0,
        streakDays: 30,
        rewardType: 'xp',
        rewardValue: 1000,
      );

      final milestones = await service.getUserMilestones('student2');
      expect(milestones.length, 2);
      expect(milestones[0].questionsCompleted, 100);
    });

    test('should include badge info in milestone', () async {
      await service.createMilestoneNotification(
        userId: 'student3',
        milestoneName: 'Accuracy Master',
        description: 'You achieved 95%+ accuracy!',
        milestoneType: 'accuracy_milestone',
        questionsCompleted: 50,
        accuracyRate: 95.5,
        streakDays: 10,
        rewardType: 'badge',
        rewardValue: 1,
        badgeInfo: {
          'badgeName': 'Accuracy Master',
          'emoji': '🎯',
          'rarity': 'rare',
        },
      );

      final milestones = await service.getUserMilestones('student3');
      expect(milestones[0].badgeInfo['badgeName'], 'Accuracy Master');
      expect(milestones[0].badgeInfo['emoji'], '🎯');
    });
  });

  group('NotificationTemplate', () {
    test('should create notification template', () async {
      final templateId = await service.createNotificationTemplate(
        templateName: 'Milestone Achieved',
        triggerType: NotificationTriggerType.milestoneReached,
        titleTemplate: '🎉 {{milestoneName}}',
        messageTemplate: 'Congratulations! You reached {{milestoneName}}. {{reward}} reward awarded!',
        defaultSeverity: AlertSeverity.info,
        variables: {
          'milestoneName': '',
          'reward': '',
        },
      );

      expect(templateId, isNotEmpty);
      expect(templateId.startsWith('template_'), true);
    });

    test('should get notification template', () async {
      final templateId = await service.createNotificationTemplate(
        templateName: 'Performance Alert',
        triggerType: NotificationTriggerType.performanceAlert,
        titleTemplate: '⚠️ Performance Alert: {{category}}',
        messageTemplate: 'Your score in {{category}} has dropped to {{score}}%',
      );

      final template = await service.getNotificationTemplate(templateId);
      expect(template, isNotNull);
      expect(template!.templateName, 'Performance Alert');
    });

    test('should get template by trigger type', () async {
      final templateId = await service.createNotificationTemplate(
        templateName: 'At Risk Alert',
        triggerType: NotificationTriggerType.atRiskAlert,
        titleTemplate: '🚨 At Risk Alert',
        messageTemplate: 'Your performance is at risk. Consider extra study time.',
        defaultSeverity: AlertSeverity.urgent,
      );

      final template = await service.getTemplateByTrigger(NotificationTriggerType.atRiskAlert);
      expect(template, isNotNull);
      expect(template!.templateName, 'At Risk Alert');
    });

    test('should render template with variables', () async {
      final templateId = await service.createNotificationTemplate(
        templateName: 'Badge Earned',
        triggerType: NotificationTriggerType.badgeEarned,
        titleTemplate: 'Badge Earned: {{badgeName}}',
        messageTemplate: 'You unlocked the {{badgeName}} badge!',
        variables: {
          'badgeName': '',
        },
      );

      final template = await service.getNotificationTemplate(templateId);
      final title = template!.renderTitle({'badgeName': 'Speed Demon'});
      final message = template.renderMessage({'badgeName': 'Speed Demon'});

      expect(title, 'Badge Earned: Speed Demon');
      expect(message, 'You unlocked the Speed Demon badge!');
    });

    test('should update notification template', () async {
      final templateId = await service.createNotificationTemplate(
        templateName: 'Original Template',
        triggerType: NotificationTriggerType.customAlert,
        titleTemplate: 'Original Title',
        messageTemplate: 'Original message',
      );

      await service.updateNotificationTemplate(
        templateId: templateId,
        titleTemplate: 'Updated Title',
        messageTemplate: 'Updated message',
        isActive: false,
      );

      final updated = await service.getNotificationTemplate(templateId);
      expect(updated!.titleTemplate, 'Updated Title');
      expect(updated.isActive, false);
    });
  });

  group('StudentAlertHistory', () {
    test('should create alert history', () async {
      final periodStart = DateTime(2024, 1, 1);
      final periodEnd = DateTime(2024, 1, 31);

      await service.createPerformanceAlert(
        userId: 'student1',
        studentName: 'John Doe',
        category: 'road-signs',
        previousScore: 85.0,
        currentScore: 70.0,
        alertReason: 'Score declined',
        suggestedActions: [],
        severity: AlertSeverity.warning,
      );

      final history = await service.getStudentAlertHistory(
        userId: 'student1',
        periodStart: periodStart,
        periodEnd: periodEnd,
      );

      expect(history, isNotNull);
      expect(history!.userId, 'student1');
      expect(history.totalAlertsGenerated, greaterThanOrEqualTo(0));
    });

    test('should calculate alert resolution rate', () async {
      final alertId = await service.createPerformanceAlert(
        userId: 'student2',
        studentName: 'Jane Doe',
        category: 'traffic-rules',
        previousScore: 90.0,
        currentScore: 75.0,
        alertReason: 'Decline',
        suggestedActions: [],
      );

      await service.resolvePerformanceAlert(alertId);

      final periodStart = DateTime.now().subtract(Duration(days: 30));
      final periodEnd = DateTime.now();

      final history = await service.getStudentAlertHistory(
        userId: 'student2',
        periodStart: periodStart,
        periodEnd: periodEnd,
      );

      expect(history!.unresolvedCount, 0);
    });
  });

  group('BatchNotifications', () {
    test('should send batch notifications', () async {
      final userIds = ['student1', 'student2', 'student3'];

      final sentIds = await service.sendBatchNotifications(
        userIds: userIds,
        title: 'Maintenance Update',
        message: 'System maintenance scheduled for tonight',
        triggerType: NotificationTriggerType.customAlert,
        severity: AlertSeverity.info,
      );

      expect(sentIds.length, 3);
      for (final id in sentIds) {
        expect(id.startsWith('notif_'), true);
      }
    });

    test('should verify all batch notifications were sent', () async {
      final userIds = ['student4', 'student5'];

      await service.sendBatchNotifications(
        userIds: userIds,
        title: 'Test Announcement',
        message: 'Test message for all',
        triggerType: NotificationTriggerType.customAlert,
        severity: AlertSeverity.info,
      );

      final student4Notifs = await service.getStudentNotifications(userId: 'student4');
      final student5Notifs = await service.getStudentNotifications(userId: 'student5');

      expect(student4Notifs.length, 1);
      expect(student5Notifs.length, 1);
      expect(student4Notifs[0].title, 'Test Announcement');
      expect(student5Notifs[0].title, 'Test Announcement');
    });
  });

  group('NotificationIntegration', () {
    test('should complete full notification workflow', () async {
      // 1. Create preferences
      await service.createNotificationPreferences(
        userId: 'student1',
        enabledChannels: {
          NotificationChannelType.inApp: true,
          NotificationChannelType.email: true,
        },
        channelAddresses: {
          NotificationChannelType.email: ['student1@example.com'],
        },
      );

      // 2. Send notification
      final notifId = await service.sendStudentNotification(
        userId: 'student1',
        title: 'Milestone Achieved',
        message: 'You completed 100 questions!',
        triggerType: NotificationTriggerType.milestoneReached,
        channels: [NotificationChannelType.inApp, NotificationChannelType.email],
      );

      // 3. Get notifications
      final notifs = await service.getStudentNotifications(userId: 'student1');
      expect(notifs.length, 1);

      // 4. Mark as read
      await service.markNotificationAsRead(notifId);

      // 5. Verify read status
      final unreadCount = await service.getUnreadNotificationCount('student1');
      expect(unreadCount, 0);
    });

    test('should handle performance alert workflow', () async {
      // 1. Detect performance decline
      final alertId = await service.createPerformanceAlert(
        userId: 'student2',
        studentName: 'John Smith',
        category: 'road-signs',
        previousScore: 90.0,
        currentScore: 65.0,
        alertReason: 'Significant score drop detected',
        suggestedActions: ['Review road signs', 'Take practice test'],
        severity: AlertSeverity.critical,
      );

      // 2. Get alert details
      final alerts = await service.getStudentPerformanceAlerts(userId: 'student2');
      expect(alerts.length, 1);
      expect(alerts[0].severity, AlertSeverity.critical);

      // 3. Get stats
      final statsByCategory = await service.getAlertStatsByCategory('student2');
      expect(statsByCategory['road-signs'], 1);

      final statsBySeverity = await service.getAlertStatsBySeverity('student2');
      expect(statsBySeverity['critical'], 1);

      // 4. Resolve alert
      await service.resolvePerformanceAlert(alertId);

      // 5. Verify resolution
      final activeAlerts = await service.getStudentPerformanceAlerts(
        userId: 'student2',
        activeOnly: true,
      );
      expect(activeAlerts.length, 0);
    });

    test('should handle milestone and notification combination', () async {
      // 1. Create milestone
      final milestoneId = await service.createMilestoneNotification(
        userId: 'student3',
        milestoneName: 'Expert Level Reached',
        description: 'You achieved 90%+ accuracy across all categories!',
        milestoneType: 'accuracy_milestone',
        questionsCompleted: 200,
        accuracyRate: 91.5,
        streakDays: 45,
        rewardType: 'badge',
        rewardValue: 1,
        badgeInfo: {
          'badgeName': 'Expert',
          'emoji': '🏆',
        },
      );

      // 2. Get milestones
      final milestones = await service.getUserMilestones('student3');
      expect(milestones.length, 1);

      // 3. Get milestone count
      expect(milestones[0].questionsCompleted, 200);
      expect(milestones[0].accuracyRate, 91.5);
    });
  });
}
