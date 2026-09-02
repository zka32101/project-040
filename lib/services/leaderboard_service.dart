import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/leaderboard_model.dart';
import '../models/user_profile_model.dart';

/// Abstract leaderboard service interface
abstract class LeaderboardService {
  /// Get top players globally
  Future<List<LeaderboardEntry>> getGlobalLeaderboard({
    int limit = 100,
    RankingPeriod period = RankingPeriod.allTime,
  });

  /// Get leaderboard for specific category
  Future<List<LeaderboardEntry>> getCategoryLeaderboard(
    String categoryId, {
    int limit = 100,
    RankingPeriod period = RankingPeriod.allTime,
  });

  /// Get friends leaderboard
  Future<List<LeaderboardEntry>> getFriendsLeaderboard(
    String userId, {
    int limit = 100,
  });

  /// Get top players by accuracy
  Future<List<LeaderboardEntry>> getAccuracyLeaderboard({
    int limit = 100,
    RankingPeriod period = RankingPeriod.allTime,
  });

  /// Get user's rank in global leaderboard
  Future<int> getUserGlobalRank(String userId);

  /// Get user's rank in category leaderboard
  Future<int> getUserCategoryRank(String userId, String categoryId);

  /// Get all user rankings
  Future<UserRankings> getUserRankings(String userId);

  /// Get leaderboard around user (user + nearby ranks)
  Future<List<LeaderboardEntry>> getLeaderboardAroundUser(
    String userId, {
    int contextSize = 5,
    RankingPeriod period = RankingPeriod.allTime,
  });

  /// Update user's leaderboard position
  Future<void> updateUserLeaderboardPosition(
    String userId,
    String displayName,
    String? avatarUrl,
    int totalPoints,
    double averageAccuracy,
    int currentStreak,
    int level,
    int questionsAnswered,
    int totalStudyMinutes,
    int achievementsUnlocked,
  );

  /// Recalculate all rankings (batch operation)
  Future<void> recalculateLeaderboards();

  /// Get leaderboard statistics
  Future<LeaderboardStats> getLeaderboardStats(
    LeaderboardType type, {
    RankingPeriod period = RankingPeriod.allTime,
    String? categoryId,
  });

  /// Get rank changes for user
  Future<List<RankChange>> getUserRankChanges(String userId, {int limit = 30});

  /// Check if user is in top rank
  Future<bool> isUserInTopRank(String userId, {int topN = 10});
}

/// Firebase implementation of leaderboard service
class FirebaseLeaderboardService implements LeaderboardService {
  final FirebaseFirestore _firestore;

  FirebaseLeaderboardService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<LeaderboardEntry>> getGlobalLeaderboard({
    int limit = 100,
    RankingPeriod period = RankingPeriod.allTime,
  }) async {
    try {
      final collectionPath = _getLeaderboardPath(
        LeaderboardType.global,
        period,
      );

      final snapshot = await _firestore
          .collection(collectionPath)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LeaderboardEntry.fromMap({
                ...doc.data(),
                'userId': doc.id,
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting global leaderboard: $e');
      return [];
    }
  }

  @override
  Future<List<LeaderboardEntry>> getCategoryLeaderboard(
    String categoryId, {
    int limit = 100,
    RankingPeriod period = RankingPeriod.allTime,
  }) async {
    try {
      final collectionPath = _getLeaderboardPath(
        LeaderboardType.category,
        period,
        categoryId,
      );

      final snapshot = await _firestore
          .collection(collectionPath)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LeaderboardEntry.fromMap({
                ...doc.data(),
                'userId': doc.id,
                'categoryId': categoryId,
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting category leaderboard: $e');
      return [];
    }
  }

  @override
  Future<List<LeaderboardEntry>> getFriendsLeaderboard(
    String userId, {
    int limit = 100,
  }) async {
    try {
      // Get user's friends list
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final friends = (userDoc.data()?['friends'] as List?)?.cast<String>() ?? [];

      if (friends.isEmpty) {
        return [];
      }

      final snapshot = await _firestore
          .collection('leaderboards/global/allTime')
          .where('userId', whereIn: [...friends, userId])
          .orderBy('totalPoints', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LeaderboardEntry.fromMap({
                ...doc.data(),
                'userId': doc.id,
                'type': LeaderboardType.friends.index,
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting friends leaderboard: $e');
      return [];
    }
  }

  @override
  Future<List<LeaderboardEntry>> getAccuracyLeaderboard({
    int limit = 100,
    RankingPeriod period = RankingPeriod.allTime,
  }) async {
    try {
      final collectionPath = _getLeaderboardPath(
        LeaderboardType.global,
        period,
      );

      final snapshot = await _firestore
          .collection(collectionPath)
          .orderBy('averageAccuracy', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LeaderboardEntry.fromMap({
                ...doc.data(),
                'userId': doc.id,
                'sortBy': RankingSortBy.accuracy.index,
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting accuracy leaderboard: $e');
      return [];
    }
  }

  @override
  Future<int> getUserGlobalRank(String userId) async {
    try {
      final doc = await _firestore
          .collection('rankings')
          .doc(userId)
          .get();

      if (!doc.exists) {
        return 0;
      }

      final rankings = UserRankings.fromMap({...doc.data() as Map<String, dynamic>});
      return rankings.globalRankAllTime;
    } catch (e) {
      debugPrint('Error getting user global rank: $e');
      return 0;
    }
  }

  @override
  Future<int> getUserCategoryRank(String userId, String categoryId) async {
    try {
      final doc = await _firestore
          .collection('rankings')
          .doc(userId)
          .get();

      if (!doc.exists) {
        return 0;
      }

      final rankings = UserRankings.fromMap({...doc.data() as Map<String, dynamic>});
      return rankings.categoryRanks[categoryId] ?? 0;
    } catch (e) {
      debugPrint('Error getting user category rank: $e');
      return 0;
    }
  }

  @override
  Future<UserRankings> getUserRankings(String userId) async {
    try {
      final doc = await _firestore
          .collection('rankings')
          .doc(userId)
          .get();

      if (!doc.exists) {
        return UserRankings.empty(userId);
      }

      return UserRankings.fromMap({
        ...doc.data() as Map<String, dynamic>,
        'userId': userId,
      });
    } catch (e) {
      debugPrint('Error getting user rankings: $e');
      return UserRankings.empty(userId);
    }
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboardAroundUser(
    String userId, {
    int contextSize = 5,
    RankingPeriod period = RankingPeriod.allTime,
  }) async {
    try {
      final userRank = await getUserGlobalRank(userId);

      if (userRank == 0) {
        return [];
      }

      final startRank = (userRank - contextSize).clamp(1, userRank);
      final endRank = userRank + contextSize;

      final collectionPath = _getLeaderboardPath(
        LeaderboardType.global,
        period,
      );

      final snapshot = await _firestore
          .collection(collectionPath)
          .where('rank', isGreaterThanOrEqualTo: startRank)
          .where('rank', isLessThanOrEqualTo: endRank)
          .get();

      final entries = snapshot.docs
          .map((doc) => LeaderboardEntry.fromMap({
                ...doc.data(),
                'userId': doc.id,
              }))
          .toList();

      entries.sort((a, b) => a.rank.compareTo(b.rank));
      return entries;
    } catch (e) {
      debugPrint('Error getting leaderboard around user: $e');
      return [];
    }
  }

  @override
  Future<void> updateUserLeaderboardPosition(
    String userId,
    String displayName,
    String? avatarUrl,
    int totalPoints,
    double averageAccuracy,
    int currentStreak,
    int level,
    int questionsAnswered,
    int totalStudyMinutes,
    int achievementsUnlocked,
  ) async {
    try {
      // Update all-time leaderboard
      await _firestore
          .collection('leaderboards/global/allTime')
          .doc(userId)
          .set({
            'userId': userId,
            'displayName': displayName,
            'avatarUrl': avatarUrl,
            'totalPoints': totalPoints,
            'averageAccuracy': averageAccuracy,
            'currentStreak': currentStreak,
            'level': level,
            'questionsAnswered': questionsAnswered,
            'totalStudyMinutes': totalStudyMinutes,
            'achievementsUnlocked': achievementsUnlocked,
            'updatedAt': FieldValue.serverTimestamp(),
            'type': LeaderboardType.global.index,
            'period': RankingPeriod.allTime.index,
          });

      // Also update weekly
      await _firestore
          .collection('leaderboards/global/weekly')
          .doc(userId)
          .set({
            'userId': userId,
            'displayName': displayName,
            'avatarUrl': avatarUrl,
            'totalPoints': totalPoints,
            'averageAccuracy': averageAccuracy,
            'currentStreak': currentStreak,
            'level': level,
            'questionsAnswered': questionsAnswered,
            'totalStudyMinutes': totalStudyMinutes,
            'achievementsUnlocked': achievementsUnlocked,
            'updatedAt': FieldValue.serverTimestamp(),
            'type': LeaderboardType.global.index,
            'period': RankingPeriod.weekly.index,
          });
    } catch (e) {
      debugPrint('Error updating leaderboard position: $e');
    }
  }

  @override
  Future<void> recalculateLeaderboards() async {
    try {
      // This would typically be a Cloud Function operation
      // For now, log that it's needed
      debugPrint('Leaderboard recalculation triggered');
    } catch (e) {
      debugPrint('Error recalculating leaderboards: $e');
    }
  }

  @override
  Future<LeaderboardStats> getLeaderboardStats(
    LeaderboardType type, {
    RankingPeriod period = RankingPeriod.allTime,
    String? categoryId,
  }) async {
    try {
      final collectionPath = _getLeaderboardPath(type, period, categoryId);

      final snapshot = await _firestore
          .collection(collectionPath)
          .get();

      if (snapshot.docs.isEmpty) {
        return LeaderboardStats.empty();
      }

      final entries = snapshot.docs
          .map((doc) => LeaderboardEntry.fromMap({...doc.data(), 'userId': doc.id}))
          .toList();

      final totalPlayers = entries.length;
      final topTen = entries.take(10).toList();
      final topTenMedianPoints = topTen.isNotEmpty
          ? topTen[(topTen.length ~/ 2)].totalPoints
          : 0;
      final averagePoints = totalPlayers > 0
          ? entries.fold(0, (sum, e) => sum + e.totalPoints) / totalPlayers
          : 0.0;
      final medianLevel = totalPlayers > 0
          ? entries[(totalPlayers ~/ 2)].level
          : 1;
      final averageAccuracy = totalPlayers > 0
          ? entries.fold(0.0, (sum, e) => sum + e.averageAccuracy) / totalPlayers
          : 0.0;

      return LeaderboardStats(
        totalPlayers: totalPlayers,
        topTenMedianPoints: topTenMedianPoints,
        averagePoints: averagePoints,
        medianLevel: medianLevel,
        averageAccuracy: averageAccuracy,
        calculatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting leaderboard stats: $e');
      return LeaderboardStats.empty();
    }
  }

  @override
  Future<List<RankChange>> getUserRankChanges(
    String userId, {
    int limit = 30,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('rankHistory')
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => RankChange.fromMap({...doc.data()}))
          .toList();
    } catch (e) {
      debugPrint('Error getting rank changes: $e');
      return [];
    }
  }

  @override
  Future<bool> isUserInTopRank(
    String userId, {
    int topN = 10,
  }) async {
    try {
      final rank = await getUserGlobalRank(userId);
      return rank > 0 && rank <= topN;
    } catch (e) {
      debugPrint('Error checking top rank: $e');
      return false;
    }
  }

  // Private helper methods

  String _getLeaderboardPath(
    LeaderboardType type,
    RankingPeriod period, [
    String? categoryId,
  ]) {
    switch (type) {
      case LeaderboardType.global:
        final period_ = period == RankingPeriod.weekly ? 'weekly' : 'allTime';
        return 'leaderboards/global/$period_';
      case LeaderboardType.category:
        final period_ = period == RankingPeriod.weekly ? 'weekly' : 'allTime';
        return 'leaderboards/categories/${categoryId ?? 'default'}/$period_';
      case LeaderboardType.friends:
        return 'leaderboards/friends/allTime';
      case LeaderboardType.weekly:
        return 'leaderboards/global/weekly';
      case LeaderboardType.monthly:
        return 'leaderboards/global/monthly';
    }
  }
}

/// Stub implementation for testing
class StubLeaderboardService implements LeaderboardService {
  final Map<String, LeaderboardEntry> _globalLeaderboard = {};
  final Map<String, Map<String, LeaderboardEntry>> _categoryLeaderboards = {};
  final Map<String, UserRankings> _rankings = {};
  final Map<String, List<RankChange>> _rankHistory = {};

  StubLeaderboardService({
    Map<String, LeaderboardEntry>? globalLeaderboard,
    Map<String, Map<String, LeaderboardEntry>>? categoryLeaderboards,
  }) {
    if (globalLeaderboard != null) _globalLeaderboard.addAll(globalLeaderboard);
    if (categoryLeaderboards != null) {
      _categoryLeaderboards.addAll(categoryLeaderboards);
    }
    _initializeDefaultLeaderboard();
  }

  @override
  Future<List<LeaderboardEntry>> getGlobalLeaderboard({
    int limit = 100,
    RankingPeriod period = RankingPeriod.allTime,
  }) async {
    final entries = _globalLeaderboard.values.toList();
    entries.sort((a, b) => a.rank.compareTo(b.rank));
    return entries.take(limit).toList();
  }

  @override
  Future<List<LeaderboardEntry>> getCategoryLeaderboard(
    String categoryId, {
    int limit = 100,
    RankingPeriod period = RankingPeriod.allTime,
  }) async {
    final entries = _categoryLeaderboards[categoryId]?.values.toList() ?? [];
    entries.sort((a, b) => a.rank.compareTo(b.rank));
    return entries.take(limit).toList();
  }

  @override
  Future<List<LeaderboardEntry>> getFriendsLeaderboard(
    String userId, {
    int limit = 100,
  }) async {
    return getGlobalLeaderboard(limit: limit);
  }

  @override
  Future<List<LeaderboardEntry>> getAccuracyLeaderboard({
    int limit = 100,
    RankingPeriod period = RankingPeriod.allTime,
  }) async {
    final entries = _globalLeaderboard.values.toList();
    entries.sort((a, b) => b.averageAccuracy.compareTo(a.averageAccuracy));
    return entries.take(limit).toList();
  }

  @override
  Future<int> getUserGlobalRank(String userId) async {
    final rankings = _rankings[userId];
    return rankings?.globalRankAllTime ?? 0;
  }

  @override
  Future<int> getUserCategoryRank(String userId, String categoryId) async {
    final rankings = _rankings[userId];
    return rankings?.categoryRanks[categoryId] ?? 0;
  }

  @override
  Future<UserRankings> getUserRankings(String userId) async {
    return _rankings[userId] ?? UserRankings.empty(userId);
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboardAroundUser(
    String userId, {
    int contextSize = 5,
    RankingPeriod period = RankingPeriod.allTime,
  }) async {
    final userRank = await getUserGlobalRank(userId);
    if (userRank == 0) return [];

    final allEntries = await getGlobalLeaderboard();
    final startIdx = (userRank - contextSize - 1).clamp(0, allEntries.length - 1);
    final endIdx = (userRank + contextSize).clamp(0, allEntries.length);

    return allEntries.sublist(startIdx, endIdx);
  }

  @override
  Future<void> updateUserLeaderboardPosition(
    String userId,
    String displayName,
    String? avatarUrl,
    int totalPoints,
    double averageAccuracy,
    int currentStreak,
    int level,
    int questionsAnswered,
    int totalStudyMinutes,
    int achievementsUnlocked,
  ) async {
    final entries = _globalLeaderboard.values.toList();
    entries.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    final newEntry = LeaderboardEntry(
      userId: userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
      rank: entries.length + 1,
      totalPoints: totalPoints,
      averageAccuracy: averageAccuracy,
      currentStreak: currentStreak,
      level: level,
      questionsAnswered: questionsAnswered,
      totalStudyMinutes: totalStudyMinutes,
      achievementsUnlocked: achievementsUnlocked,
      updatedAt: DateTime.now(),
      type: LeaderboardType.global,
      period: RankingPeriod.allTime,
    );

    _globalLeaderboard[userId] = newEntry;

    _rankings[userId] = UserRankings(
      userId: userId,
      globalRank: newEntry.rank,
      globalRankAllTime: newEntry.rank,
      globalRankWeekly: newEntry.rank,
      globalRankMonthly: newEntry.rank,
      categoryRanks: {},
      friendsRank: newEntry.rank,
      totalPlayersGlobal: _globalLeaderboard.length,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> recalculateLeaderboards() async {
    // Recalculate ranks
    final entries = _globalLeaderboard.values.toList();
    entries.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    for (int i = 0; i < entries.length; i++) {
      final updated = entries[i].copyWith(rank: i + 1);
      _globalLeaderboard[entries[i].userId] = updated;
    }
  }

  @override
  Future<LeaderboardStats> getLeaderboardStats(
    LeaderboardType type, {
    RankingPeriod period = RankingPeriod.allTime,
    String? categoryId,
  }) async {
    final entries = _globalLeaderboard.values.toList();
    if (entries.isEmpty) return LeaderboardStats.empty();

    final totalPlayers = entries.length;
    final topTen = entries.take(10).toList();
    final topTenMedianPoints = topTen.isNotEmpty
        ? topTen[(topTen.length ~/ 2)].totalPoints
        : 0;
    final averagePoints = entries.fold(0, (sum, e) => sum + e.totalPoints) / totalPlayers;
    final medianLevel = entries[(totalPlayers ~/ 2)].level;
    final averageAccuracy = entries.fold(0.0, (sum, e) => sum + e.averageAccuracy) / totalPlayers;

    return LeaderboardStats(
      totalPlayers: totalPlayers,
      topTenMedianPoints: topTenMedianPoints,
      averagePoints: averagePoints,
      medianLevel: medianLevel,
      averageAccuracy: averageAccuracy,
      calculatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<RankChange>> getUserRankChanges(
    String userId, {
    int limit = 30,
  }) async {
    return _rankHistory[userId]?.take(limit).toList() ?? [];
  }

  @override
  Future<bool> isUserInTopRank(
    String userId, {
    int topN = 10,
  }) async {
    final rank = await getUserGlobalRank(userId);
    return rank > 0 && rank <= topN;
  }

  void _initializeDefaultLeaderboard() {
    final defaultEntries = [
      LeaderboardEntry(
        userId: 'user_1',
        displayName: 'TopPlayer',
        rank: 1,
        totalPoints: 5000,
        averageAccuracy: 95.0,
        currentStreak: 30,
        level: 10,
        questionsAnswered: 500,
        totalStudyMinutes: 300,
        achievementsUnlocked: 8,
        updatedAt: DateTime.now(),
        type: LeaderboardType.global,
        period: RankingPeriod.allTime,
      ),
      LeaderboardEntry(
        userId: 'user_2',
        displayName: 'SecondBest',
        rank: 2,
        totalPoints: 4500,
        averageAccuracy: 92.0,
        currentStreak: 25,
        level: 9,
        questionsAnswered: 450,
        totalStudyMinutes: 280,
        achievementsUnlocked: 7,
        updatedAt: DateTime.now(),
        type: LeaderboardType.global,
        period: RankingPeriod.allTime,
      ),
    ];

    for (final entry in defaultEntries) {
      _globalLeaderboard[entry.userId] = entry;
      _rankings[entry.userId] = UserRankings(
        userId: entry.userId,
        globalRank: entry.rank,
        globalRankAllTime: entry.rank,
        globalRankWeekly: entry.rank,
        globalRankMonthly: entry.rank,
        categoryRanks: {},
        friendsRank: entry.rank,
        totalPlayersGlobal: defaultEntries.length,
        updatedAt: DateTime.now(),
      );
    }
  }
}
