import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/achievement_badge.dart';
import '../models/user_answer_log.dart';
import 'local_data_service.dart';

/// バッジ獲得ロジックと状態管理を担当するサービス。
abstract class AchievementService {
  /// ユーザーの回答ログから新しく獲得可能なバッジをチェックして保存。
  Future<List<AchievementBadge>> checkAndUnlockBadges(
    String uid,
    List<UserAnswerLog> answerLogs,
    Map<String, dynamic> questionMetadata,
  );

  /// ユーザーの獲得済みバッジを全て取得。
  Future<List<AchievementBadge>> loadUnlockedBadges(String uid);

  /// 特定のバッジが既に獲得済みかチェック。
  Future<bool> isBadgeUnlocked(String uid, BadgeType badgeType);

  /// ユーザーの全バッジをクリア（テスト用）。
  Future<void> clearAllBadges(String uid);
}

class LocalAchievementService implements AchievementService {
  static const String _storageKeyPrefix = 'badges_';

  @override
  Future<List<AchievementBadge>> checkAndUnlockBadges(
    String uid,
    List<UserAnswerLog> answerLogs,
    Map<String, dynamic> questionMetadata,
  ) async {
    final newBadges = <AchievementBadge>[];
    final existingBadges = await loadUnlockedBadges(uid);
    final existingTypes = {for (final b in existingBadges) b.badgeType};

    // 1. 第一段階 90%以上
    if (!existingTypes.contains(BadgeType.passLevelOne)) {
      final accuracy = _calculateAccuracyForStage(answerLogs, '第一段階', questionMetadata);
      final attempts = _countAttemptsForStage(answerLogs, '第一段階', questionMetadata);
      if (accuracy >= 0.90 && attempts >= 10) {
        newBadges.add(
          AchievementBadge(
            uid: uid,
            badgeType: BadgeType.passLevelOne,
            unlockedAt: DateTime.now(),
            criteria: '第一段階 正答率 ${(accuracy * 100).toStringAsFixed(1)}%',
          ),
        );
      }
    }

    // 2. 第二段階 90%以上
    if (!existingTypes.contains(BadgeType.passLevelTwo)) {
      final accuracy = _calculateAccuracyForStage(answerLogs, '第二段階', questionMetadata);
      final attempts = _countAttemptsForStage(answerLogs, '第二段階', questionMetadata);
      if (accuracy >= 0.90 && attempts >= 10) {
        newBadges.add(
          AchievementBadge(
            uid: uid,
            badgeType: BadgeType.passLevelTwo,
            unlockedAt: DateTime.now(),
            criteria: '第二段階 正答率 ${(accuracy * 100).toStringAsFixed(1)}%',
          ),
        );
      }
    }

    // 3. トラップマスター 95%以上
    if (!existingTypes.contains(BadgeType.masterTrapDojo)) {
      final accuracy = _calculateAccuracyForTrap(answerLogs, questionMetadata);
      if (accuracy >= 0.95 && _countTrapAttempts(answerLogs, questionMetadata) >= 15) {
        newBadges.add(
          AchievementBadge(
            uid: uid,
            badgeType: BadgeType.masterTrapDojo,
            unlockedAt: DateTime.now(),
            criteria: 'トラップ問題 正答率 ${(accuracy * 100).toStringAsFixed(1)}%',
          ),
        );
      }
    }

    // 4. カテゴリマスター（95%以上）
    for (final (category, badgeType) in [
      ('futsuuNirin', BadgeType.masterNirin),
      ('gentsuki', BadgeType.masterGentsuki),
      ('ogataNirin', BadgeType.masterOgataNirin),
    ]) {
      if (!existingTypes.contains(badgeType)) {
        final accuracy =
            _calculateAccuracyForCategory(answerLogs, category, questionMetadata);
        final attempts = _countAttemptsForCategory(answerLogs, category, questionMetadata);
        if (accuracy >= 0.95 && attempts >= 15) {
          newBadges.add(
            AchievementBadge(
              uid: uid,
              badgeType: badgeType,
              unlockedAt: DateTime.now(),
              criteria: '$category 正答率 ${(accuracy * 100).toStringAsFixed(1)}%',
            ),
          );
        }
      }
    }

    // 5. マイルストーン：100問達成
    if (!existingTypes.contains(BadgeType.questionMilestone100)) {
      if (answerLogs.length >= 100) {
        newBadges.add(
          AchievementBadge(
            uid: uid,
            badgeType: BadgeType.questionMilestone100,
            unlockedAt: DateTime.now(),
            criteria: '${answerLogs.length}問解答',
          ),
        );
      }
    }

    // 6. マイルストーン：500問達成
    if (!existingTypes.contains(BadgeType.questionMilestone500)) {
      if (answerLogs.length >= 500) {
        newBadges.add(
          AchievementBadge(
            uid: uid,
            badgeType: BadgeType.questionMilestone500,
            unlockedAt: DateTime.now(),
            criteria: '${answerLogs.length}問解答',
          ),
        );
      }
    }

    // 新しく獲得したバッジを保存
    if (newBadges.isNotEmpty) {
      await _saveBadges(uid, [...existingBadges, ...newBadges]);
    }

    return newBadges;
  }

  @override
  Future<List<AchievementBadge>> loadUnlockedBadges(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey(uid);
    final jsonList = prefs.getStringList(key) ?? [];

    return jsonList
        .map((json) {
          try {
            return AchievementBadge.fromJson(
              _jsonDecode(json),
            );
          } catch (e) {
            return null;
          }
        })
        .whereType<AchievementBadge>()
        .toList();
  }

  @override
  Future<bool> isBadgeUnlocked(String uid, BadgeType badgeType) async {
    final badges = await loadUnlockedBadges(uid);
    return badges.any((b) => b.badgeType == badgeType);
  }

  @override
  Future<void> clearAllBadges(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey(uid);
    await prefs.remove(key);
  }

  // ===== Helper Methods =====

  Future<void> _saveBadges(String uid, List<AchievementBadge> badges) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey(uid);
    final jsonList = badges.map((b) => _jsonEncode(b.toJson())).toList();
    await prefs.setStringList(key, jsonList);
  }

  double _calculateAccuracyForStage(
    List<UserAnswerLog> logs,
    String stage,
    Map<String, dynamic> questionMetadata,
  ) {
    if (logs.isEmpty) return 0.0;
    final stageIds = (questionMetadata['stages']?[stage] as List<String>?) ?? [];
    if (stageIds.isEmpty) {
      // フォールバック：メタデータがない場合は全ログから計算
      final correct = logs.where((l) => l.isCorrect).length;
      return correct / logs.length;
    }
    final stageLogs = logs.where((l) => stageIds.contains(l.questionId)).toList();
    if (stageLogs.isEmpty) return 0.0;
    final correct = stageLogs.where((l) => l.isCorrect).length;
    return correct / stageLogs.length;
  }

  double _calculateAccuracyForTrap(
    List<UserAnswerLog> logs,
    Map<String, dynamic> questionMetadata,
  ) {
    if (logs.isEmpty) return 0.0;
    // trapQuestions から該当する questionId を抽出
    final trapIds = (questionMetadata['trapQuestions'] as List<String>?) ?? [];
    final trapLogs = logs.where((l) => trapIds.contains(l.questionId)).toList();
    if (trapLogs.isEmpty) return 0.0;
    final correct = trapLogs.where((l) => l.isCorrect).length;
    return correct / trapLogs.length;
  }

  double _calculateAccuracyForCategory(
    List<UserAnswerLog> logs,
    String category,
    Map<String, dynamic> questionMetadata,
  ) {
    if (logs.isEmpty) return 0.0;
    final categoryIds =
        (questionMetadata['categories']?[category] as List<String>?) ?? [];
    final categoryLogs =
        logs.where((l) => categoryIds.contains(l.questionId)).toList();
    if (categoryLogs.isEmpty) return 0.0;
    final correct = categoryLogs.where((l) => l.isCorrect).length;
    return correct / categoryLogs.length;
  }

  int _countAttemptsForStage(
    List<UserAnswerLog> logs,
    String stage,
    Map<String, dynamic> questionMetadata,
  ) {
    final stageIds = (questionMetadata['stages']?[stage] as List<String>?) ?? [];
    if (stageIds.isEmpty) {
      // フォールバック：メタデータがない場合は全ログから計算
      return logs.length;
    }
    return logs.where((l) => stageIds.contains(l.questionId)).length;
  }

  int _countAttemptsForCategory(
    List<UserAnswerLog> logs,
    String category,
    Map<String, dynamic> questionMetadata,
  ) {
    final categoryIds = (questionMetadata['categories']?[category] as List<String>?) ?? [];
    if (categoryIds.isEmpty) {
      // フォールバック：メタデータがない場合は全ログから計算
      return logs.length;
    }
    return logs.where((l) => categoryIds.contains(l.questionId)).length;
  }

  int _countTrapAttempts(
    List<UserAnswerLog> logs,
    Map<String, dynamic> questionMetadata,
  ) {
    final trapIds = (questionMetadata['trapQuestions'] as List<String>?) ?? [];
    return logs.where((l) => trapIds.contains(l.questionId)).length;
  }

  String _getStorageKey(String uid) => '${_storageKeyPrefix}$uid';

  /// JSON エンコード：Map を JSON 文字列に変換
  String _jsonEncode(Map<String, dynamic> map) {
    return jsonEncode(map);
  }

  /// JSON デコード：JSON 文字列を Map に変換
  Map<String, dynamic> _jsonDecode(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (e) {
      return {};
    }
  }
}
