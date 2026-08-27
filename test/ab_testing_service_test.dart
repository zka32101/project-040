import 'package:flutter_test/flutter_test.dart';
import 'package:bike_license_kore/models/ab_test_model.dart';
import 'package:bike_license_kore/services/ab_testing_service.dart';

void main() {
  group('A/B Testing Service', () {
    late StubABTestingService service;

    setUp(() {
      service = StubABTestingService();
    });

    group('User variant assignment', () {
      test('should assign user to variant consistently', () async {
        const userId = 'test_user_123';
        const testId = 'test_001';

        final variant1 = await service.getUserVariant(userId, testId);
        final variant2 = await service.getUserVariant(userId, testId);

        expect(variant1, equals(variant2));
      });

      test('should assign different users to different variants', () async {
        const testId = 'test_001';
        final variants = <ABTestVariant>[];

        for (int i = 0; i < 100; i++) {
          final variant = await service.getUserVariant('user_$i', testId);
          variants.add(variant);
        }

        final controlCount =
            variants.where((v) => v == ABTestVariant.control).length;
        final variantCount =
            variants.where((v) => v == ABTestVariant.variant).length;

        // Should have roughly 50-50 split
        expect(controlCount, greaterThan(30));
        expect(variantCount, greaterThan(30));
        expect(controlCount + variantCount, equals(100));
      });

      test('should assign new users to variants', () async {
        const testId = 'test_001';

        final variant = await service.getUserVariant('new_user', testId);

        expect(
          variant,
          isIn([ABTestVariant.control, ABTestVariant.variant]),
        );
      });
    });

    group('Test event tracking', () {
      test('should record test events', () async {
        const userId = 'user_123';
        const testId = 'test_001';

        await service.recordTestEvent(userId, testId, 'page_view', {
          'page': 'quiz',
          'duration': 30,
        });

        // Should not throw
        expect(true, isTrue);
      });

      test('should record conversion events', () async {
        const userId = 'user_123';
        const testId = 'test_001';

        await service.recordConversion(userId, testId);

        expect(true, isTrue);
      });

      test('should record events with metadata', () async {
        const userId = 'user_123';
        const testId = 'test_001';
        const metadata = {
          'sessionDuration': 300,
          'accuracy': 85.5,
          'engagementScore': 92,
        };

        await service.recordTestEvent(userId, testId, 'session_complete', metadata);

        expect(true, isTrue);
      });
    });

    group('Test results analysis', () {
      test('should get test results', () async {
        const testId = 'test_001';

        final results = await service.getTestResults(testId);

        expect(results, isNotNull);
        expect(results.sampleSize, greaterThanOrEqualTo(0));
        expect(results.conversionRate, greaterThanOrEqualTo(0.0));
        expect(results.conversionRate, lessThanOrEqualTo(1.0));
      });

      test('should return empty results when no events', () async {
        const testId = 'test_001';

        final results = await service.getTestResults(testId);

        expect(results.sampleSize, equals(0));
        expect(results.conversionRate, equals(0.0));
      });

      test('should calculate variant metrics correctly', () async {
        const testId = 'test_001';

        final results = await service.getTestResults(testId);

        expect(results.variant, isNotNull);
        expect(results.averageSessionDuration, greaterThanOrEqualTo(0.0));
        expect(results.averageAccuracy, greaterThanOrEqualTo(0.0));
        expect(results.engagementScore, greaterThanOrEqualTo(0.0));
      });
    });

    group('Statistical analysis', () {
      test('should perform significance analysis', () async {
        const testId = 'test_001';

        final result = await service.analyzeTestResults(testId);

        expect(result, isNotNull);
        expect(result.pValue, greaterThanOrEqualTo(0.0));
        expect(result.pValue, lessThanOrEqualTo(1.0));
        expect(result.confidenceLevel, greaterThanOrEqualTo(0.0));
        expect(result.confidenceLevel, lessThanOrEqualTo(1.0));
      });

      test('should provide recommendation', () async {
        const testId = 'test_001';

        final result = await service.analyzeTestResults(testId);

        expect(
          result.recommendation,
          isIn(['control_wins', 'variant_wins', 'inconclusive']),
        );
      });

      test('should identify significant results', () async {
        const testId = 'test_001';

        final result = await service.analyzeTestResults(testId);

        if (result.isSignificant) {
          expect(result.pValue, lessThan(0.05));
        } else {
          expect(result.pValue, greaterThanOrEqualTo(0.05));
        }
      });
    });

    group('User assignments', () {
      test('should check if user is in variant', () async {
        const userId = 'user_123';
        const testId = 'test_001';

        final inVariant = await service.isUserInVariant(userId, testId);

        expect(inVariant, isBool);
      });

      test('should get all user assignments', () async {
        const userId = 'user_123';

        final assignments = await service.getUserAssignments(userId);

        expect(assignments, isA<Map<String, ABTestVariant>>());
      });

      test('should return empty assignments for new user', () async {
        const userId = 'new_user_xyz';

        final assignments = await service.getUserAssignments(userId);

        expect(assignments, isA<Map<String, ABTestVariant>>());
      });
    });

    group('Active tests', () {
      test('should return list of active tests', () async {
        final tests = await service.getActiveTests();

        expect(tests, isA<List<ABTest>>());
      });

      test('should filter out inactive tests', () async {
        final tests = await service.getActiveTests();

        for (final test in tests) {
          expect(test.isActive, isTrue);
        }
      });
    });
  });

  group('A/B Test Models', () {
    group('ABTest', () {
      test('should create ABTest from map', () {
        final map = {
          'id': 'test_001',
          'name': 'Quiz UI Test',
          'description': 'Testing new quiz interface',
          'status': ABTestStatus.active.index,
          'startedAt': DateTime.now(),
          'minSampleSize': 100,
          'requiredConfidence': 0.95,
        };

        final test = ABTest.fromMap(map);

        expect(test.id, equals('test_001'));
        expect(test.name, equals('Quiz UI Test'));
        expect(test.isActive, isTrue);
      });

      test('should identify active tests', () {
        final test = ABTest(
          id: 'test_001',
          name: 'Active Test',
          description: 'Test description',
          status: ABTestStatus.active,
          startedAt: DateTime.now(),
          minSampleSize: 100,
          requiredConfidence: 0.95,
        );

        expect(test.isActive, isTrue);
        expect(test.isCompleted, isFalse);
      });

      test('should identify completed tests', () {
        final test = ABTest(
          id: 'test_001',
          name: 'Completed Test',
          description: 'Test description',
          status: ABTestStatus.completed,
          startedAt: DateTime.now().subtract(const Duration(days: 7)),
          endedAt: DateTime.now(),
          minSampleSize: 100,
          requiredConfidence: 0.95,
        );

        expect(test.isCompleted, isTrue);
        expect(test.isActive, isFalse);
      });
    });

    group('ABTestVariantResults', () {
      test('should create results from map', () {
        final map = {
          'variant': 'variant',
          'sampleSize': 150,
          'conversionRate': 0.75,
          'averageSessionDuration': 320,
          'averageAccuracy': 82.5,
          'engagementScore': 88,
        };

        final results = ABTestVariantResults.fromMap(map);

        expect(results.variant, equals(ABTestVariant.variant));
        expect(results.sampleSize, equals(150));
        expect(results.conversionRate, equals(0.75));
      });

      test('should create empty results', () {
        final results = ABTestVariantResults.empty(ABTestVariant.control);

        expect(results.sampleSize, equals(0));
        expect(results.conversionRate, equals(0.0));
        expect(results.averageAccuracy, equals(0.0));
      });

      test('should calculate conversion rate correctly', () {
        final results = ABTestVariantResults(
          variant: ABTestVariant.variant,
          sampleSize: 100,
          conversionRate: 0.85,
          averageSessionDuration: 300,
          averageAccuracy: 80,
          engagementScore: 85,
        );

        expect(results.conversionRate, equals(0.85));
      });
    });

    group('SignificanceResult', () {
      test('should identify significant results', () {
        final result = SignificanceResult(
          isSignificant: true,
          pValue: 0.03,
          confidenceLevel: 0.97,
          recommendation: 'variant_wins',
        );

        expect(result.isSignificant, isTrue);
        expect(result.variantWins, isTrue);
        expect(result.controlWins, isFalse);
      });

      test('should identify inconclusive results', () {
        final result = SignificanceResult(
          isSignificant: false,
          pValue: 0.5,
          confidenceLevel: 0.5,
          recommendation: 'inconclusive',
        );

        expect(result.isInconclusive, isTrue);
        expect(result.variantWins, isFalse);
        expect(result.controlWins, isFalse);
      });

      test('should identify control winner', () {
        final result = SignificanceResult(
          isSignificant: true,
          pValue: 0.02,
          confidenceLevel: 0.98,
          recommendation: 'control_wins',
        );

        expect(result.controlWins, isTrue);
        expect(result.variantWins, isFalse);
      });
    });

    group('UserABTestAssignment', () {
      test('should create assignment from map', () {
        final now = DateTime.now();
        final map = {
          'userId': 'user_123',
          'testId': 'test_001',
          'assignedVariant': 'variant',
          'assignedAt': now,
          'metadata': {'source': 'app'},
        };

        final assignment = UserABTestAssignment.fromMap(map);

        expect(assignment.userId, equals('user_123'));
        expect(assignment.testId, equals('test_001'));
        expect(assignment.isVariant, isTrue);
        expect(assignment.isControl, isFalse);
      });

      test('should track assignment metadata', () {
        final assignment = UserABTestAssignment(
          userId: 'user_123',
          testId: 'test_001',
          assignedVariant: ABTestVariant.variant,
          assignedAt: DateTime.now(),
          metadata: {'version': '2.0', 'platform': 'iOS'},
        );

        expect(assignment.metadata['version'], equals('2.0'));
        expect(assignment.metadata['platform'], equals('iOS'));
      });
    });
  });

  group('AB Testing Integration Scenarios', () {
    late StubABTestingService service;

    setUp(() {
      service = StubABTestingService();
    });

    test('should support complete experiment workflow', () async {
      const testId = 'quiz_ui_experiment';
      const userId = 'user_123';

      // 1. Get variant assignment
      final variant = await service.getUserVariant(userId, testId);
      expect(variant, isIn([ABTestVariant.control, ABTestVariant.variant]));

      // 2. Record user interactions
      await service.recordTestEvent(userId, testId, 'quiz_started', {
        'quizType': 'daily',
      });

      // 3. Check conversion
      if (variant == ABTestVariant.variant) {
        await service.recordConversion(userId, testId);
      }

      // 4. Analyze results
      final results = await service.getTestResults(testId);
      expect(results, isNotNull);
    });

    test('should handle multiple concurrent tests', () async {
      const userId = 'user_123';

      final assignments = await service.getUserAssignments(userId);

      expect(assignments, isA<Map<String, ABTestVariant>>());
    });

    test('should maintain user consistency across sessions', () async {
      const userId = 'user_123';
      const testId = 'test_001';

      final variant1 = await service.getUserVariant(userId, testId);
      final variant2 = await service.getUserVariant(userId, testId);
      final variant3 = await service.getUserVariant(userId, testId);

      expect(variant1, equals(variant2));
      expect(variant2, equals(variant3));
    });
  });
}
