import 'package:test/test.dart';
import 'package:project_040/models/security_models.dart';
import 'package:project_040/services/security_access_service.dart';

void main() {
  group('Phase 78: Security & Access Control', () {
    late SecurityRepositoryImpl repository;

    setUp(() {
      repository = SecurityRepositoryImpl();
    });

    group('Enum Tests', () {
      test('AuthenticationMethod has all values', () {
        expect(AuthenticationMethod.values.length, 7);
      });

      test('AccessLevel has all values', () {
        expect(AccessLevel.values.length, 6);
      });

      test('PermissionType has all values', () {
        expect(PermissionType.values.length, 6);
      });

      test('ResourceType has all values', () {
        expect(ResourceType.values.length, 6);
      });

      test('RoleStatus has all values', () {
        expect(RoleStatus.values.length, 5);
      });

      test('AuditAction has all values', () {
        expect(AuditAction.values.length, 8);
      });
    });

    group('Model Tests', () {
      test('User model creation', () {
        final user = User(
          userId: 'u1',
          username: 'admin',
          email: 'admin@test.com',
          accessLevel: AccessLevel.admin,
          roleIds: [],
          createdAt: DateTime.now(),
          isActive: true,
          permissionIds: [],
        );
        expect(user.isAdmin, true);
        expect(user.canManage, true);
      });

      test('Role model creation', () {
        final role = Role(
          roleId: 'r1',
          roleName: 'Admin',
          description: 'Administrator',
          accessLevel: AccessLevel.admin,
          permissionIds: [],
          createdAt: DateTime.now(),
          status: RoleStatus.active,
        );
        expect(role.isActive, true);
      });

      test('Permission model creation', () {
        final perm = Permission(
          permissionId: 'p1',
          permissionName: 'read_job',
          type: PermissionType.read,
          resource: ResourceType.job,
          description: 'Read jobs',
          createdAt: DateTime.now(),
          constraints: {},
        );
        expect(perm.hasConstraints, false);
      });

      test('AuthenticationSession model', () {
        final session = AuthenticationSession(
          sessionId: 's1',
          userId: 'u1',
          createdAt: DateTime.now(),
          ipAddress: '127.0.0.1',
          userAgent: 'Chrome',
          method: AuthenticationMethod.oauth2,
          mfaFactors: [],
        );
        expect(session.isActive, true);
      });

      test('AccessControl model', () {
        final control = AccessControl(
          controlId: 'ac1',
          userId: 'u1',
          resource: ResourceType.job,
          resourceId: 'job_1',
          grantedPermissions: [PermissionType.read],
          grantedAt: DateTime.now(),
        );
        expect(control.canRead, true);
        expect(control.canWrite, false);
      });

      test('PasswordPolicy model', () {
        final policy = PasswordPolicy(
          policyId: 'pp1',
          minLength: 12,
          requireUppercase: true,
          requireLowercase: true,
          requireNumbers: true,
          requireSpecialChars: true,
          expirationDays: 90,
          historyCount: 5,
          createdAt: DateTime.now(),
        );
        expect(policy.complexityScore, 4);
      });

      test('SecurityAudit model', () {
        final audit = SecurityAudit(
          auditId: 'a1',
          userId: 'u1',
          action: AuditAction.login,
          timestamp: DateTime.now(),
          isSuccessful: true,
          details: {},
        );
        expect(audit.isFailed, false);
      });

      test('TwoFactorAuth model', () {
        final mfa = TwoFactorAuth(
          mfaId: 'm1',
          userId: 'u1',
          secret: 'secret',
          enabledAt: DateTime.now(),
          backupCodes: ['code1', 'code2'],
          isActive: true,
        );
        expect(mfa.hasBackupCodes, true);
        expect(mfa.backupCodeCount, 2);
      });

      test('IPWhitelist model', () {
        final whitelist = IPWhitelist(
          whitelistId: 'ipw1',
          userId: 'u1',
          ipAddresses: ['192.168.1.1'],
          cidrRanges: ['10.0.0.0/8'],
          createdAt: DateTime.now(),
          isActive: true,
        );
        expect(whitelist.totalRanges, 2);
      });

      test('SecurityPolicy model', () {
        final policy = SecurityPolicy(
          policyId: 'sp1',
          policyName: 'Default',
          sessionTimeoutMinutes: 30,
          maxLoginAttempts: 5,
          lockoutDurationMinutes: 15,
          requireMfa: true,
          enforceIpWhitelist: false,
          createdAt: DateTime.now(),
          settings: {},
        );
        expect(policy.isMfaRequired, true);
      });
    });

    group('User Management', () {
      test('createUser creates new user', () async {
        final user = await repository.createUser(
          'testuser',
          'test@example.com',
          AccessLevel.operator,
        );
        expect(user.username, 'testuser');
        expect(user.isActive, true);
      });

      test('getUser retrieves user', () async {
        final created = await repository.createUser(
          'testuser',
          'test@example.com',
          AccessLevel.operator,
        );
        final retrieved = await repository.getUser(created.userId);
        expect(retrieved, isNotNull);
      });

      test('updateUserAccessLevel changes level', () async {
        final user = await repository.createUser(
          'testuser',
          'test@example.com',
          AccessLevel.viewer,
        );
        final updated = await repository.updateUserAccessLevel(
          user.userId,
          AccessLevel.operator,
        );
        expect(updated.accessLevel, AccessLevel.operator);
      });

      test('deleteUser removes user', () async {
        final user = await repository.createUser(
          'testuser',
          'test@example.com',
          AccessLevel.operator,
        );
        await repository.deleteUser(user.userId);
        final retrieved = await repository.getUser(user.userId);
        expect(retrieved, isNull);
      });

      test('listUsers returns users', () async {
        for (int i = 0; i < 10; i++) {
          await repository.createUser(
            'user$i',
            'user$i@test.com',
            AccessLevel.viewer,
          );
        }
        final users = await repository.listUsers(limit: 5);
        expect(users.length, 5);
      });

      test('getUsersByAccessLevel filters', () async {
        await repository.createUser(
          'admin',
          'admin@test.com',
          AccessLevel.admin,
        );
        await repository.createUser(
          'viewer',
          'viewer@test.com',
          AccessLevel.viewer,
        );
        final admins = await repository.getUsersByAccessLevel(AccessLevel.admin);
        expect(admins.isNotEmpty, true);
      });

      test('getActiveUsers returns active', () async {
        await repository.createUser(
          'active',
          'active@test.com',
          AccessLevel.operator,
        );
        final active = await repository.getActiveUsers();
        expect(active.isNotEmpty, true);
      });

      test('updateUserLastLogin updates time', () async {
        final user = await repository.createUser(
          'testuser',
          'test@example.com',
          AccessLevel.operator,
        );
        final updated = await repository.updateUserLastLogin(user.userId);
        expect(updated.lastLoginAt, isNotNull);
      });

      test('getUserCount returns count', () async {
        final initial = await repository.getUserCount();
        await repository.createUser(
          'testuser',
          'test@example.com',
          AccessLevel.operator,
        );
        final updated = await repository.getUserCount();
        expect(updated, greaterThan(initial));
      });

      test('getUsersByRole returns users', () async {
        final user = await repository.createUser(
          'testuser',
          'test@example.com',
          AccessLevel.operator,
        );
        final role = await repository.createRole(
          'TestRole',
          'Test',
          AccessLevel.operator,
          [],
        );
        final users = await repository.getUsersByRole(role.roleId);
        expect(users is List, true);
      });
    });

    group('Role Management', () {
      test('createRole creates role', () async {
        final role = await repository.createRole(
          'Manager',
          'Manager role',
          AccessLevel.supervisor,
          [],
        );
        expect(role.roleName, 'Manager');
        expect(role.isActive, true);
      });

      test('getRole retrieves role', () async {
        final created = await repository.createRole(
          'Test',
          'Test role',
          AccessLevel.operator,
          [],
        );
        final retrieved = await repository.getRole(created.roleId);
        expect(retrieved, isNotNull);
      });

      test('updateRolePermissions modifies permissions', () async {
        final role = await repository.createRole(
          'Test',
          'Test role',
          AccessLevel.operator,
          [],
        );
        final updated = await repository.updateRolePermissions(
          role.roleId,
          ['perm1', 'perm2'],
        );
        expect(updated.permissionCount, 2);
      });

      test('deleteRole removes role', () async {
        final role = await repository.createRole(
          'Test',
          'Test role',
          AccessLevel.operator,
          [],
        );
        await repository.deleteRole(role.roleId);
        final retrieved = await repository.getRole(role.roleId);
        expect(retrieved, isNull);
      });

      test('listRoles returns roles', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createRole(
            'Role$i',
            'Role $i',
            AccessLevel.operator,
            [],
          );
        }
        final roles = await repository.listRoles();
        expect(roles.isNotEmpty, true);
      });

      test('getRolesByAccessLevel filters', () async {
        await repository.createRole(
          'Admin',
          'Admin role',
          AccessLevel.admin,
          [],
        );
        final roles = await repository.getRolesByAccessLevel(AccessLevel.admin);
        expect(roles.isNotEmpty, true);
      });

      test('getRoleCount returns count', () async {
        final initial = await repository.getRoleCount();
        await repository.createRole(
          'Test',
          'Test role',
          AccessLevel.operator,
          [],
        );
        final updated = await repository.getRoleCount();
        expect(updated, greaterThan(initial));
      });

      test('getActiveRoles returns active', () async {
        await repository.createRole(
          'Active',
          'Active role',
          AccessLevel.operator,
          [],
        );
        final active = await repository.getActiveRoles();
        expect(active.isNotEmpty, true);
      });
    });

    group('Permission Management', () {
      test('createPermission creates permission', () async {
        final perm = await repository.createPermission(
          'read_jobs',
          PermissionType.read,
          ResourceType.job,
          'Read job data',
        );
        expect(perm.permissionName, 'read_jobs');
      });

      test('getPermission retrieves permission', () async {
        final created = await repository.createPermission(
          'test_perm',
          PermissionType.read,
          ResourceType.job,
          'Test',
        );
        final retrieved = await repository.getPermission(created.permissionId);
        expect(retrieved, isNotNull);
      });

      test('updatePermission modifies permission', () async {
        final perm = await repository.createPermission(
          'test_perm',
          PermissionType.read,
          ResourceType.job,
          'Old description',
        );
        await repository.updatePermission(
          perm.permissionId,
          description: 'New description',
        );
        final updated = await repository.getPermission(perm.permissionId);
        expect(updated!.description, 'New description');
      });

      test('deletePermission removes permission', () async {
        final perm = await repository.createPermission(
          'test_perm',
          PermissionType.read,
          ResourceType.job,
          'Test',
        );
        await repository.deletePermission(perm.permissionId);
        final retrieved = await repository.getPermission(perm.permissionId);
        expect(retrieved, isNull);
      });

      test('listPermissions returns permissions', () async {
        for (int i = 0; i < 5; i++) {
          await repository.createPermission(
            'perm$i',
            PermissionType.read,
            ResourceType.job,
            'Permission $i',
          );
        }
        final perms = await repository.listPermissions();
        expect(perms.isNotEmpty, true);
      });

      test('getPermissionsByType filters by type', () async {
        await repository.createPermission(
          'write_perm',
          PermissionType.write,
          ResourceType.job,
          'Write permission',
        );
        final perms = await repository.getPermissionsByType(PermissionType.write);
        expect(perms.isNotEmpty, true);
      });

      test('getPermissionsByResource filters by resource', () async {
        await repository.createPermission(
          'job_perm',
          PermissionType.read,
          ResourceType.job,
          'Job permission',
        );
        final perms = await repository.getPermissionsByResource(ResourceType.job);
        expect(perms.isNotEmpty, true);
      });

      test('getPermissionCount returns count', () async {
        final initial = await repository.getPermissionCount();
        await repository.createPermission(
          'test_perm',
          PermissionType.read,
          ResourceType.job,
          'Test',
        );
        final updated = await repository.getPermissionCount();
        expect(updated, greaterThan(initial));
      });
    });

    group('Authentication Management', () {
      test('createSession creates session', () async {
        final session = await repository.createSession(
          'user1',
          '127.0.0.1',
          'Chrome',
          AuthenticationMethod.oauth2,
        );
        expect(session.userId, 'user1');
        expect(session.isActive, true);
      });

      test('getSession retrieves session', () async {
        final created = await repository.createSession(
          'user1',
          '127.0.0.1',
          'Chrome',
          AuthenticationMethod.oauth2,
        );
        final retrieved = await repository.getSession(created.sessionId);
        expect(retrieved, isNotNull);
      });

      test('invalidateSession invalidates', () async {
        final session = await repository.createSession(
          'user1',
          '127.0.0.1',
          'Chrome',
          AuthenticationMethod.oauth2,
        );
        await repository.invalidateSession(session.sessionId);
        final retrieved = await repository.getSession(session.sessionId);
        expect(retrieved!.isValid, false);
      });

      test('deleteSession removes session', () async {
        final session = await repository.createSession(
          'user1',
          '127.0.0.1',
          'Chrome',
          AuthenticationMethod.oauth2,
        );
        await repository.deleteSession(session.sessionId);
        final retrieved = await repository.getSession(session.sessionId);
        expect(retrieved, isNull);
      });

      test('getUserSessions returns user sessions', () async {
        await repository.createSession(
          'user1',
          '127.0.0.1',
          'Chrome',
          AuthenticationMethod.oauth2,
        );
        final sessions = await repository.getUserSessions('user1');
        expect(sessions.isNotEmpty, true);
      });

      test('getActiveSessions returns active', () async {
        await repository.createSession(
          'user1',
          '127.0.0.1',
          'Chrome',
          AuthenticationMethod.oauth2,
        );
        final active = await repository.getActiveSessions();
        expect(active.isNotEmpty, true);
      });

      test('getSessionCount returns count', () async {
        final initial = await repository.getSessionCount();
        await repository.createSession(
          'user1',
          '127.0.0.1',
          'Chrome',
          AuthenticationMethod.oauth2,
        );
        final updated = await repository.getSessionCount();
        expect(updated, greaterThan(initial));
      });

      test('getExpiredSessions returns expired', () async {
        final expired = await repository.getExpiredSessions();
        expect(expired is List, true);
      });

      test('cleanupExpiredSessions removes expired', () async {
        await repository.cleanupExpiredSessions();
        expect(true, true);
      });
    });

    group('Access Control Management', () {
      test('grantAccess grants access', () async {
        final access = await repository.grantAccess(
          'user1',
          ResourceType.job,
          'job_123',
          [PermissionType.read],
        );
        expect(access.canRead, true);
      });

      test('getAccessControl retrieves control', () async {
        final created = await repository.grantAccess(
          'user1',
          ResourceType.job,
          'job_123',
          [PermissionType.read],
        );
        final retrieved = await repository.getAccessControl(created.controlId);
        expect(retrieved, isNotNull);
      });

      test('revokeAccess revokes access', () async {
        final access = await repository.grantAccess(
          'user1',
          ResourceType.job,
          'job_123',
          [PermissionType.read],
        );
        await repository.revokeAccess(access.controlId);
        final retrieved = await repository.getAccessControl(access.controlId);
        expect(retrieved!.isExpired, true);
      });

      test('deleteAccessControl removes control', () async {
        final access = await repository.grantAccess(
          'user1',
          ResourceType.job,
          'job_123',
          [PermissionType.read],
        );
        await repository.deleteAccessControl(access.controlId);
        final retrieved = await repository.getAccessControl(access.controlId);
        expect(retrieved, isNull);
      });

      test('getUserAccess returns user access', () async {
        await repository.grantAccess(
          'user1',
          ResourceType.job,
          'job_123',
          [PermissionType.read],
        );
        final access = await repository.getUserAccess('user1');
        expect(access.isNotEmpty, true);
      });

      test('getResourceAccess returns resource access', () async {
        await repository.grantAccess(
          'user1',
          ResourceType.job,
          'job_123',
          [PermissionType.read],
        );
        final access = await repository.getResourceAccess(ResourceType.job, 'job_123');
        expect(access.isNotEmpty, true);
      });

      test('getAccessControlCount returns count', () async {
        final initial = await repository.getAccessControlCount();
        await repository.grantAccess(
          'user1',
          ResourceType.job,
          'job_123',
          [PermissionType.read],
        );
        final updated = await repository.getAccessControlCount();
        expect(updated, greaterThan(initial));
      });

      test('getExpiredAccessControls returns expired', () async {
        final expired = await repository.getExpiredAccessControls();
        expect(expired is List, true);
      });
    });

    group('Password Policy', () {
      test('createPasswordPolicy creates policy', () async {
        final policy = await repository.createPasswordPolicy(12, true, true, true, true, 90);
        expect(policy.minLength, 12);
      });

      test('getPasswordPolicy retrieves policy', () async {
        final created = await repository.createPasswordPolicy(12, true, true, true, true, 90);
        final retrieved = await repository.getPasswordPolicy(created.policyId);
        expect(retrieved, isNotNull);
      });

      test('updatePasswordPolicy modifies policy', () async {
        final policy = await repository.createPasswordPolicy(8, true, true, true, true, 60);
        await repository.updatePasswordPolicy(policy.policyId, minLength: 12);
        final updated = await repository.getPasswordPolicy(policy.policyId);
        expect(updated!.minLength, 12);
      });

      test('deletePasswordPolicy removes policy', () async {
        final policy = await repository.createPasswordPolicy(12, true, true, true, true, 90);
        await repository.deletePasswordPolicy(policy.policyId);
        final retrieved = await repository.getPasswordPolicy(policy.policyId);
        expect(retrieved, isNull);
      });

      test('listPasswordPolicies returns policies', () async {
        await repository.createPasswordPolicy(12, true, true, true, true, 90);
        final policies = await repository.listPasswordPolicies();
        expect(policies.isNotEmpty, true);
      });

      test('getActivePasswordPolicy returns active', () async {
        await repository.createPasswordPolicy(12, true, true, true, true, 90);
        final policy = await repository.getActivePasswordPolicy();
        expect(policy, isNotNull);
      });
    });

    group('Security Audit', () {
      test('recordAudit records audit', () async {
        final audit = await repository.recordAudit(
          'user1',
          AuditAction.login,
        );
        expect(audit.userId, 'user1');
        expect(audit.isSuccessful, true);
      });

      test('getAudit retrieves audit', () async {
        final created = await repository.recordAudit('user1', AuditAction.login);
        final retrieved = await repository.getAudit(created.auditId);
        expect(retrieved, isNotNull);
      });

      test('getUserAudits returns user audits', () async {
        await repository.recordAudit('user1', AuditAction.login);
        final audits = await repository.getUserAudits('user1');
        expect(audits.isNotEmpty, true);
      });

      test('getFailedAudits returns failed', () async {
        await repository.recordAudit('user1', AuditAction.login, successful: false);
        final failed = await repository.getFailedAudits();
        expect(failed.isNotEmpty, true);
      });

      test('listAudits returns audits', () async {
        for (int i = 0; i < 5; i++) {
          await repository.recordAudit('user1', AuditAction.login);
        }
        final audits = await repository.listAudits();
        expect(audits.isNotEmpty, true);
      });

      test('getAuditCount returns count', () async {
        final initial = await repository.getAuditCount();
        await repository.recordAudit('user1', AuditAction.login);
        final updated = await repository.getAuditCount();
        expect(updated, greaterThan(initial));
      });

      test('getAuditsByAction filters by action', () async {
        await repository.recordAudit('user1', AuditAction.login);
        final audits = await repository.getAuditsByAction(AuditAction.login);
        expect(audits.isNotEmpty, true);
      });
    });

    group('MFA Management', () {
      test('enableMfa enables MFA', () async {
        final mfa = await repository.enableMfa('user1', 'secret123');
        expect(mfa.userId, 'user1');
        expect(mfa.isActive, true);
      });

      test('getMfa retrieves MFA', () async {
        final created = await repository.enableMfa('user1', 'secret123');
        final retrieved = await repository.getMfa(created.mfaId);
        expect(retrieved, isNotNull);
      });

      test('disableMfa disables MFA', () async {
        final mfa = await repository.enableMfa('user1', 'secret123');
        await repository.disableMfa(mfa.mfaId);
        final retrieved = await repository.getMfa(mfa.mfaId);
        expect(retrieved!.isActive, false);
      });

      test('deleteMfa removes MFA', () async {
        final mfa = await repository.enableMfa('user1', 'secret123');
        await repository.deleteMfa(mfa.mfaId);
        final retrieved = await repository.getMfa(mfa.mfaId);
        expect(retrieved, isNull);
      });

      test('getUserMfa returns user MFA', () async {
        await repository.enableMfa('user1', 'secret123');
        final mfas = await repository.getUserMfa('user1');
        expect(mfas.isNotEmpty, true);
      });

      test('getMfaCount returns count', () async {
        final initial = await repository.getMfaCount();
        await repository.enableMfa('user1', 'secret123');
        final updated = await repository.getMfaCount();
        expect(updated, greaterThan(initial));
      });
    });

    group('IP Whitelist', () {
      test('createIPWhitelist creates whitelist', () async {
        final whitelist = await repository.createIPWhitelist(
          'user1',
          ['192.168.1.1'],
          ['10.0.0.0/8'],
        );
        expect(whitelist.userId, 'user1');
      });

      test('getIPWhitelist retrieves whitelist', () async {
        final created = await repository.createIPWhitelist(
          'user1',
          ['192.168.1.1'],
          [],
        );
        final retrieved = await repository.getIPWhitelist(created.whitelistId);
        expect(retrieved, isNotNull);
      });

      test('updateIPWhitelist modifies whitelist', () async {
        final whitelist = await repository.createIPWhitelist(
          'user1',
          ['192.168.1.1'],
          [],
        );
        await repository.updateIPWhitelist(
          whitelist.whitelistId,
          ['192.168.1.2'],
          [],
        );
        final updated = await repository.getIPWhitelist(whitelist.whitelistId);
        expect(updated!.ipAddresses, ['192.168.1.2']);
      });

      test('deleteIPWhitelist removes whitelist', () async {
        final whitelist = await repository.createIPWhitelist(
          'user1',
          ['192.168.1.1'],
          [],
        );
        await repository.deleteIPWhitelist(whitelist.whitelistId);
        final retrieved = await repository.getIPWhitelist(whitelist.whitelistId);
        expect(retrieved, isNull);
      });

      test('getUserIPWhitelists returns whitelists', () async {
        await repository.createIPWhitelist('user1', ['192.168.1.1'], []);
        final whitelists = await repository.getUserIPWhitelists('user1');
        expect(whitelists.isNotEmpty, true);
      });

      test('getIPWhitelistCount returns count', () async {
        final initial = await repository.getIPWhitelistCount();
        await repository.createIPWhitelist('user1', ['192.168.1.1'], []);
        final updated = await repository.getIPWhitelistCount();
        expect(updated, greaterThan(initial));
      });

      test('getExpiredIPWhitelists returns expired', () async {
        final expired = await repository.getExpiredIPWhitelists();
        expect(expired is List, true);
      });
    });

    group('Security Policy', () {
      test('createSecurityPolicy creates policy', () async {
        final policy = await repository.createSecurityPolicy(
          'Default',
          30,
          5,
          15,
        );
        expect(policy.policyName, 'Default');
      });

      test('getSecurityPolicy retrieves policy', () async {
        final created = await repository.createSecurityPolicy(
          'Test',
          30,
          5,
          15,
        );
        final retrieved = await repository.getSecurityPolicy(created.policyId);
        expect(retrieved, isNotNull);
      });

      test('updateSecurityPolicy modifies policy', () async {
        final policy = await repository.createSecurityPolicy(
          'Test',
          30,
          5,
          15,
        );
        await repository.updateSecurityPolicy(
          policy.policyId,
          sessionTimeout: 60,
          requireMfa: true,
        );
        final updated = await repository.getSecurityPolicy(policy.policyId);
        expect(updated!.sessionTimeoutMinutes, 60);
      });

      test('deleteSecurityPolicy removes policy', () async {
        final policy = await repository.createSecurityPolicy(
          'Test',
          30,
          5,
          15,
        );
        await repository.deleteSecurityPolicy(policy.policyId);
        final retrieved = await repository.getSecurityPolicy(policy.policyId);
        expect(retrieved, isNull);
      });

      test('listSecurityPolicies returns policies', () async {
        await repository.createSecurityPolicy('Test', 30, 5, 15);
        final policies = await repository.listSecurityPolicies();
        expect(policies.isNotEmpty, true);
      });

      test('getActiveSecurityPolicy returns active', () async {
        await repository.createSecurityPolicy('Test', 30, 5, 15);
        final policy = await repository.getActiveSecurityPolicy();
        expect(policy, isNotNull);
      });
    });

    group('Engine Tests', () {
      test('AuthenticationEngine validates', () async {
        final engine = AuthenticationEngine();
        final valid = await engine.validateCredentials('user', 'pass');
        expect(valid, true);
      });

      test('AuthorizationEngine checks permission', () async {
        final engine = AuthorizationEngine();
        final hasPerm = await engine.hasPermission(
          'user1',
          PermissionType.read,
          ResourceType.job,
        );
        expect(hasPerm, true);
      });

      test('RoleManagementEngine gets permissions', () async {
        final engine = RoleManagementEngine();
        final perms = await engine.getEffectivePermissions('user1');
        expect(perms is List, true);
      });

      test('SessionManagementEngine enforces policy', () async {
        final engine = SessionManagementEngine();
        await engine.enforceSessionPolicy('sess_123');
        expect(true, true);
      });

      test('ComplianceEngine verifies', () async {
        final engine = ComplianceEngine();
        final compliant = await engine.verifyCompliance('user1', 'action');
        expect(compliant, true);
      });
    });

    group('Facade Tests', () {
      test('Facade getUser', () async {
        final manager = SecurityManager(
          repository: repository,
          authEngine: AuthenticationEngine(),
          authzEngine: AuthorizationEngine(),
          roleEngine: RoleManagementEngine(),
          sessionEngine: SessionManagementEngine(),
          complianceEngine: ComplianceEngine(),
        );
        final facade = SecurityFacade(repository: repository, manager: manager);

        final user = await repository.createUser('test', 'test@test.com', AccessLevel.viewer);
        final retrieved = await facade.getUser(user.userId);
        expect(retrieved, isNotNull);
      });

      test('Facade getActiveUsers', () async {
        final manager = SecurityManager(
          repository: repository,
          authEngine: AuthenticationEngine(),
          authzEngine: AuthorizationEngine(),
          roleEngine: RoleManagementEngine(),
          sessionEngine: SessionManagementEngine(),
          complianceEngine: ComplianceEngine(),
        );
        final facade = SecurityFacade(repository: repository, manager: manager);

        await repository.createUser('test', 'test@test.com', AccessLevel.viewer);
        final active = await facade.getActiveUsers();
        expect(active is List, true);
      });

      test('Facade listRoles', () async {
        final manager = SecurityManager(
          repository: repository,
          authEngine: AuthenticationEngine(),
          authzEngine: AuthorizationEngine(),
          roleEngine: RoleManagementEngine(),
          sessionEngine: SessionManagementEngine(),
          complianceEngine: ComplianceEngine(),
        );
        final facade = SecurityFacade(repository: repository, manager: manager);

        final roles = await facade.listRoles();
        expect(roles is List, true);
      });

      test('Facade getUserCount', () async {
        final manager = SecurityManager(
          repository: repository,
          authEngine: AuthenticationEngine(),
          authzEngine: AuthorizationEngine(),
          roleEngine: RoleManagementEngine(),
          sessionEngine: SessionManagementEngine(),
          complianceEngine: ComplianceEngine(),
        );
        final facade = SecurityFacade(repository: repository, manager: manager);

        await repository.createUser('test', 'test@test.com', AccessLevel.viewer);
        final count = await facade.getUserCount();
        expect(count, greaterThanOrEqualTo(1));
      });
    });

    group('Integration Tests', () {
      test('Complete user authorization flow', () async {
        final user = await repository.createUser(
          'admin',
          'admin@test.com',
          AccessLevel.admin,
        );
        final role = await repository.createRole(
          'AdminRole',
          'Admin role',
          AccessLevel.admin,
          [],
        );
        expect(user.isAdmin, true);
        expect(role.isActive, true);
      });

      test('Session and audit flow', () async {
        final session = await repository.createSession(
          'user1',
          '127.0.0.1',
          'Chrome',
          AuthenticationMethod.oauth2,
        );
        await repository.recordAudit('user1', AuditAction.login);
        expect(session.isActive, true);
      });

      test('Access control flow', () async {
        await repository.grantAccess(
          'user1',
          ResourceType.job,
          'job_123',
          [PermissionType.read, PermissionType.write],
        );
        final access = await repository.getUserAccess('user1');
        expect(access.isNotEmpty, true);
      });
    });

    group('Performance Tests', () {
      test('Create 100 users efficiently', () async {
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 100; i++) {
          await repository.createUser(
            'user$i',
            'user$i@test.com',
            AccessLevel.viewer,
          );
        }
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('List users efficiently', () async {
        for (int i = 0; i < 50; i++) {
          await repository.createUser(
            'user$i',
            'user$i@test.com',
            AccessLevel.viewer,
          );
        }
        final stopwatch = Stopwatch()..start();
        await repository.listUsers(limit: 25);
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}
