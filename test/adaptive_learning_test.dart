import 'package:flutter_test/flutter_test.dart';
import 'package:your_app_name/models/ai_recommendation_model.dart';
import 'package:your_app_name/models/community_model.dart';
import 'package:your_app_name/services/adaptive_learning_service.dart';

void main() {
  group('AdaptiveLearningService Tests', () {
    late AdaptiveLearningService service;

    setUp(() {
      service = AdaptiveLearningService();
    });

    tearDown(() {
      service.clearAllCache();
    });

    test('generateAdaptivePath: Creates valid learning path', () async {
      // 学生のパフォーマンスデータを準備
      final categoryPerformances = [
        CategoryPerformance(
          categoryId: 'category_1',
          categoryName: 'Traffic Rules',
          totalQuestionsAttempted: 30,
          correctAnswers: 18, // 60%
          averageScore: 60,
          lastAttemptedAt: DateTime.now(),
        ),
        CategoryPerformance(
          categoryId: 'category_2',
          categoryName: 'Road Signs',
          totalQuestionsAttempted: 25,
          correctAnswers: 22, // 88%
          averageScore: 88,
          lastAttemptedAt: DateTime.now(),
        ),
      ];

      // 学習パスを生成
      final path = await service.generateAdaptivePath(
        studentId: 'student_123',
        categoryPerformances: categoryPerformances,
        targetQuestionsPerDay: 10,
        targetCompletionDate: DateTime.now().add(const Duration(days: 30)),
      );

      // 検証
      expect(path, isNotNull);
      expect(path.studentId, 'student_123');
      expect(path.elements, isNotEmpty);
      expect(path.estimatedCompletionTime, greaterThan(0));
      expect(path.isActive, true);
    });

    test('generateAdaptivePath: Prioritizes weak areas', () async {
      final categoryPerformances = [
        CategoryPerformance(
          categoryId: 'weak_area',
          categoryName: 'Weak Topic',
          totalQuestionsAttempted: 20,
          correctAnswers: 10, // 50%
          averageScore: 50,
          lastAttemptedAt: DateTime.now(),
        ),
        CategoryPerformance(
          categoryId: 'strong_area',
          categoryName: 'Strong Topic',
          totalQuestionsAttempted: 20,
          correctAnswers: 19, // 95%
          averageScore: 95,
          lastAttemptedAt: DateTime.now(),
        ),
      ];

      final path = await service.generateAdaptivePath(
        studentId: 'student_456',
        categoryPerformances: categoryPerformances,
        targetQuestionsPerDay: 5,
        targetCompletionDate: DateTime.now().add(const Duration(days: 14)),
      );

      // 弱点エリアがパスに含まれているかチェック
      final weakAreaElements =
          path.elements.where((e) => e.categoryId == 'weak_area').toList();
      expect(weakAreaElements, isNotEmpty);
    });

    test('adjustDifficulty: Increases difficulty with high accuracy', () async {
      final newDifficulty = await service.adjustDifficulty(
        studentId: 'student_789',
        categoryId: 'category_math',
        lastAnswerCorrect: true,
        currentAccuracyRate: 85,
        currentDifficultyLevel: 2,
      );

      // 高い正答率なので難度が上がるはず
      expect(newDifficulty, greaterThan(2));
    });

    test('adjustDifficulty: Decreases difficulty with low accuracy', () async {
      final newDifficulty = await service.adjustDifficulty(
        studentId: 'student_789',
        categoryId: 'category_math',
        lastAnswerCorrect: false,
        currentAccuracyRate: 35,
        currentDifficultyLevel: 4,
      );

      // 低い正答率なので難度が下がるはず
      expect(newDifficulty, lessThan(4));
    });

    test('adjustDifficulty: Respects min/max bounds', () async {
      final newDifficultyMax = await service.adjustDifficulty(
        studentId: 'student_max',
        categoryId: 'category_test',
        lastAnswerCorrect: true,
        currentAccuracyRate: 95,
        currentDifficultyLevel: 5,
      );
      expect(newDifficultyMax, lessThanOrEqualTo(5));

      final newDifficultyMin = await service.adjustDifficulty(
        studentId: 'student_min',
        categoryId: 'category_test',
        lastAnswerCorrect: false,
        currentAccuracyRate: 20,
        currentDifficultyLevel: 1,
      );
      expect(newDifficultyMin, greaterThanOrEqualTo(1));
    });

    test('recommendNextQuestion: Returns valid question ID', () async {
      final categoryPerformances = [
        CategoryPerformance(
          categoryId: 'cat_1',
          categoryName: 'Test',
          totalQuestionsAttempted: 10,
          correctAnswers: 7,
          averageScore: 70,
          lastAttemptedAt: DateTime.now(),
        ),
      ];

      final path = await service.generateAdaptivePath(
        studentId: 'student_next',
        categoryPerformances: categoryPerformances,
        targetQuestionsPerDay: 5,
        targetCompletionDate: DateTime.now().add(const Duration(days: 30)),
      );

      final nextQuestionId = await service.recommendNextQuestion(
        studentId: 'student_next',
        currentPath: path,
        categoryAccuracyMap: {'cat_1': 70},
      );

      expect(nextQuestionId, isNotNull);
      expect(nextQuestionId, startsWith('q_'));
    });

    test('Cache functionality: Path is cached after first generation', () async {
      final categoryPerformances = [
        CategoryPerformance(
          categoryId: 'cat_cache',
          categoryName: 'Cache Test',
          totalQuestionsAttempted: 15,
          correctAnswers: 10,
          averageScore: 67,
          lastAttemptedAt: DateTime.now(),
        ),
      ];

      final path1 = await service.generateAdaptivePath(
        studentId: 'student_cache',
        categoryPerformances: categoryPerformances,
        targetQuestionsPerDay: 5,
        targetCompletionDate: DateTime.now().add(const Duration(days: 30)),
      );

      // キャッシュから取得される
      final path2 = await service.generateAdaptivePath(
        studentId: 'student_cache',
        categoryPerformances: categoryPerformances,
        targetQuestionsPerDay: 5,
        targetCompletionDate: DateTime.now().add(const Duration(days: 30)),
      );

      expect(path1.generatedAt, equals(path2.generatedAt));
    });

    test('Cache clearing: clearCache removes student cache', () async {
      final categoryPerformances = [
        CategoryPerformance(
          categoryId: 'cat_clear',
          categoryName: 'Clear Test',
          totalQuestionsAttempted: 20,
          correctAnswers: 15,
          averageScore: 75,
          lastAttemptedAt: DateTime.now(),
        ),
      ];

      final originalPath = await service.generateAdaptivePath(
        studentId: 'student_clear',
        categoryPerformances: categoryPerformances,
        targetQuestionsPerDay: 5,
        targetCompletionDate: DateTime.now().add(const Duration(days: 30)),
      );

      service.clearCache('student_clear');

      // Wait a bit to ensure timestamp difference
      await Future.delayed(const Duration(milliseconds: 100));

      final newPath = await service.generateAdaptivePath(
        studentId: 'student_clear',
        categoryPerformances: categoryPerformances,
        targetQuestionsPerDay: 5,
        targetCompletionDate: DateTime.now().add(const Duration(days: 30)),
      );

      expect(newPath.generatedAt, isAfter(originalPath.generatedAt));
    });
  });
}
