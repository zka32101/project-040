import 'package:project_040/models/compliance_models.dart';

// ============================================================================
// REPOSITORY INTERFACE
// ============================================================================

abstract class ComplianceRepository {
  // Compliance Requirements (10 methods)
  Future<void> createComplianceRequirement(ComplianceRequirement requirement);
  Future<ComplianceRequirement?> getComplianceRequirement(String id);
  Future<List<ComplianceRequirement>> getAllRequirements();
  Future<void> updateComplianceRequirement(ComplianceRequirement requirement);
  Future<void> deleteComplianceRequirement(String id);
  Future<List<ComplianceRequirement>> getRequirementsByFramework(ComplianceFramework framework);
  Future<List<ComplianceRequirement>> getOverdueRequirements();
  Future<int> countActiveRequirements();
  Future<void> deleteAllRequirements();
  Future<List<ComplianceRequirement>> getUrgentRequirements();

  // Risk Assessments (12 methods)
  Future<void> createRiskAssessment(RiskAssessment assessment);
  Future<RiskAssessment?> getRiskAssessment(String id);
  Future<List<RiskAssessment>> getAllAssessments();
  Future<void> updateRiskAssessment(RiskAssessment assessment);
  Future<void> deleteRiskAssessment(String id);
  Future<List<RiskAssessment>> getAssessmentsByCategory(RiskCategory category);
  Future<List<RiskAssessment>> getCriticalRisks();
  Future<double> getAverageRiskScore();
  Future<int> countAssessments();
  Future<void> deleteAllAssessments();
  Future<List<RiskAssessment>> getAssetRisks(String assetId);
  Future<List<RiskAssessment>> getRecentRisks(int daysBack);

  // Control Activities (10 methods)
  Future<void> createControlActivity(ControlActivity control);
  Future<ControlActivity?> getControlActivity(String id);
  Future<List<ControlActivity>> getAllControls();
  Future<void> updateControlActivity(ControlActivity control);
  Future<void> deleteControlActivity(String id);
  Future<List<ControlActivity>> getControlsByType(ControlType type);
  Future<List<ControlActivity>> getIneffectiveControls();
  Future<int> countControls();
  Future<void> deleteAllControls();
  Future<List<ControlActivity>> getControlsDueForReview();

  // Audit Findings (12 methods)
  Future<void> createAuditFinding(AuditFinding finding);
  Future<AuditFinding?> getAuditFinding(String id);
  Future<List<AuditFinding>> getAllFindings();
  Future<void> updateAuditFinding(AuditFinding finding);
  Future<void> deleteAuditFinding(String id);
  Future<List<AuditFinding>> getFindingsByAudit(String auditId);
  Future<List<AuditFinding>> getOpenFindings();
  Future<List<AuditFinding>> getOverdueFindings();
  Future<int> countFindings();
  Future<void> deleteAllFindings();
  Future<List<AuditFinding>> getFindingsBySeverity(RiskLevel severity);
  Future<int> countResolvedFindings();

  // Mitigation Actions (10 methods)
  Future<void> createMitigationAction(MitigationAction action);
  Future<MitigationAction?> getMitigationAction(String id);
  Future<List<MitigationAction>> getAllActions();
  Future<void> updateMitigationAction(MitigationAction action);
  Future<void> deleteMitigationAction(String id);
  Future<List<MitigationAction>> getActionsByRisk(String riskId);
  Future<List<MitigationAction>> getOverdueActions();
  Future<int> countActions();
  Future<void> deleteAllActions();
  Future<List<MitigationAction>> getCompletedActions();

  // Compliance Assets (10 methods)
  Future<void> createComplianceAsset(ComplianceAsset asset);
  Future<ComplianceAsset?> getComplianceAsset(String id);
  Future<List<ComplianceAsset>> getAllAssets();
  Future<void> updateComplianceAsset(ComplianceAsset asset);
  Future<void> deleteComplianceAsset(String id);
  Future<List<ComplianceAsset>> getAssetsByFramework(ComplianceFramework framework);
  Future<List<ComplianceAsset>> getNonCompliantAssets();
  Future<int> countAssets();
  Future<void> deleteAllAssets();
  Future<double> getAverageComplianceScore();

  // Regulatory Events (8 methods)
  Future<void> createRegulatoryEvent(RegulatoryEvent event);
  Future<RegulatoryEvent?> getRegulatoryEvent(String id);
  Future<List<RegulatoryEvent>> getAllEvents();
  Future<void> updateRegulatoryEvent(RegulatoryEvent event);
  Future<void> deleteRegulatoryEvent(String id);
  Future<List<RegulatoryEvent>> getEventsByFramework(ComplianceFramework framework);
  Future<int> countEvents();
  Future<void> deleteAllEvents();

  // Compliance Policies (8 methods)
  Future<void> createCompliancePolicy(CompliancePolicy policy);
  Future<CompliancePolicy?> getCompliancePolicy(String id);
  Future<List<CompliancePolicy>> getAllPolicies();
  Future<void> updateCompliancePolicy(CompliancePolicy policy);
  Future<void> deleteCompliancePolicy(String id);
  Future<List<CompliancePolicy>> getPoliciesDueForReview();
  Future<int> countPolicies();
  Future<void> deleteAllPolicies();

  // Risk Register (10 methods)
  Future<void> createRiskRegister(RiskRegister register);
  Future<RiskRegister?> getRiskRegister(String id);
  Future<List<RiskRegister>> getAllRegisters();
  Future<void> updateRiskRegister(RiskRegister register);
  Future<void> deleteRiskRegister(String id);
  Future<List<RiskRegister>> getRegistersByCategory(RiskCategory category);
  Future<List<RiskRegister>> getRegistersByOwner(String owner);
  Future<int> countRegisters();
  Future<void> deleteAllRegisters();
  Future<List<RiskRegister>> getMitigatedRisks();
}

// ============================================================================
// IN-MEMORY REPOSITORY IMPLEMENTATION
// ============================================================================

class InMemoryComplianceRepository implements ComplianceRepository {
  final Map<String, ComplianceRequirement> _requirements = {};
  final Map<String, RiskAssessment> _assessments = {};
  final Map<String, ControlActivity> _controls = {};
  final Map<String, AuditFinding> _findings = {};
  final Map<String, MitigationAction> _actions = {};
  final Map<String, ComplianceAsset> _assets = {};
  final Map<String, RegulatoryEvent> _events = {};
  final Map<String, CompliancePolicy> _policies = {};
  final Map<String, RiskRegister> _registers = {};

  // Compliance Requirements Implementation
  @override
  Future<void> createComplianceRequirement(ComplianceRequirement requirement) async {
    _requirements[requirement.id] = requirement;
  }

  @override
  Future<ComplianceRequirement?> getComplianceRequirement(String id) async {
    return _requirements[id];
  }

  @override
  Future<List<ComplianceRequirement>> getAllRequirements() async {
    return _requirements.values.toList();
  }

  @override
  Future<void> updateComplianceRequirement(ComplianceRequirement requirement) async {
    _requirements[requirement.id] = requirement;
  }

  @override
  Future<void> deleteComplianceRequirement(String id) async {
    _requirements.remove(id);
  }

  @override
  Future<List<ComplianceRequirement>> getRequirementsByFramework(ComplianceFramework framework) async {
    return _requirements.values.where((r) => r.framework == framework).toList();
  }

  @override
  Future<List<ComplianceRequirement>> getOverdueRequirements() async {
    return _requirements.values.where((r) => r.isOverdue).toList();
  }

  @override
  Future<int> countActiveRequirements() async {
    return _requirements.values.where((r) => r.isActive).length;
  }

  @override
  Future<void> deleteAllRequirements() async {
    _requirements.clear();
  }

  @override
  Future<List<ComplianceRequirement>> getUrgentRequirements() async {
    return _requirements.values.where((r) => r.impactLevel == RiskLevel.critical && r.isActive).toList();
  }

  // Risk Assessments Implementation
  @override
  Future<void> createRiskAssessment(RiskAssessment assessment) async {
    _assessments[assessment.id] = assessment;
  }

  @override
  Future<RiskAssessment?> getRiskAssessment(String id) async {
    return _assessments[id];
  }

  @override
  Future<List<RiskAssessment>> getAllAssessments() async {
    return _assessments.values.toList();
  }

  @override
  Future<void> updateRiskAssessment(RiskAssessment assessment) async {
    _assessments[assessment.id] = assessment;
  }

  @override
  Future<void> deleteRiskAssessment(String id) async {
    _assessments.remove(id);
  }

  @override
  Future<List<RiskAssessment>> getAssessmentsByCategory(RiskCategory category) async {
    return _assessments.values.where((a) => a.category == category).toList();
  }

  @override
  Future<List<RiskAssessment>> getCriticalRisks() async {
    return _assessments.values.where((a) => a.isCritical).toList();
  }

  @override
  Future<double> getAverageRiskScore() async {
    if (_assessments.isEmpty) return 0.0;
    final sum = _assessments.values.fold<double>(0.0, (acc, a) => acc + a.riskScore);
    return sum / _assessments.length;
  }

  @override
  Future<int> countAssessments() async {
    return _assessments.length;
  }

  @override
  Future<void> deleteAllAssessments() async {
    _assessments.clear();
  }

  @override
  Future<List<RiskAssessment>> getAssetRisks(String assetId) async {
    return _assessments.values.where((a) => a.assetId == assetId).toList();
  }

  @override
  Future<List<RiskAssessment>> getRecentRisks(int daysBack) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysBack));
    return _assessments.values.where((a) => a.assessmentDate.isAfter(cutoff)).toList();
  }

  // Control Activities Implementation
  @override
  Future<void> createControlActivity(ControlActivity control) async {
    _controls[control.id] = control;
  }

  @override
  Future<ControlActivity?> getControlActivity(String id) async {
    return _controls[id];
  }

  @override
  Future<List<ControlActivity>> getAllControls() async {
    return _controls.values.toList();
  }

  @override
  Future<void> updateControlActivity(ControlActivity control) async {
    _controls[control.id] = control;
  }

  @override
  Future<void> deleteControlActivity(String id) async {
    _controls.remove(id);
  }

  @override
  Future<List<ControlActivity>> getControlsByType(ControlType type) async {
    return _controls.values.where((c) => c.type == type).toList();
  }

  @override
  Future<List<ControlActivity>> getIneffectiveControls() async {
    return _controls.values.where((c) => !c.isEffective).toList();
  }

  @override
  Future<int> countControls() async {
    return _controls.length;
  }

  @override
  Future<void> deleteAllControls() async {
    _controls.clear();
  }

  @override
  Future<List<ControlActivity>> getControlsDueForReview() async {
    return _controls.values.where((c) => c.isDueForReview).toList();
  }

  // Audit Findings Implementation
  @override
  Future<void> createAuditFinding(AuditFinding finding) async {
    _findings[finding.id] = finding;
  }

  @override
  Future<AuditFinding?> getAuditFinding(String id) async {
    return _findings[id];
  }

  @override
  Future<List<AuditFinding>> getAllFindings() async {
    return _findings.values.toList();
  }

  @override
  Future<void> updateAuditFinding(AuditFinding finding) async {
    _findings[finding.id] = finding;
  }

  @override
  Future<void> deleteAuditFinding(String id) async {
    _findings.remove(id);
  }

  @override
  Future<List<AuditFinding>> getFindingsByAudit(String auditId) async {
    return _findings.values.where((f) => f.auditId == auditId).toList();
  }

  @override
  Future<List<AuditFinding>> getOpenFindings() async {
    return _findings.values.where((f) => f.status != ComplianceStatus.compliant).toList();
  }

  @override
  Future<List<AuditFinding>> getOverdueFindings() async {
    return _findings.values.where((f) => f.isOverdue).toList();
  }

  @override
  Future<int> countFindings() async {
    return _findings.length;
  }

  @override
  Future<void> deleteAllFindings() async {
    _findings.clear();
  }

  @override
  Future<List<AuditFinding>> getFindingsBySeverity(RiskLevel severity) async {
    return _findings.values.where((f) => f.severity == severity).toList();
  }

  @override
  Future<int> countResolvedFindings() async {
    return _findings.values.where((f) => f.isResolved).length;
  }

  // Mitigation Actions Implementation
  @override
  Future<void> createMitigationAction(MitigationAction action) async {
    _actions[action.id] = action;
  }

  @override
  Future<MitigationAction?> getMitigationAction(String id) async {
    return _actions[id];
  }

  @override
  Future<List<MitigationAction>> getAllActions() async {
    return _actions.values.toList();
  }

  @override
  Future<void> updateMitigationAction(MitigationAction action) async {
    _actions[action.id] = action;
  }

  @override
  Future<void> deleteMitigationAction(String id) async {
    _actions.remove(id);
  }

  @override
  Future<List<MitigationAction>> getActionsByRisk(String riskId) async {
    return _actions.values.where((a) => a.riskId == riskId).toList();
  }

  @override
  Future<List<MitigationAction>> getOverdueActions() async {
    return _actions.values.where((a) => a.isOverdue).toList();
  }

  @override
  Future<int> countActions() async {
    return _actions.length;
  }

  @override
  Future<void> deleteAllActions() async {
    _actions.clear();
  }

  @override
  Future<List<MitigationAction>> getCompletedActions() async {
    return _actions.values.where((a) => a.isCompleted).toList();
  }

  // Compliance Assets Implementation
  @override
  Future<void> createComplianceAsset(ComplianceAsset asset) async {
    _assets[asset.id] = asset;
  }

  @override
  Future<ComplianceAsset?> getComplianceAsset(String id) async {
    return _assets[id];
  }

  @override
  Future<List<ComplianceAsset>> getAllAssets() async {
    return _assets.values.toList();
  }

  @override
  Future<void> updateComplianceAsset(ComplianceAsset asset) async {
    _assets[asset.id] = asset;
  }

  @override
  Future<void> deleteComplianceAsset(String id) async {
    _assets.remove(id);
  }

  @override
  Future<List<ComplianceAsset>> getAssetsByFramework(ComplianceFramework framework) async {
    return _assets.values.where((a) => a.applicableFrameworks.contains(framework)).toList();
  }

  @override
  Future<List<ComplianceAsset>> getNonCompliantAssets() async {
    return _assets.values.where((a) => a.complianceStatus != ComplianceStatus.compliant).toList();
  }

  @override
  Future<int> countAssets() async {
    return _assets.length;
  }

  @override
  Future<void> deleteAllAssets() async {
    _assets.clear();
  }

  @override
  Future<double> getAverageComplianceScore() async {
    if (_assets.isEmpty) return 0.0;
    final sum = _assets.values.fold<double>(0.0, (acc, a) => acc + a.complianceScore);
    return sum / _assets.length;
  }

  // Regulatory Events Implementation
  @override
  Future<void> createRegulatoryEvent(RegulatoryEvent event) async {
    _events[event.id] = event;
  }

  @override
  Future<RegulatoryEvent?> getRegulatoryEvent(String id) async {
    return _events[id];
  }

  @override
  Future<List<RegulatoryEvent>> getAllEvents() async {
    return _events.values.toList();
  }

  @override
  Future<void> updateRegulatoryEvent(RegulatoryEvent event) async {
    _events[event.id] = event;
  }

  @override
  Future<void> deleteRegulatoryEvent(String id) async {
    _events.remove(id);
  }

  @override
  Future<List<RegulatoryEvent>> getEventsByFramework(ComplianceFramework framework) async {
    return _events.values.where((e) => e.framework == framework).toList();
  }

  @override
  Future<int> countEvents() async {
    return _events.length;
  }

  @override
  Future<void> deleteAllEvents() async {
    _events.clear();
  }

  // Compliance Policies Implementation
  @override
  Future<void> createCompliancePolicy(CompliancePolicy policy) async {
    _policies[policy.id] = policy;
  }

  @override
  Future<CompliancePolicy?> getCompliancePolicy(String id) async {
    return _policies[id];
  }

  @override
  Future<List<CompliancePolicy>> getAllPolicies() async {
    return _policies.values.toList();
  }

  @override
  Future<void> updateCompliancePolicy(CompliancePolicy policy) async {
    _policies[policy.id] = policy;
  }

  @override
  Future<void> deleteCompliancePolicy(String id) async {
    _policies.remove(id);
  }

  @override
  Future<List<CompliancePolicy>> getPoliciesDueForReview() async {
    return _policies.values.where((p) => p.needsReview).toList();
  }

  @override
  Future<int> countPolicies() async {
    return _policies.length;
  }

  @override
  Future<void> deleteAllPolicies() async {
    _policies.clear();
  }

  // Risk Register Implementation
  @override
  Future<void> createRiskRegister(RiskRegister register) async {
    _registers[register.id] = register;
  }

  @override
  Future<RiskRegister?> getRiskRegister(String id) async {
    return _registers[id];
  }

  @override
  Future<List<RiskRegister>> getAllRegisters() async {
    return _registers.values.toList();
  }

  @override
  Future<void> updateRiskRegister(RiskRegister register) async {
    _registers[register.id] = register;
  }

  @override
  Future<void> deleteRiskRegister(String id) async {
    _registers.remove(id);
  }

  @override
  Future<List<RiskRegister>> getRegistersByCategory(RiskCategory category) async {
    return _registers.values.where((r) => r.category == category).toList();
  }

  @override
  Future<List<RiskRegister>> getRegistersByOwner(String owner) async {
    return _registers.values.where((r) => r.owner == owner).toList();
  }

  @override
  Future<int> countRegisters() async {
    return _registers.length;
  }

  @override
  Future<void> deleteAllRegisters() async {
    _registers.clear();
  }

  @override
  Future<List<RiskRegister>> getMitigatedRisks() async {
    return _registers.values.where((r) => r.riskReduced).toList();
  }
}

// ============================================================================
// ENGINES
// ============================================================================

class ComplianceCheckEngine {
  Future<ComplianceStatus> checkCompliance(ComplianceAsset asset) async {
    if (asset.complianceScore >= 0.95) {
      return ComplianceStatus.compliant;
    } else if (asset.complianceScore >= 0.80) {
      return ComplianceStatus.partiallyCompliant;
    } else if (asset.complianceScore >= 0.60) {
      return ComplianceStatus.nonCompliant;
    }
    return ComplianceStatus.inViolation;
  }

  Future<List<String>> identifyGaps(ComplianceAsset asset, ComplianceFramework framework) async {
    final gaps = <String>[];
    if (asset.complianceScore < 0.80) {
      gaps.add('Critical controls missing');
      gaps.add('Documentation incomplete');
      gaps.add('Evidence of implementation not found');
    }
    return gaps;
  }
}

class RiskScoringEngine {
  Future<double> calculateRiskScore(RiskAssessment assessment) async {
    final likelihoodScore = assessment.likelihood.index / 4.0;
    final impactScore = assessment.impact.index / 4.0;
    return (likelihoodScore + impactScore) / 2.0;
  }

  Future<RiskLevel> assessRiskLevel(double riskScore) async {
    if (riskScore >= 0.8) return RiskLevel.critical;
    if (riskScore >= 0.6) return RiskLevel.high;
    if (riskScore >= 0.4) return RiskLevel.medium;
    if (riskScore >= 0.2) return RiskLevel.low;
    return RiskLevel.minimal;
  }
}

class MitigationPlanningEngine {
  Future<MitigationStrategy> recommendStrategy(double riskScore) async {
    if (riskScore >= 0.8) return MitigationStrategy.avoid;
    if (riskScore >= 0.6) return MitigationStrategy.mitigate;
    if (riskScore >= 0.4) return MitigationStrategy.transfer;
    if (riskScore >= 0.2) return MitigationStrategy.monitor;
    return MitigationStrategy.accept;
  }

  Future<List<String>> generateActions(RiskAssessment risk, MitigationStrategy strategy) async {
    return [
      'Define $strategy action plan',
      'Assign ownership and accountability',
      'Set realistic timeline and milestones',
      'Monitor and report progress',
    ];
  }
}

class AuditTrailEngine {
  Future<List<String>> generateAuditTrail(ComplianceRequirement requirement) async {
    return [
      'Requirement created: ${requirement.createdAt}',
      'Framework: ${requirement.framework.displayName}',
      'Status: ${requirement.isActive ? "Active" : "Inactive"}',
      'Compliance assessment: Ongoing',
    ];
  }

  Future<Map<String, dynamic>> createAuditReport() async {
    return {
      'reportDate': DateTime.now(),
      'totalAssets': 0,
      'compliantAssets': 0,
      'nonCompliantAssets': 0,
      'findingsCount': 0,
      'openFindings': 0,
      'resolvedFindings': 0,
    };
  }
}

class ControlEffectivenessEngine {
  Future<bool> evaluateControl(ControlActivity control) async {
    return control.isEffective && control.isActive;
  }

  Future<List<ControlActivity>> identifyGapControls(List<ControlActivity> controls) async {
    return controls.where((c) => !c.isEffective || !c.isActive).toList();
  }
}

// ============================================================================
// MANAGER
// ============================================================================

class ComplianceManager {
  final ComplianceRepository repository;
  final ComplianceCheckEngine checkEngine = ComplianceCheckEngine();
  final RiskScoringEngine riskEngine = RiskScoringEngine();
  final MitigationPlanningEngine mitigationEngine = MitigationPlanningEngine();
  final AuditTrailEngine auditEngine = AuditTrailEngine();
  final ControlEffectivenessEngine controlEngine = ControlEffectivenessEngine();

  ComplianceManager(this.repository);

  Future<ComplianceStatus> assessAssetCompliance(String assetId) async {
    final asset = await repository.getComplianceAsset(assetId);
    if (asset == null) return ComplianceStatus.nonCompliant;
    return checkEngine.checkCompliance(asset);
  }

  Future<double> assessRiskProfile(String riskId) async {
    final assessment = await repository.getRiskAssessment(riskId);
    if (assessment == null) return 0.0;
    return riskEngine.calculateRiskScore(assessment);
  }

  Future<List<AuditFinding>> getComplianceFindings() async {
    return repository.getAllFindings();
  }
}

// ============================================================================
// FACADE
// ============================================================================

class ComplianceFacade {
  final ComplianceManager manager;

  ComplianceFacade(this.manager);

  Future<ComplianceRequirement> createRequirement(
    String title,
    String description,
    ComplianceFramework framework,
  ) async {
    final requirement = ComplianceRequirement(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      framework: framework,
      title: title,
      description: description,
      impactLevel: RiskLevel.high,
      createdAt: DateTime.now(),
      deadline: DateTime.now().add(const Duration(days: 90)),
      isActive: true,
      relatedControls: [],
    );
    await manager.repository.createComplianceRequirement(requirement);
    return requirement;
  }

  Future<RiskAssessment> assessRisk(
    String assetId,
    RiskCategory category,
    RiskLevel likelihood,
    RiskLevel impact,
  ) async {
    final riskScore = ((likelihood.index + impact.index) / 2.0) / 4.0;
    final assessment = RiskAssessment(
      id: 'risk_${DateTime.now().millisecondsSinceEpoch}',
      assetId: assetId,
      category: category,
      likelihood: likelihood,
      impact: impact,
      riskScore: riskScore,
      assessmentDate: DateTime.now(),
      description: 'Risk assessment for $assetId',
      threats: [],
    );
    await manager.repository.createRiskAssessment(assessment);
    return assessment;
  }

  Future<ControlActivity> implementControl(
    String title,
    ControlType type,
    double effectiveness,
  ) async {
    final control = ControlActivity(
      id: 'ctrl_${DateTime.now().millisecondsSinceEpoch}',
      controlId: 'ctrl_id',
      type: type,
      title: title,
      description: 'Control implementation',
      implementedDate: DateTime.now(),
      nextReviewDate: DateTime.now().add(const Duration(days: 180)),
      effectiveness: effectiveness,
      isActive: true,
    );
    await manager.repository.createControlActivity(control);
    return control;
  }

  Future<AuditFinding> logFinding(
    String auditId,
    String title,
    RiskLevel severity,
  ) async {
    final finding = AuditFinding(
      id: 'find_${DateTime.now().millisecondsSinceEpoch}',
      auditId: auditId,
      title: title,
      description: 'Audit finding',
      severity: severity,
      status: ComplianceStatus.nonCompliant,
      foundDate: DateTime.now(),
      targetRemediationDate: DateTime.now().add(const Duration(days: 30)),
      foundBy: 'Audit Team',
    );
    await manager.repository.createAuditFinding(finding);
    return finding;
  }

  Future<MitigationAction> createMitigation(
    String riskId,
    MitigationStrategy strategy,
    String title,
  ) async {
    final action = MitigationAction(
      id: 'mit_${DateTime.now().millisecondsSinceEpoch}',
      riskId: riskId,
      strategy: strategy,
      title: title,
      description: 'Mitigation action',
      plannedDate: DateTime.now().add(const Duration(days: 30)),
      progressPercent: 0.0,
      owner: 'Risk Owner',
      dependencies: [],
    );
    await manager.repository.createMitigationAction(action);
    return action;
  }

  Future<ComplianceAsset> registerAsset(
    String name,
    List<ComplianceFramework> frameworks,
  ) async {
    final asset = ComplianceAsset(
      id: 'asset_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: 'Compliance asset',
      applicableFrameworks: frameworks,
      complianceStatus: ComplianceStatus.pendingReview,
      lastAssessmentDate: DateTime.now(),
      nextAssessmentDate: DateTime.now().add(const Duration(days: 180)),
      complianceScore: 0.0,
      openFindings: [],
    );
    await manager.repository.createComplianceAsset(asset);
    return asset;
  }

  Future<CompliancePolicy> createPolicy(
    String name,
    List<ComplianceFramework> frameworks,
  ) async {
    final policy = CompliancePolicy(
      id: 'policy_${DateTime.now().millisecondsSinceEpoch}',
      policyName: name,
      purpose: 'Compliance policy',
      relatedFrameworks: frameworks,
      createdDate: DateTime.now(),
      lastUpdatedDate: DateTime.now(),
      version: 1,
      isActive: true,
      stakeholders: [],
    );
    await manager.repository.createCompliancePolicy(policy);
    return policy;
  }

  Future<Map<String, dynamic>> getComplianceDashboard() async {
    final allAssets = await manager.repository.getAllAssets();
    final nonCompliant = await manager.repository.getNonCompliantAssets();
    final findings = await manager.repository.getAllFindings();
    final openFindings = await manager.repository.getOpenFindings();
    final assessments = await manager.repository.getAllAssessments();
    final critical = await manager.repository.getCriticalRisks();

    return {
      'totalAssets': allAssets.length,
      'compliantAssets': allAssets.length - nonCompliant.length,
      'nonCompliantAssets': nonCompliant.length,
      'totalFindings': findings.length,
      'openFindings': openFindings.length,
      'resolvedFindings': findings.length - openFindings.length,
      'totalRisks': assessments.length,
      'criticalRisks': critical.length,
      'averageComplianceScore': await manager.repository.getAverageComplianceScore(),
      'averageRiskScore': await manager.repository.getAverageRiskScore(),
    };
  }

  Future<int> getComplianceStatus() async {
    return await manager.repository.countActiveRequirements();
  }

  Future<int> getRiskCount() async {
    return await manager.repository.countAssessments();
  }

  Future<int> getActiveAuditFindings() async {
    return (await manager.repository.getOpenFindings()).length;
  }
}
