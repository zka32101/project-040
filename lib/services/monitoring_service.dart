/// Phase 33: 監視・ロギング・メトリクス
import 'dart:async';

enum LogLevel { debug, info, warn, error, fatal }

class LogEntry {
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? context;
  final StackTrace? stackTrace;

  LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    this.context,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() => {
    'level': level.toString(),
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'context': context,
  };
}

class MetricPoint {
  final String name;
  final num value;
  final DateTime timestamp;
  final Map<String, dynamic>? tags;

  MetricPoint({
    required this.name,
    required this.value,
    required this.timestamp,
    this.tags,
  });
}

abstract class Logger {
  void debug(String message, {Map<String, dynamic>? context});
  void info(String message, {Map<String, dynamic>? context});
  void warn(String message, {Map<String, dynamic>? context});
  void error(String message, Object error, StackTrace stackTrace, {Map<String, dynamic>? context});
  void fatal(String message, Object error, StackTrace stackTrace);
  Stream<LogEntry> get logStream;
}

abstract class MetricsCollector {
  void recordMetric(String name, num value, {Map<String, dynamic>? tags});
  Future<List<MetricPoint>> getMetrics(String name, {Duration? duration});
  Future<Map<String, dynamic>> getSummary();
}

abstract class ErrorTracker {
  Future<void> captureException(Object error, StackTrace stackTrace, {Map<String, dynamic>? context});
  Future<List<dynamic>> getErrors({DateTime? since});
  Future<void> clearErrors();
}

class MemoryLogger implements Logger {
  final _controller = StreamController<LogEntry>.broadcast();
  final List<LogEntry> _logs = [];

  @override
  void debug(String message, {Map<String, dynamic>? context}) =>
    _log(LogLevel.debug, message, context: context);

  @override
  void info(String message, {Map<String, dynamic>? context}) =>
    _log(LogLevel.info, message, context: context);

  @override
  void warn(String message, {Map<String, dynamic>? context}) =>
    _log(LogLevel.warn, message, context: context);

  @override
  void error(String message, Object error, StackTrace stackTrace, {Map<String, dynamic>? context}) =>
    _log(LogLevel.error, message, context: context, stackTrace: stackTrace);

  @override
  void fatal(String message, Object error, StackTrace stackTrace) =>
    _log(LogLevel.fatal, message, stackTrace: stackTrace);

  @override
  Stream<LogEntry> get logStream => _controller.stream;

  void _log(LogLevel level, String message, {Map<String, dynamic>? context, StackTrace? stackTrace}) {
    final entry = LogEntry(
      level: level,
      message: message,
      timestamp: DateTime.now(),
      context: context,
      stackTrace: stackTrace,
    );
    _logs.add(entry);
    _controller.add(entry);
  }
}

class MemoryMetricsCollector implements MetricsCollector {
  final List<MetricPoint> _metrics = [];

  @override
  void recordMetric(String name, num value, {Map<String, dynamic>? tags}) {
    _metrics.add(MetricPoint(
      name: name,
      value: value,
      timestamp: DateTime.now(),
      tags: tags,
    ));
  }

  @override
  Future<List<MetricPoint>> getMetrics(String name, {Duration? duration}) async {
    var filtered = _metrics.where((m) => m.name == name).toList();
    if (duration != null) {
      final cutoff = DateTime.now().subtract(duration);
      filtered = filtered.where((m) => m.timestamp.isAfter(cutoff)).toList();
    }
    return filtered;
  }

  @override
  Future<Map<String, dynamic>> getSummary() async {
    final summary = <String, dynamic>{};
    for (final metric in _metrics) {
      summary[metric.name] ??= [];
      summary[metric.name].add(metric.value);
    }
    return summary;
  }
}
