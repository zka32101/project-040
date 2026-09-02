import 'package:cloud_firestore/cloud_firestore.dart';

/// Media messaging system enums
enum MediaType { voice, video, image, file, document }

enum MediaStatus { uploading, uploaded, processing, transcribing, failed }

enum CallStatus { initiating, ringing, connecting, active, ended, declined, missed }

enum CallType { voiceCall, videoCall }

/// Voice message model
class VoiceMessage {
  final String voiceId;
  final String messageId;
  final String conversationId;
  final String senderId;
  final String audioUrl;
  final String? transcription;
  final Duration duration;
  final int fileSize; // in bytes
  final DateTime createdAt;
  final bool isTranscribed;
  final String? transcriptionLanguage;
  final List<String> viewedBy;

  VoiceMessage({
    required this.voiceId,
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.audioUrl,
    this.transcription,
    required this.duration,
    required this.fileSize,
    required this.createdAt,
    this.isTranscribed = false,
    this.transcriptionLanguage,
    this.viewedBy = const [],
  });

  int get durationSeconds => duration.inSeconds;
  double get durationMinutes => durationSeconds / 60.0;
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  factory VoiceMessage.empty() {
    return VoiceMessage(
      voiceId: '',
      messageId: '',
      conversationId: '',
      senderId: '',
      audioUrl: '',
      duration: Duration.zero,
      fileSize: 0,
      createdAt: DateTime.now(),
    );
  }

  factory VoiceMessage.fromMap(Map<String, dynamic> map) {
    return VoiceMessage(
      voiceId: map['voiceId'] as String? ?? '',
      messageId: map['messageId'] as String? ?? '',
      conversationId: map['conversationId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      audioUrl: map['audioUrl'] as String? ?? '',
      transcription: map['transcription'] as String?,
      duration: Duration(seconds: map['durationSeconds'] as int? ?? 0),
      fileSize: map['fileSize'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isTranscribed: map['isTranscribed'] as bool? ?? false,
      transcriptionLanguage: map['transcriptionLanguage'] as String?,
      viewedBy: List<String>.from(map['viewedBy'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'voiceId': voiceId,
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'audioUrl': audioUrl,
      'transcription': transcription,
      'durationSeconds': durationSeconds,
      'fileSize': fileSize,
      'createdAt': Timestamp.fromDate(createdAt),
      'isTranscribed': isTranscribed,
      'transcriptionLanguage': transcriptionLanguage,
      'viewedBy': viewedBy,
    };
  }

  VoiceMessage copyWith({
    String? transcription,
    bool? isTranscribed,
    String? transcriptionLanguage,
    List<String>? viewedBy,
  }) {
    return VoiceMessage(
      voiceId: voiceId,
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      audioUrl: audioUrl,
      transcription: transcription ?? this.transcription,
      duration: duration,
      fileSize: fileSize,
      createdAt: createdAt,
      isTranscribed: isTranscribed ?? this.isTranscribed,
      transcriptionLanguage: transcriptionLanguage ?? this.transcriptionLanguage,
      viewedBy: viewedBy ?? this.viewedBy,
    );
  }
}

/// Video message model
class VideoMessage {
  final String videoId;
  final String messageId;
  final String conversationId;
  final String senderId;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? transcription;
  final Duration duration;
  final int fileSize; // in bytes
  final int? width;
  final int? height;
  final String? codec;
  final DateTime createdAt;
  final bool isTranscribed;
  final String? transcriptionLanguage;
  final List<String> viewedBy;

  VideoMessage({
    required this.videoId,
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.videoUrl,
    this.thumbnailUrl,
    this.transcription,
    required this.duration,
    required this.fileSize,
    this.width,
    this.height,
    this.codec,
    required this.createdAt,
    this.isTranscribed = false,
    this.transcriptionLanguage,
    this.viewedBy = const [],
  });

  int get durationSeconds => duration.inSeconds;
  double get durationMinutes => durationSeconds / 60.0;
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  factory VideoMessage.empty() {
    return VideoMessage(
      videoId: '',
      messageId: '',
      conversationId: '',
      senderId: '',
      videoUrl: '',
      duration: Duration.zero,
      fileSize: 0,
      createdAt: DateTime.now(),
    );
  }

  factory VideoMessage.fromMap(Map<String, dynamic> map) {
    return VideoMessage(
      videoId: map['videoId'] as String? ?? '',
      messageId: map['messageId'] as String? ?? '',
      conversationId: map['conversationId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      videoUrl: map['videoUrl'] as String? ?? '',
      thumbnailUrl: map['thumbnailUrl'] as String?,
      transcription: map['transcription'] as String?,
      duration: Duration(seconds: map['durationSeconds'] as int? ?? 0),
      fileSize: map['fileSize'] as int? ?? 0,
      width: map['width'] as int?,
      height: map['height'] as int?,
      codec: map['codec'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isTranscribed: map['isTranscribed'] as bool? ?? false,
      transcriptionLanguage: map['transcriptionLanguage'] as String?,
      viewedBy: List<String>.from(map['viewedBy'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'videoId': videoId,
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'transcription': transcription,
      'durationSeconds': durationSeconds,
      'fileSize': fileSize,
      'width': width,
      'height': height,
      'codec': codec,
      'createdAt': Timestamp.fromDate(createdAt),
      'isTranscribed': isTranscribed,
      'transcriptionLanguage': transcriptionLanguage,
      'viewedBy': viewedBy,
    };
  }

  VideoMessage copyWith({
    String? thumbnailUrl,
    String? transcription,
    bool? isTranscribed,
    String? transcriptionLanguage,
    List<String>? viewedBy,
  }) {
    return VideoMessage(
      videoId: videoId,
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      transcription: transcription ?? this.transcription,
      duration: duration,
      fileSize: fileSize,
      width: width,
      height: height,
      codec: codec,
      createdAt: createdAt,
      isTranscribed: isTranscribed ?? this.isTranscribed,
      transcriptionLanguage: transcriptionLanguage ?? this.transcriptionLanguage,
      viewedBy: viewedBy ?? this.viewedBy,
    );
  }
}

/// Shared media model (photos, documents, files)
class SharedMedia {
  final String mediaId;
  final String messageId;
  final String conversationId;
  final String senderId;
  final MediaType type; // image, document, file
  final String mediaUrl;
  final String? thumbnailUrl;
  final String? fileName;
  final int fileSize; // in bytes
  final String? mimeType;
  final int? width;
  final int? height;
  final DateTime createdAt;
  final List<String> viewedBy;

  SharedMedia({
    required this.mediaId,
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.fileName,
    required this.fileSize,
    this.mimeType,
    this.width,
    this.height,
    required this.createdAt,
    this.viewedBy = const [],
  });

  String get readableFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  factory SharedMedia.empty() {
    return SharedMedia(
      mediaId: '',
      messageId: '',
      conversationId: '',
      senderId: '',
      type: MediaType.image,
      mediaUrl: '',
      fileSize: 0,
      createdAt: DateTime.now(),
    );
  }

  factory SharedMedia.fromMap(Map<String, dynamic> map) {
    return SharedMedia(
      mediaId: map['mediaId'] as String? ?? '',
      messageId: map['messageId'] as String? ?? '',
      conversationId: map['conversationId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      type: MediaType.values[(map['type'] as int?) ?? MediaType.image.index],
      mediaUrl: map['mediaUrl'] as String? ?? '',
      thumbnailUrl: map['thumbnailUrl'] as String?,
      fileName: map['fileName'] as String?,
      fileSize: map['fileSize'] as int? ?? 0,
      mimeType: map['mimeType'] as String?,
      width: map['width'] as int?,
      height: map['height'] as int?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      viewedBy: List<String>.from(map['viewedBy'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mediaId': mediaId,
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'type': type.index,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'width': width,
      'height': height,
      'createdAt': Timestamp.fromDate(createdAt),
      'viewedBy': viewedBy,
    };
  }

  SharedMedia copyWith({
    String? thumbnailUrl,
    List<String>? viewedBy,
  }) {
    return SharedMedia(
      mediaId: mediaId,
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      type: type,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType,
      width: width,
      height: height,
      createdAt: createdAt,
      viewedBy: viewedBy ?? this.viewedBy,
    );
  }
}

/// Voice/Video call model
class MediaCall {
  final String callId;
  final String conversationId;
  final String initiatorId;
  final List<String> participantIds;
  final CallType callType;
  final CallStatus status;
  final DateTime initiatedAt;
  final DateTime? connectedAt;
  final DateTime? endedAt;
  final int? durationSeconds;
  final List<String> declinedBy;
  final String? recordingUrl;
  final bool isRecorded;

  MediaCall({
    required this.callId,
    required this.conversationId,
    required this.initiatorId,
    required this.participantIds,
    required this.callType,
    required this.status,
    required this.initiatedAt,
    this.connectedAt,
    this.endedAt,
    this.durationSeconds,
    this.declinedBy = const [],
    this.recordingUrl,
    this.isRecorded = false,
  });

  bool get isActive => status == CallStatus.active;
  bool get isEnded => status == CallStatus.ended || status == CallStatus.declined;
  int get callDurationSeconds {
    if (connectedAt == null || endedAt == null) return 0;
    return endedAt!.difference(connectedAt!).inSeconds;
  }

  factory MediaCall.empty() {
    return MediaCall(
      callId: '',
      conversationId: '',
      initiatorId: '',
      participantIds: [],
      callType: CallType.voiceCall,
      status: CallStatus.initiating,
      initiatedAt: DateTime.now(),
    );
  }

  factory MediaCall.fromMap(Map<String, dynamic> map) {
    return MediaCall(
      callId: map['callId'] as String? ?? '',
      conversationId: map['conversationId'] as String? ?? '',
      initiatorId: map['initiatorId'] as String? ?? '',
      participantIds: List<String>.from(map['participantIds'] as List? ?? []),
      callType: CallType.values[(map['callType'] as int?) ?? CallType.voiceCall.index],
      status: CallStatus.values[(map['status'] as int?) ?? CallStatus.initiating.index],
      initiatedAt: (map['initiatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      connectedAt: (map['connectedAt'] as Timestamp?)?.toDate(),
      endedAt: (map['endedAt'] as Timestamp?)?.toDate(),
      durationSeconds: map['durationSeconds'] as int?,
      declinedBy: List<String>.from(map['declinedBy'] as List? ?? []),
      recordingUrl: map['recordingUrl'] as String?,
      isRecorded: map['isRecorded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'conversationId': conversationId,
      'initiatorId': initiatorId,
      'participantIds': participantIds,
      'callType': callType.index,
      'status': status.index,
      'initiatedAt': Timestamp.fromDate(initiatedAt),
      'connectedAt': connectedAt != null ? Timestamp.fromDate(connectedAt!) : null,
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'durationSeconds': durationSeconds,
      'declinedBy': declinedBy,
      'recordingUrl': recordingUrl,
      'isRecorded': isRecorded,
    };
  }

  MediaCall copyWith({
    CallStatus? status,
    DateTime? connectedAt,
    DateTime? endedAt,
    int? durationSeconds,
    List<String>? declinedBy,
    String? recordingUrl,
    bool? isRecorded,
  }) {
    return MediaCall(
      callId: callId,
      conversationId: conversationId,
      initiatorId: initiatorId,
      participantIds: participantIds,
      callType: callType,
      status: status ?? this.status,
      initiatedAt: initiatedAt,
      connectedAt: connectedAt ?? this.connectedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      declinedBy: declinedBy ?? this.declinedBy,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      isRecorded: isRecorded ?? this.isRecorded,
    );
  }
}

/// Media metadata model
class MediaMetadata {
  final String metadataId;
  final String mediaId;
  final String? width;
  final String? height;
  final String? duration;
  final String? fileSize;
  final String? codec;
  final String? bitrate;
  final String? framerate;
  final DateTime createdAt;

  MediaMetadata({
    required this.metadataId,
    required this.mediaId,
    this.width,
    this.height,
    this.duration,
    this.fileSize,
    this.codec,
    this.bitrate,
    this.framerate,
    required this.createdAt,
  });

  factory MediaMetadata.empty() {
    return MediaMetadata(
      metadataId: '',
      mediaId: '',
      createdAt: DateTime.now(),
    );
  }

  factory MediaMetadata.fromMap(Map<String, dynamic> map) {
    return MediaMetadata(
      metadataId: map['metadataId'] as String? ?? '',
      mediaId: map['mediaId'] as String? ?? '',
      width: map['width'] as String?,
      height: map['height'] as String?,
      duration: map['duration'] as String?,
      fileSize: map['fileSize'] as String?,
      codec: map['codec'] as String?,
      bitrate: map['bitrate'] as String?,
      framerate: map['framerate'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'metadataId': metadataId,
      'mediaId': mediaId,
      'width': width,
      'height': height,
      'duration': duration,
      'fileSize': fileSize,
      'codec': codec,
      'bitrate': bitrate,
      'framerate': framerate,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// Media upload progress model
class MediaUploadProgress {
  final String uploadId;
  final String mediaId;
  final int progress; // 0-100
  final int bytesUploaded;
  final int totalBytes;
  final DateTime startedAt;
  final Duration? estimatedTimeRemaining;
  final bool isComplete;
  final String? error;

  MediaUploadProgress({
    required this.uploadId,
    required this.mediaId,
    required this.progress,
    required this.bytesUploaded,
    required this.totalBytes,
    required this.startedAt,
    this.estimatedTimeRemaining,
    this.isComplete = false,
    this.error,
  });

  double get uploadSpeed {
    final elapsed = DateTime.now().difference(startedAt).inSeconds;
    if (elapsed == 0) return 0;
    return bytesUploaded / elapsed;
  }

  factory MediaUploadProgress.empty() {
    return MediaUploadProgress(
      uploadId: '',
      mediaId: '',
      progress: 0,
      bytesUploaded: 0,
      totalBytes: 0,
      startedAt: DateTime.now(),
    );
  }

  factory MediaUploadProgress.fromMap(Map<String, dynamic> map) {
    return MediaUploadProgress(
      uploadId: map['uploadId'] as String? ?? '',
      mediaId: map['mediaId'] as String? ?? '',
      progress: map['progress'] as int? ?? 0,
      bytesUploaded: map['bytesUploaded'] as int? ?? 0,
      totalBytes: map['totalBytes'] as int? ?? 0,
      startedAt: (map['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimatedTimeRemaining: map['estimatedTimeRemaining'] != null
          ? Duration(seconds: map['estimatedTimeRemaining'] as int)
          : null,
      isComplete: map['isComplete'] as bool? ?? false,
      error: map['error'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uploadId': uploadId,
      'mediaId': mediaId,
      'progress': progress,
      'bytesUploaded': bytesUploaded,
      'totalBytes': totalBytes,
      'startedAt': Timestamp.fromDate(startedAt),
      'estimatedTimeRemaining': estimatedTimeRemaining?.inSeconds,
      'isComplete': isComplete,
      'error': error,
    };
  }
}
