// Phase 83: Financial Reporting & FinOps Dashboard System
// Service layer with Repository, Engines, Manager, and Facade

import 'package:project_040/models/finops_dashboard_models.dart';

// ===== REPOSITORY INTERFACE =====
abstract class FinOpsRepository {
  // Cost Attribution (6 methods)
  Future<void> createAttribution(CostAttribution attribution);
  Future<CostAttribution?> getAttribution(String id);
  Future<List<CostAttribution>> getAttributionsByCostCenter(String costCenterId);
  Future<List<CostAttribution>> getAttributionsByResource(String resourceId);
  Future<double> getTotalAttributedCost(String costCenterId);
  Future<List<CostAttribution>> getAttributionsByModel(ChargebackModel model);

  // Cost Center Management (7 methods)
  Future<void> createCostCenter(CostCenter center);
  Future<CostCenter?> getCostCenter(String id);
  Future<List<CostCenter>> getCostCentersByType(CostCenterType type);
  Future<List<CostCenter>> getSubCenters(String parentId);
  Future<List<CostCenter>> getAllCostCenters();
  Future<double> getTotalBudgetAllCenters();
  Future<void> updateCostCenterBudget(String id, double newBudget);

  // Budget vs Actual (7 methods)
  Future<void> createBudgetVsActual(BudgetVsActual bva);
  Future<BudgetVsActual?> getBudgetVsActual(String id);
  Future<List<BudgetVsActual>> getBvaByCostCenter(String costCenterId);
  Future<List<BudgetVsActual>> getOverBudgetRecords();
  Future<List<BudgetVsActual>> getCriticalVarianceRecords();
  Future<double> getAverageVariancePercentage();
  Future<List<BudgetVsActual>> getBvaByPeriod(ReportingPeriodType period);

  // Chargeback Records (6 methods)
  Future<void> createChargeback(ChargebackRecord record);
  Future<ChargebackRecord?> getChargeback(String id);
  Future<List<ChargebackRecord>> getChargebacksByCostCenter(String costCenterId);
  Future<List<ChargebackRecord>> getChargebacksByPeriod(ReportingPeriodType period);
  Future<double> getTotalChargebackAmount();
  Future<ChargebackRecord?> getLatestChargeback(String costCenterId);

  // Dashboard Widgets (6 methods)
  Future<void> createWidget(DashboardWidget widget);
  Future<DashboardWidget?> getWidget(String id);
  Future<List<DashboardWidget>> getWidgetsByDashboard(String dashboardId);
  Future<List<DashboardWidget>> getWidgetsByType(DashboardWidgetType type);
  Future<void> updateWidgetPosition(String widgetId, int x, int y);
  Future<void> deleteWidget(String widgetId);

  // FinOps Dashboards (7 methods)
  Future<void> createDashboard(FinOpsDashboard dashboard);
  Future<FinOpsDashboard?> getDashboard(String id);
  Future<List<FinOpsDashboard>> getDashboardsByOwner(String ownerId);
  Future<List<FinOpsDashboard>> getPublicDashboards();
  Future<void> addWidgetToDashboard(String dashboardId, String widgetId);
  Future<void> removeWidgetFromDashboard(String dashboardId, String widgetId);
  Future<int> getDashboardCount();

  // Financial Reports (7 methods)
  Future<void> createFinancialReport(FinancialReport report);
  Future<FinancialReport?> getFinancialReport(String id);
  Future<List<FinancialReport>> getReportsByPeriod(ReportingPeriodType period);
  Future<List<FinancialReport>> getProfitableReports();
  Future<double> getAverageMargin();
  Future<FinancialReport?> getLatestReport();
  Future<double> getTotalRevenue();

  // Unit Economics (6 methods)
  Future<void> createUnitEconomics(UnitEconomics economics);
  Future<UnitEconomics?> getUnitEconomics(String id);
  Future<List<UnitEconomics>> getUnitEconomicsByProduct(String productId);
  Future<double> getAverageMarginByProduct(String productId);
  Future<List<UnitEconomics>> getMostProfitableProducts(int limit);
  Future<double> getTotalProfitAllProducts();

  // Cost Allocation Rules (5 methods)
  Future<void> createAllocationRule(CostAllocationRule rule);
  Future<CostAllocationRule?> getAllocationRule(String id);
  Future<List<CostAllocationRule>> getActiveRules();
  Future<List<CostAllocationRule>> getUnbalancedRules();
  Future<void> deactivateRule(String ruleId);

  // Executive Summary & Export (7 methods)
  Future<void> createExecutiveSummary(ExecutiveSummary summary);
  Future<ExecutiveSummary?> getExecutiveSummary(String id);
  Future<ExecutiveSummary?> getLatestSummary();
  Future<List<ExecutiveSummary>> getSummariesByPeriod(ReportingPeriodType period);
  Future<void> createExport(ReportExport export);
  Future<List<ReportExport>> getExportsByReport(String reportId);
  Future<double> getAverageSavingsRate();
}

// ===== IN-MEMORY IMPLEMENTATION =====
class InMemoryFinOpsRepository implements FinOpsRepository {
  final Map<String, CostAttribution> _attributions = {};
  final Map<String, CostCenter> _costCenters = {};
  final Map<String, BudgetVsActual> _bvaRecords = {};
  final Map<String, ChargebackRecord> _chargebacks = {};
  final Map<String, DashboardWidget> _widgets = {};
  final Map<String, FinOpsDashboard> _dashboards = {};
  final Map<String, FinancialReport> _reports = {};
  final Map<String, UnitEconomics> _unitEconomics = {};
  final Map<String, CostAllocationRule> _rules = {};
  final Map<String, ExecutiveSummary> _summaries = {};
  final Map<String, ReportExport> _exports = {};

  @override
  Future<void> createAttribution(CostAttribution a) async => _attributions[a.id] = a;
  @override
  Future<CostAttribution?> getAttribution(String id) async => _attributions[id];
  @override
  Future<List<CostAttribution>> getAttributionsByCostCenter(String costCenterId) async =>
      _attributions.values.where((a) => a.costCenterId == costCenterId).toList();
  @override
  Future<List<CostAttribution>> getAttributionsByResource(String resourceId) async =>
      _attributions.values.where((a) => a.resourceId == resourceId).toList();
  @override
  Future<double> getTotalAttributedCost(String costCenterId) async =>
      _attributions.values.where((a) => a.costCenterId == costCenterId).fold(0.0, (s, a) => s + a.weightedAmount);
  @override
  Future<List<CostAttribution>> getAttributionsByModel(ChargebackModel model) async =>
      _attributions.values.where((a) => a.model == model).toList();

  @override
  Future<void> createCostCenter(CostCenter c) async => _costCenters[c.id] = c;
  @override
  Future<CostCenter?> getCostCenter(String id) async => _costCenters[id];
  @override
  Future<List<CostCenter>> getCostCentersByType(CostCenterType type) async =>
      _costCenters.values.where((c) => c.type == type).toList();
  @override
  Future<List<CostCenter>> getSubCenters(String parentId) async =>
      _costCenters.values.where((c) => c.parentId == parentId).toList();
  @override
  Future<List<CostCenter>> getAllCostCenters() async => _costCenters.values.toList();
  @override
  Future<double> getTotalBudgetAllCenters() async =>
      _costCenters.values.fold(0.0, (s, c) => s + c.monthlyBudget);
  @override
  Future<void> updateCostCenterBudget(String id, double newBudget) async {
    final c = _costCenters[id];
    if (c != null) {
      _costCenters[id] = CostCenter(
        id: c.id,
        name: c.name,
        type: c.type,
        parentId: c.parentId,
        monthlyBudget: newBudget,
        createdAt: c.createdAt,
      );
    }
  }

  @override
  Future<void> createBudgetVsActual(BudgetVsActual b) async => _bvaRecords[b.id] = b;
  @override
  Future<BudgetVsActual?> getBudgetVsActual(String id) async => _bvaRecords[id];
  @override
  Future<List<BudgetVsActual>> getBvaByCostCenter(String costCenterId) async =>
      _bvaRecords.values.where((b) => b.costCenterId == costCenterId).toList();
  @override
  Future<List<BudgetVsActual>> getOverBudgetRecords() async =>
      _bvaRecords.values.where((b) => b.status == VarianceStatus.overBudget || b.status == VarianceStatus.critical).toList();
  @override
  Future<List<BudgetVsActual>> getCriticalVarianceRecords() async =>
      _bvaRecords.values.where((b) => b.status == VarianceStatus.critical).toList();
  @override
  Future<double> getAverageVariancePercentage() async {
    if (_bvaRecords.isEmpty) return 0;
    return _bvaRecords.values.fold(0.0, (s, b) => s + b.variancePercentage) / _bvaRecords.length;
  }

  @override
  Future<List<BudgetVsActual>> getBvaByPeriod(ReportingPeriodType period) async =>
      _bvaRecords.values.where((b) => b.period == period).toList();

  @override
  Future<void> createChargeback(ChargebackRecord r) async => _chargebacks[r.id] = r;
  @override
  Future<ChargebackRecord?> getChargeback(String id) async => _chargebacks[id];
  @override
  Future<List<ChargebackRecord>> getChargebacksByCostCenter(String costCenterId) async =>
      _chargebacks.values.where((c) => c.costCenterId == costCenterId).toList();
  @override
  Future<List<ChargebackRecord>> getChargebacksByPeriod(ReportingPeriodType period) async =>
      _chargebacks.values.where((c) => c.period == period).toList();
  @override
  Future<double> getTotalChargebackAmount() async =>
      _chargebacks.values.fold(0.0, (s, c) => s + c.totalCost);
  @override
  Future<ChargebackRecord?> getLatestChargeback(String costCenterId) async {
    final records = await getChargebacksByCostCenter(costCenterId);
    return records.isEmpty ? null : records.reduce((a, b) => a.generatedAt.isAfter(b.generatedAt) ? a : b);
  }

  @override
  Future<void> createWidget(DashboardWidget w) async => _widgets[w.id] = w;
  @override
  Future<DashboardWidget?> getWidget(String id) async => _widgets[id];
  @override
  Future<List<DashboardWidget>> getWidgetsByDashboard(String dashboardId) async =>
      _widgets.values.where((w) => w.dashboardId == dashboardId).toList();
  @override
  Future<List<DashboardWidget>> getWidgetsByType(DashboardWidgetType type) async =>
      _widgets.values.where((w) => w.type == type).toList();
  @override
  Future<void> updateWidgetPosition(String widgetId, int x, int y) async {
    final w = _widgets[widgetId];
    if (w != null) {
      _widgets[widgetId] = DashboardWidget(
        id: w.id,
        dashboardId: w.dashboardId,
        type: w.type,
        title: w.title,
        positionX: x,
        positionY: y,
        config: w.config,
      );
    }
  }

  @override
  Future<void> deleteWidget(String widgetId) async => _widgets.remove(widgetId);

  @override
  Future<void> createDashboard(FinOpsDashboard d) async => _dashboards[d.id] = d;
  @override
  Future<FinOpsDashboard?> getDashboard(String id) async => _dashboards[id];
  @override
  Future<List<FinOpsDashboard>> getDashboardsByOwner(String ownerId) async =>
      _dashboards.values.where((d) => d.ownerId == ownerId).toList();
  @override
  Future<List<FinOpsDashboard>> getPublicDashboards() async =>
      _dashboards.values.where((d) => d.isPublic).toList();
  @override
  Future<void> addWidgetToDashboard(String dashboardId, String widgetId) async {
    final d = _dashboards[dashboardId];
    if (d != null) {
      _dashboards[dashboardId] = FinOpsDashboard(
        id: d.id,
        name: d.name,
        ownerId: d.ownerId,
        createdAt: d.createdAt,
        isPublic: d.isPublic,
        widgetIds: [...d.widgetIds, widgetId],
      );
    }
  }

  @override
  Future<void> removeWidgetFromDashboard(String dashboardId, String widgetId) async {
    final d = _dashboards[dashboardId];
    if (d != null) {
      _dashboards[dashboardId] = FinOpsDashboard(
        id: d.id,
        name: d.name,
        ownerId: d.ownerId,
        createdAt: d.createdAt,
        isPublic: d.isPublic,
        widgetIds: d.widgetIds.where((id) => id != widgetId).toList(),
      );
    }
  }

  @override
  Future<int> getDashboardCount() async => _dashboards.length;

  @override
  Future<void> createFinancialReport(FinancialReport r) async => _reports[r.id] = r;
  @override
  Future<FinancialReport?> getFinancialReport(String id) async => _reports[id];
  @override
  Future<List<FinancialReport>> getReportsByPeriod(ReportingPeriodType period) async =>
      _reports.values.where((r) => r.period == period).toList();
  @override
  Future<List<FinancialReport>> getProfitableReports() async =>
      _reports.values.where((r) => r.isProfitable).toList();
  @override
  Future<double> getAverageMargin() async {
    if (_reports.isEmpty) return 0;
    return _reports.values.fold(0.0, (s, r) => s + r.marginPercentage) / _reports.length;
  }

  @override
  Future<FinancialReport?> getLatestReport() async {
    if (_reports.isEmpty) return null;
    return _reports.values.reduce((a, b) => a.generatedAt.isAfter(b.generatedAt) ? a : b);
  }

  @override
  Future<double> getTotalRevenue() async =>
      _reports.values.fold(0.0, (s, r) => s + r.totalRevenue);

  @override
  Future<void> createUnitEconomics(UnitEconomics e) async => _unitEconomics[e.id] = e;
  @override
  Future<UnitEconomics?> getUnitEconomics(String id) async => _unitEconomics[id];
  @override
  Future<List<UnitEconomics>> getUnitEconomicsByProduct(String productId) async =>
      _unitEconomics.values.where((e) => e.productId == productId).toList();
  @override
  Future<double> getAverageMarginByProduct(String productId) async {
    final list = await getUnitEconomicsByProduct(productId);
    return list.isEmpty ? 0 : list.fold(0.0, (s, e) => s + e.margin) / list.length;
  }

  @override
  Future<List<UnitEconomics>> getMostProfitableProducts(int limit) async {
    final sorted = _unitEconomics.values.toList()
      ..sort((a, b) => b.totalProfit.compareTo(a.totalProfit));
    return sorted.take(limit).toList();
  }

  @override
  Future<double> getTotalProfitAllProducts() async =>
      _unitEconomics.values.fold(0.0, (s, e) => s + e.totalProfit);

  @override
  Future<void> createAllocationRule(CostAllocationRule r) async => _rules[r.id] = r;
  @override
  Future<CostAllocationRule?> getAllocationRule(String id) async => _rules[id];
  @override
  Future<List<CostAllocationRule>> getActiveRules() async =>
      _rules.values.where((r) => r.isActive).toList();
  @override
  Future<List<CostAllocationRule>> getUnbalancedRules() async =>
      _rules.values.where((r) => !r.isBalanced).toList();
  @override
  Future<void> deactivateRule(String ruleId) async {
    final r = _rules[ruleId];
    if (r != null) {
      _rules[ruleId] = CostAllocationRule(
        id: r.id,
        name: r.name,
        model: r.model,
        allocationWeights: r.allocationWeights,
        isActive: false,
        createdAt: r.createdAt,
      );
    }
  }

  @override
  Future<void> createExecutiveSummary(ExecutiveSummary s) async => _summaries[s.id] = s;
  @override
  Future<ExecutiveSummary?> getExecutiveSummary(String id) async => _summaries[id];
  @override
  Future<ExecutiveSummary?> getLatestSummary() async {
    if (_summaries.isEmpty) return null;
    return _summaries.values.reduce((a, b) => a.generatedAt.isAfter(b.generatedAt) ? a : b);
  }

  @override
  Future<List<ExecutiveSummary>> getSummariesByPeriod(ReportingPeriodType period) async =>
      _summaries.values.where((s) => s.period == period).toList();
  @override
  Future<void> createExport(ReportExport e) async => _exports[e.id] = e;
  @override
  Future<List<ReportExport>> getExportsByReport(String reportId) async =>
      _exports.values.where((e) => e.reportId == reportId).toList();
  @override
  Future<double> getAverageSavingsRate() async {
    if (_summaries.isEmpty) return 0;
    return _summaries.values.fold(0.0, (s, e) => s + e.savingsRate) / _summaries.length;
  }
}

// ===== ENGINES =====
class AttributionEngine {
  Future<List<CostAttribution>> distributeCost(
      double totalCost, Map<String, double> weights, String resourceId) async {
    final result = <CostAttribution>[];
    for (var entry in weights.entries) {
      result.add(CostAttribution(
        id: 'attr_${DateTime.now().microsecondsSinceEpoch}_${entry.key}',
        costCenterId: entry.key,
        resourceId: resourceId,
        amount: totalCost * (entry.value / 100),
        model: ChargebackModel.proportional,
        attributedAt: DateTime.now(),
        weight: entry.value,
      ));
    }
    return result;
  }
}

class VarianceAnalysisEngine {
  Future<VarianceStatus> analyzeVariance(double budgeted, double actual) async {
    final bva = BudgetVsActual(
      id: 'temp',
      costCenterId: 'temp',
      period: ReportingPeriodType.monthly,
      budgetedAmount: budgeted,
      actualAmount: actual,
      periodStart: DateTime.now(),
      periodEnd: DateTime.now(),
    );
    return bva.status;
  }
}

class ChargebackEngine {
  Future<ChargebackRecord> generateChargeback(
      String costCenterId, Map<String, double> breakdown, ChargebackModel model) async {
    final total = breakdown.values.fold(0.0, (a, b) => a + b);
    return ChargebackRecord(
      id: 'cb_${DateTime.now().millisecondsSinceEpoch}',
      costCenterId: costCenterId,
      totalCost: total,
      model: model,
      period: ReportingPeriodType.monthly,
      generatedAt: DateTime.now(),
      breakdown: breakdown,
    );
  }
}

class ReportGenerationEngine {
  Future<FinancialReport> generateReport(
      String title, double revenue, double cost, ReportingPeriodType period) async {
    return FinancialReport(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      period: period,
      totalRevenue: revenue,
      totalCost: cost,
      generatedAt: DateTime.now(),
      format: ExportFormat.pdf,
    );
  }
}

class ExecutiveSummaryEngine {
  Future<ExecutiveSummary> generateSummary(
      double totalSpend, double budgetUtil, int centerCount, double savings) async {
    return ExecutiveSummary(
      id: 'summary_${DateTime.now().millisecondsSinceEpoch}',
      period: ReportingPeriodType.monthly,
      totalSpend: totalSpend,
      budgetUtilization: budgetUtil,
      costCenterCount: centerCount,
      savingsAchieved: savings,
      generatedAt: DateTime.now(),
    );
  }
}

// ===== MANAGER =====
class FinOpsManager {
  final FinOpsRepository repository;
  final AttributionEngine attributionEngine;
  final VarianceAnalysisEngine varianceEngine;
  final ChargebackEngine chargebackEngine;
  final ReportGenerationEngine reportEngine;
  final ExecutiveSummaryEngine summaryEngine;

  FinOpsManager(
    this.repository,
    this.attributionEngine,
    this.varianceEngine,
    this.chargebackEngine,
    this.reportEngine,
    this.summaryEngine,
  );
}

// ===== FACADE =====
class FinOpsFacade {
  final FinOpsRepository _repository = InMemoryFinOpsRepository();
  late final FinOpsManager _manager;

  FinOpsFacade() {
    _manager = FinOpsManager(
      _repository,
      AttributionEngine(),
      VarianceAnalysisEngine(),
      ChargebackEngine(),
      ReportGenerationEngine(),
      ExecutiveSummaryEngine(),
    );
  }

  Future<CostCenter> createCostCenter(String name, CostCenterType type, double budget) async {
    final center = CostCenter(
      id: 'cc_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      monthlyBudget: budget,
      createdAt: DateTime.now(),
    );
    await _repository.createCostCenter(center);
    return center;
  }

  Future<double> getTotalOrganizationBudget() async {
    return await _repository.getTotalBudgetAllCenters();
  }

  Future<double> getAverageBudgetVariance() async {
    return await _repository.getAverageVariancePercentage();
  }

  Future<int> getCriticalBudgetIssueCount() async {
    final records = await _repository.getCriticalVarianceRecords();
    return records.length;
  }

  Future<double> getOrganizationMargin() async {
    return await _repository.getAverageMargin();
  }

  Future<ExecutiveSummary?> getLatestExecutiveSummary() async {
    return await _repository.getLatestSummary();
  }
}
