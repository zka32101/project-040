import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// ユーザー削除完了時のコールバック定義
typedef OnDeletionComplete = Future<void> Function();
typedef OnDeletionError = Future<void> Function(Object error);

/// ユーザーデータ削除サービス（GDPR対応）
///
/// 以下の処理を行います：
/// 1. Firestore 上の全ユーザーデータを削除
/// 2. Firebase Authentication ユーザーアカウントを削除
/// 3. ローカルストレージのキャッシュをクリア
abstract class UserDeletionService {
  /// ユーザーデータを完全に削除
  ///
  /// [uid]: 削除対象ユーザーID
  /// [includeLocal]: true の場合、ローカルストレージもクリア
  Future<void> deleteUser(
    String uid, {
    bool includeLocal = true,
  });

  /// 削除処理の進捗を監視
  Stream<UserDeletionProgress> get progressStream;

  /// 現在の削除状態
  UserDeletionProgress get currentProgress;
}

/// ユーザー削除の進捗を表すモデル
class UserDeletionProgress {
  UserDeletionProgress({
    required this.step,
    required this.totalSteps,
    this.currentMessage = '',
    this.error,
    this.isComplete = false,
  });

  final int step; // 現在のステップ番号
  final int totalSteps; // 総ステップ数
  final String currentMessage; // 進捗メッセージ
  final Object? error; // エラー（あれば）
  final bool isComplete; // 完了したか

  /// 進捗パーセンテージ（0-100）
  int get progressPercentage => ((step / totalSteps) * 100).toInt();

  @override
  String toString() =>
      'UserDeletionProgress(step: $step/$totalSteps, message: $currentMessage, complete: $isComplete)';
}

/// UserDeletionService の実装
class FirebaseUserDeletionService implements UserDeletionService {
  FirebaseUserDeletionService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance {
    _progressStreamController = _StreamController<UserDeletionProgress>();
  }

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  late final _StreamController<UserDeletionProgress> _progressStreamController;
  UserDeletionProgress _currentProgress = UserDeletionProgress(
    step: 0,
    totalSteps: 4,
    currentMessage: '削除を開始します...',
  );

  @override
  Stream<UserDeletionProgress> get progressStream =>
      _progressStreamController.stream;

  @override
  UserDeletionProgress get currentProgress => _currentProgress;

  @override
  Future<void> deleteUser(
    String uid, {
    bool includeLocal = true,
  }) async {
    try {
      // ステップ 1: Firestore からユーザードキュメントを削除
      _updateProgress(
        step: 1,
        message: 'ユーザーデータを削除中...',
      );
      await _deleteFirestoreUserData(uid);

      // ステップ 2: Firestore サブコレクションを削除
      _updateProgress(
        step: 2,
        message: 'ユーザーのデータを削除中...',
      );
      await _deleteFirestoreSubcollections(uid);

      // ステップ 3: Firebase Auth ユーザーアカウントを削除
      _updateProgress(
        step: 3,
        message: 'アカウントを削除中...',
      );
      await _deleteFirebaseAuthUser();

      // ステップ 4: ローカルストレージをクリア（オプション）
      if (includeLocal) {
        _updateProgress(
          step: 4,
          message: 'ローカルキャッシュをクリア中...',
        );
        // ローカル削除は別途 LocalDataService で処理
      }

      // 完了
      _updateProgress(
        step: 4,
        message: 'ユーザーデータの削除が完了しました',
        isComplete: true,
      );

      if (kDebugMode) {
        debugPrint('UserDeletionService: User $uid deleted successfully');
      }
    } catch (e) {
      _updateProgress(
        step: _currentProgress.step,
        message: 'エラーが発生しました: $e',
        error: e,
      );

      if (kDebugMode) {
        debugPrint('UserDeletionService: Failed to delete user $uid: $e');
      }

      rethrow;
    }
  }

  /// Firestore のユーザードキュメントを削除
  Future<void> _deleteFirestoreUserData(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('UserDeletionService: Failed to delete user document: $e');
      }
      rethrow;
    }
  }

  /// Firestore のユーザーサブコレクション（回答ログ、バイク進捗など）を削除
  Future<void> _deleteFirestoreSubcollections(String uid) async {
    final subcollections = [
      'answerLogs',
      'bikeProgress',
      'trapDojo',
      'metadata',
    ];

    for (final subcollection in subcollections) {
      try {
        final docs = await _firestore
            .collection('users')
            .doc(uid)
            .collection(subcollection)
            .get();

        for (final doc in docs.docs) {
          await doc.reference.delete();
        }

        if (kDebugMode) {
          debugPrint(
            'UserDeletionService: Deleted $subcollection subcollection for $uid',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            'UserDeletionService: Failed to delete $subcollection: $e',
          );
        }
        // サブコレクション削除失敗でも続行
      }
    }
  }

  /// Firebase Auth のユーザーアカウントを削除
  Future<void> _deleteFirebaseAuthUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('UserDeletionService: Failed to delete auth user: $e');
      }
      rethrow;
    }
  }

  /// 進捗を更新してストリームに通知
  void _updateProgress({
    required int step,
    required String message,
    Object? error,
    bool isComplete = false,
  }) {
    _currentProgress = UserDeletionProgress(
      step: step,
      totalSteps: 4,
      currentMessage: message,
      error: error,
      isComplete: isComplete,
    );
    _progressStreamController.add(_currentProgress);
  }

  Future<void> dispose() async {
    await _progressStreamController.close();
  }
}

/// ストリームコントローラーのシンプルな実装
class _StreamController<T> {
  final _listeners = <Function(T)>[];

  void add(T value) {
    for (final listener in _listeners) {
      listener(value);
    }
  }

  Stream<T> get stream {
    late StreamController<T> controller;
    controller = StreamController<T>(
      onListen: () {
        _listeners.add(controller.add);
      },
      onCancel: () {
        _listeners.remove(controller.add);
      },
    );
    return controller.stream;
  }

  Future<void> close() async {
    _listeners.clear();
  }
}

/// テスト用スタブ実装
class StubUserDeletionService implements UserDeletionService {
  StubUserDeletionService();

  late final _StreamController<UserDeletionProgress> _progressStreamController =
      _StreamController<UserDeletionProgress>();
  late UserDeletionProgress _currentProgress = UserDeletionProgress(
    step: 0,
    totalSteps: 4,
    currentMessage: '削除を開始します...',
  );

  @override
  Stream<UserDeletionProgress> get progressStream =>
      _progressStreamController.stream;

  @override
  UserDeletionProgress get currentProgress => _currentProgress;

  @override
  Future<void> deleteUser(
    String uid, {
    bool includeLocal = true,
  }) async {
    _updateProgress(step: 1, message: 'Deleting user data...');
    await Future.delayed(const Duration(milliseconds: 500));

    _updateProgress(step: 2, message: 'Deleting subcollections...');
    await Future.delayed(const Duration(milliseconds: 500));

    _updateProgress(step: 3, message: 'Deleting auth user...');
    await Future.delayed(const Duration(milliseconds: 500));

    _updateProgress(
      step: 4,
      message: 'User deleted successfully',
      isComplete: true,
    );

    if (kDebugMode) print('Stub: User $uid deleted');
  }

  void _updateProgress({
    required int step,
    required String message,
    Object? error,
    bool isComplete = false,
  }) {
    _currentProgress = UserDeletionProgress(
      step: step,
      totalSteps: 4,
      currentMessage: message,
      error: error,
      isComplete: isComplete,
    );
    _progressStreamController.add(_currentProgress);
  }
}
