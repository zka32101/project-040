/// Phase 89: Advanced Security & Compliance Frameworks
/// Service layer for security and compliance management
library security_service;

import 'dart:async';
import 'package:project_040/models/security_models.dart';

// ============================================================================
// REPOSITORY INTERFACE
// ============================================================================

abstract class SecurityRepository {
  // ========== Encryption Key Management (10 methods) ==========
  Future<EncryptionKey> createEncryptionKey(EncryptionKey key);
  Future<EncryptionKey?> getEncryptionKeyById(String id);
  Future<List<EncryptionKey>> getActiveEncryptionKeys();
  Future<List<EncryptionKey>> getExpiredEncryptionKeys();
  Future<List<EncryptionKey>> getKeysNeedingRotation();
  Future<EncryptionKey> updateEncryptionKey(EncryptionKey key);
  Future<void> deleteEncryptionKey(String id);
  Future<List<EncryptionKey>> listEncryptionKeys();
  Future<int> getEncryptionKeyCount();
  Future<List<EncryptionKey>> getKeysByType(EncryptionType type);

  // ========== Audit Logs (12 methods) ==========
  Future<SecurityAuditLog> createAuditLog(SecurityAuditLog log);
  Future<SecurityAuditLog?> getAuditLogById(String id);
  Future<List<SecurityAuditLog>> getAuditLogsByUserId(String userId);
  Future<List<SecurityAuditLog>> getAuditLogsByAction(SecurityAuditAction action);
  Future<List<SecurityAuditLog>> getFailedAuditLogs();
  Future<List<SecurityAuditLog>> getAuditLogsByTimeRange(DateTime start, DateTime end);
  Future<void> deleteAuditLog(String id);
  Future<List<SecurityAuditLog>> listAuditLogs();
  Future<int> getAuditLogCount();
  Future<List<SecurityAuditLog>> searchAuditLogs(String query);
  Future<int> getSuccessfulLoginCount();
  Future<int> getFailedLoginCount();

  // ========== Compliance Rules (8 methods) ==========
  Future<ComplianceRule> createComplianceRule(ComplianceRule rule);
  Future<ComplianceRule?> getComplianceRuleById(String id);
  Future<List<ComplianceRule>> getRulesByFramework(ComplianceFramework framework);
  Future<List<ComplianceRule>> getActiveRules();
  Future<List<ComplianceRule>> getRulesNeedingAudit();
  Future<ComplianceRule> updateComplianceRule(ComplianceRule rule);
  Future<void> deleteComplianceRule(String id);
  Future<List<ComplianceRule>> listComplianceRules();

  // ========== Security Incidents (10 methods) ==========
  Future<SecurityIncident> createSecurityIncident(SecurityIncident incident);
  Future<SecurityIncident?> getSecurityIncidentById(String id);
  Future<List<SecurityIncident>> getOpenIncidents();
  Future<List<SecurityIncident>> getIncidentsBySeverity(IncidentSeverity severity);
  Future<List<SecurityIncident>> getCriticalIncidents();
  Future<SecurityIncident> updateSecurityIncident(SecurityIncident incident);
  Future<void> deleteSecurityIncident(String id);
  Future<List<SecurityIncident>> listSecurityIncidents();
  Future<int> getSecurityIncidentCount();
  Future<List<SecurityIncident>> getUnresolvedIncidents();

  // ========== Compliance Assessments (10 methods) ==========
  Future<ComplianceAssessment> createAssessment(ComplianceAssessment assessment);
  Future<ComplianceAssessment?> getAssessmentById(String id);
  Future<List<ComplianceAssessment>> getAssessmentsByFramework(ComplianceFramework framework);
  Future<List<ComplianceAssessment>> getCompliantAssessments();
  Future<List<ComplianceAssessment>> getNonCompliantAssessments();
  Future<ComplianceAssessment> updateAssessment(ComplianceAssessment assessment);
  Future<void> deleteAssessment(String id);
  Future<List<ComplianceAssessment>> listAssessments();
  Future<double> getAverageComplianceScore();
  Future<int> getOverdueAssessmentCount();

  // ========== Privacy Policies (8 methods) ==========
  Future<PrivacyPolicy> createPrivacyPolicy(PrivacyPolicy policy);
  Future<PrivacyPolicy?> getPrivacyPolicyById(String id);
  Future<List<PrivacyPolicy>> getActivePolicies();
  Future<List<PrivacyPolicy>> getPoliciesNeedingReview();
  Future<PrivacyPolicy> updatePrivacyPolicy(PrivacyPolicy policy);
  Future<void> deletePrivacyPolicy(String id);
  Future<List<PrivacyPolicy>> listPrivacyPolicies();
  Future<List<PrivacyPolicy>> getPoliciesByPrivacyLevel(PrivacyLevel level);

  // ========== Data Encryption (8 methods) ==========
  Future<DataEncryption> createDataEncryption(DataEncryption encryption);
  Future<DataEncryption?> getDataEncryptionById(String id);
  Future<List<DataEncryption>> getEncryptionsByDataId(String dataId);
  Future<List<DataEncryption>> getEncryptedData();
  Future<DataEncryption> updateDataEncryption(DataEncryption encryption);
  Future<void> deleteDataEncryption(String id);
  Future<List<DataEncryption>> listDataEncryptions();
  Future<int> getEncryptedDataCount();

  // ========== Security Policies (8 methods) ==========
  Future<SecurityPolicy> createSecurityPolicy(SecurityPolicy policy);
  Future<SecurityPolicy?> getSecurityPolicyById(String id);
  Future<List<SecurityPolicy>> getActivePolicies();
  Future<SecurityPolicy> updateSecurityPolicy(SecurityPolicy policy);
  Future<void> deleteSecurityPolicy(String id);
  Future<List<SecurityPolicy>> listSecurityPolicies();
  Future<int> getSecurityPolicyCount();
  Future<List<SecurityPolicy>> getMfaRequiredPolicies();

  // ========== Vulnerability Reports (10 methods) ==========
  Future<VulnerabilityReport> createVulnerabilityReport(VulnerabilityReport report);
  Future<VulnerabilityReport?> getVulnerabilityReportById(String id);
  Future<List<VulnerabilityReport>> getOpenVulnerabilities();
  Future<List<VulnerabilityReport>> getCriticalVulnerabilities();
  Future<List<VulnerabilityReport>> getVulnerabilityBySeverity(IncidentSeverity severity);
  Future<VulnerabilityReport> updateVulnerabilityReport(VulnerabilityReport report);
  Future<void> deleteVulnerabilityReport(String id);
  Future<List<VulnerabilityReport>> listVulnerabilityReports();
  Future<int> getVulnerabilityCount();
  Future<List<VulnerabilityReport>> getOverdueVulnerabilities();

  // ========== Data Access Logs (10 methods) ==========
  Future<DataAccessLog> createAccessLog(DataAccessLog log);
  Future<DataAccessLog?> getAccessLogById(String id);
  Future<List<DataAccessLog>> getAccessLogsByUserId(String userId);
  Future<List<DataAccessLog>> getAccessLogsByDataId(String dataId);
  Future<List<DataAccessLog>> getDeniedAccessLogs();
  Future<List<DataAccessLog>> getAccessLogsByTimeRange(DateTime start, DateTime end);
  Future<void> deleteAccessLog(String id);
  Future<List<DataAccessLog>> listAccessLogs();
  Future<int> getAccessLogCount();
  Future<List<DataAccessLog>> getUnauthorizedAccessAttempts();

  // ========== Compliance Violations (10 methods) ==========
  Future<ComplianceViolation> createViolation(ComplianceViolation violation);
  Future<ComplianceViolation?> getViolationById(String id);
  Future<List<ComplianceViolation>> getOpenViolations();
  Future<List<ComplianceViolation>> getViolationsByFramework(ComplianceFramework framework);
  Future<List<ComplianceViolation>> getOverdueViolations();
  Future<ComplianceViolation> updateViolation(ComplianceViolation violation);
  Future<void> deleteViolation(String id);
  Future<List<ComplianceViolation>> listViolations();
  Future<int> getViolationCount();
  Future<List<ComplianceViolation>> getCriticalViolations();
}

// ============================================================================
// IN-MEMORY IMPLEMENTATION
// ============================================================================

class InMemorySecurityRepository implements SecurityRepository {
  final Map<String, EncryptionKey> _encryptionKeys = {};
  final Map<String, SecurityAuditLog> _auditLogs = {};
  final Map<String, ComplianceRule> _complianceRules = {};
  final Map<String, SecurityIncident> _incidents = {};
  final Map<String, ComplianceAssessment> _assessments = {};
  final Map<String, PrivacyPolicy> _policies = {};
  final Map<String, DataEncryption> _dataEncryptions = {};
  final Map<String, SecurityPolicy> _securityPolicies = {};
  final Map<String, VulnerabilityReport> _vulnerabilities = {};
  final Map<String, DataAccessLog> _accessLogs = {};
  final Map<String, ComplianceViolation> _violations = {};

  @override
  Future<EncryptionKey> createEncryptionKey(EncryptionKey key) async {
    _encryptionKeys[key.id] = key;
    return key;
  }

  @override
  Future<EncryptionKey?> getEncryptionKeyById(String id) async =>
      _encryptionKeys[id];

  @override
  Future<List<EncryptionKey>> getActiveEncryptionKeys() async =>
      _encryptionKeys.values.where((k) => k.isActive).toList();

  @override
  Future<List<EncryptionKey>> getExpiredEncryptionKeys() async =>
      _encryptionKeys.values.where((k) => k.isExpired).toList();

  @override
  Future<List<EncryptionKey>> getKeysNeedingRotation() async =>
      _encryptionKeys.values.where((k) => k.needsRotation).toList();

  @override
  Future<EncryptionKey> updateEncryptionKey(EncryptionKey key) async {
    _encryptionKeys[key.id] = key;
    return key;
  }

  @override
  Future<void> deleteEncryptionKey(String id) async {
    _encryptionKeys.remove(id);
  }

  @override
  Future<List<EncryptionKey>> listEncryptionKeys() async =>
      _encryptionKeys.values.toList();

  @override
  Future<int> getEncryptionKeyCount() async => _encryptionKeys.length;

  @override
  Future<List<EncryptionKey>> getKeysByType(EncryptionType type) async =>
      _encryptionKeys.values.where((k) => k.encryptionType == type).toList();

  @override
  Future<SecurityAuditLog> createAuditLog(SecurityAuditLog log) async {
    _auditLogs[log.id] = log;
    return log;
  }

  @override
  Future<SecurityAuditLog?> getAuditLogById(String id) async =>
      _auditLogs[id];

  @override
  Future<List<SecurityAuditLog>> getAuditLogsByUserId(String userId) async =>
      _auditLogs.values.where((l) => l.userId == userId).toList();

  @override
  Future<List<SecurityAuditLog>> getAuditLogsByAction(
      SecurityAuditAction action) async =>
      _auditLogs.values.where((l) => l.action == action).toList();

  @override
  Future<List<SecurityAuditLog>> getFailedAuditLogs() async =>
      _auditLogs.values.where((l) => l.isFailure).toList();

  @override
  Future<List<SecurityAuditLog>> getAuditLogsByTimeRange(
      DateTime start, DateTime end) async =>
      _auditLogs.values
          .where((l) => l.timestamp.isAfter(start) && l.timestamp.isBefore(end))
          .toList();

  @override
  Future<void> deleteAuditLog(String id) async {
    _auditLogs.remove(id);
  }

  @override
  Future<List<SecurityAuditLog>> listAuditLogs() async =>
      _auditLogs.values.toList();

  @override
  Future<int> getAuditLogCount() async => _auditLogs.length;

  @override
  Future<List<SecurityAuditLog>> searchAuditLogs(String query) async =>
      _auditLogs.values
          .where((l) => l.details?.contains(query) ?? false)
          .toList();

  @override
  Future<int> getSuccessfulLoginCount() async =>
      _auditLogs.values
          .where((l) => l.action == SecurityAuditAction.login && l.isSuccess)
          .length;

  @override
  Future<int> getFailedLoginCount() async =>
      _auditLogs.values
          .where((l) => l.action == SecurityAuditAction.login && l.isFailure)
          .length;

  @override
  Future<ComplianceRule> createComplianceRule(ComplianceRule rule) async {
    _complianceRules[rule.id] = rule;
    return rule;
  }

  @override
  Future<ComplianceRule?> getComplianceRuleById(String id) async =>
      _complianceRules[id];

  @override
  Future<List<ComplianceRule>> getRulesByFramework(
      ComplianceFramework framework) async =>
      _complianceRules.values
          .where((r) => r.framework == framework)
          .toList();

  @override
  Future<List<ComplianceRule>> getActiveRules() async =>
      _complianceRules.values.where((r) => r.isActive).toList();

  @override
  Future<List<ComplianceRule>> getRulesNeedingAudit() async =>
      _complianceRules.values.where((r) => r.needsAudit).toList();

  @override
  Future<ComplianceRule> updateComplianceRule(ComplianceRule rule) async {
    _complianceRules[rule.id] = rule;
    return rule;
  }

  @override
  Future<void> deleteComplianceRule(String id) async {
    _complianceRules.remove(id);
  }

  @override
  Future<List<ComplianceRule>> listComplianceRules() async =>
      _complianceRules.values.toList();

  @override
  Future<SecurityIncident> createSecurityIncident(
      SecurityIncident incident) async {
    _incidents[incident.id] = incident;
    return incident;
  }

  @override
  Future<SecurityIncident?> getSecurityIncidentById(String id) async =>
      _incidents[id];

  @override
  Future<List<SecurityIncident>> getOpenIncidents() async =>
      _incidents.values.where((i) => i.status == 'open').toList();

  @override
  Future<List<SecurityIncident>> getIncidentsBySeverity(
      IncidentSeverity severity) async =>
      _incidents.values.where((i) => i.severity == severity).toList();

  @override
  Future<List<SecurityIncident>> getCriticalIncidents() async =>
      _incidents.values.where((i) => i.isCritical).toList();

  @override
  Future<SecurityIncident> updateSecurityIncident(
      SecurityIncident incident) async {
    _incidents[incident.id] = incident;
    return incident;
  }

  @override
  Future<void> deleteSecurityIncident(String id) async {
    _incidents.remove(id);
  }

  @override
  Future<List<SecurityIncident>> listSecurityIncidents() async =>
      _incidents.values.toList();

  @override
  Future<int> getSecurityIncidentCount() async => _incidents.length;

  @override
  Future<List<SecurityIncident>> getUnresolvedIncidents() async =>
      _incidents.values.where((i) => !i.isResolved).toList();

  @override
  Future<ComplianceAssessment> createAssessment(
      ComplianceAssessment assessment) async {
    _assessments[assessment.id] = assessment;
    return assessment;
  }

  @override
  Future<ComplianceAssessment?> getAssessmentById(String id) async =>
      _assessments[id];

  @override
  Future<List<ComplianceAssessment>> getAssessmentsByFramework(
      ComplianceFramework framework) async =>
      _assessments.values
          .where((a) => a.framework == framework)
          .toList();

  @override
  Future<List<ComplianceAssessment>> getCompliantAssessments() async =>
      _assessments.values
          .where((a) => a.status == ComplianceStatus.compliant)
          .toList();

  @override
  Future<List<ComplianceAssessment>> getNonCompliantAssessments() async =>
      _assessments.values
          .where((a) => a.status == ComplianceStatus.nonCompliant)
          .toList();

  @override
  Future<ComplianceAssessment> updateAssessment(
      ComplianceAssessment assessment) async {
    _assessments[assessment.id] = assessment;
    return assessment;
  }

  @override
  Future<void> deleteAssessment(String id) async {
    _assessments.remove(id);
  }

  @override
  Future<List<ComplianceAssessment>> listAssessments() async =>
      _assessments.values.toList();

  @override
  Future<double> getAverageComplianceScore() async {
    if (_assessments.isEmpty) return 0.0;
    final total =
        _assessments.values.fold<double>(0, (sum, a) => sum + a.complianceScore);
    return total / _assessments.length;
  }

  @override
  Future<int> getOverdueAssessmentCount() async =>
      _assessments.values.where((a) => a.isOverdue).length;

  @override
  Future<PrivacyPolicy> createPrivacyPolicy(PrivacyPolicy policy) async {
    _policies[policy.id] = policy;
    return policy;
  }

  @override
  Future<PrivacyPolicy?> getPrivacyPolicyById(String id) async =>
      _policies[id];

  @override
  Future<List<PrivacyPolicy>> getActivePolicies() async =>
      _policies.values.where((p) => p.isActive).toList();

  @override
  Future<List<PrivacyPolicy>> getPoliciesNeedingReview() async =>
      _policies.values.where((p) => p.needsReview).toList();

  @override
  Future<PrivacyPolicy> updatePrivacyPolicy(PrivacyPolicy policy) async {
    _policies[policy.id] = policy;
    return policy;
  }

  @override
  Future<void> deletePrivacyPolicy(String id) async {
    _policies.remove(id);
  }

  @override
  Future<List<PrivacyPolicy>> listPrivacyPolicies() async =>
      _policies.values.toList();

  @override
  Future<List<PrivacyPolicy>> getPoliciesByPrivacyLevel(
      PrivacyLevel level) async =>
      _policies.values.where((p) => p.privacyLevel == level).toList();

  @override
  Future<DataEncryption> createDataEncryption(DataEncryption encryption) async {
    _dataEncryptions[encryption.id] = encryption;
    return encryption;
  }

  @override
  Future<DataEncryption?> getDataEncryptionById(String id) async =>
      _dataEncryptions[id];

  @override
  Future<List<DataEncryption>> getEncryptionsByDataId(String dataId) async =>
      _dataEncryptions.values.where((e) => e.dataId == dataId).toList();

  @override
  Future<List<DataEncryption>> getEncryptedData() async =>
      _dataEncryptions.values.where((e) => e.isEncrypted).toList();

  @override
  Future<DataEncryption> updateDataEncryption(DataEncryption encryption) async {
    _dataEncryptions[encryption.id] = encryption;
    return encryption;
  }

  @override
  Future<void> deleteDataEncryption(String id) async {
    _dataEncryptions.remove(id);
  }

  @override
  Future<List<DataEncryption>> listDataEncryptions() async =>
      _dataEncryptions.values.toList();

  @override
  Future<int> getEncryptedDataCount() async =>
      _dataEncryptions.values.where((e) => e.isEncrypted).length;

  @override
  Future<SecurityPolicy> createSecurityPolicy(SecurityPolicy policy) async {
    _securityPolicies[policy.id] = policy;
    return policy;
  }

  @override
  Future<SecurityPolicy?> getSecurityPolicyById(String id) async =>
      _securityPolicies[id];

  @override
  Future<List<SecurityPolicy>> getActivePolicies() async =>
      _securityPolicies.values.where((p) => p.isActive).toList();

  @override
  Future<SecurityPolicy> updateSecurityPolicy(SecurityPolicy policy) async {
    _securityPolicies[policy.id] = policy;
    return policy;
  }

  @override
  Future<void> deleteSecurityPolicy(String id) async {
    _securityPolicies.remove(id);
  }

  @override
  Future<List<SecurityPolicy>> listSecurityPolicies() async =>
      _securityPolicies.values.toList();

  @override
  Future<int> getSecurityPolicyCount() async => _securityPolicies.length;

  @override
  Future<List<SecurityPolicy>> getMfaRequiredPolicies() async =>
      _securityPolicies.values.where((p) => p.isMfaRequired).toList();

  @override
  Future<VulnerabilityReport> createVulnerabilityReport(
      VulnerabilityReport report) async {
    _vulnerabilities[report.id] = report;
    return report;
  }

  @override
  Future<VulnerabilityReport?> getVulnerabilityReportById(String id) async =>
      _vulnerabilities[id];

  @override
  Future<List<VulnerabilityReport>> getOpenVulnerabilities() async =>
      _vulnerabilities.values.where((v) => v.status == 'open').toList();

  @override
  Future<List<VulnerabilityReport>> getCriticalVulnerabilities() async =>
      _vulnerabilities.values.where((v) => v.isCritical).toList();

  @override
  Future<List<VulnerabilityReport>> getVulnerabilityBySeverity(
      IncidentSeverity severity) async =>
      _vulnerabilities.values.where((v) => v.severity == severity).toList();

  @override
  Future<VulnerabilityReport> updateVulnerabilityReport(
      VulnerabilityReport report) async {
    _vulnerabilities[report.id] = report;
    return report;
  }

  @override
  Future<void> deleteVulnerabilityReport(String id) async {
    _vulnerabilities.remove(id);
  }

  @override
  Future<List<VulnerabilityReport>> listVulnerabilityReports() async =>
      _vulnerabilities.values.toList();

  @override
  Future<int> getVulnerabilityCount() async => _vulnerabilities.length;

  @override
  Future<List<VulnerabilityReport>> getOverdueVulnerabilities() async =>
      _vulnerabilities.values.where((v) => v.daysToRemediation >= 0).toList();

  @override
  Future<DataAccessLog> createAccessLog(DataAccessLog log) async {
    _accessLogs[log.id] = log;
    return log;
  }

  @override
  Future<DataAccessLog?> getAccessLogById(String id) async =>
      _accessLogs[id];

  @override
  Future<List<DataAccessLog>> getAccessLogsByUserId(String userId) async =>
      _accessLogs.values.where((l) => l.userId == userId).toList();

  @override
  Future<List<DataAccessLog>> getAccessLogsByDataId(String dataId) async =>
      _accessLogs.values.where((l) => l.dataId == dataId).toList();

  @override
  Future<List<DataAccessLog>> getDeniedAccessLogs() async =>
      _accessLogs.values.where((l) => l.isDenied).toList();

  @override
  Future<List<DataAccessLog>> getAccessLogsByTimeRange(
      DateTime start, DateTime end) async =>
      _accessLogs.values
          .where((l) =>
              l.accessTime.isAfter(start) && l.accessTime.isBefore(end))
          .toList();

  @override
  Future<void> deleteAccessLog(String id) async {
    _accessLogs.remove(id);
  }

  @override
  Future<List<DataAccessLog>> listAccessLogs() async =>
      _accessLogs.values.toList();

  @override
  Future<int> getAccessLogCount() async => _accessLogs.length;

  @override
  Future<List<DataAccessLog>> getUnauthorizedAccessAttempts() async =>
      _accessLogs.values.where((l) => l.isDenied).toList();

  @override
  Future<ComplianceViolation> createViolation(
      ComplianceViolation violation) async {
    _violations[violation.id] = violation;
    return violation;
  }

  @override
  Future<ComplianceViolation?> getViolationById(String id) async =>
      _violations[id];

  @override
  Future<List<ComplianceViolation>> getOpenViolations() async =>
      _violations.values.where((v) => v.status == 'open').toList();

  @override
  Future<List<ComplianceViolation>> getViolationsByFramework(
      ComplianceFramework framework) async =>
      _violations.values.where((v) => v.framework == framework).toList();

  @override
  Future<List<ComplianceViolation>> getOverdueViolations() async =>
      _violations.values.where((v) => v.isOverdue).toList();

  @override
  Future<ComplianceViolation> updateViolation(
      ComplianceViolation violation) async {
    _violations[violation.id] = violation;
    return violation;
  }

  @override
  Future<void> deleteViolation(String id) async {
    _violations.remove(id);
  }

  @override
  Future<List<ComplianceViolation>> listViolations() async =>
      _violations.values.toList();

  @override
  Future<int> getViolationCount() async => _violations.length;

  @override
  Future<List<ComplianceViolation>> getCriticalViolations() async =>
      _violations.values.where((v) => v.severity == 'critical').toList();
}

// ============================================================================
// ENGINES
// ============================================================================

class EncryptionEngine {
  final SecurityRepository repository;

  EncryptionEngine(this.repository);

  Future<void> rotateExpiredKeys() async {
    final expired = await repository.getExpiredEncryptionKeys();
    for (final key in expired) {
      await repository.updateEncryptionKey(
        key.copyWith(isActive: false),
      );
    }
  }
}

class AuditEngine {
  final SecurityRepository repository;

  AuditEngine(this.repository);

  Future<void> logSecurityAction(
    String userId,
    SecurityAuditAction action,
    String? resourceId,
    String? details,
  ) async {
    await repository.createAuditLog(
      SecurityAuditLog(
        id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        action: action,
        timestamp: DateTime.now(),
        createdAt: DateTime.now(),
        resourceId: resourceId,
        details: details,
      ),
    );
  }
}

class ComplianceEngine {
  final SecurityRepository repository;

  ComplianceEngine(this.repository);

  Future<void> updateAssessmentStatus(String assessmentId) async {
    final assessment = await repository.getAssessmentById(assessmentId);
    if (assessment == null) return;

    final status = assessment.complianceScore >= 0.95
        ? ComplianceStatus.compliant
        : assessment.complianceScore >= 0.7
            ? ComplianceStatus.partiallyCompliant
            : ComplianceStatus.nonCompliant;

    await repository.updateAssessment(assessment.copyWith(status: status));
  }
}

class IncidentEngine {
  final SecurityRepository repository;

  IncidentEngine(this.repository);

  Future<void> escalateIncident(String incidentId) async {
    final incident = await repository.getSecurityIncidentById(incidentId);
    if (incident == null) return;

    await repository.updateSecurityIncident(
      incident.copyWith(status: 'escalated'),
    );
  }
}

class VulnerabilityEngine {
  final SecurityRepository repository;

  VulnerabilityEngine(this.repository);

  Future<int> getCriticalVulnerabilityCount() async {
    final vulns = await repository.getCriticalVulnerabilities();
    return vulns.length;
  }
}

// ============================================================================
// MANAGER
// ============================================================================

class SecurityManager {
  final SecurityRepository repository;
  late final EncryptionEngine encryptionEngine;
  late final AuditEngine auditEngine;
  late final ComplianceEngine complianceEngine;
  late final IncidentEngine incidentEngine;
  late final VulnerabilityEngine vulnerabilityEngine;

  SecurityManager(this.repository) {
    encryptionEngine = EncryptionEngine(repository);
    auditEngine = AuditEngine(repository);
    complianceEngine = ComplianceEngine(repository);
    incidentEngine = IncidentEngine(repository);
    vulnerabilityEngine = VulnerabilityEngine(repository);
  }
}

// ============================================================================
// FACADE
// ============================================================================

class SecurityFacade {
  final SecurityManager manager;

  SecurityFacade(this.manager);

  Future<EncryptionKey> createEncryptionKey(
    String keyName,
    EncryptionType encryptionType, {
    int rotationSchedule = 90,
  }) async {
    final key = EncryptionKey(
      id: 'key_${DateTime.now().millisecondsSinceEpoch}',
      keyName: keyName,
      encryptionType: encryptionType,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: 365)),
      rotationSchedule: rotationSchedule,
    );
    return manager.repository.createEncryptionKey(key);
  }

  Future<void> logSecurityAction(
    String userId,
    SecurityAuditAction action, {
    String? resourceId,
    String? details,
  }) async {
    await manager.auditEngine.logSecurityAction(
      userId,
      action,
      resourceId,
      details,
    );
  }

  Future<SecurityIncident> reportSecurityIncident(
    String incidentType,
    IncidentSeverity severity,
    String? description,
  ) async {
    final incident = SecurityIncident(
      id: 'incident_${DateTime.now().millisecondsSinceEpoch}',
      incidentType: incidentType,
      severity: severity,
      detectedAt: DateTime.now(),
      createdAt: DateTime.now(),
      description: description,
    );
    return manager.repository.createSecurityIncident(incident);
  }

  Future<ComplianceAssessment> createAssessment(
    ComplianceFramework framework,
  ) async {
    final assessment = ComplianceAssessment(
      id: 'assess_${DateTime.now().millisecondsSinceEpoch}',
      framework: framework,
      assessmentDate: DateTime.now(),
      createdAt: DateTime.now(),
    );
    return manager.repository.createAssessment(assessment);
  }

  Future<int> getCriticalIncidentCount() async {
    final incidents = await manager.repository.getCriticalIncidents();
    return incidents.length;
  }

  Future<double> getComplianceScore() async {
    return manager.repository.getAverageComplianceScore();
  }

  Future<int> getOpenViolationCount() async {
    final violations = await manager.repository.getOpenViolations();
    return violations.length;
  }

  Future<List<VulnerabilityReport>> getCriticalVulnerabilities() async {
    return manager.repository.getCriticalVulnerabilities();
  }
}
