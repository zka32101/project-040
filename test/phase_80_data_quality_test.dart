import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/data_quality_models.dart';
import 'package:project_040/services/data_quality_service.dart';

void main() {
  group('Data Quality Tests', () {
    late DataQualityRepositoryImpl repository;

    setUp(() {
      repository = DataQualityRepositoryImpl();
    });

    // Enum Tests
    group('Enum Tests', () {
      test('DataQualityLevel enum has all values', () {
        expect(DataQualityLevel.values.length, 5);
        expect(DataQualityLevel.critical, isNotNull);
      });

      test('ValidationRuleType enum has all values', () {
        expect(ValidationRuleType.values.length, 7);
        expect(ValidationRuleType.regex, isNotNull);
      });

      test('ScanStatus enum has all values', () {
        expect(ScanStatus.values.length, 5);
        expect(ScanStatus.pending, isNotNull);
      });

      test('AnomalyType enum has all values', () {
        expect(AnomalyType.values.length, 5);
        expect(AnomalyType.outlier, isNotNull);
      });

      test('ComplianceLevel enum has all values', () {
        expect(ComplianceLevel.values.length, 4);
        expect(ComplianceLevel.compliant, isNotNull);
      });

      test('IssueStatus enum has all values', () {
        expect(IssueStatus.values.length, 5);
        expect(IssueStatus.detected, isNotNull);
      });
    });

    // Model Tests
    group('Model Tests', () {
      test('DataQualityMetric model creation and computed properties', () {
        final metric = DataQualityMetric(
          metricId: 'm1',
          datasetId: 'ds1',
          completenessScore: 98.0,
          accuracyScore: 96.0,
          consistencyScore: 94.0,
          uniquenessScore: 95.0,
          measuredAt: DateTime.now(),
          details: {},
        );
        expect(metric.overallScore, greaterThan(95.0));
        expect(metric.isHealthy, true);
      });

      test('ValidationRule model with critical severity', () {
        final rule = ValidationRule(
          ruleId: 'r1',
          datasetId: 'ds1',
          columnName: 'email',
          type: ValidationRuleType.regex,
          ruleExpression: '^[\\w-\\.]+@[\\w-\\.]+$',
          createdAt: DateTime.now(),
          severity: 9,
        );
        expect(rule.isCritical, true);
      });

      test('DataScan model completion tracking', () {
        final scan = DataScan(
          scanId: 's1',
          datasetId: 'ds1',
          startTime: DateTime.now(),
          status: ScanStatus.completed,
          recordsScanned: 1000,
          issuesFound: 10,
          columnTargets: ['col1', 'col2'],
        );
        expect(scan.isComplete, true);
        expect(scan.issueRate, 1.0);
      });

      test('DataAnomalyDetection high confidence', () {
        final anomaly = DataAnomalyDetection(
          anomalyId: 'a1',
          datasetId: 'ds1',
          columnName: 'amount',
          type: AnomalyType.outlier,
          value: 999999.99,
          detectedAt: DateTime.now(),
          confidenceScore: 0.95,
        );
        expect(anomaly.isHighConfidence, true);
      });

      test('ComplianceCheck status assessment', () {
        final check = ComplianceCheck(
          checkId: 'cc1',
          datasetId: 'ds1',
          checkName: 'GDPR Compliance',
          complianceFramework: 'GDPR',
          checkedAt: DateTime.now(),
          level: ComplianceLevel.compliant,
          isPassed: true,
        );
        expect(check.needsAction, false);
      });

      test('QualityIssue critical severity tracking', () {
        final issue = QualityIssue(
          issueId: 'qi1',
          datasetId: 'ds1',
          issueType: 'missing_values',
          description: 'Missing values in payment column',
          detectedAt: DateTime.now(),
          status: IssueStatus.detected,
          affectedRecordCount: 5000,
          severity: 'critical',
        );
        expect(issue.isCritical, true);
        expect(issue.isResolved, false);
      });

      test('DataProfile statistics and nullability', () {
        final profile = DataProfile(
          profileId: 'dp1',
          datasetId: 'ds1',
          generatedAt: DateTime.now(),
          columnProfiles: {'col1': {}, 'col2': {}},
          totalRecords: 10000,
          nullCount: 50,
          sampledValues: ['val1', 'val2'],
          statistics: {},
        );
        expect(profile.nullPercentage, 0.5);
        expect(profile.profileColumnCount, 2);
      });

      test('ScanResult success rate calculation', () {
        final result = ScanResult(
          resultId: 'sr1',
          scanId: 's1',
          datasetId: 'ds1',
          generatedAt: DateTime.now(),
          passedChecks: 95,
          failedChecks: 5,
          failedRuleIds: [],
          issueBreakdown: {},
        );
        expect(result.successRate, 95.0);
        expect(result.isPassed, false);
      });

      test('QualityTrend direction detection', () {
        final trend = QualityTrend(
          trendId: 'qt1',
          datasetId: 'ds1',
          periodStart: DateTime.now().subtract(Duration(days: 7)),
          periodEnd: DateTime.now(),
          scoreHistory: [80.0, 82.0, 85.0, 87.0, 90.0],
          avgScore: 84.8,
          minScore: 80.0,
          maxScore: 90.0,
          trend: 'improving',
        );
        expect(trend.isImproving, true);
        expect(trend.scoreRange, 10.0);
      });

      test('DataAsset size classification', () {
        final asset = DataAsset(
          assetId: 'da1',
          assetName: 'orders_table',
          assetType: 'table',
          createdAt: DateTime.now(),
          owner: 'data_team',
          recordCount: 5000000,
          columnCount: 15,
        );
        expect(asset.isLarge, true);
      });

      test('QualityScore level assessment', () {
        final score = QualityScore(
          scoreId: 'qs1',
          datasetId: 'ds1',
          calculatedAt: DateTime.now(),
          score: 92.5,
          level: DataQualityLevel.critical,
          componentScores: {'completeness': 95.0},
        );
        expect(score.isAcceptable, true);
        expect(score.needsImprovement, false);
      });

      test('QualityReport issue resolution tracking', () {
        final report = QualityReport(
          reportId: 'qr1',
          datasetId: 'ds1',
          generatedAt: DateTime.now(),
          periodStart: DateTime.now().subtract(Duration(days: 7)),
          periodEnd: DateTime.now(),
          overallScore: 88.0,
          issuesDetected: 20,
          issuesResolved: 15,
          recommendations: [],
        );
        expect(report.resolutionRate, 75.0);
        expect(report.pendingIssues, 5);
      });
    });

    // DataQualityMetric Tests
    group('DataQualityMetric Tests', () {
      test('Create metric', () async {
        final metric = await repository.createMetric('ds1', 95.0, 92.0, 90.0, 93.0);
        expect(metric.datasetId, 'ds1');
        expect(metric.completenessScore, 95.0);
      });

      test('Get latest metric', () async {
        await repository.createMetric('ds1', 90.0, 88.0, 85.0, 87.0);
        await Future.delayed(Duration(milliseconds: 10));
        await repository.createMetric('ds1', 95.0, 92.0, 90.0, 93.0);
        final latest = await repository.getLatestMetric('ds1');
        expect(latest, isNotNull);
        expect(latest!.completenessScore, 95.0);
      });

      test('Get metrics by dataset', () async {
        await repository.createMetric('ds1', 95.0, 92.0, 90.0, 93.0);
        final metrics = await repository.getMetricsByDataset('ds1');
        expect(metrics.length, 1);
      });

      test('Get metric count', () async {
        final before = await repository.getMetricCount();
        await repository.createMetric('ds1', 95.0, 92.0, 90.0, 93.0);
        final after = await repository.getMetricCount();
        expect(after, before + 1);
      });
    });

    // ValidationRule Tests
    group('ValidationRule Tests', () {
      test('Create validation rule', () async {
        final rule = await repository.createValidationRule(
          'ds1',
          'email',
          ValidationRuleType.regex,
          '^[\\w-\\.]+@[\\w-\\.]+$',
        );
        expect(rule.columnName, 'email');
        expect(rule.isActive, true);
      });

      test('Update rule severity', () async {
        final rule = await repository.createValidationRule(
          'ds1',
          'email',
          ValidationRuleType.regex,
          '^[\\w-\\.]+@[\\w-\\.]+$',
        );
        final updated = await repository.updateValidationRule(rule.ruleId, severity: 9);
        expect(updated.severity, 9);
        expect(updated.isCritical, true);
      });

      test('Get active rules', () async {
        await repository.createValidationRule('ds1', 'col1', ValidationRuleType.range, '>0');
        final active = await repository.getActiveRules();
        expect(active.length, greaterThan(0));
      });

      test('Get rules by dataset', () async {
        await repository.createValidationRule('ds1', 'col1', ValidationRuleType.format, 'ISO8601');
        final rules = await repository.getRulesByDataset('ds1');
        expect(rules.length, greaterThan(0));
      });

      test('Delete validation rule', () async {
        final rule = await repository.createValidationRule('ds1', 'col1', ValidationRuleType.uniqueness, 'unique');
        await repository.deleteValidationRule(rule.ruleId);
        final retrieved = await repository.getValidationRule(rule.ruleId);
        expect(retrieved, isNull);
      });
    });

    // DataScan Tests
    group('DataScan Tests', () {
      test('Create scan', () async {
        final scan = await repository.createScan('ds1', ['col1', 'col2']);
        expect(scan.status, ScanStatus.pending);
        expect(scan.columnTargets.length, 2);
      });

      test('Update scan status', () async {
        final scan = await repository.createScan('ds1', ['col1']);
        final updated = await repository.updateScanStatus(
          scan.scanId,
          ScanStatus.completed,
          recordsScanned: 5000,
          issuesFound: 50,
        );
        expect(updated.isComplete, true);
        expect(updated.issueRate, 1.0);
      });

      test('Get completed scans', () async {
        final scan = await repository.createScan('ds1', ['col1']);
        await repository.updateScanStatus(scan.scanId, ScanStatus.completed);
        final completed = await repository.getCompletedScans();
        expect(completed.length, greaterThan(0));
      });

      test('Get scans by dataset', () async {
        await repository.createScan('ds1', ['col1']);
        final scans = await repository.getScansByDataset('ds1');
        expect(scans.length, 1);
      });

      test('Get scan count', () async {
        final before = await repository.getScanCount();
        await repository.createScan('ds1', ['col1']);
        final after = await repository.getScanCount();
        expect(after, before + 1);
      });
    });

    // DataAnomalyDetection Tests
    group('DataAnomalyDetection Tests', () {
      test('Record anomaly', () async {
        final anomaly = await repository.recordAnomaly(
          'ds1',
          'amount',
          AnomalyType.outlier,
          999999.99,
          0.9,
        );
        expect(anomaly.type, AnomalyType.outlier);
        expect(anomaly.isConfirmed, false);
      });

      test('Confirm anomaly', () async {
        final anomaly = await repository.recordAnomaly('ds1', 'col1', AnomalyType.duplicate, 'value', 0.85);
        final confirmed = await repository.confirmAnomaly(anomaly.anomalyId);
        expect(confirmed.isConfirmed, true);
      });

      test('Get unconfirmed anomalies', () async {
        await repository.recordAnomaly('ds1', 'col1', AnomalyType.missing, null, 0.88);
        final unconfirmed = await repository.getUnconfirmedAnomalies();
        expect(unconfirmed.length, greaterThan(0));
      });

      test('Get anomalies by dataset', () async {
        await repository.recordAnomaly('ds1', 'col1', AnomalyType.malformed, 'bad_value', 0.75);
        final anomalies = await repository.getAnomaliesByDataset('ds1');
        expect(anomalies.length, greaterThan(0));
      });

      test('Get anomaly count', () async {
        final before = await repository.getAnomalyCount();
        await repository.recordAnomaly('ds1', 'col1', AnomalyType.inconsistent, 'value', 0.92);
        final after = await repository.getAnomalyCount();
        expect(after, before + 1);
      });
    });

    // ComplianceCheck Tests
    group('ComplianceCheck Tests', () {
      test('Create compliance check', () async {
        final check = await repository.createComplianceCheck('ds1', 'GDPR Check', 'GDPR', true);
        expect(check.checkName, 'GDPR Check');
        expect(check.isPassed, true);
      });

      test('Update compliance level', () async {
        final check = await repository.createComplianceCheck('ds1', 'HIPAA Check', 'HIPAA', false);
        final updated = await repository.updateComplianceCheckLevel(check.checkId, ComplianceLevel.critical);
        expect(updated.level, ComplianceLevel.critical);
        expect(updated.needsAction, true);
      });

      test('Get failed checks', () async {
        await repository.createComplianceCheck('ds1', 'Check 1', 'GDPR', false);
        final failed = await repository.getFailedChecks();
        expect(failed.length, greaterThan(0));
      });

      test('Get checks by dataset', () async {
        await repository.createComplianceCheck('ds1', 'Check 2', 'SOC2', true);
        final checks = await repository.getChecksByDataset('ds1');
        expect(checks.length, greaterThan(0));
      });

      test('Get compliance check count', () async {
        final before = await repository.getComplianceCheckCount();
        await repository.createComplianceCheck('ds1', 'Check 3', 'PCI-DSS', true);
        final after = await repository.getComplianceCheckCount();
        expect(after, before + 1);
      });
    });

    // QualityIssue Tests
    group('QualityIssue Tests', () {
      test('Create issue', () async {
        final issue = await repository.createIssue('ds1', 'missing_values', 'Missing data', 1000);
        expect(issue.issueType, 'missing_values');
        expect(issue.status, IssueStatus.detected);
      });

      test('Update issue status', () async {
        final issue = await repository.createIssue('ds1', 'duplicates', 'Duplicate rows', 500);
        final updated = await repository.updateIssueStatus(issue.issueId, IssueStatus.inProgress);
        expect(updated.status, IssueStatus.inProgress);
      });

      test('Get unresolved issues', () async {
        await repository.createIssue('ds1', 'type1', 'desc', 100);
        final unresolved = await repository.getUnresolvedIssues();
        expect(unresolved.length, greaterThan(0));
      });

      test('Get issues by dataset', () async {
        await repository.createIssue('ds1', 'type2', 'desc', 200);
        final issues = await repository.getIssuesByDataset('ds1');
        expect(issues.length, greaterThan(0));
      });

      test('Get issue count', () async {
        final before = await repository.getIssueCount();
        await repository.createIssue('ds1', 'type3', 'desc', 300);
        final after = await repository.getIssueCount();
        expect(after, before + 1);
      });
    });

    // DataProfile Tests
    group('DataProfile Tests', () {
      test('Create profile', () async {
        final profile = await repository.createProfile('ds1', {'col1': {}}, 10000);
        expect(profile.datasetId, 'ds1');
        expect(profile.totalRecords, 10000);
      });

      test('Get latest profile', () async {
        await repository.createProfile('ds1', {'col1': {}}, 5000);
        await Future.delayed(Duration(milliseconds: 10));
        await repository.createProfile('ds1', {'col1': {}, 'col2': {}}, 10000);
        final latest = await repository.getLatestProfile('ds1');
        expect(latest, isNotNull);
        expect(latest!.totalRecords, 10000);
      });

      test('Get profiles by dataset', () async {
        await repository.createProfile('ds1', {'col1': {}}, 5000);
        final profiles = await repository.getProfilesByDataset('ds1');
        expect(profiles.length, 1);
      });

      test('Get profile count', () async {
        final before = await repository.getProfileCount();
        await repository.createProfile('ds1', {'col1': {}}, 5000);
        final after = await repository.getProfileCount();
        expect(after, before + 1);
      });
    });

    // ScanResult Tests
    group('ScanResult Tests', () {
      test('Create scan result', () async {
        final result = await repository.createScanResult('s1', 'ds1', 95, 5);
        expect(result.passedChecks, 95);
        expect(result.failedChecks, 5);
      });

      test('Get failed results', () async {
        await repository.createScanResult('s1', 'ds1', 80, 20);
        final failed = await repository.getFailedResults();
        expect(failed.length, greaterThan(0));
      });

      test('Get results by dataset', () async {
        await repository.createScanResult('s1', 'ds1', 90, 10);
        final results = await repository.getResultsByDataset('ds1');
        expect(results.length, 1);
      });

      test('Get scan result count', () async {
        final before = await repository.getScanResultCount();
        await repository.createScanResult('s1', 'ds1', 85, 15);
        final after = await repository.getScanResultCount();
        expect(after, before + 1);
      });
    });

    // QualityTrend Tests
    group('QualityTrend Tests', () {
      test('Create trend', () async {
        final trend = await repository.createTrend(
          'ds1',
          DateTime.now().subtract(Duration(days: 7)),
          DateTime.now(),
          [80.0, 82.0, 85.0, 87.0, 90.0],
        );
        expect(trend.datasetId, 'ds1');
        expect(trend.scoreHistory.length, 5);
      });

      test('Get trends by dataset', () async {
        await repository.createTrend(
          'ds1',
          DateTime.now().subtract(Duration(days: 7)),
          DateTime.now(),
          [75.0, 80.0, 85.0],
        );
        final trends = await repository.getTrendsByDataset('ds1');
        expect(trends.length, 1);
      });

      test('Get trend count', () async {
        final before = await repository.getTrendCount();
        await repository.createTrend(
          'ds1',
          DateTime.now().subtract(Duration(days: 7)),
          DateTime.now(),
          [70.0, 75.0, 80.0],
        );
        final after = await repository.getTrendCount();
        expect(after, before + 1);
      });
    });

    // DataAsset Tests
    group('DataAsset Tests', () {
      test('Create asset', () async {
        final asset = await repository.createAsset('customers', 'table', 'data_team');
        expect(asset.assetName, 'customers');
        expect(asset.isMonitored, true);
      });

      test('Update asset monitoring', () async {
        final asset = await repository.createAsset('users', 'table', 'team1');
        final updated = await repository.updateAssetMonitoring(asset.assetId, false);
        expect(updated.isMonitored, false);
      });

      test('Get monitored assets', () async {
        await repository.createAsset('orders', 'table', 'team2');
        final monitored = await repository.getMonitoredAssets();
        expect(monitored.length, greaterThan(0));
      });

      test('Get asset count', () async {
        final before = await repository.getAssetCount();
        await repository.createAsset('products', 'table', 'team3');
        final after = await repository.getAssetCount();
        expect(after, before + 1);
      });
    });

    // QualityScore Tests
    group('QualityScore Tests', () {
      test('Create score', () async {
        final score = await repository.createScore('ds1', 92.5, {'completeness': 95.0});
        expect(score.score, 92.5);
        expect(score.level, DataQualityLevel.critical);
      });

      test('Get scores by dataset', () async {
        await repository.createScore('ds1', 88.0, {});
        final scores = await repository.getScoresByDataset('ds1');
        expect(scores.length, 1);
      });

      test('Get score count', () async {
        final before = await repository.getScoreCount();
        await repository.createScore('ds1', 85.0, {});
        final after = await repository.getScoreCount();
        expect(after, before + 1);
      });
    });

    // QualityReport Tests
    group('QualityReport Tests', () {
      test('Generate report', () async {
        final now = DateTime.now();
        final report = await repository.generateReport(
          'ds1',
          now.subtract(Duration(days: 7)),
          now,
        );
        expect(report.datasetId, 'ds1');
      });

      test('Get reports by dataset', () async {
        final now = DateTime.now();
        await repository.generateReport('ds1', now.subtract(Duration(days: 7)), now);
        final reports = await repository.getReportsByDataset('ds1');
        expect(reports.length, 1);
      });

      test('Get report count', () async {
        final before = await repository.getReportCount();
        final now = DateTime.now();
        await repository.generateReport('ds1', now.subtract(Duration(days: 7)), now);
        final after = await repository.getReportCount();
        expect(after, before + 1);
      });
    });

    // Engine Tests
    group('Engine Tests', () {
      test('ValidationEngine validates rule', () async {
        final engine = ValidationEngine();
        final rule = ValidationRule(
          ruleId: 'r1',
          datasetId: 'ds1',
          columnName: 'email',
          type: ValidationRuleType.regex,
          ruleExpression: '^[\\w-\\.]+@[\\w-\\.]+$',
          createdAt: DateTime.now(),
        );
        final result = await engine.validateRule(rule, 'test@example.com');
        expect(result, true);
      });

      test('AnomalyDetectionEngine detects anomalies', () async {
        final engine = AnomalyDetectionEngine();
        final profile = DataProfile(
          profileId: 'p1',
          datasetId: 'ds1',
          generatedAt: DateTime.now(),
          columnProfiles: {},
          totalRecords: 1000,
          sampledValues: [],
          statistics: {},
        );
        final anomalies = await engine.detectAnomalies(profile);
        expect(anomalies, isA<List>());
      });

      test('ScanEngine executes scan', () async {
        final engine = ScanEngine();
        final scan = DataScan(
          scanId: 's1',
          datasetId: 'ds1',
          startTime: DateTime.now(),
          status: ScanStatus.pending,
          columnTargets: ['col1'],
        );
        expect(() => engine.executeScan(scan), returnsNormally);
      });

      test('ComplianceEngine evaluates compliance', () async {
        final engine = ComplianceEngine();
        final level = await engine.evaluateCompliance('ds1');
        expect(level, ComplianceLevel.compliant);
      });

      test('ProfileEngine generates profile', () async {
        final engine = ProfileEngine();
        final profile = await engine.generateProfile('ds1');
        expect(profile.datasetId, 'ds1');
      });
    });

    // Facade Tests
    group('Facade Tests', () {
      test('Facade registers dataset', () async {
        final repository = DataQualityRepositoryImpl();
        final manager = DataQualityManager(
          repository: repository,
          validationEngine: ValidationEngine(),
          anomalyEngine: AnomalyDetectionEngine(),
          scanEngine: ScanEngine(),
          complianceEngine: ComplianceEngine(),
          profileEngine: ProfileEngine(),
        );
        final facade = DataQualityFacade(repository: repository, manager: manager);
        final asset = await facade.registerDataset('transactions', 'table', 'finance');
        expect(asset.assetName, 'transactions');
      });

      test('Facade measures quality', () async {
        final repository = DataQualityRepositoryImpl();
        final manager = DataQualityManager(
          repository: repository,
          validationEngine: ValidationEngine(),
          anomalyEngine: AnomalyDetectionEngine(),
          scanEngine: ScanEngine(),
          complianceEngine: ComplianceEngine(),
          profileEngine: ProfileEngine(),
        );
        final facade = DataQualityFacade(repository: repository, manager: manager);
        final metric = await facade.measureQuality('ds1');
        expect(metric.isHealthy, true);
      });

      test('Facade gets unresolved issue count', () async {
        final repository = DataQualityRepositoryImpl();
        final manager = DataQualityManager(
          repository: repository,
          validationEngine: ValidationEngine(),
          anomalyEngine: AnomalyDetectionEngine(),
          scanEngine: ScanEngine(),
          complianceEngine: ComplianceEngine(),
          profileEngine: ProfileEngine(),
        );
        final facade = DataQualityFacade(repository: repository, manager: manager);
        final count = await facade.getUnresolvedIssueCount();
        expect(count, isA<int>());
      });

      test('Facade gets average quality score', () async {
        final repository = DataQualityRepositoryImpl();
        final manager = DataQualityManager(
          repository: repository,
          validationEngine: ValidationEngine(),
          anomalyEngine: AnomalyDetectionEngine(),
          scanEngine: ScanEngine(),
          complianceEngine: ComplianceEngine(),
          profileEngine: ProfileEngine(),
        );
        final facade = DataQualityFacade(repository: repository, manager: manager);
        await facade.registerDataset('test', 'table', 'team');
        await repository.createScore('ds1', 90.0, {});
        final avgScore = await facade.getAverageQualityScore();
        expect(avgScore, greaterThanOrEqualTo(0.0));
      });
    });

    // Integration Tests
    group('Integration Tests', () {
      test('Complete quality workflow', () async {
        // Create asset
        final asset = await repository.createAsset('orders', 'table', 'data_team');
        expect(asset.isMonitored, true);

        // Create validation rule
        await repository.createValidationRule(
          asset.assetId,
          'order_id',
          ValidationRuleType.uniqueness,
          'unique',
        );

        // Create scan
        final scan = await repository.createScan(asset.assetId, ['order_id', 'amount']);

        // Update scan status
        await repository.updateScanStatus(
          scan.scanId,
          ScanStatus.completed,
          recordsScanned: 50000,
          issuesFound: 50,
        );

        // Get results
        final scans = await repository.getScansByDataset(asset.assetId);
        expect(scans.length, 1);
      });

      test('Issue detection and resolution', () async {
        final asset = await repository.createAsset('users', 'table', 'team');

        // Create issue
        var issue = await repository.createIssue(
          asset.assetId,
          'missing_emails',
          '5000 users missing email',
          5000,
        );
        expect(issue.isResolved, false);

        // Resolve issue
        issue = await repository.updateIssueStatus(issue.issueId, IssueStatus.resolved);
        expect(issue.isResolved, true);
      });

      test('Compliance monitoring', () async {
        final asset = await repository.createAsset('sensitive_data', 'table', 'compliance');

        // Create compliance checks
        var gdpr = await repository.createComplianceCheck(
          asset.assetId,
          'GDPR Compliance',
          'GDPR',
          false,
        );
        expect(gdpr.needsAction, true);

        // Update status
        gdpr = await repository.updateComplianceCheckLevel(gdpr.checkId, ComplianceLevel.warning);
        expect(gdpr.needsAction, true);
      });
    });

    // Performance Tests
    group('Performance Tests', () {
      test('Bulk metric creation', () async {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 100; i++) {
          await repository.createMetric('ds$i', 90.0 + i, 88.0 + i, 85.0 + i, 87.0 + i);
        }

        stopwatch.stop();
        expect(await repository.getMetricCount(), greaterThanOrEqualTo(100));
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('Bulk issue creation', () async {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 200; i++) {
          await repository.createIssue('ds1', 'type$i', 'Description $i', i * 10);
        }

        stopwatch.stop();
        expect(await repository.getIssueCount(), greaterThanOrEqualTo(200));
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });
    });

    // Edge Case Tests
    group('Edge Case Tests', () {
      test('Empty dataset metrics', () async {
        final metrics = await repository.getMetricsByDataset('nonexistent');
        expect(metrics.isEmpty, true);
      });

      test('Negative issue count', () async {
        final asset = await repository.createAsset('test', 'table', 'team');
        final report = await repository.generateReport(asset.assetId, DateTime.now(), DateTime.now());
        expect(report.pendingIssues, greaterThanOrEqualTo(0));
      });

      test('High volume profile generation', () async {
        final profiles = <DataProfile>[];
        for (int i = 0; i < 50; i++) {
          profiles.add(await repository.createProfile('ds1', {'col': {}}, 1000000));
        }
        expect(profiles.length, 50);
      });

      test('Rule with critical severity', () async {
        final rule = await repository.createValidationRule(
          'ds1',
          'sensitive_col',
          ValidationRuleType.completeness,
          'no_nulls',
        );
        final updated = await repository.updateValidationRule(rule.ruleId, severity: 10);
        expect(updated.isCritical, true);
      });

      test('Anomaly with perfect confidence', () async {
        final anomaly = await repository.recordAnomaly('ds1', 'col', AnomalyType.outlier, 'val', 1.0);
        expect(anomaly.isHighConfidence, true);
      });
    });
  });
}
