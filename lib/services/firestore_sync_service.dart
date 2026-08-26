import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../models/user_answer_log.dart';
import '../models/bike_unlock_progress.dart';
import '../models/trap_dojo_session.dart';
import '../models/pass_prediction_score.dart';

/// Firestore と同期するデータサービスの抽象インターフェース。
/// ユーザーデータ・回答ログ・進捗情報などをクラウドに保存・読み込み。
abstract class FirestoreSyncService {
  /// ユーザー情報をFirestoreに保存
  Future<void> saveUser(AppUser user);

  /// ユーザー情報をFirestoreから読み込み
  Future<AppUser?> loadUser(String uid);

  /// 回答ログをFirestoreに保存
  Future<void> saveAnswerLogs(String uid, List<UserAnswerLog> logs);

  /// 回答ログをFirestoreから読み込み
  Future<List<UserAnswerLog>> loadAnswerLogs(String uid);

  /// バイク解放進捗をFirestoreに保存
  Future<void> saveBikeProgress(String uid, List<BikeUnlockProgress> progress);

  /// バイク解放進捗をFirestoreから読み込み
  Future<List<BikeUnlockProgress>> loadBikeProgress(String uid);

  /// ひっかけ道場セッションをFirestoreに保存
  Future<void> saveTrapDojoSessions(String uid, List<TrapDojoSession> sessions);

  /// ひっかけ道場セッションをFirestoreから読み込み
  Future<List<TrapDojoSession>> loadTrapDojoSessions(String uid);

  /// 合格率予測スコアをFirestoreに保存
  Future<void> savePredictionScore(String uid, PassPredictionScore score);

  /// 合格率予測スコアをFirestoreから読み込み
  Future<PassPredictionScore?> loadPredictionScore(String uid);
}

/// Firestore を使った実装
class LocalFirestoreSyncService implements FirestoreSyncService {
  LocalFirestoreSyncService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ───────────────────────────────────────────────────────────────────────
  // ユーザーデータ
  // ───────────────────────────────────────────────────────────────────────

  @override
  Future<void> saveUser(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(
            {
              'uid': user.uid,
              'licenseCategories': user.licenseCategories,
              'trainingStage': user.trainingStage,
              'examDate': user.examDate?.toIso8601String(),
              'purchaseStatus': user.purchaseStatus.name,
              'createdAt': user.createdAt.toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
            SetOptions(merge: true),
          );
      if (kDebugMode) {
        debugPrint('Saved user to Firestore: ${user.uid}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save user to Firestore: $e');
      }
      rethrow;
    }
  }

  @override
  Future<AppUser?> loadUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      return AppUser(
        uid: data['uid'] as String,
        licenseCategories: List<String>.from(data['licenseCategories'] as List? ?? []),
        trainingStage: data['trainingStage'] as String?,
        examDate: data['examDate'] != null ? DateTime.parse(data['examDate'] as String) : null,
        purchaseStatus: PurchaseStatus.values.firstWhere(
          (e) => e.name == data['purchaseStatus'],
          orElse: () => PurchaseStatus.free,
        ),
        createdAt: data['createdAt'] != null
            ? DateTime.parse(data['createdAt'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load user from Firestore: $e');
      }
      return null;
    }
  }

  // ───────────────────────────────────────────────────────────────────────
  // 回答ログ
  // ───────────────────────────────────────────────────────────────────────

  @override
  Future<void> saveAnswerLogs(String uid, List<UserAnswerLog> logs) async {
    try {
      final batch = _firestore.batch();

      // 既存のログを削除（新しいリストで置き換え）
      final existingDocs = await _firestore
          .collection('users')
          .doc(uid)
          .collection('answerLogs')
          .get();

      for (final doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }

      // 新しいログを追加
      for (final log in logs) {
        final docRef =
            _firestore.collection('users').doc(uid).collection('answerLogs').doc();
        batch.set(docRef, {
          'questionId': log.questionId,
          'licenseCategory': log.licenseCategory,
          'userAnswer': log.userAnswer,
          'correctAnswer': log.correctAnswer,
          'isCorrect': log.isCorrect,
          'answeredAt': log.answeredAt.toIso8601String(),
          'stage': log.stage,
        });
      }

      await batch.commit();
      if (kDebugMode) {
        debugPrint('Saved ${logs.length} answer logs to Firestore for $uid');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save answer logs to Firestore: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<UserAnswerLog>> loadAnswerLogs(String uid) async {
    try {
      final docs =
          await _firestore.collection('users').doc(uid).collection('answerLogs').get();

      return docs.docs.map((doc) {
        final data = doc.data();
        return UserAnswerLog(
          questionId: data['questionId'] as String,
          licenseCategory: data['licenseCategory'] as String,
          userAnswer: data['userAnswer'] as String,
          correctAnswer: data['correctAnswer'] as String,
          isCorrect: data['isCorrect'] as bool,
          answeredAt: DateTime.parse(data['answeredAt'] as String),
          stage: data['stage'] as String?,
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load answer logs from Firestore: $e');
      }
      return [];
    }
  }

  // ───────────────────────────────────────────────────────────────────────
  // バイク解放進捗
  // ───────────────────────────────────────────────────────────────────────

  @override
  Future<void> saveBikeProgress(String uid, List<BikeUnlockProgress> progress) async {
    try {
      final batch = _firestore.batch();

      // 既存を削除
      final existingDocs = await _firestore
          .collection('users')
          .doc(uid)
          .collection('bikeProgress')
          .get();

      for (final doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }

      // 新しいデータを追加
      for (final bike in progress) {
        final docRef =
            _firestore.collection('users').doc(uid).collection('bikeProgress').doc();
        batch.set(docRef, {
          'bikeId': bike.bikeId,
          'correctCountRequired': bike.correctCountRequired,
          'currentCorrectCount': bike.currentCorrectCount,
          'isUnlocked': bike.isUnlocked,
          'unlockedAt': bike.unlockedAt?.toIso8601String(),
        });
      }

      await batch.commit();
      if (kDebugMode) {
        debugPrint('Saved ${progress.length} bike progress records to Firestore for $uid');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save bike progress to Firestore: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<BikeUnlockProgress>> loadBikeProgress(String uid) async {
    try {
      final docs = await _firestore
          .collection('users')
          .doc(uid)
          .collection('bikeProgress')
          .get();

      return docs.docs.map((doc) {
        final data = doc.data();
        return BikeUnlockProgress(
          bikeId: data['bikeId'] as String,
          correctCountRequired: data['correctCountRequired'] as int,
          currentCorrectCount: data['currentCorrectCount'] as int,
          isUnlocked: data['isUnlocked'] as bool,
          unlockedAt: data['unlockedAt'] != null
              ? DateTime.parse(data['unlockedAt'] as String)
              : null,
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load bike progress from Firestore: $e');
      }
      return [];
    }
  }

  // ───────────────────────────────────────────────────────────────────────
  // ひっかけ道場
  // ───────────────────────────────────────────────────────────────────────

  @override
  Future<void> saveTrapDojoSessions(String uid, List<TrapDojoSession> sessions) async {
    try {
      final batch = _firestore.batch();

      // 既存を削除
      final existingDocs = await _firestore
          .collection('users')
          .doc(uid)
          .collection('trapDojo')
          .get();

      for (final doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }

      // 新しいデータを追加
      for (final session in sessions) {
        final docRef = _firestore.collection('users').doc(uid).collection('trapDojo').doc();
        batch.set(docRef, {
          'questionId': session.questionId,
          'licenseCategory': session.licenseCategory,
          'isBoss': session.isBoss,
          'defeatedCount': session.defeatedCount,
          'createdAt': session.createdAt.toIso8601String(),
          'lastDefeatedAt': session.lastDefeatedAt?.toIso8601String(),
        });
      }

      await batch.commit();
      if (kDebugMode) {
        debugPrint('Saved ${sessions.length} trap dojo sessions to Firestore for $uid');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save trap dojo sessions to Firestore: $e');
      }
      rethrow;
    }
  }

  @override
  Future<List<TrapDojoSession>> loadTrapDojoSessions(String uid) async {
    try {
      final docs =
          await _firestore.collection('users').doc(uid).collection('trapDojo').get();

      return docs.docs.map((doc) {
        final data = doc.data();
        return TrapDojoSession(
          questionId: data['questionId'] as String,
          licenseCategory: data['licenseCategory'] as String,
          isBoss: data['isBoss'] as bool,
          defeatedCount: data['defeatedCount'] as int,
          createdAt: DateTime.parse(data['createdAt'] as String),
          lastDefeatedAt: data['lastDefeatedAt'] != null
              ? DateTime.parse(data['lastDefeatedAt'] as String)
              : null,
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load trap dojo sessions from Firestore: $e');
      }
      return [];
    }
  }

  // ───────────────────────────────────────────────────────────────────────
  // 合格率予測スコア
  // ───────────────────────────────────────────────────────────────────────

  @override
  Future<void> savePredictionScore(String uid, PassPredictionScore score) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('metadata')
          .doc('predictionScore')
          .set({
            'score': score.score,
            'calculatedAt': score.calculatedAt.toIso8601String(),
            'breakdown': score.breakdown,
          });
      if (kDebugMode) {
        debugPrint('Saved prediction score to Firestore for $uid');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save prediction score to Firestore: $e');
      }
      rethrow;
    }
  }

  @override
  Future<PassPredictionScore?> loadPredictionScore(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('metadata')
          .doc('predictionScore')
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      return PassPredictionScore(
        uid: uid,
        score: (data['score'] as num).toDouble(),
        calculatedAt: DateTime.parse(data['calculatedAt'] as String),
        breakdown: Map<String, double>.from(
          (data['breakdown'] as Map?)?.map(
                (k, v) => MapEntry(k as String, (v as num).toDouble()),
              ) ??
              {},
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load prediction score from Firestore: $e');
      }
      return null;
    }
  }
}

/// テスト用スタブ実装
class StubFirestoreSyncService implements FirestoreSyncService {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> saveUser(AppUser user) async {
    _storage['user_${user.uid}'] = user;
    if (kDebugMode) print('Stub: Saved user ${user.uid}');
  }

  @override
  Future<AppUser?> loadUser(String uid) async {
    return _storage['user_$uid'] as AppUser?;
  }

  @override
  Future<void> saveAnswerLogs(String uid, List<UserAnswerLog> logs) async {
    _storage['answerLogs_$uid'] = logs;
    if (kDebugMode) print('Stub: Saved ${logs.length} answer logs for $uid');
  }

  @override
  Future<List<UserAnswerLog>> loadAnswerLogs(String uid) async {
    return (_storage['answerLogs_$uid'] as List<UserAnswerLog>?) ?? [];
  }

  @override
  Future<void> saveBikeProgress(String uid, List<BikeUnlockProgress> progress) async {
    _storage['bikeProgress_$uid'] = progress;
    if (kDebugMode) print('Stub: Saved ${progress.length} bike progress for $uid');
  }

  @override
  Future<List<BikeUnlockProgress>> loadBikeProgress(String uid) async {
    return (_storage['bikeProgress_$uid'] as List<BikeUnlockProgress>?) ?? [];
  }

  @override
  Future<void> saveTrapDojoSessions(String uid, List<TrapDojoSession> sessions) async {
    _storage['trapDojo_$uid'] = sessions;
    if (kDebugMode) print('Stub: Saved ${sessions.length} trap dojo sessions for $uid');
  }

  @override
  Future<List<TrapDojoSession>> loadTrapDojoSessions(String uid) async {
    return (_storage['trapDojo_$uid'] as List<TrapDojoSession>?) ?? [];
  }

  @override
  Future<void> savePredictionScore(String uid, PassPredictionScore score) async {
    _storage['predictionScore_$uid'] = score;
    if (kDebugMode) print('Stub: Saved prediction score for $uid');
  }

  @override
  Future<PassPredictionScore?> loadPredictionScore(String uid) async {
    return _storage['predictionScore_$uid'] as PassPredictionScore?;
  }
}
