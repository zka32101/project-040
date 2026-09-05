import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/finops_dashboard_models.dart';
import 'package:project_040/services/finops_dashboard_service.dart';

void main() {
  group('Phase 83: FinOps Dashboard Tests', () {
    // ===== ENUM TESTS =====
    group('Enum Tests', () {
      test('ChargebackModel values', () {
        expect(ChargebackModel.direct.name, 'direct');
        expect(ChargebackModel.proportional.name, 'proportional');
        expect(ChargebackModel.fixed.name, 'fixed');
        expect(ChargebackModel.usageBased.name, 'usageBased');
        expect(ChargebackModel.hybrid.name, 'hybrid');
        expect(ChargebackModel.values.length, 5);
      });

      test('ReportingPeriodType values', () {
        expect(ReportingPeriodType.daily.name, 'daily');
        expect(ReportingPeriodType.weekly.name, 'weekly');
        expect(ReportingPeriodType.monthly.name, 'monthly');
        expect(ReportingPeriodType.quarterly.name, 'quarterly');
        expect(ReportingPeriodType.annual.name, 'annual');
        expect(ReportingPeriodType.values.length, 5);
      });

      test('VarianceStatus values', () {
        expect(VarianceStatus.onTarget.name, 'onTarget');
        expect(VarianceStatus.underBudget.name, 'underBudget');
        expect(VarianceStatus.overBudget.name, 'overBudget');
        expect(VarianceStatus.critical.name, 'critical');
        expect(VarianceStatus.values.length, 4);
      });

      test('DashboardWidgetType values', () {
        expect(DashboardWidgetType.lineChart.name, 'lineChart');
        expect(DashboardWidgetType.barChart.name, 'barChart');
        expect(DashboardWidgetType.pieChart.name, 'pieChart');
        expect(DashboardWidgetType.gauge.name, 'gauge');
        expect(DashboardWidgetType.table.name, 'table');
        expect(DashboardWidgetType.kpi.name, 'kpi');
        expect(DashboardWidgetType.heatmap.name, 'heatmap');
        expect(DashboardWidgetType.values.length, 7);
      });

      test('CostCenterType values', () {
        expect(CostCenterType.engineering.name, 'engineering');
        expect(CostCenterType.product.name, 'product');
        expect(CostCenterType.sales.name, 'sales');
        expect(CostCenterType.marketing.name, 'marketing');
        expect(CostCenterType.operations.name, 'operations');
        expect(CostCenterType.shared.name, 'shared');
        expect(CostCenterType.values.length, 6);
      });

      test('ExportFormat values', () {
        expect(ExportFormat.pdf.name, 'pdf');
        expect(ExportFormat.csv.name, 'csv');
        expect(ExportFormat.xlsx.name, 'xlsx');
        expect(ExportFormat.json.name, 'json');
        expect(ExportFormat.values.length, 4);
      });
    });

    // ===== MODEL TESTS =====
    group('Model Tests', () {
      test('CostAttribution weighted amount', () {
        final attr = CostAttribution(
          id: 'attr1',
          costCenterId: 'cc1',
          resourceId: 'res1',
          amount: 1000.0,
          model: ChargebackModel.proportional,
          attributedAt: DateTime.now(),
          weight: 0.5,
        );
        expect(attr.weightedAmount, 500.0);
        expect(attr.isRecent, true);
      });

      test('CostCenter budget calculations', () {
        final center = CostCenter(
          id: 'cc1',
          name: 'Engineering',
          type: CostCenterType.engineering,
          monthlyBudget: 30000.0,
          createdAt: DateTime.now(),
        );
        expect(center.dailyBudget, 1000.0);
        expect(center.isSubCenter, false);
      });

      test('BudgetVsActual variance status - onTarget', () {
        final bva = BudgetVsActual(
          id: 'bva1',
          costCenterId: 'cc1',
          period: ReportingPeriodType.monthly,
          budgetedAmount: 10000.0,
          actualAmount: 10200.0,
          periodStart: DateTime.now(),
          periodEnd: DateTime.now().add(Duration(days: 30)),
        );
        expect(bva.status, VarianceStatus.onTarget);
      });

      test('BudgetVsActual variance status - critical', () {
        final bva = BudgetVsActual(
          id: 'bva2',
          costCenterId: 'cc1',
          period: ReportingPeriodType.monthly,
          budgetedAmount: 10000.0,
          actualAmount: 13000.0,
          periodStart: DateTime.now(),
          periodEnd: DateTime.now().add(Duration(days: 30)),
        );
        expect(bva.status, VarianceStatus.critical);
        expect(bva.variance, 3000.0);
      });

      test('ChargebackRecord line items', () {
        final record = ChargebackRecord(
          id: 'cb1',
          costCenterId: 'cc1',
          totalCost: 3000.0,
          model: ChargebackModel.usageBased,
          period: ReportingPeriodType.monthly,
          generatedAt: DateTime.now(),
          breakdown: {'compute': 2000.0, 'storage': 1000.0},
        );
        expect(record.lineItemCount, 2);
        expect(record.averageLineItem, 1500.0);
      });

      test('DashboardWidget config check', () {
        final widget = DashboardWidget(
          id: 'w1',
          dashboardId: 'd1',
          type: DashboardWidgetType.kpi,
          title: 'Total Spend',
          positionX: 0,
          positionY: 0,
          config: {'metric': 'totalSpend'},
        );
        expect(widget.hasConfig, true);
      });

      test('FinOpsDashboard widget count', () {
        final dashboard = FinOpsDashboard(
          id: 'd1',
          name: 'Executive Dashboard',
          ownerId: 'user1',
          createdAt: DateTime.now(),
          isPublic: true,
          widgetIds: ['w1', 'w2', 'w3'],
        );
        expect(dashboard.widgetCount, 3);
        expect(dashboard.isEmpty, false);
      });

      test('FinancialReport margin calculation', () {
        final report = FinancialReport(
          id: 'r1',
          title: 'Q1 Report',
          period: ReportingPeriodType.quarterly,
          totalRevenue: 100000.0,
          totalCost: 70000.0,
          generatedAt: DateTime.now(),
          format: ExportFormat.pdf,
        );
        expect(report.grossMargin, 30000.0);
        expect(report.marginPercentage, 30.0);
        expect(report.isProfitable, true);
      });

      test('UnitEconomics profit calculation', () {
        final economics = UnitEconomics(
          id: 'ue1',
          productId: 'prod1',
          costPerUnit: 5.0,
          revenuePerUnit: 10.0,
          unitsProcessed: 1000,
          calculatedAt: DateTime.now(),
        );
        expect(economics.profitPerUnit, 5.0);
        expect(economics.totalProfit, 5000.0);
        expect(economics.margin, 50.0);
      });

      test('CostAllocationRule balance check', () {
        final rule = CostAllocationRule(
          id: 'rule1',
          name: 'Fair Split',
          model: ChargebackModel.proportional,
          allocationWeights: {'cc1': 50.0, 'cc2': 50.0},
          isActive: true,
          createdAt: DateTime.now(),
        );
        expect(rule.totalWeight, 100.0);
        expect(rule.isBalanced, true);
      });

      test('ExecutiveSummary over budget detection', () {
        final summary = ExecutiveSummary(
          id: 's1',
          period: ReportingPeriodType.monthly,
          totalSpend: 55000.0,
          budgetUtilization: 110.0,
          costCenterCount: 5,
          savingsAchieved: 3000.0,
          generatedAt: DateTime.now(),
        );
        expect(summary.isOverBudget, true);
        expect(summary.savingsRate, closeTo(5.45, 0.1));
      });

      test('ReportExport large file detection', () {
        final export = ReportExport(
          id: 'exp1',
          reportId: 'r1',
          format: ExportFormat.xlsx,
          exportedAt: DateTime.now(),
          sizeBytes: 15 * 1024 * 1024,
        );
        expect(export.isLargeFile, true);
        expect(export.sizeMB, 15.0);
      });
    });

    // ===== REPOSITORY TESTS: Attribution =====
    group('Repository Tests - Attribution', () {
      late FinOpsRepository repository;

      setUp(() {
        repository = InMemoryFinOpsRepository();
      });

      test('Create and retrieve attribution', () async {
        final attr = CostAttribution(
          id: 'attr1',
          costCenterId: 'cc1',
          resourceId: 'res1',
          amount: 1000.0,
          model: ChargebackModel.direct,
          attributedAt: DateTime.now(),
        );
        await repository.createAttribution(attr);
        final retrieved = await repository.getAttribution('attr1');
        expect(retrieved!.amount, 1000.0);
      });

      test('Get attributions by cost center', () async {
        final a1 = CostAttribution(
          id: 'attr1',
          costCenterId: 'cc1',
          resourceId: 'res1',
          amount: 500.0,
          model: ChargebackModel.direct,
          attributedAt: DateTime.now(),
        );
        final a2 = CostAttribution(
          id: 'attr2',
          costCenterId: 'cc1',
          resourceId: 'res2',
          amount: 300.0,
          model: ChargebackModel.direct,
          attributedAt: DateTime.now(),
        );
        await repository.createAttribution(a1);
        await repository.createAttribution(a2);
        final attrs = await repository.getAttributionsByCostCenter('cc1');
        expect(attrs.length, 2);
      });

      test('Get total attributed cost', () async {
        final a1 = CostAttribution(
          id: 'attr1',
          costCenterId: 'cc1',
          resourceId: 'res1',
          amount: 500.0,
          model: ChargebackModel.direct,
          attributedAt: DateTime.now(),
        );
        await repository.createAttribution(a1);
        final total = await repository.getTotalAttributedCost('cc1');
        expect(total, 500.0);
      });
    });

    // ===== REPOSITORY TESTS: Cost Centers =====
    group('Repository Tests - Cost Centers', () {
      late FinOpsRepository repository;

      setUp(() {
        repository = InMemoryFinOpsRepository();
      });

      test('Create and get cost center', () async {
        final center = CostCenter(
          id: 'cc1',
          name: 'Engineering',
          type: CostCenterType.engineering,
          monthlyBudget: 30000.0,
          createdAt: DateTime.now(),
        );
        await repository.createCostCenter(center);
        final retrieved = await repository.getCostCenter('cc1');
        expect(retrieved!.name, 'Engineering');
      });

      test('Get cost centers by type', () async {
        final c1 = CostCenter(
          id: 'cc1',
          name: 'Eng A',
          type: CostCenterType.engineering,
          monthlyBudget: 20000.0,
          createdAt: DateTime.now(),
        );
        final c2 = CostCenter(
          id: 'cc2',
          name: 'Eng B',
          type: CostCenterType.engineering,
          monthlyBudget: 15000.0,
          createdAt: DateTime.now(),
        );
        await repository.createCostCenter(c1);
        await repository.createCostCenter(c2);
        final centers = await repository.getCostCentersByType(CostCenterType.engineering);
        expect(centers.length, 2);
      });

      test('Get total budget all centers', () async {
        final c1 = CostCenter(
          id: 'cc1',
          name: 'Eng',
          type: CostCenterType.engineering,
          monthlyBudget: 20000.0,
          createdAt: DateTime.now(),
        );
        final c2 = CostCenter(
          id: 'cc2',
          name: 'Sales',
          type: CostCenterType.sales,
          monthlyBudget: 10000.0,
          createdAt: DateTime.now(),
        );
        await repository.createCostCenter(c1);
        await repository.createCostCenter(c2);
        final total = await repository.getTotalBudgetAllCenters();
        expect(total, 30000.0);
      });

      test('Update cost center budget', () async {
        final center = CostCenter(
          id: 'cc1',
          name: 'Engineering',
          type: CostCenterType.engineering,
          monthlyBudget: 20000.0,
          createdAt: DateTime.now(),
        );
        await repository.createCostCenter(center);
        await repository.updateCostCenterBudget('cc1', 25000.0);
        final updated = await repository.getCostCenter('cc1');
        expect(updated!.monthlyBudget, 25000.0);
      });
    });

    // ===== REPOSITORY TESTS: Budget vs Actual =====
    group('Repository Tests - Budget vs Actual', () {
      late FinOpsRepository repository;

      setUp(() {
        repository = InMemoryFinOpsRepository();
      });

      test('Get over budget records', () async {
        final bva = BudgetVsActual(
          id: 'bva1',
          costCenterId: 'cc1',
          period: ReportingPeriodType.monthly,
          budgetedAmount: 10000.0,
          actualAmount: 11500.0,
          periodStart: DateTime.now(),
          periodEnd: DateTime.now().add(Duration(days: 30)),
        );
        await repository.createBudgetVsActual(bva);
        final overBudget = await repository.getOverBudgetRecords();
        expect(overBudget.length, 1);
      });

      test('Get critical variance records', () async {
        final bva = BudgetVsActual(
          id: 'bva1',
          costCenterId: 'cc1',
          period: ReportingPeriodType.monthly,
          budgetedAmount: 10000.0,
          actualAmount: 13500.0,
          periodStart: DateTime.now(),
          periodEnd: DateTime.now().add(Duration(days: 30)),
        );
        await repository.createBudgetVsActual(bva);
        final critical = await repository.getCriticalVarianceRecords();
        expect(critical.length, 1);
      });

      test('Get average variance percentage', () async {
        final bva = BudgetVsActual(
          id: 'bva1',
          costCenterId: 'cc1',
          period: ReportingPeriodType.monthly,
          budgetedAmount: 10000.0,
          actualAmount: 11000.0,
          periodStart: DateTime.now(),
          periodEnd: DateTime.now().add(Duration(days: 30)),
        );
        await repository.createBudgetVsActual(bva);
        final avg = await repository.getAverageVariancePercentage();
        expect(avg, 10.0);
      });
    });

    // ===== REPOSITORY TESTS: Chargeback =====
    group('Repository Tests - Chargeback', () {
      late FinOpsRepository repository;

      setUp(() {
        repository = InMemoryFinOpsRepository();
      });

      test('Get latest chargeback', () async {
        final r1 = ChargebackRecord(
          id: 'cb1',
          costCenterId: 'cc1',
          totalCost: 1000.0,
          model: ChargebackModel.direct,
          period: ReportingPeriodType.monthly,
          generatedAt: DateTime.now().subtract(Duration(days: 1)),
          breakdown: {'compute': 1000.0},
        );
        final r2 = ChargebackRecord(
          id: 'cb2',
          costCenterId: 'cc1',
          totalCost: 1200.0,
          model: ChargebackModel.direct,
          period: ReportingPeriodType.monthly,
          generatedAt: DateTime.now(),
          breakdown: {'compute': 1200.0},
        );
        await repository.createChargeback(r1);
        await repository.createChargeback(r2);
        final latest = await repository.getLatestChargeback('cc1');
        expect(latest!.totalCost, 1200.0);
      });

      test('Get total chargeback amount', () async {
        final r1 = ChargebackRecord(
          id: 'cb1',
          costCenterId: 'cc1',
          totalCost: 1000.0,
          model: ChargebackModel.direct,
          period: ReportingPeriodType.monthly,
          generatedAt: DateTime.now(),
          breakdown: {'compute': 1000.0},
        );
        await repository.createChargeback(r1);
        final total = await repository.getTotalChargebackAmount();
        expect(total, 1000.0);
      });
    });

    // ===== REPOSITORY TESTS: Widgets & Dashboards =====
    group('Repository Tests - Widgets and Dashboards', () {
      late FinOpsRepository repository;

      setUp(() {
        repository = InMemoryFinOpsRepository();
      });

      test('Create and get widget', () async {
        final widget = DashboardWidget(
          id: 'w1',
          dashboardId: 'd1',
          type: DashboardWidgetType.kpi,
          title: 'Total Spend',
          positionX: 0,
          positionY: 0,
          config: {},
        );
        await repository.createWidget(widget);
        final retrieved = await repository.getWidget('w1');
        expect(retrieved!.title, 'Total Spend');
      });

      test('Get widgets by dashboard', () async {
        final w1 = DashboardWidget(
          id: 'w1',
          dashboardId: 'd1',
          type: DashboardWidgetType.kpi,
          title: 'KPI 1',
          positionX: 0,
          positionY: 0,
          config: {},
        );
        final w2 = DashboardWidget(
          id: 'w2',
          dashboardId: 'd1',
          type: DashboardWidgetType.barChart,
          title: 'Chart 1',
          positionX: 1,
          positionY: 0,
          config: {},
        );
        await repository.createWidget(w1);
        await repository.createWidget(w2);
        final widgets = await repository.getWidgetsByDashboard('d1');
        expect(widgets.length, 2);
      });

      test('Update widget position', () async {
        final widget = DashboardWidget(
          id: 'w1',
          dashboardId: 'd1',
          type: DashboardWidgetType.kpi,
          title: 'KPI 1',
          positionX: 0,
          positionY: 0,
          config: {},
        );
        await repository.createWidget(widget);
        await repository.updateWidgetPosition('w1', 5, 3);
        final updated = await repository.getWidget('w1');
        expect(updated!.positionX, 5);
        expect(updated.positionY, 3);
      });

      test('Delete widget', () async {
        final widget = DashboardWidget(
          id: 'w1',
          dashboardId: 'd1',
          type: DashboardWidgetType.kpi,
          title: 'KPI 1',
          positionX: 0,
          positionY: 0,
          config: {},
        );
        await repository.createWidget(widget);
        await repository.deleteWidget('w1');
        final retrieved = await repository.getWidget('w1');
        expect(retrieved, isNull);
      });

      test('Create dashboard and add widget', () async {
        final dashboard = FinOpsDashboard(
          id: 'd1',
          name: 'Exec Dashboard',
          ownerId: 'user1',
          createdAt: DateTime.now(),
          isPublic: false,
          widgetIds: [],
        );
        await repository.createDashboard(dashboard);
        await repository.addWidgetToDashboard('d1', 'w1');
        final updated = await repository.getDashboard('d1');
        expect(updated!.widgetIds.contains('w1'), true);
      });

      test('Get public dashboards', () async {
        final d1 = FinOpsDashboard(
          id: 'd1',
          name: 'Public D',
          ownerId: 'user1',
          createdAt: DateTime.now(),
          isPublic: true,
          widgetIds: [],
        );
        await repository.createDashboard(d1);
        final publicList = await repository.getPublicDashboards();
        expect(publicList.length, 1);
      });
    });

    // ===== REPOSITORY TESTS: Financial Reports =====
    group('Repository Tests - Financial Reports', () {
      late FinOpsRepository repository;

      setUp(() {
        repository = InMemoryFinOpsRepository();
      });

      test('Get profitable reports', () async {
        final report = FinancialReport(
          id: 'r1',
          title: 'Q1',
          period: ReportingPeriodType.quarterly,
          totalRevenue: 100000.0,
          totalCost: 70000.0,
          generatedAt: DateTime.now(),
          format: ExportFormat.pdf,
        );
        await repository.createFinancialReport(report);
        final profitable = await repository.getProfitableReports();
        expect(profitable.length, 1);
      });

      test('Get latest report', () async {
        final r1 = FinancialReport(
          id: 'r1',
          title: 'Q1',
          period: ReportingPeriodType.quarterly,
          totalRevenue: 100000.0,
          totalCost: 70000.0,
          generatedAt: DateTime.now().subtract(Duration(days: 90)),
          format: ExportFormat.pdf,
        );
        final r2 = FinancialReport(
          id: 'r2',
          title: 'Q2',
          period: ReportingPeriodType.quarterly,
          totalRevenue: 120000.0,
          totalCost: 75000.0,
          generatedAt: DateTime.now(),
          format: ExportFormat.pdf,
        );
        await repository.createFinancialReport(r1);
        await repository.createFinancialReport(r2);
        final latest = await repository.getLatestReport();
        expect(latest!.title, 'Q2');
      });

      test('Get total revenue', () async {
        final r1 = FinancialReport(
          id: 'r1',
          title: 'Q1',
          period: ReportingPeriodType.quarterly,
          totalRevenue: 100000.0,
          totalCost: 70000.0,
          generatedAt: DateTime.now(),
          format: ExportFormat.pdf,
        );
        await repository.createFinancialReport(r1);
        final total = await repository.getTotalRevenue();
        expect(total, 100000.0);
      });
    });

    // ===== REPOSITORY TESTS: Unit Economics =====
    group('Repository Tests - Unit Economics', () {
      late FinOpsRepository repository;

      setUp(() {
        repository = InMemoryFinOpsRepository();
      });

      test('Get most profitable products', () async {
        final e1 = UnitEconomics(
          id: 'ue1',
          productId: 'prod1',
          costPerUnit: 5.0,
          revenuePerUnit: 10.0,
          unitsProcessed: 1000,
          calculatedAt: DateTime.now(),
        );
        final e2 = UnitEconomics(
          id: 'ue2',
          productId: 'prod2',
          costPerUnit: 3.0,
          revenuePerUnit: 12.0,
          unitsProcessed: 2000,
          calculatedAt: DateTime.now(),
        );
        await repository.createUnitEconomics(e1);
        await repository.createUnitEconomics(e2);
        final top = await repository.getMostProfitableProducts(1);
        expect(top.first.productId, 'prod2');
      });

      test('Get total profit all products', () async {
        final e1 = UnitEconomics(
          id: 'ue1',
          productId: 'prod1',
          costPerUnit: 5.0,
          revenuePerUnit: 10.0,
          unitsProcessed: 1000,
          calculatedAt: DateTime.now(),
        );
        await repository.createUnitEconomics(e1);
        final total = await repository.getTotalProfitAllProducts();
        expect(total, 5000.0);
      });
    });

    // ===== REPOSITORY TESTS: Allocation Rules =====
    group('Repository Tests - Allocation Rules', () {
      late FinOpsRepository repository;

      setUp(() {
        repository = InMemoryFinOpsRepository();
      });

      test('Get active rules', () async {
        final rule = CostAllocationRule(
          id: 'rule1',
          name: 'Fair Split',
          model: ChargebackModel.proportional,
          allocationWeights: {'cc1': 50.0, 'cc2': 50.0},
          isActive: true,
          createdAt: DateTime.now(),
        );
        await repository.createAllocationRule(rule);
        final active = await repository.getActiveRules();
        expect(active.length, 1);
      });

      test('Get unbalanced rules', () async {
        final rule = CostAllocationRule(
          id: 'rule1',
          name: 'Unbalanced',
          model: ChargebackModel.proportional,
          allocationWeights: {'cc1': 30.0, 'cc2': 50.0},
          isActive: true,
          createdAt: DateTime.now(),
        );
        await repository.createAllocationRule(rule);
        final unbalanced = await repository.getUnbalancedRules();
        expect(unbalanced.length, 1);
      });

      test('Deactivate rule', () async {
        final rule = CostAllocationRule(
          id: 'rule1',
          name: 'Rule 1',
          model: ChargebackModel.fixed,
          allocationWeights: {'cc1': 100.0},
          isActive: true,
          createdAt: DateTime.now(),
        );
        await repository.createAllocationRule(rule);
        await repository.deactivateRule('rule1');
        final updated = await repository.getAllocationRule('rule1');
        expect(updated!.isActive, false);
      });
    });

    // ===== REPOSITORY TESTS: Executive Summary =====
    group('Repository Tests - Executive Summary', () {
      late FinOpsRepository repository;

      setUp(() {
        repository = InMemoryFinOpsRepository();
      });

      test('Get latest summary', () async {
        final s1 = ExecutiveSummary(
          id: 's1',
          period: ReportingPeriodType.monthly,
          totalSpend: 50000.0,
          budgetUtilization: 90.0,
          costCenterCount: 5,
          savingsAchieved: 2000.0,
          generatedAt: DateTime.now(),
        );
        await repository.createExecutiveSummary(s1);
        final latest = await repository.getLatestSummary();
        expect(latest!.totalSpend, 50000.0);
      });

      test('Create and get exports', () async {
        final export = ReportExport(
          id: 'exp1',
          reportId: 'r1',
          format: ExportFormat.csv,
          exportedAt: DateTime.now(),
          sizeBytes: 1024,
        );
        await repository.createExport(export);
        final exports = await repository.getExportsByReport('r1');
        expect(exports.length, 1);
      });

      test('Get average savings rate', () async {
        final s1 = ExecutiveSummary(
          id: 's1',
          period: ReportingPeriodType.monthly,
          totalSpend: 10000.0,
          budgetUtilization: 90.0,
          costCenterCount: 5,
          savingsAchieved: 1000.0,
          generatedAt: DateTime.now(),
        );
        await repository.createExecutiveSummary(s1);
        final rate = await repository.getAverageSavingsRate();
        expect(rate, 10.0);
      });
    });

    // ===== ENGINE TESTS =====
    group('Engine Tests', () {
      test('AttributionEngine distributes cost', () async {
        final engine = AttributionEngine();
        final result = await engine.distributeCost(1000.0, {'cc1': 60.0, 'cc2': 40.0}, 'res1');
        expect(result.length, 2);
        expect(result.first.amount, 600.0);
      });

      test('VarianceAnalysisEngine analyzes variance', () async {
        final engine = VarianceAnalysisEngine();
        final status = await engine.analyzeVariance(10000.0, 13500.0);
        expect(status, VarianceStatus.critical);
      });

      test('ChargebackEngine generates chargeback', () async {
        final engine = ChargebackEngine();
        final record = await engine.generateChargeback(
          'cc1',
          {'compute': 500.0, 'storage': 300.0},
          ChargebackModel.usageBased,
        );
        expect(record.totalCost, 800.0);
      });

      test('ReportGenerationEngine generates report', () async {
        final engine = ReportGenerationEngine();
        final report = await engine.generateReport(
          'Test Report',
          50000.0,
          30000.0,
          ReportingPeriodType.monthly,
        );
        expect(report.grossMargin, 20000.0);
      });

      test('ExecutiveSummaryEngine generates summary', () async {
        final engine = ExecutiveSummaryEngine();
        final summary = await engine.generateSummary(50000.0, 95.0, 10, 3000.0);
        expect(summary.totalSpend, 50000.0);
      });
    });

    // ===== FACADE TESTS =====
    group('Facade Tests', () {
      late FinOpsFacade facade;

      setUp(() {
        facade = FinOpsFacade();
      });

      test('Create cost center', () async {
        final center = await facade.createCostCenter('Engineering', CostCenterType.engineering, 30000.0);
        expect(center.name, 'Engineering');
      });

      test('Get total organization budget', () async {
        await facade.createCostCenter('Eng', CostCenterType.engineering, 30000.0);
        await facade.createCostCenter('Sales', CostCenterType.sales, 20000.0);
        final total = await facade.getTotalOrganizationBudget();
        expect(total, 50000.0);
      });

      test('Get average budget variance', () async {
        final variance = await facade.getAverageBudgetVariance();
        expect(variance, isA<double>());
      });

      test('Get critical budget issue count', () async {
        final count = await facade.getCriticalBudgetIssueCount();
        expect(count, isA<int>());
      });

      test('Get organization margin', () async {
        final margin = await facade.getOrganizationMargin();
        expect(margin, isA<double>());
      });
    });

    // ===== INTEGRATION TESTS =====
    group('Integration Tests', () {
      late FinOpsFacade facade;

      setUp(() {
        facade = FinOpsFacade();
      });

      test('End-to-end cost center and budget workflow', () async {
        final center = await facade.createCostCenter('Product', CostCenterType.product, 25000.0);
        expect(center.monthlyBudget, 25000.0);
        final total = await facade.getTotalOrganizationBudget();
        expect(total, 25000.0);
      });

      test('Multi-cost-center management', () async {
        await facade.createCostCenter('Eng', CostCenterType.engineering, 30000.0);
        await facade.createCostCenter('Marketing', CostCenterType.marketing, 15000.0);
        await facade.createCostCenter('Ops', CostCenterType.operations, 10000.0);
        final total = await facade.getTotalOrganizationBudget();
        expect(total, 55000.0);
      });
    });

    // ===== PERFORMANCE TESTS =====
    group('Performance Tests', () {
      late FinOpsRepository repository;

      setUp(() {
        repository = InMemoryFinOpsRepository();
      });

      test('Bulk cost center creation performance', () async {
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 100; i++) {
          await repository.createCostCenter(
            CostCenter(
              id: 'cc_$i',
              name: 'Center $i',
              type: CostCenterType.shared,
              monthlyBudget: 1000.0,
              createdAt: DateTime.now(),
            ),
          );
        }
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds < 5000, true);
      });

      test('Bulk attribution creation and retrieval', () async {
        for (int i = 0; i < 50; i++) {
          await repository.createAttribution(
            CostAttribution(
              id: 'attr_$i',
              costCenterId: 'cc1',
              resourceId: 'res_$i',
              amount: 100.0,
              model: ChargebackModel.direct,
              attributedAt: DateTime.now(),
            ),
          );
        }
        final attrs = await repository.getAttributionsByCostCenter('cc1');
        expect(attrs.length, 50);
      });
    });

    // ===== EDGE CASE TESTS =====
    group('Edge Case Tests', () {
      late FinOpsRepository repository;

      setUp(() {
        repository = InMemoryFinOpsRepository();
      });

      test('Handle null values gracefully', () async {
        final center = await repository.getCostCenter('nonexistent');
        expect(center, isNull);
      });

      test('Handle empty collections', () async {
        final centers = await repository.getAllCostCenters();
        expect(centers, isEmpty);
      });

      test('Handle zero budget cost center', () async {
        final center = CostCenter(
          id: 'cc1',
          name: 'Zero Budget',
          type: CostCenterType.shared,
          monthlyBudget: 0.0,
          createdAt: DateTime.now(),
        );
        await repository.createCostCenter(center);
        final retrieved = await repository.getCostCenter('cc1');
        expect(retrieved!.dailyBudget, 0.0);
      });

      test('Handle sub cost centers', () async {
        final parent = CostCenter(
          id: 'cc1',
          name: 'Parent',
          type: CostCenterType.engineering,
          monthlyBudget: 50000.0,
          createdAt: DateTime.now(),
        );
        final child = CostCenter(
          id: 'cc2',
          name: 'Child',
          type: CostCenterType.engineering,
          parentId: 'cc1',
          monthlyBudget: 20000.0,
          createdAt: DateTime.now(),
        );
        await repository.createCostCenter(parent);
        await repository.createCostCenter(child);
        final subs = await repository.getSubCenters('cc1');
        expect(subs.length, 1);
        expect(subs.first.isSubCenter, true);
      });

      test('Concurrent operations', () async {
        final futures = <Future>[];
        for (int i = 0; i < 20; i++) {
          futures.add(repository.createCostCenter(
            CostCenter(
              id: 'concurrent_$i',
              name: 'Center $i',
              type: CostCenterType.shared,
              monthlyBudget: 1000.0,
              createdAt: DateTime.now(),
            ),
          ));
        }
        await Future.wait(futures);
        final centers = await repository.getAllCostCenters();
        expect(centers.length, 20);
      });
    });
  });
}
