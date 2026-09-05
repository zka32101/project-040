import 'package:flutter/foundation.dart';

// Enums
enum UserSegment {
  premium,
  standard,
  basic,
  trial,
  inactive,
  vip,
  churned,
  engaged;

  String get displayName => {
    UserSegment.premium: 'Premium / プレミアム',
    UserSegment.standard: 'Standard / スタンダード',
    UserSegment.basic: 'Basic / ベーシック',
    UserSegment.trial: 'Trial / トライアル',
    UserSegment.inactive: 'Inactive / 非アクティブ',
    UserSegment.vip: 'VIP / VIP',
    UserSegment.churned: 'Churned / 離脱',
    UserSegment.engaged: 'Engaged / エンゲージド',
  }[this]!;
}

enum ExperienceType {
  personalized,
  adaptive,
  contextual,
  predictive,
  social,
  gamified,
  recommended;

  String get displayName => {
    ExperienceType.personalized: 'Personalized / パーソナライズ',
    ExperienceType.adaptive: 'Adaptive / 適応的',
    ExperienceType.contextual: 'Contextual / コンテキスト',
    ExperienceType.predictive: 'Predictive / 予測',
    ExperienceType.social: 'Social / ソーシャル',
    ExperienceType.gamified: 'Gamified / ゲーミフィ',
    ExperienceType.recommended: 'Recommended / 推奨',
  }[this]!;
}

enum JourneyStage {
  awareness,
  consideration,
  decision,
  purchase,
  onboarding,
  adoption,
  retention,
  advocacy,
  churn;

  String get displayName => {
    JourneyStage.awareness: 'Awareness / 認知',
    JourneyStage.consideration: 'Consideration / 検討',
    JourneyStage.decision: 'Decision / 決定',
    JourneyStage.purchase: 'Purchase / 購入',
    JourneyStage.onboarding: 'Onboarding / オンボード',
    JourneyStage.adoption: 'Adoption / 導入',
    JourneyStage.retention: 'Retention / 保持',
    JourneyStage.advocacy: 'Advocacy / 提唱',
    JourneyStage.churn: 'Churn / 離脱',
  }[this]!;
}

enum RecommendationType {
  contentBased,
  collaborativeFiltering,
  hybridBased,
  trendingBased,
  contextualBased,
  rulesBasedEngine,
  mlPowered;

  String get displayName => {
    RecommendationType.contentBased: 'Content-Based / コンテンツ',
    RecommendationType.collaborativeFiltering: 'Collaborative / 協調',
    RecommendationType.hybridBased: 'Hybrid / ハイブリッド',
    RecommendationType.trendingBased: 'Trending / トレンド',
    RecommendationType.contextualBased: 'Contextual / コンテキスト',
    RecommendationType.rulesBasedEngine: 'Rules-Based / ルール',
    RecommendationType.mlPowered: 'ML-Powered / ML',
  }[this]!;
}

enum ABTestStatus {
  planning,
  running,
  paused,
  completed,
  abandoned;

  String get displayName => {
    ABTestStatus.planning: 'Planning / 計画',
    ABTestStatus.running: 'Running / 実行中',
    ABTestStatus.paused: 'Paused / 一時停止',
    ABTestStatus.completed: 'Completed / 完了',
    ABTestStatus.abandoned: 'Abandoned / 中止',
  }[this]!;
}

enum SatisfactionLevel {
  veryDissatisfied,
  dissatisfied,
  neutral,
  satisfied,
  verySatisfied;

  String get displayName => {
    SatisfactionLevel.veryDissatisfied: 'Very Dissatisfied / 非常に不満',
    SatisfactionLevel.dissatisfied: 'Dissatisfied / 不満',
    SatisfactionLevel.neutral: 'Neutral / 中立',
    SatisfactionLevel.satisfied: 'Satisfied / 満足',
    SatisfactionLevel.verySatisfied: 'Very Satisfied / 非常に満足',
  }[this]!;
}

// Models
class UserProfile {
  final String userId;
  final String name;
  final String email;
  final UserSegment segment;
  final List<String> interests;
  final List<String> preferences;
  final int engagementScore;
  final int lifetimeValue;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final int totalInteractions;

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.segment,
    required this.interests,
    required this.preferences,
    required this.engagementScore,
    required this.lifetimeValue,
    required this.createdAt,
    required this.lastActiveAt,
    required this.totalInteractions,
  });

  bool get isActive => DateTime.now().difference(lastActiveAt).inDays < 30;
  bool get isHighValue => lifetimeValue > 10000;
  bool get isHighEngagement => engagementScore > 75;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;
  int get inactiveDays => DateTime.now().difference(lastActiveAt).inDays;

  UserProfile copyWith({
    String? userId,
    String? name,
    String? email,
    UserSegment? segment,
    List<String>? interests,
    List<String>? preferences,
    int? engagementScore,
    int? lifetimeValue,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    int? totalInteractions,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      segment: segment ?? this.segment,
      interests: interests ?? this.interests,
      preferences: preferences ?? this.preferences,
      engagementScore: engagementScore ?? this.engagementScore,
      lifetimeValue: lifetimeValue ?? this.lifetimeValue,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      totalInteractions: totalInteractions ?? this.totalInteractions,
    );
  }
}

class PersonalizationStrategy {
  final String strategyId;
  final String userId;
  final ExperienceType experienceType;
  final List<String> rules;
  final Map<String, dynamic> parameters;
  final bool isActive;
  final double conversionRate;
  final int applicationsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  PersonalizationStrategy({
    required this.strategyId,
    required this.userId,
    required this.experienceType,
    required this.rules,
    required this.parameters,
    required this.isActive,
    required this.conversionRate,
    required this.applicationsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isEffective => conversionRate > 0.15;
  bool get hasHighApplications => applicationsCount > 1000;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;

  PersonalizationStrategy copyWith({
    String? strategyId,
    String? userId,
    ExperienceType? experienceType,
    List<String>? rules,
    Map<String, dynamic>? parameters,
    bool? isActive,
    double? conversionRate,
    int? applicationsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PersonalizationStrategy(
      strategyId: strategyId ?? this.strategyId,
      userId: userId ?? this.userId,
      experienceType: experienceType ?? this.experienceType,
      rules: rules ?? this.rules,
      parameters: parameters ?? this.parameters,
      isActive: isActive ?? this.isActive,
      conversionRate: conversionRate ?? this.conversionRate,
      applicationsCount: applicationsCount ?? this.applicationsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserJourney {
  final String journeyId;
  final String userId;
  final JourneyStage currentStage;
  final List<JourneyStage> completedStages;
  final DateTime stageEnteredAt;
  final int stageProgressPercentage;
  final List<String> touchpoints;
  final DateTime createdAt;

  UserJourney({
    required this.journeyId,
    required this.userId,
    required this.currentStage,
    required this.completedStages,
    required this.stageEnteredAt,
    required this.stageProgressPercentage,
    required this.touchpoints,
    required this.createdAt,
  });

  bool get isOnTrack => stageProgressPercentage >= 50;
  bool get isAtRisk => stageProgressPercentage < 30;
  int get stageAgeInDays => DateTime.now().difference(stageEnteredAt).inDays;

  UserJourney copyWith({
    String? journeyId,
    String? userId,
    JourneyStage? currentStage,
    List<JourneyStage>? completedStages,
    DateTime? stageEnteredAt,
    int? stageProgressPercentage,
    List<String>? touchpoints,
    DateTime? createdAt,
  }) {
    return UserJourney(
      journeyId: journeyId ?? this.journeyId,
      userId: userId ?? this.userId,
      currentStage: currentStage ?? this.currentStage,
      completedStages: completedStages ?? this.completedStages,
      stageEnteredAt: stageEnteredAt ?? this.stageEnteredAt,
      stageProgressPercentage: stageProgressPercentage ?? this.stageProgressPercentage,
      touchpoints: touchpoints ?? this.touchpoints,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Recommendation {
  final String recommendationId;
  final String userId;
  final String contentId;
  final RecommendationType type;
  final double relevanceScore;
  final String rationale;
  final bool wasAccepted;
  final DateTime recommendedAt;
  final DateTime? acceptedAt;

  Recommendation({
    required this.recommendationId,
    required this.userId,
    required this.contentId,
    required this.type,
    required this.relevanceScore,
    required this.rationale,
    required this.wasAccepted,
    required this.recommendedAt,
    required this.acceptedAt,
  });

  bool get isHighRelevance => relevanceScore > 0.75;
  bool get isRecent => DateTime.now().difference(recommendedAt).inDays < 7;
  int get ageInDays => DateTime.now().difference(recommendedAt).inDays;

  Recommendation copyWith({
    String? recommendationId,
    String? userId,
    String? contentId,
    RecommendationType? type,
    double? relevanceScore,
    String? rationale,
    bool? wasAccepted,
    DateTime? recommendedAt,
    DateTime? acceptedAt,
  }) {
    return Recommendation(
      recommendationId: recommendationId ?? this.recommendationId,
      userId: userId ?? this.userId,
      contentId: contentId ?? this.contentId,
      type: type ?? this.type,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      rationale: rationale ?? this.rationale,
      wasAccepted: wasAccepted ?? this.wasAccepted,
      recommendedAt: recommendedAt ?? this.recommendedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }
}

class ABTest {
  final String testId;
  final String name;
  final String description;
  final ABTestStatus status;
  final List<String> variants;
  final String controlVariant;
  final int samplesPerVariant;
  final double confidenceLevel;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, double> conversionRates;

  ABTest({
    required this.testId,
    required this.name,
    required this.description,
    required this.status,
    required this.variants,
    required this.controlVariant,
    required this.samplesPerVariant,
    required this.confidenceLevel,
    required this.startedAt,
    required this.completedAt,
    required this.conversionRates,
  });

  bool get isRunning => status == ABTestStatus.running;
  bool get hasStatisticalSignificance => confidenceLevel >= 0.95;
  int get durationInDays => (completedAt ?? DateTime.now()).difference(startedAt).inDays;

  ABTest copyWith({
    String? testId,
    String? name,
    String? description,
    ABTestStatus? status,
    List<String>? variants,
    String? controlVariant,
    int? samplesPerVariant,
    double? confidenceLevel,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, double>? conversionRates,
  }) {
    return ABTest(
      testId: testId ?? this.testId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      variants: variants ?? this.variants,
      controlVariant: controlVariant ?? this.controlVariant,
      samplesPerVariant: samplesPerVariant ?? this.samplesPerVariant,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      conversionRates: conversionRates ?? this.conversionRates,
    );
  }
}

class UserSatisfaction {
  final String satisfactionId;
  final String userId;
  final SatisfactionLevel level;
  final int npsScore;
  final String feedback;
  final String category;
  final DateTime measuredAt;
  final bool actionTaken;

  UserSatisfaction({
    required this.satisfactionId,
    required this.userId,
    required this.level,
    required this.npsScore,
    required this.feedback,
    required this.category,
    required this.measuredAt,
    required this.actionTaken,
  });

  bool get isPositive => level == SatisfactionLevel.satisfied || level == SatisfactionLevel.verySatisfied;
  bool get isNegative => level == SatisfactionLevel.dissatisfied || level == SatisfactionLevel.veryDissatisfied;
  bool get isPromoter => npsScore >= 9;
  bool get isDetractor => npsScore <= 6;
  int get ageInDays => DateTime.now().difference(measuredAt).inDays;

  UserSatisfaction copyWith({
    String? satisfactionId,
    String? userId,
    SatisfactionLevel? level,
    int? npsScore,
    String? feedback,
    String? category,
    DateTime? measuredAt,
    bool? actionTaken,
  }) {
    return UserSatisfaction(
      satisfactionId: satisfactionId ?? this.satisfactionId,
      userId: userId ?? this.userId,
      level: level ?? this.level,
      npsScore: npsScore ?? this.npsScore,
      feedback: feedback ?? this.feedback,
      category: category ?? this.category,
      measuredAt: measuredAt ?? this.measuredAt,
      actionTaken: actionTaken ?? this.actionTaken,
    );
  }
}

class ExperienceAnalytics {
  final String analyticsId;
  final String userId;
  final int viewsCount;
  final int clicksCount;
  final double averageTimeSpent;
  final double conversionRate;
  final List<String> topPages;
  final DateTime period;

  ExperienceAnalytics({
    required this.analyticsId,
    required this.userId,
    required this.viewsCount,
    required this.clicksCount,
    required this.averageTimeSpent,
    required this.conversionRate,
    required this.topPages,
    required this.period,
  });

  double get clickThroughRate => viewsCount > 0 ? (clicksCount / viewsCount) * 100 : 0;
  bool get hasGoodEngagement => clickThroughRate > 5;

  ExperienceAnalytics copyWith({
    String? analyticsId,
    String? userId,
    int? viewsCount,
    int? clicksCount,
    double? averageTimeSpent,
    double? conversionRate,
    List<String>? topPages,
    DateTime? period,
  }) {
    return ExperienceAnalytics(
      analyticsId: analyticsId ?? this.analyticsId,
      userId: userId ?? this.userId,
      viewsCount: viewsCount ?? this.viewsCount,
      clicksCount: clicksCount ?? this.clicksCount,
      averageTimeSpent: averageTimeSpent ?? this.averageTimeSpent,
      conversionRate: conversionRate ?? this.conversionRate,
      topPages: topPages ?? this.topPages,
      period: period ?? this.period,
    );
  }
}

class ContentRelevance {
  final String contentId;
  final String title;
  final List<String> tags;
  final double relevanceScore;
  final int viewCount;
  final int shareCount;
  final DateTime createdAt;
  final bool isTrending;

  ContentRelevance({
    required this.contentId,
    required this.title,
    required this.tags,
    required this.relevanceScore,
    required this.viewCount,
    required this.shareCount,
    required this.createdAt,
    required this.isTrending,
  });

  int get engagementScore => viewCount + (shareCount * 2);
  bool get isPopular => viewCount > 1000;
  int get ageInDays => DateTime.now().difference(createdAt).inDays;

  ContentRelevance copyWith({
    String? contentId,
    String? title,
    List<String>? tags,
    double? relevanceScore,
    int? viewCount,
    int? shareCount,
    DateTime? createdAt,
    bool? isTrending,
  }) {
    return ContentRelevance(
      contentId: contentId ?? this.contentId,
      title: title ?? this.title,
      tags: tags ?? this.tags,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      viewCount: viewCount ?? this.viewCount,
      shareCount: shareCount ?? this.shareCount,
      createdAt: createdAt ?? this.createdAt,
      isTrending: isTrending ?? this.isTrending,
    );
  }
}

class ExperienceReport {
  final String reportId;
  final int totalUsers;
  final double averageEngagementScore;
  final double conversionRateOverall;
  final Map<UserSegment, int> usersBySegment;
  final Map<ExperienceType, int> experienceDistribution;
  final double averageNPS;
  final DateTime generatedAt;

  ExperienceReport({
    required this.reportId,
    required this.totalUsers,
    required this.averageEngagementScore,
    required this.conversionRateOverall,
    required this.usersBySegment,
    required this.experienceDistribution,
    required this.averageNPS,
    required this.generatedAt,
  });

  bool get isHealthy => averageEngagementScore > 60 && conversionRateOverall > 0.05;
  bool get hasHighNPS => averageNPS > 50;

  String toMarkdown() {
    return '''# Experience Analytics Report

## Overview
- **Report ID**: $reportId
- **Generated**: ${generatedAt.toString()}
- **Total Users**: $totalUsers
- **Average Engagement Score**: ${averageEngagementScore.toStringAsFixed(2)}/100
- **Overall Conversion Rate**: ${(conversionRateOverall * 100).toStringAsFixed(2)}%
- **Average NPS**: ${averageNPS.toStringAsFixed(2)}

## User Segmentation
${usersBySegment.entries.map((e) => '- ${e.key.displayName}: ${e.value} users').join('\n')}

## Experience Distribution
${experienceDistribution.entries.map((e) => '- ${e.key.displayName}: ${e.value}').join('\n')}

## Health Status
${isHealthy ? '✅ System is healthy' : '⚠️ System needs attention'}
${hasHighNPS ? '✅ High NPS score' : '⚠️ NPS needs improvement'}
''';
  }
}
