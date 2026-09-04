/// Phase 44: Error Tracking & Reporting エラートラッキングモデル定義
///
/// エラー、スタックトレース、レポート、アラート

/// エラーレベル
enum ErrorLevel {
  debug('debug'),
  info('info'),
  warning('warning'),
  error('error'),
  critical('critical');

  final String value;
  const ErrorLevel(this.value);
}

/// エラータイプ
enum ErrorType {
  nullPointer('null_pointer'),
  typeError('type_error'),
  argumentError('argument_error'),
  stateError('state_error'),
  asyncError('async_error'),
  ioError('io_error'),
  networkError('network_error'),
  authenticationError('authentication_error'),
  validationError('validation_error'),
  customError('custom_error');

  final String value;
  const ErrorType(this.value);
}

/// エラーステータス
enum ErrorStatus {
  new_('new'),
  acknowledged('acknowledged'),
  investigating('investigating'),
  resolved('resolved'),
  reopened('reopened'),
  ignored('ignored');

  final String value;
  const ErrorStatus(this.value);
}

/// エラー優先度
enum ErrorPriority {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  final String value;
  const ErrorPriority(this.value);
}

/// スタックトレース情報
class StackTraceFrame {
  final String? fileName;
  final String? methodName;
  final int? lineNumber;
  final int? columnNumber;
  final bool isNative;
  final String rawFrame;

  StackTraceFrame({
    this.fileName,
    this.methodName,
    this.lineNumber,
    this.columnNumber,
    this.isNative = false,
    required this.rawFrame,
  });

  /// フレームの文字列表現
  String get displayString {
    if (fileName == null || methodName == null) {
      return rawFrame;
    }
    return '$fileName:$lineNumber in $methodName';
  }
}

/// エラーコンテキスト
class ErrorContext {
  final String? userId;
  final String? sessionId;
  final String? deviceId;
  final String? appVersion;
  final String? osVersion;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  ErrorContext({
    this.userId,
    this.sessionId,
    this.deviceId,
    this.appVersion,
    this.osVersion,
    this.metadata,
    required this.timestamp,
  });

  /// コンテキスト情報をマップに変換
  Map<String, dynamic> toMap() {
    return {
      if (userId != null) 'userId': userId,
      if (sessionId != null) 'sessionId': sessionId,
      if (deviceId != null) 'deviceId': deviceId,
      if (appVersion != null) 'appVersion': appVersion,
      if (osVersion != null) 'osVersion': osVersion,
      if (metadata != null) 'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// エラーイベント
class ErrorEvent {
  final String errorId;
  final String message;
  final ErrorType type;
  final ErrorLevel level;
  final String? stackTrace;
  final List<StackTraceFrame>? frames;
  final ErrorContext context;
  final DateTime occurredAt;
  final int occurrenceCount;
  final DateTime? lastOccurredAt;

  ErrorEvent({
    required this.errorId,
    required this.message,
    required this.type,
    required this.level,
    this.stackTrace,
    this.frames,
    required this.context,
    required this.occurredAt,
    this.occurrenceCount = 1,
    this.lastOccurredAt,
  });

  /// エラーが繰り返しているか
  bool get isRecurring => occurrenceCount > 1;

  /// エラーの重大度スコア (0-100)
  int get severityScore {
    final levelScore = {
      ErrorLevel.debug: 10,
      ErrorLevel.info: 20,
      ErrorLevel.warning: 50,
      ErrorLevel.error: 75,
      ErrorLevel.critical: 100,
    };
    return levelScore[level] ?? 50;
  }
}

/// エラーレポート
class ErrorReport {
  final String reportId;
  final ErrorEvent errorEvent;
  final ErrorStatus status;
  final ErrorPriority priority;
  final String? assignedTo;
  final String? resolutionNotes;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final List<String>? tags;
  final Map<String, dynamic>? additionalInfo;

  ErrorReport({
    required this.reportId,
    required this.errorEvent,
    this.status = ErrorStatus.new_,
    required this.priority,
    this.assignedTo,
    this.resolutionNotes,
    required this.createdAt,
    this.resolvedAt,
    this.tags,
    this.additionalInfo,
  });

  /// レポートが解決済みか
  bool get isResolved => status == ErrorStatus.resolved;

  /// ペンディング状態か
  bool get isPending =>
      status == ErrorStatus.new_ || status == ErrorStatus.investigating;

  /// レポートの経過時間
  Duration get ageTime => DateTime.now().difference(createdAt);
}

/// エラークラスタ (複数の同一エラーをグループ化)
class ErrorCluster {
  final String clusterId;
  final String? fingerprint;
  final List<ErrorEvent> events;
  final ErrorType type;
  final ErrorLevel level;
  final String commonMessage;
  final int totalCount;
  final DateTime firstOccurrence;
  final DateTime lastOccurrence;
  final double? affectedUserCount;

  ErrorCluster({
    required this.clusterId,
    this.fingerprint,
    required this.events,
    required this.type,
    required this.level,
    required this.commonMessage,
    required this.totalCount,
    required this.firstOccurrence,
    required this.lastOccurrence,
    this.affectedUserCount,
  });

  /// クラスタの主要フレーム
  StackTraceFrame? get topFrame {
    for (final event in events) {
      if (event.frames != null && event.frames!.isNotEmpty) {
        return event.frames!.first;
      }
    }
    return null;
  }

  /// クラスタの頻度 (イベント/日)
  double get frequency {
    final days = lastOccurrence.difference(firstOccurrence).inDays + 1;
    return days > 0 ? totalCount / days : 0;
  }
}

/// エラーメトリクス
class ErrorMetrics {
  final String metricsId;
  final int totalErrors;
  final int errorTypeCounts;
  final int criticalErrors;
  final int unresolvedErrors;
  final double errorRate;
  final double? mtbf; // 平均故障間隔
  final double? mttr; // 平均修復時間
  final DateTime measuredAt;

  ErrorMetrics({
    required this.metricsId,
    required this.totalErrors,
    required this.errorTypeCounts,
    required this.criticalErrors,
    required this.unresolvedErrors,
    required this.errorRate,
    this.mtbf,
    this.mttr,
    required this.measuredAt,
  });

  /// システムヘルススコア (0-100)
  int get systemHealthScore {
    final score = 100 - (errorRate * 100).clamp(0.0, 100.0).toInt();
    return score;
  }

  /// エラートレンドが悪化しているか
  bool get isTrendingUp => errorRate > 0.05; // 5% 以上
}

/// エラーアラート
class ErrorAlert {
  final String alertId;
  final String errorClusterId;
  final String title;
  final String message;
  final ErrorLevel level;
  final bool isActive;
  final int threshold; // トリガーする発生回数
  final Duration timeWindow; // 時間ウィンドウ
  final DateTime createdAt;
  final DateTime? triggeredAt;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;

  ErrorAlert({
    required this.alertId,
    required this.errorClusterId,
    required this.title,
    required this.message,
    required this.level,
    this.isActive = true,
    required this.threshold,
    required this.timeWindow,
    required this.createdAt,
    this.triggeredAt,
    this.acknowledgedAt,
    this.acknowledgedBy,
  });

  /// アラートがトリガーされたか
  bool get isTriggered => triggeredAt != null;

  /// アラートを確認したか
  bool get isAcknowledged => acknowledgedAt != null;
}

/// エラーアナリティクス
class ErrorAnalytics {
  final String analyticsId;
  final List<ErrorCluster> topClusters;
  final Map<ErrorType, int> errorTypeDistribution;
  final Map<ErrorLevel, int> errorLevelDistribution;
  final List<ErrorAlert> activeAlerts;
  final ErrorMetrics metrics;
  final DateTime analyzedAt;

  ErrorAnalytics({
    required this.analyticsId,
    required this.topClusters,
    required this.errorTypeDistribution,
    required this.errorLevelDistribution,
    required this.activeAlerts,
    required this.metrics,
    required this.analyzedAt,
  });

  /// 最も一般的なエラータイプ
  ErrorType? get mostCommonErrorType {
    if (errorTypeDistribution.isEmpty) return null;
    return errorTypeDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 最も重大なエラーレベル
  ErrorLevel? get mostSevereLevel {
    if (errorLevelDistribution.isEmpty) return null;
    final levels = [
      ErrorLevel.critical,
      ErrorLevel.error,
      ErrorLevel.warning,
      ErrorLevel.info,
      ErrorLevel.debug
    ];
    for (final level in levels) {
      if (errorLevelDistribution.containsKey(level) &&
          errorLevelDistribution[level]! > 0) {
        return level;
      }
    }
    return null;
  }
}

/// エラーレポート (集計)
class ErrorTrackingReport {
  final String reportId;
  final DateTime generatedAt;
  final ErrorAnalytics analytics;
  final List<ErrorReport> unresolvedReports;
  final List<ErrorAlert> pendingAlerts;
  final String? summary;
  final List<String>? recommendations;

  ErrorTrackingReport({
    required this.reportId,
    required this.generatedAt,
    required this.analytics,
    required this.unresolvedReports,
    required this.pendingAlerts,
    this.summary,
    this.recommendations,
  });

  /// Markdown 形式でレポートを生成
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Error Tracking Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');

    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Total Errors: ${analytics.metrics.totalErrors}');
    buffer.writeln('- Critical Errors: ${analytics.metrics.criticalErrors}');
    buffer.writeln('- Unresolved: ${analytics.metrics.unresolvedErrors}');
    buffer.writeln('- Error Rate: ${(analytics.metrics.errorRate * 100).toStringAsFixed(2)}%');
    buffer.writeln('- System Health: ${analytics.metrics.systemHealthScore}/100');
    buffer.writeln('');

    buffer.writeln('## Top Error Clusters');
    buffer.writeln('');
    for (final cluster in analytics.topClusters.take(5)) {
      buffer.writeln('- ${cluster.commonMessage} (${cluster.totalCount}x)');
    }
    buffer.writeln('');

    if (pendingAlerts.isNotEmpty) {
      buffer.writeln('## Active Alerts');
      buffer.writeln('');
      for (final alert in pendingAlerts) {
        buffer.writeln('- ${alert.title} (${alert.level.value})');
      }
      buffer.writeln('');
    }

    if (recommendations != null && recommendations!.isNotEmpty) {
      buffer.writeln('## Recommendations');
      buffer.writeln('');
      for (final rec in recommendations!) {
        buffer.writeln('- $rec');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}
