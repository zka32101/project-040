/// Phase 45: User Feedback & Rating System Service層
///
/// フィードバック・レポート・分析エンジン実装

import '../models/feedback_models.dart';

// ======================== Repository パターン ========================

/// フィードバックリポジトリインターフェース
abstract class FeedbackRepository {
  Future<void> addFeedback(UserFeedback feedback);
  Future<UserFeedback?> getFeedback(String feedbackId);
  Future<List<UserFeedback>> getUserFeedbacks(String userId);
  Future<List<UserFeedback>> getFeedbacksByType(FeedbackType type);
  Future<List<UserFeedback>> getFeedbacksByStatus(FeedbackStatus status);
  Future<void> updateFeedbackStatus(String feedbackId, FeedbackStatus status);
  Future<void> incrementHelpfulCount(String feedbackId);
  Future<void> incrementNotHelpfulCount(String feedbackId);
  Future<void> addRating(AppRating rating);
  Future<AppRating?> getRating(String ratingId);
  Future<List<AppRating>> getUserRatings(String userId);
  Future<double> getAverageRating();
  Future<void> addReviewComment(ReviewComment comment);
  Future<List<ReviewComment>> getReviewComments(String reviewId);
  Future<void> addSentimentAnalysis(SentimentAnalysis analysis);
  Future<SentimentAnalysis?> getSentimentAnalysis(String analysisId);
  Future<List<SentimentAnalysis>> getFeedbackSentiments(String feedbackId);
  Future<void> clearAll();
}

/// メモリベースのフィードバックリポジトリ実装
class MemoryFeedbackRepository implements FeedbackRepository {
  final Map<String, UserFeedback> _feedbacks = {};
  final Map<String, AppRating> _ratings = {};
  final Map<String, ReviewComment> _comments = {};
  final Map<String, SentimentAnalysis> _sentiments = {};

  @override
  Future<void> addFeedback(UserFeedback feedback) async {
    _feedbacks[feedback.feedbackId] = feedback;
  }

  @override
  Future<UserFeedback?> getFeedback(String feedbackId) async {
    return _feedbacks[feedbackId];
  }

  @override
  Future<List<UserFeedback>> getUserFeedbacks(String userId) async {
    return _feedbacks.values
        .where((f) => f.userId == userId)
        .toList();
  }

  @override
  Future<List<UserFeedback>> getFeedbacksByType(FeedbackType type) async {
    return _feedbacks.values
        .where((f) => f.type == type)
        .toList();
  }

  @override
  Future<List<UserFeedback>> getFeedbacksByStatus(FeedbackStatus status) async {
    return _feedbacks.values
        .where((f) => f.status == status)
        .toList();
  }

  @override
  Future<void> updateFeedbackStatus(String feedbackId, FeedbackStatus status) async {
    final feedback = _feedbacks[feedbackId];
    if (feedback != null) {
      _feedbacks[feedbackId] = UserFeedback(
        feedbackId: feedback.feedbackId,
        userId: feedback.userId,
        title: feedback.title,
        description: feedback.description,
        type: feedback.type,
        status: status,
        rating: feedback.rating,
        tags: feedback.tags,
        metadata: feedback.metadata,
        createdAt: feedback.createdAt,
        updatedAt: DateTime.now(),
        helpfulCount: feedback.helpfulCount,
        notHelpfulCount: feedback.notHelpfulCount,
      );
    }
  }

  @override
  Future<void> incrementHelpfulCount(String feedbackId) async {
    final feedback = _feedbacks[feedbackId];
    if (feedback != null) {
      _feedbacks[feedbackId] = UserFeedback(
        feedbackId: feedback.feedbackId,
        userId: feedback.userId,
        title: feedback.title,
        description: feedback.description,
        type: feedback.type,
        status: feedback.status,
        rating: feedback.rating,
        tags: feedback.tags,
        metadata: feedback.metadata,
        createdAt: feedback.createdAt,
        updatedAt: feedback.updatedAt,
        helpfulCount: feedback.helpfulCount + 1,
        notHelpfulCount: feedback.notHelpfulCount,
      );
    }
  }

  @override
  Future<void> incrementNotHelpfulCount(String feedbackId) async {
    final feedback = _feedbacks[feedbackId];
    if (feedback != null) {
      _feedbacks[feedbackId] = UserFeedback(
        feedbackId: feedback.feedbackId,
        userId: feedback.userId,
        title: feedback.title,
        description: feedback.description,
        type: feedback.type,
        status: feedback.status,
        rating: feedback.rating,
        tags: feedback.tags,
        metadata: feedback.metadata,
        createdAt: feedback.createdAt,
        updatedAt: feedback.updatedAt,
        helpfulCount: feedback.helpfulCount,
        notHelpfulCount: feedback.notHelpfulCount + 1,
      );
    }
  }

  @override
  Future<void> addRating(AppRating rating) async {
    _ratings[rating.ratingId] = rating;
  }

  @override
  Future<AppRating?> getRating(String ratingId) async {
    return _ratings[ratingId];
  }

  @override
  Future<List<AppRating>> getUserRatings(String userId) async {
    return _ratings.values
        .where((r) => r.userId == userId)
        .toList();
  }

  @override
  Future<double> getAverageRating() async {
    if (_ratings.isEmpty) return 0.0;
    final total = _ratings.values.fold<int>(0, (sum, r) => sum + r.stars);
    return total / _ratings.length;
  }

  @override
  Future<void> addReviewComment(ReviewComment comment) async {
    _comments[comment.commentId] = comment;
  }

  @override
  Future<List<ReviewComment>> getReviewComments(String reviewId) async {
    return _comments.values
        .where((c) => c.reviewId == reviewId)
        .toList();
  }

  @override
  Future<void> addSentimentAnalysis(SentimentAnalysis analysis) async {
    _sentiments[analysis.analysisId] = analysis;
  }

  @override
  Future<SentimentAnalysis?> getSentimentAnalysis(String analysisId) async {
    return _sentiments[analysisId];
  }

  @override
  Future<List<SentimentAnalysis>> getFeedbackSentiments(String feedbackId) async {
    return _sentiments.values
        .where((s) => s.feedbackId == feedbackId)
        .toList();
  }

  @override
  Future<void> clearAll() async {
    _feedbacks.clear();
    _ratings.clear();
    _comments.clear();
    _sentiments.clear();
  }
}

// ======================== Engine パターン ========================

/// センチメント分析エンジンインターフェース
abstract class SentimentAnalysisEngine {
  Future<Sentiment> analyzeSentiment(String text);
  Future<double> calculateConfidence(String text, Sentiment sentiment);
  Future<List<String>> extractKeywords(String text);
  Future<String> generateSummary(String text, Sentiment sentiment);
  Future<SentimentAnalysis> performFullAnalysis(
    String analysisId,
    String feedbackId,
    String text,
  );
}

/// メモリベースのセンチメント分析エンジン実装
class MemorySentimentAnalysisEngine implements SentimentAnalysisEngine {
  static const _positiveKeywords = [
    'excellent', 'great', 'amazing', 'wonderful', 'love', 'perfect',
    'outstanding', 'fantastic', 'good', 'better', 'best', 'awesome'
  ];
  static const _negativeKeywords = [
    'bad', 'terrible', 'awful', 'hate', 'horrible', 'poor',
    'worst', 'disappointing', 'broken', 'crash', 'issue', 'problem'
  ];

  @override
  Future<Sentiment> analyzeSentiment(String text) async {
    final lower = text.toLowerCase();
    int positiveCount = 0;
    int negativeCount = 0;

    for (final keyword in _positiveKeywords) {
      if (lower.contains(keyword)) positiveCount++;
    }
    for (final keyword in _negativeKeywords) {
      if (lower.contains(keyword)) negativeCount++;
    }

    if (positiveCount > negativeCount) return Sentiment.positive;
    if (negativeCount > positiveCount) return Sentiment.negative;
    return Sentiment.neutral;
  }

  @override
  Future<double> calculateConfidence(String text, Sentiment sentiment) async {
    if (text.isEmpty) return 0.0;
    final lower = text.toLowerCase();
    int matchCount = 0;

    final keywords = sentiment == Sentiment.positive
        ? _positiveKeywords
        : sentiment == Sentiment.negative
            ? _negativeKeywords
            : [];

    for (final keyword in keywords) {
      if (lower.contains(keyword)) matchCount++;
    }

    final confidence = matchCount / (matchCount + 1).toDouble();
    return (confidence * 100).toInt() / 100.0; // Round to 2 decimals
  }

  @override
  Future<List<String>> extractKeywords(String text) async {
    final lower = text.toLowerCase();
    final keywords = <String>{};

    for (final keyword in {..._positiveKeywords, ..._negativeKeywords}) {
      if (lower.contains(keyword)) keywords.add(keyword);
    }

    return keywords.toList();
  }

  @override
  Future<String> generateSummary(String text, Sentiment sentiment) async {
    final sentimentText = sentiment == Sentiment.positive
        ? 'positive'
        : sentiment == Sentiment.negative
            ? 'negative'
            : 'neutral';
    return 'Feedback with $sentimentText sentiment (${text.length} characters)';
  }

  @override
  Future<SentimentAnalysis> performFullAnalysis(
    String analysisId,
    String feedbackId,
    String text,
  ) async {
    final sentiment = await analyzeSentiment(text);
    final confidence = await calculateConfidence(text, sentiment);
    final keywords = await extractKeywords(text);
    final summary = await generateSummary(text, sentiment);

    return SentimentAnalysis(
      analysisId: analysisId,
      feedbackId: feedbackId,
      sentiment: sentiment,
      confidence: confidence,
      keywords: keywords,
      summary: summary,
      analyzedAt: DateTime.now(),
    );
  }
}

// ======================== Manager パターン ========================

/// フィードバック管理インターフェース
abstract class FeedbackManager {
  Future<UserFeedback> createFeedback({
    required String feedbackId,
    required String userId,
    required String title,
    required String description,
    required FeedbackType type,
    required int rating,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  });
  Future<AppRating> createRating({
    required String ratingId,
    required String userId,
    required RatingScale rating,
    String? reviewText,
    List<String>? aspects,
  });
  Future<void> markFeedbackHelpful(String feedbackId);
  Future<void> markFeedbackNotHelpful(String feedbackId);
  Future<void> changeStatus(String feedbackId, FeedbackStatus status);
  Future<FeedbackAggregate> aggregateFeedbacks(
    DateTime periodStart,
    DateTime periodEnd,
  );
  Future<NetPromoterScore> calculateNPS(
    DateTime periodStart,
    DateTime periodEnd,
  );
  Future<FeedbackReport> generateReport({
    required String reportId,
    required DateTime periodStart,
    required DateTime periodEnd,
  });
}

/// メモリベースのフィードバック管理実装
class MemoryFeedbackManager implements FeedbackManager {
  final FeedbackRepository repository;
  final SentimentAnalysisEngine sentimentEngine;

  MemoryFeedbackManager({
    required this.repository,
    required this.sentimentEngine,
  });

  @override
  Future<UserFeedback> createFeedback({
    required String feedbackId,
    required String userId,
    required String title,
    required String description,
    required FeedbackType type,
    required int rating,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) async {
    final feedback = UserFeedback(
      feedbackId: feedbackId,
      userId: userId,
      title: title,
      description: description,
      type: type,
      rating: rating,
      tags: tags,
      metadata: metadata,
      createdAt: DateTime.now(),
    );

    await repository.addFeedback(feedback);

    // Perform sentiment analysis
    final analysis = await sentimentEngine.performFullAnalysis(
      'analysis_$feedbackId',
      feedbackId,
      description,
    );
    await repository.addSentimentAnalysis(analysis);

    return feedback;
  }

  @override
  Future<AppRating> createRating({
    required String ratingId,
    required String userId,
    required RatingScale rating,
    String? reviewText,
    List<String>? aspects,
  }) async {
    final appRating = AppRating(
      ratingId: ratingId,
      userId: userId,
      rating: rating,
      reviewText: reviewText,
      aspects: aspects,
      createdAt: DateTime.now(),
    );

    await repository.addRating(appRating);
    return appRating;
  }

  @override
  Future<void> markFeedbackHelpful(String feedbackId) async {
    await repository.incrementHelpfulCount(feedbackId);
  }

  @override
  Future<void> markFeedbackNotHelpful(String feedbackId) async {
    await repository.incrementNotHelpfulCount(feedbackId);
  }

  @override
  Future<void> changeStatus(String feedbackId, FeedbackStatus status) async {
    await repository.updateFeedbackStatus(feedbackId, status);
  }

  @override
  Future<FeedbackAggregate> aggregateFeedbacks(
    DateTime periodStart,
    DateTime periodEnd,
  ) async {
    final feedbacks = await repository.getFeedbacksByStatus(FeedbackStatus.new_);
    final allFeedbacks = [
      ...feedbacks,
      ...await repository.getFeedbacksByStatus(FeedbackStatus.acknowledged),
      ...await repository.getFeedbacksByStatus(FeedbackStatus.inProgress),
      ...await repository.getFeedbacksByStatus(FeedbackStatus.closed),
      ...await repository.getFeedbacksByStatus(FeedbackStatus.reopened),
    ];

    final filteredFeedbacks = allFeedbacks
        .where((f) => f.createdAt.isAfter(periodStart) && f.createdAt.isBefore(periodEnd))
        .toList();

    final typeDistribution = <FeedbackType, int>{};
    for (final feedback in filteredFeedbacks) {
      typeDistribution[feedback.type] = (typeDistribution[feedback.type] ?? 0) + 1;
    }

    final sentimentCounts = <Sentiment, int>{};
    for (final feedback in filteredFeedbacks) {
      final sentiments = await repository.getFeedbackSentiments(feedback.feedbackId);
      for (final analysis in sentiments) {
        sentimentCounts[analysis.sentiment] = (sentimentCounts[analysis.sentiment] ?? 0) + 1;
      }
    }

    final ratings = await repository.getUserRatings(''); // This would need implementation
    final averageRating = await repository.getAverageRating();

    final resolvedCount = filteredFeedbacks
        .where((f) => f.status == FeedbackStatus.closed)
        .length;
    final pendingCount = filteredFeedbacks
        .where((f) => f.status == FeedbackStatus.new_ || f.status == FeedbackStatus.inProgress)
        .length;

    return FeedbackAggregate(
      aggregateId: 'agg_${DateTime.now().millisecondsSinceEpoch}',
      periodStart: periodStart,
      periodEnd: periodEnd,
      totalFeedbacks: filteredFeedbacks.length,
      totalRatings: ratings.length,
      averageRating: averageRating,
      typeDistribution: typeDistribution,
      sentimentDistribution: sentimentCounts,
      resolvedCount: resolvedCount,
      pendingCount: pendingCount,
    );
  }

  @override
  Future<NetPromoterScore> calculateNPS(
    DateTime periodStart,
    DateTime periodEnd,
  ) async {
    final ratings = await repository.getUserRatings(''); // This needs proper implementation

    int promoters = 0; // 4-5 stars
    int passives = 0; // 3 stars
    int detractors = 0; // 1-2 stars

    for (final rating in ratings) {
      if (rating.stars >= 4) {
        promoters++;
      } else if (rating.stars == 3) {
        passives++;
      } else {
        detractors++;
      }
    }

    final total = promoters + passives + detractors;
    final npsScore = total == 0 ? 0.0 : ((promoters - detractors) / total) * 100;

    return NetPromoterScore(
      npsId: 'nps_${DateTime.now().millisecondsSinceEpoch}',
      periodStart: periodStart,
      periodEnd: periodEnd,
      promoters: promoters,
      passives: passives,
      detractors: detractors,
      npsScore: npsScore,
    );
  }

  @override
  Future<FeedbackReport> generateReport({
    required String reportId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final aggregate = await aggregateFeedbacks(periodStart, periodEnd);
    final nps = await calculateNPS(periodStart, periodEnd);

    // Get top feedbacks (sorted by helpfulness)
    final allFeedbacks = [
      ...await repository.getFeedbacksByStatus(FeedbackStatus.new_),
      ...await repository.getFeedbacksByStatus(FeedbackStatus.acknowledged),
      ...await repository.getFeedbacksByStatus(FeedbackStatus.inProgress),
      ...await repository.getFeedbacksByStatus(FeedbackStatus.closed),
      ...await repository.getFeedbacksByStatus(FeedbackStatus.reopened),
    ];

    final filteredFeedbacks = allFeedbacks
        .where((f) => f.createdAt.isAfter(periodStart) && f.createdAt.isBefore(periodEnd))
        .toList();

    filteredFeedbacks.sort((a, b) => b.helpfulnessScore.compareTo(a.helpfulnessScore));
    final topFeedbacks = filteredFeedbacks.take(5).toList();

    return FeedbackReport(
      reportId: reportId,
      generatedAt: DateTime.now(),
      aggregate: aggregate,
      nps: nps,
      topFeedbacks: topFeedbacks,
      topRatings: [],
      recommendations: [
        'Focus on reducing negative sentiment',
        'Prioritize high-impact feature requests',
        'Improve documentation based on feedback',
      ],
      insights: {
        'total_analyzed': filteredFeedbacks.length,
        'period': '${periodStart.toIso8601String()} to ${periodEnd.toIso8601String()}',
      },
    );
  }
}

// ======================== Facade パターン ========================

/// フィードバック管理ファサード
class FeedbackManagerFacade {
  final FeedbackRepository repository;
  final SentimentAnalysisEngine sentimentEngine;
  final FeedbackManager manager;

  FeedbackManagerFacade({
    FeedbackRepository? repository,
    SentimentAnalysisEngine? sentimentEngine,
    FeedbackManager? manager,
  })  : repository = repository ?? MemoryFeedbackRepository(),
        sentimentEngine = sentimentEngine ?? MemorySentimentAnalysisEngine(),
        manager = manager ?? MemoryFeedbackManager(
          repository: repository ?? MemoryFeedbackRepository(),
          sentimentEngine: sentimentEngine ?? MemorySentimentAnalysisEngine(),
        );

  Future<UserFeedback> submitFeedback({
    required String feedbackId,
    required String userId,
    required String title,
    required String description,
    required FeedbackType type,
    required int rating,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) =>
      manager.createFeedback(
        feedbackId: feedbackId,
        userId: userId,
        title: title,
        description: description,
        type: type,
        rating: rating,
        tags: tags,
        metadata: metadata,
      );

  Future<AppRating> submitRating({
    required String ratingId,
    required String userId,
    required RatingScale rating,
    String? reviewText,
    List<String>? aspects,
  }) =>
      manager.createRating(
        ratingId: ratingId,
        userId: userId,
        rating: rating,
        reviewText: reviewText,
        aspects: aspects,
      );

  Future<void> markHelpful(String feedbackId) =>
      manager.markFeedbackHelpful(feedbackId);

  Future<void> markNotHelpful(String feedbackId) =>
      manager.markFeedbackNotHelpful(feedbackId);

  Future<void> updateStatus(String feedbackId, FeedbackStatus status) =>
      manager.changeStatus(feedbackId, status);

  Future<FeedbackReport> generateReport({
    required String reportId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) =>
      manager.generateReport(
        reportId: reportId,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
}
