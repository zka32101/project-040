import 'package:cloud_firestore/cloud_firestore.dart';

/// Community system enums
enum ChannelType { public, private, announcement }

enum MemberRole { owner, moderator, member }

enum PostStatus { published, draft, archived, pinned }

enum ModerationAction { none, warning, mute, ban }

/// Community channel model
class CommunityChannel {
  final String channelId;
  final String name;
  final String? description;
  final ChannelType type; // public, private, announcement
  final String ownerId;
  final List<String> moderatorIds;
  final List<String> memberIds;
  final String? bannerUrl;
  final String? iconUrl;
  final int memberCount;
  final int totalPosts;
  final DateTime createdAt;
  final DateTime? lastActivityAt;
  final bool isArchived;
  final String? category; // Bikes, Maintenance, Routes, Events, etc.
  final List<String> tags;

  CommunityChannel({
    required this.channelId,
    required this.name,
    this.description,
    required this.type,
    required this.ownerId,
    this.moderatorIds = const [],
    this.memberIds = const [],
    this.bannerUrl,
    this.iconUrl,
    this.memberCount = 0,
    this.totalPosts = 0,
    required this.createdAt,
    this.lastActivityAt,
    this.isArchived = false,
    this.category,
    this.tags = const [],
  });

  bool get isPublic => type == ChannelType.public;
  bool get isPrivate => type == ChannelType.private;
  bool get isAnnouncement => type == ChannelType.announcement;

  factory CommunityChannel.empty() {
    return CommunityChannel(
      channelId: '',
      name: '',
      type: ChannelType.public,
      ownerId: '',
      createdAt: DateTime.now(),
    );
  }

  factory CommunityChannel.fromMap(Map<String, dynamic> map) {
    return CommunityChannel(
      channelId: map['channelId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      type: ChannelType.values[(map['type'] as int?) ?? ChannelType.public.index],
      ownerId: map['ownerId'] as String? ?? '',
      moderatorIds: List<String>.from(map['moderatorIds'] as List? ?? []),
      memberIds: List<String>.from(map['memberIds'] as List? ?? []),
      bannerUrl: map['bannerUrl'] as String?,
      iconUrl: map['iconUrl'] as String?,
      memberCount: map['memberCount'] as int? ?? 0,
      totalPosts: map['totalPosts'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActivityAt: (map['lastActivityAt'] as Timestamp?)?.toDate(),
      isArchived: map['isArchived'] as bool? ?? false,
      category: map['category'] as String?,
      tags: List<String>.from(map['tags'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'channelId': channelId,
      'name': name,
      'description': description,
      'type': type.index,
      'ownerId': ownerId,
      'moderatorIds': moderatorIds,
      'memberIds': memberIds,
      'bannerUrl': bannerUrl,
      'iconUrl': iconUrl,
      'memberCount': memberCount,
      'totalPosts': totalPosts,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActivityAt':
          lastActivityAt != null ? Timestamp.fromDate(lastActivityAt!) : null,
      'isArchived': isArchived,
      'category': category,
      'tags': tags,
    };
  }

  CommunityChannel copyWith({
    String? name,
    String? description,
    ChannelType? type,
    List<String>? moderatorIds,
    List<String>? memberIds,
    String? bannerUrl,
    String? iconUrl,
    int? memberCount,
    int? totalPosts,
    DateTime? lastActivityAt,
    bool? isArchived,
    String? category,
    List<String>? tags,
  }) {
    return CommunityChannel(
      channelId: channelId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      ownerId: ownerId,
      moderatorIds: moderatorIds ?? this.moderatorIds,
      memberIds: memberIds ?? this.memberIds,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      memberCount: memberCount ?? this.memberCount,
      totalPosts: totalPosts ?? this.totalPosts,
      createdAt: createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      isArchived: isArchived ?? this.isArchived,
      category: category ?? this.category,
      tags: tags ?? this.tags,
    );
  }
}

/// Channel post/message model
class ChannelPost {
  final String postId;
  final String channelId;
  final String authorId;
  final String? authorName;
  final String content;
  final PostStatus status; // published, draft, archived, pinned
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likes;
  final int replies;
  final int views;
  final List<String> likedBy;
  final String? mediaUrl;
  final List<String> tags;
  final bool isPinned;
  final int? pinPosition; // For ordering pinned posts

  ChannelPost({
    required this.postId,
    required this.channelId,
    required this.authorId,
    this.authorName,
    required this.content,
    this.status = PostStatus.published,
    required this.createdAt,
    this.updatedAt,
    this.likes = 0,
    this.replies = 0,
    this.views = 0,
    this.likedBy = const [],
    this.mediaUrl,
    this.tags = const [],
    this.isPinned = false,
    this.pinPosition,
  });

  bool get isPublished => status == PostStatus.published;
  bool get isDraft => status == PostStatus.draft;

  factory ChannelPost.empty() {
    return ChannelPost(
      postId: '',
      channelId: '',
      authorId: '',
      content: '',
      createdAt: DateTime.now(),
    );
  }

  factory ChannelPost.fromMap(Map<String, dynamic> map) {
    return ChannelPost(
      postId: map['postId'] as String? ?? '',
      channelId: map['channelId'] as String? ?? '',
      authorId: map['authorId'] as String? ?? '',
      authorName: map['authorName'] as String?,
      content: map['content'] as String? ?? '',
      status: PostStatus.values[(map['status'] as int?) ?? PostStatus.published.index],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      likes: map['likes'] as int? ?? 0,
      replies: map['replies'] as int? ?? 0,
      views: map['views'] as int? ?? 0,
      likedBy: List<String>.from(map['likedBy'] as List? ?? []),
      mediaUrl: map['mediaUrl'] as String?,
      tags: List<String>.from(map['tags'] as List? ?? []),
      isPinned: map['isPinned'] as bool? ?? false,
      pinPosition: map['pinPosition'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'channelId': channelId,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'status': status.index,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'likes': likes,
      'replies': replies,
      'views': views,
      'likedBy': likedBy,
      'mediaUrl': mediaUrl,
      'tags': tags,
      'isPinned': isPinned,
      'pinPosition': pinPosition,
    };
  }

  ChannelPost copyWith({
    PostStatus? status,
    DateTime? updatedAt,
    int? likes,
    int? replies,
    int? views,
    List<String>? likedBy,
    bool? isPinned,
    int? pinPosition,
  }) {
    return ChannelPost(
      postId: postId,
      channelId: channelId,
      authorId: authorId,
      authorName: authorName,
      content: content,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      replies: replies ?? this.replies,
      views: views ?? this.views,
      likedBy: likedBy ?? this.likedBy,
      mediaUrl: mediaUrl,
      tags: tags,
      isPinned: isPinned ?? this.isPinned,
      pinPosition: pinPosition ?? this.pinPosition,
    );
  }
}

/// Channel member model
class ChannelMember {
  final String memberId;
  final String channelId;
  final String userId;
  final MemberRole role; // owner, moderator, member
  final DateTime joinedAt;
  final DateTime? lastActiveAt;
  final int postsCount;
  final bool isMuted;
  final bool isBanned;
  final String? banReason;

  ChannelMember({
    required this.memberId,
    required this.channelId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.lastActiveAt,
    this.postsCount = 0,
    this.isMuted = false,
    this.isBanned = false,
    this.banReason,
  });

  bool get isOwner => role == MemberRole.owner;
  bool get isModerator => role == MemberRole.moderator;

  factory ChannelMember.empty() {
    return ChannelMember(
      memberId: '',
      channelId: '',
      userId: '',
      role: MemberRole.member,
      joinedAt: DateTime.now(),
    );
  }

  factory ChannelMember.fromMap(Map<String, dynamic> map) {
    return ChannelMember(
      memberId: map['memberId'] as String? ?? '',
      channelId: map['channelId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      role: MemberRole.values[(map['role'] as int?) ?? MemberRole.member.index],
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveAt: (map['lastActiveAt'] as Timestamp?)?.toDate(),
      postsCount: map['postsCount'] as int? ?? 0,
      isMuted: map['isMuted'] as bool? ?? false,
      isBanned: map['isBanned'] as bool? ?? false,
      banReason: map['banReason'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'channelId': channelId,
      'userId': userId,
      'role': role.index,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'lastActiveAt':
          lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
      'postsCount': postsCount,
      'isMuted': isMuted,
      'isBanned': isBanned,
      'banReason': banReason,
    };
  }

  ChannelMember copyWith({
    MemberRole? role,
    DateTime? lastActiveAt,
    int? postsCount,
    bool? isMuted,
    bool? isBanned,
    String? banReason,
  }) {
    return ChannelMember(
      memberId: memberId,
      channelId: channelId,
      userId: userId,
      role: role ?? this.role,
      joinedAt: joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      postsCount: postsCount ?? this.postsCount,
      isMuted: isMuted ?? this.isMuted,
      isBanned: isBanned ?? this.isBanned,
      banReason: banReason ?? this.banReason,
    );
  }
}

/// Post reply/comment model
class PostReply {
  final String replyId;
  final String postId;
  final String channelId;
  final String authorId;
  final String? authorName;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likes;
  final List<String> likedBy;
  final String? mediaUrl;

  PostReply({
    required this.replyId,
    required this.postId,
    required this.channelId,
    required this.authorId,
    this.authorName,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.likes = 0,
    this.likedBy = const [],
    this.mediaUrl,
  });

  factory PostReply.empty() {
    return PostReply(
      replyId: '',
      postId: '',
      channelId: '',
      authorId: '',
      content: '',
      createdAt: DateTime.now(),
    );
  }

  factory PostReply.fromMap(Map<String, dynamic> map) {
    return PostReply(
      replyId: map['replyId'] as String? ?? '',
      postId: map['postId'] as String? ?? '',
      channelId: map['channelId'] as String? ?? '',
      authorId: map['authorId'] as String? ?? '',
      authorName: map['authorName'] as String?,
      content: map['content'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      likes: map['likes'] as int? ?? 0,
      likedBy: List<String>.from(map['likedBy'] as List? ?? []),
      mediaUrl: map['mediaUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'replyId': replyId,
      'postId': postId,
      'channelId': channelId,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'likes': likes,
      'likedBy': likedBy,
      'mediaUrl': mediaUrl,
    };
  }

  PostReply copyWith({
    DateTime? updatedAt,
    int? likes,
    List<String>? likedBy,
  }) {
    return PostReply(
      replyId: replyId,
      postId: postId,
      channelId: channelId,
      authorId: authorId,
      authorName: authorName,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      mediaUrl: mediaUrl,
    );
  }
}

/// Channel moderation action model
class ModerationRecord {
  final String recordId;
  final String channelId;
  final String targetUserId;
  final String actionBy;
  final ModerationAction action; // none, warning, mute, ban
  final String? reason;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;

  ModerationRecord({
    required this.recordId,
    required this.channelId,
    required this.targetUserId,
    required this.actionBy,
    required this.action,
    this.reason,
    required this.createdAt,
    this.expiresAt,
    this.isActive = true,
  });

  bool get isBan => action == ModerationAction.ban;
  bool get isMute => action == ModerationAction.mute;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  factory ModerationRecord.empty() {
    return ModerationRecord(
      recordId: '',
      channelId: '',
      targetUserId: '',
      actionBy: '',
      action: ModerationAction.none,
      createdAt: DateTime.now(),
    );
  }

  factory ModerationRecord.fromMap(Map<String, dynamic> map) {
    return ModerationRecord(
      recordId: map['recordId'] as String? ?? '',
      channelId: map['channelId'] as String? ?? '',
      targetUserId: map['targetUserId'] as String? ?? '',
      actionBy: map['actionBy'] as String? ?? '',
      action: ModerationAction.values[(map['action'] as int?) ?? ModerationAction.none.index],
      reason: map['reason'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recordId': recordId,
      'channelId': channelId,
      'targetUserId': targetUserId,
      'actionBy': actionBy,
      'action': action.index,
      'reason': reason,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isActive': isActive,
    };
  }

  ModerationRecord copyWith({
    bool? isActive,
  }) {
    return ModerationRecord(
      recordId: recordId,
      channelId: channelId,
      targetUserId: targetUserId,
      actionBy: actionBy,
      action: action,
      reason: reason,
      createdAt: createdAt,
      expiresAt: expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Channel statistics model
class ChannelStats {
  final String statsId;
  final String channelId;
  final int totalMembers;
  final int totalPosts;
  final int totalReplies;
  final int totalLikes;
  final int activeToday;
  final int activeThisWeek;
  final DateTime updatedAt;

  ChannelStats({
    required this.statsId,
    required this.channelId,
    this.totalMembers = 0,
    this.totalPosts = 0,
    this.totalReplies = 0,
    this.totalLikes = 0,
    this.activeToday = 0,
    this.activeThisWeek = 0,
    required this.updatedAt,
  });

  factory ChannelStats.empty(String channelId) {
    return ChannelStats(
      statsId: '',
      channelId: channelId,
      updatedAt: DateTime.now(),
    );
  }

  factory ChannelStats.fromMap(Map<String, dynamic> map) {
    return ChannelStats(
      statsId: map['statsId'] as String? ?? '',
      channelId: map['channelId'] as String? ?? '',
      totalMembers: map['totalMembers'] as int? ?? 0,
      totalPosts: map['totalPosts'] as int? ?? 0,
      totalReplies: map['totalReplies'] as int? ?? 0,
      totalLikes: map['totalLikes'] as int? ?? 0,
      activeToday: map['activeToday'] as int? ?? 0,
      activeThisWeek: map['activeThisWeek'] as int? ?? 0,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'statsId': statsId,
      'channelId': channelId,
      'totalMembers': totalMembers,
      'totalPosts': totalPosts,
      'totalReplies': totalReplies,
      'totalLikes': totalLikes,
      'activeToday': activeToday,
      'activeThisWeek': activeThisWeek,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ChannelStats copyWith({
    int? totalMembers,
    int? totalPosts,
    int? totalReplies,
    int? totalLikes,
    int? activeToday,
    int? activeThisWeek,
  }) {
    return ChannelStats(
      statsId: statsId,
      channelId: channelId,
      totalMembers: totalMembers ?? this.totalMembers,
      totalPosts: totalPosts ?? this.totalPosts,
      totalReplies: totalReplies ?? this.totalReplies,
      totalLikes: totalLikes ?? this.totalLikes,
      activeToday: activeToday ?? this.activeToday,
      activeThisWeek: activeThisWeek ?? this.activeThisWeek,
      updatedAt: DateTime.now(),
    );
  }
}
