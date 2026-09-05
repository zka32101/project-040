/// Phase 85: Advanced Workflow Orchestration & Process Automation
/// Service layer for workflow orchestration
library workflow_orchestration_service;

import 'package:project_040/models/workflow_orchestration_models.dart';

// ============================================================================
// REPOSITORY INTERFACE (70+ methods)
// ============================================================================

abstract class WorkflowRepository {
  // ---- Workflow Management (12 methods) ----
  Future<Workflow> createWorkflow(Workflow workflow);
  Future<Workflow?> getWorkflowById(String workflowId);
  Future<List<Workflow>> getAllWorkflows({int limit = 100, int offset = 0});
  Future<List<Workflow>> getWorkflowsByStatus(WorkflowStatus status);
  Future<Workflow> updateWorkflow(Workflow workflow);
  Future<bool> deleteWorkflow(String workflowId);
  Future<bool> publishWorkflow(String workflowId);
  Future<bool> archiveWorkflow(String workflowId);
  Future<List<Workflow>> searchWorkflows(String query);
  Future<int> getWorkflowCount();
  Future<int> getActiveWorkflowCount();
  Future<List<Workflow>> getRecentWorkflows(int limit);

  // ---- Workflow Steps (12 methods) ----
  Future<WorkflowStep> createStep(WorkflowStep step);
  Future<WorkflowStep?> getStepById(String stepId);
  Future<List<WorkflowStep>> getStepsByWorkflow(String workflowId);
  Future<WorkflowStep> updateStep(WorkflowStep step);
  Future<bool> deleteStep(String stepId);
  Future<List<WorkflowStep>> getStepsByOrder(String workflowId, {int limit = 50});
  Future<int> getStepCountByWorkflow(String workflowId);
  Future<List<WorkflowStep>> getStepsWithRetry(String workflowId);
  Future<bool> reorderSteps(String workflowId, Map<String, int> stepIdToOrder);
  Future<List<WorkflowStep>> getTimeoutSteps(String workflowId);
  Future<int> getTotalStepCount();
  Future<List<WorkflowStep>> getStepsWithErrorHandling(String workflowId);

  // ---- Process Instances (12 methods) ----
  Future<ProcessInstance> createProcessInstance(ProcessInstance instance);
  Future<ProcessInstance?> getProcessInstanceById(String instanceId);
  Future<List<ProcessInstance>> getProcessInstancesByWorkflow(String workflowId);
  Future<List<ProcessInstance>> getProcessInstancesByStatus(ProcessState status);
  Future<ProcessInstance> updateProcessInstance(ProcessInstance instance);
  Future<bool> deleteProcessInstance(String instanceId);
  Future<List<ProcessInstance>> getActiveProcessInstances();
  Future<List<ProcessInstance>> getProcessInstancesByUser(String userId);
  Future<int> getProcessInstanceCount();
  Future<int> getRunningProcessCount();
  Future<List<ProcessInstance>> getFailedProcesses(String workflowId);
  Future<double> getAverageProcessDuration(String workflowId);

  // ---- Step Executions (10 methods) ----
  Future<StepExecution> createStepExecution(StepExecution execution);
  Future<StepExecution?> getStepExecutionById(String executionId);
  Future<List<StepExecution>> getExecutionsByProcessInstance(String processInstanceId);
  Future<List<StepExecution>> getExecutionsByStep(String stepId);
  Future<List<StepExecution>> getExecutionsByStatus(StepStatus status);
  Future<StepExecution> updateStepExecution(StepExecution execution);
  Future<List<StepExecution>> getFailedStepExecutions(String processInstanceId);
  Future<int> getStepExecutionCount();
  Future<double> getAverageStepExecutionTime(String stepId);
  Future<List<StepExecution>> getSlowSteps(double thresholdMs);

  // ---- Transitions (8 methods) ----
  Future<WorkflowTransition> createTransition(WorkflowTransition transition);
  Future<WorkflowTransition?> getTransitionById(String transitionId);
  Future<List<WorkflowTransition>> getTransitionsByWorkflow(String workflowId);
  Future<List<WorkflowTransition>> getTransitionsFromStep(String fromStepId);
  Future<List<WorkflowTransition>> getTransitionsToStep(String toStepId);
  Future<bool> deleteTransition(String transitionId);
  Future<List<WorkflowTransition>> getConditionalTransitions(String workflowId);
  Future<List<WorkflowTransition>> getParallelTransitions(String workflowId);

  // ---- Process History (8 methods) ----
  Future<ProcessHistory> recordEvent(ProcessHistory event);
  Future<ProcessHistory?> getEventById(String eventId);
  Future<List<ProcessHistory>> getHistoryByProcess(String processInstanceId);
  Future<List<ProcessHistory>> getHistoryByEventType(String processInstanceId, String eventType);
  Future<List<ProcessHistory>> getStateChangeHistory(String processInstanceId);
  Future<int> getEventCount(String processInstanceId);
  Future<List<ProcessHistory>> getRecentEvents(String processInstanceId, int limit);
  Future<bool> deleteOldHistory(String processInstanceId, Duration olderThan);

  // ---- Automation Rules (8 methods) ----
  Future<AutomationRule> createRule(AutomationRule rule);
  Future<AutomationRule?> getRuleById(String ruleId);
  Future<List<AutomationRule>> getAllRules();
  Future<List<AutomationRule>> getActiveRules();
  Future<List<AutomationRule>> getRulesByTriggerType(AutomationTriggerType triggerType);
  Future<AutomationRule> updateRule(AutomationRule rule);
  Future<bool> toggleRuleActive(String ruleId);
  Future<bool> deleteRule(String ruleId);

  // ---- Event Triggers (8 methods) ----
  Future<EventTrigger> recordEventTrigger(EventTrigger trigger);
  Future<EventTrigger?> getEventTriggerById(String triggerId);
  Future<List<EventTrigger>> getTriggersByAutomationRule(String ruleId);
  Future<List<EventTrigger>> getTriggersByStatus(String status);
  Future<List<EventTrigger>> getPendingTriggers();
  Future<bool> markTriggerProcessed(String triggerId, String processInstanceId);
  Future<int> getPendingTriggerCount();
  Future<List<EventTrigger>> getFailedTriggers(String ruleId);

  // ---- Variables (8 methods) ----
  Future<WorkflowVariable> saveVariable(WorkflowVariable variable);
  Future<WorkflowVariable?> getVariableById(String variableId);
  Future<List<WorkflowVariable>> getVariablesByProcess(String processInstanceId);
  Future<WorkflowVariable?> getVariableByName(String processInstanceId, String name);
  Future<bool> updateVariableValue(String variableId, String newValue);
  Future<bool> deleteVariable(String variableId);
  Future<int> getVariableCount(String processInstanceId);
  Future<List<WorkflowVariable>> getEncryptedVariables(String processInstanceId);

  // ---- Rollback Points (6 methods) ----
  Future<RollbackPoint> createRollbackPoint(RollbackPoint point);
  Future<RollbackPoint?> getRollbackPointById(String pointId);
  Future<List<RollbackPoint>> getRollbackPointsByProcess(String processInstanceId);
  Future<List<RollbackPoint>> getAvailableRollbackPoints(String processInstanceId);
  Future<bool> markRollbackPointUsed(String pointId);
  Future<List<RollbackPoint>> getUnusedRollbackPoints(String processInstanceId);

  // ---- Execution Logs (8 methods) ----
  Future<ExecutionLog> recordLog(ExecutionLog log);
  Future<ExecutionLog?> getLogById(String logId);
  Future<List<ExecutionLog>> getLogsByProcess(String processInstanceId);
  Future<List<ExecutionLog>> getLogsByLevel(String processInstanceId, String level);
  Future<List<ExecutionLog>> getErrorLogs(String processInstanceId);
  Future<int> getLogCount(String processInstanceId);
  Future<List<ExecutionLog>> getRecentLogs(String processInstanceId, int limit);
  Future<bool> deleteOldLogs(String processInstanceId, Duration olderThan);

  // ---- Performance Metrics (6 methods) ----
  Future<WorkflowPerformanceMetrics> recordMetrics(WorkflowPerformanceMetrics metrics);
  Future<WorkflowPerformanceMetrics?> getLatestMetrics(String workflowId);
  Future<List<WorkflowPerformanceMetrics>> getMetricsHistory(String workflowId, Duration period);
  Future<double> getWorkflowSuccessRate(String workflowId);
  Future<double> getWorkflowAverageExecutionTime(String workflowId);
  Future<List<String>> getUnhealthyWorkflows();
}

// ============================================================================
// IN-MEMORY REPOSITORY IMPLEMENTATION
// ============================================================================

class InMemoryWorkflowRepository extends WorkflowRepository {
  final Map<String, Workflow> _workflows = {};
  final Map<String, WorkflowStep> _steps = {};
  final Map<String, ProcessInstance> _instances = {};
  final Map<String, StepExecution> _executions = {};
  final Map<String, WorkflowTransition> _transitions = {};
  final Map<String, ProcessHistory> _history = {};
  final Map<String, AutomationRule> _rules = {};
  final Map<String, EventTrigger> _triggers = {};
  final Map<String, WorkflowVariable> _variables = {};
  final Map<String, RollbackPoint> _rollbackPoints = {};
  final Map<String, ExecutionLog> _logs = {};
  final Map<String, WorkflowPerformanceMetrics> _metrics = {};

  // ---- Workflow Management ----
  @override
  Future<Workflow> createWorkflow(Workflow workflow) async {
    _workflows[workflow.id] = workflow;
    return workflow;
  }

  @override
  Future<Workflow?> getWorkflowById(String workflowId) async => _workflows[workflowId];

  @override
  Future<List<Workflow>> getAllWorkflows({int limit = 100, int offset = 0}) async {
    final all = _workflows.values.toList();
    return all.skip(offset).take(limit).toList();
  }

  @override
  Future<List<Workflow>> getWorkflowsByStatus(WorkflowStatus status) async {
    return _workflows.values.where((w) => w.status == status).toList();
  }

  @override
  Future<Workflow> updateWorkflow(Workflow workflow) async {
    _workflows[workflow.id] = workflow;
    return workflow;
  }

  @override
  Future<bool> deleteWorkflow(String workflowId) async {
    return _workflows.remove(workflowId) != null;
  }

  @override
  Future<bool> publishWorkflow(String workflowId) async {
    final workflow = _workflows[workflowId];
    if (workflow != null) {
      _workflows[workflowId] = workflow.copyWith(isPublished: true, status: WorkflowStatus.active);
      return true;
    }
    return false;
  }

  @override
  Future<bool> archiveWorkflow(String workflowId) async {
    final workflow = _workflows[workflowId];
    if (workflow != null) {
      _workflows[workflowId] = workflow.copyWith(status: WorkflowStatus.archived);
      return true;
    }
    return false;
  }

  @override
  Future<List<Workflow>> searchWorkflows(String query) async {
    final lowerQuery = query.toLowerCase();
    return _workflows.values
        .where((w) => w.name.toLowerCase().contains(lowerQuery) ||
            (w.description?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }

  @override
  Future<int> getWorkflowCount() async => _workflows.length;

  @override
  Future<int> getActiveWorkflowCount() async {
    return _workflows.values.where((w) => w.isActive).length;
  }

  @override
  Future<List<Workflow>> getRecentWorkflows(int limit) async {
    final all = _workflows.values.toList();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all.take(limit).toList();
  }

  // ---- Workflow Steps ----
  @override
  Future<WorkflowStep> createStep(WorkflowStep step) async {
    _steps[step.id] = step;
    return step;
  }

  @override
  Future<WorkflowStep?> getStepById(String stepId) async => _steps[stepId];

  @override
  Future<List<WorkflowStep>> getStepsByWorkflow(String workflowId) async {
    return _steps.values.where((s) => s.workflowId == workflowId).toList();
  }

  @override
  Future<WorkflowStep> updateStep(WorkflowStep step) async {
    _steps[step.id] = step;
    return step;
  }

  @override
  Future<bool> deleteStep(String stepId) async {
    return _steps.remove(stepId) != null;
  }

  @override
  Future<List<WorkflowStep>> getStepsByOrder(String workflowId, {int limit = 50}) async {
    final steps = _steps.values.where((s) => s.workflowId == workflowId).toList();
    steps.sort((a, b) => a.stepOrder.compareTo(b.stepOrder));
    return steps.take(limit).toList();
  }

  @override
  Future<int> getStepCountByWorkflow(String workflowId) async {
    return _steps.values.where((s) => s.workflowId == workflowId).length;
  }

  @override
  Future<List<WorkflowStep>> getStepsWithRetry(String workflowId) async {
    return _steps.values.where((s) => s.workflowId == workflowId && s.hasRetry).toList();
  }

  @override
  Future<bool> reorderSteps(String workflowId, Map<String, int> stepIdToOrder) async {
    for (final entry in stepIdToOrder.entries) {
      final step = _steps[entry.key];
      if (step != null && step.workflowId == workflowId) {
        _steps[entry.key] = WorkflowStep(
          id: step.id,
          workflowId: step.workflowId,
          name: step.name,
          stepOrder: entry.value,
          createdAt: step.createdAt,
          description: step.description,
          actionType: step.actionType,
          retryCount: step.retryCount,
          timeoutSeconds: step.timeoutSeconds,
          skipOnError: step.skipOnError,
          inputVariables: step.inputVariables,
          outputVariables: step.outputVariables,
        );
      }
    }
    return true;
  }

  @override
  Future<List<WorkflowStep>> getTimeoutSteps(String workflowId) async {
    return _steps.values.where((s) => s.workflowId == workflowId && s.hasTimeout).toList();
  }

  @override
  Future<int> getTotalStepCount() async => _steps.length;

  @override
  Future<List<WorkflowStep>> getStepsWithErrorHandling(String workflowId) async {
    return _steps.values.where((s) => s.workflowId == workflowId && s.skipOnError).toList();
  }

  // ---- Process Instances ----
  @override
  Future<ProcessInstance> createProcessInstance(ProcessInstance instance) async {
    _instances[instance.id] = instance;
    return instance;
  }

  @override
  Future<ProcessInstance?> getProcessInstanceById(String instanceId) async => _instances[instanceId];

  @override
  Future<List<ProcessInstance>> getProcessInstancesByWorkflow(String workflowId) async {
    return _instances.values.where((i) => i.workflowId == workflowId).toList();
  }

  @override
  Future<List<ProcessInstance>> getProcessInstancesByStatus(ProcessState status) async {
    return _instances.values.where((i) => i.status == status).toList();
  }

  @override
  Future<ProcessInstance> updateProcessInstance(ProcessInstance instance) async {
    _instances[instance.id] = instance;
    return instance;
  }

  @override
  Future<bool> deleteProcessInstance(String instanceId) async {
    return _instances.remove(instanceId) != null;
  }

  @override
  Future<List<ProcessInstance>> getActiveProcessInstances() async {
    return _instances.values.where((i) => i.isActive).toList();
  }

  @override
  Future<List<ProcessInstance>> getProcessInstancesByUser(String userId) async {
    return _instances.values.where((i) => i.initiatedBy == userId).toList();
  }

  @override
  Future<int> getProcessInstanceCount() async => _instances.length;

  @override
  Future<int> getRunningProcessCount() async {
    return _instances.values.where((i) => i.status == ProcessState.running).length;
  }

  @override
  Future<List<ProcessInstance>> getFailedProcesses(String workflowId) async {
    return _instances.values.where((i) => i.workflowId == workflowId && i.isFailed).toList();
  }

  @override
  Future<double> getAverageProcessDuration(String workflowId) async {
    final processes = _instances.values.where((i) => i.workflowId == workflowId).toList();
    if (processes.isEmpty) return 0;
    return processes.map((p) => p.durationSeconds).reduce((a, b) => a + b) / processes.length;
  }

  // ---- Step Executions ----
  @override
  Future<StepExecution> createStepExecution(StepExecution execution) async {
    _executions[execution.id] = execution;
    return execution;
  }

  @override
  Future<StepExecution?> getStepExecutionById(String executionId) async => _executions[executionId];

  @override
  Future<List<StepExecution>> getExecutionsByProcessInstance(String processInstanceId) async {
    return _executions.values.where((e) => e.processInstanceId == processInstanceId).toList();
  }

  @override
  Future<List<StepExecution>> getExecutionsByStep(String stepId) async {
    return _executions.values.where((e) => e.stepId == stepId).toList();
  }

  @override
  Future<List<StepExecution>> getExecutionsByStatus(StepStatus status) async {
    return _executions.values.where((e) => e.status == status).toList();
  }

  @override
  Future<StepExecution> updateStepExecution(StepExecution execution) async {
    _executions[execution.id] = execution;
    return execution;
  }

  @override
  Future<List<StepExecution>> getFailedStepExecutions(String processInstanceId) async {
    return _executions.values
        .where((e) => e.processInstanceId == processInstanceId && e.isFailed)
        .toList();
  }

  @override
  Future<int> getStepExecutionCount() async => _executions.length;

  @override
  Future<double> getAverageStepExecutionTime(String stepId) async {
    final execs = _executions.values.where((e) => e.stepId == stepId).toList();
    if (execs.isEmpty) return 0;
    return execs.map((e) => e.executionTimeMs).reduce((a, b) => a + b) / execs.length;
  }

  @override
  Future<List<StepExecution>> getSlowSteps(double thresholdMs) async {
    return _executions.values.where((e) => e.executionTimeMs > thresholdMs).toList();
  }

  // ---- Transitions ----
  @override
  Future<WorkflowTransition> createTransition(WorkflowTransition transition) async {
    _transitions[transition.id] = transition;
    return transition;
  }

  @override
  Future<WorkflowTransition?> getTransitionById(String transitionId) async => _transitions[transitionId];

  @override
  Future<List<WorkflowTransition>> getTransitionsByWorkflow(String workflowId) async {
    return _transitions.values.where((t) => t.workflowId == workflowId).toList();
  }

  @override
  Future<List<WorkflowTransition>> getTransitionsFromStep(String fromStepId) async {
    return _transitions.values.where((t) => t.fromStepId == fromStepId).toList();
  }

  @override
  Future<List<WorkflowTransition>> getTransitionsToStep(String toStepId) async {
    return _transitions.values.where((t) => t.toStepId == toStepId).toList();
  }

  @override
  Future<bool> deleteTransition(String transitionId) async {
    return _transitions.remove(transitionId) != null;
  }

  @override
  Future<List<WorkflowTransition>> getConditionalTransitions(String workflowId) async {
    return _transitions.values.where((t) => t.workflowId == workflowId && t.isConditional).toList();
  }

  @override
  Future<List<WorkflowTransition>> getParallelTransitions(String workflowId) async {
    return _transitions.values.where((t) => t.workflowId == workflowId && t.isParallel).toList();
  }

  // ---- Process History ----
  @override
  Future<ProcessHistory> recordEvent(ProcessHistory event) async {
    _history[event.id] = event;
    return event;
  }

  @override
  Future<ProcessHistory?> getEventById(String eventId) async => _history[eventId];

  @override
  Future<List<ProcessHistory>> getHistoryByProcess(String processInstanceId) async {
    return _history.values.where((h) => h.processInstanceId == processInstanceId).toList();
  }

  @override
  Future<List<ProcessHistory>> getHistoryByEventType(String processInstanceId, String eventType) async {
    return _history.values
        .where((h) => h.processInstanceId == processInstanceId && h.eventType == eventType)
        .toList();
  }

  @override
  Future<List<ProcessHistory>> getStateChangeHistory(String processInstanceId) async {
    return _history.values
        .where((h) => h.processInstanceId == processInstanceId && h.isStateChange)
        .toList();
  }

  @override
  Future<int> getEventCount(String processInstanceId) async {
    return _history.values.where((h) => h.processInstanceId == processInstanceId).length;
  }

  @override
  Future<List<ProcessHistory>> getRecentEvents(String processInstanceId, int limit) async {
    final events = _history.values.where((h) => h.processInstanceId == processInstanceId).toList();
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events.take(limit).toList();
  }

  @override
  Future<bool> deleteOldHistory(String processInstanceId, Duration olderThan) async {
    final cutoff = DateTime.now().subtract(olderThan);
    final keysToRemove = _history.entries
        .where((e) => e.value.processInstanceId == processInstanceId && e.value.timestamp.isBefore(cutoff))
        .map((e) => e.key)
        .toList();
    for (final key in keysToRemove) {
      _history.remove(key);
    }
    return keysToRemove.isNotEmpty;
  }

  // ---- Automation Rules ----
  @override
  Future<AutomationRule> createRule(AutomationRule rule) async {
    _rules[rule.id] = rule;
    return rule;
  }

  @override
  Future<AutomationRule?> getRuleById(String ruleId) async => _rules[ruleId];

  @override
  Future<List<AutomationRule>> getAllRules() async => _rules.values.toList();

  @override
  Future<List<AutomationRule>> getActiveRules() async {
    return _rules.values.where((r) => r.isActive).toList();
  }

  @override
  Future<List<AutomationRule>> getRulesByTriggerType(AutomationTriggerType triggerType) async {
    return _rules.values.where((r) => r.triggerType == triggerType).toList();
  }

  @override
  Future<AutomationRule> updateRule(AutomationRule rule) async {
    _rules[rule.id] = rule;
    return rule;
  }

  @override
  Future<bool> toggleRuleActive(String ruleId) async {
    final rule = _rules[ruleId];
    if (rule != null) {
      _rules[ruleId] = AutomationRule(
        id: rule.id,
        name: rule.name,
        triggerType: rule.triggerType,
        createdAt: rule.createdAt,
        isActive: !rule.isActive,
        description: rule.description,
        workflowId: rule.workflowId,
        condition: rule.condition,
        cronExpression: rule.cronExpression,
        webhookUrl: rule.webhookUrl,
        maxExecutionsPerDay: rule.maxExecutionsPerDay,
      );
      return true;
    }
    return false;
  }

  @override
  Future<bool> deleteRule(String ruleId) async {
    return _rules.remove(ruleId) != null;
  }

  // ---- Event Triggers ----
  @override
  Future<EventTrigger> recordEventTrigger(EventTrigger trigger) async {
    _triggers[trigger.id] = trigger;
    return trigger;
  }

  @override
  Future<EventTrigger?> getEventTriggerById(String triggerId) async => _triggers[triggerId];

  @override
  Future<List<EventTrigger>> getTriggersByAutomationRule(String ruleId) async {
    return _triggers.values.where((t) => t.automationRuleId == ruleId).toList();
  }

  @override
  Future<List<EventTrigger>> getTriggersByStatus(String status) async {
    return _triggers.values.where((t) => t.status == status).toList();
  }

  @override
  Future<List<EventTrigger>> getPendingTriggers() async {
    return _triggers.values.where((t) => t.isPending).toList();
  }

  @override
  Future<bool> markTriggerProcessed(String triggerId, String processInstanceId) async {
    final trigger = _triggers[triggerId];
    if (trigger != null) {
      _triggers[triggerId] = EventTrigger(
        id: trigger.id,
        automationRuleId: trigger.automationRuleId,
        eventType: trigger.eventType,
        createdAt: trigger.createdAt,
        payload: trigger.payload,
        processedAt: DateTime.now(),
        processInstanceId: processInstanceId,
        status: 'processed',
      );
      return true;
    }
    return false;
  }

  @override
  Future<int> getPendingTriggerCount() async {
    return _triggers.values.where((t) => t.isPending).length;
  }

  @override
  Future<List<EventTrigger>> getFailedTriggers(String ruleId) async {
    return _triggers.values.where((t) => t.automationRuleId == ruleId && t.isFailed).toList();
  }

  // ---- Variables ----
  @override
  Future<WorkflowVariable> saveVariable(WorkflowVariable variable) async {
    _variables[variable.id] = variable;
    return variable;
  }

  @override
  Future<WorkflowVariable?> getVariableById(String variableId) async => _variables[variableId];

  @override
  Future<List<WorkflowVariable>> getVariablesByProcess(String processInstanceId) async {
    return _variables.values.where((v) => v.processInstanceId == processInstanceId).toList();
  }

  @override
  Future<WorkflowVariable?> getVariableByName(String processInstanceId, String name) async {
    return _variables.values.cast<WorkflowVariable?>().firstWhere(
        (v) => v?.processInstanceId == processInstanceId && v?.name == name,
        orElse: () => null);
  }

  @override
  Future<bool> updateVariableValue(String variableId, String newValue) async {
    final variable = _variables[variableId];
    if (variable != null) {
      _variables[variableId] = WorkflowVariable(
        id: variable.id,
        processInstanceId: variable.processInstanceId,
        name: variable.name,
        value: newValue,
        type: variable.type,
        createdAt: variable.createdAt,
        updatedAt: DateTime.now(),
        isEncrypted: variable.isEncrypted,
      );
      return true;
    }
    return false;
  }

  @override
  Future<bool> deleteVariable(String variableId) async {
    return _variables.remove(variableId) != null;
  }

  @override
  Future<int> getVariableCount(String processInstanceId) async {
    return _variables.values.where((v) => v.processInstanceId == processInstanceId).length;
  }

  @override
  Future<List<WorkflowVariable>> getEncryptedVariables(String processInstanceId) async {
    return _variables.values
        .where((v) => v.processInstanceId == processInstanceId && v.isEncrypted)
        .toList();
  }

  // ---- Rollback Points ----
  @override
  Future<RollbackPoint> createRollbackPoint(RollbackPoint point) async {
    _rollbackPoints[point.id] = point;
    return point;
  }

  @override
  Future<RollbackPoint?> getRollbackPointById(String pointId) async => _rollbackPoints[pointId];

  @override
  Future<List<RollbackPoint>> getRollbackPointsByProcess(String processInstanceId) async {
    return _rollbackPoints.values.where((p) => p.processInstanceId == processInstanceId).toList();
  }

  @override
  Future<List<RollbackPoint>> getAvailableRollbackPoints(String processInstanceId) async {
    return _rollbackPoints.values
        .where((p) => p.processInstanceId == processInstanceId && p.canRollback)
        .toList();
  }

  @override
  Future<bool> markRollbackPointUsed(String pointId) async {
    final point = _rollbackPoints[pointId];
    if (point != null) {
      _rollbackPoints[pointId] = RollbackPoint(
        id: point.id,
        processInstanceId: point.processInstanceId,
        stepId: point.stepId,
        strategy: point.strategy,
        createdAt: point.createdAt,
        snapshotData: point.snapshotData,
        compensatingAction: point.compensatingAction,
        isUsed: true,
        usedAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }

  @override
  Future<List<RollbackPoint>> getUnusedRollbackPoints(String processInstanceId) async {
    return _rollbackPoints.values
        .where((p) => p.processInstanceId == processInstanceId && !p.isUsed)
        .toList();
  }

  // ---- Execution Logs ----
  @override
  Future<ExecutionLog> recordLog(ExecutionLog log) async {
    _logs[log.id] = log;
    return log;
  }

  @override
  Future<ExecutionLog?> getLogById(String logId) async => _logs[logId];

  @override
  Future<List<ExecutionLog>> getLogsByProcess(String processInstanceId) async {
    return _logs.values.where((l) => l.processInstanceId == processInstanceId).toList();
  }

  @override
  Future<List<ExecutionLog>> getLogsByLevel(String processInstanceId, String level) async {
    return _logs.values.where((l) => l.processInstanceId == processInstanceId && l.level == level).toList();
  }

  @override
  Future<List<ExecutionLog>> getErrorLogs(String processInstanceId) async {
    return _logs.values.where((l) => l.processInstanceId == processInstanceId && l.isError).toList();
  }

  @override
  Future<int> getLogCount(String processInstanceId) async {
    return _logs.values.where((l) => l.processInstanceId == processInstanceId).length;
  }

  @override
  Future<List<ExecutionLog>> getRecentLogs(String processInstanceId, int limit) async {
    final logs = _logs.values.where((l) => l.processInstanceId == processInstanceId).toList();
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs.take(limit).toList();
  }

  @override
  Future<bool> deleteOldLogs(String processInstanceId, Duration olderThan) async {
    final cutoff = DateTime.now().subtract(olderThan);
    final keysToRemove = _logs.entries
        .where((e) => e.value.processInstanceId == processInstanceId && e.value.timestamp.isBefore(cutoff))
        .map((e) => e.key)
        .toList();
    for (final key in keysToRemove) {
      _logs.remove(key);
    }
    return keysToRemove.isNotEmpty;
  }

  // ---- Performance Metrics ----
  @override
  Future<WorkflowPerformanceMetrics> recordMetrics(WorkflowPerformanceMetrics metrics) async {
    _metrics[metrics.id] = metrics;
    return metrics;
  }

  @override
  Future<WorkflowPerformanceMetrics?> getLatestMetrics(String workflowId) async {
    final allMetrics = _metrics.values.where((m) => m.workflowId == workflowId).toList();
    if (allMetrics.isEmpty) return null;
    allMetrics.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return allMetrics.first;
  }

  @override
  Future<List<WorkflowPerformanceMetrics>> getMetricsHistory(String workflowId, Duration period) async {
    final cutoff = DateTime.now().subtract(period);
    return _metrics.values
        .where((m) => m.workflowId == workflowId && m.timestamp.isAfter(cutoff))
        .toList();
  }

  @override
  Future<double> getWorkflowSuccessRate(String workflowId) async {
    final metrics = await getLatestMetrics(workflowId);
    return metrics?.actualSuccessRate ?? 0;
  }

  @override
  Future<double> getWorkflowAverageExecutionTime(String workflowId) async {
    final metrics = await getLatestMetrics(workflowId);
    return metrics?.averageExecutionTimeMs ?? 0;
  }

  @override
  Future<List<String>> getUnhealthyWorkflows() async {
    final allMetrics = _metrics.values.toList();
    final unhealthy = <String>{};
    for (final metric in allMetrics) {
      if (metric.isCritical) {
        unhealthy.add(metric.workflowId);
      }
    }
    return unhealthy.toList();
  }
}

// ============================================================================
// ENGINES (5 total)
// ============================================================================

/// WorkflowExecutionEngine: Manages workflow execution
class WorkflowExecutionEngine {
  final WorkflowRepository repository;

  WorkflowExecutionEngine(this.repository);

  Future<ProcessInstance> startWorkflow(String workflowId, String userId) async {
    final instance = ProcessInstance(
      id: 'proc_${DateTime.now().millisecondsSinceEpoch}',
      workflowId: workflowId,
      status: ProcessState.running,
      startedAt: DateTime.now(),
      createdAt: DateTime.now(),
      initiatedBy: userId,
    );
    return await repository.createProcessInstance(instance);
  }

  Future<bool> completeProcess(String processInstanceId) async {
    final instance = await repository.getProcessInstanceById(processInstanceId);
    if (instance != null) {
      await repository.updateProcessInstance(instance.copyWith(
        status: ProcessState.completed,
        completedAt: DateTime.now(),
      ));
      return true;
    }
    return false;
  }

  Future<int> getRunningWorkflowCount() async {
    return await repository.getRunningProcessCount();
  }
}

/// StepExecutionEngine: Manages individual step execution
class StepExecutionEngine {
  final WorkflowRepository repository;

  StepExecutionEngine(this.repository);

  Future<StepExecution> executeStep(String processInstanceId, String stepId) async {
    final execution = StepExecution(
      id: 'step_${DateTime.now().millisecondsSinceEpoch}',
      processInstanceId: processInstanceId,
      stepId: stepId,
      status: StepStatus.running,
      startedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
    return await repository.createStepExecution(execution);
  }

  Future<bool> failStep(String executionId, String errorMessage) async {
    final execution = await repository.getStepExecutionById(executionId);
    if (execution != null) {
      await repository.updateStepExecution(
        StepExecution(
          id: execution.id,
          processInstanceId: execution.processInstanceId,
          stepId: execution.stepId,
          status: StepStatus.failed,
          startedAt: execution.startedAt,
          createdAt: execution.createdAt,
          completedAt: DateTime.now(),
          errorMessage: errorMessage,
          executionTimeMs: DateTime.now().difference(execution.startedAt).inMilliseconds,
          attemptNumber: execution.attemptNumber,
        ),
      );
      return true;
    }
    return false;
  }

  Future<double> getAverageStepTime(String stepId) async {
    return await repository.getAverageStepExecutionTime(stepId);
  }
}

/// TransitionEngine: Manages workflow transitions
class TransitionEngine {
  final WorkflowRepository repository;

  TransitionEngine(this.repository);

  Future<List<WorkflowTransition>> getNextSteps(String stepId) async {
    return await repository.getTransitionsFromStep(stepId);
  }

  Future<bool> evaluateTransition(WorkflowTransition transition, Map<String, dynamic> variables) async {
    if (transition.condition == null) return true;
    // Simplified condition evaluation
    return true;
  }

  Future<int> getTransitionCount(String workflowId) async {
    final transitions = await repository.getTransitionsByWorkflow(workflowId);
    return transitions.length;
  }
}

/// AutomationEngine: Manages automation rules and triggers
class AutomationEngine {
  final WorkflowRepository repository;

  AutomationEngine(this.repository);

  Future<List<AutomationRule>> getApplicableRules(AutomationTriggerType triggerType) async {
    return await repository.getRulesByTriggerType(triggerType);
  }

  Future<bool> processEventTrigger(EventTrigger trigger) async {
    return await repository.markTriggerProcessed(trigger.id, '');
  }

  Future<int> getPendingAutomationCount() async {
    return await repository.getPendingTriggerCount();
  }
}

/// RollbackEngine: Manages rollback and recovery
class RollbackEngine {
  final WorkflowRepository repository;

  RollbackEngine(this.repository);

  Future<bool> rollbackProcess(String processInstanceId, String pointId) async {
    final point = await repository.getRollbackPointById(pointId);
    if (point != null && point.canRollback) {
      await repository.markRollbackPointUsed(pointId);
      return true;
    }
    return false;
  }

  Future<List<RollbackPoint>> getRecoveryOptions(String processInstanceId) async {
    return await repository.getAvailableRollbackPoints(processInstanceId);
  }

  Future<int> getAvailableRollbackCount(String processInstanceId) async {
    final points = await repository.getAvailableRollbackPoints(processInstanceId);
    return points.length;
  }
}

// ============================================================================
// MANAGER
// ============================================================================

/// WorkflowOrchestrationManager: Coordinates all engines
class WorkflowOrchestrationManager {
  final WorkflowRepository repository;
  final WorkflowExecutionEngine executionEngine;
  final StepExecutionEngine stepEngine;
  final TransitionEngine transitionEngine;
  final AutomationEngine automationEngine;
  final RollbackEngine rollbackEngine;

  WorkflowOrchestrationManager(
    this.repository, {
    WorkflowExecutionEngine? executionEngine,
    StepExecutionEngine? stepEngine,
    TransitionEngine? transitionEngine,
    AutomationEngine? automationEngine,
    RollbackEngine? rollbackEngine,
  })  : executionEngine = executionEngine ?? WorkflowExecutionEngine(repository),
        stepEngine = stepEngine ?? StepExecutionEngine(repository),
        transitionEngine = transitionEngine ?? TransitionEngine(repository),
        automationEngine = automationEngine ?? AutomationEngine(repository),
        rollbackEngine = rollbackEngine ?? RollbackEngine(repository);
}

// ============================================================================
// FACADE (Public API)
// ============================================================================

class WorkflowOrchestrationFacade {
  final WorkflowOrchestrationManager manager;

  WorkflowOrchestrationFacade(this.manager);

  Future<Workflow> createWorkflow(String name, String description) async {
    final workflow = Workflow(
      id: 'wf_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      status: WorkflowStatus.draft,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: description,
    );
    return await manager.repository.createWorkflow(workflow);
  }

  Future<ProcessInstance> startWorkflowExecution(String workflowId, String userId) async {
    return await manager.executionEngine.startWorkflow(workflowId, userId);
  }

  Future<int> getActiveWorkflowCount() async {
    return await manager.repository.getActiveWorkflowCount();
  }

  Future<int> getRunningProcessCount() async {
    return await manager.repository.getRunningProcessCount();
  }

  Future<double> getWorkflowSuccessRate(String workflowId) async {
    return await manager.repository.getWorkflowSuccessRate(workflowId);
  }

  Future<List<String>> getUnhealthyWorkflows() async {
    return await manager.repository.getUnhealthyWorkflows();
  }

  Future<int> getTotalAutomationRules() async {
    final rules = await manager.repository.getAllRules();
    return rules.length;
  }

  Future<int> getActiveAutomationRuleCount() async {
    final rules = await manager.repository.getActiveRules();
    return rules.length;
  }
}
