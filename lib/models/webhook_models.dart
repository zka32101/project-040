/// Phase 40: Webhook Management ウェブフック管理モデル定義
///
/// ウェブフックサブスクリプション、イベント、デリバリー、リトライ機能

/// ウェブフックイベントタイプ
enum WebhookEventType {
  jobCreated('job.created'),
  jobStarted('job.started'),
  jobCompleted('job.completed'),
  jobFailed('job.failed'),
  jobCancelled('job.cancelled'),
  deploymentStarted('deployment.started'),
  deploymentCompleted('deployment.completed'),
  deploymentRolledback('deployment.rolled_back'),
  featureFlagEnabled('feature_flag.enabled'),
  featureFlagDisabled('feature_flag.disabled'),
  quotaExceeded('quota.exceeded'),
  rateLimitExceeded('rate_limit.exceeded');

  final String value;
  const WebhookEventType(this.value);
}

/// ウェブフックステータス
enum WebhookStatus {
  active('active'),
  inactive('inactive'),
  suspended('suspended'),
  deleted('deleted');

  final String value;
  const WebhookStatus(this.value);
}

/// デリバリーステータス
enum DeliveryStatus {
  pending('pending'),
  delivered('delivered'),
  failed('failed'),
  retrying('retrying');

  final String value;
  const DeliveryStatus(this.value);
}

/// リトライポリシー
class RetryPolicy {
  final int maxRetries;                 // 最大リトライ回数
  final int initialDelaySeconds;        // 初期遅延 (秒)
  final int maxDelaySeconds;            // 最大遅延 (秒)
  final double backoffMultiplier;       // バックオフ乗数
  final List<int> retryableStatusCodes; // リトライ対象のステータスコード
  final bool exponentialBackoff;        // 指数バックオフ

  RetryPolicy({
    this.maxRetries = 5,
    this.initialDelaySeconds = 1,
    this.maxDelaySeconds = 3600,
    this.backoffMultiplier = 2.0,
    this.retryableStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.exponentialBackoff = true,
  });

  /// 次のリトライまでの待機時間を計算
  int getNextRetryDelay(int attemptNumber) {
    if (!exponentialBackoff) {
      return initialDelaySeconds;
    }
    final delay = initialDelaySeconds * (backoffMultiplier.pow(attemptNumber - 1)).toInt();
    return delay.clamp(initialDelaySeconds, maxDelaySeconds);
  }

  /// リトライ対象か判定
  bool isRetryable(int statusCode, int attemptNumber) {
    return attemptNumber < maxRetries && retryableStatusCodes.contains(statusCode);
  }
}

/// ウェブフックサブスクリプション
class WebhookSubscription {
  final String subscriptionId;
  final String userId;
  final String url;                     // デリバリーURL
  final List<WebhookEventType> events;  // 購読イベントタイプ
  final Map<String, dynamic>? headers;  // カスタムヘッダ
  final Map<String, dynamic>? filters;  // イベントフィルタ
  final bool active;
  final RetryPolicy retryPolicy;
  final String? secret;                 // HMAC秘密鍵
  final DateTime createdAt;
  final DateTime updatedAt;
  DateTime? lastDeliveredAt;

  WebhookSubscription({
    required this.subscriptionId,
    required this.userId,
    required this.url,
    required this.events,
    this.headers,
    this.filters,
    this.active = true,
    required this.retryPolicy,
    this.secret,
    required this.createdAt,
    required this.updatedAt,
    this.lastDeliveredAt,
  });

  /// イベントが対象か判定
  bool matchesEvent(WebhookEventType eventType) {
    return active && events.contains(eventType);
  }
}

/// ウェブフックイベント
class WebhookEvent {
  final String eventId;
  final WebhookEventType eventType;
  final String resourceId;               // イベント対象リソースID
  final String userId;                   // イベント発生ユーザーID
  final Map<String, dynamic> data;       // イベントペイロード
  final DateTime timestamp;
  final String? idempotencyKey;          // 冪等性キー
  final DateTime createdAt;

  WebhookEvent({
    required this.eventId,
    required this.eventType,
    required this.resourceId,
    required this.userId,
    required this.data,
    required this.timestamp,
    this.idempotencyKey,
    required this.createdAt,
  });

  /// JSONシリアライズ
  Map<String, dynamic> toJson() {
    return {
      'id': eventId,
      'type': eventType.value,
      'resource_id': resourceId,
      'user_id': userId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'idempotency_key': idempotencyKey,
    };
  }
}

/// ウェブフックデリバリー
class WebhookDelivery {
  final String deliveryId;
  final String subscriptionId;
  final String eventId;
  final String targetUrl;
  DeliveryStatus status;
  int? httpStatusCode;
  String? responseBody;
  int attemptNumber;
  final int maxRetries;
  DateTime? nextRetryAt;
  final DateTime createdAt;
  DateTime updatedAt;
  List<DateTime> attemptTimes;

  WebhookDelivery({
    required this.deliveryId,
    required this.subscriptionId,
    required this.eventId,
    required this.targetUrl,
    this.status = DeliveryStatus.pending,
    this.httpStatusCode,
    this.responseBody,
    this.attemptNumber = 0,
    this.maxRetries = 5,
    this.nextRetryAt,
    required this.createdAt,
    required this.updatedAt,
    List<DateTime>? attemptTimes,
  }) : attemptTimes = attemptTimes ?? [];

  /// 成功ステータスか
  bool get isSuccessful => status == DeliveryStatus.delivered;

  /// 失敗ステータスか
  bool get isFailed => status == DeliveryStatus.failed;

  /// 再試行可能か
  bool get isRetryable => attemptNumber < maxRetries && status != DeliveryStatus.delivered;

  /// デリバリーを記録
  void recordAttempt(int statusCode, String response) {
    attemptNumber++;
    httpStatusCode = statusCode;
    responseBody = response;
    attemptTimes.add(DateTime.now());
    updatedAt = DateTime.now();

    if (statusCode >= 200 && statusCode < 300) {
      status = DeliveryStatus.delivered;
    } else if (attemptNumber >= maxRetries) {
      status = DeliveryStatus.failed;
    } else {
      status = DeliveryStatus.retrying;
    }
  }

  /// 成功率を計算
  double get successRate {
    if (attemptTimes.isEmpty) return 0;
    return (status == DeliveryStatus.delivered ? 1 : 0).toDouble();
  }
}

/// ウェブフックログエントリ
class WebhookLogEntry {
  final String logId;
  final String deliveryId;
  final String message;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  WebhookLogEntry({
    required this.logId,
    required this.deliveryId,
    required this.message,
    this.metadata,
    required this.timestamp,
  });
}

/// ウェブフック署名
class WebhookSignature {
  final String signature;                // HMAC署名
  final String algorithm;                // アルゴリズム (sha256など)
  final DateTime timestamp;

  WebhookSignature({
    required this.signature,
    this.algorithm = 'sha256',
    required this.timestamp,
  });

  /// HMAC-SHA256署名を生成
  static String generateSignature(String payload, String secret) {
    // Note: 実装時には crypto パッケージを使用
    return 'sha256=${payload.hashCode}';
  }

  /// 署名を検証
  static bool verifySignature(
    String payload,
    String secret,
    String providedSignature,
  ) {
    final expectedSignature = generateSignature(payload, secret);
    return expectedSignature == providedSignature;
  }
}

/// ウェブフックテスト配信
class WebhookTestDelivery {
  final String testId;
  final String subscriptionId;
  final DateTime sentAt;
  DeliveryStatus status;
  int? httpStatusCode;
  String? response;
  String? error;

  WebhookTestDelivery({
    required this.testId,
    required this.subscriptionId,
    required this.sentAt,
    this.status = DeliveryStatus.pending,
    this.httpStatusCode,
    this.response,
    this.error,
  });
}

/// ウェブフックメトリクス
class WebhookMetrics {
  final String metricsId;
  final String subscriptionId;
  final int totalDeliveries;
  final int successfulDeliveries;
  final int failedDeliveries;
  final double averageLatencyMs;
  final double successRate;
  final DateTime measuredAt;
  final DateTime createdAt;

  WebhookMetrics({
    required this.metricsId,
    required this.subscriptionId,
    required this.totalDeliveries,
    required this.successfulDeliveries,
    required this.failedDeliveries,
    required this.averageLatencyMs,
    required this.successRate,
    required this.measuredAt,
    required this.createdAt,
  });

  /// 正常性スコア (0-100)
  int get healthScore => (successRate * 100).toInt();
}

/// ウェブフック監視アラート
class WebhookAlert {
  final String alertId;
  final String subscriptionId;
  final String type;                    // failure_rate, latency, delivery_lag
  final String severity;                // low, medium, high, critical
  final String message;
  final Map<String, dynamic>? metadata;
  final bool acknowledged;
  final DateTime createdAt;
  DateTime? acknowledgedAt;

  WebhookAlert({
    required this.alertId,
    required this.subscriptionId,
    required this.type,
    required this.severity,
    required this.message,
    this.metadata,
    this.acknowledged = false,
    required this.createdAt,
    this.acknowledgedAt,
  });
}

/// ウェブフックレポート
class WebhookReport {
  final String reportId;
  final DateTime generatedAt;
  final List<WebhookSubscription> subscriptions;
  final Map<String, WebhookMetrics> metrics;
  final Map<String, int> eventCounts;    // イベントタイプ別カウント
  final List<WebhookAlert> activeAlerts;
  final String summary;                 // Markdownサマリー

  WebhookReport({
    required this.reportId,
    required this.generatedAt,
    this.subscriptions = const [],
    this.metrics = const {},
    this.eventCounts = const {},
    this.activeAlerts = const [],
    required this.summary,
  });

  /// レポートをMarkdownで生成
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Webhook Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');
    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Active Subscriptions: ${subscriptions.length}');
    buffer.writeln('- Total Deliveries: ${metrics.values.fold(0, (sum, m) => sum + m.totalDeliveries)}');
    buffer.writeln('- Success Rate: ${(metrics.values.isNotEmpty ? metrics.values.map((m) => m.successRate).reduce((a, b) => (a + b) / 2) : 0).toStringAsFixed(2)}%');
    buffer.writeln('- Active Alerts: ${activeAlerts.length}');
    buffer.writeln('');

    if (eventCounts.isNotEmpty) {
      buffer.writeln('## Event Distribution');
      buffer.writeln('');
      eventCounts.forEach((type, count) {
        buffer.writeln('- $type: $count');
      });
      buffer.writeln('');
    }

    return buffer.toString();
  }
}
