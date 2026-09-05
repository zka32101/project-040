import 'package:test/test.dart';
import '../lib/models/product_models.dart';
import '../lib/services/product_service.dart';

void main() {
  late ProductRepository repository;

  setUp(() {
    repository = InMemoryProductRepository();
  });

  group('Phase 93: Advanced Innovation & Product Development', () {
    group('ProductStage Enum', () {
      test('ProductStage has all required stages', () {
        expect(ProductStage.values.length, equals(8));
      });

      test('ProductStage.ideation has correct displayName', () {
        expect(ProductStage.ideation.displayName, equals('Ideation / アイデーション'));
      });

      test('ProductStage.decline has correct displayName', () {
        expect(ProductStage.decline.displayName, contains('Decline'));
      });
    });

    group('FeaturePriority Enum', () {
      test('FeaturePriority has all levels', () {
        expect(FeaturePriority.values.length, equals(5));
      });

      test('FeaturePriority.critical has correct displayName', () {
        expect(FeaturePriority.critical.displayName, contains('Critical'));
      });
    });

    group('Product Model', () {
      test('Product creation with all fields', () {
        final product = Product(
          id: 'prod1',
          name: 'Test Product',
          description: 'A test product',
          stage: ProductStage.ideation,
          launchDate: DateTime(2025, 6, 1),
          ownerTeam: 'Team A',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Enterprise',
          createdAt: DateTime(2025, 1, 1),
        );

        expect(product.id, equals('prod1'));
        expect(product.name, equals('Test Product'));
        expect(product.stage, equals(ProductStage.ideation));
      });

      test('Product.isLaunched returns true for launched stage', () {
        final product = Product(
          id: 'prod1',
          name: 'Test',
          description: '',
          stage: ProductStage.launch,
          launchDate: DateTime.now(),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now(),
        );

        expect(product.isLaunched, isTrue);
      });

      test('Product.ageInDays calculates correctly', () {
        final product = Product(
          id: 'prod1',
          name: 'Test',
          description: '',
          stage: ProductStage.ideation,
          launchDate: DateTime.now(),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now().subtract(Duration(days: 10)),
        );

        expect(product.ageInDays, greaterThanOrEqualTo(10));
      });

      test('Product.daysToLaunch calculates correctly', () {
        final product = Product(
          id: 'prod1',
          name: 'Test',
          description: '',
          stage: ProductStage.development,
          launchDate: DateTime.now().add(Duration(days: 30)),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now(),
        );

        expect(product.daysToLaunch, lessThanOrEqualTo(30));
      });

      test('Product copyWith updates fields', () {
        final product = Product(
          id: 'prod1',
          name: 'Test',
          description: '',
          stage: ProductStage.ideation,
          launchDate: DateTime.now(),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now(),
        );

        final updated = product.copyWith(stage: ProductStage.development);
        expect(updated.stage, equals(ProductStage.development));
        expect(updated.name, equals('Test'));
      });
    });

    group('Feature Model', () {
      test('Feature creation with all fields', () {
        final feature = Feature(
          id: 'feat1',
          productId: 'prod1',
          name: 'Test Feature',
          description: 'A test feature',
          priority: FeaturePriority.high,
          status: FeatureStatus.inDevelopment,
          targetReleaseDate: DateTime(2025, 6, 1),
          createdAt: DateTime(2025, 1, 1),
        );

        expect(feature.id, equals('feat1'));
        expect(feature.priority, equals(FeaturePriority.high));
      });

      test('Feature.isReleased returns true for released status', () {
        final feature = Feature(
          id: 'feat1',
          productId: 'prod1',
          name: 'Test',
          description: '',
          priority: FeaturePriority.high,
          status: FeatureStatus.released,
          targetReleaseDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        expect(feature.isReleased, isTrue);
      });

      test('Feature.isOverdue returns true when past target date', () {
        final feature = Feature(
          id: 'feat1',
          productId: 'prod1',
          name: 'Test',
          description: '',
          priority: FeaturePriority.high,
          status: FeatureStatus.inDevelopment,
          targetReleaseDate: DateTime.now().subtract(Duration(days: 10)),
          createdAt: DateTime.now().subtract(Duration(days: 20)),
        );

        expect(feature.isOverdue, isTrue);
      });
    });

    group('Innovation Model', () {
      test('Innovation creation with all fields', () {
        final innovation = Innovation(
          id: 'innov1',
          name: 'Test Innovation',
          description: 'A test innovation',
          type: InnovationType.disruptive,
          expectedROI: 250,
          riskLevel: 'high',
          isApproved: false,
          createdAt: DateTime(2025, 1, 1),
        );

        expect(innovation.id, equals('innov1'));
        expect(innovation.type, equals(InnovationType.disruptive));
        expect(innovation.expectedROI, equals(250));
      });

      test('Innovation.hasHighROI returns true for ROI > 150', () {
        final innovation = Innovation(
          id: 'innov1',
          name: 'Test',
          description: '',
          type: InnovationType.incremental,
          expectedROI: 200,
          riskLevel: 'medium',
          isApproved: false,
          createdAt: DateTime.now(),
        );

        expect(innovation.hasHighROI, isTrue);
      });

      test('Innovation.isHighRisk returns true for high risk level', () {
        final innovation = Innovation(
          id: 'innov1',
          name: 'Test',
          description: '',
          type: InnovationType.disruptive,
          expectedROI: 100,
          riskLevel: 'high',
          isApproved: false,
          createdAt: DateTime.now(),
        );

        expect(innovation.isHighRisk, isTrue);
      });
    });

    group('InMemoryProductRepository - Products', () {
      test('createProduct stores product', () async {
        final product = Product(
          id: 'prod1',
          name: 'Test',
          description: '',
          stage: ProductStage.ideation,
          launchDate: DateTime.now(),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now(),
        );

        await repository.createProduct(product);
        final retrieved = await repository.getProduct('prod1');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Test'));
      });

      test('getProduct returns null for non-existent product', () async {
        final product = await repository.getProduct('nonexistent');
        expect(product, isNull);
      });

      test('getAllProducts returns empty list initially', () async {
        final products = await repository.getAllProducts();
        expect(products, isEmpty);
      });

      test('getProductsByStage filters correctly', () async {
        final prod1 = Product(
          id: 'prod1',
          name: 'Prod1',
          description: '',
          stage: ProductStage.ideation,
          launchDate: DateTime.now(),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now(),
        );
        final prod2 = Product(
          id: 'prod2',
          name: 'Prod2',
          description: '',
          stage: ProductStage.development,
          launchDate: DateTime.now(),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now(),
        );

        await repository.createProduct(prod1);
        await repository.createProduct(prod2);
        final ideationProducts =
            await repository.getProductsByStage(ProductStage.ideation);

        expect(ideationProducts.length, equals(1));
        expect(ideationProducts[0].id, equals('prod1'));
      });

      test('updateProduct modifies existing product', () async {
        final product = Product(
          id: 'prod1',
          name: 'Original',
          description: '',
          stage: ProductStage.ideation,
          launchDate: DateTime.now(),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now(),
        );

        await repository.createProduct(product);
        final updated = product.copyWith(name: 'Updated');
        await repository.updateProduct(updated);
        final retrieved = await repository.getProduct('prod1');

        expect(retrieved!.name, equals('Updated'));
      });

      test('deleteProduct removes product', () async {
        final product = Product(
          id: 'prod1',
          name: 'Test',
          description: '',
          stage: ProductStage.ideation,
          launchDate: DateTime.now(),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now(),
        );

        await repository.createProduct(product);
        await repository.deleteProduct('prod1');
        final retrieved = await repository.getProduct('prod1');

        expect(retrieved, isNull);
      });

      test('getProductCount returns correct count', () async {
        final prod1 = Product(
          id: 'prod1',
          name: 'Prod1',
          description: '',
          stage: ProductStage.ideation,
          launchDate: DateTime.now(),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now(),
        );
        final prod2 = Product(
          id: 'prod2',
          name: 'Prod2',
          description: '',
          stage: ProductStage.ideation,
          launchDate: DateTime.now(),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now(),
        );

        await repository.createProduct(prod1);
        await repository.createProduct(prod2);
        final count = await repository.getProductCount();

        expect(count, equals(2));
      });

      test('clearAllProducts removes all products', () async {
        final product = Product(
          id: 'prod1',
          name: 'Test',
          description: '',
          stage: ProductStage.ideation,
          launchDate: DateTime.now(),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now(),
        );

        await repository.createProduct(product);
        await repository.clearAllProducts();
        final count = await repository.getProductCount();

        expect(count, equals(0));
      });
    });

    group('InMemoryProductRepository - Features', () {
      test('createFeature stores feature', () async {
        final feature = Feature(
          id: 'feat1',
          productId: 'prod1',
          name: 'Test Feature',
          description: '',
          priority: FeaturePriority.high,
          status: FeatureStatus.inDevelopment,
          targetReleaseDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await repository.createFeature(feature);
        final retrieved = await repository.getFeature('feat1');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Test Feature'));
      });

      test('getFeaturesByProduct filters correctly', () async {
        final feat1 = Feature(
          id: 'feat1',
          productId: 'prod1',
          name: 'Feature1',
          description: '',
          priority: FeaturePriority.high,
          status: FeatureStatus.inDevelopment,
          targetReleaseDate: DateTime.now(),
          createdAt: DateTime.now(),
        );
        final feat2 = Feature(
          id: 'feat2',
          productId: 'prod2',
          name: 'Feature2',
          description: '',
          priority: FeaturePriority.high,
          status: FeatureStatus.inDevelopment,
          targetReleaseDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await repository.createFeature(feat1);
        await repository.createFeature(feat2);
        final productFeatures =
            await repository.getFeaturesByProduct('prod1');

        expect(productFeatures.length, equals(1));
        expect(productFeatures[0].productId, equals('prod1'));
      });

      test('getFeaturesByStatus filters correctly', () async {
        final feat1 = Feature(
          id: 'feat1',
          productId: 'prod1',
          name: 'Feature1',
          description: '',
          priority: FeaturePriority.high,
          status: FeatureStatus.inDevelopment,
          targetReleaseDate: DateTime.now(),
          createdAt: DateTime.now(),
        );
        final feat2 = Feature(
          id: 'feat2',
          productId: 'prod1',
          name: 'Feature2',
          description: '',
          priority: FeaturePriority.high,
          status: FeatureStatus.released,
          targetReleaseDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await repository.createFeature(feat1);
        await repository.createFeature(feat2);
        final inDevFeatures =
            await repository.getFeaturesByStatus(FeatureStatus.inDevelopment);

        expect(inDevFeatures.length, equals(1));
        expect(inDevFeatures[0].id, equals('feat1'));
      });

      test('getOverdueFeatures returns overdue items', () async {
        final feature = Feature(
          id: 'feat1',
          productId: 'prod1',
          name: 'Overdue Feature',
          description: '',
          priority: FeaturePriority.high,
          status: FeatureStatus.inDevelopment,
          targetReleaseDate: DateTime.now().subtract(Duration(days: 5)),
          createdAt: DateTime.now().subtract(Duration(days: 20)),
        );

        await repository.createFeature(feature);
        final overdueFeatures = await repository.getOverdueFeatures();

        expect(overdueFeatures.length, equals(1));
      });

      test('getFeatureCount returns correct count', () async {
        final feature = Feature(
          id: 'feat1',
          productId: 'prod1',
          name: 'Feature',
          description: '',
          priority: FeaturePriority.high,
          status: FeatureStatus.inDevelopment,
          targetReleaseDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await repository.createFeature(feature);
        final count = await repository.getFeatureCount();

        expect(count, equals(1));
      });
    });

    group('InMemoryProductRepository - Innovations', () {
      test('createInnovation stores innovation', () async {
        final innovation = Innovation(
          id: 'innov1',
          name: 'Test Innovation',
          description: '',
          type: InnovationType.disruptive,
          expectedROI: 200,
          riskLevel: 'medium',
          isApproved: false,
          createdAt: DateTime.now(),
        );

        await repository.createInnovation(innovation);
        final retrieved = await repository.getInnovation('innov1');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Test Innovation'));
      });

      test('getInnovationsByType filters correctly', () async {
        final innov1 = Innovation(
          id: 'innov1',
          name: 'Disruptive',
          description: '',
          type: InnovationType.disruptive,
          expectedROI: 200,
          riskLevel: 'high',
          isApproved: false,
          createdAt: DateTime.now(),
        );
        final innov2 = Innovation(
          id: 'innov2',
          name: 'Incremental',
          description: '',
          type: InnovationType.incremental,
          expectedROI: 100,
          riskLevel: 'low',
          isApproved: false,
          createdAt: DateTime.now(),
        );

        await repository.createInnovation(innov1);
        await repository.createInnovation(innov2);
        final disruptive =
            await repository.getInnovationsByType(InnovationType.disruptive);

        expect(disruptive.length, equals(1));
        expect(disruptive[0].type, equals(InnovationType.disruptive));
      });

      test('getHighROIInnovations returns high ROI items', () async {
        final innovation = Innovation(
          id: 'innov1',
          name: 'High ROI',
          description: '',
          type: InnovationType.disruptive,
          expectedROI: 250,
          riskLevel: 'medium',
          isApproved: false,
          createdAt: DateTime.now(),
        );

        await repository.createInnovation(innovation);
        final highROI = await repository.getHighROIInnovations();

        expect(highROI.length, equals(1));
        expect(highROI[0].hasHighROI, isTrue);
      });

      test('getHighRiskInnovations returns high risk items', () async {
        final innovation = Innovation(
          id: 'innov1',
          name: 'High Risk',
          description: '',
          type: InnovationType.disruptive,
          expectedROI: 100,
          riskLevel: 'high',
          isApproved: false,
          createdAt: DateTime.now(),
        );

        await repository.createInnovation(innovation);
        final highRisk = await repository.getHighRiskInnovations();

        expect(highRisk.length, equals(1));
        expect(highRisk[0].isHighRisk, isTrue);
      });

      test('getInnovationCount returns correct count', () async {
        final innovation = Innovation(
          id: 'innov1',
          name: 'Innovation',
          description: '',
          type: InnovationType.incremental,
          expectedROI: 100,
          riskLevel: 'low',
          isApproved: false,
          createdAt: DateTime.now(),
        );

        await repository.createInnovation(innovation);
        final count = await repository.getInnovationCount();

        expect(count, equals(1));
      });
    });

    group('InMemoryProductRepository - Roadmaps', () {
      test('createRoadmap stores roadmap', () async {
        final roadmap = ProductRoadmap(
          id: 'roadmap1',
          productId: 'prod1',
          quarter: RoadmapQuarter.q1,
          theme: 'Q1 Focus',
          targetDeliveries: ['Feature A', 'Feature B'],
          completedDeliveries: [],
          createdAt: DateTime.now(),
        );

        await repository.createRoadmap(roadmap);
        final retrieved = await repository.getRoadmap('roadmap1');

        expect(retrieved, isNotNull);
        expect(retrieved!.quarter, equals(RoadmapQuarter.q1));
      });

      test('getRoadmapsByProduct filters correctly', () async {
        final roadmap = ProductRoadmap(
          id: 'roadmap1',
          productId: 'prod1',
          quarter: RoadmapQuarter.q1,
          theme: 'Q1',
          targetDeliveries: [],
          completedDeliveries: [],
          createdAt: DateTime.now(),
        );

        await repository.createRoadmap(roadmap);
        final productRoadmaps =
            await repository.getRoadmapsByProduct('prod1');

        expect(productRoadmaps.length, equals(1));
      });

      test('getCompleteRoadmaps returns completed roadmaps', () async {
        final roadmap = ProductRoadmap(
          id: 'roadmap1',
          productId: 'prod1',
          quarter: RoadmapQuarter.q1,
          theme: 'Q1',
          targetDeliveries: ['Feature A'],
          completedDeliveries: ['Feature A'],
          createdAt: DateTime.now(),
        );

        await repository.createRoadmap(roadmap);
        final completed = await repository.getCompleteRoadmaps();

        expect(completed.length, equals(1));
        expect(completed[0].isComplete, isTrue);
      });
    });

    group('InMemoryProductRepository - User Feedback', () {
      test('createFeedback stores feedback', () async {
        final feedback = UserFeedback(
          id: 'fb1',
          productId: 'prod1',
          userId: 'user1',
          comment: 'Great product',
          sentimentScore: 0.8,
          createdAt: DateTime.now(),
        );

        await repository.createFeedback(feedback);
        final retrieved = await repository.getFeedback('fb1');

        expect(retrieved, isNotNull);
        expect(retrieved!.userId, equals('user1'));
      });

      test('getFeedbackByProduct filters correctly', () async {
        final feedback = UserFeedback(
          id: 'fb1',
          productId: 'prod1',
          userId: 'user1',
          comment: 'Good',
          sentimentScore: 0.7,
          createdAt: DateTime.now(),
        );

        await repository.createFeedback(feedback);
        final productFeedback =
            await repository.getFeedbackByProduct('prod1');

        expect(productFeedback.length, equals(1));
      });

      test('getPositiveFeedback returns positive sentiment', () async {
        final feedback = UserFeedback(
          id: 'fb1',
          productId: 'prod1',
          userId: 'user1',
          comment: 'Excellent',
          sentimentScore: 0.9,
          createdAt: DateTime.now(),
        );

        await repository.createFeedback(feedback);
        final positive = await repository.getPositiveFeedback();

        expect(positive.length, equals(1));
        expect(positive[0].isPositive, isTrue);
      });

      test('getAverageSentimentScore calculates correctly', () async {
        final fb1 = UserFeedback(
          id: 'fb1',
          productId: 'prod1',
          userId: 'user1',
          comment: 'Good',
          sentimentScore: 0.8,
          createdAt: DateTime.now(),
        );
        final fb2 = UserFeedback(
          id: 'fb2',
          productId: 'prod1',
          userId: 'user2',
          comment: 'Bad',
          sentimentScore: 0.2,
          createdAt: DateTime.now(),
        );

        await repository.createFeedback(fb1);
        await repository.createFeedback(fb2);
        final avgScore = await repository.getAverageSentimentScore();

        expect(avgScore, equals(0.5));
      });
    });

    group('InMemoryProductRepository - Metrics', () {
      test('createMetric stores metric', () async {
        final metric = ProductMetric(
          id: 'metric1',
          productId: 'prod1',
          name: 'Daily Active Users',
          value: 5000,
          target: 10000,
          unit: 'users',
          createdAt: DateTime.now(),
        );

        await repository.createMetric(metric);
        final retrieved = await repository.getMetric('metric1');

        expect(retrieved, isNotNull);
        expect(retrieved!.value, equals(5000));
      });

      test('getMetricsByProduct filters correctly', () async {
        final metric = ProductMetric(
          id: 'metric1',
          productId: 'prod1',
          name: 'DAU',
          value: 5000,
          target: 10000,
          unit: 'users',
          createdAt: DateTime.now(),
        );

        await repository.createMetric(metric);
        final productMetrics =
            await repository.getMetricsByProduct('prod1');

        expect(productMetrics.length, equals(1));
      });

      test('getMetricsNotMeetingTarget filters correctly', () async {
        final metric = ProductMetric(
          id: 'metric1',
          productId: 'prod1',
          name: 'DAU',
          value: 3000,
          target: 10000,
          unit: 'users',
          createdAt: DateTime.now(),
        );

        await repository.createMetric(metric);
        final notMeeting =
            await repository.getMetricsNotMeetingTarget();

        expect(notMeeting.length, equals(1));
        expect(notMeeting[0].meetsTarget, isFalse);
      });

      test('getAverageMetricValue calculates correctly', () async {
        final m1 = ProductMetric(
          id: 'metric1',
          productId: 'prod1',
          name: 'M1',
          value: 100,
          target: 150,
          unit: 'unit',
          createdAt: DateTime.now(),
        );
        final m2 = ProductMetric(
          id: 'metric2',
          productId: 'prod1',
          name: 'M2',
          value: 200,
          target: 150,
          unit: 'unit',
          createdAt: DateTime.now(),
        );

        await repository.createMetric(m1);
        await repository.createMetric(m2);
        final avgValue = await repository.getAverageMetricValue();

        expect(avgValue, equals(150));
      });
    });

    group('InMemoryProductRepository - Competitive Analysis', () {
      test('createCompetitiveAnalysis stores analysis', () async {
        final analysis = CompetitiveAnalysis(
          id: 'comp1',
          productId: 'prod1',
          competitorName: 'Competitor A',
          ourMarketShare: 25,
          competitorMarketShare: 35,
          strengthsThreats: ['Feature parity', 'Price advantage'],
          opportunities: ['Market expansion'],
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await repository.createCompetitiveAnalysis(analysis);
        final retrieved = await repository.getCompetitiveAnalysis('comp1');

        expect(retrieved, isNotNull);
        expect(retrieved!.competitorName, equals('Competitor A'));
      });

      test('getAnalysesNeedingUpdate returns stale analysis', () async {
        final analysis = CompetitiveAnalysis(
          id: 'comp1',
          productId: 'prod1',
          competitorName: 'Competitor A',
          ourMarketShare: 25,
          competitorMarketShare: 35,
          strengthsThreats: [],
          opportunities: [],
          lastUpdated: DateTime.now().subtract(Duration(days: 100)),
          createdAt: DateTime.now().subtract(Duration(days: 100)),
        );

        await repository.createCompetitiveAnalysis(analysis);
        final stale = await repository.getAnalysesNeedingUpdate();

        expect(stale.length, equals(1));
        expect(stale[0].needsUpdate, isTrue);
      });

      test('getAverageMarketShare calculates correctly', () async {
        final a1 = CompetitiveAnalysis(
          id: 'comp1',
          productId: 'prod1',
          competitorName: 'C1',
          ourMarketShare: 20,
          competitorMarketShare: 30,
          strengthsThreats: [],
          opportunities: [],
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );
        final a2 = CompetitiveAnalysis(
          id: 'comp2',
          productId: 'prod1',
          competitorName: 'C2',
          ourMarketShare: 30,
          competitorMarketShare: 25,
          strengthsThreats: [],
          opportunities: [],
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await repository.createCompetitiveAnalysis(a1);
        await repository.createCompetitiveAnalysis(a2);
        final avgShare = await repository.getAverageMarketShare();

        expect(avgShare, equals(25));
      });
    });

    group('InMemoryProductRepository - Development Milestones', () {
      test('createMilestone stores milestone', () async {
        final milestone = DevelopmentMilestone(
          id: 'mile1',
          productId: 'prod1',
          name: 'Beta Release',
          targetDate: DateTime.now().add(Duration(days: 30)),
          status: 'In Progress',
          deliverables: ['Milestone features'],
          createdAt: DateTime.now(),
        );

        await repository.createMilestone(milestone);
        final retrieved = await repository.getMilestone('mile1');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Beta Release'));
      });

      test('getMilestonesByProduct filters correctly', () async {
        final milestone = DevelopmentMilestone(
          id: 'mile1',
          productId: 'prod1',
          name: 'Beta',
          targetDate: DateTime.now(),
          status: 'In Progress',
          deliverables: [],
          createdAt: DateTime.now(),
        );

        await repository.createMilestone(milestone);
        final productMilestones =
            await repository.getMilestonesByProduct('prod1');

        expect(productMilestones.length, equals(1));
      });

      test('getOverdueMilestones returns overdue items', () async {
        final milestone = DevelopmentMilestone(
          id: 'mile1',
          productId: 'prod1',
          name: 'Overdue Milestone',
          targetDate: DateTime.now().subtract(Duration(days: 10)),
          status: 'In Progress',
          deliverables: [],
          createdAt: DateTime.now().subtract(Duration(days: 20)),
        );

        await repository.createMilestone(milestone);
        final overdue = await repository.getOverdueMilestones();

        expect(overdue.length, equals(1));
        expect(overdue[0].isOverdue, isTrue);
      });

      test('getCompletedMilestoneCount counts completed', () async {
        final m1 = DevelopmentMilestone(
          id: 'mile1',
          productId: 'prod1',
          name: 'Completed',
          targetDate: DateTime.now(),
          status: 'Completed',
          deliverables: [],
          createdAt: DateTime.now(),
        );
        final m2 = DevelopmentMilestone(
          id: 'mile2',
          productId: 'prod1',
          name: 'In Progress',
          targetDate: DateTime.now(),
          status: 'In Progress',
          deliverables: [],
          createdAt: DateTime.now(),
        );

        await repository.createMilestone(m1);
        await repository.createMilestone(m2);
        final completed = await repository.getCompletedMilestoneCount();

        expect(completed, equals(1));
      });
    });

    group('InMemoryProductRepository - Budget', () {
      test('createBudget stores budget', () async {
        final budget = ProductBudget(
          id: 'budget1',
          productId: 'prod1',
          allocatedBudget: 100000,
          spentAmount: 25000,
          currency: 'USD',
          fiscalYear: 2025,
          createdAt: DateTime.now(),
        );

        await repository.createBudget(budget);
        final retrieved = await repository.getBudget('budget1');

        expect(retrieved, isNotNull);
        expect(retrieved!.allocatedBudget, equals(100000));
      });

      test('getBudgetsByProduct filters correctly', () async {
        final budget = ProductBudget(
          id: 'budget1',
          productId: 'prod1',
          allocatedBudget: 100000,
          spentAmount: 25000,
          currency: 'USD',
          fiscalYear: 2025,
          createdAt: DateTime.now(),
        );

        await repository.createBudget(budget);
        final productBudgets =
            await repository.getBudgetsByProduct('prod1');

        expect(productBudgets.length, equals(1));
      });

      test('getTotalBudgetAllocated sums all budgets', () async {
        final b1 = ProductBudget(
          id: 'budget1',
          productId: 'prod1',
          allocatedBudget: 100000,
          spentAmount: 25000,
          currency: 'USD',
          fiscalYear: 2025,
          createdAt: DateTime.now(),
        );
        final b2 = ProductBudget(
          id: 'budget2',
          productId: 'prod2',
          allocatedBudget: 200000,
          spentAmount: 50000,
          currency: 'USD',
          fiscalYear: 2025,
          createdAt: DateTime.now(),
        );

        await repository.createBudget(b1);
        await repository.createBudget(b2);
        final total = await repository.getTotalBudgetAllocated();

        expect(total, equals(300000));
      });
    });

    group('InMemoryProductRepository - Market Research', () {
      test('createMarketResearch stores research', () async {
        final research = MarketResearch(
          id: 'market1',
          productId: 'prod1',
          researchType: 'User Survey',
          findings: 'Users prefer feature X',
          targetMarketSize: 1000000,
          totalAddressableMarket: 5000000,
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await repository.createMarketResearch(research);
        final retrieved = await repository.getMarketResearch('market1');

        expect(retrieved, isNotNull);
        expect(retrieved!.researchType, equals('User Survey'));
      });

      test('getMarketResearchByProduct filters correctly', () async {
        final research = MarketResearch(
          id: 'market1',
          productId: 'prod1',
          researchType: 'Survey',
          findings: 'Good feedback',
          targetMarketSize: 1000000,
          totalAddressableMarket: 5000000,
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await repository.createMarketResearch(research);
        final productResearch =
            await repository.getMarketResearchByProduct('prod1');

        expect(productResearch.length, equals(1));
      });
    });

    group('ProductDevelopmentEngine', () {
      late ProductDevelopmentEngine engine;

      setUp(() {
        engine = ProductDevelopmentEngine(repository);
      });

      test('getProductsReadyForLaunch filters correctly', () async {
        final product = Product(
          id: 'prod1',
          name: 'Ready',
          description: '',
          stage: ProductStage.readyForLaunch,
          launchDate: DateTime.now(),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now(),
        );

        await repository.createProduct(product);
        final ready = await engine.getProductsReadyForLaunch();

        expect(ready.length, equals(1));
      });

      test('calculateProductHealthScore returns valid score', () async {
        final product = Product(
          id: 'prod1',
          name: 'Test',
          description: '',
          stage: ProductStage.development,
          launchDate: DateTime.now(),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now(),
        );

        await repository.createProduct(product);
        final score = await engine.calculateProductHealthScore('prod1');

        expect(score, greaterThanOrEqualTo(0));
        expect(score, lessThanOrEqualTo(100));
      });

      test('promoteProductStage updates product stage', () async {
        final product = Product(
          id: 'prod1',
          name: 'Test',
          description: '',
          stage: ProductStage.ideation,
          launchDate: DateTime.now(),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now(),
        );

        await repository.createProduct(product);
        await engine.promoteProductStage('prod1', ProductStage.development);
        final updated = await repository.getProduct('prod1');

        expect(updated!.stage, equals(ProductStage.development));
      });
    });

    group('FeaturePrioritizationEngine', () {
      late FeaturePrioritizationEngine engine;

      setUp(() {
        engine = FeaturePrioritizationEngine(repository);
      });

      test('getPrioritizedFeatures sorts by priority', () async {
        final feat1 = Feature(
          id: 'feat1',
          productId: 'prod1',
          name: 'Feature1',
          description: '',
          priority: FeaturePriority.low,
          status: FeatureStatus.inDevelopment,
          targetReleaseDate: DateTime.now(),
          createdAt: DateTime.now(),
        );
        final feat2 = Feature(
          id: 'feat2',
          productId: 'prod1',
          name: 'Feature2',
          description: '',
          priority: FeaturePriority.critical,
          status: FeatureStatus.inDevelopment,
          targetReleaseDate: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await repository.createFeature(feat1);
        await repository.createFeature(feat2);
        final prioritized =
            await engine.getPrioritizedFeatures('prod1');

        expect(prioritized[0].id, equals('feat2'));
      });
    });

    group('InnovationAssessmentEngine', () {
      late InnovationAssessmentEngine engine;

      setUp(() {
        engine = InnovationAssessmentEngine(repository);
      });

      test('getViableInnovations returns high ROI low risk', () async {
        final innov = Innovation(
          id: 'innov1',
          name: 'Viable',
          description: '',
          type: InnovationType.incremental,
          expectedROI: 200,
          riskLevel: 'low',
          isApproved: false,
          createdAt: DateTime.now(),
        );

        await repository.createInnovation(innov);
        final viable = await engine.getViableInnovations();

        expect(viable.length, equals(1));
      });

      test('calculateInnovationRiskScore returns valid score', () async {
        final innov = Innovation(
          id: 'innov1',
          name: 'Test',
          description: '',
          type: InnovationType.incremental,
          expectedROI: 100,
          riskLevel: 'high',
          isApproved: false,
          createdAt: DateTime.now(),
        );

        await repository.createInnovation(innov);
        final score = await engine.calculateInnovationRiskScore('innov1');

        expect(score, isNotNull);
      });
    });

    group('MarketAnalysisEngine', () {
      late MarketAnalysisEngine engine;

      setUp(() {
        engine = MarketAnalysisEngine(repository);
      });

      test('getMarketGaps returns low market share items', () async {
        final analysis = CompetitiveAnalysis(
          id: 'comp1',
          productId: 'prod1',
          competitorName: 'Competitor',
          ourMarketShare: 10,
          competitorMarketShare: 40,
          strengthsThreats: [],
          opportunities: [],
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await repository.createCompetitiveAnalysis(analysis);
        final gaps = await engine.getMarketGaps();

        expect(gaps.length, equals(1));
      });

      test('calculateMarketTrend returns valid percentage', () async {
        final feedback = UserFeedback(
          id: 'fb1',
          productId: 'prod1',
          userId: 'user1',
          comment: 'Good',
          sentimentScore: 0.8,
          createdAt: DateTime.now(),
        );

        await repository.createFeedback(feedback);
        final trend = await engine.calculateMarketTrend('prod1');

        expect(trend, greaterThanOrEqualTo(0));
        expect(trend, lessThanOrEqualTo(100));
      });
    });

    group('BudgetOptimizationEngine', () {
      late BudgetOptimizationEngine engine;

      setUp(() {
        engine = BudgetOptimizationEngine(repository);
      });

      test('getOverBudgetProducts returns overspent budgets', () async {
        final budget = ProductBudget(
          id: 'budget1',
          productId: 'prod1',
          allocatedBudget: 100000,
          spentAmount: 150000,
          currency: 'USD',
          fiscalYear: 2025,
          createdAt: DateTime.now(),
        );

        await repository.createBudget(budget);
        final overBudget = await engine.getOverBudgetProducts();

        expect(overBudget.length, equals(1));
        expect(overBudget[0].isOverBudget, isTrue);
      });

      test('calculateSpendingRate returns valid rate', () async {
        final budget = ProductBudget(
          id: 'budget1',
          productId: 'prod1',
          allocatedBudget: 100000,
          spentAmount: 25000,
          currency: 'USD',
          fiscalYear: 2025,
          createdAt: DateTime.now(),
        );

        await repository.createBudget(budget);
        final rate = await engine.calculateSpendingRate('prod1');

        expect(rate, greaterThanOrEqualTo(0));
      });
    });

    group('ProductFacade', () {
      late ProductFacade facade;

      setUp(() {
        facade = ProductFacade(repository);
      });

      test('createProduct and getProduct through facade', () async {
        final product = Product(
          id: 'prod1',
          name: 'Test',
          description: '',
          stage: ProductStage.ideation,
          launchDate: DateTime.now(),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now(),
        );

        await facade.createProduct(product);
        final retrieved = await facade.getProduct('prod1');

        expect(retrieved!.name, equals('Test'));
      });

      test('launchProduct updates stage', () async {
        final product = Product(
          id: 'prod1',
          name: 'Test',
          description: '',
          stage: ProductStage.readyForLaunch,
          launchDate: DateTime.now(),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now(),
        );

        await facade.createProduct(product);
        await facade.launchProduct('prod1');
        final updated = await facade.getProduct('prod1');

        expect(updated!.stage, equals(ProductStage.launch));
      });

      test('getProductHealthScore returns valid value', () async {
        final product = Product(
          id: 'prod1',
          name: 'Test',
          description: '',
          stage: ProductStage.development,
          launchDate: DateTime.now(),
          ownerTeam: 'Team',
          budget: 100000,
          marketSize: 1000000,
          targetAudience: 'Users',
          createdAt: DateTime.now(),
        );

        await facade.createProduct(product);
        final score = await facade.getProductHealthScore('prod1');

        expect(score, greaterThanOrEqualTo(0));
        expect(score, lessThanOrEqualTo(100));
      });

      test('getSystemStats returns product count', () async {
        final count = await facade.getSystemStats('products');
        expect(count, equals(0));
      });
    });

    group('Integration Tests', () {
      late ProductFacade facade;

      setUp(() {
        facade = ProductFacade(repository);
      });

      test('complete product workflow', () async {
        // Create product
        final product = Product(
          id: 'prod1',
          name: 'Integration Test Product',
          description: 'Testing complete workflow',
          stage: ProductStage.ideation,
          launchDate: DateTime(2026, 3, 1),
          ownerTeam: 'Integration Team',
          budget: 500000,
          marketSize: 5000000,
          targetAudience: 'Enterprise Users',
          createdAt: DateTime.now(),
        );
        await facade.createProduct(product);

        // Create features
        for (int i = 0; i < 5; i++) {
          final feature = Feature(
            id: 'feat$i',
            productId: 'prod1',
            name: 'Feature $i',
            description: 'Feature for integration test',
            priority: i < 2 ? FeaturePriority.high : FeaturePriority.medium,
            status: FeatureStatus.inDevelopment,
            targetReleaseDate: DateTime.now().add(Duration(days: 30 + i * 10)),
            createdAt: DateTime.now(),
          );
          await repository.createFeature(feature);
        }

        // Create innovations
        final innovation = Innovation(
          id: 'innov1',
          name: 'Integration Innovation',
          description: 'Testing innovation',
          type: InnovationType.disruptive,
          expectedROI: 300,
          riskLevel: 'medium',
          isApproved: false,
          createdAt: DateTime.now(),
        );
        await repository.createInnovation(innovation);

        // Verify all components work together
        final allProducts = await facade.getAllProducts();
        expect(allProducts.length, equals(1));

        final features = await facade.getPrioritizedFeatures('prod1');
        expect(features.length, equals(5));

        final innovations = await facade.getViableInnovations();
        expect(innovations.isNotEmpty, isTrue);

        final health = await facade.getProductHealthScore('prod1');
        expect(health, greaterThan(0));
      });
    });
  });
}
