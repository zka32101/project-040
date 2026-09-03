/// Phase 26: 分析ダッシュボード
/// Riverpod + flutter_riverpod を使用した分析画面

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../providers/analytics_provider.dart';

/// 分析ダッシュボード
class AnalyticsDashboard extends ConsumerWidget {
  const AnalyticsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final successRateStats = ref.watch(successRateStatisticsProvider);
    final performanceMetrics = ref.watch(performanceMetricsProvider);
    final jobTypeAnalytics = ref.watch(jobTypeAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('分析ダッシュボード'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 成功率統計セクション
            _buildSuccessRateSection(context, successRateStats),
            const SizedBox(height: 24),

            // パフォーマンスメトリクスセクション
            _buildPerformanceMetricsSection(context, performanceMetrics),
            const SizedBox(height: 24),

            // ジョブタイプ別分析セクション
            _buildJobTypeAnalyticsSection(context, jobTypeAnalytics),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessRateSection(
    BuildContext context,
    AsyncValue<SuccessRateStatistics?> asyncStats,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '成功率統計',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            asyncStats.when(
              data: (stats) {
                if (stats == null) {
                  return const Text('データなし');
                }
                return Column(
                  children: [
                    _buildStatRow(
                      label: '成功率',
                      value: '${(stats.successRate * 100).toStringAsFixed(1)}%',
                      color: Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      label: '失敗率',
                      value: '${(stats.failureRate * 100).toStringAsFixed(1)}%',
                      color: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      label: 'キャンセル率',
                      value: '${(stats.cancellationRate * 100).toStringAsFixed(1)}%',
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    _buildMetricsInfo(
                      'ジョブ統計',
                      [
                        'テスト数: ${stats.totalJobs}',
                        '成功: ${stats.successJobs}',
                        '失敗: ${stats.failedJobs}',
                        'キャンセル: ${stats.cancelledJobs}',
                      ],
                    ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('エラー: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetricsSection(
    BuildContext context,
    AsyncValue<PerformanceMetrics?> asyncMetrics,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'パフォーマンスメトリクス',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            asyncMetrics.when(
              data: (metrics) {
                if (metrics == null) {
                  return const Text('データなし');
                }
                return Column(
                  children: [
                    _buildMetricsInfo(
                      'リソース使用率',
                      [
                        'CPU: ${metrics.cpuUsagePercent.toStringAsFixed(1)}%',
                        'メモリ: ${metrics.memoryUsageMb.toStringAsFixed(0)} MB',
                        'ディスク: ${metrics.diskUsageMb.toStringAsFixed(0)} MB',
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildMetricsInfo(
                      'パフォーマンス指標',
                      [
                        '平均遅延: ${metrics.avgLatencyMs.toStringAsFixed(1)} ms',
                        'P95 遅延: ${metrics.p95LatencyMs.toStringAsFixed(1)} ms',
                        'P99 遅延: ${metrics.p99LatencyMs.toStringAsFixed(1)} ms',
                        'エラー率: ${(metrics.errorRate * 100).toStringAsFixed(2)}%',
                      ],
                    ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('エラー: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobTypeAnalyticsSection(
    BuildContext context,
    AsyncValue<List<JobTypeAnalytics>> asyncAnalytics,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ジョブタイプ別分析',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            asyncAnalytics.when(
              data: (analytics) {
                if (analytics.isEmpty) {
                  return const Text('データなし');
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: analytics.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final item = analytics[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.jobType.toString().split('.').last,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        _buildStatRow(
                          label: '成功率',
                          value: '${(item.successRate * 100).toStringAsFixed(1)}%',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '実行数: ${item.executionCount} '
                          '(成功: ${item.successCount}, 失敗: ${item.failureCount})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('エラー: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsInfo(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            '• $item',
            style: const TextStyle(fontSize: 13),
          ),
        )),
      ],
    );
  }
}
