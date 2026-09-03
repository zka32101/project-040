/// Phase 26: エクスポート進捗ウィジェット
/// エクスポート進捗の表示と管理

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_export_model.dart';
import '../models/async_job_model.dart';
import '../providers/export_provider.dart';

/// エクスポート進捗ウィジェット
class ExportProgressWidget extends ConsumerWidget {
  final ExportResult export;

  const ExportProgressWidget({
    Key? key,
    required this.export,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        export.fileName,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${export.jobCount} ジョブ',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(export.status),
              ],
            ),
            const SizedBox(height: 12),
            _buildProgressBar(export),
            const SizedBox(height: 8),
            Text(
              '${(export.fileSizeBytes / 1024).toStringAsFixed(1)} KB',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (export.status == ExportStatus.completed ||
                export.status == ExportStatus.cancelled)
              const SizedBox(height: 16),
            if (export.status == ExportStatus.completed ||
                export.status == ExportStatus.cancelled)
              _buildActionButtons(context, ref, export),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ExportStatus status) {
    late Color backgroundColor;
    late Color textColor;
    late String label;

    switch (status) {
      case ExportStatus.pending:
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        label = '待機中';
        break;
      case ExportStatus.processing:
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        label = '処理中';
        break;
      case ExportStatus.completed:
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        label = '完了';
        break;
      case ExportStatus.failed:
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
        label = '失敗';
        break;
      case ExportStatus.cancelled:
        backgroundColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
        label = 'キャンセル';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildProgressBar(ExportResult export) {
    double progress = 0.0;
    switch (export.status) {
      case ExportStatus.pending:
        progress = 0.25;
        break;
      case ExportStatus.processing:
        progress = 0.75;
        break;
      case ExportStatus.completed:
        progress = 1.0;
        break;
      case ExportStatus.failed:
      case ExportStatus.cancelled:
        progress = 0.0;
        break;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(
          export.status == ExportStatus.failed ? Colors.red : Colors.green,
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    ExportResult export,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (export.status == ExportStatus.completed)
          ElevatedButton.icon(
            onPressed: () async {
              final ops = ExportOperations(ref);
              final data = await ops.downloadExport(export.exportId);
              if (data != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${export.fileName} をダウンロード')),
                );
              }
            },
            icon: const Icon(Icons.download),
            label: const Text('ダウンロード'),
          )
        else if (export.status != ExportStatus.cancelled)
          ElevatedButton.icon(
            onPressed: () async {
              final ops = ExportOperations(ref);
              await ops.cancelExport(export.exportId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('エクスポートをキャンセルしました')),
                );
              }
            },
            icon: const Icon(Icons.cancel),
            label: const Text('キャンセル'),
          ),
      ],
    );
  }
}

/// エクスポートダイアログ
class ExportDialog extends ConsumerStatefulWidget {
  final List<AsyncJob> jobs;

  const ExportDialog({
    Key? key,
    required this.jobs,
  }) : super(key: key);

  @override
  ConsumerState<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<ExportDialog> {
  late ExportFormat _selectedFormat;
  late bool _includeHeaders;
  late bool _compressed;

  @override
  void initState() {
    super.initState();
    _selectedFormat = ExportFormat.csv;
    _includeHeaders = true;
    _compressed = false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('エクスポート設定'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('フォーマットを選択'),
          const SizedBox(height: 8),
          DropdownButton<ExportFormat>(
            value: _selectedFormat,
            isExpanded: true,
            onChanged: (format) {
              setState(() => _selectedFormat = format ?? ExportFormat.csv);
            },
            items: ExportFormat.values.map((format) {
              return DropdownMenuItem(
                value: format,
                child: Text(format.toString().split('.').last.toUpperCase()),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('ヘッダー行を含める'),
            value: _includeHeaders,
            onChanged: (value) {
              setState(() => _includeHeaders = value ?? true);
            },
          ),
          CheckboxListTile(
            title: const Text('圧縮'),
            value: _compressed,
            onChanged: (value) {
              setState(() => _compressed = value ?? false);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: () async {
            final config = ExportConfig(
              format: _selectedFormat,
              includeHeaders: _includeHeaders,
              compressed: _compressed,
            );

            final ops = ExportOperations(ref);
            await ops.executeExport(widget.jobs, config);

            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('エクスポートを開始しました')),
              );
            }
          },
          child: const Text('エクスポート'),
        ),
      ],
    );
  }
}

/// アクティブなエクスポート一覧
class ActiveExportsList extends ConsumerWidget {
  const ActiveExportsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exports = ref.watch(activeExportsProvider);

    if (exports.isEmpty) {
      return Center(
        child: Text(
          'エクスポートはありません',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return ListView.separated(
      itemCount: exports.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return ExportProgressWidget(export: exports[index]);
      },
    );
  }
}
