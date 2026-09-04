/// Phase 57: User Management & Authorization ユーザー管理・認可

/// ユーザーロール
enum UserRole {
  admin('admin'),
  manager('manager'),
  operator('operator'),
  viewer('viewer'),
  guest('guest');

  final String value;
  const UserRole(this.value);
}

/// パーミッション
enum Permission {
  createJob('create:job'),
  readJob('read:job'),
  updateJob('update:job'),
  deleteJob('delete:job'),
  viewReports('view:reports'),
  exportData('export:data'),
  manageUsers('manage:users'),
  manageRoles('manage:roles'),
  viewAudit('view:audit'),
  configureSystem('configure:system');

  final String value;
  const Permission(this.value);
}

/// ユーザーステータス
enum UserStatus {
  active('active'),
  inactive('inactive'),
  suspended('suspended'),
  pending('pending'),
  deleted('deleted');

  final String value;
  const UserStatus(this.value);
}

/// ユーザーアカウント
class User {
  final String userId;
  final String username;
  final String email;
  final String? displayName;
  final UserRole role;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final DateTime? lastPasswordChangeAt;
  final bool isMfaEnabled;
  final String? phoneNumber;
  final Map<String, dynamic>? metadata;

  User({
    required this.userId,
    required this.username,
    required this.email,
    this.displayName,
    required this.role,
    this.status = UserStatus.active,
    required this.createdAt,
    this.lastLoginAt,
    this.lastPasswordChangeAt,
    this.isMfaEnabled = false,
    this.phoneNumber,
    this.metadata,
  });

  /// ユーザーが有効か
  bool get isActive => status == UserStatus.active;

  /// ユーザーが管理者か
  bool get isAdmin => role == UserRole.admin;

  /// パスワード変更が必要か（90日以上変更されていない）
  bool get needsPasswordChange {
    if (lastPasswordChangeAt == null) return true;
    return DateTime.now().difference(lastPasswordChangeAt!).inDays > 90;
  }

  /// ログイン履歴がある か
  bool get hasLoginHistory => lastLoginAt != null;

  /// アカウント年齢（日数）
  int get accountAgeInDays => DateTime.now().difference(createdAt).inDays;
}

/// ロール定義
class Role {
  final String roleId;
  final String roleName;
  final String description;
  final List<Permission> permissions;
  final DateTime createdAt;
  final bool isCustom;
  final bool isActive;

  Role({
    required this.roleId,
    required this.roleName,
    required this.description,
    required this.permissions,
    required this.createdAt,
    this.isCustom = false,
    this.isActive = true,
  });

  /// ロールが有効か
  bool get isEnabled => isActive;

  /// パーミッション数
  int get permissionCount => permissions.length;

  /// 特定のパーミッションを持つか
  bool hasPermission(Permission permission) => permissions.contains(permission);
}

/// パーミッション割当
class PermissionAssignment {
  final String assignmentId;
  final String userId;
  final Permission permission;
  final DateTime grantedAt;
  final DateTime? expiresAt;
  final String? grantedBy;
  final String? reason;

  PermissionAssignment({
    required this.assignmentId,
    required this.userId,
    required this.permission,
    required this.grantedAt,
    this.expiresAt,
    this.grantedBy,
    this.reason,
  });

  /// 割当が有効か
  bool get isActive => expiresAt == null || DateTime.now().isBefore(expiresAt!);

  /// 割当が期限切れか
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// 有効期限までの日数
  int? get daysUntilExpiration {
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now()).inDays;
  }
}

/// セッション
class Session {
  final String sessionId;
  final String userId;
  final String ipAddress;
  final String userAgent;
  final DateTime createdAt;
  final DateTime lastActivityAt;
  final DateTime? expiresAt;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  Session({
    required this.sessionId,
    required this.userId,
    required this.ipAddress,
    required this.userAgent,
    required this.createdAt,
    required this.lastActivityAt,
    this.expiresAt,
    this.isActive = true,
    this.metadata,
  });

  /// セッションが有効か
  bool get isValid => isActive && (expiresAt == null || DateTime.now().isBefore(expiresAt!));

  /// セッション期限切れか
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// セッション継続時間（秒）
  int get durationInSeconds => DateTime.now().difference(createdAt).inSeconds;

  /// 非アクティブ継続時間（秒）
  int get inactiveDurationInSeconds => DateTime.now().difference(lastActivityAt).inSeconds;
}

/// 監査ログ
class AuditLog {
  final String logId;
  final String userId;
  final String action; // login, logout, create, update, delete等
  final String resourceType;
  final String? resourceId;
  final DateTime timestamp;
  final String ipAddress;
  final bool isSuccessful;
  final String? details;
  final Map<String, dynamic>? changes;

  AuditLog({
    required this.logId,
    required this.userId,
    required this.action,
    required this.resourceType,
    this.resourceId,
    required this.timestamp,
    required this.ipAddress,
    this.isSuccessful = true,
    this.details,
    this.changes,
  });

  /// ログが重要か
  bool get isImportant => action == 'delete' || !isSuccessful || action == 'configure:system';

  /// 変更があったか
  bool get hasChanges => changes != null && changes!.isNotEmpty;
}

/// アクセス制御リスト
class AccessControlList {
  final String aclId;
  final String resourceId;
  final String resourceType;
  final Map<String, List<Permission>> rolePermissions; // role -> permissions
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;

  AccessControlList({
    required this.aclId,
    required this.resourceId,
    required this.resourceType,
    required this.rolePermissions,
    required this.createdAt,
    this.lastUpdatedAt,
  });

  /// 特定のロールが特定のパーミッションを持つか
  bool hasPermissionForRole(UserRole role, Permission permission) {
    return rolePermissions[role.value]?.contains(permission) ?? false;
  }

  /// ロール数
  int get roleCount => rolePermissions.length;
}

/// ユーザーアクティビティ統計
class UserActivity {
  final String activityId;
  final String userId;
  final int totalLogins;
  final int loginThisMonth;
  final int loginThisWeek;
  final DateTime? lastLoginAt;
  final DateTime? lastLogoutAt;
  final int averageSessionDurationMinutes;
  final List<String> recentIpAddresses;
  final DateTime periodStart;
  final DateTime periodEnd;

  UserActivity({
    required this.activityId,
    required this.userId,
    required this.totalLogins,
    required this.loginThisMonth,
    required this.loginThisWeek,
    this.lastLoginAt,
    this.lastLogoutAt,
    required this.averageSessionDurationMinutes,
    required this.recentIpAddresses,
    required this.periodStart,
    required this.periodEnd,
  });

  /// ユーザーがアクティブか（30日以内にログイン）
  bool get isActive => lastLoginAt != null &&
    DateTime.now().difference(lastLoginAt!).inDays <= 30;

  /// 異常なアクティビティ検出
  bool get hasAnomalousActivity => loginThisWeek > 50;
}

/// ユーザー管理レポート
class UserManagementReport {
  final String reportId;
  final DateTime generatedAt;
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int suspendedUsers;
  final Map<UserRole, int> usersByRole; // role -> count
  final List<User> recentlyCreatedUsers;
  final List<User> inactiveUsersList;
  final List<String>? recommendations;

  UserManagementReport({
    required this.reportId,
    required this.generatedAt,
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.suspendedUsers,
    required this.usersByRole,
    required this.recentlyCreatedUsers,
    required this.inactiveUsersCheckList,
    this.recommendations,
  });

  /// Markdown形式で出力
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# User Management Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');

    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Total Users: $totalUsers');
    buffer.writeln('- Active Users: $activeUsers');
    buffer.writeln('- Inactive Users: $inactiveUsers');
    buffer.writeln('- Suspended Users: $suspendedUsers');
    buffer.writeln('');

    return buffer.toString();
  }
}

/// パスワードポリシー
class PasswordPolicy {
  final String policyId;
  final int minLength;
  final int maxLength;
  final bool requireUppercase;
  final bool requireNumbers;
  final bool requireSpecialChars;
  final int expirationDays;
  final int minChangeDays;
  final int historyCount;
  final bool isActive;

  PasswordPolicy({
    required this.policyId,
    required this.minLength,
    required this.maxLength,
    required this.requireUppercase,
    required this.requireNumbers,
    required this.requireSpecialChars,
    required this.expirationDays,
    required this.minChangeDays,
    required this.historyCount,
    this.isActive = true,
  });

  /// ポリシーが有効か
  bool get isEnabled => isActive;

  /// ポリシーが厳しいか
  bool get isStrict => minLength >= 12 && requireSpecialChars && expirationDays <= 90;
}
