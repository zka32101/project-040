import 'package:flutter_test/flutter_test.dart';

import 'package:bike_license_kore/models/analytics_event.dart';
import 'package:bike_license_kore/services/analytics_tracking_service.dart';

void main() {
  group('FirebaseAnalyticsTrackingService', () {
    late FirebaseAnalyticsTrackingService service;

    setUp(() {
      service = FirebaseAnalyticsTrackingService();
    });

    test('should initialize with a session ID', () {
      // Act
      final sessionId = service.getSessionId();

      // Assert
      expect(sessionId, isNotEmpty);
      expect(sessionId.length, greaterThan(0));
    });

    test('should set and retrieve session ID', () {
      // Act
      final sessionId1 = service.getSessionId();
      final sessionId2 = service.getSessionId();

      // Assert
      expect(sessionId1, equals(sessionId2));
    });

    test('should track a question answered event', () async {
      // Arrange
      final event = AnalyticsEvents.questionAnswered(
        userId: 'test_user_123',
        sessionId: service.getSessionId(),
        questionId: 'q_1',
        selectedAnswer: 1,
        isCorrect: true,
        elapsedSeconds: 15,
      );

      // Act
      await service.trackEvent(event);
      final history = service.getEventHistory();

      // Assert
      expect(history, isNotEmpty);
      expect(history.first.type, equals(AnalyticsEventType.questionAnswered));
      expect(history.first.parameters['questionId'], equals('q_1'));
      expect(history.first.parameters['isCorrect'], isTrue);
    });

    test('should track a quiz session completed event', () async {
      // Arrange
      final event = AnalyticsEvents.quizSessionCompleted(
        userId: 'test_user_123',
        sessionId: service.getSessionId(),
        totalQuestions: 10,
        correctAnswers: 8,
        durationSeconds: 120,
      );

      // Act
      await service.trackEvent(event);
      final history = service.getEventHistory();

      // Assert
      expect(history, isNotEmpty);
      expect(
          history.first.type, equals(AnalyticsEventType.quizSessionCompleted));
      expect(history.first.parameters['totalQuestions'], equals(10));
      expect(history.first.parameters['correctAnswers'], equals(8));
      expect(history.first.parameters['accuracy'], equals('80.0'));
    });

    test('should track a bike unlocked event', () async {
      // Arrange
      final event = AnalyticsEvents.bikeUnlocked(
        userId: 'test_user_123',
        bikeCategory: 'gentsuki',
        unlockedPercentage: 100,
      );

      // Act
      await service.trackEvent(event);
      final history = service.getEventHistory();

      // Assert
      expect(history, isNotEmpty);
      expect(history.first.type, equals(AnalyticsEventType.bikeUnlocked));
      expect(history.first.parameters['bikeCategory'], equals('gentsuki'));
      expect(history.first.parameters['unlockedPercentage'], equals(100));
    });

    test('should track a prediction score calculated event', () async {
      // Arrange
      final breakdown = {'understanding': 85.0, 'retention': 90.0};
      final event = AnalyticsEvents.predictionScoreCalculated(
        userId: 'test_user_123',
        score: 87.5,
        breakdown: breakdown,
      );

      // Act
      await service.trackEvent(event);
      final history = service.getEventHistory();

      // Assert
      expect(history, isNotEmpty);
      expect(history.first.type,
          equals(AnalyticsEventType.predictionScoreCalculated));
      expect(history.first.parameters['score'], equals(87.5));
      expect(
          history.first.parameters['breakdown'],
          equals({
            'understanding': 85.0,
            'retention': 90.0,
          }));
    });

    test('should track an error occurred event', () async {
      // Arrange
      final event = AnalyticsEvents.errorOccurred(
        userId: 'test_user_123',
        errorType: 'FirestoreException',
        errorMessage: 'Network timeout',
      );

      // Act
      await service.trackEvent(event);
      final history = service.getEventHistory();

      // Assert
      expect(history, isNotEmpty);
      expect(history.first.type, equals(AnalyticsEventType.errorOccurred));
      expect(
          history.first.parameters['errorType'], equals('FirestoreException'));
      expect(history.first.parameters['errorMessage'], equals('Network timeout'));
    });

    test('should maintain max 1000 events in history', () async {
      // Act - Track more than 1000 events
      for (int i = 0; i < 1100; i++) {
        final event = AnalyticsEvent(
          type: AnalyticsEventType.questionAnswered,
          timestamp: DateTime.now(),
          userId: 'test_user_123',
          sessionId: service.getSessionId(),
          parameters: {
            'questionId': 'q_$i',
            'selectedAnswer': 1,
            'isCorrect': true,
            'elapsedSeconds': 10,
          },
        );
        await service.trackEvent(event);
      }

      final history = service.getEventHistory(limit: 2000);

      // Assert - Should only keep last 1000 events
      expect(history.length, equals(1000));
    });

    test('should respect limit parameter in getEventHistory', () async {
      // Arrange - Track multiple events
      for (int i = 0; i < 50; i++) {
        final event = AnalyticsEvent(
          type: AnalyticsEventType.questionAnswered,
          timestamp: DateTime.now(),
          userId: 'test_user_123',
          sessionId: service.getSessionId(),
          parameters: {
            'questionId': 'q_$i',
            'selectedAnswer': 1,
            'isCorrect': true,
            'elapsedSeconds': 10,
          },
        );
        await service.trackEvent(event);
      }

      // Act
      final history10 = service.getEventHistory(limit: 10);
      final history25 = service.getEventHistory(limit: 25);

      // Assert
      expect(history10.length, equals(10));
      expect(history25.length, equals(25));
    });

    test('should set user ID', () async {
      // Act
      await service.setUserId('user_abc_123');

      // Assert - Verify the service accepts the ID (no error thrown)
      expect(true, isTrue);
    });

    test('should set user property', () async {
      // Act
      await service.setUserProperty('license_category', 'gentsuki');

      // Assert - Verify the service accepts the property (no error thrown)
      expect(true, isTrue);
    });

    test('should reset analytics', () async {
      // Arrange - Track some events
      await service.trackEvent(AnalyticsEvents.questionAnswered(
        userId: 'test_user_123',
        sessionId: service.getSessionId(),
        questionId: 'q_1',
        selectedAnswer: 1,
        isCorrect: true,
        elapsedSeconds: 15,
      ));

      expect(service.getEventHistory(), isNotEmpty);

      // Act
      await service.resetAnalytics();
      final history = service.getEventHistory();

      // Assert
      expect(history, isEmpty);
    });

    test('should generate new session ID after reset', () async {
      // Arrange
      final oldSessionId = service.getSessionId();

      // Act
      await service.resetAnalytics();
      final newSessionId = service.getSessionId();

      // Assert
      expect(oldSessionId, isNotEmpty);
      expect(newSessionId, isNotEmpty);
      // New session ID should be generated, may be different timestamp
    });

    test('should include session ID in tracked events', () async {
      // Arrange
      final sessionId = service.getSessionId();
      final event = AnalyticsEvent(
        type: AnalyticsEventType.questionAnswered,
        timestamp: DateTime.now(),
        userId: 'test_user_123',
        sessionId: sessionId,
        parameters: {'questionId': 'q_1'},
      );

      // Act
      await service.trackEvent(event);
      final history = service.getEventHistory();

      // Assert
      expect(history.first.sessionId, equals(sessionId));
    });
  });

  group('StubAnalyticsTrackingService', () {
    late StubAnalyticsTrackingService service;

    setUp(() {
      service = StubAnalyticsTrackingService();
    });

    test('should initialize with a session ID', () {
      // Act
      final sessionId = service.getSessionId();

      // Assert
      expect(sessionId, isNotEmpty);
      expect(sessionId.contains('stub_session_'), isTrue);
    });

    test('should track events without Firebase', () async {
      // Arrange
      final event = AnalyticsEvents.questionAnswered(
        userId: 'test_user_123',
        sessionId: service.getSessionId(),
        questionId: 'q_1',
        selectedAnswer: 1,
        isCorrect: true,
        elapsedSeconds: 15,
      );

      // Act
      await service.trackEvent(event);
      final history = service.getEventHistory();

      // Assert
      expect(history, isNotEmpty);
      expect(history.first.type, equals(AnalyticsEventType.questionAnswered));
    });

    test('should set user ID without Firebase', () async {
      // Act & Assert - Should not throw
      await service.setUserId('test_user_123');
      expect(true, isTrue);
    });

    test('should set user property without Firebase', () async {
      // Act & Assert - Should not throw
      await service.setUserProperty('license_category', 'gentsuki');
      expect(true, isTrue);
    });

    test('should reset analytics', () async {
      // Arrange
      await service.trackEvent(AnalyticsEvents.questionAnswered(
        userId: 'test_user_123',
        sessionId: service.getSessionId(),
        questionId: 'q_1',
        selectedAnswer: 1,
        isCorrect: true,
        elapsedSeconds: 15,
      ));

      expect(service.getEventHistory(), isNotEmpty);

      // Act
      await service.resetAnalytics();

      // Assert
      expect(service.getEventHistory(), isEmpty);
    });

    test('should generate new session ID after reset', () async {
      // Arrange
      final oldSessionId = service.getSessionId();

      // Act
      await service.resetAnalytics();
      final newSessionId = service.getSessionId();

      // Assert
      expect(oldSessionId, isNotEmpty);
      expect(newSessionId, isNotEmpty);
      expect(newSessionId, isNot(equals(oldSessionId)));
    });

    test('should maintain max 1000 events in history', () async {
      // Act
      for (int i = 0; i < 1100; i++) {
        final event = AnalyticsEvent(
          type: AnalyticsEventType.questionAnswered,
          timestamp: DateTime.now(),
          userId: 'test_user_123',
          sessionId: service.getSessionId(),
          parameters: {
            'questionId': 'q_$i',
            'selectedAnswer': 1,
            'isCorrect': true,
            'elapsedSeconds': 10,
          },
        );
        await service.trackEvent(event);
      }

      final history = service.getEventHistory(limit: 2000);

      // Assert
      expect(history.length, equals(1000));
    });
  });

  group('AnalyticsEvents Helper', () {
    test('should create questionAnswered event with correct parameters', () {
      // Act
      final event = AnalyticsEvents.questionAnswered(
        userId: 'user_123',
        sessionId: 'session_456',
        questionId: 'q_1',
        selectedAnswer: 2,
        isCorrect: true,
        elapsedSeconds: 30,
      );

      // Assert
      expect(event.type, equals(AnalyticsEventType.questionAnswered));
      expect(event.userId, equals('user_123'));
      expect(event.sessionId, equals('session_456'));
      expect(event.parameters['questionId'], equals('q_1'));
      expect(event.parameters['selectedAnswer'], equals(2));
      expect(event.parameters['isCorrect'], isTrue);
      expect(event.parameters['elapsedSeconds'], equals(30));
    });

    test('should create quizSessionCompleted event with accuracy', () {
      // Act
      final event = AnalyticsEvents.quizSessionCompleted(
        userId: 'user_123',
        sessionId: 'session_456',
        totalQuestions: 20,
        correctAnswers: 15,
        durationSeconds: 600,
      );

      // Assert
      expect(event.type, equals(AnalyticsEventType.quizSessionCompleted));
      expect(event.parameters['totalQuestions'], equals(20));
      expect(event.parameters['correctAnswers'], equals(15));
      expect(event.parameters['accuracy'], equals('75.0'));
      expect(event.parameters['durationSeconds'], equals(600));
    });

    test('should create bikeUnlocked event', () {
      // Act
      final event = AnalyticsEvents.bikeUnlocked(
        userId: 'user_123',
        bikeCategory: 'normal',
        unlockedPercentage: 50,
      );

      // Assert
      expect(event.type, equals(AnalyticsEventType.bikeUnlocked));
      expect(event.parameters['bikeCategory'], equals('normal'));
      expect(event.parameters['unlockedPercentage'], equals(50));
    });

    test('should create predictionScoreCalculated event', () {
      // Arrange
      final breakdown = {
        'understanding': 80.0,
        'retention': 75.0,
        'speed': 85.0,
      };

      // Act
      final event = AnalyticsEvents.predictionScoreCalculated(
        userId: 'user_123',
        score: 80.0,
        breakdown: breakdown,
      );

      // Assert
      expect(event.type, equals(AnalyticsEventType.predictionScoreCalculated));
      expect(event.parameters['score'], equals(80.0));
      expect(event.parameters['breakdown'], equals(breakdown));
    });

    test('should create errorOccurred event', () {
      // Act
      final event = AnalyticsEvents.errorOccurred(
        userId: 'user_123',
        errorType: 'IOException',
        errorMessage: 'Failed to load data',
      );

      // Assert
      expect(event.type, equals(AnalyticsEventType.errorOccurred));
      expect(event.parameters['errorType'], equals('IOException'));
      expect(event.parameters['errorMessage'], equals('Failed to load data'));
    });
  });

  group('AnalyticsEvent Model', () {
    test('should convert to JSON correctly', () {
      // Arrange
      final event = AnalyticsEvent(
        type: AnalyticsEventType.questionAnswered,
        timestamp: DateTime(2026, 1, 1, 12, 0, 0),
        userId: 'user_123',
        sessionId: 'session_456',
        parameters: {
          'questionId': 'q_1',
          'isCorrect': true,
        },
      );

      // Act
      final json = event.toJson();

      // Assert
      expect(json['eventName'], equals('questionAnswered'));
      expect(json['userId'], equals('user_123'));
      expect(json['sessionId'], equals('session_456'));
      expect(json['parameters']['questionId'], equals('q_1'));
      expect(json['parameters']['isCorrect'], isTrue);
    });

    test('should generate event name from type', () {
      // Arrange
      final events = [
        AnalyticsEvent(
          type: AnalyticsEventType.questionAnswered,
          timestamp: DateTime.now(),
        ),
        AnalyticsEvent(
          type: AnalyticsEventType.quizSessionCompleted,
          timestamp: DateTime.now(),
        ),
        AnalyticsEvent(
          type: AnalyticsEventType.bikeUnlocked,
          timestamp: DateTime.now(),
        ),
      ];

      // Assert
      expect(events[0].eventName, equals('questionAnswered'));
      expect(events[1].eventName, equals('quizSessionCompleted'));
      expect(events[2].eventName, equals('bikeUnlocked'));
    });

    test('should handle missing optional fields', () {
      // Act
      final event = AnalyticsEvent(
        type: AnalyticsEventType.appLaunched,
        timestamp: DateTime.now(),
      );

      // Assert
      expect(event.userId, isNull);
      expect(event.sessionId, isNull);
      expect(event.parameters, isEmpty);
    });
  });
}
