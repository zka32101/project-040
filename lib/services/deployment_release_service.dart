/// Deployment & Release Management Service

import 'package:project_040/models/deployment_models.dart';

// ============================================================================
// Repository Interface (48 Methods)
// ============================================================================

abstract class DeploymentRepository {
  // Release Management (10 methods)
  Future<Release> createRelease(String version, ReleaseType type, String description, String createdBy);
  Future<Release?> getRelease(String releaseId);
  Future<Release> updateRelease(String releaseId, {String? description, String? releaseNotes, bool? isStable});
  Future<void> deleteRelease(String releaseId);
  Future<List<Release>> listReleases({int limit = 50});
  Future<List<Release>> getReleasesByType(ReleaseType type);
  Future<void> publishRelease(String releaseId);
  Future<List<Release>> getLatestReleases(int count);
  Future<Release?> getReleaseByVersion(String version);
  Future<int> getReleaseCount();

  // Deployment Management (10 methods)
  Future<Deployment> createDeployment(String releaseId, EnvironmentType environment, DeploymentStrategy strategy, String initiatedBy);
  Future<Deployment?> getDeployment(String deploymentId);
  Future<Deployment> updateDeploymentStatus(String deploymentId, DeploymentStatus status);
  Future<void> deleteDeployment(String deploymentId);
  Future<List<Deployment>> listDeployments({int limit = 50});
  Future<List<Deployment>> getActiveDeployments();
  Future<List<Deployment>> getDeploymentsByEnvironment(EnvironmentType environment);
  Future<List<Deployment>> getDeploymentsByStrategy(DeploymentStrategy strategy);
  Future<List<Deployment>> getFailedDeployments();
  Future<int> getDeploymentCount();

  // Rollout Plan (7 methods)
  Future<RolloutPlan> createRolloutPlan(String deploymentId, List<String> stages, Map<String, int> stageDuration, String createdBy);
  Future<RolloutPlan?> getRolloutPlan(String planId);
  Future<void> updateRolloutPlan(String planId, {List<String>? stages, Map<String, int>? stageDuration});
  Future<void> deleteRolloutPlan(String planId);
  Future<List<RolloutPlan>> getRolloutPlansByDeployment(String deploymentId);
  Future<List<RolloutPlan>> getAutomatedPlans();
  Future<int> getPlanCount();

  // Canary Deployment (8 methods)
  Future<CanaryDeployment> createCanaryDeployment(String deploymentId, double trafficPercentage, int targetReplicas);
  Future<CanaryDeployment?> getCanaryDeployment(String canaryId);
  Future<CanaryDeployment> updateCanaryStatus(String canaryId, int currentReplicas, bool isSuccessful);
  Future<void> deleteCanaryDeployment(String canaryId);
  Future<List<CanaryDeployment>> getActiveCanaryDeployments();
  Future<List<CanaryDeployment>> getCanaryByDeployment(String deploymentId);
  Future<List<CanaryDeployment>> getSuccessfulCanaries();
  Future<List<CanaryDeployment>> getFailedCanaries();

  // Approval Management (7 methods)
  Future<DeploymentApproval> createApprovalRequest(String deploymentId, EnvironmentType environment, String requestedBy, List<String> approvers);
  Future<DeploymentApproval?> getApproval(String approvalId);
  Future<DeploymentApproval> approveDeployment(String approvalId, String approvedBy, String? comments);
  Future<DeploymentApproval> rejectDeployment(String approvalId, String rejectReason);
  Future<List<DeploymentApproval>> getPendingApprovals();
  Future<List<DeploymentApproval>> getApprovalsByDeployment(String deploymentId);
  Future<List<DeploymentApproval>> getApprovalsByEnvironment(EnvironmentType environment);

  // Release Validation (6 methods)
  Future<ReleaseValidation> validateRelease(String releaseId, String testType, int totalTests, int passedTests);
  Future<ReleaseValidation?> getValidation(String validationId);
  Future<List<ReleaseValidation>> getValidationsByRelease(String releaseId);
  Future<List<ReleaseValidation>> getFailedValidations();
  Future<double> getValidationSuccessRate(String releaseId);
  Future<List<ReleaseValidation>> getLatestValidations(int count);

  // Rollback Management (5 methods)
  Future<DeploymentRollback> initiateRollback(String deploymentId, String targetVersion, String reason, String initiatedBy);
  Future<DeploymentRollback?> getRollback(String rollbackId);
  Future<DeploymentRollback> completeRollback(String rollbackId, String details);
  Future<List<DeploymentRollback>> getPendingRollbacks();
  Future<List<DeploymentRollback>> getRollbacksByDeployment(String deploymentId);

  // Release Notes (5 methods)
  Future<ReleaseNotes> createReleaseNotes(String releaseId, String content, List<String> features, List<String> bugFixes);
  Future<ReleaseNotes?> getReleaseNotes(String notesId);
  Future<void> updateReleaseNotes(String notesId, {String? content, List<String>? features});
  Future<void> publishReleaseNotes(String notesId);
  Future<ReleaseNotes?> getNotesByRelease(String releaseId);

  // Metrics & Analytics (4 methods)
  Future<DeploymentMetrics> recordDeploymentMetrics(String deploymentId, double duration, int successCount, int failureCount);
  Future<DeploymentMetrics?> getMetrics(String metricsId);
  Future<DeploymentReport> generateReport(DateTime startDate, DateTime endDate);
  Future<List<Deployment>> getDeploymentsByFilter(DeploymentFilter filter);
}

// ============================================================================
// In-Memory Repository Implementation
// ============================================================================

class DeploymentRepositoryImpl implements DeploymentRepository {
  final Map<String, Map<String, dynamic>> _storage = {};

  DeploymentRepositoryImpl() {
    _storage['releases'] = {};
    _storage['deployments'] = {};
    _storage['rolloutPlans'] = {};
    _storage['canaries'] = {};
    _storage['approvals'] = {};
    _storage['validations'] = {};
    _storage['rollbacks'] = {};
    _storage['releaseNotes'] = {};
    _storage['metrics'] = {};
  }

  // Release Implementation
  @override
  Future<Release> createRelease(String version, ReleaseType type, String description, String createdBy) async {
    final release = Release(
      releaseId: 'rel_${DateTime.now().millisecondsSinceEpoch}',
      version: version,
      releaseType: type,
      description: description,
      createdAt: DateTime.now(),
      createdBy: createdBy,
      changeIds: [],
    );
    _storage['releases']![release.releaseId] = _releaseToMap(release);
    return release;
  }

  @override
  Future<Release?> getRelease(String releaseId) async {
    final data = _storage['releases']![releaseId];
    return data != null ? _mapToRelease(data) : null;
  }

  @override
  Future<Release> updateRelease(String releaseId, {String? description, String? releaseNotes, bool? isStable}) async {
    final data = _storage['releases']![releaseId];
    if (data == null) throw Exception('Release not found');
    if (description != null) data['description'] = description;
    if (releaseNotes != null) data['releaseNotes'] = releaseNotes;
    if (isStable != null) data['isStable'] = isStable;
    return _mapToRelease(data);
  }

  @override
  Future<void> deleteRelease(String releaseId) async {
    _storage['releases']!.remove(releaseId);
  }

  @override
  Future<List<Release>> listReleases({int limit = 50}) async {
    return _storage['releases']!.values.map(_mapToRelease).toList().take(limit).toList();
  }

  @override
  Future<List<Release>> getReleasesByType(ReleaseType type) async {
    return _storage['releases']!.values
        .where((r) => r['releaseType'] == type.toString().split('.').last)
        .map(_mapToRelease)
        .toList();
  }

  @override
  Future<void> publishRelease(String releaseId) async {
    final data = _storage['releases']![releaseId];
    if (data != null) {
      data['publishedAt'] = DateTime.now().toIso8601String();
    }
  }

  @override
  Future<List<Release>> getLatestReleases(int count) async {
    return _storage['releases']!.values.map(_mapToRelease).toList().take(count).toList();
  }

  @override
  Future<Release?> getReleaseByVersion(String version) async {
    final data = _storage['releases']!.values.firstWhere(
        (r) => r['version'] == version,
        orElse: () => {});
    return data.isNotEmpty ? _mapToRelease(data) : null;
  }

  @override
  Future<int> getReleaseCount() async {
    return _storage['releases']!.length;
  }

  // Deployment Implementation
  @override
  Future<Deployment> createDeployment(String releaseId, EnvironmentType environment, DeploymentStrategy strategy, String initiatedBy) async {
    final deployment = Deployment(
      deploymentId: 'dep_${DateTime.now().millisecondsSinceEpoch}',
      releaseId: releaseId,
      environment: environment,
      strategy: strategy,
      status: DeploymentStatus.planned,
      startTime: DateTime.now(),
      initiatedBy: initiatedBy,
      affectedServices: [],
    );
    _storage['deployments']![deployment.deploymentId] = _deploymentToMap(deployment);
    return deployment;
  }

  @override
  Future<Deployment?> getDeployment(String deploymentId) async {
    final data = _storage['deployments']![deploymentId];
    return data != null ? _mapToDeployment(data) : null;
  }

  @override
  Future<Deployment> updateDeploymentStatus(String deploymentId, DeploymentStatus status) async {
    final data = _storage['deployments']![deploymentId];
    if (data == null) throw Exception('Deployment not found');
    data['status'] = status.toString().split('.').last;
    if (status == DeploymentStatus.completed || status == DeploymentStatus.failed) {
      data['endTime'] = DateTime.now().toIso8601String();
    }
    return _mapToDeployment(data);
  }

  @override
  Future<void> deleteDeployment(String deploymentId) async {
    _storage['deployments']!.remove(deploymentId);
  }

  @override
  Future<List<Deployment>> listDeployments({int limit = 50}) async {
    return _storage['deployments']!.values.map(_mapToDeployment).toList().take(limit).toList();
  }

  @override
  Future<List<Deployment>> getActiveDeployments() async {
    return _storage['deployments']!.values
        .where((d) => d['status'] == 'inProgress' || d['status'] == 'preparing')
        .map(_mapToDeployment)
        .toList();
  }

  @override
  Future<List<Deployment>> getDeploymentsByEnvironment(EnvironmentType environment) async {
    return _storage['deployments']!.values
        .where((d) => d['environment'] == environment.toString().split('.').last)
        .map(_mapToDeployment)
        .toList();
  }

  @override
  Future<List<Deployment>> getDeploymentsByStrategy(DeploymentStrategy strategy) async {
    return _storage['deployments']!.values
        .where((d) => d['strategy'] == strategy.toString().split('.').last)
        .map(_mapToDeployment)
        .toList();
  }

  @override
  Future<List<Deployment>> getFailedDeployments() async {
    return _storage['deployments']!.values
        .where((d) => d['status'] == 'failed')
        .map(_mapToDeployment)
        .toList();
  }

  @override
  Future<int> getDeploymentCount() async {
    return _storage['deployments']!.length;
  }

  // Rollout Plan Implementation
  @override
  Future<RolloutPlan> createRolloutPlan(String deploymentId, List<String> stages, Map<String, int> stageDuration, String createdBy) async {
    final plan = RolloutPlan(
      planId: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      deploymentId: deploymentId,
      stages: stages,
      stageDuration: stageDuration,
      createdAt: DateTime.now(),
      createdBy: createdBy,
      configuration: {},
    );
    _storage['rolloutPlans']![plan.planId] = _planToMap(plan);
    return plan;
  }

  @override
  Future<RolloutPlan?> getRolloutPlan(String planId) async {
    final data = _storage['rolloutPlans']![planId];
    return data != null ? _mapToPlan(data) : null;
  }

  @override
  Future<void> updateRolloutPlan(String planId, {List<String>? stages, Map<String, int>? stageDuration}) async {
    final data = _storage['rolloutPlans']![planId];
    if (data != null) {
      if (stages != null) data['stages'] = stages;
      if (stageDuration != null) data['stageDuration'] = stageDuration;
    }
  }

  @override
  Future<void> deleteRolloutPlan(String planId) async {
    _storage['rolloutPlans']!.remove(planId);
  }

  @override
  Future<List<RolloutPlan>> getRolloutPlansByDeployment(String deploymentId) async {
    return _storage['rolloutPlans']!.values
        .where((p) => p['deploymentId'] == deploymentId)
        .map(_mapToPlan)
        .toList();
  }

  @override
  Future<List<RolloutPlan>> getAutomatedPlans() async {
    return _storage['rolloutPlans']!.values
        .where((p) => p['isAutomated'] == true)
        .map(_mapToPlan)
        .toList();
  }

  @override
  Future<int> getPlanCount() async {
    return _storage['rolloutPlans']!.length;
  }

  // Canary Implementation
  @override
  Future<CanaryDeployment> createCanaryDeployment(String deploymentId, double trafficPercentage, int targetReplicas) async {
    final canary = CanaryDeployment(
      canaryId: 'can_${DateTime.now().millisecondsSinceEpoch}',
      deploymentId: deploymentId,
      trafficPercentage: trafficPercentage,
      targetReplicas: targetReplicas,
      currentReplicas: 0,
      startTime: DateTime.now(),
      metricNames: [],
    );
    _storage['canaries']![canary.canaryId] = _canaryToMap(canary);
    return canary;
  }

  @override
  Future<CanaryDeployment?> getCanaryDeployment(String canaryId) async {
    final data = _storage['canaries']![canaryId];
    return data != null ? _mapToCanary(data) : null;
  }

  @override
  Future<CanaryDeployment> updateCanaryStatus(String canaryId, int currentReplicas, bool isSuccessful) async {
    final data = _storage['canaries']![canaryId];
    if (data == null) throw Exception('Canary not found');
    data['currentReplicas'] = currentReplicas;
    data['isSuccessful'] = isSuccessful;
    if (isSuccessful || currentReplicas >= data['targetReplicas']) {
      data['completionTime'] = DateTime.now().toIso8601String();
    }
    return _mapToCanary(data);
  }

  @override
  Future<void> deleteCanaryDeployment(String canaryId) async {
    _storage['canaries']!.remove(canaryId);
  }

  @override
  Future<List<CanaryDeployment>> getActiveCanaryDeployments() async {
    return _storage['canaries']!.values
        .where((c) => c['completionTime'] == null)
        .map(_mapToCanary)
        .toList();
  }

  @override
  Future<List<CanaryDeployment>> getCanaryByDeployment(String deploymentId) async {
    return _storage['canaries']!.values
        .where((c) => c['deploymentId'] == deploymentId)
        .map(_mapToCanary)
        .toList();
  }

  @override
  Future<List<CanaryDeployment>> getSuccessfulCanaries() async {
    return _storage['canaries']!.values
        .where((c) => c['isSuccessful'] == true)
        .map(_mapToCanary)
        .toList();
  }

  @override
  Future<List<CanaryDeployment>> getFailedCanaries() async {
    return _storage['canaries']!.values
        .where((c) => c['isSuccessful'] == false && c['completionTime'] != null)
        .map(_mapToCanary)
        .toList();
  }

  // Approval Implementation
  @override
  Future<DeploymentApproval> createApprovalRequest(String deploymentId, EnvironmentType environment, String requestedBy, List<String> approvers) async {
    final approval = DeploymentApproval(
      approvalId: 'app_${DateTime.now().millisecondsSinceEpoch}',
      deploymentId: deploymentId,
      environment: environment,
      status: ApprovalStatus.pending,
      requestedBy: requestedBy,
      requestedAt: DateTime.now(),
      requiredApprovers: approvers,
    );
    _storage['approvals']![approval.approvalId] = _approvalToMap(approval);
    return approval;
  }

  @override
  Future<DeploymentApproval?> getApproval(String approvalId) async {
    final data = _storage['approvals']![approvalId];
    return data != null ? _mapToApproval(data) : null;
  }

  @override
  Future<DeploymentApproval> approveDeployment(String approvalId, String approvedBy, String? comments) async {
    final data = _storage['approvals']![approvalId];
    if (data == null) throw Exception('Approval not found');
    data['status'] = 'approved';
    data['approvedBy'] = approvedBy;
    data['approvedAt'] = DateTime.now().toIso8601String();
    if (comments != null) data['comments'] = comments;
    return _mapToApproval(data);
  }

  @override
  Future<DeploymentApproval> rejectDeployment(String approvalId, String rejectReason) async {
    final data = _storage['approvals']![approvalId];
    if (data == null) throw Exception('Approval not found');
    data['status'] = 'rejected';
    data['comments'] = rejectReason;
    return _mapToApproval(data);
  }

  @override
  Future<List<DeploymentApproval>> getPendingApprovals() async {
    return _storage['approvals']!.values
        .where((a) => a['status'] == 'pending')
        .map(_mapToApproval)
        .toList();
  }

  @override
  Future<List<DeploymentApproval>> getApprovalsByDeployment(String deploymentId) async {
    return _storage['approvals']!.values
        .where((a) => a['deploymentId'] == deploymentId)
        .map(_mapToApproval)
        .toList();
  }

  @override
  Future<List<DeploymentApproval>> getApprovalsByEnvironment(EnvironmentType environment) async {
    return _storage['approvals']!.values
        .where((a) => a['environment'] == environment.toString().split('.').last)
        .map(_mapToApproval)
        .toList();
  }

  // Validation Implementation
  @override
  Future<ReleaseValidation> validateRelease(String releaseId, String testType, int totalTests, int passedTests) async {
    final validation = ReleaseValidation(
      validationId: 'val_${DateTime.now().millisecondsSinceEpoch}',
      releaseId: releaseId,
      testType: testType,
      isPassed: passedTests >= (totalTests * 0.9),
      executedAt: DateTime.now(),
      totalTests: totalTests,
      passedTests: passedTests,
      failedTests: [],
    );
    _storage['validations']![validation.validationId] = _validationToMap(validation);
    return validation;
  }

  @override
  Future<ReleaseValidation?> getValidation(String validationId) async {
    final data = _storage['validations']![validationId];
    return data != null ? _mapToValidation(data) : null;
  }

  @override
  Future<List<ReleaseValidation>> getValidationsByRelease(String releaseId) async {
    return _storage['validations']!.values
        .where((v) => v['releaseId'] == releaseId)
        .map(_mapToValidation)
        .toList();
  }

  @override
  Future<List<ReleaseValidation>> getFailedValidations() async {
    return _storage['validations']!.values
        .where((v) => v['isPassed'] == false)
        .map(_mapToValidation)
        .toList();
  }

  @override
  Future<double> getValidationSuccessRate(String releaseId) async {
    final validations = _storage['validations']!.values
        .where((v) => v['releaseId'] == releaseId)
        .toList();
    if (validations.isEmpty) return 0.0;
    final passed = validations.where((v) => v['isPassed']).length;
    return (passed / validations.length) * 100;
  }

  @override
  Future<List<ReleaseValidation>> getLatestValidations(int count) async {
    return _storage['validations']!.values.map(_mapToValidation).toList().take(count).toList();
  }

  // Rollback Implementation
  @override
  Future<DeploymentRollback> initiateRollback(String deploymentId, String targetVersion, String reason, String initiatedBy) async {
    final rollback = DeploymentRollback(
      rollbackId: 'rb_${DateTime.now().millisecondsSinceEpoch}',
      deploymentId: deploymentId,
      targetVersion: targetVersion,
      reason: reason,
      initiatedAt: DateTime.now(),
      initiatedBy: initiatedBy,
    );
    _storage['rollbacks']![rollback.rollbackId] = _rollbackToMap(rollback);
    return rollback;
  }

  @override
  Future<DeploymentRollback?> getRollback(String rollbackId) async {
    final data = _storage['rollbacks']![rollbackId];
    return data != null ? _mapToRollback(data) : null;
  }

  @override
  Future<DeploymentRollback> completeRollback(String rollbackId, String details) async {
    final data = _storage['rollbacks']![rollbackId];
    if (data == null) throw Exception('Rollback not found');
    data['isCompleted'] = true;
    data['completedAt'] = DateTime.now().toIso8601String();
    data['completionDetails'] = details;
    return _mapToRollback(data);
  }

  @override
  Future<List<DeploymentRollback>> getPendingRollbacks() async {
    return _storage['rollbacks']!.values
        .where((r) => r['isCompleted'] == false)
        .map(_mapToRollback)
        .toList();
  }

  @override
  Future<List<DeploymentRollback>> getRollbacksByDeployment(String deploymentId) async {
    return _storage['rollbacks']!.values
        .where((r) => r['deploymentId'] == deploymentId)
        .map(_mapToRollback)
        .toList();
  }

  // Release Notes Implementation
  @override
  Future<ReleaseNotes> createReleaseNotes(String releaseId, String content, List<String> features, List<String> bugFixes) async {
    final notes = ReleaseNotes(
      notesId: 'notes_${DateTime.now().millisecondsSinceEpoch}',
      releaseId: releaseId,
      content: content,
      features: features,
      bugFixes: bugFixes,
      improvements: [],
      breakingChanges: [],
      createdAt: DateTime.now(),
    );
    _storage['releaseNotes']![notes.notesId] = _notesToMap(notes);
    return notes;
  }

  @override
  Future<ReleaseNotes?> getReleaseNotes(String notesId) async {
    final data = _storage['releaseNotes']![notesId];
    return data != null ? _mapToNotes(data) : null;
  }

  @override
  Future<void> updateReleaseNotes(String notesId, {String? content, List<String>? features}) async {
    final data = _storage['releaseNotes']![notesId];
    if (data != null) {
      if (content != null) data['content'] = content;
      if (features != null) data['features'] = features;
    }
  }

  @override
  Future<void> publishReleaseNotes(String notesId) async {
    final data = _storage['releaseNotes']![notesId];
    if (data != null) {
      data['isPublished'] = true;
    }
  }

  @override
  Future<ReleaseNotes?> getNotesByRelease(String releaseId) async {
    final data = _storage['releaseNotes']!.values.firstWhere(
        (n) => n['releaseId'] == releaseId,
        orElse: () => {});
    return data.isNotEmpty ? _mapToNotes(data) : null;
  }

  // Metrics Implementation
  @override
  Future<DeploymentMetrics> recordDeploymentMetrics(String deploymentId, double duration, int successCount, int failureCount) async {
    final metrics = DeploymentMetrics(
      metricsId: 'met_${DateTime.now().millisecondsSinceEpoch}',
      deploymentId: deploymentId,
      collectedAt: DateTime.now(),
      deploymentDuration: duration,
      rolloutDuration: duration * 0.8,
      successCount: successCount,
      failureCount: failureCount,
      rollbackRate: failureCount > 0 ? (failureCount / (successCount + failureCount)) * 100 : 0.0,
      affectedInstances: successCount + failureCount,
    );
    _storage['metrics']![metrics.metricsId] = _metricsToMap(metrics);
    return metrics;
  }

  @override
  Future<DeploymentMetrics?> getMetrics(String metricsId) async {
    final data = _storage['metrics']![metricsId];
    return data != null ? _mapToMetrics(data) : null;
  }

  @override
  Future<DeploymentReport> generateReport(DateTime startDate, DateTime endDate) async {
    final deployments = _storage['deployments']!.values.toList();
    final successful = deployments.where((d) => d['status'] == 'completed').length;
    final failed = deployments.where((d) => d['status'] == 'failed').length;
    final rolledBack = deployments.where((d) => d['status'] == 'rolledBack').length;
    
    return DeploymentReport(
      reportId: 'report_${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      periodStart: startDate,
      periodEnd: endDate,
      totalDeployments: deployments.length,
      successfulDeployments: successful,
      failedDeployments: failed,
      rolledBackDeployments: rolledBack,
      averageDeploymentTime: 1800.0,
    );
  }

  @override
  Future<List<Deployment>> getDeploymentsByFilter(DeploymentFilter filter) async {
    var deployments = _storage['deployments']!.values.map(_mapToDeployment).toList();
    
    if (filter.status != null) {
      deployments = deployments.where((d) => d.status == filter.status).toList();
    }
    if (filter.environment != null) {
      deployments = deployments.where((d) => d.environment == filter.environment).toList();
    }
    if (filter.strategy != null) {
      deployments = deployments.where((d) => d.strategy == filter.strategy).toList();
    }
    
    return deployments;
  }

  // Helper methods
  Map<String, dynamic> _releaseToMap(Release release) => {
    'releaseId': release.releaseId,
    'version': release.version,
    'releaseType': release.releaseType.toString().split('.').last,
    'description': release.description,
    'createdAt': release.createdAt.toIso8601String(),
    'publishedAt': release.publishedAt?.toIso8601String(),
    'createdBy': release.createdBy,
    'changeIds': release.changeIds,
    'releaseNotes': release.releaseNotes,
    'isStable': release.isStable,
  };

  Release _mapToRelease(Map<String, dynamic> map) => Release(
    releaseId: map['releaseId'],
    version: map['version'],
    releaseType: ReleaseType.values.byName(map['releaseType']),
    description: map['description'],
    createdAt: DateTime.parse(map['createdAt']),
    publishedAt: map['publishedAt'] != null ? DateTime.parse(map['publishedAt']) : null,
    createdBy: map['createdBy'],
    changeIds: List<String>.from(map['changeIds']),
    releaseNotes: map['releaseNotes'],
    isStable: map['isStable'] ?? false,
  );

  Map<String, dynamic> _deploymentToMap(Deployment deployment) => {
    'deploymentId': deployment.deploymentId,
    'releaseId': deployment.releaseId,
    'environment': deployment.environment.toString().split('.').last,
    'strategy': deployment.strategy.toString().split('.').last,
    'status': deployment.status.toString().split('.').last,
    'startTime': deployment.startTime.toIso8601String(),
    'endTime': deployment.endTime?.toIso8601String(),
    'initiatedBy': deployment.initiatedBy,
    'affectedServices': deployment.affectedServices,
    'expectedDuration': deployment.expectedDuration,
  };

  Deployment _mapToDeployment(Map<String, dynamic> map) => Deployment(
    deploymentId: map['deploymentId'],
    releaseId: map['releaseId'],
    environment: EnvironmentType.values.byName(map['environment']),
    strategy: DeploymentStrategy.values.byName(map['strategy']),
    status: DeploymentStatus.values.byName(map['status']),
    startTime: DateTime.parse(map['startTime']),
    endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
    initiatedBy: map['initiatedBy'],
    affectedServices: List<String>.from(map['affectedServices']),
    expectedDuration: map['expectedDuration'],
  );

  Map<String, dynamic> _planToMap(RolloutPlan plan) => {
    'planId': plan.planId,
    'deploymentId': plan.deploymentId,
    'stages': plan.stages,
    'stageDuration': plan.stageDuration,
    'isAutomated': plan.isAutomated,
    'createdAt': plan.createdAt.toIso8601String(),
    'createdBy': plan.createdBy,
    'configuration': plan.configuration,
  };

  RolloutPlan _mapToPlan(Map<String, dynamic> map) => RolloutPlan(
    planId: map['planId'],
    deploymentId: map['deploymentId'],
    stages: List<String>.from(map['stages']),
    stageDuration: Map<String, int>.from(map['stageDuration']),
    isAutomated: map['isAutomated'] ?? true,
    createdAt: DateTime.parse(map['createdAt']),
    createdBy: map['createdBy'],
    configuration: map['configuration'],
  );

  Map<String, dynamic> _canaryToMap(CanaryDeployment canary) => {
    'canaryId': canary.canaryId,
    'deploymentId': canary.deploymentId,
    'trafficPercentage': canary.trafficPercentage,
    'targetReplicas': canary.targetReplicas,
    'currentReplicas': canary.currentReplicas,
    'startTime': canary.startTime.toIso8601String(),
    'completionTime': canary.completionTime?.toIso8601String(),
    'metricNames': canary.metricNames,
    'isSuccessful': canary.isSuccessful,
    'rollbackReason': canary.rollbackReason,
  };

  CanaryDeployment _mapToCanary(Map<String, dynamic> map) => CanaryDeployment(
    canaryId: map['canaryId'],
    deploymentId: map['deploymentId'],
    trafficPercentage: map['trafficPercentage'],
    targetReplicas: map['targetReplicas'],
    currentReplicas: map['currentReplicas'],
    startTime: DateTime.parse(map['startTime']),
    completionTime: map['completionTime'] != null ? DateTime.parse(map['completionTime']) : null,
    metricNames: List<String>.from(map['metricNames']),
    isSuccessful: map['isSuccessful'] ?? false,
    rollbackReason: map['rollbackReason'],
  );

  Map<String, dynamic> _approvalToMap(DeploymentApproval approval) => {
    'approvalId': approval.approvalId,
    'deploymentId': approval.deploymentId,
    'environment': approval.environment.toString().split('.').last,
    'status': approval.status.toString().split('.').last,
    'requestedBy': approval.requestedBy,
    'approvedBy': approval.approvedBy,
    'requestedAt': approval.requestedAt.toIso8601String(),
    'approvedAt': approval.approvedAt?.toIso8601String(),
    'comments': approval.comments,
    'requiredApprovers': approval.requiredApprovers,
  };

  DeploymentApproval _mapToApproval(Map<String, dynamic> map) => DeploymentApproval(
    approvalId: map['approvalId'],
    deploymentId: map['deploymentId'],
    environment: EnvironmentType.values.byName(map['environment']),
    status: ApprovalStatus.values.byName(map['status']),
    requestedBy: map['requestedBy'],
    approvedBy: map['approvedBy'],
    requestedAt: DateTime.parse(map['requestedAt']),
    approvedAt: map['approvedAt'] != null ? DateTime.parse(map['approvedAt']) : null,
    comments: map['comments'],
    requiredApprovers: List<String>.from(map['requiredApprovers']),
  );

  Map<String, dynamic> _validationToMap(ReleaseValidation validation) => {
    'validationId': validation.validationId,
    'releaseId': validation.releaseId,
    'testType': validation.testType,
    'isPassed': validation.isPassed,
    'executedAt': validation.executedAt.toIso8601String(),
    'totalTests': validation.totalTests,
    'passedTests': validation.passedTests,
    'failedTests': validation.failedTests,
    'validationDetails': validation.validationDetails,
  };

  ReleaseValidation _mapToValidation(Map<String, dynamic> map) => ReleaseValidation(
    validationId: map['validationId'],
    releaseId: map['releaseId'],
    testType: map['testType'],
    isPassed: map['isPassed'],
    executedAt: DateTime.parse(map['executedAt']),
    totalTests: map['totalTests'],
    passedTests: map['passedTests'],
    failedTests: List<String>.from(map['failedTests']),
    validationDetails: map['validationDetails'],
  );

  Map<String, dynamic> _rollbackToMap(DeploymentRollback rollback) => {
    'rollbackId': rollback.rollbackId,
    'deploymentId': rollback.deploymentId,
    'targetVersion': rollback.targetVersion,
    'reason': rollback.reason,
    'initiatedAt': rollback.initiatedAt.toIso8601String(),
    'initiatedBy': rollback.initiatedBy,
    'isCompleted': rollback.isCompleted,
    'completedAt': rollback.completedAt?.toIso8601String(),
    'completionDetails': rollback.completionDetails,
  };

  DeploymentRollback _mapToRollback(Map<String, dynamic> map) => DeploymentRollback(
    rollbackId: map['rollbackId'],
    deploymentId: map['deploymentId'],
    targetVersion: map['targetVersion'],
    reason: map['reason'],
    initiatedAt: DateTime.parse(map['initiatedAt']),
    initiatedBy: map['initiatedBy'],
    isCompleted: map['isCompleted'] ?? false,
    completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    completionDetails: map['completionDetails'],
  );

  Map<String, dynamic> _notesToMap(ReleaseNotes notes) => {
    'notesId': notes.notesId,
    'releaseId': notes.releaseId,
    'content': notes.content,
    'features': notes.features,
    'bugFixes': notes.bugFixes,
    'improvements': notes.improvements,
    'breakingChanges': notes.breakingChanges,
    'createdAt': notes.createdAt.toIso8601String(),
    'isPublished': notes.isPublished,
  };

  ReleaseNotes _mapToNotes(Map<String, dynamic> map) => ReleaseNotes(
    notesId: map['notesId'],
    releaseId: map['releaseId'],
    content: map['content'],
    features: List<String>.from(map['features']),
    bugFixes: List<String>.from(map['bugFixes']),
    improvements: List<String>.from(map['improvements']),
    breakingChanges: List<String>.from(map['breakingChanges']),
    createdAt: DateTime.parse(map['createdAt']),
    isPublished: map['isPublished'] ?? false,
  );

  Map<String, dynamic> _metricsToMap(DeploymentMetrics metrics) => {
    'metricsId': metrics.metricsId,
    'deploymentId': metrics.deploymentId,
    'collectedAt': metrics.collectedAt.toIso8601String(),
    'deploymentDuration': metrics.deploymentDuration,
    'rolloutDuration': metrics.rolloutDuration,
    'successCount': metrics.successCount,
    'failureCount': metrics.failureCount,
    'rollbackRate': metrics.rollbackRate,
    'affectedInstances': metrics.affectedInstances,
  };

  DeploymentMetrics _mapToMetrics(Map<String, dynamic> map) => DeploymentMetrics(
    metricsId: map['metricsId'],
    deploymentId: map['deploymentId'],
    collectedAt: DateTime.parse(map['collectedAt']),
    deploymentDuration: map['deploymentDuration'],
    rolloutDuration: map['rolloutDuration'],
    successCount: map['successCount'],
    failureCount: map['failureCount'],
    rollbackRate: map['rollbackRate'],
    affectedInstances: map['affectedInstances'],
  );
}

// ============================================================================
// Engines (5 Specialized)
// ============================================================================

class ReleaseEngine {
  Future<Release> createProductionRelease(String version, String description) async {
    return Release(
      releaseId: 'rel_${DateTime.now().millisecondsSinceEpoch}',
      version: version,
      releaseType: ReleaseType.major,
      description: description,
      createdAt: DateTime.now(),
      createdBy: 'system',
      changeIds: [],
      isStable: true,
    );
  }
}

class DeploymentPlanningEngine {
  Future<RolloutPlan> planDeployment(String deploymentId, EnvironmentType environment) async {
    final stages = <String>['validation', 'deployment', 'verification', 'monitoring'];
    final stageDuration = <String, int>{
      'validation': 300,
      'deployment': 600,
      'verification': 300,
      'monitoring': 300,
    };
    
    return RolloutPlan(
      planId: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      deploymentId: deploymentId,
      stages: stages,
      stageDuration: stageDuration,
      createdAt: DateTime.now(),
      createdBy: 'system',
      configuration: {'environment': environment.toString().split('.').last},
    );
  }
}

class CanaryStrategyEngine {
  Future<CanaryDeployment> createCanaryStrategy(String deploymentId) async {
    return CanaryDeployment(
      canaryId: 'can_${DateTime.now().millisecondsSinceEpoch}',
      deploymentId: deploymentId,
      trafficPercentage: 10.0,
      targetReplicas: 5,
      currentReplicas: 0,
      startTime: DateTime.now(),
      metricNames: ['errorRate', 'latency', 'throughput'],
    );
  }
}

class ApprovalWorkflowEngine {
  Future<DeploymentApproval> createApprovalWorkflow(String deploymentId, EnvironmentType environment) async {
    final approvers = environment == EnvironmentType.production
        ? ['lead', 'director', 'cto']
        : ['lead', 'manager'];
    
    return DeploymentApproval(
      approvalId: 'app_${DateTime.now().millisecondsSinceEpoch}',
      deploymentId: deploymentId,
      environment: environment,
      status: ApprovalStatus.pending,
      requestedBy: 'system',
      requestedAt: DateTime.now(),
      requiredApprovers: approvers,
    );
  }
}

class RollbackRecoveryEngine {
  Future<DeploymentRollback> prepareRollback(String deploymentId, String targetVersion) async {
    return DeploymentRollback(
      rollbackId: 'rb_${DateTime.now().millisecondsSinceEpoch}',
      deploymentId: deploymentId,
      targetVersion: targetVersion,
      reason: 'Automated rollback triggered',
      initiatedAt: DateTime.now(),
      initiatedBy: 'system',
    );
  }
}

// ============================================================================
// Manager (Coordinates)
// ============================================================================

class DeploymentManager {
  final DeploymentRepository repository;
  final ReleaseEngine releaseEngine;
  final DeploymentPlanningEngine planningEngine;
  final CanaryStrategyEngine canaryEngine;
  final ApprovalWorkflowEngine approvalEngine;
  final RollbackRecoveryEngine rollbackEngine;

  DeploymentManager({
    required this.repository,
    required this.releaseEngine,
    required this.planningEngine,
    required this.canaryEngine,
    required this.approvalEngine,
    required this.rollbackEngine,
  });

  Future<Deployment> planAndCreateDeployment(
    String releaseId,
    EnvironmentType environment,
    DeploymentStrategy strategy,
    String initiatedBy,
  ) async {
    final deployment = await repository.createDeployment(releaseId, environment, strategy, initiatedBy);
    
    await repository.createRolloutPlan(
      deployment.deploymentId,
      ['validation', 'deployment', 'verification'],
      {'validation': 300, 'deployment': 600, 'verification': 300},
      initiatedBy,
    );

    if (strategy == DeploymentStrategy.canary) {
      await repository.createCanaryDeployment(deployment.deploymentId, 10.0, 5);
    }

    if (environment == EnvironmentType.production) {
      await repository.createApprovalRequest(
        deployment.deploymentId,
        environment,
        initiatedBy,
        ['lead', 'director'],
      );
    }

    return deployment;
  }
}

// ============================================================================
// Facade (Public API)
// ============================================================================

class DeploymentFacade {
  final DeploymentRepository repository;
  final DeploymentManager manager;

  DeploymentFacade({
    required this.repository,
    required this.manager,
  });

  Future<Deployment> deployRelease(
    String releaseId,
    EnvironmentType environment,
    DeploymentStrategy strategy,
    String initiatedBy,
  ) => manager.planAndCreateDeployment(releaseId, environment, strategy, initiatedBy);

  Future<Deployment?> getDeploymentStatus(String deploymentId) =>
      repository.getDeployment(deploymentId);

  Future<List<Deployment>> getActiveDeployments() =>
      repository.getActiveDeployments();

  Future<void> approveDeployment(String approvalId, String approvedBy) async {
    await repository.approveDeployment(approvalId, approvedBy, 'Approved');
  }

  Future<void> rollbackDeployment(String deploymentId, String targetVersion) async {
    await repository.initiateRollback(deploymentId, targetVersion, 'Manual rollback', 'system');
    await repository.updateDeploymentStatus(deploymentId, DeploymentStatus.rolledBack);
  }

  Future<DeploymentReport> generateDeploymentReport(DateTime startDate, DateTime endDate) =>
      repository.generateReport(startDate, endDate);
}
