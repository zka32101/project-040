/// Comprehensive test suite for Phase 95: Advanced Customer Success & Retention
/// Tests all models, enums, repository operations, engines, managers, and facades

import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/success_models.dart';
import 'package:project_040/services/success_service.dart';

void main() {
  group('Phase 95: Customer Success & Retention Tests', () {
    late SuccessFacade facade;
    late SuccessRepository repository;

    setUp(() {
      repository = InMemorySuccessRepository();
      facade = SuccessFacade(repository);
    });

    // ========================================================================
    // Enum Tests (6 enums)
    // ========================================================================

    group('Enum Tests', () {
      test('CustomerHealthStatus has all values', () {
        expect(CustomerHealthStatus.values.length, 5);
        expect(CustomerHealthStatus.values,
            contains(CustomerHealthStatus.excellent));
        expect(CustomerHealthStatus.values, contains(CustomerHealthStatus.healthy));
        expect(CustomerHealthStatus.values, contains(CustomerHealthStatus.atRisk));
        expect(CustomerHealthStatus.values, contains(CustomerHealthStatus.critical));
        expect(CustomerHealthStatus.values, contains(CustomerHealthStatus.churned));
      });

      test('CustomerHealthStatus has display names', () {
        expect(
            CustomerHealthStatus.excellent.displayName, 'Excellent (優秀)');
        expect(CustomerHealthStatus.healthy.displayName, 'Healthy (健全)');
        expect(CustomerHealthStatus.atRisk.displayName, 'At Risk (リスク)');
        expect(CustomerHealthStatus.critical.displayName, 'Critical (危機的)');
        expect(CustomerHealthStatus.churned.displayName, 'Churned (解約)');
      });

      test('ChurnRiskLevel has all values', () {
        expect(ChurnRiskLevel.values.length, 5);
        expect(ChurnRiskLevel.values, contains(ChurnRiskLevel.low));
        expect(ChurnRiskLevel.values, contains(ChurnRiskLevel.veryHigh));
        expect(ChurnRiskLevel.values, contains(ChurnRiskLevel.imminent));
      });

      test('ChurnRiskLevel has display names', () {
        expect(ChurnRiskLevel.low.displayName, 'Low (低)');
        expect(ChurnRiskLevel.veryHigh.displayName, 'Very High (非常に高い)');
        expect(ChurnRiskLevel.imminent.displayName, 'Imminent (差し迫った)');
      });

      test('SuccessMetricType has all values', () {
        expect(SuccessMetricType.values.length, 7);
        expect(SuccessMetricType.values, contains(SuccessMetricType.adoption));
        expect(SuccessMetricType.values, contains(SuccessMetricType.roi));
      });

      test('SuccessMetricType has display names', () {
        expect(SuccessMetricType.adoption.displayName, 'Adoption (採用)');
        expect(SuccessMetricType.roi.displayName, 'ROI (投資利益率)');
      });

      test('RetentionStrategy has all values', () {
        expect(RetentionStrategy.values.length, 5);
        expect(RetentionStrategy.values, contains(RetentionStrategy.proactive));
        expect(RetentionStrategy.values, contains(RetentionStrategy.tierSpecific));
      });

      test('RenewalStatus has all values', () {
        expect(RenewalStatus.values.length, 5);
        expect(RenewalStatus.values, contains(RenewalStatus.upcoming));
        expect(RenewalStatus.values, contains(RenewalStatus.cancelled));
      });

      test('ExpansionOpportunity has all values', () {
        expect(ExpansionOpportunity.values.length, 5);
        expect(ExpansionOpportunity.values,
            contains(ExpansionOpportunity.upsell));
        expect(ExpansionOpportunity.values,
            contains(ExpansionOpportunity.premiumTier));
      });
    });

    // ========================================================================
    // Model Tests (8 models)
    // ========================================================================

    group('Model Tests', () {
      test('CustomerAccount basic properties', () {
        final account = CustomerAccount(
          accountId: 'acc_001',
          companyName: 'Acme Corp',
          healthStatus: CustomerHealthStatus.healthy,
          contractValue: 100000,
          segment: 'Enterprise',
          lastCheckInDate: DateTime(2024, 1, 1),
        );
        expect(account.accountId, 'acc_001');
        expect(account.companyName, 'Acme Corp');
        expect(account.healthStatus, CustomerHealthStatus.healthy);
        expect(account.isHealthy, true);
      });

      test('CustomerAccount computed properties', () {
        final account = CustomerAccount(
          accountId: 'acc_001',
          companyName: 'Test',
          healthStatus: CustomerHealthStatus.atRisk,
          contractValue: 100000,
          segment: 'Mid',
          lastCheckInDate: DateTime.now().subtract(Duration(days: 40)),
        );
        expect(account.isAtRisk, true);
        expect(account.isHealthy, false);
        expect(account.daysSinceCheckIn, greaterThan(39));
      });

      test('CustomerAccount copyWith', () {
        final original = CustomerAccount(
          accountId: 'acc_001',
          companyName: 'Original',
          healthStatus: CustomerHealthStatus.healthy,
          contractValue: 100000,
          segment: 'Enterprise',
          lastCheckInDate: DateTime.now(),
        );
        final updated = original.copyWith(
          companyName: 'Updated',
          healthStatus: CustomerHealthStatus.critical,
        );
        expect(updated.companyName, 'Updated');
        expect(updated.healthStatus, CustomerHealthStatus.critical);
        expect(updated.accountId, original.accountId);
      });

      test('HealthScore computed properties', () {
        final score = HealthScore(
          scoreId: 'hs_001',
          accountId: 'acc_001',
          overallScore: 85.0,
          adoptionScore: 90.0,
          usageScore: 80.0,
          engagementScore: 85.0,
          satisfactionScore: 82.0,
          measuredDate: DateTime.now(),
        );
        expect(score.isGood, true);
        expect(score.needsAttention, false);
        expect(score.overallScore, 85.0);
      });

      test('HealthScore needs attention', () {
        final score = HealthScore(
          scoreId: 'hs_001',
          accountId: 'acc_001',
          overallScore: 35.0,
          adoptionScore: 40.0,
          usageScore: 30.0,
          engagementScore: 35.0,
          satisfactionScore: 32.0,
          measuredDate: DateTime.now(),
        );
        expect(score.needsAttention, true);
        expect(score.isGood, false);
      });

      test('ChurnPrediction computed properties', () {
        final prediction = ChurnPrediction(
          predictionId: 'cp_001',
          accountId: 'acc_001',
          churnProbability: 0.85,
          riskLevel: ChurnRiskLevel.imminent,
          predictedChurnDate: DateTime.now().add(Duration(days: 10)),
          signals: ['low_usage', 'support_tickets'],
          predictionDate: DateTime.now(),
        );
        expect(prediction.isUrgent, true);
        expect(prediction.hasActionableSignals, true);
        expect(prediction.daysUntilPredictedChurn, lessThan(11));
      });

      test('SuccessMetric computed properties', () {
        final metric = SuccessMetric(
          metricId: 'sm_001',
          accountId: 'acc_001',
          metricType: SuccessMetricType.adoption,
          targetValue: 100.0,
          currentValue: 95.0,
          previousValue: 90.0,
          measuredDate: DateTime.now(),
        );
        expect(metric.meetsTarget, false);
        expect(metric.percentOfTarget, 95.0);
        expect(metric.isTrendingUp, true);
      });

      test('RenewalInfo computed properties', () {
        final renewal = RenewalInfo(
          renewalId: 'ren_001',
          accountId: 'acc_001',
          renewalDate: DateTime.now().add(Duration(days: 45)),
          status: RenewalStatus.upcoming,
          contractValue: 150000,
          lastRenewalDate: DateTime.now().subtract(Duration(days: 365)),
        );
        expect(renewal.isUpcoming, true);
        expect(renewal.isOverdue, false);
        expect(renewal.daysUntilRenewal, greaterThan(44));
      });

      test('ExpansionPlan computed properties', () {
        final plan = ExpansionPlan(
          planId: 'exp_001',
          accountId: 'acc_001',
          opportunity: ExpansionOpportunity.upsell,
          expectedValue: 75000,
          targetDate: DateTime.now().add(Duration(days: 60)),
          status: 'planning',
        );
        expect(plan.isViable, true);
        expect(plan.isOverdue, false);
      });

      test('CustomerEngagement computed properties', () {
        final engagement = CustomerEngagement(
          engagementId: 'ceng_001',
          accountId: 'acc_001',
          engagementType: 'meeting',
          lastInteractionDate: DateTime.now().subtract(Duration(days: 5)),
          engagementScore: 0.9,
        );
        expect(engagement.isRecent, true);
        expect(engagement.ageInDays, lessThan(6));
      });

      test('SuccessReport computed properties', () {
        final report = SuccessReport(
          reportId: 'sr_001',
          accountId: 'acc_001',
          overallHealthScore: 80.0,
          npsScore: 65,
          criticalIssues: [],
          recommendations: [],
          generatedDate: DateTime.now(),
        );
        expect(report.isHealthy, true);
        expect(report.hasHighNPS, false);
      });

      test('SuccessReport markdown export', () {
        final report = SuccessReport(
          reportId: 'sr_001',
          accountId: 'acc_001',
          overallHealthScore: 80.0,
          npsScore: 65,
          criticalIssues: ['Issue 1'],
          recommendations: ['Recommendation 1'],
          generatedDate: DateTime.now(),
        );
        final markdown = report.toMarkdown();
        expect(markdown.contains('# Success Report'), true);
        expect(markdown.contains('80'), true);
      });
    });

    // ========================================================================
    // Repository Tests (CRUD operations)
    // ========================================================================

    group('Repository Tests - Customer Accounts', () {
      test('Create and retrieve customer account', () async {
        final account = CustomerAccount(
          accountId: 'acc_001',
          companyName: 'Test Corp',
          healthStatus: CustomerHealthStatus.healthy,
          contractValue: 100000,
          segment: 'Enterprise',
          lastCheckInDate: DateTime.now(),
        );
        await repository.createCustomerAccount(account);
        final retrieved = await repository.getCustomerAccount('acc_001');
        expect(retrieved, isNotNull);
        expect(retrieved?.companyName, 'Test Corp');
      });

      test('Get all customer accounts', () async {
        final acc1 = CustomerAccount(
          accountId: 'acc_001',
          companyName: 'Corp 1',
          healthStatus: CustomerHealthStatus.healthy,
          contractValue: 100000,
          segment: 'Enterprise',
          lastCheckInDate: DateTime.now(),
        );
        final acc2 = CustomerAccount(
          accountId: 'acc_002',
          companyName: 'Corp 2',
          healthStatus: CustomerHealthStatus.atRisk,
          contractValue: 50000,
          segment: 'Mid',
          lastCheckInDate: DateTime.now(),
        );
        await repository.createCustomerAccount(acc1);
        await repository.createCustomerAccount(acc2);
        final all = await repository.getAllCustomerAccounts();
        expect(all.length, 2);
      });

      test('Get healthy customers', () async {
        final healthy = CustomerAccount(
          accountId: 'acc_001',
          companyName: 'Healthy Corp',
          healthStatus: CustomerHealthStatus.healthy,
          contractValue: 100000,
          segment: 'Enterprise',
          lastCheckInDate: DateTime.now(),
        );
        final atRisk = CustomerAccount(
          accountId: 'acc_002',
          companyName: 'AtRisk Corp',
          healthStatus: CustomerHealthStatus.atRisk,
          contractValue: 50000,
          segment: 'Mid',
          lastCheckInDate: DateTime.now(),
        );
        await repository.createCustomerAccount(healthy);
        await repository.createCustomerAccount(atRisk);
        final result = await repository.getHealthyCustomers();
        expect(result.length, 1);
        expect(result.first.healthStatus, CustomerHealthStatus.healthy);
      });

      test('Get at-risk customers', () async {
        final atRisk = CustomerAccount(
          accountId: 'acc_001',
          companyName: 'AtRisk Corp',
          healthStatus: CustomerHealthStatus.atRisk,
          contractValue: 50000,
          segment: 'Mid',
          lastCheckInDate: DateTime.now(),
        );
        await repository.createCustomerAccount(atRisk);
        final result = await repository.getAtRiskCustomers();
        expect(result.length, greaterThan(0));
      });

      test('Get high value customers', () async {
        final highValue = CustomerAccount(
          accountId: 'acc_001',
          companyName: 'High Value Corp',
          healthStatus: CustomerHealthStatus.healthy,
          contractValue: 500000,
          segment: 'Enterprise',
          lastCheckInDate: DateTime.now(),
        );
        await repository.createCustomerAccount(highValue);
        final result = await repository.getHighValueCustomers();
        expect(result.length, greaterThan(0));
      });

      test('Update customer account', () async {
        var account = CustomerAccount(
          accountId: 'acc_001',
          companyName: 'Original',
          healthStatus: CustomerHealthStatus.healthy,
          contractValue: 100000,
          segment: 'Enterprise',
          lastCheckInDate: DateTime.now(),
        );
        await repository.createCustomerAccount(account);
        account = account.copyWith(
          companyName: 'Updated',
          healthStatus: CustomerHealthStatus.critical,
        );
        await repository.updateCustomerAccount(account);
        final retrieved = await repository.getCustomerAccount('acc_001');
        expect(retrieved?.companyName, 'Updated');
        expect(retrieved?.healthStatus, CustomerHealthStatus.critical);
      });

      test('Delete customer account', () async {
        final account = CustomerAccount(
          accountId: 'acc_001',
          companyName: 'Test',
          healthStatus: CustomerHealthStatus.healthy,
          contractValue: 100000,
          segment: 'Enterprise',
          lastCheckInDate: DateTime.now(),
        );
        await repository.createCustomerAccount(account);
        await repository.deleteCustomerAccount('acc_001');
        final retrieved = await repository.getCustomerAccount('acc_001');
        expect(retrieved, isNull);
      });

      test('Get customer account count', () async {
        final acc1 = CustomerAccount(
          accountId: 'acc_001',
          companyName: 'Corp 1',
          healthStatus: CustomerHealthStatus.healthy,
          contractValue: 100000,
          segment: 'Enterprise',
          lastCheckInDate: DateTime.now(),
        );
        await repository.createCustomerAccount(acc1);
        final count = await repository.getCustomerAccountCount();
        expect(count, 1);
      });
    });

    group('Repository Tests - Health Scores', () {
      test('Create and retrieve health score', () async {
        final score = HealthScore(
          scoreId: 'hs_001',
          accountId: 'acc_001',
          overallScore: 85.0,
          adoptionScore: 90.0,
          usageScore: 80.0,
          engagementScore: 85.0,
          satisfactionScore: 82.0,
          measuredDate: DateTime.now(),
        );
        await repository.createHealthScore(score);
        final retrieved = await repository.getHealthScore('hs_001');
        expect(retrieved, isNotNull);
        expect(retrieved?.overallScore, 85.0);
      });

      test('Get latest health score for account', () async {
        final oldScore = HealthScore(
          scoreId: 'hs_001',
          accountId: 'acc_001',
          overallScore: 75.0,
          adoptionScore: 70.0,
          usageScore: 75.0,
          engagementScore: 75.0,
          satisfactionScore: 75.0,
          measuredDate: DateTime.now().subtract(Duration(days: 1)),
        );
        final newScore = HealthScore(
          scoreId: 'hs_002',
          accountId: 'acc_001',
          overallScore: 85.0,
          adoptionScore: 90.0,
          usageScore: 80.0,
          engagementScore: 85.0,
          satisfactionScore: 82.0,
          measuredDate: DateTime.now(),
        );
        await repository.createHealthScore(oldScore);
        await repository.createHealthScore(newScore);
        final latest = await repository.getLatestHealthScoreForAccount('acc_001');
        expect(latest?.scoreId, 'hs_002');
      });

      test('Get good health scores', () async {
        final goodScore = HealthScore(
          scoreId: 'hs_001',
          accountId: 'acc_001',
          overallScore: 85.0,
          adoptionScore: 90.0,
          usageScore: 80.0,
          engagementScore: 85.0,
          satisfactionScore: 82.0,
          measuredDate: DateTime.now(),
        );
        await repository.createHealthScore(goodScore);
        final result = await repository.getGoodHealthScores();
        expect(result.length, greaterThan(0));
      });

      test('Get average health score', () async {
        final score1 = HealthScore(
          scoreId: 'hs_001',
          accountId: 'acc_001',
          overallScore: 80.0,
          adoptionScore: 80.0,
          usageScore: 80.0,
          engagementScore: 80.0,
          satisfactionScore: 80.0,
          measuredDate: DateTime.now(),
        );
        final score2 = HealthScore(
          scoreId: 'hs_002',
          accountId: 'acc_002',
          overallScore: 90.0,
          adoptionScore: 90.0,
          usageScore: 90.0,
          engagementScore: 90.0,
          satisfactionScore: 90.0,
          measuredDate: DateTime.now(),
        );
        await repository.createHealthScore(score1);
        await repository.createHealthScore(score2);
        final avg = await repository.getAverageHealthScore();
        expect(avg, 85.0);
      });
    });

    group('Repository Tests - Churn Predictions', () {
      test('Create and retrieve churn prediction', () async {
        final prediction = ChurnPrediction(
          predictionId: 'cp_001',
          accountId: 'acc_001',
          churnProbability: 0.85,
          riskLevel: ChurnRiskLevel.high,
          predictedChurnDate: DateTime.now().add(Duration(days: 30)),
          signals: ['low_usage'],
          predictionDate: DateTime.now(),
        );
        await repository.createChurnPrediction(prediction);
        final retrieved = await repository.getChurnPrediction('cp_001');
        expect(retrieved, isNotNull);
        expect(retrieved?.churnProbability, 0.85);
      });

      test('Get urgent churn predictions', () async {
        final urgent = ChurnPrediction(
          predictionId: 'cp_001',
          accountId: 'acc_001',
          churnProbability: 0.95,
          riskLevel: ChurnRiskLevel.imminent,
          predictedChurnDate: DateTime.now().add(Duration(days: 5)),
          signals: ['very_low_usage', 'support_tickets'],
          predictionDate: DateTime.now(),
        );
        await repository.createChurnPrediction(urgent);
        final result = await repository.getUrgentChurnPredictions();
        expect(result.length, greaterThan(0));
      });

      test('Get high risk predictions', () async {
        final highRisk = ChurnPrediction(
          predictionId: 'cp_001',
          accountId: 'acc_001',
          churnProbability: 0.92,
          riskLevel: ChurnRiskLevel.veryHigh,
          predictedChurnDate: DateTime.now().add(Duration(days: 20)),
          signals: ['declining_usage'],
          predictionDate: DateTime.now(),
        );
        await repository.createChurnPrediction(highRisk);
        final result = await repository.getHighRiskPredictions();
        expect(result.length, greaterThan(0));
      });
    });

    group('Repository Tests - Renewal Info', () {
      test('Create and retrieve renewal info', () async {
        final renewal = RenewalInfo(
          renewalId: 'ren_001',
          accountId: 'acc_001',
          renewalDate: DateTime.now().add(Duration(days: 90)),
          status: RenewalStatus.upcoming,
          contractValue: 150000,
          lastRenewalDate: DateTime.now().subtract(Duration(days: 365)),
        );
        await repository.createRenewalInfo(renewal);
        final retrieved = await repository.getRenewalInfo('ren_001');
        expect(retrieved, isNotNull);
        expect(retrieved?.status, RenewalStatus.upcoming);
      });

      test('Get upcoming renewals', () async {
        final renewal = RenewalInfo(
          renewalId: 'ren_001',
          accountId: 'acc_001',
          renewalDate: DateTime.now().add(Duration(days: 45)),
          status: RenewalStatus.upcoming,
          contractValue: 150000,
          lastRenewalDate: DateTime.now().subtract(Duration(days: 365)),
        );
        await repository.createRenewalInfo(renewal);
        final result = await repository.getUpcomingRenewals(Duration(days: 90));
        expect(result.length, greaterThan(0));
      });

      test('Get renewal confirmation rate', () async {
        final confirmed = RenewalInfo(
          renewalId: 'ren_001',
          accountId: 'acc_001',
          renewalDate: DateTime.now().add(Duration(days: 90)),
          status: RenewalStatus.confirmed,
          contractValue: 150000,
          lastRenewalDate: DateTime.now().subtract(Duration(days: 365)),
        );
        final pending = RenewalInfo(
          renewalId: 'ren_002',
          accountId: 'acc_002',
          renewalDate: DateTime.now().add(Duration(days: 60)),
          status: RenewalStatus.pending,
          contractValue: 100000,
          lastRenewalDate: DateTime.now().subtract(Duration(days: 365)),
        );
        await repository.createRenewalInfo(confirmed);
        await repository.createRenewalInfo(pending);
        final rate = await repository.getRenewalConfirmationRate();
        expect(rate, greaterThan(0));
      });
    });

    group('Repository Tests - Expansion Plans', () {
      test('Create and retrieve expansion plan', () async {
        final plan = ExpansionPlan(
          planId: 'exp_001',
          accountId: 'acc_001',
          opportunity: ExpansionOpportunity.upsell,
          expectedValue: 75000,
          targetDate: DateTime.now().add(Duration(days: 90)),
          status: 'planning',
        );
        await repository.createExpansionPlan(plan);
        final retrieved = await repository.getExpansionPlan('exp_001');
        expect(retrieved, isNotNull);
        expect(retrieved?.opportunity, ExpansionOpportunity.upsell);
      });

      test('Get high value expansion plans', () async {
        final highValue = ExpansionPlan(
          planId: 'exp_001',
          accountId: 'acc_001',
          opportunity: ExpansionOpportunity.premiumTier,
          expectedValue: 100000,
          targetDate: DateTime.now().add(Duration(days: 90)),
          status: 'planning',
        );
        await repository.createExpansionPlan(highValue);
        final result = await repository.getHighValueExpansionPlans(50000);
        expect(result.length, greaterThan(0));
      });

      test('Get total expected expansion value', () async {
        final plan1 = ExpansionPlan(
          planId: 'exp_001',
          accountId: 'acc_001',
          opportunity: ExpansionOpportunity.upsell,
          expectedValue: 50000,
          targetDate: DateTime.now().add(Duration(days: 90)),
          status: 'planning',
        );
        final plan2 = ExpansionPlan(
          planId: 'exp_002',
          accountId: 'acc_002',
          opportunity: ExpansionOpportunity.crossSell,
          expectedValue: 30000,
          targetDate: DateTime.now().add(Duration(days: 60)),
          status: 'planning',
        );
        await repository.createExpansionPlan(plan1);
        await repository.createExpansionPlan(plan2);
        final total = await repository.getTotalExpectedExpansionValue();
        expect(total, 80000);
      });
    });

    group('Repository Tests - Customer Engagement', () {
      test('Create and retrieve customer engagement', () async {
        final engagement = CustomerEngagement(
          engagementId: 'eng_001',
          accountId: 'acc_001',
          engagementType: 'meeting',
          lastInteractionDate: DateTime.now(),
          engagementScore: 0.9,
        );
        await repository.createCustomerEngagement(engagement);
        final retrieved = await repository.getCustomerEngagement('eng_001');
        expect(retrieved, isNotNull);
        expect(retrieved?.engagementType, 'meeting');
      });

      test('Get recent engagements', () async {
        final engagement = CustomerEngagement(
          engagementId: 'eng_001',
          accountId: 'acc_001',
          engagementType: 'call',
          lastInteractionDate: DateTime.now().subtract(Duration(days: 2)),
          engagementScore: 0.85,
        );
        await repository.createCustomerEngagement(engagement);
        final result =
            await repository.getRecentEngagements(Duration(days: 7));
        expect(result.length, greaterThan(0));
      });

      test('Get average engagement score', () async {
        final eng1 = CustomerEngagement(
          engagementId: 'eng_001',
          accountId: 'acc_001',
          engagementType: 'meeting',
          lastInteractionDate: DateTime.now(),
          engagementScore: 0.8,
        );
        final eng2 = CustomerEngagement(
          engagementId: 'eng_002',
          accountId: 'acc_002',
          engagementType: 'email',
          lastInteractionDate: DateTime.now(),
          engagementScore: 0.9,
        );
        await repository.createCustomerEngagement(eng1);
        await repository.createCustomerEngagement(eng2);
        final avg = await repository.getAverageEngagementScore();
        expect(avg, 0.85);
      });
    });

    group('Repository Tests - Success Reports', () {
      test('Create and retrieve success report', () async {
        final report = SuccessReport(
          reportId: 'sr_001',
          accountId: 'acc_001',
          overallHealthScore: 85.0,
          npsScore: 75,
          criticalIssues: [],
          recommendations: [],
          generatedDate: DateTime.now(),
        );
        await repository.createSuccessReport(report);
        final retrieved = await repository.getSuccessReport('sr_001');
        expect(retrieved, isNotNull);
        expect(retrieved?.overallHealthScore, 85.0);
      });

      test('Get healthy reports', () async {
        final report = SuccessReport(
          reportId: 'sr_001',
          accountId: 'acc_001',
          overallHealthScore: 82.0,
          npsScore: 70,
          criticalIssues: [],
          recommendations: [],
          generatedDate: DateTime.now(),
        );
        await repository.createSuccessReport(report);
        final result = await repository.getHealthyReports();
        expect(result.length, greaterThan(0));
      });
    });

    // ========================================================================
    // Engine Tests
    // ========================================================================

    group('Engine Tests - SuccessHealthEngine', () {
      test('Get accounts requiring attention', () async {
        final atRisk = CustomerAccount(
          accountId: 'acc_001',
          companyName: 'AtRisk Corp',
          healthStatus: CustomerHealthStatus.atRisk,
          contractValue: 50000,
          segment: 'Mid',
          lastCheckInDate: DateTime.now().subtract(Duration(days: 50)),
        );
        await repository.createCustomerAccount(atRisk);
        final engine = SuccessHealthEngine(repository);
        final result = await engine.getAccountsRequiringAttention();
        expect(result.length, greaterThan(0));
      });

      test('Calculate health metrics', () async {
        final score = HealthScore(
          scoreId: 'hs_001',
          accountId: 'acc_001',
          overallScore: 85.0,
          adoptionScore: 90.0,
          usageScore: 80.0,
          engagementScore: 85.0,
          satisfactionScore: 82.0,
          measuredDate: DateTime.now(),
        );
        await repository.createHealthScore(score);
        final engine = SuccessHealthEngine(repository);
        final metrics = await engine.calculateHealthMetrics();
        expect(metrics, 85.0);
      });

      test('Get health status distribution', () async {
        final healthy = CustomerAccount(
          accountId: 'acc_001',
          companyName: 'Healthy',
          healthStatus: CustomerHealthStatus.healthy,
          contractValue: 100000,
          segment: 'Enterprise',
          lastCheckInDate: DateTime.now(),
        );
        final atRisk = CustomerAccount(
          accountId: 'acc_002',
          companyName: 'AtRisk',
          healthStatus: CustomerHealthStatus.atRisk,
          contractValue: 50000,
          segment: 'Mid',
          lastCheckInDate: DateTime.now(),
        );
        await repository.createCustomerAccount(healthy);
        await repository.createCustomerAccount(atRisk);
        final engine = SuccessHealthEngine(repository);
        final dist = await engine.getHealthStatusDistribution();
        expect(dist.keys.length, greaterThan(0));
      });
    });

    group('Engine Tests - ChurnPreventionEngine', () {
      test('Get imminent churn risks', () async {
        final prediction = ChurnPrediction(
          predictionId: 'cp_001',
          accountId: 'acc_001',
          churnProbability: 0.95,
          riskLevel: ChurnRiskLevel.imminent,
          predictedChurnDate: DateTime.now().add(Duration(days: 3)),
          signals: ['critical_issue'],
          predictionDate: DateTime.now(),
        );
        await repository.createChurnPrediction(prediction);
        final engine = ChurnPreventionEngine(repository);
        final risks = await engine.getImminentChurnRisks();
        expect(risks.length, greaterThan(0));
      });

      test('Create retention interventions', () async {
        final prediction = ChurnPrediction(
          predictionId: 'cp_001',
          accountId: 'acc_001',
          churnProbability: 0.9,
          riskLevel: ChurnRiskLevel.veryHigh,
          predictedChurnDate: DateTime.now().add(Duration(days: 15)),
          signals: ['declining_engagement'],
          predictionDate: DateTime.now(),
        );
        await repository.createChurnPrediction(prediction);
        final engine = ChurnPreventionEngine(repository);
        await engine.createRetentionInterventions([prediction]);
        final engagements =
            await repository.getEngagementsForAccount('acc_001');
        expect(engagements.length, greaterThan(0));
      });
    });

    group('Engine Tests - RenewalOptimizationEngine', () {
      test('Get upcoming renewals needing action', () async {
        final renewal = RenewalInfo(
          renewalId: 'ren_001',
          accountId: 'acc_001',
          renewalDate: DateTime.now().add(Duration(days: 60)),
          status: RenewalStatus.upcoming,
          contractValue: 150000,
          lastRenewalDate: DateTime.now().subtract(Duration(days: 365)),
        );
        await repository.createRenewalInfo(renewal);
        final engine = RenewalOptimizationEngine(repository);
        final renewals = await engine.getUpcomingRenewalsNeedingAction();
        expect(renewals.length, greaterThan(0));
      });

      test('Get renewal pipeline', () async {
        final renewal = RenewalInfo(
          renewalId: 'ren_001',
          accountId: 'acc_001',
          renewalDate: DateTime.now().add(Duration(days: 90)),
          status: RenewalStatus.confirmed,
          contractValue: 200000,
          lastRenewalDate: DateTime.now().subtract(Duration(days: 365)),
        );
        await repository.createRenewalInfo(renewal);
        final engine = RenewalOptimizationEngine(repository);
        final pipeline = await engine.getRenewalPipeline();
        expect(pipeline, greaterThan(0));
      });
    });

    group('Engine Tests - ExpansionEngine', () {
      test('Get high value expansion opportunities', () async {
        final plan = ExpansionPlan(
          planId: 'exp_001',
          accountId: 'acc_001',
          opportunity: ExpansionOpportunity.premiumTier,
          expectedValue: 100000,
          targetDate: DateTime.now().add(Duration(days: 60)),
          status: 'planning',
        );
        await repository.createExpansionPlan(plan);
        final engine = ExpansionEngine(repository);
        final opportunities = await engine.getHighValueExpansionOpportunities();
        expect(opportunities.length, greaterThan(0));
      });

      test('Get total expansion revenue potential', () async {
        final plan1 = ExpansionPlan(
          planId: 'exp_001',
          accountId: 'acc_001',
          opportunity: ExpansionOpportunity.upsell,
          expectedValue: 50000,
          targetDate: DateTime.now().add(Duration(days: 90)),
          status: 'planning',
        );
        final plan2 = ExpansionPlan(
          planId: 'exp_002',
          accountId: 'acc_002',
          opportunity: ExpansionOpportunity.additionalSeats,
          expectedValue: 30000,
          targetDate: DateTime.now().add(Duration(days: 60)),
          status: 'planning',
        );
        await repository.createExpansionPlan(plan1);
        await repository.createExpansionPlan(plan2);
        final engine = ExpansionEngine(repository);
        final potential = await engine.getTotalExpansionRevenuePotential();
        expect(potential, 80000);
      });
    });

    group('Engine Tests - EngagementEngine', () {
      test('Get overall engagement score', () async {
        final eng = CustomerEngagement(
          engagementId: 'eng_001',
          accountId: 'acc_001',
          engagementType: 'call',
          lastInteractionDate: DateTime.now(),
          engagementScore: 0.9,
        );
        await repository.createCustomerEngagement(eng);
        final engine = EngagementEngine(repository);
        final score = await engine.getOverallEngagementScore();
        expect(score, 0.9);
      });

      test('Record customer interaction', () async {
        final engine = EngagementEngine(repository);
        await engine.recordCustomerInteraction('acc_001', 'meeting');
        final engagements =
            await repository.getEngagementsForAccount('acc_001');
        expect(engagements.length, greaterThan(0));
      });
    });

    // ========================================================================
    // Manager Tests
    // ========================================================================

    group('Manager Tests', () {
      test('Generate comprehensive success report', () async {
        final account = CustomerAccount(
          accountId: 'acc_001',
          companyName: 'Test Corp',
          healthStatus: CustomerHealthStatus.healthy,
          contractValue: 100000,
          segment: 'Enterprise',
          lastCheckInDate: DateTime.now(),
        );
        await repository.createCustomerAccount(account);
        final manager = SuccessManager(repository);
        final report = await manager.generateComprehensiveSuccessReport();
        expect(report.containsKey('healthScore'), true);
        expect(report.containsKey('renewalRate'), true);
        expect(report.containsKey('expansionPotential'), true);
      });
    });

    // ========================================================================
    // Facade Tests
    // ========================================================================

    group('Facade Tests', () {
      test('Add and get customer account', () async {
        final account = CustomerAccount(
          accountId: 'acc_001',
          companyName: 'Test Corp',
          healthStatus: CustomerHealthStatus.healthy,
          contractValue: 100000,
          segment: 'Enterprise',
          lastCheckInDate: DateTime.now(),
        );
        await facade.addCustomerAccount(account);
        final retrieved = await facade.getCustomer('acc_001');
        expect(retrieved?.companyName, 'Test Corp');
      });

      test('Get customers needing attention', () async {
        final account = CustomerAccount(
          accountId: 'acc_001',
          companyName: 'AtRisk Corp',
          healthStatus: CustomerHealthStatus.atRisk,
          contractValue: 50000,
          segment: 'Mid',
          lastCheckInDate: DateTime.now().subtract(Duration(days: 45)),
        );
        await repository.createCustomerAccount(account);
        final result = await facade.getCustomersNeedingAttention();
        expect(result.length, greaterThanOrEqualTo(0));
      });

      test('Get churn alerts', () async {
        final prediction = ChurnPrediction(
          predictionId: 'cp_001',
          accountId: 'acc_001',
          churnProbability: 0.95,
          riskLevel: ChurnRiskLevel.imminent,
          predictedChurnDate: DateTime.now().add(Duration(days: 2)),
          signals: ['critical'],
          predictionDate: DateTime.now(),
        );
        await repository.createChurnPrediction(prediction);
        final alerts = await facade.getChurnAlerts();
        expect(alerts.length, greaterThan(0));
      });

      test('Get upcoming renewals', () async {
        final renewal = RenewalInfo(
          renewalId: 'ren_001',
          accountId: 'acc_001',
          renewalDate: DateTime.now().add(Duration(days: 45)),
          status: RenewalStatus.upcoming,
          contractValue: 150000,
          lastRenewalDate: DateTime.now().subtract(Duration(days: 365)),
        );
        await repository.createRenewalInfo(renewal);
        final renewals = await facade.getUpcomingRenewals();
        expect(renewals.length, greaterThan(0));
      });

      test('Get expansion opportunities', () async {
        final plan = ExpansionPlan(
          planId: 'exp_001',
          accountId: 'acc_001',
          opportunity: ExpansionOpportunity.upsell,
          expectedValue: 75000,
          targetDate: DateTime.now().add(Duration(days: 60)),
          status: 'planning',
        );
        await repository.createExpansionPlan(plan);
        final opportunities = await facade.getExpansionOpportunities();
        expect(opportunities.length, greaterThan(0));
      });

      test('Record interaction', () async {
        await facade.recordInteraction('acc_001', 'meeting');
        final engagements =
            await repository.getEngagementsForAccount('acc_001');
        expect(engagements.length, greaterThan(0));
      });

      test('Get engagement score', () async {
        final eng = CustomerEngagement(
          engagementId: 'eng_001',
          accountId: 'acc_001',
          engagementType: 'call',
          lastInteractionDate: DateTime.now(),
          engagementScore: 0.85,
        );
        await repository.createCustomerEngagement(eng);
        final score = await facade.getEngagementScore();
        expect(score, greaterThan(0));
      });

      test('Get dashboard', () async {
        final account = CustomerAccount(
          accountId: 'acc_001',
          companyName: 'Dashboard Test',
          healthStatus: CustomerHealthStatus.healthy,
          contractValue: 100000,
          segment: 'Enterprise',
          lastCheckInDate: DateTime.now(),
        );
        await repository.createCustomerAccount(account);
        final dashboard = await facade.getDashboard();
        expect(dashboard.isNotEmpty, true);
        expect(dashboard.containsKey('healthScore'), true);
      });
    });

    // ========================================================================
    // Integration Tests
    // ========================================================================

    group('Integration Tests', () {
      test('Complete customer success workflow', () async {
        // Create account
        final account = CustomerAccount(
          accountId: 'acc_integration_001',
          companyName: 'Integration Test Corp',
          healthStatus: CustomerHealthStatus.healthy,
          contractValue: 250000,
          segment: 'Enterprise',
          lastCheckInDate: DateTime.now(),
        );
        await facade.addCustomerAccount(account);

        // Record health score
        final healthScore = HealthScore(
          scoreId: 'hs_int_001',
          accountId: 'acc_integration_001',
          overallScore: 82.0,
          adoptionScore: 85.0,
          usageScore: 80.0,
          engagementScore: 82.0,
          satisfactionScore: 80.0,
          measuredDate: DateTime.now(),
        );
        await repository.createHealthScore(healthScore);

        // Create renewal
        final renewal = RenewalInfo(
          renewalId: 'ren_int_001',
          accountId: 'acc_integration_001',
          renewalDate: DateTime.now().add(Duration(days: 120)),
          status: RenewalStatus.upcoming,
          contractValue: 250000,
          lastRenewalDate: DateTime.now().subtract(Duration(days: 365)),
        );
        await repository.createRenewalInfo(renewal);

        // Create expansion plan
        final expansion = ExpansionPlan(
          planId: 'exp_int_001',
          accountId: 'acc_integration_001',
          opportunity: ExpansionOpportunity.upsell,
          expectedValue: 100000,
          targetDate: DateTime.now().add(Duration(days: 90)),
          status: 'planning',
        );
        await repository.createExpansionPlan(expansion);

        // Get comprehensive dashboard
        final dashboard = await facade.getDashboard();
        expect(dashboard['healthScore'], isNotNull);
        expect(dashboard['expansionPotential'], greaterThan(0));
      });

      test('Churn prevention workflow', () async {
        // Create at-risk account
        final account = CustomerAccount(
          accountId: 'acc_churn_001',
          companyName: 'Churn Risk Corp',
          healthStatus: CustomerHealthStatus.critical,
          contractValue: 100000,
          segment: 'Mid',
          lastCheckInDate: DateTime.now().subtract(Duration(days: 60)),
        );
        await repository.createCustomerAccount(account);

        // Create churn prediction
        final prediction = ChurnPrediction(
          predictionId: 'cp_churn_001',
          accountId: 'acc_churn_001',
          churnProbability: 0.92,
          riskLevel: ChurnRiskLevel.veryHigh,
          predictedChurnDate: DateTime.now().add(Duration(days: 14)),
          signals: ['low_usage', 'support_tickets', 'no_engagement'],
          predictionDate: DateTime.now(),
        );
        await repository.createChurnPrediction(prediction);

        // Get alerts
        final alerts = await facade.getChurnAlerts();
        expect(alerts.isNotEmpty, true);

        // Initialize prevention program
        await facade.initializeChurnPreventionProgram();
        final engagements =
            await repository.getEngagementsForAccount('acc_churn_001');
        expect(engagements.isNotEmpty, true);
      });
    });
  });
}
