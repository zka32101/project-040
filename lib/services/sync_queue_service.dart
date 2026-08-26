import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 同期待ちの操作を表すモデル
class QueuedOperation {
  final String id;
  final String type; // 'saveUser', 'appendAnswerLog', 'saveBikeProgress' など
  final Map<String, dynamic> data;
  final DateTime queuedAt;
  final DateTime lastAttemptAt;
  final int retryCount;

  QueuedOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.queuedAt,
    required this.lastAttemptAt,
    required this.retryCount,
  });

  /// JSON シリアライズ用
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'data': data,
    'queuedAt': queuedAt.toIso8601String(),
    'lastAttemptAt': lastAttemptAt.toIso8601String(),
    'retryCount': retryCount,
  };

  /// JSON デシリアライズ用
  factory QueuedOperation.fromJson(Map<String, dynamic> json) => QueuedOperation(
    id: json['id'] as String,
    type: json['type'] as String,
    data: Map<String, dynamic>.from(json['data'] as Map),
    queuedAt: DateTime.parse(json['queuedAt'] as String),
    lastAttemptAt: DateTime.parse(json['lastAttemptAt'] as String),
    retryCount: json['retryCount'] as int,
  );

  /// リトライ情報を更新したコピーを作成
  QueuedOperation copyWithRetry() => QueuedOperation(
    id: id,
    type: type,
    data: data,
    queuedAt: queuedAt,
    lastAttemptAt: DateTime.now(),
    retryCount: retryCount + 1,
  );
}

/// 同期ステータス
enum SyncStatus {
  connected, // ネットワーク接続あり＆キューが空
  syncing,   // 同期処理中
  offline,   // ネットワーク接続なし
  failed,    // 同期失敗
}

/// 同期キューサービス：オフライン対応の書き込み操作を管理
///
/// - 書き込み操作をローカルキューに追加
/// - ネットワーク接続時に自動的にキュー内の操作を実行
/// - 失敗時は自動リトライ（指数バックオフ）
/// - SharedPreferences でキューを永続化
abstract class SyncQueueService {
  /// 操作をキューに追加
  Future<void> enqueue(QueuedOperation operation);

  /// ペンディング中の操作数を取得
  int getPendingCount();

  /// 同期ステータスを監視するストリーム
  Stream<SyncStatus> statusStream();

  /// 現在の同期ステータス
  SyncStatus getStatus();

  /// キュー内のすべての操作を取得
  List<QueuedOperation> getPendingOperations();

  /// キューをクリア
  Future<void> clear();
}

/// SyncQueueService の実装
class LocalSyncQueueService implements SyncQueueService {
  LocalSyncQueueService({
    SharedPreferences? prefs,
    Duration retryDelay = const Duration(seconds: 5),
  })  : _prefs = prefs,
        _retryDelay = retryDelay {
    _statusController = StreamController<SyncStatus>.broadcast();
  }

  final SharedPreferences? _prefs;
  final Duration _retryDelay;

  static const String _queueKey = 'sync_queue_operations';
  static const String _statusKey = 'sync_queue_status';
  static const int _maxRetries = 5;

  late final StreamController<SyncStatus> _statusController;
  final List<QueuedOperation> _queue = [];
  SyncStatus _currentStatus = SyncStatus.offline;

  /// 初期化：SharedPreferences からキューを復元
  Future<void> initialize() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_queueKey);

    if (queueJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(queueJson);
        _queue.addAll(decoded.map((item) => QueuedOperation.fromJson(item as Map<String, dynamic>)));
        if (kDebugMode) {
          debugPrint('SyncQueueService: Loaded ${_queue.length} pending operations from local storage');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('SyncQueueService: Failed to load queue from local storage: $e');
        }
      }
    }
  }

  @override
  Future<void> enqueue(QueuedOperation operation) async {
    _queue.add(operation);
    await _persistQueue();

    if (kDebugMode) {
      debugPrint('SyncQueueService: Queued operation ${operation.id} (${operation.type})');
    }
  }

  @override
  int getPendingCount() => _queue.length;

  @override
  Stream<SyncStatus> statusStream() => _statusController.stream;

  @override
  SyncStatus getStatus() => _currentStatus;

  @override
  List<QueuedOperation> getPendingOperations() => List.unmodifiable(_queue);

  @override
  Future<void> clear() async {
    _queue.clear();
    await _persistQueue();
    _updateStatus(SyncStatus.connected);
    if (kDebugMode) {
      debugPrint('SyncQueueService: Queue cleared');
    }
  }

  /// ネットワーク接続時に呼ばれる：キュー内の操作を処理
  Future<void> processQueue(
    Future<void> Function(QueuedOperation) processor,
  ) async {
    if (_queue.isEmpty) {
      _updateStatus(SyncStatus.connected);
      return;
    }

    _updateStatus(SyncStatus.syncing);

    final List<QueuedOperation> toRemove = [];

    for (final operation in _queue) {
      try {
        await processor(operation);
        toRemove.add(operation);
        if (kDebugMode) {
          debugPrint('SyncQueueService: Successfully processed ${operation.id}');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('SyncQueueService: Failed to process ${operation.id}: $e');
        }

        // リトライ回数チェック
        if (operation.retryCount >= _maxRetries) {
          if (kDebugMode) {
            debugPrint('SyncQueueService: Max retries reached for ${operation.id}, removing from queue');
          }
          toRemove.add(operation);
          _updateStatus(SyncStatus.failed);
        } else {
          // リトライ情報を更新（但しキューには戻さない）
          final retryOp = operation.copyWithRetry();
          final index = _queue.indexOf(operation);
          if (index >= 0) {
            _queue[index] = retryOp;
          }
        }
      }

      // バックオフ：次のリトライまで待機
      await Future.delayed(_retryDelay);
    }

    // 成功した操作をキューから削除
    _queue.removeWhere((op) => toRemove.contains(op));
    await _persistQueue();

    // ステータスを更新
    if (_queue.isEmpty) {
      _updateStatus(SyncStatus.connected);
    } else {
      _updateStatus(SyncStatus.failed);
    }
  }

  /// キューをローカルストレージに保存
  Future<void> _persistQueue() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final queueJson = jsonEncode(_queue.map((op) => op.toJson()).toList());
      await prefs.setString(_queueKey, queueJson);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SyncQueueService: Failed to persist queue: $e');
      }
    }
  }

  /// ステータスを更新してストリームに通知
  void _updateStatus(SyncStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);
      if (kDebugMode) {
        debugPrint('SyncQueueService: Status changed to ${status.name}');
      }
    }
  }

  /// クリーンアップ
  Future<void> dispose() async {
    await _statusController.close();
  }
}

/// テスト用スタブ実装
class StubSyncQueueService implements SyncQueueService {
  final List<QueuedOperation> _queue = [];
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();
  SyncStatus _currentStatus = SyncStatus.connected;

  @override
  Future<void> enqueue(QueuedOperation operation) async {
    _queue.add(operation);
    if (kDebugMode) print('Stub: Queued operation ${operation.id}');
  }

  @override
  int getPendingCount() => _queue.length;

  @override
  Stream<SyncStatus> statusStream() => _statusController.stream;

  @override
  SyncStatus getStatus() => _currentStatus;

  @override
  List<QueuedOperation> getPendingOperations() => List.unmodifiable(_queue);

  @override
  Future<void> clear() async {
    _queue.clear();
    _currentStatus = SyncStatus.connected;
    _statusController.add(_currentStatus);
    if (kDebugMode) print('Stub: Queue cleared');
  }
}
