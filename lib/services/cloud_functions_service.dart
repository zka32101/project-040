/// Phase 20: Firebase Cloud Functions 統合サービス
/// バックグラウンド非同期処理を Cloud Functions で実行

import '../models/async_job_model.dart';
import '../models/report_model.dart';

/// Cloud Functions サービスのインターフェース
abstract class CloudFunctionsService {
  /// レポート生成ジョブをキューに追加
  Future<ReportGenerationJob> generateReportAsync({
    required String userId,
    required String templateId,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
    required String title,
  });

  /// データエクスポートジョブをキューに追加
  Future<ExportDataJob> exportDataAsync({
    required String userId,
    required String dataType,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
    required bool includePersonalInfo,
    required bool maskPersonalData,
    String? encryptionType,
  });

  /// メール配信ジョブをキューに追加
  Future<EmailDeliveryJob> scheduleEmailDelivery({
    required String userId,
    required String sourceJobId,
    required List<String> recipientEmails,
    required String subject,
  });

  /// ジョブのステータスを取得
  Future<AsyncJob> getJobStatus(String jobId);

  /// ユーザーのジョブ一覧を取得
  Future<List<AsyncJob>> getUserJobs(String userId, {int limit = 10});

  /// ジョブをキャンセル
  Future<void> cancelJob(String jobId);
}

/// デフォルト実装（HTTP 経由で Cloud Functions を呼び出し）
class FirebaseCloudFunctionsService implements CloudFunctionsService {
  /// Cloud Functions のベース URL
  static const String _functionsUrl = 'https://asia-northeast1-project-040.cloudfunctions.net';

  @override
  Future<ReportGenerationJob> generateReportAsync({
    required String userId,
    required String templateId,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
    required String title,
  }) async {
    try {
      // Cloud Function: generateReportAsync を呼び出し
      // 実装時は、HTTP クライアントで実際に呼び出す
      final jobId = _generateJobId('report');

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

      // Firestore の asyncJobs/{jobId} に保存
      // await _firestoreService.saveAsyncJob(job);

      return job;
    } catch (e) {
      throw Exception('Failed to queue report generation: $e');
    }
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
    try {
      // Cloud Function: exportDataAsync を呼び出し
      final jobId = _generateJobId('export');

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

      // Firestore の asyncJobs/{jobId} に保存
      // await _firestoreService.saveAsyncJob(job);

      return job;
    } catch (e) {
      throw Exception('Failed to queue data export: $e');
    }
  }

  @override
  Future<EmailDeliveryJob> scheduleEmailDelivery({
    required String userId,
    required String sourceJobId,
    required List<String> recipientEmails,
    required String subject,
  }) async {
    try {
      // Cloud Function: sendScheduledEmails を呼び出し
      final jobId = _generateJobId('email');

      final job = EmailDeliveryJob(
        jobId: jobId,
        userId: userId,
        sourceJobId: sourceJobId,
        recipientEmails: recipientEmails,
        subject: subject,
        status: AsyncJobStatus.queued,
        createdAt: DateTime.now(),
      );

      // Firestore の asyncJobs/{jobId} に保存
      // await _firestoreService.saveAsyncJob(job);

      return job;
    } catch (e) {
      throw Exception('Failed to schedule email delivery: $e');
    }
  }

  @override
  Future<AsyncJob> getJobStatus(String jobId) async {
    try {
      // Firestore から asyncJobs/{jobId} を取得
      // final docSnap = await _firestore.collection('asyncJobs').doc(jobId).get();
      // return AsyncJob.fromJson(docSnap.data()!);

      // 実装時は上記のコメント部分を有効化
      throw UnimplementedError('getJobStatus must be implemented with Firestore');
    } catch (e) {
      throw Exception('Failed to fetch job status: $e');
    }
  }

  @override
  Future<List<AsyncJob>> getUserJobs(String userId, {int limit = 10}) async {
    try {
      // Firestore から asyncJobs/?where=userId==userId の記録を取得
      // final query = _firestore
      //     .collection('asyncJobs')
      //     .where('userId', isEqualTo: userId)
      //     .orderBy('createdAt', descending: true)
      //     .limit(limit);
      // final docs = await query.get();
      // return docs.docs.map((doc) => AsyncJob.fromJson(doc.data())).toList();

      return [];
    } catch (e) {
      throw Exception('Failed to fetch user jobs: $e');
    }
  }

  @override
  Future<void> cancelJob(String jobId) async {
    try {
      // Firestore asyncJobs/{jobId} の status を cancelled に更新
      // await _firestore
      //     .collection('asyncJobs')
      //     .doc(jobId)
      //     .update({'status': 'AsyncJobStatus.cancelled'});
    } catch (e) {
      throw Exception('Failed to cancel job: $e');
    }
  }

  /// ジョブ ID を生成
  String _generateJobId(String prefix) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_${timestamp}_${_randomId()}';
  }

  /// ランダムID を生成
  String _randomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    var result = '';
    for (var i = 0; i < 8; i++) {
      result += chars[DateTime.now().millisecond % chars.length];
    }
    return result;
  }
}

/// テスト用スタブ実装
class StubCloudFunctionsService implements CloudFunctionsService {
  /// シミュレートされたジョブストレージ
  final Map<String, AsyncJob> _jobs = {};

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

    // シミュレーション：1秒後に processing へ
    Future.delayed(const Duration(seconds: 1), () {
      if (_jobs.containsKey(jobId)) {
        _jobs[jobId]!.updateStatus(AsyncJobStatus.processing, progress: 25);
      }
    });

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

/// バックグラウンドジョブサービス
class BackgroundJobService {
  final CloudFunctionsService _functionsService;

  BackgroundJobService(this._functionsService);

  /// レポート生成ジョブを開始（ユーザーに通知なしで開始）
  Future<ReportGenerationJob> startReportGeneration({
    required String userId,
    required String templateId,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
    required String title,
  }) async {
    final job = await _functionsService.generateReportAsync(
      userId: userId,
      templateId: templateId,
      format: format,
      startDate: startDate,
      endDate: endDate,
      title: title,
    );

    // Firestore に保存（実装時）
    // await _firestoreService.saveAsyncJob(job);

    return job;
  }

  /// データエクスポートジョブを開始
  Future<ExportDataJob> startDataExport({
    required String userId,
    required String dataType,
    required String format,
    required DateTime startDate,
    required DateTime endDate,
    required bool includePersonalInfo,
    required bool maskPersonalData,
    String? encryptionType,
  }) async {
    final job = await _functionsService.exportDataAsync(
      userId: userId,
      dataType: dataType,
      format: format,
      startDate: startDate,
      endDate: endDate,
      includePersonalInfo: includePersonalInfo,
      maskPersonalData: maskPersonalData,
      encryptionType: encryptionType,
    );

    return job;
  }

  /// ジョブの完了を待つ（タイムアウト付き）
  Future<AsyncJob> waitForCompletion(
    String jobId, {
    Duration timeout = const Duration(minutes: 10),
    Duration pollInterval = const Duration(seconds: 2),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      final job = await _functionsService.getJobStatus(jobId);

      if (job.isCompleted()) {
        return job;
      }

      await Future.delayed(pollInterval);
    }

    throw Exception('Job did not complete within timeout: $jobId');
  }

  /// ジョブの進捗をポーリング
  Stream<AsyncJob> watchJobProgress(String jobId, {Duration pollInterval = const Duration(seconds: 2)}) async* {
    while (true) {
      try {
        final job = await _functionsService.getJobStatus(jobId);
        yield job;

        if (job.isCompleted()) {
          break;
        }
      } catch (e) {
        yield* Stream.error(e);
        break;
      }

      await Future.delayed(pollInterval);
    }
  }
}
