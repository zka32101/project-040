import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/report_model.dart';
import '../viewmodels/providers.dart';

/// レポート生成ビュー
/// テンプレートベースのレポートを生成・ダウンロード
class ReportGeneratorView extends ConsumerStatefulWidget {
  const ReportGeneratorView({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportGeneratorView> createState() =>
      _ReportGeneratorViewState();
}

class _ReportGeneratorViewState extends ConsumerState<ReportGeneratorView> {
  late String selectedTemplate = 'student_progress';
  late String selectedFormat = 'pdf';
  late DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  late DateTime endDate = DateTime.now();
  late String title = '';
  late String generatedBy = 'teacher_001'; // TODO: Get from auth service

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レポート生成'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // テンプレート選択
            const SizedBox(height: 16),
            _buildSectionTitle('テンプレート選択'),
            const SizedBox(height: 12),
            _buildTemplateSelector(),

            // フォーマット選択
            const SizedBox(height: 24),
            _buildSectionTitle('出力形式'),
            const SizedBox(height: 12),
            _buildFormatSelector(),

            // 期間選択
            const SizedBox(height: 24),
            _buildSectionTitle('期間設定'),
            const SizedBox(height: 12),
            _buildDateRangeSelector(),

            // レポートタイトル
            const SizedBox(height: 24),
            _buildSectionTitle('レポートタイトル'),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) {
                setState(() {
                  title = value;
                });
              },
              decoration: InputDecoration(
                hintText: '例：7月度 学生進捗レポート',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // 生成ボタン
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: title.isEmpty ? null : _generateReport,
                child: const Text('レポート生成'),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _buildTemplateSelector() {
    final templates = [
      ('student_progress', '学生進捗レポート'),
      ('class_performance', 'クラス成績レポート'),
      ('cohort_analysis', 'コホート分析レポート'),
    ];

    return Column(
      children: templates
          .map((e) => RadioListTile(
                title: Text(e.$2),
                value: e.$1,
                groupValue: selectedTemplate,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedTemplate = value;
                    });
                  }
                },
              ))
          .toList(),
    );
  }

  Widget _buildFormatSelector() {
    final formats = [
      ('pdf', 'PDF'),
      ('csv', 'CSV'),
      ('excel', 'Excel'),
      ('json', 'JSON'),
    ];

    return Column(
      children: formats
          .map((e) => RadioListTile(
                title: Text(e.$2),
                value: e.$1,
                groupValue: selectedFormat,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedFormat = value;
                    });
                  }
                },
              ))
          .toList(),
    );
  }

  Widget _buildDateRangeSelector() {
    return Column(
      children: [
        ListTile(
          title: const Text('開始日'),
          subtitle: Text('${startDate.year}-${startDate.month}-${startDate.day}'),
          onTap: _selectStartDate,
        ),
        const Divider(),
        ListTile(
          title: const Text('終了日'),
          subtitle: Text('${endDate.year}-${endDate.month}-${endDate.day}'),
          onTap: _selectEndDate,
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2020),
      lastDate: endDate,
    );
    if (selected != null) {
      setState(() {
        startDate = selected;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: startDate,
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        endDate = selected;
      });
    }
  }

  void _generateReport() {
    final params = ReportGenerationParams(
      templateId: selectedTemplate,
      reportType: selectedTemplate,
      format: selectedFormat,
      startDate: startDate,
      endDate: endDate,
      title: title,
      generatedBy: generatedBy,
      dataSource: {}, // TODO: Get actual student data
    );

    // レポート生成開始
    ref
        .read(reportGenerationProvider(params).future)
        .then((report) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('レポートを生成しました: ${report.title}'),
              backgroundColor: Colors.green,
            ),
          );
          // TODO: Navigate to report viewer or download
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エラーが発生しました: $error'),
              backgroundColor: Colors.red,
            ),
          );
        });
  }
}
