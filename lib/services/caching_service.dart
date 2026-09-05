/// Phase 87: Advanced Caching & Performance Optimization
/// Service layer for caching and performance optimization
library caching_service;

import 'package:project_040/models/caching_models.dart';

// ============================================================================
// REPOSITORY INTERFACE (70+ methods)
// ============================================================================

abstract class CachingRepository {
  // ---- Cache Entry Management (12 methods) ----
  Future<CacheEntry> createCacheEntry(CacheEntry entry);
  Future<CacheEntry?> getCacheEntryById(String entryId);
  Future<CacheEntry?> getCacheEntryByKey(String key);
  Future<List<CacheEntry>> getAllCacheEntries({int limit = 100, int offset = 0});
  Future<List<CacheEntry>> getExpiredEntries();
  Future<CacheEntry> updateCacheEntry(CacheEntry entry);
  Future<bool> deleteCacheEntry(String entryId);
  Future<bool> deleteCacheEntryByKey(String key);
  Future<int> getCacheEntryCount();
  Future<List<CacheEntry>> getEntriesByTag(String tag);
  Future<int> getTotalCacheSize();
  Future<List<CacheEntry>> searchCacheEntries(String keyPattern);

  // ---- Cache Configuration (10 methods) ----
  Future<CacheConfiguration> createConfiguration(CacheConfiguration config);
  Future<CacheConfiguration?> getConfigurationById(String configId);
  Future<List<CacheConfiguration>> getAllConfigurations();
  Future<List<CacheConfiguration>> getConfigurationsByType(CacheType type);
  Future<CacheConfiguration> updateConfiguration(CacheConfiguration config);
  Future<bool> deleteConfiguration(String configId);
  Future<int> getConfigurationCount();
  Future<List<CacheConfiguration>> searchConfigurations(String namePattern);
  Future<CacheConfiguration?> getDefaultConfiguration();
  Future<bool> setDefaultConfiguration(String configId);

  // ---- Cache Statistics (12 methods) ----
  Future<CacheStatistics> recordStatistics(CacheStatistics stats);
  Future<CacheStatistics?> getStatisticsById(String statsId);
  Future<CacheStatistics?> getLatestStatistics(String cacheId);
  Future<List<CacheStatistics>> getStatisticsHistory(String cacheId, int limit);
  Future<List<CacheStatistics>> getStatisticsByTimeRange(
      String cacheId, DateTime start, DateTime end);
  Future<double> getAverageHitRate(String cacheId);
  Future<int> getTotalEvictions(String cacheId);
  Future<double> getAverageLatency(String cacheId);
  Future<List<CacheStatistics>> getHighMissRateStats();
  Future<int> getStatisticsCount(String cacheId);
  Future<bool> deleteOldStatistics(String cacheId, Duration olderThan);
  Future<List<CacheStatistics>> getRecentStatistics(String cacheId, int minutes);

  // ---- Materialized Views (10 methods) ----
  Future<MaterializedView> createMaterializedView(MaterializedView view);
  Future<MaterializedView?> getMaterializedViewById(String viewId);
  Future<List<MaterializedView>> getAllMaterializedViews();
  Future<List<MaterializedView>> getViewsByStatus(MaterializedViewStatus status);
  Future<MaterializedView> updateMaterializedView(MaterializedView view);
  Future<bool> deleteMaterializedView(String viewId);
  Future<List<MaterializedView>> getViewsNeedingRefresh();
  Future<int> getMaterializedViewCount();
  Future<List<MaterializedView>> getLargestViews(int limit);
  Future<int> getTotalMaterializedViewSize();

  // ---- Query Result Caching (10 methods) ----
  Future<QueryResultCache> createQueryResultCache(QueryResultCache cache);
  Future<QueryResultCache?> getQueryResultByHash(String queryHash);
  Future<List<QueryResultCache>> getAllQueryResults(
      {int limit = 100, int offset = 0});
  Future<List<QueryResultCache>> getExpiredQueryResults();
  Future<QueryResultCache> updateQueryResultCache(QueryResultCache cache);
  Future<bool> deleteQueryResultCache(String cacheId);
  Future<List<QueryResultCache>> getHighAccessQueries(int limit);
  Future<int> getQueryResultCacheCount();
  Future<double> getAverageQueryReduction();
  Future<List<QueryResultCache>> searchQueryResults(String queryPattern);

  // ---- Cache Invalidation Tags (8 methods) ----
  Future<CacheInvalidationTag> createInvalidationTag(
      CacheInvalidationTag tag);
  Future<CacheInvalidationTag?> getInvalidationTagById(String tagId);
  Future<CacheInvalidationTag?> getInvalidationTagByName(String tagName);
  Future<List<CacheInvalidationTag>> getAllInvalidationTags();
  Future<CacheInvalidationTag> updateInvalidationTag(
      CacheInvalidationTag tag);
  Future<bool> deleteInvalidationTag(String tagId);
  Future<int> getInvalidationTagCount();
  Future<List<CacheInvalidationTag>> getFrequentlyInvalidatedTags(int limit);

  // ---- Prefetch Strategies (8 methods) ----
  Future<PrefetchStrategy> createPrefetchStrategy(PrefetchStrategy strategy);
  Future<PrefetchStrategy?> getPrefetchStrategyById(String strategyId);
  Future<List<PrefetchStrategy>> getAllPrefetchStrategies();
  Future<List<PrefetchStrategy>> getActivePrefetchStrategies();
  Future<PrefetchStrategy> updatePrefetchStrategy(PrefetchStrategy strategy);
  Future<bool> deletePrefetchStrategy(String strategyId);
  Future<int> getPrefetchStrategyCount();
  Future<List<PrefetchStrategy>> getStrategiesNeedingExecution();

  // ---- Performance Metrics (10 methods) ----
  Future<PerformanceMetric> recordPerformanceMetric(PerformanceMetric metric);
  Future<PerformanceMetric?> getPerformanceMetricById(String metricId);
  Future<List<PerformanceMetric>> getMetricsByType(
      PerformanceMetricType type);
  Future<List<PerformanceMetric>> getRecentMetrics(
      PerformanceMetricType type, int limit);
  Future<List<PerformanceMetric>> getAnomalousMetrics();
  Future<double> getAverageMetricValue(PerformanceMetricType type);
  Future<int> getPerformanceMetricCount();
  Future<List<PerformanceMetric>> getMetricsByTimeRange(
      DateTime start, DateTime end);
  Future<List<PerformanceMetric>> getCriticalMetrics();
  Future<bool> deleteOldMetrics(Duration olderThan);

  // ---- Cache Warming Strategies (8 methods) ----
  Future<CacheWarmingStrategy> createWarmingStrategy(
      CacheWarmingStrategy strategy);
  Future<CacheWarmingStrategy?> getWarmingStrategyById(String strategyId);
  Future<List<CacheWarmingStrategy>> getAllWarmingStrategies();
  Future<List<CacheWarmingStrategy>> getEnabledWarmingStrategies();
  Future<CacheWarmingStrategy> updateWarmingStrategy(
      CacheWarmingStrategy strategy);
  Future<bool> deleteWarmingStrategy(String strategyId);
  Future<List<CacheWarmingStrategy>> getStrategiesNeedingExecution();
  Future<int> getWarmingStrategyCount();

  // ---- Cache Hierarchy (8 methods) ----
  Future<CacheHierarchy> createCacheHierarchy(CacheHierarchy hierarchy);
  Future<CacheHierarchy?> getCacheHierarchyById(String hierarchyId);
  Future<List<CacheHierarchy>> getAllCacheHierarchies();
  Future<CacheHierarchy> updateCacheHierarchy(CacheHierarchy hierarchy);
  Future<bool> deleteCacheHierarchy(String hierarchyId);
  Future<List<CacheHierarchy>> getMultiLevelHierarchies();
  Future<int> getCacheHierarchyCount();
  Future<CacheHierarchy?> getDefaultHierarchy();

  // ---- Cache Coherence (8 methods) ----
  Future<CacheCoherence> recordCacheCoherence(CacheCoherence coherence);
  Future<CacheCoherence?> getCacheCoherenceById(String coherenceId);
  Future<CacheCoherence?> getLatestCoherence(String cacheId);
  Future<List<CacheCoherence>> getCoherenceHistory(String cacheId, int limit);
  Future<CacheCoherence> updateCacheCoherence(CacheCoherence coherence);
  Future<int> getCacheCoherenceCount();
  Future<List<CacheCoherence>> getInconsistentCaches();
  Future<bool> deleteOldCoherence(String cacheId, Duration olderThan);
}

// ============================================================================
// IN-MEMORY REPOSITORY IMPLEMENTATION
// ============================================================================

class InMemoryCachingRepository extends CachingRepository {
  final Map<String, CacheEntry> _cacheEntries = {};
  final Map<String, CacheConfiguration> _configurations = {};
  final Map<String, CacheStatistics> _statistics = {};
  final Map<String, MaterializedView> _materializedViews = {};
  final Map<String, QueryResultCache> _queryResults = {};
  final Map<String, CacheInvalidationTag> _invalidationTags = {};
  final Map<String, PrefetchStrategy> _prefetchStrategies = {};
  final Map<String, PerformanceMetric> _performanceMetrics = {};
  final Map<String, CacheWarmingStrategy> _warmingStrategies = {};
  final Map<String, CacheHierarchy> _hierarchies = {};
  final Map<String, CacheCoherence> _coherence = {};

  // ---- Cache Entry Management ----
  @override
  Future<CacheEntry> createCacheEntry(CacheEntry entry) async {
    _cacheEntries[entry.id] = entry;
    return entry;
  }

  @override
  Future<CacheEntry?> getCacheEntryById(String entryId) async =>
      _cacheEntries[entryId];

  @override
  Future<CacheEntry?> getCacheEntryByKey(String key) async {
    return _cacheEntries.values
        .firstWhere((e) => e.key == key, orElse: () => _cacheEntries.isEmpty ? null : _cacheEntries.values.first) as CacheEntry?;
  }

  @override
  Future<List<CacheEntry>> getAllCacheEntries(
      {int limit = 100, int offset = 0}) async {
    final all = _cacheEntries.values.toList();
    return all.skip(offset).take(limit).toList();
  }

  @override
  Future<List<CacheEntry>> getExpiredEntries() async {
    return _cacheEntries.values.where((e) => e.isExpired).toList();
  }

  @override
  Future<CacheEntry> updateCacheEntry(CacheEntry entry) async {
    _cacheEntries[entry.id] = entry;
    return entry;
  }

  @override
  Future<bool> deleteCacheEntry(String entryId) async =>
      _cacheEntries.remove(entryId) != null;

  @override
  Future<bool> deleteCacheEntryByKey(String key) async {
    final entry = _cacheEntries.values
        .firstWhere((e) => e.key == key, orElse: () => null as CacheEntry?);
    if (entry != null) {
      _cacheEntries.remove(entry.id);
      return true;
    }
    return false;
  }

  @override
  Future<int> getCacheEntryCount() async => _cacheEntries.length;

  @override
  Future<List<CacheEntry>> getEntriesByTag(String tag) async {
    return _cacheEntries.values.where((e) => e.tags.contains(tag)).toList();
  }

  @override
  Future<int> getTotalCacheSize() async {
    return _cacheEntries.values.fold<int>(0, (sum, e) => sum + e.size);
  }

  @override
  Future<List<CacheEntry>> searchCacheEntries(String keyPattern) async {
    return _cacheEntries.values
        .where((e) => e.key.contains(keyPattern))
        .toList();
  }

  // ---- Cache Configuration ----
  @override
  Future<CacheConfiguration> createConfiguration(
      CacheConfiguration config) async {
    _configurations[config.id] = config;
    return config;
  }

  @override
  Future<CacheConfiguration?> getConfigurationById(String configId) async =>
      _configurations[configId];

  @override
  Future<List<CacheConfiguration>> getAllConfigurations() async =>
      _configurations.values.toList();

  @override
  Future<List<CacheConfiguration>> getConfigurationsByType(
      CacheType type) async {
    return _configurations.values.where((c) => c.cacheType == type).toList();
  }

  @override
  Future<CacheConfiguration> updateConfiguration(
      CacheConfiguration config) async {
    _configurations[config.id] = config;
    return config;
  }

  @override
  Future<bool> deleteConfiguration(String configId) async =>
      _configurations.remove(configId) != null;

  @override
  Future<int> getConfigurationCount() async => _configurations.length;

  @override
  Future<List<CacheConfiguration>> searchConfigurations(
      String namePattern) async {
    return _configurations.values
        .where((c) => c.name.contains(namePattern))
        .toList();
  }

  @override
  Future<CacheConfiguration?> getDefaultConfiguration() async {
    return _configurations.values
        .firstWhere((c) => c.name == 'default', orElse: () => null as CacheConfiguration?);
  }

  @override
  Future<bool> setDefaultConfiguration(String configId) async {
    return _configurations.containsKey(configId);
  }

  // ---- Cache Statistics ----
  @override
  Future<CacheStatistics> recordStatistics(CacheStatistics stats) async {
    _statistics[stats.id] = stats;
    return stats;
  }

  @override
  Future<CacheStatistics?> getStatisticsById(String statsId) async =>
      _statistics[statsId];

  @override
  Future<CacheStatistics?> getLatestStatistics(String cacheId) async {
    return _statistics.values
        .where((s) => s.cacheId == cacheId)
        .fold<CacheStatistics?>(
            null,
            (latest, current) =>
                latest == null || current.timestamp.isAfter(latest.timestamp)
                    ? current
                    : latest);
  }

  @override
  Future<List<CacheStatistics>> getStatisticsHistory(
      String cacheId, int limit) async {
    final history = _statistics.values
        .where((s) => s.cacheId == cacheId)
        .toList();
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return history.take(limit).toList();
  }

  @override
  Future<List<CacheStatistics>> getStatisticsByTimeRange(
      String cacheId, DateTime start, DateTime end) async {
    return _statistics.values
        .where((s) =>
            s.cacheId == cacheId &&
            s.timestamp.isAfter(start) &&
            s.timestamp.isBefore(end))
        .toList();
  }

  @override
  Future<double> getAverageHitRate(String cacheId) async {
    final stats = _statistics.values.where((s) => s.cacheId == cacheId).toList();
    if (stats.isEmpty) return 0.0;
    return stats.fold<double>(0, (sum, s) => sum + s.hitRate) / stats.length;
  }

  @override
  Future<int> getTotalEvictions(String cacheId) async {
    return _statistics.values
        .where((s) => s.cacheId == cacheId)
        .fold<int>(0, (sum, s) => sum + s.totalEvictions);
  }

  @override
  Future<double> getAverageLatency(String cacheId) async {
    final stats = _statistics.values.where((s) => s.cacheId == cacheId).toList();
    if (stats.isEmpty) return 0.0;
    return stats.fold<double>(0, (sum, s) => sum + s.averageLatencyMs) /
        stats.length;
  }

  @override
  Future<List<CacheStatistics>> getHighMissRateStats() async {
    return _statistics.values.where((s) => s.isHighMissRate).toList();
  }

  @override
  Future<int> getStatisticsCount(String cacheId) async {
    return _statistics.values.where((s) => s.cacheId == cacheId).length;
  }

  @override
  Future<bool> deleteOldStatistics(String cacheId, Duration olderThan) async {
    final cutoff = DateTime.now().subtract(olderThan);
    final before = _statistics.length;
    _statistics.removeWhere((_, s) =>
        s.cacheId == cacheId && s.timestamp.isBefore(cutoff));
    return _statistics.length < before;
  }

  @override
  Future<List<CacheStatistics>> getRecentStatistics(
      String cacheId, int minutes) async {
    final cutoff = DateTime.now().subtract(Duration(minutes: minutes));
    return _statistics.values
        .where((s) => s.cacheId == cacheId && s.timestamp.isAfter(cutoff))
        .toList();
  }

  // ---- Materialized Views ----
  @override
  Future<MaterializedView> createMaterializedView(
      MaterializedView view) async {
    _materializedViews[view.id] = view;
    return view;
  }

  @override
  Future<MaterializedView?> getMaterializedViewById(String viewId) async =>
      _materializedViews[viewId];

  @override
  Future<List<MaterializedView>> getAllMaterializedViews() async =>
      _materializedViews.values.toList();

  @override
  Future<List<MaterializedView>> getViewsByStatus(
      MaterializedViewStatus status) async {
    return _materializedViews.values
        .where((v) => v.status == status)
        .toList();
  }

  @override
  Future<MaterializedView> updateMaterializedView(
      MaterializedView view) async {
    _materializedViews[view.id] = view;
    return view;
  }

  @override
  Future<bool> deleteMaterializedView(String viewId) async =>
      _materializedViews.remove(viewId) != null;

  @override
  Future<List<MaterializedView>> getViewsNeedingRefresh() async {
    return _materializedViews.values.where((v) => v.needsRefresh).toList();
  }

  @override
  Future<int> getMaterializedViewCount() async =>
      _materializedViews.length;

  @override
  Future<List<MaterializedView>> getLargestViews(int limit) async {
    final views = _materializedViews.values.toList();
    views.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
    return views.take(limit).toList();
  }

  @override
  Future<int> getTotalMaterializedViewSize() async {
    return _materializedViews.values
        .fold<int>(0, (sum, v) => sum + v.sizeBytes);
  }

  // ---- Query Result Caching ----
  @override
  Future<QueryResultCache> createQueryResultCache(
      QueryResultCache cache) async {
    _queryResults[cache.id] = cache;
    return cache;
  }

  @override
  Future<QueryResultCache?> getQueryResultByHash(String queryHash) async {
    return _queryResults.values.firstWhere((q) => q.queryHash == queryHash,
        orElse: () => null as QueryResultCache?);
  }

  @override
  Future<List<QueryResultCache>> getAllQueryResults(
      {int limit = 100, int offset = 0}) async {
    final all = _queryResults.values.toList();
    return all.skip(offset).take(limit).toList();
  }

  @override
  Future<List<QueryResultCache>> getExpiredQueryResults() async {
    return _queryResults.values.where((q) => q.isExpired).toList();
  }

  @override
  Future<QueryResultCache> updateQueryResultCache(
      QueryResultCache cache) async {
    _queryResults[cache.id] = cache;
    return cache;
  }

  @override
  Future<bool> deleteQueryResultCache(String cacheId) async =>
      _queryResults.remove(cacheId) != null;

  @override
  Future<List<QueryResultCache>> getHighAccessQueries(int limit) async {
    final queries = _queryResults.values.toList();
    queries.sort((a, b) => b.accessCount.compareTo(a.accessCount));
    return queries.take(limit).toList();
  }

  @override
  Future<int> getQueryResultCacheCount() async => _queryResults.length;

  @override
  Future<double> getAverageQueryReduction() async {
    if (_queryResults.isEmpty) return 0.0;
    return _queryResults.values.fold<double>(0, (sum, q) => sum + q.reductionPercent) /
        _queryResults.length;
  }

  @override
  Future<List<QueryResultCache>> searchQueryResults(
      String queryPattern) async {
    return _queryResults.values
        .where((q) => q.queryText.contains(queryPattern))
        .toList();
  }

  // ---- Cache Invalidation Tags ----
  @override
  Future<CacheInvalidationTag> createInvalidationTag(
      CacheInvalidationTag tag) async {
    _invalidationTags[tag.id] = tag;
    return tag;
  }

  @override
  Future<CacheInvalidationTag?> getInvalidationTagById(String tagId) async =>
      _invalidationTags[tagId];

  @override
  Future<CacheInvalidationTag?> getInvalidationTagByName(
      String tagName) async {
    return _invalidationTags.values.firstWhere((t) => t.tagName == tagName,
        orElse: () => null as CacheInvalidationTag?);
  }

  @override
  Future<List<CacheInvalidationTag>> getAllInvalidationTags() async =>
      _invalidationTags.values.toList();

  @override
  Future<CacheInvalidationTag> updateInvalidationTag(
      CacheInvalidationTag tag) async {
    _invalidationTags[tag.id] = tag;
    return tag;
  }

  @override
  Future<bool> deleteInvalidationTag(String tagId) async =>
      _invalidationTags.remove(tagId) != null;

  @override
  Future<int> getInvalidationTagCount() async => _invalidationTags.length;

  @override
  Future<List<CacheInvalidationTag>> getFrequentlyInvalidatedTags(
      int limit) async {
    final tags = _invalidationTags.values.toList();
    tags.sort((a, b) => b.entriesTagged.compareTo(a.entriesTagged));
    return tags.take(limit).toList();
  }

  // ---- Prefetch Strategies ----
  @override
  Future<PrefetchStrategy> createPrefetchStrategy(
      PrefetchStrategy strategy) async {
    _prefetchStrategies[strategy.id] = strategy;
    return strategy;
  }

  @override
  Future<PrefetchStrategy?> getPrefetchStrategyById(String strategyId) async =>
      _prefetchStrategies[strategyId];

  @override
  Future<List<PrefetchStrategy>> getAllPrefetchStrategies() async =>
      _prefetchStrategies.values.toList();

  @override
  Future<List<PrefetchStrategy>> getActivePrefetchStrategies() async {
    return _prefetchStrategies.values.where((s) => s.isActive).toList();
  }

  @override
  Future<PrefetchStrategy> updatePrefetchStrategy(
      PrefetchStrategy strategy) async {
    _prefetchStrategies[strategy.id] = strategy;
    return strategy;
  }

  @override
  Future<bool> deletePrefetchStrategy(String strategyId) async =>
      _prefetchStrategies.remove(strategyId) != null;

  @override
  Future<int> getPrefetchStrategyCount() async =>
      _prefetchStrategies.length;

  @override
  Future<List<PrefetchStrategy>> getStrategiesNeedingExecution() async {
    return _prefetchStrategies.values
        .where((s) => s.needsExecution)
        .toList();
  }

  // ---- Performance Metrics ----
  @override
  Future<PerformanceMetric> recordPerformanceMetric(
      PerformanceMetric metric) async {
    _performanceMetrics[metric.id] = metric;
    return metric;
  }

  @override
  Future<PerformanceMetric?> getPerformanceMetricById(String metricId) async =>
      _performanceMetrics[metricId];

  @override
  Future<List<PerformanceMetric>> getMetricsByType(
      PerformanceMetricType type) async {
    return _performanceMetrics.values.where((m) => m.metricType == type).toList();
  }

  @override
  Future<List<PerformanceMetric>> getRecentMetrics(
      PerformanceMetricType type, int limit) async {
    final metrics = _performanceMetrics.values
        .where((m) => m.metricType == type)
        .toList();
    metrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return metrics.take(limit).toList();
  }

  @override
  Future<List<PerformanceMetric>> getAnomalousMetrics() async {
    return _performanceMetrics.values.where((m) => m.isAnomaly).toList();
  }

  @override
  Future<double> getAverageMetricValue(PerformanceMetricType type) async {
    final metrics =
        _performanceMetrics.values.where((m) => m.metricType == type).toList();
    if (metrics.isEmpty) return 0.0;
    return metrics.fold<double>(0, (sum, m) => sum + m.value) / metrics.length;
  }

  @override
  Future<int> getPerformanceMetricCount() async =>
      _performanceMetrics.length;

  @override
  Future<List<PerformanceMetric>> getMetricsByTimeRange(
      DateTime start, DateTime end) async {
    return _performanceMetrics.values
        .where((m) =>
            m.timestamp.isAfter(start) && m.timestamp.isBefore(end))
        .toList();
  }

  @override
  Future<List<PerformanceMetric>> getCriticalMetrics() async {
    return _performanceMetrics.values.where((m) => m.isCritical).toList();
  }

  @override
  Future<bool> deleteOldMetrics(Duration olderThan) async {
    final cutoff = DateTime.now().subtract(olderThan);
    final before = _performanceMetrics.length;
    _performanceMetrics
        .removeWhere((_, m) => m.timestamp.isBefore(cutoff));
    return _performanceMetrics.length < before;
  }

  // ---- Cache Warming Strategies ----
  @override
  Future<CacheWarmingStrategy> createWarmingStrategy(
      CacheWarmingStrategy strategy) async {
    _warmingStrategies[strategy.id] = strategy;
    return strategy;
  }

  @override
  Future<CacheWarmingStrategy?> getWarmingStrategyById(
      String strategyId) async => _warmingStrategies[strategyId];

  @override
  Future<List<CacheWarmingStrategy>> getAllWarmingStrategies() async =>
      _warmingStrategies.values.toList();

  @override
  Future<List<CacheWarmingStrategy>> getEnabledWarmingStrategies() async {
    return _warmingStrategies.values.where((s) => s.enabled).toList();
  }

  @override
  Future<CacheWarmingStrategy> updateWarmingStrategy(
      CacheWarmingStrategy strategy) async {
    _warmingStrategies[strategy.id] = strategy;
    return strategy;
  }

  @override
  Future<bool> deleteWarmingStrategy(String strategyId) async =>
      _warmingStrategies.remove(strategyId) != null;

  @override
  Future<List<CacheWarmingStrategy>> getStrategiesNeedingExecution() async {
    return _warmingStrategies.values.where((s) => s.shouldExecute).toList();
  }

  @override
  Future<int> getWarmingStrategyCount() async => _warmingStrategies.length;

  // ---- Cache Hierarchy ----
  @override
  Future<CacheHierarchy> createCacheHierarchy(CacheHierarchy hierarchy) async {
    _hierarchies[hierarchy.id] = hierarchy;
    return hierarchy;
  }

  @override
  Future<CacheHierarchy?> getCacheHierarchyById(String hierarchyId) async =>
      _hierarchies[hierarchyId];

  @override
  Future<List<CacheHierarchy>> getAllCacheHierarchies() async =>
      _hierarchies.values.toList();

  @override
  Future<CacheHierarchy> updateCacheHierarchy(CacheHierarchy hierarchy) async {
    _hierarchies[hierarchy.id] = hierarchy;
    return hierarchy;
  }

  @override
  Future<bool> deleteCacheHierarchy(String hierarchyId) async =>
      _hierarchies.remove(hierarchyId) != null;

  @override
  Future<List<CacheHierarchy>> getMultiLevelHierarchies() async {
    return _hierarchies.values.where((h) => h.isMultiLevel).toList();
  }

  @override
  Future<int> getCacheHierarchyCount() async => _hierarchies.length;

  @override
  Future<CacheHierarchy?> getDefaultHierarchy() async {
    return _hierarchies.values.firstWhere((h) => h.name == 'default',
        orElse: () => null as CacheHierarchy?);
  }

  // ---- Cache Coherence ----
  @override
  Future<CacheCoherence> recordCacheCoherence(
      CacheCoherence coherence) async {
    _coherence[coherence.id] = coherence;
    return coherence;
  }

  @override
  Future<CacheCoherence?> getCacheCoherenceById(String coherenceId) async =>
      _coherence[coherenceId];

  @override
  Future<CacheCoherence?> getLatestCoherence(String cacheId) async {
    return _coherence.values
        .where((c) => c.cacheId == cacheId)
        .fold<CacheCoherence?>(
            null,
            (latest, current) =>
                latest == null ||
                    current.lastSyncAt.isAfter(latest.lastSyncAt)
                    ? current
                    : latest);
  }

  @override
  Future<List<CacheCoherence>> getCoherenceHistory(String cacheId, int limit) async {
    final history = _coherence.values
        .where((c) => c.cacheId == cacheId)
        .toList();
    history.sort((a, b) => b.lastSyncAt.compareTo(a.lastSyncAt));
    return history.take(limit).toList();
  }

  @override
  Future<CacheCoherence> updateCacheCoherence(CacheCoherence coherence) async {
    _coherence[coherence.id] = coherence;
    return coherence;
  }

  @override
  Future<int> getCacheCoherenceCount() async => _coherence.length;

  @override
  Future<List<CacheCoherence>> getInconsistentCaches() async {
    return _coherence.values.where((c) => !c.isConsistent).toList();
  }

  @override
  Future<bool> deleteOldCoherence(String cacheId, Duration olderThan) async {
    final cutoff = DateTime.now().subtract(olderThan);
    final before = _coherence.length;
    _coherence.removeWhere((_, c) =>
        c.cacheId == cacheId && c.lastSyncAt.isBefore(cutoff));
    return _coherence.length < before;
  }
}

// ============================================================================
// ENGINES (5 total)
// ============================================================================

class CacheEvictionEngine {
  final CachingRepository repository;

  CacheEvictionEngine(this.repository);

  Future<void> evictExpiredEntries() async {
    final expired = await repository.getExpiredEntries();
    for (final entry in expired) {
      await repository.deleteCacheEntry(entry.id);
    }
  }

  Future<int> getEvictionCount() async {
    final all = await repository.getAllCacheEntries();
    return all.where((e) => e.isExpired).length;
  }
}

class MaterializedViewEngine {
  final CachingRepository repository;

  MaterializedViewEngine(this.repository);

  Future<void> refreshStaleViews() async {
    final stale = await repository.getViewsNeedingRefresh();
    for (final view in stale) {
      await repository.updateMaterializedView(
        view.copyWith(status: MaterializedViewStatus.refreshing),
      );
    }
  }

  Future<int> getRefreshableViewCount() async {
    return (await repository.getViewsNeedingRefresh()).length;
  }
}

class QueryCachingEngine {
  final CachingRepository repository;

  QueryCachingEngine(this.repository);

  Future<void> removeStaleQueryResults() async {
    final expired = await repository.getExpiredQueryResults();
    for (final cache in expired) {
      await repository.deleteQueryResultCache(cache.id);
    }
  }

  Future<double> calculateAverageQueryReduction() async {
    return await repository.getAverageQueryReduction();
  }
}

class PrefetchEngine {
  final CachingRepository repository;

  PrefetchEngine(this.repository);

  Future<void> executePendingPrefetch() async {
    final pending = await repository.getStrategiesNeedingExecution();
    for (final strategy in pending) {
      await repository.updatePrefetchStrategy(
        strategy.copyWith(lastExecutedAt: DateTime.now()),
      );
    }
  }

  Future<int> getPendingPrefetchCount() async {
    return (await repository.getStrategiesNeedingExecution()).length;
  }
}

class CacheWarmingEngine {
  final CachingRepository repository;

  CacheWarmingEngine(this.repository);

  Future<void> executeWarmingStrategies() async {
    final pending = await repository.getStrategiesNeedingExecution();
    for (final strategy in pending) {
      await repository.updateWarmingStrategy(
        strategy.copyWith(lastWarmingAt: DateTime.now()),
      );
    }
  }

  Future<int> getActiveWarmingCount() async {
    return (await repository.getEnabledWarmingStrategies()).length;
  }
}

// ============================================================================
// MANAGER
// ============================================================================

class CachingManager {
  final CachingRepository repository;
  late final CacheEvictionEngine evictionEngine;
  late final MaterializedViewEngine viewEngine;
  late final QueryCachingEngine queryCachingEngine;
  late final PrefetchEngine prefetchEngine;
  late final CacheWarmingEngine warmingEngine;

  CachingManager(this.repository) {
    evictionEngine = CacheEvictionEngine(repository);
    viewEngine = MaterializedViewEngine(repository);
    queryCachingEngine = QueryCachingEngine(repository);
    prefetchEngine = PrefetchEngine(repository);
    warmingEngine = CacheWarmingEngine(repository);
  }
}

// ============================================================================
// FACADE
// ============================================================================

class CachingFacade {
  final CachingManager manager;

  CachingFacade(this.manager);

  Future<CacheEntry> createCacheEntry(String key, String value,
      {int ttlSeconds = 3600, List<String> tags = const []}) async {
    final entry = CacheEntry(
      id: 'ce_${DateTime.now().millisecondsSinceEpoch}',
      key: key,
      value: value,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(seconds: ttlSeconds)),
      tags: tags,
    );
    return await manager.repository.createCacheEntry(entry);
  }

  Future<CacheEntry?> getCacheEntry(String key) async {
    return await manager.repository.getCacheEntryByKey(key);
  }

  Future<CacheConfiguration> createConfiguration(String name, CacheType type) async {
    final config = CacheConfiguration(
      id: 'cc_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      cacheType: type,
      createdAt: DateTime.now(),
    );
    return await manager.repository.createConfiguration(config);
  }

  Future<MaterializedView> createMaterializedView(
      String name, String queryDefinition) async {
    final view = MaterializedView(
      id: 'mv_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      queryDefinition: queryDefinition,
      createdAt: DateTime.now(),
      lastRefreshedAt: DateTime.now(),
    );
    return await manager.repository.createMaterializedView(view);
  }

  Future<QueryResultCache> cacheQueryResult(
      String queryText, String result) async {
    final cache = QueryResultCache(
      id: 'qr_${DateTime.now().millisecondsSinceEpoch}',
      queryHash: queryText.hashCode.toString(),
      queryText: queryText,
      result: result,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(hours: 1)),
    );
    return await manager.repository.createQueryResultCache(cache);
  }

  Future<int> getActiveCacheCount() async {
    return await manager.repository.getCacheEntryCount();
  }

  Future<int> getTotalCacheSize() async {
    return await manager.repository.getTotalCacheSize();
  }

  Future<double> getAverageHitRate(String cacheId) async {
    return await manager.repository.getAverageHitRate(cacheId);
  }

  Future<List<MaterializedView>> getViewsNeedingRefresh() async {
    return await manager.repository.getViewsNeedingRefresh();
  }

  Future<PerformanceMetric> recordMetric(
      PerformanceMetricType type, double value) async {
    final metric = PerformanceMetric(
      id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
      metricType: type,
      value: value,
      timestamp: DateTime.now(),
    );
    return await manager.repository.recordPerformanceMetric(metric);
  }

  Future<int> getHighMissRateCount() async {
    final stats = await manager.repository.getHighMissRateStats();
    return stats.length;
  }

  Future<CacheCoherence> recordCoherence(String cacheId) async {
    final coherence = CacheCoherence(
      id: 'cc_${DateTime.now().millisecondsSinceEpoch}',
      cacheId: cacheId,
      lastSyncAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
    return await manager.repository.recordCacheCoherence(coherence);
  }
}
