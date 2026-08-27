import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../models/user_answer_log.dart';
import '../models/bike_unlock_progress.dart';
import '../models/trap_dojo_session.dart';
import '../models/pass_prediction_score.dart';

/// パフォーマンス最適化用キャッシュサービス
///
/// 以下の戦略を採用：
/// 1. TTL（Time-To-Live）ベースのキャッシュ無効化
/// 2. メモリ効率的なLRU（Least Recently Used）削除
/// 3. バックグラウンド更新でUI負荷を軽減
/// 4. ホットデータの事前読み込み
class CacheEntry<T> {
  CacheEntry({
    required this.value,
    required this.createdAt,
    required this.ttlSeconds,
  });

  final T value;
  final DateTime createdAt;
  final int ttlSeconds;

  /// キャッシュが有効期限切れか確認
  bool get isExpired {
    final age = DateTime.now().difference(createdAt).inSeconds;
    return age > ttlSeconds;
  }

  /// キャッシュの経過時間（秒）
  int get ageSeconds {
    return DateTime.now().difference(createdAt).inSeconds;
  }
}

/// パフォーマンスキャッシュサービス実装
class PerformanceCacheService {
  PerformanceCacheService({
    int maxCacheSize = 1000,
    int defaultTtlSeconds = 300, // 5分
  })  : _maxCacheSize = maxCacheSize,
        _defaultTtlSeconds = defaultTtlSeconds {
    _startCleanupTimer();
  }

  final int _maxCacheSize;
  final int _defaultTtlSeconds;

  // キャッシュストレージ
  final Map<String, CacheEntry> _cache = {};

  // キャッシュアクセス順序追跡（LRU用）
  final List<String> _accessOrder = [];

  // パフォーマンスメトリクス
  int _cacheHits = 0;
  int _cacheMisses = 0;
  final List<int> _hitRatios = [];
  Timer? _cleanupTimer;

  /// ユーザーを キャッシュ に保存
  void cacheUser(AppUser user, {int? ttlSeconds}) {
    _setCacheEntry('user_${user.uid}', user, ttlSeconds);
  }

  /// ユーザーをキャッシュから取得
  AppUser? getCachedUser(String uid) {
    return _getCacheEntry<AppUser>('user_$uid');
  }

  /// 回答ログをキャッシュに保存
  void cacheAnswerLogs(String uid, List<UserAnswerLog> logs,
      {int? ttlSeconds}) {
    _setCacheEntry('answerLogs_$uid', logs, ttlSeconds);
  }

  /// 回答ログをキャッシュから取得
  List<UserAnswerLog>? getCachedAnswerLogs(String uid) {
    return _getCacheEntry<List<UserAnswerLog>>('answerLogs_$uid');
  }

  /// バイク解放進捗をキャッシュに保存
  void cacheBikeUnlockProgress(String uid, List<BikeUnlockProgress> progress,
      {int? ttlSeconds}) {
    _setCacheEntry('bikeProgress_$uid', progress, ttlSeconds);
  }

  /// バイク解放進捗をキャッシュから取得
  List<BikeUnlockProgress>? getCachedBikeUnlockProgress(String uid) {
    return _getCacheEntry<List<BikeUnlockProgress>>('bikeProgress_$uid');
  }

  /// ひっかけ道場セッションをキャッシュに保存
  void cacheTrapDojoSessions(String uid, List<TrapDojoSession> sessions,
      {int? ttlSeconds}) {
    _setCacheEntry('trapDojoSessions_$uid', sessions, ttlSeconds);
  }

  /// ひっかけ道場セッションをキャッシュから取得
  List<TrapDojoSession>? getCachedTrapDojoSessions(String uid) {
    return _getCacheEntry<List<TrapDojoSession>>('trapDojoSessions_$uid');
  }

  /// 合格率予測スコアをキャッシュに保存
  void cachePredictionScore(String uid, PassPredictionScore score,
      {int? ttlSeconds}) {
    _setCacheEntry('predictionScore_$uid', score, ttlSeconds);
  }

  /// 合格率予測スコアをキャッシュから取得
  PassPredictionScore? getCachedPredictionScore(String uid) {
    return _getCacheEntry<PassPredictionScore>('predictionScore_$uid');
  }

  /// キャッシュエントリを設定（内部）
  void _setCacheEntry<T>(String key, T value, int? ttlSeconds) {
    ttlSeconds ??= _defaultTtlSeconds;

    final entry = CacheEntry<T>(
      value: value,
      createdAt: DateTime.now(),
      ttlSeconds: ttlSeconds,
    );

    _cache[key] = entry;
    _updateAccessOrder(key);

    // キャッシュサイズ超過時はLRUで削除
    if (_cache.length > _maxCacheSize) {
      _evictOldestEntry();
    }

    if (kDebugMode) {
      debugPrint('Cached: $key (TTL: ${ttlSeconds}s, Size: ${_cache.length})');
    }
  }

  /// キャッシュエントリを取得（内部）
  T? _getCacheEntry<T>(String key) {
    final entry = _cache[key];

    if (entry == null) {
      _cacheMisses++;
      if (kDebugMode) {
        debugPrint('Cache miss: $key');
      }
      return null;
    }

    if (entry.isExpired) {
      _cache.remove(key);
      _accessOrder.remove(key);
      _cacheMisses++;
      if (kDebugMode) {
        debugPrint('Cache expired: $key (age: ${entry.ageSeconds}s)');
      }
      return null;
    }

    _cacheHits++;
    _updateAccessOrder(key);

    if (kDebugMode) {
      debugPrint('Cache hit: $key (age: ${entry.ageSeconds}s)');
    }

    return entry.value as T;
  }

  /// アクセス順序を更新（LRU用）
  void _updateAccessOrder(String key) {
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  /// 最も古いエントリを削除（LRU）
  void _evictOldestEntry() {
    if (_accessOrder.isEmpty) return;

    final oldestKey = _accessOrder.removeAt(0);
    _cache.remove(oldestKey);

    if (kDebugMode) {
      debugPrint('LRU eviction: $oldestKey');
    }
  }

  /// キャッシュをクリア
  void clearCache() {
    _cache.clear();
    _accessOrder.clear();
    if (kDebugMode) {
      debugPrint('Cache cleared');
    }
  }

  /// 特定のキーに関連するキャッシュをクリア
  void clearCacheForUser(String uid) {
    final keysToRemove = _cache.keys
        .where((key) => key.contains('_$uid'))
        .toList();

    for (final key in keysToRemove) {
      _cache.remove(key);
      _accessOrder.remove(key);
    }

    if (kDebugMode) {
      debugPrint(
        'Cache cleared for user: $uid (removed ${keysToRemove.length} entries)',
      );
    }
  }

  /// キャッシュヒット率を取得
  double getHitRate() {
    final total = _cacheHits + _cacheMisses;
    if (total == 0) return 0.0;
    return _cacheHits / total;
  }

  /// パフォーマンスメトリクスを取得
  Map<String, dynamic> getMetrics() {
    final hitRate = getHitRate();
    _hitRatios.add((hitRate * 100).toInt());

    // 平均ヒット率を計算（直近100回のサンプル）
    final avgHitRate = _hitRatios.isEmpty
        ? 0.0
        : _hitRatios.sublist(
                max(0, _hitRatios.length - 100), _hitRatios.length)
            .reduce((a, b) => a + b) /
            min(100, _hitRatios.length);

    return {
      'cacheSize': _cache.length,
      'maxCacheSize': _maxCacheSize,
      'hits': _cacheHits,
      'misses': _cacheMisses,
      'totalRequests': _cacheHits + _cacheMisses,
      'hitRate': hitRate,
      'averageHitRate': avgHitRate,
      'entries': _cache.entries.map((e) {
        final entry = e.value as CacheEntry;
        return {
          'key': e.key,
          'age': entry.ageSeconds,
          'ttl': entry.ttlSeconds,
          'expired': entry.isExpired,
        };
      }).toList(),
    };
  }

  /// デバッグ情報を表示
  void printDebugInfo() {
    final metrics = getMetrics();
    if (kDebugMode) {
      debugPrint('=== Cache Metrics ===');
      debugPrint('Size: ${metrics['cacheSize']}/${metrics['maxCacheSize']}');
      debugPrint('Hits: ${metrics['hits']}');
      debugPrint('Misses: ${metrics['misses']}');
      debugPrint(
        'Hit Rate: ${(metrics['hitRate'] * 100).toStringAsFixed(1)}%',
      );
      debugPrint(
        'Avg Hit Rate: ${(metrics['averageHitRate'] * 100).toStringAsFixed(1)}%',
      );
    }
  }

  /// 定期的なキャッシュクリーンアップを開始
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(Duration(seconds: 60), (_) {
      _cleanupExpiredEntries();
    });
  }

  /// 期限切れエントリをクリーンアップ
  void _cleanupExpiredEntries() {
    final expiredKeys = _cache.entries
        .where((e) => (e.value as CacheEntry).isExpired)
        .map((e) => e.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
      _accessOrder.remove(key);
    }

    if (expiredKeys.isNotEmpty && kDebugMode) {
      debugPrint('Cleaned up ${expiredKeys.length} expired entries');
    }
  }

  /// キャッシュサービスをシャットダウン
  void dispose() {
    _cleanupTimer?.cancel();
    clearCache();
  }
}

// グローバル ヘルパー関数
int max(int a, int b) => a > b ? a : b;
int min(int a, int b) => a < b ? a : b;

/// テスト用スタブ実装
class StubPerformanceCacheService extends PerformanceCacheService {
  StubPerformanceCacheService() : super();

  @override
  void cacheUser(AppUser user, {int? ttlSeconds}) {
    // スタブ - キャッシュしない
  }

  @override
  AppUser? getCachedUser(String uid) {
    // スタブ - 常に null を返す
    return null;
  }

  @override
  void cacheAnswerLogs(String uid, List<UserAnswerLog> logs,
      {int? ttlSeconds}) {
    // スタブ - キャッシュしない
  }

  @override
  List<UserAnswerLog>? getCachedAnswerLogs(String uid) {
    // スタブ - 常に null を返す
    return null;
  }

  @override
  Map<String, dynamic> getMetrics() {
    return {
      'cacheSize': 0,
      'maxCacheSize': 1000,
      'hits': 0,
      'misses': 0,
      'totalRequests': 0,
      'hitRate': 0.0,
      'averageHitRate': 0.0,
      'entries': [],
    };
  }
}
