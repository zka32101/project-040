/// Phase 28: JWT トークン管理・認証サービス
/// トークン生成、検証、リフレッシュ機能

import 'dart:convert';
import 'package:crypto/crypto.dart';

// ==================== JWT 関連モデル ====================

/// JWT トークン情報
class JwtToken {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final String tokenType;
  final Map<String, dynamic>? claims;

  const JwtToken({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
    this.claims,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isExpiringSoon {
    final bufferTime = Duration(minutes: 5);
    return DateTime.now().add(bufferTime).isAfter(expiresAt);
  }

  String get authorizationHeader => '$tokenType $accessToken';

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresAt': expiresAt.toIso8601String(),
        'tokenType': tokenType,
        'claims': claims,
      };
}

/// JWT ペイロード
class JwtPayload {
  final String subject; // ユーザーID
  final String issuer;
  final String audience;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final Map<String, dynamic>? customClaims;

  const JwtPayload({
    required this.subject,
    required this.issuer,
    required this.audience,
    required this.issuedAt,
    required this.expiresAt,
    this.customClaims,
  });

  Map<String, dynamic> toClaims() => {
        'sub': subject,
        'iss': issuer,
        'aud': audience,
        'iat': (issuedAt.millisecondsSinceEpoch / 1000).toInt(),
        'exp': (expiresAt.millisecondsSinceEpoch / 1000).toInt(),
        ...?customClaims,
      };
}

/// JWT 検証結果
class JwtValidationResult {
  final bool isValid;
  final String? errorMessage;
  final Map<String, dynamic>? claims;

  const JwtValidationResult({
    required this.isValid,
    this.errorMessage,
    this.claims,
  });
}

// ==================== トークン管理サービス ====================

/// JWT サービスインターフェース
abstract class JwtService {
  /// トークンを生成
  String generateToken(JwtPayload payload, String secret);

  /// トークンを検証
  JwtValidationResult validateToken(String token, String secret);

  /// トークンからクレームを抽出
  Map<String, dynamic>? extractClaims(String token);

  /// トークンの有効期限を取得
  DateTime? getExpiresAt(String token);

  /// トークンが有効期限切れまであと何秒か
  int? getTimeToExpiry(String token);
}

/// JWT サービス実装
class JwtServiceImpl implements JwtService {
  static const String _headerType = 'JWT';

  @override
  String generateToken(JwtPayload payload, String secret) {
    final header = {
      'alg': 'HS256',
      'typ': _headerType,
    };

    final claims = payload.toClaims();

    final headerEncoded =
        _base64UrlEncode(utf8.encode(jsonEncode(header)));
    final claimsEncoded =
        _base64UrlEncode(utf8.encode(jsonEncode(claims)));

    final message = '$headerEncoded.$claimsEncoded';
    final signature = _hmacSha256(message, secret);
    final signatureEncoded = _base64UrlEncode(signature);

    return '$message.$signatureEncoded';
  }

  @override
  JwtValidationResult validateToken(String token, String secret) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return JwtValidationResult(
          isValid: false,
          errorMessage: 'Invalid token format',
        );
      }

      // 署名を検証
      final message = '${parts[0]}.${parts[1]}';
      final expectedSignature = _hmacSha256(message, secret);
      final expectedSignatureEncoded = _base64UrlEncode(expectedSignature);

      if (parts[2] != expectedSignatureEncoded) {
        return JwtValidationResult(
          isValid: false,
          errorMessage: 'Invalid token signature',
        );
      }

      // クレームをデコード
      final claimsJson = utf8.decode(_base64UrlDecode(parts[1]));
      final claims = jsonDecode(claimsJson) as Map<String, dynamic>;

      // 有効期限を確認
      final expTimestamp = claims['exp'] as int?;
      if (expTimestamp != null) {
        final expiresAt =
            DateTime.fromMillisecondsSinceEpoch(expTimestamp * 1000);
        if (DateTime.now().isAfter(expiresAt)) {
          return JwtValidationResult(
            isValid: false,
            errorMessage: 'Token expired',
            claims: claims,
          );
        }
      }

      return JwtValidationResult(
        isValid: true,
        claims: claims,
      );
    } catch (e) {
      return JwtValidationResult(
        isValid: false,
        errorMessage: 'Token validation error: $e',
      );
    }
  }

  @override
  Map<String, dynamic>? extractClaims(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final claimsJson = utf8.decode(_base64UrlDecode(parts[1]));
      return jsonDecode(claimsJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  DateTime? getExpiresAt(String token) {
    final claims = extractClaims(token);
    if (claims == null) {
      return null;
    }

    final expTimestamp = claims['exp'] as int?;
    if (expTimestamp == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(expTimestamp * 1000);
  }

  @override
  int? getTimeToExpiry(String token) {
    final expiresAt = getExpiresAt(token);
    if (expiresAt == null) {
      return null;
    }

    return expiresAt.difference(DateTime.now()).inSeconds;
  }

  String _base64UrlEncode(List<int> bytes) {
    final encoded = base64Url.encode(bytes);
    return encoded.replaceAll('=', '');
  }

  List<int> _base64UrlDecode(String encoded) {
    var output = encoded.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Invalid base64url string');
    }
    return base64Url.decode(output);
  }

  List<int> _hmacSha256(String message, String secret) {
    return Hmac(sha256, utf8.encode(secret))
        .convert(utf8.encode(message))
        .bytes;
  }
}

// ==================== トークンストア ====================

/// トークン永続化インターフェース
abstract class TokenStore {
  /// トークンを保存
  Future<void> saveToken(JwtToken token);

  /// トークンを取得
  Future<JwtToken?> getToken();

  /// トークンを削除
  Future<void> deleteToken();

  /// トークンをクリア
  Future<void> clear();
}

/// メモリベースのトークンストア
class MemoryTokenStore implements TokenStore {
  JwtToken? _token;

  @override
  Future<void> saveToken(JwtToken token) async {
    _token = token;
  }

  @override
  Future<JwtToken?> getToken() async {
    return _token;
  }

  @override
  Future<void> deleteToken() async {
    _token = null;
  }

  @override
  Future<void> clear() async {
    _token = null;
  }
}

// ==================== トークン更新マネージャー ====================

/// トークン更新マネージャー
class TokenRefreshManager {
  final TokenStore tokenStore;
  final JwtService jwtService;
  final Future<JwtToken> Function() refreshCallback;
  
  TokenRefreshManager({
    required this.tokenStore,
    required this.jwtService,
    required this.refreshCallback,
  });

  Future<JwtToken?> getValidToken() async {
    var token = await tokenStore.getToken();
    
    if (token == null) {
      return null;
    }

    // トークンが有効期限切れだったら、リフレッシュを試みる
    if (token.isExpired) {
      try {
        token = await refreshCallback();
        await tokenStore.saveToken(token);
      } catch (e) {
        await tokenStore.deleteToken();
        return null;
      }
    }
    // トークンが期限切れ間近だったら、バックグラウンドでリフレッシュ
    else if (token.isExpiringSoon) {
      try {
        final refreshedToken = await refreshCallback();
        await tokenStore.saveToken(refreshedToken);
        token = refreshedToken;
      } catch (e) {
        // リフレッシュ失敗時も現在のトークンを返す
      }
    }

    return token;
  }
}
