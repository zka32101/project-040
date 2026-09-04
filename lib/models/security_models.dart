/// Security & Access Control Models

enum SecurityLevel { public, internal, confidential, restricted, secret }
enum AccessType { read, write, delete, execute, admin, custom }
enum AuthenticationMethod { password, mfa, oauth, saml, certificate, biometric }
enum EncryptionMethod { aes256, rsa2048, tls13, custom, none }
enum PermissionScope { global, organization, project, resource, custom }
enum AuditAction { allow, deny, attempt, revoke, grant, modify }

class SecurityPolicy {
  final String policyId;
  final String policyName;
  final String description;
  final SecurityLevel minSecurityLevel;
  final List<AuthenticationMethod> requiredAuthMethods;
  final int passwordMinLength;
  final int mfaMaxAgeInDays;
  final bool enforceEncryption;
  final DateTime createdAt;
  final bool isActive;

  SecurityPolicy({
    required this.policyId,
    required this.policyName,
    required this.description,
    required this.minSecurityLevel,
    required this.requiredAuthMethods,
    required this.passwordMinLength,
    required this.mfaMaxAgeInDays,
    required this.enforceEncryption,
    required this.createdAt,
    this.isActive = true,
  });

  bool get isMFARequired => requiredAuthMethods.length > 1;
  bool get isStrict => minSecurityLevel == SecurityLevel.restricted || minSecurityLevel == SecurityLevel.secret;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  int get authMethodCount => requiredAuthMethods.length;
}

class Role {
  final String roleId;
  final String roleName;
  final String description;
  final List<String> permissionIds;
  final PermissionScope scope;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final bool isSystem;

  Role({
    required this.roleId,
    required this.roleName,
    required this.description,
    required this.permissionIds,
    required this.scope,
    required this.createdAt,
    this.modifiedAt,
    this.isSystem = false,
  });

  bool get hasPermissions => permissionIds.isNotEmpty;
  int get permissionCount => permissionIds.length;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  bool get isCustom => !isSystem;
}

class Permission {
  final String permissionId;
  final String permissionName;
  final String description;
  final AccessType accessType;
  final String resourceType;
  final PermissionScope scope;
  final DateTime createdAt;
  final bool isDangerous;

  Permission({
    required this.permissionId,
    required this.permissionName,
    required this.description,
    required this.accessType,
    required this.resourceType,
    required this.scope,
    required this.createdAt,
    this.isDangerous = false,
  });

  bool get requiresApproval => isDangerous || accessType == AccessType.admin;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  bool get isAdmin => accessType == AccessType.admin;
  bool get isWrite => accessType == AccessType.write || accessType == AccessType.delete;
}

class User {
  final String userId;
  final String username;
  final String email;
  final List<String> roleIds;
  final SecurityLevel securityLevel;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final DateTime? passwordChangedAt;
  final bool isActive;
  final bool isMFAEnabled;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.roleIds,
    required this.securityLevel,
    required this.createdAt,
    this.lastLoginAt,
    this.passwordChangedAt,
    this.isActive = true,
    this.isMFAEnabled = false,
  });

  bool get hasRoles => roleIds.isNotEmpty;
  bool get hasAdmin => roleIds.contains('admin');
  int get roleCount => roleIds.length;
  int get daysSinceLogin => lastLoginAt != null ? DateTime.now().difference(lastLoginAt!).inDays : -1;
  bool get passwordNeedsChange => passwordChangedAt == null || DateTime.now().difference(passwordChangedAt!).inDays > 90;
}

class AccessControl {
  final String controlId;
  final String userId;
  final String resourceId;
  final String resourceType;
  final List<AccessType> allowedAccess;
  final DateTime grantedAt;
  final DateTime? expiresAt;
  final String? grantedBy;
  final String? reason;

  AccessControl({
    required this.controlId,
    required this.userId,
    required this.resourceId,
    required this.resourceType,
    required this.allowedAccess,
    required this.grantedAt,
    this.expiresAt,
    this.grantedBy,
    this.reason,
  });

  bool get isActive => expiresAt == null || DateTime.now().isBefore(expiresAt!);
  bool get hasExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get canRead => allowedAccess.contains(AccessType.read);
  bool get canWrite => allowedAccess.contains(AccessType.write);
  bool get canDelete => allowedAccess.contains(AccessType.delete);
  bool get isAdmin => allowedAccess.contains(AccessType.admin);
  int get daysUntilExpiry => expiresAt != null ? expiresAt!.difference(DateTime.now()).inDays : -1;
}

class SecretManagement {
  final String secretId;
  final String secretName;
  final String secretType;
  final EncryptionMethod encryptionMethod;
  final DateTime createdAt;
  final DateTime? rotatedAt;
  final int rotationIntervalDays;
  final List<String> accessorIds;
  final bool isActive;

  SecretManagement({
    required this.secretId,
    required this.secretName,
    required this.secretType,
    required this.encryptionMethod,
    required this.createdAt,
    this.rotatedAt,
    required this.rotationIntervalDays,
    required this.accessorIds,
    this.isActive = true,
  });

  bool get needsRotation => rotatedAt == null || DateTime.now().difference(rotatedAt!).inDays > rotationIntervalDays;
  int get daysSinceRotation => rotatedAt != null ? DateTime.now().difference(rotatedAt!).inDays : -1;
  int get accessorCount => accessorIds.length;
  bool get hasAccessors => accessorIds.isNotEmpty;
}

class AuthenticationSession {
  final String sessionId;
  final String userId;
  final AuthenticationMethod authMethod;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String ipAddress;
  final String? userAgent;
  final bool isValid;
  final List<String> mfaMethods;

  AuthenticationSession({
    required this.sessionId,
    required this.userId,
    required this.authMethod,
    required this.createdAt,
    this.expiresAt,
    required this.ipAddress,
    this.userAgent,
    this.isValid = true,
    required this.mfaMethods,
  });

  bool get hasExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isMFAVerified => mfaMethods.isNotEmpty;
  int get ageInSeconds => DateTime.now().difference(createdAt).inSeconds;
  bool get isRecent => ageInSeconds < 3600;
}

class SecurityAuditLog {
  final String auditId;
  final String userId;
  final String action;
  final AuditAction auditAction;
  final String resourceId;
  final String resourceType;
  final DateTime timestamp;
  final bool wasSuccessful;
  final String? failureReason;
  final Map<String, dynamic> details;

  SecurityAuditLog({
    required this.auditId,
    required this.userId,
    required this.action,
    required this.auditAction,
    required this.resourceId,
    required this.resourceType,
    required this.timestamp,
    required this.wasSuccessful,
    this.failureReason,
    required this.details,
  });

  bool get isFailed => !wasSuccessful;
  bool get isDenied => auditAction == AuditAction.deny;
  int get ageInDays => DateTime.now().difference(timestamp).inDays;
  bool get isRecent => DateTime.now().difference(timestamp).inHours < 24;
}

class EncryptionKey {
  final String keyId;
  final String keyName;
  final EncryptionMethod encryptionMethod;
  final DateTime createdAt;
  final DateTime? rotatedAt;
  final int keySizeInBits;
  final bool isActive;
  final List<String> authorizedUsers;

  EncryptionKey({
    required this.keyId,
    required this.keyName,
    required this.encryptionMethod,
    required this.createdAt,
    this.rotatedAt,
    required this.keySizeInBits,
    this.isActive = true,
    required this.authorizedUsers,
  });

  bool get isStrong => keySizeInBits >= 256;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  int get authorizedUserCount => authorizedUsers.length;
  bool get hasAuthorizedUsers => authorizedUsers.isNotEmpty;
}

class PrivilegeEscalation {
  final String escalationId;
  final String userId;
  final String requestedRole;
  final String requestReason;
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final bool isApproved;
  final DateTime? expiresAt;

  PrivilegeEscalation({
    required this.escalationId,
    required this.userId,
    required this.requestedRole,
    required this.requestReason,
    required this.requestedAt,
    this.approvedAt,
    this.approvedBy,
    this.isApproved = false,
    this.expiresAt,
  });

  bool get isPending => !isApproved;
  bool get hasExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  int get ageInDays => DateTime.now().difference(requestedAt).inDays;
  int get daysUntilExpiry => expiresAt != null ? expiresAt!.difference(DateTime.now()).inDays : -1;
}

class SecurityThreat {
  final String threatId;
  final String threatType;
  final String description;
  final double severityScore;
  final DateTime detectedAt;
  final String? detectedBy;
  final DateTime? mitigatedAt;
  final bool isMitigated;
  final String? mitigationActions;

  SecurityThreat({
    required this.threatId,
    required this.threatType,
    required this.description,
    required this.severityScore,
    required this.detectedAt,
    this.detectedBy,
    this.mitigatedAt,
    this.isMitigated = false,
    this.mitigationActions,
  });

  bool get isHighSeverity => severityScore > 0.8;
  bool get isCritical => severityScore > 0.95;
  bool get isPending => !isMitigated;
  int get ageInHours => DateTime.now().difference(detectedAt).inHours;
  bool get isRecent => ageInHours < 24;
}
