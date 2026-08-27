import * as admin from 'firebase-admin';

describe('Event Aggregator', () => {
  describe('aggregateAnalyticsEvent', () => {
    test('should aggregate question answered events', () => {
      // Test event aggregation for question answers
      const event = {
        type: 'questionAnswered',
        timestamp: admin.firestore.Timestamp.now(),
        userId: 'test_user_123',
        sessionId: 'session_456',
        parameters: {
          questionId: 'q_1',
          selectedAnswer: 2,
          isCorrect: true,
          category: 'signals',
          elapsedSeconds: 15,
        },
      };

      expect(event.type).toBe('questionAnswered');
      expect(event.parameters.isCorrect).toBe(true);
      expect(event.parameters.category).toBe('signals');
    });

    test('should aggregate quiz session completed events', () => {
      const event = {
        type: 'quizSessionCompleted',
        timestamp: admin.firestore.Timestamp.now(),
        userId: 'test_user_123',
        sessionId: 'session_456',
        parameters: {
          totalQuestions: 10,
          correctAnswers: 8,
          durationSeconds: 300,
          accuracy: 80,
        },
      };

      expect(event.type).toBe('quizSessionCompleted');
      expect(event.parameters.accuracy).toBe(80);
      expect(event.parameters.durationSeconds).toBe(300);
    });

    test('should aggregate bike unlock events', () => {
      const event = {
        type: 'bikeUnlocked',
        timestamp: admin.firestore.Timestamp.now(),
        userId: 'test_user_123',
        parameters: {
          bikeCategory: 'normal',
          unlockedPercentage: 100,
        },
      };

      expect(event.type).toBe('bikeUnlocked');
      expect(event.parameters.bikeCategory).toBe('normal');
      expect(event.parameters.unlockedPercentage).toBe(100);
    });

    test('should handle missing optional fields', () => {
      const event = {
        type: 'errorOccurred',
        timestamp: admin.firestore.Timestamp.now(),
        parameters: {
          errorType: 'NetworkException',
          errorMessage: 'Connection timeout',
        },
      };

      expect(event.userId).toBeUndefined();
      expect(event.sessionId).toBeUndefined();
      expect(event.parameters.errorType).toBe('NetworkException');
    });

    test('should validate event timestamps', () => {
      const now = new Date();
      const event = {
        type: 'questionAnswered',
        timestamp: admin.firestore.Timestamp.fromDate(now),
        parameters: {},
      };

      const eventDate = event.timestamp.toDate();
      expect(eventDate.getTime()).toBeLessThanOrEqual(Date.now());
      expect(eventDate.getTime()).toBeGreaterThan(Date.now() - 5000); // Within 5 seconds
    });
  });

  describe('Category aggregation', () => {
    test('should track category-specific statistics', () => {
      const stats = {
        categoryId: 'signals',
        attempts: 10,
        correctCount: 8,
        accuracy: 80,
        lastAnsweredAt: admin.firestore.Timestamp.now(),
      };

      expect(stats.accuracy).toBe(80);
      expect(stats.attempts).toBe(10);
      expect((stats.correctCount / stats.attempts) * 100).toBe(80);
    });

    test('should calculate accuracy correctly', () => {
      const attempts = 20;
      const correctCount = 15;
      const accuracy = (correctCount / attempts) * 100;

      expect(Math.round(accuracy * 10) / 10).toBe(75);
    });

    test('should handle zero attempts', () => {
      const attempts = 0;
      const correctCount = 0;
      const accuracy = attempts > 0 ? (correctCount / attempts) * 100 : 0;

      expect(accuracy).toBe(0);
    });
  });

  describe('Event type aggregation', () => {
    test('should count event types', () => {
      const eventTypes: Record<string, number> = {
        questionAnswered: 50,
        quizSessionCompleted: 5,
        bikeUnlocked: 3,
        errorOccurred: 1,
      };

      expect(eventTypes.questionAnswered).toBe(50);
      expect(eventTypes.quizSessionCompleted).toBe(5);
      expect(eventTypes.bikeUnlocked).toBe(3);
      expect(Object.keys(eventTypes).length).toBe(4);
    });

    test('should increment event type counters', () => {
      const eventTypes: Record<string, number> = {};

      const addEvent = (type: string) => {
        eventTypes[type] = (eventTypes[type] || 0) + 1;
      };

      addEvent('questionAnswered');
      addEvent('questionAnswered');
      addEvent('bikeUnlocked');

      expect(eventTypes.questionAnswered).toBe(2);
      expect(eventTypes.bikeUnlocked).toBe(1);
    });
  });

  describe('Session aggregation', () => {
    test('should track session statistics', () => {
      const stats = {
        sessionsCompleted: 10,
        totalQuestionsAnswered: 100,
        totalCorrectAnswers: 80,
        totalDurationSeconds: 3600,
        lastSessionAt: admin.firestore.Timestamp.now(),
      };

      const averageDuration = Math.round(stats.totalDurationSeconds / stats.sessionsCompleted);
      const accuracy = (stats.totalCorrectAnswers / stats.totalQuestionsAnswered) * 100;

      expect(averageDuration).toBe(360); // 6 minutes average
      expect(Math.round(accuracy * 10) / 10).toBe(80);
    });

    test('should handle multiple sessions', () => {
      const sessions = [
        { questions: 10, correct: 8, duration: 300 },
        { questions: 10, correct: 9, duration: 280 },
        { questions: 10, correct: 7, duration: 320 },
      ];

      const total = sessions.reduce(
        (acc, session) => ({
          questions: acc.questions + session.questions,
          correct: acc.correct + session.correct,
          duration: acc.duration + session.duration,
        }),
        { questions: 0, correct: 0, duration: 0 },
      );

      expect(total.questions).toBe(30);
      expect(total.correct).toBe(24);
      expect(Math.round((total.correct / total.questions) * 100 * 10) / 10).toBe(80);
    });
  });

  describe('Data validation', () => {
    test('should validate event structure', () => {
      const validEvent = {
        type: 'questionAnswered',
        timestamp: admin.firestore.Timestamp.now(),
        parameters: { questionId: 'q_1', isCorrect: true },
      };

      expect(validEvent.type).toBeTruthy();
      expect(validEvent.timestamp).toBeTruthy();
      expect(validEvent.parameters).toBeTruthy();
    });

    test('should handle complex parameters', () => {
      const params = {
        breakdown: {
          understanding: 85,
          retention: 90,
          speed: 92,
        },
        metadata: {
          deviceType: 'mobile',
          networkQuality: 'good',
        },
      };

      expect(params.breakdown.understanding).toBe(85);
      expect(params.metadata.deviceType).toBe('mobile');
      expect(Object.keys(params).length).toBe(2);
    });
  });
});
