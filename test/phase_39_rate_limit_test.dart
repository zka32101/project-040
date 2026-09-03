/// Phase 39: Rate Limiting & Quotas テストスイート
///
/// レート制限、クォータ、使用状況追跡の包括的テスト

import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/rate_limit_models.dart';
import 'package:project_040/services/rate_limit_service.dart';

void main() {
  group('Rate Limit Models', () {
    test('RateLimitStrategy enum has correct values', () {
      expect(RateLimitStrategy.tokenBucket.value, 'token_bucket');
      expect(RateLimitStrategy.slidingWindow.value, 'sliding_window');
      expect(RateLimitStrategy.fixedWindow.value, 'fixed_window');
      expect(RateLimitStrategy.leakyBucket.value, 'leaky_bucket');
      expect(RateLimitStrategy.adaptive.value, 'adaptive');
    });

    test('QuotaType enum has correct values', () {
      expect(QuotaType.perMinute.value, 'per_minute');
      expect(QuotaType.perHour.value, 'per_hour');
      expect(QuotaType.perDay.value, 'per_day');
      expect(QuotaType.perMonth.value, 'per_month');
      expect(QuotaType.unlimited.value, 'unlimited');
    });

    test('QuotaStatus enum has correct values', () {
      expect(QuotaStatus.healthy.value, 'healthy');
      expect(QuotaStatus.warning.value, 'warning');
      expect(QuotaStatus.critical.value, 'critical');
      expect(QuotaStatus.exceeded.value, 'exceeded');
    });
  });

  group('RateLimitRule', () {
    test('RateLimitRule can be created with basic properties', () {
      final now = DateTime.now();
      final rule = RateLimitRule(
        ruleId: 'rule1',
        name: 'API Rate Limit',
        description: 'Basic API rate limit',
        strategy: RateLimitStrategy.tokenBucket,
        maxRequests: 1000,
        windowSizeSeconds: 3600,
        createdAt: now,
        updatedAt: now,
      );

      expect(rule.ruleId, 'rule1');
      expect(rule.name, 'API Rate Limit');
      expect(rule.strategy, RateLimitStrategy.tokenBucket);
      expect(rule.maxRequests, 1000);
      expect(rule.windowSizeSeconds, 3600);
      expect(rule.isActive, true);
    });

    test('RateLimitRule supports whitelisting and blacklisting', () {
      final now = DateTime.now();
      final rule = RateLimitRule(
        ruleId: 'rule1',
        name: 'API Rate Limit',
        description: 'API rate limit',
        strategy: RateLimitStrategy.tokenBucket,
        maxRequests: 1000,
        windowSizeSeconds: 3600,
        whitelistedUsers: ['user1', 'user2'],
        blacklistedUsers: ['user3'],
        createdAt: now,
        updatedAt: now,
      );

      expect(rule.whitelistedUsers, contains('user1'));
      expect(rule.blacklistedUsers, contains('user3'));
    });
  });

  group('TokenBucket', () {
    test('TokenBucket can be created', () {
      final now = DateTime.now();
      final bucket = TokenBucket(
        bucketId: 'bucket1',
        userId: 'user1',
        tokens: 100,
        maxTokens: 100,
        refillRate: 10,
        lastRefillTime: now,
        createdAt: now,
      );

      expect(bucket.bucketId, 'bucket1');
      expect(bucket.tokens, 100);
      expect(bucket.maxTokens, 100);
      expect(bucket.refillRate, 10);
    });

    test('TokenBucket can consume tokens', () {
      final bucket = TokenBucket(
        bucketId: 'bucket1',
        userId: 'user1',
        tokens: 100,
        maxTokens: 100,
        refillRate: 10,
        lastRefillTime: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(bucket.canConsume(50), true);
      expect(bucket.tryConsume(50), true);
      expect(bucket.tokens, 50);
    });

    test('TokenBucket rejects consumption over limit', () {
      final bucket = TokenBucket(
        bucketId: 'bucket1',
        userId: 'user1',
        tokens: 50,
        maxTokens: 100,
        refillRate: 10,
        lastRefillTime: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(bucket.canConsume(100), false);
      expect(bucket.tryConsume(100), false);
      expect(bucket.tokens, 50);
    });
  });

  group('SlidingWindow', () {
    test('SlidingWindow can be created', () {
      final window = SlidingWindow(
        windowId: 'window1',
        userId: 'user1',
        requestTimestamps: [],
        maxRequests: 100,
        windowSizeSeconds: 3600,
        createdAt: DateTime.now(),
      );

      expect(window.windowId, 'window1');
      expect(window.maxRequests, 100);
      expect(window.windowSizeSeconds, 3600);
    });

    test('SlidingWindow allows requests within limit', () {
      final window = SlidingWindow(
        windowId: 'window1',
        userId: 'user1',
        requestTimestamps: [],
        maxRequests: 5,
        windowSizeSeconds: 3600,
        createdAt: DateTime.now(),
      );

      expect(window.isAllowed(), true);
      window.recordRequest();
      expect(window.requestTimestamps.length, 1);
      expect(window.usagePercentage, 20);
    });

    test('SlidingWindow rejects requests over limit', () {
      final timestamps = <DateTime>[
        DateTime.now(),
        DateTime.now(),
        DateTime.now(),
        DateTime.now(),
        DateTime.now(),
      ];
      final window = SlidingWindow(
        windowId: 'window1',
        userId: 'user1',
        requestTimestamps: timestamps,
        maxRequests: 5,
        windowSizeSeconds: 3600,
        createdAt: DateTime.now(),
      );

      expect(window.isAllowed(), false);
    });

    test('SlidingWindow prunes old requests', () {
      final oldTime = DateTime.now().subtract(const Duration(hours: 2));
      final recentTime = DateTime.now();
      final window = SlidingWindow(
        windowId: 'window1',
        userId: 'user1',
        requestTimestamps: [oldTime, recentTime],
        maxRequests: 5,
        windowSizeSeconds: 3600,
        createdAt: DateTime.now(),
      );

      window.pruneOldRequests();
      expect(window.requestTimestamps.length, 1);
      expect(window.requestTimestamps.first, recentTime);
    });
  });

  group('UserQuota', () {
    test('UserQuota can be created', () {
      final now = DateTime.now();
      final quota = UserQuota(
        quotaId: 'quota1',
        userId: 'user1',
        quotaType: QuotaType.perDay,
        limitAmount: 10000,
        createdAt: now,
        updatedAt: now,
      );

      expect(quota.quotaId, 'quota1');
      expect(quota.userId, 'user1');
      expect(quota.quotaType, QuotaType.perDay);
      expect(quota.limitAmount, 10000);
      expect(quota.usedAmount, 0);
    });

    test('UserQuota status reflects usage percentage', () {
      final quota = UserQuota(
        quotaId: 'quota1',
        userId: 'user1',
        quotaType: QuotaType.perDay,
        limitAmount: 1000,
        usedAmount: 300,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(quota.getStatus(), QuotaStatus.healthy);
      quota.usedAmount = 700;
      expect(quota.getStatus(), QuotaStatus.warning);
      quota.usedAmount = 950;
      expect(quota.getStatus(), QuotaStatus.critical);
      quota.usedAmount = 1000;
      expect(quota.getStatus(), QuotaStatus.exceeded);
    });

    test('UserQuota can be reset', () {
      final quota = UserQuota(
        quotaId: 'quota1',
        userId: 'user1',
        quotaType: QuotaType.perDay,
        limitAmount: 1000,
        usedAmount: 500,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(quota.usedAmount, 500);
      quota.reset();
      expect(quota.usedAmount, 0);
    });

    test('UserQuota calculates remaining correctly', () {
      final quota = UserQuota(
        quotaId: 'quota1',
        userId: 'user1',
        quotaType: QuotaType.perDay,
        limitAmount: 1000,
        usedAmount: 300,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(quota.remaining, 700);
      expect(quota.usagePercentage, 30);
    });
  });

  group('RateLimitEvent', () {
    test('RateLimitEvent can be created', () {
      final now = DateTime.now();
      final event = RateLimitEvent(
        eventId: 'event1',
        userId: 'user1',
        ruleId: 'rule1',
        eventType: 'limited',
        reason: 'Rate limit exceeded',
        createdAt: now,
      );

      expect(event.eventId, 'event1');
      expect(event.userId, 'user1');
      expect(event.eventType, 'limited');
    });
  });

  group('RateLimitResponse', () {
    test('RateLimitResponse can be created for allowed request', () {
      final response = RateLimitResponse(
        allowed: true,
        userId: 'user1',
        ruleId: 'rule1',
        remaining: 999,
        reason: 'Allowed',
        evaluatedAt: DateTime.now(),
      );

      expect(response.allowed, true);
      expect(response.remaining, 999);
      expect(response.retryAfterSeconds, null);
    });

    test('RateLimitResponse can be created for denied request', () {
      final response = RateLimitResponse(
        allowed: false,
        userId: 'user1',
        ruleId: 'rule1',
        remaining: 0,
        retryAfterSeconds: 3600,
        reason: 'Rate limit exceeded',
        evaluatedAt: DateTime.now(),
      );

      expect(response.allowed, false);
      expect(response.remaining, 0);
      expect(response.retryAfterSeconds, 3600);
    });
  });

  group('UsageReport', () {
    test('UsageReport can be created', () {
      final now = DateTime.now();
      final report = UsageReport(
        reportId: 'report1',
        userId: 'user1',
        generatedAt: now,
        usageByEndpoint: {'api': 500},
        totalRequests: 500,
        averageRequestsPerHour: 20.83,
        peakRequestsPerHour: 50,
      );

      expect(report.reportId, 'report1');
      expect(report.userId, 'user1');
      expect(report.totalRequests, 500);
    });

    test('UsageReport generates markdown', () {
      final report = UsageReport(
        reportId: 'report1',
        userId: 'user1',
        generatedAt: DateTime.now(),
        usageByEndpoint: {'api': 500},
        totalRequests: 500,
        averageRequestsPerHour: 20.83,
        peakRequestsPerHour: 50,
      );

      final markdown = report.toMarkdown();
      expect(markdown, contains('Usage Report'));
      expect(markdown, contains('Total Requests: 500'));
    });
  });

  group('AdaptiveRateLimit', () {
    test('AdaptiveRateLimit can be created', () {
      final limit = AdaptiveRateLimit(
        limitId: 'limit1',
        userId: 'user1',
        baseMaxRequests: 1000,
        windowSizeSeconds: 3600,
        lastViolationTime: DateTime.now(),
      );

      expect(limit.limitId, 'limit1');
      expect(limit.baseMaxRequests, 1000);
      expect(limit.currentMultiplier, 1.0);
      expect(limit.currentLimit, 1000);
    });

    test('AdaptiveRateLimit reduces on violation', () {
      final limit = AdaptiveRateLimit(
        limitId: 'limit1',
        userId: 'user1',
        baseMaxRequests: 1000,
        windowSizeSeconds: 3600,
        lastViolationTime: DateTime.now(),
      );

      expect(limit.currentLimit, 1000);
      limit.recordViolation();
      expect(limit.currentLimit, 900);
      expect(limit.consecutiveViolations, 1);
    });

    test('AdaptiveRateLimit recovers on success', () {
      final limit = AdaptiveRateLimit(
        limitId: 'limit1',
        userId: 'user1',
        baseMaxRequests: 1000,
        windowSizeSeconds: 3600,
        consecutiveViolations: 1,
        lastViolationTime: DateTime.now(),
      );

      expect(limit.currentLimit, 900);
      limit.recordSuccess();
      expect(limit.consecutiveViolations, 0);
      expect(limit.currentLimit, 950);
    });
  });

  group('QuotaPlan', () {
    test('QuotaPlan can be created', () {
      final now = DateTime.now();
      final plan = QuotaPlan(
        planId: 'plan1',
        name: 'Premium',
        description: 'Premium plan',
        quotaLimits: {'api_calls': 100000, 'storage_gb': 1000},
        price: 99.99,
        createdAt: now,
        updatedAt: now,
      );

      expect(plan.planId, 'plan1');
      expect(plan.name, 'Premium');
      expect(plan.quotaLimits['api_calls'], 100000);
      expect(plan.price, 99.99);
    });
  });

  group('UserPlanAssignment', () {
    test('UserPlanAssignment can be created', () {
      final now = DateTime.now();
      final assignment = UserPlanAssignment(
        assignmentId: 'assign1',
        userId: 'user1',
        planId: 'plan1',
        effectiveFrom: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(assignment.assignmentId, 'assign1');
      expect(assignment.userId, 'user1');
      expect(assignment.isEffective, true);
    });

    test('UserPlanAssignment respects effective dates', () {
      final now = DateTime.now();
      final futureDate = now.add(const Duration(days: 1));
      final assignment = UserPlanAssignment(
        assignmentId: 'assign1',
        userId: 'user1',
        planId: 'plan1',
        effectiveFrom: futureDate,
        createdAt: now,
        updatedAt: now,
      );

      expect(assignment.isEffective, false);
    });
  });

  group('RateLimitRepository', () {
    test('MemoryRateLimitRepository saves and retrieves rules', () async {
      final repo = MemoryRateLimitRepository();
      final now = DateTime.now();
      final rule = RateLimitRule(
        ruleId: 'rule1',
        name: 'API Rate Limit',
        description: 'Basic rate limit',
        strategy: RateLimitStrategy.tokenBucket,
        maxRequests: 1000,
        windowSizeSeconds: 3600,
        createdAt: now,
        updatedAt: now,
      );

      await repo.saveRule(rule);
      final retrieved = await repo.getRule('rule1');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'API Rate Limit');
    });

    test('MemoryRateLimitRepository retrieves all rules', () async {
      final repo = MemoryRateLimitRepository();
      final now = DateTime.now();

      for (int i = 1; i <= 3; i++) {
        final rule = RateLimitRule(
          ruleId: 'rule$i',
          name: 'Rule $i',
          description: 'Test rule $i',
          strategy: RateLimitStrategy.tokenBucket,
          maxRequests: 1000,
          windowSizeSeconds: 3600,
          createdAt: now,
          updatedAt: now,
        );
        await repo.saveRule(rule);
      }

      final rules = await repo.getAllRules();
      expect(rules.length, 3);
    });

    test('MemoryRateLimitRepository retrieves rule by name', () async {
      final repo = MemoryRateLimitRepository();
      final now = DateTime.now();
      final rule = RateLimitRule(
        ruleId: 'rule1',
        name: 'Unique Rule Name',
        description: 'Test',
        strategy: RateLimitStrategy.tokenBucket,
        maxRequests: 1000,
        windowSizeSeconds: 3600,
        createdAt: now,
        updatedAt: now,
      );

      await repo.saveRule(rule);
      final retrieved = await repo.getRuleByName('Unique Rule Name');

      expect(retrieved, isNotNull);
      expect(retrieved!.ruleId, 'rule1');
    });

    test('MemoryRateLimitRepository saves and retrieves token buckets', () async {
      final repo = MemoryRateLimitRepository();
      final bucket = TokenBucket(
        bucketId: 'bucket1',
        userId: 'user1',
        tokens: 100,
        maxTokens: 100,
        refillRate: 10,
        lastRefillTime: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await repo.saveTokenBucket(bucket);
      final retrieved = await repo.getTokenBucket('bucket1');

      expect(retrieved, isNotNull);
      expect(retrieved!.tokens, 100);
    });

    test('MemoryRateLimitRepository saves and retrieves sliding windows', () async {
      final repo = MemoryRateLimitRepository();
      final window = SlidingWindow(
        windowId: 'window1',
        userId: 'user1',
        requestTimestamps: [],
        maxRequests: 100,
        windowSizeSeconds: 3600,
        createdAt: DateTime.now(),
      );

      await repo.saveSlidingWindow(window);
      final retrieved = await repo.getSlidingWindow('window1');

      expect(retrieved, isNotNull);
      expect(retrieved!.maxRequests, 100);
    });
  });

  group('RateLimitEngine', () {
    test('MemoryRateLimitEngine evaluates request with token bucket', () async {
      final repo = MemoryRateLimitRepository();
      final engine = MemoryRateLimitEngine(repo);
      final now = DateTime.now();
      final rule = RateLimitRule(
        ruleId: 'rule1',
        name: 'API Rate Limit',
        description: 'Test',
        strategy: RateLimitStrategy.tokenBucket,
        maxRequests: 1000,
        windowSizeSeconds: 3600,
        createdAt: now,
        updatedAt: now,
      );

      await repo.saveRule(rule);
      final response = await engine.evaluateRequest('user1', 'rule1');

      expect(response.allowed, true);
      expect(response.userId, 'user1');
    });

    test('MemoryRateLimitEngine evaluates request with sliding window', () async {
      final repo = MemoryRateLimitRepository();
      final engine = MemoryRateLimitEngine(repo);
      final now = DateTime.now();
      final rule = RateLimitRule(
        ruleId: 'rule1',
        name: 'API Rate Limit',
        description: 'Test',
        strategy: RateLimitStrategy.slidingWindow,
        maxRequests: 5,
        windowSizeSeconds: 3600,
        createdAt: now,
        updatedAt: now,
      );

      await repo.saveRule(rule);

      // First few requests should be allowed
      for (int i = 0; i < 5; i++) {
        final response = await engine.evaluateRequest('user1', 'rule1');
        expect(response.allowed, true);
      }

      // Sixth request should be denied
      final response = await engine.evaluateRequest('user1', 'rule1');
      expect(response.allowed, false);
    });

    test('MemoryRateLimitEngine respects whitelist', () async {
      final repo = MemoryRateLimitRepository();
      final engine = MemoryRateLimitEngine(repo);
      final now = DateTime.now();
      final rule = RateLimitRule(
        ruleId: 'rule1',
        name: 'API Rate Limit',
        description: 'Test',
        strategy: RateLimitStrategy.tokenBucket,
        maxRequests: 100,
        windowSizeSeconds: 3600,
        whitelistedUsers: ['user1'],
        createdAt: now,
        updatedAt: now,
      );

      await repo.saveRule(rule);
      final response = await engine.evaluateRequest('user1', 'rule1');

      expect(response.allowed, true);
      expect(response.reason, 'Whitelisted');
    });

    test('MemoryRateLimitEngine respects blacklist', () async {
      final repo = MemoryRateLimitRepository();
      final engine = MemoryRateLimitEngine(repo);
      final now = DateTime.now();
      final rule = RateLimitRule(
        ruleId: 'rule1',
        name: 'API Rate Limit',
        description: 'Test',
        strategy: RateLimitStrategy.tokenBucket,
        maxRequests: 1000,
        windowSizeSeconds: 3600,
        blacklistedUsers: ['user1'],
        createdAt: now,
        updatedAt: now,
      );

      await repo.saveRule(rule);
      final response = await engine.evaluateRequest('user1', 'rule1');

      expect(response.allowed, false);
      expect(response.reason, 'Blacklisted');
    });

    test('MemoryRateLimitEngine initializes token bucket', () async {
      final repo = MemoryRateLimitRepository();
      final engine = MemoryRateLimitEngine(repo);
      final now = DateTime.now();
      final rule = RateLimitRule(
        ruleId: 'rule1',
        name: 'API Rate Limit',
        description: 'Test',
        strategy: RateLimitStrategy.tokenBucket,
        maxRequests: 1000,
        windowSizeSeconds: 3600,
        createdAt: now,
        updatedAt: now,
      );

      await repo.saveRule(rule);
      final bucket = await engine.initializeTokenBucket('user1', 'rule1');

      expect(bucket.userId, 'user1');
      expect(bucket.tokens, 1000);
      expect(bucket.maxTokens, 1000);
    });

    test('MemoryRateLimitEngine initializes sliding window', () async {
      final repo = MemoryRateLimitRepository();
      final engine = MemoryRateLimitEngine(repo);
      final now = DateTime.now();
      final rule = RateLimitRule(
        ruleId: 'rule1',
        name: 'API Rate Limit',
        description: 'Test',
        strategy: RateLimitStrategy.slidingWindow,
        maxRequests: 100,
        windowSizeSeconds: 3600,
        createdAt: now,
        updatedAt: now,
      );

      await repo.saveRule(rule);
      final window = await engine.initializeSlidingWindow('user1', 'rule1');

      expect(window.userId, 'user1');
      expect(window.maxRequests, 100);
    });

    test('MemoryRateLimitEngine evaluates multiple requests', () async {
      final repo = MemoryRateLimitRepository();
      final engine = MemoryRateLimitEngine(repo);
      final now = DateTime.now();
      final rule = RateLimitRule(
        ruleId: 'rule1',
        name: 'API Rate Limit',
        description: 'Test',
        strategy: RateLimitStrategy.tokenBucket,
        maxRequests: 1000,
        windowSizeSeconds: 3600,
        createdAt: now,
        updatedAt: now,
      );

      await repo.saveRule(rule);
      final responses = await engine.evaluateRequests(['user1', 'user2', 'user3'], 'rule1');

      expect(responses.length, 3);
      expect(responses.every((r) => r.allowed), true);
    });
  });

  group('QuotaManager', () {
    test('MemoryQuotaManager creates and retrieves quotas', () async {
      final manager = MemoryQuotaManager();
      final now = DateTime.now();
      final quota = UserQuota(
        quotaId: 'quota1',
        userId: 'user1',
        quotaType: QuotaType.perDay,
        limitAmount: 10000,
        createdAt: now,
        updatedAt: now,
      );

      await manager.createQuota(quota);
      final retrieved = await manager.getQuota('quota1');

      expect(retrieved, isNotNull);
      expect(retrieved!.limitAmount, 10000);
    });

    test('MemoryQuotaManager retrieves user quota', () async {
      final manager = MemoryQuotaManager();
      final now = DateTime.now();
      final quota = UserQuota(
        quotaId: 'quota1',
        userId: 'user1',
        quotaType: QuotaType.perDay,
        limitAmount: 10000,
        createdAt: now,
        updatedAt: now,
      );

      await manager.createQuota(quota);
      final userQuota = await manager.getUserQuota('user1');

      expect(userQuota, isNotNull);
      expect(userQuota!.userId, 'user1');
    });

    test('MemoryQuotaManager adds usage', () async {
      final manager = MemoryQuotaManager();
      final now = DateTime.now();
      final quota = UserQuota(
        quotaId: 'quota1',
        userId: 'user1',
        quotaType: QuotaType.perDay,
        limitAmount: 10000,
        usedAmount: 0,
        createdAt: now,
        updatedAt: now,
      );

      await manager.createQuota(quota);
      await manager.addUsage('quota1', 500);

      final updated = await manager.getQuota('quota1');
      expect(updated!.usedAmount, 500);
    });

    test('MemoryQuotaManager resets quota', () async {
      final manager = MemoryQuotaManager();
      final now = DateTime.now();
      final quota = UserQuota(
        quotaId: 'quota1',
        userId: 'user1',
        quotaType: QuotaType.perDay,
        limitAmount: 10000,
        usedAmount: 5000,
        createdAt: now,
        updatedAt: now,
      );

      await manager.createQuota(quota);
      await manager.resetQuota('quota1');

      final reset = await manager.getQuota('quota1');
      expect(reset!.usedAmount, 0);
    });

    test('MemoryQuotaManager generates usage report', () async {
      final manager = MemoryQuotaManager();
      final now = DateTime.now();
      final quota = UserQuota(
        quotaId: 'quota1',
        userId: 'user1',
        quotaType: QuotaType.perDay,
        limitAmount: 10000,
        usedAmount: 5000,
        createdAt: now,
        updatedAt: now,
      );

      await manager.createQuota(quota);
      final report = await manager.generateUsageReport('user1');

      expect(report.userId, 'user1');
      expect(report.totalRequests, 5000);
    });
  });

  group('PlanManager', () {
    test('MemoryPlanManager creates and retrieves plans', () async {
      final manager = MemoryPlanManager();
      final now = DateTime.now();
      final plan = QuotaPlan(
        planId: 'plan1',
        name: 'Premium',
        description: 'Premium plan',
        quotaLimits: {'api_calls': 100000},
        price: 99.99,
        createdAt: now,
        updatedAt: now,
      );

      await manager.createPlan(plan);
      final retrieved = await manager.getPlan('plan1');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Premium');
    });

    test('MemoryPlanManager retrieves all plans', () async {
      final manager = MemoryPlanManager();
      final now = DateTime.now();

      for (int i = 1; i <= 3; i++) {
        final plan = QuotaPlan(
          planId: 'plan$i',
          name: 'Plan $i',
          description: 'Test plan $i',
          quotaLimits: {'api_calls': 100000},
          price: 50.0 * i,
          createdAt: now,
          updatedAt: now,
        );
        await manager.createPlan(plan);
      }

      final plans = await manager.getAllPlans();
      expect(plans.length, 3);
    });

    test('MemoryPlanManager assigns and retrieves user plan', () async {
      final manager = MemoryPlanManager();
      final now = DateTime.now();

      final plan = QuotaPlan(
        planId: 'plan1',
        name: 'Premium',
        description: 'Premium plan',
        quotaLimits: {'api_calls': 100000},
        price: 99.99,
        createdAt: now,
        updatedAt: now,
      );
      await manager.createPlan(plan);

      final assignment = UserPlanAssignment(
        assignmentId: 'assign1',
        userId: 'user1',
        planId: 'plan1',
        effectiveFrom: now,
        createdAt: now,
        updatedAt: now,
      );
      await manager.assignPlan(assignment);

      final userPlan = await manager.getUserActivePlan('user1');
      expect(userPlan, isNotNull);
      expect(userPlan!.name, 'Premium');
    });
  });

  group('RateLimitManager (Facade)', () {
    test('RateLimitManager creates and retrieves rules', () async {
      final manager = RateLimitManager();
      final now = DateTime.now();
      final rule = RateLimitRule(
        ruleId: 'rule1',
        name: 'API Rate Limit',
        description: 'Basic rate limit',
        strategy: RateLimitStrategy.tokenBucket,
        maxRequests: 1000,
        windowSizeSeconds: 3600,
        createdAt: now,
        updatedAt: now,
      );

      await manager.createRule(rule);
      final retrieved = await manager.getRule('rule1');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'API Rate Limit');
    });

    test('RateLimitManager evaluates requests', () async {
      final manager = RateLimitManager();
      final now = DateTime.now();
      final rule = RateLimitRule(
        ruleId: 'rule1',
        name: 'API Rate Limit',
        description: 'Test',
        strategy: RateLimitStrategy.tokenBucket,
        maxRequests: 1000,
        windowSizeSeconds: 3600,
        createdAt: now,
        updatedAt: now,
      );

      await manager.createRule(rule);
      final response = await manager.evaluateRequest('user1', 'rule1');

      expect(response.allowed, true);
    });

    test('RateLimitManager manages quotas', () async {
      final manager = RateLimitManager();
      final now = DateTime.now();
      final quota = UserQuota(
        quotaId: 'quota1',
        userId: 'user1',
        quotaType: QuotaType.perDay,
        limitAmount: 10000,
        createdAt: now,
        updatedAt: now,
      );

      await manager.createQuota(quota);
      await manager.addUsage('quota1', 500);

      final retrieved = await manager.getQuota('quota1');
      expect(retrieved!.usedAmount, 500);
    });

    test('RateLimitManager manages plans', () async {
      final manager = RateLimitManager();
      final now = DateTime.now();

      final plan = QuotaPlan(
        planId: 'plan1',
        name: 'Premium',
        description: 'Premium plan',
        quotaLimits: {'api_calls': 100000},
        price: 99.99,
        createdAt: now,
        updatedAt: now,
      );
      await manager.createPlan(plan);

      final retrieved = await manager.getPlan('plan1');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Premium');
    });
  });

  group('Integration Tests', () {
    test('Complete rate limiting workflow', () async {
      final manager = RateLimitManager();
      final now = DateTime.now();

      // Create rule
      final rule = RateLimitRule(
        ruleId: 'rule1',
        name: 'API Rate Limit',
        description: 'Test rate limit',
        strategy: RateLimitStrategy.slidingWindow,
        maxRequests: 10,
        windowSizeSeconds: 60,
        createdAt: now,
        updatedAt: now,
      );
      await manager.createRule(rule);

      // Evaluate multiple requests
      for (int i = 0; i < 10; i++) {
        final response = await manager.evaluateRequest('user1', 'rule1');
        expect(response.allowed, true);
      }

      // 11th request should be denied
      final exceededResponse = await manager.evaluateRequest('user1', 'rule1');
      expect(exceededResponse.allowed, false);
    });

    test('Complete quota management workflow', () async {
      final manager = RateLimitManager();
      final now = DateTime.now();

      // Create quota
      final quota = UserQuota(
        quotaId: 'quota1',
        userId: 'user1',
        quotaType: QuotaType.perDay,
        limitAmount: 1000,
        createdAt: now,
        updatedAt: now,
      );
      await manager.createQuota(quota);

      // Add usage
      await manager.addUsage('quota1', 600);
      var current = await manager.getQuota('quota1');
      expect(current!.getStatus(), QuotaStatus.critical);

      // Generate report
      final report = await manager.generateUsageReport('user1');
      expect(report.userId, 'user1');
      expect(report.totalRequests, 600);

      // Reset quota
      await manager.resetQuota('quota1');
      current = await manager.getQuota('quota1');
      expect(current!.usedAmount, 0);
    });

    test('Complete plan assignment workflow', () async {
      final manager = RateLimitManager();
      final now = DateTime.now();

      // Create plans
      final basicPlan = QuotaPlan(
        planId: 'plan_basic',
        name: 'Basic',
        description: 'Basic plan',
        quotaLimits: {'api_calls': 10000},
        price: 9.99,
        createdAt: now,
        updatedAt: now,
      );
      final premiumPlan = QuotaPlan(
        planId: 'plan_premium',
        name: 'Premium',
        description: 'Premium plan',
        quotaLimits: {'api_calls': 100000},
        price: 99.99,
        createdAt: now,
        updatedAt: now,
      );
      await manager.createPlan(basicPlan);
      await manager.createPlan(premiumPlan);

      // Assign basic plan
      final basicAssignment = UserPlanAssignment(
        assignmentId: 'assign1',
        userId: 'user1',
        planId: 'plan_basic',
        effectiveFrom: now,
        createdAt: now,
        updatedAt: now,
      );
      await manager.assignPlan(basicAssignment);

      var userPlan = await manager.getUserActivePlan('user1');
      expect(userPlan!.name, 'Basic');

      // Upgrade to premium
      final premiumAssignment = UserPlanAssignment(
        assignmentId: 'assign2',
        userId: 'user1',
        planId: 'plan_premium',
        effectiveFrom: now,
        createdAt: now,
        updatedAt: now,
      );
      await manager.assignPlan(premiumAssignment);

      userPlan = await manager.getUserActivePlan('user1');
      expect(userPlan!.name, 'Premium');
    });
  });
}
