/// Real-time Notification & Messaging Service

import 'package:project_040/models/notification_models.dart';

abstract class NotificationRepository {
  // Notification Management (10 methods)
  Future<Notification> createNotification(String recipientId, String title, String message, NotificationChannel channel, NotificationPriority priority);
  Future<Notification?> getNotification(String notificationId);
  Future<Notification> updateNotificationStatus(String notificationId, NotificationStatus status);
  Future<void> deleteNotification(String notificationId);
  Future<List<Notification>> listNotifications(String recipientId, {int limit = 50});
  Future<List<Notification>> getPendingNotifications();
  Future<List<Notification>> getFailedNotifications();
  Future<List<Notification>> getNotificationsByChannel(NotificationChannel channel);
  Future<int> getNotificationCount();
  Future<List<Notification>> getNotificationsByFilter(NotificationTopic topic, String recipientId);

  // Message Management (9 methods)
  Future<Message> createMessage(String senderId, String recipientId, String content, MessageType type);
  Future<Message?> getMessage(String messageId);
  Future<Message> markAsRead(String messageId);
  Future<void> deleteMessage(String messageId);
  Future<List<Message>> listMessages(String userId, {int limit = 50});
  Future<List<Message>> getUnreadMessages(String userId);
  Future<int> getUnreadCount(String userId);
  Future<void> archiveMessage(String messageId);
  Future<List<Message>> getArchivedMessages(String userId);

  // Subscription Management (8 methods)
  Future<Subscription> createSubscription(String userId, NotificationTopic topic, List<NotificationChannel> channels);
  Future<Subscription?> getSubscription(String subscriptionId);
  Future<Subscription> updateSubscriptionStatus(String subscriptionId, SubscriptionStatus status);
  Future<void> deleteSubscription(String subscriptionId);
  Future<List<Subscription>> getUserSubscriptions(String userId);
  Future<List<Subscription>> getSubscriptionsByTopic(NotificationTopic topic);
  Future<List<Subscription>> getActiveSubscriptions();
  Future<int> getSubscriptionCount();

  // Template Management (7 methods)
  Future<NotificationTemplate> createTemplate(String name, String title, String messageTemplate, NotificationTopic topic, NotificationPriority priority, List<NotificationChannel> channels);
  Future<NotificationTemplate?> getTemplate(String templateId);
  Future<NotificationTemplate> updateTemplate(String templateId, {String? title, String? messageTemplate});
  Future<void> deleteTemplate(String templateId);
  Future<List<NotificationTemplate>> listTemplates({int limit = 50});
  Future<List<NotificationTemplate>> getTemplatesByTopic(NotificationTopic topic);
  Future<int> getTemplateCount();

  // Schedule Management (7 methods)
  Future<NotificationSchedule> scheduleNotification(String notificationId, DateTime scheduledTime, {bool recurring = false, String? pattern});
  Future<NotificationSchedule?> getSchedule(String scheduleId);
  Future<void> updateSchedule(String scheduleId, DateTime newTime);
  Future<void> deleteSchedule(String scheduleId);
  Future<List<NotificationSchedule>> getUpcomingSchedules();
  Future<List<NotificationSchedule>> getExpiredSchedules();
  Future<int> getScheduleCount();

  // Preference Management (6 methods)
  Future<NotificationPreference> createPreference(String userId);
  Future<NotificationPreference?> getPreference(String preferenceId);
  Future<NotificationPreference> updateChannelPreference(String preferenceId, NotificationChannel channel, bool enabled);
  Future<NotificationPreference> updateTopicPreference(String preferenceId, NotificationTopic topic, bool enabled);
  Future<void> deletePreference(String preferenceId);
  Future<List<NotificationPreference>> getUserPreferences(String userId);

  // Batch Operations (6 methods)
  Future<NotificationBatch> createBatch(List<String> notificationIds);
  Future<NotificationBatch?> getBatch(String batchId);
  Future<NotificationBatch> updateBatchStatus(String batchId, int successCount, int failureCount);
  Future<void> deleteBatch(String batchId);
  Future<List<NotificationBatch>> listBatches({int limit = 50});
  Future<int> getBatchCount();

  // Logging & Analytics (6 methods)
  Future<NotificationLog> recordLog(String notificationId, String eventType, {String? errorMessage});
  Future<NotificationLog?> getLog(String logId);
  Future<List<NotificationLog>> getLogsByNotification(String notificationId);
  Future<List<NotificationLog>> getErrorLogs();
  Future<int> getLogCount();
  Future<NotificationAnalytics> generateAnalytics(DateTime startDate, DateTime endDate);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final Map<String, Map<String, dynamic>> _storage = {};

  NotificationRepositoryImpl() {
    _storage['notifications'] = {};
    _storage['messages'] = {};
    _storage['subscriptions'] = {};
    _storage['templates'] = {};
    _storage['schedules'] = {};
    _storage['preferences'] = {};
    _storage['batches'] = {};
    _storage['logs'] = {};
  }

  @override
  Future<Notification> createNotification(String recipientId, String title, String message, NotificationChannel channel, NotificationPriority priority) async {
    final notification = Notification(
      notificationId: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      recipientId: recipientId,
      title: title,
      message: message,
      channel: channel,
      status: NotificationStatus.pending,
      priority: priority,
      createdAt: DateTime.now(),
      metadata: {},
    );
    _storage['notifications']![notification.notificationId] = _notificationToMap(notification);
    return notification;
  }

  @override
  Future<Notification?> getNotification(String notificationId) async {
    final data = _storage['notifications']![notificationId];
    return data != null ? _mapToNotification(data) : null;
  }

  @override
  Future<Notification> updateNotificationStatus(String notificationId, NotificationStatus status) async {
    final data = _storage['notifications']![notificationId];
    if (data == null) throw Exception('Notification not found');
    data['status'] = status.toString().split('.').last;
    if (status == NotificationStatus.sent) data['sentAt'] = DateTime.now().toIso8601String();
    if (status == NotificationStatus.delivered) data['deliveredAt'] = DateTime.now().toIso8601String();
    return _mapToNotification(data);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    _storage['notifications']!.remove(notificationId);
  }

  @override
  Future<List<Notification>> listNotifications(String recipientId, {int limit = 50}) async {
    return _storage['notifications']!.values
        .where((n) => n['recipientId'] == recipientId)
        .map(_mapToNotification)
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<Notification>> getPendingNotifications() async {
    return _storage['notifications']!.values
        .where((n) => n['status'] == 'pending')
        .map(_mapToNotification)
        .toList();
  }

  @override
  Future<List<Notification>> getFailedNotifications() async {
    return _storage['notifications']!.values
        .where((n) => n['status'] == 'failed')
        .map(_mapToNotification)
        .toList();
  }

  @override
  Future<List<Notification>> getNotificationsByChannel(NotificationChannel channel) async {
    return _storage['notifications']!.values
        .where((n) => n['channel'] == channel.toString().split('.').last)
        .map(_mapToNotification)
        .toList();
  }

  @override
  Future<int> getNotificationCount() async => _storage['notifications']!.length;

  @override
  Future<List<Notification>> getNotificationsByFilter(NotificationTopic topic, String recipientId) async {
    return _storage['notifications']!.values
        .where((n) => n['recipientId'] == recipientId)
        .map(_mapToNotification)
        .toList();
  }

  @override
  Future<Message> createMessage(String senderId, String recipientId, String content, MessageType type) async {
    final message = Message(
      messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      recipientId: recipientId,
      content: content,
      type: type,
      createdAt: DateTime.now(),
      attachmentIds: [],
      context: {},
    );
    _storage['messages']![message.messageId] = _messageToMap(message);
    return message;
  }

  @override
  Future<Message?> getMessage(String messageId) async {
    final data = _storage['messages']![messageId];
    return data != null ? _mapToMessage(data) : null;
  }

  @override
  Future<Message> markAsRead(String messageId) async {
    final data = _storage['messages']![messageId];
    if (data == null) throw Exception('Message not found');
    data['readAt'] = DateTime.now().toIso8601String();
    return _mapToMessage(data);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    _storage['messages']!.remove(messageId);
  }

  @override
  Future<List<Message>> listMessages(String userId, {int limit = 50}) async {
    return _storage['messages']!.values
        .where((m) => m['recipientId'] == userId)
        .map(_mapToMessage)
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<Message>> getUnreadMessages(String userId) async {
    return _storage['messages']!.values
        .where((m) => m['recipientId'] == userId && m['readAt'] == null)
        .map(_mapToMessage)
        .toList();
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return _storage['messages']!.values
        .where((m) => m['recipientId'] == userId && m['readAt'] == null)
        .length;
  }

  @override
  Future<void> archiveMessage(String messageId) async {
    final data = _storage['messages']![messageId];
    if (data != null) data['isArchived'] = true;
  }

  @override
  Future<List<Message>> getArchivedMessages(String userId) async {
    return _storage['messages']!.values
        .where((m) => m['recipientId'] == userId && m['isArchived'] == true)
        .map(_mapToMessage)
        .toList();
  }

  @override
  Future<Subscription> createSubscription(String userId, NotificationTopic topic, List<NotificationChannel> channels) async {
    final subscription = Subscription(
      subscriptionId: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      topic: topic,
      channels: channels,
      status: SubscriptionStatus.active,
      createdAt: DateTime.now(),
    );
    _storage['subscriptions']![subscription.subscriptionId] = _subscriptionToMap(subscription);
    return subscription;
  }

  @override
  Future<Subscription?> getSubscription(String subscriptionId) async {
    final data = _storage['subscriptions']![subscriptionId];
    return data != null ? _mapToSubscription(data) : null;
  }

  @override
  Future<Subscription> updateSubscriptionStatus(String subscriptionId, SubscriptionStatus status) async {
    final data = _storage['subscriptions']![subscriptionId];
    if (data == null) throw Exception('Subscription not found');
    data['status'] = status.toString().split('.').last;
    data['modifiedAt'] = DateTime.now().toIso8601String();
    return _mapToSubscription(data);
  }

  @override
  Future<void> deleteSubscription(String subscriptionId) async {
    _storage['subscriptions']!.remove(subscriptionId);
  }

  @override
  Future<List<Subscription>> getUserSubscriptions(String userId) async {
    return _storage['subscriptions']!.values
        .where((s) => s['userId'] == userId)
        .map(_mapToSubscription)
        .toList();
  }

  @override
  Future<List<Subscription>> getSubscriptionsByTopic(NotificationTopic topic) async {
    return _storage['subscriptions']!.values
        .where((s) => s['topic'] == topic.toString().split('.').last)
        .map(_mapToSubscription)
        .toList();
  }

  @override
  Future<List<Subscription>> getActiveSubscriptions() async {
    return _storage['subscriptions']!.values
        .where((s) => s['status'] == 'active')
        .map(_mapToSubscription)
        .toList();
  }

  @override
  Future<int> getSubscriptionCount() async => _storage['subscriptions']!.length;

  @override
  Future<NotificationTemplate> createTemplate(String name, String title, String messageTemplate, NotificationTopic topic, NotificationPriority priority, List<NotificationChannel> channels) async {
    final template = NotificationTemplate(
      templateId: 'tpl_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      title: title,
      messageTemplate: messageTemplate,
      topic: topic,
      defaultPriority: priority,
      supportedChannels: channels,
      createdAt: DateTime.now(),
      placeholders: {},
    );
    _storage['templates']![template.templateId] = _templateToMap(template);
    return template;
  }

  @override
  Future<NotificationTemplate?> getTemplate(String templateId) async {
    final data = _storage['templates']![templateId];
    return data != null ? _mapToTemplate(data) : null;
  }

  @override
  Future<NotificationTemplate> updateTemplate(String templateId, {String? title, String? messageTemplate}) async {
    final data = _storage['templates']![templateId];
    if (data == null) throw Exception('Template not found');
    if (title != null) data['title'] = title;
    if (messageTemplate != null) data['messageTemplate'] = messageTemplate;
    return _mapToTemplate(data);
  }

  @override
  Future<void> deleteTemplate(String templateId) async {
    _storage['templates']!.remove(templateId);
  }

  @override
  Future<List<NotificationTemplate>> listTemplates({int limit = 50}) async {
    return _storage['templates']!.values.map(_mapToTemplate).toList().take(limit).toList();
  }

  @override
  Future<List<NotificationTemplate>> getTemplatesByTopic(NotificationTopic topic) async {
    return _storage['templates']!.values
        .where((t) => t['topic'] == topic.toString().split('.').last)
        .map(_mapToTemplate)
        .toList();
  }

  @override
  Future<int> getTemplateCount() async => _storage['templates']!.length;

  @override
  Future<NotificationSchedule> scheduleNotification(String notificationId, DateTime scheduledTime, {bool recurring = false, String? pattern}) async {
    final schedule = NotificationSchedule(
      scheduleId: 'sch_${DateTime.now().millisecondsSinceEpoch}',
      notificationId: notificationId,
      scheduledTime: scheduledTime,
      isRecurring: recurring,
      recurringPattern: pattern,
    );
    _storage['schedules']![schedule.scheduleId] = _scheduleToMap(schedule);
    return schedule;
  }

  @override
  Future<NotificationSchedule?> getSchedule(String scheduleId) async {
    final data = _storage['schedules']![scheduleId];
    return data != null ? _mapToSchedule(data) : null;
  }

  @override
  Future<void> updateSchedule(String scheduleId, DateTime newTime) async {
    final data = _storage['schedules']![scheduleId];
    if (data != null) data['scheduledTime'] = newTime.toIso8601String();
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    _storage['schedules']!.remove(scheduleId);
  }

  @override
  Future<List<NotificationSchedule>> getUpcomingSchedules() async {
    final now = DateTime.now();
    return _storage['schedules']!.values
        .where((s) => DateTime.parse(s['scheduledTime']).isAfter(now) && s['executedAt'] == null)
        .map(_mapToSchedule)
        .toList();
  }

  @override
  Future<List<NotificationSchedule>> getExpiredSchedules() async {
    return _storage['schedules']!.values
        .where((s) => s['expiresAt'] != null && DateTime.parse(s['expiresAt']).isBefore(DateTime.now()))
        .map(_mapToSchedule)
        .toList();
  }

  @override
  Future<int> getScheduleCount() async => _storage['schedules']!.length;

  @override
  Future<NotificationPreference> createPreference(String userId) async {
    final preference = NotificationPreference(
      preferenceId: 'pref_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      channelPreferences: {},
      topicPreferences: {},
      lastModified: DateTime.now(),
    );
    _storage['preferences']![preference.preferenceId] = _preferenceToMap(preference);
    return preference;
  }

  @override
  Future<NotificationPreference?> getPreference(String preferenceId) async {
    final data = _storage['preferences']![preferenceId];
    return data != null ? _mapToPreference(data) : null;
  }

  @override
  Future<NotificationPreference> updateChannelPreference(String preferenceId, NotificationChannel channel, bool enabled) async {
    final data = _storage['preferences']![preferenceId];
    if (data == null) throw Exception('Preference not found');
    final channels = Map<String, bool>.from(data['channelPreferences'] ?? {});
    channels[channel.toString().split('.').last] = enabled;
    data['channelPreferences'] = channels;
    data['lastModified'] = DateTime.now().toIso8601String();
    return _mapToPreference(data);
  }

  @override
  Future<NotificationPreference> updateTopicPreference(String preferenceId, NotificationTopic topic, bool enabled) async {
    final data = _storage['preferences']![preferenceId];
    if (data == null) throw Exception('Preference not found');
    final topics = Map<String, bool>.from(data['topicPreferences'] ?? {});
    topics[topic.toString().split('.').last] = enabled;
    data['topicPreferences'] = topics;
    data['lastModified'] = DateTime.now().toIso8601String();
    return _mapToPreference(data);
  }

  @override
  Future<void> deletePreference(String preferenceId) async {
    _storage['preferences']!.remove(preferenceId);
  }

  @override
  Future<List<NotificationPreference>> getUserPreferences(String userId) async {
    return _storage['preferences']!.values
        .where((p) => p['userId'] == userId)
        .map(_mapToPreference)
        .toList();
  }

  @override
  Future<NotificationBatch> createBatch(List<String> notificationIds) async {
    final batch = NotificationBatch(
      batchId: 'batch_${DateTime.now().millisecondsSinceEpoch}',
      notificationIds: notificationIds,
      totalCount: notificationIds.length,
      successCount: 0,
      failureCount: 0,
      createdAt: DateTime.now(),
      status: 'processing',
    );
    _storage['batches']![batch.batchId] = _batchToMap(batch);
    return batch;
  }

  @override
  Future<NotificationBatch?> getBatch(String batchId) async {
    final data = _storage['batches']![batchId];
    return data != null ? _mapToBatch(data) : null;
  }

  @override
  Future<NotificationBatch> updateBatchStatus(String batchId, int successCount, int failureCount) async {
    final data = _storage['batches']![batchId];
    if (data == null) throw Exception('Batch not found');
    data['successCount'] = successCount;
    data['failureCount'] = failureCount;
    if (successCount + failureCount == data['totalCount']) {
      data['status'] = 'completed';
      data['completedAt'] = DateTime.now().toIso8601String();
    }
    return _mapToBatch(data);
  }

  @override
  Future<void> deleteBatch(String batchId) async {
    _storage['batches']!.remove(batchId);
  }

  @override
  Future<List<NotificationBatch>> listBatches({int limit = 50}) async {
    return _storage['batches']!.values.map(_mapToBatch).toList().take(limit).toList();
  }

  @override
  Future<int> getBatchCount() async => _storage['batches']!.length;

  @override
  Future<NotificationLog> recordLog(String notificationId, String eventType, {String? errorMessage}) async {
    final log = NotificationLog(
      logId: 'log_${DateTime.now().millisecondsSinceEpoch}',
      notificationId: notificationId,
      timestamp: DateTime.now(),
      eventType: eventType,
      errorMessage: errorMessage,
      details: {},
    );
    _storage['logs']![log.logId] = _logToMap(log);
    return log;
  }

  @override
  Future<NotificationLog?> getLog(String logId) async {
    final data = _storage['logs']![logId];
    return data != null ? _mapToLog(data) : null;
  }

  @override
  Future<List<NotificationLog>> getLogsByNotification(String notificationId) async {
    return _storage['logs']!.values
        .where((l) => l['notificationId'] == notificationId)
        .map(_mapToLog)
        .toList();
  }

  @override
  Future<List<NotificationLog>> getErrorLogs() async {
    return _storage['logs']!.values
        .where((l) => l['errorMessage'] != null)
        .map(_mapToLog)
        .toList();
  }

  @override
  Future<int> getLogCount() async => _storage['logs']!.length;

  @override
  Future<NotificationAnalytics> generateAnalytics(DateTime startDate, DateTime endDate) async {
    final notifications = _storage['notifications']!.values.toList();
    final delivered = notifications.where((n) => n['status'] == 'delivered').length;
    final failed = notifications.where((n) => n['status'] == 'failed').length;
    
    return NotificationAnalytics(
      analyticsId: 'ana_${DateTime.now().millisecondsSinceEpoch}',
      periodStart: startDate,
      periodEnd: endDate,
      totalSent: notifications.length,
      totalDelivered: delivered,
      totalFailed: failed,
      deliveryRate: notifications.isNotEmpty ? (delivered / notifications.length) * 100 : 0.0,
      channelBreakdown: {},
      topicBreakdown: {},
      averageDeliveryTimeMs: 150.0,
    );
  }

  // Helper methods
  Map<String, dynamic> _notificationToMap(Notification n) => {
    'notificationId': n.notificationId,
    'recipientId': n.recipientId,
    'title': n.title,
    'message': n.message,
    'channel': n.channel.toString().split('.').last,
    'status': n.status.toString().split('.').last,
    'priority': n.priority.toString().split('.').last,
    'createdAt': n.createdAt.toIso8601String(),
    'sentAt': n.sentAt?.toIso8601String(),
    'deliveredAt': n.deliveredAt?.toIso8601String(),
    'relatedEntityId': n.relatedEntityId,
    'metadata': n.metadata,
  };

  Notification _mapToNotification(Map<String, dynamic> m) => Notification(
    notificationId: m['notificationId'],
    recipientId: m['recipientId'],
    title: m['title'],
    message: m['message'],
    channel: NotificationChannel.values.byName(m['channel']),
    status: NotificationStatus.values.byName(m['status']),
    priority: NotificationPriority.values.byName(m['priority']),
    createdAt: DateTime.parse(m['createdAt']),
    sentAt: m['sentAt'] != null ? DateTime.parse(m['sentAt']) : null,
    deliveredAt: m['deliveredAt'] != null ? DateTime.parse(m['deliveredAt']) : null,
    relatedEntityId: m['relatedEntityId'],
    metadata: m['metadata'] ?? {},
  );

  Map<String, dynamic> _messageToMap(Message m) => {
    'messageId': m.messageId,
    'senderId': m.senderId,
    'recipientId': m.recipientId,
    'content': m.content,
    'type': m.type.toString().split('.').last,
    'createdAt': m.createdAt.toIso8601String(),
    'readAt': m.readAt?.toIso8601String(),
    'attachmentIds': m.attachmentIds,
    'context': m.context,
    'isArchived': m.isArchived,
  };

  Message _mapToMessage(Map<String, dynamic> m) => Message(
    messageId: m['messageId'],
    senderId: m['senderId'],
    recipientId: m['recipientId'],
    content: m['content'],
    type: MessageType.values.byName(m['type']),
    createdAt: DateTime.parse(m['createdAt']),
    readAt: m['readAt'] != null ? DateTime.parse(m['readAt']) : null,
    attachmentIds: List<String>.from(m['attachmentIds'] ?? []),
    context: m['context'] ?? {},
    isArchived: m['isArchived'] ?? false,
  );

  Map<String, dynamic> _subscriptionToMap(Subscription s) => {
    'subscriptionId': s.subscriptionId,
    'userId': s.userId,
    'topic': s.topic.toString().split('.').last,
    'channels': s.channels.map((c) => c.toString().split('.').last).toList(),
    'status': s.status.toString().split('.').last,
    'createdAt': s.createdAt.toIso8601String(),
    'modifiedAt': s.modifiedAt?.toIso8601String(),
    'muteNotifications': s.muteNotifications,
    'dailyLimitCount': s.dailyLimitCount,
  };

  Subscription _mapToSubscription(Map<String, dynamic> m) => Subscription(
    subscriptionId: m['subscriptionId'],
    userId: m['userId'],
    topic: NotificationTopic.values.byName(m['topic']),
    channels: (m['channels'] as List).map((c) => NotificationChannel.values.byName(c)).toList(),
    status: SubscriptionStatus.values.byName(m['status']),
    createdAt: DateTime.parse(m['createdAt']),
    modifiedAt: m['modifiedAt'] != null ? DateTime.parse(m['modifiedAt']) : null,
    muteNotifications: m['muteNotifications'] ?? false,
    dailyLimitCount: m['dailyLimitCount'],
  );

  Map<String, dynamic> _templateToMap(NotificationTemplate t) => {
    'templateId': t.templateId,
    'name': t.name,
    'title': t.title,
    'messageTemplate': t.messageTemplate,
    'topic': t.topic.toString().split('.').last,
    'defaultPriority': t.defaultPriority.toString().split('.').last,
    'supportedChannels': t.supportedChannels.map((c) => c.toString().split('.').last).toList(),
    'createdAt': t.createdAt.toIso8601String(),
    'isActive': t.isActive,
    'placeholders': t.placeholders,
  };

  NotificationTemplate _mapToTemplate(Map<String, dynamic> m) => NotificationTemplate(
    templateId: m['templateId'],
    name: m['name'],
    title: m['title'],
    messageTemplate: m['messageTemplate'],
    topic: NotificationTopic.values.byName(m['topic']),
    defaultPriority: NotificationPriority.values.byName(m['defaultPriority']),
    supportedChannels: (m['supportedChannels'] as List).map((c) => NotificationChannel.values.byName(c)).toList(),
    createdAt: DateTime.parse(m['createdAt']),
    isActive: m['isActive'] ?? true,
    placeholders: Map<String, String>.from(m['placeholders'] ?? {}),
  );

  Map<String, dynamic> _scheduleToMap(NotificationSchedule s) => {
    'scheduleId': s.scheduleId,
    'notificationId': s.notificationId,
    'scheduledTime': s.scheduledTime.toIso8601String(),
    'isRecurring': s.isRecurring,
    'recurringPattern': s.recurringPattern,
    'expiresAt': s.expiresAt?.toIso8601String(),
    'executedAt': s.executedAt?.toIso8601String(),
    'isActive': s.isActive,
  };

  NotificationSchedule _mapToSchedule(Map<String, dynamic> m) => NotificationSchedule(
    scheduleId: m['scheduleId'],
    notificationId: m['notificationId'],
    scheduledTime: DateTime.parse(m['scheduledTime']),
    isRecurring: m['isRecurring'] ?? false,
    recurringPattern: m['recurringPattern'],
    expiresAt: m['expiresAt'] != null ? DateTime.parse(m['expiresAt']) : null,
    executedAt: m['executedAt'] != null ? DateTime.parse(m['executedAt']) : null,
    isActive: m['isActive'] ?? true,
  );

  Map<String, dynamic> _preferenceToMap(NotificationPreference p) => {
    'preferenceId': p.preferenceId,
    'userId': p.userId,
    'channelPreferences': p.channelPreferences.map((k, v) => MapEntry(k.toString().split('.').last, v)),
    'topicPreferences': p.topicPreferences.map((k, v) => MapEntry(k.toString().split('.').last, v)),
    'quietHourStart': p.quietHourStart,
    'quietHourEnd': p.quietHourEnd,
    'minimumPriority': p.minimumPriority?.toString().split('.').last,
    'lastModified': p.lastModified.toIso8601String(),
  };

  NotificationPreference _mapToPreference(Map<String, dynamic> m) => NotificationPreference(
    preferenceId: m['preferenceId'],
    userId: m['userId'],
    channelPreferences: (m['channelPreferences'] as Map?)?.cast<String, bool>() ?? {},
    topicPreferences: (m['topicPreferences'] as Map?)?.cast<String, bool>() ?? {},
    quietHourStart: m['quietHourStart'],
    quietHourEnd: m['quietHourEnd'],
    minimumPriority: m['minimumPriority'] != null ? NotificationPriority.values.byName(m['minimumPriority']) : null,
    lastModified: DateTime.parse(m['lastModified']),
  );

  Map<String, dynamic> _batchToMap(NotificationBatch b) => {
    'batchId': b.batchId,
    'notificationIds': b.notificationIds,
    'totalCount': b.totalCount,
    'successCount': b.successCount,
    'failureCount': b.failureCount,
    'createdAt': b.createdAt.toIso8601String(),
    'completedAt': b.completedAt?.toIso8601String(),
    'status': b.status,
  };

  NotificationBatch _mapToBatch(Map<String, dynamic> m) => NotificationBatch(
    batchId: m['batchId'],
    notificationIds: List<String>.from(m['notificationIds']),
    totalCount: m['totalCount'],
    successCount: m['successCount'],
    failureCount: m['failureCount'],
    createdAt: DateTime.parse(m['createdAt']),
    completedAt: m['completedAt'] != null ? DateTime.parse(m['completedAt']) : null,
    status: m['status'],
  );

  Map<String, dynamic> _logToMap(NotificationLog l) => {
    'logId': l.logId,
    'notificationId': l.notificationId,
    'timestamp': l.timestamp.toIso8601String(),
    'eventType': l.eventType,
    'errorMessage': l.errorMessage,
    'details': l.details,
  };

  NotificationLog _mapToLog(Map<String, dynamic> m) => NotificationLog(
    logId: m['logId'],
    notificationId: m['notificationId'],
    timestamp: DateTime.parse(m['timestamp']),
    eventType: m['eventType'],
    errorMessage: m['errorMessage'],
    details: m['details'] ?? {},
  );
}

// Engines
class NotificationDistributionEngine {
  Future<Notification> distributeNotification(Notification notification) async {
    return notification;
  }
}

class MessageQueueEngine {
  Future<Message> queueMessage(Message message) async {
    return message;
  }
}

class SubscriptionEngine {
  Future<List<Subscription>> evaluateSubscriptions(NotificationTopic topic) async {
    return [];
  }
}

class SchedulingEngine {
  Future<NotificationSchedule> scheduleForDelivery(NotificationSchedule schedule) async {
    return schedule;
  }
}

class PreferenceEngine {
  Future<bool> respectsPreferences(Notification notification, NotificationPreference preference) async {
    return true;
  }
}

class NotificationManager {
  final NotificationRepository repository;
  final NotificationDistributionEngine distributionEngine;
  final MessageQueueEngine messageEngine;
  final SubscriptionEngine subscriptionEngine;
  final SchedulingEngine schedulingEngine;
  final PreferenceEngine preferenceEngine;

  NotificationManager({
    required this.repository,
    required this.distributionEngine,
    required this.messageEngine,
    required this.subscriptionEngine,
    required this.schedulingEngine,
    required this.preferenceEngine,
  });
}

class NotificationFacade {
  final NotificationRepository repository;
  final NotificationManager manager;

  NotificationFacade({required this.repository, required this.manager});

  Future<Notification> sendNotification(String recipientId, String title, String message, NotificationChannel channel) =>
      repository.createNotification(recipientId, title, message, channel, NotificationPriority.normal);

  Future<List<Notification>> getNotifications(String recipientId) => repository.listNotifications(recipientId);

  Future<Message> sendMessage(String senderId, String recipientId, String content) =>
      repository.createMessage(senderId, recipientId, content, MessageType.alert);

  Future<int> getUnreadMessageCount(String userId) => repository.getUnreadCount(userId);
}
