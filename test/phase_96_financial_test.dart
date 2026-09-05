/// Comprehensive test suite for Phase 96: Advanced Financial Management & Accounting
/// Tests all models, enums, repository operations, engines, managers, and facades

import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/financial_models.dart';
import 'package:project_040/services/financial_service.dart';

void main() {
  group('Phase 96: Financial Management & Accounting Tests', () {
    late FinancialFacade facade;
    late FinancialRepository repository;

    setUp(() {
      repository = InMemoryFinancialRepository();
      facade = FinancialFacade(repository);
    });

    // ========================================================================
    // Enum Tests (7 enums)
    // ========================================================================

    group('Enum Tests', () {
      test('AccountType has all values', () {
        expect(AccountType.values.length, 7);
        expect(AccountType.values, contains(AccountType.asset));
        expect(AccountType.values, contains(AccountType.liability));
        expect(AccountType.values, contains(AccountType.revenue));
      });

      test('AccountType has display names', () {
        expect(AccountType.asset.displayName, 'Asset (資産)');
        expect(AccountType.revenue.displayName, 'Revenue (収益)');
      });

      test('ExpenseCategory has all values', () {
        expect(ExpenseCategory.values.length, 8);
        expect(ExpenseCategory.values, contains(ExpenseCategory.salaries));
        expect(ExpenseCategory.values, contains(ExpenseCategory.technology));
      });

      test('BudgetStatus has all values', () {
        expect(BudgetStatus.values.length, 6);
        expect(BudgetStatus.values, contains(BudgetStatus.planning));
        expect(BudgetStatus.values, contains(BudgetStatus.completed));
      });

      test('InvoiceStatus has all values', () {
        expect(InvoiceStatus.values.length, 6);
        expect(InvoiceStatus.values, contains(InvoiceStatus.draft));
        expect(InvoiceStatus.values, contains(InvoiceStatus.paid));
      });

      test('PaymentMethod has all values', () {
        expect(PaymentMethod.values.length, 6);
        expect(PaymentMethod.values, contains(PaymentMethod.credit));
        expect(PaymentMethod.values, contains(PaymentMethod.crypto));
      });

      test('ReportType has all values', () {
        expect(ReportType.values.length, 7);
        expect(ReportType.values, contains(ReportType.incomeStatement));
      });

      test('AuditStatus has all values', () {
        expect(AuditStatus.values.length, 5);
        expect(AuditStatus.values, contains(AuditStatus.notStarted));
        expect(AuditStatus.values, contains(AuditStatus.approved));
      });
    });

    // ========================================================================
    // Model Tests (10 models)
    // ========================================================================

    group('Model Tests', () {
      test('ChartOfAccounts properties', () {
        final account = ChartOfAccounts(
          accountId: 'acc_001',
          accountNumber: '1000',
          accountName: 'Cash',
          accountType: AccountType.asset,
          balance: 50000,
          createdDate: DateTime.now(),
        );
        expect(account.accountId, 'acc_001');
        expect(account.isActive, true);
        expect(account.isAsset, true);
      });

      test('GeneralLedgerEntry properties', () {
        final entry = GeneralLedgerEntry(
          entryId: 'entry_001',
          journalEntryId: 'journal_001',
          accountId: 'acc_001',
          debitAmount: 1000,
          creditAmount: 0,
          description: 'Cash deposit',
          entryDate: DateTime.now(),
        );
        expect(entry.hasDebit, true);
        expect(entry.hasCredit, false);
        expect(entry.netAmount, 1000);
      });

      test('Budget computed properties', () {
        final budget = Budget(
          budgetId: 'bud_001',
          departmentId: 'dept_001',
          budgetName: 'Q1 Marketing',
          budgetAmount: 50000,
          spentAmount: 45000,
          status: BudgetStatus.active,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 90)),
        );
        expect(budget.isActive, true);
        expect(budget.isOverBudget, false);
        expect(budget.remaining, 5000);
        expect(budget.spendPercent, 90);
      });

      test('Budget over budget', () {
        final budget = Budget(
          budgetId: 'bud_002',
          departmentId: 'dept_001',
          budgetName: 'Over Budget',
          budgetAmount: 30000,
          spentAmount: 35000,
          status: BudgetStatus.active,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 90)),
        );
        expect(budget.isOverBudget, true);
        expect(budget.remaining, -5000);
      });

      test('Expense properties', () {
        final expense = Expense(
          expenseId: 'exp_001',
          employeeId: 'emp_001',
          description: 'Travel expense',
          amount: 1500,
          category: ExpenseCategory.travel,
          expenseDate: DateTime.now().subtract(Duration(days: 5)),
          isApproved: false,
        );
        expect(expense.isRecent, true);
        expect(expense.isPending, true);
      });

      test('Invoice computed properties', () {
        final invoice = Invoice(
          invoiceId: 'inv_001',
          clientId: 'client_001',
          invoiceAmount: 5000,
          status: InvoiceStatus.sent,
          invoiceDate: DateTime.now().subtract(Duration(days: 10)),
          dueDate: DateTime.now().add(Duration(days: 20)),
        );
        expect(invoice.isPaid, false);
        expect(invoice.isOverdue, false);
        expect(invoice.isRecent, true);
        expect(invoice.daysUntilDue, greaterThan(19));
      });

      test('Invoice overdue', () {
        final invoice = Invoice(
          invoiceId: 'inv_002',
          clientId: 'client_001',
          invoiceAmount: 5000,
          status: InvoiceStatus.sent,
          invoiceDate: DateTime.now().subtract(Duration(days: 60)),
          dueDate: DateTime.now().subtract(Duration(days: 10)),
        );
        expect(invoice.isOverdue, true);
      });

      test('Payment properties', () {
        final payment = Payment(
          paymentId: 'pay_001',
          invoiceId: 'inv_001',
          paymentAmount: 5000,
          paymentMethod: PaymentMethod.bankTransfer,
          paymentDate: DateTime.now().subtract(Duration(days: 3)),
        );
        expect(payment.isRecent, true);
        expect(payment.hasBankRecord, true);
      });

      test('TaxCalculation properties', () {
        final tax = TaxCalculation(
          taxId: 'tax_001',
          entityId: 'entity_001',
          taxableIncome: 100000,
          taxRate: 0.25,
          calculatedTax: 25000,
          calculationDate: DateTime.now(),
        );
        expect(tax.isCurrent, true);
        expect(tax.effectiveTaxRate, 25);
        expect(tax.afterTaxIncome, 75000);
      });

      test('FinancialReport properties', () {
        final report = FinancialReport(
          reportId: 'rpt_001',
          entityId: 'entity_001',
          reportType: ReportType.balanceSheet,
          reportDate: DateTime.now(),
          totalAssets: 500000,
          totalLiabilities: 200000,
          netIncome: 50000,
        );
        expect(report.isHealthy, true);
        expect(report.equity, 300000);
      });

      test('FinancialReport markdown', () {
        final report = FinancialReport(
          reportId: 'rpt_001',
          entityId: 'entity_001',
          reportType: ReportType.incomeStatement,
          reportDate: DateTime.now(),
          totalAssets: 100000,
          totalLiabilities: 30000,
          netIncome: 20000,
        );
        final markdown = report.toMarkdown();
        expect(markdown.contains('Financial Report'), true);
        expect(markdown.contains('100000'), true);
      });

      test('CostCenter properties', () {
        final center = CostCenter(
          costCenterId: 'cc_001',
          costCenterName: 'Sales',
          departmentId: 'dept_001',
          allocatedBudget: 100000,
          spentAmount: 75000,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 365)),
        );
        expect(center.isActive, true);
        expect(center.isOverBudget, false);
        expect(center.utilizationRate, 75);
      });
    });

    // ========================================================================
    // Repository Tests
    // ========================================================================

    group('Repository Tests - Chart of Accounts', () {
      test('Create and retrieve account', () async {
        final account = ChartOfAccounts(
          accountId: 'acc_001',
          accountNumber: '1000',
          accountName: 'Cash',
          accountType: AccountType.asset,
          balance: 50000,
          createdDate: DateTime.now(),
        );
        await repository.createChartOfAccount(account);
        final retrieved = await repository.getChartOfAccount('acc_001');
        expect(retrieved?.accountName, 'Cash');
      });

      test('Get accounts by type', () async {
        final asset = ChartOfAccounts(
          accountId: 'acc_001',
          accountNumber: '1000',
          accountName: 'Cash',
          accountType: AccountType.asset,
          balance: 50000,
          createdDate: DateTime.now(),
        );
        final liability = ChartOfAccounts(
          accountId: 'acc_002',
          accountNumber: '2000',
          accountName: 'Accounts Payable',
          accountType: AccountType.liability,
          balance: 20000,
          createdDate: DateTime.now(),
        );
        await repository.createChartOfAccount(asset);
        await repository.createChartOfAccount(liability);
        final assets = await repository.getAccountsByType(AccountType.asset);
        expect(assets.length, 1);
      });

      test('Get total balance', () async {
        final acc1 = ChartOfAccounts(
          accountId: 'acc_001',
          accountNumber: '1000',
          accountName: 'Cash',
          accountType: AccountType.asset,
          balance: 50000,
          createdDate: DateTime.now(),
        );
        final acc2 = ChartOfAccounts(
          accountId: 'acc_002',
          accountNumber: '1100',
          accountName: 'Savings',
          accountType: AccountType.asset,
          balance: 100000,
          createdDate: DateTime.now(),
        );
        await repository.createChartOfAccount(acc1);
        await repository.createChartOfAccount(acc2);
        final total = await repository.getTotalBalance();
        expect(total, 150000);
      });
    });

    group('Repository Tests - General Ledger', () {
      test('Create and retrieve ledger entry', () async {
        final entry = GeneralLedgerEntry(
          entryId: 'entry_001',
          journalEntryId: 'journal_001',
          accountId: 'acc_001',
          debitAmount: 1000,
          creditAmount: 0,
          description: 'Cash deposit',
          entryDate: DateTime.now(),
        );
        await repository.createGeneralLedgerEntry(entry);
        final retrieved = await repository.getGeneralLedgerEntry('entry_001');
        expect(retrieved?.debitAmount, 1000);
      });

      test('Get total debits and credits', () async {
        final debit = GeneralLedgerEntry(
          entryId: 'entry_001',
          journalEntryId: 'journal_001',
          accountId: 'acc_001',
          debitAmount: 1000,
          creditAmount: 0,
          description: 'Debit entry',
          entryDate: DateTime.now(),
        );
        final credit = GeneralLedgerEntry(
          entryId: 'entry_002',
          journalEntryId: 'journal_001',
          accountId: 'acc_002',
          debitAmount: 0,
          creditAmount: 1000,
          description: 'Credit entry',
          entryDate: DateTime.now(),
        );
        await repository.createGeneralLedgerEntry(debit);
        await repository.createGeneralLedgerEntry(credit);
        final totalDebits = await repository.getTotalDebits();
        final totalCredits = await repository.getTotalCredits();
        expect(totalDebits, 1000);
        expect(totalCredits, 1000);
      });
    });

    group('Repository Tests - Budget', () {
      test('Create and retrieve budget', () async {
        final budget = Budget(
          budgetId: 'bud_001',
          departmentId: 'dept_001',
          budgetName: 'Q1 Marketing',
          budgetAmount: 50000,
          spentAmount: 25000,
          status: BudgetStatus.active,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 90)),
        );
        await repository.createBudget(budget);
        final retrieved = await repository.getBudget('bud_001');
        expect(retrieved?.budgetName, 'Q1 Marketing');
      });

      test('Get active budgets', () async {
        final active = Budget(
          budgetId: 'bud_001',
          departmentId: 'dept_001',
          budgetName: 'Active',
          budgetAmount: 50000,
          spentAmount: 25000,
          status: BudgetStatus.active,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 90)),
        );
        await repository.createBudget(active);
        final result = await repository.getActiveBudgets();
        expect(result.length, greaterThan(0));
      });

      test('Get over budget items', () async {
        final overBudget = Budget(
          budgetId: 'bud_001',
          departmentId: 'dept_001',
          budgetName: 'Over Budget',
          budgetAmount: 30000,
          spentAmount: 35000,
          status: BudgetStatus.active,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 90)),
        );
        await repository.createBudget(overBudget);
        final result = await repository.getOverBudgetBudgets();
        expect(result.length, greaterThan(0));
      });

      test('Get total budget amount', () async {
        final bud1 = Budget(
          budgetId: 'bud_001',
          departmentId: 'dept_001',
          budgetName: 'Budget 1',
          budgetAmount: 50000,
          spentAmount: 25000,
          status: BudgetStatus.active,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 90)),
        );
        final bud2 = Budget(
          budgetId: 'bud_002',
          departmentId: 'dept_002',
          budgetName: 'Budget 2',
          budgetAmount: 100000,
          spentAmount: 50000,
          status: BudgetStatus.active,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 90)),
        );
        await repository.createBudget(bud1);
        await repository.createBudget(bud2);
        final total = await repository.getTotalBudgetAmount();
        expect(total, 150000);
      });
    });

    group('Repository Tests - Expense', () {
      test('Create and retrieve expense', () async {
        final expense = Expense(
          expenseId: 'exp_001',
          employeeId: 'emp_001',
          description: 'Laptop purchase',
          amount: 1500,
          category: ExpenseCategory.technology,
          expenseDate: DateTime.now(),
          isApproved: false,
        );
        await repository.createExpense(expense);
        final retrieved = await repository.getExpense('exp_001');
        expect(retrieved?.description, 'Laptop purchase');
      });

      test('Get expenses by category', () async {
        final techExpense = Expense(
          expenseId: 'exp_001',
          employeeId: 'emp_001',
          description: 'Equipment',
          amount: 2000,
          category: ExpenseCategory.technology,
          expenseDate: DateTime.now(),
        );
        await repository.createExpense(techExpense);
        final result =
            await repository.getExpensesByCategory(ExpenseCategory.technology);
        expect(result.length, greaterThan(0));
      });

      test('Get pending approval expenses', () async {
        final pending = Expense(
          expenseId: 'exp_001',
          employeeId: 'emp_001',
          description: 'Travel',
          amount: 1000,
          category: ExpenseCategory.travel,
          expenseDate: DateTime.now(),
          isApproved: false,
        );
        await repository.createExpense(pending);
        final result = await repository.getPendingApprovalExpenses();
        expect(result.length, greaterThan(0));
      });

      test('Get total expense amount', () async {
        final exp1 = Expense(
          expenseId: 'exp_001',
          employeeId: 'emp_001',
          description: 'Expense 1',
          amount: 1000,
          category: ExpenseCategory.travel,
          expenseDate: DateTime.now(),
        );
        final exp2 = Expense(
          expenseId: 'exp_002',
          employeeId: 'emp_002',
          description: 'Expense 2',
          amount: 500,
          category: ExpenseCategory.salaries,
          expenseDate: DateTime.now(),
        );
        await repository.createExpense(exp1);
        await repository.createExpense(exp2);
        final total = await repository.getTotalExpenseAmount();
        expect(total, 1500);
      });
    });

    group('Repository Tests - Invoice', () {
      test('Create and retrieve invoice', () async {
        final invoice = Invoice(
          invoiceId: 'inv_001',
          clientId: 'client_001',
          invoiceAmount: 5000,
          status: InvoiceStatus.sent,
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
        );
        await repository.createInvoice(invoice);
        final retrieved = await repository.getInvoice('inv_001');
        expect(retrieved?.invoiceAmount, 5000);
      });

      test('Get unpaid invoices', () async {
        final unpaid = Invoice(
          invoiceId: 'inv_001',
          clientId: 'client_001',
          invoiceAmount: 5000,
          status: InvoiceStatus.sent,
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
        );
        await repository.createInvoice(unpaid);
        final result = await repository.getUnpaidInvoices();
        expect(result.length, greaterThan(0));
      });

      test('Get overdue invoices', () async {
        final overdue = Invoice(
          invoiceId: 'inv_001',
          clientId: 'client_001',
          invoiceAmount: 5000,
          status: InvoiceStatus.sent,
          invoiceDate: DateTime.now().subtract(Duration(days: 60)),
          dueDate: DateTime.now().subtract(Duration(days: 10)),
        );
        await repository.createInvoice(overdue);
        final result = await repository.getOverdueInvoices();
        expect(result.length, greaterThan(0));
      });

      test('Get total invoice amount', () async {
        final inv1 = Invoice(
          invoiceId: 'inv_001',
          clientId: 'client_001',
          invoiceAmount: 5000,
          status: InvoiceStatus.sent,
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
        );
        final inv2 = Invoice(
          invoiceId: 'inv_002',
          clientId: 'client_002',
          invoiceAmount: 3000,
          status: InvoiceStatus.paid,
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
        );
        await repository.createInvoice(inv1);
        await repository.createInvoice(inv2);
        final total = await repository.getTotalInvoiceAmount();
        expect(total, 8000);
      });
    });

    group('Repository Tests - Payment', () {
      test('Create and retrieve payment', () async {
        final payment = Payment(
          paymentId: 'pay_001',
          invoiceId: 'inv_001',
          paymentAmount: 5000,
          paymentMethod: PaymentMethod.bankTransfer,
          paymentDate: DateTime.now(),
        );
        await repository.createPayment(payment);
        final retrieved = await repository.getPayment('pay_001');
        expect(retrieved?.paymentAmount, 5000);
      });

      test('Get payments by method', () async {
        final payment = Payment(
          paymentId: 'pay_001',
          invoiceId: 'inv_001',
          paymentAmount: 5000,
          paymentMethod: PaymentMethod.credit,
          paymentDate: DateTime.now(),
        );
        await repository.createPayment(payment);
        final result = await repository.getPaymentsByMethod(PaymentMethod.credit);
        expect(result.length, greaterThan(0));
      });

      test('Get total payment amount', () async {
        final pay1 = Payment(
          paymentId: 'pay_001',
          invoiceId: 'inv_001',
          paymentAmount: 5000,
          paymentMethod: PaymentMethod.credit,
          paymentDate: DateTime.now(),
        );
        final pay2 = Payment(
          paymentId: 'pay_002',
          invoiceId: 'inv_002',
          paymentAmount: 3000,
          paymentMethod: PaymentMethod.bankTransfer,
          paymentDate: DateTime.now(),
        );
        await repository.createPayment(pay1);
        await repository.createPayment(pay2);
        final total = await repository.getTotalPaymentAmount();
        expect(total, 8000);
      });
    });

    group('Repository Tests - Tax', () {
      test('Create and retrieve tax calculation', () async {
        final tax = TaxCalculation(
          taxId: 'tax_001',
          entityId: 'entity_001',
          taxableIncome: 100000,
          taxRate: 0.25,
          calculatedTax: 25000,
          calculationDate: DateTime.now(),
        );
        await repository.createTaxCalculation(tax);
        final retrieved = await repository.getTaxCalculation('tax_001');
        expect(retrieved?.calculatedTax, 25000);
      });

      test('Get total tax liability', () async {
        final tax1 = TaxCalculation(
          taxId: 'tax_001',
          entityId: 'entity_001',
          taxableIncome: 100000,
          taxRate: 0.25,
          calculatedTax: 25000,
          calculationDate: DateTime.now(),
        );
        final tax2 = TaxCalculation(
          taxId: 'tax_002',
          entityId: 'entity_002',
          taxableIncome: 50000,
          taxRate: 0.20,
          calculatedTax: 10000,
          calculationDate: DateTime.now(),
        );
        await repository.createTaxCalculation(tax1);
        await repository.createTaxCalculation(tax2);
        final total = await repository.getTotalTaxLiability();
        expect(total, 35000);
      });
    });

    group('Repository Tests - Financial Report', () {
      test('Create and retrieve report', () async {
        final report = FinancialReport(
          reportId: 'rpt_001',
          entityId: 'entity_001',
          reportType: ReportType.balanceSheet,
          reportDate: DateTime.now(),
          totalAssets: 500000,
          totalLiabilities: 200000,
          netIncome: 50000,
        );
        await repository.createFinancialReport(report);
        final retrieved = await repository.getFinancialReport('rpt_001');
        expect(retrieved?.totalAssets, 500000);
      });

      test('Get healthy reports', () async {
        final healthy = FinancialReport(
          reportId: 'rpt_001',
          entityId: 'entity_001',
          reportType: ReportType.incomeStatement,
          reportDate: DateTime.now(),
          totalAssets: 100000,
          totalLiabilities: 30000,
          netIncome: 20000,
        );
        await repository.createFinancialReport(healthy);
        final result = await repository.getHealthyReports();
        expect(result.length, greaterThan(0));
      });
    });

    group('Repository Tests - Audit Trail', () {
      test('Create and retrieve audit', () async {
        final audit = AuditTrail(
          auditId: 'audit_001',
          entityId: 'entity_001',
          changedBy: 'user_001',
          description: 'Initial audit',
          changedDate: DateTime.now(),
          auditStatus: AuditStatus.inProgress,
        );
        await repository.createAuditTrail(audit);
        final retrieved = await repository.getAuditTrail('audit_001');
        expect(retrieved?.auditStatus, AuditStatus.inProgress);
      });

      test('Get completed audits', () async {
        final completed = AuditTrail(
          auditId: 'audit_001',
          entityId: 'entity_001',
          changedBy: 'user_001',
          description: 'Completed audit',
          changedDate: DateTime.now(),
          auditStatus: AuditStatus.completed,
        );
        await repository.createAuditTrail(completed);
        final result = await repository.getCompletedAudits();
        expect(result.length, greaterThan(0));
      });
    });

    group('Repository Tests - Cost Center', () {
      test('Create and retrieve cost center', () async {
        final center = CostCenter(
          costCenterId: 'cc_001',
          costCenterName: 'Sales',
          departmentId: 'dept_001',
          allocatedBudget: 100000,
          spentAmount: 75000,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 365)),
        );
        await repository.createCostCenter(center);
        final retrieved = await repository.getCostCenter('cc_001');
        expect(retrieved?.costCenterName, 'Sales');
      });

      test('Get active cost centers', () async {
        final active = CostCenter(
          costCenterId: 'cc_001',
          costCenterName: 'Active Center',
          departmentId: 'dept_001',
          allocatedBudget: 100000,
          spentAmount: 75000,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 365)),
        );
        await repository.createCostCenter(active);
        final result = await repository.getActiveCostCenters();
        expect(result.length, greaterThan(0));
      });
    });

    // ========================================================================
    // Engine Tests
    // ========================================================================

    group('Engine Tests - AccountingEngine', () {
      test('Calculate total assets', () async {
        final asset = ChartOfAccounts(
          accountId: 'acc_001',
          accountNumber: '1000',
          accountName: 'Cash',
          accountType: AccountType.asset,
          balance: 100000,
          createdDate: DateTime.now(),
        );
        await repository.createChartOfAccount(asset);
        final engine = AccountingEngine(repository);
        final total = await engine.calculateTotalAssets();
        expect(total, 100000);
      });

      test('Calculate total liabilities', () async {
        final liability = ChartOfAccounts(
          accountId: 'acc_001',
          accountNumber: '2000',
          accountName: 'Accounts Payable',
          accountType: AccountType.liability,
          balance: 50000,
          createdDate: DateTime.now(),
        );
        await repository.createChartOfAccount(liability);
        final engine = AccountingEngine(repository);
        final total = await engine.calculateTotalLiabilities();
        expect(total, 50000);
      });
    });

    group('Engine Tests - BudgetMonitoringEngine', () {
      test('Get budget status distribution', () async {
        final budget = Budget(
          budgetId: 'bud_001',
          departmentId: 'dept_001',
          budgetName: 'Budget',
          budgetAmount: 50000,
          spentAmount: 25000,
          status: BudgetStatus.active,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 90)),
        );
        await repository.createBudget(budget);
        final engine = BudgetMonitoringEngine(repository);
        final dist = await engine.getBudgetStatusDistribution();
        expect(dist.keys.length, greaterThan(0));
      });

      test('Get average budget utilization', () async {
        final budget = Budget(
          budgetId: 'bud_001',
          departmentId: 'dept_001',
          budgetName: 'Budget',
          budgetAmount: 100000,
          spentAmount: 50000,
          status: BudgetStatus.active,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 90)),
        );
        await repository.createBudget(budget);
        final engine = BudgetMonitoringEngine(repository);
        final avg = await engine.getAverageBudgetUtilization();
        expect(avg, 50);
      });
    });

    group('Engine Tests - InvoiceManagementEngine', () {
      test('Get outstanding revenue', () async {
        final invoice = Invoice(
          invoiceId: 'inv_001',
          clientId: 'client_001',
          invoiceAmount: 5000,
          status: InvoiceStatus.sent,
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
        );
        await repository.createInvoice(invoice);
        final engine = InvoiceManagementEngine(repository);
        final outstanding = await engine.getOutstandingRevenue();
        expect(outstanding, 5000);
      });
    });

    group('Engine Tests - ExpenseTrackingEngine', () {
      test('Get expenses by category', () async {
        final expense = Expense(
          expenseId: 'exp_001',
          employeeId: 'emp_001',
          description: 'Office supplies',
          amount: 500,
          category: ExpenseCategory.operations,
          expenseDate: DateTime.now(),
        );
        await repository.createExpense(expense);
        final engine = ExpenseTrackingEngine(repository);
        final byCategory = await engine.getExpensesByCategory();
        expect(byCategory.keys.length, greaterThan(0));
      });
    });

    group('Engine Tests - TaxPlankEngine', () {
      test('Get total tax liability', () async {
        final tax = TaxCalculation(
          taxId: 'tax_001',
          entityId: 'entity_001',
          taxableIncome: 100000,
          taxRate: 0.25,
          calculatedTax: 25000,
          calculationDate: DateTime.now(),
        );
        await repository.createTaxCalculation(tax);
        final engine = TaxPlankEngine(repository);
        final total = await engine.getTotalTaxLiability();
        expect(total, 25000);
      });
    });

    // ========================================================================
    // Manager Tests
    // ========================================================================

    group('Manager Tests', () {
      test('Generate financial dashboard', () async {
        final account = ChartOfAccounts(
          accountId: 'acc_001',
          accountNumber: '1000',
          accountName: 'Cash',
          accountType: AccountType.asset,
          balance: 100000,
          createdDate: DateTime.now(),
        );
        await repository.createChartOfAccount(account);
        final manager = FinancialManager(repository);
        final dashboard = await manager.generateFinancialDashboard();
        expect(dashboard.containsKey('totalAssets'), true);
      });
    });

    // ========================================================================
    // Facade Tests
    // ========================================================================

    group('Facade Tests', () {
      test('Add and get account', () async {
        final account = ChartOfAccounts(
          accountId: 'acc_001',
          accountNumber: '1000',
          accountName: 'Cash',
          accountType: AccountType.asset,
          balance: 50000,
          createdDate: DateTime.now(),
        );
        await facade.addAccount(account);
        final retrieved = await facade.getAccount('acc_001');
        expect(retrieved?.accountName, 'Cash');
      });

      test('Create budget', () async {
        final budget = Budget(
          budgetId: 'bud_001',
          departmentId: 'dept_001',
          budgetName: 'Q1',
          budgetAmount: 50000,
          spentAmount: 25000,
          status: BudgetStatus.active,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 90)),
        );
        await facade.createBudget(budget);
        final active = await facade.getActiveBudgets();
        expect(active.length, greaterThan(0));
      });

      test('Get outstanding revenue', () async {
        final invoice = Invoice(
          invoiceId: 'inv_001',
          clientId: 'client_001',
          invoiceAmount: 5000,
          status: InvoiceStatus.sent,
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
        );
        await repository.createInvoice(invoice);
        final outstanding = await facade.getOutstandingRevenue();
        expect(outstanding, 5000);
      });

      test('Get financial dashboard', () async {
        final dashboard = await facade.getFinancialDashboard();
        expect(dashboard.isNotEmpty, true);
      });
    });

    // ========================================================================
    // Integration Tests
    // ========================================================================

    group('Integration Tests', () {
      test('Complete accounting workflow', () async {
        // Create accounts
        final cash = ChartOfAccounts(
          accountId: 'acc_001',
          accountNumber: '1000',
          accountName: 'Cash',
          accountType: AccountType.asset,
          balance: 100000,
          createdDate: DateTime.now(),
        );
        final revenue = ChartOfAccounts(
          accountId: 'acc_002',
          accountNumber: '4000',
          accountName: 'Sales Revenue',
          accountType: AccountType.revenue,
          balance: 50000,
          createdDate: DateTime.now(),
        );
        await repository.createChartOfAccount(cash);
        await repository.createChartOfAccount(revenue);

        // Create ledger entries
        final entry = GeneralLedgerEntry(
          entryId: 'entry_001',
          journalEntryId: 'journal_001',
          accountId: 'acc_001',
          debitAmount: 5000,
          creditAmount: 0,
          description: 'Sales collection',
          entryDate: DateTime.now(),
        );
        await repository.createGeneralLedgerEntry(entry);

        // Create financial report
        final report = FinancialReport(
          reportId: 'rpt_001',
          entityId: 'entity_001',
          reportType: ReportType.incomeStatement,
          reportDate: DateTime.now(),
          totalAssets: 100000,
          totalLiabilities: 0,
          netIncome: 50000,
        );
        await repository.createFinancialReport(report);

        final dashboard = await facade.getFinancialDashboard();
        expect(dashboard['totalAssets'], greaterThan(0));
      });

      test('Budget and expense workflow', () async {
        // Create budget
        final budget = Budget(
          budgetId: 'bud_001',
          departmentId: 'dept_001',
          budgetName: 'Marketing',
          budgetAmount: 50000,
          spentAmount: 0,
          status: BudgetStatus.active,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 90)),
        );
        await facade.createBudget(budget);

        // Submit expenses
        final exp1 = Expense(
          expenseId: 'exp_001',
          employeeId: 'emp_001',
          description: 'Ad campaign',
          amount: 15000,
          category: ExpenseCategory.marketing,
          expenseDate: DateTime.now(),
          isApproved: true,
        );
        final exp2 = Expense(
          expenseId: 'exp_002',
          employeeId: 'emp_002',
          description: 'Event sponsorship',
          amount: 10000,
          category: ExpenseCategory.marketing,
          expenseDate: DateTime.now(),
          isApproved: true,
        );
        await facade.submitExpense(exp1);
        await facade.submitExpense(exp2);

        final expenses = await facade.getExpenseBreakdown();
        expect(expenses[ExpenseCategory.marketing], 25000);
      });

      test('Invoice and payment workflow', () async {
        // Create invoice
        final invoice = Invoice(
          invoiceId: 'inv_001',
          clientId: 'client_001',
          invoiceAmount: 10000,
          status: InvoiceStatus.sent,
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(Duration(days: 30)),
        );
        await facade.createInvoice(invoice);

        // Record payment
        final payment = Payment(
          paymentId: 'pay_001',
          invoiceId: 'inv_001',
          paymentAmount: 10000,
          paymentMethod: PaymentMethod.bankTransfer,
          paymentDate: DateTime.now(),
        );
        await repository.createPayment(payment);

        final outstanding = await facade.getOutstandingRevenue();
        expect(outstanding, 0);
      });
    });
  });
}
