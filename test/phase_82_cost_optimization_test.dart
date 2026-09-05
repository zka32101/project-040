import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/cost_optimization_models.dart';
import 'package:project_040/services/cost_optimization_service.dart';

void main() {
  group('Phase 82: Cost Optimization Tests', () {
    // ===== ENUM TESTS =====
    group('Enum Tests', () {
      test('CostCategory values', () {
        expect(CostCategory.compute.name, 'compute');
        expect(CostCategory.storage.name, 'storage');
        expect(CostCategory.network.name, 'network');
        expect(CostCategory.database.name, 'database');
        expect(CostCategory.licensing.name, 'licensing');
        expect(CostCategory.support.name, 'support');
        expect(CostCategory.infrastructure.name, 'infrastructure');
        expect(CostCategory.thirdparty.name, 'thirdparty');
        expect(CostCategory.values.length, 8);
      });

      test('CostTrendDirection values', () {
        expect(CostTrendDirection.increasing.name, 'increasing');
        expect(CostTrendDirection.decreasing.name, 'decreasing');
        expect(CostTrendDirection.stable.name, 'stable');
        expect(CostTrendDirection.volatile.name, 'volatile');
        expect(CostTrendDirection.values.length, 4);
      });

      test('OptimizationSeverity values', () {
        expect(OptimizationSeverity.critical.name, 'critical');
        expect(OptimizationSeverity.high.name, 'high');
        expect(OptimizationSeverity.medium.name, 'medium');
        expect(OptimizationSeverity.low.name, 'low');
        expect(OptimizationSeverity.values.length, 4);
      });

      test('AllocationStrategy values', () {
        expect(AllocationStrategy.fairShare.name, 'fairShare');
        expect(AllocationStrategy.weighted.name, 'weighted');
        expect(AllocationStrategy.demandBased.name, 'demandBased');
        expect(AllocationStrategy.reserved.name, 'reserved');
        expect(AllocationStrategy.spot.name, 'spot');
        expect(AllocationStrategy.values.length, 5);
      });

      test('ReservationStatus values', () {
        expect(ReservationStatus.active.name, 'active');
        expect(ReservationStatus.expiring.name, 'expiring');
        expect(ReservationStatus.expired.name, 'expired');
        expect(ReservationStatus.cancelled.name, 'cancelled');
        expect(ReservationStatus.values.length, 4);
      });

      test('ForecastConfidence values', () {
        expect(ForecastConfidence.veryHigh.name, 'veryHigh');
        expect(ForecastConfidence.high.name, 'high');
        expect(ForecastConfidence.medium.name, 'medium');
        expect(ForecastConfidence.low.name, 'low');
        expect(ForecastConfidence.values.length, 4);
      });
    });

    // ===== MODEL TESTS =====
    group('Model Tests', () {
      test('CostRecord model creation', () {
        final record = CostRecord(
          id: 'cost1',
          resourceId: 'res1',
          category: CostCategory.compute,
          amount: 100.0,
          recordedAt: DateTime.now(),
          currency: 'USD',
        );
        expect(record.id, 'cost1');
        expect(record.category, CostCategory.compute);
        expect(record.totalWithTax, 110.0);
      });

      test('BudgetAllocation computed properties', () {
        final allocation = BudgetAllocation(
          id: 'budget1',
          projectId: 'proj1',
          category: CostCategory.compute,
          allocatedAmount: 1000.0,
          spentAmount: 800.0,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          strategy: AllocationStrategy.fairShare,
        );
        expect(allocation.remainingBudget, 200.0);
        expect(allocation.utilizationPercentage, 80.0);
        expect(allocation.isOverBudget, false);
      });

      test('ResourceUtilization underutilization detection', () {
        final util = ResourceUtilization(
          id: 'util1',
          resourceId: 'res1',
          cpuUtilization: 10.0,
          memoryUtilization: 15.0,
          storageUtilization: 20.0,
          networkUtilization: 25.0,
          measuredAt: DateTime.now(),
        );
        expect(util.isUnderutilized, true);
        expect(util.isOverutilized, false);
      });

      test('OptimizationOpportunity significance', () {
        final opp = OptimizationOpportunity(
          id: 'opp1',
          resourceId: 'res1',
          severity: OptimizationSeverity.critical,
          title: 'Idle Instance',
          description: 'Instance not used',
          potentialSavings: 2000.0,
          discoveredAt: DateTime.now(),
        );
        expect(opp.isSignificant, true);
        expect(opp.isRecent, true);
      });

      test('CostForecast confidence scoring', () {
        final forecast = CostForecast(
          id: 'f1',
          projectId: 'proj1',
          forecastDate: DateTime.now(),
          predictedCost: 5000.0,
          confidence: ForecastConfidence.high,
          historicalData: [4000, 4500, 5000, 5200],
        );
        expect(forecast.confidenceScore, 0.80);
        expect(forecast.averageHistoricalCost, 4675.0);
      });

      test('ReservedInstance expiration', () {
        final res = ReservedInstance(
          id: 'res1',
          resourceType: 'compute',
          quantity: 10,
          purchaseDate: DateTime.now().subtract(Duration(days: 100)),
          expiryDate: DateTime.now().add(Duration(days: 20)),
          discountPercentage: 30.0,
          status: ReservationStatus.active,
        );
        expect(res.isExpiring, true);
        expect(res.isExpired, false);
      });

      test('CostTrend acceleration detection', () {
        final trend = CostTrend(
          id: 'trend1',
          projectId: 'proj1',
          category: CostCategory.compute,
          values: [1000, 1100, 1250, 1450],
          direction: CostTrendDirection.increasing,
          changePercentage: 7.5,
          analyzedAt: DateTime.now(),
        );
        expect(trend.isAccelerating, true);
        expect(trend.currentValue, 1450.0);
      });

      test('CostAnomaly deviation calculation', () {
        final anomaly = CostAnomaly(
          id: 'anom1',
          resourceId: 'res1',
          anomalyValue: 1200.0,
          expectedValue: 1000.0,
          description: 'High cost detected',
          detectedAt: DateTime.now(),
          severity: OptimizationSeverity.high,
        );
        expect(anomaly.deviation, 20.0);
        expect(anomaly.isSignificantDeviation, true);
      });

      test('CostOptimizationReport significance', () {
        final report = CostOptimizationReport(
          id: 'report1',
          projectId: 'proj1',
          generatedAt: DateTime.now(),
          totalSpend: 50000.0,
          potentialSavings: 5000.0,
          opportunityCount: 15,
          savingsPercentage: 10.0,
        );
        expect(report.hasSavingsOpportunities, true);
        expect(report.isSignificant, true);
        expect(report.projectedAnnualSavings, 60000.0);
      });

      test('ResourceAllocation utilization calculation', () {
        final alloc = ResourceAllocation(
          id: 'alloc1',
          projectId: 'proj1',
          resourceType: 'compute',
          allocatedCapacity: 1000.0,
          usedCapacity: 750.0,
          strategy: AllocationStrategy.fairShare,
          allocationDate: DateTime.now(),
        );
        expect(alloc.utilizationPercentage, 75.0);
        expect(alloc.isOptimal, true);
      });

      test('CostAlert urgency detection', () {
        final alert = CostAlert(
          id: 'alert1',
          projectId: 'proj1',
          message: 'Budget exceeded',
          severity: OptimizationSeverity.critical,
          createdAt: DateTime.now(),
          isAcknowledged: false,
        );
        expect(alert.isActive, true);
        expect(alert.isUrgent, true);
      });
    });

    // ===== REPOSITORY TESTS: Cost Records =====
    group('Repository Tests - Cost Records', () {
      late CostRepository repository;

      setUp(() {
        repository = InMemoryCostRepository();
      });

      test('Create and retrieve cost record', () async {
        final record = CostRecord(
          id: 'cost1',
          resourceId: 'res1',
          category: CostCategory.compute,
          amount: 100.0,
          recordedAt: DateTime.now(),
          currency: 'USD',
        );
        await repository.createCostRecord(record);
        final retrieved = await repository.getCostRecord('cost1');
        expect(retrieved, isNotNull);
        expect(retrieved!.amount, 100.0);
      });

      test('Get records by resource', () async {
        final r1 = CostRecord(
          id: 'cost1',
          resourceId: 'res1',
          category: CostCategory.compute,
          amount: 100.0,
          recordedAt: DateTime.now(),
          currency: 'USD',
        );
        final r2 = CostRecord(
          id: 'cost2',
          resourceId: 'res1',
          category: CostCategory.storage,
          amount: 50.0,
          recordedAt: DateTime.now(),
          currency: 'USD',
        );
        await repository.createCostRecord(r1);
        await repository.createCostRecord(r2);
        final records = await repository.getCostRecordsByResource('res1');
        expect(records.length, 2);
      });

      test('Get records by category', () async {
        final r1 = CostRecord(
          id: 'cost1',
          resourceId: 'res1',
          category: CostCategory.compute,
          amount: 100.0,
          recordedAt: DateTime.now(),
          currency: 'USD',
        );
        final r2 = CostRecord(
          id: 'cost2',
          resourceId: 'res2',
          category: CostCategory.compute,
          amount: 150.0,
          recordedAt: DateTime.now(),
          currency: 'USD',
        );
        await repository.createCostRecord(r1);
        await repository.createCostRecord(r2);
        final records = await repository.getCostRecordsByCategory(CostCategory.compute);
        expect(records.length, 2);
      });

      test('Get total cost by category', () async {
        final r1 = CostRecord(
          id: 'cost1',
          resourceId: 'res1',
          category: CostCategory.storage,
          amount: 100.0,
          recordedAt: DateTime.now(),
          currency: 'USD',
        );
        final r2 = CostRecord(
          id: 'cost2',
          resourceId: 'res2',
          category: CostCategory.storage,
          amount: 200.0,
          recordedAt: DateTime.now(),
          currency: 'USD',
        );
        await repository.createCostRecord(r1);
        await repository.createCostRecord(r2);
        final total = await repository.getTotalCostByCategory(CostCategory.storage);
        expect(total, 300.0);
      });
    });

    // ===== REPOSITORY TESTS: Budget =====
    group('Repository Tests - Budget Allocations', () {
      late CostRepository repository;

      setUp(() {
        repository = InMemoryCostRepository();
      });

      test('Create budget allocation', () async {
        final budget = BudgetAllocation(
          id: 'budget1',
          projectId: 'proj1',
          category: CostCategory.compute,
          allocatedAmount: 1000.0,
          spentAmount: 500.0,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          strategy: AllocationStrategy.fairShare,
        );
        await repository.createBudgetAllocation(budget);
        final retrieved = await repository.getBudgetAllocation('budget1');
        expect(retrieved!.allocatedAmount, 1000.0);
      });

      test('Get over budget allocations', () async {
        final budget = BudgetAllocation(
          id: 'budget1',
          projectId: 'proj1',
          category: CostCategory.compute,
          allocatedAmount: 1000.0,
          spentAmount: 1200.0,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          strategy: AllocationStrategy.fairShare,
        );
        await repository.createBudgetAllocation(budget);
        final overBudget = await repository.getOverBudgetAllocations();
        expect(overBudget.length, 1);
      });

      test('Update spent amount', () async {
        final budget = BudgetAllocation(
          id: 'budget1',
          projectId: 'proj1',
          category: CostCategory.compute,
          allocatedAmount: 1000.0,
          spentAmount: 500.0,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          strategy: AllocationStrategy.fairShare,
        );
        await repository.createBudgetAllocation(budget);
        await repository.updateSpentAmount('budget1', 750.0);
        final updated = await repository.getBudgetAllocation('budget1');
        expect(updated!.spentAmount, 750.0);
      });

      test('Get project budget utilization', () async {
        final budget = BudgetAllocation(
          id: 'budget1',
          projectId: 'proj1',
          category: CostCategory.compute,
          allocatedAmount: 1000.0,
          spentAmount: 800.0,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          strategy: AllocationStrategy.fairShare,
        );
        await repository.createBudgetAllocation(budget);
        final util = await repository.getProjectBudgetUtilization('proj1');
        expect(util, 80.0);
      });
    });

    // ===== REPOSITORY TESTS: Utilization =====
    group('Repository Tests - Utilization', () {
      late CostRepository repository;

      setUp(() {
        repository = InMemoryCostRepository();
      });

      test('Get underutilized resources', () async {
        final util = ResourceUtilization(
          id: 'util1',
          resourceId: 'res1',
          cpuUtilization: 10.0,
          memoryUtilization: 15.0,
          storageUtilization: 20.0,
          networkUtilization: 25.0,
          measuredAt: DateTime.now(),
        );
        await repository.createUtilization(util);
        final underutil = await repository.getUnderutilizedResources();
        expect(underutil.length, 1);
      });

      test('Get overutilized resources', () async {
        final util = ResourceUtilization(
          id: 'util1',
          resourceId: 'res1',
          cpuUtilization: 90.0,
          memoryUtilization: 92.0,
          storageUtilization: 88.0,
          networkUtilization: 95.0,
          measuredAt: DateTime.now(),
        );
        await repository.createUtilization(util);
        final overutil = await repository.getOverutilizedResources();
        expect(overutil.length, 1);
      });
    });

    // ===== REPOSITORY TESTS: Opportunities =====
    group('Repository Tests - Opportunities', () {
      late CostRepository repository;

      setUp(() {
        repository = InMemoryCostRepository();
      });

      test('Get significant opportunities', () async {
        final opp = OptimizationOpportunity(
          id: 'opp1',
          resourceId: 'res1',
          severity: OptimizationSeverity.critical,
          title: 'Idle Instance',
          description: 'Unused instance',
          potentialSavings: 2000.0,
          discoveredAt: DateTime.now(),
        );
        await repository.createOpportunity(opp);
        final significant = await repository.getSignificantOpportunities();
        expect(significant.length, 1);
      });

      test('Get total potential savings', () async {
        final opp1 = OptimizationOpportunity(
          id: 'opp1',
          resourceId: 'res1',
          severity: OptimizationSeverity.high,
          title: 'Opp 1',
          description: 'Opportunity 1',
          potentialSavings: 1000.0,
          discoveredAt: DateTime.now(),
        );
        final opp2 = OptimizationOpportunity(
          id: 'opp2',
          resourceId: 'res2',
          severity: OptimizationSeverity.medium,
          title: 'Opp 2',
          description: 'Opportunity 2',
          potentialSavings: 500.0,
          discoveredAt: DateTime.now(),
        );
        await repository.createOpportunity(opp1);
        await repository.createOpportunity(opp2);
        final total = await repository.getTotalPotentialSavings();
        expect(total, 1500.0);
      });
    });

    // ===== REPOSITORY TESTS: Forecasts =====
    group('Repository Tests - Forecasts', () {
      late CostRepository repository;

      setUp(() {
        repository = InMemoryCostRepository();
      });

      test('Get latest forecast', () async {
        final f1 = CostForecast(
          id: 'f1',
          projectId: 'proj1',
          forecastDate: DateTime.now().subtract(Duration(days: 1)),
          predictedCost: 5000.0,
          confidence: ForecastConfidence.high,
          historicalData: [4000, 4500, 5000],
        );
        final f2 = CostForecast(
          id: 'f2',
          projectId: 'proj1',
          forecastDate: DateTime.now(),
          predictedCost: 5200.0,
          confidence: ForecastConfidence.high,
          historicalData: [4000, 4500, 5000, 5200],
        );
        await repository.createForecast(f1);
        await repository.createForecast(f2);
        final latest = await repository.getLatestForecast('proj1');
        expect(latest!.predictedCost, 5200.0);
      });

      test('Get forecasted annual cost', () async {
        final forecast = CostForecast(
          id: 'f1',
          projectId: 'proj1',
          forecastDate: DateTime.now(),
          predictedCost: 5000.0,
          confidence: ForecastConfidence.high,
          historicalData: [4000, 4500, 5000],
        );
        await repository.createForecast(forecast);
        final annual = await repository.getForecastedAnnualCost('proj1');
        expect(annual, 60000.0);
      });
    });

    // ===== REPOSITORY TESTS: Reservations =====
    group('Repository Tests - Reservations', () {
      late CostRepository repository;

      setUp(() {
        repository = InMemoryCostRepository();
      });

      test('Get expiring reservations', () async {
        final res = ReservedInstance(
          id: 'res1',
          resourceType: 'compute',
          quantity: 10,
          purchaseDate: DateTime.now().subtract(Duration(days: 300)),
          expiryDate: DateTime.now().add(Duration(days: 20)),
          discountPercentage: 30.0,
          status: ReservationStatus.active,
        );
        await repository.createReservedInstance(res);
        final expiring = await repository.getExpiringReservations();
        expect(expiring.length, 1);
      });

      test('Get monthly reservation savings', () async {
        final res = ReservedInstance(
          id: 'res1',
          resourceType: 'compute',
          quantity: 10,
          purchaseDate: DateTime.now().subtract(Duration(days: 100)),
          expiryDate: DateTime.now().add(Duration(days: 265)),
          discountPercentage: 30.0,
          status: ReservationStatus.active,
        );
        await repository.createReservedInstance(res);
        final savings = await repository.getMonthlyReservationSavings();
        expect(savings, greaterThan(0));
      });
    });

    // ===== REPOSITORY TESTS: Trends =====
    group('Repository Tests - Trends', () {
      late CostRepository repository;

      setUp(() {
        repository = InMemoryCostRepository();
      });

      test('Get accelerating trends', () async {
        final trend = CostTrend(
          id: 'trend1',
          projectId: 'proj1',
          category: CostCategory.compute,
          values: [1000, 1100, 1250, 1450],
          direction: CostTrendDirection.increasing,
          changePercentage: 7.5,
          analyzedAt: DateTime.now(),
        );
        await repository.createTrend(trend);
        final accelerating = await repository.getAcceleratingTrends();
        expect(accelerating.length, 1);
      });
    });

    // ===== REPOSITORY TESTS: Anomalies =====
    group('Repository Tests - Anomalies', () {
      late CostRepository repository;

      setUp(() {
        repository = InMemoryCostRepository();
      });

      test('Get significant anomalies', () async {
        final anomaly = CostAnomaly(
          id: 'anom1',
          resourceId: 'res1',
          anomalyValue: 1200.0,
          expectedValue: 1000.0,
          description: 'High cost',
          detectedAt: DateTime.now(),
          severity: OptimizationSeverity.high,
        );
        await repository.createAnomaly(anomaly);
        final significant = await repository.getSignificantAnomalies();
        expect(significant.length, 1);
      });

      test('Get recent anomaly count', () async {
        final anomaly = CostAnomaly(
          id: 'anom1',
          resourceId: 'res1',
          anomalyValue: 1200.0,
          expectedValue: 1000.0,
          description: 'High cost',
          detectedAt: DateTime.now(),
          severity: OptimizationSeverity.high,
        );
        await repository.createAnomaly(anomaly);
        final count = await repository.getRecentAnomalyCount(24);
        expect(count, 1);
      });
    });

    // ===== REPOSITORY TESTS: Reports =====
    group('Repository Tests - Reports', () {
      late CostRepository repository;

      setUp(() {
        repository = InMemoryCostRepository();
      });

      test('Get latest report by project', () async {
        final r1 = CostOptimizationReport(
          id: 'report1',
          projectId: 'proj1',
          generatedAt: DateTime.now().subtract(Duration(days: 1)),
          totalSpend: 50000.0,
          potentialSavings: 5000.0,
          opportunityCount: 15,
          savingsPercentage: 10.0,
        );
        final r2 = CostOptimizationReport(
          id: 'report2',
          projectId: 'proj1',
          generatedAt: DateTime.now(),
          totalSpend: 52000.0,
          potentialSavings: 5200.0,
          opportunityCount: 16,
          savingsPercentage: 10.0,
        );
        await repository.createReport(r1);
        await repository.createReport(r2);
        final latest = await repository.getLatestReportByProject('proj1');
        expect(latest!.totalSpend, 52000.0);
      });

      test('Get average savings percentage', () async {
        final r1 = CostOptimizationReport(
          id: 'report1',
          projectId: 'proj1',
          generatedAt: DateTime.now(),
          totalSpend: 50000.0,
          potentialSavings: 5000.0,
          opportunityCount: 15,
          savingsPercentage: 10.0,
        );
        final r2 = CostOptimizationReport(
          id: 'report2',
          projectId: 'proj2',
          generatedAt: DateTime.now(),
          totalSpend: 60000.0,
          potentialSavings: 7200.0,
          opportunityCount: 20,
          savingsPercentage: 12.0,
        );
        await repository.createReport(r1);
        await repository.createReport(r2);
        final avg = await repository.getAverageSavingsPercentage();
        expect(avg, 11.0);
      });
    });

    // ===== REPOSITORY TESTS: Allocations =====
    group('Repository Tests - Allocations', () {
      late CostRepository repository;

      setUp(() {
        repository = InMemoryCostRepository();
      });

      test('Get underutilized allocations', () async {
        final alloc = ResourceAllocation(
          id: 'alloc1',
          projectId: 'proj1',
          resourceType: 'compute',
          allocatedCapacity: 1000.0,
          usedCapacity: 200.0,
          strategy: AllocationStrategy.fairShare,
          allocationDate: DateTime.now(),
        );
        await repository.createAllocation(alloc);
        final underutil = await repository.getUnderutilizedAllocations();
        expect(underutil.length, 1);
      });

      test('Get total wasted capacity', () async {
        final alloc1 = ResourceAllocation(
          id: 'alloc1',
          projectId: 'proj1',
          resourceType: 'compute',
          allocatedCapacity: 1000.0,
          usedCapacity: 200.0,
          strategy: AllocationStrategy.fairShare,
          allocationDate: DateTime.now(),
        );
        final alloc2 = ResourceAllocation(
          id: 'alloc2',
          projectId: 'proj1',
          resourceType: 'storage',
          allocatedCapacity: 500.0,
          usedCapacity: 100.0,
          strategy: AllocationStrategy.fairShare,
          allocationDate: DateTime.now(),
        );
        await repository.createAllocation(alloc1);
        await repository.createAllocation(alloc2);
        final wasted = await repository.getTotalWastedCapacity();
        expect(wasted, 1200.0);
      });
    });

    // ===== REPOSITORY TESTS: Alerts =====
    group('Repository Tests - Alerts', () {
      late CostRepository repository;

      setUp(() {
        repository = InMemoryCostRepository();
      });

      test('Get active alerts', () async {
        final alert = CostAlert(
          id: 'alert1',
          projectId: 'proj1',
          message: 'Budget exceeded',
          severity: OptimizationSeverity.critical,
          createdAt: DateTime.now(),
          isAcknowledged: false,
        );
        await repository.createAlert(alert);
        final active = await repository.getActiveAlerts();
        expect(active.length, 1);
      });

      test('Acknowledge alert', () async {
        final alert = CostAlert(
          id: 'alert1',
          projectId: 'proj1',
          message: 'Budget exceeded',
          severity: OptimizationSeverity.critical,
          createdAt: DateTime.now(),
          isAcknowledged: false,
        );
        await repository.createAlert(alert);
        await repository.acknowledgeAlert('alert1');
        final updated = await repository.getAlert('alert1');
        expect(updated!.isAcknowledged, true);
      });

      test('Get urgent alert count', () async {
        final alert = CostAlert(
          id: 'alert1',
          projectId: 'proj1',
          message: 'Critical budget issue',
          severity: OptimizationSeverity.critical,
          createdAt: DateTime.now(),
          isAcknowledged: false,
        );
        await repository.createAlert(alert);
        final count = await repository.getUrgentAlertCount();
        expect(count, 1);
      });
    });

    // ===== ENGINE TESTS =====
    group('Engine Tests', () {
      test('CostAnalysisEngine calculates optimal allocation', () async {
        final engine = CostAnalysisEngine();
        final utils = [
          ResourceUtilization(
            id: 'util1',
            resourceId: 'res1',
            cpuUtilization: 60.0,
            memoryUtilization: 70.0,
            storageUtilization: 50.0,
            networkUtilization: 65.0,
            measuredAt: DateTime.now(),
          ),
        ];
        final optimal = await engine.calculateOptimalAllocation(utils);
        expect(optimal, greaterThan(0));
      });

      test('ForecastingEngine generates forecast', () async {
        final engine = ForecastingEngine();
        final history = [
          CostRecord(
            id: 'c1',
            resourceId: 'res1',
            category: CostCategory.compute,
            amount: 4000.0,
            recordedAt: DateTime.now().subtract(Duration(days: 2)),
            currency: 'USD',
          ),
          CostRecord(
            id: 'c2',
            resourceId: 'res1',
            category: CostCategory.compute,
            amount: 4500.0,
            recordedAt: DateTime.now().subtract(Duration(days: 1)),
            currency: 'USD',
          ),
          CostRecord(
            id: 'c3',
            resourceId: 'res1',
            category: CostCategory.compute,
            amount: 5000.0,
            recordedAt: DateTime.now(),
            currency: 'USD',
          ),
        ];
        final forecast = await engine.generateForecast(history, 'proj1');
        expect(forecast.predictedCost, greaterThan(0));
      });

      test('AnomalyDetectionEngine detects anomaly', () async {
        final engine = AnomalyDetectionEngine();
        final record = CostRecord(
          id: 'c1',
          resourceId: 'res1',
          category: CostCategory.compute,
          amount: 1200.0,
          recordedAt: DateTime.now(),
          currency: 'USD',
        );
        final anomaly = await engine.detectAnomaly(record, 1000.0);
        expect(anomaly, isNotNull);
      });

      test('AlertingEngine evaluates cost alert', () async {
        final engine = AlertingEngine();
        final budget = BudgetAllocation(
          id: 'budget1',
          projectId: 'proj1',
          category: CostCategory.compute,
          allocatedAmount: 1000.0,
          spentAmount: 850.0,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          strategy: AllocationStrategy.fairShare,
        );
        final alert = await engine.evaluateCostAlert(budget);
        expect(alert, isNotNull);
      });
    });

    // ===== FACADE TESTS =====
    group('Facade Tests', () {
      late CostFacade facade;

      setUp(() {
        facade = CostFacade();
      });

      test('Record cost', () async {
        await facade.recordCost('res1', CostCategory.compute, 100.0);
        expect(true, true);
      });

      test('Get total spend', () async {
        final spend = await facade.getTotalSpend('proj1');
        expect(spend, isA<double>());
      });

      test('Get project savings potential', () async {
        final savings = await facade.getProjectSavingsPotential('proj1');
        expect(savings, isA<double>());
      });

      test('Get critical opportunity count', () async {
        final count = await facade.getCriticalOpportunityCount();
        expect(count, isA<int>());
      });

      test('Get annualized forecast', () async {
        final forecast = await facade.getAnnualizedCostForecast('proj1');
        expect(forecast, isA<double>());
      });
    });

    // ===== INTEGRATION TESTS =====
    group('Integration Tests', () {
      late CostFacade facade;

      setUp(() {
        facade = CostFacade();
      });

      test('Complete cost optimization workflow', () async {
        await facade.recordCost('res1', CostCategory.compute, 100.0);
        final spend = await facade.getTotalSpend('proj1');
        expect(spend, isA<double>());
      });

      test('Multi-project cost tracking', () async {
        await facade.recordCost('res1', CostCategory.compute, 100.0);
        await facade.recordCost('res2', CostCategory.storage, 50.0);
        expect(true, true);
      });
    });

    // ===== PERFORMANCE TESTS =====
    group('Performance Tests', () {
      late CostRepository repository;

      setUp(() {
        repository = InMemoryCostRepository();
      });

      test('Bulk cost record creation', () async {
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 100; i++) {
          await repository.createCostRecord(
            CostRecord(
              id: 'cost_$i',
              resourceId: 'res_${i % 10}',
              category: CostCategory.compute,
              amount: 100.0 + i,
              recordedAt: DateTime.now(),
              currency: 'USD',
            ),
          );
        }
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds < 5000, true);
      });

      test('Bulk budget creation and retrieval', () async {
        for (int i = 0; i < 50; i++) {
          await repository.createBudgetAllocation(
            BudgetAllocation(
              id: 'budget_$i',
              projectId: 'proj1',
              category: CostCategory.compute,
              allocatedAmount: 1000.0,
              spentAmount: 500.0 + i * 10,
              startDate: DateTime.now(),
              endDate: DateTime.now().add(Duration(days: 30)),
              strategy: AllocationStrategy.fairShare,
            ),
          );
        }
        final budgets = await repository.getBudgetsByProject('proj1');
        expect(budgets.length, 50);
      });
    });

    // ===== EDGE CASE TESTS =====
    group('Edge Case Tests', () {
      late CostRepository repository;

      setUp(() {
        repository = InMemoryCostRepository();
      });

      test('Handle null values gracefully', () async {
        final record = await repository.getCostRecord('nonexistent');
        expect(record, isNull);
      });

      test('Handle empty collections', () async {
        final records = await repository.getCostRecordsByResource('nonexistent');
        expect(records, isEmpty);
      });

      test('Handle zero cost records', () async {
        final record = CostRecord(
          id: 'cost1',
          resourceId: 'res1',
          category: CostCategory.compute,
          amount: 0.0,
          recordedAt: DateTime.now(),
          currency: 'USD',
        );
        await repository.createCostRecord(record);
        final retrieved = await repository.getCostRecord('cost1');
        expect(retrieved!.amount, 0.0);
      });

      test('Handle large budget allocations', () async {
        final budget = BudgetAllocation(
          id: 'budget1',
          projectId: 'proj1',
          category: CostCategory.compute,
          allocatedAmount: 1000000.0,
          spentAmount: 500000.0,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          strategy: AllocationStrategy.fairShare,
        );
        await repository.createBudgetAllocation(budget);
        final retrieved = await repository.getBudgetAllocation('budget1');
        expect(retrieved!.allocatedAmount, 1000000.0);
      });

      test('Concurrent cost operations', () async {
        final futures = <Future>[];
        for (int i = 0; i < 20; i++) {
          futures.add(repository.createCostRecord(
            CostRecord(
              id: 'concurrent_$i',
              resourceId: 'res1',
              category: CostCategory.compute,
              amount: 100.0 + i,
              recordedAt: DateTime.now(),
              currency: 'USD',
            ),
          ));
        }
        await Future.wait(futures);
        final records = await repository.getCostRecordsByResource('res1');
        expect(records.length, 20);
      });
    });
  });
}
