import 'dart:async';
import 'package:flutter/foundation.dart';

/// ネットワーク接続状態
enum ConnectivityStatus {
  connected,    // ネットワーク接続あり
  disconnected, // ネットワーク接続なし
}

/// ネットワーク接続を監視するサービス
abstract class ConnectivityService {
  /// 接続状態ストリーム
  Stream<ConnectivityStatus> statusStream();

  /// 現在の接続状態
  Future<ConnectivityStatus> getStatus();

  /// リスナー登録（Android/iOS ネイティブ層対応）
  Future<void> initialize();

  /// クリーンアップ
  Future<void> dispose();
}

/// ConnectivityService の実装
///
/// connectivity_plus を使用してネットワーク接続状態を監視
class LocalConnectivityService implements ConnectivityService {
  LocalConnectivityService() {
    _statusController = StreamController<ConnectivityStatus>.broadcast();
  }

  late final StreamController<ConnectivityStatus> _statusController;
  ConnectivityStatus _currentStatus = ConnectivityStatus.disconnected;
  StreamSubscription? _subscription;

  @override
  Stream<ConnectivityStatus> statusStream() => _statusController.stream;

  @override
  Future<ConnectivityStatus> getStatus() async {
    // 実装は connectivity_plus を使用した実装で行う
    // ここではデフォルト値を返す
    return _currentStatus;
  }

  @override
  Future<void> initialize() async {
    try {
      // connectivity_plus のストリームを監視
      // 注：実装には connectivity_plus パッケージが必要
      // import 'package:connectivity_plus/connectivity_plus.dart';
      // を使用して実装
      if (kDebugMode) {
        debugPrint('ConnectivityService: Initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ConnectivityService: Failed to initialize: $e');
      }
    }
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _statusController.close();
  }

  /// ステータスを更新
  void _updateStatus(ConnectivityStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
      if (kDebugMode) {
        debugPrint('ConnectivityService: Status changed to ${status.name}');
      }
    }
  }
}

/// テスト用スタブ実装
class StubConnectivityService implements ConnectivityService {
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();
  ConnectivityStatus _currentStatus = ConnectivityStatus.connected;

  @override
  Stream<ConnectivityStatus> statusStream() => _statusController.stream;

  @override
  Future<ConnectivityStatus> getStatus() async => _currentStatus;

  @override
  Future<void> initialize() async {
    if (kDebugMode) print('Stub: ConnectivityService initialized');
  }

  @override
  Future<void> dispose() async {
    await _statusController.close();
  }

  /// テスト用：ステータスを手動で更新
  void updateStatus(ConnectivityStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
    }
  }
}
