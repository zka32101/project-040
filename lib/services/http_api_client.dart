/// Phase 28: HTTP API クライアント実装
/// http パッケージを使用した REST API クライアント

import 'dart:convert';
import 'package:project_040/models/api_models.dart';
import 'package:project_040/models/async_job_model.dart';
import 'package:project_040/services/jwt_service.dart';

// ==================== HTTP クライアント設定 ====================

/// HTTP クライアント設定
class HttpClientConfig {
  final String baseUrl;
  final Duration timeout;
  final Map<String, String> defaultHeaders;
  final bool enableLogging;
  final int maxRetries;
  final Duration retryDelay;

  const HttpClientConfig({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    this.defaultHeaders = const {},
    this.enableLogging = false,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  Map<String, String> getHeaders({String? token}) {
    final headers = {...defaultHeaders, 'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}

/// HTTP リクエスト
class HttpRequest {
  final String method; // GET, POST, PUT, DELETE, PATCH
  final String endpoint;
  final Map<String, dynamic>? body;
  final Map<String, String>? headers;
  final Map<String, String>? queryParameters;

  const HttpRequest({
    required this.method,
    required this.endpoint,
    this.body,
    this.headers,
    this.queryParameters,
  });
}

/// HTTP レスポンス
class HttpResponse {
  final int statusCode;
  final Map<String, String> headers;
  final String body;
  final DateTime receivedAt;

  const HttpResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
    required this.receivedAt,
  });

  Map<String, dynamic> get json => jsonDecode(body);

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

/// HTTP クライアントインターフェース
abstract class HttpClient {
  Future<HttpResponse> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  });

  Future<HttpResponse> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  });

  Future<HttpResponse> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  });

  Future<HttpResponse> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  });

  Future<HttpResponse> delete(
    String endpoint, {
    Map<String, String>? headers,
  });
}

// ==================== HTTP API クライアント実装 ====================

/// HTTP API クライアント実装
class HttpApiClientImpl implements HttpClient {
  final HttpClientConfig config;
  final JwtService? jwtService;
  final TokenStore? tokenStore;
  final List<HttpInterceptor> interceptors;

  HttpApiClientImpl({
    required this.config,
    this.jwtService,
    this.tokenStore,
    this.interceptors = const [],
  });

  @override
  Future<HttpResponse> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    return _executeRequest(
      HttpRequest(
        method: 'GET',
        endpoint: endpoint,
        headers: headers,
        queryParameters: queryParameters,
      ),
    );
  }

  @override
  Future<HttpResponse> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _executeRequest(
      HttpRequest(
        method: 'POST',
        endpoint: endpoint,
        body: body,
        headers: headers,
      ),
    );
  }

  @override
  Future<HttpResponse> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _executeRequest(
      HttpRequest(
        method: 'PUT',
        endpoint: endpoint,
        body: body,
        headers: headers,
      ),
    );
  }

  @override
  Future<HttpResponse> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _executeRequest(
      HttpRequest(
        method: 'PATCH',
        endpoint: endpoint,
        body: body,
        headers: headers,
      ),
    );
  }

  @override
  Future<HttpResponse> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return _executeRequest(
      HttpRequest(
        method: 'DELETE',
        endpoint: endpoint,
        headers: headers,
      ),
    );
  }

  Future<HttpResponse> _executeRequest(
    HttpRequest request, [
    int retryCount = 0,
  ]) async {
    try {
      // リクエストインターセプター実行
      var interceptedRequest = request;
      for (final interceptor in interceptors) {
        interceptedRequest =
            await interceptor.onRequest(interceptedRequest, this);
      }

      // トークン設定
      final headers = interceptedRequest.headers ?? {};
      if (tokenStore != null) {
        final token = await tokenStore!.getToken();
        if (token != null) {
          headers['Authorization'] = token.authorizationHeader;
        }
      }

      // URL構築
      final url = '${config.baseUrl}${interceptedRequest.endpoint}';
      final uri = Uri.parse(url);
      final uriWithQuery = interceptedRequest.queryParameters != null
          ? uri.replace(queryParameters: interceptedRequest.queryParameters)
          : uri;

      if (config.enableLogging) {
        print('[HTTP] ${interceptedRequest.method} $uriWithQuery');
      }

      // リクエスト実行（実装予定：http パッケージを使用）
      // 現在はモック実装
      final response = await _mockHttpRequest(
        interceptedRequest.method,
        uriWithQuery.toString(),
        interceptedRequest.body,
        headers,
      );

      // レスポンスインターセプター実行
      var interceptedResponse = response;
      for (final interceptor in interceptors) {
        interceptedResponse = await interceptor.onResponse(
          interceptedResponse,
          this,
        );
      }

      if (config.enableLogging) {
        print(
          '[HTTP] ${response.statusCode} ${interceptedRequest.method} $url',
        );
      }

      return interceptedResponse;
    } catch (e) {
      if (retryCount < config.maxRetries) {
        if (config.enableLogging) {
          print('[HTTP] Retry ${retryCount + 1}/${config.maxRetries}: $e');
        }
        await Future.delayed(config.retryDelay);
        return _executeRequest(request, retryCount + 1);
      }
      rethrow;
    }
  }

  Future<HttpResponse> _mockHttpRequest(
    String method,
    String url,
    Map<String, dynamic>? body,
    Map<String, String> headers,
  ) async {
    // 実装予定：http.dart パッケージ を使用した実際の HTTP 通信
    // 現在はモック実装
    return HttpResponse(
      statusCode: 200,
      headers: {},
      body: '{}',
      receivedAt: DateTime.now(),
    );
  }
}

// ==================== インターセプター ====================

/// HTTP インターセプターインターフェース
abstract class HttpInterceptor {
  Future<HttpRequest> onRequest(HttpRequest request, HttpClient client);
  Future<HttpResponse> onResponse(HttpResponse response, HttpClient client);
}

/// ログインインターセプター
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
  Future<HttpResponse> onResponse(
    HttpResponse response,
    HttpClient client,
  ) async {
    print('[RESPONSE] ${response.statusCode}');
    print('[RESPONSE_BODY] ${response.body}');
    return response;
  }
}

/// エラーハンドリングインターセプター
class ErrorHandlingInterceptor implements HttpInterceptor {
  @override
  Future<HttpRequest> onRequest(HttpRequest request, HttpClient client) async {
    return request;
  }

  @override
  Future<HttpResponse> onResponse(
    HttpResponse response,
    HttpClient client,
  ) async {
    if (!response.isSuccess) {
      try {
        final errorData = jsonDecode(response.body);
        final error = ApiErrorResponse.fromJson(
          response.statusCode,
          errorData as Map<String, dynamic>,
        );
        throw error;
      } catch (e) {
        if (e is ApiErrorResponse) {
          rethrow;
        }
        throw ApiErrorResponse(
          statusCode: response.statusCode,
          message: response.body,
          errorCode: 'HTTP_ERROR_${response.statusCode}',
        );
      }
    }
    return response;
  }
}

/// トークンリフレッシュインターセプター
class TokenRefreshInterceptor implements HttpInterceptor {
  final TokenRefreshManager refreshManager;

  TokenRefreshInterceptor({required this.refreshManager});

  @override
  Future<HttpRequest> onRequest(HttpRequest request, HttpClient client) async {
    final token = await refreshManager.getValidToken();
    final headers = request.headers ?? {};
    if (token != null) {
      headers['Authorization'] = token.authorizationHeader;
    }
    return HttpRequest(
      method: request.method,
      endpoint: request.endpoint,
      body: request.body,
      headers: headers,
      queryParameters: request.queryParameters,
    );
  }

  @override
  Future<HttpResponse> onResponse(
    HttpResponse response,
    HttpClient client,
  ) async {
    return response;
  }
}

/// リトライインターセプター
class RetryInterceptor implements HttpInterceptor {
  @override
  Future<HttpRequest> onRequest(HttpRequest request, HttpClient client) async {
    return request;
  }

  @override
  Future<HttpResponse> onResponse(
    HttpResponse response,
    HttpClient client,
  ) async {
    // リトライ可能なステータスコード
    if (response.statusCode == 429 || response.statusCode == 503) {
      throw Exception('Retryable error: ${response.statusCode}');
    }
    return response;
  }
}
