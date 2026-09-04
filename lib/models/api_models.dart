/// API Integration & Webhook Models for Enterprise Job Monitoring System
///
/// This module provides comprehensive data models for:
/// - External API integration
/// - Webhook management and delivery
/// - API authentication and authorization
/// - Rate limiting and quota management
/// - Request/response handling and transformation
/// - Error tracking and retry management

// ============================================================================
// ENUMS
// ============================================================================

/// Supported HTTP methods for API requests
enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE'),
  head('HEAD'),
  options('OPTIONS');

  final String value;
  const HttpMethod(this.value);
}

/// Content type formats for API requests/responses
enum ContentType {
  json('application/json'),
  xml('application/xml'),
  formEncoded('application/x-www-form-urlencoded'),
  multipart('multipart/form-data'),
  plainText('text/plain'),
  html('text/html');

  final String value;
  const ContentType(this.value);
}

/// API authentication types
enum AuthType {
  none('none'),
  basic('basic'),
  bearer('bearer'),
  apiKey('api_key'),
  oauth2('oauth2'),
  custom('custom');

  final String value;
  const AuthType(this.value);
}

/// HTTP status code categories
enum HttpStatusCategory {
  informational('1xx'),
  success('2xx'),
  redirection('3xx'),
  clientError('4xx'),
  serverError('5xx');

  final String value;
  const HttpStatusCategory(this.value);
}

/// Webhook event types
enum WebhookEventType {
  jobCreated('job.created'),
  jobStarted('job.started'),
  jobCompleted('job.completed'),
  jobFailed('job.failed'),
  jobCancelled('job.cancelled'),
  jobStatusChanged('job.status_changed'),
  alertTriggered('alert.triggered'),
  notificationSent('notification.sent'),
  userAction('user.action'),
  custom('custom');

  final String value;
  const WebhookEventType(this.value);
}

/// Webhook delivery status
enum WebhookStatus {
  active('active'),
  inactive('inactive'),
  suspended('suspended'),
  failed('failed'),
  deleted('deleted');

  final String value;
  const WebhookStatus(this.value);
}

/// Webhook delivery attempt status
enum DeliveryAttemptStatus {
  pending('pending'),
  sent('sent'),
  succeeded('succeeded'),
  failed('failed'),
  retrying('retrying'),
  maxRetriesExceeded('max_retries_exceeded');

  final String value;
  const DeliveryAttemptStatus(this.value);
}

/// Rate limit strategies
enum RateLimitStrategy {
  fixed('fixed'),
  sliding('sliding'),
  token('token'),
  adaptive('adaptive');

  final String value;
  const RateLimitStrategy(this.value);
}

/// API integration status
enum ApiIntegrationStatus {
  connected('connected'),
  disconnected('disconnected'),
  authenticating('authenticating'),
  error('error'),
  rateLimited('rate_limited');

  final String value;
  const ApiIntegrationStatus(this.value);
}

/// OAuth2 grant types
enum GrantType {
  authorizationCode('authorization_code'),
  clientCredentials('client_credentials'),
  implicit('implicit'),
  resourceOwnerPasswordCredentials('password'),
  refreshToken('refresh_token');

  final String value;
  const GrantType(this.value);
}

// ============================================================================
// MODELS
// ============================================================================

/// Represents an external API configuration
class ApiConfiguration {
  final String configId;
  final String apiName;
  final String baseUrl;
  final HttpMethod defaultMethod;
  final ContentType contentType;
  final AuthType authType;
  final Map<String, String> headers;
  final int timeoutSeconds;
  final int maxRetries;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ApiConfiguration({
    required this.configId,
    required this.apiName,
    required this.baseUrl,
    required this.defaultMethod,
    required this.contentType,
    required this.authType,
    required this.headers,
    this.timeoutSeconds = 30,
    this.maxRetries = 3,
    this.isEnabled = true,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isRecent => DateTime.now().difference(createdAt).inDays < 30;
  bool get isConfigured => baseUrl.isNotEmpty && authType != AuthType.none;
  int get headerCount => headers.length;
  bool get supportsJsonContent => contentType == ContentType.json;
}

/// Represents API authentication credentials
class ApiCredential {
  final String credentialId;
  final String configId;
  final AuthType authType;
  final String? apiKey;
  final String? username;
  final String? password;
  final String? bearerToken;
  final String? clientId;
  final String? clientSecret;
  final String? refreshToken;
  final DateTime? expiresAt;
  final bool isActive;
  final DateTime createdAt;

  ApiCredential({
    required this.credentialId,
    required this.configId,
    required this.authType,
    this.apiKey,
    this.username,
    this.password,
    this.bearerToken,
    this.clientId,
    this.clientSecret,
    this.refreshToken,
    this.expiresAt,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get needsRefresh => isExpired || (expiresAt != null && DateTime.now().difference(expiresAt!).inMinutes.abs() < 5);
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  bool get isRecent => ageInDays < 7;
}

/// Represents an API request
class ApiRequest {
  final String requestId;
  final String configId;
  final String endpoint;
  final HttpMethod method;
  final Map<String, dynamic>? queryParams;
  final Map<String, dynamic>? body;
  final Map<String, String>? customHeaders;
  final DateTime createdAt;
  final DateTime? sentAt;

  ApiRequest({
    required this.requestId,
    required this.configId,
    required this.endpoint,
    required this.method,
    this.queryParams,
    this.body,
    this.customHeaders,
    required this.createdAt,
    this.sentAt,
  });

  bool get isPending => sentAt == null;
  bool get isSent => sentAt != null;
  int get ageInSeconds => DateTime.now().difference(createdAt).inSeconds;
}

/// Represents an API response
class ApiResponse {
  final String responseId;
  final String requestId;
  final int statusCode;
  final Map<String, String> headers;
  final dynamic body;
  final int? contentLength;
  final DateTime receivedAt;

  ApiResponse({
    required this.responseId,
    required this.requestId,
    required this.statusCode,
    required this.headers,
    required this.body,
    this.contentLength,
    required this.receivedAt,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isError => statusCode >= 400;
  bool get isServerError => statusCode >= 500;
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isRedirect => statusCode >= 300 && statusCode < 400;
  HttpStatusCategory get category {
    if (statusCode < 200) return HttpStatusCategory.informational;
    if (statusCode < 300) return HttpStatusCategory.success;
    if (statusCode < 400) return HttpStatusCategory.redirection;
    if (statusCode < 500) return HttpStatusCategory.clientError;
    return HttpStatusCategory.serverError;
  }
}

/// Represents a rate limit quota
class RateLimit {
  final String rateLimitId;
  final String configId;
  final int requestsPerWindow;
  final int windowSizeSeconds;
  final RateLimitStrategy strategy;
  final DateTime? resetAt;
  final int remainingRequests;
  final bool isActive;

  RateLimit({
    required this.rateLimitId,
    required this.configId,
    required this.requestsPerWindow,
    required this.windowSizeSeconds,
    required this.strategy,
    this.resetAt,
    required this.remainingRequests,
    this.isActive = true,
  });

  bool get isExceeded => remainingRequests <= 0;
  bool get isLowQuota => remainingRequests < (requestsPerWindow * 0.2);
  int get requestsUsed => requestsPerWindow - remainingRequests;
  double get utilizationPercentage => (requestsUsed / requestsPerWindow) * 100;
  int? get secondsUntilReset {
    if (resetAt == null) return null;
    final remaining = resetAt!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : null;
  }
}

/// Represents a webhook configuration
class Webhook {
  final String webhookId;
  final String configId;
  final String url;
  final List<WebhookEventType> events;
  final WebhookStatus status;
  final String? secret;
  final int maxRetries;
  final int timeoutSeconds;
  final Map<String, String>? customHeaders;
  final DateTime createdAt;
  final DateTime? lastTriggeredAt;

  Webhook({
    required this.webhookId,
    required this.configId,
    required this.url,
    required this.events,
    required this.status,
    this.secret,
    this.maxRetries = 3,
    this.timeoutSeconds = 30,
    this.customHeaders,
    required this.createdAt,
    this.lastTriggeredAt,
  });

  bool get isActive => status == WebhookStatus.active;
  bool get isEnabled => isActive;
  bool get hasValidUrl => url.startsWith('http://') || url.startsWith('https://');
  int get eventCount => events.length;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  bool get isRecent => ageInDays < 7;
  int? get hoursSinceLastTrigger {
    if (lastTriggeredAt == null) return null;
    return DateTime.now().difference(lastTriggeredAt!).inHours;
  }
}

/// Represents a webhook delivery attempt
class WebhookDeliveryAttempt {
  final String attemptId;
  final String webhookId;
  final WebhookEventType eventType;
  final DeliveryAttemptStatus status;
  final int statusCode;
  final String? responseBody;
  final String? errorMessage;
  final int retryCount;
  final DateTime attemptedAt;
  final DateTime? completedAt;

  WebhookDeliveryAttempt({
    required this.attemptId,
    required this.webhookId,
    required this.eventType,
    required this.status,
    this.statusCode = 0,
    this.responseBody,
    this.errorMessage,
    this.retryCount = 0,
    required this.attemptedAt,
    this.completedAt,
  });

  bool get isSuccessful => status == DeliveryAttemptStatus.succeeded;
  bool get hasFailed => status == DeliveryAttemptStatus.failed || status == DeliveryAttemptStatus.maxRetriesExceeded;
  bool get isRetrying => status == DeliveryAttemptStatus.retrying;
  int get durationInSeconds => completedAt != null ? completedAt!.difference(attemptedAt).inSeconds : 0;
  bool get isRecent => DateTime.now().difference(attemptedAt).inHours < 24;
}

/// Represents a webhook event payload
class WebhookEvent {
  final String eventId;
  final WebhookEventType eventType;
  final String? jobId;
  final String? alertId;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  final String? userId;

  WebhookEvent({
    required this.eventId,
    required this.eventType,
    this.jobId,
    this.alertId,
    required this.metadata,
    required this.timestamp,
    this.userId,
  });

  bool get isJobRelated => jobId != null;
  bool get isAlertRelated => alertId != null;
  bool get isUserAction => eventType == WebhookEventType.userAction;
  bool get isRecent => DateTime.now().difference(timestamp).inMinutes < 5;
}

/// Represents API integration status
class ApiIntegration {
  final String integrationId;
  final String configId;
  final ApiIntegrationStatus status;
  final int requestsToday;
  final int requestsThisMonth;
  final int failedRequests;
  final double averageResponseTimeMs;
  final DateTime? lastSuccessAt;
  final DateTime? lastErrorAt;
  final String? lastErrorMessage;

  ApiIntegration({
    required this.integrationId,
    required this.configId,
    required this.status,
    this.requestsToday = 0,
    this.requestsThisMonth = 0,
    this.failedRequests = 0,
    this.averageResponseTimeMs = 0.0,
    this.lastSuccessAt,
    this.lastErrorAt,
    this.lastErrorMessage,
  });

  bool get isHealthy => status == ApiIntegrationStatus.connected && failedRequests == 0;
  bool get isConnected => status == ApiIntegrationStatus.connected;
  bool get hasErrors => lastErrorAt != null;
  double get failureRate => requestsToday > 0 ? (failedRequests / requestsToday) * 100 : 0.0;
  int? get hoursSinceLastSuccess {
    if (lastSuccessAt == null) return null;
    return DateTime.now().difference(lastSuccessAt!).inHours;
  }
}

/// Represents OAuth2 configuration
class OAuth2Config {
  final String configId;
  final String clientId;
  final String clientSecret;
  final String authorizationUrl;
  final String tokenUrl;
  final String redirectUri;
  final List<String> scopes;
  final GrantType grantType;
  final bool isActive;
  final DateTime createdAt;

  OAuth2Config({
    required this.configId,
    required this.clientId,
    required this.clientSecret,
    required this.authorizationUrl,
    required this.tokenUrl,
    required this.redirectUri,
    required this.scopes,
    required this.grantType,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isConfigured => clientId.isNotEmpty && clientSecret.isNotEmpty;
  int get scopeCount => scopes.length;
  bool get isRecent => DateTime.now().difference(createdAt).inDays < 30;
}

/// Represents an OAuth2 token
class OAuth2Token {
  final String tokenId;
  final String configId;
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final DateTime expiresAt;
  final DateTime issuedAt;

  OAuth2Token({
    required this.tokenId,
    required this.configId,
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    required this.expiresAt,
    required this.issuedAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get needsRefresh => isExpired || DateTime.now().difference(expiresAt).inMinutes.abs() < 5;
  int get ageInSeconds => DateTime.now().difference(issuedAt).inSeconds;
  int? get secondsUntilExpiration {
    final remaining = expiresAt.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : null;
  }
}

/// Represents API usage statistics
class ApiUsageStats {
  final String statsId;
  final String configId;
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final int totalResponseTimeMs;
  final int minResponseTimeMs;
  final int maxResponseTimeMs;
  final DateTime periodStart;
  final DateTime periodEnd;

  ApiUsageStats({
    required this.statsId,
    required this.configId,
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.totalResponseTimeMs,
    required this.minResponseTimeMs,
    required this.maxResponseTimeMs,
    required this.periodStart,
    required this.periodEnd,
  });

  bool get isHealthy => successRate > 95.0 && averageResponseTimeMs < 500;
  double get successRate => totalRequests > 0 ? (successfulRequests / totalRequests) * 100 : 0.0;
  double get failureRate => totalRequests > 0 ? (failedRequests / totalRequests) * 100 : 0.0;
  double get averageResponseTimeMs => totalRequests > 0 ? totalResponseTimeMs / totalRequests : 0.0;
  int get periodLengthInDays => periodEnd.difference(periodStart).inDays;
}

/// Represents webhook statistics
class WebhookStats {
  final String statsId;
  final String webhookId;
  final int totalDeliveries;
  final int successfulDeliveries;
  final int failedDeliveries;
  final double averageDeliveryTimeMs;
  final DateTime periodStart;
  final DateTime periodEnd;

  WebhookStats({
    required this.statsId,
    required this.webhookId,
    required this.totalDeliveries,
    required this.successfulDeliveries,
    required this.failedDeliveries,
    required this.averageDeliveryTimeMs,
    required this.periodStart,
    required this.periodEnd,
  });

  bool get isHealthy => successRate > 95.0;
  double get successRate => totalDeliveries > 0 ? (successfulDeliveries / totalDeliveries) * 100 : 0.0;
  double get failureRate => totalDeliveries > 0 ? (failedDeliveries / totalDeliveries) * 100 : 0.0;
  int get periodLengthInDays => periodEnd.difference(periodStart).inDays;
}

/// Represents a comprehensive API report
class ApiReport {
  final String reportId;
  final DateTime generatedAt;
  final List<ApiIntegration> integrations;
  final List<WebhookStats> webhookStats;
  final List<ApiUsageStats> usageStats;

  ApiReport({
    required this.reportId,
    required this.generatedAt,
    required this.integrations,
    required this.webhookStats,
    required this.usageStats,
  });

  bool get isHealthy => integrations.every((i) => i.isHealthy) && webhookStats.every((w) => w.isHealthy);

  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# API Integration Report');
    buffer.writeln('Generated: ${generatedAt.toIso8601String()}\n');

    buffer.writeln('## Summary');
    buffer.writeln('- Total Integrations: ${integrations.length}');
    buffer.writeln('- Healthy Integrations: ${integrations.where((i) => i.isHealthy).length}');
    buffer.writeln('- Webhooks: ${webhookStats.length}');
    buffer.writeln('- Health Status: ${isHealthy ? "✓ Healthy" : "✗ Degraded"}\n');

    buffer.writeln('## API Integrations');
    for (final integration in integrations) {
      buffer.writeln('### ${integration.configId}');
      buffer.writeln('- Status: ${integration.status.value}');
      buffer.writeln('- Requests Today: ${integration.requestsToday}');
      buffer.writeln('- Success Rate: ${100 - integration.failureRate.toStringAsFixed(2)}%');
      buffer.writeln('- Avg Response Time: ${integration.averageResponseTimeMs.toStringAsFixed(0)}ms\n');
    }

    return buffer.toString();
  }
}

/// Represents API error information
class ApiError {
  final String errorId;
  final String configId;
  final String errorType;
  final String errorMessage;
  final int? statusCode;
  final DateTime occuredAt;
  final String? requestId;

  ApiError({
    required this.errorId,
    required this.configId,
    required this.errorType,
    required this.errorMessage,
    this.statusCode,
    required this.occuredAt,
    this.requestId,
  });

  bool get isRecent => DateTime.now().difference(occuredAt).inHours < 24;
  bool get isRateLimitError => statusCode == 429 || errorType.toLowerCase().contains('rate');
  bool get isAuthenticationError => statusCode == 401 || errorType.toLowerCase().contains('auth');
  int get ageInMinutes => DateTime.now().difference(occuredAt).inMinutes;
}
