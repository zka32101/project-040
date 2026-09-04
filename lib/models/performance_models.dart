/// Phase 53: Performance Monitoring & Optimization パフォーマンス監視・最適化
///
/// パフォーマンスメトリクス、キャッシング、最適化、分析機能

/// パフォーマンスメトリクス種別
enum PerformanceMetricType {
  cpuUsage('cpu_usage'),
  memoryUsage('memory_usage'),
  responseTime('response_time'),
  throughput('throughput'),
  latency('latency'),
  errorRate('error_rate'),
  cacheHitRate('cache_hit_rate'),
  diskUsage('disk_usage');

  final String value;
  const PerformanceMetricType(this.value);
}

/// キャッシング戦略
enum CacheStrategy {
  lru('lru'),
  lfu('lfu'),
  fifo('fifo'),
  ttl('ttl');

  final String value;
  const CacheStrategy(this.value);
}

/// 最適化レベル
enum OptimizationLevel {
  low('low'),
  medium('medium'),
  high('high'),
  aggressive('aggressive');

  final String value;
  const OptimizationLevel(this.value);
}

/// パフォーマンスデータ
class PerformanceData {
  final String metricId;
  final PerformanceMetricType metricType;
  final double value;
  final DateTime recordedAt;
  final Map<String, dynamic>? metadata;
  final bool isAnomalous;

  PerformanceData({
    required this.metricId,
    required this.metricType,
    required this.value,
    required this.recordedAt,
    this.metadata,
    this.isAnomalous = false,
  });

  /// 値が正常範囲か
  bool get isNormal => !isAnomalous;

  /// メトリクスが高いか（CPU使用率、遅延など）
  bool get isHigh => value > 80.0;

  /// メトリクスが低いか（キャッシュヒット率など）
  bool get isLow => value < 20.0;
}

/// キャッシュエントリ
class CacheEntry {
  final String entryId;
  final String key;
  final dynamic value;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int accessCount;
  final CacheStrategy strategy;
  final int? sizeByte;

  CacheEntry({
    required this.entryId,
    required this.key,
    required this.value,
    required this.createdAt,
    this.expiresAt,
    this.accessCount = 0,
    required this.strategy,
    this.sizeByte,
  });

  /// キャッシュが有効か
  bool get isValid => expiresAt == null || DateTime.now().isBefore(expiresAt!);

  /// キャッシュが期限切れか
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// 有効期限までの時間
  Duration? get timeUntilExpiration {
    if (expiresAt == null || isExpired) return null;
    return expiresAt!.difference(DateTime.now());
  }

  /// アクセス頻度
  int get frequency => accessCount;
}

/// 最適化レコメンデーション
class OptimizationRecommendation {
  final String recommendationId;
  final String title;
  final String description;
  final OptimizationLevel level;
  final double estimatedImprovement; // パーセント
  final String? implementation;
  final DateTime createdAt;
  final bool isApplied;

  OptimizationRecommendation({
    required this.recommendationId,
    required this.title,
    required this.description,
    required this.level,
    required this.estimatedImprovement,
    this.implementation,
    required this.createdAt,
    this.isApplied = false,
  });

  /// 推奨が有効か
  bool get isValid => estimatedImprovement > 0;

  /// 推奨がハイインパクトか
  bool get isHighImpact => estimatedImprovement > 20.0;
}

/// パフォーマンス分析
class PerformanceAnalysis {
  final String analysisId;
  final List<PerformanceData> dataPoints;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double averageValue;
  final double peakValue;
  final double minValue;
  final double standardDeviation;

  PerformanceAnalysis({
    required this.analysisId,
    required this.dataPoints,
    required this.periodStart,
    required this.periodEnd,
    required this.averageValue,
    required this.peakValue,
    required this.minValue,
    required this.standardDeviation,
  });

  /// 変動が大きいか
  bool get hasHighVariance => standardDeviation > averageValue * 0.3;

  /// パフォーマンストレンド（改善中か悪化中か）
  double get trend {
    if (dataPoints.length < 2) return 0.0;
    final firstHalf = dataPoints.sublist(0, dataPoints.length ~/ 2);
    final secondHalf = dataPoints.sublist(dataPoints.length ~/ 2);
    final firstAvg = firstHalf.fold<double>(0, (s, d) => s + d.value) / firstHalf.length;
    final secondAvg = secondHalf.fold<double>(0, (s, d) => s + d.value) / secondHalf.length;
    return secondAvg - firstAvg;
  }

  /// データポイント数
  int get dataPointCount => dataPoints.length;
}

/// ボトルネック分析
class BottleneckAnalysis {
  final String bottleneckId;
  final String resourceName;
  final PerformanceMetricType metricType;
  final double severity; // 0.0-1.0
  final String description;
  final DateTime detectedAt;
  final List<OptimizationRecommendation> recommendations;

  BottleneckAnalysis({
    required this.bottleneckId,
    required this.resourceName,
    required this.metricType,
    required this.severity,
    required this.description,
    required this.detectedAt,
    required this.recommendations,
  });

  /// ボトルネックが深刻か
  bool get isCritical => severity > 0.8;

  /// ボトルネックが警告レベルか
  bool get isWarning => severity > 0.5 && severity <= 0.8;

  /// 推奨アクション数
  int get recommendationCount => recommendations.length;
}

/// パフォーマンス統計
class PerformanceStats {
  final String statsId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<PerformanceMetricType, double> averageMetrics;
  final Map<PerformanceMetricType, double> peakMetrics;
  final double overallHealthScore; // 0.0-1.0
  final int totalAnomalies;
  final double cacheHitRate;

  PerformanceStats({
    required this.statsId,
    required this.periodStart,
    required this.periodEnd,
    required this.averageMetrics,
    required this.peakMetrics,
    required this.overallHealthScore,
    required this.totalAnomalies,
    required this.cacheHitRate,
  });

  /// ヘルススコアが良好か
  bool get isHealthy => overallHealthScore > 0.8;

  /// パフォーマンスが低下しているか
  bool get isDegraded => overallHealthScore < 0.6;

  /// キャッシュ効率が良いか
  bool get hasGoodCacheEfficiency => cacheHitRate > 0.7;
}

/// パフォーマンスレポート
class PerformanceReport {
  final String reportId;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final PerformanceStats stats;
  final List<BottleneckAnalysis> bottlenecks;
  final List<OptimizationRecommendation> recommendations;
  final Map<String, dynamic>? insights;

  PerformanceReport({
    required this.reportId,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.stats,
    required this.bottlenecks,
    required this.recommendations,
    this.insights,
  });

  /// Markdown形式で出力
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Performance Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');

    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Health Score: ${(stats.overallHealthScore * 100).toStringAsFixed(1)}%');
    buffer.writeln('- Cache Hit Rate: ${(stats.cacheHitRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('- Anomalies Detected: ${stats.totalAnomalies}');
    buffer.writeln('- Bottlenecks Found: ${bottlenecks.length}');
    buffer.writeln('');

    if (bottlenecks.isNotEmpty) {
      buffer.writeln('## Critical Bottlenecks');
      buffer.writeln('');
      for (final bn in bottlenecks.take(5)) {
        buffer.writeln('- **${bn.resourceName}**: ${(bn.severity * 100).toStringAsFixed(0)}% severity');
        buffer.writeln('  - ${bn.description}');
      }
      buffer.writeln('');
    }

    if (recommendations.isNotEmpty) {
      buffer.writeln('## Top Recommendations');
      buffer.writeln('');
      for (final rec in recommendations.take(5)) {
        buffer.writeln('- **${rec.title}** (+${rec.estimatedImprovement.toStringAsFixed(1)}%)');
        buffer.writeln('  - ${rec.description}');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}

/// キャッシュ統計
class CacheStats {
  final String statsId;
  final int totalEntries;
  final int validEntries;
  final int expiredEntries;
  final int hits;
  final int misses;
  final int totalSizeBytes;
  final DateTime createdAt;

  CacheStats({
    required this.statsId,
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
    required this.hits,
    required this.misses,
    required this.totalSizeBytes,
    required this.createdAt,
  });

  /// キャッシュヒット率
  double get hitRate {
    if (hits + misses == 0) return 0.0;
    return hits / (hits + misses);
  }

  /// アクティブなエントリ数
  int get activeEntries => validEntries;

  /// キャッシュ効率
  double get efficiency => (totalEntries > 0) ? validEntries / totalEntries : 0.0;
}

/// リソース使用率
class ResourceUsage {
  final String resourceId;
  final String resourceType; // cpu, memory, disk, network
  final double usagePercent; // 0.0-100.0
  final double peakPercent;
  final double averagePercent;
  final DateTime measurementTime;
  final Duration duration;

  ResourceUsage({
    required this.resourceId,
    required this.resourceType,
    required this.usagePercent,
    required this.peakPercent,
    required this.averagePercent,
    required this.measurementTime,
    required this.duration,
  });

  /// リソース使用率が高いか
  bool get isHighUsage => usagePercent > 80.0;

  /// リソース使用率が低いか
  bool get isLowUsage => usagePercent < 20.0;

  /// リソースが効率的に使用されているか
  bool get isEfficient => averagePercent < 60.0;
}
