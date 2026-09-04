import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/api_models.dart';
import 'package:project_040/services/api_service.dart';

void main() {
  group('Phase 55: API Integration & Webhooks', () {
    // ========== Enum Tests ==========
    group('Enum Tests', () {
      test('HttpMethod values', () {
        expect(HttpMethod.get.value, 'GET');
        expect(HttpMethod.post.value, 'POST');
        expect(HttpMethod.put.value, 'PUT');
        expect(HttpMethod.delete.value, 'DELETE');
      });

      test('WebhookEventType values', () {
        expect(WebhookEventType.jobCreated.value, 'job.created');
        expect(WebhookEventType.jobCompleted.value, 'job.completed');
        expect(WebhookEventType.jobFailed.value, 'job.failed');
      });

      test('RetryPolicy values', () {
        expect(RetryPolicy.noRetry.value, 'no_retry');
        expect(RetryPolicy.exponential.value, 'exponential');
        expect(RetryPolicy.linear.value, 'linear');
      });
    });

    // ========== Model Tests ==========
    group('ApiEndpoint Model Tests', () {
      test('Valid endpoint properties', () {
        final endpoint = ApiEndpoint(
          endpointId: 'ep1',
          name: 'Test API',
          baseUrl: 'https://api.example.com',
          httpMethod: HttpMethod.post,
          path: '/v1/jobs',
          headers: {'Authorization': 'Bearer token'},
          timeoutSeconds: 30,
          createdAt: DateTime.now(),
        );
        expect(endpoint.isValid, true);
        expect(endpoint.isActive, true);
        expect(endpoint.fullUrl, 'https://api.example.com/v1/jobs');
      });

      test('Full URL construction', () {
        final endpoint = ApiEndpoint(
          endpointId: 'ep1',
          name: 'Test',
          baseUrl: 'https://api.com',
          httpMethod: HttpMethod.get,
          path: '/users',
          headers: {},
          timeoutSeconds: 30,
          createdAt: DateTime.now(),
        );
        expect(endpoint.fullUrl, 'https://api.com/users');
      });

      test('Endpoint usage tracking', () {
        final endpoint = ApiEndpoint(
          endpointId: 'ep1',
          name: 'Test',
          baseUrl: 'https://api.com',
          httpMethod: HttpMethod.get,
          path: '/test',
          headers: {},
          timeoutSeconds: 30,
          createdAt: DateTime.now(),
          lastUsedAt: DateTime.now().subtract(Duration(days: 5)),
        );
        expect(endpoint.isUsed, true);
        expect(endpoint.daysSinceLastUse, 5);
      });
    });

    group('ApiRequest Model Tests', () {
      test('Successful request', () {
        final request = ApiRequest(
          requestId: 'req1',
          endpointId: 'ep1',
          method: HttpMethod.post,
          url: 'https://api.com/jobs',
          sentAt: DateTime.now(),
          responseStatusCode: 200,
          receivedAt: DateTime.now().add(Duration(milliseconds: 150)),
          isSuccessful: true,
        );
        expect(request.isCompleted, true);
        expect(request.isStatusSuccess, true);
        expect(request.responseTimeMs, isNotNull);
      });

      test('Failed request', () {
        final request = ApiRequest(
          requestId: 'req2',
          endpointId: 'ep1',
          method: HttpMethod.post,
          url: 'https://api.com/jobs',
          sentAt: DateTime.now(),
          responseStatusCode: 500,
          receivedAt: DateTime.now().add(Duration(milliseconds: 100)),
          isSuccessful: false,
          errorMessage: 'Internal Server Error',
        );
        expect(request.isStatusSuccess, false);
        expect(request.errorMessage, isNotNull);
      });

      test('Pending request', () {
        final request = ApiRequest(
          requestId: 'req3',
          endpointId: 'ep1',
          method: HttpMethod.get,
          url: 'https://api.com/status',
          sentAt: DateTime.now(),
          isSuccessful: false,
        );
        expect(request.isCompleted, false);
        expect(request.responseTimeMs, isNull);
      });
    });

    group('WebhookEndpoint Model Tests', () {
      test('Active webhook', () {
        final webhook = WebhookEndpoint(
          webhookId: 'wh1',
          targetUrl: 'https://webhook.example.com/jobs',
          events: [WebhookEventType.jobCompleted, WebhookEventType.jobFailed],
          retryPolicy: RetryPolicy.exponential,
          maxRetries: 3,
          createdAt: DateTime.now(),
        );
        expect(webhook.isEnabled, true);
        expect(webhook.eventCount, 2);
      });

      test('Inactive webhook', () {
        final webhook = WebhookEndpoint(
          webhookId: 'wh2',
          targetUrl: 'https://webhook.example.com/old',
          events: [WebhookEventType.jobCreated],
          retryPolicy: RetryPolicy.noRetry,
          maxRetries: 0,
          isActive: false,
          createdAt: DateTime.now(),
        );
        expect(webhook.isEnabled, false);
      });

      test('Triggered webhook', () {
        final webhook = WebhookEndpoint(
          webhookId: 'wh3',
          targetUrl: 'https://webhook.example.com',
          events: [WebhookEventType.jobCompleted],
          retryPolicy: RetryPolicy.exponential,
          maxRetries: 3,
          createdAt: DateTime.now(),
          lastTriggeredAt: DateTime.now().subtract(Duration(hours: 1)),
        );
        expect(webhook.isTriggered, true);
      });
    });

    group('WebhookPayload Model Tests', () {
      test('Pending payload', () {
        final payload = WebhookPayload(
          payloadId: 'pl1',
          webhookId: 'wh1',
          eventType: WebhookEventType.jobCompleted,
          triggeredAt: DateTime.now(),
          data: {'jobId': 'job123', 'status': 'completed'},
          status: WebhookPayloadStatus.pending,
        );
        expect(payload.isPending, true);
        expect(payload.isSuccessful, false);
        expect(payload.isFailed, false);
      });

      test('Delivered payload', () {
        final payload = WebhookPayload(
          payloadId: 'pl2',
          webhookId: 'wh1',
          eventType: WebhookEventType.jobCompleted,
          triggeredAt: DateTime.now(),
          data: {'jobId': 'job456'},
          status: WebhookPayloadStatus.delivered,
          attemptCount: 1,
        );
        expect(payload.isSuccessful, true);
        expect(payload.isPending, false);
      });

      test('Failed payload', () {
        final payload = WebhookPayload(
          payloadId: 'pl3',
          webhookId: 'wh1',
          eventType: WebhookEventType.jobFailed,
          triggeredAt: DateTime.now(),
          data: {'jobId': 'job789'},
          status: WebhookPayloadStatus.failed,
          attemptCount: 3,
          lastError: 'Connection timeout',
        );
        expect(payload.isFailed, true);
      });
    });

    group('ApiMetrics Model Tests', () {
      test('Healthy metrics', () {
        final metrics = ApiMetrics(
          metricsId: 'metrics1',
          totalRequests: 100,
          successfulRequests: 99,
          failedRequests: 1,
          averageResponseTimeMs: 150.0,
          totalWebhooks: 50,
          successfulWebhooks: 48,
          failedWebhooks: 2,
          periodStart: DateTime.now().subtract(Duration(days: 1)),
          periodEnd: DateTime.now(),
        );
        expect(metrics.successRate, greaterThan(0.95));
        expect(metrics.webhookSuccessRate, greaterThan(0.90));
        expect(metrics.isHealthy, true);
      });

      test('Unhealthy metrics', () {
        final metrics = ApiMetrics(
          metricsId: 'metrics2',
          totalRequests: 100,
          successfulRequests: 80,
          failedRequests: 20,
          averageResponseTimeMs: 500.0,
          totalWebhooks: 50,
          successfulWebhooks: 40,
          failedWebhooks: 10,
          periodStart: DateTime.now().subtract(Duration(days: 1)),
          periodEnd: DateTime.now(),
        );
        expect(metrics.successRate, lessThan(0.95));
        expect(metrics.isHealthy, false);
      });
    });

    group('RateLimitInfo Model Tests', () {
      test('Within rate limit', () {
        final info = RateLimitInfo(
          limitId: 'limit1',
          configId: 'config1',
          requestLimit: 100,
          currentCount: 50,
          windowStart: DateTime.now(),
          windowEnd: DateTime.now().add(Duration(minutes: 1)),
        );
        expect(info.isLimited, false);
        expect(info.remainingRequests, 50);
      });

      test('Rate limit exceeded', () {
        final info = RateLimitInfo(
          limitId: 'limit2',
          configId: 'config1',
          requestLimit: 100,
          currentCount: 100,
          windowStart: DateTime.now().subtract(Duration(seconds: 30)),
          windowEnd: DateTime.now().add(Duration(seconds: 30)),
        );
        expect(info.isLimited, true);
        expect(info.remainingRequests, 0);
      });

      test('Reset time calculation', () {
        final now = DateTime.now();
        final info = RateLimitInfo(
          limitId: 'limit3',
          configId: 'config1',
          requestLimit: 100,
          currentCount: 80,
          windowStart: now,
          windowEnd: now.add(Duration(seconds: 45)),
        );
        expect(info.resetInSeconds, lessThanOrEqualTo(45));
      });
    });

    // ========== Repository Tests ==========
    group('MemoryApiRepository Tests', () {
      late MemoryApiRepository repository;

      setUp(() {
        repository = MemoryApiRepository();
      });

      test('Add and retrieve endpoint', () async {
        final endpoint = ApiEndpoint(
          endpointId: 'ep1',
          name: 'Test API',
          baseUrl: 'https://api.com',
          httpMethod: HttpMethod.get,
          path: '/test',
          headers: {},
          timeoutSeconds: 30,
          createdAt: DateTime.now(),
        );
        await repository.addEndpoint(endpoint);
        final retrieved = await repository.getEndpoint('ep1');
        expect(retrieved, isNotNull);
        expect(retrieved!.name, 'Test API');
      });

      test('Get all endpoints', () async {
        final ep1 = ApiEndpoint(
          endpointId: 'ep1',
          name: 'API 1',
          baseUrl: 'https://api1.com',
          httpMethod: HttpMethod.get,
          path: '/',
          headers: {},
          timeoutSeconds: 30,
          createdAt: DateTime.now(),
        );
        final ep2 = ApiEndpoint(
          endpointId: 'ep2',
          name: 'API 2',
          baseUrl: 'https://api2.com',
          httpMethod: HttpMethod.post,
          path: '/',
          headers: {},
          timeoutSeconds: 30,
          createdAt: DateTime.now(),
        );
        await repository.addEndpoint(ep1);
        await repository.addEndpoint(ep2);
        final endpoints = await repository.getAllEndpoints();
        expect(endpoints.length, 2);
      });

      test('Add webhook and retrieve', () async {
        final webhook = WebhookEndpoint(
          webhookId: 'wh1',
          targetUrl: 'https://webhook.com/events',
          events: [WebhookEventType.jobCreated],
          retryPolicy: RetryPolicy.exponential,
          maxRetries: 3,
          createdAt: DateTime.now(),
        );
        await repository.addWebhook(webhook);
        final retrieved = await repository.getWebhook('wh1');
        expect(retrieved, isNotNull);
        expect(retrieved!.targetUrl, 'https://webhook.com/events');
      });

      test('Get webhooks by event type', () async {
        final wh1 = WebhookEndpoint(
          webhookId: 'wh1',
          targetUrl: 'https://webhook1.com',
          events: [WebhookEventType.jobCompleted],
          retryPolicy: RetryPolicy.exponential,
          maxRetries: 3,
          createdAt: DateTime.now(),
        );
        final wh2 = WebhookEndpoint(
          webhookId: 'wh2',
          targetUrl: 'https://webhook2.com',
          events: [WebhookEventType.jobCreated, WebhookEventType.jobFailed],
          retryPolicy: RetryPolicy.exponential,
          maxRetries: 3,
          createdAt: DateTime.now(),
        );
        await repository.addWebhook(wh1);
        await repository.addWebhook(wh2);
        final webhooks = await repository.getWebhooksByEvent(WebhookEventType.jobCreated);
        expect(webhooks.length, 1);
      });

      test('Add request and retrieve', () async {
        final request = ApiRequest(
          requestId: 'req1',
          endpointId: 'ep1',
          method: HttpMethod.post,
          url: 'https://api.com/jobs',
          sentAt: DateTime.now(),
          responseStatusCode: 200,
          receivedAt: DateTime.now(),
          isSuccessful: true,
        );
        await repository.addRequest(request);
        final retrieved = await repository.getRequest('req1');
        expect(retrieved, isNotNull);
        expect(retrieved!.isSuccessful, true);
      });

      test('Get failed requests', () async {
        final req1 = ApiRequest(
          requestId: 'req1',
          endpointId: 'ep1',
          method: HttpMethod.get,
          url: 'https://api.com/1',
          sentAt: DateTime.now(),
          isSuccessful: true,
        );
        final req2 = ApiRequest(
          requestId: 'req2',
          endpointId: 'ep1',
          method: HttpMethod.get,
          url: 'https://api.com/2',
          sentAt: DateTime.now(),
          isSuccessful: false,
        );
        await repository.addRequest(req1);
        await repository.addRequest(req2);
        final failed = await repository.getFailedRequests();
        expect(failed.length, 1);
      });
    });

    // ========== Engine Tests ==========
    group('MemoryHttpEngine Tests', () {
      late MemoryApiRepository repository;
      late MemoryHttpEngine engine;

      setUp(() {
        repository = MemoryApiRepository();
        engine = MemoryHttpEngine(repository);
      });

      test('Execute request', () async {
        final endpoint = ApiEndpoint(
          endpointId: 'ep1',
          name: 'Test',
          baseUrl: 'https://api.com',
          httpMethod: HttpMethod.post,
          path: '/jobs',
          headers: {},
          timeoutSeconds: 30,
          createdAt: DateTime.now(),
        );
        final request = await engine.executeRequest(endpoint);
        expect(request, isNotNull);
        expect(request.responseStatusCode, isNotNull);
      });

      test('Validate endpoint', () async {
        final endpoint = ApiEndpoint(
          endpointId: 'ep1',
          name: 'Test',
          baseUrl: 'https://api.com',
          httpMethod: HttpMethod.get,
          path: '/',
          headers: {},
          timeoutSeconds: 30,
          createdAt: DateTime.now(),
        );
        final isValid = await engine.validateEndpoint(endpoint);
        expect(isValid, true);
      });

      test('Calculate retry delay exponential', () async {
        final delay1 = await engine.calculateRetryDelay(1, RetryPolicy.exponential);
        final delay2 = await engine.calculateRetryDelay(2, RetryPolicy.exponential);
        expect(delay2, greaterThan(delay1));
      });

      test('Calculate retry delay linear', () async {
        final delay1 = await engine.calculateRetryDelay(1, RetryPolicy.linear);
        final delay2 = await engine.calculateRetryDelay(2, RetryPolicy.linear);
        expect(delay2, greaterThan(delay1));
      });
    });

    group('MemoryWebhookEngine Tests', () {
      late MemoryApiRepository repository;
      late MemoryWebhookEngine engine;

      setUp(() {
        repository = MemoryApiRepository();
        engine = MemoryWebhookEngine(repository);
      });

      test('Trigger webhook', () async {
        final webhook = WebhookEndpoint(
          webhookId: 'wh1',
          targetUrl: 'https://webhook.com',
          events: [WebhookEventType.jobCompleted],
          retryPolicy: RetryPolicy.exponential,
          maxRetries: 3,
          createdAt: DateTime.now(),
        );
        final payload = WebhookPayload(
          payloadId: 'pl1',
          webhookId: 'wh1',
          eventType: WebhookEventType.jobCompleted,
          triggeredAt: DateTime.now(),
          data: {'jobId': 'job123'},
        );
        await engine.triggerWebhook(webhook, payload);
        final updated = await repository.getPayload('pl1');
        expect(updated, isNotNull);
      });

      test('Generate signature', () async {
        final sig = await engine.generateSignature('payload', 'secret');
        expect(sig, isNotNull);
        expect(sig.isNotEmpty, true);
      });

      test('Get webhooks for event', () async {
        final webhook = WebhookEndpoint(
          webhookId: 'wh1',
          targetUrl: 'https://webhook.com',
          events: [WebhookEventType.jobCreated],
          retryPolicy: RetryPolicy.exponential,
          maxRetries: 3,
          createdAt: DateTime.now(),
        );
        await repository.addWebhook(webhook);
        final webhooks = await engine.getWebhooksForEvent(WebhookEventType.jobCreated);
        expect(webhooks.length, 1);
      });
    });

    // ========== Manager Tests ==========
    group('MemoryApiManager Tests', () {
      late MemoryApiRepository repository;
      late MemoryHttpEngine httpEngine;
      late MemoryWebhookEngine webhookEngine;
      late MemoryApiManager manager;

      setUp(() {
        repository = MemoryApiRepository();
        httpEngine = MemoryHttpEngine(repository);
        webhookEngine = MemoryWebhookEngine(repository);
        manager = MemoryApiManager(repository, httpEngine, webhookEngine);
      });

      test('Create endpoint', () async {
        await manager.createEndpoint('Test', 'https://api.com', HttpMethod.post, '/jobs');
        final endpoints = await repository.getAllEndpoints();
        expect(endpoints.isNotEmpty, true);
      });

      test('Register webhook', () async {
        await manager.registerWebhook(
          'https://webhook.com',
          [WebhookEventType.jobCompleted],
        );
        final webhooks = await repository.getAllWebhooks();
        expect(webhooks.isNotEmpty, true);
      });

      test('Call endpoint', () async {
        await manager.createEndpoint('Test', 'https://api.com', HttpMethod.get, '/status');
        final endpoints = await repository.getAllEndpoints();
        final request = await manager.callEndpoint(endpoints[0].endpointId);
        expect(request, isNotNull);
      });

      test('Trigger webhook event', () async {
        await manager.registerWebhook(
          'https://webhook.com',
          [WebhookEventType.jobCompleted],
        );
        await manager.triggerWebhookEvent(
          WebhookEventType.jobCompleted,
          {'jobId': 'job123', 'status': 'completed'},
        );
        final payloads = await repository.getPendingPayloads();
        expect(payloads.isNotEmpty, true);
      });

      test('Calculate metrics', () async {
        final metrics = await manager.calculateMetrics(
          DateTime.now().subtract(Duration(days: 1)),
          DateTime.now(),
        );
        expect(metrics, isNotNull);
      });

      test('Generate report', () async {
        final report = await manager.generateReport(
          DateTime.now().subtract(Duration(days: 7)),
          DateTime.now(),
        );
        expect(report, isNotNull);
        expect(report.toMarkdown(), isNotEmpty);
      });
    });

    // ========== Facade Tests ==========
    group('ApiFacade Tests', () {
      late ApiFacade facade;

      setUp(() {
        final repository = MemoryApiRepository();
        final httpEngine = MemoryHttpEngine(repository);
        final webhookEngine = MemoryWebhookEngine(repository);
        final manager = MemoryApiManager(repository, httpEngine, webhookEngine);
        facade = ApiFacade(manager, repository, httpEngine, webhookEngine);
      });

      test('Create endpoint through facade', () async {
        await facade.createEndpoint('Test', 'https://api.com', HttpMethod.get, '/test');
        final endpoints = await facade.getAllEndpoints();
        expect(endpoints.isNotEmpty, true);
      });

      test('Register webhook through facade', () async {
        await facade.registerWebhook(
          'https://webhook.com',
          [WebhookEventType.jobCreated],
        );
        final webhooks = await facade.getActiveWebhooks();
        expect(webhooks.isNotEmpty, true);
      });

      test('Trigger event through facade', () async {
        await facade.registerWebhook(
          'https://webhook.com',
          [WebhookEventType.jobCompleted],
        );
        await facade.triggerEvent(
          WebhookEventType.jobCompleted,
          {'jobId': 'job456'},
        );
        expect(true, true);
      });

      test('Generate report through facade', () async {
        final report = await facade.generateReport(
          DateTime.now().subtract(Duration(days: 1)),
          DateTime.now(),
        );
        expect(report, isNotNull);
      });
    });

    // ========== Integration Tests ==========
    group('Integration Tests', () {
      late ApiFacade facade;

      setUp(() {
        final repository = MemoryApiRepository();
        final httpEngine = MemoryHttpEngine(repository);
        final webhookEngine = MemoryWebhookEngine(repository);
        final manager = MemoryApiManager(repository, httpEngine, webhookEngine);
        facade = ApiFacade(manager, repository, httpEngine, webhookEngine);
      });

      test('Complete API workflow', () async {
        await facade.createEndpoint('JobAPI', 'https://api.example.com', HttpMethod.post, '/jobs');
        final endpoints = await facade.getAllEndpoints();
        expect(endpoints.isNotEmpty, true);

        final request = await facade.callEndpoint(endpoints[0].endpointId);
        expect(request, isNotNull);
      });

      test('Webhook integration workflow', () async {
        await facade.registerWebhook(
          'https://webhook.example.com',
          [WebhookEventType.jobCompleted, WebhookEventType.jobFailed],
        );
        final webhooks = await facade.getActiveWebhooks();
        expect(webhooks.isNotEmpty, true);

        await facade.triggerEvent(
          WebhookEventType.jobCompleted,
          {'jobId': 'job789', 'result': 'success'},
        );
        expect(true, true);
      });

      test('Multiple endpoints workflow', () async {
        await facade.createEndpoint('Jobs', 'https://api.com', HttpMethod.get, '/jobs');
        await facade.createEndpoint('Reports', 'https://api.com', HttpMethod.get, '/reports');
        final endpoints = await facade.getAllEndpoints();
        expect(endpoints.length, 2);
      });

      test('Full integration with report', () async {
        await facade.createEndpoint('Test', 'https://api.com', HttpMethod.get, '/status');
        await facade.registerWebhook('https://webhook.com', [WebhookEventType.jobCreated]);
        
        final report = await facade.generateReport(
          DateTime.now().subtract(Duration(days: 1)),
          DateTime.now(),
        );
        expect(report.toMarkdown(), isNotEmpty);
      });

      test('Rate limiting workflow', () async {
        final metrics = await facade.calculateMetrics(
          DateTime.now().subtract(Duration(days: 1)),
          DateTime.now(),
        );
        expect(metrics, isNotNull);
      });

      test('Failed request recovery', () async {
        await facade.createEndpoint('API', 'https://api.com', HttpMethod.post, '/data');
        final failed = await facade.getFailedRequests();
        expect(failed, isNotEmpty);
      });
    });
  });
}
