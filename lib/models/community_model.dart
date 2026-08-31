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

enum AppealStatus { pending, approved, denied, upheld, overturned, partiallyUpheld }

enum ModerationActionType { warning, mute, removeContent, ban, escalate, dismiss }

enum EscalationTarget { adminReview, legalTeam, executive }

enum EscalationStatus { pending, processing, approved, denied, returned }

enum ReputationEventType { postCreated, replyCreated, postUpvoted, replyUpvoted, answerMarkedHelpful, contentApproved, reportApproved, contentModerated, receivedMention }

enum BadgeRarity { common, uncommon, rare, epic, legendary }

enum BadgeCategory { social, expertise, moderation, milestone, achievement }

enum MetricType { dau, mau, engagement, revenue, health, growth, moderation }

enum TimeRange { day, week, month, quarter, year, custom }

enum QuestionType { multipleChoice, trueFalse, essay, scenario }

enum QuestionDifficulty { beginner, intermediate, advanced }

enum TestStatus { inProgress, completed, abandoned }

enum ExamType { fullLength, halfLength, quickReview }

enum VideoStatus { draft, published, archived, processing }

enum VideoLanguage { japanese, english, mixed }

enum PartnershipStatus { pending, active, suspended, expired, terminated }

enum PartnershipTier { starter, professional, enterprise }

enum LicenseType { studentAccess, instructorAccess, administratorAccess }

enum SchoolCategory { driving_school, motorcycle_training, driving_academy, government_agency }

enum DashboardMetricType { revenue, engagement, completion, performance, activity, retention }

enum StudentPerformanceStatus { excellent, good, average, atRisk, critical }

enum ReportType { performance, engagement, attendance, completion, readiness, custom }

enum ContentStatus { draft, published, archived, inactive }

enum ContentAccessLevel { public, institutional, restrictedInstitutional }

enum CourseStatus { draft, active, archived, completed }

enum CurriculumType { standardCurriculum, customCurriculum, accelerated }

enum BadgeType {
  // Milestone badges
  firstQuestion,
  tenQuestions,
  fiftyQuestions,
  hundredQuestions,
  fiveHundredQuestions,

  // Streak badges
  threeStreak,
  sevenStreak,
  thirtyStreak,
  hundredStreak,

  // Accuracy badges
  seventyPercent,
  eightyPercent,
  ninetyPercent,
  perfectScore,

  // Category mastery
  trafficRulesMastery,
  crisisAvoidanceMastery,
  mechanicalKnowledgeMastery,
  allCategoriesMastery,

  // Consistency badges
  dailyStudier,
  weeklyConsistent,
  monthlyDedicated,

  // Challenge badges
  speedDemon,
  nightOwl,
  morningStudier,
  weekendWarrior,
}

enum BadgeRarityLevel { common, uncommon, rare, epic, legendary }

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

/// Report appeal model for appealing moderation decisions
class ReportAppeal {
  final String appealId;
  final String reportId;
  final String userId;
  final String? userName;
  final String reason;
  final String? attachmentUrl;
  final AppealStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? respondedByUserId;
  final String? reasoning;
  final String? newAction;
  final bool canAppealFurther;

  ReportAppeal({
    required this.appealId,
    required this.reportId,
    required this.userId,
    this.userName,
    required this.reason,
    this.attachmentUrl,
    this.status = AppealStatus.pending,
    required this.createdAt,
    this.respondedAt,
    this.respondedByUserId,
    this.reasoning,
    this.newAction,
    this.canAppealFurther = true,
  });

  factory ReportAppeal.empty() {
    return ReportAppeal(
      appealId: '',
      reportId: '',
      userId: '',
      reason: '',
      createdAt: DateTime.now(),
    );
  }

  factory ReportAppeal.fromMap(Map<String, dynamic> map) {
    return ReportAppeal(
      appealId: map['appealId'] as String? ?? '',
      reportId: map['reportId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String?,
      reason: map['reason'] as String? ?? '',
      attachmentUrl: map['attachmentUrl'] as String?,
      status: AppealStatus.values[(map['status'] as int?) ?? AppealStatus.pending.index],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      respondedAt: (map['respondedAt'] as Timestamp?)?.toDate(),
      respondedByUserId: map['respondedByUserId'] as String?,
      reasoning: map['reasoning'] as String?,
      newAction: map['newAction'] as String?,
      canAppealFurther: map['canAppealFurther'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appealId': appealId,
      'reportId': reportId,
      'userId': userId,
      'userName': userName,
      'reason': reason,
      'attachmentUrl': attachmentUrl,
      'status': status.index,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'respondedByUserId': respondedByUserId,
      'reasoning': reasoning,
      'newAction': newAction,
      'canAppealFurther': canAppealFurther,
    };
  }

  ReportAppeal copyWith({
    AppealStatus? status,
    DateTime? respondedAt,
    String? respondedByUserId,
    String? reasoning,
    String? newAction,
  }) {
    return ReportAppeal(
      appealId: appealId,
      reportId: reportId,
      userId: userId,
      userName: userName,
      reason: reason,
      attachmentUrl: attachmentUrl,
      status: status ?? this.status,
      createdAt: createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      respondedByUserId: respondedByUserId ?? this.respondedByUserId,
      reasoning: reasoning ?? this.reasoning,
      newAction: newAction ?? this.newAction,
      canAppealFurther: canAppealFurther,
    );
  }
}

/// Moderation summary statistics model
class ModerationSummary {
  final String summaryId;
  final String timeRange; // day, week, month
  final DateTime startDate;
  final DateTime endDate;
  final int totalReports;
  final int reviewedReports;
  final int pendingReports;
  final int actionsApproved;
  final int actionsDenied;
  final int appealsReceived;
  final int appealsPending;
  final int appealsApproved;
  final int appealsOverturned;
  final int averageReviewTime;
  final double communityHealthScore;

  ModerationSummary({
    required this.summaryId,
    required this.timeRange,
    required this.startDate,
    required this.endDate,
    this.totalReports = 0,
    this.reviewedReports = 0,
    this.pendingReports = 0,
    this.actionsApproved = 0,
    this.actionsDenied = 0,
    this.appealsReceived = 0,
    this.appealsPending = 0,
    this.appealsApproved = 0,
    this.appealsOverturned = 0,
    this.averageReviewTime = 0,
    this.communityHealthScore = 100.0,
  });

  factory ModerationSummary.empty() {
    return ModerationSummary(
      summaryId: '',
      timeRange: 'day',
      startDate: DateTime.now(),
      endDate: DateTime.now(),
    );
  }

  factory ModerationSummary.fromMap(Map<String, dynamic> map) {
    return ModerationSummary(
      summaryId: map['summaryId'] as String? ?? '',
      timeRange: map['timeRange'] as String? ?? 'day',
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalReports: map['totalReports'] as int? ?? 0,
      reviewedReports: map['reviewedReports'] as int? ?? 0,
      pendingReports: map['pendingReports'] as int? ?? 0,
      actionsApproved: map['actionsApproved'] as int? ?? 0,
      actionsDenied: map['actionsDenied'] as int? ?? 0,
      appealsReceived: map['appealsReceived'] as int? ?? 0,
      appealsPending: map['appealsPending'] as int? ?? 0,
      appealsApproved: map['appealsApproved'] as int? ?? 0,
      appealsOverturned: map['appealsOverturned'] as int? ?? 0,
      averageReviewTime: map['averageReviewTime'] as int? ?? 0,
      communityHealthScore: (map['communityHealthScore'] as num?)?.toDouble() ?? 100.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'summaryId': summaryId,
      'timeRange': timeRange,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalReports': totalReports,
      'reviewedReports': reviewedReports,
      'pendingReports': pendingReports,
      'actionsApproved': actionsApproved,
      'actionsDenied': actionsDenied,
      'appealsReceived': appealsReceived,
      'appealsPending': appealsPending,
      'appealsApproved': appealsApproved,
      'appealsOverturned': appealsOverturned,
      'averageReviewTime': averageReviewTime,
      'communityHealthScore': communityHealthScore,
    };
  }

  ModerationSummary copyWith({
    int? totalReports,
    int? reviewedReports,
    int? pendingReports,
    int? actionsApproved,
    int? actionsDenied,
    int? appealsReceived,
    int? appealsPending,
    int? appealsApproved,
    int? appealsOverturned,
    int? averageReviewTime,
    double? communityHealthScore,
  }) {
    return ModerationSummary(
      summaryId: summaryId,
      timeRange: timeRange,
      startDate: startDate,
      endDate: endDate,
      totalReports: totalReports ?? this.totalReports,
      reviewedReports: reviewedReports ?? this.reviewedReports,
      pendingReports: pendingReports ?? this.pendingReports,
      actionsApproved: actionsApproved ?? this.actionsApproved,
      actionsDenied: actionsDenied ?? this.actionsDenied,
      appealsReceived: appealsReceived ?? this.appealsReceived,
      appealsPending: appealsPending ?? this.appealsPending,
      appealsApproved: appealsApproved ?? this.appealsApproved,
      appealsOverturned: appealsOverturned ?? this.appealsOverturned,
      averageReviewTime: averageReviewTime ?? this.averageReviewTime,
      communityHealthScore: communityHealthScore ?? this.communityHealthScore,
    );
  }
}

/// Moderator statistics model
class ModeratorStats {
  final String statsId;
  final String moderatorId;
  final String? moderatorName;
  final String timeRange; // day, week, month
  final int totalActionsCount;
  final int averageDecisionTimeMs;
  final Map<String, int> reportsByCategory;
  final Map<String, int> actionsByType;
  final int appealsOnDecisions;
  final double appealOverturnRate;
  final double consistencyScore;
  final double communityFeedbackScore;
  final DateTime lastActivityAt;

  ModeratorStats({
    required this.statsId,
    required this.moderatorId,
    this.moderatorName,
    required this.timeRange,
    this.totalActionsCount = 0,
    this.averageDecisionTimeMs = 0,
    this.reportsByCategory = const {},
    this.actionsByType = const {},
    this.appealsOnDecisions = 0,
    this.appealOverturnRate = 0.0,
    this.consistencyScore = 100.0,
    this.communityFeedbackScore = 0.0,
    required this.lastActivityAt,
  });

  factory ModeratorStats.empty() {
    return ModeratorStats(
      statsId: '',
      moderatorId: '',
      timeRange: 'month',
      lastActivityAt: DateTime.now(),
    );
  }

  factory ModeratorStats.fromMap(Map<String, dynamic> map) {
    return ModeratorStats(
      statsId: map['statsId'] as String? ?? '',
      moderatorId: map['moderatorId'] as String? ?? '',
      moderatorName: map['moderatorName'] as String?,
      timeRange: map['timeRange'] as String? ?? 'month',
      totalActionsCount: map['totalActionsCount'] as int? ?? 0,
      averageDecisionTimeMs: map['averageDecisionTimeMs'] as int? ?? 0,
      reportsByCategory: Map<String, int>.from(map['reportsByCategory'] as Map? ?? {}),
      actionsByType: Map<String, int>.from(map['actionsByType'] as Map? ?? {}),
      appealsOnDecisions: map['appealsOnDecisions'] as int? ?? 0,
      appealOverturnRate: (map['appealOverturnRate'] as num?)?.toDouble() ?? 0.0,
      consistencyScore: (map['consistencyScore'] as num?)?.toDouble() ?? 100.0,
      communityFeedbackScore: (map['communityFeedbackScore'] as num?)?.toDouble() ?? 0.0,
      lastActivityAt: (map['lastActivityAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'statsId': statsId,
      'moderatorId': moderatorId,
      'moderatorName': moderatorName,
      'timeRange': timeRange,
      'totalActionsCount': totalActionsCount,
      'averageDecisionTimeMs': averageDecisionTimeMs,
      'reportsByCategory': reportsByCategory,
      'actionsByType': actionsByType,
      'appealsOnDecisions': appealsOnDecisions,
      'appealOverturnRate': appealOverturnRate,
      'consistencyScore': consistencyScore,
      'communityFeedbackScore': communityFeedbackScore,
      'lastActivityAt': Timestamp.fromDate(lastActivityAt),
    };
  }

  ModeratorStats copyWith({
    int? totalActionsCount,
    int? averageDecisionTimeMs,
    Map<String, int>? reportsByCategory,
    Map<String, int>? actionsByType,
    int? appealsOnDecisions,
    double? appealOverturnRate,
    double? consistencyScore,
    double? communityFeedbackScore,
    DateTime? lastActivityAt,
  }) {
    return ModeratorStats(
      statsId: statsId,
      moderatorId: moderatorId,
      moderatorName: moderatorName,
      timeRange: timeRange,
      totalActionsCount: totalActionsCount ?? this.totalActionsCount,
      averageDecisionTimeMs: averageDecisionTimeMs ?? this.averageDecisionTimeMs,
      reportsByCategory: reportsByCategory ?? this.reportsByCategory,
      actionsByType: actionsByType ?? this.actionsByType,
      appealsOnDecisions: appealsOnDecisions ?? this.appealsOnDecisions,
      appealOverturnRate: appealOverturnRate ?? this.appealOverturnRate,
      consistencyScore: consistencyScore ?? this.consistencyScore,
      communityFeedbackScore: communityFeedbackScore ?? this.communityFeedbackScore,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }
}

/// Moderation action record model
class ModerationActionRecord {
  final String actionId;
  final String reportId;
  final String moderatorId;
  final ModerationActionType actionType;
  final String targetUserId;
  final String? targetPostId;
  final String reason;
  final int? duration; // in days
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  ModerationActionRecord({
    required this.actionId,
    required this.reportId,
    required this.moderatorId,
    required this.actionType,
    required this.targetUserId,
    this.targetPostId,
    required this.reason,
    this.duration,
    this.metadata = const {},
    required this.createdAt,
    this.resolvedAt,
  });

  factory ModerationActionRecord.empty() {
    return ModerationActionRecord(
      actionId: '',
      reportId: '',
      moderatorId: '',
      actionType: ModerationActionType.warning,
      targetUserId: '',
      reason: '',
      createdAt: DateTime.now(),
    );
  }

  factory ModerationActionRecord.fromMap(Map<String, dynamic> map) {
    return ModerationActionRecord(
      actionId: map['actionId'] as String? ?? '',
      reportId: map['reportId'] as String? ?? '',
      moderatorId: map['moderatorId'] as String? ?? '',
      actionType: ModerationActionType.values[(map['actionType'] as int?) ?? ModerationActionType.warning.index],
      targetUserId: map['targetUserId'] as String? ?? '',
      targetPostId: map['targetPostId'] as String?,
      reason: map['reason'] as String? ?? '',
      duration: map['duration'] as int?,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'actionId': actionId,
      'reportId': reportId,
      'moderatorId': moderatorId,
      'actionType': actionType.index,
      'targetUserId': targetUserId,
      'targetPostId': targetPostId,
      'reason': reason,
      'duration': duration,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  ModerationActionRecord copyWith({
    DateTime? resolvedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ModerationActionRecord(
      actionId: actionId,
      reportId: reportId,
      moderatorId: moderatorId,
      actionType: actionType,
      targetUserId: targetUserId,
      targetPostId: targetPostId,
      reason: reason,
      duration: duration,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

/// Escalation model for routing complex cases
class Escalation {
  final String escalationId;
  final String reportId;
  final String escalatedByUserId;
  final DateTime escalatedAt;
  final EscalationTarget escalateTo;
  final String reason;
  final EscalationStatus status;
  final String? processedByUserId;
  final DateTime? processedAt;
  final String? decision;
  final String? notes;

  Escalation({
    required this.escalationId,
    required this.reportId,
    required this.escalatedByUserId,
    required this.escalatedAt,
    required this.escalateTo,
    required this.reason,
    this.status = EscalationStatus.pending,
    this.processedByUserId,
    this.processedAt,
    this.decision,
    this.notes,
  });

  factory Escalation.empty() {
    return Escalation(
      escalationId: '',
      reportId: '',
      escalatedByUserId: '',
      escalatedAt: DateTime.now(),
      escalateTo: EscalationTarget.adminReview,
      reason: '',
    );
  }

  factory Escalation.fromMap(Map<String, dynamic> map) {
    return Escalation(
      escalationId: map['escalationId'] as String? ?? '',
      reportId: map['reportId'] as String? ?? '',
      escalatedByUserId: map['escalatedByUserId'] as String? ?? '',
      escalatedAt: (map['escalatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      escalateTo: EscalationTarget.values[(map['escalateTo'] as int?) ?? EscalationTarget.adminReview.index],
      reason: map['reason'] as String? ?? '',
      status: EscalationStatus.values[(map['status'] as int?) ?? EscalationStatus.pending.index],
      processedByUserId: map['processedByUserId'] as String?,
      processedAt: (map['processedAt'] as Timestamp?)?.toDate(),
      decision: map['decision'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'escalationId': escalationId,
      'reportId': reportId,
      'escalatedByUserId': escalatedByUserId,
      'escalatedAt': Timestamp.fromDate(escalatedAt),
      'escalateTo': escalateTo.index,
      'reason': reason,
      'status': status.index,
      'processedByUserId': processedByUserId,
      'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
      'decision': decision,
      'notes': notes,
    };
  }

  Escalation copyWith({
    EscalationStatus? status,
    String? processedByUserId,
    DateTime? processedAt,
    String? decision,
    String? notes,
  }) {
    return Escalation(
      escalationId: escalationId,
      reportId: reportId,
      escalatedByUserId: escalatedByUserId,
      escalatedAt: escalatedAt,
      escalateTo: escalateTo,
      reason: reason,
      status: status ?? this.status,
      processedByUserId: processedByUserId ?? this.processedByUserId,
      processedAt: processedAt ?? this.processedAt,
      decision: decision ?? this.decision,
      notes: notes ?? this.notes,
    );
  }
}

/// User reputation model
class UserReputation {
  final String reputationId;
  final String userId;
  final int totalScore;
  final int currentLevel;
  final String levelTitle;
  final int postsCount;
  final int repliesCount;
  final int upvotesReceived;
  final int badgesCount;
  final DateTime createdAt;
  final DateTime lastActivityAt;

  UserReputation({
    required this.reputationId,
    required this.userId,
    this.totalScore = 0,
    this.currentLevel = 1,
    this.levelTitle = 'Novice',
    this.postsCount = 0,
    this.repliesCount = 0,
    this.upvotesReceived = 0,
    this.badgesCount = 0,
    required this.createdAt,
    required this.lastActivityAt,
  });

  factory UserReputation.empty() {
    return UserReputation(
      reputationId: '',
      userId: '',
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );
  }

  factory UserReputation.fromMap(Map<String, dynamic> map) {
    return UserReputation(
      reputationId: map['reputationId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      totalScore: map['totalScore'] as int? ?? 0,
      currentLevel: map['currentLevel'] as int? ?? 1,
      levelTitle: map['levelTitle'] as String? ?? 'Novice',
      postsCount: map['postsCount'] as int? ?? 0,
      repliesCount: map['repliesCount'] as int? ?? 0,
      upvotesReceived: map['upvotesReceived'] as int? ?? 0,
      badgesCount: map['badgesCount'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActivityAt: (map['lastActivityAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reputationId': reputationId,
      'userId': userId,
      'totalScore': totalScore,
      'currentLevel': currentLevel,
      'levelTitle': levelTitle,
      'postsCount': postsCount,
      'repliesCount': repliesCount,
      'upvotesReceived': upvotesReceived,
      'badgesCount': badgesCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActivityAt': Timestamp.fromDate(lastActivityAt),
    };
  }

  UserReputation copyWith({
    int? totalScore,
    int? currentLevel,
    String? levelTitle,
    int? postsCount,
    int? repliesCount,
    int? upvotesReceived,
    int? badgesCount,
    DateTime? lastActivityAt,
  }) {
    return UserReputation(
      reputationId: reputationId,
      userId: userId,
      totalScore: totalScore ?? this.totalScore,
      currentLevel: currentLevel ?? this.currentLevel,
      levelTitle: levelTitle ?? this.levelTitle,
      postsCount: postsCount ?? this.postsCount,
      repliesCount: repliesCount ?? this.repliesCount,
      upvotesReceived: upvotesReceived ?? this.upvotesReceived,
      badgesCount: badgesCount ?? this.badgesCount,
      createdAt: createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }
}

/// Reputation event model
class ReputationEvent {
  final String eventId;
  final String userId;
  final ReputationEventType eventType;
  final int points;
  final String reason;
  final String? relatedContentId;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  ReputationEvent({
    required this.eventId,
    required this.userId,
    required this.eventType,
    required this.points,
    required this.reason,
    this.relatedContentId,
    required this.createdAt,
    this.metadata = const {},
  });

  factory ReputationEvent.empty() {
    return ReputationEvent(
      eventId: '',
      userId: '',
      eventType: ReputationEventType.postCreated,
      points: 0,
      reason: '',
      createdAt: DateTime.now(),
    );
  }

  factory ReputationEvent.fromMap(Map<String, dynamic> map) {
    return ReputationEvent(
      eventId: map['eventId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      eventType: ReputationEventType.values[(map['eventType'] as int?) ?? ReputationEventType.postCreated.index],
      points: map['points'] as int? ?? 0,
      reason: map['reason'] as String? ?? '',
      relatedContentId: map['relatedContentId'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'eventType': eventType.index,
      'points': points,
      'reason': reason,
      'relatedContentId': relatedContentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }
}

/// Badge definition model
class BadgeDefinition {
  final String badgeId;
  final String name;
  final String description;
  final BadgeCategory category;
  final BadgeRarity rarity;
  final int pointsValue;
  final String iconUrl;
  final Map<String, dynamic> requirements;
  final DateTime createdAt;
  final bool isActive;

  BadgeDefinition({
    required this.badgeId,
    required this.name,
    required this.description,
    required this.category,
    required this.rarity,
    required this.pointsValue,
    required this.iconUrl,
    this.requirements = const {},
    required this.createdAt,
    this.isActive = true,
  });

  factory BadgeDefinition.empty() {
    return BadgeDefinition(
      badgeId: '',
      name: '',
      description: '',
      category: BadgeCategory.social,
      rarity: BadgeRarity.common,
      pointsValue: 0,
      iconUrl: '',
      createdAt: DateTime.now(),
    );
  }

  factory BadgeDefinition.fromMap(Map<String, dynamic> map) {
    return BadgeDefinition(
      badgeId: map['badgeId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: BadgeCategory.values[(map['category'] as int?) ?? BadgeCategory.social.index],
      rarity: BadgeRarity.values[(map['rarity'] as int?) ?? BadgeRarity.common.index],
      pointsValue: map['pointsValue'] as int? ?? 0,
      iconUrl: map['iconUrl'] as String? ?? '',
      requirements: Map<String, dynamic>.from(map['requirements'] as Map? ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'badgeId': badgeId,
      'name': name,
      'description': description,
      'category': category.index,
      'rarity': rarity.index,
      'pointsValue': pointsValue,
      'iconUrl': iconUrl,
      'requirements': requirements,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  BadgeDefinition copyWith({
    String? name,
    String? description,
    BadgeRarity? rarity,
    int? pointsValue,
    String? iconUrl,
    Map<String, dynamic>? requirements,
    bool? isActive,
  }) {
    return BadgeDefinition(
      badgeId: badgeId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category,
      rarity: rarity ?? this.rarity,
      pointsValue: pointsValue ?? this.pointsValue,
      iconUrl: iconUrl ?? this.iconUrl,
      requirements: requirements ?? this.requirements,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// User badge model
class UserBadge {
  final String userBadgeId;
  final String badgeId;
  final String userId;
  final DateTime earnedAt;
  final String? awardedBy;
  final String? reason;
  final bool isDisplayed;
  final int level;

  UserBadge({
    required this.userBadgeId,
    required this.badgeId,
    required this.userId,
    required this.earnedAt,
    this.awardedBy,
    this.reason,
    this.isDisplayed = true,
    this.level = 1,
  });

  factory UserBadge.empty() {
    return UserBadge(
      userBadgeId: '',
      badgeId: '',
      userId: '',
      earnedAt: DateTime.now(),
    );
  }

  factory UserBadge.fromMap(Map<String, dynamic> map) {
    return UserBadge(
      userBadgeId: map['userBadgeId'] as String? ?? '',
      badgeId: map['badgeId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      earnedAt: (map['earnedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      awardedBy: map['awardedBy'] as String?,
      reason: map['reason'] as String?,
      isDisplayed: map['isDisplayed'] as bool? ?? true,
      level: map['level'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userBadgeId': userBadgeId,
      'badgeId': badgeId,
      'userId': userId,
      'earnedAt': Timestamp.fromDate(earnedAt),
      'awardedBy': awardedBy,
      'reason': reason,
      'isDisplayed': isDisplayed,
      'level': level,
    };
  }

  UserBadge copyWith({
    bool? isDisplayed,
    int? level,
    String? reason,
  }) {
    return UserBadge(
      userBadgeId: userBadgeId,
      badgeId: badgeId,
      userId: userId,
      earnedAt: earnedAt,
      awardedBy: awardedBy,
      reason: reason ?? this.reason,
      isDisplayed: isDisplayed ?? this.isDisplayed,
      level: level ?? this.level,
    );
  }
}

/// Platform metrics model
class PlatformMetrics {
  final String metricsId;
  final DateTime date;
  final int dau; // Daily active users
  final int mau; // Monthly active users
  final int newUsers;
  final int totalUsers;
  final int postsCreated;
  final int repliesCreated;
  final int reportsSubmitted;
  final int moderationActions;
  final double revenue;
  final int subscriptions;
  final Map<String, dynamic> metadata;

  PlatformMetrics({
    required this.metricsId,
    required this.date,
    this.dau = 0,
    this.mau = 0,
    this.newUsers = 0,
    this.totalUsers = 0,
    this.postsCreated = 0,
    this.repliesCreated = 0,
    this.reportsSubmitted = 0,
    this.moderationActions = 0,
    this.revenue = 0.0,
    this.subscriptions = 0,
    this.metadata = const {},
  });

  factory PlatformMetrics.empty() {
    return PlatformMetrics(
      metricsId: '',
      date: DateTime.now(),
    );
  }

  factory PlatformMetrics.fromMap(Map<String, dynamic> map) {
    return PlatformMetrics(
      metricsId: map['metricsId'] as String? ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dau: map['dau'] as int? ?? 0,
      mau: map['mau'] as int? ?? 0,
      newUsers: map['newUsers'] as int? ?? 0,
      totalUsers: map['totalUsers'] as int? ?? 0,
      postsCreated: map['postsCreated'] as int? ?? 0,
      repliesCreated: map['repliesCreated'] as int? ?? 0,
      reportsSubmitted: map['reportsSubmitted'] as int? ?? 0,
      moderationActions: map['moderationActions'] as int? ?? 0,
      revenue: (map['revenue'] as num?)?.toDouble() ?? 0.0,
      subscriptions: map['subscriptions'] as int? ?? 0,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'metricsId': metricsId,
      'date': Timestamp.fromDate(date),
      'dau': dau,
      'mau': mau,
      'newUsers': newUsers,
      'totalUsers': totalUsers,
      'postsCreated': postsCreated,
      'repliesCreated': repliesCreated,
      'reportsSubmitted': reportsSubmitted,
      'moderationActions': moderationActions,
      'revenue': revenue,
      'subscriptions': subscriptions,
      'metadata': metadata,
    };
  }
}

/// User engagement metrics model
class UserEngagementMetrics {
  final String engagementId;
  final String userId;
  final DateTime date;
  final int postsCreated;
  final int repliesCreated;
  final double engagementScore;
  final int sessionCount;
  final int timeSpent; // in minutes
  final DateTime lastActiveAt;
  final bool isActive;

  UserEngagementMetrics({
    required this.engagementId,
    required this.userId,
    required this.date,
    this.postsCreated = 0,
    this.repliesCreated = 0,
    this.engagementScore = 0.0,
    this.sessionCount = 0,
    this.timeSpent = 0,
    required this.lastActiveAt,
    this.isActive = false,
  });

  factory UserEngagementMetrics.empty() {
    return UserEngagementMetrics(
      engagementId: '',
      userId: '',
      date: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
  }

  factory UserEngagementMetrics.fromMap(Map<String, dynamic> map) {
    return UserEngagementMetrics(
      engagementId: map['engagementId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      postsCreated: map['postsCreated'] as int? ?? 0,
      repliesCreated: map['repliesCreated'] as int? ?? 0,
      engagementScore: (map['engagementScore'] as num?)?.toDouble() ?? 0.0,
      sessionCount: map['sessionCount'] as int? ?? 0,
      timeSpent: map['timeSpent'] as int? ?? 0,
      lastActiveAt: (map['lastActiveAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'engagementId': engagementId,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'postsCreated': postsCreated,
      'repliesCreated': repliesCreated,
      'engagementScore': engagementScore,
      'sessionCount': sessionCount,
      'timeSpent': timeSpent,
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'isActive': isActive,
    };
  }
}

/// Content analytics model
class ContentAnalytics {
  final String contentId;
  final String contentType; // 'post' or 'reply'
  final String authorId;
  final String channelId;
  final DateTime createdAt;
  final int views;
  final int reactions;
  final int replies;
  final int shares;
  final double sentiment;
  final double performanceScore;

  ContentAnalytics({
    required this.contentId,
    required this.contentType,
    required this.authorId,
    required this.channelId,
    required this.createdAt,
    this.views = 0,
    this.reactions = 0,
    this.replies = 0,
    this.shares = 0,
    this.sentiment = 0.5,
    this.performanceScore = 0.0,
  });

  factory ContentAnalytics.empty() {
    return ContentAnalytics(
      contentId: '',
      contentType: '',
      authorId: '',
      channelId: '',
      createdAt: DateTime.now(),
    );
  }

  factory ContentAnalytics.fromMap(Map<String, dynamic> map) {
    return ContentAnalytics(
      contentId: map['contentId'] as String? ?? '',
      contentType: map['contentType'] as String? ?? '',
      authorId: map['authorId'] as String? ?? '',
      channelId: map['channelId'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      views: map['views'] as int? ?? 0,
      reactions: map['reactions'] as int? ?? 0,
      replies: map['replies'] as int? ?? 0,
      shares: map['shares'] as int? ?? 0,
      sentiment: (map['sentiment'] as num?)?.toDouble() ?? 0.5,
      performanceScore: (map['performanceScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contentId': contentId,
      'contentType': contentType,
      'authorId': authorId,
      'channelId': channelId,
      'createdAt': Timestamp.fromDate(createdAt),
      'views': views,
      'reactions': reactions,
      'replies': replies,
      'shares': shares,
      'sentiment': sentiment,
      'performanceScore': performanceScore,
    };
  }
}

/// Community health metrics model
class CommunityHealthMetrics {
  final String healthId;
  final DateTime date;
  final double overallScore;
  final double sentimentScore;
  final double toxicityLevel;
  final double memberSatisfaction;
  final double retentionIndex;
  final double moderatorEffectiveness;
  final double reportResolutionRate;
  final double communityGrowth;

  CommunityHealthMetrics({
    required this.healthId,
    required this.date,
    this.overallScore = 75.0,
    this.sentimentScore = 0.7,
    this.toxicityLevel = 0.1,
    this.memberSatisfaction = 0.75,
    this.retentionIndex = 0.8,
    this.moderatorEffectiveness = 0.85,
    this.reportResolutionRate = 0.9,
    this.communityGrowth = 0.1,
  });

  factory CommunityHealthMetrics.empty() {
    return CommunityHealthMetrics(
      healthId: '',
      date: DateTime.now(),
    );
  }

  factory CommunityHealthMetrics.fromMap(Map<String, dynamic> map) {
    return CommunityHealthMetrics(
      healthId: map['healthId'] as String? ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      overallScore: (map['overallScore'] as num?)?.toDouble() ?? 75.0,
      sentimentScore: (map['sentimentScore'] as num?)?.toDouble() ?? 0.7,
      toxicityLevel: (map['toxicityLevel'] as num?)?.toDouble() ?? 0.1,
      memberSatisfaction: (map['memberSatisfaction'] as num?)?.toDouble() ?? 0.75,
      retentionIndex: (map['retentionIndex'] as num?)?.toDouble() ?? 0.8,
      moderatorEffectiveness: (map['moderatorEffectiveness'] as num?)?.toDouble() ?? 0.85,
      reportResolutionRate: (map['reportResolutionRate'] as num?)?.toDouble() ?? 0.9,
      communityGrowth: (map['communityGrowth'] as num?)?.toDouble() ?? 0.1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'healthId': healthId,
      'date': Timestamp.fromDate(date),
      'overallScore': overallScore,
      'sentimentScore': sentimentScore,
      'toxicityLevel': toxicityLevel,
      'memberSatisfaction': memberSatisfaction,
      'retentionIndex': retentionIndex,
      'moderatorEffectiveness': moderatorEffectiveness,
      'reportResolutionRate': reportResolutionRate,
      'communityGrowth': communityGrowth,
    };
  }

  CommunityHealthMetrics copyWith({
    double? overallScore,
    double? sentimentScore,
    double? toxicityLevel,
    double? memberSatisfaction,
    double? retentionIndex,
    double? moderatorEffectiveness,
    double? reportResolutionRate,
    double? communityGrowth,
  }) {
    return CommunityHealthMetrics(
      healthId: healthId,
      date: date,
      overallScore: overallScore ?? this.overallScore,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      toxicityLevel: toxicityLevel ?? this.toxicityLevel,
      memberSatisfaction: memberSatisfaction ?? this.memberSatisfaction,
      retentionIndex: retentionIndex ?? this.retentionIndex,
      moderatorEffectiveness: moderatorEffectiveness ?? this.moderatorEffectiveness,
      reportResolutionRate: reportResolutionRate ?? this.reportResolutionRate,
      communityGrowth: communityGrowth ?? this.communityGrowth,
    );
  }
}

/// Question model for practice tests and mock exams
class Question {
  final String questionId;
  final String questionText;
  final QuestionType questionType;
  final String topic;
  final QuestionDifficulty difficulty;
  final List<String> options;
  final int? correctAnswerIndex;
  final String? correctAnswer;
  final String explanation;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int usageCount;
  final double averageScore;
  final bool isActive;
  final String? videoId;
  final String? videoTitle;
  final int? videoDuration;
  final String? videoTranscript;

  Question({
    required this.questionId,
    required this.questionText,
    required this.questionType,
    required this.topic,
    required this.difficulty,
    this.options = const [],
    this.correctAnswerIndex,
    this.correctAnswer,
    this.explanation = '',
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.usageCount = 0,
    this.averageScore = 0.0,
    this.isActive = true,
    this.videoId,
    this.videoTitle,
    this.videoDuration,
    this.videoTranscript,
  });

  factory Question.empty() {
    return Question(
      questionId: '',
      questionText: '',
      questionType: QuestionType.multipleChoice,
      topic: '',
      difficulty: QuestionDifficulty.beginner,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionId: map['questionId'] as String? ?? '',
      questionText: map['questionText'] as String? ?? '',
      questionType: QuestionType.values[map['questionType'] as int? ?? 0],
      topic: map['topic'] as String? ?? '',
      difficulty: QuestionDifficulty.values[map['difficulty'] as int? ?? 0],
      options: List<String>.from(map['options'] as List? ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] as int?,
      correctAnswer: map['correctAnswer'] as String?,
      explanation: map['explanation'] as String? ?? '',
      tags: List<String>.from(map['tags'] as List? ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      usageCount: map['usageCount'] as int? ?? 0,
      averageScore: (map['averageScore'] as num?)?.toDouble() ?? 0.0,
      isActive: map['isActive'] as bool? ?? true,
      videoId: map['videoId'] as String?,
      videoTitle: map['videoTitle'] as String?,
      videoDuration: map['videoDuration'] as int?,
      videoTranscript: map['videoTranscript'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'questionType': questionType.index,
      'topic': topic,
      'difficulty': difficulty.index,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'usageCount': usageCount,
      'averageScore': averageScore,
      'isActive': isActive,
      'videoId': videoId,
      'videoTitle': videoTitle,
      'videoDuration': videoDuration,
      'videoTranscript': videoTranscript,
    };
  }
}

/// Video explanation model for providing video content for questions
class VideoExplanation {
  final String videoId;
  final String questionId;
  final String title;
  final String description;
  final int duration; // in seconds
  final String url;
  final String? transcript;
  final String? thumbnailUrl;
  final VideoStatus status;
  final VideoLanguage language;
  final List<String> topics;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;
  final double averageRating;

  VideoExplanation({
    required this.videoId,
    required this.questionId,
    required this.title,
    required this.description,
    required this.duration,
    required this.url,
    this.transcript,
    this.thumbnailUrl,
    this.status = VideoStatus.draft,
    this.language = VideoLanguage.japanese,
    this.topics = const [],
    required this.createdAt,
    required this.updatedAt,
    this.viewCount = 0,
    this.averageRating = 0.0,
  });

  factory VideoExplanation.empty() {
    return VideoExplanation(
      videoId: '',
      questionId: '',
      title: '',
      description: '',
      duration: 0,
      url: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory VideoExplanation.fromMap(Map<String, dynamic> map) {
    return VideoExplanation(
      videoId: map['videoId'] as String? ?? '',
      questionId: map['questionId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      duration: map['duration'] as int? ?? 0,
      url: map['url'] as String? ?? '',
      transcript: map['transcript'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      status: VideoStatus.values[map['status'] as int? ?? 0],
      language: VideoLanguage.values[map['language'] as int? ?? 0],
      topics: List<String>.from(map['topics'] as List? ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      viewCount: map['viewCount'] as int? ?? 0,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'videoId': videoId,
      'questionId': questionId,
      'title': title,
      'description': description,
      'duration': duration,
      'url': url,
      'transcript': transcript,
      'thumbnailUrl': thumbnailUrl,
      'status': status.index,
      'language': language.index,
      'topics': topics,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'viewCount': viewCount,
      'averageRating': averageRating,
    };
  }
}

/// Practice test model for tracking test attempts
class PracticeTest {
  final String testId;
  final String userId;
  final String topic;
  final QuestionDifficulty difficulty;
  final List<String> questionIds;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration;
  final int score;
  final double percentage;
  final bool passFail;
  final Map<String, dynamic> answers;
  final Map<String, int> timePerQuestion;
  final TestStatus status;

  PracticeTest({
    required this.testId,
    required this.userId,
    required this.topic,
    required this.difficulty,
    required this.questionIds,
    required this.startTime,
    this.endTime,
    this.duration = 0,
    this.score = 0,
    this.percentage = 0.0,
    this.passFail = false,
    this.answers = const {},
    this.timePerQuestion = const {},
    this.status = TestStatus.inProgress,
  });

  factory PracticeTest.empty() {
    return PracticeTest(
      testId: '',
      userId: '',
      topic: '',
      difficulty: QuestionDifficulty.beginner,
      questionIds: [],
      startTime: DateTime.now(),
    );
  }

  factory PracticeTest.fromMap(Map<String, dynamic> map) {
    return PracticeTest(
      testId: map['testId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      topic: map['topic'] as String? ?? '',
      difficulty: QuestionDifficulty.values[map['difficulty'] as int? ?? 0],
      questionIds: List<String>.from(map['questionIds'] as List? ?? []),
      startTime: (map['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (map['endTime'] as Timestamp?)?.toDate(),
      duration: map['duration'] as int? ?? 0,
      score: map['score'] as int? ?? 0,
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
      passFail: map['passFail'] as bool? ?? false,
      answers: Map<String, dynamic>.from(map['answers'] as Map? ?? {}),
      timePerQuestion: Map<String, int>.from(map['timePerQuestion'] as Map? ?? {}),
      status: TestStatus.values[map['status'] as int? ?? 0],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'testId': testId,
      'userId': userId,
      'topic': topic,
      'difficulty': difficulty.index,
      'questionIds': questionIds,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'duration': duration,
      'score': score,
      'percentage': percentage,
      'passFail': passFail,
      'answers': answers,
      'timePerQuestion': timePerQuestion,
      'status': status.index,
    };
  }
}

/// Mock exam model for full-length simulated exams
class MockExam {
  final String examId;
  final String userId;
  final ExamType examType;
  final int totalQuestions;
  final List<String> questionIds;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration;
  final int score;
  final double percentage;
  final int passingScore;
  final bool isPassed;
  final Map<String, double> topicScores;
  final Map<String, dynamic> answers;
  final TestStatus status;

  MockExam({
    required this.examId,
    required this.userId,
    required this.examType,
    required this.totalQuestions,
    required this.questionIds,
    required this.startTime,
    this.endTime,
    this.duration = 0,
    this.score = 0,
    this.percentage = 0.0,
    this.passingScore = 70,
    this.isPassed = false,
    this.topicScores = const {},
    this.answers = const {},
    this.status = TestStatus.inProgress,
  });

  factory MockExam.empty() {
    return MockExam(
      examId: '',
      userId: '',
      examType: ExamType.fullLength,
      totalQuestions: 0,
      questionIds: [],
      startTime: DateTime.now(),
    );
  }

  factory MockExam.fromMap(Map<String, dynamic> map) {
    return MockExam(
      examId: map['examId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      examType: ExamType.values[map['examType'] as int? ?? 0],
      totalQuestions: map['totalQuestions'] as int? ?? 0,
      questionIds: List<String>.from(map['questionIds'] as List? ?? []),
      startTime: (map['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (map['endTime'] as Timestamp?)?.toDate(),
      duration: map['duration'] as int? ?? 0,
      score: map['score'] as int? ?? 0,
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
      passingScore: map['passingScore'] as int? ?? 70,
      isPassed: map['isPassed'] as bool? ?? false,
      topicScores: Map<String, double>.from((map['topicScores'] as Map? ?? {}).cast<String, double>()),
      answers: Map<String, dynamic>.from(map['answers'] as Map? ?? {}),
      status: TestStatus.values[map['status'] as int? ?? 0],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'examId': examId,
      'userId': userId,
      'examType': examType.index,
      'totalQuestions': totalQuestions,
      'questionIds': questionIds,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'duration': duration,
      'score': score,
      'percentage': percentage,
      'passingScore': passingScore,
      'isPassed': isPassed,
      'topicScores': topicScores,
      'answers': answers,
      'status': status.index,
    };
  }
}

/// Test result model for tracking completed tests
class TestResult {
  final String resultId;
  final String userId;
  final String testId;
  final int score;
  final double percentage;
  final int questions;
  final int correctAnswers;
  final int wrongAnswers;
  final int unanswered;
  final int duration;
  final bool isPassed;
  final Map<String, double> topicScores;
  final DateTime createdAt;
  final String? reportUrl;

  TestResult({
    required this.resultId,
    required this.userId,
    required this.testId,
    required this.score,
    required this.percentage,
    required this.questions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.unanswered,
    required this.duration,
    required this.isPassed,
    this.topicScores = const {},
    required this.createdAt,
    this.reportUrl,
  });

  factory TestResult.empty() {
    return TestResult(
      resultId: '',
      userId: '',
      testId: '',
      score: 0,
      percentage: 0.0,
      questions: 0,
      correctAnswers: 0,
      wrongAnswers: 0,
      unanswered: 0,
      duration: 0,
      isPassed: false,
      createdAt: DateTime.now(),
    );
  }

  factory TestResult.fromMap(Map<String, dynamic> map) {
    return TestResult(
      resultId: map['resultId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      testId: map['testId'] as String? ?? '',
      score: map['score'] as int? ?? 0,
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
      questions: map['questions'] as int? ?? 0,
      correctAnswers: map['correctAnswers'] as int? ?? 0,
      wrongAnswers: map['wrongAnswers'] as int? ?? 0,
      unanswered: map['unanswered'] as int? ?? 0,
      duration: map['duration'] as int? ?? 0,
      isPassed: map['isPassed'] as bool? ?? false,
      topicScores: Map<String, double>.from((map['topicScores'] as Map? ?? {}).cast<String, double>()),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reportUrl: map['reportUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'resultId': resultId,
      'userId': userId,
      'testId': testId,
      'score': score,
      'percentage': percentage,
      'questions': questions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'unanswered': unanswered,
      'duration': duration,
      'isPassed': isPassed,
      'topicScores': topicScores,
      'createdAt': Timestamp.fromDate(createdAt),
      'reportUrl': reportUrl,
    };
  }
}

/// Study plan model for personalized learning paths
class StudyPlan {
  final String planId;
  final String userId;
  final DateTime createdAt;
  final List<String> topics;
  final Map<String, int> priority;
  final List<String> recommendedTests;
  final double estimatedHours;
  final DateTime? deadline;

  StudyPlan({
    required this.planId,
    required this.userId,
    required this.createdAt,
    required this.topics,
    this.priority = const {},
    this.recommendedTests = const [],
    this.estimatedHours = 0.0,
    this.deadline,
  });

  factory StudyPlan.empty() {
    return StudyPlan(
      planId: '',
      userId: '',
      createdAt: DateTime.now(),
      topics: [],
    );
  }

  factory StudyPlan.fromMap(Map<String, dynamic> map) {
    return StudyPlan(
      planId: map['planId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      topics: List<String>.from(map['topics'] as List? ?? []),
      priority: Map<String, int>.from((map['priority'] as Map? ?? {}).cast<String, int>()),
      recommendedTests: List<String>.from(map['recommendedTests'] as List? ?? []),
      estimatedHours: (map['estimatedHours'] as num?)?.toDouble() ?? 0.0,
      deadline: (map['deadline'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'planId': planId,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'topics': topics,
      'priority': priority,
      'recommendedTests': recommendedTests,
      'estimatedHours': estimatedHours,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
    };
  }
}

/// Learning progress tracker for each category/分野
class ProgressTracker {
  final String trackerId;
  final String userId;
  final String category; // e.g., '交通規則', '危機回避', '機械知識'
  final int correctCount;
  final int totalAttempts;
  final int minutesSpent;
  final DateTime lastStudiedAt;
  final List<int> lastFiveScores; // [70, 80, 75, 85, 90]
  final int consecutiveCorrect;
  final int longestStreak;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProgressTracker({
    required this.trackerId,
    required this.userId,
    required this.category,
    required this.correctCount,
    required this.totalAttempts,
    required this.minutesSpent,
    required this.lastStudiedAt,
    this.lastFiveScores = const [],
    this.consecutiveCorrect = 0,
    this.longestStreak = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 正答率を計算（0.0～1.0）
  double get accuracyRate =>
      totalAttempts > 0 ? correctCount / totalAttempts : 0.0;

  /// 正答率をパーセンテージで取得
  int get accuracyPercentage => (accuracyRate * 100).toInt();

  /// 平均回答時間（秒）
  double get averageTimePerQuestion =>
      totalAttempts > 0 ? (minutesSpent * 60) / totalAttempts : 0.0;

  /// 推奨学習時間（分）
  int get recommendedStudyMinutes {
    if (accuracyPercentage >= 85) return 0;
    final gap = 85 - accuracyPercentage;
    return (gap * 0.5).toInt().clamp(15, 120);
  }

  factory ProgressTracker.empty({
    required String trackerId,
    required String userId,
    required String category,
  }) {
    return ProgressTracker(
      trackerId: trackerId,
      userId: userId,
      category: category,
      correctCount: 0,
      totalAttempts: 0,
      minutesSpent: 0,
      lastStudiedAt: DateTime.now(),
      lastFiveScores: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory ProgressTracker.fromMap(Map<String, dynamic> map) {
    return ProgressTracker(
      trackerId: map['trackerId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      category: map['category'] as String? ?? '',
      correctCount: map['correctCount'] as int? ?? 0,
      totalAttempts: map['totalAttempts'] as int? ?? 0,
      minutesSpent: map['minutesSpent'] as int? ?? 0,
      lastStudiedAt: (map['lastStudiedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastFiveScores: List<int>.from(map['lastFiveScores'] as List? ?? []),
      consecutiveCorrect: map['consecutiveCorrect'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trackerId': trackerId,
      'userId': userId,
      'category': category,
      'correctCount': correctCount,
      'totalAttempts': totalAttempts,
      'minutesSpent': minutesSpent,
      'lastStudiedAt': Timestamp.fromDate(lastStudiedAt),
      'lastFiveScores': lastFiveScores,
      'consecutiveCorrect': consecutiveCorrect,
      'longestStreak': longestStreak,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// Weak area detection for prioritized learning
class WeakArea {
  final String weakAreaId;
  final String userId;
  final String category; // e.g., '危機回避'
  final int currentAccuracy; // 58%
  final int targetAccuracy; // 85%
  final int attemptCount; // how many times attempted
  final int priorityScore; // 0-100, higher = more urgent
  final String priority; // '最優先', '重要', '進捗中'
  final int estimatedMinutesNeeded; // to reach target
  final List<String> suggestedTopics; // specific topics to focus on
  final DateTime identifiedAt;
  final DateTime? targetCompletionDate;
  final bool isResolved; // whether this weak area has been addressed

  WeakArea({
    required this.weakAreaId,
    required this.userId,
    required this.category,
    required this.currentAccuracy,
    required this.targetAccuracy,
    required this.attemptCount,
    required this.priorityScore,
    required this.priority,
    required this.estimatedMinutesNeeded,
    required this.suggestedTopics,
    required this.identifiedAt,
    this.targetCompletionDate,
    this.isResolved = false,
  });

  /// 目標までの差分
  int get accuracyGap => targetAccuracy - currentAccuracy;

  /// 改善率（何パーセント改善が必要か）
  double get improvementPercentage {
    if (currentAccuracy >= targetAccuracy) return 0.0;
    return ((targetAccuracy - currentAccuracy) / 100.0) * 100;
  }

  /// 優先度バッジ用の色
  String get priorityBadgeColor {
    switch (priority) {
      case '最優先':
        return '#FF6A00'; // burnt orange
      case '重要':
        return '#FFA726'; // light orange
      case '進捗中':
        return '#4CAF50'; // green
      default:
        return '#1B2A4A'; // navy
    }
  }

  factory WeakArea.empty({
    required String weakAreaId,
    required String userId,
    required String category,
  }) {
    return WeakArea(
      weakAreaId: weakAreaId,
      userId: userId,
      category: category,
      currentAccuracy: 0,
      targetAccuracy: 85,
      attemptCount: 0,
      priorityScore: 0,
      priority: '進捗中',
      estimatedMinutesNeeded: 0,
      suggestedTopics: [],
      identifiedAt: DateTime.now(),
    );
  }

  factory WeakArea.fromMap(Map<String, dynamic> map) {
    return WeakArea(
      weakAreaId: map['weakAreaId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      category: map['category'] as String? ?? '',
      currentAccuracy: map['currentAccuracy'] as int? ?? 0,
      targetAccuracy: map['targetAccuracy'] as int? ?? 85,
      attemptCount: map['attemptCount'] as int? ?? 0,
      priorityScore: map['priorityScore'] as int? ?? 0,
      priority: map['priority'] as String? ?? '進捗中',
      estimatedMinutesNeeded: map['estimatedMinutesNeeded'] as int? ?? 0,
      suggestedTopics: List<String>.from(map['suggestedTopics'] as List? ?? []),
      identifiedAt: (map['identifiedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      targetCompletionDate: (map['targetCompletionDate'] as Timestamp?)?.toDate(),
      isResolved: map['isResolved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weakAreaId': weakAreaId,
      'userId': userId,
      'category': category,
      'currentAccuracy': currentAccuracy,
      'targetAccuracy': targetAccuracy,
      'attemptCount': attemptCount,
      'priorityScore': priorityScore,
      'priority': priority,
      'estimatedMinutesNeeded': estimatedMinutesNeeded,
      'suggestedTopics': suggestedTopics,
      'identifiedAt': Timestamp.fromDate(identifiedAt),
      'targetCompletionDate': targetCompletionDate != null
          ? Timestamp.fromDate(targetCompletionDate!)
          : null,
      'isResolved': isResolved,
    };
  }
}

/// Review schedule for spaced repetition learning
class ReviewScheduleItem {
  final String reviewId;
  final String userId;
  final List<String> questionIds;
  final DateTime scheduledFor; // tomorrow, 3 days, 1 week
  final String interval; // '明日', '3日後', '1週間後'
  final int questionCount;
  final bool isCompleted;
  final DateTime? completedAt;
  final int estimatedMinutes; // 予想学習時間

  ReviewScheduleItem({
    required this.reviewId,
    required this.userId,
    required this.questionIds,
    required this.scheduledFor,
    required this.interval,
    required this.questionCount,
    this.isCompleted = false,
    this.completedAt,
    required this.estimatedMinutes,
  });

  /// 次の復習までの日数
  int get daysUntilReview {
    final now = DateTime.now();
    return scheduledFor.difference(now).inDays;
  }

  /// 復習を実施したかどうか
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(scheduledFor);

  factory ReviewScheduleItem.empty({
    required String reviewId,
    required String userId,
  }) {
    return ReviewScheduleItem(
      reviewId: reviewId,
      userId: userId,
      questionIds: [],
      scheduledFor: DateTime.now(),
      interval: '明日',
      questionCount: 0,
      estimatedMinutes: 0,
    );
  }

  factory ReviewScheduleItem.fromMap(Map<String, dynamic> map) {
    return ReviewScheduleItem(
      reviewId: map['reviewId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      questionIds: List<String>.from(map['questionIds'] as List? ?? []),
      scheduledFor: (map['scheduledFor'] as Timestamp?)?.toDate() ?? DateTime.now(),
      interval: map['interval'] as String? ?? '明日',
      questionCount: map['questionCount'] as int? ?? 0,
      isCompleted: map['isCompleted'] as bool? ?? false,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      estimatedMinutes: map['estimatedMinutes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      'questionIds': questionIds,
      'scheduledFor': Timestamp.fromDate(scheduledFor),
      'interval': interval,
      'questionCount': questionCount,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'estimatedMinutes': estimatedMinutes,
    };
  }
}

/// Exam readiness prediction with pass probability
class ExamReadinessPrediction {
  final String predictionId;
  final String userId;
  final double passProbability; // 0.0～1.0 (68%)
  final int estimatedHoursNeeded; // 12時間
  final DateTime predictedReadyDate; // 目標達成日
  final List<String> criticalWeakAreas; // 最重要分野
  final List<String> recommendedFocusTopics; // 集中学習トピック
  final ReadinessFactors factors;
  final DateTime calculatedAt;
  final DateTime updatedAt;

  ExamReadinessPrediction({
    required this.predictionId,
    required this.userId,
    required this.passProbability,
    required this.estimatedHoursNeeded,
    required this.predictedReadyDate,
    required this.criticalWeakAreas,
    required this.recommendedFocusTopics,
    required this.factors,
    required this.calculatedAt,
    required this.updatedAt,
  });

  /// 合格ラインに達しているか
  bool get isPassReady => passProbability >= 0.85;

  /// 合格までの日数
  int get daysToReady {
    final now = DateTime.now();
    return predictedReadyDate.difference(now).inDays.clamp(0, 999);
  }

  /// 分野ごとの準備度（0～100）
  int get readinessPercentage => (passProbability * 100).toInt();

  /// 学習推奨度：高=True, 低=False
  bool get needsActiveLearning => !isPassReady && daysToReady <= 7;

  factory ExamReadinessPrediction.empty({
    required String predictionId,
    required String userId,
  }) {
    return ExamReadinessPrediction(
      predictionId: predictionId,
      userId: userId,
      passProbability: 0.0,
      estimatedHoursNeeded: 0,
      predictedReadyDate: DateTime.now(),
      criticalWeakAreas: [],
      recommendedFocusTopics: [],
      factors: ReadinessFactors.empty(),
      calculatedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory ExamReadinessPrediction.fromMap(Map<String, dynamic> map) {
    return ExamReadinessPrediction(
      predictionId: map['predictionId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      passProbability: (map['passProbability'] as num?)?.toDouble() ?? 0.0,
      estimatedHoursNeeded: map['estimatedHoursNeeded'] as int? ?? 0,
      predictedReadyDate: (map['predictedReadyDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      criticalWeakAreas: List<String>.from(map['criticalWeakAreas'] as List? ?? []),
      recommendedFocusTopics: List<String>.from(map['recommendedFocusTopics'] as List? ?? []),
      factors: ReadinessFactors.fromMap(map['factors'] as Map<String, dynamic>? ?? {}),
      calculatedAt: (map['calculatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'predictionId': predictionId,
      'userId': userId,
      'passProbability': passProbability,
      'estimatedHoursNeeded': estimatedHoursNeeded,
      'predictedReadyDate': Timestamp.fromDate(predictedReadyDate),
      'criticalWeakAreas': criticalWeakAreas,
      'recommendedFocusTopics': recommendedFocusTopics,
      'factors': factors.toMap(),
      'calculatedAt': Timestamp.fromDate(calculatedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// Readiness factors breakdown
class ReadinessFactors {
  final double accuracyWeighting; // 正答率の重み付け（0～1）
  final double consistencyScore; // 一貫性スコア（連続正解率）
  final double trendScore; // トレンドスコア（改善傾向）
  final double timeSpentScore; // 学習時間スコア
  final double weakAreaCoverageScore; // 弱点分野カバー率

  /// 複合スコア（全要素の平均）
  double get compositeScore {
    final scores = [
      accuracyWeighting,
      consistencyScore,
      trendScore,
      timeSpentScore,
      weakAreaCoverageScore,
    ];
    return scores.fold(0.0, (a, b) => a + b) / scores.length;
  }

  ReadinessFactors({
    required this.accuracyWeighting,
    required this.consistencyScore,
    required this.trendScore,
    required this.timeSpentScore,
    required this.weakAreaCoverageScore,
  });

  factory ReadinessFactors.empty() {
    return ReadinessFactors(
      accuracyWeighting: 0.0,
      consistencyScore: 0.0,
      trendScore: 0.0,
      timeSpentScore: 0.0,
      weakAreaCoverageScore: 0.0,
    );
  }

  factory ReadinessFactors.fromMap(Map<String, dynamic> map) {
    return ReadinessFactors(
      accuracyWeighting: (map['accuracyWeighting'] as num?)?.toDouble() ?? 0.0,
      consistencyScore: (map['consistencyScore'] as num?)?.toDouble() ?? 0.0,
      trendScore: (map['trendScore'] as num?)?.toDouble() ?? 0.0,
      timeSpentScore: (map['timeSpentScore'] as num?)?.toDouble() ?? 0.0,
      weakAreaCoverageScore: (map['weakAreaCoverageScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accuracyWeighting': accuracyWeighting,
      'consistencyScore': consistencyScore,
      'trendScore': trendScore,
      'timeSpentScore': timeSpentScore,
      'weakAreaCoverageScore': weakAreaCoverageScore,
    };
  }
}

/// Time-to-readiness estimation
class TimeToReadiness {
  final String estimateId;
  final String userId;
  final String category; // e.g., '全体', '交通規則'
  final int daysToTargetAccuracy; // 目標正答率に達するまでの日数
  final int recommendedDailyMinutes; // 1日あたりの推奨学習時間
  final int totalHoursNeeded; // 全体で必要な時間
  final DateTime estimatedCompletionDate; // 目標達成予定日
  final List<String> milestones; // マイルストーン（70% → 80% → 90%）
  final String confidenceLevel; // 'high', 'medium', 'low'
  final DateTime calculatedAt;

  TimeToReadiness({
    required this.estimateId,
    required this.userId,
    required this.category,
    required this.daysToTargetAccuracy,
    required this.recommendedDailyMinutes,
    required this.totalHoursNeeded,
    required this.estimatedCompletionDate,
    required this.milestones,
    required this.confidenceLevel,
    required this.calculatedAt,
  });

  /// 1日の学習で達成できる進捗
  double get progressPerDay => recommendedDailyMinutes > 0 ? 1.0 / daysToTargetAccuracy : 0.0;

  /// 現在のペースで達成可能か
  bool get isAchievableAtCurrentPace => daysToTargetAccuracy <= 30;

  factory TimeToReadiness.empty({
    required String estimateId,
    required String userId,
    required String category,
  }) {
    return TimeToReadiness(
      estimateId: estimateId,
      userId: userId,
      category: category,
      daysToTargetAccuracy: 0,
      recommendedDailyMinutes: 0,
      totalHoursNeeded: 0,
      estimatedCompletionDate: DateTime.now(),
      milestones: [],
      confidenceLevel: 'low',
      calculatedAt: DateTime.now(),
    );
  }

  factory TimeToReadiness.fromMap(Map<String, dynamic> map) {
    return TimeToReadiness(
      estimateId: map['estimateId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      category: map['category'] as String? ?? '',
      daysToTargetAccuracy: map['daysToTargetAccuracy'] as int? ?? 0,
      recommendedDailyMinutes: map['recommendedDailyMinutes'] as int? ?? 0,
      totalHoursNeeded: map['totalHoursNeeded'] as int? ?? 0,
      estimatedCompletionDate: (map['estimatedCompletionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      milestones: List<String>.from(map['milestones'] as List? ?? []),
      confidenceLevel: map['confidenceLevel'] as String? ?? 'low',
      calculatedAt: (map['calculatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'estimateId': estimateId,
      'userId': userId,
      'category': category,
      'daysToTargetAccuracy': daysToTargetAccuracy,
      'recommendedDailyMinutes': recommendedDailyMinutes,
      'totalHoursNeeded': totalHoursNeeded,
      'estimatedCompletionDate': Timestamp.fromDate(estimatedCompletionDate),
      'milestones': milestones,
      'confidenceLevel': confidenceLevel,
      'calculatedAt': Timestamp.fromDate(calculatedAt),
    };
  }
}

/// Achievement badge earned by user
class AchievementBadge {
  final String badgeId;
  final String userId;
  final BadgeType type;
  final String displayName; // e.g., '三連勝達成'
  final String description; // e.g., '3日連続で学習した'
  final String iconUrl; // badge emoji or image
  final BadgeRarityLevel rarity;
  final int points; // XP reward
  final DateTime earnedAt;
  final int level; // 1-5 for progressive badges
  final bool isPinned; // Featured on profile

  AchievementBadge({
    required this.badgeId,
    required this.userId,
    required this.type,
    required this.displayName,
    required this.description,
    required this.iconUrl,
    required this.rarity,
    required this.points,
    required this.earnedAt,
    this.level = 1,
    this.isPinned = false,
  });

  /// バッジの希少性に基づくポイント計算
  int get rarityMultiplier {
    switch (rarity) {
      case BadgeRarityLevel.common:
        return 1;
      case BadgeRarityLevel.uncommon:
        return 2;
      case BadgeRarityLevel.rare:
        return 3;
      case BadgeRarityLevel.epic:
        return 5;
      case BadgeRarityLevel.legendary:
        return 10;
    }
  }

  /// バッジの年齢（日数）
  int get ageInDays {
    return DateTime.now().difference(earnedAt).inDays;
  }

  factory AchievementBadge.empty({
    required String badgeId,
    required String userId,
  }) {
    return AchievementBadge(
      badgeId: badgeId,
      userId: userId,
      type: BadgeType.firstQuestion,
      displayName: '',
      description: '',
      iconUrl: '🏅',
      rarity: BadgeRarityLevel.common,
      points: 0,
      earnedAt: DateTime.now(),
    );
  }

  factory AchievementBadge.fromMap(Map<String, dynamic> map) {
    return AchievementBadge(
      badgeId: map['badgeId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      type: _parseBadgeType(map['type'] as String? ?? 'firstQuestion'),
      displayName: map['displayName'] as String? ?? '',
      description: map['description'] as String? ?? '',
      iconUrl: map['iconUrl'] as String? ?? '🏅',
      rarity: _parseBadgeRarity(map['rarity'] as String? ?? 'common'),
      points: map['points'] as int? ?? 0,
      earnedAt: (map['earnedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      level: map['level'] as int? ?? 1,
      isPinned: map['isPinned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'badgeId': badgeId,
      'userId': userId,
      'type': type.toString(),
      'displayName': displayName,
      'description': description,
      'iconUrl': iconUrl,
      'rarity': rarity.toString(),
      'points': points,
      'earnedAt': Timestamp.fromDate(earnedAt),
      'level': level,
      'isPinned': isPinned,
    };
  }
}

/// Study streak tracker
class StudyStreak {
  final String streakId;
  final String userId;
  final int currentStreak; // current consecutive days
  final int longestStreak; // personal best
  final DateTime lastStudyDate;
  final List<DateTime> studyDates; // recent study dates
  final int totalDaysStudied; // lifetime
  final DateTime createdAt;
  final DateTime updatedAt;

  StudyStreak({
    required this.streakId,
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastStudyDate,
    this.studyDates = const [],
    required this.totalDaysStudied,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ストリークが有効か（昨日または今日）
  bool get isActive {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return lastStudyDate.isAfter(yesterday);
  }

  /// ストリークが途切れるまでの日数
  int get daysUntilBroken {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return tomorrow.difference(lastStudyDate).inDays;
  }

  factory StudyStreak.empty({
    required String streakId,
    required String userId,
  }) {
    return StudyStreak(
      streakId: streakId,
      userId: userId,
      currentStreak: 0,
      longestStreak: 0,
      lastStudyDate: DateTime.now(),
      studyDates: [],
      totalDaysStudied: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory StudyStreak.fromMap(Map<String, dynamic> map) {
    return StudyStreak(
      streakId: map['streakId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      lastStudyDate: (map['lastStudyDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      studyDates: (map['studyDates'] as List?)
              ?.map((d) => (d as Timestamp).toDate())
              .toList() ??
          [],
      totalDaysStudied: map['totalDaysStudied'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'streakId': streakId,
      'userId': userId,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastStudyDate': Timestamp.fromDate(lastStudyDate),
      'studyDates': studyDates.map((d) => Timestamp.fromDate(d)).toList(),
      'totalDaysStudied': totalDaysStudied,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// User achievement statistics
class AchievementStats {
  final String statsId;
  final String userId;
  final int totalBadgesEarned;
  final int totalPoints; // XP
  final int totalLevel; // 1-100
  final List<AchievementBadge> badges;
  final StudyStreak currentStreak;
  final int perfectScoreSessions; // 100% accuracy tests
  final int fastestTimeRecord; // seconds for all questions
  final DateTime createdAt;
  final DateTime updatedAt;

  AchievementStats({
    required this.statsId,
    required this.userId,
    required this.totalBadgesEarned,
    required this.totalPoints,
    required this.totalLevel,
    required this.badges,
    required this.currentStreak,
    required this.perfectScoreSessions,
    required this.fastestTimeRecord,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 次のレベルアップまでのポイント
  int get pointsToNextLevel {
    final nextLevelThreshold = totalLevel * 1000;
    return nextLevelThreshold - totalPoints;
  }

  /// レベルアップの進捗（%）
  int get levelUpProgress {
    final currentLevelThreshold = (totalLevel - 1) * 1000;
    final nextLevelThreshold = totalLevel * 1000;
    final progress = totalPoints - currentLevelThreshold;
    final needed = nextLevelThreshold - currentLevelThreshold;
    return needed > 0 ? ((progress / needed) * 100).toInt().clamp(0, 100) : 100;
  }

  factory AchievementStats.empty({
    required String statsId,
    required String userId,
  }) {
    return AchievementStats(
      statsId: statsId,
      userId: userId,
      totalBadgesEarned: 0,
      totalPoints: 0,
      totalLevel: 1,
      badges: [],
      currentStreak: StudyStreak.empty(streakId: 'ss_$userId', userId: userId),
      perfectScoreSessions: 0,
      fastestTimeRecord: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory AchievementStats.fromMap(Map<String, dynamic> map) {
    return AchievementStats(
      statsId: map['statsId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      totalBadgesEarned: map['totalBadgesEarned'] as int? ?? 0,
      totalPoints: map['totalPoints'] as int? ?? 0,
      totalLevel: map['totalLevel'] as int? ?? 1,
      badges: (map['badges'] as List?)
              ?.map((b) => AchievementBadge.fromMap(b as Map<String, dynamic>))
              .toList() ??
          [],
      currentStreak: StudyStreak.fromMap(
        map['currentStreak'] as Map<String, dynamic>? ?? {},
      ),
      perfectScoreSessions: map['perfectScoreSessions'] as int? ?? 0,
      fastestTimeRecord: map['fastestTimeRecord'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'statsId': statsId,
      'userId': userId,
      'totalBadgesEarned': totalBadgesEarned,
      'totalPoints': totalPoints,
      'totalLevel': totalLevel,
      'badges': badges.map((b) => b.toMap()).toList(),
      'currentStreak': currentStreak.toMap(),
      'perfectScoreSessions': perfectScoreSessions,
      'fastestTimeRecord': fastestTimeRecord,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// XP reward multiplier based on conditions
class RewardMultiplier {
  final String multiplierId;
  final String userId;
  final double baseMultiplier; // 1.0 = 100%
  final List<String> activeBoosts; // e.g., ['streak_3x', 'time_bonus']
  final DateTime activatedAt;
  final DateTime? expiresAt;
  final String reason; // why this multiplier is active

  RewardMultiplier({
    required this.multiplierId,
    required this.userId,
    required this.baseMultiplier,
    required this.activeBoosts,
    required this.activatedAt,
    this.expiresAt,
    required this.reason,
  });

  /// マルチプライヤーが有効か
  bool get isActive {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// 実際のマルチプライヤー値（全ブーストを適用）
  double get effectiveMultiplier {
    if (!isActive) return 1.0;
    double multiplier = baseMultiplier;
    for (final boost in activeBoosts) {
      if (boost.contains('streak')) multiplier *= 1.5;
      if (boost.contains('time_bonus')) multiplier *= 1.2;
      if (boost.contains('accuracy')) multiplier *= 1.1;
    }
    return multiplier;
  }

  factory RewardMultiplier.empty({
    required String multiplierId,
    required String userId,
  }) {
    return RewardMultiplier(
      multiplierId: multiplierId,
      userId: userId,
      baseMultiplier: 1.0,
      activeBoosts: [],
      activatedAt: DateTime.now(),
      reason: 'none',
    );
  }

  factory RewardMultiplier.fromMap(Map<String, dynamic> map) {
    return RewardMultiplier(
      multiplierId: map['multiplierId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      baseMultiplier: (map['baseMultiplier'] as num?)?.toDouble() ?? 1.0,
      activeBoosts: List<String>.from(map['activeBoosts'] as List? ?? []),
      activatedAt: (map['activatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      reason: map['reason'] as String? ?? 'none',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'multiplierId': multiplierId,
      'userId': userId,
      'baseMultiplier': baseMultiplier,
      'activeBoosts': activeBoosts,
      'activatedAt': Timestamp.fromDate(activatedAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'reason': reason,
    };
  }
}

/// B2B Partnership with driving school
class PartnershipAgreement {
  final String partnershipId;
  final String schoolId;
  final String schoolName;
  final String contactEmail;
  final PartnershipStatus status; // pending, active, suspended
  final PartnershipTier tier; // starter, professional, enterprise
  final int maxStudents; // license limit
  final int currentStudents; // enrolled count
  final DateTime startDate;
  final DateTime expiryDate;
  final int annualCostJPY; // 年間費用
  final bool isCustomBrandingAllowed;
  final bool isPrivateContentAllowed;
  final List<String> authorizedInstructors;
  final DateTime createdAt;
  final DateTime updatedAt;

  PartnershipAgreement({
    required this.partnershipId,
    required this.schoolId,
    required this.schoolName,
    required this.contactEmail,
    required this.status,
    required this.tier,
    required this.maxStudents,
    required this.currentStudents,
    required this.startDate,
    required this.expiryDate,
    required this.annualCostJPY,
    required this.isCustomBrandingAllowed,
    required this.isPrivateContentAllowed,
    required this.authorizedInstructors,
    required this.createdAt,
    required this.updatedAt,
  });

  /// パートナーシップが有効か
  bool get isActive => status == PartnershipStatus.active && DateTime.now().isBefore(expiryDate);

  /// ライセンス余裕度
  int get remainingSeats => maxStudents - currentStudents;

  /// ライセンス利用率
  int get utilizationPercent => (currentStudents / maxStudents * 100).toInt();

  /// 更新予定日
  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  factory PartnershipAgreement.empty({
    required String partnershipId,
    required String schoolId,
  }) {
    return PartnershipAgreement(
      partnershipId: partnershipId,
      schoolId: schoolId,
      schoolName: '',
      contactEmail: '',
      status: PartnershipStatus.pending,
      tier: PartnershipTier.starter,
      maxStudents: 0,
      currentStudents: 0,
      startDate: DateTime.now(),
      expiryDate: DateTime.now().add(Duration(days: 365)),
      annualCostJPY: 0,
      isCustomBrandingAllowed: false,
      isPrivateContentAllowed: false,
      authorizedInstructors: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory PartnershipAgreement.fromMap(Map<String, dynamic> map) {
    return PartnershipAgreement(
      partnershipId: map['partnershipId'] as String? ?? '',
      schoolId: map['schoolId'] as String? ?? '',
      schoolName: map['schoolName'] as String? ?? '',
      contactEmail: map['contactEmail'] as String? ?? '',
      status: _parsePartnershipStatus(map['status'] as String? ?? 'pending'),
      tier: _parsePartnershipTier(map['tier'] as String? ?? 'starter'),
      maxStudents: map['maxStudents'] as int? ?? 0,
      currentStudents: map['currentStudents'] as int? ?? 0,
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiryDate: (map['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      annualCostJPY: map['annualCostJPY'] as int? ?? 0,
      isCustomBrandingAllowed: map['isCustomBrandingAllowed'] as bool? ?? false,
      isPrivateContentAllowed: map['isPrivateContentAllowed'] as bool? ?? false,
      authorizedInstructors: List<String>.from(map['authorizedInstructors'] as List? ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'partnershipId': partnershipId,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'contactEmail': contactEmail,
      'status': status.toString(),
      'tier': tier.toString(),
      'maxStudents': maxStudents,
      'currentStudents': currentStudents,
      'startDate': Timestamp.fromDate(startDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'annualCostJPY': annualCostJPY,
      'isCustomBrandingAllowed': isCustomBrandingAllowed,
      'isPrivateContentAllowed': isPrivateContentAllowed,
      'authorizedInstructors': authorizedInstructors,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// Institutional user license
class InstitutionalLicense {
  final String licenseId;
  final String partnershipId;
  final String userId;
  final String userName;
  final LicenseType type; // student, instructor, admin
  final DateTime issuedAt;
  final DateTime expiresAt;
  final bool isActive;
  final int loginCount;
  final DateTime? lastLoginAt;
  final Map<String, dynamic> permissions; // custom permissions

  InstitutionalLicense({
    required this.licenseId,
    required this.partnershipId,
    required this.userId,
    required this.userName,
    required this.type,
    required this.issuedAt,
    required this.expiresAt,
    required this.isActive,
    required this.loginCount,
    this.lastLoginAt,
    required this.permissions,
  });

  /// ライセンスが有効か
  bool get isLicenseValid => isActive && DateTime.now().isBefore(expiresAt);

  /// ライセンス有効期間（日数）
  int get daysUntilExpiry => expiresAt.difference(DateTime.now()).inDays;

  factory InstitutionalLicense.empty({
    required String licenseId,
    required String partnershipId,
    required String userId,
  }) {
    return InstitutionalLicense(
      licenseId: licenseId,
      partnershipId: partnershipId,
      userId: userId,
      userName: '',
      type: LicenseType.studentAccess,
      issuedAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: 365)),
      isActive: true,
      loginCount: 0,
      permissions: {},
    );
  }

  factory InstitutionalLicense.fromMap(Map<String, dynamic> map) {
    return InstitutionalLicense(
      licenseId: map['licenseId'] as String? ?? '',
      partnershipId: map['partnershipId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      type: _parseLicenseType(map['type'] as String? ?? 'studentAccess'),
      issuedAt: (map['issuedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] as bool? ?? true,
      loginCount: map['loginCount'] as int? ?? 0,
      lastLoginAt: (map['lastLoginAt'] as Timestamp?)?.toDate(),
      permissions: map['permissions'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'licenseId': licenseId,
      'partnershipId': partnershipId,
      'userId': userId,
      'userName': userName,
      'type': type.toString(),
      'issuedAt': Timestamp.fromDate(issuedAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isActive': isActive,
      'loginCount': loginCount,
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'permissions': permissions,
    };
  }
}

/// B2B Analytics dashboard
class InstitutionalAnalytics {
  final String analyticsId;
  final String partnershipId;
  final int totalStudentsEnrolled;
  final int activeStudents; // studied in last 7 days
  final double averageCompletionRate; // 0.0～1.0
  final double averageExamReadiness; // 0.0～1.0
  final int totalQuestionsAnswered;
  final int averageHoursPerStudent;
  final List<String> topPerformingStudents; // user IDs
  final Map<String, int> categoryPerformance; // category → avg accuracy
  final DateTime startDate;
  final DateTime endDate;
  final DateTime generatedAt;

  InstitutionalAnalytics({
    required this.analyticsId,
    required this.partnershipId,
    required this.totalStudentsEnrolled,
    required this.activeStudents,
    required this.averageCompletionRate,
    required this.averageExamReadiness,
    required this.totalQuestionsAnswered,
    required this.averageHoursPerStudent,
    required this.topPerformingStudents,
    required this.categoryPerformance,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
  });

  /// 学生の活動率（%）
  int get studentActivityPercentage {
    return totalStudentsEnrolled > 0
        ? ((activeStudents / totalStudentsEnrolled) * 100).toInt()
        : 0;
  }

  /// 平均合格可能性（%）
  int get averagePassProbability => (averageExamReadiness * 100).toInt();

  factory InstitutionalAnalytics.empty({
    required String analyticsId,
    required String partnershipId,
  }) {
    return InstitutionalAnalytics(
      analyticsId: analyticsId,
      partnershipId: partnershipId,
      totalStudentsEnrolled: 0,
      activeStudents: 0,
      averageCompletionRate: 0.0,
      averageExamReadiness: 0.0,
      totalQuestionsAnswered: 0,
      averageHoursPerStudent: 0,
      topPerformingStudents: [],
      categoryPerformance: {},
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      generatedAt: DateTime.now(),
    );
  }

  factory InstitutionalAnalytics.fromMap(Map<String, dynamic> map) {
    return InstitutionalAnalytics(
      analyticsId: map['analyticsId'] as String? ?? '',
      partnershipId: map['partnershipId'] as String? ?? '',
      totalStudentsEnrolled: map['totalStudentsEnrolled'] as int? ?? 0,
      activeStudents: map['activeStudents'] as int? ?? 0,
      averageCompletionRate: (map['averageCompletionRate'] as num?)?.toDouble() ?? 0.0,
      averageExamReadiness: (map['averageExamReadiness'] as num?)?.toDouble() ?? 0.0,
      totalQuestionsAnswered: map['totalQuestionsAnswered'] as int? ?? 0,
      averageHoursPerStudent: map['averageHoursPerStudent'] as int? ?? 0,
      topPerformingStudents: List<String>.from(map['topPerformingStudents'] as List? ?? []),
      categoryPerformance: Map<String, int>.from((map['categoryPerformance'] as Map? ?? {}).cast<String, int>()),
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      generatedAt: (map['generatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'analyticsId': analyticsId,
      'partnershipId': partnershipId,
      'totalStudentsEnrolled': totalStudentsEnrolled,
      'activeStudents': activeStudents,
      'averageCompletionRate': averageCompletionRate,
      'averageExamReadiness': averageExamReadiness,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'averageHoursPerStudent': averageHoursPerStudent,
      'topPerformingStudents': topPerformingStudents,
      'categoryPerformance': categoryPerformance,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'generatedAt': Timestamp.fromDate(generatedAt),
    };
  }
}

/// Billing and usage tracking
class PartnershipBilling {
  final String billingId;
  final String partnershipId;
  final int basePlanCostJPY;
  final int additionalSeatsJPY; // per student
  final int totalStudentsInBillingPeriod;
  final int totalCostJPY;
  final DateTime billingPeriodStart;
  final DateTime billingPeriodEnd;
  final bool isPaid;
  final DateTime? paidAt;
  final String invoiceUrl;

  PartnershipBilling({
    required this.billingId,
    required this.partnershipId,
    required this.basePlanCostJPY,
    required this.additionalSeatsJPY,
    required this.totalStudentsInBillingPeriod,
    required this.totalCostJPY,
    required this.billingPeriodStart,
    required this.billingPeriodEnd,
    required this.isPaid,
    this.paidAt,
    required this.invoiceUrl,
  });

  factory PartnershipBilling.empty({
    required String billingId,
    required String partnershipId,
  }) {
    return PartnershipBilling(
      billingId: billingId,
      partnershipId: partnershipId,
      basePlanCostJPY: 0,
      additionalSeatsJPY: 0,
      totalStudentsInBillingPeriod: 0,
      totalCostJPY: 0,
      billingPeriodStart: DateTime.now(),
      billingPeriodEnd: DateTime.now().add(Duration(days: 30)),
      isPaid: false,
      invoiceUrl: '',
    );
  }

  factory PartnershipBilling.fromMap(Map<String, dynamic> map) {
    return PartnershipBilling(
      billingId: map['billingId'] as String? ?? '',
      partnershipId: map['partnershipId'] as String? ?? '',
      basePlanCostJPY: map['basePlanCostJPY'] as int? ?? 0,
      additionalSeatsJPY: map['additionalSeatsJPY'] as int? ?? 0,
      totalStudentsInBillingPeriod: map['totalStudentsInBillingPeriod'] as int? ?? 0,
      totalCostJPY: map['totalCostJPY'] as int? ?? 0,
      billingPeriodStart: (map['billingPeriodStart'] as Timestamp?)?.toDate() ?? DateTime.now(),
      billingPeriodEnd: (map['billingPeriodEnd'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPaid: map['isPaid'] as bool? ?? false,
      paidAt: (map['paidAt'] as Timestamp?)?.toDate(),
      invoiceUrl: map['invoiceUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'billingId': billingId,
      'partnershipId': partnershipId,
      'basePlanCostJPY': basePlanCostJPY,
      'additionalSeatsJPY': additionalSeatsJPY,
      'totalStudentsInBillingPeriod': totalStudentsInBillingPeriod,
      'totalCostJPY': totalCostJPY,
      'billingPeriodStart': Timestamp.fromDate(billingPeriodStart),
      'billingPeriodEnd': Timestamp.fromDate(billingPeriodEnd),
      'isPaid': isPaid,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'invoiceUrl': invoiceUrl,
    };
  }
}

// ============ Content Management Models ============

class InstitutionalQuestion {
  final String questionId;
  final String partnershipId;
  final String createdByUserId;
  final String questionText;
  final QuestionType type;
  final QuestionDifficulty difficulty;
  final String category;
  final String? subcategory;
  final List<String> answerOptions;
  final String correctAnswer;
  final String? explanation;
  final List<String>? keywords;
  final ContentStatus status;
  final ContentAccessLevel accessLevel;
  final int usageCount;
  final double averageTimeSpent; // in seconds
  final double averageAccuracy;
  final DateTime? reviewedAt;
  final String? reviewedByUserId;
  final String? reviewNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  InstitutionalQuestion({
    required this.questionId,
    required this.partnershipId,
    required this.createdByUserId,
    required this.questionText,
    required this.type,
    required this.difficulty,
    required this.category,
    this.subcategory,
    required this.answerOptions,
    required this.correctAnswer,
    this.explanation,
    this.keywords,
    required this.status,
    required this.accessLevel,
    this.usageCount = 0,
    this.averageTimeSpent = 0.0,
    this.averageAccuracy = 0.0,
    this.reviewedAt,
    this.reviewedByUserId,
    this.reviewNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isApproved => status == ContentStatus.published && reviewedAt != null;

  Map<String, dynamic> toMap() => {
    'questionId': questionId,
    'partnershipId': partnershipId,
    'createdByUserId': createdByUserId,
    'questionText': questionText,
    'type': type.toString().split('.').last,
    'difficulty': difficulty.toString().split('.').last,
    'category': category,
    'subcategory': subcategory,
    'answerOptions': answerOptions,
    'correctAnswer': correctAnswer,
    'explanation': explanation,
    'keywords': keywords,
    'status': status.toString().split('.').last,
    'accessLevel': accessLevel.toString().split('.').last,
    'usageCount': usageCount,
    'averageTimeSpent': averageTimeSpent,
    'averageAccuracy': averageAccuracy,
    'reviewedAt': reviewedAt?.toIso8601String(),
    'reviewedByUserId': reviewedByUserId,
    'reviewNotes': reviewNotes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory InstitutionalQuestion.fromMap(Map<String, dynamic> map) =>
    InstitutionalQuestion(
      questionId: map['questionId'] ?? '',
      partnershipId: map['partnershipId'] ?? '',
      createdByUserId: map['createdByUserId'] ?? '',
      questionText: map['questionText'] ?? '',
      type: _parseQuestionType(map['type'] ?? ''),
      difficulty: _parseQuestionDifficulty(map['difficulty'] ?? ''),
      category: map['category'] ?? '',
      subcategory: map['subcategory'],
      answerOptions: List<String>.from(map['answerOptions'] ?? []),
      correctAnswer: map['correctAnswer'] ?? '',
      explanation: map['explanation'],
      keywords: map['keywords'] != null ? List<String>.from(map['keywords']) : null,
      status: _parseContentStatus(map['status'] ?? ''),
      accessLevel: _parseContentAccessLevel(map['accessLevel'] ?? ''),
      usageCount: map['usageCount'] ?? 0,
      averageTimeSpent: (map['averageTimeSpent'] ?? 0.0).toDouble(),
      averageAccuracy: (map['averageAccuracy'] ?? 0.0).toDouble(),
      reviewedAt: map['reviewedAt'] != null ? DateTime.parse(map['reviewedAt']) : null,
      reviewedByUserId: map['reviewedByUserId'],
      reviewNotes: map['reviewNotes'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
}

class InstitutionalQuestionBank {
  final String bankId;
  final String partnershipId;
  final String bankName;
  final String description;
  final int totalQuestions;
  final Map<String, int> questionsByDifficulty; // difficulty -> count
  final Map<String, int> questionsByCategory; // category -> count
  final List<String> creatorIds;
  final ContentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  InstitutionalQuestionBank({
    required this.bankId,
    required this.partnershipId,
    required this.bankName,
    required this.description,
    required this.totalQuestions,
    required this.questionsByDifficulty,
    required this.questionsByCategory,
    required this.creatorIds,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'bankId': bankId,
    'partnershipId': partnershipId,
    'bankName': bankName,
    'description': description,
    'totalQuestions': totalQuestions,
    'questionsByDifficulty': questionsByDifficulty,
    'questionsByCategory': questionsByCategory,
    'creatorIds': creatorIds,
    'status': status.toString().split('.').last,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory InstitutionalQuestionBank.fromMap(Map<String, dynamic> map) =>
    InstitutionalQuestionBank(
      bankId: map['bankId'] ?? '',
      partnershipId: map['partnershipId'] ?? '',
      bankName: map['bankName'] ?? '',
      description: map['description'] ?? '',
      totalQuestions: map['totalQuestions'] ?? 0,
      questionsByDifficulty: Map<String, int>.from(map['questionsByDifficulty'] ?? {}),
      questionsByCategory: Map<String, int>.from(map['questionsByCategory'] ?? {}),
      creatorIds: List<String>.from(map['creatorIds'] ?? []),
      status: _parseContentStatus(map['status'] ?? ''),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
}

class Course {
  final String courseId;
  final String partnershipId;
  final String courseName;
  final String description;
  final List<String> topicIds;
  final List<String> questionIds;
  final int totalLessons;
  final int estimatedHours;
  final CourseStatus status;
  final String instructorId;
  final ContentAccessLevel accessLevel;
  final int enrolledStudents;
  final double averageCompletion;
  final double averageScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  Course({
    required this.courseId,
    required this.partnershipId,
    required this.courseName,
    required this.description,
    required this.topicIds,
    required this.questionIds,
    required this.totalLessons,
    required this.estimatedHours,
    required this.status,
    required this.instructorId,
    required this.accessLevel,
    this.enrolledStudents = 0,
    this.averageCompletion = 0.0,
    this.averageScore = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == CourseStatus.active;

  Map<String, dynamic> toMap() => {
    'courseId': courseId,
    'partnershipId': partnershipId,
    'courseName': courseName,
    'description': description,
    'topicIds': topicIds,
    'questionIds': questionIds,
    'totalLessons': totalLessons,
    'estimatedHours': estimatedHours,
    'status': status.toString().split('.').last,
    'instructorId': instructorId,
    'accessLevel': accessLevel.toString().split('.').last,
    'enrolledStudents': enrolledStudents,
    'averageCompletion': averageCompletion,
    'averageScore': averageScore,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Course.fromMap(Map<String, dynamic> map) =>
    Course(
      courseId: map['courseId'] ?? '',
      partnershipId: map['partnershipId'] ?? '',
      courseName: map['courseName'] ?? '',
      description: map['description'] ?? '',
      topicIds: List<String>.from(map['topicIds'] ?? []),
      questionIds: List<String>.from(map['questionIds'] ?? []),
      totalLessons: map['totalLessons'] ?? 0,
      estimatedHours: map['estimatedHours'] ?? 0,
      status: _parseCourseStatus(map['status'] ?? ''),
      instructorId: map['instructorId'] ?? '',
      accessLevel: _parseContentAccessLevel(map['accessLevel'] ?? ''),
      enrolledStudents: map['enrolledStudents'] ?? 0,
      averageCompletion: (map['averageCompletion'] ?? 0.0).toDouble(),
      averageScore: (map['averageScore'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
}

class Curriculum {
  final String curriculumId;
  final String partnershipId;
  final String curriculumName;
  final String description;
  final CurriculumType type;
  final List<String> courseIds;
  final int totalHours;
  final int targetLevel;
  final String? targetExamType;
  final ContentStatus status;
  final int enrolledStudents;
  final double completionRate;
  final double passProbability;
  final DateTime createdAt;
  final DateTime updatedAt;

  Curriculum({
    required this.curriculumId,
    required this.partnershipId,
    required this.curriculumName,
    required this.description,
    required this.type,
    required this.courseIds,
    required this.totalHours,
    required this.targetLevel,
    this.targetExamType,
    required this.status,
    this.enrolledStudents = 0,
    this.completionRate = 0.0,
    this.passProbability = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPublished => status == ContentStatus.published;

  Map<String, dynamic> toMap() => {
    'curriculumId': curriculumId,
    'partnershipId': partnershipId,
    'curriculumName': curriculumName,
    'description': description,
    'type': type.toString().split('.').last,
    'courseIds': courseIds,
    'totalHours': totalHours,
    'targetLevel': targetLevel,
    'targetExamType': targetExamType,
    'status': status.toString().split('.').last,
    'enrolledStudents': enrolledStudents,
    'completionRate': completionRate,
    'passProbability': passProbability,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Curriculum.fromMap(Map<String, dynamic> map) =>
    Curriculum(
      curriculumId: map['curriculumId'] ?? '',
      partnershipId: map['partnershipId'] ?? '',
      curriculumName: map['curriculumName'] ?? '',
      description: map['description'] ?? '',
      type: _parseCurriculumType(map['type'] ?? ''),
      courseIds: List<String>.from(map['courseIds'] ?? []),
      totalHours: map['totalHours'] ?? 0,
      targetLevel: map['targetLevel'] ?? 1,
      targetExamType: map['targetExamType'],
      status: _parseContentStatus(map['status'] ?? ''),
      enrolledStudents: map['enrolledStudents'] ?? 0,
      completionRate: (map['completionRate'] ?? 0.0).toDouble(),
      passProbability: (map['passProbability'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
}

class CourseEnrollment {
  final String enrollmentId;
  final String courseId;
  final String studentId;
  final String partnershipId;
  final DateTime enrolledAt;
  final DateTime? completedAt;
  final double completionPercentage;
  final double currentScore;
  final int lessonsCompleted;
  final DateTime? lastAccessedAt;

  CourseEnrollment({
    required this.enrollmentId,
    required this.courseId,
    required this.studentId,
    required this.partnershipId,
    required this.enrolledAt,
    this.completedAt,
    required this.completionPercentage,
    required this.currentScore,
    required this.lessonsCompleted,
    this.lastAccessedAt,
  });

  bool get isCompleted => completedAt != null;
  bool get isInProgress => !isCompleted && completionPercentage > 0;

  Map<String, dynamic> toMap() => {
    'enrollmentId': enrollmentId,
    'courseId': courseId,
    'studentId': studentId,
    'partnershipId': partnershipId,
    'enrolledAt': enrolledAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'completionPercentage': completionPercentage,
    'currentScore': currentScore,
    'lessonsCompleted': lessonsCompleted,
    'lastAccessedAt': lastAccessedAt?.toIso8601String(),
  };

  factory CourseEnrollment.fromMap(Map<String, dynamic> map) =>
    CourseEnrollment(
      enrollmentId: map['enrollmentId'] ?? '',
      courseId: map['courseId'] ?? '',
      studentId: map['studentId'] ?? '',
      partnershipId: map['partnershipId'] ?? '',
      enrolledAt: DateTime.parse(map['enrolledAt'] ?? DateTime.now().toIso8601String()),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      completionPercentage: (map['completionPercentage'] ?? 0.0).toDouble(),
      currentScore: (map['currentScore'] ?? 0.0).toDouble(),
      lessonsCompleted: map['lessonsCompleted'] ?? 0,
      lastAccessedAt: map['lastAccessedAt'] != null ? DateTime.parse(map['lastAccessedAt']) : null,
    );
}

class CurriculumProgress {
  final String progressId;
  final String curriculumId;
  final String studentId;
  final String partnershipId;
  final int currentCourseIndex;
  final List<String> completedCourseIds;
  final double overallProgress;
  final double currentScore;
  final int hoursSpent;
  final DateTime startedAt;
  final DateTime? completedAt;

  CurriculumProgress({
    required this.progressId,
    required this.curriculumId,
    required this.studentId,
    required this.partnershipId,
    required this.currentCourseIndex,
    required this.completedCourseIds,
    required this.overallProgress,
    required this.currentScore,
    required this.hoursSpent,
    required this.startedAt,
    this.completedAt,
  });

  bool get isCompleted => completedAt != null;

  Map<String, dynamic> toMap() => {
    'progressId': progressId,
    'curriculumId': curriculumId,
    'studentId': studentId,
    'partnershipId': partnershipId,
    'currentCourseIndex': currentCourseIndex,
    'completedCourseIds': completedCourseIds,
    'overallProgress': overallProgress,
    'currentScore': currentScore,
    'hoursSpent': hoursSpent,
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory CurriculumProgress.fromMap(Map<String, dynamic> map) =>
    CurriculumProgress(
      progressId: map['progressId'] ?? '',
      curriculumId: map['curriculumId'] ?? '',
      studentId: map['studentId'] ?? '',
      partnershipId: map['partnershipId'] ?? '',
      currentCourseIndex: map['currentCourseIndex'] ?? 0,
      completedCourseIds: List<String>.from(map['completedCourseIds'] ?? []),
      overallProgress: (map['overallProgress'] ?? 0.0).toDouble(),
      currentScore: (map['currentScore'] ?? 0.0).toDouble(),
      hoursSpent: map['hoursSpent'] ?? 0,
      startedAt: DateTime.parse(map['startedAt'] ?? DateTime.now().toIso8601String()),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
}

// ============ Admin Dashboard Models ============

class CategoryPerformanceChart {
  final String category;
  final double accuracy;
  final int questionsAnswered;
  final double trend; // positive = improving
  final double averageTimePerQuestion;
  final String? weakestTopic;

  CategoryPerformanceChart({
    required this.category,
    required this.accuracy,
    required this.questionsAnswered,
    required this.trend,
    required this.averageTimePerQuestion,
    this.weakestTopic,
  });

  Map<String, dynamic> toMap() => {
    'category': category,
    'accuracy': accuracy,
    'questionsAnswered': questionsAnswered,
    'trend': trend,
    'averageTimePerQuestion': averageTimePerQuestion,
    'weakestTopic': weakestTopic,
  };

  factory CategoryPerformanceChart.fromMap(Map<String, dynamic> map) =>
    CategoryPerformanceChart(
      category: map['category'] ?? '',
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
      questionsAnswered: map['questionsAnswered'] ?? 0,
      trend: (map['trend'] ?? 0.0).toDouble(),
      averageTimePerQuestion: (map['averageTimePerQuestion'] ?? 0.0).toDouble(),
      weakestTopic: map['weakestTopic'],
    );
}

class StudentProgressWidget {
  final String studentId;
  final String studentName;
  final double overallAccuracy;
  final StudentPerformanceStatus status;
  final int currentStreak;
  final int longestStreak;
  final double readinessProbability;
  final int questionsAnsweredThisWeek;
  final double averageTimePerQuestion;
  final DateTime? lastActivityAt;

  StudentProgressWidget({
    required this.studentId,
    required this.studentName,
    required this.overallAccuracy,
    required this.status,
    required this.currentStreak,
    required this.longestStreak,
    required this.readinessProbability,
    required this.questionsAnsweredThisWeek,
    required this.averageTimePerQuestion,
    this.lastActivityAt,
  });

  bool get isActive => lastActivityAt != null &&
    DateTime.now().difference(lastActivityAt!).inDays <= 3;

  Map<String, dynamic> toMap() => {
    'studentId': studentId,
    'studentName': studentName,
    'overallAccuracy': overallAccuracy,
    'status': status.toString().split('.').last,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'readinessProbability': readinessProbability,
    'questionsAnsweredThisWeek': questionsAnsweredThisWeek,
    'averageTimePerQuestion': averageTimePerQuestion,
    'lastActivityAt': lastActivityAt?.toIso8601String(),
  };

  factory StudentProgressWidget.fromMap(Map<String, dynamic> map) =>
    StudentProgressWidget(
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      overallAccuracy: (map['overallAccuracy'] ?? 0.0).toDouble(),
      status: _parseStudentPerformanceStatus(map['status'] ?? ''),
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      readinessProbability: (map['readinessProbability'] ?? 0.0).toDouble(),
      questionsAnsweredThisWeek: map['questionsAnsweredThisWeek'] ?? 0,
      averageTimePerQuestion: (map['averageTimePerQuestion'] ?? 0.0).toDouble(),
      lastActivityAt: map['lastActivityAt'] != null ?
        DateTime.parse(map['lastActivityAt']) : null,
    );
}

class StudentEngagementMetrics {
  final String studentId;
  final int minutesStudiedThisWeek;
  final int minutesStudiedThisMonth;
  final int sessionsThisWeek;
  final int currentConsecutiveDays;
  final double weeklyConsistencyScore; // 0-100%
  final int averageSessionDuration; // in minutes
  final List<String> recentBadgesEarned;
  final int totalXPEarnedThisMonth;

  StudentEngagementMetrics({
    required this.studentId,
    required this.minutesStudiedThisWeek,
    required this.minutesStudiedThisMonth,
    required this.sessionsThisWeek,
    required this.currentConsecutiveDays,
    required this.weeklyConsistencyScore,
    required this.averageSessionDuration,
    required this.recentBadgesEarned,
    required this.totalXPEarnedThisMonth,
  });

  Map<String, dynamic> toMap() => {
    'studentId': studentId,
    'minutesStudiedThisWeek': minutesStudiedThisWeek,
    'minutesStudiedThisMonth': minutesStudiedThisMonth,
    'sessionsThisWeek': sessionsThisWeek,
    'currentConsecutiveDays': currentConsecutiveDays,
    'weeklyConsistencyScore': weeklyConsistencyScore,
    'averageSessionDuration': averageSessionDuration,
    'recentBadgesEarned': recentBadgesEarned,
    'totalXPEarnedThisMonth': totalXPEarnedThisMonth,
  };

  factory StudentEngagementMetrics.fromMap(Map<String, dynamic> map) =>
    StudentEngagementMetrics(
      studentId: map['studentId'] ?? '',
      minutesStudiedThisWeek: map['minutesStudiedThisWeek'] ?? 0,
      minutesStudiedThisMonth: map['minutesStudiedThisMonth'] ?? 0,
      sessionsThisWeek: map['sessionsThisWeek'] ?? 0,
      currentConsecutiveDays: map['currentConsecutiveDays'] ?? 0,
      weeklyConsistencyScore: (map['weeklyConsistencyScore'] ?? 0.0).toDouble(),
      averageSessionDuration: map['averageSessionDuration'] ?? 0,
      recentBadgesEarned: List<String>.from(map['recentBadgesEarned'] ?? []),
      totalXPEarnedThisMonth: map['totalXPEarnedThisMonth'] ?? 0,
    );
}

class DashboardWidget {
  final String widgetId;
  final String title;
  final String description;
  final DashboardMetricType metricType;
  final dynamic currentValue;
  final dynamic previousValue;
  final double? percentChange;
  final String? trend; // 'up', 'down', 'stable'
  final Map<String, dynamic>? chartData;
  final DateTime? lastUpdatedAt;

  DashboardWidget({
    required this.widgetId,
    required this.title,
    required this.description,
    required this.metricType,
    required this.currentValue,
    this.previousValue,
    this.percentChange,
    this.trend,
    this.chartData,
    this.lastUpdatedAt,
  });

  bool get isPositiveChange {
    if (percentChange == null) return false;
    return percentChange! > 0;
  }

  Map<String, dynamic> toMap() => {
    'widgetId': widgetId,
    'title': title,
    'description': description,
    'metricType': metricType.toString().split('.').last,
    'currentValue': currentValue,
    'previousValue': previousValue,
    'percentChange': percentChange,
    'trend': trend,
    'chartData': chartData,
    'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
  };

  factory DashboardWidget.fromMap(Map<String, dynamic> map) =>
    DashboardWidget(
      widgetId: map['widgetId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      metricType: _parseDashboardMetricType(map['metricType'] ?? ''),
      currentValue: map['currentValue'],
      previousValue: map['previousValue'],
      percentChange: map['percentChange'] != null ?
        (map['percentChange']).toDouble() : null,
      trend: map['trend'],
      chartData: map['chartData'],
      lastUpdatedAt: map['lastUpdatedAt'] != null ?
        DateTime.parse(map['lastUpdatedAt']) : null,
    );
}

class InstructorDashboard {
  final String dashboardId;
  final String instructorId;
  final String partnershipId;
  final String instructorName;
  final List<String> assignedStudentIds;
  final List<DashboardWidget> widgets;
  final List<StudentProgressWidget> studentSnapshots;
  final Map<String, CategoryPerformanceChart> categoryBreakdown;
  final int totalStudentsAssigned;
  final int activeStudentsThisWeek;
  final double classAverageAccuracy;
  final double classAverageReadiness;
  final DateTime? generatedAt;
  final DateTime? lastAccessedAt;

  InstructorDashboard({
    required this.dashboardId,
    required this.instructorId,
    required this.partnershipId,
    required this.instructorName,
    required this.assignedStudentIds,
    required this.widgets,
    required this.studentSnapshots,
    required this.categoryBreakdown,
    required this.totalStudentsAssigned,
    required this.activeStudentsThisWeek,
    required this.classAverageAccuracy,
    required this.classAverageReadiness,
    this.generatedAt,
    this.lastAccessedAt,
  });

  int get atRiskStudentCount =>
    studentSnapshots
      .where((s) => s.status == StudentPerformanceStatus.atRisk ||
                   s.status == StudentPerformanceStatus.critical)
      .length;

  double get engagementRate =>
    totalStudentsAssigned == 0 ? 0.0 :
    (activeStudentsThisWeek / totalStudentsAssigned) * 100;

  Map<String, dynamic> toMap() => {
    'dashboardId': dashboardId,
    'instructorId': instructorId,
    'partnershipId': partnershipId,
    'instructorName': instructorName,
    'assignedStudentIds': assignedStudentIds,
    'widgets': widgets.map((w) => w.toMap()).toList(),
    'studentSnapshots': studentSnapshots.map((s) => s.toMap()).toList(),
    'categoryBreakdown': categoryBreakdown.map((k, v) =>
      MapEntry(k, v.toMap())),
    'totalStudentsAssigned': totalStudentsAssigned,
    'activeStudentsThisWeek': activeStudentsThisWeek,
    'classAverageAccuracy': classAverageAccuracy,
    'classAverageReadiness': classAverageReadiness,
    'generatedAt': generatedAt?.toIso8601String(),
    'lastAccessedAt': lastAccessedAt?.toIso8601String(),
  };

  factory InstructorDashboard.fromMap(Map<String, dynamic> map) =>
    InstructorDashboard(
      dashboardId: map['dashboardId'] ?? '',
      instructorId: map['instructorId'] ?? '',
      partnershipId: map['partnershipId'] ?? '',
      instructorName: map['instructorName'] ?? '',
      assignedStudentIds: List<String>.from(map['assignedStudentIds'] ?? []),
      widgets: (map['widgets'] as List<dynamic>?)?.map((w) =>
        DashboardWidget.fromMap(w as Map<String, dynamic>)).toList() ?? [],
      studentSnapshots: (map['studentSnapshots'] as List<dynamic>?)?.map((s) =>
        StudentProgressWidget.fromMap(s as Map<String, dynamic>)).toList() ?? [],
      categoryBreakdown: (map['categoryBreakdown'] as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(k,
          CategoryPerformanceChart.fromMap(v as Map<String, dynamic>))) ?? {},
      totalStudentsAssigned: map['totalStudentsAssigned'] ?? 0,
      activeStudentsThisWeek: map['activeStudentsThisWeek'] ?? 0,
      classAverageAccuracy: (map['classAverageAccuracy'] ?? 0.0).toDouble(),
      classAverageReadiness: (map['classAverageReadiness'] ?? 0.0).toDouble(),
      generatedAt: map['generatedAt'] != null ?
        DateTime.parse(map['generatedAt']) : null,
      lastAccessedAt: map['lastAccessedAt'] != null ?
        DateTime.parse(map['lastAccessedAt']) : null,
    );

  factory InstructorDashboard.empty({
    required String dashboardId,
    required String instructorId,
    required String partnershipId,
    required String instructorName,
  }) =>
    InstructorDashboard(
      dashboardId: dashboardId,
      instructorId: instructorId,
      partnershipId: partnershipId,
      instructorName: instructorName,
      assignedStudentIds: [],
      widgets: [],
      studentSnapshots: [],
      categoryBreakdown: {},
      totalStudentsAssigned: 0,
      activeStudentsThisWeek: 0,
      classAverageAccuracy: 0.0,
      classAverageReadiness: 0.0,
    );
}

class AdminDashboard {
  final String dashboardId;
  final String partnershipId;
  final String schoolName;
  final List<DashboardWidget> widgets;
  final Map<String, dynamic> financialMetrics;
  final List<StudentProgressWidget> topPerformers;
  final List<StudentProgressWidget> atRiskStudents;
  final Map<String, CategoryPerformanceChart> schoolWideCategoryPerformance;
  final int totalEnrolledStudents;
  final int activeStudentsThisMonth;
  final double overallCompletionRate;
  final double overallReadinessProbability;
  final double monthlyRevenueJPY;
  final double seatUtilizationPercent;
  final List<String> recentInstructorActivity;
  final DateTime? generatedAt;
  final DateTime? lastAccessedAt;

  AdminDashboard({
    required this.dashboardId,
    required this.partnershipId,
    required this.schoolName,
    required this.widgets,
    required this.financialMetrics,
    required this.topPerformers,
    required this.atRiskStudents,
    required this.schoolWideCategoryPerformance,
    required this.totalEnrolledStudents,
    required this.activeStudentsThisMonth,
    required this.overallCompletionRate,
    required this.overallReadinessProbability,
    required this.monthlyRevenueJPY,
    required this.seatUtilizationPercent,
    required this.recentInstructorActivity,
    this.generatedAt,
    this.lastAccessedAt,
  });

  int get criticalAtRiskCount =>
    atRiskStudents.where((s) => s.status == StudentPerformanceStatus.critical).length;

  double get studentRetentionRate {
    if (totalEnrolledStudents == 0) return 0.0;
    return (activeStudentsThisMonth / totalEnrolledStudents) * 100;
  }

  Map<String, dynamic> toMap() => {
    'dashboardId': dashboardId,
    'partnershipId': partnershipId,
    'schoolName': schoolName,
    'widgets': widgets.map((w) => w.toMap()).toList(),
    'financialMetrics': financialMetrics,
    'topPerformers': topPerformers.map((p) => p.toMap()).toList(),
    'atRiskStudents': atRiskStudents.map((s) => s.toMap()).toList(),
    'schoolWideCategoryPerformance': schoolWideCategoryPerformance.map((k, v) =>
      MapEntry(k, v.toMap())),
    'totalEnrolledStudents': totalEnrolledStudents,
    'activeStudentsThisMonth': activeStudentsThisMonth,
    'overallCompletionRate': overallCompletionRate,
    'overallReadinessProbability': overallReadinessProbability,
    'monthlyRevenueJPY': monthlyRevenueJPY,
    'seatUtilizationPercent': seatUtilizationPercent,
    'recentInstructorActivity': recentInstructorActivity,
    'generatedAt': generatedAt?.toIso8601String(),
    'lastAccessedAt': lastAccessedAt?.toIso8601String(),
  };

  factory AdminDashboard.fromMap(Map<String, dynamic> map) =>
    AdminDashboard(
      dashboardId: map['dashboardId'] ?? '',
      partnershipId: map['partnershipId'] ?? '',
      schoolName: map['schoolName'] ?? '',
      widgets: (map['widgets'] as List<dynamic>?)?.map((w) =>
        DashboardWidget.fromMap(w as Map<String, dynamic>)).toList() ?? [],
      financialMetrics: map['financialMetrics'] ?? {},
      topPerformers: (map['topPerformers'] as List<dynamic>?)?.map((p) =>
        StudentProgressWidget.fromMap(p as Map<String, dynamic>)).toList() ?? [],
      atRiskStudents: (map['atRiskStudents'] as List<dynamic>?)?.map((s) =>
        StudentProgressWidget.fromMap(s as Map<String, dynamic>)).toList() ?? [],
      schoolWideCategoryPerformance: (map['schoolWideCategoryPerformance']
        as Map<String, dynamic>?)?.map((k, v) => MapEntry(k,
          CategoryPerformanceChart.fromMap(v as Map<String, dynamic>))) ?? {},
      totalEnrolledStudents: map['totalEnrolledStudents'] ?? 0,
      activeStudentsThisMonth: map['activeStudentsThisMonth'] ?? 0,
      overallCompletionRate: (map['overallCompletionRate'] ?? 0.0).toDouble(),
      overallReadinessProbability: (map['overallReadinessProbability'] ?? 0.0).toDouble(),
      monthlyRevenueJPY: (map['monthlyRevenueJPY'] ?? 0.0).toDouble(),
      seatUtilizationPercent: (map['seatUtilizationPercent'] ?? 0.0).toDouble(),
      recentInstructorActivity: List<String>.from(map['recentInstructorActivity'] ?? []),
      generatedAt: map['generatedAt'] != null ?
        DateTime.parse(map['generatedAt']) : null,
      lastAccessedAt: map['lastAccessedAt'] != null ?
        DateTime.parse(map['lastAccessedAt']) : null,
    );

  factory AdminDashboard.empty({
    required String dashboardId,
    required String partnershipId,
    required String schoolName,
  }) =>
    AdminDashboard(
      dashboardId: dashboardId,
      partnershipId: partnershipId,
      schoolName: schoolName,
      widgets: [],
      financialMetrics: {},
      topPerformers: [],
      atRiskStudents: [],
      schoolWideCategoryPerformance: {},
      totalEnrolledStudents: 0,
      activeStudentsThisMonth: 0,
      overallCompletionRate: 0.0,
      overallReadinessProbability: 0.0,
      monthlyRevenueJPY: 0.0,
      seatUtilizationPercent: 0.0,
      recentInstructorActivity: [],
    );
}

class CustomReport {
  final String reportId;
  final String partnershipId;
  final String reportName;
  final ReportType reportType;
  final DateTime generatedAt;
  final Map<String, dynamic> reportData;
  final String? generatedByUserId;
  final String? generatedByUserName;
  final bool isPubliclyShared;
  final List<String>? sharedWithEmails;
  final String? exportUrl; // S3 or storage URL
  final String? fileFormat; // 'pdf', 'csv', 'xlsx'

  CustomReport({
    required this.reportId,
    required this.partnershipId,
    required this.reportName,
    required this.reportType,
    required this.generatedAt,
    required this.reportData,
    this.generatedByUserId,
    this.generatedByUserName,
    this.isPubliclyShared = false,
    this.sharedWithEmails,
    this.exportUrl,
    this.fileFormat,
  });

  Map<String, dynamic> toMap() => {
    'reportId': reportId,
    'partnershipId': partnershipId,
    'reportName': reportName,
    'reportType': reportType.toString().split('.').last,
    'generatedAt': generatedAt.toIso8601String(),
    'reportData': reportData,
    'generatedByUserId': generatedByUserId,
    'generatedByUserName': generatedByUserName,
    'isPubliclyShared': isPubliclyShared,
    'sharedWithEmails': sharedWithEmails,
    'exportUrl': exportUrl,
    'fileFormat': fileFormat,
  };

  factory CustomReport.fromMap(Map<String, dynamic> map) =>
    CustomReport(
      reportId: map['reportId'] ?? '',
      partnershipId: map['partnershipId'] ?? '',
      reportName: map['reportName'] ?? '',
      reportType: _parseReportType(map['reportType'] ?? ''),
      generatedAt: DateTime.parse(map['generatedAt'] ?? DateTime.now().toIso8601String()),
      reportData: map['reportData'] ?? {},
      generatedByUserId: map['generatedByUserId'],
      generatedByUserName: map['generatedByUserName'],
      isPubliclyShared: map['isPubliclyShared'] ?? false,
      sharedWithEmails: map['sharedWithEmails'] != null ?
        List<String>.from(map['sharedWithEmails']) : null,
      exportUrl: map['exportUrl'],
      fileFormat: map['fileFormat'],
    );
}

// ============ Helper functions ============

BadgeType _parseBadgeType(String value) {
  try {
    return BadgeType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
    );
  } catch (e) {
    return BadgeType.firstQuestion;
  }
}

BadgeRarityLevel _parseBadgeRarity(String value) {
  try {
    return BadgeRarityLevel.values.firstWhere(
      (e) => e.toString().split('.').last == value,
    );
  } catch (e) {
    return BadgeRarityLevel.common;
  }
}

PartnershipStatus _parsePartnershipStatus(String value) {
  try {
    return PartnershipStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
    );
  } catch (e) {
    return PartnershipStatus.pending;
  }
}

PartnershipTier _parsePartnershipTier(String value) {
  try {
    return PartnershipTier.values.firstWhere(
      (e) => e.toString().split('.').last == value,
    );
  } catch (e) {
    return PartnershipTier.starter;
  }
}

LicenseType _parseLicenseType(String value) {
  try {
    return LicenseType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
    );
  } catch (e) {
    return LicenseType.studentAccess;
  }
}

StudentPerformanceStatus _parseStudentPerformanceStatus(String value) {
  try {
    return StudentPerformanceStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
    );
  } catch (e) {
    return StudentPerformanceStatus.average;
  }
}

DashboardMetricType _parseDashboardMetricType(String value) {
  try {
    return DashboardMetricType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
    );
  } catch (e) {
    return DashboardMetricType.engagement;
  }
}

ReportType _parseReportType(String value) {
  try {
    return ReportType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
    );
  } catch (e) {
    return ReportType.performance;
  }
}

ContentStatus _parseContentStatus(String value) {
  try {
    return ContentStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
    );
  } catch (e) {
    return ContentStatus.draft;
  }
}

ContentAccessLevel _parseContentAccessLevel(String value) {
  try {
    return ContentAccessLevel.values.firstWhere(
      (e) => e.toString().split('.').last == value,
    );
  } catch (e) {
    return ContentAccessLevel.public;
  }
}

CourseStatus _parseCourseStatus(String value) {
  try {
    return CourseStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
    );
  } catch (e) {
    return CourseStatus.draft;
  }
}

CurriculumType _parseCurriculumType(String value) {
  try {
    return CurriculumType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
    );
  } catch (e) {
    return CurriculumType.standardCurriculum;
  }
}

QuestionType _parseQuestionType(String value) {
  try {
    return QuestionType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
    );
  } catch (e) {
    return QuestionType.multipleChoice;
  }
}

QuestionDifficulty _parseQuestionDifficulty(String value) {
  try {
    return QuestionDifficulty.values.firstWhere(
      (e) => e.toString().split('.').last == value,
    );
  } catch (e) {
    return QuestionDifficulty.intermediate;
  }
}
