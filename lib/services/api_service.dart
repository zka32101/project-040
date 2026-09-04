/// API Integration & Webhook Services
///
/// Implements Repository + Engine + Manager + Facade pattern for:
/// - API request/response handling
/// - Webhook management and delivery
/// - Authentication and credentials
/// - Rate limiting and quota management
/// - Integration status tracking

import '../models/api_models.dart';

// ============================================================================
// REPOSITORY INTERFACE & IMPLEMENTATION
// ============================================================================

/// Repository interface for API data persistence
abstract class ApiRepository {
  // API Configuration operations
  Future<void> createApiConfiguration(ApiConfiguration config);
  Future<ApiConfiguration?> getApiConfiguration(String configId);
  Future<List<ApiConfiguration>> getAllConfigurations();
  Future<void> updateApiConfiguration(ApiConfiguration config);
  Future<void> deleteApiConfiguration(String configId);

  // API Credential operations
  Future<void> createApiCredential(ApiCredential credential);
  Future<ApiCredential?> getApiCredential(String credentialId);
  Future<List<ApiCredential>> getCredentialsByConfig(String configId);
  Future<void> updateApiCredential(ApiCredential credential);
  Future<void> deleteApiCredential(String credentialId);

  // Webhook operations
  Future<void> createWebhook(Webhook webhook);
  Future<Webhook?> getWebhook(String webhookId);
  Future<List<Webhook>> getWebhooksByConfig(String configId);
  Future<void> updateWebhook(Webhook webhook);
  Future<void> deleteWebhook(String webhookId);

  // Webhook delivery attempts
  Future<void> recordDeliveryAttempt(WebhookDeliveryAttempt attempt);
  Future<List<WebhookDeliveryAttempt>> getDeliveryAttempts(String webhookId);
  Future<List<WebhookDeliveryAttempt>> getFailedAttempts();

  // API Requests and Responses
  Future<void> recordRequest(ApiRequest request);
  Future<void> recordResponse(ApiResponse response);
  Future<ApiResponse?> getResponse(String responseId);

  // Rate limits
  Future<void> createRateLimit(RateLimit limit);
  Future<RateLimit?> getRateLimit(String rateLimitId);
  Future<void> updateRateLimit(RateLimit limit);

  // Integration status
  Future<void> recordIntegration(ApiIntegration integration);
  Future<ApiIntegration?> getIntegration(String integrationId);
  Future<List<ApiIntegration>> getAllIntegrations();

  // OAuth2
  Future<void> createOAuth2Config(OAuth2Config config);
  Future<OAuth2Config?> getOAuth2Config(String configId);
  Future<void> storeOAuth2Token(OAuth2Token token);
  Future<OAuth2Token?> getOAuth2Token(String tokenId);

  // Statistics
  Future<void> recordApiUsageStats(ApiUsageStats stats);
  Future<ApiUsageStats?> getApiUsageStats(String statsId);
  Future<void> recordWebhookStats(WebhookStats stats);
  Future<WebhookStats?> getWebhookStats(String statsId);

  // Errors
  Future<void> recordApiError(ApiError error);
  Future<List<ApiError>> getRecentErrors(String configId);
}

/// In-memory implementation of ApiRepository
class MemoryApiRepository implements ApiRepository {
  final Map<String, ApiConfiguration> _configs = {};
  final Map<String, ApiCredential> _credentials = {};
  final Map<String, Webhook> _webhooks = {};
  final Map<String, WebhookDeliveryAttempt> _deliveryAttempts = {};
  final Map<String, ApiRequest> _requests = {};
  final Map<String, ApiResponse> _responses = {};
  final Map<String, RateLimit> _rateLimits = {};
  final Map<String, ApiIntegration> _integrations = {};
  final Map<String, OAuth2Config> _oauth2Configs = {};
  final Map<String, OAuth2Token> _oauth2Tokens = {};
  final Map<String, ApiUsageStats> _usageStats = {};
  final Map<String, WebhookStats> _webhookStats = {};
  final Map<String, ApiError> _errors = {};

  @override
  Future<void> createApiConfiguration(ApiConfiguration config) async =>
      _configs[config.configId] = config;

  @override
  Future<ApiConfiguration?> getApiConfiguration(String configId) async =>
      _configs[configId];

  @override
  Future<List<ApiConfiguration>> getAllConfigurations() async =>
      _configs.values.toList();

  @override
  Future<void> updateApiConfiguration(ApiConfiguration config) async =>
      _configs[config.configId] = config;

  @override
  Future<void> deleteApiConfiguration(String configId) async =>
      _configs.remove(configId);

  @override
  Future<void> createApiCredential(ApiCredential credential) async =>
      _credentials[credential.credentialId] = credential;

  @override
  Future<ApiCredential?> getApiCredential(String credentialId) async =>
      _credentials[credentialId];

  @override
  Future<List<ApiCredential>> getCredentialsByConfig(String configId) async =>
      _credentials.values
          .where((c) => c.configId == configId)
          .toList();

  @override
  Future<void> updateApiCredential(ApiCredential credential) async =>
      _credentials[credential.credentialId] = credential;

  @override
  Future<void> deleteApiCredential(String credentialId) async =>
      _credentials.remove(credentialId);

  @override
  Future<void> createWebhook(Webhook webhook) async =>
      _webhooks[webhook.webhookId] = webhook;

  @override
  Future<Webhook?> getWebhook(String webhookId) async =>
      _webhooks[webhookId];

  @override
  Future<List<Webhook>> getWebhooksByConfig(String configId) async =>
      _webhooks.values
          .where((w) => w.configId == configId)
          .toList();

  @override
  Future<void> updateWebhook(Webhook webhook) async =>
      _webhooks[webhook.webhookId] = webhook;

  @override
  Future<void> deleteWebhook(String webhookId) async =>
      _webhooks.remove(webhookId);

  @override
  Future<void> recordDeliveryAttempt(WebhookDeliveryAttempt attempt) async =>
      _deliveryAttempts[attempt.attemptId] = attempt;

  @override
  Future<List<WebhookDeliveryAttempt>> getDeliveryAttempts(
          String webhookId) async =>
      _deliveryAttempts.values
          .where((a) => a.webhookId == webhookId)
          .toList();

  @override
  Future<List<WebhookDeliveryAttempt>> getFailedAttempts() async =>
      _deliveryAttempts.values
          .where((a) => a.hasFailed)
          .toList();

  @override
  Future<void> recordRequest(ApiRequest request) async =>
      _requests[request.requestId] = request;

  @override
  Future<void> recordResponse(ApiResponse response) async =>
      _responses[response.responseId] = response;

  @override
  Future<ApiResponse?> getResponse(String responseId) async =>
      _responses[responseId];

  @override
  Future<void> createRateLimit(RateLimit limit) async =>
      _rateLimits[limit.rateLimitId] = limit;

  @override
  Future<RateLimit?> getRateLimit(String rateLimitId) async =>
      _rateLimits[rateLimitId];

  @override
  Future<void> updateRateLimit(RateLimit limit) async =>
      _rateLimits[limit.rateLimitId] = limit;

  @override
  Future<void> recordIntegration(ApiIntegration integration) async =>
      _integrations[integration.integrationId] = integration;

  @override
  Future<ApiIntegration?> getIntegration(String integrationId) async =>
      _integrations[integrationId];

  @override
  Future<List<ApiIntegration>> getAllIntegrations() async =>
      _integrations.values.toList();

  @override
  Future<void> createOAuth2Config(OAuth2Config config) async =>
      _oauth2Configs[config.configId] = config;

  @override
  Future<OAuth2Config?> getOAuth2Config(String configId) async =>
      _oauth2Configs[configId];

  @override
  Future<void> storeOAuth2Token(OAuth2Token token) async =>
      _oauth2Tokens[token.tokenId] = token;

  @override
  Future<OAuth2Token?> getOAuth2Token(String tokenId) async =>
      _oauth2Tokens[tokenId];

  @override
  Future<void> recordApiUsageStats(ApiUsageStats stats) async =>
      _usageStats[stats.statsId] = stats;

  @override
  Future<ApiUsageStats?> getApiUsageStats(String statsId) async =>
      _usageStats[statsId];

  @override
  Future<void> recordWebhookStats(WebhookStats stats) async =>
      _webhookStats[stats.statsId] = stats;

  @override
  Future<WebhookStats?> getWebhookStats(String statsId) async =>
      _webhookStats[statsId];

  @override
  Future<void> recordApiError(ApiError error) async =>
      _errors[error.errorId] = error;

  @override
  Future<List<ApiError>> getRecentErrors(String configId) async =>
      _errors.values
          .where((e) => e.configId == configId && e.isRecent)
          .toList();
}

// ============================================================================
// ENGINES
// ============================================================================

/// API Request Engine - handles request sending and response processing
class ApiRequestEngine {
  final ApiRepository repository;

  ApiRequestEngine(this.repository);

  Future<ApiResponse> sendRequest(ApiRequest request) async {
    await repository.recordRequest(request);
    
    final response = ApiResponse(
      responseId: 'resp_${DateTime.now().millisecondsSinceEpoch}',
      requestId: request.requestId,
      statusCode: 200,
      headers: {'content-type': 'application/json'},
      body: {'status': 'success'},
      contentLength: 20,
      receivedAt: DateTime.now(),
    );

    await repository.recordResponse(response);
    return response;
  }

  Future<void> retryFailedRequests() async {
    // Implement retry logic
  }

  Future<ApiIntegrationStatus> checkIntegrationStatus(
      String configId) async {
    final config = await repository.getApiConfiguration(configId);
    if (config == null || !config.isEnabled) {
      return ApiIntegrationStatus.disconnected;
    }
    return ApiIntegrationStatus.connected;
  }
}

/// Webhook Delivery Engine - manages webhook event delivery
class WebhookDeliveryEngine {
  final ApiRepository repository;

  WebhookDeliveryEngine(this.repository);

  Future<void> deliverWebhookEvent(
      Webhook webhook, WebhookEventType eventType) async {
    if (!webhook.isActive) return;

    final attempt = WebhookDeliveryAttempt(
      attemptId: 'attempt_${DateTime.now().millisecondsSinceEpoch}',
      webhookId: webhook.webhookId,
      eventType: eventType,
      status: DeliveryAttemptStatus.succeeded,
      statusCode: 200,
      retryCount: 0,
      attemptedAt: DateTime.now(),
      completedAt: DateTime.now(),
    );

    await repository.recordDeliveryAttempt(attempt);
  }

  Future<void> retryFailedDeliveries() async {
    final failed = await repository.getFailedAttempts();
    for (final attempt in failed) {
      if (attempt.retryCount < 3) {
        // Implement retry logic
      }
    }
  }

  Future<double> getWebhookDeliveryRate(String webhookId) async {
    final attempts = await repository.getDeliveryAttempts(webhookId);
    if (attempts.isEmpty) return 0.0;
    final successful = attempts.where((a) => a.isSuccessful).length;
    return (successful / attempts.length) * 100;
  }
}

/// Rate Limit Engine - manages API rate limiting
class RateLimitEngine {
  final ApiRepository repository;

  RateLimitEngine(this.repository);

  Future<bool> isRateLimited(String configId) async {
    final limit = await repository.getRateLimit(configId);
    return limit?.isExceeded ?? false;
  }

  Future<void> updateQuota(String rateLimitId) async {
    final limit = await repository.getRateLimit(rateLimitId);
    if (limit != null) {
      final updated = RateLimit(
        rateLimitId: limit.rateLimitId,
        configId: limit.configId,
        requestsPerWindow: limit.requestsPerWindow,
        windowSizeSeconds: limit.windowSizeSeconds,
        strategy: limit.strategy,
        resetAt: limit.resetAt,
        remainingRequests: limit.remainingRequests - 1,
        isActive: limit.isActive,
      );
      await repository.updateRateLimit(updated);
    }
  }

  Future<int?> getSecondsUntilReset(String rateLimitId) async {
    final limit = await repository.getRateLimit(rateLimitId);
    return limit?.secondsUntilReset;
  }
}

// ============================================================================
// MANAGER
// ============================================================================

/// API Manager - coordinates operations
class ApiManager {
  final ApiRepository repository;
  final ApiRequestEngine requestEngine;
  final WebhookDeliveryEngine webhookEngine;
  final RateLimitEngine rateLimitEngine;

  ApiManager(
    this.repository,
    this.requestEngine,
    this.webhookEngine,
    this.rateLimitEngine,
  );

  Future<ApiConfiguration> registerApiConfig(
    String apiName,
    String baseUrl,
    AuthType authType,
  ) async {
    final config = ApiConfiguration(
      configId: 'config_${DateTime.now().millisecondsSinceEpoch}',
      apiName: apiName,
      baseUrl: baseUrl,
      defaultMethod: HttpMethod.get,
      contentType: ContentType.json,
      authType: authType,
      headers: {},
      createdAt: DateTime.now(),
    );
    await repository.createApiConfiguration(config);
    return config;
  }

  Future<Webhook> registerWebhook(
    String configId,
    String url,
    List<WebhookEventType> events,
  ) async {
    final webhook = Webhook(
      webhookId: 'webhook_${DateTime.now().millisecondsSinceEpoch}',
      configId: configId,
      url: url,
      events: events,
      status: WebhookStatus.active,
      createdAt: DateTime.now(),
    );
    await repository.createWebhook(webhook);
    return webhook;
  }

  Future<void> triggerWebhook(
    String webhookId,
    WebhookEventType eventType,
  ) async {
    final webhook = await repository.getWebhook(webhookId);
    if (webhook != null) {
      await webhookEngine.deliverWebhookEvent(webhook, eventType);
    }
  }

  Future<ApiReport> generateReport() async {
    final integrations = await repository.getAllIntegrations();
    final webhookStatsList = <WebhookStats>[];
    final usageStatsList = <ApiUsageStats>[];

    return ApiReport(
      reportId: 'report_${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      integrations: integrations,
      webhookStats: webhookStatsList,
      usageStats: usageStatsList,
    );
  }
}

// ============================================================================
// FACADE
// ============================================================================

/// API Facade - unified interface for API operations
class ApiFacade {
  late final ApiRepository _repository;
  late final ApiRequestEngine _requestEngine;
  late final WebhookDeliveryEngine _webhookEngine;
  late final RateLimitEngine _rateLimitEngine;
  late final ApiManager _manager;

  ApiFacade() {
    _repository = MemoryApiRepository();
    _requestEngine = ApiRequestEngine(_repository);
    _webhookEngine = WebhookDeliveryEngine(_repository);
    _rateLimitEngine = RateLimitEngine(_repository);
    _manager = ApiManager(
      _repository,
      _requestEngine,
      _webhookEngine,
      _rateLimitEngine,
    );
  }

  // API Configuration
  Future<ApiConfiguration> registerApiConfig(
    String apiName,
    String baseUrl,
    AuthType authType,
  ) => _manager.registerApiConfig(apiName, baseUrl, authType);

  Future<ApiConfiguration?> getApiConfig(String configId) =>
      _repository.getApiConfiguration(configId);

  Future<List<ApiConfiguration>> getAllApiConfigs() =>
      _repository.getAllConfigurations();

  // Webhooks
  Future<Webhook> registerWebhook(
    String configId,
    String url,
    List<WebhookEventType> events,
  ) => _manager.registerWebhook(configId, url, events);

  Future<Webhook?> getWebhook(String webhookId) =>
      _repository.getWebhook(webhookId);

  Future<void> triggerWebhook(
    String webhookId,
    WebhookEventType eventType,
  ) => _manager.triggerWebhook(webhookId, eventType);

  // API Credentials
  Future<void> storeCredential(ApiCredential credential) =>
      _repository.createApiCredential(credential);

  Future<ApiCredential?> getCredential(String credentialId) =>
      _repository.getApiCredential(credentialId);

  // Rate Limiting
  Future<bool> isRateLimited(String configId) =>
      _rateLimitEngine.isRateLimited(configId);

  Future<int?> getSecondsUntilReset(String rateLimitId) =>
      _rateLimitEngine.getSecondsUntilReset(rateLimitId);

  // Reporting
  Future<ApiReport> generateReport() => _manager.generateReport();

  // Integration Status
  Future<ApiIntegrationStatus> checkStatus(String configId) =>
      _requestEngine.checkIntegrationStatus(configId);
}
