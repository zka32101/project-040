/// Advanced Financial Management & Accounting Models
/// Comprehensive financial planning, budgeting, expense tracking, and reporting

// ============================================================================
// Enums (7 total)
// ============================================================================

enum AccountType {
  asset,
  liability,
  equity,
  revenue,
  expense,
  costOfRevenue,
  operatingExpense;

  String get displayName {
    switch (this) {
      case AccountType.asset:
        return 'Asset (資産)';
      case AccountType.liability:
        return 'Liability (負債)';
      case AccountType.equity:
        return 'Equity (資本)';
      case AccountType.revenue:
        return 'Revenue (収益)';
      case AccountType.expense:
        return 'Expense (費用)';
      case AccountType.costOfRevenue:
        return 'Cost of Revenue (売上原価)';
      case AccountType.operatingExpense:
        return 'Operating Expense (営業費)';
    }
  }
}

enum ExpenseCategory {
  salaries,
  marketing,
  operations,
  technology,
  facilities,
  professional,
  travel,
  other;

  String get displayName {
    switch (this) {
      case ExpenseCategory.salaries:
        return 'Salaries & Compensation (給与)';
      case ExpenseCategory.marketing:
        return 'Marketing & Advertising (マーケティング)';
      case ExpenseCategory.operations:
        return 'Operations (運営)';
      case ExpenseCategory.technology:
        return 'Technology & Infrastructure (技術)';
      case ExpenseCategory.facilities:
        return 'Facilities & Real Estate (施設)';
      case ExpenseCategory.professional:
        return 'Professional Services (専門サービス)';
      case ExpenseCategory.travel:
        return 'Travel & Transportation (旅行)';
      case ExpenseCategory.other:
        return 'Other Expenses (その他)';
    }
  }
}

enum BudgetStatus {
  planning,
  approved,
  active,
  paused,
  completed,
  archived;

  String get displayName {
    switch (this) {
      case BudgetStatus.planning:
        return 'Planning (計画中)';
      case BudgetStatus.approved:
        return 'Approved (承認済)';
      case BudgetStatus.active:
        return 'Active (実行中)';
      case BudgetStatus.paused:
        return 'Paused (一時停止)';
      case BudgetStatus.completed:
        return 'Completed (完了)';
      case BudgetStatus.archived:
        return 'Archived (アーカイブ)';
    }
  }
}

enum InvoiceStatus {
  draft,
  sent,
  viewed,
  paid,
  overdue,
  cancelled;

  String get displayName {
    switch (this) {
      case InvoiceStatus.draft:
        return 'Draft (下書き)';
      case InvoiceStatus.sent:
        return 'Sent (送信)';
      case InvoiceStatus.viewed:
        return 'Viewed (閲覧)';
      case InvoiceStatus.paid:
        return 'Paid (支払済)';
      case InvoiceStatus.overdue:
        return 'Overdue (期限切れ)';
      case InvoiceStatus.cancelled:
        return 'Cancelled (キャンセル)';
    }
  }
}

enum PaymentMethod {
  credit,
  debit,
  bankTransfer,
  check,
  cash,
  crypto;

  String get displayName {
    switch (this) {
      case PaymentMethod.credit:
        return 'Credit Card (クレジット)';
      case PaymentMethod.debit:
        return 'Debit Card (デビット)';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer (銀行振込)';
      case PaymentMethod.check:
        return 'Check (小切手)';
      case PaymentMethod.cash:
        return 'Cash (現金)';
      case PaymentMethod.crypto:
        return 'Cryptocurrency (暗号資産)';
    }
  }
}

enum ReportType {
  incomeStatement,
  balanceSheet,
  cashFlow,
  budgetVsActual,
  profitLoss,
  trialBalance,
  generalLedger;

  String get displayName {
    switch (this) {
      case ReportType.incomeStatement:
        return 'Income Statement (損益計算書)';
      case ReportType.balanceSheet:
        return 'Balance Sheet (貸借対照表)';
      case ReportType.cashFlow:
        return 'Cash Flow (キャッシュフロー)';
      case ReportType.budgetVsActual:
        return 'Budget vs Actual (予算実績)';
      case ReportType.profitLoss:
        return 'Profit & Loss (P&L)';
      case ReportType.trialBalance:
        return 'Trial Balance (試算表)';
      case ReportType.generalLedger:
        return 'General Ledger (総勘定元帳)';
    }
  }
}

enum AuditStatus {
  notStarted,
  inProgress,
  completed,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case AuditStatus.notStarted:
        return 'Not Started (未開始)';
      case AuditStatus.inProgress:
        return 'In Progress (進行中)';
      case AuditStatus.completed:
        return 'Completed (完了)';
      case AuditStatus.approved:
        return 'Approved (承認済)';
      case AuditStatus.rejected:
        return 'Rejected (却下)';
    }
  }
}

// ============================================================================
// Model Classes (10 total)
// ============================================================================

class ChartOfAccounts {
  final String accountId;
  final String accountNumber;
  final String accountName;
  final AccountType accountType;
  final double balance;
  final String? description;
  final DateTime createdDate;

  const ChartOfAccounts({
    required this.accountId,
    required this.accountNumber,
    required this.accountName,
    required this.accountType,
    required this.balance,
    this.description,
    required this.createdDate,
  });

  bool get isActive => balance != 0;
  bool get isAsset => accountType == AccountType.asset;
  bool get isLiability => accountType == AccountType.liability;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;

  ChartOfAccounts copyWith({
    String? accountId,
    String? accountNumber,
    String? accountName,
    AccountType? accountType,
    double? balance,
    String? description,
    DateTime? createdDate,
  }) {
    return ChartOfAccounts(
      accountId: accountId ?? this.accountId,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      accountType: accountType ?? this.accountType,
      balance: balance ?? this.balance,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}

class GeneralLedgerEntry {
  final String entryId;
  final String journalEntryId;
  final String accountId;
  final double debitAmount;
  final double creditAmount;
  final String description;
  final DateTime entryDate;

  const GeneralLedgerEntry({
    required this.entryId,
    required this.journalEntryId,
    required this.accountId,
    required this.debitAmount,
    required this.creditAmount,
    required this.description,
    required this.entryDate,
  });

  bool get hasDebit => debitAmount > 0;
  bool get hasCredit => creditAmount > 0;
  double get netAmount => debitAmount - creditAmount;
  int get ageInDays => DateTime.now().difference(entryDate).inDays;

  GeneralLedgerEntry copyWith({
    String? entryId,
    String? journalEntryId,
    String? accountId,
    double? debitAmount,
    double? creditAmount,
    String? description,
    DateTime? entryDate,
  }) {
    return GeneralLedgerEntry(
      entryId: entryId ?? this.entryId,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      accountId: accountId ?? this.accountId,
      debitAmount: debitAmount ?? this.debitAmount,
      creditAmount: creditAmount ?? this.creditAmount,
      description: description ?? this.description,
      entryDate: entryDate ?? this.entryDate,
    );
  }
}

class Budget {
  final String budgetId;
  final String departmentId;
  final String budgetName;
  final double budgetAmount;
  final double spentAmount;
  final BudgetStatus status;
  final DateTime startDate;
  final DateTime endDate;

  const Budget({
    required this.budgetId,
    required this.departmentId,
    required this.budgetName,
    required this.budgetAmount,
    required this.spentAmount,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  bool get isActive => status == BudgetStatus.active;
  bool get isOverBudget => spentAmount > budgetAmount;
  double get remaining => budgetAmount - spentAmount;
  double get spendPercent => (spentAmount / budgetAmount) * 100;
  bool get isExpired => DateTime.now().isAfter(endDate);
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  Budget copyWith({
    String? budgetId,
    String? departmentId,
    String? budgetName,
    double? budgetAmount,
    double? spentAmount,
    BudgetStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Budget(
      budgetId: budgetId ?? this.budgetId,
      departmentId: departmentId ?? this.departmentId,
      budgetName: budgetName ?? this.budgetName,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class Expense {
  final String expenseId;
  final String employeeId;
  final String description;
  final double amount;
  final ExpenseCategory category;
  final DateTime expenseDate;
  final String? receiptUrl;
  final bool isApproved;

  const Expense({
    required this.expenseId,
    required this.employeeId,
    required this.description,
    required this.amount,
    required this.category,
    required this.expenseDate,
    this.receiptUrl,
    this.isApproved = false,
  });

  bool get isRecent => DateTime.now().difference(expenseDate).inDays < 30;
  bool get hasReceipt => receiptUrl != null;
  int get ageInDays => DateTime.now().difference(expenseDate).inDays;
  bool get isPending => !isApproved;

  Expense copyWith({
    String? expenseId,
    String? employeeId,
    String? description,
    double? amount,
    ExpenseCategory? category,
    DateTime? expenseDate,
    String? receiptUrl,
    bool? isApproved,
  }) {
    return Expense(
      expenseId: expenseId ?? this.expenseId,
      employeeId: employeeId ?? this.employeeId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      expenseDate: expenseDate ?? this.expenseDate,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}

class Invoice {
  final String invoiceId;
  final String clientId;
  final double invoiceAmount;
  final InvoiceStatus status;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final String? notes;

  const Invoice({
    required this.invoiceId,
    required this.clientId,
    required this.invoiceAmount,
    required this.status,
    required this.invoiceDate,
    required this.dueDate,
    this.notes,
  });

  bool get isPaid => status == InvoiceStatus.paid;
  bool get isOverdue =>
      status != InvoiceStatus.paid && DateTime.now().isAfter(dueDate);
  bool get isRecent => DateTime.now().difference(invoiceDate).inDays < 30;
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
  int get ageInDays => DateTime.now().difference(invoiceDate).inDays;

  Invoice copyWith({
    String? invoiceId,
    String? clientId,
    double? invoiceAmount,
    InvoiceStatus? status,
    DateTime? invoiceDate,
    DateTime? dueDate,
    String? notes,
  }) {
    return Invoice(
      invoiceId: invoiceId ?? this.invoiceId,
      clientId: clientId ?? this.clientId,
      invoiceAmount: invoiceAmount ?? this.invoiceAmount,
      status: status ?? this.status,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
    );
  }
}

class Payment {
  final String paymentId;
  final String invoiceId;
  final double paymentAmount;
  final PaymentMethod paymentMethod;
  final DateTime paymentDate;
  final String? reference;

  const Payment({
    required this.paymentId,
    required this.invoiceId,
    required this.paymentAmount,
    required this.paymentMethod,
    required this.paymentDate,
    this.reference,
  });

  bool get isRecent => DateTime.now().difference(paymentDate).inDays < 7;
  int get ageInDays => DateTime.now().difference(paymentDate).inDays;
  bool get hasBankRecord => paymentMethod == PaymentMethod.bankTransfer;

  Payment copyWith({
    String? paymentId,
    String? invoiceId,
    double? paymentAmount,
    PaymentMethod? paymentMethod,
    DateTime? paymentDate,
    String? reference,
  }) {
    return Payment(
      paymentId: paymentId ?? this.paymentId,
      invoiceId: invoiceId ?? this.invoiceId,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      reference: reference ?? this.reference,
    );
  }
}

class TaxCalculation {
  final String taxId;
  final String entityId;
  final double taxableIncome;
  final double taxRate;
  final double calculatedTax;
  final DateTime calculationDate;
  final String? notes;

  const TaxCalculation({
    required this.taxId,
    required this.entityId,
    required this.taxableIncome,
    required this.taxRate,
    required this.calculatedTax,
    required this.calculationDate,
    this.notes,
  });

  bool get isCurrent => DateTime.now().difference(calculationDate).inDays < 365;
  double get effectiveTaxRate => (calculatedTax / taxableIncome) * 100;
  int get ageInDays => DateTime.now().difference(calculationDate).inDays;
  double get afterTaxIncome => taxableIncome - calculatedTax;

  TaxCalculation copyWith({
    String? taxId,
    String? entityId,
    double? taxableIncome,
    double? taxRate,
    double? calculatedTax,
    DateTime? calculationDate,
    String? notes,
  }) {
    return TaxCalculation(
      taxId: taxId ?? this.taxId,
      entityId: entityId ?? this.entityId,
      taxableIncome: taxableIncome ?? this.taxableIncome,
      taxRate: taxRate ?? this.taxRate,
      calculatedTax: calculatedTax ?? this.calculatedTax,
      calculationDate: calculationDate ?? this.calculationDate,
      notes: notes ?? this.notes,
    );
  }
}

class FinancialReport {
  final String reportId;
  final String entityId;
  final ReportType reportType;
  final DateTime reportDate;
  final double totalAssets;
  final double totalLiabilities;
  final double netIncome;
  final String? summary;

  const FinancialReport({
    required this.reportId,
    required this.entityId,
    required this.reportType,
    required this.reportDate,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netIncome,
    this.summary,
  });

  bool get isHealthy => netIncome > 0 && totalAssets > totalLiabilities;
  double get equity => totalAssets - totalLiabilities;
  double get debtToAssetRatio => (totalLiabilities / totalAssets);
  int get ageInDays => DateTime.now().difference(reportDate).inDays;
  bool get isRecent => ageInDays < 30;

  String toMarkdown() {
    return '''# Financial Report
- Type: ${reportType.displayName}
- Date: ${reportDate.toString()}
- Total Assets: \$${totalAssets.toStringAsFixed(2)}
- Total Liabilities: \$${totalLiabilities.toStringAsFixed(2)}
- Net Income: \$${netIncome.toStringAsFixed(2)}
- Equity: \$${equity.toStringAsFixed(2)}
- Health: ${isHealthy ? 'Healthy ✅' : 'Concerning ⚠️'}
''';
  }

  FinancialReport copyWith({
    String? reportId,
    String? entityId,
    ReportType? reportType,
    DateTime? reportDate,
    double? totalAssets,
    double? totalLiabilities,
    double? netIncome,
    String? summary,
  }) {
    return FinancialReport(
      reportId: reportId ?? this.reportId,
      entityId: entityId ?? this.entityId,
      reportType: reportType ?? this.reportType,
      reportDate: reportDate ?? this.reportDate,
      totalAssets: totalAssets ?? this.totalAssets,
      totalLiabilities: totalLiabilities ?? this.totalLiabilities,
      netIncome: netIncome ?? this.netIncome,
      summary: summary ?? this.summary,
    );
  }
}

class AuditTrail {
  final String auditId;
  final String entityId;
  final String changedBy;
  final String description;
  final DateTime changedDate;
  final AuditStatus auditStatus;
  final String? findings;

  const AuditTrail({
    required this.auditId,
    required this.entityId,
    required this.changedBy,
    required this.description,
    required this.changedDate,
    required this.auditStatus,
    this.findings,
  });

  bool get isCompleted =>
      auditStatus == AuditStatus.completed ||
      auditStatus == AuditStatus.approved;
  bool get isApproved => auditStatus == AuditStatus.approved;
  int get ageInDays => DateTime.now().difference(changedDate).inDays;
  bool get hasFinding => findings != null && findings!.isNotEmpty;

  AuditTrail copyWith({
    String? auditId,
    String? entityId,
    String? changedBy,
    String? description,
    DateTime? changedDate,
    AuditStatus? auditStatus,
    String? findings,
  }) {
    return AuditTrail(
      auditId: auditId ?? this.auditId,
      entityId: entityId ?? this.entityId,
      changedBy: changedBy ?? this.changedBy,
      description: description ?? this.description,
      changedDate: changedDate ?? this.changedDate,
      auditStatus: auditStatus ?? this.auditStatus,
      findings: findings ?? this.findings,
    );
  }
}

class CostCenter {
  final String costCenterId;
  final String costCenterName;
  final String departmentId;
  final double allocatedBudget;
  final double spentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final String? manager;

  const CostCenter({
    required this.costCenterId,
    required this.costCenterName,
    required this.departmentId,
    required this.allocatedBudget,
    required this.spentAmount,
    required this.startDate,
    required this.endDate,
    this.manager,
  });

  bool get isActive => DateTime.now().isBefore(endDate);
  bool get isOverBudget => spentAmount > allocatedBudget;
  double get remaining => allocatedBudget - spentAmount;
  double get utilizationRate => (spentAmount / allocatedBudget) * 100;
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  CostCenter copyWith({
    String? costCenterId,
    String? costCenterName,
    String? departmentId,
    double? allocatedBudget,
    double? spentAmount,
    DateTime? startDate,
    DateTime? endDate,
    String? manager,
  }) {
    return CostCenter(
      costCenterId: costCenterId ?? this.costCenterId,
      costCenterName: costCenterName ?? this.costCenterName,
      departmentId: departmentId ?? this.departmentId,
      allocatedBudget: allocatedBudget ?? this.allocatedBudget,
      spentAmount: spentAmount ?? this.spentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      manager: manager ?? this.manager,
    );
  }
}
