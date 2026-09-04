/// Phase 51: API Integration & Webhooks Service API統合・Webhook サービス

import '../models/integration_models.dart';

/// Webhook/統合リポジトリ インターフェース
abstract class IntegrationRepository {
  // Webhook操作
  Future<Webhook> addWebhook(Webhook webhook);
  Future<Webhook?> getWebhook(String webhookId);
  Future<List<Webhook>> getWebhooksByUser(String userId);
  Future<List<Webhook>> getWebhooksByStatus(WebhookStatus status);
  Future<Webhook> updateWebhook(Webhook webhook);

  // Webhook配信ログ
  Future<WebhookDelivery> addDelivery(WebhookDelivery delivery);
  Future<List<WebhookDelivery>> getDeliveriesByWebhook(String webhookId);
  Future<WebhookLog> createLog(WebhookLog log);
  Future<WebhookLog?> getLog(String logId);

  // API キー
  Future<ApiKey> addApiKey(ApiKey key);
  Future<ApiKey?> getApiKey(String keyId);
  Future<List<ApiKey>> getApiKeysByUser(String userId);
  Future<ApiKey> updateApiKey(ApiKey key);

  // 統合認証情報
  Future<IntegrationCredential> addCredential(IntegrationCredential credential);
  Future<IntegrationCredential?> getCredential(String credentialId);
  Future<List<IntegrationCredential>> getCredentialsByProvider(String provider);
  Future<IntegrationCredential> updateCredential(IntegrationCredential credential);

  // 統合ステータス
  Future<ProviderIntegrationStatus> addIntegrationStatus(ProviderIntegrationStatus status);
  Future<ProviderIntegrationStatus?> getIntegrationStatus(String statusId);
  Future<List<ProviderIntegrationStatus>> getAllIntegrationStatuses();
  Future<ProviderIntegrationStatus> updateIntegrationStatus(ProviderIntegrationStatus status);

  // 統計
  Future<IntegrationStats> createStats(IntegrationStats stats);
  Future<IntegrationStats?> getStats(String statsId);

  Future<void> clearAll();
}

/// メモリ統合リポジトリ実装
class MemoryIntegrationRepository implements IntegrationRepository {
  final Map<String, Webhook> _webhooks = {};
  final Map<String, WebhookDelivery> _deliveries = {};
  final Map<String, WebhookLog> _logs = {};
  final Map<String, ApiKey> _apiKeys = {};
  final Map<String, IntegrationCredential> _credentials = {};
  final Map<String, ProviderIntegrationStatus> _statuses = {};
  final Map<String, IntegrationStats> _stats = {};

  @override
  Future<Webhook> addWebhook(Webhook webhook) async {
    _webhooks[webhook.webhookId] = webhook;
    return webhook;
  }

  @override
  Future<Webhook?> getWebhook(String webhookId) async {
    return _webhooks[webhookId];
  }

  @override
  Future<List<Webhook>> getWebhooksByUser(String userId) async {
    return _webhooks.values.where((w) => w.userId == userId).toList();
  }

  @override
  Future<List<Webhook>> getWebhooksByStatus(WebhookStatus status) async {
    return _webhooks.values.where((w) => w.status == status).toList();
  }

  @override
  Future<Webhook> updateWebhook(Webhook webhook) async {
    _webhooks[webhook.webhookId] = webhook;
    return webhook;
  }

  @override
  Future<WebhookDelivery> addDelivery(WebhookDelivery delivery) async {
    _deliveries[delivery.deliveryId] = delivery;
    return delivery;
  }

  @override
  Future<List<WebhookDelivery>> getDeliveriesByWebhook(String webhookId) async {
    return _deliveries.values.where((d) => d.webhookId == webhookId).toList();
  }

  @override
  Future<WebhookLog> createLog(WebhookLog log) async {
    _logs[log.logId] = log;
    return log;
  }

  @override
  Future<WebhookLog?> getLog(String logId) async {
    return _logs[logId];
  }

  @override
  Future<ApiKey> addApiKey(ApiKey key) async {
    _apiKeys[key.keyId] = key;
    return key;
  }

  @override
  Future<ApiKey?> getApiKey(String keyId) async {
    return _apiKeys[keyId];
  }

  @override
  Future<List<ApiKey>> getApiKeysByUser(String userId) async {
    return _apiKeys.values.where((k) => k.userId == userId).toList();
  }

  @override
  Future<ApiKey> updateApiKey(ApiKey key) async {
    _apiKeys[key.keyId] = key;
    return key;
  }

  @override
  Future<IntegrationCredential> addCredential(IntegrationCredential credential) async {
    _credentials[credential.credentialId] = credential;
    return credential;
  }

  @override
  Future<IntegrationCredential?> getCredential(String credentialId) async {
    return _credentials[credentialId];
  }

  @override
  Future<List<IntegrationCredential>> getCredentialsByProvider(String provider) async {
    return _credentials.values.where((c) => c.provider == provider).toList();
  }

  @override
  Future<IntegrationCredential> updateCredential(IntegrationCredential credential) async {
    _credentials[credential.credentialId] = credential;
    return credential;
  }

  @override
  Future<ProviderIntegrationStatus> addIntegrationStatus(ProviderIntegrationStatus status) async {
    _statuses[status.statusId] = status;
    return status;
  }

  @override
  Future<ProviderIntegrationStatus?> getIntegrationStatus(String statusId) async {
    return _statuses[statusId];
  }

  @override
  Future<List<ProviderIntegrationStatus>> getAllIntegrationStatuses() async {
    return _statuses.values.toList();
  }

  @override
  Future<ProviderIntegrationStatus> updateIntegrationStatus(ProviderIntegrationStatus status) async {
    _statuses[status.statusId] = status;
    return status;
  }

  @override
  Future<IntegrationStats> createStats(IntegrationStats stats) async {
    _stats[stats.statsId] = stats;
    return stats;
  }

  @override
  Future<IntegrationStats?> getStats(String statsId) async {
    return _stats[statsId];
  }

  @override
  Future<void> clearAll() async {
    _webhooks.clear();
    _deliveries.clear();
    _logs.clear();
    _apiKeys.clear();
    _credentials.clear();
    _statuses.clear();
    _stats.clear();
  }
}

/// Webhook エンジン インターフェース
abstract class WebhookEngine {
  Future<bool> shouldDeliver(Webhook webhook, WebhookEventType eventType);
  Future<WebhookDelivery> deliverEvent(Webhook webhook, WebhookEventType event, Map<String, dynamic> payload);
  Future<List<WebhookDelivery>> retryFailedDeliveries(List<WebhookDelivery> deliveries);
  Future<void> updateWebhookStatus(Webhook webhook, WebhookStatus newStatus);
  Future<bool> validateCredentials(IntegrationCredential credential);
}

/// Webhook エンジン実装
class MemoryWebhookEngine implements WebhookEngine {
  final Map<String, IntegrationCredential> _credentials = {};

  @override
  Future<bool> shouldDeliver(Webhook webhook, WebhookEventType eventType) async {
    if (!webhook.isEnabled) return false;
    return webhook.events.contains(eventType);
  }

  @override
  Future<WebhookDelivery> deliverEvent(Webhook webhook, WebhookEventType event, Map<String, dynamic> payload) async {
    final delivery = WebhookDelivery(
      deliveryId: 'delivery_${DateTime.now().millisecondsSinceEpoch}',
      webhookId: webhook.webhookId,
      event: event,
      payload: payload,
      statusCode: 200,
      response: '{"success": true}',
      deliveredAt: DateTime.now(),
      latency: Duration(milliseconds: 150),
      isSuccessful: true,
    );
    return delivery;
  }

  @override
  Future<List<WebhookDelivery>> retryFailedDeliveries(List<WebhookDelivery> deliveries) async {
    return deliveries.where((d) => d.canRetry).toList();
  }

  @override
  Future<void> updateWebhookStatus(Webhook webhook, WebhookStatus newStatus) async {
    // ステータス更新ロジック
  }

  @override
  Future<bool> validateCredentials(IntegrationCredential credential) async {
    return credential.isValid;
  }
}

/// 統合マネージャー インターフェース
abstract class IntegrationManager {
  Future<Webhook> createWebhook(String webhookId, String userId, String url, List<WebhookEventType> events);
  Future<Webhook> pauseWebhook(String webhookId);
  Future<Webhook> resumeWebhook(String webhookId);
  Future<ApiKey> createApiKey(String keyId, String userId, String name, List<String> permissions);
  Future<ApiKey> rotateApiKey(String keyId);
  Future<IntegrationCredential> storeCredential(String credentialId, String provider, AuthMethod method, Map<String, String> credentials);
  Future<ProviderIntegrationStatus> checkIntegrationHealth(String provider);
  Future<IntegrationStats> calculateStats(DateTime start, DateTime end);
  Future<ApiIntegrationReport> generateReport(String reportId, DateTime start, DateTime end);
}

/// メモリ統合マネージャー実装
class MemoryIntegrationManager implements IntegrationManager {
  final IntegrationRepository repository;
  final WebhookEngine engine;

  MemoryIntegrationManager({
    required this.repository,
    required this.engine,
  });

  @override
  Future<Webhook> createWebhook(String webhookId, String userId, String url, List<WebhookEventType> events) async {
    final webhook = Webhook(
      webhookId: webhookId,
      userId: userId,
      url: url,
      events: events,
      status: WebhookStatus.active,
      createdAt: DateTime.now(),
    );
    return repository.addWebhook(webhook);
  }

  @override
  Future<Webhook> pauseWebhook(String webhookId) async {
    final webhook = await repository.getWebhook(webhookId);
    if (webhook != null) {
      final paused = Webhook(
        webhookId: webhook.webhookId,
        userId: webhook.userId,
        url: webhook.url,
        events: webhook.events,
        status: WebhookStatus.paused,
        headers: webhook.headers,
        maxRetries: webhook.maxRetries,
        createdAt: webhook.createdAt,
        lastTriggeredAt: webhook.lastTriggeredAt,
        isActive: false,
      );
      return repository.updateWebhook(paused);
    }
    return webhook!;
  }

  @override
  Future<Webhook> resumeWebhook(String webhookId) async {
    final webhook = await repository.getWebhook(webhookId);
    if (webhook != null) {
      final resumed = Webhook(
        webhookId: webhook.webhookId,
        userId: webhook.userId,
        url: webhook.url,
        events: webhook.events,
        status: WebhookStatus.active,
        headers: webhook.headers,
        maxRetries: webhook.maxRetries,
        createdAt: webhook.createdAt,
        lastTriggeredAt: webhook.lastTriggeredAt,
        isActive: true,
      );
      return repository.updateWebhook(resumed);
    }
    return webhook!;
  }

  @override
  Future<ApiKey> createApiKey(String keyId, String userId, String name, List<String> permissions) async {
    final key = ApiKey(
      keyId: keyId,
      userId: userId,
      name: name,
      secret: 'sk_${DateTime.now().millisecondsSinceEpoch}',
      permissions: permissions,
      createdAt: DateTime.now(),
    );
    return repository.addApiKey(key);
  }

  @override
  Future<ApiKey> rotateApiKey(String keyId) async {
    final key = await repository.getApiKey(keyId);
    if (key != null) {
      final rotated = ApiKey(
        keyId: key.keyId,
        userId: key.userId,
        name: key.name,
        secret: 'sk_${DateTime.now().millisecondsSinceEpoch}',
        permissions: key.permissions,
        createdAt: key.createdAt,
        lastUsedAt: key.lastUsedAt,
        expiresAt: key.expiresAt,
        isActive: key.isActive,
      );
      return repository.updateApiKey(rotated);
    }
    return key!;
  }

  @override
  Future<IntegrationCredential> storeCredential(String credentialId, String provider, AuthMethod method, Map<String, String> credentials) async {
    final credential = IntegrationCredential(
      credentialId: credentialId,
      provider: provider,
      authMethod: method,
      credentials: credentials,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: 365)),
    );
    return repository.addCredential(credential);
  }

  @override
  Future<ProviderIntegrationStatus> checkIntegrationHealth(String provider) async {
    final status = ProviderIntegrationStatus(
      statusId: 'status_${DateTime.now().millisecondsSinceEpoch}',
      provider: provider,
      status: IntegrationStatus.connected,
      lastSync: DateTime.now(),
    );
    return repository.addIntegrationStatus(status);
  }

  @override
  Future<IntegrationStats> calculateStats(DateTime start, DateTime end) async {
    final allStatuses = await repository.getAllIntegrationStatuses();
    final webhooks = (await repository.getWebhooksByStatus(WebhookStatus.active)).length;

    return IntegrationStats(
      statsId: 'stats_${DateTime.now().millisecondsSinceEpoch}',
      periodStart: start,
      periodEnd: end,
      totalDeliveries: 0,
      successCount: 0,
      failureCount: 0,
      deliveriesByEvent: {},
      averageLatency: 0.0,
      successRate: 0.0,
    );
  }

  @override
  Future<ApiIntegrationReport> generateReport(String reportId, DateTime start, DateTime end) async {
    final webhooks = <Webhook>[];
    final statuses = await repository.getAllIntegrationStatuses();
    final stats = await calculateStats(start, end);

    return ApiIntegrationReport(
      reportId: reportId,
      generatedAt: DateTime.now(),
      periodStart: start,
      periodEnd: end,
      activeWebhooks: webhooks,
      integrations: statuses,
      stats: stats,
      recommendations: _generateRecommendations(stats),
    );
  }

  List<String> _generateRecommendations(IntegrationStats stats) {
    final recommendations = <String>[];

    if (stats.successRate < 0.95) {
      recommendations.add('Webhook success rate is below 95%');
      recommendations.add('Review failed deliveries for patterns');
    }

    if (stats.averageLatency > 5000) {
      recommendations.add('Average webhook latency is high');
      recommendations.add('Consider optimizing webhook processing');
    }

    if (stats.failureRate > 0.05) {
      recommendations.add('Failure rate detected - review integration health');
    }

    return recommendations;
  }
}

/// 統合ファサード
class IntegrationFacade {
  late final IntegrationRepository repository;
  late final WebhookEngine engine;
  late final MemoryIntegrationManager manager;

  IntegrationFacade({
    IntegrationRepository? customRepository,
    WebhookEngine? customEngine,
  }) {
    repository = customRepository ?? MemoryIntegrationRepository();
    engine = customEngine ?? MemoryWebhookEngine();
    manager = MemoryIntegrationManager(repository: repository, engine: engine);
  }

  Future<Webhook> createWebhook(String webhookId, String userId, String url, List<WebhookEventType> events) async {
    return manager.createWebhook(webhookId, userId, url, events);
  }

  Future<Webhook> pauseWebhook(String webhookId) async {
    return manager.pauseWebhook(webhookId);
  }

  Future<Webhook> resumeWebhook(String webhookId) async {
    return manager.resumeWebhook(webhookId);
  }

  Future<ApiKey> createApiKey(String keyId, String userId, String name, List<String> permissions) async {
    return manager.createApiKey(keyId, userId, name, permissions);
  }

  Future<ApiKey> rotateApiKey(String keyId) async {
    return manager.rotateApiKey(keyId);
  }

  Future<IntegrationCredential> storeCredential(String credentialId, String provider, AuthMethod method, Map<String, String> credentials) async {
    return manager.storeCredential(credentialId, provider, method, credentials);
  }

  Future<ProviderIntegrationStatus> checkIntegrationHealth(String provider) async {
    return manager.checkIntegrationHealth(provider);
  }

  Future<ApiIntegrationReport> generateReport(String reportId, DateTime start, DateTime end) async {
    return manager.generateReport(reportId, start, end);
  }

  Future<Webhook?> getWebhook(String webhookId) async {
    return repository.getWebhook(webhookId);
  }

  Future<List<Webhook>> getWebhooksByUser(String userId) async {
    return repository.getWebhooksByUser(userId);
  }

  Future<List<ApiKey>> getApiKeysByUser(String userId) async {
    return repository.getApiKeysByUser(userId);
  }

  Future<List<IntegrationCredential>> getCredentialsByProvider(String provider) async {
    return repository.getCredentialsByProvider(provider);
  }

  Future<List<ProviderIntegrationStatus>> getAllIntegrationStatuses() async {
    return repository.getAllIntegrationStatuses();
  }
}
