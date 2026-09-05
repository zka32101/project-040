import 'package:flutter/foundation.dart';

// ============================================================================
// ENUMS
// ============================================================================

enum IncidentSeverity {
  low('低'),
  medium('中程度'),
  high('高'),
  critical('重大'),
  catastrophic('壊滅的');

  final String displayName;
  const IncidentSeverity(this.displayName);
}

enum IncidentStatus {
  reported('報告済み'),
  investigating('調査中'),
  contained('封じ込め済み'),
  mitigating('軽減中'),
  resolved('解決済み'),
  closed('クローズ');

  final String displayName;
  const IncidentStatus(this.displayName);
}

enum IncidentType {
  security('セキュリティ'),
  operational('運用'),
  infrastructure('インフラ'),
  dataLoss('データ損失'),
  performance('パフォーマンス'),
  compliance('準拠性');

  final String displayName;
  const IncidentType(this.displayName);
}

enum ResponsePhase {
  detection('検出'),
  triage('トリアージ'),
  containment('封じ込め'),
  eradication('根絶'),
  recovery('復旧'),
  postIncident('インシデント後');

  final String displayName;
  const ResponsePhase(this.displayName);
}

enum CommunicationChannel {
  email('メール'),
  slack('Slack'),
  sms('SMS'),
  voiceCall('音声通話'),
  dashboard('ダッシュボード'),
  publicStatement('公式声明');

  final String displayName;
  const CommunicationChannel(this.displayName);
}

enum RecoveryStrategy {
  failover('フェイルオーバー'),
  restoration('復元'),
  reconstruction('再構築'),
  migration('マイグレーション'),
  workaround('ワークアラウンド');

  final String displayName;
  const RecoveryStrategy(this.displayName);
}

// ============================================================================
// MODELS
// ============================================================================

class Incident {
  final String id;
  final String title;
  final String description;
  final IncidentType type;
  final IncidentSeverity severity;
  final DateTime reportedAt;
  final String reportedBy;
  final IncidentStatus status;
  final List<String> affectedSystems;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.reportedAt,
    required this.reportedBy,
    required this.status,
    required this.affectedSystems,
  });

  bool get isCritical => severity == IncidentSeverity.critical || severity == IncidentSeverity.catastrophic;
  int get minutesElapsed => DateTime.now().difference(reportedAt).inMinutes;
  bool get isActive => status != IncidentStatus.closed;

  Incident copyWith({
    String? id,
    String? title,
    String? description,
    IncidentType? type,
    IncidentSeverity? severity,
    DateTime? reportedAt,
    String? reportedBy,
    IncidentStatus? status,
    List<String>? affectedSystems,
  }) {
    return Incident(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      reportedAt: reportedAt ?? this.reportedAt,
      reportedBy: reportedBy ?? this.reportedBy,
      status: status ?? this.status,
      affectedSystems: affectedSystems ?? this.affectedSystems,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Incident &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class IncidentTimeline {
  final String id;
  final String incidentId;
  final DateTime eventTime;
  final ResponsePhase phase;
  final String description;
  final String actor;
  final List<String> notes;

  IncidentTimeline({
    required this.id,
    required this.incidentId,
    required this.eventTime,
    required this.phase,
    required this.description,
    required this.actor,
    required this.notes,
  });

  int get ageInMinutes => DateTime.now().difference(eventTime).inMinutes;

  IncidentTimeline copyWith({
    String? id,
    String? incidentId,
    DateTime? eventTime,
    ResponsePhase? phase,
    String? description,
    String? actor,
    List<String>? notes,
  }) {
    return IncidentTimeline(
      id: id ?? this.id,
      incidentId: incidentId ?? this.incidentId,
      eventTime: eventTime ?? this.eventTime,
      phase: phase ?? this.phase,
      description: description ?? this.description,
      actor: actor ?? this.actor,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncidentTimeline &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ImpactAssessment {
  final String id;
  final String incidentId;
  final int usersAffected;
  final int systemsAffected;
  final double estimatedDataLossPercent;
  final Duration estimatedRecoveryTime;
  final double financialImpactDollars;
  final DateTime assessmentTime;
  final String assessedBy;

  ImpactAssessment({
    required this.id,
    required this.incidentId,
    required this.usersAffected,
    required this.systemsAffected,
    required this.estimatedDataLossPercent,
    required this.estimatedRecoveryTime,
    required this.financialImpactDollars,
    required this.assessmentTime,
    required this.assessedBy,
  });

  bool get isHighImpact => usersAffected > 1000 || financialImpactDollars > 100000;
  bool get hasDataLoss => estimatedDataLossPercent > 0.0;

  ImpactAssessment copyWith({
    String? id,
    String? incidentId,
    int? usersAffected,
    int? systemsAffected,
    double? estimatedDataLossPercent,
    Duration? estimatedRecoveryTime,
    double? financialImpactDollars,
    DateTime? assessmentTime,
    String? assessedBy,
  }) {
    return ImpactAssessment(
      id: id ?? this.id,
      incidentId: incidentId ?? this.incidentId,
      usersAffected: usersAffected ?? this.usersAffected,
      systemsAffected: systemsAffected ?? this.systemsAffected,
      estimatedDataLossPercent: estimatedDataLossPercent ?? this.estimatedDataLossPercent,
      estimatedRecoveryTime: estimatedRecoveryTime ?? this.estimatedRecoveryTime,
      financialImpactDollars: financialImpactDollars ?? this.financialImpactDollars,
      assessmentTime: assessmentTime ?? this.assessmentTime,
      assessedBy: assessedBy ?? this.assessedBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImpactAssessment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ResponseAction {
  final String id;
  final String incidentId;
  final String title;
  final String description;
  final DateTime initiatedAt;
  final DateTime? completedAt;
  final String assignedTo;
  final double progressPercent;
  final List<String> outcomes;

  ResponseAction({
    required this.id,
    required this.incidentId,
    required this.title,
    required this.description,
    required this.initiatedAt,
    this.completedAt,
    required this.assignedTo,
    required this.progressPercent,
    required this.outcomes,
  });

  bool get isCompleted => progressPercent >= 100.0;
  int get durationMinutes => completedAt != null
      ? completedAt!.difference(initiatedAt).inMinutes
      : DateTime.now().difference(initiatedAt).inMinutes;

  ResponseAction copyWith({
    String? id,
    String? incidentId,
    String? title,
    String? description,
    DateTime? initiatedAt,
    DateTime? completedAt,
    String? assignedTo,
    double? progressPercent,
    List<String>? outcomes,
  }) {
    return ResponseAction(
      id: id ?? this.id,
      incidentId: incidentId ?? this.incidentId,
      title: title ?? this.title,
      description: description ?? this.description,
      initiatedAt: initiatedAt ?? this.initiatedAt,
      completedAt: completedAt ?? this.completedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      progressPercent: progressPercent ?? this.progressPercent,
      outcomes: outcomes ?? this.outcomes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseAction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CrisisCommunication {
  final String id;
  final String incidentId;
  final CommunicationChannel channel;
  final String recipient;
  final String message;
  final DateTime sentAt;
  final bool acknowledged;
  final DateTime? acknowledgedAt;
  final String sentBy;

  CrisisCommunication({
    required this.id,
    required this.incidentId,
    required this.channel,
    required this.recipient,
    required this.message,
    required this.sentAt,
    required this.acknowledged,
    this.acknowledgedAt,
    required this.sentBy,
  });

  bool get isPending => !acknowledged;
  int get minutesSinceSent => DateTime.now().difference(sentAt).inMinutes;

  CrisisCommunication copyWith({
    String? id,
    String? incidentId,
    CommunicationChannel? channel,
    String? recipient,
    String? message,
    DateTime? sentAt,
    bool? acknowledged,
    DateTime? acknowledgedAt,
    String? sentBy,
  }) {
    return CrisisCommunication(
      id: id ?? this.id,
      incidentId: incidentId ?? this.incidentId,
      channel: channel ?? this.channel,
      recipient: recipient ?? this.recipient,
      message: message ?? this.message,
      sentAt: sentAt ?? this.sentAt,
      acknowledged: acknowledged ?? this.acknowledged,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      sentBy: sentBy ?? this.sentBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrisisCommunication &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class RecoveryPlan {
  final String id;
  final String incidentId;
  final RecoveryStrategy strategy;
  final String description;
  final DateTime plannedStartTime;
  final Duration estimatedDuration;
  final List<String> steps;
  final List<String> dependencies;
  final String owner;

  RecoveryPlan({
    required this.id,
    required this.incidentId,
    required this.strategy,
    required this.description,
    required this.plannedStartTime,
    required this.estimatedDuration,
    required this.steps,
    required this.dependencies,
    required this.owner,
  });

  DateTime get estimatedCompletionTime => plannedStartTime.add(estimatedDuration);
  bool get isDue => DateTime.now().isAfter(plannedStartTime);

  RecoveryPlan copyWith({
    String? id,
    String? incidentId,
    RecoveryStrategy? strategy,
    String? description,
    DateTime? plannedStartTime,
    Duration? estimatedDuration,
    List<String>? steps,
    List<String>? dependencies,
    String? owner,
  }) {
    return RecoveryPlan(
      id: id ?? this.id,
      incidentId: incidentId ?? this.incidentId,
      strategy: strategy ?? this.strategy,
      description: description ?? this.description,
      plannedStartTime: plannedStartTime ?? this.plannedStartTime,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      steps: steps ?? this.steps,
      dependencies: dependencies ?? this.dependencies,
      owner: owner ?? this.owner,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecoveryPlan &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PostIncidentReview {
  final String id;
  final String incidentId;
  final DateTime reviewDate;
  final String reviewedBy;
  final String rootCause;
  final List<String> contributingFactors;
  final List<String> lessons;
  final List<String> actionItems;
  final bool completed;

  PostIncidentReview({
    required this.id,
    required this.incidentId,
    required this.reviewDate,
    required this.reviewedBy,
    required this.rootCause,
    required this.contributingFactors,
    required this.lessons,
    required this.actionItems,
    required this.completed,
  });

  int get daysSinceReview => DateTime.now().difference(reviewDate).inDays;
  int get pendingActionItems => actionItems.length;

  PostIncidentReview copyWith({
    String? id,
    String? incidentId,
    DateTime? reviewDate,
    String? reviewedBy,
    String? rootCause,
    List<String>? contributingFactors,
    List<String>? lessons,
    List<String>? actionItems,
    bool? completed,
  }) {
    return PostIncidentReview(
      id: id ?? this.id,
      incidentId: incidentId ?? this.incidentId,
      reviewDate: reviewDate ?? this.reviewDate,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      rootCause: rootCause ?? this.rootCause,
      contributingFactors: contributingFactors ?? this.contributingFactors,
      lessons: lessons ?? this.lessons,
      actionItems: actionItems ?? this.actionItems,
      completed: completed ?? this.completed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostIncidentReview &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class EscalationPath {
  final String id;
  final String incidentId;
  final List<String> escalationOrder;
  final DateTime escalatedAt;
  final IncidentSeverity escalationReason;
  final String escalatedBy;
  final String? currentEscalationLevel;

  EscalationPath({
    required this.id,
    required this.incidentId,
    required this.escalationOrder,
    required this.escalatedAt,
    required this.escalationReason,
    required this.escalatedBy,
    this.currentEscalationLevel,
  });

  int get escalationCount => escalationOrder.length;
  int get minutesElapsedSinceEscalation => DateTime.now().difference(escalatedAt).inMinutes;

  EscalationPath copyWith({
    String? id,
    String? incidentId,
    List<String>? escalationOrder,
    DateTime? escalatedAt,
    IncidentSeverity? escalationReason,
    String? escalatedBy,
    String? currentEscalationLevel,
  }) {
    return EscalationPath(
      id: id ?? this.id,
      incidentId: incidentId ?? this.incidentId,
      escalationOrder: escalationOrder ?? this.escalationOrder,
      escalatedAt: escalatedAt ?? this.escalatedAt,
      escalationReason: escalationReason ?? this.escalationReason,
      escalatedBy: escalatedBy ?? this.escalatedBy,
      currentEscalationLevel: currentEscalationLevel ?? this.currentEscalationLevel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EscalationPath &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ResourceAllocation {
  final String id;
  final String incidentId;
  final String resourceType;
  final int quantityAllocated;
  final DateTime allocationTime;
  final String allocatedBy;
  final List<String> assignments;
  final bool isActive;

  ResourceAllocation({
    required this.id,
    required this.incidentId,
    required this.resourceType,
    required this.quantityAllocated,
    required this.allocationTime,
    required this.allocatedBy,
    required this.assignments,
    required this.isActive,
  });

  int get hoursElapsed => DateTime.now().difference(allocationTime).inHours;
  bool get needsReallocation => !isActive;

  ResourceAllocation copyWith({
    String? id,
    String? incidentId,
    String? resourceType,
    int? quantityAllocated,
    DateTime? allocationTime,
    String? allocatedBy,
    List<String>? assignments,
    bool? isActive,
  }) {
    return ResourceAllocation(
      id: id ?? this.id,
      incidentId: incidentId ?? this.incidentId,
      resourceType: resourceType ?? this.resourceType,
      quantityAllocated: quantityAllocated ?? this.quantityAllocated,
      allocationTime: allocationTime ?? this.allocationTime,
      allocatedBy: allocatedBy ?? this.allocatedBy,
      assignments: assignments ?? this.assignments,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceAllocation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class IncidentMetrics {
  final String id;
  final String incidentId;
  final Duration timeToDetection;
  final Duration timeToContainment;
  final Duration timeToResolution;
  final int personalInvolved;
  final int meetingsHeld;
  final double costPerMinute;
  final DateTime metricsComputedAt;

  IncidentMetrics({
    required this.id,
    required this.incidentId,
    required this.timeToDetection,
    required this.timeToContainment,
    required this.timeToResolution,
    required this.personalInvolved,
    required this.meetingsHeld,
    required this.costPerMinute,
    required this.metricsComputedAt,
  });

  double get totalCost => timeToResolution.inMinutes * costPerMinute;
  Duration get totalTime => timeToResolution;

  IncidentMetrics copyWith({
    String? id,
    String? incidentId,
    Duration? timeToDetection,
    Duration? timeToContainment,
    Duration? timeToResolution,
    int? personalInvolved,
    int? meetingsHeld,
    double? costPerMinute,
    DateTime? metricsComputedAt,
  }) {
    return IncidentMetrics(
      id: id ?? this.id,
      incidentId: incidentId ?? this.incidentId,
      timeToDetection: timeToDetection ?? this.timeToDetection,
      timeToContainment: timeToContainment ?? this.timeToContainment,
      timeToResolution: timeToResolution ?? this.timeToResolution,
      personalInvolved: personalInvolved ?? this.personalInvolved,
      meetingsHeld: meetingsHeld ?? this.meetingsHeld,
      costPerMinute: costPerMinute ?? this.costPerMinute,
      metricsComputedAt: metricsComputedAt ?? this.metricsComputedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncidentMetrics &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
