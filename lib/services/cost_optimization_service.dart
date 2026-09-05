// Phase 82: Cost Optimization & Resource Management System
// Service layer with Repository, Engines, Manager, and Facade

import 'package:project_040/models/cost_optimization_models.dart';

// ===== REPOSITORY INTERFACE =====
abstract class CostRepository {
  // Cost Record Management (6 methods)
  Future<void> createCostRecord(CostRecord record);
  Future<CostRecord?> getCostRecord(String id);
  Future<List<CostRecord>> getCostRecordsByResource(String resourceId);
  Future<List<CostRecord>> getCostRecordsByCategory(CostCategory category);
  Future<List<CostRecord>> getCostRecordsInDateRange(DateTime start, DateTime end);
  Future<double> getTotalCostByCategory(CostCategory category);

  // Budget Allocation Management (8 methods)
  Future<void> createBudgetAllocation(BudgetAllocation allocation);
  Future<BudgetAllocation?> getBudgetAllocation(String id);
  Future<List<BudgetAllocation>> getBudgetsByProject(String projectId);
  Future<List<BudgetAllocation>> getOverBudgetAllocations();
  Future<double> getTotalBudgetByProject(String projectId);
  Future<void> updateSpentAmount(String allocationId, double amount);
  Future<List<BudgetAllocation>> getBudgetsByCategory(CostCategory category);
  Future<double> getProjectBudgetUtilization(String projectId);

  // Resource Utilization (7 methods)
  Future<void> createUtilization(ResourceUtilization utilization);
  Future<ResourceUtilization?> getUtilization(String id);
  Future<List<ResourceUtilization>> getUtilizationByResource(String resourceId);
  Future<List<ResourceUtilization>> getUnderutilizedResources();
  Future<List<ResourceUtilization>> getOverutilizedResources();
  Future<double> getAverageUtilization(String resourceId);
  Future<List<ResourceUtilization>> getUtilizationTrend(String resourceId, int days);

  // Optimization Opportunities (8 methods)
  Future<void> createOpportunity(OptimizationOpportunity opportunity);
  Future<OptimizationOpportunity?> getOpportunity(String id);
  Future<List<OptimizationOpportunity>> getOpportunitiesByResource(String resourceId);
  Future<List<OptimizationOpportunity>> getOpportunitiesBySeverity(OptimizationSeverity severity);
  Future<double> getTotalPotentialSavings();
  Future<List<OptimizationOpportunity>> getSignificantOpportunities();
  Future<int> getActiveOpportunityCount();
  Future<void> markOpportunityResolved(String opportunityId);

  // Cost Forecasting (8 methods)
  Future<void> createForecast(CostForecast forecast);
  Future<CostForecast?> getForecast(String id);
  Future<List<CostForecast>> getForecastsByProject(String projectId);
  Future<CostForecast?> getLatestForecast(String projectId);
  Future<double> getAverageForecastedCost(String projectId, int months);
  Future<List<CostForecast>> getHighConfidenceForecasts();
  Future<double> getForecastedAnnualCost(String projectId);
  Future<List<CostForecast>> getForecastTrend(String projectId, int months);

  // Reserved Instances (8 methods)
  Future<void> createReservedInstance(ReservedInstance instance);
  Future<ReservedInstance?> getReservedInstance(String id);
  Future<List<ReservedInstance>> getReservedInstancesByType(String resourceType);
  Future<List<ReservedInstance>> getExpiringReservations();
  Future<double> getTotalDiscountValue();
  Future<int> getActiveReservationCount();
  Future<void> renewReservation(String instanceId, DateTime newExpiryDate);
  Future<double> getMonthlyReservationSavings();

  // Cost Trends (7 methods)
  Future<void> createTrend(CostTrend trend);
  Future<CostTrend?> getTrend(String id);
  Future<List<CostTrend>> getTrendsByProject(String projectId);
  Future<List<CostTrend>> getTrendsByCategory(CostCategory category);
  Future<List<CostTrend>> getAcceleratingTrends();
  Future<double> getAnnualTrendChangePercentage(String projectId);
  Future<List<CostTrend>> getTrendAnalysis(String projectId, int months);

  // Cost Anomalies (7 methods)
  Future<void> createAnomaly(CostAnomaly anomaly);
  Future<CostAnomaly?> getAnomaly(String id);
  Future<List<CostAnomaly>> getAnomaliesByResource(String resourceId);
  Future<List<CostAnomaly>> getAnomaliesBySeverity(OptimizationSeverity severity);
  Future<int> getRecentAnomalyCount(int hours);
  Future<List<CostAnomaly>> getSignificantAnomalies();
  Future<double> getAnomalyFrequency(String resourceId);

  // Cost Reports (6 methods)
  Future<void> createReport(CostOptimizationReport report);
  Future<CostOptimizationReport?> getReport(String id);
  Future<CostOptimizationReport?> getLatestReportByProject(String projectId);
  Future<List<CostOptimizationReport>> getReportsByProject(String projectId);
  Future<double> getAverageSavingsPercentage();
  Future<List<CostOptimizationReport>> getReportsInDateRange(DateTime start, DateTime end);

  // Resource Allocations (8 methods)
  Future<void> createAllocation(ResourceAllocation allocation);
  Future<ResourceAllocation?> getAllocation(String id);
  Future<List<ResourceAllocation>> getAllocationsByProject(String projectId);
  Future<List<ResourceAllocation>> getUnderutilizedAllocations();
  Future<double> getTotalWastedCapacity();
  Future<double> getProjectAllocationUtilization(String projectId);
  Future<void> updateAllocationUsage(String allocationId, double usedCapacity);
  Future<List<ResourceAllocation>> getAllocationsByStrategy(AllocationStrategy strategy);

  // Cost Alerts (6 methods)
  Future<void> createAlert(CostAlert alert);
  Future<CostAlert?> getAlert(String id);
  Future<List<CostAlert>> getActiveAlerts();
  Future<List<CostAlert>> getAlertsByProject(String projectId);
  Future<void> acknowledgeAlert(String alertId);
  Future<int> getUrgentAlertCount();
}

// ===== IN-MEMORY IMPLEMENTATION =====
class InMemoryCostRepository implements CostRepository {
  final Map<String, CostRecord> _costRecords = {};
  final Map<String, BudgetAllocation> _budgets = {};
  final Map<String, ResourceUtilization> _utilizations = {};
  final Map<String, OptimizationOpportunity> _opportunities = {};
  final Map<String, CostForecast> _forecasts = {};
  final Map<String, ReservedInstance> _reservations = {};
  final Map<String, CostTrend> _trends = {};
  final Map<String, CostAnomaly> _anomalies = {};
  final Map<String, CostOptimizationReport> _reports = {};
  final Map<String, ResourceAllocation> _allocations = {};
  final Map<String, CostAlert> _alerts = {};

  @override
  Future<void> createCostRecord(CostRecord record) async => _costRecords[record.id] = record;
  @override
  Future<CostRecord?> getCostRecord(String id) async => _costRecords[id];
  @override
  Future<List<CostRecord>> getCostRecordsByResource(String resourceId) async =>
      _costRecords.values.where((r) => r.resourceId == resourceId).toList();
  @override
  Future<List<CostRecord>> getCostRecordsByCategory(CostCategory category) async =>
      _costRecords.values.where((r) => r.category == category).toList();
  @override
  Future<List<CostRecord>> getCostRecordsInDateRange(DateTime start, DateTime end) async =>
      _costRecords.values.where((r) => r.recordedAt.isAfter(start) && r.recordedAt.isBefore(end)).toList();
  @override
  Future<double> getTotalCostByCategory(CostCategory category) async {
    return _costRecords.values
        .where((r) => r.category == category)
        .fold(0.0, (sum, r) => sum + r.amount);
  }

  @override
  Future<void> createBudgetAllocation(BudgetAllocation allocation) async => _budgets[allocation.id] = allocation;
  @override
  Future<BudgetAllocation?> getBudgetAllocation(String id) async => _budgets[id];
  @override
  Future<List<BudgetAllocation>> getBudgetsByProject(String projectId) async =>
      _budgets.values.where((b) => b.projectId == projectId).toList();
  @override
  Future<List<BudgetAllocation>> getOverBudgetAllocations() async =>
      _budgets.values.where((b) => b.isOverBudget).toList();
  @override
  Future<double> getTotalBudgetByProject(String projectId) async {
    return _budgets.values
        .where((b) => b.projectId == projectId)
        .fold(0.0, (sum, b) => sum + b.allocatedAmount);
  }

  @override
  Future<void> updateSpentAmount(String allocationId, double amount) async {
    final budget = _budgets[allocationId];
    if (budget != null) {
      _budgets[allocationId] =
          BudgetAllocation(
            id: budget.id,
            projectId: budget.projectId,
            category: budget.category,
            allocatedAmount: budget.allocatedAmount,
            spentAmount: amount,
            startDate: budget.startDate,
            endDate: budget.endDate,
            strategy: budget.strategy,
          );
    }
  }

  @override
  Future<List<BudgetAllocation>> getBudgetsByCategory(CostCategory category) async =>
      _budgets.values.where((b) => b.category == category).toList();
  @override
  Future<double> getProjectBudgetUtilization(String projectId) async {
    final budgets = await getBudgetsByProject(projectId);
    if (budgets.isEmpty) return 0;
    double totalSpent = budgets.fold(0.0, (sum, b) => sum + b.spentAmount);
    double totalAllocated = budgets.fold(0.0, (sum, b) => sum + b.allocatedAmount);
    return totalAllocated > 0 ? (totalSpent / totalAllocated) * 100 : 0;
  }

  @override
  Future<void> createUtilization(ResourceUtilization utilization) async =>
      _utilizations[utilization.id] = utilization;
  @override
  Future<ResourceUtilization?> getUtilization(String id) async => _utilizations[id];
  @override
  Future<List<ResourceUtilization>> getUtilizationByResource(String resourceId) async =>
      _utilizations.values.where((u) => u.resourceId == resourceId).toList();
  @override
  Future<List<ResourceUtilization>> getUnderutilizedResources() async =>
      _utilizations.values.where((u) => u.isUnderutilized).toList();
  @override
  Future<List<ResourceUtilization>> getOverutilizedResources() async =>
      _utilizations.values.where((u) => u.isOverutilized).toList();
  @override
  Future<double> getAverageUtilization(String resourceId) async {
    final utils = await getUtilizationByResource(resourceId);
    return utils.isEmpty ? 0 : utils.map((u) => u.averageUtilization).reduce((a, b) => a + b) / utils.length;
  }

  @override
  Future<List<ResourceUtilization>> getUtilizationTrend(String resourceId, int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _utilizations.values
        .where((u) => u.resourceId == resourceId && u.measuredAt.isAfter(cutoff))
        .toList();
  }

  @override
  Future<void> createOpportunity(OptimizationOpportunity opportunity) async =>
      _opportunities[opportunity.id] = opportunity;
  @override
  Future<OptimizationOpportunity?> getOpportunity(String id) async => _opportunities[id];
  @override
  Future<List<OptimizationOpportunity>> getOpportunitiesByResource(String resourceId) async =>
      _opportunities.values.where((o) => o.resourceId == resourceId).toList();
  @override
  Future<List<OptimizationOpportunity>> getOpportunitiesBySeverity(OptimizationSeverity severity) async =>
      _opportunities.values.where((o) => o.severity == severity).toList();
  @override
  Future<double> getTotalPotentialSavings() async =>
      _opportunities.values.fold(0.0, (sum, o) => sum + o.potentialSavings);
  @override
  Future<List<OptimizationOpportunity>> getSignificantOpportunities() async =>
      _opportunities.values.where((o) => o.isSignificant).toList();
  @override
  Future<int> getActiveOpportunityCount() async => _opportunities.length;
  @override
  Future<void> markOpportunityResolved(String opportunityId) async => _opportunities.remove(opportunityId);

  @override
  Future<void> createForecast(CostForecast forecast) async => _forecasts[forecast.id] = forecast;
  @override
  Future<CostForecast?> getForecast(String id) async => _forecasts[id];
  @override
  Future<List<CostForecast>> getForecastsByProject(String projectId) async =>
      _forecasts.values.where((f) => f.projectId == projectId).toList();
  @override
  Future<CostForecast?> getLatestForecast(String projectId) async {
    final forecasts = await getForecastsByProject(projectId);
    return forecasts.isEmpty ? null : forecasts.reduce((a, b) => a.forecastDate.isAfter(b.forecastDate) ? a : b);
  }

  @override
  Future<double> getAverageForecastedCost(String projectId, int months) async {
    final forecasts = await getForecastsByProject(projectId);
    return forecasts.isEmpty ? 0 : forecasts.map((f) => f.predictedCost).reduce((a, b) => a + b) / forecasts.length;
  }

  @override
  Future<List<CostForecast>> getHighConfidenceForecasts() async =>
      _forecasts.values.where((f) => f.confidence == ForecastConfidence.high || f.confidence == ForecastConfidence.veryHigh).toList();
  @override
  Future<double> getForecastedAnnualCost(String projectId) async {
    final latest = await getLatestForecast(projectId);
    return latest != null ? latest.predictedCost * 12 : 0;
  }

  @override
  Future<List<CostForecast>> getForecastTrend(String projectId, int months) async {
    final cutoff = DateTime.now().subtract(Duration(days: months * 30));
    return _forecasts.values
        .where((f) => f.projectId == projectId && f.forecastDate.isAfter(cutoff))
        .toList();
  }

  @override
  Future<void> createReservedInstance(ReservedInstance instance) async =>
      _reservations[instance.id] = instance;
  @override
  Future<ReservedInstance?> getReservedInstance(String id) async => _reservations[id];
  @override
  Future<List<ReservedInstance>> getReservedInstancesByType(String resourceType) async =>
      _reservations.values.where((r) => r.resourceType == resourceType).toList();
  @override
  Future<List<ReservedInstance>> getExpiringReservations() async =>
      _reservations.values.where((r) => r.isExpiring).toList();
  @override
  Future<double> getTotalDiscountValue() async =>
      _reservations.values.fold(0.0, (sum, r) => sum + r.monthlyDiscountAmount);
  @override
  Future<int> getActiveReservationCount() async =>
      _reservations.values.where((r) => r.status == ReservationStatus.active).length;
  @override
  Future<void> renewReservation(String instanceId, DateTime newExpiryDate) async {
    final res = _reservations[instanceId];
    if (res != null) {
      _reservations[instanceId] = ReservedInstance(
        id: res.id,
        resourceType: res.resourceType,
        quantity: res.quantity,
        purchaseDate: res.purchaseDate,
        expiryDate: newExpiryDate,
        discountPercentage: res.discountPercentage,
        status: ReservationStatus.active,
      );
    }
  }

  @override
  Future<double> getMonthlyReservationSavings() async => await getTotalDiscountValue();

  @override
  Future<void> createTrend(CostTrend trend) async => _trends[trend.id] = trend;
  @override
  Future<CostTrend?> getTrend(String id) async => _trends[id];
  @override
  Future<List<CostTrend>> getTrendsByProject(String projectId) async =>
      _trends.values.where((t) => t.projectId == projectId).toList();
  @override
  Future<List<CostTrend>> getTrendsByCategory(CostCategory category) async =>
      _trends.values.where((t) => t.category == category).toList();
  @override
  Future<List<CostTrend>> getAcceleratingTrends() async =>
      _trends.values.where((t) => t.isAccelerating).toList();
  @override
  Future<double> getAnnualTrendChangePercentage(String projectId) async {
    final trends = await getTrendsByProject(projectId);
    return trends.isEmpty ? 0 : trends.map((t) => t.changePercentage).reduce((a, b) => a + b) / trends.length;
  }

  @override
  Future<List<CostTrend>> getTrendAnalysis(String projectId, int months) async {
    final cutoff = DateTime.now().subtract(Duration(days: months * 30));
    return _trends.values
        .where((t) => t.projectId == projectId && t.analyzedAt.isAfter(cutoff))
        .toList();
  }

  @override
  Future<void> createAnomaly(CostAnomaly anomaly) async => _anomalies[anomaly.id] = anomaly;
  @override
  Future<CostAnomaly?> getAnomaly(String id) async => _anomalies[id];
  @override
  Future<List<CostAnomaly>> getAnomaliesByResource(String resourceId) async =>
      _anomalies.values.where((a) => a.resourceId == resourceId).toList();
  @override
  Future<List<CostAnomaly>> getAnomaliesBySeverity(OptimizationSeverity severity) async =>
      _anomalies.values.where((a) => a.severity == severity).toList();
  @override
  Future<int> getRecentAnomalyCount(int hours) async {
    final cutoff = DateTime.now().subtract(Duration(hours: hours));
    return _anomalies.values.where((a) => a.detectedAt.isAfter(cutoff)).length;
  }

  @override
  Future<List<CostAnomaly>> getSignificantAnomalies() async =>
      _anomalies.values.where((a) => a.isSignificantDeviation).toList();
  @override
  Future<double> getAnomalyFrequency(String resourceId) async {
    final anomalies = await getAnomaliesByResource(resourceId);
    return anomalies.isEmpty ? 0 : anomalies.length.toDouble();
  }

  @override
  Future<void> createReport(CostOptimizationReport report) async => _reports[report.id] = report;
  @override
  Future<CostOptimizationReport?> getReport(String id) async => _reports[id];
  @override
  Future<CostOptimizationReport?> getLatestReportByProject(String projectId) async {
    final reports = await getReportsByProject(projectId);
    return reports.isEmpty ? null : reports.reduce((a, b) => a.generatedAt.isAfter(b.generatedAt) ? a : b);
  }

  @override
  Future<List<CostOptimizationReport>> getReportsByProject(String projectId) async =>
      _reports.values.where((r) => r.projectId == projectId).toList();
  @override
  Future<double> getAverageSavingsPercentage() async {
    if (_reports.isEmpty) return 0;
    return _reports.values.fold(0.0, (sum, r) => sum + r.savingsPercentage) / _reports.length;
  }

  @override
  Future<List<CostOptimizationReport>> getReportsInDateRange(DateTime start, DateTime end) async =>
      _reports.values.where((r) => r.generatedAt.isAfter(start) && r.generatedAt.isBefore(end)).toList();

  @override
  Future<void> createAllocation(ResourceAllocation allocation) async =>
      _allocations[allocation.id] = allocation;
  @override
  Future<ResourceAllocation?> getAllocation(String id) async => _allocations[id];
  @override
  Future<List<ResourceAllocation>> getAllocationsByProject(String projectId) async =>
      _allocations.values.where((a) => a.projectId == projectId).toList();
  @override
  Future<List<ResourceAllocation>> getUnderutilizedAllocations() async =>
      _allocations.values.where((a) => a.isUnderutilized).toList();
  @override
  Future<double> getTotalWastedCapacity() async =>
      _allocations.values.fold(0.0, (sum, a) => sum + a.wastedCapacity);
  @override
  Future<double> getProjectAllocationUtilization(String projectId) async {
    final allocations = await getAllocationsByProject(projectId);
    if (allocations.isEmpty) return 0;
    double totalUsed = allocations.fold(0.0, (sum, a) => sum + a.usedCapacity);
    double totalAllocated = allocations.fold(0.0, (sum, a) => sum + a.allocatedCapacity);
    return totalAllocated > 0 ? (totalUsed / totalAllocated) * 100 : 0;
  }

  @override
  Future<void> updateAllocationUsage(String allocationId, double usedCapacity) async {
    final alloc = _allocations[allocationId];
    if (alloc != null) {
      _allocations[allocationId] = ResourceAllocation(
        id: alloc.id,
        projectId: alloc.projectId,
        resourceType: alloc.resourceType,
        allocatedCapacity: alloc.allocatedCapacity,
        usedCapacity: usedCapacity,
        strategy: alloc.strategy,
        allocationDate: alloc.allocationDate,
      );
    }
  }

  @override
  Future<List<ResourceAllocation>> getAllocationsByStrategy(AllocationStrategy strategy) async =>
      _allocations.values.where((a) => a.strategy == strategy).toList();

  @override
  Future<void> createAlert(CostAlert alert) async => _alerts[alert.id] = alert;
  @override
  Future<CostAlert?> getAlert(String id) async => _alerts[id];
  @override
  Future<List<CostAlert>> getActiveAlerts() async =>
      _alerts.values.where((a) => a.isActive).toList();
  @override
  Future<List<CostAlert>> getAlertsByProject(String projectId) async =>
      _alerts.values.where((a) => a.projectId == projectId).toList();
  @override
  Future<void> acknowledgeAlert(String alertId) async {
    final alert = _alerts[alertId];
    if (alert != null) {
      _alerts[alertId] = CostAlert(
        id: alert.id,
        projectId: alert.projectId,
        message: alert.message,
        severity: alert.severity,
        createdAt: alert.createdAt,
        isAcknowledged: true,
        resolution: alert.resolution,
      );
    }
  }

  @override
  Future<int> getUrgentAlertCount() async =>
      _alerts.values.where((a) => a.isUrgent).length;
}

// ===== ENGINES =====
class CostAnalysisEngine {
  Future<double> calculateOptimalAllocation(List<ResourceUtilization> utilizations) async {
    if (utilizations.isEmpty) return 0;
    return utilizations.map((u) => u.averageUtilization).reduce((a, b) => a + b) / utilizations.length;
  }

  Future<List<OptimizationOpportunity>> identifyOptimizations(
      List<ResourceUtilization> utils,
      List<CostRecord> records) async {
    return [];
  }
}

class ForecastingEngine {
  Future<CostForecast> generateForecast(List<CostRecord> history, String projectId) async {
    if (history.isEmpty) {
      return CostForecast(
        id: 'forecast_${DateTime.now().millisecondsSinceEpoch}',
        projectId: projectId,
        forecastDate: DateTime.now().add(Duration(days: 30)),
        predictedCost: 0,
        confidence: ForecastConfidence.low,
        historicalData: [],
      );
    }
    final values = history.map((r) => r.amount).toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    return CostForecast(
      id: 'forecast_${DateTime.now().millisecondsSinceEpoch}',
      projectId: projectId,
      forecastDate: DateTime.now().add(Duration(days: 30)),
      predictedCost: avg,
      confidence: ForecastConfidence.medium,
      historicalData: values,
    );
  }
}

class AnomalyDetectionEngine {
  Future<CostAnomaly?> detectAnomaly(CostRecord record, double expectedValue) async {
    if ((record.amount - expectedValue).abs() > expectedValue * 0.2) {
      return CostAnomaly(
        id: 'anomaly_${DateTime.now().millisecondsSinceEpoch}',
        resourceId: record.resourceId,
        anomalyValue: record.amount,
        expectedValue: expectedValue,
        description: 'Cost deviation detected',
        detectedAt: DateTime.now(),
        severity: OptimizationSeverity.high,
      );
    }
    return null;
  }
}

class ReservationEngine {
  Future<double> calculateReservationROI(ReservedInstance reservation, double onDemandCost) async {
    final discountValue = reservation.monthlyDiscountAmount;
    return (discountValue / onDemandCost) * 100;
  }
}

class AlertingEngine {
  Future<CostAlert?> evaluateCostAlert(BudgetAllocation budget) async {
    if (budget.utilizationPercentage > 80) {
      return CostAlert(
        id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
        projectId: budget.projectId,
        message: 'Budget alert: ${budget.utilizationPercentage.toStringAsFixed(1)}% utilized',
        severity: OptimizationSeverity.high,
        createdAt: DateTime.now(),
        isAcknowledged: false,
      );
    }
    return null;
  }
}

// ===== MANAGER =====
class CostManager {
  final CostRepository repository;
  final CostAnalysisEngine analysisEngine;
  final ForecastingEngine forecastingEngine;
  final AnomalyDetectionEngine anomalyEngine;
  final ReservationEngine reservationEngine;
  final AlertingEngine alertingEngine;

  CostManager(
    this.repository,
    this.analysisEngine,
    this.forecastingEngine,
    this.anomalyEngine,
    this.reservationEngine,
    this.alertingEngine,
  );

  Future<void> processCostOptimization(String projectId) async {
    // Placeholder for comprehensive cost optimization processing
  }
}

// ===== FACADE =====
class CostFacade {
  final CostRepository _repository = InMemoryCostRepository();
  late final CostManager _manager;

  CostFacade() {
    _manager = CostManager(
      _repository,
      CostAnalysisEngine(),
      ForecastingEngine(),
      AnomalyDetectionEngine(),
      ReservationEngine(),
      AlertingEngine(),
    );
  }

  Future<void> recordCost(String resourceId, CostCategory category, double amount) async {
    final record = CostRecord(
      id: 'cost_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      category: category,
      amount: amount,
      recordedAt: DateTime.now(),
      currency: 'USD',
    );
    await _repository.createCostRecord(record);
  }

  Future<double> getTotalSpend(String projectId) async {
    final budgets = await _repository.getBudgetsByProject(projectId);
    return budgets.fold(0.0, (sum, b) => sum + b.spentAmount);
  }

  Future<double> getProjectSavingsPotential(String projectId) async {
    return await _repository.getTotalPotentialSavings();
  }

  Future<int> getCriticalOpportunityCount() async {
    final opportunities = await _repository.getOpportunitiesBySeverity(OptimizationSeverity.critical);
    return opportunities.length;
  }

  Future<double> getAnnualizedCostForecast(String projectId) async {
    return await _repository.getForecastedAnnualCost(projectId);
  }

  Future<double> getReservationSavingsMonthly() async {
    return await _repository.getMonthlyReservationSavings();
  }

  Future<int> getUrgentAlertsCount() async {
    return await _repository.getUrgentAlertCount();
  }
}
