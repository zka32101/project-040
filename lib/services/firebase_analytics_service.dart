import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'analytics_service.dart';

/// Firebase Analytics を用いた計測実装。
///
/// Production環境ではこのサービスを AnalyticsService として inject する。
/// FirebaseCore.initializeApp() で Firebase が初期化されている前提。
///
/// イベント名は AnalyticsEvents enum から必ず指定すること
/// （文字列直書き禁止 — タイポによる計測欠落や名前ズレを防ぐ）。
///
/// KPI: aha_moment_reached, daily_quota_completed, trap_boss_defeated,
///      bike_unlocked, paywall_converted, interstitial_shown,
///      rewarded_ad_completed, ad_shown_session_end
class FirebaseAnalyticsService implements AnalyticsService {
  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsService({
    FirebaseAnalytics? analytics,
  }) : _analytics = analytics ?? FirebaseAnalytics.instance;

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      // Analytics エラーはアプリケーションを止めない
      // ただしログには出す（Firebase Console でトレース可能）
      if (kDebugMode) {
        debugPrint('Analytics error: $e');
      }
    }
  }
}
