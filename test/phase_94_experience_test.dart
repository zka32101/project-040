import 'package:test/test.dart';
import '../lib/models/experience_models.dart';
import '../lib/services/experience_service.dart';

void main() {
  late ExperienceRepository repository;

  setUp(() {
    repository = InMemoryExperienceRepository();
  });

  group('Phase 94: Advanced User Experience & Personalization', () {
    group('Enums', () {
      test('UserSegment has all values', () {
        expect(UserSegment.values.length, equals(8));
      });

      test('UserSegment.premium has correct displayName', () {
        expect(UserSegment.premium.displayName, contains('Premium'));
      });

      test('ExperienceType has all values', () {
        expect(ExperienceType.values.length, equals(7));
      });

      test('JourneyStage has all values', () {
        expect(JourneyStage.values.length, equals(9));
      });

      test('RecommendationType has all values', () {
        expect(RecommendationType.values.length, equals(7));
      });

      test('ABTestStatus has all values', () {
        expect(ABTestStatus.values.length, equals(5));
      });

      test('SatisfactionLevel has all values', () {
        expect(SatisfactionLevel.values.length, equals(5));
      });
    });

    group('UserProfile Model', () {
      test('UserProfile creation', () {
        final profile = UserProfile(
          userId: 'user1',
          name: 'John Doe',
          email: 'john@example.com',
          segment: UserSegment.premium,
          interests: ['tech', 'business'],
          preferences: ['email', 'sms'],
          engagementScore: 85,
          lifetimeValue: 15000,
          createdAt: DateTime(2025, 1, 1),
          lastActiveAt: DateTime.now(),
          totalInteractions: 150,
        );

        expect(profile.userId, equals('user1'));
        expect(profile.engagementScore, equals(85));
        expect(profile.isHighValue, isTrue);
      });

      test('UserProfile.isActive returns true for recent activity', () {
        final profile = UserProfile(
          userId: 'user1',
          name: 'Test',
          email: 'test@example.com',
          segment: UserSegment.standard,
          interests: [],
          preferences: [],
          engagementScore: 50,
          lifetimeValue: 5000,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          totalInteractions: 10,
        );

        expect(profile.isActive, isTrue);
      });

      test('UserProfile.isHighEngagement returns true for high score', () {
        final profile = UserProfile(
          userId: 'user1',
          name: 'Test',
          email: 'test@example.com',
          segment: UserSegment.standard,
          interests: [],
          preferences: [],
          engagementScore: 80,
          lifetimeValue: 5000,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          totalInteractions: 10,
        );

        expect(profile.isHighEngagement, isTrue);
      });

      test('UserProfile copyWith updates fields', () {
        final profile = UserProfile(
          userId: 'user1',
          name: 'Test',
          email: 'test@example.com',
          segment: UserSegment.basic,
          interests: [],
          preferences: [],
          engagementScore: 50,
          lifetimeValue: 1000,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          totalInteractions: 10,
        );

        final updated = profile.copyWith(segment: UserSegment.premium);
        expect(updated.segment, equals(UserSegment.premium));
        expect(updated.name, equals('Test'));
      });
    });

    group('PersonalizationStrategy Model', () {
      test('PersonalizationStrategy creation', () {
        final strategy = PersonalizationStrategy(
          strategyId: 'strat1',
          userId: 'user1',
          experienceType: ExperienceType.personalized,
          rules: ['rule1', 'rule2'],
          parameters: {'key': 'value'},
          isActive: true,
          conversionRate: 0.18,
          applicationsCount: 500,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(strategy.strategyId, equals('strat1'));
        expect(strategy.isEffective, isTrue);
      });

      test('PersonalizationStrategy.isEffective returns true for good rate', () {
        final strategy = PersonalizationStrategy(
          strategyId: 'strat1',
          userId: 'user1',
          experienceType: ExperienceType.adaptive,
          rules: [],
          parameters: {},
          isActive: true,
          conversionRate: 0.20,
          applicationsCount: 100,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(strategy.isEffective, isTrue);
      });
    });

    group('UserJourney Model', () {
      test('UserJourney creation', () {
        final journey = UserJourney(
          journeyId: 'journey1',
          userId: 'user1',
          currentStage: JourneyStage.consideration,
          completedStages: [JourneyStage.awareness],
          stageEnteredAt: DateTime.now(),
          stageProgressPercentage: 60,
          touchpoints: ['homepage', 'product_page'],
          createdAt: DateTime.now(),
        );

        expect(journey.currentStage, equals(JourneyStage.consideration));
        expect(journey.isOnTrack, isTrue);
      });

      test('UserJourney.isAtRisk returns true for low progress', () {
        final journey = UserJourney(
          journeyId: 'journey1',
          userId: 'user1',
          currentStage: JourneyStage.decision,
          completedStages: [],
          stageEnteredAt: DateTime.now(),
          stageProgressPercentage: 20,
          touchpoints: [],
          createdAt: DateTime.now(),
        );

        expect(journey.isAtRisk, isTrue);
      });
    });

    group('Recommendation Model', () {
      test('Recommendation creation', () {
        final rec = Recommendation(
          recommendationId: 'rec1',
          userId: 'user1',
          contentId: 'content1',
          type: RecommendationType.contentBased,
          relevanceScore: 0.85,
          rationale: 'Based on interests',
          wasAccepted: false,
          recommendedAt: DateTime.now(),
          acceptedAt: null,
        );

        expect(rec.isHighRelevance, isTrue);
        expect(rec.wasAccepted, isFalse);
      });

      test('Recommendation.isRecent returns true for new recommendations', () {
        final rec = Recommendation(
          recommendationId: 'rec1',
          userId: 'user1',
          contentId: 'content1',
          type: RecommendationType.mlPowered,
          relevanceScore: 0.80,
          rationale: 'ML based',
          wasAccepted: false,
          recommendedAt: DateTime.now(),
          acceptedAt: null,
        );

        expect(rec.isRecent, isTrue);
      });
    });

    group('ABTest Model', () {
      test('ABTest creation', () {
        final test = ABTest(
          testId: 'test1',
          name: 'Homepage CTA',
          description: 'Testing button colors',
          status: ABTestStatus.running,
          variants: ['blue', 'green', 'red'],
          controlVariant: 'blue',
          samplesPerVariant: 1000,
          confidenceLevel: 0.95,
          startedAt: DateTime.now(),
          completedAt: null,
          conversionRates: {'blue': 0.05, 'green': 0.06, 'red': 0.04},
        );

        expect(test.isRunning, isTrue);
        expect(test.hasStatisticalSignificance, isTrue);
      });
    });

    group('UserSatisfaction Model', () {
      test('UserSatisfaction creation', () {
        final satisfaction = UserSatisfaction(
          satisfactionId: 'sat1',
          userId: 'user1',
          level: SatisfactionLevel.satisfied,
          npsScore: 8,
          feedback: 'Good experience',
          category: 'product',
          measuredAt: DateTime.now(),
          actionTaken: false,
        );

        expect(satisfaction.isPositive, isTrue);
        expect(satisfaction.isPromoter, isTrue);
      });

      test('UserSatisfaction.isNegative returns true for low satisfaction', () {
        final satisfaction = UserSatisfaction(
          satisfactionId: 'sat1',
          userId: 'user1',
          level: SatisfactionLevel.dissatisfied,
          npsScore: 4,
          feedback: 'Poor service',
          category: 'support',
          measuredAt: DateTime.now(),
          actionTaken: false,
        );

        expect(satisfaction.isNegative, isTrue);
        expect(satisfaction.isDetractor, isTrue);
      });
    });

    group('ExperienceAnalytics Model', () {
      test('ExperienceAnalytics creation', () {
        final analytics = ExperienceAnalytics(
          analyticsId: 'ana1',
          userId: 'user1',
          viewsCount: 100,
          clicksCount: 10,
          averageTimeSpent: 45.5,
          conversionRate: 0.08,
          topPages: ['home', 'product'],
          period: DateTime.now(),
        );

        expect(analytics.clickThroughRate, equals(10.0));
        expect(analytics.hasGoodEngagement, isFalse);
      });
    });

    group('ContentRelevance Model', () {
      test('ContentRelevance creation', () {
        final content = ContentRelevance(
          contentId: 'content1',
          title: 'How to Use Product',
          tags: ['tutorial', 'guide'],
          relevanceScore: 0.88,
          viewCount: 1500,
          shareCount: 100,
          createdAt: DateTime.now(),
          isTrending: true,
        );

        expect(content.isPopular, isTrue);
        expect(content.isTrending, isTrue);
      });
    });

    group('InMemoryExperienceRepository - Profiles', () {
      test('createUserProfile stores profile', () async {
        final profile = UserProfile(
          userId: 'user1',
          name: 'Test User',
          email: 'test@example.com',
          segment: UserSegment.premium,
          interests: [],
          preferences: [],
          engagementScore: 75,
          lifetimeValue: 10000,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          totalInteractions: 50,
        );

        await repository.createUserProfile(profile);
        final retrieved = await repository.getUserProfile('user1');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Test User'));
      });

      test('getProfilesBySegment filters correctly', () async {
        final profile1 = UserProfile(
          userId: 'user1',
          name: 'Premium User',
          email: 'premium@example.com',
          segment: UserSegment.premium,
          interests: [],
          preferences: [],
          engagementScore: 90,
          lifetimeValue: 20000,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          totalInteractions: 100,
        );
        final profile2 = UserProfile(
          userId: 'user2',
          name: 'Basic User',
          email: 'basic@example.com',
          segment: UserSegment.basic,
          interests: [],
          preferences: [],
          engagementScore: 40,
          lifetimeValue: 500,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          totalInteractions: 10,
        );

        await repository.createUserProfile(profile1);
        await repository.createUserProfile(profile2);
        final premiumUsers = await repository.getProfilesBySegment(UserSegment.premium);

        expect(premiumUsers.length, equals(1));
        expect(premiumUsers[0].segment, equals(UserSegment.premium));
      });

      test('getActiveProfiles returns active users', () async {
        final profile = UserProfile(
          userId: 'user1',
          name: 'Active User',
          email: 'active@example.com',
          segment: UserSegment.standard,
          interests: [],
          preferences: [],
          engagementScore: 70,
          lifetimeValue: 8000,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          totalInteractions: 30,
        );

        await repository.createUserProfile(profile);
        final active = await repository.getActiveProfiles();

        expect(active.length, equals(1));
        expect(active[0].isActive, isTrue);
      });

      test('getHighValueUsers returns high value customers', () async {
        final profile = UserProfile(
          userId: 'user1',
          name: 'VIP User',
          email: 'vip@example.com',
          segment: UserSegment.vip,
          interests: [],
          preferences: [],
          engagementScore: 95,
          lifetimeValue: 25000,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          totalInteractions: 200,
        );

        await repository.createUserProfile(profile);
        final highValue = await repository.getHighValueUsers();

        expect(highValue.length, equals(1));
        expect(highValue[0].isHighValue, isTrue);
      });

      test('getAverageEngagementScore calculates correctly', () async {
        final profile1 = UserProfile(
          userId: 'user1',
          name: 'User 1',
          email: 'user1@example.com',
          segment: UserSegment.standard,
          interests: [],
          preferences: [],
          engagementScore: 80,
          lifetimeValue: 5000,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          totalInteractions: 50,
        );
        final profile2 = UserProfile(
          userId: 'user2',
          name: 'User 2',
          email: 'user2@example.com',
          segment: UserSegment.standard,
          interests: [],
          preferences: [],
          engagementScore: 60,
          lifetimeValue: 3000,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          totalInteractions: 20,
        );

        await repository.createUserProfile(profile1);
        await repository.createUserProfile(profile2);
        final avg = await repository.getAverageEngagementScore();

        expect(avg, equals(70));
      });
    });

    group('InMemoryExperienceRepository - Strategies', () {
      test('createStrategy stores strategy', () async {
        final strategy = PersonalizationStrategy(
          strategyId: 'strat1',
          userId: 'user1',
          experienceType: ExperienceType.personalized,
          rules: ['rule1'],
          parameters: {},
          isActive: true,
          conversionRate: 0.15,
          applicationsCount: 100,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.createStrategy(strategy);
        final retrieved = await repository.getStrategy('strat1');

        expect(retrieved, isNotNull);
        expect(retrieved!.experienceType, equals(ExperienceType.personalized));
      });

      test('getActiveStrategies filters correctly', () async {
        final strategy = PersonalizationStrategy(
          strategyId: 'strat1',
          userId: 'user1',
          experienceType: ExperienceType.adaptive,
          rules: [],
          parameters: {},
          isActive: true,
          conversionRate: 0.12,
          applicationsCount: 50,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.createStrategy(strategy);
        final active = await repository.getActiveStrategies();

        expect(active.length, equals(1));
      });

      test('getEffectiveStrategies returns high performing strategies', () async {
        final strategy = PersonalizationStrategy(
          strategyId: 'strat1',
          userId: 'user1',
          experienceType: ExperienceType.personalized,
          rules: [],
          parameters: {},
          isActive: true,
          conversionRate: 0.20,
          applicationsCount: 200,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await repository.createStrategy(strategy);
        final effective = await repository.getEffectiveStrategies();

        expect(effective.length, equals(1));
        expect(effective[0].isEffective, isTrue);
      });
    });

    group('InMemoryExperienceRepository - Journeys', () {
      test('createJourney stores journey', () async {
        final journey = UserJourney(
          journeyId: 'journey1',
          userId: 'user1',
          currentStage: JourneyStage.awareness,
          completedStages: [],
          stageEnteredAt: DateTime.now(),
          stageProgressPercentage: 0,
          touchpoints: [],
          createdAt: DateTime.now(),
        );

        await repository.createJourney(journey);
        final retrieved = await repository.getJourney('journey1');

        expect(retrieved, isNotNull);
        expect(retrieved!.currentStage, equals(JourneyStage.awareness));
      });

      test('getAtRiskJourneys returns at-risk journeys', () async {
        final journey = UserJourney(
          journeyId: 'journey1',
          userId: 'user1',
          currentStage: JourneyStage.decision,
          completedStages: [],
          stageEnteredAt: DateTime.now(),
          stageProgressPercentage: 25,
          touchpoints: [],
          createdAt: DateTime.now(),
        );

        await repository.createJourney(journey);
        final atRisk = await repository.getAtRiskJourneys();

        expect(atRisk.length, equals(1));
        expect(atRisk[0].isAtRisk, isTrue);
      });
    });

    group('InMemoryExperienceRepository - Recommendations', () {
      test('createRecommendation stores recommendation', () async {
        final rec = Recommendation(
          recommendationId: 'rec1',
          userId: 'user1',
          contentId: 'content1',
          type: RecommendationType.contentBased,
          relevanceScore: 0.80,
          rationale: 'Relevant',
          wasAccepted: false,
          recommendedAt: DateTime.now(),
          acceptedAt: null,
        );

        await repository.createRecommendation(rec);
        final retrieved = await repository.getRecommendation('rec1');

        expect(retrieved, isNotNull);
        expect(retrieved!.type, equals(RecommendationType.contentBased));
      });

      test('getAcceptedRecommendations filters correctly', () async {
        final rec1 = Recommendation(
          recommendationId: 'rec1',
          userId: 'user1',
          contentId: 'content1',
          type: RecommendationType.contentBased,
          relevanceScore: 0.80,
          rationale: 'Test',
          wasAccepted: true,
          recommendedAt: DateTime.now(),
          acceptedAt: DateTime.now(),
        );
        final rec2 = Recommendation(
          recommendationId: 'rec2',
          userId: 'user1',
          contentId: 'content2',
          type: RecommendationType.mlPowered,
          relevanceScore: 0.70,
          rationale: 'Test',
          wasAccepted: false,
          recommendedAt: DateTime.now(),
          acceptedAt: null,
        );

        await repository.createRecommendation(rec1);
        await repository.createRecommendation(rec2);
        final accepted = await repository.getAcceptedRecommendations();

        expect(accepted.length, equals(1));
      });

      test('getAcceptanceRate calculates correctly', () async {
        final rec1 = Recommendation(
          recommendationId: 'rec1',
          userId: 'user1',
          contentId: 'content1',
          type: RecommendationType.contentBased,
          relevanceScore: 0.80,
          rationale: 'Test',
          wasAccepted: true,
          recommendedAt: DateTime.now(),
          acceptedAt: DateTime.now(),
        );
        final rec2 = Recommendation(
          recommendationId: 'rec2',
          userId: 'user1',
          contentId: 'content2',
          type: RecommendationType.mlPowered,
          relevanceScore: 0.70,
          rationale: 'Test',
          wasAccepted: false,
          recommendedAt: DateTime.now(),
          acceptedAt: null,
        );

        await repository.createRecommendation(rec1);
        await repository.createRecommendation(rec2);
        final rate = await repository.getAcceptanceRate();

        expect(rate, equals(0.5));
      });
    });

    group('InMemoryExperienceRepository - A/B Tests', () {
      test('createABTest stores test', () async {
        final test = ABTest(
          testId: 'test1',
          name: 'CTA Button Test',
          description: 'Testing buttons',
          status: ABTestStatus.running,
          variants: ['control', 'variant1'],
          controlVariant: 'control',
          samplesPerVariant: 1000,
          confidenceLevel: 0.95,
          startedAt: DateTime.now(),
          completedAt: null,
          conversionRates: {'control': 0.05, 'variant1': 0.06},
        );

        await repository.createABTest(test);
        final retrieved = await repository.getABTest('test1');

        expect(retrieved, isNotNull);
        expect(retrieved!.status, equals(ABTestStatus.running));
      });

      test('getRunningTests returns running tests', () async {
        final test = ABTest(
          testId: 'test1',
          name: 'Test',
          description: 'Running test',
          status: ABTestStatus.running,
          variants: ['a', 'b'],
          controlVariant: 'a',
          samplesPerVariant: 500,
          confidenceLevel: 0.90,
          startedAt: DateTime.now(),
          completedAt: null,
          conversionRates: {'a': 0.04, 'b': 0.05},
        );

        await repository.createABTest(test);
        final running = await repository.getRunningTests();

        expect(running.length, equals(1));
        expect(running[0].isRunning, isTrue);
      });
    });

    group('InMemoryExperienceRepository - Satisfaction', () {
      test('createSatisfactionRecord stores record', () async {
        final satisfaction = UserSatisfaction(
          satisfactionId: 'sat1',
          userId: 'user1',
          level: SatisfactionLevel.satisfied,
          npsScore: 8,
          feedback: 'Good',
          category: 'product',
          measuredAt: DateTime.now(),
          actionTaken: false,
        );

        await repository.createSatisfactionRecord(satisfaction);
        final retrieved = await repository.getSatisfactionRecord('sat1');

        expect(retrieved, isNotNull);
        expect(retrieved!.npsScore, equals(8));
      });

      test('getPositiveFeedback returns satisfied users', () async {
        final satisfaction = UserSatisfaction(
          satisfactionId: 'sat1',
          userId: 'user1',
          level: SatisfactionLevel.verySatisfied,
          npsScore: 9,
          feedback: 'Excellent',
          category: 'support',
          measuredAt: DateTime.now(),
          actionTaken: false,
        );

        await repository.createSatisfactionRecord(satisfaction);
        final positive = await repository.getPositiveFeedback();

        expect(positive.length, equals(1));
        expect(positive[0].isPositive, isTrue);
      });

      test('getAverageNPS calculates correctly', () async {
        final sat1 = UserSatisfaction(
          satisfactionId: 'sat1',
          userId: 'user1',
          level: SatisfactionLevel.satisfied,
          npsScore: 8,
          feedback: 'Good',
          category: 'product',
          measuredAt: DateTime.now(),
          actionTaken: false,
        );
        final sat2 = UserSatisfaction(
          satisfactionId: 'sat2',
          userId: 'user2',
          level: SatisfactionLevel.neutral,
          npsScore: 6,
          feedback: 'OK',
          category: 'product',
          measuredAt: DateTime.now(),
          actionTaken: false,
        );

        await repository.createSatisfactionRecord(sat1);
        await repository.createSatisfactionRecord(sat2);
        final avgNPS = await repository.getAverageNPS();

        expect(avgNPS, equals(7));
      });
    });

    group('PersonalizationEngine', () {
      late PersonalizationEngine engine;

      setUp(() {
        engine = PersonalizationEngine(repository);
      });

      test('generateStrategy creates strategy', () async {
        final strategy = await engine.generateStrategy('user1', ['tech', 'business']);
        
        expect(strategy.userId, equals('user1'));
        expect(strategy.isActive, isTrue);
      });

      test('getOptimalStrategies returns effective ones', () async {
        await engine.generateStrategy('user1', ['test']);
        final optimal = await engine.getOptimalStrategies();
        
        expect(optimal, isNotEmpty);
      });
    });

    group('RecommendationEngine', () {
      late RecommendationEngine engine;

      setUp(() {
        engine = RecommendationEngine(repository);
      });

      test('generateRecommendations creates recommendations', () async {
        final recs = await engine.generateRecommendations('user1', ['tag1']);
        
        expect(recs.length, equals(5));
        expect(recs[0].userId, equals('user1'));
      });
    });

    group('JourneyEngine', () {
      late JourneyEngine engine;

      setUp(() {
        engine = JourneyEngine(repository);
      });

      test('initializeJourney creates new journey', () async {
        final journey = await engine.initializeJourney('user1');
        
        expect(journey.userId, equals('user1'));
        expect(journey.currentStage, equals(JourneyStage.awareness));
      });

      test('getAtRiskJourneys returns at-risk journeys', () async {
        await engine.initializeJourney('user1');
        final atRisk = await engine.getAtRiskJourneys();
        
        expect(atRisk, isNotEmpty);
      });
    });

    group('ExperienceFacade', () {
      late ExperienceFacade facade;

      setUp(() {
        facade = ExperienceFacade(repository);
      });

      test('createProfile and getProfile through facade', () async {
        final profile = UserProfile(
          userId: 'user1',
          name: 'Test',
          email: 'test@example.com',
          segment: UserSegment.standard,
          interests: [],
          preferences: [],
          engagementScore: 50,
          lifetimeValue: 5000,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          totalInteractions: 20,
        );

        await facade.createProfile(profile);
        final retrieved = await facade.getProfile('user1');

        expect(retrieved!.name, equals('Test'));
      });

      test('generateReport creates comprehensive report', () async {
        final report = await facade.generateReport();
        
        expect(report.reportId, isNotNull);
        expect(report.generatedAt, isNotNull);
      });

      test('getAverageEngagement returns valid value', () async {
        final engagement = await facade.getAverageEngagement();
        
        expect(engagement, greaterThanOrEqualTo(0));
      });
    });

    group('Integration Tests', () {
      late ExperienceFacade facade;

      setUp(() {
        facade = ExperienceFacade(repository);
      });

      test('complete user experience workflow', () async {
        // Create user
        final profile = UserProfile(
          userId: 'user1',
          name: 'Integration Test User',
          email: 'integration@example.com',
          segment: UserSegment.standard,
          interests: ['tech', 'business'],
          preferences: ['email'],
          engagementScore: 60,
          lifetimeValue: 8000,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
          totalInteractions: 30,
        );
        await facade.createProfile(profile);

        // Generate personalization
        await facade.generatePersonalization('user1', ['tech']);

        // Generate recommendations
        await facade.generateRecommendations('user1', ['tech']);

        // Start journey
        await facade.startJourney('user1');

        // Create A/B test
        await facade.createABTest('CTA Test', ['blue', 'green']);

        // Verify all components work
        final users = await facade.getAllProfiles();
        expect(users.length, equals(1));
      });
    });
  });
}
