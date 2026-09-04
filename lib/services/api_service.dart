import '../models/api_models.dart';

/// APIリポジトリインターフェース
abstract class ApiRepository {
  // エンドポイント操作
  Future<void> addEndpoint(ApiEndpoint endpoint);
  Future<ApiEndpoint?> getEndpoint(String endpointId);
  Future<List<ApiEndpoint>> getAllEndpoints();
  Future<List<ApiEndpoint>> getActiveEndpoints();
  Future<void> updateEndpoint(ApiEndpoint endpoint);
  Future<void> deleteEndpoint(String endpointId);

  // リクエスト操作
  Future<void> addRequest(ApiRequest request);
  Future<ApiRequest?> getRequest(String requestId);
  Future<List<ApiRequest>> getEndpointRequests(String endpointId);
  Future<List<ApiRequest>> getFailedRequests();
  Future<void> deleteRequest(String requestId);

  // Webhook操作
  Future<void> addWebhook(WebhookEndpoint webhook);
  Future<WebhookEndpoint?> getWebhook(String webhookId);
  Future<List<WebhookEndpoint>> getAllWebhooks();
  Future<List<WebhookEndpoint>> getActiveWebhooks();
  Future<List<WebhookEndpoint>> getWebhooksByEvent(WebhookEventType eventType);
  Future<void> updateWebhook(WebhookEndpoint webhook);
  Future<void> deleteWebhook(String webhookId);

  // Webhookペイロード操作
  Future<void> addPayload(WebhookPayload payload);
  Future<WebhookPayload?> getPayload(String payloadId);
  Future<List<WebhookPayload>> getWebhookPayloads(String webhookId);
  Future<List<WebhookPayload>> getPendingPayloads();
  Future<void> updatePayload(WebhookPayload payload);
  Future<void> deletePayload(String payloadId);

  // API設定操作
  Future<void> addConfiguration(ApiConfiguration config);
  Future<ApiConfiguration?> getConfiguration(String configId);
  Future<List<ApiConfiguration>> getAllConfigurations();
  Future<void> updateConfiguration(ApiConfiguration config);
  Future<void> deleteConfiguration(String configId);

  // イベント操作
  Future<void> addEvent(WebhookEvent event);
  Future<WebhookEvent?> getEvent(String eventId);
  Future<List<WebhookEvent>> getEventsByType(WebhookEventType eventType);
  Future<void> deleteEvent(String eventId);

  // メトリクス操作
  Future<void> addMetrics(ApiMetrics metrics);
  Future<ApiMetrics?> getMetrics(String metricsId);
  Future<List<ApiMetrics>> getRecentMetrics(int count);
  Future<void> deleteMetrics(String metricsId);

  // レート制限操作
  Future<void> addRateLimit(RateLimitInfo info);
  Future<RateLimitInfo?> getRateLimit(String limitId);
  Future<void> updateRateLimit(RateLimitInfo info);
}

/// メモリ実装のAPIリポジトリ
class MemoryApiRepository implements ApiRepository {
  final Map<String, ApiEndpoint> _endpoints = {};
  final Map<String, ApiRequest> _requests = {};
  final Map<String, WebhookEndpoint> _webhooks = {};
  final Map<String, WebhookPayload> _payloads = {};
  final Map<String, ApiConfiguration> _configurations = {};
  final Map<String, WebhookEvent> _events = {};
  final Map<String, ApiMetrics> _metrics = {};
  final Map<String, RateLimitInfo> _rateLimits = {};

  @override
  Future<void> addEndpoint(ApiEndpoint endpoint) async {
    _endpoints[endpoint.endpointId] = endpoint;
  }

  @override
  Future<ApiEndpoint?> getEndpoint(String endpointId) async {
    return _endpoints[endpointId];
  }

  @override
  Future<List<ApiEndpoint>> getAllEndpoints() async {
    return _endpoints.values.toList();
  }

  @override
  Future<List<ApiEndpoint>> getActiveEndpoints() async {
    return _endpoints.values.where((e) => e.isActive).toList();
  }

  @override
  Future<void> updateEndpoint(ApiEndpoint endpoint) async {
    _endpoints[endpoint.endpointId] = endpoint;
  }

  @override
  Future<void> deleteEndpoint(String endpointId) async {
    _endpoints.remove(endpointId);
  }

  @override
  Future<void> addRequest(ApiRequest request) async {
    _requests[request.requestId] = request;
  }

  @override
  Future<ApiRequest?> getRequest(String requestId) async {
    return _requests[requestId];
  }

  @override
  Future<List<ApiRequest>> getEndpointRequests(String endpointId) async {
    return _requests.values.where((r) => r.endpointId == endpointId).toList();
  }

  @override
  Future<List<ApiRequest>> getFailedRequests() async {
    return _requests.values.where((r) => !r.isSuccessful).toList();
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    _requests.remove(requestId);
  }

  @override
  Future<void> addWebhook(WebhookEndpoint webhook) async {
    _webhooks[webhook.webhookId] = webhook;
  }

  @override
  Future<WebhookEndpoint?> getWebhook(String webhookId) async {
    return _webhooks[webhookId];
  }

  @override
  Future<List<WebhookEndpoint>> getAllWebhooks() async {
    return _webhooks.values.toList();
  }

  @override
  Future<List<WebhookEndpoint>> getActiveWebhooks() async {
    return _webhooks.values.where((w) => w.isActive).toList();
  }

  @override
  Future<List<WebhookEndpoint>> getWebhooksByEvent(WebhookEventType eventType) async {
    return _webhooks.values.where((w) => w.events.contains(eventType)).toList();
  }

  @override
  Future<void> updateWebhook(WebhookEndpoint webhook) async {
    _webhooks[webhook.webhookId] = webhook;
  }

  @override
  Future<void> deleteWebhook(String webhookId) async {
    _webhooks.remove(webhookId);
  }

  @override
  Future<void> addPayload(WebhookPayload payload) async {
    _payloads[payload.payloadId] = payload;
  }

  @override
  Future<WebhookPayload?> getPayload(String payloadId) async {
    return _payloads[payloadId];
  }

  @override
  Future<List<WebhookPayload>> getWebhookPayloads(String webhookId) async {
    return _payloads.values.where((p) => p.webhookId == webhookId).toList();
  }

  @override
  Future<List<WebhookPayload>> getPendingPayloads() async {
    return _payloads.values.where((p) => p.isPending).toList();
  }

  @override
  Future<void> updatePayload(WebhookPayload payload) async {
    _payloads[payload.payloadId] = payload;
  }

  @override
  Future<void> deletePayload(String payloadId) async {
    _payloads.remove(payloadId);
  }

  @override
  Future<void> addConfiguration(ApiConfiguration config) async {
    _configurations[config.configId] = config;
  }

  @override
  Future<ApiConfiguration?> getConfiguration(String configId) async {
    return _configurations[configId];
  }

  @override
  Future<List<ApiConfiguration>> getAllConfigurations() async {
    return _configurations.values.toList();
  }

  @override
  Future<void> updateConfiguration(ApiConfiguration config) async {
    _configurations[config.configId] = config;
  }

  @override
  Future<void> deleteConfiguration(String configId) async {
    _configurations.remove(configId);
  }

  @override
  Future<void> addEvent(WebhookEvent event) async {
    _events[event.eventId] = event;
  }

  @override
  Future<WebhookEvent?> getEvent(String eventId) async {
    return _events[eventId];
  }

  @override
  Future<List<WebhookEvent>> getEventsByType(WebhookEventType eventType) async {
    return _events.values.where((e) => e.eventType == eventType).toList();
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    _events.remove(eventId);
  }

  @override
  Future<void> addMetrics(ApiMetrics metrics) async {
    _metrics[metrics.metricsId] = metrics;
  }

  @override
  Future<ApiMetrics?> getMetrics(String metricsId) async {
    return _metrics[metricsId];
  }

  @override
  Future<List<ApiMetrics>> getRecentMetrics(int count) async {
    return _metrics.values.toList().reversed.take(count).toList();
  }

  @override
  Future<void> deleteMetrics(String metricsId) async {
    _metrics.remove(metricsId);
  }

  @override
  Future<void> addRateLimit(RateLimitInfo info) async {
    _rateLimits[info.limitId] = info;
  }

  @override
  Future<RateLimitInfo?> getRateLimit(String limitId) async {
    return _rateLimits[limitId];
  }

  @override
  Future<void> updateRateLimit(RateLimitInfo info) async {
    _rateLimits[info.limitId] = info;
  }
}

/// HTTPエンジンインターフェース
abstract class HttpEngine {
  Future<ApiRequest> executeRequest(ApiEndpoint endpoint, {dynamic body});
  Future<ApiRequest> retryRequest(ApiRequest request, int retryCount);
  Future<bool> validateEndpoint(ApiEndpoint endpoint);
  Future<Map<String, dynamic>> buildRequestPayload(dynamic data);
  Future<int> calculateRetryDelay(int attemptNumber, RetryPolicy policy);
}

/// メモリ実装のHTTPエンジン
class MemoryHttpEngine implements HttpEngine {
  final ApiRepository _repository;

  MemoryHttpEngine(this._repository);

  @override
  Future<ApiRequest> executeRequest(ApiEndpoint endpoint, {dynamic body}) async {
    final requestId = 'req_${DateTime.now().millisecondsSinceEpoch}';
    final sentAt = DateTime.now();

    // シミュレーション: ランダムに成功/失敗
    await Future.delayed(Duration(milliseconds: 100));
    
    final isSuccess = DateTime.now().millisecond % 3 != 0; // 66%成功率
    final statusCode = isSuccess ? 200 : 500;
    final responseBody = isSuccess ? '{"status":"success"}' : '{"error":"Internal Server Error"}';
    final receivedAt = DateTime.now();

    final request = ApiRequest(
      requestId: requestId,
      endpointId: endpoint.endpointId,
      method: endpoint.httpMethod,
      url: endpoint.fullUrl,
      headers: endpoint.headers,
      body: body,
      sentAt: sentAt,
      responseStatusCode: statusCode,
      responseBody: responseBody,
      receivedAt: receivedAt,
      isSuccessful: isSuccess,
      errorMessage: isSuccess ? null : 'Server error',
    );

    await _repository.addRequest(request);
    return request;
  }

  @override
  Future<ApiRequest> retryRequest(ApiRequest request, int retryCount) async {
    final updatedRequest = ApiRequest(
      requestId: 'req_${DateTime.now().millisecondsSinceEpoch}',
      endpointId: request.endpointId,
      method: request.method,
      url: request.url,
      headers: request.headers,
      body: request.body,
      sentAt: DateTime.now(),
      responseStatusCode: 200,
      responseBody: '{"status":"success"}',
      receivedAt: DateTime.now().add(Duration(milliseconds: 50)),
      isSuccessful: true,
    );

    await _repository.addRequest(updatedRequest);
    return updatedRequest;
  }

  @override
  Future<bool> validateEndpoint(ApiEndpoint endpoint) async {
    return endpoint.isValid && endpoint.timeoutSeconds > 0;
  }

  @override
  Future<Map<String, dynamic>> buildRequestPayload(dynamic data) async {
    if (data is Map<String, dynamic>) {
      return data;
    }
    return {'data': data};
  }

  @override
  Future<int> calculateRetryDelay(int attemptNumber, RetryPolicy policy) async {
    switch (policy) {
      case RetryPolicy.noRetry:
        return 0;
      case RetryPolicy.exponential:
        return 100 * (1 << attemptNumber);
      case RetryPolicy.linear:
        return 100 * attemptNumber;
      case RetryPolicy.fibonacci:
        return _fibonacci(attemptNumber) * 100;
    }
  }

  int _fibonacci(int n) {
    if (n <= 1) return n;
    int a = 0, b = 1;
    for (int i = 2; i <= n; i++) {
      final temp = a + b;
      a = b;
      b = temp;
    }
    return b;
  }
}

/// Webhookエンジンインターフェース
abstract class WebhookEngine {
  Future<void> triggerWebhook(WebhookEndpoint webhook, WebhookPayload payload);
  Future<void> retryFailedPayloads(String webhookId);
  Future<bool> validateSignature(String payload, String signature, String secret);
  Future<String> generateSignature(String payload, String secret);
  Future<List<WebhookEndpoint>> getWebhooksForEvent(WebhookEventType eventType);
}

/// メモリ実装のWebhookエンジン
class MemoryWebhookEngine implements WebhookEngine {
  final ApiRepository _repository;

  MemoryWebhookEngine(this._repository);

  @override
  Future<void> triggerWebhook(WebhookEndpoint webhook, WebhookPayload payload) async {
    // シミュレーション
    await Future.delayed(Duration(milliseconds: 50));
    
    final isSuccess = DateTime.now().millisecond % 2 == 0; // 50%成功率
    final status = isSuccess 
      ? WebhookPayloadStatus.delivered 
      : WebhookPayloadStatus.failed;

    final updatedPayload = WebhookPayload(
      payloadId: payload.payloadId,
      webhookId: payload.webhookId,
      eventType: payload.eventType,
      triggeredAt: payload.triggeredAt,
      data: payload.data,
      signature: payload.signature,
      attemptCount: payload.attemptCount + 1,
      status: status,
      lastError: isSuccess ? null : 'Connection timeout',
    );

    await _repository.updatePayload(updatedPayload);
  }

  @override
  Future<void> retryFailedPayloads(String webhookId) async {
    final payloads = await _repository.getWebhookPayloads(webhookId);
    for (final payload in payloads.where((p) => p.isFailed && p.attemptCount < 3)) {
      final webhook = await _repository.getWebhook(webhookId);
      if (webhook != null) {
        await triggerWebhook(webhook, payload);
      }
    }
  }

  @override
  Future<bool> validateSignature(String payload, String signature, String secret) async {
    final computed = await generateSignature(payload, secret);
    return computed == signature;
  }

  @override
  Future<String> generateSignature(String payload, String secret) async {
    // シミュレーション: SHA256署名
    return 'sha256=${payload.hashCode}_${secret.hashCode}';
  }

  @override
  Future<List<WebhookEndpoint>> getWebhooksForEvent(WebhookEventType eventType) async {
    return await _repository.getWebhooksByEvent(eventType);
  }
}

/// APIマネージャーインターフェース
abstract class ApiManager {
  Future<void> createEndpoint(String name, String baseUrl, HttpMethod method, String path);
  Future<void> registerWebhook(String targetUrl, List<WebhookEventType> events);
  Future<ApiRequest> callEndpoint(String endpointId, {dynamic body});
  Future<void> triggerWebhookEvent(WebhookEventType eventType, Map<String, dynamic> payload);
  Future<ApiMetrics> calculateMetrics(DateTime start, DateTime end);
  Future<ApiReport> generateReport(DateTime start, DateTime end);
  Future<void> setupRateLimit(String configId, int requestsPerMinute);
  Future<bool> checkRateLimit(String configId);
}

/// メモリ実装のAPIマネージャー
class MemoryApiManager implements ApiManager {
  final ApiRepository _repository;
  final HttpEngine _httpEngine;
  final WebhookEngine _webhookEngine;

  MemoryApiManager(this._repository, this._httpEngine, this._webhookEngine);

  @override
  Future<void> createEndpoint(String name, String baseUrl, HttpMethod method, String path) async {
    final endpointId = 'ep_${DateTime.now().millisecondsSinceEpoch}';
    final endpoint = ApiEndpoint(
      endpointId: endpointId,
      name: name,
      baseUrl: baseUrl,
      httpMethod: method,
      path: path,
      headers: {'Content-Type': 'application/json'},
      timeoutSeconds: 30,
      createdAt: DateTime.now(),
    );
    await _repository.addEndpoint(endpoint);
  }

  @override
  Future<void> registerWebhook(String targetUrl, List<WebhookEventType> events) async {
    final webhookId = 'wh_${DateTime.now().millisecondsSinceEpoch}';
    final webhook = WebhookEndpoint(
      webhookId: webhookId,
      targetUrl: targetUrl,
      events: events,
      retryPolicy: RetryPolicy.exponential,
      maxRetries: 3,
      createdAt: DateTime.now(),
    );
    await _repository.addWebhook(webhook);
  }

  @override
  Future<ApiRequest> callEndpoint(String endpointId, {dynamic body}) async {
    final endpoint = await _repository.getEndpoint(endpointId);
    if (endpoint == null) {
      throw Exception('Endpoint not found: $endpointId');
    }
    return await _httpEngine.executeRequest(endpoint, body: body);
  }

  @override
  Future<void> triggerWebhookEvent(WebhookEventType eventType, Map<String, dynamic> payload) async {
    final webhooks = await _webhookEngine.getWebhooksForEvent(eventType);
    for (final webhook in webhooks) {
      final payloadId = 'pl_${DateTime.now().millisecondsSinceEpoch}';
      final webhookPayload = WebhookPayload(
        payloadId: payloadId,
        webhookId: webhook.webhookId,
        eventType: eventType,
        triggeredAt: DateTime.now(),
        data: payload,
      );
      await _repository.addPayload(webhookPayload);
      await _webhookEngine.triggerWebhook(webhook, webhookPayload);
    }
  }

  @override
  Future<ApiMetrics> calculateMetrics(DateTime start, DateTime end) async {
    final requests = await _repository.getAllEndpoints()
        .then((_) => _repository.getFailedRequests());
    final successful = await _repository.getAllEndpoints()
        .then((_) async {
          final all = <ApiRequest>[];
          for (final ep in await _repository.getAllEndpoints()) {
            all.addAll(await _repository.getEndpointRequests(ep.endpointId));
          }
          return all.where((r) => r.isSuccessful).length;
        });

    return ApiMetrics(
      metricsId: 'metrics_${DateTime.now().millisecondsSinceEpoch}',
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      averageResponseTimeMs: 150.0,
      totalWebhooks: 0,
      successfulWebhooks: 0,
      failedWebhooks: 0,
      periodStart: start,
      periodEnd: end,
    );
  }

  @override
  Future<ApiReport> generateReport(DateTime start, DateTime end) async {
    final endpoints = await _repository.getAllEndpoints();
    final requests = <ApiRequest>[];
    for (final ep in endpoints) {
      requests.addAll(await _repository.getEndpointRequests(ep.endpointId));
    }
    final payloads = <WebhookPayload>[];
    for (final wh in await _repository.getAllWebhooks()) {
      payloads.addAll(await _repository.getWebhookPayloads(wh.webhookId));
    }
    final metrics = await calculateMetrics(start, end);

    return ApiReport(
      reportId: 'report_${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      periodStart: start,
      periodEnd: end,
      endpoints: endpoints,
      requests: requests,
      webhookPayloads: payloads,
      metrics: metrics,
    );
  }

  @override
  Future<void> setupRateLimit(String configId, int requestsPerMinute) async {
    final limitId = 'limit_${DateTime.now().millisecondsSinceEpoch}';
    final info = RateLimitInfo(
      limitId: limitId,
      configId: configId,
      requestLimit: requestsPerMinute,
      currentCount: 0,
      windowStart: DateTime.now(),
      windowEnd: DateTime.now().add(Duration(minutes: 1)),
    );
    await _repository.addRateLimit(info);
  }

  @override
  Future<bool> checkRateLimit(String configId) async {
    // レート制限チェック実装
    return true;
  }
}

/// APIファサード
class ApiFacade {
  final ApiManager _manager;
  final ApiRepository _repository;
  final HttpEngine _httpEngine;
  final WebhookEngine _webhookEngine;

  ApiFacade(this._manager, this._repository, this._httpEngine, this._webhookEngine);

  /// エンドポイント作成
  Future<void> createEndpoint(String name, String baseUrl, HttpMethod method, String path) =>
      _manager.createEndpoint(name, baseUrl, method, path);

  /// Webhook登録
  Future<void> registerWebhook(String targetUrl, List<WebhookEventType> events) =>
      _manager.registerWebhook(targetUrl, events);

  /// エンドポイント呼び出し
  Future<ApiRequest> callEndpoint(String endpointId, {dynamic body}) =>
      _manager.callEndpoint(endpointId, body: body);

  /// Webhookイベント発火
  Future<void> triggerEvent(WebhookEventType eventType, Map<String, dynamic> payload) =>
      _manager.triggerWebhookEvent(eventType, payload);

  /// メトリクス計算
  Future<ApiMetrics> calculateMetrics(DateTime start, DateTime end) =>
      _manager.calculateMetrics(start, end);

  /// レポート生成
  Future<ApiReport> generateReport(DateTime start, DateTime end) =>
      _manager.generateReport(start, end);

  /// 全エンドポイント取得
  Future<List<ApiEndpoint>> getAllEndpoints() =>
      _repository.getAllEndpoints();

  /// アクティブなWebhook取得
  Future<List<WebhookEndpoint>> getActiveWebhooks() =>
      _repository.getActiveWebhooks();

  /// 保留中のペイロード取得
  Future<List<WebhookPayload>> getPendingPayloads() =>
      _repository.getPendingPayloads();

  /// 失敗リクエスト取得
  Future<List<ApiRequest>> getFailedRequests() =>
      _repository.getFailedRequests();
}
