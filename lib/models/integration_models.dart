/// Phase 51: API Integration & Webhooks System API統合・Webhook システム
///
/// Webhook管理、APIキー管理、統合認証、イベント配信

/// Webhook イベントタイプ
enum WebhookEventType {
  userCreated('user.created'),
  userUpdated('user.updated'),
  jobScheduled('job.scheduled'),
  jobCompleted('job.completed'),
  jobFailed('job.failed'),
  notificationSent('notification.sent'),
  reportGenerated('report.generated'),
  feedbackReceived('feedback.received'),
  anomalyDetected('anomaly.detected'),
  complianceViolation('compliance.violation');

  final String value;
  const WebhookEventType(this.value);
}

/// Webhook ステータス
enum WebhookStatus {
  active('active'),
  paused('paused'),
  failed('failed'),
  disabled('disabled');

  final String value;
  const WebhookStatus(this.value);
}

/// 統合ステータス
enum IntegrationStatus {
  connected('connected'),
  disconnected('disconnected'),
  error('error'),
  authenticating('authenticating');

  final String value;
  const IntegrationStatus(this.value);
}

/// 認証方式
enum AuthMethod {
  apiKey('api_key'),
  oauth2('oauth2'),
  basicAuth('basic_auth'),
  bearer('bearer');

  final String value;
  const AuthMethod(this.value);
}

/// Webhook
class Webhook {
  final String webhookId;
  final String userId;
  final String url;
  final List<WebhookEventType> events;
  final WebhookStatus status;
  final Map<String, String>? headers;
  final int? maxRetries;
  final DateTime createdAt;
  final DateTime? lastTriggeredAt;
  final bool isActive;

  Webhook({
    required this.webhookId,
    required this.userId,
    required this.url,
    required this.events,
    required this.status,
    this.headers,
    this.maxRetries = 3,
    required this.createdAt,
    this.lastTriggeredAt,
    this.isActive = true,
  });

  /// Webhook がアクティブか
  bool get isEnabled => status == WebhookStatus.active && isActive;

  /// Webhook が失敗したか
  bool get hasFailed => status == WebhookStatus.failed;

  /// イベント数
  int get eventCount => events.length;

  /// 最後のトリガーからの経過時間
  Duration? get timeSinceLastTrigger {
    if (lastTriggeredAt == null) return null;
    return DateTime.now().difference(lastTriggeredAt!);
  }
}

/// Webhook 配信
class WebhookDelivery {
  final String deliveryId;
  final String webhookId;
  final WebhookEventType event;
  final Map<String, dynamic> payload;
  final int statusCode;
  final String? response;
  final DateTime deliveredAt;
  final Duration? latency;
  final bool isSuccessful;

  WebhookDelivery({
    required this.deliveryId,
    required this.webhookId,
    required this.event,
    required this.payload,
    required this.statusCode,
    this.response,
    required this.deliveredAt,
    this.latency,
    required this.isSuccessful,
  });

  /// 配信に成功したか
  bool get success => statusCode >= 200 && statusCode < 300;

  /// リトライ可能か
  bool get canRetry => statusCode >= 500 || statusCode == 408;

  /// レスポンスサイズ（バイト）
  int? get responseSize => response?.length;
}

/// 統合認証情報
class IntegrationCredential {
  final String credentialId;
  final String provider;
  final AuthMethod authMethod;
  final Map<String, String> credentials;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;

  IntegrationCredential({
    required this.credentialId,
    required this.provider,
    required this.authMethod,
    required this.credentials,
    required this.createdAt,
    this.expiresAt,
    this.isActive = true,
  });

  /// 認証情報がアクティブか
  bool get isValid => isActive && (expiresAt == null || DateTime.now().isBefore(expiresAt!));

  /// 認証情報が期限切れか
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// 有効期限までの時間
  Duration? get timeUntilExpiration {
    if (expiresAt == null || isExpired) return null;
    return expiresAt!.difference(DateTime.now());
  }
}

/// API キー
class ApiKey {
  final String keyId;
  final String userId;
  final String name;
  final String secret;
  final List<String> permissions;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final DateTime? expiresAt;
  final bool isActive;

  ApiKey({
    required this.keyId,
    required this.userId,
    required this.name,
    required this.secret,
    required this.permissions,
    required this.createdAt,
    this.lastUsedAt,
    this.expiresAt,
    this.isActive = true,
  });

  /// キーがアクティブか
  bool get isValid => isActive && (expiresAt == null || DateTime.now().isBefore(expiresAt!));

  /// キーが期限切れか
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// パーミッション数
  int get permissionCount => permissions.length;

  /// 使用されたか
  bool get hasBeenUsed => lastUsedAt != null;
}

/// Webhook ログ
class WebhookLog {
  final String logId;
  final String webhookId;
  final List<WebhookDelivery> deliveries;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  WebhookLog({
    required this.logId,
    required this.webhookId,
    required this.deliveries,
    required this.createdAt,
    this.lastUpdated,
  });

  /// 配信数
  int get deliveryCount => deliveries.length;

  /// 成功数
  int get successCount => deliveries.where((d) => d.isSuccessful).length;

  /// 失敗数
  int get failureCount => deliveries.where((d) => !d.isSuccessful).length;

  /// 成功率
  double get successRate {
    if (deliveries.isEmpty) return 0.0;
    return successCount / deliveries.length;
  }
}

/// 統合ステータス
class ProviderIntegrationStatus {
  final String statusId;
  final String provider;
  final IntegrationStatus status;
  final DateTime lastSync;
  final DateTime? lastError;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  ProviderIntegrationStatus({
    required this.statusId,
    required this.provider,
    required this.status,
    required this.lastSync,
    this.lastError,
    this.errorMessage,
    this.metadata,
  });

  /// 統合が接続されているか
  bool get isConnected => status == IntegrationStatus.connected;

  /// 統合がエラー状態か
  bool get hasError => status == IntegrationStatus.error;

  /// 最後の同期からの経過時間
  Duration get timeSinceSync => DateTime.now().difference(lastSync);

  /// 同期が古いか（24時間以上）
  bool get isSyncStale => timeSinceSync.inHours > 24;
}

/// 統合統計
class IntegrationStats {
  final String statsId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalDeliveries;
  final int successCount;
  final int failureCount;
  final Map<WebhookEventType, int> deliveriesByEvent;
  final double averageLatency; // milliseconds
  final double successRate; // 0.0-1.0

  IntegrationStats({
    required this.statsId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalDeliveries,
    required this.successCount,
    required this.failureCount,
    required this.deliveriesByEvent,
    required this.averageLatency,
    required this.successRate,
  });

  /// 失敗率
  double get failureRate {
    if (totalDeliveries == 0) return 0.0;
    return failureCount / totalDeliveries;
  }

  /// 最も多く配信されたイベント
  WebhookEventType? get mostCommonEvent {
    if (deliveriesByEvent.isEmpty) return null;
    return deliveriesByEvent.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

/// API 統合レポート
class ApiIntegrationReport {
  final String reportId;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<Webhook> activeWebhooks;
  final List<ProviderIntegrationStatus> integrations;
  final IntegrationStats stats;
  final List<String>? recommendations;

  ApiIntegrationReport({
    required this.reportId,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.activeWebhooks,
    required this.integrations,
    required this.stats,
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
    buffer.writeln('- Active Webhooks: ${activeWebhooks.length}');
    buffer.writeln('- Connected Integrations: ${integrations.where((i) => i.isConnected).length}');
    buffer.writeln('- Total Deliveries: ${stats.totalDeliveries}');
    buffer.writeln('- Success Rate: ${(stats.successRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('- Average Latency: ${stats.averageLatency.toStringAsFixed(0)}ms');
    buffer.writeln('');

    if (integrations.isNotEmpty) {
      buffer.writeln('## Integration Status');
      buffer.writeln('');
      for (final integration in integrations) {
        buffer.writeln('- **${integration.provider}**: ${integration.status.value}');
        if (integration.hasError) {
          buffer.writeln('  - Error: ${integration.errorMessage}');
        }
      }
      buffer.writeln('');
    }

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
