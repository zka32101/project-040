import 'package:cloud_firestore/cloud_firestore.dart';

/// Messaging system enums
enum MessageType { text, reaction, mention, system, media }

enum ConversationType { direct, group }

enum NotificationType {
  message,
  mention,
  reaction,
  friend_request,
  achievement,
  leaderboard,
  group_invite,
  group_update,
}

enum NotificationStatus { unread, read, dismissed }

/// Represents a single message in a conversation
class Message {
  final String messageId;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  final DateTime? editedAt;
  final List<String> readBy; // User IDs who have read
  final Map<String, int> reactions; // emoji -> count
  final String? replyToMessageId;
  final bool isDeleted;

  Message({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.type,
    required this.createdAt,
    this.editedAt,
    this.readBy = const [],
    this.reactions = const {},
    this.replyToMessageId,
    this.isDeleted = false,
  });

  bool get isRead => readBy.isNotEmpty;
  int get reactionCount => reactions.values.fold(0, (sum, count) => sum + count);

  factory Message.empty() {
    return Message(
      messageId: '',
      conversationId: '',
      senderId: '',
      senderName: '',
      content: '',
      type: MessageType.text,
      createdAt: DateTime.now(),
    );
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['messageId'] as String? ?? '',
      conversationId: map['conversationId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? 'User',
      senderAvatar: map['senderAvatar'] as String?,
      content: map['content'] as String? ?? '',
      type: MessageType
          .values[(map['type'] as int?) ?? MessageType.text.index],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      editedAt: (map['editedAt'] as Timestamp?)?.toDate(),
      readBy: List<String>.from(map['readBy'] as List? ?? []),
      reactions: Map<String, int>.from(map['reactions'] as Map? ?? {}),
      replyToMessageId: map['replyToMessageId'] as String?,
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'type': type.index,
      'createdAt': Timestamp.fromDate(createdAt),
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'readBy': readBy,
      'reactions': reactions,
      'replyToMessageId': replyToMessageId,
      'isDeleted': isDeleted,
    };
  }

  Message copyWith({
    String? content,
    DateTime? editedAt,
    List<String>? readBy,
    Map<String, int>? reactions,
  }) {
    return Message(
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: content ?? this.content,
      type: type,
      createdAt: createdAt,
      editedAt: editedAt ?? this.editedAt,
      readBy: readBy ?? this.readBy,
      reactions: reactions ?? this.reactions,
      replyToMessageId: replyToMessageId,
      isDeleted: isDeleted,
    );
  }
}

/// Represents a conversation (DM or group chat)
class Conversation {
  final String conversationId;
  final ConversationType type;
  final List<String> participantIds;
  final String? groupName;
  final String? groupDescription;
  final String? groupIcon;
  final String? groupOwnerId;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? lastMessagePreview;
  final bool isMuted;
  final DateTime? archivedAt;

  Conversation({
    required this.conversationId,
    required this.type,
    required this.participantIds,
    this.groupName,
    this.groupDescription,
    this.groupIcon,
    this.groupOwnerId,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessagePreview,
    this.isMuted = false,
    this.archivedAt,
  });

  bool get isArchived => archivedAt != null;
  String get displayName {
    if (type == ConversationType.group) {
      return groupName ?? 'Group';
    }
    return 'Direct Message';
  }

  factory Conversation.empty() {
    return Conversation(
      conversationId: '',
      type: ConversationType.direct,
      participantIds: [],
      createdAt: DateTime.now(),
    );
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      conversationId: map['conversationId'] as String? ?? '',
      type: ConversationType
          .values[(map['type'] as int?) ?? ConversationType.direct.index],
      participantIds: List<String>.from(map['participantIds'] as List? ?? []),
      groupName: map['groupName'] as String?,
      groupDescription: map['groupDescription'] as String?,
      groupIcon: map['groupIcon'] as String?,
      groupOwnerId: map['groupOwnerId'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageAt: (map['lastMessageAt'] as Timestamp?)?.toDate(),
      lastMessagePreview: map['lastMessagePreview'] as String?,
      isMuted: map['isMuted'] as bool? ?? false,
      archivedAt: (map['archivedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'type': type.index,
      'participantIds': participantIds,
      'groupName': groupName,
      'groupDescription': groupDescription,
      'groupIcon': groupIcon,
      'groupOwnerId': groupOwnerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt':
          lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'lastMessagePreview': lastMessagePreview,
      'isMuted': isMuted,
      'archivedAt': archivedAt != null ? Timestamp.fromDate(archivedAt!) : null,
    };
  }

  Conversation copyWith({
    String? groupName,
    String? groupDescription,
    String? groupIcon,
    DateTime? lastMessageAt,
    String? lastMessagePreview,
    bool? isMuted,
    DateTime? archivedAt,
  }) {
    return Conversation(
      conversationId: conversationId,
      type: type,
      participantIds: participantIds,
      groupName: groupName ?? this.groupName,
      groupDescription: groupDescription ?? this.groupDescription,
      groupIcon: groupIcon ?? this.groupIcon,
      groupOwnerId: groupOwnerId,
      createdAt: createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      isMuted: isMuted ?? this.isMuted,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }
}

/// Represents a user notification
class Notification {
  final String notificationId;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final String? relatedUserId;
  final String? relatedConversationId;
  final DateTime createdAt;
  final NotificationStatus status;
  final Map<String, dynamic>? metadata;

  Notification({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedUserId,
    this.relatedConversationId,
    required this.createdAt,
    this.status = NotificationStatus.unread,
    this.metadata,
  });

  bool get isUnread => status == NotificationStatus.unread;

  factory Notification.empty() {
    return Notification(
      notificationId: '',
      userId: '',
      type: NotificationType.message,
      title: '',
      message: '',
      createdAt: DateTime.now(),
    );
  }

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      notificationId: map['notificationId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      type: NotificationType
          .values[(map['type'] as int?) ?? NotificationType.message.index],
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      relatedUserId: map['relatedUserId'] as String?,
      relatedConversationId: map['relatedConversationId'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: NotificationStatus
          .values[(map['status'] as int?) ?? NotificationStatus.unread.index],
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'type': type.index,
      'title': title,
      'message': message,
      'relatedUserId': relatedUserId,
      'relatedConversationId': relatedConversationId,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.index,
      'metadata': metadata,
    };
  }
}

/// User notification preferences
class NotificationPreference {
  final String userId;
  final bool messagesEnabled;
  final bool mentionsEnabled;
  final bool reactionsEnabled;
  final bool friendRequestsEnabled;
  final bool achievementsEnabled;
  final bool leaderboardEnabled;
  final bool groupUpdatesEnabled;
  final bool soundEnabled;
  final bool vibrationsEnabled;

  NotificationPreference({
    required this.userId,
    this.messagesEnabled = true,
    this.mentionsEnabled = true,
    this.reactionsEnabled = true,
    this.friendRequestsEnabled = true,
    this.achievementsEnabled = true,
    this.leaderboardEnabled = true,
    this.groupUpdatesEnabled = true,
    this.soundEnabled = true,
    this.vibrationsEnabled = true,
  });

  factory NotificationPreference.empty(String userId) {
    return NotificationPreference(userId: userId);
  }

  factory NotificationPreference.fromMap(Map<String, dynamic> map) {
    return NotificationPreference(
      userId: map['userId'] as String? ?? '',
      messagesEnabled: map['messagesEnabled'] as bool? ?? true,
      mentionsEnabled: map['mentionsEnabled'] as bool? ?? true,
      reactionsEnabled: map['reactionsEnabled'] as bool? ?? true,
      friendRequestsEnabled: map['friendRequestsEnabled'] as bool? ?? true,
      achievementsEnabled: map['achievementsEnabled'] as bool? ?? true,
      leaderboardEnabled: map['leaderboardEnabled'] as bool? ?? true,
      groupUpdatesEnabled: map['groupUpdatesEnabled'] as bool? ?? true,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      vibrationsEnabled: map['vibrationsEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'messagesEnabled': messagesEnabled,
      'mentionsEnabled': mentionsEnabled,
      'reactionsEnabled': reactionsEnabled,
      'friendRequestsEnabled': friendRequestsEnabled,
      'achievementsEnabled': achievementsEnabled,
      'leaderboardEnabled': leaderboardEnabled,
      'groupUpdatesEnabled': groupUpdatesEnabled,
      'soundEnabled': soundEnabled,
      'vibrationsEnabled': vibrationsEnabled,
    };
  }

  NotificationPreference copyWith({
    bool? messagesEnabled,
    bool? mentionsEnabled,
    bool? reactionsEnabled,
    bool? friendRequestsEnabled,
    bool? achievementsEnabled,
    bool? leaderboardEnabled,
    bool? groupUpdatesEnabled,
    bool? soundEnabled,
    bool? vibrationsEnabled,
  }) {
    return NotificationPreference(
      userId: userId,
      messagesEnabled: messagesEnabled ?? this.messagesEnabled,
      mentionsEnabled: mentionsEnabled ?? this.mentionsEnabled,
      reactionsEnabled: reactionsEnabled ?? this.reactionsEnabled,
      friendRequestsEnabled:
          friendRequestsEnabled ?? this.friendRequestsEnabled,
      achievementsEnabled: achievementsEnabled ?? this.achievementsEnabled,
      leaderboardEnabled: leaderboardEnabled ?? this.leaderboardEnabled,
      groupUpdatesEnabled: groupUpdatesEnabled ?? this.groupUpdatesEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationsEnabled: vibrationsEnabled ?? this.vibrationsEnabled,
    );
  }
}

/// Typing indicator state
class TypingIndicator {
  final String conversationId;
  final String userId;
  final String userName;
  final DateTime startedAt;

  TypingIndicator({
    required this.conversationId,
    required this.userId,
    required this.userName,
    required this.startedAt,
  });

  bool get isExpired {
    return DateTime.now().difference(startedAt).inSeconds > 5;
  }

  factory TypingIndicator.fromMap(Map<String, dynamic> map) {
    return TypingIndicator(
      conversationId: map['conversationId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'User',
      startedAt: (map['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'userId': userId,
      'userName': userName,
      'startedAt': Timestamp.fromDate(startedAt),
    };
  }
}

/// Message search result
class MessageSearchResult {
  final Message message;
  final Conversation conversation;
  final int relevanceScore;

  MessageSearchResult({
    required this.message,
    required this.conversation,
    this.relevanceScore = 0,
  });
}
