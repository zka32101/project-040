import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/security_models.dart';
import 'package:project_040/services/security_service.dart';

void main() {
  group('Phase 89: Advanced Security & Compliance', () {
    group('Enum Tests', () {
      test('EncryptionType enum values', () {
        expect(EncryptionType.aes256.displayName, 'AES-256');
        expect(EncryptionType.rsa2048.displayName, 'RSA-2048');
        expect(EncryptionType.values.length, 6);
      });

      test('ComplianceFramework enum values', () {
        expect(ComplianceFramework.gdpr.displayName, 'GDPR');
        expect(ComplianceFramework.hipaa.displayName, 'HIPAA');
        expect(ComplianceFramework.values.length, 6);
      });

      test('IncidentSeverity enum values', () {
        expect(IncidentSeverity.critical.displayName, 'クリティカル');
        expect(IncidentSeverity.values.length, 5);
      });

      test('All enums have display names', () {
        for (final type in EncryptionType.values) {
          expect(type.displayName, isNotEmpty);
        }
      });
    });

    group('Model Tests', () {
      test('EncryptionKey.isExpired detects expiration', () {
        final now = DateTime.now();
        final key = EncryptionKey(
          id: 'key_1',
          keyName: 'Test Key',
          encryptionType: EncryptionType.aes256,
          createdAt: now,
          expiresAt: now.subtract(Duration(days: 1)),
        );
        expect(key.isExpired, true);
      });

      test('EncryptionKey.needsRotation works correctly', () {
        final now = DateTime.now();
        final key = EncryptionKey(
          id: 'key_1',
          keyName: 'Test Key',
          encryptionType: EncryptionType.aes256,
          createdAt: now.subtract(Duration(days: 100)),
          expiresAt: now.add(Duration(days: 265)),
          rotationSchedule: 90,
        );
        expect(key.needsRotation, true);
      });

      test('SecurityIncident.durationSeconds calculates correctly', () {
        final now = DateTime.now();
        final incident = SecurityIncident(
          id: 'inc_1',
          incidentType: 'Breach',
          severity: IncidentSeverity.critical,
          detectedAt: now.subtract(Duration(minutes: 5)),
          createdAt: now,
          resolvedAt: now,
        );
        expect(incident.durationSeconds, lessThan(600));
      });

      test('ComplianceAssessment.isCompliant checks status', () {
        final now = DateTime.now();
        final assessment = ComplianceAssessment(
          id: 'assess_1',
          framework: ComplianceFramework.gdpr,
          assessmentDate: now,
          createdAt: now,
          status: ComplianceStatus.compliant,
        );
        expect(assessment.isCompliant, true);
      });

      test('VulnerabilityReport.isCritical checks CVSS', () {
        final now = DateTime.now();
        final report = VulnerabilityReport(
          id: 'vuln_1',
          vulnerabilityName: 'Critical CVE',
          severity: IncidentSeverity.critical,
          discoveredAt: now,
          createdAt: now,
          cvssScore: 9.5,
        );
        expect(report.isCritical, true);
      });

      test('PrivacyPolicy.needsReview checks age', () {
        final now = DateTime.now();
        final policy = PrivacyPolicy(
          id: 'policy_1',
          policyName: 'GDPR Policy',
          privacyLevel: PrivacyLevel.confidential,
          createdAt: now.subtract(Duration(days: 120)),
          version: '1.0',
          lastUpdatedAt: now.subtract(Duration(days: 120)),
        );
        expect(policy.needsReview, true);
      });
    });

    group('Repository Tests', () {
      late InMemorySecurityRepository repository;

      setUp(() {
        repository = InMemorySecurityRepository();
      });

      test('createEncryptionKey stores key', () async {
        final now = DateTime.now();
        final key = EncryptionKey(
          id: 'key_1',
          keyName: 'Test Key',
          encryptionType: EncryptionType.aes256,
          createdAt: now,
          expiresAt: now.add(Duration(days: 365)),
        );

        await repository.createEncryptionKey(key);
        final retrieved = await repository.getEncryptionKeyById('key_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.keyName, 'Test Key');
      });

      test('getActiveEncryptionKeys filters correctly', () async {
        final now = DateTime.now();
        await repository.createEncryptionKey(EncryptionKey(
          id: 'key_1',
          keyName: 'Active Key',
          encryptionType: EncryptionType.aes256,
          createdAt: now,
          expiresAt: now.add(Duration(days: 365)),
          isActive: true,
        ));

        final active = await repository.getActiveEncryptionKeys();
        expect(active.length, 1);
      });

      test('createAuditLog stores log', () async {
        final now = DateTime.now();
        final log = SecurityAuditLog(
          id: 'log_1',
          userId: 'user_1',
          action: SecurityAuditAction.login,
          timestamp: now,
          createdAt: now,
        );

        await repository.createAuditLog(log);
        final retrieved = await repository.getAuditLogById('log_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.action, SecurityAuditAction.login);
      });

      test('getFailedAuditLogs filters correctly', () async {
        final now = DateTime.now();
        await repository.createAuditLog(SecurityAuditLog(
          id: 'log_1',
          userId: 'user_1',
          action: SecurityAuditAction.login,
          timestamp: now,
          createdAt: now,
          status: 'failure',
        ));

        final failed = await repository.getFailedAuditLogs();
        expect(failed.length, 1);
      });

      test('createSecurityIncident stores incident', () async {
        final now = DateTime.now();
        final incident = SecurityIncident(
          id: 'inc_1',
          incidentType: 'Data Breach',
          severity: IncidentSeverity.critical,
          detectedAt: now,
          createdAt: now,
        );

        await repository.createSecurityIncident(incident);
        final retrieved = await repository.getSecurityIncidentById('inc_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.isCritical, true);
      });

      test('getCriticalIncidents filters severity', () async {
        final now = DateTime.now();
        await repository.createSecurityIncident(SecurityIncident(
          id: 'inc_1',
          incidentType: 'Critical Issue',
          severity: IncidentSeverity.critical,
          detectedAt: now,
          createdAt: now,
        ));

        final critical = await repository.getCriticalIncidents();
        expect(critical.length, 1);
      });

      test('createAssessment stores assessment', () async {
        final now = DateTime.now();
        final assessment = ComplianceAssessment(
          id: 'assess_1',
          framework: ComplianceFramework.gdpr,
          assessmentDate: now,
          createdAt: now,
          complianceScore: 0.95,
        );

        await repository.createAssessment(assessment);
        final retrieved = await repository.getAssessmentById('assess_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.complianceScore, 0.95);
      });

      test('getCompliantAssessments filters status', () async {
        final now = DateTime.now();
        await repository.createAssessment(ComplianceAssessment(
          id: 'assess_1',
          framework: ComplianceFramework.gdpr,
          assessmentDate: now,
          createdAt: now,
          status: ComplianceStatus.compliant,
        ));

        final compliant = await repository.getCompliantAssessments();
        expect(compliant.length, 1);
      });

      test('getAverageComplianceScore calculates correctly', () async {
        final now = DateTime.now();
        await repository.createAssessment(ComplianceAssessment(
          id: 'assess_1',
          framework: ComplianceFramework.gdpr,
          assessmentDate: now,
          createdAt: now,
          complianceScore: 0.8,
        ));

        await repository.createAssessment(ComplianceAssessment(
          id: 'assess_2',
          framework: ComplianceFramework.hipaa,
          assessmentDate: now,
          createdAt: now,
          complianceScore: 0.9,
        ));

        final avg = await repository.getAverageComplianceScore();
        expect(avg, 0.85);
      });

      test('createVulnerabilityReport stores report', () async {
        final now = DateTime.now();
        final report = VulnerabilityReport(
          id: 'vuln_1',
          vulnerabilityName: 'SQL Injection',
          severity: IncidentSeverity.critical,
          discoveredAt: now,
          createdAt: now,
          cvssScore: 9.8,
        );

        await repository.createVulnerabilityReport(report);
        final retrieved = await repository.getVulnerabilityReportById('vuln_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.isCritical, true);
      });

      test('getCriticalVulnerabilities filters by CVSS', () async {
        final now = DateTime.now();
        await repository.createVulnerabilityReport(VulnerabilityReport(
          id: 'vuln_1',
          vulnerabilityName: 'Critical Vuln',
          severity: IncidentSeverity.critical,
          discoveredAt: now,
          createdAt: now,
          cvssScore: 9.5,
        ));

        final critical = await repository.getCriticalVulnerabilities();
        expect(critical.length, 1);
      });

      test('createAccessLog stores log', () async {
        final now = DateTime.now();
        final log = DataAccessLog(
          id: 'access_1',
          userId: 'user_1',
          dataId: 'data_1',
          accessTime: now,
          createdAt: now,
        );

        await repository.createAccessLog(log);
        final retrieved = await repository.getAccessLogById('access_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.userId, 'user_1');
      });

      test('getDeniedAccessLogs filters denials', () async {
        final now = DateTime.now();
        await repository.createAccessLog(DataAccessLog(
          id: 'access_1',
          userId: 'user_1',
          dataId: 'data_1',
          accessTime: now,
          createdAt: now,
          status: 'denied',
        ));

        final denied = await repository.getDeniedAccessLogs();
        expect(denied.length, 1);
      });

      test('createViolation stores violation', () async {
        final now = DateTime.now();
        final violation = ComplianceViolation(
          id: 'viol_1',
          violationType: 'Data Leak',
          framework: ComplianceFramework.gdpr,
          detectedAt: now,
          createdAt: now,
        );

        await repository.createViolation(violation);
        final retrieved = await repository.getViolationById('viol_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.framework, ComplianceFramework.gdpr);
      });

      test('getOpenViolations filters status', () async {
        final now = DateTime.now();
        await repository.createViolation(ComplianceViolation(
          id: 'viol_1',
          violationType: 'Breach',
          framework: ComplianceFramework.hipaa,
          detectedAt: now,
          createdAt: now,
          status: 'open',
        ));

        final open = await repository.getOpenViolations();
        expect(open.length, 1);
      });

      test('listEncryptionKeys returns all keys', () async {
        final now = DateTime.now();
        await repository.createEncryptionKey(EncryptionKey(
          id: 'key_1',
          keyName: 'Key 1',
          encryptionType: EncryptionType.aes256,
          createdAt: now,
          expiresAt: now.add(Duration(days: 365)),
        ));

        final keys = await repository.listEncryptionKeys();
        expect(keys.length, 1);
      });

      test('getEncryptionKeyCount returns total', () async {
        final now = DateTime.now();
        await repository.createEncryptionKey(EncryptionKey(
          id: 'key_1',
          keyName: 'Key 1',
          encryptionType: EncryptionType.aes256,
          createdAt: now,
          expiresAt: now.add(Duration(days: 365)),
        ));

        final count = await repository.getEncryptionKeyCount();
        expect(count, 1);
      });
    });

    group('Facade Tests', () {
      late SecurityFacade facade;
      late InMemorySecurityRepository repository;

      setUp(() {
        repository = InMemorySecurityRepository();
        final manager = SecurityManager(repository);
        facade = SecurityFacade(manager);
      });

      test('createEncryptionKey via facade', () async {
        final key = await facade.createEncryptionKey(
          'Test Key',
          EncryptionType.aes256,
        );

        expect(key.keyName, 'Test Key');
        expect(key.encryptionType, EncryptionType.aes256);
      });

      test('logSecurityAction via facade', () async {
        await facade.logSecurityAction(
          'user_1',
          SecurityAuditAction.login,
        );

        final logs = await repository.getAuditLogsByUserId('user_1');
        expect(logs.length, 1);
      });

      test('reportSecurityIncident via facade', () async {
        final incident = await facade.reportSecurityIncident(
          'Data Breach',
          IncidentSeverity.critical,
          'Unauthorized access detected',
        );

        expect(incident.incidentType, 'Data Breach');
        expect(incident.severity, IncidentSeverity.critical);
      });

      test('createAssessment via facade', () async {
        final assessment = await facade.createAssessment(
          ComplianceFramework.gdpr,
        );

        expect(assessment.framework, ComplianceFramework.gdpr);
      });

      test('getCriticalIncidentCount via facade', () async {
        await repository.createSecurityIncident(SecurityIncident(
          id: 'inc_1',
          incidentType: 'Critical',
          severity: IncidentSeverity.critical,
          detectedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ));

        final count = await facade.getCriticalIncidentCount();
        expect(count, greaterThanOrEqualTo(1));
      });

      test('getComplianceScore via facade', () async {
        await repository.createAssessment(ComplianceAssessment(
          id: 'assess_1',
          framework: ComplianceFramework.gdpr,
          assessmentDate: DateTime.now(),
          createdAt: DateTime.now(),
          complianceScore: 0.95,
        ));

        final score = await facade.getComplianceScore();
        expect(score, greaterThan(0.0));
      });

      test('getCriticalVulnerabilities via facade', () async {
        final now = DateTime.now();
        await repository.createVulnerabilityReport(VulnerabilityReport(
          id: 'vuln_1',
          vulnerabilityName: 'Critical CVE',
          severity: IncidentSeverity.critical,
          discoveredAt: now,
          createdAt: now,
          cvssScore: 9.5,
        ));

        final vulns = await facade.getCriticalVulnerabilities();
        expect(vulns.length, greaterThanOrEqualTo(1));
      });
    });

    group('Edge Cases', () {
      late InMemorySecurityRepository repository;

      setUp(() {
        repository = InMemorySecurityRepository();
      });

      test('getEncryptionKeyById returns null for missing', () async {
        final key = await repository.getEncryptionKeyById('nonexistent');
        expect(key, isNull);
      });

      test('listEncryptionKeys returns empty when none', () async {
        final keys = await repository.listEncryptionKeys();
        expect(keys, isEmpty);
      });

      test('getAverageComplianceScore returns 0 for empty', () async {
        final avg = await repository.getAverageComplianceScore();
        expect(avg, 0.0);
      });

      test('EncryptionKey with zero rotation shows false', () {
        final now = DateTime.now();
        final key = EncryptionKey(
          id: 'key_1',
          keyName: 'Test',
          encryptionType: EncryptionType.aes256,
          createdAt: now,
          expiresAt: now.add(Duration(days: 365)),
          rotationSchedule: null,
        );

        expect(key.needsRotation, false);
      });
    });

    group('Performance Tests', () {
      late InMemorySecurityRepository repository;

      setUp(() {
        repository = InMemorySecurityRepository();
      });

      test('Bulk key creation performance', () async {
        final stopwatch = Stopwatch()..start();
        final now = DateTime.now();

        for (int i = 0; i < 100; i++) {
          await repository.createEncryptionKey(EncryptionKey(
            id: 'key_$i',
            keyName: 'Key $i',
            encryptionType: EncryptionType.aes256,
            createdAt: now,
            expiresAt: now.add(Duration(days: 365)),
          ));
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      test('Query performance on large audit log set', () async {
        final now = DateTime.now();

        for (int i = 0; i < 50; i++) {
          await repository.createAuditLog(SecurityAuditLog(
            id: 'log_$i',
            userId: 'user_${i % 5}',
            action: i % 2 == 0
                ? SecurityAuditAction.login
                : SecurityAuditAction.logout,
            timestamp: now,
            createdAt: now,
          ));
        }

        final stopwatch = Stopwatch()..start();
        final logs = await repository.getAuditLogsByUserId('user_0');
        stopwatch.stop();

        expect(logs.length, greaterThan(0));
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });
    });
  });
}
