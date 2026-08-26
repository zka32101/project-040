/// 計測設計（企画設計書 v1.1 Step4.5）で定義されたKPIイベント名。
///
/// 8個すべてを漏れなく計測すること（実装引き継ぎ書「実装の注意点」参照）。
class AnalyticsEvents {
  AnalyticsEvents._();

  /// 初回3問正解→合格予測メーター初表示。Aha Moment本体。
  static const String ahaMomentReached = 'aha_moment_reached';

  /// 1日ノルマ完走。
  static const String dailyQuotaCompleted = 'daily_quota_completed';

  /// ひっかけ道場のボス撃破。
  static const String trapBossDefeated = 'trap_boss_defeated';

  /// バイク解放。
  static const String bikeUnlocked = 'bike_unlocked';

  /// ペイウォール経由の課金成立。
  static const String paywallConverted = 'paywall_converted';

  /// インタースティシャル表示。
  static const String interstitialShown = 'interstitial_shown';

  /// リワード広告視聴完了。
  static const String rewardedAdCompleted = 'rewarded_ad_completed';

  /// 広告表示直後のセッション離脱（監視用）。
  static const String adShownSessionEnd = 'ad_shown_session_end';

  /// 学習分析ダッシュボード表示（Phase 3）。
  /// parameters: license_category（カテゴリが複数の場合はカンマ区切り）
  static const String analyticsDashboardOpened = 'analytics_dashboard_opened';

  /// 弱点領域の復習開始（Phase 3）。
  /// parameters: weak_area_kind (stage/category/trapType/difficulty/topic)、
  ///            action_type (dailyQuota/trapDojo/stageDrill/masteryReview)
  static const String weakAreaReviewStarted = 'weak_area_review_started';

  /// 分析期間フィルター変更（Phase 3）。
  /// parameters: range (days7/days30/allTime)
  static const String analyticsRangeChanged = 'analytics_range_changed';
}
