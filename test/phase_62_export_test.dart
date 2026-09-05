import 'package:flutter_test/flutter_test.dart';
import '../lib/models/export_models.dart';
import '../lib/services/export_service.dart';

void main() {
  group('Phase 62: Data Export & Reporting Tests', () {
    late ExportFacade facade;
    late MemoryExportRepository repository;

    setUp(() {
      repository = MemoryExportRepository();
      final exportEngine = ExportEngine(repository: repository);
      final reportEngine = ReportEngine(repository: repository);
      final manager = ExportManager(
        repository: repository,
        exportEngine: exportEngine,
        reportEngine: reportEngine,
      );
      facade = ExportFacade(manager: manager);
    });

    group('Enum Tests', () {
      test('ExportFormat enum has all values', () {
        expect(ExportFormat.values.length, 4);
        expect(ExportFormat.values, contains(ExportFormat.csv));
        expect(ExportFormat.values, contains(ExportFormat.json));
        expect(ExportFormat.values, contains(ExportFormat.xml));
        expect(ExportFormat.values, contains(ExportFormat.pdf));
      });

      test('ReportStatus enum has all values', () {
        expect(ReportStatus.values.length, 4);
        expect(ReportStatus.values, contains(ReportStatus.pending));
        expect(ReportStatus.values, contains(ReportStatus.processing));
        expect(ReportStatus.values, contains(ReportStatus.completed));
        expect(ReportStatus.values, contains(ReportStatus.failed));
      });

      test('ScheduleFrequency enum has all values', () {
        expect(ScheduleFrequency.values.length, 4);
        expect(ScheduleFrequency.values, contains(ScheduleFrequency.daily));
        expect(ScheduleFrequency.values, contains(ScheduleFrequency.weekly));
        expect(ScheduleFrequency.values, contains(ScheduleFrequency.monthly));
        expect(ScheduleFrequency.values, contains(ScheduleFrequency.quarterly));
      });
    });

    group('ExportJob Model Tests', () {
      test('Create ExportJob with basic properties', () {
        final job = ExportJob(
          jobId: 'job1',
          dataSource: 'database',
          format: ExportFormat.csv,
          createdAt: DateTime.now(),
        );
        expect(job.jobId, 'job1');
        expect(job.dataSource, 'database');
        expect(job.format, ExportFormat.csv);
        expect(job.isCompleted, false);
      });

      test('ExportJob computed properties work correctly', () {
        final now = DateTime.now();
        final job = ExportJob(
          jobId: 'job1',
          dataSource: 'database',
          format: ExportFormat.csv,
          createdAt: now.subtract(Duration(days: 5)),
          completedAt: now,
          recordCount: 1000,
          isCompleted: true,
        );
        expect(job.isCompleted, true);
        expect(job.isRecent, true);
        expect(job.durationInSeconds, greaterThan(0));
      });

      test('ExportJob isRecent returns false for old jobs', () {
        final job = ExportJob(
          jobId: 'job1',
          dataSource: 'database',
          format: ExportFormat.csv,
          createdAt: DateTime.now().subtract(Duration(days: 40)),
        );
        expect(job.isRecent, false);
      });
    });

    group('Report Model Tests', () {
      test('Create Report with basic properties', () {
        final report = Report(
          reportId: 'rep1',
          title: 'Test Report',
          description: 'A test report',
          generatedAt: DateTime.now(),
          format: ExportFormat.pdf,
          pageCount: 10,
        );
        expect(report.reportId, 'rep1');
        expect(report.title, 'Test Report');
        expect(report.format, ExportFormat.pdf);
      });

      test('Report computed properties work', () {
        final now = DateTime.now();
        final report = Report(
          reportId: 'rep1',
          title: 'Test Report',
          description: 'A test report',
          generatedAt: now.subtract(Duration(days: 3)),
          format: ExportFormat.pdf,
        );
        expect(report.isRecent, true);
        expect(report.ageInDays, 3);
      });

      test('Report isRecent returns false for old reports', () {
        final report = Report(
          reportId: 'rep1',
          title: 'Test Report',
          description: 'A test report',
          generatedAt: DateTime.now().subtract(Duration(days: 10)),
          format: ExportFormat.pdf,
        );
        expect(report.isRecent, false);
      });
    });

    group('ScheduledReport Model Tests', () {
      test('Create ScheduledReport with basic properties', () {
        final schedule = ScheduledReport(
          scheduleId: 'sched1',
          reportId: 'rep1',
          frequency: ScheduleFrequency.daily,
        );
        expect(schedule.scheduleId, 'sched1');
        expect(schedule.reportId, 'rep1');
        expect(schedule.frequency, ScheduleFrequency.daily);
      });

      test('ScheduledReport hasRecipients works', () {
        final schedule1 = ScheduledReport(
          scheduleId: 'sched1',
          reportId: 'rep1',
          frequency: ScheduleFrequency.daily,
          recipients: ['user1@example.com'],
        );
        expect(schedule1.hasRecipients, true);

        final schedule2 = ScheduledReport(
          scheduleId: 'sched2',
          reportId: 'rep2',
          frequency: ScheduleFrequency.weekly,
        );
        expect(schedule2.hasRecipients, false);
      });

      test('ScheduledReport isDue works', () {
        final pastTime = DateTime.now().subtract(Duration(hours: 1));
        final schedule = ScheduledReport(
          scheduleId: 'sched1',
          reportId: 'rep1',
          frequency: ScheduleFrequency.daily,
          nextRun: pastTime,
        );
        expect(schedule.isDue, true);
      });
    });

    group('ExportFormatConfig Model Tests', () {
      test('Create ExportFormatConfig', () {
        final config = ExportFormatConfig(
          formatId: 'fmt1',
          formatName: 'CSV Export',
          extension: 'csv',
          options: {'delimiter': ','},
        );
        expect(config.formatId, 'fmt1');
        expect(config.formatName, 'CSV Export');
        expect(config.extension, 'csv');
        expect(config.hasAllOptions, true);
      });

      test('ExportFormatConfig hasAllOptions returns false for empty options', () {
        final config = ExportFormatConfig(
          formatId: 'fmt1',
          formatName: 'CSV Export',
          extension: 'csv',
          options: {},
        );
        expect(config.hasAllOptions, false);
      });
    });

    group('ReportTemplate Model Tests', () {
      test('Create ReportTemplate', () {
        final template = ReportTemplate(
          templateId: 'tmpl1',
          templateName: 'Monthly Report',
          description: 'Monthly business report',
          configuration: {'sections': ['summary', 'details']},
          createdAt: DateTime.now(),
        );
        expect(template.templateId, 'tmpl1');
        expect(template.templateName, 'Monthly Report');
        expect(template.isRecent, true);
      });
    });

    group('ExportStatistics Model Tests', () {
      test('Calculate success rate', () {
        final stats = ExportStatistics(
          statsId: 'stats1',
          totalExports: 100,
          successfulExports: 95,
          failedExports: 5,
          averageFileSize: 2048.0,
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
        );
        expect(stats.successRate, 95.0);
        expect(stats.isHealthy, true);
      });

      test('Calculate unhealthy success rate', () {
        final stats = ExportStatistics(
          statsId: 'stats2',
          totalExports: 100,
          successfulExports: 90,
          failedExports: 10,
          averageFileSize: 2048.0,
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
        );
        expect(stats.successRate, 90.0);
        expect(stats.isHealthy, false);
      });

      test('Handle zero exports', () {
        final stats = ExportStatistics(
          statsId: 'stats3',
          totalExports: 0,
          successfulExports: 0,
          failedExports: 0,
          averageFileSize: 0.0,
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
        );
        expect(stats.successRate, 0.0);
      });
    });

    group('ExportTask Model Tests', () {
      test('Create ExportTask', () {
        final task = ExportTask(
          taskId: 'task1',
          jobId: 'job1',
          status: 'processing',
          progress: 50,
          startedAt: DateTime.now(),
        );
        expect(task.taskId, 'task1');
        expect(task.progress, 50);
        expect(task.isCompleted, false);
      });

      test('ExportTask completion checks', () {
        final completedTask = ExportTask(
          taskId: 'task1',
          jobId: 'job1',
          status: 'completed',
          progress: 100,
          startedAt: DateTime.now(),
          finishedAt: DateTime.now(),
        );
        expect(completedTask.isCompleted, true);
        expect(completedTask.durationInSeconds, greaterThanOrEqualTo(0));
      });

      test('ExportTask error handling', () {
        final failedTask = ExportTask(
          taskId: 'task1',
          jobId: 'job1',
          status: 'failed',
          progress: 50,
          startedAt: DateTime.now(),
          errorMessage: 'Database connection failed',
        );
        expect(failedTask.hasError, true);
      });
    });

    group('ExportFilter Model Tests', () {
      test('Create ExportFilter', () {
        final filter = ExportFilter(
          filterId: 'filter1',
          fields: ['id', 'name', 'email'],
          conditions: {'status': 'active'},
          createdAt: DateTime.now(),
        );
        expect(filter.filterId, 'filter1');
        expect(filter.fieldCount, 3);
        expect(filter.hasFilters, true);
      });
    });

    group('ExportLog Model Tests', () {
      test('Create ExportLog', () {
        final log = ExportLog(
          logId: 'log1',
          jobId: 'job1',
          event: 'export_started',
          timestamp: DateTime.now(),
          metadata: {'recordCount': 1000},
        );
        expect(log.logId, 'log1');
        expect(log.event, 'export_started');
        expect(log.isRecent, true);
      });
    });

    group('ReportData Model Tests', () {
      test('Create ReportData', () {
        final data = ReportData(
          dataId: 'data1',
          reportId: 'rep1',
          rows: [
            {'id': 1, 'name': 'John'},
            {'id': 2, 'name': 'Jane'}
          ],
          columns: ['id', 'name'],
          totalRows: 2,
        );
        expect(data.dataId, 'data1');
        expect(data.hasData, true);
        expect(data.completeness, 100.0);
      });

      test('ReportData completeness calculation', () {
        final data = ReportData(
          dataId: 'data1',
          reportId: 'rep1',
          rows: [
            {'id': 1, 'name': 'John'},
          ],
          columns: ['id', 'name'],
          totalRows: 10,
        );
        expect(data.completeness, 10.0);
      });
    });

    group('ExportSchedule Model Tests', () {
      test('Create ExportSchedule', () {
        final schedule = ExportSchedule(
          scheduleId: 'sched1',
          jobId: 'job1',
          frequency: ScheduleFrequency.daily,
        );
        expect(schedule.scheduleId, 'sched1');
        expect(schedule.isEnabled, true);
        expect(schedule.hasExecuted, false);
      });
    });

    group('ExportNotification Model Tests', () {
      test('Create ExportNotification', () {
        final notification = ExportNotification(
          notificationId: 'notif1',
          exportJobId: 'job1',
          recipient: 'user@example.com',
          status: 'delivered',
          sentAt: DateTime.now(),
        );
        expect(notification.notificationId, 'notif1');
        expect(notification.isDelivered, true);
        expect(notification.hasFailed, false);
      });

      test('ExportNotification failure handling', () {
        final notification = ExportNotification(
          notificationId: 'notif1',
          exportJobId: 'job1',
          recipient: 'user@example.com',
          status: 'failed',
          sentAt: DateTime.now(),
          error: 'SMTP error',
        );
        expect(notification.hasFailed, true);
      });
    });

    group('Export Repository Tests', () {
      test('Create and retrieve ExportJob', () async {
        final job = ExportJob(
          jobId: 'job1',
          dataSource: 'database',
          format: ExportFormat.csv,
          createdAt: DateTime.now(),
        );
        await repository.createExportJob(job);
        final retrieved = await repository.getExportJob('job1');
        expect(retrieved, isNotNull);
        expect(retrieved?.jobId, 'job1');
      });

      test('Update ExportJob', () async {
        final job = ExportJob(
          jobId: 'job1',
          dataSource: 'database',
          format: ExportFormat.csv,
          createdAt: DateTime.now(),
          isCompleted: false,
        );
        await repository.createExportJob(job);

        final updated = ExportJob(
          jobId: 'job1',
          dataSource: 'database',
          format: ExportFormat.csv,
          createdAt: job.createdAt,
          isCompleted: true,
          completedAt: DateTime.now(),
        );
        await repository.updateExportJob(updated);

        final retrieved = await repository.getExportJob('job1');
        expect(retrieved?.isCompleted, true);
      });

      test('Delete ExportJob', () async {
        final job = ExportJob(
          jobId: 'job1',
          dataSource: 'database',
          format: ExportFormat.csv,
          createdAt: DateTime.now(),
        );
        await repository.createExportJob(job);
        await repository.deleteExportJob('job1');
        final retrieved = await repository.getExportJob('job1');
        expect(retrieved, isNull);
      });

      test('Get all ExportJobs', () async {
        await repository.createExportJob(ExportJob(
          jobId: 'job1',
          dataSource: 'database',
          format: ExportFormat.csv,
          createdAt: DateTime.now(),
        ));
        await repository.createExportJob(ExportJob(
          jobId: 'job2',
          dataSource: 'api',
          format: ExportFormat.json,
          createdAt: DateTime.now(),
        ));
        final all = await repository.getAllExportJobs();
        expect(all.length, 2);
      });

      test('Create and retrieve Report', () async {
        final report = Report(
          reportId: 'rep1',
          title: 'Test',
          description: 'Test report',
          generatedAt: DateTime.now(),
          format: ExportFormat.pdf,
        );
        await repository.createReport(report);
        final retrieved = await repository.getReport('rep1');
        expect(retrieved, isNotNull);
        expect(retrieved?.title, 'Test');
      });

      test('Create and retrieve Template', () async {
        final template = ReportTemplate(
          templateId: 'tmpl1',
          templateName: 'Monthly',
          description: 'Monthly report',
          configuration: {},
          createdAt: DateTime.now(),
        );
        await repository.createTemplate(template);
        final retrieved = await repository.getTemplate('tmpl1');
        expect(retrieved, isNotNull);
        expect(retrieved?.templateName, 'Monthly');
      });

      test('Save and retrieve Statistics', () async {
        final stats = ExportStatistics(
          statsId: 'stats1',
          totalExports: 100,
          successfulExports: 95,
          failedExports: 5,
          averageFileSize: 2048.0,
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
        );
        await repository.saveStatistics(stats);
        final retrieved = await repository.getStatistics('stats1');
        expect(retrieved, isNotNull);
        expect(retrieved?.successRate, 95.0);
      });

      test('Get statistics in date range', () async {
        final start = DateTime.now().subtract(Duration(days: 30));
        final end = DateTime.now();
        await repository.saveStatistics(ExportStatistics(
          statsId: 'stats1',
          totalExports: 100,
          successfulExports: 95,
          failedExports: 5,
          averageFileSize: 2048.0,
          periodStart: start,
          periodEnd: end,
        ));
        final results = await repository.getStatisticsInRange(start, end);
        expect(results.isNotEmpty, true);
      });

      test('Create and retrieve ExportTask', () async {
        await repository.createExportJob(ExportJob(
          jobId: 'job1',
          dataSource: 'database',
          format: ExportFormat.csv,
          createdAt: DateTime.now(),
        ));
        final task = ExportTask(
          taskId: 'task1',
          jobId: 'job1',
          status: 'processing',
          progress: 50,
          startedAt: DateTime.now(),
        );
        await repository.createTask(task);
        final retrieved = await repository.getTask('task1');
        expect(retrieved, isNotNull);
      });

      test('Get tasks by job', () async {
        await repository.createExportJob(ExportJob(
          jobId: 'job1',
          dataSource: 'database',
          format: ExportFormat.csv,
          createdAt: DateTime.now(),
        ));
        await repository.createTask(ExportTask(
          taskId: 'task1',
          jobId: 'job1',
          status: 'processing',
          progress: 50,
          startedAt: DateTime.now(),
        ));
        await repository.createTask(ExportTask(
          taskId: 'task2',
          jobId: 'job1',
          status: 'completed',
          progress: 100,
          startedAt: DateTime.now(),
        ));
        final tasks = await repository.getTasksByJob('job1');
        expect(tasks.length, 2);
      });

      test('Create and retrieve Filter', () async {
        final filter = ExportFilter(
          filterId: 'filter1',
          fields: ['id', 'name'],
          conditions: {'status': 'active'},
          createdAt: DateTime.now(),
        );
        await repository.createFilter(filter);
        final retrieved = await repository.getFilter('filter1');
        expect(retrieved, isNotNull);
        expect(retrieved?.fieldCount, 2);
      });

      test('Add and retrieve logs', () async {
        await repository.createExportJob(ExportJob(
          jobId: 'job1',
          dataSource: 'database',
          format: ExportFormat.csv,
          createdAt: DateTime.now(),
        ));
        await repository.addLog(ExportLog(
          logId: 'log1',
          jobId: 'job1',
          event: 'started',
          timestamp: DateTime.now(),
          metadata: {},
        ));
        final logs = await repository.getLogsByJob('job1');
        expect(logs.isNotEmpty, true);
      });

      test('Save and retrieve ReportData', () async {
        final data = ReportData(
          dataId: 'data1',
          reportId: 'rep1',
          rows: [{'id': 1}],
          columns: ['id'],
          totalRows: 1,
        );
        await repository.saveReportData(data);
        final retrieved = await repository.getReportData('data1');
        expect(retrieved, isNotNull);
      });

      test('Create and retrieve ExportSchedule', () async {
        final schedule = ExportSchedule(
          scheduleId: 'sched1',
          jobId: 'job1',
          frequency: ScheduleFrequency.daily,
        );
        await repository.createSchedule(schedule);
        final retrieved = await repository.getSchedule('sched1');
        expect(retrieved, isNotNull);
      });

      test('Get due schedules', () async {
        final pastTime = DateTime.now().subtract(Duration(hours: 1));
        final schedule = ExportSchedule(
          scheduleId: 'sched1',
          jobId: 'job1',
          frequency: ScheduleFrequency.daily,
          nextExecution: pastTime,
          isEnabled: true,
        );
        await repository.createSchedule(schedule);
        final due = await repository.getDueSchedules();
        expect(due.isNotEmpty, true);
      });

      test('Create and retrieve notification', () async {
        final notification = ExportNotification(
          notificationId: 'notif1',
          exportJobId: 'job1',
          recipient: 'user@example.com',
          status: 'delivered',
          sentAt: DateTime.now(),
        );
        await repository.createNotification(notification);
        final retrieved = await repository.getNotificationsByJob('job1');
        expect(retrieved.isNotEmpty, true);
      });
    });

    group('Export Engine Tests', () {
      test('Initialize export creates job', () async {
        final engine = ExportEngine(repository: repository);
        final job = await engine.initializeExport('database', ExportFormat.csv);
        expect(job.jobId, isNotEmpty);
        expect(job.format, ExportFormat.csv);
      });

      test('Process export updates job status', () async {
        final engine = ExportEngine(repository: repository);
        final job = await engine.initializeExport('database', ExportFormat.csv);
        await engine.processExport(job.jobId);
        final updated = await repository.getExportJob(job.jobId);
        expect(updated?.isCompleted, true);
      });

      test('Generate export content returns string', () async {
        final engine = ExportEngine(repository: repository);
        final job = ExportJob(
          jobId: 'job1',
          dataSource: 'database',
          format: ExportFormat.csv,
          createdAt: DateTime.now(),
        );
        final content = await engine.generateExportContent(job);
        expect(content, contains('Export content'));
      });
    });

    group('Report Engine Tests', () {
      test('Generate report creates report', () async {
        final engine = ReportEngine(repository: repository);
        final report = await engine.generateReport(
          'Test Report',
          'A test report',
          ExportFormat.pdf,
        );
        expect(report.reportId, isNotEmpty);
        expect(report.title, 'Test Report');
      });

      test('Schedule report generation', () async {
        final engine = ReportEngine(repository: repository);
        final report = await engine.generateReport(
          'Test Report',
          'A test report',
          ExportFormat.pdf,
        );
        await engine.scheduleReportGeneration(report.reportId, ScheduleFrequency.daily);
        final schedules = await engine.getScheduledReports();
        expect(schedules.isNotEmpty, true);
      });
    });

    group('Export Manager Tests', () {
      test('Initiate export', () async {
        final result = await facade.startExport('database', ExportFormat.csv);
        expect(result.jobId, isNotEmpty);
      });

      test('Execute export', () async {
        final job = await facade.startExport('database', ExportFormat.csv);
        await facade.processExportJob(job.jobId);
        final status = await facade.getExportStatus(job.jobId);
        expect(status?.isCompleted, true);
      });

      test('List exports', () async {
        await facade.startExport('database', ExportFormat.csv);
        await facade.startExport('api', ExportFormat.json);
        final exports = await facade.listExports();
        expect(exports.length, greaterThanOrEqualTo(2));
      });

      test('Generate report', () async {
        final report = await facade.generateReport(
          'Test Report',
          'Test description',
          ExportFormat.pdf,
        );
        expect(report.reportId, isNotEmpty);
      });

      test('Create template', () async {
        final template = await facade.createTemplate(
          'Monthly Report',
          'Monthly business report',
          {'sections': ['summary', 'details']},
        );
        expect(template.templateId, isNotEmpty);
        expect(template.templateName, 'Monthly Report');
      });

      test('Get statistics', () async {
        await facade.startExport('database', ExportFormat.csv);
        final start = DateTime.now().subtract(Duration(days: 1));
        final end = DateTime.now().add(Duration(days: 1));
        final stats = await facade.getStatistics(start, end);
        expect(stats.totalExports, greaterThanOrEqualTo(1));
      });
    });

    group('Export Facade Integration Tests', () {
      test('Complete export workflow', () async {
        // Start export
        final job = await facade.startExport('database', ExportFormat.csv);
        expect(job.jobId, isNotEmpty);

        // Process export
        await facade.processExportJob(job.jobId);

        // Check status
        final status = await facade.getExportStatus(job.jobId);
        expect(status?.isCompleted, true);

        // List exports
        final all = await facade.listExports();
        expect(all.isNotEmpty, true);
      });

      test('Complete report workflow', () async {
        // Generate report
        final report = await facade.generateReport(
          'Monthly Report',
          'Monthly business report',
          ExportFormat.pdf,
        );

        // Setup recurring
        await facade.setupRecurringReport(report.reportId, ScheduleFrequency.monthly);

        // Get scheduled reports
        final scheduled = await facade.getScheduledReports();
        expect(scheduled.isNotEmpty, true);
      });

      test('Template management', () async {
        // Create template
        final template = await facade.createTemplate(
          'Standard Report',
          'Standard report template',
          {'sections': ['intro', 'data', 'conclusion']},
        );

        // Retrieve template
        final retrieved = await facade.getTemplate(template.templateId);
        expect(retrieved, isNotNull);

        // List templates
        final all = await facade.listTemplates();
        expect(all.isNotEmpty, true);
      });

      test('Logging functionality', () async {
        final job = await facade.startExport('database', ExportFormat.csv);
        await facade.addExportLog(job.jobId, 'export_started', {'format': 'csv'});
        await facade.addExportLog(job.jobId, 'export_completed', {'records': 1000});

        final logs = await facade.getExportLogs(job.jobId);
        expect(logs.length, 2);
      });

      test('Multiple exports simultaneously', () async {
        final job1 = await facade.startExport('database', ExportFormat.csv);
        final job2 = await facade.startExport('api', ExportFormat.json);
        final job3 = await facade.startExport('cache', ExportFormat.xml);

        final all = await facade.listExports();
        expect(all.length, greaterThanOrEqualTo(3));
      });

      test('Export formats variety', () async {
        await facade.startExport('source1', ExportFormat.csv);
        await facade.startExport('source2', ExportFormat.json);
        await facade.startExport('source3', ExportFormat.xml);
        await facade.startExport('source4', ExportFormat.pdf);

        final all = await facade.listExports();
        expect(all.length, 4);
      });

      test('Schedule frequencies variety', () async {
        final report = await facade.generateReport(
          'Report',
          'Description',
          ExportFormat.pdf,
        );

        final scheduleId = 'sched_${DateTime.now().millisecondsSinceEpoch}';
        await repository.createScheduledReport(ScheduledReport(
          scheduleId: scheduleId,
          reportId: report.reportId,
          frequency: ScheduleFrequency.daily,
        ));

        final scheduled = await facade.getScheduledReports();
        expect(scheduled.isNotEmpty, true);
      });
    });

    group('Edge Cases & Error Handling', () {
      test('Handle missing export job', () async {
        final result = await facade.getExportStatus('nonexistent');
        expect(result, isNull);
      });

      test('Handle missing report', () async {
        final result = await repository.getReport('nonexistent');
        expect(result, isNull);
      });

      test('Handle missing template', () async {
        final result = await facade.getTemplate('nonexistent');
        expect(result, isNull);
      });

      test('Export with special characters', () async {
        final job = await facade.startExport('database@source', ExportFormat.csv);
        expect(job.dataSource, contains('@'));
      });

      test('Large export job handling', () async {
        final job = ExportJob(
          jobId: 'large_export',
          dataSource: 'huge_database',
          format: ExportFormat.csv,
          createdAt: DateTime.now(),
          recordCount: 1000000,
        );
        await repository.createExportJob(job);
        final retrieved = await repository.getExportJob('large_export');
        expect(retrieved?.recordCount, 1000000);
      });

      test('Handle concurrent operations', () async {
        final futures = List.generate(5, (i) => facade.startExport('db_$i', ExportFormat.csv));
        final results = await Future.wait(futures);
        expect(results.length, 5);
      });

      test('Statistics with edge values', () async {
        final stats = ExportStatistics(
          statsId: 'edge_stats',
          totalExports: 1,
          successfulExports: 1,
          failedExports: 0,
          averageFileSize: 0.0,
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
        );
        expect(stats.successRate, 100.0);
        expect(stats.isHealthy, true);
      });

      test('Empty filter handling', () async {
        final filter = ExportFilter(
          filterId: 'empty_filter',
          fields: [],
          conditions: {},
          createdAt: DateTime.now(),
        );
        expect(filter.hasFilters, false);
        expect(filter.fieldCount, 0);
      });
    });
  });
}
