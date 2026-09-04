/// Phase 24: パフォーマンス最適化・アクセシビリティテスト
/// リスト仮想化、アクセシビリティ、キャッシング、デルタ同期

import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/async_job_model.dart';
import 'package:project_040/widgets/virtualized_job_list.dart';
import 'package:project_040/widgets/accessible_job_dashboard.dart';
import 'package:project_040/services/job_cache_service.dart';

void main() {
  group('Phase 24: パフォーマンス最適化・アクセシビリティ', () {
    // ==================== リスト仮想化テスト ====================

    test('1. 仮想化設定の初期化', () {
      const config = VirtualizationConfig(
        cacheExtent: 1000.0,
        initialItemCount: 50,
        endOfListThreshold: 0.8,
        estimatedItemHeight: 200.0,
      );

      expect(config.cacheExtent, 1000.0);
      expect(config.initialItemCount, 50);
      expect(config.endOfListThreshold, 0.8);
      expect(config.estimatedItemHeight, 200.0);
    });

    test('2. スクロール位置状態の管理', () {
      final state = ScrollPositionState(
        offset: 500.0,
        maxScrollExtent: 1000.0,
        direction: ScrollDirection.forward,
        timestamp: DateTime.now(),
      );

      expect(state.offset, 500.0);
      expect(state.maxScrollExtent, 1000.0);
      expect(state.direction, ScrollDirection.forward);
    });

    test('3. ページング判定（しきい値以下）', () {
      final state = ScrollPositionState(
        offset: 500.0,
        maxScrollExtent: 1000.0,
        direction: ScrollDirection.forward,
        timestamp: DateTime.now(),
      );

      expect(state.shouldLoadMore(0.8), false);
    });

    test('4. ページング判定（しきい値以上）', () {
      final state = ScrollPositionState(
        offset: 850.0,
        maxScrollExtent: 1000.0,
        direction: ScrollDirection.forward,
        timestamp: DateTime.now(),
      );

      expect(state.shouldLoadMore(0.8), true);
    });

    test('5. スクロール位置状態のコピー', () {
      final state1 = ScrollPositionState(
        offset: 500.0,
        maxScrollExtent: 1000.0,
        direction: ScrollDirection.forward,
        timestamp: DateTime.now(),
      );

      final state2 = state1.copyWith(offset: 600.0);

      expect(state1.offset, 500.0);
      expect(state2.offset, 600.0);
      expect(state2.maxScrollExtent, state1.maxScrollExtent);
    });

    test('6. リスト パフォーマンス計測', () {
      final metrics = ListPerformanceMetrics(
        fps: 60.0,
        avgFrameTime: 16.67,
        maxFrameTime: 33.33,
        jankCount: 2,
        timestamp: DateTime.now(),
      );

      expect(metrics.fps, 60.0);
      expect(metrics.avgFrameTime, 16.67);
      expect(metrics.jankCount, 2);
    });

    test('7. パフォーマンス計測の JSON シリアライズ', () {
      final metrics = ListPerformanceMetrics(
        fps: 60.0,
        avgFrameTime: 16.67,
        maxFrameTime: 33.33,
        jankCount: 2,
        timestamp: DateTime.now(),
      );

      final json = metrics.toJson();
      expect(json['fps'], 60.0);
      expect(json['jankCount'], 2);
    });

    // ==================== アクセシビリティテスト ====================

    test('8. アクセシビリティ設定の初期化', () {
      const config = AccessibilityConfig(
        screenReaderEnabled: true,
        highContrastMode: false,
        fontSizeFactor: 1.2,
        keyboardNavigationEnabled: true,
        reduceMotionEnabled: false,
      );

      expect(config.screenReaderEnabled, true);
      expect(config.fontSizeFactor, 1.2);
      expect(config.keyboardNavigationEnabled, true);
    });

    test('9. アクセシビリティ設定のコピー', () {
      const config1 = AccessibilityConfig(
        fontSizeFactor: 1.0,
        highContrastMode: false,
      );

      final config2 = config1.copyWith(
        fontSizeFactor: 1.5,
        highContrastMode: true,
      );

      expect(config1.fontSizeFactor, 1.0);
      expect(config1.highContrastMode, false);
      expect(config2.fontSizeFactor, 1.5);
      expect(config2.highContrastMode, true);
    });

    test('10. 高コントラストモード設定', () {
      final config = const AccessibilityConfig()
          .copyWith(highContrastMode: true);

      expect(config.highContrastMode, true);
    });

    test('11. 縮減モーション設定', () {
      final config = const AccessibilityConfig()
          .copyWith(reduceMotionEnabled: true);

      expect(config.reduceMotionEnabled, true);
    });

    test('12. フォントサイズ倍率設定', () {
      final config = const AccessibilityConfig()
          .copyWith(fontSizeFactor: 1.5);

      expect(config.fontSizeFactor, 1.5);
    });

    // ==================== ジョブキャッシュテスト ====================

    test('13. キャッシュエントリの有効性チェック', () async {
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

      final entry = CacheEntry(
        data: job,
        ttlSeconds: 3600,
      );

      expect(entry.isValid, true);
      expect(entry.isStale, false);
    });

    test('14. キャッシュエントリの有効期限切れ判定', () async {
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

      final entry = CacheEntry(
        data: job,
        ttlSeconds: 0, // TTL 0 秒
        createdAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );

      expect(entry.isValid, false);
      expect(entry.isStale, true);
    });

    test('15. メモリキャッシュにジョブを保存', () async {
      final service = MemoryCacheService();

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

      await service.cacheJob(job);

      final cachedJob = await service.getJob('job_1');
      expect(cachedJob?.jobId, 'job_1');
    });

    test('16. メモリキャッシュからジョブを取得', () async {
      final service = MemoryCacheService();

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

      await service.cacheJob(job);
      final cachedJob = await service.getJob('job_1');

      expect(cachedJob, isNotNull);
      expect(cachedJob?.jobId, 'job_1');
    });

    test('17. 複数ジョブのキャッシング', () async {
      final service = MemoryCacheService();

      final jobs = [
        ReportGenerationJob(
          jobId: 'job_1',
          userId: 'user_1',
          status: AsyncJobStatus.completed,
          createdAt: DateTime.now(),
          templateId: 'template_1',
          format: 'pdf',
          title: 'レポート1',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        ),
        ReportGenerationJob(
          jobId: 'job_2',
          userId: 'user_1',
          status: AsyncJobStatus.completed,
          createdAt: DateTime.now(),
          templateId: 'template_2',
          format: 'pdf',
          title: 'レポート2',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        ),
      ];

      await service.cacheJobs(jobs);

      final cachedJobs = await service.getJobs(['job_1', 'job_2']);
      expect(cachedJobs.length, 2);
    });

    test('18. ユーザーのジョブをキャッシュから取得', () async {
      final service = MemoryCacheService();

      final job1 = ReportGenerationJob(
        jobId: 'job_1',
        userId: 'user_1',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'レポート1',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      final job2 = ReportGenerationJob(
        jobId: 'job_2',
        userId: 'user_2',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
        templateId: 'template_2',
        format: 'pdf',
        title: 'レポート2',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      await service.cacheJobs([job1, job2]);

      final userJobs = await service.getUserJobs('user_1');
      expect(userJobs.length, 1);
      expect(userJobs[0].userId, 'user_1');
    });

    test('19. キャッシュをクリア', () async {
      final service = MemoryCacheService();

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

      await service.cacheJob(job);
      await service.clearCache();

      final cachedJob = await service.getJob('job_1');
      expect(cachedJob, isNull);
    });

    test('20. キャッシュ統計を取得', () async {
      final service = MemoryCacheService();

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

      await service.cacheJob(job);

      final stats = await service.getStatistics();
      expect(stats.totalEntries, 1);
      expect(stats.validEntries, 1);
      expect(stats.staleEntries, 0);
    });

    // ==================== デルタ同期テスト ====================

    test('21. デルタ同期マネージャーの初期化', () {
      final manager = DeltaSyncManager();

      expect(manager.hasChanges, false);
      expect(manager.lastSyncTime, isNull);
    });

    test('22. ジョブ変更を登録', () {
      final manager = DeltaSyncManager();

      manager.markJobChanged('job_1');
      manager.markJobChanged('job_2');

      expect(manager.hasChanges, true);
    });

    test('23. 複数ジョブの変更を登録', () {
      final manager = DeltaSyncManager();

      manager.markJobsChanged(['job_1', 'job_2', 'job_3']);

      expect(manager.hasChanges, true);
    });

    test('24. 同期キューに追加', () async {
      final manager = DeltaSyncManager();

      final job = ReportGenerationJob(
        jobId: 'job_1',
        userId: 'user_1',
        status: AsyncJobStatus.processing,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'レポート',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      manager.queueForSync(job);

      final queue = manager.getSyncQueue();
      expect(queue.length, 1);
      expect(queue[0].jobId, 'job_1');
    });

    test('25. 同期実行とリセット', () async {
      final manager = DeltaSyncManager();

      final job = ReportGenerationJob(
        jobId: 'job_1',
        userId: 'user_1',
        status: AsyncJobStatus.processing,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'レポート',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      manager.queueForSync(job);
      manager.markJobChanged('job_1');

      bool syncCalled = false;
      await manager.sync((jobs) async {
        syncCalled = true;
      });

      expect(syncCalled, true);
      expect(manager.hasChanges, false);
      expect(manager.getSyncQueue().isEmpty, true);
    });

    test('26. キャッシュエントリの最終アクセス時刻', () {
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

      final entry = CacheEntry(
        data: job,
        ttlSeconds: 3600,
      );

      expect(entry.secondsSinceLastAccess, 0);
    });

    test('27. キャッシュ統計の JSON シリアライズ', () async {
      const stats = CacheStatistics(
        totalEntries: 10,
        validEntries: 8,
        staleEntries: 2,
        memoryUsageBytes: 10240,
        hitRate: 0.8,
      );

      final json = stats.toJson();
      expect(json['totalEntries'], 10);
      expect(json['hitRate'], 0.8);
      expect(stats.memoryUsageMb, 0.01);
    });
  });
}
