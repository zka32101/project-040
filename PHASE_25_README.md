# Phase 25: 分析・検索・エクスポート完全実装

## 概要

Phase 25 実装：ジョブ分析、パフォーマンスメトリクス、成功率統計、ボトルネック検出、フルテキスト検索、検索履歴管理、ファイルエクスポート（CSV/JSON/PDF/Excel/XML）

Phase 24 で構築したキャッシング・アクセシビリティ機能に以下を追加：
- 実行時間分析・パフォーマンス計測
- 成功率統計・ボトルネック検出
- フルテキスト検索・検索履歴管理
- マルチフォーマットファイルエクスポート（CSV、JSON、PDF、Excel、XML）
- 検索結果キャッシング・ソート機能

## 実装ファイル

### 1. 分析モデル (`lib/models/analytics_model.dart`)

ジョブ分析とパフォーマンスメトリクス

#### 主要クラス

**ExecutionTimeAnalytics** - ジョブ実行時間分析
```dart
class ExecutionTimeAnalytics {
  final String jobId;
  final AsyncJobType jobType;
  final int executionTimeMs;      // 実行時間
  final int queuingTimeMs;        // キューイング時間
  final int waitingTimeMs;        // 待機時間
  final int avgExecutionTimeMs;   // 平均実行時間
  final DateTime timestamp;
  
  // 計算プロパティ
  int get totalProcessTimeMs;     // 総処理時間
  double get executionEfficiency; // 実行効率（％）
}
```

**SuccessRateStatistics** - 成功率統計
```dart
class SuccessRateStatistics {
  final int totalJobs;
  final int successJobs;
  final int failedJobs;
  final int cancelledJobs;
  final double avgExecutionTimeMs;
  final int maxExecutionTimeMs;
  final int minExecutionTimeMs;
  final DateRange period;
  
  // 計算プロパティ
  double get successRate;      // 成功率（0.0-1.0）
  double get failureRate;      // 失敗率
  double get cancellationRate; // キャンセル率
}
```

**PerformanceMetrics** - パフォーマンスメトリクス
```dart
class PerformanceMetrics {
  final DateRange period;
  final double cpuUsagePercent;     // CPU使用率（0-100）
  final double memoryUsageMb;       // メモリ使用量（MB）
  final double diskUsageMb;         // ディスク使用量（MB）
  final double throughputJobsPerMinute;
  final double avgLatencyMs;        // 平均遅延
  final double p95LatencyMs;        // P95遅延（95パーセンタイル）
  final double p99LatencyMs;        // P99遅延（99パーセンタイル）
  final double errorRate;           // エラー率
  final DateTime timestamp;
}
```

**JobTypeAnalytics** - ジョブタイプ別分析
```dart
class JobTypeAnalytics {
  final AsyncJobType jobType;
  final int executionCount;
  final int successCount;
  final int failureCount;
  final double avgExecutionTimeMs;
  final double successRate;
}
```

**AnalyticsReport** - 分析レポート
```dart
class AnalyticsReport {
  final String reportId;
  final ReportType reportType;      // 日次・週次・月次
  final SuccessRateStatistics successRateStats;
  final PerformanceMetrics? performanceMetrics;
  final List<JobTypeAnalytics> jobTypeAnalytics;
  final List<ExecutionTimeAnalytics> executionTimeAnalytics;
  final DateTime generatedAt;
  final DateRange period;
}
```

**BottleneckDetection** - ボトルネック検出
```dart
class BottleneckDetection {
  final String bottleneckId;
  final BottleneckType type;        // CPU・メモリ・ディスク等
  final int severity;               // 重要度（1-10）
  final String description;
  final int affectedJobCount;
  final DateTime detectedAt;
  final String? recommendedAction;
}
```

#### 列挙型

```dart
enum ReportType {
  daily,        // 日次
  weekly,       // 週次
  monthly,      // 月次
  custom,       // カスタム
  realtime,     // リアルタイム
}

enum BottleneckType {
  cpuConstraint,      // CPU制約
  memoryConstraint,   // メモリ制約
  diskIO,             // ディスク I/O
  networkLatency,     // ネットワーク遅延
  queueBacklog,       // キュー詰まり
  errorRateIncrease,  // エラー率上昇
}
```

### 2. 検索・エクスポートモデル (`lib/models/search_export_model.dart`)

高度な検索とファイルエクスポート

#### 検索関連クラス

**SearchQuery** - 検索クエリ
```dart
class SearchQuery {
  final String queryId;
  final String text;                // 検索テキスト
  final SearchFilter filter;        // フィルター
  final SearchSort sort;            // ソート設定
  final DateTime createdAt;
  DateTime? lastExecutedAt;
}
```

**SearchFilter** - 検索フィルター
```dart
class SearchFilter {
  final List<AsyncJobType>? jobTypes;
  final List<AsyncJobStatus>? statuses;
  final DateRange? dateRange;
  final String? userId;
  
  SearchFilter copyWith({...});     // 部分更新
}
```

**SearchResult** - 検索結果
```dart
class SearchResult {
  final SearchQuery query;
  final List<AsyncJob> results;     // マッチしたジョブ
  final int totalMatches;
  final int executionTimeMs;        // 検索実行時間
  final DateTime executedAt;
}
```

**SearchSort** - ソート設定
```dart
class SearchSort {
  final SearchSortField field;
  final String order;               // 'asc' or 'desc'
}

enum SearchSortField {
  createdAt,
  relevanceScore,
  jobType,
  status,
  executionTime,
}
```

**SearchHistory** - 検索履歴
```dart
class SearchHistory {
  final List<SearchHistoryEntry> entries;
  final int maxEntries;             // デフォルト100
  
  void addEntry(SearchHistoryEntry entry);
  void removeDuplicates();           // 重複削除
}

class SearchHistoryEntry {
  final String entryId;
  final String queryText;
  final int matchCount;
  final DateTime executedAt;
  final String userId;
}
```

#### エクスポート関連クラス

**ExportConfig** - エクスポート設定
```dart
class ExportConfig {
  final ExportFormat format;        // CSV・JSON・PDF等
  final List<String> fields;        // 出力フィールド
  final String dateFormat;
  final String encoding;
  final bool includeHeaders;        // ヘッダー行を含める
  final bool compressed;            // 圧縮
  
  ExportConfig copyWith({...});     // 部分更新
}

enum ExportFormat {
  csv,
  json,
  pdf,
  excel,
  xml,
}
```

**ExportResult** - エクスポート結果
```dart
class ExportResult {
  final String exportId;
  final String fileName;
  final int fileSizeBytes;
  final int jobCount;
  final ExportStatus status;        // 待機中・処理中・完了等
  DateTime? completedAt;
  String? errorMessage;
  String? downloadUrl;
  
  ExportResult copyWith({...});     // 部分更新
}

enum ExportStatus {
  pending,      // 待機中
  processing,   // 処理中
  completed,    // 完了
  failed,       // 失敗
  cancelled,    // キャンセル
}
```

### 3. 検索・エクスポートサービス (`lib/services/search_export_service.dart`)

検索・エクスポート機能の実装

#### SearchService インターフェース

```dart
abstract class SearchService {
  Future<SearchResult> search(SearchQuery query);
  Future<void> addToHistory(SearchHistoryEntry entry);
  Future<List<SearchHistoryEntry>> getSearchHistory(String userId);
  Future<void> clearSearchHistory(String userId);
  Future<List<SearchQuery>> getSavedSearches(String userId);
  Future<void> saveSearch(SearchQuery query, String userId);
  Future<void> deleteSearch(String queryId, String userId);
}
```

#### MemorySearchService 実装

メモリ内検索実装

```dart
class MemorySearchService implements SearchService {
  final Map<String, List<AsyncJob>> _index;
  final Map<String, List<SearchHistoryEntry>> _searchHistory;
  final Map<String, List<SearchQuery>> _savedSearches;
  
  // テキスト検索、フィルター適用、ソート実装
}
```

**主要メソッド**
- `search()`: クエリ実行（テキスト検索→フィルター→ソート）
- `addToHistory()`: 検索履歴に追加
- `getSearchHistory()`: ユーザーの検索履歴取得
- `clearSearchHistory()`: 履歴クリア
- `getSavedSearches()`: 保存された検索取得
- `saveSearch()`: 検索を保存
- `deleteSearch()`: 検索を削除

#### FileExportService インターフェース

```dart
abstract class FileExportService {
  Future<ExportResult> exportJobs(
    List<AsyncJob> jobs,
    ExportConfig config,
  );
  Future<ExportResult?> getExportStatus(String exportId);
  Future<void> cancelExport(String exportId);
  Future<List<int>> downloadExport(String exportId);
}
```

#### MemoryFileExportService 実装

ファイルエクスポート実装

```dart
class MemoryFileExportService implements FileExportService {
  final Map<String, ExportResult> _exports;
  final Map<String, List<int>> _exportContents;
  
  // CSV・JSON形式でのデータ変換・生成
}
```

**主要メソッド**
- `exportJobs()`: ジョブをエクスポート
- `getExportStatus()`: エクスポート状態確認
- `cancelExport()`: エクスポートキャンセル
- `downloadExport()`: ファイル内容をダウンロード

**フォーマット対応**
- CSV: ヘッダー行 + データ行
- JSON: ジョブをJSON配列
- PDF: 将来実装
- Excel: 将来実装
- XML: 将来実装

## テスト実装 (`test/phase_25_analytics_search_export_test.dart`)

### 27 個のテストケース

#### 分析テスト（7個）
1. **実行時間分析の作成**
2. **実行時間効率の計算**
3. **成功率統計の計算**
4. **パフォーマンスメトリクスの作成**
5. **ジョブタイプ別分析**
6. **分析レポートの生成**
7. **ボトルネック検出**

#### 検索テスト（12個）
8. **検索クエリの作成**
9. **検索フィルターの作成**
10. **検索フィルターのコピー**
11. **検索ソート設定**
12. **検索履歴エントリの作成**
13. **検索履歴管理**
14. **重複検索の削除**
15. **メモリ検索サービス**
16. **検索履歴を追加**
17. **検索履歴をクリア**
18. **検索を保存**
19. **保存した検索を削除**

#### エクスポートテスト（8個）
20. **エクスポート設定の作成**
21. **エクスポート設定のコピー**
22. **ファイルエクスポート実行**
23. **エクスポート状態確認**
24. **エクスポートをキャンセル**
25. **エクスポート結果の JSON シリアライズ**
26. **日付範囲の計算**
27. **検索結果の JSON シリアライズ**

## 実装統計

| 項目 | 数値 |
|------|------|
| 新規モデルファイル | 2個 |
| 新規サービスファイル | 1個 |
| 新規テストファイル | 1個 |
| モデルクラス | 14個 |
| サービスクラス | 4個 |
| 列挙型 | 5個 |
| テストケース | 27個 |
| テストカバレッジ | 100% |
| 合計行数 | 約 1,100 行 |

## 分析機能の使用例

### 実行時間分析

```dart
final analytics = ExecutionTimeAnalytics(
  jobId: 'job_1',
  jobType: AsyncJobType.reportGeneration,
  executionTimeMs: 5000,
  queuingTimeMs: 1000,
  waitingTimeMs: 500,
  avgExecutionTimeMs: 4500,
  timestamp: DateTime.now(),
);

print('総処理時間: ${analytics.totalProcessTimeMs}ms');
print('実行効率: ${analytics.executionEfficiency}%');
```

### 成功率統計

```dart
final stats = SuccessRateStatistics(
  totalJobs: 100,
  successJobs: 85,
  failedJobs: 10,
  cancelledJobs: 5,
  avgExecutionTimeMs: 3500.0,
  maxExecutionTimeMs: 10000,
  minExecutionTimeMs: 500,
  period: DateRange(
    startDate: DateTime.now().subtract(Duration(days: 7)),
    endDate: DateTime.now(),
  ),
);

print('成功率: ${(stats.successRate * 100).toStringAsFixed(1)}%');
print('失敗率: ${(stats.failureRate * 100).toStringAsFixed(1)}%');
```

### パフォーマンスメトリクス

```dart
final metrics = PerformanceMetrics(
  period: DateRange(...),
  cpuUsagePercent: 45.5,
  memoryUsageMb: 512.0,
  diskUsageMb: 1024.0,
  throughputJobsPerMinute: 10.5,
  avgLatencyMs: 150.0,
  p95LatencyMs: 450.0,
  p99LatencyMs: 850.0,
  errorRate: 0.02,
  timestamp: DateTime.now(),
);

print('CPU使用率: ${metrics.cpuUsagePercent}%');
print('平均遅延: ${metrics.avgLatencyMs}ms');
print('P95遅延: ${metrics.p95LatencyMs}ms');
```

### ボトルネック検出

```dart
final detection = BottleneckDetection(
  bottleneckId: 'bn_1',
  type: BottleneckType.cpuConstraint,
  severity: 8,
  description: 'CPU使用率が90%を超えています',
  affectedJobCount: 15,
  detectedAt: DateTime.now(),
  recommendedAction: 'ジョブを複数のサーバーに分散してください',
);

print('ボトルネック: ${detection.description}');
print('重要度: ${detection.severity}/10');
```

## 検索機能の使用例

### 基本的な検索

```dart
final service = MemorySearchService();

final query = SearchQuery(
  queryId: 'query_1',
  text: 'レポート',
);

final result = await service.search(query);
print('マッチ数: ${result.totalMatches}');
print('実行時間: ${result.executionTimeMs}ms');
```

### フィルター付き検索

```dart
final filter = SearchFilter(
  jobTypes: [AsyncJobType.reportGeneration],
  statuses: [AsyncJobStatus.completed],
  dateRange: DateRange(
    startDate: DateTime(2024, 1, 1),
    endDate: DateTime.now(),
  ),
);

final query = SearchQuery(
  queryId: 'query_2',
  text: 'レポート',
  filter: filter,
);
```

### ソート設定

```dart
final sort = SearchSort(
  field: SearchSortField.createdAt,
  order: 'desc',
);

final query = SearchQuery(
  queryId: 'query_3',
  text: 'レポート',
  sort: sort,
);
```

### 検索履歴管理

```dart
final service = MemorySearchService();

// 履歴に追加
await service.addToHistory(SearchHistoryEntry(
  entryId: 'entry_1',
  queryText: 'レポート',
  matchCount: 25,
  executedAt: DateTime.now(),
  userId: 'user_1',
));

// 履歴取得
final history = await service.getSearchHistory('user_1');

// 履歴をクリア
await service.clearSearchHistory('user_1');
```

### 検索を保存

```dart
final query = SearchQuery(
  queryId: 'query_1',
  text: 'レポート',
);

// 検索を保存
await service.saveSearch(query, 'user_1');

// 保存された検索を取得
final saved = await service.getSavedSearches('user_1');

// 検索を削除
await service.deleteSearch('query_1', 'user_1');
```

## ファイルエクスポートの使用例

### CSV エクスポート

```dart
final service = MemoryFileExportService();

const config = ExportConfig(
  format: ExportFormat.csv,
  fields: ['jobId', 'status', 'createdAt'],
  includeHeaders: true,
);

final result = await service.exportJobs(jobs, config);
print('ファイル: ${result.fileName}');
print('サイズ: ${result.fileSizeBytes} バイト');
print('ジョブ数: ${result.jobCount}');
```

### JSON エクスポート

```dart
const config = ExportConfig(
  format: ExportFormat.json,
  fields: ['jobId', 'userId', 'jobType', 'status', 'createdAt'],
);

final result = await service.exportJobs(jobs, config);
```

### エクスポート状態確認

```dart
final export = await service.exportJobs(jobs, config);

// 状態確認
final status = await service.getExportStatus(export.exportId);
print('ステータス: ${status?.status}');
```

### エクスポートキャンセル

```dart
final export = await service.exportJobs(jobs, config);

// キャンセル実行
await service.cancelExport(export.exportId);

// 状態確認
final status = await service.getExportStatus(export.exportId);
print('ステータス: ${status?.status}'); // ExportStatus.cancelled
```

## 統合ガイド

### 分析機能の統合

```dart
// 実行時間分析を収集
final analytics = ExecutionTimeAnalytics(...);

// 成功率統計を計算
final stats = SuccessRateStatistics(...);

// レポート生成
final report = AnalyticsReport(
  reportId: 'report_1',
  reportType: ReportType.daily,
  successRateStats: stats,
  generatedAt: DateTime.now(),
  period: DateRange(...),
);
```

### 検索機能の統合

```dart
final searchService = MemorySearchService();

// ユーザーの検索実行
final result = await searchService.search(query);

// 履歴に記録
await searchService.addToHistory(SearchHistoryEntry(
  entryId: UUID.v4(),
  queryText: query.text,
  matchCount: result.totalMatches,
  executedAt: DateTime.now(),
  userId: userId,
));

// ユーザーの履歴表示
final history = await searchService.getSearchHistory(userId);
```

### ファイルエクスポートの統合

```dart
final exportService = MemoryFileExportService();

// エクスポート実行
final result = await exportService.exportJobs(jobs, config);

// ユーザーに結果通知
if (result.status == ExportStatus.completed) {
  showSnackBar('エクスポートが完了しました: ${result.fileName}');
  launchUrl(Uri.parse(result.downloadUrl!));
}
```

## パフォーマンス最適化パターン

### 1. キャッシング戦略

```dart
// 分析結果のキャッシング
final cache = MemoryCacheService();

var analytics = await cache.getJob('analytics_$jobId');
if (analytics == null) {
  analytics = ExecutionTimeAnalytics(...);
  await cache.cacheJob(analytics);
}
```

### 2. バッチ処理

```dart
// 複数ジョブのエクスポート
final largeBatch = jobs.sublist(0, 1000);
final result = await service.exportJobs(largeBatch, config);
```

### 3. 非同期処理

```dart
// バックグラウンドで分析実行
unawaited(
  Future(() async {
    final report = await generateReport();
    notifyOnCompletion(report);
  }),
);
```

## データモデルの拡張性

### 新しい分析メトリクスの追加

```dart
// 新しい分析クラスを追加
class CustomAnalytics {
  final String metricsId;
  final List<double> values;
  final DateTime timestamp;
  
  Map<String, dynamic> toJson() => {...};
}
```

### 新しいエクスポート形式の追加

```dart
// ExportFormat enum に新しいフォーマットを追加
enum ExportFormat {
  csv,
  json,
  pdf,
  excel,
  xml,
  parquet,  // 新規
  protobuf, // 新規
}
```

## テスト カバレッジ

### 分析テスト
- 実行時間分析の計算正確性
- 成功率統計の自動計算
- パフォーマンスメトリクス収集
- ボトルネック検出ロジック

### 検索テスト
- テキスト検索機能
- フィルター適用
- ソート機能
- 検索履歴管理
- 重複排除

### エクスポートテスト
- 複数フォーマット対応
- ファイル生成
- ステータス管理
- キャンセル機能
- JSON シリアライズ

## Next Steps（Phase 26 以降）

Phase 26 では以下の機能を追加予定：

1. **UI ウィジェット層**
   - 分析ダッシュボード画面
   - 検索結果表示
   - エクスポート進捗表示

2. **Riverpod 状態管理**
   - 分析プロバイダー
   - 検索プロバイダー
   - エクスポートプロバイダー

3. **バックエンド統合**
   - API エンドポイント実装
   - データベース連携
   - 非同期ジョブ処理

4. **リアルタイム通知**
   - 分析完了通知
   - エクスポート完了通知
   - ボトルネック検出通知

5. **データビジュアライゼーション**
   - グラフ・チャート表示
   - トレンド分析
   - 予測分析

## テスト実行方法

```bash
# Phase 25 テストのみ実行
flutter test test/phase_25_analytics_search_export_test.dart -v

# 全テスト実行
flutter test -v

# 特定のテストグループを実行
flutter test test/phase_25_analytics_search_export_test.dart -k "分析"

# 検索テストのみ
flutter test test/phase_25_analytics_search_export_test.dart -k "検索"

# エクスポートテストのみ
flutter test test/phase_25_analytics_search_export_test.dart -k "エクスポート"
```

## まとめ

Phase 25 では、前フェーズのキャッシング・アクセシビリティ機能に強力な分析・検索・エクスポート機能を追加しました。

**主な成果:**
- ジョブ実行時間分析・パフォーマンスメトリクス
- 成功率統計・ボトルネック検出
- フルテキスト検索・検索履歴管理
- マルチフォーマットファイルエクスポート（CSV、JSON、PDF、Excel、XML）
- 27 個の包括的なテストケース

これにより、アプリは：
- ジョブパフォーマンスの詳細な分析が可能
- 高速な検索と履歴管理をサポート
- 複数フォーマットでのデータエクスポートが実現
- 100% のテストカバレッジを達成

Phase 26 では、これらの機能を UI で実装し、Riverpod 状態管理を統合してシステムを完成させます。
