/// Data Export & Reporting Models

enum ExportFormat { csv, json, xml, pdf }
enum ReportStatus { pending, processing, completed, failed }
enum ScheduleFrequency { daily, weekly, monthly, quarterly }

class ExportJob {
  final String jobId;
  final String dataSource;
  final ExportFormat format;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? filePath;
  final int recordCount;
  final bool isCompleted;

  ExportJob({
    required this.jobId,
    required this.dataSource,
    required this.format,
    required this.createdAt,
    this.completedAt,
    this.filePath,
    this.recordCount = 0,
    this.isCompleted = false,
  });

  int get durationInSeconds => completedAt != null ? completedAt!.difference(createdAt).inSeconds : 0;
  bool get isRecent => DateTime.now().difference(createdAt).inDays < 30;
}

class Report {
  final String reportId;
  final String title;
  final String description;
  final DateTime generatedAt;
  final ExportFormat format;
  final String? fileLocation;
  final int pageCount;
  final bool isScheduled;

  Report({
    required this.reportId,
    required this.title,
    required this.description,
    required this.generatedAt,
    required this.format,
    this.fileLocation,
    this.pageCount = 0,
    this.isScheduled = false,
  });

  bool get isRecent => DateTime.now().difference(generatedAt).inDays < 7;
  int get ageInDays => DateTime.now().difference(generatedAt).inDays;
}

class ScheduledReport {
  final String scheduleId;
  final String reportId;
  final ScheduleFrequency frequency;
  final DateTime? lastRun;
  final DateTime? nextRun;
  final bool isActive;
  final List<String> recipients;

  ScheduledReport({
    required this.scheduleId,
    required this.reportId,
    required this.frequency,
    this.lastRun,
    this.nextRun,
    this.isActive = true,
    this.recipients = const [],
  });

  bool get isDue => nextRun != null && DateTime.now().isAfter(nextRun!);
  bool get hasRecipients => recipients.isNotEmpty;
}

class ExportFormatConfig {
  final String formatId;
  final String formatName;
  final String extension;
  final Map<String, dynamic> options;
  final bool isSupported;

  ExportFormatConfig({
    required this.formatId,
    required this.formatName,
    required this.extension,
    required this.options,
    this.isSupported = true,
  });

  bool get hasAllOptions => options.isNotEmpty;
}

class ReportTemplate {
  final String templateId;
  final String templateName;
  final String description;
  final Map<String, dynamic> configuration;
  final DateTime createdAt;

  ReportTemplate({
    required this.templateId,
    required this.templateName,
    required this.description,
    required this.configuration,
    required this.createdAt,
  });

  bool get isRecent => DateTime.now().difference(createdAt).inDays < 30;
}

class ExportStatistics {
  final String statsId;
  final int totalExports;
  final int successfulExports;
  final int failedExports;
  final double averageFileSize;
  final DateTime periodStart;
  final DateTime periodEnd;

  ExportStatistics({
    required this.statsId,
    required this.totalExports,
    required this.successfulExports,
    required this.failedExports,
    required this.averageFileSize,
    required this.periodStart,
    required this.periodEnd,
  });

  double get successRate => totalExports > 0 ? (successfulExports / totalExports) * 100 : 0.0;
  bool get isHealthy => successRate > 95.0;
}

class ExportTask {
  final String taskId;
  final String jobId;
  final String status;
  final int progress;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final String? errorMessage;

  ExportTask({
    required this.taskId,
    required this.jobId,
    required this.status,
    required this.progress,
    required this.startedAt,
    this.finishedAt,
    this.errorMessage,
  });

  bool get isCompleted => status == 'completed';
  bool get hasError => errorMessage != null;
  int get durationInSeconds => finishedAt != null ? finishedAt!.difference(startedAt).inSeconds : 0;
}

class ExportFilter {
  final String filterId;
  final List<String> fields;
  final Map<String, dynamic> conditions;
  final DateTime createdAt;

  ExportFilter({
    required this.filterId,
    required this.fields,
    required this.conditions,
    required this.createdAt,
  });

  bool get hasFilters => conditions.isNotEmpty;
  int get fieldCount => fields.length;
}

class ExportLog {
  final String logId;
  final String jobId;
  final String event;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  ExportLog({
    required this.logId,
    required this.jobId,
    required this.event,
    required this.timestamp,
    required this.metadata,
  });

  bool get isRecent => DateTime.now().difference(timestamp).inHours < 24;
}

class ReportData {
  final String dataId;
  final String reportId;
  final List<Map<String, dynamic>> rows;
  final List<String> columns;
  final int totalRows;

  ReportData({
    required this.dataId,
    required this.reportId,
    required this.rows,
    required this.columns,
    required this.totalRows,
  });

  bool get hasData => rows.isNotEmpty;
  double get completeness => totalRows > 0 ? (rows.length / totalRows) * 100 : 0.0;
}

class ExportSchedule {
  final String scheduleId;
  final String jobId;
  final ScheduleFrequency frequency;
  final DateTime? nextExecution;
  final DateTime? lastExecution;
  final bool isEnabled;
  final int maxRetries;

  ExportSchedule({
    required this.scheduleId,
    required this.jobId,
    required this.frequency,
    this.nextExecution,
    this.lastExecution,
    this.isEnabled = true,
    this.maxRetries = 3,
  });

  bool get isDue => nextExecution != null && DateTime.now().isAfter(nextExecution!);
  bool get hasExecuted => lastExecution != null;
}

class ExportNotification {
  final String notificationId;
  final String exportJobId;
  final String recipient;
  final String status;
  final DateTime sentAt;
  final String? error;

  ExportNotification({
    required this.notificationId,
    required this.exportJobId,
    required this.recipient,
    required this.status,
    required this.sentAt,
    this.error,
  });

  bool get isDelivered => status == 'delivered';
  bool get hasFailed => status == 'failed';
}
