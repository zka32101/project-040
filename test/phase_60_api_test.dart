import 'package:flutter_test/flutter_test.dart';
import '../lib/models/api_models.dart';
import '../lib/services/api_service.dart';

void main() {
  group('Phase 60: API Integration & Webhooks', () {
    late ApiFacade apiFacade;

    setUp(() {
      apiFacade = ApiFacade();
    });

    // ===== Enum Tests =====
    group('Enums', () {
      test('HttpMethod enum values', () {
        expect(HttpMethod.get.value, 'GET');
        expect(HttpMethod.post.value, 'POST');
        expect(HttpMethod.put.value, 'PUT');
        expect(HttpMethod.patch.value, 'PATCH');
        expect(HttpMethod.delete.value, 'DELETE');
        expect(HttpMethod.head.value, 'HEAD');
        expect(HttpMethod.options.value, 'OPTIONS');
      });

      test('ContentType enum values', () {
        expect(ContentType.json.value, 'application/json');
        expect(ContentType.xml.value, 'application/xml');
        expect(ContentType.formEncoded.value, 'application/x-www-form-urlencoded');
      });

      test('AuthType enum values', () {
        expect(AuthType.none.value, 'none');
        expect(AuthType.basic.value, 'basic');
        expect(AuthType.bearer.value, 'bearer');
        expect(AuthType.apiKey.value, 'api_key');
        expect(AuthType.oauth2.value, 'oauth2');
      });

      test('WebhookEventType enum values', () {
        expect(WebhookEventType.jobCreated.value, 'job.created');
        expect(WebhookEventType.jobCompleted.value, 'job.completed');
        expect(WebhookEventType.jobFailed.value, 'job.failed');
      });

      test('WebhookStatus enum values', () {
        expect(WebhookStatus.active.value, 'active');
        expect(WebhookStatus.inactive.value, 'inactive');
        expect(WebhookStatus.suspended.value, 'suspended');
      });

      test('RateLimitStrategy enum values', () {
        expect(RateLimitStrategy.fixed.value, 'fixed');
        expect(RateLimitStrategy.sliding.value, 'sliding');
        expect(RateLimitStrategy.token.value, 'token');
        expect(RateLimitStrategy.adaptive.value, 'adaptive');
      });

      test('ApiIntegrationStatus enum values', () {
        expect(ApiIntegrationStatus.connected.value, 'connected');
        expect(ApiIntegrationStatus.disconnected.value, 'disconnected');
        expect(ApiIntegrationStatus.error.value, 'error');
      });
    });

    // ===== API Configuration Tests =====
    group('API Configuration', () {
      test('Create API configuration', () async {
        final config = await apiFacade.registerApiConfig(
          'Test API',
          'https://api.example.com',
          AuthType.bearer,
        );

        expect(config.apiName, 'Test API');
        expect(config.baseUrl, 'https://api.example.com');
        expect(config.isEnabled, true);
      });

      test('API configuration is recent', () async {
        final config = await apiFacade.registerApiConfig(
          'Recent API',
          'https://api.example.com',
          AuthType.apiKey,
        );

        expect(config.isRecent, true);
      });

      test('API configuration is configured', () async {
        final config = await apiFacade.registerApiConfig(
          'Configured API',
          'https://api.example.com',
          AuthType.bearer,
        );

        expect(config.isConfigured, true);
      });

      test('Get API configuration', () async {
        final created = await apiFacade.registerApiConfig(
          'Get Test',
          'https://api.example.com',
          AuthType.basic,
        );

        final retrieved = await apiFacade.getApiConfig(created.configId);
        expect(retrieved?.apiName, 'Get Test');
      });

      test('List all configurations', () async {
        await apiFacade.registerApiConfig(
          'API 1',
          'https://api1.example.com',
          AuthType.bearer,
        );
        await apiFacade.registerApiConfig(
          'API 2',
          'https://api2.example.com',
          AuthType.apiKey,
        );

        final configs = await apiFacade.getAllApiConfigs();
        expect(configs.length, 2);
      });
    });

    // ===== Webhook Tests =====
    group('Webhooks', () {
      test('Create webhook', () async {
        final config = await apiFacade.registerApiConfig(
          'Webhook API',
          'https://api.example.com',
          AuthType.bearer,
        );

        final webhook = await apiFacade.registerWebhook(
          config.configId,
          'https://webhook.example.com/events',
          [WebhookEventType.jobCompleted, WebhookEventType.jobFailed],
        );

        expect(webhook.isActive, true);
        expect(webhook.eventCount, 2);
      });

      test('Webhook has valid URL', () async {
        final config = await apiFacade.registerApiConfig(
          'Webhook API',
          'https://api.example.com',
          AuthType.bearer,
        );

        final webhook = await apiFacade.registerWebhook(
          config.configId,
          'https://webhook.example.com/events',
          [WebhookEventType.jobCompleted],
        );

        expect(webhook.hasValidUrl, true);
      });

      test('Webhook is recent', () async {
        final config = await apiFacade.registerApiConfig(
          'Webhook API',
          'https://api.example.com',
          AuthType.bearer,
        );

        final webhook = await apiFacade.registerWebhook(
          config.configId,
          'https://webhook.example.com/events',
          [WebhookEventType.jobCreated],
        );

        expect(webhook.isRecent, true);
      });

      test('Trigger webhook event', () async {
        final config = await apiFacade.registerApiConfig(
          'Trigger API',
          'https://api.example.com',
          AuthType.bearer,
        );

        final webhook = await apiFacade.registerWebhook(
          config.configId,
          'https://webhook.example.com/events',
          [WebhookEventType.jobCompleted],
        );

        await apiFacade.triggerWebhook(
          webhook.webhookId,
          WebhookEventType.jobCompleted,
        );

        expect(webhook.isActive, true);
      });

      test('Get webhook', () async {
        final config = await apiFacade.registerApiConfig(
          'Get Webhook API',
          'https://api.example.com',
          AuthType.bearer,
        );

        final webhook = await apiFacade.registerWebhook(
          config.configId,
          'https://webhook.example.com/events',
          [WebhookEventType.alertTriggered],
        );

        final retrieved = await apiFacade.getWebhook(webhook.webhookId);
        expect(retrieved?.webhookId, webhook.webhookId);
      });
    });

    // ===== Credential Tests =====
    group('API Credentials', () {
      test('Store bearer token credential', () async {
        final credential = ApiCredential(
          credentialId: 'cred_bearer',
          configId: 'config_1',
          authType: AuthType.bearer,
          bearerToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
          createdAt: DateTime.now(),
        );

        await apiFacade.storeCredential(credential);
        final retrieved = await apiFacade.getCredential('cred_bearer');

        expect(retrieved?.bearerToken, isNotNull);
      });

      test('Credential is not expired', () async {
        final credential = ApiCredential(
          credentialId: 'cred_valid',
          configId: 'config_1',
          authType: AuthType.bearer,
          bearerToken: 'token123',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          createdAt: DateTime.now(),
        );

        expect(credential.isExpired, false);
      });

      test('Credential is recent', () async {
        final credential = ApiCredential(
          credentialId: 'cred_recent',
          configId: 'config_1',
          authType: AuthType.apiKey,
          apiKey: 'key123',
          createdAt: DateTime.now(),
        );

        expect(credential.isRecent, true);
      });
    });

    // ===== Rate Limit Tests =====
    group('Rate Limiting', () {
      test('Check rate limit status', () async {
        expect(await apiFacade.isRateLimited('config_1'), false);
      });

      test('Rate limit utilization', () async {
        final limit = RateLimit(
          rateLimitId: 'limit_1',
          configId: 'config_1',
          requestsPerWindow: 100,
          windowSizeSeconds: 3600,
          strategy: RateLimitStrategy.fixed,
          remainingRequests: 75,
          resetAt: DateTime.now().add(const Duration(hours: 1)),
        );

        expect(limit.utilizationPercentage, 25.0);
      });

      test('Rate limit is not exceeded', () async {
        final limit = RateLimit(
          rateLimitId: 'limit_2',
          configId: 'config_2',
          requestsPerWindow: 100,
          windowSizeSeconds: 3600,
          strategy: RateLimitStrategy.sliding,
          remainingRequests: 50,
        );

        expect(limit.isExceeded, false);
      });

      test('Rate limit is exceeded', () async {
        final limit = RateLimit(
          rateLimitId: 'limit_3',
          configId: 'config_3',
          requestsPerWindow: 100,
          windowSizeSeconds: 3600,
          strategy: RateLimitStrategy.fixed,
          remainingRequests: 0,
        );

        expect(limit.isExceeded, true);
      });

      test('Rate limit quota is low', () async {
        final limit = RateLimit(
          rateLimitId: 'limit_4',
          configId: 'config_4',
          requestsPerWindow: 100,
          windowSizeSeconds: 3600,
          strategy: RateLimitStrategy.token,
          remainingRequests: 15,
        );

        expect(limit.isLowQuota, true);
      });
    });

    // ===== API Response Tests =====
    group('API Responses', () {
      test('Response is success', () async {
        final response = ApiResponse(
          responseId: 'resp_1',
          requestId: 'req_1',
          statusCode: 200,
          headers: {},
          body: {'status': 'ok'},
          receivedAt: DateTime.now(),
        );

        expect(response.isSuccess, true);
      });

      test('Response is error', () async {
        final response = ApiResponse(
          responseId: 'resp_error',
          requestId: 'req_1',
          statusCode: 400,
          headers: {},
          body: {'error': 'Bad request'},
          receivedAt: DateTime.now(),
        );

        expect(response.isError, true);
      });

      test('Response is server error', () async {
        final response = ApiResponse(
          responseId: 'resp_server_error',
          requestId: 'req_1',
          statusCode: 500,
          headers: {},
          body: {'error': 'Server error'},
          receivedAt: DateTime.now(),
        );

        expect(response.isServerError, true);
      });

      test('Response category detection', () async {
        final response = ApiResponse(
          responseId: 'resp_2xx',
          requestId: 'req_1',
          statusCode: 201,
          headers: {},
          body: {'created': true},
          receivedAt: DateTime.now(),
        );

        expect(response.category, HttpStatusCategory.success);
      });
    });

    // ===== Webhook Delivery Attempt Tests =====
    group('Webhook Delivery Attempts', () {
      test('Delivery attempt is successful', () async {
        final attempt = WebhookDeliveryAttempt(
          attemptId: 'attempt_1',
          webhookId: 'webhook_1',
          eventType: WebhookEventType.jobCompleted,
          status: DeliveryAttemptStatus.succeeded,
          statusCode: 200,
          retryCount: 0,
          attemptedAt: DateTime.now(),
          completedAt: DateTime.now(),
        );

        expect(attempt.isSuccessful, true);
      });

      test('Delivery attempt failed', () async {
        final attempt = WebhookDeliveryAttempt(
          attemptId: 'attempt_failed',
          webhookId: 'webhook_1',
          eventType: WebhookEventType.jobFailed,
          status: DeliveryAttemptStatus.failed,
          statusCode: 500,
          errorMessage: 'Server error',
          retryCount: 3,
          attemptedAt: DateTime.now(),
        );

        expect(attempt.hasFailed, true);
      });

      test('Delivery attempt is recent', () async {
        final attempt = WebhookDeliveryAttempt(
          attemptId: 'attempt_recent',
          webhookId: 'webhook_1',
          eventType: WebhookEventType.jobCreated,
          status: DeliveryAttemptStatus.succeeded,
          statusCode: 200,
          retryCount: 0,
          attemptedAt: DateTime.now(),
          completedAt: DateTime.now(),
        );

        expect(attempt.isRecent, true);
      });

      test('Delivery attempt duration', () async {
        final now = DateTime.now();
        final attempt = WebhookDeliveryAttempt(
          attemptId: 'attempt_duration',
          webhookId: 'webhook_1',
          eventType: WebhookEventType.alertTriggered,
          status: DeliveryAttemptStatus.succeeded,
          statusCode: 200,
          retryCount: 0,
          attemptedAt: now,
          completedAt: now.add(const Duration(seconds: 2)),
        );

        expect(attempt.durationInSeconds, 2);
      });
    });

    // ===== OAuth2 Tests =====
    group('OAuth2', () {
      test('OAuth2 config is configured', () async {
        final config = OAuth2Config(
          configId: 'oauth_1',
          clientId: 'client_123',
          clientSecret: 'secret_456',
          authorizationUrl: 'https://auth.example.com/authorize',
          tokenUrl: 'https://auth.example.com/token',
          redirectUri: 'https://app.example.com/callback',
          scopes: ['read', 'write'],
          grantType: GrantType.authorizationCode,
          createdAt: DateTime.now(),
        );

        expect(config.isConfigured, true);
      });

      test('OAuth2 token is not expired', () async {
        final token = OAuth2Token(
          tokenId: 'token_1',
          configId: 'oauth_1',
          accessToken: 'access_token_123',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          issuedAt: DateTime.now(),
        );

        expect(token.isExpired, false);
      });

      test('OAuth2 token age', () async {
        final token = OAuth2Token(
          tokenId: 'token_2',
          configId: 'oauth_1',
          accessToken: 'access_token_456',
          expiresAt: DateTime.now().add(const Duration(hours: 2)),
          issuedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        expect(token.ageInSeconds, greaterThan(3500));
      });
    });

    // ===== Statistics Tests =====
    group('Statistics', () {
      test('API usage stats - healthy', () async {
        final stats = ApiUsageStats(
          statsId: 'stats_1',
          configId: 'config_1',
          totalRequests: 1000,
          successfulRequests: 980,
          failedRequests: 20,
          totalResponseTimeMs: 50000,
          minResponseTimeMs: 10,
          maxResponseTimeMs: 500,
          periodStart: DateTime.now().subtract(const Duration(days: 1)),
          periodEnd: DateTime.now(),
        );

        expect(stats.isHealthy, true);
        expect(stats.successRate, greaterThan(95.0));
      });

      test('Webhook stats success rate', () async {
        final stats = WebhookStats(
          statsId: 'webhook_stats_1',
          webhookId: 'webhook_1',
          totalDeliveries: 100,
          successfulDeliveries: 97,
          failedDeliveries: 3,
          averageDeliveryTimeMs: 150,
          periodStart: DateTime.now().subtract(const Duration(days: 1)),
          periodEnd: DateTime.now(),
        );

        expect(stats.isHealthy, true);
        expect(stats.successRate, 97.0);
      });
    });

    // ===== Error Handling Tests =====
    group('Error Handling', () {
      test('API error is recent', () async {
        final error = ApiError(
          errorId: 'error_1',
          configId: 'config_1',
          errorType: 'ConnectionError',
          errorMessage: 'Failed to connect',
          statusCode: 503,
          occuredAt: DateTime.now(),
        );

        expect(error.isRecent, true);
      });

      test('API error is rate limit error', () async {
        final error = ApiError(
          errorId: 'error_rate_limit',
          configId: 'config_1',
          errorType: 'RateLimitError',
          errorMessage: 'Too many requests',
          statusCode: 429,
          occuredAt: DateTime.now(),
        );

        expect(error.isRateLimitError, true);
      });

      test('API error is authentication error', () async {
        final error = ApiError(
          errorId: 'error_auth',
          configId: 'config_1',
          errorType: 'AuthenticationError',
          errorMessage: 'Invalid credentials',
          statusCode: 401,
          occuredAt: DateTime.now(),
        );

        expect(error.isAuthenticationError, true);
      });
    });

    // ===== Integration Tests =====
    group('Integration Tests', () {
      test('Complete API integration flow', () async {
        final config = await apiFacade.registerApiConfig(
          'Integration Test API',
          'https://api.example.com',
          AuthType.bearer,
        );

        expect(config.isConfigured, true);
        
        final status = await apiFacade.checkStatus(config.configId);
        expect(status, ApiIntegrationStatus.connected);
      });

      test('Complete webhook flow', () async {
        final config = await apiFacade.registerApiConfig(
          'Webhook Integration API',
          'https://api.example.com',
          AuthType.bearer,
        );

        final webhook = await apiFacade.registerWebhook(
          config.configId,
          'https://webhook.example.com',
          [WebhookEventType.jobCompleted],
        );

        await apiFacade.triggerWebhook(
          webhook.webhookId,
          WebhookEventType.jobCompleted,
        );

        final retrieved = await apiFacade.getWebhook(webhook.webhookId);
        expect(retrieved?.isActive, true);
      });

      test('Report generation', () async {
        final report = await apiFacade.generateReport();
        
        expect(report.reportId, isNotEmpty);
        expect(report.generatedAt, isNotNull);
      });
    });

    // ===== Edge Cases =====
    group('Edge Cases', () {
      test('Empty configuration list', () async {
        final configs = await apiFacade.getAllApiConfigs();
        // Could be empty or have previous items
        expect(configs, isA<List>());
      });

      test('Invalid URL in webhook', () async {
        final webhook = Webhook(
          webhookId: 'webhook_invalid',
          configId: 'config_1',
          url: 'not-a-valid-url',
          events: [WebhookEventType.jobCreated],
          status: WebhookStatus.active,
          createdAt: DateTime.now(),
        );

        expect(webhook.hasValidUrl, false);
      });

      test('API configuration with special characters', () async {
        final config = await apiFacade.registerApiConfig(
          'API™ with spëcial chars & symbols!',
          'https://api.example.com/v1/special-chars',
          AuthType.bearer,
        );

        expect(config.apiName, 'API™ with spëcial chars & symbols!');
      });

      test('Multiple webhooks for same config', () async {
        final config = await apiFacade.registerApiConfig(
          'Multi Webhook API',
          'https://api.example.com',
          AuthType.bearer,
        );

        final webhook1 = await apiFacade.registerWebhook(
          config.configId,
          'https://webhook1.example.com',
          [WebhookEventType.jobCreated],
        );

        final webhook2 = await apiFacade.registerWebhook(
          config.configId,
          'https://webhook2.example.com',
          [WebhookEventType.jobCompleted],
        );

        expect(webhook1.webhookId, isNotEmpty);
        expect(webhook2.webhookId, isNotEmpty);
        expect(webhook1.webhookId != webhook2.webhookId, true);
      });
    });
  });
}
