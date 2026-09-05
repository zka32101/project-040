/// Phase 86: Advanced Reporting & Analytics Engine
/// Service layer for advanced reporting and analytics
library advanced_reporting_service;

import 'package:project_040/models/advanced_reporting_models.dart';

// ============================================================================
// REPOSITORY INTERFACE (70+ methods)
// ============================================================================

abstract class AdvancedReportingRepository {
  // ---- Report Management (12 methods) ----
  Future<Report> createReport(Report report);
  Future<Report?> getReportById(String reportId);
  Future<List<Report>> getAllReports({int limit = 100, int offset = 0});
  Future<List<Report>> getReportsByType(ReportType type);
  Future<List<Report>> getReportsByOwner(String owner);
  Future<Report> updateReport(Report report);
  Future<bool> deleteReport(String reportId);
  Future<bool> publishReport(String reportId);
  Future<List<Report>> searchReports(String query);
  Future<int> getReportCount();
  Future<int> getPublishedReportCount();
  Future<List<Report>> getRecentReports(int limit);

  // ---- Report Templates (10 methods) ----
  Future<ReportTemplate> createTemplate(ReportTemplate template);
  Future<ReportTemplate?> getTemplateById(String templateId);
  Future<List<ReportTemplate>> getAllTemplates();
  Future<List<ReportTemplate>> getTemplatesByType(ReportType type);
  Future<List<ReportTemplate>> getTemplatesByCategory(String category);
  Future<ReportTemplate> updateTemplate(ReportTemplate template);
  Future<bool> deleteTemplate(String templateId);
  Future<List<ReportTemplate>> getPopularTemplates(int limit);
  Future<bool> incrementTemplateUsage(String templateId);
  Future<int> getTemplateCount();

  // ---- Analytics Metrics (12 methods) ----
  Future<AnalyticsMetric> createMetric(AnalyticsMetric metric);
  Future<AnalyticsMetric?> getMetricById(String metricId);
  Future<List<AnalyticsMetric>> getAllMetrics();
  Future<List<AnalyticsMetric>> getMetricsByType(AnalyticsMetricType type);
  Future<List<AnalyticsMetric>> getCustomMetrics();
  Future<AnalyticsMetric> updateMetric(AnalyticsMetric metric);
  Future<bool> deleteMetric(String metricId);
  Future<List<AnalyticsMetric>> getMetricsByAggregation(AggregationPeriod period);
  Future<List<AnalyticsMetric>> getMetricsWithTargets();
  Future<int> getMetricCount();
  Future<int> getCustomMetricCount();
  Future<List<AnalyticsMetric>> searchMetrics(String query);

  // ---- Data Sources (8 methods) ----
  Future<DataSource> createDataSource(DataSource source);
  Future<DataSource?> getDataSourceById(String sourceId);
  Future<List<DataSource>> getAllDataSources();
  Future<List<DataSource>> getActiveDataSources();
  Future<DataSource> updateDataSource(DataSource source);
  Future<bool> deleteDataSource(String sourceId);
  Future<bool> testDataSourceConnection(String sourceId);
  Future<List<DataSource>> getRecentlySyncedSources(int limit);

  // ---- Report Filters (10 methods) ----
  Future<ReportFilter> createFilter(ReportFilter filter);
  Future<ReportFilter?> getFilterById(String filterId);
  Future<List<ReportFilter>> getFiltersByReport(String reportId);
  Future<ReportFilter> updateFilter(ReportFilter filter);
  Future<bool> deleteFilter(String filterId);
  Future<List<ReportFilter>> getRequiredFilters(String reportId);
  Future<List<ReportFilter>> getFiltersByOperator(String reportId, FilterOperator operator);
  Future<bool> deleteFiltersForReport(String reportId);
  Future<int> getFilterCount(String reportId);
  Future<List<ReportFilter>> searchFilters(String reportId, String query);

  // ---- Pivot Configurations (8 methods) ----
  Future<PivotConfiguration> createPivotConfig(PivotConfiguration config);
  Future<PivotConfiguration?> getPivotConfigById(String configId);
  Future<PivotConfiguration?> getPivotConfigByReport(String reportId);
  Future<PivotConfiguration> updatePivotConfig(PivotConfiguration config);
  Future<bool> deletePivotConfig(String configId);
  Future<List<PivotConfiguration>> getMultiDimensionalPivots();
  Future<List<PivotConfiguration>> getPivotsWithTotals();
  Future<int> getPivotConfigCount();

  // ---- Drill-Down Paths (8 methods) ----
  Future<DrillDownPath> createDrillDownPath(DrillDownPath path);
  Future<DrillDownPath?> getDrillDownPathById(String pathId);
  Future<List<DrillDownPath>> getDrillDownPathsByReport(String reportId);
  Future<DrillDownPath> updateDrillDownPath(DrillDownPath path);
  Future<bool> deleteDrillDownPath(String pathId);
  Future<List<DrillDownPath>> getDeepPaths(String reportId, int minDepth);
  Future<List<DrillDownPath>> getDrillDownsWithFilters(String reportId);
  Future<int> getDrillDownPathCount(String reportId);

  // ---- Report Executions (10 methods) ----
  Future<ReportExecution> createExecution(ReportExecution execution);
  Future<ReportExecution?> getExecutionById(String executionId);
  Future<List<ReportExecution>> getExecutionsByReport(String reportId);
  Future<List<ReportExecution>> getExecutionsByStatus(String status);
  Future<ReportExecution> updateExecution(ReportExecution execution);
  Future<List<ReportExecution>> getRecentExecutions(String reportId, int limit);
  Future<int> getExecutionCount(String reportId);
  Future<double> getAverageExecutionTime(String reportId);
  Future<List<ReportExecution>> getFailedExecutions(String reportId);
  Future<int> getTotalRowsProcessed(String reportId);

  // ---- Analytics Aggregations (8 methods) ----
  Future<AnalyticsAggregation> recordAggregation(AnalyticsAggregation aggregation);
  Future<AnalyticsAggregation?> getAggregationById(String aggId);
  Future<List<AnalyticsAggregation>> getAggregationsByMetric(String metricId);
  Future<List<AnalyticsAggregation>> getAggregationsByPeriod(AggregationPeriod period);
  Future<List<AnalyticsAggregation>> getAggregationHistory(String metricId, Duration period);
  Future<double> getLatestAggregatedValue(String metricId);
  Future<double> getAverageAggregation(String metricId, Duration period);
  Future<int> getAggregationCount(String metricId);

  // ---- Report Schedules (8 methods) ----
  Future<ReportSchedule> createSchedule(ReportSchedule schedule);
  Future<ReportSchedule?> getScheduleById(String scheduleId);
  Future<List<ReportSchedule>> getSchedulesByReport(String reportId);
  Future<List<ReportSchedule>> getActiveSchedules();
  Future<ReportSchedule> updateSchedule(ReportSchedule schedule);
  Future<bool> deleteSchedule(String scheduleId);
  Future<List<ReportSchedule>> getSchedulesDueToRun();
  Future<bool> markScheduleRun(String scheduleId);

  // ---- Export Configurations (8 methods) ----
  Future<ExportConfiguration> createExportConfig(ExportConfiguration config);
  Future<ExportConfiguration?> getExportConfigById(String configId);
  Future<ExportConfiguration?> getExportConfigByReport(String reportId);
  Future<ExportConfiguration> updateExportConfig(ExportConfiguration config);
  Future<bool> deleteExportConfig(String configId);
  Future<List<ExportConfiguration>> getConfigsByFormat(ReportFormat format);
  Future<List<ExportConfiguration>> getSecuredExports();
  Future<int> getExportConfigCount();

  // ---- Analytics Insights (8 methods) ----
  Future<AnalyticsInsight> recordInsight(AnalyticsInsight insight);
  Future<AnalyticsInsight?> getInsightById(String insightId);
  Future<List<AnalyticsInsight>> getInsightsByReport(String reportId);
  Future<List<AnalyticsInsight>> getInsightsBySeverity(String severity);
  Future<List<AnalyticsInsight>> getActionableInsights(String reportId);
  Future<List<AnalyticsInsight>> getRecentInsights(String reportId, int limit);
  Future<int> getInsightCount(String reportId);
  Future<int> getCriticalInsightCount();
}

// ============================================================================
// IN-MEMORY REPOSITORY IMPLEMENTATION
// ============================================================================

class InMemoryAdvancedReportingRepository extends AdvancedReportingRepository {
  final Map<String, Report> _reports = {};
  final Map<String, ReportTemplate> _templates = {};
  final Map<String, AnalyticsMetric> _metrics = {};
  final Map<String, DataSource> _dataSources = {};
  final Map<String, ReportFilter> _filters = {};
  final Map<String, PivotConfiguration> _pivots = {};
  final Map<String, DrillDownPath> _drillDowns = {};
  final Map<String, ReportExecution> _executions = {};
  final Map<String, AnalyticsAggregation> _aggregations = {};
  final Map<String, ReportSchedule> _schedules = {};
  final Map<String, ExportConfiguration> _exports = {};
  final Map<String, AnalyticsInsight> _insights = {};

  // ---- Report Management ----
  @override
  Future<Report> createReport(Report report) async {
    _reports[report.id] = report;
    return report;
  }

  @override
  Future<Report?> getReportById(String reportId) async => _reports[reportId];

  @override
  Future<List<Report>> getAllReports({int limit = 100, int offset = 0}) async {
    final all = _reports.values.toList();
    return all.skip(offset).take(limit).toList();
  }

  @override
  Future<List<Report>> getReportsByType(ReportType type) async {
    return _reports.values.where((r) => r.reportType == type).toList();
  }

  @override
  Future<List<Report>> getReportsByOwner(String owner) async {
    return _reports.values.where((r) => r.owner == owner).toList();
  }

  @override
  Future<Report> updateReport(Report report) async {
    _reports[report.id] = report;
    return report;
  }

  @override
  Future<bool> deleteReport(String reportId) async {
    return _reports.remove(reportId) != null;
  }

  @override
  Future<bool> publishReport(String reportId) async {
    final report = _reports[reportId];
    if (report != null) {
      _reports[reportId] = report.copyWith(isPublished: true);
      return true;
    }
    return false;
  }

  @override
  Future<List<Report>> searchReports(String query) async {
    final lowerQuery = query.toLowerCase();
    return _reports.values
        .where((r) => r.name.toLowerCase().contains(lowerQuery) ||
            (r.description?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }

  @override
  Future<int> getReportCount() async => _reports.length;

  @override
  Future<int> getPublishedReportCount() async {
    return _reports.values.where((r) => r.isPublished).length;
  }

  @override
  Future<List<Report>> getRecentReports(int limit) async {
    final all = _reports.values.toList();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all.take(limit).toList();
  }

  // ---- Report Templates ----
  @override
  Future<ReportTemplate> createTemplate(ReportTemplate template) async {
    _templates[template.id] = template;
    return template;
  }

  @override
  Future<ReportTemplate?> getTemplateById(String templateId) async => _templates[templateId];

  @override
  Future<List<ReportTemplate>> getAllTemplates() async => _templates.values.toList();

  @override
  Future<List<ReportTemplate>> getTemplatesByType(ReportType type) async {
    return _templates.values.where((t) => t.reportType == type).toList();
  }

  @override
  Future<List<ReportTemplate>> getTemplatesByCategory(String category) async {
    return _templates.values.where((t) => t.category == category).toList();
  }

  @override
  Future<ReportTemplate> updateTemplate(ReportTemplate template) async {
    _templates[template.id] = template;
    return template;
  }

  @override
  Future<bool> deleteTemplate(String templateId) async {
    return _templates.remove(templateId) != null;
  }

  @override
  Future<List<ReportTemplate>> getPopularTemplates(int limit) async {
    final all = _templates.values.toList();
    all.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return all.take(limit).toList();
  }

  @override
  Future<bool> incrementTemplateUsage(String templateId) async {
    final template = _templates[templateId];
    if (template != null) {
      _templates[templateId] = ReportTemplate(
        id: template.id,
        name: template.name,
        reportType: template.reportType,
        createdAt: template.createdAt,
        description: template.description,
        category: template.category,
        isOfficial: template.isOfficial,
        usageCount: template.usageCount + 1,
        lastUsedAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  @override
  Future<int> getTemplateCount() async => _templates.length;

  // ---- Analytics Metrics ----
  @override
  Future<AnalyticsMetric> createMetric(AnalyticsMetric metric) async {
    _metrics[metric.id] = metric;
    return metric;
  }

  @override
  Future<AnalyticsMetric?> getMetricById(String metricId) async => _metrics[metricId];

  @override
  Future<List<AnalyticsMetric>> getAllMetrics() async => _metrics.values.toList();

  @override
  Future<List<AnalyticsMetric>> getMetricsByType(AnalyticsMetricType type) async {
    return _metrics.values.where((m) => m.metricType == type).toList();
  }

  @override
  Future<List<AnalyticsMetric>> getCustomMetrics() async {
    return _metrics.values.where((m) => m.isCustom).toList();
  }

  @override
  Future<AnalyticsMetric> updateMetric(AnalyticsMetric metric) async {
    _metrics[metric.id] = metric;
    return metric;
  }

  @override
  Future<bool> deleteMetric(String metricId) async {
    return _metrics.remove(metricId) != null;
  }

  @override
  Future<List<AnalyticsMetric>> getMetricsByAggregation(AggregationPeriod period) async {
    return _metrics.values.where((m) => m.aggregationPeriod == period).toList();
  }

  @override
  Future<List<AnalyticsMetric>> getMetricsWithTargets() async {
    return _metrics.values.where((m) => m.hasTarget).toList();
  }

  @override
  Future<int> getMetricCount() async => _metrics.length;

  @override
  Future<int> getCustomMetricCount() async {
    return _metrics.values.where((m) => m.isCustom).length;
  }

  @override
  Future<List<AnalyticsMetric>> searchMetrics(String query) async {
    final lowerQuery = query.toLowerCase();
    return _metrics.values
        .where((m) => m.name.toLowerCase().contains(lowerQuery) ||
            (m.description?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }

  // ---- Data Sources ----
  @override
  Future<DataSource> createDataSource(DataSource source) async {
    _dataSources[source.id] = source;
    return source;
  }

  @override
  Future<DataSource?> getDataSourceById(String sourceId) async => _dataSources[sourceId];

  @override
  Future<List<DataSource>> getAllDataSources() async => _dataSources.values.toList();

  @override
  Future<List<DataSource>> getActiveDataSources() async {
    return _dataSources.values.where((s) => s.isActive).toList();
  }

  @override
  Future<DataSource> updateDataSource(DataSource source) async {
    _dataSources[source.id] = source;
    return source;
  }

  @override
  Future<bool> deleteDataSource(String sourceId) async {
    return _dataSources.remove(sourceId) != null;
  }

  @override
  Future<bool> testDataSourceConnection(String sourceId) async {
    final source = _dataSources[sourceId];
    return source != null && source.isActive;
  }

  @override
  Future<List<DataSource>> getRecentlySyncedSources(int limit) async {
    final all = _dataSources.values.where((s) => s.lastSyncAt != null).toList();
    all.sort((a, b) => (b.lastSyncAt ?? DateTime.fromMicrosecondsSinceEpoch(0))
        .compareTo(a.lastSyncAt ?? DateTime.fromMicrosecondsSinceEpoch(0)));
    return all.take(limit).toList();
  }

  // ---- Report Filters ----
  @override
  Future<ReportFilter> createFilter(ReportFilter filter) async {
    _filters[filter.id] = filter;
    return filter;
  }

  @override
  Future<ReportFilter?> getFilterById(String filterId) async => _filters[filterId];

  @override
  Future<List<ReportFilter>> getFiltersByReport(String reportId) async {
    return _filters.values.where((f) => f.reportId == reportId).toList();
  }

  @override
  Future<ReportFilter> updateFilter(ReportFilter filter) async {
    _filters[filter.id] = filter;
    return filter;
  }

  @override
  Future<bool> deleteFilter(String filterId) async {
    return _filters.remove(filterId) != null;
  }

  @override
  Future<List<ReportFilter>> getRequiredFilters(String reportId) async {
    return _filters.values.where((f) => f.reportId == reportId && f.isRequired).toList();
  }

  @override
  Future<List<ReportFilter>> getFiltersByOperator(String reportId, FilterOperator operator) async {
    return _filters.values
        .where((f) => f.reportId == reportId && f.operator == operator)
        .toList();
  }

  @override
  Future<bool> deleteFiltersForReport(String reportId) async {
    final keysToRemove = _filters.entries
        .where((e) => e.value.reportId == reportId)
        .map((e) => e.key)
        .toList();
    for (final key in keysToRemove) {
      _filters.remove(key);
    }
    return keysToRemove.isNotEmpty;
  }

  @override
  Future<int> getFilterCount(String reportId) async {
    return _filters.values.where((f) => f.reportId == reportId).length;
  }

  @override
  Future<List<ReportFilter>> searchFilters(String reportId, String query) async {
    final lowerQuery = query.toLowerCase();
    return _filters.values
        .where((f) => f.reportId == reportId &&
            (f.fieldName.toLowerCase().contains(lowerQuery) ||
             f.value.toLowerCase().contains(lowerQuery)))
        .toList();
  }

  // ---- Pivot Configurations ----
  @override
  Future<PivotConfiguration> createPivotConfig(PivotConfiguration config) async {
    _pivots[config.id] = config;
    return config;
  }

  @override
  Future<PivotConfiguration?> getPivotConfigById(String configId) async => _pivots[configId];

  @override
  Future<PivotConfiguration?> getPivotConfigByReport(String reportId) async {
    return _pivots.values.cast<PivotConfiguration?>().firstWhere(
        (p) => p?.reportId == reportId,
        orElse: () => null);
  }

  @override
  Future<PivotConfiguration> updatePivotConfig(PivotConfiguration config) async {
    _pivots[config.id] = config;
    return config;
  }

  @override
  Future<bool> deletePivotConfig(String configId) async {
    return _pivots.remove(configId) != null;
  }

  @override
  Future<List<PivotConfiguration>> getMultiDimensionalPivots() async {
    return _pivots.values.where((p) => p.isMultiDimensional).toList();
  }

  @override
  Future<List<PivotConfiguration>> getPivotsWithTotals() async {
    return _pivots.values.where((p) => p.showTotals).toList();
  }

  @override
  Future<int> getPivotConfigCount() async => _pivots.length;

  // ---- Drill-Down Paths ----
  @override
  Future<DrillDownPath> createDrillDownPath(DrillDownPath path) async {
    _drillDowns[path.id] = path;
    return path;
  }

  @override
  Future<DrillDownPath?> getDrillDownPathById(String pathId) async => _drillDowns[pathId];

  @override
  Future<List<DrillDownPath>> getDrillDownPathsByReport(String reportId) async {
    return _drillDowns.values.where((d) => d.reportId == reportId).toList();
  }

  @override
  Future<DrillDownPath> updateDrillDownPath(DrillDownPath path) async {
    _drillDowns[path.id] = path;
    return path;
  }

  @override
  Future<bool> deleteDrillDownPath(String pathId) async {
    return _drillDowns.remove(pathId) != null;
  }

  @override
  Future<List<DrillDownPath>> getDeepPaths(String reportId, int minDepth) async {
    return _drillDowns.values
        .where((d) => d.reportId == reportId && d.depth >= minDepth)
        .toList();
  }

  @override
  Future<List<DrillDownPath>> getDrillDownsWithFilters(String reportId) async {
    return _drillDowns.values
        .where((d) => d.reportId == reportId && d.hasFilters)
        .toList();
  }

  @override
  Future<int> getDrillDownPathCount(String reportId) async {
    return _drillDowns.values.where((d) => d.reportId == reportId).length;
  }

  // ---- Report Executions ----
  @override
  Future<ReportExecution> createExecution(ReportExecution execution) async {
    _executions[execution.id] = execution;
    return execution;
  }

  @override
  Future<ReportExecution?> getExecutionById(String executionId) async => _executions[executionId];

  @override
  Future<List<ReportExecution>> getExecutionsByReport(String reportId) async {
    return _executions.values.where((e) => e.reportId == reportId).toList();
  }

  @override
  Future<List<ReportExecution>> getExecutionsByStatus(String status) async {
    return _executions.values.where((e) => e.status == status).toList();
  }

  @override
  Future<ReportExecution> updateExecution(ReportExecution execution) async {
    _executions[execution.id] = execution;
    return execution;
  }

  @override
  Future<List<ReportExecution>> getRecentExecutions(String reportId, int limit) async {
    final execs = _executions.values.where((e) => e.reportId == reportId).toList();
    execs.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return execs.take(limit).toList();
  }

  @override
  Future<int> getExecutionCount(String reportId) async {
    return _executions.values.where((e) => e.reportId == reportId).length;
  }

  @override
  Future<double> getAverageExecutionTime(String reportId) async {
    final execs = _executions.values.where((e) => e.reportId == reportId).toList();
    if (execs.isEmpty) return 0;
    return execs.map((e) => e.executionTimeMs).reduce((a, b) => a + b) / execs.length;
  }

  @override
  Future<List<ReportExecution>> getFailedExecutions(String reportId) async {
    return _executions.values
        .where((e) => e.reportId == reportId && e.isFailed)
        .toList();
  }

  @override
  Future<int> getTotalRowsProcessed(String reportId) async {
    final execs = _executions.values.where((e) => e.reportId == reportId).toList();
    return execs.map((e) => e.rowsProcessed).reduce((a, b) => a + b);
  }

  // ---- Analytics Aggregations ----
  @override
  Future<AnalyticsAggregation> recordAggregation(AnalyticsAggregation aggregation) async {
    _aggregations[aggregation.id] = aggregation;
    return aggregation;
  }

  @override
  Future<AnalyticsAggregation?> getAggregationById(String aggId) async => _aggregations[aggId];

  @override
  Future<List<AnalyticsAggregation>> getAggregationsByMetric(String metricId) async {
    return _aggregations.values.where((a) => a.metricId == metricId).toList();
  }

  @override
  Future<List<AnalyticsAggregation>> getAggregationsByPeriod(AggregationPeriod period) async {
    return _aggregations.values.where((a) => a.period == period).toList();
  }

  @override
  Future<List<AnalyticsAggregation>> getAggregationHistory(String metricId, Duration period) async {
    final cutoff = DateTime.now().subtract(period);
    return _aggregations.values
        .where((a) => a.metricId == metricId && a.timestamp.isAfter(cutoff))
        .toList();
  }

  @override
  Future<double> getLatestAggregatedValue(String metricId) async {
    final aggs = _aggregations.values.where((a) => a.metricId == metricId).toList();
    if (aggs.isEmpty) return 0;
    aggs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return aggs.first.aggregatedValue;
  }

  @override
  Future<double> getAverageAggregation(String metricId, Duration period) async {
    final history = await getAggregationHistory(metricId, period);
    if (history.isEmpty) return 0;
    return history.map((a) => a.aggregatedValue).reduce((a, b) => a + b) / history.length;
  }

  @override
  Future<int> getAggregationCount(String metricId) async {
    return _aggregations.values.where((a) => a.metricId == metricId).length;
  }

  // ---- Report Schedules ----
  @override
  Future<ReportSchedule> createSchedule(ReportSchedule schedule) async {
    _schedules[schedule.id] = schedule;
    return schedule;
  }

  @override
  Future<ReportSchedule?> getScheduleById(String scheduleId) async => _schedules[scheduleId];

  @override
  Future<List<ReportSchedule>> getSchedulesByReport(String reportId) async {
    return _schedules.values.where((s) => s.reportId == reportId).toList();
  }

  @override
  Future<List<ReportSchedule>> getActiveSchedules() async {
    return _schedules.values.where((s) => s.isActive).toList();
  }

  @override
  Future<ReportSchedule> updateSchedule(ReportSchedule schedule) async {
    _schedules[schedule.id] = schedule;
    return schedule;
  }

  @override
  Future<bool> deleteSchedule(String scheduleId) async {
    return _schedules.remove(scheduleId) != null;
  }

  @override
  Future<List<ReportSchedule>> getSchedulesDueToRun() async {
    return _schedules.values
        .where((s) => s.isActive && s.nextRunAt != null && s.nextRunAt!.isBefore(DateTime.now()))
        .toList();
  }

  @override
  Future<bool> markScheduleRun(String scheduleId) async {
    final schedule = _schedules[scheduleId];
    if (schedule != null) {
      _schedules[scheduleId] = ReportSchedule(
        id: schedule.id,
        reportId: schedule.reportId,
        scheduleExpression: schedule.scheduleExpression,
        createdAt: schedule.createdAt,
        isActive: schedule.isActive,
        format: schedule.format,
        recipients: schedule.recipients,
        lastRunAt: DateTime.now(),
        nextRunAt: DateTime.now().add(const Duration(days: 1)),
      );
      return true;
    }
    return false;
  }

  // ---- Export Configurations ----
  @override
  Future<ExportConfiguration> createExportConfig(ExportConfiguration config) async {
    _exports[config.id] = config;
    return config;
  }

  @override
  Future<ExportConfiguration?> getExportConfigById(String configId) async => _exports[configId];

  @override
  Future<ExportConfiguration?> getExportConfigByReport(String reportId) async {
    return _exports.values.cast<ExportConfiguration?>().firstWhere(
        (e) => e?.reportId == reportId,
        orElse: () => null);
  }

  @override
  Future<ExportConfiguration> updateExportConfig(ExportConfiguration config) async {
    _exports[config.id] = config;
    return config;
  }

  @override
  Future<bool> deleteExportConfig(String configId) async {
    return _exports.remove(configId) != null;
  }

  @override
  Future<List<ExportConfiguration>> getConfigsByFormat(ReportFormat format) async {
    return _exports.values.where((e) => e.format == format).toList();
  }

  @override
  Future<List<ExportConfiguration>> getSecuredExports() async {
    return _exports.values.where((e) => e.isSecured).toList();
  }

  @override
  Future<int> getExportConfigCount() async => _exports.length;

  // ---- Analytics Insights ----
  @override
  Future<AnalyticsInsight> recordInsight(AnalyticsInsight insight) async {
    _insights[insight.id] = insight;
    return insight;
  }

  @override
  Future<AnalyticsInsight?> getInsightById(String insightId) async => _insights[insightId];

  @override
  Future<List<AnalyticsInsight>> getInsightsByReport(String reportId) async {
    return _insights.values.where((i) => i.reportId == reportId).toList();
  }

  @override
  Future<List<AnalyticsInsight>> getInsightsBySeverity(String severity) async {
    return _insights.values.where((i) => i.severity == severity).toList();
  }

  @override
  Future<List<AnalyticsInsight>> getActionableInsights(String reportId) async {
    return _insights.values
        .where((i) => i.reportId == reportId && i.isActionable)
        .toList();
  }

  @override
  Future<List<AnalyticsInsight>> getRecentInsights(String reportId, int limit) async {
    final insights = _insights.values.where((i) => i.reportId == reportId).toList();
    insights.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return insights.take(limit).toList();
  }

  @override
  Future<int> getInsightCount(String reportId) async {
    return _insights.values.where((i) => i.reportId == reportId).length;
  }

  @override
  Future<int> getCriticalInsightCount() async {
    return _insights.values.where((i) => i.isCritical).length;
  }
}

// ============================================================================
// ENGINES (5 total)
// ============================================================================

/// ReportGenerationEngine: Manages report generation
class ReportGenerationEngine {
  final AdvancedReportingRepository repository;

  ReportGenerationEngine(this.repository);

  Future<ReportExecution> generateReport(String reportId) async {
    final execution = ReportExecution(
      id: 'exec_${DateTime.now().millisecondsSinceEpoch}',
      reportId: reportId,
      startedAt: DateTime.now(),
      createdAt: DateTime.now(),
      status: 'running',
    );
    return await repository.createExecution(execution);
  }

  Future<int> getFailureCount(String reportId) async {
    final failed = await repository.getFailedExecutions(reportId);
    return failed.length;
  }

  Future<double> getSuccessRate(String reportId) async {
    final all = await repository.getExecutionsByReport(reportId);
    if (all.isEmpty) return 0;
    final successful = all.where((e) => e.isCompleted).length;
    return (successful / all.length) * 100;
  }
}

/// PivotAnalysisEngine: Manages pivot table analysis
class PivotAnalysisEngine {
  final AdvancedReportingRepository repository;

  PivotAnalysisEngine(this.repository);

  Future<int> getDimensionCount(String reportId) async {
    final config = await repository.getPivotConfigByReport(reportId);
    return config?.totalDimensions ?? 0;
  }

  Future<int> getMetricCount(String reportId) async {
    final config = await repository.getPivotConfigByReport(reportId);
    return config?.metricCount ?? 0;
  }

  Future<bool> supportsMultiDimension(String reportId) async {
    final config = await repository.getPivotConfigByReport(reportId);
    return config?.isMultiDimensional ?? false;
  }
}

/// DrillDownEngine: Manages drill-down navigation
class DrillDownEngine {
  final AdvancedReportingRepository repository;

  DrillDownEngine(this.repository);

  Future<List<DrillDownPath>> getDeepAnalysisPaths(String reportId) async {
    return await repository.getDeepPaths(reportId, 3);
  }

  Future<int> getMaxDrillDepth(String reportId) async {
    final paths = await repository.getDrillDownPathsByReport(reportId);
    if (paths.isEmpty) return 0;
    return paths.map((p) => p.depth).reduce((a, b) => a > b ? a : b);
  }

  Future<int> getFilteredAnalysisCount(String reportId) async {
    final paths = await repository.getDrillDownsWithFilters(reportId);
    return paths.length;
  }
}

/// AggregationEngine: Manages data aggregation
class AggregationEngine {
  final AdvancedReportingRepository repository;

  AggregationEngine(this.repository);

  Future<double> calculateTrend(String metricId, Duration period) async {
    final current = await repository.getLatestAggregatedValue(metricId);
    final historical = await repository.getAverageAggregation(metricId, period);
    if (historical == 0) return 0;
    return ((current - historical) / historical) * 100;
  }

  Future<int> getAggregationCount(String metricId) async {
    return await repository.getAggregationCount(metricId);
  }

  Future<double> getLatestValue(String metricId) async {
    return await repository.getLatestAggregatedValue(metricId);
  }
}

/// InsightExtractionEngine: Manages insight generation
class InsightExtractionEngine {
  final AdvancedReportingRepository repository;

  InsightExtractionEngine(this.repository);

  Future<int> getCriticalInsightCount() async {
    return await repository.getCriticalInsightCount();
  }

  Future<int> getActionableCount(String reportId) async {
    final actionable = await repository.getActionableInsights(reportId);
    return actionable.length;
  }

  Future<int> getWarningCount(String reportId) async {
    final warnings = await repository.getInsightsBySeverity('WARNING');
    return warnings.where((w) => w.reportId == reportId).length;
  }
}

// ============================================================================
// MANAGER
// ============================================================================

/// AdvancedReportingManager: Coordinates all engines
class AdvancedReportingManager {
  final AdvancedReportingRepository repository;
  final ReportGenerationEngine generationEngine;
  final PivotAnalysisEngine pivotEngine;
  final DrillDownEngine drillDownEngine;
  final AggregationEngine aggregationEngine;
  final InsightExtractionEngine insightEngine;

  AdvancedReportingManager(
    this.repository, {
    ReportGenerationEngine? generationEngine,
    PivotAnalysisEngine? pivotEngine,
    DrillDownEngine? drillDownEngine,
    AggregationEngine? aggregationEngine,
    InsightExtractionEngine? insightEngine,
  })  : generationEngine = generationEngine ?? ReportGenerationEngine(repository),
        pivotEngine = pivotEngine ?? PivotAnalysisEngine(repository),
        drillDownEngine = drillDownEngine ?? DrillDownEngine(repository),
        aggregationEngine = aggregationEngine ?? AggregationEngine(repository),
        insightEngine = insightEngine ?? InsightExtractionEngine(repository);
}

// ============================================================================
// FACADE (Public API)
// ============================================================================

class AdvancedReportingFacade {
  final AdvancedReportingManager manager;

  AdvancedReportingFacade(this.manager);

  Future<Report> createReport(String name, ReportType type) async {
    final report = Report(
      id: 'rpt_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      reportType: type,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return await manager.repository.createReport(report);
  }

  Future<int> getPublishedReportCount() async {
    return await manager.repository.getPublishedReportCount();
  }

  Future<int> getTotalReportCount() async {
    return await manager.repository.getReportCount();
  }

  Future<double> getAverageReportExecutionTime(String reportId) async {
    return await manager.generationEngine.repository.getAverageExecutionTime(reportId);
  }

  Future<double> getReportSuccessRate(String reportId) async {
    return await manager.generationEngine.getSuccessRate(reportId);
  }

  Future<int> getTotalMetricCount() async {
    return await manager.repository.getMetricCount();
  }

  Future<int> getCustomMetricCount() async {
    return await manager.repository.getCustomMetricCount();
  }

  Future<int> getCriticalInsightCount() async {
    return await manager.insightEngine.getCriticalInsightCount();
  }

  Future<List<ReportTemplate>> getPopularTemplates(int limit) async {
    return await manager.repository.getPopularTemplates(limit);
  }
}
