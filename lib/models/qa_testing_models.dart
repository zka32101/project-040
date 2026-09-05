/// Advanced Quality Assurance & Testing Management Models
/// Comprehensive test management, defect tracking, and quality metrics

// ============================================================================
// Enums (7 total)
// ============================================================================

enum TestType {
  unit,
  integration,
  functional,
  performance,
  security,
  acceptance,
  regression;

  String get displayName {
    switch (this) {
      case TestType.unit:
        return 'Unit (ユニット)';
      case TestType.integration:
        return 'Integration (統合)';
      case TestType.functional:
        return 'Functional (機能)';
      case TestType.performance:
        return 'Performance (パフォーマンス)';
      case TestType.security:
        return 'Security (セキュリティ)';
      case TestType.acceptance:
        return 'Acceptance (受け入れ)';
      case TestType.regression:
        return 'Regression (リグレッション)';
    }
  }
}

enum TestStatus {
  planned,
  inProgress,
  completed,
  paused,
  blocked,
  cancelled;

  String get displayName {
    switch (this) {
      case TestStatus.planned:
        return 'Planned (計画中)';
      case TestStatus.inProgress:
        return 'In Progress (進行中)';
      case TestStatus.completed:
        return 'Completed (完了)';
      case TestStatus.paused:
        return 'Paused (一時停止)';
      case TestStatus.blocked:
        return 'Blocked (ブロック)';
      case TestStatus.cancelled:
        return 'Cancelled (キャンセル)';
    }
  }
}

enum DefectSeverity {
  critical,
  high,
  medium,
  low,
  trivial;

  String get displayName {
    switch (this) {
      case DefectSeverity.critical:
        return 'Critical (致命的)';
      case DefectSeverity.high:
        return 'High (高)';
      case DefectSeverity.medium:
        return 'Medium (中)';
      case DefectSeverity.low:
        return 'Low (低)';
      case DefectSeverity.trivial:
        return 'Trivial (軽微)';
    }
  }
}

enum DefectStatus {
  open,
  assigned,
  inProgress,
  resolved,
  verified,
  closed,
  reopened;

  String get displayName {
    switch (this) {
      case DefectStatus.open:
        return 'Open (未解決)';
      case DefectStatus.assigned:
        return 'Assigned (割り当て済)';
      case DefectStatus.inProgress:
        return 'In Progress (対応中)';
      case DefectStatus.resolved:
        return 'Resolved (解決)';
      case DefectStatus.verified:
        return 'Verified (検証済)';
      case DefectStatus.closed:
        return 'Closed (完了)';
      case DefectStatus.reopened:
        return 'Reopened (再開)';
    }
  }
}

enum TestEnvironment {
  development,
  staging,
  production,
  sandbox,
  custom;

  String get displayName {
    switch (this) {
      case TestEnvironment.development:
        return 'Development (開発)';
      case TestEnvironment.staging:
        return 'Staging (ステージング)';
      case TestEnvironment.production:
        return 'Production (本番)';
      case TestEnvironment.sandbox:
        return 'Sandbox (サンドボックス)';
      case TestEnvironment.custom:
        return 'Custom (カスタム)';
    }
  }
}

enum CoverageType {
  lineCoverage,
  branchCoverage,
  functionCoverage,
  statementCoverage,
  pathCoverage;

  String get displayName {
    switch (this) {
      case CoverageType.lineCoverage:
        return 'Line Coverage (行カバレッジ)';
      case CoverageType.branchCoverage:
        return 'Branch Coverage (分岐カバレッジ)';
      case CoverageType.functionCoverage:
        return 'Function Coverage (関数カバレッジ)';
      case CoverageType.statementCoverage:
        return 'Statement Coverage (ステートメント)';
      case CoverageType.pathCoverage:
        return 'Path Coverage (パスカバレッジ)';
    }
  }
}

enum TestResult {
  passed,
  failed,
  blocked,
  skipped,
  notRun;

  String get displayName {
    switch (this) {
      case TestResult.passed:
        return 'Passed (成功)';
      case TestResult.failed:
        return 'Failed (失敗)';
      case TestResult.blocked:
        return 'Blocked (ブロック)';
      case TestResult.skipped:
        return 'Skipped (スキップ)';
      case TestResult.notRun:
        return 'Not Run (未実行)';
    }
  }
}

// ============================================================================
// Model Classes (10 total)
// ============================================================================

class TestCase {
  final String testCaseId;
  final String testName;
  final String description;
  final TestType testType;
  final TestStatus status;
  final String assignedTo;
  final int stepCount;
  final DateTime createdDate;
  final bool isAutomated;

  TestCase({
    required this.testCaseId,
    required this.testName,
    required this.description,
    required this.testType,
    required this.status,
    required this.assignedTo,
    required this.stepCount,
    required this.createdDate,
    required this.isAutomated,
  });

  bool get isActive => status != TestStatus.cancelled && status != TestStatus.completed;
  bool get isBlocked => status == TestStatus.blocked;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;

  TestCase copyWith({
    String? testCaseId,
    String? testName,
    String? description,
    TestType? testType,
    TestStatus? status,
    String? assignedTo,
    int? stepCount,
    DateTime? createdDate,
    bool? isAutomated,
  }) {
    return TestCase(
      testCaseId: testCaseId ?? this.testCaseId,
      testName: testName ?? this.testName,
      description: description ?? this.description,
      testType: testType ?? this.testType,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      stepCount: stepCount ?? this.stepCount,
      createdDate: createdDate ?? this.createdDate,
      isAutomated: isAutomated ?? this.isAutomated,
    );
  }
}

class TestExecution {
  final String executionId;
  final String testCaseId;
  final TestResult result;
  final DateTime executionDate;
  final int durationSeconds;
  final String executedBy;
  final String? errorMessage;
  final TestEnvironment environment;

  TestExecution({
    required this.executionId,
    required this.testCaseId,
    required this.result,
    required this.executionDate,
    required this.durationSeconds,
    required this.executedBy,
    required this.errorMessage,
    required this.environment,
  });

  bool get passed => result == TestResult.passed;
  bool get failed => result == TestResult.failed;
  int get ageInDays => DateTime.now().difference(executionDate).inDays;

  TestExecution copyWith({
    String? executionId,
    String? testCaseId,
    TestResult? result,
    DateTime? executionDate,
    int? durationSeconds,
    String? executedBy,
    String? errorMessage,
    TestEnvironment? environment,
  }) {
    return TestExecution(
      executionId: executionId ?? this.executionId,
      testCaseId: testCaseId ?? this.testCaseId,
      result: result ?? this.result,
      executionDate: executionDate ?? this.executionDate,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      executedBy: executedBy ?? this.executedBy,
      errorMessage: errorMessage ?? this.errorMessage,
      environment: environment ?? this.environment,
    );
  }
}

class Defect {
  final String defectId;
  final String title;
  final String description;
  final DefectSeverity severity;
  final DefectStatus status;
  final String reportedBy;
  final String? assignedTo;
  final DateTime createdDate;
  final DateTime? resolvedDate;

  Defect({
    required this.defectId,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.reportedBy,
    required this.assignedTo,
    required this.createdDate,
    required this.resolvedDate,
  });

  bool get isOpen => status == DefectStatus.open || status == DefectStatus.assigned;
  bool get isCritical => severity == DefectSeverity.critical;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;
  int get resolutionDays => resolvedDate != null ? resolvedDate!.difference(createdDate).inDays : 0;

  Defect copyWith({
    String? defectId,
    String? title,
    String? description,
    DefectSeverity? severity,
    DefectStatus? status,
    String? reportedBy,
    String? assignedTo,
    DateTime? createdDate,
    DateTime? resolvedDate,
  }) {
    return Defect(
      defectId: defectId ?? this.defectId,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      reportedBy: reportedBy ?? this.reportedBy,
      assignedTo: assignedTo ?? this.assignedTo,
      createdDate: createdDate ?? this.createdDate,
      resolvedDate: resolvedDate ?? this.resolvedDate,
    );
  }
}

class TestSuite {
  final String suiteId;
  final String suiteName;
  final int totalTestCases;
  final int executedCount;
  final int passedCount;
  final DateTime lastRun;
  final double estimatedDurationMinutes;

  TestSuite({
    required this.suiteId,
    required this.suiteName,
    required this.totalTestCases,
    required this.executedCount,
    required this.passedCount,
    required this.lastRun,
    required this.estimatedDurationMinutes,
  });

  double get passRate => totalTestCases > 0 ? (passedCount / totalTestCases) * 100 : 0;
  double get executionRate => totalTestCases > 0 ? (executedCount / totalTestCases) * 100 : 0;
  int get failedCount => executedCount - passedCount;
  int get daysSinceLastRun => DateTime.now().difference(lastRun).inDays;

  TestSuite copyWith({
    String? suiteId,
    String? suiteName,
    int? totalTestCases,
    int? executedCount,
    int? passedCount,
    DateTime? lastRun,
    double? estimatedDurationMinutes,
  }) {
    return TestSuite(
      suiteId: suiteId ?? this.suiteId,
      suiteName: suiteName ?? this.suiteName,
      totalTestCases: totalTestCases ?? this.totalTestCases,
      executedCount: executedCount ?? this.executedCount,
      passedCount: passedCount ?? this.passedCount,
      lastRun: lastRun ?? this.lastRun,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
    );
  }
}

class CodeCoverage {
  final String coverId;
  final String moduleId;
  final CoverageType coverageType;
  final double percentage;
  final int linesExecuted;
  final int totalLines;
  final DateTime measuredDate;

  CodeCoverage({
    required this.coverId,
    required this.moduleId,
    required this.coverageType,
    required this.percentage,
    required this.linesExecuted,
    required this.totalLines,
    required this.measuredDate,
  });

  bool get isAcceptable => percentage >= 80;
  bool get isExcellent => percentage >= 95;
  int get gapLines => totalLines - linesExecuted;
  int get ageInDays => DateTime.now().difference(measuredDate).inDays;

  CodeCoverage copyWith({
    String? coverId,
    String? moduleId,
    CoverageType? coverageType,
    double? percentage,
    int? linesExecuted,
    int? totalLines,
    DateTime? measuredDate,
  }) {
    return CodeCoverage(
      coverId: coverId ?? this.coverId,
      moduleId: moduleId ?? this.moduleId,
      coverageType: coverageType ?? this.coverageType,
      percentage: percentage ?? this.percentage,
      linesExecuted: linesExecuted ?? this.linesExecuted,
      totalLines: totalLines ?? this.totalLines,
      measuredDate: measuredDate ?? this.measuredDate,
    );
  }
}

class TestPlan {
  final String planId;
  final String planName;
  final String projectId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalTests;
  final String scope;
  final bool isActive;

  TestPlan({
    required this.planId,
    required this.planName,
    required this.projectId,
    required this.startDate,
    required this.endDate,
    required this.totalTests,
    required this.scope,
    required this.isActive,
  });

  int get durationDays => endDate.difference(startDate).inDays;
  int get remainingDays => endDate.difference(DateTime.now()).inDays;
  bool get isOverdue => DateTime.now().isAfter(endDate) && isActive;
  int get ageInDays => DateTime.now().difference(startDate).inDays;

  TestPlan copyWith({
    String? planId,
    String? planName,
    String? projectId,
    DateTime? startDate,
    DateTime? endDate,
    int? totalTests,
    String? scope,
    bool? isActive,
  }) {
    return TestPlan(
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      projectId: projectId ?? this.projectId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalTests: totalTests ?? this.totalTests,
      scope: scope ?? this.scope,
      isActive: isActive ?? this.isActive,
    );
  }
}

class TestReport {
  final String reportId;
  final String suiteId;
  final DateTime reportDate;
  final int totalTests;
  final int passedTests;
  final int failedTests;
  final double passPercentage;
  final int defectsFound;

  TestReport({
    required this.reportId,
    required this.suiteId,
    required this.reportDate,
    required this.totalTests,
    required this.passedTests,
    required this.failedTests,
    required this.passPercentage,
    required this.defectsFound,
  });

  bool get isHealthy => passPercentage >= 95;
  int get skippedTests => totalTests - passedTests - failedTests;
  int get ageInDays => DateTime.now().difference(reportDate).inDays;

  TestReport copyWith({
    String? reportId,
    String? suiteId,
    DateTime? reportDate,
    int? totalTests,
    int? passedTests,
    int? failedTests,
    double? passPercentage,
    int? defectsFound,
  }) {
    return TestReport(
      reportId: reportId ?? this.reportId,
      suiteId: suiteId ?? this.suiteId,
      reportDate: reportDate ?? this.reportDate,
      totalTests: totalTests ?? this.totalTests,
      passedTests: passedTests ?? this.passedTests,
      failedTests: failedTests ?? this.failedTests,
      passPercentage: passPercentage ?? this.passPercentage,
      defectsFound: defectsFound ?? this.defectsFound,
    );
  }
}

class TestAutomationScript {
  final String scriptId;
  final String scriptName;
  final TestType testType;
  final String sourceCode;
  final bool isActive;
  final DateTime createdDate;
  final int executionCount;

  TestAutomationScript({
    required this.scriptId,
    required this.scriptName,
    required this.testType,
    required this.sourceCode,
    required this.isActive,
    required this.createdDate,
    required this.executionCount,
  });

  bool get isRecent => DateTime.now().difference(createdDate).inDays <= 30;
  int get ageInDays => DateTime.now().difference(createdDate).inDays;
  int get linesOfCode => sourceCode.split('\n').length;

  TestAutomationScript copyWith({
    String? scriptId,
    String? scriptName,
    TestType? testType,
    String? sourceCode,
    bool? isActive,
    DateTime? createdDate,
    int? executionCount,
  }) {
    return TestAutomationScript(
      scriptId: scriptId ?? this.scriptId,
      scriptName: scriptName ?? this.scriptName,
      testType: testType ?? this.testType,
      sourceCode: sourceCode ?? this.sourceCode,
      isActive: isActive ?? this.isActive,
      createdDate: createdDate ?? this.createdDate,
      executionCount: executionCount ?? this.executionCount,
    );
  }
}

class QAMetrics {
  final String metricsId;
  final DateTime reportDate;
  final double defectDensity;
  final double testEffectiveness;
  final double automationCoverage;
  final int averageDefectResolutionDays;
  final double releaseQualityScore;

  QAMetrics({
    required this.metricsId,
    required this.reportDate,
    required this.defectDensity,
    required this.testEffectiveness,
    required this.automationCoverage,
    required this.averageDefectResolutionDays,
    required this.releaseQualityScore,
  });

  bool get isHealthy => releaseQualityScore >= 80;
  bool get isRecent => DateTime.now().difference(reportDate).inDays <= 30;
  int get ageInDays => DateTime.now().difference(reportDate).inDays;

  QAMetrics copyWith({
    String? metricsId,
    DateTime? reportDate,
    double? defectDensity,
    double? testEffectiveness,
    double? automationCoverage,
    int? averageDefectResolutionDays,
    double? releaseQualityScore,
  }) {
    return QAMetrics(
      metricsId: metricsId ?? this.metricsId,
      reportDate: reportDate ?? this.reportDate,
      defectDensity: defectDensity ?? this.defectDensity,
      testEffectiveness: testEffectiveness ?? this.testEffectiveness,
      automationCoverage: automationCoverage ?? this.automationCoverage,
      averageDefectResolutionDays: averageDefectResolutionDays ?? this.averageDefectResolutionDays,
      releaseQualityScore: releaseQualityScore ?? this.releaseQualityScore,
    );
  }
}
