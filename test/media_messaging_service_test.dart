import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/media_messaging_model.dart';
import 'package:project_040/services/media_messaging_service.dart';

void main() {
  late MediaMessagingService service;

  setUp(() {
    service = StubMediaMessagingService();
  });

  group('Voice Messages', () {
    test('send voice message', () async {
      final voiceId = await service.sendVoiceMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        audioUrl: 'https://example.com/audio.m4a',
        duration: const Duration(seconds: 30),
        fileSize: 150000,
      );

      expect(voiceId, isNotEmpty);
      final message = await service.getVoiceMessage(voiceId);
      expect(message, isNotNull);
      expect(message!.senderId, 'user1');
      expect(message.conversationId, 'conv1');
      expect(message.durationSeconds, 30);
    });

    test('get voice message by id', () async {
      final voiceId = await service.sendVoiceMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        audioUrl: 'https://example.com/audio.m4a',
        duration: const Duration(seconds: 45),
        fileSize: 200000,
      );

      final message = await service.getVoiceMessage(voiceId);
      expect(message, isNotNull);
      expect(message!.voiceId, voiceId);
      expect(message.formattedDuration, '0:45');
    });

    test('get conversation voice messages', () async {
      final voiceId1 = await service.sendVoiceMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        audioUrl: 'https://example.com/audio1.m4a',
        duration: const Duration(seconds: 30),
        fileSize: 150000,
      );

      final voiceId2 = await service.sendVoiceMessage(
        messageId: 'msg2',
        conversationId: 'conv1',
        senderId: 'user1',
        audioUrl: 'https://example.com/audio2.m4a',
        duration: const Duration(seconds: 25),
        fileSize: 125000,
      );

      await service.sendVoiceMessage(
        messageId: 'msg3',
        conversationId: 'conv2',
        senderId: 'user2',
        audioUrl: 'https://example.com/audio3.m4a',
        duration: const Duration(seconds: 20),
        fileSize: 100000,
      );

      final messages =
          await service.getConversationVoiceMessages('conv1');
      expect(messages, hasLength(2));
      expect(messages.every((m) => m.conversationId == 'conv1'), true);
    });

    test('set voice message transcription', () async {
      final voiceId = await service.sendVoiceMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        audioUrl: 'https://example.com/audio.m4a',
        duration: const Duration(seconds: 30),
        fileSize: 150000,
      );

      await service.setVoiceMessageTranscription(
        voiceId: voiceId,
        transcription: 'This is a transcription',
        language: 'en',
      );

      final message = await service.getVoiceMessage(voiceId);
      expect(message!.isTranscribed, true);
      expect(message.transcription, 'This is a transcription');
      expect(message.transcriptionLanguage, 'en');
    });

    test('mark voice message as viewed', () async {
      final voiceId = await service.sendVoiceMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        audioUrl: 'https://example.com/audio.m4a',
        duration: const Duration(seconds: 30),
        fileSize: 150000,
      );

      await service.markVoiceMessageViewed(voiceId, 'user2');
      await service.markVoiceMessageViewed(voiceId, 'user3');

      final message = await service.getVoiceMessage(voiceId);
      expect(message!.viewedBy, contains('user2'));
      expect(message.viewedBy, contains('user3'));
      expect(message.viewedBy, hasLength(2));
    });

    test('search voice messages by transcription', () async {
      await service.sendVoiceMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        audioUrl: 'https://example.com/audio1.m4a',
        duration: const Duration(seconds: 30),
        fileSize: 150000,
      );

      final voiceId2 = await service.sendVoiceMessage(
        messageId: 'msg2',
        conversationId: 'conv1',
        senderId: 'user1',
        audioUrl: 'https://example.com/audio2.m4a',
        duration: const Duration(seconds: 25),
        fileSize: 125000,
      );

      await service.setVoiceMessageTranscription(
        voiceId: voiceId2,
        transcription: 'Bike maintenance tips',
      );

      final results = await service.searchVoiceMessages(
        conversationId: 'conv1',
        query: 'maintenance',
      );

      expect(results, hasLength(1));
      expect(results[0].transcription, contains('maintenance'));
    });

    test('voice message duration formatting', () async {
      final voiceId = await service.sendVoiceMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        audioUrl: 'https://example.com/audio.m4a',
        duration: const Duration(minutes: 2, seconds: 45),
        fileSize: 200000,
      );

      final message = await service.getVoiceMessage(voiceId);
      expect(message!.formattedDuration, '2:45');
      expect(message.durationSeconds, 165);
    });
  });

  group('Video Messages', () {
    test('send video message', () async {
      final videoId = await service.sendVideoMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        videoUrl: 'https://example.com/video.mp4',
        duration: const Duration(seconds: 120),
        fileSize: 5000000,
        width: 1920,
        height: 1080,
      );

      expect(videoId, isNotEmpty);
      final message = await service.getVideoMessage(videoId);
      expect(message, isNotNull);
      expect(message!.senderId, 'user1');
      expect(message.conversationId, 'conv1');
      expect(message.width, 1920);
      expect(message.height, 1080);
    });

    test('get video message by id', () async {
      final videoId = await service.sendVideoMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        videoUrl: 'https://example.com/video.mp4',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        duration: const Duration(seconds: 90),
        fileSize: 4000000,
      );

      final message = await service.getVideoMessage(videoId);
      expect(message, isNotNull);
      expect(message!.videoId, videoId);
      expect(message.thumbnailUrl, isNotNull);
    });

    test('get conversation video messages', () async {
      await service.sendVideoMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        videoUrl: 'https://example.com/video1.mp4',
        duration: const Duration(seconds: 60),
        fileSize: 3000000,
      );

      await service.sendVideoMessage(
        messageId: 'msg2',
        conversationId: 'conv1',
        senderId: 'user1',
        videoUrl: 'https://example.com/video2.mp4',
        duration: const Duration(seconds: 120),
        fileSize: 5000000,
      );

      final messages =
          await service.getConversationVideoMessages('conv1');
      expect(messages, hasLength(2));
    });

    test('set video message transcription', () async {
      final videoId = await service.sendVideoMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        videoUrl: 'https://example.com/video.mp4',
        duration: const Duration(seconds: 120),
        fileSize: 5000000,
      );

      await service.setVideoMessageTranscription(
        videoId: videoId,
        transcription: 'Bike repair tutorial video',
        language: 'en',
      );

      final message = await service.getVideoMessage(videoId);
      expect(message!.isTranscribed, true);
      expect(message.transcription, contains('repair'));
    });

    test('mark video message as viewed', () async {
      final videoId = await service.sendVideoMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        videoUrl: 'https://example.com/video.mp4',
        duration: const Duration(seconds: 120),
        fileSize: 5000000,
      );

      await service.markVideoMessageViewed(videoId, 'user2');
      await service.markVideoMessageViewed(videoId, 'user3');

      final message = await service.getVideoMessage(videoId);
      expect(message!.viewedBy, hasLength(2));
    });

    test('video message duration formatting', () async {
      final videoId = await service.sendVideoMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        videoUrl: 'https://example.com/video.mp4',
        duration: const Duration(minutes: 5, seconds: 30),
        fileSize: 8000000,
      );

      final message = await service.getVideoMessage(videoId);
      expect(message!.formattedDuration, '5:30');
    });

    test('search video messages by transcription', () async {
      final videoId = await service.sendVideoMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        videoUrl: 'https://example.com/video.mp4',
        duration: const Duration(seconds: 120),
        fileSize: 5000000,
      );

      await service.setVideoMessageTranscription(
        videoId: videoId,
        transcription: 'How to fix a flat tire',
      );

      final results = await service.searchVideoMessages(
        conversationId: 'conv1',
        query: 'flat tire',
      );

      expect(results, hasLength(1));
    });
  });

  group('Shared Media', () {
    test('share image media', () async {
      final mediaId = await service.shareMedia(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        type: MediaType.image,
        mediaUrl: 'https://example.com/photo.jpg',
        thumbnailUrl: 'https://example.com/photo_thumb.jpg',
        fileName: 'bike_photo.jpg',
        fileSize: 2000000,
        mimeType: 'image/jpeg',
        width: 3000,
        height: 2000,
      );

      final media = await service.getSharedMedia(mediaId);
      expect(media, isNotNull);
      expect(media!.type, MediaType.image);
      expect(media.fileName, 'bike_photo.jpg');
    });

    test('share document media', () async {
      final mediaId = await service.shareMedia(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        type: MediaType.document,
        mediaUrl: 'https://example.com/manual.pdf',
        fileName: 'bike_manual.pdf',
        fileSize: 5000000,
        mimeType: 'application/pdf',
      );

      final media = await service.getSharedMedia(mediaId);
      expect(media, isNotNull);
      expect(media!.type, MediaType.document);
      expect(media.readableFileSize, '4.8 MB');
    });

    test('get conversation shared media', () async {
      await service.shareMedia(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        type: MediaType.image,
        mediaUrl: 'https://example.com/photo1.jpg',
        fileName: 'photo1.jpg',
        fileSize: 2000000,
        mimeType: 'image/jpeg',
      );

      await service.shareMedia(
        messageId: 'msg2',
        conversationId: 'conv1',
        senderId: 'user1',
        type: MediaType.document,
        mediaUrl: 'https://example.com/doc.pdf',
        fileName: 'document.pdf',
        fileSize: 1000000,
        mimeType: 'application/pdf',
      );

      final media = await service.getConversationSharedMedia('conv1');
      expect(media, hasLength(2));
    });

    test('filter shared media by type', () async {
      await service.shareMedia(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        type: MediaType.image,
        mediaUrl: 'https://example.com/photo.jpg',
        fileName: 'photo.jpg',
        fileSize: 2000000,
        mimeType: 'image/jpeg',
      );

      await service.shareMedia(
        messageId: 'msg2',
        conversationId: 'conv1',
        senderId: 'user1',
        type: MediaType.document,
        mediaUrl: 'https://example.com/doc.pdf',
        fileName: 'document.pdf',
        fileSize: 1000000,
        mimeType: 'application/pdf',
      );

      final images =
          await service.getConversationSharedMedia('conv1',
              filterType: MediaType.image);
      expect(images, hasLength(1));
      expect(images[0].type, MediaType.image);
    });

    test('mark shared media as viewed', () async {
      final mediaId = await service.shareMedia(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        type: MediaType.image,
        mediaUrl: 'https://example.com/photo.jpg',
        fileName: 'photo.jpg',
        fileSize: 2000000,
        mimeType: 'image/jpeg',
      );

      await service.markSharedMediaViewed(mediaId, 'user2');
      await service.markSharedMediaViewed(mediaId, 'user3');

      final media = await service.getSharedMedia(mediaId);
      expect(media!.viewedBy, hasLength(2));
    });

    test('search shared media by filename', () async {
      await service.shareMedia(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        type: MediaType.image,
        mediaUrl: 'https://example.com/bike_photo.jpg',
        fileName: 'bike_photo.jpg',
        fileSize: 2000000,
        mimeType: 'image/jpeg',
      );

      await service.shareMedia(
        messageId: 'msg2',
        conversationId: 'conv1',
        senderId: 'user1',
        type: MediaType.image,
        mediaUrl: 'https://example.com/other.jpg',
        fileName: 'other.jpg',
        fileSize: 1000000,
        mimeType: 'image/jpeg',
      );

      final results = await service.searchSharedMedia(
        conversationId: 'conv1',
        query: 'bike',
      );

      expect(results, hasLength(1));
      expect(results[0].fileName, contains('bike'));
    });

    test('file size formatting', () async {
      final media1Id = await service.shareMedia(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        type: MediaType.image,
        mediaUrl: 'https://example.com/small.jpg',
        fileName: 'small.jpg',
        fileSize: 512,
        mimeType: 'image/jpeg',
      );

      final media2Id = await service.shareMedia(
        messageId: 'msg2',
        conversationId: 'conv1',
        senderId: 'user1',
        type: MediaType.document,
        mediaUrl: 'https://example.com/large.pdf',
        fileName: 'large.pdf',
        fileSize: 5242880, // 5 MB
        mimeType: 'application/pdf',
      );

      final media1 = await service.getSharedMedia(media1Id);
      final media2 = await service.getSharedMedia(media2Id);

      expect(media1!.readableFileSize, '512 B');
      expect(media2!.readableFileSize, '5.0 MB');
    });
  });

  group('Media Calls', () {
    test('initiate voice call', () async {
      final callId = await service.initiateCall(
        conversationId: 'conv1',
        initiatorId: 'user1',
        participantIds: ['user2', 'user3'],
        callType: CallType.voiceCall,
      );

      expect(callId, isNotEmpty);
      final call = await service.getCall(callId);
      expect(call, isNotNull);
      expect(call!.callType, CallType.voiceCall);
      expect(call.status, CallStatus.initiating);
    });

    test('initiate video call', () async {
      final callId = await service.initiateCall(
        conversationId: 'conv1',
        initiatorId: 'user1',
        participantIds: ['user2'],
        callType: CallType.videoCall,
      );

      final call = await service.getCall(callId);
      expect(call!.callType, CallType.videoCall);
    });

    test('get conversation calls', () async {
      await service.initiateCall(
        conversationId: 'conv1',
        initiatorId: 'user1',
        participantIds: ['user2'],
        callType: CallType.voiceCall,
      );

      await service.initiateCall(
        conversationId: 'conv1',
        initiatorId: 'user1',
        participantIds: ['user2'],
        callType: CallType.videoCall,
      );

      final calls = await service.getConversationCalls('conv1');
      expect(calls, hasLength(2));
    });

    test('update call status to active', () async {
      final callId = await service.initiateCall(
        conversationId: 'conv1',
        initiatorId: 'user1',
        participantIds: ['user2'],
        callType: CallType.voiceCall,
      );

      await service.updateCallStatus(callId, CallStatus.active);

      final call = await service.getCall(callId);
      expect(call!.status, CallStatus.active);
      expect(call.isActive, true);
    });

    test('decline call', () async {
      final callId = await service.initiateCall(
        conversationId: 'conv1',
        initiatorId: 'user1',
        participantIds: ['user2', 'user3'],
        callType: CallType.voiceCall,
      );

      await service.declineCall(callId, 'user2');
      await service.declineCall(callId, 'user3');

      final call = await service.getCall(callId);
      expect(call!.status, CallStatus.declined);
      expect(call.declinedBy, contains('user2'));
      expect(call.declinedBy, contains('user3'));
    });

    test('end call with duration', () async {
      final callId = await service.initiateCall(
        conversationId: 'conv1',
        initiatorId: 'user1',
        participantIds: ['user2'],
        callType: CallStatus.voiceCall,
      );

      await service.updateCallStatus(callId, CallStatus.active);
      await service.endCall(callId: callId, durationSeconds: 300);

      final call = await service.getCall(callId);
      expect(call!.status, CallStatus.ended);
      expect(call.durationSeconds, 300);
      expect(call.isEnded, true);
    });

    test('record call', () async {
      final callId = await service.initiateCall(
        conversationId: 'conv1',
        initiatorId: 'user1',
        participantIds: ['user2'],
        callType: CallType.voiceCall,
      );

      await service.recordCall(
        callId: callId,
        recordingUrl: 'https://example.com/recording.m4a',
      );

      final call = await service.getCall(callId);
      expect(call!.isRecorded, true);
      expect(call.recordingUrl, isNotNull);
    });

    test('call status tracking', () async {
      final callId = await service.initiateCall(
        conversationId: 'conv1',
        initiatorId: 'user1',
        participantIds: ['user2'],
        callType: CallType.voiceCall,
      );

      final initialCall = await service.getCall(callId);
      expect(initialCall!.status, CallStatus.initiating);

      await service.updateCallStatus(callId, CallStatus.ringing);
      var call = await service.getCall(callId);
      expect(call!.status, CallStatus.ringing);

      await service.updateCallStatus(callId, CallStatus.connecting);
      call = await service.getCall(callId);
      expect(call!.status, CallStatus.connecting);

      await service.updateCallStatus(callId, CallStatus.active);
      call = await service.getCall(callId);
      expect(call!.status, CallStatus.active);
    });
  });

  group('Media Metadata', () {
    test('store media metadata', () async {
      final metadataId = await service.storeMediaMetadata(
        mediaId: 'media1',
        width: '1920',
        height: '1080',
        duration: '120',
        fileSize: '5000000',
        codec: 'h264',
        bitrate: '5000k',
        framerate: '30',
      );

      final metadata = await service.getMediaMetadata(metadataId);
      expect(metadata, isNotNull);
      expect(metadata!.width, '1920');
      expect(metadata.codec, 'h264');
    });

    test('get media metadata', () async {
      final metadataId = await service.storeMediaMetadata(
        mediaId: 'media1',
        width: '3000',
        height: '2000',
        codec: 'jpeg',
      );

      final metadata = await service.getMediaMetadata(metadataId);
      expect(metadata!.metadataId, metadataId);
      expect(metadata.mediaId, 'media1');
    });
  });

  group('Media Upload Progress', () {
    test('track media upload progress', () async {
      await service.trackMediaUploadProgress(
        uploadId: 'upload1',
        mediaId: 'media1',
        progress: 50,
        bytesUploaded: 5000000,
        totalBytes: 10000000,
        estimatedTimeRemaining: const Duration(seconds: 30),
      );

      final progress = await service.getUploadProgress('upload1');
      expect(progress, isNotNull);
      expect(progress!.progress, 50);
      expect(progress.bytesUploaded, 5000000);
    });

    test('complete media upload', () async {
      await service.trackMediaUploadProgress(
        uploadId: 'upload1',
        mediaId: 'media1',
        progress: 100,
        bytesUploaded: 10000000,
        totalBytes: 10000000,
        estimatedTimeRemaining: Duration.zero,
      );

      final progress = await service.getUploadProgress('upload1');
      expect(progress!.isComplete, true);
      expect(progress.progress, 100);
    });
  });

  group('Media Statistics', () {
    test('get total voice messages count', () async {
      await service.sendVoiceMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        audioUrl: 'https://example.com/audio1.m4a',
        duration: const Duration(seconds: 30),
        fileSize: 150000,
      );

      await service.sendVoiceMessage(
        messageId: 'msg2',
        conversationId: 'conv1',
        senderId: 'user1',
        audioUrl: 'https://example.com/audio2.m4a',
        duration: const Duration(seconds: 25),
        fileSize: 125000,
      );

      final count = await service.getTotalVoiceMessagesCount('conv1');
      expect(count, 2);
    });

    test('get total video messages count', () async {
      await service.sendVideoMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        videoUrl: 'https://example.com/video.mp4',
        duration: const Duration(seconds: 120),
        fileSize: 5000000,
      );

      final count = await service.getTotalVideoMessagesCount('conv1');
      expect(count, 1);
    });

    test('get total shared media count', () async {
      await service.shareMedia(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        type: MediaType.image,
        mediaUrl: 'https://example.com/photo.jpg',
        fileName: 'photo.jpg',
        fileSize: 2000000,
        mimeType: 'image/jpeg',
      );

      await service.shareMedia(
        messageId: 'msg2',
        conversationId: 'conv1',
        senderId: 'user1',
        type: MediaType.document,
        mediaUrl: 'https://example.com/doc.pdf',
        fileName: 'document.pdf',
        fileSize: 1000000,
        mimeType: 'application/pdf',
      );

      final count = await service.getTotalSharedMediaCount('conv1');
      expect(count, 2);
    });

    test('get total calls count', () async {
      await service.initiateCall(
        conversationId: 'conv1',
        initiatorId: 'user1',
        participantIds: ['user2'],
        callType: CallType.voiceCall,
      );

      await service.initiateCall(
        conversationId: 'conv1',
        initiatorId: 'user1',
        participantIds: ['user2'],
        callType: CallType.videoCall,
      );

      final count = await service.getTotalCallsCount('conv1');
      expect(count, 2);
    });
  });

  group('Models', () {
    test('VoiceMessage serialization', () async {
      final message = VoiceMessage(
        voiceId: 'voice1',
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        audioUrl: 'https://example.com/audio.m4a',
        duration: const Duration(seconds: 30),
        fileSize: 150000,
        createdAt: DateTime.now(),
      );

      final map = message.toMap();
      final restored = VoiceMessage.fromMap(map);

      expect(restored.voiceId, message.voiceId);
      expect(restored.messageId, message.messageId);
      expect(restored.durationSeconds, 30);
    });

    test('VideoMessage serialization', () async {
      final message = VideoMessage(
        videoId: 'video1',
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        videoUrl: 'https://example.com/video.mp4',
        duration: const Duration(seconds: 120),
        fileSize: 5000000,
        createdAt: DateTime.now(),
      );

      final map = message.toMap();
      final restored = VideoMessage.fromMap(map);

      expect(restored.videoId, message.videoId);
      expect(restored.messageId, message.messageId);
    });

    test('SharedMedia serialization', () async {
      final media = SharedMedia(
        mediaId: 'media1',
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        type: MediaType.image,
        mediaUrl: 'https://example.com/photo.jpg',
        fileName: 'photo.jpg',
        fileSize: 2000000,
        mimeType: 'image/jpeg',
        createdAt: DateTime.now(),
      );

      final map = media.toMap();
      final restored = SharedMedia.fromMap(map);

      expect(restored.mediaId, media.mediaId);
      expect(restored.type, MediaType.image);
      expect(restored.readableFileSize, '1.9 MB');
    });

    test('MediaCall serialization', () async {
      final call = MediaCall(
        callId: 'call1',
        conversationId: 'conv1',
        initiatorId: 'user1',
        participantIds: ['user2', 'user3'],
        callType: CallType.voiceCall,
        status: CallStatus.active,
        initiatedAt: DateTime.now(),
      );

      final map = call.toMap();
      final restored = MediaCall.fromMap(map);

      expect(restored.callId, call.callId);
      expect(restored.callType, CallType.voiceCall);
      expect(restored.participantIds, hasLength(2));
    });

    test('MediaMetadata serialization', () async {
      final metadata = MediaMetadata(
        metadataId: 'meta1',
        mediaId: 'media1',
        width: '1920',
        height: '1080',
        duration: '120',
        codec: 'h264',
        createdAt: DateTime.now(),
      );

      final map = metadata.toMap();
      final restored = MediaMetadata.fromMap(map);

      expect(restored.metadataId, metadata.metadataId);
      expect(restored.width, '1920');
    });

    test('MediaUploadProgress serialization', () async {
      final progress = MediaUploadProgress(
        uploadId: 'upload1',
        mediaId: 'media1',
        progress: 75,
        bytesUploaded: 7500000,
        totalBytes: 10000000,
        startedAt: DateTime.now(),
      );

      final map = progress.toMap();
      final restored = MediaUploadProgress.fromMap(map);

      expect(restored.uploadId, progress.uploadId);
      expect(restored.progress, 75);
    });
  });

  group('Integration Tests', () {
    test('complete voice message workflow', () async {
      // Send voice message
      final voiceId = await service.sendVoiceMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        audioUrl: 'https://example.com/audio.m4a',
        duration: const Duration(seconds: 45),
        fileSize: 200000,
      );

      // Add transcription
      await service.setVoiceMessageTranscription(
        voiceId: voiceId,
        transcription: 'Important bike maintenance reminder',
        language: 'en',
      );

      // Mark as viewed by multiple users
      await service.markVoiceMessageViewed(voiceId, 'user2');
      await service.markVoiceMessageViewed(voiceId, 'user3');

      // Verify final state
      final message = await service.getVoiceMessage(voiceId);
      expect(message!.isTranscribed, true);
      expect(message.viewedBy, hasLength(2));
      expect(message.transcription, contains('maintenance'));
    });

    test('complete video message workflow', () async {
      // Send video message
      final videoId = await service.sendVideoMessage(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        videoUrl: 'https://example.com/video.mp4',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        duration: const Duration(minutes: 2),
        fileSize: 8000000,
        width: 1920,
        height: 1080,
      );

      // Store metadata
      await service.storeMediaMetadata(
        mediaId: videoId,
        width: '1920',
        height: '1080',
        duration: '120',
        codec: 'h264',
      );

      // Add transcription
      await service.setVideoMessageTranscription(
        videoId: videoId,
        transcription: 'How to fix a flat tire - tutorial',
      );

      // Get video with all information
      final message = await service.getVideoMessage(videoId);
      expect(message!.isTranscribed, true);
      expect(message.height, 1080);
    });

    test('complete media sharing workflow', () async {
      // Share media
      final mediaId = await service.shareMedia(
        messageId: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        type: MediaType.image,
        mediaUrl: 'https://example.com/photo.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        fileName: 'bike_photo.jpg',
        fileSize: 2000000,
        mimeType: 'image/jpeg',
        width: 3000,
        height: 2000,
      );

      // Mark as viewed
      await service.markSharedMediaViewed(mediaId, 'user2');
      await service.markSharedMediaViewed(mediaId, 'user3');

      // Verify
      final media = await service.getSharedMedia(mediaId);
      expect(media!.viewedBy, hasLength(2));
      expect(media.readableFileSize, '1.9 MB');
    });

    test('complete call workflow', () async {
      // Initiate call
      final callId = await service.initiateCall(
        conversationId: 'conv1',
        initiatorId: 'user1',
        participantIds: ['user2', 'user3'],
        callType: CallType.voiceCall,
      );

      // Progress through call states
      await service.updateCallStatus(callId, CallStatus.ringing);
      await service.updateCallStatus(callId, CallStatus.active);

      // Record the call
      await service.recordCall(
        callId: callId,
        recordingUrl: 'https://example.com/recording.m4a',
      );

      // End call
      await service.endCall(callId: callId, durationSeconds: 300);

      // Verify final state
      final call = await service.getCall(callId);
      expect(call!.isRecorded, true);
      expect(call.status, CallStatus.ended);
      expect(call.durationSeconds, 300);
    });
  });
}
