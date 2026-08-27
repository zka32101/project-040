import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/community_model.dart';
import 'package:project_040/services/community_service.dart';

void main() {
  late CommunityService service;

  setUp(() {
    service = StubCommunityService();
  });

  group('Channel Management', () {
    test('create community channel', () async {
      final channelId = await service.createChannel(
        name: 'Bike Maintenance',
        ownerId: 'user1',
        description: 'Tips and tricks for bike maintenance',
        type: ChannelType.public,
        category: 'Maintenance',
      );

      expect(channelId, isNotEmpty);
      final channel = await service.getChannel(channelId);
      expect(channel, isNotNull);
      expect(channel!.name, 'Bike Maintenance');
      expect(channel.ownerId, 'user1');
      expect(channel.isPublic, true);
    });

    test('get channel by id', () async {
      final channelId = await service.createChannel(
        name: 'Routes',
        ownerId: 'user1',
        description: 'Popular bike routes',
        type: ChannelType.public,
      );

      final channel = await service.getChannel(channelId);
      expect(channel!.channelId, channelId);
      expect(channel.name, 'Routes');
    });

    test('get channels by category', () async {
      await service.createChannel(
        name: 'Maintenance Tips',
        ownerId: 'user1',
        description: 'Maintenance discussions',
        type: ChannelType.public,
        category: 'Maintenance',
      );

      await service.createChannel(
        name: 'Chain Care',
        ownerId: 'user2',
        description: 'Chain maintenance',
        type: ChannelType.public,
        category: 'Maintenance',
      );

      await service.createChannel(
        name: 'Best Routes',
        ownerId: 'user1',
        description: 'Route discussions',
        type: ChannelType.public,
        category: 'Routes',
      );

      final maintenanceChannels =
          await service.getChannelsByCategory('Maintenance');
      expect(maintenanceChannels, hasLength(2));
      expect(
          maintenanceChannels.every((c) => c.category == 'Maintenance'), true);
    });

    test('search channels', () async {
      await service.createChannel(
        name: 'Bike Maintenance',
        ownerId: 'user1',
        description: 'Maintenance tips',
        type: ChannelType.public,
      );

      await service.createChannel(
        name: 'Urban Cycling',
        ownerId: 'user2',
        description: 'City bike discussions',
        type: ChannelType.public,
      );

      final results = await service.searchChannels('Maintenance');
      expect(results, isNotEmpty);
      expect(results[0].name, contains('Maintenance'));
    });

    test('get public channels', () async {
      await service.createChannel(
        name: 'Public Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.createChannel(
        name: 'Private Channel',
        ownerId: 'user2',
        type: ChannelType.private,
      );

      final publicChannels = await service.getPublicChannels();
      expect(publicChannels.every((c) => c.isPublic), true);
    });

    test('archive channel', () async {
      final channelId = await service.createChannel(
        name: 'Old Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.archiveChannel(channelId);

      final channel = await service.getChannel(channelId);
      expect(channel!.isArchived, true);
    });

    test('update channel', () async {
      final channelId = await service.createChannel(
        name: 'Original Name',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final channel = await service.getChannel(channelId);
      final updated = channel!.copyWith(name: 'Updated Name');
      await service.updateChannel(channelId, updated);

      final updatedChannel = await service.getChannel(channelId);
      expect(updatedChannel!.name, 'Updated Name');
    });
  });

  group('Member Management', () {
    test('add member to channel', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final memberId = await service.addMemberToChannel(
        channelId: channelId,
        userId: 'user2',
        role: MemberRole.member,
      );

      expect(memberId, isNotEmpty);
      final member = await service.getChannelMember(channelId, 'user2');
      expect(member, isNotNull);
      expect(member!.userId, 'user2');
    });

    test('get channel members', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'user2',
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'user3',
      );

      final members = await service.getChannelMembers(channelId);
      expect(members, isNotEmpty);
      expect(members.any((m) => m.userId == 'user2'), true);
    });

    test('get channel moderators', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'user2',
        role: MemberRole.moderator,
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'user3',
        role: MemberRole.member,
      );

      final moderators = await service.getChannelModerators(channelId);
      expect(moderators.length, greaterThanOrEqualTo(1));
      expect(moderators.any((m) => m.userId == 'user2'), true);
    });

    test('update member role', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'user2',
        role: MemberRole.member,
      );

      await service.updateMemberRole(
        channelId: channelId,
        userId: 'user2',
        newRole: MemberRole.moderator,
      );

      final member = await service.getChannelMember(channelId, 'user2');
      expect(member!.isModerator, true);
    });

    test('remove member from channel', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'user2',
      );

      await service.removeMemberFromChannel(channelId, 'user2');

      final member = await service.getChannelMember(channelId, 'user2');
      expect(member, isNull);
    });

    test('mute and unmute channel member', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'user2',
      );

      await service.muteChannelMember(
        channelId: channelId,
        userId: 'user2',
      );

      var member = await service.getChannelMember(channelId, 'user2');
      expect(member!.isMuted, true);

      await service.unmuteChannelMember(
        channelId: channelId,
        userId: 'user2',
      );

      member = await service.getChannelMember(channelId, 'user2');
      expect(member!.isMuted, false);
    });

    test('ban and unban channel member', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'user2',
      );

      await service.banChannelMember(
        channelId: channelId,
        userId: 'user2',
        reason: 'Spam',
      );

      var member = await service.getChannelMember(channelId, 'user2');
      expect(member!.isBanned, true);
      expect(member.banReason, 'Spam');

      await service.unbanChannelMember(channelId, 'user2');

      member = await service.getChannelMember(channelId, 'user2');
      expect(member!.isBanned, false);
    });
  });

  group('Post Management', () {
    test('create channel post', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        authorName: 'User One',
        content: 'This is a great tip for bike maintenance!',
      );

      expect(postId, isNotEmpty);
      final post = await service.getPost(postId);
      expect(post, isNotNull);
      expect(post!.content, contains('bike maintenance'));
    });

    test('get channel posts', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'First post',
      );

      await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Second post',
      );

      final posts = await service.getChannelPosts(channelId);
      expect(posts, hasLength(2));
    });

    test('update post', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Original content',
      );

      await service.updatePost(
        postId: postId,
        content: 'Updated content',
      );

      final post = await service.getPost(postId);
      expect(post!.updatedAt, isNotNull);
    });

    test('publish and delete posts', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Test post',
      );

      await service.deletePost(postId);

      final post = await service.getPost(postId);
      expect(post!.status, PostStatus.archived);
    });

    test('pin and unpin posts', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Important post',
      );

      await service.pinPost(postId: postId, position: 1);

      var post = await service.getPost(postId);
      expect(post!.isPinned, true);

      await service.unpinPost(postId);

      post = await service.getPost(postId);
      expect(post!.isPinned, false);
    });

    test('get pinned posts', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId1 = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Pinned post 1',
      );

      final postId2 = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Regular post',
      );

      await service.pinPost(postId: postId1, position: 1);

      final pinnedPosts = await service.getPinnedPosts(channelId);
      expect(pinnedPosts, isNotEmpty);
      expect(pinnedPosts.any((p) => p.isPinned), true);
    });

    test('like and unlike posts', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Test post',
      );

      await service.likePost(postId, 'user2');
      await service.likePost(postId, 'user3');

      var post = await service.getPost(postId);
      expect(post!.likes, 2);
      expect(post.likedBy, contains('user2'));

      await service.unlikePost(postId, 'user2');

      post = await service.getPost(postId);
      expect(post!.likes, 1);
    });

    test('increment post views', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Test post',
      );

      await service.incrementPostViews(postId);
      await service.incrementPostViews(postId);

      final post = await service.getPost(postId);
      expect(post!.views, 2);
    });

    test('search posts', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'How to fix a flat tire',
      );

      await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Best bike gear for beginners',
      );

      final results = await service.searchPosts(
        channelId: channelId,
        query: 'tire',
      );

      expect(results, isNotEmpty);
      expect(results[0].content, contains('tire'));
    });
  });

  group('Reply Management', () {
    test('create post reply', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Original post',
      );

      final replyId = await service.createReply(
        postId: postId,
        channelId: channelId,
        authorId: 'user2',
        authorName: 'User Two',
        content: 'Great tip!',
      );

      expect(replyId, isNotEmpty);
      final reply = await service.getReply(replyId);
      expect(reply, isNotNull);
      expect(reply!.content, 'Great tip!');
    });

    test('get post replies', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Original post',
      );

      await service.createReply(
        postId: postId,
        channelId: channelId,
        authorId: 'user2',
        content: 'Reply 1',
      );

      await service.createReply(
        postId: postId,
        channelId: channelId,
        authorId: 'user3',
        content: 'Reply 2',
      );

      final replies = await service.getPostReplies(postId);
      expect(replies, hasLength(2));
    });

    test('update reply', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Original post',
      );

      final replyId = await service.createReply(
        postId: postId,
        channelId: channelId,
        authorId: 'user2',
        content: 'Original reply',
      );

      await service.updateReply(
        replyId: replyId,
        content: 'Updated reply',
      );

      final reply = await service.getReply(replyId);
      expect(reply!.updatedAt, isNotNull);
    });

    test('delete reply', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Original post',
      );

      final replyId = await service.createReply(
        postId: postId,
        channelId: channelId,
        authorId: 'user2',
        content: 'Reply to delete',
      );

      await service.deleteReply(replyId);

      var post = await service.getPost(postId);
      expect(post!.replies, 0);
    });

    test('like and unlike replies', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Original post',
      );

      final replyId = await service.createReply(
        postId: postId,
        channelId: channelId,
        authorId: 'user2',
        content: 'Reply',
      );

      await service.likeReply(replyId, 'user3');
      await service.likeReply(replyId, 'user4');

      var reply = await service.getReply(replyId);
      expect(reply!.likes, 2);

      await service.unlikeReply(replyId, 'user3');

      reply = await service.getReply(replyId);
      expect(reply!.likes, 1);
    });

    test('search replies', () async {
      await service.searchReplies(query: 'maintenance');
      // Search works across all replies
    });
  });

  group('Moderation', () {
    test('create moderation record', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final recordId = await service.createModerationRecord(
        channelId: channelId,
        targetUserId: 'user2',
        actionBy: 'user1',
        action: ModerationAction.warning,
        reason: 'Inappropriate content',
      );

      expect(recordId, isNotEmpty);
      final record = await service.getModerationRecord(recordId);
      expect(record, isNotNull);
      expect(record!.action, ModerationAction.warning);
    });

    test('get channel moderation records', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.createModerationRecord(
        channelId: channelId,
        targetUserId: 'user2',
        actionBy: 'user1',
        action: ModerationAction.warning,
      );

      await service.createModerationRecord(
        channelId: channelId,
        targetUserId: 'user3',
        actionBy: 'user1',
        action: ModerationAction.mute,
      );

      final records = await service.getChannelModerationRecords(channelId);
      expect(records, hasLength(2));
    });

    test('get user moderation records', () async {
      final channelId1 = await service.createChannel(
        name: 'Channel 1',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final channelId2 = await service.createChannel(
        name: 'Channel 2',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.createModerationRecord(
        channelId: channelId1,
        targetUserId: 'user2',
        actionBy: 'user1',
        action: ModerationAction.warning,
      );

      await service.createModerationRecord(
        channelId: channelId2,
        targetUserId: 'user2',
        actionBy: 'user1',
        action: ModerationAction.ban,
      );

      final records = await service.getUserModerationRecords('user2');
      expect(records, hasLength(2));
    });

    test('close moderation record', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final recordId = await service.createModerationRecord(
        channelId: channelId,
        targetUserId: 'user2',
        actionBy: 'user1',
        action: ModerationAction.warning,
      );

      await service.closeModerationRecord(recordId);

      final record = await service.getModerationRecord(recordId);
      expect(record!.isActive, false);
    });
  });

  group('Statistics', () {
    test('get channel stats', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'user2',
      );

      await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Test post',
      );

      final stats = await service.getChannelStats(channelId);
      expect(stats, isNotNull);
      expect(stats!.totalMembers, greaterThan(0));
      expect(stats.totalPosts, greaterThan(0));
    });

    test('get total channels count', () async {
      await service.createChannel(
        name: 'Channel 1',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.createChannel(
        name: 'Channel 2',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final count = await service.getTotalChannelsCount();
      expect(count, greaterThanOrEqualTo(2));
    });

    test('get channel members count', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'user2',
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'user3',
      );

      final count = await service.getChannelMembersCount(channelId);
      expect(count, greaterThanOrEqualTo(2));
    });

    test('get channel posts count', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Post 1',
      );

      await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Post 2',
      );

      final count = await service.getChannelPostsCount(channelId);
      expect(count, greaterThanOrEqualTo(2));
    });
  });

  group('Models', () {
    test('CommunityChannel serialization', () {
      final channel = CommunityChannel(
        channelId: 'ch1',
        name: 'Test Channel',
        type: ChannelType.public,
        ownerId: 'user1',
        createdAt: DateTime.now(),
      );

      final map = channel.toMap();
      final restored = CommunityChannel.fromMap(map);

      expect(restored.channelId, channel.channelId);
      expect(restored.name, channel.name);
      expect(restored.isPublic, true);
    });

    test('ChannelPost serialization', () {
      final post = ChannelPost(
        postId: 'post1',
        channelId: 'ch1',
        authorId: 'user1',
        content: 'Test content',
        createdAt: DateTime.now(),
      );

      final map = post.toMap();
      final restored = ChannelPost.fromMap(map);

      expect(restored.postId, post.postId);
      expect(restored.content, post.content);
      expect(restored.isPublished, true);
    });

    test('ChannelMember serialization', () {
      final member = ChannelMember(
        memberId: 'mem1',
        channelId: 'ch1',
        userId: 'user1',
        role: MemberRole.moderator,
        joinedAt: DateTime.now(),
      );

      final map = member.toMap();
      final restored = ChannelMember.fromMap(map);

      expect(restored.memberId, member.memberId);
      expect(restored.isModerator, true);
    });

    test('PostReply serialization', () {
      final reply = PostReply(
        replyId: 'reply1',
        postId: 'post1',
        channelId: 'ch1',
        authorId: 'user1',
        content: 'Great post!',
        createdAt: DateTime.now(),
      );

      final map = reply.toMap();
      final restored = PostReply.fromMap(map);

      expect(restored.replyId, reply.replyId);
      expect(restored.content, reply.content);
    });

    test('ModerationRecord serialization', () {
      final record = ModerationRecord(
        recordId: 'rec1',
        channelId: 'ch1',
        targetUserId: 'user2',
        actionBy: 'user1',
        action: ModerationAction.ban,
        reason: 'Spam',
        createdAt: DateTime.now(),
      );

      final map = record.toMap();
      final restored = ModerationRecord.fromMap(map);

      expect(restored.recordId, record.recordId);
      expect(restored.isBan, true);
    });

    test('ChannelStats serialization', () {
      final stats = ChannelStats(
        statsId: 'stats1',
        channelId: 'ch1',
        totalMembers: 10,
        totalPosts: 50,
        updatedAt: DateTime.now(),
      );

      final map = stats.toMap();
      final restored = ChannelStats.fromMap(map);

      expect(restored.statsId, stats.statsId);
      expect(restored.totalMembers, 10);
    });
  });

  group('Integration Tests', () {
    test('complete channel workflow', () async {
      // Create channel
      final channelId = await service.createChannel(
        name: 'Bike Maintenance Tips',
        ownerId: 'user1',
        description: 'Share and discuss bike maintenance tips',
        type: ChannelType.public,
        category: 'Maintenance',
      );

      // Add members
      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'user2',
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'user3',
      );

      // Create post
      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        authorName: 'Expert',
        content: 'How to replace your chain',
      );

      // Add replies
      final replyId1 = await service.createReply(
        postId: postId,
        channelId: channelId,
        authorId: 'user2',
        content: 'Great tip! Does this work for all bikes?',
      );

      final replyId2 = await service.createReply(
        postId: postId,
        channelId: channelId,
        authorId: 'user3',
        content: 'Thanks for sharing!',
      );

      // Like post
      await service.likePost(postId, 'user2');
      await service.likePost(postId, 'user3');

      // Pin post
      await service.pinPost(postId: postId, position: 1);

      // Verify final state
      final channel = await service.getChannel(channelId);
      expect(channel!.memberCount, greaterThan(1));

      final post = await service.getPost(postId);
      expect(post!.isPinned, true);
      expect(post.likes, 2);

      final replies = await service.getPostReplies(postId);
      expect(replies, hasLength(2));
    });

    test('complete moderation workflow', () async {
      final channelId = await service.createChannel(
        name: 'Community Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'user2',
      );

      // Create moderation record
      final recordId = await service.createModerationRecord(
        channelId: channelId,
        targetUserId: 'user2',
        actionBy: 'user1',
        action: ModerationAction.mute,
        reason: 'Spam',
      );

      // Mute member
      await service.muteChannelMember(
        channelId: channelId,
        userId: 'user2',
      );

      // Verify moderation applied
      var member = await service.getChannelMember(channelId, 'user2');
      expect(member!.isMuted, true);

      // Close moderation record
      await service.closeModerationRecord(recordId);

      var record = await service.getModerationRecord(recordId);
      expect(record!.isActive, false);
    });
  });

  // ============ MENTION TESTS (Phase 11 Step 2) ============
  group('Mention Management (Phase 11 Step 2)', () {
    late CommunityService service;

    setUp(() {
      service = StubCommunityService();
    });

    test('extract mentions from content', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'john_cyclist',
      );

      final mentions = await service.extractMentions(
        'Hey @john_cyclist check this out!',
        channelId: channelId,
      );

      expect(mentions, hasLength(1));
      expect(mentions[0].mentionedUsername, 'john_cyclist');
    });

    test('extract multiple mentions from content', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'john_cyclist',
      );
      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'jane_rider',
      );

      final mentions = await service.extractMentions(
        '@john_cyclist and @jane_rider, check this!',
        channelId: channelId,
      );

      expect(mentions, hasLength(2));
    });

    test('prevent duplicate mentions in same content', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'john_cyclist',
      );

      final mentions = await service.extractMentions(
        '@john_cyclist @john_cyclist check this!',
        channelId: channelId,
      );

      expect(mentions, hasLength(1));
    });

    test('create mention record', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final mentionId = await service.createMention(
        mentionedUserId: 'john_cyclist',
        mentionedUsername: 'john_cyclist',
        channelId: channelId,
        authorId: 'user1',
        authorName: 'User 1',
      );

      expect(mentionId, isNotEmpty);
    });

    test('get mentions for user', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.createMention(
        mentionedUserId: 'john_cyclist',
        mentionedUsername: 'john_cyclist',
        channelId: channelId,
        authorId: 'user1',
      );

      final mentions = await service.getUserMentions('john_cyclist');
      expect(mentions, hasLength(1));
    });

    test('validate mention in channel', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'john_cyclist',
      );

      final isValid = await service.validateMention(
        'john_cyclist',
        channelId: channelId,
      );

      expect(isValid, true);
    });

    test('get mentionable users in channel', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'john_cyclist',
      );
      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'jane_rider',
      );

      final users = await service.getMentionableCommunityUsers(channelId);

      expect(users.length, greaterThan(0));
    });

    test('get mention count for user', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.createMention(
        mentionedUserId: 'john_cyclist',
        mentionedUsername: 'john_cyclist',
        channelId: channelId,
        authorId: 'user1',
      );

      await service.createMention(
        mentionedUserId: 'john_cyclist',
        mentionedUsername: 'john_cyclist',
        channelId: channelId,
        authorId: 'user2',
      );

      final count = await service.getMentionCount('john_cyclist');
      expect(count, 2);
    });
  });

  // ============ NOTIFICATION TESTS (Phase 11 Step 2) ============
  group('Notification Management (Phase 11 Step 2)', () {
    late CommunityService service;

    setUp(() {
      service = StubCommunityService();
    });

    test('create notification for user', () async {
      final notificationId = await service.createNotification(
        userId: 'user1',
        type: NotificationType.mention,
        title: 'New Mention',
        description: 'You were mentioned in a post',
        relatedId: 'post1',
        relatedType: 'post',
      );

      expect(notificationId, isNotEmpty);
    });

    test('get user notifications', () async {
      await service.createNotification(
        userId: 'user1',
        type: NotificationType.mention,
        title: 'New Mention',
        description: 'You were mentioned',
        relatedId: 'post1',
        relatedType: 'post',
      );

      final notifications = await service.getUserNotifications('user1');
      expect(notifications, hasLength(1));
    });

    test('get unread notifications only', () async {
      final notifId = await service.createNotification(
        userId: 'user1',
        type: NotificationType.mention,
        title: 'New Mention',
        description: 'You were mentioned',
        relatedId: 'post1',
        relatedType: 'post',
      );

      await service.markNotificationAsRead(notifId);

      final unreadNotifs = await service.getUserNotifications(
        'user1',
        unreadOnly: true,
      );

      expect(unreadNotifs, isEmpty);
    });

    test('mark notification as read', () async {
      final notifId = await service.createNotification(
        userId: 'user1',
        type: NotificationType.mention,
        title: 'New Mention',
        description: 'You were mentioned',
        relatedId: 'post1',
        relatedType: 'post',
      );

      await service.markNotificationAsRead(notifId);

      final notif = await service.getNotification(notifId);
      expect(notif!.isRead, true);
    });

    test('mark all notifications as read', () async {
      await service.createNotification(
        userId: 'user1',
        type: NotificationType.mention,
        title: 'Mention 1',
        description: 'You were mentioned',
        relatedId: 'post1',
        relatedType: 'post',
      );

      await service.createNotification(
        userId: 'user1',
        type: NotificationType.reply,
        title: 'New Reply',
        description: 'Someone replied',
        relatedId: 'post2',
        relatedType: 'post',
      );

      await service.markAllNotificationsAsRead('user1');

      final notifs = await service.getUserNotifications(
        'user1',
        unreadOnly: true,
      );

      expect(notifs, isEmpty);
    });

    test('delete notification', () async {
      final notifId = await service.createNotification(
        userId: 'user1',
        type: NotificationType.mention,
        title: 'New Mention',
        description: 'You were mentioned',
        relatedId: 'post1',
        relatedType: 'post',
      );

      await service.deleteNotification(notifId);

      final notif = await service.getNotification(notifId);
      expect(notif, isNull);
    });

    test('get unread count', () async {
      await service.createNotification(
        userId: 'user1',
        type: NotificationType.mention,
        title: 'Mention 1',
        description: 'You were mentioned',
        relatedId: 'post1',
        relatedType: 'post',
      );

      await service.createNotification(
        userId: 'user1',
        type: NotificationType.reply,
        title: 'Reply',
        description: 'New reply',
        relatedId: 'post2',
        relatedType: 'post',
      );

      final count = await service.getUnreadCount('user1');
      expect(count, 2);
    });

    test('get notification summary', () async {
      await service.createNotification(
        userId: 'user1',
        type: NotificationType.mention,
        title: 'Mention',
        description: 'Mentioned',
        relatedId: 'post1',
        relatedType: 'post',
      );

      await service.createNotification(
        userId: 'user1',
        type: NotificationType.reply,
        title: 'Reply',
        description: 'Reply received',
        relatedId: 'post2',
        relatedType: 'post',
      );

      final summary = await service.getNotificationSummary('user1');
      expect(summary['mentions'], 1);
      expect(summary['replies'], 1);
      expect(summary['total'], 2);
    });

    test('prevent duplicate notifications', () async {
      await service.createNotification(
        userId: 'user1',
        type: NotificationType.mention,
        title: 'Mention',
        description: 'Mentioned',
        relatedId: 'post1',
        relatedType: 'post',
      );

      final notifId2 = await service.createNotification(
        userId: 'user1',
        type: NotificationType.mention,
        title: 'Mention',
        description: 'Mentioned again',
        relatedId: 'post1',
        relatedType: 'post',
      );

      expect(notifId2, isEmpty);
    });
  });

  // ============ NOTIFICATION PREFERENCE TESTS (Phase 11 Step 2) ============
  group('Notification Preferences (Phase 11 Step 2)', () {
    late CommunityService service;

    setUp(() {
      service = StubCommunityService();
    });

    test('get default notification preferences', () async {
      final prefs = await service.getUserNotificationPreferences('user1');
      expect(prefs, isNull);
    });

    test('update notification preferences', () async {
      final prefs = NotificationPreferences(
        userId: 'user1',
        mentionNotifications: true,
        replyNotifications: false,
        updatedAt: DateTime.now(),
      );

      await service.updateNotificationPreferences('user1', prefs);

      final retrieved = await service.getUserNotificationPreferences('user1');
      expect(retrieved!.replyNotifications, false);
    });

    test('mute user notifications', () async {
      await service.muteUserNotifications(
        'user1',
        duration: Duration(hours: 1),
      );

      final prefs = await service.getUserNotificationPreferences('user1');
      expect(prefs!.isCurrentlyMuted, true);
    });

    test('unmute user notifications', () async {
      await service.muteUserNotifications(
        'user1',
        duration: Duration(hours: 1),
      );

      await service.unmuteUserNotifications('user1');

      final prefs = await service.getUserNotificationPreferences('user1');
      expect(prefs!.isCurrentlyMuted, false);
    });

    test('respect notification preferences when creating', () async {
      final prefs = NotificationPreferences(
        userId: 'user1',
        mentionNotifications: false,
        replyNotifications: true,
        updatedAt: DateTime.now(),
      );

      await service.updateNotificationPreferences('user1', prefs);

      final mentionNotifId = await service.createNotification(
        userId: 'user1',
        type: NotificationType.mention,
        title: 'Mention',
        description: 'Mentioned',
        relatedId: 'post1',
        relatedType: 'post',
      );

      expect(mentionNotifId, isEmpty);
    });

    test('get users with notifications enabled in channel', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'user2',
      );

      final users = await service.getUsersWithNotificationsEnabled(channelId);
      expect(users.length, greaterThan(0));
    });

    test('clear read notifications', () async {
      final notifId = await service.createNotification(
        userId: 'user1',
        type: NotificationType.mention,
        title: 'Mention',
        description: 'Mentioned',
        relatedId: 'post1',
        relatedType: 'post',
      );

      await service.markNotificationAsRead(notifId);
      await service.clearReadNotifications('user1');

      final notifs = await service.getUserNotifications('user1');
      expect(notifs, isEmpty);
    });
  });

  // ============ INTEGRATED WORKFLOW TESTS (Phase 11 Step 2) ============
  group('Integrated Mention & Notification Workflows', () {
    late CommunityService service;

    setUp(() {
      service = StubCommunityService();
    });

    test('complete mention and notification workflow', () async {
      // Setup channel
      final channelId = await service.createChannel(
        name: 'Bike Tips',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.addMemberToChannel(
        channelId: channelId,
        userId: 'john_cyclist',
      );

      // Create post with mention
      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        authorName: 'Alice',
        content: 'Hey @john_cyclist, check out this maintenance tip!',
      );

      // Extract mentions
      final mentions = await service.extractMentions(
        'Hey @john_cyclist, check out this maintenance tip!',
        channelId: channelId,
      );

      // Verify mentions were found
      expect(mentions, hasLength(1));

      // Create mention records and notifications
      for (final mention in mentions) {
        final mentionId = await service.createMention(
          mentionedUserId: mention.mentionedUserId,
          mentionedUsername: mention.mentionedUsername,
          channelId: channelId,
          authorId: 'user1',
          authorName: 'Alice',
          postId: postId,
        );

        final notifId = await service.createNotification(
          userId: mention.mentionedUserId,
          type: NotificationType.mention,
          title: 'New Mention',
          description: 'Alice mentioned you in Bike Tips',
          relatedId: postId,
          relatedType: 'post',
          channelId: channelId,
        );

        expect(notifId, isNotEmpty);
      }

      // User receives notifications
      final notifs = await service.getUserNotifications('john_cyclist');
      expect(notifs, hasLength(1));
      expect(notifs[0].type, NotificationType.mention);

      // User marks notification as read
      await service.markNotificationAsRead(notifs[0].notificationId);

      final readNotifs = await service.getUserNotifications(
        'john_cyclist',
        unreadOnly: true,
      );

      expect(readNotifs, isEmpty);
    });
  });
}
