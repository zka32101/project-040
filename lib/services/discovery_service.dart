import '../models/discovery_models.dart';

abstract class DiscoveryRepository {
  Future<void> registerService(ServiceRegistry registry);
  Future<ServiceRegistry?> getRegistry(String registryId);
  Future<List<ServiceRegistry>> getAllServices();
  Future<List<ServiceRegistry>> getServicesByName(String serviceName);
  Future<void> updateRegistry(ServiceRegistry registry);

  Future<void> registerInstance(ServiceInstance instance);
  Future<ServiceInstance?> getInstance(String instanceId);
  Future<List<ServiceInstance>> getServiceInstances(String registryId);
  Future<List<ServiceInstance>> getInstancesByStatus(ServiceStatus status);
  Future<void> updateInstance(ServiceInstance instance);

  Future<void> createHealthCheck(HealthCheck check);
  Future<HealthCheck?> getHealthCheck(String checkId);
  Future<List<HealthCheck>> getInstanceChecks(String instanceId);

  Future<void> recordHealthStatus(HealthStatus status);
  Future<HealthStatus?> getLatestStatus(String instanceId);
  Future<List<HealthStatus>> getInstanceStatusHistory(String instanceId);

  Future<void> registerNode(ServiceNode node);
  Future<ServiceNode?> getNode(String nodeId);
  Future<List<ServiceNode>> getAllNodes();
  Future<List<ServiceNode>> getNodesByStatus(NodeStatus status);
  Future<void> updateNode(ServiceNode node);

  Future<void> createDependency(ServiceDependency dependency);
  Future<List<ServiceDependency>> getServiceDependencies(String serviceId);
  Future<List<ServiceDependency>> getDependentsOf(String serviceId);

  Future<void> recordMetrics(HealthMetrics metrics);
  Future<HealthMetrics?> getLatestMetrics(String instanceId);
  Future<List<HealthMetrics>> getMetricsHistory(String instanceId);

  Future<void> createAlert(ServiceAlert alert);
  Future<ServiceAlert?> getAlert(String alertId);
  Future<List<ServiceAlert>> getInstanceAlerts(String instanceId);
  Future<List<ServiceAlert>> getActiveAlerts();
  Future<void> updateAlert(ServiceAlert alert);

  Future<void> recordEvent(DiscoveryEvent event);
  Future<List<DiscoveryEvent>> getServiceEvents(String serviceId);
  Future<List<DiscoveryEvent>> getRecentEvents(int limitSeconds);

  Future<void> saveHealthReport(HealthReport report);
  Future<HealthReport?> getLatestReport(String instanceId);

  Future<void> createLoadBalancer(LoadBalancer balancer);
  Future<LoadBalancer?> getLoadBalancer(String balancerId);
  Future<List<LoadBalancer>> getAllLoadBalancers();

  Future<void> createServiceMesh(ServiceMesh mesh);
  Future<ServiceMesh?> getServiceMesh(String meshId);
  Future<List<ServiceMesh>> getAllMeshes();

  Future<void> recordNodeMetrics(NodeMetrics metrics);
  Future<NodeMetrics?> getLatestNodeMetrics(String nodeId);
}

class MemoryDiscoveryRepository implements DiscoveryRepository {
  final Map<String, ServiceRegistry> _registries = {};
  final Map<String, ServiceInstance> _instances = {};
  final Map<String, HealthCheck> _checks = {};
  final Map<String, HealthStatus> _statuses = {};
  final Map<String, ServiceNode> _nodes = {};
  final Map<String, ServiceDependency> _dependencies = {};
  final Map<String, HealthMetrics> _metrics = {};
  final Map<String, ServiceAlert> _alerts = {};
  final Map<String, DiscoveryEvent> _events = {};
  final Map<String, HealthReport> _reports = {};
  final Map<String, LoadBalancer> _balancers = {};
  final Map<String, ServiceMesh> _meshes = {};
  final Map<String, NodeMetrics> _nodeMetrics = {};

  @override
  Future<void> registerService(ServiceRegistry registry) async =>
      _registries[registry.registryId] = registry;

  @override
  Future<ServiceRegistry?> getRegistry(String registryId) async =>
      _registries[registryId];

  @override
  Future<List<ServiceRegistry>> getAllServices() async =>
      _registries.values.toList();

  @override
  Future<List<ServiceRegistry>> getServicesByName(String serviceName) async =>
      _registries.values.where((s) => s.serviceName == serviceName).toList();

  @override
  Future<void> updateRegistry(ServiceRegistry registry) async =>
      _registries[registry.registryId] = registry;

  @override
  Future<void> registerInstance(ServiceInstance instance) async =>
      _instances[instance.instanceId] = instance;

  @override
  Future<ServiceInstance?> getInstance(String instanceId) async =>
      _instances[instanceId];

  @override
  Future<List<ServiceInstance>> getServiceInstances(String registryId) async =>
      _instances.values.where((i) => i.registryId == registryId).toList();

  @override
  Future<List<ServiceInstance>> getInstancesByStatus(ServiceStatus status) async =>
      _instances.values.where((i) => i.status == status).toList();

  @override
  Future<void> updateInstance(ServiceInstance instance) async =>
      _instances[instance.instanceId] = instance;

  @override
  Future<void> createHealthCheck(HealthCheck check) async =>
      _checks[check.checkId] = check;

  @override
  Future<HealthCheck?> getHealthCheck(String checkId) async =>
      _checks[checkId];

  @override
  Future<List<HealthCheck>> getInstanceChecks(String instanceId) async =>
      _checks.values.where((c) => c.instanceId == instanceId).toList();

  @override
  Future<void> recordHealthStatus(HealthStatus status) async =>
      _statuses[status.statusId] = status;

  @override
  Future<HealthStatus?> getLatestStatus(String instanceId) async {
    final statuses = _statuses.values.where((s) => s.instanceId == instanceId).toList();
    return statuses.isNotEmpty ? statuses.last : null;
  }

  @override
  Future<List<HealthStatus>> getInstanceStatusHistory(String instanceId) async =>
      _statuses.values.where((s) => s.instanceId == instanceId).toList();

  @override
  Future<void> registerNode(ServiceNode node) async =>
      _nodes[node.nodeId] = node;

  @override
  Future<ServiceNode?> getNode(String nodeId) async =>
      _nodes[nodeId];

  @override
  Future<List<ServiceNode>> getAllNodes() async =>
      _nodes.values.toList();

  @override
  Future<List<ServiceNode>> getNodesByStatus(NodeStatus status) async =>
      _nodes.values.where((n) => n.status == status).toList();

  @override
  Future<void> updateNode(ServiceNode node) async =>
      _nodes[node.nodeId] = node;

  @override
  Future<void> createDependency(ServiceDependency dependency) async =>
      _dependencies[dependency.dependencyId] = dependency;

  @override
  Future<List<ServiceDependency>> getServiceDependencies(String serviceId) async =>
      _dependencies.values.where((d) => d.serviceId == serviceId).toList();

  @override
  Future<List<ServiceDependency>> getDependentsOf(String serviceId) async =>
      _dependencies.values.where((d) => d.dependsOnServiceId == serviceId).toList();

  @override
  Future<void> recordMetrics(HealthMetrics metrics) async =>
      _metrics[metrics.metricsId] = metrics;

  @override
  Future<HealthMetrics?> getLatestMetrics(String instanceId) async {
    final metrics = _metrics.values.where((m) => m.instanceId == instanceId).toList();
    return metrics.isNotEmpty ? metrics.last : null;
  }

  @override
  Future<List<HealthMetrics>> getMetricsHistory(String instanceId) async =>
      _metrics.values.where((m) => m.instanceId == instanceId).toList();

  @override
  Future<void> createAlert(ServiceAlert alert) async =>
      _alerts[alert.alertId] = alert;

  @override
  Future<ServiceAlert?> getAlert(String alertId) async =>
      _alerts[alertId];

  @override
  Future<List<ServiceAlert>> getInstanceAlerts(String instanceId) async =>
      _alerts.values.where((a) => a.instanceId == instanceId).toList();

  @override
  Future<List<ServiceAlert>> getActiveAlerts() async =>
      _alerts.values.where((a) => a.isActive).toList();

  @override
  Future<void> updateAlert(ServiceAlert alert) async =>
      _alerts[alert.alertId] = alert;

  @override
  Future<void> recordEvent(DiscoveryEvent event) async =>
      _events[event.eventId] = event;

  @override
  Future<List<DiscoveryEvent>> getServiceEvents(String serviceId) async =>
      _events.values.where((e) => e.serviceId == serviceId).toList();

  @override
  Future<List<DiscoveryEvent>> getRecentEvents(int limitSeconds) async {
    final cutoff = DateTime.now().subtract(Duration(seconds: limitSeconds));
    return _events.values.where((e) => e.timestamp.isAfter(cutoff)).toList();
  }

  @override
  Future<void> saveHealthReport(HealthReport report) async =>
      _reports[report.reportId] = report;

  @override
  Future<HealthReport?> getLatestReport(String instanceId) async {
    final reports = _reports.values.where((r) => r.instanceId == instanceId).toList();
    return reports.isNotEmpty ? reports.last : null;
  }

  @override
  Future<void> createLoadBalancer(LoadBalancer balancer) async =>
      _balancers[balancer.balancerId] = balancer;

  @override
  Future<LoadBalancer?> getLoadBalancer(String balancerId) async =>
      _balancers[balancerId];

  @override
  Future<List<LoadBalancer>> getAllLoadBalancers() async =>
      _balancers.values.toList();

  @override
  Future<void> createServiceMesh(ServiceMesh mesh) async =>
      _meshes[mesh.meshId] = mesh;

  @override
  Future<ServiceMesh?> getServiceMesh(String meshId) async =>
      _meshes[meshId];

  @override
  Future<List<ServiceMesh>> getAllMeshes() async =>
      _meshes.values.toList();

  @override
  Future<void> recordNodeMetrics(NodeMetrics metrics) async =>
      _nodeMetrics[metrics.metricsId] = metrics;

  @override
  Future<NodeMetrics?> getLatestNodeMetrics(String nodeId) async {
    final metrics = _nodeMetrics.values.where((m) => m.nodeId == nodeId).toList();
    return metrics.isNotEmpty ? metrics.last : null;
  }
}

class HealthCheckEngine {
  final DiscoveryRepository repository;

  HealthCheckEngine(this.repository);

  Future<HealthStatus> performHealthCheck(String checkId) async {
    final check = await repository.getHealthCheck(checkId);
    if (check == null) {
      throw Exception('Health check not found');
    }

    final status = HealthStatus(
      statusId: 'status-${DateTime.now().millisecondsSinceEpoch}',
      instanceId: check.instanceId,
      state: HealthState.pass,
      checkedAt: DateTime.now(),
      responseTimeMs: 100,
    );

    await repository.recordHealthStatus(status);
    return status;
  }

  Future<void> markInstanceHealthy(String instanceId) async {
    final instance = await repository.getInstance(instanceId);
    if (instance != null) {
      final healthy = ServiceInstance(
        instanceId: instance.instanceId,
        registryId: instance.registryId,
        host: instance.host,
        port: instance.port,
        protocol: instance.protocol,
        startedAt: instance.startedAt,
        status: ServiceStatus.healthy,
        tags: instance.tags,
        healthCheckPath: instance.healthCheckPath,
      );
      await repository.updateInstance(healthy);
    }
  }

  Future<void> markInstanceUnhealthy(String instanceId) async {
    final instance = await repository.getInstance(instanceId);
    if (instance != null) {
      final unhealthy = ServiceInstance(
        instanceId: instance.instanceId,
        registryId: instance.registryId,
        host: instance.host,
        port: instance.port,
        protocol: instance.protocol,
        startedAt: instance.startedAt,
        status: ServiceStatus.unhealthy,
        tags: instance.tags,
        healthCheckPath: instance.healthCheckPath,
      );
      await repository.updateInstance(unhealthy);
    }
  }
}

class ServiceDiscoveryEngine {
  final DiscoveryRepository repository;

  ServiceDiscoveryEngine(this.repository);

  Future<List<ServiceInstance>> discoverService(String serviceName) async {
    final registries = await repository.getServicesByName(serviceName);
    final allInstances = <ServiceInstance>[];
    for (final registry in registries) {
      final instances = await repository.getServiceInstances(registry.registryId);
      allInstances.addAll(instances.where((i) => i.isHealthy));
    }
    return allInstances;
  }

  Future<void> recordDiscoveryEvent(String serviceId, EventType eventType, String description) async {
    final event = DiscoveryEvent(
      eventId: 'event-${DateTime.now().millisecondsSinceEpoch}',
      eventType: eventType,
      serviceId: serviceId,
      timestamp: DateTime.now(),
      description: description,
    );
    await repository.recordEvent(event);
  }
}

class MetricsCollectionEngine {
  final DiscoveryRepository repository;

  MetricsCollectionEngine(this.repository);

  Future<void> recordInstanceMetrics(
    String instanceId,
    double cpuUsage,
    double memoryUsage,
    double diskUsage,
    int requestCount,
    double errorRate,
    double avgResponseTime,
  ) async {
    final metrics = HealthMetrics(
      metricsId: 'metric-${DateTime.now().millisecondsSinceEpoch}',
      instanceId: instanceId,
      cpuUsage: cpuUsage,
      memoryUsage: memoryUsage,
      diskUsage: diskUsage,
      requestCount: requestCount,
      errorRate: errorRate,
      averageResponseTime: avgResponseTime,
      measuredAt: DateTime.now(),
    );
    await repository.recordMetrics(metrics);
  }
}

class AlertEngine {
  final DiscoveryRepository repository;

  AlertEngine(this.repository);

  Future<void> createAlert(
    String instanceId,
    AlertSeverity severity,
    String alertType,
    String message,
  ) async {
    final alert = ServiceAlert(
      alertId: 'alert-${DateTime.now().millisecondsSinceEpoch}',
      instanceId: instanceId,
      severity: severity,
      alertType: alertType,
      message: message,
      createdAt: DateTime.now(),
    );
    await repository.createAlert(alert);
  }

  Future<void> resolveAlert(String alertId) async {
    final alert = await repository.getAlert(alertId);
    if (alert != null && alert.isActive) {
      final resolved = ServiceAlert(
        alertId: alert.alertId,
        instanceId: alert.instanceId,
        severity: alert.severity,
        alertType: alert.alertType,
        message: alert.message,
        createdAt: alert.createdAt,
        resolvedAt: DateTime.now(),
        isActive: false,
      );
      await repository.updateAlert(resolved);
    }
  }
}

class DiscoveryManager {
  final DiscoveryRepository repository;
  late final HealthCheckEngine healthEngine;
  late final ServiceDiscoveryEngine discoveryEngine;
  late final MetricsCollectionEngine metricsEngine;
  late final AlertEngine alertEngine;

  DiscoveryManager(this.repository) {
    healthEngine = HealthCheckEngine(repository);
    discoveryEngine = ServiceDiscoveryEngine(repository);
    metricsEngine = MetricsCollectionEngine(repository);
    alertEngine = AlertEngine(repository);
  }
}

class DiscoveryFacade {
  final DiscoveryManager manager;

  DiscoveryFacade(this.manager);

  Future<void> registerService(
    String serviceName,
    String version,
    String registeredBy,
  ) async {
    final registry = ServiceRegistry(
      registryId: 'svc-${DateTime.now().millisecondsSinceEpoch}',
      serviceName: serviceName,
      serviceVersion: version,
      instanceIds: [],
      registeredAt: DateTime.now(),
      registeredBy: registeredBy,
    );
    await manager.repository.registerService(registry);
  }

  Future<void> registerInstance(
    String registryId,
    String host,
    int port,
    String protocol,
  ) async {
    final instance = ServiceInstance(
      instanceId: 'inst-${DateTime.now().millisecondsSinceEpoch}',
      registryId: registryId,
      host: host,
      port: port,
      protocol: protocol,
      startedAt: DateTime.now(),
    );
    await manager.repository.registerInstance(instance);
  }

  Future<List<ServiceInstance>> discoverService(String serviceName) =>
      manager.discoveryEngine.discoverService(serviceName);

  Future<void> createHealthCheck(
    String instanceId,
    CheckType checkType,
    String checkName,
  ) async {
    final check = HealthCheck(
      checkId: 'check-${DateTime.now().millisecondsSinceEpoch}',
      instanceId: instanceId,
      checkType: checkType,
      checkName: checkName,
      intervalSeconds: 30,
      timeoutSeconds: 5,
      checkConfig: {},
    );
    await manager.repository.createHealthCheck(check);
  }

  Future<HealthStatus?> getHealthStatus(String instanceId) =>
      manager.repository.getLatestStatus(instanceId);

  Future<HealthMetrics?> getMetrics(String instanceId) =>
      manager.repository.getLatestMetrics(instanceId);

  Future<void> recordMetrics(
    String instanceId,
    double cpu,
    double memory,
    double disk,
    int requests,
    double errors,
    double avgTime,
  ) =>
      manager.metricsEngine.recordInstanceMetrics(
        instanceId,
        cpu,
        memory,
        disk,
        requests,
        errors,
        avgTime,
      );

  Future<List<ServiceAlert>> getActiveAlerts() =>
      manager.repository.getActiveAlerts();

  Future<void> createAlert(String instanceId, AlertSeverity severity, String message) =>
      manager.alertEngine.createAlert(
        instanceId,
        severity,
        'health_alert',
        message,
      );

  Future<void> resolveAlert(String alertId) =>
      manager.alertEngine.resolveAlert(alertId);

  Future<void> registerNode(String nodeName, String ipAddress, int port) async {
    final node = ServiceNode(
      nodeId: 'node-${DateTime.now().millisecondsSinceEpoch}',
      nodeName: nodeName,
      ipAddress: ipAddress,
      port: port,
      joinedAt: DateTime.now(),
    );
    await manager.repository.registerNode(node);
  }

  Future<List<ServiceNode>> getAllNodes() =>
      manager.repository.getAllNodes();

  Future<void> createLoadBalancer(String name, List<String> instanceIds) async {
    final balancer = LoadBalancer(
      balancerId: 'lb-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      instanceIds: instanceIds,
      createdAt: DateTime.now(),
    );
    await manager.repository.createLoadBalancer(balancer);
  }

  Future<List<LoadBalancer>> getAllLoadBalancers() =>
      manager.repository.getAllLoadBalancers();

  Future<void> createServiceMesh(String meshName, List<String> serviceIds) async {
    final mesh = ServiceMesh(
      meshId: 'mesh-${DateTime.now().millisecondsSinceEpoch}',
      meshName: meshName,
      serviceIds: serviceIds,
      createdAt: DateTime.now(),
    );
    await manager.repository.createServiceMesh(mesh);
  }

  Future<List<ServiceMesh>> getAllMeshes() =>
      manager.repository.getAllMeshes();
}
