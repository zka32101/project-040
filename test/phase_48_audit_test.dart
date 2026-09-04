import 'package:flutter_test/flutter_test.dart';
import '../lib/models/audit_models.dart';
import '../lib/services/audit_service.dart';

void main() {
  group('Phase 48: Audit & Compliance System Tests', () {
    // ==================== Enum Tests ====================
    group('Enum Tests', () {
      test('AuditEventType has all required values', () {
        expect(AuditEventType.create.value, 'create');
        expect(AuditEventType.read.value, 'read');
        expect(AuditEventType.update.value, 'update');
        expect(AuditEventType.delete.value, 'delete');
        expect(AuditEventType.execute.value, 'execute');
        expect(AuditEventType.export.value, 'export');
        expect(AuditEventType.login.value, 'login');
        expect(AuditEventType.logout.value, 'logout');
        expect(AuditEventType.permissionChange.value, 'permission_change');
      });

      test('AuditSeverity has all required values', () {
        expect(AuditSeverity.info.value, 1);
        expect(AuditSeverity.warning.value, 2);
        expect(AuditSeverity.error.value, 3);
        expect(AuditSeverity.critical.value, 4);
      });

      test('AuditStatus has all required values', () {
        expect(AuditStatus.success.value, 'success');
        expect(AuditStatus.failure.value, 'failure');
        expect(AuditStatus.partial.value, 'partial');
      });

      test('ResourceType has all required values', () {
        expect(ResourceType.job.value, 'job');
        expect(ResourceType.feedback.value, 'feedback');
        expect(ResourceType.notification.value, 'notification');
        expect(ResourceType.metric.value, 'metric');
        expect(ResourceType.user.value, 'user');
        expect(ResourceType.config.value, 'config');
        expect(ResourceType.report.value, 'report');
        expect(ResourceType.other.value, 'other');
      });
    });

    // ==================== Model Tests ====================
    group('Model Tests', () {
      test('AuditEvent properties are set correctly', () {
        final event = AuditEvent(
          eventId: 'e1',
          userId: 'user1',
          resourceType: ResourceType.job,
          resourceId: 'job1',
          action: AuditEventType.create,
          severity: AuditSeverity.info,
          status: AuditStatus.success,
          timestamp: DateTime.now(),
        );

        expect(event.eventId, 'e1');
        expect(event.userId, 'user1');
        expect(event.resourceType, ResourceType.job);
        expect(event.isSuccessful, true);
        expect(event.isFailed, false);
        expect(event.isCritical, false);
      });

      test('AuditEvent.isCritical returns true for critical events', () {
        final event = AuditEvent(
          eventId: 'e1',
          userId: 'user1',
          resourceType: ResourceType.job,
          resourceId: 'job1',
          action: AuditEventType.delete,
          severity: AuditSeverity.critical,
          status: AuditStatus.success,
          timestamp: DateTime.now(),
        );

        expect(event.isCritical, true);
      });

      test('AuditEvent.age returns correct duration', () {
        final pastTime = DateTime.now().subtract(Duration(hours: 1));
        final event = AuditEvent(
          eventId: 'e1',
          userId: 'user1',
          resourceType: ResourceType.job,
          resourceId: 'job1',
          action: AuditEventType.create,
          severity: AuditSeverity.info,
          status: AuditStatus.success,
          timestamp: pastTime,
        );

        expect(event.age.inHours, greaterThanOrEqualTo(1));
      });

      test('AuditLog calculates event count correctly', () {
        final events = [
          AuditEvent(
            eventId: 'e1',
            userId: 'user1',
            resourceType: ResourceType.job,
            resourceId: 'job1',
            action: AuditEventType.create,
            severity: AuditSeverity.info,
            status: AuditStatus.success,
            timestamp: DateTime.now(),
          ),
          AuditEvent(
            eventId: 'e2',
            userId: 'user1',
            resourceType: ResourceType.job,
            resourceId: 'job2',
            action: AuditEventType.update,
            severity: AuditSeverity.warning,
            status: AuditStatus.failure,
            timestamp: DateTime.now(),
          ),
        ];

        final log = AuditLog(
          logId: 'log1',
          events: events,
          createdAt: DateTime.now(),
        );

        expect(log.eventCount, 2);
        expect(log.failureCount, 1);
        expect(log.successRate, 0.5);
      });

      test('AuditLog.criticalCount counts critical events', () {
        final events = [
          AuditEvent(
            eventId: 'e1',
            userId: 'user1',
            resourceType: ResourceType.job,
            resourceId: 'job1',
            action: AuditEventType.delete,
            severity: AuditSeverity.critical,
            status: AuditStatus.success,
            timestamp: DateTime.now(),
          ),
          AuditEvent(
            eventId: 'e2',
            userId: 'user1',
            resourceType: ResourceType.job,
            resourceId: 'job2',
            action: AuditEventType.update,
            severity: AuditSeverity.info,
            status: AuditStatus.success,
            timestamp: DateTime.now(),
          ),
        ];

        final log = AuditLog(
          logId: 'log1',
          events: events,
          createdAt: DateTime.now(),
        );

        expect(log.criticalCount, 1);
      });

      test('CompliancePolicy has correct properties', () {
        final policy = CompliancePolicy(
          policyId: 'p1',
          name: 'Data Protection',
          description: 'Ensure data protection compliance',
          rules: ['NO_EXPORT', 'REQUIRE_APPROVAL'],
          createdAt: DateTime.now(),
        );

        expect(policy.policyId, 'p1');
        expect(policy.isEnabled, true);
        expect(policy.ruleCount, 2);
      });

      test('ComplianceViolation.resolutionTime calculates correctly', () {
        final detectedAt = DateTime.now().subtract(Duration(hours: 2));
        final resolvedAt = detectedAt.add(Duration(hours: 1));

        final violation = ComplianceViolation(
          violationId: 'v1',
          policyId: 'p1',
          severity: AuditSeverity.error,
          description: 'Violation detected',
          detectedAt: detectedAt,
          resolvedAt: resolvedAt,
        );

        expect(violation.isResolved, true);
        expect(violation.resolutionTime?.inHours, 1);
      });

      test('ComplianceStats calculates complianceLevel correctly', () {
        final stats = ComplianceStats(
          statsId: 's1',
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
          totalPolicies: 5,
          activePolicies: 4,
          totalViolations: 2,
          criticalViolations: 1,
          resolvedViolations: 1,
          violationsBySeverity: {AuditSeverity.critical: 1},
          complianceScore: 0.95,
        );

        expect(stats.complianceLevel, 'Excellent');
        expect(stats.resolutionRate, 0.5);
      });

      test('ComplianceStats complianceLevel for different scores', () {
        final statsExcellent = ComplianceStats(
          statsId: 's1',
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          totalPolicies: 1,
          activePolicies: 1,
          totalViolations: 0,
          criticalViolations: 0,
          resolvedViolations: 0,
          violationsBySeverity: {},
          complianceScore: 0.95,
        );
        expect(statsExcellent.complianceLevel, 'Excellent');

        final statsGood = ComplianceStats(
          statsId: 's2',
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          totalPolicies: 1,
          activePolicies: 1,
          totalViolations: 1,
          criticalViolations: 0,
          resolvedViolations: 1,
          violationsBySeverity: {},
          complianceScore: 0.75,
        );
        expect(statsGood.complianceLevel, 'Good');

        final statsFair = ComplianceStats(
          statsId: 's3',
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          totalPolicies: 1,
          activePolicies: 1,
          totalViolations: 2,
          criticalViolations: 0,
          resolvedViolations: 1,
          violationsBySeverity: {},
          complianceScore: 0.55,
        );
        expect(statsFair.complianceLevel, 'Fair');
      });

      test('ComplianceReport.unresolvedViolations counts correctly', () {
        final violations = [
          ComplianceViolation(
            violationId: 'v1',
            policyId: 'p1',
            severity: AuditSeverity.error,
            description: 'Violation 1',
            detectedAt: DateTime.now(),
          ),
          ComplianceViolation(
            violationId: 'v2',
            policyId: 'p1',
            severity: AuditSeverity.warning,
            description: 'Violation 2',
            detectedAt: DateTime.now(),
            resolvedAt: DateTime.now(),
          ),
        ];

        final report = ComplianceReport(
          reportId: 'r1',
          generatedAt: DateTime.now(),
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          policies: [],
          violations: violations,
          stats: ComplianceStats(
            statsId: 's1',
            periodStart: DateTime.now(),
            periodEnd: DateTime.now(),
            totalPolicies: 1,
            activePolicies: 1,
            totalViolations: 2,
            criticalViolations: 0,
            resolvedViolations: 1,
            violationsBySeverity: {},
            complianceScore: 0.5,
          ),
        );

        expect(report.unresolvedViolations, 1);
      });

      test('ComplianceReport.toMarkdown generates valid markdown', () {
        final report = ComplianceReport(
          reportId: 'r1',
          generatedAt: DateTime.now(),
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          policies: [
            CompliancePolicy(
              policyId: 'p1',
              name: 'Data Policy',
              description: 'Data protection',
              rules: ['RULE1'],
              createdAt: DateTime.now(),
            ),
          ],
          violations: [],
          stats: ComplianceStats(
            statsId: 's1',
            periodStart: DateTime.now(),
            periodEnd: DateTime.now(),
            totalPolicies: 1,
            activePolicies: 1,
            totalViolations: 0,
            criticalViolations: 0,
            resolvedViolations: 0,
            violationsBySeverity: {},
            complianceScore: 1.0,
          ),
          recommendations: ['Recommendation 1'],
        );

        final markdown = report.toMarkdown();
        expect(markdown.contains('# Compliance Report'), true);
        expect(markdown.contains('Excellent'), true);
      });

      test('AuditTrail actionCounts groups by action type', () {
        final events = [
          AuditEvent(
            eventId: 'e1',
            userId: 'user1',
            resourceType: ResourceType.job,
            resourceId: 'job1',
            action: AuditEventType.create,
            severity: AuditSeverity.info,
            status: AuditStatus.success,
            timestamp: DateTime.now(),
          ),
          AuditEvent(
            eventId: 'e2',
            userId: 'user1',
            resourceType: ResourceType.job,
            resourceId: 'job1',
            action: AuditEventType.create,
            severity: AuditSeverity.info,
            status: AuditStatus.success,
            timestamp: DateTime.now(),
          ),
          AuditEvent(
            eventId: 'e3',
            userId: 'user1',
            resourceType: ResourceType.job,
            resourceId: 'job1',
            action: AuditEventType.update,
            severity: AuditSeverity.info,
            status: AuditStatus.success,
            timestamp: DateTime.now(),
          ),
        ];

        final trail = AuditTrail(
          trailId: 't1',
          userId: 'user1',
          events: events,
          startTime: DateTime.now().subtract(Duration(hours: 1)),
          endTime: DateTime.now(),
        );

        expect(trail.actionCounts[AuditEventType.create], 2);
        expect(trail.actionCounts[AuditEventType.update], 1);
      });

      test('AuditTrail resourceCounts groups by resource type', () {
        final events = [
          AuditEvent(
            eventId: 'e1',
            userId: 'user1',
            resourceType: ResourceType.job,
            resourceId: 'job1',
            action: AuditEventType.create,
            severity: AuditSeverity.info,
            status: AuditStatus.success,
            timestamp: DateTime.now(),
          ),
          AuditEvent(
            eventId: 'e2',
            userId: 'user1',
            resourceType: ResourceType.feedback,
            resourceId: 'fb1',
            action: AuditEventType.create,
            severity: AuditSeverity.info,
            status: AuditStatus.success,
            timestamp: DateTime.now(),
          ),
        ];

        final trail = AuditTrail(
          trailId: 't1',
          userId: 'user1',
          events: events,
          startTime: DateTime.now().subtract(Duration(hours: 1)),
          endTime: DateTime.now(),
        );

        expect(trail.resourceCounts[ResourceType.job], 1);
        expect(trail.resourceCounts[ResourceType.feedback], 1);
      });
    });

    // ==================== Repository Tests ====================
    group('Repository Tests', () {
      late AuditRepository repository;

      setUp(() {
        repository = MemoryAuditRepository();
      });

      test('addEvent and getEvent work correctly', () async {
        final event = AuditEvent(
          eventId: 'e1',
          userId: 'user1',
          resourceType: ResourceType.job,
          resourceId: 'job1',
          action: AuditEventType.create,
          severity: AuditSeverity.info,
          status: AuditStatus.success,
          timestamp: DateTime.now(),
        );

        await repository.addEvent(event);
        final retrieved = await repository.getEvent('e1');

        expect(retrieved?.eventId, 'e1');
        expect(retrieved?.userId, 'user1');
      });

      test('getEventsByUser filters correctly', () async {
        final event1 = AuditEvent(
          eventId: 'e1',
          userId: 'user1',
          resourceType: ResourceType.job,
          resourceId: 'job1',
          action: AuditEventType.create,
          severity: AuditSeverity.info,
          status: AuditStatus.success,
          timestamp: DateTime.now(),
        );
        final event2 = AuditEvent(
          eventId: 'e2',
          userId: 'user2',
          resourceType: ResourceType.job,
          resourceId: 'job2',
          action: AuditEventType.update,
          severity: AuditSeverity.info,
          status: AuditStatus.success,
          timestamp: DateTime.now(),
        );

        await repository.addEvent(event1);
        await repository.addEvent(event2);

        final userEvents = await repository.getEventsByUser('user1');
        expect(userEvents.length, 1);
        expect(userEvents.first.userId, 'user1');
      });

      test('getEventsByType filters correctly', () async {
        final event1 = AuditEvent(
          eventId: 'e1',
          userId: 'user1',
          resourceType: ResourceType.job,
          resourceId: 'job1',
          action: AuditEventType.create,
          severity: AuditSeverity.info,
          status: AuditStatus.success,
          timestamp: DateTime.now(),
        );
        final event2 = AuditEvent(
          eventId: 'e2',
          userId: 'user1',
          resourceType: ResourceType.job,
          resourceId: 'job1',
          action: AuditEventType.update,
          severity: AuditSeverity.info,
          status: AuditStatus.success,
          timestamp: DateTime.now(),
        );

        await repository.addEvent(event1);
        await repository.addEvent(event2);

        final createEvents = await repository.getEventsByType(AuditEventType.create);
        expect(createEvents.length, 1);
      });

      test('getEventsBySeverity filters correctly', () async {
        final event1 = AuditEvent(
          eventId: 'e1',
          userId: 'user1',
          resourceType: ResourceType.job,
          resourceId: 'job1',
          action: AuditEventType.create,
          severity: AuditSeverity.critical,
          status: AuditStatus.success,
          timestamp: DateTime.now(),
        );
        final event2 = AuditEvent(
          eventId: 'e2',
          userId: 'user1',
          resourceType: ResourceType.job,
          resourceId: 'job1',
          action: AuditEventType.update,
          severity: AuditSeverity.info,
          status: AuditStatus.success,
          timestamp: DateTime.now(),
        );

        await repository.addEvent(event1);
        await repository.addEvent(event2);

        final criticalEvents = await repository.getEventsBySeverity(AuditSeverity.critical);
        expect(criticalEvents.length, 1);
      });

      test('createLog and getLog work correctly', () async {
        final event = AuditEvent(
          eventId: 'e1',
          userId: 'user1',
          resourceType: ResourceType.job,
          resourceId: 'job1',
          action: AuditEventType.create,
          severity: AuditSeverity.info,
          status: AuditStatus.success,
          timestamp: DateTime.now(),
        );

        await repository.addEvent(event);
        final log = await repository.createLog('log1', [event]);
        final retrieved = await repository.getLog('log1');

        expect(retrieved?.logId, 'log1');
        expect(retrieved?.eventCount, 1);
      });

      test('clearAll removes all data', () async {
        final event = AuditEvent(
          eventId: 'e1',
          userId: 'user1',
          resourceType: ResourceType.job,
          resourceId: 'job1',
          action: AuditEventType.create,
          severity: AuditSeverity.info,
          status: AuditStatus.success,
          timestamp: DateTime.now(),
        );

        await repository.addEvent(event);
        await repository.clearAll();

        final retrieved = await repository.getEvent('e1');
        expect(retrieved, null);
      });
    });

    // ==================== Engine Tests ====================
    group('Engine Tests', () {
      late ComplianceEngine engine;

      setUp(() {
        engine = MemoryComplianceEngine();
      });

      test('createPolicy creates policy correctly', () async {
        final policy = await engine.createPolicy('p1', 'Test Policy', 'Test Description', ['RULE1']);

        expect(policy.policyId, 'p1');
        expect(policy.name, 'Test Policy');
        expect(policy.ruleCount, 1);
      });

      test('detectViolation creates violation', () async {
        final event = AuditEvent(
          eventId: 'e1',
          userId: 'user1',
          resourceType: ResourceType.job,
          resourceId: 'job1',
          action: AuditEventType.delete,
          severity: AuditSeverity.critical,
          status: AuditStatus.success,
          timestamp: DateTime.now(),
        );

        final violation = await engine.detectViolation('v1', 'p1', event);

        expect(violation.violationId, 'v1');
        expect(violation.policyId, 'p1');
      });

      test('checkEventCompliance detects critical events', () async {
        final event = AuditEvent(
          eventId: 'e1',
          userId: 'user1',
          resourceType: ResourceType.job,
          resourceId: 'job1',
          action: AuditEventType.delete,
          severity: AuditSeverity.critical,
          status: AuditStatus.success,
          timestamp: DateTime.now(),
        );

        final policy = await engine.createPolicy('p1', 'Test', 'Test', ['RULE']);
        final violations = await engine.checkEventCompliance(event, [policy]);

        expect(violations.isNotEmpty, true);
      });

      test('calculateStats computes metrics correctly', () async {
        final policy = await engine.createPolicy('p1', 'Test', 'Test', ['RULE']);
        final event = AuditEvent(
          eventId: 'e1',
          userId: 'user1',
          resourceType: ResourceType.job,
          resourceId: 'job1',
          action: AuditEventType.create,
          severity: AuditSeverity.info,
          status: AuditStatus.success,
          timestamp: DateTime.now().subtract(Duration(days: 5)),
        );

        final violations = await engine.checkEventCompliance(event, [policy]);
        final stats = await engine.calculateStats(
          [policy],
          violations,
          DateTime.now().subtract(Duration(days: 10)),
          DateTime.now(),
        );

        expect(stats.totalPolicies, 1);
      });

      test('generateRecommendations creates recommendations', () async {
        final violation = ComplianceViolation(
          violationId: 'v1',
          policyId: 'p1',
          severity: AuditSeverity.critical,
          description: 'Critical violation',
          detectedAt: DateTime.now(),
        );

        final recommendations = await engine.generateRecommendations([violation]);

        expect(recommendations.isNotEmpty, true);
        expect(recommendations.first.contains('Critical'), true);
      });

      test('generateReport produces complete report', () async {
        final policy = await engine.createPolicy('p1', 'Test Policy', 'Test', ['RULE']);
        final event = AuditEvent(
          eventId: 'e1',
          userId: 'user1',
          resourceType: ResourceType.job,
          resourceId: 'job1',
          action: AuditEventType.create,
          severity: AuditSeverity.info,
          status: AuditStatus.success,
          timestamp: DateTime.now().subtract(Duration(days: 5)),
        );

        final violations = await engine.checkEventCompliance(event, [policy]);
        final report = await engine.generateReport(
          'r1',
          [policy],
          violations,
          DateTime.now().subtract(Duration(days: 10)),
          DateTime.now(),
        );

        expect(report.reportId, 'r1');
        expect(report.policies.length, 1);
      });
    });

    // ==================== Manager Tests ====================
    group('Manager Tests', () {
      late MemoryAuditManager manager;

      setUp(() {
        manager = MemoryAuditManager(
          repository: MemoryAuditRepository(),
          complianceEngine: MemoryComplianceEngine(),
        );
      });

      test('recordEvent records event correctly', () async {
        final event = await manager.recordEvent(
          'e1',
          'user1',
          ResourceType.job,
          'job1',
          AuditEventType.create,
          AuditSeverity.info,
          AuditStatus.success,
        );

        expect(event.eventId, 'e1');
        expect(event.userId, 'user1');
      });

      test('generateLog creates audit log', () async {
        await manager.recordEvent(
          'e1',
          'user1',
          ResourceType.job,
          'job1',
          AuditEventType.create,
          AuditSeverity.info,
          AuditStatus.success,
        );

        final log = await manager.generateLog(
          'log1',
          DateTime.now().subtract(Duration(hours: 1)),
          DateTime.now(),
        );

        expect(log.logId, 'log1');
        expect(log.eventCount, greaterThan(0));
      });

      test('generateTrail creates user audit trail', () async {
        await manager.recordEvent(
          'e1',
          'user1',
          ResourceType.job,
          'job1',
          AuditEventType.create,
          AuditSeverity.info,
          AuditStatus.success,
        );

        final trail = await manager.generateTrail(
          't1',
          'user1',
          DateTime.now().subtract(Duration(hours: 1)),
          DateTime.now(),
        );

        expect(trail.trailId, 't1');
        expect(trail.userId, 'user1');
      });

      test('addPolicy stores policy', () async {
        final policy = CompliancePolicy(
          policyId: 'p1',
          name: 'Test',
          description: 'Test Policy',
          rules: ['RULE1'],
          createdAt: DateTime.now(),
        );

        final result = await manager.addPolicy(policy);

        expect(result.policyId, 'p1');
      });
    });

    // ==================== Facade Tests ====================
    group('Facade Tests', () {
      late AuditManagerFacade facade;

      setUp(() {
        facade = AuditManagerFacade();
      });

      test('recordEvent records audit event', () async {
        final event = await facade.recordEvent(
          'e1',
          'user1',
          ResourceType.job,
          'job1',
          AuditEventType.create,
          AuditSeverity.info,
          AuditStatus.success,
        );

        expect(event.eventId, 'e1');
      });

      test('createPolicy creates compliance policy', () async {
        final policy = await facade.createPolicy(
          'p1',
          'Test Policy',
          'Test Description',
          ['RULE1', 'RULE2'],
        );

        expect(policy.policyId, 'p1');
        expect(policy.ruleCount, 2);
      });

      test('generateLog creates audit log', () async {
        await facade.recordEvent(
          'e1',
          'user1',
          ResourceType.job,
          'job1',
          AuditEventType.create,
          AuditSeverity.info,
          AuditStatus.success,
        );

        final log = await facade.generateLog(
          'log1',
          DateTime.now().subtract(Duration(hours: 1)),
          DateTime.now(),
        );

        expect(log.logId, 'log1');
      });

      test('generateTrail creates user trail', () async {
        await facade.recordEvent(
          'e1',
          'user1',
          ResourceType.job,
          'job1',
          AuditEventType.create,
          AuditSeverity.info,
          AuditStatus.success,
        );

        final trail = await facade.generateTrail(
          't1',
          'user1',
          DateTime.now().subtract(Duration(hours: 1)),
          DateTime.now(),
        );

        expect(trail.trailId, 't1');
      });

      test('generateReport creates compliance report', () async {
        await facade.createPolicy('p1', 'Test', 'Test', ['RULE']);
        await facade.recordEvent(
          'e1',
          'user1',
          ResourceType.job,
          'job1',
          AuditEventType.create,
          AuditSeverity.info,
          AuditStatus.success,
        );

        final report = await facade.generateReport(
          'r1',
          DateTime.now().subtract(Duration(hours: 1)),
          DateTime.now(),
        );

        expect(report.reportId, 'r1');
      });
    });

    // ==================== Integration Tests ====================
    group('Integration Tests', () {
      late AuditManagerFacade facade;

      setUp(() {
        facade = AuditManagerFacade();
      });

      test('End-to-end audit workflow', () async {
        // Create policy
        await facade.createPolicy('p1', 'Data Protection', 'Protect data', ['NO_EXPORT']);

        // Record events
        await facade.recordEvent('e1', 'user1', ResourceType.job, 'job1', AuditEventType.create, AuditSeverity.info, AuditStatus.success);
        await facade.recordEvent('e2', 'user1', ResourceType.job, 'job1', AuditEventType.update, AuditSeverity.warning, AuditStatus.success);

        // Generate log
        final log = await facade.generateLog(
          'log1',
          DateTime.now().subtract(Duration(hours: 1)),
          DateTime.now(),
        );
        expect(log.eventCount, greaterThan(0));

        // Generate report
        final report = await facade.generateReport(
          'r1',
          DateTime.now().subtract(Duration(hours: 1)),
          DateTime.now(),
        );
        expect(report.reportId, 'r1');
      });

      test('Critical event detection workflow', () async {
        await facade.recordEvent('e1', 'user1', ResourceType.user, 'user1', AuditEventType.delete, AuditSeverity.critical, AuditStatus.success);

        final trail = await facade.generateTrail(
          't1',
          'user1',
          DateTime.now().subtract(Duration(hours: 1)),
          DateTime.now(),
        );

        expect(trail.eventCount, 1);
      });

      test('Multi-user audit trail', () async {
        await facade.recordEvent('e1', 'user1', ResourceType.job, 'job1', AuditEventType.create, AuditSeverity.info, AuditStatus.success);
        await facade.recordEvent('e2', 'user2', ResourceType.job, 'job2', AuditEventType.create, AuditSeverity.info, AuditStatus.success);

        final trail1 = await facade.generateTrail(
          't1',
          'user1',
          DateTime.now().subtract(Duration(hours: 1)),
          DateTime.now(),
        );
        final trail2 = await facade.generateTrail(
          't2',
          'user2',
          DateTime.now().subtract(Duration(hours: 1)),
          DateTime.now(),
        );

        expect(trail1.userId, 'user1');
        expect(trail2.userId, 'user2');
      });

      test('Report markdown generation', () async {
        await facade.createPolicy('p1', 'Test', 'Test', ['RULE']);
        await facade.recordEvent('e1', 'user1', ResourceType.job, 'job1', AuditEventType.create, AuditSeverity.info, AuditStatus.success);

        final report = await facade.generateReport(
          'r1',
          DateTime.now().subtract(Duration(hours: 1)),
          DateTime.now(),
        );

        final markdown = report.stats.complianceLevel;
        expect(markdown.isNotEmpty, true);
      });

      test('Compliance violation workflow', () async {
        await facade.createPolicy('p1', 'Strict', 'Strict compliance', ['NO_FAILURES']);
        await facade.recordEvent('e1', 'user1', ResourceType.job, 'job1', AuditEventType.create, AuditSeverity.critical, AuditStatus.failure);

        final report = await facade.generateReport(
          'r1',
          DateTime.now().subtract(Duration(hours: 1)),
          DateTime.now(),
        );

        expect(report.violations.isNotEmpty, true);
      });
    });
  });
}
