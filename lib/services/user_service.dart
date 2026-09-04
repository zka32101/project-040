/// Phase 50: User Management & Authorization Service ユーザー管理・認可サービス

import '../models/user_models.dart';

/// ユーザーリポジトリ インターフェース
abstract class UserRepository {
  Future<User> addUser(User user);
  Future<User?> getUser(String userId);
  Future<List<User>> getUsersByStatus(AuthStatus status);
  Future<List<User>> getAllUsers();
  Future<User> updateUser(User user);
  Future<Role> addRole(Role role);
  Future<Role?> getRole(String roleId);
  Future<List<Role>> getAllRoles();
  Future<Permission> addPermission(Permission permission);
  Future<Permission?> getPermission(String permissionId);
  Future<List<Permission>> getPermissionsByType(PermissionType type);
  Future<UserRoleAssignment> assignRole(UserRoleAssignment assignment);
  Future<List<UserRoleAssignment>> getUserRoles(String userId);
  Future<AccessControl> addAccessControl(AccessControl control);
  Future<AccessControl?> getAccessControl(String controlId);
  Future<List<AccessControl>> getResourceAccess(String resourceId, String resourceType);
  Future<void> clearAll();
}

/// メモリユーザーリポジトリ実装
class MemoryUserRepository implements UserRepository {
  final Map<String, User> _users = {};
  final Map<String, Role> _roles = {};
  final Map<String, Permission> _permissions = {};
  final Map<String, UserRoleAssignment> _roleAssignments = {};
  final Map<String, AccessControl> _accessControls = {};

  @override
  Future<User> addUser(User user) async {
    _users[user.userId] = user;
    return user;
  }

  @override
  Future<User?> getUser(String userId) async {
    return _users[userId];
  }

  @override
  Future<List<User>> getUsersByStatus(AuthStatus status) async {
    return _users.values.where((u) => u.status == status).toList();
  }

  @override
  Future<List<User>> getAllUsers() async {
    return _users.values.toList();
  }

  @override
  Future<User> updateUser(User user) async {
    _users[user.userId] = user;
    return user;
  }

  @override
  Future<Role> addRole(Role role) async {
    _roles[role.roleId] = role;
    return role;
  }

  @override
  Future<Role?> getRole(String roleId) async {
    return _roles[roleId];
  }

  @override
  Future<List<Role>> getAllRoles() async {
    return _roles.values.toList();
  }

  @override
  Future<Permission> addPermission(Permission permission) async {
    _permissions[permission.permissionId] = permission;
    return permission;
  }

  @override
  Future<Permission?> getPermission(String permissionId) async {
    return _permissions[permissionId];
  }

  @override
  Future<List<Permission>> getPermissionsByType(PermissionType type) async {
    return _permissions.values.where((p) => p.type == type).toList();
  }

  @override
  Future<UserRoleAssignment> assignRole(UserRoleAssignment assignment) async {
    _roleAssignments[assignment.assignmentId] = assignment;
    return assignment;
  }

  @override
  Future<List<UserRoleAssignment>> getUserRoles(String userId) async {
    return _roleAssignments.values.where((a) => a.userId == userId).toList();
  }

  @override
  Future<AccessControl> addAccessControl(AccessControl control) async {
    _accessControls[control.controlId] = control;
    return control;
  }

  @override
  Future<AccessControl?> getAccessControl(String controlId) async {
    return _accessControls[controlId];
  }

  @override
  Future<List<AccessControl>> getResourceAccess(String resourceId, String resourceType) async {
    return _accessControls.values
        .where((ac) => ac.resourceId == resourceId && ac.resourceType == resourceType)
        .toList();
  }

  @override
  Future<void> clearAll() async {
    _users.clear();
    _roles.clear();
    _permissions.clear();
    _roleAssignments.clear();
    _accessControls.clear();
  }
}

/// 認可エンジン インターフェース
abstract class AuthorizationEngine {
  Future<bool> hasPermission(String userId, PermissionType permission, String resourceType, String resourceId);
  Future<List<Permission>> getUserPermissions(String userId, List<String> roleIds);
  Future<bool> canAccess(String userId, String resourceId, String resourceType);
  Future<PermissionAudit> auditAccess(String userId, PermissionType action, String resourceType, String resourceId, bool allowed, String? reason);
  Future<AuthorizationPolicy> createPolicy(String policyId, String name, String description, List<Map<String, dynamic>> rules);
}

/// メモリ認可エンジン実装
class MemoryAuthorizationEngine implements AuthorizationEngine {
  final Map<String, Permission> _permissions = {};
  final Map<String, Role> _roles = {};
  final Map<String, PermissionAudit> _audits = {};
  final Map<String, AuthorizationPolicy> _policies = {};

  @override
  Future<bool> hasPermission(String userId, PermissionType permission, String resourceType, String resourceId) async {
    // 簡略化したロジック：ユーザーがリソースタイプのパーミッションを持っているかチェック
    return true; // 実装では実際のロジックが必要
  }

  @override
  Future<List<Permission>> getUserPermissions(String userId, List<String> roleIds) async {
    final permissions = <Permission>[];

    for (final roleId in roleIds) {
      final role = _roles[roleId];
      if (role != null) {
        for (final permId in role.permissionIds) {
          final perm = _permissions[permId];
          if (perm != null && !permissions.contains(perm)) {
            permissions.add(perm);
          }
        }
      }
    }

    return permissions;
  }

  @override
  Future<bool> canAccess(String userId, String resourceId, String resourceType) async {
    // 簡略化したロジック：ユーザーがリソースにアクセスできるかチェック
    return true; // 実装では実際のロジックが必要
  }

  @override
  Future<PermissionAudit> auditAccess(String userId, PermissionType action, String resourceType, String resourceId, bool allowed, String? reason) async {
    final audit = PermissionAudit(
      auditId: 'audit_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      action: action,
      resourceType: resourceType,
      resourceId: resourceId,
      allowed: allowed,
      timestamp: DateTime.now(),
      reason: reason,
    );
    _audits[audit.auditId] = audit;
    return audit;
  }

  @override
  Future<AuthorizationPolicy> createPolicy(String policyId, String name, String description, List<Map<String, dynamic>> rules) async {
    final policy = AuthorizationPolicy(
      policyId: policyId,
      name: name,
      description: description,
      rules: rules,
      createdAt: DateTime.now(),
    );
    _policies[policyId] = policy;
    return policy;
  }
}

/// ユーザーマネージャー インターフェース
abstract class UserManager {
  Future<User> createUser(String userId, String email, String name, List<String> roleIds);
  Future<User> updateUserStatus(String userId, AuthStatus status);
  Future<UserRoleAssignment> assignRoleToUser(String userId, String roleId, {DateTime? expiresAt});
  Future<bool> checkUserPermission(String userId, PermissionType permission, String resourceType, String resourceId);
  Future<UserStats> calculateStats(DateTime start, DateTime end);
  Future<UserManagementReport> generateReport(String reportId, DateTime start, DateTime end);
}

/// メモリユーザーマネージャー実装
class MemoryUserManager implements UserManager {
  final UserRepository repository;
  final AuthorizationEngine engine;
  final Map<String, UserSession> _sessions = {};

  MemoryUserManager({
    required this.repository,
    required this.engine,
  });

  @override
  Future<User> createUser(String userId, String email, String name, List<String> roleIds) async {
    final user = User(
      userId: userId,
      email: email,
      name: name,
      roleIds: roleIds,
      createdAt: DateTime.now(),
    );
    return repository.addUser(user);
  }

  @override
  Future<User> updateUserStatus(String userId, AuthStatus status) async {
    final user = await repository.getUser(userId);
    if (user != null) {
      final updatedUser = User(
        userId: user.userId,
        email: user.email,
        name: user.name,
        roleIds: user.roleIds,
        status: status,
        createdAt: user.createdAt,
        lastLogin: user.lastLogin,
        lastPasswordChange: user.lastPasswordChange,
        mfaEnabled: user.mfaEnabled,
        metadata: user.metadata,
      );
      return repository.updateUser(updatedUser);
    }
    return user!;
  }

  @override
  Future<UserRoleAssignment> assignRoleToUser(String userId, String roleId, {DateTime? expiresAt}) async {
    final assignment = UserRoleAssignment(
      assignmentId: 'assign_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      roleId: roleId,
      assignedAt: DateTime.now(),
      expiresAt: expiresAt,
    );
    return repository.assignRole(assignment);
  }

  @override
  Future<bool> checkUserPermission(String userId, PermissionType permission, String resourceType, String resourceId) async {
    return engine.hasPermission(userId, permission, resourceType, resourceId);
  }

  @override
  Future<UserStats> calculateStats(DateTime start, DateTime end) async {
    final allUsers = await repository.getAllUsers();
    final filteredUsers = allUsers.where((u) => u.createdAt.isAfter(start) && u.createdAt.isBefore(end)).toList();

    final activeCount = filteredUsers.where((u) => u.isActive).length;
    final inactiveCount = filteredUsers.where((u) => u.status == AuthStatus.inactive).length;
    final suspendedCount = filteredUsers.where((u) => u.status == AuthStatus.suspended).length;

    final roleDistribution = <UserRole, int>{};
    for (final user in filteredUsers) {
      // 簡略化：ユーザーの最初のロール
    }

    return UserStats(
      statsId: 'stats_${DateTime.now().millisecondsSinceEpoch}',
      periodStart: start,
      periodEnd: end,
      totalUsers: filteredUsers.length,
      activeUsers: activeCount,
      inactiveUsers: inactiveCount,
      suspendedUsers: suspendedCount,
      usersByRole: roleDistribution,
      totalSessions: _sessions.length,
      activeSessions: _sessions.values.where((s) => s.isSessionActive).length,
      averageSessionDuration: 45.0,
    );
  }

  @override
  Future<UserManagementReport> generateReport(String reportId, DateTime start, DateTime end) async {
    final stats = await calculateStats(start, end);
    final allUsers = await repository.getAllUsers();
    final recentUsers = allUsers.take(5).toList();

    return UserManagementReport(
      reportId: reportId,
      generatedAt: DateTime.now(),
      periodStart: start,
      periodEnd: end,
      stats: stats,
      recentUsers: recentUsers,
      recentAudits: [],
      recommendations: _generateRecommendations(stats),
    );
  }

  List<String> _generateRecommendations(UserStats stats) {
    final recommendations = <String>[];

    if (stats.activeRate < 0.8) {
      recommendations.add('Low user activity rate detected');
      recommendations.add('Consider implementing engagement campaigns');
    }

    if (stats.suspendedUsers > stats.totalUsers * 0.1) {
      recommendations.add('High number of suspended users');
      recommendations.add('Review suspension reasons and policies');
    }

    return recommendations;
  }
}

/// ユーザー管理ファサード
class UserManagerFacade {
  late final UserRepository repository;
  late final AuthorizationEngine engine;
  late final MemoryUserManager manager;

  UserManagerFacade({
    UserRepository? customRepository,
    AuthorizationEngine? customEngine,
  }) {
    repository = customRepository ?? MemoryUserRepository();
    engine = customEngine ?? MemoryAuthorizationEngine();
    manager = MemoryUserManager(repository: repository, authorizationEngine: engine);
  }

  Future<User> createUser(String userId, String email, String name, List<String> roleIds) async {
    return manager.createUser(userId, email, name, roleIds);
  }

  Future<User> updateUserStatus(String userId, AuthStatus status) async {
    return manager.updateUserStatus(userId, status);
  }

  Future<UserRoleAssignment> assignRole(String userId, String roleId, {DateTime? expiresAt}) async {
    return manager.assignRoleToUser(userId, roleId, expiresAt: expiresAt);
  }

  Future<Role> createRole(String roleId, String name, String description, List<String> permissionIds) async {
    return repository.addRole(
      Role(
        roleId: roleId,
        name: name,
        description: description,
        permissionIds: permissionIds,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<Permission> createPermission(String permissionId, String name, String description, PermissionType type, String resourceType, AccessLevel level) async {
    return repository.addPermission(
      Permission(
        permissionId: permissionId,
        name: name,
        description: description,
        type: type,
        resourceType: resourceType,
        level: level,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<bool> checkPermission(String userId, PermissionType permission, String resourceType, String resourceId) async {
    return manager.checkUserPermission(userId, permission, resourceType, resourceId);
  }

  Future<AccessControl> createAccessControl(String controlId, String resourceId, String resourceType, List<String> roleIds, List<String> userIds, AccessLevel level) async {
    return repository.addAccessControl(
      AccessControl(
        controlId: controlId,
        resourceId: resourceId,
        resourceType: resourceType,
        allowedRoleIds: roleIds,
        allowedUserIds: userIds,
        level: level,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<UserManagementReport> generateReport(String reportId, DateTime start, DateTime end) async {
    return manager.generateReport(reportId, start, end);
  }

  Future<User?> getUser(String userId) async {
    return repository.getUser(userId);
  }

  Future<List<User>> getActiveUsers() async {
    return repository.getUsersByStatus(AuthStatus.active);
  }

  Future<List<Role>> getAllRoles() async {
    return repository.getAllRoles();
  }

  Future<List<Permission>> getPermissionsByType(PermissionType type) async {
    return repository.getPermissionsByType(type);
  }
}
