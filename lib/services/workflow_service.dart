import '../models/workflow_models.dart';

abstract class WorkflowRepository {
  Future<void> createWorkflow(Workflow workflow);
  Future<Workflow?> getWorkflow(String workflowId);
  Future<List<Workflow>> getWorkflowsByStatus(WorkflowStatus status);
  Future<List<Workflow>> getAllWorkflows();
  Future<void> updateWorkflow(Workflow workflow);

  Future<void> createStep(WorkflowStep step);
  Future<WorkflowStep?> getStep(String stepId);
  Future<List<WorkflowStep>> getWorkflowSteps(String workflowId);
  Future<void> updateStep(WorkflowStep step);

  Future<void> createDependency(StepDependency dependency);
  Future<List<StepDependency>> getStepDependencies(String stepId);
  Future<List<StepDependency>> getDependentsOf(String stepId);

  Future<void> createExecution(WorkflowExecution execution);
  Future<WorkflowExecution?> getExecution(String executionId);
  Future<List<WorkflowExecution>> getWorkflowExecutions(String workflowId);
  Future<List<WorkflowExecution>> getExecutionsByState(ExecutionState state);
  Future<void> updateExecution(WorkflowExecution execution);

  Future<void> createStepExecution(StepExecution stepExecution);
  Future<StepExecution?> getStepExecution(String stepExecutionId);
  Future<List<StepExecution>> getExecutionSteps(String executionId);
  Future<List<StepExecution>> getStepExecutionHistory(String stepId);
  Future<void> updateStepExecution(StepExecution stepExecution);

  Future<void> createPipeline(WorkflowPipeline pipeline);
  Future<WorkflowPipeline?> getPipeline(String pipelineId);
  Future<List<WorkflowPipeline>> getAllPipelines();
  Future<void> updatePipeline(WorkflowPipeline pipeline);

  Future<void> createContext(ExecutionContext context);
  Future<ExecutionContext?> getContext(String contextId);
  Future<List<ExecutionContext>> getExecutionContexts(String executionId);

  Future<void> createTrigger(WorkflowTrigger trigger);
  Future<WorkflowTrigger?> getTrigger(String triggerId);
  Future<List<WorkflowTrigger>> getWorkflowTriggers(String workflowId);
  Future<List<WorkflowTrigger>> getActiveTriggers();

  Future<void> saveRetryPolicy(RetryPolicy policy);
  Future<RetryPolicy?> getRetryPolicy(String policyId);
  Future<List<RetryPolicy>> getStepRetryPolicies(String stepId);

  Future<void> saveMetrics(WorkflowMetrics metrics);
  Future<WorkflowMetrics?> getMetrics(String metricsId);
  Future<List<WorkflowMetrics>> getWorkflowMetrics(String workflowId);

  Future<void> createSchedule(WorkflowSchedule schedule);
  Future<WorkflowSchedule?> getSchedule(String scheduleId);
  Future<List<WorkflowSchedule>> getWorkflowSchedules(String workflowId);
  Future<void> updateSchedule(WorkflowSchedule schedule);

  Future<void> recordLog(ExecutionLog log);
  Future<ExecutionLog?> getLog(String logId);
  Future<List<ExecutionLog>> getExecutionLogs(String executionId);

  Future<void> createTemplate(WorkflowTemplate template);
  Future<WorkflowTemplate?> getTemplate(String templateId);
  Future<List<WorkflowTemplate>> getAllTemplates();
  Future<List<WorkflowTemplate>> getTemplatesByTag(String tag);

  Future<void> createNotification(WorkflowNotification notification);
  Future<WorkflowNotification?> getNotification(String notificationId);
  Future<List<WorkflowNotification>> getExecutionNotifications(String executionId);
}

class MemoryWorkflowRepository implements WorkflowRepository {
  final Map<String, Workflow> _workflows = {};
  final Map<String, WorkflowStep> _steps = {};
  final Map<String, StepDependency> _dependencies = {};
  final Map<String, WorkflowExecution> _executions = {};
  final Map<String, StepExecution> _stepExecutions = {};
  final Map<String, WorkflowPipeline> _pipelines = {};
  final Map<String, ExecutionContext> _contexts = {};
  final Map<String, WorkflowTrigger> _triggers = {};
  final Map<String, RetryPolicy> _retryPolicies = {};
  final Map<String, WorkflowMetrics> _metrics = {};
  final Map<String, WorkflowSchedule> _schedules = {};
  final Map<String, ExecutionLog> _logs = {};
  final Map<String, WorkflowTemplate> _templates = {};
  final Map<String, WorkflowNotification> _notifications = {};

  @override
  Future<void> createWorkflow(Workflow workflow) async => _workflows[workflow.workflowId] = workflow;

  @override
  Future<Workflow?> getWorkflow(String workflowId) async => _workflows[workflowId];

  @override
  Future<List<Workflow>> getWorkflowsByStatus(WorkflowStatus status) async =>
      _workflows.values.where((w) => w.status == status).toList();

  @override
  Future<List<Workflow>> getAllWorkflows() async => _workflows.values.toList();

  @override
  Future<void> updateWorkflow(Workflow workflow) async => _workflows[workflow.workflowId] = workflow;

  @override
  Future<void> createStep(WorkflowStep step) async => _steps[step.stepId] = step;

  @override
  Future<WorkflowStep?> getStep(String stepId) async => _steps[stepId];

  @override
  Future<List<WorkflowStep>> getWorkflowSteps(String workflowId) async =>
      _steps.values.where((s) => s.workflowId == workflowId).toList();

  @override
  Future<void> updateStep(WorkflowStep step) async => _steps[step.stepId] = step;

  @override
  Future<void> createDependency(StepDependency dependency) async =>
      _dependencies[dependency.dependencyId] = dependency;

  @override
  Future<List<StepDependency>> getStepDependencies(String stepId) async =>
      _dependencies.values.where((d) => d.stepId == stepId).toList();

  @override
  Future<List<StepDependency>> getDependentsOf(String stepId) async =>
      _dependencies.values.where((d) => d.dependsOnStepId == stepId).toList();

  @override
  Future<void> createExecution(WorkflowExecution execution) async =>
      _executions[execution.executionId] = execution;

  @override
  Future<WorkflowExecution?> getExecution(String executionId) async =>
      _executions[executionId];

  @override
  Future<List<WorkflowExecution>> getWorkflowExecutions(String workflowId) async =>
      _executions.values.where((e) => e.workflowId == workflowId).toList();

  @override
  Future<List<WorkflowExecution>> getExecutionsByState(ExecutionState state) async =>
      _executions.values.where((e) => e.state == state).toList();

  @override
  Future<void> updateExecution(WorkflowExecution execution) async =>
      _executions[execution.executionId] = execution;

  @override
  Future<void> createStepExecution(StepExecution stepExecution) async =>
      _stepExecutions[stepExecution.stepExecutionId] = stepExecution;

  @override
  Future<StepExecution?> getStepExecution(String stepExecutionId) async =>
      _stepExecutions[stepExecutionId];

  @override
  Future<List<StepExecution>> getExecutionSteps(String executionId) async =>
      _stepExecutions.values.where((s) => s.executionId == executionId).toList();

  @override
  Future<List<StepExecution>> getStepExecutionHistory(String stepId) async =>
      _stepExecutions.values.where((s) => s.stepId == stepId).toList();

  @override
  Future<void> updateStepExecution(StepExecution stepExecution) async =>
      _stepExecutions[stepExecution.stepExecutionId] = stepExecution;

  @override
  Future<void> createPipeline(WorkflowPipeline pipeline) async =>
      _pipelines[pipeline.pipelineId] = pipeline;

  @override
  Future<WorkflowPipeline?> getPipeline(String pipelineId) async =>
      _pipelines[pipelineId];

  @override
  Future<List<WorkflowPipeline>> getAllPipelines() async =>
      _pipelines.values.toList();

  @override
  Future<void> updatePipeline(WorkflowPipeline pipeline) async =>
      _pipelines[pipeline.pipelineId] = pipeline;

  @override
  Future<void> createContext(ExecutionContext context) async =>
      _contexts[context.contextId] = context;

  @override
  Future<ExecutionContext?> getContext(String contextId) async =>
      _contexts[contextId];

  @override
  Future<List<ExecutionContext>> getExecutionContexts(String executionId) async =>
      _contexts.values.where((c) => c.executionId == executionId).toList();

  @override
  Future<void> createTrigger(WorkflowTrigger trigger) async =>
      _triggers[trigger.triggerId] = trigger;

  @override
  Future<WorkflowTrigger?> getTrigger(String triggerId) async =>
      _triggers[triggerId];

  @override
  Future<List<WorkflowTrigger>> getWorkflowTriggers(String workflowId) async =>
      _triggers.values.where((t) => t.workflowId == workflowId).toList();

  @override
  Future<List<WorkflowTrigger>> getActiveTriggers() async =>
      _triggers.values.where((t) => t.isActive).toList();

  @override
  Future<void> saveRetryPolicy(RetryPolicy policy) async =>
      _retryPolicies[policy.policyId] = policy;

  @override
  Future<RetryPolicy?> getRetryPolicy(String policyId) async =>
      _retryPolicies[policyId];

  @override
  Future<List<RetryPolicy>> getStepRetryPolicies(String stepId) async =>
      _retryPolicies.values.where((p) => p.stepId == stepId).toList();

  @override
  Future<void> saveMetrics(WorkflowMetrics metrics) async =>
      _metrics[metrics.metricsId] = metrics;

  @override
  Future<WorkflowMetrics?> getMetrics(String metricsId) async =>
      _metrics[metricsId];

  @override
  Future<List<WorkflowMetrics>> getWorkflowMetrics(String workflowId) async =>
      _metrics.values.where((m) => m.workflowId == workflowId).toList();

  @override
  Future<void> createSchedule(WorkflowSchedule schedule) async =>
      _schedules[schedule.scheduleId] = schedule;

  @override
  Future<WorkflowSchedule?> getSchedule(String scheduleId) async =>
      _schedules[scheduleId];

  @override
  Future<List<WorkflowSchedule>> getWorkflowSchedules(String workflowId) async =>
      _schedules.values.where((s) => s.workflowId == workflowId).toList();

  @override
  Future<void> updateSchedule(WorkflowSchedule schedule) async =>
      _schedules[schedule.scheduleId] = schedule;

  @override
  Future<void> recordLog(ExecutionLog log) async =>
      _logs[log.logId] = log;

  @override
  Future<ExecutionLog?> getLog(String logId) async =>
      _logs[logId];

  @override
  Future<List<ExecutionLog>> getExecutionLogs(String executionId) async =>
      _logs.values.where((l) => l.executionId == executionId).toList();

  @override
  Future<void> createTemplate(WorkflowTemplate template) async =>
      _templates[template.templateId] = template;

  @override
  Future<WorkflowTemplate?> getTemplate(String templateId) async =>
      _templates[templateId];

  @override
  Future<List<WorkflowTemplate>> getAllTemplates() async =>
      _templates.values.toList();

  @override
  Future<List<WorkflowTemplate>> getTemplatesByTag(String tag) async =>
      _templates.values.where((t) => t.tags.contains(tag)).toList();

  @override
  Future<void> createNotification(WorkflowNotification notification) async =>
      _notifications[notification.notificationId] = notification;

  @override
  Future<WorkflowNotification?> getNotification(String notificationId) async =>
      _notifications[notificationId];

  @override
  Future<List<WorkflowNotification>> getExecutionNotifications(String executionId) async =>
      _notifications.values.where((n) => n.executionId == executionId).toList();
}

class WorkflowExecutionEngine {
  final WorkflowRepository repository;

  WorkflowExecutionEngine(this.repository);

  Future<WorkflowExecution?> startExecution(
    String workflowId,
    String triggeredBy,
    TriggerType triggerType, {
    Map<String, dynamic>? inputs,
  }) async {
    final workflow = await repository.getWorkflow(workflowId);
    if (workflow == null || !workflow.isActive) {
      return null;
    }

    final execution = WorkflowExecution(
      executionId: 'exec-${DateTime.now().millisecondsSinceEpoch}',
      workflowId: workflowId,
      state: ExecutionState.queued,
      startedAt: DateTime.now(),
      triggeredBy: triggeredBy,
      triggerType: triggerType,
      inputs: inputs ?? {},
    );

    await repository.createExecution(execution);
    return execution;
  }

  Future<void> completeExecution(String executionId, {Map<String, dynamic>? outputs}) async {
    final execution = await repository.getExecution(executionId);
    if (execution != null) {
      final completed = WorkflowExecution(
        executionId: execution.executionId,
        workflowId: execution.workflowId,
        state: ExecutionState.completed,
        startedAt: execution.startedAt,
        completedAt: DateTime.now(),
        triggeredBy: execution.triggeredBy,
        triggerType: execution.triggerType,
        inputs: execution.inputs,
        outputs: outputs ?? execution.outputs,
      );
      await repository.updateExecution(completed);
    }
  }

  Future<void> failExecution(String executionId) async {
    final execution = await repository.getExecution(executionId);
    if (execution != null) {
      final failed = WorkflowExecution(
        executionId: execution.executionId,
        workflowId: execution.workflowId,
        state: ExecutionState.failed,
        startedAt: execution.startedAt,
        completedAt: DateTime.now(),
        triggeredBy: execution.triggeredBy,
        triggerType: execution.triggerType,
        inputs: execution.inputs,
        outputs: execution.outputs,
      );
      await repository.updateExecution(failed);
    }
  }
}

class StepExecutionEngine {
  final WorkflowRepository repository;

  StepExecutionEngine(this.repository);

  Future<StepExecution?> startStep(String executionId, String stepId) async {
    final stepExecution = StepExecution(
      stepExecutionId: 'step-exec-${DateTime.now().millisecondsSinceEpoch}',
      executionId: executionId,
      stepId: stepId,
      status: StepStatus.running,
      startedAt: DateTime.now(),
      attemptCount: 1,
    );

    await repository.createStepExecution(stepExecution);
    return stepExecution;
  }

  Future<void> completeStep(String stepExecutionId, {Map<String, dynamic>? output}) async {
    final stepExec = await repository.getStepExecution(stepExecutionId);
    if (stepExec != null) {
      final completed = StepExecution(
        stepExecutionId: stepExec.stepExecutionId,
        executionId: stepExec.executionId,
        stepId: stepExec.stepId,
        status: StepStatus.succeeded,
        startedAt: stepExec.startedAt,
        completedAt: DateTime.now(),
        attemptCount: stepExec.attemptCount,
        stepOutput: output ?? stepExec.stepOutput,
      );
      await repository.updateStepExecution(completed);
    }
  }

  Future<void> failStep(String stepExecutionId, String errorMessage) async {
    final stepExec = await repository.getStepExecution(stepExecutionId);
    if (stepExec != null) {
      final failed = StepExecution(
        stepExecutionId: stepExec.stepExecutionId,
        executionId: stepExec.executionId,
        stepId: stepExec.stepId,
        status: StepStatus.failed,
        startedAt: stepExec.startedAt,
        completedAt: DateTime.now(),
        attemptCount: stepExec.attemptCount,
        errorMessage: errorMessage,
        stepOutput: stepExec.stepOutput,
      );
      await repository.updateStepExecution(failed);
    }
  }

  Future<void> retryStep(String stepExecutionId) async {
    final stepExec = await repository.getStepExecution(stepExecutionId);
    if (stepExec != null) {
      final retrying = StepExecution(
        stepExecutionId: stepExec.stepExecutionId,
        executionId: stepExec.executionId,
        stepId: stepExec.stepId,
        status: StepStatus.retrying,
        startedAt: stepExec.startedAt,
        attemptCount: stepExec.attemptCount + 1,
        stepOutput: stepExec.stepOutput,
      );
      await repository.updateStepExecution(retrying);
    }
  }
}

class DependencyEngine {
  final WorkflowRepository repository;

  DependencyEngine(this.repository);

  Future<List<String>> getBlockedSteps(String stepId) async {
    final dependents = await repository.getDependentsOf(stepId);
    return dependents.map((d) => d.stepId).toList();
  }

  Future<List<String>> getRequiredSteps(String stepId) async {
    final dependencies = await repository.getStepDependencies(stepId);
    return dependencies.map((d) => d.dependsOnStepId).toList();
  }

  Future<bool> canExecuteStep(String stepId, List<String> completedSteps) async {
    final dependencies = await repository.getStepDependencies(stepId);
    for (final dep in dependencies) {
      if (dep.isHard && !completedSteps.contains(dep.dependsOnStepId)) {
        return false;
      }
    }
    return true;
  }
}

class WorkflowManager {
  final WorkflowRepository repository;
  late final WorkflowExecutionEngine executionEngine;
  late final StepExecutionEngine stepEngine;
  late final DependencyEngine dependencyEngine;

  WorkflowManager(this.repository) {
    executionEngine = WorkflowExecutionEngine(repository);
    stepEngine = StepExecutionEngine(repository);
    dependencyEngine = DependencyEngine(repository);
  }

  Future<WorkflowExecution?> startWorkflow(
    String workflowId,
    String triggeredBy,
    TriggerType triggerType, {
    Map<String, dynamic>? inputs,
  }) =>
      executionEngine.startExecution(workflowId, triggeredBy, triggerType, inputs: inputs);

  Future<void> completeWorkflow(String executionId, {Map<String, dynamic>? outputs}) =>
      executionEngine.completeExecution(executionId, outputs: outputs);

  Future<void> failWorkflow(String executionId) =>
      executionEngine.failExecution(executionId);

  Future<StepExecution?> executeStep(String executionId, String stepId) =>
      stepEngine.startStep(executionId, stepId);

  Future<void> completeStep(String stepExecutionId, {Map<String, dynamic>? output}) =>
      stepEngine.completeStep(stepExecutionId, output: output);

  Future<void> failStep(String stepExecutionId, String errorMessage) =>
      stepEngine.failStep(stepExecutionId, errorMessage);

  Future<void> retryStep(String stepExecutionId) =>
      stepEngine.retryStep(stepExecutionId);
}

class WorkflowFacade {
  final WorkflowManager manager;

  WorkflowFacade(this.manager);

  Future<void> createWorkflow(
    String workflowName,
    String description,
    List<String> stepIds,
    String createdBy,
  ) async {
    final workflow = Workflow(
      workflowId: 'wf-${DateTime.now().millisecondsSinceEpoch}',
      workflowName: workflowName,
      description: description,
      stepIds: stepIds,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );
    await manager.repository.createWorkflow(workflow);
  }

  Future<Workflow?> getWorkflow(String workflowId) =>
      manager.repository.getWorkflow(workflowId);

  Future<List<Workflow>> getActiveWorkflows() =>
      manager.repository.getWorkflowsByStatus(WorkflowStatus.active);

  Future<void> activateWorkflow(String workflowId) async {
    final workflow = await manager.repository.getWorkflow(workflowId);
    if (workflow != null) {
      final active = Workflow(
        workflowId: workflow.workflowId,
        workflowName: workflow.workflowName,
        description: workflow.description,
        stepIds: workflow.stepIds,
        status: WorkflowStatus.active,
        createdAt: workflow.createdAt,
        updatedAt: DateTime.now(),
        createdBy: workflow.createdBy,
        metadata: workflow.metadata,
      );
      await manager.repository.updateWorkflow(active);
    }
  }

  Future<void> createStep(
    String workflowId,
    String stepName,
    String actionType,
    Map<String, dynamic> actionConfig,
  ) async {
    final step = WorkflowStep(
      stepId: 'step-${DateTime.now().millisecondsSinceEpoch}',
      workflowId: workflowId,
      stepName: stepName,
      description: '',
      actionType: actionType,
      actionConfig: actionConfig,
    );
    await manager.repository.createStep(step);
  }

  Future<List<WorkflowStep>> getWorkflowSteps(String workflowId) =>
      manager.repository.getWorkflowSteps(workflowId);

  Future<WorkflowExecution?> executeWorkflow(
    String workflowId,
    String triggeredBy, {
    Map<String, dynamic>? inputs,
  }) =>
      manager.startWorkflow(workflowId, triggeredBy, TriggerType.manual, inputs: inputs);

  Future<WorkflowExecution?> getExecution(String executionId) =>
      manager.repository.getExecution(executionId);

  Future<List<WorkflowExecution>> getWorkflowExecutions(String workflowId) =>
      manager.repository.getWorkflowExecutions(workflowId);

  Future<List<StepExecution>> getExecutionSteps(String executionId) =>
      manager.repository.getExecutionSteps(executionId);

  Future<void> recordLog(
    String executionId,
    String stepExecutionId,
    String message, {
    String logLevel = 'INFO',
  }) async {
    final log = ExecutionLog(
      logId: 'log-${DateTime.now().millisecondsSinceEpoch}',
      executionId: executionId,
      stepExecutionId: stepExecutionId,
      message: message,
      timestamp: DateTime.now(),
      logLevel: logLevel,
    );
    await manager.repository.recordLog(log);
  }

  Future<List<ExecutionLog>> getExecutionLogs(String executionId) =>
      manager.repository.getExecutionLogs(executionId);

  Future<void> createWorkflowTemplate(
    String templateName,
    String description,
    Map<String, dynamic> definition,
    List<String> tags,
  ) async {
    final template = WorkflowTemplate(
      templateId: 'tmpl-${DateTime.now().millisecondsSinceEpoch}',
      templateName: templateName,
      description: description,
      templateDefinition: definition,
      tags: tags,
      createdAt: DateTime.now(),
    );
    await manager.repository.createTemplate(template);
  }

  Future<List<WorkflowTemplate>> getAllTemplates() =>
      manager.repository.getAllTemplates();

  Future<void> createWorkflowTrigger(
    String workflowId,
    TriggerType triggerType,
    Map<String, dynamic> config,
  ) async {
    final trigger = WorkflowTrigger(
      triggerId: 'trig-${DateTime.now().millisecondsSinceEpoch}',
      workflowId: workflowId,
      triggerType: triggerType,
      triggerConfig: config,
      createdAt: DateTime.now(),
    );
    await manager.repository.createTrigger(trigger);
  }

  Future<List<WorkflowTrigger>> getWorkflowTriggers(String workflowId) =>
      manager.repository.getWorkflowTriggers(workflowId);

  Future<void> saveMetrics(
    String workflowId,
    int totalExecutions,
    int successfulExecutions,
    int failedExecutions,
    double averageTime,
  ) async {
    final now = DateTime.now();
    final metrics = WorkflowMetrics(
      metricsId: 'metric-${DateTime.now().millisecondsSinceEpoch}',
      workflowId: workflowId,
      totalExecutions: totalExecutions,
      successfulExecutions: successfulExecutions,
      failedExecutions: failedExecutions,
      averageExecutionTime: averageTime,
      successRate: totalExecutions > 0 ? (successfulExecutions / totalExecutions) * 100 : 0.0,
      periodStart: now.subtract(Duration(days: 1)),
      periodEnd: now,
    );
    await manager.repository.saveMetrics(metrics);
  }

  Future<WorkflowMetrics?> getLatestMetrics(String workflowId) async {
    final metrics = await manager.repository.getWorkflowMetrics(workflowId);
    return metrics.isNotEmpty ? metrics.last : null;
  }
}
