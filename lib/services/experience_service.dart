import 'dart:async';
import '../models/experience_models.dart';

abstract class ExperienceRepository {
  // User Profiles (12 methods)
  Future<void> createUserProfile(UserProfile profile);
  Future<UserProfile?> getUserProfile(String userId);
  Future<List<UserProfile>> getAllProfiles();
  Future<List<UserProfile>> getProfilesBySegment(UserSegment segment);
  Future<void> updateUserProfile(UserProfile profile);
  Future<void> deleteUserProfile(String userId);
  Future<int> getUserCount();
  Future<double> getAverageEngagementScore();
  Future<List<UserProfile>> getActiveProfiles();
  Future<List<UserProfile>> getHighValueUsers();
  Future<void> clearAllProfiles();
  Future<Map<UserSegment, int>> getUserCountBySegment();

  // Personalization Strategies (12 methods)
  Future<void> createStrategy(PersonalizationStrategy strategy);
  Future<PersonalizationStrategy?> getStrategy(String strategyId);
  Future<List<PersonalizationStrategy>> getAllStrategies();
  Future<List<PersonalizationStrategy>> getStrategiesByUser(String userId);
  Future<List<PersonalizationStrategy>> getActiveStrategies();
  Future<void> updateStrategy(PersonalizationStrategy strategy);
  Future<void> deleteStrategy(String strategyId);
  Future<int> getStrategyCount();
  Future<double> getAverageConversionRate();
  Future<List<PersonalizationStrategy>> getEffectiveStrategies();
  Future<void> clearAllStrategies();
  Future<Map<ExperienceType, int>> getStrategyCountByType();

  // User Journeys (10 methods)
  Future<void> createJourney(UserJourney journey);
  Future<UserJourney?> getJourney(String journeyId);
  Future<List<UserJourney>> getAllJourneys();
  Future<UserJourney?> getJourneyByUser(String userId);
  Future<void> updateJourney(UserJourney journey);
  Future<void> deleteJourney(String journeyId);
  Future<List<UserJourney>> getAtRiskJourneys();
  Future<void> clearAllJourneys();
  Future<int> getJourneyCount();
  Future<Map<JourneyStage, int>> getJourneyCountByStage();

  // Recommendations (12 methods)
  Future<void> createRecommendation(Recommendation recommendation);
  Future<Recommendation?> getRecommendation(String recommendationId);
  Future<List<Recommendation>> getAllRecommendations();
  Future<List<Recommendation>> getRecommendationsByUser(String userId);
  Future<List<Recommendation>> getAcceptedRecommendations();
  Future<void> updateRecommendation(Recommendation recommendation);
  Future<void> deleteRecommendation(String recommendationId);
  Future<int> getRecommendationCount();
  Future<double> getAcceptanceRate();
  Future<List<Recommendation>> getHighRelevanceRecommendations();
  Future<void> clearAllRecommendations();
  Future<Map<RecommendationType, int>> getCountByType();

  // A/B Tests (10 methods)
  Future<void> createABTest(ABTest test);
  Future<ABTest?> getABTest(String testId);
  Future<List<ABTest>> getAllABTests();
  Future<List<ABTest>> getRunningTests();
  Future<void> updateABTest(ABTest test);
  Future<void> deleteABTest(String testId);
  Future<List<ABTest>> getCompletedTests();
  Future<void> clearAllABTests();
  Future<int> getABTestCount();
  Future<Map<ABTestStatus, int>> getCountByStatus();

  // User Satisfaction (10 methods)
  Future<void> createSatisfactionRecord(UserSatisfaction satisfaction);
  Future<UserSatisfaction?> getSatisfactionRecord(String satisfactionId);
  Future<List<UserSatisfaction>> getAllSatisfactionRecords();
  Future<List<UserSatisfaction>> getSatisfactionByUser(String userId);
  Future<List<UserSatisfaction>> getPositiveFeedback();
  Future<void> updateSatisfactionRecord(UserSatisfaction satisfaction);
  Future<void> deleteSatisfactionRecord(String satisfactionId);
  Future<double> getAverageNPS();
  Future<void> clearAllSatisfaction();
  Future<int> getSatisfactionCount();

  // Experience Analytics (10 methods)
  Future<void> createAnalytics(ExperienceAnalytics analytics);
  Future<ExperienceAnalytics?> getAnalytics(String analyticsId);
  Future<List<ExperienceAnalytics>> getAllAnalytics();
  Future<ExperienceAnalytics?> getAnalyticsByUser(String userId);
  Future<void> updateAnalytics(ExperienceAnalytics analytics);
  Future<void> deleteAnalytics(String analyticsId);
  Future<double> getAverageClickThroughRate();
  Future<void> clearAllAnalytics();
  Future<int> getAnalyticsCount();
  Future<List<ExperienceAnalytics>> getHighEngagementAnalytics();

  // Content Relevance (8 methods)
  Future<void> createContent(ContentRelevance content);
  Future<ContentRelevance?> getContent(String contentId);
  Future<List<ContentRelevance>> getAllContent();
  Future<void> updateContent(ContentRelevance content);
  Future<void> deleteContent(String contentId);
  Future<List<ContentRelevance>> getTrendingContent();
  Future<void> clearAllContent();
  Future<int> getContentCount();
}

class InMemoryExperienceRepository extends ExperienceRepository {
  final Map<String, UserProfile> _profiles = {};
  final Map<String, PersonalizationStrategy> _strategies = {};
  final Map<String, UserJourney> _journeys = {};
  final Map<String, Recommendation> _recommendations = {};
  final Map<String, ABTest> _abTests = {};
  final Map<String, UserSatisfaction> _satisfaction = {};
  final Map<String, ExperienceAnalytics> _analytics = {};
  final Map<String, ContentRelevance> _content = {};

  @override
  Future<void> createUserProfile(UserProfile profile) async => _profiles[profile.userId] = profile;
  @override
  Future<UserProfile?> getUserProfile(String userId) async => _profiles[userId];
  @override
  Future<List<UserProfile>> getAllProfiles() async => _profiles.values.toList();
  @override
  Future<List<UserProfile>> getProfilesBySegment(UserSegment segment) async =>
      _profiles.values.where((p) => p.segment == segment).toList();
  @override
  Future<void> updateUserProfile(UserProfile profile) async => _profiles[profile.userId] = profile;
  @override
  Future<void> deleteUserProfile(String userId) async => _profiles.remove(userId);
  @override
  Future<int> getUserCount() async => _profiles.length;
  @override
  Future<double> getAverageEngagementScore() async {
    if (_profiles.isEmpty) return 0;
    final sum = _profiles.values.fold<int>(0, (s, p) => s + p.engagementScore);
    return sum / _profiles.length;
  }
  @override
  Future<List<UserProfile>> getActiveProfiles() async =>
      _profiles.values.where((p) => p.isActive).toList();
  @override
  Future<List<UserProfile>> getHighValueUsers() async =>
      _profiles.values.where((p) => p.isHighValue).toList();
  @override
  Future<void> clearAllProfiles() async => _profiles.clear();
  @override
  Future<Map<UserSegment, int>> getUserCountBySegment() async {
    final result = <UserSegment, int>{};
    for (final segment in UserSegment.values) {
      result[segment] = _profiles.values.where((p) => p.segment == segment).length;
    }
    return result;
  }

  @override
  Future<void> createStrategy(PersonalizationStrategy strategy) async =>
      _strategies[strategy.strategyId] = strategy;
  @override
  Future<PersonalizationStrategy?> getStrategy(String strategyId) async => _strategies[strategyId];
  @override
  Future<List<PersonalizationStrategy>> getAllStrategies() async => _strategies.values.toList();
  @override
  Future<List<PersonalizationStrategy>> getStrategiesByUser(String userId) async =>
      _strategies.values.where((s) => s.userId == userId).toList();
  @override
  Future<List<PersonalizationStrategy>> getActiveStrategies() async =>
      _strategies.values.where((s) => s.isActive).toList();
  @override
  Future<void> updateStrategy(PersonalizationStrategy strategy) async =>
      _strategies[strategy.strategyId] = strategy;
  @override
  Future<void> deleteStrategy(String strategyId) async => _strategies.remove(strategyId);
  @override
  Future<int> getStrategyCount() async => _strategies.length;
  @override
  Future<double> getAverageConversionRate() async {
    if (_strategies.isEmpty) return 0;
    final sum = _strategies.values.fold<double>(0, (s, st) => s + st.conversionRate);
    return sum / _strategies.length;
  }
  @override
  Future<List<PersonalizationStrategy>> getEffectiveStrategies() async =>
      _strategies.values.where((s) => s.isEffective).toList();
  @override
  Future<void> clearAllStrategies() async => _strategies.clear();
  @override
  Future<Map<ExperienceType, int>> getStrategyCountByType() async {
    final result = <ExperienceType, int>{};
    for (final type in ExperienceType.values) {
      result[type] = _strategies.values.where((s) => s.experienceType == type).length;
    }
    return result;
  }

  @override
  Future<void> createJourney(UserJourney journey) async => _journeys[journey.journeyId] = journey;
  @override
  Future<UserJourney?> getJourney(String journeyId) async => _journeys[journeyId];
  @override
  Future<List<UserJourney>> getAllJourneys() async => _journeys.values.toList();
  @override
  Future<UserJourney?> getJourneyByUser(String userId) async =>
      _journeys.values.firstWhere((j) => j.userId == userId, orElse: () => null as dynamic);
  @override
  Future<void> updateJourney(UserJourney journey) async => _journeys[journey.journeyId] = journey;
  @override
  Future<void> deleteJourney(String journeyId) async => _journeys.remove(journeyId);
  @override
  Future<List<UserJourney>> getAtRiskJourneys() async =>
      _journeys.values.where((j) => j.isAtRisk).toList();
  @override
  Future<void> clearAllJourneys() async => _journeys.clear();
  @override
  Future<int> getJourneyCount() async => _journeys.length;
  @override
  Future<Map<JourneyStage, int>> getJourneyCountByStage() async {
    final result = <JourneyStage, int>{};
    for (final stage in JourneyStage.values) {
      result[stage] = _journeys.values.where((j) => j.currentStage == stage).length;
    }
    return result;
  }

  @override
  Future<void> createRecommendation(Recommendation recommendation) async =>
      _recommendations[recommendation.recommendationId] = recommendation;
  @override
  Future<Recommendation?> getRecommendation(String recommendationId) async =>
      _recommendations[recommendationId];
  @override
  Future<List<Recommendation>> getAllRecommendations() async => _recommendations.values.toList();
  @override
  Future<List<Recommendation>> getRecommendationsByUser(String userId) async =>
      _recommendations.values.where((r) => r.userId == userId).toList();
  @override
  Future<List<Recommendation>> getAcceptedRecommendations() async =>
      _recommendations.values.where((r) => r.wasAccepted).toList();
  @override
  Future<void> updateRecommendation(Recommendation recommendation) async =>
      _recommendations[recommendation.recommendationId] = recommendation;
  @override
  Future<void> deleteRecommendation(String recommendationId) async =>
      _recommendations.remove(recommendationId);
  @override
  Future<int> getRecommendationCount() async => _recommendations.length;
  @override
  Future<double> getAcceptanceRate() async {
    if (_recommendations.isEmpty) return 0;
    final accepted = _recommendations.values.where((r) => r.wasAccepted).length;
    return accepted / _recommendations.length;
  }
  @override
  Future<List<Recommendation>> getHighRelevanceRecommendations() async =>
      _recommendations.values.where((r) => r.isHighRelevance).toList();
  @override
  Future<void> clearAllRecommendations() async => _recommendations.clear();
  @override
  Future<Map<RecommendationType, int>> getCountByType() async {
    final result = <RecommendationType, int>{};
    for (final type in RecommendationType.values) {
      result[type] = _recommendations.values.where((r) => r.type == type).length;
    }
    return result;
  }

  @override
  Future<void> createABTest(ABTest test) async => _abTests[test.testId] = test;
  @override
  Future<ABTest?> getABTest(String testId) async => _abTests[testId];
  @override
  Future<List<ABTest>> getAllABTests() async => _abTests.values.toList();
  @override
  Future<List<ABTest>> getRunningTests() async =>
      _abTests.values.where((t) => t.isRunning).toList();
  @override
  Future<void> updateABTest(ABTest test) async => _abTests[test.testId] = test;
  @override
  Future<void> deleteABTest(String testId) async => _abTests.remove(testId);
  @override
  Future<List<ABTest>> getCompletedTests() async =>
      _abTests.values.where((t) => t.status == ABTestStatus.completed).toList();
  @override
  Future<void> clearAllABTests() async => _abTests.clear();
  @override
  Future<int> getABTestCount() async => _abTests.length;
  @override
  Future<Map<ABTestStatus, int>> getCountByStatus() async {
    final result = <ABTestStatus, int>{};
    for (final status in ABTestStatus.values) {
      result[status] = _abTests.values.where((t) => t.status == status).length;
    }
    return result;
  }

  @override
  Future<void> createSatisfactionRecord(UserSatisfaction satisfaction) async =>
      _satisfaction[satisfaction.satisfactionId] = satisfaction;
  @override
  Future<UserSatisfaction?> getSatisfactionRecord(String satisfactionId) async =>
      _satisfaction[satisfactionId];
  @override
  Future<List<UserSatisfaction>> getAllSatisfactionRecords() async => _satisfaction.values.toList();
  @override
  Future<List<UserSatisfaction>> getSatisfactionByUser(String userId) async =>
      _satisfaction.values.where((s) => s.userId == userId).toList();
  @override
  Future<List<UserSatisfaction>> getPositiveFeedback() async =>
      _satisfaction.values.where((s) => s.isPositive).toList();
  @override
  Future<void> updateSatisfactionRecord(UserSatisfaction satisfaction) async =>
      _satisfaction[satisfaction.satisfactionId] = satisfaction;
  @override
  Future<void> deleteSatisfactionRecord(String satisfactionId) async =>
      _satisfaction.remove(satisfactionId);
  @override
  Future<double> getAverageNPS() async {
    if (_satisfaction.isEmpty) return 0;
    final sum = _satisfaction.values.fold<int>(0, (s, sat) => s + sat.npsScore);
    return sum / _satisfaction.length;
  }
  @override
  Future<void> clearAllSatisfaction() async => _satisfaction.clear();
  @override
  Future<int> getSatisfactionCount() async => _satisfaction.length;

  @override
  Future<void> createAnalytics(ExperienceAnalytics analytics) async =>
      _analytics[analytics.analyticsId] = analytics;
  @override
  Future<ExperienceAnalytics?> getAnalytics(String analyticsId) async => _analytics[analyticsId];
  @override
  Future<List<ExperienceAnalytics>> getAllAnalytics() async => _analytics.values.toList();
  @override
  Future<ExperienceAnalytics?> getAnalyticsByUser(String userId) async =>
      _analytics[userId];
  @override
  Future<void> updateAnalytics(ExperienceAnalytics analytics) async =>
      _analytics[analytics.analyticsId] = analytics;
  @override
  Future<void> deleteAnalytics(String analyticsId) async => _analytics.remove(analyticsId);
  @override
  Future<double> getAverageClickThroughRate() async {
    if (_analytics.isEmpty) return 0;
    final sum = _analytics.values.fold<double>(0, (s, a) => s + a.clickThroughRate);
    return sum / _analytics.length;
  }
  @override
  Future<void> clearAllAnalytics() async => _analytics.clear();
  @override
  Future<int> getAnalyticsCount() async => _analytics.length;
  @override
  Future<List<ExperienceAnalytics>> getHighEngagementAnalytics() async =>
      _analytics.values.where((a) => a.hasGoodEngagement).toList();

  @override
  Future<void> createContent(ContentRelevance content) async =>
      _content[content.contentId] = content;
  @override
  Future<ContentRelevance?> getContent(String contentId) async => _content[contentId];
  @override
  Future<List<ContentRelevance>> getAllContent() async => _content.values.toList();
  @override
  Future<void> updateContent(ContentRelevance content) async =>
      _content[content.contentId] = content;
  @override
  Future<void> deleteContent(String contentId) async => _content.remove(contentId);
  @override
  Future<List<ContentRelevance>> getTrendingContent() async =>
      _content.values.where((c) => c.isTrending).toList();
  @override
  Future<void> clearAllContent() async => _content.clear();
  @override
  Future<int> getContentCount() async => _content.length;
}

class PersonalizationEngine {
  final ExperienceRepository repository;
  PersonalizationEngine(this.repository);

  Future<PersonalizationStrategy> generateStrategy(String userId, List<String> interests) async {
    final strategy = PersonalizationStrategy(
      strategyId: 'strat_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      experienceType: ExperienceType.personalized,
      rules: interests,
      parameters: {'interests': interests},
      isActive: true,
      conversionRate: 0.12,
      applicationsCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await repository.createStrategy(strategy);
    return strategy;
  }

  Future<void> optimizeStrategy(String strategyId, double newConversionRate) async {
    final strategy = await repository.getStrategy(strategyId);
    if (strategy != null) {
      await repository.updateStrategy(strategy.copyWith(
        conversionRate: newConversionRate,
        updatedAt: DateTime.now(),
      ));
    }
  }

  Future<List<PersonalizationStrategy>> getOptimalStrategies() async {
    return await repository.getEffectiveStrategies();
  }
}

class RecommendationEngine {
  final ExperienceRepository repository;
  RecommendationEngine(this.repository);

  Future<List<Recommendation>> generateRecommendations(String userId, List<String> tags) async {
    final recommendations = <Recommendation>[];
    for (int i = 0; i < 5; i++) {
      final rec = Recommendation(
        recommendationId: 'rec_${DateTime.now().millisecondsSinceEpoch}_$i',
        userId: userId,
        contentId: 'content_$i',
        type: RecommendationType.contentBased,
        relevanceScore: 0.7 + (i * 0.05),
        rationale: 'Based on your interests',
        wasAccepted: false,
        recommendedAt: DateTime.now(),
        acceptedAt: null,
      );
      recommendations.add(rec);
      await repository.createRecommendation(rec);
    }
    return recommendations;
  }

  Future<void> recordAcceptance(String recommendationId) async {
    final rec = await repository.getRecommendation(recommendationId);
    if (rec != null) {
      await repository.updateRecommendation(rec.copyWith(
        wasAccepted: true,
        acceptedAt: DateTime.now(),
      ));
    }
  }

  Future<double> calculateAcceptanceRate() => repository.getAcceptanceRate();
}

class JourneyEngine {
  final ExperienceRepository repository;
  JourneyEngine(this.repository);

  Future<UserJourney> initializeJourney(String userId) async {
    final journey = UserJourney(
      journeyId: 'journey_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      currentStage: JourneyStage.awareness,
      completedStages: [],
      stageEnteredAt: DateTime.now(),
      stageProgressPercentage: 0,
      touchpoints: [],
      createdAt: DateTime.now(),
    );
    await repository.createJourney(journey);
    return journey;
  }

  Future<void> advanceStage(String journeyId, JourneyStage nextStage) async {
    final journey = await repository.getJourney(journeyId);
    if (journey != null) {
      await repository.updateJourney(journey.copyWith(
        currentStage: nextStage,
        stageEnteredAt: DateTime.now(),
      ));
    }
  }

  Future<List<UserJourney>> getAtRiskJourneys() => repository.getAtRiskJourneys();
}

class ABTestingEngine {
  final ExperienceRepository repository;
  ABTestingEngine(this.repository);

  Future<ABTest> createTest(String name, List<String> variants) async {
    final test = ABTest(
      testId: 'test_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: 'A/B test for $name',
      status: ABTestStatus.running,
      variants: variants,
      controlVariant: variants.first,
      samplesPerVariant: 1000,
      confidenceLevel: 0.0,
      startedAt: DateTime.now(),
      completedAt: null,
      conversionRates: {for (var v in variants) v: 0.0},
    );
    await repository.createABTest(test);
    return test;
  }

  Future<void> concludeTest(String testId) async {
    final test = await repository.getABTest(testId);
    if (test != null) {
      await repository.updateABTest(test.copyWith(
        status: ABTestStatus.completed,
        completedAt: DateTime.now(),
      ));
    }
  }

  Future<bool> hasSignificance(String testId) async {
    final test = await repository.getABTest(testId);
    return test?.hasStatisticalSignificance ?? false;
  }
}

class ExperienceManager {
  final ExperienceRepository repository;
  late final PersonalizationEngine personalizationEngine;
  late final RecommendationEngine recommendationEngine;
  late final JourneyEngine journeyEngine;
  late final ABTestingEngine abTestingEngine;

  ExperienceManager(this.repository) {
    personalizationEngine = PersonalizationEngine(repository);
    recommendationEngine = RecommendationEngine(repository);
    journeyEngine = JourneyEngine(repository);
    abTestingEngine = ABTestingEngine(repository);
  }

  Future<int> getTotalUsers() => repository.getUserCount();
}

class ExperienceFacade {
  final ExperienceManager manager;

  ExperienceFacade(ExperienceRepository repository) : manager = ExperienceManager(repository);

  Future<void> createProfile(UserProfile profile) =>
      manager.repository.createUserProfile(profile);

  Future<UserProfile?> getProfile(String userId) =>
      manager.repository.getUserProfile(userId);

  Future<List<UserProfile>> getAllProfiles() =>
      manager.repository.getAllProfiles();

  Future<List<UserProfile>> getActiveUsers() =>
      manager.repository.getActiveProfiles();

  Future<PersonalizationStrategy> generatePersonalization(String userId, List<String> interests) =>
      manager.personalizationEngine.generateStrategy(userId, interests);

  Future<List<Recommendation>> generateRecommendations(String userId, List<String> tags) =>
      manager.recommendationEngine.generateRecommendations(userId, tags);

  Future<UserJourney> startJourney(String userId) =>
      manager.journeyEngine.initializeJourney(userId);

  Future<ABTest> createABTest(String name, List<String> variants) =>
      manager.abTestingEngine.createTest(name, variants);

  Future<double> getAverageEngagement() =>
      manager.repository.getAverageEngagementScore();

  Future<double> getAverageNPS() =>
      manager.repository.getAverageNPS();

  Future<ExperienceReport> generateReport() async {
    return ExperienceReport(
      reportId: 'report_${DateTime.now().millisecondsSinceEpoch}',
      totalUsers: await manager.repository.getUserCount(),
      averageEngagementScore: await manager.repository.getAverageEngagementScore(),
      conversionRateOverall: await manager.repository.getAverageConversionRate(),
      usersBySegment: await manager.repository.getUserCountBySegment(),
      experienceDistribution: await manager.repository.getStrategyCountByType(),
      averageNPS: await manager.repository.getAverageNPS(),
      generatedAt: DateTime.now(),
    );
  }
}
