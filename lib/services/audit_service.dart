import '../models/audit_models.dart';

abstract class AuditRepository {
  Future<void> createAuditLog(AuditLog log);
  Future<AuditLog?> getAuditLog(String logId);
  Future<List<AuditLog>> getAllAuditLogs();
  Future<List<AuditLog>> getAuditLogsByUser(String userId);
  Future<List<AuditLog>> getAuditLogsByResource(String resourceId);
  Future<List<AuditLog>> getAuditLogsByDateRange(DateTime start, DateTime end);

  Future<void> createComplianceRule(ComplianceRule rule);
  Future<ComplianceRule?> getComplianceRule(String ruleId);
  Future<List<ComplianceRule>> getAllComplianceRules();
  Future<void> updateComplianceRule(ComplianceRule rule);
  Future<void> deleteComplianceRule(String ruleId);

  Future<void> createAuditTrail(AuditTrail trail);
  Future<AuditTrail?> getAuditTrail(String trailId);
  Future<List<AuditTrail>> getAuditTrailsByEntity(String entityId);

  Future<void> createDataClassificationPolicy(DataClassificationPolicy policy);
  Future<DataClassificationPolicy?> getDataClassificationPolicy(String policyId);
  Future<List<DataClassificationPolicy>> getAllPolicies();

  Future<void> createRetentionRule(RetentionRule rule);
  Future<RetentionRule?> getRetentionRule(String ruleId);
  Future<List<RetentionRule>> getAllRetentionRules();

  Future<void> saveComplianceCheck(ComplianceCheck check);
  Future<ComplianceCheck?> getComplianceCheck(String checkId);
  Future<List<ComplianceCheck>> getComplianceChecksByDateRange(DateTime start, DateTime end);

  Future<void> saveAuditReport(AuditReport report);
  Future<AuditReport?> getAuditReport(String reportId);
  Future<List<AuditReport>> getRecentAuditReports(int limit);

  Future<void> createUserAccessLog(UserAccessLog log);
  Future<List<UserAccessLog>> getUserAccessLogs(String userId);
  Future<List<UserAccessLog>> getAccessLogsByDateRange(DateTime start, DateTime end);

  Future<void> createChangeLog(ChangeLog log);
  Future<List<ChangeLog>> getChangeLogsByResource(String resourceId);
  Future<List<ChangeLog>> getChangeLogsByUser(String userId);

  Future<void> saveComplianceMetrics(ComplianceMetrics metrics);
  Future<ComplianceMetrics?> getComplianceMetrics(String metricsId);
  Future<List<ComplianceMetrics>> getRecentMetrics(int limit);

  Future<void> createAuditFilter(AuditFilter filter);
  Future<AuditFilter?> getAuditFilter(String filterId);
  Future<List<AuditFilter>> getAllFilters();
}

class MemoryAuditRepository implements AuditRepository {
  final Map<String, AuditLog> _auditLogs = {};
  final Map<String, ComplianceRule> _complianceRules = {};
  final Map<String, AuditTrail> _auditTrails = {};
  final Map<String, DataClassificationPolicy> _policies = {};
  final Map<String, RetentionRule> _retentionRules = {};
  final Map<String, ComplianceCheck> _complianceChecks = {};
  final Map<String, AuditReport> _auditReports = {};
  final List<UserAccessLog> _accessLogs = [];
  final List<ChangeLog> _changeLogs = [];
  final Map<String, ComplianceMetrics> _metrics = {};
  final Map<String, AuditFilter> _filters = {};

  @override
  Future<void> createAuditLog(AuditLog log) async => _auditLogs[log.logId] = log;

  @override
  Future<AuditLog?> getAuditLog(String logId) async => _auditLogs[logId];

  @override
  Future<List<AuditLog>> getAllAuditLogs() async => _auditLogs.values.toList();

  @override
  Future<List<AuditLog>> getAuditLogsByUser(String userId) async =>
      _auditLogs.values.where((log) => log.userId == userId).toList();

  @override
  Future<List<AuditLog>> getAuditLogsByResource(String resourceId) async =>
      _auditLogs.values.where((log) => log.resourceId == resourceId).toList();

  @override
  Future<List<AuditLog>> getAuditLogsByDateRange(DateTime start, DateTime end) async =>
      _auditLogs.values.where((log) => log.timestamp.isAfter(start) && log.timestamp.isBefore(end)).toList();

  @override
  Future<void> createComplianceRule(ComplianceRule rule) async =>
      _complianceRules[rule.ruleId] = rule;

  @override
  Future<ComplianceRule?> getComplianceRule(String ruleId) async => _complianceRules[ruleId];

  @override
  Future<List<ComplianceRule>> getAllComplianceRules() async => _complianceRules.values.toList();

  @override
  Future<void> updateComplianceRule(ComplianceRule rule) async =>
      _complianceRules[rule.ruleId] = rule;

  @override
  Future<void> deleteComplianceRule(String ruleId) async => _complianceRules.remove(ruleId);

  @override
  Future<void> createAuditTrail(AuditTrail trail) async => _auditTrails[trail.trailId] = trail;

  @override
  Future<AuditTrail?> getAuditTrail(String trailId) async => _auditTrails[trailId];

  @override
  Future<List<AuditTrail>> getAuditTrailsByEntity(String entityId) async =>
      _auditTrails.values.where((trail) => trail.entityId == entityId).toList();

  @override
  Future<void> createDataClassificationPolicy(DataClassificationPolicy policy) async =>
      _policies[policy.policyId] = policy;

  @override
  Future<DataClassificationPolicy?> getDataClassificationPolicy(String policyId) async =>
      _policies[policyId];

  @override
  Future<List<DataClassificationPolicy>> getAllPolicies() async => _policies.values.toList();

  @override
  Future<void> createRetentionRule(RetentionRule rule) async =>
      _retentionRules[rule.ruleId] = rule;

  @override
  Future<RetentionRule?> getRetentionRule(String ruleId) async => _retentionRules[ruleId];

  @override
  Future<List<RetentionRule>> getAllRetentionRules() async => _retentionRules.values.toList();

  @override
  Future<void> saveComplianceCheck(ComplianceCheck check) async =>
      _complianceChecks[check.checkId] = check;

  @override
  Future<ComplianceCheck?> getComplianceCheck(String checkId) async =>
      _complianceChecks[checkId];

  @override
  Future<List<ComplianceCheck>> getComplianceChecksByDateRange(DateTime start, DateTime end) async =>
      _complianceChecks.values
          .where((check) => check.executedAt.isAfter(start) && check.executedAt.isBefore(end))
          .toList();

  @override
  Future<void> saveAuditReport(AuditReport report) async =>
      _auditReports[report.reportId] = report;

  @override
  Future<AuditReport?> getAuditReport(String reportId) async => _auditReports[reportId];

  @override
  Future<List<AuditReport>> getRecentAuditReports(int limit) async =>
      _auditReports.values.toList()..sort((a, b) => b.generatedAt.compareTo(a.generatedAt))
          ..take(limit).toList();

  @override
  Future<void> createUserAccessLog(UserAccessLog log) async => _accessLogs.add(log);

  @override
  Future<List<UserAccessLog>> getUserAccessLogs(String userId) async =>
      _accessLogs.where((log) => log.userId == userId).toList();

  @override
  Future<List<UserAccessLog>> getAccessLogsByDateRange(DateTime start, DateTime end) async =>
      _accessLogs.where((log) => log.accessTime.isAfter(start) && log.accessTime.isBefore(end)).toList();

  @override
  Future<void> createChangeLog(ChangeLog log) async => _changeLogs.add(log);

  @override
  Future<List<ChangeLog>> getChangeLogsByResource(String resourceId) async =>
      _changeLogs.where((log) => log.resourceId == resourceId).toList();

  @override
  Future<List<ChangeLog>> getChangeLogsByUser(String userId) async =>
      _changeLogs.where((log) => log.modifiedBy == userId).toList();

  @override
  Future<void> saveComplianceMetrics(ComplianceMetrics metrics) async =>
      _metrics[metrics.metricsId] = metrics;

  @override
  Future<ComplianceMetrics?> getComplianceMetrics(String metricsId) async =>
      _metrics[metricsId];

  @override
  Future<List<ComplianceMetrics>> getRecentMetrics(int limit) async =>
      _metrics.values.toList()..sort((a, b) => b.calculatedAt.compareTo(a.calculatedAt))
          ..take(limit).toList();

  @override
  Future<void> createAuditFilter(AuditFilter filter) async =>
      _filters[filter.filterId] = filter;

  @override
  Future<AuditFilter?> getAuditFilter(String filterId) async => _filters[filterId];

  @override
  Future<List<AuditFilter>> getAllFilters() async => _filters.values.toList();
}

class AuditEngine {
  final AuditRepository repository;

  AuditEngine({required this.repository});

  Future<AuditLog> logEvent(
    String userId,
    String action,
    AuditEventType eventType,
    String resourceId,
    String resourceType,
    AuditActionStatus status,
    AuditSeverity severity, {
    Map<String, dynamic>? details,
  }) async {
    final log = AuditLog(
      logId: 'audit_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      action: action,
      eventType: eventType,
      timestamp: DateTime.now(),
      resourceId: resourceId,
      resourceType: resourceType,
      details: details ?? {},
      status: status,
      severity: severity,
    );
    await repository.createAuditLog(log);
    return log;
  }

  Future<List<AuditLog>> getFailedEvents(DateTime since) async {
    final allLogs = await repository.getAllAuditLogs();
    return allLogs
        .where((log) => log.isFailed && log.timestamp.isAfter(since))
        .toList();
  }

  Future<List<AuditLog>> getHighSeverityEvents(DateTime since) async {
    final allLogs = await repository.getAllAuditLogs();
    return allLogs
        .where((log) => log.isHighSeverity && log.timestamp.isAfter(since))
        .toList();
  }
}

class ComplianceEngine {
  final AuditRepository repository;

  ComplianceEngine({required this.repository});

  Future<ComplianceCheck> executeComplianceCheck(
    String checkName,
    String description,
    List<String> rulesToCheck,
  ) async {
    final rules = await repository.getAllComplianceRules();
    final applicableRules = rules.where((r) => rulesToCheck.contains(r.ruleId)).toList();

    final failedRules = <String>[];
    for (final rule in applicableRules) {
      if (!rule.isEnabled) {
        failedRules.add(rule.ruleId);
      }
    }

    final check = ComplianceCheck(
      checkId: 'check_${DateTime.now().millisecondsSinceEpoch}',
      checkName: checkName,
      description: description,
      executedAt: DateTime.now(),
      status: failedRules.isEmpty ? ComplianceStatus.compliant : ComplianceStatus.noncompliant,
      failedRules: failedRules,
      passedRules: applicableRules.length - failedRules.length,
      totalRules: applicableRules.length,
    );
    await repository.saveComplianceCheck(check);
    return check;
  }

  Future<ComplianceMetrics> calculateMetrics() async {
    final checks = await repository.getAllAuditLogs();
    final rules = await repository.getAllComplianceRules();

    final compliantRules = rules.where((r) => r.isEnabled).length;
    final total = rules.length;

    final metrics = ComplianceMetrics(
      metricsId: 'metrics_${DateTime.now().millisecondsSinceEpoch}',
      calculatedAt: DateTime.now(),
      overallScore: total > 0 ? (compliantRules / total) * 100 : 0.0,
      totalRulesChecked: total,
      rulesCompliant: compliantRules,
      rulesNonCompliant: total - compliantRules,
      categoryScores: {},
    );
    await repository.saveComplianceMetrics(metrics);
    return metrics;
  }
}

class AuditManager {
  final AuditRepository repository;
  final AuditEngine auditEngine;
  final ComplianceEngine complianceEngine;

  AuditManager({
    required this.repository,
    required this.auditEngine,
    required this.complianceEngine,
  });

  Future<AuditLog> recordEvent(
    String userId,
    String action,
    AuditEventType eventType,
    String resourceId,
    String resourceType,
    AuditActionStatus status,
    AuditSeverity severity, {
    Map<String, dynamic>? details,
  }) async {
    return await auditEngine.logEvent(
      userId,
      action,
      eventType,
      resourceId,
      resourceType,
      status,
      severity,
      details: details,
    );
  }

  Future<void> createComplianceRule(String ruleName, String description,
      List<String> resources, List<String> roles) async {
    final rule = ComplianceRule(
      ruleId: 'rule_${DateTime.now().millisecondsSinceEpoch}',
      ruleName: ruleName,
      description: description,
      applicableResources: resources,
      applicableRoles: roles,
      isEnabled: true,
      createdAt: DateTime.now(),
    );
    await repository.createComplianceRule(rule);
  }

  Future<AuditReport> generateAuditReport(DateTime start, DateTime end) async {
    final logs = await repository.getAuditLogsByDateRange(start, end);
    final failureCount = logs.where((l) => l.isFailed).length;
    final criticalEvents = logs.where((l) => l.isHighSeverity).map((l) => l.logId).toList();

    final eventsByType = <String, int>{};
    for (final log in logs) {
      eventsByType.update(log.eventType.toString(), (v) => v + 1, ifAbsent: () => 1);
    }

    final report = AuditReport(
      reportId: 'report_${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      periodStart: start,
      periodEnd: end,
      totalEvents: logs.length,
      failureCount: failureCount,
      criticalEvents: criticalEvents,
      eventsByType: eventsByType,
    );
    await repository.saveAuditReport(report);
    return report;
  }
}

class AuditFacade {
  final AuditManager manager;

  AuditFacade({required AuditManager? manager})
      : manager = manager ??
            AuditManager(
              repository: MemoryAuditRepository(),
              auditEngine: AuditEngine(repository: MemoryAuditRepository()),
              complianceEngine: ComplianceEngine(repository: MemoryAuditRepository()),
            );

  Future<AuditLog> logUserAction(
    String userId,
    String action,
    AuditEventType eventType,
    String resourceId,
    String resourceType,
    AuditActionStatus status,
    AuditSeverity severity, {
    Map<String, dynamic>? details,
  }) async {
    return await manager.recordEvent(
      userId,
      action,
      eventType,
      resourceId,
      resourceType,
      status,
      severity,
      details: details,
    );
  }

  Future<List<AuditLog>> getAuditLogs(String userId) async {
    return await manager.repository.getAuditLogsByUser(userId);
  }

  Future<List<AuditLog>> getResourceAuditLogs(String resourceId) async {
    return await manager.repository.getAuditLogsByResource(resourceId);
  }

  Future<void> createRule(String ruleName, String description,
      List<String> resources, List<String> roles) async {
    await manager.createComplianceRule(ruleName, description, resources, roles);
  }

  Future<List<ComplianceRule>> listComplianceRules() async {
    return await manager.repository.getAllComplianceRules();
  }

  Future<void> createDataPolicy(String policyName, DataClassification classification,
      List<String> roles, List<String> dataTypes) async {
    final policy = DataClassificationPolicy(
      policyId: 'policy_${DateTime.now().millisecondsSinceEpoch}',
      policyName: policyName,
      classification: classification,
      allowedRoles: roles,
      applicableDataTypes: dataTypes,
      createdAt: DateTime.now(),
    );
    await manager.repository.createDataClassificationPolicy(policy);
  }

  Future<List<DataClassificationPolicy>> listDataPolicies() async {
    return await manager.repository.getAllPolicies();
  }

  Future<void> createRetentionPolicy(String policyName, RetentionPolicy retention,
      List<String> logTypes) async {
    final rule = RetentionRule(
      ruleId: 'retention_${DateTime.now().millisecondsSinceEpoch}',
      ruleName: policyName,
      retentionPeriod: retention,
      applicableLogTypes: logTypes,
      createdAt: DateTime.now(),
    );
    await manager.repository.createRetentionRule(rule);
  }

  Future<ComplianceCheck> runComplianceCheck(
    String checkName,
    String description,
    List<String> rulesToCheck,
  ) async {
    return await manager.complianceEngine.executeComplianceCheck(
      checkName,
      description,
      rulesToCheck,
    );
  }

  Future<AuditReport> generateReport(DateTime start, DateTime end) async {
    return await manager.generateAuditReport(start, end);
  }

  Future<ComplianceMetrics> getComplianceMetrics() async {
    return await manager.complianceEngine.calculateMetrics();
  }

  Future<void> recordUserAccess(String userId, String action, String ipAddress,
      {String? deviceInfo, String? userAgent}) async {
    final log = UserAccessLog(
      logId: 'access_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      action: action,
      accessTime: DateTime.now(),
      ipAddress: ipAddress,
      deviceInfo: deviceInfo,
      userAgent: userAgent,
    );
    await manager.repository.createUserAccessLog(log);
  }

  Future<List<UserAccessLog>> getUserAccessHistory(String userId) async {
    return await manager.repository.getUserAccessLogs(userId);
  }

  Future<void> recordResourceChange(
    String resourceId,
    String resourceType,
    String fieldName,
    dynamic oldValue,
    dynamic newValue,
    String modifiedBy,
  ) async {
    final log = ChangeLog(
      logId: 'change_${DateTime.now().millisecondsSinceEpoch}',
      resourceId: resourceId,
      resourceType: resourceType,
      fieldName: fieldName,
      oldValue: oldValue,
      newValue: newValue,
      modifiedBy: modifiedBy,
      modifiedAt: DateTime.now(),
    );
    await manager.repository.createChangeLog(log);
  }

  Future<List<ChangeLog>> getResourceChangeHistory(String resourceId) async {
    return await manager.repository.getChangeLogsByResource(resourceId);
  }
}
