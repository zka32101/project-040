/// Phase 39: Rate Limiting & Quotas サービス実装
///
/// レート制限管理、クォータ実行、使用状況追跡

import 'package:project_040/models/rate_limit_models.dart';

/// レート制限リポジトリインターフェース
abstract class RateLimitRepository {
  /// ルールを取得
  Future<RateLimitRule?> getRule(String ruleId);

  /// ルールを保存
  Future<void> saveRule(RateLimitRule rule);

  /// すべてのルールを取得
  Future<List<RateLimitRule>> getAllRules();

  /// ルール名で検索
  Future<RateLimitRule?> getRuleByName(String name);

  /// トークンバケットを取得
  Future<TokenBucket?> getTokenBucket(String bucketId);

  /// トークンバケットを保存
  Future<void> saveTokenBucket(TokenBucket bucket);

  /// スライディングウィンドウを取得
  Future<SlidingWindow?> getSlidingWindow(String windowId);

  /// スライディングウィンドウを保存
  Future<void> saveSlidingWindow(SlidingWindow window);

  /// イベントを保存
  Future<void> saveEvent(RateLimitEvent event);

  /// メトリクスを保存
  Future<void> saveMetrics(UsageReport metrics);
}

/// メモリ実装のレート制限リポジトリ
class MemoryRateLimitRepository implements RateLimitRepository {
  final Map<String, RateLimitRule> _rules = {};
  final Map<String, TokenBucket> _tokenBuckets = {};
  final Map<String, SlidingWindow> _slidingWindows = {};
  final Map<String, RateLimitEvent> _events = {};
  final Map<String, UsageReport> _metrics = {};

  @override
  Future<RateLimitRule?> getRule(String ruleId) async => _rules[ruleId];

  @override
  Future<void> saveRule(RateLimitRule rule) async {
    _rules[rule.ruleId] = rule;
  }

  @override
  Future<List<RateLimitRule>> getAllRules() async => _rules.values.toList();

  @override
  Future<RateLimitRule?> getRuleByName(String name) async {
    try {
      return _rules.values.firstWhere((r) => r.name == name);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<TokenBucket?> getTokenBucket(String bucketId) async =>
      _tokenBuckets[bucketId];

  @override
  Future<void> saveTokenBucket(TokenBucket bucket) async {
    _tokenBuckets[bucket.bucketId] = bucket;
  }

  @override
  Future<SlidingWindow?> getSlidingWindow(String windowId) async =>
      _slidingWindows[windowId];

  @override
  Future<void> saveSlidingWindow(SlidingWindow window) async {
    _slidingWindows[window.windowId] = window;
  }

  @override
  Future<void> saveEvent(RateLimitEvent event) async {
    _events[event.eventId] = event;
  }

  @override
  Future<void> saveMetrics(UsageReport metrics) async {
    _metrics[metrics.reportId] = metrics;
  }
}

/// レート制限エンジンインターフェース
abstract class RateLimitEngine {
  /// リクエストを評価
  Future<RateLimitResponse> evaluateRequest(String userId, String ruleId);

  /// 複数ユーザーのリクエストを評価
  Future<List<RateLimitResponse>> evaluateRequests(
    List<String> userIds,
    String ruleId,
  );

  /// トークンバケットを初期化
  Future<TokenBucket> initializeTokenBucket(String userId, String ruleId);

  /// スライディングウィンドウを初期化
  Future<SlidingWindow> initializeSlidingWindow(String userId, String ruleId);
}

/// メモリ実装のレート制限エンジン
class MemoryRateLimitEngine implements RateLimitEngine {
  final RateLimitRepository _repository;

  MemoryRateLimitEngine(this._repository);

  @override
  Future<RateLimitResponse> evaluateRequest(String userId, String ruleId) async {
    final rule = await _repository.getRule(ruleId);
    if (rule == null) {
      return RateLimitResponse(
        allowed: false,
        userId: userId,
        ruleId: ruleId,
        remaining: 0,
        reason: 'Rule not found',
        evaluatedAt: DateTime.now(),
      );
    }

    // ホワイトリストチェック
    if (rule.whitelistedUsers?.contains(userId) ?? false) {
      return RateLimitResponse(
        allowed: true,
        userId: userId,
        ruleId: ruleId,
        remaining: rule.maxRequests,
        reason: 'Whitelisted',
        evaluatedAt: DateTime.now(),
      );
    }

    // ブラックリストチェック
    if (rule.blacklistedUsers?.contains(userId) ?? false) {
      return RateLimitResponse(
        allowed: false,
        userId: userId,
        ruleId: ruleId,
        remaining: 0,
        retryAfterSeconds: rule.windowSizeSeconds,
        reason: 'Blacklisted',
        evaluatedAt: DateTime.now(),
      );
    }

    // ルールが無効
    if (!rule.isActive) {
      return RateLimitResponse(
        allowed: true,
        userId: userId,
        ruleId: ruleId,
        remaining: rule.maxRequests,
        reason: 'Rule disabled',
        evaluatedAt: DateTime.now(),
      );
    }

    // 戦略別に評価
    switch (rule.strategy) {
      case RateLimitStrategy.tokenBucket:
        return await _evaluateTokenBucket(userId, rule);
      case RateLimitStrategy.slidingWindow:
        return await _evaluateSlidingWindow(userId, rule);
      case RateLimitStrategy.fixedWindow:
        return await _evaluateFixedWindow(userId, rule);
      case RateLimitStrategy.leakyBucket:
        return await _evaluateLeakyBucket(userId, rule);
      case RateLimitStrategy.adaptive:
        return await _evaluateAdaptive(userId, rule);
    }
  }

  Future<RateLimitResponse> _evaluateTokenBucket(
      String userId, RateLimitRule rule) async {
    final bucketId = 'bucket:$userId:${rule.ruleId}';
    var bucket = await _repository.getTokenBucket(bucketId);

    if (bucket == null) {
      bucket = TokenBucket(
        bucketId: bucketId,
        userId: userId,
        tokens: rule.maxRequests.toDouble(),
        maxTokens: rule.maxRequests.toDouble(),
        refillRate: rule.maxRequests / rule.windowSizeSeconds,
        lastRefillTime: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await _repository.saveTokenBucket(bucket);
    }

    final allowed = bucket.tryConsume(1.0);
    await _repository.saveTokenBucket(bucket);

    return RateLimitResponse(
      allowed: allowed,
      userId: userId,
      ruleId: rule.ruleId,
      remaining: bucket.tokens.toInt(),
      retryAfterSeconds: allowed ? null : rule.windowSizeSeconds,
      reason: allowed ? 'Allowed' : 'Rate limit exceeded',
      evaluatedAt: DateTime.now(),
    );
  }

  Future<RateLimitResponse> _evaluateSlidingWindow(
      String userId, RateLimitRule rule) async {
    final windowId = 'window:$userId:${rule.ruleId}';
    var window = await _repository.getSlidingWindow(windowId);

    if (window == null) {
      window = SlidingWindow(
        windowId: windowId,
        userId: userId,
        requestTimestamps: [],
        maxRequests: rule.maxRequests,
        windowSizeSeconds: rule.windowSizeSeconds,
        createdAt: DateTime.now(),
      );
      await _repository.saveSlidingWindow(window);
    }

    final allowed = window.isAllowed();
    if (allowed) {
      window.recordRequest();
      await _repository.saveSlidingWindow(window);
    }

    return RateLimitResponse(
      allowed: allowed,
      userId: userId,
      ruleId: rule.ruleId,
      remaining: (rule.maxRequests - window.requestTimestamps.length).clamp(0, rule.maxRequests),
      retryAfterSeconds: allowed ? null : rule.windowSizeSeconds,
      reason: allowed ? 'Allowed' : 'Rate limit exceeded',
      evaluatedAt: DateTime.now(),
    );
  }

  Future<RateLimitResponse> _evaluateFixedWindow(
      String userId, RateLimitRule rule) async {
    // 固定ウィンドウは簡易実装
    final hash = userId.hashCode.abs() % 100;
    final allowed = hash < ((rule.maxRequests / 100) * 100).toInt();

    return RateLimitResponse(
      allowed: allowed,
      userId: userId,
      ruleId: rule.ruleId,
      remaining: rule.maxRequests,
      retryAfterSeconds: allowed ? null : rule.windowSizeSeconds,
      reason: allowed ? 'Allowed' : 'Rate limit exceeded',
      evaluatedAt: DateTime.now(),
    );
  }

  Future<RateLimitResponse> _evaluateLeakyBucket(
      String userId, RateLimitRule rule) async {
    // リーキーバケットはトークンバケットと同様に実装
    return await _evaluateTokenBucket(userId, rule);
  }

  Future<RateLimitResponse> _evaluateAdaptive(
      String userId, RateLimitRule rule) async {
    // 適応型の簡易実装
    final hash = userId.hashCode.abs() % 100;
    final adaptiveLimit = (rule.maxRequests * 1.5).toInt();
    final allowed = hash < ((adaptiveLimit / 100) * 100).toInt();

    return RateLimitResponse(
      allowed: allowed,
      userId: userId,
      ruleId: rule.ruleId,
      remaining: (adaptiveLimit - (hash / 100 * adaptiveLimit).toInt()).clamp(0, adaptiveLimit),
      retryAfterSeconds: allowed ? null : rule.windowSizeSeconds,
      reason: allowed ? 'Allowed' : 'Rate limit exceeded',
      evaluatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<RateLimitResponse>> evaluateRequests(
    List<String> userIds,
    String ruleId,
  ) async {
    final responses = <RateLimitResponse>[];
    for (final userId in userIds) {
      final response = await evaluateRequest(userId, ruleId);
      responses.add(response);
    }
    return responses;
  }

  @override
  Future<TokenBucket> initializeTokenBucket(String userId, String ruleId) async {
    final rule = await _repository.getRule(ruleId);
    if (rule == null) {
      throw Exception('Rule not found');
    }

    final bucket = TokenBucket(
      bucketId: 'bucket:$userId:$ruleId',
      userId: userId,
      tokens: rule.maxRequests.toDouble(),
      maxTokens: rule.maxRequests.toDouble(),
      refillRate: rule.maxRequests / rule.windowSizeSeconds,
      lastRefillTime: DateTime.now(),
      createdAt: DateTime.now(),
    );
    await _repository.saveTokenBucket(bucket);
    return bucket;
  }

  @override
  Future<SlidingWindow> initializeSlidingWindow(
      String userId, String ruleId) async {
    final rule = await _repository.getRule(ruleId);
    if (rule == null) {
      throw Exception('Rule not found');
    }

    final window = SlidingWindow(
      windowId: 'window:$userId:$ruleId',
      userId: userId,
      requestTimestamps: [],
      maxRequests: rule.maxRequests,
      windowSizeSeconds: rule.windowSizeSeconds,
      createdAt: DateTime.now(),
    );
    await _repository.saveSlidingWindow(window);
    return window;
  }
}

/// クォータマネージャーインターフェース
abstract class QuotaManager {
  /// クォータを作成
  Future<void> createQuota(UserQuota quota);

  /// クォータを取得
  Future<UserQuota?> getQuota(String quotaId);

  /// ユーザーのクォータを取得
  Future<UserQuota?> getUserQuota(String userId);

  /// 使用量を追加
  Future<void> addUsage(String quotaId, int amount);

  /// クォータをリセット
  Future<void> resetQuota(String quotaId);

  /// 使用状況レポートを生成
  Future<UsageReport> generateUsageReport(String userId);
}

/// メモリ実装のクォータマネージャー
class MemoryQuotaManager implements QuotaManager {
  final Map<String, UserQuota> _quotas = {};
  final Map<String, UsageReport> _reports = {};

  @override
  Future<void> createQuota(UserQuota quota) async {
    _quotas[quota.quotaId] = quota;
  }

  @override
  Future<UserQuota?> getQuota(String quotaId) async => _quotas[quotaId];

  @override
  Future<UserQuota?> getUserQuota(String userId) async {
    try {
      return _quotas.values.firstWhere((q) => q.userId == userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addUsage(String quotaId, int amount) async {
    final quota = _quotas[quotaId];
    if (quota != null) {
      quota.usedAmount += amount;
    }
  }

  @override
  Future<void> resetQuota(String quotaId) async {
    final quota = _quotas[quotaId];
    if (quota != null) {
      quota.reset();
    }
  }

  @override
  Future<UsageReport> generateUsageReport(String userId) async {
    final quota = await getUserQuota(userId);
    if (quota == null) {
      throw Exception('Quota not found');
    }

    final report = UsageReport(
      reportId: 'report:${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      generatedAt: DateTime.now(),
      usageByEndpoint: {'api': quota.usedAmount},
      usageByHour: {},
      usageByDay: {},
      totalRequests: quota.usedAmount,
      averageRequestsPerHour: (quota.usedAmount / 24).toDouble(),
      peakRequestsPerHour: (quota.usedAmount / 10).toDouble(),
    );

    _reports[report.reportId] = report;
    return report;
  }
}

/// プランマネージャーインターフェース
abstract class PlanManager {
  /// プランを作成
  Future<void> createPlan(QuotaPlan plan);

  /// プランを取得
  Future<QuotaPlan?> getPlan(String planId);

  /// すべてのプランを取得
  Future<List<QuotaPlan>> getAllPlans();

  /// ユーザーにプランを割り当て
  Future<void> assignPlan(UserPlanAssignment assignment);

  /// ユーザーのアクティブなプランを取得
  Future<QuotaPlan?> getUserActivePlan(String userId);
}

/// メモリ実装のプランマネージャー
class MemoryPlanManager implements PlanManager {
  final Map<String, QuotaPlan> _plans = {};
  final Map<String, UserPlanAssignment> _assignments = {};

  @override
  Future<void> createPlan(QuotaPlan plan) async {
    _plans[plan.planId] = plan;
  }

  @override
  Future<QuotaPlan?> getPlan(String planId) async => _plans[planId];

  @override
  Future<List<QuotaPlan>> getAllPlans() async => _plans.values.toList();

  @override
  Future<void> assignPlan(UserPlanAssignment assignment) async {
    _assignments[assignment.assignmentId] = assignment;
  }

  @override
  Future<QuotaPlan?> getUserActivePlan(String userId) async {
    try {
      final assignment = _assignments.values.firstWhere(
        (a) => a.userId == userId && a.isEffective,
      );
      return _plans[assignment.planId];
    } catch (e) {
      return null;
    }
  }
}

/// レート制限マネージャー (ファサードパターン)
class RateLimitManager {
  late RateLimitRepository _repository;
  late RateLimitEngine _engine;
  late QuotaManager _quotaManager;
  late PlanManager _planManager;

  RateLimitManager({
    RateLimitRepository? repository,
    RateLimitEngine? engine,
    QuotaManager? quotaManager,
    PlanManager? planManager,
  }) {
    _repository = repository ?? MemoryRateLimitRepository();
    _engine = engine ?? MemoryRateLimitEngine(_repository);
    _quotaManager = quotaManager ?? MemoryQuotaManager();
    _planManager = planManager ?? MemoryPlanManager();
  }

  /// ルールを作成
  Future<void> createRule(RateLimitRule rule) => _repository.saveRule(rule);

  /// ルールを取得
  Future<RateLimitRule?> getRule(String ruleId) => _repository.getRule(ruleId);

  /// すべてのルールを取得
  Future<List<RateLimitRule>> getAllRules() => _repository.getAllRules();

  /// リクエストを評価
  Future<RateLimitResponse> evaluateRequest(String userId, String ruleId) =>
      _engine.evaluateRequest(userId, ruleId);

  /// 複数リクエストを評価
  Future<List<RateLimitResponse>> evaluateRequests(
    List<String> userIds,
    String ruleId,
  ) =>
      _engine.evaluateRequests(userIds, ruleId);

  /// トークンバケットを初期化
  Future<TokenBucket> initializeTokenBucket(String userId, String ruleId) =>
      _engine.initializeTokenBucket(userId, ruleId);

  /// スライディングウィンドウを初期化
  Future<SlidingWindow> initializeSlidingWindow(String userId, String ruleId) =>
      _engine.initializeSlidingWindow(userId, ruleId);

  /// クォータを作成
  Future<void> createQuota(UserQuota quota) => _quotaManager.createQuota(quota);

  /// クォータを取得
  Future<UserQuota?> getQuota(String quotaId) => _quotaManager.getQuota(quotaId);

  /// ユーザーのクォータを取得
  Future<UserQuota?> getUserQuota(String userId) =>
      _quotaManager.getUserQuota(userId);

  /// 使用量を追加
  Future<void> addUsage(String quotaId, int amount) =>
      _quotaManager.addUsage(quotaId, amount);

  /// クォータをリセット
  Future<void> resetQuota(String quotaId) => _quotaManager.resetQuota(quotaId);

  /// 使用状況レポート
  Future<UsageReport> generateUsageReport(String userId) =>
      _quotaManager.generateUsageReport(userId);

  /// プランを作成
  Future<void> createPlan(QuotaPlan plan) => _planManager.createPlan(plan);

  /// プランを取得
  Future<QuotaPlan?> getPlan(String planId) => _planManager.getPlan(planId);

  /// すべてのプランを取得
  Future<List<QuotaPlan>> getAllPlans() => _planManager.getAllPlans();

  /// ユーザーにプランを割り当て
  Future<void> assignPlan(UserPlanAssignment assignment) =>
      _planManager.assignPlan(assignment);

  /// ユーザーのアクティブなプランを取得
  Future<QuotaPlan?> getUserActivePlan(String userId) =>
      _planManager.getUserActivePlan(userId);
}
