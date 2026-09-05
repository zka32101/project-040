import '../models/resource_models.dart';

abstract class ResourceRepository {
  Future<void> createResource(Resource resource);
  Future<Resource?> getResource(String resourceId);
  Future<List<Resource>> getResourcesByType(ResourceType type);
  Future<List<Resource>> getAllResources();
  Future<void> updateResource(Resource resource);

  Future<void> createPool(ResourcePool pool);
  Future<ResourcePool?> getPool(String poolId);
  Future<List<ResourcePool>> getAllPools();
  Future<void> updatePool(ResourcePool pool);

  Future<void> createAllocation(ResourceAllocation allocation);
  Future<ResourceAllocation?> getAllocation(String allocationId);
  Future<List<ResourceAllocation>> getActiveAllocations(String resourceId);
  Future<List<ResourceAllocation>> getAllocationsByConsumer(String consumerId);
  Future<void> updateAllocation(ResourceAllocation allocation);

  Future<void> createQuota(ResourceQuota quota);
  Future<ResourceQuota?> getQuota(String quotaId);
  Future<List<ResourceQuota>> getQuotasByConsumer(String consumerId);
  Future<void> updateQuota(ResourceQuota quota);

  Future<void> recordUtilization(ResourceUtilization utilization);
  Future<ResourceUtilization?> getUtilization(String utilizationId);
  Future<List<ResourceUtilization>> getLatestUtilization();

  Future<void> createReservation(ResourceReservation reservation);
  Future<ResourceReservation?> getReservation(String reservationId);
  Future<List<ResourceReservation>> getActiveReservations(String resourceId);
  Future<void> updateReservation(ResourceReservation reservation);

  Future<void> createConstraint(ResourceConstraint constraint);
  Future<List<ResourceConstraint>> getConstraints(String resourceId);

  Future<void> saveMetrics(ResourceMetrics metrics);
  Future<ResourceMetrics?> getMetrics(String metricsId);
  Future<List<ResourceMetrics>> getMetricsByResource(String resourceId);

  Future<void> createSchedule(ResourceSchedule schedule);
  Future<ResourceSchedule?> getSchedule(String scheduleId);
  Future<List<ResourceSchedule>> getSchedulesByResource(String resourceId);
  Future<void> updateSchedule(ResourceSchedule schedule);

  Future<void> savePolicy(ResourcePolicy policy);
  Future<ResourcePolicy?> getPolicy(String policyId);
  Future<List<ResourcePolicy>> getAllPolicies();

  Future<void> createLimit(ResourceLimit limit);
  Future<ResourceLimit?> getLimit(String limitId);
  Future<List<ResourceLimit>> getLimitsByResource(String resourceId);

  Future<void> createAffinity(ResourceAffinity affinity);
  Future<ResourceAffinity?> getAffinity(String affinityId);
  Future<List<ResourceAffinity>> getAffinitiesByResource(String resourceId);
}

class MemoryResourceRepository implements ResourceRepository {
  final Map<String, Resource> _resources = {};
  final Map<String, ResourcePool> _pools = {};
  final Map<String, ResourceAllocation> _allocations = {};
  final Map<String, ResourceQuota> _quotas = {};
  final Map<String, ResourceUtilization> _utilizations = {};
  final Map<String, ResourceReservation> _reservations = {};
  final Map<String, ResourceConstraint> _constraints = {};
  final Map<String, ResourceMetrics> _metrics = {};
  final Map<String, ResourceSchedule> _schedules = {};
  final Map<String, ResourcePolicy> _policies = {};
  final Map<String, ResourceLimit> _limits = {};
  final Map<String, ResourceAffinity> _affinities = {};

  @override
  Future<void> createResource(Resource resource) async => _resources[resource.resourceId] = resource;

  @override
  Future<Resource?> getResource(String resourceId) async => _resources[resourceId];

  @override
  Future<List<Resource>> getResourcesByType(ResourceType type) async =>
      _resources.values.where((r) => r.resourceType == type).toList();

  @override
  Future<List<Resource>> getAllResources() async => _resources.values.toList();

  @override
  Future<void> updateResource(Resource resource) async => _resources[resource.resourceId] = resource;

  @override
  Future<void> createPool(ResourcePool pool) async => _pools[pool.poolId] = pool;

  @override
  Future<ResourcePool?> getPool(String poolId) async => _pools[poolId];

  @override
  Future<List<ResourcePool>> getAllPools() async => _pools.values.toList();

  @override
  Future<void> updatePool(ResourcePool pool) async => _pools[pool.poolId] = pool;

  @override
  Future<void> createAllocation(ResourceAllocation allocation) async =>
      _allocations[allocation.allocationId] = allocation;

  @override
  Future<ResourceAllocation?> getAllocation(String allocationId) async => _allocations[allocationId];

  @override
  Future<List<ResourceAllocation>> getActiveAllocations(String resourceId) async =>
      _allocations.values.where((a) => a.resourceId == resourceId && a.isActive).toList();

  @override
  Future<List<ResourceAllocation>> getAllocationsByConsumer(String consumerId) async =>
      _allocations.values.where((a) => a.consumerId == consumerId).toList();

  @override
  Future<void> updateAllocation(ResourceAllocation allocation) async =>
      _allocations[allocation.allocationId] = allocation;

  @override
  Future<void> createQuota(ResourceQuota quota) async => _quotas[quota.quotaId] = quota;

  @override
  Future<ResourceQuota?> getQuota(String quotaId) async => _quotas[quotaId];

  @override
  Future<List<ResourceQuota>> getQuotasByConsumer(String consumerId) async =>
      _quotas.values.where((q) => q.consumerId == consumerId).toList();

  @override
  Future<void> updateQuota(ResourceQuota quota) async => _quotas[quota.quotaId] = quota;

  @override
  Future<void> recordUtilization(ResourceUtilization utilization) async =>
      _utilizations[utilization.utilizationId] = utilization;

  @override
  Future<ResourceUtilization?> getUtilization(String utilizationId) async =>
      _utilizations[utilizationId];

  @override
  Future<List<ResourceUtilization>> getLatestUtilization() async =>
      _utilizations.values.toList();

  @override
  Future<void> createReservation(ResourceReservation reservation) async =>
      _reservations[reservation.reservationId] = reservation;

  @override
  Future<ResourceReservation?> getReservation(String reservationId) async =>
      _reservations[reservationId];

  @override
  Future<List<ResourceReservation>> getActiveReservations(String resourceId) async =>
      _reservations.values.where((r) => r.resourceId == resourceId && r.isActive).toList();

  @override
  Future<void> updateReservation(ResourceReservation reservation) async =>
      _reservations[reservation.reservationId] = reservation;

  @override
  Future<void> createConstraint(ResourceConstraint constraint) async =>
      _constraints[constraint.constraintId] = constraint;

  @override
  Future<List<ResourceConstraint>> getConstraints(String resourceId) async =>
      _constraints.values.where((c) => c.resourceId == resourceId).toList();

  @override
  Future<void> saveMetrics(ResourceMetrics metrics) async => _metrics[metrics.metricsId] = metrics;

  @override
  Future<ResourceMetrics?> getMetrics(String metricsId) async => _metrics[metricsId];

  @override
  Future<List<ResourceMetrics>> getMetricsByResource(String resourceId) async =>
      _metrics.values.where((m) => m.resourceId == resourceId).toList();

  @override
  Future<void> createSchedule(ResourceSchedule schedule) async =>
      _schedules[schedule.scheduleId] = schedule;

  @override
  Future<ResourceSchedule?> getSchedule(String scheduleId) async => _schedules[scheduleId];

  @override
  Future<List<ResourceSchedule>> getSchedulesByResource(String resourceId) async =>
      _schedules.values.where((s) => s.resourceId == resourceId).toList();

  @override
  Future<void> updateSchedule(ResourceSchedule schedule) async =>
      _schedules[schedule.scheduleId] = schedule;

  @override
  Future<void> savePolicy(ResourcePolicy policy) async => _policies[policy.policyId] = policy;

  @override
  Future<ResourcePolicy?> getPolicy(String policyId) async => _policies[policyId];

  @override
  Future<List<ResourcePolicy>> getAllPolicies() async => _policies.values.toList();

  @override
  Future<void> createLimit(ResourceLimit limit) async => _limits[limit.limitId] = limit;

  @override
  Future<ResourceLimit?> getLimit(String limitId) async => _limits[limitId];

  @override
  Future<List<ResourceLimit>> getLimitsByResource(String resourceId) async =>
      _limits.values.where((l) => l.resourceId == resourceId).toList();

  @override
  Future<void> createAffinity(ResourceAffinity affinity) async =>
      _affinities[affinity.affinityId] = affinity;

  @override
  Future<ResourceAffinity?> getAffinity(String affinityId) async => _affinities[affinityId];

  @override
  Future<List<ResourceAffinity>> getAffinitiesByResource(String resourceId) async =>
      _affinities.values.where((a) => a.resourceId == resourceId).toList();
}

class AllocationEngine {
  final ResourceRepository repository;

  AllocationEngine(this.repository);

  Future<ResourceAllocation?> allocateResource(
    String resourceId,
    String consumerId,
    double amount,
    String purpose,
  ) async {
    final resource = await repository.getResource(resourceId);
    if (resource == null || !resource.isAvailable || resource.availableCapacity < amount) {
      return null;
    }

    final allocation = ResourceAllocation(
      allocationId: 'alloc-${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      consumerId: consumerId,
      allocatedAmount: amount,
      allocatedAt: DateTime.now(),
      purpose: purpose,
    );

    await repository.createAllocation(allocation);
    return allocation;
  }

  Future<void> deallocateResource(String allocationId) async {
    final allocation = await repository.getAllocation(allocationId);
    if (allocation != null && allocation.isActive) {
      final updated = ResourceAllocation(
        allocationId: allocation.allocationId,
        resourceId: allocation.resourceId,
        consumerId: allocation.consumerId,
        allocatedAmount: allocation.allocatedAmount,
        allocatedAt: allocation.allocatedAt,
        deallocatedAt: DateTime.now(),
        isActive: false,
        purpose: allocation.purpose,
      );
      await repository.updateAllocation(updated);
    }
  }
}

class QuotaEngine {
  final ResourceRepository repository;

  QuotaEngine(this.repository);

  Future<bool> checkQuotaCompliance(String consumerId) async {
    final quotas = await repository.getQuotasByConsumer(consumerId);
    return !quotas.any((q) => q.isExceeded);
  }

  Future<void> updateQuotaUsage(String quotaId, double newUsage) async {
    final quota = await repository.getQuota(quotaId);
    if (quota != null) {
      final updated = ResourceQuota(
        quotaId: quota.quotaId,
        consumerId: quota.consumerId,
        resourceType: quota.resourceType,
        hardLimit: quota.hardLimit,
        softLimit: quota.softLimit,
        currentUsage: newUsage,
        quotaType: quota.quotaType,
        createdAt: quota.createdAt,
      );
      await repository.updateQuota(updated);
    }
  }
}

class ReservationEngine {
  final ResourceRepository repository;

  ReservationEngine(this.repository);

  Future<ResourceReservation?> reserveResource(
    String resourceId,
    String reservedBy,
    double amount,
    int durationSeconds,
    String reason,
  ) async {
    final resource = await repository.getResource(resourceId);
    if (resource == null || resource.availableCapacity < amount) {
      return null;
    }

    final now = DateTime.now();
    final reservation = ResourceReservation(
      reservationId: 'res-${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      reservedBy: reservedBy,
      reservedAmount: amount,
      reservedAt: now,
      expiresAt: now.add(Duration(seconds: durationSeconds)),
      reason: reason,
    );

    await repository.createReservation(reservation);
    return reservation;
  }

  Future<void> confirmReservation(String reservationId) async {
    final reservation = await repository.getReservation(reservationId);
    if (reservation != null) {
      final confirmed = ResourceReservation(
        reservationId: reservation.reservationId,
        resourceId: reservation.resourceId,
        reservedBy: reservation.reservedBy,
        reservedAmount: reservation.reservedAmount,
        reservedAt: reservation.reservedAt,
        expiresAt: reservation.expiresAt,
        isConfirmed: true,
        reason: reservation.reason,
      );
      await repository.updateReservation(confirmed);
    }
  }
}

class PoolEngine {
  final ResourceRepository repository;

  PoolEngine(this.repository);

  Future<List<Resource>> getPoolResources(String poolId) async {
    final pool = await repository.getPool(poolId);
    if (pool == null) return [];

    final resources = <Resource>[];
    for (final resourceId in pool.resourceIds) {
      final resource = await repository.getResource(resourceId);
      if (resource != null) {
        resources.add(resource);
      }
    }
    return resources;
  }

  Future<double> getPoolTotalCapacity(String poolId) async {
    final resources = await getPoolResources(poolId);
    return resources.fold(0.0, (sum, r) => sum + r.capacity);
  }

  Future<double> getPoolTotalUtilization(String poolId) async {
    final resources = await getPoolResources(poolId);
    return resources.fold(0.0, (sum, r) => sum + r.currentUsage);
  }
}

class ResourceManager {
  final ResourceRepository repository;
  late final AllocationEngine allocationEngine;
  late final QuotaEngine quotaEngine;
  late final ReservationEngine reservationEngine;
  late final PoolEngine poolEngine;

  ResourceManager(this.repository) {
    allocationEngine = AllocationEngine(repository);
    quotaEngine = QuotaEngine(repository);
    reservationEngine = ReservationEngine(repository);
    poolEngine = PoolEngine(repository);
  }

  Future<ResourceAllocation?> allocate(
    String resourceId,
    String consumerId,
    double amount,
    String purpose,
  ) =>
      allocationEngine.allocateResource(resourceId, consumerId, amount, purpose);

  Future<void> deallocate(String allocationId) =>
      allocationEngine.deallocateResource(allocationId);

  Future<bool> checkQuotaCompliance(String consumerId) =>
      quotaEngine.checkQuotaCompliance(consumerId);

  Future<ResourceReservation?> reserve(
    String resourceId,
    String reservedBy,
    double amount,
    int durationSeconds,
    String reason,
  ) =>
      reservationEngine.reserveResource(
        resourceId,
        reservedBy,
        amount,
        durationSeconds,
        reason,
      );

  Future<void> confirmReservation(String reservationId) =>
      reservationEngine.confirmReservation(reservationId);
}

class ResourceFacade {
  final ResourceManager manager;

  ResourceFacade(this.manager);

  Future<void> createResource(
    String resourceName,
    ResourceType type,
    double capacity,
    String unit,
  ) async {
    final resource = Resource(
      resourceId: 'res-${DateTime.now().millisecondsSinceEpoch}',
      resourceName: resourceName,
      resourceType: type,
      capacity: capacity,
      currentUsage: 0,
      unit: unit,
      createdAt: DateTime.now(),
    );
    await manager.repository.createResource(resource);
  }

  Future<Resource?> getResource(String resourceId) =>
      manager.repository.getResource(resourceId);

  Future<List<Resource>> getResourcesByType(ResourceType type) =>
      manager.repository.getResourcesByType(type);

  Future<void> createPool(
    String poolName,
    List<String> resourceIds,
    AllocationStrategy strategy,
  ) async {
    final pool = ResourcePool(
      poolId: 'pool-${DateTime.now().millisecondsSinceEpoch}',
      poolName: poolName,
      resourceIds: resourceIds,
      strategy: strategy,
      maxConcurrentAllocations: 100,
      createdAt: DateTime.now(),
    );
    await manager.repository.createPool(pool);
  }

  Future<ResourcePool?> getPool(String poolId) =>
      manager.repository.getPool(poolId);

  Future<List<Resource>> getPoolResources(String poolId) =>
      manager.poolEngine.getPoolResources(poolId);

  Future<ResourceAllocation?> allocateResource(
    String resourceId,
    String consumerId,
    double amount,
    String purpose,
  ) =>
      manager.allocate(resourceId, consumerId, amount, purpose);

  Future<void> deallocateResource(String allocationId) =>
      manager.deallocate(allocationId);

  Future<void> createQuota(
    String consumerId,
    ResourceType type,
    double hardLimit,
    double softLimit,
  ) async {
    final quota = ResourceQuota(
      quotaId: 'quota-${DateTime.now().millisecondsSinceEpoch}',
      consumerId: consumerId,
      resourceType: type,
      hardLimit: hardLimit,
      softLimit: softLimit,
      currentUsage: 0,
      quotaType: QuotaType.hard,
      createdAt: DateTime.now(),
    );
    await manager.repository.createQuota(quota);
  }

  Future<bool> checkQuotaCompliance(String consumerId) =>
      manager.checkQuotaCompliance(consumerId);

  Future<ResourceReservation?> reserveResource(
    String resourceId,
    String reservedBy,
    double amount,
    int durationSeconds,
    String reason,
  ) =>
      manager.reserve(resourceId, reservedBy, amount, durationSeconds, reason);

  Future<void> confirmReservation(String reservationId) =>
      manager.confirmReservation(reservationId);

  Future<List<ResourceReservation>> getActiveReservations(String resourceId) =>
      manager.repository.getActiveReservations(resourceId);

  Future<void> recordUtilization(
    String resourceId,
    double utilizationPercent,
    double peakUsage,
    double averageUsage,
    int sampleCount,
  ) async {
    final utilization = ResourceUtilization(
      utilizationId: 'util-${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      utilizationPercent: utilizationPercent,
      peakUsage: peakUsage,
      averageUsage: averageUsage,
      sampleCount: sampleCount,
      measuredAt: DateTime.now(),
    );
    await manager.repository.recordUtilization(utilization);
  }

  Future<List<ResourceUtilization>> getLatestUtilization() =>
      manager.repository.getLatestUtilization();

  Future<void> createPolicy(
    String policyName,
    AllocationStrategy strategy,
    ResolutionPolicy resolutionPolicy,
  ) async {
    final policy = ResourcePolicy(
      policyId: 'policy-${DateTime.now().millisecondsSinceEpoch}',
      policyName: policyName,
      strategy: strategy,
      resolutionPolicy: resolutionPolicy,
      maxRetries: 3,
      timeoutSeconds: 300,
    );
    await manager.repository.savePolicy(policy);
  }

  Future<ResourcePolicy?> getPolicy(String policyId) =>
      manager.repository.getPolicy(policyId);

  Future<void> createSchedule(
    String resourceId,
    DateTime startTime,
    DateTime endTime,
    double allocatedAmount,
    String purpose,
  ) async {
    final schedule = ResourceSchedule(
      scheduleId: 'sched-${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      startTime: startTime,
      endTime: endTime,
      allocatedAmount: allocatedAmount,
      purpose: purpose,
    );
    await manager.repository.createSchedule(schedule);
  }

  Future<List<ResourceSchedule>> getSchedulesByResource(String resourceId) =>
      manager.repository.getSchedulesByResource(resourceId);
}
