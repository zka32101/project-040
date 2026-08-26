import 'package:flutter/foundation.dart';

import '../models/bike_unlock_progress.dart';
import '../models/pass_prediction_score.dart';
import '../models/trap_dojo_session.dart';
import '../models/user.dart';
import '../models/user_answer_log.dart';
import 'firestore_sync_service.dart';
import 'local_data_service.dart';

/// ハイブリッドデータサービス：Firestore 優先でデータを読み込む。
/// Firestore が利用不可またはエラー時はローカルにフォールバック。
/// 書き込みは LocalDataService で行う（Firestore 同期は別途）。
class HybridDataService extends DataService {
  HybridDataService({
    required LocalDataService localDataService,
    required FirestoreSyncService firestoreSyncService,
  })  : _localDataService = localDataService,
        _firestoreSyncService = firestoreSyncService;

  final LocalDataService _localDataService;
  final FirestoreSyncService _firestoreSyncService;

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
    return _readFromFirestoreOrLocal(
      () => _firestoreSyncService.loadUser(uid),
      () => _localDataService.loadUser(uid),
      'user',
    );
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
