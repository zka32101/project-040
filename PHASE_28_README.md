# Phase 28: HTTP クライアント・JWT 認証・インターセプター

Phase 28では、実際のバックエンド通信に必要な HTTP クライアント実装、JWT トークン管理、リクエスト/レスポンスインターセプター機能を実装しました。

## 実装内容

### 1. JWT トークン管理 (`lib/services/jwt_service.dart`)

#### JWT トークン情報

**JwtToken**:
```dart
class JwtToken {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final String tokenType; // "Bearer"
  final Map<String, dynamic>? claims;
  
  bool get isExpired;
  bool get isExpiringSoon; // 5分以内に期限切れ
  String get authorizationHeader; // "Bearer {token}"
}
```

#### JWT ペイロード

**JwtPayload**:
```dart
class JwtPayload {
  final String subject; // ユーザーID
  final String issuer; // 発行者
  final String audience; // 対象ユーザー
  final DateTime issuedAt;
  final DateTime expiresAt;
  final Map<String, dynamic>? customClaims; // カスタム属性
  
  Map<String, dynamic> toClaims(); // 登録請求を生成
}
```

#### JWT サービス

**JwtService インターフェース**:
```dart
abstract class JwtService {
  String generateToken(JwtPayload payload, String secret);
  JwtValidationResult validateToken(String token, String secret);
  Map<String, dynamic>? extractClaims(String token);
  DateTime? getExpiresAt(String token);
  int? getTimeToExpiry(String token);
}
```

**JwtServiceImpl** - HS256 署名による実装:
- トークン生成（ヘッダー.ペイロード.署名）
- トークン検証（署名確認・有効期限確認）
- クレーム抽出
- 残り有効期限計算

```dart
final jwtService = JwtServiceImpl();

// トークン生成
final payload = JwtPayload(
  subject: 'user_1',
  issuer: 'auth-server',
  audience: 'api-server',
  issuedAt: DateTime.now(),
  expiresAt: DateTime.now().add(Duration(hours: 1)),
  customClaims: {'role': 'admin'},
);
final token = jwtService.generateToken(payload, 'secret_key');

// トークン検証
final result = jwtService.validateToken(token, 'secret_key');
if (result.isValid) {
  print('Claims: ${result.claims}');
}

// 残り時間を取得
final timeToExpiry = jwtService.getTimeToExpiry(token); // 秒単位
```

#### トークンストア

**TokenStore インターフェース**:
```dart
abstract class TokenStore {
  Future<void> saveToken(JwtToken token);
  Future<JwtToken?> getToken();
  Future<void> deleteToken();
  Future<void> clear();
}
```

**MemoryTokenStore** - メモリ実装:
```dart
final tokenStore = MemoryTokenStore();

// トークン保存
await tokenStore.saveToken(jwtToken);

// トークン取得
final token = await tokenStore.getToken();

// トークン削除
await tokenStore.deleteToken();
```

#### トークン更新マネージャー

**TokenRefreshManager**:
```dart
final refreshManager = TokenRefreshManager(
  tokenStore: tokenStore,
  jwtService: jwtService,
  refreshCallback: () async => refreshTokenFromServer(),
);

// 有効なトークンを取得（期限切れならリフレッシュ）
final token = await refreshManager.getValidToken();
```

機能:
- 有効期限切れのトークンを自動リフレッシュ
- 期限切れ間近（5分以内）のトークンをバックグラウンドリフレッシュ
- リフレッシュ失敗時の既存トークン返却

### 2. HTTP API クライアント (`lib/services/http_api_client.dart`)

#### HTTP クライアント設定

**HttpClientConfig**:
```dart
class HttpClientConfig {
  final String baseUrl;
  final Duration timeout;
  final Map<String, String> defaultHeaders;
  final bool enableLogging;
  final int maxRetries;
  final Duration retryDelay;
}

final config = HttpClientConfig(
  baseUrl: 'https://api.example.com',
  timeout: Duration(seconds: 30),
  enableLogging: true,
  maxRetries: 3,
  retryDelay: Duration(seconds: 1),
);
```

#### HTTP リクエスト・レスポンス

**HttpRequest**:
```dart
class HttpRequest {
  final String method; // GET, POST, PUT, DELETE, PATCH
  final String endpoint;
  final Map<String, dynamic>? body;
  final Map<String, String>? headers;
  final Map<String, String>? queryParameters;
}
```

**HttpResponse**:
```dart
class HttpResponse {
  final int statusCode;
  final Map<String, String> headers;
  final String body;
  final DateTime receivedAt;
  
  bool get isSuccess; // 200-299
  Map<String, dynamic> get json; // JSON デコード
}
```

#### HTTP クライアント

**HttpClient インターフェース**:
```dart
abstract class HttpClient {
  Future<HttpResponse> get(String endpoint, {...});
  Future<HttpResponse> post(String endpoint, {...});
  Future<HttpResponse> put(String endpoint, {...});
  Future<HttpResponse> patch(String endpoint, {...});
  Future<HttpResponse> delete(String endpoint, {...});
}
```

**HttpApiClientImpl** - 実装:
```dart
final httpClient = HttpApiClientImpl(
  config: config,
  jwtService: jwtService,
  tokenStore: tokenStore,
  interceptors: [
    LoggingInterceptor(),
    TokenRefreshInterceptor(refreshManager: refreshManager),
    ErrorHandlingInterceptor(),
  ],
);

// リクエスト実行
final response = await httpClient.post(
  '/api/jobs',
  body: {'title': 'New Job'},
);

if (response.isSuccess) {
  print(response.json);
}
```

### 3. インターセプター

#### HttpInterceptor インターフェース

```dart
abstract class HttpInterceptor {
  Future<HttpRequest> onRequest(HttpRequest request, HttpClient client);
  Future<HttpResponse> onResponse(HttpResponse response, HttpClient client);
}
```

#### 実装例

**LoggingInterceptor** - リクエスト・レスポンスログ:
```dart
class LoggingInterceptor implements HttpInterceptor {
  @override
  Future<HttpRequest> onRequest(HttpRequest request, HttpClient client) async {
    print('[REQUEST] ${request.method} ${request.endpoint}');
    if (request.body != null) {
      print('[BODY] ${jsonEncode(request.body)}');
    }
    return request;
  }
  
  @override
  Future<HttpResponse> onResponse(HttpResponse response, HttpClient client) async {
    print('[RESPONSE] ${response.statusCode}');
    return response;
  }
}
```

**ErrorHandlingInterceptor** - エラーハンドリング:
```dart
class ErrorHandlingInterceptor implements HttpInterceptor {
  @override
  Future<HttpResponse> onResponse(HttpResponse response, HttpClient client) async {
    if (!response.isSuccess) {
      final error = ApiErrorResponse.fromJson(
        response.statusCode,
        jsonDecode(response.body),
      );
      throw error;
    }
    return response;
  }
}
```

**TokenRefreshInterceptor** - トークン自動リフレッシュ:
```dart
class TokenRefreshInterceptor implements HttpInterceptor {
  final TokenRefreshManager refreshManager;
  
  @override
  Future<HttpRequest> onRequest(HttpRequest request, HttpClient client) async {
    final token = await refreshManager.getValidToken();
    final headers = request.headers ?? {};
    if (token != null) {
      headers['Authorization'] = token.authorizationHeader;
    }
    return request;
  }
}
```

**RetryInterceptor** - 自動リトライ:
```dart
class RetryInterceptor implements HttpInterceptor {
  @override
  Future<HttpResponse> onResponse(HttpResponse response, HttpClient client) async {
    if (response.statusCode == 429 || response.statusCode == 503) {
      throw Exception('Retryable error');
    }
    return response;
  }
}
```

## テスト カバレッジ

`test/phase_28_http_auth_test.dart` - 30個のテストケース

### JWT トークン（7テスト）
1. JWT トークンを生成
2. JWT トークンを検証 - 有効
3. JWT トークンを検証 - 無効な署名
4. JWT トークンを検証 - 有効期限切れ
5. JWT トークンからクレームを抽出
6. トークン有効期限を取得
7. トークン残り時間を取得

### トークンストア（3テスト）
8. トークンを保存
9. トークンを取得
10. トークンを削除

### JWT トークン情報（5テスト）
11. トークン有効期限判定 - 有効
12. トークン有効期限判定 - 期限切れ
13. トークン期限切れ間近判定
14. Authorization ヘッダー生成
15. JWT トークン JSON シリアライズ

### HTTP クライアント設定（2テスト）
16. HTTP クライアント設定 - デフォルト
17. HTTP ヘッダー生成

### HTTP リクエスト・レスポンス（3テスト）
18. HTTP リクエスト作成
19. HTTP レスポンス作成
20. HTTP レスポンス - エラーステータス

### インターセプター（3テスト）
21. ロギングインターセプター
22. エラーハンドリングインターセプター - 成功
23. トークンリフレッシュインターセプター

### トークン更新マネージャー（3テスト）
24. 有効なトークンを取得
25. 期限切れトークンをリフレッシュ
26. トークンが無い場合

### その他（4テスト）
27. JWT ペイロードから登録請求を生成
28. HTTP クライアント設定でトークンなしヘッダー取得
29. リトライインターセプター - リトライ可能エラー
30. HTTP クライアント初期化

## 完全な使用例

### セットアップ

```dart
// 1. JWT サービスと トークンストアを初期化
final jwtService = JwtServiceImpl();
final tokenStore = MemoryTokenStore();

// 2. トークン更新マネージャーを設定
final refreshManager = TokenRefreshManager(
  tokenStore: tokenStore,
  jwtService: jwtService,
  refreshCallback: () async {
    // サーバーからトークンを更新
    final response = await httpClient.post('/auth/refresh');
    return JwtToken.fromJson(response.json);
  },
);

// 3. HTTP クライアントを設定
final config = HttpClientConfig(
  baseUrl: 'https://api.example.com',
  enableLogging: true,
);

final httpClient = HttpApiClientImpl(
  config: config,
  jwtService: jwtService,
  tokenStore: tokenStore,
  interceptors: [
    LoggingInterceptor(),
    TokenRefreshInterceptor(refreshManager: refreshManager),
    ErrorHandlingInterceptor(),
    RetryInterceptor(),
  ],
);
```

### ログインフロー

```dart
// ログイン
final loginResponse = await httpClient.post(
  '/auth/login',
  body: {
    'email': 'user@example.com',
    'password': 'password123',
  },
);

final token = JwtToken(
  accessToken: loginResponse.json['accessToken'],
  refreshToken: loginResponse.json['refreshToken'],
  expiresAt: DateTime.parse(loginResponse.json['expiresAt']),
);

// トークンを保存
await tokenStore.saveToken(token);
```

### API リクエスト

```dart
// トークンが自動的に Authorization ヘッダーに追加される
final response = await httpClient.get('/api/jobs');

if (response.isSuccess) {
  final jobs = response.json['jobs'] as List;
  for (final job in jobs) {
    print('Job: ${job['id']} - ${job['title']}');
  }
}
```

### エラーハンドリング

```dart
try {
  await httpClient.post('/api/invalid-endpoint');
} on ApiErrorResponse catch (e) {
  print('Error ${e.statusCode}: ${e.message}');
} catch (e) {
  print('Network error: $e');
}
```

## アーキテクチャパターン

### チェーン・オブ・レスポンシビリティパターン（インターセプター）
- リクエスト前後の処理をチェーン化
- 各インターセプターが処理を追加・修正
- 処理順序を制御可能

### ストラテジーパターン（JWT サービス）
- トークン生成・検証・抽出を策略化
- 異なる署名アルゴリズムの切り替え可能

### オブザーバーパターン（トークン更新）
- トークンの有効期限を監視
- 自動リフレッシュ機能

### ファサードパターン（HTTP クライアント）
- 複雑なインターセプター処理を隠蔽
- シンプルな API を提供

## 今後の拡張ポイント

1. **HTTP 実装** - http パッケージを使用した実際の通信
2. **レート制限** - API 呼び出しの制限・スロットリング
3. **キャッシング** - レスポンスキャッシング戦略
4. **詳細ログ** - 監視・デバッグ用ログ出力
5. **RS256 署名** - RSA 署名アルゴリズム対応
6. **多要素認証** - MFA サポート
7. **トークン失効リスト** - ブラックリスト管理
8. **バイオメトリクス** - 生体認証統合

## 終了

Phase 28 で HTTP クライアント、JWT 認証、インターセプター機能が完成しました。これにより、Phase 27 のバックエンド統合基盤を実際のサーバー通信に拡張する準備が整いました。

インターセプターパターンにより、認証・エラーハンドリング・ログ・リトライなど複雑な機能を柔軟に追加・削除できるようになりました。
