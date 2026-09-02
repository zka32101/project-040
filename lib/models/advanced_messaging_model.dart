import 'package:cloud_firestore/cloud_firestore.dart';

/// Advanced messaging system enums
enum PinPriority { low, normal, high, urgent }

enum ReactionType { emoji, sticker, gif, custom }

enum ThreadStatus { active, resolved, archived }

/// Message pin for important messages
class PinnedMessage {
  final String pinnedId;
  final String messageId;
  final String conversationId;
  final String pinnedBy;
  final String? pinnedReason;
  final PinPriority priority;
  final DateTime createdAt;
  final List<String> viewers; // Users who viewed the pin

  PinnedMessage({
    required this.pinnedId,
    required this.messageId,
    required this.conversationId,
    required this.pinnedBy,
    this.pinnedReason,
    this.priority = PinPriority.normal,
    required this.createdAt,
    this.viewers = const [],
  });

  int get viewerCount => viewers.length;

  factory PinnedMessage.empty() {
    return PinnedMessage(
      pinnedId: '',
      messageId: '',
      conversationId: '',
      pinnedBy: '',
      createdAt: DateTime.now(),
    );
  }

  factory PinnedMessage.fromMap(Map<String, dynamic> map) {
    return PinnedMessage(
      pinnedId: map['pinnedId'] as String? ?? '',
      messageId: map['messageId'] as String? ?? '',
      conversationId: map['conversationId'] as String? ?? '',
      pinnedBy: map['pinnedBy'] as String? ?? '',
      pinnedReason: map['pinnedReason'] as String?,
      priority:
          PinPriority.values[(map['priority'] as int?) ?? PinPriority.normal.index],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      viewers: List<String>.from(map['viewers'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pinnedId': pinnedId,
      'messageId': messageId,
      'conversationId': conversationId,
      'pinnedBy': pinnedBy,
      'pinnedReason': pinnedReason,
      'priority': priority.index,
      'createdAt': Timestamp.fromDate(createdAt),
      'viewers': viewers,
    };
  }
}

/// Forward message history
class ForwardedMessage {
  final String forwardedId;
  final String originalMessageId;
  final String forwardedBy;
  final String targetConversationId;
  final String? forwardMessage;
  final DateTime forwardedAt;
  final String originalSenderName;
  final DateTime originalSentAt;

  ForwardedMessage({
    required this.forwardedId,
    required this.originalMessageId,
    required this.forwardedBy,
    required this.targetConversationId,
    this.forwardMessage,
    required this.forwardedAt,
    required this.originalSenderName,
    required this.originalSentAt,
  });

  factory ForwardedMessage.empty() {
    return ForwardedMessage(
      forwardedId: '',
      originalMessageId: '',
      forwardedBy: '',
      targetConversationId: '',
      forwardedAt: DateTime.now(),
      originalSenderName: '',
      originalSentAt: DateTime.now(),
    );
  }

  factory ForwardedMessage.fromMap(Map<String, dynamic> map) {
    return ForwardedMessage(
      forwardedId: map['forwardedId'] as String? ?? '',
      originalMessageId: map['originalMessageId'] as String? ?? '',
      forwardedBy: map['forwardedBy'] as String? ?? '',
      targetConversationId: map['targetConversationId'] as String? ?? '',
      forwardMessage: map['forwardMessage'] as String?,
      forwardedAt: (map['forwardedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      originalSenderName: map['originalSenderName'] as String? ?? 'User',
      originalSentAt: (map['originalSentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'forwardedId': forwardedId,
      'originalMessageId': originalMessageId,
      'forwardedBy': forwardedBy,
      'targetConversationId': targetConversationId,
      'forwardMessage': forwardMessage,
      'forwardedAt': Timestamp.fromDate(forwardedAt),
      'originalSenderName': originalSenderName,
      'originalSentAt': Timestamp.fromDate(originalSentAt),
    };
  }
}

/// Message thread for organized discussions
class MessageThread {
  final String threadId;
  final String conversationId;
  final String rootMessageId;
  final String initiatedBy;
  final String? subject;
  final int messageCount;
  final DateTime createdAt;
  final DateTime? lastReplyAt;
  final ThreadStatus status;
  final List<String> participantIds;

  MessageThread({
    required this.threadId,
    required this.conversationId,
    required this.rootMessageId,
    required this.initiatedBy,
    this.subject,
    this.messageCount = 0,
    required this.createdAt,
    this.lastReplyAt,
    this.status = ThreadStatus.active,
    this.participantIds = const [],
  });

  bool get isActive => status == ThreadStatus.active;
  bool get hasReplies => messageCount > 1;

  factory MessageThread.empty() {
    return MessageThread(
      threadId: '',
      conversationId: '',
      rootMessageId: '',
      initiatedBy: '',
      createdAt: DateTime.now(),
    );
  }

  factory MessageThread.fromMap(Map<String, dynamic> map) {
    return MessageThread(
      threadId: map['threadId'] as String? ?? '',
      conversationId: map['conversationId'] as String? ?? '',
      rootMessageId: map['rootMessageId'] as String? ?? '',
      initiatedBy: map['initiatedBy'] as String? ?? '',
      subject: map['subject'] as String?,
      messageCount: map['messageCount'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastReplyAt: (map['lastReplyAt'] as Timestamp?)?.toDate(),
      status: ThreadStatus.values[(map['status'] as int?) ?? ThreadStatus.active.index],
      participantIds: List<String>.from(map['participantIds'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'threadId': threadId,
      'conversationId': conversationId,
      'rootMessageId': rootMessageId,
      'initiatedBy': initiatedBy,
      'subject': subject,
      'messageCount': messageCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastReplyAt': lastReplyAt != null ? Timestamp.fromDate(lastReplyAt!) : null,
      'status': status.index,
      'participantIds': participantIds,
    };
  }

  MessageThread copyWith({
    int? messageCount,
    DateTime? lastReplyAt,
    ThreadStatus? status,
    List<String>? participantIds,
  }) {
    return MessageThread(
      threadId: threadId,
      conversationId: conversationId,
      rootMessageId: rootMessageId,
      initiatedBy: initiatedBy,
      subject: subject,
      messageCount: messageCount ?? this.messageCount,
      createdAt: createdAt,
      lastReplyAt: lastReplyAt ?? this.lastReplyAt,
      status: status ?? this.status,
      participantIds: participantIds ?? this.participantIds,
    );
  }
}

/// Rich reaction with stickers and GIFs
class RichReaction {
  final String reactionId;
  final String messageId;
  final String userId;
  final ReactionType type; // emoji, sticker, gif, custom
  final String content; // emoji unicode, sticker ID, GIF URL, custom content
  final String? label;
  final DateTime createdAt;
  final int reactionCount;

  RichReaction({
    required this.reactionId,
    required this.messageId,
    required this.userId,
    required this.type,
    required this.content,
    this.label,
    required this.createdAt,
    this.reactionCount = 1,
  });

  factory RichReaction.empty() {
    return RichReaction(
      reactionId: '',
      messageId: '',
      userId: '',
      type: ReactionType.emoji,
      content: '',
      createdAt: DateTime.now(),
    );
  }

  factory RichReaction.fromMap(Map<String, dynamic> map) {
    return RichReaction(
      reactionId: map['reactionId'] as String? ?? '',
      messageId: map['messageId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      type: ReactionType.values[(map['type'] as int?) ?? ReactionType.emoji.index],
      content: map['content'] as String? ?? '',
      label: map['label'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reactionCount: map['reactionCount'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reactionId': reactionId,
      'messageId': messageId,
      'userId': userId,
      'type': type.index,
      'content': content,
      'label': label,
      'createdAt': Timestamp.fromDate(createdAt),
      'reactionCount': reactionCount,
    };
  }
}

/// Bookmarked message
class BookmarkedMessage {
  final String bookmarkId;
  final String messageId;
  final String userId;
  final String conversationId;
  final String? messagePreview;
  final String? folder;
  final List<String> tags;
  final DateTime bookmarkedAt;

  BookmarkedMessage({
    required this.bookmarkId,
    required this.messageId,
    required this.userId,
    required this.conversationId,
    this.messagePreview,
    this.folder,
    this.tags = const [],
    required this.bookmarkedAt,
  });

  factory BookmarkedMessage.empty() {
    return BookmarkedMessage(
      bookmarkId: '',
      messageId: '',
      userId: '',
      conversationId: '',
      bookmarkedAt: DateTime.now(),
    );
  }

  factory BookmarkedMessage.fromMap(Map<String, dynamic> map) {
    return BookmarkedMessage(
      bookmarkId: map['bookmarkId'] as String? ?? '',
      messageId: map['messageId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      conversationId: map['conversationId'] as String? ?? '',
      messagePreview: map['messagePreview'] as String?,
      folder: map['folder'] as String?,
      tags: List<String>.from(map['tags'] as List? ?? []),
      bookmarkedAt: (map['bookmarkedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookmarkId': bookmarkId,
      'messageId': messageId,
      'userId': userId,
      'conversationId': conversationId,
      'messagePreview': messagePreview,
      'folder': folder,
      'tags': tags,
      'bookmarkedAt': Timestamp.fromDate(bookmarkedAt),
    };
  }

  BookmarkedMessage copyWith({
    String? folder,
    List<String>? tags,
  }) {
    return BookmarkedMessage(
      bookmarkId: bookmarkId,
      messageId: messageId,
      userId: userId,
      conversationId: conversationId,
      messagePreview: messagePreview,
      folder: folder ?? this.folder,
      tags: tags ?? this.tags,
      bookmarkedAt: bookmarkedAt,
    );
  }
}

/// Conversation customization settings
class ConversationSettings {
  final String conversationId;
  final String userId;
  final String? themeColor;
  final bool notificationsEnabled;
  final int? notificationQuietHoursStart; // 24-hour format
  final int? notificationQuietHoursEnd;
  final List<String> pinnedMemberIds;
  final bool showTypingIndicators;
  final bool allowReactions;
  final bool allowForwarding;
  final bool allowThreading;
  final DateTime updatedAt;

  ConversationSettings({
    required this.conversationId,
    required this.userId,
    this.themeColor,
    this.notificationsEnabled = true,
    this.notificationQuietHoursStart,
    this.notificationQuietHoursEnd,
    this.pinnedMemberIds = const [],
    this.showTypingIndicators = true,
    this.allowReactions = true,
    this.allowForwarding = true,
    this.allowThreading = true,
    required this.updatedAt,
  });

  bool get hasQuietHours =>
      notificationQuietHoursStart != null && notificationQuietHoursEnd != null;

  factory ConversationSettings.empty(String conversationId, String userId) {
    return ConversationSettings(
      conversationId: conversationId,
      userId: userId,
      updatedAt: DateTime.now(),
    );
  }

  factory ConversationSettings.fromMap(Map<String, dynamic> map) {
    return ConversationSettings(
      conversationId: map['conversationId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      themeColor: map['themeColor'] as String?,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      notificationQuietHoursStart:
          map['notificationQuietHoursStart'] as int?,
      notificationQuietHoursEnd: map['notificationQuietHoursEnd'] as int?,
      pinnedMemberIds: List<String>.from(map['pinnedMemberIds'] as List? ?? []),
      showTypingIndicators: map['showTypingIndicators'] as bool? ?? true,
      allowReactions: map['allowReactions'] as bool? ?? true,
      allowForwarding: map['allowForwarding'] as bool? ?? true,
      allowThreading: map['allowThreading'] as bool? ?? true,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'userId': userId,
      'themeColor': themeColor,
      'notificationsEnabled': notificationsEnabled,
      'notificationQuietHoursStart': notificationQuietHoursStart,
      'notificationQuietHoursEnd': notificationQuietHoursEnd,
      'pinnedMemberIds': pinnedMemberIds,
      'showTypingIndicators': showTypingIndicators,
      'allowReactions': allowReactions,
      'allowForwarding': allowForwarding,
      'allowThreading': allowThreading,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ConversationSettings copyWith({
    String? themeColor,
    bool? notificationsEnabled,
    int? notificationQuietHoursStart,
    int? notificationQuietHoursEnd,
    List<String>? pinnedMemberIds,
    bool? showTypingIndicators,
    bool? allowReactions,
    bool? allowForwarding,
    bool? allowThreading,
  }) {
    return ConversationSettings(
      conversationId: conversationId,
      userId: userId,
      themeColor: themeColor ?? this.themeColor,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationQuietHoursStart:
          notificationQuietHoursStart ?? this.notificationQuietHoursStart,
      notificationQuietHoursEnd:
          notificationQuietHoursEnd ?? this.notificationQuietHoursEnd,
      pinnedMemberIds: pinnedMemberIds ?? this.pinnedMemberIds,
      showTypingIndicators: showTypingIndicators ?? this.showTypingIndicators,
      allowReactions: allowReactions ?? this.allowReactions,
      allowForwarding: allowForwarding ?? this.allowForwarding,
      allowThreading: allowThreading ?? this.allowThreading,
      updatedAt: DateTime.now(),
    );
  }
}

/// Advanced messaging statistics
class AdvancedMessagingStats {
  final String conversationId;
  final int totalPinned;
  final int totalForwarded;
  final int activeThreads;
  final int totalReactions;
  final int totalBookmarks;
  final DateTime updatedAt;

  AdvancedMessagingStats({
    required this.conversationId,
    this.totalPinned = 0,
    this.totalForwarded = 0,
    this.activeThreads = 0,
    this.totalReactions = 0,
    this.totalBookmarks = 0,
    required this.updatedAt,
  });

  factory AdvancedMessagingStats.empty(String conversationId) {
    return AdvancedMessagingStats(
      conversationId: conversationId,
      updatedAt: DateTime.now(),
    );
  }

  factory AdvancedMessagingStats.fromMap(Map<String, dynamic> map) {
    return AdvancedMessagingStats(
      conversationId: map['conversationId'] as String? ?? '',
      totalPinned: map['totalPinned'] as int? ?? 0,
      totalForwarded: map['totalForwarded'] as int? ?? 0,
      activeThreads: map['activeThreads'] as int? ?? 0,
      totalReactions: map['totalReactions'] as int? ?? 0,
      totalBookmarks: map['totalBookmarks'] as int? ?? 0,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'totalPinned': totalPinned,
      'totalForwarded': totalForwarded,
      'activeThreads': activeThreads,
      'totalReactions': totalReactions,
      'totalBookmarks': totalBookmarks,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
