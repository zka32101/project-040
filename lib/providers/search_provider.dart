/// Phase 26: 検索プロバイダー
/// Riverpod を使用した検索機能の状態管理

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_export_model.dart';
import '../models/async_job_model.dart';
import '../services/search_export_service.dart';

/// 検索サービスプロバイダー
final searchServiceProvider = Provider<SearchService>((ref) {
  return MemorySearchService();
});

/// 現在の検索クエリプロバイダー
final currentSearchQueryProvider = StateProvider<SearchQuery?>((ref) => null);

/// 検索結果プロバイダー
final searchResultProvider = FutureProvider<SearchResult?>((ref) async {
  final query = ref.watch(currentSearchQueryProvider);
  if (query == null) return null;

  final service = ref.watch(searchServiceProvider);
  return service.search(query);
});

/// 検索フィルタープロバイダー
final searchFilterProvider = StateProvider<SearchFilter>((ref) {
  return const SearchFilter();
});

/// 検索ソートプロバイダー
final searchSortProvider = StateProvider<SearchSort>((ref) {
  return const SearchSort();
});

/// 検索履歴プロバイダー
final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<SearchHistoryEntry>>(
  (ref) => SearchHistoryNotifier(ref.watch(searchServiceProvider)),
);

/// ユーザー検索履歴プロバイダー
final userSearchHistoryProvider =
    FutureProvider.family<List<SearchHistoryEntry>, String>((ref, userId) async {
  final service = ref.watch(searchServiceProvider);
  return service.getSearchHistory(userId);
});

/// 保存された検索リストプロバイダー
final savedSearchesProvider =
    FutureProvider.family<List<SearchQuery>, String>((ref, userId) async {
  final service = ref.watch(searchServiceProvider);
  return service.getSavedSearches(userId);
});

/// 検索中フラグプロバイダー
final isSearchingProvider = StateProvider<bool>((ref) => false);

/// 検索実行時間プロバイダー
final lastSearchTimeProvider = StateProvider<DateTime?>((ref) => null);

/// 検索結果数プロバイダー
final searchResultCountProvider = StateProvider<int>((ref) => 0);

/// 検索履歴状態管理クラス
class SearchHistoryNotifier extends StateNotifier<List<SearchHistoryEntry>> {
  final SearchService _service;

  SearchHistoryNotifier(this._service) : super([]);

  /// 検索履歴に追加
  Future<void> addEntry(SearchHistoryEntry entry) async {
    await _service.addToHistory(entry);
    state = [...state, entry];
  }

  /// ユーザー履歴を読み込み
  Future<void> loadUserHistory(String userId) async {
    final history = await _service.getSearchHistory(userId);
    state = history;
  }

  /// 履歴をクリア
  Future<void> clearHistory(String userId) async {
    await _service.clearSearchHistory(userId);
    state = [];
  }

  /// 重複を削除
  void removeDuplicates() {
    final seen = <String>{};
    state = state.where((entry) => seen.add(entry.queryText)).toList();
  }
}

/// 検索操作ヘルパー
class SearchOperations {
  final Ref ref;

  SearchOperations(this.ref);

  /// 検索を実行
  Future<void> executeSearch(SearchQuery query) async {
    ref.read(isSearchingProvider.notifier).state = true;
    ref.read(currentSearchQueryProvider.notifier).state = query;

    try {
      // 検索実行（FutureProvider が自動的に処理）
      final result = await ref.watch(searchResultProvider.future);

      if (result != null) {
        ref.read(searchResultCountProvider.notifier).state = result.totalMatches;
        ref.read(lastSearchTimeProvider.notifier).state = DateTime.now();

        // 履歴に追加
        await ref.read(searchHistoryProvider.notifier).addEntry(
          SearchHistoryEntry(
            entryId: 'entry_${DateTime.now().millisecondsSinceEpoch}',
            queryText: query.text,
            matchCount: result.totalMatches,
            executedAt: DateTime.now(),
            userId: 'user_1', // 実装時に実際のユーザーID使用
          ),
        );
      }
    } finally {
      ref.read(isSearchingProvider.notifier).state = false;
    }
  }

  /// フィルターを更新
  void updateFilter(SearchFilter filter) {
    ref.read(searchFilterProvider.notifier).state = filter;
  }

  /// ソートを更新
  void updateSort(SearchSort sort) {
    ref.read(searchSortProvider.notifier).state = sort;
  }

  /// 検索を保存
  Future<void> saveSearch(SearchQuery query, String userId) async {
    final service = ref.read(searchServiceProvider);
    await service.saveSearch(query, userId);
  }

  /// 検索を削除
  Future<void> deleteSearch(String queryId, String userId) async {
    final service = ref.read(searchServiceProvider);
    await service.deleteSearch(queryId, userId);
  }
}
