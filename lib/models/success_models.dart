import 'package:flutter/foundation.dart';

// Enums
enum CustomerHealthStatus {
  excellent,
  healthy,
  atRisk,
  critical,
  churned;

  String get displayName => {
    CustomerHealthStatus.excellent: 'Excellent / 優秀',
    CustomerHealthStatus.healthy: 'Healthy / 健全',
    CustomerHealthStatus.atRisk: 'At Risk / リスク',
    CustomerHealthStatus.critical: 'Critical / 深刻',
    CustomerHealthStatus.churned: 'Churned / 離脱',
  }[this]!;
}

enum ChurnRiskLevel {
  low,
  medium,
  high,
  veryHigh,
  imminent;

  String get displayName => {
    ChurnRiskLevel.low: 'Low / 低',
    ChurnRiskLevel.medium: 'Medium / 中',
    ChurnRiskLevel.high: 'High / 高',
    ChurnRiskLevel.veryHigh: 'Very High / 非常に高',
    ChurnRiskLevel.imminent: 'Imminent / 差迫',
  }[this]!;
}

enum SuccessMetricType {
  adoption,
  usage,
  engagement,
  expansion,
  retention,
  roi,
  satisfaction;

  String get displayName => {
    SuccessMetricType.adoption: 'Adoption / 導入',
    SuccessMetricType.usage: 'Usage / 利用',
    SuccessMetricType.engagement: 'Engagement / エンゲージ',
    SuccessMetricType.expansion: 'Expansion / 拡張',
    SuccessMetricType.retention: 'Retention / 保持',
    SuccessMetricType.roi: 'ROI / ROI',
    SuccessMetricType.satisfaction: 'Satisfaction / 満足',
  }[this]!;
}

enum RetentionStrategy {
  proactive,
  reactive,
  predictive,
  personalized,
  tier_specific;

  String get displayName => {
    RetentionStrategy.proactive: 'Proactive / 積極',
    RetentionStrategy.reactive: 'Reactive / 反応',
    RetentionStrategy.predictive: 'Predictive / 予測',
    RetentionStrategy.personalized: 'Personalized / パーソナル',
    RetentionStrategy.tier_specific: 'Tier-Specific / 階層別',
  }[this]!;
}

enum RenewalStatus {
  upcoming,
  pending,
  confirmed,
  at_risk,
  cancelled;

  String get displayName => {
    RenewalStatus.upcoming: 'Upcoming / 予定',
    RenewalStatus.pending: 'Pending / 保留中',
    RenewalStatus.confirmed: 'Confirmed / 確定',
    RenewalStatus.at_risk: 'At Risk / リスク',
    RenewalStatus.cancelled: 'Cancelled / キャンセル',
  }[this]!;
}

enum ExpansionOpportunity {
  upsell,
  crossSell,
  premiumTier,
  additionalSeats,
  customFeatures;

  String get displayName => {
    ExpansionOpportunity.upsell: 'Upsell / アップセル',
    ExpansionOpportunity.crossSell: 'Cross-Sell / クロスセル',
    ExpansionOpportunity.premiumTier: 'Premium Tier / プレミアム',
    ExpansionOpportunity.additionalSeats: 'Additional Seats / シート追加',
    ExpansionOpportunity.customFeatures: 'Custom Features / カスタム',
  }[this]!;
}

// Models
class CustomerAccount {
  final String accountId;
  final String customerName;
  final String industry;
  final int employeeCount;
  final double annualRenewalValue;
  final CustomerHealthStatus healthStatus;
  final DateTime createdAt;
  final DateTime lastCheckIn;
  final List<String> productUsage;
  final int tenureInMonths;

  CustomerAccount({
    required this.accountId,
    required this.customerName,
    required this.industry,
    required this.employeeCount,
    required this.annualRenewalValue,
    required this.healthStatus,
    required this.createdAt,
    required this.lastCheckIn,
    required this.productUsage,
    required this.tenureInMonths,
  });

  bool get isHealthy => healthStatus == CustomerHealthStatus.healthy || healthStatus == CustomerHealthStatus.excellent;
  bool get isAtRisk => healthStatus == CustomerHealthStatus.atRisk || healthStatus == CustomerHealthStatus.critical;
  bool get isHighValue => annualRenewalValue > 100000;
  int get daysSinceCheckIn => DateTime.now().difference(lastCheckIn).inDays;

  CustomerAccount copyWith({
    String? accountId,
    String? customerName,
    String? industry,
    int? employeeCount,
    double? annualRenewalValue,
    CustomerHealthStatus? healthStatus,
    DateTime? createdAt,
    DateTime? lastCheckIn,
    List<String>? productUsage,
    int? tenureInMonths,
  }) {
    return CustomerAccount(
      accountId: accountId ?? this.accountId,
      customerName: customerName ?? this.customerName,
      industry: industry ?? this.industry,
      employeeCount: employeeCount ?? this.employeeCount,
      annualRenewalValue: annualRenewalValue ?? this.annualRenewalValue,
      healthStatus: healthStatus ?? this.healthStatus,
      createdAt: createdAt ?? this.createdAt,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      productUsage: productUsage ?? this.productUsage,
      tenureInMonths: tenureInMonths ?? this.tenureInMonths,
    );
  }
}

class HealthScore {
  final String scoreId;
  final String accountId;
  final double overallScore;
  final double adoptionScore;
  final double usageScore;
  final double engagementScore;
  final double supportScore;
  final DateTime calculatedAt;
  final List<String> riskFactors;

  HealthScore({
    required this.scoreId,
    required this.accountId,
    required this.overallScore,
    required this.adoptionScore,
    required this.usageScore,
    required this.engagementScore,
    required this.supportScore,
    required this.calculatedAt,
    required this.riskFactors,
  });

  bool get isGood => overallScore >= 70;
  bool get needsAttention => overallScore < 50;
  int get ageInDays => DateTime.now().difference(calculatedAt).inDays;

  HealthScore copyWith({
    String? scoreId,
    String? accountId,
    double? overallScore,
    double? adoptionScore,
    double? usageScore,
    double? engagementScore,
    double? supportScore,
    DateTime? calculatedAt,
    List<String>? riskFactors,
  }) {
    return HealthScore(
      scoreId: scoreId ?? this.scoreId,
      accountId: accountId ?? this.accountId,
      overallScore: overallScore ?? this.overallScore,
      adoptionScore: adoptionScore ?? this.adoptionScore,
      usageScore: usageScore ?? this.usageScore,
      engagementScore: engagementScore ?? this.engagementScore,
      supportScore: supportScore ?? this.supportScore,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      riskFactors: riskFactors ?? this.riskFactors,
    );
  }
}

class ChurnPrediction {
  final String predictionId;
  final String accountId;
  final ChurnRiskLevel riskLevel;
  final double riskScore;
  final List<String> warningSignals;
  final DateTime predictedChurnDate;
  final String recommendedAction;
  final DateTime createdAt;

  ChurnPrediction({
    required this.predictionId,
    required this.accountId,
    required this.riskLevel,
    required this.riskScore,
    required this.warningSignals,
    required this.predictedChurnDate,
    required this.recommendedAction,
    required this.createdAt,
  });

  bool get isUrgent => riskLevel == ChurnRiskLevel.imminent || riskLevel == ChurnRiskLevel.veryHigh;
  bool get hasActionableSignals => warningSignals.length > 0;
  int get daysUntilPredictedChurn => predictedChurnDate.difference(DateTime.now()).inDays;

  ChurnPrediction copyWith({
    String? predictionId,
    String? accountId,
    ChurnRiskLevel? riskLevel,
    double? riskScore,
    List<String>? warningSignals,
    DateTime? predictedChurnDate,
    String? recommendedAction,
    DateTime? createdAt,
  }) {
    return ChurnPrediction(
      predictionId: predictionId ?? this.predictionId,
      accountId: accountId ?? this.accountId,
      riskLevel: riskLevel ?? this.riskLevel,
      riskScore: riskScore ?? this.riskScore,
      warningSignals: warningSignals ?? this.warningSignals,
      predictedChurnDate: predictedChurnDate ?? this.predictedChurnDate,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SuccessMetric {
  final String metricId;
  final String accountId;
  final SuccessMetricType type;
  final double currentValue;
  final double targetValue;
  final double trend;
  final DateTime measuredAt;
  final String unit;

  SuccessMetric({
    required this.metricId,
    required this.accountId,
    required this.type,
    required this.currentValue,
    required this.targetValue,
    required this.trend,
    required this.measuredAt,
    required this.unit,
  });

  bool get meetsTarget => currentValue >= targetValue;
  bool get isTrendingUp => trend > 0;
  double get percentOfTarget => (currentValue / targetValue) * 100;

  SuccessMetric copyWith({
    String? metricId,
    String? accountId,
    SuccessMetricType? type,
    double? currentValue,
    double? targetValue,
    double? trend,
    DateTime? measuredAt,
    String? unit,
  }) {
    return SuccessMetric(
      metricId: metricId ?? this.metricId,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
      trend: trend ?? this.trend,
      measuredAt: measuredAt ?? this.measuredAt,
      unit: unit ?? this.unit,
    );
  }
}

class RenewalInfo {
  final String renewalId;
  final String accountId;
  final DateTime renewalDate;
  final RenewalStatus status;
  final double renewalValue;
  final bool autoRenewal;
  final List<String> negotiationPoints;
  final DateTime lastInteraction;

  RenewalInfo({
    required this.renewalId,
    required this.accountId,
    required this.renewalDate,
    required this.status,
    required this.renewalValue,
    required this.autoRenewal,
    required this.negotiationPoints,
    required this.lastInteraction,
  });

  bool get isUpcoming => DateTime.now().difference(renewalDate).inDays > -90 && DateTime.now().isBefore(renewalDate);
  bool get isOverdue => DateTime.now().isAfter(renewalDate);
  int get daysUntilRenewal => renewalDate.difference(DateTime.now()).inDays;

  RenewalInfo copyWith({
    String? renewalId,
    String? accountId,
    DateTime? renewalDate,
    RenewalStatus? status,
    double? renewalValue,
    bool? autoRenewal,
    List<String>? negotiationPoints,
    DateTime? lastInteraction,
  }) {
    return RenewalInfo(
      renewalId: renewalId ?? this.renewalId,
      accountId: accountId ?? this.accountId,
      renewalDate: renewalDate ?? this.renewalDate,
      status: status ?? this.status,
      renewalValue: renewalValue ?? this.renewalValue,
      autoRenewal: autoRenewal ?? this.autoRenewal,
      negotiationPoints: negotiationPoints ?? this.negotiationPoints,
      lastInteraction: lastInteraction ?? this.lastInteraction,
    );
  }
}

class ExpansionPlan {
  final String planId;
  final String accountId;
  final ExpansionOpportunity opportunity;
  final double projectedRevenue;
  final double probability;
  final DateTime targetDate;
  final String strategy;
  final bool executed;

  ExpansionPlan({
    required this.planId,
    required this.accountId,
    required this.opportunity,
    required this.projectedRevenue,
    required this.probability,
    required this.targetDate,
    required this.strategy,
    required this.executed,
  });

  bool get isViable => probability > 0.3;
  bool get isOverdue => !executed && DateTime.now().isAfter(targetDate);
  double get expectedValue => projectedRevenue * probability;

  ExpansionPlan copyWith({
    String? planId,
    String? accountId,
    ExpansionOpportunity? opportunity,
    double? projectedRevenue,
    double? probability,
    DateTime? targetDate,
    String? strategy,
    bool? executed,
  }) {
    return ExpansionPlan(
      planId: planId ?? this.planId,
      accountId: accountId ?? this.accountId,
      opportunity: opportunity ?? this.opportunity,
      projectedRevenue: projectedRevenue ?? this.projectedRevenue,
      probability: probability ?? this.probability,
      targetDate: targetDate ?? this.targetDate,
      strategy: strategy ?? this.strategy,
      executed: executed ?? this.executed,
    );
  }
}

class CustomerEngagement {
  final String engagementId;
  final String accountId;
  final DateTime engagementDate;
  final String type;
  final String notes;
  final String owner;
  final int attendees;
  final String outcome;

  CustomerEngagement({
    required this.engagementId,
    required this.accountId,
    required this.engagementDate,
    required this.type,
    required this.notes,
    required this.owner,
    required this.attendees,
    required this.outcome,
  });

  bool get isRecent => DateTime.now().difference(engagementDate).inDays < 30;
  int get ageInDays => DateTime.now().difference(engagementDate).inDays;

  CustomerEngagement copyWith({
    String? engagementId,
    String? accountId,
    DateTime? engagementDate,
    String? type,
    String? notes,
    String? owner,
    int? attendees,
    String? outcome,
  }) {
    return CustomerEngagement(
      engagementId: engagementId ?? this.engagementId,
      accountId: accountId ?? this.accountId,
      engagementDate: engagementDate ?? this.engagementDate,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      owner: owner ?? this.owner,
      attendees: attendees ?? this.attendees,
      outcome: outcome ?? this.outcome,
    );
  }
}

class SuccessReport {
  final String reportId;
  final int totalCustomers;
  final double averageHealthScore;
  final int atRiskCount;
  final double churnRate;
  final double nRR;
  final double expansionRate;
  final DateTime generatedAt;

  SuccessReport({
    required this.reportId,
    required this.totalCustomers,
    required this.averageHealthScore,
    required this.atRiskCount,
    required this.churnRate,
    required this.nRR,
    required this.expansionRate,
    required this.generatedAt,
  });

  bool get isHealthy => averageHealthScore > 70 && churnRate < 0.05;

  String toMarkdown() {
    return '''# Customer Success Report

## Overview
- **Report ID**: $reportId
- **Generated**: ${generatedAt.toString()}
- **Total Customers**: $totalCustomers
- **Average Health Score**: ${averageHealthScore.toStringAsFixed(2)}/100

## Key Metrics
- **At Risk Accounts**: $atRiskCount
- **Churn Rate**: ${(churnRate * 100).toStringAsFixed(2)}%
- **Net Revenue Retention (NRR)**: ${(nRR * 100).toStringAsFixed(2)}%
- **Expansion Rate**: ${(expansionRate * 100).toStringAsFixed(2)}%

## Health Status
${isHealthy ? '✅ Overall health is good' : '⚠️ Attention needed'}
''';
  }
}
