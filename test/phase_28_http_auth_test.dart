/// Phase 28: HTTP クライアント・認証テスト
/// JWT トークン、HTTP クライアント、インターセプター機能のテスト

import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/services/jwt_service.dart';
import 'package:project_040/services/http_api_client.dart';

void main() {
  group('Phase 28: HTTP クライアント・認証', () {
    late JwtServiceImpl jwtService;
    late HttpClientConfig config;
    late HttpApiClientImpl httpClient;
    late MemoryTokenStore tokenStore;

    setUp(() {
      jwtService = JwtServiceImpl();
      tokenStore = MemoryTokenStore();
      config = HttpClientConfig(
        baseUrl: 'https://api.example.com',
        timeout: Duration(seconds: 30),
        enableLogging: false,
      );
      httpClient = HttpApiClientImpl(
        config: config,
        jwtService: jwtService,
        tokenStore: tokenStore,
      );
    });

    // ==================== JWT トークンテスト ====================

    test('1. JWT トークンを生成', () {
      final payload = JwtPayload(
        subject: 'user_1',
        issuer: 'test-issuer',
        audience: 'test-audience',
        issuedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(hours: 1)),
      );

      final token = jwtService.generateToken(payload, 'secret');

      expect(token, isNotNull);
      expect(token.split('.').length, 3);
    });

    test('2. JWT トークンを検証 - 有効', () {
      final payload = JwtPayload(
        subject: 'user_1',
        issuer: 'test-issuer',
        audience: 'test-audience',
        issuedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(hours: 1)),
      );

      final token = jwtService.generateToken(payload, 'secret');
      final result = jwtService.validateToken(token, 'secret');

      expect(result.isValid, true);
      expect(result.errorMessage, isNull);
      expect(result.claims, isNotNull);
    });

    test('3. JWT トークンを検証 - 無効な署名', () {
      final payload = JwtPayload(
        subject: 'user_1',
        issuer: 'test-issuer',
        audience: 'test-audience',
        issuedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(hours: 1)),
      );

      final token = jwtService.generateToken(payload, 'secret');
      final result = jwtService.validateToken(token, 'wrong-secret');

      expect(result.isValid, false);
      expect(result.errorMessage, contains('signature'));
    });

    test('4. JWT トークンを検証 - 有効期限切れ', () {
      final payload = JwtPayload(
        subject: 'user_1',
        issuer: 'test-issuer',
        audience: 'test-audience',
        issuedAt: DateTime.now().subtract(Duration(hours: 2)),
        expiresAt: DateTime.now().subtract(Duration(hours: 1)),
      );

      final token = jwtService.generateToken(payload, 'secret');
      final result = jwtService.validateToken(token, 'secret');

      expect(result.isValid, false);
      expect(result.errorMessage, contains('expired'));
    });

    test('5. JWT トークンからクレームを抽出', () {
      final customClaims = {'role': 'admin', 'permissions': ['read', 'write']};
      final payload = JwtPayload(
        subject: 'user_1',
        issuer: 'test-issuer',
        audience: 'test-audience',
        issuedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(hours: 1)),
        customClaims: customClaims,
      );

      final token = jwtService.generateToken(payload, 'secret');
      final claims = jwtService.extractClaims(token);

      expect(claims, isNotNull);
      expect(claims!['sub'], 'user_1');
      expect(claims['role'], 'admin');
    });

    test('6. トークン有効期限を取得', () {
      final expiresAt = DateTime.now().add(Duration(hours: 1));
      final payload = JwtPayload(
        subject: 'user_1',
        issuer: 'test-issuer',
        audience: 'test-audience',
        issuedAt: DateTime.now(),
        expiresAt: expiresAt,
      );

      final token = jwtService.generateToken(payload, 'secret');
      final retrievedExpiresAt = jwtService.getExpiresAt(token);

      expect(retrievedExpiresAt, isNotNull);
      expect(retrievedExpiresAt!.difference(expiresAt).inSeconds, lessThan(1));
    });

    test('7. トークン残り時間を取得', () {
      final expiresAt = DateTime.now().add(Duration(minutes: 30));
      final payload = JwtPayload(
        subject: 'user_1',
        issuer: 'test-issuer',
        audience: 'test-audience',
        issuedAt: DateTime.now(),
        expiresAt: expiresAt,
      );

      final token = jwtService.generateToken(payload, 'secret');
      final timeToExpiry = jwtService.getTimeToExpiry(token);

      expect(timeToExpiry, isNotNull);
      expect(timeToExpiry, greaterThan(1700)); // 約28分以上
      expect(timeToExpiry, lessThan(1800)); // 30分以下
    });

    // ==================== トークンストアテスト ====================

    test('8. トークンを保存', () async {
      final token = JwtToken(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_123',
        expiresAt: DateTime.now().add(Duration(hours: 1)),
      );

      await tokenStore.saveToken(token);
      final retrieved = await tokenStore.getToken();

      expect(retrieved, isNotNull);
      expect(retrieved!.accessToken, 'access_token_123');
    });

    test('9. トークンを取得', () async {
      final token = JwtToken(
        accessToken: 'access_token_456',
        expiresAt: DateTime.now().add(Duration(hours: 1)),
      );

      await tokenStore.saveToken(token);
      final retrieved = await tokenStore.getToken();

      expect(retrieved!.accessToken, 'access_token_456');
    });

    test('10. トークンを削除', () async {
      final token = JwtToken(
        accessToken: 'access_token_789',
        expiresAt: DateTime.now().add(Duration(hours: 1)),
      );

      await tokenStore.saveToken(token);
      await tokenStore.deleteToken();
      final retrieved = await tokenStore.getToken();

      expect(retrieved, isNull);
    });

    // ==================== JWT トークン情報テスト ====================

    test('11. トークン有効期限判定 - 有効', () {
      final token = JwtToken(
        accessToken: 'token_123',
        expiresAt: DateTime.now().add(Duration(hours: 1)),
      );

      expect(token.isExpired, false);
    });

    test('12. トークン有効期限判定 - 期限切れ', () {
      final token = JwtToken(
        accessToken: 'token_123',
        expiresAt: DateTime.now().subtract(Duration(hours: 1)),
      );

      expect(token.isExpired, true);
    });

    test('13. トークン期限切れ間近判定', () {
      final token = JwtToken(
        accessToken: 'token_123',
        expiresAt: DateTime.now().add(Duration(minutes: 3)),
      );

      expect(token.isExpiringSoon, true);
    });

    test('14. Authorization ヘッダー生成', () {
      final token = JwtToken(
        accessToken: 'my_access_token',
        expiresAt: DateTime.now().add(Duration(hours: 1)),
        tokenType: 'Bearer',
      );

      expect(token.authorizationHeader, 'Bearer my_access_token');
    });

    test('15. JWT トークン JSON シリアライズ', () {
      final expiresAt = DateTime.now().add(Duration(hours: 1));
      final token = JwtToken(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_123',
        expiresAt: expiresAt,
        claims: {'role': 'admin'},
      );

      final json = token.toJson();

      expect(json['accessToken'], 'access_token_123');
      expect(json['refreshToken'], 'refresh_token_123');
      expect(json['claims']['role'], 'admin');
    });

    // ==================== HTTP クライアント設定テスト ====================

    test('16. HTTP クライアント設定 - デフォルト', () {
      final cfg = HttpClientConfig(baseUrl: 'https://api.example.com');

      expect(cfg.baseUrl, 'https://api.example.com');
      expect(cfg.timeout, Duration(seconds: 30));
      expect(cfg.maxRetries, 3);
      expect(cfg.enableLogging, false);
    });

    test('17. HTTP ヘッダー生成', () {
      final cfg = HttpClientConfig(
        baseUrl: 'https://api.example.com',
        defaultHeaders: {'X-Custom-Header': 'value'},
      );

      final headers = cfg.getHeaders(token: 'my_token');

      expect(headers['Content-Type'], 'application/json');
      expect(headers['Authorization'], 'Bearer my_token');
      expect(headers['X-Custom-Header'], 'value');
    });

    // ==================== HTTP リクエスト・レスポンステスト ====================

    test('18. HTTP リクエスト作成', () {
      final request = HttpRequest(
        method: 'POST',
        endpoint: '/api/jobs',
        body: {'title': 'Test Job'},
        headers: {'X-Custom': 'value'},
      );

      expect(request.method, 'POST');
      expect(request.endpoint, '/api/jobs');
      expect(request.body!['title'], 'Test Job');
    });

    test('19. HTTP レスポンス作成', () {
      final response = HttpResponse(
        statusCode: 200,
        headers: {'Content-Type': 'application/json'},
        body: '{"id": 1, "name": "test"}',
        receivedAt: DateTime.now(),
      );

      expect(response.isSuccess, true);
      expect(response.json['id'], 1);
    });

    test('20. HTTP レスポンス - エラーステータス', () {
      final response = HttpResponse(
        statusCode: 404,
        headers: {},
        body: '{"error": "Not found"}',
        receivedAt: DateTime.now(),
      );

      expect(response.isSuccess, false);
    });

    // ==================== インターセプターテスト ====================

    test('21. ロギングインターセプター', () async {
      final interceptor = LoggingInterceptor();
      final request = HttpRequest(
        method: 'GET',
        endpoint: '/api/jobs',
      );

      final result = await interceptor.onRequest(request, httpClient);
      expect(result.endpoint, '/api/jobs');
    });

    test('22. エラーハンドリングインターセプター - 成功', () async {
      final interceptor = ErrorHandlingInterceptor();
      final response = HttpResponse(
        statusCode: 200,
        headers: {},
        body: '{}',
        receivedAt: DateTime.now(),
      );

      final result = await interceptor.onResponse(response, httpClient);
      expect(result.statusCode, 200);
    });

    test('23. トークンリフレッシュインターセプター', () async {
      final token = JwtToken(
        accessToken: 'my_token',
        expiresAt: DateTime.now().add(Duration(hours: 1)),
      );
      await tokenStore.saveToken(token);

      final refreshManager = TokenRefreshManager(
        tokenStore: tokenStore,
        jwtService: jwtService,
        refreshCallback: () async => token,
      );

      final interceptor = TokenRefreshInterceptor(refreshManager: refreshManager);
      final request = HttpRequest(
        method: 'GET',
        endpoint: '/api/jobs',
      );

      final result = await interceptor.onRequest(request, httpClient);
      expect(result.headers, isNotNull);
      expect(result.headers!['Authorization'], contains('Bearer'));
    });

    // ==================== トークン更新マネージャーテスト ====================

    test('24. 有効なトークンを取得', () async {
      final token = JwtToken(
        accessToken: 'valid_token',
        expiresAt: DateTime.now().add(Duration(hours: 1)),
      );
      await tokenStore.saveToken(token);

      final refreshManager = TokenRefreshManager(
        tokenStore: tokenStore,
        jwtService: jwtService,
        refreshCallback: () async => token,
      );

      final retrieved = await refreshManager.getValidToken();
      expect(retrieved, isNotNull);
      expect(retrieved!.accessToken, 'valid_token');
    });

    test('25. 期限切れトークンをリフレッシュ', () async {
      final expiredToken = JwtToken(
        accessToken: 'expired_token',
        expiresAt: DateTime.now().subtract(Duration(hours: 1)),
      );
      await tokenStore.saveToken(expiredToken);

      final newToken = JwtToken(
        accessToken: 'new_token',
        expiresAt: DateTime.now().add(Duration(hours: 1)),
      );

      final refreshManager = TokenRefreshManager(
        tokenStore: tokenStore,
        jwtService: jwtService,
        refreshCallback: () async => newToken,
      );

      final retrieved = await refreshManager.getValidToken();
      expect(retrieved!.accessToken, 'new_token');
    });

    test('26. トークンが無い場合', () async {
      final token = JwtToken(
        accessToken: 'some_token',
        expiresAt: DateTime.now().add(Duration(hours: 1)),
      );

      final refreshManager = TokenRefreshManager(
        tokenStore: tokenStore,
        jwtService: jwtService,
        refreshCallback: () async => token,
      );

      final retrieved = await refreshManager.getValidToken();
      expect(retrieved, isNull);
    });

    test('27. JWT ペイロードから登録請求を生成', () {
      final customClaims = {'scope': 'read:jobs write:jobs'};
      final payload = JwtPayload(
        subject: 'user_123',
        issuer: 'auth-server',
        audience: 'api-server',
        issuedAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(hours: 1)),
        customClaims: customClaims,
      );

      final claims = payload.toClaims();

      expect(claims['sub'], 'user_123');
      expect(claims['iss'], 'auth-server');
      expect(claims['aud'], 'api-server');
      expect(claims['scope'], 'read:jobs write:jobs');
      expect(claims.containsKey('iat'), true);
      expect(claims.containsKey('exp'), true);
    });

    test('28. HTTP クライアント設定でトークンなしヘッダー取得', () {
      final cfg = HttpClientConfig(baseUrl: 'https://api.example.com');
      final headers = cfg.getHeaders();

      expect(headers.containsKey('Authorization'), false);
      expect(headers['Content-Type'], 'application/json');
    });

    test('29. リトライインターセプター - リトライ可能エラー', () async {
      final interceptor = RetryInterceptor();
      final response = HttpResponse(
        statusCode: 503,
        headers: {},
        body: 'Service Unavailable',
        receivedAt: DateTime.now(),
      );

      expect(
        () => interceptor.onResponse(response, httpClient),
        throwsException,
      );
    });

    test('30. HTTP クライアント初期化', () {
      expect(httpClient, isNotNull);
      expect(httpClient.config.baseUrl, 'https://api.example.com');
      expect(httpClient.tokenStore, isNotNull);
    });
  });
}
