import '../models/user_models.dart';

/// ユーザーリポジトリインターフェース
abstract class UserRepository {
  // ユーザー操作
  Future<void> addUser(User user);
  Future<User?> getUser(String userId);
  Future<User?> getUserByUsername(String username);
  Future<User?> getUserByEmail(String email);
  Future<List<User>> getAllUsers();
  Future<List<User>> getUsersByRole(UserRole role);
  Future<List<User>> getActiveUsers();
  Future<void> updateUser(User user);
  Future<void> deleteUser(String userId);

  // ロール操作
  Future<void> addRole(Role role);
  Future<Role?> getRole(String roleId);
  Future<List<Role>> getAllRoles();
  Future<void> updateRole(Role role);
  Future<void> deleteRole(String roleId);

  // パーミッション割当
  Future<void> addPermissionAssignment(PermissionAssignment assignment);
  Future<PermissionAssignment?> getAssignment(String assignmentId);
  Future<List<PermissionAssignment>> getUserPermissions(String userId);
  Future<List<PermissionAssignment>> getActivePermissions(String userId);
  Future<void> deleteAssignment(String assignmentId);

  // セッション操作
  Future<void> addSession(Session session);
  Future<Session?> getSession(String sessionId);
  Future<List<Session>> getUserSessions(String userId);
  Future<List<Session>> getActiveSessions();
  Future<void> updateSession(Session session);
  Future<void> deleteSession(String sessionId);

  // 監査ログ操作
  Future<void> addAuditLog(AuditLog log);
  Future<AuditLog?> getAuditLog(String logId);
  Future<List<AuditLog>> getUserLogs(String userId);
  Future<List<AuditLog>> getFailedLogs();
  Future<void> deleteAuditLog(String logId);

  // ACL操作
  Future<void> addACL(AccessControlList acl);
  Future<AccessControlList?> getACL(String aclId);
  Future<List<AccessControlList>> getResourceACLs(String resourceId);
  Future<void> updateACL(AccessControlList acl);
  Future<void> deleteACL(String aclId);

  // アクティビティ操作
  Future<void> addActivity(UserActivity activity);
  Future<UserActivity?> getActivity(String activityId);
  Future<List<UserActivity>> getUserActivity(String userId);
  Future<void> updateActivity(UserActivity activity);

  // ポリシー操作
  Future<void> addPasswordPolicy(PasswordPolicy policy);
  Future<PasswordPolicy?> getPasswordPolicy(String policyId);
  Future<List<PasswordPolicy>> getAllPolicies();
  Future<void> updatePasswordPolicy(PasswordPolicy policy);
}

/// メモリ実装のユーザーリポジトリ
class MemoryUserRepository implements UserRepository {
  final Map<String, User> _users = {};
  final Map<String, Role> _roles = {};
  final Map<String, PermissionAssignment> _assignments = {};
  final Map<String, Session> _sessions = {};
  final Map<String, AuditLog> _auditLogs = {};
  final Map<String, AccessControlList> _acls = {};
  final Map<String, UserActivity> _activities = {};
  final Map<String, PasswordPolicy> _policies = {};

  @override
  Future<void> addUser(User user) async {
    _users[user.userId] = user;
  }

  @override
  Future<User?> getUser(String userId) async {
    return _users[userId];
  }

  @override
  Future<User?> getUserByUsername(String username) async {
    return _users.values.firstWhere(
      (u) => u.username == username,
      orElse: () => null as User,
    );
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    return _users.values.firstWhere(
      (u) => u.email == email,
      orElse: () => null as User,
    );
  }

  @override
  Future<List<User>> getAllUsers() async {
    return _users.values.toList();
  }

  @override
  Future<List<User>> getUsersByRole(UserRole role) async {
    return _users.values.where((u) => u.role == role).toList();
  }

  @override
  Future<List<User>> getActiveUsers() async {
    return _users.values.where((u) => u.isActive).toList();
  }

  @override
  Future<void> updateUser(User user) async {
    _users[user.userId] = user;
  }

  @override
  Future<void> deleteUser(String userId) async {
    _users.remove(userId);
  }

  @override
  Future<void> addRole(Role role) async {
    _roles[role.roleId] = role;
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
  Future<void> updateRole(Role role) async {
    _roles[role.roleId] = role;
  }

  @override
  Future<void> deleteRole(String roleId) async {
    _roles.remove(roleId);
  }

  @override
  Future<void> addPermissionAssignment(PermissionAssignment assignment) async {
    _assignments[assignment.assignmentId] = assignment;
  }

  @override
  Future<PermissionAssignment?> getAssignment(String assignmentId) async {
    return _assignments[assignmentId];
  }

  @override
  Future<List<PermissionAssignment>> getUserPermissions(String userId) async {
    return _assignments.values.where((a) => a.userId == userId).toList();
  }

  @override
  Future<List<PermissionAssignment>> getActivePermissions(String userId) async {
    return _assignments.values
        .where((a) => a.userId == userId && a.isActive)
        .toList();
  }

  @override
  Future<void> deleteAssignment(String assignmentId) async {
    _assignments.remove(assignmentId);
  }

  @override
  Future<void> addSession(Session session) async {
    _sessions[session.sessionId] = session;
  }

  @override
  Future<Session?> getSession(String sessionId) async {
    return _sessions[sessionId];
  }

  @override
  Future<List<Session>> getUserSessions(String userId) async {
    return _sessions.values.where((s) => s.userId == userId).toList();
  }

  @override
  Future<List<Session>> getActiveSessions() async {
    return _sessions.values.where((s) => s.isValid).toList();
  }

  @override
  Future<void> updateSession(Session session) async {
    _sessions[session.sessionId] = session;
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _sessions.remove(sessionId);
  }

  @override
  Future<void> addAuditLog(AuditLog log) async {
    _auditLogs[log.logId] = log;
  }

  @override
  Future<AuditLog?> getAuditLog(String logId) async {
    return _auditLogs[logId];
  }

  @override
  Future<List<AuditLog>> getUserLogs(String userId) async {
    return _auditLogs.values.where((l) => l.userId == userId).toList();
  }

  @override
  Future<List<AuditLog>> getFailedLogs() async {
    return _auditLogs.values.where((l) => !l.isSuccessful).toList();
  }

  @override
  Future<void> deleteAuditLog(String logId) async {
    _auditLogs.remove(logId);
  }

  @override
  Future<void> addACL(AccessControlList acl) async {
    _acls[acl.aclId] = acl;
  }

  @override
  Future<AccessControlList?> getACL(String aclId) async {
    return _acls[aclId];
  }

  @override
  Future<List<AccessControlList>> getResourceACLs(String resourceId) async {
    return _acls.values.where((a) => a.resourceId == resourceId).toList();
  }

  @override
  Future<void> updateACL(AccessControlList acl) async {
    _acls[acl.aclId] = acl;
  }

  @override
  Future<void> deleteACL(String aclId) async {
    _acls.remove(aclId);
  }

  @override
  Future<void> addActivity(UserActivity activity) async {
    _activities[activity.activityId] = activity;
  }

  @override
  Future<UserActivity?> getActivity(String activityId) async {
    return _activities[activityId];
  }

  @override
  Future<List<UserActivity>> getUserActivity(String userId) async {
    return _activities.values.where((a) => a.userId == userId).toList();
  }

  @override
  Future<void> updateActivity(UserActivity activity) async {
    _activities[activity.activityId] = activity;
  }

  @override
  Future<void> addPasswordPolicy(PasswordPolicy policy) async {
    _policies[policy.policyId] = policy;
  }

  @override
  Future<PasswordPolicy?> getPasswordPolicy(String policyId) async {
    return _policies[policyId];
  }

  @override
  Future<List<PasswordPolicy>> getAllPolicies() async {
    return _policies.values.toList();
  }

  @override
  Future<void> updatePasswordPolicy(PasswordPolicy policy) async {
    _policies[policy.policyId] = policy;
  }
}

/// 認可エンジンインターフェース
abstract class AuthorizationEngine {
  Future<bool> hasPermission(String userId, Permission permission);
  Future<bool> canPerformAction(String userId, String action, String resourceId);
  Future<List<Permission>> getUserPermissions(String userId);
  Future<void> enforceACL(String userId, String resourceId, String action);
  Future<bool> validateRole(String userId, UserRole requiredRole);
}

/// メモリ実装の認可エンジン
class MemoryAuthorizationEngine implements AuthorizationEngine {
  final UserRepository _repository;

  MemoryAuthorizationEngine(this._repository);

  @override
  Future<bool> hasPermission(String userId, Permission permission) async {
    final assignments = await _repository.getUserPermissions(userId);
    return assignments.any((a) => a.permission == permission && a.isActive);
  }

  @override
  Future<bool> canPerformAction(String userId, String action, String resourceId) async {
    // アクション処理
    return true;
  }

  @override
  Future<List<Permission>> getUserPermissions(String userId) async {
    final assignments = await _repository.getActivePermissions(userId);
    return assignments.map((a) => a.permission).toList();
  }

  @override
  Future<void> enforceACL(String userId, String resourceId, String action) async {
    // ACL処理
  }

  @override
  Future<bool> validateRole(String userId, UserRole requiredRole) async {
    final user = await _repository.getUser(userId);
    return user != null && user.role.value.compareTo(requiredRole.value) >= 0;
  }
}

/// セッションエンジンインターフェース
abstract class SessionEngine {
  Future<Session> createSession(String userId, String ipAddress, String userAgent);
  Future<void> updateSession(String sessionId);
  Future<void> terminateSession(String sessionId);
  Future<bool> validateSession(String sessionId);
}

/// メモリ実装のセッションエンジン
class MemorySessionEngine implements SessionEngine {
  final UserRepository _repository;

  MemorySessionEngine(this._repository);

  @override
  Future<Session> createSession(String userId, String ipAddress, String userAgent) async {
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final session = Session(
      sessionId: sessionId,
      userId: userId,
      ipAddress: ipAddress,
      userAgent: userAgent,
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(hours: 24)),
    );
    await _repository.addSession(session);
    return session;
  }

  @override
  Future<void> updateSession(String sessionId) async {
    final session = await _repository.getSession(sessionId);
    if (session != null) {
      final updated = Session(
        sessionId: session.sessionId,
        userId: session.userId,
        ipAddress: session.ipAddress,
        userAgent: session.userAgent,
        createdAt: session.createdAt,
        lastActivityAt: DateTime.now(),
        expiresAt: session.expiresAt,
      );
      await _repository.updateSession(updated);
    }
  }

  @override
  Future<void> terminateSession(String sessionId) async {
    final session = await _repository.getSession(sessionId);
    if (session != null) {
      await _repository.deleteSession(sessionId);
    }
  }

  @override
  Future<bool> validateSession(String sessionId) async {
    final session = await _repository.getSession(sessionId);
    return session != null && session.isValid;
  }
}

/// ユーザーマネージャーインターフェース
abstract class UserManager {
  Future<void> createUser(String username, String email, UserRole role);
  Future<void> updateUserRole(String userId, UserRole newRole);
  Future<void> grantPermission(String userId, Permission permission);
  Future<void> revokePermission(String userId, Permission permission);
  Future<void> suspendUser(String userId);
  Future<void> activateUser(String userId);
  Future<UserManagementReport> generateUserReport(DateTime start, DateTime end);
  Future<void> recordAuditLog(String userId, String action, String resourceType);
}

/// メモリ実装のユーザーマネージャー
class MemoryUserManager implements UserManager {
  final UserRepository _repository;
  final AuthorizationEngine _authEngine;
  final SessionEngine _sessionEngine;

  MemoryUserManager(this._repository, this._authEngine, this._sessionEngine);

  @override
  Future<void> createUser(String username, String email, UserRole role) async {
    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final user = User(
      userId: userId,
      username: username,
      email: email,
      role: role,
      createdAt: DateTime.now(),
    );
    await _repository.addUser(user);
  }

  @override
  Future<void> updateUserRole(String userId, UserRole newRole) async {
    final user = await _repository.getUser(userId);
    if (user != null) {
      final updated = User(
        userId: user.userId,
        username: user.username,
        email: user.email,
        displayName: user.displayName,
        role: newRole,
        status: user.status,
        createdAt: user.createdAt,
        lastLoginAt: user.lastLoginAt,
      );
      await _repository.updateUser(updated);
    }
  }

  @override
  Future<void> grantPermission(String userId, Permission permission) async {
    final assignmentId = 'perm_${DateTime.now().millisecondsSinceEpoch}';
    final assignment = PermissionAssignment(
      assignmentId: assignmentId,
      userId: userId,
      permission: permission,
      grantedAt: DateTime.now(),
    );
    await _repository.addPermissionAssignment(assignment);
  }

  @override
  Future<void> revokePermission(String userId, Permission permission) async {
    final assignments = await _repository.getUserPermissions(userId);
    for (final a in assignments.where((a) => a.permission == permission)) {
      await _repository.deleteAssignment(a.assignmentId);
    }
  }

  @override
  Future<void> suspendUser(String userId) async {
    final user = await _repository.getUser(userId);
    if (user != null) {
      final updated = User(
        userId: user.userId,
        username: user.username,
        email: user.email,
        role: user.role,
        status: UserStatus.suspended,
        createdAt: user.createdAt,
      );
      await _repository.updateUser(updated);
    }
  }

  @override
  Future<void> activateUser(String userId) async {
    final user = await _repository.getUser(userId);
    if (user != null) {
      final updated = User(
        userId: user.userId,
        username: user.username,
        email: user.email,
        role: user.role,
        status: UserStatus.active,
        createdAt: user.createdAt,
      );
      await _repository.updateUser(updated);
    }
  }

  @override
  Future<UserManagementReport> generateUserReport(DateTime start, DateTime end) async {
    final users = await _repository.getAllUsers();
    final active = users.where((u) => u.isActive).toList();
    final inactive = users.where((u) => u.status == UserStatus.inactive).toList();
    final suspended = users.where((u) => u.status == UserStatus.suspended).toList();

    return UserManagementReport(
      reportId: 'report_${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      totalUsers: users.length,
      activeUsers: active.length,
      inactiveUsers: inactive.length,
      suspendedUsers: suspended.length,
      usersByRole: {},
      recentlyCreatedUsers: users.where((u) => 
        DateTime.now().difference(u.createdAt).inDays <= 7
      ).toList(),
      inactiveUsersCheckList: inactive,
    );
  }

  @override
  Future<void> recordAuditLog(String userId, String action, String resourceType) async {
    final logId = 'log_${DateTime.now().millisecondsSinceEpoch}';
    final log = AuditLog(
      logId: logId,
      userId: userId,
      action: action,
      resourceType: resourceType,
      timestamp: DateTime.now(),
      ipAddress: '0.0.0.0',
    );
    await _repository.addAuditLog(log);
  }
}

/// ユーザーファサード
class UserFacade {
  final UserManager _manager;
  final UserRepository _repository;
  final AuthorizationEngine _authEngine;
  final SessionEngine _sessionEngine;

  UserFacade(this._manager, this._repository, this._authEngine, this._sessionEngine);

  /// ユーザー作成
  Future<void> createUser(String username, String email, UserRole role) =>
      _manager.createUser(username, email, role);

  /// ロール更新
  Future<void> updateUserRole(String userId, UserRole newRole) =>
      _manager.updateUserRole(userId, newRole);

  /// パーミッション付与
  Future<void> grantPermission(String userId, Permission permission) =>
      _manager.grantPermission(userId, permission);

  /// パーミッション剥奪
  Future<void> revokePermission(String userId, Permission permission) =>
      _manager.revokePermission(userId, permission);

  /// ユーザー停止
  Future<void> suspendUser(String userId) =>
      _manager.suspendUser(userId);

  /// ユーザー復帰
  Future<void> activateUser(String userId) =>
      _manager.activateUser(userId);

  /// パーミッションチェック
  Future<bool> hasPermission(String userId, Permission permission) =>
      _authEngine.hasPermission(userId, permission);

  /// セッション作成
  Future<Session> createSession(String userId, String ipAddress, String userAgent) =>
      _sessionEngine.createSession(userId, ipAddress, userAgent);

  /// セッション検証
  Future<bool> validateSession(String sessionId) =>
      _sessionEngine.validateSession(sessionId);

  /// レポート生成
  Future<UserManagementReport> generateReport(DateTime start, DateTime end) =>
      _manager.generateUserReport(start, end);

  /// ユーザー取得
  Future<User?> getUser(String userId) =>
      _repository.getUser(userId);

  /// 全ユーザー取得
  Future<List<User>> getAllUsers() =>
      _repository.getAllUsers();

  /// アクティブユーザー取得
  Future<List<User>> getActiveUsers() =>
      _repository.getActiveUsers();
}
