/// Phase 45: User Feedback & Rating System ユーザーフィードバックモデル定義
///
/// フィードバック、評価、レビュー、センチメント分析

/// フィードバックタイプ
enum FeedbackType {
  bug('bug'),
  feature('feature'),
  improvement('improvement'),
  documentation('documentation'),
  other('other');

  final String value;
  const FeedbackType(this.value);
}

/// フィードバックステータス
enum FeedbackStatus {
  new_('new'),
  acknowledged('acknowledged'),
  inProgress('in_progress'),
  closed('closed'),
  reopened('reopened');

  final String value;
  const FeedbackStatus(this.value);
}

/// 評価スケール
enum RatingScale {
  poor(1),
  fair(2),
  good(3),
  veryGood(4),
  excellent(5);

  final int value;
  const RatingScale(this.value);
}

/// センチメント分析
enum Sentiment {
  negative('negative'),
  neutral('neutral'),
  positive('positive');

  final String value;
  const Sentiment(this.value);
}

/// ユーザーフィードバック
class UserFeedback {
  final String feedbackId;
  final String userId;
  final String title;
  final String description;
  final FeedbackType type;
  final FeedbackStatus status;
  final int rating; // 1-5
  final List<String>? tags;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int helpfulCount;
  final int notHelpfulCount;

  UserFeedback({
    required this.feedbackId,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    this.status = FeedbackStatus.new_,
    required this.rating,
    this.tags,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
    this.helpfulCount = 0,
    this.notHelpfulCount = 0,
  });

  /// フィードバックが役に立つと判断されたか
  bool get isHelpful => helpfulCount > notHelpfulCount;

  /// 役に立ちスコア (-1.0 ~ 1.0)
  double get helpfulnessScore {
    final total = helpfulCount + notHelpfulCount;
    if (total == 0) return 0.0;
    return (helpfulCount - notHelpfulCount) / total;
  }

  /// フィードバックの年齢
  Duration get age => DateTime.now().difference(createdAt);
}

/// アプリ評価
class AppRating {
  final String ratingId;
  final String userId;
  final RatingScale rating;
  final String? reviewText;
  final List<String>? aspects; // e.g. ['performance', 'usability', 'design']
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int helpfulCount;

  AppRating({
    required this.ratingId,
    required this.userId,
    required this.rating,
    this.reviewText,
    this.aspects,
    required this.createdAt,
    this.updatedAt,
    this.helpfulCount = 0,
  });

  /// スター数（1-5）
  int get stars => rating.value;

  /// レビューを持っているか
  bool get hasReview => reviewText != null && reviewText!.isNotEmpty;
}

/// レビューコメント
class ReviewComment {
  final String commentId;
  final String reviewId;
  final String userId;
  final String text;
  final int likeCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReviewComment({
    required this.commentId,
    required this.reviewId,
    required this.userId,
    required this.text,
    this.likeCount = 0,
    required this.createdAt,
    this.updatedAt,
  });
}

/// センチメント分析結果
class SentimentAnalysis {
  final String analysisId;
  final String feedbackId;
  final Sentiment sentiment;
  final double confidence; // 0.0-1.0
  final List<String> keywords;
  final String? summary;
  final DateTime analyzedAt;

  SentimentAnalysis({
    required this.analysisId,
    required this.feedbackId,
    required this.sentiment,
    required this.confidence,
    required this.keywords,
    this.summary,
    required this.analyzedAt,
  });

  /// 信頼度スコア (0-100)
  int get confidencePercentage => (confidence * 100).toInt();

  /// 分析結果が信頼できるか
  bool get isReliable => confidence >= 0.7;
}

/// フィードバック集計
class FeedbackAggregate {
  final String aggregateId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalFeedbacks;
  final int totalRatings;
  final double averageRating;
  final Map<FeedbackType, int> typeDistribution;
  final Map<Sentiment, int> sentimentDistribution;
  final int resolvedCount;
  final int pendingCount;

  FeedbackAggregate({
    required this.aggregateId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalFeedbacks,
    required this.totalRatings,
    required this.averageRating,
    required this.typeDistribution,
    required this.sentimentDistribution,
    required this.resolvedCount,
    required this.pendingCount,
  });

  /// 解決率
  double get resolutionRate {
    final total = resolvedCount + pendingCount;
    if (total == 0) return 0.0;
    return resolvedCount / total;
  }

  /// 最も一般的なタイプ
  FeedbackType? get mostCommonType {
    if (typeDistribution.isEmpty) return null;
    return typeDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// 最もポジティブなセンチメント
  Sentiment? get dominantSentiment {
    if (sentimentDistribution.isEmpty) return null;
    return sentimentDistribution.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

/// ユーザー満足度スコア (NPS - Net Promoter Score)
class NetPromoterScore {
  final String npsId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int promoters; // rating 4-5
  final int passives; // rating 3
  final int detractors; // rating 1-2
  final double npsScore; // (promoters - detractors) / (promoters + passives + detractors) * 100

  NetPromoterScore({
    required this.npsId,
    required this.periodStart,
    required this.periodEnd,
    required this.promoters,
    required this.passives,
    required this.detractors,
    required this.npsScore,
  });

  /// 総回答数
  int get totalResponses => promoters + passives + detractors;

  /// NPS カテゴリ
  String get category {
    if (npsScore >= 70) return 'Excellent';
    if (npsScore >= 50) return 'Good';
    if (npsScore >= 0) return 'Acceptable';
    return 'Poor';
  }

  /// トレンド判定
  bool get isPositive => npsScore > 0;
}

/// フィードバックレポート
class FeedbackReport {
  final String reportId;
  final DateTime generatedAt;
  final FeedbackAggregate aggregate;
  final NetPromoterScore? nps;
  final List<UserFeedback> topFeedbacks;
  final List<AppRating> topRatings;
  final List<String>? recommendations;
  final Map<String, dynamic>? insights;

  FeedbackReport({
    required this.reportId,
    required this.generatedAt,
    required this.aggregate,
    this.nps,
    required this.topFeedbacks,
    required this.topRatings,
    this.recommendations,
    this.insights,
  });

  /// Markdown 形式でレポートを生成
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# User Feedback & Rating Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');

    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Total Feedbacks: ${aggregate.totalFeedbacks}');
    buffer.writeln('- Total Ratings: ${aggregate.totalRatings}');
    buffer.writeln('- Average Rating: ${aggregate.averageRating.toStringAsFixed(2)}/5.0');
    buffer.writeln('- Resolution Rate: ${(aggregate.resolutionRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('');

    if (nps != null) {
      buffer.writeln('## Net Promoter Score (NPS)');
      buffer.writeln('');
      buffer.writeln('- NPS Score: ${nps!.npsScore.toStringAsFixed(1)}');
      buffer.writeln('- Category: ${nps!.category}');
      buffer.writeln('- Promoters: ${nps!.promoters}');
      buffer.writeln('- Passives: ${nps!.passives}');
      buffer.writeln('- Detractors: ${nps!.detractors}');
      buffer.writeln('');
    }

    if (recommendations != null && recommendations!.isNotEmpty) {
      buffer.writeln('## Recommendations');
      buffer.writeln('');
      for (final rec in recommendations!) {
        buffer.writeln('- $rec');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}
