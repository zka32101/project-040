/// Advanced Financial Management & Accounting Service
/// Provides comprehensive accounting, budgeting, expense tracking, and financial reporting

import 'package:flutter/foundation.dart';
import '../models/financial_models.dart';

// ============================================================================
// Repository Interface
// ============================================================================

abstract class FinancialRepository {
  // Chart of Accounts Methods (12)
  Future<void> createChartOfAccount(ChartOfAccounts account);
  Future<ChartOfAccounts?> getChartOfAccount(String accountId);
  Future<List<ChartOfAccounts>> getAllAccounts();
  Future<List<ChartOfAccounts>> getAccountsByType(AccountType type);
  Future<List<ChartOfAccounts>> getActiveAccounts();
  Future<List<ChartOfAccounts>> getAccountsByBalance(double minBalance);
  Future<void> updateChartOfAccount(ChartOfAccounts account);
  Future<void> deleteChartOfAccount(String accountId);
  Future<int> getAccountCount();
  Future<double> getTotalBalance();
  Future<List<ChartOfAccounts>> getRecentlyCreatedAccounts(Duration duration);
  Future<List<ChartOfAccounts>> getAssetAccounts();

  // General Ledger Entry Methods (10)
  Future<void> createGeneralLedgerEntry(GeneralLedgerEntry entry);
  Future<GeneralLedgerEntry?> getGeneralLedgerEntry(String entryId);
  Future<List<GeneralLedgerEntry>> getEntriesForAccount(String accountId);
  Future<List<GeneralLedgerEntry>> getEntriesByJournal(String journalEntryId);
  Future<List<GeneralLedgerEntry>> getDebitEntries();
  Future<List<GeneralLedgerEntry>> getCreditEntries();
  Future<void> updateGeneralLedgerEntry(GeneralLedgerEntry entry);
  Future<void> deleteGeneralLedgerEntry(String entryId);
  Future<double> getTotalDebits();
  Future<double> getTotalCredits();

  // Budget Methods (12)
  Future<void> createBudget(Budget budget);
  Future<Budget?> getBudget(String budgetId);
  Future<List<Budget>> getAllBudgets();
  Future<List<Budget>> getActiveBudgets();
  Future<List<Budget>> getOverBudgetBudgets();
  Future<List<Budget>> getBudgetsByDepartment(String departmentId);
  Future<List<Budget>> getBudgetsByStatus(BudgetStatus status);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(String budgetId);
  Future<int> getBudgetCount();
  Future<double> getTotalBudgetAmount();
  Future<List<Budget>> getExpiredBudgets();

  // Expense Methods (12)
  Future<void> createExpense(Expense expense);
  Future<Expense?> getExpense(String expenseId);
  Future<List<Expense>> getExpensesForEmployee(String employeeId);
  Future<List<Expense>> getExpensesByCategory(ExpenseCategory category);
  Future<List<Expense>> getPendingApprovalExpenses();
  Future<List<Expense>> getApprovedExpenses();
  Future<List<Expense>> getRecentExpenses(Duration duration);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String expenseId);
  Future<int> getExpenseCount();
  Future<double> getTotalExpenseAmount();
  Future<List<Expense>> getExpensesWithReceipts();

  // Invoice Methods (12)
  Future<void> createInvoice(Invoice invoice);
  Future<Invoice?> getInvoice(String invoiceId);
  Future<List<Invoice>> getInvoicesForClient(String clientId);
  Future<List<Invoice>> getPaidInvoices();
  Future<List<Invoice>> getUnpaidInvoices();
  Future<List<Invoice>> getOverdueInvoices();
  Future<List<Invoice>> getInvoicesByStatus(InvoiceStatus status);
  Future<void> updateInvoice(Invoice invoice);
  Future<void> deleteInvoice(String invoiceId);
  Future<int> getInvoiceCount();
  Future<double> getTotalInvoiceAmount();
  Future<List<Invoice>> getRecentInvoices(Duration duration);

  // Payment Methods (10)
  Future<void> createPayment(Payment payment);
  Future<Payment?> getPayment(String paymentId);
  Future<List<Payment>> getPaymentsForInvoice(String invoiceId);
  Future<List<Payment>> getPaymentsByMethod(PaymentMethod method);
  Future<List<Payment>> getRecentPayments(Duration duration);
  Future<void> updatePayment(Payment payment);
  Future<void> deletePayment(String paymentId);
  Future<int> getPaymentCount();
  Future<double> getTotalPaymentAmount();
  Future<List<Payment>> getPaymentsByDate(DateTime startDate, DateTime endDate);

  // Tax Calculation Methods (10)
  Future<void> createTaxCalculation(TaxCalculation tax);
  Future<TaxCalculation?> getTaxCalculation(String taxId);
  Future<List<TaxCalculation>> getTaxCalculationsForEntity(String entityId);
  Future<List<TaxCalculation>> getCurrentTaxCalculations();
  Future<List<TaxCalculation>> getTaxCalculationsByYear(int year);
  Future<void> updateTaxCalculation(TaxCalculation tax);
  Future<void> deleteTaxCalculation(String taxId);
  Future<int> getTaxCalculationCount();
  Future<double> getTotalTaxLiability();
  Future<double> getTotalAfterTaxIncome();

  // Financial Report Methods (10)
  Future<void> createFinancialReport(FinancialReport report);
  Future<FinancialReport?> getFinancialReport(String reportId);
  Future<List<FinancialReport>> getReportsForEntity(String entityId);
  Future<List<FinancialReport>> getReportsByType(ReportType type);
  Future<List<FinancialReport>> getRecentReports(Duration duration);
  Future<void> updateFinancialReport(FinancialReport report);
  Future<void> deleteFinancialReport(String reportId);
  Future<int> getReportCount();
  Future<List<FinancialReport>> getHealthyReports();
  Future<FinancialReport?> getLatestReportForEntity(String entityId);

  // Audit Trail Methods (8)
  Future<void> createAuditTrail(AuditTrail audit);
  Future<AuditTrail?> getAuditTrail(String auditId);
  Future<List<AuditTrail>> getAuditTrailsForEntity(String entityId);
  Future<List<AuditTrail>> getCompletedAudits();
  Future<void> updateAuditTrail(AuditTrail audit);
  Future<void> deleteAuditTrail(String auditId);
  Future<int> getAuditCount();
  Future<List<AuditTrail>> getRecentAudits(Duration duration);

  // Cost Center Methods (10)
  Future<void> createCostCenter(CostCenter center);
  Future<CostCenter?> getCostCenter(String costCenterId);
  Future<List<CostCenter>> getCostCentersByDepartment(String departmentId);
  Future<List<CostCenter>> getActiveCostCenters();
  Future<List<CostCenter>> getOverBudgetCostCenters();
  Future<void> updateCostCenter(CostCenter center);
  Future<void> deleteCostCenter(String costCenterId);
  Future<int> getCostCenterCount();
  Future<double> getTotalCostCenterBudget();
  Future<List<CostCenter>> getCostCentersByUtilization(double minRate);
}

// ============================================================================
// In-Memory Repository Implementation
// ============================================================================

class InMemoryFinancialRepository implements FinancialRepository {
  final Map<String, ChartOfAccounts> _accounts = {};
  final Map<String, GeneralLedgerEntry> _ledgerEntries = {};
  final Map<String, Budget> _budgets = {};
  final Map<String, Expense> _expenses = {};
  final Map<String, Invoice> _invoices = {};
  final Map<String, Payment> _payments = {};
  final Map<String, TaxCalculation> _taxes = {};
  final Map<String, FinancialReport> _reports = {};
  final Map<String, AuditTrail> _audits = {};
  final Map<String, CostCenter> _costCenters = {};

  // Chart of Accounts Methods
  @override
  Future<void> createChartOfAccount(ChartOfAccounts account) async {
    _accounts[account.accountId] = account;
  }

  @override
  Future<ChartOfAccounts?> getChartOfAccount(String accountId) async {
    return _accounts[accountId];
  }

  @override
  Future<List<ChartOfAccounts>> getAllAccounts() async {
    return _accounts.values.toList();
  }

  @override
  Future<List<ChartOfAccounts>> getAccountsByType(AccountType type) async {
    return _accounts.values.where((a) => a.accountType == type).toList();
  }

  @override
  Future<List<ChartOfAccounts>> getActiveAccounts() async {
    return _accounts.values.where((a) => a.isActive).toList();
  }

  @override
  Future<List<ChartOfAccounts>> getAccountsByBalance(double minBalance) async {
    return _accounts.values
        .where((a) => a.balance >= minBalance)
        .toList();
  }

  @override
  Future<void> updateChartOfAccount(ChartOfAccounts account) async {
    _accounts[account.accountId] = account;
  }

  @override
  Future<void> deleteChartOfAccount(String accountId) async {
    _accounts.remove(accountId);
  }

  @override
  Future<int> getAccountCount() async {
    return _accounts.length;
  }

  @override
  Future<double> getTotalBalance() async {
    return _accounts.values.fold<double>(0, (sum, a) => sum + a.balance);
  }

  @override
  Future<List<ChartOfAccounts>> getRecentlyCreatedAccounts(
      Duration duration) async {
    final threshold = DateTime.now().subtract(duration);
    return _accounts.values
        .where((a) => a.createdDate.isAfter(threshold))
        .toList();
  }

  @override
  Future<List<ChartOfAccounts>> getAssetAccounts() async {
    return _accounts.values
        .where((a) => a.accountType == AccountType.asset)
        .toList();
  }

  // General Ledger Entry Methods
  @override
  Future<void> createGeneralLedgerEntry(GeneralLedgerEntry entry) async {
    _ledgerEntries[entry.entryId] = entry;
  }

  @override
  Future<GeneralLedgerEntry?> getGeneralLedgerEntry(String entryId) async {
    return _ledgerEntries[entryId];
  }

  @override
  Future<List<GeneralLedgerEntry>> getEntriesForAccount(
      String accountId) async {
    return _ledgerEntries.values
        .where((e) => e.accountId == accountId)
        .toList();
  }

  @override
  Future<List<GeneralLedgerEntry>> getEntriesByJournal(
      String journalEntryId) async {
    return _ledgerEntries.values
        .where((e) => e.journalEntryId == journalEntryId)
        .toList();
  }

  @override
  Future<List<GeneralLedgerEntry>> getDebitEntries() async {
    return _ledgerEntries.values.where((e) => e.hasDebit).toList();
  }

  @override
  Future<List<GeneralLedgerEntry>> getCreditEntries() async {
    return _ledgerEntries.values.where((e) => e.hasCredit).toList();
  }

  @override
  Future<void> updateGeneralLedgerEntry(GeneralLedgerEntry entry) async {
    _ledgerEntries[entry.entryId] = entry;
  }

  @override
  Future<void> deleteGeneralLedgerEntry(String entryId) async {
    _ledgerEntries.remove(entryId);
  }

  @override
  Future<double> getTotalDebits() async {
    return _ledgerEntries.values
        .fold<double>(0, (sum, e) => sum + e.debitAmount);
  }

  @override
  Future<double> getTotalCredits() async {
    return _ledgerEntries.values
        .fold<double>(0, (sum, e) => sum + e.creditAmount);
  }

  // Budget Methods
  @override
  Future<void> createBudget(Budget budget) async {
    _budgets[budget.budgetId] = budget;
  }

  @override
  Future<Budget?> getBudget(String budgetId) async {
    return _budgets[budgetId];
  }

  @override
  Future<List<Budget>> getAllBudgets() async {
    return _budgets.values.toList();
  }

  @override
  Future<List<Budget>> getActiveBudgets() async {
    return _budgets.values.where((b) => b.isActive).toList();
  }

  @override
  Future<List<Budget>> getOverBudgetBudgets() async {
    return _budgets.values.where((b) => b.isOverBudget).toList();
  }

  @override
  Future<List<Budget>> getBudgetsByDepartment(String departmentId) async {
    return _budgets.values
        .where((b) => b.departmentId == departmentId)
        .toList();
  }

  @override
  Future<List<Budget>> getBudgetsByStatus(BudgetStatus status) async {
    return _budgets.values.where((b) => b.status == status).toList();
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    _budgets[budget.budgetId] = budget;
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    _budgets.remove(budgetId);
  }

  @override
  Future<int> getBudgetCount() async {
    return _budgets.length;
  }

  @override
  Future<double> getTotalBudgetAmount() async {
    return _budgets.values.fold<double>(0, (sum, b) => sum + b.budgetAmount);
  }

  @override
  Future<List<Budget>> getExpiredBudgets() async {
    return _budgets.values.where((b) => b.isExpired).toList();
  }

  // Expense Methods
  @override
  Future<void> createExpense(Expense expense) async {
    _expenses[expense.expenseId] = expense;
  }

  @override
  Future<Expense?> getExpense(String expenseId) async {
    return _expenses[expenseId];
  }

  @override
  Future<List<Expense>> getExpensesForEmployee(String employeeId) async {
    return _expenses.values.where((e) => e.employeeId == employeeId).toList();
  }

  @override
  Future<List<Expense>> getExpensesByCategory(ExpenseCategory category) async {
    return _expenses.values.where((e) => e.category == category).toList();
  }

  @override
  Future<List<Expense>> getPendingApprovalExpenses() async {
    return _expenses.values.where((e) => e.isPending).toList();
  }

  @override
  Future<List<Expense>> getApprovedExpenses() async {
    return _expenses.values.where((e) => e.isApproved).toList();
  }

  @override
  Future<List<Expense>> getRecentExpenses(Duration duration) async {
    final threshold = DateTime.now().subtract(duration);
    return _expenses.values
        .where((e) => e.expenseDate.isAfter(threshold))
        .toList();
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    _expenses[expense.expenseId] = expense;
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    _expenses.remove(expenseId);
  }

  @override
  Future<int> getExpenseCount() async {
    return _expenses.length;
  }

  @override
  Future<double> getTotalExpenseAmount() async {
    return _expenses.values.fold<double>(0, (sum, e) => sum + e.amount);
  }

  @override
  Future<List<Expense>> getExpensesWithReceipts() async {
    return _expenses.values.where((e) => e.hasReceipt).toList();
  }

  // Invoice Methods
  @override
  Future<void> createInvoice(Invoice invoice) async {
    _invoices[invoice.invoiceId] = invoice;
  }

  @override
  Future<Invoice?> getInvoice(String invoiceId) async {
    return _invoices[invoiceId];
  }

  @override
  Future<List<Invoice>> getInvoicesForClient(String clientId) async {
    return _invoices.values.where((i) => i.clientId == clientId).toList();
  }

  @override
  Future<List<Invoice>> getPaidInvoices() async {
    return _invoices.values.where((i) => i.isPaid).toList();
  }

  @override
  Future<List<Invoice>> getUnpaidInvoices() async {
    return _invoices.values.where((i) => !i.isPaid).toList();
  }

  @override
  Future<List<Invoice>> getOverdueInvoices() async {
    return _invoices.values.where((i) => i.isOverdue).toList();
  }

  @override
  Future<List<Invoice>> getInvoicesByStatus(InvoiceStatus status) async {
    return _invoices.values.where((i) => i.status == status).toList();
  }

  @override
  Future<void> updateInvoice(Invoice invoice) async {
    _invoices[invoice.invoiceId] = invoice;
  }

  @override
  Future<void> deleteInvoice(String invoiceId) async {
    _invoices.remove(invoiceId);
  }

  @override
  Future<int> getInvoiceCount() async {
    return _invoices.length;
  }

  @override
  Future<double> getTotalInvoiceAmount() async {
    return _invoices.values
        .fold<double>(0, (sum, i) => sum + i.invoiceAmount);
  }

  @override
  Future<List<Invoice>> getRecentInvoices(Duration duration) async {
    final threshold = DateTime.now().subtract(duration);
    return _invoices.values
        .where((i) => i.invoiceDate.isAfter(threshold))
        .toList();
  }

  // Payment Methods
  @override
  Future<void> createPayment(Payment payment) async {
    _payments[payment.paymentId] = payment;
  }

  @override
  Future<Payment?> getPayment(String paymentId) async {
    return _payments[paymentId];
  }

  @override
  Future<List<Payment>> getPaymentsForInvoice(String invoiceId) async {
    return _payments.values.where((p) => p.invoiceId == invoiceId).toList();
  }

  @override
  Future<List<Payment>> getPaymentsByMethod(PaymentMethod method) async {
    return _payments.values.where((p) => p.paymentMethod == method).toList();
  }

  @override
  Future<List<Payment>> getRecentPayments(Duration duration) async {
    final threshold = DateTime.now().subtract(duration);
    return _payments.values
        .where((p) => p.paymentDate.isAfter(threshold))
        .toList();
  }

  @override
  Future<void> updatePayment(Payment payment) async {
    _payments[payment.paymentId] = payment;
  }

  @override
  Future<void> deletePayment(String paymentId) async {
    _payments.remove(paymentId);
  }

  @override
  Future<int> getPaymentCount() async {
    return _payments.length;
  }

  @override
  Future<double> getTotalPaymentAmount() async {
    return _payments.values
        .fold<double>(0, (sum, p) => sum + p.paymentAmount);
  }

  @override
  Future<List<Payment>> getPaymentsByDate(DateTime startDate, DateTime endDate) async {
    return _payments.values
        .where((p) =>
            p.paymentDate.isAfter(startDate) &&
            p.paymentDate.isBefore(endDate))
        .toList();
  }

  // Tax Calculation Methods
  @override
  Future<void> createTaxCalculation(TaxCalculation tax) async {
    _taxes[tax.taxId] = tax;
  }

  @override
  Future<TaxCalculation?> getTaxCalculation(String taxId) async {
    return _taxes[taxId];
  }

  @override
  Future<List<TaxCalculation>> getTaxCalculationsForEntity(
      String entityId) async {
    return _taxes.values.where((t) => t.entityId == entityId).toList();
  }

  @override
  Future<List<TaxCalculation>> getCurrentTaxCalculations() async {
    return _taxes.values.where((t) => t.isCurrent).toList();
  }

  @override
  Future<List<TaxCalculation>> getTaxCalculationsByYear(int year) async {
    return _taxes.values
        .where((t) => t.calculationDate.year == year)
        .toList();
  }

  @override
  Future<void> updateTaxCalculation(TaxCalculation tax) async {
    _taxes[tax.taxId] = tax;
  }

  @override
  Future<void> deleteTaxCalculation(String taxId) async {
    _taxes.remove(taxId);
  }

  @override
  Future<int> getTaxCalculationCount() async {
    return _taxes.length;
  }

  @override
  Future<double> getTotalTaxLiability() async {
    return _taxes.values.fold<double>(0, (sum, t) => sum + t.calculatedTax);
  }

  @override
  Future<double> getTotalAfterTaxIncome() async {
    return _taxes.values
        .fold<double>(0, (sum, t) => sum + t.afterTaxIncome);
  }

  // Financial Report Methods
  @override
  Future<void> createFinancialReport(FinancialReport report) async {
    _reports[report.reportId] = report;
  }

  @override
  Future<FinancialReport?> getFinancialReport(String reportId) async {
    return _reports[reportId];
  }

  @override
  Future<List<FinancialReport>> getReportsForEntity(String entityId) async {
    return _reports.values.where((r) => r.entityId == entityId).toList();
  }

  @override
  Future<List<FinancialReport>> getReportsByType(ReportType type) async {
    return _reports.values.where((r) => r.reportType == type).toList();
  }

  @override
  Future<List<FinancialReport>> getRecentReports(Duration duration) async {
    final threshold = DateTime.now().subtract(duration);
    return _reports.values
        .where((r) => r.reportDate.isAfter(threshold))
        .toList();
  }

  @override
  Future<void> updateFinancialReport(FinancialReport report) async {
    _reports[report.reportId] = report;
  }

  @override
  Future<void> deleteFinancialReport(String reportId) async {
    _reports.remove(reportId);
  }

  @override
  Future<int> getReportCount() async {
    return _reports.length;
  }

  @override
  Future<List<FinancialReport>> getHealthyReports() async {
    return _reports.values.where((r) => r.isHealthy).toList();
  }

  @override
  Future<FinancialReport?> getLatestReportForEntity(String entityId) async {
    final reports = _reports.values.where((r) => r.entityId == entityId).toList();
    if (reports.isEmpty) return null;
    reports.sort((a, b) => b.reportDate.compareTo(a.reportDate));
    return reports.first;
  }

  // Audit Trail Methods
  @override
  Future<void> createAuditTrail(AuditTrail audit) async {
    _audits[audit.auditId] = audit;
  }

  @override
  Future<AuditTrail?> getAuditTrail(String auditId) async {
    return _audits[auditId];
  }

  @override
  Future<List<AuditTrail>> getAuditTrailsForEntity(String entityId) async {
    return _audits.values.where((a) => a.entityId == entityId).toList();
  }

  @override
  Future<List<AuditTrail>> getCompletedAudits() async {
    return _audits.values.where((a) => a.isCompleted).toList();
  }

  @override
  Future<void> updateAuditTrail(AuditTrail audit) async {
    _audits[audit.auditId] = audit;
  }

  @override
  Future<void> deleteAuditTrail(String auditId) async {
    _audits.remove(auditId);
  }

  @override
  Future<int> getAuditCount() async {
    return _audits.length;
  }

  @override
  Future<List<AuditTrail>> getRecentAudits(Duration duration) async {
    final threshold = DateTime.now().subtract(duration);
    return _audits.values
        .where((a) => a.changedDate.isAfter(threshold))
        .toList();
  }

  // Cost Center Methods
  @override
  Future<void> createCostCenter(CostCenter center) async {
    _costCenters[center.costCenterId] = center;
  }

  @override
  Future<CostCenter?> getCostCenter(String costCenterId) async {
    return _costCenters[costCenterId];
  }

  @override
  Future<List<CostCenter>> getCostCentersByDepartment(
      String departmentId) async {
    return _costCenters.values
        .where((c) => c.departmentId == departmentId)
        .toList();
  }

  @override
  Future<List<CostCenter>> getActiveCostCenters() async {
    return _costCenters.values.where((c) => c.isActive).toList();
  }

  @override
  Future<List<CostCenter>> getOverBudgetCostCenters() async {
    return _costCenters.values.where((c) => c.isOverBudget).toList();
  }

  @override
  Future<void> updateCostCenter(CostCenter center) async {
    _costCenters[center.costCenterId] = center;
  }

  @override
  Future<void> deleteCostCenter(String costCenterId) async {
    _costCenters.remove(costCenterId);
  }

  @override
  Future<int> getCostCenterCount() async {
    return _costCenters.length;
  }

  @override
  Future<double> getTotalCostCenterBudget() async {
    return _costCenters.values
        .fold<double>(0, (sum, c) => sum + c.allocatedBudget);
  }

  @override
  Future<List<CostCenter>> getCostCentersByUtilization(double minRate) async {
    return _costCenters.values
        .where((c) => c.utilizationRate >= minRate)
        .toList();
  }
}

// ============================================================================
// Specialized Engines
// ============================================================================

class AccountingEngine {
  final FinancialRepository repository;

  AccountingEngine(this.repository);

  Future<List<ChartOfAccounts>> getAccountsNeedingReview() async {
    final allAccounts = await repository.getAllAccounts();
    return allAccounts
        .where((a) => a.ageInDays > 365)
        .toList();
  }

  Future<double> calculateTotalAssets() async {
    final assets = await repository.getAccountsByType(AccountType.asset);
    return assets.fold<double>(0, (sum, a) => sum + a.balance);
  }

  Future<double> calculateTotalLiabilities() async {
    final liabilities =
        await repository.getAccountsByType(AccountType.liability);
    return liabilities.fold<double>(0, (sum, l) => sum + l.balance);
  }

  Future<Map<AccountType, double>> getBalanceByAccountType() async {
    final allAccounts = await repository.getAllAccounts();
    final balances = <AccountType, double>{};

    for (final account in allAccounts) {
      balances[account.accountType] =
          (balances[account.accountType] ?? 0) + account.balance;
    }

    return balances;
  }
}

class BudgetMonitoringEngine {
  final FinancialRepository repository;

  BudgetMonitoringEngine(this.repository);

  Future<List<Budget>> getUnderfundedBudgets() async {
    final allBudgets = await repository.getAllBudgets();
    return allBudgets.where((b) => b.remaining < 0).toList();
  }

  Future<Map<BudgetStatus, int>> getBudgetStatusDistribution() async {
    final allBudgets = await repository.getAllBudgets();
    final distribution = <BudgetStatus, int>{};

    for (final budget in allBudgets) {
      distribution[budget.status] =
          (distribution[budget.status] ?? 0) + 1;
    }

    return distribution;
  }

  Future<double> getAverageBudgetUtilization() async {
    final allBudgets = await repository.getAllBudgets();
    if (allBudgets.isEmpty) return 0;
    final sum = allBudgets.fold<double>(0, (sum, b) => sum + b.spendPercent);
    return sum / allBudgets.length;
  }

  Future<void> flagOverBudgetBudgets() async {
    final overBudget = await repository.getOverBudgetBudgets();
    for (final budget in overBudget) {
      final updated = budget.copyWith(status: BudgetStatus.paused);
      await repository.updateBudget(updated);
    }
  }
}

class InvoiceManagementEngine {
  final FinancialRepository repository;

  InvoiceManagementEngine(this.repository);

  Future<List<Invoice>> getUnpaidInvoicesOverdue() async {
    return await repository.getOverdueInvoices();
  }

  Future<double> getOutstandingRevenue() async {
    final unpaid = await repository.getUnpaidInvoices();
    return unpaid.fold<double>(0, (sum, i) => sum + i.invoiceAmount);
  }

  Future<Map<InvoiceStatus, int>> getInvoiceStatusDistribution() async {
    final allInvoices = <Invoice>[];
    final statuses = <InvoiceStatus, int>{};

    for (final status in InvoiceStatus.values) {
      final invoices = await repository.getInvoicesByStatus(status);
      allInvoices.addAll(invoices);
      statuses[status] = invoices.length;
    }

    return statuses;
  }

  Future<void> sendReminderForOverdueInvoices() async {
    final overdue = await repository.getOverdueInvoices();
    for (final invoice in overdue) {
      // Record reminder interaction
      final updated = invoice.copyWith(
        notes: (invoice.notes ?? '') + '\nReminder sent',
      );
      await repository.updateInvoice(updated);
    }
  }
}

class ExpenseTrackingEngine {
  final FinancialRepository repository;

  ExpenseTrackingEngine(this.repository);

  Future<List<Expense>> getPendingExpenses() async {
    return await repository.getPendingApprovalExpenses();
  }

  Future<Map<ExpenseCategory, double>> getExpensesByCategory() async {
    final allExpenses = <Expense>[];
    final expenses = <ExpenseCategory, double>{};

    for (final category in ExpenseCategory.values) {
      final categoryExpenses = await repository.getExpensesByCategory(category);
      allExpenses.addAll(categoryExpenses);
      expenses[category] = categoryExpenses.fold<double>(
          0, (sum, e) => sum + e.amount);
    }

    return expenses;
  }

  Future<double> getAverageExpenseAmount() async {
    final count = await repository.getExpenseCount();
    if (count == 0) return 0;
    final total = await repository.getTotalExpenseAmount();
    return total / count;
  }

  Future<void> approveExpenses(List<String> expenseIds) async {
    for (final expenseId in expenseIds) {
      final expense = await repository.getExpense(expenseId);
      if (expense != null) {
        final updated = expense.copyWith(isApproved: true);
        await repository.updateExpense(updated);
      }
    }
  }
}

class TaxPlankEngine {
  final FinancialRepository repository;

  TaxPlankEngine(this.repository);

  Future<double> getTotalTaxLiability() async {
    return await repository.getTotalTaxLiability();
  }

  Future<List<TaxCalculation>> getTaxLiabilitiesDueThisYear() async {
    final currentYear = DateTime.now().year;
    return await repository.getTaxCalculationsByYear(currentYear);
  }

  Future<double> getAverageEffectiveTaxRate() async {
    final taxes = await repository.getCurrentTaxCalculations();
    if (taxes.isEmpty) return 0;
    final sum = taxes.fold<double>(0, (sum, t) => sum + t.effectiveTaxRate);
    return sum / taxes.length;
  }

  Future<Map<String, double>> getTaxPlanning() async {
    return {
      'totalLiability': await repository.getTotalTaxLiability(),
      'totalAfterTaxIncome': await repository.getTotalAfterTaxIncome(),
      'count': (await repository.getTaxCalculationCount()).toDouble(),
    };
  }
}

// ============================================================================
// Manager
// ============================================================================

class FinancialManager {
  final FinancialRepository repository;
  late final AccountingEngine accountingEngine;
  late final BudgetMonitoringEngine budgetEngine;
  late final InvoiceManagementEngine invoiceEngine;
  late final ExpenseTrackingEngine expenseEngine;
  late final TaxPlankEngine taxEngine;

  FinancialManager(this.repository) {
    accountingEngine = AccountingEngine(repository);
    budgetEngine = BudgetMonitoringEngine(repository);
    invoiceEngine = InvoiceManagementEngine(repository);
    expenseEngine = ExpenseTrackingEngine(repository);
    taxEngine = TaxPlankEngine(repository);
  }

  Future<Map<String, dynamic>> generateFinancialDashboard() async {
    return {
      'totalAssets': await accountingEngine.calculateTotalAssets(),
      'totalLiabilities': await accountingEngine.calculateTotalLiabilities(),
      'outstandingRevenue': await invoiceEngine.getOutstandingRevenue(),
      'budgetUtilization': await budgetEngine.getAverageBudgetUtilization(),
      'totalTaxLiability': await taxEngine.getTotalTaxLiability(),
      'totalExpenses': await repository.getTotalExpenseAmount(),
    };
  }
}

// ============================================================================
// Facade
// ============================================================================

class FinancialFacade {
  final FinancialManager manager;

  FinancialFacade(FinancialRepository repository)
      : manager = FinancialManager(repository);

  // Chart of Accounts
  Future<void> addAccount(ChartOfAccounts account) =>
      manager.repository.createChartOfAccount(account);

  Future<ChartOfAccounts?> getAccount(String accountId) =>
      manager.repository.getChartOfAccount(accountId);

  Future<List<ChartOfAccounts>> getAllAccounts() =>
      manager.repository.getAllAccounts();

  // Budget Management
  Future<void> createBudget(Budget budget) =>
      manager.repository.createBudget(budget);

  Future<List<Budget>> getActiveBudgets() =>
      manager.repository.getActiveBudgets();

  Future<List<Budget>> getOverBudgetItems() =>
      manager.repository.getOverBudgetBudgets();

  // Invoice & Payment
  Future<void> createInvoice(Invoice invoice) =>
      manager.repository.createInvoice(invoice);

  Future<List<Invoice>> getOverdueInvoices() =>
      manager.repository.getOverdueInvoices();

  Future<double> getOutstandingRevenue() =>
      manager.invoiceEngine.getOutstandingRevenue();

  // Expense Management
  Future<void> submitExpense(Expense expense) =>
      manager.repository.createExpense(expense);

  Future<List<Expense>> getPendingExpenses() =>
      manager.expenseEngine.getPendingExpenses();

  Future<Map<ExpenseCategory, double>> getExpenseBreakdown() =>
      manager.expenseEngine.getExpensesByCategory();

  // Financial Reporting
  Future<void> createReport(FinancialReport report) =>
      manager.repository.createFinancialReport(report);

  Future<List<FinancialReport>> getHealthyReports() =>
      manager.repository.getHealthyReports();

  // Tax Planning
  Future<double> getTaxLiability() =>
      manager.taxEngine.getTotalTaxLiability();

  // Overall Dashboard
  Future<Map<String, dynamic>> getFinancialDashboard() =>
      manager.generateFinancialDashboard();
}
