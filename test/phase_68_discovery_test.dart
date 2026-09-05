import 'package:test/test.dart';
import '../lib/models/discovery_models.dart';
import '../lib/services/discovery_service.dart';

void main() {
  group('Phase 68: Service Discovery & Health Monitoring Tests', () {
    late MemoryDiscoveryRepository repository;
    late DiscoveryManager manager;
    late DiscoveryFacade facade;

    setUp(() {
      repository = MemoryDiscoveryRepository();
      manager = DiscoveryManager(repository);
      facade = DiscoveryFacade(manager);
    });

    // Enum Tests
    group('Enum Tests', () {
      test('ServiceStatus enum values', () {
        expect(ServiceStatus.values, contains(ServiceStatus.healthy));
        expect(ServiceStatus.values, contains(ServiceStatus.degraded));
        expect(ServiceStatus.values, contains(ServiceStatus.unhealthy));
        expect(ServiceStatus.values, contains(ServiceStatus.offline));
      });

      test('CheckType enum values', () {
        expect(CheckType.values, contains(CheckType.http));
        expect(CheckType.values, contains(CheckType.tcp));
        expect(CheckType.values, contains(CheckType.script));
        expect(CheckType.values, contains(CheckType.grpc));
      });

      test('HealthState enum values', () {
        expect(HealthState.values, contains(HealthState.pass));
        expect(HealthState.values, contains(HealthState.warn));
        expect(HealthState.values, contains(HealthState.fail));
      });

      test('AlertSeverity enum values', () {
        expect(AlertSeverity.values, contains(AlertSeverity.info));
        expect(AlertSeverity.values, contains(AlertSeverity.warning));
        expect(AlertSeverity.values, contains(AlertSeverity.critical));
      });

      test('EventType enum values', () {
        expect(EventType.values, contains(EventType.registered));
        expect(EventType.values, contains(EventType.deregistered));
        expect(EventType.values, contains(EventType.health_changed));
        expect(EventType.values, contains(EventType.metric_updated));
      });

      test('NodeStatus enum values', () {
        expect(NodeStatus.values, contains(NodeStatus.up));
        expect(NodeStatus.values, contains(NodeStatus.down));
        expect(NodeStatus.values, contains(NodeStatus.unknown));
      });
    });

    // ServiceRegistry Tests
    group('ServiceRegistry Model Tests', () {
      test('Registry creation', () {
        final registry = ServiceRegistry(
          registryId: 'svc-1',
          serviceName: 'API Service',
          serviceVersion: '1.0.0',
          instanceIds: ['inst-1', 'inst-2'],
          registeredAt: DateTime.now(),
          registeredBy: 'admin',
        );

        expect(registry.serviceName, 'API Service');
        expect(registry.instanceCount, 2);
        expect(registry.hasInstances, true);
      });

      test('Registry without instances', () {
        final registry = ServiceRegistry(
          registryId: 'svc-1',
          serviceName: 'Empty Service',
          serviceVersion: '1.0.0',
          instanceIds: [],
          registeredAt: DateTime.now(),
          registeredBy: 'admin',
        );

        expect(registry.hasInstances, false);
        expect(registry.instanceCount, 0);
      });
    });

    // ServiceInstance Tests
    group('ServiceInstance Model Tests', () {
      test('Healthy instance', () {
        final instance = ServiceInstance(
          instanceId: 'inst-1',
          registryId: 'svc-1',
          host: 'localhost',
          port: 8080,
          protocol: 'http',
          startedAt: DateTime.now(),
          status: ServiceStatus.healthy,
        );

        expect(instance.isHealthy, true);
        expect(instance.endpoint, 'http://localhost:8080');
      });

      test('Offline instance', () {
        final instance = ServiceInstance(
          instanceId: 'inst-1',
          registryId: 'svc-1',
          host: 'localhost',
          port: 8080,
          protocol: 'http',
          startedAt: DateTime.now(),
          status: ServiceStatus.offline,
        );

        expect(instance.isOffline, true);
        expect(instance.isHealthy, false);
      });

      test('Instance uptime calculation', () {
        final instance = ServiceInstance(
          instanceId: 'inst-1',
          registryId: 'svc-1',
          host: 'localhost',
          port: 8080,
          protocol: 'http',
          startedAt: DateTime.now().subtract(Duration(hours: 5)),
        );

        expect(instance.uptimeSeconds, greaterThanOrEqualTo(18000));
      });

      test('Instance with tags', () {
        final instance = ServiceInstance(
          instanceId: 'inst-1',
          registryId: 'svc-1',
          host: 'localhost',
          port: 8080,
          protocol: 'http',
          startedAt: DateTime.now(),
          tags: {'region': 'us-east', 'zone': 'a'},
        );

        expect(instance.hasTags, true);
      });
    });

    // HealthCheck Tests
    group('HealthCheck Model Tests', () {
      test('HTTP health check', () {
        final check = HealthCheck(
          checkId: 'check-1',
          instanceId: 'inst-1',
          checkType: CheckType.http,
          checkName: 'API Health',
          intervalSeconds: 30,
          timeoutSeconds: 5,
          checkConfig: {'path': '/health'},
        );

        expect(check.isHttpCheck, true);
        expect(check.hasConfig, true);
      });

      test('TCP health check', () {
        final check = HealthCheck(
          checkId: 'check-1',
          instanceId: 'inst-1',
          checkType: CheckType.tcp,
          checkName: 'TCP Connectivity',
          intervalSeconds: 60,
          timeoutSeconds: 10,
          checkConfig: {},
        );

        expect(check.isTcpCheck, true);
      });
    });

    // HealthStatus Tests
    group('HealthStatus Model Tests', () {
      test('Passing health status', () {
        final status = HealthStatus(
          statusId: 'status-1',
          instanceId: 'inst-1',
          state: HealthState.pass,
          checkedAt: DateTime.now(),
          responseTimeMs: 100,
        );

        expect(status.isHealthy, true);
        expect(status.isFailing, false);
      });

      test('Failing health status', () {
        final status = HealthStatus(
          statusId: 'status-1',
          instanceId: 'inst-1',
          state: HealthState.fail,
          checkedAt: DateTime.now(),
          message: 'Connection refused',
        );

        expect(status.isFailing, true);
      });

      test('Stale health status', () {
        final status = HealthStatus(
          statusId: 'status-1',
          instanceId: 'inst-1',
          state: HealthState.pass,
          checkedAt: DateTime.now().subtract(Duration(minutes: 6)),
        );

        expect(status.isStale, true);
      });
    });

    // ServiceNode Tests
    group('ServiceNode Model Tests', () {
      test('Up node', () {
        final node = ServiceNode(
          nodeId: 'node-1',
          nodeName: 'server-1',
          ipAddress: '192.168.1.1',
          port: 9000,
          status: NodeStatus.up,
          joinedAt: DateTime.now(),
          services: ['svc-1', 'svc-2'],
        );

        expect(node.isUp, true);
        expect(node.serviceCount, 2);
      });

      test('Down node', () {
        final node = ServiceNode(
          nodeId: 'node-1',
          nodeName: 'server-1',
          ipAddress: '192.168.1.1',
          port: 9000,
          status: NodeStatus.down,
          joinedAt: DateTime.now(),
        );

        expect(node.isDown, true);
        expect(node.address, '192.168.1.1:9000');
      });
    });

    // ServiceDependency Tests
    group('ServiceDependency Model Tests', () {
      test('Required dependency', () {
        final dep = ServiceDependency(
          dependencyId: 'dep-1',
          serviceId: 'svc-1',
          dependsOnServiceId: 'svc-2',
          dependencyType: 'http_call',
          isRequired: true,
          createdAt: DateTime.now(),
        );

        expect(dep.isRequired, true);
        expect(dep.isOptional, false);
      });

      test('Optional dependency', () {
        final dep = ServiceDependency(
          dependencyId: 'dep-1',
          serviceId: 'svc-1',
          dependsOnServiceId: 'svc-2',
          dependencyType: 'message_queue',
          isRequired: false,
          createdAt: DateTime.now(),
        );

        expect(dep.isOptional, true);
      });
    });

    // HealthMetrics Tests
    group('HealthMetrics Model Tests', () {
      test('Healthy metrics', () {
        final metrics = HealthMetrics(
          metricsId: 'metric-1',
          instanceId: 'inst-1',
          cpuUsage: 50.0,
          memoryUsage: 60.0,
          diskUsage: 70.0,
          requestCount: 1000,
          errorRate: 0.5,
          averageResponseTime: 200.0,
          measuredAt: DateTime.now(),
        );

        expect(metrics.isCpuHealthy, true);
        expect(metrics.isMemoryHealthy, true);
        expect(metrics.isDiskHealthy, true);
        expect(metrics.isErrorRateHealthy, true);
        expect(metrics.isResponsiveHealthy, true);
        expect(metrics.isOverallHealthy, true);
      });

      test('Unhealthy metrics', () {
        final metrics = HealthMetrics(
          metricsId: 'metric-1',
          instanceId: 'inst-1',
          cpuUsage: 95.0,
          memoryUsage: 90.0,
          diskUsage: 95.0,
          requestCount: 1000,
          errorRate: 10.0,
          averageResponseTime: 5000.0,
          measuredAt: DateTime.now(),
        );

        expect(metrics.isCpuHealthy, false);
        expect(metrics.isMemoryHealthy, false);
        expect(metrics.isDiskHealthy, false);
        expect(metrics.isErrorRateHealthy, false);
        expect(metrics.isResponsiveHealthy, false);
        expect(metrics.isOverallHealthy, false);
      });
    });

    // ServiceAlert Tests
    group('ServiceAlert Model Tests', () {
      test('Active alert', () {
        final alert = ServiceAlert(
          alertId: 'alert-1',
          instanceId: 'inst-1',
          severity: AlertSeverity.critical,
          alertType: 'high_cpu',
          message: 'CPU usage > 90%',
          createdAt: DateTime.now(),
          isActive: true,
        );

        expect(alert.isActive, true);
        expect(alert.isResolved, false);
      });

      test('Resolved alert', () {
        final now = DateTime.now();
        final alert = ServiceAlert(
          alertId: 'alert-1',
          instanceId: 'inst-1',
          severity: AlertSeverity.warning,
          alertType: 'memory_warning',
          message: 'Memory usage high',
          createdAt: now,
          resolvedAt: now.add(Duration(minutes: 10)),
          isActive: false,
        );

        expect(alert.isResolved, true);
        expect(alert.durationInSeconds, 600);
      });
    });

    // DiscoveryEvent Tests
    group('DiscoveryEvent Model Tests', () {
      test('Registration event', () {
        final event = DiscoveryEvent(
          eventId: 'event-1',
          eventType: EventType.registered,
          serviceId: 'svc-1',
          instanceId: 'inst-1',
          timestamp: DateTime.now(),
          description: 'Instance registered',
        );

        expect(event.isRegistration, true);
        expect(event.isDeregistration, false);
      });

      test('Deregistration event', () {
        final event = DiscoveryEvent(
          eventId: 'event-1',
          eventType: EventType.deregistered,
          serviceId: 'svc-1',
          instanceId: 'inst-1',
          timestamp: DateTime.now(),
          description: 'Instance deregistered',
        );

        expect(event.isDeregistration, true);
      });

      test('Health change event', () {
        final event = DiscoveryEvent(
          eventId: 'event-1',
          eventType: EventType.health_changed,
          serviceId: 'svc-1',
          timestamp: DateTime.now(),
          description: 'Health status changed',
        );

        expect(event.isHealthChange, true);
      });
    });

    // HealthReport Tests
    group('HealthReport Model Tests', () {
      test('Healthy report', () {
        final report = HealthReport(
          reportId: 'report-1',
          instanceId: 'inst-1',
          overallState: HealthState.pass,
          generatedAt: DateTime.now(),
          checkResults: ['check-1', 'check-2', 'check-3'],
          healthScore: 98.5,
        );

        expect(report.isHealthy, true);
        expect(report.checkCount, 3);
      });

      test('Unhealthy report', () {
        final report = HealthReport(
          reportId: 'report-1',
          instanceId: 'inst-1',
          overallState: HealthState.fail,
          generatedAt: DateTime.now(),
          checkResults: ['check-1'],
          healthScore: 45.0,
        );

        expect(report.isHealthy, false);
      });
    });

    // LoadBalancer Tests
    group('LoadBalancer Model Tests', () {
      test('Load balancer with instances', () {
        final lb = LoadBalancer(
          balancerId: 'lb-1',
          name: 'API LB',
          instanceIds: ['inst-1', 'inst-2', 'inst-3'],
          algorithm: 'round_robin',
          createdAt: DateTime.now(),
        );

        expect(lb.hasInstances, true);
        expect(lb.instanceCount, 3);
      });

      test('Load balancer without instances', () {
        final lb = LoadBalancer(
          balancerId: 'lb-1',
          name: 'Empty LB',
          instanceIds: [],
          createdAt: DateTime.now(),
        );

        expect(lb.hasInstances, false);
      });
    });

    // ServiceMesh Tests
    group('ServiceMesh Model Tests', () {
      test('Service mesh with services', () {
        final mesh = ServiceMesh(
          meshId: 'mesh-1',
          meshName: 'Production Mesh',
          serviceIds: ['svc-1', 'svc-2', 'svc-3'],
          createdAt: DateTime.now(),
        );

        expect(mesh.hasServices, true);
        expect(mesh.serviceCount, 3);
      });
    });

    // NodeMetrics Tests
    group('NodeMetrics Model Tests', () {
      test('Node metrics healthy', () {
        final metrics = NodeMetrics(
          metricsId: 'metric-1',
          nodeId: 'node-1',
          cpuUsage: 40.0,
          memoryUsage: 55.0,
          networkIn: 100.0,
          networkOut: 150.0,
          processCount: 25,
          measuredAt: DateTime.now(),
        );

        expect(metrics.isCpuHealthy, true);
        expect(metrics.isMemoryHealthy, true);
      });

      test('Node metrics unhealthy', () {
        final metrics = NodeMetrics(
          metricsId: 'metric-1',
          nodeId: 'node-1',
          cpuUsage: 95.0,
          memoryUsage: 90.0,
          networkIn: 500.0,
          networkOut: 600.0,
          processCount: 200,
          measuredAt: DateTime.now(),
        );

        expect(metrics.isCpuHealthy, false);
        expect(metrics.isMemoryHealthy, false);
      });
    });

    // Repository Tests
    group('Repository CRUD Operations', () {
      test('Register and retrieve service', () async {
        final registry = ServiceRegistry(
          registryId: 'svc-1',
          serviceName: 'API',
          serviceVersion: '1.0',
          instanceIds: [],
          registeredAt: DateTime.now(),
          registeredBy: 'admin',
        );

        await repository.registerService(registry);
        final retrieved = await repository.getRegistry('svc-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.serviceName, 'API');
      });

      test('Get services by name', () async {
        final reg1 = ServiceRegistry(
          registryId: 'svc-1',
          serviceName: 'API',
          serviceVersion: '1.0',
          instanceIds: [],
          registeredAt: DateTime.now(),
          registeredBy: 'admin',
        );

        final reg2 = ServiceRegistry(
          registryId: 'svc-2',
          serviceName: 'API',
          serviceVersion: '2.0',
          instanceIds: [],
          registeredAt: DateTime.now(),
          registeredBy: 'admin',
        );

        await repository.registerService(reg1);
        await repository.registerService(reg2);

        final services = await repository.getServicesByName('API');
        expect(services.length, 2);
      });

      test('Register and retrieve instance', () async {
        final instance = ServiceInstance(
          instanceId: 'inst-1',
          registryId: 'svc-1',
          host: 'localhost',
          port: 8080,
          protocol: 'http',
          startedAt: DateTime.now(),
        );

        await repository.registerInstance(instance);
        final retrieved = await repository.getInstance('inst-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.port, 8080);
      });

      test('Get instances by status', () async {
        final healthy = ServiceInstance(
          instanceId: 'inst-1',
          registryId: 'svc-1',
          host: 'localhost',
          port: 8080,
          protocol: 'http',
          startedAt: DateTime.now(),
          status: ServiceStatus.healthy,
        );

        final unhealthy = ServiceInstance(
          instanceId: 'inst-2',
          registryId: 'svc-1',
          host: 'localhost',
          port: 8081,
          protocol: 'http',
          startedAt: DateTime.now(),
          status: ServiceStatus.unhealthy,
        );

        await repository.registerInstance(healthy);
        await repository.registerInstance(unhealthy);

        final healthyInstances = await repository.getInstancesByStatus(ServiceStatus.healthy);
        expect(healthyInstances.length, 1);
      });

      test('Create and retrieve health check', () async {
        final check = HealthCheck(
          checkId: 'check-1',
          instanceId: 'inst-1',
          checkType: CheckType.http,
          checkName: 'Health',
          intervalSeconds: 30,
          timeoutSeconds: 5,
          checkConfig: {},
        );

        await repository.createHealthCheck(check);
        final retrieved = await repository.getHealthCheck('check-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.checkName, 'Health');
      });

      test('Record and retrieve health status', () async {
        final status = HealthStatus(
          statusId: 'status-1',
          instanceId: 'inst-1',
          state: HealthState.pass,
          checkedAt: DateTime.now(),
        );

        await repository.recordHealthStatus(status);
        final retrieved = await repository.getLatestStatus('inst-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.state, HealthState.pass);
      });

      test('Register and retrieve node', () async {
        final node = ServiceNode(
          nodeId: 'node-1',
          nodeName: 'server-1',
          ipAddress: '192.168.1.1',
          port: 9000,
          joinedAt: DateTime.now(),
        );

        await repository.registerNode(node);
        final retrieved = await repository.getNode('node-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.nodeName, 'server-1');
      });

      test('Create and retrieve alert', () async {
        final alert = ServiceAlert(
          alertId: 'alert-1',
          instanceId: 'inst-1',
          severity: AlertSeverity.critical,
          alertType: 'cpu_high',
          message: 'High CPU',
          createdAt: DateTime.now(),
        );

        await repository.createAlert(alert);
        final retrieved = await repository.getAlert('alert-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.severity, AlertSeverity.critical);
      });

      test('Get active alerts', () async {
        final alert1 = ServiceAlert(
          alertId: 'alert-1',
          instanceId: 'inst-1',
          severity: AlertSeverity.warning,
          alertType: 'memory',
          message: 'High memory',
          createdAt: DateTime.now(),
          isActive: true,
        );

        final alert2 = ServiceAlert(
          alertId: 'alert-2',
          instanceId: 'inst-1',
          severity: AlertSeverity.info,
          alertType: 'restart',
          message: 'Service restarted',
          createdAt: DateTime.now(),
          isActive: false,
        );

        await repository.createAlert(alert1);
        await repository.createAlert(alert2);

        final active = await repository.getActiveAlerts();
        expect(active.length, 1);
      });

      test('Record and retrieve metrics', () async {
        final metrics = HealthMetrics(
          metricsId: 'metric-1',
          instanceId: 'inst-1',
          cpuUsage: 50.0,
          memoryUsage: 60.0,
          diskUsage: 70.0,
          requestCount: 1000,
          errorRate: 0.5,
          averageResponseTime: 200.0,
          measuredAt: DateTime.now(),
        );

        await repository.recordMetrics(metrics);
        final retrieved = await repository.getLatestMetrics('inst-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.cpuUsage, 50.0);
      });
    });

    // Engine Tests
    group('Health Check Engine Tests', () {
      test('Perform health check', () async {
        final check = HealthCheck(
          checkId: 'check-1',
          instanceId: 'inst-1',
          checkType: CheckType.http,
          checkName: 'Health',
          intervalSeconds: 30,
          timeoutSeconds: 5,
          checkConfig: {},
        );

        await repository.createHealthCheck(check);

        final status = await manager.healthEngine.performHealthCheck('check-1');
        expect(status.state, HealthState.pass);
      });

      test('Mark instance healthy', () async {
        final instance = ServiceInstance(
          instanceId: 'inst-1',
          registryId: 'svc-1',
          host: 'localhost',
          port: 8080,
          protocol: 'http',
          startedAt: DateTime.now(),
          status: ServiceStatus.unhealthy,
        );

        await repository.registerInstance(instance);
        await manager.healthEngine.markInstanceHealthy('inst-1');

        final updated = await repository.getInstance('inst-1');
        expect(updated!.status, ServiceStatus.healthy);
      });

      test('Mark instance unhealthy', () async {
        final instance = ServiceInstance(
          instanceId: 'inst-1',
          registryId: 'svc-1',
          host: 'localhost',
          port: 8080,
          protocol: 'http',
          startedAt: DateTime.now(),
          status: ServiceStatus.healthy,
        );

        await repository.registerInstance(instance);
        await manager.healthEngine.markInstanceUnhealthy('inst-1');

        final updated = await repository.getInstance('inst-1');
        expect(updated!.status, ServiceStatus.unhealthy);
      });
    });

    // Discovery Engine Tests
    group('Service Discovery Engine Tests', () {
      test('Discover healthy services', () async {
        final registry = ServiceRegistry(
          registryId: 'svc-1',
          serviceName: 'API',
          serviceVersion: '1.0',
          instanceIds: ['inst-1'],
          registeredAt: DateTime.now(),
          registeredBy: 'admin',
        );

        final instance = ServiceInstance(
          instanceId: 'inst-1',
          registryId: 'svc-1',
          host: 'localhost',
          port: 8080,
          protocol: 'http',
          startedAt: DateTime.now(),
          status: ServiceStatus.healthy,
        );

        await repository.registerService(registry);
        await repository.registerInstance(instance);

        final discovered = await manager.discoveryEngine.discoverService('API');
        expect(discovered.length, 1);
        expect(discovered.first.isHealthy, true);
      });

      test('Record discovery event', () async {
        await manager.discoveryEngine.recordDiscoveryEvent(
          'svc-1',
          EventType.registered,
          'New instance registered',
        );

        final events = await repository.getServiceEvents('svc-1');
        expect(events.length, 1);
        expect(events.first.isRegistration, true);
      });
    });

    // Alert Engine Tests
    group('Alert Engine Tests', () {
      test('Create alert', () async {
        await manager.alertEngine.createAlert(
          'inst-1',
          AlertSeverity.critical,
          'cpu_high',
          'CPU > 90%',
        );

        final alerts = await repository.getInstanceAlerts('inst-1');
        expect(alerts.length, 1);
      });

      test('Resolve alert', () async {
        final alert = ServiceAlert(
          alertId: 'alert-1',
          instanceId: 'inst-1',
          severity: AlertSeverity.warning,
          alertType: 'memory',
          message: 'High memory',
          createdAt: DateTime.now(),
          isActive: true,
        );

        await repository.createAlert(alert);
        await manager.alertEngine.resolveAlert('alert-1');

        final updated = await repository.getAlert('alert-1');
        expect(updated!.isResolved, true);
        expect(updated.isActive, false);
      });
    });

    // Facade Integration Tests
    group('Facade Integration Tests', () {
      test('Complete service registration workflow', () async {
        await facade.registerService('API Service', '1.0.0', 'admin');
        await facade.registerInstance(
          'svc-${DateTime.now().millisecondsSinceEpoch}',
          'localhost',
          8080,
          'http',
        );

        final services = await repository.getAllServices();
        expect(services.isNotEmpty, true);
      });

      test('Create health check', () async {
        await facade.createHealthCheck(
          'inst-1',
          CheckType.http,
          'API Health',
        );

        final checks = await repository.getInstanceChecks('inst-1');
        expect(checks.isNotEmpty, true);
      });

      test('Record and retrieve metrics', () async {
        await facade.recordMetrics('inst-1', 50.0, 60.0, 70.0, 1000, 0.5, 200.0);

        final metrics = await facade.getMetrics('inst-1');
        expect(metrics, isNotNull);
        expect(metrics!.cpuUsage, 50.0);
      });

      test('Create and manage alerts', () async {
        await facade.createAlert('inst-1', AlertSeverity.critical, 'Critical CPU');

        final alerts = await facade.getActiveAlerts();
        expect(alerts.isNotEmpty, true);

        if (alerts.isNotEmpty) {
          await facade.resolveAlert(alerts.first.alertId);
        }
      });

      test('Register nodes', () async {
        await facade.registerNode('server-1', '192.168.1.1', 9000);
        await facade.registerNode('server-2', '192.168.1.2', 9000);

        final nodes = await facade.getAllNodes();
        expect(nodes.length, 2);
      });

      test('Create load balancer', () async {
        await facade.createLoadBalancer('API LB', ['inst-1', 'inst-2']);

        final balancers = await facade.getAllLoadBalancers();
        expect(balancers.isNotEmpty, true);
      });

      test('Create service mesh', () async {
        await facade.createServiceMesh('Production', ['svc-1', 'svc-2']);

        final meshes = await facade.getAllMeshes();
        expect(meshes.isNotEmpty, true);
      });
    });

    // Edge Cases
    group('Edge Case Tests', () {
      test('Service with no instances', () {
        final registry = ServiceRegistry(
          registryId: 'svc-1',
          serviceName: 'Empty Service',
          serviceVersion: '1.0',
          instanceIds: [],
          registeredAt: DateTime.now(),
          registeredBy: 'admin',
        );

        expect(registry.instanceCount, 0);
        expect(registry.hasInstances, false);
      });

      test('Alert with minimal duration', () {
        final now = DateTime.now();
        final alert = ServiceAlert(
          alertId: 'alert-1',
          instanceId: 'inst-1',
          severity: AlertSeverity.info,
          alertType: 'test',
          message: 'Test',
          createdAt: now,
          resolvedAt: now,
        );

        expect(alert.durationInSeconds, 0);
      });

      test('Node with many services', () {
        final services = List.generate(100, (i) => 'svc-$i');
        final node = ServiceNode(
          nodeId: 'node-1',
          nodeName: 'heavy-node',
          ipAddress: '192.168.1.1',
          port: 9000,
          joinedAt: DateTime.now(),
          services: services,
        );

        expect(node.serviceCount, 100);
      });

      test('Metrics at boundary values', () {
        final metrics = HealthMetrics(
          metricsId: 'metric-1',
          instanceId: 'inst-1',
          cpuUsage: 80.0,
          memoryUsage: 85.0,
          diskUsage: 90.0,
          requestCount: 0,
          errorRate: 5.0,
          averageResponseTime: 1000.0,
          measuredAt: DateTime.now(),
        );

        expect(metrics.isCpuHealthy, false);
        expect(metrics.isMemoryHealthy, false);
        expect(metrics.isDiskHealthy, false);
      });

      test('Stale status detection', () {
        final status = HealthStatus(
          statusId: 'status-1',
          instanceId: 'inst-1',
          state: HealthState.pass,
          checkedAt: DateTime.now().subtract(Duration(minutes: 6)),
        );

        expect(status.isStale, true);
      });
    });
  });
}
