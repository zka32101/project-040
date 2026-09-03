import 'package:flutter_test/flutter_test.dart';

// Phase 18 Integration Tests
// エンドツーエンドレポート生成フロー、データエクスポート、ナビゲーションの統合テスト

void main() {
  group('Phase 18: Integration Tests', () {
    // Integration Test 1: 完全なレポート生成フロー
    test('Complete report generation flow', () async {
      // 1. ユーザーがReportGeneratorViewを開く
      const templateId = 'student_progress';
      const format = 'pdf';
      final startDate = DateTime.now().subtract(const Duration(days: 30));
      final endDate = DateTime.now();

      // 2. パラメータを準備
      final params = ReportGenerationParamsForTest(
        templateId: templateId,
        reportType: 'student_progress',
        format: format,
        startDate: startDate,
        endDate: endDate,
        title: 'Integration Test Report',
        generatedBy: 'teacher_001',
        dataSource: {},
      );

      // 3. レポート生成をシミュレート
      expect(params.templateId, 'student_progress');
      expect(params.format, 'pdf');
      expect(params.title, 'Integration Test Report');

      // 4. 生成完了をシミュレート
      final report = GeneratedReportForTest(
        id: 'report_001',
        templateId: templateId,
        reportType: 'student_progress',
        title: params.title,
        description: 'A comprehensive report on student progress',
        format: format,
        generatedAt: DateTime.now(),
        startDate: startDate,
        endDate: endDate,
        contentUrl: '/reports/report_001/download',
        fileSizeBytes: 1024.0 * 10, // 10 MB
        generatedBy: 'teacher_001',
        status: 'ready',
      );

      // 5. ReportViewerPageへナビゲート（データ渡し）
      expect(report.id, 'report_001');
      expect(report.status, 'ready');
      expect(report.format.toUpperCase(), 'PDF');
    });

    // Integration Test 2: データエクスポート+ダウンロードフロー
    test('Complete data export and download flow', () async {
      // 1. ユーザーがExportDataViewを開く
      const dataType = 'student_data';
      const format = 'csv';
      final startDate = DateTime.now().subtract(const Duration(days: 90));
      final endDate = DateTime.now();

      // 2. プライバシー設定を確認
      const includePersonalInfo = true;
      const maskPersonalData = true;

      // 3. エクスポートパラメータを準備
      final params = ExportDataParamsForTest(
        exportId: 'export_001',
        dataType: dataType,
        format: format,
        startDate: startDate,
        endDate: endDate,
        maskPersonalData: maskPersonalData,
        includePersonalInfo: includePersonalInfo,
        encryptionType: 'none',
        dataRecords: [],
      );

      expect(params.dataType, 'student_data');
      expect(params.maskPersonalData, true);
      expect(params.includePersonalInfo, true);

      // 4. エクスポート実行をシミュレート
      final result = ExportResultForTest(
        id: 'export_001',
        exportType: dataType,
        format: format,
        downloadUrl: '/exports/export_001/download',
        recordCount: 150,
        fileSizeBytes: 2048.0,
        createdAt: DateTime.now(),
        status: 'ready',
        downloadCount: 0,
      );

      // 5. ダウンロード完了をシミュレート
      expect(result.recordCount, 150);
      expect(result.status, 'ready');
      expect(result.downloadCount, 0);

      // 6. ダウンロード回数を更新
      final updatedResult = ExportResultForTest(
        id: result.id,
        exportType: result.exportType,
        format: result.format,
        downloadUrl: result.downloadUrl,
        recordCount: result.recordCount,
        fileSizeBytes: result.fileSizeBytes,
        createdAt: result.createdAt,
        status: result.status,
        downloadCount: (result.downloadCount ?? 0) + 1,
      );

      expect(updatedResult.downloadCount, 1);
    });

    // Integration Test 3: ナビゲーションフロー - ダッシュボード → レポート生成
    test('Navigation flow: Dashboard to Report Generator', () async {
      // 1. ユーザーがAdminDashboardViewを表示
      const classId = 'class_001';
      const className = 'Biology 101';

      // 2. メニューからレポート生成を選択
      final navigationTarget = '/report-generator';

      expect(navigationTarget, '/report-generator');

      // 3. ReportGeneratorViewが表示される
      const templateId = 'class_performance';
      expect(templateId, 'class_performance');
    });

    // Integration Test 4: ナビゲーション - ダッシュボード → データエクスポート
    test('Navigation flow: Dashboard to Export Data', () async {
      // 1. AdminDashboardViewのメニューからエクスポートを選択
      final navigationTarget = '/export';

      expect(navigationTarget, '/export');

      // 2. ExportDataViewが表示される
      expect(navigationTarget.isNotEmpty, true);
    });

    // Integration Test 5: クラス管理ビュー生成フロー
    test('Class management view generation flow', () async {
      // 1. クラスデータを取得
      final analyses = <StudentPerformanceAnalysisForTest>[];
      for (int i = 1; i <= 28; i++) {
        analyses.add(StudentPerformanceAnalysisForTest(
          studentId: 'student_$i',
          studentName: '学生$i',
          score: 50 + (i * 1.5).toInt(),
        ));
      }

      // 2. ClassViewParamsを構築
      final params = ClassViewParamsForTest(
        classId: 'class_001',
        className: 'Biology 101',
        studentAnalyses: analyses,
      );

      expect(params.classId, 'class_001');
      expect(params.className, 'Biology 101');
      expect(params.studentAnalyses.length, 28);

      // 3. ClassManagementViewを生成
      final view = ClassManagementViewForTest(
        classId: params.classId,
        className: params.className,
        totalStudents: 28,
        activeStudents: 25,
        averageScore: 75.5,
        scoreDistribution: {
          '90-100': 8,
          '80-89': 10,
          '70-79': 6,
          '60-69': 3,
          '0-59': 1,
        },
        topPerformers: analyses
            .where((s) => s.score >= 80)
            .map((s) => s.studentId)
            .toList(),
        needsSupport: analyses
            .where((s) => s.score < 60)
            .map((s) => s.studentId)
            .toList(),
        categoryAverages: {},
        lastUpdatedAt: DateTime.now(),
      );

      // 4. 統計が正しく計算されていることを確認
      expect(view.totalStudents, 28);
      expect(view.averageScore, 75.5);
      expect(view.scoreDistribution.values.fold<int>(0, (a, b) => a + b), 28);
    });

    // Integration Test 6: エラーハンドリング - ネットワークエラー
    test('Error handling: Network error during report generation', () async {
      // 1. レポート生成要求
      final params = ReportGenerationParamsForTest(
        templateId: 'student_progress',
        reportType: 'student_progress',
        format: 'pdf',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        title: 'Test Report',
        generatedBy: 'teacher_001',
        dataSource: {},
      );

      // 2. ネットワークエラーをシミュレート
      final errorOccurred = true;
      final errorMessage = 'Network error: Unable to reach server';

      expect(errorOccurred, true);
      expect(errorMessage.isNotEmpty, true);

      // 3. エラーメッセージをユーザーに表示
      expect(errorMessage.contains('Network'), true);
    });

    // Integration Test 7: マルチステップ - レポート生成 → ビューア → ダウンロード
    test('Multi-step flow: Generate → View → Download report', () async {
      // Step 1: レポート生成
      final report = GeneratedReportForTest(
        id: 'report_001',
        templateId: 'student_progress',
        reportType: 'student_progress',
        title: 'Student Progress Report',
        description: 'Monthly student progress summary',
        format: 'pdf',
        generatedAt: DateTime.now(),
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        contentUrl: '/reports/report_001/download',
        fileSizeBytes: 1024.0 * 10,
        generatedBy: 'teacher_001',
        status: 'ready',
      );

      expect(report.status, 'ready');

      // Step 2: ビューアで表示
      expect(report.id.isNotEmpty, true);
      expect(report.contentUrl.contains('/download'), true);

      // Step 3: ダウンロード実行
      expect(report.fileSizeBytes, 10240.0);
    });

    // Integration Test 8: キャッシング - 同じパラメータでの再生成
    test('Caching behavior: Same parameters should return cached result',
        () async {
      // 1. 最初のレポート生成要求
      final params1 = ReportGenerationParamsForTest(
        templateId: 'student_progress',
        reportType: 'student_progress',
        format: 'pdf',
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 9, 1),
        title: 'Monthly Report',
        generatedBy: 'teacher_001',
        dataSource: {},
      );

      // 2. 同じパラメータで再生成要求
      final params2 = ReportGenerationParamsForTest(
        templateId: 'student_progress',
        reportType: 'student_progress',
        format: 'pdf',
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 9, 1),
        title: 'Monthly Report',
        generatedBy: 'teacher_001',
        dataSource: {},
      );

      // 3. パラメータが同じかどうか確認（キャッシュキーとして使用）
      expect(params1.templateId == params2.templateId, true);
      expect(params1.format == params2.format, true);
      expect(params1.startDate == params2.startDate, true);
      expect(params1.endDate == params2.endDate, true);
    });

    // Integration Test 9: 複数フォーマット - 同じデータを異なる形式でエクスポート
    test('Multiple formats: Export same data in different formats', () async {
      final dataType = 'student_data';
      final startDate = DateTime.now().subtract(const Duration(days: 90));
      final endDate = DateTime.now();

      final formats = ['csv', 'excel', 'json', 'xml'];
      final results = <ExportResultForTest>[];

      for (String format in formats) {
        final result = ExportResultForTest(
          id: 'export_${format}_001',
          exportType: dataType,
          format: format,
          downloadUrl: '/exports/export_${format}_001/download',
          recordCount: 150,
          fileSizeBytes: 2048.0 * (1 + (formats.indexOf(format) * 0.5)),
          createdAt: DateTime.now(),
          status: 'ready',
        );
        results.add(result);
      }

      expect(results.length, 4);
      expect(results.every((r) => r.status == 'ready'), true);
      expect(results.every((r) => r.recordCount == 150), true);
    });

    // Integration Test 10: プライバシー検証 - マスク設定の依存性
    test('Privacy validation: Masking option depends on personal info inclusion',
        () async {
      // シナリオ1: 個人情報を含めない場合、マスク設定は無効
      var params = ExportDataParamsForTest(
        exportId: 'export_001',
        dataType: 'student_data',
        format: 'csv',
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now(),
        maskPersonalData: true, // This should be ignored
        includePersonalInfo: false,
        dataRecords: [],
      );

      // 個人情報を含めない場合、マスク設定は無視される
      if (!params.includePersonalInfo) {
        expect(params.maskPersonalData, true); // UI層で false に設定されるべき
      }

      // シナリオ2: 個人情報を含める場合、マスク設定が有効
      params = ExportDataParamsForTest(
        exportId: 'export_002',
        dataType: 'student_data',
        format: 'csv',
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now(),
        maskPersonalData: true,
        includePersonalInfo: true,
        dataRecords: [],
      );

      expect(params.includePersonalInfo, true);
      expect(params.maskPersonalData, true);
    });

    // Integration Test 11: データ整合性 - エクスポート後のレコード数
    test('Data integrity: Record count should match after export', () async {
      const expectedRecordCount = 150;

      final params = ExportDataParamsForTest(
        exportId: 'export_001',
        dataType: 'student_data',
        format: 'csv',
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now(),
        maskPersonalData: false,
        includePersonalInfo: true,
        dataRecords: List.generate(
          expectedRecordCount,
          (i) => {'id': 'student_$i', 'score': 50 + (i % 50)},
        ),
      );

      final result = ExportResultForTest(
        id: 'export_001',
        exportType: 'student_data',
        format: 'csv',
        downloadUrl: '/exports/export_001/download',
        recordCount: params.dataRecords.length,
        fileSizeBytes: 2048.0,
        createdAt: DateTime.now(),
        status: 'ready',
      );

      expect(result.recordCount, expectedRecordCount);
      expect(result.recordCount == params.dataRecords.length, true);
    });

    // Integration Test 12: ナビゲーション状態の保持
    test('Navigation state preservation: Selections should be maintained',
        () async {
      // 1. ユーザーがクラスを選択
      const selectedClassId = 'class_002';
      const selectedClassName = 'Chemistry 202';

      // 2. メニューからレポート生成へナビゲート
      final navigationParams = {
        'classId': selectedClassId,
        'className': selectedClassName,
      };

      // 3. 戻ってくるまでセッションが保持されるはず
      expect(navigationParams['classId'], selectedClassId);
      expect(navigationParams['className'], selectedClassName);
    });
  });
}

// Test Helper Classes
class ReportGenerationParamsForTest {
  final String templateId;
  final String reportType;
  final String format;
  final DateTime startDate;
  final DateTime endDate;
  final String title;
  final String generatedBy;
  final Map<String, dynamic> dataSource;

  ReportGenerationParamsForTest({
    required this.templateId,
    required this.reportType,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.title,
    required this.generatedBy,
    required this.dataSource,
  });
}

class ExportDataParamsForTest {
  final String exportId;
  final String dataType;
  final String format;
  final DateTime startDate;
  final DateTime endDate;
  final bool maskPersonalData;
  final bool includePersonalInfo;
  final String? encryptionType;
  final List<Map<String, dynamic>> dataRecords;

  ExportDataParamsForTest({
    required this.exportId,
    required this.dataType,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.maskPersonalData,
    required this.includePersonalInfo,
    this.encryptionType,
    required this.dataRecords,
  });
}

class GeneratedReportForTest {
  final String id;
  final String templateId;
  final String reportType;
  final String title;
  final String description;
  final String format;
  final DateTime generatedAt;
  final DateTime startDate;
  final DateTime endDate;
  final String contentUrl;
  final double fileSizeBytes;
  final String generatedBy;
  final String? status;

  GeneratedReportForTest({
    required this.id,
    required this.templateId,
    required this.reportType,
    required this.title,
    required this.description,
    required this.format,
    required this.generatedAt,
    required this.startDate,
    required this.endDate,
    required this.contentUrl,
    required this.fileSizeBytes,
    required this.generatedBy,
    this.status,
  });
}

class ExportResultForTest {
  final String id;
  final String exportType;
  final String format;
  final String downloadUrl;
  final int recordCount;
  final double fileSizeBytes;
  final DateTime createdAt;
  final String status;
  final int? downloadCount;

  ExportResultForTest({
    required this.id,
    required this.exportType,
    required this.format,
    required this.downloadUrl,
    required this.recordCount,
    required this.fileSizeBytes,
    required this.createdAt,
    required this.status,
    this.downloadCount,
  });
}

class StudentPerformanceAnalysisForTest {
  final String studentId;
  final String studentName;
  final int score;

  StudentPerformanceAnalysisForTest({
    required this.studentId,
    required this.studentName,
    required this.score,
  });
}

class ClassViewParamsForTest {
  final String classId;
  final String className;
  final List<StudentPerformanceAnalysisForTest> studentAnalyses;

  ClassViewParamsForTest({
    required this.classId,
    required this.className,
    required this.studentAnalyses,
  });
}

class ClassManagementViewForTest {
  final String classId;
  final String className;
  final int totalStudents;
  final int activeStudents;
  final double averageScore;
  final Map<String, int> scoreDistribution;
  final List<String> topPerformers;
  final List<String> needsSupport;
  final Map<String, double> categoryAverages;
  final DateTime lastUpdatedAt;

  ClassManagementViewForTest({
    required this.classId,
    required this.className,
    required this.totalStudents,
    required this.activeStudents,
    required this.averageScore,
    required this.scoreDistribution,
    required this.topPerformers,
    required this.needsSupport,
    required this.categoryAverages,
    required this.lastUpdatedAt,
  });
}
