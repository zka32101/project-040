/// Phase 42: Observability & Tracing 監視可能性モデル定義
///
/// 分散トレーシング、スパン、メトリクス、ログ

/// スパンの種類
enum SpanKind {
  internal('internal'),     // 内部処理
  server('server'),         // サーバー処理
  client('client'),         // クライアント処理
  producer('producer'),     // プロデューサー
  consumer('consumer');     // コンシューマー

  final String value;
  const SpanKind(this.value);
}

/// スパンの状態
enum SpanStatus {
  unset('unset'),           // 未設定
  ok('ok'),                 // 成功
  error('error'),           // エラー
  cancelled('cancelled');   // キャンセル

  final String value;
  const SpanStatus(this.value);
}

/// ログレベル
enum LogLevel {
  debug('debug'),
  info('info'),
  warning('warning'),
  error('error'),
  fatal('fatal');

  final String value;
  const LogLevel(this.value);
}

/// メトリクスタイプ
enum MetricType {
  counter('counter'),           // カウンター
  gauge('gauge'),               // ゲージ
  histogram('histogram'),       // ヒストグラム
  summary('summary');           // サマリー

  final String value;
  const MetricType(this.value);
}

/// サンプリングタイプ
enum SamplingType {
  always('always'),             // 常にサンプリング
  never('never'),               // サンプリングしない
  probabilistic('probabilistic'); // 確率的サンプリング

  final String value;
  const SamplingType(this.value);
}

/// トレースコンテキスト
class TraceContext {
  final String traceId;
  final String spanId;
  final String? parentSpanId;
  final Map<String, String> traceState;
  final DateTime createdAt;

  TraceContext({
    required this.traceId,
    required this.spanId,
    this.parentSpanId,
    Map<String, String>? traceState,
    required this.createdAt,
  }) : traceState = traceState ?? {};

  /// 親スパンIDを設定した新しいコンテキストを作成
  TraceContext withParentSpan(String parentId) {
    return TraceContext(
      traceId: traceId,
      spanId: 'span:${DateTime.now().millisecondsSinceEpoch}',
      parentSpanId: parentId,
      traceState: Map.from(traceState),
      createdAt: DateTime.now(),
    );
  }
}

/// スパンイベント
class SpanEvent {
  final String name;
  final DateTime timestamp;
  final Map<String, dynamic>? attributes;

  SpanEvent({
    required this.name,
    required this.timestamp,
    this.attributes,
  });
}

/// スパン
class Span {
  final String spanId;
  final String traceId;
  final String? parentSpanId;
  final String name;
  final SpanKind kind;
  final DateTime startTime;
  DateTime? endTime;
  final Map<String, dynamic> attributes;
  final List<SpanEvent> events;
  SpanStatus status;
  String? errorMessage;

  Span({
    required this.spanId,
    required this.traceId,
    this.parentSpanId,
    required this.name,
    required this.kind,
    required this.startTime,
    this.endTime,
    Map<String, dynamic>? attributes,
    List<SpanEvent>? events,
    this.status = SpanStatus.unset,
    this.errorMessage,
  })  : attributes = attributes ?? {},
        events = events ?? [];

  /// スパンの経過時間 (ミリ秒)
  int get durationMs {
    if (endTime == null) {
      return DateTime.now().difference(startTime).inMilliseconds;
    }
    return endTime!.difference(startTime).inMilliseconds;
  }

  /// アトリビュート追加
  void addAttribute(String key, dynamic value) {
    attributes[key] = value;
  }

  /// イベント追加
  void addEvent(SpanEvent event) {
    events.add(event);
  }

  /// スパンを終了
  void end({SpanStatus? status, String? errorMsg}) {
    endTime = DateTime.now();
    if (status != null) {
      this.status = status;
    }
    if (errorMsg != null) {
      errorMessage = errorMsg;
    }
  }

  /// エラースパンか
  bool get isError => status == SpanStatus.error || errorMessage != null;
}

/// トレース
class Trace {
  final String traceId;
  final String rootSpanId;
  final List<Span> spans;
  final DateTime startTime;
  final DateTime? endTime;
  final String? serviceName;
  final Map<String, dynamic>? metadata;

  Trace({
    required this.traceId,
    required this.rootSpanId,
    required this.spans,
    required this.startTime,
    this.endTime,
    this.serviceName,
    this.metadata,
  });

  /// トレースの経過時間 (ミリ秒)
  int get durationMs {
    if (endTime == null) {
      return DateTime.now().difference(startTime).inMilliseconds;
    }
    return endTime!.difference(startTime).inMilliseconds;
  }

  /// スパン数
  int get spanCount => spans.length;

  /// エラースパン数
  int get errorSpanCount => spans.where((s) => s.isError).length;
}

/// メトリクス
class Metric {
  final String metricId;
  final String name;
  final MetricType type;
  final String? unit;
  final double value;
  final DateTime timestamp;
  final Map<String, dynamic>? attributes;

  Metric({
    required this.metricId,
    required this.name,
    required this.type,
    this.unit,
    required this.value,
    required this.timestamp,
    this.attributes,
  });
}

/// トレースメトリクス
class TraceMetrics {
  final String metricsId;
  final String traceId;
  final int totalSpans;
  final int errorSpans;
  final double averageLatencyMs;
  final String? slowestSpan;
  final int? slowestSpanDurationMs;
  final DateTime createdAt;

  TraceMetrics({
    required this.metricsId,
    required this.traceId,
    required this.totalSpans,
    required this.errorSpans,
    required this.averageLatencyMs,
    this.slowestSpan,
    this.slowestSpanDurationMs,
    required this.createdAt,
  });

  /// エラー率
  double get errorRate {
    return totalSpans > 0 ? errorSpans / totalSpans : 0.0;
  }

  /// エラー率パーセント
  int get errorRatePercentage => (errorRate * 100).toInt();
}

/// 構造化ログ
class ObservabilityLog {
  final String logId;
  final String traceId;
  final String? spanId;
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? attributes;

  ObservabilityLog({
    required this.logId,
    required this.traceId,
    this.spanId,
    required this.level,
    required this.message,
    required this.timestamp,
    this.attributes,
  });
}

/// サンプリングポリシー
class SamplingPolicy {
  final String policyId;
  final SamplingType type;
  final double probability;
  final DateTime createdAt;

  SamplingPolicy({
    required this.policyId,
    required this.type,
    required this.probability,
    required this.createdAt,
  });

  /// サンプリング対象か判定
  bool shouldSample() {
    switch (type) {
      case SamplingType.always:
        return true;
      case SamplingType.never:
        return false;
      case SamplingType.probabilistic:
        return (DateTime.now().millisecondsSinceEpoch % 1000) / 1000 < probability;
    }
  }
}

/// トレース収集統計
class TraceCollector {
  final String collectorId;
  final int totalTraces;
  final int totalSpans;
  final double averageSpansPerTrace;
  final double averageLatencyMs;
  final DateTime createdAt;
  final DateTime measuredAt;

  TraceCollector({
    required this.collectorId,
    required this.totalTraces,
    required this.totalSpans,
    required this.averageSpansPerTrace,
    required this.averageLatencyMs,
    required this.createdAt,
    required this.measuredAt,
  });
}

/// 監視可能性レポート
class ObservabilityReport {
  final String reportId;
  final DateTime generatedAt;
  final List<TraceMetrics> traceMetrics;
  final List<Metric> metrics;
  final int totalTraces;
  final int totalErrors;
  final double systemHealthScore;

  ObservabilityReport({
    required this.reportId,
    required this.generatedAt,
    required this.traceMetrics,
    required this.metrics,
    required this.totalTraces,
    required this.totalErrors,
    required this.systemHealthScore,
  });

  /// Markdown形式でレポートを生成
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Observability Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');
    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Total Traces: $totalTraces');
    buffer.writeln('- Total Errors: $totalErrors');
    buffer.writeln('- Error Rate: ${(totalErrors / (totalTraces > 0 ? totalTraces : 1) * 100).toStringAsFixed(2)}%');
    buffer.writeln('- System Health Score: ${(systemHealthScore * 100).toStringAsFixed(2)}/100');
    buffer.writeln('');

    if (traceMetrics.isNotEmpty) {
      buffer.writeln('## Trace Metrics');
      buffer.writeln('');
      final avgLatency = traceMetrics.isEmpty
          ? 0.0
          : traceMetrics.map((m) => m.averageLatencyMs).reduce((a, b) => a + b) / traceMetrics.length;
      buffer.writeln('- Average Latency: ${avgLatency.toStringAsFixed(2)}ms');
      buffer.writeln('- Traces Analyzed: ${traceMetrics.length}');
      buffer.writeln('');
    }

    return buffer.toString();
  }
}
