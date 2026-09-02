import 'package:flutter/foundation.dart';
import '../models/ai_recommendation_model.dart';
import '../models/community_model.dart';
import 'package:collection/collection.dart';

/// 適応的学習パスエンジン
/// 学生の進度と弱点に応じて動的に学習経路を生成
class AdaptiveLearningService {
  final Map<String, AdaptiveLearningPath> _pathCache = {};
  final Map<String, DifficultyAdjustment> _difficultyCache = {};

  /// 学習パス生成：学生の進度と弱点から個別最適化された学習順序を計算
  Future<AdaptiveLearningPath> generateAdaptivePath({
    required String studentId,
    required List<CategoryPerformance> categoryPerformances,
    required int targetQuestionsPerDay,
    required DateTime targetCompletionDate,
  }) async {
    // キャッシュから取得
    if (_pathCache.containsKey(studentId)) {
      return _pathCache[studentId]!;
    }

    try {
      // 1. 学生の弱点カテゴリを特定
      final weakAreas = _identifyWeakAreas(categoryPerformances);
      final strongAreas = _identifyStrongAreas(categoryPerformances);

      // 2. 学習優先度を計算
      final prioritizedCategories = _prioritizeCategories(
        weak: weakAreas,
        strong: strongAreas,
        targetCompletion: targetCompletionDate,
      );

      // 3. 学習パス要素を生成
      final elements = await _generatePathElements(
        studentId: studentId,
        prioritizedCategories: prioritizedCategories,
        targetQuestionsPerDay: targetQuestionsPerDay,
      );

      // 4. パス全体の統計を計算
      final estimatedTime = _estimateCompletionTime(
        elements: elements,
        targetQuestionsPerDay: targetQuestionsPerDay,
      );

      final path = AdaptiveLearningPath(
        studentId: studentId,
        elements: elements,
        generatedAt: DateTime.now(),
        generationReason:
            '弱点分析に基づく ${weakAreas.length} 個の強化カテゴリを含む最適化パス',
        estimatedCompletionTime: estimatedTime,
        currentElementIndex: 0,
        isActive: true,
      );

      // キャッシュに保存
      _pathCache[studentId] = path;
      return path;
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'AdaptiveLearningService.generatePath');
      rethrow;
    }
  }

  /// 難度調整：学生の正答率に基づいてリアルタイムで問題難度を調整
  Future<int> adjustDifficulty({
    required String studentId,
    required String categoryId,
    required bool lastAnswerCorrect,
    required double currentAccuracyRate,
    required int currentDifficultyLevel, // 1-5
  }) async {
    try {
      // 1. 調整戦略を決定
      final strategy = _determineAdjustmentStrategy(currentAccuracyRate);

      // 2. 新しい難度を計算
      int newDifficulty = currentDifficultyLevel;

      if (strategy == 'aggressive') {
        // 高い正答率 (>80%) → 難度アップ
        // 低い正答率 (<50%) → 難度ダウン
        if (currentAccuracyRate > 80) {
          newDifficulty = (currentDifficultyLevel + 1).clamp(1, 5);
        } else if (currentAccuracyRate < 50) {
          newDifficulty = (currentDifficultyLevel - 1).clamp(1, 5);
        }
      } else if (strategy == 'moderate') {
        // 中程度の調整
        if (currentAccuracyRate > 85 && lastAnswerCorrect) {
          newDifficulty = (currentDifficultyLevel + 1).clamp(1, 5);
        } else if (currentAccuracyRate < 40 && !lastAnswerCorrect) {
          newDifficulty = (currentDifficultyLevel - 1).clamp(1, 5);
        }
      }
      // conservative: ほぼ変わらない

      // 3. キャッシュを更新
      _updateDifficultyCache(studentId, categoryId, newDifficulty);

      return newDifficulty;
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'AdaptiveLearningService.adjustDifficulty');
      rethrow;
    }
  }

  /// 弱点カテゴリの特定
  List<String> _identifyWeakAreas(
    List<CategoryPerformance> performances,
  ) {
    return performances
        .where((p) => (p.averageScore ?? 0) < 60) // スコア 60% 未満
        .map((p) => p.categoryId)
        .toList();
  }

  /// 強い分野の特定
  List<String> _identifyStrongAreas(
    List<CategoryPerformance> performances,
  ) {
    return performances
        .where((p) => (p.averageScore ?? 0) >= 80) // スコア 80% 以上
        .map((p) => p.categoryId)
        .toList();
  }

  /// カテゴリ優先度の計算
  List<({String categoryId, int priority, String reason})> _prioritizeCategories({
    required List<String> weak,
    required List<String> strong,
    required DateTime targetCompletion,
  }) {
    final result = <({String categoryId, int priority, String reason})>[];

    // 弱点を最優先（優先度 10-8）
    for (var i = 0; i < weak.length; i++) {
      result.add((
        categoryId: weak[i],
        priority: 10 - (i * 2 ~/ weak.length),
        reason: '弱点分野の集中強化',
      ));
    }

    // 中程度の分野（優先度 5-6）
    // 強い分野（優先度 2-3、保持学習）

    return result;
  }

  /// 学習パス要素の生成
  Future<List<LearningPathElement>> _generatePathElements({
    required String studentId,
    required List<({String categoryId, int priority, String reason})> prioritizedCategories,
    required int targetQuestionsPerDay,
  }) async {
    final elements = <LearningPathElement>[];
    int elementIndex = 0;

    for (final category in prioritizedCategories) {
      // 各カテゴリから問題をセレクト（概念的なデモ）
      for (int i = 0; i < 5; i++) {
        final difficulty = 2 + (i ~/ 2); // 段階的に難度を上げる
        final element = LearningPathElement(
          id: 'element_${studentId}_$elementIndex',
          questionId: 'q_${category.categoryId}_$i',
          categoryId: category.categoryId,
          subcategoryId: 'sub_${category.categoryId}',
          difficulty: difficulty.clamp(1, 5),
          rationale: category.reason,
          recommendedAt: DateTime.now().add(Duration(hours: elementIndex ~/ targetQuestionsPerDay)),
          completedAt: null,
          passed: null,
        );
        elements.add(element);
        elementIndex++;
      }
    }

    return elements;
  }

  /// 修了予定時間の推定
  double _estimateCompletionTime({
    required List<LearningPathElement> elements,
    required int targetQuestionsPerDay,
  }) {
    // 1問あたり 3-5 分と仮定
    const minutesPerQuestion = 4.0;
    final totalMinutes = elements.length * minutesPerQuestion;
    const hoursPerDay = 1.0; // 1日に割ける学習時間
    return (totalMinutes / 60) / hoursPerDay;
  }

  /// 調整戦略の決定
  String _determineAdjustmentStrategy(double accuracyRate) {
    if (accuracyRate > 75) return 'aggressive';
    if (accuracyRate > 50) return 'moderate';
    return 'conservative';
  }

  /// 難度キャッシュの更新
  void _updateDifficultyCache(
    String studentId,
    String categoryId,
    int newDifficulty,
  ) {
    final adjustment = _difficultyCache[studentId];
    if (adjustment != null) {
      final updated = adjustment.categoryLevels;
      updated[categoryId] = DifficultyLevel(
        categoryId: categoryId,
        currentLevel: newDifficulty,
        accuracyRate: 0, // 更新時に実際の値で上書きされる
        questionCount: 0,
        lastUpdatedAt: DateTime.now(),
      );
    }
  }

  /// 次問の推奨
  Future<String?> recommendNextQuestion({
    required String studentId,
    required AdaptiveLearningPath currentPath,
    required Map<String, double> categoryAccuracyMap,
  }) async {
    try {
      if (currentPath.currentElementIndex == null ||
          currentPath.currentElementIndex! >= currentPath.elements.length) {
        return null; // パス完了
      }

      final element = currentPath.elements[currentPath.currentElementIndex!];
      return element.questionId;
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'AdaptiveLearningService.recommendNext');
      return null;
    }
  }

  /// キャッシュのクリア
  void clearCache(String studentId) {
    _pathCache.remove(studentId);
    _difficultyCache.remove(studentId);
  }

  /// 全キャッシュのクリア
  void clearAllCache() {
    _pathCache.clear();
    _difficultyCache.clear();
  }
}
