import 'package:flutter_test/flutter_test.dart';
import '../lib/models/community_model.dart';
import '../lib/services/community_service.dart';

void main() {
  late StubCommunityService service;

  setUp(() {
    service = StubCommunityService();
  });

  group('ProgressTracker', () {
    test('should initialize empty progress tracker', () async {
      final tracker = ProgressTracker.empty(
        trackerId: 'pt_1',
        userId: 'user123',
        category: '交通規則',
      );

      expect(tracker.correctCount, 0);
      expect(tracker.totalAttempts, 0);
      expect(tracker.accuracyPercentage, 0);
      expect(tracker.recommendedStudyMinutes, 75);
    });

    test('should update progress after correct answer', () async {
      await service.updateProgressTracker(
        userId: 'user123',
        category: '交通規則',
        isCorrect: true,
        timeSpentSeconds: 30,
      );

      final tracker = await service.getProgressTracker(
        userId: 'user123',
        category: '交通規則',
      );

      expect(tracker, isNotNull);
      expect(tracker!.correctCount, 1);
      expect(tracker.totalAttempts, 1);
      expect(tracker.accuracyPercentage, 100);
      expect(tracker.lastFiveScores, [100]);
    });

    test('should track consecutive correct answers', () async {
      for (int i = 0; i < 5; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '交通規則',
          isCorrect: true,
          timeSpentSeconds: 30,
        );
      }

      final tracker = await service.getProgressTracker(
        userId: 'user123',
        category: '交通規則',
      );

      expect(tracker!.consecutiveCorrect, 5);
      expect(tracker.longestStreak, 5);
      expect(tracker.accuracyPercentage, 100);
    });

    test('should calculate accuracy correctly with mixed results', () async {
      // 3正解, 2不正解
      for (int i = 0; i < 3; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '危機回避',
          isCorrect: true,
          timeSpentSeconds: 30,
        );
      }
      for (int i = 0; i < 2; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '危機回避',
          isCorrect: false,
          timeSpentSeconds: 30,
        );
      }

      final tracker = await service.getProgressTracker(
        userId: 'user123',
        category: '危機回避',
      );

      expect(tracker!.totalAttempts, 5);
      expect(tracker.correctCount, 3);
      expect(tracker.accuracyPercentage, 60);
      expect(tracker.consecutiveCorrect, 0);
    });

    test('should track time spent on questions', () async {
      await service.updateProgressTracker(
        userId: 'user123',
        category: '機械知識',
        isCorrect: true,
        timeSpentSeconds: 120, // 2 minutes
      );
      await service.updateProgressTracker(
        userId: 'user123',
        category: '機械知識',
        isCorrect: true,
        timeSpentSeconds: 180, // 3 minutes
      );

      final tracker = await service.getProgressTracker(
        userId: 'user123',
        category: '機械知識',
      );

      expect(tracker!.minutesSpent, 5); // 2 + 3
      expect(tracker.averageTimePerQuestion, 150); // 300 / 2 seconds
    });

    test('should recommend study time based on accuracy', () async {
      // 58% accuracy (gap of 27 from target 85%)
      for (int i = 0; i < 5; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '危機回避',
          isCorrect: i < 3,
          timeSpentSeconds: 30,
        );
      }

      final tracker = await service.getProgressTracker(
        userId: 'user123',
        category: '危機回避',
      );

      expect(tracker!.accuracyPercentage, 60);
      expect(tracker.recommendedStudyMinutes, greaterThan(0));
      expect(tracker.recommendedStudyMinutes, lessThanOrEqualTo(120));
    });

    test('should maintain last five scores', () async {
      final scores = [70, 80, 60, 90, 75, 85];
      for (final score in scores) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '交通規則',
          isCorrect: score >= 75,
          timeSpentSeconds: 30,
        );
      }

      final tracker = await service.getProgressTracker(
        userId: 'user123',
        category: '交通規則',
      );

      expect(tracker!.lastFiveScores.length, 5);
      expect(tracker.lastFiveScores, [80, 60, 90, 75, 85]);
    });

    test('should get all user progress trackers', () async {
      await service.updateProgressTracker(
        userId: 'user123',
        category: '交通規則',
        isCorrect: true,
        timeSpentSeconds: 30,
      );
      await service.updateProgressTracker(
        userId: 'user123',
        category: '危機回避',
        isCorrect: false,
        timeSpentSeconds: 30,
      );
      await service.updateProgressTracker(
        userId: 'user123',
        category: '機械知識',
        isCorrect: true,
        timeSpentSeconds: 30,
      );

      final trackers = await service.getUserProgressTrackers('user123');

      expect(trackers.length, 3);
      expect(
        trackers.map((t) => t.category),
        containsAll(['交通規則', '危機回避', '機械知識']),
      );
    });

    test('should get progress trackers by categories', () async {
      await service.updateProgressTracker(
        userId: 'user123',
        category: '交通規則',
        isCorrect: true,
        timeSpentSeconds: 30,
      );
      await service.updateProgressTracker(
        userId: 'user123',
        category: '危機回避',
        isCorrect: false,
        timeSpentSeconds: 30,
      );

      final trackers = await service.getProgressTrackersByCategories(
        userId: 'user123',
        categories: ['交通規則', '危機回避'],
      );

      expect(trackers.keys, {'交通規則', '危機回避'});
      expect(trackers['交通規則']!.accuracyPercentage, 100);
      expect(trackers['危機回避']!.accuracyPercentage, 0);
    });
  });

  group('WeakAreaDetection', () {
    test('should not detect weak areas with insufficient attempts', () async {
      await service.updateProgressTracker(
        userId: 'user123',
        category: '危機回避',
        isCorrect: false,
        timeSpentSeconds: 30,
      );

      final weakAreas = await service.detectWeakAreas(
        userId: 'user123',
        minAttempts: 5,
      );

      expect(weakAreas, isEmpty);
    });

    test('should detect weak area with low accuracy and enough attempts',
        () async {
      // Create 5 attempts with 40% accuracy (2 correct, 3 wrong)
      for (int i = 0; i < 2; i++) {
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

      final weakAreas = await service.detectWeakAreas(
        userId: 'user123',
        accuracyThreshold: 0.7,
        minAttempts: 5,
      );

      expect(weakAreas, isNotEmpty);
      expect(weakAreas[0].category, '危機回避');
      expect(weakAreas[0].currentAccuracy, 40);
      expect(weakAreas[0].targetAccuracy, 85);
      expect(weakAreas[0].priority, '最優先');
    });

    test('should categorize weak areas by priority', () async {
      // Very weak area: 40% accuracy
      for (int i = 0; i < 2; i++) {
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

      // Moderately weak: 60% accuracy
      for (int i = 0; i < 3; i++) {
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

      final weakAreas = await service.detectWeakAreas(
        userId: 'user123',
        accuracyThreshold: 0.7,
        minAttempts: 5,
      );

      expect(weakAreas, isNotEmpty);
      final critical =
          weakAreas.firstWhere((wa) => wa.category == '危機回避');
      final moderate = weakAreas.firstWhere(
        (wa) => wa.category == '交通規則',
        orElse: () => throw Exception('Not found'),
      );

      expect(critical.priority, '最優先');
      expect(moderate.priority, '重要');
    });

    test('should get weak area by category', () async {
      for (int i = 0; i < 3; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '危機回避',
          isCorrect: false,
          timeSpentSeconds: 30,
        );
      }
      for (int i = 0; i < 2; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '危機回避',
          isCorrect: true,
          timeSpentSeconds: 30,
        );
      }

      await service.detectWeakAreas(
        userId: 'user123',
        minAttempts: 5,
      );

      final weakArea = await service.getWeakArea(
        userId: 'user123',
        category: '危機回避',
      );

      expect(weakArea, isNotNull);
      expect(weakArea!.category, '危機回避');
      expect(weakArea.isResolved, false);
    });

    test('should resolve weak areas', () async {
      for (int i = 0; i < 3; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '危機回避',
          isCorrect: false,
          timeSpentSeconds: 30,
        );
      }
      for (int i = 0; i < 2; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '危機回避',
          isCorrect: true,
          timeSpentSeconds: 30,
        );
      }

      final weakAreas = await service.detectWeakAreas(
        userId: 'user123',
        minAttempts: 5,
      );

      expect(weakAreas, isNotEmpty);
      final weakAreaId = weakAreas[0].weakAreaId;

      await service.resolveWeakArea(
        userId: 'user123',
        weakAreaId: weakAreaId,
      );

      final unresolved = await service.getUserWeakAreas('user123');
      expect(
        unresolved.any((wa) => wa.weakAreaId == weakAreaId),
        false,
      );
    });

    test('should get weak areas by priority', () async {
      // Create multiple weak areas with different severity levels
      final categories = ['危機回避', '交通規則', '機械知識'];
      int correctCount = 4;

      for (final category in categories) {
        for (int i = 0; i < correctCount; i++) {
          await service.updateProgressTracker(
            userId: 'user123',
            category: category,
            isCorrect: i == 0,
            timeSpentSeconds: 30,
          );
        }
        correctCount--;
      }

      final weakAreas = await service.getWeakAreasByPriority(
        userId: 'user123',
        limit: 5,
      );

      expect(weakAreas, isNotEmpty);
      // Should be sorted by priority score (descending)
      for (int i = 0; i < weakAreas.length - 1; i++) {
        expect(
          weakAreas[i].priorityScore,
          greaterThanOrEqualTo(weakAreas[i + 1].priorityScore),
        );
      }
    });

    test('should generate suggested topics for weak areas', () async {
      for (int i = 0; i < 2; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '危機回避',
          isCorrect: i == 0,
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

      final weakAreas = await service.detectWeakAreas(
        userId: 'user123',
        minAttempts: 5,
      );

      expect(weakAreas, isNotEmpty);
      final topics = await service.getRecommendedTopicsForWeakArea(
        weakAreas[0].weakAreaId,
      );

      expect(topics, isNotEmpty);
      expect(topics.length, lessThanOrEqualTo(3));
    });
  });

  group('ReviewSchedule', () {
    test('should create spaced review schedule', () async {
      const questionIds = ['q1', 'q2', 'q3', 'q4', 'q5'];
      final schedules = await service.createReviewSchedule(
        userId: 'user123',
        questionIds: questionIds,
        baseTopic: '交通規則',
      );

      expect(schedules.length, 3);
      expect(schedules.map((s) => s.interval), [
        '明日',
        '3日後',
        '1週間後',
      ]);

      // Check spacing
      expect(schedules[0].scheduledFor.day, 31); // tomorrow (assuming today is 30)
      expect(schedules[1].scheduledFor.day, 2); // 3 days later
      expect(schedules[2].scheduledFor.day, 6); // 1 week later
    });

    test('should track review completion', () async {
      const questionIds = ['q1', 'q2', 'q3'];
      final schedules = await service.createReviewSchedule(
        userId: 'user123',
        questionIds: questionIds,
        baseTopic: '交通規則',
      );

      expect(schedules[0].isCompleted, false);

      await service.completeReviewSchedule(
        reviewId: schedules[0].reviewId,
      );

      final reviews = await service.getUserReviewSchedules('user123');
      final completed = reviews.firstWhere((r) => r.reviewId == schedules[0].reviewId);

      expect(completed.isCompleted, true);
      expect(completed.completedAt, isNotNull);
    });

    test('should get today review schedule', () async {
      const questionIds = ['q1', 'q2'];
      await service.createReviewSchedule(
        userId: 'user123',
        questionIds: questionIds,
        baseTopic: '交通規則',
      );

      final todayReviews = await service.getTodayReviewSchedule('user123');

      expect(todayReviews, isEmpty); // No reviews scheduled for today
    });

    test('should identify overdue reviews', () async {
      const questionIds = ['q1', 'q2', 'q3'];
      final schedules = await service.createReviewSchedule(
        userId: 'user123',
        questionIds: questionIds,
        baseTopic: '交通規則',
      );

      // The first schedule is for tomorrow, so not overdue yet
      final overdueReviews = await service.getOverdueReviewSchedules('user123');

      expect(overdueReviews, isEmpty);
    });

    test('should estimate study time for reviews', () async {
      const questionIds = ['q1', 'q2', 'q3', 'q4', 'q5'];
      final schedules = await service.createReviewSchedule(
        userId: 'user123',
        questionIds: questionIds,
        baseTopic: '交通規則',
      );

      for (final schedule in schedules) {
        expect(schedule.estimatedMinutes, greaterThan(0));
        expect(schedule.estimatedMinutes, lessThanOrEqualTo(20));
      }
    });

    test('should get user review schedules', () async {
      const questionIds1 = ['q1', 'q2'];
      const questionIds2 = ['q3', 'q4'];

      await service.createReviewSchedule(
        userId: 'user123',
        questionIds: questionIds1,
        baseTopic: '交通規則',
      );
      await service.createReviewSchedule(
        userId: 'user123',
        questionIds: questionIds2,
        baseTopic: '危機回避',
      );

      final schedules = await service.getUserReviewSchedules('user123');

      expect(schedules.length, 6); // 3 schedules × 2 review sets
    });

    test('should get review schedule for specific date', () async {
      const questionIds = ['q1', 'q2'];
      final schedules = await service.createReviewSchedule(
        userId: 'user123',
        questionIds: questionIds,
        baseTopic: '交通規則',
      );

      final tomorrow = DateTime.now().add(Duration(days: 1));
      final dateReviews = await service.getReviewScheduleForDate(
        userId: 'user123',
        date: tomorrow,
      );

      expect(dateReviews, isNotEmpty);
      expect(
        dateReviews.every((r) => r.interval == '明日'),
        true,
      );
    });
  });

  group('AdaptiveLearning', () {
    test('should predict readiness probability', () async {
      // Create good performance data
      for (int i = 0; i < 5; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '交通規則',
          isCorrect: i < 4, // 80% accuracy
          timeSpentSeconds: 30,
        );
      }

      final readiness = await service.predictReadinessProbability('user123');

      expect(readiness, greaterThan(0.5));
      expect(readiness, lessThanOrEqualTo(1.0));
    });

    test('should calculate recommended study time', () async {
      // Create weak areas
      for (int i = 0; i < 3; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '危機回避',
          isCorrect: false,
          timeSpentSeconds: 30,
        );
      }
      for (int i = 0; i < 2; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '危機回避',
          isCorrect: true,
          timeSpentSeconds: 30,
        );
      }

      final minutes = await service.calculateRecommendedStudyMinutes('user123');

      expect(minutes, greaterThan(0));
      expect(minutes, lessThanOrEqualTo(180));
    });

    test('should generate personalized study plan', () async {
      // Create performance data
      for (int i = 0; i < 3; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '危機回避',
          isCorrect: i == 0,
          timeSpentSeconds: 30,
        );
      }
      for (int i = 0; i < 2; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '危機回避',
          isCorrect: true,
          timeSpentSeconds: 30,
        );
      }

      final plan =
          await service.generatePersonalizedStudyPlan('user123');

      expect(plan.userId, 'user123');
      expect(plan.topics, isNotEmpty);
      expect(plan.priority, isNotEmpty);
      expect(plan.estimatedHours, greaterThan(0));
      expect(plan.deadline, isNotNull);
    });
  });
}
