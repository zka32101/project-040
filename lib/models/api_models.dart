/// Phase 27: API モデル
/// REST API のリクエスト・レスポンスモデル

import 'async_job_model.dart';
import 'analytics_model.dart';
import 'search_export_model.dart';

// ==================== 認証関連 ====================

/// ログインリクエスト
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

/// ログインレスポンス
class LoginResponse {
  final String userId;
  final String token;
  final String refreshToken;
  final DateTime expiresAt;

  const LoginResponse({
    required this.userId,
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json['userId'] as String,
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}

/// トークンリフレッシュリクエスト
class RefreshTokenRequest {
  final String refreshToken;

  const RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

// ==================== ジョブ関連 ====================

/// ジョブ作成リクエスト
class CreateJobRequest {
  final String userId;
  final AsyncJobType jobType;
  final Map<String, dynamic> parameters;

  const CreateJobRequest({
    required this.userId,
    required this.jobType,
    required this.parameters,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'jobType': jobType.toString().split('.').last,
        'parameters': parameters,
      };
}

/// ジョブリストレスポンス
class JobListResponse {
  final List<AsyncJob> jobs;
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  const JobListResponse({
    required this.jobs,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  factory JobListResponse.fromJson(Map<String, dynamic> json) {
    return JobListResponse(
      jobs: (json['jobs'] as List)
          .map((j) => AsyncJob.fromJson(j as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      pageNumber: json['pageNumber'] as int,
      pageSize: json['pageSize'] as int,
    );
  }

  int get totalPages => (totalCount + pageSize - 1) ~/ pageSize;
}

/// ジョブ更新リクエスト
class UpdateJobRequest {
  final String jobId;
  final AsyncJobStatus? status;
  final int? progressPercent;
  final Map<String, dynamic>? metadata;

  const UpdateJobRequest({
    required this.jobId,
    this.status,
    this.progressPercent,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'jobId': jobId,
        if (status != null) 'status': status.toString().split('.').last,
        if (progressPercent != null) 'progressPercent': progressPercent,
        if (metadata != null) 'metadata': metadata,
      };
}

// ==================== 分析関連 ====================

/// 分析レポートリクエスト
class AnalyticsReportRequest {
  final String userId;
  final ReportType reportType;
  final DateRange period;
  final List<String>? jobTypeFilter;

  const AnalyticsReportRequest({
    required this.userId,
    required this.reportType,
    required this.period,
    this.jobTypeFilter,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'reportType': reportType.toString().split('.').last,
        'period': {
          'startDate': period.startDate.toIso8601String(),
          'endDate': period.endDate.toIso8601String(),
        },
        if (jobTypeFilter != null) 'jobTypeFilter': jobTypeFilter,
      };
}

/// 分析レポートレスポンス
class AnalyticsReportResponse {
  final AnalyticsReport report;
  final List<JobTypeAnalytics> jobTypeAnalytics;
  final PerformanceMetrics? performanceMetrics;

  const AnalyticsReportResponse({
    required this.report,
    required this.jobTypeAnalytics,
    this.performanceMetrics,
  });

  factory AnalyticsReportResponse.fromJson(Map<String, dynamic> json) {
    return AnalyticsReportResponse(
      report: AnalyticsReport(
        reportId: json['report']['reportId'] as String,
        reportType: ReportType.values.firstWhere(
          (e) => e.toString().split('.').last == json['report']['reportType'],
        ),
        successRateStats: SuccessRateStatistics(
          totalJobs: json['report']['successRateStats']['totalJobs'] as int,
          successJobs: json['report']['successRateStats']['successJobs'] as int,
          failedJobs: json['report']['successRateStats']['failedJobs'] as int,
          cancelledJobs:
              json['report']['successRateStats']['cancelledJobs'] as int,
          avgExecutionTimeMs: (json['report']['successRateStats']
              ['avgExecutionTimeMs'] as num)
            .toDouble(),
          maxExecutionTimeMs: json['report']['successRateStats']
              ['maxExecutionTimeMs'] as int,
          minExecutionTimeMs: json['report']['successRateStats']
              ['minExecutionTimeMs'] as int,
          period: DateRange(
            startDate: DateTime.parse(
                json['report']['period']['startDate'] as String),
            endDate:
                DateTime.parse(json['report']['period']['endDate'] as String),
          ),
        ),
        generatedAt:
            DateTime.parse(json['report']['generatedAt'] as String),
        period: DateRange(
          startDate:
              DateTime.parse(json['report']['period']['startDate'] as String),
          endDate:
              DateTime.parse(json['report']['period']['endDate'] as String),
        ),
      ),
      jobTypeAnalytics: (json['jobTypeAnalytics'] as List?)
              ?.map((j) => JobTypeAnalytics(
                    jobType: AsyncJobType.values.firstWhere(
                      (e) => e.toString().split('.').last == j['jobType'],
                    ),
                    executionCount: j['executionCount'] as int,
                    successCount: j['successCount'] as int,
                    failureCount: j['failureCount'] as int,
                    avgExecutionTimeMs: (j['avgExecutionTimeMs'] as num)
                        .toDouble(),
                    successRate: (j['successRate'] as num).toDouble(),
                  ))
              .toList() ??
          [],
      performanceMetrics: json['performanceMetrics'] != null
          ? PerformanceMetrics(
              period: DateRange(
                startDate: DateTime.parse(
                    json['performanceMetrics']['period']['startDate']
                        as String),
                endDate: DateTime.parse(
                    json['performanceMetrics']['period']['endDate']
                        as String),
              ),
              cpuUsagePercent: (json['performanceMetrics']['cpuUsagePercent']
                      as num)
                  .toDouble(),
              memoryUsageMb: (json['performanceMetrics']['memoryUsageMb']
                      as num)
                  .toDouble(),
              diskUsageMb:
                  (json['performanceMetrics']['diskUsageMb'] as num)
                      .toDouble(),
              throughputJobsPerMinute: (json['performanceMetrics']
                      ['throughputJobsPerMinute'] as num)
                  .toDouble(),
              avgLatencyMs: (json['performanceMetrics']['avgLatencyMs']
                      as num)
                  .toDouble(),
              p95LatencyMs: (json['performanceMetrics']['p95LatencyMs']
                      as num)
                  .toDouble(),
              p99LatencyMs: (json['performanceMetrics']['p99LatencyMs']
                      as num)
                  .toDouble(),
              errorRate:
                  (json['performanceMetrics']['errorRate'] as num)
                      .toDouble(),
              timestamp: DateTime.parse(
                  json['performanceMetrics']['timestamp'] as String),
            )
          : null,
    );
  }
}

// ==================== 検索関連 ====================

/// 検索リクエスト
class SearchRequest {
  final String userId;
  final String queryText;
  final SearchFilter? filter;
  final SearchSort? sort;
  final int page;
  final int pageSize;

  const SearchRequest({
    required this.userId,
    required this.queryText,
    this.filter,
    this.sort,
    this.page = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'queryText': queryText,
        if (filter != null) 'filter': filter!.toJson(),
        if (sort != null) 'sort': sort!.toJson(),
        'page': page,
        'pageSize': pageSize,
      };
}

/// 検索レスポンス
class SearchResponse {
  final SearchResult result;
  final int totalPages;
  final int currentPage;

  const SearchResponse({
    required this.result,
    required this.totalPages,
    required this.currentPage,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      result: SearchResult(
        query: SearchQuery(
          queryId: json['result']['query']['queryId'] as String,
          text: json['result']['query']['text'] as String,
        ),
        results: (json['result']['results'] as List?)
                ?.map((r) =>
                    AsyncJob.fromJson(r as Map<String, dynamic>))
                .toList() ??
            [],
        totalMatches: json['result']['totalMatches'] as int,
        executionTimeMs: json['result']['executionTimeMs'] as int,
        executedAt:
            DateTime.parse(json['result']['executedAt'] as String),
      ),
      totalPages: json['totalPages'] as int,
      currentPage: json['currentPage'] as int,
    );
  }
}

// ==================== エクスポート関連 ====================

/// エクスポートリクエスト
class ExportRequest {
  final String userId;
  final List<String> jobIds;
  final ExportConfig config;

  const ExportRequest({
    required this.userId,
    required this.jobIds,
    required this.config,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'jobIds': jobIds,
        'config': config.toJson(),
      };
}

/// エクスポートレスポンス
class ExportResponse {
  final ExportResult export;
  final String? downloadUrl;

  const ExportResponse({
    required this.export,
    this.downloadUrl,
  });

  factory ExportResponse.fromJson(Map<String, dynamic> json) {
    return ExportResponse(
      export: ExportResult(
        exportId: json['export']['exportId'] as String,
        fileName: json['export']['fileName'] as String,
        fileSizeBytes: json['export']['fileSizeBytes'] as int,
        jobCount: json['export']['jobCount'] as int,
        status: ExportStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['export']['status'],
        ),
        completedAt: json['export']['completedAt'] != null
            ? DateTime.parse(json['export']['completedAt'] as String)
            : null,
      ),
      downloadUrl: json['downloadUrl'] as String?,
    );
  }
}

// ==================== エラーハンドリング ====================

/// API エラーレスポンス
class ApiErrorResponse {
  final int statusCode;
  final String message;
  final String? errorCode;
  final Map<String, dynamic>? details;

  const ApiErrorResponse({
    required this.statusCode,
    required this.message,
    this.errorCode,
    this.details,
  });

  factory ApiErrorResponse.fromJson(
    int statusCode,
    Map<String, dynamic> json,
  ) {
    return ApiErrorResponse(
      statusCode: statusCode,
      message: json['message'] as String? ?? 'Unknown error',
      errorCode: json['errorCode'] as String?,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() => 'ApiError($statusCode): $message';
}

// ==================== ページング ====================

/// ページング情報
class PaginationInfo {
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginationInfo({
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    final pageNumber = json['pageNumber'] as int;
    final pageSize = json['pageSize'] as int;
    final totalCount = json['totalCount'] as int;
    final totalPages = (totalCount + pageSize - 1) ~/ pageSize;

    return PaginationInfo(
      pageNumber: pageNumber,
      pageSize: pageSize,
      totalCount: totalCount,
      totalPages: totalPages,
      hasNextPage: pageNumber < totalPages,
      hasPreviousPage: pageNumber > 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'totalCount': totalCount,
        'totalPages': totalPages,
        'hasNextPage': hasNextPage,
        'hasPreviousPage': hasPreviousPage,
      };
}
