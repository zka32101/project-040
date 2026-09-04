/// Phase 45: User Feedback & Rating System テストスイート
///
/// 50+の包括的なテストケース

import 'package:flutter_test/flutter_test.dart';
import '../lib/models/feedback_models.dart';
import '../lib/services/feedback_service.dart';

void main() {
  late MemoryFeedbackRepository repository;
  late MemorySentimentAnalysisEngine sentimentEngine;
  late MemoryFeedbackManager manager;
  late FeedbackManagerFacade facade;

  setUp(() {
    repository = MemoryFeedbackRepository();
    sentimentEngine = MemorySentimentAnalysisEngine();
    manager = MemoryFeedbackManager(
      repository: repository,
      sentimentEngine: sentimentEngine,
    );
    facade = FeedbackManagerFacade(
      repository: repository,
      sentimentEngine: sentimentEngine,
      manager: manager,
    );
  });

  group('FeedbackType Enum Tests', () {
    test('FeedbackType.bug has correct value', () {
      expect(FeedbackType.bug.value, equals('bug'));
    });

    test('FeedbackType.feature has correct value', () {
      expect(FeedbackType.feature.value, equals('feature'));
    });

    test('FeedbackType.improvement has correct value', () {
      expect(FeedbackType.improvement.value, equals('improvement'));
    });

    test('FeedbackType.documentation has correct value', () {
      expect(FeedbackType.documentation.value, equals('documentation'));
    });

    test('FeedbackType.other has correct value', () {
      expect(FeedbackType.other.value, equals('other'));
    });
  });

  group('FeedbackStatus Enum Tests', () {
    test('FeedbackStatus.new_ has correct value', () {
      expect(FeedbackStatus.new_.value, equals('new'));
    });

    test('FeedbackStatus.acknowledged has correct value', () {
      expect(FeedbackStatus.acknowledged.value, equals('acknowledged'));
    });

    test('FeedbackStatus.inProgress has correct value', () {
      expect(FeedbackStatus.inProgress.value, equals('in_progress'));
    });

    test('FeedbackStatus.closed has correct value', () {
      expect(FeedbackStatus.closed.value, equals('closed'));
    });
  });

  group('RatingScale Enum Tests', () {
    test('RatingScale.poor has value 1', () {
      expect(RatingScale.poor.value, equals(1));
    });

    test('RatingScale.excellent has value 5', () {
      expect(RatingScale.excellent.value, equals(5));
    });
  });

  group('Sentiment Enum Tests', () {
    test('Sentiment.positive has correct value', () {
      expect(Sentiment.positive.value, equals('positive'));
    });

    test('Sentiment.negative has correct value', () {
      expect(Sentiment.negative.value, equals('negative'));
    });

    test('Sentiment.neutral has correct value', () {
      expect(Sentiment.neutral.value, equals('neutral'));
    });
  });

  group('UserFeedback Model Tests', () {
    test('UserFeedback creation with all fields', () {
      final feedback = UserFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Great app',
        description: 'Love this app',
        type: FeedbackType.feature,
        status: FeedbackStatus.new_,
        rating: 5,
        tags: ['ui', 'performance'],
        createdAt: DateTime.now(),
        helpfulCount: 10,
        notHelpfulCount: 2,
      );

      expect(feedback.feedbackId, equals('fb1'));
      expect(feedback.userId, equals('user1'));
      expect(feedback.title, equals('Great app'));
      expect(feedback.rating, equals(5));
      expect(feedback.tags, equals(['ui', 'performance']));
    });

    test('UserFeedback.isHelpful returns true when helpful > not helpful', () {
      final feedback = UserFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Test',
        description: 'Test description',
        type: FeedbackType.bug,
        rating: 3,
        createdAt: DateTime.now(),
        helpfulCount: 10,
        notHelpfulCount: 2,
      );

      expect(feedback.isHelpful, isTrue);
    });

    test('UserFeedback.helpfulnessScore calculation', () {
      final feedback = UserFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Test',
        description: 'Test description',
        type: FeedbackType.bug,
        rating: 3,
        createdAt: DateTime.now(),
        helpfulCount: 8,
        notHelpfulCount: 2,
      );

      expect(feedback.helpfulnessScore, equals(0.6));
    });

    test('UserFeedback.age returns duration since creation', () {
      final now = DateTime.now();
      final feedback = UserFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Test',
        description: 'Test description',
        type: FeedbackType.bug,
        rating: 3,
        createdAt: now.subtract(Duration(hours: 1)),
      );

      expect(feedback.age.inHours, greaterThanOrEqualTo(1));
    });
  });

  group('AppRating Model Tests', () {
    test('AppRating creation with all fields', () {
      final rating = AppRating(
        ratingId: 'r1',
        userId: 'user1',
        rating: RatingScale.excellent,
        reviewText: 'Excellent app',
        aspects: ['performance', 'usability'],
        createdAt: DateTime.now(),
        helpfulCount: 5,
      );

      expect(rating.ratingId, equals('r1'));
      expect(rating.stars, equals(5));
      expect(rating.hasReview, isTrue);
      expect(rating.aspects, equals(['performance', 'usability']));
    });

    test('AppRating.hasReview returns false when reviewText is null', () {
      final rating = AppRating(
        ratingId: 'r1',
        userId: 'user1',
        rating: RatingScale.good,
        createdAt: DateTime.now(),
      );

      expect(rating.hasReview, isFalse);
    });

    test('AppRating.hasReview returns false when reviewText is empty', () {
      final rating = AppRating(
        ratingId: 'r1',
        userId: 'user1',
        rating: RatingScale.good,
        reviewText: '',
        createdAt: DateTime.now(),
      );

      expect(rating.hasReview, isFalse);
    });
  });

  group('ReviewComment Model Tests', () {
    test('ReviewComment creation with all fields', () {
      final comment = ReviewComment(
        commentId: 'c1',
        reviewId: 'r1',
        userId: 'user1',
        text: 'Great review!',
        likeCount: 3,
        createdAt: DateTime.now(),
      );

      expect(comment.commentId, equals('c1'));
      expect(comment.reviewId, equals('r1'));
      expect(comment.likeCount, equals(3));
    });
  });

  group('SentimentAnalysis Model Tests', () {
    test('SentimentAnalysis creation with all fields', () {
      final analysis = SentimentAnalysis(
        analysisId: 'sa1',
        feedbackId: 'fb1',
        sentiment: Sentiment.positive,
        confidence: 0.92,
        keywords: ['excellent', 'great', 'amazing'],
        summary: 'Very positive feedback',
        analyzedAt: DateTime.now(),
      );

      expect(analysis.analysisId, equals('sa1'));
      expect(analysis.sentiment, equals(Sentiment.positive));
      expect(analysis.confidencePercentage, equals(92));
    });

    test('SentimentAnalysis.isReliable returns true for confidence >= 0.7', () {
      final analysis = SentimentAnalysis(
        analysisId: 'sa1',
        feedbackId: 'fb1',
        sentiment: Sentiment.positive,
        confidence: 0.75,
        keywords: [],
        analyzedAt: DateTime.now(),
      );

      expect(analysis.isReliable, isTrue);
    });

    test('SentimentAnalysis.isReliable returns false for confidence < 0.7', () {
      final analysis = SentimentAnalysis(
        analysisId: 'sa1',
        feedbackId: 'fb1',
        sentiment: Sentiment.neutral,
        confidence: 0.5,
        keywords: [],
        analyzedAt: DateTime.now(),
      );

      expect(analysis.isReliable, isFalse);
    });
  });

  group('FeedbackAggregate Model Tests', () {
    test('FeedbackAggregate creation with all fields', () {
      final aggregate = FeedbackAggregate(
        aggregateId: 'agg1',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        totalFeedbacks: 100,
        totalRatings: 80,
        averageRating: 4.2,
        typeDistribution: {FeedbackType.bug: 30, FeedbackType.feature: 70},
        sentimentDistribution: {
          Sentiment.positive: 70,
          Sentiment.negative: 20,
          Sentiment.neutral: 10,
        },
        resolvedCount: 60,
        pendingCount: 40,
      );

      expect(aggregate.aggregateId, equals('agg1'));
      expect(aggregate.totalFeedbacks, equals(100));
    });

    test('FeedbackAggregate.resolutionRate calculation', () {
      final aggregate = FeedbackAggregate(
        aggregateId: 'agg1',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        totalFeedbacks: 100,
        totalRatings: 80,
        averageRating: 4.2,
        typeDistribution: {},
        sentimentDistribution: {},
        resolvedCount: 60,
        pendingCount: 40,
      );

      expect(aggregate.resolutionRate, equals(0.6));
    });

    test('FeedbackAggregate.mostCommonType returns correct type', () {
      final aggregate = FeedbackAggregate(
        aggregateId: 'agg1',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        totalFeedbacks: 100,
        totalRatings: 80,
        averageRating: 4.2,
        typeDistribution: {FeedbackType.bug: 50, FeedbackType.feature: 30},
        sentimentDistribution: {},
        resolvedCount: 60,
        pendingCount: 40,
      );

      expect(aggregate.mostCommonType, equals(FeedbackType.bug));
    });

    test('FeedbackAggregate.dominantSentiment returns correct sentiment', () {
      final aggregate = FeedbackAggregate(
        aggregateId: 'agg1',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        totalFeedbacks: 100,
        totalRatings: 80,
        averageRating: 4.2,
        typeDistribution: {},
        sentimentDistribution: {
          Sentiment.positive: 70,
          Sentiment.negative: 30,
        },
        resolvedCount: 60,
        pendingCount: 40,
      );

      expect(aggregate.dominantSentiment, equals(Sentiment.positive));
    });
  });

  group('NetPromoterScore Model Tests', () {
    test('NetPromoterScore creation with all fields', () {
      final nps = NetPromoterScore(
        npsId: 'nps1',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        promoters: 70,
        passives: 20,
        detractors: 10,
        npsScore: 60.0,
      );

      expect(nps.npsId, equals('nps1'));
      expect(nps.totalResponses, equals(100));
    });

    test('NetPromoterScore.category returns Excellent for score >= 70', () {
      final nps = NetPromoterScore(
        npsId: 'nps1',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        promoters: 80,
        passives: 15,
        detractors: 5,
        npsScore: 75.0,
      );

      expect(nps.category, equals('Excellent'));
    });

    test('NetPromoterScore.category returns Good for score >= 50', () {
      final nps = NetPromoterScore(
        npsId: 'nps1',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        promoters: 65,
        passives: 25,
        detractors: 10,
        npsScore: 55.0,
      );

      expect(nps.category, equals('Good'));
    });

    test('NetPromoterScore.isPositive returns true for positive score', () {
      final nps = NetPromoterScore(
        npsId: 'nps1',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        promoters: 60,
        passives: 20,
        detractors: 20,
        npsScore: 40.0,
      );

      expect(nps.isPositive, isTrue);
    });
  });

  group('FeedbackReport Model Tests', () {
    test('FeedbackReport creation and toMarkdown method', () {
      final aggregate = FeedbackAggregate(
        aggregateId: 'agg1',
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        totalFeedbacks: 100,
        totalRatings: 80,
        averageRating: 4.2,
        typeDistribution: {},
        sentimentDistribution: {},
        resolvedCount: 60,
        pendingCount: 40,
      );

      final report = FeedbackReport(
        reportId: 'report1',
        generatedAt: DateTime.now(),
        aggregate: aggregate,
        topFeedbacks: [],
        topRatings: [],
        recommendations: ['Improve performance', 'Add dark mode'],
      );

      final markdown = report.toMarkdown();
      expect(markdown, contains('User Feedback & Rating Report'));
      expect(markdown, contains('100'));
      expect(markdown, contains('4.20'));
    });
  });

  group('MemoryFeedbackRepository Tests', () {
    test('addFeedback and getFeedback', () async {
      final feedback = UserFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Test',
        description: 'Test description',
        type: FeedbackType.bug,
        rating: 3,
        createdAt: DateTime.now(),
      );

      await repository.addFeedback(feedback);
      final retrieved = await repository.getFeedback('fb1');

      expect(retrieved, isNotNull);
      expect(retrieved!.feedbackId, equals('fb1'));
    });

    test('getUserFeedbacks returns feedbacks for specific user', () async {
      final feedback1 = UserFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Test 1',
        description: 'Test description 1',
        type: FeedbackType.bug,
        rating: 3,
        createdAt: DateTime.now(),
      );

      final feedback2 = UserFeedback(
        feedbackId: 'fb2',
        userId: 'user2',
        title: 'Test 2',
        description: 'Test description 2',
        type: FeedbackType.feature,
        rating: 5,
        createdAt: DateTime.now(),
      );

      await repository.addFeedback(feedback1);
      await repository.addFeedback(feedback2);

      final user1Feedbacks = await repository.getUserFeedbacks('user1');
      expect(user1Feedbacks.length, equals(1));
      expect(user1Feedbacks.first.feedbackId, equals('fb1'));
    });

    test('getFeedbacksByType filters correctly', () async {
      final feedback1 = UserFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Bug report',
        description: 'Test',
        type: FeedbackType.bug,
        rating: 2,
        createdAt: DateTime.now(),
      );

      final feedback2 = UserFeedback(
        feedbackId: 'fb2',
        userId: 'user1',
        title: 'Feature request',
        description: 'Test',
        type: FeedbackType.feature,
        rating: 4,
        createdAt: DateTime.now(),
      );

      await repository.addFeedback(feedback1);
      await repository.addFeedback(feedback2);

      final bugFeedbacks = await repository.getFeedbacksByType(FeedbackType.bug);
      expect(bugFeedbacks.length, equals(1));
      expect(bugFeedbacks.first.type, equals(FeedbackType.bug));
    });

    test('updateFeedbackStatus changes status correctly', () async {
      final feedback = UserFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Test',
        description: 'Test',
        type: FeedbackType.bug,
        status: FeedbackStatus.new_,
        rating: 3,
        createdAt: DateTime.now(),
      );

      await repository.addFeedback(feedback);
      await repository.updateFeedbackStatus('fb1', FeedbackStatus.acknowledged);

      final updated = await repository.getFeedback('fb1');
      expect(updated!.status, equals(FeedbackStatus.acknowledged));
    });

    test('incrementHelpfulCount increases count', () async {
      final feedback = UserFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Test',
        description: 'Test',
        type: FeedbackType.bug,
        rating: 3,
        createdAt: DateTime.now(),
        helpfulCount: 5,
      );

      await repository.addFeedback(feedback);
      await repository.incrementHelpfulCount('fb1');

      final updated = await repository.getFeedback('fb1');
      expect(updated!.helpfulCount, equals(6));
    });

    test('addRating and getRating', () async {
      final rating = AppRating(
        ratingId: 'r1',
        userId: 'user1',
        rating: RatingScale.excellent,
        createdAt: DateTime.now(),
      );

      await repository.addRating(rating);
      final retrieved = await repository.getRating('r1');

      expect(retrieved, isNotNull);
      expect(retrieved!.stars, equals(5));
    });

    test('getAverageRating calculation', () async {
      final rating1 = AppRating(
        ratingId: 'r1',
        userId: 'user1',
        rating: RatingScale.excellent,
        createdAt: DateTime.now(),
      );

      final rating2 = AppRating(
        ratingId: 'r2',
        userId: 'user2',
        rating: RatingScale.good,
        createdAt: DateTime.now(),
      );

      await repository.addRating(rating1);
      await repository.addRating(rating2);

      final average = await repository.getAverageRating();
      expect(average, equals(4.0)); // (5 + 3) / 2
    });

    test('clearAll removes all data', () async {
      final feedback = UserFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Test',
        description: 'Test',
        type: FeedbackType.bug,
        rating: 3,
        createdAt: DateTime.now(),
      );

      await repository.addFeedback(feedback);
      await repository.clearAll();

      final retrieved = await repository.getFeedback('fb1');
      expect(retrieved, isNull);
    });
  });

  group('MemorySentimentAnalysisEngine Tests', () {
    test('analyzeSentiment detects positive sentiment', () async {
      final sentiment = await sentimentEngine.analyzeSentiment('This is amazing and excellent!');
      expect(sentiment, equals(Sentiment.positive));
    });

    test('analyzeSentiment detects negative sentiment', () async {
      final sentiment = await sentimentEngine.analyzeSentiment('This is terrible and awful');
      expect(sentiment, equals(Sentiment.negative));
    });

    test('analyzeSentiment detects neutral sentiment', () async {
      final sentiment = await sentimentEngine.analyzeSentiment('The app works');
      expect(sentiment, equals(Sentiment.neutral));
    });

    test('calculateConfidence returns valid score', () async {
      final confidence = await sentimentEngine.calculateConfidence(
        'This is excellent and great',
        Sentiment.positive,
      );
      expect(confidence, greaterThan(0.0));
      expect(confidence, lessThanOrEqualTo(1.0));
    });

    test('extractKeywords finds relevant keywords', () async {
      final keywords = await sentimentEngine.extractKeywords('This is amazing and terrible');
      expect(keywords, contains('amazing'));
      expect(keywords, contains('terrible'));
    });

    test('generateSummary creates appropriate summary', () async {
      final summary = await sentimentEngine.generateSummary('Test feedback', Sentiment.positive);
      expect(summary, contains('positive'));
      expect(summary, contains('Test feedback'));
    });

    test('performFullAnalysis returns complete analysis', () async {
      final analysis = await sentimentEngine.performFullAnalysis(
        'sa1',
        'fb1',
        'This is an excellent and wonderful app',
      );

      expect(analysis.analysisId, equals('sa1'));
      expect(analysis.feedbackId, equals('fb1'));
      expect(analysis.sentiment, equals(Sentiment.positive));
      expect(analysis.keywords.isNotEmpty, isTrue);
    });
  });

  group('MemoryFeedbackManager Tests', () {
    test('createFeedback creates feedback with sentiment analysis', () async {
      final feedback = await manager.createFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Great app',
        description: 'This is an amazing application',
        type: FeedbackType.feature,
        rating: 5,
      );

      expect(feedback.feedbackId, equals('fb1'));
      expect(feedback.title, equals('Great app'));

      // Verify sentiment analysis was created
      final sentiments = await repository.getFeedbackSentiments('fb1');
      expect(sentiments.isNotEmpty, isTrue);
    });

    test('createRating creates app rating', () async {
      final rating = await manager.createRating(
        ratingId: 'r1',
        userId: 'user1',
        rating: RatingScale.excellent,
        reviewText: 'Excellent app',
      );

      expect(rating.ratingId, equals('r1'));
      expect(rating.stars, equals(5));
    });

    test('markFeedbackHelpful increments helpful count', () async {
      final feedback = UserFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Test',
        description: 'Test',
        type: FeedbackType.bug,
        rating: 3,
        createdAt: DateTime.now(),
        helpfulCount: 5,
      );

      await repository.addFeedback(feedback);
      await manager.markFeedbackHelpful('fb1');

      final updated = await repository.getFeedback('fb1');
      expect(updated!.helpfulCount, equals(6));
    });

    test('changeStatus updates feedback status', () async {
      final feedback = UserFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Test',
        description: 'Test',
        type: FeedbackType.bug,
        status: FeedbackStatus.new_,
        rating: 3,
        createdAt: DateTime.now(),
      );

      await repository.addFeedback(feedback);
      await manager.changeStatus('fb1', FeedbackStatus.inProgress);

      final updated = await repository.getFeedback('fb1');
      expect(updated!.status, equals(FeedbackStatus.inProgress));
    });

    test('aggregateFeedbacks returns correct statistics', () async {
      final now = DateTime.now();
      final feedback = UserFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Test',
        description: 'Test',
        type: FeedbackType.bug,
        status: FeedbackStatus.closed,
        rating: 3,
        createdAt: now,
      );

      await repository.addFeedback(feedback);

      final aggregate = await manager.aggregateFeedbacks(
        now.subtract(Duration(hours: 1)),
        now.add(Duration(hours: 1)),
      );

      expect(aggregate.totalFeedbacks, equals(1));
      expect(aggregate.resolvedCount, equals(1));
    });

    test('calculateNPS returns NPS score', () async {
      final now = DateTime.now();
      final rating1 = AppRating(
        ratingId: 'r1',
        userId: 'user1',
        rating: RatingScale.excellent,
        createdAt: now,
      );

      await repository.addRating(rating1);

      final nps = await manager.calculateNPS(
        now.subtract(Duration(hours: 1)),
        now.add(Duration(hours: 1)),
      );

      expect(nps.npsId, isNotNull);
      expect(nps.totalResponses, greaterThanOrEqualTo(0));
    });

    test('generateReport returns complete report', () async {
      final now = DateTime.now();
      final feedback = UserFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Test Feedback',
        description: 'Test description',
        type: FeedbackType.bug,
        rating: 4,
        createdAt: now,
      );

      await repository.addFeedback(feedback);

      final report = await manager.generateReport(
        reportId: 'report1',
        periodStart: now.subtract(Duration(hours: 1)),
        periodEnd: now.add(Duration(hours: 1)),
      );

      expect(report.reportId, equals('report1'));
      expect(report.aggregate.totalFeedbacks, equals(1));
      expect(report.recommendations, isNotEmpty);
    });
  });

  group('FeedbackManagerFacade Tests', () {
    test('submitFeedback creates feedback', () async {
      final feedback = await facade.submitFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Great',
        description: 'Excellent app',
        type: FeedbackType.feature,
        rating: 5,
      );

      expect(feedback.feedbackId, equals('fb1'));
    });

    test('submitRating creates rating', () async {
      final rating = await facade.submitRating(
        ratingId: 'r1',
        userId: 'user1',
        rating: RatingScale.excellent,
        reviewText: 'Perfect',
      );

      expect(rating.stars, equals(5));
    });

    test('markHelpful updates helpful count', () async {
      final feedback = UserFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Test',
        description: 'Test',
        type: FeedbackType.bug,
        rating: 3,
        createdAt: DateTime.now(),
      );

      await repository.addFeedback(feedback);
      await facade.markHelpful('fb1');

      final updated = await repository.getFeedback('fb1');
      expect(updated!.helpfulCount, equals(1));
    });

    test('updateStatus changes status', () async {
      final feedback = UserFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Test',
        description: 'Test',
        type: FeedbackType.bug,
        status: FeedbackStatus.new_,
        rating: 3,
        createdAt: DateTime.now(),
      );

      await repository.addFeedback(feedback);
      await facade.updateStatus('fb1', FeedbackStatus.acknowledged);

      final updated = await repository.getFeedback('fb1');
      expect(updated!.status, equals(FeedbackStatus.acknowledged));
    });

    test('generateReport creates report', () async {
      final now = DateTime.now();
      final report = await facade.generateReport(
        reportId: 'report1',
        periodStart: now.subtract(Duration(days: 30)),
        periodEnd: now,
      );

      expect(report.reportId, equals('report1'));
      expect(report.aggregate, isNotNull);
    });
  });

  group('Integration Tests', () {
    test('Complete feedback lifecycle', () async {
      // 1. Submit feedback
      final feedback = await facade.submitFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Bug found',
        description: 'App crashes when clicking button',
        type: FeedbackType.bug,
        rating: 2,
      );

      expect(feedback.status, equals(FeedbackStatus.new_));

      // 2. Update status
      await facade.updateStatus('fb1', FeedbackStatus.acknowledged);
      var updated = await repository.getFeedback('fb1');
      expect(updated!.status, equals(FeedbackStatus.acknowledged));

      // 3. Move to in progress
      await facade.updateStatus('fb1', FeedbackStatus.inProgress);
      updated = await repository.getFeedback('fb1');
      expect(updated!.status, equals(FeedbackStatus.inProgress));

      // 4. Mark as closed
      await facade.updateStatus('fb1', FeedbackStatus.closed);
      updated = await repository.getFeedback('fb1');
      expect(updated!.status, equals(FeedbackStatus.closed));
    });

    test('Rating and feedback workflow', () async {
      // Submit rating
      final rating = await facade.submitRating(
        ratingId: 'r1',
        userId: 'user1',
        rating: RatingScale.excellent,
        reviewText: 'Amazing app',
        aspects: ['performance', 'usability'],
      );

      expect(rating.hasReview, isTrue);
      expect(rating.aspects, contains('performance'));

      // Submit feedback
      final feedback = await facade.submitFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Great experience',
        description: 'Love the new design and performance',
        type: FeedbackType.improvement,
        rating: 5,
      );

      expect(feedback.rating, equals(5));
    });

    test('Sentiment analysis with feedback', () async {
      final feedback = await facade.submitFeedback(
        feedbackId: 'fb1',
        userId: 'user1',
        title: 'Feedback',
        description: 'This app is excellent and amazing',
        type: FeedbackType.feature,
        rating: 5,
      );

      final sentiments = await repository.getFeedbackSentiments('fb1');
      expect(sentiments.isNotEmpty, isTrue);
      expect(sentiments.first.sentiment, equals(Sentiment.positive));
    });

    test('Report generation with multiple feedbacks', () async {
      final now = DateTime.now();

      // Create multiple feedbacks
      for (int i = 0; i < 5; i++) {
        await facade.submitFeedback(
          feedbackId: 'fb$i',
          userId: 'user1',
          title: 'Feedback $i',
          description: 'This is great' * i,
          type: FeedbackType.bug,
          rating: 4,
        );
      }

      // Generate report
      final report = await facade.generateReport(
        reportId: 'report1',
        periodStart: now.subtract(Duration(hours: 1)),
        periodEnd: now.add(Duration(hours: 1)),
      );

      expect(report.aggregate.totalFeedbacks, equals(5));
      expect(report.topFeedbacks.isNotEmpty, isTrue);
    });
  });
}
