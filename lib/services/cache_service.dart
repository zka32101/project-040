/// Phase 30: キャッシング・パフォーマンス
import 'dart:async';

abstract class CacheEntry<T> {
  T get value;
  DateTime get createdAt;
  DateTime get expiresAt;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

abstract class CacheService<K, V> {
  Future<V?> get(K key);
  Future<void> put(K key, V value, Duration ttl);
  Future<void> invalidate(K key);
  Future<void> clear();
  Future<int> size();
}

class MemoryCacheService<K, V> implements CacheService<K, V> {
  final Map<K, _CacheEntry<V>> _cache = {};
  
  @override
  Future<V?> get(K key) async {
    final entry = _cache[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.value;
  }

  @override
  Future<void> put(K key, V value, Duration ttl) async {
    _cache[key] = _CacheEntry(value, DateTime.now().add(ttl));
  }

  @override
  Future<void> invalidate(K key) async => _cache.remove(key);

  @override
  Future<void> clear() async => _cache.clear();

  @override
  Future<int> size() async => _cache.length;
}

class _CacheEntry<V> {
  final V value;
  final DateTime expiresAt;
  _CacheEntry(this.value, this.expiresAt);
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
