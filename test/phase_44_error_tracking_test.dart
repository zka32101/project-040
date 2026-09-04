/// Phase 44: Error Tracking & Reporting テスト
/// エラーレコーディング、クラスタリング、アラート、分析

import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/error_tracking_models.dart';
import 'package:project_040/services/error_tracking_service.dart';

void main() {
  group('Phase 44: Error Tracking & Reporting Tests', () {
    // ==================== Enum Tests ====================
    group('Enum Tests', () {
      test('ErrorLevel enum values', () {
        expect(ErrorLevel.debug.value, 'debug');
        expect(ErrorLevel.info.value, 'info');
        expect(ErrorLevel.warning.value, 'warning');
        expect(ErrorLevel.error.value, 'error');
        expect(ErrorLevel.critical.value, 'critical');
      });

      test('ErrorType enum values', () {
        expect(ErrorType.nullPointer.value, 'null_pointer');
        expect(ErrorType.typeError.value, 'type_error');
        expect(ErrorType.networkError.value, 'network_error');
        expect(ErrorType.authenticationError.value, 'authentication_error');
      });

      test('ErrorStatus enum values', () {
        expect(ErrorStatus.new_.value, 'new');
        expect(ErrorStatus.acknowledged.value, 'acknowledged');
        expect(ErrorStatus.investigating.value, 'investigating');
        expect(ErrorStatus.resolved.value, 'resolved');
      });

      test('ErrorPriority enum values', () {
        expect(ErrorPriority.low.value, 'low');
        expect(ErrorPriority.medium.value, 'medium');
        expect(ErrorPriority.high.value, 'high');
        expect(ErrorPriority.critical.value, 'critical');
      });
    });

    // ==================== StackTraceFrame Tests ====================
    group('StackTraceFrame Model Tests', () {
      test('Create stack trace frame', () {
        final frame = StackTraceFrame(
          fileName: 'main.dart',
          methodName: 'main',
          lineNumber: 42,
          columnNumber: 10,
          rawFrame: '#0 main (main.dart:42:10)',
        );

        expect(frame.fileName, 'main.dart');
        expect(frame.methodName, 'main');
        expect(frame.lineNumber, 42);
        expect(frame.displayString, 'main.dart:42 in main');
      });

      test('Native frame', () {
        final frame = StackTraceFrame(
          isNative: true,
          rawFrame: '[native code]',
        );

        expect(frame.isNative, true);
      });

      test('Frame with null values', () {
        final frame = StackTraceFrame(
          rawFrame: 'unknown frame',
        );

        expect(frame.displayString, 'unknown frame');
      });
    });

    // ==================== ErrorContext Tests ====================
    group('ErrorContext Model Tests', () {
      test('Create error context', () {
        final context = ErrorContext(
          userId: 'user_123',
          sessionId: 'session_456',
          deviceId: 'device_789',
          appVersion: '1.0.0',
          osVersion: 'Android 12',
          timestamp: DateTime.now(),
        );

        expect(context.userId, 'user_123');
        expect(context.sessionId, 'session_456');
      });

      test('Convert context to map', () {
        final context = ErrorContext(
          userId: 'user_123',
          timestamp: DateTime.now(),
        );

        final map = context.toMap();
        expect(map.containsKey('userId'), true);
        expect(map.containsKey('timestamp'), true);
      });

      test('Error context with metadata', () {
        final metadata = {'key': 'value', 'number': 42};
        final context = ErrorContext(
          metadata: metadata,
          timestamp: DateTime.now(),
        );

        expect(context.metadata, metadata);
      });
    });

    // ==================== ErrorEvent Tests ====================
    group('ErrorEvent Model Tests', () {
      test('Create error event', () {
        final context = ErrorContext(timestamp: DateTime.now());
        final event = ErrorEvent(
          errorId: 'error_1',
          message: 'Null pointer exception',
          type: ErrorType.nullPointer,
          level: ErrorLevel.critical,
          context: context,
          occurredAt: DateTime.now(),
        );

        expect(event.errorId, 'error_1');
        expect(event.message, 'Null pointer exception');
        expect(event.type, ErrorType.nullPointer);
        expect(event.level, ErrorLevel.critical);
      });

      test('Recurring error detection', () {
        final context = ErrorContext(timestamp: DateTime.now());
        final event = ErrorEvent(
          errorId: 'error_2',
          message: 'Test error',
          type: ErrorType.typeError,
          level: ErrorLevel.error,
          context: context,
          occurredAt: DateTime.now(),
          occurrenceCount: 5,
        );

        expect(event.isRecurring, true);
      });

      test('Severity score calculation', () {
        final context = ErrorContext(timestamp: DateTime.now());
        final criticalEvent = ErrorEvent(
          errorId: 'error_3',
          message: 'Critical error',
          type: ErrorType.nullPointer,
          level: ErrorLevel.critical,
          context: context,
          occurredAt: DateTime.now(),
        );

        expect(criticalEvent.severityScore, 100);
      });

      test('Error event with stack trace', () {
        final context = ErrorContext(timestamp: DateTime.now());
        final frames = [
          StackTraceFrame(
            fileName: 'main.dart',
            methodName: 'main',
            lineNumber: 1,
            rawFrame: '#0 main',
          ),
        ];

        final event = ErrorEvent(
          errorId: 'error_4',
          message: 'Error with stack',
          type: ErrorType.customError,
          level: ErrorLevel.error,
          frames: frames,
          context: context,
          occurredAt: DateTime.now(),
        );

        expect(event.frames, isNotEmpty);
        expect(event.frames!.first.fileName, 'main.dart');
      });
    });

    // ==================== ErrorReport Tests ====================
    group('ErrorReport Model Tests', () {
      test('Create error report', () {
        final context = ErrorContext(timestamp: DateTime.now());
        final event = ErrorEvent(
          errorId: 'error_5',
          message: 'Test error',
          type: ErrorType.typeError,
          level: ErrorLevel.error,
          context: context,
          occurredAt: DateTime.now(),
        );

        final report = ErrorReport(
          reportId: 'report_1',
          errorEvent: event,
          priority: ErrorPriority.high,
          createdAt: DateTime.now(),
        );

        expect(report.reportId, 'report_1');
        expect(report.status, ErrorStatus.new_);
        expect(report.isPending, true);
      });

      test('Resolved report', () {
        final context = ErrorContext(timestamp: DateTime.now());
        final event = ErrorEvent(
          errorId: 'error_6',
          message: 'Test error',
          type: ErrorType.typeError,
          level: ErrorLevel.error,
          context: context,
          occurredAt: DateTime.now(),
        );

        final report = ErrorReport(
          reportId: 'report_2',
          errorEvent: event,
          status: ErrorStatus.resolved,
          priority: ErrorPriority.medium,
          createdAt: DateTime.now(),
          resolvedAt: DateTime.now(),
        );

        expect(report.isResolved, true);
        expect(report.isPending, false);
      });

      test('Report age time', () async {
        final context = ErrorContext(timestamp: DateTime.now());
        final event = ErrorEvent(
          errorId: 'error_7',
          message: 'Test error',
          type: ErrorType.typeError,
          level: ErrorLevel.error,
          context: context,
          occurredAt: DateTime.now(),
        );

        final report = ErrorReport(
          reportId: 'report_3',
          errorEvent: event,
          priority: ErrorPriority.low,
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
        );

        expect(report.ageTime.inHours, greaterThanOrEqualTo(2));
      });
    });

    // ==================== ErrorCluster Tests ====================
    group('ErrorCluster Model Tests', () {
      test('Create error cluster', () {
        final context = ErrorContext(timestamp: DateTime.now());
        final event = ErrorEvent(
          errorId: 'error_8',
          message: 'Cluster test',
          type: ErrorType.nullPointer,
          level: ErrorLevel.critical,
          context: context,
          occurredAt: DateTime.now(),
        );

        final cluster = ErrorCluster(
          clusterId: 'cluster_1',
          events: [event],
          type: ErrorType.nullPointer,
          level: ErrorLevel.critical,
          commonMessage: 'Cluster test',
          totalCount: 1,
          firstOccurrence: DateTime.now(),
          lastOccurrence: DateTime.now(),
        );

        expect(cluster.clusterId, 'cluster_1');
        expect(cluster.totalCount, 1);
      });

      test('Cluster with multiple events', () {
        final context = ErrorContext(timestamp: DateTime.now());
        final events = List.generate(
          5,
          (i) => ErrorEvent(
            errorId: 'error_$i',
            message: 'Cluster test',
            type: ErrorType.nullPointer,
            level: ErrorLevel.critical,
            context: context,
            occurredAt: DateTime.now(),
          ),
        );

        final cluster = ErrorCluster(
          clusterId: 'cluster_2',
          events: events,
          type: ErrorType.nullPointer,
          level: ErrorLevel.critical,
          commonMessage: 'Cluster test',
          totalCount: 5,
          firstOccurrence: DateTime.now().subtract(Duration(hours: 1)),
          lastOccurrence: DateTime.now(),
        );

        expect(cluster.totalCount, 5);
        expect(cluster.frequency, greaterThan(0));
      });

      test('Cluster top frame', () {
        final context = ErrorContext(timestamp: DateTime.now());
        final frames = [
          StackTraceFrame(
            fileName: 'main.dart',
            methodName: 'main',
            lineNumber: 1,
            rawFrame: '#0 main',
          ),
        ];

        final event = ErrorEvent(
          errorId: 'error_9',
          message: 'Test',
          type: ErrorType.customError,
          level: ErrorLevel.error,
          frames: frames,
          context: context,
          occurredAt: DateTime.now(),
        );

        final cluster = ErrorCluster(
          clusterId: 'cluster_3',
          events: [event],
          type: ErrorType.customError,
          level: ErrorLevel.error,
          commonMessage: 'Test',
          totalCount: 1,
          firstOccurrence: DateTime.now(),
          lastOccurrence: DateTime.now(),
        );

        expect(cluster.topFrame, isNotNull);
      });
    });

    // ==================== ErrorMetrics Tests ====================
    group('ErrorMetrics Model Tests', () {
      test('Create error metrics', () {
        final metrics = ErrorMetrics(
          metricsId: 'metrics_1',
          totalErrors: 100,
          errorTypeCounts: 5,
          criticalErrors: 10,
          unresolvedErrors: 5,
          errorRate: 0.1,
          createdAt: DateTime.now(),
        );

        expect(metrics.metricsId, 'metrics_1');
        expect(metrics.totalErrors, 100);
      });

      test('Calculate health score', () {
        final metrics = ErrorMetrics(
          metricsId: 'metrics_2',
          totalErrors: 50,
          errorTypeCounts: 3,
          criticalErrors: 5,
          unresolvedErrors: 3,
          errorRate: 0.1,
          createdAt: DateTime.now(),
        );

        expect(metrics.systemHealthScore, isNonNegative);
        expect(metrics.systemHealthScore, lessThanOrEqualTo(100));
      });

      test('Trending up detection', () {
        final metrics = ErrorMetrics(
          metricsId: 'metrics_3',
          totalErrors: 100,
          errorTypeCounts: 5,
          criticalErrors: 20,
          unresolvedErrors: 15,
          errorRate: 0.1, // 10% error rate
          createdAt: DateTime.now(),
        );

        expect(metrics.isTrendingUp, true);
      });
    });

    // ==================== ErrorAlert Tests ====================
    group('ErrorAlert Model Tests', () {
      test('Create alert', () {
        final alert = ErrorAlert(
          alertId: 'alert_1',
          errorClusterId: 'cluster_1',
          title: 'High error rate detected',
          message: 'Error rate exceeded threshold',
          level: ErrorLevel.critical,
          threshold: 10,
          timeWindow: Duration(hours: 1),
          createdAt: DateTime.now(),
        );

        expect(alert.alertId, 'alert_1');
        expect(alert.isActive, true);
        expect(alert.isTriggered, false);
      });

      test('Triggered alert', () {
        final alert = ErrorAlert(
          alertId: 'alert_2',
          errorClusterId: 'cluster_2',
          title: 'Critical alert',
          message: 'System error detected',
          level: ErrorLevel.critical,
          threshold: 5,
          timeWindow: Duration(minutes: 5),
          createdAt: DateTime.now(),
          triggeredAt: DateTime.now(),
        );

        expect(alert.isTriggered, true);
      });

      test('Acknowledged alert', () {
        final alert = ErrorAlert(
          alertId: 'alert_3',
          errorClusterId: 'cluster_3',
          title: 'Warning alert',
          message: 'Warning detected',
          level: ErrorLevel.warning,
          threshold: 20,
          timeWindow: Duration(hours: 1),
          createdAt: DateTime.now(),
          acknowledgedAt: DateTime.now(),
          acknowledgedBy: 'user_123',
        );

        expect(alert.isAcknowledged, true);
      });
    });

    // ==================== ErrorAnalytics Tests ====================
    group('ErrorAnalytics Model Tests', () {
      test('Create error analytics', () {
        final analytics = ErrorAnalytics(
          analyticsId: 'analytics_1',
          topClusters: [],
          errorTypeDistribution: {},
          errorLevelDistribution: {},
          activeAlerts: [],
          metrics: ErrorMetrics(
            metricsId: 'metrics_1',
            totalErrors: 0,
            errorTypeCounts: 0,
            criticalErrors: 0,
            unresolvedErrors: 0,
            errorRate: 0.0,
            createdAt: DateTime.now(),
          ),
          analyzedAt: DateTime.now(),
        );

        expect(analytics.analyticsId, 'analytics_1');
      });

      test('Most common error type', () {
        final distribution = {
          ErrorType.nullPointer: 50,
          ErrorType.typeError: 30,
          ErrorType.networkError: 20,
        };

        final analytics = ErrorAnalytics(
          analyticsId: 'analytics_2',
          topClusters: [],
          errorTypeDistribution: distribution,
          errorLevelDistribution: {},
          activeAlerts: [],
          metrics: ErrorMetrics(
            metricsId: 'metrics_2',
            totalErrors: 100,
            errorTypeCounts: 3,
            criticalErrors: 10,
            unresolvedErrors: 5,
            errorRate: 0.1,
            createdAt: DateTime.now(),
          ),
          analyzedAt: DateTime.now(),
        );

        expect(analytics.mostCommonErrorType, ErrorType.nullPointer);
      });
    });

    // ==================== Repository Tests ====================
    group('ErrorTrackingRepository Tests', () {
      late MemoryErrorTrackingRepository repository;

      setUp(() {
        repository = MemoryErrorTrackingRepository();
      });

      test('Save and retrieve error event', () async {
        final context = ErrorContext(timestamp: DateTime.now());
        final event = ErrorEvent(
          errorId: 'error_1',
          message: 'Test error',
          type: ErrorType.typeError,
          level: ErrorLevel.error,
          context: context,
          occurredAt: DateTime.now(),
        );

        await repository.saveErrorEvent(event);
        final retrieved = await repository.getErrorEvent('error_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.message, 'Test error');
      });

      test('Get all error events', () async {
        final context = ErrorContext(timestamp: DateTime.now());
        final event1 = ErrorEvent(
          errorId: 'error_1',
          message: 'Error 1',
          type: ErrorType.typeError,
          level: ErrorLevel.error,
          context: context,
          occurredAt: DateTime.now(),
        );

        final event2 = ErrorEvent(
          errorId: 'error_2',
          message: 'Error 2',
          type: ErrorType.nullPointer,
          level: ErrorLevel.critical,
          context: context,
          occurredAt: DateTime.now(),
        );

        await repository.saveErrorEvent(event1);
        await repository.saveErrorEvent(event2);

        final all = await repository.getAllErrorEvents();
        expect(all.length, 2);
      });

      test('Save and retrieve error report', () async {
        final context = ErrorContext(timestamp: DateTime.now());
        final event = ErrorEvent(
          errorId: 'error_3',
          message: 'Test',
          type: ErrorType.typeError,
          level: ErrorLevel.error,
          context: context,
          occurredAt: DateTime.now(),
        );

        final report = ErrorReport(
          reportId: 'report_1',
          errorEvent: event,
          priority: ErrorPriority.high,
          createdAt: DateTime.now(),
        );

        await repository.saveErrorReport(report);
        final retrieved = await repository.getErrorReport('report_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.priority, ErrorPriority.high);
      });

      test('Get unresolved reports', () async {
        final context = ErrorContext(timestamp: DateTime.now());
        final event = ErrorEvent(
          errorId: 'error_4',
          message: 'Test',
          type: ErrorType.typeError,
          level: ErrorLevel.error,
          context: context,
          occurredAt: DateTime.now(),
        );

        final unresolvedReport = ErrorReport(
          reportId: 'report_2',
          errorEvent: event,
          status: ErrorStatus.new_,
          priority: ErrorPriority.medium,
          createdAt: DateTime.now(),
        );

        final resolvedReport = ErrorReport(
          reportId: 'report_3',
          errorEvent: event,
          status: ErrorStatus.resolved,
          priority: ErrorPriority.low,
          createdAt: DateTime.now(),
          resolvedAt: DateTime.now(),
        );

        await repository.saveErrorReport(unresolvedReport);
        await repository.saveErrorReport(resolvedReport);

        final unresolved = await repository.getUnresolvedReports();
        expect(unresolved.length, 1);
      });

      test('Save and retrieve alert', () async {
        final alert = ErrorAlert(
          alertId: 'alert_1',
          errorClusterId: 'cluster_1',
          title: 'Test alert',
          message: 'Test message',
          level: ErrorLevel.warning,
          threshold: 10,
          timeWindow: Duration(hours: 1),
          createdAt: DateTime.now(),
        );

        await repository.saveAlert(alert);
        final alerts = await repository.getActiveAlerts();

        expect(alerts.length, 1);
        expect(alerts.first.title, 'Test alert');
      });
    });

    // ==================== Analysis Engine Tests ====================
    group('ErrorAnalysisEngine Tests', () {
      late MemoryErrorTrackingRepository repository;
      late MemoryErrorAnalysisEngine engine;

      setUp(() {
        repository = MemoryErrorTrackingRepository();
        engine = MemoryErrorAnalysisEngine(repository);
      });

      test('Cluster error', () async {
        final context = ErrorContext(timestamp: DateTime.now());
        final event = ErrorEvent(
          errorId: 'error_1',
          message: 'Test error',
          type: ErrorType.typeError,
          level: ErrorLevel.error,
          context: context,
          occurredAt: DateTime.now(),
        );

        final cluster = await engine.clusterError(event);

        expect(cluster.type, ErrorType.typeError);
        expect(cluster.events.length, 1);
      });

      test('Analyze errors', () async {
        final context = ErrorContext(timestamp: DateTime.now());
        final events = [
          ErrorEvent(
            errorId: 'error_1',
            message: 'Error 1',
            type: ErrorType.typeError,
            level: ErrorLevel.error,
            context: context,
            occurredAt: DateTime.now(),
          ),
          ErrorEvent(
            errorId: 'error_2',
            message: 'Error 2',
            type: ErrorType.nullPointer,
            level: ErrorLevel.critical,
            context: context,
            occurredAt: DateTime.now(),
          ),
        ];

        final analytics = await engine.analyzeErrors(events);

        expect(analytics.topClusters.isNotEmpty, true);
        expect(analytics.metrics.totalErrors, 2);
      });

      test('Calculate metrics', () async {
        final context = ErrorContext(timestamp: DateTime.now());
        final events = [
          ErrorEvent(
            errorId: 'error_1',
            message: 'Critical',
            type: ErrorType.nullPointer,
            level: ErrorLevel.critical,
            context: context,
            occurredAt: DateTime.now(),
          ),
        ];

        final metrics = await engine.calculateMetrics(events);

        expect(metrics.totalErrors, 1);
        expect(metrics.criticalErrors, 1);
      });
    });

    // ==================== Manager Tests ====================
    group('ErrorTrackingManager Tests', () {
      late MemoryErrorTrackingRepository repository;
      late MemoryErrorAnalysisEngine analysisEngine;
      late MemoryErrorTrackingManager manager;

      setUp(() {
        repository = MemoryErrorTrackingRepository();
        analysisEngine = MemoryErrorAnalysisEngine(repository);
        manager = MemoryErrorTrackingManager(repository, analysisEngine);
      });

      test('Record error', () async {
        final context = ErrorContext(timestamp: DateTime.now());
        final event = ErrorEvent(
          errorId: 'error_1',
          message: 'Test error',
          type: ErrorType.typeError,
          level: ErrorLevel.error,
          context: context,
          occurredAt: DateTime.now(),
        );

        await manager.recordError(event);
        final retrieved = await repository.getErrorEvent('error_1');

        expect(retrieved, isNotNull);
      });

      test('Create error report', () async {
        final context = ErrorContext(timestamp: DateTime.now());
        final event = ErrorEvent(
          errorId: 'error_2',
          message: 'Test',
          type: ErrorType.typeError,
          level: ErrorLevel.error,
          context: context,
          occurredAt: DateTime.now(),
        );

        final report = await manager.createErrorReport(
          event,
          ErrorPriority.high,
        );

        expect(report.reportId, isNotEmpty);
        expect(report.priority, ErrorPriority.high);
      });

      test('Update report status', () async {
        final context = ErrorContext(timestamp: DateTime.now());
        final event = ErrorEvent(
          errorId: 'error_3',
          message: 'Test',
          type: ErrorType.typeError,
          level: ErrorLevel.error,
          context: context,
          occurredAt: DateTime.now(),
        );

        final report = await manager.createErrorReport(
          event,
          ErrorPriority.medium,
        );

        await manager.updateReportStatus(report.reportId, ErrorStatus.resolved);
        final updated = await repository.getErrorReport(report.reportId);

        expect(updated!.status, ErrorStatus.resolved);
      });
    });

    // ==================== Facade Tests ====================
    group('ErrorTrackingManagerFacade Tests', () {
      late ErrorTrackingManagerFacade facade;

      setUp(() {
        facade = ErrorTrackingManagerFacade();
      });

      test('Record error via facade', () async {
        final context = ErrorContext(timestamp: DateTime.now());
        final event = ErrorEvent(
          errorId: 'error_1',
          message: 'Facade test',
          type: ErrorType.typeError,
          level: ErrorLevel.error,
          context: context,
          occurredAt: DateTime.now(),
        );

        await facade.recordError(event);
        final retrieved = await facade.getErrorEvent('error_1');

        expect(retrieved, isNotNull);
      });

      test('Create and update report via facade', () async {
        final context = ErrorContext(timestamp: DateTime.now());
        final event = ErrorEvent(
          errorId: 'error_2',
          message: 'Facade test',
          type: ErrorType.typeError,
          level: ErrorLevel.error,
          context: context,
          occurredAt: DateTime.now(),
        );

        final report = await facade.createErrorReport(
          event,
          ErrorPriority.high,
        );

        await facade.updateReportStatus(report.reportId, ErrorStatus.resolved);
        final unresolved = await facade.getUnresolvedReports();

        expect(unresolved.isEmpty, true);
      });

      test('Generate report via facade', () async {
        final context = ErrorContext(timestamp: DateTime.now());
        final event = ErrorEvent(
          errorId: 'error_3',
          message: 'Report test',
          type: ErrorType.nullPointer,
          level: ErrorLevel.critical,
          context: context,
          occurredAt: DateTime.now(),
        );

        await facade.recordError(event);
        final report = await facade.generateReport();

        expect(report.reportId, isNotEmpty);
        expect(report.toMarkdown(), contains('Error Tracking Report'));
      });

      test('Get metrics via facade', () async {
        final context = ErrorContext(timestamp: DateTime.now());
        final event = ErrorEvent(
          errorId: 'error_4',
          message: 'Metrics test',
          type: ErrorType.typeError,
          level: ErrorLevel.error,
          context: context,
          occurredAt: DateTime.now(),
        );

        await facade.recordError(event);
        final metrics = await facade.getMetrics();

        expect(metrics, isNotNull);
        expect(metrics!.totalErrors, greaterThan(0));
      });
    });

    // ==================== Integration Tests ====================
    group('Integration Tests', () {
      test('Complete error tracking workflow', () async {
        final facade = ErrorTrackingManagerFacade();

        // Record multiple errors
        final context1 = ErrorContext(timestamp: DateTime.now());
        final event1 = ErrorEvent(
          errorId: 'error_1',
          message: 'Database connection failed',
          type: ErrorType.networkError,
          level: ErrorLevel.critical,
          context: context1,
          occurredAt: DateTime.now(),
        );

        final context2 = ErrorContext(timestamp: DateTime.now());
        final event2 = ErrorEvent(
          errorId: 'error_2',
          message: 'Null pointer in parser',
          type: ErrorType.nullPointer,
          level: ErrorLevel.error,
          context: context2,
          occurredAt: DateTime.now(),
        );

        await facade.recordError(event1);
        await facade.recordError(event2);

        // Create reports
        final report1 = await facade.createErrorReport(
          event1,
          ErrorPriority.critical,
        );

        final report2 = await facade.createErrorReport(
          event2,
          ErrorPriority.high,
        );

        // Update statuses
        await facade.updateReportStatus(report1.reportId, ErrorStatus.investigating);

        // Get unresolved
        final unresolved = await facade.getUnresolvedReports();
        expect(unresolved.length, 2);

        // Generate report
        final trackingReport = await facade.generateReport();
        expect(trackingReport.analytics.metrics.totalErrors, greaterThan(0));
        expect(trackingReport.toMarkdown(), contains('Error Tracking Report'));
      });

      test('Error clustering and analysis', () async {
        final facade = ErrorTrackingManagerFacade();

        // Create multiple similar errors
        for (int i = 0; i < 5; i++) {
          final context = ErrorContext(timestamp: DateTime.now());
          final event = ErrorEvent(
            errorId: 'error_$i',
            message: 'Database connection failed',
            type: ErrorType.networkError,
            level: ErrorLevel.critical,
            context: context,
            occurredAt: DateTime.now(),
          );

          await facade.recordError(event);
        }

        // Analyze
        final allEvents = await facade.getAllErrorEvents();
        final analytics = await facade.analyzeErrors(allEvents);

        expect(analytics.metrics.totalErrors, 5);
        expect(analytics.topClusters.isNotEmpty, true);
      });

      test('Alert triggering based on error threshold', () async {
        final facade = ErrorTrackingManagerFacade();

        // Create alert
        final alert = ErrorAlert(
          alertId: 'alert_1',
          errorClusterId: 'cluster_1',
          title: 'High error rate',
          message: 'Too many errors',
          level: ErrorLevel.critical,
          threshold: 3,
          timeWindow: Duration(hours: 1),
          createdAt: DateTime.now(),
        );

        await facade.createAlert('cluster_1', alert);

        // Record errors
        for (int i = 0; i < 3; i++) {
          final context = ErrorContext(timestamp: DateTime.now());
          final event = ErrorEvent(
            errorId: 'error_$i',
            message: 'Test error $i',
            type: ErrorType.typeError,
            level: ErrorLevel.error,
            context: context,
            occurredAt: DateTime.now(),
          );

          await facade.recordError(event);
        }

        // Check alerts
        final activeAlerts = await facade.getActiveAlerts();
        expect(activeAlerts.isNotEmpty, true);
      });
    });
  });
}
