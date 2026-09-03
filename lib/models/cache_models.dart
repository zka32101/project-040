/// Phase 41: Advanced Caching Strategies キャッシング戦略モデル定義
///
/// LRU, LFU, TTL, ARC, 分散キャッシュ戦略

/// キャッシング戦略
enum CacheStrategy {
  lru('lru'),               // Least Recently Used
  lfu('lfu'),               // Least Frequently Used
  ttl('ttl'),               // Time To Live
  arc('arc'),               // Adaptive Replacement Cache
  distributed('distributed'); // 分散キャッシュ

  final String value;
  const CacheStrategy(this.value);
}

/// 削除ポリシー
enum EvictionPolicy {
  lru('lru'),     // 最近使用されたエントリを保持
  lfu('lfu'),     // 頻繁に使用されたエントリを保持
  fifo('fifo'),   // 先入先出
  random('random'), // ランダム削除
  ttl('ttl');     // TTL ベース削除

  final String value;
  const EvictionPolicy(this.value);
}

/// キャッシュレベル
enum CacheLevel {
  L1('L1'),       // メモリ内（最高速度）
  L2('L2'),       // メモリ内（大容量）
  L3('L3');       // 分散キャッシュ

  final String value;
  const CacheLevel(this.value);
}

/// キャッシュエントリ
class CacheEntry {
  final String key;
  final dynamic value;
  final int? ttlSeconds;
  final DateTime createdAt;
  final DateTime lastAccessedAt;
  final int accessCount;
  final int? estimatedSizeBytes;

  CacheEntry({
    required this.key,
    required this.value,
    this.ttlSeconds,
    required this.createdAt,
    required this.lastAccessedAt,
    this.accessCount = 0,
    this.estimatedSizeBytes,
  });

  /// TTL が有効期限を超過したか
  bool get isExpired {
    if (ttlSeconds == null) return false;
    final expiresAt = createdAt.add(Duration(seconds: ttlSeconds!));
    return DateTime.now().isAfter(expiresAt);
  }

  /// 最後のアクセスからの経過時間 (秒)
  int get secondsSinceLastAccess {
    return DateTime.now().difference(lastAccessedAt).inSeconds;
  }

  /// アクセス済みのコピーを作成
  CacheEntry withAccess() {
    return CacheEntry(
      key: key,
      value: value,
      ttlSeconds: ttlSeconds,
      createdAt: createdAt,
      lastAccessedAt: DateTime.now(),
      accessCount: accessCount + 1,
      estimatedSizeBytes: estimatedSizeBytes,
    );
  }
}

/// キャッシュポリシー
class CachePolicy {
  final String policyId;
  final String name;
  final String? description;
  final CacheStrategy strategy;
  final int maxSize;
  final int maxMemoryMB;
  final int? ttlSeconds;
  final EvictionPolicy evictionPolicy;
  final CacheLevel cacheLevel;
  final int? replicationFactor;
  final DateTime createdAt;
  final DateTime updatedAt;

  CachePolicy({
    required this.policyId,
    required this.name,
    this.description,
    required this.strategy,
    this.maxSize = 1000,
    this.maxMemoryMB = 512,
    this.ttlSeconds,
    required this.evictionPolicy,
    this.cacheLevel = CacheLevel.L1,
    this.replicationFactor,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// キャッシュメトリクス
class CacheMetrics {
  final String metricsId;
  final String policyId;
  final int totalHits;
  final int totalMisses;
  final int evictedEntries;
  final int currentSize;
  final int currentMemoryBytes;
  final DateTime createdAt;
  final DateTime measuredAt;

  CacheMetrics({
    required this.metricsId,
    required this.policyId,
    required this.totalHits,
    required this.totalMisses,
    required this.evictedEntries,
    required this.currentSize,
    this.currentMemoryBytes = 0,
    required this.createdAt,
    required this.measuredAt,
  });

  /// ヒット率
  double get hitRate {
    final total = totalHits + totalMisses;
    return total > 0 ? totalHits / total : 0.0;
  }

  /// ミス率
  double get missRate {
    final total = totalHits + totalMisses;
    return total > 0 ? totalMisses / total : 0.0;
  }

  /// 平均ヒット率 (0-100)
  int get hitRatePercentage => (hitRate * 100).toInt();
}

/// LRU キャッシュ
class LRUCache {
  final String cacheId;
  final int maxSize;
  final Map<String, CacheEntry> _cache = {};
  final List<String> _accessOrder = [];

  LRUCache({
    required this.cacheId,
    required this.maxSize,
  });

  /// 値を取得
  CacheEntry? get(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      _updateAccessOrder(key);
      return entry.withAccess();
    }
    if (entry?.isExpired ?? false) {
      _cache.remove(key);
      _accessOrder.remove(key);
    }
    return null;
  }

  /// 値を設定
  void set(String key, CacheEntry entry) {
    if (_cache.containsKey(key)) {
      _accessOrder.remove(key);
    } else if (_cache.length >= maxSize) {
      // 最も古いエントリを削除
      final lruKey = _accessOrder.removeAt(0);
      _cache.remove(lruKey);
    }
    _cache[key] = entry;
    _accessOrder.add(key);
  }

  /// キーを削除
  void delete(String key) {
    _cache.remove(key);
    _accessOrder.remove(key);
  }

  /// キャッシュをクリア
  void clear() {
    _cache.clear();
    _accessOrder.clear();
  }

  /// アクセス順序を更新
  void _updateAccessOrder(String key) {
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  /// 現在のサイズ
  int get currentSize => _cache.length;

  /// すべてのエントリを取得
  Map<String, CacheEntry> getAll() => Map.from(_cache);
}

/// LFU キャッシュ
class LFUCache {
  final String cacheId;
  final int maxSize;
  final Map<String, CacheEntry> _cache = {};

  LFUCache({
    required this.cacheId,
    required this.maxSize,
  });

  /// 値を取得
  CacheEntry? get(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      _cache[key] = entry.withAccess();
      return _cache[key];
    }
    if (entry?.isExpired ?? false) {
      _cache.remove(key);
    }
    return null;
  }

  /// 値を設定
  void set(String key, CacheEntry entry) {
    if (_cache.containsKey(key)) {
      // 既存キーは上書き
      _cache[key] = entry;
    } else if (_cache.length >= maxSize) {
      // 最も使用頻度が低いエントリを削除
      final lfuKey = _cache.entries
          .reduce((a, b) => a.value.accessCount <= b.value.accessCount ? a : b)
          .key;
      _cache.remove(lfuKey);
      _cache[key] = entry;
    } else {
      _cache[key] = entry;
    }
  }

  /// キーを削除
  void delete(String key) {
    _cache.remove(key);
  }

  /// キャッシュをクリア
  void clear() {
    _cache.clear();
  }

  /// 現在のサイズ
  int get currentSize => _cache.length;

  /// すべてのエントリを取得
  Map<String, CacheEntry> getAll() => Map.from(_cache);
}

/// TTL キャッシュ
class TTLCache {
  final String cacheId;
  final int maxSize;
  final int ttlSeconds;
  final Map<String, CacheEntry> _cache = {};

  TTLCache({
    required this.cacheId,
    required this.maxSize,
    required this.ttlSeconds,
  });

  /// 値を取得
  CacheEntry? get(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.withAccess();
    }
    if (entry?.isExpired ?? false) {
      _cache.remove(key);
    }
    return null;
  }

  /// 値を設定
  void set(String key, CacheEntry entry) {
    if (_cache.length >= maxSize && !_cache.containsKey(key)) {
      // 期限切れエントリを削除してからセット
      _expireOldEntries();
      if (_cache.length >= maxSize) {
        _cache.remove(_cache.keys.first);
      }
    }
    _cache[key] = entry;
  }

  /// キーを削除
  void delete(String key) {
    _cache.remove(key);
  }

  /// キャッシュをクリア
  void clear() {
    _cache.clear();
  }

  /// 古いエントリを削除
  void _expireOldEntries() {
    final keysToRemove = _cache.entries
        .where((e) => e.value.isExpired)
        .map((e) => e.key)
        .toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }

  /// 現在のサイズ
  int get currentSize => _cache.length;

  /// すべてのエントリを取得
  Map<String, CacheEntry> getAll() => Map.from(_cache);
}

/// ARC キャッシュ (Adaptive Replacement Cache)
class ARCCache {
  final String cacheId;
  final int maxSize;
  final List<String> _recentList = [];  // 最近アクセスされたキー
  final List<String> _frequentList = []; // 頻繁にアクセスされたキー
  final Map<String, CacheEntry> _cache = {};
  int _targetT = 0; // T1 と T2 のバランスポイント

  ARCCache({
    required this.cacheId,
    required this.maxSize,
  });

  /// 値を取得
  CacheEntry? get(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      _updateAdaptive(key);
      return entry.withAccess();
    }
    if (entry?.isExpired ?? false) {
      _cache.remove(key);
      _recentList.remove(key);
      _frequentList.remove(key);
    }
    return null;
  }

  /// 値を設定
  void set(String key, CacheEntry entry) {
    if (_cache.containsKey(key)) {
      _cache[key] = entry;
    } else {
      if (_cache.length >= maxSize) {
        _evictAdaptive();
      }
      _cache[key] = entry;
      _recentList.add(key);
    }
  }

  /// キーを削除
  void delete(String key) {
    _cache.remove(key);
    _recentList.remove(key);
    _frequentList.remove(key);
  }

  /// キャッシュをクリア
  void clear() {
    _cache.clear();
    _recentList.clear();
    _frequentList.clear();
  }

  /// 適応的に更新
  void _updateAdaptive(String key) {
    if (_recentList.contains(key)) {
      _recentList.remove(key);
      _frequentList.add(key);
    }
  }

  /// 適応的に削除
  void _evictAdaptive() {
    if (_recentList.length > _targetT && _recentList.isNotEmpty) {
      final keyToRemove = _recentList.removeAt(0);
      _cache.remove(keyToRemove);
    } else if (_frequentList.isNotEmpty) {
      final keyToRemove = _frequentList.removeAt(0);
      _cache.remove(keyToRemove);
    } else if (_recentList.isNotEmpty) {
      final keyToRemove = _recentList.removeAt(0);
      _cache.remove(keyToRemove);
    }
  }

  /// 現在のサイズ
  int get currentSize => _cache.length;

  /// すべてのエントリを取得
  Map<String, CacheEntry> getAll() => Map.from(_cache);
}

/// 分散キャッシュ
class DistributedCache {
  final String cacheId;
  final int maxSize;
  final int replicationFactor;
  final Map<String, CacheEntry> _cache = {};

  DistributedCache({
    required this.cacheId,
    required this.maxSize,
    required this.replicationFactor,
  });

  /// 値を取得
  CacheEntry? get(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.withAccess();
    }
    if (entry?.isExpired ?? false) {
      _cache.remove(key);
    }
    return null;
  }

  /// 値を設定
  void set(String key, CacheEntry entry) {
    if (_cache.length >= maxSize && !_cache.containsKey(key)) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = entry;
  }

  /// キーを削除
  void delete(String key) {
    _cache.remove(key);
  }

  /// キャッシュをクリア
  void clear() {
    _cache.clear();
  }

  /// 現在のサイズ
  int get currentSize => _cache.length;

  /// すべてのエントリを取得
  Map<String, CacheEntry> getAll() => Map.from(_cache);
}

/// キャッシュホットスポット
class CacheHotspot {
  final String key;
  final int accessCount;
  final DateTime firstAccessedAt;
  final DateTime lastAccessedAt;
  final double accessFrequencyPerSecond;

  CacheHotspot({
    required this.key,
    required this.accessCount,
    required this.firstAccessedAt,
    required this.lastAccessedAt,
    required this.accessFrequencyPerSecond,
  });
}

/// キャッシュウォーミング
class CacheWarming {
  final String warmingId;
  final String policyId;
  final List<MapEntry<String, dynamic>> entries;
  final DateTime createdAt;
  final DateTime? completedAt;

  CacheWarming({
    required this.warmingId,
    required this.policyId,
    required this.entries,
    required this.createdAt,
    this.completedAt,
  });

  /// 完了済みか
  bool get isCompleted => completedAt != null;
}

/// キャッシュ削除イベント
class CacheEvictionEvent {
  final String eventId;
  final String key;
  final String reason; // expired, lru, lfu, manual
  final DateTime timestamp;

  CacheEvictionEvent({
    required this.eventId,
    required this.key,
    required this.reason,
    required this.timestamp,
  });
}

/// キャッシュレポート
class CacheReport {
  final String reportId;
  final DateTime generatedAt;
  final List<CacheMetrics> metrics;
  final List<CacheHotspot> hotspots;
  final int totalCacheEntries;
  final double averageHitRate;

  CacheReport({
    required this.reportId,
    required this.generatedAt,
    required this.metrics,
    required this.hotspots,
    required this.totalCacheEntries,
    required this.averageHitRate,
  });

  /// Markdown形式でレポートを生成
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Cache Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');
    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Total Cache Entries: $totalCacheEntries');
    buffer.writeln('- Average Hit Rate: ${(averageHitRate * 100).toStringAsFixed(2)}%');
    buffer.writeln('- Total Policies: ${metrics.length}');
    buffer.writeln('- Hot Keys: ${hotspots.length}');
    buffer.writeln('');

    if (hotspots.isNotEmpty) {
      buffer.writeln('## Hot Keys');
      buffer.writeln('');
      for (final spot in hotspots.take(10)) {
        buffer.writeln('- **${spot.key}**: ${spot.accessCount} accesses');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}
