/// Workflow Orchestration & Execution Engine Models

enum WorkflowStatus { draft, active, inactive, deleted }
enum StepStatus { pending, running, succeeded, failed, skipped, retrying }
enum ExecutionState { queued, running, completed, failed, cancelled }
enum TriggerType { manual, scheduled, event, webhook }
enum FailureStrategy { fail, skip, retry, continue_ }
enum ParallelizationMode { sequential, parallel, hybrid }

class Workflow {
  final String workflowId;
  final String workflowName;
  final String description;
  final List<String> stepIds;
  final WorkflowStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;
  final Map<String, dynamic> metadata;

  Workflow({
    required this.workflowId,
    required this.workflowName,
    required this.description,
    required this.stepIds,
    this.status = WorkflowStatus.draft,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    this.metadata = const {},
  });

  bool get isActive => status == WorkflowStatus.active;
  int get stepCount => stepIds.length;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  bool get hasMetadata => metadata.isNotEmpty;
}

class WorkflowStep {
  final String stepId;
  final String workflowId;
  final String stepName;
  final String description;
  final String actionType;
  final Map<String, dynamic> actionConfig;
  final List<String> dependsOn;
  final FailureStrategy failureStrategy;
  final int maxRetries;
  final int timeoutSeconds;
  final bool isOptional;

  WorkflowStep({
    required this.stepId,
    required this.workflowId,
    required this.stepName,
    required this.description,
    required this.actionType,
    required this.actionConfig,
    this.dependsOn = const [],
    this.failureStrategy = FailureStrategy.fail,
    this.maxRetries = 0,
    this.timeoutSeconds = 3600,
    this.isOptional = false,
  });

  bool get hasDependencies => dependsOn.isNotEmpty;
  int get dependencyCount => dependsOn.length;
  bool get hasConfig => actionConfig.isNotEmpty;
  bool get isRetryable => maxRetries > 0;
}

class StepDependency {
  final String dependencyId;
  final String stepId;
  final String dependsOnStepId;
  final String dependencyType;
  final bool isHard;
  final DateTime createdAt;

  StepDependency({
    required this.dependencyId,
    required this.stepId,
    required this.dependsOnStepId,
    required this.dependencyType,
    this.isHard = true,
    required this.createdAt,
  });

  bool get isSoft => !isHard;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class WorkflowExecution {
  final String executionId;
  final String workflowId;
  final ExecutionState state;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String triggeredBy;
  final TriggerType triggerType;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic> outputs;

  WorkflowExecution({
    required this.executionId,
    required this.workflowId,
    this.state = ExecutionState.queued,
    required this.startedAt,
    this.completedAt,
    required this.triggeredBy,
    required this.triggerType,
    this.inputs = const {},
    this.outputs = const {},
  });

  bool get isRunning => state == ExecutionState.running;
  bool get isCompleted => state == ExecutionState.completed;
  bool get isFailed => state == ExecutionState.failed;
  int get durationInSeconds => completedAt != null ? completedAt!.difference(startedAt).inSeconds : 0;
  int get ageInSeconds => DateTime.now().difference(startedAt).inSeconds;
}

class StepExecution {
  final String stepExecutionId;
  final String executionId;
  final String stepId;
  final StepStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int attemptCount;
  final String? errorMessage;
  final Map<String, dynamic> stepOutput;

  StepExecution({
    required this.stepExecutionId,
    required this.executionId,
    required this.stepId,
    this.status = StepStatus.pending,
    required this.startedAt,
    this.completedAt,
    this.attemptCount = 0,
    this.errorMessage,
    this.stepOutput = const {},
  });

  bool get isRunning => status == StepStatus.running;
  bool get isSucceeded => status == StepStatus.succeeded;
  bool get isFailed => status == StepStatus.failed;
  bool get isRetrying => status == StepStatus.retrying;
  int get durationInSeconds => completedAt != null ? completedAt!.difference(startedAt).inSeconds : 0;
  bool get hasError => errorMessage != null;
  bool get hasOutput => stepOutput.isNotEmpty;
}

class WorkflowPipeline {
  final String pipelineId;
  final String pipelineName;
  final List<String> workflowIds;
  final ParallelizationMode mode;
  final int maxParallelSteps;
  final DateTime createdAt;
  final bool isEnabled;

  WorkflowPipeline({
    required this.pipelineId,
    required this.pipelineName,
    required this.workflowIds,
    this.mode = ParallelizationMode.sequential,
    this.maxParallelSteps = 1,
    required this.createdAt,
    this.isEnabled = true,
  });

  bool get hasWorkflows => workflowIds.isNotEmpty;
  int get workflowCount => workflowIds.length;
  bool get isParallel => mode == ParallelizationMode.parallel;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class ExecutionContext {
  final String contextId;
  final String executionId;
  final Map<String, dynamic> variables;
  final Map<String, dynamic> secrets;
  final Map<String, dynamic> artifacts;
  final DateTime createdAt;

  ExecutionContext({
    required this.contextId,
    required this.executionId,
    this.variables = const {},
    this.secrets = const {},
    this.artifacts = const {},
    required this.createdAt,
  });

  bool get hasVariables => variables.isNotEmpty;
  bool get hasSecrets => secrets.isNotEmpty;
  bool get hasArtifacts => artifacts.isNotEmpty;
  int get totalData => variables.length + secrets.length + artifacts.length;
}

class WorkflowTrigger {
  final String triggerId;
  final String workflowId;
  final TriggerType triggerType;
  final Map<String, dynamic> triggerConfig;
  final bool isActive;
  final DateTime createdAt;
  final String? cronExpression;

  WorkflowTrigger({
    required this.triggerId,
    required this.workflowId,
    required this.triggerType,
    required this.triggerConfig,
    this.isActive = true,
    required this.createdAt,
    this.cronExpression,
  });

  bool get isScheduled => triggerType == TriggerType.scheduled;
  bool get isManual => triggerType == TriggerType.manual;
  bool get isEventBased => triggerType == TriggerType.event;
  bool get hasConfig => triggerConfig.isNotEmpty;
}

class RetryPolicy {
  final String policyId;
  final String stepId;
  final int maxRetries;
  final int initialDelaySeconds;
  final int maxDelaySeconds;
  final double backoffMultiplier;
  final List<String> retryableErrors;
  final bool isEnabled;

  RetryPolicy({
    required this.policyId,
    required this.stepId,
    required this.maxRetries,
    required this.initialDelaySeconds,
    required this.maxDelaySeconds,
    this.backoffMultiplier = 2.0,
    this.retryableErrors = const [],
    this.isEnabled = true,
  });

  bool get hasRetryableErrors => retryableErrors.isNotEmpty;
  int get errorCount => retryableErrors.length;
  bool get hasExponentialBackoff => backoffMultiplier > 1.0;
}

class WorkflowMetrics {
  final String metricsId;
  final String workflowId;
  final int totalExecutions;
  final int successfulExecutions;
  final int failedExecutions;
  final double averageExecutionTime;
  final double successRate;
  final DateTime periodStart;
  final DateTime periodEnd;

  WorkflowMetrics({
    required this.metricsId,
    required this.workflowId,
    required this.totalExecutions,
    required this.successfulExecutions,
    required this.failedExecutions,
    required this.averageExecutionTime,
    required this.successRate,
    required this.periodStart,
    required this.periodEnd,
  });

  bool get isHealthy => successRate >= 95.0;
  int get failureCount => totalExecutions - successfulExecutions;
  double get failureRate => totalExecutions > 0 ? (failureCount / totalExecutions) * 100 : 0.0;
}

class WorkflowSchedule {
  final String scheduleId;
  final String workflowId;
  final String cronExpression;
  final DateTime? nextExecution;
  final DateTime? lastExecution;
  final bool isActive;
  final String timezone;

  WorkflowSchedule({
    required this.scheduleId,
    required this.workflowId,
    required this.cronExpression,
    this.nextExecution,
    this.lastExecution,
    this.isActive = true,
    this.timezone = 'UTC',
  });

  bool get isDue => nextExecution != null && DateTime.now().isAfter(nextExecution!);
  bool get hasExecuted => lastExecution != null;
  int get daysSinceLastExecution => lastExecution != null 
      ? DateTime.now().difference(lastExecution!).inDays 
      : 0;
}

class ExecutionLog {
  final String logId;
  final String executionId;
  final String stepExecutionId;
  final String message;
  final DateTime timestamp;
  final String logLevel;
  final Map<String, dynamic> metadata;

  ExecutionLog({
    required this.logId,
    required this.executionId,
    required this.stepExecutionId,
    required this.message,
    required this.timestamp,
    this.logLevel = 'INFO',
    this.metadata = const {},
  });

  bool get isError => logLevel == 'ERROR';
  bool get isWarning => logLevel == 'WARNING';
  bool get isInfo => logLevel == 'INFO';
  bool get isDebug => logLevel == 'DEBUG';
  int get ageInSeconds => DateTime.now().difference(timestamp).inSeconds;
  bool get hasMetadata => metadata.isNotEmpty;
}

class WorkflowTemplate {
  final String templateId;
  final String templateName;
  final String description;
  final Map<String, dynamic> templateDefinition;
  final List<String> tags;
  final DateTime createdAt;
  final int usageCount;

  WorkflowTemplate({
    required this.templateId,
    required this.templateName,
    required this.description,
    required this.templateDefinition,
    this.tags = const [],
    required this.createdAt,
    this.usageCount = 0,
  });

  bool get hasDefinition => templateDefinition.isNotEmpty;
  bool get hasTags => tags.isNotEmpty;
  int get tagCount => tags.length;
  bool get isPopular => usageCount >= 10;
}

class WorkflowNotification {
  final String notificationId;
  final String executionId;
  final String notificationType;
  final String recipient;
  final String message;
  final DateTime createdAt;
  final bool isSent;
  final String? sendError;

  WorkflowNotification({
    required this.notificationId,
    required this.executionId,
    required this.notificationType,
    required this.recipient,
    required this.message,
    required this.createdAt,
    this.isSent = false,
    this.sendError,
  });

  bool get hasFailed => sendError != null;
  int get ageInMinutes => DateTime.now().difference(createdAt).inMinutes;
}
