/// Phase 50: User Management & Authorization System ユーザー管理・認可システム
///
/// ユーザー管理、ロール管理、権限制御、アクセス制御、セッション管理

/// ユーザーロール
enum UserRole {
  admin('admin'),
  manager('manager'),
  user('user'),
  guest('guest'),
  custom('custom');

  final String value;
  const UserRole(this.value);
}

/// パーミッションタイプ
enum PermissionType {
  create('create'),
  read('read'),
  update('update'),
  delete('delete'),
  export('export'),
  approve('approve'),
  admin('admin');

  final String value;
  const PermissionType(this.value);
}

/// 認可ステータス
enum AuthStatus {
  active('active'),
  inactive('inactive'),
  suspended('suspended'),
  locked('locked'),
  pendingVerification('pending_verification');

  final String value;
  const AuthStatus(this.value);
}

/// アクセスレベル
enum AccessLevel {
  public('public'),
  internal('internal'),
  restricted('restricted'),
  private('private'),
  custom('custom');

  final String value;
  const AccessLevel(this.value);
}

/// ユーザー
class User {
  final String userId;
  final String email;
  final String name;
  final List<String> roleIds;
  final AuthStatus status;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final DateTime? lastPasswordChange;
  final bool mfaEnabled;
  final Map<String, dynamic>? metadata;

  User({
    required this.userId,
    required this.email,
    required this.name,
    required this.roleIds,
    this.status = AuthStatus.active,
    required this.createdAt,
    this.lastLogin,
    this.lastPasswordChange,
    this.mfaEnabled = false,
    this.metadata,
  });

  /// ユーザーがアクティブか
  bool get isActive => status == AuthStatus.active;

  /// ユーザーがロックされているか
  bool get isLocked => status == AuthStatus.locked;

  /// ユーザーが確認待ちか
  bool get isPendingVerification => status == AuthStatus.pendingVerification;

  /// ユーザーの年齢
  Duration get age => DateTime.now().difference(createdAt);

  /// 最後のログインからの経過時間
  Duration? get timeSinceLastLogin {
    if (lastLogin == null) return null;
    return DateTime.now().difference(lastLogin!);
  }
}

/// ロール
class Role {
  final String roleId;
  final String name;
  final String description;
  final List<String> permissionIds;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Role({
    required this.roleId,
    required this.name,
    required this.description,
    required this.permissionIds,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// ロールが有効か
  bool get isEnabled => isActive;

  /// パーミッション数
  int get permissionCount => permissionIds.length;
}

/// パーミッション
class Permission {
  final String permissionId;
  final String name;
  final String description;
  final PermissionType type;
  final String resourceType;
  final AccessLevel level;
  final DateTime createdAt;

  Permission({
    required this.permissionId,
    required this.name,
    required this.description,
    required this.type,
    required this.resourceType,
    required this.level,
    required this.createdAt,
  });

  /// パーミッションが読み取り専用か
  bool get isReadOnly => type == PermissionType.read;

  /// パーミッションが管理者限定か
  bool get isAdminOnly => type == PermissionType.admin;
}

/// ユーザーロール割り当て
class UserRoleAssignment {
  final String assignmentId;
  final String userId;
  final String roleId;
  final DateTime assignedAt;
  final DateTime? expiresAt;
  final String? assignedBy;

  UserRoleAssignment({
    required this.assignmentId,
    required this.userId,
    required this.roleId,
    required this.assignedAt,
    this.expiresAt,
    this.assignedBy,
  });

  /// ロール割り当てがアクティブか
  bool get isActive {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// ロール割り当てが期限切れか
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// 有効期限までの時間
  Duration? get timeUntilExpiration {
    if (expiresAt == null) return null;
    if (isExpired) return null;
    return expiresAt!.difference(DateTime.now());
  }
}

/// アクセスコントロール
class AccessControl {
  final String controlId;
  final String resourceId;
  final String resourceType;
  final List<String> allowedRoleIds;
  final List<String> allowedUserIds;
  final AccessLevel level;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AccessControl({
    required this.controlId,
    required this.resourceId,
    required this.resourceType,
    required this.allowedRoleIds,
    required this.allowedUserIds,
    required this.level,
    required this.createdAt,
    this.updatedAt,
  });

  /// アクセス許可ユーザー数
  int get totalAllowedUsers => allowedRoleIds.length + allowedUserIds.length;

  /// プライベートリソースか
  bool get isPrivate => level == AccessLevel.private;

  /// パブリックリソースか
  bool get isPublic => level == AccessLevel.public;
}

/// ユーザーセッション
class UserSession {
  final String sessionId;
  final String userId;
  final DateTime loginAt;
  final DateTime? logoutAt;
  final DateTime lastActivity;
  final String? ipAddress;
  final String? userAgent;
  final bool isActive;

  UserSession({
    required this.sessionId,
    required this.userId,
    required this.loginAt,
    this.logoutAt,
    required this.lastActivity,
    this.ipAddress,
    this.userAgent,
    this.isActive = true,
  });

  /// セッションがアクティブか
  bool get isSessionActive => isActive && logoutAt == null;

  /// セッション継続時間
  Duration get duration {
    final endTime = logoutAt ?? DateTime.now();
    return endTime.difference(loginAt);
  }

  /// アイドル時間
  Duration get idleTime => DateTime.now().difference(lastActivity);

  /// セッションがタイムアウトしているか（30分以上アイドル）
  bool get isTimedOut => idleTime.inMinutes > 30;
}

/// 認可ポリシー
class AuthorizationPolicy {
  final String policyId;
  final String name;
  final String description;
  final List<Map<String, dynamic>> rules;
  final List<Map<String, dynamic>>? conditions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AuthorizationPolicy({
    required this.policyId,
    required this.name,
    required this.description,
    required this.rules,
    this.conditions,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// ポリシーが有効か
  bool get isEnabled => isActive;

  /// ルール数
  int get ruleCount => rules.length;
}

/// 権限監査
class PermissionAudit {
  final String auditId;
  final String userId;
  final PermissionType action;
  final String resourceType;
  final String resourceId;
  final bool allowed;
  final DateTime timestamp;
  final String? reason;
  final Map<String, dynamic>? context;

  PermissionAudit({
    required this.auditId,
    required this.userId,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    required this.allowed,
    required this.timestamp,
    this.reason,
    this.context,
  });

  /// アクセスが許可されたか
  bool get isAllowed => allowed;

  /// アクセスが拒否されたか
  bool get isDenied => !allowed;
}

/// ユーザー統計
class UserStats {
  final String statsId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int suspendedUsers;
  final Map<UserRole, int> usersByRole;
  final int totalSessions;
  final int activeSessions;
  final double averageSessionDuration; // minutes

  UserStats({
    required this.statsId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.suspendedUsers,
    required this.usersByRole,
    required this.totalSessions,
    required this.activeSessions,
    required this.averageSessionDuration,
  });

  /// アクティブ率
  double get activeRate {
    if (totalUsers == 0) return 0.0;
    return activeUsers / totalUsers;
  }

  /// セッション稼働率
  double get sessionActiveRate {
    if (totalSessions == 0) return 0.0;
    return activeSessions / totalSessions;
  }

  /// 最も使用されたロール
  UserRole? get mostCommonRole {
    if (usersByRole.isEmpty) return null;
    return usersByRole.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

/// ユーザー管理レポート
class UserManagementReport {
  final String reportId;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final UserStats stats;
  final List<User> recentUsers;
  final List<PermissionAudit> recentAudits;
  final List<String>? recommendations;

  UserManagementReport({
    required this.reportId,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.stats,
    required this.recentUsers,
    required this.recentAudits,
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
    buffer.writeln('- Total Users: ${stats.totalUsers}');
    buffer.writeln('- Active Users: ${stats.activeUsers}');
    buffer.writeln('- Inactive Users: ${stats.inactiveUsers}');
    buffer.writeln('- Suspended Users: ${stats.suspendedUsers}');
    buffer.writeln('- Active Rate: ${(stats.activeRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('');

    buffer.writeln('## Sessions');
    buffer.writeln('');
    buffer.writeln('- Total Sessions: ${stats.totalSessions}');
    buffer.writeln('- Active Sessions: ${stats.activeSessions}');
    buffer.writeln('- Active Rate: ${(stats.sessionActiveRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('- Avg Duration: ${stats.averageSessionDuration.toStringAsFixed(1)} min');
    buffer.writeln('');

    if (recommendations != null && recommendations!.isNotEmpty) {
      buffer.writeln('## Recommendations');
      buffer.writeln('');
      for (final rec in recommendations!.take(5)) {
        buffer.writeln('- $rec');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}
