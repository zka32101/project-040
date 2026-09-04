import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/security_models.dart';
import 'package:project_040/services/security_service.dart';

void main() {
  group('Phase 54: Security & Compliance', () {
    // ========== Enum Tests ==========
    group('Enum Tests', () {
      test('EncryptionType values', () {
        expect(EncryptionType.aes256.value, 'aes256');
        expect(EncryptionType.rsa2048.value, 'rsa2048');
        expect(EncryptionType.sha256.value, 'sha256');
        expect(EncryptionType.bcrypt.value, 'bcrypt');
      });

      test('SecurityLevel ordering', () {
        final levels = [SecurityLevel.critical, SecurityLevel.high, SecurityLevel.medium, SecurityLevel.low];
        expect(levels.length, 4);
        expect(levels[0].value, 'critical');
      });

      test('ComplianceStatus values', () {
        expect(ComplianceStatus.compliant.value, 'compliant');
        expect(ComplianceStatus.nonCompliant.value, 'non_compliant');
        expect(ComplianceStatus.partiallyCompliant.value, 'partially_compliant');
        expect(ComplianceStatus.unknown.value, 'unknown');
      });
    });

    // ========== Model Tests ==========
    group('EncryptionKey Model Tests', () {
      test('Valid key properties', () {
        final key = EncryptionKey(
          keyId: 'key1',
          keyName: 'Main Key',
          encryptionType: EncryptionType.aes256,
          createdAt: DateTime.now(),
          isActive: true,
        );
        expect(key.isValid, true);
        expect(key.isExpired, false);
      });

      test('Expired key detection', () {
        final key = EncryptionKey(
          keyId: 'key2',
          keyName: 'Expired Key',
          encryptionType: EncryptionType.aes256,
          createdAt: DateTime.now().subtract(Duration(days: 180)),
          expiresAt: DateTime.now().subtract(Duration(days: 1)),
          isActive: true,
        );
        expect(key.isExpired, true);
        expect(key.isValid, false);
      });

      test('Key rotation detection', () {
        final key = EncryptionKey(
          keyId: 'key3',
          keyName: 'Old Key',
          encryptionType: EncryptionType.aes256,
          createdAt: DateTime.now().subtract(Duration(days: 180)),
          rotatedAt: DateTime.now().subtract(Duration(days: 100)),
          isActive: true,
        );
        expect(key.needsRotation, true);
      });

      test('Inactive key is invalid', () {
        final key = EncryptionKey(
          keyId: 'key4',
          keyName: 'Inactive Key',
          encryptionType: EncryptionType.aes256,
          createdAt: DateTime.now(),
          isActive: false,
        );
        expect(key.isValid, false);
      });
    });

    group('TokenInfo Model Tests', () {
      test('Valid token', () {
        final token = TokenInfo(
          tokenId: 'tok1',
          userId: 'user1',
          token: 'token_value',
          issuedAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
          scopes: ['read', 'write'],
          securityLevel: SecurityLevel.high,
        );
        expect(token.isValid, true);
        expect(token.isExpired, false);
        expect(token.timeUntilExpiration, isNotNull);
      });

      test('Expired token', () {
        final token = TokenInfo(
          tokenId: 'tok2',
          userId: 'user1',
          token: 'token_value',
          issuedAt: DateTime.now().subtract(Duration(hours: 2)),
          expiresAt: DateTime.now().subtract(Duration(hours: 1)),
          scopes: ['read'],
          securityLevel: SecurityLevel.medium,
        );
        expect(token.isExpired, true);
        expect(token.isValid, false);
        expect(token.timeUntilExpiration, null);
      });

      test('Revoked token', () {
        final token = TokenInfo(
          tokenId: 'tok3',
          userId: 'user1',
          token: 'token_value',
          issuedAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
          scopes: ['read'],
          securityLevel: SecurityLevel.medium,
          isRevoked: true,
        );
        expect(token.isValid, false);
      });

      test('Token scopes', () {
        final token = TokenInfo(
          tokenId: 'tok4',
          userId: 'user1',
          token: 'token_value',
          issuedAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
          scopes: ['read', 'write', 'delete'],
          securityLevel: SecurityLevel.high,
        );
        expect(token.scopes.length, 3);
      });
    });

    group('PasswordPolicy Model Tests', () {
      test('Strict password policy', () {
        final policy = PasswordPolicy(
          policyId: 'policy1',
          minLength: 12,
          maxLength: 128,
          requireUppercase: true,
          requireLowercase: true,
          requireNumbers: true,
          requireSpecialChars: true,
          expirationDays: 90,
          historyCount: 5,
          createdAt: DateTime.now(),
        );
        expect(policy.isStrict, true);
      });

      test('Lenient password policy', () {
        final policy = PasswordPolicy(
          policyId: 'policy2',
          minLength: 6,
          maxLength: 128,
          requireUppercase: false,
          requireLowercase: false,
          requireNumbers: false,
          requireSpecialChars: false,
          expirationDays: 365,
          historyCount: 1,
          createdAt: DateTime.now(),
        );
        expect(policy.isStrict, false);
      });

      test('Complexity score calculation', () {
        final policy = PasswordPolicy(
          policyId: 'policy3',
          minLength: 12,
          maxLength: 128,
          requireUppercase: true,
          requireLowercase: true,
          requireNumbers: true,
          requireSpecialChars: true,
          expirationDays: 90,
          historyCount: 5,
          createdAt: DateTime.now(),
        );
        expect(policy.complexityScore, greaterThan(0));
      });
    });

    group('SecurityEvent Model Tests', () {
      test('Critical security event', () {
        final event = SecurityEvent(
          eventId: 'event1',
          userId: 'user1',
          eventType: 'failed_login',
          severity: SecurityLevel.critical,
          occurredAt: DateTime.now(),
          ipAddress: '192.168.1.1',
        );
        expect(event.isCritical, true);
        expect(event.isWarning, false);
      });

      test('Warning level event', () {
        final event = SecurityEvent(
          eventId: 'event2',
          userId: 'user1',
          eventType: 'permission_change',
          severity: SecurityLevel.high,
          occurredAt: DateTime.now(),
          ipAddress: '192.168.1.1',
        );
        expect(event.isWarning, true);
      });

      test('Anomalous event detection', () {
        final event = SecurityEvent(
          eventId: 'event3',
          userId: 'user1',
          eventType: 'login',
          severity: SecurityLevel.medium,
          occurredAt: DateTime.now(),
          ipAddress: '192.168.1.1',
          isAnomalous: true,
        );
        expect(event.isAnomalous, true);
      });
    });

    group('VulnerabilityAssessment Model Tests', () {
      test('High risk vulnerability', () {
        final assessment = VulnerabilityAssessment(
          assessmentId: 'vuln1',
          resourceId: 'res1',
          resourceType: 'database',
          vulnerabilities: ['SQL Injection', 'XSS'],
          riskScore: 0.85,
          assessedAt: DateTime.now(),
        );
        expect(assessment.isHighRisk, true);
        expect(assessment.vulnerabilityCount, 2);
      });

      test('Low risk vulnerability', () {
        final assessment = VulnerabilityAssessment(
          assessmentId: 'vuln2',
          resourceId: 'res2',
          resourceType: 'api',
          vulnerabilities: ['Outdated library'],
          riskScore: 0.3,
          assessedAt: DateTime.now(),
        );
        expect(assessment.isHighRisk, false);
      });

      test('Resolved vulnerability', () {
        final assessment = VulnerabilityAssessment(
          assessmentId: 'vuln3',
          resourceId: 'res3',
          resourceType: 'app',
          vulnerabilities: [],
          riskScore: 0.0,
          assessedAt: DateTime.now(),
          isResolved: true,
        );
        expect(assessment.isResolved, true);
      });
    });

    group('SecurityAudit Model Tests', () {
      test('Passing audit', () {
        final events = <SecurityEvent>[];
        final audit = SecurityAudit(
          auditId: 'audit1',
          events: events,
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
          totalEvents: 10,
          criticalEvents: 0,
          compliancePercentage: 0.98,
        );
        expect(audit.isPassing, true);
      });

      test('Failing audit', () {
        final events = <SecurityEvent>[];
        final audit = SecurityAudit(
          auditId: 'audit2',
          events: events,
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
          totalEvents: 20,
          criticalEvents: 5,
          compliancePercentage: 0.80,
        );
        expect(audit.isPassing, false);
      });

      test('Critical event rate', () {
        final events = <SecurityEvent>[];
        final audit = SecurityAudit(
          auditId: 'audit3',
          events: events,
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
          totalEvents: 10,
          criticalEvents: 2,
          compliancePercentage: 0.95,
        );
        expect(audit.criticalEventRate, 0.2);
      });
    });

    // ========== Repository Tests ==========
    group('MemorySecurityRepository Tests', () {
      late MemorySecurityRepository repository;

      setUp(() {
        repository = MemorySecurityRepository();
      });

      test('Add and retrieve encryption key', () async {
        final key = EncryptionKey(
          keyId: 'key1',
          keyName: 'Test Key',
          encryptionType: EncryptionType.aes256,
          createdAt: DateTime.now(),
        );
        await repository.addEncryptionKey(key);
        final retrieved = await repository.getEncryptionKey('key1');
        expect(retrieved, isNotNull);
        expect(retrieved!.keyName, 'Test Key');
      });

      test('Get all encryption keys', () async {
        final key1 = EncryptionKey(
          keyId: 'key1',
          keyName: 'Key 1',
          encryptionType: EncryptionType.aes256,
          createdAt: DateTime.now(),
        );
        final key2 = EncryptionKey(
          keyId: 'key2',
          keyName: 'Key 2',
          encryptionType: EncryptionType.rsa2048,
          createdAt: DateTime.now(),
        );
        await repository.addEncryptionKey(key1);
        await repository.addEncryptionKey(key2);
        final keys = await repository.getAllEncryptionKeys();
        expect(keys.length, 2);
      });

      test('Add and retrieve token', () async {
        final token = TokenInfo(
          tokenId: 'tok1',
          userId: 'user1',
          token: 'token_value',
          issuedAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
          scopes: ['read'],
          securityLevel: SecurityLevel.high,
        );
        await repository.addToken(token);
        final retrieved = await repository.getToken('tok1');
        expect(retrieved, isNotNull);
        expect(retrieved!.userId, 'user1');
      });

      test('Get user tokens', () async {
        final token1 = TokenInfo(
          tokenId: 'tok1',
          userId: 'user1',
          token: 'token1',
          issuedAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
          scopes: ['read'],
          securityLevel: SecurityLevel.high,
        );
        final token2 = TokenInfo(
          tokenId: 'tok2',
          userId: 'user1',
          token: 'token2',
          issuedAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
          scopes: ['write'],
          securityLevel: SecurityLevel.high,
        );
        await repository.addToken(token1);
        await repository.addToken(token2);
        final tokens = await repository.getUserTokens('user1');
        expect(tokens.length, 2);
      });

      test('Revoke token', () async {
        final token = TokenInfo(
          tokenId: 'tok1',
          userId: 'user1',
          token: 'token_value',
          issuedAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
          scopes: ['read'],
          securityLevel: SecurityLevel.high,
        );
        await repository.addToken(token);
        await repository.revokeToken('tok1');
        final revoked = await repository.getToken('tok1');
        expect(revoked!.isRevoked, true);
      });

      test('Add password policy', () async {
        final policy = PasswordPolicy(
          policyId: 'policy1',
          minLength: 12,
          maxLength: 128,
          requireUppercase: true,
          requireLowercase: true,
          requireNumbers: true,
          requireSpecialChars: true,
          expirationDays: 90,
          historyCount: 5,
          createdAt: DateTime.now(),
        );
        await repository.addPasswordPolicy(policy);
        final retrieved = await repository.getPasswordPolicy('policy1');
        expect(retrieved, isNotNull);
      });

      test('Add and get security events', () async {
        final event = SecurityEvent(
          eventId: 'event1',
          userId: 'user1',
          eventType: 'login',
          severity: SecurityLevel.low,
          occurredAt: DateTime.now(),
          ipAddress: '192.168.1.1',
        );
        await repository.addSecurityEvent(event);
        final events = await repository.getUserSecurityEvents('user1');
        expect(events.length, 1);
      });

      test('Get anomalous events', () async {
        final event1 = SecurityEvent(
          eventId: 'event1',
          userId: 'user1',
          eventType: 'login',
          severity: SecurityLevel.medium,
          occurredAt: DateTime.now(),
          ipAddress: '192.168.1.1',
          isAnomalous: true,
        );
        final event2 = SecurityEvent(
          eventId: 'event2',
          userId: 'user2',
          eventType: 'logout',
          severity: SecurityLevel.low,
          occurredAt: DateTime.now(),
          ipAddress: '192.168.1.2',
          isAnomalous: false,
        );
        await repository.addSecurityEvent(event1);
        await repository.addSecurityEvent(event2);
        final anomalous = await repository.getAnomalousEvents();
        expect(anomalous.length, 1);
      });

      test('Add vulnerability assessment', () async {
        final assessment = VulnerabilityAssessment(
          assessmentId: 'vuln1',
          resourceId: 'res1',
          resourceType: 'database',
          vulnerabilities: ['SQL Injection'],
          riskScore: 0.85,
          assessedAt: DateTime.now(),
        );
        await repository.addVulnerabilityAssessment(assessment);
        final retrieved = await repository.getVulnerabilityAssessment('vuln1');
        expect(retrieved, isNotNull);
      });

      test('Get high risk assessments', () async {
        final high = VulnerabilityAssessment(
          assessmentId: 'vuln1',
          resourceId: 'res1',
          resourceType: 'app',
          vulnerabilities: [],
          riskScore: 0.8,
          assessedAt: DateTime.now(),
        );
        final low = VulnerabilityAssessment(
          assessmentId: 'vuln2',
          resourceId: 'res2',
          resourceType: 'app',
          vulnerabilities: [],
          riskScore: 0.3,
          assessedAt: DateTime.now(),
        );
        await repository.addVulnerabilityAssessment(high);
        await repository.addVulnerabilityAssessment(low);
        final highRisk = await repository.getHighRiskAssessments();
        expect(highRisk.length, 1);
      });
    });

    // ========== Engine Tests ==========
    group('MemoryEncryptionEngine Tests', () {
      late MemorySecurityRepository repository;
      late MemoryEncryptionEngine engine;

      setUp(() async {
        repository = MemorySecurityRepository();
        engine = MemoryEncryptionEngine(repository);
        
        final key = EncryptionKey(
          keyId: 'key1',
          keyName: 'Test Key',
          encryptionType: EncryptionType.aes256,
          createdAt: DateTime.now(),
          isActive: true,
        );
        await repository.addEncryptionKey(key);
      });

      test('Encrypt data', () async {
        final encrypted = await engine.encryptData('secret', 'key1');
        expect(encrypted, isNotNull);
        expect(encrypted.startsWith('encrypted_'), true);
      });

      test('Decrypt data', () async {
        final encrypted = await engine.encryptData('secret', 'key1');
        final decrypted = await engine.decryptData(encrypted, 'key1');
        expect(decrypted, 'secret');
      });

      test('Hash password', () async {
        final hash = await engine.hashPassword('password123', EncryptionType.bcrypt);
        expect(hash, isNotNull);
        expect(hash.contains('bcrypt'), true);
      });

      test('Verify password', () async {
        final hash = await engine.hashPassword('password123', EncryptionType.bcrypt);
        final verified = await engine.verifyPassword('password123', hash, EncryptionType.bcrypt);
        expect(verified, true);
      });

      test('Verify wrong password', () async {
        final hash = await engine.hashPassword('password123', EncryptionType.bcrypt);
        final verified = await engine.verifyPassword('wrongpass', hash, EncryptionType.bcrypt);
        expect(verified, false);
      });

      test('Generate key', () async {
        final key = await engine.generateKey(EncryptionType.aes256);
        expect(key, isNotNull);
        expect(key.startsWith('key_'), true);
      });

      test('Rotate key', () async {
        final key = await repository.getEncryptionKey('key1');
        expect(key!.rotatedAt, isNull);
        await engine.rotateKey('key1');
        final rotated = await repository.getEncryptionKey('key1');
        expect(rotated!.rotatedAt, isNotNull);
      });
    });

    group('MemoryComplianceEngine Tests', () {
      late MemorySecurityRepository repository;
      late MemoryComplianceEngine engine;

      setUp(() {
        repository = MemorySecurityRepository();
        engine = MemoryComplianceEngine(repository);
      });

      test('Check compliance returns boolean', () async {
        final rule = ComplianceRule(
          ruleId: 'rule1',
          ruleName: 'GDPR Rule',
          description: 'GDPR compliance',
          framework: 'GDPR',
          isActive: true,
          createdAt: DateTime.now(),
          relatedPolicies: [],
        );
        final result = await engine.checkCompliance(rule, 'res1');
        expect(result, isNotNull);
      });

      test('Assess full compliance', () async {
        final rule1 = ComplianceRule(
          ruleId: 'rule1',
          ruleName: 'Rule 1',
          description: 'Test rule',
          framework: 'GDPR',
          isActive: true,
          createdAt: DateTime.now(),
          relatedPolicies: [],
        );
        final rule2 = ComplianceRule(
          ruleId: 'rule2',
          ruleName: 'Rule 2',
          description: 'Test rule',
          framework: 'GDPR',
          isActive: true,
          createdAt: DateTime.now(),
          relatedPolicies: [],
        );
        final status = await engine.assessCompliance([rule1, rule2]);
        expect(status, ComplianceStatus.compliant);
      });

      test('Get compliance recommendations', () async {
        final recs = await engine.getComplianceRecommendations(ComplianceStatus.compliant);
        expect(recs.isNotEmpty, true);
      });

      test('Calculate compliance score', () async {
        final audit = SecurityAudit(
          auditId: 'audit1',
          events: [],
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
          totalEvents: 10,
          criticalEvents: 1,
          compliancePercentage: 0.95,
        );
        final score = await engine.calculateComplianceScore(audit);
        expect(score, 0.95);
      });
    });

    // ========== Manager Tests ==========
    group('MemorySecurityManager Tests', () {
      late MemorySecurityRepository repository;
      late MemoryEncryptionEngine encryptionEngine;
      late MemoryComplianceEngine complianceEngine;
      late MemorySecurityManager manager;

      setUp(() {
        repository = MemorySecurityRepository();
        encryptionEngine = MemoryEncryptionEngine(repository);
        complianceEngine = MemoryComplianceEngine(repository);
        manager = MemorySecurityManager(repository, encryptionEngine, complianceEngine);
      });

      test('Setup encryption key', () async {
        await manager.setupEncryptionKey('MyKey', EncryptionType.aes256);
        final keys = await repository.getAllEncryptionKeys();
        expect(keys.isNotEmpty, true);
      });

      test('Issue token', () async {
        await manager.issueToken('user1', ['read', 'write'], SecurityLevel.high);
        final tokens = await repository.getUserTokens('user1');
        expect(tokens.isNotEmpty, true);
      });

      test('Record security event', () async {
        await manager.recordSecurityEvent('user1', 'login', SecurityLevel.low);
        final events = await repository.getUserSecurityEvents('user1');
        expect(events.isNotEmpty, true);
      });

      test('Assess resource security', () async {
        await manager.assessResourceSecurity('res1', 'database');
        final assessments = await repository.getResourceAssessments('res1');
        expect(assessments.isNotEmpty, true);
      });

      test('Generate security report', () async {
        final start = DateTime.now().subtract(Duration(days: 30));
        final end = DateTime.now();
        final report = await manager.generateSecurityReport(start, end);
        expect(report, isNotNull);
        expect(report.generatedAt, isNotNull);
      });

      test('Check compliance status', () async {
        final status = await manager.checkComplianceStatus();
        expect(status, isNotNull);
      });
    });

    // ========== Facade Tests ==========
    group('SecurityFacade Tests', () {
      late SecurityFacade facade;

      setUp(() {
        final repository = MemorySecurityRepository();
        final encryptionEngine = MemoryEncryptionEngine(repository);
        final complianceEngine = MemoryComplianceEngine(repository);
        final manager = MemorySecurityManager(repository, encryptionEngine, complianceEngine);
        facade = SecurityFacade(manager, repository, encryptionEngine, complianceEngine);
      });

      test('Setup encryption key through facade', () async {
        await facade.setupEncryptionKey('Key1', EncryptionType.aes256);
        final keys = await facade.getAllEncryptionKeys();
        expect(keys.isNotEmpty, true);
      });

      test('Issue token through facade', () async {
        await facade.issueToken('user1', ['read'], SecurityLevel.high);
        final tokens = await facade.getUserTokens('user1');
        expect(tokens.isNotEmpty, true);
      });

      test('Record event through facade', () async {
        await facade.recordEvent('user1', 'login', SecurityLevel.low);
        expect(true, true);
      });

      test('Assess resource through facade', () async {
        await facade.assessResourceSecurity('res1', 'app');
        expect(true, true);
      });

      test('Generate report through facade', () async {
        final report = await facade.generateReport(
          DateTime.now().subtract(Duration(days: 30)),
          DateTime.now(),
        );
        expect(report, isNotNull);
      });
    });

    // ========== Integration Tests ==========
    group('Integration Tests', () {
      late SecurityFacade facade;

      setUp(() {
        final repository = MemorySecurityRepository();
        final encryptionEngine = MemoryEncryptionEngine(repository);
        final complianceEngine = MemoryComplianceEngine(repository);
        final manager = MemorySecurityManager(repository, encryptionEngine, complianceEngine);
        facade = SecurityFacade(manager, repository, encryptionEngine, complianceEngine);
      });

      test('Complete security workflow', () async {
        await facade.setupEncryptionKey('WorkflowKey', EncryptionType.aes256);
        await facade.issueToken('user1', ['read', 'write'], SecurityLevel.high);
        await facade.recordEvent('user1', 'login', SecurityLevel.low);
        
        final tokens = await facade.getUserTokens('user1');
        expect(tokens.isNotEmpty, true);
      });

      test('Compliance assessment workflow', () async {
        final status = await facade.checkCompliance();
        expect(status, isNotNull);
      });

      test('Security report generation', () async {
        await facade.recordEvent('user1', 'failed_login', SecurityLevel.high);
        final report = await facade.generateReport(
          DateTime.now().subtract(Duration(days: 7)),
          DateTime.now(),
        );
        expect(report.toMarkdown(), isNotEmpty);
      });

      test('Vulnerability assessment workflow', () async {
        await facade.assessResourceSecurity('db1', 'database');
        final vulns = await facade.getHighRiskVulnerabilities();
        expect(vulns, isNotNull);
      });

      test('Multiple keys management', () async {
        await facade.setupEncryptionKey('Key1', EncryptionType.aes256);
        await facade.setupEncryptionKey('Key2', EncryptionType.rsa2048);
        final keys = await facade.getAllEncryptionKeys();
        expect(keys.length, 2);
      });

      test('Token lifecycle management', () async {
        await facade.issueToken('user1', ['read'], SecurityLevel.medium);
        var tokens = await facade.getUserTokens('user1');
        expect(tokens.length, 1);
        
        final tokenId = tokens[0].tokenId;
        await facade.revokeToken(tokenId);
        tokens = await facade.getUserTokens('user1');
        final revokedToken = tokens.firstWhere((t) => t.tokenId == tokenId);
        expect(revokedToken.isRevoked, true);
      });
    });
  });
}
