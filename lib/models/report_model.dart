import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_model.freezed.dart';
part 'report_model.g.dart';

/// レポート生成・エクスポートシステムのデータモデル

// ============================================================================
// 1. レポート定義・設定
// ============================================================================

/// レポートテンプレート
@freezed
class ReportTemplate with _$ReportTemplate {
  const factory ReportTemplate({
    required String id,
    required String name,
    required String description,
    required String category, // 'student', 'class', 'institution'
    required List<String> includedMetrics, // 含まれるメトリクス
    required String defaultFormat, // 'pdf', 'csv', 'excel', 'json'
    required Map<String, dynamic> templateConfig, // テンプレート設定
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCustom, // ユーザーカスタムテンプレート
  }) = _ReportTemplate;

  factory ReportTemplate.fromJson(Map<String, dynamic> json) =>
      _$ReportTemplateFromJson(json);
}

/// レポート設定（フィルタ・期間・フォーマット）
@freezed
class ReportConfig with _$ReportConfig {
  const factory ReportConfig({
    required String id,
    required String templateId,
    required String reportType, // 'student_progress', 'class_performance', 'cohort_analysis'
    required String format, // 'pdf', 'csv', 'excel', 'json'
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? filters, // フィルタ条件
    List<String>? includedFields, // 含めるフィールド
    bool? includeCharts, // グラフ含否
    bool? includeSummary, // 概要ページ含否
    String? timezone, // タイムゾーン
    DateTime? createdAt,
  }) = _ReportConfig;

  factory ReportConfig.fromJson(Map<String, dynamic> json) =>
      _$ReportConfigFromJson(json);
}

// ============================================================================
// 2. 生成されたレポート
// ============================================================================

/// 生成済みレポート
@freezed
class GeneratedReport with _$GeneratedReport {
  const factory GeneratedReport({
    required String id,
    required String templateId,
    required String reportType,
    required String title,
    required String description,
    required String format,
    required DateTime generatedAt,
    required DateTime startDate,
    required DateTime endDate,
    required String contentUrl, // レポート保存先 URL
    required double fileSizeBytes,
    required String generatedBy, // ユーザーID
    int? pageCount,
    int? recordCount, // レコード数
    String? status, // 'pending', 'generating', 'ready', 'error'
    String? errorMessage,
    DateTime? expiresAt, // 有効期限
    int? downloadCount,
    DateTime? lastDownloadedAt,
  }) = _GeneratedReport;

  factory GeneratedReport.fromJson(Map<String, dynamic> json) =>
      _$GeneratedReportFromJson(json);
}

/// レポート配信設定（スケジュール）
@freezed
class ReportDeliverySchedule with _$ReportDeliverySchedule {
  const factory ReportDeliverySchedule({
    required String id,
    required String templateId,
    required String deliveryType, // 'email', 'download', 'dashboard'
    required String frequency, // 'daily', 'weekly', 'monthly'
    required String dayOfWeek, // 'monday', 'tuesday'... (weeklyの場合)
    required int dayOfMonth, // 月の日（monthlyの場合）
    required String time, // '09:00' 形式
    required List<String> recipientEmails,
    required String timezone,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? nextDeliveryAt,
    int? totalDeliveries,
  }) = _ReportDeliverySchedule;

  factory ReportDeliverySchedule.fromJson(Map<String, dynamic> json) =>
      _$ReportDeliveryScheduleFromJson(json);
}

// ============================================================================
// 3. エクスポート機能
// ============================================================================

/// エクスポート設定
@freezed
class ExportConfig with _$ExportConfig {
  const factory ExportConfig({
    required String id,
    required String dataType, // 'student_data', 'answers', 'analytics', 'progress'
    required String format, // 'csv', 'excel', 'json', 'xml'
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? filters,
    List<String>? includedFields,
    bool? includePersonalInfo, // 個人情報を含める
    bool? maskPersonalData, // 個人情報をマスク
    String? encryptionType, // 'none', 'aes256', 'pgp'
    DateTime? createdAt,
  }) = _ExportConfig;

  factory ExportConfig.fromJson(Map<String, dynamic> json) =>
      _$ExportConfigFromJson(json);
}

/// エクスポート結果
@freezed
class ExportResult with _$ExportResult {
  const factory ExportResult({
    required String id,
    required String exportType,
    required String format,
    required String downloadUrl,
    required int recordCount,
    required double fileSizeBytes,
    required DateTime createdAt,
    required String status, // 'pending', 'processing', 'ready', 'error'
    String? errorMessage,
    DateTime? expiresAt,
    int? downloadCount,
    bool? isEncrypted,
    String? encryptionKey, // クライアント側でのみ表示
  }) = _ExportResult;

  factory ExportResult.fromJson(Map<String, dynamic> json) =>
      _$ExportResultFromJson(json);
}

// ============================================================================
// 4. 教師・管理者向けダッシュボード
// ============================================================================

/// クラス管理ビュー
@freezed
class ClassManagementView with _$ClassManagementView {
  const factory ClassManagementView({
    required String classId,
    required String className,
    required int totalStudents,
    required int activeStudents,
    required double averageScore,
    required Map<String, int> scoreDistribution, // スコア範囲の学生数
    required List<String> topPerformers, // 成績上位学生 ID
    required List<String> needsSupport, // 支援が必要な学生 ID
    required Map<String, double> categoryAverages, // カテゴリ別平均
    required DateTime lastUpdatedAt,
  }) = _ClassManagementView;

  factory ClassManagementView.fromJson(Map<String, dynamic> json) =>
      _$ClassManagementViewFromJson(json);
}

/// 学生パフォーマンス分析（教師用）
@freezed
class StudentPerformanceAnalysis with _$StudentPerformanceAnalysis {
  const factory StudentPerformanceAnalysis({
    required String studentId,
    required String studentName,
    required double currentScore,
    required double previousScore,
    required double scoreChange, // スコア変化量
    required String trend, // 'improving', 'declining', 'stable'
    required int questionsAttempted,
    required int correctAnswers,
    required double accuracy,
    required Map<String, double> categoryScores,
    required List<String> weakCategories,
    required List<String> strongCategories,
    required DateTime lastActivityAt,
    required String engagementLevel, // 'high', 'medium', 'low'
    required List<String> recommendedActions,
  }) = _StudentPerformanceAnalysis;

  factory StudentPerformanceAnalysis.fromJson(Map<String, dynamic> json) =>
      _$StudentPerformanceAnalysisFromJson(json);
}

/// 掲示板（クラス内コミュニケーション）
@freezed
class Announcement with _$Announcement {
  const factory Announcement({
    required String id,
    required String classId,
    required String creatorId,
    required String title,
    required String content,
    required DateTime createdAt,
    DateTime? updatedAt,
    required String priority, // 'low', 'normal', 'high'
    required List<String> targetStudentIds, // 空=全員
    DateTime? expiresAt,
    int? viewCount,
  }) = _Announcement;

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);
}

/// 課題・アサインメント
@freezed
class Assignment with _$Assignment {
  const factory Assignment({
    required String id,
    required String classId,
    required String creatorId,
    required String title,
    required String description,
    required DateTime dueDate,
    required List<String> assignedStudentIds,
    required String category, // 'practice', 'test', 'project'
    required int estimatedMinutes,
    DateTime? createdAt,
    Map<String, dynamic>? rubric, // 評価基準
    List<String>? resourceUrls,
    bool? allowLateSubmission,
    int? lateSubmissionPenaltyPercent,
  }) = _Assignment;

  factory Assignment.fromJson(Map<String, dynamic> json) =>
      _$AssignmentFromJson(json);
}

/// 採点・フィードバック
@freezed
class GradingFeedback with _$GradingFeedback {
  const factory GradingFeedback({
    required String id,
    required String assignmentId,
    required String studentId,
    required double score,
    required String scoreOutOf, // 例: "10"
    required String feedbackText,
    required DateTime submittedAt,
    required DateTime gradedAt,
    required String gradedBy, // 教師 ID
    List<String>? attachmentUrls, // フィードバック添付資料
    bool? isPublished,
    DateTime? publishedAt,
  }) = _GradingFeedback;

  factory GradingFeedback.fromJson(Map<String, dynamic> json) =>
      _$GradingFeedbackFromJson(json);
}

// ============================================================================
// 5. 統計分析・予測
// ============================================================================

/// コホート分析（学年別、入学日別の比較）
@freezed
class CohortAnalysis with _$CohortAnalysis {
  const factory CohortAnalysis({
    required String id,
    required String cohortName,
    required String cohortType, // 'enrollment_date', 'grade', 'program'
    required int totalStudents,
    required double averageScore,
    required double medianScore,
    required double stdDeviation,
    required Map<String, int> scoreDistribution,
    required Map<String, double> categoryAverages,
    required double completionRate,
    required double passRate,
    required DateTime generatedAt,
    required int percentileRank, // 他のコホートに対する百分位数
  }) = _CohortAnalysis;

  factory CohortAnalysis.fromJson(Map<String, dynamic> json) =>
      _$CohortAnalysisFromJson(json);
}

/// 修了予定日・脱落リスク予測
@freezed
class CompletionPrediction with _$CompletionPrediction {
  const factory CompletionPrediction({
    required String studentId,
    required DateTime estimatedCompletionDate,
    required int estimatedDaysRemaining,
    required double completionLikelihood, // 0-100%
    required String riskLevel, // 'low', 'medium', 'high'
    required List<String> riskFactors,
    required List<String> positiveFactors,
    required String recommendedAction, // 取るべき行動
    required DateTime predictedAt,
  }) = _CompletionPrediction;

  factory CompletionPrediction.fromJson(Map<String, dynamic> json) =>
      _$CompletionPredictionFromJson(json);
}

/// ベンチマーク分析（機関内外の比較）
@freezed
class BenchmarkAnalysis with _$BenchmarkAnalysis {
  const factory BenchmarkAnalysis({
    required String id,
    required String institutionId,
    required double institutionAverage,
    required double nationalAverage,
    required double regionAverage,
    required double performanceDifference, // 機関 - 国家平均
    required String performanceRating, // 'below_average', 'average', 'above_average', 'exceptional'
    required Map<String, double> categoryComparison,
    required int percentilRank, // 他機関に対する百分位数
    required DateTime analyzeDate,
  }) = _BenchmarkAnalysis;

  factory BenchmarkAnalysis.fromJson(Map<String, dynamic> json) =>
      _$BenchmarkAnalysisFromJson(json);
}
