/// Phase 25: ジョブ分析・レポーティング
/// 実行時間分析、成功率、パフォーマンスメトリクス

import 'async_job_model.dart';

/// ジョブ実行時間分析
class ExecutionTimeAnalytics {
  /// ジョブ ID
  final String jobId;

  /// ジョブタイプ
  final AsyncJobType jobType;

  /// 実行時間（ミリ秒）
  final int executionTimeMs;

  /// キューイング時間（ミリ秒）
  final int queuingTimeMs;

  /// 待機時間（ミリ秒）
  final int waitingTimeMs;

  /// 平均実行時間（ミリ秒）
  final int avgExecutionTimeMs;

  /// タイムスタンプ
  final DateTime timestamp;

  const ExecutionTimeAnalytics({
    required this.jobId,
    required this.jobType,
    required this.executionTimeMs,
    required this.queuingTimeMs,
    required this.waitingTimeMs,
    required this.avgExecutionTimeMs,
    required this.timestamp,
  });

  /// 総処理時間（ミリ秒）
  int get totalProcessTimeMs => executionTimeMs + queuingTimeMs + waitingTimeMs;

  /// 実行時間効率（パーセント）
  double get executionEfficiency => (executionTimeMs / totalProcessTimeMs) * 100;

  /// JSON に変換
  Map<String, dynamic> toJson() => {
        'jobId': jobId,
        'jobType': jobType.toString().split('.').last,
        'executionTimeMs': executionTimeMs,
        'queuingTimeMs': queuingTimeMs,
        'waitingTimeMs': waitingTimeMs,
        'avgExecutionTimeMs': avgExecutionTimeMs,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// ジョブ成功率統計
class SuccessRateStatistics {
  /// 総ジョブ数
  final int totalJobs;

  /// 成功ジョブ数
  final int successJobs;

  /// 失敗ジョブ数
  final int failedJobs;

  /// キャンセル済みジョブ数
  final int cancelledJobs;

  /// 平均実行時間（ミリ秒）
  final double avgExecutionTimeMs;

  /// 最大実行時間（ミリ秒）
  final int maxExecutionTimeMs;

  /// 最小実行時間（ミリ秒）
  final int minExecutionTimeMs;

  /// 集計期間
  final DateRange period;

  const SuccessRateStatistics({
    required this.totalJobs,
    required this.successJobs,
    required this.failedJobs,
    required this.cancelledJobs,
    required this.avgExecutionTimeMs,
    required this.maxExecutionTimeMs,
    required this.minExecutionTimeMs,
    required this.period,
  });

  /// 成功率（0.0 - 1.0）
  double get successRate => totalJobs > 0 ? successJobs / totalJobs : 0.0;

  /// 失敗率（0.0 - 1.0）
  double get failureRate => totalJobs > 0 ? failedJobs / totalJobs : 0.0;

  /// キャンセル率（0.0 - 1.0）
  double get cancellationRate => totalJobs > 0 ? cancelledJobs / totalJobs : 0.0;

  /// JSON に変換
  Map<String, dynamic> toJson() => {
        'totalJobs': totalJobs,
        'successJobs': successJobs,
        'failedJobs': failedJobs,
        'cancelledJobs': cancelledJobs,
        'successRate': successRate,
        'failureRate': failureRate,
        'avgExecutionTimeMs': avgExecutionTimeMs,
        'maxExecutionTimeMs': maxExecutionTimeMs,
        'minExecutionTimeMs': minExecutionTimeMs,
      };
}

/// パフォーマンスメトリクス
class PerformanceMetrics {
  /// 計測期間
  final DateRange period;

  /// CPU 使用率（0.0 - 100.0）
  final double cpuUsagePercent;

  /// メモリ使用量（MB）
  final double memoryUsageMb;

  /// ディスク使用量（MB）
  final double diskUsageMb;

  /// スループット（ジョブ/分）
  final double throughputJobsPerMinute;

  /// 平均遅延（ミリ秒）
  final double avgLatencyMs;

  /// P95 遅延（ミリ秒）
  final double p95LatencyMs;

  /// P99 遅延（ミリ秒）
  final double p99LatencyMs;

  /// エラー率（0.0 - 1.0）
  final double errorRate;

  /// タイムスタンプ
  final DateTime timestamp;

  const PerformanceMetrics({
    required this.period,
    required this.cpuUsagePercent,
    required this.memoryUsageMb,
    required this.diskUsageMb,
    required this.throughputJobsPerMinute,
    required this.avgLatencyMs,
    required this.p95LatencyMs,
    required this.p99LatencyMs,
    required this.errorRate,
    required this.timestamp,
  });

  /// JSON に変換
  Map<String, dynamic> toJson() => {
        'cpuUsagePercent': cpuUsagePercent,
        'memoryUsageMb': memoryUsageMb,
        'diskUsageMb': diskUsageMb,
        'throughputJobsPerMinute': throughputJobsPerMinute,
        'avgLatencyMs': avgLatencyMs,
        'p95LatencyMs': p95LatencyMs,
        'p99LatencyMs': p99LatencyMs,
        'errorRate': errorRate,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// ジョブタイプ別分析
class JobTypeAnalytics {
  /// ジョブタイプ
  final AsyncJobType jobType;

  /// 実行数
  final int executionCount;

  /// 成功数
  final int successCount;

  /// 失敗数
  final int failureCount;

  /// 平均実行時間（ミリ秒）
  final double avgExecutionTimeMs;

  /// 成功率（0.0 - 1.0）
  final double successRate;

  const JobTypeAnalytics({
    required this.jobType,
    required this.executionCount,
    required this.successCount,
    required this.failureCount,
    required this.avgExecutionTimeMs,
    required this.successRate,
  });

  /// JSON に変換
  Map<String, dynamic> toJson() => {
        'jobType': jobType.toString().split('.').last,
        'executionCount': executionCount,
        'successCount': successCount,
        'failureCount': failureCount,
        'avgExecutionTimeMs': avgExecutionTimeMs,
        'successRate': successRate,
      };
}

/// 日付範囲
class DateRange {
  /// 開始日時
  final DateTime startDate;

  /// 終了日時
  final DateTime endDate;

  const DateRange({
    required this.startDate,
    required this.endDate,
  });

  /// 日数
  int get days => endDate.difference(startDate).inDays;

  /// 時間数
  int get hours => endDate.difference(startDate).inHours;

  /// コピー
  DateRange copyWith({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DateRange(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

/// 分析レポート
class AnalyticsReport {
  /// レポート ID
  final String reportId;

  /// レポートタイプ
  final ReportType reportType;

  /// 成功率統計
  final SuccessRateStatistics successRateStats;

  /// パフォーマンスメトリクス
  final PerformanceMetrics? performanceMetrics;

  /// ジョブタイプ別分析リスト
  final List<JobTypeAnalytics> jobTypeAnalytics;

  /// 実行時間分析リスト
  final List<ExecutionTimeAnalytics> executionTimeAnalytics;

  /// 生成日時
  final DateTime generatedAt;

  /// レポート期間
  final DateRange period;

  const AnalyticsReport({
    required this.reportId,
    required this.reportType,
    required this.successRateStats,
    this.performanceMetrics,
    this.jobTypeAnalytics = const [],
    this.executionTimeAnalytics = const [],
    required this.generatedAt,
    required this.period,
  });

  /// JSON に変換
  Map<String, dynamic> toJson() => {
        'reportId': reportId,
        'reportType': reportType.toString().split('.').last,
        'successRateStats': successRateStats.toJson(),
        'performanceMetrics': performanceMetrics?.toJson(),
        'jobTypeAnalytics': jobTypeAnalytics.map((j) => j.toJson()).toList(),
        'executionTimeAnalytics': executionTimeAnalytics.map((e) => e.toJson()).toList(),
        'generatedAt': generatedAt.toIso8601String(),
      };
}

/// レポートタイプ
enum ReportType {
  /// 日次レポート
  daily,

  /// 週次レポート
  weekly,

  /// 月次レポート
  monthly,

  /// カスタムレポート
  custom,

  /// リアルタイムレポート
  realtime,
}

/// ボトルネック検出
class BottleneckDetection {
  /// ボトルネック ID
  final String bottleneckId;

  /// 種類
  final BottleneckType type;

  /// 重要度（1-10）
  final int severity;

  /// 説明
  final String description;

  /// 影響ジョブ数
  final int affectedJobCount;

  /// 検出時刻
  final DateTime detectedAt;

  /// 推奨アクション
  final String? recommendedAction;

  const BottleneckDetection({
    required this.bottleneckId,
    required this.type,
    required this.severity,
    required this.description,
    required this.affectedJobCount,
    required this.detectedAt,
    this.recommendedAction,
  });

  /// JSON に変換
  Map<String, dynamic> toJson() => {
        'bottleneckId': bottleneckId,
        'type': type.toString().split('.').last,
        'severity': severity,
        'description': description,
        'affectedJobCount': affectedJobCount,
        'detectedAt': detectedAt.toIso8601String(),
        'recommendedAction': recommendedAction,
      };
}

/// ボトルネック種類
enum BottleneckType {
  /// CPU 制約
  cpuConstraint,

  /// メモリ制約
  memoryConstraint,

  /// ディスク I/O
  diskIO,

  /// ネットワーク遅延
  networkLatency,

  /// キュー詰まり
  queueBacklog,

  /// エラー率上昇
  errorRateIncrease,
}
