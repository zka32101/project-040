/// Audit Logging & Compliance Models

enum AuditEventType { create, read, update, delete, login, logout, export, import, share, permission }
enum AuditSeverity { low, medium, high, critical }
enum ComplianceStatus { compliant, noncompliant, pending, exempted }
enum DataClassification { public, internal, confidential, restricted }
enum RetentionPolicy { thirtyDays, ninetyDays, oneYear, threeYears, permanent }
enum AuditActionStatus { success, failed, partial }

class AuditLog {
  final String logId;
  final String userId;
  final String action;
  final AuditEventType eventType;
  final DateTime timestamp;
  final String resourceId;
  final String resourceType;
  final Map<String, dynamic> details;
  final AuditActionStatus status;
  final AuditSeverity severity;

  AuditLog({
    required this.logId,
    required this.userId,
    required this.action,
    required this.eventType,
    required this.timestamp,
    required this.resourceId,
    required this.resourceType,
    required this.details,
    required this.status,
    required this.severity,
  });

  bool get isRecent => DateTime.now().difference(timestamp).inDays < 7;
  bool get isFailed => status == AuditActionStatus.failed;
  bool get isHighSeverity => severity == AuditSeverity.high || severity == AuditSeverity.critical;
  int get ageInDays => DateTime.now().difference(timestamp).inDays;
}

class ComplianceRule {
  final String ruleId;
  final String ruleName;
  final String description;
  final List<String> applicableResources;
  final List<String> applicableRoles;
  final bool isEnabled;
  final DateTime createdAt;

  ComplianceRule({
    required this.ruleId,
    required this.ruleName,
    required this.description,
    required this.applicableResources,
    required this.applicableRoles,
    required this.isEnabled,
    required this.createdAt,
  });

  bool get isActive => isEnabled;
  int get resourceCount => applicableResources.length;
  int get roleCount => applicableRoles.length;
}

class AuditTrail {
  final String trailId;
  final String entityId;
  final String entityType;
  final List<String> logIds;
  final DateTime startTime;
  final DateTime? endTime;
  final int totalEvents;

  AuditTrail({
    required this.trailId,
    required this.entityId,
    required this.entityType,
    required this.logIds,
    required this.startTime,
    this.endTime,
    this.totalEvents = 0,
  });

  bool get isOngoing => endTime == null;
  int get eventCount => logIds.length;
  int get durationInDays => endTime != null ? endTime!.difference(startTime).inDays : 0;
}

class DataClassificationPolicy {
  final String policyId;
  final String policyName;
  final DataClassification classification;
  final List<String> allowedRoles;
  final List<String> applicableDataTypes;
  final DateTime createdAt;
  final bool isActive;

  DataClassificationPolicy({
    required this.policyId,
    required this.policyName,
    required this.classification,
    required this.allowedRoles,
    required this.applicableDataTypes,
    required this.createdAt,
    this.isActive = true,
  });

  bool get isRestricted => classification == DataClassification.restricted;
  bool get isConfidential => classification == DataClassification.confidential;
  int get allowedRoleCount => allowedRoles.length;
}

class RetentionRule {
  final String ruleId;
  final String ruleName;
  final RetentionPolicy retentionPeriod;
  final List<String> applicableLogTypes;
  final DateTime createdAt;
  final bool isEnabled;

  RetentionRule({
    required this.ruleId,
    required this.ruleName,
    required this.retentionPeriod,
    required this.applicableLogTypes,
    required this.createdAt,
    this.isEnabled = true,
  });

  bool get isActive => isEnabled;
  int get logTypeCount => applicableLogTypes.length;
}

class ComplianceCheck {
  final String checkId;
  final String checkName;
  final String description;
  final DateTime executedAt;
  final ComplianceStatus status;
  final List<String> failedRules;
  final int passedRules;
  final int totalRules;

  ComplianceCheck({
    required this.checkId,
    required this.checkName,
    required this.description,
    required this.executedAt,
    required this.status,
    required this.failedRules,
    required this.passedRules,
    required this.totalRules,
  });

  bool get passed => status == ComplianceStatus.compliant;
  double get complianceScore => totalRules > 0 ? (passedRules / totalRules) * 100 : 0.0;
  bool get isHealthy => complianceScore > 95.0;
  int get ageInDays => DateTime.now().difference(executedAt).inDays;
}

class AuditReport {
  final String reportId;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalEvents;
  final int failureCount;
  final List<String> criticalEvents;
  final Map<String, int> eventsByType;

  AuditReport({
    required this.reportId,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.totalEvents,
    required this.failureCount,
    required this.criticalEvents,
    required this.eventsByType,
  });

  double get failureRate => totalEvents > 0 ? (failureCount / totalEvents) * 100 : 0.0;
  bool get hasFailures => failureCount > 0;
  bool get hasCriticalEvents => criticalEvents.isNotEmpty;
  int get periodInDays => periodEnd.difference(periodStart).inDays;
}

class UserAccessLog {
  final String logId;
  final String userId;
  final String action;
  final DateTime accessTime;
  final String ipAddress;
  final String? deviceInfo;
  final String? userAgent;
  final bool isSuccessful;

  UserAccessLog({
    required this.logId,
    required this.userId,
    required this.action,
    required this.accessTime,
    required this.ipAddress,
    this.deviceInfo,
    this.userAgent,
    this.isSuccessful = true,
  });

  bool get isRecent => DateTime.now().difference(accessTime).inHours < 24;
  bool get isFailed => !isSuccessful;
  int get ageInHours => DateTime.now().difference(accessTime).inHours;
}

class ChangeLog {
  final String logId;
  final String resourceId;
  final String resourceType;
  final String fieldName;
  final dynamic oldValue;
  final dynamic newValue;
  final String modifiedBy;
  final DateTime modifiedAt;

  ChangeLog({
    required this.logId,
    required this.resourceId,
    required this.resourceType,
    required this.fieldName,
    required this.oldValue,
    required this.newValue,
    required this.modifiedBy,
    required this.modifiedAt,
  });

  bool get hasValueChanged => oldValue != newValue;
  bool get isRecent => DateTime.now().difference(modifiedAt).inDays < 30;
}

class ComplianceMetrics {
  final String metricsId;
  final DateTime calculatedAt;
  final double overallScore;
  final int totalRulesChecked;
  final int rulesCompliant;
  final int rulesNonCompliant;
  final Map<String, double> categoryScores;

  ComplianceMetrics({
    required this.metricsId,
    required this.calculatedAt,
    required this.overallScore,
    required this.totalRulesChecked,
    required this.rulesCompliant,
    required this.rulesNonCompliant,
    required this.categoryScores,
  });

  bool get isHealthy => overallScore > 95.0;
  double get compliancePercentage => overallScore;
  int get ageInDays => DateTime.now().difference(calculatedAt).inDays;
}

class AuditFilter {
  final String filterId;
  final String filterName;
  final AuditEventType? eventType;
  final String? userId;
  final AuditSeverity? severity;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  AuditFilter({
    required this.filterId,
    required this.filterName,
    this.eventType,
    this.userId,
    this.severity,
    this.startDate,
    this.endDate,
    this.isActive = true,
  });

  bool get hasFilters =>
      eventType != null || userId != null || severity != null || startDate != null || endDate != null;
  int get activeFilterCount =>
      (eventType != null ? 1 : 0) +
      (userId != null ? 1 : 0) +
      (severity != null ? 1 : 0) +
      (startDate != null ? 1 : 0) +
      (endDate != null ? 1 : 0);
}
