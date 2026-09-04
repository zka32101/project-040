/// Phase 38: Feature Flags & A/B Testing モデル定義
///
/// フィーチャーフラグ、A/Bテスト、段階的ロールアウト、ユーザーセグメント管理

/// フィーチャーフラグの状態
enum FeatureFlagStatus {
  disabled('disabled'),     // 無効
  enabled('enabled'),       // 有効
  rolling('rolling'),       // ロール中
  scheduled('scheduled');   // スケジュール済み

  final String value;
  const FeatureFlagStatus(this.value);
}

/// ロールアウト戦略
enum RolloutStrategy {
  immediate('immediate'),   // 即座にロール
  gradual('gradual'),       // 段階的ロール
  canary('canary'),         // カナリアロール
  beta('beta'),             // ベータテスト
  scheduled('scheduled');   // スケジュール済み

  final String value;
  const RolloutStrategy(this.value);
}

/// ユーザーセグメント定義
class UserSegment {
  final String segmentId;
  final String name;
  final String description;
  final Map<String, dynamic> rules;  // セグメント条件ルール
  final int estimatedUserCount;      // 推定ユーザー数
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSegment({
    required this.segmentId,
    required this.name,
    required this.description,
    required this.rules,
    this.estimatedUserCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// フィーチャーフラグバリアント (A/Bテスト用)
class FeatureFlagVariant {
  final String variantId;
  final String name;
  final String description;
  final Map<String, dynamic> config;    // バリアント設定
  final double trafficPercentage;       // トラフィック割合 (0-100)
  final List<String>? targetSegments;   // 対象セグメント
  final DateTime createdAt;

  FeatureFlagVariant({
    required this.variantId,
    required this.name,
    required this.description,
    required this.config,
    this.trafficPercentage = 50.0,
    this.targetSegments,
    required this.createdAt,
  });
}

/// フィーチャーフラグ定義
class FeatureFlag {
  final String flagId;
  final String name;
  final String description;
  final FeatureFlagStatus status;
  final RolloutStrategy strategy;
  final List<FeatureFlagVariant> variants;  // A/Bテストのバリアント
  final Map<String, dynamic> config;        // デフォルト設定
  final List<String>? targetSegments;       // 対象セグメント
  final double rolloutPercentage;           // ロール率 (0-100)
  final DateTime? enabledAt;
  final DateTime? disabledAt;
  final DateTime? scheduledAt;              // スケジュール日時
  final List<String>? ownerTeam;            // オーナーチーム
  final Map<String, dynamic>? tags;         // タグ
  final bool allowForcedVariation;          // 強制バリアント許可
  final DateTime createdAt;
  final DateTime updatedAt;

  FeatureFlag({
    required this.flagId,
    required this.name,
    required this.description,
    required this.status,
    required this.strategy,
    this.variants = const [],
    required this.config,
    this.targetSegments,
    this.rolloutPercentage = 0.0,
    this.enabledAt,
    this.disabledAt,
    this.scheduledAt,
    this.ownerTeam,
    this.tags,
    this.allowForcedVariation = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// フラグが有効か
  bool get isEnabled => status == FeatureFlagStatus.enabled;

  /// フラグがロール中か
  bool get isRolling => status == FeatureFlagStatus.rolling;

  /// フラグが完全にロールアウトされているか
  bool get isFullyRolledOut => rolloutPercentage >= 100.0;
}

/// A/Bテスト実験設定
class ExperimentConfig {
  final String experimentId;
  final String flagId;
  final String name;
  final String description;
  final List<FeatureFlagVariant> variants;
  final DateTime startDate;
  final DateTime? endDate;
  final double confidenceLevel;         // 信頼度レベル (例: 0.95)
  final int minSampleSize;              // 最小サンプルサイズ
  final String? primaryMetric;          // 主要メトリック
  final List<String>? secondaryMetrics; // 副次メトリック
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExperimentConfig({
    required this.experimentId,
    required this.flagId,
    required this.name,
    required this.description,
    required this.variants,
    required this.startDate,
    this.endDate,
    this.confidenceLevel = 0.95,
    this.minSampleSize = 100,
    this.primaryMetric,
    this.secondaryMetrics,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 実験が実行中か
  bool get isRunning {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startDate) &&
        (endDate == null || now.isBefore(endDate!));
  }

  /// 実験が完了したか
  bool get isCompleted => endDate != null && DateTime.now().isAfter(endDate!);
}

/// A/Bテスト実験結果
class ExperimentResult {
  final String resultId;
  final String experimentId;
  final String variantId;
  final int sampleSize;
  final int conversions;
  final double conversionRate;          // コンバージョン率
  final double confidenceInterval;      // 信頼区間
  final String? statisticalSignificance; // 統計的有意性
  final Map<String, dynamic>? metrics;  // 追加メトリクス
  final DateTime measuredAt;
  final DateTime createdAt;

  ExperimentResult({
    required this.resultId,
    required this.experimentId,
    required this.variantId,
    required this.sampleSize,
    required this.conversions,
    required this.conversionRate,
    this.confidenceInterval = 0.0,
    this.statisticalSignificance,
    this.metrics,
    required this.measuredAt,
    required this.createdAt,
  });

  /// 結果が統計的に有意か
  bool get isSignificant => confidenceInterval > 0.95;
}

/// フィーチャーフラグイベント (監査ログ)
class FeatureFlagEvent {
  final String eventId;
  final String flagId;
  final String eventType;  // created, updated, enabled, disabled, rolled_out
  final String? userId;    // イベント実行ユーザー
  final Map<String, dynamic>? changes;  // 変更内容
  final String? reason;    // 理由
  final DateTime createdAt;

  FeatureFlagEvent({
    required this.eventId,
    required this.flagId,
    required this.eventType,
    this.userId,
    this.changes,
    this.reason,
    required this.createdAt,
  });
}

/// ユーザーのフラグ評価結果
class FlagEvaluationResult {
  final String flagId;
  final String userId;
  final bool enabled;
  final String? variantId;           // 割り当てられたバリアント
  final Map<String, dynamic>? config; // 適用される設定
  final DateTime evaluatedAt;
  final String? reason;              // 評価理由

  FlagEvaluationResult({
    required this.flagId,
    required this.userId,
    required this.enabled,
    this.variantId,
    this.config,
    required this.evaluatedAt,
    this.reason,
  });
}

/// フィーチャーフラグメトリクス
class FeatureFlagMetrics {
  final String metricsId;
  final String flagId;
  final int totalUsers;              // 総ユーザー数
  final int enabledUsers;            // フラグ有効ユーザー数
  final int disabledUsers;           // フラグ無効ユーザー数
  final Map<String, int> variantUsers; // バリアント別ユーザー数
  final double enabledPercentage;    // 有効率
  final int evaluationCount;         // 評価回数
  final DateTime measuredAt;
  final DateTime createdAt;

  FeatureFlagMetrics({
    required this.metricsId,
    required this.flagId,
    required this.totalUsers,
    required this.enabledUsers,
    required this.disabledUsers,
    this.variantUsers = const {},
    required this.enabledPercentage,
    required this.evaluationCount,
    required this.measuredAt,
    required this.createdAt,
  });

  /// 有効なユーザーの割合を返す (パーセント)
  double get enabledRatePercent => (enabledUsers / totalUsers) * 100;
}

/// フィーチャーフラグ評価コンテキスト
class EvaluationContext {
  final String userId;
  final Map<String, dynamic>? userAttributes;  // ユーザー属性
  final Map<String, dynamic>? environment;     // 環境情報
  final String? forcedVariantId;               // 強制バリアント

  EvaluationContext({
    required this.userId,
    this.userAttributes,
    this.environment,
    this.forcedVariantId,
  });
}

/// フィーチャーフラグロールアウト履歴
class RolloutHistory {
  final String historyId;
  final String flagId;
  final DateTime timestamp;
  final double previousPercentage;
  final double newPercentage;
  final String? reason;
  final String? executedBy;
  final DateTime createdAt;

  RolloutHistory({
    required this.historyId,
    required this.flagId,
    required this.timestamp,
    required this.previousPercentage,
    required this.newPercentage,
    this.reason,
    this.executedBy,
    required this.createdAt,
  });
}

/// フィーチャーフラグレポート
class FeatureFlagReport {
  final String reportId;
  final DateTime generatedAt;
  final List<FeatureFlag> flags;
  final Map<String, FeatureFlagMetrics> metrics;
  final List<ExperimentResult> experimentResults;
  final String summary;  // Markdownフォーマット
  final Map<String, dynamic>? additionalData;

  FeatureFlagReport({
    required this.reportId,
    required this.generatedAt,
    this.flags = const [],
    this.metrics = const {},
    this.experimentResults = const [],
    required this.summary,
    this.additionalData,
  });

  /// レポートをMarkdownで生成
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Feature Flag Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');
    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Total Flags: ${flags.length}');
    buffer.writeln('- Enabled Flags: ${flags.where((f) => f.isEnabled).length}');
    buffer.writeln('- Rolling Out: ${flags.where((f) => f.isRolling).length}');
    buffer.writeln('- Experiments: ${experimentResults.length}');
    buffer.writeln('');

    if (flags.isNotEmpty) {
      buffer.writeln('## Flags');
      buffer.writeln('');
      for (final flag in flags) {
        buffer.writeln('### ${flag.name}');
        buffer.writeln('');
        buffer.writeln('**Status**: ${flag.status.value}');
        buffer.writeln('**Rollout**: ${flag.rolloutPercentage.toStringAsFixed(1)}%');
        buffer.writeln('');
      }
    }

    return buffer.toString();
  }
}
