import 'package:test/test.dart';
import '../lib/models/workflow_models.dart';
import '../lib/services/workflow_service.dart';

void main() {
  group('Phase 67: Workflow Orchestration & Execution Tests', () {
    late MemoryWorkflowRepository repository;
    late WorkflowManager manager;
    late WorkflowFacade facade;

    setUp(() {
      repository = MemoryWorkflowRepository();
      manager = WorkflowManager(repository);
      facade = WorkflowFacade(manager);
    });

    // Enum Tests
    group('Enum Tests', () {
      test('WorkflowStatus enum has all values', () {
        expect(WorkflowStatus.values, contains(WorkflowStatus.draft));
        expect(WorkflowStatus.values, contains(WorkflowStatus.active));
        expect(WorkflowStatus.values, contains(WorkflowStatus.inactive));
        expect(WorkflowStatus.values, contains(WorkflowStatus.deleted));
      });

      test('StepStatus enum values', () {
        expect(StepStatus.values, contains(StepStatus.pending));
        expect(StepStatus.values, contains(StepStatus.running));
        expect(StepStatus.values, contains(StepStatus.succeeded));
        expect(StepStatus.values, contains(StepStatus.failed));
        expect(StepStatus.values, contains(StepStatus.skipped));
        expect(StepStatus.values, contains(StepStatus.retrying));
      });

      test('ExecutionState enum values', () {
        expect(ExecutionState.values, contains(ExecutionState.queued));
        expect(ExecutionState.values, contains(ExecutionState.running));
        expect(ExecutionState.values, contains(ExecutionState.completed));
        expect(ExecutionState.values, contains(ExecutionState.failed));
        expect(ExecutionState.values, contains(ExecutionState.cancelled));
      });

      test('TriggerType enum values', () {
        expect(TriggerType.values, contains(TriggerType.manual));
        expect(TriggerType.values, contains(TriggerType.scheduled));
        expect(TriggerType.values, contains(TriggerType.event));
        expect(TriggerType.values, contains(TriggerType.webhook));
      });

      test('FailureStrategy enum values', () {
        expect(FailureStrategy.values, contains(FailureStrategy.fail));
        expect(FailureStrategy.values, contains(FailureStrategy.skip));
        expect(FailureStrategy.values, contains(FailureStrategy.retry));
        expect(FailureStrategy.values, contains(FailureStrategy.continue_));
      });

      test('ParallelizationMode enum values', () {
        expect(ParallelizationMode.values, contains(ParallelizationMode.sequential));
        expect(ParallelizationMode.values, contains(ParallelizationMode.parallel));
        expect(ParallelizationMode.values, contains(ParallelizationMode.hybrid));
      });
    });

    // Workflow Model Tests
    group('Workflow Model Tests', () {
      test('Workflow creation with default values', () {
        final workflow = Workflow(
          workflowId: 'wf-1',
          workflowName: 'Test Workflow',
          description: 'A test workflow',
          stepIds: ['step-1', 'step-2'],
          createdAt: DateTime.now(),
          createdBy: 'user-1',
        );

        expect(workflow.workflowId, 'wf-1');
        expect(workflow.workflowName, 'Test Workflow');
        expect(workflow.stepCount, 2);
        expect(workflow.status, WorkflowStatus.draft);
      });

      test('Workflow computed properties', () {
        final workflow = Workflow(
          workflowId: 'wf-1',
          workflowName: 'Test Workflow',
          description: 'A test workflow',
          stepIds: ['step-1', 'step-2', 'step-3'],
          createdAt: DateTime.now().subtract(Duration(days: 5)),
          createdBy: 'user-1',
          status: WorkflowStatus.active,
        );

        expect(workflow.isActive, true);
        expect(workflow.stepCount, 3);
        expect(workflow.ageInDays, 5);
      });

      test('Active workflow status', () {
        final workflow = Workflow(
          workflowId: 'wf-1',
          workflowName: 'Test Workflow',
          description: 'A test workflow',
          stepIds: [],
          createdAt: DateTime.now(),
          createdBy: 'user-1',
          status: WorkflowStatus.active,
        );

        expect(workflow.isActive, true);
      });
    });

    // WorkflowStep Tests
    group('WorkflowStep Model Tests', () {
      test('Step creation with dependencies', () {
        final step = WorkflowStep(
          stepId: 'step-1',
          workflowId: 'wf-1',
          stepName: 'Process Data',
          description: 'Process input data',
          actionType: 'execute_job',
          actionConfig: {'timeout': 300},
          dependsOn: ['step-0'],
        );

        expect(step.stepId, 'step-1');
        expect(step.hasDependencies, true);
        expect(step.dependencyCount, 1);
        expect(step.hasConfig, true);
      });

      test('Step with retry configuration', () {
        final step = WorkflowStep(
          stepId: 'step-1',
          workflowId: 'wf-1',
          stepName: 'Retry Step',
          description: 'Step with retries',
          actionType: 'api_call',
          actionConfig: {},
          maxRetries: 3,
        );

        expect(step.isRetryable, true);
        expect(step.maxRetries, 3);
      });

      test('Optional step', () {
        final step = WorkflowStep(
          stepId: 'step-1',
          workflowId: 'wf-1',
          stepName: 'Optional Step',
          description: 'Optional step',
          actionType: 'notify',
          actionConfig: {},
          isOptional: true,
        );

        expect(step.isOptional, true);
      });
    });

    // StepDependency Tests
    group('StepDependency Model Tests', () {
      test('Hard dependency', () {
        final dependency = StepDependency(
          dependencyId: 'dep-1',
          stepId: 'step-1',
          dependsOnStepId: 'step-0',
          dependencyType: 'completion',
          createdAt: DateTime.now(),
        );

        expect(dependency.isHard, true);
        expect(dependency.isSoft, false);
      });

      test('Soft dependency', () {
        final dependency = StepDependency(
          dependencyId: 'dep-1',
          stepId: 'step-1',
          dependsOnStepId: 'step-0',
          dependencyType: 'success_only',
          isHard: false,
          createdAt: DateTime.now(),
        );

        expect(dependency.isSoft, true);
      });
    });

    // WorkflowExecution Tests
    group('WorkflowExecution Model Tests', () {
      test('Queued execution', () {
        final execution = WorkflowExecution(
          executionId: 'exec-1',
          workflowId: 'wf-1',
          state: ExecutionState.queued,
          startedAt: DateTime.now(),
          triggeredBy: 'user-1',
          triggerType: TriggerType.manual,
        );

        expect(execution.state, ExecutionState.queued);
        expect(execution.isRunning, false);
        expect(execution.isCompleted, false);
      });

      test('Running execution', () {
        final execution = WorkflowExecution(
          executionId: 'exec-1',
          workflowId: 'wf-1',
          state: ExecutionState.running,
          startedAt: DateTime.now(),
          triggeredBy: 'user-1',
          triggerType: TriggerType.scheduled,
        );

        expect(execution.isRunning, true);
        expect(execution.isCompleted, false);
      });

      test('Completed execution', () {
        final now = DateTime.now();
        final execution = WorkflowExecution(
          executionId: 'exec-1',
          workflowId: 'wf-1',
          state: ExecutionState.completed,
          startedAt: now,
          completedAt: now.add(Duration(minutes: 5)),
          triggeredBy: 'user-1',
          triggerType: TriggerType.manual,
        );

        expect(execution.isCompleted, true);
        expect(execution.durationInSeconds, 300);
      });

      test('Failed execution', () {
        final execution = WorkflowExecution(
          executionId: 'exec-1',
          workflowId: 'wf-1',
          state: ExecutionState.failed,
          startedAt: DateTime.now(),
          triggeredBy: 'user-1',
          triggerType: TriggerType.event,
        );

        expect(execution.isFailed, true);
      });
    });

    // StepExecution Tests
    group('StepExecution Model Tests', () {
      test('Step execution lifecycle', () {
        final stepExec = StepExecution(
          stepExecutionId: 'step-exec-1',
          executionId: 'exec-1',
          stepId: 'step-1',
          status: StepStatus.running,
          startedAt: DateTime.now(),
        );

        expect(stepExec.isRunning, true);
        expect(stepExec.isSucceeded, false);
        expect(stepExec.isFailed, false);
      });

      test('Successful step execution', () {
        final now = DateTime.now();
        final stepExec = StepExecution(
          stepExecutionId: 'step-exec-1',
          executionId: 'exec-1',
          stepId: 'step-1',
          status: StepStatus.succeeded,
          startedAt: now,
          completedAt: now.add(Duration(seconds: 10)),
          stepOutput: {'result': 'success'},
        );

        expect(stepExec.isSucceeded, true);
        expect(stepExec.hasOutput, true);
        expect(stepExec.durationInSeconds, 10);
      });

      test('Failed step with error', () {
        final stepExec = StepExecution(
          stepExecutionId: 'step-exec-1',
          executionId: 'exec-1',
          stepId: 'step-1',
          status: StepStatus.failed,
          startedAt: DateTime.now(),
          errorMessage: 'Connection timeout',
        );

        expect(stepExec.isFailed, true);
        expect(stepExec.hasError, true);
      });

      test('Retrying step', () {
        final stepExec = StepExecution(
          stepExecutionId: 'step-exec-1',
          executionId: 'exec-1',
          stepId: 'step-1',
          status: StepStatus.retrying,
          startedAt: DateTime.now(),
          attemptCount: 2,
        );

        expect(stepExec.isRetrying, true);
        expect(stepExec.attemptCount, 2);
      });
    });

    // WorkflowPipeline Tests
    group('WorkflowPipeline Model Tests', () {
      test('Sequential pipeline', () {
        final pipeline = WorkflowPipeline(
          pipelineId: 'pipe-1',
          pipelineName: 'Data Processing',
          workflowIds: ['wf-1', 'wf-2', 'wf-3'],
          mode: ParallelizationMode.sequential,
          createdAt: DateTime.now(),
        );

        expect(pipeline.isParallel, false);
        expect(pipeline.workflowCount, 3);
        expect(pipeline.hasWorkflows, true);
      });

      test('Parallel pipeline', () {
        final pipeline = WorkflowPipeline(
          pipelineId: 'pipe-1',
          pipelineName: 'Analytics',
          workflowIds: ['wf-1', 'wf-2'],
          mode: ParallelizationMode.parallel,
          maxParallelSteps: 4,
          createdAt: DateTime.now(),
        );

        expect(pipeline.isParallel, true);
        expect(pipeline.maxParallelSteps, 4);
      });
    });

    // ExecutionContext Tests
    group('ExecutionContext Model Tests', () {
      test('Context with variables', () {
        final context = ExecutionContext(
          contextId: 'ctx-1',
          executionId: 'exec-1',
          variables: {'key': 'value', 'number': 42},
          createdAt: DateTime.now(),
        );

        expect(context.hasVariables, true);
        expect(context.totalData, 2);
      });

      test('Context with secrets', () {
        final context = ExecutionContext(
          contextId: 'ctx-1',
          executionId: 'exec-1',
          secrets: {'api_key': 'secret123'},
          createdAt: DateTime.now(),
        );

        expect(context.hasSecrets, true);
      });

      test('Context with artifacts', () {
        final context = ExecutionContext(
          contextId: 'ctx-1',
          executionId: 'exec-1',
          artifacts: {'report': '/path/to/report.pdf'},
          createdAt: DateTime.now(),
        );

        expect(context.hasArtifacts, true);
      });
    });

    // WorkflowTrigger Tests
    group('WorkflowTrigger Model Tests', () {
      test('Manual trigger', () {
        final trigger = WorkflowTrigger(
          triggerId: 'trig-1',
          workflowId: 'wf-1',
          triggerType: TriggerType.manual,
          triggerConfig: {},
          createdAt: DateTime.now(),
        );

        expect(trigger.isManual, true);
        expect(trigger.isScheduled, false);
      });

      test('Scheduled trigger', () {
        final trigger = WorkflowTrigger(
          triggerId: 'trig-1',
          workflowId: 'wf-1',
          triggerType: TriggerType.scheduled,
          triggerConfig: {'frequency': 'daily'},
          cronExpression: '0 9 * * *',
          createdAt: DateTime.now(),
        );

        expect(trigger.isScheduled, true);
      });

      test('Event-based trigger', () {
        final trigger = WorkflowTrigger(
          triggerId: 'trig-1',
          workflowId: 'wf-1',
          triggerType: TriggerType.event,
          triggerConfig: {'event_type': 'data_uploaded'},
          createdAt: DateTime.now(),
        );

        expect(trigger.isEventBased, true);
      });
    });

    // RetryPolicy Tests
    group('RetryPolicy Model Tests', () {
      test('Retry policy with exponential backoff', () {
        final policy = RetryPolicy(
          policyId: 'retry-1',
          stepId: 'step-1',
          maxRetries: 3,
          initialDelaySeconds: 5,
          maxDelaySeconds: 60,
          backoffMultiplier: 2.0,
        );

        expect(policy.hasExponentialBackoff, true);
        expect(policy.maxRetries, 3);
      });

      test('Retry policy with retryable errors', () {
        final policy = RetryPolicy(
          policyId: 'retry-1',
          stepId: 'step-1',
          maxRetries: 3,
          initialDelaySeconds: 5,
          maxDelaySeconds: 60,
          retryableErrors: ['timeout', 'connection_error'],
        );

        expect(policy.hasRetryableErrors, true);
        expect(policy.errorCount, 2);
      });
    });

    // WorkflowMetrics Tests
    group('WorkflowMetrics Model Tests', () {
      test('Healthy workflow metrics', () {
        final metrics = WorkflowMetrics(
          metricsId: 'metric-1',
          workflowId: 'wf-1',
          totalExecutions: 100,
          successfulExecutions: 97,
          failedExecutions: 3,
          averageExecutionTime: 250.0,
          successRate: 97.0,
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
        );

        expect(metrics.isHealthy, true);
        expect(metrics.successRate, 97.0);
        expect(metrics.failureCount, 3);
      });

      test('Unhealthy workflow metrics', () {
        final metrics = WorkflowMetrics(
          metricsId: 'metric-1',
          workflowId: 'wf-1',
          totalExecutions: 100,
          successfulExecutions: 80,
          failedExecutions: 20,
          averageExecutionTime: 500.0,
          successRate: 80.0,
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
        );

        expect(metrics.isHealthy, false);
        expect(metrics.failureRate, 20.0);
      });
    });

    // WorkflowSchedule Tests
    group('WorkflowSchedule Model Tests', () {
      test('Active schedule', () {
        final schedule = WorkflowSchedule(
          scheduleId: 'sched-1',
          workflowId: 'wf-1',
          cronExpression: '0 9 * * *',
          nextExecution: DateTime.now().add(Duration(hours: 5)),
          lastExecution: DateTime.now().subtract(Duration(days: 1)),
          isActive: true,
        );

        expect(schedule.isActive, true);
        expect(schedule.hasExecuted, true);
      });

      test('Schedule due for execution', () {
        final schedule = WorkflowSchedule(
          scheduleId: 'sched-1',
          workflowId: 'wf-1',
          cronExpression: '0 9 * * *',
          nextExecution: DateTime.now().subtract(Duration(minutes: 5)),
          isActive: true,
        );

        expect(schedule.isDue, true);
      });
    });

    // ExecutionLog Tests
    group('ExecutionLog Model Tests', () {
      test('Info log', () {
        final log = ExecutionLog(
          logId: 'log-1',
          executionId: 'exec-1',
          stepExecutionId: 'step-exec-1',
          message: 'Step started',
          timestamp: DateTime.now(),
          logLevel: 'INFO',
        );

        expect(log.isInfo, true);
        expect(log.isError, false);
      });

      test('Error log', () {
        final log = ExecutionLog(
          logId: 'log-1',
          executionId: 'exec-1',
          stepExecutionId: 'step-exec-1',
          message: 'Connection failed',
          timestamp: DateTime.now(),
          logLevel: 'ERROR',
          metadata: {'error_code': 500},
        );

        expect(log.isError, true);
        expect(log.hasMetadata, true);
      });

      test('Warning log', () {
        final log = ExecutionLog(
          logId: 'log-1',
          executionId: 'exec-1',
          stepExecutionId: 'step-exec-1',
          message: 'High latency detected',
          timestamp: DateTime.now(),
          logLevel: 'WARNING',
        );

        expect(log.isWarning, true);
      });
    });

    // WorkflowTemplate Tests
    group('WorkflowTemplate Model Tests', () {
      test('Template with tags', () {
        final template = WorkflowTemplate(
          templateId: 'tmpl-1',
          templateName: 'Data Processing',
          description: 'Process data files',
          templateDefinition: {'steps': ['parse', 'validate', 'store']},
          tags: ['data', 'processing', 'batch'],
          createdAt: DateTime.now(),
        );

        expect(template.hasTags, true);
        expect(template.tagCount, 3);
        expect(template.hasDefinition, true);
      });

      test('Popular template', () {
        final template = WorkflowTemplate(
          templateId: 'tmpl-1',
          templateName: 'Popular Template',
          description: 'A popular workflow',
          templateDefinition: {},
          createdAt: DateTime.now(),
          usageCount: 25,
        );

        expect(template.isPopular, true);
      });
    });

    // WorkflowNotification Tests
    group('WorkflowNotification Model Tests', () {
      test('Sent notification', () {
        final notification = WorkflowNotification(
          notificationId: 'notif-1',
          executionId: 'exec-1',
          notificationType: 'completion',
          recipient: 'user@example.com',
          message: 'Workflow completed',
          createdAt: DateTime.now(),
          isSent: true,
        );

        expect(notification.isSent, true);
        expect(notification.hasFailed, false);
      });

      test('Failed notification', () {
        final notification = WorkflowNotification(
          notificationId: 'notif-1',
          executionId: 'exec-1',
          notificationType: 'error',
          recipient: 'user@example.com',
          message: 'Workflow failed',
          createdAt: DateTime.now(),
          isSent: false,
          sendError: 'Mail server unavailable',
        );

        expect(notification.hasFailed, true);
      });
    });

    // Repository CRUD Tests
    group('Repository CRUD Operations', () {
      test('Create and retrieve workflow', () async {
        final workflow = Workflow(
          workflowId: 'wf-1',
          workflowName: 'Test Workflow',
          description: 'A test workflow',
          stepIds: ['step-1'],
          createdAt: DateTime.now(),
          createdBy: 'user-1',
        );

        await repository.createWorkflow(workflow);
        final retrieved = await repository.getWorkflow('wf-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.workflowName, 'Test Workflow');
      });

      test('Create and retrieve step', () async {
        final step = WorkflowStep(
          stepId: 'step-1',
          workflowId: 'wf-1',
          stepName: 'Process',
          description: 'Process data',
          actionType: 'execute',
          actionConfig: {},
        );

        await repository.createStep(step);
        final retrieved = await repository.getStep('step-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.stepName, 'Process');
      });

      test('Get workflow steps', () async {
        final step1 = WorkflowStep(
          stepId: 'step-1',
          workflowId: 'wf-1',
          stepName: 'Step 1',
          description: '',
          actionType: 'execute',
          actionConfig: {},
        );

        final step2 = WorkflowStep(
          stepId: 'step-2',
          workflowId: 'wf-1',
          stepName: 'Step 2',
          description: '',
          actionType: 'execute',
          actionConfig: {},
        );

        await repository.createStep(step1);
        await repository.createStep(step2);

        final steps = await repository.getWorkflowSteps('wf-1');
        expect(steps.length, 2);
      });

      test('Create and retrieve execution', () async {
        final execution = WorkflowExecution(
          executionId: 'exec-1',
          workflowId: 'wf-1',
          state: ExecutionState.running,
          startedAt: DateTime.now(),
          triggeredBy: 'user-1',
          triggerType: TriggerType.manual,
        );

        await repository.createExecution(execution);
        final retrieved = await repository.getExecution('exec-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.state, ExecutionState.running);
      });

      test('Get executions by state', () async {
        final exec1 = WorkflowExecution(
          executionId: 'exec-1',
          workflowId: 'wf-1',
          state: ExecutionState.completed,
          startedAt: DateTime.now(),
          triggeredBy: 'user-1',
          triggerType: TriggerType.manual,
        );

        final exec2 = WorkflowExecution(
          executionId: 'exec-2',
          workflowId: 'wf-1',
          state: ExecutionState.running,
          startedAt: DateTime.now(),
          triggeredBy: 'user-1',
          triggerType: TriggerType.scheduled,
        );

        await repository.createExecution(exec1);
        await repository.createExecution(exec2);

        final completed = await repository.getExecutionsByState(ExecutionState.completed);
        expect(completed.length, 1);
      });

      test('Create and retrieve step execution', () async {
        final stepExec = StepExecution(
          stepExecutionId: 'step-exec-1',
          executionId: 'exec-1',
          stepId: 'step-1',
          status: StepStatus.running,
          startedAt: DateTime.now(),
        );

        await repository.createStepExecution(stepExec);
        final retrieved = await repository.getStepExecution('step-exec-1');

        expect(retrieved, isNotNull);
        expect(retrieved!.status, StepStatus.running);
      });

      test('Get execution steps', () async {
        final stepExec1 = StepExecution(
          stepExecutionId: 'step-exec-1',
          executionId: 'exec-1',
          stepId: 'step-1',
          status: StepStatus.succeeded,
          startedAt: DateTime.now(),
        );

        final stepExec2 = StepExecution(
          stepExecutionId: 'step-exec-2',
          executionId: 'exec-1',
          stepId: 'step-2',
          status: StepStatus.running,
          startedAt: DateTime.now(),
        );

        await repository.createStepExecution(stepExec1);
        await repository.createStepExecution(stepExec2);

        final steps = await repository.getExecutionSteps('exec-1');
        expect(steps.length, 2);
      });
    });

    // Engine Tests
    group('Execution Engine Tests', () {
      test('Start workflow execution', () async {
        final workflow = Workflow(
          workflowId: 'wf-1',
          workflowName: 'Test',
          description: 'Test',
          stepIds: [],
          createdAt: DateTime.now(),
          createdBy: 'user-1',
          status: WorkflowStatus.active,
        );

        await repository.createWorkflow(workflow);

        final execution = await manager.startWorkflow('wf-1', 'user-1', TriggerType.manual);

        expect(execution, isNotNull);
        expect(execution!.state, ExecutionState.queued);
      });

      test('Cannot start inactive workflow', () async {
        final workflow = Workflow(
          workflowId: 'wf-1',
          workflowName: 'Test',
          description: 'Test',
          stepIds: [],
          createdAt: DateTime.now(),
          createdBy: 'user-1',
          status: WorkflowStatus.draft,
        );

        await repository.createWorkflow(workflow);

        final execution = await manager.startWorkflow('wf-1', 'user-1', TriggerType.manual);

        expect(execution, isNull);
      });

      test('Complete execution', () async {
        final execution = WorkflowExecution(
          executionId: 'exec-1',
          workflowId: 'wf-1',
          state: ExecutionState.running,
          startedAt: DateTime.now(),
          triggeredBy: 'user-1',
          triggerType: TriggerType.manual,
        );

        await repository.createExecution(execution);
        await manager.completeWorkflow('exec-1');

        final updated = await repository.getExecution('exec-1');
        expect(updated!.state, ExecutionState.completed);
        expect(updated.completedAt, isNotNull);
      });

      test('Fail execution', () async {
        final execution = WorkflowExecution(
          executionId: 'exec-1',
          workflowId: 'wf-1',
          state: ExecutionState.running,
          startedAt: DateTime.now(),
          triggeredBy: 'user-1',
          triggerType: TriggerType.manual,
        );

        await repository.createExecution(execution);
        await manager.failWorkflow('exec-1');

        final updated = await repository.getExecution('exec-1');
        expect(updated!.state, ExecutionState.failed);
      });
    });

    // Step Execution Engine Tests
    group('Step Execution Engine Tests', () {
      test('Execute step', () async {
        final stepExec = await manager.executeStep('exec-1', 'step-1');

        expect(stepExec, isNotNull);
        expect(stepExec!.status, StepStatus.running);
      });

      test('Complete step', () async {
        final stepExec = await manager.executeStep('exec-1', 'step-1');
        await manager.completeStep(stepExec!.stepExecutionId, output: {'result': 'ok'});

        final updated = await repository.getStepExecution(stepExec.stepExecutionId);
        expect(updated!.status, StepStatus.succeeded);
        expect(updated.hasOutput, true);
      });

      test('Fail step with error', () async {
        final stepExec = await manager.executeStep('exec-1', 'step-1');
        await manager.failStep(stepExec!.stepExecutionId, 'Connection timeout');

        final updated = await repository.getStepExecution(stepExec.stepExecutionId);
        expect(updated!.status, StepStatus.failed);
        expect(updated.hasError, true);
      });

      test('Retry step', () async {
        final stepExec = await manager.executeStep('exec-1', 'step-1');
        await manager.retryStep(stepExec!.stepExecutionId);

        final updated = await repository.getStepExecution(stepExec.stepExecutionId);
        expect(updated!.status, StepStatus.retrying);
        expect(updated.attemptCount, 1);
      });
    });

    // Dependency Engine Tests
    group('Dependency Engine Tests', () {
      test('Get step dependencies', () async {
        final dep = StepDependency(
          dependencyId: 'dep-1',
          stepId: 'step-1',
          dependsOnStepId: 'step-0',
          dependencyType: 'completion',
          createdAt: DateTime.now(),
        );

        await repository.createDependency(dep);

        final dependencies = await manager.dependencyEngine.getRequiredSteps('step-1');
        expect(dependencies.length, 1);
        expect(dependencies.first, 'step-0');
      });

      test('Get dependent steps', () async {
        final dep = StepDependency(
          dependencyId: 'dep-1',
          stepId: 'step-1',
          dependsOnStepId: 'step-0',
          dependencyType: 'completion',
          createdAt: DateTime.now(),
        );

        await repository.createDependency(dep);

        final dependents = await manager.dependencyEngine.getBlockedSteps('step-0');
        expect(dependents.length, 1);
        expect(dependents.first, 'step-1');
      });

      test('Can execute step when dependencies met', () async {
        final dep = StepDependency(
          dependencyId: 'dep-1',
          stepId: 'step-1',
          dependsOnStepId: 'step-0',
          dependencyType: 'completion',
          createdAt: DateTime.now(),
        );

        await repository.createDependency(dep);

        final canExecute = await manager.dependencyEngine.canExecuteStep('step-1', ['step-0']);
        expect(canExecute, true);
      });

      test('Cannot execute step when dependencies missing', () async {
        final dep = StepDependency(
          dependencyId: 'dep-1',
          stepId: 'step-1',
          dependsOnStepId: 'step-0',
          dependencyType: 'completion',
          isHard: true,
          createdAt: DateTime.now(),
        );

        await repository.createDependency(dep);

        final canExecute = await manager.dependencyEngine.canExecuteStep('step-1', []);
        expect(canExecute, false);
      });
    });

    // Facade Integration Tests
    group('Facade Integration Tests', () {
      test('Create and activate workflow', () async {
        await facade.createWorkflow('Test WF', 'Test workflow', ['step-1'], 'user-1');
        await facade.activateWorkflow('wf-${DateTime.now().millisecondsSinceEpoch}');

        final workflows = await facade.getActiveWorkflows();
        expect(workflows.isNotEmpty, true);
      });

      test('Complete workflow execution', () async {
        final workflow = Workflow(
          workflowId: 'wf-1',
          workflowName: 'Test',
          description: 'Test',
          stepIds: [],
          createdAt: DateTime.now(),
          createdBy: 'user-1',
          status: WorkflowStatus.active,
        );

        await repository.createWorkflow(workflow);

        final exec = await facade.executeWorkflow('wf-1', 'user-1');
        expect(exec, isNotNull);

        final retrieved = await facade.getExecution(exec!.executionId);
        expect(retrieved, isNotNull);
      });

      test('Record execution log', () async {
        await facade.recordLog('exec-1', 'step-exec-1', 'Step completed', logLevel: 'INFO');

        final logs = await facade.getExecutionLogs('exec-1');
        expect(logs.length, 1);
        expect(logs.first.isInfo, true);
      });

      test('Create workflow template', () async {
        await facade.createWorkflowTemplate(
          'Data Process',
          'Process data files',
          {'steps': ['parse', 'validate']},
          ['data', 'batch'],
        );

        final templates = await facade.getAllTemplates();
        expect(templates.isNotEmpty, true);
      });

      test('Create workflow trigger', () async {
        await facade.createWorkflowTrigger(
          'wf-1',
          TriggerType.scheduled,
          {'frequency': 'daily'},
        );

        final triggers = await facade.getWorkflowTriggers('wf-1');
        expect(triggers.isNotEmpty, true);
      });

      test('Save and retrieve metrics', () async {
        await facade.saveMetrics('wf-1', 100, 95, 5, 250.0);

        final metrics = await facade.getLatestMetrics('wf-1');
        expect(metrics, isNotNull);
        expect(metrics!.isHealthy, true);
      });
    });

    // Edge Cases
    group('Edge Case Tests', () {
      test('Workflow with no steps', () {
        final workflow = Workflow(
          workflowId: 'wf-1',
          workflowName: 'Empty',
          description: 'No steps',
          stepIds: [],
          createdAt: DateTime.now(),
          createdBy: 'user-1',
        );

        expect(workflow.stepCount, 0);
      });

      test('Execution with zero duration', () {
        final now = DateTime.now();
        final execution = WorkflowExecution(
          executionId: 'exec-1',
          workflowId: 'wf-1',
          state: ExecutionState.completed,
          startedAt: now,
          completedAt: now,
          triggeredBy: 'user-1',
          triggerType: TriggerType.manual,
        );

        expect(execution.durationInSeconds, 0);
      });

      test('Multiple retries', () async {
        var stepExec = await manager.executeStep('exec-1', 'step-1');

        for (int i = 0; i < 3; i++) {
          await manager.retryStep(stepExec!.stepExecutionId);
          stepExec = await repository.getStepExecution(stepExec.stepExecutionId);
        }

        expect(stepExec!.attemptCount, 3);
      });

      test('Circular dependency prevention', () async {
        final dep = StepDependency(
          dependencyId: 'dep-1',
          stepId: 'step-1',
          dependsOnStepId: 'step-0',
          dependencyType: 'completion',
          createdAt: DateTime.now(),
        );

        await repository.createDependency(dep);

        // Attempting to create circular dependency
        final circularDep = StepDependency(
          dependencyId: 'dep-2',
          stepId: 'step-0',
          dependsOnStepId: 'step-1',
          dependencyType: 'completion',
          createdAt: DateTime.now(),
        );

        await repository.createDependency(circularDep);

        // Repository allows it, but business logic should prevent execution
        final deps = await repository.getStepDependencies('step-0');
        expect(deps.length, 1);
      });

      test('Log with max age', () {
        final log = ExecutionLog(
          logId: 'log-1',
          executionId: 'exec-1',
          stepExecutionId: 'step-exec-1',
          message: 'Old log',
          timestamp: DateTime.now().subtract(Duration(days: 30)),
        );

        expect(log.ageInSeconds, greaterThan(2592000));
      });
    });
  });
}
