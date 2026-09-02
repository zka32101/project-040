import 'package:flutter/foundation.dart';
import '../models/report_model.dart';

/// データエクスポートサービス
/// 学生データ・成績・学習履歴をCSV/Excel/JSON形式で出力
class ExportService {
  final Map<String, ExportResult> _exportCache = {};

  /// データをエクスポート
  Future<ExportResult> exportData({
    required String exportId,
    required ExportConfig config,
    required List<Map<String, dynamic>> dataRecords,
  }) async {
    try {
      // 1. プライバシー設定を適用
      final processedData = _applyPrivacySettings(
        records: dataRecords,
        maskPersonalData: config.maskPersonalData ?? false,
        includePersonalInfo: config.includePersonalInfo ?? false,
      );

      // 2. フィルタリング
      final filteredData = _filterRecords(
        records: processedData,
        includedFields: config.includedFields,
      );

      // 3. フォーマット変換
      final formattedContent = _formatData(
        records: filteredData,
        format: config.format,
      );

      // 4. 暗号化（必要に場合）
      final finalContent = config.encryptionType != null &&
              config.encryptionType != 'none'
          ? _encryptContent(formattedContent, config.encryptionType!)
          : formattedContent;

      final result = ExportResult(
        id: exportId,
        exportType: config.dataType,
        format: config.format,
        downloadUrl: '/exports/$exportId/download',
        recordCount: filteredData.length,
        fileSizeBytes: finalContent.length.toDouble(),
        createdAt: DateTime.now(),
        status: 'ready',
        isEncrypted: config.encryptionType != null,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        downloadCount: 0,
      );

      _exportCache[exportId] = result;
      return result;
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'ExportService.exportData');
      rethrow;
    }
  }

  /// スケジュール配信エクスポート
  Future<void> scheduleExport({
    required String templateId,
    required String frequency,
    required String time,
    required List<String> recipientEmails,
  }) async {
    // 実装：データベースに定期エクスポートを登録
  }

  /// プライバシー設定を適用
  List<Map<String, dynamic>> _applyPrivacySettings({
    required List<Map<String, dynamic>> records,
    required bool maskPersonalData,
    required bool includePersonalInfo,
  }) {
    if (!includePersonalInfo) {
      return records
          .map((r) => Map.from(r)..removeWhere((k, v) => _isPersonalField(k)))
          .toList();
    }

    if (maskPersonalData) {
      return records
          .map((r) => _maskPersonalFields(r))
          .toList();
    }

    return records;
  }

  /// 個人情報フィールドか判定
  bool _isPersonalField(String fieldName) {
    final personalFields = ['email', 'phone', 'address', 'ssn', 'student_id'];
    return personalFields.contains(fieldName.toLowerCase());
  }

  /// 個人情報をマスク
  Map<String, dynamic> _maskPersonalFields(Map<String, dynamic> record) {
    final masked = Map.from(record);
    if (masked.containsKey('email')) {
      masked['email'] = _maskEmail(masked['email']);
    }
    if (masked.containsKey('phone')) {
      masked['phone'] = '***-****-****';
    }
    return masked;
  }

  /// メールアドレスをマスク
  String _maskEmail(dynamic email) {
    if (email is! String) return '***@***.com';
    final parts = email.split('@');
    if (parts.length != 2) return '***@***.com';
    final local = parts[0];
    final masked = '${local.substring(0, 1)}***@${parts[1]}';
    return masked;
  }

  /// レコードをフィルタリング
  List<Map<String, dynamic>> _filterRecords({
    required List<Map<String, dynamic>> records,
    required List<String>? includedFields,
  }) {
    if (includedFields == null || includedFields.isEmpty) {
      return records;
    }

    return records
        .map((record) {
          final filtered = <String, dynamic>{};
          for (final field in includedFields) {
            if (record.containsKey(field)) {
              filtered[field] = record[field];
            }
          }
          return filtered;
        })
        .toList();
  }

  /// データをフォーマット
  String _formatData({
    required List<Map<String, dynamic>> records,
    required String format,
  }) {
    switch (format.toLowerCase()) {
      case 'csv':
        return _formatAsCSV(records);
      case 'excel':
        return '<excel>${_formatAsCSV(records)}</excel>';
      case 'json':
        return _formatAsJSON(records);
      case 'xml':
        return _formatAsXML(records);
      default:
        return _formatAsCSV(records);
    }
  }

  /// CSV フォーマット
  String _formatAsCSV(List<Map<String, dynamic>> records) {
    if (records.isEmpty) return '';

    final headers = records.first.keys.toList();
    final lines = <String>[];

    // ヘッダー行
    lines.add(headers.map((h) => '"$h"').join(','));

    // データ行
    for (final record in records) {
      final values = headers.map((h) {
        final value = record[h] ?? '';
        return '"$value"';
      }).join(',');
      lines.add(values);
    }

    return lines.join('\n');
  }

  /// JSON フォーマット
  String _formatAsJSON(List<Map<String, dynamic>> records) {
    return '{"records": $records}';
  }

  /// XML フォーマット
  String _formatAsXML(List<Map<String, dynamic>> records) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<data>');
    for (final record in records) {
      buffer.writeln('  <record>');
      record.forEach((k, v) {
        buffer.writeln('    <$k>$v</$k>');
      });
      buffer.writeln('  </record>');
    }
    buffer.writeln('</data>');
    return buffer.toString();
  }

  /// コンテンツを暗号化
  String _encryptContent(String content, String encryptionType) {
    // 概念的な実装：実際には暗号化ライブラリを使用
    return '[ENCRYPTED:$encryptionType]$content[/ENCRYPTED]';
  }

  /// キャッシュをクリア
  void clearCache(String exportId) {
    _exportCache.remove(exportId);
  }

  /// すべてのキャッシュをクリア
  void clearAllCache() {
    _exportCache.clear();
  }
}
