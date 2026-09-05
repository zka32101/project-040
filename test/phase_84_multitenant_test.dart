import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/multitenant_models.dart';
import 'package:project_040/services/multitenant_service.dart';

void main() {
  late MultiTenantRepository repository;
  late MultiTenantManager manager;
  late MultiTenantFacade facade;

  setUp(() {
    repository = InMemoryMultiTenantRepository();
    manager = MultiTenantManager(repository);
    facade = MultiTenantFacade(manager);
  });

  // ============================================================================
  // ENUM TESTS (6)
  // ============================================================================

  group('Enum Tests', () {
    test('TenantStatus has 4 values', () {
      expect(TenantStatus.values.length, equals(4));
      expect(TenantStatus.active.displayName, equals('アクティブ'));
    });

    test('IsolationLevel has 4 values', () {
      expect(IsolationLevel.values.length, equals(4));
      expect(IsolationLevel.strict.displayName, equals('厳密分離'));
    });

    test('TenantTier has 5 values', () {
      expect(TenantTier.values.length, equals(5));
      expect(TenantTier.enterprise.displayName, equals('エンタープライズ'));
    });

    test('AccessLevel has 5 values', () {
      expect(AccessLevel.values.length, equals(5));
      expect(AccessLevel.owner.displayName, equals('オーナー'));
    });

    test('DataResidencyRegion has 5 values', () {
      expect(DataResidencyRegion.values.length, equals(5));
      expect(DataResidencyRegion.euCentral.displayName, equals('EU Central'));
    });

    test('SharingPermissionType has 5 values', () {
      expect(SharingPermissionType.values.length, equals(5));
      expect(SharingPermissionType.public.displayName, equals('公開'));
    });
  });

  // ============================================================================
  // MODEL TESTS (12)
  // ============================================================================

  group('Model Tests', () {
    test('Tenant model with defaults', () {
      final tenant = Tenant(
        id: 't1',
        name: 'Test Tenant',
        organizationId: 'org1',
        status: TenantStatus.active,
        tier: TenantTier.professional,
        isolationLevel: IsolationLevel.hybrid,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(tenant.isActive, isTrue);
      expect(tenant.isEnterprise, isFalse);
      expect(tenant.ageInDays, greaterThan(0));
    });

    test('Tenant copyWith method', () {
      final tenant = Tenant(
        id: 't1',
        name: 'Test',
        organizationId: 'org1',
        status: TenantStatus.active,
        tier: TenantTier.free,
        isolationLevel: IsolationLevel.logical,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = tenant.copyWith(status: TenantStatus.suspended, tier: TenantTier.enterprise);
      expect(updated.status, equals(TenantStatus.suspended));
      expect(updated.isEnterprise, isTrue);
      expect(updated.id, equals(tenant.id));
    });

    test('TenantAdmin active check', () {
      final admin = TenantAdmin(
        id: 'admin1',
        tenantId: 't1',
        userId: 'u1',
        accessLevel: AccessLevel.owner,
        grantedAt: DateTime.now(),
      );

      expect(admin.isActive, isTrue);
      expect(admin.isOwner, isTrue);
    });

    test('TenantAuditLog age calculation', () {
      final log = TenantAuditLog(
        id: 'log1',
        tenantId: 't1',
        userId: 'u1',
        action: 'create',
        resourceType: 'tenant',
        resourceId: 't1',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      );

      expect(log.isSuccess, isTrue);
      expect(log.ageInHours, greaterThan(4));
    });

    test('IsolationPolicy strictness check', () {
      final policy = IsolationPolicy(
        id: 'p1',
        tenantId: 't1',
        level: IsolationLevel.strict,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        enforceDataEncryption: true,
        enforceNetworkIsolation: true,
      );

      expect(policy.isStrictlyIsolated, isTrue);
    });

    test('AccessControl expiration check', () {
      final future = DateTime.now().add(const Duration(days: 5));
      final control = AccessControl(
        id: 'ac1',
        tenantId: 't1',
        userId: 'u1',
        resourceType: 'resource',
        resourceId: 'r1',
        permission: 'read',
        grantedAt: DateTime.now(),
        expiresAt: future,
      );

      expect(control.isActive, isTrue);
      expect(control.expiresInDays, greaterThan(0));
    });

    test('ResourceQuota usage percentage', () {
      final quota = ResourceQuota(
        id: 'q1',
        tenantId: 't1',
        resourceType: 'storage',
        quotaLimit: 1000,
        currentUsage: 800,
        resetDate: DateTime.now().add(const Duration(days: 30)),
      );

      expect(quota.usagePercent, equals(80));
      expect(quota.shouldAlert, isTrue);
      expect(quota.isExceeded, isFalse);
    });

    test('DataResidencyPolicy validation', () {
      final policy = DataResidencyPolicy(
        id: 'drp1',
        tenantId: 't1',
        allowedRegions: [DataResidencyRegion.usEast, DataResidencyRegion.euCentral],
        primaryRegion: DataResidencyRegion.usEast,
        createdAt: DateTime.now(),
      );

      expect(policy.isPrimaryInRegion, isTrue);
      expect(policy.totalRegionCount, equals(2));
    });

    test('CrossTenantRequest validity', () {
      final request = CrossTenantRequest(
        id: 'ctr1',
        sourceTenantId: 't1',
        targetTenantId: 't2',
        requestType: 'share',
        status: 'approved',
        createdAt: DateTime.now(),
        approvedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 10)),
      );

      expect(request.isApproved, isTrue);
      expect(request.isValid, isTrue);
    });

    test('TenantMetrics resource usage calculation', () {
      final metrics = TenantMetrics(
        id: 'm1',
        tenantId: 't1',
        timestamp: DateTime.now(),
        activeUsers: 50,
        apiCallCount: 10000,
        storageUsedGb: 500,
        cpuUsagePercent: 75,
        memoryUsagePercent: 85,
      );

      expect(metrics.totalResourceUsagePercent, equals(80));
      expect(metrics.isMemoryHigh, isTrue);
      expect(metrics.isCpuHigh, isTrue);
    });

    test('ComplianceProfile audit tracking', () {
      final profile = ComplianceProfile(
        id: 'cp1',
        tenantId: 't1',
        complianceFrameworks: ['SOC2', 'GDPR'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        certifications: ['ISO27001', 'HIPAA'],
        isCompliant: true,
      );

      expect(profile.frameworkCount, equals(2));
      expect(profile.certificationCount, equals(2));
    });

    test('SharingRule permission levels', () {
      final rule = SharingRule(
        id: 'sr1',
        tenantId: 't1',
        resourceType: 'project',
        resourceId: 'p1',
        grantedTenantId: 't2',
        permissionType: SharingPermissionType.public,
        createdAt: DateTime.now(),
      );

      expect(rule.isFullyOpen, isTrue);
      expect(rule.isActive, isTrue);
    });

    test('TenantHealthCheck status', () {
      final check = TenantHealthCheck(
        id: 'hc1',
        tenantId: 't1',
        timestamp: DateTime.now(),
        status: 'healthy',
        responseTimeMs: 1000,
      );

      expect(check.isHealthy, isTrue);
      expect(check.isSlowResponse, isFalse);
    });
  });

  // ============================================================================
  // REPOSITORY TESTS (40+)
  // ============================================================================

  group('Repository: Tenant Management', () {
    test('createTenant and getTenantById', () async {
      final tenant = Tenant(
        id: 't1',
        name: 'Tenant A',
        organizationId: 'org1',
        status: TenantStatus.active,
        tier: TenantTier.starter,
        isolationLevel: IsolationLevel.logical,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createTenant(tenant);
      final retrieved = await repository.getTenantById('t1');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Tenant A'));
    });

    test('getTenantsByOrganization', () async {
      final tenant1 = Tenant(
        id: 't1',
        name: 'T1',
        organizationId: 'org1',
        status: TenantStatus.active,
        tier: TenantTier.free,
        isolationLevel: IsolationLevel.logical,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final tenant2 = Tenant(
        id: 't2',
        name: 'T2',
        organizationId: 'org1',
        status: TenantStatus.active,
        tier: TenantTier.professional,
        isolationLevel: IsolationLevel.hybrid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createTenant(tenant1);
      await repository.createTenant(tenant2);
      final result = await repository.getTenantsByOrganization('org1');

      expect(result.length, equals(2));
    });

    test('getTenantsByStatus', () async {
      final tenant = Tenant(
        id: 't1',
        name: 'T1',
        organizationId: 'org1',
        status: TenantStatus.active,
        tier: TenantTier.free,
        isolationLevel: IsolationLevel.logical,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createTenant(tenant);
      final active = await repository.getTenantsByStatus(TenantStatus.active);

      expect(active.isNotEmpty, isTrue);
    });

    test('getTenantsByTier', () async {
      final tenant = Tenant(
        id: 't1',
        name: 'T1',
        organizationId: 'org1',
        status: TenantStatus.active,
        tier: TenantTier.enterprise,
        isolationLevel: IsolationLevel.strict,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createTenant(tenant);
      final enterprise = await repository.getTenantsByTier(TenantTier.enterprise);

      expect(enterprise.isNotEmpty, isTrue);
    });

    test('searchTenants', () async {
      final tenant = Tenant(
        id: 't1',
        name: 'Premium Customer',
        organizationId: 'org1',
        status: TenantStatus.active,
        tier: TenantTier.professional,
        isolationLevel: IsolationLevel.hybrid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: 'A premium account',
      );

      await repository.createTenant(tenant);
      final results = await repository.searchTenants('premium');

      expect(results.isNotEmpty, isTrue);
    });

    test('updateTenant', () async {
      var tenant = Tenant(
        id: 't1',
        name: 'T1',
        organizationId: 'org1',
        status: TenantStatus.active,
        tier: TenantTier.free,
        isolationLevel: IsolationLevel.logical,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createTenant(tenant);
      tenant = tenant.copyWith(tier: TenantTier.professional);
      await repository.updateTenant(tenant);

      final updated = await repository.getTenantById('t1');
      expect(updated!.tier, equals(TenantTier.professional));
    });

    test('deleteTenant', () async {
      final tenant = Tenant(
        id: 't1',
        name: 'T1',
        organizationId: 'org1',
        status: TenantStatus.active,
        tier: TenantTier.free,
        isolationLevel: IsolationLevel.logical,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createTenant(tenant);
      final result = await repository.deleteTenant('t1');

      expect(result, isTrue);
      expect(await repository.getTenantById('t1'), isNull);
    });

    test('suspendTenant', () async {
      final tenant = Tenant(
        id: 't1',
        name: 'T1',
        organizationId: 'org1',
        status: TenantStatus.active,
        tier: TenantTier.free,
        isolationLevel: IsolationLevel.logical,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createTenant(tenant);
      await repository.suspendTenant('t1');

      final suspended = await repository.getTenantById('t1');
      expect(suspended!.status, equals(TenantStatus.suspended));
    });

    test('getTenantCount', () async {
      for (int i = 0; i < 5; i++) {
        await repository.createTenant(Tenant(
          id: 't$i',
          name: 'T$i',
          organizationId: 'org1',
          status: TenantStatus.active,
          tier: TenantTier.free,
          isolationLevel: IsolationLevel.logical,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      final count = await repository.getTenantCount();
      expect(count, equals(5));
    });

    test('getActiveTenantCount', () async {
      for (int i = 0; i < 3; i++) {
        await repository.createTenant(Tenant(
          id: 't$i',
          name: 'T$i',
          organizationId: 'org1',
          status: TenantStatus.active,
          tier: TenantTier.free,
          isolationLevel: IsolationLevel.logical,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      final count = await repository.getActiveTenantCount();
      expect(count, equals(3));
    });

    test('isTenantNameUnique', () async {
      final tenant = Tenant(
        id: 't1',
        name: 'Unique Name',
        organizationId: 'org1',
        status: TenantStatus.active,
        tier: TenantTier.free,
        isolationLevel: IsolationLevel.logical,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createTenant(tenant);
      final isUnique = await repository.isTenantNameUnique('Unique Name');

      expect(isUnique, isFalse);
    });
  });

  group('Repository: Admin Management', () {
    test('grantAdminAccess', () async {
      final admin = TenantAdmin(
        id: 'admin1',
        tenantId: 't1',
        userId: 'u1',
        accessLevel: AccessLevel.owner,
        grantedAt: DateTime.now(),
      );

      final result = await repository.grantAdminAccess(admin);
      expect(result.id, equals('admin1'));
    });

    test('getAdminById', () async {
      final admin = TenantAdmin(
        id: 'admin1',
        tenantId: 't1',
        userId: 'u1',
        accessLevel: AccessLevel.admin,
        grantedAt: DateTime.now(),
      );

      await repository.grantAdminAccess(admin);
      final retrieved = await repository.getAdminById('admin1');

      expect(retrieved, isNotNull);
      expect(retrieved!.accessLevel, equals(AccessLevel.admin));
    });

    test('getAdminsByTenant', () async {
      for (int i = 0; i < 3; i++) {
        await repository.grantAdminAccess(TenantAdmin(
          id: 'admin$i',
          tenantId: 't1',
          userId: 'u$i',
          accessLevel: AccessLevel.admin,
          grantedAt: DateTime.now(),
        ));
      }

      final admins = await repository.getAdminsByTenant('t1');
      expect(admins.length, equals(3));
    });

    test('hasAdminAccess', () async {
      final admin = TenantAdmin(
        id: 'admin1',
        tenantId: 't1',
        userId: 'u1',
        accessLevel: AccessLevel.admin,
        grantedAt: DateTime.now(),
      );

      await repository.grantAdminAccess(admin);
      final hasAccess = await repository.hasAdminAccess('t1', 'u1');

      expect(hasAccess, isTrue);
    });

    test('revokeAdminAccess', () async {
      final admin = TenantAdmin(
        id: 'admin1',
        tenantId: 't1',
        userId: 'u1',
        accessLevel: AccessLevel.admin,
        grantedAt: DateTime.now(),
      );

      await repository.grantAdminAccess(admin);
      final revoked = await repository.revokeAdminAccess('admin1');

      expect(revoked, isTrue);
    });
  });

  group('Repository: Audit Logging', () {
    test('logAction', () async {
      final log = TenantAuditLog(
        id: 'log1',
        tenantId: 't1',
        userId: 'u1',
        action: 'create',
        resourceType: 'tenant',
        resourceId: 't1',
        timestamp: DateTime.now(),
      );

      final result = await repository.logAction(log);
      expect(result.action, equals('create'));
    });

    test('getAuditLogsByTenant', () async {
      for (int i = 0; i < 5; i++) {
        await repository.logAction(TenantAuditLog(
          id: 'log$i',
          tenantId: 't1',
          userId: 'u1',
          action: 'action$i',
          resourceType: 'resource',
          resourceId: 'r$i',
          timestamp: DateTime.now(),
        ));
      }

      final logs = await repository.getAuditLogsByTenant('t1');
      expect(logs.length, equals(5));
    });

    test('getRecentAuditLogs with limit', () async {
      for (int i = 0; i < 10; i++) {
        await repository.logAction(TenantAuditLog(
          id: 'log$i',
          tenantId: 't1',
          userId: 'u1',
          action: 'action',
          resourceType: 'resource',
          resourceId: 'r$i',
          timestamp: DateTime.now(),
        ));
      }

      final logs = await repository.getRecentAuditLogs('t1', limit: 5);
      expect(logs.length, lessThanOrEqualTo(5));
    });
  });

  group('Repository: Isolation Policy', () {
    test('createIsolationPolicy', () async {
      final policy = IsolationPolicy(
        id: 'p1',
        tenantId: 't1',
        level: IsolationLevel.strict,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repository.createIsolationPolicy(policy);
      expect(result.level, equals(IsolationLevel.strict));
    });

    test('getPolicyByTenant', () async {
      final policy = IsolationPolicy(
        id: 'p1',
        tenantId: 't1',
        level: IsolationLevel.hybrid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createIsolationPolicy(policy);
      final retrieved = await repository.getPolicyByTenant('t1');

      expect(retrieved, isNotNull);
      expect(retrieved!.level, equals(IsolationLevel.hybrid));
    });

    test('getPoliciesByLevel', () async {
      for (int i = 0; i < 2; i++) {
        await repository.createIsolationPolicy(IsolationPolicy(
          id: 'p$i',
          tenantId: 't$i',
          level: IsolationLevel.strict,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      final policies = await repository.getPoliciesByLevel(IsolationLevel.strict);
      expect(policies.length, equals(2));
    });
  });

  group('Repository: Access Control', () {
    test('grantAccess', () async {
      final control = AccessControl(
        id: 'ac1',
        tenantId: 't1',
        userId: 'u1',
        resourceType: 'resource',
        resourceId: 'r1',
        permission: 'read',
        grantedAt: DateTime.now(),
      );

      final result = await repository.grantAccess(control);
      expect(result.permission, equals('read'));
    });

    test('hasPermission', () async {
      final control = AccessControl(
        id: 'ac1',
        tenantId: 't1',
        userId: 'u1',
        resourceType: 'resource',
        resourceId: 'r1',
        permission: 'write',
        grantedAt: DateTime.now(),
      );

      await repository.grantAccess(control);
      final hasAccess = await repository.hasPermission('u1', 't1', 'r1', 'write');

      expect(hasAccess, isTrue);
    });

    test('revokeAccessByUser', () async {
      for (int i = 0; i < 3; i++) {
        await repository.grantAccess(AccessControl(
          id: 'ac$i',
          tenantId: 't1',
          userId: 'u1',
          resourceType: 'resource',
          resourceId: 'r$i',
          permission: 'read',
          grantedAt: DateTime.now(),
        ));
      }

      final revoked = await repository.revokeAccessByUser('u1', 't1');
      expect(revoked, isTrue);
    });

    test('getExpiringAccess', () async {
      final future = DateTime.now().add(const Duration(days: 5));
      await repository.grantAccess(AccessControl(
        id: 'ac1',
        tenantId: 't1',
        userId: 'u1',
        resourceType: 'resource',
        resourceId: 'r1',
        permission: 'read',
        grantedAt: DateTime.now(),
        expiresAt: future,
      ));

      final expiring = await repository.getExpiringAccess('t1', withinDays: const Duration(days: 10));
      expect(expiring.length, equals(1));
    });
  });

  group('Repository: Resource Quota', () {
    test('createQuota', () async {
      final quota = ResourceQuota(
        id: 'q1',
        tenantId: 't1',
        resourceType: 'storage',
        quotaLimit: 1000,
        currentUsage: 500,
        resetDate: DateTime.now().add(const Duration(days: 30)),
      );

      final result = await repository.createQuota(quota);
      expect(result.resourceType, equals('storage'));
    });

    test('incrementUsage', () async {
      final quota = ResourceQuota(
        id: 'q1',
        tenantId: 't1',
        resourceType: 'storage',
        quotaLimit: 1000,
        currentUsage: 500,
        resetDate: DateTime.now().add(const Duration(days: 30)),
      );

      await repository.createQuota(quota);
      await repository.incrementUsage('q1', 100);

      final updated = await repository.getQuotaById('q1');
      expect(updated!.currentUsage, equals(600));
    });

    test('getQuotasAboveThreshold', () async {
      for (int i = 0; i < 2; i++) {
        await repository.createQuota(ResourceQuota(
          id: 'q$i',
          tenantId: 't1',
          resourceType: 'storage',
          quotaLimit: 1000,
          currentUsage: 950,
          resetDate: DateTime.now().add(const Duration(days: 30)),
        ));
      }

      final aboveThreshold = await repository.getQuotasAboveThreshold('t1', 80);
      expect(aboveThreshold.length, equals(2));
    });
  });

  group('Repository: Data Residency', () {
    test('createPolicy', () async {
      final policy = DataResidencyPolicy(
        id: 'drp1',
        tenantId: 't1',
        allowedRegions: [DataResidencyRegion.usEast],
        primaryRegion: DataResidencyRegion.usEast,
        createdAt: DateTime.now(),
      );

      final result = await repository.createPolicy(policy);
      expect(result.primaryRegion, equals(DataResidencyRegion.usEast));
    });

    test('isRegionAllowed', () async {
      final policy = DataResidencyPolicy(
        id: 'drp1',
        tenantId: 't1',
        allowedRegions: [DataResidencyRegion.euCentral, DataResidencyRegion.usEast],
        primaryRegion: DataResidencyRegion.usEast,
        createdAt: DateTime.now(),
      );

      await repository.createPolicy(policy);
      final allowed = await repository.isRegionAllowed('t1', DataResidencyRegion.euCentral);

      expect(allowed, isTrue);
    });
  });

  group('Repository: Cross-Tenant Requests', () {
    test('createRequest', () async {
      final request = CrossTenantRequest(
        id: 'ctr1',
        sourceTenantId: 't1',
        targetTenantId: 't2',
        requestType: 'share',
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final result = await repository.createRequest(request);
      expect(result.status, equals('pending'));
    });

    test('approveRequest', () async {
      final request = CrossTenantRequest(
        id: 'ctr1',
        sourceTenantId: 't1',
        targetTenantId: 't2',
        requestType: 'share',
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await repository.createRequest(request);
      final approved = await repository.approveRequest('ctr1');

      expect(approved.status, equals('approved'));
      expect(approved.approvedAt, isNotNull);
    });

    test('rejectRequest', () async {
      final request = CrossTenantRequest(
        id: 'ctr1',
        sourceTenantId: 't1',
        targetTenantId: 't2',
        requestType: 'share',
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await repository.createRequest(request);
      final result = await repository.rejectRequest('ctr1');

      expect(result, isTrue);
    });
  });

  group('Repository: Tenant Metrics', () {
    test('recordMetrics', () async {
      final metrics = TenantMetrics(
        id: 'm1',
        tenantId: 't1',
        timestamp: DateTime.now(),
        activeUsers: 100,
        apiCallCount: 50000,
        storageUsedGb: 750,
        cpuUsagePercent: 60,
        memoryUsagePercent: 70,
      );

      final result = await repository.recordMetrics(metrics);
      expect(result.activeUsers, equals(100));
    });

    test('getLatestMetrics', () async {
      final metrics = TenantMetrics(
        id: 'm1',
        tenantId: 't1',
        timestamp: DateTime.now(),
        activeUsers: 50,
        apiCallCount: 10000,
        storageUsedGb: 500,
        cpuUsagePercent: 50,
        memoryUsagePercent: 60,
      );

      await repository.recordMetrics(metrics);
      final latest = await repository.getLatestMetrics('t1');

      expect(latest, isNotNull);
      expect(latest!.activeUsers, equals(50));
    });
  });

  group('Repository: Compliance', () {
    test('createProfile', () async {
      final profile = ComplianceProfile(
        id: 'cp1',
        tenantId: 't1',
        complianceFrameworks: ['SOC2', 'GDPR'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repository.createProfile(profile);
      expect(result.frameworkCount, equals(2));
    });

    test('getProfileByTenant', () async {
      final profile = ComplianceProfile(
        id: 'cp1',
        tenantId: 't1',
        complianceFrameworks: ['ISO27001'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createProfile(profile);
      final retrieved = await repository.getProfileByTenant('t1');

      expect(retrieved, isNotNull);
    });
  });

  // ============================================================================
  // ENGINE TESTS (5)
  // ============================================================================

  group('Engine: TenantIsolationEngine', () {
    test('enforceIsolation for strict level', () async {
      final tenant = Tenant(
        id: 't1',
        name: 'Test',
        organizationId: 'org1',
        status: TenantStatus.active,
        tier: TenantTier.enterprise,
        isolationLevel: IsolationLevel.strict,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.createTenant(tenant);

      final policy = IsolationPolicy(
        id: 'p1',
        tenantId: 't1',
        level: IsolationLevel.strict,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.createIsolationPolicy(policy);

      final result = await manager.isolationEngine.enforceIsolation('t1');
      expect(result, isTrue);
    });

    test('getIsolationScore', () async {
      final policy = IsolationPolicy(
        id: 'p1',
        tenantId: 't1',
        level: IsolationLevel.strict,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        enforceDataEncryption: true,
        enforceNetworkIsolation: true,
      );
      await repository.createIsolationPolicy(policy);

      final score = await manager.isolationEngine.getIsolationScore('t1');
      expect(score, greaterThan(0));
    });
  });

  group('Engine: AccessControlEngine', () {
    test('grantPermission', () async {
      final result = await manager.accessEngine.grantPermission('u1', 't1', 'r1', 'read');
      expect(result, isTrue);
    });

    test('enforceAccessRules', () async {
      final result = await manager.accessEngine.enforceAccessRules('t1');
      expect(result, isTrue);
    });
  });

  group('Engine: ResourceQuotaEngine', () {
    test('checkQuotaAvailability', () async {
      final quota = ResourceQuota(
        id: 'q1',
        tenantId: 't1',
        resourceType: 'storage',
        quotaLimit: 1000,
        currentUsage: 500,
        resetDate: DateTime.now().add(const Duration(days: 30)),
      );
      await repository.createQuota(quota);

      final available = await manager.quotaEngine.checkQuotaAvailability('t1', 'storage', 400);
      expect(available, isTrue);
    });

    test('getCriticalQuotaCount', () async {
      await repository.createQuota(ResourceQuota(
        id: 'q1',
        tenantId: 't1',
        resourceType: 'storage',
        quotaLimit: 1000,
        currentUsage: 950,
        resetDate: DateTime.now().add(const Duration(days: 30)),
      ));

      final count = await manager.quotaEngine.getCriticalQuotaCount('t1');
      expect(count, equals(1));
    });
  });

  group('Engine: ComplianceEngine', () {
    test('validateCompliance', () async {
      final profile = ComplianceProfile(
        id: 'cp1',
        tenantId: 't1',
        complianceFrameworks: ['SOC2'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCompliant: true,
      );
      await repository.createProfile(profile);

      final result = await manager.complianceEngine.validateCompliance('t1');
      expect(result, isTrue);
    });

    test('getComplianceScore', () async {
      final profile = ComplianceProfile(
        id: 'cp1',
        tenantId: 't1',
        complianceFrameworks: ['SOC2', 'GDPR'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        certifications: ['ISO27001'],
        isCompliant: true,
      );
      await repository.createProfile(profile);

      final score = await manager.complianceEngine.getComplianceScore('t1');
      expect(score, greaterThan(50));
    });
  });

  group('Engine: AuditLoggingEngine', () {
    test('logTenantAction', () async {
      await manager.auditEngine.logTenantAction('t1', 'u1', 'create', 'resource', 'r1');
      final count = await manager.auditEngine.getAuditLogCount('t1');

      expect(count, greaterThan(0));
    });

    test('getRecentActions', () async {
      await manager.auditEngine.logTenantAction('t1', 'u1', 'create', 'tenant', 't1');
      await manager.auditEngine.logTenantAction('t1', 'u1', 'update', 'tenant', 't1');

      final actions = await manager.auditEngine.getRecentActions('t1', limit: 5);
      expect(actions.isNotEmpty, isTrue);
    });
  });

  // ============================================================================
  // FACADE TESTS (6)
  // ============================================================================

  group('Facade Tests', () {
    test('createTenant via facade', () async {
      final tenant = await facade.createTenant('New Tenant', 'org1', TenantTier.professional);

      expect(tenant.name, equals('New Tenant'));
      expect(tenant.tier, equals(TenantTier.professional));
    });

    test('getActiveTenantCount', () async {
      for (int i = 0; i < 3; i++) {
        await facade.createTenant('T$i', 'org1', TenantTier.free);
      }

      final count = await facade.getActiveTenantCount();
      expect(count, equals(3));
    });

    test('getTotalTenantCount', () async {
      for (int i = 0; i < 5; i++) {
        await facade.createTenant('T$i', 'org1', TenantTier.starter);
      }

      final count = await facade.getTotalTenantCount();
      expect(count, equals(5));
    });

    test('getAverageIsolationScore', () async {
      for (int i = 0; i < 2; i++) {
        final tenant = await facade.createTenant('T$i', 'org1', TenantTier.enterprise);
        final policy = IsolationPolicy(
          id: 'p$i',
          tenantId: tenant.id,
          level: IsolationLevel.strict,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          enforceDataEncryption: true,
        );
        await repository.createIsolationPolicy(policy);
      }

      final score = await facade.getAverageIsolationScore();
      expect(score, greaterThanOrEqualTo(0));
    });

    test('grantUserAccess via facade', () async {
      final result = await facade.grantUserAccess('t1', 'u1', 'r1', 'read');
      expect(result, isTrue);
    });

    test('getSystemQuotaUsage', () async {
      final usage = await facade.getSystemQuotaUsage();
      expect(usage, greaterThanOrEqualTo(0));
    });
  });

  // ============================================================================
  // INTEGRATION TESTS (2)
  // ============================================================================

  group('Integration Tests', () {
    test('Complete tenant lifecycle', () async {
      // Create tenant
      final tenant = await facade.createTenant('Integration Test', 'org1', TenantTier.professional);
      expect(tenant.isActive, isTrue);

      // Grant admin access
      final admin = TenantAdmin(
        id: 'admin1',
        tenantId: tenant.id,
        userId: 'u1',
        accessLevel: AccessLevel.owner,
        grantedAt: DateTime.now(),
      );
      await repository.grantAdminAccess(admin);

      // Add access control
      await facade.grantUserAccess(tenant.id, 'u2', 'r1', 'read');

      // Verify
      final hasAccess = await repository.hasAdminAccess(tenant.id, 'u1');
      expect(hasAccess, isTrue);
    });

    test('Quota and metrics tracking', () async {
      final tenant = await facade.createTenant('Quota Test', 'org1', TenantTier.professional);

      // Create quota
      await repository.createQuota(ResourceQuota(
        id: 'q1',
        tenantId: tenant.id,
        resourceType: 'storage',
        quotaLimit: 1000,
        currentUsage: 600,
        resetDate: DateTime.now().add(const Duration(days: 30)),
      ));

      // Record metrics
      await repository.recordMetrics(TenantMetrics(
        id: 'm1',
        tenantId: tenant.id,
        timestamp: DateTime.now(),
        activeUsers: 50,
        apiCallCount: 10000,
        storageUsedGb: 600,
        cpuUsagePercent: 65,
        memoryUsagePercent: 75,
      ));

      // Verify
      final usage = await facade.getSystemQuotaUsage();
      expect(usage, greaterThanOrEqualTo(0));
    });
  });

  // ============================================================================
  // PERFORMANCE TESTS (2)
  // ============================================================================

  group('Performance Tests', () {
    test('Bulk tenant creation', () async {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        await facade.createTenant('Tenant$i', 'org1', TenantTier.free);
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('Large scale quota update', () async {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 50; i++) {
        final quota = ResourceQuota(
          id: 'q$i',
          tenantId: 't1',
          resourceType: 'storage',
          quotaLimit: 1000,
          currentUsage: i * 10.0,
          resetDate: DateTime.now().add(const Duration(days: 30)),
        );
        await repository.createQuota(quota);
        await repository.incrementUsage('q$i', 50);
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
  });

  // ============================================================================
  // EDGE CASE TESTS (5+)
  // ============================================================================

  group('Edge Case Tests', () {
    test('Null tenant operations', () async {
      final result = await repository.getTenantById('nonexistent');
      expect(result, isNull);
    });

    test('Quota exceed with hard limit', () async {
      final quota = ResourceQuota(
        id: 'q1',
        tenantId: 't1',
        resourceType: 'storage',
        quotaLimit: 100,
        currentUsage: 50,
        resetDate: DateTime.now().add(const Duration(days: 30)),
        hardLimit: true,
      );
      await repository.createQuota(quota);

      final available = await manager.quotaEngine.checkQuotaAvailability('t1', 'storage', 60);
      expect(available, isFalse);
    });

    test('Expired access revocation', () async {
      final past = DateTime.now().subtract(const Duration(days: 1));
      final control = AccessControl(
        id: 'ac1',
        tenantId: 't1',
        userId: 'u1',
        resourceType: 'resource',
        resourceId: 'r1',
        permission: 'read',
        grantedAt: DateTime.now().subtract(const Duration(days: 10)),
        expiresAt: past,
      );
      await repository.grantAccess(control);

      final revoked = await repository.revokeExpiredAccess('t1');
      expect(revoked, isTrue);
    });

    test('Cross-tenant request expiration', () async {
      final request = CrossTenantRequest(
        id: 'ctr1',
        sourceTenantId: 't1',
        targetTenantId: 't2',
        requestType: 'share',
        status: 'approved',
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
        approvedAt: DateTime.now().subtract(const Duration(days: 40)),
        expiresAt: DateTime.now().subtract(const Duration(days: 10)),
      );
      await repository.createRequest(request);

      final retrieved = await repository.getRequestById('ctr1');
      expect(retrieved!.isExpired, isTrue);
    });

    test('Compliance profile with zero frameworks', () async {
      final profile = ComplianceProfile(
        id: 'cp1',
        tenantId: 't1',
        complianceFrameworks: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repository.createProfile(profile);
      expect(result.frameworkCount, equals(0));
    });

    test('Health check consecutive failures', () async {
      final check1 = TenantHealthCheck(
        id: 'hc1',
        tenantId: 't1',
        timestamp: DateTime.now(),
        status: 'unhealthy',
        responseTimeMs: 10000,
        consecutiveFailures: 1,
      );
      await repository.recordHealthCheck(check1);

      final check2 = TenantHealthCheck(
        id: 'hc2',
        tenantId: 't1',
        timestamp: DateTime.now(),
        status: 'unhealthy',
        responseTimeMs: 15000,
        consecutiveFailures: 2,
      );
      final result = await repository.recordHealthCheck(check2);

      expect(result.isCriticalFailure, isFalse);
    });
  });
}
