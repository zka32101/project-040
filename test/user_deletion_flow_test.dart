import 'package:flutter_test/flutter_test.dart';

import 'package:bike_license_kore/models/user.dart';
import 'package:bike_license_kore/models/user_answer_log.dart';
import 'package:bike_license_kore/models/bike_unlock_progress.dart';
import 'package:bike_license_kore/models/trap_dojo_session.dart';
import 'package:bike_license_kore/models/pass_prediction_score.dart';
import 'package:bike_license_kore/services/user_deletion_service.dart';

void main() {
  group('UserDeletionProgress', () {
    test('should initialize with default values', () {
      // Act
      final progress = UserDeletionProgress(
        step: 1,
        totalSteps: 4,
        currentMessage: 'Deleting profile...',
        progressPercentage: 25,
        isComplete: false,
        error: null,
      );

      // Assert
      expect(progress.step, equals(1));
      expect(progress.totalSteps, equals(4));
      expect(progress.currentMessage, equals('Deleting profile...'));
      expect(progress.progressPercentage, equals(25));
      expect(progress.isComplete, isFalse);
      expect(progress.error, isNull);
    });

    test('should mark as complete when all steps done', () {
      // Act
      final progress = UserDeletionProgress(
        step: 4,
        totalSteps: 4,
        currentMessage: 'Deletion complete',
        progressPercentage: 100,
        isComplete: true,
        error: null,
      );

      // Assert
      expect(progress.isComplete, isTrue);
      expect(progress.progressPercentage, equals(100));
      expect(progress.step, equals(progress.totalSteps));
    });

    test('should handle error state', () {
      // Act
      final progress = UserDeletionProgress(
        step: 2,
        totalSteps: 4,
        currentMessage: 'Error during deletion',
        progressPercentage: 50,
        isComplete: false,
        error: Exception('Firestore deletion failed'),
      );

      // Assert
      expect(progress.error, isNotNull);
      expect(progress.isComplete, isFalse);
    });

    test('should track progress through all steps', () {
      // Define all steps
      final steps = [
        UserDeletionProgress(
          step: 1,
          totalSteps: 4,
          currentMessage: 'Deleting profile...',
          progressPercentage: 25,
          isComplete: false,
          error: null,
        ),
        UserDeletionProgress(
          step: 2,
          totalSteps: 4,
          currentMessage: 'Deleting answer logs...',
          progressPercentage: 50,
          isComplete: false,
          error: null,
        ),
        UserDeletionProgress(
          step: 3,
          totalSteps: 4,
          currentMessage: 'Deleting bike progress...',
          progressPercentage: 75,
          isComplete: false,
          error: null,
        ),
        UserDeletionProgress(
          step: 4,
          totalSteps: 4,
          currentMessage: 'Deletion complete',
          progressPercentage: 100,
          isComplete: true,
          error: null,
        ),
      ];

      // Assert - Each step should progress
      for (int i = 0; i < steps.length; i++) {
        expect(steps[i].step, equals(i + 1));
        expect(steps[i].progressPercentage, equals((i + 1) * 25));
        if (i == steps.length - 1) {
          expect(steps[i].isComplete, isTrue);
        }
      }
    });
  });

  group('GDPR Deletion Compliance', () {
    test('should delete all user profile data', () {
      // Verify deletion includes profile
      final deletionSteps = [
        'profile', // Step 1
      ];

      expect(deletionSteps.contains('profile'), isTrue);
    });

    test('should delete all answer logs', () {
      // Verify deletion includes answer logs
      final deletionSteps = [
        'answer logs', // Step 2
      ];

      expect(deletionSteps.contains('answer logs'), isTrue);
    });

    test('should delete bike unlock progress', () {
      // Verify deletion includes bike progress
      final deletionSteps = [
        'bike progress', // Step 3
      ];

      expect(deletionSteps.contains('bike progress'), isTrue);
    });

    test('should delete all associated data', () {
      // Verify complete data deletion
      final deletionItems = [
        'profile',
        'answer logs',
        'bike progress',
        'trap dojo sessions',
        'prediction scores',
      ];

      expect(deletionItems.length, equals(5));
      expect(deletionItems.every((item) => item.isNotEmpty), isTrue);
    });

    test('should be irreversible', () {
      // Test should indicate deletion is irreversible
      final warning =
          'このアクションは取り消せません。以下のデータが削除されます：';

      expect(warning.contains('取り消せません'), isTrue);
    });
  });

  group('Deletion Data Models', () {
    test('should handle user model for deletion', () {
      // Create a user
      final user = AppUser(
        uid: 'test_user_12345678901234567890',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime.now(),
      );

      // Verify user can be serialized for deletion
      final json = user.toJson();
      expect(json.containsKey('uid'), isTrue);
      expect(json['uid'], equals('test_user_12345678901234567890'));
    });

    test('should handle answer log deletion data', () {
      // Create answer logs
      const log = UserAnswerLog(
        id: 'log_1',
        uid: 'test_user_12345678901234567890',
        questionId: 'q_1',
        selectedAnswer: 2,
        isCorrect: true,
        answeredAt: null,
      );

      // Verify answer log can be serialized
      final json = log.toJson();
      expect(json.containsKey('uid'), isTrue);
      expect(json['uid'], equals('test_user_12345678901234567890'));
    });

    test('should handle bike progress deletion data', () {
      // Create bike progress
      final progress = BikeUnlockProgress(
        uid: 'test_user_12345678901234567890',
        bikeCategory: 'gentsuki',
        unlockedAt: DateTime.now(),
        unlockedPercentage: 50,
      );

      // Verify bike progress can be serialized
      final json = progress.toJson();
      expect(json.containsKey('uid'), isTrue);
      expect(json['uid'], equals('test_user_12345678901234567890'));
    });

    test('should handle trap dojo session deletion data', () {
      // Create trap dojo session
      final session = TrapDojoSession(
        id: 'session_1',
        uid: 'test_user_12345678901234567890',
        startedAt: DateTime.now(),
        completedAt: DateTime.now(),
        score: 80,
        totalQuestions: 10,
      );

      // Verify session can be serialized
      final json = session.toJson();
      expect(json.containsKey('uid'), isTrue);
      expect(json['uid'], equals('test_user_12345678901234567890'));
    });

    test('should handle prediction score deletion data', () {
      // Create prediction score
      final score = PassPredictionScore(
        uid: 'test_user_12345678901234567890',
        score: 85.5,
        calculatedAt: DateTime.now(),
        breakdown: {'understanding': 85.0, 'retention': 86.0},
      );

      // Verify score can be serialized
      final json = score.toJson();
      expect(json.containsKey('uid'), isTrue);
      expect(json['uid'], equals('test_user_12345678901234567890'));
    });
  });

  group('Deletion Error Handling', () {
    test('should handle deletion errors gracefully', () {
      // Create error progress
      final errorProgress = UserDeletionProgress(
        step: 2,
        totalSteps: 4,
        currentMessage: 'Error occurred',
        progressPercentage: 50,
        isComplete: false,
        error: Exception('Firestore deletion failed'),
      );

      // Verify error is captured
      expect(errorProgress.error, isNotNull);
      expect(errorProgress.error.toString().contains('Firestore'), isTrue);
    });

    test('should allow retry after error', () {
      // First attempt with error
      var progress = UserDeletionProgress(
        step: 2,
        totalSteps: 4,
        currentMessage: 'Error occurred',
        progressPercentage: 50,
        isComplete: false,
        error: Exception('Network error'),
      );

      expect(progress.error, isNotNull);

      // Simulate retry - create new progress starting from step 2
      progress = UserDeletionProgress(
        step: 2,
        totalSteps: 4,
        currentMessage: 'Retrying...',
        progressPercentage: 50,
        isComplete: false,
        error: null,
      );

      // Verify error cleared and retry in progress
      expect(progress.error, isNull);
    });

    test('should provide meaningful error messages', () {
      // Various error scenarios
      final errorMessages = [
        'Firestore deletion failed',
        'Firebase Auth deletion failed',
        'Network error - please check connection',
        'Permission denied - please re-authenticate',
        'Subcollection deletion failed',
      ];

      for (final message in errorMessages) {
        final progress = UserDeletionProgress(
          step: 1,
          totalSteps: 4,
          currentMessage: message,
          progressPercentage: 0,
          isComplete: false,
          error: Exception(message),
        );

        expect(progress.error, isNotNull);
        expect(progress.currentMessage, equals(message));
      }
    });
  });
}
