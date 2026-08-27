import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../models/analytics_event.dart';
import '../models/user.dart';

/// Firebase Analytics を使用したイベント追跡サービス
abstract class AnalyticsTrackingService {
  /// イベントを記録
  Future<void> trackEvent(AnalyticsEvent event);

  /// ユーザーIDを設定
  Future<void> setUserId(String uid);

  /// ユーザープロパティを設定
  Future<void> setUserProperty(String name, String value);

  /// セッションIDを取得
  String getSessionId();

  /// イベント履歴を取得
  List<AnalyticsEvent> getEventHistory({int limit = 100});

  /// 分析データをリセット
  Future<void> resetAnalytics();
}

/// Firebase Analytics 統合実装
class FirebaseAnalyticsTrackingService implements AnalyticsTrackingService {
  FirebaseAnalyticsTrackingService({
    FirebaseAnalytics? firebaseAnalytics,
  }) : _firebaseAnalytics = firebaseAnalytics ?? FirebaseAnalytics.instance {
    _initializeSession();
  }

  final FirebaseAnalytics _firebaseAnalytics;
  late String _sessionId;
  final List<AnalyticsEvent> _eventHistory = [];
  String? _currentUserId;

  /// セッションを初期化
  void _initializeSession() {
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    if (kDebugMode) {
      debugPrint('Analytics session initialized: $_sessionId');
    }
  }

  @override
  Future<void> trackEvent(AnalyticsEvent event) async {
    try {
      // ローカル履歴に追加
      _eventHistory.add(event);
      if (_eventHistory.length > 1000) {
        _eventHistory.removeAt(0); // 古いイベントを削除
      }

      // Firebase Analytics に送信
      await _firebaseAnalytics.logEvent(
        name: event.eventName,
        parameters: {
          'timestamp': event.timestamp.toIso8601String(),
          'userId': event.userId ?? 'anonymous',
          'sessionId': event.sessionId ?? _sessionId,
          ...event.parameters,
        },
      );

      if (kDebugMode) {
        debugPrint('Event tracked: ${event.eventName}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to track event: $e');
      }
    }
  }

  @override
  Future<void> setUserId(String uid) async {
    try {
      _currentUserId = uid;
      await _firebaseAnalytics.setUserId(uid);

      if (kDebugMode) {
        debugPrint('Analytics userId set: $uid');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to set userId: $e');
      }
    }
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    try {
      await _firebaseAnalytics.setUserProperty(name: name, value: value);

      if (kDebugMode) {
        debugPrint('User property set: $name = $value');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to set user property: $e');
      }
    }
  }

  @override
  String getSessionId() {
    return _sessionId;
  }

  @override
  List<AnalyticsEvent> getEventHistory({int limit = 100}) {
    return _eventHistory.sublist(
      max(0, _eventHistory.length - limit),
      _eventHistory.length,
    );
  }

  @override
  Future<void> resetAnalytics() async {
    try {
      _eventHistory.clear();
      _currentUserId = null;
      _initializeSession();

      if (kDebugMode) {
        debugPrint('Analytics reset');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to reset analytics: $e');
      }
    }
  }
}

/// テスト用スタブ実装
class StubAnalyticsTrackingService implements AnalyticsTrackingService {
  final List<AnalyticsEvent> _eventHistory = [];
  late String _sessionId;
  String? _currentUserId;

  StubAnalyticsTrackingService() {
    _sessionId = 'stub_session_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> trackEvent(AnalyticsEvent event) async {
    _eventHistory.add(event);
    if (_eventHistory.length > 1000) {
      _eventHistory.removeAt(0);
    }
  }

  @override
  Future<void> setUserId(String uid) async {
    _currentUserId = uid;
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    // スタブ - 何もしない
  }

  @override
  String getSessionId() {
    return _sessionId;
  }

  @override
  List<AnalyticsEvent> getEventHistory({int limit = 100}) {
    return _eventHistory.sublist(
      max(0, _eventHistory.length - limit),
      _eventHistory.length,
    );
  }

  @override
  Future<void> resetAnalytics() async {
    _eventHistory.clear();
    _currentUserId = null;
    _sessionId = 'stub_session_${DateTime.now().millisecondsSinceEpoch}';
  }
}

// ヘルパー関数
int max(int a, int b) => a > b ? a : b;

/// 便利な Analytics イベント生成ヘルパー
class AnalyticsEvents {
  /// 質問に回答した
  static AnalyticsEvent questionAnswered({
    required String userId,
    required String sessionId,
    required String questionId,
    required int selectedAnswer,
    required bool isCorrect,
    required int elapsedSeconds,
  }) {
    return AnalyticsEvent(
      type: AnalyticsEventType.questionAnswered,
      timestamp: DateTime.now(),
      userId: userId,
      sessionId: sessionId,
      parameters: {
        'questionId': questionId,
        'selectedAnswer': selectedAnswer,
        'isCorrect': isCorrect,
        'elapsedSeconds': elapsedSeconds,
      },
    );
  }

  /// クイズセッション完了
  static AnalyticsEvent quizSessionCompleted({
    required String userId,
    required String sessionId,
    required int totalQuestions,
    required int correctAnswers,
    required int durationSeconds,
  }) {
    return AnalyticsEvent(
      type: AnalyticsEventType.quizSessionCompleted,
      timestamp: DateTime.now(),
      userId: userId,
      sessionId: sessionId,
      parameters: {
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'accuracy': (correctAnswers / totalQuestions * 100).toStringAsFixed(1),
        'durationSeconds': durationSeconds,
      },
    );
  }

  /// バイク解放
  static AnalyticsEvent bikeUnlocked({
    required String userId,
    required String bikeCategory,
    required int unlockedPercentage,
  }) {
    return AnalyticsEvent(
      type: AnalyticsEventType.bikeUnlocked,
      timestamp: DateTime.now(),
      userId: userId,
      parameters: {
        'bikeCategory': bikeCategory,
        'unlockedPercentage': unlockedPercentage,
      },
    );
  }

  /// 予測スコア計算
  static AnalyticsEvent predictionScoreCalculated({
    required String userId,
    required double score,
    required Map<String, double> breakdown,
  }) {
    return AnalyticsEvent(
      type: AnalyticsEventType.predictionScoreCalculated,
      timestamp: DateTime.now(),
      userId: userId,
      parameters: {
        'score': score,
        'breakdown': breakdown,
      },
    );
  }

  /// エラー発生
  static AnalyticsEvent errorOccurred({
    required String userId,
    required String errorType,
    required String errorMessage,
  }) {
    return AnalyticsEvent(
      type: AnalyticsEventType.errorOccurred,
      timestamp: DateTime.now(),
      userId: userId,
      parameters: {
        'errorType': errorType,
        'errorMessage': errorMessage,
      },
    );
  }
}
