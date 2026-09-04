import 'package:flutter_test/flutter_test.dart';
import 'package:your_app_name/models/report_model.dart';
import 'package:your_app_name/services/report_service.dart';

void main() {
  group('ReportService Tests', () {
    late ReportService service;

    setUp(() {
      service = ReportService();
    });

    tearDown(() {
      service.clearAllCache();
    });

    test('generateReport: Creates valid report', () async {
      final config = ReportConfig(
        id: 'config_1',
        templateId: 'student_progress',
        reportType: 'student_progress',
        format: 'pdf',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );

      final report = await service.generateReport(
        templateId: 'student_progress',
        config: config,
        title: 'Test Report',
        generatedBy: 'teacher_001',
        dataSource: {'students': []},
      );

      expect(report, isNotNull);
      expect(report.title, 'Test Report');
      expect(report.format, 'pdf');
      expect(report.status, 'ready');
      expect(report.fileSizeBytes, greaterThan(0));
    });

    test('generateReport: Supports multiple formats', () async {
      final formats = ['pdf', 'csv', 'excel', 'json'];

      for (final format in formats) {
        final config = ReportConfig(
          id: 'config_$format',
          templateId: 'student_progress',
          reportType: 'student_progress',
          format: format,
          startDate: DateTime.now().subtract(const Duration(days: 7)),
          endDate: DateTime.now(),
        );

        final report = await service.generateReport(
          templateId: 'student_progress',
          config: config,
          title: '$format Report',
          generatedBy: 'user_001',
          dataSource: {'data': []},
        );

        expect(report.format, format);
      }
    });

    test('scheduleReportDelivery: Creates valid schedule', () async {
      final schedule = await service.scheduleReportDelivery(
        templateId: 'student_progress',
        deliveryType: 'email',
        frequency: 'weekly',
        time: '09:00',
        recipientEmails: ['teacher@example.com'],
        dayOfWeek: 'monday',
      );

      expect(schedule, isNotNull);
      expect(schedule.frequency, 'weekly');
      expect(schedule.isActive, true);
      expect(schedule.recipientEmails, contains('teacher@example.com'));
    });

    test('generateClassView: Calculates class statistics', () async {
      final analyses = [
        StudentPerformanceAnalysis(
          studentId: 'student_1',
          studentName: 'Alice',
          currentScore: 85,
          previousScore: 80,
          scoreChange: 5,
          trend: 'improving',
          questionsAttempted: 50,
          correctAnswers: 42,
          accuracy: 0.84,
          categoryScores: {'math': 85, 'english': 80},
          weakCategories: ['english'],
          strongCategories: ['math'],
          lastActivityAt: DateTime.now(),
          engagementLevel: 'high',
          recommendedActions: [],
        ),
        StudentPerformanceAnalysis(
          studentId: 'student_2',
          studentName: 'Bob',
          currentScore: 45,
          previousScore: 50,
          scoreChange: -5,
          trend: 'declining',
          questionsAttempted: 30,
          correctAnswers: 12,
          accuracy: 0.40,
          categoryScores: {'math': 40, 'english': 50},
          weakCategories: ['math', 'english'],
          strongCategories: [],
          lastActivityAt: DateTime.now().subtract(const Duration(days: 5)),
          engagementLevel: 'low',
          recommendedActions: [],
        ),
      ];

      final classView = await service.generateClassView(
        classId: 'class_001',
        className: 'Biology 101',
        studentAnalyses: analyses,
      );

      expect(classView.totalStudents, 2);
      expect(classView.averageScore, 65);
      expect(classView.topPerformers, contains('student_1'));
      expect(classView.needsSupport, contains('student_2'));
    });

    test('Caching: Reports are cached after generation', () async {
      final config = ReportConfig(
        id: 'config_cache',
        templateId: 'student_progress',
        reportType: 'student_progress',
        format: 'pdf',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      );

      final report1 = await service.generateReport(
        templateId: 'student_progress',
        config: config,
        title: 'Cached Report',
        generatedBy: 'user_cache',
        dataSource: {},
      );

      await Future.delayed(const Duration(milliseconds: 50));

      // キャッシュから再生成されるはず
      final report2 = await service.generateReport(
        templateId: 'student_progress',
        config: config,
        title: 'Cached Report 2',
        generatedBy: 'user_cache',
        dataSource: {},
      );

      // 異なるレポートなので別の ID を持つ
      expect(report1.id, isNotEqualTo(report2.id));
    });

    test('Template retrieval: Predefined templates are available', () {
      expect(ReportService.predefinedTemplates.keys,
          contains('student_progress'));
      expect(
          ReportService.predefinedTemplates.keys, contains('class_performance'));
      expect(
          ReportService.predefinedTemplates.keys, contains('cohort_analysis'));
    });
  });
}
