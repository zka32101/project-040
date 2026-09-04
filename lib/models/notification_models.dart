/// Phase 46: Real-time Notifications System リアルタイム通知モデル定義
///
/// 通知、配信、設定、テンプレート管理

/// 通知タイプ
enum NotificationType {
  system('system'),
  alert('alert'),
  feedback('feedback'),
  report('report'),
  reminder('reminder'),
  error('error'),
  success('success'),
  warning('warning');

  final String value;
  const NotificationType(this.value);
}

/// 通知チャネル
enum NotificationChannel {
  email('email'),
  sms('sms'),
  push('push'),
  inApp('in_app'),
  webhook('webhook');

  final String value;
  const NotificationChannel(this.value);
}

/// 通知ステータス
enum NotificationStatus {
  pending('pending'),
  sent('sent'),
  delivered('delivered'),
  read('read'),
  failed('failed'),
  deleted('deleted');

  final String value;
  const NotificationStatus(this.value);
}

/// 優先度レベル
enum NotificationPriority {
  low(1),
  normal(2),
  high(3),
  critical(4);

  final int value;
  const NotificationPriority(this.value);
}

/// リアルタイム通知
class Notification {
  final String notificationId;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationChannel channel;
  final NotificationStatus status;
  final NotificationPriority priority;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime? readAt;
  final DateTime? expiresAt;
  final List<String>? tags;

  Notification({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.channel,
    this.status = NotificationStatus.pending,
    this.priority = NotificationPriority.normal,
    this.actionUrl,
    this.metadata,
    required this.createdAt,
    this.sentAt,
    this.readAt,
    this.expiresAt,
    this.tags,
  });

  /// 通知が既読か
  bool get isRead => status == NotificationStatus.read;

  /// 通知が配信済みか
  bool get isDelivered => status == NotificationStatus.delivered || isRead;

  /// 通知が失敗したか
  bool get isFailed => status == NotificationStatus.failed;

  /// 通知が期限切れか
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 通知の年齢
  Duration get age => DateTime.now().difference(createdAt);

  /// 配信時間
  Duration? get deliveryTime {
    if (sentAt == null) return null;
    return sentAt!.difference(createdAt);
  }

  /// 既読までの時間
  Duration? get readTime {
    if (readAt == null) return null;
    return readAt!.difference(createdAt);
  }
}

/// 通知設定
class NotificationPreference {
  final String preferenceId;
  final String userId;
  final Map<NotificationType, bool> typePreferences;
  final Map<NotificationChannel, bool> channelPreferences;
  final bool enableNotifications;
  final String? quietHoursStart; // HH:mm format
  final String? quietHoursEnd;
  final List<String>? mutedTopics;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NotificationPreference({
    required this.preferenceId,
    required this.userId,
    required this.typePreferences,
    required this.channelPreferences,
    this.enableNotifications = true,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.mutedTopics,
    required this.createdAt,
    this.updatedAt,
  });

  /// 通知タイプが有効か
  bool isTypeEnabled(NotificationType type) {
    return typePreferences[type] ?? true;
  }

  /// チャネルが有効か
  bool isChannelEnabled(NotificationChannel channel) {
    return channelPreferences[channel] ?? true;
  }

  /// クワイエットアワー中か
  bool get isInQuietHours {
    if (quietHoursStart == null || quietHoursEnd == null) return false;
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return currentTime.compareTo(quietHoursStart!) >= 0 && currentTime.compareTo(quietHoursEnd!) <= 0;
  }
}

/// 通知キュー
class NotificationQueue {
  final String queueId;
  final String notificationId;
  final NotificationChannel channel;
  final int retryCount;
  final int maxRetries;
  final DateTime queuedAt;
  final DateTime? processedAt;
  final String? errorMessage;

  NotificationQueue({
    required this.queueId,
    required this.notificationId,
    required this.channel,
    this.retryCount = 0,
    this.maxRetries = 3,
    required this.queuedAt,
    this.processedAt,
    this.errorMessage,
  });

  /// リトライ可能か
  bool get canRetry => retryCount < maxRetries;

  /// 処理済みか
  bool get isProcessed => processedAt != null;

  /// 処理待ちか
  bool get isPending => !isProcessed;
}

/// 通知配信履歴
class NotificationDelivery {
  final String deliveryId;
  final String notificationId;
  final NotificationChannel channel;
  final String recipient;
  final NotificationStatus status;
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final String? response;
  final int? statusCode;
  final Duration? latency;

  NotificationDelivery({
    required this.deliveryId,
    required this.notificationId,
    required this.channel,
    required this.recipient,
    required this.status,
    required this.sentAt,
    this.deliveredAt,
    this.response,
    this.statusCode,
    this.latency,
  });

  /// 配信に成功したか
  bool get isSuccessful => status == NotificationStatus.delivered;

  /// 配信に失敗したか
  bool get hasFailed => status == NotificationStatus.failed;

  /// 配信時間（秒）
  double? get latencySeconds => latency?.inMilliseconds.toDouble() ?? 0;
}

/// 通知テンプレート
class NotificationTemplate {
  final String templateId;
  final String name;
  final NotificationType type;
  final String titleTemplate;
  final String messageTemplate;
  final Map<String, dynamic>? defaultData;
  final List<String>? variables;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  NotificationTemplate({
    required this.templateId,
    required this.name,
    required this.type,
    required this.titleTemplate,
    required this.messageTemplate,
    this.defaultData,
    this.variables,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  /// テンプレートをレンダリング
  Map<String, String> render(Map<String, dynamic> data) {
    String title = titleTemplate;
    String message = messageTemplate;

    for (final variable in variables ?? []) {
      final value = data[variable]?.toString() ?? '';
      title = title.replaceAll('{{$variable}}', value);
      message = message.replaceAll('{{$variable}}', value);
    }

    return {'title': title, 'message': message};
  }

  /// 必要な変数をチェック
  bool validate(Map<String, dynamic> data) {
    for (final variable in variables ?? []) {
      if (!data.containsKey(variable)) return false;
    }
    return true;
  }
}

/// 通知統計
class NotificationStats {
  final String statsId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalNotifications;
  final int sentCount;
  final int deliveredCount;
  final int readCount;
  final int failedCount;
  final Map<NotificationType, int> typeDistribution;
  final Map<NotificationChannel, int> channelDistribution;
  final double averageDeliveryTime; // seconds
  final double deliveryRate; // 0.0-1.0

  NotificationStats({
    required this.statsId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalNotifications,
    required this.sentCount,
    required this.deliveredCount,
    required this.readCount,
    required this.failedCount,
    required this.typeDistribution,
    required this.channelDistribution,
    required this.averageDeliveryTime,
    required this.deliveryRate,
  });

  /// 読了率
  double get readRate {
    if (deliveredCount == 0) return 0.0;
    return readCount / deliveredCount;
  }

  /// 失敗率
  double get failureRate {
    if (totalNotifications == 0) return 0.0;
    return failedCount / totalNotifications;
  }

  /// 最も使用されたタイプ
  NotificationType? get mostUsedType {
    if (typeDistribution.isEmpty) return null;
    return typeDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 最も使用されたチャネル
  NotificationChannel? get mostUsedChannel {
    if (channelDistribution.isEmpty) return null;
    return channelDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

/// 通知レポート
class NotificationReport {
  final String reportId;
  final DateTime generatedAt;
  final NotificationStats stats;
  final List<Notification> topNotifications;
  final List<NotificationDelivery> recentDeliveries;
  final Map<String, dynamic>? insights;

  NotificationReport({
    required this.reportId,
    required this.generatedAt,
    required this.stats,
    required this.topNotifications,
    required this.recentDeliveries,
    this.insights,
  });

  /// Markdown形式でレポートを生成
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Notification Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');

    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Total Notifications: ${stats.totalNotifications}');
    buffer.writeln('- Sent: ${stats.sentCount}');
    buffer.writeln('- Delivered: ${stats.deliveredCount}');
    buffer.writeln('- Read: ${stats.readCount}');
    buffer.writeln('- Failed: ${stats.failedCount}');
    buffer.writeln('- Delivery Rate: ${(stats.deliveryRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('- Read Rate: ${(stats.readRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('- Failure Rate: ${(stats.failureRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('- Avg Delivery Time: ${stats.averageDeliveryTime.toStringAsFixed(2)}s');
    buffer.writeln('');

    buffer.writeln('## Distribution');
    buffer.writeln('');
    buffer.writeln('### By Type');
    for (final entry in stats.typeDistribution.entries) {
      buffer.writeln('- ${entry.key.value}: ${entry.value}');
    }
    buffer.writeln('');

    buffer.writeln('### By Channel');
    for (final entry in stats.channelDistribution.entries) {
      buffer.writeln('- ${entry.key.value}: ${entry.value}');
    }
    buffer.writeln('');

    return buffer.toString();
  }
}
