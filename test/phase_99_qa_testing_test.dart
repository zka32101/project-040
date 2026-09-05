import 'package:flutter_test/flutter_test.dart';
import '../lib/models/qa_testing_models.dart';
import '../lib/services/qa_testing_service.dart';

void main() {
  group('QA Testing & Quality Assurance Tests', () {
    late InMemoryQATestingRepository repository;
    late QATestingManager manager;
    late QATestingFacade facade;

    setUp(() {
      repository = InMemoryQATestingRepository();
      manager = QATestingManager(repository);
      facade = QATestingFacade(repository);
    });

    // Enum Tests
    group('Enum Tests', () {
      test('TestType enum has all values', () {
        expect(TestType.values.length, equals(7));
        expect(TestType.unit.displayName, contains('Unit'));
      });

      test('TestStatus enum has all values', () {
        expect(TestStatus.values.length, equals(6));
      });

      test('DefectSeverity enum has all values', () {
        expect(DefectSeverity.values.length, equals(5));
      });

      test('DefectStatus enum has all values', () {
        expect(DefectStatus.values.length, equals(7));
      });

      test('TestEnvironment enum has all values', () {
        expect(TestEnvironment.values.length, equals(5));
      });

      test('CoverageType enum has all values', () {
        expect(CoverageType.values.length, equals(5));
      });

      test('TestResult enum has all values', () {
        expect(TestResult.values.length, equals(5));
      });
    });

    // Model Tests
    group('Model Tests', () {
      test('TestCase model with automation', () {
        final testCase = TestCase(
          testCaseId: 'tc_001',
          testName: 'Login Test',
          description: 'Test user login functionality',
          testType: TestType.functional,
          status: TestStatus.inProgress,
          assignedTo: 'tester_001',
          stepCount: 5,
          createdDate: DateTime.now().subtract(Duration(days: 10)),
          isAutomated: true,
        );

        expect(testCase.isActive, true);
        expect(testCase.isAutomated, true);
        expect(testCase.ageInDays, equals(10));
      });

      test('Defect model with severity tracking', () {
        final defect = Defect(
          defectId: 'def_001',
          title: 'Login button not clickable',
          description: 'Login button is disabled',
          severity: DefectSeverity.high,
          status: DefectStatus.open,
          reportedBy: 'tester_001',
          assignedTo: 'dev_001',
          createdDate: DateTime.now().subtract(Duration(days: 5)),
          resolvedDate: null,
        );

        expect(defect.isOpen, true);
        expect(defect.isCritical, false);
        expect(defect.ageInDays, equals(5));
      });

      test('TestSuite calculates metrics', () {
        final suite = TestSuite(
          suiteId: 'suite_001',
          suiteName: 'Login Suite',
          totalTestCases: 10,
          executedCount: 8,
          passedCount: 7,
          lastRun: DateTime.now().subtract(Duration(days: 1)),
          estimatedDurationMinutes: 30,
        );

        expect(suite.passRate, equals(70));
        expect(suite.executionRate, equals(80));
        expect(suite.failedCount, equals(1));
      });

      test('CodeCoverage acceptance tracking', () {
        final coverage = CodeCoverage(
          coverId: 'cov_001',
          moduleId: 'mod_001',
          coverageType: CoverageType.lineCoverage,
          percentage: 95,
          linesExecuted: 950,
          totalLines: 1000,
          measuredDate: DateTime.now(),
        );

        expect(coverage.isAcceptable, true);
        expect(coverage.isExcellent, true);
        expect(coverage.gapLines, equals(50));
      });

      test('TestPlan timeline tracking', () {
        final plan = TestPlan(
          planId: 'plan_001',
          planName: 'Release 1.0 Testing',
          projectId: 'proj_001',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          totalTests: 100,
          scope: 'Full regression testing',
          isActive: true,
        );

        expect(plan.isActive, true);
        expect(plan.durationDays, equals(30));
        expect(plan.isOverdue, false);
      });

      test('TestReport health assessment', () {
        final report = TestReport(
          reportId: 'rep_001',
          suiteId: 'suite_001',
          reportDate: DateTime.now(),
          totalTests: 100,
          passedTests: 96,
          failedTests: 4,
          passPercentage: 96,
          defectsFound: 2,
        );

        expect(report.isHealthy, true);
        expect(report.skippedTests, equals(0));
      });
    });

    // Repository Tests
    group('Repository Tests', () {
      test('Create and retrieve test case', () async {
        final testCase = TestCase(
          testCaseId: 'tc_001',
          testName: 'Login Test',
          description: 'Test login',
          testType: TestType.functional,
          status: TestStatus.inProgress,
          assignedTo: 'tester_001',
          stepCount: 5,
          createdDate: DateTime.now(),
          isAutomated: true,
        );

        await repository.createTestCase(testCase);
        final retrieved = await repository.getTestCase('tc_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.testName, equals('Login Test'));
      });

      test('Get active test cases', () async {
        final active = TestCase(
          testCaseId: 'tc_001',
          testName: 'Active Test',
          description: 'Test',
          testType: TestType.unit,
          status: TestStatus.inProgress,
          assignedTo: 'tester_001',
          stepCount: 3,
          createdDate: DateTime.now(),
          isAutomated: false,
        );

        final completed = TestCase(
          testCaseId: 'tc_002',
          testName: 'Completed Test',
          description: 'Test',
          testType: TestType.unit,
          status: TestStatus.completed,
          assignedTo: 'tester_001',
          stepCount: 3,
          createdDate: DateTime.now(),
          isAutomated: false,
        );

        await repository.createTestCase(active);
        await repository.createTestCase(completed);
        final activeList = await repository.getActiveTestCases();

        expect(activeList.length, equals(1));
      });

      test('Get automated test cases', () async {
        final automated = TestCase(
          testCaseId: 'tc_001',
          testName: 'Automated Test',
          description: 'Test',
          testType: TestType.unit,
          status: TestStatus.inProgress,
          assignedTo: 'tester_001',
          stepCount: 5,
          createdDate: DateTime.now(),
          isAutomated: true,
        );

        await repository.createTestCase(automated);
        final automatedList = await repository.getAutomatedTestCases();

        expect(automatedList.length, equals(1));
        expect(automatedList.first.isAutomated, true);
      });

      test('Record and retrieve test execution', () async {
        final execution = TestExecution(
          executionId: 'exec_001',
          testCaseId: 'tc_001',
          result: TestResult.passed,
          executionDate: DateTime.now(),
          durationSeconds: 45,
          executedBy: 'tester_001',
          errorMessage: null,
          environment: TestEnvironment.staging,
        );

        await repository.recordTestExecution(execution);
        final retrieved = await repository.getTestExecution('exec_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.result, equals(TestResult.passed));
      });

      test('Get passed and failed executions', () async {
        final passed = TestExecution(
          executionId: 'exec_001',
          testCaseId: 'tc_001',
          result: TestResult.passed,
          executionDate: DateTime.now(),
          durationSeconds: 30,
          executedBy: 'tester_001',
          errorMessage: null,
          environment: TestEnvironment.staging,
        );

        final failed = TestExecution(
          executionId: 'exec_002',
          testCaseId: 'tc_002',
          result: TestResult.failed,
          executionDate: DateTime.now(),
          durationSeconds: 60,
          executedBy: 'tester_001',
          errorMessage: 'Assertion failed',
          environment: TestEnvironment.staging,
        );

        await repository.recordTestExecution(passed);
        await repository.recordTestExecution(failed);
        
        final passedList = await repository.getPassedExecutions();
        final failedList = await repository.getFailedExecutions();

        expect(passedList.length, equals(1));
        expect(failedList.length, equals(1));
      });

      test('Report and retrieve defect', () async {
        final defect = Defect(
          defectId: 'def_001',
          title: 'Critical bug',
          description: 'Login fails',
          severity: DefectSeverity.critical,
          status: DefectStatus.open,
          reportedBy: 'tester_001',
          assignedTo: 'dev_001',
          createdDate: DateTime.now(),
          resolvedDate: null,
        );

        await repository.reportDefect(defect);
        final retrieved = await repository.getDefect('def_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.isCritical, true);
      });

      test('Get critical defects', () async {
        final critical = Defect(
          defectId: 'def_001',
          title: 'Critical',
          description: 'Test',
          severity: DefectSeverity.critical,
          status: DefectStatus.open,
          reportedBy: 'tester_001',
          assignedTo: 'dev_001',
          createdDate: DateTime.now(),
          resolvedDate: null,
        );

        await repository.reportDefect(critical);
        final criticalList = await repository.getCriticalDefects();

        expect(criticalList.length, equals(1));
      });

      test('Create and retrieve test suite', () async {
        final suite = TestSuite(
          suiteId: 'suite_001',
          suiteName: 'Login Tests',
          totalTestCases: 10,
          executedCount: 8,
          passedCount: 7,
          lastRun: DateTime.now(),
          estimatedDurationMinutes: 30,
        );

        await repository.createTestSuite(suite);
        final retrieved = await repository.getTestSuite('suite_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.suiteName, equals('Login Tests'));
      });

      test('Record and retrieve code coverage', () async {
        final coverage = CodeCoverage(
          coverId: 'cov_001',
          moduleId: 'mod_001',
          coverageType: CoverageType.lineCoverage,
          percentage: 92,
          linesExecuted: 920,
          totalLines: 1000,
          measuredDate: DateTime.now(),
        );

        await repository.recordCodeCoverage(coverage);
        final retrieved = await repository.getCodeCoverage('cov_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.percentage, equals(92));
      });

      test('Get acceptable coverage', () async {
        final acceptable = CodeCoverage(
          coverId: 'cov_001',
          moduleId: 'mod_001',
          coverageType: CoverageType.lineCoverage,
          percentage: 85,
          linesExecuted: 850,
          totalLines: 1000,
          measuredDate: DateTime.now(),
        );

        await repository.recordCodeCoverage(acceptable);
        final acceptableList = await repository.getAcceptableCoverage();

        expect(acceptableList.length, equals(1));
        expect(acceptableList.first.isAcceptable, true);
      });

      test('Create and retrieve test plan', () async {
        final plan = TestPlan(
          planId: 'plan_001',
          planName: 'Release Testing',
          projectId: 'proj_001',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          totalTests: 100,
          scope: 'Full regression',
          isActive: true,
        );

        await repository.createTestPlan(plan);
        final retrieved = await repository.getTestPlan('plan_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.planName, equals('Release Testing'));
      });

      test('Create and retrieve test report', () async {
        final report = TestReport(
          reportId: 'rep_001',
          suiteId: 'suite_001',
          reportDate: DateTime.now(),
          totalTests: 100,
          passedTests: 97,
          failedTests: 3,
          passPercentage: 97,
          defectsFound: 1,
        );

        await repository.createTestReport(report);
        final retrieved = await repository.getTestReport('rep_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.isHealthy, true);
      });

      test('Create and retrieve automation script', () async {
        final script = TestAutomationScript(
          scriptId: 'script_001',
          scriptName: 'Login Automation',
          testType: TestType.functional,
          sourceCode: 'def test_login(): pass',
          isActive: true,
          createdDate: DateTime.now(),
          executionCount: 15,
        );

        await repository.createAutomationScript(script);
        final retrieved = await repository.getAutomationScript('script_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.scriptName, equals('Login Automation'));
      });

      test('Record and retrieve QA metrics', () async {
        final metrics = QAMetrics(
          metricsId: 'met_001',
          reportDate: DateTime.now(),
          defectDensity: 2.5,
          testEffectiveness: 85,
          automationCoverage: 75,
          averageDefectResolutionDays: 3,
          releaseQualityScore: 92,
        );

        await repository.recordQAMetrics(metrics);
        final retrieved = await repository.getQAMetrics('met_001');

        expect(retrieved, isNotNull);
        expect(retrieved!.releaseQualityScore, equals(92));
      });
    });

    // Engine Tests
    group('Engine Tests', () {
      test('Test management engine calculates quality', () async {
        final report = TestReport(
          reportId: 'rep_001',
          suiteId: 'suite_001',
          reportDate: DateTime.now(),
          totalTests: 100,
          passedTests: 95,
          failedTests: 5,
          passPercentage: 95,
          defectsFound: 0,
        );

        final coverage = CodeCoverage(
          coverId: 'cov_001',
          moduleId: 'mod_001',
          coverageType: CoverageType.lineCoverage,
          percentage: 90,
          linesExecuted: 900,
          totalLines: 1000,
          measuredDate: DateTime.now(),
        );

        await repository.createTestReport(report);
        await repository.recordCodeCoverage(coverage);
        final quality = await manager.testEngine.getOverallTestQuality();

        expect(quality, greaterThan(0));
      });
    });

    // Manager Tests
    group('Manager Tests', () {
      test('Get QA dashboard', () async {
        final testCase = TestCase(
          testCaseId: 'tc_001',
          testName: 'Test',
          description: 'Test',
          testType: TestType.unit,
          status: TestStatus.inProgress,
          assignedTo: 'tester_001',
          stepCount: 5,
          createdDate: DateTime.now(),
          isAutomated: true,
        );

        await repository.createTestCase(testCase);
        final dashboard = await manager.getQADashboard();

        expect(dashboard, contains('totalTestCases'));
        expect(dashboard['totalTestCases'], equals(1));
      });
    });

    // Facade Tests
    group('Facade Tests', () {
      test('Create test case through facade', () async {
        final testCase = TestCase(
          testCaseId: 'tc_001',
          testName: 'Test',
          description: 'Test',
          testType: TestType.unit,
          status: TestStatus.inProgress,
          assignedTo: 'tester_001',
          stepCount: 5,
          createdDate: DateTime.now(),
          isAutomated: true,
        );

        await facade.createTestCase(testCase);
        final active = await facade.getActiveTestCases();

        expect(active.length, equals(1));
      });

      test('Get QA dashboard through facade', () async {
        final testCase = TestCase(
          testCaseId: 'tc_001',
          testName: 'Test',
          description: 'Test',
          testType: TestType.unit,
          status: TestStatus.inProgress,
          assignedTo: 'tester_001',
          stepCount: 5,
          createdDate: DateTime.now(),
          isAutomated: true,
        );

        await facade.createTestCase(testCase);
        final dashboard = await facade.getQADashboard();

        expect(dashboard, contains('totalTestCases'));
      });
    });

    // Integration Tests
    group('Integration Tests', () {
      test('Complete testing workflow', () async {
        // Create test case
        final testCase = TestCase(
          testCaseId: 'tc_001',
          testName: 'Login Test',
          description: 'Test login',
          testType: TestType.functional,
          status: TestStatus.inProgress,
          assignedTo: 'tester_001',
          stepCount: 5,
          createdDate: DateTime.now(),
          isAutomated: true,
        );
        await repository.createTestCase(testCase);

        // Execute test
        final execution = TestExecution(
          executionId: 'exec_001',
          testCaseId: 'tc_001',
          result: TestResult.passed,
          executionDate: DateTime.now(),
          durationSeconds: 30,
          executedBy: 'tester_001',
          errorMessage: null,
          environment: TestEnvironment.staging,
        );
        await repository.recordTestExecution(execution);

        // Report metrics
        final report = TestReport(
          reportId: 'rep_001',
          suiteId: 'suite_001',
          reportDate: DateTime.now(),
          totalTests: 1,
          passedTests: 1,
          failedTests: 0,
          passPercentage: 100,
          defectsFound: 0,
        );
        await repository.createTestReport(report);

        // Verify
        final finalReport = await repository.getTestReport('rep_001');
        expect(finalReport!.isHealthy, true);
      });

      test('Defect workflow', () async {
        // Report defect
        final defect = Defect(
          defectId: 'def_001',
          title: 'Login fails',
          description: 'Cannot login',
          severity: DefectSeverity.high,
          status: DefectStatus.open,
          reportedBy: 'tester_001',
          assignedTo: 'dev_001',
          createdDate: DateTime.now(),
          resolvedDate: null,
        );
        await repository.reportDefect(defect);

        // Verify open defect
        var open = await repository.getOpenDefects();
        expect(open.length, equals(1));

        // Resolve defect
        await repository.closeDefect('def_001');
        open = await repository.getOpenDefects();
        expect(open.length, equals(0));
      });
    });
  });
}
