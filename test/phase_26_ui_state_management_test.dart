/// Phase 26: UI・状態管理テスト
/// Riverpod プロバイダーと UI ウィジェットのテスト

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_040/models/analytics_model.dart';
import 'package:project_040/models/search_export_model.dart';
import 'package:project_040/models/async_job_model.dart';
import 'package:project_040/providers/analytics_provider.dart';
import 'package:project_040/providers/search_provider.dart';
import 'package:project_040/providers/export_provider.dart';

void main() {
  group('Phase 26: UI・状態管理', () {
    // ==================== 分析プロバイダーテスト ====================

    test('1. 分析サービスプロバイダーの初期化', () {
      final container = ProviderContainer();
      final service = container.read(analyticsServiceProvider);

      expect(service, isNotNull);
      expect(service is AnalyticsService, true);
    });

    test('2. 実行時間分析リスト初期状態', () {
      final container = ProviderContainer();
      final analytics = container.read(executionTimeAnalyticsProvider);

      expect(analytics, isEmpty);
    });

    test('3. 実行時間分析を追加', () {
      final container = ProviderContainer();
      final notifier = container.read(executionTimeAnalyticsProvider.notifier);

      final analytics = ExecutionTimeAnalytics(
        jobId: 'job_1',
        jobType: AsyncJobType.reportGeneration,
        executionTimeMs: 5000,
        queuingTimeMs: 1000,
        waitingTimeMs: 500,
        avgExecutionTimeMs: 4500,
        timestamp: DateTime.now(),
      );

      notifier.addAnalytics(analytics);
      final state = container.read(executionTimeAnalyticsProvider);

      expect(state.length, 1);
      expect(state.first.jobId, 'job_1');
    });

    test('4. 複数の分析を追加', () {
      final container = ProviderContainer();
      final notifier = container.read(executionTimeAnalyticsProvider.notifier);

      for (int i = 0; i < 3; i++) {
        notifier.addAnalytics(ExecutionTimeAnalytics(
          jobId: 'job_$i',
          jobType: AsyncJobType.reportGeneration,
          executionTimeMs: 5000,
          queuingTimeMs: 1000,
          waitingTimeMs: 500,
          avgExecutionTimeMs: 4500,
          timestamp: DateTime.now(),
        ));
      }

      final state = container.read(executionTimeAnalyticsProvider);
      expect(state.length, 3);
    });

    test('5. 分析をクリア', () {
      final container = ProviderContainer();
      final notifier = container.read(executionTimeAnalyticsProvider.notifier);

      notifier.addAnalytics(ExecutionTimeAnalytics(
        jobId: 'job_1',
        jobType: AsyncJobType.reportGeneration,
        executionTimeMs: 5000,
        queuingTimeMs: 1000,
        waitingTimeMs: 500,
        avgExecutionTimeMs: 4500,
        timestamp: DateTime.now(),
      ));

      notifier.clearAll();
      final state = container.read(executionTimeAnalyticsProvider);

      expect(state, isEmpty);
    });

    test('6. ジョブから分析を作成', () {
      final container = ProviderContainer();
      final notifier = container.read(executionTimeAnalyticsProvider.notifier);

      final job = ReportGenerationJob(
        jobId: 'job_1',
        userId: 'user_1',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'レポート',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      notifier.analyzeJob(job);
      final state = container.read(executionTimeAnalyticsProvider);

      expect(state.length, 1);
      expect(state.first.jobId, 'job_1');
    });

    // ==================== 検索プロバイダーテスト ====================

    test('7. 検索フィルタープロバイダー初期状態', () {
      final container = ProviderContainer();
      final filter = container.read(searchFilterProvider);

      expect(filter.jobTypes, isNull);
      expect(filter.statuses, isNull);
      expect(filter.userId, isNull);
    });

    test('8. 検索ソートプロバイダー初期状態', () {
      final container = ProviderContainer();
      final sort = container.read(searchSortProvider);

      expect(sort.field, SearchSortField.createdAt);
      expect(sort.order, 'desc');
    });

    test('9. 現在の検索クエリプロバイダー', () {
      final container = ProviderContainer();
      final query = container.read(currentSearchQueryProvider);

      expect(query, isNull);
    });

    test('10. 検索クエリを設定', () {
      final container = ProviderContainer();
      final query = SearchQuery(
        queryId: 'query_1',
        text: 'レポート',
      );

      container.read(currentSearchQueryProvider.notifier).state = query;
      final state = container.read(currentSearchQueryProvider);

      expect(state, isNotNull);
      expect(state!.text, 'レポート');
    });

    test('11. 検索履歴を追加', () async {
      final container = ProviderContainer();
      final notifier = container.read(searchHistoryProvider.notifier);

      final entry = SearchHistoryEntry(
        entryId: 'entry_1',
        queryText: 'レポート',
        matchCount: 25,
        executedAt: DateTime.now(),
        userId: 'user_1',
      );

      await notifier.addEntry(entry);
      final state = container.read(searchHistoryProvider);

      expect(state.length, 1);
      expect(state.first.queryText, 'レポート');
    });

    test('12. 検索履歴から重複を削除', () async {
      final container = ProviderContainer();
      final notifier = container.read(searchHistoryProvider.notifier);

      // 同じクエリテキストで 2 つのエントリを追加
      await notifier.addEntry(SearchHistoryEntry(
        entryId: 'entry_1',
        queryText: 'レポート',
        matchCount: 25,
        executedAt: DateTime.now(),
        userId: 'user_1',
      ));

      await notifier.addEntry(SearchHistoryEntry(
        entryId: 'entry_2',
        queryText: 'レポート',
        matchCount: 30,
        executedAt: DateTime.now(),
        userId: 'user_1',
      ));

      notifier.removeDuplicates();
      final state = container.read(searchHistoryProvider);

      expect(state.length, 1);
    });

    test('13. 検索履歴をクリア', () async {
      final container = ProviderContainer();
      final notifier = container.read(searchHistoryProvider.notifier);

      await notifier.addEntry(SearchHistoryEntry(
        entryId: 'entry_1',
        queryText: 'レポート',
        matchCount: 25,
        executedAt: DateTime.now(),
        userId: 'user_1',
      ));

      await notifier.clearHistory('user_1');
      final state = container.read(searchHistoryProvider);

      expect(state, isEmpty);
    });

    test('14. 検索フィルターを更新', () {
      final container = ProviderContainer();
      final newFilter = SearchFilter(
        jobTypes: [AsyncJobType.reportGeneration],
        statuses: [AsyncJobStatus.completed],
      );

      container.read(searchFilterProvider.notifier).state = newFilter;
      final state = container.read(searchFilterProvider);

      expect(state.jobTypes, isNotNull);
      expect(state.jobTypes!.length, 1);
    });

    test('15. 検索ソートを更新', () {
      final container = ProviderContainer();
      final newSort = SearchSort(
        field: SearchSortField.status,
        order: 'asc',
      );

      container.read(searchSortProvider.notifier).state = newSort;
      final state = container.read(searchSortProvider);

      expect(state.field, SearchSortField.status);
      expect(state.order, 'asc');
    });

    // ==================== エクスポートプロバイダーテスト ====================

    test('16. エクスポート設定プロバイダー初期状態', () {
      final container = ProviderContainer();
      final config = container.read(exportConfigProvider);

      expect(config.format, ExportFormat.csv);
      expect(config.includeHeaders, true);
      expect(config.compressed, false);
    });

    test('17. エクスポート設定を更新', () {
      final container = ProviderContainer();
      final newConfig = ExportConfig(
        format: ExportFormat.json,
        compressed: true,
      );

      container.read(exportConfigProvider.notifier).state = newConfig;
      final state = container.read(exportConfigProvider);

      expect(state.format, ExportFormat.json);
      expect(state.compressed, true);
    });

    test('18. アクティブなエクスポート初期状態', () {
      final container = ProviderContainer();
      final exports = container.read(activeExportsProvider);

      expect(exports, isEmpty);
    });

    test('19. エクスポートを追加', () {
      final container = ProviderContainer();
      final notifier = container.read(activeExportsProvider.notifier);

      final export = ExportResult(
        exportId: 'export_1',
        fileName: 'jobs.csv',
        fileSizeBytes: 2048,
        jobCount: 50,
        status: ExportStatus.completed,
        completedAt: DateTime.now(),
        downloadUrl: 'https://example.com/exports/export_1',
      );

      notifier.addExport(export);
      final state = container.read(activeExportsProvider);

      expect(state.length, 1);
      expect(state.first.exportId, 'export_1');
    });

    test('20. 複数のエクスポートを管理', () {
      final container = ProviderContainer();
      final notifier = container.read(activeExportsProvider.notifier);

      for (int i = 0; i < 3; i++) {
        notifier.addExport(ExportResult(
          exportId: 'export_$i',
          fileName: 'jobs_$i.csv',
          fileSizeBytes: 2048,
          jobCount: 50,
          status: ExportStatus.processing,
        ));
      }

      final state = container.read(activeExportsProvider);
      expect(state.length, 3);
    });

    test('21. エクスポート中フラグ', () {
      final container = ProviderContainer();
      final isExporting = container.read(isExportingProvider);

      expect(isExporting, false);

      container.read(isExportingProvider.notifier).state = true;
      final state = container.read(isExportingProvider);

      expect(state, true);
    });

    test('22. エクスポート設定をコピー', () {
      final config1 = ExportConfig(
        format: ExportFormat.csv,
        compressed: false,
      );

      final config2 = config1.copyWith(
        format: ExportFormat.json,
        compressed: true,
      );

      expect(config1.format, ExportFormat.csv);
      expect(config2.format, ExportFormat.json);
      expect(config2.compressed, true);
    });

    test('23. 検索フィルターをコピー', () {
      final filter1 = SearchFilter(
        jobTypes: [AsyncJobType.reportGeneration],
      );

      final filter2 = filter1.copyWith(
        statuses: [AsyncJobStatus.completed],
      );

      expect(filter1.jobTypes?.length, 1);
      expect(filter2.statuses?.length, 1);
    });

    test('24. 検索クエリを JSON に変換', () {
      final query = SearchQuery(
        queryId: 'query_1',
        text: 'レポート',
      );

      final json = query.toJson();

      expect(json['queryId'], 'query_1');
      expect(json['text'], 'レポート');
    });

    test('25. エクスポート結果を JSON に変換', () {
      final result = ExportResult(
        exportId: 'export_1',
        fileName: 'jobs.csv',
        fileSizeBytes: 2048,
        jobCount: 50,
        status: ExportStatus.completed,
        completedAt: DateTime.now(),
        downloadUrl: 'https://example.com/exports/export_1',
      );

      final json = result.toJson();

      expect(json['exportId'], 'export_1');
      expect(json['jobCount'], 50);
      expect(json['status'], 'completed');
    });

    test('26. 検索フィルター初期化', () {
      const filter = SearchFilter();

      expect(filter.jobTypes, isNull);
      expect(filter.statuses, isNull);
      expect(filter.dateRange, isNull);
      expect(filter.userId, isNull);
    });

    test('27. エクスポートステータス遷移', () {
      final export1 = ExportResult(
        exportId: 'export_1',
        fileName: 'jobs.csv',
        fileSizeBytes: 0,
        jobCount: 0,
        status: ExportStatus.pending,
      );

      expect(export1.status, ExportStatus.pending);

      final export2 = export1.copyWith(status: ExportStatus.processing);
      expect(export2.status, ExportStatus.processing);

      final export3 = export2.copyWith(
        status: ExportStatus.completed,
        fileSizeBytes: 2048,
      );
      expect(export3.status, ExportStatus.completed);
      expect(export3.fileSizeBytes, 2048);
    });
  });
}
