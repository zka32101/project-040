/// Phase 25: 検索・エクスポートサービス
/// フルテキスト検索、検索履歴管理、ファイルエクスポート

import '../models/async_job_model.dart';
import '../models/search_export_model.dart';

/// 検索サービス抽象インターフェース
abstract class SearchService {
  /// フルテキスト検索
  Future<SearchResult> search(SearchQuery query);

  /// 検索履歴を追加
  Future<void> addToHistory(SearchHistoryEntry entry);

  /// 検索履歴を取得
  Future<List<SearchHistoryEntry>> getSearchHistory(String userId);

  /// 検索をクリア
  Future<void> clearSearchHistory(String userId);

  /// 保存された検索を取得
  Future<List<SearchQuery>> getSavedSearches(String userId);

  /// 検索を保存
  Future<void> saveSearch(SearchQuery query, String userId);

  /// 検索を削除
  Future<void> deleteSearch(String queryId, String userId);
}

/// メモリ検索サービス実装
class MemorySearchService implements SearchService {
  /// インデックス
  final Map<String, List<AsyncJob>> _index = {};

  /// 検索履歴
  final Map<String, List<SearchHistoryEntry>> _searchHistory = {};

  /// 保存された検索
  final Map<String, List<SearchQuery>> _savedSearches = {};

  @override
  Future<SearchResult> search(SearchQuery query) async {
    final stopwatch = Stopwatch()..start();

    // テキスト検索
    final results = _performTextSearch(query.text);

    // フィルター適用
    var filtered = _applyFilter(results, query.filter);

    // ソート適用
    filtered = _applySort(filtered, query.sort);

    stopwatch.stop();

    return SearchResult(
      query: query,
      results: filtered,
      totalMatches: filtered.length,
      executionTimeMs: stopwatch.elapsedMilliseconds,
      executedAt: DateTime.now(),
    );
  }

  @override
  Future<void> addToHistory(SearchHistoryEntry entry) async {
    if (!_searchHistory.containsKey(entry.userId)) {
      _searchHistory[entry.userId] = [];
    }
    _searchHistory[entry.userId]!.insert(0, entry);
  }

  @override
  Future<List<SearchHistoryEntry>> getSearchHistory(String userId) async {
    return _searchHistory[userId] ?? [];
  }

  @override
  Future<void> clearSearchHistory(String userId) async {
    _searchHistory[userId] = [];
  }

  @override
  Future<List<SearchQuery>> getSavedSearches(String userId) async {
    return _savedSearches[userId] ?? [];
  }

  @override
  Future<void> saveSearch(SearchQuery query, String userId) async {
    if (!_savedSearches.containsKey(userId)) {
      _savedSearches[userId] = [];
    }
    _savedSearches[userId]!.add(query);
  }

  @override
  Future<void> deleteSearch(String queryId, String userId) async {
    if (_savedSearches.containsKey(userId)) {
      _savedSearches[userId]!.removeWhere((q) => q.queryId == queryId);
    }
  }

  /// テキスト検索を実行
  List<AsyncJob> _performTextSearch(String query) {
    // メモリ内検索（実装簡略化）
    return [];
  }

  /// フィルターを適用
  List<AsyncJob> _applyFilter(List<AsyncJob> jobs, SearchFilter filter) {
    var filtered = jobs;

    if (filter.jobTypes != null) {
      filtered = filtered.where((j) => filter.jobTypes!.contains(j.jobType)).toList();
    }

    if (filter.statuses != null) {
      filtered = filtered.where((j) => filter.statuses!.contains(j.status)).toList();
    }

    if (filter.userId != null) {
      filtered = filtered.where((j) => j.userId == filter.userId).toList();
    }

    return filtered;
  }

  /// ソートを適用
  List<AsyncJob> _applySort(List<AsyncJob> jobs, SearchSort sort) {
    final sorted = List<AsyncJob>.from(jobs);

    switch (sort.field) {
      case SearchSortField.createdAt:
        sorted.sort((a, b) => sort.order == 'asc'
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      case SearchSortField.status:
        sorted.sort((a, b) => sort.order == 'asc'
            ? a.status.index.compareTo(b.status.index)
            : b.status.index.compareTo(a.status.index));
        break;
      default:
        break;
    }

    return sorted;
  }
}

/// ファイルエクスポートサービス抽象インターフェース
abstract class FileExportService {
  /// ジョブをエクスポート
  Future<ExportResult> exportJobs(
    List<AsyncJob> jobs,
    ExportConfig config,
  );

  /// エクスポート状態を取得
  Future<ExportResult?> getExportStatus(String exportId);

  /// エクスポートをキャンセル
  Future<void> cancelExport(String exportId);

  /// エクスポート結果をダウンロード
  Future<List<int>> downloadExport(String exportId);
}

/// メモリファイルエクスポートサービス実装
class MemoryFileExportService implements FileExportService {
  /// エクスポート結果
  final Map<String, ExportResult> _exports = {};

  /// エクスポート内容
  final Map<String, List<int>> _exportContents = {};

  @override
  Future<ExportResult> exportJobs(
    List<AsyncJob> jobs,
    ExportConfig config,
  ) async {
    final exportId = 'export_${DateTime.now().millisecondsSinceEpoch}';
    final fileName = 'jobs_${DateTime.now().toIso8601String().replaceAll(':', '-')}.${_getFileExtension(config.format)}';

    // ファイル内容を生成（簡略化）
    final content = _generateExportContent(jobs, config);

    final result = ExportResult(
      exportId: exportId,
      fileName: fileName,
      fileSizeBytes: content.length,
      jobCount: jobs.length,
      status: ExportStatus.completed,
      completedAt: DateTime.now(),
      downloadUrl: 'https://example.com/exports/$exportId',
    );

    _exports[exportId] = result;
    _exportContents[exportId] = content;

    return result;
  }

  @override
  Future<ExportResult?> getExportStatus(String exportId) async {
    return _exports[exportId];
  }

  @override
  Future<void> cancelExport(String exportId) async {
    if (_exports.containsKey(exportId)) {
      _exports[exportId] = _exports[exportId]!.copyWith(
        status: ExportStatus.cancelled,
        completedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<List<int>> downloadExport(String exportId) async {
    return _exportContents[exportId] ?? [];
  }

  /// ファイル拡張子を取得
  String _getFileExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.json:
        return 'json';
      case ExportFormat.pdf:
        return 'pdf';
      case ExportFormat.excel:
        return 'xlsx';
      case ExportFormat.xml:
        return 'xml';
    }
  }

  /// エクスポート内容を生成
  List<int> _generateExportContent(List<AsyncJob> jobs, ExportConfig config) {
    final buffer = StringBuffer();

    switch (config.format) {
      case ExportFormat.csv:
        if (config.includeHeaders) {
          buffer.writeln(config.fields.join(','));
        }
        for (final job in jobs) {
          buffer.writeln(_jobToCSVLine(job, config.fields));
        }
        break;
      case ExportFormat.json:
        buffer.write('[');
        buffer.write(jobs.map((j) => j.toJson()).join(','));
        buffer.write(']');
        break;
      default:
        break;
    }

    return buffer.toString().codeUnits;
  }

  /// ジョブを CSV 行に変換
  String _jobToCSVLine(AsyncJob job, List<String> fields) {
    return fields.map((field) {
      switch (field) {
        case 'jobId':
          return job.jobId;
        case 'userId':
          return job.userId;
        case 'jobType':
          return job.jobType.toString().split('.').last;
        case 'status':
          return job.status.toString().split('.').last;
        case 'createdAt':
          return job.createdAt.toIso8601String();
        case 'completedAt':
          return job.completedAt?.toIso8601String() ?? '';
        case 'progressPercent':
          return job.progressPercent.toString();
        default:
          return '';
      }
    }).join(',');
  }
}

/// ExportResult の拡張メソッド
extension ExportResultExtension on ExportResult {
  /// コピー
  ExportResult copyWith({
    String? exportId,
    String? fileName,
    int? fileSizeBytes,
    int? jobCount,
    ExportStatus? status,
    DateTime? completedAt,
    String? errorMessage,
    String? downloadUrl,
  }) {
    return ExportResult(
      exportId: exportId ?? this.exportId,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      jobCount: jobCount ?? this.jobCount,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }
}
