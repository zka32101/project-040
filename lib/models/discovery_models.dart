/// Service Discovery & Health Monitoring Models

enum ServiceStatus { healthy, degraded, unhealthy, offline }
enum CheckType { http, tcp, script, grpc }
enum HealthState { pass, warn, fail }
enum AlertSeverity { info, warning, critical }
enum EventType { registered, deregistered, health_changed, metric_updated }
enum NodeStatus { up, down, unknown }

class ServiceRegistry {
  final String registryId;
  final String serviceName;
  final String serviceVersion;
  final List<String> instanceIds;
  final DateTime registeredAt;
  final String registeredBy;
  final Map<String, dynamic> metadata;
  final bool isEnabled;

  ServiceRegistry({
    required this.registryId,
    required this.serviceName,
    required this.serviceVersion,
    required this.instanceIds,
    required this.registeredAt,
    required this.registeredBy,
    this.metadata = const {},
    this.isEnabled = true,
  });

  bool get hasInstances => instanceIds.isNotEmpty;
  int get instanceCount => instanceIds.length;
  int get ageInDays => DateTime.now().difference(registeredAt).inDays;
  bool get hasMetadata => metadata.isNotEmpty;
}

class ServiceInstance {
  final String instanceId;
  final String registryId;
  final String host;
  final int port;
  final String protocol;
  final DateTime startedAt;
  final ServiceStatus status;
  final Map<String, dynamic> tags;
  final String? healthCheckPath;

  ServiceInstance({
    required this.instanceId,
    required this.registryId,
    required this.host,
    required this.port,
    required this.protocol,
    required this.startedAt,
    this.status = ServiceStatus.healthy,
    this.tags = const {},
    this.healthCheckPath,
  });

  bool get isHealthy => status == ServiceStatus.healthy;
  bool get isOffline => status == ServiceStatus.offline;
  int get ageInDays => DateTime.now().difference(startedAt).inDays;
  int get uptimeSeconds => DateTime.now().difference(startedAt).inSeconds;
  bool get hasTags => tags.isNotEmpty;
  String get endpoint => '$protocol://$host:$port';
}

class HealthCheck {
  final String checkId;
  final String instanceId;
  final CheckType checkType;
  final String checkName;
  final int intervalSeconds;
  final int timeoutSeconds;
  final Map<String, dynamic> checkConfig;
  final bool isEnabled;
  final List<int> expectedHttpStatuses;

  HealthCheck({
    required this.checkId,
    required this.instanceId,
    required this.checkType,
    required this.checkName,
    required this.intervalSeconds,
    required this.timeoutSeconds,
    required this.checkConfig,
    this.isEnabled = true,
    this.expectedHttpStatuses = const [200, 201, 204],
  });

  bool get isHttpCheck => checkType == CheckType.http;
  bool get isTcpCheck => checkType == CheckType.tcp;
  bool get hasConfig => checkConfig.isNotEmpty;
}

class HealthStatus {
  final String statusId;
  final String instanceId;
  final HealthState state;
  final DateTime checkedAt;
  final int? responseTimeMs;
  final String? message;
  final Map<String, dynamic> details;

  HealthStatus({
    required this.statusId,
    required this.instanceId,
    required this.state,
    required this.checkedAt,
    this.responseTimeMs,
    this.message,
    this.details = const {},
  });

  bool get isHealthy => state == HealthState.pass;
  bool get isWarning => state == HealthState.warn;
  bool get isFailing => state == HealthState.fail;
  int get ageInSeconds => DateTime.now().difference(checkedAt).inSeconds;
  bool get isStale => ageInSeconds > 300;
  bool get hasDetails => details.isNotEmpty;
}

class ServiceNode {
  final String nodeId;
  final String nodeName;
  final String ipAddress;
  final int port;
  final NodeStatus status;
  final DateTime joinedAt;
  final List<String> services;
  final Map<String, dynamic> metadata;

  ServiceNode({
    required this.nodeId,
    required this.nodeName,
    required this.ipAddress,
    required this.port,
    this.status = NodeStatus.unknown,
    required this.joinedAt,
    this.services = const [],
    this.metadata = const {},
  });

  bool get isUp => status == NodeStatus.up;
  bool get isDown => status == NodeStatus.down;
  int get serviceCount => services.length;
  int get ageInDays => DateTime.now().difference(joinedAt).inDays;
  String get address => '$ipAddress:$port';
}

class ServiceDependency {
  final String dependencyId;
  final String serviceId;
  final String dependsOnServiceId;
  final String dependencyType;
  final bool isRequired;
  final int timeoutSeconds;
  final DateTime createdAt;

  ServiceDependency({
    required this.dependencyId,
    required this.serviceId,
    required this.dependsOnServiceId,
    required this.dependencyType,
    this.isRequired = true,
    this.timeoutSeconds = 5,
    required this.createdAt,
  });

  bool get isOptional => !isRequired;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class HealthMetrics {
  final String metricsId;
  final String instanceId;
  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;
  final int requestCount;
  final double errorRate;
  final double averageResponseTime;
  final DateTime measuredAt;

  HealthMetrics({
    required this.metricsId,
    required this.instanceId,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.requestCount,
    required this.errorRate,
    required this.averageResponseTime,
    required this.measuredAt,
  });

  bool get isCpuHealthy => cpuUsage < 80.0;
  bool get isMemoryHealthy => memoryUsage < 85.0;
  bool get isDiskHealthy => diskUsage < 90.0;
  bool get isErrorRateHealthy => errorRate < 5.0;
  bool get isResponsiveHealthy => averageResponseTime < 1000.0;
  bool get isOverallHealthy =>
      isCpuHealthy && isMemoryHealthy && isDiskHealthy && isErrorRateHealthy;
  int get ageInSeconds => DateTime.now().difference(measuredAt).inSeconds;
}

class ServiceAlert {
  final String alertId;
  final String instanceId;
  final AlertSeverity severity;
  final String alertType;
  final String message;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final bool isActive;

  ServiceAlert({
    required this.alertId,
    required this.instanceId,
    required this.severity,
    required this.alertType,
    required this.message,
    required this.createdAt,
    this.resolvedAt,
    this.isActive = true,
  });

  bool get isResolved => resolvedAt != null;
  int get durationInSeconds => resolvedAt != null
      ? resolvedAt!.difference(createdAt).inSeconds
      : DateTime.now().difference(createdAt).inSeconds;
  int get ageInMinutes => DateTime.now().difference(createdAt).inMinutes;
}

class DiscoveryEvent {
  final String eventId;
  final EventType eventType;
  final String serviceId;
  final String? instanceId;
  final DateTime timestamp;
  final String description;
  final Map<String, dynamic> metadata;

  DiscoveryEvent({
    required this.eventId,
    required this.eventType,
    required this.serviceId,
    this.instanceId,
    required this.timestamp,
    required this.description,
    this.metadata = const {},
  });

  bool get isRegistration => eventType == EventType.registered;
  bool get isDeregistration => eventType == EventType.deregistered;
  bool get isHealthChange => eventType == EventType.health_changed;
  int get ageInSeconds => DateTime.now().difference(timestamp).inSeconds;
  bool get hasMetadata => metadata.isNotEmpty;
}

class HealthReport {
  final String reportId;
  final String instanceId;
  final HealthState overallState;
  final DateTime generatedAt;
  final List<String> checkResults;
  final double healthScore;
  final Map<String, dynamic> summary;

  HealthReport({
    required this.reportId,
    required this.instanceId,
    required this.overallState,
    required this.generatedAt,
    required this.checkResults,
    required this.healthScore,
    this.summary = const {},
  });

  bool get isHealthy => overallState == HealthState.pass && healthScore >= 95.0;
  int get checkCount => checkResults.length;
  int get ageInMinutes => DateTime.now().difference(generatedAt).inMinutes;
  bool get hasSummary => summary.isNotEmpty;
}

class LoadBalancer {
  final String balancerId;
  final String name;
  final List<String> instanceIds;
  final String algorithm;
  final bool isEnabled;
  final int healthCheckIntervalSeconds;
  final DateTime createdAt;

  LoadBalancer({
    required this.balancerId,
    required this.name,
    required this.instanceIds,
    this.algorithm = 'round_robin',
    this.isEnabled = true,
    this.healthCheckIntervalSeconds = 30,
    required this.createdAt,
  });

  bool get hasInstances => instanceIds.isNotEmpty;
  int get instanceCount => instanceIds.length;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class ServiceMesh {
  final String meshId;
  final String meshName;
  final List<String> serviceIds;
  final DateTime createdAt;
  final bool isEnabled;
  final Map<String, dynamic> config;

  ServiceMesh({
    required this.meshId,
    required this.meshName,
    required this.serviceIds,
    required this.createdAt,
    this.isEnabled = true,
    this.config = const {},
  });

  bool get hasServices => serviceIds.isNotEmpty;
  int get serviceCount => serviceIds.length;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  bool get hasConfig => config.isNotEmpty;
}

class NodeMetrics {
  final String metricsId;
  final String nodeId;
  final double cpuUsage;
  final double memoryUsage;
  final double networkIn;
  final double networkOut;
  final int processCount;
  final DateTime measuredAt;

  NodeMetrics({
    required this.metricsId,
    required this.nodeId,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.networkIn,
    required this.networkOut,
    required this.processCount,
    required this.measuredAt,
  });

  bool get isCpuHealthy => cpuUsage < 80.0;
  bool get isMemoryHealthy => memoryUsage < 85.0;
  int get ageInSeconds => DateTime.now().difference(measuredAt).inSeconds;
}
