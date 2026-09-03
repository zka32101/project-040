/// Phase 21: ジョブ監視 UI モデル
/// バックグラウンドジョブの進捗状態をUIで表示するためのモデル

import '../models/async_job_model.dart';

/// ジョブ監視ダッシュボードの表示状態
class JobMonitoringState {
  /// アクティブジョブのリスト
  final List<AsyncJob> activeJobs;

  /// 完了済みジョブのリスト
  final List<AsyncJob> completedJobs;

  /// 失敗したジョブのリスト
  final List<AsyncJob> failedJobs;

  /// 現在選択されているジョブ ID
  final String? selectedJobId;

  /// ロード中かどうか
  final bool isLoading;

  /// エラーメッセージ
  final String? errorMessage;

  /// 最後に更新された時刻
  final DateTime? lastUpdatedAt;

  /// フィルタリングモード
  final JobFilterMode filterMode;

  JobMonitoringState({
    required this.activeJobs,
    required this.completedJobs,
    required this.failedJobs,
    this.selectedJobId,
    this.isLoading = false,
    this.errorMessage,
    this.lastUpdatedAt,
    this.filterMode = JobFilterMode.all,
  });

  /// ジョブの総数
  int get totalJobCount => activeJobs.length + completedJobs.length + failedJobs.length;

  /// アクティブなジョブの平均進捗率
  double get averageProgress {
    if (activeJobs.isEmpty) return 0.0;
    final totalProgress = activeJobs.fold<int>(0, (sum, job) => sum + job.progressPercent);
    return totalProgress / activeJobs.length / 100.0;
  }

  /// 選択されたジョブを取得
  AsyncJob? getSelectedJob() {
    if (selectedJobId == null) return null;

    try {
      return activeJobs.firstWhere((j) => j.jobId == selectedJobId) ??
          completedJobs.firstWhere((j) => j.jobId == selectedJobId) ??
          failedJobs.firstWhere((j) => j.jobId == selectedJobId);
    } catch (e) {
      return null;
    }
  }

  /// 状態をコピーして新しいインスタンスを作成
  JobMonitoringState copyWith({
    List<AsyncJob>? activeJobs,
    List<AsyncJob>? completedJobs,
    List<AsyncJob>? failedJobs,
    String? selectedJobId,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastUpdatedAt,
    JobFilterMode? filterMode,
  }) {
    return JobMonitoringState(
      activeJobs: activeJobs ?? this.activeJobs,
      completedJobs: completedJobs ?? this.completedJobs,
      failedJobs: failedJobs ?? this.failedJobs,
      selectedJobId: selectedJobId ?? this.selectedJobId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      filterMode: filterMode ?? this.filterMode,
    );
  }
}

/// ジョブ監視のフィルタリングモード
enum JobFilterMode {
  /// すべてのジョブを表示
  all,

  /// アクティブなジョブのみ表示
  active,

  /// 完了済みジョブのみ表示
  completed,

  /// 失敗したジョブのみ表示
  failed,
}

/// ジョブ通知イベント
class JobNotificationEvent {
  /// イベントの種類
  final JobNotificationType type;

  /// 関連するジョブ ID
  final String jobId;

  /// ジョブのタイプ
  final AsyncJobType jobType;

  /// 通知メッセージ
  final String message;

  /// イベントの発生時刻
  final DateTime timestamp;

  /// 関連するデータ（オプション）
  final Map<String, dynamic>? metadata;

  JobNotificationEvent({
    required this.type,
    required this.jobId,
    required this.jobType,
    required this.message,
    required this.timestamp,
    this.metadata,
  });

  /// JSON シリアライザ
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'jobId': jobId,
      'jobType': jobType.toString(),
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// JSON デシリアライザ
  factory JobNotificationEvent.fromJson(Map<String, dynamic> json) {
    return JobNotificationEvent(
      type: _parseNotificationType(json['type'] as String),
      jobId: json['jobId'] as String,
      jobType: _parseJobType(json['jobType'] as String),
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// ジョブ通知イベントの種類
enum JobNotificationType {
  /// ジョブがキューに登録された
  queued,

  /// ジョブの処理が開始した
  started,

  /// ジョブが進行中
  progress,

  /// ジョブが完了した
  completed,

  /// ジョブが失敗した
  failed,

  /// ジョブがキャンセルされた
  cancelled,

  /// リトライが実行された
  retrying,
}

/// ジョブ監視の詳細情報
class JobMonitoringDetails {
  /// ジョブ ID
  final String jobId;

  /// ジョブのタイプ
  final AsyncJobType jobType;

  /// 現在のステータス
  final AsyncJobStatus status;

  /// 進捗率（0-100）
  final int progressPercent;

  /// 予測される残り時間
  final Duration? estimatedTimeRemaining;

  /// ジョブが処理に要した時間
  final Duration elapsedTime;

  /// スループット情報（例：処理済みレコード数/秒）
  final double? throughputPerSecond;

  /// エラーが発生した場合のエラーメッセージ
  final String? errorMessage;

  /// 最後の更新時刻
  final DateTime lastUpdatedAt;

  /// リトライ情報
  final RetryInfo? retryInfo;

  JobMonitoringDetails({
    required this.jobId,
    required this.jobType,
    required this.status,
    required this.progressPercent,
    this.estimatedTimeRemaining,
    required this.elapsedTime,
    this.throughputPerSecond,
    this.errorMessage,
    required this.lastUpdatedAt,
    this.retryInfo,
  });

  /// 進捗率を 0.0-1.0 の範囲で取得
  double get normalizedProgress => progressPercent / 100.0;

  /// ジョブが完了しているかどうか
  bool get isComplete => status == AsyncJobStatus.completed || status == AsyncJobStatus.failed;
}

/// リトライ情報
class RetryInfo {
  /// 現在のリトライ回数
  final int currentRetryCount;

  /// 最大リトライ回数
  final int maxRetries;

  /// 次のリトライ予定時刻
  final DateTime? nextRetryAt;

  /// リトライ履歴
  final List<RetryAttempt> attempts;

  RetryInfo({
    required this.currentRetryCount,
    required this.maxRetries,
    this.nextRetryAt,
    required this.attempts,
  });

  /// リトライ可能かどうか
  bool get canRetry => currentRetryCount < maxRetries;

  /// 残りリトライ回数
  int get remainingRetries => maxRetries - currentRetryCount;
}

/// リトライ試行の履歴
class RetryAttempt {
  /// 試行番号
  final int attemptNumber;

  /// 試行日時
  final DateTime attemptedAt;

  /// 失敗理由
  final String? failureReason;

  /// 結果ステータス
  final AsyncJobStatus resultStatus;

  RetryAttempt({
    required this.attemptNumber,
    required this.attemptedAt,
    this.failureReason,
    required this.resultStatus,
  });
}

/// ヘルパー関数
JobNotificationType _parseNotificationType(String type) {
  switch (type) {
    case 'JobNotificationType.queued':
      return JobNotificationType.queued;
    case 'JobNotificationType.started':
      return JobNotificationType.started;
    case 'JobNotificationType.progress':
      return JobNotificationType.progress;
    case 'JobNotificationType.completed':
      return JobNotificationType.completed;
    case 'JobNotificationType.failed':
      return JobNotificationType.failed;
    case 'JobNotificationType.cancelled':
      return JobNotificationType.cancelled;
    case 'JobNotificationType.retrying':
      return JobNotificationType.retrying;
    default:
      return JobNotificationType.progress;
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
