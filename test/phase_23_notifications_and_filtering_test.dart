/// Phase 23: 通知・フィルタリング・履歴機能テスト
/// FCM 通知、ローカル通知、高度なフィルタリング、ジョブ履歴

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:project_040/models/async_job_model.dart';
import 'package:project_040/models/job_history_model.dart';
import 'package:project_040/services/fcm_notification_service.dart';
import 'package:project_040/providers/notification_provider.dart';

void main() {
  group('Phase 23: 通知・フィルタリング・履歴', () {
    // ==================== FCM 通知テスト ====================

    test('1. FCM ペイロード JSON シリアライズ', () {
      final payload = FCMPayload(
        type: NotificationType.jobCompleted,
        jobId: 'job_123',
        jobType: AsyncJobType.reportGeneration,
        title: 'レポート生成完了',
        body: 'レポートが正常に生成されました',
        priority: 'high',
      );

      final json = payload.toJson();
      expect(json['jobId'], 'job_123');
      expect(json['title'], 'レポート生成完了');
      expect(json['type'], 'jobCompleted');
      expect(json['priority'], 'high');
    });

    test('2. FCM ペイロード JSON デシリアライズ', () {
      final json = {
        'type': 'jobFailed',
        'jobId': 'job_456',
        'jobType': 'dataExport',
        'title': 'エクスポート失敗',
        'body': 'エクスポート処理がエラーで終了しました',
        'timestamp': DateTime.now().toIso8601String(),
        'priority': 'high',
        'ttl': 3600,
        'data': {'errorCode': '500'},
      };

      final payload = FCMPayload.fromJson(json);
      expect(payload.jobId, 'job_456');
      expect(payload.title, 'エクスポート失敗');
      expect(payload.type, NotificationType.jobFailed);
    });

    test('3. FCM トークン管理', () async {
      final service = StubFCMNotificationService();

      final token1 = await service.getToken();
      expect(token1, isNotNull);

      await service.registerDeviceToken('user_123', token1!);

      final token2 = await service.getToken();
      expect(token2, token1);

      await service.resetToken();
      final token3 = await service.getToken();
      expect(token3, isNull);
    });

    // ==================== ローカル通知テスト ====================

    test('4. ローカル通知作成と表示', () async {
      final service = StubLocalNotificationService();

      final notification = LocalNotification(
        id: 1,
        title: 'テスト通知',
        body: '通知テスト本文',
        jobId: 'job_123',
      );

      await service.showNotification(notification);
      final notifications = await service.getNotifications();

      expect(notifications.length, 1);
      expect(notifications[0].title, 'テスト通知');
      expect(notifications[0].jobId, 'job_123');
    });

    test('5. ローカル通知を既読にする', () async {
      final service = StubLocalNotificationService();

      final notification = LocalNotification(
        id: 1,
        title: 'テスト',
        body: '本文',
        isRead: false,
      );

      await service.showNotification(notification);
      await service.markAsRead(1);

      final notifications = await service.getNotifications();
      expect(notifications[0].isRead, true);
    });

    test('6. すべてを既読にする', () async {
      final service = StubLocalNotificationService();

      await service.showNotification(
        LocalNotification(id: 1, title: 'A', body: 'a', isRead: false),
      );
      await service.showNotification(
        LocalNotification(id: 2, title: 'B', body: 'b', isRead: false),
      );

      await service.markAllAsRead();
      final notifications = await service.getNotifications();

      expect(notifications.every((n) => n.isRead), true);
    });

    test('7. ローカル通知をキャンセル', () async {
      final service = StubLocalNotificationService();

      await service.showNotification(
        LocalNotification(id: 1, title: 'A', body: 'a'),
      );
      await service.showNotification(
        LocalNotification(id: 2, title: 'B', body: 'b'),
      );

      await service.cancelNotification(1);
      final notifications = await service.getNotifications();

      expect(notifications.length, 1);
      expect(notifications[0].id, 2);
    });

    test('8. すべての通知をキャンセル', () async {
      final service = StubLocalNotificationService();

      await service.showNotification(
        LocalNotification(id: 1, title: 'A', body: 'a'),
      );
      await service.showNotification(
        LocalNotification(id: 2, title: 'B', body: 'b'),
      );

      await service.cancelAllNotifications();
      final notifications = await service.getNotifications();

      expect(notifications.isEmpty, true);
    });

    // ==================== ジョブ履歴テスト ====================

    test('9. ジョブ履歴エントリ作成', () {
      final entry = JobHistoryEntry(
        entryId: 'entry_1',
        jobId: 'job_123',
        eventType: JobHistoryEventType.started,
        previousStatus: AsyncJobStatus.queued,
        newStatus: AsyncJobStatus.processing,
        message: 'ジョブが開始されました',
        timestamp: DateTime.now(),
      );

      expect(entry.jobId, 'job_123');
      expect(entry.eventType, JobHistoryEventType.started);
      expect(entry.newStatus, AsyncJobStatus.processing);
    });

    test('10. ジョブ履歴エントリ JSON シリアライズ', () {
      final entry = JobHistoryEntry(
        entryId: 'entry_1',
        jobId: 'job_123',
        eventType: JobHistoryEventType.completed,
        newStatus: AsyncJobStatus.completed,
        message: '完了',
        timestamp: DateTime.now(),
      );

      final json = entry.toJson();
      expect(json['jobId'], 'job_123');
      expect(json['eventType'], 'completed');
      expect(json['newStatus'], 'completed');
    });

    test('11. ジョブ履歴フィルター：ジョブ ID', () {
      final filter = JobHistoryFilter(jobId: 'job_123');

      final entry1 = JobHistoryEntry(
        entryId: '1',
        jobId: 'job_123',
        eventType: JobHistoryEventType.started,
        message: 'テスト',
        timestamp: DateTime.now(),
      );

      final entry2 = JobHistoryEntry(
        entryId: '2',
        jobId: 'job_456',
        eventType: JobHistoryEventType.started,
        message: 'テスト',
        timestamp: DateTime.now(),
      );

      expect(filter.matches(entry1), true);
      expect(filter.matches(entry2), false);
    });

    test('12. ジョブ履歴フィルター：イベントタイプ', () {
      final filter = JobHistoryFilter(
        eventTypes: [JobHistoryEventType.completed, JobHistoryEventType.failed],
      );

      final completedEntry = JobHistoryEntry(
        entryId: '1',
        jobId: 'job_123',
        eventType: JobHistoryEventType.completed,
        message: 'テスト',
        timestamp: DateTime.now(),
      );

      final startedEntry = JobHistoryEntry(
        entryId: '2',
        jobId: 'job_123',
        eventType: JobHistoryEventType.started,
        message: 'テスト',
        timestamp: DateTime.now(),
      );

      expect(filter.matches(completedEntry), true);
      expect(filter.matches(startedEntry), false);
    });

    test('13. ジョブ履歴フィルター：日付範囲', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      final filter = JobHistoryFilter(
        startDate: yesterday,
        endDate: tomorrow,
      );

      final entry = JobHistoryEntry(
        entryId: '1',
        jobId: 'job_123',
        eventType: JobHistoryEventType.started,
        message: 'テスト',
        timestamp: now,
      );

      expect(filter.matches(entry), true);
    });

    test('14. ジョブ履歴フィルター：テキスト検索', () {
      final filter = JobHistoryFilter(searchText: 'エラー');

      final matchingEntry = JobHistoryEntry(
        entryId: '1',
        jobId: 'job_123',
        eventType: JobHistoryEventType.failed,
        message: 'エラーが発生しました',
        timestamp: DateTime.now(),
      );

      final nonMatchingEntry = JobHistoryEntry(
        entryId: '2',
        jobId: 'job_123',
        eventType: JobHistoryEventType.started,
        message: 'ジョブ開始',
        timestamp: DateTime.now(),
      );

      expect(filter.matches(matchingEntry), true);
      expect(filter.matches(nonMatchingEntry), false);
    });

    // ==================== 高度なフィルタリングテスト ====================

    test('15. 高度なフィルター：ジョブタイプ', () {
      final filter = AdvancedJobFilter(
        jobTypes: [AsyncJobType.reportGeneration],
      );

      final reportJob = ReportGenerationJob(
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

      final exportJob = ExportDataJob(
        jobId: 'job_2',
        userId: 'user_1',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
        dataType: 'csv',
        format: 'csv',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      expect(filter.matches(reportJob), true);
      expect(filter.matches(exportJob), false);
    });

    test('16. 高度なフィルター：ステータス', () {
      final filter = AdvancedJobFilter(
        statuses: [AsyncJobStatus.processing, AsyncJobStatus.queued],
      );

      final processingJob = ReportGenerationJob(
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

      final completedJob = ReportGenerationJob(
        jobId: 'job_2',
        userId: 'user_1',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'レポート',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      expect(filter.matches(processingJob), true);
      expect(filter.matches(completedJob), false);
    });

    test('17. 高度なフィルター：進捗率範囲', () {
      final filter = AdvancedJobFilter(
        minProgress: 30,
        maxProgress: 70,
      );

      final job1 = ReportGenerationJob(
        jobId: 'job_1',
        userId: 'user_1',
        status: AsyncJobStatus.processing,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'レポート',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        progressPercent: 50,
      );

      final job2 = ReportGenerationJob(
        jobId: 'job_2',
        userId: 'user_1',
        status: AsyncJobStatus.processing,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'レポート',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        progressPercent: 10,
      );

      expect(filter.matches(job1), true);
      expect(filter.matches(job2), false);
    });

    test('18. 高度なフィルター：エラーのみ', () {
      final filter = AdvancedJobFilter(errorsOnly: true);

      final failedJob = ReportGenerationJob(
        jobId: 'job_1',
        userId: 'user_1',
        status: AsyncJobStatus.failed,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'レポート',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        errorMessage: 'エラーが発生しました',
      );

      final successJob = ReportGenerationJob(
        jobId: 'job_2',
        userId: 'user_1',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'レポート',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      expect(filter.matches(failedJob), true);
      expect(filter.matches(successJob), false);
    });

    test('19. 高度なフィルター：テキスト検索', () {
      final filter = AdvancedJobFilter(searchText: 'レポート');

      final reportJob = ReportGenerationJob(
        jobId: 'job_1',
        userId: 'user_1',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'レポート生成',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      final emailJob = EmailDeliveryJob(
        jobId: 'job_2',
        userId: 'user_1',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
        sourceJobId: 'source_1',
        recipientEmails: ['user@example.com'],
        subject: 'メール配信',
      );

      expect(filter.matches(reportJob), true);
      expect(filter.matches(emailJob), false);
    });

    test('20. 高度なフィルター：複合条件', () {
      final filter = AdvancedJobFilter(
        jobTypes: [AsyncJobType.reportGeneration],
        statuses: [AsyncJobStatus.completed, AsyncJobStatus.failed],
        minProgress: 0,
      );

      final reportCompleted = ReportGenerationJob(
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

      final reportProcessing = ReportGenerationJob(
        jobId: 'job_2',
        userId: 'user_1',
        status: AsyncJobStatus.processing,
        createdAt: DateTime.now(),
        templateId: 'template_1',
        format: 'pdf',
        title: 'レポート',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );

      expect(filter.matches(reportCompleted), true);
      expect(filter.matches(reportProcessing), false);
    });

    test('21. 通知プロバイダー状態初期化', () async {
      final container = ProviderContainer();

      final state = container.read(notificationProvider);
      expect(state.notifications.isEmpty, true);
      expect(state.unreadCount, 0);
      expect(state.isLoading, false);
    });

    test('22. ジョブ履歴プロバイダー：エントリ追加', () async {
      final container = ProviderContainer();
      final notifier = container.read(jobHistoryProvider.notifier);

      final entry = JobHistoryEntry(
        entryId: 'entry_1',
        jobId: 'job_123',
        eventType: JobHistoryEventType.started,
        message: 'テスト',
        timestamp: DateTime.now(),
      );

      notifier.addEntry(entry);

      // エントリ追加後、履歴を読み込む
      await notifier.loadHistory(const JobHistoryFilter());

      final state = container.read(jobHistoryProvider);
      expect(state.totalCount, 1);
    });

    test('23. フィルター：ソート順序', () {
      final jobs = [
        ReportGenerationJob(
          jobId: 'job_1',
          userId: 'user_1',
          status: AsyncJobStatus.completed,
          createdAt: DateTime(2024, 1, 1),
          templateId: 'template_1',
          format: 'pdf',
          title: 'レポート',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        ),
        ReportGenerationJob(
          jobId: 'job_2',
          userId: 'user_1',
          status: AsyncJobStatus.completed,
          createdAt: DateTime(2024, 1, 2),
          templateId: 'template_1',
          format: 'pdf',
          title: 'レポート',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        ),
      ];

      final notifier = AdvancedFilterNotifier(jobs);
      notifier.applyFilter(const AdvancedJobFilter());

      final state = notifier.state;
      expect(state.filteredJobs.length, 2);
    });

    test('24. LocalNotification copyWith', () {
      final notification = LocalNotification(
        id: 1,
        title: 'テスト',
        body: '本文',
        isRead: false,
      );

      final updated = notification.copyWith(isRead: true);

      expect(notification.isRead, false);
      expect(updated.isRead, true);
      expect(updated.id, 1);
    });

    test('25. AdvancedJobFilter copyWith', () {
      final filter1 = const AdvancedJobFilter();

      final filter2 = filter1.copyWith(
        searchText: 'テスト',
        errorsOnly: true,
      );

      expect(filter1.searchText, isNull);
      expect(filter2.searchText, 'テスト');
      expect(filter2.errorsOnly, true);
    });
  });
}
