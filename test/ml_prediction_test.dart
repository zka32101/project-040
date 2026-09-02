import 'package:flutter_test/flutter_test.dart';
import 'package:your_app_name/services/ml_predictor_service.dart';

void main() {
  group('MLPredictorService Tests', () {
    late MLPredictorService service;

    setUp(() {
      service = MLPredictorService();
    });

    tearDown(() {
      service.clearAllCache();
    });

    test('predictLearningEffect: Generates valid prediction', () async {
      final prediction = await service.predictLearningEffect(
        studentId: 'student_001',
        currentScore: 75,
        questionsAttempted: 50,
        correctAnswers: 38,
        totalQuestions: 200,
        enrollmentDate: DateTime.now().subtract(const Duration(days: 30)),
        targetDate: DateTime.now().add(const Duration(days: 60)),
        categoryScores: {
          'math': 80,
          'science': 70,
          'english': 65,
        },
      );

      expect(prediction, isNotNull);
      expect(prediction.studentId, 'student_001');
      expect(prediction.passLikelihood, greaterThanOrEqualTo(0));
      expect(prediction.passLikelihood, lessThanOrEqualTo(100));
      expect(prediction.estimatedDaysToCompletion, greaterThanOrEqualTo(0));
      expect(prediction.estimatedHoursToCompletion, greaterThanOrEqualTo(0));
      expect(prediction.riskFactors, isA<List>());
      expect(prediction.successFactors, isA<List>());
      expect(prediction.confidenceScore, greaterThanOrEqualTo(0));
      expect(prediction.confidenceScore, lessThanOrEqualTo(100));
    });

    test('predictLearningEffect: High accuracy increases pass likelihood', () async {
      final highAccuracyPrediction = await service.predictLearningEffect(
        studentId: 'student_high',
        currentScore: 90,
        questionsAttempted: 100,
        correctAnswers: 90,
        totalQuestions: 200,
        enrollmentDate: DateTime.now().subtract(const Duration(days: 60)),
        targetDate: null,
        categoryScores: {
          'cat1': 90,
          'cat2': 85,
          'cat3': 95,
        },
      );

      final lowAccuracyPrediction = await service.predictLearningEffect(
        studentId: 'student_low',
        currentScore: 40,
        questionsAttempted: 50,
        correctAnswers: 20,
        totalQuestions: 200,
        enrollmentDate: DateTime.now().subtract(const Duration(days: 30)),
        targetDate: null,
        categoryScores: {
          'cat1': 40,
          'cat2': 35,
          'cat3': 45,
        },
      );

      expect(
        highAccuracyPrediction.passLikelihood,
        greaterThan(lowAccuracyPrediction.passLikelihood),
      );
    });

    test('predictLearningEffect: Completion status varies appropriately', () async {
      final fastCompletion = await service.predictLearningEffect(
        studentId: 'student_fast',
        currentScore: 85,
        questionsAttempted: 150,
        correctAnswers: 128,
        totalQuestions: 200,
        enrollmentDate: DateTime.now().subtract(const Duration(days: 10)),
        targetDate: null,
        categoryScores: {'cat1': 85},
      );

      final slowCompletion = await service.predictLearningEffect(
        studentId: 'student_slow',
        currentScore: 50,
        questionsAttempted: 30,
        correctAnswers: 15,
        totalQuestions: 200,
        enrollmentDate: DateTime.now().subtract(const Duration(days: 90)),
        targetDate: null,
        categoryScores: {'cat1': 50},
      );

      expect(
        fastCompletion.completionStatus,
        isIn(['fast', 'on_track']),
      );
      expect(
        slowCompletion.completionStatus,
        isIn(['slow', 'at_risk']),
      );
    });

    test('detectDropoutRisk: Identifies high-risk students', () async {
      final riskDetection = await service.detectDropoutRisk(
        studentId: 'student_risk',
        currentScore: 35,
        daysSinceLastActivity: 14,
        missedDays: 8,
        categoryScores: {
          'cat1': 30,
          'cat2': 25,
          'cat3': 40,
        },
        loginStreak: 0,
        previousUserFeedback: ['struggling', 'busy'],
      );

      expect(riskDetection, isNotNull);
      expect(riskDetection.riskScore, greaterThan(0));
      expect(riskDetection.riskLevel, isIn(['low', 'medium', 'high', 'critical']));
      expect(riskDetection.riskIndicators, isNotEmpty);
      expect(riskDetection.interventionSuggestions, isNotEmpty);
    });

    test('detectDropoutRisk: Low-risk students score accordingly', () async {
      final riskDetection = await service.detectDropoutRisk(
        studentId: 'student_safe',
        currentScore: 85,
        daysSinceLastActivity: 1,
        missedDays: 0,
        categoryScores: {
          'cat1': 85,
          'cat2': 80,
          'cat3': 90,
        },
        loginStreak: 10,
        previousUserFeedback: ['motivated'],
      );

      expect(riskDetection.riskScore, lessThan(20));
      expect(riskDetection.riskLevel, 'low');
    });

    test('detectDropoutRisk: Risk level classification is correct', () async {
      // Critical risk
      final criticalRisk = await service.detectDropoutRisk(
        studentId: 'student_critical',
        currentScore: 20,
        daysSinceLastActivity: 30,
        missedDays: 20,
        categoryScores: {'cat1': 15},
        loginStreak: 0,
        previousUserFeedback: [],
      );
      expect(criticalRisk.riskLevel, 'critical');

      // Medium risk
      final mediumRisk = await service.detectDropoutRisk(
        studentId: 'student_medium',
        currentScore: 55,
        daysSinceLastActivity: 5,
        missedDays: 2,
        categoryScores: {'cat1': 55},
        loginStreak: 2,
        previousUserFeedback: [],
      );
      expect(mediumRisk.riskLevel, 'medium');
    });

    test('Cache functionality: Predictions are cached', () async {
      final prediction1 = await service.predictLearningEffect(
        studentId: 'student_cache',
        currentScore: 70,
        questionsAttempted: 50,
        correctAnswers: 35,
        totalQuestions: 200,
        enrollmentDate: DateTime.now().subtract(const Duration(days: 30)),
        targetDate: null,
        categoryScores: {'cat1': 70},
      );

      // Small delay to ensure timestamp would differ if regenerated
      await Future.delayed(const Duration(milliseconds: 50));

      final prediction2 = await service.predictLearningEffect(
        studentId: 'student_cache',
        currentScore: 70,
        questionsAttempted: 50,
        correctAnswers: 35,
        totalQuestions: 200,
        enrollmentDate: DateTime.now().subtract(const Duration(days: 30)),
        targetDate: null,
        categoryScores: {'cat1': 70},
      );

      // Should be from cache (same timestamp)
      expect(prediction1.generatedAt, equals(prediction2.generatedAt));
    });

    test('Confidence score increases with more questions attempted', () async {
      final lowConfidence = await service.predictLearningEffect(
        studentId: 'student_conf_low',
        currentScore: 60,
        questionsAttempted: 20, // Low sample size
        correctAnswers: 12,
        totalQuestions: 200,
        enrollmentDate: DateTime.now().subtract(const Duration(days: 7)),
        targetDate: null,
        categoryScores: {'cat1': 60},
      );

      final highConfidence = await service.predictLearningEffect(
        studentId: 'student_conf_high',
        currentScore: 60,
        questionsAttempted: 500, // High sample size
        correctAnswers: 300,
        totalQuestions: 200,
        enrollmentDate: DateTime.now().subtract(const Duration(days: 90)),
        targetDate: null,
        categoryScores: {'cat1': 60},
      );

      expect(
        highConfidence.confidenceScore,
        greaterThan(lowConfidence.confidenceScore),
      );
    });
  });
}
