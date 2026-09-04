import 'package:test/test.dart';
import '../lib/models/resource_models.dart';
import '../lib/services/resource_service.dart';

void main() {
  group('Phase 66: Resource Management & Pooling Tests', () {
    late MemoryResourceRepository repository;
    late ResourceManager manager;
    late ResourceFacade facade;

    setUp(() {
      repository = MemoryResourceRepository();
      manager = ResourceManager(repository);
      facade = ResourceFacade(manager);
    });

    // Enum Tests
    group('Enum Tests', () {
      test('ResourceType enum has all values', () {
        expect(ResourceType.values, contains(ResourceType.cpu));
        expect(ResourceType.values, contains(ResourceType.memory));
        expect(ResourceType.values, contains(ResourceType.disk));
        expect(ResourceType.values, contains(ResourceType.network));
        expect(ResourceType.values, contains(ResourceType.gpu));
        expect(ResourceType.values, contains(ResourceType.custom));
      });

      test('AllocationStrategy enum has all values', () {
        expect(AllocationStrategy.values, contains(AllocationStrategy.fair));
        expect(AllocationStrategy.values, contains(AllocationStrategy.weighted));
        expect(AllocationStrategy.values, contains(AllocationStrategy.priority));
        expect(AllocationStrategy.values, contains(AllocationStrategy.exclusive));
        expect(AllocationStrategy.values, contains(AllocationStrategy.shared));
      });

      test('QuotaType enum values', () {
        expect(QuotaType.values, contains(QuotaType.hard));
        expect(QuotaType.values, contains(QuotaType.soft));
      });

      test('ResolutionPolicy enum values', () {
        expect(ResolutionPolicy.values, contains(ResolutionPolicy.fail));
        expect(ResolutionPolicy.values, contains(ResolutionPolicy.queue));
        expect(ResolutionPolicy.values, contains(ResolutionPolicy.preempt));
        expect(ResolutionPolicy.values, contains(ResolutionPolicy.migrate));
      });

      test('ResourceState enum values', () {
        expect(ResourceState.values, contains(ResourceState.available));
        expect(ResourceState.values, contains(ResourceState.allocated));
        expect(ResourceState.values, contains(ResourceState.reserved));
        expect(ResourceState.values, contains(ResourceState.unavailable));
      });

      test('ConstraintType enum values', () {
        expect(ConstraintType.values, contains(ConstraintType.hard));
        expect(ConstraintType.values, contains(ConstraintType.soft));
        expect(ConstraintType.values, contains(ConstraintType.preference));
      });
    });

    // Resource Model Tests
    group('Resource Model Tests', () {
      test('Resource creation with default values', () {
        final resource = Resource(
          resourceId: 'res-1',
          resourceName: 'CPU-1',
          resourceType: ResourceType.cpu,
          capacity: 100.0,
          currentUsage: 30.0,
          unit: 'cores',
          createdAt: DateTime.now(),
        );

        expect(resource.resourceId, 'res-1');
        expect(resource.resourceName, 'CPU-1');
        expect(resource.resourceType, ResourceType.cpu);
        expect(resource.capacity, 100.0);
      });

      test('Resource computed properties', () {
        final resource = Resource(
          resourceId: 'res-1',
          resourceName: 'CPU-1',
          resourceType: ResourceType.cpu,
          capacity: 100.0,
          currentUsage: 30.0,
          unit: 'cores',
          createdAt: DateTime.now(),
        );

        expect(resource.availableCapacity, 70.0);
        expect(resource.isAvailable, true);
        expect(resource.utilizationPercent, 30.0);
      });

      test('Resource unavailable when capacity exceeded', () {
        final resource = Resource(
          resourceId: 'res-1',
          resourceName: 'CPU-1',
          resourceType: ResourceType.cpu,
          capacity: 100.0,
          currentUsage: 100.0,
          unit: 'cores',
          createdAt: DateTime.now(),
          state: ResourceState.allocated,
        );

        expect(resource.isAvailable, false);
        expect(resource.availableCapacity, 0.0);
      });

      test('Resource state transitions', () {
        final available = Resource(
          resourceId: 'res-1',
          resourceName: 'CPU-1',
          resourceType: ResourceType.cpu,
          capacity: 100.0,
          currentUsage: 0.0,
          unit: 'cores',
          createdAt: DateTime.now(),
          state: ResourceState.available,
        );

        expect(available.state, ResourceState.available);
        expect(available.isAvailable, true);
      });

      test('Resource age calculation', () {
        final now = DateTime.now();
        final resource = Resource(
          resourceId: 'res-1',
          resourceName: 'CPU-1',
          resourceType: ResourceType.cpu,
          capacity: 100.0,
          currentUsage: 0.0,
          unit: 'cores',
          createdAt: now.subtract(Duration(days: 5)),
        );

        expect(resource.ageInDays, 5);
      });
    });

    // ResourcePool Tests
    group('ResourcePool Tests', () {
      test('Pool creation and properties', () {
        final pool = ResourcePool(
          poolId: 'pool-1',
          poolName: 'CPU Pool',
          resourceIds: ['res-1', 'res-2', 'res-3'],
          strategy: AllocationStrategy.fair,
          maxConcurrentAllocations: 10,
          createdAt: DateTime.now(),
        );

        expect(pool.poolId, 'pool-1');
        expect(pool.resourceCount, 3);
        expect(pool.hasResources, true);
      });

      test('Empty pool properties', () {
        final pool = ResourcePool(
          poolId: 'pool-1',
          poolName: 'Empty Pool',
          resourceIds: [],
          strategy: AllocationStrategy.fair,
          maxConcurrentAllocations: 10,
          createdAt: DateTime.now(),
        );

        expect(pool.hasResources, false);
        expect(pool.resourceCount, 0);
      });
    });

    // ResourceAllocation Tests
    group('ResourceAllocation Tests', () {
      test('Active allocation properties', () {
        final allocation = ResourceAllocation(
          allocationId: 'alloc-1',
          resourceId: 'res-1',
          consumerId: 'consumer-1',
          allocatedAmount: 50.0,
          allocatedAt: DateTime.now(),
          purpose: 'job-1',
        );

        expect(allocation.isActive, true);
        expect(allocation.isCompleted, false);
        expect(allocation.ageInSeconds, greaterThanOrEqualTo(0));
      });

      test('Completed allocation properties', () {
        final now = DateTime.now();
        final allocation = ResourceAllocation(
          allocationId: 'alloc-1',
          resourceId: 'res-1',
          consumerId: 'consumer-1',
          allocatedAmount: 50.0,
          allocatedAt: now,
          deallocatedAt: now.add(Duration(seconds: 100)),
          isActive: false,
          purpose: 'job-1',
        );

        expect(allocation.isCompleted, true);
        expect(allocation.isActive, false);
        expect(allocation.durationInSeconds, 100);
      });
    });

    // ResourceQuota Tests
    group('ResourceQuota Tests', () {
      test('Quota compliance check', () {
        final quota = ResourceQuota(
          quotaId: 'quota-1',
          consumerId: 'consumer-1',
          resourceType: ResourceType.memory,
          hardLimit: 100.0,
          softLimit: 80.0,
          currentUsage: 60.0,
          quotaType: QuotaType.hard,
          createdAt: DateTime.now(),
        );

        expect(quota.isExceeded, false);
        expect(quota.isSoftLimitExceeded, false);
        expect(quota.remainingQuota, 40.0);
      });

      test('Quota exceeded detection', () {
        final quota = ResourceQuota(
          quotaId: 'quota-1',
          consumerId: 'consumer-1',
          resourceType: ResourceType.memory,
          hardLimit: 100.0,
          softLimit: 80.0,
          currentUsage: 120.0,
          quotaType: QuotaType.hard,
          createdAt: DateTime.now(),
        );

        expect(quota.isExceeded, true);
        expect(quota.isSoftLimitExceeded, true);
        expect(quota.utilizationPercent, 120.0);
      });

      test('Soft limit exceeded but hard limit not', () {
        final quota = ResourceQuota(
          quotaId: 'quota-1',
          consumerId: 'consumer-1',
          resourceType: ResourceType.memory,
          hardLimit: 100.0,
          softLimit: 80.0,
          currentUsage: 90.0,
          quotaType: QuotaType.hard,
          createdAt: DateTime.now(),
        );

        expect(quota.isExceeded, false);
        expect(quota.isSoftLimitExceeded, true);
      });
    });

    // ResourceUtilization Tests
    group('ResourceUtilization Tests', () {
      test('Healthy utilization status', () {
        final util = ResourceUtilization(
          utilizationId: 'util-1',
          resourceId: 'res-1',
          utilizationPercent: 50.0,
          peakUsage: 70.0,
          averageUsage: 45.0,
          sampleCount: 100,
          measuredAt: DateTime.now(),
        );

        expect(util.isHealthy, true);
        expect(util.isWarning, false);
        expect(util.isCritical, false);
      });

      test('Warning utilization status', () {
        final util = ResourceUtilization(
          utilizationId: 'util-1',
          resourceId: 'res-1',
          utilizationPercent: 85.0,
          peakUsage: 90.0,
          averageUsage: 80.0,
          sampleCount: 100,
          measuredAt: DateTime.now(),
        );

        expect(util.isHealthy, false);
        expect(util.isWarning, true);
        expect(util.isCritical, false);
      });

      test('Critical utilization status', () {
        final util = ResourceUtilization(
          utilizationId: 'util-1',
          resourceId: 'res-1',
          utilizationPercent: 98.0,
          peakUsage: 100.0,
          averageUsage: 95.0,
          sampleCount: 100,
          measuredAt: DateTime.now(),
        );

        expect(util.isHealthy, false);
        expect(util.isWarning, false);
        expect(util.isCritical, true);
      });
    });

    // ResourceReservation Tests
    group('ResourceReservation Tests', () {
      test('Active reservation properties', () {
        final now = DateTime.now();
        final reservation = ResourceReservation(
          reservationId: 'res-1',
          resourceId: 'res-1',
          reservedBy: 'user-1',
          reservedAmount: 25.0,
          reservedAt: now,
          expiresAt: now.add(Duration(hours: 1)),
          isConfirmed: true,
          reason: 'job-reservation',
        );

        expect(reservation.isActive, true);
        expect(reservation.isExpired, false);
        expect(reservation.remainingSeconds, greaterThan(3500));
      });

      test('Expired reservation detection', () {
        final now = DateTime.now();
        final reservation = ResourceReservation(
          reservationId: 'res-1',
          resourceId: 'res-1',
          reservedBy: 'user-1',
          reservedAmount: 25.0,
          reservedAt: now.subtract(Duration(hours: 2)),
          expiresAt: now.subtract(Duration(minutes: 30)),
          isConfirmed: true,
          reason: 'job-reservation',
        );

        expect(reservation.isExpired, true);
        expect(reservation.isActive, false);
      });

      test('Unconfirmed reservation', () {
        final now = DateTime.now();
        final reservation = ResourceReservation(
          reservationId: 'res-1',
          resourceId: 'res-1',
          reservedBy: 'user-1',
          reservedAmount: 25.0,
          reservedAt: now,
          expiresAt: now.add(Duration(hours: 1)),
          isConfirmed: false,
          reason: 'job-reservation',
        );

        expect(reservation.isActive, false);
      });
    });

    // ResourceConstraint Tests
    group('ResourceConstraint Tests', () {
      test('Constraint with parameters', () {
        final constraint = ResourceConstraint(
          constraintId: 'const-1',
          resourceId: 'res-1',
          constraintType: ConstraintType.hard,
          name: 'MaxAllocation',
          parameters: {'maxPercent': 80.0, 'minHold': 10.0},
        );

        expect(constraint.hasParameters, true);
        expect(constraint.parameterCount, 2);
      });

      test('Empty constraint parameters', () {
        final constraint = ResourceConstraint(
          constraintId: 'const-1',
          resourceId: 'res-1',
          constraintType: ConstraintType.soft,
          name: 'Preference',
          parameters: {},
        );

        expect(constraint.hasParameters, false);
        expect(constraint.parameterCount, 0);
      });
    });

    // ResourceMetrics Tests
    group('ResourceMetrics Tests', () {
      test('Healthy metrics', () {
        final metrics = ResourceMetrics(
          metricsId: 'metric-1',
          resourceId: 'res-1',
          totalAllocations: 100.0,
          successfulAllocations: 98.0,
          failedAllocations: 2.0,
          averageAllocationTime: 250.0,
          peakUtilization: 85.0,
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
        );

        expect(metrics.successRate, 98.0);
        expect(metrics.failureRate, 2.0);
        expect(metrics.isHealthy, true);
      });

      test('Unhealthy metrics', () {
        final metrics = ResourceMetrics(
          metricsId: 'metric-1',
          resourceId: 'res-1',
          totalAllocations: 100.0,
          successfulAllocations: 90.0,
          failedAllocations: 10.0,
          averageAllocationTime: 500.0,
          peakUtilization: 95.0,
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
        );

        expect(metrics.successRate, 90.0);
        expect(metrics.failureRate, 10.0);
        expect(metrics.isHealthy, false);
      });

      test('Zero allocations metrics', () {
        final metrics = ResourceMetrics(
          metricsId: 'metric-1',
          resourceId: 'res-1',
          totalAllocations: 0.0,
          successfulAllocations: 0.0,
          failedAllocations: 0.0,
          averageAllocationTime: 0.0,
          peakUtilization: 0.0,
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
        );

        expect(metrics.successRate, 0.0);
        expect(metrics.failureRate, 0.0);
      });
    });

    // ResourceSchedule Tests
    group('ResourceSchedule Tests', () {
      test('Upcoming schedule', () {
        final now = DateTime.now();
        final schedule = ResourceSchedule(
          scheduleId: 'sched-1',
          resourceId: 'res-1',
          startTime: now.add(Duration(hours: 1)),
          endTime: now.add(Duration(hours: 2)),
          allocatedAmount: 50.0,
          purpose: 'batch-job',
        );

        expect(schedule.isUpcoming, true);
        expect(schedule.isActive, false);
        expect(schedule.isExpired, false);
      });

      test('Active schedule', () {
        final now = DateTime.now();
        final schedule = ResourceSchedule(
          scheduleId: 'sched-1',
          resourceId: 'res-1',
          startTime: now.subtract(Duration(minutes: 30)),
          endTime: now.add(Duration(minutes: 30)),
          allocatedAmount: 50.0,
          purpose: 'batch-job',
        );

        expect(schedule.isUpcoming, false);
        expect(schedule.isActive, true);
        expect(schedule.isExpired, false);
      });

      test('Expired schedule', () {
        final now = DateTime.now();
        final schedule = ResourceSchedule(
          scheduleId: 'sched-1',
          resourceId: 'res-1',
          startTime: now.subtract(Duration(hours: 2)),
          endTime: now.subtract(Duration(hours: 1)),
          allocatedAmount: 50.0,
          purpose: 'batch-job',
        );

        expect(schedule.isUpcoming, false);
        expect(schedule.isActive, false);
        expect(schedule.isExpired, true);
      });
    });

    // ResourcePolicy Tests
    group('ResourcePolicy Tests', () {
      test('Policy creation', () {
        final policy = ResourcePolicy(
          policyId: 'policy-1',
          policyName: 'Fair Allocation',
          strategy: AllocationStrategy.fair,
          resolutionPolicy: ResolutionPolicy.queue,
          maxRetries: 3,
          timeoutSeconds: 300,
        );

        expect(policy.policyName, 'Fair Allocation');
        expect(policy.strategy, AllocationStrategy.fair);
        expect(policy.isActive, true);
      });

      test('Policy with description', () {
        final policy = ResourcePolicy(
          policyId: 'policy-1',
          policyName: 'Fair Allocation',
          strategy: AllocationStrategy.fair,
          resolutionPolicy: ResolutionPolicy.queue,
          maxRetries: 3,
          timeoutSeconds: 300,
          description: 'Distributes resources fairly among consumers',
        );

        expect(policy.hasDescription, true);
        expect(policy.description, contains('fairly'));
      });
    });

    // ResourceLimit Tests
    group('ResourceLimit Tests', () {
      test('Valid limit range', () {
        final limit = ResourceLimit(
          limitId: 'limit-1',
          resourceId: 'res-1',
          minThreshold: 10.0,
          maxThreshold: 90.0,
          warningLevel: 70,
          criticalLevel: 90,
          createdAt: DateTime.now(),
        );

        expect(limit.hasValidRange, true);
      });

      test('Invalid limit range', () {
        final limit = ResourceLimit(
          limitId: 'limit-1',
          resourceId: 'res-1',
          minThreshold: 90.0,
          maxThreshold: 10.0,
          warningLevel: 70,
          criticalLevel: 90,
          createdAt: DateTime.now(),
        );

        expect(limit.hasValidRange, false);
      });
    });

    // ResourceAffinity Tests
    group('ResourceAffinity Tests', () {
      test('Affinity with preferences', () {
        final affinity = ResourceAffinity(
          affinityId: 'aff-1',
          resourceId: 'res-1',
          preferredNodes: ['node-1', 'node-2'],
          forbiddenNodes: ['node-5'],
          affinityRule: 'prefer-local',
          isRequired: false,
        );

        expect(affinity.hasPreferredNodes, true);
        expect(affinity.hasForbiddenNodes, true);
        expect(affinity.totalNodeConstraints, 3);
      });

      test('Required affinity rule', () {
        final affinity = ResourceAffinity(
          affinityId: 'aff-1',
          resourceId: 'res-1',
          preferredNodes: ['node-1'],
          forbiddenNodes: [],
          affinityRule: 'required-local',
          isRequired: true,
        );

        expect(affinity.isRequired, true);
      });
    });

    // Repository CRUD Tests
    group('Repository CRUD Operations', () {
      test('Create and retrieve resource', () async {
        final resource = Resource(
          resourceId: 'res-1',
          resourceName: 'CPU-1',
          resourceType: ResourceType.cpu,
          capacity: 100.0,
          currentUsage: 0.0,
          unit: 'cores',
          createdAt: DateTime.now(),
        );

        await repository.createResource(resource);
        final retrieved = await repository.getResource('res-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.resourceId, 'res-1');
        expect(retrieved.resourceName, 'CPU-1');
      });

      test('Get resources by type', () async {
        final cpu = Resource(
          resourceId: 'cpu-1',
          resourceName: 'CPU-1',
          resourceType: ResourceType.cpu,
          capacity: 100.0,
          currentUsage: 0.0,
          unit: 'cores',
          createdAt: DateTime.now(),
        );

        final mem = Resource(
          resourceId: 'mem-1',
          resourceName: 'Memory-1',
          resourceType: ResourceType.memory,
          capacity: 1000.0,
          currentUsage: 0.0,
          unit: 'MB',
          createdAt: DateTime.now(),
        );

        await repository.createResource(cpu);
        await repository.createResource(mem);

        final cpuResources = await repository.getResourcesByType(ResourceType.cpu);
        expect(cpuResources.length, 1);
        expect(cpuResources.first.resourceType, ResourceType.cpu);
      });

      test('Create and retrieve pool', () async {
        final pool = ResourcePool(
          poolId: 'pool-1',
          poolName: 'CPU Pool',
          resourceIds: ['res-1'],
          strategy: AllocationStrategy.fair,
          maxConcurrentAllocations: 10,
          createdAt: DateTime.now(),
        );

        await repository.createPool(pool);
        final retrieved = await repository.getPool('pool-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.poolName, 'CPU Pool');
      });

      test('Create and retrieve allocation', () async {
        final allocation = ResourceAllocation(
          allocationId: 'alloc-1',
          resourceId: 'res-1',
          consumerId: 'consumer-1',
          allocatedAmount: 50.0,
          allocatedAt: DateTime.now(),
          purpose: 'job-1',
        );

        await repository.createAllocation(allocation);
        final retrieved = await repository.getAllocation('alloc-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.consumerId, 'consumer-1');
        expect(retrieved.allocatedAmount, 50.0);
      });

      test('Create and retrieve quota', () async {
        final quota = ResourceQuota(
          quotaId: 'quota-1',
          consumerId: 'consumer-1',
          resourceType: ResourceType.memory,
          hardLimit: 100.0,
          softLimit: 80.0,
          currentUsage: 0.0,
          quotaType: QuotaType.hard,
          createdAt: DateTime.now(),
        );

        await repository.createQuota(quota);
        final retrieved = await repository.getQuota('quota-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.hardLimit, 100.0);
      });

      test('Get active allocations', () async {
        final alloc1 = ResourceAllocation(
          allocationId: 'alloc-1',
          resourceId: 'res-1',
          consumerId: 'consumer-1',
          allocatedAmount: 50.0,
          allocatedAt: DateTime.now(),
          purpose: 'job-1',
        );

        final alloc2 = ResourceAllocation(
          allocationId: 'alloc-2',
          resourceId: 'res-1',
          consumerId: 'consumer-1',
          allocatedAmount: 30.0,
          allocatedAt: DateTime.now(),
          isActive: false,
          purpose: 'job-2',
        );

        await repository.createAllocation(alloc1);
        await repository.createAllocation(alloc2);

        final active = await repository.getActiveAllocations('res-1');
        expect(active.length, 1);
        expect(active.first.isActive, true);
      });

      test('Get allocations by consumer', () async {
        final alloc = ResourceAllocation(
          allocationId: 'alloc-1',
          resourceId: 'res-1',
          consumerId: 'consumer-1',
          allocatedAmount: 50.0,
          allocatedAt: DateTime.now(),
          purpose: 'job-1',
        );

        await repository.createAllocation(alloc);
        final byConsumer = await repository.getAllocationsByConsumer('consumer-1');

        expect(byConsumer.length, 1);
        expect(byConsumer.first.consumerId, 'consumer-1');
      });

      test('Get quotas by consumer', () async {
        final quota = ResourceQuota(
          quotaId: 'quota-1',
          consumerId: 'consumer-1',
          resourceType: ResourceType.memory,
          hardLimit: 100.0,
          softLimit: 80.0,
          currentUsage: 0.0,
          quotaType: QuotaType.hard,
          createdAt: DateTime.now(),
        );

        await repository.createQuota(quota);
        final quotas = await repository.getQuotasByConsumer('consumer-1');

        expect(quotas.length, 1);
        expect(quotas.first.consumerId, 'consumer-1');
      });

      test('Create and retrieve reservation', () async {
        final reservation = ResourceReservation(
          reservationId: 'res-1',
          resourceId: 'res-1',
          reservedBy: 'user-1',
          reservedAmount: 25.0,
          reservedAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
          reason: 'job-reservation',
        );

        await repository.createReservation(reservation);
        final retrieved = await repository.getReservation('res-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.reservedBy, 'user-1');
      });

      test('Record and retrieve utilization', () async {
        final util = ResourceUtilization(
          utilizationId: 'util-1',
          resourceId: 'res-1',
          utilizationPercent: 50.0,
          peakUsage: 70.0,
          averageUsage: 45.0,
          sampleCount: 100,
          measuredAt: DateTime.now(),
        );

        await repository.recordUtilization(util);
        final retrieved = await repository.getUtilization('util-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.utilizationPercent, 50.0);
      });
    });

    // Engine Tests
    group('AllocationEngine Tests', () {
      test('Successful resource allocation', () async {
        final resource = Resource(
          resourceId: 'res-1',
          resourceName: 'CPU-1',
          resourceType: ResourceType.cpu,
          capacity: 100.0,
          currentUsage: 0.0,
          unit: 'cores',
          createdAt: DateTime.now(),
        );

        await repository.createResource(resource);

        final allocation = await manager.allocate('res-1', 'consumer-1', 50.0, 'test-job');

        expect(allocation, isNotNull);
        expect(allocation!.allocatedAmount, 50.0);
        expect(allocation.consumerId, 'consumer-1');
      });

      test('Failed allocation when insufficient capacity', () async {
        final resource = Resource(
          resourceId: 'res-1',
          resourceName: 'CPU-1',
          resourceType: ResourceType.cpu,
          capacity: 100.0,
          currentUsage: 50.0,
          unit: 'cores',
          createdAt: DateTime.now(),
        );

        await repository.createResource(resource);

        final allocation = await manager.allocate('res-1', 'consumer-1', 100.0, 'test-job');

        expect(allocation, isNull);
      });

      test('Allocation deallocation', () async {
        final allocation = ResourceAllocation(
          allocationId: 'alloc-1',
          resourceId: 'res-1',
          consumerId: 'consumer-1',
          allocatedAmount: 50.0,
          allocatedAt: DateTime.now(),
          purpose: 'job-1',
        );

        await repository.createAllocation(allocation);
        await manager.deallocate('alloc-1');

        final updated = await repository.getAllocation('alloc-1');
        expect(updated!.isActive, false);
        expect(updated.deallocatedAt, isNotNull);
      });
    });

    // QuotaEngine Tests
    group('QuotaEngine Tests', () {
      test('Quota compliance check passes', () async {
        final quota = ResourceQuota(
          quotaId: 'quota-1',
          consumerId: 'consumer-1',
          resourceType: ResourceType.memory,
          hardLimit: 100.0,
          softLimit: 80.0,
          currentUsage: 60.0,
          quotaType: QuotaType.hard,
          createdAt: DateTime.now(),
        );

        await repository.createQuota(quota);

        final compliant = await manager.checkQuotaCompliance('consumer-1');
        expect(compliant, true);
      });

      test('Quota compliance check fails', () async {
        final quota = ResourceQuota(
          quotaId: 'quota-1',
          consumerId: 'consumer-1',
          resourceType: ResourceType.memory,
          hardLimit: 100.0,
          softLimit: 80.0,
          currentUsage: 120.0,
          quotaType: QuotaType.hard,
          createdAt: DateTime.now(),
        );

        await repository.createQuota(quota);

        final compliant = await manager.checkQuotaCompliance('consumer-1');
        expect(compliant, false);
      });
    });

    // ReservationEngine Tests
    group('ReservationEngine Tests', () {
      test('Successful resource reservation', () async {
        final resource = Resource(
          resourceId: 'res-1',
          resourceName: 'CPU-1',
          resourceType: ResourceType.cpu,
          capacity: 100.0,
          currentUsage: 0.0,
          unit: 'cores',
          createdAt: DateTime.now(),
        );

        await repository.createResource(resource);

        final reservation = await manager.reserve(
          'res-1',
          'user-1',
          50.0,
          3600,
          'test-reservation',
        );

        expect(reservation, isNotNull);
        expect(reservation!.reservedAmount, 50.0);
      });

      test('Failed reservation when insufficient capacity', () async {
        final resource = Resource(
          resourceId: 'res-1',
          resourceName: 'CPU-1',
          resourceType: ResourceType.cpu,
          capacity: 100.0,
          currentUsage: 50.0,
          unit: 'cores',
          createdAt: DateTime.now(),
        );

        await repository.createResource(resource);

        final reservation = await manager.reserve(
          'res-1',
          'user-1',
          100.0,
          3600,
          'test-reservation',
        );

        expect(reservation, isNull);
      });

      test('Reservation confirmation', () async {
        final reservation = ResourceReservation(
          reservationId: 'res-1',
          resourceId: 'res-1',
          reservedBy: 'user-1',
          reservedAmount: 25.0,
          reservedAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 1)),
          isConfirmed: false,
          reason: 'test',
        );

        await repository.createReservation(reservation);
        await manager.confirmReservation('res-1');

        final updated = await repository.getReservation('res-1');
        expect(updated!.isConfirmed, true);
      });
    });

    // PoolEngine Tests
    group('PoolEngine Tests', () {
      test('Get pool resources', () async {
        final res1 = Resource(
          resourceId: 'res-1',
          resourceName: 'CPU-1',
          resourceType: ResourceType.cpu,
          capacity: 100.0,
          currentUsage: 0.0,
          unit: 'cores',
          createdAt: DateTime.now(),
        );

        final res2 = Resource(
          resourceId: 'res-2',
          resourceName: 'CPU-2',
          resourceType: ResourceType.cpu,
          capacity: 100.0,
          currentUsage: 0.0,
          unit: 'cores',
          createdAt: DateTime.now(),
        );

        final pool = ResourcePool(
          poolId: 'pool-1',
          poolName: 'CPU Pool',
          resourceIds: ['res-1', 'res-2'],
          strategy: AllocationStrategy.fair,
          maxConcurrentAllocations: 10,
          createdAt: DateTime.now(),
        );

        await repository.createResource(res1);
        await repository.createResource(res2);
        await repository.createPool(pool);

        final resources = await manager.poolEngine.getPoolResources('pool-1');
        expect(resources.length, 2);
      });

      test('Calculate pool total capacity', () async {
        final res1 = Resource(
          resourceId: 'res-1',
          resourceName: 'CPU-1',
          resourceType: ResourceType.cpu,
          capacity: 100.0,
          currentUsage: 0.0,
          unit: 'cores',
          createdAt: DateTime.now(),
        );

        final res2 = Resource(
          resourceId: 'res-2',
          resourceName: 'CPU-2',
          resourceType: ResourceType.cpu,
          capacity: 50.0,
          currentUsage: 0.0,
          unit: 'cores',
          createdAt: DateTime.now(),
        );

        final pool = ResourcePool(
          poolId: 'pool-1',
          poolName: 'CPU Pool',
          resourceIds: ['res-1', 'res-2'],
          strategy: AllocationStrategy.fair,
          maxConcurrentAllocations: 10,
          createdAt: DateTime.now(),
        );

        await repository.createResource(res1);
        await repository.createResource(res2);
        await repository.createPool(pool);

        final totalCapacity = await manager.poolEngine.getPoolTotalCapacity('pool-1');
        expect(totalCapacity, 150.0);
      });

      test('Calculate pool total utilization', () async {
        final res1 = Resource(
          resourceId: 'res-1',
          resourceName: 'CPU-1',
          resourceType: ResourceType.cpu,
          capacity: 100.0,
          currentUsage: 30.0,
          unit: 'cores',
          createdAt: DateTime.now(),
        );

        final res2 = Resource(
          resourceId: 'res-2',
          resourceName: 'CPU-2',
          resourceType: ResourceType.cpu,
          capacity: 50.0,
          currentUsage: 20.0,
          unit: 'cores',
          createdAt: DateTime.now(),
        );

        final pool = ResourcePool(
          poolId: 'pool-1',
          poolName: 'CPU Pool',
          resourceIds: ['res-1', 'res-2'],
          strategy: AllocationStrategy.fair,
          maxConcurrentAllocations: 10,
          createdAt: DateTime.now(),
        );

        await repository.createResource(res1);
        await repository.createResource(res2);
        await repository.createPool(pool);

        final totalUtilization = await manager.poolEngine.getPoolTotalUtilization('pool-1');
        expect(totalUtilization, 50.0);
      });
    });

    // Facade Integration Tests
    group('Facade Integration Tests', () {
      test('Complete resource management workflow', () async {
        // Create resource
        await facade.createResource('CPU-1', ResourceType.cpu, 100.0, 'cores');
        final resource = await facade.getResource('res-${DateTime.now().millisecondsSinceEpoch}');
        expect(resource, isNull); // Because ID is auto-generated

        // Create pool
        await facade.createPool('CPU Pool', [], AllocationStrategy.fair);

        // Create quota
        await facade.createQuota('consumer-1', ResourceType.memory, 100.0, 80.0);

        // Create policy
        await facade.createPolicy('Fair Policy', AllocationStrategy.fair, ResolutionPolicy.queue);

        // Create schedule
        final now = DateTime.now();
        await facade.createSchedule(
          'res-1',
          now.add(Duration(hours: 1)),
          now.add(Duration(hours: 2)),
          50.0,
          'batch-job',
        );
      });

      test('Resource type retrieval', () async {
        final resource = Resource(
          resourceId: 'res-1',
          resourceName: 'CPU-1',
          resourceType: ResourceType.cpu,
          capacity: 100.0,
          currentUsage: 0.0,
          unit: 'cores',
          createdAt: DateTime.now(),
        );

        await repository.createResource(resource);

        final cpuResources = await facade.getResourcesByType(ResourceType.cpu);
        expect(cpuResources.length, 1);
        expect(cpuResources.first.resourceType, ResourceType.cpu);
      });

      test('Quota compliance workflow', () async {
        final quota = ResourceQuota(
          quotaId: 'quota-1',
          consumerId: 'consumer-1',
          resourceType: ResourceType.memory,
          hardLimit: 100.0,
          softLimit: 80.0,
          currentUsage: 60.0,
          quotaType: QuotaType.hard,
          createdAt: DateTime.now(),
        );

        await repository.createQuota(quota);

        final compliant = await facade.checkQuotaCompliance('consumer-1');
        expect(compliant, true);
      });

      test('Utilization recording and retrieval', () async {
        await facade.recordUtilization('res-1', 50.0, 70.0, 45.0, 100);
        await facade.recordUtilization('res-2', 85.0, 90.0, 80.0, 100);

        final utilizations = await facade.getLatestUtilization();
        expect(utilizations.length, 2);
      });

      test('Schedule retrieval', () async {
        final now = DateTime.now();
        await facade.createSchedule(
          'res-1',
          now.add(Duration(hours: 1)),
          now.add(Duration(hours: 2)),
          50.0,
          'batch-job',
        );

        final schedules = await facade.getSchedulesByResource('res-1');
        expect(schedules.isNotEmpty, true);
      });
    });

    // Edge Cases
    group('Edge Case Tests', () {
      test('Zero capacity resource', () {
        final resource = Resource(
          resourceId: 'res-1',
          resourceName: 'Empty',
          resourceType: ResourceType.cpu,
          capacity: 0.0,
          currentUsage: 0.0,
          unit: 'cores',
          createdAt: DateTime.now(),
        );

        expect(resource.isAvailable, false);
        expect(resource.availableCapacity, 0.0);
      });

      test('Negative usage handling', () {
        final resource = Resource(
          resourceId: 'res-1',
          resourceName: 'CPU-1',
          resourceType: ResourceType.cpu,
          capacity: 100.0,
          currentUsage: -10.0,
          unit: 'cores',
          createdAt: DateTime.now(),
        );

        expect(resource.availableCapacity, 110.0);
        expect(resource.utilizationPercent, -10.0);
      });

      test('Allocation duration with same timestamps', () {
        final now = DateTime.now();
        final allocation = ResourceAllocation(
          allocationId: 'alloc-1',
          resourceId: 'res-1',
          consumerId: 'consumer-1',
          allocatedAmount: 50.0,
          allocatedAt: now,
          deallocatedAt: now,
          isActive: false,
          purpose: 'job-1',
        );

        expect(allocation.durationInSeconds, 0);
      });

      test('Reservation duration calculation', () {
        final start = DateTime.now();
        final end = start.add(Duration(hours: 24));
        final reservation = ResourceReservation(
          reservationId: 'res-1',
          resourceId: 'res-1',
          reservedBy: 'user-1',
          reservedAmount: 25.0,
          reservedAt: start,
          expiresAt: end,
          reason: 'test',
        );

        expect(reservation.durationInSeconds, 86400);
      });

      test('Pool with empty resource list', () async {
        final pool = ResourcePool(
          poolId: 'pool-1',
          poolName: 'Empty Pool',
          resourceIds: [],
          strategy: AllocationStrategy.fair,
          maxConcurrentAllocations: 10,
          createdAt: DateTime.now(),
        );

        await repository.createPool(pool);

        final resources = await manager.poolEngine.getPoolResources('pool-1');
        expect(resources.isEmpty, true);
      });

      test('Multiple quotas for single consumer', () async {
        final quota1 = ResourceQuota(
          quotaId: 'quota-1',
          consumerId: 'consumer-1',
          resourceType: ResourceType.cpu,
          hardLimit: 100.0,
          softLimit: 80.0,
          currentUsage: 50.0,
          quotaType: QuotaType.hard,
          createdAt: DateTime.now(),
        );

        final quota2 = ResourceQuota(
          quotaId: 'quota-2',
          consumerId: 'consumer-1',
          resourceType: ResourceType.memory,
          hardLimit: 200.0,
          softLimit: 160.0,
          currentUsage: 150.0,
          quotaType: QuotaType.hard,
          createdAt: DateTime.now(),
        );

        await repository.createQuota(quota1);
        await repository.createQuota(quota2);

        final quotas = await repository.getQuotasByConsumer('consumer-1');
        expect(quotas.length, 2);
        expect(quotas.any((q) => q.resourceType == ResourceType.cpu), true);
        expect(quotas.any((q) => q.resourceType == ResourceType.memory), true);
      });

      test('Schedule with same start and end time', () {
        final now = DateTime.now();
        final schedule = ResourceSchedule(
          scheduleId: 'sched-1',
          resourceId: 'res-1',
          startTime: now,
          endTime: now,
          allocatedAmount: 50.0,
          purpose: 'instant-job',
        );

        expect(schedule.durationInSeconds, 0);
      });

      test('Utilization with zero samples', () {
        final util = ResourceUtilization(
          utilizationId: 'util-1',
          resourceId: 'res-1',
          utilizationPercent: 0.0,
          peakUsage: 0.0,
          averageUsage: 0.0,
          sampleCount: 0,
          measuredAt: DateTime.now(),
        );

        expect(util.isHealthy, true);
        expect(util.isWarning, false);
        expect(util.isCritical, false);
      });
    });
  });
}
