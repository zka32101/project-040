/// Phase 23: Firebase Cloud Messaging (FCM) 通知サービス
/// リアルタイムジョブ通知とプッシュ通知管理

import 'package:flutter/foundation.dart';
import '../models/async_job_model.dart';

/// FCM 通知タイプ
enum NotificationType {
  jobQueued,
  jobStarted,
  jobProgress,
  jobCompleted,
  jobFailed,
  jobCancelled,
  jobRetrying,
}

/// FCM ペイロード
class FCMPayload {
  /// 通知タイプ
  final NotificationType type;

  /// ジョブ ID
  final String jobId;

  /// ジョブタイプ
  final AsyncJobType jobType;

  /// タイトル
  final String title;

  /// メッセージ本文
  final String body;

  /// 追加データ
  final Map<String, String> data;

  /// タイムスタンプ
  final DateTime timestamp;

  /// 優先度 (high/normal)
  final String priority;

  /// TTL (秒)
  final int ttl;

  const FCMPayload({
    required this.type,
    required this.jobId,
    required this.jobType,
    required this.title,
    required this.body,
    this.data = const {},
    DateTime? timestamp,
    this.priority = 'high',
    this.ttl = 3600,
  }) : timestamp = timestamp ?? const Priority().now();

  static DateTime _now() => DateTime.now();

  /// JSON に変換
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'jobId': jobId,
      'jobType': jobType.toString().split('.').last,
      'title': title,
      'body': body,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'priority': priority,
      'ttl': ttl,
    };
  }

  /// JSON から作成
  factory FCMPayload.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final notificationType = NotificationType.values.firstWhere(
      (e) => e.toString().split('.').last == typeStr,
      orElse: () => NotificationType.jobProgress,
    );

    final jobTypeStr = json['jobType'] as String;
    final asyncJobType = AsyncJobType.values.firstWhere(
      (e) => e.toString().split('.').last == jobTypeStr,
      orElse: () => AsyncJobType.reportGeneration,
    );

    return FCMPayload(
      type: notificationType,
      jobId: json['jobId'] as String,
      jobType: asyncJobType,
      title: json['title'] as String,
      body: json['body'] as String,
      data: Map<String, String>.from(json['data'] as Map? ?? {}),
      timestamp: DateTime.parse(json['timestamp'] as String),
      priority: json['priority'] as String? ?? 'high',
      ttl: json['ttl'] as int? ?? 3600,
    );
  }
}

/// ローカル通知モデル
class LocalNotification {
  /// 通知 ID
  final int id;

  /// タイトル
  final String title;

  /// メッセージ本文
  final String body;

  /// ジョブ ID
  final String? jobId;

  /// タイムスタンプ
  final DateTime timestamp;

  /// 既読フラグ
  final bool isRead;

  /// アクション可能フラグ
  final bool isActionable;

  const LocalNotification({
    required this.id,
    required this.title,
    required this.body,
    this.jobId,
    DateTime? timestamp,
    this.isRead = false,
    this.isActionable = true,
  }) : timestamp = timestamp ?? const Priority().now();

  static DateTime _now() => DateTime.now();

  /// コピー
  LocalNotification copyWith({
    int? id,
    String? title,
    String? body,
    String? jobId,
    DateTime? timestamp,
    bool? isRead,
    bool? isActionable,
  }) {
    return LocalNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      jobId: jobId ?? this.jobId,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isActionable: isActionable ?? this.isActionable,
    );
  }

  /// JSON に変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'jobId': jobId,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'isActionable': isActionable,
    };
  }

  /// JSON から作成
  factory LocalNotification.fromJson(Map<String, dynamic> json) {
    return LocalNotification(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      jobId: json['jobId'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      isActionable: json['isActionable'] as bool? ?? true,
    );
  }
}

/// FCM 通知サービス抽象インターフェース
abstract class FCMNotificationService {
  /// FCM トークン取得
  Future<String?> getToken();

  /// FCM トークンリセット
  Future<void> resetToken();

  /// デバイストークン登録
  Future<void> registerDeviceToken(String userId, String token);

  /// 通知購読
  Stream<FCMPayload> subscribeToNotifications();

  /// 通知を処理
  Future<void> handleNotification(Map<String, dynamic> message);

  /// バックグラウンド通知を処理
  Future<void> handleBackgroundNotification(Map<String, dynamic> message);
}

/// ローカル通知サービス抽象インターフェース
abstract class LocalNotificationService {
  /// 通知を表示
  Future<void> showNotification(LocalNotification notification);

  /// 通知をキャンセル
  Future<void> cancelNotification(int id);

  /// すべての通知をキャンセル
  Future<void> cancelAllNotifications();

  /// 通知一覧取得
  Future<List<LocalNotification>> getNotifications();

  /// 通知を既読
  Future<void> markAsRead(int id);

  /// すべてを既読
  Future<void> markAllAsRead();
}

/// スタブ FCM 通知サービス（テスト用）
class StubFCMNotificationService implements FCMNotificationService {
  /// トークン
  String? _token = 'stub_token_${DateTime.now().millisecondsSinceEpoch}';

  /// 登録済みデバイス
  final Map<String, String> _registeredDevices = {};

  /// 通知ストリーム
  final List<FCMPayload> _notifications = [];

  @override
  Future<String?> getToken() async {
    return _token;
  }

  @override
  Future<void> resetToken() async {
    _token = null;
  }

  @override
  Future<void> registerDeviceToken(String userId, String token) async {
    _registeredDevices[userId] = token;
  }

  @override
  Stream<FCMPayload> subscribeToNotifications() async* {
    for (final notification in _notifications) {
      yield notification;
    }
  }

  @override
  Future<void> handleNotification(Map<String, dynamic> message) async {
    // スタブ実装
  }

  @override
  Future<void> handleBackgroundNotification(Map<String, dynamic> message) async {
    // スタブ実装
  }

  /// テスト用通知を送信
  void sendTestNotification(FCMPayload payload) {
    _notifications.add(payload);
  }
}

/// スタブ ローカル通知サービス（テスト用）
class StubLocalNotificationService implements LocalNotificationService {
  /// 通知リスト
  final List<LocalNotification> _notifications = [];

  @override
  Future<void> showNotification(LocalNotification notification) async {
    _notifications.add(notification);
  }

  @override
  Future<void> cancelNotification(int id) async {
    _notifications.removeWhere((n) => n.id == id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    _notifications.clear();
  }

  @override
  Future<List<LocalNotification>> getNotifications() async {
    return List.from(_notifications);
  }

  @override
  Future<void> markAsRead(int id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }
}

// ヘルパークラス
class Priority {
  const Priority();
  DateTime get now => DateTime.now();
}
