/// Phase 40: Webhook Management テストスイート
///
/// ウェブフック、イベント、デリバリー、リトライの包括的テスト

import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/webhook_models.dart';
import 'package:project_040/services/webhook_service.dart';

void main() {
  group('Webhook Models', () {
    test('WebhookEventType enum has correct values', () {
      expect(WebhookEventType.jobCreated.value, 'job.created');
      expect(WebhookEventType.jobStarted.value, 'job.started');
      expect(WebhookEventType.deploymentCompleted.value, 'deployment.completed');
      expect(WebhookEventType.featureFlagEnabled.value, 'feature_flag.enabled');
      expect(WebhookEventType.quotaExceeded.value, 'quota.exceeded');
    });

    test('WebhookStatus enum has correct values', () {
      expect(WebhookStatus.active.value, 'active');
      expect(WebhookStatus.inactive.value, 'inactive');
      expect(WebhookStatus.suspended.value, 'suspended');
      expect(WebhookStatus.deleted.value, 'deleted');
    });

    test('DeliveryStatus enum has correct values', () {
      expect(DeliveryStatus.pending.value, 'pending');
      expect(DeliveryStatus.delivered.value, 'delivered');
      expect(DeliveryStatus.failed.value, 'failed');
      expect(DeliveryStatus.retrying.value, 'retrying');
    });
  });

  group('RetryPolicy', () {
    test('RetryPolicy can be created with defaults', () {
      final policy = RetryPolicy();

      expect(policy.maxRetries, 5);
      expect(policy.initialDelaySeconds, 1);
      expect(policy.maxDelaySeconds, 3600);
      expect(policy.backoffMultiplier, 2.0);
      expect(policy.exponentialBackoff, true);
    });

    test('RetryPolicy calculates next retry delay with exponential backoff', () {
      final policy = RetryPolicy(
        initialDelaySeconds: 1,
        exponentialBackoff: true,
      );

      expect(policy.getNextRetryDelay(1), 1);
      expect(policy.getNextRetryDelay(2), 2);
      expect(policy.getNextRetryDelay(3), 4);
      expect(policy.getNextRetryDelay(4), 8);
    });

    test('RetryPolicy respects max delay', () {
      final policy = RetryPolicy(
        initialDelaySeconds: 1,
        maxDelaySeconds: 10,
        exponentialBackoff: true,
      );

      final delay = policy.getNextRetryDelay(10);
      expect(delay <= policy.maxDelaySeconds, true);
    });

    test('RetryPolicy determines retryable status codes', () {
      final policy = RetryPolicy(
        retryableStatusCodes: [500, 502, 503],
      );

      expect(policy.isRetryable(500, 1), true);
      expect(policy.isRetryable(200, 1), false);
      expect(policy.isRetryable(503, 5), false); // Max retries reached
    });
  });

  group('WebhookSubscription', () {
    test('WebhookSubscription can be created', () {
      final now = DateTime.now();
      final subscription = WebhookSubscription(
        subscriptionId: 'sub1',
        userId: 'user1',
        url: 'https://example.com/webhook',
        events: [WebhookEventType.jobCreated, WebhookEventType.jobStarted],
        active: true,
        retryPolicy: RetryPolicy(),
        createdAt: now,
        updatedAt: now,
      );

      expect(subscription.subscriptionId, 'sub1');
      expect(subscription.userId, 'user1');
      expect(subscription.url, 'https://example.com/webhook');
      expect(subscription.events.length, 2);
      expect(subscription.active, true);
    });

    test('WebhookSubscription matches events', () {
      final subscription = WebhookSubscription(
        subscriptionId: 'sub1',
        userId: 'user1',
        url: 'https://example.com/webhook',
        events: [WebhookEventType.jobCreated],
        active: true,
        retryPolicy: RetryPolicy(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(subscription.matchesEvent(WebhookEventType.jobCreated), true);
      expect(subscription.matchesEvent(WebhookEventType.jobStarted), false);
    });

    test('WebhookSubscription inactive check', () {
      final subscription = WebhookSubscription(
        subscriptionId: 'sub1',
        userId: 'user1',
        url: 'https://example.com/webhook',
        events: [WebhookEventType.jobCreated],
        active: false,
        retryPolicy: RetryPolicy(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(subscription.matchesEvent(WebhookEventType.jobCreated), false);
    });

    test('WebhookSubscription with custom headers', () {
      final headers = {'Authorization': 'Bearer token123'};
      final subscription = WebhookSubscription(
        subscriptionId: 'sub1',
        userId: 'user1',
        url: 'https://example.com/webhook',
        events: [WebhookEventType.jobCreated],
        headers: headers,
        active: true,
        retryPolicy: RetryPolicy(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(subscription.headers, headers);
    });
  });

  group('WebhookEvent', () {
    test('WebhookEvent can be created', () {
      final now = DateTime.now();
      final event = WebhookEvent(
        eventId: 'event1',
        eventType: WebhookEventType.jobCreated,
        resourceId: 'job123',
        userId: 'user1',
        data: {'status': 'pending'},
        timestamp: now,
        createdAt: now,
      );

      expect(event.eventId, 'event1');
      expect(event.eventType, WebhookEventType.jobCreated);
      expect(event.resourceId, 'job123');
      expect(event.data['status'], 'pending');
    });

    test('WebhookEvent serializes to JSON', () {
      final event = WebhookEvent(
        eventId: 'event1',
        eventType: WebhookEventType.jobCreated,
        resourceId: 'job123',
        userId: 'user1',
        data: {'status': 'pending'},
        timestamp: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final json = event.toJson();
      expect(json['id'], 'event1');
      expect(json['type'], 'job.created');
      expect(json['resource_id'], 'job123');
    });

    test('WebhookEvent with idempotency key', () {
      final event = WebhookEvent(
        eventId: 'event1',
        eventType: WebhookEventType.jobCreated,
        resourceId: 'job123',
        userId: 'user1',
        data: {},
        timestamp: DateTime.now(),
        idempotencyKey: 'idem123',
        createdAt: DateTime.now(),
      );

      expect(event.idempotencyKey, 'idem123');
    });
  });

  group('WebhookDelivery', () {
    test('WebhookDelivery can be created', () {
      final delivery = WebhookDelivery(
        deliveryId: 'delivery1',
        subscriptionId: 'sub1',
        eventId: 'event1',
        targetUrl: 'https://example.com/webhook',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(delivery.deliveryId, 'delivery1');
      expect(delivery.status, DeliveryStatus.pending);
      expect(delivery.attemptNumber, 0);
      expect(delivery.isSuccessful, false);
    });

    test('WebhookDelivery records attempts', () {
      final delivery = WebhookDelivery(
        deliveryId: 'delivery1',
        subscriptionId: 'sub1',
        eventId: 'event1',
        targetUrl: 'https://example.com/webhook',
        maxRetries: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      delivery.recordAttempt(200, '{"status":"ok"}');

      expect(delivery.attemptNumber, 1);
      expect(delivery.httpStatusCode, 200);
      expect(delivery.status, DeliveryStatus.delivered);
      expect(delivery.isSuccessful, true);
    });

    test('WebhookDelivery handles failed delivery', () {
      final delivery = WebhookDelivery(
        deliveryId: 'delivery1',
        subscriptionId: 'sub1',
        eventId: 'event1',
        targetUrl: 'https://example.com/webhook',
        maxRetries: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      delivery.recordAttempt(500, 'Internal Server Error');

      expect(delivery.attemptNumber, 1);
      expect(delivery.httpStatusCode, 500);
      expect(delivery.isFailed, true);
      expect(delivery.isRetryable, false);
    });

    test('WebhookDelivery tracks retries', () {
      final delivery = WebhookDelivery(
        deliveryId: 'delivery1',
        subscriptionId: 'sub1',
        eventId: 'event1',
        targetUrl: 'https://example.com/webhook',
        maxRetries: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(delivery.isRetryable, true);

      delivery.recordAttempt(503, 'Service Unavailable');
      expect(delivery.isRetryable, true);
      expect(delivery.status, DeliveryStatus.retrying);

      delivery.recordAttempt(503, 'Service Unavailable');
      expect(delivery.isRetryable, true);

      delivery.recordAttempt(503, 'Service Unavailable');
      expect(delivery.isRetryable, false);
      expect(delivery.isFailed, true);
    });

    test('WebhookDelivery tracks attempt times', () {
      final delivery = WebhookDelivery(
        deliveryId: 'delivery1',
        subscriptionId: 'sub1',
        eventId: 'event1',
        targetUrl: 'https://example.com/webhook',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(delivery.attemptTimes.length, 0);

      delivery.recordAttempt(200, 'OK');
      expect(delivery.attemptTimes.length, 1);

      delivery.recordAttempt(200, 'OK');
      expect(delivery.attemptTimes.length, 2);
    });
  });

  group('WebhookLogEntry', () {
    test('WebhookLogEntry can be created', () {
      final log = WebhookLogEntry(
        logId: 'log1',
        deliveryId: 'delivery1',
        message: 'Delivery successful',
        timestamp: DateTime.now(),
      );

      expect(log.logId, 'log1');
      expect(log.deliveryId, 'delivery1');
      expect(log.message, 'Delivery successful');
    });

    test('WebhookLogEntry with metadata', () {
      final metadata = {'status_code': 200, 'latency_ms': 150};
      final log = WebhookLogEntry(
        logId: 'log1',
        deliveryId: 'delivery1',
        message: 'Delivery successful',
        metadata: metadata,
        timestamp: DateTime.now(),
      );

      expect(log.metadata, metadata);
    });
  });

  group('WebhookMetrics', () {
    test('WebhookMetrics can be created', () {
      final metrics = WebhookMetrics(
        metricsId: 'metrics1',
        subscriptionId: 'sub1',
        totalDeliveries: 100,
        successfulDeliveries: 95,
        failedDeliveries: 5,
        averageLatencyMs: 125.5,
        successRate: 0.95,
        measuredAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(metrics.metricsId, 'metrics1');
      expect(metrics.totalDeliveries, 100);
      expect(metrics.successRate, 0.95);
    });

    test('WebhookMetrics calculates health score', () {
      final metrics = WebhookMetrics(
        metricsId: 'metrics1',
        subscriptionId: 'sub1',
        totalDeliveries: 100,
        successfulDeliveries: 85,
        failedDeliveries: 15,
        averageLatencyMs: 125.5,
        successRate: 0.85,
        measuredAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(metrics.healthScore, 85);
    });
  });

  group('WebhookSignature', () {
    test('WebhookSignature can be created', () {
      final sig = WebhookSignature(
        signature: 'sha256=abc123',
        algorithm: 'sha256',
        timestamp: DateTime.now(),
      );

      expect(sig.signature, 'sha256=abc123');
      expect(sig.algorithm, 'sha256');
    });

    test('WebhookSignature generates signature', () {
      final payload = 'test_payload';
      final secret = 'test_secret';

      final signature = WebhookSignature.generateSignature(payload, secret);
      expect(signature.isNotEmpty, true);
    });

    test('WebhookSignature verifies signature', () {
      final payload = 'test_payload';
      const secret = 'test_secret';

      final signature = WebhookSignature.generateSignature(payload, secret);
      final verified = WebhookSignature.verifySignature(
        payload,
        secret,
        signature,
      );

      expect(verified, true);
    });
  });

  group('WebhookTestDelivery', () {
    test('WebhookTestDelivery can be created', () {
      final test = WebhookTestDelivery(
        testId: 'test1',
        subscriptionId: 'sub1',
        sentAt: DateTime.now(),
      );

      expect(test.testId, 'test1');
      expect(test.status, DeliveryStatus.pending);
    });

    test('WebhookTestDelivery records result', () {
      final test = WebhookTestDelivery(
        testId: 'test1',
        subscriptionId: 'sub1',
        sentAt: DateTime.now(),
      );

      test.status = DeliveryStatus.delivered;
      test.httpStatusCode = 200;
      test.response = '{"status":"ok"}';

      expect(test.status, DeliveryStatus.delivered);
      expect(test.httpStatusCode, 200);
    });
  });

  group('WebhookAlert', () {
    test('WebhookAlert can be created', () {
      final alert = WebhookAlert(
        alertId: 'alert1',
        subscriptionId: 'sub1',
        type: 'failure_rate',
        severity: 'high',
        message: 'High failure rate detected',
        createdAt: DateTime.now(),
      );

      expect(alert.alertId, 'alert1');
      expect(alert.type, 'failure_rate');
      expect(alert.acknowledged, false);
    });

    test('WebhookAlert can be acknowledged', () {
      final alert = WebhookAlert(
        alertId: 'alert1',
        subscriptionId: 'sub1',
        type: 'failure_rate',
        severity: 'high',
        message: 'High failure rate detected',
        createdAt: DateTime.now(),
      );

      // Simulate acknowledgment
      final ackAlert = WebhookAlert(
        alertId: alert.alertId,
        subscriptionId: alert.subscriptionId,
        type: alert.type,
        severity: alert.severity,
        message: alert.message,
        acknowledged: true,
        createdAt: alert.createdAt,
        acknowledgedAt: DateTime.now(),
      );

      expect(ackAlert.acknowledged, true);
      expect(ackAlert.acknowledgedAt, isNotNull);
    });
  });

  group('WebhookReport', () {
    test('WebhookReport can be created', () {
      final report = WebhookReport(
        reportId: 'report1',
        generatedAt: DateTime.now(),
        summary: 'Webhook system report',
      );

      expect(report.reportId, 'report1');
      expect(report.subscriptions.length, 0);
    });

    test('WebhookReport generates markdown', () {
      final report = WebhookReport(
        reportId: 'report1',
        generatedAt: DateTime.now(),
        subscriptions: [],
        metrics: {},
        eventCounts: {'job.created': 100, 'job.failed': 10},
        summary: 'Test report',
      );

      final markdown = report.toMarkdown();
      expect(markdown.contains('Webhook Report'), true);
      expect(markdown.contains('Active Subscriptions'), true);
    });
  });

  group('WebhookRepository', () {
    test('MemoryWebhookRepository saves and retrieves subscriptions', () async {
      final repo = MemoryWebhookRepository();
      final now = DateTime.now();
      final subscription = WebhookSubscription(
        subscriptionId: 'sub1',
        userId: 'user1',
        url: 'https://example.com/webhook',
        events: [WebhookEventType.jobCreated],
        active: true,
        retryPolicy: RetryPolicy(),
        createdAt: now,
        updatedAt: now,
      );

      await repo.saveSubscription(subscription);
      final retrieved = await repo.getSubscription('sub1');

      expect(retrieved, isNotNull);
      expect(retrieved!.url, 'https://example.com/webhook');
    });

    test('MemoryWebhookRepository retrieves user subscriptions', () async {
      final repo = MemoryWebhookRepository();
      final now = DateTime.now();

      for (int i = 1; i <= 3; i++) {
        final subscription = WebhookSubscription(
          subscriptionId: 'sub$i',
          userId: 'user1',
          url: 'https://example.com/webhook$i',
          events: [WebhookEventType.jobCreated],
          active: true,
          retryPolicy: RetryPolicy(),
          createdAt: now,
          updatedAt: now,
        );
        await repo.saveSubscription(subscription);
      }

      final subs = await repo.getUserSubscriptions('user1');
      expect(subs.length, 3);
    });

    test('MemoryWebhookRepository retrieves subscriptions by event type', () async {
      final repo = MemoryWebhookRepository();
      final now = DateTime.now();

      final sub1 = WebhookSubscription(
        subscriptionId: 'sub1',
        userId: 'user1',
        url: 'https://example.com/webhook1',
        events: [WebhookEventType.jobCreated],
        active: true,
        retryPolicy: RetryPolicy(),
        createdAt: now,
        updatedAt: now,
      );

      final sub2 = WebhookSubscription(
        subscriptionId: 'sub2',
        userId: 'user1',
        url: 'https://example.com/webhook2',
        events: [WebhookEventType.jobCreated, WebhookEventType.jobStarted],
        active: true,
        retryPolicy: RetryPolicy(),
        createdAt: now,
        updatedAt: now,
      );

      await repo.saveSubscription(sub1);
      await repo.saveSubscription(sub2);

      final subs = await repo.getSubscriptionsByEventType(
        WebhookEventType.jobCreated,
      );
      expect(subs.length, 2);
    });

    test('MemoryWebhookRepository saves and retrieves events', () async {
      final repo = MemoryWebhookRepository();
      final now = DateTime.now();
      final event = WebhookEvent(
        eventId: 'event1',
        eventType: WebhookEventType.jobCreated,
        resourceId: 'job123',
        userId: 'user1',
        data: {'status': 'pending'},
        timestamp: now,
        createdAt: now,
      );

      await repo.saveEvent(event);
      final retrieved = await repo.getEvent('event1');

      expect(retrieved, isNotNull);
      expect(retrieved!.resourceId, 'job123');
    });

    test('MemoryWebhookRepository saves and retrieves deliveries', () async {
      final repo = MemoryWebhookRepository();
      final delivery = WebhookDelivery(
        deliveryId: 'delivery1',
        subscriptionId: 'sub1',
        eventId: 'event1',
        targetUrl: 'https://example.com/webhook',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.saveDelivery(delivery);
      final retrieved = await repo.getDelivery('delivery1');

      expect(retrieved, isNotNull);
      expect(retrieved!.targetUrl, 'https://example.com/webhook');
    });
  });

  group('WebhookDeliveryEngine', () {
    test('MemoryWebhookDeliveryEngine delivers events', () async {
      final repo = MemoryWebhookRepository();
      final engine = MemoryWebhookDeliveryEngine(repo);
      final now = DateTime.now();

      final subscription = WebhookSubscription(
        subscriptionId: 'sub1',
        userId: 'user1',
        url: 'https://example.com/webhook',
        events: [WebhookEventType.jobCreated],
        active: true,
        retryPolicy: RetryPolicy(),
        createdAt: now,
        updatedAt: now,
      );

      final event = WebhookEvent(
        eventId: 'event1',
        eventType: WebhookEventType.jobCreated,
        resourceId: 'job123',
        userId: 'user1',
        data: {},
        timestamp: now,
        createdAt: now,
      );

      await engine.deliverEvent(subscription, event);
      // Delivery should be created
    });

    test('MemoryWebhookDeliveryEngine calculates metrics', () async {
      final repo = MemoryWebhookRepository();
      final engine = MemoryWebhookDeliveryEngine(repo);

      final metrics = await engine.calculateMetrics('sub1');
      expect(metrics.subscriptionId, 'sub1');
    });
  });

  group('WebhookManager (Facade)', () {
    test('WebhookManagerFacade creates subscriptions', () async {
      final facade = WebhookManagerFacade();
      final now = DateTime.now();

      final subscription = WebhookSubscription(
        subscriptionId: 'sub1',
        userId: 'user1',
        url: 'https://example.com/webhook',
        events: [WebhookEventType.jobCreated],
        active: true,
        retryPolicy: RetryPolicy(),
        createdAt: now,
        updatedAt: now,
      );

      await facade.createSubscription(subscription);
      final retrieved = await facade.getSubscription('sub1');

      expect(retrieved, isNotNull);
      expect(retrieved!.url, 'https://example.com/webhook');
    });

    test('WebhookManagerFacade publishes events', () async {
      final facade = WebhookManagerFacade();
      final now = DateTime.now();

      final event = WebhookEvent(
        eventId: 'event1',
        eventType: WebhookEventType.jobCreated,
        resourceId: 'job123',
        userId: 'user1',
        data: {},
        timestamp: now,
        createdAt: now,
      );

      await facade.publishEvent(event);
    });

    test('WebhookManagerFacade generates reports', () async {
      final facade = WebhookManagerFacade();

      final report = await facade.generateReport('user1');
      expect(report.generatedAt, isNotNull);
    });
  });

  group('Integration Tests', () {
    test('Complete webhook subscription and delivery workflow', () async {
      final facade = WebhookManagerFacade();
      final now = DateTime.now();

      // Create subscription
      final subscription = WebhookSubscription(
        subscriptionId: 'sub1',
        userId: 'user1',
        url: 'https://example.com/webhook',
        events: [WebhookEventType.jobCreated, WebhookEventType.jobStarted],
        active: true,
        retryPolicy: RetryPolicy(),
        createdAt: now,
        updatedAt: now,
      );
      await facade.createSubscription(subscription);

      // Verify subscription
      final retrieved = await facade.getSubscription('sub1');
      expect(retrieved, isNotNull);

      // Publish event
      final event = WebhookEvent(
        eventId: 'event1',
        eventType: WebhookEventType.jobCreated,
        resourceId: 'job123',
        userId: 'user1',
        data: {'status': 'pending'},
        timestamp: now,
        createdAt: now,
      );
      await facade.publishEvent(event);

      // Get user subscriptions
      final userSubs = await facade.getUserSubscriptions('user1');
      expect(userSubs.length, 1);
    });

    test('Complete webhook retry workflow', () async {
      final facade = WebhookManagerFacade();

      // Create subscription with retry policy
      final subscription = WebhookSubscription(
        subscriptionId: 'sub1',
        userId: 'user1',
        url: 'https://example.com/webhook',
        events: [WebhookEventType.jobFailed],
        active: true,
        retryPolicy: RetryPolicy(maxRetries: 3),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await facade.createSubscription(subscription);

      // Publish event
      final event = WebhookEvent(
        eventId: 'event1',
        eventType: WebhookEventType.jobFailed,
        resourceId: 'job123',
        userId: 'user1',
        data: {'reason': 'timeout'},
        timestamp: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await facade.publishEvent(event);
    });

    test('Complete webhook metrics and reporting workflow', () async {
      final facade = WebhookManagerFacade();
      final now = DateTime.now();

      // Create subscription
      final subscription = WebhookSubscription(
        subscriptionId: 'sub1',
        userId: 'user1',
        url: 'https://example.com/webhook',
        events: [WebhookEventType.jobCreated],
        active: true,
        retryPolicy: RetryPolicy(),
        createdAt: now,
        updatedAt: now,
      );
      await facade.createSubscription(subscription);

      // Get metrics
      final metrics = await facade.getMetrics('sub1');
      expect(metrics, isNotNull);

      // Generate report
      final report = await facade.generateReport('user1');
      expect(report.subscriptions.length, 1);

      // Convert to markdown
      final markdown = report.toMarkdown();
      expect(markdown.contains('Webhook Report'), true);
    });
  });
}
