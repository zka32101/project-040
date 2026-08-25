import 'package:shared_preferences/shared_preferences.dart';

import '../models/question_mastery_status.dart';

/// 「記憶した」フラグの管理サービス。
/// shared_preferences でローカルに永続化する。
abstract class MasteryService {
  /// 指定の問題をマスター済みにする。
  Future<void> markAsMastered(String uid, String questionId);

  /// マスター済みフラグを解除する。
  Future<void> unmarkAsMastered(String uid, String questionId);

  /// 指定ユーザーの全マスター問題を取得。
  Future<List<QuestionMasteryStatus>> loadMasteredQuestions(String uid);

  /// 指定ユーザーの特定カテゴリのマスター問題を取得。
  Future<List<QuestionMasteryStatus>> loadMasteredQuestionsInCategory(
    String uid,
    List<String> questionIds,
  );

  /// 指定問題がマスター済みかチェック。
  Future<bool> isMastered(String uid, String questionId);

  /// 指定ユーザーの全マスター済み問題をクリア。
  Future<void> clearAllMastered(String uid);
}

class LocalMasteryService implements MasteryService {
  static const String _storageKeyPrefix = 'mastered_questions_';

  @override
  Future<void> markAsMastered(String uid, String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey(uid);
    final current = prefs.getStringList(key) ?? [];

    if (!current.contains(questionId)) {
      current.add(questionId);
      await prefs.setStringList(key, current);
    }
  }

  @override
  Future<void> unmarkAsMastered(String uid, String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey(uid);
    final current = prefs.getStringList(key) ?? [];

    if (current.contains(questionId)) {
      current.remove(questionId);
      await prefs.setStringList(key, current);
    }
  }

  @override
  Future<List<QuestionMasteryStatus>> loadMasteredQuestions(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey(uid);
    final ids = prefs.getStringList(key) ?? [];

    return ids.map((id) {
      return QuestionMasteryStatus(
        uid: uid,
        questionId: id,
        isMastered: true,
        masteredAt: DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<List<QuestionMasteryStatus>> loadMasteredQuestionsInCategory(
    String uid,
    List<String> questionIds,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey(uid);
    final masteredIds = prefs.getStringList(key) ?? [];

    final filtered = questionIds.where((id) => masteredIds.contains(id)).toList();

    return filtered.map((id) {
      return QuestionMasteryStatus(
        uid: uid,
        questionId: id,
        isMastered: true,
        masteredAt: DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<bool> isMastered(String uid, String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey(uid);
    final ids = prefs.getStringList(key) ?? [];
    return ids.contains(questionId);
  }

  @override
  Future<void> clearAllMastered(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey(uid);
    await prefs.remove(key);
  }

  String _getStorageKey(String uid) => '${_storageKeyPrefix}$uid';
}
