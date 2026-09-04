/// Phase 44: Error Tracking & Reporting エラートラッキングサービス実装
///
/// エラー記録、クラスタリング、アラート、分析

import 'package:project_040/models/error_tracking_models.dart';

/// エラートラッキングリポジトリインターフェース
abstract class ErrorTrackingRepository {
  /// エラーイベントを保存
  Future<void> saveErrorEvent(ErrorEvent event);

  /// エラーイベントを取得
  Future<ErrorEvent?> getErrorEvent(String errorId);

  /// すべてのエラーイベントを取得
  Future<List<ErrorEvent>> getAllErrorEvents();

  /// エラーレポートを保存
  Future<void> saveErrorReport(ErrorReport report);

  /// エラーレポートを取得
  Future<ErrorReport?> getErrorReport(String reportId);

  /// 未解決のレポートを取得
  Future<List<ErrorReport>> getUnresolvedReports();

  /// エラークラスタを保存
  Future<void> saveErrorCluster(ErrorCluster cluster);

  /// エラークラスタを取得
  Future<ErrorCluster?> getErrorCluster(String clusterId);

  /// すべてのクラスタを取得
  Future<List<ErrorCluster>> getAllClusters();

  /// アラートを保存
  Future<void> saveAlert(ErrorAlert alert);

  /// アクティブなアラートを取得
  Future<List<ErrorAlert>> getActiveAlerts();

  /// メトリクスを保存
  Future<void> saveMetrics(ErrorMetrics metrics);

  /// 最新のメトリクスを取得
  Future<ErrorMetrics?> getLatestMetrics();
}

/// メモリ実装のエラートラッキングリポジトリ
class MemoryErrorTrackingRepository implements ErrorTrackingRepository {
  final Map<String, ErrorEvent> _errorEvents = {};
  final Map<String, ErrorReport> _errorReports = {};
  final Map<String, ErrorCluster> _errorClusters = {};
  final Map<String, ErrorAlert> _alerts = {};
  final Map<String, ErrorMetrics> _metrics = {};

  @override
  Future<void> saveErrorEvent(ErrorEvent event) async {
    _errorEvents[event.errorId] = event;
  }

  @override
  Future<ErrorEvent?> getErrorEvent(String errorId) async =>
      _errorEvents[errorId];

  @override
  Future<List<ErrorEvent>> getAllErrorEvents() async =>
      _errorEvents.values.toList();

  @override
  Future<void> saveErrorReport(ErrorReport report) async {
    _errorReports[report.reportId] = report;
  }

  @override
  Future<ErrorReport?> getErrorReport(String reportId) async =>
      _errorReports[reportId];

  @override
  Future<List<ErrorReport>> getUnresolvedReports() async =>
      _errorReports.values
          .where((r) => !r.isResolved)
          .toList();

  @override
  Future<void> saveErrorCluster(ErrorCluster cluster) async {
    _errorClusters[cluster.clusterId] = cluster;
  }

  @override
  Future<ErrorCluster?> getErrorCluster(String clusterId) async =>
      _errorClusters[clusterId];

  @override
  Future<List<ErrorCluster>> getAllClusters() async =>
      _errorClusters.values.toList();

  @override
  Future<void> saveAlert(ErrorAlert alert) async {
    _alerts[alert.alertId] = alert;
  }

  @override
  Future<List<ErrorAlert>> getActiveAlerts() async =>
      _alerts.values.where((a) => a.isActive && !a.isAcknowledged).toList();

  @override
  Future<void> saveMetrics(ErrorMetrics metrics) async {
    _metrics[metrics.metricsId] = metrics;
  }

  @override
  Future<ErrorMetrics?> getLatestMetrics() async {
    if (_metrics.isEmpty) return null;
    return _metrics.values.reduce((a, b) =>
        a.measuredAt.isAfter(b.measuredAt) ? a : b);
  }
}

/// エラー分析エンジンインターフェース
abstract class ErrorAnalysisEngine {
  /// エラーをクラスタリング
  Future<ErrorCluster> clusterError(ErrorEvent event);

  /// エラークラスタを分析
  Future<ErrorAnalytics> analyzeErrors(List<ErrorEvent> events);

  /// エラーメトリクスを計算
  Future<ErrorMetrics> calculateMetrics(List<ErrorEvent> events);

  /// アラートをトリガー
  Future<void> checkAlerts(ErrorCluster cluster);

  /// レポートを生成
  Future<ErrorTrackingReport> generateReport();
}

/// メモリ実装のエラー分析エンジン
class MemoryErrorAnalysisEngine implements ErrorAnalysisEngine {
  final ErrorTrackingRepository _repository;

  MemoryErrorAnalysisEngine(this._repository);

  @override
  Future<ErrorCluster> clusterError(ErrorEvent event) async {
    final clusterId = 'cluster:${event.type.value}:${DateTime.now().millisecondsSinceEpoch}';
    final fingerprint = _generateFingerprint(event);

    return ErrorCluster(
      clusterId: clusterId,
      fingerprint: fingerprint,
      events: [event],
      type: event.type,
      level: event.level,
      commonMessage: event.message,
      totalCount: 1,
      firstOccurrence: event.occurredAt,
      lastOccurrence: event.occurredAt,
    );
  }

  @override
  Future<ErrorAnalytics> analyzeErrors(List<ErrorEvent> events) async {
    final clusters = <String, ErrorCluster>{};

    for (final event in events) {
      final cluster = await clusterError(event);
      clusters[cluster.clusterId] = cluster;
    }

    final errorTypeDistribution = <ErrorType, int>{};
    final errorLevelDistribution = <ErrorLevel, int>{};

    for (final event in events) {
      errorTypeDistribution[event.type] =
          (errorTypeDistribution[event.type] ?? 0) + 1;
      errorLevelDistribution[event.level] =
          (errorLevelDistribution[event.level] ?? 0) + 1;
    }

    final metrics = await calculateMetrics(events);
    final alerts = await _repository.getActiveAlerts();

    return ErrorAnalytics(
      analyticsId: 'analytics:${DateTime.now().millisecondsSinceEpoch}',
      topClusters: clusters.values.toList()..sort((a, b) => b.totalCount.compareTo(a.totalCount)),
      errorTypeDistribution: errorTypeDistribution,
      errorLevelDistribution: errorLevelDistribution,
      activeAlerts: alerts,
      metrics: metrics,
      analyzedAt: DateTime.now(),
    );
  }

  @override
  Future<ErrorMetrics> calculateMetrics(List<ErrorEvent> events) async {
    final totalErrors = events.length;
    final errorTypes = events.map((e) => e.type).toSet().length;
    final criticalErrors = events
        .where((e) => e.level == ErrorLevel.critical)
        .length;

    final unresolvedReports = await _repository.getUnresolvedReports();
    final unresolvedCount = unresolvedReports.length;

    final errorRate = totalErrors > 0 ? (criticalErrors / totalErrors) : 0.0;

    return ErrorMetrics(
      metricsId: 'metrics:${DateTime.now().millisecondsSinceEpoch}',
      totalErrors: totalErrors,
      errorTypeCounts: errorTypes,
      criticalErrors: criticalErrors,
      unresolvedErrors: unresolvedCount,
      errorRate: errorRate,
      measuredAt: DateTime.now(),
    );
  }

  @override
  Future<void> checkAlerts(ErrorCluster cluster) async {
    final alerts = await _repository.getActiveAlerts();
    for (final alert in alerts) {
      if (alert.errorClusterId == cluster.clusterId &&
          cluster.totalCount >= alert.threshold) {
        // Alert should be triggered
      }
    }
  }

  @override
  Future<ErrorTrackingReport> generateReport() async {
    final events = await _repository.getAllErrorEvents();
    final analytics = await analyzeErrors(events);
    final unresolvedReports = await _repository.getUnresolvedReports();
    final alerts = await _repository.getActiveAlerts();

    final recommendations = _generateRecommendations(analytics);

    return ErrorTrackingReport(
      reportId: 'report:${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      analytics: analytics,
      unresolvedReports: unresolvedReports,
      pendingAlerts: alerts,
      recommendations: recommendations,
    );
  }

  String _generateFingerprint(ErrorEvent event) {
    final message = event.message;
    final type = event.type.value;
    return '$type:$message';
  }

  List<String> _generateRecommendations(ErrorAnalytics analytics) {
    final recommendations = <String>[];

    if (analytics.metrics.criticalErrors > 0) {
      recommendations.add('Critical errors detected - immediate action required');
    }

    if (analytics.metrics.isTrendingUp) {
      recommendations.add('Error rate is increasing - investigate root causes');
    }

    if (analytics.topClusters.isNotEmpty) {
      recommendations.add('Focus on top error cluster: ${analytics.topClusters.first.commonMessage}');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Error tracking is nominal');
    }

    return recommendations;
  }
}

/// エラートラッキングマネージャーインターフェース
abstract class ErrorTrackingManager {
  /// エラーを記録
  Future<void> recordError(ErrorEvent event);

  /// エラーレポートを作成
  Future<ErrorReport> createErrorReport(ErrorEvent event, ErrorPriority priority);

  /// レポートのステータスを更新
  Future<void> updateReportStatus(String reportId, ErrorStatus status);

  /// アラートを作成
  Future<void> createAlert(String clusterId, ErrorAlert alert);

  /// レポートを生成
  Future<ErrorTrackingReport> generateReport();

  /// メトリクスを取得
  Future<ErrorMetrics?> getMetrics();
}

/// メモリ実装のエラートラッキングマネージャー
class MemoryErrorTrackingManager implements ErrorTrackingManager {
  final ErrorTrackingRepository _repository;
  final ErrorAnalysisEngine _analysisEngine;

  MemoryErrorTrackingManager(this._repository, this._analysisEngine);

  @override
  Future<void> recordError(ErrorEvent event) async {
    await _repository.saveErrorEvent(event);
    final cluster = await _analysisEngine.clusterError(event);
    await _repository.saveErrorCluster(cluster);
    await _analysisEngine.checkAlerts(cluster);
  }

  @override
  Future<ErrorReport> createErrorReport(
    ErrorEvent event,
    ErrorPriority priority,
  ) async {
    final report = ErrorReport(
      reportId: 'report:${DateTime.now().millisecondsSinceEpoch}',
      errorEvent: event,
      priority: priority,
      createdAt: DateTime.now(),
    );

    await _repository.saveErrorReport(report);
    return report;
  }

  @override
  Future<void> updateReportStatus(String reportId, ErrorStatus status) async {
    final report = await _repository.getErrorReport(reportId);
    if (report != null) {
      final updatedReport = ErrorReport(
        reportId: report.reportId,
        errorEvent: report.errorEvent,
        status: status,
        priority: report.priority,
        assignedTo: report.assignedTo,
        resolutionNotes: report.resolutionNotes,
        createdAt: report.createdAt,
        resolvedAt: status == ErrorStatus.resolved ? DateTime.now() : null,
        tags: report.tags,
        additionalInfo: report.additionalInfo,
      );

      await _repository.saveErrorReport(updatedReport);
    }
  }

  @override
  Future<void> createAlert(String clusterId, ErrorAlert alert) async {
    await _repository.saveAlert(alert);
  }

  @override
  Future<ErrorTrackingReport> generateReport() async {
    return _analysisEngine.generateReport();
  }

  @override
  Future<ErrorMetrics?> getMetrics() async {
    return _repository.getLatestMetrics();
  }
}

/// エラートラッキングマネージャーファサード
class ErrorTrackingManagerFacade {
  late ErrorTrackingRepository _repository;
  late ErrorAnalysisEngine _analysisEngine;
  late ErrorTrackingManager _manager;

  ErrorTrackingManagerFacade({
    ErrorTrackingRepository? repository,
    ErrorAnalysisEngine? analysisEngine,
    ErrorTrackingManager? manager,
  }) {
    _repository = repository ?? MemoryErrorTrackingRepository();
    _analysisEngine = analysisEngine ?? MemoryErrorAnalysisEngine(_repository);
    _manager = manager ??
        MemoryErrorTrackingManager(_repository, _analysisEngine);
  }

  /// エラーを記録
  Future<void> recordError(ErrorEvent event) => _manager.recordError(event);

  /// エラーレポートを作成
  Future<ErrorReport> createErrorReport(
    ErrorEvent event,
    ErrorPriority priority,
  ) =>
      _manager.createErrorReport(event, priority);

  /// レポートのステータスを更新
  Future<void> updateReportStatus(String reportId, ErrorStatus status) =>
      _manager.updateReportStatus(reportId, status);

  /// アラートを作成
  Future<void> createAlert(String clusterId, ErrorAlert alert) =>
      _manager.createAlert(clusterId, alert);

  /// レポートを生成
  Future<ErrorTrackingReport> generateReport() => _manager.generateReport();

  /// メトリクスを取得
  Future<ErrorMetrics?> getMetrics() => _manager.getMetrics();

  /// エラーイベントを取得
  Future<ErrorEvent?> getErrorEvent(String errorId) =>
      _repository.getErrorEvent(errorId);

  /// すべてのエラーイベントを取得
  Future<List<ErrorEvent>> getAllErrorEvents() =>
      _repository.getAllErrorEvents();

  /// 未解決のレポートを取得
  Future<List<ErrorReport>> getUnresolvedReports() =>
      _repository.getUnresolvedReports();

  /// アクティブなアラートを取得
  Future<List<ErrorAlert>> getActiveAlerts() =>
      _repository.getActiveAlerts();

  /// クラスタを分析
  Future<ErrorAnalytics> analyzeErrors(List<ErrorEvent> events) =>
      _analysisEngine.analyzeErrors(events);
}
