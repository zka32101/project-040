import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../models/user_answer_log.dart';
import '../models/bike_unlock_progress.dart';
import '../models/trap_dojo_session.dart';
import '../models/pass_prediction_score.dart';
import 'sync_queue_service.dart';
import 'connectivity_service.dart';
import 'firestore_sync_service.dart';
import 'local_data_service.dart';

/// ネットワークとキューを統合管理するサービス
///
/// - ネットワーク状態を監視
/// - ネットワーク接続時にキューを自動処理
/// - Firestore同期操作を実行
abstract class NetworkQueueProcessor {
  /// キュー処理を開始（ネットワーク監視を開始）
  Future<void> start();

  /// キュー処理を停止
  Future<void> stop();

  /// 現在のネットワーク状態
  ConnectivityStatus getConnectivityStatus();

  /// キュー内の保留中操作数
  int getPendingOperationCount();
}

/// NetworkQueueProcessor の実装
class DefaultNetworkQueueProcessor implements NetworkQueueProcessor {
  DefaultNetworkQueueProcessor({
    required SyncQueueService syncQueueService,
    required ConnectivityService connectivityService,
    required FirestoreSyncService firestoreSyncService,
    required LocalDataService localDataService,
  })  : _syncQueueService = syncQueueService,
        _connectivityService = connectivityService,
        _firestoreSyncService = firestoreSyncService,
        _localDataService = localDataService {
    _statusStreamController = StreamController<ConnectivityStatus>.broadcast();
  }

  final SyncQueueService _syncQueueService;
  final ConnectivityService _connectivityService;
  final FirestoreSyncService _firestoreSyncService;
  final LocalDataService _localDataService;

  late final StreamController<ConnectivityStatus> _statusStreamController;
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  ConnectivityStatus _currentStatus = ConnectivityStatus.disconnected;
  bool _isProcessing = false;

  @override
  Future<void> start() async {
    if (kDebugMode) {
      debugPrint('NetworkQueueProcessor: Starting network monitoring');
    }

    // ネットワーク状態の変化を監視
    _connectivitySubscription = _connectivityService.statusStream().listen(
      (status) async {
        _currentStatus = status;
        _statusStreamController.add(status);

        // ネットワーク接続時にキューを処理
        if (status == ConnectivityStatus.connected && !_isProcessing) {
          await _processQueue();
        }
      },
    );

    // 初期ネットワーク状態を取得
    _currentStatus = await _connectivityService.getStatus();

    // 初期状態で接続している場合は、キューを処理
    if (_currentStatus == ConnectivityStatus.connected) {
      await _processQueue();
    }
  }

  @override
  Future<void> stop() async {
    if (kDebugMode) {
      debugPrint('NetworkQueueProcessor: Stopping network monitoring');
    }
    await _connectivitySubscription?.cancel();
    await _statusStreamController.close();
  }

  @override
  ConnectivityStatus getConnectivityStatus() => _currentStatus;

  @override
  int getPendingOperationCount() => _syncQueueService.getPendingCount();

  /// キュー内の全操作を処理
  Future<void> _processQueue() async {
    if (_isProcessing) {
      if (kDebugMode) {
        debugPrint('NetworkQueueProcessor: Queue processing already in progress');
      }
      return;
    }

    _isProcessing = true;

    try {
      if (kDebugMode) {
        debugPrint(
          'NetworkQueueProcessor: Starting queue processing (${_syncQueueService.getPendingCount()} operations)',
        );
      }

      await _syncQueueService.processQueue(_processOperation);

      if (kDebugMode) {
        debugPrint('NetworkQueueProcessor: Queue processing completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('NetworkQueueProcessor: Queue processing failed: $e');
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// 個別操作を処理
  Future<void> _processOperation(QueuedOperation operation) async {
    try {
      switch (operation.type) {
        case 'saveUser':
          await _processSaveUser(operation);
          break;
        case 'saveAnswerLogs':
          await _processSaveAnswerLogs(operation);
          break;
        case 'saveBikeProgress':
          await _processSaveBikeProgress(operation);
          break;
        case 'saveTrapDojoSessions':
          await _processSaveTrapDojoSessions(operation);
          break;
        case 'savePredictionScore':
          await _processSavePredictionScore(operation);
          break;
        default:
          if (kDebugMode) {
            debugPrint('NetworkQueueProcessor: Unknown operation type: ${operation.type}');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('NetworkQueueProcessor: Failed to process operation: $e');
      }
      rethrow;
    }
  }

  Future<void> _processSaveUser(QueuedOperation operation) async {
    final user = AppUser.fromJson(Map<String, dynamic>.from(operation.data));
    await _firestoreSyncService.saveUser(user);
    if (kDebugMode) {
      debugPrint('NetworkQueueProcessor: Saved user ${user.uid}');
    }
  }

  Future<void> _processSaveAnswerLogs(QueuedOperation operation) async {
    final uid = operation.data['uid'] as String;
    final logsList = (operation.data['logs'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final logs = logsList.map((l) => UserAnswerLog.fromJson(l)).toList();
    await _firestoreSyncService.saveAnswerLogs(uid, logs);
    if (kDebugMode) {
      debugPrint('NetworkQueueProcessor: Saved ${logs.length} answer logs');
    }
  }

  Future<void> _processSaveBikeProgress(QueuedOperation operation) async {
    final uid = operation.data['uid'] as String;
    final progressList = (operation.data['progress'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final progress = progressList.map((p) => BikeUnlockProgress.fromJson(p)).toList();
    await _firestoreSyncService.saveBikeProgress(uid, progress);
    if (kDebugMode) {
      debugPrint('NetworkQueueProcessor: Saved ${progress.length} bike progress records');
    }
  }

  Future<void> _processSaveTrapDojoSessions(QueuedOperation operation) async {
    final uid = operation.data['uid'] as String;
    final sessionsList = (operation.data['sessions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final sessions = sessionsList.map((s) => TrapDojoSession.fromJson(s)).toList();
    await _firestoreSyncService.saveTrapDojoSessions(uid, sessions);
    if (kDebugMode) {
      debugPrint('NetworkQueueProcessor: Saved ${sessions.length} trap dojo sessions');
    }
  }

  Future<void> _processSavePredictionScore(QueuedOperation operation) async {
    final uid = operation.data['uid'] as String;
    final score = PassPredictionScore(
      uid: uid,
      score: (operation.data['score'] as num).toDouble(),
      calculatedAt: DateTime.parse(operation.data['calculatedAt'] as String),
      breakdown: Map<String, double>.from(
        (operation.data['breakdown'] as Map?)?.map(
              (k, v) => MapEntry(k as String, (v as num).toDouble()),
            ) ??
            {},
      ),
    );
    await _firestoreSyncService.savePredictionScore(uid, score);
    if (kDebugMode) {
      debugPrint('NetworkQueueProcessor: Saved prediction score for $uid');
    }
  }
}

/// テスト用スタブ実装
class StubNetworkQueueProcessor implements NetworkQueueProcessor {
  StubNetworkQueueProcessor({
    required this.syncQueueService,
    required this.connectivityService,
  });

  final SyncQueueService syncQueueService;
  final ConnectivityService connectivityService;

  @override
  Future<void> start() async {
    if (kDebugMode) print('Stub: NetworkQueueProcessor started');
  }

  @override
  Future<void> stop() async {
    if (kDebugMode) print('Stub: NetworkQueueProcessor stopped');
  }

  @override
  ConnectivityStatus getConnectivityStatus() => ConnectivityStatus.connected;

  @override
  int getPendingOperationCount() => syncQueueService.getPendingCount();
}
