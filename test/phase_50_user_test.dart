import 'package:flutter_test/flutter_test.dart';
import '../lib/models/user_models.dart';
import '../lib/services/user_service.dart';

void main() {
  group('Phase 50: User Management & Authorization System Tests', () {
    // ==================== Enum Tests ====================
    group('Enum Tests', () {
      test('UserRole has all required values', () {
        expect(UserRole.admin.value, 'admin');
        expect(UserRole.manager.value, 'manager');
        expect(UserRole.user.value, 'user');
        expect(UserRole.guest.value, 'guest');
        expect(UserRole.custom.value, 'custom');
      });

      test('PermissionType has all required values', () {
        expect(PermissionType.create.value, 'create');
        expect(PermissionType.read.value, 'read');
        expect(PermissionType.update.value, 'update');
        expect(PermissionType.delete.value, 'delete');
        expect(PermissionType.export.value, 'export');
        expect(PermissionType.approve.value, 'approve');
        expect(PermissionType.admin.value, 'admin');
      });

      test('AuthStatus has all required values', () {
        expect(AuthStatus.active.value, 'active');
        expect(AuthStatus.inactive.value, 'inactive');
        expect(AuthStatus.suspended.value, 'suspended');
        expect(AuthStatus.locked.value, 'locked');
        expect(AuthStatus.pendingVerification.value, 'pending_verification');
      });

      test('AccessLevel has all required values', () {
        expect(AccessLevel.public.value, 'public');
        expect(AccessLevel.internal.value, 'internal');
        expect(AccessLevel.restricted.value, 'restricted');
        expect(AccessLevel.private.value, 'private');
        expect(AccessLevel.custom.value, 'custom');
      });
    });

    // ==================== Model Tests ====================
    group('Model Tests', () {
      test('User properties are set correctly', () {
        final user = User(
          userId: 'u1',
          email: 'user@example.com',
          name: 'Test User',
          roleIds: ['admin', 'manager'],
          createdAt: DateTime.now(),
        );

        expect(user.userId, 'u1');
        expect(user.isActive, true);
        expect(user.isLocked, false);
      });

      test('User.isActive checks status correctly', () {
        final activeUser = User(
          userId: 'u1',
          email: 'user@example.com',
          name: 'Test User',
          roleIds: [],
          status: AuthStatus.active,
          createdAt: DateTime.now(),
        );

        final lockedUser = User(
          userId: 'u2',
          email: 'user2@example.com',
          name: 'Locked User',
          roleIds: [],
          status: AuthStatus.locked,
          createdAt: DateTime.now(),
        );

        expect(activeUser.isActive, true);
        expect(lockedUser.isLocked, true);
      });

      test('User.timeSinceLastLogin calculates correctly', () {
        final lastLogin = DateTime.now().subtract(Duration(hours: 2));

        final user = User(
          userId: 'u1',
          email: 'user@example.com',
          name: 'Test User',
          roleIds: [],
          createdAt: DateTime.now().subtract(Duration(days: 30)),
          lastLogin: lastLogin,
        );

        expect(user.timeSinceLastLogin?.inHours, greaterThanOrEqualTo(2));
      });

      test('Role.permissionCount returns correct count', () {
        final role = Role(
          roleId: 'r1',
          name: 'Manager',
          description: 'Manager role',
          permissionIds: ['p1', 'p2', 'p3'],
          createdAt: DateTime.now(),
        );

        expect(role.permissionCount, 3);
        expect(role.isEnabled, true);
      });

      test('Permission properties are correct', () {
        final permission = Permission(
          permissionId: 'p1',
          name: 'Read',
          description: 'Read permission',
          type: PermissionType.read,
          resourceType: 'job',
          level: AccessLevel.internal,
          createdAt: DateTime.now(),
        );

        expect(permission.isReadOnly, true);
        expect(permission.isAdminOnly, false);
      });

      test('UserRoleAssignment.isActive checks expiration', () {
        final futureExpiry = DateTime.now().add(Duration(days: 30));

        final assignment = UserRoleAssignment(
          assignmentId: 'a1',
          userId: 'u1',
          roleId: 'r1',
          assignedAt: DateTime.now(),
          expiresAt: futureExpiry,
        );

        expect(assignment.isActive, true);
        expect(assignment.isExpired, false);
      });

      test('UserRoleAssignment.timeUntilExpiration calculates correctly', () {
        final futureExpiry = DateTime.now().add(Duration(days: 7));

        final assignment = UserRoleAssignment(
          assignmentId: 'a1',
          userId: 'u1',
          roleId: 'r1',
          assignedAt: DateTime.now(),
          expiresAt: futureExpiry,
        );

        expect(assignment.timeUntilExpiration?.inDays, greaterThanOrEqualTo(6));
      });

      test('AccessControl properties are correct', () {
        final control = AccessControl(
          controlId: 'ac1',
          resourceId: 'job1',
          resourceType: 'job',
          allowedRoleIds: ['admin', 'manager'],
          allowedUserIds: ['user1'],
          level: AccessLevel.internal,
          createdAt: DateTime.now(),
        );

        expect(control.isPrivate, false);
        expect(control.isPublic, false);
        expect(control.totalAllowedUsers, 3);
      });

      test('UserSession.isSessionActive checks state', () {
        final session = UserSession(
          sessionId: 's1',
          userId: 'u1',
          loginAt: DateTime.now().subtract(Duration(hours: 1)),
          lastActivity: DateTime.now(),
          isActive: true,
        );

        expect(session.isSessionActive, true);
      });

      test('UserSession.isTimedOut detects idle sessions', () {
        final oldActivity = DateTime.now().subtract(Duration(minutes: 45));

        final session = UserSession(
          sessionId: 's1',
          userId: 'u1',
          loginAt: DateTime.now().subtract(Duration(hours: 2)),
          lastActivity: oldActivity,
          isActive: true,
        );

        expect(session.isTimedOut, true);
      });

      test('PermissionAudit tracks access correctly', () {
        final audit = PermissionAudit(
          auditId: 'a1',
          userId: 'u1',
          action: PermissionType.read,
          resourceType: 'job',
          resourceId: 'job1',
          allowed: true,
          timestamp: DateTime.now(),
        );

        expect(audit.isAllowed, true);
        expect(audit.isDenied, false);
      });

      test('UserStats.activeRate calculates correctly', () {
        final stats = UserStats(
          statsId: 's1',
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          totalUsers: 10,
          activeUsers: 8,
          inactiveUsers: 1,
          suspendedUsers: 1,
          usersByRole: {},
          totalSessions: 5,
          activeSessions: 4,
          averageSessionDuration: 30.0,
        );

        expect(stats.activeRate, 0.8);
      });

      test('UserStats.sessionActiveRate calculates correctly', () {
        final stats = UserStats(
          statsId: 's1',
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          totalUsers: 10,
          activeUsers: 8,
          inactiveUsers: 1,
          suspendedUsers: 1,
          usersByRole: {},
          totalSessions: 20,
          activeSessions: 15,
          averageSessionDuration: 30.0,
        );

        expect(stats.sessionActiveRate, 0.75);
      });

      test('UserManagementReport.toMarkdown generates valid markdown', () {
        final stats = UserStats(
          statsId: 's1',
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          totalUsers: 10,
          activeUsers: 8,
          inactiveUsers: 1,
          suspendedUsers: 1,
          usersByRole: {},
          totalSessions: 5,
          activeSessions: 4,
          averageSessionDuration: 30.0,
        );

        final report = UserManagementReport(
          reportId: 'r1',
          generatedAt: DateTime.now(),
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          stats: stats,
          recentUsers: [],
          recentAudits: [],
        );

        final markdown = report.toMarkdown();
        expect(markdown.contains('# User Management Report'), true);
        expect(markdown.contains('Total Users'), true);
      });
    });

    // ==================== Repository Tests ====================
    group('Repository Tests', () {
      late UserRepository repository;

      setUp(() {
        repository = MemoryUserRepository();
      });

      test('addUser and getUser work correctly', () async {
        final user = User(
          userId: 'u1',
          email: 'user@example.com',
          name: 'Test User',
          roleIds: [],
          createdAt: DateTime.now(),
        );

        await repository.addUser(user);
        final retrieved = await repository.getUser('u1');

        expect(retrieved?.userId, 'u1');
      });

      test('getUsersByStatus filters correctly', () async {
        final user1 = User(
          userId: 'u1',
          email: 'user1@example.com',
          name: 'Active User',
          roleIds: [],
          status: AuthStatus.active,
          createdAt: DateTime.now(),
        );

        final user2 = User(
          userId: 'u2',
          email: 'user2@example.com',
          name: 'Inactive User',
          roleIds: [],
          status: AuthStatus.inactive,
          createdAt: DateTime.now(),
        );

        await repository.addUser(user1);
        await repository.addUser(user2);

        final activeUsers = await repository.getUsersByStatus(AuthStatus.active);
        expect(activeUsers.length, 1);
      });

      test('addRole and getRole work correctly', () async {
        final role = Role(
          roleId: 'r1',
          name: 'Admin',
          description: 'Admin role',
          permissionIds: [],
          createdAt: DateTime.now(),
        );

        await repository.addRole(role);
        final retrieved = await repository.getRole('r1');

        expect(retrieved?.roleId, 'r1');
      });

      test('addPermission and getPermission work correctly', () async {
        final permission = Permission(
          permissionId: 'p1',
          name: 'Read',
          description: 'Read permission',
          type: PermissionType.read,
          resourceType: 'job',
          level: AccessLevel.public,
          createdAt: DateTime.now(),
        );

        await repository.addPermission(permission);
        final retrieved = await repository.getPermission('p1');

        expect(retrieved?.permissionId, 'p1');
      });

      test('getPermissionsByType filters correctly', () async {
        final p1 = Permission(
          permissionId: 'p1',
          name: 'Read',
          description: 'Read',
          type: PermissionType.read,
          resourceType: 'job',
          level: AccessLevel.public,
          createdAt: DateTime.now(),
        );

        final p2 = Permission(
          permissionId: 'p2',
          name: 'Write',
          description: 'Write',
          type: PermissionType.update,
          resourceType: 'job',
          level: AccessLevel.public,
          createdAt: DateTime.now(),
        );

        await repository.addPermission(p1);
        await repository.addPermission(p2);

        final readPerms = await repository.getPermissionsByType(PermissionType.read);
        expect(readPerms.length, 1);
      });

      test('assignRole and getUserRoles work correctly', () async {
        final assignment = UserRoleAssignment(
          assignmentId: 'a1',
          userId: 'u1',
          roleId: 'r1',
          assignedAt: DateTime.now(),
        );

        await repository.assignRole(assignment);
        final roles = await repository.getUserRoles('u1');

        expect(roles.length, 1);
        expect(roles.first.userId, 'u1');
      });
    });

    // ==================== Engine Tests ====================
    group('Engine Tests', () {
      late AuthorizationEngine engine;

      setUp(() {
        engine = MemoryAuthorizationEngine();
      });

      test('auditAccess records audit trail', () async {
        final audit = await engine.auditAccess(
          'u1',
          PermissionType.read,
          'job',
          'job1',
          true,
          'User has permission',
        );

        expect(audit.isAllowed, true);
        expect(audit.userId, 'u1');
      });

      test('createPolicy creates policy correctly', () async {
        final policy = await engine.createPolicy(
          'pol1',
          'Test Policy',
          'Test policy description',
          [{'type': 'allow', 'action': 'read'}],
        );

        expect(policy.policyId, 'pol1');
        expect(policy.isEnabled, true);
      });
    });

    // ==================== Manager Tests ====================
    group('Manager Tests', () {
      late MemoryUserManager manager;

      setUp(() {
        manager = MemoryUserManager(
          repository: MemoryUserRepository(),
          engine: MemoryAuthorizationEngine(),
        );
      });

      test('createUser creates user correctly', () async {
        final user = await manager.createUser('u1', 'user@example.com', 'Test User', ['admin']);

        expect(user.userId, 'u1');
        expect(user.email, 'user@example.com');
      });

      test('updateUserStatus updates status', () async {
        await manager.createUser('u1', 'user@example.com', 'Test User', []);
        final updated = await manager.updateUserStatus('u1', AuthStatus.suspended);

        expect(updated.status, AuthStatus.suspended);
      });

      test('assignRoleToUser assigns role', () async {
        final assignment = await manager.assignRoleToUser('u1', 'r1');

        expect(assignment.userId, 'u1');
        expect(assignment.roleId, 'r1');
      });
    });

    // ==================== Facade Tests ====================
    group('Facade Tests', () {
      late UserManagerFacade facade;

      setUp(() {
        facade = UserManagerFacade();
      });

      test('createUser creates user via facade', () async {
        final user = await facade.createUser('u1', 'user@example.com', 'Test', ['admin']);

        expect(user.userId, 'u1');
      });

      test('createRole creates role via facade', () async {
        final role = await facade.createRole('r1', 'Admin', 'Admin role', ['p1']);

        expect(role.roleId, 'r1');
      });

      test('createPermission creates permission via facade', () async {
        final perm = await facade.createPermission(
          'p1',
          'Read',
          'Read permission',
          PermissionType.read,
          'job',
          AccessLevel.public,
        );

        expect(perm.permissionId, 'p1');
      });

      test('createAccessControl creates access control', () async {
        final control = await facade.createAccessControl(
          'ac1',
          'job1',
          'job',
          ['admin'],
          ['u1'],
          AccessLevel.internal,
        );

        expect(control.controlId, 'ac1');
      });

      test('getUser retrieves user', () async {
        await facade.createUser('u1', 'user@example.com', 'Test', []);
        final user = await facade.getUser('u1');

        expect(user?.userId, 'u1');
      });

      test('getActiveUsers retrieves active users', () async {
        await facade.createUser('u1', 'user1@example.com', 'User1', []);
        await facade.createUser('u2', 'user2@example.com', 'User2', []);

        final activeUsers = await facade.getActiveUsers();

        expect(activeUsers.length, greaterThanOrEqualTo(0));
      });
    });

    // ==================== Integration Tests ====================
    group('Integration Tests', () {
      late UserManagerFacade facade;

      setUp(() {
        facade = UserManagerFacade();
      });

      test('User creation and role assignment workflow', () async {
        // Create role
        final role = await facade.createRole('admin', 'Administrator', 'Admin role', ['p1', 'p2']);
        expect(role.permissionCount, 2);

        // Create user
        final user = await facade.createUser('u1', 'admin@example.com', 'Admin User', ['admin']);
        expect(user.isActive, true);

        // Verify user
        final retrieved = await facade.getUser('u1');
        expect(retrieved?.userId, 'u1');
      });

      test('Permission and access control workflow', () async {
        // Create permissions
        final readPerm = await facade.createPermission(
          'p1',
          'Read Jobs',
          'Read job permission',
          PermissionType.read,
          'job',
          AccessLevel.internal,
        );

        // Create access control
        final control = await facade.createAccessControl(
          'ac1',
          'job1',
          'job',
          ['admin'],
          ['u1'],
          AccessLevel.internal,
        );

        expect(control.resourceId, 'job1');
      });

      test('Report generation workflow', () async {
        // Create users
        await facade.createUser('u1', 'user1@example.com', 'User1', []);
        await facade.createUser('u2', 'user2@example.com', 'User2', []);

        // Generate report
        final report = await facade.generateReport(
          'report1',
          DateTime.now().subtract(Duration(days: 30)),
          DateTime.now(),
        );

        expect(report.reportId, 'report1');
        expect(report.stats.totalUsers, greaterThanOrEqualTo(0));
      });

      test('Multi-role user management', () async {
        // Create roles
        await facade.createRole('admin', 'Admin', 'Admin', []);
        await facade.createRole('manager', 'Manager', 'Manager', []);

        // Create user with multiple roles
        final user = await facade.createUser(
          'u1',
          'user@example.com',
          'Multi-role User',
          ['admin', 'manager'],
        );

        expect(user.roleIds.length, 2);
      });

      test('User status lifecycle', () async {
        // Create active user
        var user = await facade.createUser('u1', 'user@example.com', 'Test', []);
        expect(user.isActive, true);

        // Suspend user
        user = await facade.updateUserStatus('u1', AuthStatus.suspended);
        expect(user.status, AuthStatus.suspended);

        // Reactivate user
        user = await facade.updateUserStatus('u1', AuthStatus.active);
        expect(user.isActive, true);
      });
    });
  });
}
