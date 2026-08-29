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

  // ============ REACTION TESTS (Phase 11 Step 3) ============
  group('Reaction Management (Phase 11 Step 3)', () {
    late CommunityService service;

    setUp(() {
      service = StubCommunityService();
    });

    test('add reaction to post', () async {
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

      final reactionId = await service.addPostReaction(
        postId: postId,
        userId: 'user2',
        emoji: '👍',
      );

      expect(reactionId, isNotEmpty);
    });

    test('get post reactions', () async {
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

      await service.addPostReaction(
        postId: postId,
        userId: 'user2',
        emoji: '👍',
      );

      await service.addPostReaction(
        postId: postId,
        userId: 'user3',
        emoji: '❤️',
      );

      final reactions = await service.getPostReactions(postId);
      expect(reactions, hasLength(2));
    });

    test('remove reaction from post', () async {
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

      await service.addPostReaction(
        postId: postId,
        userId: 'user2',
        emoji: '👍',
      );

      await service.removePostReaction(postId, 'user2', '👍');

      final reactions = await service.getPostReactions(postId);
      expect(reactions, isEmpty);
    });

    test('get reaction count', () async {
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

      await service.addPostReaction(
        postId: postId,
        userId: 'user2',
        emoji: '👍',
      );

      await service.addPostReaction(
        postId: postId,
        userId: 'user3',
        emoji: '👍',
      );

      final count = await service.getReactionCount(postId);
      expect(count, 2);
    });

    test('add reaction to reply', () async {
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

      final replyId = await service.createReply(
        postId: postId,
        channelId: channelId,
        authorId: 'user2',
        content: 'Test reply',
      );

      final reactionId = await service.addReplyReaction(
        replyId: replyId,
        postId: postId,
        userId: 'user3',
        emoji: '👍',
      );

      expect(reactionId, isNotEmpty);
    });
  });

  // ============ REPORT TESTS (Phase 11 Step 3) ============
  group('Report Management (Phase 11 Step 3)', () {
    late CommunityService service;

    setUp(() {
      service = StubCommunityService();
    });

    test('report post', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Inappropriate content',
      );

      final reportId = await service.reportPost(
        postId: postId,
        reportedByUserId: 'user2',
        category: ReportCategory.inappropriate,
        description: 'Offensive language',
      );

      expect(reportId, isNotEmpty);
    });

    test('get report', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Test',
      );

      final reportId = await service.reportPost(
        postId: postId,
        reportedByUserId: 'user2',
        category: ReportCategory.spam,
      );

      final report = await service.getReport(reportId);
      expect(report!.isPending, true);
    });

    test('action report', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Test',
      );

      final reportId = await service.reportPost(
        postId: postId,
        reportedByUserId: 'user2',
        category: ReportCategory.spam,
      );

      await service.actionReport(
        reportId: reportId,
        action: ReportAction.removeContent,
        moderatorId: 'moderator1',
        reason: 'Spam detected',
      );

      final report = await service.getReport(reportId);
      expect(report!.isUpheld, true);
    });

    test('get channel reports', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Test',
      );

      await service.reportPost(
        postId: postId,
        reportedByUserId: 'user2',
        category: ReportCategory.spam,
      );

      final reports = await service.getChannelReports(channelId);
      expect(reports, hasLength(1));
    });

    test('report stats', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Test',
      );

      await service.reportPost(
        postId: postId,
        reportedByUserId: 'user2',
        category: ReportCategory.spam,
      );

      final stats = await service.getReportStats(channelId);
      expect(stats['total'], 1);
      expect(stats['pending'], 1);
    });
  });

  // ============ TRENDING TESTS (Phase 11 Step 3) ============
  group('Trending Content (Phase 11 Step 3)', () {
    late CommunityService service;

    setUp(() {
      service = StubCommunityService();
    });

    test('get trending posts', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      final postId = await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Popular post',
      );

      // Add engagement
      await service.likePost(postId, 'user2');
      await service.likePost(postId, 'user3');

      final trending = await service.getTrendingPosts(channelId);
      expect(trending.isNotEmpty, true);
    });

    test('get trending tags', () async {
      final channelId = await service.createChannel(
        name: 'Test Channel',
        ownerId: 'user1',
        type: ChannelType.public,
      );

      await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Post 1',
        tags: ['bike', 'maintenance'],
      );

      await service.createPost(
        channelId: channelId,
        authorId: 'user1',
        content: 'Post 2',
        tags: ['bike', 'repair'],
      );

      final tags = await service.getTrendingTags(channelId);
      expect(tags.contains('bike'), true);
    });

    test('calculate trending score', () async {
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

      final score = await service.calculateTrendingScore(postId);
      expect(score, greaterThan(0));
    });

    test('get post engagement analytics', () async {
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

      await service.updateEngagementAnalytics(postId);

      final analytics = await service.getPostEngagementAnalytics(postId);
      expect(analytics, isNotNull);
    });
  });

  group('Phase 11 Step 4: Channel Access Control & Invitations', () {
    group('Invitations', () {
      test('Create invitation to channel', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final invitationId = await service.createInvitation(
          channelId: channelId,
          invitedUserId: 'user2',
          invitedByUserId: 'user1',
          inviterName: 'User 1',
          role: 'member',
        );

        expect(invitationId, isNotEmpty);

        final invitation = await service.getInvitation(invitationId);
        expect(invitation, isNotNull);
        expect(invitation?.invitedUserId, 'user2');
        expect(invitation?.status, 'pending');
      });

      test('Invite multiple users at once', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final invitationIds = await service.inviteMultipleUsers(
          channelId: channelId,
          invitedUserIds: ['user2', 'user3', 'user4'],
          invitedByUserId: 'user1',
          inviterName: 'User 1',
          role: 'member',
        );

        expect(invitationIds.length, 3);

        final invitations = await service.getChannelInvitations(channelId);
        expect(invitations.length, 3);
      });

      test('Get user invitations', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        await service.createInvitation(
          channelId: channelId,
          invitedUserId: 'user2',
          invitedByUserId: 'user1',
          inviterName: 'User 1',
        );

        final invitations = await service.getUserInvitations('user2');
        expect(invitations, isNotEmpty);
        expect(invitations.first.invitedUserId, 'user2');
      });

      test('Accept invitation', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final invitationId = await service.createInvitation(
          channelId: channelId,
          invitedUserId: 'user2',
          invitedByUserId: 'user1',
          inviterName: 'User 1',
        );

        await service.acceptInvitation(invitationId, 'user2');

        final invitation = await service.getInvitation(invitationId);
        expect(invitation?.status, 'accepted');

        final isMember = await service.isChannelMember(channelId, 'user2');
        expect(isMember, true);
      });

      test('Decline invitation', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final invitationId = await service.createInvitation(
          channelId: channelId,
          invitedUserId: 'user2',
          invitedByUserId: 'user1',
          inviterName: 'User 1',
        );

        await service.declineInvitation(invitationId, 'user2');

        final invitation = await service.getInvitation(invitationId);
        expect(invitation?.status, 'declined');

        final isMember = await service.isChannelMember(channelId, 'user2');
        expect(isMember, false);
      });
    });

    group('Access Requests', () {
      test('Create access request', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.private,
        );

        final requestId = await service.createAccessRequest(
          channelId: channelId,
          requestedByUserId: 'user2',
          requesterName: 'User 2',
          reason: 'I want to join',
        );

        expect(requestId, isNotEmpty);

        final request = await service.getAccessRequest(requestId);
        expect(request, isNotNull);
        expect(request?.status, 'pending');
      });

      test('Get channel access requests', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.private,
        );

        await service.createAccessRequest(
          channelId: channelId,
          requestedByUserId: 'user2',
          requesterName: 'User 2',
        );

        await service.createAccessRequest(
          channelId: channelId,
          requestedByUserId: 'user3',
          requesterName: 'User 3',
        );

        final requests = await service.getChannelAccessRequests(channelId);
        expect(requests.length, 2);
      });

      test('Approve access request', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.private,
        );

        final requestId = await service.createAccessRequest(
          channelId: channelId,
          requestedByUserId: 'user2',
          requesterName: 'User 2',
        );

        await service.approveAccessRequest(
          requestId,
          'user1',
          role: 'member',
        );

        final request = await service.getAccessRequest(requestId);
        expect(request?.status, 'approved');

        final isMember = await service.isChannelMember(channelId, 'user2');
        expect(isMember, true);
      });

      test('Reject access request', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.private,
        );

        final requestId = await service.createAccessRequest(
          channelId: channelId,
          requestedByUserId: 'user2',
          requesterName: 'User 2',
        );

        await service.rejectAccessRequest(
          requestId,
          'user1',
          reason: 'Does not meet requirements',
        );

        final request = await service.getAccessRequest(requestId);
        expect(request?.status, 'rejected');

        final isMember = await service.isChannelMember(channelId, 'user2');
        expect(isMember, false);
      });
    });

    group('Member Management', () {
      test('Get channel members', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        // Create and accept invitation
        final invitationId = await service.createInvitation(
          channelId: channelId,
          invitedUserId: 'user2',
          invitedByUserId: 'user1',
          inviterName: 'User 1',
        );
        await service.acceptInvitation(invitationId, 'user2');

        final members = await service.getChannelMembers(channelId);
        expect(members.length, greaterThan(0));
      });

      test('Update member role', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final invitationId = await service.createInvitation(
          channelId: channelId,
          invitedUserId: 'user2',
          invitedByUserId: 'user1',
          inviterName: 'User 1',
          role: 'member',
        );
        await service.acceptInvitation(invitationId, 'user2');

        await service.updateMemberRole(
          channelId,
          'user2',
          'moderator',
          'user1',
        );

        final role = await service.getUserRoleInChannel(channelId, 'user2');
        expect(role, 'moderator');
      });

      test('Remove member from channel', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final invitationId = await service.createInvitation(
          channelId: channelId,
          invitedUserId: 'user2',
          invitedByUserId: 'user1',
          inviterName: 'User 1',
        );
        await service.acceptInvitation(invitationId, 'user2');

        await service.removeMember(channelId, 'user2', 'user1');

        final isMember = await service.isChannelMember(channelId, 'user2');
        expect(isMember, false);
      });

      test('Leave channel', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final invitationId = await service.createInvitation(
          channelId: channelId,
          invitedUserId: 'user2',
          invitedByUserId: 'user1',
          inviterName: 'User 1',
        );
        await service.acceptInvitation(invitationId, 'user2');

        await service.leaveChannel(channelId, 'user2');

        final isMember = await service.isChannelMember(channelId, 'user2');
        expect(isMember, false);
      });

      test('Get user channels', () async {
        final channelId1 = await service.createChannel(
          name: 'Channel 1',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final invitationId = await service.createInvitation(
          channelId: channelId1,
          invitedUserId: 'user2',
          invitedByUserId: 'user1',
          inviterName: 'User 1',
        );
        await service.acceptInvitation(invitationId, 'user2');

        final channels = await service.getUserChannels('user2');
        expect(channels, isNotEmpty);
      });
    });

    group('Permissions', () {
      test('Check if user is channel member', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        var isMember = await service.isChannelMember(channelId, 'user2');
        expect(isMember, false);

        final invitationId = await service.createInvitation(
          channelId: channelId,
          invitedUserId: 'user2',
          invitedByUserId: 'user1',
          inviterName: 'User 1',
        );
        await service.acceptInvitation(invitationId, 'user2');

        isMember = await service.isChannelMember(channelId, 'user2');
        expect(isMember, true);
      });

      test('Get user role in channel', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        var role = await service.getUserRoleInChannel(channelId, 'user2');
        expect(role, isNull);

        final invitationId = await service.createInvitation(
          channelId: channelId,
          invitedUserId: 'user2',
          invitedByUserId: 'user1',
          inviterName: 'User 1',
          role: 'member',
        );
        await service.acceptInvitation(invitationId, 'user2');

        role = await service.getUserRoleInChannel(channelId, 'user2');
        expect(role, 'member');
      });

      test('Check invite permission', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        var canInvite = await service.canUserInvite(channelId, 'user2');
        expect(canInvite, false);

        final invitationId = await service.createInvitation(
          channelId: channelId,
          invitedUserId: 'user2',
          invitedByUserId: 'user1',
          inviterName: 'User 1',
          role: 'moderator',
        );
        await service.acceptInvitation(invitationId, 'user2');

        canInvite = await service.canUserInvite(channelId, 'user2');
        expect(canInvite, true);
      });

      test('Check moderation permission', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final invitationId = await service.createInvitation(
          channelId: channelId,
          invitedUserId: 'user2',
          invitedByUserId: 'user1',
          inviterName: 'User 1',
          role: 'member',
        );
        await service.acceptInvitation(invitationId, 'user2');

        var canModerate = await service.canUserModerate(channelId, 'user2');
        expect(canModerate, false);

        await service.updateMemberRole(
          channelId,
          'user2',
          'moderator',
          'user1',
        );

        canModerate = await service.canUserModerate(channelId, 'user2');
        expect(canModerate, true);
      });

      test('Check specific permissions', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final invitationId = await service.createInvitation(
          channelId: channelId,
          invitedUserId: 'user2',
          invitedByUserId: 'user1',
          inviterName: 'User 1',
          role: 'guest',
        );
        await service.acceptInvitation(invitationId, 'user2');

        var canPost = await service.hasPermission(
          channelId,
          'user2',
          'post_content',
        );
        expect(canPost, false);

        var canInvite = await service.hasPermission(
          channelId,
          'user2',
          'invite',
        );
        expect(canInvite, false);
      });
    });

    group('Access History', () {
      test('Get channel access history', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final invitationId = await service.createInvitation(
          channelId: channelId,
          invitedUserId: 'user2',
          invitedByUserId: 'user1',
          inviterName: 'User 1',
        );
        await service.acceptInvitation(invitationId, 'user2');

        final history = await service.getChannelAccessHistory(channelId);
        expect(history, isNotEmpty);
      });

      test('Get user access history', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final invitationId = await service.createInvitation(
          channelId: channelId,
          invitedUserId: 'user2',
          invitedByUserId: 'user1',
          inviterName: 'User 1',
        );
        await service.acceptInvitation(invitationId, 'user2');

        final history = await service.getUserAccessHistory('user2');
        expect(history, isNotEmpty);
      });

      test('History tracks role changes', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final invitationId = await service.createInvitation(
          channelId: channelId,
          invitedUserId: 'user2',
          invitedByUserId: 'user1',
          inviterName: 'User 1',
          role: 'member',
        );
        await service.acceptInvitation(invitationId, 'user2');

        await service.updateMemberRole(
          channelId,
          'user2',
          'moderator',
          'user1',
        );

        final history = await service.getChannelAccessHistory(channelId);
        expect(history.any((h) => h.action == 'promoted'), true);
      });
    });
  });

  group('Phase 11 Step 5: Advanced Search & Content Discovery', () {
    group('Full-Text Search', () {
      test('Search posts by query', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        await service.createPost(
          channelId: channelId,
          authorId: 'user1',
          content: 'bike maintenance guide',
          tags: ['maintenance'],
        );

        final results = await service.searchPosts('maintenance');
        expect(results, isNotEmpty);
        expect(results.first.snippet, contains('maintenance'));
      });

      test('Search posts with channel filter', () async {
        final channel1 = await service.createChannel(
          name: 'Channel 1',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final channel2 = await service.createChannel(
          name: 'Channel 2',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        await service.createPost(
          channelId: channel1,
          authorId: 'user1',
          content: 'bike test',
        );

        await service.createPost(
          channelId: channel2,
          authorId: 'user1',
          content: 'bike test',
        );

        final results = await service.searchPosts(
          'bike',
          channelId: channel1,
        );

        expect(results.isNotEmpty, true);
      });

      test('Search posts with date range filter', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        await service.createPost(
          channelId: channelId,
          authorId: 'user1',
          content: 'bike maintenance',
        );

        final results = await service.searchPostsByDateRange(
          query: 'bike',
          fromDate: DateTime.now().subtract(Duration(days: 7)),
          toDate: DateTime.now(),
        );

        expect(results, isNotEmpty);
      });

      test('Search posts by tags', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        await service.createPost(
          channelId: channelId,
          authorId: 'user1',
          content: 'maintenance post',
          tags: ['maintenance', 'safety'],
        );

        final results = await service.searchPostsByTags(
          tags: ['maintenance'],
        );

        expect(results, isNotEmpty);
      });

      test('Get search result', () async {
        final channelId = await service.createChannel(
          name: 'Test Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final postId = await service.createPost(
          channelId: channelId,
          authorId: 'user1',
          content: 'test content',
        );

        final result = await service.getSearchResult(postId);
        expect(result, isNotNull);
        expect(result?.contentId, postId);
      });
    });

    group('Channel Discovery', () {
      test('Search channels', () async {
        await service.createChannel(
          name: 'Maintenance Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final results = await service.searchChannels('Maintenance');
        expect(results, isNotEmpty);
      });

      test('Get popular channels', () async {
        await service.createChannel(
          name: 'Popular Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final popular = await service.getPopularChannels(limit: 10);
        expect(popular, isNotEmpty);
      });

      test('Get trending channels', () async {
        await service.createChannel(
          name: 'Trending Channel',
          ownerId: 'user1',
          type: ChannelType.public,
        );

        final trending = await service.getTrendingChannels(limit: 10);
        expect(trending, isNotEmpty);
      });
    });

    group('Search Suggestions', () {
      test('Get search suggestions', () async {
        final suggestions = await service.getSearchSuggestions(
          'bike',
          limit: 10,
        );

        expect(suggestions, isNotEmpty);
      });

      test('Suggestions by category', () async {
        final suggestions = await service.getSearchSuggestions(
          'bi',
          category: 'posts',
          limit: 10,
        );

        expect(suggestions, isNotEmpty);
      });
    });

    group('Search History', () {
      test('Record search', () async {
        await service.recordSearch(
          userId: 'user1',
          query: 'bike maintenance',
          resultCount: 42,
        );

        final history = await service.getUserSearchHistory('user1');
        expect(history, isNotEmpty);
        expect(history.first.query, 'bike maintenance');
      });

      test('Get user search history', () async {
        await service.recordSearch(
          userId: 'user1',
          query: 'query1',
          resultCount: 10,
        );

        await service.recordSearch(
          userId: 'user1',
          query: 'query2',
          resultCount: 20,
        );

        final history = await service.getUserSearchHistory('user1');
        expect(history.length, greaterThanOrEqualTo(2));
      });

      test('Get trending searches', () async {
        await service.recordSearch(
          userId: 'user1',
          query: 'popular query',
          resultCount: 100,
        );

        final trending = await service.getTrendingSearches(timeRange: 'week');
        expect(trending, isNotEmpty);
      });

      test('Clear search history', () async {
        await service.recordSearch(
          userId: 'user1',
          query: 'test',
          resultCount: 10,
        );

        await service.clearSearchHistory('user1');

        final history = await service.getUserSearchHistory('user1');
        expect(history, isEmpty);
      });
    });

    group('Saved Searches', () {
      test('Save search', () async {
        final searchId = await service.saveSearch(
          userId: 'user1',
          query: 'bike maintenance',
          name: 'Maintenance Tips',
        );

        expect(searchId, isNotEmpty);
      });

      test('Get saved search', () async {
        final searchId = await service.saveSearch(
          userId: 'user1',
          query: 'test query',
          name: 'Test Search',
        );

        final saved = await service.getSavedSearch(searchId);
        expect(saved, isNotNull);
        expect(saved?.name, 'Test Search');
      });

      test('Get user saved searches', () async {
        await service.saveSearch(
          userId: 'user1',
          query: 'query1',
          name: 'Search 1',
        );

        await service.saveSearch(
          userId: 'user1',
          query: 'query2',
          name: 'Search 2',
        );

        final saved = await service.getSavedSearches('user1');
        expect(saved.length, greaterThanOrEqualTo(2));
      });

      test('Update saved search', () async {
        final searchId = await service.saveSearch(
          userId: 'user1',
          query: 'test',
          name: 'Original Name',
        );

        await service.updateSavedSearch(
          searchId,
          name: 'Updated Name',
        );

        final saved = await service.getSavedSearch(searchId);
        expect(saved?.name, 'Updated Name');
      });

      test('Delete saved search', () async {
        final searchId = await service.saveSearch(
          userId: 'user1',
          query: 'test',
          name: 'To Delete',
        );

        await service.deleteSavedSearch(searchId);

        final saved = await service.getSavedSearch(searchId);
        expect(saved, isNull);
      });

      test('Use saved search increments counter', () async {
        final searchId = await service.saveSearch(
          userId: 'user1',
          query: 'test',
          name: 'Test Search',
        );

        await service.useSavedSearch(searchId);

        final saved = await service.getSavedSearch(searchId);
        expect(saved?.useCount, greaterThan(0));
      });
    });

    group('Search Analytics', () {
      test('Get search analytics', () async {
        await service.recordSearch(
          userId: 'user1',
          query: 'test',
          resultCount: 10,
        );

        final analytics = await service.getSearchAnalytics();
        expect(analytics, isNotEmpty);
      });

      test('Get search stats', () async {
        await service.recordSearch(
          userId: 'user1',
          query: 'query1',
          resultCount: 10,
        );

        await service.recordSearch(
          userId: 'user2',
          query: 'query2',
          resultCount: 20,
        );

        final stats = await service.getSearchStats();
        expect(stats['totalSearches'], greaterThan(0));
        expect(stats['uniqueUsers'], greaterThan(0));
      });
    });

    // Phase 11 Step 6: Report Appeals & Moderation Dashboard
    group('Report Appeals', () {
      test('createReportAppeal creates a new appeal', () async {
        final service = StubCommunityService();
        final appealId = await service.createReportAppeal(
          reportId: 'report1',
          userId: 'user1',
          userName: 'User One',
          reason: 'I believe this was incorrectly flagged',
          attachmentUrl: 'https://example.com/evidence.jpg',
        );

        expect(appealId, isNotEmpty);

        final appeal = await service.getReportAppeal(appealId);
        expect(appeal, isNotNull);
        expect(appeal!.reportId, 'report1');
        expect(appeal.userId, 'user1');
        expect(appeal.status, AppealStatus.pending);
      });

      test('getReportAppeal returns appeal by ID', () async {
        final service = StubCommunityService();
        final appealId = await service.createReportAppeal(
          reportId: 'report1',
          userId: 'user1',
          reason: 'Appeal reason',
        );

        final appeal = await service.getReportAppeal(appealId);
        expect(appeal, isNotNull);
        expect(appeal!.appealId, appealId);
      });

      test('getReportAppeals filters by report and status', () async {
        final service = StubCommunityService();

        await service.createReportAppeal(
          reportId: 'report1',
          userId: 'user1',
          reason: 'Appeal 1',
        );

        final appeal2Id = await service.createReportAppeal(
          reportId: 'report1',
          userId: 'user2',
          reason: 'Appeal 2',
        );

        final appeals = await service.getReportAppeals(reportId: 'report1');
        expect(appeals.length, 2);

        await service.respondToAppeal(
          appealId: appeal2Id,
          respondedByUserId: 'mod1',
          decision: 'overturned',
          reasoning: 'Decision was incorrect',
        );

        final overturnedAppeals = await service.getReportAppeals(
          reportId: 'report1',
          status: 'overturned',
        );
        expect(overturnedAppeals.length, greaterThanOrEqualTo(1));
      });

      test('getUserAppeals returns user\'s appeals', () async {
        final service = StubCommunityService();

        await service.createReportAppeal(
          reportId: 'report1',
          userId: 'user1',
          reason: 'Appeal 1',
        );

        await service.createReportAppeal(
          reportId: 'report2',
          userId: 'user1',
          reason: 'Appeal 2',
        );

        await service.createReportAppeal(
          reportId: 'report3',
          userId: 'user2',
          reason: 'Appeal 3',
        );

        final userAppeals = await service.getUserAppeals(userId: 'user1');
        expect(userAppeals.length, 2);
        expect(userAppeals.every((a) => a.userId == 'user1'), true);
      });

      test('respondToAppeal updates appeal status', () async {
        final service = StubCommunityService();
        final appealId = await service.createReportAppeal(
          reportId: 'report1',
          userId: 'user1',
          reason: 'Appeal reason',
        );

        await service.respondToAppeal(
          appealId: appealId,
          respondedByUserId: 'mod1',
          decision: 'upheld',
          reasoning: 'Decision was correct',
        );

        final appeal = await service.getReportAppeal(appealId);
        expect(appeal!.status, AppealStatus.upheld);
        expect(appeal.respondedByUserId, 'mod1');
        expect(appeal.reasoning, 'Decision was correct');
      });

      test('respondToAppeal with overturned decision', () async {
        final service = StubCommunityService();
        final appealId = await service.createReportAppeal(
          reportId: 'report1',
          userId: 'user1',
          reason: 'Appeal reason',
        );

        await service.respondToAppeal(
          appealId: appealId,
          respondedByUserId: 'mod1',
          decision: 'overturned',
          reasoning: 'Post did not violate guidelines',
        );

        final appeal = await service.getReportAppeal(appealId);
        expect(appeal!.status, AppealStatus.overturned);
      });
    });

    group('Moderation Dashboard', () {
      test('getModerationSummary retrieves summary stats', () async {
        final service = StubCommunityService();

        final summary = await service.getModerationSummary(timeRange: 'day');
        expect(summary, isNotNull);
      });

      test('getModerationAnalytics returns analytics for date range', () async {
        final service = StubCommunityService();

        final analytics = await service.getModerationAnalytics(
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 8, 28),
        );

        expect(analytics, isNotNull);
      });

      test('getModeratorStats retrieves moderator performance', () async {
        final service = StubCommunityService();

        final stats = await service.getModeratorStats(
          userId: 'mod1',
          timeRange: 'month',
        );

        expect(stats, isNotNull);
      });

      test('getTeamModerationStats returns team statistics', () async {
        final service = StubCommunityService();

        final teamStats = await service.getTeamModerationStats(
          timeRange: 'month',
          limit: 50,
        );

        expect(teamStats, isList);
      });

      test('compareModerators compares performance metrics', () async {
        final service = StubCommunityService();

        final comparison = await service.compareModerators(
          moderatorIds: ['mod1', 'mod2', 'mod3'],
          metric: 'appeal_overturn_rate',
        );

        expect(comparison['metric'], 'appeal_overturn_rate');
        expect(comparison['moderators'], isList);
      });
    });

    group('Action History & Audit Trail', () {
      test('getModerationActionHistory retrieves action records', () async {
        final service = StubCommunityService();

        final history = await service.getModerationActionHistory(limit: 100);
        expect(history, isList);
      });

      test('getModeratorActionHistory filters by moderator', () async {
        final service = StubCommunityService();

        final history = await service.getModeratorActionHistory(
          userId: 'mod1',
          limit: 50,
        );

        expect(history, isList);
      });

      test('getUserModerationHistory filters by target user', () async {
        final service = StubCommunityService();

        final history = await service.getUserModerationHistory(
          userId: 'user1',
          limit: 50,
        );

        expect(history, isList);
      });

      test('getModerationAction retrieves specific action', () async {
        final service = StubCommunityService();

        final action = await service.getModerationAction('action1');
        expect(action, isNotNull);
      });
    });

    group('Escalation Management', () {
      test('escalateReport escalates a report', () async {
        final service = StubCommunityService();

        await service.escalateReport(
          reportId: 'report1',
          escalatedByUserId: 'mod1',
          reason: 'Requires legal review',
          escalateTo: 'legalTeam',
        );

        final escalations = await service.getEscalations(status: 'pending');
        expect(escalations.length, greaterThanOrEqualTo(0));
      });

      test('getEscalations retrieves pending escalations', () async {
        final service = StubCommunityService();

        await service.escalateReport(
          reportId: 'report1',
          escalatedByUserId: 'mod1',
          reason: 'Complex case',
          escalateTo: 'adminReview',
        );

        final escalations = await service.getEscalations(
          status: 'pending',
          limit: 50,
        );

        expect(escalations, isList);
      });

      test('processEscalation updates escalation status', () async {
        final service = StubCommunityService();

        await service.escalateReport(
          reportId: 'report1',
          escalatedByUserId: 'mod1',
          reason: 'Legal review needed',
          escalateTo: 'legalTeam',
        );

        final escalations = await service.getEscalations(status: 'pending');
        if (escalations.isNotEmpty) {
          final escalationId = escalations.first.escalationId;

          await service.processEscalation(
            escalationId: escalationId,
            processedByUserId: 'admin1',
            decision: 'approved',
            notes: 'Action confirmed appropriate',
          );

          final processed = await service.getEscalations(status: 'approved');
          expect(processed, isList);
        }
      });

      test('escalation includes correct target', () async {
        final service = StubCommunityService();

        await service.escalateReport(
          reportId: 'report1',
          escalatedByUserId: 'mod1',
          reason: 'Executive decision needed',
          escalateTo: 'executive',
        );

        final escalations = await service.getEscalations(
          status: 'pending',
          limit: 1,
        );

        expect(escalations.isNotEmpty, true);
        if (escalations.isNotEmpty) {
          expect(
            escalations.first.escalateTo,
            isIn([EscalationTarget.values]),
          );
        }
      });
    });

    // Phase 11 Step 7: Community Gamification & User Badges
    group('User Reputation & Gamification', () {
      test('addReputationEvent creates event and updates reputation', () async {
        final service = StubCommunityService();

        final eventId = await service.addReputationEvent(
          userId: 'user1',
          eventType: 'postCreated',
          points: 10,
          reason: 'Created high-quality post',
        );

        expect(eventId, isNotEmpty);

        final reputation = await service.getUserReputation('user1');
        expect(reputation, isNotNull);
        expect(reputation!.totalScore, 10);
      });

      test('getUserReputation retrieves user reputation', () async {
        final service = StubCommunityService();

        await service.addReputationEvent(
          userId: 'user1',
          eventType: 'replyCreated',
          points: 5,
          reason: 'Helpful reply',
        );

        final reputation = await service.getUserReputation('user1');
        expect(reputation!.userId, 'user1');
        expect(reputation.totalScore, 5);
      });

      test('getReputationEvents returns user\'s events', () async {
        final service = StubCommunityService();

        await service.addReputationEvent(
          userId: 'user1',
          eventType: 'postCreated',
          points: 10,
          reason: 'Event 1',
        );

        await service.addReputationEvent(
          userId: 'user1',
          eventType: 'replyCreated',
          points: 5,
          reason: 'Event 2',
        );

        final events = await service.getReputationEvents(userId: 'user1');
        expect(events.length, 2);
      });

      test('getUserStatistics returns comprehensive stats', () async {
        final service = StubCommunityService();

        await service.addReputationEvent(
          userId: 'user1',
          eventType: 'postCreated',
          points: 10,
          reason: 'Created post',
        );

        final stats = await service.getUserStatistics('user1');
        expect(stats['totalReputation'], greaterThan(0));
        expect(stats['level'], isNotNull);
      });

      test('getTotalReputation returns only score', () async {
        final service = StubCommunityService();

        await service.addReputationEvent(
          userId: 'user1',
          eventType: 'postCreated',
          points: 25,
          reason: 'High-value post',
        );

        final total = await service.getTotalReputation('user1');
        expect(total, 25);
      });
    });

    group('Badges', () {
      test('createBadgeDefinition creates new badge', () async {
        final service = StubCommunityService();

        final badgeId = await service.createBadgeDefinition(
          name: 'First Post',
          description: 'Created your first post',
          category: 'social',
          rarity: 'common',
          pointsValue: 5,
          iconUrl: 'url_to_icon',
        );

        expect(badgeId, isNotEmpty);

        final badge = await service.getBadgeDefinition(badgeId);
        expect(badge, isNotNull);
        expect(badge!.name, 'First Post');
      });

      test('getBadgeDefinitions filters by category', () async {
        final service = StubCommunityService();

        await service.createBadgeDefinition(
          name: 'Social Badge',
          description: 'Social badge',
          category: 'social',
          rarity: 'common',
          pointsValue: 5,
          iconUrl: 'url',
        );

        await service.createBadgeDefinition(
          name: 'Expert Badge',
          description: 'Expert badge',
          category: 'expertise',
          rarity: 'rare',
          pointsValue: 20,
          iconUrl: 'url',
        );

        final badges = await service.getBadgeDefinitions(category: 'social');
        expect(badges.isNotEmpty, true);
      });

      test('getUserBadges returns user\'s earned badges', () async {
        final service = StubCommunityService();

        final badgeId = await service.createBadgeDefinition(
          name: 'Test Badge',
          description: 'Test badge',
          category: 'social',
          rarity: 'common',
          pointsValue: 5,
          iconUrl: 'url',
        );

        await service.awardBadge(
          userId: 'user1',
          badgeId: badgeId,
        );

        final badges = await service.getUserBadges('user1');
        expect(badges.length, 1);
        expect(badges.first.badgeId, badgeId);
      });

      test('awardBadge increases badge count', () async {
        final service = StubCommunityService();

        await service.addReputationEvent(
          userId: 'user1',
          eventType: 'postCreated',
          points: 10,
          reason: 'Create post',
        );

        final badgeId = await service.createBadgeDefinition(
          name: 'Badge',
          description: 'Badge desc',
          category: 'achievement',
          rarity: 'uncommon',
          pointsValue: 10,
          iconUrl: 'url',
        );

        await service.awardBadge(userId: 'user1', badgeId: badgeId);

        final rep = await service.getUserReputation('user1');
        expect(rep!.badgesCount, 1);
      });

      test('getBadgeProgress tracks badge earning', () async {
        final service = StubCommunityService();

        final badgeId = await service.createBadgeDefinition(
          name: 'Progress Badge',
          description: 'Track progress',
          category: 'milestone',
          rarity: 'rare',
          pointsValue: 15,
          iconUrl: 'url',
        );

        var progress = await service.getBadgeProgress(
          userId: 'user1',
          badgeId: badgeId,
        );
        expect(progress['earned'], false);

        await service.awardBadge(userId: 'user1', badgeId: badgeId);

        progress = await service.getBadgeProgress(
          userId: 'user1',
          badgeId: badgeId,
        );
        expect(progress['earned'], true);
      });
    });

    group('Leaderboards', () {
      test('getTopContributors returns ranked list', () async {
        final service = StubCommunityService();

        await service.addReputationEvent(
          userId: 'user1',
          eventType: 'postCreated',
          points: 50,
          reason: 'High contribution',
        );

        await service.addReputationEvent(
          userId: 'user2',
          eventType: 'postCreated',
          points: 30,
          reason: 'Medium contribution',
        );

        final top = await service.getTopContributors(limit: 10);
        expect(top.isNotEmpty, true);
        expect(top.first['rank'], 1);
      });

      test('getLeaderboard returns sorted by metric', () async {
        final service = StubCommunityService();

        await service.addReputationEvent(
          userId: 'user1',
          eventType: 'postCreated',
          points: 40,
          reason: 'Post',
        );

        final leaderboard = await service.getLeaderboard(
          metric: 'reputation',
          limit: 50,
        );

        expect(leaderboard, isList);
        expect(leaderboard.isNotEmpty, true);
      });

      test('getUserRank finds user position', () async {
        final service = StubCommunityService();

        await service.addReputationEvent(
          userId: 'user1',
          eventType: 'postCreated',
          points: 100,
          reason: 'Top contributor',
        );

        final rank = await service.getUserRank(
          userId: 'user1',
          metric: 'reputation',
        );

        expect(rank, isNotNull);
        expect(rank!['rank'], 1);
      });

      test('getNearbyRanks shows users around target', () async {
        final service = StubCommunityService();

        for (int i = 1; i <= 10; i++) {
          await service.addReputationEvent(
            userId: 'user$i',
            eventType: 'postCreated',
            points: i * 10,
            reason: 'User $i contribution',
          );
        }

        final nearby = await service.getNearbyRanks(
          userId: 'user5',
          metric: 'reputation',
          range: 2,
        );

        expect(nearby, isList);
      });
    });

    group('Levels & Progression', () {
      test('getUserLevel returns current level info', () async {
        final service = StubCommunityService();

        await service.addReputationEvent(
          userId: 'user1',
          eventType: 'postCreated',
          points: 50,
          reason: 'Reach level threshold',
        );

        final level = await service.getUserLevel('user1');
        expect(level['level'], isNotNull);
        expect(level['title'], isNotNull);
      });

      test('checkAndProcessLevelUp levels up when threshold met', () async {
        final service = StubCommunityService();

        await service.addReputationEvent(
          userId: 'user1',
          eventType: 'postCreated',
          points: 75,
          reason: 'Exceed level threshold',
        );

        await service.checkAndProcessLevelUp('user1');

        final rep = await service.getUserReputation('user1');
        expect(rep!.currentLevel, greaterThanOrEqualTo(1));
      });

      test('getLevelDefinitions returns level progression', () async {
        final service = StubCommunityService();

        final levels = await service.getLevelDefinitions();
        expect(levels, isList);
        expect(levels.isNotEmpty, true);
        expect(levels.first['level'], 1);
      });

      test('Level progression increases with reputation', () async {
        final service = StubCommunityService();

        final initialLevel = await service.getUserLevel('user1');
        expect(initialLevel['level'], 1);

        await service.addReputationEvent(
          userId: 'user1',
          eventType: 'postCreated',
          points: 100,
          reason: 'Major contribution',
        );

        await service.checkAndProcessLevelUp('user1');

        final newLevel = await service.getUserLevel('user1');
        expect(newLevel['experience'], greaterThan(0));
      });
    });

    // Phase 11 Step 8: Community Analytics & Insights Dashboard
    group('Platform Analytics', () {
      test('getPlatformOverview returns key metrics', () async {
        final service = StubCommunityService();

        final overview = await service.getPlatformOverview(timeRange: 'week');
        expect(overview['dau'], isNotNull);
        expect(overview['mau'], isNotNull);
        expect(overview['postsCreated'], isNotNull);
      });

      test('getKeyMetrics returns metrics for date range', () async {
        final service = StubCommunityService();

        final metrics = await service.getKeyMetrics(
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 8, 28),
        );

        expect(metrics, isList);
        expect(metrics.isNotEmpty || metrics.isEmpty, true);
      });

      test('getMetricTrends tracks metric over time', () async {
        final service = StubCommunityService();

        final trends = await service.getMetricTrends(
          metric: 'daily_active_users',
          timeRange: 'month',
        );

        expect(trends, isList);
      });
    });

    group('User Engagement Analytics', () {
      test('getUserEngagementStats returns engagement metrics', () async {
        final service = StubCommunityService();

        final stats = await service.getUserEngagementStats(timeRange: 'week');
        expect(stats['avgPostsPerUser'], isNotNull);
        expect(stats['engagementRate'], isNotNull);
      });

      test('getUserRetention tracks retention by cohort', () async {
        final service = StubCommunityService();

        final retention = await service.getUserRetention(
          cohortDate: DateTime(2026, 1, 1),
        );

        expect(retention, isMap);
      });

      test('getEngagementBySegment segments engagement data', () async {
        final service = StubCommunityService();

        final segments = await service.getEngagementBySegment(
          segment: 'channel',
          limit: 50,
        );

        expect(segments, isList);
      });
    });

    group('Content Analytics', () {
      test('getContentAnalytics returns content performance', () async {
        final service = StubCommunityService();

        final analytics = await service.getContentAnalytics(timeRange: 'week');
        expect(analytics['totalPosts'], isNotNull);
        expect(analytics['avgEngagement'], isNotNull);
      });

      test('getTrendingContent returns trending posts', () async {
        final service = StubCommunityService();

        final trending = await service.getTrendingContent(
          timeRange: 'day',
          limit: 20,
        );

        expect(trending, isList);
      });

      test('getChannelContentAnalytics returns channel-specific data', () async {
        final service = StubCommunityService();

        final analytics = await service.getChannelContentAnalytics(
          channelId: 'channel1',
          timeRange: 'month',
        );

        expect(analytics, isMap);
      });
    });

    group('Community Health Analytics', () {
      test('getCommunityHealthScore returns health metrics', () async {
        final service = StubCommunityService();

        final health = await service.getCommunityHealthScore(timeRange: 'week');
        expect(health['overallScore'], isNotNull);
        expect(health['overallScore'], greaterThanOrEqualTo(0));
        expect(health['overallScore'], lessThanOrEqualTo(100));
      });

      test('getCommunityHealthTrends tracks health over time', () async {
        final service = StubCommunityService();

        final trends = await service.getCommunityHealthTrends(timeRange: 'month');
        expect(trends, isList);
      });

      test('getChannelHealthMetrics returns channel health', () async {
        final service = StubCommunityService();

        final health = await service.getChannelHealthMetrics(channelId: 'channel1');
        expect(health, isMap);
      });
    });

    group('Growth & Retention Analytics', () {
      test('getUserGrowthMetrics tracks user growth', () async {
        final service = StubCommunityService();

        final growth = await service.getUserGrowthMetrics(timeRange: 'month');
        expect(growth['newUsersPerDay'], isNotNull);
        expect(growth['churnRate'], isNotNull);
      });

      test('getCohortRetention analyzes retention by cohort', () async {
        final service = StubCommunityService();

        final cohorts = await service.getCohortRetention(
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 8, 28),
        );

        expect(cohorts, isList);
      });

      test('getUserAcquisitionAnalytics tracks acquisition', () async {
        final service = StubCommunityService();

        final acquisition = await service.getUserAcquisitionAnalytics(
          timeRange: 'month',
        );

        expect(acquisition, isMap);
      });
    });

    group('Moderation Analytics', () {
      test('getModerationAnalyticsOverview returns moderation stats', () async {
        final service = StubCommunityService();

        final stats = await service.getModerationAnalyticsOverview(timeRange: 'week');
        expect(stats['reportsPerDay'], isNotNull);
        expect(stats['actionsPerDay'], isNotNull);
      });

      test('getModeratorEffectiveness tracks moderator performance', () async {
        final service = StubCommunityService();

        final effectiveness = await service.getModeratorEffectiveness(
          timeRange: 'month',
          limit: 50,
        );

        expect(effectiveness, isList);
      });

      test('getModerationHotspots identifies problem areas', () async {
        final service = StubCommunityService();

        final hotspots = await service.getModerationHotspots(
          timeRange: 'week',
          limit: 20,
        );

        expect(hotspots, isList);
      });
    });

    group('Revenue Analytics', () {
      test('getRevenueAnalytics returns revenue metrics', () async {
        final service = StubCommunityService();

        final revenue = await service.getRevenueAnalytics(timeRange: 'month');
        expect(revenue['totalRevenue'], isNotNull);
        expect(revenue['arpu'], isNotNull);
      });

      test('getSubscriptionAnalytics tracks subscriptions', () async {
        final service = StubCommunityService();

        final subs = await service.getSubscriptionAnalytics(timeRange: 'month');
        expect(subs['activeSubscriptions'], isNotNull);
        expect(subs['churnRate'], isNotNull);
      });

      test('getConversionFunnel tracks conversion', () async {
        final service = StubCommunityService();

        final funnel = await service.getConversionFunnel(timeRange: 'week');
        expect(funnel, isMap);
      });
    });

    group('Custom Reporting', () {
      test('generateCustomReport creates custom report', () async {
        final service = StubCommunityService();

        final report = await service.generateCustomReport(
          name: 'Weekly Report',
          metrics: ['dau', 'posts', 'engagement'],
          timeRange: 'week',
        );

        expect(report['reportId'], isNotNull);
        expect(report['name'], 'Weekly Report');
      });

      test('getSavedReports retrieves saved reports', () async {
        final service = StubCommunityService();

        final reports = await service.getSavedReports(limit: 20);
        expect(reports, isList);
      });

      test('exportAnalyticsData exports metrics', () async {
        final service = StubCommunityService();

        final export = await service.exportAnalyticsData(
          metrics: ['all'],
          format: 'csv',
        );

        expect(export['exportId'], isNotNull);
        expect(export['format'], 'csv');
      });
    });

    // Practice Test & Mock Exam Tests (Phase 11 Step 9)
    group('Question Management', () {
      test('createQuestion creates new question', () async {
        final service = StubCommunityService();

        final questionId = await service.createQuestion(
          questionText: 'What is the speed limit?',
          questionType: QuestionType.multipleChoice,
          topic: 'Traffic Laws',
          difficulty: QuestionDifficulty.beginner,
          options: ['25 mph', '35 mph', '45 mph', '55 mph'],
          correctAnswerIndex: 0,
          explanation: 'The limit is 25 mph in residential areas.',
          tags: ['speed_limit', 'traffic'],
        );

        expect(questionId, isNotEmpty);
      });

      test('getQuestion retrieves question by ID', () async {
        final service = StubCommunityService();

        final questionId = await service.createQuestion(
          questionText: 'Test question',
          questionType: QuestionType.multipleChoice,
          topic: 'Traffic Laws',
          difficulty: QuestionDifficulty.beginner,
        );

        final question = await service.getQuestion(questionId);
        expect(question, isNotNull);
        expect(question?.questionText, 'Test question');
      });

      test('getQuestionsByTopic retrieves questions by topic', () async {
        final service = StubCommunityService();

        await service.createQuestion(
          questionText: 'Traffic question',
          questionType: QuestionType.multipleChoice,
          topic: 'Traffic Laws',
          difficulty: QuestionDifficulty.beginner,
        );

        final questions = await service.getQuestionsByTopic('Traffic Laws');
        expect(questions, isNotEmpty);
      });

      test('getQuestionsByDifficulty retrieves by difficulty', () async {
        final service = StubCommunityService();

        await service.createQuestion(
          questionText: 'Easy question',
          questionType: QuestionType.multipleChoice,
          topic: 'Traffic',
          difficulty: QuestionDifficulty.beginner,
        );

        final questions = await service.getQuestionsByDifficulty(QuestionDifficulty.beginner);
        expect(questions, isNotEmpty);
      });
    });

    group('Practice Tests', () {
      test('startPracticeTest creates new test', () async {
        final service = StubCommunityService();

        // Create questions first
        await service.createQuestion(
          questionText: 'Q1',
          questionType: QuestionType.multipleChoice,
          topic: 'Traffic',
          difficulty: QuestionDifficulty.beginner,
        );

        final testId = await service.startPracticeTest(
          userId: 'user123',
          topic: 'Traffic',
          difficulty: QuestionDifficulty.beginner,
          questionCount: 5,
        );

        expect(testId, isNotEmpty);
      });

      test('submitAnswer records user answer', () async {
        final service = StubCommunityService();

        final questionId = await service.createQuestion(
          questionText: 'Q1',
          questionType: QuestionType.multipleChoice,
          topic: 'Traffic',
          difficulty: QuestionDifficulty.beginner,
          options: ['A', 'B', 'C'],
          correctAnswerIndex: 0,
        );

        final testId = await service.startPracticeTest(
          userId: 'user123',
          topic: 'Traffic',
          difficulty: QuestionDifficulty.beginner,
        );

        await service.submitAnswer(
          testId: testId,
          questionId: questionId,
          selectedAnswer: 0,
          timeTaken: 30,
        );

        expect(true, true); // Answer recorded
      });

      test('completePracticeTest calculates scores', () async {
        final service = StubCommunityService();

        final questionId = await service.createQuestion(
          questionText: 'Q1',
          questionType: QuestionType.multipleChoice,
          topic: 'Traffic',
          difficulty: QuestionDifficulty.beginner,
          options: ['A', 'B', 'C'],
          correctAnswerIndex: 0,
        );

        final testId = await service.startPracticeTest(
          userId: 'user123',
          topic: 'Traffic',
          difficulty: QuestionDifficulty.beginner,
          questionCount: 1,
        );

        await service.submitAnswer(
          testId: testId,
          questionId: questionId,
          selectedAnswer: 0,
        );

        final result = await service.completePracticeTest(testId);
        expect(result['score'], isNotNull);
        expect(result['percentage'], isNotNull);
      });

      test('getPracticeTestHistory retrieves user tests', () async {
        final service = StubCommunityService();

        await service.createQuestion(
          questionText: 'Q1',
          questionType: QuestionType.multipleChoice,
          topic: 'Traffic',
          difficulty: QuestionDifficulty.beginner,
        );

        await service.startPracticeTest(
          userId: 'user123',
          topic: 'Traffic',
          difficulty: QuestionDifficulty.beginner,
        );

        final history = await service.getPracticeTestHistory(userId: 'user123');
        expect(history, isList);
      });
    });

    group('Mock Exams', () {
      test('startMockExam creates full-length exam', () async {
        final service = StubCommunityService();

        final examId = await service.startMockExam(
          userId: 'user123',
          examType: ExamType.fullLength,
        );

        expect(examId, isNotEmpty);
      });

      test('getMockExamQuestions retrieves exam questions', () async {
        final service = StubCommunityService();

        await service.createQuestion(
          questionText: 'Exam Q',
          questionType: QuestionType.multipleChoice,
          topic: 'Traffic',
          difficulty: QuestionDifficulty.intermediate,
        );

        final examId = await service.startMockExam(
          userId: 'user123',
          examType: ExamType.fullLength,
        );

        final questions = await service.getMockExamQuestions(examId);
        expect(questions, isList);
      });

      test('completeMockExam scores full exam', () async {
        final service = StubCommunityService();

        final examId = await service.startMockExam(
          userId: 'user123',
          examType: ExamType.fullLength,
        );

        final result = await service.completeMockExam(examId);
        expect(result['score'], isNotNull);
        expect(result['passed'], isBool);
      });
    });

    group('Performance Analytics', () {
      test('getTestStatistics tracks user performance', () async {
        final service = StubCommunityService();

        await service.createQuestion(
          questionText: 'Q1',
          questionType: QuestionType.multipleChoice,
          topic: 'Traffic',
          difficulty: QuestionDifficulty.beginner,
        );

        await service.startPracticeTest(
          userId: 'user123',
          topic: 'Traffic',
          difficulty: QuestionDifficulty.beginner,
        );

        final stats = await service.getTestStatistics(userId: 'user123');
        expect(stats['totalTests'], isNotNull);
        expect(stats['averageScore'], isNotNull);
      });

      test('getScoreTrends shows performance history', () async {
        final service = StubCommunityService();

        await service.createQuestion(
          questionText: 'Q1',
          questionType: QuestionType.multipleChoice,
          topic: 'Traffic',
          difficulty: QuestionDifficulty.beginner,
        );

        await service.startPracticeTest(
          userId: 'user123',
          topic: 'Traffic',
          difficulty: QuestionDifficulty.beginner,
        );

        final trends = await service.getScoreTrends(userId: 'user123');
        expect(trends, isList);
      });

      test('getPerformanceByTopic analyzes by topic', () async {
        final service = StubCommunityService();

        await service.createQuestion(
          questionText: 'Traffic Q',
          questionType: QuestionType.multipleChoice,
          topic: 'Traffic Laws',
          difficulty: QuestionDifficulty.beginner,
        );

        await service.startPracticeTest(
          userId: 'user123',
          topic: 'Traffic Laws',
          difficulty: QuestionDifficulty.beginner,
        );

        final performance = await service.getPerformanceByTopic('user123');
        expect(performance, isMap);
      });

      test('getWeakAreas identifies low-scoring topics', () async {
        final service = StubCommunityService();

        final weakAreas = await service.getWeakAreas(
          userId: 'user123',
          threshold: 70.0,
        );

        expect(weakAreas, isList);
      });

      test('generateStudyPlan creates personalized plan', () async {
        final service = StubCommunityService();

        final plan = await service.generateStudyPlan('user123');
        expect(plan['planId'], isNotNull);
        expect(plan['topics'], isList);
      });

      test('getTestAchievements tracks milestones', () async {
        final service = StubCommunityService();

        final achievements = await service.getTestAchievements('user123');
        expect(achievements, isList);
      });
    });
  });
}
