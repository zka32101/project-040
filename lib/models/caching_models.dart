/// Phase 87: Advanced Caching & Performance Optimization
/// Core domain models for caching and performance optimization
library caching_models;

// ============================================================================
// ENUMS (6 total)
// ============================================================================

enum CacheType {
  inmemory('インメモリ'),
  distributed('分散'),
  persistent('永続'),
  hybrid('ハイブリッド'),
  local('ローカル'),
  remote('リモート');

  const CacheType(this.displayName);
  final String displayName;
}

enum CacheEvictionPolicy {
  lru('最近最少使用'),
  lfu('最近最少頻度'),
  fifo('先入れ先出し'),
  ttl('時間ベース'),
  random('ランダム'),
  adaptive('適応型');

  const CacheEvictionPolicy(this.displayName);
  final String displayName;
}

enum CacheInvalidationStrategy {
  ttl('時間ベース'),
  eventBased('イベントベース'),
  tagBased('タグベース'),
  patternBased('パターンベース'),
  manual('手動'),
  hybrid('ハイブリッド');

  const CacheInvalidationStrategy(this.displayName);
  final String displayName;
}

enum MaterializedViewStatus {
  active('アクティブ'),
  building('構築中'),
  refreshing('更新中'),
  stale('古い'),
  disabled('無効'),
  error('エラー');

  const MaterializedViewStatus(this.displayName);
  final String displayName;
}

enum PerformanceMetricType {
  hitRate('ヒット率'),
  missRate('ミス率'),
  latency('レイテンシ'),
  throughput('スループット'),
  memoryUsage('メモリ使用量'),
  evictionCount('削除数');

  const PerformanceMetricType(this.displayName);
  final String displayName;
}

enum CacheCompressionType {
  none('なし'),
  gzip('Gzip'),
  snappy('Snappy'),
  lz4('LZ4'),
  brotli('Brotli'),
  zstd('Zstd');

  const CacheCompressionType(this.displayName);
  final String displayName;
}

// ============================================================================
// MODELS (12 total)
// ============================================================================

/// CacheEntry: キャッシュエントリ
class CacheEntry {
  CacheEntry({
    required this.id,
    required this.key,
    required this.value,
    required this.createdAt,
    required this.expiresAt,
    this.lastAccessedAt,
    this.accessCount = 0,
    this.size = 0,
    this.compressed = false,
    this.tags = const [],
  });

  final String id;
  final String key;
  final String value;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? lastAccessedAt;
  final int accessCount;
  final int size;
  final bool compressed;
  final List<String> tags;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  int get ageInSeconds => DateTime.now().difference(createdAt).inSeconds;
  int get secondsUntilExpiry => expiresAt.difference(DateTime.now()).inSeconds;
  bool get isStale => secondsUntilExpiry < 60;

  CacheEntry copyWith({
    String? id,
    String? key,
    String? value,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? lastAccessedAt,
    int? accessCount,
    int? size,
    bool? compressed,
    List<String>? tags,
  }) {
    return CacheEntry(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      accessCount: accessCount ?? this.accessCount,
      size: size ?? this.size,
      compressed: compressed ?? this.compressed,
      tags: tags ?? this.tags,
    );
  }
}

/// CacheConfiguration: キャッシュ設定
class CacheConfiguration {
  CacheConfiguration({
    required this.id,
    required this.name,
    required this.cacheType,
    required this.createdAt,
    this.maxSize = 1000000,
    this.maxEntries = 10000,
    this.evictionPolicy = CacheEvictionPolicy.lru,
    this.invalidationStrategy = CacheInvalidationStrategy.ttl,
    this.defaultTtlSeconds = 3600,
    this.compressionEnabled = false,
    this.compressionType = CacheCompressionType.gzip,
    this.persistenceEnabled = false,
  });

  final String id;
  final String name;
  final CacheType cacheType;
  final DateTime createdAt;
  final int maxSize;
  final int maxEntries;
  final CacheEvictionPolicy evictionPolicy;
  final CacheInvalidationStrategy invalidationStrategy;
  final int defaultTtlSeconds;
  final bool compressionEnabled;
  final CacheCompressionType compressionType;
  final bool persistenceEnabled;

  bool get isLru => evictionPolicy == CacheEvictionPolicy.lru;
  bool get isDistributed => cacheType == CacheType.distributed;
  bool get supportsPersistence => persistenceEnabled;
}

/// CacheStatistics: キャッシュ統計
class CacheStatistics {
  CacheStatistics({
    required this.id,
    required this.cacheId,
    required this.timestamp,
    this.totalHits = 0,
    this.totalMisses = 0,
    this.totalEvictions = 0,
    this.currentEntries = 0,
    this.currentMemoryUsage = 0,
    this.averageLatencyMs = 0.0,
    this.peakMemoryUsage = 0,
  });

  final String id;
  final String cacheId;
  final DateTime timestamp;
  final int totalHits;
  final int totalMisses;
  final int totalEvictions;
  final int currentEntries;
  final int currentMemoryUsage;
  final double averageLatencyMs;
  final int peakMemoryUsage;

  double get hitRate =>
      totalHits + totalMisses > 0 ? totalHits / (totalHits + totalMisses) : 0.0;
  double get missRate => 1.0 - hitRate;
  int get ageInMinutes => DateTime.now().difference(timestamp).inMinutes;
  bool get isHighMissRate => missRate > 0.3;
}

/// MaterializedView: マテリアライズドビュー
class MaterializedView {
  MaterializedView({
    required this.id,
    required this.name,
    required this.queryDefinition,
    required this.createdAt,
    required this.lastRefreshedAt,
    this.status = MaterializedViewStatus.active,
    this.refreshIntervalSeconds = 3600,
    this.rowCount = 0,
    this.sizeBytes = 0,
    this.isIndexed = false,
  });

  final String id;
  final String name;
  final String queryDefinition;
  final DateTime createdAt;
  final DateTime lastRefreshedAt;
  final MaterializedViewStatus status;
  final int refreshIntervalSeconds;
  final int rowCount;
  final int sizeBytes;
  final bool isIndexed;

  bool get isActive => status == MaterializedViewStatus.active;
  bool get needsRefresh =>
      DateTime.now().difference(lastRefreshedAt).inSeconds >
      refreshIntervalSeconds;
  int get secondsSinceRefresh =>
      DateTime.now().difference(lastRefreshedAt).inSeconds;
  int get ageInHours => DateTime.now().difference(createdAt).inHours;
}

/// QueryResultCache: クエリ結果キャッシュ
class QueryResultCache {
  QueryResultCache({
    required this.id,
    required this.queryHash,
    required this.queryText,
    required this.result,
    required this.createdAt,
    required this.expiresAt,
    this.executionTimeMs = 0,
    this.resultSize = 0,
    this.accessCount = 0,
    this.lastAccessedAt,
  });

  final String id;
  final String queryHash;
  final String queryText;
  final String result;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int executionTimeMs;
  final int resultSize;
  final int accessCount;
  final DateTime? lastAccessedAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isStale => DateTime.now().difference(createdAt).inMinutes > 30;
  double get reductionPercent => executionTimeMs > 0 ? 95.0 : 0.0;
}

/// CacheInvalidationTag: キャッシュ無効化タグ
class CacheInvalidationTag {
  CacheInvalidationTag({
    required this.id,
    required this.tagName,
    required this.createdAt,
    this.description,
    this.entriesTagged = 0,
    this.lastInvalidatedAt,
  });

  final String id;
  final String tagName;
  final DateTime createdAt;
  final String? description;
  final int entriesTagged;
  final DateTime? lastInvalidatedAt;

  bool get hasBeenInvalidated => lastInvalidatedAt != null;
  int get hoursSinceCreated => DateTime.now().difference(createdAt).inHours;
}

/// PrefetchStrategy: プリフェッチ戦略
class PrefetchStrategy {
  PrefetchStrategy({
    required this.id,
    required this.name,
    required this.sourceQuery,
    required this.createdAt,
    this.enabled = true,
    this.prefetchIntervalSeconds = 1800,
    this.targetCacheKeys = const [],
    this.lastExecutedAt,
    this.successCount = 0,
  });

  final String id;
  final String name;
  final String sourceQuery;
  final DateTime createdAt;
  final bool enabled;
  final int prefetchIntervalSeconds;
  final List<String> targetCacheKeys;
  final DateTime? lastExecutedAt;
  final int successCount;

  bool get needsExecution => lastExecutedAt == null ||
      DateTime.now().difference(lastExecutedAt!).inSeconds >
          prefetchIntervalSeconds;
  bool get isActive => enabled && needsExecution;
  int get targetCount => targetCacheKeys.length;
}

/// PerformanceMetric: パフォーマンスメトリクス
class PerformanceMetric {
  PerformanceMetric({
    required this.id,
    required this.metricType,
    required this.value,
    required this.timestamp,
    this.dimension,
    this.threshold,
    this.isAnomaly = false,
  });

  final String id;
  final PerformanceMetricType metricType;
  final double value;
  final DateTime timestamp;
  final String? dimension;
  final double? threshold;
  final bool isAnomaly;

  bool get isAboveThreshold => threshold != null && value > threshold!;
  bool get isCritical => isAnomaly || isAboveThreshold;
  int get ageInMinutes => DateTime.now().difference(timestamp).inMinutes;
}

/// CacheWarmingStrategy: キャッシュウォーミング戦略
class CacheWarmingStrategy {
  CacheWarmingStrategy({
    required this.id,
    required this.name,
    required this.dataSource,
    required this.createdAt,
    this.enabled = true,
    this.warmingIntervalSeconds = 3600,
    this.keysToWarm = const [],
    this.estimatedWarmupTimeSeconds = 0,
    this.lastWarmingAt,
  });

  final String id;
  final String name;
  final String dataSource;
  final DateTime createdAt;
  final bool enabled;
  final int warmingIntervalSeconds;
  final List<String> keysToWarm;
  final int estimatedWarmupTimeSeconds;
  final DateTime? lastWarmingAt;

  bool get needsWarming => lastWarmingAt == null ||
      DateTime.now().difference(lastWarmingAt!).inSeconds >
          warmingIntervalSeconds;
  bool get shouldExecute => enabled && needsWarming;
  int get keyCount => keysToWarm.length;
}

/// CacheHierarchy: キャッシュ階層
class CacheHierarchy {
  CacheHierarchy({
    required this.id,
    required this.name,
    required this.createdAt,
    this.level1CacheId,
    this.level2CacheId,
    this.level3CacheId,
    this.level1HitRate = 0.0,
    this.level2HitRate = 0.0,
    this.level3HitRate = 0.0,
    this.promotionEnabled = true,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final String? level1CacheId;
  final String? level2CacheId;
  final String? level3CacheId;
  final double level1HitRate;
  final double level2HitRate;
  final double level3HitRate;
  final bool promotionEnabled;

  int get levelCount =>
      (level1CacheId != null ? 1 : 0) +
      (level2CacheId != null ? 1 : 0) +
      (level3CacheId != null ? 1 : 0);
  double get overallHitRate =>
      (level1HitRate + level2HitRate + level3HitRate) / 3;
  bool get isMultiLevel => levelCount > 1;
}

/// CacheCoherence: キャッシュコヒーレンス
class CacheCoherence {
  CacheCoherence({
    required this.id,
    required this.cacheId,
    required this.lastSyncAt,
    required this.createdAt,
    this.syncStrategy = 'write-through',
    this.inconsistencies = 0,
    this.resolutionsApplied = 0,
    this.inconsistencyDetectionEnabled = true,
  });

  final String id;
  final String cacheId;
  final DateTime lastSyncAt;
  final DateTime createdAt;
  final String syncStrategy;
  final int inconsistencies;
  final int resolutionsApplied;
  final bool inconsistencyDetectionEnabled;

  bool get isConsistent => inconsistencies == 0;
  int get hoursSinceSync => DateTime.now().difference(lastSyncAt).inHours;
  bool get needsSync => hoursSinceSync > 1;
  int get resolutionRate => inconsistencies > 0
      ? (resolutionsApplied / inconsistencies * 100).toInt()
      : 100;
}
