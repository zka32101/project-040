/// Phase 36: Testing Framework & Quality Assurance モデル定義
///
/// テスト実行、モック、カバレッジ分析用モデル

/// テストタイプ
enum TestType {
  unit('unit'),             // ユニットテスト
  integration('integration'), // 統合テスト
  widget('widget'),         // ウィジェットテスト
  performance('performance'), // パフォーマンステスト
  security('security'),     // セキュリティテスト
  endToEnd('e2e');         // エンドツーエンドテスト

  final String value;
  const TestType(this.value);
}

/// テストステータス
enum TestStatus {
  pending('pending'),
  running('running'),
  passed('passed'),
  failed('failed'),
  skipped('skipped'),
  error('error');

  final String value;
  const TestStatus(this.value);
}

/// テストの重要度
enum TestPriority {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  final String value;
  const TestPriority(this.value);
}

/// テストケース定義
class TestCase {
  final String testId;
  final String name;
  final String description;
  final TestType type;
  final TestPriority priority;
  final List<String> tags;
  final String? setupMethod;      // セットアップメソッド
  final String? teardownMethod;   // クリーンアップメソッド
  final Duration? timeout;
  final int retryCount;
  final bool skip;
  final DateTime createdAt;
  final DateTime updatedAt;

  TestCase({
    required this.testId,
    required this.name,
    required this.description,
    required this.type,
    this.priority = TestPriority.medium,
    this.tags = const [],
    this.setupMethod,
    this.teardownMethod,
    this.timeout,
    this.retryCount = 0,
    this.skip = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// フルテスト名を返す
  String get fullName => '$type.$name';
}

/// テスト実行結果
class TestResult {
  final String resultId;
  final String testId;
  final TestStatus status;
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final String? errorMessage;
  final String? stackTrace;
  final int attemptNumber;
  final Map<String, dynamic>? metadata;

  TestResult({
    required this.resultId,
    required this.testId,
    required this.status,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.errorMessage,
    this.stackTrace,
    this.attemptNumber = 1,
    this.metadata,
  });

  /// テストが成功したか
  bool get isPassed => status == TestStatus.passed;

  /// テストが失敗したか
  bool get isFailed => status == TestStatus.failed;

  /// テストがスキップされたか
  bool get isSkipped => status == TestStatus.skipped;
}

/// テストスイート
class TestSuite {
  final String suiteId;
  final String name;
  final String description;
  final List<TestCase> testCases;
  final DateTime createdAt;
  final DateTime updatedAt;

  TestSuite({
    required this.suiteId,
    required this.name,
    required this.description,
    this.testCases = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// テストスイート内のテスト数
  int get totalTests => testCases.length;

  /// スキップされていないテスト数
  int get activeTests => testCases.where((t) => !t.skip).length;
}

/// テスト実行セッション
class TestSession {
  final String sessionId;
  final String name;
  final List<String> suiteIds;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int totalTests;
  final int passedTests;
  final int failedTests;
  final int skippedTests;
  final Duration totalDuration;
  final Map<String, TestResult> results;

  TestSession({
    required this.sessionId,
    required this.name,
    this.suiteIds = const [],
    required this.startedAt,
    this.completedAt,
    this.totalTests = 0,
    this.passedTests = 0,
    this.failedTests = 0,
    this.skippedTests = 0,
    required this.totalDuration,
    this.results = const {},
  });

  /// テスト成功率を返す
  double get successRate {
    if (totalTests == 0) return 0.0;
    return (passedTests / totalTests) * 100;
  }

  /// すべてのテストが成功したか
  bool get isSuccessful => failedTests == 0;
}

/// モック定義
class MockDefinition {
  final String mockId;
  final String name;
  final String targetClass;
  final Map<String, dynamic> returnValues; // メソッド -> 戻り値
  final List<String> callHistory;          // 呼び出し履歴
  final bool autoResetCallHistory;
  final DateTime createdAt;

  MockDefinition({
    required this.mockId,
    required this.name,
    required this.targetClass,
    required this.returnValues,
    this.callHistory = const [],
    this.autoResetCallHistory = true,
    required this.createdAt,
  });

  /// メソッドが呼ばれたか確認
  bool wasMethodCalled(String methodName) {
    return callHistory.contains(methodName);
  }

  /// メソッド呼び出し回数を返す
  int getCallCount(String methodName) {
    return callHistory.where((call) => call == methodName).length;
  }
}

/// テストフィクスチャ
class TestFixture {
  final String fixtureId;
  final String name;
  final String description;
  final Map<String, dynamic> data;  // フィクスチャデータ
  final List<String>? setupSteps;
  final List<String>? teardownSteps;
  final bool reusable;
  final DateTime createdAt;

  TestFixture({
    required this.fixtureId,
    required this.name,
    required this.description,
    required this.data,
    this.setupSteps,
    this.teardownSteps,
    this.reusable = true,
    required this.createdAt,
  });

  /// フィクスチャをクローン
  TestFixture clone() {
    return TestFixture(
      fixtureId: fixtureId,
      name: name,
      description: description,
      data: Map.from(data),
      setupSteps: setupSteps != null ? List.from(setupSteps!) : null,
      teardownSteps: teardownSteps != null ? List.from(teardownSteps!) : null,
      reusable: reusable,
      createdAt: createdAt,
    );
  }
}

/// テストカバレッジ統計
class CoverageStatistics {
  final String statisticsId;
  final int totalLines;
  final int coveredLines;
  final int totalBranches;
  final int coveredBranches;
  final int totalFunctions;
  final int coveredFunctions;
  final DateTime calculatedAt;

  CoverageStatistics({
    required this.statisticsId,
    required this.totalLines,
    required this.coveredLines,
    required this.totalBranches,
    required this.coveredBranches,
    required this.totalFunctions,
    required this.coveredFunctions,
    required this.calculatedAt,
  });

  /// 行カバレッジ率 (%)
  double get lineCoverage {
    if (totalLines == 0) return 0.0;
    return (coveredLines / totalLines) * 100;
  }

  /// ブランチカバレッジ率 (%)
  double get branchCoverage {
    if (totalBranches == 0) return 0.0;
    return (coveredBranches / totalBranches) * 100;
  }

  /// 関数カバレッジ率 (%)
  double get functionCoverage {
    if (totalFunctions == 0) return 0.0;
    return (coveredFunctions / totalFunctions) * 100;
  }

  /// 全体カバレッジ率 (%)
  double get overallCoverage {
    return (lineCoverage + branchCoverage + functionCoverage) / 3;
  }
}

/// パフォーマンステスト結果
class PerformanceTestResult {
  final String resultId;
  final String testId;
  final int executionCount;
  final Duration minTime;
  final Duration maxTime;
  final Duration averageTime;
  final Duration medianTime;
  final List<Duration> allDurations;
  final DateTime measuredAt;

  PerformanceTestResult({
    required this.resultId,
    required this.testId,
    required this.executionCount,
    required this.minTime,
    required this.maxTime,
    required this.averageTime,
    required this.medianTime,
    required this.allDurations,
    required this.measuredAt,
  });

  /// パフォーマンス劣化を検出
  bool isRegression(Duration previousAverage, double thresholdPercent) {
    final increase = ((averageTime.inMilliseconds - previousAverage.inMilliseconds) /
            previousAverage.inMilliseconds) *
        100;
    return increase > thresholdPercent;
  }

  /// 標準偏差を計算
  double get standardDeviation {
    if (allDurations.isEmpty) return 0.0;
    final mean = averageTime.inMilliseconds.toDouble();
    final variance = allDurations
            .map((d) => (d.inMilliseconds - mean) * (d.inMilliseconds - mean))
            .reduce((a, b) => a + b) /
        allDurations.length;
    return variance.isFinite ? variance.toDouble().sqrt() : 0.0;
  }
}

extension on double {
  double sqrt() => double.parse(this.toString()); // 簡易実装
}

/// テストレポート
class TestReport {
  final String reportId;
  final String title;
  final DateTime generatedAt;
  final int totalSuites;
  final int totalTests;
  final int passedTests;
  final int failedTests;
  final int skippedTests;
  final Duration totalDuration;
  final CoverageStatistics? coverage;
  final List<TestResult> failedResults;
  final Map<String, dynamic>? additionalMetrics;

  TestReport({
    required this.reportId,
    required this.title,
    required this.generatedAt,
    required this.totalSuites,
    required this.totalTests,
    required this.passedTests,
    required this.failedTests,
    required this.skippedTests,
    required this.totalDuration,
    this.coverage,
    this.failedResults = const [],
    this.additionalMetrics,
  });

  /// テスト成功率 (%)
  double get successRate {
    if (totalTests == 0) return 0.0;
    return (passedTests / totalTests) * 100;
  }

  /// レポートをMarkdownで生成
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Test Report: $title');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');
    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Total Suites: $totalSuites');
    buffer.writeln('- Total Tests: $totalTests');
    buffer.writeln('- Passed: $passedTests ✅');
    buffer.writeln('- Failed: $failedTests ❌');
    buffer.writeln('- Skipped: $skippedTests ⏭️');
    buffer.writeln('- Success Rate: ${successRate.toStringAsFixed(2)}%');
    buffer.writeln('- Total Duration: ${totalDuration.inSeconds}s');
    buffer.writeln('');

    if (coverage != null) {
      buffer.writeln('## Coverage');
      buffer.writeln('');
      buffer.writeln('- Line Coverage: ${coverage!.lineCoverage.toStringAsFixed(2)}%');
      buffer.writeln(
          '- Branch Coverage: ${coverage!.branchCoverage.toStringAsFixed(2)}%');
      buffer.writeln(
          '- Function Coverage: ${coverage!.functionCoverage.toStringAsFixed(2)}%');
      buffer.writeln('- Overall: ${coverage!.overallCoverage.toStringAsFixed(2)}%');
      buffer.writeln('');
    }

    if (failedResults.isNotEmpty) {
      buffer.writeln('## Failed Tests');
      buffer.writeln('');
      for (final result in failedResults) {
        buffer.writeln('### ${result.testId}');
        buffer.writeln('');
        buffer.writeln('**Error**: ${result.errorMessage}');
        buffer.writeln('');
      }
    }

    return buffer.toString();
  }
}

/// テスト設定
class TestConfiguration {
  final String configId;
  final bool parallelExecution;
  final int parallelWorkers;
  final bool failFast;
  final Duration testTimeout;
  final bool captureOutput;
  final bool generateCoverage;
  final String? coverageMinimum;  // 最小カバレッジ % (例: "80")
  final List<String> excludePatterns;
  final DateTime createdAt;

  TestConfiguration({
    required this.configId,
    this.parallelExecution = true,
    this.parallelWorkers = 4,
    this.failFast = false,
    this.testTimeout = const Duration(seconds: 30),
    this.captureOutput = true,
    this.generateCoverage = true,
    this.coverageMinimum,
    this.excludePatterns = const [],
    required this.createdAt,
  });
}
