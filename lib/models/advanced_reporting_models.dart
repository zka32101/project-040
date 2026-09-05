/// Phase 86: Advanced Reporting & Analytics Engine
/// Core domain models for advanced reporting and analytics
library advanced_reporting_models;

// ============================================================================
// ENUMS (6 total)
// ============================================================================

enum ReportType {
  standard('標準'),
  executive('エグゼクティブ'),
  detailed('詳細'),
  custom('カスタム'),
  automated('自動');

  const ReportType(this.displayName);
  final String displayName;
}

enum AnalyticsMetricType {
  count('カウント'),
  sum('合計'),
  average('平均'),
  minimum('最小'),
  maximum('最大'),
  stddev('標準偏差'),
  percentile('パーセンタイル');

  const AnalyticsMetricType(this.displayName);
  final String displayName;
}

enum ReportFormat {
  pdf('PDF'),
  excel('Excel'),
  csv('CSV'),
  json('JSON'),
  html('HTML');

  const ReportFormat(this.displayName);
  final String displayName;
}

enum AggregationPeriod {
  hourly('時間単位'),
  daily('日単位'),
  weekly('週単位'),
  monthly('月単位'),
  quarterly('四半期単位'),
  yearly('年単位');

  const AggregationPeriod(this.displayName);
  final String displayName;
}

enum FilterOperator {
  equals('等しい'),
  notEquals('等しくない'),
  greaterThan('より大きい'),
  lessThan('より小さい'),
  inList('含まれている'),
  contains('含む'),
  between('間');

  const FilterOperator(this.displayName);
  final String displayName;
}

enum DrillDownLevel {
  summary('概要'),
  detail('詳細'),
  granular('粒度'),
  transaction('トランザクション'),
  debug('デバッグ');

  const DrillDownLevel(this.displayName);
  final String displayName;
}

// ============================================================================
// MODELS (12 total)
// ============================================================================

/// Report: レポート定義
class Report {
  Report({
    required this.id,
    required this.name,
    required this.reportType,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.owner,
    this.isPublished = false,
    this.isTemplate = false,
    this.lastExecutedAt,
    this.totalExecutions = 0,
  });

  final String id;
  final String name;
  final ReportType reportType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final String? owner;
  final bool isPublished;
  final bool isTemplate;
  final DateTime? lastExecutedAt;
  final int totalExecutions;

  bool get isExecuted => totalExecutions > 0;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  int get daysSinceExecution => lastExecutedAt != null
      ? DateTime.now().difference(lastExecutedAt!).inDays
      : -1;

  Report copyWith({
    String? id,
    String? name,
    ReportType? reportType,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
    String? owner,
    bool? isPublished,
    bool? isTemplate,
    DateTime? lastExecutedAt,
    int? totalExecutions,
  }) {
    return Report(
      id: id ?? this.id,
      name: name ?? this.name,
      reportType: reportType ?? this.reportType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
      owner: owner ?? this.owner,
      isPublished: isPublished ?? this.isPublished,
      isTemplate: isTemplate ?? this.isTemplate,
      lastExecutedAt: lastExecutedAt ?? this.lastExecutedAt,
      totalExecutions: totalExecutions ?? this.totalExecutions,
    );
  }
}

/// ReportTemplate: レポートテンプレート
class ReportTemplate {
  ReportTemplate({
    required this.id,
    required this.name,
    required this.reportType,
    required this.createdAt,
    this.description,
    this.category,
    this.isOfficial = false,
    this.usageCount = 0,
    this.lastUsedAt,
  });

  final String id;
  final String name;
  final ReportType reportType;
  final DateTime createdAt;
  final String? description;
  final String? category;
  final bool isOfficial;
  final int usageCount;
  final DateTime? lastUsedAt;

  bool get isUsed => usageCount > 0;
  bool get isPopular => usageCount > 10;
}

/// AnalyticsMetric: メトリクス定義
class AnalyticsMetric {
  AnalyticsMetric({
    required this.id,
    required this.name,
    required this.metricType,
    required this.sourceField,
    required this.createdAt,
    this.description,
    this.aggregationPeriod = AggregationPeriod.daily,
    this.isCustom = false,
    this.unitOfMeasure,
    this.targetValue,
  });

  final String id;
  final String name;
  final AnalyticsMetricType metricType;
  final String sourceField;
  final DateTime createdAt;
  final String? description;
  final AggregationPeriod aggregationPeriod;
  final bool isCustom;
  final String? unitOfMeasure;
  final double? targetValue;

  bool get hasTarget => targetValue != null;
  bool get isAggregated => metricType != AnalyticsMetricType.count;
}

/// DataSource: データソース定義
class DataSource {
  DataSource({
    required this.id,
    required this.name,
    required this.sourceType,
    required this.createdAt,
    this.description,
    this.connectionString,
    this.credentials,
    this.isActive = true,
    this.lastSyncAt,
  });

  final String id;
  final String name;
  final String sourceType;
  final DateTime createdAt;
  final String? description;
  final String? connectionString;
  final String? credentials;
  final bool isActive;
  final DateTime? lastSyncAt;

  bool get hasSync => lastSyncAt != null;
  int get hoursSinceSync => lastSyncAt != null
      ? DateTime.now().difference(lastSyncAt!).inHours
      : -1;
}

/// ReportFilter: フィルター定義
class ReportFilter {
  ReportFilter({
    required this.id,
    required this.reportId,
    required this.fieldName,
    required this.operator,
    required this.value,
    required this.createdAt,
    this.description,
    this.isRequired = false,
  });

  final String id;
  final String reportId;
  final String fieldName;
  final FilterOperator operator;
  final String value;
  final DateTime createdAt;
  final String? description;
  final bool isRequired;

  bool get isActive => value.isNotEmpty;
  bool get isRangeFilter => operator == FilterOperator.between;
}

/// PivotConfiguration: ピボットテーブル設定
class PivotConfiguration {
  PivotConfiguration({
    required this.id,
    required this.reportId,
    required this.rowFields,
    required this.columnFields,
    required this.valueFields,
    required this.createdAt,
    this.sortOrder = 'asc',
    this.maxRows = 1000,
    this.showTotals = true,
  });

  final String id;
  final String reportId;
  final List<String> rowFields;
  final List<String> columnFields;
  final List<String> valueFields;
  final DateTime createdAt;
  final String sortOrder;
  final int maxRows;
  final bool showTotals;

  int get totalDimensions => rowFields.length + columnFields.length;
  int get metricCount => valueFields.length;
  bool get isMultiDimensional => totalDimensions > 2;
}

/// DrillDownPath: ドリルダウン経路
class DrillDownPath {
  DrillDownPath({
    required this.id,
    required this.reportId,
    required this.currentLevel,
    required this.path,
    required this.createdAt,
    this.targetLevel = DrillDownLevel.granular,
    this.filters = const {},
  });

  final String id;
  final String reportId;
  final DrillDownLevel currentLevel;
  final List<String> path;
  final DateTime createdAt;
  final DrillDownLevel targetLevel;
  final Map<String, dynamic> filters;

  int get depth => path.length;
  bool get canDrillDeeper => currentLevel.index < targetLevel.index;
  bool get hasFilters => filters.isNotEmpty;
}

/// ReportExecution: レポート実行履歴
class ReportExecution {
  ReportExecution({
    required this.id,
    required this.reportId,
    required this.startedAt,
    required this.createdAt,
    this.completedAt,
    this.executionTimeMs = 0,
    this.rowsProcessed = 0,
    this.status = 'completed',
    this.errorMessage,
  });

  final String id;
  final String reportId;
  final DateTime startedAt;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int executionTimeMs;
  final int rowsProcessed;
  final String status;
  final String? errorMessage;

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isRunning => status == 'running';
  int get durationSeconds => executionTimeMs ~/ 1000;
}

/// AnalyticsAggregation: データ集約
class AnalyticsAggregation {
  AnalyticsAggregation({
    required this.id,
    required this.metricId,
    required this.period,
    required this.aggregatedValue,
    required this.timestamp,
    this.dataPoint,
    this.count = 1,
    this.variance = 0.0,
  });

  final String id;
  final String metricId;
  final AggregationPeriod period;
  final double aggregatedValue;
  final DateTime timestamp;
  final String? dataPoint;
  final int count;
  final double variance;

  double get standardDeviation => variance > 0 ? variance.sqrt() : 0;
  int get ageInHours => DateTime.now().difference(timestamp).inHours;
}

/// ReportSchedule: スケジュール設定
class ReportSchedule {
  ReportSchedule({
    required this.id,
    required this.reportId,
    required this.scheduleExpression,
    required this.createdAt,
    this.isActive = true,
    this.format = ReportFormat.pdf,
    this.recipients = const [],
    this.lastRunAt,
    this.nextRunAt,
  });

  final String id;
  final String reportId;
  final String scheduleExpression;
  final DateTime createdAt;
  final bool isActive;
  final ReportFormat format;
  final List<String> recipients;
  final DateTime? lastRunAt;
  final DateTime? nextRunAt;

  bool get hasRecipients => recipients.isNotEmpty;
  bool get isScheduled => nextRunAt != null;
  int get hourUntilNextRun => nextRunAt != null
      ? nextRunAt!.difference(DateTime.now()).inHours
      : -1;
}

/// ExportConfiguration: エクスポート設定
class ExportConfiguration {
  ExportConfiguration({
    required this.id,
    required this.reportId,
    required this.format,
    required this.createdAt,
    this.includeMetadata = true,
    this.compressionEnabled = false,
    this.encryptionEnabled = false,
    this.pageOrientation = 'portrait',
    this.customHeaders = const [],
    this.customFooters = const [],
  });

  final String id;
  final String reportId;
  final ReportFormat format;
  final DateTime createdAt;
  final bool includeMetadata;
  final bool compressionEnabled;
  final bool encryptionEnabled;
  final String pageOrientation;
  final List<String> customHeaders;
  final List<String> customFooters;

  bool get isPdf => format == ReportFormat.pdf;
  bool get isExcel => format == ReportFormat.excel;
  bool get isCsv => format == ReportFormat.csv;
  bool get isSecured => encryptionEnabled;
}

/// AnalyticsInsight: インサイト抽出
class AnalyticsInsight {
  AnalyticsInsight({
    required this.id,
    required this.reportId,
    required this.insightType,
    required this.description,
    required this.severity,
    required this.createdAt,
    this.metric,
    this.previousValue = 0.0,
    this.currentValue = 0.0,
    this.changePercent = 0.0,
    this.isActionable = false,
  });

  final String id;
  final String reportId;
  final String insightType;
  final String description;
  final String severity;
  final DateTime createdAt;
  final String? metric;
  final double previousValue;
  final double currentValue;
  final double changePercent;
  final bool isActionable;

  bool get isCritical => severity == 'CRITICAL';
  bool get isWarning => severity == 'WARNING';
  bool get isInfo => severity == 'INFO';
  bool get hasImprovement => changePercent > 0;
  bool get isDeterioration => changePercent < 0;
}
