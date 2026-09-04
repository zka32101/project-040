/// Resource Management & Pooling Models

enum ResourceType { cpu, memory, disk, network, gpu, custom }
enum AllocationStrategy { fair, weighted, priority, exclusive, shared }
enum QuotaType { hard, soft }
enum ResolutionPolicy { fail, queue, preempt, migrate }
enum ResourceState { available, allocated, reserved, unavailable }
enum ConstraintType { hard, soft, preference }

class Resource {
  final String resourceId;
  final String resourceName;
  final ResourceType resourceType;
  final double capacity;
  final double currentUsage;
  final String unit;
  final DateTime createdAt;
  final ResourceState state;
  final Map<String, dynamic> metadata;

  Resource({
    required this.resourceId,
    required this.resourceName,
    required this.resourceType,
    required this.capacity,
    required this.currentUsage,
    required this.unit,
    required this.createdAt,
    this.state = ResourceState.available,
    this.metadata = const {},
  });

  double get availableCapacity => capacity - currentUsage;
  bool get isAvailable => state == ResourceState.available && availableCapacity > 0;
  double get utilizationPercent => capacity > 0 ? (currentUsage / capacity) * 100 : 0.0;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class ResourcePool {
  final String poolId;
  final String poolName;
  final List<String> resourceIds;
  final AllocationStrategy strategy;
  final int maxConcurrentAllocations;
  final String description;
  final DateTime createdAt;
  final bool isEnabled;

  ResourcePool({
    required this.poolId,
    required this.poolName,
    required this.resourceIds,
    required this.strategy,
    required this.maxConcurrentAllocations,
    this.description = '',
    required this.createdAt,
    this.isEnabled = true,
  });

  bool get hasResources => resourceIds.isNotEmpty;
  int get resourceCount => resourceIds.length;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class ResourceAllocation {
  final String allocationId;
  final String resourceId;
  final String consumerId;
  final double allocatedAmount;
  final DateTime allocatedAt;
  final DateTime? deallocatedAt;
  final bool isActive;
  final String purpose;

  ResourceAllocation({
    required this.allocationId,
    required this.resourceId,
    required this.consumerId,
    required this.allocatedAmount,
    required this.allocatedAt,
    this.deallocatedAt,
    this.isActive = true,
    required this.purpose,
  });

  bool get isCompleted => deallocatedAt != null;
  int get durationInSeconds => deallocatedAt != null ? deallocatedAt!.difference(allocatedAt).inSeconds : 0;
  int get ageInSeconds => DateTime.now().difference(allocatedAt).inSeconds;
}

class ResourceQuota {
  final String quotaId;
  final String consumerId;
  final ResourceType resourceType;
  final double hardLimit;
  final double softLimit;
  final double currentUsage;
  final QuotaType quotaType;
  final DateTime createdAt;

  ResourceQuota({
    required this.quotaId,
    required this.consumerId,
    required this.resourceType,
    required this.hardLimit,
    required this.softLimit,
    required this.currentUsage,
    required this.quotaType,
    required this.createdAt,
  });

  bool get isExceeded => currentUsage > hardLimit;
  bool get isSoftLimitExceeded => currentUsage > softLimit;
  double get remainingQuota => (hardLimit - currentUsage).clamp(0.0, double.infinity);
  double get utilizationPercent => hardLimit > 0 ? (currentUsage / hardLimit) * 100 : 0.0;
}

class ResourceUtilization {
  final String utilizationId;
  final String resourceId;
  final double utilizationPercent;
  final double peakUsage;
  final double averageUsage;
  final int sampleCount;
  final DateTime measuredAt;
  final String status;

  ResourceUtilization({
    required this.utilizationId,
    required this.resourceId,
    required this.utilizationPercent,
    required this.peakUsage,
    required this.averageUsage,
    required this.sampleCount,
    required this.measuredAt,
    this.status = 'normal',
  });

  bool get isHealthy => utilizationPercent < 80.0;
  bool get isWarning => utilizationPercent >= 80.0 && utilizationPercent < 95.0;
  bool get isCritical => utilizationPercent >= 95.0;
  int get ageInSeconds => DateTime.now().difference(measuredAt).inSeconds;
}

class ResourceReservation {
  final String reservationId;
  final String resourceId;
  final String reservedBy;
  final double reservedAmount;
  final DateTime reservedAt;
  final DateTime expiresAt;
  final bool isConfirmed;
  final String reason;

  ResourceReservation({
    required this.reservationId,
    required this.resourceId,
    required this.reservedBy,
    required this.reservedAmount,
    required this.reservedAt,
    required this.expiresAt,
    this.isConfirmed = false,
    required this.reason,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => !isExpired && isConfirmed;
  int get durationInSeconds => expiresAt.difference(reservedAt).inSeconds;
  int get remainingSeconds => (expiresAt.difference(DateTime.now()).inSeconds).clamp(0, double.infinity).toInt();
}

class ResourceConstraint {
  final String constraintId;
  final String resourceId;
  final ConstraintType constraintType;
  final String name;
  final Map<String, dynamic> parameters;
  final String description;
  final bool isEnforced;

  ResourceConstraint({
    required this.constraintId,
    required this.resourceId,
    required this.constraintType,
    required this.name,
    required this.parameters,
    this.description = '',
    this.isEnforced = true,
  });

  bool get hasParameters => parameters.isNotEmpty;
  int get parameterCount => parameters.length;
}

class ResourceMetrics {
  final String metricsId;
  final String resourceId;
  final double totalAllocations;
  final double successfulAllocations;
  final double failedAllocations;
  final double averageAllocationTime;
  final double peakUtilization;
  final DateTime periodStart;
  final DateTime periodEnd;

  ResourceMetrics({
    required this.metricsId,
    required this.resourceId,
    required this.totalAllocations,
    required this.successfulAllocations,
    required this.failedAllocations,
    required this.averageAllocationTime,
    required this.peakUtilization,
    required this.periodStart,
    required this.periodEnd,
  });

  double get successRate => totalAllocations > 0 ? (successfulAllocations / totalAllocations) * 100 : 0.0;
  double get failureRate => totalAllocations > 0 ? (failedAllocations / totalAllocations) * 100 : 0.0;
  bool get isHealthy => successRate >= 95.0;
}

class ResourceSchedule {
  final String scheduleId;
  final String resourceId;
  final DateTime startTime;
  final DateTime endTime;
  final double allocatedAmount;
  final String purpose;
  final bool isConfirmed;

  ResourceSchedule({
    required this.scheduleId,
    required this.resourceId,
    required this.startTime,
    required this.endTime,
    required this.allocatedAmount,
    required this.purpose,
    this.isConfirmed = false,
  });

  bool get isUpcoming => DateTime.now().isBefore(startTime);
  bool get isActive => DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get isExpired => DateTime.now().isAfter(endTime);
  int get durationInSeconds => endTime.difference(startTime).inSeconds;
}

class ResourcePolicy {
  final String policyId;
  final String policyName;
  final AllocationStrategy strategy;
  final ResolutionPolicy resolutionPolicy;
  final int maxRetries;
  final int timeoutSeconds;
  final String description;
  final bool isActive;

  ResourcePolicy({
    required this.policyId,
    required this.policyName,
    required this.strategy,
    required this.resolutionPolicy,
    required this.maxRetries,
    required this.timeoutSeconds,
    this.description = '',
    this.isActive = true,
  });

  bool get hasDescription => description.isNotEmpty;
}

class ResourceLimit {
  final String limitId;
  final String resourceId;
  final double minThreshold;
  final double maxThreshold;
  final int warningLevel;
  final int criticalLevel;
  final bool isEnforced;
  final DateTime createdAt;

  ResourceLimit({
    required this.limitId,
    required this.resourceId,
    required this.minThreshold,
    required this.maxThreshold,
    required this.warningLevel,
    required this.criticalLevel,
    this.isEnforced = true,
    required this.createdAt,
  });

  bool get hasValidRange => minThreshold < maxThreshold;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class ResourceAffinity {
  final String affinityId;
  final String resourceId;
  final List<String> preferredNodes;
  final List<String> forbiddenNodes;
  final String affinityRule;
  final bool isRequired;

  ResourceAffinity({
    required this.affinityId,
    required this.resourceId,
    required this.preferredNodes,
    required this.forbiddenNodes,
    required this.affinityRule,
    this.isRequired = false,
  });

  bool get hasPreferredNodes => preferredNodes.isNotEmpty;
  bool get hasForbiddenNodes => forbiddenNodes.isNotEmpty;
  int get totalNodeConstraints => preferredNodes.length + forbiddenNodes.length;
}
