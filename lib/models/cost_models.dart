/// Cost & Billing Management Models

enum CostType { compute, storage, network, database, service, license, support, other }
enum BillingCycle { hourly, daily, weekly, monthly, yearly, custom }
enum InvoiceStatus { draft, sent, paid, overdue, cancelled }
enum ChargeType { fixed, variable, tiered, usage_based }
enum CurrencyCode { usd, eur, gbp, jpy, aud, cad, custom }
enum PaymentStatus { pending, completed, failed, refunded, disputed }

class CostAllocation {
  final String allocationId;
  final String resourceId;
  final String projectId;
  final CostType costType;
  final double amount;
  final CurrencyCode currency;
  final DateTime allocatedAt;
  final DateTime? billedAt;
  final Map<String, dynamic> tags;

  CostAllocation({
    required this.allocationId,
    required this.resourceId,
    required this.projectId,
    required this.costType,
    required this.amount,
    required this.currency,
    required this.allocatedAt,
    this.billedAt,
    this.tags = const {},
  });

  bool get isBilled => billedAt != null;
  int get ageInDays => DateTime.now().difference(allocatedAt).inDays;
  bool get isRecent => ageInDays < 30;
}

class BillingPeriod {
  final String periodId;
  final String billingAccountId;
  final DateTime startDate;
  final DateTime endDate;
  final BillingCycle billingCycle;
  final List<String> costAllocationIds;
  final double totalAmount;
  final CurrencyCode currency;
  final bool isClosed;

  BillingPeriod({
    required this.periodId,
    required this.billingAccountId,
    required this.startDate,
    required this.endDate,
    required this.billingCycle,
    required this.costAllocationIds,
    required this.totalAmount,
    required this.currency,
    required this.isClosed,
  });

  bool get hasAllocations => costAllocationIds.isNotEmpty;
  int get allocationCount => costAllocationIds.length;
  int get durationInDays => endDate.difference(startDate).inDays;
  bool get isOverdue => DateTime.now().isAfter(endDate.add(Duration(days: 30)));
}

class Invoice {
  final String invoiceId;
  final String billingAccountId;
  final String billingPeriodId;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final double totalAmount;
  final double? paidAmount;
  final CurrencyCode currency;
  final InvoiceStatus status;
  final String? invoiceNumber;
  final Map<String, double> lineItems;

  Invoice({
    required this.invoiceId,
    required this.billingAccountId,
    required this.billingPeriodId,
    required this.invoiceDate,
    required this.dueDate,
    required this.totalAmount,
    this.paidAmount,
    required this.currency,
    required this.status,
    this.invoiceNumber,
    required this.lineItems,
  });

  bool get isPaid => status == InvoiceStatus.paid;
  bool get isOverdue => DateTime.now().isAfter(dueDate) && !isPaid;
  double get remainingAmount => totalAmount - (paidAmount ?? 0);
  double get paidPercentage => paidAmount != null ? (paidAmount! / totalAmount * 100) : 0.0;
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
}

class RateCard {
  final String rateCardId;
  final CostType costType;
  final ChargeType chargeType;
  final double baseRate;
  final String unit;
  final CurrencyCode currency;
  final DateTime effectiveDate;
  final DateTime? expiryDate;
  final Map<String, double>? tierPricing;
  final String? description;

  RateCard({
    required this.rateCardId,
    required this.costType,
    required this.chargeType,
    required this.baseRate,
    required this.unit,
    required this.currency,
    required this.effectiveDate,
    this.expiryDate,
    this.tierPricing,
    this.description,
  });

  bool get isActive => DateTime.now().isAfter(effectiveDate) && (expiryDate == null || DateTime.now().isBefore(expiryDate!));
  bool get hasTiering => tierPricing != null && tierPricing!.isNotEmpty;
  int get ageInDays => DateTime.now().difference(effectiveDate).inDays;
}

class CostMetric {
  final String metricId;
  final String resourceId;
  final CostType costType;
  final double usageQuantity;
  final String usageUnit;
  final double unitRate;
  final double calculatedCost;
  final CurrencyCode currency;
  final DateTime recordedAt;
  final String? billableReference;

  CostMetric({
    required this.metricId,
    required this.resourceId,
    required this.costType,
    required this.usageQuantity,
    required this.usageUnit,
    required this.unitRate,
    required this.calculatedCost,
    required this.currency,
    required this.recordedAt,
    this.billableReference,
  });

  bool get isBillable => billableReference != null;
  int get ageInHours => DateTime.now().difference(recordedAt).inHours;
  double get costPerUnit => usageQuantity > 0 ? calculatedCost / usageQuantity : 0.0;
}

class BillingAccount {
  final String accountId;
  final String organizationId;
  final String accountName;
  final String primaryContact;
  final String? secondaryContact;
  final BillingCycle billingCycle;
  final DateTime createdAt;
  final DateTime? suspendedAt;
  final bool isActive;

  BillingAccount({
    required this.accountId,
    required this.organizationId,
    required this.accountName,
    required this.primaryContact,
    this.secondaryContact,
    required this.billingCycle,
    required this.createdAt,
    this.suspendedAt,
    required this.isActive,
  });

  bool get isSuspended => suspendedAt != null;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  bool get hasSecondaryContact => secondaryContact != null;
}

class BudgetAllocation {
  final String budgetId;
  final String projectId;
  final String budgetName;
  final double budgetLimit;
  final CurrencyCode currency;
  final DateTime startDate;
  final DateTime endDate;
  final double currentSpending;
  final List<String> costTypeRestrictions;

  BudgetAllocation({
    required this.budgetId,
    required this.projectId,
    required this.budgetName,
    required this.budgetLimit,
    required this.currency,
    required this.startDate,
    required this.endDate,
    required this.currentSpending,
    required this.costTypeRestrictions,
  });

  bool get isExceeded => currentSpending > budgetLimit;
  double get remainingBudget => budgetLimit - currentSpending;
  double get utilizationPercentage => (currentSpending / budgetLimit * 100);
  bool get isWarning => utilizationPercentage > 80 && utilizationPercentage <= 100;
  bool get isCritical => utilizationPercentage > 100;
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
}

class CostForecast {
  final String forecastId;
  final String resourceId;
  final CostType costType;
  final DateTime forecastDate;
  final double projectedCost;
  final double lowerBound;
  final double upperBound;
  final double confidence;
  final int dataPointsUsed;
  final String? forecastMethod;

  CostForecast({
    required this.forecastId,
    required this.resourceId,
    required this.costType,
    required this.forecastDate,
    required this.projectedCost,
    required this.lowerBound,
    required this.upperBound,
    required this.confidence,
    required this.dataPointsUsed,
    this.forecastMethod,
  });

  bool get isHighConfidence => confidence > 0.9;
  double get forecastRange => upperBound - lowerBound;
  bool get isRecent => DateTime.now().difference(forecastDate).inDays < 7;
}

class Payment {
  final String paymentId;
  final String invoiceId;
  final double amount;
  final CurrencyCode currency;
  final PaymentStatus status;
  final DateTime paymentDate;
  final String paymentMethod;
  final String? transactionReference;
  final String? notes;

  Payment({
    required this.paymentId,
    required this.invoiceId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentDate,
    required this.paymentMethod,
    this.transactionReference,
    this.notes,
  });

  bool get isSuccessful => status == PaymentStatus.completed;
  bool get isFailed => status == PaymentStatus.failed;
  int get ageInDays => DateTime.now().difference(paymentDate).inDays;
  bool get isRecent => ageInDays < 30;
}

class CostOptimization {
  final String optimizationId;
  final String resourceId;
  final String title;
  final String description;
  final double potentialSavings;
  final CurrencyCode currency;
  final DateTime discoveredAt;
  final DateTime? implementedAt;
  final double? actualSavings;
  final String? recommendation;

  CostOptimization({
    required this.optimizationId,
    required this.resourceId,
    required this.title,
    required this.description,
    required this.potentialSavings,
    required this.currency,
    required this.discoveredAt,
    this.implementedAt,
    this.actualSavings,
    this.recommendation,
  });

  bool get isImplemented => implementedAt != null;
  bool get isPending => !isImplemented;
  int get ageInDays => DateTime.now().difference(discoveredAt).inDays;
  double get savingsRealizationRate => isImplemented && actualSavings != null ? (actualSavings! / potentialSavings * 100) : 0.0;
}
