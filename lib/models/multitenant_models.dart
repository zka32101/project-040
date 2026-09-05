/// Phase 84: Multi-Tenant Architecture & Isolation System
/// Core domain models for multi-tenant application management
library multitenant_models;

part 'enums/multitenant_enums.dart';

// ============================================================================
// ENUMS (6 total)
// ============================================================================

enum TenantStatus {
  active('アクティブ'),
  suspended('停止中'),
  archived('アーカイブ'),
  deleted('削除済み');

  const TenantStatus(this.displayName);
  final String displayName;
}

enum IsolationLevel {
  logical('論理分離'),
  physical('物理分離'),
  hybrid('ハイブリッド'),
  strict('厳密分離');

  const IsolationLevel(this.displayName);
  final String displayName;
}

enum TenantTier {
  free('フリー'),
  starter('スターター'),
  professional('プロフェッショナル'),
  enterprise('エンタープライズ'),
  custom('カスタム');

  const TenantTier(this.displayName);
  final String displayName;
}

enum AccessLevel {
  owner('オーナー'),
  admin('管理者'),
  manager('マネージャー'),
  member('メンバー'),
  viewer('ビューアー');

  const AccessLevel(this.displayName);
  final String displayName;
}

enum DataResidencyRegion {
  usEast('US East'),
  usWest('US West'),
  euCentral('EU Central'),
  apacSingapore('APAC Singapore'),
  custom('カスタム');

  const DataResidencyRegion(this.displayName);
  final String displayName;
}

enum SharingPermissionType {
  inherit('継承'),
  explicit('明示的'),
  denyAll('全て拒否'),
  public('公開'),
  restricted('制限付き');

  const SharingPermissionType(this.displayName);
  final String displayName;
}

// ============================================================================
// MODELS (12 total)
// ============================================================================

/// Tenant: テナント基本情報
class Tenant {
  Tenant({
    required this.id,
    required this.name,
    required this.organizationId,
    required this.status,
    required this.tier,
    required this.isolationLevel,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.contactEmail,
    this.dataResidencyRegion = DataResidencyRegion.usEast,
    this.maxUsers = 100,
    this.maxStorageGb = 1000,
    this.maxApiCalls = 100000,
  });

  final String id;
  final String name;
  final String organizationId;
  final TenantStatus status;
  final TenantTier tier;
  final IsolationLevel isolationLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final String? contactEmail;
  final DataResidencyRegion dataResidencyRegion;
  final int maxUsers;
  final int maxStorageGb;
  final int maxApiCalls;

  bool get isActive => status == TenantStatus.active;
  bool get isEnterprise => tier == TenantTier.enterprise;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;

  Tenant copyWith({
    String? id,
    String? name,
    String? organizationId,
    TenantStatus? status,
    TenantTier? tier,
    IsolationLevel? isolationLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
    String? contactEmail,
    DataResidencyRegion? dataResidencyRegion,
    int? maxUsers,
    int? maxStorageGb,
    int? maxApiCalls,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      organizationId: organizationId ?? this.organizationId,
      status: status ?? this.status,
      tier: tier ?? this.tier,
      isolationLevel: isolationLevel ?? this.isolationLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
      contactEmail: contactEmail ?? this.contactEmail,
      dataResidencyRegion: dataResidencyRegion ?? this.dataResidencyRegion,
      maxUsers: maxUsers ?? this.maxUsers,
      maxStorageGb: maxStorageGb ?? this.maxStorageGb,
      maxApiCalls: maxApiCalls ?? this.maxApiCalls,
    );
  }
}

/// TenantAdmin: テナント管理者
class TenantAdmin {
  TenantAdmin({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.accessLevel,
    required this.grantedAt,
    this.revokedAt,
    this.notes,
  });

  final String id;
  final String tenantId;
  final String userId;
  final AccessLevel accessLevel;
  final DateTime grantedAt;
  final DateTime? revokedAt;
  final String? notes;

  bool get isActive => revokedAt == null;
  bool get isOwner => accessLevel == AccessLevel.owner;
  int get tenureDays => DateTime.now().difference(grantedAt).inDays;
}

/// TenantAuditLog: 監査ログ
class TenantAuditLog {
  TenantAuditLog({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    required this.timestamp,
    this.details,
    this.ipAddress,
    this.status = 'success',
  });

  final String id;
  final String tenantId;
  final String userId;
  final String action;
  final String resourceType;
  final String resourceId;
  final DateTime timestamp;
  final String? details;
  final String? ipAddress;
  final String status;

  bool get isSuccess => status == 'success';
  int get ageInHours => DateTime.now().difference(timestamp).inHours;
}

/// IsolationPolicy: 分離ポリシー
class IsolationPolicy {
  IsolationPolicy({
    required this.id,
    required this.tenantId,
    required this.level,
    required this.createdAt,
    required this.updatedAt,
    this.enforceDataEncryption = true,
    this.enforceNetworkIsolation = true,
    this.allowCrossTenantAccess = false,
    this.encryptionKeyRotationDays = 90,
  });

  final String id;
  final String tenantId;
  final IsolationLevel level;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool enforceDataEncryption;
  final bool enforceNetworkIsolation;
  final bool allowCrossTenantAccess;
  final int encryptionKeyRotationDays;

  bool get isStrictlyIsolated => level == IsolationLevel.strict && enforceDataEncryption && enforceNetworkIsolation;
}

/// AccessControl: アクセス制御
class AccessControl {
  AccessControl({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.resourceType,
    required this.resourceId,
    required this.permission,
    required this.grantedAt,
    this.expiresAt,
    this.conditions,
  });

  final String id;
  final String tenantId;
  final String userId;
  final String resourceType;
  final String resourceId;
  final String permission;
  final DateTime grantedAt;
  final DateTime? expiresAt;
  final String? conditions;

  bool get isActive => expiresAt == null || expiresAt!.isAfter(DateTime.now());
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
  int get expiresInDays => expiresAt?.difference(DateTime.now()).inDays ?? -1;
}

/// ResourceQuota: リソース割当
class ResourceQuota {
  ResourceQuota({
    required this.id,
    required this.tenantId,
    required this.resourceType,
    required this.quotaLimit,
    required this.currentUsage,
    required this.resetDate,
    this.alertThresholdPercent = 80,
    this.hardLimit = true,
  });

  final String id;
  final String tenantId;
  final String resourceType;
  final double quotaLimit;
  final double currentUsage;
  final DateTime resetDate;
  final double alertThresholdPercent;
  final bool hardLimit;

  double get usagePercent => (currentUsage / quotaLimit) * 100;
  double get remainingQuota => quotaLimit - currentUsage;
  bool get isExceeded => currentUsage > quotaLimit;
  bool get shouldAlert => usagePercent >= alertThresholdPercent;
  int get resetInDays => resetDate.difference(DateTime.now()).inDays;
}

/// DataResidencyPolicy: データレジデンシーポリシー
class DataResidencyPolicy {
  DataResidencyPolicy({
    required this.id,
    required this.tenantId,
    required this.allowedRegions,
    required this.primaryRegion,
    required this.createdAt,
    this.backupRegions = const [],
    this.enforceComplianceChecks = true,
    this.allowMultiRegionReplication = true,
  });

  final String id;
  final String tenantId;
  final List<DataResidencyRegion> allowedRegions;
  final DataResidencyRegion primaryRegion;
  final List<DataResidencyRegion> backupRegions;
  final DateTime createdAt;
  final bool enforceComplianceChecks;
  final bool allowMultiRegionReplication;

  bool get isPrimaryInRegion => allowedRegions.contains(primaryRegion);
  int get totalRegionCount => allowedRegions.length;
  bool get hasBackupRegions => backupRegions.isNotEmpty;
}

/// CrossTenantRequest: クロステナントリクエスト
class CrossTenantRequest {
  CrossTenantRequest({
    required this.id,
    required this.sourceTenantId,
    required this.targetTenantId,
    required this.requestType,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.expiresAt,
    this.reason,
  });

  final String id;
  final String sourceTenantId;
  final String targetTenantId;
  final String requestType;
  final String status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? expiresAt;
  final String? reason;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get isValid => isApproved && !isExpired;
}

/// TenantMetrics: テナントメトリクス
class TenantMetrics {
  TenantMetrics({
    required this.id,
    required this.tenantId,
    required this.timestamp,
    required this.activeUsers,
    required this.apiCallCount,
    required this.storageUsedGb,
    required this.cpuUsagePercent,
    required this.memoryUsagePercent,
  });

  final String id;
  final String tenantId;
  final DateTime timestamp;
  final int activeUsers;
  final int apiCallCount;
  final double storageUsedGb;
  final double cpuUsagePercent;
  final double memoryUsagePercent;

  double get totalResourceUsagePercent => (cpuUsagePercent + memoryUsagePercent) / 2;
  bool get isCpuHigh => cpuUsagePercent > 80;
  bool get isMemoryHigh => memoryUsagePercent > 80;
  int get ageInHours => DateTime.now().difference(timestamp).inHours;
}

/// ComplianceProfile: コンプライアンスプロファイル
class ComplianceProfile {
  ComplianceProfile({
    required this.id,
    required this.tenantId,
    required this.complianceFrameworks,
    required this.createdAt,
    required this.updatedAt,
    this.certifications = const [],
    this.auditDate,
    this.nextAuditDate,
    this.isCompliant = true,
  });

  final String id;
  final String tenantId;
  final List<String> complianceFrameworks;
  final List<String> certifications;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? auditDate;
  final DateTime? nextAuditDate;
  final bool isCompliant;

  int get frameworkCount => complianceFrameworks.length;
  int get certificationCount => certifications.length;
  bool get needsAudit => nextAuditDate != null && nextAuditDate!.isBefore(DateTime.now());
}

/// SharingRule: 共有ルール
class SharingRule {
  SharingRule({
    required this.id,
    required this.tenantId,
    required this.resourceType,
    required this.resourceId,
    required this.grantedTenantId,
    required this.permissionType,
    required this.createdAt,
    this.expiresAt,
    this.accessLevel = AccessLevel.viewer,
  });

  final String id;
  final String tenantId;
  final String resourceType;
  final String resourceId;
  final String grantedTenantId;
  final SharingPermissionType permissionType;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final AccessLevel accessLevel;

  bool get isActive => expiresAt == null || expiresAt!.isAfter(DateTime.now());
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get isFullyOpen => permissionType == SharingPermissionType.public;
}

/// TenantHealthCheck: テナントヘルスチェック
class TenantHealthCheck {
  TenantHealthCheck({
    required this.id,
    required this.tenantId,
    required this.timestamp,
    required this.status,
    required this.responseTimeMs,
    this.errorMessage,
    this.failureCount = 0,
    this.consecutiveFailures = 0,
  });

  final String id;
  final String tenantId;
  final DateTime timestamp;
  final String status;
  final int responseTimeMs;
  final String? errorMessage;
  final int failureCount;
  final int consecutiveFailures;

  bool get isHealthy => status == 'healthy';
  bool get isUnhealthy => status == 'unhealthy';
  bool get isSlowResponse => responseTimeMs > 5000;
  bool get isCriticalFailure => consecutiveFailures > 5;
  int get ageInMinutes => DateTime.now().difference(timestamp).inMinutes;
}
