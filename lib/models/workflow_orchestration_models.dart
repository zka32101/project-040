/// Phase 85: Advanced Workflow Orchestration & Process Automation
/// Core domain models for workflow and process automation
library workflow_orchestration_models;

// ============================================================================
// ENUMS (6 total)
// ============================================================================

enum WorkflowStatus {
  draft('ドラフト'),
  active('アクティブ'),
  paused('一時停止'),
  archived('アーカイブ'),
  executing('実行中'),
  completed('完了'),
  failed('失敗');

  const WorkflowStatus(this.displayName);
  final String displayName;
}

enum ProcessState {
  pending('保留中'),
  running('実行中'),
  paused('一時停止'),
  completed('完了'),
  failed('失敗'),
  rolledBack('ロールバック'),
  cancelled('キャンセル');

  const ProcessState(this.displayName);
  final String displayName;
}

enum StepStatus {
  pending('保留中'),
  running('実行中'),
  completed('完了'),
  failed('失敗'),
  skipped('スキップ'),
  waiting('待機中');

  const StepStatus(this.displayName);
  final String displayName;
}

enum TransitionType {
  sequential('順序実行'),
  conditional('条件付き'),
  parallel('並列実行'),
  loop('ループ'),
  forkJoin('フォーク/ジョイン');

  const TransitionType(this.displayName);
  final String displayName;
}

enum AutomationTriggerType {
  manual('手動'),
  scheduled('スケジュール'),
  eventBased('イベント駆動'),
  webhook('ウェブフック'),
  apiCall('API呼び出し'),
  timeBased('時間ベース');

  const AutomationTriggerType(this.displayName);
  final String displayName;
}

enum RollbackStrategy {
  none('なし'),
  automatic('自動'),
  manual('手動'),
  compensating('補償トランザクション'),
  snapshot('スナップショット');

  const RollbackStrategy(this.displayName);
  final String displayName;
}

// ============================================================================
// MODELS (12 total)
// ============================================================================

/// Workflow: ワークフロー定義
class Workflow {
  Workflow({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.version = 1,
    this.stepCount = 0,
    this.isPublished = false,
    this.retryPolicy,
    this.timeoutSeconds,
  });

  final String id;
  final String name;
  final WorkflowStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final int version;
  final int stepCount;
  final bool isPublished;
  final String? retryPolicy;
  final int? timeoutSeconds;

  bool get isActive => status == WorkflowStatus.active;
  bool get isExecuting => status == WorkflowStatus.executing;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;

  Workflow copyWith({
    String? id,
    String? name,
    WorkflowStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
    int? version,
    int? stepCount,
    bool? isPublished,
    String? retryPolicy,
    int? timeoutSeconds,
  }) {
    return Workflow(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
      version: version ?? this.version,
      stepCount: stepCount ?? this.stepCount,
      isPublished: isPublished ?? this.isPublished,
      retryPolicy: retryPolicy ?? this.retryPolicy,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    );
  }
}

/// WorkflowStep: ワークフローのステップ
class WorkflowStep {
  WorkflowStep({
    required this.id,
    required this.workflowId,
    required this.name,
    required this.stepOrder,
    required this.createdAt,
    this.description,
    this.actionType,
    this.retryCount = 0,
    this.timeoutSeconds = 300,
    this.skipOnError = false,
    this.inputVariables = const [],
    this.outputVariables = const [],
  });

  final String id;
  final String workflowId;
  final String name;
  final int stepOrder;
  final DateTime createdAt;
  final String? description;
  final String? actionType;
  final int retryCount;
  final int timeoutSeconds;
  final bool skipOnError;
  final List<String> inputVariables;
  final List<String> outputVariables;

  bool get hasRetry => retryCount > 0;
  bool get hasTimeout => timeoutSeconds > 0;
  int get totalVariables => inputVariables.length + outputVariables.length;
}

/// ProcessInstance: ワークフロー実行インスタンス
class ProcessInstance {
  ProcessInstance({
    required this.id,
    required this.workflowId,
    required this.status,
    required this.startedAt,
    required this.createdAt,
    this.completedAt,
    this.failedAt,
    this.initiatedBy,
    this.currentStepId,
    this.variables = const {},
    this.retryCount = 0,
  });

  final String id;
  final String workflowId;
  final ProcessState status;
  final DateTime startedAt;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final String? initiatedBy;
  final String? currentStepId;
  final Map<String, dynamic> variables;
  final int retryCount;

  bool get isActive => status == ProcessState.running || status == ProcessState.pending;
  bool get isCompleted => status == ProcessState.completed;
  bool get isFailed => status == ProcessState.failed;
  int get durationSeconds => (completedAt ?? DateTime.now()).difference(startedAt).inSeconds;
}

/// StepExecution: ステップ実行記録
class StepExecution {
  StepExecution({
    required this.id,
    required this.processInstanceId,
    required this.stepId,
    required this.status,
    required this.startedAt,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
    this.output,
    this.executionTimeMs = 0,
    this.attemptNumber = 1,
  });

  final String id;
  final String processInstanceId;
  final String stepId;
  final StepStatus status;
  final DateTime startedAt;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final String? output;
  final int executionTimeMs;
  final int attemptNumber;

  bool get isRunning => status == StepStatus.running;
  bool get isCompleted => status == StepStatus.completed;
  bool get isFailed => status == StepStatus.failed;
  bool get isWaiting => status == StepStatus.waiting;
}

/// WorkflowTransition: ステップ間の遷移
class WorkflowTransition {
  WorkflowTransition({
    required this.id,
    required this.workflowId,
    required this.fromStepId,
    required this.toStepId,
    required this.transitionType,
    required this.createdAt,
    this.condition,
    this.weight = 1.0,
    this.isDefault = false,
  });

  final String id;
  final String workflowId;
  final String fromStepId;
  final String toStepId;
  final TransitionType transitionType;
  final DateTime createdAt;
  final String? condition;
  final double weight;
  final bool isDefault;

  bool get isConditional => condition != null;
  bool get isParallel => transitionType == TransitionType.parallel;
  bool get isSequential => transitionType == TransitionType.sequential;
}

/// ProcessHistory: プロセス履歴
class ProcessHistory {
  ProcessHistory({
    required this.id,
    required this.processInstanceId,
    required this.eventType,
    required this.timestamp,
    this.details,
    this.previousState,
    this.newState,
    this.actor,
  });

  final String id;
  final String processInstanceId;
  final String eventType;
  final DateTime timestamp;
  final String? details;
  final String? previousState;
  final String? newState;
  final String? actor;

  bool get isStateChange => previousState != null && newState != null;
  int get ageInHours => DateTime.now().difference(timestamp).inHours;
}

/// AutomationRule: 自動化ルール
class AutomationRule {
  AutomationRule({
    required this.id,
    required this.name,
    required this.triggerType,
    required this.createdAt,
    required this.isActive,
    this.description,
    this.workflowId,
    this.condition,
    this.cronExpression,
    this.webhookUrl,
    this.maxExecutionsPerDay = 1000,
  });

  final String id;
  final String name;
  final AutomationTriggerType triggerType;
  final DateTime createdAt;
  final bool isActive;
  final String? description;
  final String? workflowId;
  final String? condition;
  final String? cronExpression;
  final String? webhookUrl;
  final int maxExecutionsPerDay;

  bool get isScheduled => cronExpression != null;
  bool get hasWebhook => webhookUrl != null;
  bool get isEventDriven => triggerType == AutomationTriggerType.eventBased;
}

/// EventTrigger: イベントトリガー
class EventTrigger {
  EventTrigger({
    required this.id,
    required this.automationRuleId,
    required this.eventType,
    required this.createdAt,
    this.payload,
    this.processedAt,
    this.processInstanceId,
    this.status = 'pending',
  });

  final String id;
  final String automationRuleId;
  final String eventType;
  final DateTime createdAt;
  final String? payload;
  final DateTime? processedAt;
  final String? processInstanceId;
  final String status;

  bool get isPending => status == 'pending';
  bool get isProcessed => status == 'processed';
  bool get isFailed => status == 'failed';
}

/// WorkflowVariable: ワークフロー変数
class WorkflowVariable {
  WorkflowVariable({
    required this.id,
    required this.processInstanceId,
    required this.name,
    required this.value,
    required this.type,
    required this.createdAt,
    this.updatedAt,
    this.isEncrypted = false,
  });

  final String id;
  final String processInstanceId;
  final String name;
  final String value;
  final String type;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEncrypted;

  bool get isString => type == 'string';
  bool get isNumeric => type == 'numeric';
  bool get isBoolean => type == 'boolean';
  int get ageInMinutes => DateTime.now().difference(createdAt).inMinutes;
}

/// RollbackPoint: ロールバックポイント
class RollbackPoint {
  RollbackPoint({
    required this.id,
    required this.processInstanceId,
    required this.stepId,
    required this.strategy,
    required this.createdAt,
    this.snapshotData,
    this.compensatingAction,
    this.isUsed = false,
    this.usedAt,
  });

  final String id;
  final String processInstanceId;
  final String stepId;
  final RollbackStrategy strategy;
  final DateTime createdAt;
  final String? snapshotData;
  final String? compensatingAction;
  final bool isUsed;
  final DateTime? usedAt;

  bool get isSnapshot => strategy == RollbackStrategy.snapshot;
  bool get isCompensating => strategy == RollbackStrategy.compensating;
  bool get canRollback => !isUsed && (snapshotData != null || compensatingAction != null);
}

/// ExecutionLog: 実行ログ
class ExecutionLog {
  ExecutionLog({
    required this.id,
    required this.processInstanceId,
    required this.timestamp,
    required this.level,
    required this.message,
    this.stepId,
    this.metadata,
    this.stackTrace,
  });

  final String id;
  final String processInstanceId;
  final DateTime timestamp;
  final String level;
  final String message;
  final String? stepId;
  final String? metadata;
  final String? stackTrace;

  bool get isError => level == 'ERROR';
  bool get isWarning => level == 'WARNING';
  bool get isInfo => level == 'INFO';
  bool get isDebug => level == 'DEBUG';
  int get ageInMinutes => DateTime.now().difference(timestamp).inMinutes;
}

/// WorkflowPerformanceMetrics: パフォーマンスメトリクス
class WorkflowPerformanceMetrics {
  WorkflowPerformanceMetrics({
    required this.id,
    required this.workflowId,
    required this.timestamp,
    required this.totalExecutions,
    required this.successfulExecutions,
    required this.failedExecutions,
    required this.averageExecutionTimeMs,
    this.p50ExecutionTimeMs = 0,
    this.p95ExecutionTimeMs = 0,
    this.p99ExecutionTimeMs = 0,
    this.successRate = 0.0,
  });

  final String id;
  final String workflowId;
  final DateTime timestamp;
  final int totalExecutions;
  final int successfulExecutions;
  final int failedExecutions;
  final double averageExecutionTimeMs;
  final double p50ExecutionTimeMs;
  final double p95ExecutionTimeMs;
  final double p99ExecutionTimeMs;
  final double successRate;

  double get actualSuccessRate => totalExecutions > 0 ? (successfulExecutions / totalExecutions) * 100 : 0;
  int get errorCount => failedExecutions;
  bool get isHealthy => actualSuccessRate >= 95;
  bool get isWarning => actualSuccessRate >= 80 && actualSuccessRate < 95;
  bool get isCritical => actualSuccessRate < 80;
  int get ageInHours => DateTime.now().difference(timestamp).inHours;
}
