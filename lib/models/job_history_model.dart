/// Phase 23: ジョブ履歴モデル
/// ジョブの履歴管理と詳細追跡

import 'async_job_model.dart';

/// ジョブ履歴エントリ
class JobHistoryEntry {
  /// エントリ ID
  final String entryId;

  /// ジョブ ID
  final String jobId;

  /// 変更タイプ
  final JobHistoryEventType eventType;

  /// 前の状態
  final AsyncJobStatus? previousStatus;

  /// 新しい状態
  final AsyncJobStatus? newStatus;

  /// イベントメッセージ
  final String message;

  /// タイムスタンプ
  final DateTime timestamp;

  /// メタデータ
  final Map<String, dynamic> metadata;

  const JobHistoryEntry({
    required this.entryId,
    required this.jobId,
    required this.eventType,
    this.previousStatus,
    this.newStatus,
    required this.message,
    required this.timestamp,
    this.metadata = const {},
  });

  /// JSON に変換
  Map<String, dynamic> toJson() {
    return {
      'entryId': entryId,
      'jobId': jobId,
      'eventType': eventType.toString().split('.').last,
      'previousStatus': previousStatus?.toString().split('.').last,
      'newStatus': newStatus?.toString().split('.').last,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// JSON から作成
  factory JobHistoryEntry.fromJson(Map<String, dynamic> json) {
    final eventTypeStr = json['eventType'] as String;
    final eventType = JobHistoryEventType.values.firstWhere(
      (e) => e.toString().split('.').last == eventTypeStr,
      orElse: () => JobHistoryEventType.statusChanged,
    );

    final prevStatusStr = json['previousStatus'] as String?;
    final AsyncJobStatus? previousStatus = prevStatusStr != null
        ? AsyncJobStatus.values.firstWhere(
            (e) => e.toString().split('.').last == prevStatusStr,
            orElse: () => AsyncJobStatus.queued,
          )
        : null;

    final newStatusStr = json['newStatus'] as String?;
    final AsyncJobStatus? newStatus = newStatusStr != null
        ? AsyncJobStatus.values.firstWhere(
            (e) => e.toString().split('.').last == newStatusStr,
            orElse: () => AsyncJobStatus.queued,
          )
        : null;

    return JobHistoryEntry(
      entryId: json['entryId'] as String,
      jobId: json['jobId'] as String,
      eventType: eventType,
      previousStatus: previousStatus,
      newStatus: newStatus,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }
}

/// ジョブ履歴イベントタイプ
enum JobHistoryEventType {
  created,
  queued,
  started,
  progress,
  completed,
  failed,
  cancelled,
  retried,
  statusChanged,
  errorOccurred,
  metadataUpdated,
}

/// ジョブ履歴フィルター
class JobHistoryFilter {
  /// ジョブ ID（オプション）
  final String? jobId;

  /// イベントタイプリスト（オプション）
  final List<JobHistoryEventType>? eventTypes;

  /// 開始日時
  final DateTime? startDate;

  /// 終了日時
  final DateTime? endDate;

  /// 検索テキスト
  final String? searchText;

  /// 最大件数
  final int limit;

  /// オフセット
  final int offset;

  /// ソート順（asc/desc）
  final String sortOrder;

  const JobHistoryFilter({
    this.jobId,
    this.eventTypes,
    this.startDate,
    this.endDate,
    this.searchText,
    this.limit = 50,
    this.offset = 0,
    this.sortOrder = 'desc',
  });

  /// フィルター条件を満たすかチェック
  bool matches(JobHistoryEntry entry) {
    if (jobId != null && entry.jobId != jobId) return false;
    if (eventTypes != null && !eventTypes!.contains(entry.eventType)) return false;
    if (startDate != null && entry.timestamp.isBefore(startDate!)) return false;
    if (endDate != null && entry.timestamp.isAfter(endDate!)) return false;
    if (searchText != null && !entry.message.toLowerCase().contains(searchText!.toLowerCase())) {
      return false;
    }
    return true;
  }

  /// コピー
  JobHistoryFilter copyWith({
    String? jobId,
    List<JobHistoryEventType>? eventTypes,
    DateTime? startDate,
    DateTime? endDate,
    String? searchText,
    int? limit,
    int? offset,
    String? sortOrder,
  }) {
    return JobHistoryFilter(
      jobId: jobId ?? this.jobId,
      eventTypes: eventTypes ?? this.eventTypes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchText: searchText ?? this.searchText,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// 高度なジョブフィルター
class AdvancedJobFilter {
  /// ジョブタイプリスト
  final List<AsyncJobType>? jobTypes;

  /// ステータスリスト
  final List<AsyncJobStatus>? statuses;

  /// 開始日時（開始日）
  final DateTime? createdFromDate;

  /// 終了日時（終了日）
  final DateTime? createdToDate;

  /// 完了日時（開始）
  final DateTime? completedFromDate;

  /// 完了日時（終了）
  final DateTime? completedToDate;

  /// 進捗率下限
  final int? minProgress;

  /// 進捗率上限
  final int? maxProgress;

  /// ユーザーフィルター
  final String? userId;

  /// 検索テキスト
  final String? searchText;

  /// エラー状態のみ
  final bool errorsOnly;

  /// リトライ回数
  final int? minRetries;

  /// ソート対象フィールド
  final JobSortField sortBy;

  /// ソート順
  final SortOrder sortOrder;

  const AdvancedJobFilter({
    this.jobTypes,
    this.statuses,
    this.createdFromDate,
    this.createdToDate,
    this.completedFromDate,
    this.completedToDate,
    this.minProgress,
    this.maxProgress,
    this.userId,
    this.searchText,
    this.errorsOnly = false,
    this.minRetries,
    this.sortBy = JobSortField.createdAt,
    this.sortOrder = SortOrder.descending,
  });

  /// フィルター条件を満たすかチェック
  bool matches(AsyncJob job) {
    if (jobTypes != null && !jobTypes!.contains(job.jobType)) return false;
    if (statuses != null && !statuses!.contains(job.status)) return false;
    if (createdFromDate != null && job.createdAt.isBefore(createdFromDate!)) return false;
    if (createdToDate != null && job.createdAt.isAfter(createdToDate!)) return false;
    if (completedFromDate != null && (job.completedAt == null || job.completedAt!.isBefore(completedFromDate!))) {
      return false;
    }
    if (completedToDate != null && (job.completedAt == null || job.completedAt!.isAfter(completedToDate!))) {
      return false;
    }
    if (minProgress != null && job.progressPercent < minProgress!) return false;
    if (maxProgress != null && job.progressPercent > maxProgress!) return false;
    if (userId != null && job.userId != userId) return false;
    if (searchText != null && !_matchesSearchText(job)) return false;
    if (errorsOnly && job.status != AsyncJobStatus.failed) return false;
    if (minRetries != null && job.retryCount < minRetries!) return false;
    return true;
  }

  /// 検索テキストにマッチするかチェック
  bool _matchesSearchText(AsyncJob job) {
    final query = searchText!.toLowerCase();
    if (job.jobId.toLowerCase().contains(query)) return true;
    if (job.errorMessage?.toLowerCase().contains(query) ?? false) return true;
    if (job is ReportGenerationJob && job.title.toLowerCase().contains(query)) return true;
    if (job is EmailDeliveryJob && job.subject.toLowerCase().contains(query)) return true;
    return false;
  }

  /// コピー
  AdvancedJobFilter copyWith({
    List<AsyncJobType>? jobTypes,
    List<AsyncJobStatus>? statuses,
    DateTime? createdFromDate,
    DateTime? createdToDate,
    DateTime? completedFromDate,
    DateTime? completedToDate,
    int? minProgress,
    int? maxProgress,
    String? userId,
    String? searchText,
    bool? errorsOnly,
    int? minRetries,
    JobSortField? sortBy,
    SortOrder? sortOrder,
  }) {
    return AdvancedJobFilter(
      jobTypes: jobTypes ?? this.jobTypes,
      statuses: statuses ?? this.statuses,
      createdFromDate: createdFromDate ?? this.createdFromDate,
      createdToDate: createdToDate ?? this.createdToDate,
      completedFromDate: completedFromDate ?? this.completedFromDate,
      completedToDate: completedToDate ?? this.completedToDate,
      minProgress: minProgress ?? this.minProgress,
      maxProgress: maxProgress ?? this.maxProgress,
      userId: userId ?? this.userId,
      searchText: searchText ?? this.searchText,
      errorsOnly: errorsOnly ?? this.errorsOnly,
      minRetries: minRetries ?? this.minRetries,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// ジョブソートフィールド
enum JobSortField {
  createdAt,
  startedAt,
  completedAt,
  progressPercent,
  retryCount,
  status,
}

/// ソート順
enum SortOrder {
  ascending,
  descending,
}
