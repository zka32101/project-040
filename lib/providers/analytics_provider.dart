/// Phase 26: 分析プロバイダー
/// Riverpod を使用した分析機能の状態管理

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../models/async_job_model.dart';

/// 分析サービスプロバイダー
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// 実行時間分析リストプロバイダー
final executionTimeAnalyticsProvider =
    StateNotifierProvider<ExecutionTimeAnalyticsNotifier, List<ExecutionTimeAnalytics>>(
  (ref) => ExecutionTimeAnalyticsNotifier(ref.watch(analyticsServiceProvider)),
);

/// 成功率統計プロバイダー
final successRateStatisticsProvider =
    FutureProvider<SuccessRateStatistics?>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getSuccessRateStatistics(
    DateRange(
      startDate: DateTime.now().subtract(Duration(days: 7)),
      endDate: DateTime.now(),
    ),
  );
});

/// パフォーマンスメトリクスプロバイダー
final performanceMetricsProvider = FutureProvider<PerformanceMetrics?>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getPerformanceMetrics(
    DateRange(
      startDate: DateTime.now().subtract(Duration(hours: 1)),
      endDate: DateTime.now(),
    ),
  );
});

/// ジョブタイプ別分析リストプロバイダー
final jobTypeAnalyticsProvider =
    FutureProvider<List<JobTypeAnalytics>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.getJobTypeAnalytics();
});

/// ボトルネック検出リストプロバイダー
final bottleneckDetectionProvider =
    FutureProvider<List<BottleneckDetection>>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  return service.detectBottlenecks();
});

/// 分析レポートプロバイダー
final analyticsReportProvider = FutureProvider<AnalyticsReport?>((ref) async {
  final service = ref.watch(analyticsServiceProvider);
  final stats = await ref.watch(successRateStatisticsProvider.future);

  if (stats == null) return null;

  return AnalyticsReport(
    reportId: 'report_${DateTime.now().millisecondsSinceEpoch}',
    reportType: ReportType.daily,
    successRateStats: stats,
    performanceMetrics: await ref.watch(performanceMetricsProvider.future),
    jobTypeAnalytics: await ref.watch(jobTypeAnalyticsProvider.future),
    generatedAt: DateTime.now(),
    period: DateRange(
      startDate: DateTime.now().subtract(Duration(days: 1)),
      endDate: DateTime.now(),
    ),
  );
});

/// 実行時間分析状態管理クラス
class ExecutionTimeAnalyticsNotifier extends StateNotifier<List<ExecutionTimeAnalytics>> {
  final AnalyticsService _service;

  ExecutionTimeAnalyticsNotifier(this._service) : super([]);

  /// 分析を追加
  void addAnalytics(ExecutionTimeAnalytics analytics) {
    state = [...state, analytics];
  }

  /// ジョブの分析を作成
  void analyzeJob(AsyncJob job) {
    final analytics = ExecutionTimeAnalytics(
      jobId: job.jobId,
      jobType: job.jobType,
      executionTimeMs: 0,
      queuingTimeMs: 0,
      waitingTimeMs: 0,
      avgExecutionTimeMs: 0,
      timestamp: DateTime.now(),
    );
    addAnalytics(analytics);
  }

  /// 全分析をクリア
  void clearAll() {
    state = [];
  }
}

/// 分析サービス
class AnalyticsService {
  /// 成功率統計を取得
  Future<SuccessRateStatistics?> getSuccessRateStatistics(DateRange period) async {
    // 実装は簡略化（将来 API から取得）
    return SuccessRateStatistics(
      totalJobs: 100,
      successJobs: 85,
      failedJobs: 10,
      cancelledJobs: 5,
      avgExecutionTimeMs: 3500.0,
      maxExecutionTimeMs: 10000,
      minExecutionTimeMs: 500,
      period: period,
    );
  }

  /// パフォーマンスメトリクスを取得
  Future<PerformanceMetrics?> getPerformanceMetrics(DateRange period) async {
    // 実装は簡略化（将来 API から取得）
    return PerformanceMetrics(
      period: period,
      cpuUsagePercent: 45.5,
      memoryUsageMb: 512.0,
      diskUsageMb: 1024.0,
      throughputJobsPerMinute: 10.5,
      avgLatencyMs: 150.0,
      p95LatencyMs: 450.0,
      p99LatencyMs: 850.0,
      errorRate: 0.02,
      timestamp: DateTime.now(),
    );
  }

  /// ジョブタイプ別分析を取得
  Future<List<JobTypeAnalytics>> getJobTypeAnalytics() async {
    // 実装は簡略化（将来 API から取得）
    return [
      JobTypeAnalytics(
        jobType: AsyncJobType.reportGeneration,
        executionCount: 50,
        successCount: 45,
        failureCount: 5,
        avgExecutionTimeMs: 4000.0,
        successRate: 0.9,
      ),
      JobTypeAnalytics(
        jobType: AsyncJobType.dataProcessing,
        executionCount: 30,
        successCount: 28,
        failureCount: 2,
        avgExecutionTimeMs: 2500.0,
        successRate: 0.93,
      ),
    ];
  }

  /// ボトルネックを検出
  Future<List<BottleneckDetection>> detectBottlenecks() async {
    // 実装は簡略化（将来 API から取得）
    return [];
  }
}
