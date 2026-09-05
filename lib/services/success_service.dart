/// Advanced Customer Success & Retention Service
/// Provides comprehensive customer health, churn prevention, renewal optimization,
/// and expansion planning capabilities.

import 'package:flutter/foundation.dart';
import '../models/success_models.dart';

// ============================================================================
// Repository Interface
// ============================================================================

abstract class SuccessRepository {
  // Customer Account Methods (12)
  Future<void> createCustomerAccount(CustomerAccount account);
  Future<CustomerAccount?> getCustomerAccount(String accountId);
  Future<List<CustomerAccount>> getAllCustomerAccounts();
  Future<List<CustomerAccount>> getHealthyCustomers();
  Future<List<CustomerAccount>> getAtRiskCustomers();
  Future<List<CustomerAccount>> getHighValueCustomers();
  Future<List<CustomerAccount>> getCustomersNotCheckedIn(Duration duration);
  Future<void> updateCustomerAccount(CustomerAccount account);
  Future<void> deleteCustomerAccount(String accountId);
  Future<int> getCustomerAccountCount();
  Future<List<CustomerAccount>> getCustomersByHealthStatus(
      CustomerHealthStatus status);
  Future<List<CustomerAccount>> getCustomersBySegment(String segment);

  // Health Score Methods (10)
  Future<void> createHealthScore(HealthScore score);
  Future<HealthScore?> getHealthScore(String scoreId);
  Future<HealthScore?> getLatestHealthScoreForAccount(String accountId);
  Future<List<HealthScore>> getHealthScoresForAccount(String accountId);
  Future<List<HealthScore>> getGoodHealthScores();
  Future<List<HealthScore>> getNeedsAttentionScores();
  Future<void> updateHealthScore(HealthScore score);
  Future<void> deleteHealthScore(String scoreId);
  Future<double> getAverageHealthScore();
  Future<List<HealthScore>> getRecentHealthScores(Duration duration);

  // Churn Prediction Methods (10)
  Future<void> createChurnPrediction(ChurnPrediction prediction);
  Future<ChurnPrediction?> getChurnPrediction(String predictionId);
  Future<ChurnPrediction?> getLatestChurnPredictionForAccount(
      String accountId);
  Future<List<ChurnPrediction>> getChurnPredictionsForAccount(
      String accountId);
  Future<List<ChurnPrediction>> getUrgentChurnPredictions();
  Future<List<ChurnPrediction>> getHighRiskPredictions();
  Future<List<ChurnPrediction>> getPredictionsWithActionableSignals();
  Future<void> updateChurnPrediction(ChurnPrediction prediction);
  Future<void> deleteChurnPrediction(String predictionId);
  Future<int> getChurnPredictionCount();

  // Success Metric Methods (10)
  Future<void> createSuccessMetric(SuccessMetric metric);
  Future<SuccessMetric?> getSuccessMetric(String metricId);
  Future<List<SuccessMetric>> getMetricsForAccount(String accountId);
  Future<List<SuccessMetric>> getMetricsByType(SuccessMetricType type);
  Future<List<SuccessMetric>> getMetricsNotMeetingTarget();
  Future<List<SuccessMetric>> getTrendingUpMetrics();
  Future<List<SuccessMetric>> getTrendingDownMetrics();
  Future<void> updateSuccessMetric(SuccessMetric metric);
  Future<void> deleteSuccessMetric(String metricId);
  Future<double> getAverageMetricAchievement();

  // Renewal Info Methods (10)
  Future<void> createRenewalInfo(RenewalInfo renewal);
  Future<RenewalInfo?> getRenewalInfo(String renewalId);
  Future<RenewalInfo?> getLatestRenewalForAccount(String accountId);
  Future<List<RenewalInfo>> getRenewalsForAccount(String accountId);
  Future<List<RenewalInfo>> getUpcomingRenewals(Duration daysAhead);
  Future<List<RenewalInfo>> getOverdueRenewals();
  Future<List<RenewalInfo>> getConfirmedRenewals();
  Future<void> updateRenewalInfo(RenewalInfo renewal);
  Future<void> deleteRenewalInfo(String renewalId);
  Future<double> getRenewalConfirmationRate();

  // Expansion Plan Methods (10)
  Future<void> createExpansionPlan(ExpansionPlan plan);
  Future<ExpansionPlan?> getExpansionPlan(String planId);
  Future<List<ExpansionPlan>> getExpansionPlansForAccount(String accountId);
  Future<List<ExpansionPlan>> getViableExpansionPlans();
  Future<List<ExpansionPlan>> getOverdueExpansionPlans();
  Future<List<ExpansionPlan>> getExpansionPlansByOpportunity(
      ExpansionOpportunity opportunity);
  Future<double> getTotalExpectedExpansionValue();
  Future<void> updateExpansionPlan(ExpansionPlan plan);
  Future<void> deleteExpansionPlan(String planId);
  Future<List<ExpansionPlan>> getHighValueExpansionPlans(double threshold);

  // Customer Engagement Methods (10)
  Future<void> createCustomerEngagement(CustomerEngagement engagement);
  Future<CustomerEngagement?> getCustomerEngagement(String engagementId);
  Future<List<CustomerEngagement>> getEngagementsForAccount(String accountId);
  Future<List<CustomerEngagement>> getRecentEngagements(Duration duration);
  Future<List<CustomerEngagement>> getLowEngagementRecords();
  Future<void> updateCustomerEngagement(CustomerEngagement engagement);
  Future<void> deleteCustomerEngagement(String engagementId);
  Future<int> getEngagementCount();
  Future<double> getAverageEngagementScore();
  Future<List<CustomerEngagement>> getEngagementsByType(String type);

  // Success Report Methods (8)
  Future<void> createSuccessReport(SuccessReport report);
  Future<SuccessReport?> getSuccessReport(String reportId);
  Future<List<SuccessReport>> getReportsForAccount(String accountId);
  Future<List<SuccessReport>> getHealthyReports();
  Future<List<SuccessReport>> getReportsWithHighNPS();
  Future<void> updateSuccessReport(SuccessReport report);
  Future<void> deleteSuccessReport(String reportId);
  Future<List<SuccessReport>> getRecentReports(Duration duration);
}

// ============================================================================
// In-Memory Repository Implementation
// ============================================================================

class InMemorySuccessRepository implements SuccessRepository {
  final Map<String, CustomerAccount> _accounts = {};
  final Map<String, HealthScore> _healthScores = {};
  final Map<String, ChurnPrediction> _churnPredictions = {};
  final Map<String, SuccessMetric> _metrics = {};
  final Map<String, RenewalInfo> _renewals = {};
  final Map<String, ExpansionPlan> _expansions = {};
  final Map<String, CustomerEngagement> _engagements = {};
  final Map<String, SuccessReport> _reports = {};

  // Customer Account Methods
  @override
  Future<void> createCustomerAccount(CustomerAccount account) async {
    _accounts[account.accountId] = account;
  }

  @override
  Future<CustomerAccount?> getCustomerAccount(String accountId) async {
    return _accounts[accountId];
  }

  @override
  Future<List<CustomerAccount>> getAllCustomerAccounts() async {
    return _accounts.values.toList();
  }

  @override
  Future<List<CustomerAccount>> getHealthyCustomers() async {
    return _accounts.values
        .where((a) => a.isHealthy)
        .toList();
  }

  @override
  Future<List<CustomerAccount>> getAtRiskCustomers() async {
    return _accounts.values
        .where((a) => a.isAtRisk)
        .toList();
  }

  @override
  Future<List<CustomerAccount>> getHighValueCustomers() async {
    return _accounts.values
        .where((a) => a.isHighValue)
        .toList();
  }

  @override
  Future<List<CustomerAccount>> getCustomersNotCheckedIn(Duration duration) async {
    final threshold = DateTime.now().subtract(duration);
    return _accounts.values
        .where((a) => a.lastCheckInDate.isBefore(threshold))
        .toList();
  }

  @override
  Future<void> updateCustomerAccount(CustomerAccount account) async {
    _accounts[account.accountId] = account;
  }

  @override
  Future<void> deleteCustomerAccount(String accountId) async {
    _accounts.remove(accountId);
  }

  @override
  Future<int> getCustomerAccountCount() async {
    return _accounts.length;
  }

  @override
  Future<List<CustomerAccount>> getCustomersByHealthStatus(
      CustomerHealthStatus status) async {
    return _accounts.values
        .where((a) => a.healthStatus == status)
        .toList();
  }

  @override
  Future<List<CustomerAccount>> getCustomersBySegment(String segment) async {
    return _accounts.values
        .where((a) => a.segment == segment)
        .toList();
  }

  // Health Score Methods
  @override
  Future<void> createHealthScore(HealthScore score) async {
    _healthScores[score.scoreId] = score;
  }

  @override
  Future<HealthScore?> getHealthScore(String scoreId) async {
    return _healthScores[scoreId];
  }

  @override
  Future<HealthScore?> getLatestHealthScoreForAccount(String accountId) async {
    final scores = _healthScores.values
        .where((s) => s.accountId == accountId)
        .toList();
    if (scores.isEmpty) return null;
    scores.sort((a, b) => b.measuredDate.compareTo(a.measuredDate));
    return scores.first;
  }

  @override
  Future<List<HealthScore>> getHealthScoresForAccount(String accountId) async {
    return _healthScores.values
        .where((s) => s.accountId == accountId)
        .toList();
  }

  @override
  Future<List<HealthScore>> getGoodHealthScores() async {
    return _healthScores.values
        .where((s) => s.isGood)
        .toList();
  }

  @override
  Future<List<HealthScore>> getNeedsAttentionScores() async {
    return _healthScores.values
        .where((s) => s.needsAttention)
        .toList();
  }

  @override
  Future<void> updateHealthScore(HealthScore score) async {
    _healthScores[score.scoreId] = score;
  }

  @override
  Future<void> deleteHealthScore(String scoreId) async {
    _healthScores.remove(scoreId);
  }

  @override
  Future<double> getAverageHealthScore() async {
    if (_healthScores.isEmpty) return 0;
    final sum = _healthScores.values.fold<double>(
        0, (sum, s) => sum + s.overallScore);
    return sum / _healthScores.length;
  }

  @override
  Future<List<HealthScore>> getRecentHealthScores(Duration duration) async {
    final threshold = DateTime.now().subtract(duration);
    return _healthScores.values
        .where((s) => s.measuredDate.isAfter(threshold))
        .toList();
  }

  // Churn Prediction Methods
  @override
  Future<void> createChurnPrediction(ChurnPrediction prediction) async {
    _churnPredictions[prediction.predictionId] = prediction;
  }

  @override
  Future<ChurnPrediction?> getChurnPrediction(String predictionId) async {
    return _churnPredictions[predictionId];
  }

  @override
  Future<ChurnPrediction?> getLatestChurnPredictionForAccount(
      String accountId) async {
    final predictions = _churnPredictions.values
        .where((p) => p.accountId == accountId)
        .toList();
    if (predictions.isEmpty) return null;
    predictions.sort((a, b) => b.predictionDate.compareTo(a.predictionDate));
    return predictions.first;
  }

  @override
  Future<List<ChurnPrediction>> getChurnPredictionsForAccount(
      String accountId) async {
    return _churnPredictions.values
        .where((p) => p.accountId == accountId)
        .toList();
  }

  @override
  Future<List<ChurnPrediction>> getUrgentChurnPredictions() async {
    return _churnPredictions.values
        .where((p) => p.isUrgent)
        .toList();
  }

  @override
  Future<List<ChurnPrediction>> getHighRiskPredictions() async {
    return _churnPredictions.values
        .where((p) => p.riskLevel == ChurnRiskLevel.veryHigh ||
            p.riskLevel == ChurnRiskLevel.imminent)
        .toList();
  }

  @override
  Future<List<ChurnPrediction>> getPredictionsWithActionableSignals() async {
    return _churnPredictions.values
        .where((p) => p.hasActionableSignals)
        .toList();
  }

  @override
  Future<void> updateChurnPrediction(ChurnPrediction prediction) async {
    _churnPredictions[prediction.predictionId] = prediction;
  }

  @override
  Future<void> deleteChurnPrediction(String predictionId) async {
    _churnPredictions.remove(predictionId);
  }

  @override
  Future<int> getChurnPredictionCount() async {
    return _churnPredictions.length;
  }

  // Success Metric Methods
  @override
  Future<void> createSuccessMetric(SuccessMetric metric) async {
    _metrics[metric.metricId] = metric;
  }

  @override
  Future<SuccessMetric?> getSuccessMetric(String metricId) async {
    return _metrics[metricId];
  }

  @override
  Future<List<SuccessMetric>> getMetricsForAccount(String accountId) async {
    return _metrics.values
        .where((m) => m.accountId == accountId)
        .toList();
  }

  @override
  Future<List<SuccessMetric>> getMetricsByType(SuccessMetricType type) async {
    return _metrics.values
        .where((m) => m.metricType == type)
        .toList();
  }

  @override
  Future<List<SuccessMetric>> getMetricsNotMeetingTarget() async {
    return _metrics.values
        .where((m) => !m.meetsTarget)
        .toList();
  }

  @override
  Future<List<SuccessMetric>> getTrendingUpMetrics() async {
    return _metrics.values
        .where((m) => m.isTrendingUp)
        .toList();
  }

  @override
  Future<List<SuccessMetric>> getTrendingDownMetrics() async {
    return _metrics.values
        .where((m) => !m.isTrendingUp)
        .toList();
  }

  @override
  Future<void> updateSuccessMetric(SuccessMetric metric) async {
    _metrics[metric.metricId] = metric;
  }

  @override
  Future<void> deleteSuccessMetric(String metricId) async {
    _metrics.remove(metricId);
  }

  @override
  Future<double> getAverageMetricAchievement() async {
    if (_metrics.isEmpty) return 0;
    final sum = _metrics.values.fold<double>(
        0, (sum, m) => sum + m.percentOfTarget);
    return sum / _metrics.length;
  }

  // Renewal Info Methods
  @override
  Future<void> createRenewalInfo(RenewalInfo renewal) async {
    _renewals[renewal.renewalId] = renewal;
  }

  @override
  Future<RenewalInfo?> getRenewalInfo(String renewalId) async {
    return _renewals[renewalId];
  }

  @override
  Future<RenewalInfo?> getLatestRenewalForAccount(String accountId) async {
    final renewals = _renewals.values
        .where((r) => r.accountId == accountId)
        .toList();
    if (renewals.isEmpty) return null;
    renewals.sort((a, b) => b.renewalDate.compareTo(a.renewalDate));
    return renewals.first;
  }

  @override
  Future<List<RenewalInfo>> getRenewalsForAccount(String accountId) async {
    return _renewals.values
        .where((r) => r.accountId == accountId)
        .toList();
  }

  @override
  Future<List<RenewalInfo>> getUpcomingRenewals(Duration daysAhead) async {
    final threshold = DateTime.now().add(daysAhead);
    return _renewals.values
        .where((r) => r.isUpcoming &&
            r.renewalDate.isBefore(threshold))
        .toList();
  }

  @override
  Future<List<RenewalInfo>> getOverdueRenewals() async {
    return _renewals.values
        .where((r) => r.isOverdue)
        .toList();
  }

  @override
  Future<List<RenewalInfo>> getConfirmedRenewals() async {
    return _renewals.values
        .where((r) => r.status == RenewalStatus.confirmed)
        .toList();
  }

  @override
  Future<void> updateRenewalInfo(RenewalInfo renewal) async {
    _renewals[renewal.renewalId] = renewal;
  }

  @override
  Future<void> deleteRenewalInfo(String renewalId) async {
    _renewals.remove(renewalId);
  }

  @override
  Future<double> getRenewalConfirmationRate() async {
    if (_renewals.isEmpty) return 0;
    final confirmed = _renewals.values
        .where((r) => r.status == RenewalStatus.confirmed)
        .length;
    return (confirmed / _renewals.length) * 100;
  }

  // Expansion Plan Methods
  @override
  Future<void> createExpansionPlan(ExpansionPlan plan) async {
    _expansions[plan.planId] = plan;
  }

  @override
  Future<ExpansionPlan?> getExpansionPlan(String planId) async {
    return _expansions[planId];
  }

  @override
  Future<List<ExpansionPlan>> getExpansionPlansForAccount(
      String accountId) async {
    return _expansions.values
        .where((p) => p.accountId == accountId)
        .toList();
  }

  @override
  Future<List<ExpansionPlan>> getViableExpansionPlans() async {
    return _expansions.values
        .where((p) => p.isViable)
        .toList();
  }

  @override
  Future<List<ExpansionPlan>> getOverdueExpansionPlans() async {
    return _expansions.values
        .where((p) => p.isOverdue)
        .toList();
  }

  @override
  Future<List<ExpansionPlan>> getExpansionPlansByOpportunity(
      ExpansionOpportunity opportunity) async {
    return _expansions.values
        .where((p) => p.opportunity == opportunity)
        .toList();
  }

  @override
  Future<double> getTotalExpectedExpansionValue() async {
    return _expansions.values.fold<double>(
        0, (sum, p) => sum + p.expectedValue);
  }

  @override
  Future<void> updateExpansionPlan(ExpansionPlan plan) async {
    _expansions[plan.planId] = plan;
  }

  @override
  Future<void> deleteExpansionPlan(String planId) async {
    _expansions.remove(planId);
  }

  @override
  Future<List<ExpansionPlan>> getHighValueExpansionPlans(
      double threshold) async {
    return _expansions.values
        .where((p) => p.expectedValue >= threshold)
        .toList();
  }

  // Customer Engagement Methods
  @override
  Future<void> createCustomerEngagement(CustomerEngagement engagement) async {
    _engagements[engagement.engagementId] = engagement;
  }

  @override
  Future<CustomerEngagement?> getCustomerEngagement(String engagementId) async {
    return _engagements[engagementId];
  }

  @override
  Future<List<CustomerEngagement>> getEngagementsForAccount(
      String accountId) async {
    return _engagements.values
        .where((e) => e.accountId == accountId)
        .toList();
  }

  @override
  Future<List<CustomerEngagement>> getRecentEngagements(Duration duration) async {
    final threshold = DateTime.now().subtract(duration);
    return _engagements.values
        .where((e) => e.lastInteractionDate.isAfter(threshold))
        .toList();
  }

  @override
  Future<List<CustomerEngagement>> getLowEngagementRecords() async {
    return _engagements.values
        .where((e) => !e.isRecent)
        .toList();
  }

  @override
  Future<void> updateCustomerEngagement(CustomerEngagement engagement) async {
    _engagements[engagement.engagementId] = engagement;
  }

  @override
  Future<void> deleteCustomerEngagement(String engagementId) async {
    _engagements.remove(engagementId);
  }

  @override
  Future<int> getEngagementCount() async {
    return _engagements.length;
  }

  @override
  Future<double> getAverageEngagementScore() async {
    if (_engagements.isEmpty) return 0;
    final sum = _engagements.values.fold<double>(
        0, (sum, e) => sum + e.engagementScore);
    return sum / _engagements.length;
  }

  @override
  Future<List<CustomerEngagement>> getEngagementsByType(String type) async {
    return _engagements.values
        .where((e) => e.engagementType == type)
        .toList();
  }

  // Success Report Methods
  @override
  Future<void> createSuccessReport(SuccessReport report) async {
    _reports[report.reportId] = report;
  }

  @override
  Future<SuccessReport?> getSuccessReport(String reportId) async {
    return _reports[reportId];
  }

  @override
  Future<List<SuccessReport>> getReportsForAccount(String accountId) async {
    return _reports.values
        .where((r) => r.accountId == accountId)
        .toList();
  }

  @override
  Future<List<SuccessReport>> getHealthyReports() async {
    return _reports.values
        .where((r) => r.isHealthy)
        .toList();
  }

  @override
  Future<List<SuccessReport>> getReportsWithHighNPS() async {
    return _reports.values
        .where((r) => r.hasHighNPS)
        .toList();
  }

  @override
  Future<void> updateSuccessReport(SuccessReport report) async {
    _reports[report.reportId] = report;
  }

  @override
  Future<void> deleteSuccessReport(String reportId) async {
    _reports.remove(reportId);
  }

  @override
  Future<List<SuccessReport>> getRecentReports(Duration duration) async {
    final threshold = DateTime.now().subtract(duration);
    return _reports.values
        .where((r) => r.generatedDate.isAfter(threshold))
        .toList();
  }
}

// ============================================================================
// Specialized Engines
// ============================================================================

class SuccessHealthEngine {
  final SuccessRepository repository;

  SuccessHealthEngine(this.repository);

  Future<List<CustomerAccount>> getAccountsRequiringAttention() async {
    final atRisk = await repository.getAtRiskCustomers();
    final allAccounts = await repository.getAllCustomerAccounts();
    final noCheckIn = await repository.getCustomersNotCheckedIn(
        Duration(days: 30));

    final combined = {...?atRisk, ...?noCheckIn}
        .values
        .toList();
    return combined;
  }

  Future<double> calculateHealthMetrics() async {
    return await repository.getAverageHealthScore();
  }

  Future<Map<CustomerHealthStatus, int>> getHealthStatusDistribution() async {
    final accounts = await repository.getAllCustomerAccounts();
    final distribution = <CustomerHealthStatus, int>{};

    for (final account in accounts) {
      distribution[account.healthStatus] =
          (distribution[account.healthStatus] ?? 0) + 1;
    }

    return distribution;
  }

  Future<void> triggerHealthCheckForAtRiskAccounts() async {
    final atRisk = await repository.getAtRiskCustomers();
    for (final account in atRisk) {
      final engagement = CustomerEngagement(
        engagementId: 'eng_${DateTime.now().millisecondsSinceEpoch}',
        accountId: account.accountId,
        engagementType: 'health_check',
        lastInteractionDate: DateTime.now(),
        engagementScore: 0.5,
      );
      await repository.createCustomerEngagement(engagement);
    }
  }
}

class ChurnPreventionEngine {
  final SuccessRepository repository;

  ChurnPreventionEngine(this.repository);

  Future<List<ChurnPrediction>> getImminentChurnRisks() async {
    return await repository.getUrgentChurnPredictions();
  }

  Future<Map<ChurnRiskLevel, int>> getChurnRiskDistribution() async {
    final predictions = await repository
        .getChurnPredictionsForAccount('all');
    final distribution = <ChurnRiskLevel, int>{};

    for (final prediction in predictions) {
      distribution[prediction.riskLevel] =
          (distribution[prediction.riskLevel] ?? 0) + 1;
    }

    return distribution;
  }

  Future<List<CustomerAccount>> getAccountsAtRiskOfChurn() async {
    final predictions = await repository.getHighRiskPredictions();
    final accounts = <CustomerAccount>[];

    for (final prediction in predictions) {
      final account = await repository.getCustomerAccount(
          prediction.accountId);
      if (account != null) accounts.add(account);
    }

    return accounts;
  }

  Future<void> createRetentionInterventions(
      List<ChurnPrediction> predictions) async {
    for (final prediction in predictions) {
      final engagement = CustomerEngagement(
        engagementId: 'eng_${DateTime.now().millisecondsSinceEpoch}',
        accountId: prediction.accountId,
        engagementType: 'retention_intervention',
        lastInteractionDate: DateTime.now(),
        engagementScore: 1.0,
      );
      await repository.createCustomerEngagement(engagement);
    }
  }
}

class RenewalOptimizationEngine {
  final SuccessRepository repository;

  RenewalOptimizationEngine(this.repository);

  Future<List<RenewalInfo>> getUpcomingRenewalsNeedingAction() async {
    return await repository.getUpcomingRenewals(Duration(days: 90));
  }

  Future<double> getRenewalPipeline() async {
    final renewals = await repository.getConfirmedRenewals();
    double total = 0;
    for (final renewal in renewals) {
      total += renewal.contractValue ?? 0;
    }
    return total;
  }

  Future<Map<RenewalStatus, int>> getRenewalStatusDistribution() async {
    final allRenewals = <RenewalInfo>[];
    final accounts = await repository.getAllCustomerAccounts();

    for (final account in accounts) {
      final renewals = await repository.getRenewalsForAccount(
          account.accountId);
      allRenewals.addAll(renewals);
    }

    final distribution = <RenewalStatus, int>{};
    for (final renewal in allRenewals) {
      distribution[renewal.status] =
          (distribution[renewal.status] ?? 0) + 1;
    }

    return distribution;
  }

  Future<void> scheduleRenewalFollowUps() async {
    final upcomingRenewals = await getUpcomingRenewalsNeedingAction();
    for (final renewal in upcomingRenewals) {
      // Create engagement for follow-up
      final engagement = CustomerEngagement(
        engagementId: 'eng_${DateTime.now().millisecondsSinceEpoch}',
        accountId: renewal.accountId,
        engagementType: 'renewal_followup',
        lastInteractionDate: DateTime.now(),
        engagementScore: 0.8,
      );
      await repository.createCustomerEngagement(engagement);
    }
  }
}

class ExpansionEngine {
  final SuccessRepository repository;

  ExpansionEngine(this.repository);

  Future<List<ExpansionPlan>> getHighValueExpansionOpportunities() async {
    return await repository.getHighValueExpansionPlans(50000);
  }

  Future<double> getTotalExpansionRevenuePotential() async {
    return await repository.getTotalExpectedExpansionValue();
  }

  Future<Map<ExpansionOpportunity, List<ExpansionPlan>>>
      getExpansionsByType() async {
    final allPlans = <ExpansionPlan>[];
    final accounts = await repository.getAllCustomerAccounts();

    for (final account in accounts) {
      final plans = await repository.getExpansionPlansForAccount(
          account.accountId);
      allPlans.addAll(plans);
    }

    final groupedPlans = <ExpansionOpportunity, List<ExpansionPlan>>{};
    for (final plan in allPlans) {
      if (!groupedPlans.containsKey(plan.opportunity)) {
        groupedPlans[plan.opportunity] = [];
      }
      groupedPlans[plan.opportunity]!.add(plan);
    }

    return groupedPlans;
  }

  Future<void> activateExpansionPlans(
      List<ExpansionPlan> plans) async {
    for (final plan in plans) {
      final updated = plan.copyWith(
        status: 'active',
      );
      await repository.updateExpansionPlan(updated);
    }
  }
}

class EngagementEngine {
  final SuccessRepository repository;

  EngagementEngine(this.repository);

  Future<double> getOverallEngagementScore() async {
    return await repository.getAverageEngagementScore();
  }

  Future<List<CustomerAccount>> getLowEngagementAccounts() async {
    final accounts = await repository.getAllCustomerAccounts();
    final lowEngagement = <CustomerAccount>[];

    for (final account in accounts) {
      final engagements = await repository.getEngagementsForAccount(
          account.accountId);
      if (engagements.isEmpty ||
          engagements.every((e) => !e.isRecent)) {
        lowEngagement.add(account);
      }
    }

    return lowEngagement;
  }

  Future<Map<String, int>> getEngagementTypeDistribution() async {
    final allEngagements = <CustomerEngagement>[];
    final accounts = await repository.getAllCustomerAccounts();

    for (final account in accounts) {
      final engagements = await repository.getEngagementsForAccount(
          account.accountId);
      allEngagements.addAll(engagements);
    }

    final distribution = <String, int>{};
    for (final engagement in allEngagements) {
      distribution[engagement.engagementType] =
          (distribution[engagement.engagementType] ?? 0) + 1;
    }

    return distribution;
  }

  Future<void> recordCustomerInteraction(
      String accountId, String type) async {
    final engagement = CustomerEngagement(
      engagementId: 'eng_${DateTime.now().millisecondsSinceEpoch}',
      accountId: accountId,
      engagementType: type,
      lastInteractionDate: DateTime.now(),
      engagementScore: 0.75,
    );
    await repository.createCustomerEngagement(engagement);
  }
}

// ============================================================================
// Manager
// ============================================================================

class SuccessManager {
  final SuccessRepository repository;
  late final SuccessHealthEngine healthEngine;
  late final ChurnPreventionEngine churnEngine;
  late final RenewalOptimizationEngine renewalEngine;
  late final ExpansionEngine expansionEngine;
  late final EngagementEngine engagementEngine;

  SuccessManager(this.repository) {
    healthEngine = SuccessHealthEngine(repository);
    churnEngine = ChurnPreventionEngine(repository);
    renewalEngine = RenewalOptimizationEngine(repository);
    expansionEngine = ExpansionEngine(repository);
    engagementEngine = EngagementEngine(repository);
  }

  Future<Map<String, dynamic>> generateComprehensiveSuccessReport() async {
    return {
      'healthScore': await healthEngine.calculateHealthMetrics(),
      'renewalRate': await renewalEngine.getRenewalPipeline(),
      'expansionPotential':
          await expansionEngine.getTotalExpansionRevenuePotential(),
      'engagementScore': await engagementEngine.getOverallEngagementScore(),
      'accountsAtRisk': (await churnEngine.getAccountsAtRiskOfChurn()).length,
    };
  }
}

// ============================================================================
// Facade
// ============================================================================

class SuccessFacade {
  final SuccessManager manager;

  SuccessFacade(SuccessRepository repository)
      : manager = SuccessManager(repository);

  // Customer Management
  Future<void> addCustomerAccount(CustomerAccount account) =>
      manager.repository.createCustomerAccount(account);

  Future<CustomerAccount?> getCustomer(String accountId) =>
      manager.repository.getCustomerAccount(accountId);

  // Health Monitoring
  Future<List<CustomerAccount>> getCustomersNeedingAttention() =>
      manager.healthEngine.getAccountsRequiringAttention();

  Future<Map<CustomerHealthStatus, int>> getHealthStatusBreakdown() =>
      manager.healthEngine.getHealthStatusDistribution();

  // Churn Prevention
  Future<List<ChurnPrediction>> getChurnAlerts() =>
      manager.churnEngine.getImminentChurnRisks();

  Future<void> initializeChurnPreventionProgram() =>
      manager.churnEngine.createRetentionInterventions(
          await manager.churnEngine.getImminentChurnRisks());

  // Renewal Management
  Future<List<RenewalInfo>> getUpcomingRenewals() =>
      manager.renewalEngine.getUpcomingRenewalsNeedingAction();

  Future<double> getRenewalPipeline() =>
      manager.renewalEngine.getRenewalPipeline();

  // Expansion Opportunities
  Future<List<ExpansionPlan>> getExpansionOpportunities() =>
      manager.expansionEngine.getHighValueExpansionOpportunities();

  Future<double> getExpansionPotential() =>
      manager.expansionEngine.getTotalExpansionRevenuePotential();

  // Engagement Tracking
  Future<void> recordInteraction(String accountId, String type) =>
      manager.engagementEngine.recordCustomerInteraction(accountId, type);

  Future<double> getEngagementScore() =>
      manager.engagementEngine.getOverallEngagementScore();

  // Overall Metrics
  Future<Map<String, dynamic>> getDashboard() =>
      manager.generateComprehensiveSuccessReport();
}
