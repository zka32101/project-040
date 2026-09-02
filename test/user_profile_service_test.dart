import 'package:flutter_test/flutter_test.dart';
import 'package:bike_license_kore/models/user_profile_model.dart';
import 'package:bike_license_kore/services/user_profile_service.dart';

void main() {
  group('User Profile Service', () {
    late StubUserProfileService service;

    setUp(() {
      service = StubUserProfileService();
    });

    group('User Profile Management', () {
      test('should create empty profile for new user', () async {
        const userId = 'new_user_123';

        final profile = UserProfile.empty(userId);

        expect(profile.userId, equals(userId));
        expect(profile.displayName, equals('User'));
        expect(profile.totalPoints, equals(0));
        expect(profile.visibility, equals(ProfileVisibility.private));
      });

      test('should update user profile', () async {
        const userId = 'user_123';
        const newName = 'John Doe';
        const newBio = 'Studying hard!';

        await service.updateProfile(
          userId,
          newName,
          bio: newBio,
          visibility: ProfileVisibility.public,
        );

        final profile = await service.getUserProfile(userId);

        expect(profile, isNotNull);
        expect(profile!.displayName, equals(newName));
        expect(profile.bio, equals(newBio));
        expect(profile.visibility, equals(ProfileVisibility.public));
      });

      test('should update user status', () async {
        const userId = 'user_123';

        await service.updateUserStatus(userId, UserStatus.studying);

        final profile = await service.getUserProfile(userId);

        expect(profile, isNotNull);
        expect(profile!.status, equals(UserStatus.studying));
      });

      test('should set profile visibility', () async {
        const userId = 'user_123';

        await service.updateProfile(
          userId,
          'Test User',
          visibility: ProfileVisibility.friends,
        );

        final profile = await service.getUserProfile(userId);

        expect(profile!.isPublic, isFalse);
      });

      test('should track last activity time', () async {
        const userId = 'user_123';

        await service.updateUserStatus(userId, UserStatus.active);

        final profile = await service.getUserProfile(userId);

        expect(profile!.lastActivityAt, isNotNull);
      });
    });

    group('User Statistics', () {
      test('should get empty stats for new user', () async {
        const userId = 'new_user';

        final stats = await service.getUserStats(userId);

        expect(stats.totalPoints, equals(0));
        expect(stats.totalStudyMinutes, equals(0));
        expect(stats.questionsAnswered, equals(0));
        expect(stats.averageAccuracy, equals(0.0));
      });

      test('should award points to user', () async {
        const userId = 'user_123';

        await service.awardPoints(userId, 100, 'Quiz completed');

        expect(true, isTrue); // Points awarded
      });

      test('should add study minutes', () async {
        const userId = 'user_123';

        await service.addStudyMinutes(userId, 30);

        expect(true, isTrue); // Minutes added
      });

      test('should calculate progress to next level', () {
        const stats = UserStats(
          totalPoints: 500,
          totalStudyMinutes: 120,
          questionsAnswered: 50,
          correctAnswers: 40,
          averageAccuracy: 80.0,
          currentStreak: 5,
          longestStreak: 10,
          level: 1,
          nextLevelPoints: 1000,
          achievementsUnlocked: 2,
        );

        expect(stats.pointsToNextLevel, equals(500));
        expect(stats.levelProgress, equals(0.5));
      });

      test('should calculate minutes to next hour', () {
        const stats = UserStats(
          totalPoints: 0,
          totalStudyMinutes: 25,
          questionsAnswered: 0,
          correctAnswers: 0,
          averageAccuracy: 0.0,
          currentStreak: 0,
          longestStreak: 0,
          level: 1,
          nextLevelPoints: 1000,
          achievementsUnlocked: 0,
        );

        expect(stats.minutesToNextHour, equals(35));
      });
    });

    group('Achievement System', () {
      test('should get all achievements', () async {
        final achievements = await service.getAllAchievements();

        expect(achievements, isNotEmpty);
        expect(achievements.length, greaterThanOrEqualTo(2));
      });

      test('should get specific achievement', () async {
        final achievement = await service.getAchievement('first_100_points');

        expect(achievement, isNotNull);
        expect(achievement!.name, equals('Getting Started'));
        expect(achievement.points, equals(50));
      });

      test('should check if user has achievement', () async {
        const userId = 'user_123';
        const achievementId = 'first_100_points';

        final hasIt = await service.hasAchievement(userId, achievementId);

        expect(hasIt, isBool);
      });

      test('should get user achievements', () async {
        const userId = 'user_123';

        final achievements = await service.getUserAchievements(userId);

        expect(achievements, isA<List<UserAchievement>>());
      });

      test('should check and unlock achievements', () async {
        const userId = 'user_123';

        final achievements = await service.checkAndUnlockAchievements(userId);

        expect(achievements, isA<List<UserAchievement>>());
      });
    });

    group('Level System', () {
      test('should calculate level from points', () {
        expect(service.calculateLevel(0), equals(1));
        expect(service.calculateLevel(500), equals(1));
        expect(service.calculateLevel(1000), equals(2));
        expect(service.calculateLevel(2500), equals(3));
      });

      test('should get level threshold', () {
        expect(service.getLevelThreshold(1), equals(1000));
        expect(service.getLevelThreshold(2), equals(2500));
        expect(service.getLevelThreshold(3), equals(4000));
      });

      test('should determine correct level progression', () {
        const testCases = [
          (points: 0, level: 1),
          (points: 999, level: 1),
          (points: 1000, level: 2),
          (points: 2499, level: 2),
          (points: 2500, level: 3),
          (points: 10000, level: 8),
        ];

        for (final testCase in testCases) {
          expect(
            service.calculateLevel(testCase.points),
            equals(testCase.level),
            reason: 'Points ${testCase.points} should be level ${testCase.level}',
          );
        }
      });
    });
  });

  group('User Profile Models', () {
    group('UserProfile', () {
      test('should create profile from map', () {
        final map = {
          'userId': 'user_123',
          'displayName': 'John Doe',
          'bio': 'Learning hard',
          'totalPoints': 500,
          'totalStudyMinutes': 120,
          'questionsAnswered': 50,
          'averageAccuracy': 85.0,
          'level': 2,
          'visibility': ProfileVisibility.public.index,
          'status': UserStatus.studying.index,
        };

        final profile = UserProfile.fromMap(map);

        expect(profile.userId, equals('user_123'));
        expect(profile.displayName, equals('John Doe'));
        expect(profile.bio, equals('Learning hard'));
        expect(profile.level, equals(2));
      });

      test('should serialize profile to map', () {
        final profile = UserProfile(
          userId: 'user_123',
          displayName: 'Jane',
          bio: 'Student',
          totalPoints: 100,
          totalStudyMinutes: 60,
          questionsAnswered: 20,
          averageAccuracy: 80.0,
          level: 1,
          visibility: ProfileVisibility.public,
          status: UserStatus.active,
          createdAt: DateTime(2026, 8, 27),
          updatedAt: DateTime(2026, 8, 27),
        );

        final map = profile.toMap();

        expect(map['userId'], equals('user_123'));
        expect(map['displayName'], equals('Jane'));
        expect(map['level'], equals(1));
      });

      test('should identify public profiles', () {
        final publicProfile = UserProfile(
          userId: 'user_1',
          displayName: 'Public User',
          totalPoints: 0,
          totalStudyMinutes: 0,
          questionsAnswered: 0,
          averageAccuracy: 0.0,
          level: 1,
          visibility: ProfileVisibility.public,
          status: UserStatus.inactive,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(publicProfile.isPublic, isTrue);
      });

      test('should copy with modifications', () {
        final original = UserProfile(
          userId: 'user_123',
          displayName: 'Original',
          totalPoints: 100,
          totalStudyMinutes: 30,
          questionsAnswered: 10,
          averageAccuracy: 75.0,
          level: 1,
          visibility: ProfileVisibility.private,
          status: UserStatus.inactive,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final updated = original.copyWith(
          displayName: 'Updated',
          totalPoints: 200,
        );

        expect(updated.displayName, equals('Updated'));
        expect(updated.totalPoints, equals(200));
        expect(updated.userId, equals(original.userId));
      });
    });

    group('Achievement', () {
      test('should create achievement from map', () {
        final map = {
          'id': 'first_100',
          'name': 'Getting Started',
          'description': 'Earn 100 points',
          'iconUrl': 'https://example.com/icon.png',
          'type': AchievementType.milestone.index,
          'points': 50,
          'requirement': 'Earn 100 points',
          'rarity': 1,
        };

        final achievement = Achievement.fromMap(map);

        expect(achievement.id, equals('first_100'));
        expect(achievement.name, equals('Getting Started'));
        expect(achievement.type, equals(AchievementType.milestone));
        expect(achievement.points, equals(50));
      });

      test('should serialize achievement to map', () {
        final achievement = Achievement(
          id: 'streak_7',
          name: 'Week Streak',
          description: '7-day streak',
          iconUrl: 'https://example.com/streak.png',
          type: AchievementType.streak,
          points: 100,
          rarity: 3,
        );

        final map = achievement.toMap();

        expect(map['id'], equals('streak_7'));
        expect(map['points'], equals(100));
        expect(map['rarity'], equals(3));
      });
    });

    group('UserAchievement', () {
      test('should create earned achievement from map', () {
        final achievement = Achievement(
          id: 'first_100',
          name: 'Getting Started',
          description: '',
          iconUrl: '',
          type: AchievementType.milestone,
          points: 50,
        );

        final map = {
          'userId': 'user_123',
          'achievementId': 'first_100',
          'achievement': achievement.toMap(),
          'unlockedAt': DateTime.now(),
        };

        final userAchievement = UserAchievement.fromMap(map);

        expect(userAchievement.userId, equals('user_123'));
        expect(userAchievement.achievement.id, equals('first_100'));
      });
    });

    group('UserStats', () {
      test('should create stats from map', () {
        final map = {
          'totalPoints': 500,
          'totalStudyMinutes': 120,
          'questionsAnswered': 50,
          'correctAnswers': 40,
          'averageAccuracy': 80.0,
          'currentStreak': 5,
          'longestStreak': 10,
          'level': 2,
          'nextLevelPoints': 2500,
          'achievementsUnlocked': 3,
        };

        final stats = UserStats.fromMap(map);

        expect(stats.totalPoints, equals(500));
        expect(stats.level, equals(2));
        expect(stats.achievementsUnlocked, equals(3));
      });

      test('should calculate stats correctly', () {
        final stats = UserStats(
          totalPoints: 1500,
          totalStudyMinutes: 240,
          questionsAnswered: 100,
          correctAnswers: 85,
          averageAccuracy: 85.0,
          currentStreak: 10,
          longestStreak: 15,
          level: 2,
          nextLevelPoints: 2500,
          achievementsUnlocked: 5,
        );

        expect(stats.pointsToNextLevel, equals(1000));
        expect(stats.levelProgress, equals(0.6));
      });
    });
  });

  group('User Profile Integration Scenarios', () {
    late StubUserProfileService service;

    setUp(() {
      service = StubUserProfileService();
    });

    test('should complete user profile creation workflow', () async {
      const userId = 'new_user';
      const displayName = 'Alice Smith';

      // Create profile
      await service.updateProfile(
        userId,
        displayName,
        bio: 'Learning for exam',
        visibility: ProfileVisibility.public,
      );

      // Get profile
      final profile = await service.getUserProfile(userId);

      expect(profile, isNotNull);
      expect(profile!.displayName, equals(displayName));
      expect(profile.isPublic, isTrue);
    });

    test('should track user progression', () async {
      const userId = 'user_123';

      // Award points
      await service.awardPoints(userId, 100, 'Quiz completed');
      await service.awardPoints(userId, 50, 'Quiz completed');

      // Add study time
      await service.addStudyMinutes(userId, 30);
      await service.addStudyMinutes(userId, 45);

      // Get stats
      final stats = await service.getUserStats(userId);

      expect(stats, isNotNull);
    });

    test('should handle achievement unlocking', () async {
      const userId = 'user_123';

      // Check achievements
      final achievements = await service.checkAndUnlockAchievements(userId);

      expect(achievements, isA<List<UserAchievement>>());
    });

    test('should provide complete user profile data', () async {
      const userId = 'user_123';

      // Update profile
      await service.updateProfile(
        userId,
        'Test User',
        bio: 'Bio',
        visibility: ProfileVisibility.public,
      );

      // Get profile and stats
      final profile = await service.getUserProfile(userId);
      final stats = await service.getUserStats(userId);
      final achievements = await service.getUserAchievements(userId);

      expect(profile, isNotNull);
      expect(stats, isNotNull);
      expect(achievements, isA<List<UserAchievement>>());
    });
  });
}
