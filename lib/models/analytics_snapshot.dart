import 'dart:convert';

/// 正答率の最小単位。Stage/Category/WeakArea が全て内包する。
class AccuracyStat {
  AccuracyStat({
    required this.attempts,
    required this.correctCount,
    this.lastAnsweredAt,
  });

  final int attempts;
  final int correctCount;
  final DateTime? lastAnsweredAt;

  /// 正答率（0.0 ~ 1.0）
  double get accuracy => attempts == 0 ? 0.0 : correctCount / attempts;

  /// 正答率のパーセント表記
  double get accuracyPercent => accuracy * 100;

  /// 十分な試行回数があるか（最小10回）
  bool get isReliable => attempts >= AccuracyStat.minReliableAttempts;

  static const int minReliableAttempts = 10;

  factory AccuracyStat.fromJson(Map<String, dynamic> json) => AccuracyStat(
    attempts: json['attempts'] as int,
    correctCount: json['correctCount'] as int,
    lastAnsweredAt: json['lastAnsweredAt'] != null
        ? DateTime.parse(json['lastAnsweredAt'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'attempts': attempts,
    'correctCount': correctCount,
    'lastAnsweredAt': lastAnsweredAt?.toIso8601String(),
  };
}

/// ステージ別のパフォーマンス
class StagePerformance {
  StagePerformance({
    required this.stageTag,
    required this.stat,
    this.deltaVsPrevious,
  });

  final String stageTag; // '第一段階', '第二段階'
  final AccuracyStat stat;

  /// 前期間比の正答率変化（相対値）
  final double? deltaVsPrevious;

  factory StagePerformance.fromJson(Map<String, dynamic> json) =>
      StagePerformance(
        stageTag: json['stageTag'] as String,
        stat: AccuracyStat.fromJson(json['stat'] as Map<String, dynamic>),
        deltaVsPrevious: json['deltaVsPrevious'] as double?,
      );

  Map<String, dynamic> toJson() => {
    'stageTag': stageTag,
    'stat': stat.toJson(),
    'deltaVsPrevious': deltaVsPrevious,
  };
}

/// カテゴリ別（免許区分別）のパフォーマンス
class CategoryPerformance {
  CategoryPerformance({
    required this.categoryId,
    required this.stat,
  });

  final String categoryId; // '普通二輪', '原付', '大型二輪'
  final AccuracyStat stat;

  factory CategoryPerformance.fromJson(Map<String, dynamic> json) =>
      CategoryPerformance(
        categoryId: json['categoryId'] as String,
        stat: AccuracyStat.fromJson(json['stat'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
    'categoryId': categoryId,
    'stat': stat.toJson(),
  };
}

/// 弱点のカテゴリ種別
enum WeakAreaKind {
  stage,
  category,
  trapType,
  difficulty,
  topic,
}

/// 学習の弱点を表すモデル
class WeakArea {
  WeakArea({
    required this.kind,
    required this.key,
    required this.label,
    required this.stat,
    required this.severity,
    required this.sampleQuestionIds,
  });

  /// 弱点の種別（ステージ、カテゴリ等）
  final WeakAreaKind kind;

  /// 安定した識別子（例: 'stage:第一段階'）
  final String key;

  /// 表示用の日本語ラベル
  final String label;

  /// 正答率情報
  final AccuracyStat stat;

  /// 重大度スコア（0.0 ~ 1.0）
  /// severity = (1 - accuracy) * confidence * volumeWeight
  /// confidence = min(attempts / 10, 1.0)
  /// volumeWeight = min(attempts / totalAttempts * 5, 1.0)
  final double severity;

  /// 復習に使用する問題IDのサンプル（最大20件）
  final List<String> sampleQuestionIds;

  factory WeakArea.fromJson(Map<String, dynamic> json) => WeakArea(
    kind: WeakAreaKind.values.firstWhere(
      (e) => e.name == json['kind'],
      orElse: () => WeakAreaKind.stage,
    ),
    key: json['key'] as String,
    label: json['label'] as String,
    stat: AccuracyStat.fromJson(json['stat'] as Map<String, dynamic>),
    severity: json['severity'] as double,
    sampleQuestionIds: List<String>.from(json['sampleQuestionIds'] as List),
  );

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'key': key,
    'label': label,
    'stat': stat.toJson(),
    'severity': severity,
    'sampleQuestionIds': sampleQuestionIds,
  };
}

/// 日々の学習進捗データポイント
class DailyPerformancePoint {
  DailyPerformancePoint({
    required this.date,
    required this.attempts,
    required this.correctCount,
  });

  final DateTime date;
  final int attempts;
  final int correctCount;

  double get dailyAccuracy =>
      attempts == 0 ? 0.0 : correctCount / attempts;

  factory DailyPerformancePoint.fromJson(Map<String, dynamic> json) =>
      DailyPerformancePoint(
        date: DateTime.parse(json['date'] as String),
        attempts: json['attempts'] as int,
        correctCount: json['correctCount'] as int,
      );

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'attempts': attempts,
    'correctCount': correctCount,
  };
}

/// 復習アクションの種別
enum ReviewActionType {
  dailyQuota,
  trapDojo,
  stageDrill,
  masteryReview,
}

/// 学習の弱点に基づく復習推奨
class ReviewRecommendation {
  ReviewRecommendation({
    required this.weakAreaKey,
    required this.title,
    required this.body,
    required this.action,
    required this.payload,
  });

  /// 関連する弱点のキー
  final String weakAreaKey;

  /// 推奨のタイトル
  final String title;

  /// 詳細な説明
  final String body;

  /// 実行するアクションの種別
  final ReviewActionType action;

  /// ナビゲーション用のペイロード（例: {'licenseCategory': '普通二輪'}）
  final Map<String, String> payload;

  factory ReviewRecommendation.fromJson(Map<String, dynamic> json) =>
      ReviewRecommendation(
        weakAreaKey: json['weakAreaKey'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        action: ReviewActionType.values.firstWhere(
          (e) => e.name == json['action'],
          orElse: () => ReviewActionType.dailyQuota,
        ),
        payload: Map<String, String>.from(json['payload'] as Map),
      );

  Map<String, dynamic> toJson() => {
    'weakAreaKey': weakAreaKey,
    'title': title,
    'body': body,
    'action': action.name,
    'payload': payload,
  };
}

/// 分析スナップショット：学習分析の完全なスナップショット
class AnalyticsSnapshot {
  AnalyticsSnapshot({
    required this.uid,
    required this.generatedAt,
    required this.sourceLogCount,
    required this.overall,
    required this.stages,
    required this.categories,
    required this.weakAreas,
    required this.recommendations,
    required this.dailyHistory,
    this.orphanLogCount = 0,
  });

  static const int schemaVersion = 1;

  final String uid;
  final DateTime generatedAt;

  /// キャッシュ鮮度判定のフィンガープリント
  final int sourceLogCount;

  /// 全体の正答率情報
  final AccuracyStat overall;

  /// ステージ別パフォーマンス
  final List<StagePerformance> stages;

  /// カテゴリ別パフォーマンス
  final List<CategoryPerformance> categories;

  /// 上位5件の弱点（severity降順）
  final List<WeakArea> weakAreas;

  /// 復習推奨（弱点に基づく）
  final List<ReviewRecommendation> recommendations;

  /// 日々の学習進捗（新しい順）
  final List<DailyPerformancePoint> dailyHistory;

  /// 質問インデックスに存在しない回答ログ数（デバッグ用）
  final int orphanLogCount;

  /// 最も苦手なステージを取得
  String? get weakestStage {
    if (stages.isEmpty) return null;
    var weakest = stages.first;
    for (final stage in stages) {
      if (stage.stat.accuracy < weakest.stat.accuracy) {
        weakest = stage;
      }
    }
    return weakest.stageTag;
  }

  /// 最も苦手なカテゴリを取得
  String? get weakestCategory {
    if (categories.isEmpty) return null;
    var weakest = categories.first;
    for (final cat in categories) {
      if (cat.stat.accuracy < weakest.stat.accuracy) {
        weakest = cat;
      }
    }
    return weakest.categoryId;
  }

  factory AnalyticsSnapshot.fromJson(Map<String, dynamic> json) =>
      AnalyticsSnapshot(
        uid: json['uid'] as String,
        generatedAt: DateTime.parse(json['generatedAt'] as String),
        sourceLogCount: json['sourceLogCount'] as int,
        overall:
            AccuracyStat.fromJson(json['overall'] as Map<String, dynamic>),
        stages: (json['stages'] as List)
            .cast<Map<String, dynamic>>()
            .map(StagePerformance.fromJson)
            .toList(),
        categories: (json['categories'] as List)
            .cast<Map<String, dynamic>>()
            .map(CategoryPerformance.fromJson)
            .toList(),
        weakAreas: (json['weakAreas'] as List)
            .cast<Map<String, dynamic>>()
            .map(WeakArea.fromJson)
            .toList(),
        recommendations: (json['recommendations'] as List)
            .cast<Map<String, dynamic>>()
            .map(ReviewRecommendation.fromJson)
            .toList(),
        dailyHistory: (json['dailyHistory'] as List)
            .cast<Map<String, dynamic>>()
            .map(DailyPerformancePoint.fromJson)
            .toList(),
        orphanLogCount: json['orphanLogCount'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'generatedAt': generatedAt.toIso8601String(),
    'sourceLogCount': sourceLogCount,
    'overall': overall.toJson(),
    'stages': stages.map((s) => s.toJson()).toList(),
    'categories': categories.map((c) => c.toJson()).toList(),
    'weakAreas': weakAreas.map((w) => w.toJson()).toList(),
    'recommendations': recommendations.map((r) => r.toJson()).toList(),
    'dailyHistory': dailyHistory.map((d) => d.toJson()).toList(),
    'orphanLogCount': orphanLogCount,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsSnapshot &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          sourceLogCount == other.sourceLogCount;

  @override
  int get hashCode => uid.hashCode ^ sourceLogCount.hashCode;
}
