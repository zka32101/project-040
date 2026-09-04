/// Phase 26: 検索結果ページ
/// 検索結果の表示と管理

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_export_model.dart';
import '../models/async_job_model.dart';
import '../providers/search_provider.dart';

/// 検索結果ページ
class SearchResultsPage extends ConsumerStatefulWidget {
  const SearchResultsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResult = ref.watch(searchResultProvider);
    final isSearching = ref.watch(isSearchingProvider);
    final resultCount = ref.watch(searchResultCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('検索'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSearchBar(),
          ),

          // 検索フィルター
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildFilterRow(),
          ),

          // 結果数表示
          if (!isSearching)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    '検索結果: $resultCount 件',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),

          // 検索結果
          Expanded(
            child: isSearching
                ? const Center(child: CircularProgressIndicator())
                : searchResult.when(
                    data: (result) {
                      if (result == null || result.results.isEmpty) {
                        return Center(
                          child: Text(
                            result == null
                                ? '検索を実行してください'
                                : '結果がありません',
                            style:
                                Theme.of(context).textTheme.titleMedium,
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: result.results.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 8),
                        itemBuilder: (context, index) {
                          final job = result.results[index];
                          return _buildSearchResultItem(job);
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (err, stack) => Center(
                      child: Text('エラー: $err'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SearchBar(
      controller: _searchController,
      hintText: 'ジョブを検索...',
      leading: const Icon(Icons.search),
      onSubmitted: (query) {
        if (query.isNotEmpty) {
          final searchOps = SearchOperations(ref);
          searchOps.executeSearch(
            SearchQuery(
              queryId: 'query_${DateTime.now().millisecondsSinceEpoch}',
              text: query,
              filter: ref.read(searchFilterProvider),
              sort: ref.read(searchSortProvider),
            ),
          );
        }
      },
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showFilterDialog(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.filter_list, size: 20),
                  SizedBox(width: 8),
                  Text('フィルター'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _showSortDialog(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.sort, size: 20),
                SizedBox(width: 8),
                Text('ソート'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultItem(AsyncJob job) {
    return ListTile(
      title: Text(job.jobId),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            job.jobType.toString().split('.').last,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            job.status.toString().split('.').last,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      trailing: Text(
        '${job.progressPercent.toStringAsFixed(0)}%',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onTap: () => _showJobDetails(job),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('フィルター設定'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ジョブタイプ、ステータス、日付範囲でフィルター'),
            // フィルター UI の実装
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('適用'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ソート設定'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('作成日時、関連性、ステータスでソート'),
            // ソート UI の実装
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('適用'),
          ),
        ],
      ),
    );
  }

  void _showJobDetails(AsyncJob job) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ジョブ詳細',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildDetailRow('ジョブ ID', job.jobId),
            _buildDetailRow('ユーザー ID', job.userId),
            _buildDetailRow(
              'ジョブタイプ',
              job.jobType.toString().split('.').last,
            ),
            _buildDetailRow(
              'ステータス',
              job.status.toString().split('.').last,
            ),
            _buildDetailRow('進捗', '${job.progressPercent.toStringAsFixed(0)}%'),
            _buildDetailRow('作成日時', job.createdAt.toString()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('閉じる'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
