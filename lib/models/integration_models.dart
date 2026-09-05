/// Integration & API Gateway Models

enum IntegrationMethod { rest, graphql, grpc, webhook, soap, asyncQueue, eventStream }
enum APIVersionStatus { active, deprecated, archived, beta, preview }
enum GatewayStrategy { roundRobin, leastConnection, random, weighted, ipHash, consistent }
enum RateLimitStrategy { perUser, perIp, perEndpoint, global, adaptive }
enum CachePolicyType { none, ttl, conditional, etag, lastModified, always }
enum IntegrationStatus { active, inactive, suspended, deprecated, maintenance }

class APIEndpoint {
  final String endpointId;
  final String path;
  final String method;
  final String description;
  final String version;
  final List<String> supportedContentTypes;
  final DateTime createdAt;
  final bool isActive;
  final int timeoutMs;

  APIEndpoint({
    required this.endpointId,
    required this.path,
    required this.method,
    required this.description,
    required this.version,
    required this.supportedContentTypes,
    required this.createdAt,
    this.isActive = true,
    this.timeoutMs = 30000,
  });

  bool get isPublic => !path.contains('/private');
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class IntegrationPartner {
  final String partnerId;
  final String partnerName;
  final String apiBaseUrl;
  final IntegrationMethod method;
  final IntegrationStatus status;
  final DateTime connectedAt;
  final String? contactEmail;
  final Map<String, String> metadata;

  IntegrationPartner({
    required this.partnerId,
    required this.partnerName,
    required this.apiBaseUrl,
    required this.method,
    required this.status,
    required this.connectedAt,
    this.contactEmail,
    required this.metadata,
  });

  bool get isActive => status == IntegrationStatus.active;
  int get ageInDays => DateTime.now().difference(connectedAt).inDays;
}

class APIRoute {
  final String routeId;
  final String sourceEndpointId;
  final List<String> targetPartnerIds;
  final GatewayStrategy strategy;
  final int priority;
  final DateTime createdAt;
  final bool isActive;
  final Map<String, dynamic> transformationRules;

  APIRoute({
    required this.routeId,
    required this.sourceEndpointId,
    required this.targetPartnerIds,
    required this.strategy,
    required this.priority,
    required this.createdAt,
    this.isActive = true,
    required this.transformationRules,
  });

  bool get isHighPriority => priority >= 8;
  int get targetCount => targetPartnerIds.length;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class RateLimiter {
  final String limiterId;
  final String endpointId;
  final RateLimitStrategy strategy;
  final int requestsPerWindow;
  final int windowSizeSeconds;
  final DateTime createdAt;
  final bool isActive;
  final String? description;

  RateLimiter({
    required this.limiterId,
    required this.endpointId,
    required this.strategy,
    required this.requestsPerWindow,
    required this.windowSizeSeconds,
    required this.createdAt,
    this.isActive = true,
    this.description,
  });

  bool get isStrict => requestsPerWindow < 10;
  int get throughputPerSecond => (requestsPerWindow / windowSizeSeconds).ceil();
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class CachePolicy {
  final String policyId;
  final String endpointId;
  final CachePolicyType type;
  final int ttlSeconds;
  final DateTime createdAt;
  final bool isActive;
  final List<String> cacheKeyPatterns;

  CachePolicy({
    required this.policyId,
    required this.endpointId,
    required this.type,
    required this.ttlSeconds,
    required this.createdAt,
    this.isActive = true,
    required this.cacheKeyPatterns,
  });

  bool get hasShortTtl => ttlSeconds < 60;
  bool get hasLongTtl => ttlSeconds > 3600;
  int get patternCount => cacheKeyPatterns.length;
}

class CircuitBreaker {
  final String breakerId;
  final String partnerId;
  final int failureThreshold;
  final int successThreshold;
  final int timeoutMs;
  final DateTime createdAt;
  final String currentState; // open, closed, half-open

  CircuitBreaker({
    required this.breakerId,
    required this.partnerId,
    required this.failureThreshold,
    required this.successThreshold,
    required this.timeoutMs,
    required this.createdAt,
    this.currentState = 'closed',
  });

  bool get isOpen => currentState == 'open';
  bool get isClosed => currentState == 'closed';
  bool get isHalfOpen => currentState == 'half-open';
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class WebhookEvent {
  final String eventId;
  final String partnerId;
  final String eventType;
  final Map<String, dynamic> payload;
  final DateTime occurredAt;
  final int? deliveryAttempts;
  final DateTime? deliveredAt;
  final String? deliveryStatus;

  WebhookEvent({
    required this.eventId,
    required this.partnerId,
    required this.eventType,
    required this.payload,
    required this.occurredAt,
    this.deliveryAttempts,
    this.deliveredAt,
    this.deliveryStatus,
  });

  bool get isDelivered => deliveredAt != null;
  bool get isPending => deliveryStatus == 'pending' || deliveryStatus == null;
  bool get isFailed => deliveryStatus == 'failed';
  int get ageInMinutes => DateTime.now().difference(occurredAt).inMinutes;
}

class APIKey {
  final String keyId;
  final String partnerId;
  final String keyHash;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final List<String> allowedEndpoints;
  final bool isActive;
  final int? rateLimit;

  APIKey({
    required this.keyId,
    required this.partnerId,
    required this.keyHash,
    required this.createdAt,
    this.expiresAt,
    required this.allowedEndpoints,
    this.isActive = true,
    this.rateLimit,
  });

  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get isValid => isActive && !isExpired;
  int get endpointCount => allowedEndpoints.length;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class RequestLog {
  final String logId;
  final String endpointId;
  final String method;
  final String path;
  final int statusCode;
  final int latencyMs;
  final DateTime timestamp;
  final String? error;
  final Map<String, dynamic> metadata;

  RequestLog({
    required this.logId,
    required this.endpointId,
    required this.method,
    required this.path,
    required this.statusCode,
    required this.latencyMs,
    required this.timestamp,
    this.error,
    required this.metadata,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isError => statusCode >= 400;
  bool get isSlowRequest => latencyMs > 5000;
  int get ageInMinutes => DateTime.now().difference(timestamp).inMinutes;
}

class ResponseCache {
  final String cacheId;
  final String endpointId;
  final String requestHash;
  final String cachedResponse;
  final DateTime cachedAt;
  final DateTime expiresAt;
  final int hitCount;
  final String? etagValue;

  ResponseCache({
    required this.cacheId,
    required this.endpointId,
    required this.requestHash,
    required this.cachedResponse,
    required this.cachedAt,
    required this.expiresAt,
    this.hitCount = 0,
    this.etagValue,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isExpired;
  bool get isHotCache => hitCount > 100;
  int get ageInMinutes => DateTime.now().difference(cachedAt).inMinutes;
}

class IntegrationMetrics {
  final String metricsId;
  final String partnerId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final double averageLatencyMs;
  final double p99LatencyMs;
  final Map<String, int> endpointStats;

  IntegrationMetrics({
    required this.metricsId,
    required this.partnerId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.averageLatencyMs,
    required this.p99LatencyMs,
    required this.endpointStats,
  });

  double get successRate => totalRequests > 0 ? (successfulRequests / totalRequests) * 100 : 0.0;
  double get errorRate => totalRequests > 0 ? (failedRequests / totalRequests) * 100 : 0.0;
  bool get isHealthy => successRate >= 99.0 && p99LatencyMs < 5000;
  int get periodInDays => periodEnd.difference(periodStart).inDays;
}
