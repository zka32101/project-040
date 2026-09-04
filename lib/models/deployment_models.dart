/// Deployment & Release Management Models

enum DeploymentStrategy { blueGreen, canary, rolling, recreate, shadowTraffic, featureToggle }
enum DeploymentStatus { planned, preparing, inProgress, paused, completed, failed, rolledBack, cancelled }
enum ReleaseType { major, minor, patch, hotfix, beta, alpha, rc }
enum EnvironmentType { development, staging, uat, production, disaster_recovery }
enum ApprovalStatus { pending, approved, rejected, conditionallyApproved, revokeApproval }
enum RolloutPhase { validation, deployment, verification, monitoring, completion }

class Release {
  final String releaseId;
  final String version;
  final ReleaseType releaseType;
  final String description;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final String createdBy;
  final List<String> changeIds;
  final String? releaseNotes;
  final bool isStable;

  Release({
    required this.releaseId,
    required this.version,
    required this.releaseType,
    required this.description,
    required this.createdAt,
    this.publishedAt,
    required this.createdBy,
    required this.changeIds,
    this.releaseNotes,
    this.isStable = false,
  });

  bool get isPublished => publishedAt != null;
  bool get isBeta => releaseType == ReleaseType.beta || releaseType == ReleaseType.alpha;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  int get changeCount => changeIds.length;
}

class Deployment {
  final String deploymentId;
  final String releaseId;
  final EnvironmentType environment;
  final DeploymentStrategy strategy;
  final DeploymentStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final String initiatedBy;
  final List<String> affectedServices;
  final int expectedDuration;

  Deployment({
    required this.deploymentId,
    required this.releaseId,
    required this.environment,
    required this.strategy,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.initiatedBy,
    required this.affectedServices,
    this.expectedDuration = 3600,
  });

  bool get isActive => status == DeploymentStatus.inProgress || status == DeploymentStatus.preparing;
  bool get isCompleted => status == DeploymentStatus.completed || status == DeploymentStatus.rolledBack;
  bool get isFailed => status == DeploymentStatus.failed;
  int get durationSeconds => endTime != null ? endTime!.difference(startTime).inSeconds : -1;
  double get progressPercentage => isActive ? (durationSeconds.toDouble() / expectedDuration * 100).clamp(0, 100) : 0.0;
}

class RolloutPlan {
  final String planId;
  final String deploymentId;
  final List<String> stages;
  final Map<String, int> stageDuration;
  final bool isAutomated;
  final DateTime createdAt;
  final String createdBy;
  final Map<String, dynamic> configuration;

  RolloutPlan({
    required this.planId,
    required this.deploymentId,
    required this.stages,
    required this.stageDuration,
    this.isAutomated = true,
    required this.createdAt,
    required this.createdBy,
    required this.configuration,
  });

  int get totalDuration => stageDuration.values.fold(0, (a, b) => a + b);
  int get stageCount => stages.length;
  bool get isValid => stages.isNotEmpty && stageDuration.length == stages.length;
}

class CanaryDeployment {
  final String canaryId;
  final String deploymentId;
  final double trafficPercentage;
  final int targetReplicas;
  final int currentReplicas;
  final DateTime startTime;
  final DateTime? completionTime;
  final List<String> metricNames;
  final bool isSuccessful;
  final String? rollbackReason;

  CanaryDeployment({
    required this.canaryId,
    required this.deploymentId,
    required this.trafficPercentage,
    required this.targetReplicas,
    required this.currentReplicas,
    required this.startTime,
    this.completionTime,
    required this.metricNames,
    this.isSuccessful = false,
    this.rollbackReason,
  });

  bool get isActive => completionTime == null;
  bool get isReady => currentReplicas >= targetReplicas;
  double get replicaReadiness => targetReplicas > 0 ? (currentReplicas / targetReplicas) * 100 : 0.0;
  int get durationMinutes => completionTime != null ? completionTime!.difference(startTime).inMinutes : -1;
}

class DeploymentApproval {
  final String approvalId;
  final String deploymentId;
  final EnvironmentType environment;
  final ApprovalStatus status;
  final String requestedBy;
  final String? approvedBy;
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final String? comments;
  final List<String> requiredApprovers;

  DeploymentApproval({
    required this.approvalId,
    required this.deploymentId,
    required this.environment,
    required this.status,
    required this.requestedBy,
    this.approvedBy,
    required this.requestedAt,
    this.approvedAt,
    this.comments,
    required this.requiredApprovers,
  });

  bool get isApproved => status == ApprovalStatus.approved;
  bool get isPending => status == ApprovalStatus.pending;
  bool get isRejected => status == ApprovalStatus.rejected;
  int get pendingApproverCount => requiredApprovers.length;
  int get waitingTimeMinutes => DateTime.now().difference(requestedAt).inMinutes;
}

class ReleaseValidation {
  final String validationId;
  final String releaseId;
  final String testType;
  final bool isPassed;
  final DateTime executedAt;
  final int totalTests;
  final int passedTests;
  final List<String> failedTests;
  final String? validationDetails;

  ReleaseValidation({
    required this.validationId,
    required this.releaseId,
    required this.testType,
    required this.isPassed,
    required this.executedAt,
    required this.totalTests,
    required this.passedTests,
    required this.failedTests,
    this.validationDetails,
  });

  double get successRate => totalTests > 0 ? (passedTests / totalTests) * 100 : 0.0;
  int get ageInMinutes => DateTime.now().difference(executedAt).inMinutes;
}

class DeploymentRollback {
  final String rollbackId;
  final String deploymentId;
  final String targetVersion;
  final String reason;
  final DateTime initiatedAt;
  final String initiatedBy;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? completionDetails;

  DeploymentRollback({
    required this.rollbackId,
    required this.deploymentId,
    required this.targetVersion,
    required this.reason,
    required this.initiatedAt,
    required this.initiatedBy,
    this.isCompleted = false,
    this.completedAt,
    this.completionDetails,
  });

  int get durationSeconds => completedAt != null ? completedAt!.difference(initiatedAt).inSeconds : -1;
  int get ageInMinutes => DateTime.now().difference(initiatedAt).inMinutes;
}

class ReleaseNotes {
  final String notesId;
  final String releaseId;
  final String content;
  final List<String> features;
  final List<String> bugFixes;
  final List<String> improvements;
  final List<String> breakingChanges;
  final DateTime createdAt;
  final bool isPublished;

  ReleaseNotes({
    required this.notesId,
    required this.releaseId,
    required this.content,
    required this.features,
    required this.bugFixes,
    required this.improvements,
    required this.breakingChanges,
    required this.createdAt,
    this.isPublished = false,
  });

  int get totalChanges => features.length + bugFixes.length + improvements.length;
  bool get hasBreakingChanges => breakingChanges.isNotEmpty;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class DeploymentMetrics {
  final String metricsId;
  final String deploymentId;
  final DateTime collectedAt;
  final double deploymentDuration;
  final double rolloutDuration;
  final int successCount;
  final int failureCount;
  final double rollbackRate;
  final int affectedInstances;

  DeploymentMetrics({
    required this.metricsId,
    required this.deploymentId,
    required this.collectedAt,
    required this.deploymentDuration,
    required this.rolloutDuration,
    required this.successCount,
    required this.failureCount,
    required this.rollbackRate,
    required this.affectedInstances,
  });

  double get successRate => (successCount + failureCount) > 0 
      ? (successCount / (successCount + failureCount)) * 100 
      : 0.0;
  int get ageInMinutes => DateTime.now().difference(collectedAt).inMinutes;
}

class DeploymentReport {
  final String reportId;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalDeployments;
  final int successfulDeployments;
  final int failedDeployments;
  final int rolledBackDeployments;
  final double averageDeploymentTime;

  DeploymentReport({
    required this.reportId,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.totalDeployments,
    required this.successfulDeployments,
    required this.failedDeployments,
    required this.rolledBackDeployments,
    required this.averageDeploymentTime,
  });

  double get successRate => totalDeployments > 0 
      ? (successfulDeployments / totalDeployments) * 100 
      : 0.0;
  int get periodInDays => periodEnd.difference(periodStart).inDays;
}

class DeploymentFilter {
  final String filterId;
  final String filterName;
  final DeploymentStatus? status;
  final EnvironmentType? environment;
  final DeploymentStrategy? strategy;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  DeploymentFilter({
    required this.filterId,
    required this.filterName,
    this.status,
    this.environment,
    this.strategy,
    this.startDate,
    this.endDate,
    this.isActive = true,
  });

  bool get hasFilters =>
      status != null || environment != null || strategy != null || startDate != null || endDate != null;
  int get activeFilterCount =>
      (status != null ? 1 : 0) +
      (environment != null ? 1 : 0) +
      (strategy != null ? 1 : 0) +
      (startDate != null ? 1 : 0) +
      (endDate != null ? 1 : 0);
}
