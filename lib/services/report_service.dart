import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../models/community_model.dart';
import 'package:intl/intl.dart';

/// レポート生成エンジン
/// 日次、週次、月次のレポート生成とスケジュール配信
class ReportService {
  final Map<String, GeneratedReport> _reportCache = {};
  final Map<String, ReportDeliverySchedule> _scheduleCache = {};

  /// レポートテンプレート集
  static const Map<String, ReportTemplate> predefinedTemplates = {
    'student_progress': ReportTemplate(
      id: 'tpl_student_progress',
      name: 'Student Progress Report',
      description: 'Individual student learning progress and achievement',
      category: 'student',
      includedMetrics: [
        'total_questions_attempted',
        'correct_answers',
        'accuracy_rate',
        'average_score',
        'category_breakdown',
        'trend_analysis',
        'time_spent'
      ],
      defaultFormat: 'pdf',
      templateConfig: {},
    ),
    'class_performance': ReportTemplate(
      id: 'tpl_class_performance',
      name: 'Class Performance Report',
      description: 'Overall class performance and student distribution',
      category: 'class',
      includedMetrics: [
        'class_average',
        'score_distribution',
        'top_performers',
        'needs_support',
        'category_averages',
        'attendance_rate'
      ],
      defaultFormat: 'pdf',
      templateConfig: {},
    ),
    'cohort_analysis': ReportTemplate(
      id: 'tpl_cohort_analysis',
      name: 'Cohort Analysis Report',
      description: 'Multi-cohort comparison and benchmark analysis',
      category: 'institution',
      includedMetrics: [
        'cohort_averages',
        'completion_rates',
        'pass_rates',
        'comparison_metrics',
        'trend_analysis',
        'benchmark_comparison'
      ],
      defaultFormat: 'excel',
      templateConfig: {},
    ),
  };

  /// レポート生成：テンプレートとフィルタに基づいてレポートを生成
  Future<GeneratedReport> generateReport({
    required String templateId,
    required ReportConfig config,
    required String title,
    required String generatedBy,
    required Map<String, dynamic> dataSource, // 学生データなど
  }) async {
    try {
      final reportId = _generateReportId(templateId);

      // 1. テンプレートを取得
      final template = _getTemplate(templateId);
      if (template == null) {
        throw Exception('Template not found: $templateId');
      }

      // 2. データをフィルタリング
      final filteredData = _applyFilters(
        data: dataSource,
        filters: config.filters ?? {},
        startDate: config.startDate,
        endDate: config.endDate,
      );

      // 3. レポート内容を生成
      final content = _generateReportContent(
        template: template,
        config: config,
        data: filteredData,
      );

      // 4. フォーマットに応じて出力
      final formattedContent = _formatReportContent(
        content: content,
        format: config.format,
        includeCharts: true,
        includeSummary: true,
      );

      // 5. レポートオブジェクトを作成
      final report = GeneratedReport(
        id: reportId,
        templateId: templateId,
        reportType: config.reportType,
        title: title,
        description: 'Report generated on ${_formatDateTime(DateTime.now())}',
        format: config.format,
        generatedAt: DateTime.now(),
        startDate: config.startDate,
        endDate: config.endDate,
        contentUrl: '/reports/$reportId/download', // 概念的な URL
        fileSizeBytes: formattedContent.length.toDouble(),
        generatedBy: generatedBy,
        pageCount: _estimatePageCount(formattedContent),
        recordCount: filteredData.length,
        status: 'ready',
      );

      // キャッシュに保存
      _reportCache[reportId] = report;
      return report;
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'ReportService.generateReport');
      rethrow;
    }
  }

  /// スケジュール配信設定
  Future<ReportDeliverySchedule> scheduleReportDelivery({
    required String templateId,
    required String deliveryType,
    required String frequency,
    required String time,
    required List<String> recipientEmails,
    String? dayOfWeek,
    int? dayOfMonth,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final scheduleId = _generateScheduleId(templateId);

      final schedule = ReportDeliverySchedule(
        id: scheduleId,
        templateId: templateId,
        deliveryType: deliveryType,
        frequency: frequency,
        dayOfWeek: dayOfWeek ?? 'monday',
        dayOfMonth: dayOfMonth ?? 1,
        time: time,
        recipientEmails: recipientEmails,
        timezone: 'UTC',
        isActive: true,
        startDate: startDate ?? DateTime.now(),
        endDate: endDate,
        createdAt: DateTime.now(),
        nextDeliveryAt: _calculateNextDeliveryTime(frequency, time),
        totalDeliveries: 0,
      );

      // キャッシュに保存
      _scheduleCache[scheduleId] = schedule;
      return schedule;
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'ReportService.schedule');
      rethrow;
    }
  }

  /// クラス管理ビューの生成
  Future<ClassManagementView> generateClassView({
    required String classId,
    required String className,
    required List<StudentPerformanceAnalysis> studentAnalyses,
  }) async {
    try {
      // 統計計算
      final totalStudents = studentAnalyses.length;
      final activeStudents = studentAnalyses
          .where((s) => DateTime.now().difference(s.lastActivityAt).inDays < 7)
          .length;

      final averageScore = totalStudents == 0
          ? 0
          : studentAnalyses
                  .map((s) => s.currentScore)
                  .reduce((a, b) => a + b) /
              totalStudents;

      final topPerformers = studentAnalyses
          .sorted((a, b) => b.currentScore.compareTo(a.currentScore))
          .take(5)
          .map((s) => s.studentId)
          .toList();

      final needsSupport = studentAnalyses
          .where((s) => s.currentScore < 50)
          .map((s) => s.studentId)
          .toList();

      // カテゴリ別平均を計算
      final categoryAverages = <String, double>{};
      // 実装では実際のカテゴリデータから計算

      return ClassManagementView(
        classId: classId,
        className: className,
        totalStudents: totalStudents,
        activeStudents: activeStudents,
        averageScore: averageScore,
        scoreDistribution: _buildScoreDistribution(studentAnalyses),
        topPerformers: topPerformers,
        needsSupport: needsSupport,
        categoryAverages: categoryAverages,
        lastUpdatedAt: DateTime.now(),
      );
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'ReportService.classView');
      rethrow;
    }
  }

  /// テンプレートを取得
  ReportTemplate? _getTemplate(String templateId) {
    return predefinedTemplates[templateId];
  }

  /// データにフィルタを適用
  List<Map<String, dynamic>> _applyFilters({
    required Map<String, dynamic> data,
    required Map<String, dynamic> filters,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // 概念的実装：実際にはデータベースクエリで効率化
    return [];
  }

  /// レポート内容を生成
  String _generateReportContent({
    required ReportTemplate template,
    required ReportConfig config,
    required List<Map<String, dynamic>> data,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Report: ${config.reportType}');
    buffer.writeln('Period: ${_formatDateTime(config.startDate)} - ${_formatDateTime(config.endDate)}');
    buffer.writeln('Records: ${data.length}');
    return buffer.toString();
  }

  /// レポートをフォーマット
  String _formatReportContent({
    required String content,
    required String format,
    required bool includeCharts,
    required bool includeSummary,
  }) {
    switch (format) {
      case 'pdf':
        return '<pdf>$content</pdf>';
      case 'csv':
        return _formatAsCSV(content);
      case 'excel':
        return '<excel>$content</excel>';
      case 'json':
        return '{"report": "$content"}';
      default:
        return content;
    }
  }

  /// CSV フォーマット
  String _formatAsCSV(String content) {
    return 'data,value\n$content';
  }

  /// ページ数を推定
  int _estimatePageCount(String content) {
    return ((content.length / 2000) + 1).toInt();
  }

  /// スコア分布を構築
  Map<String, int> _buildScoreDistribution(
    List<StudentPerformanceAnalysis> analyses,
  ) {
    return {
      '90-100': analyses.where((a) => a.currentScore >= 90).length,
      '80-89': analyses.where((a) => a.currentScore >= 80 && a.currentScore < 90).length,
      '70-79': analyses.where((a) => a.currentScore >= 70 && a.currentScore < 80).length,
      '60-69': analyses.where((a) => a.currentScore >= 60 && a.currentScore < 70).length,
      '0-59': analyses.where((a) => a.currentScore < 60).length,
    };
  }

  /// 次の配信時刻を計算
  DateTime _calculateNextDeliveryTime(String frequency, String time) {
    final now = DateTime.now();
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    DateTime nextTime;

    if (frequency == 'daily') {
      nextTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (nextTime.isBefore(now)) {
        nextTime = nextTime.add(const Duration(days: 1));
      }
    } else if (frequency == 'weekly') {
      nextTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (nextTime.isBefore(now)) {
        nextTime = nextTime.add(const Duration(days: 1));
      }
    } else {
      // monthly
      nextTime = DateTime(now.year, now.month + 1, 1, hour, minute);
    }

    return nextTime;
  }

  /// ID を生成
  String _generateReportId(String templateId) {
    return 'report_${templateId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// スケジュール ID を生成
  String _generateScheduleId(String templateId) {
    return 'schedule_${templateId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// DateTime をフォーマット
  String _formatDateTime(DateTime dt) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }

  /// キャッシュをクリア
  void clearCache(String reportId) {
    _reportCache.remove(reportId);
  }

  /// すべてのキャッシュをクリア
  void clearAllCache() {
    _reportCache.clear();
    _scheduleCache.clear();
  }
}

/// 拡張メソッド: sorted
extension StudentAnalysisList on List<StudentPerformanceAnalysis> {
  List<StudentPerformanceAnalysis> sorted(
    int Function(StudentPerformanceAnalysis, StudentPerformanceAnalysis) compare,
  ) {
    final copy = [...this];
    copy.sort(compare);
    return copy;
  }
}
