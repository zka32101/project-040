/// Phase 89: Advanced Security & Compliance Frameworks
/// Core domain models for security and compliance systems
library security_models;

// ============================================================================
// ENUMS (6 total)
// ============================================================================

enum EncryptionType {
  aes256('AES-256'),
  rsa2048('RSA-2048'),
  chacha20('ChaCha20'),
  twofish('Twofish'),
  serpent('Serpent'),
  blake3('BLAKE3');

  const EncryptionType(this.displayName);
  final String displayName;
}

enum ComplianceFramework {
  gdpr('GDPR'),
  hipaa('HIPAA'),
  pci_dss('PCI DSS'),
  soc2('SOC 2'),
  iso27001('ISO 27001'),
  ccpa('CCPA');

  const ComplianceFramework(this.displayName);
  final String displayName;
}

enum SecurityAuditAction {
  login('ログイン'),
  logout('ログアウト'),
  dataAccess('データアクセス'),
  dataModify('データ変更'),
  roleChange('ロール変更'),
  permissionChange('権限変更');

  const SecurityAuditAction(this.displayName);
  final String displayName;
}

enum IncidentSeverity {
  critical('クリティカル'),
  high('高'),
  medium('中'),
  low('低'),
  informational('情報');

  const IncidentSeverity(this.displayName);
  final String displayName;
}

enum ComplianceStatus {
  compliant('準拠'),
  nonCompliant('非準拠'),
  partiallyCompliant('部分的に準拠'),
  notAssessed('未評価'),
  remediation('改善中');

  const ComplianceStatus(this.displayName);
  final String displayName;
}

enum PrivacyLevel {
  public('公開'),
  internal('社内'),
  confidential('機密'),
  restricted('制限'),
  topSecret('極秘');

  const PrivacyLevel(this.displayName);
  final String displayName;
}

// ============================================================================
// MODELS (12 total)
// ============================================================================

/// EncryptionKey: 暗号化キー
class EncryptionKey {
  EncryptionKey({
    required this.id,
    required this.keyName,
    required this.encryptionType,
    required this.createdAt,
    required this.expiresAt,
    this.description,
    this.keyVersion = '1.0',
    this.isActive = true,
    this.rotationSchedule,
  });

  final String id;
  final String keyName;
  final EncryptionType encryptionType;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? description;
  final String keyVersion;
  final bool isActive;
  final int? rotationSchedule;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get needsRotation =>
      rotationSchedule != null &&
      DateTime.now().difference(createdAt).inDays >= rotationSchedule!;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  int get daysUntilExpiry => expiresAt.difference(DateTime.now()).inDays;

  EncryptionKey copyWith({
    String? id,
    String? keyName,
    EncryptionType? encryptionType,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? description,
    String? keyVersion,
    bool? isActive,
    int? rotationSchedule,
  }) {
    return EncryptionKey(
      id: id ?? this.id,
      keyName: keyName ?? this.keyName,
      encryptionType: encryptionType ?? this.encryptionType,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      description: description ?? this.description,
      keyVersion: keyVersion ?? this.keyVersion,
      isActive: isActive ?? this.isActive,
      rotationSchedule: rotationSchedule ?? this.rotationSchedule,
    );
  }
}

/// SecurityAuditLog: セキュリティ監査ログ
class SecurityAuditLog {
  SecurityAuditLog({
    required this.id,
    required this.userId,
    required this.action,
    required this.timestamp,
    required this.createdAt,
    this.resourceId,
    this.details,
    this.ipAddress,
    this.userAgent,
    this.status = 'success',
  });

  final String id;
  final String userId;
  final SecurityAuditAction action;
  final DateTime timestamp;
  final DateTime createdAt;
  final String? resourceId;
  final String? details;
  final String? ipAddress;
  final String? userAgent;
  final String status;

  bool get isSuccess => status == 'success';
  bool get isFailure => status == 'failure';
  int get ageInSeconds => DateTime.now().difference(timestamp).inSeconds;
  int get ageInMinutes => DateTime.now().difference(timestamp).inMinutes;
}

/// ComplianceRule: コンプライアンスルール
class ComplianceRule {
  ComplianceRule({
    required this.id,
    required this.ruleName,
    required this.framework,
    required this.createdAt,
    this.description,
    this.severity = 'high',
    this.isActive = true,
    this.lastAuditedAt,
  });

  final String id;
  final String ruleName;
  final ComplianceFramework framework;
  final DateTime createdAt;
  final String? description;
  final String severity;
  final bool isActive;
  final DateTime? lastAuditedAt;

  bool get needsAudit =>
      lastAuditedAt == null ||
      DateTime.now().difference(lastAuditedAt!).inDays > 30;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  int get daysSinceAudit => lastAuditedAt != null
      ? DateTime.now().difference(lastAuditedAt!).inDays
      : -1;
}

/// SecurityIncident: セキュリティインシデント
class SecurityIncident {
  SecurityIncident({
    required this.id,
    required this.incidentType,
    required this.severity,
    required this.detectedAt,
    required this.createdAt,
    this.description,
    this.affectedResources,
    this.resolvedAt,
    this.status = 'open',
  });

  final String id;
  final String incidentType;
  final IncidentSeverity severity;
  final DateTime detectedAt;
  final DateTime createdAt;
  final String? description;
  final List<String>? affectedResources;
  final DateTime? resolvedAt;
  final String status;

  bool get isResolved => resolvedAt != null;
  bool get isCritical => severity == IncidentSeverity.critical;
  int get durationSeconds => (resolvedAt ?? DateTime.now())
      .difference(detectedAt)
      .inSeconds;
  int get ageInHours => DateTime.now().difference(detectedAt).inHours;
}

/// ComplianceAssessment: コンプライアンス評価
class ComplianceAssessment {
  ComplianceAssessment({
    required this.id,
    required this.framework,
    required this.assessmentDate,
    required this.createdAt,
    this.status = ComplianceStatus.notAssessed,
    this.complianceScore = 0.0,
    this.findingsCount = 0,
    this.remediationDeadline,
  });

  final String id;
  final ComplianceFramework framework;
  final DateTime assessmentDate;
  final DateTime createdAt;
  final ComplianceStatus status;
  final double complianceScore;
  final int findingsCount;
  final DateTime? remediationDeadline;

  bool get isCompliant => status == ComplianceStatus.compliant;
  bool get hasFindings => findingsCount > 0;
  bool get isOverdue =>
      remediationDeadline != null &&
      DateTime.now().isAfter(remediationDeadline!);
  int get ageInDays => DateTime.now().difference(assessmentDate).inDays;
}

/// PrivacyPolicy: プライバシーポリシー
class PrivacyPolicy {
  PrivacyPolicy({
    required this.id,
    required this.policyName,
    required this.privacyLevel,
    required this.createdAt,
    required this.version,
    this.description,
    this.dataRetentionDays = 365,
    this.isActive = true,
    this.lastUpdatedAt,
  });

  final String id;
  final String policyName;
  final PrivacyLevel privacyLevel;
  final DateTime createdAt;
  final String version;
  final String? description;
  final int dataRetentionDays;
  final bool isActive;
  final DateTime? lastUpdatedAt;

  bool get needsReview =>
      lastUpdatedAt == null ||
      DateTime.now().difference(lastUpdatedAt!).inDays > 90;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

/// DataEncryption: データ暗号化
class DataEncryption {
  DataEncryption({
    required this.id,
    required this.dataId,
    required this.encryptionKeyId,
    required this.encryptionType,
    required this.createdAt,
    this.algorithm,
    this.isEncrypted = true,
    this.encryptionTimestampMs = 0,
  });

  final String id;
  final String dataId;
  final String encryptionKeyId;
  final EncryptionType encryptionType;
  final DateTime createdAt;
  final String? algorithm;
  final bool isEncrypted;
  final int encryptionTimestampMs;

  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

/// SecurityPolicy: セキュリティポリシー
class SecurityPolicy {
  SecurityPolicy({
    required this.id,
    required this.policyName,
    required this.createdAt,
    this.description,
    this.minPasswordLength = 12,
    this.requireMfa = true,
    this.sessionTimeoutMinutes = 30,
    this.isActive = true,
  });

  final String id;
  final String policyName;
  final DateTime createdAt;
  final String? description;
  final int minPasswordLength;
  final bool requireMfa;
  final int sessionTimeoutMinutes;
  final bool isActive;

  bool get isMfaRequired => requireMfa;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

/// VulnerabilityReport: 脆弱性レポート
class VulnerabilityReport {
  VulnerabilityReport({
    required this.id,
    required this.vulnerabilityName,
    required this.severity,
    required this.discoveredAt,
    required this.createdAt,
    this.cvssScore = 0.0,
    this.affectedComponent,
    this.remediationDate,
    this.status = 'open',
  });

  final String id;
  final String vulnerabilityName;
  final IncidentSeverity severity;
  final DateTime discoveredAt;
  final DateTime createdAt;
  final double cvssScore;
  final String? affectedComponent;
  final DateTime? remediationDate;
  final String status;

  bool get isResolved => status == 'resolved';
  bool get isCritical => cvssScore >= 9.0;
  int get ageInDays => DateTime.now().difference(discoveredAt).inDays;
  int get daysToRemediation => remediationDate != null
      ? remediationDate!.difference(DateTime.now()).inDays
      : -1;
}

/// DataAccessLog: データアクセスログ
class DataAccessLog {
  DataAccessLog({
    required this.id,
    required this.userId,
    required this.dataId,
    required this.accessTime,
    required this.createdAt,
    this.accessType = 'read',
    this.purpose,
    this.ipAddress,
    this.status = 'granted',
  });

  final String id;
  final String userId;
  final String dataId;
  final DateTime accessTime;
  final DateTime createdAt;
  final String accessType;
  final String? purpose;
  final String? ipAddress;
  final String status;

  bool get isGranted => status == 'granted';
  bool get isDenied => status == 'denied';
  int get ageInSeconds => DateTime.now().difference(accessTime).inSeconds;
  int get ageInMinutes => DateTime.now().difference(accessTime).inMinutes;
}

/// ComplianceViolation: コンプライアンス違反
class ComplianceViolation {
  ComplianceViolation({
    required this.id,
    required this.violationType,
    required this.framework,
    required this.detectedAt,
    required this.createdAt,
    this.description,
    this.severity = 'high',
    this.remediationDeadline,
    this.status = 'open',
  });

  final String id;
  final String violationType;
  final ComplianceFramework framework;
  final DateTime detectedAt;
  final DateTime createdAt;
  final String? description;
  final String severity;
  final DateTime? remediationDeadline;
  final String status;

  bool get isResolved => status == 'resolved';
  bool get isOverdue =>
      remediationDeadline != null &&
      DateTime.now().isAfter(remediationDeadline!);
  int get ageInDays => DateTime.now().difference(detectedAt).inDays;
}
