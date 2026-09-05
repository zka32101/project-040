import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/workflow_orchestration_models.dart';
import 'package:project_040/services/workflow_orchestration_service.dart';

void main() {
  late WorkflowRepository repository;
  late WorkflowOrchestrationManager manager;
  late WorkflowOrchestrationFacade facade;

  setUp(() {
    repository = InMemoryWorkflowRepository();
    manager = WorkflowOrchestrationManager(repository);
    facade = WorkflowOrchestrationFacade(manager);
  });

  // ============================================================================
  // ENUM TESTS (6)
  // ============================================================================

  group('Enum Tests', () {
    test('WorkflowStatus has 7 values', () {
      expect(WorkflowStatus.values.length, equals(7));
      expect(WorkflowStatus.active.displayName, equals('アクティブ'));
    });

    test('ProcessState has 7 values', () {
      expect(ProcessState.values.length, equals(7));
      expect(ProcessState.running.displayName, equals('実行中'));
    });

    test('StepStatus has 6 values', () {
      expect(StepStatus.values.length, equals(6));
      expect(StepStatus.completed.displayName, equals('完了'));
    });

    test('TransitionType has 5 values', () {
      expect(TransitionType.values.length, equals(5));
      expect(TransitionType.parallel.displayName, equals('並列実行'));
    });

    test('AutomationTriggerType has 6 values', () {
      expect(AutomationTriggerType.values.length, equals(6));
      expect(AutomationTriggerType.eventBased.displayName, equals('イベント駆動'));
    });

    test('RollbackStrategy has 5 values', () {
      expect(RollbackStrategy.values.length, equals(5));
      expect(RollbackStrategy.snapshot.displayName, equals('スナップショット'));
    });
  });

  // ============================================================================
  // MODEL TESTS (12)
  // ============================================================================

  group('Model Tests', () {
    test('Workflow model with defaults', () {
      final workflow = Workflow(
        id: 'wf1',
        name: 'Test Workflow',
        status: WorkflowStatus.active,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(workflow.isActive, isTrue);
      expect(workflow.isPublished, isFalse);
      expect(workflow.ageInDays, greaterThan(0));
    });

    test('Workflow copyWith method', () {
      final workflow = Workflow(
        id: 'wf1',
        name: 'Test',
        status: WorkflowStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = workflow.copyWith(status: WorkflowStatus.active, isPublished: true);
      expect(updated.isActive, isTrue);
      expect(updated.isPublished, isTrue);
    });

    test('WorkflowStep with retry tracking', () {
      final step = WorkflowStep(
        id: 's1',
        workflowId: 'wf1',
        name: 'Step 1',
        stepOrder: 1,
        createdAt: DateTime.now(),
        retryCount: 3,
        timeoutSeconds: 300,
      );

      expect(step.hasRetry, isTrue);
      expect(step.hasTimeout, isTrue);
    });

    test('ProcessInstance status tracking', () {
      final process = ProcessInstance(
        id: 'p1',
        workflowId: 'wf1',
        status: ProcessState.running,
        startedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(process.isActive, isTrue);
      expect(process.isCompleted, isFalse);
    });

    test('StepExecution timing', () {
      final exec = StepExecution(
        id: 'se1',
        processInstanceId: 'p1',
        stepId: 's1',
        status: StepStatus.completed,
        startedAt: DateTime.now().subtract(const Duration(seconds: 10)),
        createdAt: DateTime.now(),
      );

      expect(exec.isCompleted, isTrue);
      expect(exec.executionTimeMs, equals(0));
    });

    test('WorkflowTransition conditional check', () {
      final transition = WorkflowTransition(
        id: 't1',
        workflowId: 'wf1',
        fromStepId: 's1',
        toStepId: 's2',
        transitionType: TransitionType.conditional,
        createdAt: DateTime.now(),
        condition: 'status == success',
      );

      expect(transition.isConditional, isTrue);
      expect(transition.isSequential, isFalse);
    });

    test('ProcessHistory state change', () {
      final history = ProcessHistory(
        id: 'h1',
        processInstanceId: 'p1',
        eventType: 'state_change',
        timestamp: DateTime.now(),
        previousState: 'pending',
        newState: 'running',
      );

      expect(history.isStateChange, isTrue);
    });

    test('AutomationRule scheduling', () {
      final rule = AutomationRule(
        id: 'ar1',
        name: 'Daily Process',
        triggerType: AutomationTriggerType.scheduled,
        createdAt: DateTime.now(),
        isActive: true,
        cronExpression: '0 0 * * *',
      );

      expect(rule.isScheduled, isTrue);
      expect(rule.isActive, isTrue);
    });

    test('EventTrigger lifecycle', () {
      final trigger = EventTrigger(
        id: 'et1',
        automationRuleId: 'ar1',
        eventType: 'order_created',
        createdAt: DateTime.now(),
      );

      expect(trigger.isPending, isTrue);
      expect(trigger.isProcessed, isFalse);
    });

    test('WorkflowVariable encryption', () {
      final variable = WorkflowVariable(
        id: 'v1',
        processInstanceId: 'p1',
        name: 'api_key',
        value: 'secret',
        type: 'string',
        createdAt: DateTime.now(),
        isEncrypted: true,
      );

      expect(variable.isEncrypted, isTrue);
      expect(variable.isString, isTrue);
    });

    test('RollbackPoint strategies', () {
      final point = RollbackPoint(
        id: 'rp1',
        processInstanceId: 'p1',
        stepId: 's1',
        strategy: RollbackStrategy.snapshot,
        createdAt: DateTime.now(),
        snapshotData: '{}',
      );

      expect(point.isSnapshot, isTrue);
      expect(point.canRollback, isTrue);
    });

    test('WorkflowPerformanceMetrics health', () {
      final metrics = WorkflowPerformanceMetrics(
        id: 'm1',
        workflowId: 'wf1',
        timestamp: DateTime.now(),
        totalExecutions: 100,
        successfulExecutions: 95,
        failedExecutions: 5,
        averageExecutionTimeMs: 500,
        successRate: 95.0,
      );

      expect(metrics.isHealthy, isTrue);
      expect(metrics.actualSuccessRate, equals(95));
    });
  });

  // ============================================================================
  // REPOSITORY TESTS (40+)
  // ============================================================================

  group('Repository: Workflow Management', () {
    test('createWorkflow and getWorkflowById', () async {
      final workflow = Workflow(
        id: 'wf1',
        name: 'Test Flow',
        status: WorkflowStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createWorkflow(workflow);
      final retrieved = await repository.getWorkflowById('wf1');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Test Flow'));
    });

    test('getAllWorkflows with pagination', () async {
      for (int i = 0; i < 5; i++) {
        await repository.createWorkflow(Workflow(
          id: 'wf$i',
          name: 'WF$i',
          status: WorkflowStatus.draft,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      final result = await repository.getAllWorkflows(limit: 3);
      expect(result.length, lessThanOrEqualTo(3));
    });

    test('getWorkflowsByStatus', () async {
      final workflow = Workflow(
        id: 'wf1',
        name: 'Active WF',
        status: WorkflowStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createWorkflow(workflow);
      final active = await repository.getWorkflowsByStatus(WorkflowStatus.active);

      expect(active.isNotEmpty, isTrue);
    });

    test('updateWorkflow', () async {
      var workflow = Workflow(
        id: 'wf1',
        name: 'WF1',
        status: WorkflowStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createWorkflow(workflow);
      workflow = workflow.copyWith(status: WorkflowStatus.active);
      await repository.updateWorkflow(workflow);

      final updated = await repository.getWorkflowById('wf1');
      expect(updated!.status, equals(WorkflowStatus.active));
    });

    test('publishWorkflow', () async {
      final workflow = Workflow(
        id: 'wf1',
        name: 'WF1',
        status: WorkflowStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isPublished: false,
      );

      await repository.createWorkflow(workflow);
      await repository.publishWorkflow('wf1');

      final published = await repository.getWorkflowById('wf1');
      expect(published!.isPublished, isTrue);
    });

    test('getWorkflowCount', () async {
      for (int i = 0; i < 3; i++) {
        await repository.createWorkflow(Workflow(
          id: 'wf$i',
          name: 'WF$i',
          status: WorkflowStatus.draft,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      final count = await repository.getWorkflowCount();
      expect(count, equals(3));
    });

    test('getActiveWorkflowCount', () async {
      for (int i = 0; i < 2; i++) {
        await repository.createWorkflow(Workflow(
          id: 'wf$i',
          name: 'WF$i',
          status: WorkflowStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      final count = await repository.getActiveWorkflowCount();
      expect(count, equals(2));
    });

    test('searchWorkflows', () async {
      final workflow = Workflow(
        id: 'wf1',
        name: 'Order Processing Workflow',
        status: WorkflowStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: 'Processes customer orders',
      );

      await repository.createWorkflow(workflow);
      final results = await repository.searchWorkflows('order');

      expect(results.isNotEmpty, isTrue);
    });
  });

  group('Repository: Workflow Steps', () {
    test('createStep and getStepById', () async {
      final step = WorkflowStep(
        id: 's1',
        workflowId: 'wf1',
        name: 'Validate',
        stepOrder: 1,
        createdAt: DateTime.now(),
      );

      await repository.createStep(step);
      final retrieved = await repository.getStepById('s1');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Validate'));
    });

    test('getStepsByWorkflow', () async {
      for (int i = 0; i < 3; i++) {
        await repository.createStep(WorkflowStep(
          id: 's$i',
          workflowId: 'wf1',
          name: 'Step$i',
          stepOrder: i,
          createdAt: DateTime.now(),
        ));
      }

      final steps = await repository.getStepsByWorkflow('wf1');
      expect(steps.length, equals(3));
    });

    test('getStepsByOrder maintains order', () async {
      for (int i = 0; i < 3; i++) {
        await repository.createStep(WorkflowStep(
          id: 's$i',
          workflowId: 'wf1',
          name: 'Step$i',
          stepOrder: i,
          createdAt: DateTime.now(),
        ));
      }

      final steps = await repository.getStepsByOrder('wf1');
      expect(steps[0].stepOrder, lessThanOrEqualTo(steps[1].stepOrder));
    });

    test('getStepCountByWorkflow', () async {
      for (int i = 0; i < 5; i++) {
        await repository.createStep(WorkflowStep(
          id: 's$i',
          workflowId: 'wf1',
          name: 'Step$i',
          stepOrder: i,
          createdAt: DateTime.now(),
        ));
      }

      final count = await repository.getStepCountByWorkflow('wf1');
      expect(count, equals(5));
    });

    test('getStepsWithRetry', () async {
      await repository.createStep(WorkflowStep(
        id: 's1',
        workflowId: 'wf1',
        name: 'Step1',
        stepOrder: 1,
        createdAt: DateTime.now(),
        retryCount: 3,
      ));

      final retrySteps = await repository.getStepsWithRetry('wf1');
      expect(retrySteps.isNotEmpty, isTrue);
    });
  });

  group('Repository: Process Instances', () {
    test('createProcessInstance and getProcessInstanceById', () async {
      final instance = ProcessInstance(
        id: 'p1',
        workflowId: 'wf1',
        status: ProcessState.running,
        startedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await repository.createProcessInstance(instance);
      final retrieved = await repository.getProcessInstanceById('p1');

      expect(retrieved, isNotNull);
      expect(retrieved!.status, equals(ProcessState.running));
    });

    test('getProcessInstancesByWorkflow', () async {
      for (int i = 0; i < 3; i++) {
        await repository.createProcessInstance(ProcessInstance(
          id: 'p$i',
          workflowId: 'wf1',
          status: ProcessState.running,
          startedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ));
      }

      final instances = await repository.getProcessInstancesByWorkflow('wf1');
      expect(instances.length, equals(3));
    });

    test('getProcessInstancesByStatus', () async {
      for (int i = 0; i < 2; i++) {
        await repository.createProcessInstance(ProcessInstance(
          id: 'p$i',
          workflowId: 'wf1',
          status: ProcessState.completed,
          startedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ));
      }

      final completed = await repository.getProcessInstancesByStatus(ProcessState.completed);
      expect(completed.length, equals(2));
    });

    test('getActiveProcessInstances', () async {
      await repository.createProcessInstance(ProcessInstance(
        id: 'p1',
        workflowId: 'wf1',
        status: ProcessState.running,
        startedAt: DateTime.now(),
        createdAt: DateTime.now(),
      ));

      final active = await repository.getActiveProcessInstances();
      expect(active.isNotEmpty, isTrue);
    });

    test('getRunningProcessCount', () async {
      for (int i = 0; i < 3; i++) {
        await repository.createProcessInstance(ProcessInstance(
          id: 'p$i',
          workflowId: 'wf1',
          status: ProcessState.running,
          startedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ));
      }

      final count = await repository.getRunningProcessCount();
      expect(count, equals(3));
    });

    test('getFailedProcesses', () async {
      await repository.createProcessInstance(ProcessInstance(
        id: 'p1',
        workflowId: 'wf1',
        status: ProcessState.failed,
        startedAt: DateTime.now(),
        createdAt: DateTime.now(),
      ));

      final failed = await repository.getFailedProcesses('wf1');
      expect(failed.isNotEmpty, isTrue);
    });

    test('getAverageProcessDuration', () async {
      await repository.createProcessInstance(ProcessInstance(
        id: 'p1',
        workflowId: 'wf1',
        status: ProcessState.completed,
        startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      ));

      final duration = await repository.getAverageProcessDuration('wf1');
      expect(duration, greaterThan(0));
    });
  });

  group('Repository: Step Executions', () {
    test('createStepExecution and getStepExecutionById', () async {
      final execution = StepExecution(
        id: 'se1',
        processInstanceId: 'p1',
        stepId: 's1',
        status: StepStatus.running,
        startedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await repository.createStepExecution(execution);
      final retrieved = await repository.getStepExecutionById('se1');

      expect(retrieved, isNotNull);
      expect(retrieved!.status, equals(StepStatus.running));
    });

    test('getExecutionsByProcessInstance', () async {
      for (int i = 0; i < 3; i++) {
        await repository.createStepExecution(StepExecution(
          id: 'se$i',
          processInstanceId: 'p1',
          stepId: 's$i',
          status: StepStatus.completed,
          startedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ));
      }

      final executions = await repository.getExecutionsByProcessInstance('p1');
      expect(executions.length, equals(3));
    });

    test('getFailedStepExecutions', () async {
      await repository.createStepExecution(StepExecution(
        id: 'se1',
        processInstanceId: 'p1',
        stepId: 's1',
        status: StepStatus.failed,
        startedAt: DateTime.now(),
        createdAt: DateTime.now(),
        errorMessage: 'Test error',
      ));

      final failed = await repository.getFailedStepExecutions('p1');
      expect(failed.isNotEmpty, isTrue);
    });

    test('getSlowSteps', () async {
      await repository.createStepExecution(StepExecution(
        id: 'se1',
        processInstanceId: 'p1',
        stepId: 's1',
        status: StepStatus.completed,
        startedAt: DateTime.now(),
        createdAt: DateTime.now(),
        executionTimeMs: 10000,
      ));

      final slow = await repository.getSlowSteps(5000);
      expect(slow.isNotEmpty, isTrue);
    });
  });

  group('Repository: Transitions', () {
    test('createTransition and getTransitionById', () async {
      final transition = WorkflowTransition(
        id: 't1',
        workflowId: 'wf1',
        fromStepId: 's1',
        toStepId: 's2',
        transitionType: TransitionType.sequential,
        createdAt: DateTime.now(),
      );

      await repository.createTransition(transition);
      final retrieved = await repository.getTransitionById('t1');

      expect(retrieved, isNotNull);
    });

    test('getTransitionsFromStep', () async {
      for (int i = 0; i < 2; i++) {
        await repository.createTransition(WorkflowTransition(
          id: 't$i',
          workflowId: 'wf1',
          fromStepId: 's1',
          toStepId: 's${i + 2}',
          transitionType: TransitionType.parallel,
          createdAt: DateTime.now(),
        ));
      }

      final transitions = await repository.getTransitionsFromStep('s1');
      expect(transitions.length, equals(2));
    });

    test('getConditionalTransitions', () async {
      await repository.createTransition(WorkflowTransition(
        id: 't1',
        workflowId: 'wf1',
        fromStepId: 's1',
        toStepId: 's2',
        transitionType: TransitionType.conditional,
        createdAt: DateTime.now(),
        condition: 'status == ok',
      ));

      final conditional = await repository.getConditionalTransitions('wf1');
      expect(conditional.isNotEmpty, isTrue);
    });

    test('getParallelTransitions', () async {
      await repository.createTransition(WorkflowTransition(
        id: 't1',
        workflowId: 'wf1',
        fromStepId: 's1',
        toStepId: 's2',
        transitionType: TransitionType.parallel,
        createdAt: DateTime.now(),
      ));

      final parallel = await repository.getParallelTransitions('wf1');
      expect(parallel.isNotEmpty, isTrue);
    });
  });

  group('Repository: Process History', () {
    test('recordEvent and getEventById', () async {
      final event = ProcessHistory(
        id: 'h1',
        processInstanceId: 'p1',
        eventType: 'step_completed',
        timestamp: DateTime.now(),
      );

      await repository.recordEvent(event);
      final retrieved = await repository.getEventById('h1');

      expect(retrieved, isNotNull);
    });

    test('getHistoryByProcess', () async {
      for (int i = 0; i < 3; i++) {
        await repository.recordEvent(ProcessHistory(
          id: 'h$i',
          processInstanceId: 'p1',
          eventType: 'event$i',
          timestamp: DateTime.now(),
        ));
      }

      final history = await repository.getHistoryByProcess('p1');
      expect(history.length, equals(3));
    });

    test('getStateChangeHistory', () async {
      await repository.recordEvent(ProcessHistory(
        id: 'h1',
        processInstanceId: 'p1',
        eventType: 'state_change',
        timestamp: DateTime.now(),
        previousState: 'pending',
        newState: 'running',
      ));

      final stateChanges = await repository.getStateChangeHistory('p1');
      expect(stateChanges.isNotEmpty, isTrue);
    });

    test('getEventCount', () async {
      for (int i = 0; i < 5; i++) {
        await repository.recordEvent(ProcessHistory(
          id: 'h$i',
          processInstanceId: 'p1',
          eventType: 'event',
          timestamp: DateTime.now(),
        ));
      }

      final count = await repository.getEventCount('p1');
      expect(count, equals(5));
    });
  });

  group('Repository: Automation Rules', () {
    test('createRule and getRuleById', () async {
      final rule = AutomationRule(
        id: 'ar1',
        name: 'Auto Process',
        triggerType: AutomationTriggerType.scheduled,
        createdAt: DateTime.now(),
        isActive: true,
        cronExpression: '0 0 * * *',
      );

      await repository.createRule(rule);
      final retrieved = await repository.getRuleById('ar1');

      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Auto Process'));
    });

    test('getActiveRules', () async {
      for (int i = 0; i < 2; i++) {
        await repository.createRule(AutomationRule(
          id: 'ar$i',
          name: 'Rule$i',
          triggerType: AutomationTriggerType.eventBased,
          createdAt: DateTime.now(),
          isActive: true,
        ));
      }

      final active = await repository.getActiveRules();
      expect(active.length, equals(2));
    });

    test('getRulesByTriggerType', () async {
      await repository.createRule(AutomationRule(
        id: 'ar1',
        name: 'Webhook Rule',
        triggerType: AutomationTriggerType.webhook,
        createdAt: DateTime.now(),
        isActive: true,
      ));

      final webhooks = await repository.getRulesByTriggerType(AutomationTriggerType.webhook);
      expect(webhooks.isNotEmpty, isTrue);
    });

    test('toggleRuleActive', () async {
      final rule = AutomationRule(
        id: 'ar1',
        name: 'Rule1',
        triggerType: AutomationTriggerType.manual,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await repository.createRule(rule);
      await repository.toggleRuleActive('ar1');

      final toggled = await repository.getRuleById('ar1');
      expect(toggled!.isActive, isFalse);
    });
  });

  group('Repository: Event Triggers', () {
    test('recordEventTrigger and getEventTriggerById', () async {
      final trigger = EventTrigger(
        id: 'et1',
        automationRuleId: 'ar1',
        eventType: 'order_created',
        createdAt: DateTime.now(),
      );

      await repository.recordEventTrigger(trigger);
      final retrieved = await repository.getEventTriggerById('et1');

      expect(retrieved, isNotNull);
      expect(retrieved!.status, equals('pending'));
    });

    test('getPendingTriggers', () async {
      for (int i = 0; i < 3; i++) {
        await repository.recordEventTrigger(EventTrigger(
          id: 'et$i',
          automationRuleId: 'ar1',
          eventType: 'event$i',
          createdAt: DateTime.now(),
          status: 'pending',
        ));
      }

      final pending = await repository.getPendingTriggers();
      expect(pending.length, equals(3));
    });

    test('getPendingTriggerCount', () async {
      for (int i = 0; i < 5; i++) {
        await repository.recordEventTrigger(EventTrigger(
          id: 'et$i',
          automationRuleId: 'ar1',
          eventType: 'event',
          createdAt: DateTime.now(),
          status: 'pending',
        ));
      }

      final count = await repository.getPendingTriggerCount();
      expect(count, equals(5));
    });
  });

  group('Repository: Variables', () {
    test('saveVariable and getVariableById', () async {
      final variable = WorkflowVariable(
        id: 'v1',
        processInstanceId: 'p1',
        name: 'user_id',
        value: '123',
        type: 'string',
        createdAt: DateTime.now(),
      );

      await repository.saveVariable(variable);
      final retrieved = await repository.getVariableById('v1');

      expect(retrieved, isNotNull);
      expect(retrieved!.value, equals('123'));
    });

    test('getVariableByName', () async {
      final variable = WorkflowVariable(
        id: 'v1',
        processInstanceId: 'p1',
        name: 'api_key',
        value: 'secret123',
        type: 'string',
        createdAt: DateTime.now(),
      );

      await repository.saveVariable(variable);
      final found = await repository.getVariableByName('p1', 'api_key');

      expect(found, isNotNull);
    });

    test('getEncryptedVariables', () async {
      await repository.saveVariable(WorkflowVariable(
        id: 'v1',
        processInstanceId: 'p1',
        name: 'password',
        value: 'encrypted',
        type: 'string',
        createdAt: DateTime.now(),
        isEncrypted: true,
      ));

      final encrypted = await repository.getEncryptedVariables('p1');
      expect(encrypted.isNotEmpty, isTrue);
    });
  });

  group('Repository: Rollback Points', () {
    test('createRollbackPoint and getRollbackPointById', () async {
      final point = RollbackPoint(
        id: 'rp1',
        processInstanceId: 'p1',
        stepId: 's1',
        strategy: RollbackStrategy.snapshot,
        createdAt: DateTime.now(),
        snapshotData: '{}',
      );

      await repository.createRollbackPoint(point);
      final retrieved = await repository.getRollbackPointById('rp1');

      expect(retrieved, isNotNull);
    });

    test('getAvailableRollbackPoints', () async {
      await repository.createRollbackPoint(RollbackPoint(
        id: 'rp1',
        processInstanceId: 'p1',
        stepId: 's1',
        strategy: RollbackStrategy.compensating,
        createdAt: DateTime.now(),
        compensatingAction: 'undo',
      ));

      final available = await repository.getAvailableRollbackPoints('p1');
      expect(available.isNotEmpty, isTrue);
    });

    test('markRollbackPointUsed', () async {
      final point = RollbackPoint(
        id: 'rp1',
        processInstanceId: 'p1',
        stepId: 's1',
        strategy: RollbackStrategy.snapshot,
        createdAt: DateTime.now(),
        snapshotData: '{}',
        isUsed: false,
      );

      await repository.createRollbackPoint(point);
      await repository.markRollbackPointUsed('rp1');

      final marked = await repository.getRollbackPointById('rp1');
      expect(marked!.isUsed, isTrue);
    });
  });

  group('Repository: Execution Logs', () {
    test('recordLog and getLogById', () async {
      final log = ExecutionLog(
        id: 'l1',
        processInstanceId: 'p1',
        timestamp: DateTime.now(),
        level: 'INFO',
        message: 'Process started',
      );

      await repository.recordLog(log);
      final retrieved = await repository.getLogById('l1');

      expect(retrieved, isNotNull);
      expect(retrieved!.isInfo, isTrue);
    });

    test('getErrorLogs', () async {
      await repository.recordLog(ExecutionLog(
        id: 'l1',
        processInstanceId: 'p1',
        timestamp: DateTime.now(),
        level: 'ERROR',
        message: 'Something failed',
      ));

      final errors = await repository.getErrorLogs('p1');
      expect(errors.isNotEmpty, isTrue);
    });

    test('getLogsByLevel', () async {
      for (int i = 0; i < 3; i++) {
        await repository.recordLog(ExecutionLog(
          id: 'l$i',
          processInstanceId: 'p1',
          timestamp: DateTime.now(),
          level: 'WARNING',
          message: 'Warning $i',
        ));
      }

      final warnings = await repository.getLogsByLevel('p1', 'WARNING');
      expect(warnings.length, equals(3));
    });

    test('getRecentLogs', () async {
      for (int i = 0; i < 10; i++) {
        await repository.recordLog(ExecutionLog(
          id: 'l$i',
          processInstanceId: 'p1',
          timestamp: DateTime.now(),
          level: 'INFO',
          message: 'Log $i',
        ));
      }

      final recent = await repository.getRecentLogs('p1', 5);
      expect(recent.length, lessThanOrEqualTo(5));
    });
  });

  group('Repository: Performance Metrics', () {
    test('recordMetrics and getLatestMetrics', () async {
      final metrics = WorkflowPerformanceMetrics(
        id: 'm1',
        workflowId: 'wf1',
        timestamp: DateTime.now(),
        totalExecutions: 100,
        successfulExecutions: 95,
        failedExecutions: 5,
        averageExecutionTimeMs: 500,
      );

      await repository.recordMetrics(metrics);
      final latest = await repository.getLatestMetrics('wf1');

      expect(latest, isNotNull);
      expect(latest!.totalExecutions, equals(100));
    });

    test('getWorkflowSuccessRate', () async {
      await repository.recordMetrics(WorkflowPerformanceMetrics(
        id: 'm1',
        workflowId: 'wf1',
        timestamp: DateTime.now(),
        totalExecutions: 100,
        successfulExecutions: 90,
        failedExecutions: 10,
        averageExecutionTimeMs: 400,
      ));

      final rate = await repository.getWorkflowSuccessRate('wf1');
      expect(rate, equals(90));
    });

    test('getUnhealthyWorkflows', () async {
      await repository.recordMetrics(WorkflowPerformanceMetrics(
        id: 'm1',
        workflowId: 'wf1',
        timestamp: DateTime.now(),
        totalExecutions: 100,
        successfulExecutions: 50,
        failedExecutions: 50,
        averageExecutionTimeMs: 1000,
      ));

      final unhealthy = await repository.getUnhealthyWorkflows();
      expect(unhealthy.isNotEmpty, isTrue);
    });
  });

  // ============================================================================
  // ENGINE TESTS (5)
  // ============================================================================

  group('Engine: WorkflowExecutionEngine', () {
    test('startWorkflow creates process instance', () async {
      final instance = await manager.executionEngine.startWorkflow('wf1', 'user1');

      expect(instance.workflowId, equals('wf1'));
      expect(instance.status, equals(ProcessState.running));
      expect(instance.initiatedBy, equals('user1'));
    });

    test('completeProcess updates status', () async {
      final instance = await repository.createProcessInstance(ProcessInstance(
        id: 'p1',
        workflowId: 'wf1',
        status: ProcessState.running,
        startedAt: DateTime.now(),
        createdAt: DateTime.now(),
      ));

      await manager.executionEngine.completeProcess('p1');

      final completed = await repository.getProcessInstanceById('p1');
      expect(completed!.status, equals(ProcessState.completed));
    });

    test('getRunningWorkflowCount', () async {
      for (int i = 0; i < 3; i++) {
        await repository.createProcessInstance(ProcessInstance(
          id: 'p$i',
          workflowId: 'wf1',
          status: ProcessState.running,
          startedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ));
      }

      final count = await manager.executionEngine.getRunningWorkflowCount();
      expect(count, equals(3));
    });
  });

  group('Engine: StepExecutionEngine', () {
    test('executeStep creates step execution', () async {
      final exec = await manager.stepEngine.executeStep('p1', 's1');

      expect(exec.processInstanceId, equals('p1'));
      expect(exec.stepId, equals('s1'));
      expect(exec.status, equals(StepStatus.running));
    });

    test('failStep marks step as failed', () async {
      final exec = await repository.createStepExecution(StepExecution(
        id: 'se1',
        processInstanceId: 'p1',
        stepId: 's1',
        status: StepStatus.running,
        startedAt: DateTime.now(),
        createdAt: DateTime.now(),
      ));

      await manager.stepEngine.failStep('se1', 'Connection timeout');

      final failed = await repository.getStepExecutionById('se1');
      expect(failed!.isFailed, isTrue);
      expect(failed.errorMessage, equals('Connection timeout'));
    });
  });

  group('Engine: TransitionEngine', () {
    test('getNextSteps', () async {
      for (int i = 0; i < 2; i++) {
        await repository.createTransition(WorkflowTransition(
          id: 't$i',
          workflowId: 'wf1',
          fromStepId: 's1',
          toStepId: 's${i + 2}',
          transitionType: TransitionType.sequential,
          createdAt: DateTime.now(),
        ));
      }

      final next = await manager.transitionEngine.getNextSteps('s1');
      expect(next.length, equals(2));
    });
  });

  group('Engine: AutomationEngine', () {
    test('getApplicableRules', () async {
      await repository.createRule(AutomationRule(
        id: 'ar1',
        name: 'Event Rule',
        triggerType: AutomationTriggerType.eventBased,
        createdAt: DateTime.now(),
        isActive: true,
      ));

      final rules = await manager.automationEngine.getApplicableRules(AutomationTriggerType.eventBased);
      expect(rules.isNotEmpty, isTrue);
    });

    test('getPendingAutomationCount', () async {
      for (int i = 0; i < 3; i++) {
        await repository.recordEventTrigger(EventTrigger(
          id: 'et$i',
          automationRuleId: 'ar1',
          eventType: 'event',
          createdAt: DateTime.now(),
          status: 'pending',
        ));
      }

      final count = await manager.automationEngine.getPendingAutomationCount();
      expect(count, equals(3));
    });
  });

  group('Engine: RollbackEngine', () {
    test('getRecoveryOptions', () async {
      await repository.createRollbackPoint(RollbackPoint(
        id: 'rp1',
        processInstanceId: 'p1',
        stepId: 's1',
        strategy: RollbackStrategy.snapshot,
        createdAt: DateTime.now(),
        snapshotData: '{}',
      ));

      final options = await manager.rollbackEngine.getRecoveryOptions('p1');
      expect(options.isNotEmpty, isTrue);
    });

    test('getAvailableRollbackCount', () async {
      for (int i = 0; i < 2; i++) {
        await repository.createRollbackPoint(RollbackPoint(
          id: 'rp$i',
          processInstanceId: 'p1',
          stepId: 's$i',
          strategy: RollbackStrategy.compensating,
          createdAt: DateTime.now(),
          compensatingAction: 'undo',
        ));
      }

      final count = await manager.rollbackEngine.getAvailableRollbackCount('p1');
      expect(count, equals(2));
    });
  });

  // ============================================================================
  // FACADE TESTS (6)
  // ============================================================================

  group('Facade Tests', () {
    test('createWorkflow via facade', () async {
      final workflow = await facade.createWorkflow('Order Processing', 'Handles customer orders');

      expect(workflow.name, equals('Order Processing'));
      expect(workflow.status, equals(WorkflowStatus.draft));
    });

    test('startWorkflowExecution', () async {
      final instance = await facade.startWorkflowExecution('wf1', 'user1');

      expect(instance.workflowId, equals('wf1'));
      expect(instance.status, equals(ProcessState.running));
    });

    test('getActiveWorkflowCount', () async {
      for (int i = 0; i < 2; i++) {
        await repository.createWorkflow(Workflow(
          id: 'wf$i',
          name: 'WF$i',
          status: WorkflowStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      final count = await facade.getActiveWorkflowCount();
      expect(count, equals(2));
    });

    test('getRunningProcessCount', () async {
      for (int i = 0; i < 3; i++) {
        await repository.createProcessInstance(ProcessInstance(
          id: 'p$i',
          workflowId: 'wf1',
          status: ProcessState.running,
          startedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ));
      }

      final count = await facade.getRunningProcessCount();
      expect(count, equals(3));
    });

    test('getWorkflowSuccessRate', () async {
      await repository.recordMetrics(WorkflowPerformanceMetrics(
        id: 'm1',
        workflowId: 'wf1',
        timestamp: DateTime.now(),
        totalExecutions: 100,
        successfulExecutions: 98,
        failedExecutions: 2,
        averageExecutionTimeMs: 300,
      ));

      final rate = await facade.getWorkflowSuccessRate('wf1');
      expect(rate, equals(98));
    });

    test('getTotalAutomationRules', () async {
      for (int i = 0; i < 4; i++) {
        await repository.createRule(AutomationRule(
          id: 'ar$i',
          name: 'Rule$i',
          triggerType: AutomationTriggerType.scheduled,
          createdAt: DateTime.now(),
          isActive: true,
        ));
      }

      final count = await facade.getTotalAutomationRules();
      expect(count, equals(4));
    });
  });

  // ============================================================================
  // INTEGRATION & PERFORMANCE TESTS
  // ============================================================================

  group('Integration Tests', () {
    test('Complete workflow execution cycle', () async {
      final workflow = await facade.createWorkflow('Test Flow', 'Test');
      final instance = await facade.startWorkflowExecution(workflow.id, 'user1');

      expect(instance.workflowId, equals(workflow.id));
      expect(instance.isActive, isTrue);
    });

    test('Workflow with multiple steps and transitions', () async {
      final workflow = await repository.createWorkflow(Workflow(
        id: 'wf1',
        name: 'Multi-Step',
        status: WorkflowStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      for (int i = 1; i <= 3; i++) {
        await repository.createStep(WorkflowStep(
          id: 's$i',
          workflowId: workflow.id,
          name: 'Step$i',
          stepOrder: i,
          createdAt: DateTime.now(),
        ));
      }

      for (int i = 1; i < 3; i++) {
        await repository.createTransition(WorkflowTransition(
          id: 't$i',
          workflowId: workflow.id,
          fromStepId: 's$i',
          toStepId: 's${i + 1}',
          transitionType: TransitionType.sequential,
          createdAt: DateTime.now(),
        ));
      }

      final steps = await repository.getStepsByWorkflow(workflow.id);
      expect(steps.length, equals(3));
    });
  });

  group('Performance Tests', () {
    test('Bulk workflow creation', () async {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 50; i++) {
        await repository.createWorkflow(Workflow(
          id: 'wf$i',
          name: 'Workflow$i',
          status: WorkflowStatus.draft,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    test('Large process instance queries', () async {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        await repository.createProcessInstance(ProcessInstance(
          id: 'p$i',
          workflowId: 'wf${i % 10}',
          status: i % 3 == 0 ? ProcessState.completed : ProcessState.running,
          startedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ));
      }

      await repository.getActiveProcessInstances();
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });

  group('Edge Case Tests', () {
    test('Null workflow operations', () async {
      final result = await repository.getWorkflowById('nonexistent');
      expect(result, isNull);
    });

    test('Empty workflow search', () async {
      final results = await repository.searchWorkflows('nonexistent');
      expect(results.isEmpty, isTrue);
    });

    test('Process with no steps', () async {
      final instance = await repository.createProcessInstance(ProcessInstance(
        id: 'p1',
        workflowId: 'wf1',
        status: ProcessState.running,
        startedAt: DateTime.now(),
        createdAt: DateTime.now(),
      ));

      final executions = await repository.getExecutionsByProcessInstance('p1');
      expect(executions.isEmpty, isTrue);
    });

    test('Rollback without available points', () async {
      final points = await repository.getAvailableRollbackPoints('p_nonexistent');
      expect(points.isEmpty, isTrue);
    });

    test('Automation rules with zero triggers', () async {
      await repository.createRule(AutomationRule(
        id: 'ar1',
        name: 'Unused Rule',
        triggerType: AutomationTriggerType.manual,
        createdAt: DateTime.now(),
        isActive: false,
      ));

      final count = await repository.getPendingTriggerCount();
      expect(count, equals(0));
    });
  });
}
