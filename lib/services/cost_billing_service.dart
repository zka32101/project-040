import '../models/cost_models.dart';

abstract class CostBillingRepository {
  Future<void> recordCostAllocation(CostAllocation allocation);
  Future<CostAllocation?> getCostAllocation(String allocationId);
  Future<List<CostAllocation>> getResourceCosts(String resourceId);
  Future<List<CostAllocation>> getCostsByType(CostType costType);
  Future<List<CostAllocation>> getUnbilledCosts();

  Future<void> createBillingPeriod(BillingPeriod period);
  Future<BillingPeriod?> getBillingPeriod(String periodId);
  Future<List<BillingPeriod>> getAccountBillingPeriods(String accountId);
  Future<List<BillingPeriod>> getOpenBillingPeriods();

  Future<void> createInvoice(Invoice invoice);
  Future<Invoice?> getInvoice(String invoiceId);
  Future<List<Invoice>> getAccountInvoices(String accountId);
  Future<List<Invoice>> getOverdueInvoices();
  Future<List<Invoice>> getUnpaidInvoices();

  Future<void> saveRateCard(RateCard rateCard);
  Future<RateCard?> getRateCard(String rateCardId);
  Future<List<RateCard>> getRateCardsByType(CostType costType);
  Future<List<RateCard>> getActiveRateCards();

  Future<void> recordCostMetric(CostMetric metric);
  Future<CostMetric?> getCostMetric(String metricId);
  Future<List<CostMetric>> getResourceMetrics(String resourceId);
  Future<List<CostMetric>> getMetricsByType(CostType costType);

  Future<void> createBillingAccount(BillingAccount account);
  Future<BillingAccount?> getBillingAccount(String accountId);
  Future<List<BillingAccount>> getOrganizationAccounts(String organizationId);
  Future<List<BillingAccount>> getActiveBillingAccounts();

  Future<void> createBudgetAllocation(BudgetAllocation budget);
  Future<BudgetAllocation?> getBudgetAllocation(String budgetId);
  Future<List<BudgetAllocation>> getProjectBudgets(String projectId);
  Future<List<BudgetAllocation>> getExceededBudgets();

  Future<void> saveCostForecast(CostForecast forecast);
  Future<CostForecast?> getCostForecast(String forecastId);
  Future<List<CostForecast>> getResourceForecasts(String resourceId);

  Future<void> recordPayment(Payment payment);
  Future<Payment?> getPayment(String paymentId);
  Future<List<Payment>> getInvoicePayments(String invoiceId);
  Future<List<Payment>> getFailedPayments();

  Future<void> recordOptimization(CostOptimization optimization);
  Future<CostOptimization?> getOptimization(String optimizationId);
  Future<List<CostOptimization>> getResourceOptimizations(String resourceId);
  Future<List<CostOptimization>> getPendingOptimizations();
}

class MemoryCostBillingRepository implements CostBillingRepository {
  final Map<String, CostAllocation> _allocations = {};
  final Map<String, BillingPeriod> _periods = {};
  final Map<String, Invoice> _invoices = {};
  final Map<String, RateCard> _rateCards = {};
  final Map<String, CostMetric> _metrics = {};
  final Map<String, BillingAccount> _accounts = {};
  final Map<String, BudgetAllocation> _budgets = {};
  final Map<String, CostForecast> _forecasts = {};
  final Map<String, Payment> _payments = {};
  final Map<String, CostOptimization> _optimizations = {};

  @override
  Future<void> recordCostAllocation(CostAllocation allocation) async => _allocations[allocation.allocationId] = allocation;

  @override
  Future<CostAllocation?> getCostAllocation(String allocationId) async => _allocations[allocationId];

  @override
  Future<List<CostAllocation>> getResourceCosts(String resourceId) async =>
      _allocations.values.where((a) => a.resourceId == resourceId).toList();

  @override
  Future<List<CostAllocation>> getCostsByType(CostType costType) async =>
      _allocations.values.where((a) => a.costType == costType).toList();

  @override
  Future<List<CostAllocation>> getUnbilledCosts() async =>
      _allocations.values.where((a) => !a.isBilled).toList();

  @override
  Future<void> createBillingPeriod(BillingPeriod period) async => _periods[period.periodId] = period;

  @override
  Future<BillingPeriod?> getBillingPeriod(String periodId) async => _periods[periodId];

  @override
  Future<List<BillingPeriod>> getAccountBillingPeriods(String accountId) async =>
      _periods.values.where((p) => p.billingAccountId == accountId).toList();

  @override
  Future<List<BillingPeriod>> getOpenBillingPeriods() async =>
      _periods.values.where((p) => !p.isClosed).toList();

  @override
  Future<void> createInvoice(Invoice invoice) async => _invoices[invoice.invoiceId] = invoice;

  @override
  Future<Invoice?> getInvoice(String invoiceId) async => _invoices[invoiceId];

  @override
  Future<List<Invoice>> getAccountInvoices(String accountId) async =>
      _invoices.values.where((i) => i.billingAccountId == accountId).toList();

  @override
  Future<List<Invoice>> getOverdueInvoices() async =>
      _invoices.values.where((i) => i.isOverdue).toList();

  @override
  Future<List<Invoice>> getUnpaidInvoices() async =>
      _invoices.values.where((i) => !i.isPaid).toList();

  @override
  Future<void> saveRateCard(RateCard rateCard) async => _rateCards[rateCard.rateCardId] = rateCard;

  @override
  Future<RateCard?> getRateCard(String rateCardId) async => _rateCards[rateCardId];

  @override
  Future<List<RateCard>> getRateCardsByType(CostType costType) async =>
      _rateCards.values.where((r) => r.costType == costType).toList();

  @override
  Future<List<RateCard>> getActiveRateCards() async =>
      _rateCards.values.where((r) => r.isActive).toList();

  @override
  Future<void> recordCostMetric(CostMetric metric) async => _metrics[metric.metricId] = metric;

  @override
  Future<CostMetric?> getCostMetric(String metricId) async => _metrics[metricId];

  @override
  Future<List<CostMetric>> getResourceMetrics(String resourceId) async =>
      _metrics.values.where((m) => m.resourceId == resourceId).toList();

  @override
  Future<List<CostMetric>> getMetricsByType(CostType costType) async =>
      _metrics.values.where((m) => m.costType == costType).toList();

  @override
  Future<void> createBillingAccount(BillingAccount account) async => _accounts[account.accountId] = account;

  @override
  Future<BillingAccount?> getBillingAccount(String accountId) async => _accounts[accountId];

  @override
  Future<List<BillingAccount>> getOrganizationAccounts(String organizationId) async =>
      _accounts.values.where((a) => a.organizationId == organizationId).toList();

  @override
  Future<List<BillingAccount>> getActiveBillingAccounts() async =>
      _accounts.values.where((a) => a.isActive).toList();

  @override
  Future<void> createBudgetAllocation(BudgetAllocation budget) async => _budgets[budget.budgetId] = budget;

  @override
  Future<BudgetAllocation?> getBudgetAllocation(String budgetId) async => _budgets[budgetId];

  @override
  Future<List<BudgetAllocation>> getProjectBudgets(String projectId) async =>
      _budgets.values.where((b) => b.projectId == projectId).toList();

  @override
  Future<List<BudgetAllocation>> getExceededBudgets() async =>
      _budgets.values.where((b) => b.isExceeded).toList();

  @override
  Future<void> saveCostForecast(CostForecast forecast) async => _forecasts[forecast.forecastId] = forecast;

  @override
  Future<CostForecast?> getCostForecast(String forecastId) async => _forecasts[forecastId];

  @override
  Future<List<CostForecast>> getResourceForecasts(String resourceId) async =>
      _forecasts.values.where((f) => f.resourceId == resourceId).toList();

  @override
  Future<void> recordPayment(Payment payment) async => _payments[payment.paymentId] = payment;

  @override
  Future<Payment?> getPayment(String paymentId) async => _payments[paymentId];

  @override
  Future<List<Payment>> getInvoicePayments(String invoiceId) async =>
      _payments.values.where((p) => p.invoiceId == invoiceId).toList();

  @override
  Future<List<Payment>> getFailedPayments() async =>
      _payments.values.where((p) => p.isFailed).toList();

  @override
  Future<void> recordOptimization(CostOptimization optimization) async =>
      _optimizations[optimization.optimizationId] = optimization;

  @override
  Future<CostOptimization?> getOptimization(String optimizationId) async => _optimizations[optimizationId];

  @override
  Future<List<CostOptimization>> getResourceOptimizations(String resourceId) async =>
      _optimizations.values.where((o) => o.resourceId == resourceId).toList();

  @override
  Future<List<CostOptimization>> getPendingOptimizations() async =>
      _optimizations.values.where((o) => o.isPending).toList();
}

class CostCalculationEngine {
  final CostBillingRepository repository;

  CostCalculationEngine({required this.repository});

  Future<double> calculateResourceCost(String resourceId, DateTime startDate, DateTime endDate) async {
    final allocations = await repository.getResourceCosts(resourceId);
    return allocations
        .where((a) => a.allocatedAt.isAfter(startDate) && a.allocatedAt.isBefore(endDate))
        .fold(0.0, (sum, a) => sum + a.amount);
  }

  Future<CostAllocation> recordCostAllocation(String resourceId, String projectId, CostType costType, double amount) async {
    final allocation = CostAllocation(
      allocationId: 'alloc_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      projectId: projectId,
      costType: costType,
      amount: amount,
      currency: CurrencyCode.usd,
      allocatedAt: DateTime.now(),
    );
    await repository.recordCostAllocation(allocation);
    return allocation;
  }
}

class BillingEngine {
  final CostBillingRepository repository;

  BillingEngine({required this.repository});

  Future<Invoice> createInvoice(String accountId, String periodId, double totalAmount, Map<String, double> lineItems) async {
    final invoice = Invoice(
      invoiceId: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      billingAccountId: accountId,
      billingPeriodId: periodId,
      invoiceDate: DateTime.now(),
      dueDate: DateTime.now().add(Duration(days: 30)),
      totalAmount: totalAmount,
      currency: CurrencyCode.usd,
      status: InvoiceStatus.draft,
      invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      lineItems: lineItems,
    );
    await repository.createInvoice(invoice);
    return invoice;
  }

  Future<void> sendInvoice(String invoiceId) async {
    final invoice = await repository.getInvoice(invoiceId);
    if (invoice != null && invoice.status == InvoiceStatus.draft) {
      final sent = Invoice(
        invoiceId: invoice.invoiceId,
        billingAccountId: invoice.billingAccountId,
        billingPeriodId: invoice.billingPeriodId,
        invoiceDate: invoice.invoiceDate,
        dueDate: invoice.dueDate,
        totalAmount: invoice.totalAmount,
        paidAmount: invoice.paidAmount,
        currency: invoice.currency,
        status: InvoiceStatus.sent,
        invoiceNumber: invoice.invoiceNumber,
        lineItems: invoice.lineItems,
      );
      await repository.createInvoice(sent);
    }
  }

  Future<void> markInvoiceAsPaid(String invoiceId, double paidAmount) async {
    final invoice = await repository.getInvoice(invoiceId);
    if (invoice != null) {
      final paid = Invoice(
        invoiceId: invoice.invoiceId,
        billingAccountId: invoice.billingAccountId,
        billingPeriodId: invoice.billingPeriodId,
        invoiceDate: invoice.invoiceDate,
        dueDate: invoice.dueDate,
        totalAmount: invoice.totalAmount,
        paidAmount: paidAmount,
        currency: invoice.currency,
        status: paidAmount >= invoice.totalAmount ? InvoiceStatus.paid : InvoiceStatus.sent,
        invoiceNumber: invoice.invoiceNumber,
        lineItems: invoice.lineItems,
      );
      await repository.createInvoice(paid);
    }
  }
}

class BudgetManagementEngine {
  final CostBillingRepository repository;

  BudgetManagementEngine({required this.repository});

  Future<BudgetAllocation> createBudget(String projectId, String budgetName, double limit, DateTime startDate, DateTime endDate) async {
    final budget = BudgetAllocation(
      budgetId: 'budget_${DateTime.now().millisecondsSinceEpoch}',
      projectId: projectId,
      budgetName: budgetName,
      budgetLimit: limit,
      currency: CurrencyCode.usd,
      startDate: startDate,
      endDate: endDate,
      currentSpending: 0,
      costTypeRestrictions: [],
    );
    await repository.createBudgetAllocation(budget);
    return budget;
  }

  Future<List<BudgetAllocation>> getExceededBudgets() async {
    return await repository.getExceededBudgets();
  }
}

class ForecastingEngine {
  final CostBillingRepository repository;

  ForecastingEngine({required this.repository});

  Future<CostForecast> generateForecast(String resourceId, CostType costType, double projectedCost) async {
    final forecast = CostForecast(
      forecastId: 'forecast_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      costType: costType,
      forecastDate: DateTime.now().add(Duration(days: 30)),
      projectedCost: projectedCost,
      lowerBound: projectedCost * 0.9,
      upperBound: projectedCost * 1.1,
      confidence: 0.85,
      dataPointsUsed: 30,
      forecastMethod: 'linear_regression',
    );
    await repository.saveCostForecast(forecast);
    return forecast;
  }
}

class CostOptimizationEngine {
  final CostBillingRepository repository;

  CostOptimizationEngine({required this.repository});

  Future<CostOptimization> suggestOptimization(String resourceId, String title, String description, double potentialSavings) async {
    final optimization = CostOptimization(
      optimizationId: 'opt_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      title: title,
      description: description,
      potentialSavings: potentialSavings,
      currency: CurrencyCode.usd,
      discoveredAt: DateTime.now(),
      recommendation: 'Review resource configuration',
    );
    await repository.recordOptimization(optimization);
    return optimization;
  }

  Future<void> markOptimizationImplemented(String optimizationId, double actualSavings) async {
    final optimization = await repository.getOptimization(optimizationId);
    if (optimization != null) {
      final implemented = CostOptimization(
        optimizationId: optimization.optimizationId,
        resourceId: optimization.resourceId,
        title: optimization.title,
        description: optimization.description,
        potentialSavings: optimization.potentialSavings,
        currency: optimization.currency,
        discoveredAt: optimization.discoveredAt,
        implementedAt: DateTime.now(),
        actualSavings: actualSavings,
        recommendation: optimization.recommendation,
      );
      await repository.recordOptimization(implemented);
    }
  }
}

class CostBillingManager {
  final CostBillingRepository repository;
  final CostCalculationEngine costEngine;
  final BillingEngine billingEngine;
  final BudgetManagementEngine budgetEngine;
  final ForecastingEngine forecastEngine;
  final CostOptimizationEngine optimizationEngine;

  CostBillingManager({
    required this.repository,
    required this.costEngine,
    required this.billingEngine,
    required this.budgetEngine,
    required this.forecastEngine,
    required this.optimizationEngine,
  });

  Future<double> calculateProjectCost(String projectId, DateTime startDate, DateTime endDate) async {
    final allocations = await repository.getResourceCosts(projectId);
    return allocations
        .where((a) => a.allocatedAt.isAfter(startDate) && a.allocatedAt.isBefore(endDate))
        .fold(0.0, (sum, a) => sum + a.amount);
  }

  Future<Invoice> createInvoice(String accountId, String periodId, double totalAmount, Map<String, double> lineItems) async {
    return await billingEngine.createInvoice(accountId, periodId, totalAmount, lineItems);
  }
}

class CostBillingFacade {
  final CostBillingManager manager;

  CostBillingFacade({required CostBillingManager? manager})
      : manager = manager ??
            CostBillingManager(
              repository: MemoryCostBillingRepository(),
              costEngine: CostCalculationEngine(repository: MemoryCostBillingRepository()),
              billingEngine: BillingEngine(repository: MemoryCostBillingRepository()),
              budgetEngine: BudgetManagementEngine(repository: MemoryCostBillingRepository()),
              forecastEngine: ForecastingEngine(repository: MemoryCostBillingRepository()),
              optimizationEngine: CostOptimizationEngine(repository: MemoryCostBillingRepository()),
            );

  Future<CostAllocation> recordCost(String resourceId, String projectId, CostType costType, double amount) async {
    return await manager.costEngine.recordCostAllocation(resourceId, projectId, costType, amount);
  }

  Future<double> getResourceCost(String resourceId, DateTime startDate, DateTime endDate) async {
    return await manager.costEngine.calculateResourceCost(resourceId, startDate, endDate);
  }

  Future<Invoice> createInvoice(String accountId, String periodId, double amount, Map<String, double> items) async {
    return await manager.billingEngine.createInvoice(accountId, periodId, amount, items);
  }

  Future<void> sendInvoice(String invoiceId) async {
    await manager.billingEngine.sendInvoice(invoiceId);
  }

  Future<void> markInvoicePaid(String invoiceId, double paidAmount) async {
    await manager.billingEngine.markInvoiceAsPaid(invoiceId, paidAmount);
  }

  Future<BudgetAllocation> createBudget(String projectId, String name, double limit, DateTime start, DateTime end) async {
    return await manager.budgetEngine.createBudget(projectId, name, limit, start, end);
  }

  Future<List<BudgetAllocation>> getExceededBudgets() async {
    return await manager.budgetEngine.getExceededBudgets();
  }

  Future<CostForecast> generateForecast(String resourceId, CostType type, double projectedCost) async {
    return await manager.forecastEngine.generateForecast(resourceId, type, projectedCost);
  }

  Future<CostOptimization> suggestOptimization(String resourceId, String title, String description, double savings) async {
    return await manager.optimizationEngine.suggestOptimization(resourceId, title, description, savings);
  }
}
