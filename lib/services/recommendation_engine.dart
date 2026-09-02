import 'package:flutter/foundation.dart';
import '../models/ai_recommendation_model.dart';
import 'package:collection/collection.dart';

/// AI推奨エンジン
/// 学生ごとに最適な学習推奨を生成
class RecommendationEngine {
  final Map<String, List<LearningRecommendation>> _recommendationCache = {};

  /// 学習推奨を生成
  Future<List<LearningRecommendation>> generateRecommendations({
    required String studentId,
    required Map<String, double> categoryScores,
    required List<String> recentlyMastered,
    required List<String> strugglingWith,
    required int hoursSinceLastStudy,
    required Map<String, int> categoryAttempts,
  }) async {
    try {
      final recommendations = <LearningRecommendation>[];

      // 1. 弱点集中推奨（優先度 10）
      for (final category in strugglingWith.take(2)) {
        final categoryScore = categoryScores[category] ?? 0;
        if (categoryScore < 60) {
          recommendations.add(
            LearningRecommendation(
              id: 'rec_${studentId}_${category}_focus',
              studentId: studentId,
              type: 'focus_area',
              contentId: category,
              contentTitle: '$category 集中レッスン',
              description: '正答率が低い分野を集中的に学習します',
              priority: 10,
              effectScore: 85 - categoryScore, // スコアが低いほど効果的
              reason:
                  '現在の正答率 ${categoryScore.toStringAsFixed(1)}% - 合格には 70% 以上が必要です',
              createdAt: DateTime.now(),
            ),
          );
        }
      }

      // 2. 復習推奨（優先度 8）
      if (hoursSinceLastStudy > 24) {
        for (final category in recentlyMastered.take(2)) {
          recommendations.add(
            LearningRecommendation(
              id: 'rec_${studentId}_${category}_review',
              studentId: studentId,
              type: 'review',
              contentId: category,
              contentTitle: '$category の復習',
              description: '忘却曲線に基づいた復習で知識を定着させます',
              priority: 8,
              effectScore: 75,
              reason: '${hoursSinceLastStudy} 時間勉強していません。記憶定着のために復習がお勧めです',
              createdAt: DateTime.now(),
            ),
          );
        }
      }

      // 3. グループ学習推奨（優先度 6）
      final groupLearningCategory = strugglingWith.isNotEmpty
          ? strugglingWith.first
          : categoryScores.entries
              .reduce((a, b) => a.value < b.value ? a : b)
              .key;
      recommendations.add(
        LearningRecommendation(
          id: 'rec_${studentId}_${groupLearningCategory}_group',
          studentId: studentId,
          type: 'group_study',
          contentId: groupLearningCategory,
          contentTitle: '$groupLearningCategory グループ学習セッション',
          description: 'エキスパートと初心者がペアになって学習します',
          priority: 6,
          effectScore: 70,
          reason:
              'グループ学習は理解を深め、モチベーション維持に効果的です',
          createdAt: DateTime.now(),
        ),
      );

      // 4. スキップ推奨（優先度 3）
      final masteredCategories = categoryScores.entries
          .where((e) => e.value >= 85)
          .take(1)
          .map((e) => e.key)
          .toList();
      if (masteredCategories.isNotEmpty) {
        final masteredCat = masteredCategories.first;
        recommendations.add(
          LearningRecommendation(
            id: 'rec_${studentId}_${masteredCat}_skip',
            studentId: studentId,
            type: 'skip',
            contentId: masteredCat,
            contentTitle: '$masteredCat は十分にマスター済み',
            description: 'この分野は十分な理解度に達しています',
            priority: 3,
            effectScore: 0, // スキップなので効果スコアは 0
            reason:
                '正答率 ${categoryScores[masteredCat]?.toStringAsFixed(1) ?? 'N/A'}% で十分です。他の分野に時間を使いましょう',
            createdAt: DateTime.now(),
          ),
        );
      }

      // キャッシュに保存
      _recommendationCache[studentId] = recommendations;
      return recommendations;
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'RecommendationEngine.generate');
      rethrow;
    }
  }

  /// スタック検出：成長停滞をリアルタイムで検出
  Future<StuckDetection?> detectStuck({
    required String studentId,
    required String categoryId,
    required List<bool> last30Answers, // 直近 30 個の回答（時系列）
    required int daysSinceProgress,
    required double accuracyRate,
  }) async {
    try {
      // 1. 停滞条件をチェック
      if (daysSinceProgress < 7) return null; // 7日未満なら停滞ではない

      // 2. 最近の正答率が低いかチェック
      if (accuracyRate > 60) return null; // 60% 以上なら改善中

      // 3. 正答パターンがフラットかチェック
      final recentAccuracy = last30Answers.isEmpty
          ? 0.0
          : last30Answers.where((e) => e).length / last30Answers.length;

      if (recentAccuracy > 0.55) return null; // 55% 以上なら停滞ではない

      // スタック検出
      final suggestedInterventions = [
        '別の学習教材を試してみましょう',
        'メンターに質問して理解を深めましょう',
        '簡単な問題から始めて自信を回復させましょう',
        '1日休んでリフレッシュしてから再開しましょう',
      ];

      return StuckDetection(
        studentId: studentId,
        categoryId: categoryId,
        dayCount: daysSinceProgress,
        accuracyRate: accuracyRate,
        problemCount: last30Answers.length,
        detectedAt: DateTime.now(),
        suggestedInterventions: suggestedInterventions,
      );
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'RecommendationEngine.detectStuck');
      return null;
    }
  }

  /// 代替学習法を提案
  Future<List<AlternativeLearningMethod>> suggestAlternativeMethods({
    required String studentId,
    required String categoryId,
    required String categoryName,
    required double currentAccuracy,
  }) async {
    try {
      final methods = <AlternativeLearningMethod>[];

      // 1. ビデオ学習法
      methods.add(
        AlternativeLearningMethod(
          id: 'alt_${studentId}_${categoryId}_video',
          studentId: studentId,
          categoryId: categoryId,
          methodType: 'video',
          description: '${categoryName}の概念説明ビデオを視聴',
          expectedEffectiveness: 75,
          reason: '動画による説明で視覚的な理解が進むことが多いです',
          suggestedAt: DateTime.now(),
        ),
      );

      // 2. 詳細解説法
      methods.add(
        AlternativeLearningMethod(
          id: 'alt_${studentId}_${categoryId}_explain',
          studentId: studentId,
          categoryId: categoryId,
          methodType: 'explanation',
          description: '専門家による詳細な解説を読む',
          expectedEffectiveness: 80,
          reason: '詳しい解説で背景知識が身につきます',
          suggestedAt: DateTime.now(),
        ),
      );

      // 3. 集中練習法
      methods.add(
        AlternativeLearningMethod(
          id: 'alt_${studentId}_${categoryId}_intensive',
          studentId: studentId,
          categoryId: categoryId,
          methodType: 'practice_intensive',
          description: '${categoryName}の集中練習コース（100問）',
          expectedEffectiveness: 85,
          reason: '同じ分野の多くの問題を解くことで理解が定着します',
          suggestedAt: DateTime.now(),
        ),
      );

      // 4. グループ学習法
      methods.add(
        AlternativeLearningMethod(
          id: 'alt_${studentId}_${categoryId}_group',
          studentId: studentId,
          categoryId: categoryId,
          methodType: 'groupwork',
          description: 'スタディグループでの協働学習',
          expectedEffectiveness: 70,
          reason: '他の学生との議論で新しい視点が得られます',
          suggestedAt: DateTime.now(),
        ),
      );

      return methods;
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'RecommendationEngine.suggestAlternative');
      rethrow;
    }
  }

  /// 復習スケジュールを生成（忘却曲線ベース）
  Future<List<ReviewSchedule>> generateReviewSchedules({
    required String studentId,
    required List<String> recentlyAnsweredQuestions,
    required Map<String, bool> questionAccuracyMap,
  }) async {
    try {
      final schedules = <ReviewSchedule>[];

      // Ebbinghaus の忘却曲線に基づく復習スケジュール
      const reviewIntervals = ['1day', '3days', '1week', '2weeks', '1month'];

      for (final questionId in recentlyAnsweredQuestions.take(20)) {
        final wasCorrect = questionAccuracyMap[questionId] ?? false;

        // 正解した問題は長めの間隔、不正解は短い間隔
        final intervalIndex = wasCorrect ? 2 : 0; // 1week vs 1day
        final interval = reviewIntervals[intervalIndex.clamp(0, 4)];

        // 次の復習日を計算
        final nextReviewDate = _calculateNextReviewDate(interval);

        schedules.add(
          ReviewSchedule(
            studentId: studentId,
            questionId: questionId,
            nextReviewDate: nextReviewDate,
            reviewCount: 0,
            interval: interval,
            retentionRate: wasCorrect ? 90 : 60,
            lastReviewedAt: DateTime.now(),
          ),
        );
      }

      return schedules;
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'RecommendationEngine.generateReview');
      rethrow;
    }
  }

  /// 次の復習日を計算
  DateTime _calculateNextReviewDate(String interval) {
    switch (interval) {
      case '1day':
        return DateTime.now().add(const Duration(days: 1));
      case '3days':
        return DateTime.now().add(const Duration(days: 3));
      case '1week':
        return DateTime.now().add(const Duration(days: 7));
      case '2weeks':
        return DateTime.now().add(const Duration(days: 14));
      case '1month':
        return DateTime.now().add(const Duration(days: 30));
      default:
        return DateTime.now().add(const Duration(days: 7));
    }
  }

  /// キャッシュのクリア
  void clearCache(String studentId) {
    _recommendationCache.remove(studentId);
  }

  /// 全キャッシュのクリア
  void clearAllCache() {
    _recommendationCache.clear();
  }
}
