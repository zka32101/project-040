/// Phase 42: Observability & Tracing 監視可能性サービス実装
///
/// 分散トレーシング、メトリクス、ログ記録

import 'package:project_040/models/observability_models.dart';

/// 監視可能性リポジトリインターフェース
abstract class ObservabilityRepository {
  /// トレースを保存
  Future<void> saveTrace(Trace trace);

  /// トレースを取得
  Future<Trace?> getTrace(String traceId);

  /// スパンを保存
  Future<void> saveSpan(Span span);

  /// トレースIDでスパンを取得
  Future<List<Span>> getSpansByTraceId(String traceId);

  /// メトリクスを保存
  Future<void> saveMetric(Metric metric);

  /// ログを保存
  Future<void> saveLog(ObservabilityLog log);

  /// トレースメトリクスを保存
  Future<void> saveTraceMetrics(TraceMetrics metrics);
}

/// メモリ実装の監視可能性リポジトリ
class MemoryObservabilityRepository implements ObservabilityRepository {
  final Map<String, Trace> _traces = {};
  final Map<String, Span> _spans = {};
  final Map<String, List<Span>> _spansByTraceId = {};
  final Map<String, Metric> _metrics = {};
  final Map<String, ObservabilityLog> _logs = {};
  final Map<String, TraceMetrics> _traceMetrics = {};

  @override
  Future<void> saveTrace(Trace trace) async {
    _traces[trace.traceId] = trace;
  }

  @override
  Future<Trace?> getTrace(String traceId) async => _traces[traceId];

  @override
  Future<void> saveSpan(Span span) async {
    _spans[span.spanId] = span;
    _spansByTraceId.putIfAbsent(span.traceId, () => []).add(span);
  }

  @override
  Future<List<Span>> getSpansByTraceId(String traceId) async =>
      _spansByTraceId[traceId] ?? [];

  @override
  Future<void> saveMetric(Metric metric) async {
    _metrics[metric.metricId] = metric;
  }

  @override
  Future<void> saveLog(ObservabilityLog log) async {
    _logs[log.logId] = log;
  }

  @override
  Future<void> saveTraceMetrics(TraceMetrics metrics) async {
    _traceMetrics[metrics.metricsId] = metrics;
  }
}

/// トレースエンジンインターフェース
abstract class TraceEngine {
  /// トレース開始
  TraceContext startTrace(String operationName);

  /// スパン開始
  Span startSpan(
    TraceContext context,
    String spanName, {
    SpanKind? kind,
  });

  /// スパン終了
  Future<void> endSpan(Span span);

  /// トレース終了
  Future<void> endTrace(TraceContext context);

  /// トレース取得
  Future<Trace?> getTrace(String traceId);

  /// トレースメトリクス計算
  Future<TraceMetrics> calculateMetrics(String traceId);
}

/// メモリ実装のトレースエンジン
class MemoryTraceEngine implements TraceEngine {
  final ObservabilityRepository _repository;
  final Map<String, List<Span>> _activeSpans = {};
  final Map<String, DateTime> _traceStartTimes = {};

  MemoryTraceEngine(this._repository);

  @override
  TraceContext startTrace(String operationName) {
    final traceId = 'trace:${DateTime.now().millisecondsSinceEpoch}';
    final spanId = 'span:${DateTime.now().millisecondsSinceEpoch}';

    _traceStartTimes[traceId] = DateTime.now();
    _activeSpans[traceId] = [];

    return TraceContext(
      traceId: traceId,
      spanId: spanId,
      createdAt: DateTime.now(),
    );
  }

  @override
  Span startSpan(
    TraceContext context,
    String spanName, {
    SpanKind? kind,
  }) {
    final span = Span(
      spanId: 'span:${DateTime.now().millisecondsSinceEpoch}',
      traceId: context.traceId,
      parentSpanId: context.parentSpanId,
      name: spanName,
      kind: kind ?? SpanKind.internal,
      startTime: DateTime.now(),
    );

    _activeSpans.putIfAbsent(context.traceId, () => []).add(span);
    return span;
  }

  @override
  Future<void> endSpan(Span span) async {
    span.end();
    await _repository.saveSpan(span);
  }

  @override
  Future<void> endTrace(TraceContext context) async {
    final spans = _activeSpans[context.traceId] ?? [];
    final startTime = _traceStartTimes[context.traceId] ?? DateTime.now();

    final trace = Trace(
      traceId: context.traceId,
      rootSpanId: context.spanId,
      spans: spans,
      startTime: startTime,
      endTime: DateTime.now(),
    );

    await _repository.saveTrace(trace);
    _activeSpans.remove(context.traceId);
    _traceStartTimes.remove(context.traceId);
  }

  @override
  Future<Trace?> getTrace(String traceId) async =>
      _repository.getTrace(traceId);

  @override
  Future<TraceMetrics> calculateMetrics(String traceId) async {
    final spans = await _repository.getSpansByTraceId(traceId);

    if (spans.isEmpty) {
      return TraceMetrics(
        metricsId: 'metrics:${DateTime.now().millisecondsSinceEpoch}',
        traceId: traceId,
        totalSpans: 0,
        errorSpans: 0,
        averageLatencyMs: 0,
        createdAt: DateTime.now(),
      );
    }

    final errorSpans = spans.where((s) => s.isError).length;
    final avgLatency = spans.isEmpty
        ? 0.0
        : spans.map((s) => s.durationMs).reduce((a, b) => a + b) / spans.length;
    final slowestSpan = spans.isEmpty
        ? null
        : spans.reduce((a, b) => a.durationMs > b.durationMs ? a : b);

    return TraceMetrics(
      metricsId: 'metrics:${DateTime.now().millisecondsSinceEpoch}',
      traceId: traceId,
      totalSpans: spans.length,
      errorSpans: errorSpans,
      averageLatencyMs: avgLatency.toDouble(),
      slowestSpan: slowestSpan?.name,
      slowestSpanDurationMs: slowestSpan?.durationMs,
      createdAt: DateTime.now(),
    );
  }
}

/// 監視可能性管理インターフェース
abstract class ObservabilityManager {
  /// メトリクスを記録
  Future<void> recordMetric(Metric metric);

  /// ログを記録
  Future<void> recordLog(ObservabilityLog log);

  /// トレースメトリクスを取得
  Future<TraceMetrics?> getTraceMetrics(String traceId);

  /// レポートを生成
  Future<ObservabilityReport> generateReport(String userId);
}

/// メモリ実装の監視可能性管理
class MemoryObservabilityManager implements ObservabilityManager {
  final ObservabilityRepository _repository;
  final TraceEngine _traceEngine;

  MemoryObservabilityManager(
    this._repository,
    this._traceEngine,
  );

  @override
  Future<void> recordMetric(Metric metric) async {
    await _repository.saveMetric(metric);
  }

  @override
  Future<void> recordLog(ObservabilityLog log) async {
    await _repository.saveLog(log);
  }

  @override
  Future<TraceMetrics?> getTraceMetrics(String traceId) async {
    return _traceEngine.calculateMetrics(traceId);
  }

  @override
  Future<ObservabilityReport> generateReport(String userId) async {
    return ObservabilityReport(
      reportId: 'report:${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      traceMetrics: [],
      metrics: [],
      totalTraces: 0,
      totalErrors: 0,
      systemHealthScore: 0.95,
    );
  }
}

/// 監視可能性管理マネージャー (ファサード)
class ObservabilityManagerFacade {
  late ObservabilityRepository _repository;
  late TraceEngine _traceEngine;
  late ObservabilityManager _manager;

  ObservabilityManagerFacade({
    ObservabilityRepository? repository,
    TraceEngine? traceEngine,
    ObservabilityManager? manager,
  }) {
    _repository = repository ?? MemoryObservabilityRepository();
    _traceEngine = traceEngine ?? MemoryTraceEngine(_repository);
    _manager = manager ?? MemoryObservabilityManager(_repository, _traceEngine);
  }

  /// トレース開始
  TraceContext startTrace(String operationName) =>
      _traceEngine.startTrace(operationName);

  /// スパン開始
  Span startSpan(
    TraceContext context,
    String spanName, {
    SpanKind? kind,
  }) =>
      _traceEngine.startSpan(context, spanName, kind: kind);

  /// スパン終了
  Future<void> endSpan(Span span) => _traceEngine.endSpan(span);

  /// トレース終了
  Future<void> endTrace(TraceContext context) =>
      _traceEngine.endTrace(context);

  /// メトリクスを記録
  Future<void> recordMetric(Metric metric) => _manager.recordMetric(metric);

  /// ログを記録
  Future<void> recordLog(ObservabilityLog log) => _manager.recordLog(log);

  /// トレース取得
  Future<Trace?> getTrace(String traceId) => _traceEngine.getTrace(traceId);

  /// トレースメトリクス取得
  Future<TraceMetrics?> getTraceMetrics(String traceId) =>
      _manager.getTraceMetrics(traceId);

  /// レポート生成
  Future<ObservabilityReport> generateReport(String userId) =>
      _manager.generateReport(userId);

  /// サンプリングポリシーでトレース開始
  TraceContext startTraceWithPolicy(
    String operationName,
    SamplingPolicy policy,
  ) {
    if (!policy.shouldSample()) {
      // サンプリング対象外のトレースを作成
      return TraceContext(
        traceId: 'trace:disabled',
        spanId: 'span:disabled',
        createdAt: DateTime.now(),
      );
    }
    return startTrace(operationName);
  }

  /// トレース検索（エラーのみ）
  Future<List<TraceMetrics>> searchErrorTraces() async {
    // エラートレースを検索する実装
    // （実装は簡略化）
    return [];
  }

  /// パフォーマンスプロファイル
  Future<Map<String, dynamic>> profilePerformance(String traceId) async {
    final trace = await getTrace(traceId);
    if (trace == null) return {};

    final slowestSpans = trace.spans
      ..sort((a, b) => b.durationMs.compareTo(a.durationMs));

    return {
      'total_duration': trace.durationMs,
      'span_count': trace.spanCount,
      'error_count': trace.errorSpanCount,
      'slowest_spans': slowestSpans.take(5).map((s) => {
        'name': s.name,
        'duration_ms': s.durationMs,
      }).toList(),
    };
  }
}
