import 'package:cloud_firestore/cloud_firestore.dart';

/// Social features enums
enum FriendshipStatus { none, pending, accepted, blocked }

enum ActivityType { quiz_completed, achievement_unlocked, level_up, streak_milestone }

enum PrivacyLevel { public, friends, private }

enum GroupRole { owner, moderator, member }

/// Represents a friend relationship
class Friend {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final FriendshipStatus status;
  final DateTime addedAt;
  final DateTime? acceptedAt;

  Friend({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.status,
    required this.addedAt,
    this.acceptedAt,
  });

  bool get isPending => status == FriendshipStatus.pending;
  bool get isAccepted => status == FriendshipStatus.accepted;
  bool get isBlocked => status == FriendshipStatus.blocked;

  factory Friend.empty() {
    return Friend(
      userId: '',
      displayName: '',
      status: FriendshipStatus.none,
      addedAt: DateTime.now(),
    );
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      userId: map['userId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'User',
      avatarUrl: map['avatarUrl'] as String?,
      status: FriendshipStatus
          .values[(map['status'] as int?) ?? FriendshipStatus.none.index],
      addedAt: (map['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedAt: (map['acceptedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'status': status.index,
      'addedAt': Timestamp.fromDate(addedAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
    };
  }

  Friend copyWith({
    String? displayName,
    String? avatarUrl,
    FriendshipStatus? status,
    DateTime? acceptedAt,
  }) {
    return Friend(
      userId: userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      addedAt: addedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }
}

/// User activity for activity feed
class Activity {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final ActivityType type;
  final String description;
  final String? details;
  final int? pointsEarned;
  final DateTime createdAt;
  final bool isPublic;

  Activity({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.type,
    required this.description,
    this.details,
    this.pointsEarned,
    required this.createdAt,
    this.isPublic = true,
  });

  factory Activity.empty() {
    return Activity(
      userId: '',
      displayName: '',
      type: ActivityType.quiz_completed,
      description: '',
      createdAt: DateTime.now(),
    );
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      userId: map['userId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'User',
      avatarUrl: map['avatarUrl'] as String?,
      type: ActivityType
          .values[(map['type'] as int?) ?? ActivityType.quiz_completed.index],
      description: map['description'] as String? ?? '',
      details: map['details'] as String?,
      pointsEarned: map['pointsEarned'] as int?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublic: map['isPublic'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'type': type.index,
      'description': description,
      'details': details,
      'pointsEarned': pointsEarned,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublic': isPublic,
    };
  }
}

/// Study group for collaborative learning
class StudyGroup {
  final String groupId;
  final String name;
  final String? description;
  final String ownerId;
  final List<String> memberIds;
  final List<String> moderatorIds;
  final String? categoryFocus;
  final int maxMembers;
  final PrivacyLevel privacy;
  final DateTime createdAt;
  final DateTime? lastActivityAt;
  final int totalPoints;
  final int completedQuizzes;

  StudyGroup({
    required this.groupId,
    required this.name,
    this.description,
    required this.ownerId,
    required this.memberIds,
    required this.moderatorIds,
    this.categoryFocus,
    this.maxMembers = 50,
    this.privacy = PrivacyLevel.private,
    required this.createdAt,
    this.lastActivityAt,
    this.totalPoints = 0,
    this.completedQuizzes = 0,
  });

  bool get isFull => memberIds.length >= maxMembers;
  int get memberCount => memberIds.length;
  bool get isPublic => privacy == PrivacyLevel.public;

  factory StudyGroup.empty(String groupId) {
    return StudyGroup(
      groupId: groupId,
      name: 'Study Group',
      ownerId: '',
      memberIds: [],
      moderatorIds: [],
      createdAt: DateTime.now(),
    );
  }

  factory StudyGroup.fromMap(Map<String, dynamic> map) {
    return StudyGroup(
      groupId: map['groupId'] as String? ?? '',
      name: map['name'] as String? ?? 'Study Group',
      description: map['description'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      memberIds: List<String>.from(map['memberIds'] as List? ?? []),
      moderatorIds: List<String>.from(map['moderatorIds'] as List? ?? []),
      categoryFocus: map['categoryFocus'] as String?,
      maxMembers: map['maxMembers'] as int? ?? 50,
      privacy: PrivacyLevel
          .values[(map['privacy'] as int?) ?? PrivacyLevel.private.index],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActivityAt: (map['lastActivityAt'] as Timestamp?)?.toDate(),
      totalPoints: map['totalPoints'] as int? ?? 0,
      completedQuizzes: map['completedQuizzes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'moderatorIds': moderatorIds,
      'categoryFocus': categoryFocus,
      'maxMembers': maxMembers,
      'privacy': privacy.index,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActivityAt':
          lastActivityAt != null ? Timestamp.fromDate(lastActivityAt!) : null,
      'totalPoints': totalPoints,
      'completedQuizzes': completedQuizzes,
    };
  }

  StudyGroup copyWith({
    String? name,
    String? description,
    List<String>? memberIds,
    List<String>? moderatorIds,
    String? categoryFocus,
    int? maxMembers,
    PrivacyLevel? privacy,
    DateTime? lastActivityAt,
    int? totalPoints,
    int? completedQuizzes,
  }) {
    return StudyGroup(
      groupId: groupId,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId,
      memberIds: memberIds ?? this.memberIds,
      moderatorIds: moderatorIds ?? this.moderatorIds,
      categoryFocus: categoryFocus ?? this.categoryFocus,
      maxMembers: maxMembers ?? this.maxMembers,
      privacy: privacy ?? this.privacy,
      createdAt: createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      totalPoints: totalPoints ?? this.totalPoints,
      completedQuizzes: completedQuizzes ?? this.completedQuizzes,
    );
  }
}

/// Group member details
class GroupMember {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final GroupRole role;
  final DateTime joinedAt;
  final int groupPoints;
  final int contributedQuizzes;
  final DateTime? lastActiveAt;

  GroupMember({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    required this.joinedAt,
    this.groupPoints = 0,
    this.contributedQuizzes = 0,
    this.lastActiveAt,
  });

  bool get isOwner => role == GroupRole.owner;
  bool get isModerator => role == GroupRole.moderator;
  bool get isRegularMember => role == GroupRole.member;

  factory GroupMember.fromMap(Map<String, dynamic> map) {
    return GroupMember(
      userId: map['userId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Member',
      avatarUrl: map['avatarUrl'] as String?,
      role: GroupRole.values[(map['role'] as int?) ?? GroupRole.member.index],
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      groupPoints: map['groupPoints'] as int? ?? 0,
      contributedQuizzes: map['contributedQuizzes'] as int? ?? 0,
      lastActiveAt: (map['lastActiveAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'role': role.index,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'groupPoints': groupPoints,
      'contributedQuizzes': contributedQuizzes,
      'lastActiveAt':
          lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
    };
  }
}

/// Shared achievement celebration
class SharedAchievement {
  final String achievementId;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final String achievementName;
  final String description;
  final int points;
  final DateTime unlockedAt;
  final List<String> celebrations; // User IDs who celebrated
  final String? message;

  SharedAchievement({
    required this.achievementId,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.achievementName,
    required this.description,
    required this.points,
    required this.unlockedAt,
    this.celebrations = const [],
    this.message,
  });

  int get celebrationCount => celebrations.length;

  factory SharedAchievement.fromMap(Map<String, dynamic> map) {
    return SharedAchievement(
      achievementId: map['achievementId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'User',
      avatarUrl: map['avatarUrl'] as String?,
      achievementName: map['achievementName'] as String? ?? '',
      description: map['description'] as String? ?? '',
      points: map['points'] as int? ?? 0,
      unlockedAt: (map['unlockedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      celebrations: List<String>.from(map['celebrations'] as List? ?? []),
      message: map['message'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'achievementId': achievementId,
      'userId': userId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'achievementName': achievementName,
      'description': description,
      'points': points,
      'unlockedAt': Timestamp.fromDate(unlockedAt),
      'celebrations': celebrations,
      'message': message,
    };
  }
}

/// Social statistics
class SocialStats {
  final String userId;
  final int friendCount;
  final int pendingRequests;
  final int groupCount;
  final int activitiesShared;
  final int celebrationsReceived;
  final DateTime lastActivityAt;

  SocialStats({
    required this.userId,
    this.friendCount = 0,
    this.pendingRequests = 0,
    this.groupCount = 0,
    this.activitiesShared = 0,
    this.celebrationsReceived = 0,
    required this.lastActivityAt,
  });

  factory SocialStats.empty(String userId) {
    return SocialStats(
      userId: userId,
      lastActivityAt: DateTime.now(),
    );
  }

  factory SocialStats.fromMap(Map<String, dynamic> map) {
    return SocialStats(
      userId: map['userId'] as String? ?? '',
      friendCount: map['friendCount'] as int? ?? 0,
      pendingRequests: map['pendingRequests'] as int? ?? 0,
      groupCount: map['groupCount'] as int? ?? 0,
      activitiesShared: map['activitiesShared'] as int? ?? 0,
      celebrationsReceived: map['celebrationsReceived'] as int? ?? 0,
      lastActivityAt:
          (map['lastActivityAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'friendCount': friendCount,
      'pendingRequests': pendingRequests,
      'groupCount': groupCount,
      'activitiesShared': activitiesShared,
      'celebrationsReceived': celebrationsReceived,
      'lastActivityAt': Timestamp.fromDate(lastActivityAt),
    };
  }
}
