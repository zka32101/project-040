/// Phase 24: ジョブキャッシング・オフラインサポート
/// メモリ・ローカルストレージでのキャッシング管理

import 'dart:async';
import '../models/async_job_model.dart';

/// キャッシュ戦略
enum CacheStrategy {
  /// ネットワークファースト
  networkFirst,

  /// キャッシュファースト
  cacheFirst,

  /// ネットワークのみ
  networkOnly,

  /// キャッシュのみ
  cacheOnly,

  /// ステイル・ホワイル・リバリデート
  staleWhileRevalidate,
}

/// キャッシュエントリ
class CacheEntry<T> {
  /// キャッシュデータ
  final T data;

  /// キャッシュ作成時刻
  final DateTime createdAt;

  /// 最終アクセス時刻
  DateTime lastAccessedAt;

  /// TTL（秒）
  final int ttlSeconds;

  /// キャッシュのタイムスタンプ
  final String? eTag;

  CacheEntry({
    required this.data,
    required this.ttlSeconds,
    DateTime? createdAt,
    this.eTag,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastAccessedAt = DateTime.now();

  /// キャッシュが有効か
  bool get isValid {
    final age = DateTime.now().difference(createdAt);
    return age.inSeconds < ttlSeconds;
  }

  /// キャッシュが古いか
  bool get isStale {
    return !isValid;
  }

  /// 最終アクセスから経過時間（秒）
  int get secondsSinceLastAccess {
    return DateTime.now().difference(lastAccessedAt).inSeconds;
  }
}

/// ジョブキャッシュサービス
abstract class JobCacheService {
  /// ジョブをキャッシュに保存
  Future<void> cacheJob(AsyncJob job);

  /// ジョブをキャッシュから取得
  Future<AsyncJob?> getJob(String jobId);

  /// 複数ジョブをキャッシュに保存
  Future<void> cacheJobs(List<AsyncJob> jobs);

  /// 複数ジョブをキャッシュから取得
  Future<List<AsyncJob>> getJobs(List<String> jobIds);

  /// ユーザーのすべてのジョブを取得
  Future<List<AsyncJob>> getUserJobs(String userId);

  /// キャッシュをクリア
  Future<void> clearCache();

  /// 特定ジョブのキャッシュを削除
  Future<void> removeJob(String jobId);

  /// キャッシュ統計を取得
  Future<CacheStatistics> getStatistics();
}

/// メモリ内キャッシュサービス実装
class MemoryCacheService implements JobCacheService {
  /// メモリ内キャッシュ
  final Map<String, CacheEntry<AsyncJob>> _cache = {};

  /// LRU トラッキング用
  final List<String> _accessOrder = [];

  /// 最大キャッシュサイズ
  final int maxCacheSize;

  /// デフォルト TTL（秒）
  final int defaultTtlSeconds;

  MemoryCacheService({
    this.maxCacheSize = 1000,
    this.defaultTtlSeconds = 3600,
  });

  @override
  Future<void> cacheJob(AsyncJob job) async {
    _evictIfNeeded();

    final entry = CacheEntry(
      data: job,
      ttlSeconds: defaultTtlSeconds,
    );

    _cache[job.jobId] = entry;
    _updateAccessOrder(job.jobId);
  }

  @override
  Future<AsyncJob?> getJob(String jobId) async {
    final entry = _cache[jobId];

    if (entry == null) return null;

    if (entry.isStale) {
      _cache.remove(jobId);
      _accessOrder.remove(jobId);
      return null;
    }

    entry.lastAccessedAt = DateTime.now();
    _updateAccessOrder(jobId);

    return entry.data;
  }

  @override
  Future<void> cacheJobs(List<AsyncJob> jobs) async {
    for (final job in jobs) {
      await cacheJob(job);
    }
  }

  @override
  Future<List<AsyncJob>> getJobs(List<String> jobIds) async {
    final jobs = <AsyncJob>[];

    for (final jobId in jobIds) {
      final job = await getJob(jobId);
      if (job != null) {
        jobs.add(job);
      }
    }

    return jobs;
  }

  @override
  Future<List<AsyncJob>> getUserJobs(String userId) async {
    final jobs = <AsyncJob>[];

    for (final entry in _cache.values) {
      if (entry.isValid && entry.data.userId == userId) {
        jobs.add(entry.data);
      }
    }

    return jobs;
  }

  @override
  Future<void> clearCache() async {
    _cache.clear();
    _accessOrder.clear();
  }

  @override
  Future<void> removeJob(String jobId) async {
    _cache.remove(jobId);
    _accessOrder.remove(jobId);
  }

  @override
  Future<CacheStatistics> getStatistics() async {
    return CacheStatistics(
      totalEntries: _cache.length,
      validEntries: _cache.values.where((e) => e.isValid).length,
      staleEntries: _cache.values.where((e) => e.isStale).length,
      memoryUsageBytes: _estimateMemoryUsage(),
      hitRate: _calculateHitRate(),
    );
  }

  /// キャッシュサイズ超過時に削除
  void _evictIfNeeded() {
    while (_cache.length >= maxCacheSize) {
      // LRU（最も使用されていないものを削除）
      if (_accessOrder.isNotEmpty) {
        final lruJobId = _accessOrder.first;
        _cache.remove(lruJobId);
        _accessOrder.removeAt(0);
      }
    }
  }

  /// アクセス順序を更新
  void _updateAccessOrder(String jobId) {
    _accessOrder.remove(jobId);
    _accessOrder.add(jobId);
  }

  /// メモリ使用量を推定（バイト）
  int _estimateMemoryUsage() {
    int bytes = 0;
    for (final entry in _cache.values) {
      bytes += entry.data.jobId.length * 2; // 文字列
      bytes += 64; // メタデータ
    }
    return bytes;
  }

  /// キャッシュヒット率を計算
  double _calculateHitRate() {
    if (_cache.isEmpty) return 0.0;
    final validCount = _cache.values.where((e) => e.isValid).length;
    return validCount / _cache.length;
  }
}

/// デルタ同期マネージャー
class DeltaSyncManager {
  /// 最後に同期した時刻
  DateTime? _lastSyncTime;

  /// 変更されたジョブ ID
  final Set<String> _changedJobIds = {};

  /// 同期キュー
  final List<AsyncJob> _syncQueue = [];

  /// 同期イン・プログレス
  bool _isSyncing = false;

  /// 最後に同期した時刻を取得
  DateTime? get lastSyncTime => _lastSyncTime;

  /// 変更があるか
  bool get hasChanges => _changedJobIds.isNotEmpty;

  /// ジョブの変更を登録
  void markJobChanged(String jobId) {
    _changedJobIds.add(jobId);
  }

  /// 複数ジョブの変更を登録
  void markJobsChanged(List<String> jobIds) {
    _changedJobIds.addAll(jobIds);
  }

  /// 変更を同期キューに追加
  void queueForSync(AsyncJob job) {
    _syncQueue.add(job);
  }

  /// 同期キューを取得
  List<AsyncJob> getSyncQueue() => List.from(_syncQueue);

  /// 同期を実行
  Future<void> sync(
    Future<void> Function(List<AsyncJob>) syncFunction,
  ) async {
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      if (_syncQueue.isNotEmpty) {
        await syncFunction(_syncQueue);
        _syncQueue.clear();
        _changedJobIds.clear();
        _lastSyncTime = DateTime.now();
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// 同期状態をリセット
  void reset() {
    _changedJobIds.clear();
    _syncQueue.clear();
    _isSyncing = false;
  }
}

/// キャッシュ統計
class CacheStatistics {
  /// 総エントリ数
  final int totalEntries;

  /// 有効なエントリ数
  final int validEntries;

  /// 古いエントリ数
  final int staleEntries;

  /// メモリ使用量（バイト）
  final int memoryUsageBytes;

  /// キャッシュヒット率（0.0 - 1.0）
  final double hitRate;

  const CacheStatistics({
    required this.totalEntries,
    required this.validEntries,
    required this.staleEntries,
    required this.memoryUsageBytes,
    required this.hitRate,
  });

  /// JSON に変換
  Map<String, dynamic> toJson() => {
        'totalEntries': totalEntries,
        'validEntries': validEntries,
        'staleEntries': staleEntries,
        'memoryUsageBytes': memoryUsageBytes,
        'hitRate': hitRate,
      };

  /// メモリ使用量を MB で取得
  double get memoryUsageMb => memoryUsageBytes / (1024 * 1024);
}
