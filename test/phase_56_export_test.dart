import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/export_models.dart';
import 'package:project_040/services/export_service.dart';

void main() {
  group('Phase 56: Data Export & Reporting', () {
    // ========== Enum Tests ==========
    group('Enum Tests', () {
      test('ExportFormat values', () {
        expect(ExportFormat.csv.value, 'csv');
        expect(ExportFormat.json.value, 'json');
        expect(ExportFormat.pdf.value, 'pdf');
      });

      test('ReportType values', () {
        expect(ReportType.jobSummary.value, 'job_summary');
        expect(ReportType.performanceAnalysis.value, 'performance_analysis');
      });

      test('FilterType values', () {
        expect(FilterType.dateRange.value, 'date_range');
        expect(FilterType.status.value, 'status');
      });
    });

    // ========== Model Tests ==========
    group('ExportConfiguration Model Tests', () {
      test('Valid configuration', () {
        final config = ExportConfiguration(
          configId: 'config1',
          name: 'CSV Export',
          format: ExportFormat.csv,
          includeFields: ['id', 'name', 'status'],
          excludeFields: [],
          includeHeaders: true,
          includeSummary: true,
          createdAt: DateTime.now(),
        );
        expect(config.isEnabled, true);
        expect(config.totalFields, 3);
        expect(config.isCustomized, false);
      });

      test('Customized configuration', () {
        final config = ExportConfiguration(
          configId: 'config2',
          name: 'Filtered CSV',
          format: ExportFormat.csv,
          includeFields: ['id', 'name', 'status', 'timestamp'],
          excludeFields: ['timestamp'],
          includeHeaders: true,
          includeSummary: false,
          createdAt: DateTime.now(),
        );
        expect(config.isCustomized, true);
        expect(config.totalFields, 3);
      });
    });

    group('ExportJob Model Tests', () {
      test('Pending job', () {
        final job = ExportJob(
          jobId: 'job1',
          exportConfigId: 'config1',
          format: ExportFormat.csv,
          createdAt: DateTime.now(),
          status: ExportJobStatus.pending,
          totalRecords: 1000,
        );
        expect(job.isCompleted, false);
        expect(job.progressPercentage, 0.0);
      });

      test('Completed successful job', () {
        final job = ExportJob(
          jobId: 'job2',
          exportConfigId: 'config1',
          format: ExportFormat.json,
          createdAt: DateTime.now(),
          startedAt: DateTime.now(),
          completedAt: DateTime.now().add(Duration(seconds: 5)),
          status: ExportJobStatus.completed,
          totalRecords: 500,
          processedRecords: 500,
          filePath: '/exports/file.json',
          fileSizeBytes: 15360,
        );
        expect(job.isCompleted, true);
        expect(job.isSuccessful, true);
        expect(job.progressPercentage, 100.0);
        expect(job.executionTimeSeconds, 5);
      });

      test('Failed job', () {
        final job = ExportJob(
          jobId: 'job3',
          exportConfigId: 'config1',
          format: ExportFormat.pdf,
          createdAt: DateTime.now(),
          startedAt: DateTime.now(),
          completedAt: DateTime.now(),
          status: ExportJobStatus.failed,
          errorMessage: 'PDF generation failed',
        );
        expect(job.isFailed, true);
        expect(job.isSuccessful, false);
      });
    });

    group('Report Model Tests', () {
      test('Recent report', () {
        final report = Report(
          reportId: 'report1',
          title: 'Monthly Summary',
          reportType: ReportType.jobSummary,
          generatedAt: DateTime.now(),
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
          data: {'total_jobs': 150, 'successful': 145},
        );
        expect(report.isRecent, true);
      });

      test('Old report', () {
        final report = Report(
          reportId: 'report2',
          title: 'Old Report',
          reportType: ReportType.performanceAnalysis,
          generatedAt: DateTime.now().subtract(Duration(days: 15)),
          periodStart: DateTime.now().subtract(Duration(days: 45)),
          periodEnd: DateTime.now().subtract(Duration(days: 15)),
          data: {},
        );
        expect(report.isRecent, false);
      });

      test('Report with recommendations', () {
        final report = Report(
          reportId: 'report3',
          title: 'Analysis',
          reportType: ReportType.detailedAnalysis,
          generatedAt: DateTime.now(),
          periodStart: DateTime.now().subtract(Duration(days: 7)),
          periodEnd: DateTime.now(),
          data: {},
          recommendations: ['Optimize database', 'Add caching'],
        );
        expect(report.hasRecommendations, true);
      });

      test('Markdown output', () {
        final report = Report(
          reportId: 'report4',
          title: 'Test Report',
          reportType: ReportType.jobSummary,
          generatedAt: DateTime.now(),
          periodStart: DateTime.now().subtract(Duration(days: 1)),
          periodEnd: DateTime.now(),
          data: {},
          summary: 'This is a test report',
        );
        final markdown = report.toMarkdown();
        expect(markdown.contains('Test Report'), true);
        expect(markdown.contains('Generated'), true);
      });
    });

    group('DataFilter Model Tests', () {
      test('Simple filter', () {
        final filter = DataFilter(
          filterId: 'filter1',
          filterName: 'Status Filter',
          filterType: FilterType.status,
          filterValue: 'completed',
          createdAt: DateTime.now(),
        );
        expect(filter.isEnabled, true);
        expect(filter.isComplex, false);
      });

      test('Complex filter', () {
        final filter = DataFilter(
          filterId: 'filter2',
          filterName: 'Date Range',
          filterType: FilterType.dateRange,
          filterValue: ['2026-01-01', '2026-12-31'],
          createdAt: DateTime.now(),
        );
        expect(filter.isComplex, true);
      });
    });

    group('ScheduledExport Model Tests', () {
      test('Scheduled export', () {
        final schedule = ScheduledExport(
          scheduleId: 'schedule1',
          exportConfigId: 'config1',
          cronExpression: '0 0 * * *',
          createdAt: DateTime.now(),
          emailRecipients: ['user@example.com'],
        );
        expect(schedule.isEnabled, true);
        expect(schedule.recipientCount, 1);
      });

      test('Schedule with execution history', () {
        final schedule = ScheduledExport(
          scheduleId: 'schedule2',
          exportConfigId: 'config1',
          cronExpression: '0 9 * * 1',
          createdAt: DateTime.now().subtract(Duration(days: 30)),
          lastExecutedAt: DateTime.now().subtract(Duration(days: 1)),
          nextExecutionAt: DateTime.now().add(Duration(days: 6)),
          emailRecipients: ['admin@example.com', 'manager@example.com'],
        );
        expect(schedule.hasExecuted, true);
        expect(schedule.hasSchedule, true);
        expect(schedule.recipientCount, 2);
      });
    });

    group('ExportMetrics Model Tests', () {
      test('Healthy metrics', () {
        final metrics = ExportMetrics(
          metricsId: 'metrics1',
          totalExports: 100,
          successfulExports: 99,
          failedExports: 1,
          averageProcessingTimeSeconds: 2.5,
          totalDataRecords: 5000,
          totalExportedRecords: 4950,
          averageFileSizeMb: 5.2,
          periodStart: DateTime.now().subtract(Duration(days: 7)),
          periodEnd: DateTime.now(),
        );
        expect(metrics.successRate, greaterThan(0.95));
        expect(metrics.isHealthy, true);
      });

      test('Unhealthy metrics', () {
        final metrics = ExportMetrics(
          metricsId: 'metrics2',
          totalExports: 100,
          successfulExports: 80,
          failedExports: 20,
          averageProcessingTimeSeconds: 15.0,
          totalDataRecords: 5000,
          totalExportedRecords: 4000,
          averageFileSizeMb: 2.1,
          periodStart: DateTime.now().subtract(Duration(days: 7)),
          periodEnd: DateTime.now(),
        );
        expect(metrics.successRate, lessThan(0.95));
        expect(metrics.isHealthy, false);
      });
    });

    group('ReportTemplate Model Tests', () {
      test('Template rendering', () {
        final template = ReportTemplate(
          templateId: 'template1',
          templateName: 'Basic Report',
          reportType: ReportType.jobSummary,
          htmlContent: '<h1>{{title}}</h1><p>{{content}}</p>',
          placeholders: {'title': '', 'content': ''},
          createdAt: DateTime.now(),
        );
        final rendered = template.render({
          'title': 'Monthly Report',
          'content': 'Summary data here',
        });
        expect(rendered.contains('Monthly Report'), true);
        expect(rendered.contains('Summary data here'), true);
      });

      test('Template with multiple placeholders', () {
        final template = ReportTemplate(
          templateId: 'template2',
          templateName: 'Detail Report',
          reportType: ReportType.detailedAnalysis,
          htmlContent: '<h1>{{title}}</h1><table>{{table_data}}</table><footer>{{footer}}</footer>',
          placeholders: {'title': '', 'table_data': '', 'footer': ''},
          createdAt: DateTime.now(),
        );
        expect(template.placeholderCount, 3);
        expect(template.isEnabled, true);
      });
    });

    // ========== Repository Tests ==========
    group('MemoryExportRepository Tests', () {
      late MemoryExportRepository repository;

      setUp(() {
        repository = MemoryExportRepository();
      });

      test('Add and retrieve configuration', () async {
        final config = ExportConfiguration(
          configId: 'config1',
          name: 'Test Config',
          format: ExportFormat.csv,
          includeFields: [],
          excludeFields: [],
          includeHeaders: true,
          includeSummary: true,
          createdAt: DateTime.now(),
        );
        await repository.addConfiguration(config);
        final retrieved = await repository.getConfiguration('config1');
        expect(retrieved, isNotNull);
        expect(retrieved!.name, 'Test Config');
      });

      test('Add and retrieve job', () async {
        final job = ExportJob(
          jobId: 'job1',
          exportConfigId: 'config1',
          format: ExportFormat.json,
          createdAt: DateTime.now(),
          status: ExportJobStatus.pending,
        );
        await repository.addJob(job);
        final retrieved = await repository.getJob('job1');
        expect(retrieved, isNotNull);
      });

      test('Get jobs by status', () async {
        final job1 = ExportJob(
          jobId: 'job1',
          exportConfigId: 'config1',
          format: ExportFormat.csv,
          createdAt: DateTime.now(),
          status: ExportJobStatus.completed,
        );
        final job2 = ExportJob(
          jobId: 'job2',
          exportConfigId: 'config1',
          format: ExportFormat.json,
          createdAt: DateTime.now(),
          status: ExportJobStatus.failed,
        );
        await repository.addJob(job1);
        await repository.addJob(job2);
        final completed = await repository.getJobsByStatus(ExportJobStatus.completed);
        expect(completed.length, 1);
      });

      test('Add and retrieve report', () async {
        final report = Report(
          reportId: 'report1',
          title: 'Test Report',
          reportType: ReportType.jobSummary,
          generatedAt: DateTime.now(),
          periodStart: DateTime.now().subtract(Duration(days: 1)),
          periodEnd: DateTime.now(),
          data: {},
        );
        await repository.addReport(report);
        final retrieved = await repository.getReport('report1');
        expect(retrieved, isNotNull);
      });

      test('Add filter', () async {
        final filter = DataFilter(
          filterId: 'filter1',
          filterName: 'Test',
          filterType: FilterType.status,
          filterValue: 'active',
          createdAt: DateTime.now(),
        );
        await repository.addFilter(filter);
        final retrieved = await repository.getFilter('filter1');
        expect(retrieved, isNotNull);
      });
    });

    // ========== Engine Tests ==========
    group('MemoryExportEngine Tests', () {
      late MemoryExportEngine engine;

      setUp(() {
        engine = MemoryExportEngine();
      });

      test('Export to CSV', () async {
        final data = [
          {'id': '1', 'name': 'Job 1', 'status': 'completed'},
          {'id': '2', 'name': 'Job 2', 'status': 'pending'},
        ];
        final csv = await engine.exportToCsv(data, ['id', 'name', 'status']);
        expect(csv.contains('id,name,status'), true);
        expect(csv.contains('Job 1'), true);
      });

      test('Export to JSON', () async {
        final data = [{'id': '1', 'name': 'Test'}];
        final json = await engine.exportToJson(data);
        expect(json, isNotEmpty);
      });

      test('Export to XML', () async {
        final data = [{'id': '1', 'name': 'Test'}];
        final xml = await engine.exportToXml(data);
        expect(xml.contains('<?xml version'), true);
        expect(xml.contains('<root>'), true);
      });
    });

    group('MemoryReportEngine Tests', () {
      late MemoryReportEngine engine;

      setUp(() {
        engine = MemoryReportEngine();
      });

      test('Generate report', () async {
        final report = await engine.generateReport(
          ReportType.jobSummary,
          DateTime.now().subtract(Duration(days: 7)),
          DateTime.now(),
        );
        expect(report, isNotNull);
        expect(report.reportType, ReportType.jobSummary);
      });

      test('Render template', () async {
        final template = ReportTemplate(
          templateId: 'template1',
          templateName: 'Test',
          reportType: ReportType.jobSummary,
          htmlContent: 'Hello {{name}}',
          placeholders: {'name': ''},
          createdAt: DateTime.now(),
        );
        final rendered = await engine.renderTemplate(template, {'name': 'World'});
        expect(rendered.contains('World'), true);
      });
    });

    // ========== Manager Tests ==========
    group('MemoryExportManager Tests', () {
      late MemoryExportRepository repository;
      late MemoryExportEngine exportEngine;
      late MemoryReportEngine reportEngine;
      late MemoryExportManager manager;

      setUp(() {
        repository = MemoryExportRepository();
        exportEngine = MemoryExportEngine();
        reportEngine = MemoryReportEngine();
        manager = MemoryExportManager(repository, exportEngine, reportEngine);
      });

      test('Create export job', () async {
        final config = ExportConfiguration(
          configId: 'config1',
          name: 'Test',
          format: ExportFormat.csv,
          includeFields: [],
          excludeFields: [],
          includeHeaders: true,
          includeSummary: true,
          createdAt: DateTime.now(),
        );
        await repository.addConfiguration(config);
        
        final job = await manager.createExportJob(
          'config1',
          [{'id': '1'}, {'id': '2'}],
        );
        expect(job, isNotNull);
        expect(job.totalRecords, 2);
      });

      test('Schedule export', () async {
        await manager.scheduleExport(
          'config1',
          '0 0 * * *',
          ['user@example.com'],
        );
        expect(true, true);
      });

      test('Generate report', () async {
        final report = await manager.generateReport(
          ReportType.jobSummary,
          DateTime.now().subtract(Duration(days: 30)),
          DateTime.now(),
        );
        expect(report, isNotNull);
      });
    });

    // ========== Facade Tests ==========
    group('ExportFacade Tests', () {
      late ExportFacade facade;

      setUp(() {
        final repository = MemoryExportRepository();
        final exportEngine = MemoryExportEngine();
        final reportEngine = MemoryReportEngine();
        final manager = MemoryExportManager(repository, exportEngine, reportEngine);
        facade = ExportFacade(manager, repository, exportEngine, reportEngine);
      });

      test('Create configuration', () async {
        await facade.createConfiguration('Test CSV', ExportFormat.csv);
        final configs = await facade._repository.getAllConfigurations();
        expect(configs.isNotEmpty, true);
      });

      test('Generate report through facade', () async {
        final report = await facade.generateReport(
          ReportType.jobSummary,
          DateTime.now().subtract(Duration(days: 7)),
          DateTime.now(),
        );
        expect(report, isNotNull);
      });
    });

    // ========== Integration Tests ==========
    group('Integration Tests', () {
      late ExportFacade facade;

      setUp(() {
        final repository = MemoryExportRepository();
        final exportEngine = MemoryExportEngine();
        final reportEngine = MemoryReportEngine();
        final manager = MemoryExportManager(repository, exportEngine, reportEngine);
        facade = ExportFacade(manager, repository, exportEngine, reportEngine);
      });

      test('Complete export workflow', () async {
        await facade.createConfiguration('Complete', ExportFormat.json);
        final report = await facade.generateReport(
          ReportType.performanceAnalysis,
          DateTime.now().subtract(Duration(days: 1)),
          DateTime.now(),
        );
        expect(report.toMarkdown(), isNotEmpty);
      });

      test('Multiple exports workflow', () async {
        await facade.createConfiguration('CSV Export', ExportFormat.csv);
        await facade.createConfiguration('JSON Export', ExportFormat.json);
        final jobs = await facade.getAllJobs();
        expect(jobs, isNotEmpty);
      });

      test('Report generation workflow', () async {
        final report = await facade.generateReport(
          ReportType.executiveSummary,
          DateTime.now().subtract(Duration(days: 30)),
          DateTime.now(),
        );
        expect(report.reportType, ReportType.executiveSummary);
      });

      test('Export metrics calculation', () async {
        final metrics = await facade.calculateMetrics(
          DateTime.now().subtract(Duration(days: 7)),
          DateTime.now(),
        );
        expect(metrics.isHealthy, true);
      });
    });
  });
}
