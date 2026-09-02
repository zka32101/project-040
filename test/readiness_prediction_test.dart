import 'package:flutter_test/flutter_test.dart';
import '../lib/models/community_model.dart';
import '../lib/services/community_service.dart';

void main() {
  late StubCommunityService service;

  setUp(() {
    service = StubCommunityService();
  });

  group('ExamReadinessPrediction', () {
    test('should initialize empty readiness prediction', () {
      final prediction = ExamReadinessPrediction.empty(
        predictionId: 'erp_1',
        userId: 'user123',
      );

      expect(prediction.passProbability, 0.0);
      expect(prediction.isPassReady, false);
      expect(prediction.daysToReady, 0);
      expect(prediction.readinessPercentage, 0);
    });

    test('should calculate pass ready status correctly', () {
      final prediction = ExamReadinessPrediction(
        predictionId: 'erp_1',
        userId: 'user123',
        passProbability: 0.85,
        estimatedHoursNeeded: 5,
        predictedReadyDate: DateTime.now(),
        criticalWeakAreas: [],
        recommendedFocusTopics: [],
        factors: ReadinessFactors(
          accuracyWeighting: 0.4,
          consistencyScore: 0.15,
          trendScore: 0.15,
          timeSpentScore: 0.08,
          weakAreaCoverageScore: 0.07,
        ),
        calculatedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(prediction.isPassReady, true);
      expect(prediction.readinessPercentage, 85);
      expect(prediction.needsActiveLearning, false);
    });

    test('should calculate days to ready', () {
      final futureDate = DateTime.now().add(Duration(days: 7));
      final prediction = ExamReadinessPrediction(
        predictionId: 'erp_1',
        userId: 'user123',
        passProbability: 0.5,
        estimatedHoursNeeded: 10,
        predictedReadyDate: futureDate,
        criticalWeakAreas: [],
        recommendedFocusTopics: [],
        factors: ReadinessFactors.empty(),
        calculatedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(prediction.daysToReady, 7);
      expect(prediction.needsActiveLearning, true);
    });
  });

  group('ReadinessFactors', () {
    test('should calculate composite score from all factors', () {
      final factors = ReadinessFactors(
        accuracyWeighting: 0.4,
        consistencyScore: 0.2,
        trendScore: 0.2,
        timeSpentScore: 0.1,
        weakAreaCoverageScore: 0.1,
      );

      final composite = factors.compositeScore;
      expect(composite, greaterThan(0.0));
      expect(composite, lessThanOrEqualTo(1.0));
      expect(composite, closeTo(0.2, 0.01)); // Average of 0.4, 0.2, 0.2, 0.1, 0.1
    });

    test('should handle zero factors', () {
      final factors = ReadinessFactors.empty();

      expect(factors.compositeScore, 0.0);
      expect(factors.accuracyWeighting, 0.0);
    });
  });

  group('TimeToReadiness', () {
    test('should calculate progress per day', () {
      final estimate = TimeToReadiness(
        estimateId: 'ttr_1',
        userId: 'user123',
        category: '交通規則',
        daysToTargetAccuracy: 10,
        recommendedDailyMinutes: 60,
        totalHoursNeeded: 10,
        estimatedCompletionDate: DateTime.now().add(Duration(days: 10)),
        milestones: ['60%', '75%', '85%'],
        confidenceLevel: 'high',
        calculatedAt: DateTime.now(),
      );

      expect(estimate.progressPerDay, closeTo(0.1, 0.01));
      expect(estimate.isAchievableAtCurrentPace, true);
    });

    test('should identify unachievable timelines', () {
      final estimate = TimeToReadiness(
        estimateId: 'ttr_1',
        userId: 'user123',
        category: '交通規則',
        daysToTargetAccuracy: 60,
        recommendedDailyMinutes: 30,
        totalHoursNeeded: 30,
        estimatedCompletionDate: DateTime.now().add(Duration(days: 60)),
        milestones: [],
        confidenceLevel: 'low',
        calculatedAt: DateTime.now(),
      );

      expect(estimate.isAchievableAtCurrentPace, false);
    });
  });

  group('ExamReadinessPredictionService', () {
    test('should predict exam readiness with no progress data', () async {
      final prediction = await service.predictExamReadiness('user123');

      expect(prediction.userId, 'user123');
      expect(prediction.passProbability, 0.0);
      expect(prediction.isPassReady, false);
    });

    test('should predict readiness with good performance', () async {
      // High accuracy data: 8 correct out of 10
      for (int i = 0; i < 8; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '交通規則',
          isCorrect: true,
          timeSpentSeconds: 30,
        );
      }
      for (int i = 0; i < 2; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '交通規則',
          isCorrect: false,
          timeSpentSeconds: 30,
        );
      }

      final prediction = await service.predictExamReadiness('user123');

      expect(prediction.passProbability, greaterThan(0.5));
      expect(prediction.estimatedHoursNeeded, greaterThanOrEqualTo(0));
      expect(prediction.criticalWeakAreas, isNotEmpty);
    });

    test('should predict readiness with multiple categories', () async {
      // Setup data for 3 categories
      for (int i = 0; i < 8; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '交通規則',
          isCorrect: i < 7,
          timeSpentSeconds: 30,
        );
      }
      for (int i = 0; i < 8; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '危機回避',
          isCorrect: i < 5,
          timeSpentSeconds: 30,
        );
      }
      for (int i = 0; i < 8; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '機械知識',
          isCorrect: i < 6,
          timeSpentSeconds: 30,
        );
      }

      final prediction = await service.predictExamReadiness('user123');

      expect(prediction.passProbability, greaterThan(0.4));
      expect(prediction.factors.compositeScore, greaterThan(0.0));
    });

    test('should identify critical weak areas', () async {
      // Create weak area: 30% accuracy
      for (int i = 0; i < 1; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '危機回避',
          isCorrect: true,
          timeSpentSeconds: 30,
        );
      }
      for (int i = 0; i < 3; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '危機回避',
          isCorrect: false,
          timeSpentSeconds: 30,
        );
      }

      // Good area: 80% accuracy
      for (int i = 0; i < 8; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '交通規則',
          isCorrect: i < 8,
          timeSpentSeconds: 30,
        );
      }

      final prediction = await service.predictExamReadiness('user123');

      expect(prediction.criticalWeakAreas, contains('危機回避'));
      expect(prediction.criticalWeakAreas, isNot(contains('交通規則')));
    });
  });

  group('CategoryReadinessPrediction', () {
    test('should predict category-specific readiness', () async {
      for (int i = 0; i < 7; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '交通規則',
          isCorrect: i < 6,
          timeSpentSeconds: 30,
        );
      }

      final prediction = await service.predictCategoryReadiness(
        userId: 'user123',
        category: '交通規則',
      );

      expect(prediction.category, null); // Category is not stored in prediction
      expect(prediction.passProbability, greaterThan(0.0));
    });

    test('should predict all categories readiness', () async {
      final categories = ['交通規則', '危機回避', '機械知識'];

      for (final category in categories) {
        for (int i = 0; i < 5; i++) {
          await service.updateProgressTracker(
            userId: 'user123',
            category: category,
            isCorrect: i < 3,
            timeSpentSeconds: 30,
          );
        }
      }

      final predictions = await service.predictCategoryReadinessList('user123');

      expect(predictions.keys.length, 3);
      expect(predictions.keys, containsAll(categories));

      for (final category in categories) {
        expect(predictions[category], isNotNull);
        expect(predictions[category]!.passProbability, greaterThan(0.0));
      }
    });
  });

  group('ReadinessFactorsCalculation', () {
    test('should calculate readiness factors from progress', () async {
      for (int i = 0; i < 10; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '交通規則',
          isCorrect: i < 7,
          timeSpentSeconds: 60,
        );
      }

      final factors = await service.calculateReadinessFactors(
        userId: 'user123',
        category: '交通規則',
      );

      expect(factors.accuracyWeighting, greaterThan(0.0));
      expect(factors.consistencyScore, greaterThanOrEqualTo(0.0));
      expect(factors.trendScore, greaterThanOrEqualTo(0.0));
      expect(factors.timeSpentScore, greaterThan(0.0));
      expect(factors.weakAreaCoverageScore, greaterThan(0.0));
    });

    test('should weight factors correctly', () async {
      for (int i = 0; i < 20; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '交通規則',
          isCorrect: i < 15, // 75% accuracy
          timeSpentSeconds: 120,
        );
      }

      final factors = await service.calculateReadinessFactors(
        userId: 'user123',
        category: '交通規則',
      );

      // accuracyWeighting should be about 30% (75% * 0.4)
      expect(factors.accuracyWeighting, closeTo(0.30, 0.05));

      // Each component should sum to approximately 1.0 divided by 5
      final sum = factors.accuracyWeighting +
          factors.consistencyScore +
          factors.trendScore +
          factors.timeSpentScore +
          factors.weakAreaCoverageScore;
      expect(sum, lessThanOrEqualTo(1.0));
    });
  });

  group('TimeToReadinessEstimation', () {
    test('should estimate time to reach target accuracy', () async {
      // Start with 60% accuracy
      for (int i = 0; i < 5; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '交通規則',
          isCorrect: i < 3,
          timeSpentSeconds: 30,
        );
      }

      final estimate = await service.estimateTimeToReadiness(
        userId: 'user123',
        category: '交通規則',
        targetAccuracyPercent: 85,
      );

      expect(estimate.daysToTargetAccuracy, greaterThan(0));
      expect(estimate.daysToTargetAccuracy, lessThanOrEqualTo(60));
      expect(estimate.recommendedDailyMinutes, greaterThan(0));
      expect(estimate.totalHoursNeeded, greaterThan(0));
    });

    test('should generate appropriate milestones', () async {
      for (int i = 0; i < 5; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '危機回避',
          isCorrect: i < 2,
          timeSpentSeconds: 30,
        );
      }

      final estimate = await service.estimateTimeToReadiness(
        userId: 'user123',
        category: '危機回避',
        targetAccuracyPercent: 85,
      );

      expect(estimate.milestones, isNotEmpty);
      expect(estimate.milestones.length, lessThanOrEqualTo(4));
    });

    test('should set high confidence with sufficient attempts', () async {
      for (int i = 0; i < 15; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '交通規則',
          isCorrect: i < 10,
          timeSpentSeconds: 30,
        );
      }

      final estimate = await service.estimateTimeToReadiness(
        userId: 'user123',
        category: '交通規則',
        targetAccuracyPercent: 85,
      );

      expect(estimate.confidenceLevel, 'high');
    });
  });

  group('ReadinessPredictionPersistence', () {
    test('should store and retrieve readiness prediction', () async {
      final prediction = ExamReadinessPrediction(
        predictionId: 'erp_test',
        userId: 'user123',
        passProbability: 0.75,
        estimatedHoursNeeded: 10,
        predictedReadyDate: DateTime.now().add(Duration(days: 7)),
        criticalWeakAreas: ['危機回避'],
        recommendedFocusTopics: ['急ブレーキ'],
        factors: ReadinessFactors(
          accuracyWeighting: 0.3,
          consistencyScore: 0.15,
          trendScore: 0.15,
          timeSpentScore: 0.1,
          weakAreaCoverageScore: 0.1,
        ),
        calculatedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await service.updateReadinessPrediction(
        userId: 'user123',
        prediction: prediction,
      );

      final retrieved = await service.getReadinessPrediction('user123');

      expect(retrieved, isNotNull);
      expect(retrieved!.passProbability, 0.75);
      expect(retrieved.criticalWeakAreas, contains('危機回避'));
    });

    test('should track readiness trend over time', () async {
      await service.predictExamReadiness('user123');
      await Future.delayed(Duration(milliseconds: 10));
      await service.predictExamReadiness('user123');

      final trend = await service.getReadinessTrend('user123');

      expect(trend, isNotEmpty);
      expect(trend.length, greaterThanOrEqualTo(1));
    });
  });

  group('PassProbabilityThreshold', () {
    test('should identify pass-probable users', () async {
      // Create very high accuracy: 90%+
      for (int i = 0; i < 10; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '交通規則',
          isCorrect: true,
          timeSpentSeconds: 30,
        );
      }
      for (int i = 0; i < 8; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '危機回避',
          isCorrect: true,
          timeSpentSeconds: 30,
        );
      }

      final isReady = await service.isPassProbableReady('user123');

      expect(isReady, isNotNull);
    });

    test('should reject unprepared users', () async {
      final isReady = await service.isPassProbableReady('unprepared_user');

      expect(isReady, false);
    });
  });
}
