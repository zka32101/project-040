/// Phase 27: 通知サービス
/// プッシュ通知、メール、Webhook 統合

import '../models/async_job_model.dart';
import 'dart:async';

// ==================== 通知関連モデル ====================

/// 通知タイプ
enum NotificationType {
  jobCompleted,
  jobFailed,
  jobCancelled,
  alertWarning,
  reportGenerated,
  systemNotification,
}

/// 通知優先度
enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

/// 通知チャネル
enum NotificationChannel {
  push,
  email,
  webhook,
  inApp,
}

/// 通知モデル
class Notification {
  final String notificationId;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final NotificationPriority priority;
  final List<NotificationChannel> channels;
  final DateTime createdAt;
  final DateTime? sentAt;
  final Map<String, dynamic>? metadata;
  final bool read;

  const Notification({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.priority,
    required this.channels,
    required this.createdAt,
    this.sentAt,
    this.metadata,
    this.read = false,
  });

  Notification copyWith({
    String? notificationId,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    NotificationPriority? priority,
    List<NotificationChannel>? channels,
    DateTime? createdAt,
    DateTime? sentAt,
    Map<String, dynamic>? metadata,
    bool? read,
  }) =>
      Notification(
        notificationId: notificationId ?? this.notificationId,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        title: title ?? this.title,
        message: message ?? this.message,
        priority: priority ?? this.priority,
        channels: channels ?? this.channels,
        createdAt: createdAt ?? this.createdAt,
        sentAt: sentAt ?? this.sentAt,
        metadata: metadata ?? this.metadata,
        read: read ?? this.read,
      );

  Map<String, dynamic> toJson() => {
        'notificationId': notificationId,
        'userId': userId,
        'type': type.toString().split('.').last,
        'title': title,
        'message': message,
        'priority': priority.toString().split('.').last,
        'channels': channels.map((c) => c.toString().split('.').last).toList(),
        'createdAt': createdAt.toIso8601String(),
        'sentAt': sentAt?.toIso8601String(),
        'metadata': metadata,
        'read': read,
      };
}

/// ユーザー通知設定
class NotificationPreferences {
  final String userId;
  final bool enablePushNotifications;
  final bool enableEmailNotifications;
  final bool enableWebhooks;
  final List<NotificationType> preferredTypes;
  final Map<NotificationChannel, bool> channelPreferences;
  final DateTime updatedAt;

  const NotificationPreferences({
    required this.userId,
    this.enablePushNotifications = true,
    this.enableEmailNotifications = true,
    this.enableWebhooks = false,
    this.preferredTypes = const [],
    this.channelPreferences = const {},
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'enablePushNotifications': enablePushNotifications,
        'enableEmailNotifications': enableEmailNotifications,
        'enableWebhooks': enableWebhooks,
        'preferredTypes':
            preferredTypes.map((t) => t.toString().split('.').last).toList(),
        'channelPreferences': channelPreferences
            .map((k, v) => MapEntry(k.toString().split('.').last, v)),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

// ==================== 通知サービスインターフェース ====================

/// 通知サービス
abstract class NotificationService {
  /// 通知を送信
  Future<void> sendNotification(Notification notification);

  /// ジョブ完了通知を送信
  Future<void> notifyJobCompleted(AsyncJob job);

  /// ジョブ失敗通知を送信
  Future<void> notifyJobFailed(AsyncJob job, String errorMessage);

  /// ユーザーの通知を取得
  Future<List<Notification>> getUserNotifications(String userId);

  /// 通知を既読にマーク
  Future<void> markAsRead(String notificationId);

  /// 通知を削除
  Future<void> deleteNotification(String notificationId);

  /// 通知設定を更新
  Future<void> updatePreferences(NotificationPreferences preferences);

  /// ユーザーの通知設定を取得
  Future<NotificationPreferences?> getPreferences(String userId);
}

/// プッシュ通知サービス
abstract class PushNotificationService {
  /// デバイストークンを登録
  Future<void> registerDeviceToken(String userId, String deviceToken);

  /// プッシュ通知を送信
  Future<void> sendPushNotification(String deviceToken, String title,
      String message, Map<String, dynamic>? data);

  /// トピックを購読
  Future<void> subscribeTopic(String deviceToken, String topic);

  /// トピックを購読解除
  Future<void> unsubscribeTopic(String deviceToken, String topic);
}

/// メール通知サービス
abstract class EmailNotificationService {
  /// メール通知を送信
  Future<void> sendEmail(
    String toEmail,
    String subject,
    String body, {
    String? htmlBody,
  });

  /// テンプレートメールを送信
  Future<void> sendTemplateEmail(
    String toEmail,
    String templateId,
    Map<String, dynamic> variables,
  );

  /// 一括メール送信
  Future<void> sendBulkEmail(
    List<String> recipients,
    String subject,
    String body,
  );
}

/// Webhook サービス
abstract class WebhookService {
  /// Webhook を登録
  Future<void> registerWebhook(String userId, String url);

  /// Webhook を削除
  Future<void> unregisterWebhook(String userId, String webhookId);

  /// ユーザーの Webhook を取得
  Future<List<Map<String, dynamic>>> getUserWebhooks(String userId);

  /// イベントを Webhook に送信
  Future<void> sendWebhookEvent(
    String userId,
    String eventType,
    Map<String, dynamic> payload,
  );
}

// ==================== メモリ実装 ====================

/// メモリベースの通知サービス実装
class MemoryNotificationService implements NotificationService {
  final Map<String, List<Notification>> _userNotifications = {};
  final Map<String, NotificationPreferences> _preferences = {};

  @override
  Future<void> sendNotification(Notification notification) async {
    if (!_userNotifications.containsKey(notification.userId)) {
      _userNotifications[notification.userId] = [];
    }
    _userNotifications[notification.userId]!.add(
      notification.copyWith(sentAt: DateTime.now()),
    );
  }

  @override
  Future<void> notifyJobCompleted(AsyncJob job) async {
    final notification = Notification(
      notificationId: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: job.userId,
      type: NotificationType.jobCompleted,
      title: 'ジョブ完了',
      message: 'ジョブ ${job.jobId} が完了しました',
      priority: NotificationPriority.normal,
      channels: [NotificationChannel.push, NotificationChannel.email],
      createdAt: DateTime.now(),
      metadata: {'jobId': job.jobId},
    );
    await sendNotification(notification);
  }

  @override
  Future<void> notifyJobFailed(AsyncJob job, String errorMessage) async {
    final notification = Notification(
      notificationId: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: job.userId,
      type: NotificationType.jobFailed,
      title: 'ジョブ失敗',
      message: 'ジョブ ${job.jobId} が失敗しました: $errorMessage',
      priority: NotificationPriority.high,
      channels: [NotificationChannel.push, NotificationChannel.email],
      createdAt: DateTime.now(),
      metadata: {'jobId': job.jobId, 'error': errorMessage},
    );
    await sendNotification(notification);
  }

  @override
  Future<List<Notification>> getUserNotifications(String userId) async {
    return _userNotifications[userId] ?? [];
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    for (var notifications in _userNotifications.values) {
      for (int i = 0; i < notifications.length; i++) {
        if (notifications[i].notificationId == notificationId) {
          notifications[i] = notifications[i].copyWith(read: true);
          return;
        }
      }
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    for (var notifications in _userNotifications.values) {
      notifications.removeWhere((n) => n.notificationId == notificationId);
    }
  }

  @override
  Future<void> updatePreferences(NotificationPreferences preferences) async {
    _preferences[preferences.userId] = preferences;
  }

  @override
  Future<NotificationPreferences?> getPreferences(String userId) async {
    return _preferences[userId];
  }
}

/// メモリベースのプッシュ通知サービス実装
class MemoryPushNotificationService implements PushNotificationService {
  final Map<String, List<String>> _deviceTokens = {};
  final Map<String, Set<String>> _subscriptions = {};

  @override
  Future<void> registerDeviceToken(String userId, String deviceToken) async {
    if (!_deviceTokens.containsKey(userId)) {
      _deviceTokens[userId] = [];
    }
    if (!_deviceTokens[userId]!.contains(deviceToken)) {
      _deviceTokens[userId]!.add(deviceToken);
    }
  }

  @override
  Future<void> sendPushNotification(
    String deviceToken,
    String title,
    String message,
    Map<String, dynamic>? data,
  ) async {
    // メモリ実装では通知を記録するだけ
  }

  @override
  Future<void> subscribeTopic(String deviceToken, String topic) async {
    if (!_subscriptions.containsKey(deviceToken)) {
      _subscriptions[deviceToken] = {};
    }
    _subscriptions[deviceToken]!.add(topic);
  }

  @override
  Future<void> unsubscribeTopic(String deviceToken, String topic) async {
    if (_subscriptions.containsKey(deviceToken)) {
      _subscriptions[deviceToken]!.remove(topic);
    }
  }
}

/// メモリベースのメール通知サービス実装
class MemoryEmailNotificationService implements EmailNotificationService {
  final List<Map<String, dynamic>> _sentEmails = [];

  @override
  Future<void> sendEmail(
    String toEmail,
    String subject,
    String body, {
    String? htmlBody,
  }) async {
    _sentEmails.add({
      'to': toEmail,
      'subject': subject,
      'body': body,
      'htmlBody': htmlBody,
      'sentAt': DateTime.now(),
    });
  }

  @override
  Future<void> sendTemplateEmail(
    String toEmail,
    String templateId,
    Map<String, dynamic> variables,
  ) async {
    _sentEmails.add({
      'to': toEmail,
      'templateId': templateId,
      'variables': variables,
      'sentAt': DateTime.now(),
    });
  }

  @override
  Future<void> sendBulkEmail(
    List<String> recipients,
    String subject,
    String body,
  ) async {
    for (final recipient in recipients) {
      await sendEmail(recipient, subject, body);
    }
  }
}

/// メモリベースの Webhook サービス実装
class MemoryWebhookService implements WebhookService {
  final Map<String, List<Map<String, dynamic>>> _webhooks = {};

  @override
  Future<void> registerWebhook(String userId, String url) async {
    if (!_webhooks.containsKey(userId)) {
      _webhooks[userId] = [];
    }
    _webhooks[userId]!.add({
      'webhookId': 'webhook_${DateTime.now().millisecondsSinceEpoch}',
      'url': url,
      'registeredAt': DateTime.now(),
    });
  }

  @override
  Future<void> unregisterWebhook(String userId, String webhookId) async {
    if (_webhooks.containsKey(userId)) {
      _webhooks[userId]!.removeWhere((w) => w['webhookId'] == webhookId);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserWebhooks(String userId) async {
    return _webhooks[userId] ?? [];
  }

  @override
  Future<void> sendWebhookEvent(
    String userId,
    String eventType,
    Map<String, dynamic> payload,
  ) async {
    // メモリ実装では Webhook イベントを記録するだけ
  }
}
