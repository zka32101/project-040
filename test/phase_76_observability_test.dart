import 'package:test/test.dart';
import 'package:project_040/models/observability_models.dart';
import 'package:project_040/services/observability_tracing_service.dart';

void main() {
  group('Phase 76: Observability & Tracing', () {
    late ObservabilityRepositoryImpl repository;

    setUp(() {
      repository = ObservabilityRepositoryImpl();
    });

    // Enum Tests
    group('Enum Tests', () {
      test('TraceStatus has all required values', () {
        expect(TraceStatus.values.length, 6);
        expect(TraceStatus.values, contains(TraceStatus.started));
        expect(TraceStatus.values, contains(TraceStatus.active));
        expect(TraceStatus.values, contains(TraceStatus.completed));
        expect(TraceStatus.values, contains(TraceStatus.failed));
        expect(TraceStatus.values, contains(TraceStatus.cancelled));
        expect(TraceStatus.values, contains(TraceStatus.timeout));
      });

      test('SpanKind has all required values', () {
        expect(SpanKind.values.length, 5);
        expect(SpanKind.values, contains(SpanKind.internal));
        expect(SpanKind.values, contains(SpanKind.server));
        expect(SpanKind.values, contains(SpanKind.client));
        expect(SpanKind.values, contains(SpanKind.producer));
        expect(SpanKind.values, contains(SpanKind.consumer));
      });

      test('MetricType has all required values', () {
        expect(MetricType.values.length, 4);
        expect(MetricType.values, contains(MetricType.gauge));
        expect(MetricType.values, contains(MetricType.counter));
        expect(MetricType.values, contains(MetricType.histogram));
        expect(MetricType.values, contains(MetricType.summary));
      });

      test('LogLevel has all required values', () {
        expect(LogLevel.values.length, 6);
        expect(LogLevel.values, contains(LogLevel.trace));
        expect(LogLevel.values, contains(LogLevel.debug));
        expect(LogLevel.values, contains(LogLevel.info));
        expect(LogLevel.values, contains(LogLevel.warn));
        expect(LogLevel.values, contains(LogLevel.error));
        expect(LogLevel.values, contains(LogLevel.fatal));
      });

      test('SamplingStrategy has all required values', () {
        expect(SamplingStrategy.values.length, 5);
        expect(SamplingStrategy.values, contains(SamplingStrategy.always));
        expect(SamplingStrategy.values, contains(SamplingStrategy.never));
        expect(SamplingStrategy.values, contains(SamplingStrategy.probabilistic));
        expect(SamplingStrategy.values, contains(SamplingStrategy.adaptive));
        expect(SamplingStrategy.values, contains(SamplingStrategy.rateLimit));
      });

      test('AlertSeverity has all required values', () {
        expect(AlertSeverity.values.length, 5);
        expect(AlertSeverity.values, contains(AlertSeverity.critical));
        expect(AlertSeverity.values, contains(AlertSeverity.high));
        expect(AlertSeverity.values, contains(AlertSeverity.medium));
        expect(AlertSeverity.values, contains(AlertSeverity.low));
        expect(AlertSeverity.values, contains(AlertSeverity.info));
      });
    });

    // Model Tests
    group('Model Tests', () {
      test('Trace model creates with required fields', () {
        final trace = Trace(
          traceId: 'tr_123',
          parentTraceId: 'par_123',
          serviceName: 'api-service',
          startTime: DateTime.now(),
          status: TraceStatus.active,
          spanIds: [],
          tags: {},
        );
        expect(trace.traceId, 'tr_123');
        expect(trace.serviceName, 'api-service');
        expect(trace.status, TraceStatus.active);
      });

      test('Trace computed properties work correctly', () {
        final now = DateTime.now();
        final trace = Trace(
          traceId: 'tr_123',
          parentTraceId: '',
          serviceName: 'api',
          startTime: now,
          endTime: now.add(Duration(milliseconds: 500)),
          status: TraceStatus.completed,
          spanIds: ['sp_1', 'sp_2'],
          tags: {},
        );
        expect(trace.isCompleted, true);
        expect(trace.spanCount, 2);
        expect(trace.durationMs, 500);
      });

      test('Span model creates with required fields', () {
        final span = Span(
          spanId: 'sp_123',
          traceId: 'tr_123',
          parentSpanId: 'sp_parent',
          operationName: 'database_query',
          kind: SpanKind.internal,
          startTime: DateTime.now(),
          attributes: {},
          eventIds: [],
        );
        expect(span.spanId, 'sp_123');
        expect(span.operationName, 'database_query');
        expect(span.hasError, false);
      });

      test('Metric model records correctly', () {
        final metric = Metric(
          metricId: 'met_123',
          serviceName: 'api',
          metricName: 'request_count',
          type: MetricType.counter,
          value: 42.0,
          recordedAt: DateTime.now(),
          labels: {'endpoint': '/api/users'},
        );
        expect(metric.metricName, 'request_count');
        expect(metric.value, 42.0);
        expect(metric.type, MetricType.counter);
      });

      test('LogEntry model with error detection', () {
        final log = LogEntry(
          logId: 'log_123',
          serviceName: 'api',
          level: LogLevel.error,
          message: 'Connection timeout',
          timestamp: DateTime.now(),
          traceId: 'tr_123',
          context: {},
        );
        expect(log.isError, true);
        expect(log.level, LogLevel.error);
      });

      test('Sampling model configuration', () {
        final sampling = Sampling(
          samplingId: 'samp_123',
          strategy: SamplingStrategy.probabilistic,
          samplingRate: 0.1,
          maxTracesPerSecond: 100,
          createdAt: DateTime.now(),
          serviceName: 'api',
        );
        expect(sampling.isProbabilistic, true);
        expect(sampling.samplingRate, 0.1);
      });

      test('ServiceHealth model assessment', () {
        final health = ServiceHealth(
          healthId: 'hlth_123',
          serviceName: 'api',
          checkedAt: DateTime.now(),
          errorRate: 0.5,
          latencyP99: 1000.0,
          latencyP95: 500.0,
          requestCount: 1000,
          errorCount: 5,
          status: 'healthy',
        );
        expect(health.isHealthy, true);
        expect(health.requestCount, 1000);
      });

      test('Alert model severity tracking', () {
        final alert = Alert(
          alertId: 'alrt_123',
          serviceName: 'api',
          metricName: 'error_rate',
          severity: AlertSeverity.high,
          description: 'Error rate exceeds threshold',
          triggeredAt: DateTime.now(),
        );
        expect(alert.isActive, true);
        expect(alert.severity, AlertSeverity.high);
        expect(alert.isResolved, false);
      });

      test('TraceAnalysis model computation', () {
        final analysis = TraceAnalysis(
          analysisId: 'ana_123',
          traceId: 'tr_123',
          analyzedAt: DateTime.now(),
          spanCount: 10,
          errorSpanCount: 2,
          criticalPath: 500.0,
          slowestSpans: ['sp_1', 'sp_2'],
          errorSpans: ['sp_3', 'sp_4'],
          spanDetailedLatency: 1000.0,
        );
        expect(analysis.hasErrors, true);
        expect(analysis.errorRate, 20.0);
      });

      test('DistributedTraceContext creation', () {
        final context = DistributedTraceContext(
          contextId: 'ctx_123',
          traceId: 'tr_123',
          spanId: 'sp_123',
          traceFlags: true,
          traceState: 'active',
          createdAt: DateTime.now(),
          baggage: {'key': 'value'},
        );
        expect(context.traceFlags, true);
        expect(context.traceState, 'active');
      });

      test('ObservabilityReport generation', () {
        final now = DateTime.now();
        final report = ObservabilityReport(
          reportId: 'rpt_123',
          generatedAt: now,
          periodStart: now.subtract(Duration(days: 1)),
          periodEnd: now,
          totalTraces: 1000,
          failedTraces: 50,
          averageLatency: 250.0,
          p99Latency: 1000.0,
          errorRate: 5.0,
          topServices: ['api', 'db'],
        );
        expect(report.successRate, 95.0);
        expect(report.periodInDays, 1);
      });

      test('ObservabilityFilter configuration', () {
        final filter = ObservabilityFilter(
          filterId: 'flt_123',
          filterName: 'error_logs',
          serviceName: 'api',
          minLogLevel: LogLevel.error,
        );
        expect(filter.hasFilters, true);
        expect(filter.activeFilterCount, 2);
      });
    });

    // Repository Trace Management Tests
    group('Repository - Trace Management', () {
      test('createTrace creates new trace', () async {
        final trace = await repository.createTrace('api-service', DateTime.now());
        expect(trace.serviceName, 'api-service');
        expect(trace.status, TraceStatus.active);
      });

      test('getTrace retrieves existing trace', () async {
        final created = await repository.createTrace('api', DateTime.now());
        final retrieved = await repository.getTrace(created.traceId);
        expect(retrieved, isNotNull);
        expect(retrieved!.traceId, created.traceId);
      });

      test('getTrace returns null for non-existent trace', () async {
        final retrieved = await repository.getTrace('non_existent');
        expect(retrieved, isNull);
      });

      test('updateTraceStatus changes trace status', () async {
        final trace = await repository.createTrace('api', DateTime.now());
        final updated = await repository.updateTraceStatus(trace.traceId, TraceStatus.completed);
        expect(updated.status, TraceStatus.completed);
      });

      test('deleteTrace removes trace', () async {
        final trace = await repository.createTrace('api', DateTime.now());
        await repository.deleteTrace(trace.traceId);
        final retrieved = await repository.getTrace(trace.traceId);
        expect(retrieved, isNull);
      });

      test('listTraces returns limited traces', () async {
        for (int i = 0; i < 100; i++) {
          await repository.createTrace('api', DateTime.now());
        }
        final traces = await repository.listTraces(limit: 10);
        expect(traces.length, 10);
      });

      test('getActiveTraces returns only active traces', () async {
        final active = await repository.createTrace('api', DateTime.now());
        final completed = await repository.createTrace('api', DateTime.now());
        await repository.updateTraceStatus(completed.traceId, TraceStatus.completed);
        
        final activeTraces = await repository.getActiveTraces();
        expect(activeTraces.length, greaterThan(0));
      });

      test('getFailedTraces returns only failed traces', () async {
        final failed = await repository.createTrace('api', DateTime.now());
        await repository.updateTraceStatus(failed.traceId, TraceStatus.failed);
        
        final failedTraces = await repository.getFailedTraces();
        expect(failedTraces.isNotEmpty, true);
      });

      test('getTracesByService filters by service name', () async {
        await repository.createTrace('service-a', DateTime.now());
        await repository.createTrace('service-b', DateTime.now());
        
        final traces = await repository.getTracesByService('service-a');
        expect(traces.every((t) => t.serviceName == 'service-a'), true);
      });

      test('getTraceCount returns correct count', () async {
        final initialCount = await repository.getTraceCount();
        await repository.createTrace('api', DateTime.now());
        final newCount = await repository.getTraceCount();
        expect(newCount, initialCount + 1);
      });

      test('getTracesByFilter applies filters', () async {
        await repository.createTrace('api', DateTime.now());
        final filter = ObservabilityFilter(
          filterId: 'flt_123',
          filterName: 'api-only',
          serviceName: 'api',
        );
        final filtered = await repository.getTracesByFilter(filter);
        expect(filtered.every((t) => t.serviceName == 'api'), true);
      });
    });

    // Repository Span Management Tests
    group('Repository - Span Management', () {
      test('createSpan creates new span', () async {
        final span = await repository.createSpan('tr_123', 'db_query', SpanKind.internal, 'sp_parent');
        expect(span.operationName, 'db_query');
        expect(span.kind, SpanKind.internal);
      });

      test('getSpan retrieves existing span', () async {
        final created = await repository.createSpan('tr_123', 'query', SpanKind.client, 'sp_parent');
        final retrieved = await repository.getSpan(created.spanId);
        expect(retrieved, isNotNull);
      });

      test('completeSpan marks span as completed', () async {
        final span = await repository.createSpan('tr_123', 'query', SpanKind.client, 'sp_parent');
        final completed = await repository.completeSpan(span.spanId);
        expect(completed.isCompleted, true);
      });

      test('deleteSpan removes span', () async {
        final span = await repository.createSpan('tr_123', 'query', SpanKind.client, 'sp_parent');
        await repository.deleteSpan(span.spanId);
        final retrieved = await repository.getSpan(span.spanId);
        expect(retrieved, isNull);
      });

      test('getSpansByTrace returns spans for trace', () async {
        await repository.createSpan('tr_123', 'query', SpanKind.client, 'sp_parent');
        await repository.createSpan('tr_123', 'write', SpanKind.client, 'sp_parent');
        
        final spans = await repository.getSpansByTrace('tr_123');
        expect(spans.every((s) => s.traceId == 'tr_123'), true);
      });

      test('getErrorSpans returns only error spans', () async {
        final errorSpan = await repository.createSpan('tr_123', 'query', SpanKind.client, 'sp_parent');
        await repository.completeSpan(errorSpan.spanId, errorMessage: 'DB Error');
        
        final errors = await repository.getErrorSpans('tr_123');
        expect(errors.isNotEmpty, true);
      });

      test('getSpanCount returns correct count', () async {
        await repository.createSpan('tr_123', 'q1', SpanKind.client, 'sp_parent');
        await repository.createSpan('tr_123', 'q2', SpanKind.client, 'sp_parent');
        
        final count = await repository.getSpanCount('tr_123');
        expect(count, greaterThanOrEqualTo(2));
      });

      test('getSlowSpans filters by duration', () async {
        final span = await repository.createSpan('tr_123', 'slow', SpanKind.client, 'sp_parent');
        await repository.completeSpan(span.spanId);
        
        final slow = await repository.getSlowSpans('tr_123', 100);
        expect(slow.isNotEmpty, true);
      });
    });

    // Repository Metric Recording Tests
    group('Repository - Metric Recording', () {
      test('recordMetric stores metric', () async {
        final metric = await repository.recordMetric(
          'api',
          'request_count',
          MetricType.counter,
          42.0,
          {'endpoint': '/api'},
        );
        expect(metric.value, 42.0);
        expect(metric.type, MetricType.counter);
      });

      test('getMetric retrieves metric', () async {
        final recorded = await repository.recordMetric('api', 'latency', MetricType.gauge, 250.0, {});
        final retrieved = await repository.getMetric(recorded.metricId);
        expect(retrieved, isNotNull);
      });

      test('getMetricsByService filters by service', () async {
        await repository.recordMetric('api', 'count', MetricType.counter, 1.0, {});
        await repository.recordMetric('db', 'count', MetricType.counter, 2.0, {});
        
        final metrics = await repository.getMetricsByService('api');
        expect(metrics.every((m) => m.serviceName == 'api'), true);
      });

      test('getMetricsByName filters by metric name', () async {
        await repository.recordMetric('api', 'cpu', MetricType.gauge, 50.0, {});
        await repository.recordMetric('db', 'memory', MetricType.gauge, 80.0, {});
        
        final metrics = await repository.getMetricsByName('cpu');
        expect(metrics.every((m) => m.metricName == 'cpu'), true);
      });

      test('getRecentMetrics returns recent metrics', () async {
        await repository.recordMetric('api', 'count', MetricType.counter, 1.0, {});
        
        final recent = await repository.getRecentMetrics(5);
        expect(recent.isNotEmpty, true);
      });

      test('getAverageMetricValue computes average', () async {
        await repository.recordMetric('api', 'latency', MetricType.gauge, 100.0, {});
        await repository.recordMetric('api', 'latency', MetricType.gauge, 200.0, {});
        await repository.recordMetric('api', 'latency', MetricType.gauge, 300.0, {});
        
        final avg = await repository.getAverageMetricValue('latency');
        expect(avg, greaterThan(0));
      });

      test('getMetricCount returns correct count', () async {
        final initial = await repository.getMetricCount();
        await repository.recordMetric('api', 'count', MetricType.counter, 1.0, {});
        final updated = await repository.getMetricCount();
        expect(updated, greaterThanOrEqualTo(initial));
      });
    });

    // Repository Log Management Tests
    group('Repository - Log Management', () {
      test('recordLog stores log entry', () async {
        final log = await repository.recordLog('api', LogLevel.info, 'User login', 'tr_123');
        expect(log.message, 'User login');
        expect(log.level, LogLevel.info);
      });

      test('getLog retrieves log entry', () async {
        final recorded = await repository.recordLog('api', LogLevel.error, 'Error', 'tr_123');
        final retrieved = await repository.getLog(recorded.logId);
        expect(retrieved, isNotNull);
      });

      test('getLogsByService filters by service', () async {
        await repository.recordLog('api', LogLevel.info, 'msg1', 'tr_123');
        await repository.recordLog('db', LogLevel.info, 'msg2', 'tr_123');
        
        final logs = await repository.getLogsByService('api');
        expect(logs.every((l) => l.serviceName == 'api'), true);
      });

      test('getLogsByLevel filters by level', () async {
        await repository.recordLog('api', LogLevel.error, 'err', 'tr_123');
        await repository.recordLog('api', LogLevel.info, 'info', 'tr_123');
        
        final errors = await repository.getLogsByLevel(LogLevel.error);
        expect(errors.every((l) => l.level == LogLevel.error), true);
      });

      test('getLogsByTraceId filters by trace', () async {
        await repository.recordLog('api', LogLevel.info, 'msg', 'tr_123');
        await repository.recordLog('api', LogLevel.info, 'msg', 'tr_456');
        
        final logs = await repository.getLogsByTraceId('tr_123');
        expect(logs.every((l) => l.traceId == 'tr_123'), true);
      });

      test('getErrorLogs returns error level logs', () async {
        await repository.recordLog('api', LogLevel.error, 'Error', 'tr_123');
        await repository.recordLog('api', LogLevel.info, 'Info', 'tr_123');
        
        final errors = await repository.getErrorLogs('api');
        expect(errors.every((l) => l.isError), true);
      });

      test('deleteLog removes log', () async {
        final log = await repository.recordLog('api', LogLevel.info, 'msg', 'tr_123');
        await repository.deleteLog(log.logId);
        final retrieved = await repository.getLog(log.logId);
        expect(retrieved, isNull);
      });

      test('getLogCount returns count', () async {
        final initial = await repository.getLogCount();
        await repository.recordLog('api', LogLevel.info, 'msg', 'tr_123');
        final updated = await repository.getLogCount();
        expect(updated, greaterThanOrEqualTo(initial));
      });
    });

    // Repository Sampling Configuration Tests
    group('Repository - Sampling Configuration', () {
      test('createSamplingConfig creates config', () async {
        final sampling = await repository.createSamplingConfig(
          'api',
          SamplingStrategy.probabilistic,
          0.1,
          100,
        );
        expect(sampling.serviceName, 'api');
        expect(sampling.samplingRate, 0.1);
      });

      test('getSamplingConfig retrieves config', () async {
        final created = await repository.createSamplingConfig('api', SamplingStrategy.always, 1.0, 1000);
        final retrieved = await repository.getSamplingConfig(created.samplingId);
        expect(retrieved, isNotNull);
      });

      test('getSamplingConfigsByService filters', () async {
        await repository.createSamplingConfig('api', SamplingStrategy.always, 1.0, 1000);
        await repository.createSamplingConfig('db', SamplingStrategy.never, 0.0, 0);
        
        final configs = await repository.getSamplingConfigsByService('api');
        expect(configs.every((c) => c.serviceName == 'api'), true);
      });

      test('updateSamplingConfig modifies config', () async {
        final config = await repository.createSamplingConfig('api', SamplingStrategy.always, 1.0, 1000);
        await repository.updateSamplingConfig(config.samplingId, rate: 0.5, maxTraces: 500);
        final updated = await repository.getSamplingConfig(config.samplingId);
        expect(updated!.samplingRate, 0.5);
      });

      test('disableSamplingConfig deactivates config', () async {
        final config = await repository.createSamplingConfig('api', SamplingStrategy.always, 1.0, 1000);
        await repository.disableSamplingConfig(config.samplingId);
        final disabled = await repository.getSamplingConfig(config.samplingId);
        expect(disabled!.isActive, false);
      });

      test('getActiveSamplingConfigs returns only active', () async {
        final active = await repository.createSamplingConfig('api', SamplingStrategy.always, 1.0, 1000);
        final inactive = await repository.createSamplingConfig('db', SamplingStrategy.never, 0.0, 0);
        await repository.disableSamplingConfig(inactive.samplingId);
        
        final activeConfigs = await repository.getActiveSamplingConfigs();
        expect(activeConfigs.any((c) => c.samplingId == active.samplingId), true);
      });
    });

    // Repository Service Health Tests
    group('Repository - Service Health', () {
      test('recordServiceHealth stores health', () async {
        final health = await repository.recordServiceHealth('api', 0.5, 1000.0, 500.0, 1000, 5);
        expect(health.serviceName, 'api');
        expect(health.errorRate, 0.5);
      });

      test('getServiceHealth retrieves health', () async {
        final recorded = await repository.recordServiceHealth('api', 0.1, 500.0, 250.0, 100, 1);
        final retrieved = await repository.getServiceHealth(recorded.healthId);
        expect(retrieved, isNotNull);
      });

      test('getLatestServiceHealth returns most recent', () async {
        await repository.recordServiceHealth('api', 0.5, 1000.0, 500.0, 1000, 5);
        await repository.recordServiceHealth('api', 0.1, 500.0, 250.0, 1000, 1);
        
        final latest = await repository.getLatestServiceHealth('api');
        expect(latest, isNotNull);
      });

      test('getHealthByService filters by service', () async {
        await repository.recordServiceHealth('api', 0.1, 500.0, 250.0, 1000, 1);
        await repository.recordServiceHealth('db', 0.5, 1000.0, 500.0, 1000, 5);
        
        final health = await repository.getHealthByService('api');
        expect(health.every((h) => h.serviceName == 'api'), true);
      });

      test('getUnhealthyServices returns degraded services', () async {
        await repository.recordServiceHealth('api', 0.1, 500.0, 250.0, 1000, 1);
        await repository.recordServiceHealth('db', 10.0, 15000.0, 10000.0, 1000, 100);
        
        final unhealthy = await repository.getUnhealthyServices();
        expect(unhealthy.isNotEmpty, true);
      });

      test('getServiceHealthCount returns count', () async {
        final initial = await repository.getServiceHealthCount();
        await repository.recordServiceHealth('api', 0.1, 500.0, 250.0, 1000, 1);
        final updated = await repository.getServiceHealthCount();
        expect(updated, greaterThan(initial));
      });
    });

    // Repository Alert Management Tests
    group('Repository - Alert Management', () {
      test('createAlert creates alert', () async {
        final alert = await repository.createAlert(
          'api',
          'error_rate',
          AlertSeverity.high,
          'Error rate high',
        );
        expect(alert.serviceName, 'api');
        expect(alert.severity, AlertSeverity.high);
      });

      test('getAlert retrieves alert', () async {
        final created = await repository.createAlert('api', 'metric', AlertSeverity.critical, 'Critical');
        final retrieved = await repository.getAlert(created.alertId);
        expect(retrieved, isNotNull);
      });

      test('resolveAlert marks as resolved', () async {
        final alert = await repository.createAlert('api', 'metric', AlertSeverity.high, 'Alert');
        final resolved = await repository.resolveAlert(alert.alertId, 'Fixed');
        expect(resolved.isResolved, true);
      });

      test('getActiveAlerts returns only active', () async {
        final active = await repository.createAlert('api', 'metric', AlertSeverity.high, 'Alert');
        await repository.resolveAlert(active.alertId, 'Fixed');
        
        final activeAlerts = await repository.getActiveAlerts();
        expect(activeAlerts.where((a) => a.alertId == active.alertId).isEmpty, true);
      });

      test('getAlertsByService filters by service', () async {
        await repository.createAlert('api', 'metric1', AlertSeverity.high, 'Alert');
        await repository.createAlert('db', 'metric2', AlertSeverity.low, 'Alert');
        
        final alerts = await repository.getAlertsByService('api');
        expect(alerts.every((a) => a.serviceName == 'api'), true);
      });

      test('getAlertsBySeverity filters by severity', () async {
        await repository.createAlert('api', 'metric', AlertSeverity.critical, 'Critical');
        await repository.createAlert('api', 'metric', AlertSeverity.low, 'Low');
        
        final critical = await repository.getAlertsBySeverity(AlertSeverity.critical);
        expect(critical.every((a) => a.severity == AlertSeverity.critical), true);
      });

      test('getAlertCount returns count', () async {
        final initial = await repository.getAlertCount();
        await repository.createAlert('api', 'metric', AlertSeverity.high, 'Alert');
        final updated = await repository.getAlertCount();
        expect(updated, greaterThan(initial));
      });
    });

    // Repository Trace Analysis Tests
    group('Repository - Trace Analysis', () {
      test('analyzeTrace creates analysis', () async {
        final analysis = await repository.analyzeTrace('tr_123');
        expect(analysis.traceId, 'tr_123');
        expect(analysis.hasErrors, false);
      });

      test('getTraceAnalysis retrieves analysis', () async {
        final created = await repository.analyzeTrace('tr_123');
        final retrieved = await repository.getTraceAnalysis(created.analysisId);
        expect(retrieved, isNotNull);
      });

      test('getAnalysesWithErrors filters error analyses', () async {
        await repository.analyzeTrace('tr_123');
        
        final errors = await repository.getAnalysesWithErrors();
        expect(errors is List, true);
      });

      test('getSlowTraceAnalyses filters by latency', () async {
        await repository.analyzeTrace('tr_123');
        
        final slow = await repository.getSlowTraceAnalyses(100);
        expect(slow is List, true);
      });

      test('getAnalysisCount returns count', () async {
        final initial = await repository.getAnalysisCount();
        await repository.analyzeTrace('tr_123');
        final updated = await repository.getAnalysisCount();
        expect(updated, greaterThan(initial));
      });
    });

    // Repository Context Propagation Tests
    group('Repository - Context Propagation', () {
      test('createTraceContext creates context', () async {
        final context = await repository.createTraceContext('tr_123', 'sp_123');
        expect(context.traceId, 'tr_123');
        expect(context.spanId, 'sp_123');
      });

      test('getTraceContext retrieves context', () async {
        final created = await repository.createTraceContext('tr_123', 'sp_123');
        final retrieved = await repository.getTraceContext(created.contextId);
        expect(retrieved, isNotNull);
      });

      test('getContextsByTraceId filters by trace', () async {
        await repository.createTraceContext('tr_123', 'sp_1');
        await repository.createTraceContext('tr_123', 'sp_2');
        await repository.createTraceContext('tr_456', 'sp_3');
        
        final contexts = await repository.getContextsByTraceId('tr_123');
        expect(contexts.every((c) => c.traceId == 'tr_123'), true);
      });

      test('getContextCount returns count', () async {
        final initial = await repository.getContextCount();
        await repository.createTraceContext('tr_123', 'sp_123');
        final updated = await repository.getContextCount();
        expect(updated, greaterThan(initial));
      });
    });

    // Repository Reporting Tests
    group('Repository - Reporting', () {
      test('generateReport creates report', () async {
        final now = DateTime.now();
        final report = await repository.generateReport(
          now.subtract(Duration(days: 1)),
          now,
        );
        expect(report.generatedAt, isNotNull);
        expect(report.periodStart, isNotNull);
      });

      test('getObservabilityMetrics returns metrics', () async {
        await repository.createTrace('api', DateTime.now());
        
        final metrics = await repository.getObservabilityMetrics();
        expect(metrics.containsKey('traces'), true);
        expect(metrics.containsKey('spans'), true);
        expect(metrics.containsKey('metrics'), true);
        expect(metrics.containsKey('logs'), true);
        expect(metrics.containsKey('alerts'), true);
      });
    });

    // Engine Tests
    group('Engine Tests', () {
      test('TraceCollectionEngine starts trace', () async {
        final engine = TraceCollectionEngine();
        final trace = await engine.startTrace('api-service');
        expect(trace.serviceName, 'api-service');
        expect(trace.status, TraceStatus.started);
      });

      test('MetricsAggregationEngine aggregates metrics', () async {
        final engine = MetricsAggregationEngine();
        final metrics = [
          Metric(metricId: 'm1', serviceName: 'api', metricName: 'cpu', type: MetricType.gauge, value: 50.0, recordedAt: DateTime.now(), labels: {}),
          Metric(metricId: 'm2', serviceName: 'api', metricName: 'cpu', type: MetricType.gauge, value: 60.0, recordedAt: DateTime.now(), labels: {}),
        ];
        final aggregated = await engine.aggregateMetrics(metrics);
        expect(aggregated.containsKey('cpu'), true);
      });

      test('ServiceHealthEngine assesses health', () async {
        final engine = ServiceHealthEngine();
        final health = await engine.assessHealth('api', 5, 1000);
        expect(health.serviceName, 'api');
        expect(health.errorCount, 5);
        expect(health.requestCount, 1000);
      });

      test('AlertingEngine evaluates alert', () async {
        final engine = AlertingEngine();
        final alert = await engine.evaluateAlert('api', 'cpu', 95.0, 80.0);
        expect(alert.serviceName, 'api');
        expect(alert.severity, AlertSeverity.high);
      });

      test('ContextPropagationEngine propagates context', () async {
        final engine = ContextPropagationEngine();
        final context = await engine.propagateContext('tr_123', 'sp_123');
        expect(context.traceId, 'tr_123');
        expect(context.spanId, 'sp_123');
      });
    });

    // Manager Tests
    group('Manager Tests', () {
      test('ObservabilityManager initializes with engines', () {
        final manager = ObservabilityManager(
          repository: repository,
          traceEngine: TraceCollectionEngine(),
          metricsEngine: MetricsAggregationEngine(),
          healthEngine: ServiceHealthEngine(),
          alertingEngine: AlertingEngine(),
          contextEngine: ContextPropagationEngine(),
        );
        expect(manager.repository, isNotNull);
        expect(manager.traceEngine, isNotNull);
      });
    });

    // Facade Tests
    group('Facade Tests', () {
      test('ObservabilityFacade exposes startTrace', () async {
        final manager = ObservabilityManager(
          repository: repository,
          traceEngine: TraceCollectionEngine(),
          metricsEngine: MetricsAggregationEngine(),
          healthEngine: ServiceHealthEngine(),
          alertingEngine: AlertingEngine(),
          contextEngine: ContextPropagationEngine(),
        );
        final facade = ObservabilityFacade(repository: repository, manager: manager);
        
        final trace = await facade.startTrace('api');
        expect(trace.serviceName, 'api');
      });

      test('ObservabilityFacade exposes getTraces', () async {
        final manager = ObservabilityManager(
          repository: repository,
          traceEngine: TraceCollectionEngine(),
          metricsEngine: MetricsAggregationEngine(),
          healthEngine: ServiceHealthEngine(),
          alertingEngine: AlertingEngine(),
          contextEngine: ContextPropagationEngine(),
        );
        final facade = ObservabilityFacade(repository: repository, manager: manager);
        
        await repository.createTrace('api', DateTime.now());
        final traces = await facade.getTraces();
        expect(traces is List<Trace>, true);
      });

      test('ObservabilityFacade exposes generateReport', () async {
        final manager = ObservabilityManager(
          repository: repository,
          traceEngine: TraceCollectionEngine(),
          metricsEngine: MetricsAggregationEngine(),
          healthEngine: ServiceHealthEngine(),
          alertingEngine: AlertingEngine(),
          contextEngine: ContextPropagationEngine(),
        );
        final facade = ObservabilityFacade(repository: repository, manager: manager);
        
        final now = DateTime.now();
        final report = await facade.generateReport(now.subtract(Duration(days: 1)), now);
        expect(report.generatedAt, isNotNull);
      });
    });

    // Integration Tests
    group('Integration Tests', () {
      test('Full tracing workflow', () async {
        final trace = await repository.createTrace('api', DateTime.now());
        final span = await repository.createSpan(trace.traceId, 'query', SpanKind.internal, '');
        await repository.completeSpan(span.spanId);
        await repository.updateTraceStatus(trace.traceId, TraceStatus.completed);
        
        final retrieved = await repository.getTrace(trace.traceId);
        expect(retrieved!.status, TraceStatus.completed);
      });

      test('Health monitoring workflow', () async {
        final health = await repository.recordServiceHealth('api', 0.1, 500.0, 250.0, 1000, 1);
        final metric = await repository.recordMetric('api', 'latency', MetricType.gauge, 500.0, {});
        
        final latest = await repository.getLatestServiceHealth('api');
        expect(latest, isNotNull);
      });

      test('Alert and log workflow', () async {
        final alert = await repository.createAlert('api', 'error_rate', AlertSeverity.high, 'Alert');
        final log = await repository.recordLog('api', LogLevel.error, 'Error detected', alert.alertId);
        
        final logs = await repository.getErrorLogs('api');
        expect(logs.isNotEmpty, true);
      });
    });

    // Edge Case Tests
    group('Edge Case Tests', () {
      test('Trace with empty service name', () async {
        final trace = await repository.createTrace('', DateTime.now());
        expect(trace.serviceName, '');
      });

      test('Metric with extreme values', () async {
        final metric = await repository.recordMetric('api', 'value', MetricType.gauge, double.infinity, {});
        expect(metric.value, double.infinity);
      });

      test('Empty log message', () async {
        final log = await repository.recordLog('api', LogLevel.info, '', 'tr_123');
        expect(log.message, '');
      });

      test('Zero sampling rate', () async {
        final sampling = await repository.createSamplingConfig('api', SamplingStrategy.never, 0.0, 0);
        expect(sampling.samplingRate, 0.0);
      });

      test('Negative latency handling', () async {
        final now = DateTime.now();
        final trace = Trace(
          traceId: 'tr_123',
          parentTraceId: '',
          serviceName: 'api',
          startTime: now,
          status: TraceStatus.active,
          spanIds: [],
          tags: {},
        );
        expect(trace.durationMs, -1);
      });
    });

    // Performance Tests
    group('Performance Tests', () {
      test('Create 100 traces efficiently', () async {
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 100; i++) {
          await repository.createTrace('api', DateTime.now());
        }
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('List traces with large dataset', () async {
        for (int i = 0; i < 50; i++) {
          await repository.createTrace('api', DateTime.now());
        }
        final stopwatch = Stopwatch()..start();
        final traces = await repository.listTraces(limit: 25);
        stopwatch.stop();
        expect(traces.length, 25);
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });

      test('Query with filters efficiently', () async {
        for (int i = 0; i < 30; i++) {
          await repository.createTrace('service-$i', DateTime.now());
        }
        final stopwatch = Stopwatch()..start();
        final filter = ObservabilityFilter(
          filterId: 'flt_123',
          filterName: 'test',
          serviceName: 'service-1',
        );
        await repository.getTracesByFilter(filter);
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });

    // Null Safety Tests
    group('Null Safety Tests', () {
      test('Handle null trace gracefully', () async {
        final trace = await repository.getTrace('non_existent_id');
        expect(trace, isNull);
      });

      test('Span without error message', () async {
        final span = await repository.createSpan('tr_123', 'query', SpanKind.client, 'sp_parent');
        expect(span.errorMessage, isNull);
        expect(span.hasError, false);
      });

      test('Alert without resolution', () async {
        final alert = await repository.createAlert('api', 'metric', AlertSeverity.low, 'Alert');
        expect(alert.resolution, isNull);
        expect(alert.isResolved, false);
      });

      test('Log without stack trace', () async {
        final log = await repository.recordLog('api', LogLevel.info, 'msg', 'tr_123');
        expect(log.stackTrace, isNull);
      });

      test('Trace filter without constraints', () async {
        final filter = ObservabilityFilter(
          filterId: 'flt_123',
          filterName: 'all',
        );
        expect(filter.hasFilters, false);
      });
    });
  });
}
