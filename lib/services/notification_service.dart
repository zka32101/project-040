import '../models/notification_models.dart';

/// 通知リポジトリインターフェース
abstract class NotificationRepository {
  // Notification管理
  Future<void> createNotification(Notification notification);
  Future<Notification?> getNotificationById(String notificationId);
  Future<List<Notification>> getUserNotifications(String userId);
  Future<void> updateNotification(Notification notification);
  Future<bool> deleteNotification(String notificationId);

  // DeliveryLog管理
  Future<void> createDeliveryLog(DeliveryLog log);
  Future<List<DeliveryLog>> getDeliveryLogsByNotification(String notificationId);
  Future<List<DeliveryLog>> getDeliveryLogsByChannel(DeliveryChannel channel);

  // Template管理
  Future<void> createTemplate(NotificationTemplate template);
  Future<NotificationTemplate?> getTemplateById(String templateId);
  Future<List<NotificationTemplate>> getAllTemplates();
  Future<void> updateTemplate(NotificationTemplate template);

  // Parameter管理
  Future<void> createParameter(NotificationParameter parameter);
  Future<List<NotificationParameter>> getParametersByTemplate(String templateId);

  // Preference管理
  Future<void> createPreference(NotificationPreference preference);
  Future<NotificationPreference?> getPreferenceByUserId(String userId);
  Future<void> updatePreference(NotificationPreference preference);

  // Alert管理
  Future<void> createAlert(Alert alert);
  Future<Alert?> getAlertById(String alertId);
  Future<List<Alert>> getAllAlerts();
  Future<void> updateAlert(Alert alert);

  // AlertEvent管理
  Future<void> createAlertEvent(AlertEvent event);
  Future<List<AlertEvent>> getAlertEventsByAlert(String alertId);

  // Stats管理
  Future<void> saveNotificationStats(NotificationStats stats);
  Future<NotificationStats?> getLatestStats();

  // Report管理
  Future<void> saveNotificationReport(NotificationReport report);
  Future<NotificationReport?> getLatestReport();

  // Queue管理
  Future<void> enqueueNotification(QueueEntry entry);
  Future<QueueEntry?> dequeueNotification();
  Future<List<QueueEntry>> getPendingQueue();
  Future<void> updateQueueEntry(QueueEntry entry);

  // Channel設定
  Future<void> createChannelConfig(ChannelConfiguration config);
  Future<ChannelConfiguration?> getChannelConfig(DeliveryChannel channel);
  Future<void> updateChannelConfig(ChannelConfiguration config);
}

/// メモリ実装の通知リポジトリ
class MemoryNotificationRepository implements NotificationRepository {
  final Map<String, Notification> _notifications = {};
  final List<DeliveryLog> _deliveryLogs = [];
  final Map<String, NotificationTemplate> _templates = {};
  final Map<String, NotificationParameter> _parameters = {};
  final Map<String, NotificationPreference> _preferences = {};
  final Map<String, Alert> _alerts = {};
  final List<AlertEvent> _alertEvents = [];
  final List<NotificationStats> _stats = [];
  final List<NotificationReport> _reports = [];
  final List<QueueEntry> _queue = [];
  final Map<DeliveryChannel, ChannelConfiguration> _channelConfigs = {};

  @override
  Future<void> createNotification(Notification notification) async {
    if (_notifications.containsKey(notification.notificationId)) {
      throw Exception('Notification already exists');
    }
    _notifications[notification.notificationId] = notification;
  }

  @override
  Future<Notification?> getNotificationById(String notificationId) async {
    return _notifications[notificationId];
  }

  @override
  Future<List<Notification>> getUserNotifications(String userId) async {
    return _notifications.values.where((n) => n.userId == userId).toList();
  }

  @override
  Future<void> updateNotification(Notification notification) async {
    if (!_notifications.containsKey(notification.notificationId)) {
      throw Exception('Notification not found');
    }
    _notifications[notification.notificationId] = notification;
  }

  @override
  Future<bool> deleteNotification(String notificationId) async {
    return _notifications.remove(notificationId) != null;
  }

  @override
  Future<void> createDeliveryLog(DeliveryLog log) async {
    _deliveryLogs.add(log);
  }

  @override
  Future<List<DeliveryLog>> getDeliveryLogsByNotification(String notificationId) async {
    return _deliveryLogs.where((l) => l.notificationId == notificationId).toList();
  }

  @override
  Future<List<DeliveryLog>> getDeliveryLogsByChannel(DeliveryChannel channel) async {
    return _deliveryLogs.where((l) => l.channel == channel).toList();
  }

  @override
  Future<void> createTemplate(NotificationTemplate template) async {
    if (_templates.containsKey(template.templateId)) {
      throw Exception('Template already exists');
    }
    _templates[template.templateId] = template;
  }

  @override
  Future<NotificationTemplate?> getTemplateById(String templateId) async {
    return _templates[templateId];
  }

  @override
  Future<List<NotificationTemplate>> getAllTemplates() async {
    return _templates.values.toList();
  }

  @override
  Future<void> updateTemplate(NotificationTemplate template) async {
    if (!_templates.containsKey(template.templateId)) {
      throw Exception('Template not found');
    }
    _templates[template.templateId] = template;
  }

  @override
  Future<void> createParameter(NotificationParameter parameter) async {
    _parameters[parameter.parameterId] = parameter;
  }

  @override
  Future<List<NotificationParameter>> getParametersByTemplate(String templateId) async {
    return _parameters.values.where((p) => p.templateId == templateId).toList();
  }

  @override
  Future<void> createPreference(NotificationPreference preference) async {
    if (_preferences.containsKey(preference.preferenceId)) {
      throw Exception('Preference already exists');
    }
    _preferences[preference.preferenceId] = preference;
  }

  @override
  Future<NotificationPreference?> getPreferenceByUserId(String userId) async {
    return _preferences.values.cast<NotificationPreference?>().firstWhere(
          (p) => p?.userId == userId,
          orElse: () => null,
        );
  }

  @override
  Future<void> updatePreference(NotificationPreference preference) async {
    if (!_preferences.containsKey(preference.preferenceId)) {
      throw Exception('Preference not found');
    }
    _preferences[preference.preferenceId] = preference;
  }

  @override
  Future<void> createAlert(Alert alert) async {
    if (_alerts.containsKey(alert.alertId)) {
      throw Exception('Alert already exists');
    }
    _alerts[alert.alertId] = alert;
  }

  @override
  Future<Alert?> getAlertById(String alertId) async {
    return _alerts[alertId];
  }

  @override
  Future<List<Alert>> getAllAlerts() async {
    return _alerts.values.toList();
  }

  @override
  Future<void> updateAlert(Alert alert) async {
    if (!_alerts.containsKey(alert.alertId)) {
      throw Exception('Alert not found');
    }
    _alerts[alert.alertId] = alert;
  }

  @override
  Future<void> createAlertEvent(AlertEvent event) async {
    _alertEvents.add(event);
  }

  @override
  Future<List<AlertEvent>> getAlertEventsByAlert(String alertId) async {
    return _alertEvents.where((e) => e.alertId == alertId).toList();
  }

  @override
  Future<void> saveNotificationStats(NotificationStats stats) async {
    _stats.add(stats);
  }

  @override
  Future<NotificationStats?> getLatestStats() async {
    return _stats.isNotEmpty ? _stats.last : null;
  }

  @override
  Future<void> saveNotificationReport(NotificationReport report) async {
    _reports.add(report);
  }

  @override
  Future<NotificationReport?> getLatestReport() async {
    return _reports.isNotEmpty ? _reports.last : null;
  }

  @override
  Future<void> enqueueNotification(QueueEntry entry) async {
    _queue.add(entry);
  }

  @override
  Future<QueueEntry?> dequeueNotification() async {
    if (_queue.isEmpty) return null;
    final entry = _queue.firstWhere(
      (e) => e.status == 'queued',
      orElse: () => _queue.first,
    );
    _queue.remove(entry);
    return entry;
  }

  @override
  Future<List<QueueEntry>> getPendingQueue() async {
    return _queue.where((e) => e.status == 'queued' || e.status == 'processing').toList();
  }

  @override
  Future<void> updateQueueEntry(QueueEntry entry) async {
    final index = _queue.indexWhere((e) => e.entryId == entry.entryId);
    if (index >= 0) {
      _queue[index] = entry;
    }
  }

  @override
  Future<void> createChannelConfig(ChannelConfiguration config) async {
    _channelConfigs[config.channel] = config;
  }

  @override
  Future<ChannelConfiguration?> getChannelConfig(DeliveryChannel channel) async {
    return _channelConfigs[channel];
  }

  @override
  Future<void> updateChannelConfig(ChannelConfiguration config) async {
    _channelConfigs[config.channel] = config;
  }
}

/// 通知配信エンジン
abstract class NotificationDeliveryEngine {
  Future<void> sendNotification(Notification notification, DeliveryChannel channel);
  Future<void> processQueue();
  Future<List<DeliveryLog>> getDeliveryStatus(String notificationId);
  Future<void> retryFailedDeliveries();
}

/// メモリ実装の通知配信エンジン
class MemoryNotificationDeliveryEngine implements NotificationDeliveryEngine {
  final NotificationRepository _repository;

  MemoryNotificationDeliveryEngine(this._repository);

  @override
  Future<void> sendNotification(Notification notification, DeliveryChannel channel) async {
    final log = DeliveryLog(
      logId: 'log_${DateTime.now().millisecondsSinceEpoch}',
      notificationId: notification.notificationId,
      channel: channel,
      sentAt: DateTime.now(),
      status: NotificationStatus.sent,
      retryCount: 0,
    );
    await _repository.createDeliveryLog(log);
  }

  @override
  Future<void> processQueue() async {
    final queue = await _repository.getPendingQueue();
    for (final entry in queue.take(10)) {
      // Simulate processing
      await _repository.updateQueueEntry(
        QueueEntry(
          entryId: entry.entryId,
          notificationId: entry.notificationId,
          channel: entry.channel,
          enqueuedAt: entry.enqueuedAt,
          processedAt: DateTime.now(),
          status: 'completed',
          priority: entry.priority,
          retryCount: entry.retryCount,
        ),
      );
    }
  }

  @override
  Future<List<DeliveryLog>> getDeliveryStatus(String notificationId) async {
    return _repository.getDeliveryLogsByNotification(notificationId);
  }

  @override
  Future<void> retryFailedDeliveries() async {
    final queue = await _repository.getPendingQueue();
    for (final entry in queue) {
      if (entry.hasFailed && entry.needsRetry) {
        await _repository.updateQueueEntry(
          QueueEntry(
            entryId: entry.entryId,
            notificationId: entry.notificationId,
            channel: entry.channel,
            enqueuedAt: entry.enqueuedAt,
            status: 'queued',
            priority: entry.priority,
            retryCount: entry.retryCount + 1,
            lastError: entry.lastError,
          ),
        );
      }
    }
  }
}

/// アラートエンジン
abstract class AlertEngine {
  Future<void> createAlert(Alert alert);
  Future<void> triggerAlert(String alertId, String message, Map<String, dynamic>? details);
  Future<void> acknowledgeAlert(String eventId, String acknowledgedBy);
  Future<void> resolveAlert(String alertId);
  Future<List<Alert>> getActiveAlerts();
  Future<List<AlertEvent>> getRecentAlertEvents();
}

/// メモリ実装のアラートエンジン
class MemoryAlertEngine implements AlertEngine {
  final NotificationRepository _repository;

  MemoryAlertEngine(this._repository);

  @override
  Future<void> createAlert(Alert alert) async {
    await _repository.createAlert(alert);
  }

  @override
  Future<void> triggerAlert(String alertId, String message, Map<String, dynamic>? details) async {
    final alert = await _repository.getAlertById(alertId);
    if (alert == null) throw Exception('Alert not found');

    final event = AlertEvent(
      eventId: 'event_${DateTime.now().millisecondsSinceEpoch}',
      alertId: alertId,
      occurredAt: DateTime.now(),
      message: message,
      details: details,
      severity: alert.severity.value,
    );
    await _repository.createAlertEvent(event);

    // Update alert trigger count
    final updatedAlert = Alert(
      alertId: alert.alertId,
      alertName: alert.alertName,
      alertType: alert.alertType,
      condition: alert.condition,
      severity: alert.severity,
      recipients: alert.recipients,
      notificationChannels: alert.notificationChannels,
      createdAt: alert.createdAt,
      lastTriggeredAt: DateTime.now(),
      status: alert.status,
      isEnabled: alert.isEnabled,
      triggerCount: alert.triggerCount + 1,
    );
    await _repository.updateAlert(updatedAlert);
  }

  @override
  Future<void> acknowledgeAlert(String eventId, String acknowledgedBy) async {
    final events = await _repository.getAlertEventsByAlert('');
    final event = events.firstWhere((e) => e.eventId == eventId, orElse: () => throw Exception('Event not found'));

    final updatedEvent = AlertEvent(
      eventId: event.eventId,
      alertId: event.alertId,
      occurredAt: event.occurredAt,
      message: event.message,
      details: event.details,
      severity: event.severity,
      isAcknowledged: true,
      acknowledgedAt: DateTime.now(),
      acknowledgedBy: acknowledgedBy,
    );
    await _repository.createAlertEvent(updatedEvent);
  }

  @override
  Future<void> resolveAlert(String alertId) async {
    final alert = await _repository.getAlertById(alertId);
    if (alert == null) throw Exception('Alert not found');

    final resolved = Alert(
      alertId: alert.alertId,
      alertName: alert.alertName,
      alertType: alert.alertType,
      condition: alert.condition,
      severity: alert.severity,
      recipients: alert.recipients,
      notificationChannels: alert.notificationChannels,
      createdAt: alert.createdAt,
      lastTriggeredAt: alert.lastTriggeredAt,
      status: AlertStatus.resolved,
      isEnabled: alert.isEnabled,
      triggerCount: alert.triggerCount,
    );
    await _repository.updateAlert(resolved);
  }

  @override
  Future<List<Alert>> getActiveAlerts() async {
    final alerts = await _repository.getAllAlerts();
    return alerts.where((a) => a.isActive).toList();
  }

  @override
  Future<List<AlertEvent>> getRecentAlertEvents() async {
    final alerts = await _repository.getAllAlerts();
    final events = <AlertEvent>[];
    for (final alert in alerts) {
      final alertEvents = await _repository.getAlertEventsByAlert(alert.alertId);
      events.addAll(alertEvents.where((e) => e.isRecent));
    }
    return events;
  }
}

/// 通知マネージャー
abstract class NotificationManager {
  Future<Notification> sendNotification(String userId, String title, String message, NotificationType type);
  Future<void> markAsRead(String notificationId);
  Future<List<Notification>> getUserNotifications(String userId);
  Future<void> setUserPreference(String userId, NotificationPreference preference);
  Future<NotificationPreference?> getUserPreference(String userId);
  Future<void> createAndSendAlert(String alertName, AlertType type, String condition);
  Future<NotificationReport> generateReport();
}

/// メモリ実装の通知マネージャー
class MemoryNotificationManager implements NotificationManager {
  final NotificationRepository _repository;
  late final NotificationDeliveryEngine _deliveryEngine;
  late final AlertEngine _alertEngine;

  MemoryNotificationManager(this._repository) {
    _deliveryEngine = MemoryNotificationDeliveryEngine(_repository);
    _alertEngine = MemoryAlertEngine(_repository);
  }

  @override
  Future<Notification> sendNotification(String userId, String title, String message, NotificationType type) async {
    final notification = Notification(
      notificationId: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title,
      message: message,
      notificationType: type,
      createdAt: DateTime.now(),
    );
    await _repository.createNotification(notification);
    await _deliveryEngine.sendNotification(notification, DeliveryChannel.inApp);
    return notification;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final notification = await _repository.getNotificationById(notificationId);
    if (notification == null) throw Exception('Notification not found');

    final updated = Notification(
      notificationId: notification.notificationId,
      userId: notification.userId,
      title: notification.title,
      message: notification.message,
      notificationType: notification.notificationType,
      priority: notification.priority,
      createdAt: notification.createdAt,
      readAt: DateTime.now(),
      status: NotificationStatus.read,
      metadata: notification.metadata,
      actionUrl: notification.actionUrl,
    );
    await _repository.updateNotification(updated);
  }

  @override
  Future<List<Notification>> getUserNotifications(String userId) async {
    return _repository.getUserNotifications(userId);
  }

  @override
  Future<void> setUserPreference(String userId, NotificationPreference preference) async {
    await _repository.createPreference(preference);
  }

  @override
  Future<NotificationPreference?> getUserPreference(String userId) async {
    return _repository.getPreferenceByUserId(userId);
  }

  @override
  Future<void> createAndSendAlert(String alertName, AlertType type, String condition) async {
    final alert = Alert(
      alertId: 'alert_${DateTime.now().millisecondsSinceEpoch}',
      alertName: alertName,
      alertType: type,
      condition: condition,
      severity: PriorityLevel.high,
      recipients: [],
      notificationChannels: [DeliveryChannel.inApp, DeliveryChannel.email],
      createdAt: DateTime.now(),
    );
    await _alertEngine.createAlert(alert);
  }

  @override
  Future<NotificationReport> generateReport() async {
    final stats = NotificationStats(
      statsId: 'stats_${DateTime.now().millisecondsSinceEpoch}',
      totalNotifications: 100,
      sentNotifications: 95,
      deliveredNotifications: 90,
      readNotifications: 75,
      failedNotifications: 5,
      periodStart: DateTime.now().subtract(Duration(days: 1)),
      periodEnd: DateTime.now(),
      deliveryRate: 0.95,
      readRate: 0.83,
      averageDeliveryTimeSeconds: 5,
    );

    final report = NotificationReport(
      reportId: 'report_${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      periodStart: DateTime.now().subtract(Duration(days: 1)),
      periodEnd: DateTime.now(),
      stats: stats,
      topNotificationTypes: ['info', 'warning', 'alert'],
      topChannels: ['in_app', 'email', 'push'],
      recommendations: [],
    );

    await _repository.saveNotificationReport(report);
    return report;
  }
}

/// 通知ファサード
class NotificationFacade {
  late final NotificationRepository _repository;
  late final NotificationManager _manager;

  NotificationFacade() {
    _repository = MemoryNotificationRepository();
    _manager = MemoryNotificationManager(_repository);
  }

  // Notification操作
  Future<Notification> sendNotification(String userId, String title, String message, NotificationType type) =>
      _manager.sendNotification(userId, title, message, type);

  Future<void> markAsRead(String notificationId) => _manager.markAsRead(notificationId);

  Future<List<Notification>> getUserNotifications(String userId) => _manager.getUserNotifications(userId);

  Future<Notification?> getNotification(String notificationId) => _repository.getNotificationById(notificationId);

  // Preference操作
  Future<void> setUserPreference(String userId, NotificationPreference preference) =>
      _manager.setUserPreference(userId, preference);

  Future<NotificationPreference?> getUserPreference(String userId) => _manager.getUserPreference(userId);

  // Alert操作
  Future<void> createAlert(String alertName, AlertType type, String condition) =>
      _manager.createAndSendAlert(alertName, type, condition);

  Future<Alert?> getAlert(String alertId) => _repository.getAlertById(alertId);

  Future<List<Alert>> getAllAlerts() => _repository.getAllAlerts();

  // Template操作
  Future<void> createTemplate(NotificationTemplate template) => _repository.createTemplate(template);

  Future<NotificationTemplate?> getTemplate(String templateId) => _repository.getTemplateById(templateId);

  Future<List<NotificationTemplate>> getAllTemplates() => _repository.getAllTemplates();

  // Report
  Future<NotificationReport> generateReport() => _manager.generateReport();

  Future<NotificationReport?> getLatestReport() => _repository.getLatestReport();

  // Queue操作
  Future<void> enqueueNotification(QueueEntry entry) => _repository.enqueueNotification(entry);

  Future<List<QueueEntry>> getPendingQueue() => _repository.getPendingQueue();

  // Channel設定
  Future<void> configureChannel(DeliveryChannel channel, Map<String, dynamic> settings) async {
    final config = ChannelConfiguration(
      configId: 'config_${DateTime.now().millisecondsSinceEpoch}',
      channel: channel,
      isEnabled: true,
      settings: settings,
      createdAt: DateTime.now(),
      isVerified: true,
    );
    await _repository.createChannelConfig(config);
  }

  Future<ChannelConfiguration?> getChannelConfig(DeliveryChannel channel) =>
      _repository.getChannelConfig(channel);
}
