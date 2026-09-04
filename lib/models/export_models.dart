/// Phase 49: Data Export & Reporting System データエクスポート・レポートシステム
///
/// エクスポート、レポート生成、スケジューリング、マルチフォーマット対応

/// エクスポート形式
enum ExportFormat {
  csv('csv'),
  json('json'),
  pdf('pdf'),
  excel('excel'),
  markdown('markdown'),
  xml('xml');

  final String value;
  const ExportFormat(this.value);
}

/// エクスポートステータス
enum ExportStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  final String value;
  const ExportStatus(this.value);
}

/// レポートタイプ
enum ReportType {
  summary('summary'),
  detailed('detailed'),
  trend('trend'),
  comparative('comparative'),
  custom('custom');

  final String value;
  const ReportType(this.value);
}

/// スケジュール頻度
enum ScheduleFrequency {
  oneTime('one_time'),
  daily('daily'),
  weekly('weekly'),
  monthly('monthly'),
  quarterly('quarterly');

  final String value;
  const ScheduleFrequency(this.value);
}

/// エクスポートジョブ
class ExportJob {
  final String jobId;
  final String userId;
  final String resourceType;
  final ExportFormat format;
  final ExportStatus status;
  final double progress; // 0.0-1.0
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? fileSize;
  final String? filePath;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  ExportJob({
    required this.jobId,
    required this.userId,
    required this.resourceType,
    required this.format,
    required this.status,
    this.progress = 0.0,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.fileSize,
    this.filePath,
    this.errorMessage,
    this.metadata,
  });

  /// ジョブが完了したか
  bool get isCompleted => status == ExportStatus.completed;

  /// ジョブが失敗したか
  bool get isFailed => status == ExportStatus.failed;

  /// ジョブが処理中か
  bool get isProcessing => status == ExportStatus.processing;

  /// 処理時間
  Duration? get processingTime {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!);
  }

  /// ジョブの年齢
  Duration get age => DateTime.now().difference(createdAt);
}

/// エクスポートリクエスト
class ExportRequest {
  final String requestId;
  final String userId;
  final String resourceType;
  final List<String> resourceIds;
  final ExportFormat format;
  final Map<String, dynamic>? filters;
  final int priority; // 1-5
  final DateTime requestedAt;
  final DateTime? scheduledFor;

  ExportRequest({
    required this.requestId,
    required this.userId,
    required this.resourceType,
    required this.resourceIds,
    required this.format,
    this.filters,
    this.priority = 3,
    required this.requestedAt,
    this.scheduledFor,
  });

  /// リクエストが高優先度か
  bool get isHighPriority => priority >= 4;

  /// リクエストがスケジュール済みか
  bool get isScheduled => scheduledFor != null;

  /// リソース数
  int get resourceCount => resourceIds.length;
}

/// レポートテンプレート
class ReportTemplate {
  final String templateId;
  final String name;
  final String description;
  final ReportType type;
  final List<String> sections;
  final Map<String, dynamic>? config;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReportTemplate({
    required this.templateId,
    required this.name,
    required this.description,
    required this.type,
    required this.sections,
    this.config,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// テンプレートが有効か
  bool get isEnabled => isActive;

  /// セクション数
  int get sectionCount => sections.length;
}

/// スケジュール済みレポート
class ScheduledReport {
  final String reportId;
  final String templateId;
  final String userId;
  final ScheduleFrequency frequency;
  final ExportFormat format;
  final DateTime nextRunTime;
  final DateTime? lastRunTime;
  final bool isActive;
  final List<String>? recipients;
  final DateTime createdAt;

  ScheduledReport({
    required this.reportId,
    required this.templateId,
    required this.userId,
    required this.frequency,
    required this.format,
    required this.nextRunTime,
    this.lastRunTime,
    this.isActive = true,
    this.recipients,
    required this.createdAt,
  });

  /// レポートが実行予定か
  bool get isScheduled => isActive && nextRunTime.isAfter(DateTime.now());

  /// 次実行までの時間
  Duration? get timeUntilNextRun {
    if (!isScheduled) return null;
    return nextRunTime.difference(DateTime.now());
  }

  /// 実行されたか
  bool get hasRun => lastRunTime != null;
}

/// レポート生成
class ReportGeneration {
  final String generationId;
  final String reportId;
  final ReportType type;
  final ExportStatus status;
  final DateTime generatedAt;
  final Map<String, dynamic>? data;
  final String? content;
  final int? contentLength;
  final List<String>? sections;

  ReportGeneration({
    required this.generationId,
    required this.reportId,
    required this.type,
    required this.status,
    required this.generatedAt,
    this.data,
    this.content,
    this.contentLength,
    this.sections,
  });

  /// レポートが生成されたか
  bool get isGenerated => status == ExportStatus.completed && content != null;

  /// レポートが大きいか（> 1MB）
  bool get isLarge => contentLength != null && contentLength! > 1000000;
}

/// レポート統計
class ReportStats {
  final String statsId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalReports;
  final int successfulReports;
  final int failedReports;
  final Map<ReportType, int> reportsByType;
  final Map<ExportFormat, int> reportsByFormat;
  final double averageGenerationTime; // seconds
  final double successRate; // 0.0-1.0

  ReportStats({
    required this.statsId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalReports,
    required this.successfulReports,
    required this.failedReports,
    required this.reportsByType,
    required this.reportsByFormat,
    required this.averageGenerationTime,
    required this.successRate,
  });

  /// 失敗率
  double get failureRate {
    if (totalReports == 0) return 0.0;
    return failedReports / totalReports;
  }

  /// 最も使用されたタイプ
  ReportType? get mostUsedType {
    if (reportsByType.isEmpty) return null;
    return reportsByType.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// 最も使用されたフォーマット
  ExportFormat? get mostUsedFormat {
    if (reportsByFormat.isEmpty) return null;
    return reportsByFormat.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

/// エクスポート履歴
class ExportHistory {
  final String historyId;
  final String userId;
  final List<ExportJob> exports;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<String, dynamic>? metadata;

  ExportHistory({
    required this.historyId,
    required this.userId,
    required this.exports,
    required this.periodStart,
    required this.periodEnd,
    this.metadata,
  });

  /// エクスポート数
  int get exportCount => exports.length;

  /// 成功したエクスポート数
  int get successCount => exports.where((e) => e.isCompleted).length;

  /// 失敗したエクスポート数
  int get failureCount => exports.where((e) => e.isFailed).length;

  /// 成功率
  double get successRate {
    if (exports.isEmpty) return 0.0;
    return successCount / exports.length;
  }

  /// 総ファイルサイズ
  int get totalFileSize {
    return exports.fold<int>(0, (sum, e) => sum + (e.fileSize ?? 0));
  }

  /// フォーマット別集計
  Map<ExportFormat, int> get formatCounts {
    final counts = <ExportFormat, int>{};
    for (final export in exports) {
      counts[export.format] = (counts[export.format] ?? 0) + 1;
    }
    return counts;
  }
}

/// エクスポート・レポートサマリー
class ExportReportSummary {
  final String summaryId;
  final DateTime generatedAt;
  final ExportHistory exportHistory;
  final ReportStats reportStats;
  final List<String>? recommendations;
  final Map<String, dynamic>? insights;

  ExportReportSummary({
    required this.summaryId,
    required this.generatedAt,
    required this.exportHistory,
    required this.reportStats,
    this.recommendations,
    this.insights,
  });

  /// Markdown形式で出力
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Export & Reporting Summary');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');

    buffer.writeln('## Export Statistics');
    buffer.writeln('');
    buffer.writeln('- Total Exports: ${exportHistory.exportCount}');
    buffer.writeln('- Successful: ${exportHistory.successCount}');
    buffer.writeln('- Failed: ${exportHistory.failureCount}');
    buffer.writeln('- Success Rate: ${(exportHistory.successRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('- Total File Size: ${(exportHistory.totalFileSize / 1024 / 1024).toStringAsFixed(2)} MB');
    buffer.writeln('');

    buffer.writeln('## Report Statistics');
    buffer.writeln('');
    buffer.writeln('- Total Reports: ${reportStats.totalReports}');
    buffer.writeln('- Successful: ${reportStats.successfulReports}');
    buffer.writeln('- Failed: ${reportStats.failedReports}');
    buffer.writeln('- Success Rate: ${(reportStats.successRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('- Avg Generation Time: ${reportStats.averageGenerationTime.toStringAsFixed(2)}s');
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
