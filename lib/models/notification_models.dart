/// Phase 59: Real-time Notifications & Alerts リアルタイム通知・アラート
///
/// 通知、アラート、チャネル、テンプレート、配信トラッキング機能

/// 通知タイプ
enum NotificationType {
  info('info'),
  warning('warning'),
  error('error'),
  success('success'),
  alert('alert');

  final String value;
  const NotificationType(this.value);
}

/// 配信チャネル
enum DeliveryChannel {
  inApp('in_app'),
  email('email'),
  sms('sms'),
  pushNotification('push'),
  slack('slack'),
  webhook('webhook');

  final String value;
  const DeliveryChannel(this.value);
}

/// 通知ステータス
enum NotificationStatus {
  pending('pending'),
  sent('sent'),
  delivered('delivered'),
  read('read'),
  failed('failed'),
  bounced('bounced');

  final String value;
  const NotificationStatus(this.value);
}

/// 優先度レベル
enum PriorityLevel {
  low('low'),
  normal('normal'),
  high('high'),
  critical('critical');

  final String value;
  const PriorityLevel(this.value);
}

/// アラートタイプ
enum AlertType {
  threshold('threshold'),
  anomaly('anomaly'),
  errorRate('error_rate'),
  performanceDegradation('performance_degradation'),
  securityEvent('security_event'),
  custom('custom');

  final String value;
  const AlertType(this.value);
}

/// アラートステータス
enum AlertStatus {
  active('active'),
  acknowledged('acknowledged'),
  resolved('resolved'),
  silenced('silenced');

  final String value;
  const AlertStatus(this.value);
}

/// 基本通知
class Notification {
  final String notificationId;
  final String userId;
  final String title;
  final String message;
  final NotificationType notificationType;
  final PriorityLevel priority;
  final DateTime createdAt;
  final DateTime? readAt;
  final NotificationStatus status;
  final Map<String, dynamic>? metadata;
  final String? actionUrl;

  Notification({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.notificationType,
    this.priority = PriorityLevel.normal,
    required this.createdAt,
    this.readAt,
    this.status = NotificationStatus.pending,
    this.metadata,
    this.actionUrl,
  });

  /// 通知が配信されたか
  bool get isDelivered => status == NotificationStatus.delivered || status == NotificationStatus.read;

  /// 通知が読まれたか
  bool get isRead => readAt != null;

  /// 通知が失敗したか
  bool get hasFailed => status == NotificationStatus.failed || status == NotificationStatus.bounced;

  /// 優先度は高いか
  bool get isHighPriority => priority == PriorityLevel.high || priority == PriorityLevel.critical;

  /// 通知年齢（時間）
  int get ageInHours => DateTime.now().difference(createdAt).inHours;

  /// 通知が古いか（24時間以上）
  bool get isOld => ageInHours > 24;
}

/// 配信ログ
class DeliveryLog {
  final String logId;
  final String notificationId;
  final DeliveryChannel channel;
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final NotificationStatus status;
  final String? errorMessage;
  final int retryCount;
  final String? recipientIdentifier;

  DeliveryLog({
    required this.logId,
    required this.notificationId,
    required this.channel,
    required this.sentAt,
    this.deliveredAt,
    this.status = NotificationStatus.pending,
    this.errorMessage,
    this.retryCount = 0,
    this.recipientIdentifier,
  });

  /// 配信が成功したか
  bool get isSuccessful => status == NotificationStatus.delivered || status == NotificationStatus.read;

  /// 配信が失敗したか
  bool get hasFailed => status == NotificationStatus.failed || status == NotificationStatus.bounced;

  /// 配信時間（秒）
  int? get deliveryTimeInSeconds {
    if (deliveredAt == null) return null;
    return deliveredAt!.difference(sentAt).inSeconds;
  }

  /// 配信待機中か
  bool get isPending => status == NotificationStatus.pending;
}

/// 通知テンプレート
class NotificationTemplate {
  final String templateId;
  final String templateName;
  final String titleTemplate;
  final String messageTemplate;
  final NotificationType notificationType;
  final PriorityLevel defaultPriority;
  final List<DeliveryChannel> channels;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final int usageCount;

  NotificationTemplate({
    required this.templateId,
    required this.templateName,
    required this.titleTemplate,
    required this.messageTemplate,
    required this.notificationType,
    this.defaultPriority = PriorityLevel.normal,
    required this.channels,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.usageCount = 0,
  });

  /// テンプレートが有効か
  bool get isEnabled => isActive;

  /// チャネル数
  int get channelCount => channels.length;

  /// テンプレートはよく使われているか（10回以上）
  bool get isPopular => usageCount >= 10;
}

/// 通知パラメータ
class NotificationParameter {
  final String parameterId;
  final String templateId;
  final String parameterName;
  final String defaultValue;
  final bool isRequired;
  final String? description;

  NotificationParameter({
    required this.parameterId,
    required this.templateId,
    required this.parameterName,
    required this.defaultValue,
    this.isRequired = false,
    this.description,
  });

  /// パラメータが必須か
  bool get isMandatory => isRequired;
}

/// ユーザー通知設定
class NotificationPreference {
  final String preferenceId;
  final String userId;
  final Map<DeliveryChannel, bool> channelPreferences;
  final Map<NotificationType, bool> typePreferences;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool pushNotifications;
  final bool inAppNotifications;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEnabled;

  NotificationPreference({
    required this.preferenceId,
    required this.userId,
    required this.channelPreferences,
    required this.typePreferences,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.pushNotifications = true,
    this.inAppNotifications = true,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  bool isActive;

  /// 設定が有効か
  bool get isEnabled => isActive;

  /// 通知が完全に無効か
  bool get isCompletelyDisabled => !emailNotifications && !smsNotifications && !pushNotifications && !inAppNotifications;

  /// 有効なチャネル数
  int get enabledChannelCount => [emailNotifications, smsNotifications, pushNotifications, inAppNotifications].where((e) => e).length;
}

/// アラート定義
class Alert {
  final String alertId;
  final String alertName;
  final AlertType alertType;
  final String condition;
  final PriorityLevel severity;
  final List<String> recipients;
  final List<DeliveryChannel> notificationChannels;
  final DateTime createdAt;
  final DateTime? lastTriggeredAt;
  final AlertStatus status;
  final bool isEnabled;
  final int triggerCount;

  Alert({
    required this.alertId,
    required this.alertName,
    required this.alertType,
    required this.condition,
    required this.severity,
    required this.recipients,
    required this.notificationChannels,
    required this.createdAt,
    this.lastTriggeredAt,
    this.status = AlertStatus.active,
    this.isEnabled = true,
    this.triggerCount = 0,
  });

  /// アラートが有効か
  bool get isActive => isEnabled && status != AlertStatus.silenced;

  /// アラートは最近トリガーされたか（1時間以内）
  bool get wasRecentlyTriggered {
    if (lastTriggeredAt == null) return false;
    return DateTime.now().difference(lastTriggeredAt!).inMinutes < 60;
  }

  /// アラートはよくトリガーされているか（10回以上）
  bool get isFrequent => triggerCount >= 10;

  /// 最後のトリガーからの経過時間（時間）
  int? get hoursSinceLastTrigger {
    if (lastTriggeredAt == null) return null;
    return DateTime.now().difference(lastTriggeredAt!).inHours;
  }
}

/// アラートイベント
class AlertEvent {
  final String eventId;
  final String alertId;
  final DateTime occurredAt;
  final String message;
  final Map<String, dynamic>? details;
  final String severity;
  final bool isAcknowledged;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;

  AlertEvent({
    required this.eventId,
    required this.alertId,
    required this.occurredAt,
    required this.message,
    this.details,
    this.severity = 'warning',
    this.isAcknowledged = false,
    this.acknowledgedAt,
    this.acknowledgedBy,
  });

  /// イベントが確認されたか
  bool get isConfirmed => isAcknowledged;

  /// イベント年齢（分）
  int get ageInMinutes => DateTime.now().difference(occurredAt).inMinutes;

  /// イベントは最近か（30分以内）
  bool get isRecent => ageInMinutes < 30;
}

/// 通知統計
class NotificationStats {
  final String statsId;
  final int totalNotifications;
  final int sentNotifications;
  final int deliveredNotifications;
  final int readNotifications;
  final int failedNotifications;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double deliveryRate; // 0.0-1.0
  final double readRate; // 0.0-1.0
  final int averageDeliveryTimeSeconds;

  NotificationStats({
    required this.statsId,
    required this.totalNotifications,
    required this.sentNotifications,
    required this.deliveredNotifications,
    required this.readNotifications,
    required this.failedNotifications,
    required this.periodStart,
    required this.periodEnd,
    required this.deliveryRate,
    required this.readRate,
    required this.averageDeliveryTimeSeconds,
  });

  /// 統計が良好か
  bool get isHealthy => deliveryRate > 0.95 && readRate > 0.5;

  /// 配信率はパーセンテージ
  double get deliveryRatePercentage => deliveryRate * 100;

  /// 開封率はパーセンテージ
  double get readRatePercentage => readRate * 100;

  /// 失敗率
  double get failureRate {
    if (totalNotifications == 0) return 0.0;
    return failedNotifications / totalNotifications;
  }
}

/// 通知レポート
class NotificationReport {
  final String reportId;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final NotificationStats stats;
  final List<String> topNotificationTypes;
  final List<String> topChannels;
  final List<String>? recommendations;

  NotificationReport({
    required this.reportId,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.stats,
    required this.topNotificationTypes,
    required this.topChannels,
    this.recommendations,
  });

  /// レポートが良好か
  bool get isHealthy => stats.isHealthy;

  /// Markdown形式で出力
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Notification Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');

    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Total Notifications: ${stats.totalNotifications}');
    buffer.writeln('- Delivery Rate: ${stats.deliveryRatePercentage.toStringAsFixed(1)}%');
    buffer.writeln('- Read Rate: ${stats.readRatePercentage.toStringAsFixed(1)}%');
    buffer.writeln('- Failed: ${stats.failedNotifications}');
    buffer.writeln('- Average Delivery Time: ${stats.averageDeliveryTimeSeconds}s');
    buffer.writeln('');

    if (topNotificationTypes.isNotEmpty) {
      buffer.writeln('## Top Notification Types');
      buffer.writeln('');
      for (final type in topNotificationTypes.take(5)) {
        buffer.writeln('- $type');
      }
      buffer.writeln('');
    }

    if (topChannels.isNotEmpty) {
      buffer.writeln('## Top Channels');
      buffer.writeln('');
      for (final channel in topChannels.take(5)) {
        buffer.writeln('- $channel');
      }
      buffer.writeln('');
    }

    if (recommendations != null && recommendations!.isNotEmpty) {
      buffer.writeln('## Recommendations');
      buffer.writeln('');
      for (final rec in recommendations!.take(5)) {
        buffer.writeln('- $rec');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}

/// 通知キューエントリ
class QueueEntry {
  final String entryId;
  final String notificationId;
  final DeliveryChannel channel;
  final DateTime enqueuedAt;
  final DateTime? processedAt;
  final String status; // queued, processing, completed, failed
  final int priority;
  final int retryCount;
  final String? lastError;

  QueueEntry({
    required this.entryId,
    required this.notificationId,
    required this.channel,
    required this.enqueuedAt,
    this.processedAt,
    this.status = 'queued',
    this.priority = 0,
    this.retryCount = 0,
    this.lastError,
  });

  /// エントリが処理中か
  bool get isProcessing => status == 'processing';

  /// エントリが完了したか
  bool get isCompleted => status == 'completed';

  /// エントリが失敗したか
  bool get hasFailed => status == 'failed';

  /// 待機時間（秒）
  int? get queuedTimeInSeconds {
    if (processedAt == null) return null;
    return processedAt!.difference(enqueuedAt).inSeconds;
  }

  /// 再試行が必要か
  bool get needsRetry => retryCount < 3 && hasFailed;
}

/// チャネル設定
class ChannelConfiguration {
  final String configId;
  final DeliveryChannel channel;
  final bool isEnabled;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerified;

  ChannelConfiguration({
    required this.configId,
    required this.channel,
    required this.isEnabled,
    required this.settings,
    required this.createdAt,
    this.updatedAt,
    this.isVerified = false,
  });

  /// チャネルが有効か
  bool get isActive => isEnabled && isVerified;

  /// チャネルが検証済みか
  bool get isReady => isVerified;
}
