import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/advanced_messaging_model.dart';

/// Abstract advanced messaging service interface
abstract class AdvancedMessagingService {
  /// Message Pinning
  Future<String> pinMessage(
    String messageId,
    String conversationId,
    String userId, {
    String? reason,
    PinPriority priority = PinPriority.normal,
  });

  Future<void> unpinMessage(String pinnedId);
  Future<PinnedMessage?> getPinnedMessage(String pinnedId);
  Future<List<PinnedMessage>> getConversationPinnedMessages(
    String conversationId, {
    int limit = 10,
  });

  Future<void> markPinnedMessageViewed(String pinnedId, String userId);

  /// Message Forwarding
  Future<String> forwardMessage(
    String messageId,
    String targetConversationId,
    String userId, {
    String? message,
  });

  Future<ForwardedMessage?> getForwardedMessage(String forwardedId);
  Future<List<ForwardedMessage>> getForwardHistory(String messageId);

  /// Message Threading
  Future<String> createThread(
    String messageId,
    String conversationId,
    String userId, {
    String? subject,
  });

  Future<MessageThread?> getThread(String threadId);
  Future<List<MessageThread>> getConversationThreads(String conversationId);
  Future<void> addThreadParticipant(String threadId, String userId);
  Future<void> removeThreadParticipant(String threadId, String userId);
  Future<void> resolveThread(String threadId);
  Future<void> archiveThread(String threadId);

  /// Rich Reactions
  Future<void> addRichReaction(
    String messageId,
    String userId,
    ReactionType type,
    String content, {
    String? label,
  });

  Future<void> removeRichReaction(String reactionId);
  Future<List<RichReaction>> getMessageReactions(String messageId);
  Future<int> getReactionCount(String messageId, String content);

  /// Message Bookmarks
  Future<String> bookmarkMessage(
    String messageId,
    String conversationId,
    String userId, {
    String? messagePreview,
    String? folder,
    List<String>? tags,
  });

  Future<void> unbookmarkMessage(String bookmarkId);
  Future<BookmarkedMessage?> getBookmark(String bookmarkId);
  Future<List<BookmarkedMessage>> getUserBookmarks(String userId);
  Future<List<BookmarkedMessage>> getBookmarksByFolder(
    String userId,
    String folder,
  );

  Future<void> updateBookmarkTags(String bookmarkId, List<String> tags);
  Future<void> moveBookmarkToFolder(String bookmarkId, String folder);

  /// Conversation Settings
  Future<ConversationSettings> getConversationSettings(
    String conversationId,
    String userId,
  );

  Future<void> updateConversationSettings(ConversationSettings settings);
  Future<void> setQuietHours(
    String conversationId,
    String userId,
    int startHour,
    int endHour,
  );

  Future<void> pinMember(String conversationId, String userId, String memberId);
  Future<void> unpinMember(String conversationId, String userId, String memberId);

  /// Advanced Messaging Stats
  Future<AdvancedMessagingStats> getStats(String conversationId);
  Future<void> updateStats(AdvancedMessagingStats stats);
}

/// Firebase implementation
class FirebaseAdvancedMessagingService implements AdvancedMessagingService {
  final FirebaseFirestore _firestore;

  FirebaseAdvancedMessagingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> pinMessage(
    String messageId,
    String conversationId,
    String userId, {
    String? reason,
    PinPriority priority = PinPriority.normal,
  }) async {
    try {
      final pinnedRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('pinnedMessages')
          .doc();

      final pinned = PinnedMessage(
        pinnedId: pinnedRef.id,
        messageId: messageId,
        conversationId: conversationId,
        pinnedBy: userId,
        pinnedReason: reason,
        priority: priority,
        createdAt: DateTime.now(),
      );

      await pinnedRef.set(pinned.toMap());

      // Update stats
      final statsRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('stats')
          .doc('advanced');

      await statsRef.update({
        'totalPinned': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return pinnedRef.id;
    } catch (e) {
      throw Exception('Failed to pin message: $e');
    }
  }

  @override
  Future<void> unpinMessage(String pinnedId) async {
    try {
      // Find and delete the pinned message
      final result = await _firestore
          .collectionGroup('pinnedMessages')
          .where(FieldPath.documentId, isEqualTo: pinnedId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        await result.docs.first.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to unpin message: $e');
    }
  }

  @override
  Future<PinnedMessage?> getPinnedMessage(String pinnedId) async {
    try {
      final result = await _firestore
          .collectionGroup('pinnedMessages')
          .where(FieldPath.documentId, isEqualTo: pinnedId)
          .limit(1)
          .get();

      if (result.docs.isEmpty) return null;
      return PinnedMessage.fromMap(result.docs.first.data());
    } catch (e) {
      throw Exception('Failed to get pinned message: $e');
    }
  }

  @override
  Future<List<PinnedMessage>> getConversationPinnedMessages(
    String conversationId, {
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('pinnedMessages')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PinnedMessage.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pinned messages: $e');
    }
  }

  @override
  Future<void> markPinnedMessageViewed(String pinnedId, String userId) async {
    try {
      final result = await _firestore
          .collectionGroup('pinnedMessages')
          .where(FieldPath.documentId, isEqualTo: pinnedId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        await result.docs.first.reference.update({
          'viewers': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      throw Exception('Failed to mark pinned message as viewed: $e');
    }
  }

  @override
  Future<String> forwardMessage(
    String messageId,
    String targetConversationId,
    String userId, {
    String? message,
  }) async {
    try {
      final forwardedRef = _firestore
          .collection('conversations')
          .doc(targetConversationId)
          .collection('forwardedMessages')
          .doc();

      final forwarded = ForwardedMessage(
        forwardedId: forwardedRef.id,
        originalMessageId: messageId,
        forwardedBy: userId,
        targetConversationId: targetConversationId,
        forwardMessage: message,
        forwardedAt: DateTime.now(),
        originalSenderName: 'User',
        originalSentAt: DateTime.now(),
      );

      await forwardedRef.set(forwarded.toMap());
      return forwardedRef.id;
    } catch (e) {
      throw Exception('Failed to forward message: $e');
    }
  }

  @override
  Future<ForwardedMessage?> getForwardedMessage(String forwardedId) async {
    try {
      final result = await _firestore
          .collectionGroup('forwardedMessages')
          .where(FieldPath.documentId, isEqualTo: forwardedId)
          .limit(1)
          .get();

      if (result.docs.isEmpty) return null;
      return ForwardedMessage.fromMap(result.docs.first.data());
    } catch (e) {
      throw Exception('Failed to get forwarded message: $e');
    }
  }

  @override
  Future<List<ForwardedMessage>> getForwardHistory(String messageId) async {
    try {
      final result = await _firestore
          .collectionGroup('forwardedMessages')
          .where('originalMessageId', isEqualTo: messageId)
          .orderBy('forwardedAt', descending: true)
          .get();

      return result.docs
          .map((doc) => ForwardedMessage.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get forward history: $e');
    }
  }

  @override
  Future<String> createThread(
    String messageId,
    String conversationId,
    String userId, {
    String? subject,
  }) async {
    try {
      final threadRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('threads')
          .doc();

      final thread = MessageThread(
        threadId: threadRef.id,
        conversationId: conversationId,
        rootMessageId: messageId,
        initiatedBy: userId,
        subject: subject,
        messageCount: 1,
        createdAt: DateTime.now(),
        participantIds: [userId],
      );

      await threadRef.set(thread.toMap());

      // Update stats
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('stats')
          .doc('advanced')
          .update({
        'activeThreads': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return threadRef.id;
    } catch (e) {
      throw Exception('Failed to create thread: $e');
    }
  }

  @override
  Future<MessageThread?> getThread(String threadId) async {
    try {
      final result = await _firestore
          .collectionGroup('threads')
          .where(FieldPath.documentId, isEqualTo: threadId)
          .limit(1)
          .get();

      if (result.docs.isEmpty) return null;
      return MessageThread.fromMap(result.docs.first.data());
    } catch (e) {
      throw Exception('Failed to get thread: $e');
    }
  }

  @override
  Future<List<MessageThread>> getConversationThreads(String conversationId) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('threads')
          .where('status', isEqualTo: ThreadStatus.active.index)
          .orderBy('lastReplyAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MessageThread.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get conversation threads: $e');
    }
  }

  @override
  Future<void> addThreadParticipant(String threadId, String userId) async {
    try {
      final result = await _firestore
          .collectionGroup('threads')
          .where(FieldPath.documentId, isEqualTo: threadId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        await result.docs.first.reference.update({
          'participantIds': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      throw Exception('Failed to add thread participant: $e');
    }
  }

  @override
  Future<void> removeThreadParticipant(String threadId, String userId) async {
    try {
      final result = await _firestore
          .collectionGroup('threads')
          .where(FieldPath.documentId, isEqualTo: threadId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        await result.docs.first.reference.update({
          'participantIds': FieldValue.arrayRemove([userId]),
        });
      }
    } catch (e) {
      throw Exception('Failed to remove thread participant: $e');
    }
  }

  @override
  Future<void> resolveThread(String threadId) async {
    try {
      final result = await _firestore
          .collectionGroup('threads')
          .where(FieldPath.documentId, isEqualTo: threadId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        await result.docs.first.reference.update({
          'status': ThreadStatus.resolved.index,
        });
      }
    } catch (e) {
      throw Exception('Failed to resolve thread: $e');
    }
  }

  @override
  Future<void> archiveThread(String threadId) async {
    try {
      final result = await _firestore
          .collectionGroup('threads')
          .where(FieldPath.documentId, isEqualTo: threadId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        await result.docs.first.reference.update({
          'status': ThreadStatus.archived.index,
        });
      }
    } catch (e) {
      throw Exception('Failed to archive thread: $e');
    }
  }

  @override
  Future<void> addRichReaction(
    String messageId,
    String userId,
    ReactionType type,
    String content, {
    String? label,
  }) async {
    try {
      final reactionRef = _firestore
          .collectionGroup('messages')
          .doc(messageId)
          .collection('reactions')
          .doc();

      final reaction = RichReaction(
        reactionId: reactionRef.id,
        messageId: messageId,
        userId: userId,
        type: type,
        content: content,
        label: label,
        createdAt: DateTime.now(),
      );

      await reactionRef.set(reaction.toMap());
    } catch (e) {
      throw Exception('Failed to add rich reaction: $e');
    }
  }

  @override
  Future<void> removeRichReaction(String reactionId) async {
    try {
      final result = await _firestore
          .collectionGroup('reactions')
          .where(FieldPath.documentId, isEqualTo: reactionId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        await result.docs.first.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to remove rich reaction: $e');
    }
  }

  @override
  Future<List<RichReaction>> getMessageReactions(String messageId) async {
    try {
      final snapshot = await _firestore
          .collectionGroup('reactions')
          .where('messageId', isEqualTo: messageId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RichReaction.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get message reactions: $e');
    }
  }

  @override
  Future<int> getReactionCount(String messageId, String content) async {
    try {
      final snapshot = await _firestore
          .collectionGroup('reactions')
          .where('messageId', isEqualTo: messageId)
          .where('content', isEqualTo: content)
          .get();

      return snapshot.size;
    } catch (e) {
      throw Exception('Failed to get reaction count: $e');
    }
  }

  @override
  Future<String> bookmarkMessage(
    String messageId,
    String conversationId,
    String userId, {
    String? messagePreview,
    String? folder,
    List<String>? tags,
  }) async {
    try {
      final bookmarkRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .doc();

      final bookmark = BookmarkedMessage(
        bookmarkId: bookmarkRef.id,
        messageId: messageId,
        userId: userId,
        conversationId: conversationId,
        messagePreview: messagePreview,
        folder: folder,
        tags: tags ?? [],
        bookmarkedAt: DateTime.now(),
      );

      await bookmarkRef.set(bookmark.toMap());
      return bookmarkRef.id;
    } catch (e) {
      throw Exception('Failed to bookmark message: $e');
    }
  }

  @override
  Future<void> unbookmarkMessage(String bookmarkId) async {
    try {
      final result = await _firestore
          .collectionGroup('bookmarks')
          .where(FieldPath.documentId, isEqualTo: bookmarkId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        await result.docs.first.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to unbookmark message: $e');
    }
  }

  @override
  Future<BookmarkedMessage?> getBookmark(String bookmarkId) async {
    try {
      final result = await _firestore
          .collectionGroup('bookmarks')
          .where(FieldPath.documentId, isEqualTo: bookmarkId)
          .limit(1)
          .get();

      if (result.docs.isEmpty) return null;
      return BookmarkedMessage.fromMap(result.docs.first.data());
    } catch (e) {
      throw Exception('Failed to get bookmark: $e');
    }
  }

  @override
  Future<List<BookmarkedMessage>> getUserBookmarks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .orderBy('bookmarkedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BookmarkedMessage.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user bookmarks: $e');
    }
  }

  @override
  Future<List<BookmarkedMessage>> getBookmarksByFolder(
    String userId,
    String folder,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bookmarks')
          .where('folder', isEqualTo: folder)
          .orderBy('bookmarkedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BookmarkedMessage.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get bookmarks by folder: $e');
    }
  }

  @override
  Future<void> updateBookmarkTags(String bookmarkId, List<String> tags) async {
    try {
      final result = await _firestore
          .collectionGroup('bookmarks')
          .where(FieldPath.documentId, isEqualTo: bookmarkId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        await result.docs.first.reference.update({'tags': tags});
      }
    } catch (e) {
      throw Exception('Failed to update bookmark tags: $e');
    }
  }

  @override
  Future<void> moveBookmarkToFolder(String bookmarkId, String folder) async {
    try {
      final result = await _firestore
          .collectionGroup('bookmarks')
          .where(FieldPath.documentId, isEqualTo: bookmarkId)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        await result.docs.first.reference.update({'folder': folder});
      }
    } catch (e) {
      throw Exception('Failed to move bookmark to folder: $e');
    }
  }

  @override
  Future<ConversationSettings> getConversationSettings(
    String conversationId,
    String userId,
  ) async {
    try {
      final doc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('settings')
          .doc(userId)
          .get();

      if (!doc.exists) {
        return ConversationSettings.empty(conversationId, userId);
      }
      return ConversationSettings.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get conversation settings: $e');
    }
  }

  @override
  Future<void> updateConversationSettings(ConversationSettings settings) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(settings.conversationId)
          .collection('settings')
          .doc(settings.userId)
          .set(settings.toMap());
    } catch (e) {
      throw Exception('Failed to update conversation settings: $e');
    }
  }

  @override
  Future<void> setQuietHours(
    String conversationId,
    String userId,
    int startHour,
    int endHour,
  ) async {
    try {
      var settings =
          await getConversationSettings(conversationId, userId);
      settings = settings.copyWith(
        notificationQuietHoursStart: startHour,
        notificationQuietHoursEnd: endHour,
      );
      await updateConversationSettings(settings);
    } catch (e) {
      throw Exception('Failed to set quiet hours: $e');
    }
  }

  @override
  Future<void> pinMember(
    String conversationId,
    String userId,
    String memberId,
  ) async {
    try {
      var settings = await getConversationSettings(conversationId, userId);
      if (!settings.pinnedMemberIds.contains(memberId)) {
        settings = settings.copyWith(
          pinnedMemberIds: [...settings.pinnedMemberIds, memberId],
        );
        await updateConversationSettings(settings);
      }
    } catch (e) {
      throw Exception('Failed to pin member: $e');
    }
  }

  @override
  Future<void> unpinMember(
    String conversationId,
    String userId,
    String memberId,
  ) async {
    try {
      var settings = await getConversationSettings(conversationId, userId);
      settings = settings.copyWith(
        pinnedMemberIds: settings.pinnedMemberIds
            .where((id) => id != memberId)
            .toList(),
      );
      await updateConversationSettings(settings);
    } catch (e) {
      throw Exception('Failed to unpin member: $e');
    }
  }

  @override
  Future<AdvancedMessagingStats> getStats(String conversationId) async {
    try {
      final doc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('stats')
          .doc('advanced')
          .get();

      if (!doc.exists) {
        return AdvancedMessagingStats.empty(conversationId);
      }
      return AdvancedMessagingStats.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get stats: $e');
    }
  }

  @override
  Future<void> updateStats(AdvancedMessagingStats stats) async {
    try {
      await _firestore
          .collection('conversations')
          .doc(stats.conversationId)
          .collection('stats')
          .doc('advanced')
          .set(stats.toMap());
    } catch (e) {
      throw Exception('Failed to update stats: $e');
    }
  }
}

/// Stub implementation for testing
class StubAdvancedMessagingService implements AdvancedMessagingService {
  final Map<String, PinnedMessage> _pinned = {};
  final Map<String, ForwardedMessage> _forwarded = {};
  final Map<String, MessageThread> _threads = {};
  final Map<String, RichReaction> _reactions = {};
  final Map<String, BookmarkedMessage> _bookmarks = {};
  final Map<String, ConversationSettings> _settings = {};
  final Map<String, AdvancedMessagingStats> _stats = {};

  @override
  Future<String> pinMessage(
    String messageId,
    String conversationId,
    String userId, {
    String? reason,
    PinPriority priority = PinPriority.normal,
  }) async {
    final pinnedId = 'pin_${DateTime.now().millisecondsSinceEpoch}';
    _pinned[pinnedId] = PinnedMessage(
      pinnedId: pinnedId,
      messageId: messageId,
      conversationId: conversationId,
      pinnedBy: userId,
      pinnedReason: reason,
      priority: priority,
      createdAt: DateTime.now(),
    );
    return pinnedId;
  }

  @override
  Future<void> unpinMessage(String pinnedId) async {
    _pinned.remove(pinnedId);
  }

  @override
  Future<PinnedMessage?> getPinnedMessage(String pinnedId) async {
    return _pinned[pinnedId];
  }

  @override
  Future<List<PinnedMessage>> getConversationPinnedMessages(
    String conversationId, {
    int limit = 10,
  }) async {
    return _pinned.values
        .where((p) => p.conversationId == conversationId)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  @override
  Future<void> markPinnedMessageViewed(String pinnedId, String userId) async {
    final pinned = _pinned[pinnedId];
    if (pinned != null && !pinned.viewers.contains(userId)) {
      _pinned[pinnedId] = PinnedMessage(
        pinnedId: pinned.pinnedId,
        messageId: pinned.messageId,
        conversationId: pinned.conversationId,
        pinnedBy: pinned.pinnedBy,
        pinnedReason: pinned.pinnedReason,
        priority: pinned.priority,
        createdAt: pinned.createdAt,
        viewers: [...pinned.viewers, userId],
      );
    }
  }

  @override
  Future<String> forwardMessage(
    String messageId,
    String targetConversationId,
    String userId, {
    String? message,
  }) async {
    final forwardedId = 'fwd_${DateTime.now().millisecondsSinceEpoch}';
    _forwarded[forwardedId] = ForwardedMessage(
      forwardedId: forwardedId,
      originalMessageId: messageId,
      forwardedBy: userId,
      targetConversationId: targetConversationId,
      forwardMessage: message,
      forwardedAt: DateTime.now(),
      originalSenderName: 'User',
      originalSentAt: DateTime.now(),
    );
    return forwardedId;
  }

  @override
  Future<ForwardedMessage?> getForwardedMessage(String forwardedId) async {
    return _forwarded[forwardedId];
  }

  @override
  Future<List<ForwardedMessage>> getForwardHistory(String messageId) async {
    return _forwarded.values
        .where((f) => f.originalMessageId == messageId)
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<String> createThread(
    String messageId,
    String conversationId,
    String userId, {
    String? subject,
  }) async {
    final threadId = 'thread_${DateTime.now().millisecondsSinceEpoch}';
    _threads[threadId] = MessageThread(
      threadId: threadId,
      conversationId: conversationId,
      rootMessageId: messageId,
      initiatedBy: userId,
      subject: subject,
      messageCount: 1,
      createdAt: DateTime.now(),
      participantIds: [userId],
    );
    return threadId;
  }

  @override
  Future<MessageThread?> getThread(String threadId) async {
    return _threads[threadId];
  }

  @override
  Future<List<MessageThread>> getConversationThreads(String conversationId) async {
    return _threads.values
        .where((t) =>
            t.conversationId == conversationId && t.isActive)
        .toList();
  }

  @override
  Future<void> addThreadParticipant(String threadId, String userId) async {
    final thread = _threads[threadId];
    if (thread != null && !thread.participantIds.contains(userId)) {
      _threads[threadId] = thread.copyWith(
        participantIds: [...thread.participantIds, userId],
      );
    }
  }

  @override
  Future<void> removeThreadParticipant(String threadId, String userId) async {
    final thread = _threads[threadId];
    if (thread != null) {
      _threads[threadId] = thread.copyWith(
        participantIds:
            thread.participantIds.where((id) => id != userId).toList(),
      );
    }
  }

  @override
  Future<void> resolveThread(String threadId) async {
    final thread = _threads[threadId];
    if (thread != null) {
      _threads[threadId] = thread.copyWith(status: ThreadStatus.resolved);
    }
  }

  @override
  Future<void> archiveThread(String threadId) async {
    final thread = _threads[threadId];
    if (thread != null) {
      _threads[threadId] = thread.copyWith(status: ThreadStatus.archived);
    }
  }

  @override
  Future<void> addRichReaction(
    String messageId,
    String userId,
    ReactionType type,
    String content, {
    String? label,
  }) async {
    final reactionId = 'rxn_${DateTime.now().millisecondsSinceEpoch}';
    _reactions[reactionId] = RichReaction(
      reactionId: reactionId,
      messageId: messageId,
      userId: userId,
      type: type,
      content: content,
      label: label,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> removeRichReaction(String reactionId) async {
    _reactions.remove(reactionId);
  }

  @override
  Future<List<RichReaction>> getMessageReactions(String messageId) async {
    return _reactions.values
        .where((r) => r.messageId == messageId)
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<int> getReactionCount(String messageId, String content) async {
    return _reactions.values
        .where((r) =>
            r.messageId == messageId && r.content == content)
        .length;
  }

  @override
  Future<String> bookmarkMessage(
    String messageId,
    String conversationId,
    String userId, {
    String? messagePreview,
    String? folder,
    List<String>? tags,
  }) async {
    final bookmarkId = 'bm_${DateTime.now().millisecondsSinceEpoch}';
    _bookmarks[bookmarkId] = BookmarkedMessage(
      bookmarkId: bookmarkId,
      messageId: messageId,
      userId: userId,
      conversationId: conversationId,
      messagePreview: messagePreview,
      folder: folder,
      tags: tags ?? [],
      bookmarkedAt: DateTime.now(),
    );
    return bookmarkId;
  }

  @override
  Future<void> unbookmarkMessage(String bookmarkId) async {
    _bookmarks.remove(bookmarkId);
  }

  @override
  Future<BookmarkedMessage?> getBookmark(String bookmarkId) async {
    return _bookmarks[bookmarkId];
  }

  @override
  Future<List<BookmarkedMessage>> getUserBookmarks(String userId) async {
    return _bookmarks.values
        .where((b) => b.userId == userId)
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<List<BookmarkedMessage>> getBookmarksByFolder(
    String userId,
    String folder,
  ) async {
    return _bookmarks.values
        .where((b) => b.userId == userId && b.folder == folder)
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<void> updateBookmarkTags(String bookmarkId, List<String> tags) async {
    final bookmark = _bookmarks[bookmarkId];
    if (bookmark != null) {
      _bookmarks[bookmarkId] = bookmark.copyWith(tags: tags);
    }
  }

  @override
  Future<void> moveBookmarkToFolder(String bookmarkId, String folder) async {
    final bookmark = _bookmarks[bookmarkId];
    if (bookmark != null) {
      _bookmarks[bookmarkId] = bookmark.copyWith(folder: folder);
    }
  }

  @override
  Future<ConversationSettings> getConversationSettings(
    String conversationId,
    String userId,
  ) async {
    final key = '$conversationId:$userId';
    return _settings[key] ?? ConversationSettings.empty(conversationId, userId);
  }

  @override
  Future<void> updateConversationSettings(ConversationSettings settings) async {
    final key = '${settings.conversationId}:${settings.userId}';
    _settings[key] = settings;
  }

  @override
  Future<void> setQuietHours(
    String conversationId,
    String userId,
    int startHour,
    int endHour,
  ) async {
    var settings = await getConversationSettings(conversationId, userId);
    settings = settings.copyWith(
      notificationQuietHoursStart: startHour,
      notificationQuietHoursEnd: endHour,
    );
    await updateConversationSettings(settings);
  }

  @override
  Future<void> pinMember(
    String conversationId,
    String userId,
    String memberId,
  ) async {
    var settings = await getConversationSettings(conversationId, userId);
    if (!settings.pinnedMemberIds.contains(memberId)) {
      settings = settings.copyWith(
        pinnedMemberIds: [...settings.pinnedMemberIds, memberId],
      );
      await updateConversationSettings(settings);
    }
  }

  @override
  Future<void> unpinMember(
    String conversationId,
    String userId,
    String memberId,
  ) async {
    var settings = await getConversationSettings(conversationId, userId);
    settings = settings.copyWith(
      pinnedMemberIds:
          settings.pinnedMemberIds.where((id) => id != memberId).toList(),
    );
    await updateConversationSettings(settings);
  }

  @override
  Future<AdvancedMessagingStats> getStats(String conversationId) async {
    return _stats[conversationId] ??
        AdvancedMessagingStats.empty(conversationId);
  }

  @override
  Future<void> updateStats(AdvancedMessagingStats stats) async {
    _stats[stats.conversationId] = stats;
  }
}
