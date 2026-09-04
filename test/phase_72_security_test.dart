import 'package:flutter_test/flutter_test.dart';
import '../lib/models/security_models.dart';
import '../lib/services/security_access_service.dart';

void main() {
  group('Phase 72: Security & Access Control', () {
    late SecurityRepository repository;
    late SecurityFacade facade;

    setUp(() {
      repository = MemorySecurityRepository();
      final accessEngine = AccessControlEngine(repository: repository);
      final authEngine = AuthenticationEngine(repository: repository);
      final auditEngine = AuditEngine(repository: repository);
      final secretEngine = SecretManagementEngine(repository: repository);
      final escalationEngine = PrivilegeEscalationEngine(repository: repository);
      final manager = SecurityManager(
        repository: repository,
        accessEngine: accessEngine,
        authEngine: authEngine,
        auditEngine: auditEngine,
        secretEngine: secretEngine,
        escalationEngine: escalationEngine,
      );
      facade = SecurityFacade(manager: manager);
    });

    // Enum Tests
    group('Enums', () {
      test('SecurityLevel contains all values', () {
        expect(SecurityLevel.values.length, equals(5));
        expect(SecurityLevel.values, contains(SecurityLevel.secret));
      });

      test('AccessType contains all values', () {
        expect(AccessType.values.length, equals(6));
      });

      test('AuthenticationMethod contains all values', () {
        expect(AuthenticationMethod.values.length, equals(6));
      });

      test('EncryptionMethod contains all values', () {
        expect(EncryptionMethod.values.length, equals(5));
      });

      test('PermissionScope contains all values', () {
        expect(PermissionScope.values.length, equals(5));
      });

      test('AuditAction contains all values', () {
        expect(AuditAction.values.length, equals(6));
      });
    });

    // SecurityPolicy Tests
    group('SecurityPolicy', () {
      test('create strict security policy', () {
        final policy = SecurityPolicy(
          policyId: 'policy_1',
          policyName: 'Strict Security',
          description: 'Enforced security policy',
          minSecurityLevel: SecurityLevel.restricted,
          requiredAuthMethods: [AuthenticationMethod.password, AuthenticationMethod.mfa],
          passwordMinLength: 16,
          mfaMaxAgeInDays: 30,
          enforceEncryption: true,
          createdAt: DateTime.now(),
        );

        expect(policy.isStrict, isTrue);
        expect(policy.isMFARequired, isTrue);
      });

      test('MFA requirement checking', () {
        final policy = SecurityPolicy(
          policyId: 'policy_2',
          policyName: 'Standard',
          description: 'Standard policy',
          minSecurityLevel: SecurityLevel.internal,
          requiredAuthMethods: [AuthenticationMethod.password],
          passwordMinLength: 12,
          mfaMaxAgeInDays: 90,
          enforceEncryption: false,
          createdAt: DateTime.now(),
        );

        expect(policy.isMFARequired, isFalse);
      });
    });

    // Role Tests
    group('Role', () {
      test('create role with permissions', () {
        final role = Role(
          roleId: 'role_1',
          roleName: 'Editor',
          description: 'Can edit resources',
          permissionIds: ['perm_1', 'perm_2', 'perm_3'],
          scope: PermissionScope.project,
          createdAt: DateTime.now(),
        );

        expect(role.hasPermissions, isTrue);
        expect(role.permissionCount, equals(3));
      });

      test('system vs custom roles', () {
        final systemRole = Role(
          roleId: 'role_system',
          roleName: 'Admin',
          description: 'System admin',
          permissionIds: [],
          scope: PermissionScope.global,
          createdAt: DateTime.now(),
          isSystem: true,
        );

        final customRole = Role(
          roleId: 'role_custom',
          roleName: 'Custom',
          description: 'Custom role',
          permissionIds: [],
          scope: PermissionScope.project,
          createdAt: DateTime.now(),
          isSystem: false,
        );

        expect(systemRole.isSystem, isTrue);
        expect(customRole.isCustom, isTrue);
      });
    });

    // Permission Tests
    group('Permission', () {
      test('admin permission', () {
        final permission = Permission(
          permissionId: 'perm_admin',
          permissionName: 'Admin Access',
          description: 'Full access',
          accessType: AccessType.admin,
          resourceType: 'all',
          scope: PermissionScope.global,
          createdAt: DateTime.now(),
        );

        expect(permission.isAdmin, isTrue);
        expect(permission.requiresApproval, isTrue);
      });

      test('dangerous permission', () {
        final permission = Permission(
          permissionId: 'perm_delete',
          permissionName: 'Delete',
          description: 'Delete resources',
          accessType: AccessType.delete,
          resourceType: 'resource',
          scope: PermissionScope.resource,
          createdAt: DateTime.now(),
          isDangerous: true,
        );

        expect(permission.isDangerous, isTrue);
        expect(permission.requiresApproval, isTrue);
      });
    });

    // User Tests
    group('User', () {
      test('create active user', () {
        final user = User(
          userId: 'user_1',
          username: 'john_doe',
          email: 'john@example.com',
          roleIds: ['role_1', 'role_2'],
          securityLevel: SecurityLevel.internal,
          createdAt: DateTime.now(),
          isMFAEnabled: true,
        );

        expect(user.isActive, isTrue);
        expect(user.hasRoles, isTrue);
        expect(user.roleCount, equals(2));
      });

      test('password change requirement', () {
        final oldPasswordUser = User(
          userId: 'user_2',
          username: 'jane_doe',
          email: 'jane@example.com',
          roleIds: ['role_1'],
          securityLevel: SecurityLevel.confidential,
          createdAt: DateTime.now().subtract(Duration(days: 120)),
          passwordChangedAt: DateTime.now().subtract(Duration(days: 120)),
        );

        expect(oldPasswordUser.passwordNeedsChange, isTrue);
      });
    });

    // AccessControl Tests
    group('AccessControl', () {
      test('create active access control', () {
        final control = AccessControl(
          controlId: 'ac_1',
          userId: 'user_1',
          resourceId: 'resource_1',
          resourceType: 'database',
          allowedAccess: [AccessType.read, AccessType.write],
          grantedAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(days: 30)),
        );

        expect(control.isActive, isTrue);
        expect(control.canRead, isTrue);
        expect(control.canWrite, isTrue);
        expect(control.canDelete, isFalse);
      });

      test('access control expiration', () {
        final expiredControl = AccessControl(
          controlId: 'ac_2',
          userId: 'user_1',
          resourceId: 'resource_1',
          resourceType: 'file',
          allowedAccess: [AccessType.read],
          grantedAt: DateTime.now().subtract(Duration(days: 60)),
          expiresAt: DateTime.now().subtract(Duration(days: 30)),
        );

        expect(expiredControl.hasExpired, isTrue);
        expect(expiredControl.isActive, isFalse);
      });

      test('admin access detection', () {
        final adminControl = AccessControl(
          controlId: 'ac_3',
          userId: 'user_1',
          resourceId: 'resource_1',
          resourceType: 'system',
          allowedAccess: [AccessType.admin, AccessType.execute],
          grantedAt: DateTime.now(),
        );

        expect(adminControl.isAdmin, isTrue);
      });
    });

    // SecretManagement Tests
    group('SecretManagement', () {
      test('create secret needing rotation', () {
        final secret = SecretManagement(
          secretId: 'secret_1',
          secretName: 'API Key',
          secretType: 'api_key',
          encryptionMethod: EncryptionMethod.aes256,
          createdAt: DateTime.now().subtract(Duration(days: 100)),
          rotationIntervalDays: 90,
          accessorIds: ['user_1', 'user_2'],
        );

        expect(secret.needsRotation, isTrue);
        expect(secret.hasAccessors, isTrue);
      });

      test('secret with recent rotation', () {
        final secret = SecretManagement(
          secretId: 'secret_2',
          secretName: 'Database Password',
          secretType: 'password',
          encryptionMethod: EncryptionMethod.aes256,
          createdAt: DateTime.now().subtract(Duration(days: 200)),
          rotatedAt: DateTime.now().subtract(Duration(days: 10)),
          rotationIntervalDays: 90,
          accessorIds: ['user_1'],
        );

        expect(secret.needsRotation, isFalse);
      });
    });

    // AuthenticationSession Tests
    group('AuthenticationSession', () {
      test('create MFA session', () {
        final session = AuthenticationSession(
          sessionId: 'session_1',
          userId: 'user_1',
          authMethod: AuthenticationMethod.password,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 8)),
          ipAddress: '192.168.1.1',
          mfaMethods: ['totp', 'email'],
        );

        expect(session.isMFAVerified, isTrue);
        expect(session.isRecent, isTrue);
      });

      test('expired session detection', () {
        final expiredSession = AuthenticationSession(
          sessionId: 'session_2',
          userId: 'user_1',
          authMethod: AuthenticationMethod.mfa,
          createdAt: DateTime.now().subtract(Duration(hours: 10)),
          expiresAt: DateTime.now().subtract(Duration(hours: 2)),
          ipAddress: '192.168.1.1',
          mfaMethods: [],
        );

        expect(expiredSession.hasExpired, isTrue);
      });
    });

    // SecurityAuditLog Tests
    group('SecurityAuditLog', () {
      test('successful access audit', () {
        final log = SecurityAuditLog(
          auditId: 'audit_1',
          userId: 'user_1',
          action: 'read_file',
          auditAction: AuditAction.allow,
          resourceId: 'file_1',
          resourceType: 'document',
          timestamp: DateTime.now(),
          wasSuccessful: true,
          details: {'fileName': 'report.pdf'},
        );

        expect(log.wasSuccessful, isTrue);
        expect(log.isDenied, isFalse);
      });

      test('denied access audit', () {
        final log = SecurityAuditLog(
          auditId: 'audit_2',
          userId: 'user_2',
          action: 'delete_database',
          auditAction: AuditAction.deny,
          resourceId: 'db_1',
          resourceType: 'database',
          timestamp: DateTime.now(),
          wasSuccessful: false,
          failureReason: 'Insufficient permissions',
          details: {},
        );

        expect(log.isFailed, isTrue);
        expect(log.isDenied, isTrue);
      });
    });

    // EncryptionKey Tests
    group('EncryptionKey', () {
      test('strong encryption key', () {
        final key = EncryptionKey(
          keyId: 'key_1',
          keyName: 'Master Key',
          encryptionMethod: EncryptionMethod.rsa2048,
          createdAt: DateTime.now(),
          keySizeInBits: 2048,
          authorizedUsers: ['user_1', 'user_2'],
        );

        expect(key.isStrong, isTrue);
        expect(key.hasAuthorizedUsers, isTrue);
      });

      test('weak encryption key', () {
        final key = EncryptionKey(
          keyId: 'key_2',
          keyName: 'Legacy Key',
          encryptionMethod: EncryptionMethod.aes256,
          createdAt: DateTime.now().subtract(Duration(days: 365)),
          keySizeInBits: 128,
          authorizedUsers: [],
        );

        expect(key.isStrong, isFalse);
        expect(key.hasAuthorizedUsers, isFalse);
      });
    });

    // PrivilegeEscalation Tests
    group('PrivilegeEscalation', () {
      test('pending escalation request', () {
        final escalation = PrivilegeEscalation(
          escalationId: 'esc_1',
          userId: 'user_1',
          requestedRole: 'admin',
          requestReason: 'Need to manage system settings',
          requestedAt: DateTime.now(),
        );

        expect(escalation.isPending, isTrue);
        expect(escalation.isApproved, isFalse);
      });

      test('approved escalation with expiry', () {
        final escalation = PrivilegeEscalation(
          escalationId: 'esc_2',
          userId: 'user_1',
          requestedRole: 'admin',
          requestReason: 'Temporary admin access',
          requestedAt: DateTime.now().subtract(Duration(days: 1)),
          approvedAt: DateTime.now(),
          approvedBy: 'admin_user',
          isApproved: true,
          expiresAt: DateTime.now().add(Duration(days: 7)),
        );

        expect(escalation.isApproved, isTrue);
        expect(escalation.daysUntilExpiry, greaterThan(0));
      });
    });

    // SecurityThreat Tests
    group('SecurityThreat', () {
      test('critical security threat', () {
        final threat = SecurityThreat(
          threatId: 'threat_1',
          threatType: 'brute_force_attack',
          description: 'Multiple failed login attempts',
          severityScore: 0.96,
          detectedAt: DateTime.now(),
          detectedBy: 'security_system',
        );

        expect(threat.isCritical, isTrue);
        expect(threat.isHighSeverity, isTrue);
      });

      test('mitigated threat', () {
        final threat = SecurityThreat(
          threatId: 'threat_2',
          threatType: 'suspicious_activity',
          description: 'Unusual access pattern detected',
          severityScore: 0.65,
          detectedAt: DateTime.now().subtract(Duration(hours: 2)),
          detectedBy: 'monitoring_service',
          mitigatedAt: DateTime.now(),
          isMitigated: true,
          mitigationActions: 'Blocked IP address and reset password',
        );

        expect(threat.isMitigated, isTrue);
        expect(threat.isPending, isFalse);
      });
    });

    // Repository Tests
    group('MemorySecurityRepository', () {
      test('createUser and getUser', () async {
        final user = User(
          userId: 'user_repo_1',
          username: 'test_user',
          email: 'test@example.com',
          roleIds: ['role_1'],
          securityLevel: SecurityLevel.internal,
          createdAt: DateTime.now(),
        );

        await repository.createUser(user);
        final retrieved = await repository.getUser('user_repo_1');

        expect(retrieved, isNotNull);
        expect(retrieved?.username, equals('test_user'));
      });

      test('getActiveUsers returns only active users', () async {
        final activeUser = User(
          userId: 'user_active',
          username: 'active',
          email: 'active@example.com',
          roleIds: [],
          securityLevel: SecurityLevel.internal,
          createdAt: DateTime.now(),
          isActive: true,
        );

        final inactiveUser = User(
          userId: 'user_inactive',
          username: 'inactive',
          email: 'inactive@example.com',
          roleIds: [],
          securityLevel: SecurityLevel.internal,
          createdAt: DateTime.now(),
          isActive: false,
        );

        await repository.createUser(activeUser);
        await repository.createUser(inactiveUser);
        final active = await repository.getActiveUsers();

        expect(active.length, equals(1));
        expect(active[0].username, equals('active'));
      });

      test('getFailedAccessAttempts', () async {
        final failedLog = SecurityAuditLog(
          auditId: 'audit_failed',
          userId: 'user_1',
          action: 'login',
          auditAction: AuditAction.deny,
          resourceId: 'system',
          resourceType: 'auth',
          timestamp: DateTime.now(),
          wasSuccessful: false,
          failureReason: 'Invalid credentials',
          details: {},
        );

        await repository.recordAuditLog(failedLog);
        final failed = await repository.getFailedAccessAttempts();

        expect(failed.isNotEmpty, isTrue);
      });

      test('getUnmitigatedThreats', () async {
        final unmitigatedThreat = SecurityThreat(
          threatId: 'threat_unmit',
          threatType: 'sql_injection',
          description: 'SQL injection attempt detected',
          severityScore: 0.9,
          detectedAt: DateTime.now(),
          isMitigated: false,
        );

        await repository.recordSecurityThreat(unmitigatedThreat);
        final unmitigated = await repository.getUnmitigatedThreats();

        expect(unmitigated.isNotEmpty, isTrue);
      });
    });

    // Facade Integration Tests
    group('SecurityFacade Integration', () {
      test('end-to-end access control workflow', () async {
        // Grant access
        final control = await facade.grantAccess('user_1', 'resource_1', 'database', [AccessType.read, AccessType.write]);
        expect(control.canRead, isTrue);

        // Revoke access
        await facade.revokeAccess(control.controlId);

        // Verify revocation
        final retrieved = await repository.getAccessControl(control.controlId);
        expect(retrieved?.allowedAccess.isEmpty, isTrue);
      });

      test('authentication and MFA workflow', () async {
        final session = await facade.createSession('user_1', AuthenticationMethod.password, '192.168.1.1');
        expect(session.isMFAVerified, isFalse);

        await facade.verifyMFA(session.sessionId, 'totp');

        final updated = await repository.getSession(session.sessionId);
        expect(updated?.isMFAVerified, isTrue);
      });

      test('security event logging', () async {
        await facade.logSecurityEvent('user_1', 'access_resource', AuditAction.allow, 'resource_1', 'file', true);

        final logs = await facade.getUserAuditLogs('user_1');
        expect(logs.isNotEmpty, isTrue);
      });

      test('privilege escalation workflow', () async {
        final escalation = await facade.requestEscalation('user_1', 'admin', 'Need temporary admin access');
        expect(escalation.isPending, isTrue);

        await facade.approveEscalation(escalation.escalationId, 'admin_user');

        final pending = await facade.getPendingEscalations();
        final approved = pending.where((e) => e.escalationId == escalation.escalationId).isEmpty;
        expect(approved, isTrue);
      });
    });

    // Edge Cases
    group('Edge Cases', () {
      test('empty role with no permissions', () {
        final role = Role(
          roleId: 'role_empty',
          roleName: 'Viewer',
          description: 'Read-only',
          permissionIds: [],
          scope: PermissionScope.resource,
          createdAt: DateTime.now(),
        );

        expect(role.hasPermissions, isFalse);
        expect(role.permissionCount, equals(0));
      });

      test('access control with immediate expiry', () {
        final control = AccessControl(
          controlId: 'ac_expired',
          userId: 'user_1',
          resourceId: 'resource_1',
          resourceType: 'data',
          allowedAccess: [AccessType.read],
          grantedAt: DateTime.now(),
          expiresAt: DateTime.now(),
        );

        expect(control.hasExpired, isTrue);
      });

      test('multiple access types permission', () {
        final allAccess = [AccessType.read, AccessType.write, AccessType.delete, AccessType.admin];
        final control = AccessControl(
          controlId: 'ac_all',
          userId: 'user_1',
          resourceId: 'resource_1',
          resourceType: 'system',
          allowedAccess: allAccess,
          grantedAt: DateTime.now(),
        );

        expect(control.canRead, isTrue);
        expect(control.canWrite, isTrue);
        expect(control.canDelete, isTrue);
        expect(control.isAdmin, isTrue);
      });

      test('threat severity boundaries', () {
        final lowThreat = SecurityThreat(
          threatId: 'threat_low',
          threatType: 'info',
          description: 'Informational',
          severityScore: 0.3,
          detectedAt: DateTime.now(),
        );

        final highThreat = SecurityThreat(
          threatId: 'threat_high',
          threatType: 'critical',
          description: 'Critical',
          severityScore: 0.8,
          detectedAt: DateTime.now(),
        );

        expect(lowThreat.isHighSeverity, isFalse);
        expect(highThreat.isHighSeverity, isTrue);
      });
    });

    // Performance Tests
    group('Performance', () {
      test('handle large user volume', () async {
        for (int i = 0; i < 100; i++) {
          final user = User(
            userId: 'user_$i',
            username: 'user_$i',
            email: 'user$i@example.com',
            roleIds: ['role_1'],
            securityLevel: SecurityLevel.internal,
            createdAt: DateTime.now(),
          );
          await repository.createUser(user);
        }

        final users = await repository.getAllUsers();
        expect(users.length, equals(100));
      });

      test('rapid audit logging', () async {
        for (int i = 0; i < 50; i++) {
          final log = SecurityAuditLog(
            auditId: 'audit_$i',
            userId: 'user_1',
            action: 'access_$i',
            auditAction: AuditAction.allow,
            resourceId: 'resource_$i',
            resourceType: 'resource',
            timestamp: DateTime.now(),
            wasSuccessful: true,
            details: {},
          );
          await repository.recordAuditLog(log);
        }

        final logs = await repository.getUserAuditLogs('user_1');
        expect(logs.length, equals(50));
      });
    });
  });
}
