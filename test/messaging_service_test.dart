import 'package:flutter_test/flutter_test.dart';
import '../lib/models/messaging_model.dart';
import '../lib/services/messaging_service.dart';

void main() {
  late MessagingService messagingService;

  setUp(() {
    messagingService = StubMessagingService();
  });

  group('Direct Messaging', () {
    test('Send message creates message with ID', () async {
      final messageId = await messagingService.sendMessage(
        'user1',
        'user2',
        'Hello there!',
      );

      expect(messageId, isNotEmpty);
      final message = await messagingService.getMessage(messageId);
      expect(message, isNotNull);
      expect(message!.content, equals('Hello there!'));
      expect(message.senderId, equals('user1'));
    });

    test('Send multiple messages', () async {
      final msg1 = await messagingService.sendMessage(
        'user1',
        'user2',
        'First message',
      );
      final msg2 = await messagingService.sendMessage(
        'user1',
        'user2',
        'Second message',
      );

      expect(msg1, isNotEmpty);
      expect(msg2, isNotEmpty);
      expect(msg1, isNot(equals(msg2)));
    });

    test('Get message returns correct content', () async {
      final messageId = await messagingService.sendMessage(
        'user1',
        'user2',
        'Test content',
      );

      final message = await messagingService.getMessage(messageId);
      expect(message!.content, equals('Test content'));
      expect(message.type, equals(MessageType.text));
    });

    test('Get non-existent message returns null', () async {
      final message = await messagingService.getMessage('nonexistent');
      expect(message, isNull);
    });

    test('Message has sender information', () async {
      final messageId = await messagingService.sendMessage(
        'alice',
        'bob',
        'Hi Bob!',
      );

      final message = await messagingService.getMessage(messageId);
      expect(message!.senderId, equals('alice'));
      expect(message.senderName, equals('User'));
    });

    test('Message has timestamp', () async {
      final before = DateTime.now();
      final messageId = await messagingService.sendMessage(
        'user1',
        'user2',
        'Timed message',
      );
      final after = DateTime.now();

      final message = await messagingService.getMessage(messageId);
      expect(message!.createdAt.isAfter(before), true);
      expect(message.createdAt.isBefore(after), true);
    });

    test('Message initially not read', () async {
      final messageId = await messagingService.sendMessage(
        'user1',
        'user2',
        'Unread message',
      );

      final message = await messagingService.getMessage(messageId);
      expect(message!.readBy, isEmpty);
      expect(message.isRead, false);
    });
  });

  group('Conversation Management', () {
    test('Get or create DM creates new conversation', () async {
      final convId = await messagingService.getOrCreateDMConversation(
        'user1',
        'user2',
      );

      expect(convId, isNotEmpty);
      final conv = await messagingService.getConversation(convId);
      expect(conv, isNotNull);
      expect(conv!.type, equals(ConversationType.direct));
    });

    test('Get or create DM returns existing conversation', () async {
      final convId1 = await messagingService.getOrCreateDMConversation(
        'user1',
        'user2',
      );
      final convId2 = await messagingService.getOrCreateDMConversation(
        'user1',
        'user2',
      );

      expect(convId1, equals(convId2));
    });

    test('DM conversation has both participants', () async {
      final convId = await messagingService.getOrCreateDMConversation(
        'alice',
        'bob',
      );

      final conv = await messagingService.getConversation(convId);
      expect(conv!.participantIds, contains('alice'));
      expect(conv.participantIds, contains('bob'));
      expect(conv.participantIds.length, equals(2));
    });

    test('Get conversation returns null for non-existent', () async {
      final conv = await messagingService.getConversation('nonexistent');
      expect(conv, isNull);
    });

    test('Get user conversations returns active conversations', () async {
      await messagingService.getOrCreateDMConversation('user1', 'user2');
      await messagingService.getOrCreateDMConversation('user1', 'user3');

      final convs = await messagingService.getUserConversations('user1');
      expect(convs.length, equals(2));
      expect(convs.every((c) => c.participantIds.contains('user1')), true);
    });

    test('Get user conversations excludes archived', () async {
      final convId = await messagingService.getOrCreateDMConversation(
        'user1',
        'user2',
      );
      await messagingService.archiveConversation(convId);

      final convs = await messagingService.getUserConversations('user1');
      expect(convs, isEmpty);
    });

    test('Archive conversation', () async {
      final convId = await messagingService.getOrCreateDMConversation(
        'user1',
        'user2',
      );

      await messagingService.archiveConversation(convId);
      final conv = await messagingService.getConversation(convId);
      expect(conv!.isArchived, true);
    });

    test('Unarchive conversation', () async {
      final convId = await messagingService.getOrCreateDMConversation(
        'user1',
        'user2',
      );

      await messagingService.archiveConversation(convId);
      await messagingService.unarchiveConversation(convId);

      final conv = await messagingService.getConversation(convId);
      expect(conv!.isArchived, false);
    });

    test('Mute conversation', () async {
      final convId = await messagingService.getOrCreateDMConversation(
        'user1',
        'user2',
      );

      await messagingService.muteConversation(convId);
      final conv = await messagingService.getConversation(convId);
      expect(conv!.isMuted, true);
    });

    test('Unmute conversation', () async {
      final convId = await messagingService.getOrCreateDMConversation(
        'user1',
        'user2',
      );

      await messagingService.muteConversation(convId);
      await messagingService.unmuteConversation(convId);

      final conv = await messagingService.getConversation(convId);
      expect(conv!.isMuted, false);
    });
  });

  group('Message Reading', () {
    test('Mark message as read', () async {
      final messageId = await messagingService.sendMessage(
        'user1',
        'user2',
        'Read test',
      );

      await messagingService.markMessageAsRead(messageId, 'user2');
      final message = await messagingService.getMessage(messageId);
      expect(message!.readBy, contains('user2'));
      expect(message.isRead, true);
    });

    test('Mark message as read by multiple users', () async {
      final messageId = await messagingService.sendMessage(
        'user1',
        'user2',
        'Multi-read test',
      );

      await messagingService.markMessageAsRead(messageId, 'user2');
      await messagingService.markMessageAsRead(messageId, 'user3');

      final message = await messagingService.getMessage(messageId);
      expect(message!.readBy.length, equals(2));
    });

    test('Mark conversation as read', () async {
      final convId = await messagingService.getOrCreateDMConversation(
        'user1',
        'user2',
      );

      final msg1 = await messagingService.sendMessage('user1', 'user2', 'Msg 1');
      final msg2 = await messagingService.sendMessage('user1', 'user2', 'Msg 2');

      await messagingService.markConversationAsRead(convId, 'user2');

      final message1 = await messagingService.getMessage(msg1);
      final message2 = await messagingService.getMessage(msg2);

      expect(message1!.readBy, contains('user2'));
      expect(message2!.readBy, contains('user2'));
    });

    test('Get unread message count', () async {
      await messagingService.sendMessage('user1', 'user2', 'Msg 1');
      await messagingService.sendMessage('user1', 'user2', 'Msg 2');

      final count = await messagingService.getUnreadMessageCount('user2');
      expect(count, equals(2));
    });
  });

  group('Message Editing & Deletion', () {
    test('Edit message updates content', () async {
      final messageId = await messagingService.sendMessage(
        'user1',
        'user2',
        'Original content',
      );

      await messagingService.editMessage(messageId, 'Edited content');
      final message = await messagingService.getMessage(messageId);
      expect(message!.content, equals('Edited content'));
    });

    test('Delete message marks as deleted', () async {
      final messageId = await messagingService.sendMessage(
        'user1',
        'user2',
        'To delete',
      );

      await messagingService.deleteMessage(messageId);
      final message = await messagingService.getMessage(messageId);
      expect(message!.isDeleted, true);
    });

    test('Deleted message shows placeholder', () async {
      final messageId = await messagingService.sendMessage(
        'user1',
        'user2',
        'Secret message',
      );

      await messagingService.deleteMessage(messageId);
      final message = await messagingService.getMessage(messageId);
      expect(message!.content.contains('deleted'), true);
    });
  });

  group('Message Reactions', () {
    test('Add reaction to message', () async {
      final messageId = await messagingService.sendMessage(
        'user1',
        'user2',
        'React to this',
      );

      await messagingService.addReaction(messageId, '👍');
      final message = await messagingService.getMessage(messageId);
      expect(message!.reactions.containsKey('👍'), true);
      expect(message.reactions['👍'], equals(1));
    });

    test('Add multiple reactions', () async {
      final messageId = await messagingService.sendMessage(
        'user1',
        'user2',
        'Multiple reactions',
      );

      await messagingService.addReaction(messageId, '👍');
      await messagingService.addReaction(messageId, '❤️');
      await messagingService.addReaction(messageId, '😂');

      final message = await messagingService.getMessage(messageId);
      expect(message!.reactions.length, equals(3));
      expect(message.reactionCount, equals(3));
    });

    test('Add same reaction multiple times', () async {
      final messageId = await messagingService.sendMessage(
        'user1',
        'user2',
        'Popular message',
      );

      await messagingService.addReaction(messageId, '👍');
      await messagingService.addReaction(messageId, '👍');
      await messagingService.addReaction(messageId, '👍');

      final message = await messagingService.getMessage(messageId);
      expect(message!.reactions['👍'], equals(3));
    });

    test('Remove reaction from message', () async {
      final messageId = await messagingService.sendMessage(
        'user1',
        'user2',
        'Reaction removal',
      );

      await messagingService.addReaction(messageId, '👍');
      await messagingService.removeReaction(messageId, '👍');

      final message = await messagingService.getMessage(messageId);
      expect(message!.reactions.containsKey('👍'), false);
    });

    test('Remove reaction reduces count', () async {
      final messageId = await messagingService.sendMessage(
        'user1',
        'user2',
        'Reaction count',
      );

      await messagingService.addReaction(messageId, '👍');
      await messagingService.addReaction(messageId, '👍');
      await messagingService.removeReaction(messageId, '👍');

      final message = await messagingService.getMessage(messageId);
      expect(message!.reactions['👍'], equals(1));
    });
  });

  group('Group Chat', () {
    test('Create group conversation', () async {
      final convId = await messagingService.createGroupConversation(
        'Study Group',
        ['user1', 'user2', 'user3'],
        'Studying together',
      );

      expect(convId, isNotEmpty);
      final conv = await messagingService.getConversation(convId);
      expect(conv!.type, equals(ConversationType.group));
      expect(conv.groupName, equals('Study Group'));
    });

    test('Group has all participants', () async {
      final convId = await messagingService.createGroupConversation(
        'Team',
        ['user1', 'user2', 'user3', 'user4'],
      );

      final conv = await messagingService.getConversation(convId);
      expect(conv!.participantIds.length, equals(4));
    });

    test('Add participant to group', () async {
      final convId = await messagingService.createGroupConversation(
        'Group',
        ['user1', 'user2'],
      );

      await messagingService.addGroupParticipant(convId, 'user3');
      final conv = await messagingService.getConversation(convId);
      expect(conv!.participantIds, contains('user3'));
      expect(conv.participantIds.length, equals(3));
    });

    test('Remove participant from group', () async {
      final convId = await messagingService.createGroupConversation(
        'Group',
        ['user1', 'user2', 'user3'],
      );

      await messagingService.removeGroupParticipant(convId, 'user2');
      final conv = await messagingService.getConversation(convId);
      expect(conv!.participantIds, isNot(contains('user2')));
      expect(conv.participantIds.length, equals(2));
    });

    test('Update group info', () async {
      final convId = await messagingService.createGroupConversation(
        'Old Name',
        ['user1', 'user2'],
        'Old description',
      );

      await messagingService.updateGroupInfo(
        convId,
        'New Name',
        'New description',
      );

      final conv = await messagingService.getConversation(convId);
      expect(conv!.groupName, equals('New Name'));
      expect(conv.groupDescription, equals('New description'));
    });

    test('Group owner is first participant', () async {
      final convId = await messagingService.createGroupConversation(
        'Group',
        ['alice', 'bob', 'charlie'],
      );

      final conv = await messagingService.getConversation(convId);
      expect(conv!.groupOwnerId, equals('alice'));
    });
  });

  group('Notifications', () {
    test('Send notification', () async {
      final notif = Notification(
        notificationId: 'notif1',
        userId: 'user1',
        type: NotificationType.message,
        title: 'New Message',
        message: 'You have a new message',
        createdAt: DateTime.now(),
      );

      await messagingService.sendNotification(notif);
      final retrieved = await messagingService.getNotification('notif1');
      expect(retrieved, isNotNull);
      expect(retrieved!.title, equals('New Message'));
    });

    test('Get user notifications', () async {
      final notif1 = Notification(
        notificationId: 'n1',
        userId: 'user1',
        type: NotificationType.message,
        title: 'Msg 1',
        message: 'Message 1',
        createdAt: DateTime.now(),
      );

      final notif2 = Notification(
        notificationId: 'n2',
        userId: 'user1',
        type: NotificationType.mention,
        title: 'Mention',
        message: 'You were mentioned',
        createdAt: DateTime.now(),
      );

      await messagingService.sendNotification(notif1);
      await messagingService.sendNotification(notif2);

      final notifs = await messagingService.getUserNotifications('user1');
      expect(notifs.length, equals(2));
    });

    test('Get unread notifications', () async {
      final notif = Notification(
        notificationId: 'n1',
        userId: 'user1',
        type: NotificationType.message,
        title: 'New',
        message: 'Unread',
        createdAt: DateTime.now(),
      );

      await messagingService.sendNotification(notif);

      final unread =
          await messagingService.getUnreadNotifications('user1');
      expect(unread.length, equals(1));
      expect(unread.first.isUnread, true);
    });

    test('Mark notification as read', () async {
      final notif = Notification(
        notificationId: 'n1',
        userId: 'user1',
        type: NotificationType.message,
        title: 'Test',
        message: 'Test',
        createdAt: DateTime.now(),
      );

      await messagingService.sendNotification(notif);
      await messagingService.markNotificationAsRead('n1');

      final retrieved = await messagingService.getNotification('n1');
      expect(retrieved!.status, equals(NotificationStatus.read));
    });

    test('Mark all notifications as read', () async {
      final notif1 = Notification(
        notificationId: 'n1',
        userId: 'user1',
        type: NotificationType.message,
        title: 'Msg1',
        message: 'Message 1',
        createdAt: DateTime.now(),
      );

      final notif2 = Notification(
        notificationId: 'n2',
        userId: 'user1',
        type: NotificationType.mention,
        title: 'Msg2',
        message: 'Message 2',
        createdAt: DateTime.now(),
      );

      await messagingService.sendNotification(notif1);
      await messagingService.sendNotification(notif2);
      await messagingService.markAllNotificationsAsRead('user1');

      final notifs = await messagingService.getUserNotifications('user1');
      expect(notifs.every((n) => !n.isUnread), true);
    });

    test('Delete notification', () async {
      final notif = Notification(
        notificationId: 'n1',
        userId: 'user1',
        type: NotificationType.message,
        title: 'Delete me',
        message: 'Test',
        createdAt: DateTime.now(),
      );

      await messagingService.sendNotification(notif);
      await messagingService.deleteNotification('n1');

      final retrieved = await messagingService.getNotification('n1');
      expect(retrieved, isNull);
    });

    test('Get unread notification count', () async {
      final notif1 = Notification(
        notificationId: 'n1',
        userId: 'user1',
        type: NotificationType.message,
        title: 'Test1',
        message: 'Test1',
        createdAt: DateTime.now(),
      );

      final notif2 = Notification(
        notificationId: 'n2',
        userId: 'user1',
        type: NotificationType.message,
        title: 'Test2',
        message: 'Test2',
        createdAt: DateTime.now(),
      );

      await messagingService.sendNotification(notif1);
      await messagingService.sendNotification(notif2);

      final count = await messagingService.getUnreadNotificationCount('user1');
      expect(count, equals(2));
    });
  });

  group('Notification Preferences', () {
    test('Get notification preferences defaults to all enabled', () async {
      final prefs =
          await messagingService.getNotificationPreferences('user1');

      expect(prefs.messagesEnabled, true);
      expect(prefs.mentionsEnabled, true);
      expect(prefs.soundEnabled, true);
    });

    test('Update notification preferences', () async {
      var prefs = await messagingService.getNotificationPreferences('user1');
      prefs = prefs.copyWith(messagesEnabled: false, soundEnabled: false);

      await messagingService.updateNotificationPreferences(prefs);

      final updated =
          await messagingService.getNotificationPreferences('user1');
      expect(updated.messagesEnabled, false);
      expect(updated.soundEnabled, false);
    });

    test('Disable specific notifications', () async {
      var prefs = await messagingService.getNotificationPreferences('user1');
      prefs = prefs.copyWith(
        mentionsEnabled: false,
        reactionsEnabled: false,
      );

      await messagingService.updateNotificationPreferences(prefs);

      final updated =
          await messagingService.getNotificationPreferences('user1');
      expect(updated.mentionsEnabled, false);
      expect(updated.reactionsEnabled, false);
      expect(updated.messagesEnabled, true);
    });
  });

  group('Typing Indicators', () {
    test('Set typing indicator', () async {
      final convId = await messagingService.getOrCreateDMConversation(
        'user1',
        'user2',
      );

      await messagingService.setTypingIndicator(convId, 'user2');
      final indicators = await messagingService.getTypingIndicators(convId);

      expect(indicators.length, equals(1));
      expect(indicators.first.userId, equals('user2'));
    });

    test('Get multiple typing indicators', () async {
      final convId = await messagingService.getOrCreateDMConversation(
        'user1',
        'user2',
      );

      await messagingService.setTypingIndicator(convId, 'user2');
      await messagingService.setTypingIndicator(convId, 'user3');

      final indicators = await messagingService.getTypingIndicators(convId);
      expect(indicators.length, greaterThanOrEqualTo(1));
    });

    test('Clear typing indicator', () async {
      final convId = await messagingService.getOrCreateDMConversation(
        'user1',
        'user2',
      );

      await messagingService.setTypingIndicator(convId, 'user2');
      await messagingService.clearTypingIndicator(convId, 'user2');

      final indicators = await messagingService.getTypingIndicators(convId);
      expect(indicators.where((t) => t.userId == 'user2'), isEmpty);
    });

    test('Expired typing indicators excluded', () async {
      final convId = await messagingService.getOrCreateDMConversation(
        'user1',
        'user2',
      );

      await messagingService.setTypingIndicator(convId, 'user2');
      await Future.delayed(const Duration(seconds: 6));

      final indicators = await messagingService.getTypingIndicators(convId);
      expect(
        indicators.where((t) => t.userId == 'user2' && !t.isExpired),
        isEmpty,
      );
    });
  });

  group('Message Search', () {
    test('Search messages finds results', () async {
      await messagingService.sendMessage(
        'user1',
        'user2',
        'Search for this keyword',
      );

      final results = await messagingService.searchMessages(
        'user1',
        'keyword',
      );

      expect(results.isNotEmpty, true);
    });

    test('Search returns message and conversation', () async {
      await messagingService.sendMessage(
        'user1',
        'user2',
        'Test message',
      );

      final results = await messagingService.searchMessages(
        'user1',
        'Test',
      );

      expect(results.isNotEmpty, true);
      expect(results.first.message, isNotNull);
      expect(results.first.conversation, isNotNull);
    });

    test('Search with no matches', () async {
      final results = await messagingService.searchMessages(
        'user1',
        'nonexistent_keyword_xyz',
      );

      expect(results.isEmpty, true);
    });
  });

  group('Conversation Messages', () {
    test('Get conversation messages returns in order', () async {
      final convId = await messagingService.getOrCreateDMConversation(
        'user1',
        'user2',
      );

      await messagingService.sendMessage('user1', 'user2', 'Message 1');
      await messagingService.sendMessage('user1', 'user2', 'Message 2');
      await messagingService.sendMessage('user1', 'user2', 'Message 3');

      final messages =
          await messagingService.getConversationMessages(convId);
      expect(messages.length, equals(3));
      expect(messages.first.content, equals('Message 1'));
      expect(messages.last.content, equals('Message 3'));
    });

    test('Get conversation messages respects limit', () async {
      final convId = await messagingService.getOrCreateDMConversation(
        'user1',
        'user2',
      );

      for (int i = 0; i < 100; i++) {
        await messagingService.sendMessage(
          'user1',
          'user2',
          'Message $i',
        );
      }

      final messages =
          await messagingService.getConversationMessages(convId, limit: 10);
      expect(messages.length, equals(10));
    });

    test('Get messages returns empty for empty conversation', () async {
      final convId = await messagingService.getOrCreateDMConversation(
        'user1',
        'user2',
      );

      final messages =
          await messagingService.getConversationMessages(convId);
      expect(messages, isEmpty);
    });
  });

  group('Integration', () {
    test('Complete DM workflow', () async {
      // Create conversation
      final convId = await messagingService.getOrCreateDMConversation(
        'alice',
        'bob',
      );

      // Send messages
      final msg1 = await messagingService.sendMessage(
        'alice',
        'bob',
        'Hi Bob!',
      );
      final msg2 = await messagingService.sendMessage(
        'bob',
        'alice',
        'Hi Alice!',
      );

      // Get messages
      final messages =
          await messagingService.getConversationMessages(convId);
      expect(messages.length, equals(2));

      // Add reactions
      await messagingService.addReaction(msg1, '👋');
      await messagingService.addReaction(msg2, '😊');

      // Mark as read
      await messagingService.markConversationAsRead(convId, 'alice');
      await messagingService.markConversationAsRead(convId, 'bob');

      // Verify read
      final readMsg1 = await messagingService.getMessage(msg1);
      expect(readMsg1!.readBy.length, greaterThan(0));
    });

    test('Group chat workflow', () async {
      // Create group
      final convId = await messagingService.createGroupConversation(
        'Study Group',
        ['user1', 'user2', 'user3'],
        'Let us study together',
      );

      // Send group message
      await messagingService.sendMessage('user1', 'user2', 'Group message');

      // Add participant
      await messagingService.addGroupParticipant(convId, 'user4');

      // Verify
      final conv = await messagingService.getConversation(convId);
      expect(conv!.participantIds.length, equals(4));
      expect(conv.participantIds, contains('user4'));
    });

    test('Notification workflow', () async {
      // Create notification
      final notif = Notification(
        notificationId: 'n1',
        userId: 'user1',
        type: NotificationType.message,
        title: 'New Message',
        message: 'You have a new message from Alice',
        relatedUserId: 'alice',
        createdAt: DateTime.now(),
      );

      await messagingService.sendNotification(notif);

      // Get preferences
      var prefs = await messagingService.getNotificationPreferences('user1');

      // Update preferences
      prefs = prefs.copyWith(soundEnabled: false);
      await messagingService.updateNotificationPreferences(prefs);

      // Verify
      final updated =
          await messagingService.getNotificationPreferences('user1');
      expect(updated.soundEnabled, false);
    });
  });

  group('Data Models', () {
    test('Message serialization', () {
      final message = Message(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        senderName: 'Alice',
        content: 'Test message',
        type: MessageType.text,
        createdAt: DateTime.now(),
      );

      final map = message.toMap();
      final restored = Message.fromMap(map);

      expect(restored.messageId, equals(message.messageId));
      expect(restored.content, equals(message.content));
      expect(restored.senderName, equals(message.senderName));
    });

    test('Conversation serialization', () {
      final conv = Conversation(
        conversationId: 'conv1',
        type: ConversationType.direct,
        participantIds: ['user1', 'user2'],
        createdAt: DateTime.now(),
      );

      final map = conv.toMap();
      final restored = Conversation.fromMap(map);

      expect(restored.conversationId, equals(conv.conversationId));
      expect(restored.type, equals(conv.type));
      expect(restored.participantIds, equals(conv.participantIds));
    });

    test('Notification serialization', () {
      final notif = Notification(
        notificationId: 'n1',
        userId: 'user1',
        type: NotificationType.message,
        title: 'Test',
        message: 'Test message',
        createdAt: DateTime.now(),
      );

      final map = notif.toMap();
      final restored = Notification.fromMap(map);

      expect(restored.notificationId, equals(notif.notificationId));
      expect(restored.title, equals(notif.title));
    });

    test('NotificationPreference serialization', () {
      final prefs = NotificationPreference(
        userId: 'user1',
        messagesEnabled: false,
        soundEnabled: false,
      );

      final map = prefs.toMap();
      final restored = NotificationPreference.fromMap(map);

      expect(restored.messagesEnabled, false);
      expect(restored.soundEnabled, false);
      expect(restored.mentionsEnabled, true);
    });
  });
}
