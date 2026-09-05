import 'package:flutter/foundation.dart';

// ============================================================================
// ENUMS
// ============================================================================

enum ComplianceFramework {
  gdpr('GDPR'),
  ccpa('CCPA'),
  hipaa('HIPAA'),
  sox('SOX'),
  pci('PCI-DSS'),
  iso27001('ISO 27001');

  final String displayName;
  const ComplianceFramework(this.displayName);
}

enum RiskLevel {
  minimal('最小限'),
  low('低'),
  medium('中程度'),
  high('高'),
  critical('критичный');

  final String displayName;
  const RiskLevel(this.displayName);
}

enum ComplianceStatus {
  compliant('準拠'),
  nonCompliant('非準拠'),
  partiallyCompliant('部分的に準拠'),
  pendingReview('レビュー保留中'),
  inViolation('違反中');

  final String displayName;
  const ComplianceStatus(this.displayName);
}

enum RiskCategory {
  operational('運用上'),
  strategic('戦略的'),
  financial('財務的'),
  regulatory('規制'),
  reputational('評判');

  final String displayName;
  const RiskCategory(this.displayName);
}

enum MitigationStrategy {
  avoid('回避'),
  mitigate('軽減'),
  transfer('移行'),
  accept('受け入れ'),
  monitor('監視');

  final String displayName;
  const MitigationStrategy(this.displayName);
}

enum ControlType {
  preventive('予防的'),
  detective('検出的'),
  corrective('是正的'),
  compensating('補償的'),
  monitoring('監視的');

  final String displayName;
  const ControlType(this.displayName);
}

// ============================================================================
// MODELS
// ============================================================================

class ComplianceRequirement {
  final String id;
  final ComplianceFramework framework;
  final String title;
  final String description;
  final RiskLevel impactLevel;
  final DateTime createdAt;
  final DateTime? deadline;
  final bool isActive;
  final List<String> relatedControls;

  ComplianceRequirement({
    required this.id,
    required this.framework,
    required this.title,
    required this.description,
    required this.impactLevel,
    required this.createdAt,
    this.deadline,
    required this.isActive,
    required this.relatedControls,
  });

  bool get isOverdue => deadline != null && DateTime.now().isAfter(deadline!);
  int get daysUntilDeadline => deadline != null
      ? deadline!.difference(DateTime.now()).inDays
      : -1;

  ComplianceRequirement copyWith({
    String? id,
    ComplianceFramework? framework,
    String? title,
    String? description,
    RiskLevel? impactLevel,
    DateTime? createdAt,
    DateTime? deadline,
    bool? isActive,
    List<String>? relatedControls,
  }) {
    return ComplianceRequirement(
      id: id ?? this.id,
      framework: framework ?? this.framework,
      title: title ?? this.title,
      description: description ?? this.description,
      impactLevel: impactLevel ?? this.impactLevel,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      isActive: isActive ?? this.isActive,
      relatedControls: relatedControls ?? this.relatedControls,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplianceRequirement &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class RiskAssessment {
  final String id;
  final String assetId;
  final RiskCategory category;
  final RiskLevel likelihood;
  final RiskLevel impact;
  final double riskScore;
  final DateTime assessmentDate;
  final String description;
  final List<String> threats;

  RiskAssessment({
    required this.id,
    required this.assetId,
    required this.category,
    required this.likelihood,
    required this.impact,
    required this.riskScore,
    required this.assessmentDate,
    required this.description,
    required this.threats,
  });

  bool get isCritical => riskScore >= 0.8;
  bool get needsImmediate => riskScore >= 0.7;
  int get ageInDays => DateTime.now().difference(assessmentDate).inDays;

  RiskAssessment copyWith({
    String? id,
    String? assetId,
    RiskCategory? category,
    RiskLevel? likelihood,
    RiskLevel? impact,
    double? riskScore,
    DateTime? assessmentDate,
    String? description,
    List<String>? threats,
  }) {
    return RiskAssessment(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      category: category ?? this.category,
      likelihood: likelihood ?? this.likelihood,
      impact: impact ?? this.impact,
      riskScore: riskScore ?? this.riskScore,
      assessmentDate: assessmentDate ?? this.assessmentDate,
      description: description ?? this.description,
      threats: threats ?? this.threats,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiskAssessment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ControlActivity {
  final String id;
  final String controlId;
  final ControlType type;
  final String title;
  final String description;
  final DateTime implementedDate;
  final DateTime? nextReviewDate;
  final double effectiveness;
  final bool isActive;

  ControlActivity({
    required this.id,
    required this.controlId,
    required this.type,
    required this.title,
    required this.description,
    required this.implementedDate,
    this.nextReviewDate,
    required this.effectiveness,
    required this.isActive,
  });

  bool get isEffective => effectiveness >= 0.8;
  bool get isDueForReview => nextReviewDate != null && DateTime.now().isAfter(nextReviewDate!);
  int get ageInDays => DateTime.now().difference(implementedDate).inDays;

  ControlActivity copyWith({
    String? id,
    String? controlId,
    ControlType? type,
    String? title,
    String? description,
    DateTime? implementedDate,
    DateTime? nextReviewDate,
    double? effectiveness,
    bool? isActive,
  }) {
    return ControlActivity(
      id: id ?? this.id,
      controlId: controlId ?? this.controlId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      implementedDate: implementedDate ?? this.implementedDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      effectiveness: effectiveness ?? this.effectiveness,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ControlActivity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class AuditFinding {
  final String id;
  final String auditId;
  final String title;
  final String description;
  final RiskLevel severity;
  final ComplianceStatus status;
  final DateTime foundDate;
  final DateTime? targetRemediationDate;
  final String? remediationPlan;
  final String foundBy;

  AuditFinding({
    required this.id,
    required this.auditId,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.foundDate,
    this.targetRemediationDate,
    this.remediationPlan,
    required this.foundBy,
  });

  bool get isOverdue => targetRemediationDate != null && 
      DateTime.now().isAfter(targetRemediationDate!) &&
      status != ComplianceStatus.compliant;
  bool get isResolved => status == ComplianceStatus.compliant;
  int get daysOpen => DateTime.now().difference(foundDate).inDays;

  AuditFinding copyWith({
    String? id,
    String? auditId,
    String? title,
    String? description,
    RiskLevel? severity,
    ComplianceStatus? status,
    DateTime? foundDate,
    DateTime? targetRemediationDate,
    String? remediationPlan,
    String? foundBy,
  }) {
    return AuditFinding(
      id: id ?? this.id,
      auditId: auditId ?? this.auditId,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      foundDate: foundDate ?? this.foundDate,
      targetRemediationDate: targetRemediationDate ?? this.targetRemediationDate,
      remediationPlan: remediationPlan ?? this.remediationPlan,
      foundBy: foundBy ?? this.foundBy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuditFinding &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class MitigationAction {
  final String id;
  final String riskId;
  final MitigationStrategy strategy;
  final String title;
  final String description;
  final DateTime plannedDate;
  final DateTime? completionDate;
  final double progressPercent;
  final String owner;
  final List<String> dependencies;

  MitigationAction({
    required this.id,
    required this.riskId,
    required this.strategy,
    required this.title,
    required this.description,
    required this.plannedDate,
    this.completionDate,
    required this.progressPercent,
    required this.owner,
    required this.dependencies,
  });

  bool get isCompleted => progressPercent >= 100.0;
  bool get isOverdue => DateTime.now().isAfter(plannedDate) && !isCompleted;
  int get daysUntilDue => plannedDate.difference(DateTime.now()).inDays;

  MitigationAction copyWith({
    String? id,
    String? riskId,
    MitigationStrategy? strategy,
    String? title,
    String? description,
    DateTime? plannedDate,
    DateTime? completionDate,
    double? progressPercent,
    String? owner,
    List<String>? dependencies,
  }) {
    return MitigationAction(
      id: id ?? this.id,
      riskId: riskId ?? this.riskId,
      strategy: strategy ?? this.strategy,
      title: title ?? this.title,
      description: description ?? this.description,
      plannedDate: plannedDate ?? this.plannedDate,
      completionDate: completionDate ?? this.completionDate,
      progressPercent: progressPercent ?? this.progressPercent,
      owner: owner ?? this.owner,
      dependencies: dependencies ?? this.dependencies,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MitigationAction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ComplianceAsset {
  final String id;
  final String name;
  final String description;
  final List<ComplianceFramework> applicableFrameworks;
  final ComplianceStatus complianceStatus;
  final DateTime lastAssessmentDate;
  final DateTime? nextAssessmentDate;
  final double complianceScore;
  final List<String> openFindings;

  ComplianceAsset({
    required this.id,
    required this.name,
    required this.description,
    required this.applicableFrameworks,
    required this.complianceStatus,
    required this.lastAssessmentDate,
    this.nextAssessmentDate,
    required this.complianceScore,
    required this.openFindings,
  });

  bool get isFullyCompliant => complianceStatus == ComplianceStatus.compliant;
  bool get isDueForAssessment => nextAssessmentDate != null && DateTime.now().isAfter(nextAssessmentDate!);
  int get daysLastAssessed => DateTime.now().difference(lastAssessmentDate).inDays;

  ComplianceAsset copyWith({
    String? id,
    String? name,
    String? description,
    List<ComplianceFramework>? applicableFrameworks,
    ComplianceStatus? complianceStatus,
    DateTime? lastAssessmentDate,
    DateTime? nextAssessmentDate,
    double? complianceScore,
    List<String>? openFindings,
  }) {
    return ComplianceAsset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      applicableFrameworks: applicableFrameworks ?? this.applicableFrameworks,
      complianceStatus: complianceStatus ?? this.complianceStatus,
      lastAssessmentDate: lastAssessmentDate ?? this.lastAssessmentDate,
      nextAssessmentDate: nextAssessmentDate ?? this.nextAssessmentDate,
      complianceScore: complianceScore ?? this.complianceScore,
      openFindings: openFindings ?? this.openFindings,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplianceAsset &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class RegulatoryEvent {
  final String id;
  final String title;
  final String description;
  final ComplianceFramework framework;
  final DateTime eventDate;
  final DateTime? deadline;
  final String category;
  final bool isCompleted;
  final List<String> affectedSystems;

  RegulatoryEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.framework,
    required this.eventDate,
    this.deadline,
    required this.category,
    required this.isCompleted,
    required this.affectedSystems,
  });

  bool get isOverdue => deadline != null && DateTime.now().isAfter(deadline!) && !isCompleted;
  int get daysUntilDeadline => deadline != null ? deadline!.difference(DateTime.now()).inDays : -1;

  RegulatoryEvent copyWith({
    String? id,
    String? title,
    String? description,
    ComplianceFramework? framework,
    DateTime? eventDate,
    DateTime? deadline,
    String? category,
    bool? isCompleted,
    List<String>? affectedSystems,
  }) {
    return RegulatoryEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      framework: framework ?? this.framework,
      eventDate: eventDate ?? this.eventDate,
      deadline: deadline ?? this.deadline,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      affectedSystems: affectedSystems ?? this.affectedSystems,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegulatoryEvent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CompliancePolicy {
  final String id;
  final String policyName;
  final String purpose;
  final List<ComplianceFramework> relatedFrameworks;
  final DateTime createdDate;
  final DateTime lastUpdatedDate;
  final int version;
  final bool isActive;
  final List<String> stakeholders;

  CompliancePolicy({
    required this.id,
    required this.policyName,
    required this.purpose,
    required this.relatedFrameworks,
    required this.createdDate,
    required this.lastUpdatedDate,
    required this.version,
    required this.isActive,
    required this.stakeholders,
  });

  int get ageInDays => DateTime.now().difference(lastUpdatedDate).inDays;
  bool get needsReview => ageInDays > 365;

  CompliancePolicy copyWith({
    String? id,
    String? policyName,
    String? purpose,
    List<ComplianceFramework>? relatedFrameworks,
    DateTime? createdDate,
    DateTime? lastUpdatedDate,
    int? version,
    bool? isActive,
    List<String>? stakeholders,
  }) {
    return CompliancePolicy(
      id: id ?? this.id,
      policyName: policyName ?? this.policyName,
      purpose: purpose ?? this.purpose,
      relatedFrameworks: relatedFrameworks ?? this.relatedFrameworks,
      createdDate: createdDate ?? this.createdDate,
      lastUpdatedDate: lastUpdatedDate ?? this.lastUpdatedDate,
      version: version ?? this.version,
      isActive: isActive ?? this.isActive,
      stakeholders: stakeholders ?? this.stakeholders,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompliancePolicy &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class RiskRegister {
  final String id;
  final String riskId;
  final String title;
  final String description;
  final RiskCategory category;
  final RiskLevel inherentRisk;
  final RiskLevel residualRisk;
  final DateTime identifiedDate;
  final String owner;
  final List<String> mitigations;

  RiskRegister({
    required this.id,
    required this.riskId,
    required this.title,
    required this.description,
    required this.category,
    required this.inherentRisk,
    required this.residualRisk,
    required this.identifiedDate,
    required this.owner,
    required this.mitigations,
  });

  bool get riskReduced => residualRisk.index < inherentRisk.index;
  int get ageInDays => DateTime.now().difference(identifiedDate).inDays;

  RiskRegister copyWith({
    String? id,
    String? riskId,
    String? title,
    String? description,
    RiskCategory? category,
    RiskLevel? inherentRisk,
    RiskLevel? residualRisk,
    DateTime? identifiedDate,
    String? owner,
    List<String>? mitigations,
  }) {
    return RiskRegister(
      id: id ?? this.id,
      riskId: riskId ?? this.riskId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      inherentRisk: inherentRisk ?? this.inherentRisk,
      residualRisk: residualRisk ?? this.residualRisk,
      identifiedDate: identifiedDate ?? this.identifiedDate,
      owner: owner ?? this.owner,
      mitigations: mitigations ?? this.mitigations,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiskRegister &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
