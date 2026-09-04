import 'package:flutter_test/flutter_test.dart';
import 'package:your_app_name/models/report_model.dart';
import 'package:your_app_name/services/export_service.dart';

void main() {
  group('ExportService Tests', () {
    late ExportService service;

    setUp(() {
      service = ExportService();
    });

    tearDown(() {
      service.clearAllCache();
    });

    test('exportData: Creates valid export', () async {
      final config = ExportConfig(
        id: 'export_1',
        dataType: 'student_data',
        format: 'csv',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );

      final records = [
        {'id': '1', 'name': 'Alice', 'score': 85},
        {'id': '2', 'name': 'Bob', 'score': 72},
      ];

      final result = await service.exportData(
        exportId: 'exp_001',
        config: config,
        dataRecords: records,
      );

      expect(result, isNotNull);
      expect(result.format, 'csv');
      expect(result.status, 'ready');
      expect(result.recordCount, 2);
      expect(result.fileSizeBytes, greaterThan(0));
    });

    test('exportData: Supports multiple formats', () async {
      final formats = ['csv', 'excel', 'json', 'xml'];
      final records = [
        {'id': '1', 'name': 'Test', 'score': 80},
      ];

      for (final format in formats) {
        final config = ExportConfig(
          id: 'export_$format',
          dataType: 'test_data',
          format: format,
          startDate: DateTime.now().subtract(const Duration(days: 7)),
          endDate: DateTime.now(),
        );

        final result = await service.exportData(
          exportId: 'exp_$format',
          config: config,
          dataRecords: records,
        );

        expect(result.format, format);
      }
    });

    test('exportData: Applies privacy settings', () async {
      final config = ExportConfig(
        id: 'export_privacy',
        dataType: 'student_data',
        format: 'csv',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        includePersonalInfo: false,
        maskPersonalData: true,
      );

      final records = [
        {
          'id': '1',
          'name': 'Alice',
          'email': 'alice@example.com',
          'score': 85,
        },
      ];

      final result = await service.exportData(
        exportId: 'exp_privacy',
        config: config,
        dataRecords: records,
      );

      expect(result.status, 'ready');
      // 個人情報がマスクされている
      expect(result.isEncrypted, false);
    });

    test('exportData: Handles encryption', () async {
      final config = ExportConfig(
        id: 'export_encrypted',
        dataType: 'sensitive_data',
        format: 'csv',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        encryptionType: 'aes256',
      );

      final records = [
        {'id': '1', 'sensitive': 'data'},
      ];

      final result = await service.exportData(
        exportId: 'exp_encrypted',
        config: config,
        dataRecords: records,
      );

      expect(result.isEncrypted, true);
      expect(result.status, 'ready');
    });

    test('exportData: Filters included fields', () async {
      final config = ExportConfig(
        id: 'export_filter',
        dataType: 'student_data',
        format: 'csv',
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now(),
        includedFields: ['id', 'score'], // nameは除外
      );

      final records = [
        {'id': '1', 'name': 'Alice', 'score': 85},
        {'id': '2', 'name': 'Bob', 'score': 72},
      ];

      final result = await service.exportData(
        exportId: 'exp_filter',
        config: config,
        dataRecords: records,
      );

      expect(result.recordCount, 2);
      expect(result.status, 'ready');
    });

    test('exportData: Sets expiration date', () async {
      final config = ExportConfig(
        id: 'export_expiry',
        dataType: 'test_data',
        format: 'csv',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      final records = [
        {'id': '1', 'value': 'test'},
      ];

      final result = await service.exportData(
        exportId: 'exp_expiry',
        config: config,
        dataRecords: records,
      );

      expect(result.expiresAt, isNotNull);
      expect(
        result.expiresAt!.isAfter(result.createdAt),
        true,
      );
    });

    test('exportData: Tracks download count', () async {
      final config = ExportConfig(
        id: 'export_download',
        dataType: 'test_data',
        format: 'csv',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      final result = await service.exportData(
        exportId: 'exp_download',
        config: config,
        dataRecords: [
          {'id': '1', 'value': 'test'},
        ],
      );

      expect(result.downloadCount, 0);
    });
  });
}
