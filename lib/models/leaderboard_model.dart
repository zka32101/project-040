import 'package:cloud_firestore/cloud_firestore.dart';

/// Leaderboard types
enum LeaderboardType { global, category, friends, weekly, monthly }

/// Ranking period
enum RankingPeriod { allTime, weekly, monthly }

/// Ranking sort criteria
enum RankingSortBy { points, accuracy, streak, studyTime, achievement }

/// Represents a user's rank on a leaderboard
class LeaderboardEntry {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int rank;
  final int totalPoints;
  final double averageAccuracy;
  final int currentStreak;
  final int level;
  final int questionsAnswered;
  final int totalStudyMinutes;
  final int achievementsUnlocked;
  final DateTime updatedAt;
  final LeaderboardType type;
  final RankingPeriod period;
  final String? categoryId; // For category leaderboards

  LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.rank,
    required this.totalPoints,
    required this.averageAccuracy,
    required this.currentStreak,
    required this.level,
    required this.questionsAnswered,
    required this.totalStudyMinutes,
    required this.achievementsUnlocked,
    required this.updatedAt,
    required this.type,
    required this.period,
    this.categoryId,
  });

  // Getters
  bool get isTopTen => rank <= 10;
  bool get isTopHundred => rank <= 100;
  bool get isTopThousand => rank <= 1000;

  factory LeaderboardEntry.empty() {
    final now = DateTime.now();
    return LeaderboardEntry(
      userId: '',
      displayName: '',
      rank: 0,
      totalPoints: 0,
      averageAccuracy: 0.0,
      currentStreak: 0,
      level: 1,
      questionsAnswered: 0,
      totalStudyMinutes: 0,
      achievementsUnlocked: 0,
      updatedAt: now,
      type: LeaderboardType.global,
      period: RankingPeriod.allTime,
    );
  }

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: map['userId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'User',
      avatarUrl: map['avatarUrl'] as String?,
      rank: map['rank'] as int? ?? 0,
      totalPoints: map['totalPoints'] as int? ?? 0,
      averageAccuracy: (map['averageAccuracy'] as num?)?.toDouble() ?? 0.0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      questionsAnswered: map['questionsAnswered'] as int? ?? 0,
      totalStudyMinutes: map['totalStudyMinutes'] as int? ?? 0,
      achievementsUnlocked: map['achievementsUnlocked'] as int? ?? 0,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: LeaderboardType.values[
          (map['type'] as int?) ?? LeaderboardType.global.index],
      period: RankingPeriod.values[
          (map['period'] as int?) ?? RankingPeriod.allTime.index],
      categoryId: map['categoryId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'rank': rank,
      'totalPoints': totalPoints,
      'averageAccuracy': averageAccuracy,
      'currentStreak': currentStreak,
      'level': level,
      'questionsAnswered': questionsAnswered,
      'totalStudyMinutes': totalStudyMinutes,
      'achievementsUnlocked': achievementsUnlocked,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'type': type.index,
      'period': period.index,
      'categoryId': categoryId,
    };
  }

  LeaderboardEntry copyWith({
    String? userId,
    String? displayName,
    String? avatarUrl,
    int? rank,
    int? totalPoints,
    double? averageAccuracy,
    int? currentStreak,
    int? level,
    int? questionsAnswered,
    int? totalStudyMinutes,
    int? achievementsUnlocked,
    DateTime? updatedAt,
    LeaderboardType? type,
    RankingPeriod? period,
    String? categoryId,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rank: rank ?? this.rank,
      totalPoints: totalPoints ?? this.totalPoints,
      averageAccuracy: averageAccuracy ?? this.averageAccuracy,
      currentStreak: currentStreak ?? this.currentStreak,
      level: level ?? this.level,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
      achievementsUnlocked: achievementsUnlocked ?? this.achievementsUnlocked,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      period: period ?? this.period,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

/// Represents rank change over time
class RankChange {
  final String userId;
  final int previousRank;
  final int currentRank;
  final int pointsGained;
  final DateTime updatedAt;

  RankChange({
    required this.userId,
    required this.previousRank,
    required this.currentRank,
    required this.pointsGained,
    required this.updatedAt,
  });

  int get rankImprovement => previousRank - currentRank;
  bool get rankImproved => rankImprovement > 0;

  factory RankChange.fromMap(Map<String, dynamic> map) {
    return RankChange(
      userId: map['userId'] as String? ?? '',
      previousRank: map['previousRank'] as int? ?? 0,
      currentRank: map['currentRank'] as int? ?? 0,
      pointsGained: map['pointsGained'] as int? ?? 0,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'previousRank': previousRank,
      'currentRank': currentRank,
      'pointsGained': pointsGained,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// User's position in multiple leaderboards
class UserRankings {
  final String userId;
  final int globalRank;
  final int globalRankAllTime;
  final int globalRankWeekly;
  final int globalRankMonthly;
  final Map<String, int> categoryRanks; // categoryId -> rank
  final int friendsRank;
  final int totalPlayersGlobal;
  final DateTime updatedAt;

  UserRankings({
    required this.userId,
    required this.globalRank,
    required this.globalRankAllTime,
    required this.globalRankWeekly,
    required this.globalRankMonthly,
    required this.categoryRanks,
    required this.friendsRank,
    required this.totalPlayersGlobal,
    required this.updatedAt,
  });

  factory UserRankings.empty(String userId) {
    return UserRankings(
      userId: userId,
      globalRank: 0,
      globalRankAllTime: 0,
      globalRankWeekly: 0,
      globalRankMonthly: 0,
      categoryRanks: {},
      friendsRank: 0,
      totalPlayersGlobal: 0,
      updatedAt: DateTime.now(),
    );
  }

  factory UserRankings.fromMap(Map<String, dynamic> map) {
    return UserRankings(
      userId: map['userId'] as String? ?? '',
      globalRank: map['globalRank'] as int? ?? 0,
      globalRankAllTime: map['globalRankAllTime'] as int? ?? 0,
      globalRankWeekly: map['globalRankWeekly'] as int? ?? 0,
      globalRankMonthly: map['globalRankMonthly'] as int? ?? 0,
      categoryRanks:
          Map<String, int>.from(map['categoryRanks'] as Map? ?? {}),
      friendsRank: map['friendsRank'] as int? ?? 0,
      totalPlayersGlobal: map['totalPlayersGlobal'] as int? ?? 0,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'globalRank': globalRank,
      'globalRankAllTime': globalRankAllTime,
      'globalRankWeekly': globalRankWeekly,
      'globalRankMonthly': globalRankMonthly,
      'categoryRanks': categoryRanks,
      'friendsRank': friendsRank,
      'totalPlayersGlobal': totalPlayersGlobal,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// Leaderboard configuration
class LeaderboardConfig {
  final LeaderboardType type;
  final RankingPeriod period;
  final RankingSortBy sortBy;
  final int maxEntries;
  final bool includePrivateProfiles;
  final String? categoryId;

  LeaderboardConfig({
    required this.type,
    required this.period,
    required this.sortBy,
    this.maxEntries = 100,
    this.includePrivateProfiles = false,
    this.categoryId,
  });

  factory LeaderboardConfig.globalAllTime() {
    return LeaderboardConfig(
      type: LeaderboardType.global,
      period: RankingPeriod.allTime,
      sortBy: RankingSortBy.points,
    );
  }

  factory LeaderboardConfig.globalWeekly() {
    return LeaderboardConfig(
      type: LeaderboardType.global,
      period: RankingPeriod.weekly,
      sortBy: RankingSortBy.points,
    );
  }

  factory LeaderboardConfig.accuracy() {
    return LeaderboardConfig(
      type: LeaderboardType.global,
      period: RankingPeriod.allTime,
      sortBy: RankingSortBy.accuracy,
    );
  }
}

/// Leaderboard statistics
class LeaderboardStats {
  final int totalPlayers;
  final int topTenMedianPoints;
  final double averagePoints;
  final int medianLevel;
  final double averageAccuracy;
  final DateTime calculatedAt;

  LeaderboardStats({
    required this.totalPlayers,
    required this.topTenMedianPoints,
    required this.averagePoints,
    required this.medianLevel,
    required this.averageAccuracy,
    required this.calculatedAt,
  });

  factory LeaderboardStats.empty() {
    return LeaderboardStats(
      totalPlayers: 0,
      topTenMedianPoints: 0,
      averagePoints: 0.0,
      medianLevel: 1,
      averageAccuracy: 0.0,
      calculatedAt: DateTime.now(),
    );
  }

  factory LeaderboardStats.fromMap(Map<String, dynamic> map) {
    return LeaderboardStats(
      totalPlayers: map['totalPlayers'] as int? ?? 0,
      topTenMedianPoints: map['topTenMedianPoints'] as int? ?? 0,
      averagePoints: (map['averagePoints'] as num?)?.toDouble() ?? 0.0,
      medianLevel: map['medianLevel'] as int? ?? 1,
      averageAccuracy: (map['averageAccuracy'] as num?)?.toDouble() ?? 0.0,
      calculatedAt:
          (map['calculatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalPlayers': totalPlayers,
      'topTenMedianPoints': topTenMedianPoints,
      'averagePoints': averagePoints,
      'medianLevel': medianLevel,
      'averageAccuracy': averageAccuracy,
      'calculatedAt': Timestamp.fromDate(calculatedAt),
    };
  }
}
