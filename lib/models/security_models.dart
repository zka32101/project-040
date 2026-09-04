/// Security & Access Control Models

enum AuthenticationMethod { basic, oauth2, jwt, apiKey, mfa, saml, ldap }
enum AccessLevel { admin, supervisor, operator, viewer, restricted, guest }
enum PermissionType { read, write, delete, execute, manage, override }
enum ResourceType { job, deployment, config, incident, analytics, audit }
enum RoleStatus { active, suspended, archived, pending, expired }
enum AuditAction { create, read, update, delete, login, logout, export, configuration }

class User {
  final String userId;
  final String username;
  final String email;
  final AccessLevel accessLevel;
  final List<String> roleIds;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final String? department;
  final List<String> permissionIds;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.accessLevel,
    required this.roleIds,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.department,
    required this.permissionIds,
  });

  bool get isAdmin => accessLevel == AccessLevel.admin;
  bool get canManage => accessLevel == AccessLevel.admin || accessLevel == AccessLevel.supervisor;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  int get roleCount => roleIds.length;
}

class Role {
  final String roleId;
  final String roleName;
  final String description;
  final AccessLevel accessLevel;
  final List<String> permissionIds;
  final DateTime createdAt;
  final RoleStatus status;
  final bool isDynamic;

  Role({
    required this.roleId,
    required this.roleName,
    required this.description,
    required this.accessLevel,
    required this.permissionIds,
    required this.createdAt,
    required this.status,
    this.isDynamic = false,
  });

  bool get isActive => status == RoleStatus.active;
  int get permissionCount => permissionIds.length;
}

class Permission {
  final String permissionId;
  final String permissionName;
  final PermissionType type;
  final ResourceType resource;
  final String description;
  final DateTime createdAt;
  final bool isGlobal;
  final Map<String, dynamic> constraints;

  Permission({
    required this.permissionId,
    required this.permissionName,
    required this.type,
    required this.resource,
    required this.description,
    required this.createdAt,
    this.isGlobal = false,
    required this.constraints,
  });

  bool get hasConstraints => constraints.isNotEmpty;
  int get constraintCount => constraints.length;
}

class AuthenticationSession {
  final String sessionId;
  final String userId;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String ipAddress;
  final String userAgent;
  final AuthenticationMethod method;
  final bool isValid;
  final List<String> mfaFactors;

  AuthenticationSession({
    required this.sessionId,
    required this.userId,
    required this.createdAt,
    this.expiresAt,
    required this.ipAddress,
    required this.userAgent,
    required this.method,
    this.isValid = true,
    required this.mfaFactors,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isActive => isValid && !isExpired;
  int get ageInMinutes => DateTime.now().difference(createdAt).inMinutes;
}

class AccessControl {
  final String controlId;
  final String userId;
  final ResourceType resource;
  final String resourceId;
  final List<PermissionType> grantedPermissions;
  final DateTime grantedAt;
  final DateTime? expiresAt;
  final String? grantedBy;
  final String? reason;

  AccessControl({
    required this.controlId,
    required this.userId,
    required this.resource,
    required this.resourceId,
    required this.grantedPermissions,
    required this.grantedAt,
    this.expiresAt,
    this.grantedBy,
    this.reason,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isActive => !isExpired;
  bool get canRead => grantedPermissions.contains(PermissionType.read);
  bool get canWrite => grantedPermissions.contains(PermissionType.write);
  int get permissionCount => grantedPermissions.length;
}

class PasswordPolicy {
  final String policyId;
  final int minLength;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireNumbers;
  final bool requireSpecialChars;
  final int expirationDays;
  final int historyCount;
  final DateTime createdAt;
  final bool isActive;

  PasswordPolicy({
    required this.policyId,
    required this.minLength,
    required this.requireUppercase,
    required this.requireLowercase,
    required this.requireNumbers,
    required this.requireSpecialChars,
    required this.expirationDays,
    required this.historyCount,
    required this.createdAt,
    this.isActive = true,
  });

  int get complexityScore {
    int score = 0;
    if (requireUppercase) score++;
    if (requireLowercase) score++;
    if (requireNumbers) score++;
    if (requireSpecialChars) score++;
    return score;
  }
}

class SecurityAudit {
  final String auditId;
  final String userId;
  final AuditAction action;
  final ResourceType? resourceType;
  final String? resourceId;
  final DateTime timestamp;
  final String? ipAddress;
  final bool isSuccessful;
  final String? failureReason;
  final Map<String, dynamic> details;

  SecurityAudit({
    required this.auditId,
    required this.userId,
    required this.action,
    this.resourceType,
    this.resourceId,
    required this.timestamp,
    this.ipAddress,
    this.isSuccessful = true,
    this.failureReason,
    required this.details,
  });

  bool get isFailed => !isSuccessful;
  int get ageInMinutes => DateTime.now().difference(timestamp).inMinutes;
}

class TwoFactorAuth {
  final String mfaId;
  final String userId;
  final String secret;
  final DateTime enabledAt;
  final DateTime? disabledAt;
  final List<String> backupCodes;
  final bool isActive;

  TwoFactorAuth({
    required this.mfaId,
    required this.userId,
    required this.secret,
    required this.enabledAt,
    this.disabledAt,
    required this.backupCodes,
    this.isActive = true,
  });

  bool get hasBackupCodes => backupCodes.isNotEmpty;
  int get backupCodeCount => backupCodes.length;
  int get ageInDays => DateTime.now().difference(enabledAt).inDays;
}

class IPWhitelist {
  final String whitelistId;
  final String userId;
  final List<String> ipAddresses;
  final List<String> cidrRanges;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;
  final String? description;

  IPWhitelist({
    required this.whitelistId,
    required this.userId,
    required this.ipAddresses,
    required this.cidrRanges,
    required this.createdAt,
    this.expiresAt,
    this.isActive = true,
    this.description,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  int get totalRanges => ipAddresses.length + cidrRanges.length;
}

class SecurityPolicy {
  final String policyId;
  final String policyName;
  final int sessionTimeoutMinutes;
  final int maxLoginAttempts;
  final int lockoutDurationMinutes;
  final bool requireMfa;
  final bool enforceIpWhitelist;
  final DateTime createdAt;
  final bool isActive;
  final Map<String, dynamic> settings;

  SecurityPolicy({
    required this.policyId,
    required this.policyName,
    required this.sessionTimeoutMinutes,
    required this.maxLoginAttempts,
    required this.lockoutDurationMinutes,
    required this.requireMfa,
    required this.enforceIpWhitelist,
    required this.createdAt,
    this.isActive = true,
    required this.settings,
  });

  bool get isMfaRequired => requireMfa;
  bool get isIpEnforced => enforceIpWhitelist;
}
