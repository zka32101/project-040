import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile visibility settings
enum ProfileVisibility { public, friends, private }

/// User profile status
enum UserStatus { active, inactive, studying }

/// Represents a user's public profile
class UserProfile {
  final String userId;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final int totalPoints;
  final int totalStudyMinutes;
  final int questionsAnswered;
  final double averageAccuracy;
  final int level;
  final ProfileVisibility visibility;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActivityAt;

  UserProfile({
    required this.userId,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    required this.totalPoints,
    required this.totalStudyMinutes,
    required this.questionsAnswered,
    required this.averageAccuracy,
    required this.level,
    required this.visibility,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastActivityAt,
  });

  bool get isPublic => visibility == ProfileVisibility.public;
  bool get isStudying => status == UserStatus.studying;

  factory UserProfile.empty(String userId) {
    final now = DateTime.now();
    return UserProfile(
      userId: userId,
      displayName: 'User',
      totalPoints: 0,
      totalStudyMinutes: 0,
      questionsAnswered: 0,
      averageAccuracy: 0.0,
      level: 1,
      visibility: ProfileVisibility.private,
      status: UserStatus.inactive,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'User',
      bio: map['bio'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      totalPoints: map['totalPoints'] as int? ?? 0,
      totalStudyMinutes: map['totalStudyMinutes'] as int? ?? 0,
      questionsAnswered: map['questionsAnswered'] as int? ?? 0,
      averageAccuracy: (map['averageAccuracy'] as num?)?.toDouble() ?? 0.0,
      level: map['level'] as int? ?? 1,
      visibility: ProfileVisibility
          .values[(map['visibility'] as int?) ?? ProfileVisibility.private.index],
      status: UserStatus.values[(map['status'] as int?) ?? UserStatus.inactive.index],
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActivityAt: (map['lastActivityAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'totalPoints': totalPoints,
      'totalStudyMinutes': totalStudyMinutes,
      'questionsAnswered': questionsAnswered,
      'averageAccuracy': averageAccuracy,
      'level': level,
      'visibility': visibility.index,
      'status': status.index,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastActivityAt':
          lastActivityAt != null ? Timestamp.fromDate(lastActivityAt!) : null,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? bio,
    String? avatarUrl,
    int? totalPoints,
    int? totalStudyMinutes,
    int? questionsAnswered,
    double? averageAccuracy,
    int? level,
    ProfileVisibility? visibility,
    UserStatus? status,
    DateTime? lastActivityAt,
  }) {
    return UserProfile(
      userId: userId,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      averageAccuracy: averageAccuracy ?? this.averageAccuracy,
      level: level ?? this.level,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }
}

/// Achievement/Badge types
enum AchievementType {
  milestone, // Reaching score milestones
  streak, // Study streaks
  category, // Category mastery
  performance, // Performance achievements
  social, // Social milestones
}

/// Represents an achievement/badge
class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final AchievementType type;
  final int points;
  final String? requirement; // Description of how to earn
  final int? rarity; // 1-5 rarity level

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.type,
    required this.points,
    this.requirement,
    this.rarity,
  });

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      iconUrl: map['iconUrl'] as String? ?? '',
      type: AchievementType
          .values[(map['type'] as int?) ?? AchievementType.milestone.index],
      points: map['points'] as int? ?? 0,
      requirement: map['requirement'] as String?,
      rarity: map['rarity'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'type': type.index,
      'points': points,
      'requirement': requirement,
      'rarity': rarity,
    };
  }
}

/// User's earned achievement
class UserAchievement {
  final String userId;
  final String achievementId;
  final Achievement achievement;
  final DateTime unlockedAt;
  final DateTime? firstNotifiedAt;

  UserAchievement({
    required this.userId,
    required this.achievementId,
    required this.achievement,
    required this.unlockedAt,
    this.firstNotifiedAt,
  });

  factory UserAchievement.fromMap(Map<String, dynamic> map) {
    return UserAchievement(
      userId: map['userId'] as String? ?? '',
      achievementId: map['achievementId'] as String? ?? '',
      achievement: Achievement.fromMap(
          map['achievement'] as Map<String, dynamic>? ?? {}),
      unlockedAt:
          (map['unlockedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      firstNotifiedAt: (map['firstNotifiedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'achievementId': achievementId,
      'achievement': achievement.toMap(),
      'unlockedAt': Timestamp.fromDate(unlockedAt),
      'firstNotifiedAt': firstNotifiedAt != null
          ? Timestamp.fromDate(firstNotifiedAt!)
          : null,
    };
  }
}

/// User statistics for display
class UserStats {
  final int totalPoints;
  final int totalStudyMinutes;
  final int questionsAnswered;
  final int correctAnswers;
  final double averageAccuracy;
  final int currentStreak;
  final int longestStreak;
  final int level;
  final int nextLevelPoints;
  final int achievementsUnlocked;

  UserStats({
    required this.totalPoints,
    required this.totalStudyMinutes,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.averageAccuracy,
    required this.currentStreak,
    required this.longestStreak,
    required this.level,
    required this.nextLevelPoints,
    required this.achievementsUnlocked,
  });

  int get pointsToNextLevel => nextLevelPoints - totalPoints;
  double get levelProgress => (totalPoints % nextLevelPoints) / nextLevelPoints;
  int get minutesToNextHour => (60 - (totalStudyMinutes % 60));

  factory UserStats.empty() {
    return UserStats(
      totalPoints: 0,
      totalStudyMinutes: 0,
      questionsAnswered: 0,
      correctAnswers: 0,
      averageAccuracy: 0.0,
      currentStreak: 0,
      longestStreak: 0,
      level: 1,
      nextLevelPoints: 1000,
      achievementsUnlocked: 0,
    );
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      totalPoints: map['totalPoints'] as int? ?? 0,
      totalStudyMinutes: map['totalStudyMinutes'] as int? ?? 0,
      questionsAnswered: map['questionsAnswered'] as int? ?? 0,
      correctAnswers: map['correctAnswers'] as int? ?? 0,
      averageAccuracy: (map['averageAccuracy'] as num?)?.toDouble() ?? 0.0,
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      nextLevelPoints: map['nextLevelPoints'] as int? ?? 1000,
      achievementsUnlocked: map['achievementsUnlocked'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalPoints': totalPoints,
      'totalStudyMinutes': totalStudyMinutes,
      'questionsAnswered': questionsAnswered,
      'correctAnswers': correctAnswers,
      'averageAccuracy': averageAccuracy,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'level': level,
      'nextLevelPoints': nextLevelPoints,
      'achievementsUnlocked': achievementsUnlocked,
    };
  }
}
