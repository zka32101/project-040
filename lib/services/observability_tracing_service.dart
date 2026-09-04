/// Observability & Tracing Service

import 'package:project_040/models/observability_models.dart';

abstract class ObservabilityRepository {
  // Trace Management (10 methods)
  Future<Trace> createTrace(String serviceName, DateTime startTime, {String parentTraceId = ''});
  Future<Trace?> getTrace(String traceId);
  Future<Trace> updateTraceStatus(String traceId, TraceStatus status, {String? errorMessage});
  Future<void> deleteTrace(String traceId);
  Future<List<Trace>> listTraces({int limit = 50});
  Future<List<Trace>> getActiveTraces();
  Future<List<Trace>> getFailedTraces();
  Future<List<Trace>> getTracesByService(String serviceName);
  Future<int> getTraceCount();
  Future<List<Trace>> getTracesByFilter(ObservabilityFilter filter);

  // Span Management (8 methods)
  Future<Span> createSpan(String traceId, String operationName, SpanKind kind, String parentSpanId);
  Future<Span?> getSpan(String spanId);
  Future<Span> completeSpan(String spanId, {String? errorMessage});
  Future<void> deleteSpan(String spanId);
  Future<List<Span>> getSpansByTrace(String traceId);
  Future<List<Span>> getErrorSpans(String traceId);
  Future<int> getSpanCount(String traceId);
  Future<List<Span>> getSlowSpans(String traceId, int thresholdMs);

  // Metric Recording (7 methods)
  Future<Metric> recordMetric(String serviceName, String metricName, MetricType type, double value, Map<String, String> labels);
  Future<Metric?> getMetric(String metricId);
  Future<List<Metric>> getMetricsByService(String serviceName);
  Future<List<Metric>> getMetricsByName(String metricName);
  Future<List<Metric>> getRecentMetrics(int minutesBack);
  Future<double> getAverageMetricValue(String metricName);
  Future<int> getMetricCount();

  // Log Management (8 methods)
  Future<LogEntry> recordLog(String serviceName, LogLevel level, String message, String traceId, {String? spanId});
  Future<LogEntry?> getLog(String logId);
  Future<List<LogEntry>> getLogsByService(String serviceName);
  Future<List<LogEntry>> getLogsByLevel(LogLevel level);
  Future<List<LogEntry>> getLogsByTraceId(String traceId);
  Future<List<LogEntry>> getErrorLogs(String serviceName);
  Future<void> deleteLog(String logId);
  Future<int> getLogCount();

  // Sampling Configuration (6 methods)
  Future<Sampling> createSamplingConfig(String serviceName, SamplingStrategy strategy, double rate, int maxTraces);
  Future<Sampling?> getSamplingConfig(String samplingId);
  Future<List<Sampling>> getSamplingConfigsByService(String serviceName);
  Future<void> updateSamplingConfig(String samplingId, {double? rate, int? maxTraces});
  Future<void> disableSamplingConfig(String samplingId);
  Future<List<Sampling>> getActiveSamplingConfigs();

  // Service Health (6 methods)
  Future<ServiceHealth> recordServiceHealth(String serviceName, double errorRate, double p99, double p95, int requests, int errors);
  Future<ServiceHealth?> getServiceHealth(String healthId);
  Future<ServiceHealth?> getLatestServiceHealth(String serviceName);
  Future<List<ServiceHealth>> getHealthByService(String serviceName);
  Future<List<ServiceHealth>> getUnhealthyServices();
  Future<int> getServiceHealthCount();

  // Alert Management (7 methods)
  Future<Alert> createAlert(String serviceName, String metricName, AlertSeverity severity, String description);
  Future<Alert?> getAlert(String alertId);
  Future<Alert> resolveAlert(String alertId, String? resolution);
  Future<List<Alert>> getActiveAlerts();
  Future<List<Alert>> getAlertsByService(String serviceName);
  Future<List<Alert>> getAlertsBySeverity(AlertSeverity severity);
  Future<int> getAlertCount();

  // Trace Analysis (5 methods)
  Future<TraceAnalysis> analyzeTrace(String traceId);
  Future<TraceAnalysis?> getTraceAnalysis(String analysisId);
  Future<List<TraceAnalysis>> getAnalysesWithErrors();
  Future<List<TraceAnalysis>> getSlowTraceAnalyses(int thresholdMs);
  Future<int> getAnalysisCount();

  // Context Propagation (4 methods)
  Future<DistributedTraceContext> createTraceContext(String traceId, String spanId);
  Future<DistributedTraceContext?> getTraceContext(String contextId);
  Future<List<DistributedTraceContext>> getContextsByTraceId(String traceId);
  Future<int> getContextCount();

  // Reporting (2 methods)
  Future<ObservabilityReport> generateReport(DateTime startDate, DateTime endDate);
  Future<Map<String, dynamic>> getObservabilityMetrics();
}

class ObservabilityRepositoryImpl implements ObservabilityRepository {
  final Map<String, Map<String, dynamic>> _storage = {};

  ObservabilityRepositoryImpl() {
    _storage['traces'] = {};
    _storage['spans'] = {};
    _storage['metrics'] = {};
    _storage['logs'] = {};
    _storage['sampling'] = {};
    _storage['health'] = {};
    _storage['alerts'] = {};
    _storage['analysis'] = {};
    _storage['contexts'] = {};
  }

  @override
  Future<Trace> createTrace(String serviceName, DateTime startTime, {String parentTraceId = ''}) async {
    final trace = Trace(
      traceId: 'tr_${DateTime.now().millisecondsSinceEpoch}',
      parentTraceId: parentTraceId,
      serviceName: serviceName,
      startTime: startTime,
      status: TraceStatus.active,
      spanIds: [],
      tags: {},
    );
    _storage['traces']![trace.traceId] = _traceToMap(trace);
    return trace;
  }

  @override
  Future<Trace?> getTrace(String traceId) async {
    final data = _storage['traces']![traceId];
    return data != null ? _mapToTrace(data) : null;
  }

  @override
  Future<Trace> updateTraceStatus(String traceId, TraceStatus status, {String? errorMessage}) async {
    final data = _storage['traces']![traceId];
    if (data == null) throw Exception('Trace not found');
    data['status'] = status.toString().split('.').last;
    if (status == TraceStatus.completed || status == TraceStatus.failed) {
      data['endTime'] = DateTime.now().toIso8601String();
    }
    if (errorMessage != null) data['errorMessage'] = errorMessage;
    return _mapToTrace(data);
  }

  @override
  Future<void> deleteTrace(String traceId) async {
    _storage['traces']!.remove(traceId);
  }

  @override
  Future<List<Trace>> listTraces({int limit = 50}) async {
    return _storage['traces']!.values.map(_mapToTrace).toList().take(limit).toList();
  }

  @override
  Future<List<Trace>> getActiveTraces() async {
    return _storage['traces']!.values
        .where((t) => t['status'] == 'active' || t['status'] == 'started')
        .map(_mapToTrace)
        .toList();
  }

  @override
  Future<List<Trace>> getFailedTraces() async {
    return _storage['traces']!.values
        .where((t) => t['status'] == 'failed')
        .map(_mapToTrace)
        .toList();
  }

  @override
  Future<List<Trace>> getTracesByService(String serviceName) async {
    return _storage['traces']!.values
        .where((t) => t['serviceName'] == serviceName)
        .map(_mapToTrace)
        .toList();
  }

  @override
  Future<int> getTraceCount() async {
    return _storage['traces']!.length;
  }

  @override
  Future<List<Trace>> getTracesByFilter(ObservabilityFilter filter) async {
    var traces = _storage['traces']!.values.map(_mapToTrace).toList();
    if (filter.serviceName != null) {
      traces = traces.where((t) => t.serviceName == filter.serviceName).toList();
    }
    return traces;
  }

  @override
  Future<Span> createSpan(String traceId, String operationName, SpanKind kind, String parentSpanId) async {
    final span = Span(
      spanId: 'sp_${DateTime.now().millisecondsSinceEpoch}',
      traceId: traceId,
      parentSpanId: parentSpanId,
      operationName: operationName,
      kind: kind,
      startTime: DateTime.now(),
      attributes: {},
      eventIds: [],
    );
    _storage['spans']![span.spanId] = _spanToMap(span);
    return span;
  }

  @override
  Future<Span?> getSpan(String spanId) async {
    final data = _storage['spans']![spanId];
    return data != null ? _mapToSpan(data) : null;
  }

  @override
  Future<Span> completeSpan(String spanId, {String? errorMessage}) async {
    final data = _storage['spans']![spanId];
    if (data == null) throw Exception('Span not found');
    data['endTime'] = DateTime.now().toIso8601String();
    if (errorMessage != null) data['errorMessage'] = errorMessage;
    return _mapToSpan(data);
  }

  @override
  Future<void> deleteSpan(String spanId) async {
    _storage['spans']!.remove(spanId);
  }

  @override
  Future<List<Span>> getSpansByTrace(String traceId) async {
    return _storage['spans']!.values
        .where((s) => s['traceId'] == traceId)
        .map(_mapToSpan)
        .toList();
  }

  @override
  Future<List<Span>> getErrorSpans(String traceId) async {
    return _storage['spans']!.values
        .where((s) => s['traceId'] == traceId && s['errorMessage'] != null)
        .map(_mapToSpan)
        .toList();
  }

  @override
  Future<int> getSpanCount(String traceId) async {
    return _storage['spans']!.values.where((s) => s['traceId'] == traceId).length;
  }

  @override
  Future<List<Span>> getSlowSpans(String traceId, int thresholdMs) async {
    return _storage['spans']!.values
        .where((s) => s['traceId'] == traceId && s['endTime'] != null)
        .map(_mapToSpan)
        .toList();
  }

  @override
  Future<Metric> recordMetric(String serviceName, String metricName, MetricType type, double value, Map<String, String> labels) async {
    final metric = Metric(
      metricId: 'met_${DateTime.now().millisecondsSinceEpoch}',
      serviceName: serviceName,
      metricName: metricName,
      type: type,
      value: value,
      recordedAt: DateTime.now(),
      labels: labels,
    );
    _storage['metrics']![metric.metricId] = _metricToMap(metric);
    return metric;
  }

  @override
  Future<Metric?> getMetric(String metricId) async {
    final data = _storage['metrics']![metricId];
    return data != null ? _mapToMetric(data) : null;
  }

  @override
  Future<List<Metric>> getMetricsByService(String serviceName) async {
    return _storage['metrics']!.values
        .where((m) => m['serviceName'] == serviceName)
        .map(_mapToMetric)
        .toList();
  }

  @override
  Future<List<Metric>> getMetricsByName(String metricName) async {
    return _storage['metrics']!.values
        .where((m) => m['metricName'] == metricName)
        .map(_mapToMetric)
        .toList();
  }

  @override
  Future<List<Metric>> getRecentMetrics(int minutesBack) async {
    final since = DateTime.now().subtract(Duration(minutes: minutesBack));
    return _storage['metrics']!.values
        .where((m) => DateTime.parse(m['recordedAt']).isAfter(since))
        .map(_mapToMetric)
        .toList();
  }

  @override
  Future<double> getAverageMetricValue(String metricName) async {
    final metrics = _storage['metrics']!.values
        .where((m) => m['metricName'] == metricName)
        .toList();
    if (metrics.isEmpty) return 0.0;
    return metrics.fold(0.0, (sum, m) => sum + m['value']) / metrics.length;
  }

  @override
  Future<int> getMetricCount() async {
    return _storage['metrics']!.length;
  }

  @override
  Future<LogEntry> recordLog(String serviceName, LogLevel level, String message, String traceId, {String? spanId}) async {
    final log = LogEntry(
      logId: 'log_${DateTime.now().millisecondsSinceEpoch}',
      serviceName: serviceName,
      level: level,
      message: message,
      timestamp: DateTime.now(),
      traceId: traceId,
      spanId: spanId,
      context: {},
    );
    _storage['logs']![log.logId] = _logToMap(log);
    return log;
  }

  @override
  Future<LogEntry?> getLog(String logId) async {
    final data = _storage['logs']![logId];
    return data != null ? _mapToLog(data) : null;
  }

  @override
  Future<List<LogEntry>> getLogsByService(String serviceName) async {
    return _storage['logs']!.values
        .where((l) => l['serviceName'] == serviceName)
        .map(_mapToLog)
        .toList();
  }

  @override
  Future<List<LogEntry>> getLogsByLevel(LogLevel level) async {
    return _storage['logs']!.values
        .where((l) => l['level'] == level.toString().split('.').last)
        .map(_mapToLog)
        .toList();
  }

  @override
  Future<List<LogEntry>> getLogsByTraceId(String traceId) async {
    return _storage['logs']!.values
        .where((l) => l['traceId'] == traceId)
        .map(_mapToLog)
        .toList();
  }

  @override
  Future<List<LogEntry>> getErrorLogs(String serviceName) async {
    return _storage['logs']!.values
        .where((l) => l['serviceName'] == serviceName && (l['level'] == 'error' || l['level'] == 'fatal'))
        .map(_mapToLog)
        .toList();
  }

  @override
  Future<void> deleteLog(String logId) async {
    _storage['logs']!.remove(logId);
  }

  @override
  Future<int> getLogCount() async {
    return _storage['logs']!.length;
  }

  @override
  Future<Sampling> createSamplingConfig(String serviceName, SamplingStrategy strategy, double rate, int maxTraces) async {
    final sampling = Sampling(
      samplingId: 'samp_${DateTime.now().millisecondsSinceEpoch}',
      strategy: strategy,
      samplingRate: rate,
      maxTracesPerSecond: maxTraces,
      createdAt: DateTime.now(),
      serviceName: serviceName,
    );
    _storage['sampling']![sampling.samplingId] = _samplingToMap(sampling);
    return sampling;
  }

  @override
  Future<Sampling?> getSamplingConfig(String samplingId) async {
    final data = _storage['sampling']![samplingId];
    return data != null ? _mapToSampling(data) : null;
  }

  @override
  Future<List<Sampling>> getSamplingConfigsByService(String serviceName) async {
    return _storage['sampling']!.values
        .where((s) => s['serviceName'] == serviceName)
        .map(_mapToSampling)
        .toList();
  }

  @override
  Future<void> updateSamplingConfig(String samplingId, {double? rate, int? maxTraces}) async {
    final data = _storage['sampling']![samplingId];
    if (data != null) {
      if (rate != null) data['samplingRate'] = rate;
      if (maxTraces != null) data['maxTracesPerSecond'] = maxTraces;
    }
  }

  @override
  Future<void> disableSamplingConfig(String samplingId) async {
    final data = _storage['sampling']![samplingId];
    if (data != null) {
      data['isActive'] = false;
    }
  }

  @override
  Future<List<Sampling>> getActiveSamplingConfigs() async {
    return _storage['sampling']!.values
        .where((s) => s['isActive'] == true)
        .map(_mapToSampling)
        .toList();
  }

  @override
  Future<ServiceHealth> recordServiceHealth(String serviceName, double errorRate, double p99, double p95, int requests, int errors) async {
    final health = ServiceHealth(
      healthId: 'hlth_${DateTime.now().millisecondsSinceEpoch}',
      serviceName: serviceName,
      checkedAt: DateTime.now(),
      errorRate: errorRate,
      latencyP99: p99,
      latencyP95: p95,
      requestCount: requests,
      errorCount: errors,
      status: errorRate < 1.0 ? 'healthy' : 'degraded',
    );
    _storage['health']![health.healthId] = _healthToMap(health);
    return health;
  }

  @override
  Future<ServiceHealth?> getServiceHealth(String healthId) async {
    final data = _storage['health']![healthId];
    return data != null ? _mapToHealth(data) : null;
  }

  @override
  Future<ServiceHealth?> getLatestServiceHealth(String serviceName) async {
    final health = _storage['health']!.values
        .where((h) => h['serviceName'] == serviceName)
        .toList();
    return health.isNotEmpty ? _mapToHealth(health.last) : null;
  }

  @override
  Future<List<ServiceHealth>> getHealthByService(String serviceName) async {
    return _storage['health']!.values
        .where((h) => h['serviceName'] == serviceName)
        .map(_mapToHealth)
        .toList();
  }

  @override
  Future<List<ServiceHealth>> getUnhealthyServices() async {
    return _storage['health']!.values
        .where((h) => h['status'] != 'healthy')
        .map(_mapToHealth)
        .toList();
  }

  @override
  Future<int> getServiceHealthCount() async {
    return _storage['health']!.length;
  }

  @override
  Future<Alert> createAlert(String serviceName, String metricName, AlertSeverity severity, String description) async {
    final alert = Alert(
      alertId: 'alrt_${DateTime.now().millisecondsSinceEpoch}',
      serviceName: serviceName,
      metricName: metricName,
      severity: severity,
      description: description,
      triggeredAt: DateTime.now(),
    );
    _storage['alerts']![alert.alertId] = _alertToMap(alert);
    return alert;
  }

  @override
  Future<Alert?> getAlert(String alertId) async {
    final data = _storage['alerts']![alertId];
    return data != null ? _mapToAlert(data) : null;
  }

  @override
  Future<Alert> resolveAlert(String alertId, String? resolution) async {
    final data = _storage['alerts']![alertId];
    if (data == null) throw Exception('Alert not found');
    data['resolvedAt'] = DateTime.now().toIso8601String();
    data['isActive'] = false;
    if (resolution != null) data['resolution'] = resolution;
    return _mapToAlert(data);
  }

  @override
  Future<List<Alert>> getActiveAlerts() async {
    return _storage['alerts']!.values
        .where((a) => a['isActive'] == true)
        .map(_mapToAlert)
        .toList();
  }

  @override
  Future<List<Alert>> getAlertsByService(String serviceName) async {
    return _storage['alerts']!.values
        .where((a) => a['serviceName'] == serviceName)
        .map(_mapToAlert)
        .toList();
  }

  @override
  Future<List<Alert>> getAlertsBySeverity(AlertSeverity severity) async {
    return _storage['alerts']!.values
        .where((a) => a['severity'] == severity.toString().split('.').last)
        .map(_mapToAlert)
        .toList();
  }

  @override
  Future<int> getAlertCount() async {
    return _storage['alerts']!.length;
  }

  @override
  Future<TraceAnalysis> analyzeTrace(String traceId) async {
    final analysis = TraceAnalysis(
      analysisId: 'ana_${DateTime.now().millisecondsSinceEpoch}',
      traceId: traceId,
      analyzedAt: DateTime.now(),
      spanCount: 10,
      errorSpanCount: 0,
      criticalPath: 500.0,
      slowestSpans: [],
      errorSpans: [],
      spanDetailedLatency: 500.0,
    );
    _storage['analysis']![analysis.analysisId] = _analysisToMap(analysis);
    return analysis;
  }

  @override
  Future<TraceAnalysis?> getTraceAnalysis(String analysisId) async {
    final data = _storage['analysis']![analysisId];
    return data != null ? _mapToAnalysis(data) : null;
  }

  @override
  Future<List<TraceAnalysis>> getAnalysesWithErrors() async {
    return _storage['analysis']!.values
        .where((a) => a['errorSpanCount'] > 0)
        .map(_mapToAnalysis)
        .toList();
  }

  @override
  Future<List<TraceAnalysis>> getSlowTraceAnalyses(int thresholdMs) async {
    return _storage['analysis']!.values
        .where((a) => a['spanDetailedLatency'] > thresholdMs)
        .map(_mapToAnalysis)
        .toList();
  }

  @override
  Future<int> getAnalysisCount() async {
    return _storage['analysis']!.length;
  }

  @override
  Future<DistributedTraceContext> createTraceContext(String traceId, String spanId) async {
    final context = DistributedTraceContext(
      contextId: 'ctx_${DateTime.now().millisecondsSinceEpoch}',
      traceId: traceId,
      spanId: spanId,
      traceFlags: true,
      traceState: 'active',
      createdAt: DateTime.now(),
      baggage: {},
    );
    _storage['contexts']![context.contextId] = _contextToMap(context);
    return context;
  }

  @override
  Future<DistributedTraceContext?> getTraceContext(String contextId) async {
    final data = _storage['contexts']![contextId];
    return data != null ? _mapToContext(data) : null;
  }

  @override
  Future<List<DistributedTraceContext>> getContextsByTraceId(String traceId) async {
    return _storage['contexts']!.values
        .where((c) => c['traceId'] == traceId)
        .map(_mapToContext)
        .toList();
  }

  @override
  Future<int> getContextCount() async {
    return _storage['contexts']!.length;
  }

  @override
  Future<ObservabilityReport> generateReport(DateTime startDate, DateTime endDate) async {
    final traces = _storage['traces']!.values.toList();
    final failed = traces.where((t) => t['status'] == 'failed').length;
    
    return ObservabilityReport(
      reportId: 'rpt_${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      periodStart: startDate,
      periodEnd: endDate,
      totalTraces: traces.length,
      failedTraces: failed,
      averageLatency: 250.0,
      p99Latency: 1000.0,
      errorRate: failed > 0 ? (failed / traces.length) * 100 : 0.0,
      topServices: [],
    );
  }

  @override
  Future<Map<String, dynamic>> getObservabilityMetrics() async {
    return {
      'traces': _storage['traces']!.length,
      'spans': _storage['spans']!.length,
      'metrics': _storage['metrics']!.length,
      'logs': _storage['logs']!.length,
      'alerts': _storage['alerts']!.length,
    };
  }

  // Helper methods
  Map<String, dynamic> _traceToMap(Trace trace) => {
    'traceId': trace.traceId,
    'parentTraceId': trace.parentTraceId,
    'serviceName': trace.serviceName,
    'startTime': trace.startTime.toIso8601String(),
    'endTime': trace.endTime?.toIso8601String(),
    'status': trace.status.toString().split('.').last,
    'spanIds': trace.spanIds,
    'tags': trace.tags,
    'errorMessage': trace.errorMessage,
  };

  Trace _mapToTrace(Map<String, dynamic> map) => Trace(
    traceId: map['traceId'],
    parentTraceId: map['parentTraceId'],
    serviceName: map['serviceName'],
    startTime: DateTime.parse(map['startTime']),
    endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
    status: TraceStatus.values.byName(map['status']),
    spanIds: List<String>.from(map['spanIds']),
    tags: map['tags'],
    errorMessage: map['errorMessage'],
  );

  Map<String, dynamic> _spanToMap(Span span) => {
    'spanId': span.spanId,
    'traceId': span.traceId,
    'parentSpanId': span.parentSpanId,
    'operationName': span.operationName,
    'kind': span.kind.toString().split('.').last,
    'startTime': span.startTime.toIso8601String(),
    'endTime': span.endTime?.toIso8601String(),
    'attributes': span.attributes,
    'eventIds': span.eventIds,
    'errorMessage': span.errorMessage,
  };

  Span _mapToSpan(Map<String, dynamic> map) => Span(
    spanId: map['spanId'],
    traceId: map['traceId'],
    parentSpanId: map['parentSpanId'],
    operationName: map['operationName'],
    kind: SpanKind.values.byName(map['kind']),
    startTime: DateTime.parse(map['startTime']),
    endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
    attributes: map['attributes'],
    eventIds: List<String>.from(map['eventIds']),
    errorMessage: map['errorMessage'],
  );

  Map<String, dynamic> _metricToMap(Metric metric) => {
    'metricId': metric.metricId,
    'serviceName': metric.serviceName,
    'metricName': metric.metricName,
    'type': metric.type.toString().split('.').last,
    'value': metric.value,
    'recordedAt': metric.recordedAt.toIso8601String(),
    'labels': metric.labels,
  };

  Metric _mapToMetric(Map<String, dynamic> map) => Metric(
    metricId: map['metricId'],
    serviceName: map['serviceName'],
    metricName: map['metricName'],
    type: MetricType.values.byName(map['type']),
    value: map['value'],
    recordedAt: DateTime.parse(map['recordedAt']),
    labels: Map<String, String>.from(map['labels']),
  );

  Map<String, dynamic> _logToMap(LogEntry log) => {
    'logId': log.logId,
    'serviceName': log.serviceName,
    'level': log.level.toString().split('.').last,
    'message': log.message,
    'timestamp': log.timestamp.toIso8601String(),
    'traceId': log.traceId,
    'spanId': log.spanId,
    'context': log.context,
    'stackTrace': log.stackTrace,
  };

  LogEntry _mapToLog(Map<String, dynamic> map) => LogEntry(
    logId: map['logId'],
    serviceName: map['serviceName'],
    level: LogLevel.values.byName(map['level']),
    message: map['message'],
    timestamp: DateTime.parse(map['timestamp']),
    traceId: map['traceId'],
    spanId: map['spanId'],
    context: map['context'],
    stackTrace: map['stackTrace'],
  );

  Map<String, dynamic> _samplingToMap(Sampling sampling) => {
    'samplingId': sampling.samplingId,
    'strategy': sampling.strategy.toString().split('.').last,
    'samplingRate': sampling.samplingRate,
    'maxTracesPerSecond': sampling.maxTracesPerSecond,
    'createdAt': sampling.createdAt.toIso8601String(),
    'serviceName': sampling.serviceName,
    'isActive': sampling.isActive,
  };

  Sampling _mapToSampling(Map<String, dynamic> map) => Sampling(
    samplingId: map['samplingId'],
    strategy: SamplingStrategy.values.byName(map['strategy']),
    samplingRate: map['samplingRate'],
    maxTracesPerSecond: map['maxTracesPerSecond'],
    createdAt: DateTime.parse(map['createdAt']),
    serviceName: map['serviceName'],
    isActive: map['isActive'] ?? true,
  );

  Map<String, dynamic> _healthToMap(ServiceHealth health) => {
    'healthId': health.healthId,
    'serviceName': health.serviceName,
    'checkedAt': health.checkedAt.toIso8601String(),
    'errorRate': health.errorRate,
    'latencyP99': health.latencyP99,
    'latencyP95': health.latencyP95,
    'requestCount': health.requestCount,
    'errorCount': health.errorCount,
    'status': health.status,
  };

  ServiceHealth _mapToHealth(Map<String, dynamic> map) => ServiceHealth(
    healthId: map['healthId'],
    serviceName: map['serviceName'],
    checkedAt: DateTime.parse(map['checkedAt']),
    errorRate: map['errorRate'],
    latencyP99: map['latencyP99'],
    latencyP95: map['latencyP95'],
    requestCount: map['requestCount'],
    errorCount: map['errorCount'],
    status: map['status'],
  );

  Map<String, dynamic> _alertToMap(Alert alert) => {
    'alertId': alert.alertId,
    'serviceName': alert.serviceName,
    'metricName': alert.metricName,
    'severity': alert.severity.toString().split('.').last,
    'description': alert.description,
    'triggeredAt': alert.triggeredAt.toIso8601String(),
    'resolvedAt': alert.resolvedAt?.toIso8601String(),
    'isActive': alert.isActive,
    'resolution': alert.resolution,
  };

  Alert _mapToAlert(Map<String, dynamic> map) => Alert(
    alertId: map['alertId'],
    serviceName: map['serviceName'],
    metricName: map['metricName'],
    severity: AlertSeverity.values.byName(map['severity']),
    description: map['description'],
    triggeredAt: DateTime.parse(map['triggeredAt']),
    resolvedAt: map['resolvedAt'] != null ? DateTime.parse(map['resolvedAt']) : null,
    isActive: map['isActive'] ?? true,
    resolution: map['resolution'],
  );

  Map<String, dynamic> _analysisToMap(TraceAnalysis analysis) => {
    'analysisId': analysis.analysisId,
    'traceId': analysis.traceId,
    'analyzedAt': analysis.analyzedAt.toIso8601String(),
    'spanCount': analysis.spanCount,
    'errorSpanCount': analysis.errorSpanCount,
    'criticalPath': analysis.criticalPath,
    'slowestSpans': analysis.slowestSpans,
    'errorSpans': analysis.errorSpans,
    'spanDetailedLatency': analysis.spanDetailedLatency,
  };

  TraceAnalysis _mapToAnalysis(Map<String, dynamic> map) => TraceAnalysis(
    analysisId: map['analysisId'],
    traceId: map['traceId'],
    analyzedAt: DateTime.parse(map['analyzedAt']),
    spanCount: map['spanCount'],
    errorSpanCount: map['errorSpanCount'],
    criticalPath: map['criticalPath'],
    slowestSpans: List<String>.from(map['slowestSpans']),
    errorSpans: List<String>.from(map['errorSpans']),
    spanDetailedLatency: map['spanDetailedLatency'],
  );

  Map<String, dynamic> _contextToMap(DistributedTraceContext context) => {
    'contextId': context.contextId,
    'traceId': context.traceId,
    'spanId': context.spanId,
    'traceFlags': context.traceFlags,
    'traceState': context.traceState,
    'createdAt': context.createdAt.toIso8601String(),
    'baggage': context.baggage,
  };

  DistributedTraceContext _mapToContext(Map<String, dynamic> map) => DistributedTraceContext(
    contextId: map['contextId'],
    traceId: map['traceId'],
    spanId: map['spanId'],
    traceFlags: map['traceFlags'],
    traceState: map['traceState'],
    createdAt: DateTime.parse(map['createdAt']),
    baggage: Map<String, String>.from(map['baggage']),
  );
}

// Engines and Facade follow the established pattern
class TraceCollectionEngine {
  Future<Trace> startTrace(String serviceName) async {
    return Trace(
      traceId: 'tr_${DateTime.now().millisecondsSinceEpoch}',
      parentTraceId: '',
      serviceName: serviceName,
      startTime: DateTime.now(),
      status: TraceStatus.started,
      spanIds: [],
      tags: {},
    );
  }
}

class MetricsAggregationEngine {
  Future<Map<String, double>> aggregateMetrics(List<Metric> metrics) async {
    final byName = <String, List<double>>{};
    for (final metric in metrics) {
      byName.putIfAbsent(metric.metricName, () => []).add(metric.value);
    }
    return byName.map((k, v) => MapEntry(k, v.fold(0.0, (a, b) => a + b) / v.length));
  }
}

class ServiceHealthEngine {
  Future<ServiceHealth> assessHealth(String serviceName, int errors, int total) async {
    final errorRate = total > 0 ? (errors / total) * 100 : 0.0;
    return ServiceHealth(
      healthId: 'hlth_${DateTime.now().millisecondsSinceEpoch}',
      serviceName: serviceName,
      checkedAt: DateTime.now(),
      errorRate: errorRate,
      latencyP99: 1000.0,
      latencyP95: 500.0,
      requestCount: total,
      errorCount: errors,
      status: errorRate < 1.0 ? 'healthy' : 'degraded',
    );
  }
}

class AlertingEngine {
  Future<Alert> evaluateAlert(String serviceName, String metricName, double value, double threshold) async {
    return Alert(
      alertId: 'alrt_${DateTime.now().millisecondsSinceEpoch}',
      serviceName: serviceName,
      metricName: metricName,
      severity: value > threshold ? AlertSeverity.high : AlertSeverity.low,
      description: 'Metric $metricName = $value',
      triggeredAt: DateTime.now(),
    );
  }
}

class ContextPropagationEngine {
  Future<DistributedTraceContext> propagateContext(String traceId, String spanId) async {
    return DistributedTraceContext(
      contextId: 'ctx_${DateTime.now().millisecondsSinceEpoch}',
      traceId: traceId,
      spanId: spanId,
      traceFlags: true,
      traceState: 'active',
      createdAt: DateTime.now(),
      baggage: {},
    );
  }
}

class ObservabilityManager {
  final ObservabilityRepository repository;
  final TraceCollectionEngine traceEngine;
  final MetricsAggregationEngine metricsEngine;
  final ServiceHealthEngine healthEngine;
  final AlertingEngine alertingEngine;
  final ContextPropagationEngine contextEngine;

  ObservabilityManager({
    required this.repository,
    required this.traceEngine,
    required this.metricsEngine,
    required this.healthEngine,
    required this.alertingEngine,
    required this.contextEngine,
  });
}

class ObservabilityFacade {
  final ObservabilityRepository repository;
  final ObservabilityManager manager;

  ObservabilityFacade({required this.repository, required this.manager});

  Future<Trace> startTrace(String serviceName) => repository.createTrace(serviceName, DateTime.now());
  Future<List<Trace>> getTraces() => repository.listTraces();
  Future<Trace?> getTrace(String traceId) => repository.getTrace(traceId);
  Future<ObservabilityReport> generateReport(DateTime start, DateTime end) => repository.generateReport(start, end);
}
