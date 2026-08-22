import 'package:flutter/foundation.dart';

/// 計測3点セット（Analytics/Crashlytics/Remote Config）のうち Analytics 送信口。
///
/// Firebase未接続環境（このリポジトリの初期状態）ではログ出力のみ行う
/// スタブとして動作し、`firebase_analytics` を有効化した実装に差し替え可能な
/// インターフェースにしてある。KPIイベント名は AnalyticsEvents を必ず使うこと
/// （文字列直書き禁止 — タイポによる計測欠落を防ぐ）。
abstract class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object?> parameters = const {}});
}

class DebugAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    if (kDebugMode) {
      debugPrint('[analytics] $name $parameters');
    }
  }
}

// TODO(firebase-setup): FirebaseAnalyticsService を実装し、
// google-services.json / GoogleService-Info.plist 追加後に main.dart で差し替える。
// class FirebaseAnalyticsService implements AnalyticsService {
//   final _analytics = FirebaseAnalytics.instance;
//   @override
//   Future<void> logEvent(String name, {Map<String, Object?> parameters = const {}}) =>
//       _analytics.logEvent(name: name, parameters: parameters);
// }
