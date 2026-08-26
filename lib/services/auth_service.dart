import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Firebase Authentication を通じたユーザー認証サービス。
/// 匿名ログイン（メールアドレス・パスワード不要）で、ユーザーIDを取得。
abstract class AuthService {
  /// 現在のユーザー UID を取得
  /// null = 未ログイン
  String? get currentUid;

  /// 匿名ログイン（初回起動時に自動実行）
  /// すでにログイン済みの場合は何もしない。
  Future<String> signInAnonymously();

  /// ログアウト（テスト・デバッグ用）
  Future<void> signOut();

  /// 現在のAuth状態を Stream で監視
  Stream<User?> get authStateChanges;

  /// 認証が準備完了したか
  Future<void> waitForAuthReady();
}

/// Firebase Authentication を使った実装
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  bool _initialized = false;

  /// 初期化：初回起動時に匿名ログインを実行
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // すでにログイン済みかを確認
      if (_auth.currentUser == null) {
        await signInAnonymously();
      }
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize auth: $e');
      }
      rethrow;
    }
  }

  @override
  String? get currentUid => _auth.currentUser?.uid;

  @override
  Future<String> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw Exception('Failed to get UID after anonymous sign-in');
      }
      if (kDebugMode) {
        debugPrint('Signed in anonymously with UID: $uid');
      }
      return uid;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Anonymous sign-in failed: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (kDebugMode) {
        debugPrint('Signed out');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sign-out failed: $e');
      }
      rethrow;
    }
  }

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<void> waitForAuthReady() async {
    await initialize();
  }
}

/// テスト用スタブ実装
class StubAuthService implements AuthService {
  String? _currentUid;

  StubAuthService({
    String? initialUid,
  }) : _currentUid = initialUid ?? 'stub-user-123';

  @override
  String? get currentUid => _currentUid;

  @override
  Future<String> signInAnonymously() async {
    _currentUid ??= 'stub-user-${DateTime.now().millisecondsSinceEpoch}';
    if (kDebugMode) {
      debugPrint('Stub: Signed in anonymously with UID: $_currentUid');
    }
    return _currentUid!;
  }

  @override
  Future<void> signOut() async {
    _currentUid = null;
    if (kDebugMode) {
      debugPrint('Stub: Signed out');
    }
  }

  @override
  Stream<User?> get authStateChanges => Stream.value(null);

  @override
  Future<void> waitForAuthReady() async {
    await signInAnonymously();
  }
}
