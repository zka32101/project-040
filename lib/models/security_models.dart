/// Phase 54: Security & Compliance セキュリティ・法令準拠
///
/// 暗号化、トークン管理、パスワードポリシー、監査ログ、法令準拠機能

/// 暗号化方式
enum EncryptionType {
  aes256('aes256'),
  rsa2048('rsa2048'),
  sha256('sha256'),
  bcrypt('bcrypt');

  final String value;
  const EncryptionType(this.value);
}

/// セキュリティレベル
enum SecurityLevel {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  final String value;
  const SecurityLevel(this.value);
}

/// 法令準拠ステータス
enum ComplianceStatus {
  compliant('compliant'),
  nonCompliant('non_compliant'),
  partiallyCompliant('partially_compliant'),
  unknown('unknown');

  final String value;
  const ComplianceStatus(this.value);
}

/// 暗号化キー
class EncryptionKey {
  final String keyId;
  final String keyName;
  final EncryptionType encryptionType;
  final DateTime createdAt;
  final DateTime? rotatedAt;
  final DateTime? expiresAt;
  final bool isActive;
  final String? algorithm;

  EncryptionKey({
    required this.keyId,
    required this.keyName,
    required this.encryptionType,
    required this.createdAt,
    this.rotatedAt,
    this.expiresAt,
    this.isActive = true,
    this.algorithm,
  });

  /// キーが有効か
  bool get isValid => isActive && (expiresAt == null || DateTime.now().isBefore(expiresAt!));

  /// キーが期限切れか
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// キーがローテーション前か
  bool get needsRotation => rotatedAt != null && 
    DateTime.now().difference(rotatedAt!).inDays > 90;
}

/// トークン情報
class TokenInfo {
  final String tokenId;
  final String userId;
  final String token;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final List<String> scopes;
  final SecurityLevel securityLevel;
  final bool isRevoked;

  TokenInfo({
    required this.tokenId,
    required this.userId,
    required this.token,
    required this.issuedAt,
    required this.expiresAt,
    required this.scopes,
    required this.securityLevel,
    this.isRevoked = false,
  });

  /// トークンが有効か
  bool get isValid => !isRevoked && DateTime.now().isBefore(expiresAt);

  /// トークンが期限切れか
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// トークンの有効期限までの時間
  Duration? get timeUntilExpiration {
    if (isExpired) return null;
    return expiresAt.difference(DateTime.now());
  }
}

/// パスワードポリシー
class PasswordPolicy {
  final String policyId;
  final int minLength;
  final int maxLength;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireNumbers;
  final bool requireSpecialChars;
  final int expirationDays;
  final int historyCount;
  final DateTime createdAt;

  PasswordPolicy({
    required this.policyId,
    required this.minLength,
    required this.maxLength,
    required this.requireUppercase,
    required this.requireLowercase,
    required this.requireNumbers,
    required this.requireSpecialChars,
    required this.expirationDays,
    required this.historyCount,
    required this.createdAt,
  });

  /// ポリシーが厳しいか
  bool get isStrict => minLength >= 12 && requireSpecialChars && expirationDays <= 90;

  /// パスワード複雑度スコア
  int get complexityScore {
    int score = 0;
    if (minLength >= 12) score += 2;
    if (requireUppercase) score += 1;
    if (requireLowercase) score += 1;
    if (requireNumbers) score += 1;
    if (requireSpecialChars) score += 2;
    return score;
  }
}

/// セキュリティイベント
class SecurityEvent {
  final String eventId;
  final String userId;
  final String eventType; // login, logout, failed_login, permission_change
  final SecurityLevel severity;
  final DateTime occurredAt;
  final String ipAddress;
  final Map<String, dynamic>? details;
  final bool isAnomalous;

  SecurityEvent({
    required this.eventId,
    required this.userId,
    required this.eventType,
    required this.severity,
    required this.occurredAt,
    required this.ipAddress,
    this.details,
    this.isAnomalous = false,
  });

  /// イベントが重大か
  bool get isCritical => severity == SecurityLevel.critical;

  /// イベントが警告レベルか
  bool get isWarning => severity == SecurityLevel.high;
}

/// 脆弱性評価
class VulnerabilityAssessment {
  final String assessmentId;
  final String resourceId;
  final String resourceType;
  final List<String> vulnerabilities;
  final double riskScore; // 0.0-1.0
  final DateTime assessedAt;
  final String? remediationPlan;
  final bool isResolved;

  VulnerabilityAssessment({
    required this.assessmentId,
    required this.resourceId,
    required this.resourceType,
    required this.vulnerabilities,
    required this.riskScore,
    required this.assessedAt,
    this.remediationPlan,
    this.isResolved = false,
  });

  /// リスクが高いか
  bool get isHighRisk => riskScore > 0.7;

  /// 脆弱性数
  int get vulnerabilityCount => vulnerabilities.length;
}

/// 法令準拠ルール
class ComplianceRule {
  final String ruleId;
  final String ruleName;
  final String description;
  final String framework; // GDPR, HIPAA, SOC2等
  final bool isActive;
  final DateTime createdAt;
  final List<String> relatedPolicies;

  ComplianceRule({
    required this.ruleId,
    required this.ruleName,
    required this.description,
    required this.framework,
    required this.isActive,
    required this.createdAt,
    required this.relatedPolicies,
  });

  /// ルールが有効か
  bool get isEnabled => isActive;

  /// 関連ポリシー数
  int get policyCount => relatedPolicies.length;
}

/// セキュリティ監査
class SecurityAudit {
  final String auditId;
  final List<SecurityEvent> events;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalEvents;
  final int criticalEvents;
  final double compliancePercentage;

  SecurityAudit({
    required this.auditId,
    required this.events,
    required this.periodStart,
    required this.periodEnd,
    required this.totalEvents,
    required this.criticalEvents,
    required this.compliancePercentage,
  });

  /// 監査が良好か
  bool get isPassing => compliancePercentage > 0.95;

  /// セキュリティイベント数
  int get eventCount => events.length;

  /// クリティカルイベント率
  double get criticalEventRate {
    if (totalEvents == 0) return 0.0;
    return criticalEvents / totalEvents;
  }
}

/// セキュリティレポート
class SecurityReport {
  final String reportId;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final SecurityAudit audit;
  final List<VulnerabilityAssessment> vulnerabilities;
  final ComplianceStatus overallComplianceStatus;
  final List<String>? recommendations;

  SecurityReport({
    required this.reportId,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.audit,
    required this.vulnerabilities,
    required this.overallComplianceStatus,
    this.recommendations,
  });

  /// Markdown形式で出力
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Security Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');

    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Compliance Status: ${overallComplianceStatus.value}');
    buffer.writeln('- Compliance Score: ${(audit.compliancePercentage * 100).toStringAsFixed(1)}%');
    buffer.writeln('- Total Events: ${audit.totalEvents}');
    buffer.writeln('- Critical Events: ${audit.criticalEvents}');
    buffer.writeln('- Vulnerabilities Found: ${vulnerabilities.length}');
    buffer.writeln('');

    if (vulnerabilities.isNotEmpty) {
      buffer.writeln('## High Risk Vulnerabilities');
      buffer.writeln('');
      for (final vuln in vulnerabilities.where((v) => v.isHighRisk).take(5)) {
        buffer.writeln('- **${vuln.resourceId}**: Risk ${(vuln.riskScore * 100).toStringAsFixed(0)}%');
        buffer.writeln('  - Found: ${vuln.vulnerabilityCount} issues');
      }
      buffer.writeln('');
    }

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

/// 権限監査ログ
class PermissionAuditLog {
  final String logId;
  final String userId;
  final String action; // grant, revoke, modify
  final String permission;
  final DateTime timestamp;
  final String? reason;
  final bool isApproved;

  PermissionAuditLog({
    required this.logId,
    required this.userId,
    required this.action,
    required this.permission,
    required this.timestamp,
    this.reason,
    this.isApproved = false,
  });

  /// 権限付与か
  bool get isGrant => action == 'grant';

  /// 権限取消か
  bool get isRevoke => action == 'revoke';
}

/// セキュリティポリシー
class SecurityPolicy {
  final String policyId;
  final String policyName;
  final SecurityLevel minimumLevel;
  final List<String> appliedRoles;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;
  final bool isActive;

  SecurityPolicy({
    required this.policyId,
    required this.policyName,
    required this.minimumLevel,
    required this.appliedRoles,
    required this.createdAt,
    this.lastUpdatedAt,
    this.isActive = true,
  });

  /// ポリシーが有効か
  bool get isEnabled => isActive;

  /// 対象ロール数
  int get roleCount => appliedRoles.length;
}
