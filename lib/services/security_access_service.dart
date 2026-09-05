/// Security & Access Control Service

import 'package:project_040/models/security_models.dart';

abstract class SecurityRepository {
  // User Management (10 methods)
  Future<User> createUser(String username, String email, AccessLevel accessLevel);
  Future<User?> getUser(String userId);
  Future<User> updateUserAccessLevel(String userId, AccessLevel newLevel);
  Future<void> deleteUser(String userId);
  Future<List<User>> listUsers({int limit = 50});
  Future<List<User>> getUsersByAccessLevel(AccessLevel level);
  Future<List<User>> getActiveUsers();
  Future<User> updateUserLastLogin(String userId);
  Future<int> getUserCount();
  Future<List<User>> getUsersByRole(String roleId);

  // Role Management (8 methods)
  Future<Role> createRole(String roleName, String description, AccessLevel level, List<String> permissions);
  Future<Role?> getRole(String roleId);
  Future<Role> updateRolePermissions(String roleId, List<String> permissionIds);
  Future<void> deleteRole(String roleId);
  Future<List<Role>> listRoles({int limit = 50});
  Future<List<Role>> getRolesByAccessLevel(AccessLevel level);
  Future<int> getRoleCount();
  Future<List<Role>> getActiveRoles();

  // Permission Management (8 methods)
  Future<Permission> createPermission(String name, PermissionType type, ResourceType resource, String description);
  Future<Permission?> getPermission(String permissionId);
  Future<Permission> updatePermission(String permissionId, {String? description, Map<String, dynamic>? constraints});
  Future<void> deletePermission(String permissionId);
  Future<List<Permission>> listPermissions({int limit = 50});
  Future<List<Permission>> getPermissionsByType(PermissionType type);
  Future<List<Permission>> getPermissionsByResource(ResourceType resource);
  Future<int> getPermissionCount();

  // Authentication Management (9 methods)
  Future<AuthenticationSession> createSession(String userId, String ipAddress, String userAgent, AuthenticationMethod method);
  Future<AuthenticationSession?> getSession(String sessionId);
  Future<void> invalidateSession(String sessionId);
  Future<void> deleteSession(String sessionId);
  Future<List<AuthenticationSession>> getUserSessions(String userId);
  Future<List<AuthenticationSession>> getActiveSessions();
  Future<int> getSessionCount();
  Future<List<AuthenticationSession>> getExpiredSessions();
  Future<void> cleanupExpiredSessions();

  // Access Control Management (8 methods)
  Future<AccessControl> grantAccess(String userId, ResourceType resource, String resourceId, List<PermissionType> permissions);
  Future<AccessControl?> getAccessControl(String controlId);
  Future<void> revokeAccess(String controlId);
  Future<void> deleteAccessControl(String controlId);
  Future<List<AccessControl>> getUserAccess(String userId);
  Future<List<AccessControl>> getResourceAccess(ResourceType resource, String resourceId);
  Future<int> getAccessControlCount();
  Future<List<AccessControl>> getExpiredAccessControls();

  // Password Policy (6 methods)
  Future<PasswordPolicy> createPasswordPolicy(int minLength, bool uppercase, bool lowercase, bool numbers, bool special, int expiration);
  Future<PasswordPolicy?> getPasswordPolicy(String policyId);
  Future<PasswordPolicy> updatePasswordPolicy(String policyId, {int? minLength, int? expiration});
  Future<void> deletePasswordPolicy(String policyId);
  Future<List<PasswordPolicy>> listPasswordPolicies();
  Future<PasswordPolicy?> getActivePasswordPolicy();

  // Security Audit (7 methods)
  Future<SecurityAudit> recordAudit(String userId, AuditAction action, {ResourceType? resource, String? resourceId, bool successful = true});
  Future<SecurityAudit?> getAudit(String auditId);
  Future<List<SecurityAudit>> getUserAudits(String userId);
  Future<List<SecurityAudit>> getFailedAudits();
  Future<List<SecurityAudit>> listAudits({int limit = 50});
  Future<int> getAuditCount();
  Future<List<SecurityAudit>> getAuditsByAction(AuditAction action);

  // Two-Factor Authentication (6 methods)
  Future<TwoFactorAuth> enableMfa(String userId, String secret);
  Future<TwoFactorAuth?> getMfa(String mfaId);
  Future<void> disableMfa(String mfaId);
  Future<void> deleteMfa(String mfaId);
  Future<List<TwoFactorAuth>> getUserMfa(String userId);
  Future<int> getMfaCount();

  // IP Whitelist (7 methods)
  Future<IPWhitelist> createIPWhitelist(String userId, List<String> ips, List<String> cidrs);
  Future<IPWhitelist?> getIPWhitelist(String whitelistId);
  Future<IPWhitelist> updateIPWhitelist(String whitelistId, List<String> ips, List<String> cidrs);
  Future<void> deleteIPWhitelist(String whitelistId);
  Future<List<IPWhitelist>> getUserIPWhitelists(String userId);
  Future<int> getIPWhitelistCount();
  Future<List<IPWhitelist>> getExpiredIPWhitelists();

  // Security Policy (6 methods)
  Future<SecurityPolicy> createSecurityPolicy(String name, int sessionTimeout, int maxAttempts, int lockoutDuration);
  Future<SecurityPolicy?> getSecurityPolicy(String policyId);
  Future<SecurityPolicy> updateSecurityPolicy(String policyId, {int? sessionTimeout, bool? requireMfa});
  Future<void> deleteSecurityPolicy(String policyId);
  Future<List<SecurityPolicy>> listSecurityPolicies();
  Future<SecurityPolicy?> getActiveSecurityPolicy();
}

class SecurityRepositoryImpl implements SecurityRepository {
  final Map<String, Map<String, dynamic>> _storage = {};

  SecurityRepositoryImpl() {
    _storage['users'] = {};
    _storage['roles'] = {};
    _storage['permissions'] = {};
    _storage['sessions'] = {};
    _storage['access_controls'] = {};
    _storage['password_policies'] = {};
    _storage['audits'] = {};
    _storage['mfa'] = {};
    _storage['ip_whitelist'] = {};
    _storage['security_policies'] = {};
  }

  @override
  Future<User> createUser(String username, String email, AccessLevel accessLevel) async {
    final user = User(
      userId: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      email: email,
      accessLevel: accessLevel,
      roleIds: [],
      createdAt: DateTime.now(),
      isActive: true,
      permissionIds: [],
    );
    _storage['users']![user.userId] = _userToMap(user);
    return user;
  }

  @override
  Future<User?> getUser(String userId) async {
    final data = _storage['users']![userId];
    return data != null ? _mapToUser(data) : null;
  }

  @override
  Future<User> updateUserAccessLevel(String userId, AccessLevel newLevel) async {
    final data = _storage['users']![userId];
    if (data == null) throw Exception('User not found');
    data['accessLevel'] = newLevel.toString().split('.').last;
    return _mapToUser(data);
  }

  @override
  Future<void> deleteUser(String userId) async {
    _storage['users']!.remove(userId);
  }

  @override
  Future<List<User>> listUsers({int limit = 50}) async {
    return _storage['users']!.values.map(_mapToUser).toList().take(limit).toList();
  }

  @override
  Future<List<User>> getUsersByAccessLevel(AccessLevel level) async {
    return _storage['users']!.values
        .where((u) => u['accessLevel'] == level.toString().split('.').last)
        .map(_mapToUser)
        .toList();
  }

  @override
  Future<List<User>> getActiveUsers() async {
    return _storage['users']!.values
        .where((u) => u['isActive'] == true)
        .map(_mapToUser)
        .toList();
  }

  @override
  Future<User> updateUserLastLogin(String userId) async {
    final data = _storage['users']![userId];
    if (data == null) throw Exception('User not found');
    data['lastLoginAt'] = DateTime.now().toIso8601String();
    return _mapToUser(data);
  }

  @override
  Future<int> getUserCount() async => _storage['users']!.length;

  @override
  Future<List<User>> getUsersByRole(String roleId) async {
    return _storage['users']!.values
        .where((u) => (u['roleIds'] as List).contains(roleId))
        .map(_mapToUser)
        .toList();
  }

  @override
  Future<Role> createRole(String roleName, String description, AccessLevel level, List<String> permissions) async {
    final role = Role(
      roleId: 'role_${DateTime.now().millisecondsSinceEpoch}',
      roleName: roleName,
      description: description,
      accessLevel: level,
      permissionIds: permissions,
      createdAt: DateTime.now(),
      status: RoleStatus.active,
    );
    _storage['roles']![role.roleId] = _roleToMap(role);
    return role;
  }

  @override
  Future<Role?> getRole(String roleId) async {
    final data = _storage['roles']![roleId];
    return data != null ? _mapToRole(data) : null;
  }

  @override
  Future<Role> updateRolePermissions(String roleId, List<String> permissionIds) async {
    final data = _storage['roles']![roleId];
    if (data == null) throw Exception('Role not found');
    data['permissionIds'] = permissionIds;
    return _mapToRole(data);
  }

  @override
  Future<void> deleteRole(String roleId) async {
    _storage['roles']!.remove(roleId);
  }

  @override
  Future<List<Role>> listRoles({int limit = 50}) async {
    return _storage['roles']!.values.map(_mapToRole).toList().take(limit).toList();
  }

  @override
  Future<List<Role>> getRolesByAccessLevel(AccessLevel level) async {
    return _storage['roles']!.values
        .where((r) => r['accessLevel'] == level.toString().split('.').last)
        .map(_mapToRole)
        .toList();
  }

  @override
  Future<int> getRoleCount() async => _storage['roles']!.length;

  @override
  Future<List<Role>> getActiveRoles() async {
    return _storage['roles']!.values
        .where((r) => r['status'] == 'active')
        .map(_mapToRole)
        .toList();
  }

  @override
  Future<Permission> createPermission(String name, PermissionType type, ResourceType resource, String description) async {
    final permission = Permission(
      permissionId: 'perm_${DateTime.now().millisecondsSinceEpoch}',
      permissionName: name,
      type: type,
      resource: resource,
      description: description,
      createdAt: DateTime.now(),
      constraints: {},
    );
    _storage['permissions']![permission.permissionId] = _permissionToMap(permission);
    return permission;
  }

  @override
  Future<Permission?> getPermission(String permissionId) async {
    final data = _storage['permissions']![permissionId];
    return data != null ? _mapToPermission(data) : null;
  }

  @override
  Future<Permission> updatePermission(String permissionId, {String? description, Map<String, dynamic>? constraints}) async {
    final data = _storage['permissions']![permissionId];
    if (data == null) throw Exception('Permission not found');
    if (description != null) data['description'] = description;
    if (constraints != null) data['constraints'] = constraints;
    return _mapToPermission(data);
  }

  @override
  Future<void> deletePermission(String permissionId) async {
    _storage['permissions']!.remove(permissionId);
  }

  @override
  Future<List<Permission>> listPermissions({int limit = 50}) async {
    return _storage['permissions']!.values.map(_mapToPermission).toList().take(limit).toList();
  }

  @override
  Future<List<Permission>> getPermissionsByType(PermissionType type) async {
    return _storage['permissions']!.values
        .where((p) => p['type'] == type.toString().split('.').last)
        .map(_mapToPermission)
        .toList();
  }

  @override
  Future<List<Permission>> getPermissionsByResource(ResourceType resource) async {
    return _storage['permissions']!.values
        .where((p) => p['resource'] == resource.toString().split('.').last)
        .map(_mapToPermission)
        .toList();
  }

  @override
  Future<int> getPermissionCount() async => _storage['permissions']!.length;

  @override
  Future<AuthenticationSession> createSession(String userId, String ipAddress, String userAgent, AuthenticationMethod method) async {
    final session = AuthenticationSession(
      sessionId: 'sess_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(hours: 8)),
      ipAddress: ipAddress,
      userAgent: userAgent,
      method: method,
      mfaFactors: [],
    );
    _storage['sessions']![session.sessionId] = _sessionToMap(session);
    return session;
  }

  @override
  Future<AuthenticationSession?> getSession(String sessionId) async {
    final data = _storage['sessions']![sessionId];
    return data != null ? _mapToSession(data) : null;
  }

  @override
  Future<void> invalidateSession(String sessionId) async {
    final data = _storage['sessions']![sessionId];
    if (data != null) data['isValid'] = false;
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _storage['sessions']!.remove(sessionId);
  }

  @override
  Future<List<AuthenticationSession>> getUserSessions(String userId) async {
    return _storage['sessions']!.values
        .where((s) => s['userId'] == userId)
        .map(_mapToSession)
        .toList();
  }

  @override
  Future<List<AuthenticationSession>> getActiveSessions() async {
    return _storage['sessions']!.values
        .where((s) => s['isValid'] == true && s['expiresAt'] != null && DateTime.parse(s['expiresAt']).isAfter(DateTime.now()))
        .map(_mapToSession)
        .toList();
  }

  @override
  Future<int> getSessionCount() async => _storage['sessions']!.length;

  @override
  Future<List<AuthenticationSession>> getExpiredSessions() async {
    return _storage['sessions']!.values
        .where((s) => s['expiresAt'] != null && DateTime.parse(s['expiresAt']).isBefore(DateTime.now()))
        .map(_mapToSession)
        .toList();
  }

  @override
  Future<void> cleanupExpiredSessions() async {
    final expired = await getExpiredSessions();
    for (final session in expired) {
      await deleteSession(session.sessionId);
    }
  }

  @override
  Future<AccessControl> grantAccess(String userId, ResourceType resource, String resourceId, List<PermissionType> permissions) async {
    final control = AccessControl(
      controlId: 'ctrl_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      resource: resource,
      resourceId: resourceId,
      grantedPermissions: permissions,
      grantedAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: 365)),
    );
    _storage['access_controls']![control.controlId] = _accessControlToMap(control);
    return control;
  }

  @override
  Future<AccessControl?> getAccessControl(String controlId) async {
    final data = _storage['access_controls']![controlId];
    return data != null ? _mapToAccessControl(data) : null;
  }

  @override
  Future<void> revokeAccess(String controlId) async {
    final data = _storage['access_controls']![controlId];
    if (data != null) data['expiresAt'] = DateTime.now().toIso8601String();
  }

  @override
  Future<void> deleteAccessControl(String controlId) async {
    _storage['access_controls']!.remove(controlId);
  }

  @override
  Future<List<AccessControl>> getUserAccess(String userId) async {
    return _storage['access_controls']!.values
        .where((a) => a['userId'] == userId)
        .map(_mapToAccessControl)
        .toList();
  }

  @override
  Future<List<AccessControl>> getResourceAccess(ResourceType resource, String resourceId) async {
    return _storage['access_controls']!.values
        .where((a) => a['resource'] == resource.toString().split('.').last && a['resourceId'] == resourceId)
        .map(_mapToAccessControl)
        .toList();
  }

  @override
  Future<int> getAccessControlCount() async => _storage['access_controls']!.length;

  @override
  Future<List<AccessControl>> getExpiredAccessControls() async {
    return _storage['access_controls']!.values
        .where((a) => a['expiresAt'] != null && DateTime.parse(a['expiresAt']).isBefore(DateTime.now()))
        .map(_mapToAccessControl)
        .toList();
  }

  @override
  Future<PasswordPolicy> createPasswordPolicy(int minLength, bool uppercase, bool lowercase, bool numbers, bool special, int expiration) async {
    final policy = PasswordPolicy(
      policyId: 'pol_${DateTime.now().millisecondsSinceEpoch}',
      minLength: minLength,
      requireUppercase: uppercase,
      requireLowercase: lowercase,
      requireNumbers: numbers,
      requireSpecialChars: special,
      expirationDays: expiration,
      historyCount: 5,
      createdAt: DateTime.now(),
    );
    _storage['password_policies']![policy.policyId] = _policyToMap(policy);
    return policy;
  }

  @override
  Future<PasswordPolicy?> getPasswordPolicy(String policyId) async {
    final data = _storage['password_policies']![policyId];
    return data != null ? _mapToPolicy(data) : null;
  }

  @override
  Future<PasswordPolicy> updatePasswordPolicy(String policyId, {int? minLength, int? expiration}) async {
    final data = _storage['password_policies']![policyId];
    if (data == null) throw Exception('Policy not found');
    if (minLength != null) data['minLength'] = minLength;
    if (expiration != null) data['expirationDays'] = expiration;
    return _mapToPolicy(data);
  }

  @override
  Future<void> deletePasswordPolicy(String policyId) async {
    _storage['password_policies']!.remove(policyId);
  }

  @override
  Future<List<PasswordPolicy>> listPasswordPolicies() async {
    return _storage['password_policies']!.values.map(_mapToPolicy).toList();
  }

  @override
  Future<PasswordPolicy?> getActivePasswordPolicy() async {
    final policies = _storage['password_policies']!.values
        .where((p) => p['isActive'] == true)
        .toList();
    return policies.isNotEmpty ? _mapToPolicy(policies.first) : null;
  }

  @override
  Future<SecurityAudit> recordAudit(String userId, AuditAction action, {ResourceType? resource, String? resourceId, bool successful = true}) async {
    final audit = SecurityAudit(
      auditId: 'aud_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      action: action,
      resourceType: resource,
      resourceId: resourceId,
      timestamp: DateTime.now(),
      isSuccessful: successful,
      details: {},
    );
    _storage['audits']![audit.auditId] = _auditToMap(audit);
    return audit;
  }

  @override
  Future<SecurityAudit?> getAudit(String auditId) async {
    final data = _storage['audits']![auditId];
    return data != null ? _mapToAudit(data) : null;
  }

  @override
  Future<List<SecurityAudit>> getUserAudits(String userId) async {
    return _storage['audits']!.values
        .where((a) => a['userId'] == userId)
        .map(_mapToAudit)
        .toList();
  }

  @override
  Future<List<SecurityAudit>> getFailedAudits() async {
    return _storage['audits']!.values
        .where((a) => a['isSuccessful'] == false)
        .map(_mapToAudit)
        .toList();
  }

  @override
  Future<List<SecurityAudit>> listAudits({int limit = 50}) async {
    return _storage['audits']!.values.map(_mapToAudit).toList().take(limit).toList();
  }

  @override
  Future<int> getAuditCount() async => _storage['audits']!.length;

  @override
  Future<List<SecurityAudit>> getAuditsByAction(AuditAction action) async {
    return _storage['audits']!.values
        .where((a) => a['action'] == action.toString().split('.').last)
        .map(_mapToAudit)
        .toList();
  }

  @override
  Future<TwoFactorAuth> enableMfa(String userId, String secret) async {
    final mfa = TwoFactorAuth(
      mfaId: 'mfa_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      secret: secret,
      enabledAt: DateTime.now(),
      backupCodes: List.generate(10, (i) => 'code_${DateTime.now().millisecondsSinceEpoch}_$i'),
    );
    _storage['mfa']![mfa.mfaId] = _mfaToMap(mfa);
    return mfa;
  }

  @override
  Future<TwoFactorAuth?> getMfa(String mfaId) async {
    final data = _storage['mfa']![mfaId];
    return data != null ? _mapToMfa(data) : null;
  }

  @override
  Future<void> disableMfa(String mfaId) async {
    final data = _storage['mfa']![mfaId];
    if (data != null) {
      data['isActive'] = false;
      data['disabledAt'] = DateTime.now().toIso8601String();
    }
  }

  @override
  Future<void> deleteMfa(String mfaId) async {
    _storage['mfa']!.remove(mfaId);
  }

  @override
  Future<List<TwoFactorAuth>> getUserMfa(String userId) async {
    return _storage['mfa']!.values
        .where((m) => m['userId'] == userId)
        .map(_mapToMfa)
        .toList();
  }

  @override
  Future<int> getMfaCount() async => _storage['mfa']!.length;

  @override
  Future<IPWhitelist> createIPWhitelist(String userId, List<String> ips, List<String> cidrs) async {
    final whitelist = IPWhitelist(
      whitelistId: 'ipw_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      ipAddresses: ips,
      cidrRanges: cidrs,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: 365)),
    );
    _storage['ip_whitelist']![whitelist.whitelistId] = _ipWhitelistToMap(whitelist);
    return whitelist;
  }

  @override
  Future<IPWhitelist?> getIPWhitelist(String whitelistId) async {
    final data = _storage['ip_whitelist']![whitelistId];
    return data != null ? _mapToIPWhitelist(data) : null;
  }

  @override
  Future<IPWhitelist> updateIPWhitelist(String whitelistId, List<String> ips, List<String> cidrs) async {
    final data = _storage['ip_whitelist']![whitelistId];
    if (data == null) throw Exception('Whitelist not found');
    data['ipAddresses'] = ips;
    data['cidrRanges'] = cidrs;
    return _mapToIPWhitelist(data);
  }

  @override
  Future<void> deleteIPWhitelist(String whitelistId) async {
    _storage['ip_whitelist']!.remove(whitelistId);
  }

  @override
  Future<List<IPWhitelist>> getUserIPWhitelists(String userId) async {
    return _storage['ip_whitelist']!.values
        .where((w) => w['userId'] == userId)
        .map(_mapToIPWhitelist)
        .toList();
  }

  @override
  Future<int> getIPWhitelistCount() async => _storage['ip_whitelist']!.length;

  @override
  Future<List<IPWhitelist>> getExpiredIPWhitelists() async {
    return _storage['ip_whitelist']!.values
        .where((w) => w['expiresAt'] != null && DateTime.parse(w['expiresAt']).isBefore(DateTime.now()))
        .map(_mapToIPWhitelist)
        .toList();
  }

  @override
  Future<SecurityPolicy> createSecurityPolicy(String name, int sessionTimeout, int maxAttempts, int lockoutDuration) async {
    final policy = SecurityPolicy(
      policyId: 'sec_${DateTime.now().millisecondsSinceEpoch}',
      policyName: name,
      sessionTimeoutMinutes: sessionTimeout,
      maxLoginAttempts: maxAttempts,
      lockoutDurationMinutes: lockoutDuration,
      requireMfa: false,
      enforceIpWhitelist: false,
      createdAt: DateTime.now(),
      settings: {},
    );
    _storage['security_policies']![policy.policyId] = _securityPolicyToMap(policy);
    return policy;
  }

  @override
  Future<SecurityPolicy?> getSecurityPolicy(String policyId) async {
    final data = _storage['security_policies']![policyId];
    return data != null ? _mapToSecurityPolicy(data) : null;
  }

  @override
  Future<SecurityPolicy> updateSecurityPolicy(String policyId, {int? sessionTimeout, bool? requireMfa}) async {
    final data = _storage['security_policies']![policyId];
    if (data == null) throw Exception('Policy not found');
    if (sessionTimeout != null) data['sessionTimeoutMinutes'] = sessionTimeout;
    if (requireMfa != null) data['requireMfa'] = requireMfa;
    return _mapToSecurityPolicy(data);
  }

  @override
  Future<void> deleteSecurityPolicy(String policyId) async {
    _storage['security_policies']!.remove(policyId);
  }

  @override
  Future<List<SecurityPolicy>> listSecurityPolicies() async {
    return _storage['security_policies']!.values.map(_mapToSecurityPolicy).toList();
  }

  @override
  Future<SecurityPolicy?> getActiveSecurityPolicy() async {
    final policies = _storage['security_policies']!.values
        .where((p) => p['isActive'] == true)
        .toList();
    return policies.isNotEmpty ? _mapToSecurityPolicy(policies.first) : null;
  }

  // Helper methods
  Map<String, dynamic> _userToMap(User u) => {
    'userId': u.userId,
    'username': u.username,
    'email': u.email,
    'accessLevel': u.accessLevel.toString().split('.').last,
    'roleIds': u.roleIds,
    'createdAt': u.createdAt.toIso8601String(),
    'lastLoginAt': u.lastLoginAt?.toIso8601String(),
    'isActive': u.isActive,
    'department': u.department,
    'permissionIds': u.permissionIds,
  };

  User _mapToUser(Map<String, dynamic> m) => User(
    userId: m['userId'],
    username: m['username'],
    email: m['email'],
    accessLevel: AccessLevel.values.byName(m['accessLevel']),
    roleIds: List<String>.from(m['roleIds'] ?? []),
    createdAt: DateTime.parse(m['createdAt']),
    lastLoginAt: m['lastLoginAt'] != null ? DateTime.parse(m['lastLoginAt']) : null,
    isActive: m['isActive'] ?? true,
    department: m['department'],
    permissionIds: List<String>.from(m['permissionIds'] ?? []),
  );

  Map<String, dynamic> _roleToMap(Role r) => {
    'roleId': r.roleId,
    'roleName': r.roleName,
    'description': r.description,
    'accessLevel': r.accessLevel.toString().split('.').last,
    'permissionIds': r.permissionIds,
    'createdAt': r.createdAt.toIso8601String(),
    'status': r.status.toString().split('.').last,
    'isDynamic': r.isDynamic,
  };

  Role _mapToRole(Map<String, dynamic> m) => Role(
    roleId: m['roleId'],
    roleName: m['roleName'],
    description: m['description'],
    accessLevel: AccessLevel.values.byName(m['accessLevel']),
    permissionIds: List<String>.from(m['permissionIds'] ?? []),
    createdAt: DateTime.parse(m['createdAt']),
    status: RoleStatus.values.byName(m['status']),
    isDynamic: m['isDynamic'] ?? false,
  );

  Map<String, dynamic> _permissionToMap(Permission p) => {
    'permissionId': p.permissionId,
    'permissionName': p.permissionName,
    'type': p.type.toString().split('.').last,
    'resource': p.resource.toString().split('.').last,
    'description': p.description,
    'createdAt': p.createdAt.toIso8601String(),
    'isGlobal': p.isGlobal,
    'constraints': p.constraints,
  };

  Permission _mapToPermission(Map<String, dynamic> m) => Permission(
    permissionId: m['permissionId'],
    permissionName: m['permissionName'],
    type: PermissionType.values.byName(m['type']),
    resource: ResourceType.values.byName(m['resource']),
    description: m['description'],
    createdAt: DateTime.parse(m['createdAt']),
    isGlobal: m['isGlobal'] ?? false,
    constraints: m['constraints'] ?? {},
  );

  Map<String, dynamic> _sessionToMap(AuthenticationSession s) => {
    'sessionId': s.sessionId,
    'userId': s.userId,
    'createdAt': s.createdAt.toIso8601String(),
    'expiresAt': s.expiresAt?.toIso8601String(),
    'ipAddress': s.ipAddress,
    'userAgent': s.userAgent,
    'method': s.method.toString().split('.').last,
    'isValid': s.isValid,
    'mfaFactors': s.mfaFactors,
  };

  AuthenticationSession _mapToSession(Map<String, dynamic> m) => AuthenticationSession(
    sessionId: m['sessionId'],
    userId: m['userId'],
    createdAt: DateTime.parse(m['createdAt']),
    expiresAt: m['expiresAt'] != null ? DateTime.parse(m['expiresAt']) : null,
    ipAddress: m['ipAddress'],
    userAgent: m['userAgent'],
    method: AuthenticationMethod.values.byName(m['method']),
    isValid: m['isValid'] ?? true,
    mfaFactors: List<String>.from(m['mfaFactors'] ?? []),
  );

  Map<String, dynamic> _accessControlToMap(AccessControl a) => {
    'controlId': a.controlId,
    'userId': a.userId,
    'resource': a.resource.toString().split('.').last,
    'resourceId': a.resourceId,
    'grantedPermissions': a.grantedPermissions.map((p) => p.toString().split('.').last).toList(),
    'grantedAt': a.grantedAt.toIso8601String(),
    'expiresAt': a.expiresAt?.toIso8601String(),
    'grantedBy': a.grantedBy,
    'reason': a.reason,
  };

  AccessControl _mapToAccessControl(Map<String, dynamic> m) => AccessControl(
    controlId: m['controlId'],
    userId: m['userId'],
    resource: ResourceType.values.byName(m['resource']),
    resourceId: m['resourceId'],
    grantedPermissions: (m['grantedPermissions'] as List).map((p) => PermissionType.values.byName(p)).toList(),
    grantedAt: DateTime.parse(m['grantedAt']),
    expiresAt: m['expiresAt'] != null ? DateTime.parse(m['expiresAt']) : null,
    grantedBy: m['grantedBy'],
    reason: m['reason'],
  );

  Map<String, dynamic> _policyToMap(PasswordPolicy p) => {
    'policyId': p.policyId,
    'minLength': p.minLength,
    'requireUppercase': p.requireUppercase,
    'requireLowercase': p.requireLowercase,
    'requireNumbers': p.requireNumbers,
    'requireSpecialChars': p.requireSpecialChars,
    'expirationDays': p.expirationDays,
    'historyCount': p.historyCount,
    'createdAt': p.createdAt.toIso8601String(),
    'isActive': p.isActive,
  };

  PasswordPolicy _mapToPolicy(Map<String, dynamic> m) => PasswordPolicy(
    policyId: m['policyId'],
    minLength: m['minLength'],
    requireUppercase: m['requireUppercase'],
    requireLowercase: m['requireLowercase'],
    requireNumbers: m['requireNumbers'],
    requireSpecialChars: m['requireSpecialChars'],
    expirationDays: m['expirationDays'],
    historyCount: m['historyCount'],
    createdAt: DateTime.parse(m['createdAt']),
    isActive: m['isActive'] ?? true,
  );

  Map<String, dynamic> _auditToMap(SecurityAudit a) => {
    'auditId': a.auditId,
    'userId': a.userId,
    'action': a.action.toString().split('.').last,
    'resourceType': a.resourceType?.toString().split('.').last,
    'resourceId': a.resourceId,
    'timestamp': a.timestamp.toIso8601String(),
    'ipAddress': a.ipAddress,
    'isSuccessful': a.isSuccessful,
    'failureReason': a.failureReason,
    'details': a.details,
  };

  SecurityAudit _mapToAudit(Map<String, dynamic> m) => SecurityAudit(
    auditId: m['auditId'],
    userId: m['userId'],
    action: AuditAction.values.byName(m['action']),
    resourceType: m['resourceType'] != null ? ResourceType.values.byName(m['resourceType']) : null,
    resourceId: m['resourceId'],
    timestamp: DateTime.parse(m['timestamp']),
    ipAddress: m['ipAddress'],
    isSuccessful: m['isSuccessful'] ?? true,
    failureReason: m['failureReason'],
    details: m['details'] ?? {},
  );

  Map<String, dynamic> _mfaToMap(TwoFactorAuth m) => {
    'mfaId': m.mfaId,
    'userId': m.userId,
    'secret': m.secret,
    'enabledAt': m.enabledAt.toIso8601String(),
    'disabledAt': m.disabledAt?.toIso8601String(),
    'backupCodes': m.backupCodes,
    'isActive': m.isActive,
  };

  TwoFactorAuth _mapToMfa(Map<String, dynamic> m) => TwoFactorAuth(
    mfaId: m['mfaId'],
    userId: m['userId'],
    secret: m['secret'],
    enabledAt: DateTime.parse(m['enabledAt']),
    disabledAt: m['disabledAt'] != null ? DateTime.parse(m['disabledAt']) : null,
    backupCodes: List<String>.from(m['backupCodes'] ?? []),
    isActive: m['isActive'] ?? true,
  );

  Map<String, dynamic> _ipWhitelistToMap(IPWhitelist i) => {
    'whitelistId': i.whitelistId,
    'userId': i.userId,
    'ipAddresses': i.ipAddresses,
    'cidrRanges': i.cidrRanges,
    'createdAt': i.createdAt.toIso8601String(),
    'expiresAt': i.expiresAt?.toIso8601String(),
    'isActive': i.isActive,
    'description': i.description,
  };

  IPWhitelist _mapToIPWhitelist(Map<String, dynamic> m) => IPWhitelist(
    whitelistId: m['whitelistId'],
    userId: m['userId'],
    ipAddresses: List<String>.from(m['ipAddresses'] ?? []),
    cidrRanges: List<String>.from(m['cidrRanges'] ?? []),
    createdAt: DateTime.parse(m['createdAt']),
    expiresAt: m['expiresAt'] != null ? DateTime.parse(m['expiresAt']) : null,
    isActive: m['isActive'] ?? true,
    description: m['description'],
  );

  Map<String, dynamic> _securityPolicyToMap(SecurityPolicy s) => {
    'policyId': s.policyId,
    'policyName': s.policyName,
    'sessionTimeoutMinutes': s.sessionTimeoutMinutes,
    'maxLoginAttempts': s.maxLoginAttempts,
    'lockoutDurationMinutes': s.lockoutDurationMinutes,
    'requireMfa': s.requireMfa,
    'enforceIpWhitelist': s.enforceIpWhitelist,
    'createdAt': s.createdAt.toIso8601String(),
    'isActive': s.isActive,
    'settings': s.settings,
  };

  SecurityPolicy _mapToSecurityPolicy(Map<String, dynamic> m) => SecurityPolicy(
    policyId: m['policyId'],
    policyName: m['policyName'],
    sessionTimeoutMinutes: m['sessionTimeoutMinutes'],
    maxLoginAttempts: m['maxLoginAttempts'],
    lockoutDurationMinutes: m['lockoutDurationMinutes'],
    requireMfa: m['requireMfa'] ?? false,
    enforceIpWhitelist: m['enforceIpWhitelist'] ?? false,
    createdAt: DateTime.parse(m['createdAt']),
    isActive: m['isActive'] ?? true,
    settings: m['settings'] ?? {},
  );
}

// Engines
class AuthenticationEngine {
  Future<bool> validateCredentials(String username, String password) async => true;
}

class AuthorizationEngine {
  Future<bool> hasPermission(String userId, PermissionType permission, ResourceType resource) async => true;
}

class RoleManagementEngine {
  Future<List<Permission>> getEffectivePermissions(String userId) async => [];
}

class SessionManagementEngine {
  Future<void> enforceSessionPolicy(String sessionId) async {}
}

class ComplianceEngine {
  Future<bool> verifyCompliance(String userId, String action) async => true;
}

class SecurityManager {
  final SecurityRepository repository;
  final AuthenticationEngine authEngine;
  final AuthorizationEngine authzEngine;
  final RoleManagementEngine roleEngine;
  final SessionManagementEngine sessionEngine;
  final ComplianceEngine complianceEngine;

  SecurityManager({
    required this.repository,
    required this.authEngine,
    required this.authzEngine,
    required this.roleEngine,
    required this.sessionEngine,
    required this.complianceEngine,
  });
}

class SecurityFacade {
  final SecurityRepository repository;
  final SecurityManager manager;

  SecurityFacade({required this.repository, required this.manager});

  Future<User?> getUser(String userId) => repository.getUser(userId);
  Future<List<User>> getActiveUsers() => repository.getActiveUsers();
  Future<List<Role>> listRoles() => repository.listRoles();
  Future<int> getUserCount() => repository.getUserCount();
}
