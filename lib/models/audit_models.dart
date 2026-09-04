/// Phase 48: Audit & Compliance System 監査・コンプライアンスシステム
///
/// 監査ログ、イベントトレーサビリティ、コンプライアンス管理、規制対応

/// 監査イベントタイプ
enum AuditEventType {
  create('create'),
  read('read'),
  update('update'),
  delete('delete'),
  execute('execute'),
  export('export'),
  login('login'),
  logout('logout'),
  permissionChange('permission_change');

  final String value;
  const AuditEventType(this.value);
}

/// 監査重要度レベル
enum AuditSeverity {
  info(1),
  warning(2),
  error(3),
  critical(4);

  final int value;
  const AuditSeverity(this.value);
}

/// 監査ステータス
enum AuditStatus {
  success('success'),
  failure('failure'),
  partial('partial');

  final String value;
  const AuditStatus(this.value);
}

/// リソースタイプ
enum ResourceType {
  job('job'),
  feedback('feedback'),
  notification('notification'),
  metric('metric'),
  user('user'),
  config('config'),
  report('report'),
  other('other');

  final String value;
  const ResourceType(this.value);
}

/// 監査イベント
class AuditEvent {
  final String eventId;
  final String userId;
  final ResourceType resourceType;
  final String resourceId;
  final AuditEventType action;
  final AuditSeverity severity;
  final AuditStatus status;
  final DateTime timestamp;
  final Map<String, dynamic>? details;
  final String? ipAddress;
  final String? userAgent;
  final String? errorMessage;

  AuditEvent({
    required this.eventId,
    required this.userId,
    required this.resourceType,
    required this.resourceId,
    required this.action,
    required this.severity,
    required this.status,
    required this.timestamp,
    this.details,
    this.ipAddress,
    this.userAgent,
    this.errorMessage,
  });

  /// イベントが成功したか
  bool get isSuccessful => status == AuditStatus.success;

  /// イベントが失敗したか
  bool get isFailed => status == AuditStatus.failure;

  /// イベントが重大か
  bool get isCritical => severity == AuditSeverity.critical;

  /// イベントの年齢
  Duration get age => DateTime.now().difference(timestamp);
}

/// 監査ログ
class AuditLog {
  final String logId;
  final List<AuditEvent> events;
  final DateTime createdAt;
  final DateTime? closedAt;
  final Map<String, dynamic>? metadata;

  AuditLog({
    required this.logId,
    required this.events,
    required this.createdAt,
    this.closedAt,
    this.metadata,
  });

  /// イベント数
  int get eventCount => events.length;

  /// 失敗数
  int get failureCount => events.where((e) => e.isFailed).length;

  /// 重大イベント数
  int get criticalCount => events.where((e) => e.isCritical).length;

  /// 成功率
  double get successRate {
    if (events.isEmpty) return 0.0;
    final successCount = events.where((e) => e.isSuccessful).length;
    return successCount / events.length;
  }
}

/// コンプライアンスポリシー
class CompliancePolicy {
  final String policyId;
  final String name;
  final String description;
  final List<String> rules;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  CompliancePolicy({
    required this.policyId,
    required this.name,
    required this.description,
    required this.rules,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  /// ポリシーが有効か
  bool get isEnabled => isActive;

  /// ルール数
  int get ruleCount => rules.length;
}

/// コンプライアンス違反
class ComplianceViolation {
  final String violationId;
  final String policyId;
  final AuditSeverity severity;
  final String description;
  final DateTime detectedAt;
  final String? resolution;
  final DateTime? resolvedAt;
  final List<String>? affectedEvents;

  ComplianceViolation({
    required this.violationId,
    required this.policyId,
    required this.severity,
    required this.description,
    required this.detectedAt,
    this.resolution,
    this.resolvedAt,
    this.affectedEvents,
  });

  /// 違反が解決されたか
  bool get isResolved => resolvedAt != null;

  /// 違反が重大か
  bool get isCritical => severity == AuditSeverity.critical;

  /// 解決までの時間
  Duration? get resolutionTime {
    if (resolvedAt == null) return null;
    return resolvedAt!.difference(detectedAt);
  }
}

/// コンプライアンス統計
class ComplianceStats {
  final String statsId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalPolicies;
  final int activePolicies;
  final int totalViolations;
  final int criticalViolations;
  final int resolvedViolations;
  final Map<AuditSeverity, int> violationsBySeverity;
  final double complianceScore; // 0.0-1.0

  ComplianceStats({
    required this.statsId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalPolicies,
    required this.activePolicies,
    required this.totalViolations,
    required this.criticalViolations,
    required this.resolvedViolations,
    required this.violationsBySeverity,
    required this.complianceScore,
  });

  /// 違反解決率
  double get resolutionRate {
    if (totalViolations == 0) return 1.0;
    return resolvedViolations / totalViolations;
  }

  /// コンプライアンスレベル
  String get complianceLevel {
    if (complianceScore >= 0.9) return 'Excellent';
    if (complianceScore >= 0.7) return 'Good';
    if (complianceScore >= 0.5) return 'Fair';
    return 'Poor';
  }
}

/// コンプライアンスレポート
class ComplianceReport {
  final String reportId;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<CompliancePolicy> policies;
  final List<ComplianceViolation> violations;
  final ComplianceStats stats;
  final List<String>? recommendations;
  final Map<String, dynamic>? insights;

  ComplianceReport({
    required this.reportId,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.policies,
    required this.violations,
    required this.stats,
    this.recommendations,
    this.insights,
  });

  /// 未解決違反数
  int get unresolvedViolations => violations.where((v) => !v.isResolved).length;

  /// Markdown形式でレポート生成
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Compliance Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('**Period**: ${periodStart.toIso8601String()} to ${periodEnd.toIso8601String()}');
    buffer.writeln('');

    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Compliance Score: ${(stats.complianceScore * 100).toStringAsFixed(1)}% (${stats.complianceLevel})');
    buffer.writeln('- Total Policies: ${stats.totalPolicies}');
    buffer.writeln('- Active Policies: ${stats.activePolicies}');
    buffer.writeln('- Total Violations: ${stats.totalViolations}');
    buffer.writeln('- Critical Violations: ${stats.criticalViolations}');
    buffer.writeln('- Resolved Violations: ${stats.resolvedViolations}');
    buffer.writeln('- Resolution Rate: ${(stats.resolutionRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('');

    if (violations.isNotEmpty) {
      buffer.writeln('## Active Violations');
      buffer.writeln('');
      for (final violation in violations.where((v) => !v.isResolved).take(10)) {
        buffer.writeln('- **${violation.description}** (${violation.severity.name})');
        buffer.writeln('  - Detected: ${violation.detectedAt.toIso8601String()}');
        if (violation.resolution != null) {
          buffer.writeln('  - Resolution: ${violation.resolution}');
        }
      }
      buffer.writeln('');
    }

    if (recommendations != null && recommendations!.isNotEmpty) {
      buffer.writeln('## Recommendations');
      buffer.writeln('');
      for (final rec in recommendations!.take(5)) {
        buffer.writeln('- $rec');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}

/// 監査追跡
class AuditTrail {
  final String trailId;
  final String userId;
  final List<AuditEvent> events;
  final DateTime startTime;
  final DateTime endTime;
  final String? summary;

  AuditTrail({
    required this.trailId,
    required this.userId,
    required this.events,
    required this.startTime,
    required this.endTime,
    this.summary,
  });

  /// イベント数
  int get eventCount => events.length;

  /// アクション別集計
  Map<AuditEventType, int> get actionCounts {
    final counts = <AuditEventType, int>{};
    for (final event in events) {
      counts[event.action] = (counts[event.action] ?? 0) + 1;
    }
    return counts;
  }

  /// リソースタイプ別集計
  Map<ResourceType, int> get resourceCounts {
    final counts = <ResourceType, int>{};
    for (final event in events) {
      counts[event.resourceType] = (counts[event.resourceType] ?? 0) + 1;
    }
    return counts;
  }
}
