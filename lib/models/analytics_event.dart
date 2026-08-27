/// Firebase Analytics イベント追跡用モデル

enum AnalyticsEventType {
  // ユーザー行動
  appLaunched,
  userSignedIn,
  userSignedOut,
  userDeleted,

  // 学習行動
  questionAnswered,
  quizSessionStarted,
  quizSessionCompleted,
  dailyQuotaMet,

  // バイク解放
  bikeUnlocked,
  bikeProgressUpdated,

  // ひっかけ道場
  trapDojoSessionStarted,
  trapDojoSessionCompleted,
  trapDojoBossDefeated,

  // 予測スコア
  predictionScoreCalculated,
  passRateThresholdReached,

  // 購入・パス
  subscriptionPurchased,
  subscriptionCancelled,
  adShown,
  rewardedAdCompleted,

  // エラー
  errorOccurred,
  syncFailed,
  offlineModeActivated,

  // その他
  settingsChanged,
  notificationPreferenceChanged,
}

/// Analytics イベント
class AnalyticsEvent {
  AnalyticsEvent({
    required this.type,
    required this.timestamp,
    this.userId,
    this.sessionId,
    this.parameters = const {},
  });

  final AnalyticsEventType type;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;
  final Map<String, dynamic> parameters;

  /// イベント名を取得（Firebase Analytics用）
  String get eventName {
    return type.toString().split('.').last;
  }

  /// イベントデータをJSON形式に変換
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'eventName': eventName,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'sessionId': sessionId,
      'parameters': parameters,
    };
  }
}

/// アナリティクス集計データ
class AnalyticsSnapshot {
  AnalyticsSnapshot({
    required this.uid,
    required this.period,
    required this.totalQuestionsAnswered,
    required this.correctAnswersCount,
    required this.quizSessionsCompleted,
    required this.averageScore,
    required this.bikesUnlocked,
    required this.trapDojoSessionsCompleted,
    required this.totalSessionDuration,
    required this.lastActiveAt,
    required this.predictionScoreHistory,
  });

  final String uid;
  final DatePeriod period;
  final int totalQuestionsAnswered;
  final int correctAnswersCount;
  final int quizSessionsCompleted;
  final double averageScore;
  final int bikesUnlocked;
  final int trapDojoSessionsCompleted;
  final Duration totalSessionDuration;
  final DateTime lastActiveAt;
  final List<PredictionScoreRecord> predictionScoreHistory;

  /// 正答率を計算
  double get accuracyRate {
    if (totalQuestionsAnswered == 0) return 0.0;
    return (correctAnswersCount / totalQuestionsAnswered) * 100;
  }

  /// 平均セッション時間
  Duration get averageSessionDuration {
    if (quizSessionsCompleted == 0) {
      return Duration.zero;
    }
    return Duration(
      seconds: totalSessionDuration.inSeconds ~/ quizSessionsCompleted,
    );
  }

  /// JSON に変換
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'period': period.toString(),
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'correctAnswersCount': correctAnswersCount,
      'quizSessionsCompleted': quizSessionsCompleted,
      'averageScore': averageScore,
      'bikesUnlocked': bikesUnlocked,
      'trapDojoSessionsCompleted': trapDojoSessionsCompleted,
      'totalSessionDuration': totalSessionDuration.inSeconds,
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'predictionScoreHistory': predictionScoreHistory
          .map((record) => record.toJson())
          .toList(),
    };
  }
}

/// 予測スコア履歴レコード
class PredictionScoreRecord {
  PredictionScoreRecord({
    required this.score,
    required this.calculatedAt,
    required this.breakdown,
  });

  final double score;
  final DateTime calculatedAt;
  final Map<String, double> breakdown; // カテゴリ別スコア

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'calculatedAt': calculatedAt.toIso8601String(),
      'breakdown': breakdown,
    };
  }
}

/// 分析期間
enum DatePeriod {
  daily,
  weekly,
  monthly,
  allTime,
}
