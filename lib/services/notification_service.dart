import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 通知機能の管理サービス。
/// OS許可の取得・状態管理・テスト通知送信。
abstract class NotificationService {
  /// 通知が有効（OSレベルでユーザーが許可済み）か確認
  Future<bool> isNotificationEnabled();

  /// OS許可をリクエスト
  /// true = ユーザーが許可した、false = 拒否・キャンセル
  Future<bool> requestNotificationPermission();

  /// テスト通知を送信
  Future<void> sendTestNotification();

  /// 通知を無効化（ユーザーが後から設定を変更した場合）
  Future<void> disableNotifications();
}

/// flutter_local_notifications を使った実装
class LocalNotificationService implements NotificationService {
  LocalNotificationService() {
    _initializePlugin();
  }

  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  void _initializePlugin() {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    // Android 初期化
    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 初期化
    const iosInitSettings = DarwinInitializationSettings(
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    _notificationsPlugin.initialize(initSettings);
  }

  @override
  Future<bool> isNotificationEnabled() async {
    try {
      // Android
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final areNotificationsEnabled = await androidPlugin.areNotificationsEnabled();
        if (areNotificationsEnabled != null) {
          return areNotificationsEnabled;
        }
      }

      // iOS
      final iosPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          DarwinFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final notificationsPermission = await iosPlugin.requestPermissions(
          alert: false,
          badge: false,
          sound: false,
        );
        return notificationsPermission ?? false;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to check notification status: $e');
      }
      return false;
    }
  }

  @override
  Future<bool> requestNotificationPermission() async {
    try {
      // Android - API 33(Android 13)以上でリクエスト可能
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }

      // iOS
      final iosPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          DarwinFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        return await iosPlugin.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to request notification permission: $e');
      }
      return false;
    }
  }

  @override
  Future<void> sendTestNotification() async {
    try {
      await _notificationsPlugin.show(
        0,
        '原付・バイク免許コレ！',
        '毎日のノルマに挑戦して、合格に近づこう！',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'bike_license_channel',
            '免許学習通知',
            channelDescription: '免許試験の学習進捗に関する通知',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send test notification: $e');
      }
    }
  }

  @override
  Future<void> disableNotifications() async {
    // 現在の実装では、OS設定をアプリから直接無効化はできない。
    // ユーザーが設定 > アプリ > 通知 で自分で無効化する必要がある。
    // ここはアプリレベルの無効化フラグがあれば設定するような処理
    if (kDebugMode) {
      print('User disabled notifications via app settings');
    }
  }
}

/// テスト用スタブ実装
class StubNotificationService implements NotificationService {
  bool _enabled = false;

  @override
  Future<bool> isNotificationEnabled() async => _enabled;

  @override
  Future<bool> requestNotificationPermission() async {
    _enabled = true;
    return true;
  }

  @override
  Future<void> sendTestNotification() async {
    if (kDebugMode) {
      print('Test notification sent');
    }
  }

  @override
  Future<void> disableNotifications() async {
    _enabled = false;
  }
}
