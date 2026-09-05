/// Phase 84: Multi-Tenant Architecture & Isolation System
/// Service layer for multi-tenant management
library multitenant_service;

import 'package:project_040/models/multitenant_models.dart';

// ============================================================================
// REPOSITORY INTERFACE (88 methods)
// ============================================================================

abstract class MultiTenantRepository {
  // ---- Tenant Management (15 methods) ----
  Future<Tenant> createTenant(Tenant tenant);
  Future<Tenant?> getTenantById(String tenantId);
  Future<List<Tenant>> getTenantsByOrganization(String organizationId);
  Future<List<Tenant>> getTenantsByStatus(TenantStatus status);
  Future<List<Tenant>> getTenantsByTier(TenantTier tier);
  Future<List<Tenant>> searchTenants(String query);
  Future<Tenant> updateTenant(Tenant tenant);
  Future<bool> deleteTenant(String tenantId);
  Future<bool> suspendTenant(String tenantId);
  Future<bool> reactivateTenant(String tenantId);
  Future<int> getTenantCount();
  Future<int> getActiveTenantCount();
  Future<List<Tenant>> getAllTenants({int limit = 100, int offset = 0});
  Future<bool> isTenantNameUnique(String name);
  Future<Tenant?> getTenantByName(String name);

  // ---- Admin Management (10 methods) ----
  Future<TenantAdmin> grantAdminAccess(TenantAdmin admin);
  Future<TenantAdmin?> getAdminById(String adminId);
  Future<List<TenantAdmin>> getAdminsByTenant(String tenantId);
  Future<List<TenantAdmin>> getAdminsByUser(String userId);
  Future<TenantAdmin> updateAdminAccess(TenantAdmin admin);
  Future<bool> revokeAdminAccess(String adminId);
  Future<int> getAdminCountForTenant(String tenantId);
  Future<List<TenantAdmin>> getActiveAdmins(String tenantId);
  Future<TenantAdmin?> getTenantOwner(String tenantId);
  Future<bool> hasAdminAccess(String tenantId, String userId);

  // ---- Audit Logging (8 methods) ----
  Future<TenantAuditLog> logAction(TenantAuditLog log);
  Future<TenantAuditLog?> getAuditLogById(String logId);
  Future<List<TenantAuditLog>> getAuditLogsByTenant(String tenantId);
  Future<List<TenantAuditLog>> getAuditLogsByUser(String userId, String tenantId);
  Future<List<TenantAuditLog>> getAuditLogsByAction(String tenantId, String action);
  Future<int> getAuditLogCount(String tenantId);
  Future<List<TenantAuditLog>> getRecentAuditLogs(String tenantId, {int limit = 50});
  Future<bool> deleteOldAuditLogs(String tenantId, Duration olderThan);

  // ---- Isolation Policy (8 methods) ----
  Future<IsolationPolicy> createIsolationPolicy(IsolationPolicy policy);
  Future<IsolationPolicy?> getPolicyById(String policyId);
  Future<IsolationPolicy?> getPolicyByTenant(String tenantId);
  Future<IsolationPolicy> updatePolicy(IsolationPolicy policy);
  Future<bool> deletePolicy(String policyId);
  Future<List<IsolationPolicy>> getPoliciesByLevel(IsolationLevel level);
  Future<bool> enforcePolicyEncryption(String tenantId);
  Future<bool> enforcePolicyNetworkIsolation(String tenantId);

  // ---- Access Control (12 methods) ----
  Future<AccessControl> grantAccess(AccessControl control);
  Future<AccessControl?> getAccessById(String accessId);
  Future<List<AccessControl>> getAccessByUser(String userId, String tenantId);
  Future<List<AccessControl>> getAccessByResource(String tenantId, String resourceType, String resourceId);
  Future<AccessControl> updateAccess(AccessControl control);
  Future<bool> revokeAccess(String accessId);
  Future<bool> revokeAccessByUser(String userId, String tenantId);
  Future<int> getAccessCountForUser(String userId, String tenantId);
  Future<bool> hasPermission(String userId, String tenantId, String resourceId, String permission);
  Future<List<AccessControl>> getAccessByPermission(String tenantId, String permission);
  Future<List<AccessControl>> getExpiringAccess(String tenantId, {Duration withinDays = const Duration(days: 7)});
  Future<bool> revokeExpiredAccess(String tenantId);

  // ---- Resource Quota (8 methods) ----
  Future<ResourceQuota> createQuota(ResourceQuota quota);
  Future<ResourceQuota?> getQuotaById(String quotaId);
  Future<ResourceQuota?> getQuotaByTenant(String tenantId, String resourceType);
  Future<List<ResourceQuota>> getQuotasByTenant(String tenantId);
  Future<ResourceQuota> updateQuota(ResourceQuota quota);
  Future<bool> incrementUsage(String quotaId, double amount);
  Future<bool> decrementUsage(String quotaId, double amount);
  Future<List<ResourceQuota>> getQuotasAboveThreshold(String tenantId, double thresholdPercent);

  // ---- Data Residency (8 methods) ----
  Future<DataResidencyPolicy> createPolicy(DataResidencyPolicy policy);
  Future<DataResidencyPolicy?> getPolicyById(String policyId);
  Future<DataResidencyPolicy?> getPolicyByTenant(String tenantId);
  Future<DataResidencyPolicy> updatePolicy(DataResidencyPolicy policy);
  Future<bool> deletePolicy(String policyId);
  Future<List<DataResidencyPolicy>> getPoliciesByRegion(DataResidencyRegion region);
  Future<bool> isRegionAllowed(String tenantId, DataResidencyRegion region);
  Future<bool> canReplicateToRegion(String tenantId, DataResidencyRegion region);

  // ---- Cross-Tenant Requests (6 methods) ----
  Future<CrossTenantRequest> createRequest(CrossTenantRequest request);
  Future<CrossTenantRequest?> getRequestById(String requestId);
  Future<List<CrossTenantRequest>> getRequestsBySource(String sourceTenantId);
  Future<List<CrossTenantRequest>> getRequestsByTarget(String targetTenantId);
  Future<CrossTenantRequest> approveRequest(String requestId);
  Future<bool> rejectRequest(String requestId);

  // ---- Tenant Metrics (6 methods) ----
  Future<TenantMetrics> recordMetrics(TenantMetrics metrics);
  Future<TenantMetrics?> getLatestMetrics(String tenantId);
  Future<List<TenantMetrics>> getMetricsHistory(String tenantId, Duration period);
  Future<double> getAverageApiCalls(String tenantId, Duration period);
  Future<double> getAverageActiveUsers(String tenantId, Duration period);
  Future<List<TenantMetrics>> getHighResourceUsageTenants(double threshold);

  // ---- Compliance & Health (7 methods) ----
  Future<ComplianceProfile> createProfile(ComplianceProfile profile);
  Future<ComplianceProfile?> getProfileByTenant(String tenantId);
  Future<ComplianceProfile> updateProfile(ComplianceProfile profile);
  Future<TenantHealthCheck> recordHealthCheck(TenantHealthCheck check);
  Future<TenantHealthCheck?> getLatestHealthCheck(String tenantId);
  Future<List<TenantHealthCheck>> getHealthCheckHistory(String tenantId, Duration period);
  Future<List<String>> getUnhealthyTenants();
}

// ============================================================================
// IN-MEMORY REPOSITORY IMPLEMENTATION
// ============================================================================

class InMemoryMultiTenantRepository extends MultiTenantRepository {
  final Map<String, Tenant> _tenants = {};
  final Map<String, TenantAdmin> _admins = {};
  final Map<String, TenantAuditLog> _auditLogs = {};
  final Map<String, IsolationPolicy> _policies = {};
  final Map<String, AccessControl> _accessControls = {};
  final Map<String, ResourceQuota> _quotas = {};
  final Map<String, DataResidencyPolicy> _residencyPolicies = {};
  final Map<String, CrossTenantRequest> _crossTenantRequests = {};
  final Map<String, TenantMetrics> _metrics = {};
  final Map<String, ComplianceProfile> _complianceProfiles = {};

  // ---- Tenant Management ----
  @override
  Future<Tenant> createTenant(Tenant tenant) async {
    _tenants[tenant.id] = tenant;
    return tenant;
  }

  @override
  Future<Tenant?> getTenantById(String tenantId) async => _tenants[tenantId];

  @override
  Future<List<Tenant>> getTenantsByOrganization(String organizationId) async {
    return _tenants.values
        .where((t) => t.organizationId == organizationId)
        .toList();
  }

  @override
  Future<List<Tenant>> getTenantsByStatus(TenantStatus status) async {
    return _tenants.values.where((t) => t.status == status).toList();
  }

  @override
  Future<List<Tenant>> getTenantsByTier(TenantTier tier) async {
    return _tenants.values.where((t) => t.tier == tier).toList();
  }

  @override
  Future<List<Tenant>> searchTenants(String query) async {
    final lowerQuery = query.toLowerCase();
    return _tenants.values
        .where((t) => t.name.toLowerCase().contains(lowerQuery) ||
            (t.description?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }

  @override
  Future<Tenant> updateTenant(Tenant tenant) async {
    _tenants[tenant.id] = tenant;
    return tenant;
  }

  @override
  Future<bool> deleteTenant(String tenantId) async {
    return _tenants.remove(tenantId) != null;
  }

  @override
  Future<bool> suspendTenant(String tenantId) async {
    final tenant = _tenants[tenantId];
    if (tenant != null) {
      _tenants[tenantId] = tenant.copyWith(status: TenantStatus.suspended);
      return true;
    }
    return false;
  }

  @override
  Future<bool> reactivateTenant(String tenantId) async {
    final tenant = _tenants[tenantId];
    if (tenant != null) {
      _tenants[tenantId] = tenant.copyWith(status: TenantStatus.active);
      return true;
    }
    return false;
  }

  @override
  Future<int> getTenantCount() async => _tenants.length;

  @override
  Future<int> getActiveTenantCount() async {
    return _tenants.values.where((t) => t.isActive).length;
  }

  @override
  Future<List<Tenant>> getAllTenants({int limit = 100, int offset = 0}) async {
    final all = _tenants.values.toList();
    return all.skip(offset).take(limit).toList();
  }

  @override
  Future<bool> isTenantNameUnique(String name) async {
    return !_tenants.values.any((t) => t.name == name);
  }

  @override
  Future<Tenant?> getTenantByName(String name) async {
    return _tenants.values.cast<Tenant?>().firstWhere(
        (t) => t?.name == name,
        orElse: () => null);
  }

  // ---- Admin Management ----
  @override
  Future<TenantAdmin> grantAdminAccess(TenantAdmin admin) async {
    _admins[admin.id] = admin;
    return admin;
  }

  @override
  Future<TenantAdmin?> getAdminById(String adminId) async => _admins[adminId];

  @override
  Future<List<TenantAdmin>> getAdminsByTenant(String tenantId) async {
    return _admins.values.where((a) => a.tenantId == tenantId).toList();
  }

  @override
  Future<List<TenantAdmin>> getAdminsByUser(String userId) async {
    return _admins.values.where((a) => a.userId == userId).toList();
  }

  @override
  Future<TenantAdmin> updateAdminAccess(TenantAdmin admin) async {
    _admins[admin.id] = admin;
    return admin;
  }

  @override
  Future<bool> revokeAdminAccess(String adminId) async {
    final admin = _admins[adminId];
    if (admin != null) {
      _admins[adminId] = TenantAdmin(
        id: admin.id,
        tenantId: admin.tenantId,
        userId: admin.userId,
        accessLevel: admin.accessLevel,
        grantedAt: admin.grantedAt,
        revokedAt: DateTime.now(),
        notes: admin.notes,
      );
      return true;
    }
    return false;
  }

  @override
  Future<int> getAdminCountForTenant(String tenantId) async {
    return _admins.values.where((a) => a.tenantId == tenantId).length;
  }

  @override
  Future<List<TenantAdmin>> getActiveAdmins(String tenantId) async {
    return _admins.values
        .where((a) => a.tenantId == tenantId && a.isActive)
        .toList();
  }

  @override
  Future<TenantAdmin?> getTenantOwner(String tenantId) async {
    return _admins.values.cast<TenantAdmin?>().firstWhere(
        (a) => a?.tenantId == tenantId && a?.isOwner == true,
        orElse: () => null);
  }

  @override
  Future<bool> hasAdminAccess(String tenantId, String userId) async {
    return _admins.values.any((a) => a.tenantId == tenantId && a.userId == userId && a.isActive);
  }

  // ---- Audit Logging ----
  @override
  Future<TenantAuditLog> logAction(TenantAuditLog log) async {
    _auditLogs[log.id] = log;
    return log;
  }

  @override
  Future<TenantAuditLog?> getAuditLogById(String logId) async => _auditLogs[logId];

  @override
  Future<List<TenantAuditLog>> getAuditLogsByTenant(String tenantId) async {
    return _auditLogs.values.where((l) => l.tenantId == tenantId).toList();
  }

  @override
  Future<List<TenantAuditLog>> getAuditLogsByUser(String userId, String tenantId) async {
    return _auditLogs.values
        .where((l) => l.tenantId == tenantId && l.userId == userId)
        .toList();
  }

  @override
  Future<List<TenantAuditLog>> getAuditLogsByAction(String tenantId, String action) async {
    return _auditLogs.values
        .where((l) => l.tenantId == tenantId && l.action == action)
        .toList();
  }

  @override
  Future<int> getAuditLogCount(String tenantId) async {
    return _auditLogs.values.where((l) => l.tenantId == tenantId).length;
  }

  @override
  Future<List<TenantAuditLog>> getRecentAuditLogs(String tenantId, {int limit = 50}) async {
    final logs = _auditLogs.values
        .where((l) => l.tenantId == tenantId)
        .toList();
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs.take(limit).toList();
  }

  @override
  Future<bool> deleteOldAuditLogs(String tenantId, Duration olderThan) async {
    final cutoff = DateTime.now().subtract(olderThan);
    final keysToRemove = _auditLogs.entries
        .where((e) => e.value.tenantId == tenantId && e.value.timestamp.isBefore(cutoff))
        .map((e) => e.key)
        .toList();
    for (final key in keysToRemove) {
      _auditLogs.remove(key);
    }
    return keysToRemove.isNotEmpty;
  }

  // ---- Isolation Policy ----
  @override
  Future<IsolationPolicy> createIsolationPolicy(IsolationPolicy policy) async {
    _policies[policy.id] = policy;
    return policy;
  }

  @override
  Future<IsolationPolicy?> getPolicyById(String policyId) async => _policies[policyId];

  @override
  Future<IsolationPolicy?> getPolicyByTenant(String tenantId) async {
    return _policies.values.cast<IsolationPolicy?>().firstWhere(
        (p) => p?.tenantId == tenantId,
        orElse: () => null);
  }

  @override
  Future<IsolationPolicy> updatePolicy(IsolationPolicy policy) async {
    _policies[policy.id] = policy;
    return policy;
  }

  @override
  Future<bool> deletePolicy(String policyId) async {
    return _policies.remove(policyId) != null;
  }

  @override
  Future<List<IsolationPolicy>> getPoliciesByLevel(IsolationLevel level) async {
    return _policies.values.where((p) => p.level == level).toList();
  }

  @override
  Future<bool> enforcePolicyEncryption(String tenantId) async {
    final policy = await getPolicyByTenant(tenantId);
    if (policy != null) {
      await updatePolicy(policy.copyWith(enforceDataEncryption: true));
      return true;
    }
    return false;
  }

  @override
  Future<bool> enforcePolicyNetworkIsolation(String tenantId) async {
    final policy = await getPolicyByTenant(tenantId);
    if (policy != null) {
      await updatePolicy(policy.copyWith(enforceNetworkIsolation: true));
      return true;
    }
    return false;
  }

  // ---- Access Control ----
  @override
  Future<AccessControl> grantAccess(AccessControl control) async {
    _accessControls[control.id] = control;
    return control;
  }

  @override
  Future<AccessControl?> getAccessById(String accessId) async => _accessControls[accessId];

  @override
  Future<List<AccessControl>> getAccessByUser(String userId, String tenantId) async {
    return _accessControls.values
        .where((a) => a.userId == userId && a.tenantId == tenantId)
        .toList();
  }

  @override
  Future<List<AccessControl>> getAccessByResource(String tenantId, String resourceType, String resourceId) async {
    return _accessControls.values
        .where((a) => a.tenantId == tenantId && a.resourceType == resourceType && a.resourceId == resourceId)
        .toList();
  }

  @override
  Future<AccessControl> updateAccess(AccessControl control) async {
    _accessControls[control.id] = control;
    return control;
  }

  @override
  Future<bool> revokeAccess(String accessId) async {
    return _accessControls.remove(accessId) != null;
  }

  @override
  Future<bool> revokeAccessByUser(String userId, String tenantId) async {
    final keysToRemove = _accessControls.entries
        .where((e) => e.value.userId == userId && e.value.tenantId == tenantId)
        .map((e) => e.key)
        .toList();
    for (final key in keysToRemove) {
      _accessControls.remove(key);
    }
    return keysToRemove.isNotEmpty;
  }

  @override
  Future<int> getAccessCountForUser(String userId, String tenantId) async {
    return _accessControls.values
        .where((a) => a.userId == userId && a.tenantId == tenantId)
        .length;
  }

  @override
  Future<bool> hasPermission(String userId, String tenantId, String resourceId, String permission) async {
    return _accessControls.values.any((a) =>
        a.userId == userId &&
        a.tenantId == tenantId &&
        a.resourceId == resourceId &&
        a.permission == permission &&
        a.isActive);
  }

  @override
  Future<List<AccessControl>> getAccessByPermission(String tenantId, String permission) async {
    return _accessControls.values
        .where((a) => a.tenantId == tenantId && a.permission == permission)
        .toList();
  }

  @override
  Future<List<AccessControl>> getExpiringAccess(String tenantId, {Duration withinDays = const Duration(days: 7)}) async {
    final cutoff = DateTime.now().add(withinDays);
    return _accessControls.values
        .where((a) => a.tenantId == tenantId && a.expiresAt != null && a.expiresAt!.isBefore(cutoff))
        .toList();
  }

  @override
  Future<bool> revokeExpiredAccess(String tenantId) async {
    final now = DateTime.now();
    final keysToRemove = _accessControls.entries
        .where((e) => e.value.tenantId == tenantId && e.value.isExpired)
        .map((e) => e.key)
        .toList();
    for (final key in keysToRemove) {
      _accessControls.remove(key);
    }
    return keysToRemove.isNotEmpty;
  }

  // ---- Resource Quota ----
  @override
  Future<ResourceQuota> createQuota(ResourceQuota quota) async {
    _quotas[quota.id] = quota;
    return quota;
  }

  @override
  Future<ResourceQuota?> getQuotaById(String quotaId) async => _quotas[quotaId];

  @override
  Future<ResourceQuota?> getQuotaByTenant(String tenantId, String resourceType) async {
    return _quotas.values.cast<ResourceQuota?>().firstWhere(
        (q) => q?.tenantId == tenantId && q?.resourceType == resourceType,
        orElse: () => null);
  }

  @override
  Future<List<ResourceQuota>> getQuotasByTenant(String tenantId) async {
    return _quotas.values.where((q) => q.tenantId == tenantId).toList();
  }

  @override
  Future<ResourceQuota> updateQuota(ResourceQuota quota) async {
    _quotas[quota.id] = quota;
    return quota;
  }

  @override
  Future<bool> incrementUsage(String quotaId, double amount) async {
    final quota = _quotas[quotaId];
    if (quota != null) {
      _quotas[quotaId] = ResourceQuota(
        id: quota.id,
        tenantId: quota.tenantId,
        resourceType: quota.resourceType,
        quotaLimit: quota.quotaLimit,
        currentUsage: quota.currentUsage + amount,
        resetDate: quota.resetDate,
        alertThresholdPercent: quota.alertThresholdPercent,
        hardLimit: quota.hardLimit,
      );
      return true;
    }
    return false;
  }

  @override
  Future<bool> decrementUsage(String quotaId, double amount) async {
    final quota = _quotas[quotaId];
    if (quota != null) {
      _quotas[quotaId] = ResourceQuota(
        id: quota.id,
        tenantId: quota.tenantId,
        resourceType: quota.resourceType,
        quotaLimit: quota.quotaLimit,
        currentUsage: (quota.currentUsage - amount).clamp(0, quota.quotaLimit),
        resetDate: quota.resetDate,
        alertThresholdPercent: quota.alertThresholdPercent,
        hardLimit: quota.hardLimit,
      );
      return true;
    }
    return false;
  }

  @override
  Future<List<ResourceQuota>> getQuotasAboveThreshold(String tenantId, double thresholdPercent) async {
    return _quotas.values
        .where((q) => q.tenantId == tenantId && q.usagePercent >= thresholdPercent)
        .toList();
  }

  // ---- Data Residency ----
  @override
  Future<DataResidencyPolicy> createPolicy(DataResidencyPolicy policy) async {
    _residencyPolicies[policy.id] = policy;
    return policy;
  }

  @override
  Future<DataResidencyPolicy?> getPolicyById(String policyId) async => _residencyPolicies[policyId];

  @override
  Future<DataResidencyPolicy?> getPolicyByTenant(String tenantId) async {
    return _residencyPolicies.values.cast<DataResidencyPolicy?>().firstWhere(
        (p) => p?.tenantId == tenantId,
        orElse: () => null);
  }

  @override
  Future<DataResidencyPolicy> updatePolicy(DataResidencyPolicy policy) async {
    _residencyPolicies[policy.id] = policy;
    return policy;
  }

  @override
  Future<bool> deletePolicy(String policyId) async {
    return _residencyPolicies.remove(policyId) != null;
  }

  @override
  Future<List<DataResidencyPolicy>> getPoliciesByRegion(DataResidencyRegion region) async {
    return _residencyPolicies.values.where((p) => p.allowedRegions.contains(region)).toList();
  }

  @override
  Future<bool> isRegionAllowed(String tenantId, DataResidencyRegion region) async {
    final policy = await getPolicyByTenant(tenantId);
    return policy?.allowedRegions.contains(region) ?? false;
  }

  @override
  Future<bool> canReplicateToRegion(String tenantId, DataResidencyRegion region) async {
    final policy = await getPolicyByTenant(tenantId);
    return policy?.allowMultiRegionReplication == true && policy?.allowedRegions.contains(region) == true;
  }

  // ---- Cross-Tenant Requests ----
  @override
  Future<CrossTenantRequest> createRequest(CrossTenantRequest request) async {
    _crossTenantRequests[request.id] = request;
    return request;
  }

  @override
  Future<CrossTenantRequest?> getRequestById(String requestId) async => _crossTenantRequests[requestId];

  @override
  Future<List<CrossTenantRequest>> getRequestsBySource(String sourceTenantId) async {
    return _crossTenantRequests.values.where((r) => r.sourceTenantId == sourceTenantId).toList();
  }

  @override
  Future<List<CrossTenantRequest>> getRequestsByTarget(String targetTenantId) async {
    return _crossTenantRequests.values.where((r) => r.targetTenantId == targetTenantId).toList();
  }

  @override
  Future<CrossTenantRequest> approveRequest(String requestId) async {
    final request = _crossTenantRequests[requestId];
    if (request != null) {
      final approved = CrossTenantRequest(
        id: request.id,
        sourceTenantId: request.sourceTenantId,
        targetTenantId: request.targetTenantId,
        requestType: request.requestType,
        status: 'approved',
        createdAt: request.createdAt,
        approvedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        reason: request.reason,
      );
      _crossTenantRequests[requestId] = approved;
      return approved;
    }
    throw Exception('Request not found');
  }

  @override
  Future<bool> rejectRequest(String requestId) async {
    final request = _crossTenantRequests[requestId];
    if (request != null) {
      final rejected = CrossTenantRequest(
        id: request.id,
        sourceTenantId: request.sourceTenantId,
        targetTenantId: request.targetTenantId,
        requestType: request.requestType,
        status: 'rejected',
        createdAt: request.createdAt,
        reason: request.reason,
      );
      _crossTenantRequests[requestId] = rejected;
      return true;
    }
    return false;
  }

  // ---- Tenant Metrics ----
  @override
  Future<TenantMetrics> recordMetrics(TenantMetrics metrics) async {
    _metrics[metrics.id] = metrics;
    return metrics;
  }

  @override
  Future<TenantMetrics?> getLatestMetrics(String tenantId) async {
    final allMetrics = _metrics.values.where((m) => m.tenantId == tenantId).toList();
    if (allMetrics.isEmpty) return null;
    allMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return allMetrics.first;
  }

  @override
  Future<List<TenantMetrics>> getMetricsHistory(String tenantId, Duration period) async {
    final cutoff = DateTime.now().subtract(period);
    return _metrics.values
        .where((m) => m.tenantId == tenantId && m.timestamp.isAfter(cutoff))
        .toList();
  }

  @override
  Future<double> getAverageApiCalls(String tenantId, Duration period) async {
    final history = await getMetricsHistory(tenantId, period);
    if (history.isEmpty) return 0;
    return history.map((m) => m.apiCallCount).reduce((a, b) => a + b) / history.length;
  }

  @override
  Future<double> getAverageActiveUsers(String tenantId, Duration period) async {
    final history = await getMetricsHistory(tenantId, period);
    if (history.isEmpty) return 0;
    return history.map((m) => m.activeUsers).reduce((a, b) => a + b) / history.length;
  }

  @override
  Future<List<TenantMetrics>> getHighResourceUsageTenants(double threshold) async {
    return _metrics.values
        .where((m) => m.totalResourceUsagePercent > threshold)
        .toList();
  }

  // ---- Compliance & Health ----
  @override
  Future<ComplianceProfile> createProfile(ComplianceProfile profile) async {
    _complianceProfiles[profile.id] = profile;
    return profile;
  }

  @override
  Future<ComplianceProfile?> getProfileByTenant(String tenantId) async {
    return _complianceProfiles.values.cast<ComplianceProfile?>().firstWhere(
        (p) => p?.tenantId == tenantId,
        orElse: () => null);
  }

  @override
  Future<ComplianceProfile> updateProfile(ComplianceProfile profile) async {
    _complianceProfiles[profile.id] = profile;
    return profile;
  }

  @override
  Future<TenantHealthCheck> recordHealthCheck(TenantHealthCheck check) async {
    final checkId = check.id;
    final existing = _metrics[checkId] as TenantHealthCheck?;

    // Simple health check storage (could use separate map)
    if (existing != null) {
      final updated = TenantHealthCheck(
        id: check.id,
        tenantId: check.tenantId,
        timestamp: check.timestamp,
        status: check.status,
        responseTimeMs: check.responseTimeMs,
        errorMessage: check.errorMessage,
        failureCount: check.failureCount + (existing.failureCount),
        consecutiveFailures: check.status == 'unhealthy' ? existing.consecutiveFailures + 1 : 0,
      );
      _metrics[checkId] = updated;
      return updated;
    }
    _metrics[checkId] = check;
    return check;
  }

  @override
  Future<TenantHealthCheck?> getLatestHealthCheck(String tenantId) async {
    // This is a simplified implementation
    return null;
  }

  @override
  Future<List<TenantHealthCheck>> getHealthCheckHistory(String tenantId, Duration period) async {
    // Simplified implementation
    return [];
  }

  @override
  Future<List<String>> getUnhealthyTenants() async {
    // Simplified implementation
    return [];
  }
}

// ============================================================================
// EXTENSION METHODS FOR ISOLATION POLICY
// ============================================================================

extension on IsolationPolicy {
  IsolationPolicy copyWith({
    String? id,
    String? tenantId,
    IsolationLevel? level,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? enforceDataEncryption,
    bool? enforceNetworkIsolation,
    bool? allowCrossTenantAccess,
    int? encryptionKeyRotationDays,
  }) {
    return IsolationPolicy(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      enforceDataEncryption: enforceDataEncryption ?? this.enforceDataEncryption,
      enforceNetworkIsolation: enforceNetworkIsolation ?? this.enforceNetworkIsolation,
      allowCrossTenantAccess: allowCrossTenantAccess ?? this.allowCrossTenantAccess,
      encryptionKeyRotationDays: encryptionKeyRotationDays ?? this.encryptionKeyRotationDays,
    );
  }
}

// ============================================================================
// ENGINES (5 total)
// ============================================================================

/// TenantIsolationEngine: Handles multi-tenant isolation and compliance
class TenantIsolationEngine {
  final MultiTenantRepository repository;

  TenantIsolationEngine(this.repository);

  Future<bool> enforceIsolation(String tenantId) async {
    final policy = await repository.getPolicyByTenant(tenantId);
    if (policy != null && policy.level == IsolationLevel.strict) {
      await repository.enforcePolicyEncryption(tenantId);
      await repository.enforcePolicyNetworkIsolation(tenantId);
      return true;
    }
    return false;
  }

  Future<int> getIsolationScore(String tenantId) async {
    int score = 0;
    final policy = await repository.getPolicyByTenant(tenantId);
    if (policy != null) {
      if (policy.enforceDataEncryption) score += 25;
      if (policy.enforceNetworkIsolation) score += 25;
      if (policy.level == IsolationLevel.strict) score += 25;
      if (!policy.allowCrossTenantAccess) score += 25;
    }
    return score;
  }
}

/// AccessControlEngine: Manages access permissions and role-based control
class AccessControlEngine {
  final MultiTenantRepository repository;

  AccessControlEngine(this.repository);

  Future<bool> grantPermission(String userId, String tenantId, String resourceId, String permission) async {
    final control = AccessControl(
      id: 'ac_${DateTime.now().millisecondsSinceEpoch}',
      tenantId: tenantId,
      userId: userId,
      resourceType: 'resource',
      resourceId: resourceId,
      permission: permission,
      grantedAt: DateTime.now(),
    );
    await repository.grantAccess(control);
    return true;
  }

  Future<bool> enforceAccessRules(String tenantId) async {
    await repository.revokeExpiredAccess(tenantId);
    return true;
  }

  Future<int> getAccessControlCount(String tenantId) async {
    final admins = await repository.getAdminsByTenant(tenantId);
    final accesses = await repository.getAccessByResource(tenantId, '', '');
    return admins.length + accesses.length;
  }
}

/// ResourceQuotaEngine: Monitors and enforces resource quotas
class ResourceQuotaEngine {
  final MultiTenantRepository repository;

  ResourceQuotaEngine(this.repository);

  Future<bool> checkQuotaAvailability(String tenantId, String resourceType, double requiredAmount) async {
    final quota = await repository.getQuotaByTenant(tenantId, resourceType);
    if (quota == null) return true;

    if (quota.hardLimit && quota.currentUsage + requiredAmount > quota.quotaLimit) {
      return false;
    }
    return true;
  }

  Future<double> getTotalQuotaUsagePercent(String tenantId) async {
    final quotas = await repository.getQuotasByTenant(tenantId);
    if (quotas.isEmpty) return 0;
    return quotas.map((q) => q.usagePercent).reduce((a, b) => a + b) / quotas.length;
  }

  Future<int> getCriticalQuotaCount(String tenantId) async {
    return (await repository.getQuotasAboveThreshold(tenantId, 90)).length;
  }
}

/// ComplianceEngine: Ensures compliance with regulations and standards
class ComplianceEngine {
  final MultiTenantRepository repository;

  ComplianceEngine(this.repository);

  Future<bool> validateCompliance(String tenantId) async {
    final profile = await repository.getProfileByTenant(tenantId);
    return profile?.isCompliant ?? false;
  }

  Future<int> getComplianceScore(String tenantId) async {
    int score = 50;
    final profile = await repository.getProfileByTenant(tenantId);
    if (profile != null) {
      if (profile.isCompliant) score += 25;
      score += (profile.certificationCount * 5).clamp(0, 25);
    }
    return score;
  }

  Future<bool> scheduleAudit(String tenantId) async {
    final profile = await repository.getProfileByTenant(tenantId);
    if (profile != null) {
      final updated = ComplianceProfile(
        id: profile.id,
        tenantId: profile.tenantId,
        complianceFrameworks: profile.complianceFrameworks,
        createdAt: profile.createdAt,
        updatedAt: DateTime.now(),
        certifications: profile.certifications,
        auditDate: DateTime.now(),
        nextAuditDate: DateTime.now().add(const Duration(days: 365)),
        isCompliant: profile.isCompliant,
      );
      await repository.updateProfile(updated);
      return true;
    }
    return false;
  }
}

/// AuditLoggingEngine: Maintains comprehensive audit trails
class AuditLoggingEngine {
  final MultiTenantRepository repository;

  AuditLoggingEngine(this.repository);

  Future<void> logTenantAction(String tenantId, String userId, String action, String resourceType, String resourceId) async {
    final log = TenantAuditLog(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
      tenantId: tenantId,
      userId: userId,
      action: action,
      resourceType: resourceType,
      resourceId: resourceId,
      timestamp: DateTime.now(),
      status: 'success',
    );
    await repository.logAction(log);
  }

  Future<int> getAuditLogCount(String tenantId) async {
    return await repository.getAuditLogCount(tenantId);
  }

  Future<List<String>> getRecentActions(String tenantId, {int limit = 10}) async {
    final logs = await repository.getRecentAuditLogs(tenantId, limit: limit);
    return logs.map((l) => l.action).toList();
  }
}

// ============================================================================
// MANAGER
// ============================================================================

/// MultiTenantManager: Coordinates all engines
class MultiTenantManager {
  final MultiTenantRepository repository;
  final TenantIsolationEngine isolationEngine;
  final AccessControlEngine accessEngine;
  final ResourceQuotaEngine quotaEngine;
  final ComplianceEngine complianceEngine;
  final AuditLoggingEngine auditEngine;

  MultiTenantManager(
    this.repository, {
    TenantIsolationEngine? isolationEngine,
    AccessControlEngine? accessEngine,
    ResourceQuotaEngine? quotaEngine,
    ComplianceEngine? complianceEngine,
    AuditLoggingEngine? auditEngine,
  })  : isolationEngine = isolationEngine ?? TenantIsolationEngine(repository),
        accessEngine = accessEngine ?? AccessControlEngine(repository),
        quotaEngine = quotaEngine ?? ResourceQuotaEngine(repository),
        complianceEngine = complianceEngine ?? ComplianceEngine(repository),
        auditEngine = auditEngine ?? AuditLoggingEngine(repository);

  Future<Tenant> setupNewTenant(Tenant tenant) async {
    final createdTenant = await repository.createTenant(tenant);

    final policy = IsolationPolicy(
      id: 'policy_${tenant.id}',
      tenantId: tenant.id,
      level: tenant.isolationLevel,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await repository.createIsolationPolicy(policy);

    return createdTenant;
  }
}

// ============================================================================
// FACADE (Public API)
// ============================================================================

class MultiTenantFacade {
  final MultiTenantManager manager;

  MultiTenantFacade(this.manager);

  Future<Tenant> createTenant(String name, String organizationId, TenantTier tier) async {
    final tenant = Tenant(
      id: 'tenant_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      organizationId: organizationId,
      status: TenantStatus.active,
      tier: tier,
      isolationLevel: tier == TenantTier.enterprise ? IsolationLevel.strict : IsolationLevel.logical,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return manager.setupNewTenant(tenant);
  }

  Future<int> getActiveTenantCount() async {
    return await manager.repository.getActiveTenantCount();
  }

  Future<int> getTotalTenantCount() async {
    return await manager.repository.getTenantCount();
  }

  Future<double> getAverageIsolationScore() async {
    final tenants = await manager.repository.getAllTenants(limit: 1000);
    if (tenants.isEmpty) return 0;
    double total = 0;
    for (final tenant in tenants) {
      total += await manager.isolationEngine.getIsolationScore(tenant.id);
    }
    return total / tenants.length;
  }

  Future<int> getCriticalComplianceIssuesCount() async {
    final tenants = await manager.repository.getAllTenants(limit: 1000);
    int count = 0;
    for (final tenant in tenants) {
      final isCompliant = await manager.complianceEngine.validateCompliance(tenant.id);
      if (!isCompliant) count++;
    }
    return count;
  }

  Future<bool> grantUserAccess(String tenantId, String userId, String resourceId, String permission) async {
    return await manager.accessEngine.grantPermission(userId, tenantId, resourceId, permission);
  }

  Future<double> getSystemQuotaUsage() async {
    final tenants = await manager.repository.getAllTenants(limit: 1000);
    if (tenants.isEmpty) return 0;
    double total = 0;
    for (final tenant in tenants) {
      total += await manager.quotaEngine.getTotalQuotaUsagePercent(tenant.id);
    }
    return total / tenants.length;
  }

  Future<int> getUnhealthyTenantsCount() async {
    return (await manager.repository.getUnhealthyTenants()).length;
  }
}
