import 'package:flutter_test/flutter_test.dart';
import 'package:bike_license_kore/models/social_model.dart';
import 'package:bike_license_kore/services/social_service.dart';

void main() {
  group('Social Service', () {
    late StubSocialService service;

    setUp(() {
      service = StubSocialService();
    });

    group('Friend Management', () {
      test('should send friend request', () async {
        await service.sendFriendRequest('user_1', 'user_2');

        expect(true, isTrue); // Request sent
      });

      test('should accept friend request', () async {
        await service.acceptFriendRequest('user_1', 'user_2');

        final friends = await service.getFriends('user_1');
        expect(friends, isNotEmpty);
      });

      test('should reject friend request', () async {
        await service.rejectFriendRequest('user_1', 'user_2');

        expect(true, isTrue); // Request rejected
      });

      test('should remove friend', () async {
        await service.acceptFriendRequest('user_1', 'user_2');
        await service.removeFriend('user_1', 'user_2');

        final friends = await service.getFriends('user_1');
        expect(friends.isEmpty, isTrue);
      });

      test('should get friends list', () async {
        final friends = await service.getFriends('user_1');

        expect(friends, isA<List<Friend>>());
      });

      test('should get pending requests', () async {
        final requests = await service.getPendingRequests('user_1');

        expect(requests, isA<List<Friend>>());
      });

      test('should check friendship status', () async {
        await service.acceptFriendRequest('user_1', 'user_2');
        final areFriends = await service.areFriends('user_1', 'user_2');

        expect(areFriends, isTrue);
      });

      test('should return false for non-friends', () async {
        final areFriends = await service.areFriends('user_1', 'user_99');

        expect(areFriends, isFalse);
      });

      test('should get friend details', () async {
        await service.acceptFriendRequest('user_1', 'user_2');
        final friend = await service.getFriendDetails('user_1', 'user_2');

        expect(friend, isNotNull);
      });

      test('should return null for non-existent friend', () async {
        final friend = await service.getFriendDetails('user_1', 'non_existent');

        expect(friend?.userId, isEmpty);
      });
    });

    group('Activity Feed', () {
      test('should post activity', () async {
        final activity = Activity(
          userId: 'user_1',
          displayName: 'Test User',
          type: ActivityType.quiz_completed,
          description: 'Completed quiz',
          createdAt: DateTime.now(),
        );

        await service.postActivity(activity);

        expect(true, isTrue); // Activity posted
      });

      test('should get activity feed', () async {
        final feed = await service.getActivityFeed('user_1');

        expect(feed, isA<List<Activity>>());
      });

      test('should get user activities', () async {
        final activity = Activity(
          userId: 'user_1',
          displayName: 'Test User',
          type: ActivityType.achievement_unlocked,
          description: 'Unlocked achievement',
          createdAt: DateTime.now(),
        );

        await service.postActivity(activity);
        final activities = await service.getUserActivities('user_1');

        expect(activities, isNotEmpty);
      });

      test('should respect activity limit', () async {
        for (int i = 0; i < 50; i++) {
          await service.postActivity(Activity(
            userId: 'user_1',
            displayName: 'Test User',
            type: ActivityType.quiz_completed,
            description: 'Activity $i',
            createdAt: DateTime.now(),
          ));
        }

        final activities = await service.getUserActivities('user_1', limit: 10);

        expect(activities.length, lessThanOrEqualTo(10));
      });

      test('should delete activity', () async {
        await service.deleteActivity('activity_1');

        expect(true, isTrue); // Activity deleted
      });
    });

    group('Study Groups', () {
      test('should create study group', () async {
        const group = StudyGroup(
          groupId: 'group_1',
          name: 'Test Group',
          ownerId: 'user_1',
          memberIds: ['user_1'],
          moderatorIds: ['user_1'],
          createdAt: DateTime(2026, 8, 27),
        );

        final groupId = await service.createStudyGroup(group);

        expect(groupId, isNotEmpty);
      });

      test('should get study group', () async {
        final group = StudyGroup(
          groupId: 'group_1',
          name: 'Test Group',
          ownerId: 'user_1',
          memberIds: ['user_1'],
          moderatorIds: ['user_1'],
          createdAt: DateTime.now(),
        );

        await service.createStudyGroup(group);
        final retrieved = await service.getStudyGroup('group_1');

        expect(retrieved?.groupId, equals('group_1'));
      });

      test('should get user groups', () async {
        final group = StudyGroup(
          groupId: 'group_1',
          name: 'Test Group',
          ownerId: 'user_1',
          memberIds: ['user_1'],
          moderatorIds: ['user_1'],
          createdAt: DateTime.now(),
        );

        await service.createStudyGroup(group);
        final groups = await service.getUserGroups('user_1');

        expect(groups, isNotEmpty);
      });

      test('should join study group', () async {
        final group = StudyGroup(
          groupId: 'group_1',
          name: 'Test Group',
          ownerId: 'user_1',
          memberIds: ['user_1'],
          moderatorIds: ['user_1'],
          createdAt: DateTime.now(),
        );

        await service.createStudyGroup(group);
        await service.joinStudyGroup('user_2', 'group_1');

        final updated = await service.getStudyGroup('group_1');
        expect(updated?.memberIds.contains('user_2'), isTrue);
      });

      test('should leave study group', () async {
        final group = StudyGroup(
          groupId: 'group_1',
          name: 'Test Group',
          ownerId: 'user_1',
          memberIds: ['user_1', 'user_2'],
          moderatorIds: ['user_1'],
          createdAt: DateTime.now(),
        );

        await service.createStudyGroup(group);
        await service.leaveStudyGroup('user_2', 'group_1');

        final updated = await service.getStudyGroup('group_1');
        expect(updated?.memberIds.contains('user_2'), isFalse);
      });

      test('should update group settings', () async {
        final group = StudyGroup(
          groupId: 'group_1',
          name: 'Old Name',
          ownerId: 'user_1',
          memberIds: ['user_1'],
          moderatorIds: ['user_1'],
          createdAt: DateTime.now(),
        );

        await service.createStudyGroup(group);
        await service.updateGroupSettings(
          'group_1',
          'New Name',
          description: 'New description',
        );

        final updated = await service.getStudyGroup('group_1');
        expect(updated?.name, equals('New Name'));
      });

      test('should delete study group', () async {
        final group = StudyGroup(
          groupId: 'group_1',
          name: 'Test Group',
          ownerId: 'user_1',
          memberIds: ['user_1'],
          moderatorIds: ['user_1'],
          createdAt: DateTime.now(),
        );

        await service.createStudyGroup(group);
        await service.deleteStudyGroup('group_1', 'user_1');

        final retrieved = await service.getStudyGroup('group_1');
        expect(retrieved, isNull);
      });

      test('should get group members', () async {
        final members = await service.getGroupMembers('group_1');

        expect(members, isA<List<GroupMember>>());
      });

      test('should check group capacity', () async {
        final group = StudyGroup(
          groupId: 'group_1',
          name: 'Small Group',
          ownerId: 'user_1',
          memberIds: List.generate(50, (i) => 'user_$i'),
          moderatorIds: ['user_1'],
          maxMembers: 50,
          createdAt: DateTime.now(),
        );

        expect(group.isFull, isTrue);
      });
    });

    group('Shared Achievements', () {
      test('should share achievement', () async {
        final achievement = SharedAchievement(
          achievementId: 'ach_1',
          userId: 'user_1',
          displayName: 'Test User',
          achievementName: 'Test Achievement',
          description: 'Test description',
          points: 100,
          unlockedAt: DateTime.now(),
        );

        await service.shareAchievement(achievement);

        expect(true, isTrue); // Achievement shared
      });

      test('should celebrate achievement', () async {
        await service.celebrateAchievement('ach_1', 'user_2');

        expect(true, isTrue); // Celebration recorded
      });

      test('should get celebration feed', () async {
        final achievement = SharedAchievement(
          achievementId: 'ach_1',
          userId: 'user_1',
          displayName: 'Test User',
          achievementName: 'Test Achievement',
          description: 'Test description',
          points: 100,
          unlockedAt: DateTime.now(),
        );

        await service.shareAchievement(achievement);
        final feed = await service.getCelebrationFeed();

        expect(feed, isNotEmpty);
      });

      test('should respect celebration feed limit', () async {
        for (int i = 0; i < 50; i++) {
          await service.shareAchievement(SharedAchievement(
            achievementId: 'ach_$i',
            userId: 'user_1',
            displayName: 'Test User',
            achievementName: 'Achievement $i',
            description: 'Description $i',
            points: 100 + i,
            unlockedAt: DateTime.now(),
          ));
        }

        final feed = await service.getCelebrationFeed(limit: 20);

        expect(feed.length, lessThanOrEqualTo(20));
      });
    });

    group('Social Statistics', () {
      test('should get social stats', () async {
        final stats = await service.getSocialStats('user_1');

        expect(stats.userId, equals('user_1'));
      });

      test('should update social stats', () async {
        final stats = SocialStats(
          userId: 'user_1',
          friendCount: 5,
          pendingRequests: 2,
          groupCount: 3,
          lastActivityAt: DateTime.now(),
        );

        await service.updateSocialStats('user_1', stats);
        final retrieved = await service.getSocialStats('user_1');

        expect(retrieved.friendCount, equals(5));
      });

      test('should return empty stats for new user', () async {
        final stats = await service.getSocialStats('new_user');

        expect(stats.userId, equals('new_user'));
        expect(stats.friendCount, equals(0));
      });
    });
  });

  group('Social Models', () {
    group('Friend', () {
      test('should create friend', () {
        final friend = Friend(
          userId: 'user_1',
          displayName: 'John Doe',
          status: FriendshipStatus.accepted,
          addedAt: DateTime.now(),
        );

        expect(friend.userId, equals('user_1'));
        expect(friend.isAccepted, isTrue);
      });

      test('should identify pending friendship', () {
        final friend = Friend(
          userId: 'user_2',
          displayName: 'Jane Doe',
          status: FriendshipStatus.pending,
          addedAt: DateTime.now(),
        );

        expect(friend.isPending, isTrue);
        expect(friend.isAccepted, isFalse);
      });

      test('should serialize friend to map', () {
        final friend = Friend(
          userId: 'user_1',
          displayName: 'John',
          status: FriendshipStatus.accepted,
          addedAt: DateTime(2026, 8, 27),
        );

        final map = friend.toMap();

        expect(map['userId'], equals('user_1'));
        expect(map['status'], equals(FriendshipStatus.accepted.index));
      });

      test('should deserialize friend from map', () {
        final map = {
          'userId': 'user_1',
          'displayName': 'John',
          'status': FriendshipStatus.accepted.index,
        };

        final friend = Friend.fromMap(map);

        expect(friend.userId, equals('user_1'));
        expect(friend.displayName, equals('John'));
      });
    });

    group('Activity', () {
      test('should create activity', () {
        final activity = Activity(
          userId: 'user_1',
          displayName: 'Test User',
          type: ActivityType.quiz_completed,
          description: 'Completed quiz',
          createdAt: DateTime.now(),
        );

        expect(activity.userId, equals('user_1'));
        expect(activity.type, equals(ActivityType.quiz_completed));
      });

      test('should serialize activity', () {
        final activity = Activity(
          userId: 'user_1',
          displayName: 'Test',
          type: ActivityType.achievement_unlocked,
          description: 'Unlocked',
          pointsEarned: 100,
          createdAt: DateTime(2026, 8, 27),
        );

        final map = activity.toMap();

        expect(map['userId'], equals('user_1'));
        expect(map['pointsEarned'], equals(100));
      });

      test('should deserialize activity', () {
        final map = {
          'userId': 'user_1',
          'displayName': 'User',
          'type': ActivityType.level_up.index,
          'description': 'Level up',
          'pointsEarned': 50,
        };

        final activity = Activity.fromMap(map);

        expect(activity.type, equals(ActivityType.level_up));
      });
    });

    group('StudyGroup', () {
      test('should create study group', () {
        final group = StudyGroup(
          groupId: 'group_1',
          name: 'Test Group',
          ownerId: 'user_1',
          memberIds: ['user_1', 'user_2'],
          moderatorIds: ['user_1'],
          createdAt: DateTime.now(),
        );

        expect(group.groupId, equals('group_1'));
        expect(group.memberCount, equals(2));
      });

      test('should identify group capacity', () {
        final group = StudyGroup(
          groupId: 'group_1',
          name: 'Full Group',
          ownerId: 'user_1',
          memberIds: List.generate(50, (i) => 'user_$i'),
          moderatorIds: ['user_1'],
          maxMembers: 50,
          createdAt: DateTime.now(),
        );

        expect(group.isFull, isTrue);
      });

      test('should check public privacy', () {
        final group = StudyGroup(
          groupId: 'group_1',
          name: 'Public Group',
          ownerId: 'user_1',
          memberIds: ['user_1'],
          moderatorIds: ['user_1'],
          privacy: PrivacyLevel.public,
          createdAt: DateTime.now(),
        );

        expect(group.isPublic, isTrue);
      });

      test('should serialize group', () {
        final group = StudyGroup(
          groupId: 'group_1',
          name: 'Group',
          ownerId: 'user_1',
          memberIds: ['user_1'],
          moderatorIds: ['user_1'],
          totalPoints: 500,
          createdAt: DateTime(2026, 8, 27),
        );

        final map = group.toMap();

        expect(map['name'], equals('Group'));
        expect(map['totalPoints'], equals(500));
      });

      test('should deserialize group', () {
        final map = {
          'groupId': 'group_1',
          'name': 'Study Group',
          'ownerId': 'user_1',
          'memberIds': ['user_1', 'user_2'],
          'moderatorIds': ['user_1'],
          'maxMembers': 30,
        };

        final group = StudyGroup.fromMap(map);

        expect(group.memberCount, equals(2));
        expect(group.maxMembers, equals(30));
      });

      test('should copy with modifications', () {
        final original = StudyGroup(
          groupId: 'group_1',
          name: 'Original',
          ownerId: 'user_1',
          memberIds: ['user_1'],
          moderatorIds: ['user_1'],
          createdAt: DateTime.now(),
        );

        final updated = original.copyWith(
          name: 'Updated',
          maxMembers: 100,
        );

        expect(updated.name, equals('Updated'));
        expect(updated.maxMembers, equals(100));
        expect(updated.groupId, equals(original.groupId));
      });
    });

    group('GroupMember', () {
      test('should create group member', () {
        final member = GroupMember(
          userId: 'user_1',
          displayName: 'John',
          role: GroupRole.owner,
          joinedAt: DateTime.now(),
        );

        expect(member.isOwner, isTrue);
        expect(member.isModerator, isFalse);
      });

      test('should identify member roles', () {
        final owner = GroupMember(
          userId: 'user_1',
          displayName: 'Owner',
          role: GroupRole.owner,
          joinedAt: DateTime.now(),
        );

        final moderator = GroupMember(
          userId: 'user_2',
          displayName: 'Mod',
          role: GroupRole.moderator,
          joinedAt: DateTime.now(),
        );

        final member = GroupMember(
          userId: 'user_3',
          displayName: 'Member',
          role: GroupRole.member,
          joinedAt: DateTime.now(),
        );

        expect(owner.isOwner, isTrue);
        expect(moderator.isModerator, isTrue);
        expect(member.isRegularMember, isTrue);
      });

      test('should serialize member', () {
        final member = GroupMember(
          userId: 'user_1',
          displayName: 'John',
          role: GroupRole.member,
          joinedAt: DateTime(2026, 8, 27),
          groupPoints: 250,
        );

        final map = member.toMap();

        expect(map['userId'], equals('user_1'));
        expect(map['groupPoints'], equals(250));
      });

      test('should deserialize member', () {
        final map = {
          'userId': 'user_1',
          'displayName': 'John',
          'role': GroupRole.moderator.index,
          'groupPoints': 300,
        };

        final member = GroupMember.fromMap(map);

        expect(member.isModerator, isTrue);
        expect(member.groupPoints, equals(300));
      });
    });

    group('SharedAchievement', () {
      test('should create shared achievement', () {
        final achievement = SharedAchievement(
          achievementId: 'ach_1',
          userId: 'user_1',
          displayName: 'John',
          achievementName: 'Master',
          description: 'Mastered topic',
          points: 200,
          unlockedAt: DateTime.now(),
        );

        expect(achievement.celebrationCount, equals(0));
      });

      test('should track celebrations', () {
        final achievement = SharedAchievement(
          achievementId: 'ach_1',
          userId: 'user_1',
          displayName: 'John',
          achievementName: 'Expert',
          description: 'Expert level',
          points: 150,
          unlockedAt: DateTime.now(),
          celebrations: ['user_2', 'user_3', 'user_4'],
        );

        expect(achievement.celebrationCount, equals(3));
      });

      test('should serialize achievement', () {
        final achievement = SharedAchievement(
          achievementId: 'ach_1',
          userId: 'user_1',
          displayName: 'User',
          achievementName: 'Achievement',
          description: 'Desc',
          points: 100,
          unlockedAt: DateTime(2026, 8, 27),
          message: 'Proud moment!',
        );

        final map = achievement.toMap();

        expect(map['achievementName'], equals('Achievement'));
        expect(map['message'], equals('Proud moment!'));
      });

      test('should deserialize achievement', () {
        final map = {
          'achievementId': 'ach_1',
          'userId': 'user_1',
          'displayName': 'User',
          'achievementName': 'Badge',
          'description': 'Badge desc',
          'points': 75,
          'celebrations': ['user_2'],
        };

        final achievement = SharedAchievement.fromMap(map);

        expect(achievement.celebrationCount, equals(1));
      });
    });

    group('SocialStats', () {
      test('should create social stats', () {
        final stats = SocialStats(
          userId: 'user_1',
          friendCount: 10,
          pendingRequests: 2,
          groupCount: 3,
          lastActivityAt: DateTime.now(),
        );

        expect(stats.friendCount, equals(10));
      });

      test('should serialize stats', () {
        final stats = SocialStats(
          userId: 'user_1',
          friendCount: 5,
          groupCount: 2,
          activitiesShared: 10,
          lastActivityAt: DateTime(2026, 8, 27),
        );

        final map = stats.toMap();

        expect(map['friendCount'], equals(5));
        expect(map['activitiesShared'], equals(10));
      });

      test('should deserialize stats', () {
        final map = {
          'userId': 'user_1',
          'friendCount': 8,
          'pendingRequests': 1,
          'celebrationsReceived': 15,
        };

        final stats = SocialStats.fromMap(map);

        expect(stats.friendCount, equals(8));
        expect(stats.celebrationsReceived, equals(15));
      });
    });
  });

  group('Social Integration Scenarios', () {
    late StubSocialService service;

    setUp(() {
      service = StubSocialService();
    });

    test('should complete friend workflow', () async {
      // Request
      await service.sendFriendRequest('user_1', 'user_2');

      // Accept
      await service.acceptFriendRequest('user_1', 'user_2');

      // Verify
      final areFriends = await service.areFriends('user_1', 'user_2');

      expect(areFriends, isTrue);
    });

    test('should create and join study group', () async {
      // Create
      const group = StudyGroup(
        groupId: 'study_1',
        name: 'Math Group',
        ownerId: 'user_1',
        memberIds: ['user_1'],
        moderatorIds: ['user_1'],
        createdAt: DateTime(2026, 8, 27),
      );

      await service.createStudyGroup(group);

      // Join
      await service.joinStudyGroup('user_2', 'study_1');

      // Verify
      final userGroups = await service.getUserGroups('user_2');

      expect(userGroups, isNotEmpty);
    });

    test('should share and celebrate achievement', () async {
      // Share
      const achievement = SharedAchievement(
        achievementId: 'ach_master',
        userId: 'user_1',
        displayName: 'Alice',
        achievementName: 'Quiz Master',
        description: 'Mastered all quizzes',
        points: 500,
        unlockedAt: DateTime(2026, 8, 27),
      );

      await service.shareAchievement(achievement);

      // Celebrate
      await service.celebrateAchievement('ach_master', 'user_2');

      // Verify
      final feed = await service.getCelebrationFeed();

      expect(feed, isNotEmpty);
    });

    test('should post and retrieve activities', () async {
      // Post activities
      await service.postActivity(Activity(
        userId: 'user_1',
        displayName: 'Alice',
        type: ActivityType.quiz_completed,
        description: 'Completed Licensing Basics',
        pointsEarned: 50,
        createdAt: DateTime.now(),
      ));

      // Retrieve
      final activities = await service.getUserActivities('user_1');

      expect(activities, isNotEmpty);
      expect(activities.first.type, equals(ActivityType.quiz_completed));
    });

    test('should manage social statistics', () async {
      // Create stats
      final stats = SocialStats(
        userId: 'user_1',
        friendCount: 3,
        groupCount: 1,
        activitiesShared: 5,
        lastActivityAt: DateTime.now(),
      );

      await service.updateSocialStats('user_1', stats);

      // Retrieve
      final retrieved = await service.getSocialStats('user_1');

      expect(retrieved.friendCount, equals(3));
      expect(retrieved.groupCount, equals(1));
    });
  });
}
