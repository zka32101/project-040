/// Incident Management & Response Service

import 'package:project_040/models/incident_models.dart';

// ============================================================================
// Repository Interface (45 Methods)
// ============================================================================

abstract class IncidentRepository {
  // Incident Management (10 methods)
  Future<Incident> createIncident(String title, String description, IncidentSeverity severity, String assignedTo);
  Future<Incident?> getIncident(String incidentId);
  Future<Incident> updateIncident(String incidentId, {String? title, String? description, IncidentStatus? status, String? assignedTo});
  Future<void> deleteIncident(String incidentId);
  Future<List<Incident>> listIncidents({int limit = 50, String? status, String? severity});
  Future<List<Incident>> getOpenIncidents();
  Future<List<Incident>> getCriticalIncidents();
  Future<List<Incident>> getIncidentsByService(String serviceId);
  Future<List<Incident>> getIncidentsByUser(String userId);
  Future<void> bulkUpdateIncidents(List<String> incidentIds, IncidentStatus status);

  // Timeline Events (8 methods)
  Future<IncidentTimeline> createTimelineEvent(String incidentId, String eventType, String description, String triggeredBy);
  Future<IncidentTimeline?> getTimelineEvent(String timelineId);
  Future<List<IncidentTimeline>> getIncidentTimeline(String incidentId);
  Future<void> deleteTimelineEvent(String timelineId);
  Future<List<IncidentTimeline>> getRecentTimelineEvents(int hoursBack);
  Future<List<IncidentTimeline>> getTimelineEventsByType(String incidentId, String eventType);
  Future<int> getTimelineEventCount(String incidentId);
  Future<void> archiveTimelineEvents(String incidentId, DateTime beforeDate);

  // Impact Analysis (7 methods)
  Future<IncidentImpactAnalysis> analyzeIncidentImpact(String incidentId);
  Future<IncidentImpactAnalysis?> getImpactAnalysis(String analysisId);
  Future<void> updateImpactAnalysis(String analysisId, int affectedUsers, double revenueLoss);
  Future<List<IncidentImpactAnalysis>> getHighImpactIncidents();
  Future<List<IncidentImpactAnalysis>> getGlobalImpactIncidents();
  Future<double> calculateTotalRevenueLoss(DateTime startDate, DateTime endDate);
  Future<List<String>> getMostAffectedServices(int limit);

  // Escalation Management (6 methods)
  Future<IncidentEscalation> escalateIncident(String incidentId, int level, String escalatedTo, String reason);
  Future<IncidentEscalation?> getEscalation(String escalationId);
  Future<List<IncidentEscalation>> getPendingEscalations();
  Future<void> acknowledgeEscalation(String escalationId);
  Future<void> resolveEscalation(String escalationId);
  Future<List<IncidentEscalation>> getEscalationsByIncident(String incidentId);

  // Communication Management (6 methods)
  Future<IncidentCommunication> sendCommunication(String incidentId, String channelType, String recipient, String message, String sentBy);
  Future<IncidentCommunication?> getCommunication(String communicationId);
  Future<List<IncidentCommunication>> getIncidentCommunications(String incidentId);
  Future<void> markCommunicationAsRead(String communicationId);
  Future<void> addResponseToCommunication(String communicationId, String response);
  Future<int> getPendingCommunicationCount();

  // Resolution Management (5 methods)
  Future<IncidentResolution> recordResolution(String incidentId, ResolutionType type, String description, String implementedBy);
  Future<IncidentResolution?> getResolution(String resolutionId);
  Future<IncidentResolution?> getIncidentResolution(String incidentId);
  Future<void> verifyResolution(String resolutionId, String verificationDetails);
  Future<List<IncidentResolution>> getUnverifiedResolutions();

  // Postmortem Management (6 methods)
  Future<IncidentPostmortem> createPostmortem(String incidentId, String title, String rootCauseAnalysis, String createdBy);
  Future<IncidentPostmortem?> getPostmortem(String postmortemId);
  Future<void> updatePostmortem(String postmortemId, {String? analysis, List<String>? actionItems});
  Future<void> publishPostmortem(String postmortemId);
  Future<List<IncidentPostmortem>> getPendingPostmortems();
  Future<List<IncidentPostmortem>> getPublishedPostmortems();

  // Notification Management (5 methods)
  Future<IncidentNotification> createNotification(String incidentId, String type, List<String> recipients, String subject, String body);
  Future<IncidentNotification?> getNotification(String notificationId);
  Future<void> recordNotificationSent(String notificationId, int sentCount, int failedCount);
  Future<List<IncidentNotification>> getUnsentNotifications();
  Future<List<IncidentNotification>> getIncidentNotifications(String incidentId);

  // Trends & Analytics (4 methods)
  Future<IncidentTrendAnalysis> analyzeTrends(DateTime startDate, DateTime endDate);
  Future<IncidentReport> generateReport(DateTime startDate, DateTime endDate);
  Future<Map<String, int>> getIncidentMetrics();
  Future<List<Incident>> getIncidentsByFilter(IncidentFilter filter);
}

// ============================================================================
// In-Memory Repository Implementation
// ============================================================================

class IncidentRepositoryImpl implements IncidentRepository {
  final Map<String, Map<String, dynamic>> _storage = {};

  IncidentRepositoryImpl() {
    _storage['incidents'] = {};
    _storage['timelines'] = {};
    _storage['impacts'] = {};
    _storage['escalations'] = {};
    _storage['communications'] = {};
    _storage['resolutions'] = {};
    _storage['postmortems'] = {};
    _storage['notifications'] = {};
  }

  // Incident Management Implementation
  @override
  Future<Incident> createIncident(String title, String description, IncidentSeverity severity, String assignedTo) async {
    final incident = Incident(
      incidentId: 'inc_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      severity: severity,
      status: IncidentStatus.open,
      priority: IncidentPriority.p1,
      createdAt: DateTime.now(),
      assignedTo: assignedTo,
      affectedServices: [],
      affectedUsers: [],
    );
    _storage['incidents']![incident.incidentId] = _incidentToMap(incident);
    return incident;
  }

  @override
  Future<Incident?> getIncident(String incidentId) async {
    final data = _storage['incidents']![incidentId];
    return data != null ? _mapToIncident(data) : null;
  }

  @override
  Future<Incident> updateIncident(String incidentId, {String? title, String? description, IncidentStatus? status, String? assignedTo}) async {
    final data = _storage['incidents']![incidentId];
    if (data == null) throw Exception('Incident not found');
    
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (status != null) {
      data['status'] = status.toString().split('.').last;
      if (status == IncidentStatus.resolved || status == IncidentStatus.closed) {
        data['resolvedAt'] = DateTime.now();
      }
    }
    if (assignedTo != null) data['assignedTo'] = assignedTo;
    
    return _mapToIncident(data);
  }

  @override
  Future<void> deleteIncident(String incidentId) async {
    _storage['incidents']!.remove(incidentId);
  }

  @override
  Future<List<Incident>> listIncidents({int limit = 50, String? status, String? severity}) async {
    final incidents = _storage['incidents']!.values.toList();
    return incidents.map(_mapToIncident).toList().take(limit).toList();
  }

  @override
  Future<List<Incident>> getOpenIncidents() async {
    final incidents = _storage['incidents']!.values
        .where((i) => i['status'] == 'open' || i['status'] == 'investigating')
        .map(_mapToIncident)
        .toList();
    return incidents;
  }

  @override
  Future<List<Incident>> getCriticalIncidents() async {
    final incidents = _storage['incidents']!.values
        .where((i) => i['severity'] == 'critical')
        .map(_mapToIncident)
        .toList();
    return incidents;
  }

  @override
  Future<List<Incident>> getIncidentsByService(String serviceId) async {
    final incidents = _storage['incidents']!.values
        .where((i) => (i['affectedServices'] as List).contains(serviceId))
        .map(_mapToIncident)
        .toList();
    return incidents;
  }

  @override
  Future<List<Incident>> getIncidentsByUser(String userId) async {
    final incidents = _storage['incidents']!.values
        .where((i) => (i['affectedUsers'] as List).contains(userId))
        .map(_mapToIncident)
        .toList();
    return incidents;
  }

  @override
  Future<void> bulkUpdateIncidents(List<String> incidentIds, IncidentStatus status) async {
    for (final id in incidentIds) {
      _storage['incidents']![id]?['status'] = status.toString().split('.').last;
    }
  }

  // Timeline Implementation
  @override
  Future<IncidentTimeline> createTimelineEvent(String incidentId, String eventType, String description, String triggeredBy) async {
    final event = IncidentTimeline(
      timelineId: 'tl_${DateTime.now().millisecondsSinceEpoch}',
      incidentId: incidentId,
      timestamp: DateTime.now(),
      eventType: eventType,
      description: description,
      triggeredBy: triggeredBy,
      metadata: {},
    );
    _storage['timelines']![event.timelineId] = _timelineToMap(event);
    return event;
  }

  @override
  Future<IncidentTimeline?> getTimelineEvent(String timelineId) async {
    final data = _storage['timelines']![timelineId];
    return data != null ? _mapToTimeline(data) : null;
  }

  @override
  Future<List<IncidentTimeline>> getIncidentTimeline(String incidentId) async {
    final timelines = _storage['timelines']!.values
        .where((t) => t['incidentId'] == incidentId)
        .map(_mapToTimeline)
        .toList();
    return timelines;
  }

  @override
  Future<void> deleteTimelineEvent(String timelineId) async {
    _storage['timelines']!.remove(timelineId);
  }

  @override
  Future<List<IncidentTimeline>> getRecentTimelineEvents(int hoursBack) async {
    final since = DateTime.now().subtract(Duration(hours: hoursBack));
    final events = _storage['timelines']!.values
        .where((e) => DateTime.parse(e['timestamp']).isAfter(since))
        .map(_mapToTimeline)
        .toList();
    return events;
  }

  @override
  Future<List<IncidentTimeline>> getTimelineEventsByType(String incidentId, String eventType) async {
    final events = _storage['timelines']!.values
        .where((e) => e['incidentId'] == incidentId && e['eventType'] == eventType)
        .map(_mapToTimeline)
        .toList();
    return events;
  }

  @override
  Future<int> getTimelineEventCount(String incidentId) async {
    return _storage['timelines']!.values.where((t) => t['incidentId'] == incidentId).length;
  }

  @override
  Future<void> archiveTimelineEvents(String incidentId, DateTime beforeDate) async {
    _storage['timelines']!.removeWhere((k, v) =>
        v['incidentId'] == incidentId && DateTime.parse(v['timestamp']).isBefore(beforeDate));
  }

  // Impact Analysis Implementation
  @override
  Future<IncidentImpactAnalysis> analyzeIncidentImpact(String incidentId) async {
    final analysis = IncidentImpactAnalysis(
      analysisId: 'ana_${DateTime.now().millisecondsSinceEpoch}',
      incidentId: incidentId,
      scope: ImpactScope.service,
      estimatedAffectedUsers: 100,
      affectedServices: [],
      dependentServices: [],
      estimatedRevenueLoss: 5000.0,
      analyzedAt: DateTime.now(),
    );
    _storage['impacts']![analysis.analysisId] = _impactToMap(analysis);
    return analysis;
  }

  @override
  Future<IncidentImpactAnalysis?> getImpactAnalysis(String analysisId) async {
    final data = _storage['impacts']![analysisId];
    return data != null ? _mapToImpact(data) : null;
  }

  @override
  Future<void> updateImpactAnalysis(String analysisId, int affectedUsers, double revenueLoss) async {
    final data = _storage['impacts']![analysisId];
    if (data != null) {
      data['estimatedAffectedUsers'] = affectedUsers;
      data['estimatedRevenueLoss'] = revenueLoss;
    }
  }

  @override
  Future<List<IncidentImpactAnalysis>> getHighImpactIncidents() async {
    final impacts = _storage['impacts']!.values
        .where((i) => i['estimatedAffectedUsers'] > 10000 || i['estimatedRevenueLoss'] > 10000)
        .map(_mapToImpact)
        .toList();
    return impacts;
  }

  @override
  Future<List<IncidentImpactAnalysis>> getGlobalImpactIncidents() async {
    final impacts = _storage['impacts']!.values
        .where((i) => i['scope'] == 'global')
        .map(_mapToImpact)
        .toList();
    return impacts;
  }

  @override
  Future<double> calculateTotalRevenueLoss(DateTime startDate, DateTime endDate) async {
    double total = 0;
    for (final impact in _storage['impacts']!.values) {
      total += impact['estimatedRevenueLoss'] as double;
    }
    return total;
  }

  @override
  Future<List<String>> getMostAffectedServices(int limit) async {
    final services = <String, int>{};
    for (final impact in _storage['impacts']!.values) {
      for (final service in impact['affectedServices'] as List) {
        services[service] = (services[service] ?? 0) + 1;
      }
    }
    return services.entries.toList()
        .sort((a, b) => b.value.compareTo(a.value));
  }

  // Escalation Implementation
  @override
  Future<IncidentEscalation> escalateIncident(String incidentId, int level, String escalatedTo, String reason) async {
    final escalation = IncidentEscalation(
      escalationId: 'esc_${DateTime.now().millisecondsSinceEpoch}',
      incidentId: incidentId,
      escalationLevel: level,
      escalatedTo: escalatedTo,
      reason: reason,
      escalatedAt: DateTime.now(),
    );
    _storage['escalations']![escalation.escalationId] = _escalationToMap(escalation);
    return escalation;
  }

  @override
  Future<IncidentEscalation?> getEscalation(String escalationId) async {
    final data = _storage['escalations']![escalationId];
    return data != null ? _mapToEscalation(data) : null;
  }

  @override
  Future<List<IncidentEscalation>> getPendingEscalations() async {
    final escalations = _storage['escalations']!.values
        .where((e) => e['acknowledgedAt'] == null)
        .map(_mapToEscalation)
        .toList();
    return escalations;
  }

  @override
  Future<void> acknowledgeEscalation(String escalationId) async {
    final data = _storage['escalations']![escalationId];
    if (data != null) {
      data['acknowledgedAt'] = DateTime.now();
    }
  }

  @override
  Future<void> resolveEscalation(String escalationId) async {
    final data = _storage['escalations']![escalationId];
    if (data != null) {
      data['isResolved'] = true;
    }
  }

  @override
  Future<List<IncidentEscalation>> getEscalationsByIncident(String incidentId) async {
    final escalations = _storage['escalations']!.values
        .where((e) => e['incidentId'] == incidentId)
        .map(_mapToEscalation)
        .toList();
    return escalations;
  }

  // Communication Implementation
  @override
  Future<IncidentCommunication> sendCommunication(String incidentId, String channelType, String recipient, String message, String sentBy) async {
    final comm = IncidentCommunication(
      communicationId: 'com_${DateTime.now().millisecondsSinceEpoch}',
      incidentId: incidentId,
      channelType: channelType,
      recipient: recipient,
      message: message,
      sentAt: DateTime.now(),
      sentBy: sentBy,
    );
    _storage['communications']![comm.communicationId] = _communicationToMap(comm);
    return comm;
  }

  @override
  Future<IncidentCommunication?> getCommunication(String communicationId) async {
    final data = _storage['communications']![communicationId];
    return data != null ? _mapToCommunication(data) : null;
  }

  @override
  Future<List<IncidentCommunication>> getIncidentCommunications(String incidentId) async {
    final comms = _storage['communications']!.values
        .where((c) => c['incidentId'] == incidentId)
        .map(_mapToCommunication)
        .toList();
    return comms;
  }

  @override
  Future<void> markCommunicationAsRead(String communicationId) async {
    final data = _storage['communications']![communicationId];
    if (data != null) {
      data['isRead'] = true;
    }
  }

  @override
  Future<void> addResponseToCommunication(String communicationId, String response) async {
    final data = _storage['communications']![communicationId];
    if (data != null) {
      data['responseMessage'] = response;
    }
  }

  @override
  Future<int> getPendingCommunicationCount() async {
    return _storage['communications']!.values.where((c) => !c['isRead']).length;
  }

  // Resolution Implementation
  @override
  Future<IncidentResolution> recordResolution(String incidentId, ResolutionType type, String description, String implementedBy) async {
    final resolution = IncidentResolution(
      resolutionId: 'res_${DateTime.now().millisecondsSinceEpoch}',
      incidentId: incidentId,
      resolutionType: type,
      description: description,
      implementedAt: DateTime.now(),
      implementedBy: implementedBy,
    );
    _storage['resolutions']![resolution.resolutionId] = _resolutionToMap(resolution);
    return resolution;
  }

  @override
  Future<IncidentResolution?> getResolution(String resolutionId) async {
    final data = _storage['resolutions']![resolutionId];
    return data != null ? _mapToResolution(data) : null;
  }

  @override
  Future<IncidentResolution?> getIncidentResolution(String incidentId) async {
    final data = _storage['resolutions']!.values.firstWhere(
        (r) => r['incidentId'] == incidentId,
        orElse: () => {});
    return data.isNotEmpty ? _mapToResolution(data) : null;
  }

  @override
  Future<void> verifyResolution(String resolutionId, String verificationDetails) async {
    final data = _storage['resolutions']![resolutionId];
    if (data != null) {
      data['isVerified'] = true;
      data['verificationDetails'] = verificationDetails;
    }
  }

  @override
  Future<List<IncidentResolution>> getUnverifiedResolutions() async {
    final resolutions = _storage['resolutions']!.values
        .where((r) => !r['isVerified'])
        .map(_mapToResolution)
        .toList();
    return resolutions;
  }

  // Postmortem Implementation
  @override
  Future<IncidentPostmortem> createPostmortem(String incidentId, String title, String rootCauseAnalysis, String createdBy) async {
    final postmortem = IncidentPostmortem(
      postmortemId: 'pm_${DateTime.now().millisecondsSinceEpoch}',
      incidentId: incidentId,
      title: title,
      rootCauseAnalysis: rootCauseAnalysis,
      contributingFactors: [],
      actionItems: [],
      preventionMeasures: [],
      status: PostmortemStatus.draft,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );
    _storage['postmortems']![postmortem.postmortemId] = _postmortemToMap(postmortem);
    return postmortem;
  }

  @override
  Future<IncidentPostmortem?> getPostmortem(String postmortemId) async {
    final data = _storage['postmortems']![postmortemId];
    return data != null ? _mapToPostmortem(data) : null;
  }

  @override
  Future<void> updatePostmortem(String postmortemId, {String? analysis, List<String>? actionItems}) async {
    final data = _storage['postmortems']![postmortemId];
    if (data != null) {
      if (analysis != null) data['rootCauseAnalysis'] = analysis;
      if (actionItems != null) data['actionItems'] = actionItems;
    }
  }

  @override
  Future<void> publishPostmortem(String postmortemId) async {
    final data = _storage['postmortems']![postmortemId];
    if (data != null) {
      data['status'] = 'published';
      data['publishedAt'] = DateTime.now();
    }
  }

  @override
  Future<List<IncidentPostmortem>> getPendingPostmortems() async {
    final postmortems = _storage['postmortems']!.values
        .where((p) => p['status'] == 'pending' || p['status'] == 'draft')
        .map(_mapToPostmortem)
        .toList();
    return postmortems;
  }

  @override
  Future<List<IncidentPostmortem>> getPublishedPostmortems() async {
    final postmortems = _storage['postmortems']!.values
        .where((p) => p['status'] == 'published')
        .map(_mapToPostmortem)
        .toList();
    return postmortems;
  }

  // Notification Implementation
  @override
  Future<IncidentNotification> createNotification(String incidentId, String type, List<String> recipients, String subject, String body) async {
    final notification = IncidentNotification(
      notificationId: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      incidentId: incidentId,
      notificationType: type,
      recipients: recipients,
      subject: subject,
      body: body,
      createdAt: DateTime.now(),
    );
    _storage['notifications']![notification.notificationId] = _notificationToMap(notification);
    return notification;
  }

  @override
  Future<IncidentNotification?> getNotification(String notificationId) async {
    final data = _storage['notifications']![notificationId];
    return data != null ? _mapToNotification(data) : null;
  }

  @override
  Future<void> recordNotificationSent(String notificationId, int sentCount, int failedCount) async {
    final data = _storage['notifications']![notificationId];
    if (data != null) {
      data['sentAt'] = DateTime.now();
      data['sentCount'] = sentCount;
      data['failedCount'] = failedCount;
    }
  }

  @override
  Future<List<IncidentNotification>> getUnsentNotifications() async {
    final notifications = _storage['notifications']!.values
        .where((n) => n['sentAt'] == null)
        .map(_mapToNotification)
        .toList();
    return notifications;
  }

  @override
  Future<List<IncidentNotification>> getIncidentNotifications(String incidentId) async {
    final notifications = _storage['notifications']!.values
        .where((n) => n['incidentId'] == incidentId)
        .map(_mapToNotification)
        .toList();
    return notifications;
  }

  // Trends & Analytics Implementation
  @override
  Future<IncidentTrendAnalysis> analyzeTrends(DateTime startDate, DateTime endDate) async {
    final analysis = IncidentTrendAnalysis(
      analysisId: 'trend_${DateTime.now().millisecondsSinceEpoch}',
      analyzedAt: DateTime.now(),
      incidentsInPeriod: 10,
      averageDuration: 120.0,
      averageTimeToResolution: 95.0,
      severityDistribution: {
        IncidentSeverity.critical: 2,
        IncidentSeverity.high: 3,
        IncidentSeverity.medium: 5,
      },
      topAffectedServices: ['api', 'database'],
      mtbf: 7200.0,
      mttr: 95.0,
      mtrc: 120.0,
    );
    return analysis;
  }

  @override
  Future<IncidentReport> generateReport(DateTime startDate, DateTime endDate) async {
    final report = IncidentReport(
      reportId: 'report_${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      periodStart: startDate,
      periodEnd: endDate,
      totalIncidents: 10,
      resolvedIncidents: 9,
      unresolved: 1,
      escalatedIncidents: 3,
      severityBreakdown: {
        IncidentSeverity.critical: 2,
        IncidentSeverity.high: 3,
        IncidentSeverity.medium: 5,
      },
      averageResolutionTime: 95.0,
    );
    return report;
  }

  @override
  Future<Map<String, int>> getIncidentMetrics() async {
    return {
      'total': _storage['incidents']!.length,
      'open': _storage['incidents']!.values.where((i) => i['status'] == 'open').length,
      'critical': _storage['incidents']!.values.where((i) => i['severity'] == 'critical').length,
    };
  }

  @override
  Future<List<Incident>> getIncidentsByFilter(IncidentFilter filter) async {
    var incidents = _storage['incidents']!.values.map(_mapToIncident).toList();
    
    if (filter.severity != null) {
      incidents = incidents.where((i) => i.severity == filter.severity).toList();
    }
    if (filter.status != null) {
      incidents = incidents.where((i) => i.status == filter.status).toList();
    }
    if (filter.assignedTo != null) {
      incidents = incidents.where((i) => i.assignedTo == filter.assignedTo).toList();
    }
    
    return incidents;
  }

  // Helper methods
  Map<String, dynamic> _incidentToMap(Incident incident) => {
    'incidentId': incident.incidentId,
    'title': incident.title,
    'description': incident.description,
    'severity': incident.severity.toString().split('.').last,
    'status': incident.status.toString().split('.').last,
    'priority': incident.priority.toString().split('.').last,
    'createdAt': incident.createdAt.toIso8601String(),
    'resolvedAt': incident.resolvedAt?.toIso8601String(),
    'resolvedBy': incident.resolvedBy,
    'assignedTo': incident.assignedTo,
    'affectedServices': incident.affectedServices,
    'affectedUsers': incident.affectedUsers,
  };

  Incident _mapToIncident(Map<String, dynamic> map) => Incident(
    incidentId: map['incidentId'],
    title: map['title'],
    description: map['description'],
    severity: IncidentSeverity.values.byName(map['severity']),
    status: IncidentStatus.values.byName(map['status']),
    priority: IncidentPriority.values.byName(map['priority']),
    createdAt: DateTime.parse(map['createdAt']),
    resolvedAt: map['resolvedAt'] != null ? DateTime.parse(map['resolvedAt']) : null,
    resolvedBy: map['resolvedBy'],
    assignedTo: map['assignedTo'],
    affectedServices: List<String>.from(map['affectedServices']),
    affectedUsers: List<String>.from(map['affectedUsers']),
  );

  Map<String, dynamic> _timelineToMap(IncidentTimeline timeline) => {
    'timelineId': timeline.timelineId,
    'incidentId': timeline.incidentId,
    'timestamp': timeline.timestamp.toIso8601String(),
    'eventType': timeline.eventType,
    'description': timeline.description,
    'triggeredBy': timeline.triggeredBy,
    'metadata': timeline.metadata,
  };

  IncidentTimeline _mapToTimeline(Map<String, dynamic> map) => IncidentTimeline(
    timelineId: map['timelineId'],
    incidentId: map['incidentId'],
    timestamp: DateTime.parse(map['timestamp']),
    eventType: map['eventType'],
    description: map['description'],
    triggeredBy: map['triggeredBy'],
    metadata: map['metadata'],
  );

  Map<String, dynamic> _impactToMap(IncidentImpactAnalysis impact) => {
    'analysisId': impact.analysisId,
    'incidentId': impact.incidentId,
    'scope': impact.scope.toString().split('.').last,
    'estimatedAffectedUsers': impact.estimatedAffectedUsers,
    'affectedServices': impact.affectedServices,
    'dependentServices': impact.dependentServices,
    'estimatedRevenueLoss': impact.estimatedRevenueLoss,
    'analyzedAt': impact.analyzedAt.toIso8601String(),
  };

  IncidentImpactAnalysis _mapToImpact(Map<String, dynamic> map) => IncidentImpactAnalysis(
    analysisId: map['analysisId'],
    incidentId: map['incidentId'],
    scope: ImpactScope.values.byName(map['scope']),
    estimatedAffectedUsers: map['estimatedAffectedUsers'],
    affectedServices: List<String>.from(map['affectedServices']),
    dependentServices: List<String>.from(map['dependentServices']),
    estimatedRevenueLoss: map['estimatedRevenueLoss'],
    analyzedAt: DateTime.parse(map['analyzedAt']),
  );

  Map<String, dynamic> _escalationToMap(IncidentEscalation escalation) => {
    'escalationId': escalation.escalationId,
    'incidentId': escalation.incidentId,
    'escalationLevel': escalation.escalationLevel,
    'escalatedTo': escalation.escalatedTo,
    'reason': escalation.reason,
    'escalatedAt': escalation.escalatedAt.toIso8601String(),
    'acknowledgedAt': escalation.acknowledgedAt?.toIso8601String(),
    'isResolved': escalation.isResolved,
  };

  IncidentEscalation _mapToEscalation(Map<String, dynamic> map) => IncidentEscalation(
    escalationId: map['escalationId'],
    incidentId: map['incidentId'],
    escalationLevel: map['escalationLevel'],
    escalatedTo: map['escalatedTo'],
    reason: map['reason'],
    escalatedAt: DateTime.parse(map['escalatedAt']),
    acknowledgedAt: map['acknowledgedAt'] != null ? DateTime.parse(map['acknowledgedAt']) : null,
    isResolved: map['isResolved'] ?? false,
  );

  Map<String, dynamic> _communicationToMap(IncidentCommunication comm) => {
    'communicationId': comm.communicationId,
    'incidentId': comm.incidentId,
    'channelType': comm.channelType,
    'recipient': comm.recipient,
    'message': comm.message,
    'sentAt': comm.sentAt.toIso8601String(),
    'sentBy': comm.sentBy,
    'isRead': comm.isRead,
    'responseMessage': comm.responseMessage,
  };

  IncidentCommunication _mapToCommunication(Map<String, dynamic> map) => IncidentCommunication(
    communicationId: map['communicationId'],
    incidentId: map['incidentId'],
    channelType: map['channelType'],
    recipient: map['recipient'],
    message: map['message'],
    sentAt: DateTime.parse(map['sentAt']),
    sentBy: map['sentBy'],
    isRead: map['isRead'] ?? false,
    responseMessage: map['responseMessage'],
  );

  Map<String, dynamic> _resolutionToMap(IncidentResolution resolution) => {
    'resolutionId': resolution.resolutionId,
    'incidentId': resolution.incidentId,
    'resolutionType': resolution.resolutionType.toString().split('.').last,
    'description': resolution.description,
    'implementedAt': resolution.implementedAt.toIso8601String(),
    'implementedBy': resolution.implementedBy,
    'isVerified': resolution.isVerified,
    'verificationDetails': resolution.verificationDetails,
  };

  IncidentResolution _mapToResolution(Map<String, dynamic> map) => IncidentResolution(
    resolutionId: map['resolutionId'],
    incidentId: map['incidentId'],
    resolutionType: ResolutionType.values.byName(map['resolutionType']),
    description: map['description'],
    implementedAt: DateTime.parse(map['implementedAt']),
    implementedBy: map['implementedBy'],
    isVerified: map['isVerified'] ?? false,
    verificationDetails: map['verificationDetails'],
  );

  Map<String, dynamic> _postmortemToMap(IncidentPostmortem postmortem) => {
    'postmortemId': postmortem.postmortemId,
    'incidentId': postmortem.incidentId,
    'title': postmortem.title,
    'rootCauseAnalysis': postmortem.rootCauseAnalysis,
    'contributingFactors': postmortem.contributingFactors,
    'actionItems': postmortem.actionItems,
    'preventionMeasures': postmortem.preventionMeasures,
    'status': postmortem.status.toString().split('.').last,
    'createdAt': postmortem.createdAt.toIso8601String(),
    'publishedAt': postmortem.publishedAt?.toIso8601String(),
    'createdBy': postmortem.createdBy,
  };

  IncidentPostmortem _mapToPostmortem(Map<String, dynamic> map) => IncidentPostmortem(
    postmortemId: map['postmortemId'],
    incidentId: map['incidentId'],
    title: map['title'],
    rootCauseAnalysis: map['rootCauseAnalysis'],
    contributingFactors: List<String>.from(map['contributingFactors']),
    actionItems: List<String>.from(map['actionItems']),
    preventionMeasures: List<String>.from(map['preventionMeasures']),
    status: PostmortemStatus.values.byName(map['status']),
    createdAt: DateTime.parse(map['createdAt']),
    publishedAt: map['publishedAt'] != null ? DateTime.parse(map['publishedAt']) : null,
    createdBy: map['createdBy'],
  );

  Map<String, dynamic> _notificationToMap(IncidentNotification notification) => {
    'notificationId': notification.notificationId,
    'incidentId': notification.incidentId,
    'notificationType': notification.notificationType,
    'recipients': notification.recipients,
    'subject': notification.subject,
    'body': notification.body,
    'createdAt': notification.createdAt.toIso8601String(),
    'sentAt': notification.sentAt?.toIso8601String(),
    'sentCount': notification.sentCount,
    'failedCount': notification.failedCount,
  };

  IncidentNotification _mapToNotification(Map<String, dynamic> map) => IncidentNotification(
    notificationId: map['notificationId'],
    incidentId: map['incidentId'],
    notificationType: map['notificationType'],
    recipients: List<String>.from(map['recipients']),
    subject: map['subject'],
    body: map['body'],
    createdAt: DateTime.parse(map['createdAt']),
    sentAt: map['sentAt'] != null ? DateTime.parse(map['sentAt']) : null,
    sentCount: map['sentCount'] ?? 0,
    failedCount: map['failedCount'] ?? 0,
  );
}

// ============================================================================
// Engines (5 Specialized)
// ============================================================================

class IncidentDetectionEngine {
  Future<Incident> detectAndCreateIncident(String title, String description, IncidentSeverity severity) async {
    return Incident(
      incidentId: 'inc_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      severity: severity,
      status: IncidentStatus.open,
      priority: _severityToPriority(severity),
      createdAt: DateTime.now(),
      assignedTo: 'on-call',
      affectedServices: [],
      affectedUsers: [],
    );
  }

  IncidentPriority _severityToPriority(IncidentSeverity severity) {
    return switch (severity) {
      IncidentSeverity.critical => IncidentPriority.p0,
      IncidentSeverity.high => IncidentPriority.p1,
      IncidentSeverity.medium => IncidentPriority.p2,
      IncidentSeverity.low => IncidentPriority.p3,
      IncidentSeverity.info => IncidentPriority.p4,
    };
  }
}

class IncidentEscalationEngine {
  Future<IncidentEscalation> determineEscalation(Incident incident) async {
    final level = incident.isCritical ? 2 : 1;
    return IncidentEscalation(
      escalationId: 'esc_${DateTime.now().millisecondsSinceEpoch}',
      incidentId: incident.incidentId,
      escalationLevel: level,
      escalatedTo: 'manager',
      reason: incident.isCritical ? 'Critical incident' : 'Needs attention',
      escalatedAt: DateTime.now(),
    );
  }
}

class ImpactAnalysisEngine {
  Future<IncidentImpactAnalysis> analyzeImpact(Incident incident) async {
    return IncidentImpactAnalysis(
      analysisId: 'ana_${DateTime.now().millisecondsSinceEpoch}',
      incidentId: incident.incidentId,
      scope: _determinScope(incident),
      estimatedAffectedUsers: incident.affectedUsers.length * 100,
      affectedServices: incident.affectedServices,
      dependentServices: [],
      estimatedRevenueLoss: incident.impactScore * 1000,
      analyzedAt: DateTime.now(),
    );
  }

  ImpactScope _determinScope(Incident incident) {
    if (incident.affectedServices.length > 5) return ImpactScope.global;
    if (incident.affectedServices.length > 2) return ImpactScope.regional;
    if (incident.affectedServices.length > 1) return ImpactScope.service;
    return ImpactScope.component;
  }
}

class IncidentResolutionEngine {
  Future<IncidentResolution> recommendResolution(Incident incident) async {
    final type = _selectResolutionType(incident);
    return IncidentResolution(
      resolutionId: 'res_${DateTime.now().millisecondsSinceEpoch}',
      incidentId: incident.incidentId,
      resolutionType: type,
      description: 'Resolution for ${incident.title}',
      implementedAt: DateTime.now(),
      implementedBy: 'system',
    );
  }

  ResolutionType _selectResolutionType(Incident incident) {
    return incident.isCritical ? ResolutionType.rollback : ResolutionType.fix;
  }
}

class PostmortemGenerationEngine {
  Future<IncidentPostmortem> generatePostmortem(Incident incident, String rootCause) async {
    return IncidentPostmortem(
      postmortemId: 'pm_${DateTime.now().millisecondsSinceEpoch}',
      incidentId: incident.incidentId,
      title: 'Postmortem: ${incident.title}',
      rootCauseAnalysis: rootCause,
      contributingFactors: [],
      actionItems: [],
      preventionMeasures: [],
      status: PostmortemStatus.draft,
      createdAt: DateTime.now(),
      createdBy: 'system',
    );
  }
}

// ============================================================================
// Manager (Coordinates)
// ============================================================================

class IncidentManager {
  final IncidentRepository repository;
  final IncidentDetectionEngine detectionEngine;
  final IncidentEscalationEngine escalationEngine;
  final ImpactAnalysisEngine impactEngine;
  final IncidentResolutionEngine resolutionEngine;
  final PostmortemGenerationEngine postmortemEngine;

  IncidentManager({
    required this.repository,
    required this.detectionEngine,
    required this.escalationEngine,
    required this.impactEngine,
    required this.resolutionEngine,
    required this.postmortemEngine,
  });

  Future<Incident> createAndProcessIncident(String title, String description, IncidentSeverity severity) async {
    final incident = await repository.createIncident(title, description, severity, 'on-call');
    
    final impact = await impactEngine.analyzeImpact(incident);
    if (incident.isCritical) {
      await escalationEngine.determineEscalation(incident);
    }
    
    return incident;
  }

  Future<void> resolveIncident(String incidentId, ResolutionType resolutionType) async {
    final incident = await repository.getIncident(incidentId);
    if (incident != null) {
      await repository.updateIncident(incidentId, status: IncidentStatus.resolved);
      await repository.recordResolution(incidentId, resolutionType, 'Resolution implemented', 'system');
    }
  }
}

// ============================================================================
// Facade (Public API)
// ============================================================================

class IncidentFacade {
  final IncidentRepository repository;
  final IncidentManager manager;

  IncidentFacade({
    required this.repository,
    required this.manager,
  });

  Future<Incident> reportIncident(String title, String description, IncidentSeverity severity) =>
      manager.createAndProcessIncident(title, description, severity);

  Future<Incident?> getIncidentDetails(String incidentId) =>
      repository.getIncident(incidentId);

  Future<List<Incident>> getCriticalIncidents() =>
      repository.getCriticalIncidents();

  Future<List<Incident>> getOpenIncidents() =>
      repository.getOpenIncidents();

  Future<void> acknowledgeIncident(String incidentId, String message) async {
    await repository.updateIncident(incidentId, status: IncidentStatus.acknowledged);
    await repository.sendCommunication(incidentId, 'internal', 'team', message, 'system');
  }

  Future<void> resolveIncident(String incidentId, ResolutionType resolutionType) =>
      manager.resolveIncident(incidentId, resolutionType);

  Future<IncidentImpactAnalysis> analyzeIncidentImpact(String incidentId) =>
      repository.analyzeIncidentImpact(incidentId);

  Future<IncidentReport> generateReport(DateTime startDate, DateTime endDate) =>
      repository.generateReport(startDate, endDate);
}
