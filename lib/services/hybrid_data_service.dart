import 'package:flutter/foundation.dart';

import '../models/bike_unlock_progress.dart';
import '../models/pass_prediction_score.dart';
import '../models/trap_dojo_session.dart';
import '../models/user.dart';
import '../models/user_answer_log.dart';
import 'firestore_sync_service.dart';
import 'local_data_service.dart';
import 'conflict_resolution_service.dart';

/// ハイブリッドデータサービス：Firestore 優先でデータを読み込む。
/// Firestore が利用不可またはエラー時はローカルにフォールバック。
/// コンフリクト検出時は Last-Write-Wins 戦略を適用。
/// 書き込みは LocalDataService で行う（Firestore 同期は別途）。
class HybridDataService extends DataService {
  HybridDataService({
    required LocalDataService localDataService,
    required FirestoreSyncService firestoreSyncService,
    ConflictResolutionService? conflictResolutionService,
  })  : _localDataService = localDataService,
        _firestoreSyncService = firestoreSyncService,
        _conflictResolutionService =
            conflictResolutionService ?? DefaultConflictResolutionService();

  final LocalDataService _localDataService;
  final FirestoreSyncService _firestoreSyncService;
  final ConflictResolutionService _conflictResolutionService;

  /// Firestore から読み込む（エラー時はローカルにフォールバック）
  Future<T> _readFromFirestoreOrLocal<T>(
    Future<T?> Function() firestoreRead,
    Future<T> Function() localRead,
    String operationName,
  ) async {
    try {
      final result = await firestoreRead();
      if (result != null) {
        if (kDebugMode) {
          debugPrint('Loaded $operationName from Firestore');
        }
        return result;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load $operationName from Firestore: $e, falling back to local');
      }
    }

    // ローカルにフォールバック
    return localRead();
  }

  // ───────────────────────────────────────────────────────────────────────
  // ユーザー
  // ───────────────────────────────────────────────────────────────────────

  @override
  Future<AppUser> loadUser(String uid) async {
    AppUser? remoteUser;
    AppUser? localUser;

    // Firestore からの読み込みを試みる
    try {
      remoteUser = await _firestoreSyncService.loadUser(uid);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load user from Firestore: $e');
      }
    }

    // ローカルから読み込み
    try {
      localUser = await _localDataService.loadUser(uid);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load user from local: $e');
      }
    }

    // 両方のデータがある場合はコンフリクト解決
    if (remoteUser != null && localUser != null) {
      final winner = _conflictResolutionService.resolveConflict(
        local: localUser,
        remote: remoteUser,
        localTimestamp: localUser.updatedAt,
        remoteTimestamp: remoteUser.updatedAt,
      );

      if (winner == 'remote') {
        if (kDebugMode) {
          debugPrint('Loaded user from Firestore (remote is newer)');
        }
        return remoteUser;
      } else {
        if (kDebugMode) {
          debugPrint('Loaded user from local (local is newer or equal)');
        }
        return localUser;
      }
    }

    // どちらか一方のみ存在
    if (remoteUser != null) {
      if (kDebugMode) {
        debugPrint('Loaded user from Firestore');
      }
      return remoteUser;
    }

    if (localUser != null) {
      if (kDebugMode) {
        debugPrint('Loaded user from local');
      }
      return localUser;
    }

    // どちらも存在しない場合は新規作成
    final newUser = AppUser(uid: uid);
    await _localDataService.saveUser(newUser);
    return newUser;
  }

  @override
  Future<void> saveUser(AppUser user) =>
      _localDataService.saveUser(user);

  // ───────────────────────────────────────────────────────────────────────
  // 回答ログ
  // ───────────────────────────────────────────────────────────────────────

  @override
  Future<void> appendAnswerLog(UserAnswerLog log) =>
      _localDataService.appendAnswerLog(log);

  @override
  Future<List<UserAnswerLog>> loadAnswerLogs(
    String uid, {
    DateTime? since,
  }) async {
    return _readFromFirestoreOrLocal(
      () async => (await _firestoreSyncService.loadAnswerLogs(uid)).isEmpty
          ? null
          : await _firestoreSyncService.loadAnswerLogs(uid),
      () => _localDataService.loadAnswerLogs(uid, since: since),
      'answer logs',
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // バイク解放進捗
  // ───────────────────────────────────────────────────────────────────────

  @override
  Future<void> saveBikeUnlockProgress(BikeUnlockProgress progress) =>
      _localDataService.saveBikeUnlockProgress(progress);

  @override
  Future<List<BikeUnlockProgress>> loadBikeUnlockProgress(String uid) async {
    return _readFromFirestoreOrLocal(
      () async =>
          (await _firestoreSyncService.loadBikeProgress(uid)).isEmpty
              ? null
              : await _firestoreSyncService.loadBikeProgress(uid),
      () => _localDataService.loadBikeUnlockProgress(uid),
      'bike progress',
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // ひっかけ道場
  // ───────────────────────────────────────────────────────────────────────

  @override
  Future<void> saveTrapDojoSession(TrapDojoSession session) =>
      _localDataService.saveTrapDojoSession(session);

  @override
  Future<List<TrapDojoSession>> loadTrapDojoSessions(String uid) async {
    return _readFromFirestoreOrLocal(
      () async =>
          (await _firestoreSyncService.loadTrapDojoSessions(uid)).isEmpty
              ? null
              : await _firestoreSyncService.loadTrapDojoSessions(uid),
      () => _localDataService.loadTrapDojoSessions(uid),
      'trap dojo sessions',
    );
  }

  // ───────────────────────────────────────────────────────────────────────
  // 合格率予測スコア
  // ───────────────────────────────────────────────────────────────────────

  @override
  Future<void> savePredictionScore(PassPredictionScore score) =>
      _localDataService.savePredictionScore(score);

  @override
  Future<PassPredictionScore?> loadPredictionScore(String uid) async {
    try {
      // Firestore から読み込みを試みる
      final firestoreScore =
          await _firestoreSyncService.loadPredictionScore(uid);
      if (firestoreScore != null) {
        if (kDebugMode) {
          debugPrint('Loaded prediction score from Firestore');
        }
        return firestoreScore;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'Failed to load prediction score from Firestore: $e, falling back to local');
      }
    }

    // ローカルにフォールバック
    return _localDataService.loadPredictionScore(uid);
  }
}
