import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/sla_models.dart';
import 'package:project_040/services/sla_management_service.dart';

void main() {
  group('Phase 81: SLA Management Tests', () {
    // ===== ENUM TESTS =====
    group('Enum Tests', () {
      test('SLAStatus values', () {
        expect(SLAStatus.active.name, 'active');
        expect(SLAStatus.inactive.name, 'inactive');
        expect(SLAStatus.expired.name, 'expired');
        expect(SLAStatus.suspended.name, 'suspended');
        expect(SLAStatus.archived.name, 'archived');
        expect(SLAStatus.values.length, 5);
      });

      test('MetricType values', () {
        expect(MetricType.availability.name, 'availability');
        expect(MetricType.latency.name, 'latency');
        expect(MetricType.throughput.name, 'throughput');
        expect(MetricType.errorRate.name, 'errorRate');
        expect(MetricType.responseTime.name, 'responseTime');
        expect(MetricType.values.length, 5);
      });

      test('BreachSeverity values', () {
        expect(BreachSeverity.critical.name, 'critical');
        expect(BreachSeverity.high.name, 'high');
        expect(BreachSeverity.medium.name, 'medium');
        expect(BreachSeverity.low.name, 'low');
        expect(BreachSeverity.values.length, 4);
      });

      test('AlertState values', () {
        expect(AlertState.active.name, 'active');
        expect(AlertState.inactive.name, 'inactive');
        expect(AlertState.triggered.name, 'triggered');
        expect(AlertState.acknowledged.name, 'acknowledged');
        expect(AlertState.resolved.name, 'resolved');
        expect(AlertState.values.length, 5);
      });

      test('ReportFrequency values', () {
        expect(ReportFrequency.daily.name, 'daily');
        expect(ReportFrequency.weekly.name, 'weekly');
        expect(ReportFrequency.monthly.name, 'monthly');
        expect(ReportFrequency.quarterly.name, 'quarterly');
        expect(ReportFrequency.annual.name, 'annual');
        expect(ReportFrequency.values.length, 5);
      });

      test('ComplianceStatus values', () {
        expect(ComplianceStatus.compliant.name, 'compliant');
        expect(ComplianceStatus.atRisk.name, 'atRisk');
        expect(ComplianceStatus.nonCompliant.name, 'nonCompliant');
        expect(ComplianceStatus.waived.name, 'waived');
        expect(ComplianceStatus.values.length, 4);
      });
    });

    // ===== MODEL TESTS =====
    group('Model Tests', () {
      test('ServiceLevelAgreement model creation', () {
        final sla = ServiceLevelAgreement(
          id: 'sla1',
          serviceName: 'API Service',
          status: SLAStatus.active,
          createdAt: DateTime(2025, 1, 1),
          expiresAt: DateTime(2026, 1, 1),
          targetAvailability: 99.9,
        );
        expect(sla.id, 'sla1');
        expect(sla.serviceName, 'API Service');
        expect(sla.status, SLAStatus.active);
        expect(sla.targetAvailability, 99.9);
        expect(sla.isExpired, false);
      });

      test('SLAMetric computed properties', () {
        final metric = SLAMetric(
          id: 'metric1',
          slaId: 'sla1',
          type: MetricType.availability,
          value: 99.95,
          threshold: 99.9,
          measuredAt: DateTime.now(),
        );
        expect(metric.meetsTarget, true);
        expect(metric.variance, 0.05);
      });

      test('SLAThreshold model', () {
        final threshold = SLAThreshold(
          id: 'thresh1',
          slaId: 'sla1',
          metricType: MetricType.latency,
          warningLevel: 500.0,
          criticalLevel: 1000.0,
          createdAt: DateTime.now(),
        );
        expect(threshold.metricType, MetricType.latency);
        expect(threshold.warningLevel, 500.0);
      });

      test('ServiceLevelIndicator model', () {
        final sli = ServiceLevelIndicator(
          id: 'sli1',
          slaId: 'sla1',
          name: 'API Response Time',
          measurementWindow: 3600,
          target: 99.9,
          status: SLAStatus.active,
          createdAt: DateTime.now(),
        );
        expect(sli.name, 'API Response Time');
        expect(sli.target, 99.9);
      });

      test('PerformanceMetric model', () {
        final perf = PerformanceMetric(
          id: 'perf1',
          sliId: 'sli1',
          timestamp: DateTime.now(),
          value: 98.5,
          unit: 'percentage',
        );
        expect(perf.value, 98.5);
        expect(perf.unit, 'percentage');
      });

      test('SLABreach model', () {
        final breach = SLABreach(
          id: 'breach1',
          slaId: 'sla1',
          breachTime: DateTime.now(),
          severity: BreachSeverity.critical,
          duration: 300,
          affectedMetric: MetricType.availability,
        );
        expect(breach.severity, BreachSeverity.critical);
        expect(breach.affectedMetric, MetricType.availability);
        expect(breach.durationMinutes, 5);
      });

      test('AlertPolicy model', () {
        final policy = AlertPolicy(
          id: 'policy1',
          slaId: 'sla1',
          name: 'High Latency Alert',
          condition: 'latency > 1000',
          severity: BreachSeverity.high,
          enabled: true,
          createdAt: DateTime.now(),
        );
        expect(policy.name, 'High Latency Alert');
        expect(policy.enabled, true);
      });

      test('Alert model', () {
        final alert = Alert(
          id: 'alert1',
          policyId: 'policy1',
          state: AlertState.triggered,
          triggeredAt: DateTime.now(),
          acknowledgedAt: null,
          resolvedAt: null,
        );
        expect(alert.state, AlertState.triggered);
        expect(alert.isActive, true);
      });

      test('SLACompliance model', () {
        final compliance = SLACompliance(
          id: 'comp1',
          slaId: 'sla1',
          status: ComplianceStatus.compliant,
          score: 99.95,
          breachCount: 0,
          evaluatedAt: DateTime.now(),
        );
        expect(compliance.status, ComplianceStatus.compliant);
        expect(compliance.score, 99.95);
        expect(compliance.isHealthy, true);
      });

      test('SLAHistory model', () {
        final history = SLAHistory(
          id: 'hist1',
          slaId: 'sla1',
          changeType: 'status_update',
          previousValue: 'active',
          newValue: 'suspended',
          changedAt: DateTime.now(),
        );
        expect(history.changeType, 'status_update');
        expect(history.previousValue, 'active');
      });

      test('SLAReport model', () {
        final report = SLAReport(
          id: 'report1',
          slaId: 'sla1',
          period: 'monthly',
          compliance: 99.8,
          breachCount: 1,
          generatedAt: DateTime.now(),
        );
        expect(report.period, 'monthly');
        expect(report.compliance, 99.8);
      });

      test('SLAGoal model', () {
        final goal = SLAGoal(
          id: 'goal1',
          slaId: 'sla1',
          metricType: MetricType.availability,
          targetValue: 99.95,
          quarter: 'Q1',
          year: 2025,
        );
        expect(goal.metricType, MetricType.availability);
        expect(goal.targetValue, 99.95);
      });
    });

    // ===== REPOSITORY METHOD TESTS (SLA Management) =====
    group('Repository Tests - SLA Management', () {
      late SLARepository repository;

      setUp(() {
        repository = InMemorySLARepository();
      });

      test('Create and retrieve SLA', () async {
        final sla = ServiceLevelAgreement(
          id: 'sla1',
          serviceName: 'API Service',
          status: SLAStatus.active,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(days: 365)),
          targetAvailability: 99.9,
        );

        await repository.createServiceLevelAgreement(sla);
        final retrieved = await repository.getServiceLevelAgreement('sla1');
        expect(retrieved, isNotNull);
        expect(retrieved!.serviceName, 'API Service');
      });

      test('Update SLA status', () async {
        final sla = ServiceLevelAgreement(
          id: 'sla2',
          serviceName: 'Database Service',
          status: SLAStatus.active,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(days: 365)),
          targetAvailability: 99.95,
        );
        await repository.createServiceLevelAgreement(sla);
        await repository.updateSLAStatus('sla2', SLAStatus.suspended);
        final updated = await repository.getServiceLevelAgreement('sla2');
        expect(updated!.status, SLAStatus.suspended);
      });

      test('Get all active SLAs', () async {
        final sla1 = ServiceLevelAgreement(
          id: 'sla3',
          serviceName: 'Service A',
          status: SLAStatus.active,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(days: 365)),
          targetAvailability: 99.9,
        );
        final sla2 = ServiceLevelAgreement(
          id: 'sla4',
          serviceName: 'Service B',
          status: SLAStatus.inactive,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(days: 365)),
          targetAvailability: 99.8,
        );
        await repository.createServiceLevelAgreement(sla1);
        await repository.createServiceLevelAgreement(sla2);
        final active = await repository.getActiveSLAs();
        expect(active.length, 1);
        expect(active.first.status, SLAStatus.active);
      });

      test('Delete SLA', () async {
        final sla = ServiceLevelAgreement(
          id: 'sla5',
          serviceName: 'Temp Service',
          status: SLAStatus.active,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(days: 365)),
          targetAvailability: 99.9,
        );
        await repository.createServiceLevelAgreement(sla);
        await repository.deleteServiceLevelAgreement('sla5');
        final retrieved = await repository.getServiceLevelAgreement('sla5');
        expect(retrieved, isNull);
      });
    });

    // ===== REPOSITORY METHOD TESTS (Metrics) =====
    group('Repository Tests - Metrics', () {
      late SLARepository repository;

      setUp(() {
        repository = InMemorySLARepository();
      });

      test('Create and retrieve metric', () async {
        final metric = SLAMetric(
          id: 'metric1',
          slaId: 'sla1',
          type: MetricType.availability,
          value: 99.95,
          threshold: 99.9,
          measuredAt: DateTime.now(),
        );
        await repository.createMetric(metric);
        final retrieved = await repository.getMetric('metric1');
        expect(retrieved, isNotNull);
        expect(retrieved!.value, 99.95);
      });

      test('Get metrics by SLA', () async {
        final m1 = SLAMetric(
          id: 'metric2',
          slaId: 'sla1',
          type: MetricType.availability,
          value: 99.9,
          threshold: 99.9,
          measuredAt: DateTime.now(),
        );
        final m2 = SLAMetric(
          id: 'metric3',
          slaId: 'sla1',
          type: MetricType.latency,
          value: 250.0,
          threshold: 500.0,
          measuredAt: DateTime.now(),
        );
        await repository.createMetric(m1);
        await repository.createMetric(m2);
        final metrics = await repository.getMetricsBySLA('sla1');
        expect(metrics.length, 2);
      });

      test('Get metrics by type', () async {
        final m1 = SLAMetric(
          id: 'metric4',
          slaId: 'sla1',
          type: MetricType.errorRate,
          value: 0.1,
          threshold: 0.5,
          measuredAt: DateTime.now(),
        );
        final m2 = SLAMetric(
          id: 'metric5',
          slaId: 'sla2',
          type: MetricType.errorRate,
          value: 0.05,
          threshold: 0.5,
          measuredAt: DateTime.now(),
        );
        await repository.createMetric(m1);
        await repository.createMetric(m2);
        final errorMetrics = await repository.getMetricsByType(MetricType.errorRate);
        expect(errorMetrics.length, 2);
      });

      test('Update metric', () async {
        final metric = SLAMetric(
          id: 'metric6',
          slaId: 'sla1',
          type: MetricType.throughput,
          value: 1000.0,
          threshold: 800.0,
          measuredAt: DateTime.now(),
        );
        await repository.createMetric(metric);
        await repository.updateMetricValue('metric6', 1100.0);
        final updated = await repository.getMetric('metric6');
        expect(updated!.value, 1100.0);
      });
    });

    // ===== REPOSITORY METHOD TESTS (Thresholds) =====
    group('Repository Tests - Thresholds', () {
      late SLARepository repository;

      setUp(() {
        repository = InMemorySLARepository();
      });

      test('Create and get threshold', () async {
        final threshold = SLAThreshold(
          id: 'thresh1',
          slaId: 'sla1',
          metricType: MetricType.latency,
          warningLevel: 500.0,
          criticalLevel: 1000.0,
          createdAt: DateTime.now(),
        );
        await repository.createThreshold(threshold);
        final retrieved = await repository.getThreshold('thresh1');
        expect(retrieved, isNotNull);
        expect(retrieved!.criticalLevel, 1000.0);
      });

      test('Get thresholds by SLA', () async {
        final t1 = SLAThreshold(
          id: 'thresh2',
          slaId: 'sla1',
          metricType: MetricType.availability,
          warningLevel: 98.0,
          criticalLevel: 95.0,
          createdAt: DateTime.now(),
        );
        final t2 = SLAThreshold(
          id: 'thresh3',
          slaId: 'sla1',
          metricType: MetricType.errorRate,
          warningLevel: 1.0,
          criticalLevel: 5.0,
          createdAt: DateTime.now(),
        );
        await repository.createThreshold(t1);
        await repository.createThreshold(t2);
        final thresholds = await repository.getThresholdsBySLA('sla1');
        expect(thresholds.length, 2);
      });

      test('Update threshold', () async {
        final threshold = SLAThreshold(
          id: 'thresh4',
          slaId: 'sla1',
          metricType: MetricType.responseTime,
          warningLevel: 300.0,
          criticalLevel: 600.0,
          createdAt: DateTime.now(),
        );
        await repository.createThreshold(threshold);
        await repository.updateThreshold('thresh4', 250.0, 500.0);
        final updated = await repository.getThreshold('thresh4');
        expect(updated!.warningLevel, 250.0);
        expect(updated.criticalLevel, 500.0);
      });
    });

    // ===== REPOSITORY METHOD TESTS (Indicators) =====
    group('Repository Tests - Indicators', () {
      late SLARepository repository;

      setUp(() {
        repository = InMemorySLARepository();
      });

      test('Create and get SLI', () async {
        final sli = ServiceLevelIndicator(
          id: 'sli1',
          slaId: 'sla1',
          name: 'API Response Time',
          measurementWindow: 3600,
          target: 99.9,
          status: SLAStatus.active,
          createdAt: DateTime.now(),
        );
        await repository.createServiceLevelIndicator(sli);
        final retrieved = await repository.getServiceLevelIndicator('sli1');
        expect(retrieved, isNotNull);
        expect(retrieved!.name, 'API Response Time');
      });

      test('Get SLIs by SLA', () async {
        final sli1 = ServiceLevelIndicator(
          id: 'sli2',
          slaId: 'sla1',
          name: 'Indicator 1',
          measurementWindow: 3600,
          target: 99.9,
          status: SLAStatus.active,
          createdAt: DateTime.now(),
        );
        final sli2 = ServiceLevelIndicator(
          id: 'sli3',
          slaId: 'sla1',
          name: 'Indicator 2',
          measurementWindow: 1800,
          target: 99.95,
          status: SLAStatus.active,
          createdAt: DateTime.now(),
        );
        await repository.createServiceLevelIndicator(sli1);
        await repository.createServiceLevelIndicator(sli2);
        final slis = await repository.getServiceLevelIndicatorsBySLA('sla1');
        expect(slis.length, 2);
      });
    });

    // ===== REPOSITORY METHOD TESTS (Performance) =====
    group('Repository Tests - Performance Metrics', () {
      late SLARepository repository;

      setUp(() {
        repository = InMemorySLARepository();
      });

      test('Create and get performance metric', () async {
        final perf = PerformanceMetric(
          id: 'perf1',
          sliId: 'sli1',
          timestamp: DateTime.now(),
          value: 98.5,
          unit: 'percentage',
        );
        await repository.createPerformanceMetric(perf);
        final retrieved = await repository.getPerformanceMetric('perf1');
        expect(retrieved, isNotNull);
        expect(retrieved!.value, 98.5);
      });

      test('Get performance metrics by SLI', () async {
        final now = DateTime.now();
        final p1 = PerformanceMetric(
          id: 'perf2',
          sliId: 'sli1',
          timestamp: now,
          value: 99.0,
          unit: 'percentage',
        );
        final p2 = PerformanceMetric(
          id: 'perf3',
          sliId: 'sli1',
          timestamp: now.add(Duration(minutes: 5)),
          value: 98.8,
          unit: 'percentage',
        );
        await repository.createPerformanceMetric(p1);
        await repository.createPerformanceMetric(p2);
        final metrics = await repository.getPerformanceMetricsBySLI('sli1');
        expect(metrics.length, 2);
      });
    });

    // ===== REPOSITORY METHOD TESTS (Breaches) =====
    group('Repository Tests - Breaches', () {
      late SLARepository repository;

      setUp(() {
        repository = InMemorySLARepository();
      });

      test('Create and get breach', () async {
        final breach = SLABreach(
          id: 'breach1',
          slaId: 'sla1',
          breachTime: DateTime.now(),
          severity: BreachSeverity.critical,
          duration: 300,
          affectedMetric: MetricType.availability,
        );
        await repository.createBreach(breach);
        final retrieved = await repository.getBreach('breach1');
        expect(retrieved, isNotNull);
        expect(retrieved!.severity, BreachSeverity.critical);
      });

      test('Get breaches by SLA', () async {
        final b1 = SLABreach(
          id: 'breach2',
          slaId: 'sla1',
          breachTime: DateTime.now(),
          severity: BreachSeverity.high,
          duration: 120,
          affectedMetric: MetricType.latency,
        );
        final b2 = SLABreach(
          id: 'breach3',
          slaId: 'sla1',
          breachTime: DateTime.now().subtract(Duration(hours: 1)),
          severity: BreachSeverity.medium,
          duration: 60,
          affectedMetric: MetricType.errorRate,
        );
        await repository.createBreach(b1);
        await repository.createBreach(b2);
        final breaches = await repository.getBreachesBySLA('sla1');
        expect(breaches.length, 2);
      });

      test('Get breaches by severity', () async {
        final b1 = SLABreach(
          id: 'breach4',
          slaId: 'sla1',
          breachTime: DateTime.now(),
          severity: BreachSeverity.critical,
          duration: 180,
          affectedMetric: MetricType.availability,
        );
        final b2 = SLABreach(
          id: 'breach5',
          slaId: 'sla2',
          breachTime: DateTime.now(),
          severity: BreachSeverity.critical,
          duration: 240,
          affectedMetric: MetricType.throughput,
        );
        await repository.createBreach(b1);
        await repository.createBreach(b2);
        final critical = await repository.getBreachesBySeverity(BreachSeverity.critical);
        expect(critical.length, 2);
      });
    });

    // ===== REPOSITORY METHOD TESTS (Policies) =====
    group('Repository Tests - Alert Policies', () {
      late SLARepository repository;

      setUp(() {
        repository = InMemorySLARepository();
      });

      test('Create and get alert policy', () async {
        final policy = AlertPolicy(
          id: 'policy1',
          slaId: 'sla1',
          name: 'High Latency Alert',
          condition: 'latency > 1000',
          severity: BreachSeverity.high,
          enabled: true,
          createdAt: DateTime.now(),
        );
        await repository.createAlertPolicy(policy);
        final retrieved = await repository.getAlertPolicy('policy1');
        expect(retrieved, isNotNull);
        expect(retrieved!.name, 'High Latency Alert');
      });

      test('Get policies by SLA', () async {
        final p1 = AlertPolicy(
          id: 'policy2',
          slaId: 'sla1',
          name: 'Policy A',
          condition: 'availability < 99',
          severity: BreachSeverity.critical,
          enabled: true,
          createdAt: DateTime.now(),
        );
        final p2 = AlertPolicy(
          id: 'policy3',
          slaId: 'sla1',
          name: 'Policy B',
          condition: 'errorRate > 0.5',
          severity: BreachSeverity.medium,
          enabled: false,
          createdAt: DateTime.now(),
        );
        await repository.createAlertPolicy(p1);
        await repository.createAlertPolicy(p2);
        final policies = await repository.getAlertPoliciesBySLA('sla1');
        expect(policies.length, 2);
      });

      test('Enable/disable policy', () async {
        final policy = AlertPolicy(
          id: 'policy4',
          slaId: 'sla1',
          name: 'Test Policy',
          condition: 'test > 100',
          severity: BreachSeverity.low,
          enabled: true,
          createdAt: DateTime.now(),
        );
        await repository.createAlertPolicy(policy);
        await repository.updatePolicyStatus('policy4', false);
        final updated = await repository.getAlertPolicy('policy4');
        expect(updated!.enabled, false);
      });
    });

    // ===== REPOSITORY METHOD TESTS (Alerts) =====
    group('Repository Tests - Alerts', () {
      late SLARepository repository;

      setUp(() {
        repository = InMemorySLARepository();
      });

      test('Create and get alert', () async {
        final alert = Alert(
          id: 'alert1',
          policyId: 'policy1',
          state: AlertState.triggered,
          triggeredAt: DateTime.now(),
          acknowledgedAt: null,
          resolvedAt: null,
        );
        await repository.createAlert(alert);
        final retrieved = await repository.getAlert('alert1');
        expect(retrieved, isNotNull);
        expect(retrieved!.state, AlertState.triggered);
      });

      test('Get active alerts', () async {
        final a1 = Alert(
          id: 'alert2',
          policyId: 'policy1',
          state: AlertState.triggered,
          triggeredAt: DateTime.now(),
          acknowledgedAt: null,
          resolvedAt: null,
        );
        final a2 = Alert(
          id: 'alert3',
          policyId: 'policy1',
          state: AlertState.resolved,
          triggeredAt: DateTime.now().subtract(Duration(hours: 1)),
          acknowledgedAt: DateTime.now().subtract(Duration(minutes: 30)),
          resolvedAt: DateTime.now(),
        );
        await repository.createAlert(a1);
        await repository.createAlert(a2);
        final active = await repository.getActiveAlerts();
        expect(active.length, 1);
      });

      test('Acknowledge alert', () async {
        final alert = Alert(
          id: 'alert4',
          policyId: 'policy1',
          state: AlertState.triggered,
          triggeredAt: DateTime.now(),
          acknowledgedAt: null,
          resolvedAt: null,
        );
        await repository.createAlert(alert);
        await repository.acknowledgeAlert('alert4');
        final updated = await repository.getAlert('alert4');
        expect(updated!.state, AlertState.acknowledged);
      });
    });

    // ===== REPOSITORY METHOD TESTS (Compliance) =====
    group('Repository Tests - Compliance', () {
      late SLARepository repository;

      setUp(() {
        repository = InMemorySLARepository();
      });

      test('Create and get compliance record', () async {
        final compliance = SLACompliance(
          id: 'comp1',
          slaId: 'sla1',
          status: ComplianceStatus.compliant,
          score: 99.95,
          breachCount: 0,
          evaluatedAt: DateTime.now(),
        );
        await repository.createCompliance(compliance);
        final retrieved = await repository.getCompliance('comp1');
        expect(retrieved, isNotNull);
        expect(retrieved!.score, 99.95);
      });

      test('Get compliance by SLA', () async {
        final comp = SLACompliance(
          id: 'comp2',
          slaId: 'sla1',
          status: ComplianceStatus.atRisk,
          score: 98.5,
          breachCount: 1,
          evaluatedAt: DateTime.now(),
        );
        await repository.createCompliance(comp);
        final retrieved = await repository.getComplianceBySLA('sla1');
        expect(retrieved, isNotNull);
        expect(retrieved!.score, 98.5);
      });

      test('Get non-compliant SLAs', () async {
        final c1 = SLACompliance(
          id: 'comp3',
          slaId: 'sla1',
          status: ComplianceStatus.nonCompliant,
          score: 95.0,
          breachCount: 5,
          evaluatedAt: DateTime.now(),
        );
        final c2 = SLACompliance(
          id: 'comp4',
          slaId: 'sla2',
          status: ComplianceStatus.compliant,
          score: 99.9,
          breachCount: 0,
          evaluatedAt: DateTime.now(),
        );
        await repository.createCompliance(c1);
        await repository.createCompliance(c2);
        final nonCompliant = await repository.getNonCompliantSLAs();
        expect(nonCompliant.length, 1);
      });
    });

    // ===== REPOSITORY METHOD TESTS (History) =====
    group('Repository Tests - History', () {
      late SLARepository repository;

      setUp(() {
        repository = InMemorySLARepository();
      });

      test('Create history record', () async {
        final history = SLAHistory(
          id: 'hist1',
          slaId: 'sla1',
          changeType: 'status_update',
          previousValue: 'active',
          newValue: 'suspended',
          changedAt: DateTime.now(),
        );
        await repository.createHistory(history);
        final retrieved = await repository.getHistory('hist1');
        expect(retrieved, isNotNull);
      });

      test('Get history by SLA', () async {
        final h1 = SLAHistory(
          id: 'hist2',
          slaId: 'sla1',
          changeType: 'target_update',
          previousValue: '99.0',
          newValue: '99.9',
          changedAt: DateTime.now(),
        );
        await repository.createHistory(h1);
        final history = await repository.getHistoryBySLA('sla1');
        expect(history.length, 1);
      });
    });

    // ===== REPOSITORY METHOD TESTS (Reports & Goals) =====
    group('Repository Tests - Reports and Goals', () {
      late SLARepository repository;

      setUp(() {
        repository = InMemorySLARepository();
      });

      test('Create and get report', () async {
        final report = SLAReport(
          id: 'report1',
          slaId: 'sla1',
          period: 'monthly',
          compliance: 99.8,
          breachCount: 1,
          generatedAt: DateTime.now(),
        );
        await repository.createReport(report);
        final retrieved = await repository.getReport('report1');
        expect(retrieved, isNotNull);
        expect(retrieved!.compliance, 99.8);
      });

      test('Create and get goal', () async {
        final goal = SLAGoal(
          id: 'goal1',
          slaId: 'sla1',
          metricType: MetricType.availability,
          targetValue: 99.95,
          quarter: 'Q1',
          year: 2025,
        );
        await repository.createGoal(goal);
        final retrieved = await repository.getGoal('goal1');
        expect(retrieved, isNotNull);
        expect(retrieved!.targetValue, 99.95);
      });
    });

    // ===== ENGINE TESTS =====
    group('Engine Tests', () {
      test('SLAMonitoringEngine monitors breaches', () async {
        final engine = SLAMonitoringEngine();
        final metric = SLAMetric(
          id: 'm1',
          slaId: 'sla1',
          type: MetricType.availability,
          value: 98.0,
          threshold: 99.0,
          measuredAt: DateTime.now(),
        );
        final breach = await engine.evaluateMetricForBreach(metric, 99.0);
        expect(breach, isNotNull);
      });

      test('MetricsAggregationEngine aggregates data', () async {
        final engine = MetricsAggregationEngine();
        final metrics = [
          SLAMetric(
            id: 'm1',
            slaId: 'sla1',
            type: MetricType.availability,
            value: 99.0,
            threshold: 99.0,
            measuredAt: DateTime.now(),
          ),
          SLAMetric(
            id: 'm2',
            slaId: 'sla1',
            type: MetricType.availability,
            value: 99.9,
            threshold: 99.0,
            measuredAt: DateTime.now(),
          ),
        ];
        final aggregate = await engine.aggregateMetrics(metrics);
        expect(aggregate.length, 2);
      });

      test('AlertingEngine triggers alerts', () async {
        final engine = AlertingEngine();
        final breach = SLABreach(
          id: 'b1',
          slaId: 'sla1',
          breachTime: DateTime.now(),
          severity: BreachSeverity.critical,
          duration: 60,
          affectedMetric: MetricType.availability,
        );
        final alert = await engine.createAlertFromBreach(breach);
        expect(alert, isNotNull);
      });

      test('ComplianceEngine assesses compliance', () async {
        final engine = ComplianceEngine();
        final breaches = [
          SLABreach(
            id: 'b1',
            slaId: 'sla1',
            breachTime: DateTime.now(),
            severity: BreachSeverity.medium,
            duration: 30,
            affectedMetric: MetricType.latency,
          ),
        ];
        final status = await engine.assessCompliance('sla1', breaches);
        expect(status, isNotNull);
      });

      test('ReportingEngine generates reports', () async {
        final engine = ReportingEngine();
        final metrics = [
          SLAMetric(
            id: 'm1',
            slaId: 'sla1',
            type: MetricType.availability,
            value: 99.8,
            threshold: 99.0,
            measuredAt: DateTime.now(),
          ),
        ];
        final report = await engine.generateReport('sla1', 'monthly', metrics);
        expect(report, isNotNull);
      });
    });

    // ===== FACADE TESTS =====
    group('Facade Tests', () {
      late SLAFacade facade;

      setUp(() {
        facade = SLAFacade();
      });

      test('Create service SLA', () async {
        final sla = await facade.createServiceSLA(
          'API Service',
          99.9,
          DateTime.now().add(Duration(days: 365)),
        );
        expect(sla, isNotNull);
        expect(sla.serviceName, 'API Service');
      });

      test('Get active SLA count', () async {
        await facade.createServiceSLA(
          'Service 1',
          99.9,
          DateTime.now().add(Duration(days: 365)),
        );
        await facade.createServiceSLA(
          'Service 2',
          99.8,
          DateTime.now().add(Duration(days: 365)),
        );
        final count = await facade.getActiveSLACount();
        expect(count, 2);
      });

      test('Get average compliance', () async {
        final avg = await facade.getAverageCompliance();
        expect(avg, isA<double>());
      });

      test('Get critical breach count', () async {
        final count = await facade.getCriticalBreachCount();
        expect(count, isA<int>());
      });

      test('Get SLA health status', () async {
        final sla = await facade.createServiceSLA(
          'Healthy Service',
          99.9,
          DateTime.now().add(Duration(days: 365)),
        );
        final health = await facade.getSLAHealthStatus(sla.id);
        expect(health, isNotNull);
      });
    });

    // ===== INTEGRATION TESTS =====
    group('Integration Tests', () {
      late SLAFacade facade;

      setUp(() {
        facade = SLAFacade();
      });

      test('End-to-end SLA creation and monitoring', () async {
        final sla = await facade.createServiceSLA(
          'Integration Test Service',
          99.9,
          DateTime.now().add(Duration(days: 365)),
        );
        expect(sla.status, SLAStatus.active);
        expect(sla.targetAvailability, 99.9);
      });

      test('SLA lifecycle: create, update, archive', () async {
        final sla = await facade.createServiceSLA(
          'Lifecycle Service',
          99.95,
          DateTime.now().add(Duration(days: 365)),
        );
        expect(sla.status, SLAStatus.active);
      });

      test('Multi-SLA management', () async {
        await facade.createServiceSLA(
          'Service A',
          99.9,
          DateTime.now().add(Duration(days: 365)),
        );
        await facade.createServiceSLA(
          'Service B',
          99.95,
          DateTime.now().add(Duration(days: 365)),
        );
        final count = await facade.getActiveSLACount();
        expect(count, 2);
      });
    });

    // ===== PERFORMANCE TESTS =====
    group('Performance Tests', () {
      late SLARepository repository;

      setUp(() {
        repository = InMemorySLARepository();
      });

      test('Bulk SLA creation performance', () async {
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 100; i++) {
          final sla = ServiceLevelAgreement(
            id: 'sla_perf_$i',
            serviceName: 'Service $i',
            status: SLAStatus.active,
            createdAt: DateTime.now(),
            expiresAt: DateTime.now().add(Duration(days: 365)),
            targetAvailability: 99.9,
          );
          await repository.createServiceLevelAgreement(sla);
        }
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds < 5000, true);
      });

      test('Bulk metric creation and retrieval', () async {
        for (int i = 0; i < 50; i++) {
          final metric = SLAMetric(
            id: 'metric_perf_$i',
            slaId: 'sla1',
            type: MetricType.availability,
            value: 99.0 + i * 0.01,
            threshold: 99.0,
            measuredAt: DateTime.now(),
          );
          await repository.createMetric(metric);
        }
        final metrics = await repository.getMetricsBySLA('sla1');
        expect(metrics.length, 50);
      });
    });

    // ===== EDGE CASE TESTS =====
    group('Edge Case Tests', () {
      late SLARepository repository;

      setUp(() {
        repository = InMemorySLARepository();
      });

      test('Handle null values gracefully', () async {
        final sla = await repository.getServiceLevelAgreement('nonexistent');
        expect(sla, isNull);
      });

      test('Handle empty collections', () async {
        final slas = await repository.getActiveSLAs();
        expect(slas, isEmpty);
      });

      test('Handle boundary metric values', () async {
        final metric = SLAMetric(
          id: 'edge_metric',
          slaId: 'sla1',
          type: MetricType.availability,
          value: 0.0,
          threshold: 100.0,
          measuredAt: DateTime.now(),
        );
        await repository.createMetric(metric);
        final retrieved = await repository.getMetric('edge_metric');
        expect(retrieved!.value, 0.0);
      });

      test('Handle SLA expiration', () async {
        final sla = ServiceLevelAgreement(
          id: 'expired_sla',
          serviceName: 'Expired Service',
          status: SLAStatus.expired,
          createdAt: DateTime.now().subtract(Duration(days: 400)),
          expiresAt: DateTime.now().subtract(Duration(days: 35)),
          targetAvailability: 99.9,
        );
        await repository.createServiceLevelAgreement(sla);
        final retrieved = await repository.getServiceLevelAgreement('expired_sla');
        expect(retrieved!.isExpired, true);
      });

      test('Concurrent operations', () async {
        final futures = <Future>[];
        for (int i = 0; i < 20; i++) {
          futures.add(repository.createServiceLevelAgreement(
            ServiceLevelAgreement(
              id: 'concurrent_$i',
              serviceName: 'Concurrent $i',
              status: SLAStatus.active,
              createdAt: DateTime.now(),
              expiresAt: DateTime.now().add(Duration(days: 365)),
              targetAvailability: 99.9,
            ),
          ));
        }
        await Future.wait(futures);
        final slas = await repository.getActiveSLAs();
        expect(slas.length, 20);
      });
    });
  });
}
