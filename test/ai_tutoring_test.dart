import 'package:flutter_test/flutter_test.dart';
import 'package:bike_license_kore/models/community_model.dart';

void main() {
  group('Phase 16: AI-Powered Tutoring & Study Planning', () {
    group('AdaptiveStudyPlan', () {
      test('creates personalized study plan', () {
        final plan = AdaptiveStudyPlan(
          id: 'plan_001',
          studentId: 'student_001',
          startDate: DateTime.now(),
          targetExamDate: DateTime.now().add(const Duration(days: 30)),
          sessions: [
            StudySession(
              id: 'sess_001',
              category: 'road-signs',
              scheduledDate: DateTime.now().add(const Duration(days: 1)),
              durationMinutes: 45,
              topicsToReview: ['stop-signs', 'yield-signs'],
              questionIds: ['q_001', 'q_002', 'q_003'],
              completed: false,
            ),
          ],
          priorityCategories: ['road-signs', 'traffic-rules'],
          estimatedTotalHours: 20,
          frequency: StudyPlanFrequency.daily,
          strategy: OptimizationStrategy.balanced,
          confidenceScore: 0.85,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(plan.studentId, 'student_001');
        expect(plan.sessions.length, 1);
        expect(plan.daysRemaining, 30);
        expect(plan.isOnTrack, false);
      });

      test('tracks plan progress', () {
        final plan = AdaptiveStudyPlan(
          id: 'plan_002',
          studentId: 'student_002',
          startDate: DateTime.now(),
          targetExamDate: DateTime.now().add(const Duration(days: 10)),
          sessions: List.generate(
            10,
            (i) => StudySession(
              id: 'sess_$i',
              category: 'traffic-rules',
              scheduledDate: DateTime.now().add(Duration(days: i)),
              durationMinutes: 30,
              topicsToReview: ['speed-limits'],
              questionIds: ['q_$i'],
              completed: i < 8, // 8 out of 10 completed
              completedAt: i < 8 ? DateTime.now() : null,
            ),
          ),
          priorityCategories: ['traffic-rules'],
          estimatedTotalHours: 5,
          frequency: StudyPlanFrequency.daily,
          strategy: OptimizationStrategy.aggressive,
          confidenceScore: 0.90,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(plan.sessions.length, 10);
        expect(plan.isOnTrack, true);
      });

      test('serializes and deserializes correctly', () {
        final plan = AdaptiveStudyPlan(
          id: 'plan_003',
          studentId: 'student_003',
          startDate: DateTime.now(),
          targetExamDate: DateTime.now().add(const Duration(days: 30)),
          sessions: [],
          priorityCategories: ['road-signs'],
          estimatedTotalHours: 15,
          frequency: StudyPlanFrequency.threeDaysWeek,
          strategy: OptimizationStrategy.gradual,
          confidenceScore: 0.75,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final map = plan.toMap();
        final reconstructed = AdaptiveStudyPlan.fromMap(map);

        expect(reconstructed.id, plan.id);
        expect(reconstructed.frequency, StudyPlanFrequency.threeDaysWeek);
        expect(reconstructed.strategy, OptimizationStrategy.gradual);
      });
    });

    group('StudySession', () {
      test('tracks individual study sessions', () {
        final session = StudySession(
          id: 'sess_001',
          category: 'vehicle-handling',
          scheduledDate: DateTime.now(),
          durationMinutes: 60,
          topicsToReview: ['tire-pressure', 'braking'],
          questionIds: ['q_vh_001', 'q_vh_002'],
          completed: true,
          completedAt: DateTime.now(),
          performanceScore: 0.82,
        );

        expect(session.category, 'vehicle-handling');
        expect(session.completed, true);
        expect(session.isOverdue, false);
        expect(session.performanceScore, 0.82);
      });

      test('identifies overdue sessions', () {
        final overdue = StudySession(
          id: 'sess_002',
          category: 'defensive-driving',
          scheduledDate: DateTime.now().subtract(const Duration(days: 2)),
          durationMinutes: 45,
          topicsToReview: ['hazard-identification'],
          questionIds: ['q_dd_001'],
          completed: false,
        );

        expect(overdue.isOverdue, true);
      });
    });

    group('PersonalizedTutorSession', () {
      test('manages tutoring session lifecycle', () {
        final session = PersonalizedTutorSession(
          id: 'tut_001',
          studentId: 'student_001',
          tutoringType: TutoringType.oneOnOne.toString(),
          category: 'emergency-procedures',
          focusTopics: ['accident-response'],
          startTime: DateTime.now(),
          status: TutoringSessionStatus.active,
          sessionDurationMinutes: 30,
          interactions: [],
          sessionProductivity: 0.0,
          nextRecommendedTopics: [],
        );

        expect(session.isActive, true);
        expect(session.elapsedMinutes, 0);
      });

      test('tracks tutoring interactions', () {
        final interaction = TutoringInteraction(
          id: 'int_001',
          questionId: 'q_001',
          studentResponse: 'Answer A',
          tutorFeedback: 'Good attempt, but consider the regulation...',
          hintLevel: HintLevel.intermediate,
          feedbackType: FeedbackType.progressive,
          isCorrect: false,
          timestamp: DateTime.now(),
          learningGain: 0.25,
        );

        expect(interaction.hintLevel, HintLevel.intermediate);
        expect(interaction.feedbackType, FeedbackType.progressive);
        expect(interaction.learningGain, 0.25);
      });
    });

    group('HintProgression', () {
      test('provides progressive hints', () {
        final hints = HintProgression(
          id: 'hint_001',
          questionId: 'q_001',
          hintsByLevel: [
            'Hint: Think about road safety',
            'Hint: Consider the sign color',
            'Hint: Red octagonal signs indicate...',
            'This is a stop sign indicating you must come to a complete stop',
          ],
          hintAccessTimes: [],
          maxHintsAllowed: 3,
          revealedFull: false,
        );

        expect(hints.hintsByLevel.length, 4);
        expect(hints.maxHintsAllowed, 3);
        expect(hints.getNextHint(), hints.hintsByLevel[0]);
      });
    });

    group('PerformanceFeedback', () {
      test('generates detailed performance feedback', () {
        final feedback = PerformanceFeedback(
          id: 'fb_001',
          studentId: 'student_001',
          sessionId: 'sess_001',
          accuracyImprovement: 15.5,
          correctAnswers: 18,
          totalAttempts: 20,
          strengths: ['Road signs knowledge', 'Quick decision making'],
          areasForImprovement: ['Vehicle handling', 'Weather conditions'],
          motivationalMessage: 'Great progress! Keep up the consistent practice.',
          suggestedNextSteps: ['Focus on vehicle handling', 'Review emergency procedures'],
          generatedAt: DateTime.now(),
        );

        expect(feedback.accuracyRate, 90.0);
        expect(feedback.strengths.length, 2);
        expect(feedback.areasForImprovement.length, 2);
      });
    });

    group('Enum Parsing', () {
      test('parses HintLevel correctly', () {
        expect(_parseHintLevel('basic'), HintLevel.basic);
        expect(_parseHintLevel('intermediate'), HintLevel.intermediate);
        expect(_parseHintLevel('detailed'), HintLevel.detailed);
        expect(_parseHintLevel('fullExplanation'), HintLevel.fullExplanation);
        expect(_parseHintLevel('invalid'), HintLevel.basic);
      });

      test('parses FeedbackType correctly', () {
        expect(_parseFeedbackType('positive'), FeedbackType.positive);
        expect(_parseFeedbackType('corrective'), FeedbackType.corrective);
        expect(_parseFeedbackType('progressive'), FeedbackType.progressive);
        expect(_parseFeedbackType('invalid'), FeedbackType.progressive);
      });

      test('parses TutoringSessionStatus correctly', () {
        expect(_parseTutoringSessionStatus('active'), TutoringSessionStatus.active);
        expect(_parseTutoringSessionStatus('completed'), TutoringSessionStatus.completed);
        expect(_parseTutoringSessionStatus('invalid'), TutoringSessionStatus.scheduled);
      });

      test('parses StudyPlanFrequency correctly', () {
        expect(_parseStudyPlanFrequency('daily'), StudyPlanFrequency.daily);
        expect(_parseStudyPlanFrequency('threeDaysWeek'), StudyPlanFrequency.threeDaysWeek);
        expect(_parseStudyPlanFrequency('invalid'), StudyPlanFrequency.daily);
      });

      test('parses OptimizationStrategy correctly', () {
        expect(_parseOptimizationStrategy('aggressive'), OptimizationStrategy.aggressive);
        expect(_parseOptimizationStrategy('balanced'), OptimizationStrategy.balanced);
        expect(_parseOptimizationStrategy('conservative'), OptimizationStrategy.conservative);
        expect(_parseOptimizationStrategy('invalid'), OptimizationStrategy.balanced);
      });
    });

    group('Integration Scenarios', () {
      test('creates and manages complete tutoring workflow', () {
        // Create plan
        final plan = AdaptiveStudyPlan(
          id: 'plan_001',
          studentId: 'student_001',
          startDate: DateTime.now(),
          targetExamDate: DateTime.now().add(const Duration(days: 30)),
          sessions: [
            StudySession(
              id: 'sess_001',
              category: 'road-signs',
              scheduledDate: DateTime.now(),
              durationMinutes: 45,
              topicsToReview: ['stop-signs'],
              questionIds: ['q_001', 'q_002'],
              completed: false,
            ),
          ],
          priorityCategories: ['road-signs'],
          estimatedTotalHours: 20,
          frequency: StudyPlanFrequency.daily,
          strategy: OptimizationStrategy.balanced,
          confidenceScore: 0.85,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(plan.sessions.isNotEmpty, true);

        // Start tutoring session
        final tutSession = PersonalizedTutorSession(
          id: 'tut_001',
          studentId: 'student_001',
          tutoringType: TutoringType.oneOnOne.toString(),
          category: 'road-signs',
          focusTopics: ['stop-signs'],
          startTime: DateTime.now(),
          status: TutoringSessionStatus.active,
          sessionDurationMinutes: 30,
          interactions: [],
          sessionProductivity: 0.0,
          nextRecommendedTopics: [],
        );

        expect(tutSession.isActive, true);

        // Add interaction
        final interaction = TutoringInteraction(
          id: 'int_001',
          questionId: 'q_001',
          studentResponse: 'Red octagon means stop',
          tutorFeedback: 'Correct!',
          hintLevel: HintLevel.basic,
          feedbackType: FeedbackType.positive,
          isCorrect: true,
          timestamp: DateTime.now(),
          learningGain: 0.5,
        );

        expect(interaction.isCorrect, true);

        // Generate feedback
        final feedback = PerformanceFeedback(
          id: 'fb_001',
          studentId: 'student_001',
          sessionId: 'tut_001',
          accuracyImprovement: 10.0,
          correctAnswers: 1,
          totalAttempts: 1,
          strengths: ['Quick response'],
          areasForImprovement: [],
          motivationalMessage: 'Excellent start!',
          suggestedNextSteps: ['Continue practicing'],
          generatedAt: DateTime.now(),
        );

        expect(feedback.accuracyRate, 100.0);
      });
    });
  });
}
