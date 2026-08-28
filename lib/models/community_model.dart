import 'package:cloud_firestore/cloud_firestore.dart';

/// Community system enums
enum ChannelType { public, private, announcement }

enum MemberRole { owner, moderator, member, guest }

enum PostStatus { published, draft, archived, pinned }

enum ModerationAction { none, warning, mute, ban }

enum NotificationType { mention, reply, likePost, likeReply, moderation, channelEvent, channelAnnounce }

enum ReactionType { emoji, sticker }

enum ReportCategory { inappropriate, harassment, spam, misinformation, copyright, other }

enum ReportStatus { pending, reviewing, upheld, dismissed, appealed }

enum ReportAction { warning, mute, removeContent, ban, escalate, dismiss }

enum InvitationStatus { pending, accepted, declined, cancelled, expired }

enum AccessRequestStatus { pending, approved, rejected, cancelled }

enum MemberStatus { active, inactive, suspended, left }

enum AccessAction { invited, joined, promoted, demoted, removed, left, invitedByLink }

enum SearchType { query, tag, channel, user }

enum SortBy { relevance, newest, oldest, trending, popular, members, activity }

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

/// Channel invitation model for inviting users to channels
class ChannelInvitation {
  final String invitationId;
  final String channelId;
  final String invitedUserId;
  final String invitedByUserId;
  final String inviterName;
  final String role; // owner, moderator, member, guest
  final String? message;
  final String status; // pending, accepted, declined, cancelled, expired
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? respondedAt;
  final String invitationCode;

  ChannelInvitation({
    required this.invitationId,
    required this.channelId,
    required this.invitedUserId,
    required this.invitedByUserId,
    required this.inviterName,
    required this.role,
    this.message,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.respondedAt,
    required this.invitationCode,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';
  bool get isExpired => status == 'expired';
  bool get isActive => status == 'pending' && DateTime.now().isBefore(expiresAt);

  factory ChannelInvitation.empty(String channelId, String invitedUserId) {
    return ChannelInvitation(
      invitationId: '',
      channelId: channelId,
      invitedUserId: invitedUserId,
      invitedByUserId: '',
      inviterName: '',
      role: 'member',
      status: 'pending',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: 14)),
      invitationCode: '',
    );
  }

  factory ChannelInvitation.fromMap(Map<String, dynamic> map) {
    return ChannelInvitation(
      invitationId: map['invitationId'] as String? ?? '',
      channelId: map['channelId'] as String? ?? '',
      invitedUserId: map['invitedUserId'] as String? ?? '',
      invitedByUserId: map['invitedByUserId'] as String? ?? '',
      inviterName: map['inviterName'] as String? ?? '',
      role: map['role'] as String? ?? 'member',
      message: map['message'] as String?,
      status: map['status'] as String? ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now().add(Duration(days: 14)),
      respondedAt: (map['respondedAt'] as Timestamp?)?.toDate(),
      invitationCode: map['invitationCode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invitationId': invitationId,
      'channelId': channelId,
      'invitedUserId': invitedUserId,
      'invitedByUserId': invitedByUserId,
      'inviterName': inviterName,
      'role': role,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'invitationCode': invitationCode,
    };
  }

  ChannelInvitation copyWith({
    String? status,
    DateTime? respondedAt,
  }) {
    return ChannelInvitation(
      invitationId: invitationId,
      channelId: channelId,
      invitedUserId: invitedUserId,
      invitedByUserId: invitedByUserId,
      inviterName: inviterName,
      role: role,
      message: message,
      status: status ?? this.status,
      createdAt: createdAt,
      expiresAt: expiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
      invitationCode: invitationCode,
    );
  }
}

/// Access request model for requesting channel access
class AccessRequest {
  final String requestId;
  final String channelId;
  final String requestedByUserId;
  final String requesterName;
  final String? reason;
  final String status; // pending, approved, rejected, cancelled
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? respondedByUserId;
  final String? approvedRole;
  final String? rejectionReason;

  AccessRequest({
    required this.requestId,
    required this.channelId,
    required this.requestedByUserId,
    required this.requesterName,
    this.reason,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.respondedByUserId,
    this.approvedRole,
    this.rejectionReason,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';

  factory AccessRequest.empty(String channelId, String requestedByUserId) {
    return AccessRequest(
      requestId: '',
      channelId: channelId,
      requestedByUserId: requestedByUserId,
      requesterName: '',
      status: 'pending',
      createdAt: DateTime.now(),
    );
  }

  factory AccessRequest.fromMap(Map<String, dynamic> map) {
    return AccessRequest(
      requestId: map['requestId'] as String? ?? '',
      channelId: map['channelId'] as String? ?? '',
      requestedByUserId: map['requestedByUserId'] as String? ?? '',
      requesterName: map['requesterName'] as String? ?? '',
      reason: map['reason'] as String?,
      status: map['status'] as String? ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      respondedAt: (map['respondedAt'] as Timestamp?)?.toDate(),
      respondedByUserId: map['respondedByUserId'] as String?,
      approvedRole: map['approvedRole'] as String?,
      rejectionReason: map['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'channelId': channelId,
      'requestedByUserId': requestedByUserId,
      'requesterName': requesterName,
      'reason': reason,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'respondedByUserId': respondedByUserId,
      'approvedRole': approvedRole,
      'rejectionReason': rejectionReason,
    };
  }

  AccessRequest copyWith({
    String? status,
    DateTime? respondedAt,
    String? respondedByUserId,
    String? approvedRole,
    String? rejectionReason,
  }) {
    return AccessRequest(
      requestId: requestId,
      channelId: channelId,
      requestedByUserId: requestedByUserId,
      requesterName: requesterName,
      reason: reason,
      status: status ?? this.status,
      createdAt: createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      respondedByUserId: respondedByUserId ?? this.respondedByUserId,
      approvedRole: approvedRole ?? this.approvedRole,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

/// Channel member model for tracking members and their roles
class ChannelMember {
  final String memberId;
  final String channelId;
  final String userId;
  final String userName;
  final String role; // owner, moderator, member, guest
  final DateTime joinedAt;
  final DateTime? invitedAt;
  final String? invitedByUserId;
  final String status; // active, inactive, suspended, left
  final DateTime? lastActivityAt;

  ChannelMember({
    required this.memberId,
    required this.channelId,
    required this.userId,
    required this.userName,
    required this.role,
    required this.joinedAt,
    this.invitedAt,
    this.invitedByUserId,
    required this.status,
    this.lastActivityAt,
  });

  bool get isOwner => role == 'owner';
  bool get isModerator => role == 'moderator';
  bool get isRegularMember => role == 'member';
  bool get isGuest => role == 'guest';
  bool get isActive => status == 'active';
  bool get isSuspended => status == 'suspended';

  factory ChannelMember.empty(String channelId, String userId) {
    return ChannelMember(
      memberId: '',
      channelId: channelId,
      userId: userId,
      userName: '',
      role: 'member',
      joinedAt: DateTime.now(),
      status: 'active',
    );
  }

  factory ChannelMember.fromMap(Map<String, dynamic> map) {
    return ChannelMember(
      memberId: map['memberId'] as String? ?? '',
      channelId: map['channelId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      role: map['role'] as String? ?? 'member',
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      invitedAt: (map['invitedAt'] as Timestamp?)?.toDate(),
      invitedByUserId: map['invitedByUserId'] as String?,
      status: map['status'] as String? ?? 'active',
      lastActivityAt: (map['lastActivityAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'channelId': channelId,
      'userId': userId,
      'userName': userName,
      'role': role,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'invitedAt': invitedAt != null ? Timestamp.fromDate(invitedAt!) : null,
      'invitedByUserId': invitedByUserId,
      'status': status,
      'lastActivityAt': lastActivityAt != null ? Timestamp.fromDate(lastActivityAt!) : null,
    };
  }

  ChannelMember copyWith({
    String? role,
    String? status,
    DateTime? lastActivityAt,
  }) {
    return ChannelMember(
      memberId: memberId,
      channelId: channelId,
      userId: userId,
      userName: userName,
      role: role ?? this.role,
      joinedAt: joinedAt,
      invitedAt: invitedAt,
      invitedByUserId: invitedByUserId,
      status: status ?? this.status,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }
}

/// Access history entry for auditing access changes
class AccessHistoryEntry {
  final String historyId;
  final String channelId;
  final String userId;
  final String actor;
  final String action; // invited, joined, promoted, demoted, removed, left, invitedByLink
  final String? oldRole;
  final String? newRole;
  final String? reason;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  AccessHistoryEntry({
    required this.historyId,
    required this.channelId,
    required this.userId,
    required this.actor,
    required this.action,
    this.oldRole,
    this.newRole,
    this.reason,
    required this.createdAt,
    this.metadata = const {},
  });

  factory AccessHistoryEntry.empty(String channelId, String userId) {
    return AccessHistoryEntry(
      historyId: '',
      channelId: channelId,
      userId: userId,
      actor: '',
      action: 'joined',
      createdAt: DateTime.now(),
    );
  }

  factory AccessHistoryEntry.fromMap(Map<String, dynamic> map) {
    return AccessHistoryEntry(
      historyId: map['historyId'] as String? ?? '',
      channelId: map['channelId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      actor: map['actor'] as String? ?? '',
      action: map['action'] as String? ?? 'joined',
      oldRole: map['oldRole'] as String?,
      newRole: map['newRole'] as String?,
      reason: map['reason'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: (map['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'historyId': historyId,
      'channelId': channelId,
      'userId': userId,
      'actor': actor,
      'action': action,
      'oldRole': oldRole,
      'newRole': newRole,
      'reason': reason,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }

  AccessHistoryEntry copyWith({
    String? historyId,
    String? channelId,
    String? userId,
    String? actor,
    String? action,
    String? oldRole,
    String? newRole,
    String? reason,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return AccessHistoryEntry(
      historyId: historyId ?? this.historyId,
      channelId: channelId ?? this.channelId,
      userId: userId ?? this.userId,
      actor: actor ?? this.actor,
      action: action ?? this.action,
      oldRole: oldRole ?? this.oldRole,
      newRole: newRole ?? this.newRole,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Search result model for community search
class SearchResult {
  final String resultId;
  final String query;
  final String contentType; // 'post' or 'reply'
  final String contentId;
  final String title;
  final String snippet;
  final double relevanceScore;
  final String author;
  final String authorId;
  final String channelId;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int replyCount;
  final int reactionCount;
  final int viewCount;
  final String url;

  SearchResult({
    required this.resultId,
    required this.query,
    required this.contentType,
    required this.contentId,
    required this.title,
    required this.snippet,
    required this.relevanceScore,
    required this.author,
    required this.authorId,
    required this.channelId,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.replyCount = 0,
    this.reactionCount = 0,
    this.viewCount = 0,
    required this.url,
  });

  bool get isPost => contentType == 'post';
  bool get isReply => contentType == 'reply';

  factory SearchResult.empty() {
    return SearchResult(
      resultId: '',
      query: '',
      contentType: 'post',
      contentId: '',
      title: '',
      snippet: '',
      relevanceScore: 0.0,
      author: '',
      authorId: '',
      channelId: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      url: '',
    );
  }

  factory SearchResult.fromMap(Map<String, dynamic> map) {
    return SearchResult(
      resultId: map['resultId'] as String? ?? '',
      query: map['query'] as String? ?? '',
      contentType: map['contentType'] as String? ?? 'post',
      contentId: map['contentId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      snippet: map['snippet'] as String? ?? '',
      relevanceScore: (map['relevanceScore'] as num?)?.toDouble() ?? 0.0,
      author: map['author'] as String? ?? '',
      authorId: map['authorId'] as String? ?? '',
      channelId: map['channelId'] as String? ?? '',
      tags: (map['tags'] as List?)?.cast<String>() ?? [],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      replyCount: map['replyCount'] as int? ?? 0,
      reactionCount: map['reactionCount'] as int? ?? 0,
      viewCount: map['viewCount'] as int? ?? 0,
      url: map['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'resultId': resultId,
      'query': query,
      'contentType': contentType,
      'contentId': contentId,
      'title': title,
      'snippet': snippet,
      'relevanceScore': relevanceScore,
      'author': author,
      'authorId': authorId,
      'channelId': channelId,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'replyCount': replyCount,
      'reactionCount': reactionCount,
      'viewCount': viewCount,
      'url': url,
    };
  }

  SearchResult copyWith({
    double? relevanceScore,
    int? viewCount,
  }) {
    return SearchResult(
      resultId: resultId,
      query: query,
      contentType: contentType,
      contentId: contentId,
      title: title,
      snippet: snippet,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      author: author,
      authorId: authorId,
      channelId: channelId,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
      replyCount: replyCount,
      reactionCount: reactionCount,
      viewCount: viewCount ?? this.viewCount,
      url: url,
    );
  }
}

/// Search query model for tracking searches
class SearchQuery {
  final String queryId;
  final String userId;
  final String query;
  final int resultCount;
  final int timeMs;
  final Map<String, dynamic> filters;
  final DateTime createdAt;
  final String? selectedResultId;

  SearchQuery({
    required this.queryId,
    required this.userId,
    required this.query,
    required this.resultCount,
    required this.timeMs,
    this.filters = const {},
    required this.createdAt,
    this.selectedResultId,
  });

  factory SearchQuery.empty(String userId, String query) {
    return SearchQuery(
      queryId: '',
      userId: userId,
      query: query,
      resultCount: 0,
      timeMs: 0,
      createdAt: DateTime.now(),
    );
  }

  factory SearchQuery.fromMap(Map<String, dynamic> map) {
    return SearchQuery(
      queryId: map['queryId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      query: map['query'] as String? ?? '',
      resultCount: map['resultCount'] as int? ?? 0,
      timeMs: map['timeMs'] as int? ?? 0,
      filters: (map['filters'] as Map<String, dynamic>?) ?? {},
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      selectedResultId: map['selectedResultId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'queryId': queryId,
      'userId': userId,
      'query': query,
      'resultCount': resultCount,
      'timeMs': timeMs,
      'filters': filters,
      'createdAt': Timestamp.fromDate(createdAt),
      'selectedResultId': selectedResultId,
    };
  }

  SearchQuery copyWith({
    int? resultCount,
    int? timeMs,
    String? selectedResultId,
  }) {
    return SearchQuery(
      queryId: queryId,
      userId: userId,
      query: query,
      resultCount: resultCount ?? this.resultCount,
      timeMs: timeMs ?? this.timeMs,
      filters: filters,
      createdAt: createdAt,
      selectedResultId: selectedResultId ?? this.selectedResultId,
    );
  }
}

/// Saved search model
class SavedSearch {
  final String savedSearchId;
  final String userId;
  final String query;
  final String name;
  final String? description;
  final Map<String, dynamic> filters;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final int useCount;

  SavedSearch({
    required this.savedSearchId,
    required this.userId,
    required this.query,
    required this.name,
    this.description,
    this.filters = const {},
    required this.createdAt,
    this.lastUsedAt,
    this.useCount = 0,
  });

  factory SavedSearch.empty(String userId) {
    return SavedSearch(
      savedSearchId: '',
      userId: userId,
      query: '',
      name: '',
      createdAt: DateTime.now(),
    );
  }

  factory SavedSearch.fromMap(Map<String, dynamic> map) {
    return SavedSearch(
      savedSearchId: map['savedSearchId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      query: map['query'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String?,
      filters: (map['filters'] as Map<String, dynamic>?) ?? {},
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUsedAt: (map['lastUsedAt'] as Timestamp?)?.toDate(),
      useCount: map['useCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'savedSearchId': savedSearchId,
      'userId': userId,
      'query': query,
      'name': name,
      'description': description,
      'filters': filters,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUsedAt': lastUsedAt != null ? Timestamp.fromDate(lastUsedAt!) : null,
      'useCount': useCount,
    };
  }

  SavedSearch copyWith({
    DateTime? lastUsedAt,
    int? useCount,
  }) {
    return SavedSearch(
      savedSearchId: savedSearchId,
      userId: userId,
      query: query,
      name: name,
      description: description,
      filters: filters,
      createdAt: createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      useCount: useCount ?? this.useCount,
    );
  }
}

/// Search suggestion model
class SearchSuggestion {
  final String suggestionId;
  final String text;
  final String type; // query, tag, channel, user
  final String category;
  final int popularity;
  final DateTime? lastUsedAt;

  SearchSuggestion({
    required this.suggestionId,
    required this.text,
    required this.type,
    required this.category,
    required this.popularity,
    this.lastUsedAt,
  });

  bool get isQuery => type == 'query';
  bool get isTag => type == 'tag';
  bool get isChannel => type == 'channel';
  bool get isUser => type == 'user';

  factory SearchSuggestion.empty() {
    return SearchSuggestion(
      suggestionId: '',
      text: '',
      type: 'query',
      category: '',
      popularity: 0,
    );
  }

  factory SearchSuggestion.fromMap(Map<String, dynamic> map) {
    return SearchSuggestion(
      suggestionId: map['suggestionId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      type: map['type'] as String? ?? 'query',
      category: map['category'] as String? ?? '',
      popularity: map['popularity'] as int? ?? 0,
      lastUsedAt: (map['lastUsedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'suggestionId': suggestionId,
      'text': text,
      'type': type,
      'category': category,
      'popularity': popularity,
      'lastUsedAt': lastUsedAt != null ? Timestamp.fromDate(lastUsedAt!) : null,
    };
  }

  SearchSuggestion copyWith({
    int? popularity,
    DateTime? lastUsedAt,
  }) {
    return SearchSuggestion(
      suggestionId: suggestionId,
      text: text,
      type: type,
      category: category,
      popularity: popularity ?? this.popularity,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }
}

/// Search filters model
class SearchFilters {
  final List<String> channelIds;
  final List<String> authorIds;
  final List<String> tags;
  final String? status;
  final bool? hasMedia;
  final int? minReplies;
  final int? minReactions;
  final DateTime? fromDate;
  final DateTime? toDate;

  const SearchFilters({
    this.channelIds = const [],
    this.authorIds = const [],
    this.tags = const [],
    this.status,
    this.hasMedia,
    this.minReplies,
    this.minReactions,
    this.fromDate,
    this.toDate,
  });

  factory SearchFilters.fromMap(Map<String, dynamic> map) {
    return SearchFilters(
      channelIds: (map['channelIds'] as List?)?.cast<String>() ?? [],
      authorIds: (map['authorIds'] as List?)?.cast<String>() ?? [],
      tags: (map['tags'] as List?)?.cast<String>() ?? [],
      status: map['status'] as String?,
      hasMedia: map['hasMedia'] as bool?,
      minReplies: map['minReplies'] as int?,
      minReactions: map['minReactions'] as int?,
      fromDate: (map['fromDate'] as Timestamp?)?.toDate(),
      toDate: (map['toDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'channelIds': channelIds,
      'authorIds': authorIds,
      'tags': tags,
      'status': status,
      'hasMedia': hasMedia,
      'minReplies': minReplies,
      'minReactions': minReactions,
      'fromDate': fromDate != null ? Timestamp.fromDate(fromDate!) : null,
      'toDate': toDate != null ? Timestamp.fromDate(toDate!) : null,
    };
  }

  SearchFilters copyWith({
    List<String>? channelIds,
    List<String>? authorIds,
    List<String>? tags,
    String? status,
    bool? hasMedia,
    int? minReplies,
    int? minReactions,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return SearchFilters(
      channelIds: channelIds ?? this.channelIds,
      authorIds: authorIds ?? this.authorIds,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      hasMedia: hasMedia ?? this.hasMedia,
      minReplies: minReplies ?? this.minReplies,
      minReactions: minReactions ?? this.minReactions,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}
