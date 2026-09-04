/// Real-time Notification & Messaging Models

enum NotificationChannel { email, sms, push, webhook, inApp, slack, teams }
enum NotificationStatus { pending, sent, delivered, failed, expired, archived }
enum NotificationPriority { critical, high, normal, low, minimal }
enum MessageType { alert, update, reminder, confirmation, broadcast, scheduled }
enum SubscriptionStatus { active, paused, unsubscribed, suspended, expired }
enum NotificationTopic { incident, deployment, health, performance, security, audit }

class Notification {
  final String notificationId;
  final String recipientId;
  final String title;
  final String message;
  final NotificationChannel channel;
  final NotificationStatus status;
  final NotificationPriority priority;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final String? relatedEntityId;
  final Map<String, dynamic> metadata;

  Notification({
    required this.notificationId,
    required this.recipientId,
    required this.title,
    required this.message,
    required this.channel,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.sentAt,
    this.deliveredAt,
    this.relatedEntityId,
    required this.metadata,
  });

  bool get isPending => status == NotificationStatus.pending;
  bool get isDelivered => status == NotificationStatus.delivered;
  bool get isFailed => status == NotificationStatus.failed;
  bool get isUrgent => priority == NotificationPriority.critical || priority == NotificationPriority.high;
  int get ageInMinutes => DateTime.now().difference(createdAt).inMinutes;
  int get deliveryTimeMs => deliveredAt != null ? deliveredAt!.difference(createdAt).inMilliseconds : -1;
}

class Message {
  final String messageId;
  final String senderId;
  final String recipientId;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  final DateTime? readAt;
  final List<String> attachmentIds;
  final Map<String, dynamic> context;
  final bool isArchived;

  Message({
    required this.messageId,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.type,
    required this.createdAt,
    this.readAt,
    required this.attachmentIds,
    required this.context,
    this.isArchived = false,
  });

  bool get isRead => readAt != null;
  bool get isUnread => readAt == null;
  int get ageInMinutes => DateTime.now().difference(createdAt).inMinutes;
  int get attachmentCount => attachmentIds.length;
}

class Subscription {
  final String subscriptionId;
  final String userId;
  final NotificationTopic topic;
  final List<NotificationChannel> channels;
  final SubscriptionStatus status;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final bool muteNotifications;
  final int? dailyLimitCount;

  Subscription({
    required this.subscriptionId,
    required this.userId,
    required this.topic,
    required this.channels,
    required this.status,
    required this.createdAt,
    this.modifiedAt,
    this.muteNotifications = false,
    this.dailyLimitCount,
  });

  bool get isActive => status == SubscriptionStatus.active;
  bool get isPaused => status == SubscriptionStatus.paused;
  bool get isUnsubscribed => status == SubscriptionStatus.unsubscribed;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  int get channelCount => channels.length;
}

class NotificationTemplate {
  final String templateId;
  final String name;
  final String title;
  final String messageTemplate;
  final NotificationTopic topic;
  final NotificationPriority defaultPriority;
  final List<NotificationChannel> supportedChannels;
  final DateTime createdAt;
  final bool isActive;
  final Map<String, String> placeholders;

  NotificationTemplate({
    required this.templateId,
    required this.name,
    required this.title,
    required this.messageTemplate,
    required this.topic,
    required this.defaultPriority,
    required this.supportedChannels,
    required this.createdAt,
    this.isActive = true,
    required this.placeholders,
  });

  bool get isUsable => isActive && supportedChannels.isNotEmpty;
  int get placeholderCount => placeholders.length;
}

class NotificationSchedule {
  final String scheduleId;
  final String notificationId;
  final DateTime scheduledTime;
  final bool isRecurring;
  final String? recurringPattern;
  final DateTime? expiresAt;
  final DateTime? executedAt;
  final bool isActive;

  NotificationSchedule({
    required this.scheduleId,
    required this.notificationId,
    required this.scheduledTime,
    this.isRecurring = false,
    this.recurringPattern,
    this.expiresAt,
    this.executedAt,
    this.isActive = true,
  });

  bool get isPending => executedAt == null;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isDue => DateTime.now().isAfter(scheduledTime) && !isPending;
  int get minutesUntilExecution => scheduledTime.difference(DateTime.now()).inMinutes;
}

class NotificationPreference {
  final String preferenceId;
  final String userId;
  final Map<NotificationChannel, bool> channelPreferences;
  final Map<NotificationTopic, bool> topicPreferences;
  final int? quietHourStart;
  final int? quietHourEnd;
  final NotificationPriority? minimumPriority;
  final DateTime lastModified;

  NotificationPreference({
    required this.preferenceId,
    required this.userId,
    required this.channelPreferences,
    required this.topicPreferences,
    this.quietHourStart,
    this.quietHourEnd,
    this.minimumPriority,
    required this.lastModified,
  });

  bool get hasQuietHours => quietHourStart != null && quietHourEnd != null;
  int get enabledChannels => channelPreferences.values.where((v) => v).length;
  int get enabledTopics => topicPreferences.values.where((v) => v).length;
}

class NotificationBatch {
  final String batchId;
  final List<String> notificationIds;
  final int totalCount;
  final int successCount;
  final int failureCount;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String status;

  NotificationBatch({
    required this.batchId,
    required this.notificationIds,
    required this.totalCount,
    required this.successCount,
    required this.failureCount,
    required this.createdAt,
    this.completedAt,
    required this.status,
  });

  double get successRate => totalCount > 0 ? (successCount / totalCount) * 100 : 0.0;
  bool get isComplete => completedAt != null;
  int get processingTimeMs => completedAt != null ? completedAt!.difference(createdAt).inMilliseconds : -1;
}

class NotificationLog {
  final String logId;
  final String notificationId;
  final DateTime timestamp;
  final String eventType;
  final String? errorMessage;
  final Map<String, dynamic> details;

  NotificationLog({
    required this.logId,
    required this.notificationId,
    required this.timestamp,
    required this.eventType,
    this.errorMessage,
    required this.details,
  });

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  int get ageInMinutes => DateTime.now().difference(timestamp).inMinutes;
}

class NotificationAnalytics {
  final String analyticsId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalSent;
  final int totalDelivered;
  final int totalFailed;
  final double deliveryRate;
  final Map<NotificationChannel, int> channelBreakdown;
  final Map<NotificationTopic, int> topicBreakdown;
  final double averageDeliveryTimeMs;

  NotificationAnalytics({
    required this.analyticsId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalSent,
    required this.totalDelivered,
    required this.totalFailed,
    required this.deliveryRate,
    required this.channelBreakdown,
    required this.topicBreakdown,
    required this.averageDeliveryTimeMs,
  });

  double get failureRate => totalSent > 0 ? ((totalSent - totalDelivered) / totalSent) * 100 : 0.0;
  int get periodInDays => periodEnd.difference(periodStart).inDays;
}
