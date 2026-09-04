import 'package:flutter_test/flutter_test.dart';
import '../lib/models/user_models.dart';
import '../lib/services/user_service.dart';

void main() {
  group('Phase 57: User Management & Authorization', () {
    late UserFacade userFacade;

    setUp(() {
      userFacade = UserFacade();
    });

    // ===== Enum Tests =====
    group('Enums', () {
      test('UserRole enum values', () {
        expect(UserRole.admin.value, 'admin');
        expect(UserRole.manager.value, 'manager');
        expect(UserRole.operator.value, 'operator');
        expect(UserRole.viewer.value, 'viewer');
        expect(UserRole.guest.value, 'guest');
      });

      test('Permission enum values', () {
        expect(Permission.createJob.value, 'create_job');
        expect(Permission.readJob.value, 'read_job');
        expect(Permission.updateJob.value, 'update_job');
        expect(Permission.deleteJob.value, 'delete_job');
        expect(Permission.viewReports.value, 'view_reports');
        expect(Permission.exportData.value, 'export_data');
        expect(Permission.manageUsers.value, 'manage_users');
        expect(Permission.manageRoles.value, 'manage_roles');
        expect(Permission.viewAudit.value, 'view_audit');
        expect(Permission.configureSystem.value, 'configure_system');
      });

      test('UserStatus enum values', () {
        expect(UserStatus.active.value, 'active');
        expect(UserStatus.inactive.value, 'inactive');
        expect(UserStatus.suspended.value, 'suspended');
        expect(UserStatus.pending.value, 'pending');
        expect(UserStatus.deleted.value, 'deleted');
      });
    });

    // ===== User Model Tests =====
    group('User Model', () {
      test('User creation with required fields', () {
        final user = User(
          userId: 'user1',
          username: 'john_doe',
          email: 'john@example.com',
          role: UserRole.operator,
          status: UserStatus.active,
          createdAt: DateTime(2026, 1, 1),
          lastLoginAt: DateTime(2026, 9, 1),
        );

        expect(user.userId, 'user1');
        expect(user.username, 'john_doe');
        expect(user.email, 'john@example.com');
        expect(user.role, UserRole.operator);
        expect(user.status, UserStatus.active);
      });

      test('User isActive computed property', () {
        final activeUser = User(
          userId: 'user1',
          username: 'john',
          email: 'john@example.com',
          role: UserRole.operator,
          status: UserStatus.active,
          createdAt: DateTime(2026, 1, 1),
        );

        final inactiveUser = User(
          userId: 'user2',
          username: 'jane',
          email: 'jane@example.com',
          role: UserRole.viewer,
          status: UserStatus.inactive,
          createdAt: DateTime(2026, 1, 1),
        );

        expect(activeUser.isActive, true);
        expect(inactiveUser.isActive, false);
      });

      test('User isAdmin computed property', () {
        final adminUser = User(
          userId: 'user1',
          username: 'admin',
          email: 'admin@example.com',
          role: UserRole.admin,
          status: UserStatus.active,
          createdAt: DateTime(2026, 1, 1),
        );

        final regularUser = User(
          userId: 'user2',
          username: 'operator',
          email: 'op@example.com',
          role: UserRole.operator,
          status: UserStatus.active,
          createdAt: DateTime(2026, 1, 1),
        );

        expect(adminUser.isAdmin, true);
        expect(regularUser.isAdmin, false);
      });

      test('User needsPasswordChange computed property', () {
        final lastPasswordChange = DateTime.now().subtract(Duration(days: 120));
        final user = User(
          userId: 'user1',
          username: 'john',
          email: 'john@example.com',
          role: UserRole.operator,
          status: UserStatus.active,
          createdAt: DateTime(2026, 1, 1),
          lastPasswordChangeAt: lastPasswordChange,
        );

        expect(user.needsPasswordChange, true);
      });

      test('User accountAgeInDays computed property', () {
        final createdAt = DateTime.now().subtract(Duration(days: 100));
        final user = User(
          userId: 'user1',
          username: 'john',
          email: 'john@example.com',
          role: UserRole.operator,
          status: UserStatus.active,
          createdAt: createdAt,
        );

        expect(user.accountAgeInDays >= 99, true);
        expect(user.accountAgeInDays <= 100, true);
      });

      test('User hasLoginHistory computed property', () {
        final userWithLogin = User(
          userId: 'user1',
          username: 'john',
          email: 'john@example.com',
          role: UserRole.operator,
          status: UserStatus.active,
          createdAt: DateTime(2026, 1, 1),
          lastLoginAt: DateTime(2026, 9, 1),
        );

        final userWithoutLogin = User(
          userId: 'user2',
          username: 'jane',
          email: 'jane@example.com',
          role: UserRole.viewer,
          status: UserStatus.active,
          createdAt: DateTime(2026, 1, 1),
        );

        expect(userWithLogin.hasLoginHistory, true);
        expect(userWithoutLogin.hasLoginHistory, false);
      });
    });

    // ===== Role Model Tests =====
    group('Role Model', () {
      test('Role creation with permissions', () {
        final role = Role(
          roleId: 'role1',
          roleName: 'Operator Role',
          userRole: UserRole.operator,
          permissions: [Permission.readJob, Permission.updateJob],
          createdAt: DateTime(2026, 1, 1),
          isActive: true,
        );

        expect(role.roleId, 'role1');
        expect(role.roleName, 'Operator Role');
        expect(role.permissionCount, 2);
      });

      test('Role isEnabled computed property', () {
        final activeRole = Role(
          roleId: 'role1',
          roleName: 'Active',
          userRole: UserRole.operator,
          permissions: [],
          createdAt: DateTime(2026, 1, 1),
          isActive: true,
        );

        final inactiveRole = Role(
          roleId: 'role2',
          roleName: 'Inactive',
          userRole: UserRole.viewer,
          permissions: [],
          createdAt: DateTime(2026, 1, 1),
          isActive: false,
        );

        expect(activeRole.isEnabled, true);
        expect(inactiveRole.isEnabled, false);
      });

      test('Role hasPermission method', () {
        final role = Role(
          roleId: 'role1',
          roleName: 'Operator',
          userRole: UserRole.operator,
          permissions: [Permission.readJob, Permission.updateJob],
          createdAt: DateTime(2026, 1, 1),
        );

        expect(role.hasPermission(Permission.readJob), true);
        expect(role.hasPermission(Permission.updateJob), true);
        expect(role.hasPermission(Permission.deleteJob), false);
      });

      test('Role permissionCount computed property', () {
        final role = Role(
          roleId: 'role1',
          roleName: 'Manager',
          userRole: UserRole.manager,
          permissions: [
            Permission.createJob,
            Permission.readJob,
            Permission.updateJob,
            Permission.viewReports,
          ],
          createdAt: DateTime(2026, 1, 1),
        );

        expect(role.permissionCount, 4);
      });
    });

    // ===== PermissionAssignment Tests =====
    group('PermissionAssignment Model', () {
      test('PermissionAssignment creation', () {
        final perm = PermissionAssignment(
          assignmentId: 'perm1',
          userId: 'user1',
          permission: Permission.exportData,
          grantedAt: DateTime(2026, 1, 1),
        );

        expect(perm.assignmentId, 'perm1');
        expect(perm.userId, 'user1');
        expect(perm.permission, Permission.exportData);
      });

      test('PermissionAssignment isActive computed property', () {
        final activeAssignment = PermissionAssignment(
          assignmentId: 'perm1',
          userId: 'user1',
          permission: Permission.readJob,
          grantedAt: DateTime(2026, 1, 1),
          isActive: true,
        );

        final inactiveAssignment = PermissionAssignment(
          assignmentId: 'perm2',
          userId: 'user2',
          permission: Permission.updateJob,
          grantedAt: DateTime(2026, 1, 1),
          isActive: false,
        );

        expect(activeAssignment.isActive, true);
        expect(inactiveAssignment.isActive, false);
      });

      test('PermissionAssignment isExpired computed property', () {
        final expiredAssignment = PermissionAssignment(
          assignmentId: 'perm1',
          userId: 'user1',
          permission: Permission.readJob,
          grantedAt: DateTime(2026, 1, 1),
          expiresAt: DateTime(2026, 8, 1),
        );

        expect(expiredAssignment.isExpired, true);
      });

      test('PermissionAssignment daysUntilExpiration computed property', () {
        final futureDate = DateTime.now().add(Duration(days: 30));
        final assignment = PermissionAssignment(
          assignmentId: 'perm1',
          userId: 'user1',
          permission: Permission.viewReports,
          grantedAt: DateTime(2026, 1, 1),
          expiresAt: futureDate,
        );

        expect(assignment.daysUntilExpiration, 30);
      });
    });

    // ===== Session Tests =====
    group('Session Model', () {
      test('Session creation', () {
        final session = Session(
          sessionId: 'session1',
          userId: 'user1',
          startedAt: DateTime(2026, 9, 1),
          expiresAt: DateTime(2026, 9, 2),
          token: 'token123',
        );

        expect(session.sessionId, 'session1');
        expect(session.userId, 'user1');
        expect(session.token, 'token123');
      });

      test('Session isValid computed property', () {
        final future = DateTime.now().add(Duration(hours: 1));
        final validSession = Session(
          sessionId: 'session1',
          userId: 'user1',
          startedAt: DateTime.now(),
          expiresAt: future,
          token: 'token123',
          isActive: true,
        );

        final past = DateTime.now().subtract(Duration(hours: 1));
        final expiredSession = Session(
          sessionId: 'session2',
          userId: 'user2',
          startedAt: past.subtract(Duration(hours: 2)),
          expiresAt: past,
          token: 'token456',
        );

        expect(validSession.isValid, true);
        expect(expiredSession.isValid, false);
      });

      test('Session isExpired computed property', () {
        final past = DateTime.now().subtract(Duration(hours: 1));
        final expiredSession = Session(
          sessionId: 'session1',
          userId: 'user1',
          startedAt: past.subtract(Duration(hours: 2)),
          expiresAt: past,
          token: 'token123',
        );

        expect(expiredSession.isExpired, true);
      });

      test('Session durationInSeconds computed property', () {
        final start = DateTime(2026, 9, 1, 10, 0, 0);
        final end = DateTime(2026, 9, 1, 10, 30, 0);
        final session = Session(
          sessionId: 'session1',
          userId: 'user1',
          startedAt: start,
          expiresAt: end,
          token: 'token123',
        );

        expect(session.durationInSeconds, 1800);
      });

      test('Session inactiveDurationInSeconds computed property', () {
        final now = DateTime.now();
        final lastActivity = now.subtract(Duration(minutes: 15));
        final session = Session(
          sessionId: 'session1',
          userId: 'user1',
          startedAt: now.subtract(Duration(hours: 1)),
          expiresAt: now.add(Duration(hours: 1)),
          token: 'token123',
          lastActivityAt: lastActivity,
        );

        expect(session.inactiveDurationInSeconds >= 899, true);
        expect(session.inactiveDurationInSeconds <= 900, true);
      });
    });

    // ===== AuditLog Tests =====
    group('AuditLog Model', () {
      test('AuditLog creation', () {
        final log = AuditLog(
          logId: 'log1',
          userId: 'user1',
          action: 'user_created',
          timestamp: DateTime(2026, 9, 1),
          details: {'username': 'john'},
        );

        expect(log.logId, 'log1');
        expect(log.userId, 'user1');
        expect(log.action, 'user_created');
      });

      test('AuditLog isImportant computed property', () {
        final importantLog = AuditLog(
          logId: 'log1',
          userId: 'user1',
          action: 'user_suspended',
          timestamp: DateTime(2026, 9, 1),
          severity: 'high',
        );

        final normalLog = AuditLog(
          logId: 'log2',
          userId: 'user2',
          action: 'user_login',
          timestamp: DateTime(2026, 9, 1),
          severity: 'low',
        );

        expect(importantLog.isImportant, true);
        expect(normalLog.isImportant, false);
      });

      test('AuditLog hasChanges computed property', () {
        final logWithChanges = AuditLog(
          logId: 'log1',
          userId: 'user1',
          action: 'role_updated',
          timestamp: DateTime(2026, 9, 1),
          details: {'oldRole': 'operator', 'newRole': 'manager'},
        );

        final logWithoutChanges = AuditLog(
          logId: 'log2',
          userId: 'user2',
          action: 'user_login',
          timestamp: DateTime(2026, 9, 1),
        );

        expect(logWithChanges.hasChanges, true);
        expect(logWithoutChanges.hasChanges, false);
      });
    });

    // ===== AccessControlList Tests =====
    group('AccessControlList Model', () {
      test('AccessControlList creation', () {
        final acl = AccessControlList(
          aclId: 'acl1',
          resourceId: 'resource1',
          resourceType: 'job',
          rolePermissions: {
            UserRole.admin: [Permission.createJob, Permission.deleteJob],
            UserRole.operator: [Permission.readJob, Permission.updateJob],
          },
          createdAt: DateTime(2026, 1, 1),
        );

        expect(acl.aclId, 'acl1');
        expect(acl.resourceId, 'resource1');
        expect(acl.rolePermissions.length, 2);
      });

      test('AccessControlList hasPermissionForRole method', () {
        final acl = AccessControlList(
          aclId: 'acl1',
          resourceId: 'resource1',
          resourceType: 'job',
          rolePermissions: {
            UserRole.admin: [Permission.createJob, Permission.deleteJob],
            UserRole.operator: [Permission.readJob],
          },
          createdAt: DateTime(2026, 1, 1),
        );

        expect(acl.hasPermissionForRole(UserRole.admin, Permission.createJob), true);
        expect(acl.hasPermissionForRole(UserRole.operator, Permission.createJob), false);
      });

      test('AccessControlList roleCount computed property', () {
        final acl = AccessControlList(
          aclId: 'acl1',
          resourceId: 'resource1',
          resourceType: 'job',
          rolePermissions: {
            UserRole.admin: [Permission.createJob],
            UserRole.manager: [Permission.readJob],
            UserRole.operator: [Permission.updateJob],
          },
          createdAt: DateTime(2026, 1, 1),
        );

        expect(acl.roleCount, 3);
      });
    });

    // ===== UserActivity Tests =====
    group('UserActivity Model', () {
      test('UserActivity creation', () {
        final activity = UserActivity(
          activityId: 'activity1',
          userId: 'user1',
          activityType: 'login',
          timestamp: DateTime(2026, 9, 1),
          ipAddress: '192.168.1.1',
        );

        expect(activity.activityId, 'activity1');
        expect(activity.userId, 'user1');
        expect(activity.ipAddress, '192.168.1.1');
      });

      test('UserActivity isActive computed property', () {
        final recentActivity = UserActivity(
          activityId: 'activity1',
          userId: 'user1',
          activityType: 'login',
          timestamp: DateTime.now().subtract(Duration(minutes: 5)),
          ipAddress: '192.168.1.1',
        );

        final oldActivity = UserActivity(
          activityId: 'activity2',
          userId: 'user2',
          activityType: 'login',
          timestamp: DateTime.now().subtract(Duration(days: 30)),
          ipAddress: '192.168.1.2',
        );

        expect(recentActivity.isActive, true);
        expect(oldActivity.isActive, false);
      });

      test('UserActivity hasAnomalousActivity computed property', () {
        final anomalous = UserActivity(
          activityId: 'activity1',
          userId: 'user1',
          activityType: 'failed_login_multiple',
          timestamp: DateTime.now(),
          ipAddress: '192.168.1.1',
          isAnomalous: true,
        );

        final normal = UserActivity(
          activityId: 'activity2',
          userId: 'user2',
          activityType: 'login',
          timestamp: DateTime.now(),
          ipAddress: '192.168.1.2',
          isAnomalous: false,
        );

        expect(anomalous.hasAnomalousActivity, true);
        expect(normal.hasAnomalousActivity, false);
      });
    });

    // ===== UserRepository Tests =====
    group('UserRepository', () {
      test('Create and retrieve user', () async {
        final user = User(
          userId: 'user1',
          username: 'john_doe',
          email: 'john@example.com',
          role: UserRole.operator,
          status: UserStatus.active,
          createdAt: DateTime(2026, 1, 1),
        );

        await userFacade.createUser('user1', 'john_doe', 'john@example.com', UserRole.operator);
        final retrieved = await userFacade.getUserById('user1');

        expect(retrieved, isNotNull);
        expect(retrieved!.username, 'john_doe');
      });

      test('Create user with duplicate ID', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);
        
        expect(
          () => userFacade.createUser('user1', 'jane', 'jane@example.com', UserRole.viewer),
          throwsException,
        );
      });

      test('Get non-existent user returns null', () async {
        final retrieved = await userFacade.getUserById('nonexistent');
        expect(retrieved, isNull);
      });

      test('List all users', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);
        await userFacade.createUser('user2', 'jane', 'jane@example.com', UserRole.manager);

        final users = await userFacade.getAllUsers();
        expect(users.length, greaterThanOrEqualTo(2));
      });

      test('Update user status', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);
        
        final updated = await userFacade.updateUserStatus('user1', UserStatus.suspended);
        expect(updated, isNotNull);
        expect(updated!.status, UserStatus.suspended);
      });

      test('Delete user', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);
        
        final deleted = await userFacade.deleteUser('user1');
        expect(deleted, true);

        final retrieved = await userFacade.getUserById('user1');
        expect(retrieved, isNull);
      });
    });

    // ===== Role Tests =====
    group('Role Management', () {
      test('Create and retrieve role', () async {
        await userFacade.createRole(
          'role1',
          'Operator',
          UserRole.operator,
          [Permission.readJob, Permission.updateJob],
        );

        final role = await userFacade.getRoleById('role1');
        expect(role, isNotNull);
        expect(role!.permissionCount, 2);
      });

      test('Get role permissions', () async {
        await userFacade.createRole(
          'role1',
          'Manager',
          UserRole.manager,
          [Permission.createJob, Permission.readJob, Permission.manageUsers],
        );

        final permissions = await userFacade.getRolePermissions('role1');
        expect(permissions.length, 3);
      });

      test('Update role permissions', () async {
        await userFacade.createRole(
          'role1',
          'Viewer',
          UserRole.viewer,
          [Permission.readJob],
        );

        await userFacade.updateRolePermissions('role1', [
          Permission.readJob,
          Permission.viewReports,
        ]);

        final role = await userFacade.getRoleById('role1');
        expect(role!.permissionCount, 2);
      });

      test('Delete role', () async {
        await userFacade.createRole('role1', 'Temp', UserRole.operator, []);
        
        final deleted = await userFacade.deleteRole('role1');
        expect(deleted, true);

        final retrieved = await userFacade.getRoleById('role1');
        expect(retrieved, isNull);
      });
    });

    // ===== Permission Tests =====
    group('Permission Management', () {
      test('Grant permission to user', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.viewer);

        await userFacade.grantPermissionToUser('user1', Permission.exportData);
        
        final hasPermission = await userFacade.userHasPermission('user1', Permission.exportData);
        expect(hasPermission, true);
      });

      test('Revoke permission from user', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);
        await userFacade.grantPermissionToUser('user1', Permission.deleteJob);

        await userFacade.revokePermissionFromUser('user1', Permission.deleteJob);

        final hasPermission = await userFacade.userHasPermission('user1', Permission.deleteJob);
        expect(hasPermission, false);
      });

      test('User has permission from role', () async {
        await userFacade.createRole(
          'role1',
          'Manager',
          UserRole.manager,
          [Permission.createJob, Permission.readJob],
        );

        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.manager);
        
        final hasPermission = await userFacade.userHasPermission('user1', Permission.createJob);
        expect(hasPermission, true);
      });

      test('List user permissions', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);
        await userFacade.grantPermissionToUser('user1', Permission.exportData);

        final permissions = await userFacade.getUserPermissions('user1');
        expect(permissions.isNotEmpty, true);
      });
    });

    // ===== Session Tests =====
    group('Session Management', () {
      test('Create session for user', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);

        final session = await userFacade.createSession('user1');
        expect(session, isNotNull);
        expect(session!.userId, 'user1');
        expect(session.isValid, true);
      });

      test('Validate active session', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);
        final session = await userFacade.createSession('user1');

        final isValid = await userFacade.validateSession(session!.sessionId);
        expect(isValid, true);
      });

      test('Terminate session', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);
        final session = await userFacade.createSession('user1');

        await userFacade.terminateSession(session!.sessionId);

        final terminated = await userFacade.getSession(session.sessionId);
        expect(terminated!.isActive, false);
      });

      test('Get user sessions', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);
        
        final session1 = await userFacade.createSession('user1');
        final session2 = await userFacade.createSession('user1');

        final sessions = await userFacade.getUserSessions('user1');
        expect(sessions.length, greaterThanOrEqualTo(2));
      });
    });

    // ===== Audit Log Tests =====
    group('Audit Log Management', () {
      test('Record audit log', () async {
        await userFacade.recordAuditLog('user1', 'user_created', {'username': 'john'});

        final logs = await userFacade.getAuditLogs();
        expect(logs.isNotEmpty, true);
      });

      test('Get audit logs by action', () async {
        await userFacade.recordAuditLog('user1', 'login', {});
        await userFacade.recordAuditLog('user2', 'permission_granted', {});

        final logs = await userFacade.getAuditLogsByAction('login');
        expect(logs.isNotEmpty, true);
      });

      test('Get user audit history', () async {
        await userFacade.recordAuditLog('user1', 'login', {});
        await userFacade.recordAuditLog('user1', 'logout', {});

        final logs = await userFacade.getUserAuditHistory('user1');
        expect(logs.length >= 2, true);
      });
    });

    // ===== AccessControlList Tests =====
    group('AccessControlList Management', () {
      test('Create ACL', () async {
        await userFacade.createACL('acl1', 'resource1', 'job', {
          UserRole.admin: [Permission.createJob, Permission.deleteJob],
        });

        final acl = await userFacade.getACLById('acl1');
        expect(acl, isNotNull);
      });

      test('Verify ACL permissions', () async {
        await userFacade.createACL('acl1', 'resource1', 'job', {
          UserRole.operator: [Permission.readJob, Permission.updateJob],
        });

        final acl = await userFacade.getACLById('acl1');
        expect(acl!.hasPermissionForRole(UserRole.operator, Permission.readJob), true);
        expect(acl.hasPermissionForRole(UserRole.operator, Permission.deleteJob), false);
      });

      test('Get resource ACL', () async {
        await userFacade.createACL('acl1', 'job1', 'job', {
          UserRole.manager: [Permission.readJob],
        });

        final acl = await userFacade.getACLByResource('job1');
        expect(acl, isNotNull);
      });
    });

    // ===== UserActivity Tests =====
    group('UserActivity Tracking', () {
      test('Record user activity', () async {
        await userFacade.recordUserActivity('user1', 'login', '192.168.1.1');

        final activities = await userFacade.getUserActivities('user1');
        expect(activities.isNotEmpty, true);
      });

      test('Get recent activities', () async {
        await userFacade.recordUserActivity('user1', 'login', '192.168.1.1');
        await userFacade.recordUserActivity('user1', 'logout', '192.168.1.1');

        final activities = await userFacade.getUserActivities('user1');
        expect(activities.length >= 2, true);
      });

      test('Detect anomalous activity', () async {
        await userFacade.recordAnomalousActivity('user1', 'multiple_failed_logins', '192.168.1.1');

        final activities = await userFacade.getUserActivities('user1');
        final anomalous = activities.where((a) => a.isAnomalous).toList();
        expect(anomalous.isNotEmpty, true);
      });
    });

    // ===== UserManagementReport Tests =====
    group('UserManagementReport', () {
      test('Generate user report with Markdown output', () async {
        final report = UserManagementReport(
          reportId: 'report1',
          generatedAt: DateTime.now(),
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
          totalUsers: 10,
          activeUsers: 8,
          suspendedUsers: 1,
          newUsers: 3,
          roleDistribution: {UserRole.operator: 5, UserRole.manager: 3},
        );

        final markdown = report.toMarkdown();
        expect(markdown.contains('User Management Report'), true);
        expect(markdown.contains('Active Users: 8'), true);
      });

      test('Report calculations', () async {
        final report = UserManagementReport(
          reportId: 'report1',
          generatedAt: DateTime.now(),
          periodStart: DateTime.now().subtract(Duration(days: 30)),
          periodEnd: DateTime.now(),
          totalUsers: 20,
          activeUsers: 18,
          suspendedUsers: 2,
          newUsers: 5,
          roleDistribution: {UserRole.admin: 1, UserRole.operator: 17},
        );

        expect(report.totalUsers, 20);
        expect(report.activeUsers, 18);
        expect((report.activePercentage * 100).toStringAsFixed(0), '90');
      });
    });

    // ===== Integration Tests =====
    group('Integration Tests', () {
      test('Complete user lifecycle', () async {
        // Create user
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);
        
        // Create session
        final session = await userFacade.createSession('user1');
        expect(session!.isValid, true);

        // Grant permission
        await userFacade.grantPermissionToUser('user1', Permission.exportData);
        expect(await userFacade.userHasPermission('user1', Permission.exportData), true);

        // Record activity
        await userFacade.recordUserActivity('user1', 'login', '192.168.1.1');

        // Suspend user
        await userFacade.updateUserStatus('user1', UserStatus.suspended);
        final updated = await userFacade.getUserById('user1');
        expect(updated!.status, UserStatus.suspended);

        // Terminate session
        await userFacade.terminateSession(session.sessionId);
        expect(await userFacade.validateSession(session.sessionId), false);
      });

      test('Role-based access control workflow', () async {
        // Create roles
        await userFacade.createRole(
          'manager_role',
          'Manager Role',
          UserRole.manager,
          [Permission.createJob, Permission.readJob, Permission.viewReports],
        );

        // Create users with different roles
        await userFacade.createUser('manager1', 'manager', 'mgr@example.com', UserRole.manager);
        await userFacade.createUser('operator1', 'operator', 'op@example.com', UserRole.operator);

        // Verify manager has permissions
        expect(await userFacade.userHasPermission('manager1', Permission.createJob), true);

        // Grant additional permissions
        await userFacade.grantPermissionToUser('operator1', Permission.viewReports);
        expect(await userFacade.userHasPermission('operator1', Permission.viewReports), true);
      });

      test('Audit trail for permission changes', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);
        
        // Grant permission
        await userFacade.grantPermissionToUser('user1', Permission.exportData);
        await userFacade.recordAuditLog('admin', 'permission_granted', {
          'userId': 'user1',
          'permission': 'export_data',
        });

        // Revoke permission
        await userFacade.revokePermissionFromUser('user1', Permission.exportData);
        await userFacade.recordAuditLog('admin', 'permission_revoked', {
          'userId': 'user1',
          'permission': 'export_data',
        });

        // Verify audit logs
        final logs = await userFacade.getAuditLogs();
        expect(logs.isNotEmpty, true);
      });

      test('User activity monitoring and anomaly detection', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);

        // Record normal activities
        await userFacade.recordUserActivity('user1', 'login', '192.168.1.100');
        await userFacade.recordUserActivity('user1', 'view_report', '192.168.1.100');

        // Record anomalous activity
        await userFacade.recordAnomalousActivity('user1', 'multiple_failed_logins', '192.168.1.50');

        // Verify anomalies are tracked
        final activities = await userFacade.getUserActivities('user1');
        final anomalies = activities.where((a) => a.isAnomalous).toList();
        expect(anomalies.isNotEmpty, true);
      });
    });

    // ===== Edge Case Tests =====
    group('Edge Cases', () {
      test('Empty username handling', () async {
        expect(
          () => userFacade.createUser('user1', '', 'email@example.com', UserRole.operator),
          throwsException,
        );
      });

      test('Invalid email format', () async {
        expect(
          () => userFacade.createUser('user1', 'john', 'invalid_email', UserRole.operator),
          throwsException,
        );
      });

      test('Permission expiration handling', () async {
        final expiryDate = DateTime.now().subtract(Duration(days: 1));
        final perm = PermissionAssignment(
          assignmentId: 'perm1',
          userId: 'user1',
          permission: Permission.exportData,
          grantedAt: DateTime.now().subtract(Duration(days: 2)),
          expiresAt: expiryDate,
        );

        expect(perm.isExpired, true);
      });

      test('Session timeout validation', () async {
        final pastDate = DateTime.now().subtract(Duration(hours: 25));
        final session = Session(
          sessionId: 'session1',
          userId: 'user1',
          startedAt: pastDate,
          expiresAt: DateTime.now().subtract(Duration(hours: 1)),
          token: 'token',
        );

        expect(session.isValid, false);
      });

      test('Concurrent session handling', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);

        final session1 = await userFacade.createSession('user1');
        final session2 = await userFacade.createSession('user1');

        expect(session1!.sessionId != session2!.sessionId, true);
        expect(session1.isValid && session2.isValid, true);
      });

      test('Role with no permissions', () async {
        final role = Role(
          roleId: 'role1',
          roleName: 'Guest',
          userRole: UserRole.guest,
          permissions: [],
          createdAt: DateTime(2026, 1, 1),
        );

        expect(role.permissionCount, 0);
        expect(role.hasPermission(Permission.readJob), false);
      });

      test('User with multiple role assignments', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);
        
        // Grant additional specific permissions beyond role
        await userFacade.grantPermissionToUser('user1', Permission.manageUsers);
        await userFacade.grantPermissionToUser('user1', Permission.exportData);

        final permissions = await userFacade.getUserPermissions('user1');
        expect(permissions.length >= 2, true);
      });
    });

    // ===== Error Handling Tests =====
    group('Error Handling', () {
      test('Handle non-existent user operations', () async {
        expect(await userFacade.getUserById('nonexistent'), isNull);
        expect(await userFacade.getRoleById('nonexistent'), isNull);
        expect(await userFacade.getACLById('nonexistent'), isNull);
      });

      test('Handle invalid status transitions', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);

        // Valid transition
        final suspended = await userFacade.updateUserStatus('user1', UserStatus.suspended);
        expect(suspended!.status, UserStatus.suspended);

        // Can transition back
        final reactivated = await userFacade.updateUserStatus('user1', UserStatus.active);
        expect(reactivated!.status, UserStatus.active);
      });

      test('Handle permission grant to active user only', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);
        await userFacade.updateUserStatus('user1', UserStatus.inactive);

        // Should handle gracefully
        final result = await userFacade.grantPermissionToUser('user1', Permission.readJob);
        expect(result, isNotNull);
      });

      test('Handle session termination idempotency', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);
        final session = await userFacade.createSession('user1');

        await userFacade.terminateSession(session!.sessionId);
        
        // Terminating again should not throw
        await userFacade.terminateSession(session.sessionId);
        
        expect(await userFacade.validateSession(session.sessionId), false);
      });

      test('Concurrent permission modifications', () async {
        await userFacade.createUser('user1', 'john', 'john@example.com', UserRole.operator);

        await userFacade.grantPermissionToUser('user1', Permission.exportData);
        await userFacade.grantPermissionToUser('user1', Permission.viewReports);

        final permissions = await userFacade.getUserPermissions('user1');
        expect(permissions.contains(Permission.exportData), true);
      });
    });

    // ===== Calculation Tests =====
    group('Calculated Properties', () {
      test('Account age calculation accuracy', () {
        final createdAt = DateTime(2026, 1, 1);
        final user = User(
          userId: 'user1',
          username: 'john',
          email: 'john@example.com',
          role: UserRole.operator,
          status: UserStatus.active,
          createdAt: createdAt,
        );

        expect(user.accountAgeInDays > 0, true);
      });

      test('Password expiry calculation', () {
        final lastChange = DateTime(2026, 3, 1);
        final user = User(
          userId: 'user1',
          username: 'john',
          email: 'john@example.com',
          role: UserRole.operator,
          status: UserStatus.active,
          createdAt: DateTime(2026, 1, 1),
          lastPasswordChangeAt: lastChange,
        );

        expect(user.needsPasswordChange, true);
      });

      test('Role complexity score', () {
        final strictRole = Role(
          roleId: 'role1',
          roleName: 'Admin',
          userRole: UserRole.admin,
          permissions: [
            Permission.createJob,
            Permission.deleteJob,
            Permission.manageUsers,
            Permission.manageRoles,
            Permission.configureSystem,
          ],
          createdAt: DateTime(2026, 1, 1),
        );

        expect(strictRole.permissionCount, 5);
      });

      test('Session duration calculation', () {
        final start = DateTime(2026, 9, 1, 10, 0, 0);
        final end = DateTime(2026, 9, 1, 12, 30, 45);
        
        final session = Session(
          sessionId: 'session1',
          userId: 'user1',
          startedAt: start,
          expiresAt: end,
          token: 'token',
        );

        expect(session.durationInSeconds, 9045);
      });
    });
  });
}
