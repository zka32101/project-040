/// Phase 29: セキュリティ強化サービス
/// レート制限、トークンブラックリスト、CSRF保護

import 'dart:async';
import 'dart:collection';
import 'package:crypto/crypto.dart';

// ==================== レート制限 ====================

/// レート制限戦略
enum RateLimitStrategy {
  fixedWindow,    // 固定ウィンドウ
  slidingWindow,  // スライディングウィンドウ
  tokenBucket,    // トークンバケット
}

/// レート制限ルール
class RateLimitRule {
  final String identifier; // ユーザーID, IP等
  final int maxRequests;   // 最大リクエスト数
  final Duration window;   // ウィンドウ期間
  final RateLimitStrategy strategy;

  const RateLimitRule({
    required this.identifier,
    required this.maxRequests,
    required this.window,
    this.strategy = RateLimitStrategy.slidingWindow,
  });
}

/// レート制限チェック結果
class RateLimitResult {
  final bool allowed;
  final int remainingRequests;
  final DateTime resetTime;
  final String? message;

  const RateLimitResult({
    required this.allowed,
    required this.remainingRequests,
    required this.resetTime,
    this.message,
  });
}

/// レート制限サービス
abstract class RateLimiter {
  Future<RateLimitResult> checkLimit(RateLimitRule rule);
  Future<void> reset(String identifier);
  Future<void> clear();
}

/// メモリベースのレート制限実装
class MemoryRateLimiter implements RateLimiter {
  final Map<String, Queue<DateTime>> _requests = {};
  final Map<String, Timer> _resetTimers = {};

  @override
  Future<RateLimitResult> checkLimit(RateLimitRule rule) async {
    final now = DateTime.now();
    final windowStart = now.subtract(rule.window);

    // リクエスト履歴を初期化
    if (!_requests.containsKey(rule.identifier)) {
      _requests[rule.identifier] = Queue();
    }

    // ウィンドウ外のリクエストを削除
    final queue = _requests[rule.identifier]!;
    queue.removeWhere((time) => time.isBefore(windowStart));

    // リクエスト数をチェック
    final allowed = queue.length < rule.maxRequests;

    if (allowed) {
      queue.addLast(now);
    }

    final resetTime = queue.isNotEmpty
        ? queue.first.add(rule.window)
        : now.add(rule.window);

    return RateLimitResult(
      allowed: allowed,
      remainingRequests: (rule.maxRequests - queue.length).clamp(0, rule.maxRequests),
      resetTime: resetTime,
      message: allowed
          ? 'Request allowed'
          : 'Rate limit exceeded. Reset at ${resetTime.toIso8601String()}',
    );
  }

  @override
  Future<void> reset(String identifier) async {
    _requests.remove(identifier);
    _resetTimers[identifier]?.cancel();
    _resetTimers.remove(identifier);
  }

  @override
  Future<void> clear() async {
    _requests.clear();
    for (final timer in _resetTimers.values) {
      timer.cancel();
    }
    _resetTimers.clear();
  }
}

// ==================== トークンブラックリスト ====================

/// ブラックリストエントリ
class BlacklistEntry {
  final String token;
  final DateTime revokedAt;
  final String? reason;
  final DateTime expiresAt;

  const BlacklistEntry({
    required this.token,
    required this.revokedAt,
    this.reason,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'token': token,
        'revokedAt': revokedAt.toIso8601String(),
        'reason': reason,
        'expiresAt': expiresAt.toIso8601String(),
      };
}

/// トークンブラックリストサービス
abstract class TokenBlacklist {
  /// トークンをブラックリストに追加
  Future<void> revoke(String token, String? reason, DateTime expiresAt);

  /// トークンがブラックリストに含まれているかチェック
  Future<bool> isRevoked(String token);

  /// ブラックリストをクリア
  Future<void> clear();

  /// 期限切れエントリを削除
  Future<void> cleanup();
}

/// メモリベースのトークンブラックリスト実装
class MemoryTokenBlacklist implements TokenBlacklist {
  final Map<String, BlacklistEntry> _blacklist = {};

  @override
  Future<void> revoke(
    String token,
    String? reason,
    DateTime expiresAt,
  ) async {
    _blacklist[token] = BlacklistEntry(
      token: token,
      revokedAt: DateTime.now(),
      reason: reason,
      expiresAt: expiresAt,
    );
  }

  @override
  Future<bool> isRevoked(String token) async {
    final entry = _blacklist[token];
    if (entry == null) {
      return false;
    }

    if (entry.isExpired) {
      _blacklist.remove(token);
      return false;
    }

    return true;
  }

  @override
  Future<void> clear() async {
    _blacklist.clear();
  }

  @override
  Future<void> cleanup() async {
    _blacklist.removeWhere((_, entry) => entry.isExpired);
  }
}

// ==================== CSRF保護 ====================

/// CSRF トークン
class CsrfToken {
  final String token;
  final String sessionId;
  final DateTime createdAt;
  final DateTime expiresAt;

  const CsrfToken({
    required this.token,
    required this.sessionId,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'token': token,
        'sessionId': sessionId,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };
}

/// CSRF保護サービス
abstract class CsrfProtection {
  /// CSRF トークンを生成
  Future<CsrfToken> generateToken(String sessionId);

  /// CSRF トークンを検証
  Future<bool> validateToken(String token, String sessionId);

  /// トークンをクリア
  Future<void> clearToken(String sessionId);

  /// 期限切れトークンをクリーンアップ
  Future<void> cleanup();
}

/// メモリベースのCSRF保護実装
class MemoryCsrfProtection implements CsrfProtection {
  final Map<String, CsrfToken> _tokens = {};
  static const int _tokenLength = 32;
  static const int _expiryMinutes = 30;

  @override
  Future<CsrfToken> generateToken(String sessionId) async {
    final token = _generateSecureToken();
    final now = DateTime.now();
    final expiresAt = now.add(Duration(minutes: _expiryMinutes));

    final csrfToken = CsrfToken(
      token: token,
      sessionId: sessionId,
      createdAt: now,
      expiresAt: expiresAt,
    );

    _tokens[sessionId] = csrfToken;
    return csrfToken;
  }

  @override
  Future<bool> validateToken(String token, String sessionId) async {
    final stored = _tokens[sessionId];
    if (stored == null) {
      return false;
    }

    if (stored.isExpired) {
      _tokens.remove(sessionId);
      return false;
    }

    return stored.token == token;
  }

  @override
  Future<void> clearToken(String sessionId) async {
    _tokens.remove(sessionId);
  }

  @override
  Future<void> cleanup() async {
    _tokens.removeWhere((_, token) => token.isExpired);
  }

  String _generateSecureToken() {
    final values = List<int>.generate(32, (i) => i);
    return sha256.convert(values).toString().substring(0, 32);
  }
}

// ==================== IPホワイトリスト ====================

/// IP ホワイトリストエントリ
class IpWhitelistEntry {
  final String ipAddress;
  final String? description;
  final DateTime addedAt;
  final DateTime? expiresAt;

  const IpWhitelistEntry({
    required this.ipAddress,
    this.description,
    required this.addedAt,
    this.expiresAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

/// IPホワイトリストサービス
abstract class IpWhitelist {
  /// IP を許可リストに追加
  Future<void> addIp(String ipAddress, String? description, DateTime? expiresAt);

  /// IP がホワイトリストに含まれているかチェック
  Future<bool> isAllowed(String ipAddress);

  /// IPを削除
  Future<void> removeIp(String ipAddress);

  /// ホワイトリストをクリア
  Future<void> clear();
}

/// メモリベースの IP ホワイトリスト実装
class MemoryIpWhitelist implements IpWhitelist {
  final Map<String, IpWhitelistEntry> _whitelist = {};

  @override
  Future<void> addIp(
    String ipAddress,
    String? description,
    DateTime? expiresAt,
  ) async {
    _whitelist[ipAddress] = IpWhitelistEntry(
      ipAddress: ipAddress,
      description: description,
      addedAt: DateTime.now(),
      expiresAt: expiresAt,
    );
  }

  @override
  Future<bool> isAllowed(String ipAddress) async {
    final entry = _whitelist[ipAddress];
    if (entry == null) {
      return false;
    }

    if (entry.isExpired) {
      _whitelist.remove(ipAddress);
      return false;
    }

    return true;
  }

  @override
  Future<void> removeIp(String ipAddress) async {
    _whitelist.remove(ipAddress);
  }

  @override
  Future<void> clear() async {
    _whitelist.clear();
  }
}

// ==================== セキュリティマネージャー ====================

/// セキュリティマネージャー（統合）
class SecurityManager {
  final RateLimiter rateLimiter;
  final TokenBlacklist tokenBlacklist;
  final CsrfProtection csrfProtection;
  final IpWhitelist ipWhitelist;

  SecurityManager({
    required this.rateLimiter,
    required this.tokenBlacklist,
    required this.csrfProtection,
    required this.ipWhitelist,
  });

  /// セキュリティチェック（複合）
  Future<({
    bool rateLimitOk,
    bool tokenValid,
    bool ipAllowed,
    String message,
  })> performSecurityCheck({
    required String userId,
    required String ipAddress,
    required String? authToken,
    bool requireCsrf = false,
    String? csrfToken,
    String? sessionId,
  }) async {
    // IP チェック
    final ipAllowed = await ipWhitelist.isAllowed(ipAddress);
    if (!ipAllowed) {
      return (
        rateLimitOk: false,
        tokenValid: false,
        ipAllowed: false,
        message: 'IP address not whitelisted',
      );
    }

    // レート制限チェック
    final rateLimitRule = RateLimitRule(
      identifier: '$userId:$ipAddress',
      maxRequests: 100,
      window: Duration(minutes: 1),
    );
    final rateLimitResult = await rateLimiter.checkLimit(rateLimitRule);

    if (!rateLimitResult.allowed) {
      return (
        rateLimitOk: false,
        tokenValid: false,
        ipAllowed: true,
        message: rateLimitResult.message ?? 'Rate limit exceeded',
      );
    }

    // トークン検証
    bool tokenValid = true;
    if (authToken != null) {
      final isRevoked = await tokenBlacklist.isRevoked(authToken);
      if (isRevoked) {
        tokenValid = false;
        return (
          rateLimitOk: true,
          tokenValid: false,
          ipAllowed: true,
          message: 'Token has been revoked',
        );
      }
    }

    // CSRF検証
    if (requireCsrf && sessionId != null && csrfToken != null) {
      final csrfValid = await csrfProtection.validateToken(csrfToken, sessionId);
      if (!csrfValid) {
        return (
          rateLimitOk: true,
          tokenValid: true,
          ipAllowed: true,
          message: 'CSRF token validation failed',
        );
      }
    }

    return (
      rateLimitOk: true,
      tokenValid: true,
      ipAllowed: true,
      message: 'Security checks passed',
    );
  }
}
