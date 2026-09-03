/// Phase 39: Rate Limiting & Quotas レート制限・クォータモデル定義
///
/// API レート制限、ユーザークォータ、使用状況追跡、制限戦略

/// レート制限戦略
enum RateLimitStrategy {
  tokenBucket('token_bucket'),     // トークンバケット
  slidingWindow('sliding_window'),  // スライディングウィンドウ
  fixedWindow('fixed_window'),      // 固定ウィンドウ
  leakyBucket('leaky_bucket'),      // リーキーバケット
  adaptive('adaptive');             // 適応型

  final String value;
  const RateLimitStrategy(this.value);
}

/// クォータタイプ
enum QuotaType {
  perMinute('per_minute'),
  perHour('per_hour'),
  perDay('per_day'),
  perMonth('per_month'),
  unlimited('unlimited');

  final String value;
  const QuotaType(this.value);
}

/// クォータ状態
enum QuotaStatus {
  healthy('healthy'),           // 健全 (使用量 < 50%)
  warning('warning'),           // 警告 (50% <= 使用量 < 90%)
  critical('critical'),         // 重大 (使用量 >= 90%)
  exceeded('exceeded');         // 超過

  final String value;
  const QuotaStatus(this.value);
}

/// レート制限ルール
class RateLimitRule {
  final String ruleId;
  final String name;
  final String description;
  final RateLimitStrategy strategy;
  final int maxRequests;              // 最大リクエスト数
  final int windowSizeSeconds;        // ウィンドウサイズ (秒)
  final bool enableQueuing;           // キューイング有効
  final int? maxQueueSize;            // 最大キュー
  final double? burstMultiplier;      // バースト乗数
  final List<String>? whitelistedUsers; // ホワイトリストユーザー
  final List<String>? blacklistedUsers; // ブラックリストユーザー
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RateLimitRule({
    required this.ruleId,
    required this.name,
    required this.description,
    required this.strategy,
    required this.maxRequests,
    required this.windowSizeSeconds,
    this.enableQueuing = false,
    this.maxQueueSize,
    this.burstMultiplier,
    this.whitelistedUsers,
    this.blacklistedUsers,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// トークンバケット状態
class TokenBucket {
  final String bucketId;
  final String userId;
  double tokens;                      // 現在のトークン数
  final double maxTokens;             // 最大トークン数
  final double refillRate;            // トークン補充率 (tokens/second)
  DateTime lastRefillTime;
  final bool isPaused;
  final DateTime createdAt;

  TokenBucket({
    required this.bucketId,
    required this.userId,
    required this.tokens,
    required this.maxTokens,
    required this.refillRate,
    required this.lastRefillTime,
    this.isPaused = false,
    required this.createdAt,
  });

  /// トークンを補充
  void refill() {
    if (isPaused) return;
    final now = DateTime.now();
    final elapsed = now.difference(lastRefillTime).inMilliseconds / 1000.0;
    final tokensToAdd = elapsed * refillRate;
    tokens = (tokens + tokensToAdd).clamp(0, maxTokens);
    lastRefillTime = now;
  }

  /// トークンを消費できるか
  bool canConsume(double amount) {
    refill();
    return tokens >= amount;
  }

  /// トークンを消費
  bool tryConsume(double amount) {
    if (canConsume(amount)) {
      tokens -= amount;
      return true;
    }
    return false;
  }
}

/// スライディングウィンドウ
class SlidingWindow {
  final String windowId;
  final String userId;
  final List<DateTime> requestTimestamps; // リクエストタイムスタンプ
  final int maxRequests;
  final int windowSizeSeconds;
  final DateTime createdAt;

  SlidingWindow({
    required this.windowId,
    required this.userId,
    required this.requestTimestamps,
    required this.maxRequests,
    required this.windowSizeSeconds,
    required this.createdAt,
  });

  /// 古いリクエストを削除
  void pruneOldRequests() {
    final now = DateTime.now();
    final cutoffTime = now.subtract(Duration(seconds: windowSizeSeconds));
    requestTimestamps.removeWhere((ts) => ts.isBefore(cutoffTime));
  }

  /// リクエストが許可されているか
  bool isAllowed() {
    pruneOldRequests();
    return requestTimestamps.length < maxRequests;
  }

  /// リクエストを記録
  void recordRequest() {
    if (isAllowed()) {
      requestTimestamps.add(DateTime.now());
    }
  }

  /// 現在の使用率
  double get usagePercentage => (requestTimestamps.length / maxRequests) * 100;
}

/// ユーザークォータ
class UserQuota {
  final String quotaId;
  final String userId;
  final QuotaType quotaType;
  final int limitAmount;              // 制限量
  int usedAmount;                     // 使用量
  final List<String>? allowedEndpoints; // 許可エンドポイント
  final DateTime? resetTime;          // リセット時刻
  final bool isSoftLimit;             // ソフトリミット (警告のみ)
  final DateTime createdAt;
  final DateTime updatedAt;

  UserQuota({
    required this.quotaId,
    required this.userId,
    required this.quotaType,
    required this.limitAmount,
    this.usedAmount = 0,
    this.allowedEndpoints,
    this.resetTime,
    this.isSoftLimit = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// クォータ状態を取得
  QuotaStatus getStatus() {
    final percentage = (usedAmount / limitAmount) * 100;
    if (percentage >= 100) return QuotaStatus.exceeded;
    if (percentage >= 90) return QuotaStatus.critical;
    if (percentage >= 50) return QuotaStatus.warning;
    return QuotaStatus.healthy;
  }

  /// リセットが必要か
  bool needsReset() {
    if (resetTime == null) return false;
    return DateTime.now().isAfter(resetTime!);
  }

  /// クォータをリセット
  void reset() {
    usedAmount = 0;
  }

  /// クォータの使用率
  double get usagePercentage => (usedAmount / limitAmount) * 100;

  /// 残りのクォータ
  int get remaining => (limitAmount - usedAmount).clamp(0, limitAmount);
}

/// レート制限イベント
class RateLimitEvent {
  final String eventId;
  final String userId;
  final String ruleId;
  final String eventType;             // limited, warned, reset, exceeded
  final String? reason;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  RateLimitEvent({
    required this.eventId,
    required this.userId,
    required this.ruleId,
    required this.eventType,
    this.reason,
    this.metadata,
    required this.createdAt,
  });
}

/// レート制限応答
class RateLimitResponse {
  final bool allowed;
  final String userId;
  final String ruleId;
  final int remaining;                // 残りリクエスト数
  final int? retryAfterSeconds;       // 再試行秒数
  final String? reason;
  final Map<String, dynamic>? headers; // レスポンスヘッダ
  final DateTime evaluatedAt;

  RateLimitResponse({
    required this.allowed,
    required this.userId,
    required this.ruleId,
    required this.remaining,
    this.retryAfterSeconds,
    this.reason,
    this.headers,
    required this.evaluatedAt,
  });
}

/// 使用状況レポート
class UsageReport {
  final String reportId;
  final String userId;
  final DateTime generatedAt;
  final Map<String, int> usageByEndpoint;    // エンドポイント別使用量
  final Map<String, int> usageByHour;        // 時間別使用量
  final Map<String, int> usageByDay;         // 日別使用量
  final int totalRequests;
  final double averageRequestsPerHour;
  final double peakRequestsPerHour;
  final String? summary;               // Markdownサマリー
  final Map<String, dynamic>? metadata;

  UsageReport({
    required this.reportId,
    required this.userId,
    required this.generatedAt,
    this.usageByEndpoint = const {},
    this.usageByHour = const {},
    this.usageByDay = const {},
    required this.totalRequests,
    required this.averageRequestsPerHour,
    required this.peakRequestsPerHour,
    this.summary,
    this.metadata,
  });

  /// レポートをMarkdownで生成
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Usage Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('**User ID**: $userId');
    buffer.writeln('');
    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Total Requests: $totalRequests');
    buffer.writeln('- Avg Requests/Hour: ${averageRequestsPerHour.toStringAsFixed(2)}');
    buffer.writeln('- Peak Requests/Hour: ${peakRequestsPerHour.toStringAsFixed(2)}');
    buffer.writeln('');

    if (usageByEndpoint.isNotEmpty) {
      buffer.writeln('## Usage by Endpoint');
      buffer.writeln('');
      usageByEndpoint.forEach((endpoint, usage) {
        buffer.writeln('- $endpoint: $usage');
      });
      buffer.writeln('');
    }

    return buffer.toString();
  }
}

/// 適応型レート制限
class AdaptiveRateLimit {
  final String limitId;
  final String userId;
  int baseMaxRequests;
  final int windowSizeSeconds;
  double currentMultiplier;            // 現在の乗数
  final double minMultiplier;
  final double maxMultiplier;
  final double adjustmentFactor;      // 調整係数
  int consecutiveViolations;           // 連続違反回数
  DateTime lastViolationTime;
  final bool enabled;
  final DateTime createdAt;

  AdaptiveRateLimit({
    required this.limitId,
    required this.userId,
    required this.baseMaxRequests,
    required this.windowSizeSeconds,
    this.currentMultiplier = 1.0,
    this.minMultiplier = 0.5,
    this.maxMultiplier = 2.0,
    this.adjustmentFactor = 0.1,
    this.consecutiveViolations = 0,
    required this.lastViolationTime,
    this.enabled = true,
    required this.createdAt,
  });

  /// 現在の制限を取得
  int get currentLimit => (baseMaxRequests * currentMultiplier).toInt();

  /// 違反時に乗数を低下
  void recordViolation() {
    consecutiveViolations++;
    lastViolationTime = DateTime.now();
    currentMultiplier =
        (currentMultiplier - adjustmentFactor).clamp(minMultiplier, maxMultiplier);
  }

  /// 成功時に乗数を回復
  void recordSuccess() {
    if (consecutiveViolations > 0) {
      consecutiveViolations--;
      currentMultiplier =
          (currentMultiplier + adjustmentFactor * 0.5).clamp(minMultiplier, maxMultiplier);
    }
  }

  /// リセット条件をチェック
  bool shouldReset() {
    const resetWindowHours = 1;
    return DateTime.now().difference(lastViolationTime).inHours >= resetWindowHours &&
        consecutiveViolations == 0;
  }
}

/// クォータプラン
class QuotaPlan {
  final String planId;
  final String name;
  final String description;
  final Map<String, int> quotaLimits;  // リソース別制限
  final double price;                 // 月額価格
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuotaPlan({
    required this.planId,
    required this.name,
    required this.description,
    required this.quotaLimits,
    required this.price,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// ユーザープラン割り当て
class UserPlanAssignment {
  final String assignmentId;
  final String userId;
  final String planId;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPlanAssignment({
    required this.assignmentId,
    required this.userId,
    required this.planId,
    required this.effectiveFrom,
    this.effectiveUntil,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 割り当てが有効か
  bool get isEffective {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(effectiveFrom) &&
        (effectiveUntil == null || now.isBefore(effectiveUntil!));
  }
}
