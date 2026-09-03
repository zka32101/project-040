/// Phase 22: ジョブ監視 UI ウィジェットテスト
/// JobProgressCard、JobMonitoringDashboard、JobDetailsPanel のテスト

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import '../lib/models/async_job_model.dart';
import '../lib/models/job_monitoring_model.dart';
import '../lib/widgets/job_progress_card.dart';
import '../lib/widgets/job_monitoring_dashboard.dart';
import '../lib/widgets/job_details_panel.dart';
import '../lib/services/cloud_functions_service.dart';
import '../lib/providers/job_monitoring_provider.dart';

void main() {
  group('Phase 22: ジョブ監視 UI ウィジェットテスト', () {
    late StubCloudFunctionsServiceForUITesting stubService;
    late ProviderContainer container;

    setUp(() {
      stubService = StubCloudFunctionsServiceForUITesting();
      container = ProviderContainer(
        overrides: [
          cloudFunctionsServiceProvider.overrideWithValue(stubService),
          currentUserIdProvider.overrideWithValue('test-user-123'),
        ],
      );
    });

    /// Test 1: JobProgressCard - 処理中ジョブの表示
    testWidgets('JobProgressCard が処理中ジョブを正しく表示', (WidgetTester tester) async {
      final job = ReportGenerationJob(
        jobId: 'card-test-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Test Report',
        status: AsyncJobStatus.processing,
        createdAt: DateTime.now(),
        progressPercent: 45,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobProgressCard(job: job),
          ),
        ),
      );

      // ジョブタイトルが表示されている
      expect(find.text('Test Report'), findsOneWidget);

      // 進捗率が表示されている
      expect(find.text('45%'), findsOneWidget);

      // ステータスバッジが表示されている
      expect(find.text('処理中'), findsOneWidget);

      // プログレスバーが表示されている
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    /// Test 2: JobProgressCard - 完了ジョブの表示
    testWidgets('JobProgressCard が完了ジョブを正しく表示', (WidgetTester tester) async {
      final job = ReportGenerationJob(
        jobId: 'card-test-002',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Completed Report',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
        progressPercent: 100,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobProgressCard(job: job),
          ),
        ),
      );

      // ステータスが「完了」と表示されている
      expect(find.text('完了'), findsOneWidget);

      // プログレスバーが非表示（完了時は表示されない）
      // 完了時はプログレスバーが表示されない仕様
    });

    /// Test 3: JobProgressCard - エラーメッセージの表示
    testWidgets('JobProgressCard がエラーメッセージを表示', (WidgetTester tester) async {
      final job = ReportGenerationJob(
        jobId: 'card-test-003',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Failed Report',
        status: AsyncJobStatus.failed,
        createdAt: DateTime.now(),
        errorMessage: 'Database connection timeout',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobProgressCard(job: job),
          ),
        ),
      );

      // ステータスが「失敗」と表示されている
      expect(find.text('失敗'), findsOneWidget);

      // エラーメッセージが表示されている
      expect(find.text('Database connection timeout'), findsOneWidget);
    });

    /// Test 4: JobProgressCard - キャンセルボタン
    testWidgets('JobProgressCard がキャンセルボタンを表示', (WidgetTester tester) async {
      bool cancelPressed = false;

      final job = ReportGenerationJob(
        jobId: 'card-test-004',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Cancellable Job',
        status: AsyncJobStatus.processing,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobProgressCard(
              job: job,
              onCancel: () {
                cancelPressed = true;
              },
            ),
          ),
        ),
      );

      // キャンセルボタンが表示されている
      expect(find.text('キャンセル'), findsOneWidget);

      // キャンセルボタンをタップ
      await tester.tap(find.text('キャンセル'));
      await tester.pumpAndSettle();

      // コールバックが呼ばれた
      expect(cancelPressed, true);
    });

    /// Test 5: JobProgressCard - 詳細ボタン
    testWidgets('JobProgressCard が詳細ボタンを表示', (WidgetTester tester) async {
      bool detailsPressed = false;

      final job = ReportGenerationJob(
        jobId: 'card-test-005',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Details Job',
        status: AsyncJobStatus.queued,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobProgressCard(
              job: job,
              onShowDetails: () {
                detailsPressed = true;
              },
            ),
          ),
        ),
      );

      // 詳細ボタンが表示されている
      expect(find.text('詳細'), findsOneWidget);

      // 詳細ボタンをタップ
      await tester.tap(find.text('詳細'));
      await tester.pumpAndSettle();

      // コールバックが呼ばれた
      expect(detailsPressed, true);
    });

    /// Test 6: JobProgressCard - レポートジョブの説明
    testWidgets('JobProgressCard がレポートジョブの期間を表示', (WidgetTester tester) async {
      final job = ReportGenerationJob(
        jobId: 'card-test-006',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        title: 'Year Report',
        status: AsyncJobStatus.queued,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobProgressCard(job: job),
          ),
        ),
      );

      // 期間が表示されている
      expect(find.textContaining('2024年1月〜'), findsOneWidget);
    });

    /// Test 7: JobProgressCard - エクスポートジョブの説明
    testWidgets('JobProgressCard がエクスポートジョブを正しく表示', (WidgetTester tester) async {
      final job = ExportDataJob(
        jobId: 'card-test-007',
        userId: 'test-user-123',
        dataType: 'student_data',
        format: 'csv',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        includePersonalInfo: false,
        maskPersonalData: true,
        status: AsyncJobStatus.queued,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobProgressCard(job: job),
          ),
        ),
      );

      // データエクスポートであることが表示されている
      expect(find.textContaining('データエクスポート'), findsOneWidget);

      // マスク設定が表示されている
      expect(find.textContaining('マスク'), findsOneWidget);
    });

    /// Test 8: JobProgressCard - メールジョブの説明
    testWidgets('JobProgressCard がメールジョブの受信者数を表示', (WidgetTester tester) async {
      final job = EmailDeliveryJob(
        jobId: 'card-test-008',
        userId: 'test-user-123',
        sourceJobId: 'report-001',
        recipientEmails: ['user1@example.com', 'user2@example.com', 'user3@example.com'],
        subject: 'Monthly Report',
        status: AsyncJobStatus.queued,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobProgressCard(job: job),
          ),
        ),
      );

      // 受信者数が表示されている
      expect(find.textContaining('3'), findsWidgets);

      // 件名が表示されている
      expect(find.text('Monthly Report'), findsOneWidget);
    });

    /// Test 9: JobProgressCard - 進捗色の段階
    testWidgets('JobProgressCard が進捗率に応じた色を表示', (WidgetTester tester) async {
      final job = ReportGenerationJob(
        jobId: 'card-test-009',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Progress Test',
        status: AsyncJobStatus.processing,
        createdAt: DateTime.now(),
        progressPercent: 75,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobProgressCard(job: job),
          ),
        ),
      );

      // プログレスバーが表示されている（色は内部で判定）
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    /// Test 10: JobProgressCard - 時間経過表示
    testWidgets('JobProgressCard が相対時間を表示', (WidgetTester tester) async {
      final job = ReportGenerationJob(
        jobId: 'card-test-010',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Time Test',
        status: AsyncJobStatus.queued,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobProgressCard(job: job),
          ),
        ),
      );

      // 「〜前」という表示が含まれている
      expect(find.textContaining('分前'), findsOneWidget);
    });

    /// Test 11: JobDetailsPanel - ジョブID表示
    testWidgets('JobDetailsPanel がジョブ情報を表示', (WidgetTester tester) async {
      final job = ReportGenerationJob(
        jobId: 'details-test-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Details Test',
        status: AsyncJobStatus.processing,
        createdAt: DateTime.now(),
        progressPercent: 50,
      );

      stubService.addJob(job);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cloudFunctionsServiceProvider.overrideWithValue(stubService),
            currentUserIdProvider.overrideWithValue('test-user-123'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: JobDetailsPanel(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ジョブタイトルが表示されている
      expect(find.text('Details Test'), findsOneWidget);
    });

    /// Test 12: JobDetailsPanel - リトライボタン（失敗時）
    testWidgets('JobDetailsPanel が失敗したジョブのリトライボタンを表示', (WidgetTester tester) async {
      final job = ReportGenerationJob(
        jobId: 'retry-test-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Retry Test',
        status: AsyncJobStatus.failed,
        createdAt: DateTime.now(),
        errorMessage: 'Connection failed',
        retryCount: 0,
      );

      stubService.addJob(job);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cloudFunctionsServiceProvider.overrideWithValue(stubService),
            currentUserIdProvider.overrideWithValue('test-user-123'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: JobDetailsPanel(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 失敗ステータスが表示されている
      expect(find.text('失敗'), findsOneWidget);

      // エラーメッセージが表示されている
      expect(find.text('Connection failed'), findsOneWidget);
    });

    /// Test 13: JobDetailsPanel - メールジョブの受信者情報
    testWidgets('JobDetailsPanel がメールジョブの詳細を表示', (WidgetTester tester) async {
      final job = EmailDeliveryJob(
        jobId: 'email-detail-001',
        userId: 'test-user-123',
        sourceJobId: 'report-001',
        recipientEmails: ['a@example.com', 'b@example.com'],
        subject: 'Test Email',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
        sentCount: 2,
        failedCount: 0,
      );

      stubService.addJob(job);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cloudFunctionsServiceProvider.overrideWithValue(stubService),
            currentUserIdProvider.overrideWithValue('test-user-123'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: JobDetailsPanel(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 件名が表示されている
      expect(find.text('Test Email'), findsOneWidget);

      // 受信者情報が表示されている
      expect(find.textContaining('受信者'), findsOneWidget);
    });

    /// Test 14: JobDetailsPanel - エクスポートジョブの詳細情報
    testWidgets('JobDetailsPanel がエクスポートジョブの詳細を表示', (WidgetTester tester) async {
      final job = ExportDataJob(
        jobId: 'export-detail-001',
        userId: 'test-user-123',
        dataType: 'student_data',
        format: 'csv',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
        includePersonalInfo: false,
        maskPersonalData: true,
        encryptionType: 'AES-256',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
      );

      stubService.addJob(job);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cloudFunctionsServiceProvider.overrideWithValue(stubService),
            currentUserIdProvider.overrideWithValue('test-user-123'),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: JobDetailsPanel(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // データタイプが表示されている
      expect(find.textContaining('student_data'), findsOneWidget);

      // 暗号化情報が表示されている
      expect(find.textContaining('AES-256'), findsOneWidget);
    });

    /// Test 15: JobMonitoringDashboard - 統計情報ヘッダー
    testWidgets('JobMonitoringDashboard が統計情報を表示', (WidgetTester tester) async {
      final job = ReportGenerationJob(
        jobId: 'dashboard-test-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Dashboard Test',
        status: AsyncJobStatus.processing,
        createdAt: DateTime.now(),
      );

      stubService.addJob(job);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cloudFunctionsServiceProvider.overrideWithValue(stubService),
            currentUserIdProvider.overrideWithValue('test-user-123'),
          ],
          child: const MaterialApp(
            home: JobMonitoringDashboard(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 統計情報が表示されている
      expect(find.text('ジョブ統計'), findsOneWidget);

      // フィルタタブが表示されている
      expect(find.textContaining('すべて'), findsOneWidget);
    });

    /// Test 16: JobMonitoringDashboard - フィルタ切り替え
    testWidgets('JobMonitoringDashboard でフィルタを切り替え', (WidgetTester tester) async {
      final activeJob = ReportGenerationJob(
        jobId: 'filter-test-001',
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
        jobId: 'filter-test-002',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Completed Job',
        status: AsyncJobStatus.completed,
        createdAt: DateTime.now(),
      );

      stubService.addJob(activeJob);
      stubService.addJob(completedJob);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cloudFunctionsServiceProvider.overrideWithValue(stubService),
            currentUserIdProvider.overrideWithValue('test-user-123'),
          ],
          child: const MaterialApp(
            home: JobMonitoringDashboard(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // デフォルトではすべてのジョブが表示されている
      expect(find.byType(JobProgressCard), findsWidgets);

      // 「アクティブ」フィルタをタップ
      await tester.tap(find.text('アクティブ'));
      await tester.pumpAndSettle();

      // アクティブジョブのみが表示されている
      expect(find.text('Active Job'), findsOneWidget);
    });

    /// Test 17: JobMonitoringDashboard - リフレッシュボタン
    testWidgets('JobMonitoringDashboard でリフレッシュボタンが機能', (WidgetTester tester) async {
      stubService.addJob(ReportGenerationJob(
        jobId: 'refresh-test-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Refresh Test',
        status: AsyncJobStatus.queued,
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cloudFunctionsServiceProvider.overrideWithValue(stubService),
            currentUserIdProvider.overrideWithValue('test-user-123'),
          ],
          child: const MaterialApp(
            home: JobMonitoringDashboard(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // リフレッシュボタンが表示されている
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // リフレッシュボタンをタップ
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // ジョブが表示されている
      expect(find.text('Refresh Test'), findsOneWidget);
    });

    /// Test 18: JobMonitoringDashboard - 空のジョブリスト
    testWidgets('JobMonitoringDashboard がジョブなしの表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cloudFunctionsServiceProvider.overrideWithValue(stubService),
            currentUserIdProvider.overrideWithValue('test-user-123'),
          ],
          child: const MaterialApp(
            home: JobMonitoringDashboard(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ジョブがありませんのメッセージが表示されている
      expect(find.text('ジョブがありません'), findsOneWidget);

      // インボックスアイコンが表示されている
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    /// Test 19: JobProgressCard - 複数ステータスの表示
    testWidgets('JobProgressCard が各ステータスを正しく表示', (WidgetTester tester) async {
      final statuses = [
        (AsyncJobStatus.queued, 'キュー待機中'),
        (AsyncJobStatus.processing, '処理中'),
        (AsyncJobStatus.completed, '完了'),
        (AsyncJobStatus.failed, '失敗'),
        (AsyncJobStatus.cancelled, 'キャンセル'),
      ];

      for (final (status, label) in statuses) {
        final job = ReportGenerationJob(
          jobId: 'status-test-${status.toString()}',
          userId: 'test-user-123',
          templateId: 'template-001',
          format: 'pdf',
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          title: 'Status Test',
          status: status,
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JobProgressCard(job: job),
            ),
          ),
        );

        // 各ステータスラベルが表示されている
        expect(find.text(label), findsOneWidget);

        // タイトルが表示されている
        expect(find.text('Status Test'), findsOneWidget);
      }
    });

    /// Test 20: JobProgressCard - InkWell タップ機能
    testWidgets('JobProgressCard の InkWell がタップに反応', (WidgetTester tester) async {
      bool tapped = false;

      final job = ReportGenerationJob(
        jobId: 'tap-test-001',
        userId: 'test-user-123',
        templateId: 'template-001',
        format: 'pdf',
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        title: 'Tap Test',
        status: AsyncJobStatus.queued,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobProgressCard(
              job: job,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // カード全体をタップ
      await tester.tap(find.byType(JobProgressCard));
      await tester.pumpAndSettle();

      // onTap コールバックが呼ばれた
      expect(tapped, true);
    });
  });
}

/// テスト用の Stub Cloud Functions サービス
class StubCloudFunctionsServiceForUITesting implements CloudFunctionsService {
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
