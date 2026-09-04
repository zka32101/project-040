/// Data Quality & Quality Management Models

enum DataQualityLevel { critical, high, medium, low, minimal }
enum ValidationRuleType { regex, range, format, uniqueness, consistency, completeness, referential }
enum ScanStatus { pending, running, completed, failed, cancelled }
enum AnomalyType { outlier, duplicate, missing, malformed, inconsistent }
enum ComplianceLevel { compliant, warning, violation, critical }
enum IssueStatus { detected, acknowledged, inProgress, resolved, waived }

class DataQualityMetric {
  final String metricId;
  final String datasetId;
  final double completenessScore;
  final double accuracyScore;
  final double consistencyScore;
  final double uniquenessScore;
  final DateTime measuredAt;
  final Map<String, dynamic> details;

  DataQualityMetric({
    required this.metricId,
    required this.datasetId,
    required this.completenessScore,
    required this.accuracyScore,
    required this.consistencyScore,
    required this.uniquenessScore,
    required this.measuredAt,
    required this.details,
  });

  double get overallScore => (completenessScore + accuracyScore + consistencyScore + uniquenessScore) / 4;
  bool get isHealthy => overallScore >= 95.0;
  int get ageInMinutes => DateTime.now().difference(measuredAt).inMinutes;
}

class ValidationRule {
  final String ruleId;
  final String datasetId;
  final String columnName;
  final ValidationRuleType type;
  final String ruleExpression;
  final DateTime createdAt;
  final bool isActive;
  final int severity; // 1-10

  ValidationRule({
    required this.ruleId,
    required this.datasetId,
    required this.columnName,
    required this.type,
    required this.ruleExpression,
    required this.createdAt,
    this.isActive = true,
    this.severity = 5,
  });

  bool get isCritical => severity >= 8;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class DataScan {
  final String scanId;
  final String datasetId;
  final DateTime startTime;
  final DateTime? endTime;
  final ScanStatus status;
  final int recordsScanned;
  final int issuesFound;
  final List<String> columnTargets;
  final String? errorMessage;

  DataScan({
    required this.scanId,
    required this.datasetId,
    required this.startTime,
    this.endTime,
    required this.status,
    this.recordsScanned = 0,
    this.issuesFound = 0,
    required this.columnTargets,
    this.errorMessage,
  });

  bool get isComplete => status == ScanStatus.completed;
  bool get isFailed => status == ScanStatus.failed;
  int get durationSeconds => endTime != null ? endTime!.difference(startTime).inSeconds : -1;
  double get issueRate => recordsScanned > 0 ? (issuesFound / recordsScanned) * 100 : 0.0;
}

class DataAnomalyDetection {
  final String anomalyId;
  final String datasetId;
  final String columnName;
  final AnomalyType type;
  final dynamic value;
  final DateTime detectedAt;
  final double confidenceScore;
  final bool isConfirmed;

  DataAnomalyDetection({
    required this.anomalyId,
    required this.datasetId,
    required this.columnName,
    required this.type,
    required this.value,
    required this.detectedAt,
    required this.confidenceScore,
    this.isConfirmed = false,
  });

  bool get isHighConfidence => confidenceScore >= 0.8;
  int get ageInHours => DateTime.now().difference(detectedAt).inHours;
}

class ComplianceCheck {
  final String checkId;
  final String datasetId;
  final String checkName;
  final String complianceFramework;
  final DateTime checkedAt;
  final ComplianceLevel level;
  final String? findings;
  final bool isPassed;

  ComplianceCheck({
    required this.checkId,
    required this.datasetId,
    required this.checkName,
    required this.complianceFramework,
    required this.checkedAt,
    required this.level,
    this.findings,
    required this.isPassed,
  });

  bool get needsAction => level == ComplianceLevel.violation || level == ComplianceLevel.critical;
  int get ageInDays => DateTime.now().difference(checkedAt).inDays;
}

class QualityIssue {
  final String issueId;
  final String datasetId;
  final String issueType;
  final String description;
  final DateTime detectedAt;
  final IssueStatus status;
  final int affectedRecordCount;
  final String severity; // critical, high, medium, low
  final String? assignedTo;

  QualityIssue({
    required this.issueId,
    required this.datasetId,
    required this.issueType,
    required this.description,
    required this.detectedAt,
    required this.status,
    required this.affectedRecordCount,
    this.severity = 'medium',
    this.assignedTo,
  });

  bool get isResolved => status == IssueStatus.resolved;
  bool get isCritical => severity == 'critical';
  int get ageInDays => DateTime.now().difference(detectedAt).inDays;
}

class DataProfile {
  final String profileId;
  final String datasetId;
  final DateTime generatedAt;
  final Map<String, dynamic> columnProfiles;
  final int totalRecords;
  final int nullCount;
  final List<String> sampledValues;
  final Map<String, dynamic> statistics;

  DataProfile({
    required this.profileId,
    required this.datasetId,
    required this.generatedAt,
    required this.columnProfiles,
    required this.totalRecords,
    this.nullCount = 0,
    required this.sampledValues,
    required this.statistics,
  });

  double get nullPercentage => totalRecords > 0 ? (nullCount / totalRecords) * 100 : 0.0;
  int get profileColumnCount => columnProfiles.length;
  int get ageInDays => DateTime.now().difference(generatedAt).inDays;
}

class ScanResult {
  final String resultId;
  final String scanId;
  final String datasetId;
  final DateTime generatedAt;
  final int passedChecks;
  final int failedChecks;
  final int warningCount;
  final List<String> failedRuleIds;
  final Map<String, int> issueBreakdown;

  ScanResult({
    required this.resultId,
    required this.scanId,
    required this.datasetId,
    required this.generatedAt,
    required this.passedChecks,
    required this.failedChecks,
    this.warningCount = 0,
    required this.failedRuleIds,
    required this.issueBreakdown,
  });

  double get successRate => (passedChecks + failedChecks) > 0 ? (passedChecks / (passedChecks + failedChecks)) * 100 : 0.0;
  bool get isPassed => failedChecks == 0;
  int get totalChecks => passedChecks + failedChecks;
  int get ageInDays => DateTime.now().difference(generatedAt).inDays;
}

class QualityTrend {
  final String trendId;
  final String datasetId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<double> scoreHistory;
  final double avgScore;
  final double minScore;
  final double maxScore;
  final String trend; // improving, stable, declining

  QualityTrend({
    required this.trendId,
    required this.datasetId,
    required this.periodStart,
    required this.periodEnd,
    required this.scoreHistory,
    required this.avgScore,
    required this.minScore,
    required this.maxScore,
    required this.trend,
  });

  bool get isImproving => trend == 'improving';
  bool get isDeclining => trend == 'declining';
  int get periodInDays => periodEnd.difference(periodStart).inDays;
  double get scoreRange => maxScore - minScore;
}

class DataAsset {
  final String assetId;
  final String assetName;
  final String assetType;
  final DateTime createdAt;
  final String owner;
  final int recordCount;
  final int columnCount;
  final bool isMonitored;

  DataAsset({
    required this.assetId,
    required this.assetName,
    required this.assetType,
    required this.createdAt,
    required this.owner,
    this.recordCount = 0,
    this.columnCount = 0,
    this.isMonitored = true,
  });

  bool get isLarge => recordCount > 1000000;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
}

class QualityScore {
  final String scoreId;
  final String datasetId;
  final DateTime calculatedAt;
  final double score; // 0-100
  final DataQualityLevel level;
  final Map<String, dynamic> componentScores;
  final String? recommendation;

  QualityScore({
    required this.scoreId,
    required this.datasetId,
    required this.calculatedAt,
    required this.score,
    required this.level,
    required this.componentScores,
    this.recommendation,
  });

  bool get isAcceptable => level == DataQualityLevel.high || level == DataQualityLevel.critical;
  bool get needsImprovement => level == DataQualityLevel.low || level == DataQualityLevel.minimal;
  int get ageInHours => DateTime.now().difference(calculatedAt).inHours;
}

class QualityReport {
  final String reportId;
  final String datasetId;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double overallScore;
  final int issuesDetected;
  final int issuesResolved;
  final List<String> recommendations;

  QualityReport({
    required this.reportId,
    required this.datasetId,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.overallScore,
    required this.issuesDetected,
    required this.issuesResolved,
    required this.recommendations,
  });

  double get resolutionRate => issuesDetected > 0 ? (issuesResolved / issuesDetected) * 100 : 0.0;
  int get pendingIssues => issuesDetected - issuesResolved;
  int get periodInDays => periodEnd.difference(periodStart).inDays;
}
