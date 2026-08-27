import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community_model.dart';

/// Abstract interface for community service
abstract class CommunityService {
  // Channel operations
  Future<String> createChannel({
    required String name,
    required String ownerId,
    String? description,
    required ChannelType type,
    String? bannerUrl,
    String? iconUrl,
    String? category,
    List<String> tags,
  });

  Future<CommunityChannel?> getChannel(String channelId);

  Future<List<CommunityChannel>> getChannelsByCategory(
    String category, {
    int limit = 50,
  });

  Future<List<CommunityChannel>> searchChannels(
    String query, {
    int limit = 50,
  });

  Future<List<CommunityChannel>> getPublicChannels({int limit = 50});

  Future<void> updateChannel(String channelId, CommunityChannel channel);

  Future<void> archiveChannel(String channelId);

  // Member operations
  Future<String> addMemberToChannel({
    required String channelId,
    required String userId,
    MemberRole role = MemberRole.member,
  });

  Future<ChannelMember?> getChannelMember(String channelId, String userId);

  Future<List<ChannelMember>> getChannelMembers(
    String channelId, {
    int limit = 50,
  });

  Future<List<ChannelMember>> getChannelModerators(String channelId);

  Future<void> updateMemberRole({
    required String channelId,
    required String userId,
    required MemberRole newRole,
  });

  Future<void> removeMemberFromChannel(String channelId, String userId);

  Future<void> muteChannelMember({
    required String channelId,
    required String userId,
  });

  Future<void> unmuteChannelMember({
    required String channelId,
    required String userId,
  });

  Future<void> banChannelMember({
    required String channelId,
    required String userId,
    String? reason,
  });

  Future<void> unbanChannelMember(String channelId, String userId);

  // Post operations
  Future<String> createPost({
    required String channelId,
    required String authorId,
    String? authorName,
    required String content,
    String? mediaUrl,
    List<String> tags,
  });

  Future<ChannelPost?> getPost(String postId);

  Future<List<ChannelPost>> getChannelPosts(
    String channelId, {
    PostStatus? statusFilter,
    int limit = 50,
  });

  Future<List<ChannelPost>> getPinnedPosts(String channelId);

  Future<void> updatePost({
    required String postId,
    required String content,
  });

  Future<void> publishPost(String postId);

  Future<void> deletePost(String postId);

  Future<void> pinPost({
    required String postId,
    required int position,
  });

  Future<void> unpinPost(String postId);

  Future<void> incrementPostViews(String postId);

  // Post interaction operations
  Future<void> likePost(String postId, String userId);

  Future<void> unlikePost(String postId, String userId);

  // Reply operations
  Future<String> createReply({
    required String postId,
    required String channelId,
    required String authorId,
    String? authorName,
    required String content,
    String? mediaUrl,
  });

  Future<PostReply?> getReply(String replyId);

  Future<List<PostReply>> getPostReplies(
    String postId, {
    int limit = 50,
  });

  Future<void> updateReply({
    required String replyId,
    required String content,
  });

  Future<void> deleteReply(String replyId);

  Future<void> likeReply(String replyId, String userId);

  Future<void> unlikeReply(String replyId, String userId);

  // Moderation operations
  Future<String> createModerationRecord({
    required String channelId,
    required String targetUserId,
    required String actionBy,
    required ModerationAction action,
    String? reason,
    DateTime? expiresAt,
  });

  Future<ModerationRecord?> getModerationRecord(String recordId);

  Future<List<ModerationRecord>> getChannelModerationRecords(
    String channelId, {
    int limit = 50,
  });

  Future<List<ModerationRecord>> getUserModerationRecords(
    String userId, {
    int limit = 50,
  });

  Future<void> closeModerationRecord(String recordId);

  // Statistics operations
  Future<void> updateChannelStats(String channelId);

  Future<ChannelStats?> getChannelStats(String channelId);

  Future<int> getTotalChannelsCount();

  Future<int> getChannelMembersCount(String channelId);

  Future<int> getChannelPostsCount(String channelId);

  // Search operations
  Future<List<ChannelPost>> searchPosts({
    required String channelId,
    required String query,
    int limit = 50,
  });

  Future<List<PostReply>> searchReplies({
    required String query,
    int limit = 50,
  });

  // Mention operations (Phase 11 Step 2)
  Future<List<Mention>> extractMentions(
    String content, {
    required String channelId,
  });

  Future<String> createMention({
    required String mentionedUserId,
    required String mentionedUsername,
    required String channelId,
    required String authorId,
    String? authorName,
    String? postId,
    String? replyId,
    String? notificationId,
  });

  Future<List<Mention>> getPostMentions(String postId);

  Future<List<Mention>> getReplyMentions(String replyId);

  Future<List<Mention>> getUserMentions(
    String userId, {
    int limit = 50,
  });

  Future<List<Mention>> getChannelMentions(
    String channelId, {
    int limit = 50,
  });

  Future<int> getMentionCount(String userId);

  Future<bool> validateMention(
    String username, {
    required String channelId,
  });

  Future<List<ChannelMember>> getMentionableCommunityUsers(
    String channelId,
  );

  // Notification operations (Phase 11 Step 2)
  Future<List<UserNotification>> getUserNotifications(
    String userId, {
    bool unreadOnly = false,
    int limit = 50,
    int offset = 0,
  });

  Future<UserNotification?> getNotification(String notificationId);

  Future<String> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String description,
    required String relatedId,
    required String relatedType,
    String? channelId,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  });

  Future<void> markNotificationAsRead(String notificationId);

  Future<void> markAllNotificationsAsRead(String userId);

  Future<void> markPostNotificationsAsRead({
    required String userId,
    required String postId,
  });

  Future<void> deleteNotification(String notificationId);

  Future<void> deleteUserNotifications(String userId);

  Future<void> archiveOldNotifications({
    int olderThanDays = 30,
  });

  Future<void> clearReadNotifications(String userId);

  Future<Map<String, int>> getNotificationSummary(String userId);

  Future<int> getUnreadCount(String userId);

  // Notification preference operations (Phase 11 Step 2)
  Future<NotificationPreferences?> getUserNotificationPreferences(
    String userId,
  );

  Future<void> updateNotificationPreferences(
    String userId,
    NotificationPreferences preferences,
  );

  Future<List<String>> getUsersWithNotificationsEnabled(String channelId);

  Future<void> muteUserNotifications(
    String userId, {
    required Duration duration,
  });

  Future<void> unmuteUserNotifications(String userId);

  // Reaction operations (Phase 11 Step 3)
  Future<String> addPostReaction({
    required String postId,
    required String userId,
    required String emoji,
    ReactionType reactionType = ReactionType.emoji,
  });

  Future<String> addReplyReaction({
    required String replyId,
    required String postId,
    required String userId,
    required String emoji,
    ReactionType reactionType = ReactionType.emoji,
  });

  Future<void> removePostReaction(
    String postId,
    String userId,
    String emoji,
  );

  Future<void> removeReplyReaction(
    String replyId,
    String userId,
    String emoji,
  );

  Future<List<PostReaction>> getPostReactions(String postId);

  Future<List<ReplyReaction>> getReplyReactions(String replyId);

  Future<List<String>> getReactionUsers(
    String postId,
    String emoji,
  );

  Future<int> getReactionCount(String postId);

  Future<PostReaction?> getUserPostReaction(
    String postId,
    String userId,
    String emoji,
  );

  Future<ReplyReaction?> getUserReplyReaction(
    String replyId,
    String userId,
    String emoji,
  );

  // Report operations (Phase 11 Step 3)
  Future<String> reportPost({
    required String postId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
    String? attachmentUrl,
  });

  Future<String> reportReply({
    required String replyId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
    String? attachmentUrl,
  });

  Future<String> reportUser({
    required String reportedUserId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
  });

  Future<ContentReport?> getReport(String reportId);

  Future<List<ContentReport>> getChannelReports(
    String channelId, {
    ReportStatus? statusFilter,
    int limit = 50,
  });

  Future<List<ContentReport>> getUserReports(
    String reportedUserId, {
    int limit = 50,
  });

  Future<List<ContentReport>> getReportedContentReports(
    String contentId, {
    int limit = 50,
  });

  Future<void> actionReport({
    required String reportId,
    required ReportAction action,
    required String moderatorId,
    String? reason,
    String? actionDetails,
  });

  Future<void> dismissReport({
    required String reportId,
    required String moderatorId,
    String? reason,
  });

  Future<Map<String, int>> getReportStats(String channelId);

  // Trending operations (Phase 11 Step 3)
  Future<List<ChannelPost>> getTrendingPosts(
    String channelId, {
    String timeRange = 'day', // 'day', 'week', 'month'
    int limit = 20,
  });

  Future<List<ChannelPost>> getGlobalTrendingPosts({
    String timeRange = 'week',
    int limit = 50,
  });

  Future<List<ChannelPost>> getTrendingByCategory(
    String category, {
    String timeRange = 'week',
    int limit = 20,
  });

  Future<List<String>> getTrendingTags(
    String channelId, {
    int limit = 10,
  });

  Future<double> calculateTrendingScore(String postId);

  Future<PostEngagementAnalytics?> getPostEngagementAnalytics(
    String postId,
  );

  Future<void> updateEngagementAnalytics(String postId);
}

/// Firebase implementation of community service
class FirebaseCommunityService implements CommunityService {
  final FirebaseFirestore _db;

  FirebaseCommunityService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<String> createChannel({
    required String name,
    required String ownerId,
    String? description,
    required ChannelType type,
    String? bannerUrl,
    String? iconUrl,
    String? category,
    List<String> tags = const [],
  }) async {
    final channelId = _db.collection('communityChannels').doc().id;
    final channel = CommunityChannel(
      channelId: channelId,
      name: name,
      description: description,
      type: type,
      ownerId: ownerId,
      moderatorIds: [],
      memberIds: [ownerId],
      bannerUrl: bannerUrl,
      iconUrl: iconUrl,
      memberCount: 1,
      createdAt: DateTime.now(),
      category: category,
      tags: tags,
    );

    await _db.collection('communityChannels').doc(channelId).set(channel.toMap());

    // Create member record for owner
    await addMemberToChannel(
      channelId: channelId,
      userId: ownerId,
      role: MemberRole.owner,
    );

    // Create stats record
    final statsId = _db.collection('channelStats').doc().id;
    final stats = ChannelStats(
      statsId: statsId,
      channelId: channelId,
      totalMembers: 1,
      updatedAt: DateTime.now(),
    );
    await _db.collection('channelStats').doc(statsId).set(stats.toMap());

    return channelId;
  }

  @override
  Future<CommunityChannel?> getChannel(String channelId) async {
    final doc = await _db.collection('communityChannels').doc(channelId).get();
    if (!doc.exists) return null;
    return CommunityChannel.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<CommunityChannel>> getChannelsByCategory(
    String category, {
    int limit = 50,
  }) async {
    final query = _db
        .collection('communityChannels')
        .where('category', isEqualTo: category)
        .where('isArchived', isEqualTo: false)
        .orderBy('lastActivityAt', descending: true)
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => CommunityChannel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CommunityChannel>> searchChannels(
    String query, {
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('communityChannels')
        .where('isArchived', isEqualTo: false)
        .limit(limit)
        .get();

    final allChannels = snapshot.docs
        .map((doc) => CommunityChannel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    return allChannels
        .where((channel) =>
            channel.name.toLowerCase().contains(query.toLowerCase()) ||
            channel.description?.toLowerCase().contains(query.toLowerCase()) ??
            false)
        .toList();
  }

  @override
  Future<List<CommunityChannel>> getPublicChannels({int limit = 50}) async {
    final query = _db
        .collection('communityChannels')
        .where('type', isEqualTo: ChannelType.public.index)
        .where('isArchived', isEqualTo: false)
        .orderBy('lastActivityAt', descending: true)
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => CommunityChannel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateChannel(String channelId, CommunityChannel channel) async {
    await _db.collection('communityChannels').doc(channelId).set(
          channel.toMap(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> archiveChannel(String channelId) async {
    await _db.collection('communityChannels').doc(channelId).update({
      'isArchived': true,
    });
  }

  @override
  Future<String> addMemberToChannel({
    required String channelId,
    required String userId,
    MemberRole role = MemberRole.member,
  }) async {
    final memberId = _db.collection('channelMembers').doc().id;
    final member = ChannelMember(
      memberId: memberId,
      channelId: channelId,
      userId: userId,
      role: role,
      joinedAt: DateTime.now(),
    );

    await _db.collection('channelMembers').doc(memberId).set(member.toMap());

    // Update channel member list and count
    final channel = await getChannel(channelId);
    if (channel != null) {
      final updatedMembers = [...channel.memberIds];
      if (!updatedMembers.contains(userId)) {
        updatedMembers.add(userId);
      }
      await updateChannel(
        channelId,
        channel.copyWith(
          memberIds: updatedMembers,
          memberCount: updatedMembers.length,
        ),
      );
    }

    return memberId;
  }

  @override
  Future<ChannelMember?> getChannelMember(String channelId, String userId) async {
    final query = _db
        .collection('channelMembers')
        .where('channelId', isEqualTo: channelId)
        .where('userId', isEqualTo: userId);

    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) return null;
    return ChannelMember.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
  }

  @override
  Future<List<ChannelMember>> getChannelMembers(
    String channelId, {
    int limit = 50,
  }) async {
    final query = _db
        .collection('channelMembers')
        .where('channelId', isEqualTo: channelId)
        .where('isBanned', isEqualTo: false)
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ChannelMember.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ChannelMember>> getChannelModerators(String channelId) async {
    final query = _db
        .collection('channelMembers')
        .where('channelId', isEqualTo: channelId)
        .where('role', whereIn: [MemberRole.owner.index, MemberRole.moderator.index]);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ChannelMember.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateMemberRole({
    required String channelId,
    required String userId,
    required MemberRole newRole,
  }) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      await _db.collection('channelMembers').doc(member.memberId).update({
        'role': newRole.index,
      });

      // Update channel moderator list
      final channel = await getChannel(channelId);
      if (channel != null) {
        var updatedModerators = [...channel.moderatorIds];
        if (newRole == MemberRole.moderator &&
            !updatedModerators.contains(userId)) {
          updatedModerators.add(userId);
        } else if (newRole != MemberRole.moderator) {
          updatedModerators.removeWhere((id) => id == userId);
        }
        await updateChannel(
          channelId,
          channel.copyWith(moderatorIds: updatedModerators),
        );
      }
    }
  }

  @override
  Future<void> removeMemberFromChannel(String channelId, String userId) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      await _db.collection('channelMembers').doc(member.memberId).delete();

      // Update channel member list
      final channel = await getChannel(channelId);
      if (channel != null) {
        final updatedMembers =
            channel.memberIds.where((id) => id != userId).toList();
        await updateChannel(
          channelId,
          channel.copyWith(
            memberIds: updatedMembers,
            memberCount: updatedMembers.length,
          ),
        );
      }
    }
  }

  @override
  Future<void> muteChannelMember({
    required String channelId,
    required String userId,
  }) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      await _db.collection('channelMembers').doc(member.memberId).update({
        'isMuted': true,
      });
    }
  }

  @override
  Future<void> unmuteChannelMember({
    required String channelId,
    required String userId,
  }) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      await _db.collection('channelMembers').doc(member.memberId).update({
        'isMuted': false,
      });
    }
  }

  @override
  Future<void> banChannelMember({
    required String channelId,
    required String userId,
    String? reason,
  }) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      await _db.collection('channelMembers').doc(member.memberId).update({
        'isBanned': true,
        'banReason': reason,
      });
    }
  }

  @override
  Future<void> unbanChannelMember(String channelId, String userId) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      await _db.collection('channelMembers').doc(member.memberId).update({
        'isBanned': false,
        'banReason': null,
      });
    }
  }

  @override
  Future<String> createPost({
    required String channelId,
    required String authorId,
    String? authorName,
    required String content,
    String? mediaUrl,
    List<String> tags = const [],
  }) async {
    final postId = _db.collection('channelPosts').doc().id;
    final post = ChannelPost(
      postId: postId,
      channelId: channelId,
      authorId: authorId,
      authorName: authorName,
      content: content,
      status: PostStatus.published,
      createdAt: DateTime.now(),
      mediaUrl: mediaUrl,
      tags: tags,
    );

    await _db.collection('channelPosts').doc(postId).set(post.toMap());

    // Update channel stats
    await updateChannelStats(channelId);

    return postId;
  }

  @override
  Future<ChannelPost?> getPost(String postId) async {
    final doc = await _db.collection('channelPosts').doc(postId).get();
    if (!doc.exists) return null;
    return ChannelPost.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<ChannelPost>> getChannelPosts(
    String channelId, {
    PostStatus? statusFilter,
    int limit = 50,
  }) async {
    Query query = _db
        .collection('channelPosts')
        .where('channelId', isEqualTo: channelId);

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter.index);
    }

    query = query.orderBy('isPinned', descending: true).orderBy('createdAt', descending: true).limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ChannelPost.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ChannelPost>> getPinnedPosts(String channelId) async {
    final query = _db
        .collection('channelPosts')
        .where('channelId', isEqualTo: channelId)
        .where('isPinned', isEqualTo: true)
        .orderBy('pinPosition', descending: true);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ChannelPost.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updatePost({
    required String postId,
    required String content,
  }) async {
    await _db.collection('channelPosts').doc(postId).update({
      'content': content,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> publishPost(String postId) async {
    await _db.collection('channelPosts').doc(postId).update({
      'status': PostStatus.published.index,
    });
  }

  @override
  Future<void> deletePost(String postId) async {
    await _db.collection('channelPosts').doc(postId).update({
      'status': PostStatus.archived.index,
    });
  }

  @override
  Future<void> pinPost({
    required String postId,
    required int position,
  }) async {
    await _db.collection('channelPosts').doc(postId).update({
      'isPinned': true,
      'pinPosition': position,
    });
  }

  @override
  Future<void> unpinPost(String postId) async {
    await _db.collection('channelPosts').doc(postId).update({
      'isPinned': false,
      'pinPosition': null,
    });
  }

  @override
  Future<void> incrementPostViews(String postId) async {
    await _db.collection('channelPosts').doc(postId).update({
      'views': FieldValue.increment(1),
    });
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    await _db.collection('channelPosts').doc(postId).update({
      'likes': FieldValue.increment(1),
      'likedBy': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    await _db.collection('channelPosts').doc(postId).update({
      'likes': FieldValue.increment(-1),
      'likedBy': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<String> createReply({
    required String postId,
    required String channelId,
    required String authorId,
    String? authorName,
    required String content,
    String? mediaUrl,
  }) async {
    final replyId = _db.collection('postReplies').doc().id;
    final reply = PostReply(
      replyId: replyId,
      postId: postId,
      channelId: channelId,
      authorId: authorId,
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
      mediaUrl: mediaUrl,
    );

    await _db.collection('postReplies').doc(replyId).set(reply.toMap());

    // Update post reply count
    await _db.collection('channelPosts').doc(postId).update({
      'replies': FieldValue.increment(1),
    });

    return replyId;
  }

  @override
  Future<PostReply?> getReply(String replyId) async {
    final doc = await _db.collection('postReplies').doc(replyId).get();
    if (!doc.exists) return null;
    return PostReply.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<PostReply>> getPostReplies(
    String postId, {
    int limit = 50,
  }) async {
    final query = _db
        .collection('postReplies')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => PostReply.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateReply({
    required String replyId,
    required String content,
  }) async {
    await _db.collection('postReplies').doc(replyId).update({
      'content': content,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> deleteReply(String replyId) async {
    final reply = await getReply(replyId);
    if (reply != null) {
      await _db.collection('postReplies').doc(replyId).delete();

      // Update post reply count
      await _db.collection('channelPosts').doc(reply.postId).update({
        'replies': FieldValue.increment(-1),
      });
    }
  }

  @override
  Future<void> likeReply(String replyId, String userId) async {
    await _db.collection('postReplies').doc(replyId).update({
      'likes': FieldValue.increment(1),
      'likedBy': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> unlikeReply(String replyId, String userId) async {
    await _db.collection('postReplies').doc(replyId).update({
      'likes': FieldValue.increment(-1),
      'likedBy': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<String> createModerationRecord({
    required String channelId,
    required String targetUserId,
    required String actionBy,
    required ModerationAction action,
    String? reason,
    DateTime? expiresAt,
  }) async {
    final recordId = _db.collection('moderationRecords').doc().id;
    final record = ModerationRecord(
      recordId: recordId,
      channelId: channelId,
      targetUserId: targetUserId,
      actionBy: actionBy,
      action: action,
      reason: reason,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
    );

    await _db.collection('moderationRecords').doc(recordId).set(record.toMap());

    return recordId;
  }

  @override
  Future<ModerationRecord?> getModerationRecord(String recordId) async {
    final doc = await _db.collection('moderationRecords').doc(recordId).get();
    if (!doc.exists) return null;
    return ModerationRecord.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<ModerationRecord>> getChannelModerationRecords(
    String channelId, {
    int limit = 50,
  }) async {
    final query = _db
        .collection('moderationRecords')
        .where('channelId', isEqualTo: channelId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ModerationRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ModerationRecord>> getUserModerationRecords(
    String userId, {
    int limit = 50,
  }) async {
    final query = _db
        .collection('moderationRecords')
        .where('targetUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ModerationRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> closeModerationRecord(String recordId) async {
    await _db.collection('moderationRecords').doc(recordId).update({
      'isActive': false,
    });
  }

  @override
  Future<void> updateChannelStats(String channelId) async {
    final postsCount = await getChannelPostsCount(channelId);
    final membersCount = await getChannelMembersCount(channelId);

    final query = _db
        .collection('channelStats')
        .where('channelId', isEqualTo: channelId);
    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      await _db.collection('channelStats').doc(doc.id).update({
        'totalMembers': membersCount,
        'totalPosts': postsCount,
        'updatedAt': Timestamp.now(),
      });
    }
  }

  @override
  Future<ChannelStats?> getChannelStats(String channelId) async {
    final query = _db
        .collection('channelStats')
        .where('channelId', isEqualTo: channelId);

    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) return null;
    return ChannelStats.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
  }

  @override
  Future<int> getTotalChannelsCount() async {
    final query = _db.collection('communityChannels').where('isArchived', isEqualTo: false);
    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<int> getChannelMembersCount(String channelId) async {
    final query = _db
        .collection('channelMembers')
        .where('channelId', isEqualTo: channelId)
        .where('isBanned', isEqualTo: false);

    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<int> getChannelPostsCount(String channelId) async {
    final query = _db
        .collection('channelPosts')
        .where('channelId', isEqualTo: channelId)
        .where('status', isEqualTo: PostStatus.published.index);

    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<List<ChannelPost>> searchPosts({
    required String channelId,
    required String query,
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('channelPosts')
        .where('channelId', isEqualTo: channelId)
        .where('status', isEqualTo: PostStatus.published.index)
        .limit(limit)
        .get();

    final allPosts = snapshot.docs
        .map((doc) => ChannelPost.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    return allPosts
        .where((post) => post.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<PostReply>> searchReplies({
    required String query,
    int limit = 50,
  }) async {
    final snapshot = await _db.collection('postReplies').limit(limit).get();

    final allReplies = snapshot.docs
        .map((doc) => PostReply.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    return allReplies
        .where((reply) => reply.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // ============ MENTION OPERATIONS (Phase 11 Step 2) ============

  @override
  Future<List<Mention>> extractMentions(
    String content, {
    required String channelId,
  }) async {
    final regex = RegExp(r'@(\w+)');
    final matches = regex.allMatches(content);
    final mentions = <Mention>[];
    final seenUsernames = <String>{};

    // Get channel members
    final memberSnapshot = await _db
        .collection('channelMembers')
        .where('channelId', isEqualTo: channelId)
        .get();

    final memberUserIds = memberSnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['userId'] as String)
        .toSet();

    for (final match in matches) {
      final username = match.group(1)!.toLowerCase();
      if (seenUsernames.add(username) && memberUserIds.contains(username)) {
        mentions.add(
          Mention(
            mentionId: 'mention_${DateTime.now().millisecondsSinceEpoch}',
            mentionedUserId: username,
            mentionedUsername: username,
            channelId: channelId,
            authorId: '',
            mentionedAt: DateTime.now(),
          ),
        );
      }
    }
    return mentions;
  }

  @override
  Future<String> createMention({
    required String mentionedUserId,
    required String mentionedUsername,
    required String channelId,
    required String authorId,
    String? authorName,
    String? postId,
    String? replyId,
    String? notificationId,
  }) async {
    final mentionId = 'mention_${DateTime.now().millisecondsSinceEpoch}';
    await _db.collection('mentions').doc(mentionId).set({
      'mentionId': mentionId,
      'mentionedUserId': mentionedUserId,
      'mentionedUsername': mentionedUsername,
      'postId': postId,
      'replyId': replyId,
      'channelId': channelId,
      'authorId': authorId,
      'authorName': authorName,
      'mentionedAt': Timestamp.now(),
      'notificationId': notificationId,
    });
    return mentionId;
  }

  @override
  Future<List<Mention>> getPostMentions(String postId) async {
    final snapshot = await _db
        .collection('mentions')
        .where('postId', isEqualTo: postId)
        .where('replyId', isEqualTo: null)
        .get();

    return snapshot.docs
        .map((doc) => Mention.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<Mention>> getReplyMentions(String replyId) async {
    final snapshot = await _db
        .collection('mentions')
        .where('replyId', isEqualTo: replyId)
        .get();

    return snapshot.docs
        .map((doc) => Mention.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<Mention>> getUserMentions(
    String userId, {
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('mentions')
        .where('mentionedUserId', isEqualTo: userId)
        .orderBy('mentionedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => Mention.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<Mention>> getChannelMentions(
    String channelId, {
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('mentions')
        .where('channelId', isEqualTo: channelId)
        .orderBy('mentionedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => Mention.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<int> getMentionCount(String userId) async {
    final snapshot = await _db
        .collection('mentions')
        .where('mentionedUserId', isEqualTo: userId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  @override
  Future<bool> validateMention(
    String username, {
    required String channelId,
  }) async {
    final snapshot = await _db
        .collection('channelMembers')
        .where('channelId', isEqualTo: channelId)
        .where('userId', isEqualTo: username)
        .where('isBanned', isEqualTo: false)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  @override
  Future<List<ChannelMember>> getMentionableCommunityUsers(
    String channelId,
  ) async {
    final snapshot = await _db
        .collection('channelMembers')
        .where('channelId', isEqualTo: channelId)
        .where('isBanned', isEqualTo: false)
        .get();

    return snapshot.docs
        .map((doc) => ChannelMember.fromMap(doc.data()))
        .toList();
  }

  // ============ NOTIFICATION OPERATIONS (Phase 11 Step 2) ============

  @override
  Future<List<UserNotification>> getUserNotifications(
    String userId, {
    bool unreadOnly = false,
    int limit = 50,
    int offset = 0,
  }) async {
    var query = _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true);

    if (unreadOnly) {
      query = query.where('isRead', isEqualTo: false);
    }

    final snapshot = await query
        .limit(limit + offset)
        .get();

    return snapshot.docs
        .skip(offset)
        .map((doc) => UserNotification.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<UserNotification?> getNotification(String notificationId) async {
    // Search across all users (inefficient but works for now)
    // In production, store notificationId -> userId mapping
    final snapshot = await _db
        .collectionGroup('notifications')
        .where('notificationId', isEqualTo: notificationId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return UserNotification.fromMap(snapshot.docs.first.data());
  }

  @override
  Future<String> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String description,
    required String relatedId,
    required String relatedType,
    String? channelId,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) async {
    // Check preferences
    final prefs = await getUserNotificationPreferences(userId);
    if (prefs?.isCurrentlyMuted ?? false) {
      return '';
    }

    // Check type-specific preferences
    bool shouldCreate = true;
    if (prefs != null) {
      switch (type) {
        case NotificationType.mention:
          shouldCreate = prefs.mentionNotifications;
          break;
        case NotificationType.reply:
          shouldCreate = prefs.replyNotifications;
          break;
        case NotificationType.likePost:
        case NotificationType.likeReply:
          shouldCreate = prefs.likeNotifications;
          break;
        case NotificationType.moderation:
          shouldCreate = prefs.moderationNotifications;
          break;
        case NotificationType.channelEvent:
        case NotificationType.channelAnnounce:
          shouldCreate = prefs.channelAnnouncements;
          break;
      }
    }

    if (!shouldCreate) {
      return '';
    }

    // Check for duplicates
    final dupSnapshot = await _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .where('type', isEqualTo: type.index)
        .where('relatedId', isEqualTo: relatedId)
        .where('isRead', isEqualTo: false)
        .limit(1)
        .get();

    if (dupSnapshot.docs.isNotEmpty) {
      return '';
    }

    final notificationId = 'notif_${DateTime.now().millisecondsSinceEpoch}';
    await _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .set({
      'notificationId': notificationId,
      'userId': userId,
      'type': type.index,
      'title': title,
      'description': description,
      'relatedId': relatedId,
      'relatedType': relatedType,
      'channelId': channelId,
      'isRead': false,
      'createdAt': Timestamp.now(),
      'readAt': null,
      'actionUrl': actionUrl,
      'metadata': metadata,
    });

    return notificationId;
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    // Need to find the notification first (inefficient in production)
    final snapshot = await _db
        .collectionGroup('notifications')
        .where('notificationId', isEqualTo: notificationId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final userId = doc.reference.parent.parent?.id;
      if (userId != null) {
        await doc.reference.update({
          'isRead': true,
          'readAt': Timestamp.now(),
        });
      }
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
    final snapshot = await _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': Timestamp.now(),
      });
    }
    await batch.commit();
  }

  @override
  Future<void> markPostNotificationsAsRead({
    required String userId,
    required String postId,
  }) async {
    final snapshot = await _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .where('relatedId', isEqualTo: postId)
        .get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': Timestamp.now(),
      });
    }
    await batch.commit();
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final snapshot = await _db
        .collectionGroup('notifications')
        .where('notificationId', isEqualTo: notificationId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();
    }
  }

  @override
  Future<void> deleteUserNotifications(String userId) async {
    final snapshot = await _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<void> archiveOldNotifications({
    int olderThanDays = 30,
  }) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));

    // This would need to be done per-user in production
    // For now, this is a placeholder
  }

  @override
  Future<void> clearReadNotifications(String userId) async {
    final snapshot = await _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: true)
        .get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<Map<String, int>> getNotificationSummary(String userId) async {
    final snapshot = await _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .get();

    final notifs = snapshot.docs
        .map((doc) => UserNotification.fromMap(doc.data()))
        .toList();

    return {
      'mentions': notifs
          .where((n) => n.type == NotificationType.mention)
          .length,
      'replies': notifs
          .where((n) => n.type == NotificationType.reply)
          .length,
      'likes': notifs
          .where((n) =>
              n.type == NotificationType.likePost ||
              n.type == NotificationType.likeReply)
          .length,
      'moderation': notifs
          .where((n) => n.type == NotificationType.moderation)
          .length,
      'total': notifs.length,
      'unread': notifs.where((n) => n.isUnread).length,
    };
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final snapshot = await _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  // ============ NOTIFICATION PREFERENCE OPERATIONS (Phase 11 Step 2) ============

  @override
  Future<NotificationPreferences?> getUserNotificationPreferences(
    String userId,
  ) async {
    final doc = await _db
        .collection('notificationPreferences')
        .doc(userId)
        .get();

    if (!doc.exists) return null;
    return NotificationPreferences.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> updateNotificationPreferences(
    String userId,
    NotificationPreferences preferences,
  ) async {
    await _db
        .collection('notificationPreferences')
        .doc(userId)
        .set(preferences.toMap(), SetOptions(merge: true));
  }

  @override
  Future<List<String>> getUsersWithNotificationsEnabled(
    String channelId,
  ) async {
    final memberSnapshot = await _db
        .collection('channelMembers')
        .where('channelId', isEqualTo: channelId)
        .where('isBanned', isEqualTo: false)
        .get();

    final enabledUsers = <String>[];
    for (final memberDoc in memberSnapshot.docs) {
      final userId = (memberDoc.data() as Map<String, dynamic>)['userId'] as String;
      final prefs = await getUserNotificationPreferences(userId);

      if (prefs == null || prefs.hasAnyNotificationsEnabled) {
        enabledUsers.add(userId);
      }
    }

    return enabledUsers;
  }

  @override
  Future<void> muteUserNotifications(
    String userId, {
    required Duration duration,
  }) async {
    final prefs = await getUserNotificationPreferences(userId) ??
        NotificationPreferences.empty(userId);

    final muteUntil = DateTime.now().add(duration);
    await updateNotificationPreferences(
      userId,
      prefs.copyWith(muteUntil: muteUntil),
    );
  }

  @override
  Future<void> unmuteUserNotifications(String userId) async {
    final prefs = await getUserNotificationPreferences(userId);
    if (prefs != null) {
      await updateNotificationPreferences(
        userId,
        prefs.copyWith(muteUntil: null),
      );
    }
  }

  // ============ REACTION OPERATIONS (Phase 11 Step 3) ============

  @override
  Future<String> addPostReaction({
    required String postId,
    required String userId,
    required String emoji,
    ReactionType reactionType = ReactionType.emoji,
  }) async {
    final reactionId = 'reaction_${DateTime.now().millisecondsSinceEpoch}';
    await _db.collection('postReactions').doc(reactionId).set({
      'reactionId': reactionId,
      'postId': postId,
      'userId': userId,
      'emoji': emoji,
      'reactionType': reactionType.index,
      'createdAt': Timestamp.now(),
    });
    return reactionId;
  }

  @override
  Future<String> addReplyReaction({
    required String replyId,
    required String postId,
    required String userId,
    required String emoji,
    ReactionType reactionType = ReactionType.emoji,
  }) async {
    final reactionId = 'reaction_${DateTime.now().millisecondsSinceEpoch}';
    await _db.collection('replyReactions').doc(reactionId).set({
      'reactionId': reactionId,
      'replyId': replyId,
      'postId': postId,
      'userId': userId,
      'emoji': emoji,
      'reactionType': reactionType.index,
      'createdAt': Timestamp.now(),
    });
    return reactionId;
  }

  @override
  Future<void> removePostReaction(String postId, String userId, String emoji) async {
    final snapshot = await _db
        .collection('postReactions')
        .where('postId', isEqualTo: postId)
        .where('userId', isEqualTo: userId)
        .where('emoji', isEqualTo: emoji)
        .limit(1)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<void> removeReplyReaction(String replyId, String userId, String emoji) async {
    final snapshot = await _db
        .collection('replyReactions')
        .where('replyId', isEqualTo: replyId)
        .where('userId', isEqualTo: userId)
        .where('emoji', isEqualTo: emoji)
        .limit(1)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<List<PostReaction>> getPostReactions(String postId) async {
    final snapshot = await _db
        .collection('postReactions')
        .where('postId', isEqualTo: postId)
        .get();

    return snapshot.docs
        .map((doc) => PostReaction.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<ReplyReaction>> getReplyReactions(String replyId) async {
    final snapshot = await _db
        .collection('replyReactions')
        .where('replyId', isEqualTo: replyId)
        .get();

    return snapshot.docs
        .map((doc) => ReplyReaction.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<String>> getReactionUsers(String postId, String emoji) async {
    final snapshot = await _db
        .collection('postReactions')
        .where('postId', isEqualTo: postId)
        .where('emoji', isEqualTo: emoji)
        .get();

    return snapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['userId'] as String)
        .toList();
  }

  @override
  Future<int> getReactionCount(String postId) async {
    final snapshot = await _db
        .collection('postReactions')
        .where('postId', isEqualTo: postId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  @override
  Future<PostReaction?> getUserPostReaction(
    String postId,
    String userId,
    String emoji,
  ) async {
    final snapshot = await _db
        .collection('postReactions')
        .where('postId', isEqualTo: postId)
        .where('userId', isEqualTo: userId)
        .where('emoji', isEqualTo: emoji)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return PostReaction.fromMap(snapshot.docs.first.data());
  }

  @override
  Future<ReplyReaction?> getUserReplyReaction(
    String replyId,
    String userId,
    String emoji,
  ) async {
    final snapshot = await _db
        .collection('replyReactions')
        .where('replyId', isEqualTo: replyId)
        .where('userId', isEqualTo: userId)
        .where('emoji', isEqualTo: emoji)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return ReplyReaction.fromMap(snapshot.docs.first.data());
  }

  // ============ REPORT OPERATIONS (Phase 11 Step 3) ============

  @override
  Future<String> reportPost({
    required String postId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
    String? attachmentUrl,
  }) async {
    final post = await getPost(postId);
    final reportId = 'report_${DateTime.now().millisecondsSinceEpoch}';

    await _db.collection('contentReports').doc(reportId).set({
      'reportId': reportId,
      'contentId': postId,
      'contentType': 'post',
      'reportedByUserId': reportedByUserId,
      'channelId': post?.channelId ?? '',
      'category': category.index,
      'description': description,
      'attachmentUrl': attachmentUrl,
      'status': ReportStatus.pending.index,
      'createdAt': Timestamp.now(),
    });

    return reportId;
  }

  @override
  Future<String> reportReply({
    required String replyId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
    String? attachmentUrl,
  }) async {
    final reply = await getReply(replyId);
    final reportId = 'report_${DateTime.now().millisecondsSinceEpoch}';

    await _db.collection('contentReports').doc(reportId).set({
      'reportId': reportId,
      'contentId': replyId,
      'contentType': 'reply',
      'reportedByUserId': reportedByUserId,
      'channelId': reply?.channelId ?? '',
      'category': category.index,
      'description': description,
      'attachmentUrl': attachmentUrl,
      'status': ReportStatus.pending.index,
      'createdAt': Timestamp.now(),
    });

    return reportId;
  }

  @override
  Future<String> reportUser({
    required String reportedUserId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
  }) async {
    final reportId = 'report_${DateTime.now().millisecondsSinceEpoch}';

    await _db.collection('contentReports').doc(reportId).set({
      'reportId': reportId,
      'contentId': reportedUserId,
      'contentType': 'user',
      'reportedByUserId': reportedByUserId,
      'reportedUserId': reportedUserId,
      'category': category.index,
      'description': description,
      'status': ReportStatus.pending.index,
      'createdAt': Timestamp.now(),
    });

    return reportId;
  }

  @override
  Future<ContentReport?> getReport(String reportId) async {
    final doc = await _db.collection('contentReports').doc(reportId).get();
    if (!doc.exists) return null;
    return ContentReport.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<ContentReport>> getChannelReports(
    String channelId, {
    ReportStatus? statusFilter,
    int limit = 50,
  }) async {
    var query = _db
        .collection('contentReports')
        .where('channelId', isEqualTo: channelId);

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter.index);
    }

    final snapshot = await query.limit(limit).get();

    return snapshot.docs
        .map((doc) => ContentReport.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<ContentReport>> getUserReports(
    String reportedUserId, {
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('contentReports')
        .where('reportedUserId', isEqualTo: reportedUserId)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ContentReport.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<ContentReport>> getReportedContentReports(
    String contentId, {
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('contentReports')
        .where('contentId', isEqualTo: contentId)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ContentReport.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<void> actionReport({
    required String reportId,
    required ReportAction action,
    required String moderatorId,
    String? reason,
    String? actionDetails,
  }) async {
    await _db.collection('contentReports').doc(reportId).update({
      'status': ReportStatus.upheld.index,
      'reviewedAt': Timestamp.now(),
      'reviewedBy': moderatorId,
      'action': action.index,
      'actionReason': reason,
      'actionDetails': actionDetails,
    });
  }

  @override
  Future<void> dismissReport({
    required String reportId,
    required String moderatorId,
    String? reason,
  }) async {
    await _db.collection('contentReports').doc(reportId).update({
      'status': ReportStatus.dismissed.index,
      'reviewedAt': Timestamp.now(),
      'reviewedBy': moderatorId,
      'actionReason': reason,
    });
  }

  @override
  Future<Map<String, int>> getReportStats(String channelId) async {
    final snapshot = await _db
        .collection('contentReports')
        .where('channelId', isEqualTo: channelId)
        .get();

    final reports = snapshot.docs;
    return {
      'total': reports.length,
      'pending': reports
          .where((r) =>
              (r.data() as Map<String, dynamic>)['status'] ==
              ReportStatus.pending.index)
          .length,
      'upheld': reports
          .where((r) =>
              (r.data() as Map<String, dynamic>)['status'] ==
              ReportStatus.upheld.index)
          .length,
      'dismissed': reports
          .where((r) =>
              (r.data() as Map<String, dynamic>)['status'] ==
              ReportStatus.dismissed.index)
          .length,
    };
  }

  // ============ TRENDING OPERATIONS (Phase 11 Step 3) ============

  @override
  Future<List<ChannelPost>> getTrendingPosts(
    String channelId, {
    String timeRange = 'day',
    int limit = 20,
  }) async {
    final posts = await getChannelPosts(channelId, statusFilter: PostStatus.published);
    posts.sort((a, b) {
      final scoreA = (a.likes * 1) + (a.replies * 3) + (a.views * 0.1);
      final scoreB = (b.likes * 1) + (b.replies * 3) + (b.views * 0.1);
      return scoreB.compareTo(scoreA);
    });
    return posts.take(limit).toList();
  }

  @override
  Future<List<ChannelPost>> getGlobalTrendingPosts({
    String timeRange = 'week',
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('channelPosts')
        .where('status', isEqualTo: PostStatus.published.index)
        .limit(limit * 2)
        .get();

    final posts = snapshot.docs
        .map((doc) => ChannelPost.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    posts.sort((a, b) {
      final scoreA = (a.likes * 1) + (a.replies * 3) + (a.views * 0.1);
      final scoreB = (b.likes * 1) + (b.replies * 3) + (b.views * 0.1);
      return scoreB.compareTo(scoreA);
    });

    return posts.take(limit).toList();
  }

  @override
  Future<List<ChannelPost>> getTrendingByCategory(
    String category, {
    String timeRange = 'week',
    int limit = 20,
  }) async {
    final channelSnapshot = await _db
        .collection('communityChannels')
        .where('category', isEqualTo: category)
        .get();

    final channelIds = channelSnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['channelId'] as String)
        .toSet();

    if (channelIds.isEmpty) return [];

    final posts = <ChannelPost>[];
    for (final channelId in channelIds) {
      posts.addAll(await getChannelPosts(channelId, statusFilter: PostStatus.published));
    }

    posts.sort((a, b) {
      final scoreA = (a.likes * 1) + (a.replies * 3) + (a.views * 0.1);
      final scoreB = (b.likes * 1) + (b.replies * 3) + (b.views * 0.1);
      return scoreB.compareTo(scoreA);
    });

    return posts.take(limit).toList();
  }

  @override
  Future<List<String>> getTrendingTags(
    String channelId, {
    int limit = 10,
  }) async {
    final posts = await getChannelPosts(channelId);
    final tagCounts = <String, int>{};

    for (final post in posts) {
      for (final tag in post.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    final sorted = tagCounts.entries.toList();
    sorted.sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((e) => e.key).take(limit).toList();
  }

  @override
  Future<double> calculateTrendingScore(String postId) async {
    final post = await getPost(postId);
    if (post == null) return 0.0;

    final engagementScore = (post.likes * 1) + (post.replies * 3) + (post.views * 0.1);
    final ageHours = DateTime.now().difference(post.createdAt).inHours;
    final timeDecay = 1.0 / (1.0 + (ageHours / 24.0));

    return engagementScore * timeDecay;
  }

  @override
  Future<PostEngagementAnalytics?> getPostEngagementAnalytics(
    String postId,
  ) async {
    final doc = await _db
        .collection('postEngagementAnalytics')
        .doc(postId)
        .get();

    if (!doc.exists) return null;
    return PostEngagementAnalytics.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> updateEngagementAnalytics(String postId) async {
    final post = await getPost(postId);
    if (post == null) return;

    final trendingScore = await calculateTrendingScore(postId);
    final reactionCount = await getReactionCount(postId);

    await _db.collection('postEngagementAnalytics').doc(postId).set({
      'analyticsId': postId,
      'postId': postId,
      'channelId': post.channelId,
      'reactionCount': reactionCount,
      'replyCount': post.replies,
      'likeCount': post.likes,
      'viewCount': post.views,
      'trendingScore': trendingScore,
      'lastUpdatedAt': Timestamp.now(),
    });
  }
}

/// Stub implementation for testing
class StubCommunityService implements CommunityService {
  final Map<String, CommunityChannel> _channels = {};
  final Map<String, ChannelMember> _members = {};
  final Map<String, ChannelPost> _posts = {};
  final Map<String, PostReply> _replies = {};
  final Map<String, ModerationRecord> _records = {};
  final Map<String, ChannelStats> _stats = {};
  final Map<String, Mention> _mentions = {}; // Phase 11 Step 2
  final Map<String, UserNotification> _notifications = {}; // Phase 11 Step 2
  final Map<String, NotificationPreferences> _preferences = {}; // Phase 11 Step 2
  final Map<String, PostReaction> _postReactions = {}; // Phase 11 Step 3
  final Map<String, ReplyReaction> _replyReactions = {}; // Phase 11 Step 3
  final Map<String, ContentReport> _reports = {}; // Phase 11 Step 3
  final Map<String, PostEngagementAnalytics> _analytics = {}; // Phase 11 Step 3

  @override
  Future<String> createChannel({
    required String name,
    required String ownerId,
    String? description,
    required ChannelType type,
    String? bannerUrl,
    String? iconUrl,
    String? category,
    List<String> tags = const [],
  }) async {
    final channelId = 'channel_${_channels.length}';
    _channels[channelId] = CommunityChannel(
      channelId: channelId,
      name: name,
      description: description,
      type: type,
      ownerId: ownerId,
      memberIds: [ownerId],
      bannerUrl: bannerUrl,
      iconUrl: iconUrl,
      memberCount: 1,
      createdAt: DateTime.now(),
      category: category,
      tags: tags,
    );

    final memberId = 'member_${_members.length}';
    _members[memberId] = ChannelMember(
      memberId: memberId,
      channelId: channelId,
      userId: ownerId,
      role: MemberRole.owner,
      joinedAt: DateTime.now(),
    );

    final statsId = 'stats_$channelId';
    _stats[statsId] = ChannelStats(
      statsId: statsId,
      channelId: channelId,
      totalMembers: 1,
      updatedAt: DateTime.now(),
    );

    return channelId;
  }

  @override
  Future<CommunityChannel?> getChannel(String channelId) async {
    return _channels[channelId];
  }

  @override
  Future<List<CommunityChannel>> getChannelsByCategory(
    String category, {
    int limit = 50,
  }) async {
    return _channels.values
        .where((ch) => ch.category == category && !ch.isArchived)
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<CommunityChannel>> searchChannels(
    String query, {
    int limit = 50,
  }) async {
    return _channels.values
        .where((ch) =>
            !ch.isArchived &&
            (ch.name.toLowerCase().contains(query.toLowerCase()) ||
                ch.description?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<CommunityChannel>> getPublicChannels({int limit = 50}) async {
    return _channels.values
        .where((ch) => ch.isPublic && !ch.isArchived)
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<void> updateChannel(String channelId, CommunityChannel channel) async {
    _channels[channelId] = channel;
  }

  @override
  Future<void> archiveChannel(String channelId) async {
    final channel = _channels[channelId];
    if (channel != null) {
      _channels[channelId] = channel.copyWith(isArchived: true);
    }
  }

  @override
  Future<String> addMemberToChannel({
    required String channelId,
    required String userId,
    MemberRole role = MemberRole.member,
  }) async {
    final memberId = 'member_${_members.length}';
    _members[memberId] = ChannelMember(
      memberId: memberId,
      channelId: channelId,
      userId: userId,
      role: role,
      joinedAt: DateTime.now(),
    );

    final channel = _channels[channelId];
    if (channel != null) {
      final updatedMembers = [...channel.memberIds];
      if (!updatedMembers.contains(userId)) {
        updatedMembers.add(userId);
      }
      _channels[channelId] = channel.copyWith(
        memberIds: updatedMembers,
        memberCount: updatedMembers.length,
      );
    }

    return memberId;
  }

  @override
  Future<ChannelMember?> getChannelMember(String channelId, String userId) async {
    return _members.values.firstWhere(
      (m) => m.channelId == channelId && m.userId == userId,
      orElse: () => ChannelMember.empty(),
    ) as ChannelMember?;
  }

  @override
  Future<List<ChannelMember>> getChannelMembers(
    String channelId, {
    int limit = 50,
  }) async {
    return _members.values
        .where((m) => m.channelId == channelId && !m.isBanned)
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<ChannelMember>> getChannelModerators(String channelId) async {
    return _members.values
        .where((m) =>
            m.channelId == channelId &&
            (m.isOwner || m.isModerator))
        .toList();
  }

  @override
  Future<void> updateMemberRole({
    required String channelId,
    required String userId,
    required MemberRole newRole,
  }) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      _members[member.memberId] = member.copyWith(role: newRole);
    }
  }

  @override
  Future<void> removeMemberFromChannel(String channelId, String userId) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      _members.remove(member.memberId);

      final channel = _channels[channelId];
      if (channel != null) {
        final updatedMembers =
            channel.memberIds.where((id) => id != userId).toList();
        _channels[channelId] = channel.copyWith(
          memberIds: updatedMembers,
          memberCount: updatedMembers.length,
        );
      }
    }
  }

  @override
  Future<void> muteChannelMember({
    required String channelId,
    required String userId,
  }) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      _members[member.memberId] = member.copyWith(isMuted: true);
    }
  }

  @override
  Future<void> unmuteChannelMember({
    required String channelId,
    required String userId,
  }) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      _members[member.memberId] = member.copyWith(isMuted: false);
    }
  }

  @override
  Future<void> banChannelMember({
    required String channelId,
    required String userId,
    String? reason,
  }) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      _members[member.memberId] =
          member.copyWith(isBanned: true, banReason: reason);
    }
  }

  @override
  Future<void> unbanChannelMember(String channelId, String userId) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      _members[member.memberId] = member.copyWith(isBanned: false);
    }
  }

  @override
  Future<String> createPost({
    required String channelId,
    required String authorId,
    String? authorName,
    required String content,
    String? mediaUrl,
    List<String> tags = const [],
  }) async {
    final postId = 'post_${_posts.length}';
    _posts[postId] = ChannelPost(
      postId: postId,
      channelId: channelId,
      authorId: authorId,
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
      mediaUrl: mediaUrl,
      tags: tags,
    );

    await updateChannelStats(channelId);
    return postId;
  }

  @override
  Future<ChannelPost?> getPost(String postId) async {
    return _posts[postId];
  }

  @override
  Future<List<ChannelPost>> getChannelPosts(
    String channelId, {
    PostStatus? statusFilter,
    int limit = 50,
  }) async {
    var filtered = _posts.values.where((p) => p.channelId == channelId).toList();

    if (statusFilter != null) {
      filtered = filtered.where((p) => p.status == statusFilter).toList();
    }

    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered.take(limit).toList();
  }

  @override
  Future<List<ChannelPost>> getPinnedPosts(String channelId) async {
    return _posts.values
        .where((p) => p.channelId == channelId && p.isPinned)
        .toList();
  }

  @override
  Future<void> updatePost({
    required String postId,
    required String content,
  }) async {
    final post = _posts[postId];
    if (post != null) {
      _posts[postId] = post.copyWith(updatedAt: DateTime.now());
    }
  }

  @override
  Future<void> publishPost(String postId) async {
    final post = _posts[postId];
    if (post != null) {
      _posts[postId] = post.copyWith(status: PostStatus.published);
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    final post = _posts[postId];
    if (post != null) {
      _posts[postId] = post.copyWith(status: PostStatus.archived);
    }
  }

  @override
  Future<void> pinPost({
    required String postId,
    required int position,
  }) async {
    final post = _posts[postId];
    if (post != null) {
      _posts[postId] =
          post.copyWith(isPinned: true, pinPosition: position);
    }
  }

  @override
  Future<void> unpinPost(String postId) async {
    final post = _posts[postId];
    if (post != null) {
      _posts[postId] = post.copyWith(isPinned: false);
    }
  }

  @override
  Future<void> incrementPostViews(String postId) async {
    final post = _posts[postId];
    if (post != null) {
      _posts[postId] = post.copyWith(views: post.views + 1);
    }
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    final post = _posts[postId];
    if (post != null) {
      final updatedLikedBy = [...post.likedBy];
      if (!updatedLikedBy.contains(userId)) {
        updatedLikedBy.add(userId);
      }
      _posts[postId] = post.copyWith(
        likes: post.likes + 1,
        likedBy: updatedLikedBy,
      );
    }
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    final post = _posts[postId];
    if (post != null) {
      final updatedLikedBy = post.likedBy.where((id) => id != userId).toList();
      _posts[postId] = post.copyWith(
        likes: post.likes - 1,
        likedBy: updatedLikedBy,
      );
    }
  }

  @override
  Future<String> createReply({
    required String postId,
    required String channelId,
    required String authorId,
    String? authorName,
    required String content,
    String? mediaUrl,
  }) async {
    final replyId = 'reply_${_replies.length}';
    _replies[replyId] = PostReply(
      replyId: replyId,
      postId: postId,
      channelId: channelId,
      authorId: authorId,
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
      mediaUrl: mediaUrl,
    );

    final post = _posts[postId];
    if (post != null) {
      _posts[postId] = post.copyWith(replies: post.replies + 1);
    }

    return replyId;
  }

  @override
  Future<PostReply?> getReply(String replyId) async {
    return _replies[replyId];
  }

  @override
  Future<List<PostReply>> getPostReplies(
    String postId, {
    int limit = 50,
  }) async {
    return _replies.values
        .where((r) => r.postId == postId)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  @override
  Future<void> updateReply({
    required String replyId,
    required String content,
  }) async {
    final reply = _replies[replyId];
    if (reply != null) {
      _replies[replyId] = reply.copyWith(updatedAt: DateTime.now());
    }
  }

  @override
  Future<void> deleteReply(String replyId) async {
    final reply = _replies[replyId];
    if (reply != null) {
      _replies.remove(replyId);

      final post = _posts[reply.postId];
      if (post != null) {
        _posts[reply.postId] = post.copyWith(replies: post.replies - 1);
      }
    }
  }

  @override
  Future<void> likeReply(String replyId, String userId) async {
    final reply = _replies[replyId];
    if (reply != null) {
      final updatedLikedBy = [...reply.likedBy];
      if (!updatedLikedBy.contains(userId)) {
        updatedLikedBy.add(userId);
      }
      _replies[replyId] = reply.copyWith(
        likes: reply.likes + 1,
        likedBy: updatedLikedBy,
      );
    }
  }

  @override
  Future<void> unlikeReply(String replyId, String userId) async {
    final reply = _replies[replyId];
    if (reply != null) {
      final updatedLikedBy = reply.likedBy.where((id) => id != userId).toList();
      _replies[replyId] = reply.copyWith(
        likes: reply.likes - 1,
        likedBy: updatedLikedBy,
      );
    }
  }

  @override
  Future<String> createModerationRecord({
    required String channelId,
    required String targetUserId,
    required String actionBy,
    required ModerationAction action,
    String? reason,
    DateTime? expiresAt,
  }) async {
    final recordId = 'record_${_records.length}';
    _records[recordId] = ModerationRecord(
      recordId: recordId,
      channelId: channelId,
      targetUserId: targetUserId,
      actionBy: actionBy,
      action: action,
      reason: reason,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
    );
    return recordId;
  }

  @override
  Future<ModerationRecord?> getModerationRecord(String recordId) async {
    return _records[recordId];
  }

  @override
  Future<List<ModerationRecord>> getChannelModerationRecords(
    String channelId, {
    int limit = 50,
  }) async {
    return _records.values
        .where((r) => r.channelId == channelId)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  @override
  Future<List<ModerationRecord>> getUserModerationRecords(
    String userId, {
    int limit = 50,
  }) async {
    return _records.values
        .where((r) => r.targetUserId == userId)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  @override
  Future<void> closeModerationRecord(String recordId) async {
    final record = _records[recordId];
    if (record != null) {
      _records[recordId] = record.copyWith(isActive: false);
    }
  }

  @override
  Future<void> updateChannelStats(String channelId) async {
    final postCount = await getChannelPostsCount(channelId);
    final memberCount = await getChannelMembersCount(channelId);

    final statsKey = _stats.keys.firstWhere(
      (k) => _stats[k]!.channelId == channelId,
      orElse: () => 'stats_$channelId',
    );

    _stats[statsKey] = ChannelStats(
      statsId: statsKey,
      channelId: channelId,
      totalMembers: memberCount,
      totalPosts: postCount,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<ChannelStats?> getChannelStats(String channelId) async {
    final statsKey = _stats.keys.firstWhere(
      (k) => _stats[k]!.channelId == channelId,
      orElse: () => '',
    );
    return statsKey.isEmpty ? null : _stats[statsKey];
  }

  @override
  Future<int> getTotalChannelsCount() async {
    return _channels.values.where((ch) => !ch.isArchived).length;
  }

  @override
  Future<int> getChannelMembersCount(String channelId) async {
    return _members.values
        .where((m) => m.channelId == channelId && !m.isBanned)
        .length;
  }

  @override
  Future<int> getChannelPostsCount(String channelId) async {
    return _posts.values
        .where((p) => p.channelId == channelId && p.isPublished)
        .length;
  }

  @override
  Future<List<ChannelPost>> searchPosts({
    required String channelId,
    required String query,
    int limit = 50,
  }) async {
    return _posts.values
        .where((p) =>
            p.channelId == channelId &&
            p.isPublished &&
            p.content.toLowerCase().contains(query.toLowerCase()))
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<PostReply>> searchReplies({
    required String query,
    int limit = 50,
  }) async {
    return _replies.values
        .where((r) => r.content.toLowerCase().contains(query.toLowerCase()))
        .toList()
        .take(limit)
        .toList();
  }

  // ============ MENTION OPERATIONS (Phase 11 Step 2) ============

  @override
  Future<List<Mention>> extractMentions(
    String content, {
    required String channelId,
  }) async {
    final regex = RegExp(r'@(\w+)');
    final matches = regex.allMatches(content);
    final mentions = <Mention>[];
    final seenUsernames = <String>{};

    for (final match in matches) {
      final username = match.group(1)!.toLowerCase();
      if (seenUsernames.add(username)) {
        // Check if user is a channel member
        final isMember = _members.values.any((m) =>
            m.channelId == channelId &&
            m.userId == username);
        if (isMember) {
          mentions.add(
            Mention(
              mentionId: 'mention_${_mentions.length}',
              mentionedUserId: username,
              mentionedUsername: username,
              channelId: channelId,
              authorId: '', // Will be set during create
              mentionedAt: DateTime.now(),
            ),
          );
        }
      }
    }
    return mentions;
  }

  @override
  Future<String> createMention({
    required String mentionedUserId,
    required String mentionedUsername,
    required String channelId,
    required String authorId,
    String? authorName,
    String? postId,
    String? replyId,
    String? notificationId,
  }) async {
    final mentionId = 'mention_${_mentions.length}';
    _mentions[mentionId] = Mention(
      mentionId: mentionId,
      mentionedUserId: mentionedUserId,
      mentionedUsername: mentionedUsername,
      postId: postId,
      replyId: replyId,
      channelId: channelId,
      authorId: authorId,
      authorName: authorName,
      mentionedAt: DateTime.now(),
      notificationId: notificationId,
    );
    return mentionId;
  }

  @override
  Future<List<Mention>> getPostMentions(String postId) async {
    return _mentions.values
        .where((m) => m.postId == postId && m.replyId == null)
        .toList();
  }

  @override
  Future<List<Mention>> getReplyMentions(String replyId) async {
    return _mentions.values
        .where((m) => m.replyId == replyId)
        .toList();
  }

  @override
  Future<List<Mention>> getUserMentions(
    String userId, {
    int limit = 50,
  }) async {
    return _mentions.values
        .where((m) => m.mentionedUserId == userId)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  @override
  Future<List<Mention>> getChannelMentions(
    String channelId, {
    int limit = 50,
  }) async {
    return _mentions.values
        .where((m) => m.channelId == channelId)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  @override
  Future<int> getMentionCount(String userId) async {
    return _mentions.values
        .where((m) => m.mentionedUserId == userId)
        .length;
  }

  @override
  Future<bool> validateMention(
    String username, {
    required String channelId,
  }) async {
    return _members.values.any((m) =>
        m.channelId == channelId &&
        m.userId == username &&
        !m.isBanned);
  }

  @override
  Future<List<ChannelMember>> getMentionableCommunityUsers(
    String channelId,
  ) async {
    return _members.values
        .where((m) => m.channelId == channelId && !m.isBanned)
        .toList();
  }

  // ============ NOTIFICATION OPERATIONS (Phase 11 Step 2) ============

  @override
  Future<List<UserNotification>> getUserNotifications(
    String userId, {
    bool unreadOnly = false,
    int limit = 50,
    int offset = 0,
  }) async {
    var results = _notifications.values
        .where((n) => n.userId == userId)
        .toList();

    if (unreadOnly) {
      results = results.where((n) => n.isUnread).toList();
    }

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return results
        .skip(offset)
        .take(limit)
        .toList();
  }

  @override
  Future<UserNotification?> getNotification(String notificationId) async {
    return _notifications[notificationId];
  }

  @override
  Future<String> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String description,
    required String relatedId,
    required String relatedType,
    String? channelId,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) async {
    // Check if user has notifications enabled
    final prefs = await getUserNotificationPreferences(userId);
    final prefsToUse = prefs ?? NotificationPreferences.empty(userId);

    // Check if user is muted
    if (prefsToUse.isCurrentlyMuted) {
      return '';
    }

    // Check type-specific preferences
    bool shouldCreate = false;
    switch (type) {
      case NotificationType.mention:
        shouldCreate = prefsToUse.mentionNotifications;
        break;
      case NotificationType.reply:
        shouldCreate = prefsToUse.replyNotifications;
        break;
      case NotificationType.likePost:
      case NotificationType.likeReply:
        shouldCreate = prefsToUse.likeNotifications;
        break;
      case NotificationType.moderation:
        shouldCreate = prefsToUse.moderationNotifications;
        break;
      case NotificationType.channelEvent:
      case NotificationType.channelAnnounce:
        shouldCreate = prefsToUse.channelAnnouncements;
        break;
    }

    if (!shouldCreate) {
      return '';
    }

    // Prevent duplicates
    final exists = _notifications.values.any((n) =>
        n.userId == userId &&
        n.type == type &&
        n.relatedId == relatedId &&
        n.isUnread);

    if (exists) {
      return '';
    }

    final notificationId = 'notif_${_notifications.length}';
    _notifications[notificationId] = UserNotification(
      notificationId: notificationId,
      userId: userId,
      type: type,
      title: title,
      description: description,
      relatedId: relatedId,
      relatedType: relatedType,
      channelId: channelId,
      isRead: false,
      createdAt: DateTime.now(),
      actionUrl: actionUrl,
      metadata: metadata,
    );

    return notificationId;
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    final notification = _notifications[notificationId];
    if (notification != null) {
      _notifications[notificationId] = notification.copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
    for (final entry in _notifications.entries) {
      if (entry.value.userId == userId) {
        _notifications[entry.key] = entry.value.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }
    }
  }

  @override
  Future<void> markPostNotificationsAsRead({
    required String userId,
    required String postId,
  }) async {
    for (final entry in _notifications.entries) {
      if (entry.value.userId == userId &&
          entry.value.relatedId == postId) {
        _notifications[entry.key] = entry.value.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    _notifications.remove(notificationId);
  }

  @override
  Future<void> deleteUserNotifications(String userId) async {
    _notifications.removeWhere((_, n) => n.userId == userId);
  }

  @override
  Future<void> archiveOldNotifications({
    int olderThanDays = 30,
  }) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
    final toRemove = _notifications.entries
        .where((e) =>
            e.value.isRead &&
            e.value.createdAt.isBefore(cutoffDate))
        .map((e) => e.key)
        .toList();

    for (final id in toRemove) {
      _notifications.remove(id);
    }
  }

  @override
  Future<void> clearReadNotifications(String userId) async {
    _notifications.removeWhere((_, n) =>
        n.userId == userId && n.isRead);
  }

  @override
  Future<Map<String, int>> getNotificationSummary(String userId) async {
    final userNotifs = _notifications.values
        .where((n) => n.userId == userId)
        .toList();

    return {
      'mentions': userNotifs
          .where((n) => n.type == NotificationType.mention)
          .length,
      'replies': userNotifs
          .where((n) => n.type == NotificationType.reply)
          .length,
      'likes': userNotifs
          .where((n) =>
              n.type == NotificationType.likePost ||
              n.type == NotificationType.likeReply)
          .length,
      'moderation': userNotifs
          .where((n) => n.type == NotificationType.moderation)
          .length,
      'total': userNotifs.length,
      'unread': userNotifs.where((n) => n.isUnread).length,
    };
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return _notifications.values
        .where((n) => n.userId == userId && n.isUnread)
        .length;
  }

  // ============ NOTIFICATION PREFERENCE OPERATIONS (Phase 11 Step 2) ============

  @override
  Future<NotificationPreferences?> getUserNotificationPreferences(
    String userId,
  ) async {
    return _preferences[userId];
  }

  @override
  Future<void> updateNotificationPreferences(
    String userId,
    NotificationPreferences preferences,
  ) async {
    _preferences[userId] = preferences;
  }

  @override
  Future<List<String>> getUsersWithNotificationsEnabled(
    String channelId,
  ) async {
    final channelMembers = _members.values
        .where((m) => m.channelId == channelId && !m.isBanned)
        .map((m) => m.userId)
        .toSet();

    final enabledUsers = <String>[];
    for (final userId in channelMembers) {
      final prefs = await getUserNotificationPreferences(userId);
      if (prefs == null || prefs.hasAnyNotificationsEnabled) {
        enabledUsers.add(userId);
      }
    }

    return enabledUsers;
  }

  @override
  Future<void> muteUserNotifications(
    String userId, {
    required Duration duration,
  }) async {
    final prefs = await getUserNotificationPreferences(userId) ??
        NotificationPreferences.empty(userId);

    final muteUntil = DateTime.now().add(duration);
    _preferences[userId] = prefs.copyWith(
      muteUntil: muteUntil,
    );
  }

  @override
  Future<void> unmuteUserNotifications(String userId) async {
    final prefs = await getUserNotificationPreferences(userId);
    if (prefs != null) {
      _preferences[userId] = prefs.copyWith(
        muteUntil: null,
      );
    }
  }

  // ============ REACTION OPERATIONS (Phase 11 Step 3) ============

  @override
  Future<String> addPostReaction({
    required String postId,
    required String userId,
    required String emoji,
    ReactionType reactionType = ReactionType.emoji,
  }) async {
    final reactionId = 'reaction_${_postReactions.length}';
    _postReactions[reactionId] = PostReaction(
      reactionId: reactionId,
      postId: postId,
      userId: userId,
      channelId: '', // Would be populated from post
      emoji: emoji,
      reactionType: reactionType,
      createdAt: DateTime.now(),
    );
    return reactionId;
  }

  @override
  Future<String> addReplyReaction({
    required String replyId,
    required String postId,
    required String userId,
    required String emoji,
    ReactionType reactionType = ReactionType.emoji,
  }) async {
    final reactionId = 'reaction_${_replyReactions.length}';
    _replyReactions[reactionId] = ReplyReaction(
      reactionId: reactionId,
      replyId: replyId,
      postId: postId,
      userId: userId,
      emoji: emoji,
      reactionType: reactionType,
      createdAt: DateTime.now(),
    );
    return reactionId;
  }

  @override
  Future<void> removePostReaction(String postId, String userId, String emoji) async {
    _postReactions.removeWhere((_, r) =>
        r.postId == postId && r.userId == userId && r.emoji == emoji);
  }

  @override
  Future<void> removeReplyReaction(String replyId, String userId, String emoji) async {
    _replyReactions.removeWhere((_, r) =>
        r.replyId == replyId && r.userId == userId && r.emoji == emoji);
  }

  @override
  Future<List<PostReaction>> getPostReactions(String postId) async {
    return _postReactions.values.where((r) => r.postId == postId).toList();
  }

  @override
  Future<List<ReplyReaction>> getReplyReactions(String replyId) async {
    return _replyReactions.values.where((r) => r.replyId == replyId).toList();
  }

  @override
  Future<List<String>> getReactionUsers(String postId, String emoji) async {
    return _postReactions.values
        .where((r) => r.postId == postId && r.emoji == emoji)
        .map((r) => r.userId)
        .toList();
  }

  @override
  Future<int> getReactionCount(String postId) async {
    return _postReactions.values.where((r) => r.postId == postId).length;
  }

  @override
  Future<PostReaction?> getUserPostReaction(
    String postId,
    String userId,
    String emoji,
  ) async {
    try {
      return _postReactions.values.firstWhere((r) =>
          r.postId == postId && r.userId == userId && r.emoji == emoji);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ReplyReaction?> getUserReplyReaction(
    String replyId,
    String userId,
    String emoji,
  ) async {
    try {
      return _replyReactions.values.firstWhere((r) =>
          r.replyId == replyId && r.userId == userId && r.emoji == emoji);
    } catch (e) {
      return null;
    }
  }

  // ============ REPORT OPERATIONS (Phase 11 Step 3) ============

  @override
  Future<String> reportPost({
    required String postId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
    String? attachmentUrl,
  }) async {
    final post = await getPost(postId);
    final reportId = 'report_${_reports.length}';
    _reports[reportId] = ContentReport(
      reportId: reportId,
      contentId: postId,
      contentType: 'post',
      reportedByUserId: reportedByUserId,
      channelId: post?.channelId ?? '',
      category: category,
      description: description,
      attachmentUrl: attachmentUrl,
      createdAt: DateTime.now(),
    );
    return reportId;
  }

  @override
  Future<String> reportReply({
    required String replyId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
    String? attachmentUrl,
  }) async {
    final reply = await getReply(replyId);
    final reportId = 'report_${_reports.length}';
    _reports[reportId] = ContentReport(
      reportId: reportId,
      contentId: replyId,
      contentType: 'reply',
      reportedByUserId: reportedByUserId,
      channelId: reply?.channelId ?? '',
      category: category,
      description: description,
      attachmentUrl: attachmentUrl,
      createdAt: DateTime.now(),
    );
    return reportId;
  }

  @override
  Future<String> reportUser({
    required String reportedUserId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
  }) async {
    final reportId = 'report_${_reports.length}';
    _reports[reportId] = ContentReport(
      reportId: reportId,
      contentId: reportedUserId,
      contentType: 'user',
      reportedByUserId: reportedByUserId,
      reportedUserId: reportedUserId,
      channelId: '', // N/A for user reports
      category: category,
      description: description,
      createdAt: DateTime.now(),
    );
    return reportId;
  }

  @override
  Future<ContentReport?> getReport(String reportId) async {
    return _reports[reportId];
  }

  @override
  Future<List<ContentReport>> getChannelReports(
    String channelId, {
    ReportStatus? statusFilter,
    int limit = 50,
  }) async {
    var results = _reports.values
        .where((r) => r.channelId == channelId)
        .toList();

    if (statusFilter != null) {
      results = results.where((r) => r.status == statusFilter).toList();
    }

    return results.take(limit).toList();
  }

  @override
  Future<List<ContentReport>> getUserReports(
    String reportedUserId, {
    int limit = 50,
  }) async {
    return _reports.values
        .where((r) => r.reportedUserId == reportedUserId)
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<ContentReport>> getReportedContentReports(
    String contentId, {
    int limit = 50,
  }) async {
    return _reports.values
        .where((r) => r.contentId == contentId)
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<void> actionReport({
    required String reportId,
    required ReportAction action,
    required String moderatorId,
    String? reason,
    String? actionDetails,
  }) async {
    final report = _reports[reportId];
    if (report != null) {
      _reports[reportId] = report.copyWith(
        status: ReportStatus.upheld,
        reviewedAt: DateTime.now(),
        reviewedBy: moderatorId,
        action: action,
        actionReason: reason,
        actionDetails: actionDetails,
      );
    }
  }

  @override
  Future<void> dismissReport({
    required String reportId,
    required String moderatorId,
    String? reason,
  }) async {
    final report = _reports[reportId];
    if (report != null) {
      _reports[reportId] = report.copyWith(
        status: ReportStatus.dismissed,
        reviewedAt: DateTime.now(),
        reviewedBy: moderatorId,
        actionReason: reason,
      );
    }
  }

  @override
  Future<Map<String, int>> getReportStats(String channelId) async {
    final channelReports = _reports.values
        .where((r) => r.channelId == channelId)
        .toList();

    return {
      'total': channelReports.length,
      'pending': channelReports.where((r) => r.isPending).length,
      'upheld': channelReports.where((r) => r.isUpheld).length,
      'dismissed': channelReports.where((r) => r.isDismissed).length,
    };
  }

  // ============ TRENDING OPERATIONS (Phase 11 Step 3) ============

  @override
  Future<List<ChannelPost>> getTrendingPosts(
    String channelId, {
    String timeRange = 'day',
    int limit = 20,
  }) async {
    final posts = await getChannelPosts(channelId, statusFilter: PostStatus.published);

    // Score posts by engagement
    final scored = <(ChannelPost, double)>[];
    for (final post in posts) {
      final score = await calculateTrendingScore(post.postId);
      scored.add((post, score));
    }

    // Sort by score descending
    scored.sort((a, b) => b.$2.compareTo(a.$2));

    return scored.map((s) => s.$1).take(limit).toList();
  }

  @override
  Future<List<ChannelPost>> getGlobalTrendingPosts({
    String timeRange = 'week',
    int limit = 50,
  }) async {
    final allPosts = _posts.values
        .where((p) => p.isPublished)
        .toList();

    final scored = <(ChannelPost, double)>[];
    for (final post in allPosts) {
      final score = await calculateTrendingScore(post.postId);
      scored.add((post, score));
    }

    scored.sort((a, b) => b.$2.compareTo(a.$2));

    return scored.map((s) => s.$1).take(limit).toList();
  }

  @override
  Future<List<ChannelPost>> getTrendingByCategory(
    String category, {
    String timeRange = 'week',
    int limit = 20,
  }) async {
    final channels = _channels.values
        .where((ch) => ch.category == category)
        .map((ch) => ch.channelId)
        .toSet();

    final posts = _posts.values
        .where((p) => channels.contains(p.channelId) && p.isPublished)
        .toList();

    final scored = <(ChannelPost, double)>[];
    for (final post in posts) {
      final score = await calculateTrendingScore(post.postId);
      scored.add((post, score));
    }

    scored.sort((a, b) => b.$2.compareTo(a.$2));

    return scored.map((s) => s.$1).take(limit).toList();
  }

  @override
  Future<List<String>> getTrendingTags(
    String channelId, {
    int limit = 10,
  }) async {
    final posts = await getChannelPosts(channelId);

    final tagCounts = <String, int>{};
    for (final post in posts) {
      for (final tag in post.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    final sorted = tagCounts.entries.toList();
    sorted.sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((e) => e.key).take(limit).toList();
  }

  @override
  Future<double> calculateTrendingScore(String postId) async {
    final post = await getPost(postId);
    if (post == null) return 0.0;

    // Get engagement metrics
    final reactionCount = await getReactionCount(postId);
    final likeCount = post.likes;
    final replyCount = post.replies;
    final viewCount = post.views;

    // Calculate score: weighted sum of engagement
    // Reactions: 2x, Replies: 3x, Likes: 1x, Views: 0.1x
    final engagementScore = (reactionCount * 2) +
        (replyCount * 3) +
        (likeCount * 1) +
        (viewCount * 0.1);

    // Time decay: newer posts score higher
    final ageHours = DateTime.now().difference(post.createdAt).inHours;
    final timeDecay = 1.0 / (1.0 + (ageHours / 24.0));

    final score = engagementScore * timeDecay;

    // Store analytics
    await updateEngagementAnalytics(postId);

    return score;
  }

  @override
  Future<PostEngagementAnalytics?> getPostEngagementAnalytics(
    String postId,
  ) async {
    try {
      return _analytics.values.firstWhere((a) => a.postId == postId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateEngagementAnalytics(String postId) async {
    final post = await getPost(postId);
    if (post == null) return;

    final analyticsId = 'analytics_$postId';
    final reactionCount = await getReactionCount(postId);
    final trendingScore = await calculateTrendingScore(postId);

    _analytics[analyticsId] = PostEngagementAnalytics(
      analyticsId: analyticsId,
      postId: postId,
      channelId: post.channelId,
      reactionCount: reactionCount,
      replyCount: post.replies,
      likeCount: post.likes,
      viewCount: post.views,
      trendingScore: trendingScore,
      lastUpdatedAt: DateTime.now(),
    );
  }
}
