/// Phase 20: 非同期ジョブ管理モデル
/// Cloud Functions でのバックグラウンド処理の状態を管理

/// 非同期ジョブのステータス
enum AsyncJobStatus {
  /// キューに登録済み
  queued,

  /// 処理中
  processing,

  /// 完了
  completed,

  /// エラー発生
  failed,

  /// キャンセル
  cancelled,
}

/// ジョブタイプ
enum AsyncJobType {
  /// レポート生成
  reportGeneration,

  /// メール配信
  emailDelivery,

  /// データエクスポート
  dataExport,

  /// レポート削除
  reportDeletion,
}

/// 非同期ジョブの基本モデル
class AsyncJob {
  /// ジョブ ID
  final String jobId;

  /// ユーザー ID
  final String userId;

  /// ジョブタイプ
  final AsyncJobType jobType;

  /// 現在のステータス
  AsyncJobStatus status;

  /// 作成日時
  final DateTime createdAt;

  /// 開始日時
  DateTime? startedAt;

  /// 完了日時
  DateTime? completedAt;

  /// 進捗（0-100）
  int progressPercent;

  /// エラーメッセージ
  String? errorMessage;

  /// 結果 URL（ダウンロードリンクなど）
  String? resultUrl;

  /// メタデータ
  final Map<String, dynamic> metadata;

  /// リトライ回数
  int retryCount;

  /// 最大リトライ回数
  static const int maxRetries = 3;

  AsyncJob({
    required this.jobId,
    required this.userId,
    required this.jobType,
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

  /// JSON シリアライザ
  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'userId': userId,
      'jobType': jobType.toString(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'progressPercent': progressPercent,
      'errorMessage': errorMessage,
      'resultUrl': resultUrl,
      'metadata': metadata,
      'retryCount': retryCount,
    };
  }

  /// JSON デシリアライザ
  factory AsyncJob.fromJson(Map<String, dynamic> json) {
    return AsyncJob(
      jobId: json['jobId'] as String,
      userId: json['userId'] as String,
      jobType: _parseJobType(json['jobType'] as String),
      status: _parseJobStatus(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      progressPercent: json['progressPercent'] as int? ?? 0,
      errorMessage: json['errorMessage'] as String?,
      resultUrl: json['resultUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  /// ステータス更新
  void updateStatus(AsyncJobStatus newStatus, {int? progress, String? error}) {
    status = newStatus;
    if (progress != null) {
      progressPercent = progress.clamp(0, 100);
    }
    if (error != null) {
      errorMessage = error;
    }
    if (newStatus == AsyncJobStatus.processing && startedAt == null) {
      startedAt = DateTime.now();
    }
    if ((newStatus == AsyncJobStatus.completed || newStatus == AsyncJobStatus.failed) &&
        completedAt == null) {
      completedAt = DateTime.now();
    }
  }

  /// リトライ可能かどうか
  bool canRetry() {
    return status == AsyncJobStatus.failed && retryCount < maxRetries;
  }

  /// リトライを実行
  void retry() {
    if (canRetry()) {
      retryCount++;
      status = AsyncJobStatus.queued;
      errorMessage = null;
      startedAt = null;
      completedAt = null;
    }
  }

  /// 完了しているかどうか
  bool isCompleted() {
    return status == AsyncJobStatus.completed || status == AsyncJobStatus.failed;
  }

  /// 進捗率を取得
  double getProgress() {
    return progressPercent / 100.0;
  }
}

/// レポート生成ジョブの詳細
class ReportGenerationJob extends AsyncJob {
  /// テンプレート ID
  final String templateId;

  /// レポートフォーマット
  final String format;

  /// 期間開始日
  final DateTime startDate;

  /// 期間終了日
  final DateTime endDate;

  /// レポートタイトル
  final String title;

  ReportGenerationJob({
    required String jobId,
    required String userId,
    required this.templateId,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.title,
    AsyncJobStatus status = AsyncJobStatus.queued,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    int progressPercent = 0,
    String? errorMessage,
    String? resultUrl,
    Map<String, dynamic>? metadata,
    int retryCount = 0,
  }) : super(
    jobId: jobId,
    userId: userId,
    jobType: AsyncJobType.reportGeneration,
    status: status,
    createdAt: createdAt,
    startedAt: startedAt,
    completedAt: completedAt,
    progressPercent: progressPercent,
    errorMessage: errorMessage,
    resultUrl: resultUrl,
    metadata: metadata,
    retryCount: retryCount,
  );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'templateId': templateId,
      'format': format,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'title': title,
    });
    return json;
  }

  factory ReportGenerationJob.fromJson(Map<String, dynamic> json) {
    return ReportGenerationJob(
      jobId: json['jobId'] as String,
      userId: json['userId'] as String,
      templateId: json['templateId'] as String,
      format: json['format'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      title: json['title'] as String,
      status: _parseJobStatus(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      progressPercent: json['progressPercent'] as int? ?? 0,
      errorMessage: json['errorMessage'] as String?,
      resultUrl: json['resultUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
}

/// データエクスポートジョブの詳細
class ExportDataJob extends AsyncJob {
  /// データタイプ
  final String dataType;

  /// エクスポートフォーマット
  final String format;

  /// 期間開始日
  final DateTime startDate;

  /// 期間終了日
  final DateTime endDate;

  /// 個人情報を含めるかどうか
  final bool includePersonalInfo;

  /// 個人情報をマスクするかどうか
  final bool maskPersonalData;

  /// 暗号化タイプ
  final String? encryptionType;

  ExportDataJob({
    required String jobId,
    required String userId,
    required this.dataType,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.includePersonalInfo,
    required this.maskPersonalData,
    this.encryptionType,
    AsyncJobStatus status = AsyncJobStatus.queued,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    int progressPercent = 0,
    String? errorMessage,
    String? resultUrl,
    Map<String, dynamic>? metadata,
    int retryCount = 0,
  }) : super(
    jobId: jobId,
    userId: userId,
    jobType: AsyncJobType.dataExport,
    status: status,
    createdAt: createdAt,
    startedAt: startedAt,
    completedAt: completedAt,
    progressPercent: progressPercent,
    errorMessage: errorMessage,
    resultUrl: resultUrl,
    metadata: metadata,
    retryCount: retryCount,
  );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'dataType': dataType,
      'format': format,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'includePersonalInfo': includePersonalInfo,
      'maskPersonalData': maskPersonalData,
      'encryptionType': encryptionType,
    });
    return json;
  }

  factory ExportDataJob.fromJson(Map<String, dynamic> json) {
    return ExportDataJob(
      jobId: json['jobId'] as String,
      userId: json['userId'] as String,
      dataType: json['dataType'] as String,
      format: json['format'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      includePersonalInfo: json['includePersonalInfo'] as bool? ?? true,
      maskPersonalData: json['maskPersonalData'] as bool? ?? false,
      encryptionType: json['encryptionType'] as String?,
      status: _parseJobStatus(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      progressPercent: json['progressPercent'] as int? ?? 0,
      errorMessage: json['errorMessage'] as String?,
      resultUrl: json['resultUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
}

/// メール配信ジョブの詳細
class EmailDeliveryJob extends AsyncJob {
  /// 配信者（レポートまたはエクスポートのジョブID）
  final String sourceJobId;

  /// 受信者メールアドレス
  final List<String> recipientEmails;

  /// メール件名
  final String subject;

  /// 送信完了した件数
  int sentCount;

  /// 送信失敗した件数
  int failedCount;

  EmailDeliveryJob({
    required String jobId,
    required String userId,
    required this.sourceJobId,
    required this.recipientEmails,
    required this.subject,
    this.sentCount = 0,
    this.failedCount = 0,
    AsyncJobStatus status = AsyncJobStatus.queued,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    int progressPercent = 0,
    String? errorMessage,
    String? resultUrl,
    Map<String, dynamic>? metadata,
    int retryCount = 0,
  }) : super(
    jobId: jobId,
    userId: userId,
    jobType: AsyncJobType.emailDelivery,
    status: status,
    createdAt: createdAt,
    startedAt: startedAt,
    completedAt: completedAt,
    progressPercent: progressPercent,
    errorMessage: errorMessage,
    resultUrl: resultUrl,
    metadata: metadata,
    retryCount: retryCount,
  );

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'sourceJobId': sourceJobId,
      'recipientEmails': recipientEmails,
      'subject': subject,
      'sentCount': sentCount,
      'failedCount': failedCount,
    });
    return json;
  }

  factory EmailDeliveryJob.fromJson(Map<String, dynamic> json) {
    return EmailDeliveryJob(
      jobId: json['jobId'] as String,
      userId: json['userId'] as String,
      sourceJobId: json['sourceJobId'] as String,
      recipientEmails: List<String>.from(json['recipientEmails'] as List),
      subject: json['subject'] as String,
      sentCount: json['sentCount'] as int? ?? 0,
      failedCount: json['failedCount'] as int? ?? 0,
      status: _parseJobStatus(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      progressPercent: json['progressPercent'] as int? ?? 0,
      errorMessage: json['errorMessage'] as String?,
      resultUrl: json['resultUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
}

/// ヘルパー関数
AsyncJobStatus _parseJobStatus(String status) {
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

AsyncJobType _parseJobType(String type) {
  switch (type) {
    case 'AsyncJobType.reportGeneration':
      return AsyncJobType.reportGeneration;
    case 'AsyncJobType.emailDelivery':
      return AsyncJobType.emailDelivery;
    case 'AsyncJobType.dataExport':
      return AsyncJobType.dataExport;
    case 'AsyncJobType.reportDeletion':
      return AsyncJobType.reportDeletion;
    default:
      return AsyncJobType.reportGeneration;
  }
}
