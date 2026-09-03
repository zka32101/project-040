/// Phase 21: ジョブ監視 UI テスト
/// ジョブ監視ダッシュボード、通知、リアルタイム更新機能のテスト

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import '../lib/models/async_job_model.dart';
import '../lib/models/job_monitoring_model.dart';
import '../lib/services/cloud_functions_service.dart';
import '../lib/providers/job_monitoring_provider.dart';

void main() {
  group('Phase 21: ジョブ監視機能テスト', () {
    late StubCloudFunctionsServiceForTesting stubService;
    late ProviderContainer container;

    setUp(() {
      stubService = StubCloudFunctionsServiceForTesting();
      container = ProviderContainer(
        overrides: [
          cloudFunctionsServiceProvider.overrideWithValue(stubService),
          currentUserIdProvider.overrideWithValue('test-user-123'),
        ],
      );
    });

    /// Test 1: ジョブ監視ダッシュボード初期状態
    test('JobMonitoringState 初期状態の確認', () {
      final state = JobMonitoringState(
        activeJobs: [],
        completedJobs: [],
        failedJobs: [],
      );

      expect(state.activeJobs, isEmpty);
      expect(state.completedJobs, isEmpty);
      expect(state.failedJobs, isEmpty);
      expect(state.totalJobCount, 0);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
    });

    /// Test 2: ジョブリスト更新の確認
    test('refreshJobs でジョブ一覧を更新', () async {
      // テストデータを準備
      final testJob = ReportGenerationJob(
        jobId: 'test-report-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Test Report',
        status: AsyncJobStatus.processing,
        createdAt: DateTime.now(),
      );

      stubService.addJob(testJob);

      final notifier = container.read(jobMonitoringProvider.notifier);
      await notifier.refreshJobs();

      final state = container.read(jobMonitoringProvider);
      expect(state.activeJobs, isNotEmpty);
      expect(state.activeJobs.first.jobId, 'test-report-001');
    });

    /// Test 3: ジョブをステータスごとに分類
    test('ジョブが正しくステータス別に分類される', () async {
      final activeJob = ReportGenerationJob(
        jobId: 'active-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Active Job',
        status: AsyncJobStatus.processing,
        createdAt: DateTime.now(),
      );

      final completedJob = ReportGenerationJob(
        jobId: 'completed-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Completed Job',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
      );

      final failedJob = ReportGenerationJob(
        jobId: 'failed-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Failed Job',
        status: AsyncJobStatus.failed,
        createdAt: DateTime.now(),
        errorMessage: 'Test Error',
      );

      stubService.addJob(activeJob);
      stubService.addJob(completedJob);
      stubService.addJob(failedJob);

      final notifier = container.read(jobMonitoringProvider.notifier);
      await notifier.refreshJobs();

      final state = container.read(jobMonitoringProvider);
      expect(state.activeJobs.length, 1);
      expect(state.completedJobs.length, 1);
      expect(state.failedJobs.length, 1);
    });

    /// Test 4: ジョブを選択する
    test('selectJob でジョブを選択', () async {
      final testJob = ReportGenerationJob(
        jobId: 'select-test-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Selection Test',
        status: AsyncJobStatus.queued,
        createdAt: DateTime.now(),
      );

      stubService.addJob(testJob);

      final notifier = container.read(jobMonitoringProvider.notifier);
      await notifier.refreshJobs();
      notifier.selectJob('select-test-001');

      final state = container.read(jobMonitoringProvider);
      expect(state.selectedJobId, 'select-test-001');
      expect(state.getSelectedJob()?.jobId, 'select-test-001');
    });

    /// Test 5: ジョブの選択を解除
    test('deselectJob で選択を解除', () async {
      final testJob = ReportGenerationJob(
        jobId: 'deselect-test-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Deselection Test',
        status: AsyncJobStatus.queued,
        createdAt: DateTime.now(),
      );

      stubService.addJob(testJob);

      final notifier = container.read(jobMonitoringProvider.notifier);
      await notifier.refreshJobs();
      notifier.selectJob('deselect-test-001');
      notifier.deselectJob();

      final state = container.read(jobMonitoringProvider);
      expect(state.selectedJobId, isNull);
    });

    /// Test 6: ジョブをキャンセル
    test('cancelJob でジョブをキャンセル', () async {
      final testJob = ReportGenerationJob(
        jobId: 'cancel-test-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Cancel Test',
        status: AsyncJobStatus.processing,
        createdAt: DateTime.now(),
      );

      stubService.addJob(testJob);

      final notifier = container.read(jobMonitoringProvider.notifier);
      await notifier.refreshJobs();
      await notifier.cancelJob('cancel-test-001');

      final state = container.read(jobMonitoringProvider);
      // キャンセルされたジョブはアクティブリストから削除されている
      expect(state.activeJobs.where((j) => j.jobId == 'cancel-test-001'), isEmpty);
    });

    /// Test 7: フィルタモード - Active
    test('フィルタモード Active の確認', () async {
      final activeJob = ReportGenerationJob(
        jobId: 'active-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Active',
        status: AsyncJobStatus.processing,
        createdAt: DateTime.now(),
      );

      final completedJob = ReportGenerationJob(
        jobId: 'completed-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Completed',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
      );

      stubService.addJob(activeJob);
      stubService.addJob(completedJob);

      final notifier = container.read(jobMonitoringProvider.notifier);
      await notifier.refreshJobs();
      notifier.setFilterMode(JobFilterMode.active);

      final filteredJobs = container.read(filteredJobsProvider);
      expect(filteredJobs.length, 1);
      expect(filteredJobs.first.status, AsyncJobStatus.processing);
    });

    /// Test 8: フィルタモード - Failed
    test('フィルタモード Failed の確認', () async {
      final failedJob1 = ReportGenerationJob(
        jobId: 'failed-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Failed 1',
        status: AsyncJobStatus.failed,
        createdAt: DateTime.now(),
        errorMessage: 'Error 1',
      );

      final failedJob2 = ReportGenerationJob(
        jobId: 'failed-002',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Failed 2',
        status: AsyncJobStatus.failed,
        createdAt: DateTime.now(),
        errorMessage: 'Error 2',
      );

      stubService.addJob(failedJob1);
      stubService.addJob(failedJob2);

      final notifier = container.read(jobMonitoringProvider.notifier);
      await notifier.refreshJobs();
      notifier.setFilterMode(JobFilterMode.failed);

      final filteredJobs = container.read(filteredJobsProvider);
      expect(filteredJobs.length, 2);
      expect(filteredJobs.every((j) => j.status == AsyncJobStatus.failed), true);
    });

    /// Test 9: 平均進捗率の計算
    test('averageProgress で平均進捗率を計算', () {
      final job1 = ReportGenerationJob(
        jobId: 'progress-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Progress 1',
        status: AsyncJobStatus.processing,
        createdAt: DateTime.now(),
        progressPercent: 50,
      );

      final job2 = ReportGenerationJob(
        jobId: 'progress-002',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Progress 2',
        status: AsyncJobStatus.processing,
        createdAt: DateTime.now(),
        progressPercent: 75,
      );

      final state = JobMonitoringState(
        activeJobs: [job1, job2],
        completedJobs: [],
        failedJobs: [],
      );

      expect(state.averageProgress, 0.625); // (50 + 75) / 2 / 100
    });

    /// Test 10: 通知イベントのシリアライゼーション
    test('JobNotificationEvent JSON シリアライゼーション', () {
      final event = JobNotificationEvent(
        type: JobNotificationType.completed,
        jobId: 'notification-001',
        jobType: AsyncJobType.reportGeneration,
        message: 'レポート生成が完了しました',
        timestamp: DateTime(2024, 1, 1),
        metadata: {'reportUrl': 'https://example.com/report.pdf'},
      );

      final json = event.toJson();
      expect(json['jobId'], 'notification-001');
      expect(json['message'], 'レポート生成が完了しました');
      expect(json['metadata']['reportUrl'], 'https://example.com/report.pdf');
    });

    /// Test 11: 通知イベントのデシリアライゼーション
    test('JobNotificationEvent JSON デシリアライゼーション', () {
      final json = {
        'type': 'JobNotificationType.completed',
        'jobId': 'deser-001',
        'jobType': 'AsyncJobType.reportGeneration',
        'message': 'ジョブが完了',
        'timestamp': DateTime(2024, 1, 1).toIso8601String(),
        'metadata': null,
      };

      final event = JobNotificationEvent.fromJson(json);
      expect(event.jobId, 'deser-001');
      expect(event.type, JobNotificationType.completed);
      expect(event.jobType, AsyncJobType.reportGeneration);
    });

    /// Test 12: ジョブ監視詳細情報
    test('JobMonitoringDetails の情報が正確', () {
      final createdAt = DateTime(2024, 1, 1, 10, 0, 0);
      final completedAt = DateTime(2024, 1, 1, 10, 5, 0); // 5分後

      final testJob = ReportGenerationJob(
        jobId: 'details-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Details Test',
        status: AsyncJobStatus.completed,
        createdAt: createdAt,
        completedAt: completedAt,
        progressPercent: 100,
      );

      final details = JobMonitoringDetails(
        jobId: testJob.jobId,
        jobType: testJob.jobType,
        status: testJob.status,
        progressPercent: testJob.progressPercent,
        elapsedTime: completedAt.difference(createdAt),
        lastUpdatedAt: completedAt,
      );

      expect(details.normalizedProgress, 1.0);
      expect(details.elapsedTime.inMinutes, 5);
      expect(details.isComplete, true);
    });

    /// Test 13: リトライ情報の管理
    test('RetryInfo でリトライ情報を管理', () {
      final retryInfo = RetryInfo(
        currentRetryCount: 2,
        maxRetries: 3,
        nextRetryAt: DateTime.now().add(const Duration(seconds: 30)),
        attempts: [
          RetryAttempt(
            attemptNumber: 1,
            attemptedAt: DateTime.now(),
            failureReason: 'Network timeout',
            resultStatus: AsyncJobStatus.failed,
          ),
          RetryAttempt(
            attemptNumber: 2,
            attemptedAt: DateTime.now(),
            failureReason: 'Connection refused',
            resultStatus: AsyncJobStatus.failed,
          ),
        ],
      );

      expect(retryInfo.canRetry, true);
      expect(retryInfo.remainingRetries, 1);
      expect(retryInfo.attempts.length, 2);
    });

    /// Test 14: ジョブ統計情報
    test('JobStatistics で集計情報を取得', () async {
      final activeJob = ReportGenerationJob(
        jobId: 'stat-active-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Stat Active',
        status: AsyncJobStatus.processing,
        createdAt: DateTime.now(),
      );

      final completedJob = ReportGenerationJob(
        jobId: 'stat-completed-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Stat Completed',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
      );

      const failedCount = 2;
      stubService.addJob(activeJob);
      stubService.addJob(completedJob);

      final notifier = container.read(jobMonitoringProvider.notifier);
      await notifier.refreshJobs();

      final stats = container.read(jobStatisticsProvider);
      expect(stats.totalJobs, 2);
      expect(stats.activeJobs, 1);
      expect(stats.completedJobs, 1);
      expect(stats.successRate, 50.0); // 1 completed out of 2
    });

    /// Test 15: 複数ジョブのステータス更新
    test('複数ジョブのステータスを効率的に更新', () async {
      final jobs = [
        ReportGenerationJob(
          jobId: 'multi-001',
          userId: 'test-user-123',
          templateId: 'template-001',
          format: 'pdf',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          title: 'Multi 1',
          status: AsyncJobStatus.processing,
          createdAt: DateTime.now(),
          progressPercent: 30,
        ),
        ReportGenerationJob(
          jobId: 'multi-002',
          userId: 'test-user-123',
          templateId: 'template-001',
          format: 'pdf',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          title: 'Multi 2',
          status: AsyncJobStatus.processing,
          createdAt: DateTime.now(),
          progressPercent: 60,
        ),
        ExportDataJob(
          jobId: 'multi-003',
          userId: 'test-user-123',
          dataType: 'student_data',
          format: 'csv',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          includePersonalInfo: false,
          maskPersonalData: true,
          status: AsyncJobStatus.processing,
          createdAt: DateTime.now(),
          progressPercent: 90,
        ),
      ];

      for (final job in jobs) {
        stubService.addJob(job);
      }

      final notifier = container.read(jobMonitoringProvider.notifier);
      await notifier.refreshJobs();

      final state = container.read(jobMonitoringProvider);
      expect(state.activeJobs.length, 3);
      expect(state.averageProgress, closeTo(0.6, 0.01)); // (30 + 60 + 90) / 3 / 100
    });

    /// Test 16: ジョブタイプ別の集計
    test('ジョブタイプ別の集計情報', () async {
      final reportJobs = [
        ReportGenerationJob(
          jobId: 'type-report-001',
          userId: 'test-user-123',
          templateId: 'template-001',
          format: 'pdf',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          title: 'Report 1',
          status: AsyncJobStatus.completed,
          createdAt: DateTime.now(),
        ),
        ReportGenerationJob(
          jobId: 'type-report-002',
          userId: 'test-user-123',
          templateId: 'template-001',
          format: 'pdf',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          title: 'Report 2',
          status: AsyncJobStatus.processing,
          createdAt: DateTime.now(),
        ),
      ];

      final exportJobs = [
        ExportDataJob(
          jobId: 'type-export-001',
          userId: 'test-user-123',
          dataType: 'student_data',
          format: 'csv',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          includePersonalInfo: false,
          maskPersonalData: true,
          status: AsyncJobStatus.completed,
          createdAt: DateTime.now(),
        ),
      ];

      for (final job in [...reportJobs, ...exportJobs]) {
        stubService.addJob(job);
      }

      final notifier = container.read(jobMonitoringProvider.notifier);
      await notifier.refreshJobs();

      final state = container.read(jobMonitoringProvider);
      final reportCount = state.activeJobs.where((j) => j.jobType == AsyncJobType.reportGeneration).length +
          state.completedJobs.where((j) => j.jobType == AsyncJobType.reportGeneration).length;
      final exportCount = state.activeJobs.where((j) => j.jobType == AsyncJobType.dataExport).length +
          state.completedJobs.where((j) => j.jobType == AsyncJobType.dataExport).length;

      expect(reportCount, 2);
      expect(exportCount, 1);
    });

    /// Test 17: ロード中フラグの管理
    test('isLoading フラグが正しく管理される', () async {
      final testJob = ReportGenerationJob(
        jobId: 'loading-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Loading Test',
        status: AsyncJobStatus.queued,
        createdAt: DateTime.now(),
      );

      stubService.addJob(testJob);

      final notifier = container.read(jobMonitoringProvider.notifier);
      var state = container.read(jobMonitoringProvider);
      expect(state.isLoading, false);

      // refreshJobs 実行中は true になるはず
      final future = notifier.refreshJobs();
      await future;

      state = container.read(jobMonitoringProvider);
      expect(state.isLoading, false); // 完了後は false
    });

    /// Test 18: エラー状態の管理
    test('エラーメッセージが正しく保存される', () async {
      final notifier = container.read(jobMonitoringProvider.notifier);

      // 存在しないジョブ ID で更新を試みる
      await notifier.updateJobStatus('non-existent-job-id');

      final state = container.read(jobMonitoringProvider);
      expect(state.errorMessage, isNotNull);
      expect(state.errorMessage, contains('更新に失敗'));
    });

    /// Test 19: コピーウィズメソッド
    test('JobMonitoringState.copyWith で状態をコピー', () {
      final original = JobMonitoringState(
        activeJobs: [],
        completedJobs: [],
        failedJobs: [],
        isLoading: true,
        errorMessage: 'Original error',
      );

      final copied = original.copyWith(
        isLoading: false,
        errorMessage: null,
      );

      expect(copied.isLoading, false);
      expect(copied.errorMessage, isNull);
      expect(copied.activeJobs, original.activeJobs);
    });

    /// Test 20: 最終更新時刻の記録
    test('lastUpdatedAt が更新される', () async {
      final testJob = ReportGenerationJob(
        jobId: 'update-time-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Update Time Test',
        status: AsyncJobStatus.queued,
        createdAt: DateTime.now(),
      );

      stubService.addJob(testJob);

      final notifier = container.read(jobMonitoringProvider.notifier);
      var state = container.read(jobMonitoringProvider);
      expect(state.lastUpdatedAt, isNull);

      await notifier.refreshJobs();

      state = container.read(jobMonitoringProvider);
      expect(state.lastUpdatedAt, isNotNull);
      expect(
        state.lastUpdatedAt!.difference(DateTime.now()).inSeconds.abs(),
        lessThan(1),
      );
    });
  });
}

/// テスト用の Stub Cloud Functions サービス
class StubCloudFunctionsServiceForTesting implements CloudFunctionsService {
  final Map<String, AsyncJob> _jobs = {};

  void addJob(AsyncJob job) {
    _jobs[job.jobId] = job;
  }

  @override
  Future<ReportGenerationJob> generateReportAsync({
    required String userId,
    required String templateId,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
    required String title,
  }) async {
    final jobId = 'report_${DateTime.now().millisecondsSinceEpoch}';
    final job = ReportGenerationJob(
      jobId: jobId,
      userId: userId,
      templateId: templateId,
      format: format,
      startDate: startDate,
      endDate: endDate,
      title: title,
      status: AsyncJobStatus.queued,
      createdAt: DateTime.now(),
    );
    _jobs[jobId] = job;
    return job;
  }

  @override
  Future<ExportDataJob> exportDataAsync({
    required String userId,
    required String dataType,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
    required bool includePersonalInfo,
    required bool maskPersonalData,
    String? encryptionType,
  }) async {
    final jobId = 'export_${DateTime.now().millisecondsSinceEpoch}';
    final job = ExportDataJob(
      jobId: jobId,
      userId: userId,
      dataType: dataType,
      format: format,
      startDate: startDate,
      endDate: endDate,
      includePersonalInfo: includePersonalInfo,
      maskPersonalData: maskPersonalData,
      encryptionType: encryptionType,
      status: AsyncJobStatus.queued,
      createdAt: DateTime.now(),
    );
    _jobs[jobId] = job;
    return job;
  }

  @override
  Future<EmailDeliveryJob> scheduleEmailDelivery({
    required String userId,
    required String sourceJobId,
    required List<String> recipientEmails,
    required String subject,
  }) async {
    final jobId = 'email_${DateTime.now().millisecondsSinceEpoch}';
    final job = EmailDeliveryJob(
      jobId: jobId,
      userId: userId,
      sourceJobId: sourceJobId,
      recipientEmails: recipientEmails,
      subject: subject,
      status: AsyncJobStatus.queued,
      createdAt: DateTime.now(),
    );
    _jobs[jobId] = job;
    return job;
  }

  @override
  Future<AsyncJob> getJobStatus(String jobId) async {
    if (_jobs.containsKey(jobId)) {
      return _jobs[jobId]!;
    }
    throw Exception('Job not found: $jobId');
  }

  @override
  Future<List<AsyncJob>> getUserJobs(String userId, {int limit = 10}) async {
    return _jobs.values
        .where((job) => job.userId == userId)
        .toList()
        .sublist(0, (_jobs.length < limit ? _jobs.length : limit));
  }

  @override
  Future<void> cancelJob(String jobId) async {
    if (_jobs.containsKey(jobId)) {
      _jobs[jobId]!.status = AsyncJobStatus.cancelled;
    }
  }
}
