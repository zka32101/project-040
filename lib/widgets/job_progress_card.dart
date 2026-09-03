/// Phase 22: ジョブ進捗カードウィジェット
/// 個別ジョブの進捗状況を表示するカード

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import '../models/async_job_model.dart';

/// ジョブの進捗情報を表示するカード
class JobProgressCard extends ConsumerWidget {
  /// 表示するジョブ
  final AsyncJob job;

  /// ジョブ選択時のコールバック
  final VoidCallback? onTap;

  /// ジョブキャンセル時のコールバック
  final VoidCallback? onCancel;

  /// 詳細情報表示時のコールバック
  final VoidCallback? onShowDetails;

  const JobProgressCard({
    Key? key,
    required this.job,
    this.onTap,
    this.onCancel,
    this.onShowDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProcessing = job.status == AsyncJobStatus.processing || job.status == AsyncJobStatus.queued;
    final isCompleted = job.status == AsyncJobStatus.completed;
    final isFailed = job.status == AsyncJobStatus.failed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ジョブタイトル・ステータス行
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getJobTitle(job),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getJobDescription(job),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context, job.status),
                ],
              ),
              const SizedBox(height: 12),

              // 進捗バーと進捗率
              if (isProcessing) ...[
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: job.getProgress(),
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(job.progressPercent),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${job.progressPercent}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // 詳細情報行
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn(
                    context,
                    '作成日時',
                    _formatDateTime(job.createdAt),
                  ),
                  if (job.startedAt != null)
                    _buildInfoColumn(
                      context,
                      '開始日時',
                      _formatDateTime(job.startedAt!),
                    ),
                  if (job.completedAt != null && (isCompleted || isFailed))
                    _buildInfoColumn(
                      context,
                      '完了日時',
                      _formatDateTime(job.completedAt!),
                    ),
                ],
              ),

              // エラーメッセージ表示
              if (job.errorMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    job.errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red[700],
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              // アクションボタン
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onShowDetails != null)
                    TextButton(
                      onPressed: onShowDetails,
                      child: const Text('詳細'),
                    ),
                  if (isProcessing && onCancel != null)
                    TextButton(
                      onPressed: onCancel,
                      child: const Text('キャンセル'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ジョブのタイトルを取得
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

  /// ジョブの説明を取得
  String _getJobDescription(AsyncJob job) {
    if (job is ReportGenerationJob) {
      return '${job.startDate.year}年${job.startDate.month}月〜${job.endDate.year}年${job.endDate.month}月';
    } else if (job is ExportDataJob) {
      final flags = <String>[];
      if (job.maskPersonalData) flags.add('PII マスク');
      if (job.encryptionType != null) flags.add('暗号化');
      return flags.isNotEmpty ? flags.join(', ') : 'エクスポート中';
    } else if (job is EmailDeliveryJob) {
      return job.subject;
    }
    return '処理中';
  }

  /// ステータスバッジを構築
  Widget _buildStatusBadge(BuildContext context, AsyncJobStatus status) {
    final (color, label) = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  /// ステータスに基づいた色とラベルを取得
  (Color, String) _getStatusColor(AsyncJobStatus status) {
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

  /// 進捗率に基づいた色を取得
  Color _getProgressColor(int progress) {
    if (progress < 33) return Colors.red;
    if (progress < 66) return Colors.orange;
    return Colors.green;
  }

  /// 日時をフォーマット
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'たった今';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else {
      return '${dateTime.month}月${dateTime.day}日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  /// 情報カラムを構築
  Widget _buildInfoColumn(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
