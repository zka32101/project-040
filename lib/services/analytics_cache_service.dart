import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/analytics_snapshot.dart';
import '../models/user_answer_log.dart';

/// 分析スナップショットの永続化キャッシュサービス
/// ログの指紋（フィンガープリント）に基づいて更新判定を行い、
/// 計算コスト（aggregate）を削減します。
abstract class AnalyticsCacheService {
  /// キャッシュから最新のスナップショットを取得（存在し、有効かつログが変わっていないならnull以外）
  /// [logs] 現在のログリスト。キャッシュの指紋と比較するために使用
  Future<AnalyticsSnapshot?> getCachedIfValid(
    String uid,
    List<UserAnswerLog> logs,
  );

  /// スナップショットをキャッシュに永続化
  Future<void> cache(String uid, AnalyticsSnapshot snapshot, List<UserAnswerLog> logs);

  /// キャッシュを明示的にクリア
  Future<void> clear(String uid);

  /// ログの指紋を計算（キャッシュ有効性判定用）
  String calculateLogFingerprint(List<UserAnswerLog> logs);
}

/// ローカル実装（SharedPreferences）
class LocalAnalyticsCacheService extends AnalyticsCacheService {
  static const String _cacheKeyPrefix = 'analytics_snapshot_';
  static const String _fingerprintKeyPrefix = 'analytics_fingerprint_';
  static const String _timestampKeyPrefix = 'analytics_timestamp_';

  /// キャッシュ有効期限（1時間）
  static const Duration _cacheTTL = Duration(hours: 1);

  @override
  Future<AnalyticsSnapshot?> getCachedIfValid(
    String uid,
    List<UserAnswerLog> logs,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _cacheKeyPrefix + uid;
      final json = prefs.getString(key);

      if (json == null) return null;

      // キャッシュが有効期限内か確認
      final timestampKey = _timestampKeyPrefix + uid;
      final timestamp = prefs.getInt(timestampKey);
      if (timestamp != null) {
        final cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        if (now.difference(cachedAt) > _cacheTTL) {
          // TTL切れ：キャッシュをクリアして返す
          await clear(uid);
          return null;
        }
      }

      // 指紋を確認（ログが変わっていないか）
      final currentFingerprint = calculateLogFingerprint(logs);
      final fingerprintKey = _fingerprintKeyPrefix + uid;
      final cachedFingerprint = prefs.getString(fingerprintKey);

      if (cachedFingerprint != currentFingerprint) {
        // ログが変わっている：キャッシュは無効
        await clear(uid);
        return null;
      }

      // JSON をデコード
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return AnalyticsSnapshot.fromJson(decoded);
    } catch (e) {
      // デコードエラーは無視、キャッシュをクリア
      await clear(uid);
      return null;
    }
  }

  @override
  Future<void> cache(
    String uid,
    AnalyticsSnapshot snapshot,
    List<UserAnswerLog> logs,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // スナップショットを JSON に変換
      final json = jsonEncode(snapshot.toJson());
      await prefs.setString(_cacheKeyPrefix + uid, json);

      // 指紋を計算して保存
      final fingerprint = calculateLogFingerprint(logs);
      await prefs.setString(_fingerprintKeyPrefix + uid, fingerprint);

      // タイムスタンプを保存（キャッシュ有効期限判定用）
      await prefs.setInt(
        _timestampKeyPrefix + uid,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // キャッシュ失敗は無視（分析処理自体は続行）
    }
  }

  @override
  Future<void> clear(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKeyPrefix + uid);
      await prefs.remove(_fingerprintKeyPrefix + uid);
      await prefs.remove(_timestampKeyPrefix + uid);
    } catch (e) {
      // クリア失敗は無視
    }
  }

  @override
  String calculateLogFingerprint(List<UserAnswerLog> logs) {
    if (logs.isEmpty) return '';

    // ログをソート（ID と タイムスタンプで）
    final sorted = [...logs]..sort((a, b) => a.questionId.compareTo(b.questionId));

    // 各ログから：questionId, answeredAt, isCorrect を抽出
    final parts = sorted.map((log) {
      return '${log.questionId}|${log.answeredAt.toIso8601String()}|${log.isCorrect}';
    }).toList();

    // SHA256 でハッシュ化
    return sha256.convert(utf8.encode(parts.join('\n'))).toString();
  }
}

/// テスト用スタブ実装（キャッシュなし）
class StubAnalyticsCacheService extends AnalyticsCacheService {
  @override
  Future<AnalyticsSnapshot?> getCachedIfValid(
    String uid,
    List<UserAnswerLog> logs,
  ) =>
      Future.value(null);

  @override
  Future<void> cache(
    String uid,
    AnalyticsSnapshot snapshot,
    List<UserAnswerLog> logs,
  ) =>
      Future.value();

  @override
  Future<void> clear(String uid) => Future.value();

  @override
  String calculateLogFingerprint(List<UserAnswerLog> logs) => '';
}
