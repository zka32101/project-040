import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/social_model.dart';

/// Abstract social service interface
abstract class SocialService {
  // Friend Management
  /// Send friend request
  Future<void> sendFriendRequest(String userId, String targetUserId);

  /// Accept friend request
  Future<void> acceptFriendRequest(String userId, String fromUserId);

  /// Reject friend request
  Future<void> rejectFriendRequest(String userId, String fromUserId);

  /// Remove friend
  Future<void> removeFriend(String userId, String friendUserId);

  /// Get user's friends list
  Future<List<Friend>> getFriends(String userId);

  /// Get pending friend requests
  Future<List<Friend>> getPendingRequests(String userId);

  /// Get friend details
  Future<Friend?> getFriendDetails(String userId, String friendId);

  /// Check if users are friends
  Future<bool> areFriends(String userId, String friendUserId);

  // Activity Feed
  /// Post activity
  Future<void> postActivity(Activity activity);

  /// Get friend activity feed
  Future<List<Activity>> getActivityFeed(String userId, {int limit = 50});

  /// Get user's own activities
  Future<List<Activity>> getUserActivities(String userId, {int limit = 30});

  /// Delete activity
  Future<void> deleteActivity(String activityId);

  // Study Groups
  /// Create study group
  Future<String> createStudyGroup(StudyGroup group);

  /// Get study group details
  Future<StudyGroup?> getStudyGroup(String groupId);

  /// Get user's groups
  Future<List<StudyGroup>> getUserGroups(String userId);

  /// Join study group
  Future<void> joinStudyGroup(String userId, String groupId);

  /// Leave study group
  Future<void> leaveStudyGroup(String userId, String groupId);

  /// Get group members
  Future<List<GroupMember>> getGroupMembers(String groupId);

  /// Update group settings
  Future<void> updateGroupSettings(
    String groupId,
    String name, {
    String? description,
    int? maxMembers,
    PrivacyLevel? privacy,
  });

  /// Delete study group
  Future<void> deleteStudyGroup(String groupId, String userId);

  // Shared Achievements
  /// Share achievement
  Future<void> shareAchievement(SharedAchievement achievement);

  /// Celebrate achievement
  Future<void> celebrateAchievement(
    String achievementId,
    String userId,
  );

  /// Get celebration activity
  Future<List<SharedAchievement>> getCelebrationFeed({int limit = 30});

  // Social Statistics
  /// Get social statistics
  Future<SocialStats> getSocialStats(String userId);

  /// Update social statistics
  Future<void> updateSocialStats(String userId, SocialStats stats);
}

/// Firebase implementation of social service
class FirebaseSocialService implements SocialService {
  final FirebaseFirestore _firestore;

  FirebaseSocialService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> sendFriendRequest(String userId, String targetUserId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('friendRequests')
          .doc(targetUserId)
          .set({
            'status': FriendshipStatus.pending.index,
            'sentAt': FieldValue.serverTimestamp(),
          });

      // Also add to target user's incoming requests
      await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('incomingRequests')
          .doc(userId)
          .set({
            'status': FriendshipStatus.pending.index,
            'sentAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error sending friend request: $e');
    }
  }

  @override
  Future<void> acceptFriendRequest(String userId, String fromUserId) async {
    try {
      // Add to friends lists
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(fromUserId)
          .set({
            'status': FriendshipStatus.accepted.index,
            'acceptedAt': FieldValue.serverTimestamp(),
          });

      await _firestore
          .collection('users')
          .doc(fromUserId)
          .collection('friends')
          .doc(userId)
          .set({
            'status': FriendshipStatus.accepted.index,
            'acceptedAt': FieldValue.serverTimestamp(),
          });

      // Remove from requests
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('incomingRequests')
          .doc(fromUserId)
          .delete();

      await _firestore
          .collection('users')
          .doc(fromUserId)
          .collection('friendRequests')
          .doc(userId)
          .delete();
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
    }
  }

  @override
  Future<void> rejectFriendRequest(String userId, String fromUserId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('incomingRequests')
          .doc(fromUserId)
          .delete();

      await _firestore
          .collection('users')
          .doc(fromUserId)
          .collection('friendRequests')
          .doc(userId)
          .delete();
    } catch (e) {
      debugPrint('Error rejecting friend request: $e');
    }
  }

  @override
  Future<void> removeFriend(String userId, String friendUserId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendUserId)
          .delete();

      await _firestore
          .collection('users')
          .doc(friendUserId)
          .collection('friends')
          .doc(userId)
          .delete();
    } catch (e) {
      debugPrint('Error removing friend: $e');
    }
  }

  @override
  Future<List<Friend>> getFriends(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .get();

      return snapshot.docs
          .map((doc) => Friend.fromMap({
                ...doc.data(),
                'userId': doc.id,
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting friends: $e');
      return [];
    }
  }

  @override
  Future<List<Friend>> getPendingRequests(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('incomingRequests')
          .get();

      return snapshot.docs
          .map((doc) => Friend.fromMap({
                ...doc.data(),
                'userId': doc.id,
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting pending requests: $e');
      return [];
    }
  }

  @override
  Future<Friend?> getFriendDetails(String userId, String friendId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .get();

      if (!doc.exists) return null;

      return Friend.fromMap({
        ...doc.data() as Map<String, dynamic>,
        'userId': friendId,
      });
    } catch (e) {
      debugPrint('Error getting friend details: $e');
      return null;
    }
  }

  @override
  Future<bool> areFriends(String userId, String friendUserId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendUserId)
          .get();

      return doc.exists;
    } catch (e) {
      debugPrint('Error checking friend status: $e');
      return false;
    }
  }

  @override
  Future<void> postActivity(Activity activity) async {
    try {
      await _firestore
          .collection('users')
          .doc(activity.userId)
          .collection('activities')
          .add(activity.toMap());

      // Also post to activity feed
      await _firestore.collection('activityFeed').add(activity.toMap());
    } catch (e) {
      debugPrint('Error posting activity: $e');
    }
  }

  @override
  Future<List<Activity>> getActivityFeed(String userId, {int limit = 50}) async {
    try {
      // Get friends' activities
      final friends = await getFriends(userId);
      final friendIds = friends.map((f) => f.userId).toList();

      if (friendIds.isEmpty) return [];

      final snapshot = await _firestore
          .collection('activityFeed')
          .where('userId', whereIn: friendIds)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Activity.fromMap({...doc.data()}))
          .toList();
    } catch (e) {
      debugPrint('Error getting activity feed: $e');
      return [];
    }
  }

  @override
  Future<List<Activity>> getUserActivities(String userId,
      {int limit = 30}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('activities')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Activity.fromMap({...doc.data()}))
          .toList();
    } catch (e) {
      debugPrint('Error getting user activities: $e');
      return [];
    }
  }

  @override
  Future<void> deleteActivity(String activityId) async {
    try {
      await _firestore.collection('activityFeed').doc(activityId).delete();
    } catch (e) {
      debugPrint('Error deleting activity: $e');
    }
  }

  @override
  Future<String> createStudyGroup(StudyGroup group) async {
    try {
      final doc = await _firestore.collection('studyGroups').add(group.toMap());
      return doc.id;
    } catch (e) {
      debugPrint('Error creating study group: $e');
      return '';
    }
  }

  @override
  Future<StudyGroup?> getStudyGroup(String groupId) async {
    try {
      final doc = await _firestore.collection('studyGroups').doc(groupId).get();

      if (!doc.exists) return null;

      return StudyGroup.fromMap({
        ...doc.data() as Map<String, dynamic>,
        'groupId': groupId,
      });
    } catch (e) {
      debugPrint('Error getting study group: $e');
      return null;
    }
  }

  @override
  Future<List<StudyGroup>> getUserGroups(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('studyGroups')
          .where('memberIds', arrayContains: userId)
          .get();

      return snapshot.docs
          .map((doc) => StudyGroup.fromMap({
                ...doc.data(),
                'groupId': doc.id,
              }))
          .toList();
    } catch (e) {
      debugPrint('Error getting user groups: $e');
      return [];
    }
  }

  @override
  Future<void> joinStudyGroup(String userId, String groupId) async {
    try {
      await _firestore.collection('studyGroups').doc(groupId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      debugPrint('Error joining study group: $e');
    }
  }

  @override
  Future<void> leaveStudyGroup(String userId, String groupId) async {
    try {
      await _firestore.collection('studyGroups').doc(groupId).update({
        'memberIds': FieldValue.arrayRemove([userId]),
        'moderatorIds': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      debugPrint('Error leaving study group: $e');
    }
  }

  @override
  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    try {
      final snapshot = await _firestore
          .collection('studyGroups')
          .doc(groupId)
          .collection('members')
          .get();

      return snapshot.docs
          .map((doc) => GroupMember.fromMap({...doc.data()}))
          .toList();
    } catch (e) {
      debugPrint('Error getting group members: $e');
      return [];
    }
  }

  @override
  Future<void> updateGroupSettings(
    String groupId,
    String name, {
    String? description,
    int? maxMembers,
    PrivacyLevel? privacy,
  }) async {
    try {
      final updates = <String, dynamic>{
        'name': name,
        if (description != null) 'description': description,
        if (maxMembers != null) 'maxMembers': maxMembers,
        if (privacy != null) 'privacy': privacy.index,
      };

      await _firestore.collection('studyGroups').doc(groupId).update(updates);
    } catch (e) {
      debugPrint('Error updating group settings: $e');
    }
  }

  @override
  Future<void> deleteStudyGroup(String groupId, String userId) async {
    try {
      // Verify ownership
      final group = await getStudyGroup(groupId);
      if (group?.ownerId != userId) return;

      await _firestore.collection('studyGroups').doc(groupId).delete();
    } catch (e) {
      debugPrint('Error deleting study group: $e');
    }
  }

  @override
  Future<void> shareAchievement(SharedAchievement achievement) async {
    try {
      await _firestore
          .collection('sharedAchievements')
          .add(achievement.toMap());
    } catch (e) {
      debugPrint('Error sharing achievement: $e');
    }
  }

  @override
  Future<void> celebrateAchievement(
    String achievementId,
    String userId,
  ) async {
    try {
      await _firestore
          .collection('sharedAchievements')
          .doc(achievementId)
          .update({
            'celebrations': FieldValue.arrayUnion([userId]),
          });
    } catch (e) {
      debugPrint('Error celebrating achievement: $e');
    }
  }

  @override
  Future<List<SharedAchievement>> getCelebrationFeed({int limit = 30}) async {
    try {
      final snapshot = await _firestore
          .collection('sharedAchievements')
          .orderBy('unlockedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => SharedAchievement.fromMap({...doc.data()}))
          .toList();
    } catch (e) {
      debugPrint('Error getting celebration feed: $e');
      return [];
    }
  }

  @override
  Future<SocialStats> getSocialStats(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('social')
          .doc('stats')
          .get();

      if (!doc.exists) {
        return SocialStats.empty(userId);
      }

      return SocialStats.fromMap({
        ...doc.data() as Map<String, dynamic>,
        'userId': userId,
      });
    } catch (e) {
      debugPrint('Error getting social stats: $e');
      return SocialStats.empty(userId);
    }
  }

  @override
  Future<void> updateSocialStats(String userId, SocialStats stats) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('social')
          .doc('stats')
          .set(stats.toMap());
    } catch (e) {
      debugPrint('Error updating social stats: $e');
    }
  }
}

/// Stub implementation for testing
class StubSocialService implements SocialService {
  final Map<String, List<Friend>> _friends = {};
  final Map<String, List<Friend>> _pendingRequests = {};
  final Map<String, List<Activity>> _activities = {};
  final Map<String, StudyGroup> _groups = {};
  final Map<String, List<SharedAchievement>> _achievements = {};
  final Map<String, SocialStats> _stats = {};

  StubSocialService({
    Map<String, List<Friend>>? friends,
    Map<String, List<Activity>>? activities,
    Map<String, StudyGroup>? groups,
  }) {
    if (friends != null) _friends.addAll(friends);
    if (activities != null) _activities.addAll(activities);
    if (groups != null) _groups.addAll(groups);
  }

  @override
  Future<void> sendFriendRequest(String userId, String targetUserId) async {
    _pendingRequests.putIfAbsent(userId, () => []);
  }

  @override
  Future<void> acceptFriendRequest(String userId, String fromUserId) async {
    _friends.putIfAbsent(userId, () => []);
    _friends.putIfAbsent(fromUserId, () => []);
  }

  @override
  Future<void> rejectFriendRequest(String userId, String fromUserId) async {
    _pendingRequests[userId]?.removeWhere((f) => f.userId == fromUserId);
  }

  @override
  Future<void> removeFriend(String userId, String friendUserId) async {
    _friends[userId]?.removeWhere((f) => f.userId == friendUserId);
    _friends[friendUserId]?.removeWhere((f) => f.userId == userId);
  }

  @override
  Future<List<Friend>> getFriends(String userId) async {
    return _friends[userId] ?? [];
  }

  @override
  Future<List<Friend>> getPendingRequests(String userId) async {
    return _pendingRequests[userId] ?? [];
  }

  @override
  Future<Friend?> getFriendDetails(String userId, String friendId) async {
    return _friends[userId]
        ?.firstWhere((f) => f.userId == friendId, orElse: () => Friend.empty());
  }

  @override
  Future<bool> areFriends(String userId, String friendUserId) async {
    return _friends[userId]?.any((f) => f.userId == friendUserId) ?? false;
  }

  @override
  Future<void> postActivity(Activity activity) async {
    _activities.putIfAbsent(activity.userId, () => []);
    _activities[activity.userId]!.add(activity);
  }

  @override
  Future<List<Activity>> getActivityFeed(String userId, {int limit = 50}) async {
    return _activities[userId]?.take(limit).toList() ?? [];
  }

  @override
  Future<List<Activity>> getUserActivities(String userId,
      {int limit = 30}) async {
    return _activities[userId]?.take(limit).toList() ?? [];
  }

  @override
  Future<void> deleteActivity(String activityId) async {}

  @override
  Future<String> createStudyGroup(StudyGroup group) async {
    _groups[group.groupId] = group;
    return group.groupId;
  }

  @override
  Future<StudyGroup?> getStudyGroup(String groupId) async {
    return _groups[groupId];
  }

  @override
  Future<List<StudyGroup>> getUserGroups(String userId) async {
    return _groups.values
        .where((g) => g.memberIds.contains(userId))
        .toList();
  }

  @override
  Future<void> joinStudyGroup(String userId, String groupId) async {
    final group = _groups[groupId];
    if (group != null && !group.memberIds.contains(userId)) {
      _groups[groupId] = group.copyWith(
        memberIds: [...group.memberIds, userId],
      );
    }
  }

  @override
  Future<void> leaveStudyGroup(String userId, String groupId) async {
    final group = _groups[groupId];
    if (group != null) {
      final newMembers = group.memberIds
          .where((id) => id != userId)
          .toList();
      _groups[groupId] = group.copyWith(memberIds: newMembers);
    }
  }

  @override
  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    return [];
  }

  @override
  Future<void> updateGroupSettings(
    String groupId,
    String name, {
    String? description,
    int? maxMembers,
    PrivacyLevel? privacy,
  }) async {
    final group = _groups[groupId];
    if (group != null) {
      _groups[groupId] = group.copyWith(
        name: name,
        description: description,
        maxMembers: maxMembers,
        privacy: privacy,
      );
    }
  }

  @override
  Future<void> deleteStudyGroup(String groupId, String userId) async {
    _groups.remove(groupId);
  }

  @override
  Future<void> shareAchievement(SharedAchievement achievement) async {
    _achievements.putIfAbsent(achievement.userId, () => []);
    _achievements[achievement.userId]!.add(achievement);
  }

  @override
  Future<void> celebrateAchievement(
    String achievementId,
    String userId,
  ) async {}

  @override
  Future<List<SharedAchievement>> getCelebrationFeed({int limit = 30}) async {
    final all = _achievements.values.expand((list) => list).toList();
    return all.take(limit).toList();
  }

  @override
  Future<SocialStats> getSocialStats(String userId) async {
    return _stats[userId] ?? SocialStats.empty(userId);
  }

  @override
  Future<void> updateSocialStats(String userId, SocialStats stats) async {
    _stats[userId] = stats;
  }
}
