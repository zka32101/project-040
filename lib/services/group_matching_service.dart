import 'package:flutter/foundation.dart';
import '../models/ai_recommendation_model.dart';
import 'dart:math' as math;
import 'package:collection/collection.dart';

/// グループマッチング・協調学習サービス
/// スタディグループの自動組成と効果的な協働学習を支援
class GroupMatchingService {
  final Map<String, StudyGroupMatch> _matchCache = {};
  final Map<String, List<GroupLearningSession>> _sessionCache = {};

  /// スタディグループのマッチング：相互補完的な学生をペアリング
  Future<StudyGroupMatch> matchStudyGroup({
    required String studentId,
    required Map<String, double> categoryScores,
    required int totalQuestionsAttempted,
    required double learningVelocity,
    required List<String> weakCategories,
    required List<String> strongCategories,
    required List<Map<String, dynamic>> cohortStudents, // コホート内の他の学生
  }) async {
    // キャッシュから取得
    if (_matchCache.containsKey(studentId)) {
      return _matchCache[studentId]!;
    }

    try {
      // 1. 対象学生のプロファイルを作成
      final studentProfile = _buildStudentProfile(
        studentId: studentId,
        categoryScores: categoryScores,
        velocity: learningVelocity,
        weakCategories: weakCategories,
        strongCategories: strongCategories,
      );

      // 2. コホート内の他の学生との互換性スコアを計算
      final compatibilityScores = <String, double>{};
      for (final other in cohortStudents) {
        final peerId = other['student_id'] as String?;
        if (peerId == null || peerId == studentId) continue;

        final compatibility = _calculateCompatibility(
          student1Profile: studentProfile,
          student2: other,
        );
        if (compatibility > 0.4) {
          // 互換性 40% 以上のみを対象
          compatibilityScores[peerId] = compatibility;
        }
      }

      // 3. 最適なマッチを選択（互換性スコアが高い3～5人）
      final sortedMatches = compatibilityScores.entries
          .sorted((a, b) => b.value.compareTo(a.value))
          .take(5)
          .map((e) => e.key)
          .toList();

      // 4. グループ学習が効果的なトピックを特定
      final effectiveTopics = _identifyEffectiveTopics(
        studentWeak: weakCategories,
        peerStrong: cohortStudents
            .where((s) => sortedMatches.contains(s['student_id']))
            .expand<String>((s) => (s['strong_categories'] as List?)?.cast<String>() ?? [])
            .toSet()
            .toList(),
      );

      final match = StudyGroupMatch(
        studentId: studentId,
        suggestedPeerIds: sortedMatches,
        suggestedTopics: effectiveTopics,
        compatibilityScore:
            compatibilityScores.isEmpty ? 0 : compatibilityScores.values.average * 100,
        reason:
            '相互補完的なスキル構成で学習効果が最大化されるグループです。${effectiveTopics.length}個の単元でグループ学習が効果的です。',
        generatedAt: DateTime.now(),
      );

      // キャッシュに保存
      _matchCache[studentId] = match;
      return match;
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'GroupMatchingService.match');
      rethrow;
    }
  }

  /// グループ学習セッションの作成
  Future<GroupLearningSession> createGroupSession({
    required List<String> studentIds,
    required String topicId,
    required String topicName,
    required int estimatedDurationMinutes,
    required DateTime scheduledAt,
    List<String>? resourceUrls,
  }) async {
    try {
      final sessionId = _generateSessionId(studentIds, topicId);

      final session = GroupLearningSession(
        id: sessionId,
        studentIds: studentIds,
        topicId: topicId,
        topicName: topicName,
        scheduledAt: scheduledAt,
        startedAt: null,
        completedAt: null,
        estimatedDurationMinutes: estimatedDurationMinutes,
        resourceUrls: resourceUrls ?? [],
        outcome: null,
        studentScores: null,
      );

      // キャッシュに保存
      _sessionCache
          .putIfAbsent(studentIds.first, () => [])
          .add(session);

      return session;
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'GroupMatchingService.createSession');
      rethrow;
    }
  }

  /// グループセッションの開始
  Future<GroupLearningSession> startGroupSession({
    required String sessionId,
    required List<String> studentIds,
  }) async {
    try {
      final sessions = _sessionCache[studentIds.first] ?? [];
      final sessionIndex =
          sessions.indexWhere((s) => s.id == sessionId);

      if (sessionIndex == -1) {
        throw Exception('Session not found: $sessionId');
      }

      final session = sessions[sessionIndex];
      final updatedSession = session.copyWith(
        startedAt: DateTime.now(),
        outcome: 'in_progress',
      );

      sessions[sessionIndex] = updatedSession;
      return updatedSession;
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'GroupMatchingService.startSession');
      rethrow;
    }
  }

  /// グループセッションの終了・採点
  Future<GroupLearningSession> completeGroupSession({
    required String sessionId,
    required List<String> studentIds,
    required Map<String, double> studentScores, // 学生ごとのパフォーマンススコア (0-100)
    required String outcome, // 'completed', 'incomplete', 'cancelled'
  }) async {
    try {
      final sessions = _sessionCache[studentIds.first] ?? [];
      final sessionIndex =
          sessions.indexWhere((s) => s.id == sessionId);

      if (sessionIndex == -1) {
        throw Exception('Session not found: $sessionId');
      }

      final session = sessions[sessionIndex];

      // スコアの妥当性チェック
      for (final score in studentScores.values) {
        if (score < 0 || score > 100) {
          throw ArgumentError('Student score must be between 0 and 100');
        }
      }

      final updatedSession = session.copyWith(
        completedAt: DateTime.now(),
        outcome: outcome,
        studentScores: studentScores,
      );

      sessions[sessionIndex] = updatedSession;
      return updatedSession;
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'GroupMatchingService.completeSession');
      rethrow;
    }
  }

  /// 学生プロファイルの構築
  Map<String, dynamic> _buildStudentProfile({
    required String studentId,
    required Map<String, double> categoryScores,
    required double velocity,
    required List<String> weakCategories,
    required List<String> strongCategories,
  }) {
    return {
      'student_id': studentId,
      'average_score': categoryScores.isEmpty
          ? 0
          : categoryScores.values.reduce((a, b) => a + b) / categoryScores.length,
      'velocity': velocity,
      'weak_categories': weakCategories,
      'strong_categories': strongCategories,
      'category_scores': categoryScores,
      'profile_type': _determineProfileType(weakCategories, strongCategories),
    };
  }

  /// 学生のプロファイルタイプを決定
  String _determineProfileType(
    List<String> weakCategories,
    List<String> strongCategories,
  ) {
    if (strongCategories.length > weakCategories.length) {
      return 'mentor'; // メンター：強い分野が多い
    } else if (weakCategories.length > strongCategories.length) {
      return 'learner'; // 学習者：弱い分野が多い
    } else {
      return 'balanced'; // バランス型
    }
  }

  /// 互換性スコアの計算（0-1）
  double _calculateCompatibility({
    required Map<String, dynamic> student1Profile,
    required Map<String, dynamic> student2,
  }) {
    try {
      // 相互補完性を重視（一方の強い分野が他方の弱い分野）
      final s1Weak = (student1Profile['weak_categories'] as List?)?.cast<String>() ?? [];
      final s1Strong =
          (student1Profile['strong_categories'] as List?)?.cast<String>() ?? [];

      final s2Strong =
          (student2['strong_categories'] as List?)?.cast<String>() ?? [];
      final s2Weak = (student2['weak_categories'] as List?)?.cast<String>() ?? [];

      // 補完的ペアの特定
      final s1WeakCoveredByS2 = s1Weak.where((c) => s2Strong.contains(c)).length;
      final s2WeakCoveredByS1 = s2Weak.where((c) => s1Strong.contains(c)).length;

      final complementarity =
          (s1WeakCoveredByS2 + s2WeakCoveredByS1) /
          math.max(1, (s1Weak.length + s2Weak.length));

      // 学習速度の相似性（極端に異なる場合は低くなる）
      final s1Velocity = student1Profile['velocity'] as double? ?? 0;
      final s2Velocity = student2['velocity'] as double? ?? 0;
      final velocityDiff = (s1Velocity - s2Velocity).abs();
      const maxVelocityDiff = 10.0;
      final velocitySimilarity = math.max(0, 1 - (velocityDiff / maxVelocityDiff));

      // スコア差の考慮（20%～80%の範囲が最適）
      final s1AvgScore = student1Profile['average_score'] as double? ?? 0;
      final s2AvgScore = student2['average_score'] as double? ?? 0;
      final scoreDiff = (s1AvgScore - s2AvgScore).abs();
      const optimalDiff = 30;
      const maxDiff = 60;
      final scoreDiffPenalty = scoreDiff < optimalDiff
          ? (scoreDiff / optimalDiff)
          : math.max(0, 1 - ((scoreDiff - optimalDiff) / (maxDiff - optimalDiff)));

      // 重み付け統合
      const complementarityWeight = 0.5;
      const velocitySimilarityWeight = 0.3;
      const scoreDiffWeight = 0.2;

      final score = (complementarity * complementarityWeight) +
          (velocitySimilarity * velocitySimilarityWeight) +
          (scoreDiffPenalty * scoreDiffWeight);

      return score.clamp(0, 1);
    } catch (e) {
      debugPrint('Error calculating compatibility: $e');
      return 0;
    }
  }

  /// グループ学習が効果的なトピックを特定
  List<String> _identifyEffectiveTopics({
    required List<String> studentWeak,
    required List<String> peerStrong,
  }) {
    // 学生の弱い分野とピアの強い分野の交差
    return studentWeak
        .where((w) => peerStrong.contains(w))
        .toList();
  }

  /// セッションIDの生成
  String _generateSessionId(List<String> studentIds, String topicId) {
    final sorted = [...studentIds]..sort();
    final membersHash =
        sorted.join('_').hashCode.toString().substring(0, 8).padLeft(8, '0');
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(6);
    return 'session_${topicId}_${membersHash}_$timestamp';
  }

  /// グループセッション履歴の取得
  List<GroupLearningSession> getSessionHistory(String studentId) {
    return _sessionCache[studentId] ?? [];
  }

  /// キャッシュのクリア
  void clearCache(String studentId) {
    _matchCache.remove(studentId);
    _sessionCache.remove(studentId);
  }

  /// 全キャッシュのクリア
  void clearAllCache() {
    _matchCache.clear();
    _sessionCache.clear();
  }
}

/// 拡張メソッド: copyWith の実装（freezed が無い場合のフォールバック）
extension GroupLearningSessionCopyWith on GroupLearningSession {
  GroupLearningSession copyWith({
    String? id,
    List<String>? studentIds,
    String? topicId,
    String? topicName,
    DateTime? scheduledAt,
    DateTime? startedAt,
    DateTime? completedAt,
    int? estimatedDurationMinutes,
    List<String>? resourceUrls,
    String? outcome,
    Map<String, double>? studentScores,
  }) {
    return GroupLearningSession(
      id: id ?? this.id,
      studentIds: studentIds ?? this.studentIds,
      topicId: topicId ?? this.topicId,
      topicName: topicName ?? this.topicName,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      resourceUrls: resourceUrls ?? this.resourceUrls,
      outcome: outcome ?? this.outcome,
      studentScores: studentScores ?? this.studentScores,
    );
  }
}
