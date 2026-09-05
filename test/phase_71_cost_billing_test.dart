import 'package:flutter_test/flutter_test.dart';
import '../lib/models/cost_models.dart';
import '../lib/services/cost_billing_service.dart';

void main() {
  group('Phase 71: Cost & Billing Management', () {
    late CostBillingRepository repository;
    late CostBillingFacade facade;

    setUp(() {
      repository = MemoryCostBillingRepository();
      final costEngine = CostCalculationEngine(repository: repository);
      final billingEngine = BillingEngine(repository: repository);
      final budgetEngine = BudgetManagementEngine(repository: repository);
      final forecastEngine = ForecastingEngine(repository: repository);
      final optimizationEngine = CostOptimizationEngine(repository: repository);
      final manager = CostBillingManager(
        repository: repository,
        costEngine: costEngine,
        billingEngine: billingEngine,
        budgetEngine: budgetEngine,
        forecastEngine: forecastEngine,
        optimizationEngine: optimizationEngine,
      );
      facade = CostBillingFacade(manager: manager);
    });

    // Enum Tests
    group('Enums', () {
      test('CostType contains all values', () {
        expect(CostType.values.length, equals(8));
        expect(CostType.values, contains(CostType.compute));
      });

      test('BillingCycle contains all values', () {
        expect(BillingCycle.values.length, equals(6));
      });

      test('InvoiceStatus contains all values', () {
        expect(InvoiceStatus.values.length, equals(5));
      });

      test('ChargeType contains all values', () {
        expect(ChargeType.values.length, equals(4));
      });

      test('CurrencyCode contains all values', () {
        expect(CurrencyCode.values.length, equals(7));
      });

      test('PaymentStatus contains all values', () {
        expect(PaymentStatus.values.length, equals(5));
      });
    });

    // CostAllocation Tests
    group('CostAllocation', () {
      test('create cost allocation', () {
        final allocation = CostAllocation(
          allocationId: 'alloc_1',
          resourceId: 'resource_1',
          projectId: 'project_1',
          costType: CostType.compute,
          amount: 100.0,
          currency: CurrencyCode.usd,
          allocatedAt: DateTime.now(),
        );

        expect(allocation.isBilled, isFalse);
        expect(allocation.amount, equals(100.0));
      });

      test('allocation with billing date', () {
        final allocation = CostAllocation(
          allocationId: 'alloc_2',
          resourceId: 'resource_1',
          projectId: 'project_1',
          costType: CostType.storage,
          amount: 50.0,
          currency: CurrencyCode.usd,
          allocatedAt: DateTime.now(),
          billedAt: DateTime.now(),
        );

        expect(allocation.isBilled, isTrue);
      });

      test('isRecent for recent allocation', () {
        final allocation = CostAllocation(
          allocationId: 'alloc_3',
          resourceId: 'resource_1',
          projectId: 'project_1',
          costType: CostType.network,
          amount: 25.0,
          currency: CurrencyCode.usd,
          allocatedAt: DateTime.now().subtract(Duration(days: 15)),
        );

        expect(allocation.isRecent, isTrue);
      });
    });

    // BillingPeriod Tests
    group('BillingPeriod', () {
      test('create billing period', () {
        final period = BillingPeriod(
          periodId: 'period_1',
          billingAccountId: 'account_1',
          startDate: DateTime.now().subtract(Duration(days: 30)),
          endDate: DateTime.now(),
          billingCycle: BillingCycle.monthly,
          costAllocationIds: ['alloc_1', 'alloc_2'],
          totalAmount: 1500.0,
          currency: CurrencyCode.usd,
          isClosed: false,
        );

        expect(period.durationInDays, equals(30));
        expect(period.allocationCount, equals(2));
      });

      test('closed billing period', () {
        final period = BillingPeriod(
          periodId: 'period_2',
          billingAccountId: 'account_1',
          startDate: DateTime.now().subtract(Duration(days: 60)),
          endDate: DateTime.now().subtract(Duration(days: 30)),
          billingCycle: BillingCycle.monthly,
          costAllocationIds: [],
          totalAmount: 0.0,
          currency: CurrencyCode.usd,
          isClosed: true,
        );

        expect(period.isClosed, isTrue);
      });

      test('overdue billing period', () {
        final end = DateTime.now().subtract(Duration(days: 60));
        final period = BillingPeriod(
          periodId: 'period_3',
          billingAccountId: 'account_1',
          startDate: end.subtract(Duration(days: 30)),
          endDate: end,
          billingCycle: BillingCycle.monthly,
          costAllocationIds: [],
          totalAmount: 0.0,
          currency: CurrencyCode.usd,
          isClosed: false,
        );

        expect(period.isOverdue, isTrue);
      });
    });

    // Invoice Tests
    group('Invoice', () {
      test('create draft invoice', () {
        final invoice = Invoice(
          invoiceId: 'inv_1',
          billingAccountId: 'account_1',
          billingPeriodId: 'period_1',
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
          totalAmount: 2000.0,
          currency: CurrencyCode.usd,
          status: InvoiceStatus.draft,
          lineItems: {'compute': 1200.0, 'storage': 800.0},
        );

        expect(invoice.status, equals(InvoiceStatus.draft));
        expect(invoice.isPaid, isFalse);
      });

      test('paid invoice', () {
        final invoice = Invoice(
          invoiceId: 'inv_2',
          billingAccountId: 'account_1',
          billingPeriodId: 'period_1',
          invoiceDate: DateTime.now().subtract(Duration(days: 10)),
          dueDate: DateTime.now().add(Duration(days: 20)),
          totalAmount: 1500.0,
          paidAmount: 1500.0,
          currency: CurrencyCode.usd,
          status: InvoiceStatus.paid,
          lineItems: {},
        );

        expect(invoice.isPaid, isTrue);
        expect(invoice.remainingAmount, equals(0.0));
      });

      test('overdue invoice', () {
        final invoice = Invoice(
          invoiceId: 'inv_3',
          billingAccountId: 'account_1',
          billingPeriodId: 'period_1',
          invoiceDate: DateTime.now().subtract(Duration(days: 60)),
          dueDate: DateTime.now().subtract(Duration(days: 30)),
          totalAmount: 1000.0,
          currency: CurrencyCode.usd,
          status: InvoiceStatus.sent,
          lineItems: {},
        );

        expect(invoice.isOverdue, isTrue);
      });

      test('invoice payment percentage', () {
        final invoice = Invoice(
          invoiceId: 'inv_4',
          billingAccountId: 'account_1',
          billingPeriodId: 'period_1',
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
          totalAmount: 1000.0,
          paidAmount: 500.0,
          currency: CurrencyCode.usd,
          status: InvoiceStatus.sent,
          lineItems: {},
        );

        expect(invoice.paidPercentage, equals(50.0));
      });
    });

    // RateCard Tests
    group('RateCard', () {
      test('create active rate card', () {
        final rateCard = RateCard(
          rateCardId: 'rate_1',
          costType: CostType.compute,
          chargeType: ChargeType.usage_based,
          baseRate: 0.10,
          unit: 'CPU-hour',
          currency: CurrencyCode.usd,
          effectiveDate: DateTime.now().subtract(Duration(days: 30)),
        );

        expect(rateCard.isActive, isTrue);
        expect(rateCard.baseRate, equals(0.10));
      });

      test('rate card with expiry', () {
        final rateCard = RateCard(
          rateCardId: 'rate_2',
          costType: CostType.storage,
          chargeType: ChargeType.fixed,
          baseRate: 50.0,
          unit: 'month',
          currency: CurrencyCode.usd,
          effectiveDate: DateTime.now().subtract(Duration(days: 90)),
          expiryDate: DateTime.now().add(Duration(days: 30)),
        );

        expect(rateCard.isActive, isTrue);
      });

      test('rate card with tiering', () {
        final rateCard = RateCard(
          rateCardId: 'rate_3',
          costType: CostType.database,
          chargeType: ChargeType.tiered,
          baseRate: 0.05,
          unit: 'GB-month',
          currency: CurrencyCode.usd,
          effectiveDate: DateTime.now(),
          tierPricing: {'1-100': 0.05, '101-1000': 0.04, '1001+': 0.03},
        );

        expect(rateCard.hasTiering, isTrue);
      });
    });

    // CostMetric Tests
    group('CostMetric', () {
      test('create cost metric', () {
        final metric = CostMetric(
          metricId: 'metric_1',
          resourceId: 'resource_1',
          costType: CostType.compute,
          usageQuantity: 100.0,
          usageUnit: 'CPU-hour',
          unitRate: 0.10,
          calculatedCost: 10.0,
          currency: CurrencyCode.usd,
          recordedAt: DateTime.now(),
        );

        expect(metric.isBillable, isFalse);
        expect(metric.costPerUnit, equals(0.10));
      });

      test('billable cost metric', () {
        final metric = CostMetric(
          metricId: 'metric_2',
          resourceId: 'resource_1',
          costType: CostType.storage,
          usageQuantity: 500.0,
          usageUnit: 'GB-month',
          unitRate: 0.05,
          calculatedCost: 25.0,
          currency: CurrencyCode.usd,
          recordedAt: DateTime.now(),
          billableReference: 'inv_1',
        );

        expect(metric.isBillable, isTrue);
      });
    });

    // BillingAccount Tests
    group('BillingAccount', () {
      test('create billing account', () {
        final account = BillingAccount(
          accountId: 'account_1',
          organizationId: 'org_1',
          accountName: 'Main Billing Account',
          primaryContact: 'billing@company.com',
          billingCycle: BillingCycle.monthly,
          createdAt: DateTime.now(),
          isActive: true,
        );

        expect(account.isActive, isTrue);
        expect(account.isSuspended, isFalse);
      });

      test('suspended billing account', () {
        final account = BillingAccount(
          accountId: 'account_2',
          organizationId: 'org_1',
          accountName: 'Suspended Account',
          primaryContact: 'contact@company.com',
          billingCycle: BillingCycle.monthly,
          createdAt: DateTime.now().subtract(Duration(days: 180)),
          suspendedAt: DateTime.now(),
          isActive: false,
        );

        expect(account.isSuspended, isTrue);
      });

      test('account with secondary contact', () {
        final account = BillingAccount(
          accountId: 'account_3',
          organizationId: 'org_1',
          accountName: 'Full Account',
          primaryContact: 'primary@company.com',
          secondaryContact: 'secondary@company.com',
          billingCycle: BillingCycle.monthly,
          createdAt: DateTime.now(),
          isActive: true,
        );

        expect(account.hasSecondaryContact, isTrue);
      });
    });

    // BudgetAllocation Tests
    group('BudgetAllocation', () {
      test('create budget within limit', () {
        final budget = BudgetAllocation(
          budgetId: 'budget_1',
          projectId: 'project_1',
          budgetName: 'Q1 Budget',
          budgetLimit: 10000.0,
          currency: CurrencyCode.usd,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 90)),
          currentSpending: 3000.0,
          costTypeRestrictions: [],
        );

        expect(budget.isExceeded, isFalse);
        expect(budget.utilizationPercentage, equals(30.0));
      });

      test('budget warning level', () {
        final budget = BudgetAllocation(
          budgetId: 'budget_2',
          projectId: 'project_1',
          budgetName: 'Warning Budget',
          budgetLimit: 5000.0,
          currency: CurrencyCode.usd,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 90)),
          currentSpending: 4100.0,
          costTypeRestrictions: [],
        );

        expect(budget.isWarning, isTrue);
        expect(budget.utilizationPercentage, equals(82.0));
      });

      test('exceeded budget', () {
        final budget = BudgetAllocation(
          budgetId: 'budget_3',
          projectId: 'project_1',
          budgetName: 'Exceeded Budget',
          budgetLimit: 5000.0,
          currency: CurrencyCode.usd,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 90)),
          currentSpending: 6000.0,
          costTypeRestrictions: [],
        );

        expect(budget.isExceeded, isTrue);
        expect(budget.isCritical, isTrue);
      });
    });

    // CostForecast Tests
    group('CostForecast', () {
      test('create forecast', () {
        final forecast = CostForecast(
          forecastId: 'forecast_1',
          resourceId: 'resource_1',
          costType: CostType.compute,
          forecastDate: DateTime.now().add(Duration(days: 30)),
          projectedCost: 1000.0,
          lowerBound: 900.0,
          upperBound: 1100.0,
          confidence: 0.95,
          dataPointsUsed: 90,
        );

        expect(forecast.isHighConfidence, isTrue);
        expect(forecast.forecastRange, equals(200.0));
      });

      test('forecast range calculation', () {
        final forecast = CostForecast(
          forecastId: 'forecast_2',
          resourceId: 'resource_1',
          costType: CostType.storage,
          forecastDate: DateTime.now().add(Duration(days: 7)),
          projectedCost: 500.0,
          lowerBound: 450.0,
          upperBound: 550.0,
          confidence: 0.85,
          dataPointsUsed: 30,
        );

        expect(forecast.isHighConfidence, isFalse);
        expect(forecast.forecastRange, equals(100.0));
      });
    });

    // Payment Tests
    group('Payment', () {
      test('successful payment', () {
        final payment = Payment(
          paymentId: 'pay_1',
          invoiceId: 'inv_1',
          amount: 1000.0,
          currency: CurrencyCode.usd,
          status: PaymentStatus.completed,
          paymentDate: DateTime.now(),
          paymentMethod: 'credit_card',
        );

        expect(payment.isSuccessful, isTrue);
        expect(payment.isFailed, isFalse);
      });

      test('failed payment', () {
        final payment = Payment(
          paymentId: 'pay_2',
          invoiceId: 'inv_2',
          amount: 500.0,
          currency: CurrencyCode.usd,
          status: PaymentStatus.failed,
          paymentDate: DateTime.now(),
          paymentMethod: 'bank_transfer',
          notes: 'Insufficient funds',
        );

        expect(payment.isFailed, isTrue);
      });

      test('recent payment', () {
        final payment = Payment(
          paymentId: 'pay_3',
          invoiceId: 'inv_3',
          amount: 750.0,
          currency: CurrencyCode.usd,
          status: PaymentStatus.completed,
          paymentDate: DateTime.now().subtract(Duration(days: 5)),
          paymentMethod: 'ach',
        );

        expect(payment.isRecent, isTrue);
      });
    });

    // CostOptimization Tests
    group('CostOptimization', () {
      test('pending optimization', () {
        final optimization = CostOptimization(
          optimizationId: 'opt_1',
          resourceId: 'resource_1',
          title: 'Reserved Instance',
          description: 'Use reserved instances for stable workloads',
          potentialSavings: 5000.0,
          currency: CurrencyCode.usd,
          discoveredAt: DateTime.now(),
          recommendation: 'Purchase 1-year reserved instances',
        );

        expect(optimization.isPending, isTrue);
        expect(optimization.isImplemented, isFalse);
      });

      test('implemented optimization', () {
        final optimization = CostOptimization(
          optimizationId: 'opt_2',
          resourceId: 'resource_1',
          title: 'Right-sizing',
          description: 'Reduce instance size',
          potentialSavings: 2000.0,
          currency: CurrencyCode.usd,
          discoveredAt: DateTime.now().subtract(Duration(days: 30)),
          implementedAt: DateTime.now().subtract(Duration(days: 15)),
          actualSavings: 1800.0,
        );

        expect(optimization.isImplemented, isTrue);
        expect(optimization.savingsRealizationRate, equals(90.0));
      });
    });

    // Repository Tests
    group('MemoryCostBillingRepository', () {
      test('recordCostAllocation and retrieve', () async {
        final allocation = CostAllocation(
          allocationId: 'alloc_test_1',
          resourceId: 'resource_1',
          projectId: 'project_1',
          costType: CostType.compute,
          amount: 100.0,
          currency: CurrencyCode.usd,
          allocatedAt: DateTime.now(),
        );

        await repository.recordCostAllocation(allocation);
        final retrieved = await repository.getCostAllocation('alloc_test_1');

        expect(retrieved, isNotNull);
        expect(retrieved?.amount, equals(100.0));
      });

      test('getUnbilledCosts', () async {
        final alloc1 = CostAllocation(
          allocationId: 'alloc_1',
          resourceId: 'resource_1',
          projectId: 'project_1',
          costType: CostType.compute,
          amount: 100.0,
          currency: CurrencyCode.usd,
          allocatedAt: DateTime.now(),
        );
        final alloc2 = CostAllocation(
          allocationId: 'alloc_2',
          resourceId: 'resource_1',
          projectId: 'project_1',
          costType: CostType.storage,
          amount: 50.0,
          currency: CurrencyCode.usd,
          allocatedAt: DateTime.now(),
          billedAt: DateTime.now(),
        );

        await repository.recordCostAllocation(alloc1);
        await repository.recordCostAllocation(alloc2);
        final unbilled = await repository.getUnbilledCosts();

        expect(unbilled.length, equals(1));
      });

      test('createInvoice and getUnpaidInvoices', () async {
        final invoice = Invoice(
          invoiceId: 'inv_repo_1',
          billingAccountId: 'account_1',
          billingPeriodId: 'period_1',
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
          totalAmount: 1000.0,
          currency: CurrencyCode.usd,
          status: InvoiceStatus.sent,
          lineItems: {},
        );

        await repository.createInvoice(invoice);
        final unpaid = await repository.getUnpaidInvoices();

        expect(unpaid.isNotEmpty, isTrue);
      });

      test('createBudgetAllocation and getExceededBudgets', () async {
        final budget = BudgetAllocation(
          budgetId: 'budget_repo_1',
          projectId: 'project_1',
          budgetName: 'Test Budget',
          budgetLimit: 1000.0,
          currency: CurrencyCode.usd,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          currentSpending: 1500.0,
          costTypeRestrictions: [],
        );

        await repository.createBudgetAllocation(budget);
        final exceeded = await repository.getExceededBudgets();

        expect(exceeded.isNotEmpty, isTrue);
      });
    });

    // Engine Tests
    group('Engines', () {
      test('CostCalculationEngine recordCostAllocation', () async {
        final allocation = await facade.recordCost('resource_1', 'project_1', CostType.compute, 100.0);

        expect(allocation.allocationId, isNotEmpty);
        expect(allocation.amount, equals(100.0));
      });

      test('BillingEngine createInvoice', () async {
        final invoice = await facade.createInvoice('account_1', 'period_1', 2000.0, {'compute': 1200.0, 'storage': 800.0});

        expect(invoice.invoiceId, isNotEmpty);
        expect(invoice.status, equals(InvoiceStatus.draft));
      });

      test('BudgetManagementEngine createBudget', () async {
        final budget = await facade.createBudget('project_1', 'Q1', 5000.0, DateTime.now(), DateTime.now().add(Duration(days: 90)));

        expect(budget.budgetId, isNotEmpty);
        expect(budget.budgetLimit, equals(5000.0));
      });

      test('ForecastingEngine generateForecast', () async {
        final forecast = await facade.generateForecast('resource_1', CostType.compute, 1000.0);

        expect(forecast.forecastId, isNotEmpty);
        expect(forecast.isHighConfidence, isTrue);
      });

      test('CostOptimizationEngine suggestOptimization', () async {
        final optimization = await facade.suggestOptimization('resource_1', 'Title', 'Description', 5000.0);

        expect(optimization.optimizationId, isNotEmpty);
        expect(optimization.isPending, isTrue);
      });
    });

    // Facade Integration Tests
    group('CostBillingFacade Integration', () {
      test('end-to-end billing workflow', () async {
        // Record costs
        await facade.recordCost('resource_1', 'project_1', CostType.compute, 1000.0);
        await facade.recordCost('resource_2', 'project_1', CostType.storage, 500.0);

        // Create budget
        await facade.createBudget('project_1', 'Q1', 5000.0, DateTime.now(), DateTime.now().add(Duration(days: 90)));

        // Create invoice
        final invoice = await facade.createInvoice('account_1', 'period_1', 1500.0, {'compute': 1000.0, 'storage': 500.0});

        // Send invoice
        await facade.sendInvoice(invoice.invoiceId);

        // Mark as paid
        await facade.markInvoicePaid(invoice.invoiceId, 1500.0);

        expect(invoice.invoiceId, isNotEmpty);
      });

      test('budget warning and exceeded checks', () async {
        final budget = await facade.createBudget('project_1', 'Budget', 10000.0, DateTime.now(), DateTime.now().add(Duration(days: 90)));
        final exceeded = await facade.getExceededBudgets();

        expect(budget.budgetLimit, equals(10000.0));
        expect(exceeded, isEmpty);
      });

      test('cost forecasting', () async {
        final forecast = await facade.generateForecast('resource_1', CostType.compute, 2000.0);

        expect(forecast.projectedCost, equals(2000.0));
        expect(forecast.lowerBound, lessThan(forecast.projectedCost));
        expect(forecast.upperBound, greaterThan(forecast.projectedCost));
      });
    });

    // Edge Cases
    group('Edge Cases', () {
      test('zero cost allocation', () {
        final allocation = CostAllocation(
          allocationId: 'alloc_edge_1',
          resourceId: 'resource_1',
          projectId: 'project_1',
          costType: CostType.compute,
          amount: 0.0,
          currency: CurrencyCode.usd,
          allocatedAt: DateTime.now(),
        );

        expect(allocation.amount, equals(0.0));
      });

      test('invoice with zero line items', () {
        final invoice = Invoice(
          invoiceId: 'inv_edge_1',
          billingAccountId: 'account_1',
          billingPeriodId: 'period_1',
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
          totalAmount: 0.0,
          currency: CurrencyCode.usd,
          status: InvoiceStatus.draft,
          lineItems: {},
        );

        expect(invoice.lineItems.isEmpty, isTrue);
      });

      test('budget utilization edge case', () {
        final budget = BudgetAllocation(
          budgetId: 'budget_edge_1',
          projectId: 'project_1',
          budgetName: 'Edge Budget',
          budgetLimit: 100.0,
          currency: CurrencyCode.usd,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 1)),
          currentSpending: 80.0,
          costTypeRestrictions: [],
        );

        expect(budget.utilizationPercentage, equals(80.0));
        expect(budget.isWarning, isTrue);
      });

      test('forecast confidence boundary', () {
        final forecast = CostForecast(
          forecastId: 'forecast_edge_1',
          resourceId: 'resource_1',
          costType: CostType.compute,
          forecastDate: DateTime.now().add(Duration(days: 30)),
          projectedCost: 1000.0,
          lowerBound: 900.0,
          upperBound: 1100.0,
          confidence: 0.90,
          dataPointsUsed: 30,
        );

        expect(forecast.isHighConfidence, isTrue);
      });

      test('multiple currencies handling', () {
        final allocations = [
          CostAllocation(
            allocationId: 'alloc_eur_1',
            resourceId: 'resource_1',
            projectId: 'project_1',
            costType: CostType.compute,
            amount: 100.0,
            currency: CurrencyCode.eur,
            allocatedAt: DateTime.now(),
          ),
          CostAllocation(
            allocationId: 'alloc_gbp_1',
            resourceId: 'resource_1',
            projectId: 'project_1',
            costType: CostType.compute,
            amount: 80.0,
            currency: CurrencyCode.gbp,
            allocatedAt: DateTime.now(),
          ),
        ];

        expect(allocations[0].currency, equals(CurrencyCode.eur));
        expect(allocations[1].currency, equals(CurrencyCode.gbp));
      });
    });

    // Performance Tests
    group('Performance', () {
      test('handle large cost volume', () async {
        for (int i = 0; i < 100; i++) {
          await facade.recordCost('resource_1', 'project_1', CostType.compute, (i * 10).toDouble());
        }

        final costs = await repository.getResourceCosts('resource_1');
        expect(costs.length, equals(100));
      });

      test('rapid invoice creation', () async {
        for (int i = 0; i < 50; i++) {
          await facade.createInvoice('account_1', 'period_$i', (i * 100).toDouble(), {});
        }

        final invoices = await repository.getAccountInvoices('account_1');
        expect(invoices.length, equals(50));
      });
    });
  });
}
