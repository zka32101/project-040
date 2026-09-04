import 'package:flutter_test/flutter_test.dart';
import '../lib/models/export_models.dart';
import '../lib/services/export_service.dart';

void main() {
  group('Phase 49: Data Export & Reporting System Tests', () {
    // ==================== Enum Tests ====================
    group('Enum Tests', () {
      test('ExportFormat has all required values', () {
        expect(ExportFormat.csv.value, 'csv');
        expect(ExportFormat.json.value, 'json');
        expect(ExportFormat.pdf.value, 'pdf');
        expect(ExportFormat.excel.value, 'excel');
        expect(ExportFormat.markdown.value, 'markdown');
        expect(ExportFormat.xml.value, 'xml');
      });

      test('ExportStatus has all required values', () {
        expect(ExportStatus.pending.value, 'pending');
        expect(ExportStatus.processing.value, 'processing');
        expect(ExportStatus.completed.value, 'completed');
        expect(ExportStatus.failed.value, 'failed');
        expect(ExportStatus.cancelled.value, 'cancelled');
      });

      test('ReportType has all required values', () {
        expect(ReportType.summary.value, 'summary');
        expect(ReportType.detailed.value, 'detailed');
        expect(ReportType.trend.value, 'trend');
        expect(ReportType.comparative.value, 'comparative');
        expect(ReportType.custom.value, 'custom');
      });

      test('ScheduleFrequency has all required values', () {
        expect(ScheduleFrequency.oneTime.value, 'one_time');
        expect(ScheduleFrequency.daily.value, 'daily');
        expect(ScheduleFrequency.weekly.value, 'weekly');
        expect(ScheduleFrequency.monthly.value, 'monthly');
        expect(ScheduleFrequency.quarterly.value, 'quarterly');
      });
    });

    // ==================== Model Tests ====================
    group('Model Tests', () {
      test('ExportJob properties are set correctly', () {
        final job = ExportJob(
          jobId: 'job1',
          userId: 'user1',
          resourceType: 'feedback',
          format: ExportFormat.csv,
          status: ExportStatus.completed,
          createdAt: DateTime.now(),
          filePath: '/exports/file.csv',
          fileSize: 1024,
        );

        expect(job.jobId, 'job1');
        expect(job.format, ExportFormat.csv);
        expect(job.isCompleted, true);
        expect(job.isFailed, false);
      });

      test('ExportJob.processingTime calculates correctly', () {
        final now = DateTime.now();
        final startTime = now.subtract(Duration(minutes: 5));
        final endTime = now;

        final job = ExportJob(
          jobId: 'job1',
          userId: 'user1',
          resourceType: 'feedback',
          format: ExportFormat.csv,
          status: ExportStatus.completed,
          createdAt: now.subtract(Duration(hours: 1)),
          startedAt: startTime,
          completedAt: endTime,
        );

        expect(job.processingTime?.inMinutes, greaterThanOrEqualTo(5));
      });

      test('ExportRequest.isHighPriority works correctly', () {
        final request1 = ExportRequest(
          requestId: 'r1',
          userId: 'user1',
          resourceType: 'job',
          resourceIds: ['job1'],
          format: ExportFormat.json,
          priority: 5,
          requestedAt: DateTime.now(),
        );

        final request2 = ExportRequest(
          requestId: 'r2',
          userId: 'user1',
          resourceType: 'job',
          resourceIds: ['job1'],
          format: ExportFormat.json,
          priority: 2,
          requestedAt: DateTime.now(),
        );

        expect(request1.isHighPriority, true);
        expect(request2.isHighPriority, false);
      });

      test('ExportRequest.resourceCount returns correct count', () {
        final request = ExportRequest(
          requestId: 'r1',
          userId: 'user1',
          resourceType: 'job',
          resourceIds: ['job1', 'job2', 'job3'],
          format: ExportFormat.json,
          requestedAt: DateTime.now(),
        );

        expect(request.resourceCount, 3);
      });

      test('ReportTemplate.sectionCount returns correct count', () {
        final template = ReportTemplate(
          templateId: 't1',
          name: 'Test Report',
          description: 'Test',
          type: ReportType.summary,
          sections: ['Summary', 'Details', 'Trends', 'Recommendations'],
          createdAt: DateTime.now(),
        );

        expect(template.sectionCount, 4);
        expect(template.isEnabled, true);
      });

      test('ScheduledReport.isScheduled works correctly', () {
        final futureTime = DateTime.now().add(Duration(days: 1));

        final report = ScheduledReport(
          reportId: 'sr1',
          templateId: 't1',
          userId: 'user1',
          frequency: ScheduleFrequency.daily,
          format: ExportFormat.pdf,
          nextRunTime: futureTime,
          createdAt: DateTime.now(),
        );

        expect(report.isScheduled, true);
      });

      test('ScheduledReport.timeUntilNextRun calculates correctly', () {
        final futureTime = DateTime.now().add(Duration(hours: 2));

        final report = ScheduledReport(
          reportId: 'sr1',
          templateId: 't1',
          userId: 'user1',
          frequency: ScheduleFrequency.daily,
          format: ExportFormat.pdf,
          nextRunTime: futureTime,
          createdAt: DateTime.now(),
        );

        expect(report.timeUntilNextRun?.inHours, greaterThanOrEqualTo(1));
      });

      test('ReportGeneration.isGenerated checks completion', () {
        final generation = ReportGeneration(
          generationId: 'g1',
          reportId: 'r1',
          type: ReportType.summary,
          status: ExportStatus.completed,
          generatedAt: DateTime.now(),
          content: 'Report content here',
          contentLength: 100,
        );

        expect(generation.isGenerated, true);
      });

      test('ReportGeneration.isLarge identifies large reports', () {
        final generation = ReportGeneration(
          generationId: 'g1',
          reportId: 'r1',
          type: ReportType.detailed,
          status: ExportStatus.completed,
          generatedAt: DateTime.now(),
          content: 'x' * 2000000,
          contentLength: 2000000,
        );

        expect(generation.isLarge, true);
      });

      test('ReportStats.failureRate calculates correctly', () {
        final stats = ReportStats(
          statsId: 's1',
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          totalReports: 10,
          successfulReports: 9,
          failedReports: 1,
          reportsByType: {},
          reportsByFormat: {},
          averageGenerationTime: 0.5,
          successRate: 0.9,
        );

        expect(stats.failureRate, 0.1);
      });

      test('ReportStats.mostUsedType returns correct type', () {
        final stats = ReportStats(
          statsId: 's1',
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          totalReports: 10,
          successfulReports: 9,
          failedReports: 1,
          reportsByType: {
            ReportType.summary: 5,
            ReportType.detailed: 3,
            ReportType.trend: 2,
          },
          reportsByFormat: {},
          averageGenerationTime: 0.5,
          successRate: 0.9,
        );

        expect(stats.mostUsedType, ReportType.summary);
      });

      test('ExportHistory.successRate calculates correctly', () {
        final exports = [
          ExportJob(
            jobId: 'j1',
            userId: 'user1',
            resourceType: 'job',
            format: ExportFormat.csv,
            status: ExportStatus.completed,
            createdAt: DateTime.now(),
          ),
          ExportJob(
            jobId: 'j2',
            userId: 'user1',
            resourceType: 'job',
            format: ExportFormat.csv,
            status: ExportStatus.failed,
            createdAt: DateTime.now(),
          ),
        ];

        final history = ExportHistory(
          historyId: 'h1',
          userId: 'user1',
          exports: exports,
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
        );

        expect(history.successRate, 0.5);
      });

      test('ExportHistory.totalFileSize sums file sizes', () {
        final exports = [
          ExportJob(
            jobId: 'j1',
            userId: 'user1',
            resourceType: 'job',
            format: ExportFormat.csv,
            status: ExportStatus.completed,
            createdAt: DateTime.now(),
            fileSize: 1000,
          ),
          ExportJob(
            jobId: 'j2',
            userId: 'user1',
            resourceType: 'job',
            format: ExportFormat.csv,
            status: ExportStatus.completed,
            createdAt: DateTime.now(),
            fileSize: 2000,
          ),
        ];

        final history = ExportHistory(
          historyId: 'h1',
          userId: 'user1',
          exports: exports,
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
        );

        expect(history.totalFileSize, 3000);
      });

      test('ExportReportSummary.toMarkdown generates valid markdown', () {
        final exports = [
          ExportJob(
            jobId: 'j1',
            userId: 'user1',
            resourceType: 'job',
            format: ExportFormat.csv,
            status: ExportStatus.completed,
            createdAt: DateTime.now(),
            fileSize: 1000,
          ),
        ];

        final history = ExportHistory(
          historyId: 'h1',
          userId: 'user1',
          exports: exports,
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
        );

        final stats = ReportStats(
          statsId: 's1',
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          totalReports: 1,
          successfulReports: 1,
          failedReports: 0,
          reportsByType: {},
          reportsByFormat: {},
          averageGenerationTime: 0.5,
          successRate: 1.0,
        );

        final summary = ExportReportSummary(
          summaryId: 'sum1',
          generatedAt: DateTime.now(),
          exportHistory: history,
          reportStats: stats,
        );

        final markdown = summary.toMarkdown();
        expect(markdown.contains('# Export & Reporting Summary'), true);
        expect(markdown.contains('Total Exports'), true);
      });
    });

    // ==================== Repository Tests ====================
    group('Repository Tests', () {
      late ExportRepository repository;

      setUp(() {
        repository = MemoryExportRepository();
      });

      test('addJob and getJob work correctly', () async {
        final job = ExportJob(
          jobId: 'j1',
          userId: 'user1',
          resourceType: 'job',
          format: ExportFormat.csv,
          status: ExportStatus.pending,
          createdAt: DateTime.now(),
        );

        await repository.addJob(job);
        final retrieved = await repository.getJob('j1');

        expect(retrieved?.jobId, 'j1');
      });

      test('getJobsByUser filters correctly', () async {
        final job1 = ExportJob(
          jobId: 'j1',
          userId: 'user1',
          resourceType: 'job',
          format: ExportFormat.csv,
          status: ExportStatus.completed,
          createdAt: DateTime.now(),
        );
        final job2 = ExportJob(
          jobId: 'j2',
          userId: 'user2',
          resourceType: 'job',
          format: ExportFormat.json,
          status: ExportStatus.completed,
          createdAt: DateTime.now(),
        );

        await repository.addJob(job1);
        await repository.addJob(job2);

        final jobs = await repository.getJobsByUser('user1');
        expect(jobs.length, 1);
      });

      test('getJobsByStatus filters correctly', () async {
        final job1 = ExportJob(
          jobId: 'j1',
          userId: 'user1',
          resourceType: 'job',
          format: ExportFormat.csv,
          status: ExportStatus.completed,
          createdAt: DateTime.now(),
        );
        final job2 = ExportJob(
          jobId: 'j2',
          userId: 'user1',
          resourceType: 'job',
          format: ExportFormat.csv,
          status: ExportStatus.failed,
          createdAt: DateTime.now(),
        );

        await repository.addJob(job1);
        await repository.addJob(job2);

        final jobs = await repository.getJobsByStatus(ExportStatus.completed);
        expect(jobs.length, 1);
      });

      test('getJobsByFormat filters correctly', () async {
        final job1 = ExportJob(
          jobId: 'j1',
          userId: 'user1',
          resourceType: 'job',
          format: ExportFormat.csv,
          status: ExportStatus.completed,
          createdAt: DateTime.now(),
        );
        final job2 = ExportJob(
          jobId: 'j2',
          userId: 'user1',
          resourceType: 'job',
          format: ExportFormat.json,
          status: ExportStatus.completed,
          createdAt: DateTime.now(),
        );

        await repository.addJob(job1);
        await repository.addJob(job2);

        final jobs = await repository.getJobsByFormat(ExportFormat.csv);
        expect(jobs.length, 1);
      });

      test('addRequest and getRequest work correctly', () async {
        final request = ExportRequest(
          requestId: 'r1',
          userId: 'user1',
          resourceType: 'job',
          resourceIds: ['job1'],
          format: ExportFormat.csv,
          requestedAt: DateTime.now(),
        );

        await repository.addRequest(request);
        final retrieved = await repository.getRequest('r1');

        expect(retrieved?.requestId, 'r1');
      });

      test('addTemplate and getTemplate work correctly', () async {
        final template = ReportTemplate(
          templateId: 't1',
          name: 'Test',
          description: 'Test Template',
          type: ReportType.summary,
          sections: ['Section1'],
          createdAt: DateTime.now(),
        );

        await repository.addTemplate(template);
        final retrieved = await repository.getTemplate('t1');

        expect(retrieved?.templateId, 't1');
      });

      test('addScheduledReport and getScheduledReport work correctly', () async {
        final report = ScheduledReport(
          reportId: 'sr1',
          templateId: 't1',
          userId: 'user1',
          frequency: ScheduleFrequency.daily,
          format: ExportFormat.pdf,
          nextRunTime: DateTime.now().add(Duration(days: 1)),
          createdAt: DateTime.now(),
        );

        await repository.addScheduledReport(report);
        final retrieved = await repository.getScheduledReport('sr1');

        expect(retrieved?.reportId, 'sr1');
      });

      test('getActiveSchedules returns only active schedules', () async {
        final report1 = ScheduledReport(
          reportId: 'sr1',
          templateId: 't1',
          userId: 'user1',
          frequency: ScheduleFrequency.daily,
          format: ExportFormat.pdf,
          nextRunTime: DateTime.now().add(Duration(days: 1)),
          isActive: true,
          createdAt: DateTime.now(),
        );
        final report2 = ScheduledReport(
          reportId: 'sr2',
          templateId: 't1',
          userId: 'user1',
          frequency: ScheduleFrequency.weekly,
          format: ExportFormat.pdf,
          nextRunTime: DateTime.now().add(Duration(days: 7)),
          isActive: false,
          createdAt: DateTime.now(),
        );

        await repository.addScheduledReport(report1);
        await repository.addScheduledReport(report2);

        final active = await repository.getActiveSchedules();
        expect(active.length, 1);
      });
    });

    // ==================== Engine Tests ====================
    group('Engine Tests', () {
      late ReportEngine engine;

      setUp(() {
        engine = MemoryReportEngine();
      });

      test('createTemplate creates template correctly', () async {
        final template = await engine.createTemplate(
          't1',
          'Test Report',
          'Description',
          ReportType.summary,
          ['Section1', 'Section2'],
        );

        expect(template.templateId, 't1');
        expect(template.sectionCount, 2);
      });

      test('generateReport produces report content', () async {
        final template = await engine.createTemplate(
          't1',
          'Test Report',
          'Description',
          ReportType.summary,
          ['Summary', 'Details'],
        );

        final data = {'Summary': 'Test summary', 'Details': 'Test details'};
        final report = await engine.generateReport('g1', template, data);

        expect(report.isGenerated, true);
        expect(report.content?.contains('Summary'), true);
      });

      test('calculateStats computes metrics', () async {
        final reports = [
          ReportGeneration(
            generationId: 'g1',
            reportId: 'r1',
            type: ReportType.summary,
            status: ExportStatus.completed,
            generatedAt: DateTime.now().subtract(Duration(days: 5)),
          ),
          ReportGeneration(
            generationId: 'g2',
            reportId: 'r2',
            type: ReportType.detailed,
            status: ExportStatus.completed,
            generatedAt: DateTime.now().subtract(Duration(days: 3)),
          ),
        ];

        final stats = await engine.calculateStats(
          reports,
          DateTime.now().subtract(Duration(days: 10)),
          DateTime.now(),
        );

        expect(stats.successRate, 1.0);
      });

      test('generateRecommendations creates recommendations', () async {
        final stats = ReportStats(
          statsId: 's1',
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          totalReports: 10,
          successfulReports: 8,
          failedReports: 2,
          reportsByType: {},
          reportsByFormat: {},
          averageGenerationTime: 0.5,
          successRate: 0.8,
        );

        final recommendations = await engine.generateRecommendations(stats);

        expect(recommendations.isNotEmpty, true);
      });
    });

    // ==================== Manager Tests ====================
    group('Manager Tests', () {
      late MemoryExportManager manager;

      setUp(() {
        manager = MemoryExportManager(
          repository: MemoryExportRepository(),
          reportEngine: MemoryReportEngine(),
        );
      });

      test('createExportJob creates job correctly', () async {
        final job = await manager.createExportJob(
          'j1',
          'user1',
          'feedback',
          ExportFormat.csv,
        );

        expect(job.jobId, 'j1');
        expect(job.status, ExportStatus.pending);
      });

      test('updateJobProgress updates progress', () async {
        await manager.createExportJob('j1', 'user1', 'feedback', ExportFormat.csv);
        final updated = await manager.updateJobProgress('j1', 0.5);

        expect(updated.progress, 0.5);
        expect(updated.status, ExportStatus.processing);
      });

      test('completeJob marks job completed', () async {
        await manager.createExportJob('j1', 'user1', 'feedback', ExportFormat.csv);
        final completed = await manager.completeJob('j1', '/path/file.csv', 1024);

        expect(completed.isCompleted, true);
        expect(completed.progress, 1.0);
      });

      test('failJob marks job failed', () async {
        await manager.createExportJob('j1', 'user1', 'feedback', ExportFormat.csv);
        final failed = await manager.failJob('j1', 'Export failed');

        expect(failed.isFailed, true);
        expect(failed.errorMessage, 'Export failed');
      });

      test('createScheduledReport schedules correctly', () async {
        final report = await manager.createScheduledReport(
          'sr1',
          't1',
          'user1',
          ScheduleFrequency.daily,
          ExportFormat.pdf,
        );

        expect(report.reportId, 'sr1');
        expect(report.isScheduled, true);
      });
    });

    // ==================== Facade Tests ====================
    group('Facade Tests', () {
      late ExportManagerFacade facade;

      setUp(() {
        facade = ExportManagerFacade();
      });

      test('createExportJob creates job via facade', () async {
        final job = await facade.createExportJob('j1', 'user1', 'feedback', ExportFormat.csv);

        expect(job.jobId, 'j1');
      });

      test('updateJobProgress updates progress', () async {
        await facade.createExportJob('j1', 'user1', 'feedback', ExportFormat.csv);
        final updated = await facade.updateJobProgress('j1', 0.75);

        expect(updated.progress, 0.75);
      });

      test('completeJob completes export', () async {
        await facade.createExportJob('j1', 'user1', 'feedback', ExportFormat.csv);
        final completed = await facade.completeJob('j1', '/exports/file.csv', 2048);

        expect(completed.isCompleted, true);
      });

      test('createTemplate creates template via facade', () async {
        final template = await facade.createTemplate(
          't1',
          'Report',
          'Description',
          ReportType.summary,
          ['Summary', 'Details'],
        );

        expect(template.templateId, 't1');
      });

      test('generateReport generates report via facade', () async {
        final template = await facade.createTemplate(
          't1',
          'Report',
          'Description',
          ReportType.summary,
          ['Summary'],
        );

        final report = await facade.generateReport(
          'g1',
          template,
          {'Summary': 'Test'},
        );

        expect(report.isGenerated, true);
      });

      test('scheduleReport schedules report', () async {
        final report = await facade.scheduleReport(
          'sr1',
          't1',
          'user1',
          ScheduleFrequency.weekly,
          ExportFormat.pdf,
        );

        expect(report.reportId, 'sr1');
      });

      test('getJobsByUser retrieves user jobs', () async {
        await facade.createExportJob('j1', 'user1', 'feedback', ExportFormat.csv);
        await facade.createExportJob('j2', 'user1', 'feedback', ExportFormat.json);

        final jobs = await facade.getJobsByUser('user1');

        expect(jobs.length, 2);
      });

      test('getActiveSchedules retrieves active schedules', () async {
        await facade.scheduleReport('sr1', 't1', 'user1', ScheduleFrequency.daily, ExportFormat.pdf);

        final schedules = await facade.getActiveSchedules();

        expect(schedules.isNotEmpty, true);
      });
    });

    // ==================== Integration Tests ====================
    group('Integration Tests', () {
      late ExportManagerFacade facade;

      setUp(() {
        facade = ExportManagerFacade();
      });

      test('End-to-end export workflow', () async {
        // Create export job
        final job = await facade.createExportJob('j1', 'user1', 'feedback', ExportFormat.csv);
        expect(job.status, ExportStatus.pending);

        // Update progress
        var updated = await facade.updateJobProgress('j1', 0.5);
        expect(updated.progress, 0.5);

        // Complete job
        final completed = await facade.completeJob('j1', '/exports/data.csv', 5000);
        expect(completed.isCompleted, true);

        // Get history
        final history = await facade.getExportHistory(
          'h1',
          'user1',
          DateTime.now().subtract(Duration(hours: 1)),
          DateTime.now(),
        );

        expect(history.successCount, 1);
      });

      test('Report generation workflow', () async {
        // Create template
        final template = await facade.createTemplate(
          't1',
          'Performance Report',
          'Monthly performance metrics',
          ReportType.detailed,
          ['Overview', 'Metrics', 'Trends', 'Recommendations'],
        );

        expect(template.sectionCount, 4);

        // Generate report
        final data = {
          'Overview': 'Overall performance is good',
          'Metrics': 'CPU: 60%, Memory: 50%',
          'Trends': 'Upward trend in performance',
          'Recommendations': 'Continue monitoring',
        };

        final report = await facade.generateReport('g1', template, data);
        expect(report.isGenerated, true);
      });

      test('Scheduled reporting workflow', () async {
        // Create template
        await facade.createTemplate(
          't1',
          'Weekly Report',
          'Weekly summary',
          ReportType.summary,
          ['Summary'],
        );

        // Schedule report
        final scheduled = await facade.scheduleReport(
          'sr1',
          't1',
          'user1',
          ScheduleFrequency.weekly,
          ExportFormat.pdf,
        );

        expect(scheduled.isScheduled, true);

        // Get active schedules
        final schedules = await facade.getActiveSchedules();
        expect(schedules.isNotEmpty, true);
      });

      test('Summary generation workflow', () async {
        // Create multiple jobs
        await facade.createExportJob('j1', 'user1', 'feedback', ExportFormat.csv);
        await facade.createExportJob('j2', 'user1', 'metrics', ExportFormat.json);

        // Generate summary
        final summary = await facade.generateSummary(
          'sum1',
          'user1',
          DateTime.now().subtract(Duration(hours: 1)),
          DateTime.now(),
        );

        expect(summary.summaryId, 'sum1');
        expect(summary.exportHistory.exportCount, greaterThan(0));
      });

      test('Multiple user export tracking', () async {
        // Create jobs for multiple users
        await facade.createExportJob('j1', 'user1', 'feedback', ExportFormat.csv);
        await facade.createExportJob('j2', 'user1', 'metrics', ExportFormat.json);
        await facade.createExportJob('j3', 'user2', 'feedback', ExportFormat.pdf);

        // Get jobs for each user
        final user1Jobs = await facade.getJobsByUser('user1');
        final user2Jobs = await facade.getJobsByUser('user2');

        expect(user1Jobs.length, 2);
        expect(user2Jobs.length, 1);
      });
    });
  });
}
