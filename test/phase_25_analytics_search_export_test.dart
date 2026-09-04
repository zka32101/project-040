/// Phase 25: 分析・検索・エクスポートテスト
/// ジョブ分析、検索機能、ファイルエクスポート

import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/async_job_model.dart';
import 'package:project_040/models/analytics_model.dart';
import 'package:project_040/models/search_export_model.dart';
import 'package:project_040/services/search_export_service.dart';

void main() {
  group('Phase 25: 分析・検索・エクスポート', () {
    // ==================== 分析テスト ====================

    test('1. 実行時間分析の作成', () {
      final analytics = ExecutionTimeAnalytics(
        jobId: 'job_1',
        jobType: AsyncJobType.reportGeneration,
        executionTimeMs: 5000,
        queuingTimeMs: 1000,
        waitingTimeMs: 500,
        avgExecutionTimeMs: 4500,
        timestamp: DateTime.now(),
      );

      expect(analytics.jobId, 'job_1');
      expect(analytics.executionTimeMs, 5000);
      expect(analytics.totalProcessTimeMs, 6500);
    });

    test('2. 実行時間効率の計算', () {
      final analytics = ExecutionTimeAnalytics(
        jobId: 'job_1',
        jobType: AsyncJobType.reportGeneration,
        executionTimeMs: 5000,
        queuingTimeMs: 1000,
        waitingTimeMs: 500,
        avgExecutionTimeMs: 4500,
        timestamp: DateTime.now(),
      );

      final efficiency = analytics.executionEfficiency;
      expect(efficiency > 70, true); // 約76%
    });

    test('3. 成功率統計の計算', () {
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

      expect(stats.successRate, 0.85);
      expect(stats.failureRate, 0.1);
      expect(stats.cancellationRate, 0.05);
    });

    test('4. パフォーマンスメトリクスの作成', () {
      final metrics = PerformanceMetrics(
        period: DateRange(
          startDate: DateTime.now().subtract(Duration(hours: 1)),
          endDate: DateTime.now(),
        ),
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

      expect(metrics.cpuUsagePercent, 45.5);
      expect(metrics.errorRate, 0.02);
    });

    test('5. ジョブタイプ別分析', () {
      final analytics = JobTypeAnalytics(
        jobType: AsyncJobType.reportGeneration,
        executionCount: 50,
        successCount: 45,
        failureCount: 5,
        avgExecutionTimeMs: 4000.0,
        successRate: 0.9,
      );

      expect(analytics.successCount, 45);
      expect(analytics.successRate, 0.9);
    });

    test('6. 分析レポートの生成', () {
      final report = AnalyticsReport(
        reportId: 'report_1',
        reportType: ReportType.daily,
        successRateStats: SuccessRateStatistics(
          totalJobs: 100,
          successJobs: 85,
          failedJobs: 10,
          cancelledJobs: 5,
          avgExecutionTimeMs: 3500.0,
          maxExecutionTimeMs: 10000,
          minExecutionTimeMs: 500,
          period: DateRange(
            startDate: DateTime.now().subtract(Duration(days: 1)),
            endDate: DateTime.now(),
          ),
        ),
        generatedAt: DateTime.now(),
        period: DateRange(
          startDate: DateTime.now().subtract(Duration(days: 1)),
          endDate: DateTime.now(),
        ),
      );

      expect(report.reportType, ReportType.daily);
      expect(report.successRateStats.successRate, 0.85);
    });

    test('7. ボトルネック検出', () {
      final detection = BottleneckDetection(
        bottleneckId: 'bn_1',
        type: BottleneckType.cpuConstraint,
        severity: 8,
        description: 'CPU 使用率が 90% を超えています',
        affectedJobCount: 15,
        detectedAt: DateTime.now(),
        recommendedAction: 'ジョブを複数のサーバーに分散してください',
      );

      expect(detection.severity, 8);
      expect(detection.type, BottleneckType.cpuConstraint);
    });

    // ==================== 検索テスト ====================

    test('8. 検索クエリの作成', () {
      final query = SearchQuery(
        queryId: 'query_1',
        text: 'レポート',
      );

      expect(query.queryId, 'query_1');
      expect(query.text, 'レポート');
    });

    test('9. 検索フィルターの作成', () {
      final filter = SearchFilter(
        jobTypes: [AsyncJobType.reportGeneration],
        statuses: [AsyncJobStatus.completed],
      );

      expect(filter.jobTypes?.length, 1);
      expect(filter.statuses?.length, 1);
    });

    test('10. 検索フィルターのコピー', () {
      final filter1 = SearchFilter(
        jobTypes: [AsyncJobType.reportGeneration],
      );

      final filter2 = filter1.copyWith(
        statuses: [AsyncJobStatus.completed],
      );

      expect(filter1.jobTypes?.length, 1);
      expect(filter2.statuses?.length, 1);
    });

    test('11. 検索ソート設定', () {
      final sort = SearchSort(
        field: SearchSortField.createdAt,
        order: 'desc',
      );

      expect(sort.field, SearchSortField.createdAt);
      expect(sort.order, 'desc');
    });

    test('12. 検索履歴エントリの作成', () {
      final entry = SearchHistoryEntry(
        entryId: 'entry_1',
        queryText: 'レポート',
        matchCount: 25,
        executedAt: DateTime.now(),
        userId: 'user_1',
      );

      expect(entry.queryText, 'レポート');
      expect(entry.matchCount, 25);
    });

    test('13. 検索履歴管理', () {
      final history = SearchHistory();

      history.addEntry(SearchHistoryEntry(
        entryId: 'entry_1',
        queryText: 'レポート',
        matchCount: 25,
        executedAt: DateTime.now(),
        userId: 'user_1',
      ));

      expect(history.entries.length, 1);
    });

    test('14. 重複検索の削除', () {
      final history = SearchHistory();

      history.addEntry(SearchHistoryEntry(
        entryId: 'entry_1',
        queryText: 'レポート',
        matchCount: 25,
        executedAt: DateTime.now(),
        userId: 'user_1',
      ));

      history.addEntry(SearchHistoryEntry(
        entryId: 'entry_2',
        queryText: 'レポート',
        matchCount: 30,
        executedAt: DateTime.now(),
        userId: 'user_1',
      ));

      history.removeDuplicates();
      expect(history.entries.length, 1);
    });

    test('15. メモリ検索サービス', () async {
      final service = MemorySearchService();

      final query = SearchQuery(
        queryId: 'query_1',
        text: 'レポート',
      );

      final result = await service.search(query);
      expect(result.query.queryId, 'query_1');
    });

    test('16. 検索履歴を追加', () async {
      final service = MemorySearchService();

      final entry = SearchHistoryEntry(
        entryId: 'entry_1',
        queryText: 'レポート',
        matchCount: 25,
        executedAt: DateTime.now(),
        userId: 'user_1',
      );

      await service.addToHistory(entry);

      final history = await service.getSearchHistory('user_1');
      expect(history.length, 1);
    });

    test('17. 検索履歴をクリア', () async {
      final service = MemorySearchService();

      final entry = SearchHistoryEntry(
        entryId: 'entry_1',
        queryText: 'レポート',
        matchCount: 25,
        executedAt: DateTime.now(),
        userId: 'user_1',
      );

      await service.addToHistory(entry);
      await service.clearSearchHistory('user_1');

      final history = await service.getSearchHistory('user_1');
      expect(history.isEmpty, true);
    });

    test('18. 検索を保存', () async {
      final service = MemorySearchService();

      final query = SearchQuery(
        queryId: 'query_1',
        text: 'レポート',
      );

      await service.saveSearch(query, 'user_1');

      final searches = await service.getSavedSearches('user_1');
      expect(searches.length, 1);
    });

    test('19. 保存した検索を削除', () async {
      final service = MemorySearchService();

      final query = SearchQuery(
        queryId: 'query_1',
        text: 'レポート',
      );

      await service.saveSearch(query, 'user_1');
      await service.deleteSearch('query_1', 'user_1');

      final searches = await service.getSavedSearches('user_1');
      expect(searches.isEmpty, true);
    });

    // ==================== エクスポートテスト ====================

    test('20. エクスポート設定の作成', () {
      const config = ExportConfig(
        format: ExportFormat.csv,
        fields: ['jobId', 'status', 'createdAt'],
      );

      expect(config.format, ExportFormat.csv);
      expect(config.fields.length, 3);
    });

    test('21. エクスポート設定のコピー', () {
      const config1 = ExportConfig(
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

    test('22. ファイルエクスポート実行', () async {
      final service = MemoryFileExportService();

      final jobs = [
        ReportGenerationJob(
          jobId: 'job_1',
          userId: 'user_1',
          status: AsyncJobStatus.completed,
          createdAt: DateTime.now(),
          templateId: 'template_1',
          format: 'pdf',
          title: 'レポート',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        ),
      ];

      const config = ExportConfig(format: ExportFormat.csv);

      final result = await service.exportJobs(jobs, config);
      expect(result.status, ExportStatus.completed);
      expect(result.jobCount, 1);
    });

    test('23. エクスポート状態確認', () async {
      final service = MemoryFileExportService();

      final jobs = [
        ReportGenerationJob(
          jobId: 'job_1',
          userId: 'user_1',
          status: AsyncJobStatus.completed,
          createdAt: DateTime.now(),
          templateId: 'template_1',
          format: 'pdf',
          title: 'レポート',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        ),
      ];

      const config = ExportConfig(format: ExportFormat.csv);

      final export = await service.exportJobs(jobs, config);
      final status = await service.getExportStatus(export.exportId);

      expect(status?.status, ExportStatus.completed);
    });

    test('24. エクスポートをキャンセル', () async {
      final service = MemoryFileExportService();

      final jobs = [
        ReportGenerationJob(
          jobId: 'job_1',
          userId: 'user_1',
          status: AsyncJobStatus.completed,
          createdAt: DateTime.now(),
          templateId: 'template_1',
          format: 'pdf',
          title: 'レポート',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        ),
      ];

      const config = ExportConfig(format: ExportFormat.csv);

      final export = await service.exportJobs(jobs, config);
      await service.cancelExport(export.exportId);

      final status = await service.getExportStatus(export.exportId);
      expect(status?.status, ExportStatus.cancelled);
    });

    test('25. エクスポート結果の JSON シリアライズ', () {
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
    });

    test('26. 日付範囲の計算', () {
      final range = DateRange(
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
      );

      expect(range.days, 30);
    });

    test('27. 検索結果の JSON シリアライズ', () async {
      final query = SearchQuery(
        queryId: 'query_1',
        text: 'レポート',
      );

      final result = SearchResult(
        query: query,
        results: [],
        totalMatches: 0,
        executionTimeMs: 100,
        executedAt: DateTime.now(),
      );

      final json = result.toJson();
      expect(json['totalMatches'], 0);
      expect(json['executionTimeMs'], 100);
    });
  });
}
