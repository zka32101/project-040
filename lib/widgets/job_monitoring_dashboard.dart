/// Phase 22: ジョブ監視ダッシュボードウィジェット
/// すべてのバックグラウンドジョブを一括管理・監視

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import '../models/async_job_model.dart';
import '../models/job_monitoring_model.dart';
import '../providers/job_monitoring_provider.dart';
import 'job_progress_card.dart';
import 'job_details_panel.dart';

/// ジョブ監視ダッシュボード
class JobMonitoringDashboard extends ConsumerStatefulWidget {
  /// ページタイトル
  final String title;

  /// ページを閉じるコールバック
  final VoidCallback? onClose;

  const JobMonitoringDashboard({
    Key? key,
    this.title = 'ジョブ監視',
    this.onClose,
  }) : super(key: key);

  @override
  ConsumerState<JobMonitoringDashboard> createState() => _JobMonitoringDashboardState();
}

class _JobMonitoringDashboardState extends ConsumerState<JobMonitoringDashboard> {
  @override
  void initState() {
    super.initState();
    // 初期ロード
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobMonitoringProvider.notifier).refreshJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobMonitoringProvider);
    final stats = ref.watch(jobStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(jobMonitoringProvider.notifier).refreshJobs();
            },
            tooltip: '更新',
          ),
          if (widget.onClose != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onClose,
              tooltip: '閉じる',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(jobMonitoringProvider.notifier).refreshJobs();
        },
        child: state.isLoading && state.totalJobCount == 0
            ? const _LoadingView()
            : state.errorMessage != null && state.totalJobCount == 0
                ? _ErrorView(errorMessage: state.errorMessage!)
                : Column(
                    children: [
                      // 統計情報ヘッダー
                      _buildStatisticsHeader(context, stats),

                      // フィルタタブ
                      _buildFilterTabs(context, state),

                      // ジョブリスト
                      Expanded(
                        child: _buildJobsList(context, state),
                      ),
                    ],
                  ),
      ),
    );
  }

  /// 統計情報ヘッダーを構築
  Widget _buildStatisticsHeader(BuildContext context, JobStatistics stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ジョブ統計',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatisticCard(
                context,
                '総数',
                stats.totalJobs.toString(),
                Colors.blue,
              ),
              _buildStatisticCard(
                context,
                'アクティブ',
                stats.activeJobs.toString(),
                Colors.orange,
              ),
              _buildStatisticCard(
                context,
                '完了',
                stats.completedJobs.toString(),
                Colors.green,
              ),
              _buildStatisticCard(
                context,
                '失敗',
                stats.failedJobs.toString(),
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stats.averageProgress,
              minHeight: 6,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                stats.averageProgress > 0.66
                    ? Colors.green
                    : stats.averageProgress > 0.33
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '平均進捗: ${(stats.averageProgress * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  /// 統計カードを構築
  Widget _buildStatisticCard(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  /// フィルタタブを構築
  Widget _buildFilterTabs(BuildContext context, JobMonitoringState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: JobFilterMode.values.map((mode) {
            final isSelected = state.filterMode == mode;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(_getFilterLabel(mode)),
                selected: isSelected,
                onSelected: (selected) {
                  ref.read(jobMonitoringProvider.notifier).setFilterMode(mode);
                },
                backgroundColor: Colors.grey[200],
                selectedColor: Colors.blue[200],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.blue[900] : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// フィルタラベルを取得
  String _getFilterLabel(JobFilterMode mode) {
    switch (mode) {
      case JobFilterMode.all:
        return 'すべて';
      case JobFilterMode.active:
        return 'アクティブ';
      case JobFilterMode.completed:
        return '完了';
      case JobFilterMode.failed:
        return '失敗';
    }
  }

  /// ジョブリストを構築
  Widget _buildJobsList(BuildContext context, JobMonitoringState state) {
    final filteredJobs = ref.watch(filteredJobsProvider);

    if (filteredJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'ジョブがありません',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: filteredJobs.length,
      itemBuilder: (context, index) {
        final job = filteredJobs[index];
        return JobProgressCard(
          job: job,
          onTap: () {
            ref.read(jobMonitoringProvider.notifier).selectJob(job.jobId);
          },
          onCancel: job.status == AsyncJobStatus.processing || job.status == AsyncJobStatus.queued
              ? () {
                  _showCancelConfirmation(context, job);
                }
              : null,
          onShowDetails: () {
            ref.read(jobMonitoringProvider.notifier).selectJob(job.jobId);
            _showJobDetailsModal(context);
          },
        );
      },
    );
  }

  /// キャンセル確認ダイアログを表示
  void _showCancelConfirmation(BuildContext context, AsyncJob job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ジョブをキャンセルしますか?'),
        content: Text('ジョブ「${_getJobTitle(job)}」をキャンセルします。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('いいえ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(jobMonitoringProvider.notifier).cancelJob(job.jobId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ジョブをキャンセルしました')),
              );
            },
            child: const Text('はい'),
          ),
        ],
      ),
    );
  }

  /// ジョブ詳細モーダルを表示
  void _showJobDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => JobDetailsPanel(
          scrollController: scrollController,
        ),
      ),
    );
  }

  /// ジョブのタイトルを取得
  String _getJobTitle(AsyncJob job) {
    if (job is ReportGenerationJob) {
      return job.title.isNotEmpty ? job.title : 'レポート生成';
    } else if (job is ExportDataJob) {
      return 'データエクスポート';
    } else if (job is EmailDeliveryJob) {
      return 'メール配信';
    }
    return 'ジョブ';
  }
}

/// ローディング表示
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'ジョブを読み込み中...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

/// エラー表示
class _ErrorView extends StatelessWidget {
  final String errorMessage;

  const _ErrorView({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'エラーが発生しました',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.red[400],
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
