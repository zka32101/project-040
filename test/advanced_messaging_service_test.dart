import 'package:flutter_test/flutter_test.dart';
import '../lib/models/advanced_messaging_model.dart';
import '../lib/services/advanced_messaging_service.dart';

void main() {
  late AdvancedMessagingService service;

  setUp(() {
    service = StubAdvancedMessagingService();
  });

  group('Message Pinning', () {
    test('Pin message creates pinned message', () async {
      final pinnedId = await service.pinMessage(
        'msg1',
        'conv1',
        'user1',
        reason: 'Important announcement',
      );

      expect(pinnedId, isNotEmpty);
      final pinned = await service.getPinnedMessage(pinnedId);
      expect(pinned, isNotNull);
      expect(pinned!.messageId, equals('msg1'));
    });

    test('Pinned message has priority', () async {
      final pinnedId = await service.pinMessage(
        'msg1',
        'conv1',
        'user1',
        priority: PinPriority.urgent,
      );

      final pinned = await service.getPinnedMessage(pinnedId);
      expect(pinned!.priority, equals(PinPriority.urgent));
    });

    test('Unpin message removes pinned message', () async {
      final pinnedId = await service.pinMessage('msg1', 'conv1', 'user1');

      await service.unpinMessage(pinnedId);
      final pinned = await service.getPinnedMessage(pinnedId);
      expect(pinned, isNull);
    });

    test('Get conversation pinned messages', () async {
      await service.pinMessage('msg1', 'conv1', 'user1');
      await service.pinMessage('msg2', 'conv1', 'user1');
      await service.pinMessage('msg3', 'conv2', 'user1');

      final pinned =
          await service.getConversationPinnedMessages('conv1');
      expect(pinned.length, equals(2));
      expect(pinned.every((p) => p.conversationId == 'conv1'), true);
    });

    test('Mark pinned message as viewed', () async {
      final pinnedId = await service.pinMessage('msg1', 'conv1', 'user1');

      await service.markPinnedMessageViewed(pinnedId, 'user2');
      final pinned = await service.getPinnedMessage(pinnedId);
      expect(pinned!.viewers, contains('user2'));
    });

    test('Multiple users can view pinned message', () async {
      final pinnedId = await service.pinMessage('msg1', 'conv1', 'user1');

      await service.markPinnedMessageViewed(pinnedId, 'user2');
      await service.markPinnedMessageViewed(pinnedId, 'user3');

      final pinned = await service.getPinnedMessage(pinnedId);
      expect(pinned!.viewerCount, equals(2));
    });

    test('Pinned message respects limit', () async {
      for (int i = 0; i < 20; i++) {
        await service.pinMessage('msg$i', 'conv1', 'user1');
      }

      final pinned = await service.getConversationPinnedMessages(
        'conv1',
        limit: 5,
      );
      expect(pinned.length, equals(5));
    });
  });

  group('Message Forwarding', () {
    test('Forward message creates forwarded message', () async {
      final forwardedId = await service.forwardMessage(
        'msg1',
        'conv2',
        'user1',
        message: 'Check this out!',
      );

      expect(forwardedId, isNotEmpty);
      final forwarded = await service.getForwardedMessage(forwardedId);
      expect(forwarded, isNotNull);
      expect(forwarded!.originalMessageId, equals('msg1'));
    });

    test('Forwarded message has metadata', () async {
      final forwardedId = await service.forwardMessage(
        'msg1',
        'conv2',
        'alice',
      );

      final forwarded = await service.getForwardedMessage(forwardedId);
      expect(forwarded!.forwardedBy, equals('alice'));
      expect(forwarded.targetConversationId, equals('conv2'));
    });

    test('Get forward history for message', () async {
      await service.forwardMessage('msg1', 'conv2', 'user1');
      await service.forwardMessage('msg1', 'conv3', 'user1');
      await service.forwardMessage('msg2', 'conv2', 'user1');

      final history = await service.getForwardHistory('msg1');
      expect(history.length, equals(2));
      expect(history.every((f) => f.originalMessageId == 'msg1'), true);
    });

    test('Forward message multiple times', () async {
      for (int i = 0; i < 5; i++) {
        await service.forwardMessage('msg1', 'conv$i', 'user1');
      }

      final history = await service.getForwardHistory('msg1');
      expect(history.length, equals(5));
    });
  });

  group('Message Threading', () {
    test('Create thread for message', () async {
      final threadId = await service.createThread(
        'msg1',
        'conv1',
        'user1',
        subject: 'License exam tips',
      );

      expect(threadId, isNotEmpty);
      final thread = await service.getThread(threadId);
      expect(thread, isNotNull);
      expect(thread!.subject, equals('License exam tips'));
    });

    test('Thread has creator as participant', () async {
      final threadId = await service.createThread(
        'msg1',
        'conv1',
        'user1',
      );

      final thread = await service.getThread(threadId);
      expect(thread!.participantIds, contains('user1'));
    });

    test('Add participant to thread', () async {
      final threadId = await service.createThread(
        'msg1',
        'conv1',
        'user1',
      );

      await service.addThreadParticipant(threadId, 'user2');
      final thread = await service.getThread(threadId);
      expect(thread!.participantIds, contains('user2'));
    });

    test('Remove participant from thread', () async {
      final threadId = await service.createThread(
        'msg1',
        'conv1',
        'user1',
      );

      await service.addThreadParticipant(threadId, 'user2');
      await service.removeThreadParticipant(threadId, 'user1');

      final thread = await service.getThread(threadId);
      expect(thread!.participantIds, isNot(contains('user1')));
    });

    test('Resolve thread changes status', () async {
      final threadId = await service.createThread(
        'msg1',
        'conv1',
        'user1',
      );

      await service.resolveThread(threadId);
      final thread = await service.getThread(threadId);
      expect(thread!.status, equals(ThreadStatus.resolved));
    });

    test('Archive thread changes status', () async {
      final threadId = await service.createThread(
        'msg1',
        'conv1',
        'user1',
      );

      await service.archiveThread(threadId);
      final thread = await service.getThread(threadId);
      expect(thread!.status, equals(ThreadStatus.archived));
    });

    test('Get active conversation threads only', () async {
      final thread1 = await service.createThread('msg1', 'conv1', 'user1');
      final thread2 = await service.createThread('msg2', 'conv1', 'user1');

      await service.resolveThread(thread1);

      final threads = await service.getConversationThreads('conv1');
      expect(
        threads.where((t) => t.status == ThreadStatus.active).length,
        equals(1),
      );
    });

    test('Thread has reply count', () async {
      final threadId = await service.createThread(
        'msg1',
        'conv1',
        'user1',
      );

      final thread = await service.getThread(threadId);
      expect(thread!.hasReplies, false);
    });
  });

  group('Rich Reactions', () {
    test('Add emoji reaction', () async {
      await service.addRichReaction(
        'msg1',
        'user1',
        ReactionType.emoji,
        '👍',
      );

      final reactions = await service.getMessageReactions('msg1');
      expect(reactions.isNotEmpty, true);
      expect(reactions.first.content, equals('👍'));
    });

    test('Add sticker reaction', () async {
      await service.addRichReaction(
        'msg1',
        'user1',
        ReactionType.sticker,
        'sticker_123',
        label: 'Thumbs up',
      );

      final reactions = await service.getMessageReactions('msg1');
      expect(reactions.first.type, equals(ReactionType.sticker));
      expect(reactions.first.label, equals('Thumbs up'));
    });

    test('Add GIF reaction', () async {
      await service.addRichReaction(
        'msg1',
        'user1',
        ReactionType.gif,
        'https://giphy.com/gifs/...',
      );

      final reactions = await service.getMessageReactions('msg1');
      expect(reactions.first.type, equals(ReactionType.gif));
    });

    test('Remove reaction', () async {
      await service.addRichReaction(
        'msg1',
        'user1',
        ReactionType.emoji,
        '👍',
      );

      final reactions = await service.getMessageReactions('msg1');
      final reactionId = reactions.first.reactionId;

      await service.removeRichReaction(reactionId);
      final updatedReactions = await service.getMessageReactions('msg1');
      expect(updatedReactions.isEmpty, true);
    });

    test('Get reaction count for content', () async {
      await service.addRichReaction(
        'msg1',
        'user1',
        ReactionType.emoji,
        '👍',
      );
      await service.addRichReaction(
        'msg1',
        'user2',
        ReactionType.emoji,
        '👍',
      );

      final count =
          await service.getReactionCount('msg1', '👍');
      expect(count, equals(2));
    });

    test('Multiple reactions to same message', () async {
      await service.addRichReaction('msg1', 'user1', ReactionType.emoji, '👍');
      await service.addRichReaction('msg1', 'user2', ReactionType.emoji, '❤️');
      await service.addRichReaction(
        'msg1',
        'user3',
        ReactionType.sticker,
        'sticker_123',
      );

      final reactions = await service.getMessageReactions('msg1');
      expect(reactions.length, equals(3));
    });
  });

  group('Message Bookmarks', () {
    test('Bookmark message', () async {
      final bookmarkId = await service.bookmarkMessage(
        'msg1',
        'conv1',
        'user1',
        messagePreview: 'Important tips...',
      );

      expect(bookmarkId, isNotEmpty);
      final bookmark = await service.getBookmark(bookmarkId);
      expect(bookmark, isNotNull);
      expect(bookmark!.messageId, equals('msg1'));
    });

    test('Bookmark with folder', () async {
      final bookmarkId = await service.bookmarkMessage(
        'msg1',
        'conv1',
        'user1',
        folder: 'Study Tips',
      );

      final bookmark = await service.getBookmark(bookmarkId);
      expect(bookmark!.folder, equals('Study Tips'));
    });

    test('Bookmark with tags', () async {
      final bookmarkId = await service.bookmarkMessage(
        'msg1',
        'conv1',
        'user1',
        tags: ['important', 'rules', 'remember'],
      );

      final bookmark = await service.getBookmark(bookmarkId);
      expect(bookmark!.tags.length, equals(3));
    });

    test('Unbookmark message', () async {
      final bookmarkId = await service.bookmarkMessage(
        'msg1',
        'conv1',
        'user1',
      );

      await service.unbookmarkMessage(bookmarkId);
      final bookmark = await service.getBookmark(bookmarkId);
      expect(bookmark, isNull);
    });

    test('Get user bookmarks', () async {
      await service.bookmarkMessage('msg1', 'conv1', 'user1');
      await service.bookmarkMessage('msg2', 'conv1', 'user1');
      await service.bookmarkMessage('msg3', 'conv1', 'user2');

      final bookmarks = await service.getUserBookmarks('user1');
      expect(bookmarks.length, equals(2));
    });

    test('Get bookmarks by folder', () async {
      await service.bookmarkMessage(
        'msg1',
        'conv1',
        'user1',
        folder: 'Tips',
      );
      await service.bookmarkMessage(
        'msg2',
        'conv1',
        'user1',
        folder: 'Questions',
      );
      await service.bookmarkMessage(
        'msg3',
        'conv1',
        'user1',
        folder: 'Tips',
      );

      final bookmarks =
          await service.getBookmarksByFolder('user1', 'Tips');
      expect(bookmarks.length, equals(2));
    });

    test('Update bookmark tags', () async {
      final bookmarkId = await service.bookmarkMessage(
        'msg1',
        'conv1',
        'user1',
        tags: ['old'],
      );

      await service.updateBookmarkTags(
        bookmarkId,
        ['new', 'tags', 'here'],
      );

      final bookmark = await service.getBookmark(bookmarkId);
      expect(bookmark!.tags, contains('new'));
      expect(bookmark.tags, isNot(contains('old')));
    });

    test('Move bookmark to folder', () async {
      final bookmarkId = await service.bookmarkMessage(
        'msg1',
        'conv1',
        'user1',
        folder: 'Old Folder',
      );

      await service.moveBookmarkToFolder(bookmarkId, 'New Folder');
      final bookmark = await service.getBookmark(bookmarkId);
      expect(bookmark!.folder, equals('New Folder'));
    });
  });

  group('Conversation Settings', () {
    test('Get default conversation settings', () async {
      final settings =
          await service.getConversationSettings('conv1', 'user1');

      expect(settings.conversationId, equals('conv1'));
      expect(settings.notificationsEnabled, true);
      expect(settings.allowReactions, true);
    });

    test('Update conversation settings', () async {
      var settings =
          await service.getConversationSettings('conv1', 'user1');
      settings = settings.copyWith(notificationsEnabled: false);

      await service.updateConversationSettings(settings);

      final updated =
          await service.getConversationSettings('conv1', 'user1');
      expect(updated.notificationsEnabled, false);
    });

    test('Set quiet hours', () async {
      await service.setQuietHours('conv1', 'user1', 22, 8);

      final settings =
          await service.getConversationSettings('conv1', 'user1');
      expect(settings.notificationQuietHoursStart, equals(22));
      expect(settings.notificationQuietHoursEnd, equals(8));
      expect(settings.hasQuietHours, true);
    });

    test('Pin member in conversation', () async {
      await service.pinMember('conv1', 'user1', 'friend1');

      final settings =
          await service.getConversationSettings('conv1', 'user1');
      expect(settings.pinnedMemberIds, contains('friend1'));
    });

    test('Unpin member from conversation', () async {
      await service.pinMember('conv1', 'user1', 'friend1');
      await service.unpinMember('conv1', 'user1', 'friend1');

      final settings =
          await service.getConversationSettings('conv1', 'user1');
      expect(settings.pinnedMemberIds, isNot(contains('friend1')));
    });

    test('Multiple pinned members', () async {
      await service.pinMember('conv1', 'user1', 'friend1');
      await service.pinMember('conv1', 'user1', 'friend2');
      await service.pinMember('conv1', 'user1', 'friend3');

      final settings =
          await service.getConversationSettings('conv1', 'user1');
      expect(settings.pinnedMemberIds.length, equals(3));
    });

    test('Disable reactions in conversation', () async {
      var settings =
          await service.getConversationSettings('conv1', 'user1');
      settings = settings.copyWith(allowReactions: false);

      await service.updateConversationSettings(settings);

      final updated =
          await service.getConversationSettings('conv1', 'user1');
      expect(updated.allowReactions, false);
      expect(updated.allowForwarding, true);
    });

    test('Disable threading in conversation', () async {
      var settings =
          await service.getConversationSettings('conv1', 'user1');
      settings = settings.copyWith(allowThreading: false);

      await service.updateConversationSettings(settings);

      final updated =
          await service.getConversationSettings('conv1', 'user1');
      expect(updated.allowThreading, false);
    });

    test('Set theme color for conversation', () async {
      var settings =
          await service.getConversationSettings('conv1', 'user1');
      settings = settings.copyWith(themeColor: '#FF5733');

      await service.updateConversationSettings(settings);

      final updated =
          await service.getConversationSettings('conv1', 'user1');
      expect(updated.themeColor, equals('#FF5733'));
    });
  });

  group('Statistics', () {
    test('Get default stats', () async {
      final stats = await service.getStats('conv1');

      expect(stats.totalPinned, equals(0));
      expect(stats.totalForwarded, equals(0));
      expect(stats.activeThreads, equals(0));
    });

    test('Update statistics', () async {
      var stats = await service.getStats('conv1');
      stats = stats.copyWith(
        totalPinned: 5,
        totalForwarded: 3,
        activeThreads: 2,
      );

      await service.updateStats(stats);

      final updated = await service.getStats('conv1');
      expect(updated.totalPinned, equals(5));
      expect(updated.activeThreads, equals(2));
    });

    test('Stats include multiple metrics', () async {
      var stats = await service.getStats('conv1');
      stats = stats.copyWith(
        totalPinned: 10,
        totalForwarded: 8,
        activeThreads: 5,
        totalReactions: 45,
        totalBookmarks: 12,
      );

      await service.updateStats(stats);

      final updated = await service.getStats('conv1');
      expect(updated.totalReactions, equals(45));
      expect(updated.totalBookmarks, equals(12));
    });
  });

  group('Data Models', () {
    test('PinnedMessage serialization', () {
      final pinned = PinnedMessage(
        pinnedId: 'pin1',
        messageId: 'msg1',
        conversationId: 'conv1',
        pinnedBy: 'user1',
        pinnedReason: 'Important',
        priority: PinPriority.high,
        createdAt: DateTime.now(),
        viewers: ['user2', 'user3'],
      );

      final map = pinned.toMap();
      final restored = PinnedMessage.fromMap(map);

      expect(restored.messageId, equals(pinned.messageId));
      expect(restored.priority, equals(pinned.priority));
    });

    test('MessageThread serialization', () {
      final thread = MessageThread(
        threadId: 'thread1',
        conversationId: 'conv1',
        rootMessageId: 'msg1',
        initiatedBy: 'user1',
        subject: 'Test',
        messageCount: 5,
        createdAt: DateTime.now(),
        participantIds: ['user1', 'user2'],
      );

      final map = thread.toMap();
      final restored = MessageThread.fromMap(map);

      expect(restored.messageCount, equals(5));
      expect(restored.participantIds.length, equals(2));
    });

    test('BookmarkedMessage serialization', () {
      final bookmark = BookmarkedMessage(
        bookmarkId: 'bm1',
        messageId: 'msg1',
        userId: 'user1',
        conversationId: 'conv1',
        folder: 'Tips',
        tags: ['important', 'study'],
        bookmarkedAt: DateTime.now(),
      );

      final map = bookmark.toMap();
      final restored = BookmarkedMessage.fromMap(map);

      expect(restored.folder, equals('Tips'));
      expect(restored.tags.length, equals(2));
    });

    test('ConversationSettings serialization', () {
      final settings = ConversationSettings(
        conversationId: 'conv1',
        userId: 'user1',
        themeColor: '#FF5733',
        notificationsEnabled: false,
        notificationQuietHoursStart: 22,
        notificationQuietHoursEnd: 8,
        updatedAt: DateTime.now(),
      );

      final map = settings.toMap();
      final restored = ConversationSettings.fromMap(map);

      expect(restored.themeColor, equals('#FF5733'));
      expect(restored.hasQuietHours, true);
    });
  });

  group('Integration', () {
    test('Complete threading workflow', () async {
      // Create thread
      final threadId = await service.createThread(
        'msg1',
        'conv1',
        'user1',
        subject: 'License tips',
      );

      // Add participants
      await service.addThreadParticipant(threadId, 'user2');
      await service.addThreadParticipant(threadId, 'user3');

      // Get thread
      final thread = await service.getThread(threadId);
      expect(thread!.participantIds.length, equals(3));

      // Resolve thread
      await service.resolveThread(threadId);
      final resolved = await service.getThread(threadId);
      expect(resolved!.status, equals(ThreadStatus.resolved));
    });

    test('Pin and forward workflow', () async {
      // Pin message
      final pinnedId = await service.pinMessage(
        'msg1',
        'conv1',
        'user1',
        priority: PinPriority.urgent,
      );

      // Forward message
      final forwardedId = await service.forwardMessage(
        'msg1',
        'conv2',
        'user1',
        message: 'Great content!',
      );

      // Verify both
      final pinned = await service.getPinnedMessage(pinnedId);
      final forwarded =
          await service.getForwardedMessage(forwardedId);

      expect(pinned!.messageId, equals('msg1'));
      expect(forwarded!.originalMessageId, equals('msg1'));
    });

    test('Bookmark with tags and folder', () async {
      // Create bookmarks
      final bm1 = await service.bookmarkMessage(
        'msg1',
        'conv1',
        'user1',
        folder: 'Rules',
        tags: ['important', 'rules'],
      );

      final bm2 = await service.bookmarkMessage(
        'msg2',
        'conv1',
        'user1',
        folder: 'Questions',
        tags: ['practice', 'hard'],
      );

      // Get by folder
      final rulesBookmarks =
          await service.getBookmarksByFolder('user1', 'Rules');
      expect(rulesBookmarks.length, equals(1));

      // Update tags
      await service.updateBookmarkTags(bm1, ['critical', 'must-know']);
      final updated = await service.getBookmark(bm1);
      expect(updated!.tags.length, equals(2));
    });
  });
}
