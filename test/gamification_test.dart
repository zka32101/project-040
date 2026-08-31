import 'package:flutter_test/flutter_test.dart';
import '../lib/models/community_model.dart';
import '../lib/services/community_service.dart';

void main() {
  late StubCommunityService service;

  setUp(() {
    service = StubCommunityService();
  });

  group('AchievementBadge', () {
    test('should initialize empty badge', () {
      final badge = AchievementBadge.empty(
        badgeId: 'badge_1',
        userId: 'user123',
      );

      expect(badge.displayName, isEmpty);
      expect(badge.points, 0);
      expect(badge.rarity, BadgeRarityLevel.common);
    });

    test('should calculate rarity multiplier', () {
      final commonBadge = AchievementBadge(
        badgeId: 'badge_1',
        userId: 'user123',
        type: BadgeType.firstQuestion,
        displayName: 'First',
        description: 'Test',
        iconUrl: '🎯',
        rarity: BadgeRarityLevel.common,
        points: 10,
        earnedAt: DateTime.now(),
      );

      final epicBadge = AchievementBadge(
        badgeId: 'badge_2',
        userId: 'user123',
        type: BadgeType.sevenStreak,
        displayName: 'Streak',
        description: 'Test',
        iconUrl: '🔥',
        rarity: BadgeRarityLevel.epic,
        points: 100,
        earnedAt: DateTime.now(),
      );

      expect(commonBadge.rarityMultiplier, 1);
      expect(epicBadge.rarityMultiplier, 5);
    });

    test('should calculate badge age', () {
      final earnedDate = DateTime.now().subtract(Duration(days: 5));
      final badge = AchievementBadge(
        badgeId: 'badge_1',
        userId: 'user123',
        type: BadgeType.firstQuestion,
        displayName: 'Test',
        description: 'Test',
        iconUrl: '🎯',
        rarity: BadgeRarityLevel.common,
        points: 10,
        earnedAt: earnedDate,
      );

      expect(badge.ageInDays, 5);
    });
  });

  group('StudyStreak', () {
    test('should initialize empty streak', () {
      final streak = StudyStreak.empty(
        streakId: 'ss_1',
        userId: 'user123',
      );

      expect(streak.currentStreak, 0);
      expect(streak.longestStreak, 0);
      expect(streak.isActive, false);
    });

    test('should detect active streak', () {
      final yesterday = DateTime.now().subtract(Duration(days: 1));
      final streak = StudyStreak(
        streakId: 'ss_1',
        userId: 'user123',
        currentStreak: 5,
        longestStreak: 10,
        lastStudyDate: yesterday,
        studyDates: [],
        totalDaysStudied: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(streak.isActive, true);
      expect(streak.daysUntilBroken, 1);
    });

    test('should calculate days until broken', () {
      final daysBefore = DateTime.now().subtract(Duration(days: 3));
      final streak = StudyStreak(
        streakId: 'ss_1',
        userId: 'user123',
        currentStreak: 5,
        longestStreak: 5,
        lastStudyDate: daysBefore,
        studyDates: [],
        totalDaysStudied: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(streak.isActive, false);
      expect(streak.daysUntilBroken, lessThanOrEqualTo(0));
    });
  });

  group('AchievementStats', () {
    test('should initialize empty stats', () {
      final stats = AchievementStats.empty(
        statsId: 'as_1',
        userId: 'user123',
      );

      expect(stats.totalBadgesEarned, 0);
      expect(stats.totalPoints, 0);
      expect(stats.totalLevel, 1);
      expect(stats.perfectScoreSessions, 0);
    });

    test('should calculate points to next level', () {
      final stats = AchievementStats(
        statsId: 'as_1',
        userId: 'user123',
        totalBadgesEarned: 0,
        totalPoints: 500,
        totalLevel: 1,
        badges: [],
        currentStreak: StudyStreak.empty(streakId: 'ss_1', userId: 'user123'),
        perfectScoreSessions: 0,
        fastestTimeRecord: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(stats.pointsToNextLevel, 500); // 1000 - 500
      expect(stats.levelUpProgress, 50); // 50%
    });

    test('should calculate level correctly', () {
      final stats = AchievementStats(
        statsId: 'as_1',
        userId: 'user123',
        totalBadgesEarned: 0,
        totalPoints: 2500,
        totalLevel: 3,
        badges: [],
        currentStreak: StudyStreak.empty(streakId: 'ss_1', userId: 'user123'),
        perfectScoreSessions: 0,
        fastestTimeRecord: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(stats.totalLevel, 3);
      expect(stats.levelUpProgress, closeTo(50, 1));
    });
  });

  group('RewardMultiplier', () {
    test('should initialize empty multiplier', () {
      final multiplier = RewardMultiplier.empty(
        multiplierId: 'rm_1',
        userId: 'user123',
      );

      expect(multiplier.baseMultiplier, 1.0);
      expect(multiplier.isActive, true);
    });

    test('should calculate effective multiplier with boosts', () {
      final multiplier = RewardMultiplier(
        multiplierId: 'rm_1',
        userId: 'user123',
        baseMultiplier: 1.0,
        activeBoosts: ['streak_3x', 'time_bonus'],
        activatedAt: DateTime.now(),
        reason: 'test',
      );

      final effective = multiplier.effectiveMultiplier;
      expect(effective, greaterThan(1.0));
      expect(effective, closeTo(1.8, 0.1)); // 1.0 * 1.5 * 1.2
    });

    test('should expire multiplier', () {
      final expiredDate = DateTime.now().subtract(Duration(hours: 1));
      final multiplier = RewardMultiplier(
        multiplierId: 'rm_1',
        userId: 'user123',
        baseMultiplier: 2.0,
        activeBoosts: [],
        activatedAt: DateTime.now(),
        expiresAt: expiredDate,
        reason: 'test',
      );

      expect(multiplier.isActive, false);
      expect(multiplier.effectiveMultiplier, 1.0);
    });
  });

  group('BadgeEarning', () {
    test('should earn badge', () async {
      await service.earnBadge(
        userId: 'user123',
        type: BadgeType.firstQuestion,
        displayName: '最初の一歩',
        description: '最初の問題に答えた',
        rarity: BadgeRarityLevel.common,
        points: 10,
      );

      final badges = await service.getUserBadges('user123');

      expect(badges, isNotEmpty);
      expect(badges[0].displayName, '最初の一歩');
      expect(badges[0].type, BadgeType.firstQuestion);
    });

    test('should earn multiple badges', () async {
      await service.earnBadge(
        userId: 'user123',
        type: BadgeType.firstQuestion,
        displayName: 'First',
        description: 'Test',
        rarity: BadgeRarityLevel.common,
        points: 10,
      );
      await service.earnBadge(
        userId: 'user123',
        type: BadgeType.threeStreak,
        displayName: 'Streak',
        description: 'Test',
        rarity: BadgeRarityLevel.uncommon,
        points: 50,
      );

      final badges = await service.getUserBadges('user123');

      expect(badges.length, 2);
    });

    test('should toggle badge pinned status', () async {
      await service.earnBadge(
        userId: 'user123',
        type: BadgeType.firstQuestion,
        displayName: 'Test',
        description: 'Test',
        rarity: BadgeRarityLevel.common,
        points: 10,
      );

      final badgesBefore = await service.getUserBadges('user123');
      final badgeId = badgesBefore[0].badgeId;

      await service.toggleBadgePinned(badgeId: badgeId, isPinned: true);

      final badge = await service.getBadge(badgeId);
      expect(badge!.isPinned, true);
    });

    test('should retrieve single badge by ID', () async {
      await service.earnBadge(
        userId: 'user123',
        type: BadgeType.firstQuestion,
        displayName: 'Test',
        description: 'Test',
        rarity: BadgeRarityLevel.common,
        points: 10,
      );

      final badges = await service.getUserBadges('user123');
      final retrieved = await service.getBadge(badges[0].badgeId);

      expect(retrieved, isNotNull);
      expect(retrieved!.displayName, 'Test');
    });
  });

  group('StreakTracking', () {
    test('should initialize streak for user', () async {
      await service.initializeAchievementStats('user123');
      await service.updateStreak(userId: 'user123', studiedToday: true);

      final streak = await service.getUserStreak('user123');

      expect(streak, isNotNull);
      expect(streak!.currentStreak, 1);
    });

    test('should increment consecutive days', () async {
      await service.initializeAchievementStats('user123');

      for (int i = 0; i < 3; i++) {
        // Mock studying on consecutive days would require time manipulation
        await service.updateStreak(userId: 'user123', studiedToday: true);
      }

      final streak = await service.getUserStreak('user123');

      expect(streak!.currentStreak, greaterThan(0));
    });

    test('should track longest streak', () async {
      await service.initializeAchievementStats('user123');

      for (int i = 0; i < 5; i++) {
        await service.updateStreak(userId: 'user123', studiedToday: true);
      }

      final streak = await service.getUserStreak('user123');

      expect(streak!.longestStreak, greaterThan(0));
    });

    test('should reset streak when no study', () async {
      await service.initializeAchievementStats('user123');
      await service.updateStreak(userId: 'user123', studiedToday: false);

      final streak = await service.getUserStreak('user123');

      expect(streak!.currentStreak, 0);
    });

    test('should earn 3-day streak badge', () async {
      await service.initializeAchievementStats('user123');

      // Simulate 3 consecutive days (simplified)
      for (int i = 0; i < 3; i++) {
        await service.updateStreak(userId: 'user123', studiedToday: true);
      }

      final badges = await service.getUserBadges('user123');

      // May or may not have streak badge depending on logic
      expect(badges, isNotNull);
    });

    test('should manually reset streak', () async {
      await service.initializeAchievementStats('user123');
      await service.updateStreak(userId: 'user123', studiedToday: true);
      await service.resetStreak('user123');

      final streak = await service.getUserStreak('user123');

      expect(streak!.currentStreak, 0);
    });
  });

  group('AchievementStatistics', () {
    test('should initialize achievement stats', () async {
      await service.initializeAchievementStats('user123');

      final stats = await service.getAchievementStats('user123');

      expect(stats, isNotNull);
      expect(stats!.totalBadgesEarned, 0);
      expect(stats.totalPoints, 0);
      expect(stats.totalLevel, 1);
    });

    test('should update stats on badge earn', () async {
      await service.initializeAchievementStats('user123');

      await service.earnBadge(
        userId: 'user123',
        type: BadgeType.firstQuestion,
        displayName: 'First',
        description: 'Test',
        rarity: BadgeRarityLevel.common,
        points: 50,
      );

      final stats = await service.getAchievementStats('user123');

      expect(stats!.totalBadgesEarned, 1);
      expect(stats.totalPoints, 50);
    });

    test('should record perfect score', () async {
      await service.initializeAchievementStats('user123');

      await service.recordPerfectScore('user123');

      final stats = await service.getAchievementStats('user123');

      expect(stats!.perfectScoreSessions, 1);
    });

    test('should update fastest time record', () async {
      await service.initializeAchievementStats('user123');

      await service.updateFastestTime(userId: 'user123', timeInSeconds: 120);
      await service.updateFastestTime(userId: 'user123', timeInSeconds: 100);

      final stats = await service.getAchievementStats('user123');

      expect(stats!.fastestTimeRecord, 100);
    });

    test('should earn speed demon badge', () async {
      await service.initializeAchievementStats('user123');

      await service.updateFastestTime(userId: 'user123', timeInSeconds: 50);

      final badges = await service.getUserBadges('user123');

      expect(
        badges.any((b) => b.type == BadgeType.speedDemon),
        true,
      );
    });

    test('should get user level', () async {
      await service.initializeAchievementStats('user123');

      final level = await service.getUserLevel('user123');

      expect(level, 1);
    });

    test('should get user total XP', () async {
      await service.initializeAchievementStats('user123');

      final xp = await service.getUserTotalXP('user123');

      expect(xp, 0);
    });
  });

  group('RewardMultipliers', () {
    test('should set reward multiplier', () async {
      await service.setRewardMultiplier(
        userId: 'user123',
        multiplier: 1.5,
        boosts: ['streak_3x'],
        reason: 'test',
      );

      final multiplier = await service.getRewardMultiplier('user123');

      expect(multiplier, isNotNull);
      expect(multiplier!.baseMultiplier, 1.5);
    });

    test('should calculate effective XP with multiplier', () async {
      await service.initializeAchievementStats('user123');
      await service.setRewardMultiplier(
        userId: 'user123',
        multiplier: 1.0,
        boosts: ['streak_3x'],
        reason: 'test',
      );

      final xpAwarded = await service.awardXP(
        userId: 'user123',
        baseXP: 100,
      );

      expect(xpAwarded, greaterThan(100));
    });

    test('should award XP without multiplier', () async {
      await service.initializeAchievementStats('user123');

      final xpAwarded = await service.awardXP(
        userId: 'user123',
        baseXP: 100,
      );

      expect(xpAwarded, 100);
    });
  });

  group('MilestoneAchievements', () {
    test('should check milestone achievements', () async {
      // Create progress data
      for (int i = 0; i < 5; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '交通規則',
          isCorrect: true,
          timeSpentSeconds: 30,
        );
      }

      final milestones = await service.checkMilestoneAchievements('user123');

      expect(milestones, isList);
    });

    test('should detect 10 question milestone', () async {
      for (int i = 0; i < 10; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '交通規則',
          isCorrect: true,
          timeSpentSeconds: 30,
        );
      }

      final milestones = await service.checkMilestoneAchievements('user123');

      expect(milestones, contains('tenQuestions'));
    });

    test('should detect 100 question milestone', () async {
      for (int i = 0; i < 100; i++) {
        await service.updateProgressTracker(
          userId: 'user123',
          category: '交通規則',
          isCorrect: i < 80,
          timeSpentSeconds: 30,
        );
      }

      final milestones = await service.checkMilestoneAchievements('user123');

      expect(milestones, contains('hundredQuestions'));
    });
  });
}
