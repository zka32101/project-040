/// Incident Management & Response Models

enum IncidentSeverity { critical, high, medium, low, info }
enum IncidentStatus { open, acknowledged, investigating, resolved, closed, reopened }
enum IncidentPriority { p0, p1, p2, p3, p4 }
enum ImpactScope { global, regional, service, component, user }
enum ResolutionType { fix, workaround, rollback, scaling, configuration, investigation }
enum PostmortemStatus { pending, draft, review, published, archived }

class Incident {
  final String incidentId;
  final String title;
  final String description;
  final IncidentSeverity severity;
  final IncidentStatus status;
  final IncidentPriority priority;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String assignedTo;
  final List<String> affectedServices;
  final List<String> affectedUsers;

  Incident({
    required this.incidentId,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.resolvedAt,
    this.resolvedBy,
    required this.assignedTo,
    required this.affectedServices,
    required this.affectedUsers,
  });

  bool get isOpen => status == IncidentStatus.open || status == IncidentStatus.investigating;
  bool get isCritical => severity == IncidentSeverity.critical;
  bool get isResolved => status == IncidentStatus.resolved || status == IncidentStatus.closed;
  int get durationMinutes => resolvedAt != null ? resolvedAt!.difference(createdAt).inMinutes : -1;
  int get ageInMinutes => DateTime.now().difference(createdAt).inMinutes;
  double get impactScore => (severity.index + 1) * (affectedUsers.length + 1) * (affectedServices.length + 1) / 100;
}

class IncidentTimeline {
  final String timelineId;
  final String incidentId;
  final DateTime timestamp;
  final String eventType;
  final String description;
  final String triggeredBy;
  final Map<String, dynamic> metadata;

  IncidentTimeline({
    required this.timelineId,
    required this.incidentId,
    required this.timestamp,
    required this.eventType,
    required this.description,
    required this.triggeredBy,
    required this.metadata,
  });

  bool get isRecent => DateTime.now().difference(timestamp).inHours < 24;
  int get ageInHours => DateTime.now().difference(timestamp).inHours;
}

class IncidentImpactAnalysis {
  final String analysisId;
  final String incidentId;
  final ImpactScope scope;
  final int estimatedAffectedUsers;
  final List<String> affectedServices;
  final List<String> dependentServices;
  final double estimatedRevenueLoss;
  final DateTime analyzedAt;

  IncidentImpactAnalysis({
    required this.analysisId,
    required this.incidentId,
    required this.scope,
    required this.estimatedAffectedUsers,
    required this.affectedServices,
    required this.dependentServices,
    required this.estimatedRevenueLoss,
    required this.analyzedAt,
  });

  bool get isGlobal => scope == ImpactScope.global;
  bool get hasHighImpact => estimatedAffectedUsers > 10000 || estimatedRevenueLoss > 10000;
  int get totalAffectedServices => affectedServices.length + dependentServices.length;
  int get ageInMinutes => DateTime.now().difference(analyzedAt).inMinutes;
}

class IncidentEscalation {
  final String escalationId;
  final String incidentId;
  final int escalationLevel;
  final String escalatedTo;
  final String reason;
  final DateTime escalatedAt;
  final DateTime? acknowledgedAt;
  final bool isResolved;

  IncidentEscalation({
    required this.escalationId,
    required this.incidentId,
    required this.escalationLevel,
    required this.escalatedTo,
    required this.reason,
    required this.escalatedAt,
    this.acknowledgedAt,
    this.isResolved = false,
  });

  bool get isAcknowledged => acknowledgedAt != null;
  bool get isPending => !isAcknowledged;
  int get responseTimeMinutes => acknowledgedAt != null 
      ? acknowledgedAt!.difference(escalatedAt).inMinutes 
      : DateTime.now().difference(escalatedAt).inMinutes;
  int get ageInMinutes => DateTime.now().difference(escalatedAt).inMinutes;
}

class IncidentCommunication {
  final String communicationId;
  final String incidentId;
  final String channelType;
  final String recipient;
  final String message;
  final DateTime sentAt;
  final String sentBy;
  final bool isRead;
  final String? responseMessage;

  IncidentCommunication({
    required this.communicationId,
    required this.incidentId,
    required this.channelType,
    required this.recipient,
    required this.message,
    required this.sentAt,
    required this.sentBy,
    this.isRead = false,
    this.responseMessage,
  });

  bool get hasResponse => responseMessage != null && responseMessage!.isNotEmpty;
  bool get isPending => !isRead;
  int get ageInMinutes => DateTime.now().difference(sentAt).inMinutes;
}

class IncidentResolution {
  final String resolutionId;
  final String incidentId;
  final ResolutionType resolutionType;
  final String description;
  final DateTime implementedAt;
  final String implementedBy;
  final bool isVerified;
  final String? verificationDetails;

  IncidentResolution({
    required this.resolutionId,
    required this.incidentId,
    required this.resolutionType,
    required this.description,
    required this.implementedAt,
    required this.implementedBy,
    this.isVerified = false,
    this.verificationDetails,
  });

  bool get isPending => !isVerified;
  int get ageInMinutes => DateTime.now().difference(implementedAt).inMinutes;
}

class IncidentPostmortem {
  final String postmortemId;
  final String incidentId;
  final String title;
  final String rootCauseAnalysis;
  final List<String> contributingFactors;
  final List<String> actionItems;
  final List<String> preventionMeasures;
  final PostmortemStatus status;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String createdBy;

  IncidentPostmortem({
    required this.postmortemId,
    required this.incidentId,
    required this.title,
    required this.rootCauseAnalysis,
    required this.contributingFactors,
    required this.actionItems,
    required this.preventionMeasures,
    required this.status,
    required this.createdAt,
    this.publishedAt,
    required this.createdBy,
  });

  bool get isPublished => status == PostmortemStatus.published;
  bool get isPending => status == PostmortemStatus.pending || status == PostmortemStatus.draft;
  int get actionItemCount => actionItems.length;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class IncidentNotification {
  final String notificationId;
  final String incidentId;
  final String notificationType;
  final List<String> recipients;
  final String subject;
  final String body;
  final DateTime createdAt;
  final DateTime? sentAt;
  final int sentCount;
  final int failedCount;

  IncidentNotification({
    required this.notificationId,
    required this.incidentId,
    required this.notificationType,
    required this.recipients,
    required this.subject,
    required this.body,
    required this.createdAt,
    this.sentAt,
    this.sentCount = 0,
    this.failedCount = 0,
  });

  bool get isSent => sentAt != null;
  bool get hasFailed => failedCount > 0;
  double get successRate => sentCount > 0 ? ((sentCount - failedCount) / sentCount) * 100 : 0.0;
  int get ageInMinutes => DateTime.now().difference(createdAt).inMinutes;
}

class IncidentTrendAnalysis {
  final String analysisId;
  final DateTime analyzedAt;
  final int incidentsInPeriod;
  final double averageDuration;
  final double averageTimeToResolution;
  final Map<IncidentSeverity, int> severityDistribution;
  final List<String> topAffectedServices;
  final double mtbf; // Mean Time Between Failures
  final double mttr; // Mean Time To Resolution
  final double mtrc; // Mean Time To Restoration

  IncidentTrendAnalysis({
    required this.analysisId,
    required this.analyzedAt,
    required this.incidentsInPeriod,
    required this.averageDuration,
    required this.averageTimeToResolution,
    required this.severityDistribution,
    required this.topAffectedServices,
    required this.mtbf,
    required this.mttr,
    required this.mtrc,
  });

  bool get hasIncidents => incidentsInPeriod > 0;
  int get criticalIncidents => severityDistribution[IncidentSeverity.critical] ?? 0;
  double get improvementRate => mttr > 0 ? (mtbf / mttr) * 100 : 0.0;
  int get ageInDays => DateTime.now().difference(analyzedAt).inDays;
}

class IncidentReport {
  final String reportId;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalIncidents;
  final int resolvedIncidents;
  final int unresolved;
  final int escalatedIncidents;
  final Map<IncidentSeverity, int> severityBreakdown;
  final double averageResolutionTime;

  IncidentReport({
    required this.reportId,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.totalIncidents,
    required this.resolvedIncidents,
    required this.unresolved,
    required this.escalatedIncidents,
    required this.severityBreakdown,
    required this.averageResolutionTime,
  });

  double get resolutionRate => totalIncidents > 0 ? (resolvedIncidents / totalIncidents) * 100 : 0.0;
  int get criticalCount => severityBreakdown[IncidentSeverity.critical] ?? 0;
  int get periodInDays => periodEnd.difference(periodStart).inDays;
  bool get hasHighUnresolved => unresolved > (totalIncidents * 0.1);
}

class IncidentFilter {
  final String filterId;
  final String filterName;
  final IncidentSeverity? severity;
  final IncidentStatus? status;
  final String? assignedTo;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  IncidentFilter({
    required this.filterId,
    required this.filterName,
    this.severity,
    this.status,
    this.assignedTo,
    this.startDate,
    this.endDate,
    this.isActive = true,
  });

  bool get hasFilters =>
      severity != null || status != null || assignedTo != null || startDate != null || endDate != null;
  int get activeFilterCount =>
      (severity != null ? 1 : 0) +
      (status != null ? 1 : 0) +
      (assignedTo != null ? 1 : 0) +
      (startDate != null ? 1 : 0) +
      (endDate != null ? 1 : 0);
}
