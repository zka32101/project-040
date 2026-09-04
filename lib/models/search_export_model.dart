/// Phase 25: 高度な検索・ファイルエクスポート
/// フルテキスト検索、検索履歴、CSV/PDF エクスポート

import 'async_job_model.dart';

/// 検索クエリ
class SearchQuery {
  /// クエリ ID
  final String queryId;

  /// テキスト
  final String text;

  /// フィルター
  final SearchFilter filter;

  /// ソート
  final SearchSort sort;

  /// 作成日時
  final DateTime createdAt;

  /// 最終実行日時
  DateTime? lastExecutedAt;

  SearchQuery({
    required this.queryId,
    required this.text,
    SearchFilter? filter,
    SearchSort? sort,
    DateTime? createdAt,
    this.lastExecutedAt,
  })  : filter = filter ?? const SearchFilter(),
        sort = sort ?? const SearchSort(),
        createdAt = createdAt ?? DateTime.now();

  /// JSON に変換
  Map<String, dynamic> toJson() => {
        'queryId': queryId,
        'text': text,
        'filter': filter.toJson(),
        'sort': sort.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'lastExecutedAt': lastExecutedAt?.toIso8601String(),
      };
}

/// 検索フィルター
class SearchFilter {
  /// ジョブタイプ
  final List<AsyncJobType>? jobTypes;

  /// ステータス
  final List<AsyncJobStatus>? statuses;

  /// 日付範囲
  final DateRange? dateRange;

  /// ユーザー ID
  final String? userId;

  const SearchFilter({
    this.jobTypes,
    this.statuses,
    this.dateRange,
    this.userId,
  });

  /// JSON に変換
  Map<String, dynamic> toJson() => {
        'jobTypes': jobTypes?.map((j) => j.toString().split('.').last).toList(),
        'statuses': statuses?.map((s) => s.toString().split('.').last).toList(),
        'dateRange': dateRange != null
            ? {
                'startDate': dateRange!.startDate.toIso8601String(),
                'endDate': dateRange!.endDate.toIso8601String(),
              }
            : null,
        'userId': userId,
      };

  /// コピー
  SearchFilter copyWith({
    List<AsyncJobType>? jobTypes,
    List<AsyncJobStatus>? statuses,
    DateRange? dateRange,
    String? userId,
  }) {
    return SearchFilter(
      jobTypes: jobTypes ?? this.jobTypes,
      statuses: statuses ?? this.statuses,
      dateRange: dateRange ?? this.dateRange,
      userId: userId ?? this.userId,
    );
  }
}

/// 検索結果
class SearchResult {
  /// 検索クエリ
  final SearchQuery query;

  /// マッチしたジョブ
  final List<AsyncJob> results;

  /// 全マッチ数
  final int totalMatches;

  /// 検索実行時間（ミリ秒）
  final int executionTimeMs;

  /// 検索実行時刻
  final DateTime executedAt;

  const SearchResult({
    required this.query,
    required this.results,
    required this.totalMatches,
    required this.executionTimeMs,
    required this.executedAt,
  });

  /// JSON に変換
  Map<String, dynamic> toJson() => {
        'query': query.toJson(),
        'totalMatches': totalMatches,
        'resultCount': results.length,
        'executionTimeMs': executionTimeMs,
        'executedAt': executedAt.toIso8601String(),
      };
}

/// 検索ソート
class SearchSort {
  /// ソートフィールド
  final SearchSortField field;

  /// ソート順（asc/desc）
  final String order;

  const SearchSort({
    this.field = SearchSortField.createdAt,
    this.order = 'desc',
  });

  /// JSON に変換
  Map<String, dynamic> toJson() => {
        'field': field.toString().split('.').last,
        'order': order,
      };
}

/// 検索ソートフィールド
enum SearchSortField {
  /// 作成日時
  createdAt,

  /// 関連性スコア
  relevanceScore,

  /// ジョブタイプ
  jobType,

  /// ステータス
  status,

  /// 実行時間
  executionTime,
}

/// 検索履歴エントリ
class SearchHistoryEntry {
  /// エントリ ID
  final String entryId;

  /// クエリテキスト
  final String queryText;

  /// マッチ数
  final int matchCount;

  /// 実行日時
  final DateTime executedAt;

  /// ユーザー ID
  final String userId;

  const SearchHistoryEntry({
    required this.entryId,
    required this.queryText,
    required this.matchCount,
    required this.executedAt,
    required this.userId,
  });

  /// JSON に変換
  Map<String, dynamic> toJson() => {
        'entryId': entryId,
        'queryText': queryText,
        'matchCount': matchCount,
        'executedAt': executedAt.toIso8601String(),
        'userId': userId,
      };
}

/// 検索履歴
class SearchHistory {
  /// エントリリスト
  final List<SearchHistoryEntry> entries;

  /// 最大保持数
  final int maxEntries;

  SearchHistory({
    this.entries = const [],
    this.maxEntries = 100,
  });

  /// エントリを追加
  void addEntry(SearchHistoryEntry entry) {
    entries.insert(0, entry);
    if (entries.length > maxEntries) {
      entries.removeRange(maxEntries, entries.length);
    }
  }

  /// 重複するクエリを削除
  void removeDuplicates() {
    final seen = <String>{};
    entries.removeWhere((entry) => !seen.add(entry.queryText));
  }
}

/// ファイルエクスポート設定
class ExportConfig {
  /// エクスポートフォーマット
  final ExportFormat format;

  /// 含めるフィールド
  final List<String> fields;

  /// 日付フォーマット
  final String dateFormat;

  /// エンコーディング
  final String encoding;

  /// ヘッダー行を含める
  final bool includeHeaders;

  /// 圧縮
  final bool compressed;

  const ExportConfig({
    required this.format,
    this.fields = const [
      'jobId',
      'userId',
      'jobType',
      'status',
      'createdAt',
      'completedAt',
      'progressPercent',
    ],
    this.dateFormat = 'yyyy-MM-dd HH:mm:ss',
    this.encoding = 'utf-8',
    this.includeHeaders = true,
    this.compressed = false,
  });

  /// JSON に変換
  Map<String, dynamic> toJson() => {
        'format': format.toString().split('.').last,
        'fields': fields,
        'dateFormat': dateFormat,
        'encoding': encoding,
        'includeHeaders': includeHeaders,
        'compressed': compressed,
      };

  /// コピー
  ExportConfig copyWith({
    ExportFormat? format,
    List<String>? fields,
    String? dateFormat,
    String? encoding,
    bool? includeHeaders,
    bool? compressed,
  }) {
    return ExportConfig(
      format: format ?? this.format,
      fields: fields ?? this.fields,
      dateFormat: dateFormat ?? this.dateFormat,
      encoding: encoding ?? this.encoding,
      includeHeaders: includeHeaders ?? this.includeHeaders,
      compressed: compressed ?? this.compressed,
    );
  }
}

/// エクスポートフォーマット
enum ExportFormat {
  /// CSV
  csv,

  /// JSON
  json,

  /// PDF
  pdf,

  /// Excel
  excel,

  /// XML
  xml,
}

/// エクスポート結果
class ExportResult {
  /// エクスポート ID
  final String exportId;

  /// ファイル名
  final String fileName;

  /// ファイルサイズ（バイト）
  final int fileSizeBytes;

  /// ジョブ数
  final int jobCount;

  /// エクスポート状態
  final ExportStatus status;

  /// 完了日時
  DateTime? completedAt;

  /// エラーメッセージ
  String? errorMessage;

  /// ダウンロード URL
  String? downloadUrl;

  ExportResult({
    required this.exportId,
    required this.fileName,
    required this.fileSizeBytes,
    required this.jobCount,
    this.status = ExportStatus.pending,
    this.completedAt,
    this.errorMessage,
    this.downloadUrl,
  });

  /// JSON に変換
  Map<String, dynamic> toJson() => {
        'exportId': exportId,
        'fileName': fileName,
        'fileSizeBytes': fileSizeBytes,
        'jobCount': jobCount,
        'status': status.toString().split('.').last,
        'completedAt': completedAt?.toIso8601String(),
        'errorMessage': errorMessage,
        'downloadUrl': downloadUrl,
      };
}

/// エクスポート状態
enum ExportStatus {
  /// 待機中
  pending,

  /// 処理中
  processing,

  /// 完了
  completed,

  /// 失敗
  failed,

  /// キャンセル
  cancelled,
}

/// 日付範囲（再定義）
class DateRange {
  /// 開始日時
  final DateTime startDate;

  /// 終了日時
  final DateTime endDate;

  const DateRange({
    required this.startDate,
    required this.endDate,
  });

  /// 日数
  int get days => endDate.difference(startDate).inDays;

  /// コピー
  DateRange copyWith({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DateRange(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
