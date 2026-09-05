/// SLA Management & Monitoring Models

enum SLAStatus { active, inactive, expired, suspended, archived }
enum MetricType { availability, latency, throughput, errorRate, responseTime }
enum BreachSeverity { critical, high, medium, low }
enum AlertState { active, inactive, triggered, acknowledged, resolved }
enum ReportFrequency { daily, weekly, monthly, quarterly, annual }
enum ComplianceStatus { compliant, atRisk, nonCompliant, waived }

class ServiceLevelAgreement {
  final String slaId;
  final String serviceName;
  final String customerId;
  final DateTime startDate;
  final DateTime? endDate;
  final SLAStatus status;
  final double targetAvailability;
  final Map<String, dynamic> terms;
  final String? notes;

  ServiceLevelAgreement({
    required this.slaId,
    required this.serviceName,
    required this.customerId,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.targetAvailability,
    required this.terms,
    this.notes,
  });

  bool get isActive => status == SLAStatus.active;
  bool get isExpired => endDate != null && endDate!.isBefore(DateTime.now());
  int get ageInDays => DateTime.now().difference(startDate).inDays;
}

class SLAMetric {
  final String metricId;
  final String slaId;
  final MetricType type;
  final double currentValue;
  final double targetValue;
  final DateTime measuredAt;
  final bool isCompliant;
  final Map<String, dynamic> details;

  SLAMetric({
    required this.metricId,
    required this.slaId,
    required this.type,
    required this.currentValue,
    required this.targetValue,
    required this.measuredAt,
    required this.isCompliant,
    required this.details,
  });

  double get variance => currentValue - targetValue;
  double get percentageOfTarget => targetValue > 0 ? (currentValue / targetValue) * 100 : 0.0;
  bool get isAboveTarget => currentValue > targetValue;
  int get ageInMinutes => DateTime.now().difference(measuredAt).inMinutes;
}

class SLAThreshold {
  final String thresholdId;
  final String slaId;
  final MetricType type;
  final double warningLevel;
  final double criticalLevel;
  final DateTime createdAt;
  final bool isActive;

  SLAThreshold({
    required this.thresholdId,
    required this.slaId,
    required this.type,
    required this.warningLevel,
    required this.criticalLevel,
    required this.createdAt,
    this.isActive = true,
  });

  bool get isCritical => criticalLevel > 0;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class ServiceLevelIndicator {
  final String sliId;
  final String slaId;
  final String name;
  final String description;
  final double measuredValue;
  final double targetValue;
  final DateTime calculatedAt;
  final String unit;

  ServiceLevelIndicator({
    required this.sliId,
    required this.slaId,
    required this.name,
    required this.description,
    required this.measuredValue,
    required this.targetValue,
    required this.calculatedAt,
    required this.unit,
  });

  bool get isMet => measuredValue >= targetValue;
  double get achievement => targetValue > 0 ? (measuredValue / targetValue) * 100 : 0.0;
  int get ageInHours => DateTime.now().difference(calculatedAt).inHours;
}

class PerformanceMetric {
  final String metricId;
  final String slaId;
  final MetricType type;
  final double min;
  final double max;
  final double average;
  final double percentile95;
  final DateTime periodStart;
  final DateTime periodEnd;

  PerformanceMetric({
    required this.metricId,
    required this.slaId,
    required this.type,
    required this.min,
    required this.max,
    required this.average,
    required this.percentile95,
    required this.periodStart,
    required this.periodEnd,
  });

  double get variance => max - min;
  double get range => max - min;
  int get periodInDays => periodEnd.difference(periodStart).inDays;
}

class SLABreach {
  final String breachId;
  final String slaId;
  final MetricType type;
  final BreachSeverity severity;
  final DateTime breachTime;
  final DateTime? resolvedTime;
  final String description;
  final String? rootCause;
  final String? resolution;

  SLABreach({
    required this.breachId,
    required this.slaId,
    required this.type,
    required this.severity,
    required this.breachTime,
    this.resolvedTime,
    required this.description,
    this.rootCause,
    this.resolution,
  });

  bool get isResolved => resolvedTime != null;
  bool get isCritical => severity == BreachSeverity.critical;
  int get durationMinutes => resolvedTime != null
      ? resolvedTime!.difference(breachTime).inMinutes
      : DateTime.now().difference(breachTime).inMinutes;
}

class AlertPolicy {
  final String policyId;
  final String slaId;
  final MetricType metricType;
  final double threshold;
  final int triggerCount;
  final DateTime createdAt;
  final bool isActive;
  final String notificationChannel;

  AlertPolicy({
    required this.policyId,
    required this.slaId,
    required this.metricType,
    required this.threshold,
    required this.triggerCount,
    required this.createdAt,
    this.isActive = true,
    required this.notificationChannel,
  });

  bool get isSensitive => triggerCount <= 3;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class Alert {
  final String alertId;
  final String policyId;
  final String slaId;
  final DateTime triggeredAt;
  final DateTime? clearedAt;
  final AlertState state;
  final String message;
  final String severity;
  final int escalationLevel;

  Alert({
    required this.alertId,
    required this.policyId,
    required this.slaId,
    required this.triggeredAt,
    this.clearedAt,
    required this.state,
    required this.message,
    required this.severity,
    this.escalationLevel = 1,
  });

  bool get isActive => state == AlertState.active || state == AlertState.triggered;
  bool get isResolved => clearedAt != null;
  int get durationMinutes => clearedAt != null
      ? clearedAt!.difference(triggeredAt).inMinutes
      : DateTime.now().difference(triggeredAt).inMinutes;
}

class SLACompliance {
  final String complianceId;
  final String slaId;
  final DateTime evaluatedAt;
  final ComplianceStatus status;
  final double compliancePercentage;
  final int breachCount;
  final int totalSlaBreach;
  final String? notes;

  SLACompliance({
    required this.complianceId,
    required this.slaId,
    required this.evaluatedAt,
    required this.status,
    required this.compliancePercentage,
    required this.breachCount,
    required this.totalSlaBreach,
    this.notes,
  });

  bool get isCompliant => status == ComplianceStatus.compliant;
  bool get atRisk => status == ComplianceStatus.atRisk;
  int get ageInDays => DateTime.now().difference(evaluatedAt).inDays;
}

class SLAHistory {
  final String historyId;
  final String slaId;
  final DateTime timestamp;
  final String eventType;
  final String details;
  final String? previousValue;
  final String? newValue;

  SLAHistory({
    required this.historyId,
    required this.slaId,
    required this.timestamp,
    required this.eventType,
    required this.details,
    this.previousValue,
    this.newValue,
  });

  int get ageInMinutes => DateTime.now().difference(timestamp).inMinutes;
}

class SLAReport {
  final String reportId;
  final String slaId;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double uptime;
  final double avgLatency;
  final double errorRate;
  final int totalBreaches;
  final List<String> recommendations;

  SLAReport({
    required this.reportId,
    required this.slaId,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.uptime,
    required this.avgLatency,
    required this.errorRate,
    required this.totalBreaches,
    required this.recommendations,
  });

  bool get isPassed => uptime >= 99.0 && errorRate <= 1.0;
  int get periodInDays => periodEnd.difference(periodStart).inDays;
}

class SLAGoal {
  final String goalId;
  final String slaId;
  final MetricType type;
  final double targetValue;
  final double currentValue;
  final DateTime setDate;
  final DateTime? dueDate;
  final bool isAchieved;

  SLAGoal({
    required this.goalId,
    required this.slaId,
    required this.type,
    required this.targetValue,
    required this.currentValue,
    required this.setDate,
    this.dueDate,
    required this.isAchieved,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue) * 100 : 0.0;
  int get ageInDays => DateTime.now().difference(setDate).inDays;
}
