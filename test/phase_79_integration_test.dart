import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/integration_models.dart';
import 'package:project_040/services/integration_gateway_service.dart';

void main() {
  group('Integration & API Gateway Tests', () {
    late IntegrationRepositoryImpl repository;

    setUp(() {
      repository = IntegrationRepositoryImpl();
    });

    // Enum Tests
    group('Enum Tests', () {
      test('IntegrationMethod enum has all values', () {
        expect(IntegrationMethod.values.length, 7);
        expect(IntegrationMethod.rest, isNotNull);
        expect(IntegrationMethod.graphql, isNotNull);
      });

      test('APIVersionStatus enum has all values', () {
        expect(APIVersionStatus.values.length, 5);
        expect(APIVersionStatus.active, isNotNull);
      });

      test('GatewayStrategy enum has all values', () {
        expect(GatewayStrategy.values.length, 6);
        expect(GatewayStrategy.roundRobin, isNotNull);
      });

      test('RateLimitStrategy enum has all values', () {
        expect(RateLimitStrategy.values.length, 5);
        expect(RateLimitStrategy.perUser, isNotNull);
      });

      test('CachePolicyType enum has all values', () {
        expect(CachePolicyType.values.length, 6);
        expect(CachePolicyType.ttl, isNotNull);
      });

      test('IntegrationStatus enum has all values', () {
        expect(IntegrationStatus.values.length, 5);
        expect(IntegrationStatus.active, isNotNull);
      });
    });

    // Model Tests
    group('Model Tests', () {
      test('APIEndpoint model creation and computed properties', () async {
        final endpoint = APIEndpoint(
          endpointId: 'ep1',
          path: '/api/v1/jobs',
          method: 'GET',
          description: 'List jobs',
          version: '1.0',
          supportedContentTypes: ['application/json'],
          createdAt: DateTime.now(),
        );
        expect(endpoint.isPublic, true);
        expect(endpoint.ageInDays, 0);
      });

      test('IntegrationPartner model creation and computed properties', () {
        final partner = IntegrationPartner(
          partnerId: 'p1',
          partnerName: 'External API',
          apiBaseUrl: 'https://api.external.com',
          method: IntegrationMethod.rest,
          status: IntegrationStatus.active,
          connectedAt: DateTime.now(),
          metadata: {},
        );
        expect(partner.isActive, true);
        expect(partner.ageInDays, 0);
      });

      test('APIRoute model with high priority', () {
        final route = APIRoute(
          routeId: 'r1',
          sourceEndpointId: 'ep1',
          targetPartnerIds: ['p1', 'p2'],
          strategy: GatewayStrategy.roundRobin,
          priority: 9,
          createdAt: DateTime.now(),
          transformationRules: {},
        );
        expect(route.isHighPriority, true);
        expect(route.targetCount, 2);
      });

      test('RateLimiter model with strict limits', () {
        final limiter = RateLimiter(
          limiterId: 'l1',
          endpointId: 'ep1',
          strategy: RateLimitStrategy.perUser,
          requestsPerWindow: 5,
          windowSizeSeconds: 60,
          createdAt: DateTime.now(),
        );
        expect(limiter.isStrict, true);
        expect(limiter.throughputPerSecond, 1);
      });

      test('CachePolicy model computation', () {
        final policy = CachePolicy(
          policyId: 'cp1',
          endpointId: 'ep1',
          type: CachePolicyType.ttl,
          ttlSeconds: 30,
          createdAt: DateTime.now(),
          cacheKeyPatterns: ['*'],
        );
        expect(policy.hasShortTtl, true);
        expect(policy.patternCount, 1);
      });

      test('CircuitBreaker model state checks', () {
        final breaker = CircuitBreaker(
          breakerId: 'cb1',
          partnerId: 'p1',
          failureThreshold: 5,
          successThreshold: 2,
          timeoutMs: 30000,
          createdAt: DateTime.now(),
        );
        expect(breaker.isClosed, true);
        expect(breaker.isOpen, false);
      });

      test('WebhookEvent model delivery tracking', () {
        final event = WebhookEvent(
          eventId: 'we1',
          partnerId: 'p1',
          eventType: 'deployment.complete',
          payload: {'status': 'success'},
          occurredAt: DateTime.now(),
          deliveryStatus: 'pending',
        );
        expect(event.isPending, true);
        expect(event.isDelivered, false);
      });

      test('APIKey model expiration and validity', () {
        final key = APIKey(
          keyId: 'k1',
          partnerId: 'p1',
          keyHash: 'hash123',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(days: 30)),
          allowedEndpoints: ['ep1', 'ep2'],
          isActive: true,
        );
        expect(key.isValid, true);
        expect(key.endpointCount, 2);
      });

      test('RequestLog model status and performance checks', () {
        final log = RequestLog(
          logId: 'rl1',
          endpointId: 'ep1',
          method: 'GET',
          path: '/api/v1/jobs',
          statusCode: 200,
          latencyMs: 150,
          timestamp: DateTime.now(),
          metadata: {},
        );
        expect(log.isSuccess, true);
        expect(log.isSlowRequest, false);
      });

      test('ResponseCache model with multiple hits', () {
        final cache = ResponseCache(
          cacheId: 'rc1',
          endpointId: 'ep1',
          requestHash: 'hash123',
          cachedResponse: '{"data": "test"}',
          cachedAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(minutes: 5)),
          hitCount: 150,
        );
        expect(cache.isValid, true);
        expect(cache.isHotCache, true);
      });

      test('IntegrationMetrics model with high success rate', () {
        final metrics = IntegrationMetrics(
          metricsId: 'im1',
          partnerId: 'p1',
          periodStart: DateTime.now().subtract(Duration(days: 1)),
          periodEnd: DateTime.now(),
          totalRequests: 1000,
          successfulRequests: 995,
          failedRequests: 5,
          averageLatencyMs: 150.0,
          p99LatencyMs: 2500.0,
          endpointStats: {},
        );
        expect(metrics.successRate, 99.5);
        expect(metrics.isHealthy, true);
      });
    });

    // APIEndpoint Management Tests
    group('APIEndpoint Management Tests', () {
      test('Create endpoint', () async {
        final endpoint = await repository.createEndpoint(
          '/api/v1/jobs',
          'GET',
          'Retrieve all jobs',
          '1.0',
          ['application/json'],
        );
        expect(endpoint.path, '/api/v1/jobs');
        expect(endpoint.method, 'GET');
      });

      test('Get endpoint by ID', () async {
        final created = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List jobs', '1.0', ['application/json']);
        final retrieved = await repository.getEndpoint(created.endpointId);
        expect(retrieved, isNotNull);
        expect(retrieved!.path, '/api/v1/jobs');
      });

      test('Update endpoint', () async {
        final created = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List jobs', '1.0', ['application/json']);
        final updated = await repository.updateEndpoint(created.endpointId, isActive: false);
        expect(updated.isActive, false);
      });

      test('Delete endpoint', () async {
        final created = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List jobs', '1.0', ['application/json']);
        await repository.deleteEndpoint(created.endpointId);
        final retrieved = await repository.getEndpoint(created.endpointId);
        expect(retrieved, isNull);
      });

      test('List endpoints with pagination', () async {
        await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        await repository.createEndpoint('/api/v1/deployments', 'POST', 'Create', '1.0', ['application/json']);
        final list = await repository.listEndpoints(limit: 10, offset: 0);
        expect(list.length, greaterThanOrEqualTo(2));
      });

      test('Get endpoints by method', () async {
        await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        await repository.createEndpoint('/api/v1/deployments', 'POST', 'Create', '1.0', ['application/json']);
        final gets = await repository.getEndpointsByMethod('GET');
        expect(gets.length, greaterThan(0));
      });

      test('Get active endpoints', () async {
        final ep1 = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        await repository.updateEndpoint(ep1.endpointId, isActive: false);
        await repository.createEndpoint('/api/v1/deployments', 'POST', 'Create', '1.0', ['application/json']);
        final active = await repository.getActiveEndpoints();
        expect(active.where((e) => e.path == '/api/v1/deployments').length, 1);
      });

      test('Get endpoint count', () async {
        final before = await repository.getEndpointCount();
        await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        final after = await repository.getEndpointCount();
        expect(after, before + 1);
      });
    });

    // IntegrationPartner Management Tests
    group('IntegrationPartner Management Tests', () {
      test('Create partner', () async {
        final partner = await repository.createPartner(
          'Acme Corp',
          'https://api.acme.com',
          IntegrationMethod.rest,
          'contact@acme.com',
        );
        expect(partner.partnerName, 'Acme Corp');
        expect(partner.isActive, true);
      });

      test('Get partner by ID', () async {
        final created = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        final retrieved = await repository.getPartner(created.partnerId);
        expect(retrieved, isNotNull);
      });

      test('Update partner status', () async {
        final created = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        final updated = await repository.updatePartnerStatus(created.partnerId, IntegrationStatus.maintenance);
        expect(updated.status, IntegrationStatus.maintenance);
      });

      test('Get partners by method', () async {
        await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        final rest = await repository.getPartnersByMethod(IntegrationMethod.rest);
        expect(rest.length, greaterThan(0));
      });

      test('Get active partners', () async {
        await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        final active = await repository.getActivePartners();
        expect(active.length, greaterThan(0));
      });

      test('Get partner count', () async {
        final before = await repository.getPartnerCount();
        await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        final after = await repository.getPartnerCount();
        expect(after, before + 1);
      });
    });

    // APIRoute Management Tests
    group('APIRoute Management Tests', () {
      test('Create route', () async {
        final ep = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        final partner = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        final route = await repository.createRoute(ep.endpointId, [partner.partnerId], GatewayStrategy.roundRobin, 5);
        expect(route.sourceEndpointId, ep.endpointId);
      });

      test('Get routes by endpoint', () async {
        final ep = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        final partner = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        await repository.createRoute(ep.endpointId, [partner.partnerId], GatewayStrategy.roundRobin, 5);
        final routes = await repository.getRoutesByEndpoint(ep.endpointId);
        expect(routes.length, 1);
      });

      test('Get route count', () async {
        final before = await repository.getRouteCount();
        final ep = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        final partner = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        await repository.createRoute(ep.endpointId, [partner.partnerId], GatewayStrategy.roundRobin, 5);
        final after = await repository.getRouteCount();
        expect(after, before + 1);
      });
    });

    // RateLimiter Management Tests
    group('RateLimiter Management Tests', () {
      test('Create rate limiter', () async {
        final ep = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        final limiter = await repository.createRateLimiter(
          ep.endpointId,
          RateLimitStrategy.perUser,
          100,
          60,
        );
        expect(limiter.requestsPerWindow, 100);
      });

      test('Get rate limiter by endpoint', () async {
        final ep = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        await repository.createRateLimiter(ep.endpointId, RateLimitStrategy.perUser, 100, 60);
        final limiter = await repository.getRateLimiterByEndpoint(ep.endpointId);
        expect(limiter, isNotNull);
      });

      test('Get rate limiter count', () async {
        final before = await repository.getRateLimiterCount();
        final ep = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        await repository.createRateLimiter(ep.endpointId, RateLimitStrategy.perUser, 100, 60);
        final after = await repository.getRateLimiterCount();
        expect(after, before + 1);
      });
    });

    // CachePolicy Management Tests
    group('CachePolicy Management Tests', () {
      test('Create cache policy', () async {
        final ep = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        final policy = await repository.createCachePolicy(
          ep.endpointId,
          CachePolicyType.ttl,
          300,
          ['*'],
        );
        expect(policy.ttlSeconds, 300);
      });

      test('Get cache policy by endpoint', () async {
        final ep = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        await repository.createCachePolicy(ep.endpointId, CachePolicyType.ttl, 300, ['*']);
        final policy = await repository.getCachePolicyByEndpoint(ep.endpointId);
        expect(policy, isNotNull);
      });

      test('Get cache policy count', () async {
        final before = await repository.getCachePolicyCount();
        final ep = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        await repository.createCachePolicy(ep.endpointId, CachePolicyType.ttl, 300, ['*']);
        final after = await repository.getCachePolicyCount();
        expect(after, before + 1);
      });
    });

    // CircuitBreaker Management Tests
    group('CircuitBreaker Management Tests', () {
      test('Create circuit breaker', () async {
        final partner = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        final breaker = await repository.createCircuitBreaker(partner.partnerId, 5, 2, 30000);
        expect(breaker.failureThreshold, 5);
      });

      test('Get circuit breaker by partner', () async {
        final partner = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        await repository.createCircuitBreaker(partner.partnerId, 5, 2, 30000);
        final breaker = await repository.getCircuitBreakerByPartner(partner.partnerId);
        expect(breaker, isNotNull);
      });

      test('Update circuit breaker state', () async {
        final partner = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        final breaker = await repository.createCircuitBreaker(partner.partnerId, 5, 2, 30000);
        final updated = await repository.updateCircuitBreakerState(breaker.breakerId, 'open');
        expect(updated.isOpen, true);
      });

      test('Get circuit breaker count', () async {
        final before = await repository.getCircuitBreakerCount();
        final partner = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        await repository.createCircuitBreaker(partner.partnerId, 5, 2, 30000);
        final after = await repository.getCircuitBreakerCount();
        expect(after, before + 1);
      });
    });

    // WebhookEvent Management Tests
    group('WebhookEvent Management Tests', () {
      test('Record webhook event', () async {
        final partner = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        final event = await repository.recordWebhookEvent(
          partner.partnerId,
          'deployment.complete',
          {'status': 'success'},
        );
        expect(event.eventType, 'deployment.complete');
      });

      test('Get pending webhooks', () async {
        final partner = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        await repository.recordWebhookEvent(partner.partnerId, 'deployment.complete', {'status': 'success'});
        final pending = await repository.getPendingWebhooks();
        expect(pending.length, greaterThan(0));
      });

      test('Update webhook delivery', () async {
        final partner = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        final event = await repository.recordWebhookEvent(partner.partnerId, 'deployment.complete', {'status': 'success'});
        final updated = await repository.updateWebhookDelivery(
          event.eventId,
          attempts: 1,
          status: 'delivered',
          deliveredAt: DateTime.now(),
        );
        expect(updated.isDelivered, true);
      });

      test('Get webhook event count', () async {
        final before = await repository.getWebhookEventCount();
        final partner = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        await repository.recordWebhookEvent(partner.partnerId, 'deployment.complete', {'status': 'success'});
        final after = await repository.getWebhookEventCount();
        expect(after, before + 1);
      });
    });

    // APIKey Management Tests
    group('APIKey Management Tests', () {
      test('Create API key', () async {
        final partner = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        final key = await repository.createAPIKey(
          partner.partnerId,
          ['ep1', 'ep2'],
          DateTime.now().add(Duration(days: 30)),
          100,
        );
        expect(key.isValid, true);
      });

      test('Get API keys by partner', () async {
        final partner = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        await repository.createAPIKey(partner.partnerId, ['ep1'], DateTime.now().add(Duration(days: 30)), 100);
        final keys = await repository.getAPIKeysByPartner(partner.partnerId);
        expect(keys.length, 1);
      });

      test('Update API key status', () async {
        final partner = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        final key = await repository.createAPIKey(partner.partnerId, ['ep1'], null, null);
        final updated = await repository.updateAPIKeyStatus(key.keyId, false);
        expect(updated.isActive, false);
      });

      test('Get API key count', () async {
        final before = await repository.getAPIKeyCount();
        final partner = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        await repository.createAPIKey(partner.partnerId, ['ep1'], null, null);
        final after = await repository.getAPIKeyCount();
        expect(after, before + 1);
      });
    });

    // RequestLog Management Tests
    group('RequestLog Management Tests', () {
      test('Log request', () async {
        final ep = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        final log = await repository.logRequest(ep.endpointId, 'GET', '/api/v1/jobs', 200, 150);
        expect(log.statusCode, 200);
        expect(log.isSuccess, true);
      });

      test('Get error logs', () async {
        final ep = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        await repository.logRequest(ep.endpointId, 'GET', '/api/v1/jobs', 500, 150);
        final errors = await repository.getErrorLogs();
        expect(errors.length, greaterThan(0));
      });

      test('Get slow requests', () async {
        final ep = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        await repository.logRequest(ep.endpointId, 'GET', '/api/v1/jobs', 200, 6000);
        final slow = await repository.getSlowRequests();
        expect(slow.length, greaterThan(0));
      });

      test('Get request log count', () async {
        final before = await repository.getRequestLogCount();
        final ep = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        await repository.logRequest(ep.endpointId, 'GET', '/api/v1/jobs', 200, 150);
        final after = await repository.getRequestLogCount();
        expect(after, before + 1);
      });
    });

    // ResponseCache Management Tests
    group('ResponseCache Management Tests', () {
      test('Cache response', () async {
        final ep = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        final cache = await repository.cacheResponse(
          ep.endpointId,
          'req_hash_123',
          '{"data": "test"}',
          300,
        );
        expect(cache.isValid, true);
      });

      test('Increment cache hit', () async {
        final ep = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        final cache = await repository.cacheResponse(ep.endpointId, 'hash', '{}', 300);
        final hit = await repository.incrementCacheHit(cache.cacheId);
        expect(hit.hitCount, 1);
      });

      test('Get valid caches', () async {
        final ep = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        await repository.cacheResponse(ep.endpointId, 'hash', '{}', 300);
        final valid = await repository.getValidCaches();
        expect(valid.length, greaterThan(0));
      });

      test('Get cache count', () async {
        final before = await repository.getCacheCount();
        final ep = await repository.createEndpoint('/api/v1/jobs', 'GET', 'List', '1.0', ['application/json']);
        await repository.cacheResponse(ep.endpointId, 'hash', '{}', 300);
        final after = await repository.getCacheCount();
        expect(after, before + 1);
      });
    });

    // IntegrationMetrics Tests
    group('IntegrationMetrics Tests', () {
      test('Generate metrics', () async {
        final partner = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        final now = DateTime.now();
        final metrics = await repository.generateMetrics(
          partner.partnerId,
          now.subtract(Duration(days: 1)),
          now,
        );
        expect(metrics.partnerId, partner.partnerId);
      });

      test('Get metrics by partner', () async {
        final partner = await repository.createPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest, null);
        final now = DateTime.now();
        await repository.generateMetrics(partner.partnerId, now.subtract(Duration(days: 1)), now);
        final metrics = await repository.getMetricsByPartner(partner.partnerId);
        expect(metrics.length, greaterThan(0));
      });
    });

    // Engine Tests
    group('Engine Tests', () {
      test('IntegrationEngine validates partner', () async {
        final engine = IntegrationEngine();
        final partner = IntegrationPartner(
          partnerId: 'p1',
          partnerName: 'Acme',
          apiBaseUrl: 'https://api.acme.com',
          method: IntegrationMethod.rest,
          status: IntegrationStatus.active,
          connectedAt: DateTime.now(),
          metadata: {},
        );
        expect(() => engine.integratePartner(partner), returnsNormally);
      });

      test('APIRoutingEngine routes request', () async {
        final engine = APIRoutingEngine();
        final route = APIRoute(
          routeId: 'r1',
          sourceEndpointId: 'ep1',
          targetPartnerIds: ['p1'],
          strategy: GatewayStrategy.roundRobin,
          priority: 5,
          createdAt: DateTime.now(),
          transformationRules: {},
        );
        expect(() => engine.routeRequest(route, 'request'), returnsNormally);
      });

      test('RateLimitingEngine checks rate limit', () async {
        final engine = RateLimitingEngine();
        final limiter = RateLimiter(
          limiterId: 'l1',
          endpointId: 'ep1',
          strategy: RateLimitStrategy.perUser,
          requestsPerWindow: 100,
          windowSizeSeconds: 60,
          createdAt: DateTime.now(),
        );
        final result = await engine.checkRateLimit(limiter, 'user1');
        expect(result, true);
      });

      test('CachingEngine retrieves from cache', () async {
        final engine = CachingEngine();
        final policy = CachePolicy(
          policyId: 'cp1',
          endpointId: 'ep1',
          type: CachePolicyType.ttl,
          ttlSeconds: 300,
          createdAt: DateTime.now(),
          cacheKeyPatterns: ['*'],
        );
        final result = await engine.getFromCache(policy, 'key');
        expect(result, isNull);
      });

      test('CircuitBreakerEngine evaluates health', () async {
        final engine = CircuitBreakerEngine();
        final breaker = CircuitBreaker(
          breakerId: 'cb1',
          partnerId: 'p1',
          failureThreshold: 5,
          successThreshold: 2,
          timeoutMs: 30000,
          createdAt: DateTime.now(),
        );
        expect(() => engine.evaluateHealth(breaker), returnsNormally);
      });
    });

    // Facade Tests
    group('Facade Tests', () {
      test('Facade creates endpoint', () async {
        final repository = IntegrationRepositoryImpl();
        final manager = IntegrationManager(
          repository: repository,
          integrationEngine: IntegrationEngine(),
          routingEngine: APIRoutingEngine(),
          rateLimitEngine: RateLimitingEngine(),
          cachingEngine: CachingEngine(),
          circuitBreakerEngine: CircuitBreakerEngine(),
        );
        final facade = IntegrationFacade(repository: repository, manager: manager);
        final ep = await facade.createEndpoint('/api/v1/jobs', 'GET', 'List jobs');
        expect(ep.path, '/api/v1/jobs');
      });

      test('Facade adds partner', () async {
        final repository = IntegrationRepositoryImpl();
        final manager = IntegrationManager(
          repository: repository,
          integrationEngine: IntegrationEngine(),
          routingEngine: APIRoutingEngine(),
          rateLimitEngine: RateLimitingEngine(),
          cachingEngine: CachingEngine(),
          circuitBreakerEngine: CircuitBreakerEngine(),
        );
        final facade = IntegrationFacade(repository: repository, manager: manager);
        final partner = await facade.addPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest);
        expect(partner.partnerName, 'Acme');
      });

      test('Facade checks routing', () async {
        final repository = IntegrationRepositoryImpl();
        final manager = IntegrationManager(
          repository: repository,
          integrationEngine: IntegrationEngine(),
          routingEngine: APIRoutingEngine(),
          rateLimitEngine: RateLimitingEngine(),
          cachingEngine: CachingEngine(),
          circuitBreakerEngine: CircuitBreakerEngine(),
        );
        final facade = IntegrationFacade(repository: repository, manager: manager);
        final ep = await facade.createEndpoint('/api/v1/jobs', 'GET', 'List');
        final canRoute = await facade.canRouteRequest(ep.endpointId);
        expect(canRoute, true);
      });

      test('Facade counts healthy partners', () async {
        final repository = IntegrationRepositoryImpl();
        final manager = IntegrationManager(
          repository: repository,
          integrationEngine: IntegrationEngine(),
          routingEngine: APIRoutingEngine(),
          rateLimitEngine: RateLimitingEngine(),
          cachingEngine: CachingEngine(),
          circuitBreakerEngine: CircuitBreakerEngine(),
        );
        final facade = IntegrationFacade(repository: repository, manager: manager);
        await facade.addPartner('Acme', 'https://api.acme.com', IntegrationMethod.rest);
        final count = await facade.getHealthyPartnerCount();
        expect(count, greaterThanOrEqualTo(1));
      });
    });

    // Integration Tests
    group('Integration Tests', () {
      test('Complete integration workflow', () async {
        final repository = IntegrationRepositoryImpl();
        
        // Create endpoint
        final endpoint = await repository.createEndpoint(
          '/api/v1/jobs',
          'GET',
          'List jobs',
          '1.0',
          ['application/json'],
        );
        
        // Create partner
        final partner = await repository.createPartner(
          'Acme API',
          'https://api.acme.com',
          IntegrationMethod.rest,
          'api@acme.com',
        );
        
        // Create route
        final route = await repository.createRoute(
          endpoint.endpointId,
          [partner.partnerId],
          GatewayStrategy.roundRobin,
          5,
        );
        
        // Add rate limiter
        await repository.createRateLimiter(
          endpoint.endpointId,
          RateLimitStrategy.perUser,
          1000,
          60,
        );
        
        // Add cache policy
        await repository.createCachePolicy(
          endpoint.endpointId,
          CachePolicyType.ttl,
          300,
          ['*'],
        );
        
        // Log request
        await repository.logRequest(
          endpoint.endpointId,
          'GET',
          '/api/v1/jobs',
          200,
          150,
        );
        
        // Verify all created
        expect(await repository.getEndpointCount(), greaterThan(0));
        expect(await repository.getPartnerCount(), greaterThan(0));
        expect(await repository.getRouteCount(), greaterThan(0));
      });

      test('Partner lifecycle', () async {
        final repository = IntegrationRepositoryImpl();
        
        // Create
        final partner = await repository.createPartner(
          'Test Partner',
          'https://api.test.com',
          IntegrationMethod.graphql,
          'test@example.com',
        );
        expect(partner.status, IntegrationStatus.active);
        
        // Update to maintenance
        final maintenance = await repository.updatePartnerStatus(
          partner.partnerId,
          IntegrationStatus.maintenance,
        );
        expect(maintenance.status, IntegrationStatus.maintenance);
        
        // Get active count should decrease
        final active = await repository.getActivePartners();
        expect(active.where((p) => p.partnerId == partner.partnerId).isEmpty, true);
      });

      test('Cache hit tracking', () async {
        final repository = IntegrationRepositoryImpl();
        final endpoint = await repository.createEndpoint(
          '/api/v1/jobs',
          'GET',
          'List',
          '1.0',
          ['application/json'],
        );
        
        final cache = await repository.cacheResponse(
          endpoint.endpointId,
          'req_hash',
          '{}',
          300,
        );
        
        var hit = await repository.incrementCacheHit(cache.cacheId);
        expect(hit.hitCount, 1);
        
        hit = await repository.incrementCacheHit(hit.cacheId);
        expect(hit.hitCount, 2);
        
        hit = await repository.incrementCacheHit(hit.cacheId);
        expect(hit.isHotCache, false); // Need 100+ hits
      });
    });

    // Performance Tests
    group('Performance Tests', () {
      test('Bulk endpoint creation', () async {
        final repository = IntegrationRepositoryImpl();
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 100; i++) {
          await repository.createEndpoint(
            '/api/v1/resource$i',
            'GET',
            'Description $i',
            '1.0',
            ['application/json'],
          );
        }
        
        stopwatch.stop();
        expect(await repository.getEndpointCount(), greaterThanOrEqualTo(100));
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('Bulk log ingestion', () async {
        final repository = IntegrationRepositoryImpl();
        final endpoint = await repository.createEndpoint(
          '/api/v1/jobs',
          'GET',
          'List',
          '1.0',
          ['application/json'],
        );
        
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 500; i++) {
          await repository.logRequest(
            endpoint.endpointId,
            'GET',
            '/api/v1/jobs',
            200,
            100 + i,
          );
        }
        
        stopwatch.stop();
        expect(await repository.getRequestLogCount(), greaterThanOrEqualTo(500));
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });
    });

    // Edge Case Tests
    group('Edge Case Tests', () {
      test('Expired API key', () async {
        final repository = IntegrationRepositoryImpl();
        final partner = await repository.createPartner(
          'Acme',
          'https://api.acme.com',
          IntegrationMethod.rest,
          null,
        );
        
        final expiredKey = await repository.createAPIKey(
          partner.partnerId,
          ['ep1'],
          DateTime.now().subtract(Duration(days: 1)),
          null,
        );
        
        expect(expiredKey.isExpired, true);
        expect(expiredKey.isValid, false);
      });

      test('Circuit breaker state transitions', () async {
        final repository = IntegrationRepositoryImpl();
        final partner = await repository.createPartner(
          'Acme',
          'https://api.acme.com',
          IntegrationMethod.rest,
          null,
        );
        
        var breaker = await repository.createCircuitBreaker(
          partner.partnerId,
          5,
          2,
          30000,
        );
        expect(breaker.isClosed, true);
        
        breaker = await repository.updateCircuitBreakerState(
          breaker.breakerId,
          'open',
        );
        expect(breaker.isOpen, true);
        
        breaker = await repository.updateCircuitBreakerState(
          breaker.breakerId,
          'half-open',
        );
        expect(breaker.isHalfOpen, true);
      });

      test('Cache TTL expiration', () async {
        final repository = IntegrationRepositoryImpl();
        final endpoint = await repository.createEndpoint(
          '/api/v1/jobs',
          'GET',
          'List',
          '1.0',
          ['application/json'],
        );
        
        // Create cache that expires immediately
        final cache = ResponseCache(
          cacheId: 'rc1',
          endpointId: endpoint.endpointId,
          requestHash: 'hash',
          cachedResponse: '{}',
          cachedAt: DateTime.now().subtract(Duration(seconds: 10)),
          expiresAt: DateTime.now().subtract(Duration(seconds: 5)),
        );
        
        expect(cache.isExpired, true);
        expect(cache.isValid, false);
      });

      test('Empty endpoint method filtering', () async {
        final repository = IntegrationRepositoryImpl();
        final list = await repository.getEndpointsByMethod('NONEXISTENT');
        expect(list.isEmpty, true);
      });

      test('High volume metrics aggregation', () async {
        final repository = IntegrationRepositoryImpl();
        final partner = await repository.createPartner(
          'Acme',
          'https://api.acme.com',
          IntegrationMethod.rest,
          null,
        );
        
        final now = DateTime.now();
        final metrics = await repository.generateMetrics(
          partner.partnerId,
          now.subtract(Duration(days: 30)),
          now,
        );
        
        expect(metrics.periodInDays, 30);
      });
    });
  });
}
