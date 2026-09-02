import 'package:riverpod/riverpod.dart';
import '../models/ai_recommendation_model.dart';
import '../models/community_model.dart';
import '../services/adaptive_learning_service.dart';
import '../services/ml_predictor_service.dart';
import '../services/recommendation_engine.dart';
import '../services/group_matching_service.dart';

// ============================================================================
// サービスプロバイダー
// ============================================================================

/// 適応的学習パスエンジンプロバイダー
final adaptiveLearningServiceProvider = Provider<AdaptiveLearningService>((ref) {
  return AdaptiveLearningService();
});

/// ML予測エンジンプロバイダー
final mlPredictorServiceProvider = Provider<MLPredictorService>((ref) {
  return MLPredictorService();
});

/// レコメンデーションエンジンプロバイダー
final recommendationEngineProvider = Provider<RecommendationEngine>((ref) {
  return RecommendationEngine();
});

/// グループマッチングサービスプロバイダー
final groupMatchingServiceProvider = Provider<GroupMatchingService>((ref) {
  return GroupMatchingService();
});

// ============================================================================
// 適応的学習パスプロバイダー
// ============================================================================

/// 学習パス生成パラメータ
class AdaptivePathParams {
  final String studentId;
  final List<CategoryPerformance> categoryPerformances;
  final int targetQuestionsPerDay;
  final DateTime targetCompletionDate;

  AdaptivePathParams({
    required this.studentId,
    required this.categoryPerformances,
    required this.targetQuestionsPerDay,
    required this.targetCompletionDate,
  });
}

/// 学習パス取得プロバイダー
final adaptivePathProvider =
    FutureProvider.family<AdaptiveLearningPath, AdaptivePathParams>(
  (ref, params) async {
    final service = ref.watch(adaptiveLearningServiceProvider);
    return service.generateAdaptivePath(
      studentId: params.studentId,
      categoryPerformances: params.categoryPerformances,
      targetQuestionsPerDay: params.targetQuestionsPerDay,
      targetCompletionDate: params.targetCompletionDate,
    );
  },
);

// ============================================================================
// 難度調整プロバイダー
// ============================================================================

/// 難度調整パラメータ
class DifficultyAdjustParams {
  final String studentId;
  final String categoryId;
  final bool lastAnswerCorrect;
  final double currentAccuracyRate;
  final int currentDifficultyLevel;

  DifficultyAdjustParams({
    required this.studentId,
    required this.categoryId,
    required this.lastAnswerCorrect,
    required this.currentAccuracyRate,
    required this.currentDifficultyLevel,
  });
}

/// 難度調整プロバイダー
final difficultyAdjustProvider =
    FutureProvider.family<int, DifficultyAdjustParams>(
  (ref, params) async {
    final service = ref.watch(adaptiveLearningServiceProvider);
    return service.adjustDifficulty(
      studentId: params.studentId,
      categoryId: params.categoryId,
      lastAnswerCorrect: params.lastAnswerCorrect,
      currentAccuracyRate: params.currentAccuracyRate,
      currentDifficultyLevel: params.currentDifficultyLevel,
    );
  },
);

// ============================================================================
// 学習効果予測プロバイダー
// ============================================================================

/// 学習効果予測パラメータ
class PredictionParams {
  final String studentId;
  final double currentScore;
  final int questionsAttempted;
  final int correctAnswers;
  final int totalQuestions;
  final DateTime enrollmentDate;
  final DateTime? targetDate;
  final Map<String, double> categoryScores;

  PredictionParams({
    required this.studentId,
    required this.currentScore,
    required this.questionsAttempted,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.enrollmentDate,
    this.targetDate,
    required this.categoryScores,
  });
}

/// 学習効果予測プロバイダー
final learningEffectPredictionProvider =
    FutureProvider.family<LearningEffectPrediction, PredictionParams>(
  (ref, params) async {
    final service = ref.watch(mlPredictorServiceProvider);
    return service.predictLearningEffect(
      studentId: params.studentId,
      currentScore: params.currentScore,
      questionsAttempted: params.questionsAttempted,
      correctAnswers: params.correctAnswers,
      totalQuestions: params.totalQuestions,
      enrollmentDate: params.enrollmentDate,
      targetDate: params.targetDate,
      categoryScores: params.categoryScores,
    );
  },
);

// ============================================================================
// 脱落リスク検出プロバイダー
// ============================================================================

/// 脱落リスク検出パラメータ
class DropoutRiskParams {
  final String studentId;
  final double currentScore;
  final int daysSinceLastActivity;
  final int missedDays;
  final Map<String, double> categoryScores;
  final int loginStreak;
  final List<String> previousUserFeedback;

  DropoutRiskParams({
    required this.studentId,
    required this.currentScore,
    required this.daysSinceLastActivity,
    required this.missedDays,
    required this.categoryScores,
    required this.loginStreak,
    required this.previousUserFeedback,
  });
}

/// 脱落リスク検出プロバイダー
final dropoutRiskProvider =
    FutureProvider.family<DropoutRiskDetection, DropoutRiskParams>(
  (ref, params) async {
    final service = ref.watch(mlPredictorServiceProvider);
    return service.detectDropoutRisk(
      studentId: params.studentId,
      currentScore: params.currentScore,
      daysSinceLastActivity: params.daysSinceLastActivity,
      missedDays: params.missedDays,
      categoryScores: params.categoryScores,
      loginStreak: params.loginStreak,
      previousUserFeedback: params.previousUserFeedback,
    );
  },
);

// ============================================================================
// 学習推奨プロバイダー
// ============================================================================

/// 推奨生成パラメータ
class RecommendationParams {
  final String studentId;
  final Map<String, double> categoryScores;
  final List<String> recentlyMastered;
  final List<String> strugglingWith;
  final int hoursSinceLastStudy;
  final Map<String, int> categoryAttempts;

  RecommendationParams({
    required this.studentId,
    required this.categoryScores,
    required this.recentlyMastered,
    required this.strugglingWith,
    required this.hoursSinceLastStudy,
    required this.categoryAttempts,
  });
}

/// 推奨生成プロバイダー
final recommendationsProvider =
    FutureProvider.family<List<LearningRecommendation>, RecommendationParams>(
  (ref, params) async {
    final engine = ref.watch(recommendationEngineProvider);
    return engine.generateRecommendations(
      studentId: params.studentId,
      categoryScores: params.categoryScores,
      recentlyMastered: params.recentlyMastered,
      strugglingWith: params.strugglingWith,
      hoursSinceLastStudy: params.hoursSinceLastStudy,
      categoryAttempts: params.categoryAttempts,
    );
  },
);

// ============================================================================
// グループマッチングプロバイダー
// ============================================================================

/// グループマッチングパラメータ
class GroupMatchParams {
  final String studentId;
  final Map<String, double> categoryScores;
  final int totalQuestionsAttempted;
  final double learningVelocity;
  final List<String> weakCategories;
  final List<String> strongCategories;
  final List<Map<String, dynamic>> cohortStudents;

  GroupMatchParams({
    required this.studentId,
    required this.categoryScores,
    required this.totalQuestionsAttempted,
    required this.learningVelocity,
    required this.weakCategories,
    required this.strongCategories,
    required this.cohortStudents,
  });
}

/// グループマッチングプロバイダー
final groupMatchProvider =
    FutureProvider.family<StudyGroupMatch, GroupMatchParams>(
  (ref, params) async {
    final service = ref.watch(groupMatchingServiceProvider);
    return service.matchStudyGroup(
      studentId: params.studentId,
      categoryScores: params.categoryScores,
      totalQuestionsAttempted: params.totalQuestionsAttempted,
      learningVelocity: params.learningVelocity,
      weakCategories: params.weakCategories,
      strongCategories: params.strongCategories,
      cohortStudents: params.cohortStudents,
    );
  },
);

// ============================================================================
// 統合ダッシュボードプロバイダー
// ============================================================================

/// 統合学習分析ダッシュボードデータ
class AdaptiveLearningDashboardData {
  final AdaptiveLearningPath? learningPath;
  final LearningEffectPrediction? prediction;
  final DropoutRiskDetection? riskDetection;
  final List<LearningRecommendation>? recommendations;
  final StudyGroupMatch? groupMatch;
  final String? errorMessage;

  AdaptiveLearningDashboardData({
    this.learningPath,
    this.prediction,
    this.riskDetection,
    this.recommendations,
    this.groupMatch,
    this.errorMessage,
  });

  bool get isLoading => false; // 個別の Future が loading を管理
  bool get hasError => errorMessage != null;
}

/// 統合ダッシュボードプロバイダー
final adaptiveLearningDashboardProvider =
    FutureProvider.family<AdaptiveLearningDashboardData, String>(
  (ref, studentId) async {
    try {
      // 各プロバイダーから必要なデータを取得
      // 注：実装時に、実際の学生データを取得して各プロバイダーを呼び出す

      return AdaptiveLearningDashboardData(
        errorMessage: 'ダッシュボードデータ構築中...',
      );
    } catch (e) {
      return AdaptiveLearningDashboardData(
        errorMessage: 'ダッシュボード読み込みエラー: $e',
      );
    }
  },
);

// ============================================================================
// ユーティリティプロバイダー
// ============================================================================

/// スタック検出パラメータ
class StuckDetectionParams {
  final String studentId;
  final String categoryId;
  final List<bool> last30Answers;
  final int daysSinceProgress;
  final double accuracyRate;

  StuckDetectionParams({
    required this.studentId,
    required this.categoryId,
    required this.last30Answers,
    required this.daysSinceProgress,
    required this.accuracyRate,
  });
}

/// スタック検出プロバイダー
final stuckDetectionProvider =
    FutureProvider.family<StuckDetection?, StuckDetectionParams>(
  (ref, params) async {
    final engine = ref.watch(recommendationEngineProvider);
    return engine.detectStuck(
      studentId: params.studentId,
      categoryId: params.categoryId,
      last30Answers: params.last30Answers,
      daysSinceProgress: params.daysSinceProgress,
      accuracyRate: params.accuracyRate,
    );
  },
);

/// 代替学習法提案プロバイダー
final alternativeMethodsProvider =
    FutureProvider.family<List<AlternativeLearningMethod>,
      (String, String, String, double)>(
  (ref, params) async {
    final (studentId, categoryId, categoryName, accuracy) = params;
    final engine = ref.watch(recommendationEngineProvider);
    return engine.suggestAlternativeMethods(
      studentId: studentId,
      categoryId: categoryId,
      categoryName: categoryName,
      currentAccuracy: accuracy,
    );
  },
);

/// 復習スケジュール生成プロバイダー
final reviewScheduleProvider =
    FutureProvider.family<List<ReviewSchedule>,
      (String, List<String>, Map<String, bool>)>(
  (ref, params) async {
    final (studentId, questions, accuracy) = params;
    final engine = ref.watch(recommendationEngineProvider);
    return engine.generateReviewSchedules(
      studentId: studentId,
      recentlyAnsweredQuestions: questions,
      questionAccuracyMap: accuracy,
    );
  },
);
