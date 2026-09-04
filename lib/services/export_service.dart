/// Phase 49: Data Export & Reporting Service データエクスポート・レポートサービス

import '../models/export_models.dart';

/// エクスポートリポジトリ インターフェース
abstract class ExportRepository {
  Future<ExportJob> addJob(ExportJob job);
  Future<ExportJob?> getJob(String jobId);
  Future<List<ExportJob>> getJobsByUser(String userId);
  Future<List<ExportJob>> getJobsByStatus(ExportStatus status);
  Future<List<ExportJob>> getJobsByFormat(ExportFormat format);
  Future<ExportRequest> addRequest(ExportRequest request);
  Future<ExportRequest?> getRequest(String requestId);
  Future<List<ExportRequest>> getRequestsByUser(String userId);
  Future<ReportTemplate> addTemplate(ReportTemplate template);
  Future<ReportTemplate?> getTemplate(String templateId);
  Future<List<ReportTemplate>> getAllTemplates();
  Future<ScheduledReport> addScheduledReport(ScheduledReport report);
  Future<ScheduledReport?> getScheduledReport(String reportId);
  Future<List<ScheduledReport>> getActiveSchedules();
  Future<ExportHistory> createHistory(ExportHistory history);
  Future<ExportHistory?> getHistory(String historyId);
  Future<void> clearAll();
}

/// メモリエクスポートリポジトリ実装
class MemoryExportRepository implements ExportRepository {
  final Map<String, ExportJob> _jobs = {};
  final Map<String, ExportRequest> _requests = {};
  final Map<String, ReportTemplate> _templates = {};
  final Map<String, ScheduledReport> _schedules = {};
  final Map<String, ExportHistory> _histories = {};

  @override
  Future<ExportJob> addJob(ExportJob job) async {
    _jobs[job.jobId] = job;
    return job;
  }

  @override
  Future<ExportJob?> getJob(String jobId) async {
    return _jobs[jobId];
  }

  @override
  Future<List<ExportJob>> getJobsByUser(String userId) async {
    return _jobs.values.where((j) => j.userId == userId).toList();
  }

  @override
  Future<List<ExportJob>> getJobsByStatus(ExportStatus status) async {
    return _jobs.values.where((j) => j.status == status).toList();
  }

  @override
  Future<List<ExportJob>> getJobsByFormat(ExportFormat format) async {
    return _jobs.values.where((j) => j.format == format).toList();
  }

  @override
  Future<ExportRequest> addRequest(ExportRequest request) async {
    _requests[request.requestId] = request;
    return request;
  }

  @override
  Future<ExportRequest?> getRequest(String requestId) async {
    return _requests[requestId];
  }

  @override
  Future<List<ExportRequest>> getRequestsByUser(String userId) async {
    return _requests.values.where((r) => r.userId == userId).toList();
  }

  @override
  Future<ReportTemplate> addTemplate(ReportTemplate template) async {
    _templates[template.templateId] = template;
    return template;
  }

  @override
  Future<ReportTemplate?> getTemplate(String templateId) async {
    return _templates[templateId];
  }

  @override
  Future<List<ReportTemplate>> getAllTemplates() async {
    return _templates.values.toList();
  }

  @override
  Future<ScheduledReport> addScheduledReport(ScheduledReport report) async {
    _schedules[report.reportId] = report;
    return report;
  }

  @override
  Future<ScheduledReport?> getScheduledReport(String reportId) async {
    return _schedules[reportId];
  }

  @override
  Future<List<ScheduledReport>> getActiveSchedules() async {
    return _schedules.values.where((s) => s.isActive).toList();
  }

  @override
  Future<ExportHistory> createHistory(ExportHistory history) async {
    _histories[history.historyId] = history;
    return history;
  }

  @override
  Future<ExportHistory?> getHistory(String historyId) async {
    return _histories[historyId];
  }

  @override
  Future<void> clearAll() async {
    _jobs.clear();
    _requests.clear();
    _templates.clear();
    _schedules.clear();
    _histories.clear();
  }
}

/// レポートエンジン インターフェース
abstract class ReportEngine {
  Future<ReportTemplate> createTemplate(String templateId, String name, String description, ReportType type, List<String> sections);
  Future<ReportGeneration> generateReport(String generationId, ReportTemplate template, Map<String, dynamic> data);
  Future<ReportStats> calculateStats(List<ReportGeneration> reports, DateTime start, DateTime end);
  Future<List<String>> generateRecommendations(ReportStats stats);
}

/// メモリレポートエンジン実装
class MemoryReportEngine implements ReportEngine {
  final Map<String, ReportTemplate> _templates = {};

  @override
  Future<ReportTemplate> createTemplate(String templateId, String name, String description, ReportType type, List<String> sections) async {
    final template = ReportTemplate(
      templateId: templateId,
      name: name,
      description: description,
      type: type,
      sections: sections,
      createdAt: DateTime.now(),
    );
    _templates[templateId] = template;
    return template;
  }

  @override
  Future<ReportGeneration> generateReport(String generationId, ReportTemplate template, Map<String, dynamic> data) async {
    final content = _generateContent(template, data);

    return ReportGeneration(
      generationId: generationId,
      reportId: template.templateId,
      type: template.type,
      status: ExportStatus.completed,
      generatedAt: DateTime.now(),
      data: data,
      content: content,
      contentLength: content.length,
      sections: template.sections,
    );
  }

  String _generateContent(ReportTemplate template, Map<String, dynamic> data) {
    final buffer = StringBuffer();
    buffer.writeln('# ${template.name}');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${DateTime.now().toIso8601String()}');
    buffer.writeln('');

    for (final section in template.sections) {
      buffer.writeln('## $section');
      buffer.writeln('');
      final sectionData = data[section] ?? 'No data available';
      buffer.writeln('$sectionData');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  @override
  Future<ReportStats> calculateStats(List<ReportGeneration> reports, DateTime start, DateTime end) async {
    final filteredReports = reports.where((r) => r.generatedAt.isAfter(start) && r.generatedAt.isBefore(end)).toList();
    final successCount = filteredReports.where((r) => r.status == ExportStatus.completed).length;
    final failureCount = filteredReports.where((r) => r.status == ExportStatus.failed).length;

    final typeCounts = <ReportType, int>{};
    final formatCounts = <ExportFormat, int>{};

    for (final report in filteredReports) {
      typeCounts[report.type] = (typeCounts[report.type] ?? 0) + 1;
    }

    final successRate = filteredReports.isEmpty ? 0.0 : successCount / filteredReports.length;

    return ReportStats(
      statsId: 'stats_${DateTime.now().millisecondsSinceEpoch}',
      periodStart: start,
      periodEnd: end,
      totalReports: filteredReports.length,
      successfulReports: successCount,
      failedReports: failureCount,
      reportsByType: typeCounts,
      reportsByFormat: formatCounts,
      averageGenerationTime: 0.5,
      successRate: successRate,
    );
  }

  @override
  Future<List<String>> generateRecommendations(ReportStats stats) async {
    final recommendations = <String>[];

    if (stats.successRate < 0.9) {
      recommendations.add('Improve report generation success rate');
      recommendations.add('Review failed reports for common issues');
    }

    if (stats.failureRate > 0.1) {
      recommendations.add('High failure rate detected');
      recommendations.add('Consider optimizing report templates');
    }

    if (stats.averageGenerationTime > 5.0) {
      recommendations.add('Report generation time is high');
      recommendations.add('Consider simplifying templates or using caching');
    }

    return recommendations;
  }
}

/// エクスポートマネージャー インターフェース
abstract class ExportManager {
  Future<ExportJob> createExportJob(String jobId, String userId, String resourceType, ExportFormat format);
  Future<ExportJob> updateJobProgress(String jobId, double progress);
  Future<ExportJob> completeJob(String jobId, String filePath, int fileSize);
  Future<ExportJob> failJob(String jobId, String errorMessage);
  Future<ExportHistory> generateExportHistory(String historyId, String userId, DateTime start, DateTime end);
  Future<ScheduledReport> createScheduledReport(String reportId, String templateId, String userId, ScheduleFrequency frequency, ExportFormat format);
  Future<ExportReportSummary> generateSummary(String summaryId, String userId, DateTime start, DateTime end);
}

/// メモリエクスポートマネージャー実装
class MemoryExportManager implements ExportManager {
  final ExportRepository repository;
  final ReportEngine reportEngine;
  final Map<String, ReportGeneration> _reports = {};

  MemoryExportManager({
    required this.repository,
    required this.reportEngine,
  });

  @override
  Future<ExportJob> createExportJob(String jobId, String userId, String resourceType, ExportFormat format) async {
    final job = ExportJob(
      jobId: jobId,
      userId: userId,
      resourceType: resourceType,
      format: format,
      status: ExportStatus.pending,
      progress: 0.0,
      createdAt: DateTime.now(),
    );
    return repository.addJob(job);
  }

  @override
  Future<ExportJob> updateJobProgress(String jobId, double progress) async {
    final job = await repository.getJob(jobId);
    if (job != null) {
      final updatedJob = ExportJob(
        jobId: job.jobId,
        userId: job.userId,
        resourceType: job.resourceType,
        format: job.format,
        status: ExportStatus.processing,
        progress: progress.clamp(0.0, 1.0),
        createdAt: job.createdAt,
        startedAt: job.startedAt ?? DateTime.now(),
        completedAt: job.completedAt,
        fileSize: job.fileSize,
        filePath: job.filePath,
        metadata: job.metadata,
      );
      return repository.addJob(updatedJob);
    }
    return job!;
  }

  @override
  Future<ExportJob> completeJob(String jobId, String filePath, int fileSize) async {
    final job = await repository.getJob(jobId);
    if (job != null) {
      final completedJob = ExportJob(
        jobId: job.jobId,
        userId: job.userId,
        resourceType: job.resourceType,
        format: job.format,
        status: ExportStatus.completed,
        progress: 1.0,
        createdAt: job.createdAt,
        startedAt: job.startedAt,
        completedAt: DateTime.now(),
        fileSize: fileSize,
        filePath: filePath,
        metadata: job.metadata,
      );
      return repository.addJob(completedJob);
    }
    return job!;
  }

  @override
  Future<ExportJob> failJob(String jobId, String errorMessage) async {
    final job = await repository.getJob(jobId);
    if (job != null) {
      final failedJob = ExportJob(
        jobId: job.jobId,
        userId: job.userId,
        resourceType: job.resourceType,
        format: job.format,
        status: ExportStatus.failed,
        progress: job.progress,
        createdAt: job.createdAt,
        startedAt: job.startedAt,
        completedAt: DateTime.now(),
        errorMessage: errorMessage,
        metadata: job.metadata,
      );
      return repository.addJob(failedJob);
    }
    return job!;
  }

  @override
  Future<ExportHistory> generateExportHistory(String historyId, String userId, DateTime start, DateTime end) async {
    final jobs = await repository.getJobsByUser(userId);
    final filteredJobs = jobs.where((j) => j.createdAt.isAfter(start) && j.createdAt.isBefore(end)).toList();

    return repository.createHistory(
      ExportHistory(
        historyId: historyId,
        userId: userId,
        exports: filteredJobs,
        periodStart: start,
        periodEnd: end,
      ),
    );
  }

  @override
  Future<ScheduledReport> createScheduledReport(String reportId, String templateId, String userId, ScheduleFrequency frequency, ExportFormat format) async {
    final nextRun = _calculateNextRun(frequency);

    return repository.addScheduledReport(
      ScheduledReport(
        reportId: reportId,
        templateId: templateId,
        userId: userId,
        frequency: frequency,
        format: format,
        nextRunTime: nextRun,
        createdAt: DateTime.now(),
      ),
    );
  }

  DateTime _calculateNextRun(ScheduleFrequency frequency) {
    final now = DateTime.now();
    switch (frequency) {
      case ScheduleFrequency.oneTime:
        return now.add(Duration(hours: 1));
      case ScheduleFrequency.daily:
        return now.add(Duration(days: 1));
      case ScheduleFrequency.weekly:
        return now.add(Duration(days: 7));
      case ScheduleFrequency.monthly:
        return now.add(Duration(days: 30));
      case ScheduleFrequency.quarterly:
        return now.add(Duration(days: 90));
    }
  }

  @override
  Future<ExportReportSummary> generateSummary(String summaryId, String userId, DateTime start, DateTime end) async {
    final history = await generateExportHistory('h_$summaryId', userId, start, end);
    final stats = await reportEngine.calculateStats(_reports.values.toList(), start, end);
    final recommendations = await reportEngine.generateRecommendations(stats);

    return ExportReportSummary(
      summaryId: summaryId,
      generatedAt: DateTime.now(),
      exportHistory: history,
      reportStats: stats,
      recommendations: recommendations,
    );
  }
}

/// エクスポートファサード
class ExportManagerFacade {
  late final ExportRepository repository;
  late final ReportEngine engine;
  late final MemoryExportManager manager;

  ExportManagerFacade({
    ExportRepository? customRepository,
    ReportEngine? customEngine,
  }) {
    repository = customRepository ?? MemoryExportRepository();
    engine = customEngine ?? MemoryReportEngine();
    manager = MemoryExportManager(repository: repository, reportEngine: engine);
  }

  Future<ExportJob> createExportJob(String jobId, String userId, String resourceType, ExportFormat format) async {
    return manager.createExportJob(jobId, userId, resourceType, format);
  }

  Future<ExportJob> updateJobProgress(String jobId, double progress) async {
    return manager.updateJobProgress(jobId, progress);
  }

  Future<ExportJob> completeJob(String jobId, String filePath, int fileSize) async {
    return manager.completeJob(jobId, filePath, fileSize);
  }

  Future<ExportJob> failJob(String jobId, String errorMessage) async {
    return manager.failJob(jobId, errorMessage);
  }

  Future<ReportTemplate> createTemplate(String templateId, String name, String description, ReportType type, List<String> sections) async {
    return engine.createTemplate(templateId, name, description, type, sections);
  }

  Future<ReportGeneration> generateReport(String generationId, ReportTemplate template, Map<String, dynamic> data) async {
    return engine.generateReport(generationId, template, data);
  }

  Future<ScheduledReport> scheduleReport(String reportId, String templateId, String userId, ScheduleFrequency frequency, ExportFormat format) async {
    return manager.createScheduledReport(reportId, templateId, userId, frequency, format);
  }

  Future<ExportReportSummary> generateSummary(String summaryId, String userId, DateTime start, DateTime end) async {
    return manager.generateSummary(summaryId, userId, start, end);
  }

  Future<ExportHistory> getExportHistory(String historyId, String userId, DateTime start, DateTime end) async {
    return manager.generateExportHistory(historyId, userId, start, end);
  }

  Future<List<ExportJob>> getJobsByUser(String userId) async {
    return repository.getJobsByUser(userId);
  }

  Future<List<ExportJob>> getJobsByStatus(ExportStatus status) async {
    return repository.getJobsByStatus(status);
  }

  Future<List<ScheduledReport>> getActiveSchedules() async {
    return repository.getActiveSchedules();
  }
}
