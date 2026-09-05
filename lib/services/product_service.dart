import 'dart:async';
import '../models/product_models.dart';

abstract class ProductRepository {
  // Products (12 methods)
  Future<void> createProduct(Product product);
  Future<Product?> getProduct(String id);
  Future<List<Product>> getAllProducts();
  Future<List<Product>> getProductsByStage(ProductStage stage);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<int> getProductCount();
  Future<double> getAverageProductAge();
  Future<List<Product>> getProductsByTeam(String team);
  Future<List<Product>> getRecentProducts(int days);
  Future<void> clearAllProducts();
  Future<Map<String, int>> getProductCountByStage();

  // Features (12 methods)
  Future<void> createFeature(Feature feature);
  Future<Feature?> getFeature(String id);
  Future<List<Feature>> getAllFeatures();
  Future<List<Feature>> getFeaturesByProduct(String productId);
  Future<List<Feature>> getFeaturesByStatus(FeatureStatus status);
  Future<void> updateFeature(Feature feature);
  Future<void> deleteFeature(String id);
  Future<int> getFeatureCount();
  Future<List<Feature>> getOverdueFeatures();
  Future<double> getAverageFeatureAge();
  Future<void> clearAllFeatures();
  Future<Map<String, int>> getFeatureCountByStatus();

  // Innovations (12 methods)
  Future<void> createInnovation(Innovation innovation);
  Future<Innovation?> getInnovation(String id);
  Future<List<Innovation>> getAllInnovations();
  Future<List<Innovation>> getInnovationsByType(InnovationType type);
  Future<List<Innovation>> getHighROIInnovations();
  Future<void> updateInnovation(Innovation innovation);
  Future<void> deleteInnovation(String id);
  Future<int> getInnovationCount();
  Future<double> getAverageExpectedROI();
  Future<List<Innovation>> getHighRiskInnovations();
  Future<void> clearAllInnovations();
  Future<Map<String, int>> getInnovationCountByType();

  // Product Roadmaps (10 methods)
  Future<void> createRoadmap(ProductRoadmap roadmap);
  Future<ProductRoadmap?> getRoadmap(String id);
  Future<List<ProductRoadmap>> getAllRoadmaps();
  Future<List<ProductRoadmap>> getRoadmapsByProduct(String productId);
  Future<void> updateRoadmap(ProductRoadmap roadmap);
  Future<void> deleteRoadmap(String id);
  Future<List<ProductRoadmap>> getCompleteRoadmaps();
  Future<List<ProductRoadmap>> getOnTrackRoadmaps();
  Future<void> clearAllRoadmaps();
  Future<int> getRoadmapCount();

  // User Feedback (10 methods)
  Future<void> createFeedback(UserFeedback feedback);
  Future<UserFeedback?> getFeedback(String id);
  Future<List<UserFeedback>> getAllFeedback();
  Future<List<UserFeedback>> getFeedbackByProduct(String productId);
  Future<List<UserFeedback>> getPositiveFeedback();
  Future<void> updateFeedback(UserFeedback feedback);
  Future<void> deleteFeedback(String id);
  Future<double> getAverageSentimentScore();
  Future<void> clearAllFeedback();
  Future<int> getFeedbackCount();

  // Product Metrics (10 methods)
  Future<void> createMetric(ProductMetric metric);
  Future<ProductMetric?> getMetric(String id);
  Future<List<ProductMetric>> getAllMetrics();
  Future<List<ProductMetric>> getMetricsByProduct(String productId);
  Future<List<ProductMetric>> getMetricsNotMeetingTarget();
  Future<void> updateMetric(ProductMetric metric);
  Future<void> deleteMetric(String id);
  Future<double> getAverageMetricValue();
  Future<void> clearAllMetrics();
  Future<int> getMetricCount();

  // Competitive Analysis (10 methods)
  Future<void> createCompetitiveAnalysis(CompetitiveAnalysis analysis);
  Future<CompetitiveAnalysis?> getCompetitiveAnalysis(String id);
  Future<List<CompetitiveAnalysis>> getAllAnalyses();
  Future<List<CompetitiveAnalysis>> getAnalysesByProduct(String productId);
  Future<List<CompetitiveAnalysis>> getAnalysesNeedingUpdate();
  Future<void> updateCompetitiveAnalysis(CompetitiveAnalysis analysis);
  Future<void> deleteCompetitiveAnalysis(String id);
  Future<double> getAverageMarketShare();
  Future<void> clearAllAnalyses();
  Future<int> getCompetitiveAnalysisCount();

  // Development Milestones (10 methods)
  Future<void> createMilestone(DevelopmentMilestone milestone);
  Future<DevelopmentMilestone?> getMilestone(String id);
  Future<List<DevelopmentMilestone>> getAllMilestones();
  Future<List<DevelopmentMilestone>> getMilestonesByProduct(String productId);
  Future<List<DevelopmentMilestone>> getOverdueMilestones();
  Future<void> updateMilestone(DevelopmentMilestone milestone);
  Future<void> deleteMilestone(String id);
  Future<int> getCompletedMilestoneCount();
  Future<void> clearAllMilestones();
  Future<int> getMilestoneCount();

  // Product Budget (8 methods)
  Future<void> createBudget(ProductBudget budget);
  Future<ProductBudget?> getBudget(String id);
  Future<List<ProductBudget>> getAllBudgets();
  Future<List<ProductBudget>> getBudgetsByProduct(String productId);
  Future<void> updateBudget(ProductBudget budget);
  Future<void> deleteBudget(String id);
  Future<double> getTotalBudgetAllocated();
  Future<void> clearAllBudgets();

  // Market Research (8 methods)
  Future<void> createMarketResearch(MarketResearch research);
  Future<MarketResearch?> getMarketResearch(String id);
  Future<List<MarketResearch>> getAllMarketResearch();
  Future<List<MarketResearch>> getMarketResearchByProduct(String productId);
  Future<void> updateMarketResearch(MarketResearch research);
  Future<void> deleteMarketResearch(String id);
  Future<int> getMarketResearchCount();
  Future<void> clearAllMarketResearch();
}

class InMemoryProductRepository extends ProductRepository {
  final Map<String, Product> _products = {};
  final Map<String, Feature> _features = {};
  final Map<String, Innovation> _innovations = {};
  final Map<String, ProductRoadmap> _roadmaps = {};
  final Map<String, UserFeedback> _feedback = {};
  final Map<String, ProductMetric> _metrics = {};
  final Map<String, CompetitiveAnalysis> _competitiveAnalyses = {};
  final Map<String, DevelopmentMilestone> _milestones = {};
  final Map<String, ProductBudget> _budgets = {};
  final Map<String, MarketResearch> _marketResearch = {};

  @override
  Future<void> createProduct(Product product) async => _products[product.id] = product;
  @override
  Future<Product?> getProduct(String id) async => _products[id];
  @override
  Future<List<Product>> getAllProducts() async => _products.values.toList();
  @override
  Future<List<Product>> getProductsByStage(ProductStage stage) async =>
      _products.values.where((p) => p.stage == stage).toList();
  @override
  Future<void> updateProduct(Product product) async => _products[product.id] = product;
  @override
  Future<void> deleteProduct(String id) async => _products.remove(id);
  @override
  Future<int> getProductCount() async => _products.length;
  @override
  Future<double> getAverageProductAge() async {
    if (_products.isEmpty) return 0;
    final sum = _products.values.fold<int>(0, (s, p) => s + p.ageInDays);
    return sum / _products.length;
  }
  @override
  Future<List<Product>> getProductsByTeam(String team) async =>
      _products.values.where((p) => p.ownerTeam == team).toList();
  @override
  Future<List<Product>> getRecentProducts(int days) async =>
      _products.values.where((p) => p.ageInDays <= days).toList();
  @override
  Future<void> clearAllProducts() async => _products.clear();
  @override
  Future<Map<String, int>> getProductCountByStage() async {
    final result = <String, int>{};
    for (final stage in ProductStage.values) {
      result[stage.displayName] = _products.values.where((p) => p.stage == stage).length;
    }
    return result;
  }

  @override
  Future<void> createFeature(Feature feature) async => _features[feature.id] = feature;
  @override
  Future<Feature?> getFeature(String id) async => _features[id];
  @override
  Future<List<Feature>> getAllFeatures() async => _features.values.toList();
  @override
  Future<List<Feature>> getFeaturesByProduct(String productId) async =>
      _features.values.where((f) => f.productId == productId).toList();
  @override
  Future<List<Feature>> getFeaturesByStatus(FeatureStatus status) async =>
      _features.values.where((f) => f.status == status).toList();
  @override
  Future<void> updateFeature(Feature feature) async => _features[feature.id] = feature;
  @override
  Future<void> deleteFeature(String id) async => _features.remove(id);
  @override
  Future<int> getFeatureCount() async => _features.length;
  @override
  Future<List<Feature>> getOverdueFeatures() async =>
      _features.values.where((f) => f.isOverdue).toList();
  @override
  Future<double> getAverageFeatureAge() async {
    if (_features.isEmpty) return 0;
    final sum = _features.values.fold<int>(0, (s, f) => s + f.ageInDays);
    return sum / _features.length;
  }
  @override
  Future<void> clearAllFeatures() async => _features.clear();
  @override
  Future<Map<String, int>> getFeatureCountByStatus() async {
    final result = <String, int>{};
    for (final status in FeatureStatus.values) {
      result[status.displayName] = _features.values.where((f) => f.status == status).length;
    }
    return result;
  }

  @override
  Future<void> createInnovation(Innovation innovation) async =>
      _innovations[innovation.id] = innovation;
  @override
  Future<Innovation?> getInnovation(String id) async => _innovations[id];
  @override
  Future<List<Innovation>> getAllInnovations() async => _innovations.values.toList();
  @override
  Future<List<Innovation>> getInnovationsByType(InnovationType type) async =>
      _innovations.values.where((i) => i.type == type).toList();
  @override
  Future<List<Innovation>> getHighROIInnovations() async =>
      _innovations.values.where((i) => i.hasHighROI).toList();
  @override
  Future<void> updateInnovation(Innovation innovation) async =>
      _innovations[innovation.id] = innovation;
  @override
  Future<void> deleteInnovation(String id) async => _innovations.remove(id);
  @override
  Future<int> getInnovationCount() async => _innovations.length;
  @override
  Future<double> getAverageExpectedROI() async {
    if (_innovations.isEmpty) return 0;
    final sum = _innovations.values.fold<double>(0, (s, i) => s + i.expectedROI);
    return sum / _innovations.length;
  }
  @override
  Future<List<Innovation>> getHighRiskInnovations() async =>
      _innovations.values.where((i) => i.isHighRisk).toList();
  @override
  Future<void> clearAllInnovations() async => _innovations.clear();
  @override
  Future<Map<String, int>> getInnovationCountByType() async {
    final result = <String, int>{};
    for (final type in InnovationType.values) {
      result[type.displayName] = _innovations.values.where((i) => i.type == type).length;
    }
    return result;
  }

  @override
  Future<void> createRoadmap(ProductRoadmap roadmap) async =>
      _roadmaps[roadmap.id] = roadmap;
  @override
  Future<ProductRoadmap?> getRoadmap(String id) async => _roadmaps[id];
  @override
  Future<List<ProductRoadmap>> getAllRoadmaps() async => _roadmaps.values.toList();
  @override
  Future<List<ProductRoadmap>> getRoadmapsByProduct(String productId) async =>
      _roadmaps.values.where((r) => r.productId == productId).toList();
  @override
  Future<void> updateRoadmap(ProductRoadmap roadmap) async =>
      _roadmaps[roadmap.id] = roadmap;
  @override
  Future<void> deleteRoadmap(String id) async => _roadmaps.remove(id);
  @override
  Future<List<ProductRoadmap>> getCompleteRoadmaps() async =>
      _roadmaps.values.where((r) => r.isComplete).toList();
  @override
  Future<List<ProductRoadmap>> getOnTrackRoadmaps() async =>
      _roadmaps.values.where((r) => r.isOnTrack).toList();
  @override
  Future<void> clearAllRoadmaps() async => _roadmaps.clear();
  @override
  Future<int> getRoadmapCount() async => _roadmaps.length;

  @override
  Future<void> createFeedback(UserFeedback feedback) async =>
      _feedback[feedback.id] = feedback;
  @override
  Future<UserFeedback?> getFeedback(String id) async => _feedback[id];
  @override
  Future<List<UserFeedback>> getAllFeedback() async => _feedback.values.toList();
  @override
  Future<List<UserFeedback>> getFeedbackByProduct(String productId) async =>
      _feedback.values.where((f) => f.productId == productId).toList();
  @override
  Future<List<UserFeedback>> getPositiveFeedback() async =>
      _feedback.values.where((f) => f.isPositive).toList();
  @override
  Future<void> updateFeedback(UserFeedback feedback) async =>
      _feedback[feedback.id] = feedback;
  @override
  Future<void> deleteFeedback(String id) async => _feedback.remove(id);
  @override
  Future<double> getAverageSentimentScore() async {
    if (_feedback.isEmpty) return 0;
    final sum = _feedback.values.fold<double>(0, (s, f) => s + f.sentimentScore);
    return sum / _feedback.length;
  }
  @override
  Future<void> clearAllFeedback() async => _feedback.clear();
  @override
  Future<int> getFeedbackCount() async => _feedback.length;

  @override
  Future<void> createMetric(ProductMetric metric) async =>
      _metrics[metric.id] = metric;
  @override
  Future<ProductMetric?> getMetric(String id) async => _metrics[id];
  @override
  Future<List<ProductMetric>> getAllMetrics() async => _metrics.values.toList();
  @override
  Future<List<ProductMetric>> getMetricsByProduct(String productId) async =>
      _metrics.values.where((m) => m.productId == productId).toList();
  @override
  Future<List<ProductMetric>> getMetricsNotMeetingTarget() async =>
      _metrics.values.where((m) => !m.meetsTarget).toList();
  @override
  Future<void> updateMetric(ProductMetric metric) async =>
      _metrics[metric.id] = metric;
  @override
  Future<void> deleteMetric(String id) async => _metrics.remove(id);
  @override
  Future<double> getAverageMetricValue() async {
    if (_metrics.isEmpty) return 0;
    final sum = _metrics.values.fold<double>(0, (s, m) => s + m.value);
    return sum / _metrics.length;
  }
  @override
  Future<void> clearAllMetrics() async => _metrics.clear();
  @override
  Future<int> getMetricCount() async => _metrics.length;

  @override
  Future<void> createCompetitiveAnalysis(CompetitiveAnalysis analysis) async =>
      _competitiveAnalyses[analysis.id] = analysis;
  @override
  Future<CompetitiveAnalysis?> getCompetitiveAnalysis(String id) async =>
      _competitiveAnalyses[id];
  @override
  Future<List<CompetitiveAnalysis>> getAllAnalyses() async =>
      _competitiveAnalyses.values.toList();
  @override
  Future<List<CompetitiveAnalysis>> getAnalysesByProduct(String productId) async =>
      _competitiveAnalyses.values.where((a) => a.productId == productId).toList();
  @override
  Future<List<CompetitiveAnalysis>> getAnalysesNeedingUpdate() async =>
      _competitiveAnalyses.values.where((a) => a.needsUpdate).toList();
  @override
  Future<void> updateCompetitiveAnalysis(CompetitiveAnalysis analysis) async =>
      _competitiveAnalyses[analysis.id] = analysis;
  @override
  Future<void> deleteCompetitiveAnalysis(String id) async =>
      _competitiveAnalyses.remove(id);
  @override
  Future<double> getAverageMarketShare() async {
    if (_competitiveAnalyses.isEmpty) return 0;
    final sum = _competitiveAnalyses.values
        .fold<double>(0, (s, a) => s + a.ourMarketShare);
    return sum / _competitiveAnalyses.length;
  }
  @override
  Future<void> clearAllAnalyses() async => _competitiveAnalyses.clear();
  @override
  Future<int> getCompetitiveAnalysisCount() async => _competitiveAnalyses.length;

  @override
  Future<void> createMilestone(DevelopmentMilestone milestone) async =>
      _milestones[milestone.id] = milestone;
  @override
  Future<DevelopmentMilestone?> getMilestone(String id) async => _milestones[id];
  @override
  Future<List<DevelopmentMilestone>> getAllMilestones() async =>
      _milestones.values.toList();
  @override
  Future<List<DevelopmentMilestone>> getMilestonesByProduct(String productId) async =>
      _milestones.values.where((m) => m.productId == productId).toList();
  @override
  Future<List<DevelopmentMilestone>> getOverdueMilestones() async =>
      _milestones.values.where((m) => m.isOverdue).toList();
  @override
  Future<void> updateMilestone(DevelopmentMilestone milestone) async =>
      _milestones[milestone.id] = milestone;
  @override
  Future<void> deleteMilestone(String id) async => _milestones.remove(id);
  @override
  Future<int> getCompletedMilestoneCount() async =>
      _milestones.values.where((m) => m.isCompleted).length;
  @override
  Future<void> clearAllMilestones() async => _milestones.clear();
  @override
  Future<int> getMilestoneCount() async => _milestones.length;

  @override
  Future<void> createBudget(ProductBudget budget) async =>
      _budgets[budget.id] = budget;
  @override
  Future<ProductBudget?> getBudget(String id) async => _budgets[id];
  @override
  Future<List<ProductBudget>> getAllBudgets() async => _budgets.values.toList();
  @override
  Future<List<ProductBudget>> getBudgetsByProduct(String productId) async =>
      _budgets.values.where((b) => b.productId == productId).toList();
  @override
  Future<void> updateBudget(ProductBudget budget) async =>
      _budgets[budget.id] = budget;
  @override
  Future<void> deleteBudget(String id) async => _budgets.remove(id);
  @override
  Future<double> getTotalBudgetAllocated() async =>
      _budgets.values.fold(0, (sum, b) => sum + b.allocatedBudget);
  @override
  Future<void> clearAllBudgets() async => _budgets.clear();

  @override
  Future<void> createMarketResearch(MarketResearch research) async =>
      _marketResearch[research.id] = research;
  @override
  Future<MarketResearch?> getMarketResearch(String id) async =>
      _marketResearch[id];
  @override
  Future<List<MarketResearch>> getAllMarketResearch() async =>
      _marketResearch.values.toList();
  @override
  Future<List<MarketResearch>> getMarketResearchByProduct(String productId) async =>
      _marketResearch.values.where((r) => r.productId == productId).toList();
  @override
  Future<void> updateMarketResearch(MarketResearch research) async =>
      _marketResearch[research.id] = research;
  @override
  Future<void> deleteMarketResearch(String id) async =>
      _marketResearch.remove(id);
  @override
  Future<int> getMarketResearchCount() async => _marketResearch.length;
  @override
  Future<void> clearAllMarketResearch() async => _marketResearch.clear();
}

class ProductDevelopmentEngine {
  final ProductRepository repository;
  ProductDevelopmentEngine(this.repository);

  Future<List<Product>> getProductsReadyForLaunch() async {
    final products = await repository.getAllProducts();
    return products.where((p) => p.stage == ProductStage.readyForLaunch).toList();
  }

  Future<double> calculateProductHealthScore(String productId) async {
    final product = await repository.getProduct(productId);
    if (product == null) return 0;
    
    final features = await repository.getFeaturesByProduct(productId);
    final metrics = await repository.getMetricsByProduct(productId);
    
    double score = 80;
    if (features.any((f) => f.isOverdue)) score -= 10;
    if (metrics.any((m) => !m.meetsTarget)) score -= 10;
    
    return score.clamp(0, 100);
  }

  Future<void> promoteProductStage(String productId, ProductStage nextStage) async {
    final product = await repository.getProduct(productId);
    if (product != null) {
      await repository.updateProduct(product.copyWith(stage: nextStage));
    }
  }
}

class FeaturePrioritizationEngine {
  final ProductRepository repository;
  FeaturePrioritizationEngine(this.repository);

  Future<List<Feature>> getPrioritizedFeatures(String productId) async {
    final features = await repository.getFeaturesByProduct(productId);
    features.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return features;
  }

  Future<void> adjustFeaturePriorities(String productId, List<String> featureIds) async {
    final features = await repository.getFeaturesByProduct(productId);
    for (int i = 0; i < featureIds.length && i < features.length; i++) {
      final feature = features.firstWhere((f) => f.id == featureIds[i], orElse: () => features.first);
      final newPriority = i < 2 ? FeaturePriority.high : FeaturePriority.medium;
      await repository.updateFeature(feature.copyWith(priority: newPriority));
    }
  }

  Future<Map<FeaturePriority, int>> getFeatureDistributionByPriority(
      String productId) async {
    final features = await repository.getFeaturesByProduct(productId);
    final distribution = <FeaturePriority, int>{};
    for (final priority in FeaturePriority.values) {
      distribution[priority] = features.where((f) => f.priority == priority).length;
    }
    return distribution;
  }
}

class InnovationAssessmentEngine {
  final ProductRepository repository;
  InnovationAssessmentEngine(this.repository);

  Future<List<Innovation>> getViableInnovations() async {
    final innovations = await repository.getAllInnovations();
    return innovations.where((i) => i.hasHighROI && !i.isHighRisk).toList();
  }

  Future<double> calculateInnovationRiskScore(String innovationId) async {
    final innovation = await repository.getInnovation(innovationId);
    if (innovation == null) return 0;
    return innovation.isHighRisk ? 75 : 25;
  }

  Future<void> updateInnovationStatus(String innovationId, bool isApproved) async {
    final innovation = await repository.getInnovation(innovationId);
    if (innovation != null) {
      await repository.updateInnovation(
        innovation.copyWith(isApproved: isApproved),
      );
    }
  }
}

class MarketAnalysisEngine {
  final ProductRepository repository;
  MarketAnalysisEngine(this.repository);

  Future<List<CompetitiveAnalysis>> getMarketGaps() async {
    final analyses = await repository.getAllAnalyses();
    return analyses.where((a) => a.ourMarketShare < 20).toList();
  }

  Future<double> calculateMarketTrend(String productId) async {
    final feedback = await repository.getFeedbackByProduct(productId);
    if (feedback.isEmpty) return 0;
    final positiveCount = feedback.where((f) => f.isPositive).length;
    return (positiveCount / feedback.length) * 100;
  }

  Future<void> updateMarketShare(String analysisId, double newShare) async {
    final analysis = await repository.getCompetitiveAnalysis(analysisId);
    if (analysis != null) {
      await repository.updateCompetitiveAnalysis(
        analysis.copyWith(ourMarketShare: newShare),
      );
    }
  }
}

class BudgetOptimizationEngine {
  final ProductRepository repository;
  BudgetOptimizationEngine(this.repository);

  Future<List<ProductBudget>> getOverBudgetProducts() async {
    final budgets = await repository.getAllBudgets();
    return budgets.where((b) => b.isOverBudget).toList();
  }

  Future<double> calculateSpendingRate(String productId) async {
    final budget = await repository.getBudgetsByProduct(productId);
    if (budget.isEmpty) return 0;
    final avgSpend = budget.fold<double>(0, (sum, b) => sum + b.spendPercent) /
        budget.length;
    return avgSpend;
  }

  Future<void> rebalanceBudgets(String productId, double adjustment) async {
    final budgets = await repository.getBudgetsByProduct(productId);
    for (final budget in budgets) {
      final newAllocated = budget.allocatedBudget * (1 + adjustment / 100);
      await repository.updateBudget(
        budget.copyWith(allocatedBudget: newAllocated),
      );
    }
  }
}

class ProductManager {
  final ProductRepository repository;
  late final ProductDevelopmentEngine developmentEngine;
  late final FeaturePrioritizationEngine featurePrioritizationEngine;
  late final InnovationAssessmentEngine innovationAssessmentEngine;
  late final MarketAnalysisEngine marketAnalysisEngine;
  late final BudgetOptimizationEngine budgetOptimizationEngine;

  ProductManager(this.repository) {
    developmentEngine = ProductDevelopmentEngine(repository);
    featurePrioritizationEngine = FeaturePrioritizationEngine(repository);
    innovationAssessmentEngine = InnovationAssessmentEngine(repository);
    marketAnalysisEngine = MarketAnalysisEngine(repository);
    budgetOptimizationEngine = BudgetOptimizationEngine(repository);
  }

  Future<int> getTotalProductCount() async => await repository.getProductCount();

  Future<void> initializeNewProduct(Product product) async {
    await repository.createProduct(product);
  }

  Future<void> archiveProduct(String productId) async {
    final product = await repository.getProduct(productId);
    if (product != null) {
      await repository.updateProduct(product.copyWith(stage: ProductStage.decline));
    }
  }
}

class ProductFacade {
  final ProductManager manager;

  ProductFacade(ProductRepository repository) : manager = ProductManager(repository);

  Future<void> createProduct(Product product) =>
      manager.repository.createProduct(product);

  Future<Product?> getProduct(String id) =>
      manager.repository.getProduct(id);

  Future<List<Product>> getAllProducts() =>
      manager.repository.getAllProducts();

  Future<void> launchProduct(String productId) async {
    await manager.developmentEngine.promoteProductStage(
      productId,
      ProductStage.launch,
    );
  }

  Future<List<Product>> getProductsReadyForLaunch() =>
      manager.developmentEngine.getProductsReadyForLaunch();

  Future<double> getProductHealthScore(String productId) =>
      manager.developmentEngine.calculateProductHealthScore(productId);

  Future<List<Feature>> getPrioritizedFeatures(String productId) =>
      manager.featurePrioritizationEngine.getPrioritizedFeatures(productId);

  Future<List<Innovation>> getViableInnovations() =>
      manager.innovationAssessmentEngine.getViableInnovations();

  Future<List<CompetitiveAnalysis>> getMarketGaps() =>
      manager.marketAnalysisEngine.getMarketGaps();

  Future<List<ProductBudget>> getOverBudgetProducts() =>
      manager.budgetOptimizationEngine.getOverBudgetProducts();

  Future<int> getSystemStats(String statType) async {
    switch (statType) {
      case 'products':
        return await manager.repository.getProductCount();
      case 'features':
        return await manager.repository.getFeatureCount();
      case 'innovations':
        return await manager.repository.getInnovationCount();
      default:
        return 0;
    }
  }
}
