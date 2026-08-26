import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../models/analytics_snapshot.dart';
import '../models/user_answer_log.dart';
import 'question_index.dart';
import 'study_analytics_service.dart';

/// 大規模ログセット用の分離スレッド処理サービス
/// 2000件以上のログがある場合、isolate 上で aggregate() を実行して UI ブロッキングを回避
class AnalyticsIsolateService {
  /// 大規模処理のしきい値（ログ件数）
  static const int _largeDatasetThreshold = 2000;

  /// 分析スナップショットを計算
  /// ログ数が多い場合は compute() で背景スレッドに移譲
  static Future<AnalyticsSnapshot> aggregateWithThreshold({
    required String uid,
    required List<UserAnswerLog> logs,
    required QuestionIndex index,
    required DateTime now,
  }) async {
    // 小規模なら同期的に計算（UI ブロッキングなし）
    if (logs.length < _largeDatasetThreshold) {
      final service = DefaultStudyAnalyticsService();
      return service.aggregate(
        uid: uid,
        logs: logs,
        index: index,
        now: now,
      );
    }

    // 大規模なら isolate に移譲
    return _aggregateInIsolate(
      uid: uid,
      logs: logs,
      index: index,
      now: now,
    );
  }

  /// Isolate 上で aggregate を実行
  static Future<AnalyticsSnapshot> _aggregateInIsolate({
    required String uid,
    required List<UserAnswerLog> logs,
    required QuestionIndex index,
    required DateTime now,
  }) async {
    try {
      return await compute(
        _aggregateInBackground,
        _AggregateParams(
          uid: uid,
          logs: logs,
          index: index,
          now: now,
        ),
      );
    } catch (e) {
      // Isolate 処理に失敗した場合は UI スレッドで実行
      // （フォールバック：速度は落ちるが、処理は進む）
      final service = DefaultStudyAnalyticsService();
      return service.aggregate(
        uid: uid,
        logs: logs,
        index: index,
        now: now,
      );
    }
  }
}

/// Isolate 間通信用のパラメータクラス
class _AggregateParams {
  final String uid;
  final List<UserAnswerLog> logs;
  final QuestionIndex index;
  final DateTime now;

  _AggregateParams({
    required this.uid,
    required this.logs,
    required this.index,
    required this.now,
  });
}

/// Top-level な aggregate 関数（compute() で直接参照可能）
@pragma('vm:entry-point')
AnalyticsSnapshot _aggregateInBackground(_AggregateParams params) {
  final service = DefaultStudyAnalyticsService();
  return service.aggregate(
    uid: params.uid,
    logs: params.logs,
    index: params.index,
    now: params.now,
  );
}
