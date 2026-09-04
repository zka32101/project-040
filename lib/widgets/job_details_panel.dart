/// Phase 22: ジョブ詳細パネルウィジェット
/// 選択されたジョブの詳細情報を表示

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import '../models/async_job_model.dart';
import '../providers/job_monitoring_provider.dart';

/// ジョブ詳細パネル
class JobDetailsPanel extends ConsumerWidget {
  /// スクロールコントローラ
  final ScrollController? scrollController;

  const JobDetailsPanel({
    Key? key,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(jobMonitoringProvider);
    final selectedJob = state.getSelectedJob();

    if (selectedJob == null) {
      return Center(
        child: Text(
          'ジョブが選択されていません',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            _buildHeader(context, selectedJob),

            // 基本情報
            _buildSection(
              context,
              'ジョブ情報',
              _buildJobInfo(context, selectedJob),
            ),

            // ステータス情報
            _buildSection(
              context,
              'ステータス',
              _buildStatusInfo(context, selectedJob),
            ),

            // 進捗情報
            if (selectedJob.status == AsyncJobStatus.processing ||
                selectedJob.status == AsyncJobStatus.queued)
              _buildSection(
                context,
                '進捗詳細',
                _buildProgressInfo(context, selectedJob),
              ),

            // エラー情報
            if (selectedJob.errorMessage != null)
              _buildSection(
                context,
                'エラー情報',
                _buildErrorInfo(context, selectedJob),
              ),

            // ジョブタイプ別情報
            _buildJobTypeSpecificInfo(context, selectedJob),

            // アクション
            _buildActions(context, ref, selectedJob),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// ヘッダーを構築
  Widget _buildHeader(BuildContext context, AsyncJob job) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _getJobTitle(job),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildStatusBadge(context, job.status),
        ],
      ),
    );
  }

  /// セクションを構築
  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  /// ジョブ基本情報を構築
  Widget _buildJobInfo(BuildContext context, AsyncJob job) {
    return Column(
      children: [
        _buildInfoRow(context, 'ジョブID', job.jobId),
        _buildInfoRow(context, 'ユーザーID', job.userId),
        _buildInfoRow(context, 'ジョブタイプ', _getJobType(job)),
        _buildInfoRow(
          context,
          '作成日時',
          _formatDateTime(job.createdAt),
        ),
      ],
    );
  }

  /// ステータス情報を構築
  Widget _buildStatusInfo(BuildContext context, AsyncJob job) {
    return Column(
      children: [
        _buildInfoRow(context, '現在のステータス', _getStatusLabel(job.status)),
        if (job.startedAt != null)
          _buildInfoRow(context, '開始日時', _formatDateTime(job.startedAt!)),
        if (job.completedAt != null)
          _buildInfoRow(context, '完了日時', _formatDateTime(job.completedAt!)),
        _buildInfoRow(
          context,
          'リトライ回数',
          '${job.retryCount} / ${AsyncJob.maxRetries}',
        ),
      ],
    );
  }

  /// 進捗情報を構築
  Widget _buildProgressInfo(BuildContext context, AsyncJob job) {
    final elapsedTime = DateTime.now().difference(job.createdAt);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: job.getProgress(),
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      job.progressPercent < 33
                          ? Colors.red
                          : job.progressPercent < 66
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${job.progressPercent}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        _buildInfoRow(context, '経過時間', _formatDuration(elapsedTime)),
      ],
    );
  }

  /// エラー情報を構築
  Widget _buildErrorInfo(BuildContext context, AsyncJob job) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'エラーメッセージ',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            job.errorMessage!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red[700],
                ),
          ),
        ],
      ),
    );
  }

  /// ジョブタイプ固有情報を構築
  Widget _buildJobTypeSpecificInfo(BuildContext context, AsyncJob job) {
    if (job is ReportGenerationJob) {
      return _buildSection(
        context,
        'レポート情報',
        Column(
          children: [
            _buildInfoRow(context, 'テンプレート', job.templateId),
            _buildInfoRow(context, 'フォーマット', job.format.toUpperCase()),
            _buildInfoRow(context, 'タイトル', job.title),
            _buildInfoRow(
              context,
              '対象期間',
              '${_formatDate(job.startDate)} 〜 ${_formatDate(job.endDate)}',
            ),
          ],
        ),
      );
    } else if (job is ExportDataJob) {
      return _buildSection(
        context,
        'エクスポート情報',
        Column(
          children: [
            _buildInfoRow(context, 'データタイプ', job.dataType),
            _buildInfoRow(context, 'フォーマット', job.format.toUpperCase()),
            _buildInfoRow(
              context,
              '対象期間',
              '${_formatDate(job.startDate)} 〜 ${_formatDate(job.endDate)}',
            ),
            _buildInfoRow(
              context,
              '個人情報を含める',
              job.includePersonalInfo ? 'はい' : 'いいえ',
            ),
            _buildInfoRow(
              context,
              '個人情報をマスク',
              job.maskPersonalData ? 'はい' : 'いいえ',
            ),
            if (job.encryptionType != null)
              _buildInfoRow(context, '暗号化タイプ', job.encryptionType!),
          ],
        ),
      );
    } else if (job is EmailDeliveryJob) {
      return _buildSection(
        context,
        'メール情報',
        Column(
          children: [
            _buildInfoRow(context, '件名', job.subject),
            _buildInfoRow(
              context,
              '受信者数',
              job.recipientEmails.length.toString(),
            ),
            if (job.sentCount > 0)
              _buildInfoRow(context, '送信済み', job.sentCount.toString()),
            if (job.failedCount > 0)
              _buildInfoRow(
                context,
                '送信失敗',
                job.failedCount.toString(),
                isError: true,
              ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// アクションボタンを構築
  Widget _buildActions(BuildContext context, WidgetRef ref, AsyncJob job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (job.status == AsyncJobStatus.processing ||
              job.status == AsyncJobStatus.queued)
            ElevatedButton.icon(
              icon: const Icon(Icons.cancel),
              label: const Text('キャンセル'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                ref.read(jobMonitoringProvider.notifier).cancelJob(job.jobId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ジョブをキャンセルしました')),
                );
              },
            ),
          if (job.canRetry())
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('リトライ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  job.retry();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ジョブをリトライしました')),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// 情報行を構築
  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isError = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isError ? Colors.red[700] : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// ステータスバッジを構築
  Widget _buildStatusBadge(BuildContext context, AsyncJobStatus status) {
    final (color, label) = _getStatusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  // ヘルパー関数

  String _getJobTitle(AsyncJob job) {
    if (job is ReportGenerationJob) {
      return job.title.isNotEmpty ? job.title : 'レポート生成';
    } else if (job is ExportDataJob) {
      return 'データエクスポート (${job.dataType})';
    } else if (job is EmailDeliveryJob) {
      return 'メール配信 (${job.recipientEmails.length} 件)';
    }
    return 'ジョブ #${job.jobId.substring(0, 8)}';
  }

  String _getJobType(AsyncJob job) {
    switch (job.jobType) {
      case AsyncJobType.reportGeneration:
        return 'レポート生成';
      case AsyncJobType.emailDelivery:
        return 'メール配信';
      case AsyncJobType.dataExport:
        return 'データエクスポート';
      case AsyncJobType.reportDeletion:
        return 'レポート削除';
    }
  }

  String _getStatusLabel(AsyncJobStatus status) {
    switch (status) {
      case AsyncJobStatus.queued:
        return 'キュー待機中';
      case AsyncJobStatus.processing:
        return '処理中';
      case AsyncJobStatus.completed:
        return '完了';
      case AsyncJobStatus.failed:
        return '失敗';
      case AsyncJobStatus.cancelled:
        return 'キャンセル';
    }
  }

  (Color, String) _getStatusColors(AsyncJobStatus status) {
    switch (status) {
      case AsyncJobStatus.queued:
        return (Colors.blue, 'キュー待機中');
      case AsyncJobStatus.processing:
        return (Colors.orange, '処理中');
      case AsyncJobStatus.completed:
        return (Colors.green, '完了');
      case AsyncJobStatus.failed:
        return (Colors.red, '失敗');
      case AsyncJobStatus.cancelled:
        return (Colors.grey, 'キャンセル');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}時間${duration.inMinutes.remainder(60)}分';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}分${duration.inSeconds.remainder(60)}秒';
    } else {
      return '${duration.inSeconds}秒';
    }
  }
}
