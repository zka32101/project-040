// Phase 83: Financial Reporting & FinOps Dashboard System
// Models for cost attribution, chargeback, and executive financial reporting

enum ChargebackModel {
  direct,
  proportional,
  fixed,
  usageBased,
  hybrid,
}

enum ReportingPeriodType {
  daily,
  weekly,
  monthly,
  quarterly,
  annual,
}

enum VarianceStatus {
  onTarget,
  underBudget,
  overBudget,
  critical,
}

enum DashboardWidgetType {
  lineChart,
  barChart,
  pieChart,
  gauge,
  table,
  kpi,
  heatmap,
}

enum CostCenterType {
  engineering,
  product,
  sales,
  marketing,
  operations,
  shared,
}

enum ExportFormat {
  pdf,
  csv,
  xlsx,
  json,
}

class CostAttribution {
  final String id;
  final String costCenterId;
  final String resourceId;
  final double amount;
  final ChargebackModel model;
  final DateTime attributedAt;
  final double? weight;

  CostAttribution({
    required this.id,
    required this.costCenterId,
    required this.resourceId,
    required this.amount,
    required this.model,
    required this.attributedAt,
    this.weight,
  });

  double get weightedAmount => weight != null ? amount * weight! : amount;
  bool get isRecent => DateTime.now().difference(attributedAt).inDays < 7;
}

class CostCenter {
  final String id;
  final String name;
  final CostCenterType type;
  final String? parentId;
  final double monthlyBudget;
  final DateTime createdAt;

  CostCenter({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    required this.monthlyBudget,
    required this.createdAt,
  });

  bool get isSubCenter => parentId != null;
  double get dailyBudget => monthlyBudget / 30;
}

class BudgetVsActual {
  final String id;
  final String costCenterId;
  final ReportingPeriodType period;
  final double budgetedAmount;
  final double actualAmount;
  final DateTime periodStart;
  final DateTime periodEnd;

  BudgetVsActual({
    required this.id,
    required this.costCenterId,
    required this.period,
    required this.budgetedAmount,
    required this.actualAmount,
    required this.periodStart,
    required this.periodEnd,
  });

  double get variance => actualAmount - budgetedAmount;
  double get variancePercentage => budgetedAmount != 0 ? (variance / budgetedAmount) * 100 : 0;
  VarianceStatus get status {
    final pct = variancePercentage;
    if (pct.abs() <= 5) return VarianceStatus.onTarget;
    if (pct < -5) return VarianceStatus.underBudget;
    if (pct > 25) return VarianceStatus.critical;
    return VarianceStatus.overBudget;
  }
}

class ChargebackRecord {
  final String id;
  final String costCenterId;
  final double totalCost;
  final ChargebackModel model;
  final ReportingPeriodType period;
  final DateTime generatedAt;
  final Map<String, double> breakdown;

  ChargebackRecord({
    required this.id,
    required this.costCenterId,
    required this.totalCost,
    required this.model,
    required this.period,
    required this.generatedAt,
    required this.breakdown,
  });

  int get lineItemCount => breakdown.length;
  double get averageLineItem => breakdown.isEmpty ? 0 : totalCost / breakdown.length;
}

class DashboardWidget {
  final String id;
  final String dashboardId;
  final DashboardWidgetType type;
  final String title;
  final int positionX;
  final int positionY;
  final Map<String, dynamic> config;

  DashboardWidget({
    required this.id,
    required this.dashboardId,
    required this.type,
    required this.title,
    required this.positionX,
    required this.positionY,
    required this.config,
  });

  bool get hasConfig => config.isNotEmpty;
}

class FinOpsDashboard {
  final String id;
  final String name;
  final String ownerId;
  final DateTime createdAt;
  final bool isPublic;
  final List<String> widgetIds;

  FinOpsDashboard({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.createdAt,
    required this.isPublic,
    required this.widgetIds,
  });

  int get widgetCount => widgetIds.length;
  bool get isEmpty => widgetIds.isEmpty;
}

class FinancialReport {
  final String id;
  final String title;
  final ReportingPeriodType period;
  final double totalRevenue;
  final double totalCost;
  final DateTime generatedAt;
  final ExportFormat format;

  FinancialReport({
    required this.id,
    required this.title,
    required this.period,
    required this.totalRevenue,
    required this.totalCost,
    required this.generatedAt,
    required this.format,
  });

  double get grossMargin => totalRevenue - totalCost;
  double get marginPercentage => totalRevenue != 0 ? (grossMargin / totalRevenue) * 100 : 0;
  bool get isProfitable => grossMargin > 0;
}

class UnitEconomics {
  final String id;
  final String productId;
  final double costPerUnit;
  final double revenuePerUnit;
  final int unitsProcessed;
  final DateTime calculatedAt;

  UnitEconomics({
    required this.id,
    required this.productId,
    required this.costPerUnit,
    required this.revenuePerUnit,
    required this.unitsProcessed,
    required this.calculatedAt,
  });

  double get profitPerUnit => revenuePerUnit - costPerUnit;
  double get totalProfit => profitPerUnit * unitsProcessed;
  double get margin => revenuePerUnit != 0 ? (profitPerUnit / revenuePerUnit) * 100 : 0;
}

class CostAllocationRule {
  final String id;
  final String name;
  final ChargebackModel model;
  final Map<String, double> allocationWeights;
  final bool isActive;
  final DateTime createdAt;

  CostAllocationRule({
    required this.id,
    required this.name,
    required this.model,
    required this.allocationWeights,
    required this.isActive,
    required this.createdAt,
  });

  double get totalWeight => allocationWeights.values.fold(0.0, (a, b) => a + b);
  bool get isBalanced => (totalWeight - 100.0).abs() < 0.01;
}

class ExecutiveSummary {
  final String id;
  final ReportingPeriodType period;
  final double totalSpend;
  final double budgetUtilization;
  final int costCenterCount;
  final double savingsAchieved;
  final DateTime generatedAt;

  ExecutiveSummary({
    required this.id,
    required this.period,
    required this.totalSpend,
    required this.budgetUtilization,
    required this.costCenterCount,
    required this.savingsAchieved,
    required this.generatedAt,
  });

  bool get isOverBudget => budgetUtilization > 100;
  double get savingsRate => totalSpend != 0 ? (savingsAchieved / totalSpend) * 100 : 0;
}

class ReportExport {
  final String id;
  final String reportId;
  final ExportFormat format;
  final DateTime exportedAt;
  final String? downloadUrl;
  final int sizeBytes;

  ReportExport({
    required this.id,
    required this.reportId,
    required this.format,
    required this.exportedAt,
    this.downloadUrl,
    required this.sizeBytes,
  });

  double get sizeMB => sizeBytes / (1024 * 1024);
  bool get isLargeFile => sizeMB > 10;
}
