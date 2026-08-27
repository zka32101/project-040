import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/media_messaging_model.dart';

/// Abstract interface for media messaging service
abstract class MediaMessagingService {
  // Voice message operations
  Future<String> sendVoiceMessage({
    required String messageId,
    required String conversationId,
    required String senderId,
    required String audioUrl,
    required Duration duration,
    required int fileSize,
  });

  Future<VoiceMessage?> getVoiceMessage(String voiceId);

  Future<List<VoiceMessage>> getConversationVoiceMessages(
    String conversationId, {
    int limit = 50,
  });

  Future<void> setVoiceMessageTranscription({
    required String voiceId,
    required String transcription,
    String? language,
  });

  Future<void> markVoiceMessageViewed(String voiceId, String userId);

  // Video message operations
  Future<String> sendVideoMessage({
    required String messageId,
    required String conversationId,
    required String senderId,
    required String videoUrl,
    String? thumbnailUrl,
    required Duration duration,
    required int fileSize,
    int? width,
    int? height,
    String? codec,
  });

  Future<VideoMessage?> getVideoMessage(String videoId);

  Future<List<VideoMessage>> getConversationVideoMessages(
    String conversationId, {
    int limit = 50,
  });

  Future<void> setVideoMessageTranscription({
    required String videoId,
    required String transcription,
    String? language,
  });

  Future<void> markVideoMessageViewed(String videoId, String userId);

  // Shared media operations
  Future<String> shareMedia({
    required String messageId,
    required String conversationId,
    required String senderId,
    required MediaType type,
    required String mediaUrl,
    String? thumbnailUrl,
    String? fileName,
    required int fileSize,
    String? mimeType,
    int? width,
    int? height,
  });

  Future<SharedMedia?> getSharedMedia(String mediaId);

  Future<List<SharedMedia>> getConversationSharedMedia(
    String conversationId, {
    MediaType? filterType,
    int limit = 50,
  });

  Future<void> markSharedMediaViewed(String mediaId, String userId);

  // Call operations
  Future<String> initiateCall({
    required String conversationId,
    required String initiatorId,
    required List<String> participantIds,
    required CallType callType,
  });

  Future<MediaCall?> getCall(String callId);

  Future<List<MediaCall>> getConversationCalls(
    String conversationId, {
    int limit = 50,
  });

  Future<void> updateCallStatus(String callId, CallStatus status);

  Future<void> declineCall(String callId, String userId);

  Future<void> endCall({
    required String callId,
    required int durationSeconds,
  });

  Future<void> recordCall({
    required String callId,
    required String recordingUrl,
  });

  // Media metadata operations
  Future<String> storeMediaMetadata({
    required String mediaId,
    String? width,
    String? height,
    String? duration,
    String? fileSize,
    String? codec,
    String? bitrate,
    String? framerate,
  });

  Future<MediaMetadata?> getMediaMetadata(String metadataId);

  // Media upload progress tracking
  Future<void> trackMediaUploadProgress({
    required String uploadId,
    required String mediaId,
    required int progress,
    required int bytesUploaded,
    required int totalBytes,
    Duration? estimatedTimeRemaining,
  });

  Future<MediaUploadProgress?> getUploadProgress(String uploadId);

  // Statistics operations
  Future<int> getTotalVoiceMessagesCount(String conversationId);

  Future<int> getTotalVideoMessagesCount(String conversationId);

  Future<int> getTotalSharedMediaCount(String conversationId);

  Future<int> getTotalCallsCount(String conversationId);

  // Search and filter operations
  Future<List<VoiceMessage>> searchVoiceMessages({
    required String conversationId,
    required String query,
    int limit = 50,
  });

  Future<List<VideoMessage>> searchVideoMessages({
    required String conversationId,
    required String query,
    int limit = 50,
  });

  Future<List<SharedMedia>> searchSharedMedia({
    required String conversationId,
    required String query,
    int limit = 50,
  });
}

/// Firebase implementation of media messaging service
class FirebaseMediaMessagingService implements MediaMessagingService {
  final FirebaseFirestore _db;

  FirebaseMediaMessagingService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<String> sendVoiceMessage({
    required String messageId,
    required String conversationId,
    required String senderId,
    required String audioUrl,
    required Duration duration,
    required int fileSize,
  }) async {
    final voiceId = _db.collection('voiceMessages').doc().id;
    final voiceMessage = VoiceMessage(
      voiceId: voiceId,
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      audioUrl: audioUrl,
      duration: duration,
      fileSize: fileSize,
      createdAt: DateTime.now(),
    );

    await _db.collection('voiceMessages').doc(voiceId).set(voiceMessage.toMap());

    // Update conversation media stats
    await _updateConversationMediaStats(conversationId);

    return voiceId;
  }

  @override
  Future<VoiceMessage?> getVoiceMessage(String voiceId) async {
    final doc = await _db.collection('voiceMessages').doc(voiceId).get();
    if (!doc.exists) return null;
    return VoiceMessage.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<VoiceMessage>> getConversationVoiceMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    final query = _db
        .collection('voiceMessages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => VoiceMessage.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> setVoiceMessageTranscription({
    required String voiceId,
    required String transcription,
    String? language,
  }) async {
    await _db.collection('voiceMessages').doc(voiceId).update({
      'transcription': transcription,
      'isTranscribed': true,
      'transcriptionLanguage': language,
    });
  }

  @override
  Future<void> markVoiceMessageViewed(String voiceId, String userId) async {
    await _db.collection('voiceMessages').doc(voiceId).update({
      'viewedBy': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<String> sendVideoMessage({
    required String messageId,
    required String conversationId,
    required String senderId,
    required String videoUrl,
    String? thumbnailUrl,
    required Duration duration,
    required int fileSize,
    int? width,
    int? height,
    String? codec,
  }) async {
    final videoId = _db.collection('videoMessages').doc().id;
    final videoMessage = VideoMessage(
      videoId: videoId,
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      duration: duration,
      fileSize: fileSize,
      width: width,
      height: height,
      codec: codec,
      createdAt: DateTime.now(),
    );

    await _db.collection('videoMessages').doc(videoId).set(videoMessage.toMap());

    // Update conversation media stats
    await _updateConversationMediaStats(conversationId);

    return videoId;
  }

  @override
  Future<VideoMessage?> getVideoMessage(String videoId) async {
    final doc = await _db.collection('videoMessages').doc(videoId).get();
    if (!doc.exists) return null;
    return VideoMessage.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<VideoMessage>> getConversationVideoMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    final query = _db
        .collection('videoMessages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => VideoMessage.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> setVideoMessageTranscription({
    required String videoId,
    required String transcription,
    String? language,
  }) async {
    await _db.collection('videoMessages').doc(videoId).update({
      'transcription': transcription,
      'isTranscribed': true,
      'transcriptionLanguage': language,
    });
  }

  @override
  Future<void> markVideoMessageViewed(String videoId, String userId) async {
    await _db.collection('videoMessages').doc(videoId).update({
      'viewedBy': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<String> shareMedia({
    required String messageId,
    required String conversationId,
    required String senderId,
    required MediaType type,
    required String mediaUrl,
    String? thumbnailUrl,
    String? fileName,
    required int fileSize,
    String? mimeType,
    int? width,
    int? height,
  }) async {
    final mediaId = _db.collection('sharedMedia').doc().id;
    final media = SharedMedia(
      mediaId: mediaId,
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      type: type,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType,
      width: width,
      height: height,
      createdAt: DateTime.now(),
    );

    await _db.collection('sharedMedia').doc(mediaId).set(media.toMap());

    // Update conversation media stats
    await _updateConversationMediaStats(conversationId);

    return mediaId;
  }

  @override
  Future<SharedMedia?> getSharedMedia(String mediaId) async {
    final doc = await _db.collection('sharedMedia').doc(mediaId).get();
    if (!doc.exists) return null;
    return SharedMedia.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<SharedMedia>> getConversationSharedMedia(
    String conversationId, {
    MediaType? filterType,
    int limit = 50,
  }) async {
    Query query = _db
        .collection('sharedMedia')
        .where('conversationId', isEqualTo: conversationId);

    if (filterType != null) {
      query = query.where('type', isEqualTo: filterType.index);
    }

    query = query.orderBy('createdAt', descending: true).limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => SharedMedia.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markSharedMediaViewed(String mediaId, String userId) async {
    await _db.collection('sharedMedia').doc(mediaId).update({
      'viewedBy': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<String> initiateCall({
    required String conversationId,
    required String initiatorId,
    required List<String> participantIds,
    required CallType callType,
  }) async {
    final callId = _db.collection('mediaCalls').doc().id;
    final call = MediaCall(
      callId: callId,
      conversationId: conversationId,
      initiatorId: initiatorId,
      participantIds: participantIds,
      callType: callType,
      status: CallStatus.initiating,
      initiatedAt: DateTime.now(),
    );

    await _db.collection('mediaCalls').doc(callId).set(call.toMap());

    // Update conversation media stats
    await _updateConversationMediaStats(conversationId);

    return callId;
  }

  @override
  Future<MediaCall?> getCall(String callId) async {
    final doc = await _db.collection('mediaCalls').doc(callId).get();
    if (!doc.exists) return null;
    return MediaCall.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<MediaCall>> getConversationCalls(
    String conversationId, {
    int limit = 50,
  }) async {
    final query = _db
        .collection('mediaCalls')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('initiatedAt', descending: true)
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => MediaCall.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateCallStatus(String callId, CallStatus status) async {
    final updateData = {'status': status.index};

    if (status == CallStatus.active) {
      updateData['connectedAt'] = Timestamp.now();
    } else if (status == CallStatus.ended) {
      updateData['endedAt'] = Timestamp.now();
    }

    await _db.collection('mediaCalls').doc(callId).update(updateData);
  }

  @override
  Future<void> declineCall(String callId, String userId) async {
    await _db.collection('mediaCalls').doc(callId).update({
      'declinedBy': FieldValue.arrayUnion([userId]),
      'status': CallStatus.declined.index,
    });
  }

  @override
  Future<void> endCall({
    required String callId,
    required int durationSeconds,
  }) async {
    await _db.collection('mediaCalls').doc(callId).update({
      'status': CallStatus.ended.index,
      'endedAt': Timestamp.now(),
      'durationSeconds': durationSeconds,
    });
  }

  @override
  Future<void> recordCall({
    required String callId,
    required String recordingUrl,
  }) async {
    await _db.collection('mediaCalls').doc(callId).update({
      'recordingUrl': recordingUrl,
      'isRecorded': true,
    });
  }

  @override
  Future<String> storeMediaMetadata({
    required String mediaId,
    String? width,
    String? height,
    String? duration,
    String? fileSize,
    String? codec,
    String? bitrate,
    String? framerate,
  }) async {
    final metadataId = _db.collection('mediaMetadata').doc().id;
    final metadata = MediaMetadata(
      metadataId: metadataId,
      mediaId: mediaId,
      width: width,
      height: height,
      duration: duration,
      fileSize: fileSize,
      codec: codec,
      bitrate: bitrate,
      framerate: framerate,
      createdAt: DateTime.now(),
    );

    await _db.collection('mediaMetadata').doc(metadataId).set(metadata.toMap());

    return metadataId;
  }

  @override
  Future<MediaMetadata?> getMediaMetadata(String metadataId) async {
    final doc = await _db.collection('mediaMetadata').doc(metadataId).get();
    if (!doc.exists) return null;
    return MediaMetadata.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> trackMediaUploadProgress({
    required String uploadId,
    required String mediaId,
    required int progress,
    required int bytesUploaded,
    required int totalBytes,
    Duration? estimatedTimeRemaining,
  }) async {
    final progressDoc = MediaUploadProgress(
      uploadId: uploadId,
      mediaId: mediaId,
      progress: progress,
      bytesUploaded: bytesUploaded,
      totalBytes: totalBytes,
      startedAt: DateTime.now(),
      estimatedTimeRemaining: estimatedTimeRemaining,
      isComplete: progress == 100,
    );

    await _db
        .collection('mediaUploadProgress')
        .doc(uploadId)
        .set(progressDoc.toMap(), SetOptions(merge: true));
  }

  @override
  Future<MediaUploadProgress?> getUploadProgress(String uploadId) async {
    final doc = await _db.collection('mediaUploadProgress').doc(uploadId).get();
    if (!doc.exists) return null;
    return MediaUploadProgress.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<int> getTotalVoiceMessagesCount(String conversationId) async {
    final query = _db
        .collection('voiceMessages')
        .where('conversationId', isEqualTo: conversationId);

    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<int> getTotalVideoMessagesCount(String conversationId) async {
    final query = _db
        .collection('videoMessages')
        .where('conversationId', isEqualTo: conversationId);

    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<int> getTotalSharedMediaCount(String conversationId) async {
    final query = _db
        .collection('sharedMedia')
        .where('conversationId', isEqualTo: conversationId);

    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<int> getTotalCallsCount(String conversationId) async {
    final query = _db
        .collection('mediaCalls')
        .where('conversationId', isEqualTo: conversationId);

    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<List<VoiceMessage>> searchVoiceMessages({
    required String conversationId,
    required String query,
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('voiceMessages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    final allMessages = snapshot.docs
        .map((doc) => VoiceMessage.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    // Filter by transcription if available
    return allMessages
        .where((msg) =>
            msg.transcription?.toLowerCase().contains(query.toLowerCase()) ??
            false)
        .toList();
  }

  @override
  Future<List<VideoMessage>> searchVideoMessages({
    required String conversationId,
    required String query,
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('videoMessages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    final allMessages = snapshot.docs
        .map((doc) => VideoMessage.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    // Filter by transcription if available
    return allMessages
        .where((msg) =>
            msg.transcription?.toLowerCase().contains(query.toLowerCase()) ??
            false)
        .toList();
  }

  @override
  Future<List<SharedMedia>> searchSharedMedia({
    required String conversationId,
    required String query,
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('sharedMedia')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    final allMedia = snapshot.docs
        .map((doc) => SharedMedia.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    // Filter by filename or type
    return allMedia
        .where((media) =>
            media.fileName?.toLowerCase().contains(query.toLowerCase()) ??
            false)
        .toList();
  }

  Future<void> _updateConversationMediaStats(String conversationId) async {
    final voiceCount = await getTotalVoiceMessagesCount(conversationId);
    final videoCount = await getTotalVideoMessagesCount(conversationId);
    final mediaCount = await getTotalSharedMediaCount(conversationId);
    final callCount = await getTotalCallsCount(conversationId);

    await _db.collection('conversationMediaStats').doc(conversationId).set({
      'conversationId': conversationId,
      'totalVoiceMessages': voiceCount,
      'totalVideoMessages': videoCount,
      'totalSharedMedia': mediaCount,
      'totalCalls': callCount,
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}

/// Stub implementation for testing
class StubMediaMessagingService implements MediaMessagingService {
  final Map<String, VoiceMessage> _voiceMessages = {};
  final Map<String, VideoMessage> _videoMessages = {};
  final Map<String, SharedMedia> _sharedMedia = {};
  final Map<String, MediaCall> _calls = {};
  final Map<String, MediaMetadata> _metadata = {};
  final Map<String, MediaUploadProgress> _uploadProgress = {};

  @override
  Future<String> sendVoiceMessage({
    required String messageId,
    required String conversationId,
    required String senderId,
    required String audioUrl,
    required Duration duration,
    required int fileSize,
  }) async {
    final voiceId = 'voice_${_voiceMessages.length}';
    _voiceMessages[voiceId] = VoiceMessage(
      voiceId: voiceId,
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      audioUrl: audioUrl,
      duration: duration,
      fileSize: fileSize,
      createdAt: DateTime.now(),
    );
    return voiceId;
  }

  @override
  Future<VoiceMessage?> getVoiceMessage(String voiceId) async {
    return _voiceMessages[voiceId];
  }

  @override
  Future<List<VoiceMessage>> getConversationVoiceMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    return _voiceMessages.values
        .where((msg) => msg.conversationId == conversationId)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  @override
  Future<void> setVoiceMessageTranscription({
    required String voiceId,
    required String transcription,
    String? language,
  }) async {
    final msg = _voiceMessages[voiceId];
    if (msg != null) {
      _voiceMessages[voiceId] = msg.copyWith(
        transcription: transcription,
        isTranscribed: true,
        transcriptionLanguage: language,
      );
    }
  }

  @override
  Future<void> markVoiceMessageViewed(String voiceId, String userId) async {
    final msg = _voiceMessages[voiceId];
    if (msg != null) {
      final updatedViewedBy = [...msg.viewedBy];
      if (!updatedViewedBy.contains(userId)) {
        updatedViewedBy.add(userId);
      }
      _voiceMessages[voiceId] =
          msg.copyWith(viewedBy: updatedViewedBy);
    }
  }

  @override
  Future<String> sendVideoMessage({
    required String messageId,
    required String conversationId,
    required String senderId,
    required String videoUrl,
    String? thumbnailUrl,
    required Duration duration,
    required int fileSize,
    int? width,
    int? height,
    String? codec,
  }) async {
    final videoId = 'video_${_videoMessages.length}';
    _videoMessages[videoId] = VideoMessage(
      videoId: videoId,
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      duration: duration,
      fileSize: fileSize,
      width: width,
      height: height,
      codec: codec,
      createdAt: DateTime.now(),
    );
    return videoId;
  }

  @override
  Future<VideoMessage?> getVideoMessage(String videoId) async {
    return _videoMessages[videoId];
  }

  @override
  Future<List<VideoMessage>> getConversationVideoMessages(
    String conversationId, {
    int limit = 50,
  }) async {
    return _videoMessages.values
        .where((msg) => msg.conversationId == conversationId)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  @override
  Future<void> setVideoMessageTranscription({
    required String videoId,
    required String transcription,
    String? language,
  }) async {
    final msg = _videoMessages[videoId];
    if (msg != null) {
      _videoMessages[videoId] = msg.copyWith(
        transcription: transcription,
        isTranscribed: true,
        transcriptionLanguage: language,
      );
    }
  }

  @override
  Future<void> markVideoMessageViewed(String videoId, String userId) async {
    final msg = _videoMessages[videoId];
    if (msg != null) {
      final updatedViewedBy = [...msg.viewedBy];
      if (!updatedViewedBy.contains(userId)) {
        updatedViewedBy.add(userId);
      }
      _videoMessages[videoId] =
          msg.copyWith(viewedBy: updatedViewedBy);
    }
  }

  @override
  Future<String> shareMedia({
    required String messageId,
    required String conversationId,
    required String senderId,
    required MediaType type,
    required String mediaUrl,
    String? thumbnailUrl,
    String? fileName,
    required int fileSize,
    String? mimeType,
    int? width,
    int? height,
  }) async {
    final mediaId = 'media_${_sharedMedia.length}';
    _sharedMedia[mediaId] = SharedMedia(
      mediaId: mediaId,
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      type: type,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType,
      width: width,
      height: height,
      createdAt: DateTime.now(),
    );
    return mediaId;
  }

  @override
  Future<SharedMedia?> getSharedMedia(String mediaId) async {
    return _sharedMedia[mediaId];
  }

  @override
  Future<List<SharedMedia>> getConversationSharedMedia(
    String conversationId, {
    MediaType? filterType,
    int limit = 50,
  }) async {
    var filtered = _sharedMedia.values
        .where((media) => media.conversationId == conversationId)
        .toList();

    if (filterType != null) {
      filtered = filtered.where((media) => media.type == filterType).toList();
    }

    return filtered.reversed.take(limit).toList();
  }

  @override
  Future<void> markSharedMediaViewed(String mediaId, String userId) async {
    final media = _sharedMedia[mediaId];
    if (media != null) {
      final updatedViewedBy = [...media.viewedBy];
      if (!updatedViewedBy.contains(userId)) {
        updatedViewedBy.add(userId);
      }
      _sharedMedia[mediaId] =
          media.copyWith(viewedBy: updatedViewedBy);
    }
  }

  @override
  Future<String> initiateCall({
    required String conversationId,
    required String initiatorId,
    required List<String> participantIds,
    required CallType callType,
  }) async {
    final callId = 'call_${_calls.length}';
    _calls[callId] = MediaCall(
      callId: callId,
      conversationId: conversationId,
      initiatorId: initiatorId,
      participantIds: participantIds,
      callType: callType,
      status: CallStatus.initiating,
      initiatedAt: DateTime.now(),
    );
    return callId;
  }

  @override
  Future<MediaCall?> getCall(String callId) async {
    return _calls[callId];
  }

  @override
  Future<List<MediaCall>> getConversationCalls(
    String conversationId, {
    int limit = 50,
  }) async {
    return _calls.values
        .where((call) => call.conversationId == conversationId)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  @override
  Future<void> updateCallStatus(String callId, CallStatus status) async {
    final call = _calls[callId];
    if (call != null) {
      var updatedCall = call.copyWith(status: status);

      if (status == CallStatus.active) {
        updatedCall = updatedCall.copyWith(
          connectedAt: DateTime.now(),
        );
      } else if (status == CallStatus.ended) {
        updatedCall = updatedCall.copyWith(
          endedAt: DateTime.now(),
        );
      }

      _calls[callId] = updatedCall;
    }
  }

  @override
  Future<void> declineCall(String callId, String userId) async {
    final call = _calls[callId];
    if (call != null) {
      final updatedDeclinedBy = [...call.declinedBy];
      if (!updatedDeclinedBy.contains(userId)) {
        updatedDeclinedBy.add(userId);
      }
      _calls[callId] = call.copyWith(
        status: CallStatus.declined,
        declinedBy: updatedDeclinedBy,
      );
    }
  }

  @override
  Future<void> endCall({
    required String callId,
    required int durationSeconds,
  }) async {
    final call = _calls[callId];
    if (call != null) {
      _calls[callId] = call.copyWith(
        status: CallStatus.ended,
        endedAt: DateTime.now(),
        durationSeconds: durationSeconds,
      );
    }
  }

  @override
  Future<void> recordCall({
    required String callId,
    required String recordingUrl,
  }) async {
    final call = _calls[callId];
    if (call != null) {
      _calls[callId] = call.copyWith(
        recordingUrl: recordingUrl,
        isRecorded: true,
      );
    }
  }

  @override
  Future<String> storeMediaMetadata({
    required String mediaId,
    String? width,
    String? height,
    String? duration,
    String? fileSize,
    String? codec,
    String? bitrate,
    String? framerate,
  }) async {
    final metadataId = 'metadata_${_metadata.length}';
    _metadata[metadataId] = MediaMetadata(
      metadataId: metadataId,
      mediaId: mediaId,
      width: width,
      height: height,
      duration: duration,
      fileSize: fileSize,
      codec: codec,
      bitrate: bitrate,
      framerate: framerate,
      createdAt: DateTime.now(),
    );
    return metadataId;
  }

  @override
  Future<MediaMetadata?> getMediaMetadata(String metadataId) async {
    return _metadata[metadataId];
  }

  @override
  Future<void> trackMediaUploadProgress({
    required String uploadId,
    required String mediaId,
    required int progress,
    required int bytesUploaded,
    required int totalBytes,
    Duration? estimatedTimeRemaining,
  }) async {
    _uploadProgress[uploadId] = MediaUploadProgress(
      uploadId: uploadId,
      mediaId: mediaId,
      progress: progress,
      bytesUploaded: bytesUploaded,
      totalBytes: totalBytes,
      startedAt: DateTime.now(),
      estimatedTimeRemaining: estimatedTimeRemaining,
      isComplete: progress == 100,
    );
  }

  @override
  Future<MediaUploadProgress?> getUploadProgress(String uploadId) async {
    return _uploadProgress[uploadId];
  }

  @override
  Future<int> getTotalVoiceMessagesCount(String conversationId) async {
    return _voiceMessages.values
        .where((msg) => msg.conversationId == conversationId)
        .length;
  }

  @override
  Future<int> getTotalVideoMessagesCount(String conversationId) async {
    return _videoMessages.values
        .where((msg) => msg.conversationId == conversationId)
        .length;
  }

  @override
  Future<int> getTotalSharedMediaCount(String conversationId) async {
    return _sharedMedia.values
        .where((media) => media.conversationId == conversationId)
        .length;
  }

  @override
  Future<int> getTotalCallsCount(String conversationId) async {
    return _calls.values
        .where((call) => call.conversationId == conversationId)
        .length;
  }

  @override
  Future<List<VoiceMessage>> searchVoiceMessages({
    required String conversationId,
    required String query,
    int limit = 50,
  }) async {
    return _voiceMessages.values
        .where((msg) =>
            msg.conversationId == conversationId &&
            (msg.transcription?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<VideoMessage>> searchVideoMessages({
    required String conversationId,
    required String query,
    int limit = 50,
  }) async {
    return _videoMessages.values
        .where((msg) =>
            msg.conversationId == conversationId &&
            (msg.transcription?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<SharedMedia>> searchSharedMedia({
    required String conversationId,
    required String query,
    int limit = 50,
  }) async {
    return _sharedMedia.values
        .where((media) =>
            media.conversationId == conversationId &&
            (media.fileName?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList()
        .take(limit)
        .toList();
  }
}
