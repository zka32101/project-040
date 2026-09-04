/// Phase 40: Webhook Management サービス実装
///
/// ウェブフック管理、デリバリー、リトライ、監視

import 'package:project_040/models/webhook_models.dart';

/// ウェブフックリポジトリインターフェース
abstract class WebhookRepository {
  /// サブスクリプションを取得
  Future<WebhookSubscription?> getSubscription(String subscriptionId);

  /// サブスクリプションを保存
  Future<void> saveSubscription(WebhookSubscription subscription);

  /// ユーザーのすべてのサブスクリプションを取得
  Future<List<WebhookSubscription>> getUserSubscriptions(String userId);

  /// イベントタイプのサブスクリプションを取得
  Future<List<WebhookSubscription>> getSubscriptionsByEventType(
    WebhookEventType eventType,
  );

  /// イベントを保存
  Future<void> saveEvent(WebhookEvent event);

  /// イベントを取得
  Future<WebhookEvent?> getEvent(String eventId);

  /// デリバリーを保存
  Future<void> saveDelivery(WebhookDelivery delivery);

  /// デリバリーを取得
  Future<WebhookDelivery?> getDelivery(String deliveryId);

  /// ペンディングデリバリーを取得
  Future<List<WebhookDelivery>> getPendingDeliveries();

  /// リトライ対象のデリバリーを取得
  Future<List<WebhookDelivery>> getRetryableDeliveries();

  /// ログエントリを保存
  Future<void> saveLogEntry(WebhookLogEntry log);

  /// メトリクスを保存
  Future<void> saveMetrics(WebhookMetrics metrics);
}

/// メモリ実装のウェブフックリポジトリ
class MemoryWebhookRepository implements WebhookRepository {
  final Map<String, WebhookSubscription> _subscriptions = {};
  final Map<String, WebhookEvent> _events = {};
  final Map<String, WebhookDelivery> _deliveries = {};
  final Map<String, WebhookLogEntry> _logs = {};
  final Map<String, WebhookMetrics> _metrics = {};

  @override
  Future<WebhookSubscription?> getSubscription(String subscriptionId) async =>
      _subscriptions[subscriptionId];

  @override
  Future<void> saveSubscription(WebhookSubscription subscription) async {
    _subscriptions[subscription.subscriptionId] = subscription;
  }

  @override
  Future<List<WebhookSubscription>> getUserSubscriptions(String userId) async {
    return _subscriptions.values.where((s) => s.userId == userId).toList();
  }

  @override
  Future<List<WebhookSubscription>> getSubscriptionsByEventType(
    WebhookEventType eventType,
  ) async {
    return _subscriptions.values
        .where((s) => s.events.contains(eventType))
        .toList();
  }

  @override
  Future<void> saveEvent(WebhookEvent event) async {
    _events[event.eventId] = event;
  }

  @override
  Future<WebhookEvent?> getEvent(String eventId) async => _events[eventId];

  @override
  Future<void> saveDelivery(WebhookDelivery delivery) async {
    _deliveries[delivery.deliveryId] = delivery;
  }

  @override
  Future<WebhookDelivery?> getDelivery(String deliveryId) async =>
      _deliveries[deliveryId];

  @override
  Future<List<WebhookDelivery>> getPendingDeliveries() async {
    return _deliveries.values
        .where((d) => d.status == DeliveryStatus.pending)
        .toList();
  }

  @override
  Future<List<WebhookDelivery>> getRetryableDeliveries() async {
    return _deliveries.values.where((d) => d.isRetryable).toList();
  }

  @override
  Future<void> saveLogEntry(WebhookLogEntry log) async {
    _logs[log.logId] = log;
  }

  @override
  Future<void> saveMetrics(WebhookMetrics metrics) async {
    _metrics[metrics.metricsId] = metrics;
  }
}

/// ウェブフックデリバリーエンジンインターフェース
abstract class WebhookDeliveryEngine {
  /// デリバリーを実行
  Future<void> deliverEvent(
    WebhookSubscription subscription,
    WebhookEvent event,
  );

  /// リトライを処理
  Future<void> retryDelivery(WebhookDelivery delivery);

  /// すべてのペンディング配信を処理
  Future<void> processAllDeliveries();

  /// デリバリーメトリクスを計算
  Future<WebhookMetrics> calculateMetrics(String subscriptionId);
}

/// メモリ実装のウェブフックデリバリーエンジン
class MemoryWebhookDeliveryEngine implements WebhookDeliveryEngine {
  final WebhookRepository _repository;
  final Duration _deliveryTimeout = const Duration(seconds: 30);

  MemoryWebhookDeliveryEngine(this._repository);

  @override
  Future<void> deliverEvent(
    WebhookSubscription subscription,
    WebhookEvent event,
  ) async {
    // イベントマッチング確認
    if (!subscription.matchesEvent(event.eventType)) {
      return;
    }

    // デリバリー作成
    final delivery = WebhookDelivery(
      deliveryId: 'delivery:${DateTime.now().millisecondsSinceEpoch}',
      subscriptionId: subscription.subscriptionId,
      eventId: event.eventId,
      targetUrl: subscription.url,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      maxRetries: subscription.retryPolicy.maxRetries,
    );

    await _repository.saveDelivery(delivery);

    // デリバリー実行
    await _executeDelivery(delivery, subscription, event);
  }

  Future<void> _executeDelivery(
    WebhookDelivery delivery,
    WebhookSubscription subscription,
    WebhookEvent event,
  ) async {
    try {
      // シミュレーション: リクエスト送信
      await Future.delayed(const Duration(milliseconds: 50));

      // 簡易的に成功/失敗を判定
      final success = (event.eventId.hashCode % 100) < 95; // 95%成功率
      final statusCode = success ? 200 : 500;
      final response = success ? '{"status":"ok"}' : '{"error":"server_error"}';

      delivery.recordAttempt(statusCode, response);
      await _repository.saveDelivery(delivery);
    } catch (e) {
      delivery.recordAttempt(500, 'Exception: $e');
      await _repository.saveDelivery(delivery);
    }
  }

  @override
  Future<void> retryDelivery(WebhookDelivery delivery) async {
    if (!delivery.isRetryable) {
      return;
    }

    final nextDelay = _repository; // リトライ遅延は retryPolicy から計算

    delivery.nextRetryAt = DateTime.now().add(
      Duration(
        seconds: 1 << (delivery.attemptNumber - 1), // 指数バックオフ
      ),
    );

    await _repository.saveDelivery(delivery);
  }

  @override
  Future<void> processAllDeliveries() async {
    final pending = await _repository.getPendingDeliveries();
    for (final delivery in pending) {
      // ここで実際のデリバリーを実行
    }

    final retryable = await _repository.getRetryableDeliveries();
    for (final delivery in retryable) {
      final now = DateTime.now();
      if (delivery.nextRetryAt != null && now.isAfter(delivery.nextRetryAt!)) {
        // リトライ実行
      }
    }
  }

  @override
  Future<WebhookMetrics> calculateMetrics(String subscriptionId) async {
    final deliveries = (await _repository.getUserSubscriptions(''))
        .where((s) => s.subscriptionId == subscriptionId)
        .toList();

    final totalDeliveries = deliveries.length;
    int successfulDeliveries = 0;
    int failedDeliveries = 0;
    double totalLatency = 0;

    for (final delivery in deliveries) {
      if (delivery.isSuccessful) {
        successfulDeliveries++;
      } else if (delivery.isFailed) {
        failedDeliveries++;
      }

      if (delivery.attemptTimes.isNotEmpty && delivery.updatedAt != null) {
        totalLatency += delivery.updatedAt!
            .difference(delivery.createdAt)
            .inMilliseconds
            .toDouble();
      }
    }

    final successRate = totalDeliveries > 0
        ? successfulDeliveries / totalDeliveries
        : 0.0;
    final avgLatency =
        totalDeliveries > 0 ? totalLatency / totalDeliveries : 0;

    return WebhookMetrics(
      metricsId: 'metrics:${DateTime.now().millisecondsSinceEpoch}',
      subscriptionId: subscriptionId,
      totalDeliveries: totalDeliveries,
      successfulDeliveries: successfulDeliveries,
      failedDeliveries: failedDeliveries,
      averageLatencyMs: avgLatency,
      successRate: successRate,
      measuredAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }
}

/// ウェブフック管理インターフェース
abstract class WebhookManager {
  /// サブスクリプションを作成
  Future<void> createSubscription(WebhookSubscription subscription);

  /// サブスクリプションを取得
  Future<WebhookSubscription?> getSubscription(String subscriptionId);

  /// ユーザーのサブスクリプションを取得
  Future<List<WebhookSubscription>> getUserSubscriptions(String userId);

  /// サブスクリプションを削除
  Future<void> deleteSubscription(String subscriptionId);

  /// イベントを発行
  Future<void> publishEvent(WebhookEvent event);

  /// テストデリバリーを送信
  Future<WebhookTestDelivery> sendTestDelivery(
    String subscriptionId,
    WebhookEvent testEvent,
  );

  /// メトリクスを取得
  Future<WebhookMetrics?> getMetrics(String subscriptionId);

  /// レポートを生成
  Future<WebhookReport> generateReport(String userId);
}

/// メモリ実装のウェブフック管理
class MemoryWebhookManager implements WebhookManager {
  final WebhookRepository _repository;
  final WebhookDeliveryEngine _deliveryEngine;

  MemoryWebhookManager(
    this._repository,
    this._deliveryEngine,
  );

  @override
  Future<void> createSubscription(WebhookSubscription subscription) =>
      _repository.saveSubscription(subscription);

  @override
  Future<WebhookSubscription?> getSubscription(String subscriptionId) =>
      _repository.getSubscription(subscriptionId);

  @override
  Future<List<WebhookSubscription>> getUserSubscriptions(String userId) =>
      _repository.getUserSubscriptions(userId);

  @override
  Future<void> deleteSubscription(String subscriptionId) async {
    final subscription = await _repository.getSubscription(subscriptionId);
    if (subscription != null) {
      final updated = WebhookSubscription(
        subscriptionId: subscription.subscriptionId,
        userId: subscription.userId,
        url: subscription.url,
        events: subscription.events,
        active: false,
        retryPolicy: subscription.retryPolicy,
        secret: subscription.secret,
        createdAt: subscription.createdAt,
        updatedAt: DateTime.now(),
      );
      await _repository.saveSubscription(updated);
    }
  }

  @override
  Future<void> publishEvent(WebhookEvent event) async {
    await _repository.saveEvent(event);

    // マッチするサブスクリプションを取得
    final subscriptions = await _repository.getSubscriptionsByEventType(
      event.eventType,
    );

    // 各サブスクリプションにデリバリーを実行
    for (final subscription in subscriptions) {
      await _deliveryEngine.deliverEvent(subscription, event);
    }
  }

  @override
  Future<WebhookTestDelivery> sendTestDelivery(
    String subscriptionId,
    WebhookEvent testEvent,
  ) async {
    final subscription = await _repository.getSubscription(subscriptionId);
    if (subscription == null) {
      throw Exception('Subscription not found');
    }

    final testDelivery = WebhookTestDelivery(
      testId: 'test:${DateTime.now().millisecondsSinceEpoch}',
      subscriptionId: subscriptionId,
      sentAt: DateTime.now(),
    );

    try {
      // テストデリバリーを実行
      await _deliveryEngine.deliverEvent(subscription, testEvent);
      testDelivery.status = DeliveryStatus.delivered;
      testDelivery.httpStatusCode = 200;
      testDelivery.response = '{"status":"ok"}';
    } catch (e) {
      testDelivery.status = DeliveryStatus.failed;
      testDelivery.error = e.toString();
    }

    return testDelivery;
  }

  @override
  Future<WebhookMetrics?> getMetrics(String subscriptionId) async {
    return _deliveryEngine.calculateMetrics(subscriptionId);
  }

  @override
  Future<WebhookReport> generateReport(String userId) async {
    final subscriptions = await _repository.getUserSubscriptions(userId);
    final metrics = <String, WebhookMetrics>{};
    final eventCounts = <String, int>{};

    for (final subscription in subscriptions) {
      final subMetrics = await _deliveryEngine.calculateMetrics(
        subscription.subscriptionId,
      );
      metrics[subscription.subscriptionId] = subMetrics;
    }

    return WebhookReport(
      reportId: 'report:${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      subscriptions: subscriptions,
      metrics: metrics,
      eventCounts: eventCounts,
      summary: 'Webhook report for user $userId',
    );
  }
}

/// ウェブフック管理マネージャー (ファサード)
class WebhookManagerFacade {
  late WebhookRepository _repository;
  late WebhookDeliveryEngine _deliveryEngine;
  late WebhookManager _manager;

  WebhookManagerFacade({
    WebhookRepository? repository,
    WebhookDeliveryEngine? deliveryEngine,
    WebhookManager? manager,
  }) {
    _repository = repository ?? MemoryWebhookRepository();
    _deliveryEngine =
        deliveryEngine ?? MemoryWebhookDeliveryEngine(_repository);
    _manager = manager ?? MemoryWebhookManager(_repository, _deliveryEngine);
  }

  /// サブスクリプションを作成
  Future<void> createSubscription(WebhookSubscription subscription) =>
      _manager.createSubscription(subscription);

  /// サブスクリプションを取得
  Future<WebhookSubscription?> getSubscription(String subscriptionId) =>
      _manager.getSubscription(subscriptionId);

  /// ユーザーのサブスクリプションを取得
  Future<List<WebhookSubscription>> getUserSubscriptions(String userId) =>
      _manager.getUserSubscriptions(userId);

  /// サブスクリプションを削除
  Future<void> deleteSubscription(String subscriptionId) =>
      _manager.deleteSubscription(subscriptionId);

  /// イベントを発行
  Future<void> publishEvent(WebhookEvent event) => _manager.publishEvent(event);

  /// テストデリバリーを送信
  Future<WebhookTestDelivery> sendTestDelivery(
    String subscriptionId,
    WebhookEvent testEvent,
  ) =>
      _manager.sendTestDelivery(subscriptionId, testEvent);

  /// メトリクスを取得
  Future<WebhookMetrics?> getMetrics(String subscriptionId) =>
      _manager.getMetrics(subscriptionId);

  /// レポートを生成
  Future<WebhookReport> generateReport(String userId) =>
      _manager.generateReport(userId);

  /// すべてのデリバリーを処理
  Future<void> processAllDeliveries() =>
      _deliveryEngine.processAllDeliveries();
}
