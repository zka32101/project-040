import 'package:cloud_firestore/cloud_firestore.dart';

/// Community system enums
enum ChannelType { public, private, announcement }

enum MemberRole { owner, moderator, member }

enum PostStatus { published, draft, archived, pinned }

enum ModerationAction { none, warning, mute, ban }

enum NotificationType { mention, reply, likePost, likeReply, moderation, channelEvent, channelAnnounce }

enum ReactionType { emoji, sticker }

enum ReportCategory { inappropriate, harassment, spam, misinformation, copyright, other }

enum ReportStatus { pending, reviewing, upheld, dismissed, appealed }

enum ReportAction { warning, mute, removeContent, ban, escalate, dismiss }

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

/// User mention model (Phase 11 Step 2)
class Mention {
  final String mentionId;
  final String mentionedUserId;
  final String mentionedUsername;
  final String? postId;
  final String? replyId;
  final String channelId;
  final String authorId;
  final String? authorName;
  final DateTime mentionedAt;
  final String? notificationId; // Link to notification

  Mention({
    required this.mentionId,
    required this.mentionedUserId,
    required this.mentionedUsername,
    this.postId,
    this.replyId,
    required this.channelId,
    required this.authorId,
    this.authorName,
    required this.mentionedAt,
    this.notificationId,
  });

  bool get isPostMention => postId != null && replyId == null;
  bool get isReplyMention => replyId != null;

  factory Mention.empty() {
    return Mention(
      mentionId: '',
      mentionedUserId: '',
      mentionedUsername: '',
      channelId: '',
      authorId: '',
      mentionedAt: DateTime.now(),
    );
  }

  factory Mention.fromMap(Map<String, dynamic> map) {
    return Mention(
      mentionId: map['mentionId'] as String? ?? '',
      mentionedUserId: map['mentionedUserId'] as String? ?? '',
      mentionedUsername: map['mentionedUsername'] as String? ?? '',
      postId: map['postId'] as String?,
      replyId: map['replyId'] as String?,
      channelId: map['channelId'] as String? ?? '',
      authorId: map['authorId'] as String? ?? '',
      authorName: map['authorName'] as String?,
      mentionedAt: (map['mentionedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notificationId: map['notificationId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mentionId': mentionId,
      'mentionedUserId': mentionedUserId,
      'mentionedUsername': mentionedUsername,
      'postId': postId,
      'replyId': replyId,
      'channelId': channelId,
      'authorId': authorId,
      'authorName': authorName,
      'mentionedAt': Timestamp.fromDate(mentionedAt),
      'notificationId': notificationId,
    };
  }

  Mention copyWith({
    String? notificationId,
  }) {
    return Mention(
      mentionId: mentionId,
      mentionedUserId: mentionedUserId,
      mentionedUsername: mentionedUsername,
      postId: postId,
      replyId: replyId,
      channelId: channelId,
      authorId: authorId,
      authorName: authorName,
      mentionedAt: mentionedAt,
      notificationId: notificationId ?? this.notificationId,
    );
  }
}

/// User notification model (Phase 11 Step 2)
class UserNotification {
  final String notificationId;
  final String userId;
  final NotificationType type;
  final String title;
  final String description;
  final String relatedId; // postId, replyId, userId, etc.
  final String relatedType; // 'post', 'reply', 'user', 'channel', 'mention'
  final String? channelId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;

  UserNotification({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.relatedId,
    required this.relatedType,
    this.channelId,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
    this.actionUrl,
    this.metadata,
  });

  bool get isUnread => !isRead;
  bool get isOld => DateTime.now().difference(createdAt).inDays > 30;

  factory UserNotification.empty() {
    return UserNotification(
      notificationId: '',
      userId: '',
      type: NotificationType.mention,
      title: '',
      description: '',
      relatedId: '',
      relatedType: '',
      createdAt: DateTime.now(),
    );
  }

  factory UserNotification.fromMap(Map<String, dynamic> map) {
    return UserNotification(
      notificationId: map['notificationId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      type: NotificationType.values[(map['type'] as int?) ?? NotificationType.mention.index],
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      relatedId: map['relatedId'] as String? ?? '',
      relatedType: map['relatedType'] as String? ?? '',
      channelId: map['channelId'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (map['readAt'] as Timestamp?)?.toDate(),
      actionUrl: map['actionUrl'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'type': type.index,
      'title': title,
      'description': description,
      'relatedId': relatedId,
      'relatedType': relatedType,
      'channelId': channelId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'actionUrl': actionUrl,
      'metadata': metadata,
    };
  }

  UserNotification copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return UserNotification(
      notificationId: notificationId,
      userId: userId,
      type: type,
      title: title,
      description: description,
      relatedId: relatedId,
      relatedType: relatedType,
      channelId: channelId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
      actionUrl: actionUrl,
      metadata: metadata,
    );
  }
}

/// User notification preferences model (Phase 11 Step 2)
class NotificationPreferences {
  final String userId;
  final bool mentionNotifications;
  final bool replyNotifications;
  final bool likeNotifications;
  final bool moderationNotifications;
  final bool channelAnnouncements;
  final DateTime updatedAt;
  final DateTime? muteUntil;

  NotificationPreferences({
    required this.userId,
    this.mentionNotifications = true,
    this.replyNotifications = true,
    this.likeNotifications = true,
    this.moderationNotifications = true,
    this.channelAnnouncements = true,
    required this.updatedAt,
    this.muteUntil,
  });

  bool get isCurrentlyMuted => muteUntil != null && DateTime.now().isBefore(muteUntil!);
  bool get hasAnyNotificationsEnabled =>
      mentionNotifications || replyNotifications || likeNotifications ||
      moderationNotifications || channelAnnouncements;

  factory NotificationPreferences.empty(String userId) {
    return NotificationPreferences(
      userId: userId,
      updatedAt: DateTime.now(),
    );
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      userId: map['userId'] as String? ?? '',
      mentionNotifications: map['mentionNotifications'] as bool? ?? true,
      replyNotifications: map['replyNotifications'] as bool? ?? true,
      likeNotifications: map['likeNotifications'] as bool? ?? true,
      moderationNotifications: map['moderationNotifications'] as bool? ?? true,
      channelAnnouncements: map['channelAnnouncements'] as bool? ?? true,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      muteUntil: (map['muteUntil'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'mentionNotifications': mentionNotifications,
      'replyNotifications': replyNotifications,
      'likeNotifications': likeNotifications,
      'moderationNotifications': moderationNotifications,
      'channelAnnouncements': channelAnnouncements,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'muteUntil': muteUntil != null ? Timestamp.fromDate(muteUntil!) : null,
    };
  }

  NotificationPreferences copyWith({
    bool? mentionNotifications,
    bool? replyNotifications,
    bool? likeNotifications,
    bool? moderationNotifications,
    bool? channelAnnouncements,
    DateTime? muteUntil,
  }) {
    return NotificationPreferences(
      userId: userId,
      mentionNotifications: mentionNotifications ?? this.mentionNotifications,
      replyNotifications: replyNotifications ?? this.replyNotifications,
      likeNotifications: likeNotifications ?? this.likeNotifications,
      moderationNotifications: moderationNotifications ?? this.moderationNotifications,
      channelAnnouncements: channelAnnouncements ?? this.channelAnnouncements,
      updatedAt: DateTime.now(),
      muteUntil: muteUntil ?? this.muteUntil,
    );
  }
}

/// Post reaction model (Phase 11 Step 3)
class PostReaction {
  final String reactionId;
  final String postId;
  final String userId;
  final String channelId;
  final String emoji;
  final ReactionType reactionType;
  final DateTime createdAt;

  PostReaction({
    required this.reactionId,
    required this.postId,
    required this.userId,
    required this.channelId,
    required this.emoji,
    this.reactionType = ReactionType.emoji,
    required this.createdAt,
  });

  bool get isEmoji => reactionType == ReactionType.emoji;
  bool get isSticker => reactionType == ReactionType.sticker;

  factory PostReaction.empty() {
    return PostReaction(
      reactionId: '',
      postId: '',
      userId: '',
      channelId: '',
      emoji: '',
      createdAt: DateTime.now(),
    );
  }

  factory PostReaction.fromMap(Map<String, dynamic> map) {
    return PostReaction(
      reactionId: map['reactionId'] as String? ?? '',
      postId: map['postId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      channelId: map['channelId'] as String? ?? '',
      emoji: map['emoji'] as String? ?? '',
      reactionType: ReactionType.values[(map['reactionType'] as int?) ?? ReactionType.emoji.index],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reactionId': reactionId,
      'postId': postId,
      'userId': userId,
      'channelId': channelId,
      'emoji': emoji,
      'reactionType': reactionType.index,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PostReaction copyWith() {
    return PostReaction(
      reactionId: reactionId,
      postId: postId,
      userId: userId,
      channelId: channelId,
      emoji: emoji,
      reactionType: reactionType,
      createdAt: createdAt,
    );
  }
}

/// Reply reaction model (Phase 11 Step 3)
class ReplyReaction {
  final String reactionId;
  final String replyId;
  final String postId;
  final String userId;
  final String emoji;
  final ReactionType reactionType;
  final DateTime createdAt;

  ReplyReaction({
    required this.reactionId,
    required this.replyId,
    required this.postId,
    required this.userId,
    required this.emoji,
    this.reactionType = ReactionType.emoji,
    required this.createdAt,
  });

  bool get isEmoji => reactionType == ReactionType.emoji;
  bool get isSticker => reactionType == ReactionType.sticker;

  factory ReplyReaction.empty() {
    return ReplyReaction(
      reactionId: '',
      replyId: '',
      postId: '',
      userId: '',
      emoji: '',
      createdAt: DateTime.now(),
    );
  }

  factory ReplyReaction.fromMap(Map<String, dynamic> map) {
    return ReplyReaction(
      reactionId: map['reactionId'] as String? ?? '',
      replyId: map['replyId'] as String? ?? '',
      postId: map['postId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      emoji: map['emoji'] as String? ?? '',
      reactionType: ReactionType.values[(map['reactionType'] as int?) ?? ReactionType.emoji.index],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reactionId': reactionId,
      'replyId': replyId,
      'postId': postId,
      'userId': userId,
      'emoji': emoji,
      'reactionType': reactionType.index,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ReplyReaction copyWith() {
    return ReplyReaction(
      reactionId: reactionId,
      replyId: replyId,
      postId: postId,
      userId: userId,
      emoji: emoji,
      reactionType: reactionType,
      createdAt: createdAt,
    );
  }
}

/// Content report model (Phase 11 Step 3)
class ContentReport {
  final String reportId;
  final String contentId; // postId or replyId or userId
  final String contentType; // 'post', 'reply', 'user'
  final String reportedByUserId;
  final String? reportedUserId; // Only for user reports
  final String channelId;
  final ReportCategory category;
  final String? description;
  final String? attachmentUrl;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final ReportAction? action;
  final String? actionReason;
  final String? actionDetails;

  ContentReport({
    required this.reportId,
    required this.contentId,
    required this.contentType,
    required this.reportedByUserId,
    this.reportedUserId,
    required this.channelId,
    required this.category,
    this.description,
    this.attachmentUrl,
    this.status = ReportStatus.pending,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.action,
    this.actionReason,
    this.actionDetails,
  });

  bool get isPending => status == ReportStatus.pending;
  bool get isResolved => status == ReportStatus.upheld || status == ReportStatus.dismissed;
  bool get isUpheld => status == ReportStatus.upheld;
  bool get isDismissed => status == ReportStatus.dismissed;
  bool get isPostReport => contentType == 'post';
  bool get isReplyReport => contentType == 'reply';
  bool get isUserReport => contentType == 'user';

  factory ContentReport.empty() {
    return ContentReport(
      reportId: '',
      contentId: '',
      contentType: '',
      reportedByUserId: '',
      channelId: '',
      category: ReportCategory.other,
      createdAt: DateTime.now(),
    );
  }

  factory ContentReport.fromMap(Map<String, dynamic> map) {
    return ContentReport(
      reportId: map['reportId'] as String? ?? '',
      contentId: map['contentId'] as String? ?? '',
      contentType: map['contentType'] as String? ?? '',
      reportedByUserId: map['reportedByUserId'] as String? ?? '',
      reportedUserId: map['reportedUserId'] as String?,
      channelId: map['channelId'] as String? ?? '',
      category: ReportCategory.values[(map['category'] as int?) ?? ReportCategory.other.index],
      description: map['description'] as String?,
      attachmentUrl: map['attachmentUrl'] as String?,
      status: ReportStatus.values[(map['status'] as int?) ?? ReportStatus.pending.index],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewedAt: (map['reviewedAt'] as Timestamp?)?.toDate(),
      reviewedBy: map['reviewedBy'] as String?,
      action: map['action'] != null
          ? ReportAction.values[map['action'] as int]
          : null,
      actionReason: map['actionReason'] as String?,
      actionDetails: map['actionDetails'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'contentId': contentId,
      'contentType': contentType,
      'reportedByUserId': reportedByUserId,
      'reportedUserId': reportedUserId,
      'channelId': channelId,
      'category': category.index,
      'description': description,
      'attachmentUrl': attachmentUrl,
      'status': status.index,
      'createdAt': Timestamp.fromDate(createdAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewedBy': reviewedBy,
      'action': action?.index,
      'actionReason': actionReason,
      'actionDetails': actionDetails,
    };
  }

  ContentReport copyWith({
    ReportStatus? status,
    DateTime? reviewedAt,
    String? reviewedBy,
    ReportAction? action,
    String? actionReason,
    String? actionDetails,
  }) {
    return ContentReport(
      reportId: reportId,
      contentId: contentId,
      contentType: contentType,
      reportedByUserId: reportedByUserId,
      reportedUserId: reportedUserId,
      channelId: channelId,
      category: category,
      description: description,
      attachmentUrl: attachmentUrl,
      status: status ?? this.status,
      createdAt: createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      action: action ?? this.action,
      actionReason: actionReason ?? this.actionReason,
      actionDetails: actionDetails ?? this.actionDetails,
    );
  }
}

/// Post engagement analytics model (Phase 11 Step 3)
class PostEngagementAnalytics {
  final String analyticsId;
  final String postId;
  final String channelId;
  final int reactionCount;
  final int replyCount;
  final int likeCount;
  final int viewCount;
  final double trendingScore;
  final DateTime lastUpdatedAt;
  final String timeRange; // 'hour', 'day', 'week'

  PostEngagementAnalytics({
    required this.analyticsId,
    required this.postId,
    required this.channelId,
    this.reactionCount = 0,
    this.replyCount = 0,
    this.likeCount = 0,
    this.viewCount = 0,
    this.trendingScore = 0.0,
    required this.lastUpdatedAt,
    this.timeRange = 'day',
  });

  int get totalEngagement => reactionCount + replyCount + likeCount + viewCount;
  double get engagementRate => totalEngagement > 0 ? (totalEngagement / (viewCount + 1)).toDouble() : 0.0;

  factory PostEngagementAnalytics.empty(String postId, String channelId) {
    return PostEngagementAnalytics(
      analyticsId: '',
      postId: postId,
      channelId: channelId,
      lastUpdatedAt: DateTime.now(),
    );
  }

  factory PostEngagementAnalytics.fromMap(Map<String, dynamic> map) {
    return PostEngagementAnalytics(
      analyticsId: map['analyticsId'] as String? ?? '',
      postId: map['postId'] as String? ?? '',
      channelId: map['channelId'] as String? ?? '',
      reactionCount: map['reactionCount'] as int? ?? 0,
      replyCount: map['replyCount'] as int? ?? 0,
      likeCount: map['likeCount'] as int? ?? 0,
      viewCount: map['viewCount'] as int? ?? 0,
      trendingScore: (map['trendingScore'] as num?)?.toDouble() ?? 0.0,
      lastUpdatedAt: (map['lastUpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeRange: map['timeRange'] as String? ?? 'day',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'analyticsId': analyticsId,
      'postId': postId,
      'channelId': channelId,
      'reactionCount': reactionCount,
      'replyCount': replyCount,
      'likeCount': likeCount,
      'viewCount': viewCount,
      'trendingScore': trendingScore,
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
      'timeRange': timeRange,
    };
  }

  PostEngagementAnalytics copyWith({
    int? reactionCount,
    int? replyCount,
    int? likeCount,
    int? viewCount,
    double? trendingScore,
  }) {
    return PostEngagementAnalytics(
      analyticsId: analyticsId,
      postId: postId,
      channelId: channelId,
      reactionCount: reactionCount ?? this.reactionCount,
      replyCount: replyCount ?? this.replyCount,
      likeCount: likeCount ?? this.likeCount,
      viewCount: viewCount ?? this.viewCount,
      trendingScore: trendingScore ?? this.trendingScore,
      lastUpdatedAt: DateTime.now(),
      timeRange: timeRange,
    );
  }
}
