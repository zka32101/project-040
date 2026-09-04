/// Phase 48: Audit & Compliance Service 監査・コンプライアンスサービス

import '../models/audit_models.dart';

/// 監査リポジトリ インターフェース
abstract class AuditRepository {
  Future<AuditEvent> addEvent(AuditEvent event);
  Future<AuditEvent?> getEvent(String eventId);
  Future<List<AuditEvent>> getEventsByUser(String userId);
  Future<List<AuditEvent>> getEventsByResource(ResourceType type, String resourceId);
  Future<List<AuditEvent>> getEventsByType(AuditEventType type);
  Future<List<AuditEvent>> getEventsBySeverity(AuditSeverity severity);
  Future<List<AuditEvent>> getEventsByDateRange(DateTime start, DateTime end);
  Future<AuditLog> createLog(String logId, List<AuditEvent> events);
  Future<AuditLog?> getLog(String logId);
  Future<List<AuditLog>> getAllLogs();
  Future<void> clearAll();
}

/// メモリ監査リポジトリ実装
class MemoryAuditRepository implements AuditRepository {
  final Map<String, AuditEvent> _events = {};
  final Map<String, AuditLog> _logs = {};

  @override
  Future<AuditEvent> addEvent(AuditEvent event) async {
    _events[event.eventId] = event;
    return event;
  }

  @override
  Future<AuditEvent?> getEvent(String eventId) async {
    return _events[eventId];
  }

  @override
  Future<List<AuditEvent>> getEventsByUser(String userId) async {
    return _events.values.where((e) => e.userId == userId).toList();
  }

  @override
  Future<List<AuditEvent>> getEventsByResource(ResourceType type, String resourceId) async {
    return _events.values.where((e) => e.resourceType == type && e.resourceId == resourceId).toList();
  }

  @override
  Future<List<AuditEvent>> getEventsByType(AuditEventType type) async {
    return _events.values.where((e) => e.action == type).toList();
  }

  @override
  Future<List<AuditEvent>> getEventsBySeverity(AuditSeverity severity) async {
    return _events.values.where((e) => e.severity == severity).toList();
  }

  @override
  Future<List<AuditEvent>> getEventsByDateRange(DateTime start, DateTime end) async {
    return _events.values.where((e) => e.timestamp.isAfter(start) && e.timestamp.isBefore(end)).toList();
  }

  @override
  Future<AuditLog> createLog(String logId, List<AuditEvent> events) async {
    final log = AuditLog(
      logId: logId,
      events: events,
      createdAt: DateTime.now(),
    );
    _logs[logId] = log;
    return log;
  }

  @override
  Future<AuditLog?> getLog(String logId) async {
    return _logs[logId];
  }

  @override
  Future<List<AuditLog>> getAllLogs() async {
    return _logs.values.toList();
  }

  @override
  Future<void> clearAll() async {
    _events.clear();
    _logs.clear();
  }
}

/// コンプライアンスエンジン インターフェース
abstract class ComplianceEngine {
  Future<CompliancePolicy> createPolicy(String policyId, String name, String description, List<String> rules);
  Future<ComplianceViolation> detectViolation(String violationId, String policyId, AuditEvent event);
  Future<List<ComplianceViolation>> checkEventCompliance(AuditEvent event, List<CompliancePolicy> policies);
  Future<ComplianceStats> calculateStats(List<CompliancePolicy> policies, List<ComplianceViolation> violations, DateTime start, DateTime end);
  Future<List<String>> generateRecommendations(List<ComplianceViolation> violations);
  Future<ComplianceReport> generateReport(String reportId, List<CompliancePolicy> policies, List<ComplianceViolation> violations, DateTime start, DateTime end);
}

/// メモリコンプライアンスエンジン実装
class MemoryComplianceEngine implements ComplianceEngine {
  final Map<String, CompliancePolicy> _policies = {};
  final Map<String, ComplianceViolation> _violations = {};

  @override
  Future<CompliancePolicy> createPolicy(String policyId, String name, String description, List<String> rules) async {
    final policy = CompliancePolicy(
      policyId: policyId,
      name: name,
      description: description,
      rules: rules,
      createdAt: DateTime.now(),
    );
    _policies[policyId] = policy;
    return policy;
  }

  @override
  Future<ComplianceViolation> detectViolation(String violationId, String policyId, AuditEvent event) async {
    final violation = ComplianceViolation(
      violationId: violationId,
      policyId: policyId,
      severity: event.severity,
      description: 'Compliance violation detected for event: ${event.eventId}',
      detectedAt: DateTime.now(),
      affectedEvents: [event.eventId],
    );
    _violations[violationId] = violation;
    return violation;
  }

  @override
  Future<List<ComplianceViolation>> checkEventCompliance(AuditEvent event, List<CompliancePolicy> policies) async {
    final violations = <ComplianceViolation>[];

    // 重大イベントを常に違反と見なす
    if (event.isCritical) {
      final violation = await detectViolation(
        'v_${event.eventId}',
        policies.isNotEmpty ? policies.first.policyId : 'default',
        event,
      );
      violations.add(violation);
    }

    // 失敗したイベントもチェック
    if (event.isFailed) {
      for (final policy in policies) {
        if (policy.isActive && policy.rules.contains('NO_FAILURES')) {
          final violation = await detectViolation(
            'v_fail_${event.eventId}',
            policy.policyId,
            event,
          );
          violations.add(violation);
        }
      }
    }

    return violations;
  }

  @override
  Future<ComplianceStats> calculateStats(List<CompliancePolicy> policies, List<ComplianceViolation> violations, DateTime start, DateTime end) async {
    final filteredViolations = violations.where((v) => v.detectedAt.isAfter(start) && v.detectedAt.isBefore(end)).toList();
    final severityCounts = <AuditSeverity, int>{};

    for (final violation in filteredViolations) {
      severityCounts[violation.severity] = (severityCounts[violation.severity] ?? 0) + 1;
    }

    final criticalCount = filteredViolations.where((v) => v.isCritical).length;
    final resolvedCount = filteredViolations.where((v) => v.isResolved).length;

    // コンプライアンススコア計算
    double complianceScore = 1.0;
    if (filteredViolations.isNotEmpty) {
      final unresolvedRate = (filteredViolations.length - resolvedCount) / filteredViolations.length;
      final criticalPenalty = (criticalCount / filteredViolations.length) * 0.5;
      complianceScore = (1.0 - unresolvedRate) - criticalPenalty;
      complianceScore = complianceScore.clamp(0.0, 1.0);
    }

    return ComplianceStats(
      statsId: 'stats_${DateTime.now().millisecondsSinceEpoch}',
      periodStart: start,
      periodEnd: end,
      totalPolicies: policies.length,
      activePolicies: policies.where((p) => p.isActive).length,
      totalViolations: filteredViolations.length,
      criticalViolations: criticalCount,
      resolvedViolations: resolvedCount,
      violationsBySeverity: severityCounts,
      complianceScore: complianceScore,
    );
  }

  @override
  Future<List<String>> generateRecommendations(List<ComplianceViolation> violations) async {
    final recommendations = <String>[];

    if (violations.isEmpty) {
      return recommendations;
    }

    final criticalCount = violations.where((v) => v.isCritical).length;
    final unresolvedCount = violations.where((v) => !v.isResolved).length;

    if (criticalCount > 0) {
      recommendations.add('Critical violations detected: Immediate action required');
      recommendations.add('Review and address critical compliance violations within 24 hours');
    }

    if (unresolvedCount > 0) {
      recommendations.add('${unresolvedCount} unresolved violations remain');
      recommendations.add('Establish resolution timeline for pending violations');
    }

    if (violations.where((v) => v.severity == AuditSeverity.error).length > 5) {
      recommendations.add('High number of error-level violations');
      recommendations.add('Implement additional monitoring and controls');
    }

    return recommendations;
  }

  Future<ComplianceReport> _performFullAnalysis(
    String reportId,
    List<CompliancePolicy> policies,
    List<ComplianceViolation> violations,
    DateTime start,
    DateTime end,
  ) async {
    final stats = await calculateStats(policies, violations, start, end);
    final recommendations = await generateRecommendations(violations);

    return ComplianceReport(
      reportId: reportId,
      generatedAt: DateTime.now(),
      periodStart: start,
      periodEnd: end,
      policies: policies,
      violations: violations,
      stats: stats,
      recommendations: recommendations,
    );
  }

  @override
  Future<ComplianceReport> generateReport(String reportId, List<CompliancePolicy> policies, List<ComplianceViolation> violations, DateTime start, DateTime end) async {
    return _performFullAnalysis(reportId, policies, violations, start, end);
  }
}

/// 監査マネージャー インターフェース
abstract class AuditManager {
  Future<AuditEvent> recordEvent(
    String eventId,
    String userId,
    ResourceType resourceType,
    String resourceId,
    AuditEventType action,
    AuditSeverity severity,
    AuditStatus status, {
    Map<String, dynamic>? details,
    String? ipAddress,
    String? userAgent,
  });
  Future<AuditLog> generateLog(String logId, DateTime start, DateTime end);
  Future<AuditTrail> generateTrail(String trailId, String userId, DateTime start, DateTime end);
  Future<ComplianceReport> generateComplianceReport(
    String reportId,
    DateTime start,
    DateTime end,
  );
  Future<List<AuditEvent>> getEventsByDateRange(DateTime start, DateTime end);
}

/// メモリ監査マネージャー実装
class MemoryAuditManager implements AuditManager {
  final AuditRepository repository;
  final ComplianceEngine complianceEngine;
  final Map<String, CompliancePolicy> _policies = {};
  final Map<String, ComplianceViolation> _violations = {};

  MemoryAuditManager({
    required this.repository,
    required this.complianceEngine,
  });

  @override
  Future<AuditEvent> recordEvent(
    String eventId,
    String userId,
    ResourceType resourceType,
    String resourceId,
    AuditEventType action,
    AuditSeverity severity,
    AuditStatus status, {
    Map<String, dynamic>? details,
    String? ipAddress,
    String? userAgent,
  }) async {
    final event = AuditEvent(
      eventId: eventId,
      userId: userId,
      resourceType: resourceType,
      resourceId: resourceId,
      action: action,
      severity: severity,
      status: status,
      timestamp: DateTime.now(),
      details: details,
      ipAddress: ipAddress,
      userAgent: userAgent,
    );

    await repository.addEvent(event);

    // コンプライアンスチェック
    final violations = await complianceEngine.checkEventCompliance(event, _policies.values.toList());
    for (final violation in violations) {
      _violations[violation.violationId] = violation;
    }

    return event;
  }

  @override
  Future<AuditLog> generateLog(String logId, DateTime start, DateTime end) async {
    final events = await repository.getEventsByDateRange(start, end);
    return repository.createLog(logId, events);
  }

  @override
  Future<AuditTrail> generateTrail(String trailId, String userId, DateTime start, DateTime end) async {
    final userEvents = await repository.getEventsByUser(userId);
    final filteredEvents = userEvents
        .where((e) => e.timestamp.isAfter(start) && e.timestamp.isBefore(end))
        .toList();

    return AuditTrail(
      trailId: trailId,
      userId: userId,
      events: filteredEvents,
      startTime: start,
      endTime: end,
      summary: 'User activity trail for $userId from $start to $end',
    );
  }

  @override
  Future<ComplianceReport> generateComplianceReport(
    String reportId,
    DateTime start,
    DateTime end,
  ) async {
    return complianceEngine.generateReport(
      reportId,
      _policies.values.toList(),
      _violations.values.toList(),
      start,
      end,
    );
  }

  @override
  Future<List<AuditEvent>> getEventsByDateRange(DateTime start, DateTime end) async {
    return repository.getEventsByDateRange(start, end);
  }

  Future<CompliancePolicy> addPolicy(CompliancePolicy policy) async {
    _policies[policy.policyId] = policy;
    return policy;
  }
}

/// 監査ファサード
class AuditManagerFacade {
  late final AuditRepository repository;
  late final ComplianceEngine engine;
  late final MemoryAuditManager manager;

  AuditManagerFacade({
    AuditRepository? customRepository,
    ComplianceEngine? customEngine,
  }) {
    repository = customRepository ?? MemoryAuditRepository();
    engine = customEngine ?? MemoryComplianceEngine();
    manager = MemoryAuditManager(repository: repository, complianceEngine: engine);
  }

  Future<AuditEvent> recordEvent(
    String eventId,
    String userId,
    ResourceType resourceType,
    String resourceId,
    AuditEventType action,
    AuditSeverity severity,
    AuditStatus status, {
    Map<String, dynamic>? details,
    String? ipAddress,
    String? userAgent,
  }) async {
    return manager.recordEvent(
      eventId,
      userId,
      resourceType,
      resourceId,
      action,
      severity,
      status,
      details: details,
      ipAddress: ipAddress,
      userAgent: userAgent,
    );
  }

  Future<CompliancePolicy> createPolicy(
    String policyId,
    String name,
    String description,
    List<String> rules,
  ) async {
    final policy = await engine.createPolicy(policyId, name, description, rules);
    await manager.addPolicy(policy);
    return policy;
  }

  Future<AuditLog> generateLog(
    String logId,
    DateTime start,
    DateTime end,
  ) async {
    return manager.generateLog(logId, start, end);
  }

  Future<AuditTrail> generateTrail(
    String trailId,
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    return manager.generateTrail(trailId, userId, start, end);
  }

  Future<ComplianceReport> generateReport(
    String reportId,
    DateTime start,
    DateTime end,
  ) async {
    return manager.generateComplianceReport(reportId, start, end);
  }

  Future<List<AuditEvent>> getEventsByDateRange(DateTime start, DateTime end) async {
    return manager.getEventsByDateRange(start, end);
  }
}
