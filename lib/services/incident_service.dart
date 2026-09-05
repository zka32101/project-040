import 'package:project_040/models/incident_models.dart';

// ============================================================================
// REPOSITORY INTERFACE
// ============================================================================

abstract class IncidentRepository {
  // Incidents (12 methods)
  Future<void> createIncident(Incident incident);
  Future<Incident?> getIncident(String id);
  Future<List<Incident>> getAllIncidents();
  Future<void> updateIncident(Incident incident);
  Future<void> deleteIncident(String id);
  Future<List<Incident>> getActiveIncidents();
  Future<List<Incident>> getCriticalIncidents();
  Future<List<Incident>> getIncidentsByType(IncidentType type);
  Future<int> countIncidents();
  Future<void> deleteAllIncidents();
  Future<List<Incident>> getRecentIncidents(int daysBack);
  Future<List<Incident>> getIncidentsByStatus(IncidentStatus status);

  // Incident Timelines (10 methods)
  Future<void> createIncidentTimeline(IncidentTimeline timeline);
  Future<IncidentTimeline?> getIncidentTimeline(String id);
  Future<List<IncidentTimeline>> getAllTimelines();
  Future<void> updateIncidentTimeline(IncidentTimeline timeline);
  Future<void> deleteIncidentTimeline(String id);
  Future<List<IncidentTimeline>> getTimelinesByIncident(String incidentId);
  Future<int> countTimelines();
  Future<void> deleteAllTimelines();
  Future<List<IncidentTimeline>> getTimelinesByPhase(ResponsePhase phase);
  Future<IncidentTimeline?> getLatestTimeline(String incidentId);

  // Impact Assessments (10 methods)
  Future<void> createImpactAssessment(ImpactAssessment assessment);
  Future<ImpactAssessment?> getImpactAssessment(String id);
  Future<List<ImpactAssessment>> getAllAssessments();
  Future<void> updateImpactAssessment(ImpactAssessment assessment);
  Future<void> deleteImpactAssessment(String id);
  Future<ImpactAssessment?> getLatestAssessment(String incidentId);
  Future<List<ImpactAssessment>> getHighImpactAssessments();
  Future<int> countAssessments();
  Future<void> deleteAllAssessments();
  Future<double> getAverageAffectedUsers();

  // Response Actions (12 methods)
  Future<void> createResponseAction(ResponseAction action);
  Future<ResponseAction?> getResponseAction(String id);
  Future<List<ResponseAction>> getAllActions();
  Future<void> updateResponseAction(ResponseAction action);
  Future<void> deleteResponseAction(String id);
  Future<List<ResponseAction>> getActionsByIncident(String incidentId);
  Future<List<ResponseAction>> getCompletedActions(String incidentId);
  Future<List<ResponseAction>> getInProgressActions(String incidentId);
  Future<int> countActions();
  Future<void> deleteAllActions();
  Future<List<ResponseAction>> getActionsByAssignee(String assignee);
  Future<double> getAverageActionDuration();

  // Crisis Communications (12 methods)
  Future<void> createCrisisCommunication(CrisisCommunication communication);
  Future<CrisisCommunication?> getCrisisCommunication(String id);
  Future<List<CrisisCommunication>> getAllCommunications();
  Future<void> updateCrisisCommunication(CrisisCommunication communication);
  Future<void> deleteCrisisCommunication(String id);
  Future<List<CrisisCommunication>> getCommunicationsByIncident(String incidentId);
  Future<List<CrisisCommunication>> getPendingAcknowledgments();
  Future<List<CrisisCommunication>> getCommunicationsByChannel(CommunicationChannel channel);
  Future<int> countCommunications();
  Future<void> deleteAllCommunications();
  Future<int> getUnacknowledgedCount(String incidentId);
  Future<List<CrisisCommunication>> getRecentCommunications(String incidentId);

  // Recovery Plans (10 methods)
  Future<void> createRecoveryPlan(RecoveryPlan plan);
  Future<RecoveryPlan?> getRecoveryPlan(String id);
  Future<List<RecoveryPlan>> getAllPlans();
  Future<void> updateRecoveryPlan(RecoveryPlan plan);
  Future<void> deleteRecoveryPlan(String id);
  Future<RecoveryPlan?> getLatestPlan(String incidentId);
  Future<List<RecoveryPlan>> getActivePlans();
  Future<int> countPlans();
  Future<void> deleteAllPlans();
  Future<List<RecoveryPlan>> getPlansByStrategy(RecoveryStrategy strategy);

  // Post-Incident Reviews (10 methods)
  Future<void> createPostIncidentReview(PostIncidentReview review);
  Future<PostIncidentReview?> getPostIncidentReview(String id);
  Future<List<PostIncidentReview>> getAllReviews();
  Future<void> updatePostIncidentReview(PostIncidentReview review);
  Future<void> deletePostIncidentReview(String id);
  Future<PostIncidentReview?> getReviewByIncident(String incidentId);
  Future<List<PostIncidentReview>> getCompletedReviews();
  Future<int> countReviews();
  Future<void> deleteAllReviews();
  Future<int> getAverageLessonsPerIncident();

  // Escalation Paths (10 methods)
  Future<void> createEscalationPath(EscalationPath path);
  Future<EscalationPath?> getEscalationPath(String id);
  Future<List<EscalationPath>> getAllPaths();
  Future<void> updateEscalationPath(EscalationPath path);
  Future<void> deleteEscalationPath(String id);
  Future<EscalationPath?> getPathByIncident(String incidentId);
  Future<List<EscalationPath>> getEscalatedIncidents();
  Future<int> countPaths();
  Future<void> deleteAllPaths();
  Future<double> getAverageEscalationTime();

  // Resource Allocations (10 methods)
  Future<void> createResourceAllocation(ResourceAllocation allocation);
  Future<ResourceAllocation?> getResourceAllocation(String id);
  Future<List<ResourceAllocation>> getAllAllocations();
  Future<void> updateResourceAllocation(ResourceAllocation allocation);
  Future<void> deleteResourceAllocation(String id);
  Future<List<ResourceAllocation>> getAllocationsByIncident(String incidentId);
  Future<List<ResourceAllocation>> getActiveAllocations();
  Future<int> countAllocations();
  Future<void> deleteAllAllocations();
  Future<int> getTotalResourcesAllocated();

  // Incident Metrics (8 methods)
  Future<void> createIncidentMetrics(IncidentMetrics metrics);
  Future<IncidentMetrics?> getIncidentMetrics(String id);
  Future<List<IncidentMetrics>> getAllMetrics();
  Future<void> updateIncidentMetrics(IncidentMetrics metrics);
  Future<void> deleteIncidentMetrics(String id);
  Future<IncidentMetrics?> getMetricsByIncident(String incidentId);
  Future<int> countMetrics();
  Future<void> deleteAllMetrics();
}

// ============================================================================
// IN-MEMORY REPOSITORY IMPLEMENTATION
// ============================================================================

class InMemoryIncidentRepository implements IncidentRepository {
  final Map<String, Incident> _incidents = {};
  final Map<String, IncidentTimeline> _timelines = {};
  final Map<String, ImpactAssessment> _assessments = {};
  final Map<String, ResponseAction> _actions = {};
  final Map<String, CrisisCommunication> _communications = {};
  final Map<String, RecoveryPlan> _plans = {};
  final Map<String, PostIncidentReview> _reviews = {};
  final Map<String, EscalationPath> _escalations = {};
  final Map<String, ResourceAllocation> _resources = {};
  final Map<String, IncidentMetrics> _metrics = {};

  // Incidents Implementation
  @override
  Future<void> createIncident(Incident incident) async {
    _incidents[incident.id] = incident;
  }

  @override
  Future<Incident?> getIncident(String id) async {
    return _incidents[id];
  }

  @override
  Future<List<Incident>> getAllIncidents() async {
    return _incidents.values.toList();
  }

  @override
  Future<void> updateIncident(Incident incident) async {
    _incidents[incident.id] = incident;
  }

  @override
  Future<void> deleteIncident(String id) async {
    _incidents.remove(id);
  }

  @override
  Future<List<Incident>> getActiveIncidents() async {
    return _incidents.values.where((i) => i.isActive).toList();
  }

  @override
  Future<List<Incident>> getCriticalIncidents() async {
    return _incidents.values.where((i) => i.isCritical).toList();
  }

  @override
  Future<List<Incident>> getIncidentsByType(IncidentType type) async {
    return _incidents.values.where((i) => i.type == type).toList();
  }

  @override
  Future<int> countIncidents() async {
    return _incidents.length;
  }

  @override
  Future<void> deleteAllIncidents() async {
    _incidents.clear();
  }

  @override
  Future<List<Incident>> getRecentIncidents(int daysBack) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysBack));
    return _incidents.values.where((i) => i.reportedAt.isAfter(cutoff)).toList();
  }

  @override
  Future<List<Incident>> getIncidentsByStatus(IncidentStatus status) async {
    return _incidents.values.where((i) => i.status == status).toList();
  }

  // Incident Timelines Implementation
  @override
  Future<void> createIncidentTimeline(IncidentTimeline timeline) async {
    _timelines[timeline.id] = timeline;
  }

  @override
  Future<IncidentTimeline?> getIncidentTimeline(String id) async {
    return _timelines[id];
  }

  @override
  Future<List<IncidentTimeline>> getAllTimelines() async {
    return _timelines.values.toList();
  }

  @override
  Future<void> updateIncidentTimeline(IncidentTimeline timeline) async {
    _timelines[timeline.id] = timeline;
  }

  @override
  Future<void> deleteIncidentTimeline(String id) async {
    _timelines.remove(id);
  }

  @override
  Future<List<IncidentTimeline>> getTimelinesByIncident(String incidentId) async {
    return _timelines.values.where((t) => t.incidentId == incidentId).toList();
  }

  @override
  Future<int> countTimelines() async {
    return _timelines.length;
  }

  @override
  Future<void> deleteAllTimelines() async {
    _timelines.clear();
  }

  @override
  Future<List<IncidentTimeline>> getTimelinesByPhase(ResponsePhase phase) async {
    return _timelines.values.where((t) => t.phase == phase).toList();
  }

  @override
  Future<IncidentTimeline?> getLatestTimeline(String incidentId) async {
    final timelines = _timelines.values.where((t) => t.incidentId == incidentId).toList();
    if (timelines.isEmpty) return null;
    timelines.sort((a, b) => b.eventTime.compareTo(a.eventTime));
    return timelines.first;
  }

  // Impact Assessments Implementation
  @override
  Future<void> createImpactAssessment(ImpactAssessment assessment) async {
    _assessments[assessment.id] = assessment;
  }

  @override
  Future<ImpactAssessment?> getImpactAssessment(String id) async {
    return _assessments[id];
  }

  @override
  Future<List<ImpactAssessment>> getAllAssessments() async {
    return _assessments.values.toList();
  }

  @override
  Future<void> updateImpactAssessment(ImpactAssessment assessment) async {
    _assessments[assessment.id] = assessment;
  }

  @override
  Future<void> deleteImpactAssessment(String id) async {
    _assessments.remove(id);
  }

  @override
  Future<ImpactAssessment?> getLatestAssessment(String incidentId) async {
    final assessments = _assessments.values.toList();
    if (assessments.isEmpty) return null;
    assessments.sort((a, b) => b.assessmentTime.compareTo(a.assessmentTime));
    return assessments.first;
  }

  @override
  Future<List<ImpactAssessment>> getHighImpactAssessments() async {
    return _assessments.values.where((a) => a.isHighImpact).toList();
  }

  @override
  Future<int> countAssessments() async {
    return _assessments.length;
  }

  @override
  Future<void> deleteAllAssessments() async {
    _assessments.clear();
  }

  @override
  Future<double> getAverageAffectedUsers() async {
    if (_assessments.isEmpty) return 0.0;
    final sum = _assessments.values.fold<int>(0, (acc, a) => acc + a.usersAffected);
    return sum / _assessments.length;
  }

  // Response Actions Implementation
  @override
  Future<void> createResponseAction(ResponseAction action) async {
    _actions[action.id] = action;
  }

  @override
  Future<ResponseAction?> getResponseAction(String id) async {
    return _actions[id];
  }

  @override
  Future<List<ResponseAction>> getAllActions() async {
    return _actions.values.toList();
  }

  @override
  Future<void> updateResponseAction(ResponseAction action) async {
    _actions[action.id] = action;
  }

  @override
  Future<void> deleteResponseAction(String id) async {
    _actions.remove(id);
  }

  @override
  Future<List<ResponseAction>> getActionsByIncident(String incidentId) async {
    return _actions.values.where((a) => a.incidentId == incidentId).toList();
  }

  @override
  Future<List<ResponseAction>> getCompletedActions(String incidentId) async {
    return _actions.values.where((a) => a.incidentId == incidentId && a.isCompleted).toList();
  }

  @override
  Future<List<ResponseAction>> getInProgressActions(String incidentId) async {
    return _actions.values.where((a) => a.incidentId == incidentId && !a.isCompleted).toList();
  }

  @override
  Future<int> countActions() async {
    return _actions.length;
  }

  @override
  Future<void> deleteAllActions() async {
    _actions.clear();
  }

  @override
  Future<List<ResponseAction>> getActionsByAssignee(String assignee) async {
    return _actions.values.where((a) => a.assignedTo == assignee).toList();
  }

  @override
  Future<double> getAverageActionDuration() async {
    if (_actions.isEmpty) return 0.0;
    final sum = _actions.values.fold<int>(0, (acc, a) => acc + a.durationMinutes);
    return sum / _actions.length;
  }

  // Crisis Communications Implementation
  @override
  Future<void> createCrisisCommunication(CrisisCommunication communication) async {
    _communications[communication.id] = communication;
  }

  @override
  Future<CrisisCommunication?> getCrisisCommunication(String id) async {
    return _communications[id];
  }

  @override
  Future<List<CrisisCommunication>> getAllCommunications() async {
    return _communications.values.toList();
  }

  @override
  Future<void> updateCrisisCommunication(CrisisCommunication communication) async {
    _communications[communication.id] = communication;
  }

  @override
  Future<void> deleteCrisisCommunication(String id) async {
    _communications.remove(id);
  }

  @override
  Future<List<CrisisCommunication>> getCommunicationsByIncident(String incidentId) async {
    return _communications.values.where((c) => c.incidentId == incidentId).toList();
  }

  @override
  Future<List<CrisisCommunication>> getPendingAcknowledgments() async {
    return _communications.values.where((c) => c.isPending).toList();
  }

  @override
  Future<List<CrisisCommunication>> getCommunicationsByChannel(CommunicationChannel channel) async {
    return _communications.values.where((c) => c.channel == channel).toList();
  }

  @override
  Future<int> countCommunications() async {
    return _communications.length;
  }

  @override
  Future<void> deleteAllCommunications() async {
    _communications.clear();
  }

  @override
  Future<int> getUnacknowledgedCount(String incidentId) async {
    return _communications.values.where((c) => c.incidentId == incidentId && c.isPending).length;
  }

  @override
  Future<List<CrisisCommunication>> getRecentCommunications(String incidentId) async {
    return _communications.values.where((c) => c.incidentId == incidentId).toList();
  }

  // Recovery Plans Implementation
  @override
  Future<void> createRecoveryPlan(RecoveryPlan plan) async {
    _plans[plan.id] = plan;
  }

  @override
  Future<RecoveryPlan?> getRecoveryPlan(String id) async {
    return _plans[id];
  }

  @override
  Future<List<RecoveryPlan>> getAllPlans() async {
    return _plans.values.toList();
  }

  @override
  Future<void> updateRecoveryPlan(RecoveryPlan plan) async {
    _plans[plan.id] = plan;
  }

  @override
  Future<void> deleteRecoveryPlan(String id) async {
    _plans.remove(id);
  }

  @override
  Future<RecoveryPlan?> getLatestPlan(String incidentId) async {
    final plans = _plans.values.toList();
    if (plans.isEmpty) return null;
    plans.sort((a, b) => b.plannedStartTime.compareTo(a.plannedStartTime));
    return plans.first;
  }

  @override
  Future<List<RecoveryPlan>> getActivePlans() async {
    return _plans.values.where((p) => p.isDue).toList();
  }

  @override
  Future<int> countPlans() async {
    return _plans.length;
  }

  @override
  Future<void> deleteAllPlans() async {
    _plans.clear();
  }

  @override
  Future<List<RecoveryPlan>> getPlansByStrategy(RecoveryStrategy strategy) async {
    return _plans.values.where((p) => p.strategy == strategy).toList();
  }

  // Post-Incident Reviews Implementation
  @override
  Future<void> createPostIncidentReview(PostIncidentReview review) async {
    _reviews[review.id] = review;
  }

  @override
  Future<PostIncidentReview?> getPostIncidentReview(String id) async {
    return _reviews[id];
  }

  @override
  Future<List<PostIncidentReview>> getAllReviews() async {
    return _reviews.values.toList();
  }

  @override
  Future<void> updatePostIncidentReview(PostIncidentReview review) async {
    _reviews[review.id] = review;
  }

  @override
  Future<void> deletePostIncidentReview(String id) async {
    _reviews.remove(id);
  }

  @override
  Future<PostIncidentReview?> getReviewByIncident(String incidentId) async {
    return _reviews.values.cast<PostIncidentReview?>().firstWhere(
          (r) => r?.incidentId == incidentId,
          orElse: () => null,
        );
  }

  @override
  Future<List<PostIncidentReview>> getCompletedReviews() async {
    return _reviews.values.where((r) => r.completed).toList();
  }

  @override
  Future<int> countReviews() async {
    return _reviews.length;
  }

  @override
  Future<void> deleteAllReviews() async {
    _reviews.clear();
  }

  @override
  Future<int> getAverageLessonsPerIncident() async {
    if (_reviews.isEmpty) return 0;
    final sum = _reviews.values.fold<int>(0, (acc, r) => acc + r.lessons.length);
    return sum ~/ _reviews.length;
  }

  // Escalation Paths Implementation
  @override
  Future<void> createEscalationPath(EscalationPath path) async {
    _escalations[path.id] = path;
  }

  @override
  Future<EscalationPath?> getEscalationPath(String id) async {
    return _escalations[id];
  }

  @override
  Future<List<EscalationPath>> getAllPaths() async {
    return _escalations.values.toList();
  }

  @override
  Future<void> updateEscalationPath(EscalationPath path) async {
    _escalations[path.id] = path;
  }

  @override
  Future<void> deleteEscalationPath(String id) async {
    _escalations.remove(id);
  }

  @override
  Future<EscalationPath?> getPathByIncident(String incidentId) async {
    return _escalations.values.cast<EscalationPath?>().firstWhere(
          (p) => p?.incidentId == incidentId,
          orElse: () => null,
        );
  }

  @override
  Future<List<EscalationPath>> getEscalatedIncidents() async {
    return _escalations.values.toList();
  }

  @override
  Future<int> countPaths() async {
    return _escalations.length;
  }

  @override
  Future<void> deleteAllPaths() async {
    _escalations.clear();
  }

  @override
  Future<double> getAverageEscalationTime() async {
    if (_escalations.isEmpty) return 0.0;
    final sum = _escalations.values.fold<int>(0, (acc, p) => acc + p.minutesElapsedSinceEscalation);
    return sum / _escalations.length;
  }

  // Resource Allocations Implementation
  @override
  Future<void> createResourceAllocation(ResourceAllocation allocation) async {
    _resources[allocation.id] = allocation;
  }

  @override
  Future<ResourceAllocation?> getResourceAllocation(String id) async {
    return _resources[id];
  }

  @override
  Future<List<ResourceAllocation>> getAllAllocations() async {
    return _resources.values.toList();
  }

  @override
  Future<void> updateResourceAllocation(ResourceAllocation allocation) async {
    _resources[allocation.id] = allocation;
  }

  @override
  Future<void> deleteResourceAllocation(String id) async {
    _resources.remove(id);
  }

  @override
  Future<List<ResourceAllocation>> getAllocationsByIncident(String incidentId) async {
    return _resources.values.where((r) => r.incidentId == incidentId).toList();
  }

  @override
  Future<List<ResourceAllocation>> getActiveAllocations() async {
    return _resources.values.where((r) => r.isActive).toList();
  }

  @override
  Future<int> countAllocations() async {
    return _resources.length;
  }

  @override
  Future<void> deleteAllAllocations() async {
    _resources.clear();
  }

  @override
  Future<int> getTotalResourcesAllocated() async {
    return _resources.values.fold<int>(0, (acc, r) => acc + r.quantityAllocated);
  }

  // Incident Metrics Implementation
  @override
  Future<void> createIncidentMetrics(IncidentMetrics metrics) async {
    _metrics[metrics.id] = metrics;
  }

  @override
  Future<IncidentMetrics?> getIncidentMetrics(String id) async {
    return _metrics[id];
  }

  @override
  Future<List<IncidentMetrics>> getAllMetrics() async {
    return _metrics.values.toList();
  }

  @override
  Future<void> updateIncidentMetrics(IncidentMetrics metrics) async {
    _metrics[metrics.id] = metrics;
  }

  @override
  Future<void> deleteIncidentMetrics(String id) async {
    _metrics.remove(id);
  }

  @override
  Future<IncidentMetrics?> getMetricsByIncident(String incidentId) async {
    return _metrics.values.cast<IncidentMetrics?>().firstWhere(
          (m) => m?.incidentId == incidentId,
          orElse: () => null,
        );
  }

  @override
  Future<int> countMetrics() async {
    return _metrics.length;
  }

  @override
  Future<void> deleteAllMetrics() async {
    _metrics.clear();
  }
}

// ============================================================================
// ENGINES
// ============================================================================

class IncidentDetectionEngine {
  Future<bool> isIncidentCritical(Incident incident) async {
    return incident.isCritical;
  }

  Future<ResponsePhase> suggestCurrentPhase(IncidentStatus status) async {
    switch (status) {
      case IncidentStatus.reported:
      case IncidentStatus.investigating:
        return ResponsePhase.detection;
      case IncidentStatus.contained:
        return ResponsePhase.containment;
      case IncidentStatus.mitigating:
        return ResponsePhase.eradication;
      case IncidentStatus.resolved:
        return ResponsePhase.recovery;
      case IncidentStatus.closed:
        return ResponsePhase.postIncident;
    }
  }
}

class CrisisCoordinationEngine {
  Future<List<String>> generateEscalationList(IncidentSeverity severity) async {
    return severity == IncidentSeverity.catastrophic
        ? ['CTO', 'CEO', 'Board']
        : severity == IncidentSeverity.critical
            ? ['VP Engineering', 'CTO']
            : ['Team Lead', 'Manager'];
  }

  Future<String> suggestCommunicationStrategy(IncidentSeverity severity) async {
    if (severity == IncidentSeverity.catastrophic) {
      return 'Immediate all-hands communication across all channels';
    } else if (severity == IncidentSeverity.critical) {
      return 'Stakeholder notification via email and Slack';
    }
    return 'Team notification via standard channels';
  }
}

class RecoveryCoordinationEngine {
  Future<RecoveryStrategy> recommendStrategy(IncidentType type, double dataLossPercent) async {
    if (dataLossPercent > 10.0) {
      return RecoveryStrategy.reconstruction;
    }
    if (type == IncidentType.infrastructure) {
      return RecoveryStrategy.failover;
    }
    return RecoveryStrategy.restoration;
  }

  Future<List<String>> generateRecoverySteps(RecoveryStrategy strategy) async {
    return [
      'Validate recovery environment',
      'Execute recovery procedure',
      'Verify data integrity',
      'Resume operations',
      'Monitor system health',
    ];
  }
}

class ImpactCalculationEngine {
  Future<double> calculateTotalImpact(ImpactAssessment assessment) async {
    return assessment.financialImpactDollars + (assessment.usersAffected * 10.0);
  }

  Future<String> assessSeverity(ImpactAssessment assessment) async {
    if (assessment.isHighImpact) {
      return 'Severe - Immediate action required';
    }
    return 'Moderate - Coordinate response';
  }
}

class PostIncidentLearningEngine {
  Future<List<String>> extractLessons(PostIncidentReview review) async {
    return review.lessons;
  }

  Future<Map<String, int>> analyzeContributingFactors(PostIncidentReview review) async {
    final factors = <String, int>{};
    for (var factor in review.contributingFactors) {
      factors[factor] = (factors[factor] ?? 0) + 1;
    }
    return factors;
  }
}

// ============================================================================
// MANAGER
// ============================================================================

class IncidentManager {
  final IncidentRepository repository;
  final IncidentDetectionEngine detectionEngine = IncidentDetectionEngine();
  final CrisisCoordinationEngine coordinationEngine = CrisisCoordinationEngine();
  final RecoveryCoordinationEngine recoveryEngine = RecoveryCoordinationEngine();
  final ImpactCalculationEngine impactEngine = ImpactCalculationEngine();
  final PostIncidentLearningEngine learningEngine = PostIncidentLearningEngine();

  IncidentManager(this.repository);

  Future<bool> assessIncidentCriticality(String incidentId) async {
    final incident = await repository.getIncident(incidentId);
    if (incident == null) return false;
    return detectionEngine.isIncidentCritical(incident);
  }

  Future<List<Incident>> getActiveIncidents() async {
    return repository.getActiveIncidents();
  }

  Future<int> getCriticalIncidentCount() async {
    final criticals = await repository.getCriticalIncidents();
    return criticals.length;
  }
}

// ============================================================================
// FACADE
// ============================================================================

class IncidentFacade {
  final IncidentManager manager;

  IncidentFacade(this.manager);

  Future<Incident> reportIncident(
    String title,
    String description,
    IncidentType type,
    IncidentSeverity severity,
    String reportedBy,
  ) async {
    final incident = Incident(
      id: 'inc_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      type: type,
      severity: severity,
      reportedAt: DateTime.now(),
      reportedBy: reportedBy,
      status: IncidentStatus.reported,
      affectedSystems: [],
    );
    await manager.repository.createIncident(incident);
    return incident;
  }

  Future<void> updateIncidentStatus(String incidentId, IncidentStatus newStatus) async {
    final incident = await manager.repository.getIncident(incidentId);
    if (incident != null) {
      await manager.repository.updateIncident(incident.copyWith(status: newStatus));
    }
  }

  Future<ImpactAssessment> assessImpact(
    String incidentId,
    int usersAffected,
    int systemsAffected,
    double dataLossPercent,
  ) async {
    final assessment = ImpactAssessment(
      id: 'imp_${DateTime.now().millisecondsSinceEpoch}',
      incidentId: incidentId,
      usersAffected: usersAffected,
      systemsAffected: systemsAffected,
      estimatedDataLossPercent: dataLossPercent,
      estimatedRecoveryTime: Duration(hours: 4),
      financialImpactDollars: usersAffected * 100.0,
      assessmentTime: DateTime.now(),
      assessedBy: 'Assessment Team',
    );
    await manager.repository.createImpactAssessment(assessment);
    return assessment;
  }

  Future<ResponseAction> createResponseAction(
    String incidentId,
    String title,
    String description,
    String assignedTo,
  ) async {
    final action = ResponseAction(
      id: 'act_${DateTime.now().millisecondsSinceEpoch}',
      incidentId: incidentId,
      title: title,
      description: description,
      initiatedAt: DateTime.now(),
      assignedTo: assignedTo,
      progressPercent: 0.0,
      outcomes: [],
    );
    await manager.repository.createResponseAction(action);
    return action;
  }

  Future<void> sendCrisisCommunication(
    String incidentId,
    CommunicationChannel channel,
    String recipient,
    String message,
  ) async {
    final communication = CrisisCommunication(
      id: 'com_${DateTime.now().millisecondsSinceEpoch}',
      incidentId: incidentId,
      channel: channel,
      recipient: recipient,
      message: message,
      sentAt: DateTime.now(),
      acknowledged: false,
      sentBy: 'Communication Team',
    );
    await manager.repository.createCrisisCommunication(communication);
  }

  Future<RecoveryPlan> createRecoveryPlan(
    String incidentId,
    RecoveryStrategy strategy,
    String description,
  ) async {
    final plan = RecoveryPlan(
      id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
      incidentId: incidentId,
      strategy: strategy,
      description: description,
      plannedStartTime: DateTime.now().add(Duration(minutes: 30)),
      estimatedDuration: Duration(hours: 2),
      steps: ['Step 1', 'Step 2', 'Step 3'],
      dependencies: [],
      owner: 'Recovery Lead',
    );
    await manager.repository.createRecoveryPlan(plan);
    return plan;
  }

  Future<PostIncidentReview> createPostIncidentReview(
    String incidentId,
    String rootCause,
    List<String> lessons,
  ) async {
    final review = PostIncidentReview(
      id: 'pir_${DateTime.now().millisecondsSinceEpoch}',
      incidentId: incidentId,
      reviewDate: DateTime.now(),
      reviewedBy: 'Review Team',
      rootCause: rootCause,
      contributingFactors: [],
      lessons: lessons,
      actionItems: [],
      completed: false,
    );
    await manager.repository.createPostIncidentReview(review);
    return review;
  }

  Future<Map<String, dynamic>> getIncidentDashboard() async {
    final active = await manager.repository.getActiveIncidents();
    final critical = await manager.repository.getCriticalIncidents();
    final allIncidents = await manager.repository.getAllIncidents();
    final communications = await manager.repository.getPendingAcknowledgments();

    return {
      'totalIncidents': allIncidents.length,
      'activeIncidents': active.length,
      'criticalIncidents': critical.length,
      'pendingCommunications': communications.length,
      'resolvedIncidents': allIncidents.where((i) => i.status == IncidentStatus.resolved).length,
      'avgResponseTime': 0,
    };
  }

  Future<List<Incident>> getRecentIncidents(int days) async {
    return manager.repository.getRecentIncidents(days);
  }

  Future<bool> isCriticalIncident(String incidentId) async {
    return manager.assessIncidentCriticality(incidentId);
  }
}
