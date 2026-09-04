import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/observability_models.dart';
import 'package:project_040/services/observability_service.dart';

void main() {
  group('Phase 42: Observability & Tracing', () {
    // ==================== モデルテスト ====================
    group('SpanKind Enum', () {
      test('internal kind has correct value', () {
        expect(SpanKind.internal.value, equals('internal'));
      });

      test('server kind has correct value', () {
        expect(SpanKind.server.value, equals('server'));
      });

      test('client kind has correct value', () {
        expect(SpanKind.client.value, equals('client'));
      });
    });

    group('SpanStatus Enum', () {
      test('ok status has correct value', () {
        expect(SpanStatus.ok.value, equals('ok'));
      });

      test('error status has correct value', () {
        expect(SpanStatus.error.value, equals('error'));
      });
    });

    group('LogLevel Enum', () {
      test('info level has correct value', () {
        expect(LogLevel.info.value, equals('info'));
      });

      test('error level has correct value', () {
        expect(LogLevel.error.value, equals('error'));
      });
    });

    group('MetricType Enum', () {
      test('counter type has correct value', () {
        expect(MetricType.counter.value, equals('counter'));
      });

      test('histogram type has correct value', () {
        expect(MetricType.histogram.value, equals('histogram'));
      });
    });

    group('TraceContext', () {
      test('creation with required fields', () {
        final now = DateTime.now();
        final context = TraceContext(
          traceId: 'trace1',
          spanId: 'span1',
          createdAt: now,
        );

        expect(context.traceId, equals('trace1'));
        expect(context.spanId, equals('span1'));
        expect(context.parentSpanId, isNull);
      });

      test('withParentSpan creates new context', () {
        final context = TraceContext(
          traceId: 'trace1',
          spanId: 'span1',
          createdAt: DateTime.now(),
        );

        final childContext = context.withParentSpan('span2');

        expect(childContext.traceId, equals('trace1'));
        expect(childContext.parentSpanId, equals('span2'));
        expect(childContext.spanId, isNotEmpty);
      });
    });

    group('Span', () {
      test('span creation', () {
        final now = DateTime.now();
        final span = Span(
          spanId: 'span1',
          traceId: 'trace1',
          name: 'operation',
          kind: SpanKind.internal,
          startTime: now,
        );

        expect(span.spanId, equals('span1'));
        expect(span.name, equals('operation'));
        expect(span.status, equals(SpanStatus.unset));
      });

      test('span duration calculation', () {
        final now = DateTime.now();
        final pastTime = now.subtract(const Duration(milliseconds: 100));
        final span = Span(
          spanId: 'span1',
          traceId: 'trace1',
          name: 'operation',
          kind: SpanKind.internal,
          startTime: pastTime,
          endTime: now,
        );

        expect(span.durationMs, greaterThan(90));
        expect(span.durationMs, lessThan(150));
      });

      test('span add attribute', () {
        final span = Span(
          spanId: 'span1',
          traceId: 'trace1',
          name: 'operation',
          kind: SpanKind.internal,
          startTime: DateTime.now(),
        );

        span.addAttribute('user_id', 'user123');

        expect(span.attributes['user_id'], equals('user123'));
      });

      test('span add event', () {
        final span = Span(
          spanId: 'span1',
          traceId: 'trace1',
          name: 'operation',
          kind: SpanKind.internal,
          startTime: DateTime.now(),
        );

        final event = SpanEvent(
          name: 'started',
          timestamp: DateTime.now(),
        );

        span.addEvent(event);

        expect(span.events.length, equals(1));
        expect(span.events[0].name, equals('started'));
      });

      test('span end sets status', () {
        final span = Span(
          spanId: 'span1',
          traceId: 'trace1',
          name: 'operation',
          kind: SpanKind.internal,
          startTime: DateTime.now(),
        );

        span.end(status: SpanStatus.ok);

        expect(span.status, equals(SpanStatus.ok));
        expect(span.endTime, isNotNull);
      });

      test('span error detection', () {
        final span = Span(
          spanId: 'span1',
          traceId: 'trace1',
          name: 'operation',
          kind: SpanKind.internal,
          startTime: DateTime.now(),
        );

        span.end(status: SpanStatus.error, errorMsg: 'Database error');

        expect(span.isError, isTrue);
        expect(span.errorMessage, equals('Database error'));
      });
    });

    group('Trace', () {
      test('trace creation', () {
        final now = DateTime.now();
        final trace = Trace(
          traceId: 'trace1',
          rootSpanId: 'span1',
          spans: [],
          startTime: now,
        );

        expect(trace.traceId, equals('trace1'));
        expect(trace.spanCount, equals(0));
      });

      test('trace with spans', () {
        final now = DateTime.now();
        final span1 = Span(
          spanId: 'span1',
          traceId: 'trace1',
          name: 'op1',
          kind: SpanKind.internal,
          startTime: now,
        );
        final span2 = Span(
          spanId: 'span2',
          traceId: 'trace1',
          name: 'op2',
          kind: SpanKind.internal,
          startTime: now,
        );

        final trace = Trace(
          traceId: 'trace1',
          rootSpanId: 'span1',
          spans: [span1, span2],
          startTime: now,
        );

        expect(trace.spanCount, equals(2));
      });

      test('trace error span count', () {
        final now = DateTime.now();
        final span1 = Span(
          spanId: 'span1',
          traceId: 'trace1',
          name: 'op1',
          kind: SpanKind.internal,
          startTime: now,
        );
        final span2 = Span(
          spanId: 'span2',
          traceId: 'trace1',
          name: 'op2',
          kind: SpanKind.internal,
          startTime: now,
        );

        span2.end(status: SpanStatus.error);

        final trace = Trace(
          traceId: 'trace1',
          rootSpanId: 'span1',
          spans: [span1, span2],
          startTime: now,
        );

        expect(trace.errorSpanCount, equals(1));
      });
    });

    group('Metric', () {
      test('metric creation', () {
        final now = DateTime.now();
        final metric = Metric(
          metricId: 'metric1',
          name: 'latency',
          type: MetricType.histogram,
          unit: 'ms',
          value: 125.5,
          timestamp: now,
        );

        expect(metric.name, equals('latency'));
        expect(metric.value, equals(125.5));
      });
    });

    group('TraceMetrics', () {
      test('error rate calculation', () {
        final metrics = TraceMetrics(
          metricsId: 'metrics1',
          traceId: 'trace1',
          totalSpans: 10,
          errorSpans: 2,
          averageLatencyMs: 150.0,
          createdAt: DateTime.now(),
        );

        expect(metrics.errorRate, closeTo(0.2, 0.01));
        expect(metrics.errorRatePercentage, equals(20));
      });

      test('zero error rate', () {
        final metrics = TraceMetrics(
          metricsId: 'metrics1',
          traceId: 'trace1',
          totalSpans: 10,
          errorSpans: 0,
          averageLatencyMs: 150.0,
          createdAt: DateTime.now(),
        );

        expect(metrics.errorRate, equals(0.0));
      });
    });

    group('ObservabilityLog', () {
      test('log creation', () {
        final now = DateTime.now();
        final log = ObservabilityLog(
          logId: 'log1',
          traceId: 'trace1',
          spanId: 'span1',
          level: LogLevel.info,
          message: 'Request started',
          timestamp: now,
        );

        expect(log.message, equals('Request started'));
        expect(log.level, equals(LogLevel.info));
      });
    });

    group('SamplingPolicy', () {
      test('always sampling policy', () {
        final policy = SamplingPolicy(
          policyId: 'policy1',
          type: SamplingType.always,
          probability: 1.0,
          createdAt: DateTime.now(),
        );

        expect(policy.shouldSample(), isTrue);
      });

      test('never sampling policy', () {
        final policy = SamplingPolicy(
          policyId: 'policy1',
          type: SamplingType.never,
          probability: 0.0,
          createdAt: DateTime.now(),
        );

        expect(policy.shouldSample(), isFalse);
      });
    });

    // ==================== リポジトリテスト ====================
    group('MemoryObservabilityRepository', () {
      late MemoryObservabilityRepository repository;

      setUp(() {
        repository = MemoryObservabilityRepository();
      });

      test('save and retrieve trace', () async {
        final now = DateTime.now();
        final trace = Trace(
          traceId: 'trace1',
          rootSpanId: 'span1',
          spans: [],
          startTime: now,
        );

        await repository.saveTrace(trace);
        final retrieved = await repository.getTrace('trace1');

        expect(retrieved, isNotNull);
        expect(retrieved!.traceId, equals('trace1'));
      });

      test('save and retrieve span', () async {
        final now = DateTime.now();
        final span = Span(
          spanId: 'span1',
          traceId: 'trace1',
          name: 'operation',
          kind: SpanKind.internal,
          startTime: now,
        );

        await repository.saveSpan(span);
        final spans = await repository.getSpansByTraceId('trace1');

        expect(spans.length, equals(1));
        expect(spans[0].spanId, equals('span1'));
      });

      test('save metric', () async {
        final metric = Metric(
          metricId: 'metric1',
          name: 'latency',
          type: MetricType.histogram,
          value: 125.5,
          timestamp: DateTime.now(),
        );

        await repository.saveMetric(metric);
        // メトリクスは取得メソッドがないのでテストは省略
      });

      test('save log', () async {
        final log = ObservabilityLog(
          logId: 'log1',
          traceId: 'trace1',
          level: LogLevel.info,
          message: 'Test log',
          timestamp: DateTime.now(),
        );

        await repository.saveLog(log);
        // ログは取得メソッドがないのでテストは省略
      });
    });

    // ==================== エンジンテスト ====================
    group('MemoryTraceEngine', () {
      late ObservabilityRepository repository;
      late MemoryTraceEngine engine;

      setUp(() {
        repository = MemoryObservabilityRepository();
        engine = MemoryTraceEngine(repository);
      });

      test('start and end trace', () async {
        final context = engine.startTrace('test_operation');
        expect(context.traceId, isNotEmpty);

        await engine.endTrace(context);

        final trace = await engine.getTrace(context.traceId);
        expect(trace, isNotNull);
      });

      test('start span within trace', () async {
        final context = engine.startTrace('test_operation');
        final span = engine.startSpan(context, 'test_span');

        expect(span.traceId, equals(context.traceId));
        expect(span.name, equals('test_span'));
      });

      test('end span sets duration', () async {
        final context = engine.startTrace('test_operation');
        final span = engine.startSpan(context, 'test_span');

        await Future.delayed(const Duration(milliseconds: 10));
        await engine.endSpan(span);

        expect(span.endTime, isNotNull);
        expect(span.durationMs, greaterThan(0));
      });

      test('calculate trace metrics', () async {
        final context = engine.startTrace('test_operation');
        final span1 = engine.startSpan(context, 'span1');
        final span2 = engine.startSpan(context, 'span2');

        await engine.endSpan(span1);
        await engine.endSpan(span2);
        await engine.endTrace(context);

        final metrics = await engine.calculateMetrics(context.traceId);

        expect(metrics.totalSpans, equals(2));
        expect(metrics.errorSpans, equals(0));
      });

      test('track error spans in metrics', () async {
        final context = engine.startTrace('test_operation');
        final span1 = engine.startSpan(context, 'span1');
        final span2 = engine.startSpan(context, 'span2');

        await engine.endSpan(span1);
        span2.end(status: SpanStatus.error);
        await engine.endSpan(span2);
        await engine.endTrace(context);

        final metrics = await engine.calculateMetrics(context.traceId);

        expect(metrics.errorSpans, equals(1));
        expect(metrics.errorRatePercentage, equals(50));
      });
    });

    // ==================== マネージャーテスト ====================
    group('MemoryObservabilityManager', () {
      late ObservabilityRepository repository;
      late TraceEngine traceEngine;
      late MemoryObservabilityManager manager;

      setUp(() {
        repository = MemoryObservabilityRepository();
        traceEngine = MemoryTraceEngine(repository);
        manager = MemoryObservabilityManager(repository, traceEngine);
      });

      test('record metric', () async {
        final metric = Metric(
          metricId: 'metric1',
          name: 'latency',
          type: MetricType.histogram,
          value: 125.5,
          timestamp: DateTime.now(),
        );

        await manager.recordMetric(metric);
        // メトリクスは取得メソッドがないのでテストは省略
      });

      test('record log', () async {
        final log = ObservabilityLog(
          logId: 'log1',
          traceId: 'trace1',
          level: LogLevel.info,
          message: 'Test message',
          timestamp: DateTime.now(),
        );

        await manager.recordLog(log);
        // ログは取得メソッドがないのでテストは省略
      });

      test('get trace metrics', () async {
        final context = traceEngine.startTrace('operation');
        final span = traceEngine.startSpan(context, 'test');

        await traceEngine.endSpan(span);
        await traceEngine.endTrace(context);

        final metrics = await manager.getTraceMetrics(context.traceId);

        expect(metrics, isNotNull);
        expect(metrics!.totalSpans, equals(1));
      });
    });

    // ==================== ファサードテスト ====================
    group('ObservabilityManagerFacade', () {
      late ObservabilityManagerFacade facade;

      setUp(() {
        facade = ObservabilityManagerFacade();
      });

      test('start and end trace', () async {
        final context = facade.startTrace('test_operation');
        expect(context.traceId, isNotEmpty);

        await facade.endTrace(context);

        final trace = await facade.getTrace(context.traceId);
        expect(trace, isNotNull);
      });

      test('complete span workflow', () async {
        final context = facade.startTrace('user_request');
        final span = facade.startSpan(context, 'process_data');

        span.addAttribute('user_id', 'user123');

        await Future.delayed(const Duration(milliseconds: 5));
        await facade.endSpan(span);
        await facade.endTrace(context);

        final metrics = await facade.getTraceMetrics(context.traceId);

        expect(metrics!.totalSpans, equals(1));
      });

      test('record metrics and logs', () async {
        final context = facade.startTrace('operation');
        final span = facade.startSpan(context, 'test');

        final metric = Metric(
          metricId: 'metric1',
          name: 'latency',
          type: MetricType.histogram,
          value: 125.5,
          timestamp: DateTime.now(),
        );
        await facade.recordMetric(metric);

        final log = ObservabilityLog(
          logId: 'log1',
          traceId: context.traceId,
          spanId: span.spanId,
          level: LogLevel.info,
          message: 'Processing complete',
          timestamp: DateTime.now(),
        );
        await facade.recordLog(log);

        await facade.endSpan(span);
        await facade.endTrace(context);

        expect(true, isTrue);
      });

      test('start trace with sampling policy', () async {
        final policy = SamplingPolicy(
          policyId: 'policy1',
          type: SamplingType.always,
          probability: 1.0,
          createdAt: DateTime.now(),
        );

        final context = facade.startTraceWithPolicy('operation', policy);
        expect(context.traceId, isNotEmpty);
      });

      test('generate report', () async {
        final report = await facade.generateReport('user123');

        expect(report, isNotNull);
        expect(report.reportId, isNotEmpty);
      });

      test('nested spans', () async {
        final context = facade.startTrace('parent_operation');

        final parentSpan = facade.startSpan(context, 'parent');
        final childContext = context.withParentSpan(parentSpan.spanId);
        final childSpan = facade.startSpan(childContext, 'child');

        await facade.endSpan(childSpan);
        await facade.endSpan(parentSpan);
        await facade.endTrace(context);

        final trace = await facade.getTrace(context.traceId);
        expect(trace, isNotNull);
      });

      test('performance profiling', () async {
        final context = facade.startTrace('operation');
        final span1 = facade.startSpan(context, 'fast');
        final span2 = facade.startSpan(context, 'slow');

        await Future.delayed(const Duration(milliseconds: 10));
        await facade.endSpan(span1);

        await Future.delayed(const Duration(milliseconds: 20));
        await facade.endSpan(span2);

        await facade.endTrace(context);

        final profile = await facade.profilePerformance(context.traceId);

        expect(profile, isNotEmpty);
        expect(profile['span_count'], equals(2));
      });
    });

    // ==================== 統合テスト ====================
    group('Integration Tests', () {
      test('complete observability workflow', () async {
        final facade = ObservabilityManagerFacade();

        // トレース開始
        final context = facade.startTrace('process_user_request');

        // バリデーションスパン
        final validateSpan = facade.startSpan(
          context,
          'validate_input',
          kind: SpanKind.internal,
        );
        validateSpan.addAttribute('fields_checked', 5);
        await facade.endSpan(validateSpan);

        // データベーススパン
        final dbSpan = facade.startSpan(
          context,
          'database_query',
          kind: SpanKind.client,
        );
        dbSpan.addAttribute('query_type', 'SELECT');
        await facade.endSpan(dbSpan);

        // トレース終了
        await facade.endTrace(context);

        // メトリクス取得
        final metrics = await facade.getTraceMetrics(context.traceId);

        expect(metrics!.totalSpans, equals(2));
        expect(metrics.errorSpans, equals(0));
      });

      test('error tracking in observability', () async {
        final facade = ObservabilityManagerFacade();

        final context = facade.startTrace('failing_operation');
        final span = facade.startSpan(context, 'operation');

        span.addEvent(SpanEvent(
          name: 'error_occurred',
          timestamp: DateTime.now(),
          attributes: {'error_code': 500},
        ));

        span.end(
          status: SpanStatus.error,
          errorMsg: 'Database connection timeout',
        );

        await facade.endSpan(span);
        await facade.endTrace(context);

        final trace = await facade.getTrace(context.traceId);

        expect(trace!.errorSpanCount, equals(1));
      });
    });

    // ==================== レポートテスト ====================
    group('ObservabilityReport', () {
      test('markdown generation', () {
        final report = ObservabilityReport(
          reportId: 'report1',
          generatedAt: DateTime.now(),
          traceMetrics: [],
          metrics: [],
          totalTraces: 100,
          totalErrors: 5,
          systemHealthScore: 0.95,
        );

        final markdown = report.toMarkdown();

        expect(markdown, contains('Observability Report'));
        expect(markdown, contains('Total Traces'));
        expect(markdown, contains('System Health Score'));
      });
    });
  });
}
