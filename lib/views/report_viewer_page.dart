import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/report_model.dart';

/// レポートビューアページ
/// 生成されたレポートを表示・ダウンロード・共有
class ReportViewerPage extends ConsumerStatefulWidget {
  final GeneratedReport report;

  const ReportViewerPage({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  ConsumerState<ReportViewerPage> createState() => _ReportViewerPageState();
}

class _ReportViewerPageState extends ConsumerState<ReportViewerPage> {
  late bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report.title),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadReport,
            tooltip: 'ダウンロード',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReport,
            tooltip: '共有',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'print',
                child: Text('印刷'),
              ),
              const PopupMenuItem(
                value: 'email',
                child: Text('メール送信'),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // レポートメタデータ
                  _buildReportMetadata(),

                  const SizedBox(height: 24),

                  // レポート内容（プレビュー）
                  _buildReportPreview(),

                  const SizedBox(height: 24),

                  // レポート詳細情報
                  _buildReportDetails(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildReportMetadata() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.report.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              widget.report.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ステータス',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        widget.report.status ?? 'unknown',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: _getStatusColor(widget.report.status),
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'フォーマット',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        widget.report.format.toUpperCase(),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ページ数',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${widget.report.pageCount ?? 'N/A'} pages',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'レポートプレビュー',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'レポート ${widget.report.reportType}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '期間: ${_formatDate(widget.report.startDate)} ～ ${_formatDate(widget.report.endDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '[実際のレポート内容がここに表示されます]\n\n'
                    '詳細なデータ分析、グラフ、統計情報が含まれます。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'レポート詳細',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                title: const Text('生成者'),
                subtitle: Text(widget.report.generatedBy),
              ),
              const Divider(),
              ListTile(
                title: const Text('生成日時'),
                subtitle: Text(_formatDateTime(widget.report.generatedAt)),
              ),
              const Divider(),
              ListTile(
                title: const Text('ファイルサイズ'),
                subtitle: Text(
                  '${(widget.report.fileSizeBytes / 1024).toStringAsFixed(2)} KB',
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('レコード数'),
                subtitle: Text('${widget.report.recordCount ?? 'N/A'} items'),
              ),
              if (widget.report.expiresAt != null)
                Column(
                  children: [
                    const Divider(),
                    ListTile(
                      title: const Text('有効期限'),
                      subtitle: Text(
                        _formatDateTime(widget.report.expiresAt!),
                      ),
                    ),
                  ],
                ),
              if (widget.report.downloadCount != null)
                Column(
                  children: [
                    const Divider(),
                    ListTile(
                      title: const Text('ダウンロード回数'),
                      subtitle: Text('${widget.report.downloadCount} times'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'ready':
        return Colors.green;
      case 'generating':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _downloadReport() {
    setState(() {
      isLoading = true;
    });

    // Simulate download
    Future.delayed(const Duration(seconds: 2)).then((_) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ダウンロードしました: ${widget.report.title}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _shareReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('レポートを共有: ${widget.report.title}'),
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'print':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('印刷機能は準備中です')),
        );
        break;
      case 'email':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('メール送信機能は準備中です')),
        );
        break;
    }
  }
}
