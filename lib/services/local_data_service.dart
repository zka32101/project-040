import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/bike_unlock_progress.dart';
import '../models/pass_prediction_score.dart';
import '../models/question.dart';
import '../models/trap_dojo_session.dart';
import '../models/user.dart';
import '../models/user_answer_log.dart';

/// データ永続化の窓口。
///
/// 本番では Firestore(FirestoreService) をこのインターフェースの実装として
/// 差し込む想定。Firebase設定ファイル（google-services.json 等）未接続でも
/// アプリを起動・動作確認できるよう、初期実装は端末ローカル
/// （SharedPreferences + 同梱JSON問題データ）で完結させている。
///
/// 差し替え方法: main.dart の Provider override で
/// `dataServiceProvider.overrideWithValue(FirestoreDataService())` とする。
abstract class DataService {
  Future<AppUser> loadUser(String uid);
  Future<void> saveUser(AppUser user);

  Future<List<Question>> loadQuestions({
    required String licenseCategory,
    String? stageTag,
  });

  Future<void> appendAnswerLog(UserAnswerLog log);
  /// ログを読み込む（オプション：[since] 以降のログのみ）
  Future<List<UserAnswerLog>> loadAnswerLogs(
    String uid, {
    DateTime? since,
  });

  Future<void> savePredictionScore(PassPredictionScore score);
  Future<PassPredictionScore?> loadPredictionScore(String uid);

  Future<List<BikeUnlockProgress>> loadBikeUnlockProgress(String uid);
  Future<void> saveBikeUnlockProgress(BikeUnlockProgress progress);

  Future<List<TrapDojoSession>> loadTrapDojoSessions(String uid);
  Future<void> saveTrapDojoSession(TrapDojoSession session);
}

/// 入稿パイプライン（スプレッドシート→検証→Firestore投入）が確立するまでの
/// 暫定データソース。assets/questions/*.json を区分ごとに束ねて読み込む。
class LocalDataService implements DataService {
  LocalDataService();

  static const _userPrefix = 'user_';
  static const _answerLogKey = 'answer_logs_';
  static const _predictionKey = 'prediction_score_';
  static const _bikeUnlockKey = 'bike_unlock_';
  static const _trapDojoKey = 'trap_dojo_';

  static const Map<String, String> _questionAssetByCategory = {
    'gentsuki': 'assets/questions/gentsuki.json',
    'kogataGentsukiNirin': 'assets/questions/futsuu_nirin.json',
    'futsuuNirin': 'assets/questions/futsuu_nirin.json',
    'ogataNirin': 'assets/questions/ogata_nirin.json',
    'atGentei': 'assets/questions/futsuu_nirin.json',
  };

  final Map<String, List<Question>> _questionCache = {};

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<AppUser> loadUser(String uid) async {
    final prefs = await _prefs;
    final raw = prefs.getString('$_userPrefix$uid');
    if (raw == null) return AppUser(uid: uid);
    return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> saveUser(AppUser user) async {
    final prefs = await _prefs;
    await prefs.setString('$_userPrefix${user.uid}', jsonEncode(user.toJson()));
  }

  @override
  Future<List<Question>> loadQuestions({
    required String licenseCategory,
    String? stageTag,
  }) async {
    final asset = _questionAssetByCategory[licenseCategory];
    if (asset == null) return [];

    var pool = _questionCache[asset];
    if (pool == null) {
      final raw = await rootBundle.loadString(asset);
      final list = jsonDecode(raw) as List;
      pool = list
          .map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList();
      _questionCache[asset] = pool;
    }

    return pool
        .where((q) => q.licenseCategory.contains(licenseCategory))
        .where((q) => stageTag == null || stageTag.isEmpty || q.stageTag == stageTag)
        .toList();
  }

  @override
  Future<void> appendAnswerLog(UserAnswerLog log) async {
    final prefs = await _prefs;
    final key = '$_answerLogKey${log.uid}';
    final existing = prefs.getStringList(key) ?? [];
    existing.add(jsonEncode(log.toJson()));
    await prefs.setStringList(key, existing);
  }

  @override
  Future<List<UserAnswerLog>> loadAnswerLogs(
    String uid, {
    DateTime? since,
  }) async {
    final prefs = await _prefs;
    final existing = prefs.getStringList('$_answerLogKey$uid') ?? [];
    final logs = existing
        .map((e) => UserAnswerLog.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();

    // since 指定時はフィルタ
    if (since != null) {
      return logs.where((log) => log.answeredAt.isAfter(since)).toList();
    }
    return logs;
  }

  @override
  Future<void> savePredictionScore(PassPredictionScore score) async {
    final prefs = await _prefs;
    await prefs.setString(
      '$_predictionKey${score.uid}',
      jsonEncode(score.toJson()),
    );
  }

  @override
  Future<PassPredictionScore?> loadPredictionScore(String uid) async {
    final prefs = await _prefs;
    final raw = prefs.getString('$_predictionKey$uid');
    if (raw == null) return null;
    return PassPredictionScore.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<List<BikeUnlockProgress>> loadBikeUnlockProgress(String uid) async {
    final prefs = await _prefs;
    final existing = prefs.getStringList('$_bikeUnlockKey$uid') ?? [];
    return existing
        .map((e) => BikeUnlockProgress.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveBikeUnlockProgress(BikeUnlockProgress progress) async {
    final prefs = await _prefs;
    final key = '$_bikeUnlockKey${progress.uid}';
    final existing = await loadBikeUnlockProgress(progress.uid);
    final updated = [
      ...existing.where((p) => p.bikeId != progress.bikeId),
      progress,
    ];
    await prefs.setStringList(
      key,
      updated.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  @override
  Future<List<TrapDojoSession>> loadTrapDojoSessions(String uid) async {
    final prefs = await _prefs;
    final existing = prefs.getStringList('$_trapDojoKey$uid') ?? [];
    return existing
        .map((e) => TrapDojoSession.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveTrapDojoSession(TrapDojoSession session) async {
    final prefs = await _prefs;
    final key = '$_trapDojoKey${session.uid}';
    final existing = await loadTrapDojoSessions(session.uid);
    final updated = [
      ...existing.where((s) => s.bossQuestionId != session.bossQuestionId),
      session,
    ];
    await prefs.setStringList(
      key,
      updated.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }
}
