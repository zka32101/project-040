/// Observability & Tracing Models

enum TraceStatus { started, active, completed, failed, cancelled, timeout }
enum SpanKind { internal, server, client, producer, consumer }
enum MetricType { gauge, counter, histogram, summary }
enum LogLevel { trace, debug, info, warn, error, fatal }
enum SamplingStrategy { always, never, probabilistic, adaptive, rateLimit }
enum AlertSeverity { critical, high, medium, low, info }

class Trace {
  final String traceId;
  final String parentTraceId;
  final String serviceName;
  final DateTime startTime;
  final DateTime? endTime;
  final TraceStatus status;
  final List<String> spanIds;
  final Map<String, dynamic> tags;
  final String? errorMessage;

  Trace({
    required this.traceId,
    required this.parentTraceId,
    required this.serviceName,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.spanIds,
    required this.tags,
    this.errorMessage,
  });

  bool get isActive => status == TraceStatus.active || status == TraceStatus.started;
  bool get isCompleted => status == TraceStatus.completed;
  bool get isFailed => status == TraceStatus.failed;
  int get durationMs => endTime != null ? endTime!.difference(startTime).inMilliseconds : -1;
  int get spanCount => spanIds.length;
}

class Span {
  final String spanId;
  final String traceId;
  final String parentSpanId;
  final String operationName;
  final SpanKind kind;
  final DateTime startTime;
  final DateTime? endTime;
  final Map<String, dynamic> attributes;
  final List<String> eventIds;
  final String? errorMessage;

  Span({
    required this.spanId,
    required this.traceId,
    required this.parentSpanId,
    required this.operationName,
    required this.kind,
    required this.startTime,
    this.endTime,
    required this.attributes,
    required this.eventIds,
    this.errorMessage,
  });

  bool get isCompleted => endTime != null;
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  int get durationMs => endTime != null ? endTime!.difference(startTime).inMilliseconds : -1;
  int get eventCount => eventIds.length;
}

class Metric {
  final String metricId;
  final String serviceName;
  final String metricName;
  final MetricType type;
  final double value;
  final DateTime recordedAt;
  final Map<String, String> labels;
  final int unit;

  Metric({
    required this.metricId,
    required this.serviceName,
    required this.metricName,
    required this.type,
    required this.value,
    required this.recordedAt,
    required this.labels,
    this.unit = 1,
  });

  bool get isRecent => DateTime.now().difference(recordedAt).inMinutes < 5;
  int get ageInMinutes => DateTime.now().difference(recordedAt).inMinutes;
}

class LogEntry {
  final String logId;
  final String serviceName;
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final String traceId;
  final String? spanId;
  final Map<String, dynamic> context;
  final String? stackTrace;

  LogEntry({
    required this.logId,
    required this.serviceName,
    required this.level,
    required this.message,
    required this.timestamp,
    required this.traceId,
    this.spanId,
    required this.context,
    this.stackTrace,
  });

  bool get isError => level == LogLevel.error || level == LogLevel.fatal;
  bool get isWarning => level == LogLevel.warn;
  int get ageInMinutes => DateTime.now().difference(timestamp).inMinutes;
}

class Sampling {
  final String samplingId;
  final SamplingStrategy strategy;
  final double samplingRate;
  final int maxTracesPerSecond;
  final DateTime createdAt;
  final String serviceName;
  final bool isActive;

  Sampling({
    required this.samplingId,
    required this.strategy,
    required this.samplingRate,
    required this.maxTracesPerSecond,
    required this.createdAt,
    required this.serviceName,
    this.isActive = true,
  });

  bool get isProbabilistic => strategy == SamplingStrategy.probabilistic;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class ServiceHealth {
  final String healthId;
  final String serviceName;
  final DateTime checkedAt;
  final double errorRate;
  final double latencyP99;
  final double latencyP95;
  final int requestCount;
  final int errorCount;
  final String status;

  ServiceHealth({
    required this.healthId,
    required this.serviceName,
    required this.checkedAt,
    required this.errorRate,
    required this.latencyP99,
    required this.latencyP95,
    required this.requestCount,
    required this.errorCount,
    required this.status,
  });

  bool get isHealthy => errorRate < 1.0 && latencyP99 < 5000;
  bool get isDegraded => errorRate < 5.0 && latencyP99 < 10000;
  bool get isUnhealthy => errorRate >= 5.0 || latencyP99 >= 10000;
  int get ageInMinutes => DateTime.now().difference(checkedAt).inMinutes;
}

class Alert {
  final String alertId;
  final String serviceName;
  final String metricName;
  final AlertSeverity severity;
  final String description;
  final DateTime triggeredAt;
  final DateTime? resolvedAt;
  final bool isActive;
  final String? resolution;

  Alert({
    required this.alertId,
    required this.serviceName,
    required this.metricName,
    required this.severity,
    required this.description,
    required this.triggeredAt,
    this.resolvedAt,
    this.isActive = true,
    this.resolution,
  });

  bool get isResolved => resolvedAt != null;
  int get durationMinutes => resolvedAt != null
      ? resolvedAt!.difference(triggeredAt).inMinutes
      : DateTime.now().difference(triggeredAt).inMinutes;
}

class TraceAnalysis {
  final String analysisId;
  final String traceId;
  final DateTime analyzedAt;
  final int spanCount;
  final int errorSpanCount;
  final double criticalPath;
  final List<String> slowestSpans;
  final List<String> errorSpans;
  final double spanDetailedLatency;

  TraceAnalysis({
    required this.analysisId,
    required this.traceId,
    required this.analyzedAt,
    required this.spanCount,
    required this.errorSpanCount,
    required this.criticalPath,
    required this.slowestSpans,
    required this.errorSpans,
    required this.spanDetailedLatency,
  });

  double get errorRate => spanCount > 0 ? (errorSpanCount / spanCount) * 100 : 0.0;
  bool get hasErrors => errorSpanCount > 0;
  int get ageInMinutes => DateTime.now().difference(analyzedAt).inMinutes;
}

class DistributedTraceContext {
  final String contextId;
  final String traceId;
  final String spanId;
  final bool traceFlags;
  final String traceState;
  final DateTime createdAt;
  final Map<String, String> baggage;

  DistributedTraceContext({
    required this.contextId,
    required this.traceId,
    required this.spanId,
    required this.traceFlags,
    required this.traceState,
    required this.createdAt,
    required this.baggage,
  });

  int get ageInSeconds => DateTime.now().difference(createdAt).inSeconds;
}

class ObservabilityReport {
  final String reportId;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalTraces;
  final int failedTraces;
  final double averageLatency;
  final double p99Latency;
  final double errorRate;
  final List<String> topServices;

  ObservabilityReport({
    required this.reportId,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.totalTraces,
    required this.failedTraces,
    required this.averageLatency,
    required this.p99Latency,
    required this.errorRate,
    required this.topServices,
  });

  double get successRate => totalTraces > 0 ? ((totalTraces - failedTraces) / totalTraces) * 100 : 0.0;
  int get periodInDays => periodEnd.difference(periodStart).inDays;
}

class ObservabilityFilter {
  final String filterId;
  final String filterName;
  final String? serviceName;
  final LogLevel? minLogLevel;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isActive;

  ObservabilityFilter({
    required this.filterId,
    required this.filterName,
    this.serviceName,
    this.minLogLevel,
    this.startTime,
    this.endTime,
    this.isActive = true,
  });

  bool get hasFilters => serviceName != null || minLogLevel != null || startTime != null || endTime != null;
  int get activeFilterCount =>
      (serviceName != null ? 1 : 0) +
      (minLogLevel != null ? 1 : 0) +
      (startTime != null ? 1 : 0) +
      (endTime != null ? 1 : 0);
}
