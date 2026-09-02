import 'package:flutter_test/flutter_test.dart';
import 'package:bike_license_kore/models/leaderboard_model.dart';
import 'package:bike_license_kore/services/leaderboard_service.dart';

void main() {
  group('Leaderboard Service', () {
    late StubLeaderboardService service;

    setUp(() {
      service = StubLeaderboardService();
    });

    group('Global Leaderboard', () {
      test('should get global leaderboard', () async {
        final leaderboard = await service.getGlobalLeaderboard();

        expect(leaderboard, isNotEmpty);
        expect(leaderboard.first.rank, equals(1));
      });

      test('should return entries sorted by rank', () async {
        final leaderboard = await service.getGlobalLeaderboard();

        for (int i = 0; i < leaderboard.length - 1; i++) {
          expect(
            leaderboard[i].rank,
            lessThanOrEqualTo(leaderboard[i + 1].rank),
          );
        }
      });

      test('should respect limit parameter', () async {
        final leaderboard = await service.getGlobalLeaderboard(limit: 1);

        expect(leaderboard.length, lessThanOrEqualTo(1));
      });

      test('should get different periods', () async {
        final allTime = await service.getGlobalLeaderboard(
          period: RankingPeriod.allTime,
        );
        final weekly = await service.getGlobalLeaderboard(
          period: RankingPeriod.weekly,
        );

        expect(allTime, isNotEmpty);
        expect(weekly, isNotEmpty);
      });
    });

    group('Category Leaderboard', () {
      test('should get category leaderboard', () async {
        final leaderboard = await service.getCategoryLeaderboard('quiz_master');

        expect(leaderboard, isA<List<LeaderboardEntry>>());
      });

      test('should include categoryId in results', () async {
        await service.updateUserLeaderboardPosition(
          'user_cat',
          'CategoryPlayer',
          null,
          100,
          85.0,
          5,
          1,
          10,
          30,
          2,
        );

        final leaderboard = await service.getCategoryLeaderboard('test_cat');

        expect(leaderboard, isNotEmpty);
      });

      test('should get different categories', () async {
        final cat1 = await service.getCategoryLeaderboard('category_1');
        final cat2 = await service.getCategoryLeaderboard('category_2');

        expect(cat1, isA<List<LeaderboardEntry>>());
        expect(cat2, isA<List<LeaderboardEntry>>());
      });
    });

    group('Friends Leaderboard', () {
      test('should get friends leaderboard', () async {
        final leaderboard = await service.getFriendsLeaderboard('user_1');

        expect(leaderboard, isA<List<LeaderboardEntry>>());
      });

      test('should return list of entries', () async {
        final leaderboard = await service.getFriendsLeaderboard('user_1');

        expect(leaderboard, isNotEmpty);
        expect(leaderboard.first, isA<LeaderboardEntry>());
      });
    });

    group('Accuracy Leaderboard', () {
      test('should get accuracy leaderboard', () async {
        final leaderboard = await service.getAccuracyLeaderboard();

        expect(leaderboard, isNotEmpty);
      });

      test('should sort by accuracy descending', () async {
        final leaderboard = await service.getAccuracyLeaderboard();

        for (int i = 0; i < leaderboard.length - 1; i++) {
          expect(
            leaderboard[i].averageAccuracy,
            greaterThanOrEqualTo(leaderboard[i + 1].averageAccuracy),
          );
        }
      });

      test('should respect limit', () async {
        final leaderboard = await service.getAccuracyLeaderboard(limit: 5);

        expect(leaderboard.length, lessThanOrEqualTo(5));
      });
    });

    group('User Rankings', () {
      test('should get user global rank', () async {
        final rank = await service.getUserGlobalRank('user_1');

        expect(rank, isA<int>());
      });

      test('should return 0 for non-existent user', () async {
        final rank = await service.getUserGlobalRank('non_existent');

        expect(rank, equals(0));
      });

      test('should get user category rank', () async {
        final rank = await service.getUserCategoryRank('user_1', 'category_1');

        expect(rank, isA<int>());
      });

      test('should get all user rankings', () async {
        final rankings = await service.getUserRankings('user_1');

        expect(rankings.userId, equals('user_1'));
        expect(rankings.globalRank, isA<int>());
        expect(rankings.categoryRanks, isA<Map<String, int>>());
      });

      test('should return empty rankings for new user', () async {
        final rankings = await service.getUserRankings('new_user');

        expect(rankings.userId, equals('new_user'));
        expect(rankings.globalRank, equals(0));
      });
    });

    group('Leaderboard Around User', () {
      test('should get leaderboard around user', () async {
        final leaderboard = await service.getLeaderboardAroundUser('user_1');

        expect(leaderboard, isNotEmpty);
      });

      test('should return empty for non-existent user', () async {
        final leaderboard = await service.getLeaderboardAroundUser('non_existent');

        expect(leaderboard, isEmpty);
      });

      test('should respect context size', () async {
        final leaderboard = await service.getLeaderboardAroundUser(
          'user_1',
          contextSize: 2,
        );

        expect(leaderboard.length, lessThanOrEqualTo(5));
      });

      test('should include user in results', () async {
        final leaderboard = await service.getLeaderboardAroundUser(
          'user_1',
          contextSize: 5,
        );

        final userIds = leaderboard.map((e) => e.userId).toList();
        expect(userIds, contains('user_1'));
      });
    });

    group('Update Leaderboard Position', () {
      test('should update user position', () async {
        await service.updateUserLeaderboardPosition(
          'test_user',
          'Test Player',
          'https://example.com/avatar.jpg',
          1000,
          90.5,
          10,
          3,
          100,
          240,
          5,
        );

        final rankings = await service.getUserRankings('test_user');

        expect(rankings.userId, equals('test_user'));
        expect(rankings.globalRank, greaterThan(0));
      });

      test('should update with new points', () async {
        await service.updateUserLeaderboardPosition(
          'user_update',
          'Updated Player',
          null,
          500,
          85.0,
          5,
          2,
          50,
          150,
          3,
        );

        final leaderboard = await service.getGlobalLeaderboard();
        final entry = leaderboard.firstWhere(
          (e) => e.userId == 'user_update',
          orElse: () => LeaderboardEntry.empty(),
        );

        expect(entry.totalPoints, equals(500));
      });

      test('should track all stats', () async {
        const userId = 'stats_test';
        const displayName = 'Stats Test';
        const points = 2000;
        const accuracy = 92.5;
        const streak = 15;
        const level = 5;
        const questions = 200;
        const studyTime = 300;
        const achievements = 6;

        await service.updateUserLeaderboardPosition(
          userId,
          displayName,
          null,
          points,
          accuracy,
          streak,
          level,
          questions,
          studyTime,
          achievements,
        );

        final rankings = await service.getUserRankings(userId);

        expect(rankings.userId, equals(userId));
      });
    });

    group('Top Rank Checks', () {
      test('should identify top 10 players', () async {
        final isTop = await service.isUserInTopRank('user_1', topN: 10);

        expect(isTop, isA<bool>());
      });

      test('should return false for non-top players', () async {
        final isTop = await service.isUserInTopRank('non_existent', topN: 10);

        expect(isTop, isFalse);
      });

      test('should respect top N parameter', () async {
        final isTopTen = await service.isUserInTopRank('user_2', topN: 10);
        final isTopThree = await service.isUserInTopRank('user_2', topN: 3);

        expect(isTopTen, isA<bool>());
        expect(isTopThree, isA<bool>());
      });
    });

    group('Leaderboard Statistics', () {
      test('should get leaderboard stats', () async {
        final stats = await service.getLeaderboardStats(
          LeaderboardType.global,
        );

        expect(stats.totalPlayers, isA<int>());
        expect(stats.averagePoints, isA<double>());
      });

      test('should calculate total players', () async {
        final stats = await service.getLeaderboardStats(
          LeaderboardType.global,
        );

        expect(stats.totalPlayers, greaterThanOrEqualTo(0));
      });

      test('should calculate average points', () async {
        final stats = await service.getLeaderboardStats(
          LeaderboardType.global,
        );

        expect(stats.averagePoints, greaterThanOrEqualTo(0));
      });

      test('should calculate median level', () async {
        final stats = await service.getLeaderboardStats(
          LeaderboardType.global,
        );

        expect(stats.medianLevel, greaterThanOrEqualTo(1));
      });

      test('should calculate average accuracy', () async {
        final stats = await service.getLeaderboardStats(
          LeaderboardType.global,
        );

        expect(stats.averageAccuracy, greaterThanOrEqualTo(0));
        expect(stats.averageAccuracy, lessThanOrEqualTo(100));
      });

      test('should provide calculation timestamp', () async {
        final stats = await service.getLeaderboardStats(
          LeaderboardType.global,
        );

        expect(stats.calculatedAt, isNotNull);
      });
    });

    group('Rank Changes', () {
      test('should get user rank changes', () async {
        final changes = await service.getUserRankChanges('user_1');

        expect(changes, isA<List<RankChange>>());
      });

      test('should return empty for new user', () async {
        final changes = await service.getUserRankChanges('non_existent');

        expect(changes, isEmpty);
      });

      test('should respect limit parameter', () async {
        final changes = await service.getUserRankChanges('user_1', limit: 5);

        expect(changes.length, lessThanOrEqualTo(5));
      });
    });

    group('Recalculate Leaderboards', () {
      test('should recalculate rankings', () async {
        await service.updateUserLeaderboardPosition(
          'recalc_user_1',
          'Recalc 1',
          null,
          1000,
          85.0,
          5,
          2,
          50,
          150,
          3,
        );

        await service.recalculateLeaderboards();

        final rankings = await service.getUserRankings('recalc_user_1');
        expect(rankings.userId, equals('recalc_user_1'));
      });
    });
  });

  group('Leaderboard Models', () {
    group('LeaderboardEntry', () {
      test('should create leaderboard entry', () {
        final entry = LeaderboardEntry(
          userId: 'user_1',
          displayName: 'Player One',
          rank: 1,
          totalPoints: 1000,
          averageAccuracy: 85.0,
          currentStreak: 10,
          level: 2,
          questionsAnswered: 50,
          totalStudyMinutes: 120,
          achievementsUnlocked: 3,
          updatedAt: DateTime.now(),
          type: LeaderboardType.global,
          period: RankingPeriod.allTime,
        );

        expect(entry.userId, equals('user_1'));
        expect(entry.rank, equals(1));
      });

      test('should identify top ten', () {
        final topEntry = LeaderboardEntry(
          userId: 'top',
          displayName: 'Top',
          rank: 5,
          totalPoints: 1000,
          averageAccuracy: 85.0,
          currentStreak: 10,
          level: 2,
          questionsAnswered: 50,
          totalStudyMinutes: 120,
          achievementsUnlocked: 3,
          updatedAt: DateTime.now(),
          type: LeaderboardType.global,
          period: RankingPeriod.allTime,
        );

        expect(topEntry.isTopTen, isTrue);
      });

      test('should identify top hundred', () {
        final entry = LeaderboardEntry(
          userId: 'rank50',
          displayName: 'Rank 50',
          rank: 50,
          totalPoints: 500,
          averageAccuracy: 80.0,
          currentStreak: 5,
          level: 1,
          questionsAnswered: 25,
          totalStudyMinutes: 60,
          achievementsUnlocked: 1,
          updatedAt: DateTime.now(),
          type: LeaderboardType.global,
          period: RankingPeriod.allTime,
        );

        expect(entry.isTopHundred, isTrue);
        expect(entry.isTopTen, isFalse);
      });

      test('should serialize to map', () {
        final entry = LeaderboardEntry(
          userId: 'user_1',
          displayName: 'Player',
          rank: 1,
          totalPoints: 1000,
          averageAccuracy: 85.0,
          currentStreak: 10,
          level: 2,
          questionsAnswered: 50,
          totalStudyMinutes: 120,
          achievementsUnlocked: 3,
          updatedAt: DateTime(2026, 8, 27),
          type: LeaderboardType.global,
          period: RankingPeriod.allTime,
        );

        final map = entry.toMap();

        expect(map['userId'], equals('user_1'));
        expect(map['rank'], equals(1));
      });

      test('should deserialize from map', () {
        final now = DateTime.now();
        final map = {
          'userId': 'user_123',
          'displayName': 'Test User',
          'rank': 5,
          'totalPoints': 500,
          'averageAccuracy': 90.0,
          'currentStreak': 7,
          'level': 2,
          'questionsAnswered': 100,
          'totalStudyMinutes': 240,
          'achievementsUnlocked': 5,
          'type': LeaderboardType.global.index,
          'period': RankingPeriod.allTime.index,
        };

        final entry = LeaderboardEntry.fromMap(map);

        expect(entry.userId, equals('user_123'));
        expect(entry.rank, equals(5));
      });

      test('should copy with modifications', () {
        final original = LeaderboardEntry(
          userId: 'user_1',
          displayName: 'Original',
          rank: 10,
          totalPoints: 1000,
          averageAccuracy: 85.0,
          currentStreak: 10,
          level: 2,
          questionsAnswered: 50,
          totalStudyMinutes: 120,
          achievementsUnlocked: 3,
          updatedAt: DateTime.now(),
          type: LeaderboardType.global,
          period: RankingPeriod.allTime,
        );

        final updated = original.copyWith(
          displayName: 'Updated',
          rank: 5,
        );

        expect(updated.displayName, equals('Updated'));
        expect(updated.rank, equals(5));
        expect(updated.userId, equals(original.userId));
      });
    });

    group('RankChange', () {
      test('should track rank changes', () {
        final change = RankChange(
          userId: 'user_1',
          previousRank: 50,
          currentRank: 30,
          pointsGained: 200,
          updatedAt: DateTime.now(),
        );

        expect(change.rankImprovement, equals(20));
        expect(change.rankImproved, isTrue);
      });

      test('should calculate rank improvement', () {
        final improvement = RankChange(
          userId: 'user_1',
          previousRank: 100,
          currentRank: 50,
          pointsGained: 500,
          updatedAt: DateTime.now(),
        );

        expect(improvement.rankImprovement, equals(50));
      });
    });

    group('UserRankings', () {
      test('should create user rankings', () {
        final rankings = UserRankings(
          userId: 'user_1',
          globalRank: 5,
          globalRankAllTime: 5,
          globalRankWeekly: 10,
          globalRankMonthly: 3,
          categoryRanks: {'quiz': 2, 'essay': 5},
          friendsRank: 1,
          totalPlayersGlobal: 1000,
          updatedAt: DateTime.now(),
        );

        expect(rankings.userId, equals('user_1'));
        expect(rankings.globalRank, equals(5));
        expect(rankings.categoryRanks['quiz'], equals(2));
      });

      test('should serialize rankings', () {
        final rankings = UserRankings(
          userId: 'user_1',
          globalRank: 5,
          globalRankAllTime: 5,
          globalRankWeekly: 10,
          globalRankMonthly: 3,
          categoryRanks: {},
          friendsRank: 1,
          totalPlayersGlobal: 1000,
          updatedAt: DateTime(2026, 8, 27),
        );

        final map = rankings.toMap();

        expect(map['userId'], equals('user_1'));
        expect(map['globalRank'], equals(5));
      });

      test('should deserialize rankings', () {
        final map = {
          'userId': 'user_123',
          'globalRank': 10,
          'globalRankAllTime': 10,
          'globalRankWeekly': 15,
          'globalRankMonthly': 8,
          'categoryRanks': {'math': 3, 'science': 7},
          'friendsRank': 2,
          'totalPlayersGlobal': 500,
        };

        final rankings = UserRankings.fromMap(map);

        expect(rankings.userId, equals('user_123'));
        expect(rankings.globalRank, equals(10));
      });
    });

    group('LeaderboardConfig', () {
      test('should create default global config', () {
        final config = LeaderboardConfig.globalAllTime();

        expect(config.type, equals(LeaderboardType.global));
        expect(config.period, equals(RankingPeriod.allTime));
        expect(config.sortBy, equals(RankingSortBy.points));
      });

      test('should create weekly config', () {
        final config = LeaderboardConfig.globalWeekly();

        expect(config.type, equals(LeaderboardType.global));
        expect(config.period, equals(RankingPeriod.weekly));
      });

      test('should create accuracy config', () {
        final config = LeaderboardConfig.accuracy();

        expect(config.sortBy, equals(RankingSortBy.accuracy));
      });
    });

    group('LeaderboardStats', () {
      test('should create stats', () {
        final stats = LeaderboardStats(
          totalPlayers: 1000,
          topTenMedianPoints: 2000,
          averagePoints: 800.0,
          medianLevel: 3,
          averageAccuracy: 80.0,
          calculatedAt: DateTime.now(),
        );

        expect(stats.totalPlayers, equals(1000));
        expect(stats.averagePoints, equals(800.0));
      });

      test('should serialize stats', () {
        final stats = LeaderboardStats(
          totalPlayers: 500,
          topTenMedianPoints: 1500,
          averagePoints: 600.0,
          medianLevel: 2,
          averageAccuracy: 75.0,
          calculatedAt: DateTime(2026, 8, 27),
        );

        final map = stats.toMap();

        expect(map['totalPlayers'], equals(500));
        expect(map['averagePoints'], equals(600.0));
      });

      test('should deserialize stats', () {
        final map = {
          'totalPlayers': 300,
          'topTenMedianPoints': 1000,
          'averagePoints': 500.0,
          'medianLevel': 2,
          'averageAccuracy': 70.0,
        };

        final stats = LeaderboardStats.fromMap(map);

        expect(stats.totalPlayers, equals(300));
        expect(stats.medianLevel, equals(2));
      });
    });
  });

  group('Leaderboard Integration Scenarios', () {
    late StubLeaderboardService service;

    setUp(() {
      service = StubLeaderboardService();
    });

    test('should track user progression through leaderboard', () async {
      const userId = 'progress_user';

      // Initial position
      await service.updateUserLeaderboardPosition(
        userId,
        'Progress User',
        null,
        100,
        80.0,
        2,
        1,
        10,
        30,
        1,
      );

      var rankings = await service.getUserRankings(userId);
      final initialRank = rankings.globalRank;

      // After more study
      await service.updateUserLeaderboardPosition(
        userId,
        'Progress User',
        null,
        500,
        85.0,
        7,
        2,
        50,
        150,
        3,
      );

      rankings = await service.getUserRankings(userId);
      expect(rankings.globalRank, lessThanOrEqualTo(initialRank));
    });

    test('should provide complete ranking view', () async {
      const userId = 'complete_user';

      await service.updateUserLeaderboardPosition(
        userId,
        'Complete User',
        'https://example.com/avatar.jpg',
        2000,
        90.0,
        15,
        4,
        200,
        300,
        6,
      );

      final rankings = await service.getUserRankings(userId);
      final leaderboard = await service.getGlobalLeaderboard();
      final stats = await service.getLeaderboardStats(LeaderboardType.global);

      expect(rankings.userId, equals(userId));
      expect(leaderboard, isNotEmpty);
      expect(stats.totalPlayers, greaterThan(0));
    });

    test('should support leaderboard filtering', () async {
      final global = await service.getGlobalLeaderboard(limit: 100);
      final topTen = await service.getGlobalLeaderboard(limit: 10);
      final accuracy = await service.getAccuracyLeaderboard(limit: 50);

      expect(global.length, greaterThanOrEqualTo(topTen.length));
      expect(accuracy, isNotEmpty);
    });
  });
}
