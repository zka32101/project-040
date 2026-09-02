import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/messaging_model.dart';

/// Abstract messaging service interface
abstract class MessagingService {
  /// Direct Messaging
  Future<String> sendMessage(
    String userId,
    String recipientUserId,
    String content,
  );

  Future<Message?> getMessage(String messageId);
  Future<List<Message>> getConversationMessages(
    String conversationId, {
    int limit = 50,
  });

  Future<void> markMessageAsRead(String messageId, String userId);
  Future<void> markConversationAsRead(String conversationId, String userId);

  Future<void> editMessage(String messageId, String newContent);
  Future<void> deleteMessage(String messageId);

  /// Reactions
  Future<void> addReaction(String messageId, String emoji);
  Future<void> removeReaction(String messageId, String emoji);

  /// Conversations
  Future<String> getOrCreateDMConversation(
    String userId,
    String otherUserId,
  );

  Future<Conversation?> getConversation(String conversationId);
  Future<List<Conversation>> getUserConversations(String userId);

  Future<void> archiveConversation(String conversationId);
  Future<void> unarchiveConversation(String conversationId);
  Future<void> muteConversation(String conversationId);
  Future<void> unmuteConversation(String conversationId);

  /// Group Chat
  Future<String> createGroupConversation(
    String groupName,
    List<String> participantIds,
    String? description,
  );

  Future<void> addGroupParticipant(String conversationId, String userId);
  Future<void> removeGroupParticipant(String conversationId, String userId);
  Future<void> updateGroupInfo(
    String conversationId,
    String? groupName,
    String? description,
  );

  /// Notifications
  Future<void> sendNotification(Notification notification);
  Future<Notification?> getNotification(String notificationId);
  Future<List<Notification>> getUserNotifications(String userId);
  Future<List<Notification>> getUnreadNotifications(String userId);

  Future<void> markNotificationAsRead(String notificationId);
  Future<void> markAllNotificationsAsRead(String userId);
  Future<void> deleteNotification(String notificationId);

  /// Notification Preferences
  Future<NotificationPreference> getNotificationPreferences(String userId);
  Future<void> updateNotificationPreferences(
    NotificationPreference preferences,
  );

  /// Typing Indicators
  Future<void> setTypingIndicator(String conversationId, String userId);
  Future<void> clearTypingIndicator(String conversationId, String userId);
  Future<List<TypingIndicator>> getTypingIndicators(String conversationId);

  /// Search
  Future<List<MessageSearchResult>> searchMessages(
    String userId,
    String query, {
    String? conversationId,
  });

  /// Statistics
  Future<int> getUnreadMessageCount(String userId);
  Future<int> getUnreadNotificationCount(String userId);
}

/// Firebase implementation of messaging service
class FirebaseMessagingService implements MessagingService {
  final FirebaseFirestore _firestore;

  FirebaseMessagingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> sendMessage(
    String userId,
    String recipientUserId,
    String content,
  ) async {
    try {
      // Get or create DM conversation
      final conversationId =
          await getOrCreateDMConversation(userId, recipientUserId);

      // Create message
      final messageRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc();

      final message = Message(
        messageId: messageRef.id,
        conversationId: conversationId,
        senderId: userId,
        senderName: 'User',
        content: content,
        type: MessageType.text,
        createdAt: DateTime.now(),
      );

      await messageRef.set(message.toMap());

      // Update conversation last message
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessagePreview': content.length > 100
            ? content.substring(0, 100) + '...'
            : content,
      });

      return message.messageId;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<Message?> getMessage(String messageId) async {
    try {
      // Search for message across all conversations
      final result = await _firestore
          .collectionGroup('messages')
          .where(FieldPath.documentId, isEqualTo: messageId)
          .limit(1)
          .get();

      if (result.docs.isEmpty) return null;
      return Message.fromMap(result.docs.first.data());
    } catch (e) {
      throw Exception('Failed to get message: $e');
    }
  }

  @override
  Future<List<Message>> getConversationMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Message.fromMap(doc.data()))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      throw Exception('Failed to get conversation messages: $e');
    }
  }

  @override
  Future<void> markMessageAsRead(String messageId, String userId) async {
    try {
      final result = await _firestore
          .collectionGroup('messages')
          .where(FieldPath.documentId, isEqualTo: messageId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        final messageDoc = result.docs.first;
        await messageDoc.reference.update({
          'readBy': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  @override
  Future<void> markConversationAsRead(String conversationId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();

      for (final doc in snapshot.docs) {
        if (!doc.data()['readBy'].contains(userId)) {
          await doc.reference.update({
            'readBy': FieldValue.arrayUnion([userId]),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to mark conversation as read: $e');
    }
  }

  @override
  Future<void> editMessage(String messageId, String newContent) async {
    try {
      final result = await _firestore
          .collectionGroup('messages')
          .where(FieldPath.documentId, isEqualTo: messageId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        await result.docs.first.reference.update({
          'content': newContent,
          'editedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to edit message: $e');
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      final result = await _firestore
          .collectionGroup('messages')
          .where(FieldPath.documentId, isEqualTo: messageId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        await result.docs.first.reference.update({
          'isDeleted': true,
          'content': '[Message deleted]',
        });
      }
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  @override
  Future<void> addReaction(String messageId, String emoji) async {
    try {
      final result = await _firestore
          .collectionGroup('messages')
          .where(FieldPath.documentId, isEqualTo: messageId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        await result.docs.first.reference.update({
          'reactions.$emoji': FieldValue.increment(1),
        });
      }
    } catch (e) {
      throw Exception('Failed to add reaction: $e');
    }
  }

  @override
  Future<void> removeReaction(String messageId, String emoji) async {
    try {
      final result = await _firestore
          .collectionGroup('messages')
          .where(FieldPath.documentId, isEqualTo: messageId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        final currentCount =
            (result.docs.first.data()['reactions'][emoji] as int?) ?? 0;
        if (currentCount > 0) {
          await result.docs.first.reference.update({
            'reactions.$emoji': FieldValue.increment(-1),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to remove reaction: $e');
    }
  }

  @override
  Future<String> getOrCreateDMConversation(
    String userId,
    String otherUserId,
  ) async {
    try {
      // Check if DM exists
      final existing = await _firestore
          .collection('conversations')
          .where('type', isEqualTo: ConversationType.direct.index)
          .where('participantIds', arrayContains: userId)
          .where('participantIds', arrayContains: otherUserId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }

      // Create new DM conversation
      final ref = _firestore.collection('conversations').doc();
      final conversation = Conversation(
        conversationId: ref.id,
        type: ConversationType.direct,
        participantIds: [userId, otherUserId],
        createdAt: DateTime.now(),
      );

      await ref.set(conversation.toMap());
      return ref.id;
    } catch (e) {
      throw Exception('Failed to get or create DM conversation: $e');
    }
  }

  @override
  Future<Conversation?> getConversation(String conversationId) async {
    try {
      final doc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!doc.exists) return null;
      return Conversation.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get conversation: $e');
    }
  }

  @override
  Future<List<Conversation>> getUserConversations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: userId)
          .where('archivedAt', isNull: true)
          .orderBy('lastMessageAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              Conversation.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user conversations: $e');
    }
  }

  @override
  Future<void> archiveConversation(String conversationId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'archivedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to archive conversation: $e');
    }
  }

  @override
  Future<void> unarchiveConversation(String conversationId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'archivedAt': null,
      });
    } catch (e) {
      throw Exception('Failed to unarchive conversation: $e');
    }
  }

  @override
  Future<void> muteConversation(String conversationId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({'isMuted': true});
    } catch (e) {
      throw Exception('Failed to mute conversation: $e');
    }
  }

  @override
  Future<void> unmuteConversation(String conversationId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({'isMuted': false});
    } catch (e) {
      throw Exception('Failed to unmute conversation: $e');
    }
  }

  @override
  Future<String> createGroupConversation(
    String groupName,
    List<String> participantIds,
    String? description,
  ) async {
    try {
      final ref = _firestore.collection('conversations').doc();
      final conversation = Conversation(
        conversationId: ref.id,
        type: ConversationType.group,
        participantIds: participantIds,
        groupName: groupName,
        groupDescription: description,
        groupOwnerId: participantIds.first,
        createdAt: DateTime.now(),
      );

      await ref.set(conversation.toMap());
      return ref.id;
    } catch (e) {
      throw Exception('Failed to create group conversation: $e');
    }
  }

  @override
  Future<void> addGroupParticipant(String conversationId, String userId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'participantIds': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw Exception('Failed to add group participant: $e');
    }
  }

  @override
  Future<void> removeGroupParticipant(String conversationId, String userId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'participantIds': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw Exception('Failed to remove group participant: $e');
    }
  }

  @override
  Future<void> updateGroupInfo(
    String conversationId,
    String? groupName,
    String? description,
  ) async {
    try {
      final updates = <String, dynamic>{};
      if (groupName != null) updates['groupName'] = groupName;
      if (description != null) updates['groupDescription'] = description;

      if (updates.isNotEmpty) {
        await _firestore
            .collection('conversations')
            .doc(conversationId)
            .update(updates);
      }
    } catch (e) {
      throw Exception('Failed to update group info: $e');
    }
  }

  @override
  Future<void> sendNotification(Notification notification) async {
    try {
      final ref = _firestore
          .collection('users')
          .doc(notification.userId)
          .collection('notifications')
          .doc();

      final notif = notification.copyWith(
        notificationId: ref.id,
      );

      await ref.set(notif.toMap());
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  @override
  Future<Notification?> getNotification(String notificationId) async {
    try {
      final result = await _firestore
          .collectionGroup('notifications')
          .where(FieldPath.documentId, isEqualTo: notificationId)
          .limit(1)
          .get();

      if (result.docs.isEmpty) return null;
      return Notification.fromMap(result.docs.first.data());
    } catch (e) {
      throw Exception('Failed to get notification: $e');
    }
  }

  @override
  Future<List<Notification>> getUserNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) =>
              Notification.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user notifications: $e');
    }
  }

  @override
  Future<List<Notification>> getUnreadNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('status', isEqualTo: NotificationStatus.unread.index)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              Notification.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get unread notifications: $e');
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final result = await _firestore
          .collectionGroup('notifications')
          .where(FieldPath.documentId, isEqualTo: notificationId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        await result.docs.first.reference.update({
          'status': NotificationStatus.read.index,
        });
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('status', isEqualTo: NotificationStatus.unread.index)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.update({
          'status': NotificationStatus.read.index,
        });
      }
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final result = await _firestore
          .collectionGroup('notifications')
          .where(FieldPath.documentId, isEqualTo: notificationId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        await result.docs.first.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  @override
  Future<NotificationPreference> getNotificationPreferences(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .get();

      if (!doc.exists) {
        return NotificationPreference.empty(userId);
      }
      return NotificationPreference.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get notification preferences: $e');
    }
  }

  @override
  Future<void> updateNotificationPreferences(
    NotificationPreference preferences,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(preferences.userId)
          .collection('settings')
          .doc('notifications')
          .set(preferences.toMap());
    } catch (e) {
      throw Exception('Failed to update notification preferences: $e');
    }
  }

  @override
  Future<void> setTypingIndicator(String conversationId, String userId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('typing')
          .doc(userId)
          .set({
        'userId': userId,
        'startedAt': FieldValue.serverTimestamp(),
      });

      // Auto-clear after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        clearTypingIndicator(conversationId, userId);
      });
    } catch (e) {
      throw Exception('Failed to set typing indicator: $e');
    }
  }

  @override
  Future<void> clearTypingIndicator(String conversationId, String userId) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('typing')
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Failed to clear typing indicator: $e');
    }
  }

  @override
  Future<List<TypingIndicator>> getTypingIndicators(String conversationId) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('typing')
          .get();

      return snapshot.docs
          .map((doc) {
            try {
              return TypingIndicator.fromMap(doc.data());
            } catch (_) {
              return null;
            }
          })
          .whereType<TypingIndicator>()
          .where((indicator) => !indicator.isExpired)
          .toList();
    } catch (e) {
      throw Exception('Failed to get typing indicators: $e');
    }
  }

  @override
  Future<List<MessageSearchResult>> searchMessages(
    String userId,
    String query, {
    String? conversationId,
  }) async {
    try {
      Query<Map<String, dynamic>> collection = _firestore
          .collectionGroup('messages')
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThan: query + 'z');

      final snapshot = await collection.limit(20).get();
      final results = <MessageSearchResult>[];

      for (final doc in snapshot.docs) {
        final message = Message.fromMap(doc.data());
        final conv =
            await getConversation(message.conversationId);

        if (conv != null) {
          results.add(MessageSearchResult(
            message: message,
            conversation: conv,
          ));
        }
      }

      return results;
    } catch (e) {
      throw Exception('Failed to search messages: $e');
    }
  }

  @override
  Future<int> getUnreadMessageCount(String userId) async {
    try {
      final conversations = await getUserConversations(userId);
      int unreadCount = 0;

      for (final conv in conversations) {
        final messages = await getConversationMessages(conv.conversationId);
        for (final msg in messages) {
          if (!msg.readBy.contains(userId)) {
            unreadCount++;
          }
        }
      }

      return unreadCount;
    } catch (e) {
      throw Exception('Failed to get unread message count: $e');
    }
  }

  @override
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('status', isEqualTo: NotificationStatus.unread.index)
          .get();

      return snapshot.size;
    } catch (e) {
      throw Exception('Failed to get unread notification count: $e');
    }
  }

  Notification copyWith({String? notificationId}) {
    return Notification(
      notificationId: notificationId ?? '',
      userId: '',
      type: NotificationType.message,
      title: '',
      message: '',
      createdAt: DateTime.now(),
    );
  }
}

/// Stub implementation for testing
class StubMessagingService implements MessagingService {
  final Map<String, Message> _messages = {};
  final Map<String, Conversation> _conversations = {};
  final Map<String, List<Notification>> _notifications = {};
  final Map<String, NotificationPreference> _preferences = {};
  final Map<String, List<TypingIndicator>> _typingIndicators = {};

  @override
  Future<String> sendMessage(
    String userId,
    String recipientUserId,
    String content,
  ) async {
    final conversationId =
        await getOrCreateDMConversation(userId, recipientUserId);
    final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';

    final message = Message(
      messageId: messageId,
      conversationId: conversationId,
      senderId: userId,
      senderName: 'User',
      content: content,
      type: MessageType.text,
      createdAt: DateTime.now(),
    );

    _messages[messageId] = message;
    return messageId;
  }

  @override
  Future<Message?> getMessage(String messageId) async {
    return _messages[messageId];
  }

  @override
  Future<List<Message>> getConversationMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    return _messages.values
        .where((msg) => msg.conversationId == conversationId)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  @override
  Future<void> markMessageAsRead(String messageId, String userId) async {
    final message = _messages[messageId];
    if (message != null && !message.readBy.contains(userId)) {
      _messages[messageId] = message.copyWith(
        readBy: [...message.readBy, userId],
      );
    }
  }

  @override
  Future<void> markConversationAsRead(String conversationId, String userId) async {
    for (final msg in _messages.values
        .where((msg) => msg.conversationId == conversationId)) {
      if (!msg.readBy.contains(userId)) {
        _messages[msg.messageId] = msg.copyWith(
          readBy: [...msg.readBy, userId],
        );
      }
    }
  }

  @override
  Future<void> editMessage(String messageId, String newContent) async {
    final message = _messages[messageId];
    if (message != null) {
      _messages[messageId] = message.copyWith(content: newContent);
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    final message = _messages[messageId];
    if (message != null) {
      _messages[messageId] = Message(
        messageId: message.messageId,
        conversationId: message.conversationId,
        senderId: message.senderId,
        senderName: message.senderName,
        content: '[Message deleted]',
        type: message.type,
        createdAt: message.createdAt,
        isDeleted: true,
      );
    }
  }

  @override
  Future<void> addReaction(String messageId, String emoji) async {
    final message = _messages[messageId];
    if (message != null) {
      final reactions = Map<String, int>.from(message.reactions);
      reactions[emoji] = (reactions[emoji] ?? 0) + 1;
      _messages[messageId] = message.copyWith(reactions: reactions);
    }
  }

  @override
  Future<void> removeReaction(String messageId, String emoji) async {
    final message = _messages[messageId];
    if (message != null) {
      final reactions = Map<String, int>.from(message.reactions);
      if (reactions.containsKey(emoji) && reactions[emoji]! > 0) {
        reactions[emoji] = reactions[emoji]! - 1;
        if (reactions[emoji] == 0) {
          reactions.remove(emoji);
        }
        _messages[messageId] = message.copyWith(reactions: reactions);
      }
    }
  }

  @override
  Future<String> getOrCreateDMConversation(
    String userId,
    String otherUserId,
  ) async {
    final existing = _conversations.values
        .where((conv) =>
            conv.type == ConversationType.direct &&
            conv.participantIds.contains(userId) &&
            conv.participantIds.contains(otherUserId))
        .firstOrNull;

    if (existing != null) {
      return existing.conversationId;
    }

    final conversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
    final conversation = Conversation(
      conversationId: conversationId,
      type: ConversationType.direct,
      participantIds: [userId, otherUserId],
      createdAt: DateTime.now(),
    );

    _conversations[conversationId] = conversation;
    return conversationId;
  }

  @override
  Future<Conversation?> getConversation(String conversationId) async {
    return _conversations[conversationId];
  }

  @override
  Future<List<Conversation>> getUserConversations(String userId) async {
    return _conversations.values
        .where((conv) =>
            conv.participantIds.contains(userId) && !conv.isArchived)
        .toList();
  }

  @override
  Future<void> archiveConversation(String conversationId) async {
    final conv = _conversations[conversationId];
    if (conv != null) {
      _conversations[conversationId] = conv.copyWith(
        archivedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> unarchiveConversation(String conversationId) async {
    final conv = _conversations[conversationId];
    if (conv != null) {
      _conversations[conversationId] = conv.copyWith(archivedAt: null);
    }
  }

  @override
  Future<void> muteConversation(String conversationId) async {
    final conv = _conversations[conversationId];
    if (conv != null) {
      _conversations[conversationId] = conv.copyWith(isMuted: true);
    }
  }

  @override
  Future<void> unmuteConversation(String conversationId) async {
    final conv = _conversations[conversationId];
    if (conv != null) {
      _conversations[conversationId] = conv.copyWith(isMuted: false);
    }
  }

  @override
  Future<String> createGroupConversation(
    String groupName,
    List<String> participantIds,
    String? description,
  ) async {
    final conversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
    final conversation = Conversation(
      conversationId: conversationId,
      type: ConversationType.group,
      participantIds: participantIds,
      groupName: groupName,
      groupDescription: description,
      groupOwnerId: participantIds.first,
      createdAt: DateTime.now(),
    );

    _conversations[conversationId] = conversation;
    return conversationId;
  }

  @override
  Future<void> addGroupParticipant(String conversationId, String userId) async {
    final conv = _conversations[conversationId];
    if (conv != null && !conv.participantIds.contains(userId)) {
      _conversations[conversationId] = conv.copyWith(
        participantIds: [...conv.participantIds, userId],
      );
    }
  }

  @override
  Future<void> removeGroupParticipant(String conversationId, String userId) async {
    final conv = _conversations[conversationId];
    if (conv != null) {
      final updated = conv.participantIds.where((id) => id != userId).toList();
      _conversations[conversationId] = conv.copyWith(
        participantIds: updated,
      );
    }
  }

  @override
  Future<void> updateGroupInfo(
    String conversationId,
    String? groupName,
    String? description,
  ) async {
    final conv = _conversations[conversationId];
    if (conv != null) {
      _conversations[conversationId] = conv.copyWith(
        groupName: groupName,
        groupDescription: description,
      );
    }
  }

  @override
  Future<void> sendNotification(Notification notification) async {
    _notifications.putIfAbsent(notification.userId, () => []);
    _notifications[notification.userId]!.add(notification);
  }

  @override
  Future<Notification?> getNotification(String notificationId) async {
    for (final notifs in _notifications.values) {
      final notif =
          notifs.where((n) => n.notificationId == notificationId).firstOrNull;
      if (notif != null) return notif;
    }
    return null;
  }

  @override
  Future<List<Notification>> getUserNotifications(String userId) async {
    return _notifications[userId] ?? [];
  }

  @override
  Future<List<Notification>> getUnreadNotifications(String userId) async {
    return (_notifications[userId] ?? [])
        .where((n) => n.isUnread)
        .toList();
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    for (final notifs in _notifications.values) {
      final index =
          notifs.indexWhere((n) => n.notificationId == notificationId);
      if (index >= 0) {
        notifs[index] = Notification(
          notificationId: notifs[index].notificationId,
          userId: notifs[index].userId,
          type: notifs[index].type,
          title: notifs[index].title,
          message: notifs[index].message,
          status: NotificationStatus.read,
          createdAt: notifs[index].createdAt,
        );
        break;
      }
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
    final notifs = _notifications[userId];
    if (notifs != null) {
      for (int i = 0; i < notifs.length; i++) {
        if (notifs[i].isUnread) {
          notifs[i] = Notification(
            notificationId: notifs[i].notificationId,
            userId: notifs[i].userId,
            type: notifs[i].type,
            title: notifs[i].title,
            message: notifs[i].message,
            status: NotificationStatus.read,
            createdAt: notifs[i].createdAt,
          );
        }
      }
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    for (final notifs in _notifications.values) {
      notifs.removeWhere((n) => n.notificationId == notificationId);
    }
  }

  @override
  Future<NotificationPreference> getNotificationPreferences(String userId) async {
    return _preferences[userId] ?? NotificationPreference.empty(userId);
  }

  @override
  Future<void> updateNotificationPreferences(
    NotificationPreference preferences,
  ) async {
    _preferences[preferences.userId] = preferences;
  }

  @override
  Future<void> setTypingIndicator(String conversationId, String userId) async {
    _typingIndicators.putIfAbsent(conversationId, () => []);
    _typingIndicators[conversationId]!.removeWhere((t) => t.userId == userId);
    _typingIndicators[conversationId]!.add(
      TypingIndicator(
        conversationId: conversationId,
        userId: userId,
        userName: 'User',
        startedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> clearTypingIndicator(String conversationId, String userId) async {
    _typingIndicators[conversationId]
        ?.removeWhere((t) => t.userId == userId);
  }

  @override
  Future<List<TypingIndicator>> getTypingIndicators(String conversationId) async {
    return (_typingIndicators[conversationId] ?? [])
        .where((t) => !t.isExpired)
        .toList();
  }

  @override
  Future<List<MessageSearchResult>> searchMessages(
    String userId,
    String query, {
    String? conversationId,
  }) async {
    final results = <MessageSearchResult>[];
    for (final message in _messages.values) {
      if (message.content.contains(query) &&
          (conversationId == null ||
              message.conversationId == conversationId)) {
        final conv = _conversations[message.conversationId];
        if (conv != null) {
          results.add(MessageSearchResult(
            message: message,
            conversation: conv,
          ));
        }
      }
    }
    return results;
  }

  @override
  Future<int> getUnreadMessageCount(String userId) async {
    int count = 0;
    for (final message in _messages.values) {
      if (!message.readBy.contains(userId)) {
        count++;
      }
    }
    return count;
  }

  @override
  Future<int> getUnreadNotificationCount(String userId) async {
    return (_notifications[userId] ?? [])
        .where((n) => n.isUnread)
        .length;
  }
}
