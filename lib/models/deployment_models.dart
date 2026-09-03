/// Phase 37: Deployment & Release Management モデル定義
///
/// リリース管理、デプロイメント戦略、ロールバック管理

/// リリースチャネル
enum ReleaseChannel {
  stable('stable'),       // 本番リリース
  beta('beta'),          // ベータリリース
  alpha('alpha'),        // アルファリリース
  canary('canary');      // カナリアリリース

  final String value;
  const ReleaseChannel(this.value);
}

/// デプロイメント戦略
enum DeploymentStrategy {
  blueGreen('blue-green'),    // ブルーグリーンデプロイメント
  canary('canary'),           // カナリアデプロイメント
  rolling('rolling'),         // ローリングデプロイメント
  immediate('immediate');     // 即座のデプロイメント

  final String value;
  const DeploymentStrategy(this.value);
}

/// デプロイメント状態
enum DeploymentStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  failed('failed'),
  rolledBack('rolled_back');

  final String value;
  const DeploymentStatus(this.value);
}

/// セマンティックバージョン
class SemanticVersion implements Comparable<SemanticVersion> {
  final int major;
  final int minor;
  final int patch;
  final String? prerelease;  // alpha, beta, rc等
  final String? metadata;     // ビルドメタデータ

  SemanticVersion({
    required this.major,
    required this.minor,
    required this.patch,
    this.prerelease,
    this.metadata,
  });

  /// バージョン文字列を返す (例: 1.2.3-alpha.1+build.123)
  @override
  String toString() {
    final buffer = StringBuffer('$major.$minor.$patch');
    if (prerelease != null) buffer.write('-$prerelease');
    if (metadata != null) buffer.write('+$metadata');
    return buffer.toString();
  }

  /// バージョン比較
  @override
  int compareTo(SemanticVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);
    // プレリリース版は通常版より小さい
    if (prerelease != null && other.prerelease == null) return -1;
    if (prerelease == null && other.prerelease != null) return 1;
    return prerelease?.compareTo(other.prerelease ?? '') ?? 0;
  }

  /// バージョンの次のマイナーバージョンを返す
  SemanticVersion nextMinor() =>
      SemanticVersion(major: major, minor: minor + 1, patch: 0);

  /// バージョンの次のパッチバージョンを返す
  SemanticVersion nextPatch() =>
      SemanticVersion(major: major, minor: minor, patch: patch + 1);

  /// バージョンの次のメジャーバージョンを返す
  SemanticVersion nextMajor() =>
      SemanticVersion(major: major + 1, minor: 0, patch: 0);
}

/// チェンジログエントリ
class ChangeLogEntry {
  final String entryId;
  final String version;
  final String changeType;  // added, changed, deprecated, removed, fixed, security
  final String description;
  final DateTime releaseDate;
  final List<String>? affectedComponents;  // 影響を受けたコンポーネント
  final String? migrateInfo;                // 移行情報
  final DateTime createdAt;

  ChangeLogEntry({
    required this.entryId,
    required this.version,
    required this.changeType,
    required this.description,
    required this.releaseDate,
    this.affectedComponents,
    this.migrateInfo,
    required this.createdAt,
  });
}

/// リリース情報
class Release {
  final String releaseId;
  final String version;
  final ReleaseChannel channel;
  final String title;
  final String description;
  final List<ChangeLogEntry> changeLog;
  final DateTime createdAt;
  final DateTime releasedAt;
  final String? releaseNotes;     // Markdownフォーマット
  final List<String> assets;      // アセットリンク
  final bool isDraft;
  final bool isPrerelease;
  final DateTime? deprecatedAt;   // 非推奨になった日時
  final DateTime? sunsetDate;     // サポート終了予定日

  Release({
    required this.releaseId,
    required this.version,
    required this.channel,
    required this.title,
    required this.description,
    this.changeLog = const [],
    required this.createdAt,
    required this.releasedAt,
    this.releaseNotes,
    this.assets = const [],
    this.isDraft = false,
    this.isPrerelease = false,
    this.deprecatedAt,
    this.sunsetDate,
  });

  /// リリースが非推奨か
  bool get isDeprecated => deprecatedAt != null;

  /// リリースのサポートが終了しているか
  bool get isSunset => sunsetDate != null && DateTime.now().isAfter(sunsetDate!);
}

/// デプロイメント設定
class DeploymentConfig {
  final String configId;
  final String environmentName;
  final String? baseUrl;
  final Map<String, String> environmentVariables;
  final int minInstances;           // 最小インスタンス数
  final int maxInstances;           // 最大インスタンス数
  final Duration healthCheckInterval;
  final int maxRetries;
  final Duration retryDelay;
  final bool autoRollback;          // 自動ロールバック
  final int rollbackThresholdPercent; // ロールバック閾値
  final DateTime createdAt;

  DeploymentConfig({
    required this.configId,
    required this.environmentName,
    this.baseUrl,
    this.environmentVariables = const {},
    this.minInstances = 1,
    this.maxInstances = 10,
    this.healthCheckInterval = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 10),
    this.autoRollback = true,
    this.rollbackThresholdPercent = 5,
    required this.createdAt,
  });
}

/// デプロイメント情報
class Deployment {
  final String deploymentId;
  final String releaseId;
  final String version;
  final String environmentName;
  final DeploymentStrategy strategy;
  final DeploymentStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int totalInstances;
  final int successfulInstances;
  final int failedInstances;
  final String? errorMessage;
  final String? errorStackTrace;
  final String? previousVersion;   // ロールバック対象バージョン
  final Duration deploymentDuration;
  final double? progressPercent;    // 進捗 (0-100)
  final Map<String, dynamic>? metrics; // デプロイメント指標
  final DateTime createdAt;
  final DateTime updatedAt;

  Deployment({
    required this.deploymentId,
    required this.releaseId,
    required this.version,
    required this.environmentName,
    required this.strategy,
    required this.status,
    required this.startedAt,
    this.completedAt,
    required this.totalInstances,
    this.successfulInstances = 0,
    this.failedInstances = 0,
    this.errorMessage,
    this.errorStackTrace,
    this.previousVersion,
    required this.deploymentDuration,
    this.progressPercent,
    this.metrics,
    required this.createdAt,
    required this.updatedAt,
  });

  /// デプロイメントが成功したか
  bool get isSuccessful => status == DeploymentStatus.completed;

  /// デプロイメントが失敗したか
  bool get isFailed => status == DeploymentStatus.failed;

  /// デプロイメントがロールバック可能か
  bool get canRollback =>
      (isSuccessful || isFailed) && previousVersion != null;

  /// 成功率を返す
  double get successRate {
    if (totalInstances == 0) return 0.0;
    return (successfulInstances / totalInstances) * 100;
  }
}

/// ロールバックポリシー
class RollbackPolicy {
  final String policyId;
  final bool autoRollback;
  final int errorRateThreshold;     // エラー率閾値 (%)
  final int failureCountThreshold;  // 失敗数閾値
  final Duration timeToDecide;      // 判断までの時間
  final List<String> rollbackTriggers; // ロールバックのトリガー
  final DateTime createdAt;

  RollbackPolicy({
    required this.policyId,
    this.autoRollback = true,
    this.errorRateThreshold = 10,
    this.failureCountThreshold = 5,
    this.timeToDecide = const Duration(minutes: 5),
    this.rollbackTriggers = const [],
    required this.createdAt,
  });
}

/// ロールバック情報
class Rollback {
  final String rollbackId;
  final String deploymentId;
  final String fromVersion;
  final String toVersion;
  final DateTime initiatedAt;
  final DateTime? completedAt;
  final String reason;              // ロールバック理由
  final String? initiatedBy;        // ロールバック実行者
  final bool isAutomatic;
  final DeploymentStatus status;
  final Duration duration;
  final Map<String, dynamic>? metrics;
  final DateTime createdAt;

  Rollback({
    required this.rollbackId,
    required this.deploymentId,
    required this.fromVersion,
    required this.toVersion,
    required this.initiatedAt,
    this.completedAt,
    required this.reason,
    this.initiatedBy,
    this.isAutomatic = false,
    required this.status,
    required this.duration,
    this.metrics,
    required this.createdAt,
  });

  /// ロールバックが完了したか
  bool get isCompleted => status == DeploymentStatus.completed;
}

/// デプロイメント指標
class DeploymentMetrics {
  final String metricsId;
  final String deploymentId;
  final Duration deploymentDuration;
  final int totalRequests;
  final int successfulRequests;
  final int failedRequests;
  final double averageLatency;      // ミリ秒
  final double errorRate;           // パーセント
  final double cpuUsage;
  final double memoryUsage;
  final int activeConnections;
  final DateTime measuredAt;
  final DateTime createdAt;

  DeploymentMetrics({
    required this.metricsId,
    required this.deploymentId,
    required this.deploymentDuration,
    required this.totalRequests,
    required this.successfulRequests,
    required this.failedRequests,
    required this.averageLatency,
    required this.errorRate,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.activeConnections,
    required this.measuredAt,
    required this.createdAt,
  });

  /// 健全性をチェック (エラー率が低いか)
  bool get isHealthy => errorRate < 5.0;

  /// 高パフォーマンスか
  bool get isHighPerformance => averageLatency < 100.0;
}

/// リリースノート
class ReleaseNotice {
  final String noticeId;
  final String releaseId;
  final String version;
  final String title;
  final String content;            // Markdownフォーマット
  final ReleaseChannel channel;
  final DateTime publishedAt;
  final List<String> highlightedFeatures;
  final List<String> knownIssues;
  final String? downloadUrl;
  final String? documentationUrl;
  final bool isPublished;
  final DateTime createdAt;

  ReleaseNotice({
    required this.noticeId,
    required this.releaseId,
    required this.version,
    required this.title,
    required this.content,
    required this.channel,
    required this.publishedAt,
    this.highlightedFeatures = const [],
    this.knownIssues = const [],
    this.downloadUrl,
    this.documentationUrl,
    this.isPublished = false,
    required this.createdAt,
  });
}

/// デプロイメント履歴
class DeploymentHistory {
  final String historyId;
  final String environmentName;
  final List<Deployment> deployments;
  final List<Rollback> rollbacks;
  final DateTime createdAt;

  DeploymentHistory({
    required this.historyId,
    required this.environmentName,
    this.deployments = const [],
    this.rollbacks = const [],
    required this.createdAt,
  });

  /// 最後のデプロイメントを取得
  Deployment? get lastDeployment =>
      deployments.isNotEmpty ? deployments.last : null;

  /// 最後の成功したデプロイメントを取得
  Deployment? get lastSuccessfulDeployment =>
      deployments.where((d) => d.isSuccessful).isNotEmpty
          ? deployments.where((d) => d.isSuccessful).last
          : null;

  /// 稼働中のバージョンを取得
  String? get currentVersion => lastSuccessfulDeployment?.version;
}

/// デプロイメントレポート
class DeploymentReport {
  final String reportId;
  final String deploymentId;
  final String version;
  final String environmentName;
  final DateTime generatedAt;
  final Deployment deployment;
  final DeploymentMetrics? metrics;
  final List<String> warnings;
  final List<String> errors;
  final String summary;            // Markdownフォーマット
  final Map<String, dynamic>? additionalData;

  DeploymentReport({
    required this.reportId,
    required this.deploymentId,
    required this.version,
    required this.environmentName,
    required this.generatedAt,
    required this.deployment,
    this.metrics,
    this.warnings = const [],
    this.errors = const [],
    required this.summary,
    this.additionalData,
  });

  /// レポートをMarkdownで生成
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Deployment Report');
    buffer.writeln('');
    buffer.writeln('**Version**: $version');
    buffer.writeln('**Environment**: $environmentName');
    buffer.writeln('**Date**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');
    buffer.writeln('## Status');
    buffer.writeln('');
    buffer.writeln('- **Deployment Status**: ${deployment.status.value}');
    buffer.writeln('- **Duration**: ${deployment.deploymentDuration.inSeconds}s');
    buffer.writeln(
        '- **Success Rate**: ${deployment.successRate.toStringAsFixed(2)}%');
    buffer.writeln('');

    if (metrics != null) {
      buffer.writeln('## Metrics');
      buffer.writeln('');
      buffer.writeln('- **Avg Latency**: ${metrics!.averageLatency}ms');
      buffer.writeln('- **Error Rate**: ${metrics!.errorRate.toStringAsFixed(2)}%');
      buffer.writeln('- **CPU Usage**: ${metrics!.cpuUsage.toStringAsFixed(2)}%');
      buffer.writeln(
          '- **Memory Usage**: ${metrics!.memoryUsage.toStringAsFixed(2)}%');
      buffer.writeln('');
    }

    if (errors.isNotEmpty) {
      buffer.writeln('## Errors');
      buffer.writeln('');
      for (final error in errors) {
        buffer.writeln('- $error');
      }
      buffer.writeln('');
    }

    if (warnings.isNotEmpty) {
      buffer.writeln('## Warnings');
      buffer.writeln('');
      for (final warning in warnings) {
        buffer.writeln('- $warning');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}
