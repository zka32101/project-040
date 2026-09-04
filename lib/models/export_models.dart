/// Phase 56: Data Export & Reporting データエクスポート・レポート

/// エクスポート形式
enum ExportFormat {
  csv('csv'),
  json('json'),
  xml('xml'),
  pdf('pdf'),
  xlsx('xlsx'),
  markdown('markdown');

  final String value;
  const ExportFormat(this.value);
}

/// レポートタイプ
enum ReportType {
  jobSummary('job_summary'),
  performanceAnalysis('performance_analysis'),
  securityAudit('security_audit'),
  apiUsage('api_usage'),
  complianceReport('compliance_report'),
  executiveSummary('executive_summary'),
  detailedAnalysis('detailed_analysis');

  final String value;
  const ReportType(this.value);
}

/// データフィルタタイプ
enum FilterType {
  dateRange('date_range'),
  status('status'),
  category('category'),
  priority('priority'),
  user('user'),
  resource('resource');

  final String value;
  const FilterType(this.value);
}

/// エクスポート設定
class ExportConfiguration {
  final String configId;
  final String name;
  final ExportFormat format;
  final List<String> includeFields;
  final List<String> excludeFields;
  final bool includeHeaders;
  final bool includeSummary;
  final DateTime createdAt;
  final bool isActive;

  ExportConfiguration({
    required this.configId,
    required this.name,
    required this.format,
    required this.includeFields,
    required this.excludeFields,
    required this.includeHeaders,
    required this.includeSummary,
    required this.createdAt,
    this.isActive = true,
  });

  /// 設定が有効か
  bool get isEnabled => isActive;

  /// フィールド数
  int get totalFields => includeFields.length - excludeFields.length;

  /// カスタマイズされているか
  bool get isCustomized => excludeFields.isNotEmpty;
}

/// エクスポートジョブ
class ExportJob {
  final String jobId;
  final String exportConfigId;
  final ExportFormat format;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final ExportJobStatus status;
  final int totalRecords;
  final int processedRecords;
  final String? filePath;
  final String? errorMessage;
  final int? fileSizeBytes;

  ExportJob({
    required this.jobId,
    required this.exportConfigId,
    required this.format,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    required this.status,
    this.totalRecords = 0,
    this.processedRecords = 0,
    this.filePath,
    this.errorMessage,
    this.fileSizeBytes,
  });

  /// ジョブが完了したか
  bool get isCompleted => completedAt != null;

  /// ジョブが成功したか
  bool get isSuccessful => status == ExportJobStatus.completed && filePath != null;

  /// ジョブが失敗したか
  bool get isFailed => status == ExportJobStatus.failed;

  /// 処理進捗率
  double get progressPercentage {
    if (totalRecords == 0) return 0.0;
    return (processedRecords / totalRecords) * 100;
  }

  /// 実行時間（秒）
  int? get executionTimeSeconds {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!).inSeconds;
  }
}

/// エクスポートジョブステータス
enum ExportJobStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  final String value;
  const ExportJobStatus(this.value);
}

/// レポート
class Report {
  final String reportId;
  final String title;
  final ReportType reportType;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<String, dynamic> data;
  final String? summary;
  final List<String>? recommendations;
  final String? generatedBy;

  Report({
    required this.reportId,
    required this.title,
    required this.reportType,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.data,
    this.summary,
    this.recommendations,
    this.generatedBy,
  });

  /// レポートが最新か（7日以内）
  bool get isRecent => DateTime.now().difference(generatedAt).inDays <= 7;

  /// 推奨事項がある か
  bool get hasRecommendations => recommendations != null && recommendations!.isNotEmpty;

  /// Markdown形式で出力
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# $title');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('**Period**: ${periodStart.toIso8601String()} ~ ${periodEnd.toIso8601String()}');
    buffer.writeln('');

    if (summary != null) {
      buffer.writeln('## Summary');
      buffer.writeln('');
      buffer.writeln(summary);
      buffer.writeln('');
    }

    if (recommendations != null && recommendations!.isNotEmpty) {
      buffer.writeln('## Recommendations');
      buffer.writeln('');
      for (final rec in recommendations!.take(5)) {
        buffer.writeln('- $rec');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}

/// データフィルタ
class DataFilter {
  final String filterId;
  final String filterName;
  final FilterType filterType;
  final dynamic filterValue;
  final bool isActive;
  final DateTime createdAt;

  DataFilter({
    required this.filterId,
    required this.filterName,
    required this.filterType,
    required this.filterValue,
    this.isActive = true,
    required this.createdAt,
  });

  /// フィルタが有効か
  bool get isEnabled => isActive;

  /// フィルタが複雑か
  bool get isComplex => filterValue is List || filterValue is Map;
}

/// スケジュール済みエクスポート
class ScheduledExport {
  final String scheduleId;
  final String exportConfigId;
  final String cronExpression; // "0 0 * * *" 形式
  final DateTime createdAt;
  final DateTime? lastExecutedAt;
  final DateTime? nextExecutionAt;
  final bool isActive;
  final int maxRetries;
  final List<String> emailRecipients;

  ScheduledExport({
    required this.scheduleId,
    required this.exportConfigId,
    required this.cronExpression,
    required this.createdAt,
    this.lastExecutedAt,
    this.nextExecutionAt,
    this.isActive = true,
    this.maxRetries = 3,
    required this.emailRecipients,
  });

  /// スケジュールが有効か
  bool get isEnabled => isActive;

  /// 実行予定がある か
  bool get hasSchedule => nextExecutionAt != null;

  /// 実行済みか
  bool get hasExecuted => lastExecutedAt != null;

  /// メール受信者数
  int get recipientCount => emailRecipients.length;
}

/// エクスポートメトリクス
class ExportMetrics {
  final String metricsId;
  final int totalExports;
  final int successfulExports;
  final int failedExports;
  final double averageProcessingTimeSeconds;
  final int totalDataRecords;
  final int totalExportedRecords;
  final double averageFileSizeMb;
  final DateTime periodStart;
  final DateTime periodEnd;

  ExportMetrics({
    required this.metricsId,
    required this.totalExports,
    required this.successfulExports,
    required this.failedExports,
    required this.averageProcessingTimeSeconds,
    required this.totalDataRecords,
    required this.totalExportedRecords,
    required this.averageFileSizeMb,
    required this.periodStart,
    required this.periodEnd,
  });

  /// 成功率
  double get successRate {
    if (totalExports == 0) return 0.0;
    return successfulExports / totalExports;
  }

  /// エクスポート率
  double get exportRate {
    if (totalDataRecords == 0) return 0.0;
    return totalExportedRecords / totalDataRecords;
  }

  /// メトリクスが良好か
  bool get isHealthy => successRate > 0.95;
}

/// エクスポートレポート
class ExportReport {
  final String reportId;
  final DateTime generatedAt;
  final List<ExportJob> jobs;
  final ExportMetrics metrics;
  final List<String>? recommendations;
  final Map<String, int> formatDistribution; // 形式別の件数

  ExportReport({
    required this.reportId,
    required this.generatedAt,
    required this.jobs,
    required this.metrics,
    this.recommendations,
    required this.formatDistribution,
  });

  /// Markdown形式で出力
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Export Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');

    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Total Exports: ${metrics.totalExports}');
    buffer.writeln('- Success Rate: ${(metrics.successRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('- Total Records: ${metrics.totalDataRecords}');
    buffer.writeln('- Exported Records: ${metrics.totalExportedRecords}');
    buffer.writeln('- Avg Processing Time: ${metrics.averageProcessingTimeSeconds.toStringAsFixed(2)}s');
    buffer.writeln('');

    if (recommendations != null && recommendations!.isNotEmpty) {
      buffer.writeln('## Recommendations');
      buffer.writeln('');
      for (final rec in recommendations!.take(5)) {
        buffer.writeln('- $rec');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}

/// テンプレート
class ReportTemplate {
  final String templateId;
  final String templateName;
  final ReportType reportType;
  final String htmlContent;
  final Map<String, String> placeholders; // {{placeholder}}形式
  final DateTime createdAt;
  final bool isActive;

  ReportTemplate({
    required this.templateId,
    required this.templateName,
    required this.reportType,
    required this.htmlContent,
    required this.placeholders,
    required this.createdAt,
    this.isActive = true,
  });

  /// テンプレートが有効か
  bool get isEnabled => isActive;

  /// プレースホルダ数
  int get placeholderCount => placeholders.length;

  /// データを使用してテンプレートをレンダリング
  String render(Map<String, String> data) {
    var result = htmlContent;
    data.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
    });
    return result;
  }
}
