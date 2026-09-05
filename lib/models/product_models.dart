import 'package:flutter/foundation.dart';

// ============================================================================
// ENUMS
// ============================================================================

enum ProductStage {
  ideation('構想段階'),
  concept('コンセプト'),
  development('開発中'),
  beta('ベータ'),
  launch('ローンチ'),
  growth('成長期'),
  maturity('成熟期'),
  decline('衰退期');

  final String displayName;
  const ProductStage(this.displayName);
}

enum FeaturePriority {
  critical('必須'),
  high('高'),
  medium('中'),
  low('低'),
  backlog('バックログ');

  final String displayName;
  const FeaturePriority(this.displayName);
}

enum FeatureStatus {
  proposed('提案'),
  approved('承認'),
  inDevelopment('開発中'),
  testing('テスト中'),
  released('リリース済み'),
  deprecated('廃止予定');

  final String displayName;
  const FeatureStatus(this.displayName);
}

enum InnovationType {
  incremental('段階的'),
  disruptive('破壊的'),
  radical('根本的'),
  process('プロセス'),
  business('ビジネス');

  final String displayName;
  const InnovationType(this.displayName);
}

enum RoadmapQuarter {
  q1('Q1'),
  q2('Q2'),
  q3('Q3'),
  q4('Q4');

  final String displayName;
  const RoadmapQuarter(this.displayName);
}

enum MetricCategory {
  adoption('採用'),
  engagement('エンゲージメント'),
  revenue('売上'),
  retention('維持'),
  satisfaction('満足度');

  final String displayName;
  const MetricCategory(this.displayName);
}

// ============================================================================
// MODELS
// ============================================================================

class Product {
  final String id;
  final String name;
  final String description;
  final ProductStage stage;
  final DateTime createdAt;
  final DateTime? launchDate;
  final String owner;
  final List<String> team;
  final double budget;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.stage,
    required this.createdAt,
    this.launchDate,
    required this.owner,
    required this.team,
    required this.budget,
  });

  bool get isLaunched => launchDate != null && DateTime.now().isAfter(launchDate!);
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  int get daysToLaunch => launchDate != null ? launchDate!.difference(DateTime.now()).inDays : -1;

  Product copyWith({
    String? id,
    String? name,
    String? description,
    ProductStage? stage,
    DateTime? createdAt,
    DateTime? launchDate,
    String? owner,
    List<String>? team,
    double? budget,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      stage: stage ?? this.stage,
      createdAt: createdAt ?? this.createdAt,
      launchDate: launchDate ?? this.launchDate,
      owner: owner ?? this.owner,
      team: team ?? this.team,
      budget: budget ?? this.budget,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Feature {
  final String id;
  final String productId;
  final String title;
  final String description;
  final FeaturePriority priority;
  final FeatureStatus status;
  final DateTime createdAt;
  final DateTime? targetReleaseDate;
  final String owner;
  final double estimatedHours;

  Feature({
    required this.id,
    required this.productId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.targetReleaseDate,
    required this.owner,
    required this.estimatedHours,
  });

  bool get isReleased => status == FeatureStatus.released;
  bool get isOverdue => targetReleaseDate != null && 
      DateTime.now().isAfter(targetReleaseDate!) &&
      status != FeatureStatus.released;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;

  Feature copyWith({
    String? id,
    String? productId,
    String? title,
    String? description,
    FeaturePriority? priority,
    FeatureStatus? status,
    DateTime? createdAt,
    DateTime? targetReleaseDate,
    String? owner,
    double? estimatedHours,
  }) {
    return Feature(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      targetReleaseDate: targetReleaseDate ?? this.targetReleaseDate,
      owner: owner ?? this.owner,
      estimatedHours: estimatedHours ?? this.estimatedHours,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Feature &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Innovation {
  final String id;
  final String title;
  final String description;
  final InnovationType type;
  final DateTime proposedAt;
  final String proposedBy;
  final double expectedROI;
  final int estimatedMonthsToImplement;
  final bool isApproved;
  final List<String> risks;

  Innovation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.proposedAt,
    required this.proposedBy,
    required this.expectedROI,
    required this.estimatedMonthsToImplement,
    required this.isApproved,
    required this.risks,
  });

  bool get hasHighROI => expectedROI > 50.0;
  bool get isHighRisk => risks.length > 3;
  int get ageInDays => DateTime.now().difference(proposedAt).inDays;

  Innovation copyWith({
    String? id,
    String? title,
    String? description,
    InnovationType? type,
    DateTime? proposedAt,
    String? proposedBy,
    double? expectedROI,
    int? estimatedMonthsToImplement,
    bool? isApproved,
    List<String>? risks,
  }) {
    return Innovation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      proposedAt: proposedAt ?? this.proposedAt,
      proposedBy: proposedBy ?? this.proposedBy,
      expectedROI: expectedROI ?? this.expectedROI,
      estimatedMonthsToImplement: estimatedMonthsToImplement ?? this.estimatedMonthsToImplement,
      isApproved: isApproved ?? this.isApproved,
      risks: risks ?? this.risks,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Innovation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ProductRoadmap {
  final String id;
  final String productId;
  final RoadmapQuarter quarter;
  final int year;
  final List<String> plannedFeatures;
  final String description;
  final DateTime createdAt;
  final double completionPercent;

  ProductRoadmap({
    required this.id,
    required this.productId,
    required this.quarter,
    required this.year,
    required this.plannedFeatures,
    required this.description,
    required this.createdAt,
    required this.completionPercent,
  });

  bool get isComplete => completionPercent >= 100.0;
  bool get isOnTrack => completionPercent >= 75.0;

  ProductRoadmap copyWith({
    String? id,
    String? productId,
    RoadmapQuarter? quarter,
    int? year,
    List<String>? plannedFeatures,
    String? description,
    DateTime? createdAt,
    double? completionPercent,
  }) {
    return ProductRoadmap(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quarter: quarter ?? this.quarter,
      year: year ?? this.year,
      plannedFeatures: plannedFeatures ?? this.plannedFeatures,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      completionPercent: completionPercent ?? this.completionPercent,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductRoadmap &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class UserFeedback {
  final String id;
  final String productId;
  final String userId;
  final String title;
  final String content;
  final DateTime submittedAt;
  final double rating;
  final List<String> tags;
  final bool isAddressed;

  UserFeedback({
    required this.id,
    required this.productId,
    required this.userId,
    required this.title,
    required this.content,
    required this.submittedAt,
    required this.rating,
    required this.tags,
    required this.isAddressed,
  });

  bool get isPositive => rating >= 4.0;
  bool get isNegative => rating <= 2.0;
  int get ageInDays => DateTime.now().difference(submittedAt).inDays;

  UserFeedback copyWith({
    String? id,
    String? productId,
    String? userId,
    String? title,
    String? content,
    DateTime? submittedAt,
    double? rating,
    List<String>? tags,
    bool? isAddressed,
  }) {
    return UserFeedback(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      submittedAt: submittedAt ?? this.submittedAt,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      isAddressed: isAddressed ?? this.isAddressed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserFeedback &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ProductMetric {
  final String id;
  final String productId;
  final MetricCategory category;
  final String metricName;
  final double value;
  final DateTime recordedAt;
  final double? targetValue;
  final String unit;

  ProductMetric({
    required this.id,
    required this.productId,
    required this.category,
    required this.metricName,
    required this.value,
    required this.recordedAt,
    this.targetValue,
    required this.unit,
  });

  bool get meetsTarget => targetValue != null && value >= targetValue!;
  bool get isRecent => DateTime.now().difference(recordedAt).inDays <= 7;

  ProductMetric copyWith({
    String? id,
    String? productId,
    MetricCategory? category,
    String? metricName,
    double? value,
    DateTime? recordedAt,
    double? targetValue,
    String? unit,
  }) {
    return ProductMetric(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      category: category ?? this.category,
      metricName: metricName ?? this.metricName,
      value: value ?? this.value,
      recordedAt: recordedAt ?? this.recordedAt,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductMetric &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CompetitiveAnalysis {
  final String id;
  final String productId;
  final String competitorName;
  final String competitorProduct;
  final DateTime analyzedAt;
  final List<String> strengths;
  final List<String> weaknesses;
  final String positioningStrategy;
  final double marketShare;

  CompetitiveAnalysis({
    required this.id,
    required this.productId,
    required this.competitorName,
    required this.competitorProduct,
    required this.analyzedAt,
    required this.strengths,
    required this.weaknesses,
    required this.positioningStrategy,
    required this.marketShare,
  });

  int get daysSinceAnalysis => DateTime.now().difference(analyzedAt).inDays;
  bool get needsUpdate => daysSinceAnalysis > 30;

  CompetitiveAnalysis copyWith({
    String? id,
    String? productId,
    String? competitorName,
    String? competitorProduct,
    DateTime? analyzedAt,
    List<String>? strengths,
    List<String>? weaknesses,
    String? positioningStrategy,
    double? marketShare,
  }) {
    return CompetitiveAnalysis(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      competitorName: competitorName ?? this.competitorName,
      competitorProduct: competitorProduct ?? this.competitorProduct,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      positioningStrategy: positioningStrategy ?? this.positioningStrategy,
      marketShare: marketShare ?? this.marketShare,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompetitiveAnalysis &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DevelopmentMilestone {
  final String id;
  final String productId;
  final String title;
  final String description;
  final DateTime targetDate;
  final DateTime? completedDate;
  final double completionPercent;
  final List<String> deliverables;
  final String owner;

  DevelopmentMilestone({
    required this.id,
    required this.productId,
    required this.title,
    required this.description,
    required this.targetDate,
    this.completedDate,
    required this.completionPercent,
    required this.deliverables,
    required this.owner,
  });

  bool get isCompleted => completedDate != null;
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(targetDate);
  int get daysUntilTarget => targetDate.difference(DateTime.now()).inDays;

  DevelopmentMilestone copyWith({
    String? id,
    String? productId,
    String? title,
    String? description,
    DateTime? targetDate,
    DateTime? completedDate,
    double? completionPercent,
    List<String>? deliverables,
    String? owner,
  }) {
    return DevelopmentMilestone(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      completedDate: completedDate ?? this.completedDate,
      completionPercent: completionPercent ?? this.completionPercent,
      deliverables: deliverables ?? this.deliverables,
      owner: owner ?? this.owner,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DevelopmentMilestone &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ProductBudget {
  final String id;
  final String productId;
  final double totalBudget;
  final double spent;
  final DateTime fiscalYear;
  final List<String> categories;
  final Map<String, double> categorySpend;

  ProductBudget({
    required this.id,
    required this.productId,
    required this.totalBudget,
    required this.spent,
    required this.fiscalYear,
    required this.categories,
    required this.categorySpend,
  });

  double get remaining => totalBudget - spent;
  double get spendPercent => (spent / totalBudget) * 100;
  bool get isOverBudget => spent > totalBudget;

  ProductBudget copyWith({
    String? id,
    String? productId,
    double? totalBudget,
    double? spent,
    DateTime? fiscalYear,
    List<String>? categories,
    Map<String, double>? categorySpend,
  }) {
    return ProductBudget(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      totalBudget: totalBudget ?? this.totalBudget,
      spent: spent ?? this.spent,
      fiscalYear: fiscalYear ?? this.fiscalYear,
      categories: categories ?? this.categories,
      categorySpend: categorySpend ?? this.categorySpend,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductBudget &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class MarketResearch {
  final String id;
  final String productId;
  final String researchTopic;
  final DateTime conductedAt;
  final int respondentCount;
  final List<String> keyFindings;
  final String recommendedActions;
  final double budget;

  MarketResearch({
    required this.id,
    required this.productId,
    required this.researchTopic,
    required this.conductedAt,
    required this.respondentCount,
    required this.keyFindings,
    required this.recommendedActions,
    required this.budget,
  });

  int get daysOld => DateTime.now().difference(conductedAt).inDays;
  bool get isRecent => daysOld <= 90;

  MarketResearch copyWith({
    String? id,
    String? productId,
    String? researchTopic,
    DateTime? conductedAt,
    int? respondentCount,
    List<String>? keyFindings,
    String? recommendedActions,
    double? budget,
  }) {
    return MarketResearch(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      researchTopic: researchTopic ?? this.researchTopic,
      conductedAt: conductedAt ?? this.conductedAt,
      respondentCount: respondentCount ?? this.respondentCount,
      keyFindings: keyFindings ?? this.keyFindings,
      recommendedActions: recommendedActions ?? this.recommendedActions,
      budget: budget ?? this.budget,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketResearch &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
