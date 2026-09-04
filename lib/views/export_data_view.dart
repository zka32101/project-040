import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/report_model.dart';
import '../viewmodels/providers.dart';

/// データエクスポートビュー
/// 学生データ・成績・学習履歴をCSV/Excel/JSON形式で出力
class ExportDataView extends ConsumerStatefulWidget {
  const ExportDataView({Key? key}) : super(key: key);

  @override
  ConsumerState<ExportDataView> createState() => _ExportDataViewState();
}

class _ExportDataViewState extends ConsumerState<ExportDataView> {
  late String selectedDataType = 'student_data';
  late String selectedFormat = 'csv';
  late DateTime startDate = DateTime.now().subtract(const Duration(days: 90));
  late DateTime endDate = DateTime.now();
  late bool includePersonalInfo = true;
  late bool maskPersonalData = false;
  late String encryptionType = 'none';
  late List<String> includedFields = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('データエクスポート'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // エクスポートデータタイプ
            const SizedBox(height: 16),
            _buildSectionTitle('エクスポートデータ'),
            const SizedBox(height: 12),
            _buildDataTypeSelector(),

            // フォーマット選択
            const SizedBox(height: 24),
            _buildSectionTitle('出力形式'),
            const SizedBox(height: 12),
            _buildFormatSelector(),

            // 期間設定
            const SizedBox(height: 24),
            _buildSectionTitle('期間設定'),
            const SizedBox(height: 12),
            _buildDateRangeSelector(),

            // プライバシー設定
            const SizedBox(height: 24),
            _buildSectionTitle('プライバシー設定'),
            const SizedBox(height: 12),
            _buildPrivacySettings(),

            // 暗号化設定
            const SizedBox(height: 24),
            _buildSectionTitle('暗号化'),
            const SizedBox(height: 12),
            _buildEncryptionSelector(),

            // エクスポートボタン
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _exportData,
                child: const Text('データをエクスポート'),
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

  Widget _buildDataTypeSelector() {
    final dataTypes = [
      ('student_data', '学生データ'),
      ('answers', '回答ログ'),
      ('analytics', '分析データ'),
      ('progress', '進捗データ'),
    ];

    return Column(
      children: dataTypes
          .map((e) => RadioListTile(
                title: Text(e.$2),
                value: e.$1,
                groupValue: selectedDataType,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedDataType = value;
                    });
                  }
                },
              ))
          .toList(),
    );
  }

  Widget _buildFormatSelector() {
    final formats = [
      ('csv', 'CSV'),
      ('excel', 'Excel'),
      ('json', 'JSON'),
      ('xml', 'XML'),
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

  Widget _buildPrivacySettings() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('個人情報を含める'),
          subtitle: const Text('メール、電話、住所などの個人情報を含めます'),
          value: includePersonalInfo,
          onChanged: (value) {
            setState(() {
              includePersonalInfo = value ?? false;
              if (!includePersonalInfo) {
                maskPersonalData = false;
              }
            });
          },
        ),
        if (includePersonalInfo)
          CheckboxListTile(
            title: const Text('個人情報をマスク'),
            subtitle: const Text('メールアドレスなどを部分的に隠します'),
            value: maskPersonalData,
            onChanged: (value) {
              setState(() {
                maskPersonalData = value ?? false;
              });
            },
          ),
      ],
    );
  }

  Widget _buildEncryptionSelector() {
    final encryptionTypes = [
      ('none', 'なし'),
      ('aes256', 'AES-256'),
      ('pgp', 'PGP'),
    ];

    return Column(
      children: encryptionTypes
          .map((e) => RadioListTile(
                title: Text(e.$2),
                value: e.$1,
                groupValue: encryptionType,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      encryptionType = value;
                    });
                  }
                },
              ))
          .toList(),
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

  void _exportData() {
    final params = ExportDataParams(
      exportId: 'export_${DateTime.now().millisecondsSinceEpoch}',
      dataType: selectedDataType,
      format: selectedFormat,
      startDate: startDate,
      endDate: endDate,
      maskPersonalData: maskPersonalData,
      includePersonalInfo: includePersonalInfo,
      encryptionType: encryptionType == 'none' ? null : encryptionType,
      dataRecords: [], // TODO: Get actual data based on selectedDataType
    );

    // データエクスポート開始
    ref
        .read(exportDataProvider(params).future)
        .then((result) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'データをエクスポートしました（${result.recordCount}件）',
              ),
              backgroundColor: Colors.green,
            ),
          );
          // TODO: Download or share the exported file
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
