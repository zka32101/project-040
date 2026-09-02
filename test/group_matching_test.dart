import 'package:flutter_test/flutter_test.dart';
import 'package:your_app_name/services/group_matching_service.dart';

void main() {
  group('GroupMatchingService Tests', () {
    late GroupMatchingService service;

    setUp(() {
      service = GroupMatchingService();
    });

    tearDown(() {
      service.clearAllCache();
    });

    // サンプル学生データ生成ヘルパー
    Map<String, dynamic> createStudentData({
      required String studentId,
      Map<String, double>? categoryScores,
      double velocity = 3.0,
      List<String>? weakCategories,
      List<String>? strongCategories,
    }) {
      return {
        'student_id': studentId,
        'average_score': categoryScores?.isEmpty ?? true
            ? 50
            : categoryScores!.values.reduce((a, b) => a + b) / categoryScores.length,
        'velocity': velocity,
        'weak_categories': weakCategories ?? ['math'],
        'strong_categories': strongCategories ?? ['english'],
        'category_scores': categoryScores ?? {'math': 40, 'english': 80},
      };
    }

    test('matchStudyGroup: Creates valid study group match', () async {
      final cohortStudents = [
        createStudentData(
          studentId: 'peer_001',
          categoryScores: {'math': 85, 'english': 50},
          weakCategories: ['english'],
          strongCategories: ['math'],
        ),
        createStudentData(
          studentId: 'peer_002',
          categoryScores: {'math': 50, 'english': 75},
          weakCategories: ['math'],
          strongCategories: ['english'],
        ),
      ];

      final match = await service.matchStudyGroup(
        studentId: 'student_001',
        categoryScores: {'math': 40, 'english': 80},
        totalQuestionsAttempted: 50,
        learningVelocity: 3.0,
        weakCategories: ['math'],
        strongCategories: ['english'],
        cohortStudents: cohortStudents,
      );

      expect(match, isNotNull);
      expect(match.studentId, 'student_001');
      expect(match.suggestedPeerIds, isNotEmpty);
      expect(match.compatibilityScore, greaterThanOrEqualTo(0));
      expect(match.compatibilityScore, lessThanOrEqualTo(100));
      expect(match.suggestedTopics, isA<List>());
    });

    test('matchStudyGroup: Identifies complementary peers', () async {
      // メンター：math 強、learner：math 弱
      final cohortStudents = [
        createStudentData(
          studentId: 'mentor_math',
          categoryScores: {'math': 95, 'english': 60},
          weakCategories: ['english'],
          strongCategories: ['math'],
        ),
        createStudentData(
          studentId: 'unrelated',
          categoryScores: {'science': 70},
          weakCategories: ['science'],
          strongCategories: ['history'],
        ),
      ];

      final match = await service.matchStudyGroup(
        studentId: 'learner_math',
        categoryScores: {'math': 30, 'english': 70},
        totalQuestionsAttempted: 40,
        learningVelocity: 2.5,
        weakCategories: ['math'],
        strongCategories: ['english'],
        cohortStudents: cohortStudents,
      );

      // メンターが提案されるべき
      expect(match.suggestedPeerIds, contains('mentor_math'));
    });

    test('matchStudyGroup: Returns effective topics for collaboration', () async {
      final cohortStudents = [
        createStudentData(
          studentId: 'peer_strong_math',
          categoryScores: {'math': 90},
          strongCategories: ['math'],
        ),
      ];

      final match = await service.matchStudyGroup(
        studentId: 'student_weak_math',
        categoryScores: {'math': 35},
        totalQuestionsAttempted: 30,
        learningVelocity: 2.0,
        weakCategories: ['math'],
        strongCategories: [],
        cohortStudents: cohortStudents,
      );

      // math がグループ学習効果的なトピックに含まれるはず
      expect(match.suggestedTopics, contains('math'));
    });

    test('createGroupSession: Creates valid session', () async {
      final session = await service.createGroupSession(
        studentIds: ['student_001', 'student_002'],
        topicId: 'topic_math_algebra',
        topicName: 'Algebra Fundamentals',
        estimatedDurationMinutes: 60,
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
        resourceUrls: ['https://example.com/resource1'],
      );

      expect(session, isNotNull);
      expect(session.studentIds, ['student_001', 'student_002']);
      expect(session.topicId, 'topic_math_algebra');
      expect(session.topicName, 'Algebra Fundamentals');
      expect(session.estimatedDurationMinutes, 60);
      expect(session.outcome, isNull); // 未開始
      expect(session.completedAt, isNull);
    });

    test('startGroupSession: Transitions session to in_progress', () async {
      final session = await service.createGroupSession(
        studentIds: ['student_001', 'student_002'],
        topicId: 'topic_test',
        topicName: 'Test Topic',
        estimatedDurationMinutes: 45,
        scheduledAt: DateTime.now(),
      );

      final startedSession = await service.startGroupSession(
        sessionId: session.id,
        studentIds: session.studentIds,
      );

      expect(startedSession.startedAt, isNotNull);
      expect(startedSession.outcome, 'in_progress');
    });

    test('completeGroupSession: Records completion with scores', () async {
      final session = await service.createGroupSession(
        studentIds: ['student_001', 'student_002'],
        topicId: 'topic_test',
        topicName: 'Test Topic',
        estimatedDurationMinutes: 45,
        scheduledAt: DateTime.now(),
      );

      final startedSession = await service.startGroupSession(
        sessionId: session.id,
        studentIds: session.studentIds,
      );

      final completedSession = await service.completeGroupSession(
        sessionId: startedSession.id,
        studentIds: startedSession.studentIds,
        studentScores: {
          'student_001': 85.0,
          'student_002': 78.0,
        },
        outcome: 'completed',
      );

      expect(completedSession.completedAt, isNotNull);
      expect(completedSession.outcome, 'completed');
      expect(completedSession.studentScores, isNotNull);
      expect(completedSession.studentScores!['student_001'], 85.0);
    });

    test('completeGroupSession: Validates score ranges', () async {
      final session = await service.createGroupSession(
        studentIds: ['student_001'],
        topicId: 'topic_test',
        topicName: 'Test',
        estimatedDurationMinutes: 30,
        scheduledAt: DateTime.now(),
      );

      expect(
        () => service.completeGroupSession(
          sessionId: session.id,
          studentIds: session.studentIds,
          studentScores: {'student_001': 150.0}, // 無効なスコア
          outcome: 'completed',
        ),
        throwsArgumentError,
      );
    });

    test('Cache functionality: Match is cached', () async {
      final cohortStudents = [
        createStudentData(
          studentId: 'peer_001',
          categoryScores: {'math': 85},
          strongCategories: ['math'],
        ),
      ];

      final match1 = await service.matchStudyGroup(
        studentId: 'student_cache',
        categoryScores: {'math': 40},
        totalQuestionsAttempted: 30,
        learningVelocity: 2.5,
        weakCategories: ['math'],
        strongCategories: [],
        cohortStudents: cohortStudents,
      );

      await Future.delayed(const Duration(milliseconds: 50));

      final match2 = await service.matchStudyGroup(
        studentId: 'student_cache',
        categoryScores: {'math': 40},
        totalQuestionsAttempted: 30,
        learningVelocity: 2.5,
        weakCategories: ['math'],
        strongCategories: [],
        cohortStudents: cohortStudents,
      );

      expect(match1.generatedAt, equals(match2.generatedAt));
    });

    test('getSessionHistory: Returns all sessions for student', () async {
      final studentIds = ['student_001', 'student_002'];

      final session1 = await service.createGroupSession(
        studentIds: studentIds,
        topicId: 'topic_1',
        topicName: 'Topic 1',
        estimatedDurationMinutes: 45,
        scheduledAt: DateTime.now(),
      );

      final session2 = await service.createGroupSession(
        studentIds: studentIds,
        topicId: 'topic_2',
        topicName: 'Topic 2',
        estimatedDurationMinutes: 60,
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
      );

      final history = service.getSessionHistory('student_001');

      expect(history.length, 2);
      expect(history.map((s) => s.id), contains(session1.id));
      expect(history.map((s) => s.id), contains(session2.id));
    });

    test('clearCache: Removes cached data for student', () async {
      final cohortStudents = [
        createStudentData(
          studentId: 'peer_001',
          categoryScores: {'math': 85},
          strongCategories: ['math'],
        ),
      ];

      final originalMatch = await service.matchStudyGroup(
        studentId: 'student_clear',
        categoryScores: {'math': 40},
        totalQuestionsAttempted: 30,
        learningVelocity: 2.5,
        weakCategories: ['math'],
        strongCategories: [],
        cohortStudents: cohortStudents,
      );

      service.clearCache('student_clear');

      await Future.delayed(const Duration(milliseconds: 100));

      final newMatch = await service.matchStudyGroup(
        studentId: 'student_clear',
        categoryScores: {'math': 40},
        totalQuestionsAttempted: 30,
        learningVelocity: 2.5,
        weakCategories: ['math'],
        strongCategories: [],
        cohortStudents: cohortStudents,
      );

      expect(newMatch.generatedAt, isAfter(originalMatch.generatedAt));
    });

    test('Compatibility scoring: Prefers complementary students', () async {
      // 完全に補完的なペア
      final complementaryPeers = [
        createStudentData(
          studentId: 'complement_peer',
          categoryScores: {'math': 90, 'english': 30},
          weakCategories: ['english'],
          strongCategories: ['math'],
        ),
      ];

      // 似たようなプロファイル
      final similarPeers = [
        createStudentData(
          studentId: 'similar_peer',
          categoryScores: {'math': 35, 'english': 85},
          weakCategories: ['math'],
          strongCategories: ['english'],
        ),
      ];

      final complementaryMatch = await service.matchStudyGroup(
        studentId: 'student_comp',
        categoryScores: {'math': 35, 'english': 85},
        totalQuestionsAttempted: 50,
        learningVelocity: 3.0,
        weakCategories: ['math'],
        strongCategories: ['english'],
        cohortStudents: complementaryPeers,
      );

      final similarMatch = await service.matchStudyGroup(
        studentId: 'student_sim',
        categoryScores: {'math': 35, 'english': 85},
        totalQuestionsAttempted: 50,
        learningVelocity: 3.0,
        weakCategories: ['math'],
        strongCategories: ['english'],
        cohortStudents: similarPeers,
      );

      // 補完的なペアの方が互換性が高いはず
      expect(
        complementaryMatch.compatibilityScore,
        greaterThan(similarMatch.compatibilityScore),
      );
    });
  });
}
