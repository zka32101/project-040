import 'package:flutter_test/flutter_test.dart';

// Phase 20: Cloud Functions Integration Tests
// 非同期ジョブ管理と Cloud Functions 統合のテスト

void main() {
  group('Phase 20: Cloud Functions Integration', () {
    late StubCloudFunctionsService functionsService;
    late BackgroundJobService jobService;

    setUp(() {
      functionsService = StubCloudFunctionsService();
      jobService = BackgroundJobService(functionsService);
    });

    // Test 1: レポート生成ジョブをキューに追加
    test('Queue report generation job', () async {
      final job = await functionsService.generateReportAsync(
        userId: 'user_001',
        templateId: 'student_progress',
        format: 'pdf',
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 9, 1),
        title: 'August Report',
      );

      expect(job.jobId.startsWith('report_'), true);
      expect(job.userId, 'user_001');
      expect(job.templateId, 'student_progress');
      expect(job.format, 'pdf');
      expect(job.status, AsyncJobStatus.queued);
      expect(job.progressPercent, 0);
    });

    // Test 2: データエクスポートジョブをキューに追加
    test('Queue data export job', () async {
      final job = await functionsService.exportDataAsync(
        userId: 'user_002',
        dataType: 'student_data',
        format: 'csv',
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 9, 1),
        includePersonalInfo: true,
        maskPersonalData: true,
        encryptionType: 'aes256',
      );

      expect(job.jobId.startsWith('export_'), true);
      expect(job.userId, 'user_002');
      expect(job.dataType, 'student_data');
      expect(job.format, 'csv');
      expect(job.includePersonalInfo, true);
      expect(job.maskPersonalData, true);
      expect(job.encryptionType, 'aes256');
      expect(job.status, AsyncJobStatus.queued);
    });

    // Test 3: メール配信ジョブをキューに追加
    test('Queue email delivery job', () async {
      final recipients = ['teacher@example.com', 'admin@example.com'];
      final job = await functionsService.scheduleEmailDelivery(
        userId: 'user_001',
        sourceJobId: 'report_001',
        recipientEmails: recipients,
        subject: 'Your August Report is Ready',
      );

      expect(job.jobId.startsWith('email_'), true);
      expect(job.userId, 'user_001');
      expect(job.sourceJobId, 'report_001');
      expect(job.recipientEmails, recipients);
      expect(job.recipientEmails.length, 2);
      expect(job.status, AsyncJobStatus.queued);
      expect(job.sentCount, 0);
      expect(job.failedCount, 0);
    });

    // Test 4: ジョブステータスを取得
    test('Fetch job status', () async {
      final queuedJob = await functionsService.generateReportAsync(
        userId: 'user_001',
        templateId: 'student_progress',
        format: 'pdf',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        title: 'Test Report',
      );

      final fetchedJob = await functionsService.getJobStatus(queuedJob.jobId);

      expect(fetchedJob.jobId, queuedJob.jobId);
      expect(fetchedJob.userId, queuedJob.userId);
      expect(fetchedJob.status, AsyncJobStatus.queued);
    });

    // Test 5: ジョブステータス更新
    test('Update job status', () async {
      final job = await functionsService.generateReportAsync(
        userId: 'user_001',
        templateId: 'student_progress',
        format: 'pdf',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        title: 'Test Report',
      );

      job.updateStatus(AsyncJobStatus.processing, progress: 50);

      expect(job.status, AsyncJobStatus.processing);
      expect(job.progressPercent, 50);
      expect(job.startedAt, isNotNull);
    });

    // Test 6: ジョブ完了と結果URL
    test('Complete job with result URL', () async {
      final job = await functionsService.generateReportAsync(
        userId: 'user_001',
        templateId: 'student_progress',
        format: 'pdf',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        title: 'Test Report',
      );

      job.updateStatus(
        AsyncJobStatus.completed,
        progress: 100,
      );
      job.resultUrl = 'gs://project-040-bucket/reports/report_001.pdf';

      expect(job.status, AsyncJobStatus.completed);
      expect(job.progressPercent, 100);
      expect(job.resultUrl, 'gs://project-040-bucket/reports/report_001.pdf');
      expect(job.completedAt, isNotNull);
    });

    // Test 7: ジョブエラーハンドリング
    test('Handle job error with retry capability', () async {
      final job = await functionsService.generateReportAsync(
        userId: 'user_001',
        templateId: 'student_progress',
        format: 'pdf',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        title: 'Test Report',
      );

      job.updateStatus(
        AsyncJobStatus.failed,
        error: 'Network timeout while fetching data',
      );

      expect(job.status, AsyncJobStatus.failed);
      expect(job.errorMessage, 'Network timeout while fetching data');
      expect(job.canRetry(), true);
      expect(job.retryCount, 0);
    });

    // Test 8: ジョブリトライロジック
    test('Retry failed job', () async {
      final job = await functionsService.generateReportAsync(
        userId: 'user_001',
        templateId: 'student_progress',
        format: 'pdf',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        title: 'Test Report',
      );

      // 失敗状態に
      job.updateStatus(AsyncJobStatus.failed, error: 'Temporary error');
      expect(job.canRetry(), true);

      // リトライ
      job.retry();
      expect(job.status, AsyncJobStatus.queued);
      expect(job.retryCount, 1);
      expect(job.errorMessage, isNull);

      // 複数回リトライ
      for (int i = 0; i < 3; i++) {
        job.updateStatus(AsyncJobStatus.failed, error: 'Error');
        job.retry();
      }

      expect(job.retryCount, 4);
      expect(job.canRetry(), false);
    });

    // Test 9: ユーザーのジョブ一覧取得
    test('Fetch user jobs list', () async {
      // ユーザー001 のジョブを 3 つ作成
      await functionsService.generateReportAsync(
        userId: 'user_001',
        templateId: 'student_progress',
        format: 'pdf',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        title: 'Report 1',
      );

      await functionsService.exportDataAsync(
        userId: 'user_001',
        dataType: 'student_data',
        format: 'csv',
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now(),
        includePersonalInfo: true,
        maskPersonalData: true,
      );

      // ユーザー002 のジョブを 1 つ作成
      await functionsService.generateReportAsync(
        userId: 'user_002',
        templateId: 'class_performance',
        format: 'excel',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        title: 'Report 2',
      );

      // ユーザー001 のジョブを取得
      final user001Jobs = await functionsService.getUserJobs('user_001', limit: 10);
      expect(user001Jobs.length, 2);
      expect(user001Jobs.every((job) => job.userId == 'user_001'), true);

      // ユーザー002 のジョブを取得
      final user002Jobs = await functionsService.getUserJobs('user_002', limit: 10);
      expect(user002Jobs.length, 1);
      expect(user002Jobs[0].userId, 'user_002');
    });

    // Test 10: ジョブキャンセル
    test('Cancel job', () async {
      final job = await functionsService.generateReportAsync(
        userId: 'user_001',
        templateId: 'student_progress',
        format: 'pdf',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        title: 'Test Report',
      );

      expect(job.status, AsyncJobStatus.queued);

      await functionsService.cancelJob(job.jobId);

      final cancelledJob = await functionsService.getJobStatus(job.jobId);
      expect(cancelledJob.status, AsyncJobStatus.cancelled);
    });

    // Test 11: レポート生成ジョブのシリアライゼーション
    test('Serialize and deserialize report generation job', () async {
      final job = await functionsService.generateReportAsync(
        userId: 'user_001',
        templateId: 'student_progress',
        format: 'pdf',
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 9, 1),
        title: 'August Report',
      );

      final json = job.toJson();
      final restored = ReportGenerationJobForTest.fromJson(json);

      expect(restored.jobId, job.jobId);
      expect(restored.userId, job.userId);
      expect(restored.templateId, job.templateId);
      expect(restored.format, job.format);
      expect(restored.title, job.title);
      expect(restored.status, job.status);
    });

    // Test 12: データエクスポートジョブのシリアライゼーション
    test('Serialize and deserialize export data job', () async {
      final job = await functionsService.exportDataAsync(
        userId: 'user_002',
        dataType: 'student_data',
        format: 'csv',
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 9, 1),
        includePersonalInfo: true,
        maskPersonalData: true,
        encryptionType: 'aes256',
      );

      final json = job.toJson();
      final restored = ExportDataJobForTest.fromJson(json);

      expect(restored.jobId, job.jobId);
      expect(restored.userId, job.userId);
      expect(restored.dataType, job.dataType);
      expect(restored.format, job.format);
      expect(restored.includePersonalInfo, true);
      expect(restored.maskPersonalData, true);
      expect(restored.encryptionType, 'aes256');
    });

    // Test 13: バックグラウンドジョブサービス - レポート生成
    test('BackgroundJobService: Start report generation', () async {
      final job = await jobService.startReportGeneration(
        userId: 'user_001',
        templateId: 'student_progress',
        format: 'pdf',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        title: 'Background Report',
      );

      expect(job.userId, 'user_001');
      expect(job.status, AsyncJobStatus.queued);
    });

    // Test 14: バックグラウンドジョブサービス - データエクスポート
    test('BackgroundJobService: Start data export', () async {
      final job = await jobService.startDataExport(
        userId: 'user_001',
        dataType: 'student_data',
        format: 'excel',
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now(),
        includePersonalInfo: true,
        maskPersonalData: false,
      );

      expect(job.userId, 'user_001');
      expect(job.dataType, 'student_data');
      expect(job.format, 'excel');
      expect(job.status, AsyncJobStatus.queued);
    });

    // Test 15: メール配信ジョブの複数受信者
    test('Email delivery job with multiple recipients', () async {
      final recipients = [
        'teacher1@school.edu',
        'teacher2@school.edu',
        'admin@school.edu',
        'principal@school.edu',
      ];

      final job = await functionsService.scheduleEmailDelivery(
        userId: 'user_001',
        sourceJobId: 'report_001',
        recipientEmails: recipients,
        subject: 'Report Ready for Distribution',
      );

      expect(job.recipientEmails.length, 4);
      expect(job.recipientEmails.contains('teacher1@school.edu'), true);
      expect(job.recipientEmails.contains('teacher2@school.edu'), true);
      expect(job.recipientEmails.contains('admin@school.edu'), true);
      expect(job.recipientEmails.contains('principal@school.edu'), true);
    });

    // Test 16: メール配信進捗トラッキング
    test('Email delivery progress tracking', () async {
      final recipients = ['teacher@example.com', 'admin@example.com', 'principal@example.com'];
      final job = await functionsService.scheduleEmailDelivery(
        userId: 'user_001',
        sourceJobId: 'report_001',
        recipientEmails: recipients,
        subject: 'Report Ready',
      );

      // 初期状態：0/3
      expect(job.sentCount, 0);
      expect(job.failedCount, 0);

      // 1 通配信完了
      job.sentCount = 1;
      expect(job.progressPercent == 33 || job.progressPercent == 34, true);

      // 全て配信完了
      job.sentCount = 3;
      job.updateStatus(AsyncJobStatus.completed, progress: 100);
      expect(job.sentCount, 3);
      expect(job.failedCount, 0);
      expect(job.status, AsyncJobStatus.completed);
    });

    // Test 17: 複数フォーマットレポート生成
    test('Generate reports in multiple formats', () async {
      const formats = ['pdf', 'csv', 'excel', 'json'];
      final jobs = <ReportGenerationJobForTest>[];

      for (String format in formats) {
        final job = await functionsService.generateReportAsync(
          userId: 'user_001',
          templateId: 'student_progress',
          format: format,
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
          title: 'Multi-format Report',
        );
        jobs.add(job as ReportGenerationJobForTest);
      }

      expect(jobs.length, 4);
      for (int i = 0; i < formats.length; i++) {
        expect(jobs[i].format, formats[i]);
      }
    });

    // Test 18: ジョブの作成時刻と完了時刻
    test('Job lifecycle timestamps', () async {
      final job = await functionsService.generateReportAsync(
        userId: 'user_001',
        templateId: 'student_progress',
        format: 'pdf',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
        title: 'Test Report',
      );

      expect(job.createdAt, isNotNull);
      expect(job.startedAt, isNull);
      expect(job.completedAt, isNull);

      job.updateStatus(AsyncJobStatus.processing);
      expect(job.startedAt, isNotNull);
      expect(job.completedAt, isNull);

      job.updateStatus(AsyncJobStatus.completed);
      expect(job.completedAt, isNotNull);

      final duration = job.completedAt!.difference(job.startedAt!);
      expect(duration.isNegative, false);
    });

    // Test 19: プライバシー設定の検証
    test('Privacy settings validation in export job', () async {
      // シナリオ1: 個人情報を含めない
      var job = await functionsService.exportDataAsync(
        userId: 'user_001',
        dataType: 'student_data',
        format: 'csv',
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now(),
        includePersonalInfo: false,
        maskPersonalData: false,
      );

      expect(job.includePersonalInfo, false);
      expect(job.maskPersonalData, false);

      // シナリオ2: 個人情報を含めて、マスク適用
      job = await functionsService.exportDataAsync(
        userId: 'user_001',
        dataType: 'student_data',
        format: 'csv',
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now(),
        includePersonalInfo: true,
        maskPersonalData: true,
      );

      expect(job.includePersonalInfo, true);
      expect(job.maskPersonalData, true);
    });

    // Test 20: 暗号化タイプの指定
    test('Encryption type specification', () async {
      const encryptionTypes = [null, 'none', 'aes256', 'pgp'];

      for (String? encType in encryptionTypes) {
        final job = await functionsService.exportDataAsync(
          userId: 'user_001',
          dataType: 'student_data',
          format: 'csv',
          startDate: DateTime.now().subtract(const Duration(days: 90)),
          endDate: DateTime.now(),
          includePersonalInfo: true,
          maskPersonalData: true,
          encryptionType: encType,
        );

        expect(job.encryptionType, encType);
      }
    });
  });
}

// Test Helper Classes and Enums
enum AsyncJobStatus {
  queued,
  processing,
  completed,
  failed,
  cancelled,
}

enum AsyncJobType {
  reportGeneration,
  emailDelivery,
  dataExport,
  reportDeletion,
}

abstract class AsyncJobBase {
  String get jobId;
  String get userId;
  AsyncJobType get jobType;
  AsyncJobStatus get status;
  DateTime get createdAt;
  DateTime? get startedAt;
  DateTime? get completedAt;
  int get progressPercent;
  String? get errorMessage;
  String? get resultUrl;
  Map<String, dynamic> get metadata;
  int get retryCount;

  void updateStatus(AsyncJobStatus newStatus, {int? progress, String? error});
  bool canRetry();
  void retry();
  bool isCompleted();
  double getProgress();
  Map<String, dynamic> toJson();
}

class ReportGenerationJobForTest implements AsyncJobBase {
  @override
  final String jobId;
  @override
  final String userId;
  @override
  final AsyncJobType jobType = AsyncJobType.reportGeneration;
  @override
  AsyncJobStatus status;
  @override
  final DateTime createdAt;
  @override
  DateTime? startedAt;
  @override
  DateTime? completedAt;
  @override
  int progressPercent;
  @override
  String? errorMessage;
  @override
  String? resultUrl;
  @override
  Map<String, dynamic> metadata;
  @override
  int retryCount;

  final String templateId;
  final String format;
  final DateTime startDate;
  final DateTime endDate;
  final String title;

  ReportGenerationJobForTest({
    required this.jobId,
    required this.userId,
    required this.templateId,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.title,
    this.status = AsyncJobStatus.queued,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.progressPercent = 0,
    this.errorMessage,
    this.resultUrl,
    Map<String, dynamic>? metadata,
    this.retryCount = 0,
  }) : metadata = metadata ?? {};

  @override
  void updateStatus(AsyncJobStatus newStatus, {int? progress, String? error}) {
    status = newStatus;
    if (progress != null) progressPercent = progress.clamp(0, 100);
    if (error != null) errorMessage = error;
    if (newStatus == AsyncJobStatus.processing && startedAt == null) {
      startedAt = DateTime.now();
    }
    if ((newStatus == AsyncJobStatus.completed || newStatus == AsyncJobStatus.failed) &&
        completedAt == null) {
      completedAt = DateTime.now();
    }
  }

  @override
  bool canRetry() => status == AsyncJobStatus.failed && retryCount < 3;

  @override
  void retry() {
    if (canRetry()) {
      retryCount++;
      status = AsyncJobStatus.queued;
      errorMessage = null;
      startedAt = null;
      completedAt = null;
    }
  }

  @override
  bool isCompleted() => status == AsyncJobStatus.completed || status == AsyncJobStatus.failed;

  @override
  double getProgress() => progressPercent / 100.0;

  @override
  Map<String, dynamic> toJson() => {
    'jobId': jobId,
    'userId': userId,
    'templateId': templateId,
    'format': format,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'title': title,
    'status': status.toString(),
    'createdAt': createdAt.toIso8601String(),
    'startedAt': startedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'progressPercent': progressPercent,
    'errorMessage': errorMessage,
    'resultUrl': resultUrl,
    'retryCount': retryCount,
  };

  factory ReportGenerationJobForTest.fromJson(Map<String, dynamic> json) {
    return ReportGenerationJobForTest(
      jobId: json['jobId'] as String,
      userId: json['userId'] as String,
      templateId: json['templateId'] as String,
      format: json['format'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      title: json['title'] as String,
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      progressPercent: json['progressPercent'] as int? ?? 0,
      errorMessage: json['errorMessage'] as String?,
      resultUrl: json['resultUrl'] as String?,
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
}

class ExportDataJobForTest implements AsyncJobBase {
  @override
  final String jobId;
  @override
  final String userId;
  @override
  final AsyncJobType jobType = AsyncJobType.dataExport;
  @override
  AsyncJobStatus status;
  @override
  final DateTime createdAt;
  @override
  DateTime? startedAt;
  @override
  DateTime? completedAt;
  @override
  int progressPercent;
  @override
  String? errorMessage;
  @override
  String? resultUrl;
  @override
  Map<String, dynamic> metadata;
  @override
  int retryCount;

  final String dataType;
  final String format;
  final DateTime startDate;
  final DateTime endDate;
  final bool includePersonalInfo;
  final bool maskPersonalData;
  final String? encryptionType;

  ExportDataJobForTest({
    required this.jobId,
    required this.userId,
    required this.dataType,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.includePersonalInfo,
    required this.maskPersonalData,
    this.encryptionType,
    this.status = AsyncJobStatus.queued,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.progressPercent = 0,
    this.errorMessage,
    this.resultUrl,
    Map<String, dynamic>? metadata,
    this.retryCount = 0,
  }) : metadata = metadata ?? {};

  @override
  void updateStatus(AsyncJobStatus newStatus, {int? progress, String? error}) {
    status = newStatus;
    if (progress != null) progressPercent = progress.clamp(0, 100);
    if (error != null) errorMessage = error;
    if (newStatus == AsyncJobStatus.processing && startedAt == null) {
      startedAt = DateTime.now();
    }
    if ((newStatus == AsyncJobStatus.completed || newStatus == AsyncJobStatus.failed) &&
        completedAt == null) {
      completedAt = DateTime.now();
    }
  }

  @override
  bool canRetry() => status == AsyncJobStatus.failed && retryCount < 3;

  @override
  void retry() {
    if (canRetry()) {
      retryCount++;
      status = AsyncJobStatus.queued;
      errorMessage = null;
      startedAt = null;
      completedAt = null;
    }
  }

  @override
  bool isCompleted() => status == AsyncJobStatus.completed || status == AsyncJobStatus.failed;

  @override
  double getProgress() => progressPercent / 100.0;

  @override
  Map<String, dynamic> toJson() => {
    'jobId': jobId,
    'userId': userId,
    'dataType': dataType,
    'format': format,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'includePersonalInfo': includePersonalInfo,
    'maskPersonalData': maskPersonalData,
    'encryptionType': encryptionType,
    'status': status.toString(),
    'createdAt': createdAt.toIso8601String(),
    'startedAt': startedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'progressPercent': progressPercent,
    'errorMessage': errorMessage,
    'resultUrl': resultUrl,
    'retryCount': retryCount,
  };

  factory ExportDataJobForTest.fromJson(Map<String, dynamic> json) {
    return ExportDataJobForTest(
      jobId: json['jobId'] as String,
      userId: json['userId'] as String,
      dataType: json['dataType'] as String,
      format: json['format'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      includePersonalInfo: json['includePersonalInfo'] as bool? ?? true,
      maskPersonalData: json['maskPersonalData'] as bool? ?? false,
      encryptionType: json['encryptionType'] as String?,
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      progressPercent: json['progressPercent'] as int? ?? 0,
      errorMessage: json['errorMessage'] as String?,
      resultUrl: json['resultUrl'] as String?,
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
}

class StubCloudFunctionsService {
  final Map<String, AsyncJobBase> _jobs = {};

  Future<ReportGenerationJobForTest> generateReportAsync({
    required String userId,
    required String templateId,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
    required String title,
  }) async {
    final jobId = 'report_${DateTime.now().millisecondsSinceEpoch}';
    final job = ReportGenerationJobForTest(
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

  Future<ExportDataJobForTest> exportDataAsync({
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
    final job = ExportDataJobForTest(
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

  Future<EmailDeliveryJobForTest> scheduleEmailDelivery({
    required String userId,
    required String sourceJobId,
    required List<String> recipientEmails,
    required String subject,
  }) async {
    final jobId = 'email_${DateTime.now().millisecondsSinceEpoch}';
    final job = EmailDeliveryJobForTest(
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

  Future<AsyncJobBase> getJobStatus(String jobId) async {
    if (_jobs.containsKey(jobId)) {
      return _jobs[jobId]!;
    }
    throw Exception('Job not found: $jobId');
  }

  Future<List<AsyncJobBase>> getUserJobs(String userId, {int limit = 10}) async {
    return _jobs.values
        .where((job) => job.userId == userId)
        .toList()
        .sublist(0, (_jobs.length < limit ? _jobs.length : limit));
  }

  Future<void> cancelJob(String jobId) async {
    if (_jobs.containsKey(jobId)) {
      _jobs[jobId]!.status = AsyncJobStatus.cancelled;
    }
  }
}

class EmailDeliveryJobForTest implements AsyncJobBase {
  @override
  final String jobId;
  @override
  final String userId;
  @override
  final AsyncJobType jobType = AsyncJobType.emailDelivery;
  @override
  AsyncJobStatus status;
  @override
  final DateTime createdAt;
  @override
  DateTime? startedAt;
  @override
  DateTime? completedAt;
  @override
  int progressPercent;
  @override
  String? errorMessage;
  @override
  String? resultUrl;
  @override
  Map<String, dynamic> metadata;
  @override
  int retryCount;

  final String sourceJobId;
  final List<String> recipientEmails;
  final String subject;
  int sentCount = 0;
  int failedCount = 0;

  EmailDeliveryJobForTest({
    required this.jobId,
    required this.userId,
    required this.sourceJobId,
    required this.recipientEmails,
    required this.subject,
    this.status = AsyncJobStatus.queued,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.progressPercent = 0,
    this.errorMessage,
    this.resultUrl,
    Map<String, dynamic>? metadata,
    this.retryCount = 0,
  }) : metadata = metadata ?? {};

  @override
  void updateStatus(AsyncJobStatus newStatus, {int? progress, String? error}) {
    status = newStatus;
    if (progress != null) progressPercent = progress.clamp(0, 100);
    if (error != null) errorMessage = error;
    if (newStatus == AsyncJobStatus.processing && startedAt == null) {
      startedAt = DateTime.now();
    }
    if ((newStatus == AsyncJobStatus.completed || newStatus == AsyncJobStatus.failed) &&
        completedAt == null) {
      completedAt = DateTime.now();
    }
  }

  @override
  bool canRetry() => status == AsyncJobStatus.failed && retryCount < 3;

  @override
  void retry() {
    if (canRetry()) {
      retryCount++;
      status = AsyncJobStatus.queued;
      errorMessage = null;
      startedAt = null;
      completedAt = null;
    }
  }

  @override
  bool isCompleted() => status == AsyncJobStatus.completed || status == AsyncJobStatus.failed;

  @override
  double getProgress() => progressPercent / 100.0;

  @override
  Map<String, dynamic> toJson() => {
    'jobId': jobId,
    'userId': userId,
    'sourceJobId': sourceJobId,
    'recipientEmails': recipientEmails,
    'subject': subject,
    'sentCount': sentCount,
    'failedCount': failedCount,
    'status': status.toString(),
    'createdAt': createdAt.toIso8601String(),
  };
}

class BackgroundJobService {
  final StubCloudFunctionsService _functionsService;

  BackgroundJobService(this._functionsService);

  Future<ReportGenerationJobForTest> startReportGeneration({
    required String userId,
    required String templateId,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
    required String title,
  }) async {
    return _functionsService.generateReportAsync(
      userId: userId,
      templateId: templateId,
      format: format,
      startDate: startDate,
      endDate: endDate,
      title: title,
    );
  }

  Future<ExportDataJobForTest> startDataExport({
    required String userId,
    required String dataType,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
    required bool includePersonalInfo,
    required bool maskPersonalData,
    String? encryptionType,
  }) async {
    return _functionsService.exportDataAsync(
      userId: userId,
      dataType: dataType,
      format: format,
      startDate: startDate,
      endDate: endDate,
      includePersonalInfo: includePersonalInfo,
      maskPersonalData: maskPersonalData,
      encryptionType: encryptionType,
    );
  }
}

AsyncJobStatus _parseStatus(String status) {
  switch (status) {
    case 'AsyncJobStatus.queued':
      return AsyncJobStatus.queued;
    case 'AsyncJobStatus.processing':
      return AsyncJobStatus.processing;
    case 'AsyncJobStatus.completed':
      return AsyncJobStatus.completed;
    case 'AsyncJobStatus.failed':
      return AsyncJobStatus.failed;
    case 'AsyncJobStatus.cancelled':
      return AsyncJobStatus.cancelled;
    default:
      return AsyncJobStatus.queued;
  }
}
