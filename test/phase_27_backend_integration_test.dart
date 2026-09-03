/// Phase 27: バックエンド統合テスト
/// API、データベース、通知、スケジュール機能のテスト

import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/api_models.dart';
import 'package:project_040/models/async_job_model.dart';
import 'package:project_040/models/analytics_model.dart';
import 'package:project_040/models/search_export_model.dart';
import 'package:project_040/services/api_service.dart';
import 'package:project_040/services/database_service.dart';
import 'package:project_040/services/notification_service.dart';
import 'package:project_040/services/scheduling_service.dart';

void main() {
  group('Phase 27: バックエンド統合', () {
    late MemoryApiService apiService;
    late DatabaseService databaseService;
    late MemoryNotificationService notificationService;
    late MemorySchedulingService schedulingService;
    late MemoryBatchProcessingService batchService;

    setUp(() {
      apiService = MemoryApiService();
      databaseService = DatabaseService();
      notificationService = MemoryNotificationService();
      schedulingService = MemorySchedulingService();
      batchService = MemoryBatchProcessingService();
    });

    // ==================== API サービステスト ====================

    test('1. ログイン - 有効な認証情報', () async {
      final request = LoginRequest(
        email: 'user@example.com',
        password: 'password123',
      );

      final response = await apiService.login(request);

      expect(response.userId, isNotNull);
      expect(response.token, isNotNull);
      expect(response.refreshToken, isNotNull);
      expect(response.expiresAt.isAfter(DateTime.now()), true);
    });

    test('2. ログイン - 無効な認証情報', () async {
      final request = LoginRequest(
        email: 'invalid@example.com',
        password: 'wrongpassword',
      );

      expect(
        () => apiService.login(request),
        throwsA(isA<ApiErrorResponse>()),
      );
    });

    test('3. トークンをリフレッシュ', () async {
      final request = RefreshTokenRequest(refreshToken: 'refresh_token_123');

      final response = await apiService.refreshToken(request);

      expect(response.token, isNotNull);
      expect(response.refreshToken, isNotNull);
    });

    test('4. ジョブを作成', () async {
      final request = CreateJobRequest(
        userId: 'user_1',
        jobType: AsyncJobType.reportGeneration,
        parameters: {'templateId': 'template_1'},
      );

      final job = await apiService.createJob(request);

      expect(job.jobId, isNotNull);
      expect(job.userId, 'user_1');
      expect(job.status, AsyncJobStatus.pending);
    });

    test('5. ジョブを取得', () async {
      // まずジョブを作成
      final createRequest = CreateJobRequest(
        userId: 'user_1',
        jobType: AsyncJobType.reportGeneration,
        parameters: {},
      );
      final createdJob = await apiService.createJob(createRequest);

      // ジョブを取得
      final job = await apiService.getJob(createdJob.jobId);

      expect(job.jobId, createdJob.jobId);
      expect(job.userId, 'user_1');
    });

    test('6. ジョブを取得 - 存在しないジョブ', () async {
      expect(
        () => apiService.getJob('nonexistent_job_id'),
        throwsA(isA<ApiErrorResponse>()),
      );
    });

    test('7. ジョブリストを取得', () async {
      final response = await apiService.listJobs(userId: 'user_1');

      expect(response.jobs, isA<List<AsyncJob>>());
      expect(response.totalCount, isNotNull);
      expect(response.pageNumber, 1);
    });

    test('8. ジョブを更新', () async {
      // まずジョブを作成
      final createRequest = CreateJobRequest(
        userId: 'user_1',
        jobType: AsyncJobType.reportGeneration,
        parameters: {},
      );
      final job = await apiService.createJob(createRequest);

      // ジョブを更新
      final updateRequest = UpdateJobRequest(
        jobId: job.jobId,
        status: AsyncJobStatus.processing,
        progressPercent: 50,
      );

      final updated = await apiService.updateJob(updateRequest);
      expect(updated.jobId, job.jobId);
    });

    test('9. ジョブを削除', () async {
      // まずジョブを作成
      final createRequest = CreateJobRequest(
        userId: 'user_1',
        jobType: AsyncJobType.reportGeneration,
        parameters: {},
      );
      final job = await apiService.createJob(createRequest);

      // ジョブを削除
      await apiService.deleteJob(job.jobId);

      // 削除されたジョブを取得しようとする
      expect(
        () => apiService.getJob(job.jobId),
        throwsA(isA<ApiErrorResponse>()),
      );
    });

    test('10. 分析レポートを取得', () async {
      final request = AnalyticsReportRequest(
        userId: 'user_1',
        reportType: ReportType.executionMetrics,
        period: DateRange(
          startDate: DateTime.now().subtract(Duration(days: 7)),
          endDate: DateTime.now(),
        ),
      );

      final response = await apiService.getAnalyticsReport(request);

      expect(response.report, isNotNull);
      expect(response.report.reportId, isNotNull);
      expect(response.jobTypeAnalytics, isA<List>());
    });

    test('11. 検索を実行', () async {
      final request = SearchRequest(
        userId: 'user_1',
        queryText: 'レポート',
      );

      final response = await apiService.search(request);

      expect(response.result, isNotNull);
      expect(response.totalPages, isNotNull);
    });

    test('12. エクスポートを実行', () async {
      final request = ExportRequest(
        userId: 'user_1',
        jobIds: [],
        config: ExportConfig(format: ExportFormat.csv),
      );

      final response = await apiService.export(request);

      expect(response.export, isNotNull);
      expect(response.downloadUrl, isNotNull);
    });

    test('13. ヘルスチェック', () async {
      final isHealthy = await apiService.healthCheck();

      expect(isHealthy, true);
    });

    // ==================== データベースリポジトリテスト ====================

    test('14. ジョブをデータベースに挿入', () async {
      final job = ReportGenerationJob(
        jobId: 'job_1',
        userId: 'user_1',
        status: AsyncJobStatus.pending,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'テストレポート',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      await databaseService.jobRepository.insert(job);
      final retrieved = await databaseService.jobRepository.getById('job_1');

      expect(retrieved, isNotNull);
      expect(retrieved!.jobId, 'job_1');
    });

    test('15. ジョブを更新', () async {
      final job = ReportGenerationJob(
        jobId: 'job_2',
        userId: 'user_1',
        status: AsyncJobStatus.pending,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'テストレポート',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      await databaseService.jobRepository.insert(job);

      final updated = job.copyWith(status: AsyncJobStatus.processing);
      await databaseService.jobRepository.update(updated);

      final retrieved = await databaseService.jobRepository.getById('job_2');
      expect(retrieved!.status, AsyncJobStatus.processing);
    });

    test('16. ジョブを削除', () async {
      final job = ReportGenerationJob(
        jobId: 'job_3',
        userId: 'user_1',
        status: AsyncJobStatus.pending,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'テストレポート',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      await databaseService.jobRepository.insert(job);
      await databaseService.jobRepository.delete('job_3');

      final retrieved = await databaseService.jobRepository.getById('job_3');
      expect(retrieved, isNull);
    });

    test('17. ユーザーのジョブを取得', () async {
      final job1 = ReportGenerationJob(
        jobId: 'job_4',
        userId: 'user_1',
        status: AsyncJobStatus.pending,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'レポート1',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      final job2 = ReportGenerationJob(
        jobId: 'job_5',
        userId: 'user_1',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'レポート2',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      await databaseService.jobRepository.insert(job1);
      await databaseService.jobRepository.insert(job2);

      final jobs = await databaseService.jobRepository.getUserJobs('user_1');
      expect(jobs.length, 2);
    });

    test('18. ジョブクエリビルダー', () async {
      final job = ReportGenerationJob(
        jobId: 'job_6',
        userId: 'user_2',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'レポート',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      await databaseService.jobRepository.insert(job);

      final query = JobQueryBuilder()
          .withUserId('user_2')
          .withStatus(AsyncJobStatus.completed)
          .build();

      expect(query['userId'], 'user_2');
      expect(query['status'], AsyncJobStatus.completed);
    });

    // ==================== 通知サービステスト ====================

    test('19. 通知を送信', () async {
      final notification = Notification(
        notificationId: 'notif_1',
        userId: 'user_1',
        type: NotificationType.jobCompleted,
        title: 'ジョブ完了',
        message: 'ジョブが完了しました',
        priority: NotificationPriority.normal,
        channels: [NotificationChannel.push],
        createdAt: DateTime.now(),
      );

      await notificationService.sendNotification(notification);

      final notifications =
          await notificationService.getUserNotifications('user_1');
      expect(notifications.length, 1);
      expect(notifications.first.notificationId, 'notif_1');
    });

    test('20. ジョブ完了通知を送信', () async {
      final job = ReportGenerationJob(
        jobId: 'job_7',
        userId: 'user_1',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'テストレポート',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      await notificationService.notifyJobCompleted(job);

      final notifications =
          await notificationService.getUserNotifications('user_1');
      expect(notifications.isNotEmpty, true);
      expect(notifications.first.type, NotificationType.jobCompleted);
    });

    test('21. ジョブ失敗通知を送信', () async {
      final job = ReportGenerationJob(
        jobId: 'job_8',
        userId: 'user_1',
        status: AsyncJobStatus.failed,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'テストレポート',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      await notificationService.notifyJobFailed(job, 'エラーが発生しました');

      final notifications =
          await notificationService.getUserNotifications('user_1');
      expect(notifications.any((n) => n.type == NotificationType.jobFailed),
          true);
    });

    test('22. 通知を既読にマーク', () async {
      final notification = Notification(
        notificationId: 'notif_2',
        userId: 'user_1',
        type: NotificationType.jobCompleted,
        title: 'ジョブ完了',
        message: 'ジョブが完了しました',
        priority: NotificationPriority.normal,
        channels: [NotificationChannel.push],
        createdAt: DateTime.now(),
      );

      await notificationService.sendNotification(notification);
      await notificationService.markAsRead('notif_2');

      final notifications =
          await notificationService.getUserNotifications('user_1');
      final marked =
          notifications.firstWhere((n) => n.notificationId == 'notif_2');
      expect(marked.read, true);
    });

    test('23. 通知設定を更新', () async {
      final prefs = NotificationPreferences(
        userId: 'user_1',
        enablePushNotifications: true,
        enableEmailNotifications: false,
        enableWebhooks: true,
        updatedAt: DateTime.now(),
      );

      await notificationService.updatePreferences(prefs);

      final retrieved = await notificationService.getPreferences('user_1');
      expect(retrieved, isNotNull);
      expect(retrieved!.enablePushNotifications, true);
      expect(retrieved.enableEmailNotifications, false);
    });

    // ==================== スケジュール・バッチ処理テスト ====================

    test('24. スケジュールを作成', () async {
      final config = ScheduleConfig(
        scheduleId: 'schedule_1',
        userId: 'user_1',
        jobType: AsyncJobType.reportGeneration,
        jobName: '日次レポート',
        frequency: ScheduleFrequency.daily,
        createdAt: DateTime.now(),
      );

      final created = await schedulingService.createSchedule(config);
      expect(created.scheduleId, 'schedule_1');
      expect(created.frequency, ScheduleFrequency.daily);
    });

    test('25. スケジュールを取得', () async {
      final config = ScheduleConfig(
        scheduleId: 'schedule_2',
        userId: 'user_1',
        jobType: AsyncJobType.reportGeneration,
        jobName: '週次レポート',
        frequency: ScheduleFrequency.weekly,
        createdAt: DateTime.now(),
      );

      await schedulingService.createSchedule(config);

      final retrieved = await schedulingService.getSchedule('schedule_2');
      expect(retrieved, isNotNull);
      expect(retrieved!.jobName, '週次レポート');
    });

    test('26. スケジュールを実行', () async {
      final config = ScheduleConfig(
        scheduleId: 'schedule_3',
        userId: 'user_1',
        jobType: AsyncJobType.reportGeneration,
        jobName: 'テストスケジュール',
        frequency: ScheduleFrequency.once,
        createdAt: DateTime.now(),
      );

      await schedulingService.createSchedule(config);

      final job = await schedulingService.executeSchedule('schedule_3');
      expect(job.jobId, isNotNull);
      expect(job.userId, 'user_1');
    });

    test('27. 次の実行時刻を計算', () async {
      final config = ScheduleConfig(
        scheduleId: 'schedule_4',
        userId: 'user_1',
        jobType: AsyncJobType.reportGeneration,
        jobName: 'テスト',
        frequency: ScheduleFrequency.daily,
        createdAt: DateTime.now(),
      );

      final nextRun = schedulingService.calculateNextRunTime(config);
      expect(nextRun.isAfter(DateTime.now()), true);
    });

    test('28. バッチジョブを作成', () async {
      final config = BatchJobConfig(
        batchId: 'batch_1',
        userId: 'user_1',
        jobTypes: [AsyncJobType.reportGeneration],
        batchSize: 50,
        maxConcurrent: 5,
        createdAt: DateTime.now(),
      );

      final created = await batchService.createBatch(config);
      expect(created.batchId, 'batch_1');
    });

    test('29. バッチジョブを実行', () async {
      final config = BatchJobConfig(
        batchId: 'batch_2',
        userId: 'user_1',
        jobTypes: [AsyncJobType.reportGeneration],
        batchSize: 100,
        createdAt: DateTime.now(),
      );

      await batchService.createBatch(config);

      final result = await batchService.executeBatch('batch_2');
      expect(result.batchId, 'batch_2');
      expect(result.totalJobs, 100);
      expect(result.successfulJobs, greaterThan(0));
    });

    test('30. バッチ実行結果を取得', () async {
      final config = BatchJobConfig(
        batchId: 'batch_3',
        userId: 'user_1',
        jobTypes: [AsyncJobType.reportGeneration],
        batchSize: 50,
        createdAt: DateTime.now(),
      );

      await batchService.createBatch(config);
      await batchService.executeBatch('batch_3');

      final result = await batchService.getBatchResult('batch_3');
      expect(result, isNotNull);
      expect(result!.successRate, greaterThan(0.0));
    });
  });
}
