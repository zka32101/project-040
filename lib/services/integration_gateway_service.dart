/// Integration & API Gateway Service

import 'package:flutter/foundation.dart';
import '../models/integration_models.dart';

// Repository Interface
abstract class IntegrationRepository {
  // APIEndpoint Management
  Future<APIEndpoint> createEndpoint(String path, String method, String description, String version, List<String> contentTypes);
  Future<APIEndpoint?> getEndpoint(String endpointId);
  Future<APIEndpoint> updateEndpoint(String endpointId, {bool? isActive, int? timeoutMs});
  Future<void> deleteEndpoint(String endpointId);
  Future<List<APIEndpoint>> listEndpoints({int limit = 50, int offset = 0});
  Future<List<APIEndpoint>> getEndpointsByMethod(String method);
  Future<List<APIEndpoint>> getActiveEndpoints();
  Future<int> getEndpointCount();

  // IntegrationPartner Management
  Future<IntegrationPartner> createPartner(String name, String baseUrl, IntegrationMethod method, String? contactEmail);
  Future<IntegrationPartner?> getPartner(String partnerId);
  Future<IntegrationPartner> updatePartnerStatus(String partnerId, IntegrationStatus status);
  Future<void> deletePartner(String partnerId);
  Future<List<IntegrationPartner>> listPartners({int limit = 50, int offset = 0});
  Future<List<IntegrationPartner>> getPartnersByMethod(IntegrationMethod method);
  Future<List<IntegrationPartner>> getActivePartners();
  Future<int> getPartnerCount();

  // APIRoute Management
  Future<APIRoute> createRoute(String sourceEndpointId, List<String> targetPartnerIds, GatewayStrategy strategy, int priority);
  Future<APIRoute?> getRoute(String routeId);
  Future<APIRoute> updateRoute(String routeId, {GatewayStrategy? strategy, int? priority, bool? isActive});
  Future<void> deleteRoute(String routeId);
  Future<List<APIRoute>> listRoutes({int limit = 50, int offset = 0});
  Future<List<APIRoute>> getRoutesByEndpoint(String endpointId);
  Future<List<APIRoute>> getActiveRoutes();
  Future<int> getRouteCount();

  // RateLimiter Management
  Future<RateLimiter> createRateLimiter(String endpointId, RateLimitStrategy strategy, int requestsPerWindow, int windowSizeSeconds);
  Future<RateLimiter?> getRateLimiter(String limiterId);
  Future<RateLimiter> updateRateLimiter(String limiterId, {int? requestsPerWindow, bool? isActive});
  Future<void> deleteRateLimiter(String limiterId);
  Future<List<RateLimiter>> listRateLimiters({int limit = 50, int offset = 0});
  Future<RateLimiter?> getRateLimiterByEndpoint(String endpointId);
  Future<int> getRateLimiterCount();

  // CachePolicy Management
  Future<CachePolicy> createCachePolicy(String endpointId, CachePolicyType type, int ttlSeconds, List<String> keyPatterns);
  Future<CachePolicy?> getCachePolicy(String policyId);
  Future<CachePolicy> updateCachePolicy(String policyId, {CachePolicyType? type, int? ttlSeconds, bool? isActive});
  Future<void> deleteCachePolicy(String policyId);
  Future<List<CachePolicy>> listCachePolicies({int limit = 50, int offset = 0});
  Future<CachePolicy?> getCachePolicyByEndpoint(String endpointId);
  Future<int> getCachePolicyCount();

  // CircuitBreaker Management
  Future<CircuitBreaker> createCircuitBreaker(String partnerId, int failureThreshold, int successThreshold, int timeoutMs);
  Future<CircuitBreaker?> getCircuitBreaker(String breakerId);
  Future<CircuitBreaker> updateCircuitBreakerState(String breakerId, String state);
  Future<void> deleteCircuitBreaker(String breakerId);
  Future<List<CircuitBreaker>> listCircuitBreakers({int limit = 50, int offset = 0});
  Future<CircuitBreaker?> getCircuitBreakerByPartner(String partnerId);
  Future<int> getCircuitBreakerCount();

  // WebhookEvent Management
  Future<WebhookEvent> recordWebhookEvent(String partnerId, String eventType, Map<String, dynamic> payload);
  Future<WebhookEvent?> getWebhookEvent(String eventId);
  Future<WebhookEvent> updateWebhookDelivery(String eventId, {int? attempts, DateTime? deliveredAt, String? status});
  Future<void> deleteWebhookEvent(String eventId);
  Future<List<WebhookEvent>> listWebhookEvents({int limit = 50, int offset = 0});
  Future<List<WebhookEvent>> getPendingWebhooks();
  Future<int> getWebhookEventCount();

  // APIKey Management
  Future<APIKey> createAPIKey(String partnerId, List<String> allowedEndpoints, DateTime? expiresAt, int? rateLimit);
  Future<APIKey?> getAPIKey(String keyId);
  Future<APIKey> updateAPIKeyStatus(String keyId, bool isActive);
  Future<void> deleteAPIKey(String keyId);
  Future<List<APIKey>> listAPIKeys({int limit = 50, int offset = 0});
  Future<List<APIKey>> getAPIKeysByPartner(String partnerId);
  Future<int> getAPIKeyCount();

  // RequestLog Management
  Future<RequestLog> logRequest(String endpointId, String method, String path, int statusCode, int latencyMs, {String? error});
  Future<RequestLog?> getRequestLog(String logId);
  Future<List<RequestLog>> listRequestLogs({int limit = 100, int offset = 0});
  Future<List<RequestLog>> getRequestLogsByEndpoint(String endpointId);
  Future<List<RequestLog>> getErrorLogs();
  Future<List<RequestLog>> getSlowRequests();
  Future<int> getRequestLogCount();

  // ResponseCache Management
  Future<ResponseCache> cacheResponse(String endpointId, String requestHash, String response, int ttlSeconds, {String? etag});
  Future<ResponseCache?> getCachedResponse(String cacheId);
  Future<ResponseCache> incrementCacheHit(String cacheId);
  Future<void> deleteCachedResponse(String cacheId);
  Future<List<ResponseCache>> listCachedResponses({int limit = 100, int offset = 0});
  Future<List<ResponseCache>> getValidCaches();
  Future<int> getCacheCount();

  // IntegrationMetrics
  Future<IntegrationMetrics> generateMetrics(String partnerId, DateTime periodStart, DateTime periodEnd);
  Future<IntegrationMetrics?> getMetrics(String metricsId);
  Future<List<IntegrationMetrics>> listMetrics({int limit = 50, int offset = 0});
  Future<List<IntegrationMetrics>> getMetricsByPartner(String partnerId);
}

// In-Memory Implementation
class IntegrationRepositoryImpl implements IntegrationRepository {
  final Map<String, APIEndpoint> _endpoints = {};
  final Map<String, IntegrationPartner> _partners = {};
  final Map<String, APIRoute> _routes = {};
  final Map<String, RateLimiter> _limiters = {};
  final Map<String, CachePolicy> _policies = {};
  final Map<String, CircuitBreaker> _breakers = {};
  final Map<String, WebhookEvent> _webhooks = {};
  final Map<String, APIKey> _keys = {};
  final Map<String, RequestLog> _logs = {};
  final Map<String, ResponseCache> _cache = {};
  final Map<String, IntegrationMetrics> _metrics = {};

  String _generateId() => 'id_${DateTime.now().millisecondsSinceEpoch}_${_randomString()}';
  String _randomString() => (DateTime.now().microsecond % 10000).toString();

  // APIEndpoint
  @override
  Future<APIEndpoint> createEndpoint(String path, String method, String description, String version, List<String> contentTypes) async {
    final endpoint = APIEndpoint(
      endpointId: _generateId(),
      path: path,
      method: method,
      description: description,
      version: version,
      supportedContentTypes: contentTypes,
      createdAt: DateTime.now(),
    );
    _endpoints[endpoint.endpointId] = endpoint;
    return endpoint;
  }

  @override
  Future<APIEndpoint?> getEndpoint(String endpointId) async => _endpoints[endpointId];

  @override
  Future<APIEndpoint> updateEndpoint(String endpointId, {bool? isActive, int? timeoutMs}) async {
    final endpoint = _endpoints[endpointId];
    if (endpoint == null) throw Exception('Endpoint not found');
    final updated = APIEndpoint(
      endpointId: endpoint.endpointId,
      path: endpoint.path,
      method: endpoint.method,
      description: endpoint.description,
      version: endpoint.version,
      supportedContentTypes: endpoint.supportedContentTypes,
      createdAt: endpoint.createdAt,
      isActive: isActive ?? endpoint.isActive,
      timeoutMs: timeoutMs ?? endpoint.timeoutMs,
    );
    _endpoints[endpointId] = updated;
    return updated;
  }

  @override
  Future<void> deleteEndpoint(String endpointId) async => _endpoints.remove(endpointId);

  @override
  Future<List<APIEndpoint>> listEndpoints({int limit = 50, int offset = 0}) async {
    return _endpoints.values.skip(offset).take(limit).toList();
  }

  @override
  Future<List<APIEndpoint>> getEndpointsByMethod(String method) async {
    return _endpoints.values.where((e) => e.method == method).toList();
  }

  @override
  Future<List<APIEndpoint>> getActiveEndpoints() async {
    return _endpoints.values.where((e) => e.isActive).toList();
  }

  @override
  Future<int> getEndpointCount() async => _endpoints.length;

  // IntegrationPartner
  @override
  Future<IntegrationPartner> createPartner(String name, String baseUrl, IntegrationMethod method, String? contactEmail) async {
    final partner = IntegrationPartner(
      partnerId: _generateId(),
      partnerName: name,
      apiBaseUrl: baseUrl,
      method: method,
      status: IntegrationStatus.active,
      connectedAt: DateTime.now(),
      contactEmail: contactEmail,
      metadata: {},
    );
    _partners[partner.partnerId] = partner;
    return partner;
  }

  @override
  Future<IntegrationPartner?> getPartner(String partnerId) async => _partners[partnerId];

  @override
  Future<IntegrationPartner> updatePartnerStatus(String partnerId, IntegrationStatus status) async {
    final partner = _partners[partnerId];
    if (partner == null) throw Exception('Partner not found');
    final updated = IntegrationPartner(
      partnerId: partner.partnerId,
      partnerName: partner.partnerName,
      apiBaseUrl: partner.apiBaseUrl,
      method: partner.method,
      status: status,
      connectedAt: partner.connectedAt,
      contactEmail: partner.contactEmail,
      metadata: partner.metadata,
    );
    _partners[partnerId] = updated;
    return updated;
  }

  @override
  Future<void> deletePartner(String partnerId) async => _partners.remove(partnerId);

  @override
  Future<List<IntegrationPartner>> listPartners({int limit = 50, int offset = 0}) async {
    return _partners.values.skip(offset).take(limit).toList();
  }

  @override
  Future<List<IntegrationPartner>> getPartnersByMethod(IntegrationMethod method) async {
    return _partners.values.where((p) => p.method == method).toList();
  }

  @override
  Future<List<IntegrationPartner>> getActivePartners() async {
    return _partners.values.where((p) => p.isActive).toList();
  }

  @override
  Future<int> getPartnerCount() async => _partners.length;

  // APIRoute
  @override
  Future<APIRoute> createRoute(String sourceEndpointId, List<String> targetPartnerIds, GatewayStrategy strategy, int priority) async {
    final route = APIRoute(
      routeId: _generateId(),
      sourceEndpointId: sourceEndpointId,
      targetPartnerIds: targetPartnerIds,
      strategy: strategy,
      priority: priority,
      createdAt: DateTime.now(),
      transformationRules: {},
    );
    _routes[route.routeId] = route;
    return route;
  }

  @override
  Future<APIRoute?> getRoute(String routeId) async => _routes[routeId];

  @override
  Future<APIRoute> updateRoute(String routeId, {GatewayStrategy? strategy, int? priority, bool? isActive}) async {
    final route = _routes[routeId];
    if (route == null) throw Exception('Route not found');
    final updated = APIRoute(
      routeId: route.routeId,
      sourceEndpointId: route.sourceEndpointId,
      targetPartnerIds: route.targetPartnerIds,
      strategy: strategy ?? route.strategy,
      priority: priority ?? route.priority,
      createdAt: route.createdAt,
      isActive: isActive ?? route.isActive,
      transformationRules: route.transformationRules,
    );
    _routes[routeId] = updated;
    return updated;
  }

  @override
  Future<void> deleteRoute(String routeId) async => _routes.remove(routeId);

  @override
  Future<List<APIRoute>> listRoutes({int limit = 50, int offset = 0}) async {
    return _routes.values.skip(offset).take(limit).toList();
  }

  @override
  Future<List<APIRoute>> getRoutesByEndpoint(String endpointId) async {
    return _routes.values.where((r) => r.sourceEndpointId == endpointId).toList();
  }

  @override
  Future<List<APIRoute>> getActiveRoutes() async {
    return _routes.values.where((r) => r.isActive).toList();
  }

  @override
  Future<int> getRouteCount() async => _routes.length;

  // RateLimiter
  @override
  Future<RateLimiter> createRateLimiter(String endpointId, RateLimitStrategy strategy, int requestsPerWindow, int windowSizeSeconds) async {
    final limiter = RateLimiter(
      limiterId: _generateId(),
      endpointId: endpointId,
      strategy: strategy,
      requestsPerWindow: requestsPerWindow,
      windowSizeSeconds: windowSizeSeconds,
      createdAt: DateTime.now(),
    );
    _limiters[limiter.limiterId] = limiter;
    return limiter;
  }

  @override
  Future<RateLimiter?> getRateLimiter(String limiterId) async => _limiters[limiterId];

  @override
  Future<RateLimiter> updateRateLimiter(String limiterId, {int? requestsPerWindow, bool? isActive}) async {
    final limiter = _limiters[limiterId];
    if (limiter == null) throw Exception('Rate limiter not found');
    final updated = RateLimiter(
      limiterId: limiter.limiterId,
      endpointId: limiter.endpointId,
      strategy: limiter.strategy,
      requestsPerWindow: requestsPerWindow ?? limiter.requestsPerWindow,
      windowSizeSeconds: limiter.windowSizeSeconds,
      createdAt: limiter.createdAt,
      isActive: isActive ?? limiter.isActive,
      description: limiter.description,
    );
    _limiters[limiterId] = updated;
    return updated;
  }

  @override
  Future<void> deleteRateLimiter(String limiterId) async => _limiters.remove(limiterId);

  @override
  Future<List<RateLimiter>> listRateLimiters({int limit = 50, int offset = 0}) async {
    return _limiters.values.skip(offset).take(limit).toList();
  }

  @override
  Future<RateLimiter?> getRateLimiterByEndpoint(String endpointId) async {
    return _limiters.values.firstWhereOrNull((l) => l.endpointId == endpointId);
  }

  @override
  Future<int> getRateLimiterCount() async => _limiters.length;

  // CachePolicy
  @override
  Future<CachePolicy> createCachePolicy(String endpointId, CachePolicyType type, int ttlSeconds, List<String> keyPatterns) async {
    final policy = CachePolicy(
      policyId: _generateId(),
      endpointId: endpointId,
      type: type,
      ttlSeconds: ttlSeconds,
      createdAt: DateTime.now(),
      cacheKeyPatterns: keyPatterns,
    );
    _policies[policy.policyId] = policy;
    return policy;
  }

  @override
  Future<CachePolicy?> getCachePolicy(String policyId) async => _policies[policyId];

  @override
  Future<CachePolicy> updateCachePolicy(String policyId, {CachePolicyType? type, int? ttlSeconds, bool? isActive}) async {
    final policy = _policies[policyId];
    if (policy == null) throw Exception('Cache policy not found');
    final updated = CachePolicy(
      policyId: policy.policyId,
      endpointId: policy.endpointId,
      type: type ?? policy.type,
      ttlSeconds: ttlSeconds ?? policy.ttlSeconds,
      createdAt: policy.createdAt,
      isActive: isActive ?? policy.isActive,
      cacheKeyPatterns: policy.cacheKeyPatterns,
    );
    _policies[policyId] = updated;
    return updated;
  }

  @override
  Future<void> deleteCachePolicy(String policyId) async => _policies.remove(policyId);

  @override
  Future<List<CachePolicy>> listCachePolicies({int limit = 50, int offset = 0}) async {
    return _policies.values.skip(offset).take(limit).toList();
  }

  @override
  Future<CachePolicy?> getCachePolicyByEndpoint(String endpointId) async {
    return _policies.values.firstWhereOrNull((p) => p.endpointId == endpointId);
  }

  @override
  Future<int> getCachePolicyCount() async => _policies.length;

  // CircuitBreaker
  @override
  Future<CircuitBreaker> createCircuitBreaker(String partnerId, int failureThreshold, int successThreshold, int timeoutMs) async {
    final breaker = CircuitBreaker(
      breakerId: _generateId(),
      partnerId: partnerId,
      failureThreshold: failureThreshold,
      successThreshold: successThreshold,
      timeoutMs: timeoutMs,
      createdAt: DateTime.now(),
    );
    _breakers[breaker.breakerId] = breaker;
    return breaker;
  }

  @override
  Future<CircuitBreaker?> getCircuitBreaker(String breakerId) async => _breakers[breakerId];

  @override
  Future<CircuitBreaker> updateCircuitBreakerState(String breakerId, String state) async {
    final breaker = _breakers[breakerId];
    if (breaker == null) throw Exception('Circuit breaker not found');
    final updated = CircuitBreaker(
      breakerId: breaker.breakerId,
      partnerId: breaker.partnerId,
      failureThreshold: breaker.failureThreshold,
      successThreshold: breaker.successThreshold,
      timeoutMs: breaker.timeoutMs,
      createdAt: breaker.createdAt,
      currentState: state,
    );
    _breakers[breakerId] = updated;
    return updated;
  }

  @override
  Future<void> deleteCircuitBreaker(String breakerId) async => _breakers.remove(breakerId);

  @override
  Future<List<CircuitBreaker>> listCircuitBreakers({int limit = 50, int offset = 0}) async {
    return _breakers.values.skip(offset).take(limit).toList();
  }

  @override
  Future<CircuitBreaker?> getCircuitBreakerByPartner(String partnerId) async {
    return _breakers.values.firstWhereOrNull((b) => b.partnerId == partnerId);
  }

  @override
  Future<int> getCircuitBreakerCount() async => _breakers.length;

  // WebhookEvent
  @override
  Future<WebhookEvent> recordWebhookEvent(String partnerId, String eventType, Map<String, dynamic> payload) async {
    final event = WebhookEvent(
      eventId: _generateId(),
      partnerId: partnerId,
      eventType: eventType,
      payload: payload,
      occurredAt: DateTime.now(),
      deliveryStatus: 'pending',
    );
    _webhooks[event.eventId] = event;
    return event;
  }

  @override
  Future<WebhookEvent?> getWebhookEvent(String eventId) async => _webhooks[eventId];

  @override
  Future<WebhookEvent> updateWebhookDelivery(String eventId, {int? attempts, DateTime? deliveredAt, String? status}) async {
    final event = _webhooks[eventId];
    if (event == null) throw Exception('Webhook event not found');
    final updated = WebhookEvent(
      eventId: event.eventId,
      partnerId: event.partnerId,
      eventType: event.eventType,
      payload: event.payload,
      occurredAt: event.occurredAt,
      deliveryAttempts: attempts ?? event.deliveryAttempts,
      deliveredAt: deliveredAt ?? event.deliveredAt,
      deliveryStatus: status ?? event.deliveryStatus,
    );
    _webhooks[eventId] = updated;
    return updated;
  }

  @override
  Future<void> deleteWebhookEvent(String eventId) async => _webhooks.remove(eventId);

  @override
  Future<List<WebhookEvent>> listWebhookEvents({int limit = 50, int offset = 0}) async {
    return _webhooks.values.skip(offset).take(limit).toList();
  }

  @override
  Future<List<WebhookEvent>> getPendingWebhooks() async {
    return _webhooks.values.where((e) => e.isPending).toList();
  }

  @override
  Future<int> getWebhookEventCount() async => _webhooks.length;

  // APIKey
  @override
  Future<APIKey> createAPIKey(String partnerId, List<String> allowedEndpoints, DateTime? expiresAt, int? rateLimit) async {
    final key = APIKey(
      keyId: _generateId(),
      partnerId: partnerId,
      keyHash: 'hash_${_generateId()}',
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      allowedEndpoints: allowedEndpoints,
      rateLimit: rateLimit,
    );
    _keys[key.keyId] = key;
    return key;
  }

  @override
  Future<APIKey?> getAPIKey(String keyId) async => _keys[keyId];

  @override
  Future<APIKey> updateAPIKeyStatus(String keyId, bool isActive) async {
    final key = _keys[keyId];
    if (key == null) throw Exception('API key not found');
    final updated = APIKey(
      keyId: key.keyId,
      partnerId: key.partnerId,
      keyHash: key.keyHash,
      createdAt: key.createdAt,
      expiresAt: key.expiresAt,
      allowedEndpoints: key.allowedEndpoints,
      isActive: isActive,
      rateLimit: key.rateLimit,
    );
    _keys[keyId] = updated;
    return updated;
  }

  @override
  Future<void> deleteAPIKey(String keyId) async => _keys.remove(keyId);

  @override
  Future<List<APIKey>> listAPIKeys({int limit = 50, int offset = 0}) async {
    return _keys.values.skip(offset).take(limit).toList();
  }

  @override
  Future<List<APIKey>> getAPIKeysByPartner(String partnerId) async {
    return _keys.values.where((k) => k.partnerId == partnerId).toList();
  }

  @override
  Future<int> getAPIKeyCount() async => _keys.length;

  // RequestLog
  @override
  Future<RequestLog> logRequest(String endpointId, String method, String path, int statusCode, int latencyMs, {String? error}) async {
    final log = RequestLog(
      logId: _generateId(),
      endpointId: endpointId,
      method: method,
      path: path,
      statusCode: statusCode,
      latencyMs: latencyMs,
      timestamp: DateTime.now(),
      error: error,
      metadata: {},
    );
    _logs[log.logId] = log;
    return log;
  }

  @override
  Future<RequestLog?> getRequestLog(String logId) async => _logs[logId];

  @override
  Future<List<RequestLog>> listRequestLogs({int limit = 100, int offset = 0}) async {
    return _logs.values.skip(offset).take(limit).toList();
  }

  @override
  Future<List<RequestLog>> getRequestLogsByEndpoint(String endpointId) async {
    return _logs.values.where((l) => l.endpointId == endpointId).toList();
  }

  @override
  Future<List<RequestLog>> getErrorLogs() async {
    return _logs.values.where((l) => l.isError).toList();
  }

  @override
  Future<List<RequestLog>> getSlowRequests() async {
    return _logs.values.where((l) => l.isSlowRequest).toList();
  }

  @override
  Future<int> getRequestLogCount() async => _logs.length;

  // ResponseCache
  @override
  Future<ResponseCache> cacheResponse(String endpointId, String requestHash, String response, int ttlSeconds, {String? etag}) async {
    final cache = ResponseCache(
      cacheId: _generateId(),
      endpointId: endpointId,
      requestHash: requestHash,
      cachedResponse: response,
      cachedAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(seconds: ttlSeconds)),
      etagValue: etag,
    );
    _cache[cache.cacheId] = cache;
    return cache;
  }

  @override
  Future<ResponseCache?> getCachedResponse(String cacheId) async => _cache[cacheId];

  @override
  Future<ResponseCache> incrementCacheHit(String cacheId) async {
    final cache = _cache[cacheId];
    if (cache == null) throw Exception('Cache entry not found');
    final updated = ResponseCache(
      cacheId: cache.cacheId,
      endpointId: cache.endpointId,
      requestHash: cache.requestHash,
      cachedResponse: cache.cachedResponse,
      cachedAt: cache.cachedAt,
      expiresAt: cache.expiresAt,
      hitCount: cache.hitCount + 1,
      etagValue: cache.etagValue,
    );
    _cache[cacheId] = updated;
    return updated;
  }

  @override
  Future<void> deleteCachedResponse(String cacheId) async => _cache.remove(cacheId);

  @override
  Future<List<ResponseCache>> listCachedResponses({int limit = 100, int offset = 0}) async {
    return _cache.values.skip(offset).take(limit).toList();
  }

  @override
  Future<List<ResponseCache>> getValidCaches() async {
    return _cache.values.where((c) => c.isValid).toList();
  }

  @override
  Future<int> getCacheCount() async => _cache.length;

  // IntegrationMetrics
  @override
  Future<IntegrationMetrics> generateMetrics(String partnerId, DateTime periodStart, DateTime periodEnd) async {
    final metrics = IntegrationMetrics(
      metricsId: _generateId(),
      partnerId: partnerId,
      periodStart: periodStart,
      periodEnd: periodEnd,
      totalRequests: 0,
      successfulRequests: 0,
      failedRequests: 0,
      averageLatencyMs: 0.0,
      p99LatencyMs: 0.0,
      endpointStats: {},
    );
    _metrics[metrics.metricsId] = metrics;
    return metrics;
  }

  @override
  Future<IntegrationMetrics?> getMetrics(String metricsId) async => _metrics[metricsId];

  @override
  Future<List<IntegrationMetrics>> listMetrics({int limit = 50, int offset = 0}) async {
    return _metrics.values.skip(offset).take(limit).toList();
  }

  @override
  Future<List<IntegrationMetrics>> getMetricsByPartner(String partnerId) async {
    return _metrics.values.where((m) => m.partnerId == partnerId).toList();
  }
}

extension _ListExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

// Engines
class IntegrationEngine {
  Future<void> integratePartner(IntegrationPartner partner) async {
    // Validate partner connection
    if (partner.apiBaseUrl.isEmpty) throw Exception('Invalid base URL');
  }
}

class APIRoutingEngine {
  Future<void> routeRequest(APIRoute route, String request) async {
    // Route request to appropriate partner based on strategy
    if (route.targetPartnerIds.isEmpty) throw Exception('No targets');
  }
}

class RateLimitingEngine {
  Future<bool> checkRateLimit(RateLimiter limiter, String identifier) async {
    // Check if request is within rate limit
    return true;
  }
}

class CachingEngine {
  Future<String?> getFromCache(CachePolicy policy, String key) async {
    // Retrieve from cache if valid
    return null;
  }
}

class CircuitBreakerEngine {
  Future<void> evaluateHealth(CircuitBreaker breaker) async {
    // Evaluate partner health and manage state
  }
}

// Manager
class IntegrationManager {
  final IntegrationRepository repository;
  final IntegrationEngine integrationEngine;
  final APIRoutingEngine routingEngine;
  final RateLimitingEngine rateLimitEngine;
  final CachingEngine cachingEngine;
  final CircuitBreakerEngine circuitBreakerEngine;

  IntegrationManager({
    required this.repository,
    required this.integrationEngine,
    required this.routingEngine,
    required this.rateLimitEngine,
    required this.cachingEngine,
    required this.circuitBreakerEngine,
  });
}

// Facade
class IntegrationFacade {
  final IntegrationRepository repository;
  final IntegrationManager manager;

  IntegrationFacade({
    required this.repository,
    required this.manager,
  });

  Future<APIEndpoint> createEndpoint(String path, String method, String description) async {
    return repository.createEndpoint(path, method, description, '1.0', ['application/json']);
  }

  Future<IntegrationPartner> addPartner(String name, String baseUrl, IntegrationMethod method) async {
    return repository.createPartner(name, baseUrl, method, null);
  }

  Future<bool> canRouteRequest(String endpointId) async {
    final endpoint = await repository.getEndpoint(endpointId);
    return endpoint != null && endpoint.isActive;
  }

  Future<int> getHealthyPartnerCount() async {
    final partners = await repository.getActivePartners();
    return partners.length;
  }
}
