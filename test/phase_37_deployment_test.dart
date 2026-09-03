import 'package:test/test.dart';
import 'package:project_040/models/deployment_models.dart';
import 'package:project_040/services/deployment_service.dart';

void main() {
  group('Phase 37: Deployment & Release Management', () {
    late DeploymentManager manager;

    setUp(() {
      manager = DeploymentManager();
    });

    // Semantic Version Tests
    group('SemanticVersion', () {
      test('should create version correctly', () {
        final version = SemanticVersion(major: 1, minor: 2, patch: 3);
        expect(version.toString(), equals('1.2.3'));
      });

      test('should include prerelease in version string', () {
        final version =
            SemanticVersion(major: 1, minor: 0, patch: 0, prerelease: 'alpha');
        expect(version.toString(), equals('1.0.0-alpha'));
      });

      test('should include metadata in version string', () {
        final version = SemanticVersion(
          major: 1,
          minor: 0,
          patch: 0,
          metadata: 'build.123',
        );
        expect(version.toString(), equals('1.0.0+build.123'));
      });

      test('should compare versions correctly', () {
        final v1 = SemanticVersion(major: 1, minor: 0, patch: 0);
        final v2 = SemanticVersion(major: 1, minor: 1, patch: 0);
        expect(v1.compareTo(v2), lessThan(0));
      });

      test('should increment minor version', () {
        final version = SemanticVersion(major: 1, minor: 2, patch: 3);
        final next = version.nextMinor();
        expect(next.toString(), equals('1.3.0'));
      });

      test('should increment patch version', () {
        final version = SemanticVersion(major: 1, minor: 2, patch: 3);
        final next = version.nextPatch();
        expect(next.toString(), equals('1.2.4'));
      });

      test('should increment major version', () {
        final version = SemanticVersion(major: 1, minor: 2, patch: 3);
        final next = version.nextMajor();
        expect(next.toString(), equals('2.0.0'));
      });
    });

    // Release Enum Tests
    group('ReleaseChannel Enum', () {
      test('should have stable channel', () {
        expect(ReleaseChannel.stable.value, equals('stable'));
      });

      test('should have beta channel', () {
        expect(ReleaseChannel.beta.value, equals('beta'));
      });

      test('should have all release channels', () {
        expect(ReleaseChannel.values.length, equals(4));
      });
    });

    group('DeploymentStrategy Enum', () {
      test('should have blue-green strategy', () {
        expect(DeploymentStrategy.blueGreen.value, equals('blue-green'));
      });

      test('should have canary strategy', () {
        expect(DeploymentStrategy.canary.value, equals('canary'));
      });

      test('should have all deployment strategies', () {
        expect(DeploymentStrategy.values.length, equals(4));
      });
    });

    group('DeploymentStatus Enum', () {
      test('should have pending status', () {
        expect(DeploymentStatus.pending.value, equals('pending'));
      });

      test('should have all deployment statuses', () {
        expect(DeploymentStatus.values.length, equals(5));
      });
    });

    // Release Tests
    group('Release', () {
      test('should create release', () {
        final release = Release(
          releaseId: 'rel_1',
          version: '1.0.0',
          channel: ReleaseChannel.stable,
          title: 'Version 1.0.0',
          description: 'Initial release',
          createdAt: DateTime.now(),
          releasedAt: DateTime.now(),
        );
        expect(release.version, equals('1.0.0'));
        expect(release.channel, equals(ReleaseChannel.stable));
      });

      test('should track deprecation', () {
        final now = DateTime.now();
        final release = Release(
          releaseId: 'rel_2',
          version: '0.9.0',
          channel: ReleaseChannel.beta,
          title: 'Version 0.9.0',
          description: 'Beta release',
          deprecatedAt: now.subtract(Duration(days: 30)),
          createdAt: DateTime.now(),
          releasedAt: DateTime.now(),
        );
        expect(release.isDeprecated, isTrue);
      });

      test('should track sunset date', () {
        final futureDate = DateTime.now().add(Duration(days: 90));
        final release = Release(
          releaseId: 'rel_3',
          version: '0.8.0',
          channel: ReleaseChannel.alpha,
          title: 'Version 0.8.0',
          description: 'Alpha release',
          sunsetDate: futureDate,
          createdAt: DateTime.now(),
          releasedAt: DateTime.now(),
        );
        expect(release.isSunset, isFalse);
      });
    });

    // ChangeLog Tests
    group('ChangeLogEntry', () {
      test('should create changelog entry', () {
        final entry = ChangeLogEntry(
          entryId: 'entry_1',
          version: '1.0.0',
          changeType: 'added',
          description: 'New feature added',
          releaseDate: DateTime.now(),
          createdAt: DateTime.now(),
        );
        expect(entry.version, equals('1.0.0'));
        expect(entry.changeType, equals('added'));
      });

      test('should include affected components', () {
        final entry = ChangeLogEntry(
          entryId: 'entry_2',
          version: '1.1.0',
          changeType: 'fixed',
          description: 'Bug fix',
          releaseDate: DateTime.now(),
          affectedComponents: ['auth', 'database'],
          createdAt: DateTime.now(),
        );
        expect(entry.affectedComponents, contains('auth'));
      });
    });

    // Deployment Config Tests
    group('DeploymentConfig', () {
      test('should create deployment config', () {
        final config = DeploymentConfig(
          configId: 'config_1',
          environmentName: 'production',
          minInstances: 3,
          maxInstances: 10,
          createdAt: DateTime.now(),
        );
        expect(config.environmentName, equals('production'));
        expect(config.minInstances, equals(3));
      });

      test('should have environment variables', () {
        final config = DeploymentConfig(
          configId: 'config_2',
          environmentName: 'staging',
          environmentVariables: {'DEBUG': 'true'},
          createdAt: DateTime.now(),
        );
        expect(config.environmentVariables['DEBUG'], equals('true'));
      });
    });

    // Deployment Tests
    group('Deployment', () {
      test('should execute deployment', () async {
        final release = Release(
          releaseId: 'rel_deploy',
          version: '1.5.0',
          channel: ReleaseChannel.stable,
          title: 'Version 1.5.0',
          description: 'Release 1.5.0',
          createdAt: DateTime.now(),
          releasedAt: DateTime.now(),
        );

        final config = DeploymentConfig(
          configId: 'config_deploy',
          environmentName: 'production',
          maxInstances: 10,
          createdAt: DateTime.now(),
        );

        final deployment = await manager.executeDeploy(
          release,
          'production',
          config,
          DeploymentStrategy.rolling,
        );

        expect(deployment.version, equals('1.5.0'));
        expect(deployment.environmentName, equals('production'));
        expect(deployment.strategy, equals(DeploymentStrategy.rolling));
      });

      test('should calculate success rate', () async {
        final release = Release(
          releaseId: 'rel_success',
          version: '2.0.0',
          channel: ReleaseChannel.stable,
          title: 'Version 2.0.0',
          description: 'Release 2.0.0',
          createdAt: DateTime.now(),
          releasedAt: DateTime.now(),
        );

        final config = DeploymentConfig(
          configId: 'config_success',
          environmentName: 'staging',
          maxInstances: 20,
          createdAt: DateTime.now(),
        );

        final deployment = await manager.executeDeploy(
          release,
          'staging',
          config,
          DeploymentStrategy.canary,
        );

        expect(deployment.successRate, greaterThan(0));
        expect(deployment.successRate, lessThanOrEqualTo(100));
      });

      test('should track deployment duration', () async {
        final release = Release(
          releaseId: 'rel_duration',
          version: '1.2.0',
          channel: ReleaseChannel.beta,
          title: 'Version 1.2.0',
          description: 'Beta 1.2.0',
          createdAt: DateTime.now(),
          releasedAt: DateTime.now(),
        );

        final config = DeploymentConfig(
          configId: 'config_duration',
          environmentName: 'development',
          createdAt: DateTime.now(),
        );

        final deployment = await manager.executeDeploy(
          release,
          'development',
          config,
          DeploymentStrategy.immediate,
        );

        expect(deployment.deploymentDuration.inMilliseconds, greaterThan(0));
      });
    });

    // Rollback Tests
    group('Rollback', () {
      test('should perform rollback', () async {
        final release = Release(
          releaseId: 'rel_rollback',
          version: '1.3.0',
          channel: ReleaseChannel.stable,
          title: 'Version 1.3.0',
          description: 'Release 1.3.0',
          createdAt: DateTime.now(),
          releasedAt: DateTime.now(),
        );

        final config = DeploymentConfig(
          configId: 'config_rollback',
          environmentName: 'production',
          createdAt: DateTime.now(),
        );

        final deployment = await manager.executeDeploy(
          release,
          'production',
          config,
          DeploymentStrategy.rolling,
        );

        final rollback = await manager.rollback(
          deployment.deploymentId,
          '1.2.0',
          'Critical bug detected',
        );

        expect(rollback.deploymentId, equals(deployment.deploymentId));
        expect(rollback.toVersion, equals('1.2.0'));
      });

      test('should track rollback reason', () async {
        final release = Release(
          releaseId: 'rel_reason',
          version: '1.4.0',
          channel: ReleaseChannel.beta,
          title: 'Version 1.4.0',
          description: 'Beta 1.4.0',
          createdAt: DateTime.now(),
          releasedAt: DateTime.now(),
        );

        final config = DeploymentConfig(
          configId: 'config_reason',
          environmentName: 'staging',
          createdAt: DateTime.now(),
        );

        final deployment = await manager.executeDeploy(
          release,
          'staging',
          config,
          DeploymentStrategy.canary,
        );

        final rollback = await manager.rollback(
          deployment.deploymentId,
          '1.3.0',
          'Performance regression',
        );

        expect(rollback.reason, equals('Performance regression'));
      });
    });

    // Metrics Tests
    group('DeploymentMetrics', () {
      test('should collect metrics', () async {
        final release = Release(
          releaseId: 'rel_metrics',
          version: '2.1.0',
          channel: ReleaseChannel.stable,
          title: 'Version 2.1.0',
          description: 'Release 2.1.0',
          createdAt: DateTime.now(),
          releasedAt: DateTime.now(),
        );

        final config = DeploymentConfig(
          configId: 'config_metrics',
          environmentName: 'production',
          createdAt: DateTime.now(),
        );

        final deployment = await manager.executeDeploy(
          release,
          'production',
          config,
          DeploymentStrategy.rolling,
        );

        final metrics = await manager.collectMetrics(deployment.deploymentId);

        expect(metrics.deploymentId, equals(deployment.deploymentId));
        expect(metrics.totalRequests, greaterThan(0));
      });

      test('should track error rate', () async {
        final metrics = DeploymentMetrics(
          metricsId: 'metrics_1',
          deploymentId: 'deploy_1',
          deploymentDuration: Duration(seconds: 120),
          totalRequests: 1000,
          successfulRequests: 950,
          failedRequests: 50,
          averageLatency: 85.5,
          errorRate: 5.0,
          cpuUsage: 45.2,
          memoryUsage: 62.8,
          activeConnections: 250,
          measuredAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(metrics.errorRate, equals(5.0));
        expect(metrics.isHealthy, isTrue);
      });

      test('should check high performance', () {
        final metrics = DeploymentMetrics(
          metricsId: 'metrics_2',
          deploymentId: 'deploy_2',
          deploymentDuration: Duration(seconds: 60),
          totalRequests: 500,
          successfulRequests: 500,
          failedRequests: 0,
          averageLatency: 50.0,
          errorRate: 0.0,
          cpuUsage: 30.0,
          memoryUsage: 45.0,
          activeConnections: 100,
          measuredAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(metrics.isHighPerformance, isTrue);
      });
    });

    // ReleaseNotice Tests
    group('ReleaseNotice', () {
      test('should create release notice', () {
        final notice = ReleaseNotice(
          noticeId: 'notice_1',
          releaseId: 'rel_notice',
          version: '2.0.0',
          title: 'Version 2.0.0 Released',
          content: '# Version 2.0.0\n\nMajor release',
          channel: ReleaseChannel.stable,
          publishedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(notice.version, equals('2.0.0'));
        expect(notice.channel, equals(ReleaseChannel.stable));
      });

      test('should track highlighted features', () {
        final notice = ReleaseNotice(
          noticeId: 'notice_2',
          releaseId: 'rel_features',
          version: '1.5.0',
          title: 'Version 1.5.0',
          content: 'Release notes',
          channel: ReleaseChannel.stable,
          publishedAt: DateTime.now(),
          highlightedFeatures: ['New API', 'Performance improvements'],
          createdAt: DateTime.now(),
        );

        expect(notice.highlightedFeatures.length, equals(2));
        expect(notice.highlightedFeatures, contains('New API'));
      });
    });

    // DeploymentHistory Tests
    group('DeploymentHistory', () {
      test('should track deployment history', () {
        final deployment = Deployment(
          deploymentId: 'deploy_hist',
          releaseId: 'rel_hist',
          version: '1.1.0',
          environmentName: 'production',
          strategy: DeploymentStrategy.rolling,
          status: DeploymentStatus.completed,
          startedAt: DateTime.now(),
          completedAt: DateTime.now(),
          totalInstances: 5,
          successfulInstances: 5,
          failedInstances: 0,
          deploymentDuration: Duration(seconds: 60),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final history = DeploymentHistory(
          historyId: 'hist_1',
          environmentName: 'production',
          deployments: [deployment],
          createdAt: DateTime.now(),
        );

        expect(history.lastDeployment, equals(deployment));
        expect(history.currentVersion, equals('1.1.0'));
      });
    });

    // Report Tests
    group('DeploymentReport', () {
      test('should generate deployment report', () async {
        final release = Release(
          releaseId: 'rel_report',
          version: '2.2.0',
          channel: ReleaseChannel.stable,
          title: 'Version 2.2.0',
          description: 'Release 2.2.0',
          createdAt: DateTime.now(),
          releasedAt: DateTime.now(),
        );

        final config = DeploymentConfig(
          configId: 'config_report',
          environmentName: 'production',
          createdAt: DateTime.now(),
        );

        final deployment = await manager.executeDeploy(
          release,
          'production',
          config,
          DeploymentStrategy.rolling,
        );

        final report = await manager.generateReport(deployment.deploymentId);

        expect(report.deploymentId, equals(deployment.deploymentId));
        expect(report.version, equals('2.2.0'));
      });

      test('should export report to markdown', () async {
        final deployment = Deployment(
          deploymentId: 'deploy_md',
          releaseId: 'rel_md',
          version: '1.6.0',
          environmentName: 'staging',
          strategy: DeploymentStrategy.canary,
          status: DeploymentStatus.completed,
          startedAt: DateTime.now(),
          completedAt: DateTime.now(),
          totalInstances: 8,
          successfulInstances: 8,
          failedInstances: 0,
          deploymentDuration: Duration(seconds: 120),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final metrics = DeploymentMetrics(
          metricsId: 'metrics_md',
          deploymentId: deployment.deploymentId,
          deploymentDuration: Duration(seconds: 120),
          totalRequests: 1000,
          successfulRequests: 950,
          failedRequests: 50,
          averageLatency: 85.5,
          errorRate: 5.0,
          cpuUsage: 45.2,
          memoryUsage: 62.8,
          activeConnections: 250,
          measuredAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        final report = DeploymentReport(
          reportId: 'report_md',
          deploymentId: deployment.deploymentId,
          version: deployment.version,
          environmentName: deployment.environmentName,
          generatedAt: DateTime.now(),
          deployment: deployment,
          metrics: metrics,
          summary: 'Deployment successful',
        );

        final markdown = report.toMarkdown();
        expect(markdown, contains('Deployment Report'));
        expect(markdown, contains('1.6.0'));
      });
    });

    // Health Check Tests
    group('Health Check', () {
      test('should perform health check', () async {
        final isHealthy = await manager.healthCheck('production');
        expect(isHealthy, isTrue);
      });
    });

    // Integration Tests
    group('Integration Tests', () {
      test('should complete full deployment workflow', () async {
        // Create release
        final release = Release(
          releaseId: 'rel_workflow',
          version: '3.0.0',
          channel: ReleaseChannel.stable,
          title: 'Version 3.0.0',
          description: 'Major release',
          createdAt: DateTime.now(),
          releasedAt: DateTime.now(),
        );

        await manager.createRelease(release);
        final retrieved = await manager.getRelease('rel_workflow');
        expect(retrieved, isNotNull);

        // Deploy
        final config = DeploymentConfig(
          configId: 'config_workflow',
          environmentName: 'production',
          createdAt: DateTime.now(),
        );

        final deployment = await manager.executeDeploy(
          release,
          'production',
          config,
          DeploymentStrategy.rolling,
        );

        expect(deployment.isSuccessful, isTrue);

        // Check progress
        final progress = await manager.getDeploymentProgress(deployment.deploymentId);
        expect(progress, isNotNull);

        // Generate report
        final report = await manager.generateReport(deployment.deploymentId);
        expect(report.deployment.version, equals('3.0.0'));
      });

      test('should handle rollback workflow', () async {
        final release = Release(
          releaseId: 'rel_rollback_wf',
          version: '2.5.0',
          channel: ReleaseChannel.stable,
          title: 'Version 2.5.0',
          description: 'Release 2.5.0',
          createdAt: DateTime.now(),
          releasedAt: DateTime.now(),
        );

        final config = DeploymentConfig(
          configId: 'config_rollback_wf',
          environmentName: 'production',
          createdAt: DateTime.now(),
        );

        final deployment = await manager.executeDeploy(
          release,
          'production',
          config,
          DeploymentStrategy.rolling,
        );

        final rollback = await manager.rollback(
          deployment.deploymentId,
          '2.4.0',
          'Issues detected',
        );

        expect(rollback.isCompleted, isTrue);
        expect(rollback.toVersion, equals('2.4.0'));
      });
    });
  });
}
