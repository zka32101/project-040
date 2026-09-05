// Phase 82: Cost Optimization & Resource Management System
// Models for comprehensive cost tracking and optimization

enum CostCategory {
  compute,
  storage,
  network,
  database,
  licensing,
  support,
  infrastructure,
  thirdparty,
}

enum CostTrendDirection {
  increasing,
  decreasing,
  stable,
  volatile,
}

enum OptimizationSeverity {
  critical,
  high,
  medium,
  low,
}

enum AllocationStrategy {
  fairShare,
  weighted,
  demandBased,
  reserved,
  spot,
}

enum ReservationStatus {
  active,
  expiring,
  expired,
  cancelled,
}

enum ForecastConfidence {
  veryHigh,
  high,
  medium,
  low,
}

class CostRecord {
  final String id;
  final String resourceId;
  final CostCategory category;
  final double amount;
  final DateTime recordedAt;
  final String currency;
  final String? description;

  CostRecord({
    required this.id,
    required this.resourceId,
    required this.category,
    required this.amount,
    required this.recordedAt,
    required this.currency,
    this.description,
  });

  double get taxAmount => amount * 0.1;
  double get totalWithTax => amount + taxAmount;
  bool get isRecent => DateTime.now().difference(recordedAt).inDays < 7;
}

class BudgetAllocation {
  final String id;
  final String projectId;
  final CostCategory category;
  final double allocatedAmount;
  final double spentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final AllocationStrategy strategy;

  BudgetAllocation({
    required this.id,
    required this.projectId,
    required this.category,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.startDate,
    required this.endDate,
    required this.strategy,
  });

  double get remainingBudget => allocatedAmount - spentAmount;
  double get utilizationPercentage => (spentAmount / allocatedAmount) * 100;
  bool get isOverBudget => spentAmount > allocatedAmount;
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
}

class ResourceUtilization {
  final String id;
  final String resourceId;
  final double cpuUtilization;
  final double memoryUtilization;
  final double storageUtilization;
  final double networkUtilization;
  final DateTime measuredAt;

  ResourceUtilization({
    required this.id,
    required this.resourceId,
    required this.cpuUtilization,
    required this.memoryUtilization,
    required this.storageUtilization,
    required this.networkUtilization,
    required this.measuredAt,
  });

  double get averageUtilization =>
      (cpuUtilization + memoryUtilization + storageUtilization + networkUtilization) / 4;
  bool get isUnderutilized => averageUtilization < 20;
  bool get isWellUtilized => averageUtilization >= 60 && averageUtilization <= 80;
  bool get isOverutilized => averageUtilization > 85;
}

class OptimizationOpportunity {
  final String id;
  final String resourceId;
  final OptimizationSeverity severity;
  final String title;
  final String description;
  final double potentialSavings;
  final DateTime discoveredAt;
  final String? recommendation;

  OptimizationOpportunity({
    required this.id,
    required this.resourceId,
    required this.severity,
    required this.title,
    required this.description,
    required this.potentialSavings,
    required this.discoveredAt,
    this.recommendation,
  });

  bool get isSignificant => potentialSavings > 1000;
  bool get isRecent => DateTime.now().difference(discoveredAt).inDays < 30;
  int get ageInDays => DateTime.now().difference(discoveredAt).inDays;
}

class CostForecast {
  final String id;
  final String projectId;
  final DateTime forecastDate;
  final double predictedCost;
  final ForecastConfidence confidence;
  final List<double> historicalData;
  final String? method;

  CostForecast({
    required this.id,
    required this.projectId,
    required this.forecastDate,
    required this.predictedCost,
    required this.confidence,
    required this.historicalData,
    this.method,
  });

  double get averageHistoricalCost =>
      historicalData.isEmpty ? 0 : historicalData.reduce((a, b) => a + b) / historicalData.length;
  double get variance => historicalData.isEmpty
      ? 0
      : historicalData.map((x) => (x - averageHistoricalCost) * (x - averageHistoricalCost)).reduce((a, b) => a + b) /
          historicalData.length;
  double get confidenceScore {
    switch (confidence) {
      case ForecastConfidence.veryHigh:
        return 0.95;
      case ForecastConfidence.high:
        return 0.80;
      case ForecastConfidence.medium:
        return 0.60;
      case ForecastConfidence.low:
        return 0.40;
    }
  }
}

class ReservedInstance {
  final String id;
  final String resourceType;
  final int quantity;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final double discountPercentage;
  final ReservationStatus status;

  ReservedInstance({
    required this.id,
    required this.resourceType,
    required this.quantity,
    required this.purchaseDate,
    required this.expiryDate,
    required this.discountPercentage,
    required this.status,
  });

  bool get isExpiring => DateTime.now().difference(expiryDate).inDays > -30 && DateTime.now().isBefore(expiryDate);
  bool get isExpired => DateTime.now().isAfter(expiryDate);
  int get remainingDays => expiryDate.difference(DateTime.now()).inDays;
  double get monthlyDiscountAmount => (quantity * 1000) * (discountPercentage / 100);
}

class CostTrend {
  final String id;
  final String projectId;
  final CostCategory category;
  final List<double> values;
  final CostTrendDirection direction;
  final double changePercentage;
  final DateTime analyzedAt;

  CostTrend({
    required this.id,
    required this.projectId,
    required this.category,
    required this.values,
    required this.direction,
    required this.changePercentage,
    required this.analyzedAt,
  });

  double get currentValue => values.isNotEmpty ? values.last : 0;
  double get previousValue => values.length > 1 ? values[values.length - 2] : 0;
  double get averageValue => values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
  bool get isAccelerating => changePercentage > 5;
}

class CostAnomaly {
  final String id;
  final String resourceId;
  final double anomalyValue;
  final double expectedValue;
  final String description;
  final DateTime detectedAt;
  final OptimizationSeverity severity;

  CostAnomaly({
    required this.id,
    required this.resourceId,
    required this.anomalyValue,
    required this.expectedValue,
    required this.description,
    required this.detectedAt,
    required this.severity,
  });

  double get deviation => ((anomalyValue - expectedValue) / expectedValue) * 100;
  bool get isSignificantDeviation => deviation.abs() > 20;
  int get hoursSinceDetection => DateTime.now().difference(detectedAt).inHours;
}

class CostOptimizationReport {
  final String id;
  final String projectId;
  final DateTime generatedAt;
  final double totalSpend;
  final double potentialSavings;
  final int opportunityCount;
  final double savingsPercentage;

  CostOptimizationReport({
    required this.id,
    required this.projectId,
    required this.generatedAt,
    required this.totalSpend,
    required this.potentialSavings,
    required this.opportunityCount,
    required this.savingsPercentage,
  });

  bool get hasSavingsOpportunities => potentialSavings > 0;
  double get projectedAnnualSavings => potentialSavings * 12;
  bool get isSignificant => savingsPercentage > 5;
}

class ResourceAllocation {
  final String id;
  final String projectId;
  final String resourceType;
  final double allocatedCapacity;
  final double usedCapacity;
  final AllocationStrategy strategy;
  final DateTime allocationDate;

  ResourceAllocation({
    required this.id,
    required this.projectId,
    required this.resourceType,
    required this.allocatedCapacity,
    required this.usedCapacity,
    required this.strategy,
    required this.allocationDate,
  });

  double get utilizationPercentage => (usedCapacity / allocatedCapacity) * 100;
  double get wastedCapacity => allocatedCapacity - usedCapacity;
  bool get isUnderutilized => utilizationPercentage < 30;
  bool get isOptimal => utilizationPercentage >= 70 && utilizationPercentage <= 90;
}

class CostAlert {
  final String id;
  final String projectId;
  final String message;
  final OptimizationSeverity severity;
  final DateTime createdAt;
  final bool isAcknowledged;
  final String? resolution;

  CostAlert({
    required this.id,
    required this.projectId,
    required this.message,
    required this.severity,
    required this.createdAt,
    required this.isAcknowledged,
    this.resolution,
  });

  bool get isActive => !isAcknowledged;
  int get ageInHours => DateTime.now().difference(createdAt).inHours;
  bool get isUrgent => severity == OptimizationSeverity.critical && !isAcknowledged;
}
