import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile_model.dart';

/// Abstract user profile service interface
abstract class UserProfileService {
  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId);

  /// Update user profile
  Future<void> updateProfile(
    String userId,
    String displayName, {
    String? bio,
    String? avatarUrl,
    ProfileVisibility? visibility,
  });

  /// Update user status
  Future<void> updateUserStatus(String userId, UserStatus status);

  /// Get user statistics
  Future<UserStats> getUserStats(String userId);

  /// Award points to user
  Future<void> awardPoints(String userId, int points, String reason);

  /// Add study minutes
  Future<void> addStudyMinutes(String userId, int minutes);

  /// Check and unlock achievements
  Future<List<UserAchievement>> checkAndUnlockAchievements(String userId);

  /// Get user achievements
  Future<List<UserAchievement>> getUserAchievements(String userId);

  /// Get achievement by ID
  Future<Achievement?> getAchievement(String achievementId);

  /// Get all available achievements
  Future<List<Achievement>> getAllAchievements();

  /// Check if user has achievement
  Future<bool> hasAchievement(String userId, String achievementId);

  /// Get user level (calculated from points)
  int calculateLevel(int totalPoints);

  /// Get level-up points threshold
  int getLevelThreshold(int level);
}

/// Firebase implementation of user profile service
class FirebaseUserProfileService implements UserProfileService {
  final FirebaseFirestore _firestore;

  // Achievement definitions (could be loaded from Firestore)
  late Map<String, Achievement> _achievementsCache;

  FirebaseUserProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> checkAndUnlockAchievements(String userId) async {
    try {
      await _initializeAchievements();

      final stats = await getUserStats(userId);
      final currentAchievements = await getUserAchievements(userId);
      final unlockedIds =
          currentAchievements.map((a) => a.achievementId).toSet();

      for (final achievement in _achievementsCache.values) {
        if (unlockedIds.contains(achievement.id)) continue;

        // Check if achievement should be unlocked
        if (_shouldUnlock(achievement, stats)) {
          await _unlockAchievement(userId, achievement);
        }
      }
    } catch (e) {
      debugPrint('Error checking achievements: $e');
    }
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('data')
          .get();

      if (!doc.exists) {
        return null;
      }

      return UserProfile.fromMap({...doc.data() as Map<String, dynamic>});
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  @override
  Future<void> updateProfile(
    String userId,
    String displayName, {
    String? bio,
    String? avatarUrl,
    ProfileVisibility? visibility,
  }) async {
    try {
      final profileRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('data');

      final current = await profileRef.get();
      final profile = current.exists
          ? UserProfile.fromMap({...current.data() as Map<String, dynamic>})
          : UserProfile.empty(userId);

      final updated = profile.copyWith(
        displayName: displayName,
        bio: bio ?? profile.bio,
        avatarUrl: avatarUrl ?? profile.avatarUrl,
        visibility: visibility ?? profile.visibility,
      );

      await profileRef.set(updated.toMap());
    } catch (e) {
      debugPrint('Error updating profile: $e');
      throw e;
    }
  }

  @override
  Future<void> updateUserStatus(String userId, UserStatus status) async {
    try {
      final profileRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('data');

      await profileRef.update({
        'status': status.index,
        'updatedAt': FieldValue.serverTimestamp(),
        'lastActivityAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating user status: $e');
    }
  }

  @override
  Future<UserStats> getUserStats(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('stats')
          .get();

      if (!doc.exists) {
        return UserStats.empty();
      }

      return UserStats.fromMap({...doc.data() as Map<String, dynamic>});
    } catch (e) {
      debugPrint('Error getting user stats: $e');
      return UserStats.empty();
    }
  }

  @override
  Future<void> awardPoints(String userId, int points, String reason) async {
    try {
      final statsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('stats');

      await statsRef.update({
        'totalPoints': FieldValue.increment(points),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Log point award
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .collection('pointHistory')
          .add({
            'points': points,
            'reason': reason,
            'awardedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error awarding points: $e');
    }
  }

  @override
  Future<void> addStudyMinutes(String userId, int minutes) async {
    try {
      final statsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('stats');

      await statsRef.update({
        'totalStudyMinutes': FieldValue.increment(minutes),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding study minutes: $e');
    }
  }

  @override
  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .collection('achievements')
          .get();

      return snapshot.docs
          .map((doc) =>
              UserAchievement.fromMap({...doc.data(), 'userId': userId}))
          .toList();
    } catch (e) {
      debugPrint('Error getting user achievements: $e');
      return [];
    }
  }

  @override
  Future<Achievement?> getAchievement(String achievementId) async {
    try {
      await _initializeAchievements();
      return _achievementsCache[achievementId];
    } catch (e) {
      debugPrint('Error getting achievement: $e');
      return null;
    }
  }

  @override
  Future<List<Achievement>> getAllAchievements() async {
    try {
      await _initializeAchievements();
      return _achievementsCache.values.toList();
    } catch (e) {
      debugPrint('Error getting all achievements: $e');
      return [];
    }
  }

  @override
  Future<bool> hasAchievement(String userId, String achievementId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .collection('achievements')
          .doc(achievementId)
          .get();

      return doc.exists;
    } catch (e) {
      debugPrint('Error checking achievement: $e');
      return false;
    }
  }

  @override
  int calculateLevel(int totalPoints) {
    // Level progression: Level 1 = 0-1000 points, Level 2 = 1000-2500, etc.
    int level = 1;
    int threshold = 1000;

    while (totalPoints >= threshold) {
      level++;
      threshold = getLevelThreshold(level);
    }

    return level;
  }

  @override
  int getLevelThreshold(int level) {
    // Points needed to reach this level
    return 1000 + ((level - 2) * 1500);
  }

  // Private helper methods

  Future<void> _initializeAchievements() async {
    if (_achievementsCache.isNotEmpty) return;

    try {
      final snapshot =
          await _firestore.collection('achievements').get();

      _achievementsCache = {
        for (final doc in snapshot.docs)
          doc.id: Achievement.fromMap({
            ...doc.data(),
            'id': doc.id,
          }),
      };
    } catch (e) {
      debugPrint('Error initializing achievements: $e');
      _achievementsCache = _getDefaultAchievements();
    }
  }

  bool _shouldUnlock(Achievement achievement, UserStats stats) {
    switch (achievement.type) {
      case AchievementType.milestone:
        // Unlock at specific point milestones
        if (achievement.id == 'first_100_points') {
          return stats.totalPoints >= 100;
        }
        if (achievement.id == 'thousand_points') {
          return stats.totalPoints >= 1000;
        }
        break;

      case AchievementType.streak:
        // Unlock at streak milestones
        if (achievement.id == 'week_streak') {
          return stats.currentStreak >= 7;
        }
        if (achievement.id == 'month_streak') {
          return stats.currentStreak >= 30;
        }
        break;

      case AchievementType.category:
        // Category mastery (implemented later)
        break;

      case AchievementType.performance:
        // Performance achievements
        if (achievement.id == 'perfect_score') {
          return stats.averageAccuracy >= 100.0;
        }
        if (achievement.id == 'high_accuracy') {
          return stats.averageAccuracy >= 90.0;
        }
        break;

      case AchievementType.social:
        // Social achievements (implemented later)
        break;
    }

    return false;
  }

  Future<void> _unlockAchievement(
      String userId, Achievement achievement) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .collection('achievements')
          .doc(achievement.id)
          .set({
            'userId': userId,
            'achievementId': achievement.id,
            'achievement': achievement.toMap(),
            'unlockedAt': FieldValue.serverTimestamp(),
          });

      // Award achievement points
      await awardPoints(userId, achievement.points,
          'Achievement: ${achievement.name}');

      // Update achievement count
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('stats')
          .update({
            'achievementsUnlocked': FieldValue.increment(1),
          });
    } catch (e) {
      debugPrint('Error unlocking achievement: $e');
    }
  }

  Map<String, Achievement> _getDefaultAchievements() {
    return {
      'first_100_points': Achievement(
        id: 'first_100_points',
        name: 'Getting Started',
        description: 'Earn 100 points',
        iconUrl: 'https://example.com/icons/started.png',
        type: AchievementType.milestone,
        points: 50,
        requirement: 'Earn 100 points',
        rarity: 1,
      ),
      'thousand_points': Achievement(
        id: 'thousand_points',
        name: 'Milestone Master',
        description: 'Reach 1000 points',
        iconUrl: 'https://example.com/icons/thousand.png',
        type: AchievementType.milestone,
        points: 200,
        requirement: 'Earn 1000 points',
        rarity: 3,
      ),
      'week_streak': Achievement(
        id: 'week_streak',
        name: 'On Fire!',
        description: 'Study for 7 consecutive days',
        iconUrl: 'https://example.com/icons/week.png',
        type: AchievementType.streak,
        points: 150,
        requirement: '7-day study streak',
        rarity: 3,
      ),
      'month_streak': Achievement(
        id: 'month_streak',
        name: 'Dedicated Scholar',
        description: 'Study for 30 consecutive days',
        iconUrl: 'https://example.com/icons/month.png',
        type: AchievementType.streak,
        points: 500,
        requirement: '30-day study streak',
        rarity: 5,
      ),
      'perfect_score': Achievement(
        id: 'perfect_score',
        name: 'Perfection',
        description: 'Achieve 100% accuracy',
        iconUrl: 'https://example.com/icons/perfect.png',
        type: AchievementType.performance,
        points: 300,
        requirement: '100% accuracy',
        rarity: 5,
      ),
      'high_accuracy': Achievement(
        id: 'high_accuracy',
        name: 'Accurate Scholar',
        description: 'Maintain 90%+ accuracy',
        iconUrl: 'https://example.com/icons/accuracy.png',
        type: AchievementType.performance,
        points: 100,
        requirement: '90%+ accuracy',
        rarity: 2,
      ),
    };
  }
}

/// Stub implementation for testing
class StubUserProfileService implements UserProfileService {
  final Map<String, UserProfile> _profiles = {};
  final Map<String, UserStats> _stats = {};
  final Map<String, List<UserAchievement>> _achievements = {};
  final Map<String, Achievement> _allAchievements = {};

  StubUserProfileService({
    Map<String, UserProfile>? profiles,
    Map<String, UserStats>? stats,
    Map<String, List<UserAchievement>>? achievements,
  }) {
    if (profiles != null) _profiles.addAll(profiles);
    if (stats != null) _stats.addAll(stats);
    if (achievements != null) _achievements.addAll(achievements);
    _initializeDefaultAchievements();
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    return _profiles[userId];
  }

  @override
  Future<void> updateProfile(
    String userId,
    String displayName, {
    String? bio,
    String? avatarUrl,
    ProfileVisibility? visibility,
  }) async {
    final profile = _profiles[userId] ?? UserProfile.empty(userId);
    _profiles[userId] = profile.copyWith(
      displayName: displayName,
      bio: bio,
      avatarUrl: avatarUrl,
      visibility: visibility,
    );
  }

  @override
  Future<void> updateUserStatus(String userId, UserStatus status) async {
    final profile = _profiles[userId] ?? UserProfile.empty(userId);
    _profiles[userId] = profile.copyWith(status: status);
  }

  @override
  Future<UserStats> getUserStats(String userId) async {
    return _stats[userId] ?? UserStats.empty();
  }

  @override
  Future<void> awardPoints(String userId, int points, String reason) async {
    final stats = _stats[userId] ?? UserStats.empty();
    _stats[userId] = stats; // Would update in real implementation
  }

  @override
  Future<void> addStudyMinutes(String userId, int minutes) async {
    final stats = _stats[userId] ?? UserStats.empty();
    _stats[userId] = stats; // Would update in real implementation
  }

  @override
  Future<List<UserAchievement>> checkAndUnlockAchievements(
      String userId) async {
    return _achievements[userId] ?? [];
  }

  @override
  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    return _achievements[userId] ?? [];
  }

  @override
  Future<Achievement?> getAchievement(String achievementId) async {
    return _allAchievements[achievementId];
  }

  @override
  Future<List<Achievement>> getAllAchievements() async {
    return _allAchievements.values.toList();
  }

  @override
  Future<bool> hasAchievement(String userId, String achievementId) async {
    final userAchievements = _achievements[userId] ?? [];
    return userAchievements.any((a) => a.achievementId == achievementId);
  }

  @override
  int calculateLevel(int totalPoints) {
    int level = 1;
    int threshold = 1000;
    while (totalPoints >= threshold) {
      level++;
      threshold = getLevelThreshold(level);
    }
    return level;
  }

  @override
  int getLevelThreshold(int level) {
    return 1000 + ((level - 2) * 1500);
  }

  void _initializeDefaultAchievements() {
    _allAchievements.addAll({
      'first_100_points': Achievement(
        id: 'first_100_points',
        name: 'Getting Started',
        description: 'Earn 100 points',
        iconUrl: '',
        type: AchievementType.milestone,
        points: 50,
      ),
      'thousand_points': Achievement(
        id: 'thousand_points',
        name: 'Milestone Master',
        description: 'Reach 1000 points',
        iconUrl: '',
        type: AchievementType.milestone,
        points: 200,
      ),
    });
  }
}
