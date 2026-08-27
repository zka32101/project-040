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
}

/// Stub implementation for testing
class StubCommunityService implements CommunityService {
  final Map<String, CommunityChannel> _channels = {};
  final Map<String, ChannelMember> _members = {};
  final Map<String, ChannelPost> _posts = {};
  final Map<String, PostReply> _replies = {};
  final Map<String, ModerationRecord> _records = {};
  final Map<String, ChannelStats> _stats = {};

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
}
