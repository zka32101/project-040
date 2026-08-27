import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bike_license_kore/models/analytics_event.dart';
import 'package:bike_license_kore/models/analytics_snapshot.dart';
import 'package:bike_license_kore/services/analytics_tracking_service.dart';

void main() {
  group('Analytics Events Workflow', () {
    late StubAnalyticsTrackingService analyticsService;

    setUp(() {
      analyticsService = StubAnalyticsTrackingService();
    });

    test('should track complete quiz session workflow', () async {
      // Arrange
      final userId = 'test_user_123';
      final sessionId = analyticsService.getSessionId();

      // Act - Track quiz start (implicit in session ID)
      await analyticsService.setUserId(userId);

      // Track individual question answers
      for (int i = 0; i < 10; i++) {
        final event = AnalyticsEvents.questionAnswered(
          userId: userId,
          sessionId: sessionId,
          questionId: 'q_$i',
          selectedAnswer: (i % 4) + 1,
          isCorrect: i % 2 == 0, // 50% correct
          elapsedSeconds: 15 + (i * 2),
        );
        await analyticsService.trackEvent(event);
      }

      // Track session completion
      final completionEvent = AnalyticsEvents.quizSessionCompleted(
        userId: userId,
        sessionId: sessionId,
        totalQuestions: 10,
        correctAnswers: 5,
        durationSeconds: 300,
      );
      await analyticsService.trackEvent(completionEvent);

      // Assert
      final history = analyticsService.getEventHistory();
      expect(history.length, equals(11)); // 10 questions + 1 session completion
      expect(history.last.type, equals(AnalyticsEventType.quizSessionCompleted));
      expect(history.last.parameters['accuracy'], equals('50.0'));

      // Verify question answers are tracked
      final questionEvents =
          history.where((e) => e.type == AnalyticsEventType.questionAnswered);
      expect(questionEvents.length, equals(10));
    });

    test('should track bike unlock progression', () async {
      // Arrange
      final userId = 'test_user_123';
      const bikeCategories = ['gentsuki', 'normal', 'middium', 'big', 'large'];

      // Act
      for (int i = 0; i < bikeCategories.length; i++) {
        final event = AnalyticsEvents.bikeUnlocked(
          userId: userId,
          bikeCategory: bikeCategories[i],
          unlockedPercentage: (i + 1) * 20,
        );
        await analyticsService.trackEvent(event);
      }

      // Assert
      final history = analyticsService.getEventHistory();
      expect(history.length, equals(5));

      for (int i = 0; i < history.length; i++) {
        expect(history[i].type, equals(AnalyticsEventType.bikeUnlocked));
        expect(
            history[i].parameters['bikeCategory'], equals(bikeCategories[i]));
        expect(
            history[i].parameters['unlockedPercentage'], equals((i + 1) * 20));
      }
    });

    test('should track prediction score calculation', () async {
      // Arrange
      final userId = 'test_user_123';
      const breakdownStages = [
        {'understanding': 70.0, 'retention': 65.0},
        {'understanding': 75.0, 'retention': 72.0},
        {'understanding': 80.0, 'retention': 78.0},
      ];

      // Act
      for (int i = 0; i < breakdownStages.length; i++) {
        final event = AnalyticsEvents.predictionScoreCalculated(
          userId: userId,
          score: 70.0 + (i * 5),
          breakdown: breakdownStages[i],
        );
        await analyticsService.trackEvent(event);
      }

      // Assert
      final history = analyticsService.getEventHistory();
      expect(history.length, equals(3));

      for (int i = 0; i < history.length; i++) {
        expect(history[i].type,
            equals(AnalyticsEventType.predictionScoreCalculated));
        expect(history[i].parameters['score'], equals(70.0 + (i * 5)));
        expect(history[i].parameters['breakdown'],
            equals(breakdownStages[i]));
      }
    });

    test('should track error events', () async {
      // Arrange
      final userId = 'test_user_123';
      const errorScenarios = [
        ('FirestoreException', 'Failed to load data'),
        ('NetworkException', 'Connection timeout'),
        ('AuthException', 'User not authenticated'),
      ];

      // Act
      for (final (errorType, errorMessage) in errorScenarios) {
        final event = AnalyticsEvents.errorOccurred(
          userId: userId,
          errorType: errorType,
          errorMessage: errorMessage,
        );
        await analyticsService.trackEvent(event);
      }

      // Assert
      final history = analyticsService.getEventHistory();
      expect(history.length, equals(3));

      for (int i = 0; i < history.length; i++) {
        expect(history[i].type, equals(AnalyticsEventType.errorOccurred));
        expect(
            history[i].parameters['errorType'], equals(errorScenarios[i].$1));
        expect(history[i].parameters['errorMessage'],
            equals(errorScenarios[i].$2));
      }
    });

    test('should maintain event order', () async {
      // Arrange
      final userId = 'test_user_123';
      final sessionId = analyticsService.getSessionId();
      final eventTypes = [
        AnalyticsEventType.quizSessionStarted,
        AnalyticsEventType.questionAnswered,
        AnalyticsEventType.questionAnswered,
        AnalyticsEventType.bikeUnlocked,
        AnalyticsEventType.predictionScoreCalculated,
        AnalyticsEventType.quizSessionCompleted,
      ];

      // Act
      for (int i = 0; i < eventTypes.length; i++) {
        final event = AnalyticsEvent(
          type: eventTypes[i],
          timestamp: DateTime.now(),
          userId: userId,
          sessionId: sessionId,
          parameters: {'index': i},
        );
        await analyticsService.trackEvent(event);
      }

      // Assert
      final history = analyticsService.getEventHistory();
      expect(history.length, equals(eventTypes.length));

      for (int i = 0; i < history.length; i++) {
        expect(history[i].type, equals(eventTypes[i]));
        expect(history[i].parameters['index'], equals(i));
      }
    });
  });

  group('Analytics Data Aggregation Patterns', () {
    late StubAnalyticsTrackingService analyticsService;

    setUp(() {
      analyticsService = StubAnalyticsTrackingService();
    });

    test('should support multi-session tracking', () async {
      // Arrange
      const userId = 'test_user_123';
      const numSessions = 3;
      const questionsPerSession = 10;

      // Act
      for (int session = 0; session < numSessions; session++) {
        final sessionId = 'session_$session';

        // Track session start
        for (int q = 0; q < questionsPerSession; q++) {
          final event = AnalyticsEvents.questionAnswered(
            userId: userId,
            sessionId: sessionId,
            questionId: 'q_${session}_$q',
            selectedAnswer: 1,
            isCorrect: q % 2 == 0,
            elapsedSeconds: 20,
          );
          await analyticsService.trackEvent(event);
        }

        // Track session completion
        final completionEvent = AnalyticsEvents.quizSessionCompleted(
          userId: userId,
          sessionId: sessionId,
          totalQuestions: questionsPerSession,
          correctAnswers: questionsPerSession ~/ 2,
          durationSeconds: 400,
        );
        await analyticsService.trackEvent(completionEvent);
      }

      // Assert
      final history = analyticsService.getEventHistory();
      final totalEvents = (questionsPerSession + 1) * numSessions;
      expect(history.length, equals(totalEvents));

      // Verify session grouping
      final sessionIds = <String>{};
      for (final event in history) {
        if (event.sessionId != null) {
          sessionIds.add(event.sessionId!);
        }
      }
      expect(sessionIds.length, equals(numSessions));
    });

    test('should track learning progression', () async {
      // Arrange
      const userId = 'test_user_123';
      const sessionId = 'long_session';

      // Act - Simulate learning progression with improving scores
      for (int i = 0; i < 5; i++) {
        final correctCount = 2 + (i * 1); // Improvement over time
        final totalQuestions = 10;

        for (int q = 0; q < totalQuestions; q++) {
          final event = AnalyticsEvents.questionAnswered(
            userId: userId,
            sessionId: sessionId,
            questionId: 'q_${i}_$q',
            selectedAnswer: 1,
            isCorrect: q < correctCount,
            elapsedSeconds: 25 - (i * 2), // Also faster
          );
          await analyticsService.trackEvent(event);
        }

        // Calculate accuracy for this batch
        final accuracy = (correctCount / totalQuestions * 100).toString();

        // Track milestone
        final milestoneEvent = AnalyticsEvents.quizSessionCompleted(
          userId: userId,
          sessionId: '${sessionId}_batch_$i',
          totalQuestions: totalQuestions,
          correctAnswers: correctCount,
          durationSeconds: 250 - (i * 20),
        );
        await analyticsService.trackEvent(milestoneEvent);
      }

      // Assert
      final history = analyticsService.getEventHistory();
      expect(history.length, greaterThan(50)); // 50 question events + 5 batch events

      // Verify improvement pattern
      final completionEvents = history
          .where((e) => e.type == AnalyticsEventType.quizSessionCompleted)
          .toList();
      expect(completionEvents.length, equals(5));

      // Check that later sessions have different accuracy
      for (int i = 1; i < completionEvents.length; i++) {
        final prevAccuracy =
            double.parse(completionEvents[i - 1].parameters['accuracy']);
        final currAccuracy =
            double.parse(completionEvents[i].parameters['accuracy']);
        expect(currAccuracy, greaterThanOrEqualTo(prevAccuracy));
      }
    });

    test('should support category-based analytics', () async {
      // Arrange
      const userId = 'test_user_123';
      const sessionId = 'category_test';
      const categories = ['signals', 'rules', 'safety', 'vehicle_control'];

      // Act
      for (final category in categories) {
        for (int i = 0; i < 5; i++) {
          final event = AnalyticsEvent(
            type: AnalyticsEventType.questionAnswered,
            timestamp: DateTime.now(),
            userId: userId,
            sessionId: sessionId,
            parameters: {
              'category': category,
              'questionId': '${category}_$i',
              'isCorrect': i % 2 == 0,
            },
          );
          await analyticsService.trackEvent(event);
        }
      }

      // Assert
      final history = analyticsService.getEventHistory();
      expect(history.length, equals(categories.length * 5));

      // Group by category
      final byCategory = <String, List<AnalyticsEvent>>{};
      for (final event in history) {
        final category = event.parameters['category'] as String?;
        if (category != null) {
          byCategory.putIfAbsent(category, () => []).add(event);
        }
      }

      expect(byCategory.keys.length, equals(categories.length));
      for (final events in byCategory.values) {
        expect(events.length, equals(5));
      }
    });
  });

  group('Analytics Performance', () {
    late StubAnalyticsTrackingService analyticsService;

    setUp(() {
      analyticsService = StubAnalyticsTrackingService();
    });

    test('should handle high volume of events', () async {
      // Arrange
      const userId = 'test_user_123';
      const eventCount = 500;

      // Act
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < eventCount; i++) {
        final event = AnalyticsEvent(
          type: AnalyticsEventType.questionAnswered,
          timestamp: DateTime.now(),
          userId: userId,
          parameters: {'index': i},
        );
        await analyticsService.trackEvent(event);
      }

      stopwatch.stop();

      // Assert
      final history = analyticsService.getEventHistory(limit: 1000);
      expect(history.length, equals(500)); // All 500 fit within 1000 limit

      // Verify performance (tracking should be reasonably fast)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('should efficiently retrieve event history', () async {
      // Arrange
      const userId = 'test_user_123';
      for (int i = 0; i < 100; i++) {
        final event = AnalyticsEvent(
          type: AnalyticsEventType.questionAnswered,
          timestamp: DateTime.now(),
          userId: userId,
          parameters: {'index': i},
        );
        await analyticsService.trackEvent(event);
      }

      // Act
      final stopwatch = Stopwatch()..start();
      final history1 = analyticsService.getEventHistory(limit: 10);
      final history2 = analyticsService.getEventHistory(limit: 50);
      final history3 = analyticsService.getEventHistory(limit: 100);
      stopwatch.stop();

      // Assert
      expect(history1.length, equals(10));
      expect(history2.length, equals(50));
      expect(history3.length, equals(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });

  group('Analytics Data Integrity', () {
    late StubAnalyticsTrackingService analyticsService;

    setUp(() {
      analyticsService = StubAnalyticsTrackingService();
    });

    test('should preserve event data through tracking lifecycle', () async {
      // Arrange
      const userId = 'test_user_123';
      const sessionId = 'integrity_test';
      final originalEvent = AnalyticsEvents.questionAnswered(
        userId: userId,
        sessionId: sessionId,
        questionId: 'q_integrity',
        selectedAnswer: 3,
        isCorrect: true,
        elapsedSeconds: 42,
      );

      // Act
      await analyticsService.trackEvent(originalEvent);
      final history = analyticsService.getEventHistory();
      final trackedEvent = history.first;

      // Assert
      expect(trackedEvent.type, equals(originalEvent.type));
      expect(trackedEvent.userId, equals(originalEvent.userId));
      expect(trackedEvent.sessionId, equals(originalEvent.sessionId));
      expect(trackedEvent.parameters['questionId'],
          equals(originalEvent.parameters['questionId']));
      expect(trackedEvent.parameters['selectedAnswer'],
          equals(originalEvent.parameters['selectedAnswer']));
      expect(trackedEvent.parameters['isCorrect'],
          equals(originalEvent.parameters['isCorrect']));
      expect(trackedEvent.parameters['elapsedSeconds'],
          equals(originalEvent.parameters['elapsedSeconds']));
    });

    test('should maintain timestamp accuracy', () async {
      // Arrange
      const userId = 'test_user_123';
      final beforeTime = DateTime.now();

      // Act
      final event = AnalyticsEvent(
        type: AnalyticsEventType.questionAnswered,
        timestamp: beforeTime,
        userId: userId,
      );
      await analyticsService.trackEvent(event);

      final afterTime = DateTime.now();
      final history = analyticsService.getEventHistory();
      final trackedEvent = history.first;

      // Assert
      expect(trackedEvent.timestamp.isAfter(beforeTime.subtract(Duration(seconds: 1))), isTrue);
      expect(trackedEvent.timestamp.isBefore(afterTime.add(Duration(seconds: 1))), isTrue);
    });

    test('should handle complex parameter structures', () async {
      // Arrange
      const userId = 'test_user_123';
      final complexParams = {
        'breakdown': {
          'understanding': 85.0,
          'retention': 90.0,
          'speed': 92.5,
        },
        'nested': {
          'level1': {
            'level2': 'value',
          },
        },
        'list': [1, 2, 3, 4, 5],
      };

      // Act
      final event = AnalyticsEvent(
        type: AnalyticsEventType.predictionScoreCalculated,
        timestamp: DateTime.now(),
        userId: userId,
        parameters: complexParams,
      );
      await analyticsService.trackEvent(event);
      final history = analyticsService.getEventHistory();
      final trackedEvent = history.first;

      // Assert
      expect(trackedEvent.parameters['breakdown'],
          equals(complexParams['breakdown']));
      expect(trackedEvent.parameters['nested'], equals(complexParams['nested']));
      expect(trackedEvent.parameters['list'], equals(complexParams['list']));
    });
  });
}
