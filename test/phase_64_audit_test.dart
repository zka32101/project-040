import 'package:flutter_test/flutter_test.dart';
import '../lib/models/audit_models.dart';
import '../lib/services/audit_service.dart';

void main() {
  group('Phase 64: Audit Logging & Compliance Tests', () {
    late AuditFacade facade;
    late MemoryAuditRepository repository;

    setUp(() {
      repository = MemoryAuditRepository();
      final auditEngine = AuditEngine(repository: repository);
      final complianceEngine = ComplianceEngine(repository: repository);
      final manager = AuditManager(
        repository: repository,
        auditEngine: auditEngine,
        complianceEngine: complianceEngine,
      );
      facade = AuditFacade(manager: manager);
    });

    group('Enum Tests', () {
      test('AuditEventType enum has all values', () {
        expect(AuditEventType.values.length, 10);
        expect(AuditEventType.values, contains(AuditEventType.create));
        expect(AuditEventType.values, contains(AuditEventType.delete));
      });

      test('AuditSeverity enum has all values', () {
        expect(AuditSeverity.values.length, 4);
      });

      test('ComplianceStatus enum has all values', () {
        expect(ComplianceStatus.values.length, 4);
      });

      test('DataClassification enum has all values', () {
        expect(DataClassification.values.length, 4);
      });

      test('RetentionPolicy enum has all values', () {
        expect(RetentionPolicy.values.length, 5);
      });
    });

    group('AuditLog Model Tests', () {
      test('Create audit log', () {
        final log = AuditLog(
          logId: 'log1',
          userId: 'user1',
          action: 'create_document',
          eventType: AuditEventType.create,
          timestamp: DateTime.now(),
          resourceId: 'doc1',
          resourceType: 'document',
          details: {'name': 'Test Doc'},
          status: AuditActionStatus.success,
          severity: AuditSeverity.low,
        );
        expect(log.logId, 'log1');
        expect(log.isRecent, true);
        expect(log.isFailed, false);
      });

      test('Audit log failure detection', () {
        final log = AuditLog(
          logId: 'log1',
          userId: 'user1',
          action: 'delete',
          eventType: AuditEventType.delete,
          timestamp: DateTime.now(),
          resourceId: 'doc1',
          resourceType: 'document',
          details: {},
          status: AuditActionStatus.failed,
          severity: AuditSeverity.critical,
        );
        expect(log.isFailed, true);
        expect(log.isHighSeverity, true);
      });

      test('Audit log age calculation', () {
        final log = AuditLog(
          logId: 'log1',
          userId: 'user1',
          action: 'read',
          eventType: AuditEventType.read,
          timestamp: DateTime.now().subtract(Duration(days: 5)),
          resourceId: 'doc1',
          resourceType: 'document',
          details: {},
          status: AuditActionStatus.success,
          severity: AuditSeverity.low,
        );
        expect(log.ageInDays, 5);
        expect(log.isRecent, true);
      });
    });

    group('ComplianceRule Model Tests', () {
      test('Create compliance rule', () {
        final rule = ComplianceRule(
          ruleId: 'rule1',
          ruleName: 'Data Export Rule',
          description: 'Restrict data exports',
          applicableResources: ['document', 'report'],
          applicableRoles: ['admin', 'manager'],
          isEnabled: true,
          createdAt: DateTime.now(),
        );
        expect(rule.ruleName, 'Data Export Rule');
        expect(rule.isActive, true);
        expect(rule.resourceCount, 2);
        expect(rule.roleCount, 2);
      });
    });

    group('AuditTrail Model Tests', () {
      test('Create audit trail', () {
        final trail = AuditTrail(
          trailId: 'trail1',
          entityId: 'doc1',
          entityType: 'document',
          logIds: ['log1', 'log2', 'log3'],
          startTime: DateTime.now(),
          totalEvents: 3,
        );
        expect(trail.entityId, 'doc1');
        expect(trail.isOngoing, true);
        expect(trail.eventCount, 3);
      });

      test('Audit trail with end time', () {
        final start = DateTime.now().subtract(Duration(days: 1));
        final end = DateTime.now();
        final trail = AuditTrail(
          trailId: 'trail1',
          entityId: 'doc1',
          entityType: 'document',
          logIds: ['log1'],
          startTime: start,
          endTime: end,
        );
        expect(trail.isOngoing, false);
        expect(trail.durationInDays, 1);
      });
    });

    group('DataClassificationPolicy Model Tests', () {
      test('Create data classification policy', () {
        final policy = DataClassificationPolicy(
          policyId: 'policy1',
          policyName: 'Confidential Data Policy',
          classification: DataClassification.confidential,
          allowedRoles: ['admin', 'legal'],
          applicableDataTypes: ['ssn', 'credit_card'],
          createdAt: DateTime.now(),
        );
        expect(policy.isConfidential, true);
        expect(policy.isRestricted, false);
        expect(policy.allowedRoleCount, 2);
      });

      test('Restricted data classification', () {
        final policy = DataClassificationPolicy(
          policyId: 'policy2',
          policyName: 'Secret Policy',
          classification: DataClassification.restricted,
          allowedRoles: ['ceo'],
          applicableDataTypes: ['trade_secrets'],
          createdAt: DateTime.now(),
        );
        expect(policy.isRestricted, true);
      });
    });

    group('RetentionRule Model Tests', () {
      test('Create retention rule', () {
        final rule = RetentionRule(
          ruleId: 'ret1',
          ruleName: '90-Day Retention',
          retentionPeriod: RetentionPolicy.ninetyDays,
          applicableLogTypes: ['user_access', 'data_export'],
          createdAt: DateTime.now(),
        );
        expect(rule.isActive, true);
        expect(rule.logTypeCount, 2);
      });
    });

    group('ComplianceCheck Model Tests', () {
      test('Compliant check', () {
        final check = ComplianceCheck(
          checkId: 'check1',
          checkName: 'Security Compliance',
          description: 'Check security rules',
          executedAt: DateTime.now(),
          status: ComplianceStatus.compliant,
          failedRules: [],
          passedRules: 10,
          totalRules: 10,
        );
        expect(check.passed, true);
        expect(check.complianceScore, 100.0);
        expect(check.isHealthy, true);
      });

      test('Non-compliant check', () {
        final check = ComplianceCheck(
          checkId: 'check2',
          checkName: 'Data Protection',
          description: 'Check data policies',
          executedAt: DateTime.now(),
          status: ComplianceStatus.noncompliant,
          failedRules: ['rule1', 'rule2'],
          passedRules: 8,
          totalRules: 10,
        );
        expect(check.passed, false);
        expect(check.complianceScore, 80.0);
        expect(check.isHealthy, false);
      });
    });

    group('AuditReport Model Tests', () {
      test('Create audit report', () {
        final report = AuditReport(
          reportId: 'rep1',
          generatedAt: DateTime.now(),
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
          totalEvents: 1000,
          failureCount: 5,
          criticalEvents: ['log1', 'log2'],
          eventsByType: {'create': 500, 'update': 400, 'delete': 100},
        );
        expect(report.failureRate, 0.5);
        expect(report.hasFailures, true);
        expect(report.hasCriticalEvents, true);
        expect(report.periodInDays, 30);
      });
    });

    group('UserAccessLog Model Tests', () {
      test('Create user access log', () {
        final log = UserAccessLog(
          logId: 'access1',
          userId: 'user1',
          action: 'login',
          accessTime: DateTime.now(),
          ipAddress: '192.168.1.1',
          isSuccessful: true,
        );
        expect(log.isRecent, true);
        expect(log.isFailed, false);
      });

      test('Failed access log', () {
        final log = UserAccessLog(
          logId: 'access2',
          userId: 'user2',
          action: 'login',
          accessTime: DateTime.now(),
          ipAddress: '10.0.0.1',
          isSuccessful: false,
        );
        expect(log.isFailed, true);
      });
    });

    group('ChangeLog Model Tests', () {
      test('Create change log', () {
        final log = ChangeLog(
          logId: 'change1',
          resourceId: 'doc1',
          resourceType: 'document',
          fieldName: 'title',
          oldValue: 'Old Title',
          newValue: 'New Title',
          modifiedBy: 'user1',
          modifiedAt: DateTime.now(),
        );
        expect(log.hasValueChanged, true);
        expect(log.isRecent, true);
      });
    });

    group('ComplianceMetrics Model Tests', () {
      test('Healthy compliance metrics', () {
        final metrics = ComplianceMetrics(
          metricsId: 'metrics1',
          calculatedAt: DateTime.now(),
          overallScore: 98.5,
          totalRulesChecked: 100,
          rulesCompliant: 98,
          rulesNonCompliant: 2,
          categoryScores: {'security': 100.0, 'privacy': 95.0},
        );
        expect(metrics.isHealthy, true);
        expect(metrics.compliancePercentage, 98.5);
      });

      test('Unhealthy compliance metrics', () {
        final metrics = ComplianceMetrics(
          metricsId: 'metrics2',
          calculatedAt: DateTime.now(),
          overallScore: 85.0,
          totalRulesChecked: 100,
          rulesCompliant: 85,
          rulesNonCompliant: 15,
          categoryScores: {},
        );
        expect(metrics.isHealthy, false);
      });
    });

    group('AuditFilter Model Tests', () {
      test('Create audit filter', () {
        final filter = AuditFilter(
          filterId: 'filter1',
          filterName: 'Critical Events',
          eventType: AuditEventType.delete,
          severity: AuditSeverity.critical,
          isActive: true,
        );
        expect(filter.hasFilters, true);
        expect(filter.activeFilterCount, 2);
      });
    });

    group('Repository Tests', () {
      test('Create and retrieve audit log', () async {
        final log = AuditLog(
          logId: 'log1',
          userId: 'user1',
          action: 'create',
          eventType: AuditEventType.create,
          timestamp: DateTime.now(),
          resourceId: 'res1',
          resourceType: 'resource',
          details: {},
          status: AuditActionStatus.success,
          severity: AuditSeverity.low,
        );
        await repository.createAuditLog(log);
        final retrieved = await repository.getAuditLog('log1');
        expect(retrieved?.userId, 'user1');
      });

      test('Get audit logs by user', () async {
        await repository.createAuditLog(AuditLog(
          logId: 'log1',
          userId: 'user1',
          action: 'create',
          eventType: AuditEventType.create,
          timestamp: DateTime.now(),
          resourceId: 'res1',
          resourceType: 'resource',
          details: {},
          status: AuditActionStatus.success,
          severity: AuditSeverity.low,
        ));
        final logs = await repository.getAuditLogsByUser('user1');
        expect(logs.isNotEmpty, true);
      });

      test('Create and retrieve compliance rule', () async {
        final rule = ComplianceRule(
          ruleId: 'rule1',
          ruleName: 'Rule 1',
          description: 'Test rule',
          applicableResources: [],
          applicableRoles: [],
          isEnabled: true,
          createdAt: DateTime.now(),
        );
        await repository.createComplianceRule(rule);
        final retrieved = await repository.getComplianceRule('rule1');
        expect(retrieved?.ruleName, 'Rule 1');
      });

      test('Create and retrieve data policy', () async {
        final policy = DataClassificationPolicy(
          policyId: 'policy1',
          policyName: 'Policy 1',
          classification: DataClassification.confidential,
          allowedRoles: [],
          applicableDataTypes: [],
          createdAt: DateTime.now(),
        );
        await repository.createDataClassificationPolicy(policy);
        final retrieved = await repository.getDataClassificationPolicy('policy1');
        expect(retrieved?.policyName, 'Policy 1');
      });

      test('Create and retrieve retention rule', () async {
        final rule = RetentionRule(
          ruleId: 'ret1',
          ruleName: 'Retention 1',
          retentionPeriod: RetentionPolicy.oneYear,
          applicableLogTypes: [],
          createdAt: DateTime.now(),
        );
        await repository.createRetentionRule(rule);
        final retrieved = await repository.getRetentionRule('ret1');
        expect(retrieved?.ruleName, 'Retention 1');
      });

      test('Save and retrieve compliance check', () async {
        final check = ComplianceCheck(
          checkId: 'check1',
          checkName: 'Check 1',
          description: 'Test check',
          executedAt: DateTime.now(),
          status: ComplianceStatus.compliant,
          failedRules: [],
          passedRules: 5,
          totalRules: 5,
        );
        await repository.saveComplianceCheck(check);
        final retrieved = await repository.getComplianceCheck('check1');
        expect(retrieved?.checkName, 'Check 1');
      });

      test('Create and retrieve user access log', () async {
        final log = UserAccessLog(
          logId: 'access1',
          userId: 'user1',
          action: 'login',
          accessTime: DateTime.now(),
          ipAddress: '192.168.1.1',
        );
        await repository.createUserAccessLog(log);
        final logs = await repository.getUserAccessLogs('user1');
        expect(logs.isNotEmpty, true);
      });

      test('Create and retrieve change log', () async {
        final log = ChangeLog(
          logId: 'change1',
          resourceId: 'res1',
          resourceType: 'document',
          fieldName: 'title',
          oldValue: 'Old',
          newValue: 'New',
          modifiedBy: 'user1',
          modifiedAt: DateTime.now(),
        );
        await repository.createChangeLog(log);
        final logs = await repository.getChangeLogsByResource('res1');
        expect(logs.isNotEmpty, true);
      });

      test('Save and retrieve compliance metrics', () async {
        final metrics = ComplianceMetrics(
          metricsId: 'metrics1',
          calculatedAt: DateTime.now(),
          overallScore: 95.0,
          totalRulesChecked: 100,
          rulesCompliant: 95,
          rulesNonCompliant: 5,
          categoryScores: {},
        );
        await repository.saveComplianceMetrics(metrics);
        final retrieved = await repository.getComplianceMetrics('metrics1');
        expect(retrieved?.overallScore, 95.0);
      });
    });

    group('Audit Engine Tests', () {
      test('Log event creates audit log', () async {
        final engine = AuditEngine(repository: repository);
        final log = await engine.logEvent(
          'user1',
          'create_doc',
          AuditEventType.create,
          'doc1',
          'document',
          AuditActionStatus.success,
          AuditSeverity.low,
        );
        expect(log.logId, isNotEmpty);
        expect(log.userId, 'user1');
      });

      test('Get failed events', () async {
        final engine = AuditEngine(repository: repository);
        await engine.logEvent(
          'user1',
          'delete',
          AuditEventType.delete,
          'doc1',
          'document',
          AuditActionStatus.failed,
          AuditSeverity.high,
        );
        final failedEvents = await engine.getFailedEvents(DateTime.now().subtract(Duration(hours: 1)));
        expect(failedEvents.isNotEmpty, true);
      });

      test('Get high severity events', () async {
        final engine = AuditEngine(repository: repository);
        await engine.logEvent(
          'user1',
          'export',
          AuditEventType.export,
          'data1',
          'data',
          AuditActionStatus.success,
          AuditSeverity.critical,
        );
        final criticalEvents = await engine.getHighSeverityEvents(DateTime.now().subtract(Duration(hours: 1)));
        expect(criticalEvents.isNotEmpty, true);
      });
    });

    group('Compliance Engine Tests', () {
      test('Execute compliance check', () async {
        final engine = ComplianceEngine(repository: repository);
        final check = await engine.executeComplianceCheck(
          'Security Check',
          'Check security rules',
          ['rule1', 'rule2'],
        );
        expect(check.checkName, 'Security Check');
      });

      test('Calculate compliance metrics', () async {
        final engine = ComplianceEngine(repository: repository);
        final metrics = await engine.calculateMetrics();
        expect(metrics.metricsId, isNotEmpty);
      });
    });

    group('Audit Facade Integration Tests', () {
      test('Complete audit workflow', () async {
        // Log user action
        final log = await facade.logUserAction(
          'user1',
          'create_document',
          AuditEventType.create,
          'doc1',
          'document',
          AuditActionStatus.success,
          AuditSeverity.low,
        );
        expect(log.logId, isNotEmpty);

        // Retrieve audit logs
        final logs = await facade.getAuditLogs('user1');
        expect(logs.isNotEmpty, true);
      });

      test('Compliance management', () async {
        // Create rule
        await facade.createRule(
          'Data Access Rule',
          'Restrict unauthorized access',
          ['document'],
          ['admin'],
        );

        // List rules
        final rules = await facade.listComplianceRules();
        expect(rules.isNotEmpty, true);
      });

      test('Data classification policies', () async {
        // Create policy
        await facade.createDataPolicy(
          'Confidential Data Policy',
          DataClassification.confidential,
          ['admin', 'manager'],
          ['ssn', 'salary'],
        );

        // List policies
        final policies = await facade.listDataPolicies();
        expect(policies.isNotEmpty, true);
      });

      test('Retention policies', () async {
        // Create retention policy
        await facade.createRetentionPolicy(
          '90-Day Retention',
          RetentionPolicy.ninetyDays,
          ['audit_log', 'access_log'],
        );
      });

      test('Compliance check execution', () async {
        // Create a rule first
        await facade.createRule(
          'Test Rule',
          'Test',
          [],
          [],
        );

        // Run compliance check
        final check = await facade.runComplianceCheck(
          'System Compliance Check',
          'Monthly compliance verification',
          ['rule1'],
        );
        expect(check.checkName, 'System Compliance Check');
      });

      test('Audit report generation', () async {
        final start = DateTime.now().subtract(Duration(days: 7));
        final end = DateTime.now();
        final report = await facade.generateReport(start, end);
        expect(report.reportId, isNotEmpty);
      });

      test('User access tracking', () async {
        await facade.recordUserAccess(
          'user1',
          'login',
          '192.168.1.100',
          deviceInfo: 'MacBook Pro',
        );

        final history = await facade.getUserAccessHistory('user1');
        expect(history.isNotEmpty, true);
      });

      test('Resource change tracking', () async {
        await facade.recordResourceChange(
          'doc1',
          'document',
          'title',
          'Old Title',
          'New Title',
          'user1',
        );

        final changeHistory = await facade.getResourceChangeHistory('doc1');
        expect(changeHistory.isNotEmpty, true);
      });

      test('Multiple audit events', () async {
        for (int i = 0; i < 5; i++) {
          await facade.logUserAction(
            'user1',
            'action_$i',
            AuditEventType.update,
            'res_$i',
            'resource',
            AuditActionStatus.success,
            AuditSeverity.low,
          );
        }

        final logs = await facade.getAuditLogs('user1');
        expect(logs.length, greaterThanOrEqualTo(5));
      });

      test('Complex compliance workflow', () async {
        // Create multiple rules
        for (int i = 0; i < 3; i++) {
          await facade.createRule(
            'Rule $i',
            'Description $i',
            ['res_$i'],
            ['role_$i'],
          );
        }

        // Create policies
        await facade.createDataPolicy(
          'Policy A',
          DataClassification.confidential,
          ['admin'],
          ['type_a'],
        );

        // Run compliance check
        final check = await facade.runComplianceCheck(
          'Comprehensive Check',
          'Full system compliance check',
          [],
        );
        expect(check.checkName, 'Comprehensive Check');
      });
    });

    group('Edge Cases & Error Handling', () {
      test('Handle missing audit log', () async {
        final result = await repository.getAuditLog('nonexistent');
        expect(result, isNull);
      });

      test('Handle missing compliance rule', () async {
        final result = await repository.getComplianceRule('nonexistent');
        expect(result, isNull);
      });

      test('Audit log with empty details', () {
        final log = AuditLog(
          logId: 'log1',
          userId: 'user1',
          action: 'test',
          eventType: AuditEventType.read,
          timestamp: DateTime.now(),
          resourceId: 'res1',
          resourceType: 'resource',
          details: {},
          status: AuditActionStatus.success,
          severity: AuditSeverity.low,
        );
        expect(log.details.isEmpty, true);
      });

      test('Old audit log age', () {
        final log = AuditLog(
          logId: 'log1',
          userId: 'user1',
          action: 'test',
          eventType: AuditEventType.read,
          timestamp: DateTime.now().subtract(Duration(days: 90)),
          resourceId: 'res1',
          resourceType: 'resource',
          details: {},
          status: AuditActionStatus.success,
          severity: AuditSeverity.low,
        );
        expect(log.isRecent, false);
        expect(log.ageInDays, 90);
      });

      test('Zero compliance score', () {
        final metrics = ComplianceMetrics(
          metricsId: 'metrics1',
          calculatedAt: DateTime.now(),
          overallScore: 0.0,
          totalRulesChecked: 0,
          rulesCompliant: 0,
          rulesNonCompliant: 0,
          categoryScores: {},
        );
        expect(metrics.isHealthy, false);
      });

      test('Large audit report', () {
        final report = AuditReport(
          reportId: 'rep1',
          generatedAt: DateTime.now(),
          periodStart: DateTime.now().subtract(Duration(days: 365)),
          periodEnd: DateTime.now(),
          totalEvents: 1000000,
          failureCount: 5000,
          criticalEvents: List.generate(100, (i) => 'log_$i'),
          eventsByType: {'create': 500000, 'update': 400000, 'delete': 100000},
        );
        expect(report.totalEvents, 1000000);
        expect(report.failureRate, 0.5);
      });

      test('Multiple user access logs', () async {
        for (int i = 0; i < 10; i++) {
          await facade.recordUserAccess(
            'user1',
            'action_$i',
            '192.168.1.$i',
          );
        }

        final logs = await facade.getUserAccessHistory('user1');
        expect(logs.length, 10);
      });

      test('Concurrent compliance checks', () async {
        final futures = List.generate(
          3,
          (i) => facade.runComplianceCheck(
            'Check $i',
            'Concurrent check $i',
            [],
          ),
        );
        final results = await Future.wait(futures);
        expect(results.length, 3);
      });

      test('Special characters in audit logs', () async {
        await facade.logUserAction(
          'user@example.com',
          'action with #special @characters',
          AuditEventType.create,
          'resource-123',
          'special_type',
          AuditActionStatus.success,
          AuditSeverity.medium,
        );
      });
    });
  });
}
