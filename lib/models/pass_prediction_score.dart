/// 合格予測メーターのスコア。
///
/// 【致命的リスク①対応・実装時注意】単純な正答率ベースでは「予測」と
/// 名乗るには説得力が弱い。UI側では区分に応じて「予測」／「習熟度」の
/// 表記を出し分けられるよう、根拠(breakdown)を必ず保持しておくこと。
/// もっともらしい数値の独り歩きを避ける。
class PassPredictionScore {
  PassPredictionScore({
    required this.uid,
    required this.score,
    required this.calculatedAt,
    required this.breakdown,
  }) : assert(score >= 0 && score <= 100, 'score must be 0-100');

  final String uid;

  /// 0-100。UI表示は最小回答数に満たない場合「習熟度」表記へフォールバック。
  final double score;
  final DateTime calculatedAt;

  /// 区分別正答率（key: LicenseCategory.name, value: 0.0-1.0）。
  final Map<String, double> breakdown;

  factory PassPredictionScore.fromJson(Map<String, dynamic> json) =>
      PassPredictionScore(
        uid: json['uid'] as String,
        score: (json['score'] as num).toDouble(),
        calculatedAt: DateTime.parse(json['calculatedAt'] as String),
        breakdown: Map<String, double>.from(
          (json['breakdown'] as Map).map(
            (k, v) => MapEntry(k as String, (v as num).toDouble()),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'score': score,
    'calculatedAt': calculatedAt.toIso8601String(),
    'breakdown': breakdown,
  };
}
