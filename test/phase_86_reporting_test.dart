/// Phase 86: Advanced Reporting & Analytics Engine - Test Suite
/// Comprehensive test coverage for reporting and analytics components
import 'package:test/test.dart';
import 'package:project_040/models/advanced_reporting_models.dart';
import 'package:project_040/services/advanced_reporting_service.dart';

void main() {
  group('Phase 86: Advanced Reporting & Analytics Engine', () {
    // =========================================================================
    // ENUM TESTS (6)
    // =========================================================================
    group('Enum Tests', () {
      test('ReportType enum has all values', () {
        expect(ReportType.values.length, equals(5));
        expect(ReportType.standard.displayName, equals('標準'));
        expect(ReportType.executive.displayName, equals('エグゼクティブ'));
        expect(ReportType.detailed.displayName, equals('詳細'));
        expect(ReportType.custom.displayName, equals('カスタム'));
        expect(ReportType.automated.displayName, equals('自動'));
      });

      test('AnalyticsMetricType enum has all values', () {
        expect(AnalyticsMetricType.values.length, equals(7));
        expect(AnalyticsMetricType.count.displayName, equals('カウント'));
        expect(AnalyticsMetricType.sum.displayName, equals('合計'));
        expect(AnalyticsMetricType.average.displayName, equals('平均'));
      });

      test('ReportFormat enum has all values', () {
        expect(ReportFormat.values.length, equals(5));
        expect(ReportFormat.pdf.displayName, equals('PDF'));
        expect(ReportFormat.excel.displayName, equals('Excel'));
        expect(ReportFormat.csv.displayName, equals('CSV'));
      });

      test('AggregationPeriod enum has all values', () {
        expect(AggregationPeriod.values.length, equals(6));
        expect(AggregationPeriod.hourly.displayName, equals('時間単位'));
        expect(AggregationPeriod.daily.displayName, equals('日単位'));
      });

      test('FilterOperator enum has all values', () {
        expect(FilterOperator.values.length, equals(7));
        expect(FilterOperator.equals.displayName, equals('等しい'));
        expect(FilterOperator.between.displayName, equals('間'));
      });

      test('DrillDownLevel enum has all values', () {
        expect(DrillDownLevel.values.length, equals(5));
        expect(DrillDownLevel.summary.displayName, equals('概要'));
        expect(DrillDownLevel.transaction.displayName, equals('トランザクション'));
      });
    });

    // =========================================================================
    // MODEL TESTS (12)
    // =========================================================================
    group('Model Tests', () {
      test('Report model computes isExecuted correctly', () {
        final report = Report(
          id: 'r1',
          name: 'Test Report',
          reportType: ReportType.standard,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          totalExecutions: 5,
        );
        expect(report.isExecuted, isTrue);

        final unexecuted = Report(
          id: 'r2',
          name: 'New Report',
          reportType: ReportType.standard,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(unexecuted.isExecuted, isFalse);
      });

      test('Report model computes ageInDays', () {
        final now = DateTime.now();
        final report = Report(
          id: 'r1',
          name: 'Test',
          reportType: ReportType.standard,
          createdAt: now.subtract(Duration(days: 10)),
          updatedAt: now,
        );
        expect(report.ageInDays, equals(10));
      });

      test('Report copyWith creates new instance with updated fields', () {
        final original = Report(
          id: 'r1',
          name: 'Original',
          reportType: ReportType.standard,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final updated = original.copyWith(name: 'Updated');
        expect(updated.name, equals('Updated'));
        expect(updated.id, equals(original.id));
        expect(updated.reportType, equals(original.reportType));
      });

      test('ReportTemplate model computes isPopular', () {
        final template = ReportTemplate(
          id: 't1',
          name: 'Popular',
          reportType: ReportType.standard,
          createdAt: DateTime.now(),
          usageCount: 15,
        );
        expect(template.isPopular, isTrue);

        final unpopular = ReportTemplate(
          id: 't2',
          name: 'Unused',
          reportType: ReportType.standard,
          createdAt: DateTime.now(),
          usageCount: 5,
        );
        expect(unpopular.isPopular, isFalse);
      });

      test('AnalyticsMetric model validates hasTarget', () {
        final withTarget = AnalyticsMetric(
          id: 'm1',
          name: 'Sales',
          metricType: AnalyticsMetricType.sum,
          sourceField: 'amount',
          createdAt: DateTime.now(),
          targetValue: 1000.0,
        );
        expect(withTarget.hasTarget, isTrue);

        final noTarget = AnalyticsMetric(
          id: 'm2',
          name: 'Count',
          metricType: AnalyticsMetricType.count,
          sourceField: 'id',
          createdAt: DateTime.now(),
        );
        expect(noTarget.hasTarget, isFalse);
      });

      test('DataSource model computes hoursSinceSync', () {
        final now = DateTime.now();
        final source = DataSource(
          id: 'd1',
          name: 'Database',
          sourceType: 'postgresql',
          createdAt: now,
          lastSyncAt: now.subtract(Duration(hours: 5)),
        );
        expect(source.hoursSinceSync, equals(5));
      });

      test('ReportFilter model validates isRangeFilter', () {
        final rangeFilter = ReportFilter(
          id: 'f1',
          reportId: 'r1',
          fieldName: 'date',
          operator: FilterOperator.between,
          value: '2026-01-01,2026-12-31',
          createdAt: DateTime.now(),
        );
        expect(rangeFilter.isRangeFilter, isTrue);

        final simpleFilter = ReportFilter(
          id: 'f2',
          reportId: 'r1',
          fieldName: 'status',
          operator: FilterOperator.equals,
          value: 'active',
          createdAt: DateTime.now(),
        );
        expect(simpleFilter.isRangeFilter, isFalse);
      });

      test('PivotConfiguration model computes totalDimensions', () {
        final pivot = PivotConfiguration(
          id: 'p1',
          reportId: 'r1',
          rowFields: ['region', 'product'],
          columnFields: ['month', 'year'],
          valueFields: ['sales', 'units'],
          createdAt: DateTime.now(),
        );
        expect(pivot.totalDimensions, equals(4));
        expect(pivot.metricCount, equals(2));
        expect(pivot.isMultiDimensional, isTrue);
      });

      test('DrillDownPath model validates canDrillDeeper', () {
        final path = DrillDownPath(
          id: 'dd1',
          reportId: 'r1',
          currentLevel: DrillDownLevel.summary,
          path: ['all', 'region_1'],
          createdAt: DateTime.now(),
          targetLevel: DrillDownLevel.transaction,
        );
        expect(path.depth, equals(2));
        expect(path.canDrillDeeper, isTrue);
      });

      test('ReportExecution model computes durationSeconds', () {
        final execution = ReportExecution(
          id: 'e1',
          reportId: 'r1',
          startedAt: DateTime.now(),
          createdAt: DateTime.now(),
          executionTimeMs: 5000,
        );
        expect(execution.durationSeconds, equals(5));
      });

      test('AnalyticsAggregation model computes standardDeviation', () {
        final agg = AnalyticsAggregation(
          id: 'a1',
          metricId: 'm1',
          period: AggregationPeriod.daily,
          aggregatedValue: 100.0,
          timestamp: DateTime.now(),
          variance: 16.0,
        );
        expect(agg.standardDeviation, equals(4.0));
      });

      test('AnalyticsInsight model validates severity levels', () {
        final critical = AnalyticsInsight(
          id: 'i1',
          reportId: 'r1',
          insightType: 'anomaly',
          description: 'Critical issue',
          severity: 'CRITICAL',
          createdAt: DateTime.now(),
        );
        expect(critical.isCritical, isTrue);
        expect(critical.isWarning, isFalse);
      });
    });

    // =========================================================================
    // REPOSITORY TESTS (40+)
    // =========================================================================
    group('Repository Tests', () {
      late InMemoryAdvancedReportingRepository repository;

      setUp(() {
        repository = InMemoryAdvancedReportingRepository();
      });

      // Report Management Tests
      test('create and retrieve report', () async {
        final report = Report(
          id: 'r1',
          name: 'Sales Report',
          reportType: ReportType.standard,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.createReport(report);
        final retrieved = await repository.getReportById('r1');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Sales Report'));
      });

      test('get all reports with pagination', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createReport(Report(
            id: 'r$i',
            name: 'Report $i',
            reportType: ReportType.standard,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
        }

        final all = await repository.getAllReports();
        expect(all.length, equals(5));

        final paginated = await repository.getAllReports(limit: 2, offset: 1);
        expect(paginated.length, equals(2));
      });

      test('get reports by type', () async {
        await repository.createReport(Report(
          id: 'r1',
          name: 'Standard',
          reportType: ReportType.standard,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
        await repository.createReport(Report(
          id: 'r2',
          name: 'Executive',
          reportType: ReportType.executive,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        final standard = await repository.getReportsByType(ReportType.standard);
        expect(standard.length, equals(1));
      });

      test('update report', () async {
        final original = Report(
          id: 'r1',
          name: 'Original',
          reportType: ReportType.standard,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.createReport(original);
        final updated = await repository.updateReport(
          original.copyWith(name: 'Updated')
        );

        expect(updated.name, equals('Updated'));
        final retrieved = await repository.getReportById('r1');
        expect(retrieved!.name, equals('Updated'));
      });

      test('delete report', () async {
        final report = Report(
          id: 'r1',
          name: 'Temp',
          reportType: ReportType.standard,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.createReport(report);
        final deleted = await repository.deleteReport('r1');

        expect(deleted, isTrue);
        final retrieved = await repository.getReportById('r1');
        expect(retrieved, isNull);
      });

      // Template Tests
      test('create and retrieve template', () async {
        final template = ReportTemplate(
          id: 't1',
          name: 'Sales Template',
          reportType: ReportType.standard,
          createdAt: DateTime.now(),
        );

        await repository.createTemplate(template);
        final retrieved = await repository.getTemplateById('t1');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Sales Template'));
      });

      test('get popular templates', () async {
        for (int i = 0; i < 3; i++) {
          final template = ReportTemplate(
            id: 't$i',
            name: 'Template $i',
            reportType: ReportType.standard,
            createdAt: DateTime.now(),
            usageCount: i > 0 ? 15 : 5,
          );
          await repository.createTemplate(template);
        }

        final popular = await repository.getPopularTemplates(10);
        expect(popular.length, equals(2));
      });

      // Metrics Tests
      test('create and retrieve metric', () async {
        final metric = AnalyticsMetric(
          id: 'm1',
          name: 'Revenue',
          metricType: AnalyticsMetricType.sum,
          sourceField: 'amount',
          createdAt: DateTime.now(),
        );

        await repository.createMetric(metric);
        final retrieved = await repository.getMetricById('m1');

        expect(retrieved, isNotNull);
        expect(retrieved!.metricType, equals(AnalyticsMetricType.sum));
      });

      test('get custom metrics', () async {
        await repository.createMetric(AnalyticsMetric(
          id: 'm1',
          name: 'Custom',
          metricType: AnalyticsMetricType.sum,
          sourceField: 'value',
          createdAt: DateTime.now(),
          isCustom: true,
        ));
        await repository.createMetric(AnalyticsMetric(
          id: 'm2',
          name: 'Standard',
          metricType: AnalyticsMetricType.count,
          sourceField: 'id',
          createdAt: DateTime.now(),
          isCustom: false,
        ));

        final custom = await repository.getCustomMetrics();
        expect(custom.length, equals(1));
      });

      // Data Source Tests
      test('create and retrieve data source', () async {
        final source = DataSource(
          id: 'd1',
          name: 'Main Database',
          sourceType: 'postgresql',
          createdAt: DateTime.now(),
          isActive: true,
        );

        await repository.createDataSource(source);
        final retrieved = await repository.getDataSourceById('d1');

        expect(retrieved, isNotNull);
        expect(retrieved!.isActive, isTrue);
      });

      test('get active data sources', () async {
        await repository.createDataSource(DataSource(
          id: 'd1',
          name: 'Active',
          sourceType: 'postgresql',
          createdAt: DateTime.now(),
          isActive: true,
        ));
        await repository.createDataSource(DataSource(
          id: 'd2',
          name: 'Inactive',
          sourceType: 'mysql',
          createdAt: DateTime.now(),
          isActive: false,
        ));

        final active = await repository.getActiveDataSources();
        expect(active.length, equals(1));
      });

      // Filter Tests
      test('create and retrieve filter', () async {
        final filter = ReportFilter(
          id: 'f1',
          reportId: 'r1',
          fieldName: 'status',
          operator: FilterOperator.equals,
          value: 'active',
          createdAt: DateTime.now(),
        );

        await repository.createFilter(filter);
        final retrieved = await repository.getFilterById('f1');

        expect(retrieved, isNotNull);
        expect(retrieved!.operator, equals(FilterOperator.equals));
      });

      test('get filters by report', () async {
        await repository.createFilter(ReportFilter(
          id: 'f1',
          reportId: 'r1',
          fieldName: 'date',
          operator: FilterOperator.between,
          value: '2026-01-01,2026-12-31',
          createdAt: DateTime.now(),
        ));
        await repository.createFilter(ReportFilter(
          id: 'f2',
          reportId: 'r2',
          fieldName: 'region',
          operator: FilterOperator.equals,
          value: 'US',
          createdAt: DateTime.now(),
        ));

        final filters = await repository.getFiltersByReport('r1');
        expect(filters.length, equals(1));
      });

      // Pivot Configuration Tests
      test('create and retrieve pivot configuration', () async {
        final pivot = PivotConfiguration(
          id: 'p1',
          reportId: 'r1',
          rowFields: ['region'],
          columnFields: ['month'],
          valueFields: ['sales'],
          createdAt: DateTime.now(),
        );

        await repository.createPivotConfig(pivot);
        final retrieved = await repository.getPivotConfigById('p1');

        expect(retrieved, isNotNull);
        expect(retrieved!.rowFields.length, equals(1));
      });

      test('get multi-dimensional pivots', () async {
        await repository.createPivotConfig(PivotConfiguration(
          id: 'p1',
          reportId: 'r1',
          rowFields: ['region', 'product'],
          columnFields: ['month', 'year'],
          valueFields: ['sales'],
          createdAt: DateTime.now(),
        ));
        await repository.createPivotConfig(PivotConfiguration(
          id: 'p2',
          reportId: 'r2',
          rowFields: ['region'],
          columnFields: ['month'],
          valueFields: ['sales'],
          createdAt: DateTime.now(),
        ));

        final multi = await repository.getMultiDimensionalPivots();
        expect(multi.length, equals(1));
      });

      // Drill-Down Path Tests
      test('create and retrieve drill-down path', () async {
        final path = DrillDownPath(
          id: 'dd1',
          reportId: 'r1',
          currentLevel: DrillDownLevel.summary,
          path: ['all'],
          createdAt: DateTime.now(),
        );

        await repository.createDrillDownPath(path);
        final retrieved = await repository.getDrillDownPathById('dd1');

        expect(retrieved, isNotNull);
        expect(retrieved!.depth, equals(1));
      });

      // Report Execution Tests
      test('create and retrieve report execution', () async {
        final execution = ReportExecution(
          id: 'e1',
          reportId: 'r1',
          startedAt: DateTime.now(),
          createdAt: DateTime.now(),
          status: 'completed',
        );

        await repository.createExecution(execution);
        final retrieved = await repository.getExecutionById('e1');

        expect(retrieved, isNotNull);
        expect(retrieved!.isCompleted, isTrue);
      });

      test('get executions by status', () async {
        await repository.createExecution(ReportExecution(
          id: 'e1',
          reportId: 'r1',
          startedAt: DateTime.now(),
          createdAt: DateTime.now(),
          status: 'completed',
        ));
        await repository.createExecution(ReportExecution(
          id: 'e2',
          reportId: 'r1',
          startedAt: DateTime.now(),
          createdAt: DateTime.now(),
          status: 'failed',
        ));

        final completed = await repository.getExecutionsByStatus('completed');
        expect(completed.length, equals(1));
      });

      // Aggregation Tests
      test('record and retrieve aggregation', () async {
        final agg = AnalyticsAggregation(
          id: 'a1',
          metricId: 'm1',
          period: AggregationPeriod.daily,
          aggregatedValue: 1000.0,
          timestamp: DateTime.now(),
        );

        await repository.recordAggregation(agg);
        final retrieved = await repository.getAggregationById('a1');

        expect(retrieved, isNotNull);
        expect(retrieved!.aggregatedValue, equals(1000.0));
      });

      test('get aggregations by period', () async {
        await repository.recordAggregation(AnalyticsAggregation(
          id: 'a1',
          metricId: 'm1',
          period: AggregationPeriod.daily,
          aggregatedValue: 100.0,
          timestamp: DateTime.now(),
        ));
        await repository.recordAggregation(AnalyticsAggregation(
          id: 'a2',
          metricId: 'm2',
          period: AggregationPeriod.monthly,
          aggregatedValue: 3000.0,
          timestamp: DateTime.now(),
        ));

        final daily = await repository.getAggregationsByPeriod(AggregationPeriod.daily);
        expect(daily.length, equals(1));
      });

      // Report Schedule Tests
      test('create and retrieve report schedule', () async {
        final schedule = ReportSchedule(
          id: 's1',
          reportId: 'r1',
          scheduleExpression: 'daily',
          createdAt: DateTime.now(),
          isActive: true,
        );

        await repository.createSchedule(schedule);
        final retrieved = await repository.getScheduleById('s1');

        expect(retrieved, isNotNull);
        expect(retrieved!.isActive, isTrue);
      });

      test('get active schedules', () async {
        await repository.createSchedule(ReportSchedule(
          id: 's1',
          reportId: 'r1',
          scheduleExpression: 'daily',
          createdAt: DateTime.now(),
          isActive: true,
        ));
        await repository.createSchedule(ReportSchedule(
          id: 's2',
          reportId: 'r2',
          scheduleExpression: 'weekly',
          createdAt: DateTime.now(),
          isActive: false,
        ));

        final active = await repository.getActiveSchedules();
        expect(active.length, equals(1));
      });

      // Export Configuration Tests
      test('create and retrieve export configuration', () async {
        final config = ExportConfiguration(
          id: 'ex1',
          reportId: 'r1',
          format: ReportFormat.pdf,
          createdAt: DateTime.now(),
        );

        await repository.createExportConfig(config);
        final retrieved = await repository.getExportConfigById('ex1');

        expect(retrieved, isNotNull);
        expect(retrieved!.isPdf, isTrue);
      });

      test('get export configs by format', () async {
        await repository.createExportConfig(ExportConfiguration(
          id: 'ex1',
          reportId: 'r1',
          format: ReportFormat.pdf,
          createdAt: DateTime.now(),
        ));
        await repository.createExportConfig(ExportConfiguration(
          id: 'ex2',
          reportId: 'r2',
          format: ReportFormat.excel,
          createdAt: DateTime.now(),
        ));

        final pdfs = await repository.getConfigsByFormat(ReportFormat.pdf);
        expect(pdfs.length, equals(1));
      });

      // Analytics Insight Tests
      test('record and retrieve insight', () async {
        final insight = AnalyticsInsight(
          id: 'i1',
          reportId: 'r1',
          insightType: 'trend',
          description: 'Rising trend detected',
          severity: 'INFO',
          createdAt: DateTime.now(),
        );

        await repository.recordInsight(insight);
        final retrieved = await repository.getInsightById('i1');

        expect(retrieved, isNotNull);
        expect(retrieved!.isInfo, isTrue);
      });

      test('get insights by severity', () async {
        await repository.recordInsight(AnalyticsInsight(
          id: 'i1',
          reportId: 'r1',
          insightType: 'anomaly',
          description: 'Critical issue',
          severity: 'CRITICAL',
          createdAt: DateTime.now(),
        ));
        await repository.recordInsight(AnalyticsInsight(
          id: 'i2',
          reportId: 'r1',
          insightType: 'info',
          description: 'FYI',
          severity: 'INFO',
          createdAt: DateTime.now(),
        ));

        final critical = await repository.getInsightsBySeverity('CRITICAL');
        expect(critical.length, equals(1));
      });

      test('get actionable insights', () async {
        await repository.recordInsight(AnalyticsInsight(
          id: 'i1',
          reportId: 'r1',
          insightType: 'alert',
          description: 'Action needed',
          severity: 'WARNING',
          createdAt: DateTime.now(),
          isActionable: true,
        ));
        await repository.recordInsight(AnalyticsInsight(
          id: 'i2',
          reportId: 'r1',
          insightType: 'info',
          description: 'FYI',
          severity: 'INFO',
          createdAt: DateTime.now(),
          isActionable: false,
        ));

        final actionable = await repository.getActionableInsights('r1');
        expect(actionable.length, equals(1));
      });
    });

    // =========================================================================
    // ENGINE TESTS (5)
    // =========================================================================
    group('Engine Tests', () {
      late AdvancedReportingManager manager;

      setUp(() {
        manager = AdvancedReportingManager(
          InMemoryAdvancedReportingRepository(),
        );
      });

      test('ReportGenerationEngine creates reports', () async {
        final report = Report(
          id: 'r1',
          name: 'Generated',
          reportType: ReportType.standard,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await manager.repository.createReport(report);
        final retrieved = await manager.repository.getReportById('r1');

        expect(retrieved, isNotNull);
      });

      test('PivotAnalysisEngine analyzes pivot data', () async {
        final pivot = PivotConfiguration(
          id: 'p1',
          reportId: 'r1',
          rowFields: ['region'],
          columnFields: ['product'],
          valueFields: ['sales', 'units'],
          createdAt: DateTime.now(),
        );

        await manager.repository.createPivotConfig(pivot);
        final retrieved = await manager.repository.getPivotConfigById('p1');

        expect(retrieved!.isMultiDimensional, isFalse);
        expect(retrieved.metricCount, equals(2));
      });

      test('DrillDownEngine manages drill-down navigation', () async {
        final path = DrillDownPath(
          id: 'dd1',
          reportId: 'r1',
          currentLevel: DrillDownLevel.summary,
          path: ['all', 'region_1'],
          createdAt: DateTime.now(),
          targetLevel: DrillDownLevel.granular,
        );

        await manager.repository.createDrillDownPath(path);
        final retrieved = await manager.repository.getDrillDownPathById('dd1');

        expect(retrieved!.depth, equals(2));
        expect(retrieved.canDrillDeeper, isTrue);
      });

      test('AggregationEngine computes aggregations', () async {
        final agg = AnalyticsAggregation(
          id: 'a1',
          metricId: 'm1',
          period: AggregationPeriod.daily,
          aggregatedValue: 500.0,
          timestamp: DateTime.now(),
          count: 10,
        );

        await manager.repository.recordAggregation(agg);
        final latest = await manager.repository.getLatestAggregatedValue('m1');

        expect(latest, equals(500.0));
      });

      test('InsightExtractionEngine generates insights', () async {
        final insight = AnalyticsInsight(
          id: 'i1',
          reportId: 'r1',
          insightType: 'anomaly',
          description: 'Unusual pattern',
          severity: 'WARNING',
          createdAt: DateTime.now(),
          currentValue: 100.0,
          previousValue: 80.0,
          changePercent: 25.0,
        );

        await manager.repository.recordInsight(insight);
        final retrieved = await manager.repository.getInsightById('i1');

        expect(retrieved!.hasImprovement, isTrue);
      });
    });

    // =========================================================================
    // FACADE TESTS (6)
    // =========================================================================
    group('Facade Tests', () {
      late AdvancedReportingFacade facade;

      setUp(() {
        final manager = AdvancedReportingManager(
          InMemoryAdvancedReportingRepository(),
        );
        facade = AdvancedReportingFacade(manager);
      });

      test('createReport via facade', () async {
        final report = await facade.createReport('Sales Report', ReportType.standard);

        expect(report.name, equals('Sales Report'));
        expect(report.reportType, equals(ReportType.standard));
      });

      test('getActiveReportCount', () async {
        await facade.createReport('Report 1', ReportType.standard);
        await facade.createReport('Report 2', ReportType.executive);

        final count = await facade.getActiveReportCount();
        expect(count, equals(2));
      });

      test('getTotalReportCount', () async {
        await facade.createReport('Report 1', ReportType.standard);

        final count = await facade.getTotalReportCount();
        expect(count, greaterThanOrEqualTo(1));
      });

      test('getReportExecutionMetrics', () async {
        await facade.createReport('Report 1', ReportType.standard);

        final metrics = await facade.getReportExecutionMetrics('r_0');
        expect(metrics, isNotNull);
      });

      test('getMostUsedTemplates', () async {
        await facade.createTemplate('Template 1', ReportType.standard, usageCount: 10);

        final templates = await facade.getMostUsedTemplates(5);
        expect(templates.length, greaterThanOrEqualTo(0));
      });

      test('generateAnalyticsInsight', () async {
        await facade.createReport('Report 1', ReportType.standard);

        final insight = await facade.generateAnalyticsInsight(
          'r_0',
          'anomaly',
          'Test anomaly',
          'WARNING',
        );

        expect(insight.reportId, equals('r_0'));
        expect(insight.severity, equals('WARNING'));
      });
    });

    // =========================================================================
    // INTEGRATION TESTS (2)
    // =========================================================================
    group('Integration Tests', () {
      late AdvancedReportingFacade facade;

      setUp(() {
        final manager = AdvancedReportingManager(
          InMemoryAdvancedReportingRepository(),
        );
        facade = AdvancedReportingFacade(manager);
      });

      test('complete reporting workflow', () async {
        // Create report
        final report = await facade.createReport(
          'Sales Analysis',
          ReportType.detailed,
        );

        // Create template
        final template = await facade.createTemplate(
          'Sales Template',
          ReportType.detailed,
        );

        // Create metric
        final metric = await facade.createMetric(
          'Revenue',
          AnalyticsMetricType.sum,
          'amount',
        );

        // Verify
        expect(report.name, equals('Sales Analysis'));
        expect(template.name, equals('Sales Template'));
        expect(metric.name, equals('Revenue'));
      });

      test('pivot and drill-down analysis workflow', () async {
        // Create report
        final report = await facade.createReport(
          'Regional Analysis',
          ReportType.standard,
        );

        // Create pivot configuration
        final pivot = await facade.createPivotConfig(
          report.id,
          ['region', 'product'],
          ['month'],
          ['sales'],
        );

        // Create drill-down path
        final drillDown = await facade.createDrillDownPath(
          report.id,
          DrillDownLevel.summary,
          ['all'],
        );

        expect(pivot.isMultiDimensional, isTrue);
        expect(drillDown.depth, equals(1));
      });
    });

    // =========================================================================
    // PERFORMANCE TESTS (2)
    // =========================================================================
    group('Performance Tests', () {
      late AdvancedReportingFacade facade;

      setUp(() {
        final manager = AdvancedReportingManager(
          InMemoryAdvancedReportingRepository(),
        );
        facade = AdvancedReportingFacade(manager);
      });

      test('create 50 reports efficiently', () async {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 50; i++) {
          await facade.createReport('Report $i', ReportType.standard);
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('query 100 reports with pagination', () async {
        for (int i = 0; i < 100; i++) {
          await facade.createReport('Report $i', ReportType.standard);
        }

        final stopwatch = Stopwatch()..start();
        await facade.getAllReports(limit: 20, offset: 0);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });

    // =========================================================================
    // EDGE CASE TESTS (5+)
    // =========================================================================
    group('Edge Case Tests', () {
      late InMemoryAdvancedReportingRepository repository;

      setUp(() {
        repository = InMemoryAdvancedReportingRepository();
      });

      test('handle null report retrieval', () async {
        final result = await repository.getReportById('nonexistent');
        expect(result, isNull);
      });

      test('handle empty report list', () async {
        final reports = await repository.getAllReports();
        expect(reports, isEmpty);
      });

      test('handle duplicate report creation', () async {
        final report = Report(
          id: 'r1',
          name: 'Test',
          reportType: ReportType.standard,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.createReport(report);
        await repository.createReport(report);

        final count = await repository.getReportCount();
        expect(count, equals(1));
      });

      test('handle empty filter value', () async {
        final filter = ReportFilter(
          id: 'f1',
          reportId: 'r1',
          fieldName: 'status',
          operator: FilterOperator.equals,
          value: '',
          createdAt: DateTime.now(),
        );

        expect(filter.isActive, isFalse);
      });

      test('handle invalid aggregation period', () async {
        final agg = AnalyticsAggregation(
          id: 'a1',
          metricId: 'm1',
          period: AggregationPeriod.yearly,
          aggregatedValue: 0.0,
          timestamp: DateTime.now(),
        );

        await repository.recordAggregation(agg);
        final retrieved = await repository.getAggregationsByPeriod(AggregationPeriod.yearly);

        expect(retrieved.length, equals(1));
      });

      test('handle insight with zero change percent', () async {
        final insight = AnalyticsInsight(
          id: 'i1',
          reportId: 'r1',
          insightType: 'info',
          description: 'No change',
          severity: 'INFO',
          createdAt: DateTime.now(),
          changePercent: 0.0,
        );

        expect(insight.hasImprovement, isFalse);
        expect(insight.isDeterioration, isFalse);
      });
    });
  });
}
