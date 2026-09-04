/// Phase 55: API Integration & Webhooks APIインテグレーション・ウェブフック

/// HTTPメソッド
enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE'),
  head('HEAD');

  final String value;
  const HttpMethod(this.value);
}

/// Webhook イベントタイプ
enum WebhookEventType {
  jobCreated('job.created'),
  jobCompleted('job.completed'),
  jobFailed('job.failed'),
  jobCancelled('job.cancelled'),
  monitoringAlert('monitoring.alert'),
  reportGenerated('report.generated'),
  errorOccurred('error.occurred'),
  dataUpdated('data.updated');

  final String value;
  const WebhookEventType(this.value);
}

/// リトライポリシー
enum RetryPolicy {
  noRetry('no_retry'),
  exponential('exponential'),
  linear('linear'),
  fibonacci('fibonacci');

  final String value;
  const RetryPolicy(this.value);
}

/// APIエンドポイント
class ApiEndpoint {
  final String endpointId;
  final String name;
  final String baseUrl;
  final HttpMethod httpMethod;
  final String path;
  final Map<String, String> headers;
  final int timeoutSeconds;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  ApiEndpoint({
    required this.endpointId,
    required this.name,
    required this.baseUrl,
    required this.httpMethod,
    required this.path,
    required this.headers,
    required this.timeoutSeconds,
    this.isActive = true,
    required this.createdAt,
    this.lastUsedAt,
  });

  /// エンドポイントが有効か
  bool get isValid => isActive && (DateTime.now().difference(createdAt).inDays < 365);

  /// 完全URL
  String get fullUrl => '$baseUrl$path';

  /// 使用済みか
  bool get isUsed => lastUsedAt != null;

  /// 最後の使用からの日数
  int? get daysSinceLastUse => lastUsedAt != null 
    ? DateTime.now().difference(lastUsedAt!).inDays 
    : null;
}

/// APIリクエスト
class ApiRequest {
  final String requestId;
  final String endpointId;
  final HttpMethod method;
  final String url;
  final Map<String, String>? headers;
  final dynamic body;
  final DateTime sentAt;
  final int? responseStatusCode;
  final String? responseBody;
  final DateTime? receivedAt;
  final bool isSuccessful;
  final String? errorMessage;

  ApiRequest({
    required this.requestId,
    required this.endpointId,
    required this.method,
    required this.url,
    this.headers,
    this.body,
    required this.sentAt,
    this.responseStatusCode,
    this.responseBody,
    this.receivedAt,
    this.isSuccessful = false,
    this.errorMessage,
  });

  /// リクエストが完了したか
  bool get isCompleted => receivedAt != null;

  /// レスポンス時間（ミリ秒）
  int? get responseTimeMs => receivedAt != null
    ? receivedAt!.difference(sentAt).inMilliseconds
    : null;

  /// ステータスコードが成功か
  bool get isStatusSuccess => responseStatusCode != null && responseStatusCode! >= 200 && responseStatusCode! < 300;
}

/// Webhook エンドポイント
class WebhookEndpoint {
  final String webhookId;
  final String targetUrl;
  final List<WebhookEventType> events;
  final Map<String, String>? headers;
  final RetryPolicy retryPolicy;
  final int maxRetries;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastTriggeredAt;
  final String? secret;

  WebhookEndpoint({
    required this.webhookId,
    required this.targetUrl,
    required this.events,
    this.headers,
    required this.retryPolicy,
    required this.maxRetries,
    this.isActive = true,
    required this.createdAt,
    this.lastTriggeredAt,
    this.secret,
  });

  /// Webhookが有効か
  bool get isEnabled => isActive;

  /// トリガーされたか
  bool get isTriggered => lastTriggeredAt != null;

  /// イベント数
  int get eventCount => events.length;
}

/// Webhook ペイロード
class WebhookPayload {
  final String payloadId;
  final String webhookId;
  final WebhookEventType eventType;
  final DateTime triggeredAt;
  final Map<String, dynamic> data;
  final String? signature;
  final int attemptCount;
  final WebhookPayloadStatus status;
  final String? lastError;

  WebhookPayload({
    required this.payloadId,
    required this.webhookId,
    required this.eventType,
    required this.triggeredAt,
    required this.data,
    this.signature,
    this.attemptCount = 0,
    this.status = WebhookPayloadStatus.pending,
    this.lastError,
  });

  /// ペイロードが保留中か
  bool get isPending => status == WebhookPayloadStatus.pending;

  /// ペイロードが成功したか
  bool get isSuccessful => status == WebhookPayloadStatus.delivered;

  /// ペイロードが失敗したか
  bool get isFailed => status == WebhookPayloadStatus.failed;
}

/// Webhook ペイロードステータス
enum WebhookPayloadStatus {
  pending('pending'),
  delivered('delivered'),
  failed('failed'),
  retrying('retrying');

  final String value;
  const WebhookPayloadStatus(this.value);
}

/// API 設定
class ApiConfiguration {
  final String configId;
  final String name;
  final String apiKey;
  final String? apiSecret;
  final int rateLimit; // リクエスト数/分
  final Duration timeout;
  final RetryPolicy retryPolicy;
  final int maxRetries;
  final bool isActive;
  final DateTime createdAt;

  ApiConfiguration({
    required this.configId,
    required this.name,
    required this.apiKey,
    this.apiSecret,
    required this.rateLimit,
    required this.timeout,
    required this.retryPolicy,
    required this.maxRetries,
    this.isActive = true,
    required this.createdAt,
  });

  /// 設定が有効か
  bool get isEnabled => isActive;

  /// レート制限が高いか
  bool get hasHighRateLimit => rateLimit > 100;

  /// タイムアウトが長いか
  bool get hasLongTimeout => timeout.inSeconds > 30;
}

/// Webhook イベント
class WebhookEvent {
  final String eventId;
  final WebhookEventType eventType;
  final DateTime occurredAt;
  final Map<String, dynamic> payload;
  final String? source; // ジョブID等
  final List<String> webhookIds; // トリガーされたWebhook

  WebhookEvent({
    required this.eventId,
    required this.eventType,
    required this.occurredAt,
    required this.payload,
    this.source,
    required this.webhookIds,
  });

  /// イベントが発火したか
  bool get isTriggered => webhookIds.isNotEmpty;

  /// トリガーされたWebhook数
  int get triggeredCount => webhookIds.length;
}

/// API メトリクス
class ApiMetrics {
  final String metricsId;
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final double averageResponseTimeMs;
  final int totalWebhooks;
  final int successfulWebhooks;
  final int failedWebhooks;
  final DateTime periodStart;
  final DateTime periodEnd;

  ApiMetrics({
    required this.metricsId,
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.averageResponseTimeMs,
    required this.totalWebhooks,
    required this.successfulWebhooks,
    required this.failedWebhooks,
    required this.periodStart,
    required this.periodEnd,
  });

  /// 成功率
  double get successRate {
    if (totalRequests == 0) return 0.0;
    return successfulRequests / totalRequests;
  }

  /// Webhook成功率
  double get webhookSuccessRate {
    if (totalWebhooks == 0) return 0.0;
    return successfulWebhooks / totalWebhooks;
  }

  /// メトリクスが良好か
  bool get isHealthy => successRate > 0.95 && webhookSuccessRate > 0.90;
}

/// API レポート
class ApiReport {
  final String reportId;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<ApiEndpoint> endpoints;
  final List<ApiRequest> requests;
  final List<WebhookPayload> webhookPayloads;
  final ApiMetrics metrics;
  final List<String>? recommendations;

  ApiReport({
    required this.reportId,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.endpoints,
    required this.requests,
    required this.webhookPayloads,
    required this.metrics,
    this.recommendations,
  });

  /// Markdown形式で出力
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# API Integration Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');

    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Total Endpoints: ${endpoints.length}');
    buffer.writeln('- Total Requests: ${metrics.totalRequests}');
    buffer.writeln('- Success Rate: ${(metrics.successRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('- Avg Response Time: ${metrics.averageResponseTimeMs.toStringAsFixed(0)}ms');
    buffer.writeln('- Total Webhooks: ${metrics.totalWebhooks}');
    buffer.writeln('- Webhook Success Rate: ${(metrics.webhookSuccessRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('');

    buffer.writeln('## Endpoints');
    buffer.writeln('');
    for (final endpoint in endpoints.take(5)) {
      buffer.writeln('- **${endpoint.name}**: ${endpoint.httpMethod.value} ${endpoint.fullUrl}');
      buffer.writeln('  - Active: ${endpoint.isActive}');
    }
    buffer.writeln('');

    if (recommendations != null && recommendations!.isNotEmpty) {
      buffer.writeln('## Recommendations');
      buffer.writeln('');
      for (final rec in recommendations!.take(5)) {
        buffer.writeln('- $rec');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}

/// API レート制限情報
class RateLimitInfo {
  final String limitId;
  final String configId;
  final int requestLimit; // リクエスト数/分
  final int currentCount;
  final DateTime windowStart;
  final DateTime windowEnd;

  RateLimitInfo({
    required this.limitId,
    required this.configId,
    required this.requestLimit,
    required this.currentCount,
    required this.windowStart,
    required this.windowEnd,
  });

  /// レート制限に達したか
  bool get isLimited => currentCount >= requestLimit;

  /// 残り許可リクエスト数
  int get remainingRequests => (requestLimit - currentCount).clamp(0, requestLimit);

  /// リセットまでの秒数
  int get resetInSeconds {
    final now = DateTime.now();
    return windowEnd.difference(now).inSeconds.clamp(0, 60);
  }
}
