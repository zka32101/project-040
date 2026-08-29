import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community_model.dart';

/// Abstract interface for community service
abstract class CommunityService {
  // Channel operations
  Future<String> createChannel({
    required String name,
    required String ownerId,
    String? description,
    required ChannelType type,
    String? bannerUrl,
    String? iconUrl,
    String? category,
    List<String> tags,
  });

  Future<CommunityChannel?> getChannel(String channelId);

  Future<List<CommunityChannel>> getChannelsByCategory(
    String category, {
    int limit = 50,
  });

  Future<List<CommunityChannel>> searchChannels(
    String query, {
    int limit = 50,
  });

  Future<List<CommunityChannel>> getPublicChannels({int limit = 50});

  Future<void> updateChannel(String channelId, CommunityChannel channel);

  Future<void> archiveChannel(String channelId);

  // Member operations
  Future<String> addMemberToChannel({
    required String channelId,
    required String userId,
    MemberRole role = MemberRole.member,
  });

  Future<ChannelMember?> getChannelMember(String channelId, String userId);

  Future<List<ChannelMember>> getChannelMembers(
    String channelId, {
    int limit = 50,
  });

  Future<List<ChannelMember>> getChannelModerators(String channelId);

  Future<void> updateMemberRole({
    required String channelId,
    required String userId,
    required MemberRole newRole,
  });

  Future<void> removeMemberFromChannel(String channelId, String userId);

  Future<void> muteChannelMember({
    required String channelId,
    required String userId,
  });

  Future<void> unmuteChannelMember({
    required String channelId,
    required String userId,
  });

  Future<void> banChannelMember({
    required String channelId,
    required String userId,
    String? reason,
  });

  Future<void> unbanChannelMember(String channelId, String userId);

  // Post operations
  Future<String> createPost({
    required String channelId,
    required String authorId,
    String? authorName,
    required String content,
    String? mediaUrl,
    List<String> tags,
  });

  Future<ChannelPost?> getPost(String postId);

  Future<List<ChannelPost>> getChannelPosts(
    String channelId, {
    PostStatus? statusFilter,
    int limit = 50,
  });

  Future<List<ChannelPost>> getPinnedPosts(String channelId);

  Future<void> updatePost({
    required String postId,
    required String content,
  });

  Future<void> publishPost(String postId);

  Future<void> deletePost(String postId);

  Future<void> pinPost({
    required String postId,
    required int position,
  });

  Future<void> unpinPost(String postId);

  Future<void> incrementPostViews(String postId);

  // Post interaction operations
  Future<void> likePost(String postId, String userId);

  Future<void> unlikePost(String postId, String userId);

  // Reply operations
  Future<String> createReply({
    required String postId,
    required String channelId,
    required String authorId,
    String? authorName,
    required String content,
    String? mediaUrl,
  });

  Future<PostReply?> getReply(String replyId);

  Future<List<PostReply>> getPostReplies(
    String postId, {
    int limit = 50,
  });

  Future<void> updateReply({
    required String replyId,
    required String content,
  });

  Future<void> deleteReply(String replyId);

  Future<void> likeReply(String replyId, String userId);

  Future<void> unlikeReply(String replyId, String userId);

  // Moderation operations
  Future<String> createModerationRecord({
    required String channelId,
    required String targetUserId,
    required String actionBy,
    required ModerationAction action,
    String? reason,
    DateTime? expiresAt,
  });

  Future<ModerationRecord?> getModerationRecord(String recordId);

  Future<List<ModerationRecord>> getChannelModerationRecords(
    String channelId, {
    int limit = 50,
  });

  Future<List<ModerationRecord>> getUserModerationRecords(
    String userId, {
    int limit = 50,
  });

  Future<void> closeModerationRecord(String recordId);

  // Statistics operations
  Future<void> updateChannelStats(String channelId);

  Future<ChannelStats?> getChannelStats(String channelId);

  Future<int> getTotalChannelsCount();

  Future<int> getChannelMembersCount(String channelId);

  Future<int> getChannelPostsCount(String channelId);

  // Search operations
  Future<List<ChannelPost>> searchPosts({
    required String channelId,
    required String query,
    int limit = 50,
  });

  Future<List<PostReply>> searchReplies({
    required String query,
    int limit = 50,
  });

  // Mention operations (Phase 11 Step 2)
  Future<List<Mention>> extractMentions(
    String content, {
    required String channelId,
  });

  Future<String> createMention({
    required String mentionedUserId,
    required String mentionedUsername,
    required String channelId,
    required String authorId,
    String? authorName,
    String? postId,
    String? replyId,
    String? notificationId,
  });

  Future<List<Mention>> getPostMentions(String postId);

  Future<List<Mention>> getReplyMentions(String replyId);

  Future<List<Mention>> getUserMentions(
    String userId, {
    int limit = 50,
  });

  Future<List<Mention>> getChannelMentions(
    String channelId, {
    int limit = 50,
  });

  Future<int> getMentionCount(String userId);

  Future<bool> validateMention(
    String username, {
    required String channelId,
  });

  Future<List<ChannelMember>> getMentionableCommunityUsers(
    String channelId,
  );

  // Notification operations (Phase 11 Step 2)
  Future<List<UserNotification>> getUserNotifications(
    String userId, {
    bool unreadOnly = false,
    int limit = 50,
    int offset = 0,
  });

  Future<UserNotification?> getNotification(String notificationId);

  Future<String> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String description,
    required String relatedId,
    required String relatedType,
    String? channelId,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  });

  Future<void> markNotificationAsRead(String notificationId);

  Future<void> markAllNotificationsAsRead(String userId);

  Future<void> markPostNotificationsAsRead({
    required String userId,
    required String postId,
  });

  Future<void> deleteNotification(String notificationId);

  Future<void> deleteUserNotifications(String userId);

  Future<void> archiveOldNotifications({
    int olderThanDays = 30,
  });

  Future<void> clearReadNotifications(String userId);

  Future<Map<String, int>> getNotificationSummary(String userId);

  Future<int> getUnreadCount(String userId);

  // Notification preference operations (Phase 11 Step 2)
  Future<NotificationPreferences?> getUserNotificationPreferences(
    String userId,
  );

  Future<void> updateNotificationPreferences(
    String userId,
    NotificationPreferences preferences,
  );

  Future<List<String>> getUsersWithNotificationsEnabled(String channelId);

  Future<void> muteUserNotifications(
    String userId, {
    required Duration duration,
  });

  Future<void> unmuteUserNotifications(String userId);

  // Reaction operations (Phase 11 Step 3)
  Future<String> addPostReaction({
    required String postId,
    required String userId,
    required String emoji,
    ReactionType reactionType = ReactionType.emoji,
  });

  Future<String> addReplyReaction({
    required String replyId,
    required String postId,
    required String userId,
    required String emoji,
    ReactionType reactionType = ReactionType.emoji,
  });

  Future<void> removePostReaction(
    String postId,
    String userId,
    String emoji,
  );

  Future<void> removeReplyReaction(
    String replyId,
    String userId,
    String emoji,
  );

  Future<List<PostReaction>> getPostReactions(String postId);

  Future<List<ReplyReaction>> getReplyReactions(String replyId);

  Future<List<String>> getReactionUsers(
    String postId,
    String emoji,
  );

  Future<int> getReactionCount(String postId);

  Future<PostReaction?> getUserPostReaction(
    String postId,
    String userId,
    String emoji,
  );

  Future<ReplyReaction?> getUserReplyReaction(
    String replyId,
    String userId,
    String emoji,
  );

  // Report operations (Phase 11 Step 3)
  Future<String> reportPost({
    required String postId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
    String? attachmentUrl,
  });

  Future<String> reportReply({
    required String replyId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
    String? attachmentUrl,
  });

  Future<String> reportUser({
    required String reportedUserId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
  });

  Future<ContentReport?> getReport(String reportId);

  Future<List<ContentReport>> getChannelReports(
    String channelId, {
    ReportStatus? statusFilter,
    int limit = 50,
  });

  Future<List<ContentReport>> getUserReports(
    String reportedUserId, {
    int limit = 50,
  });

  Future<List<ContentReport>> getReportedContentReports(
    String contentId, {
    int limit = 50,
  });

  Future<void> actionReport({
    required String reportId,
    required ReportAction action,
    required String moderatorId,
    String? reason,
    String? actionDetails,
  });

  Future<void> dismissReport({
    required String reportId,
    required String moderatorId,
    String? reason,
  });

  Future<Map<String, int>> getReportStats(String channelId);

  // Trending operations (Phase 11 Step 3)
  Future<List<ChannelPost>> getTrendingPosts(
    String channelId, {
    String timeRange = 'day', // 'day', 'week', 'month'
    int limit = 20,
  });

  Future<List<ChannelPost>> getGlobalTrendingPosts({
    String timeRange = 'week',
    int limit = 50,
  });

  Future<List<ChannelPost>> getTrendingByCategory(
    String category, {
    String timeRange = 'week',
    int limit = 20,
  });

  Future<List<String>> getTrendingTags(
    String channelId, {
    int limit = 10,
  });

  Future<double> calculateTrendingScore(String postId);

  Future<PostEngagementAnalytics?> getPostEngagementAnalytics(
    String postId,
  );

  Future<void> updateEngagementAnalytics(String postId);

  // Phase 11 Step 4: Channel Access Control & Invitations

  // Invitation Management
  Future<String> createInvitation({
    required String channelId,
    required String invitedUserId,
    required String invitedByUserId,
    required String inviterName,
    String role = 'member',
    String? message,
  });

  Future<List<String>> inviteMultipleUsers({
    required String channelId,
    required List<String> invitedUserIds,
    required String invitedByUserId,
    required String inviterName,
    String role = 'member',
  });

  Future<ChannelInvitation?> getInvitation(String invitationId);

  Future<List<ChannelInvitation>> getUserInvitations(
    String userId, {
    bool includeExpired = false,
    int limit = 20,
  });

  Future<List<ChannelInvitation>> getChannelInvitations(
    String channelId, {
    String? status,
    int limit = 20,
  });

  Future<void> acceptInvitation(String invitationId, String userId);

  Future<void> declineInvitation(String invitationId, String userId);

  Future<void> cancelInvitation(String invitationId, String cancelledByUserId);

  // Access Request Management
  Future<String> createAccessRequest({
    required String channelId,
    required String requestedByUserId,
    required String requesterName,
    String? reason,
  });

  Future<AccessRequest?> getAccessRequest(String requestId);

  Future<List<AccessRequest>> getChannelAccessRequests(
    String channelId, {
    String? status,
    int limit = 20,
  });

  Future<List<AccessRequest>> getUserAccessRequests(
    String userId, {
    String? status,
    int limit = 10,
  });

  Future<void> approveAccessRequest(
    String requestId,
    String approvedByUserId, {
    String role = 'member',
  });

  Future<void> rejectAccessRequest(
    String requestId,
    String rejectedByUserId, {
    String? reason,
  });

  Future<void> cancelAccessRequest(String requestId, String cancelledByUserId);

  // Member Management
  Future<List<ChannelMember>> getChannelMembers(
    String channelId, {
    String? role,
    int limit = 50,
  });

  Future<ChannelMember?> getChannelMember(String channelId, String userId);

  Future<void> updateMemberRole(
    String channelId,
    String userId,
    String newRole,
    String updatedByUserId,
  );

  Future<void> removeMember(
    String channelId,
    String userId,
    String removedByUserId,
  );

  Future<void> leaveChannel(String channelId, String userId);

  Future<bool> isChannelMember(String channelId, String userId);

  Future<String?> getUserRoleInChannel(String channelId, String userId);

  Future<List<CommunityChannel>> getUserChannels(
    String userId, {
    String? role,
    int limit = 50,
  });

  // Permission Management
  Future<bool> canUserInvite(String channelId, String userId);

  Future<bool> canUserModerate(String channelId, String userId);

  Future<bool> canUserRemoveMembers(String channelId, String userId);

  Future<bool> hasPermission(
    String channelId,
    String userId,
    String permission,
  );

  // Access History
  Future<List<AccessHistoryEntry>> getChannelAccessHistory(
    String channelId, {
    String? actionType,
    int limit = 50,
  });

  Future<List<AccessHistoryEntry>> getUserAccessHistory(
    String userId, {
    int limit = 30,
  });

  Future<AccessHistoryEntry?> getAccessHistoryEntry(String historyId);

  // Phase 11 Step 5: Advanced Search & Content Discovery

  // Search Posts and Replies
  Future<List<SearchResult>> searchPosts(
    String query, {
    String? channelId,
    String? authorId,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    String sortBy = 'relevance',
    int limit = 20,
  });

  Future<List<SearchResult>> searchPostsByDateRange({
    required String query,
    required DateTime fromDate,
    required DateTime toDate,
    int limit = 20,
  });

  Future<List<SearchResult>> searchPostsByTags({
    required List<String> tags,
    int limit = 20,
  });

  Future<SearchResult?> getSearchResult(String resultId);

  // Search Channels
  Future<List<CommunityChannel>> searchChannels(
    String query, {
    String? category,
    String sortBy = 'relevance',
    int limit = 20,
  });

  Future<List<CommunityChannel>> getPopularChannels({int limit = 10});

  Future<List<CommunityChannel>> getTrendingChannels({int limit = 10});

  // Search Users
  Future<List<Map<String, dynamic>>> searchUsers(
    String query, {
    int limit = 20,
  });

  Future<Map<String, dynamic>?> searchUserByUsername(String username);

  // Search Suggestions
  Future<List<SearchSuggestion>> getSearchSuggestions(
    String partialQuery, {
    String category = 'all',
    int limit = 10,
  });

  // Search History
  Future<void> recordSearch({
    required String userId,
    required String query,
    required int resultCount,
    Map<String, dynamic>? filters,
  });

  Future<List<SearchQuery>> getUserSearchHistory(
    String userId, {
    int limit = 20,
  });

  Future<List<SearchQuery>> getTrendingSearches({
    String timeRange = 'week',
    int limit = 10,
  });

  Future<void> clearSearchHistory(String userId);

  // Saved Searches
  Future<String> saveSearch({
    required String userId,
    required String query,
    required String name,
    String? description,
    Map<String, dynamic>? filters,
  });

  Future<SavedSearch?> getSavedSearch(String savedSearchId);

  Future<List<SavedSearch>> getSavedSearches(String userId);

  Future<void> updateSavedSearch(String savedSearchId, {
    String? name,
    String? description,
  });

  Future<void> deleteSavedSearch(String savedSearchId);

  Future<void> useSavedSearch(String savedSearchId);

  // Search Analytics
  Future<List<SearchQuery>> getSearchAnalytics({
    String? query,
    String timeRange = 'week',
    int limit = 20,
  });

  Future<Map<String, dynamic>> getSearchStats();

  // Report Appeals
  Future<String> createReportAppeal({
    required String reportId,
    required String userId,
    String? userName,
    required String reason,
    String? attachmentUrl,
  });

  Future<ReportAppeal?> getReportAppeal(String appealId);

  Future<List<ReportAppeal>> getReportAppeals({
    required String reportId,
    String? status,
    int limit = 20,
  });

  Future<List<ReportAppeal>> getUserAppeals({
    required String userId,
    String status = 'all',
    int limit = 20,
  });

  Future<void> respondToAppeal({
    required String appealId,
    required String respondedByUserId,
    required String decision,
    String? reasoning,
    String? newAction,
  });

  // Moderation Dashboard
  Future<ModerationSummary?> getModerationSummary({
    String timeRange = 'day',
  });

  Future<ModerationSummary?> getModerationAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<ModeratorStats?> getModeratorStats({
    required String userId,
    String timeRange = 'month',
  });

  Future<List<ModeratorStats>> getTeamModerationStats({
    String timeRange = 'month',
    int limit = 50,
  });

  Future<Map<String, dynamic>> compareModerators({
    required List<String> moderatorIds,
    required String metric,
  });

  // Action History & Audit Trail
  Future<List<ModerationActionRecord>> getModerationActionHistory({
    int limit = 100,
    String? actionType,
  });

  Future<List<ModerationActionRecord>> getModeratorActionHistory({
    required String userId,
    int limit = 50,
  });

  Future<List<ModerationActionRecord>> getUserModerationHistory({
    required String userId,
    int limit = 50,
  });

  Future<ModerationActionRecord?> getModerationAction(String actionId);

  // Escalation Management
  Future<void> escalateReport({
    required String reportId,
    required String escalatedByUserId,
    required String reason,
    required String escalateTo,
  });

  Future<List<Escalation>> getEscalations({
    String status = 'pending',
    int limit = 50,
  });

  Future<void> processEscalation({
    required String escalationId,
    required String processedByUserId,
    required String decision,
    String? notes,
  });

  // User Reputation & Gamification
  Future<String> addReputationEvent({
    required String userId,
    required String eventType,
    required int points,
    required String reason,
    String? relatedContentId,
    Map<String, dynamic>? metadata,
  });

  Future<UserReputation?> getUserReputation(String userId);

  Future<List<ReputationEvent>> getReputationEvents({
    required String userId,
    int limit = 50,
  });

  Future<Map<String, dynamic>> getUserStatistics(String userId);

  Future<int> getTotalReputation(String userId);

  // Badges
  Future<String> createBadgeDefinition({
    required String name,
    required String description,
    required String category,
    required String rarity,
    required int pointsValue,
    required String iconUrl,
    Map<String, dynamic>? requirements,
  });

  Future<BadgeDefinition?> getBadgeDefinition(String badgeId);

  Future<List<BadgeDefinition>> getBadgeDefinitions({
    String? category,
    int limit = 50,
  });

  Future<List<UserBadge>> getUserBadges(String userId);

  Future<void> awardBadge({
    required String userId,
    required String badgeId,
    String? awardedBy,
    String? reason,
  });

  Future<Map<String, dynamic>> getBadgeProgress({
    required String userId,
    required String badgeId,
  });

  // Leaderboards
  Future<List<Map<String, dynamic>>> getTopContributors({
    int limit = 100,
    String timeRange = 'all',
  });

  Future<List<Map<String, dynamic>>> getLeaderboard({
    required String metric,
    int limit = 50,
    String timeRange = 'month',
  });

  Future<Map<String, dynamic>?> getUserRank({
    required String userId,
    required String metric,
  });

  Future<List<Map<String, dynamic>>> getNearbyRanks({
    required String userId,
    required String metric,
    int range = 5,
  });

  // Levels & Progression
  Future<Map<String, dynamic>> getUserLevel(String userId);

  Future<void> checkAndProcessLevelUp(String userId);

  Future<List<Map<String, dynamic>>> getLevelDefinitions();

  // Community Analytics & Insights
  Future<Map<String, dynamic>> getPlatformOverview({
    String timeRange = 'week',
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Map<String, dynamic>> getKeyMetrics({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<Map<String, dynamic>>> getMetricTrends({
    required String metric,
    String timeRange = 'month',
    String granularity = 'daily',
  });

  Future<Map<String, dynamic>> getUserEngagementStats({
    String timeRange = 'week',
  });

  Future<Map<String, dynamic>> getUserRetention({
    required DateTime cohortDate,
  });

  Future<List<Map<String, dynamic>>> getEngagementBySegment({
    required String segment,
    int limit = 50,
  });

  Future<Map<String, dynamic>> getContentAnalytics({
    String timeRange = 'week',
  });

  Future<List<Map<String, dynamic>>> getTrendingContent({
    String timeRange = 'day',
    int limit = 20,
  });

  Future<Map<String, dynamic>> getChannelContentAnalytics({
    required String channelId,
    String timeRange = 'month',
  });

  Future<Map<String, dynamic>> getCommunityHealthScore({
    String timeRange = 'week',
  });

  Future<List<Map<String, dynamic>>> getCommunityHealthTrends({
    String timeRange = 'month',
  });

  Future<Map<String, dynamic>> getChannelHealthMetrics({
    required String channelId,
  });

  Future<Map<String, dynamic>> getUserGrowthMetrics({
    String timeRange = 'month',
  });

  Future<List<Map<String, dynamic>>> getCohortRetention({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Map<String, dynamic>> getUserAcquisitionAnalytics({
    String timeRange = 'month',
  });

  Future<Map<String, dynamic>> getModerationAnalyticsOverview({
    String timeRange = 'week',
  });

  Future<List<Map<String, dynamic>>> getModeratorEffectiveness({
    String timeRange = 'month',
    int limit = 50,
  });

  Future<List<Map<String, dynamic>>> getModerationHotspots({
    String timeRange = 'week',
    int limit = 20,
  });

  Future<Map<String, dynamic>> getRevenueAnalytics({
    String timeRange = 'month',
  });

  Future<Map<String, dynamic>> getSubscriptionAnalytics({
    String timeRange = 'month',
  });

  Future<Map<String, dynamic>> getConversionFunnel({
    String timeRange = 'week',
  });

  Future<Map<String, dynamic>> generateCustomReport({
    required String name,
    required List<String> metrics,
    Map<String, dynamic>? filters,
    String timeRange = 'week',
    String format = 'json',
  });

  Future<List<Map<String, dynamic>>> getSavedReports({
    int limit = 20,
  });

  Future<Map<String, dynamic>> exportAnalyticsData({
    List<String> metrics = const ['all'],
    String timeRange = 'month',
    String format = 'csv',
  });

  // Practice Test & Mock Exam Methods
  Future<String> createQuestion({
    required String questionText,
    required QuestionType questionType,
    required String topic,
    required QuestionDifficulty difficulty,
    List<String> options = const [],
    int? correctAnswerIndex,
    String? correctAnswer,
    String explanation = '',
    List<String> tags = const [],
  });

  Future<Question?> getQuestion(String questionId);

  Future<List<Question>> getQuestions({
    String? topic,
    QuestionDifficulty? difficulty,
    int limit = 50,
  });

  Future<List<Question>> getQuestionsByTopic(String topic);

  Future<List<Question>> getQuestionsByDifficulty(QuestionDifficulty difficulty);

  Future<List<Question>> searchQuestions(String query);

  Future<String> startPracticeTest({
    required String userId,
    required String topic,
    required QuestionDifficulty difficulty,
    int questionCount = 10,
    int timeLimit = 600,
  });

  Future<void> submitAnswer({
    required String testId,
    required String questionId,
    dynamic selectedAnswer,
    int timeTaken = 0,
  });

  Future<Map<String, dynamic>> completePracticeTest(String testId);

  Future<Map<String, dynamic>?> getPracticeTestResults(String testId);

  Future<List<PracticeTest>> getPracticeTestHistory({
    required String userId,
    int limit = 50,
  });

  Future<Map<String, double>> getTopicPerformance(
    String userId,
    String topic,
  );

  Future<String> startMockExam({
    required String userId,
    required ExamType examType,
    bool randomizeQuestions = true,
    bool showTimer = true,
  });

  Future<List<Question>> getMockExamQuestions(String examId);

  Future<Map<String, dynamic>> completeMockExam(String examId);

  Future<Map<String, dynamic>> getTestStatistics({
    required String userId,
    String timeRange = 'month',
  });

  Future<List<Map<String, dynamic>>> getScoreTrends({
    required String userId,
    int limit = 30,
  });

  Future<Map<String, double>> getPerformanceByTopic(String userId);

  Future<Map<String, dynamic>> generateStudyPlan(String userId);

  Future<List<Map<String, dynamic>>> getWeakAreas({
    required String userId,
    double threshold = 70.0,
  });

  Future<List<Map<String, dynamic>>> getTestAchievements(String userId);
}

/// Firebase implementation of community service
class FirebaseCommunityService implements CommunityService {
  final FirebaseFirestore _db;

  FirebaseCommunityService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<String> createChannel({
    required String name,
    required String ownerId,
    String? description,
    required ChannelType type,
    String? bannerUrl,
    String? iconUrl,
    String? category,
    List<String> tags = const [],
  }) async {
    final channelId = _db.collection('communityChannels').doc().id;
    final channel = CommunityChannel(
      channelId: channelId,
      name: name,
      description: description,
      type: type,
      ownerId: ownerId,
      moderatorIds: [],
      memberIds: [ownerId],
      bannerUrl: bannerUrl,
      iconUrl: iconUrl,
      memberCount: 1,
      createdAt: DateTime.now(),
      category: category,
      tags: tags,
    );

    await _db.collection('communityChannels').doc(channelId).set(channel.toMap());

    // Create member record for owner
    await addMemberToChannel(
      channelId: channelId,
      userId: ownerId,
      role: MemberRole.owner,
    );

    // Create stats record
    final statsId = _db.collection('channelStats').doc().id;
    final stats = ChannelStats(
      statsId: statsId,
      channelId: channelId,
      totalMembers: 1,
      updatedAt: DateTime.now(),
    );
    await _db.collection('channelStats').doc(statsId).set(stats.toMap());

    return channelId;
  }

  @override
  Future<CommunityChannel?> getChannel(String channelId) async {
    final doc = await _db.collection('communityChannels').doc(channelId).get();
    if (!doc.exists) return null;
    return CommunityChannel.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<CommunityChannel>> getChannelsByCategory(
    String category, {
    int limit = 50,
  }) async {
    final query = _db
        .collection('communityChannels')
        .where('category', isEqualTo: category)
        .where('isArchived', isEqualTo: false)
        .orderBy('lastActivityAt', descending: true)
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => CommunityChannel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CommunityChannel>> searchChannels(
    String query, {
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('communityChannels')
        .where('isArchived', isEqualTo: false)
        .limit(limit)
        .get();

    final allChannels = snapshot.docs
        .map((doc) => CommunityChannel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    return allChannels
        .where((channel) =>
            channel.name.toLowerCase().contains(query.toLowerCase()) ||
            channel.description?.toLowerCase().contains(query.toLowerCase()) ??
            false)
        .toList();
  }

  @override
  Future<List<CommunityChannel>> getPublicChannels({int limit = 50}) async {
    final query = _db
        .collection('communityChannels')
        .where('type', isEqualTo: ChannelType.public.index)
        .where('isArchived', isEqualTo: false)
        .orderBy('lastActivityAt', descending: true)
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => CommunityChannel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateChannel(String channelId, CommunityChannel channel) async {
    await _db.collection('communityChannels').doc(channelId).set(
          channel.toMap(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> archiveChannel(String channelId) async {
    await _db.collection('communityChannels').doc(channelId).update({
      'isArchived': true,
    });
  }

  @override
  Future<String> addMemberToChannel({
    required String channelId,
    required String userId,
    MemberRole role = MemberRole.member,
  }) async {
    final memberId = _db.collection('channelMembers').doc().id;
    final member = ChannelMember(
      memberId: memberId,
      channelId: channelId,
      userId: userId,
      role: role,
      joinedAt: DateTime.now(),
    );

    await _db.collection('channelMembers').doc(memberId).set(member.toMap());

    // Update channel member list and count
    final channel = await getChannel(channelId);
    if (channel != null) {
      final updatedMembers = [...channel.memberIds];
      if (!updatedMembers.contains(userId)) {
        updatedMembers.add(userId);
      }
      await updateChannel(
        channelId,
        channel.copyWith(
          memberIds: updatedMembers,
          memberCount: updatedMembers.length,
        ),
      );
    }

    return memberId;
  }

  @override
  Future<ChannelMember?> getChannelMember(String channelId, String userId) async {
    final query = _db
        .collection('channelMembers')
        .where('channelId', isEqualTo: channelId)
        .where('userId', isEqualTo: userId);

    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) return null;
    return ChannelMember.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
  }

  @override
  Future<List<ChannelMember>> getChannelMembers(
    String channelId, {
    int limit = 50,
  }) async {
    final query = _db
        .collection('channelMembers')
        .where('channelId', isEqualTo: channelId)
        .where('isBanned', isEqualTo: false)
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ChannelMember.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ChannelMember>> getChannelModerators(String channelId) async {
    final query = _db
        .collection('channelMembers')
        .where('channelId', isEqualTo: channelId)
        .where('role', whereIn: [MemberRole.owner.index, MemberRole.moderator.index]);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ChannelMember.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateMemberRole({
    required String channelId,
    required String userId,
    required MemberRole newRole,
  }) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      await _db.collection('channelMembers').doc(member.memberId).update({
        'role': newRole.index,
      });

      // Update channel moderator list
      final channel = await getChannel(channelId);
      if (channel != null) {
        var updatedModerators = [...channel.moderatorIds];
        if (newRole == MemberRole.moderator &&
            !updatedModerators.contains(userId)) {
          updatedModerators.add(userId);
        } else if (newRole != MemberRole.moderator) {
          updatedModerators.removeWhere((id) => id == userId);
        }
        await updateChannel(
          channelId,
          channel.copyWith(moderatorIds: updatedModerators),
        );
      }
    }
  }

  @override
  Future<void> removeMemberFromChannel(String channelId, String userId) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      await _db.collection('channelMembers').doc(member.memberId).delete();

      // Update channel member list
      final channel = await getChannel(channelId);
      if (channel != null) {
        final updatedMembers =
            channel.memberIds.where((id) => id != userId).toList();
        await updateChannel(
          channelId,
          channel.copyWith(
            memberIds: updatedMembers,
            memberCount: updatedMembers.length,
          ),
        );
      }
    }
  }

  @override
  Future<void> muteChannelMember({
    required String channelId,
    required String userId,
  }) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      await _db.collection('channelMembers').doc(member.memberId).update({
        'isMuted': true,
      });
    }
  }

  @override
  Future<void> unmuteChannelMember({
    required String channelId,
    required String userId,
  }) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      await _db.collection('channelMembers').doc(member.memberId).update({
        'isMuted': false,
      });
    }
  }

  @override
  Future<void> banChannelMember({
    required String channelId,
    required String userId,
    String? reason,
  }) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      await _db.collection('channelMembers').doc(member.memberId).update({
        'isBanned': true,
        'banReason': reason,
      });
    }
  }

  @override
  Future<void> unbanChannelMember(String channelId, String userId) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      await _db.collection('channelMembers').doc(member.memberId).update({
        'isBanned': false,
        'banReason': null,
      });
    }
  }

  @override
  Future<String> createPost({
    required String channelId,
    required String authorId,
    String? authorName,
    required String content,
    String? mediaUrl,
    List<String> tags = const [],
  }) async {
    final postId = _db.collection('channelPosts').doc().id;
    final post = ChannelPost(
      postId: postId,
      channelId: channelId,
      authorId: authorId,
      authorName: authorName,
      content: content,
      status: PostStatus.published,
      createdAt: DateTime.now(),
      mediaUrl: mediaUrl,
      tags: tags,
    );

    await _db.collection('channelPosts').doc(postId).set(post.toMap());

    // Update channel stats
    await updateChannelStats(channelId);

    return postId;
  }

  @override
  Future<ChannelPost?> getPost(String postId) async {
    final doc = await _db.collection('channelPosts').doc(postId).get();
    if (!doc.exists) return null;
    return ChannelPost.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<ChannelPost>> getChannelPosts(
    String channelId, {
    PostStatus? statusFilter,
    int limit = 50,
  }) async {
    Query query = _db
        .collection('channelPosts')
        .where('channelId', isEqualTo: channelId);

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter.index);
    }

    query = query.orderBy('isPinned', descending: true).orderBy('createdAt', descending: true).limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ChannelPost.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ChannelPost>> getPinnedPosts(String channelId) async {
    final query = _db
        .collection('channelPosts')
        .where('channelId', isEqualTo: channelId)
        .where('isPinned', isEqualTo: true)
        .orderBy('pinPosition', descending: true);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ChannelPost.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updatePost({
    required String postId,
    required String content,
  }) async {
    await _db.collection('channelPosts').doc(postId).update({
      'content': content,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> publishPost(String postId) async {
    await _db.collection('channelPosts').doc(postId).update({
      'status': PostStatus.published.index,
    });
  }

  @override
  Future<void> deletePost(String postId) async {
    await _db.collection('channelPosts').doc(postId).update({
      'status': PostStatus.archived.index,
    });
  }

  @override
  Future<void> pinPost({
    required String postId,
    required int position,
  }) async {
    await _db.collection('channelPosts').doc(postId).update({
      'isPinned': true,
      'pinPosition': position,
    });
  }

  @override
  Future<void> unpinPost(String postId) async {
    await _db.collection('channelPosts').doc(postId).update({
      'isPinned': false,
      'pinPosition': null,
    });
  }

  @override
  Future<void> incrementPostViews(String postId) async {
    await _db.collection('channelPosts').doc(postId).update({
      'views': FieldValue.increment(1),
    });
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    await _db.collection('channelPosts').doc(postId).update({
      'likes': FieldValue.increment(1),
      'likedBy': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    await _db.collection('channelPosts').doc(postId).update({
      'likes': FieldValue.increment(-1),
      'likedBy': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<String> createReply({
    required String postId,
    required String channelId,
    required String authorId,
    String? authorName,
    required String content,
    String? mediaUrl,
  }) async {
    final replyId = _db.collection('postReplies').doc().id;
    final reply = PostReply(
      replyId: replyId,
      postId: postId,
      channelId: channelId,
      authorId: authorId,
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
      mediaUrl: mediaUrl,
    );

    await _db.collection('postReplies').doc(replyId).set(reply.toMap());

    // Update post reply count
    await _db.collection('channelPosts').doc(postId).update({
      'replies': FieldValue.increment(1),
    });

    return replyId;
  }

  @override
  Future<PostReply?> getReply(String replyId) async {
    final doc = await _db.collection('postReplies').doc(replyId).get();
    if (!doc.exists) return null;
    return PostReply.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<PostReply>> getPostReplies(
    String postId, {
    int limit = 50,
  }) async {
    final query = _db
        .collection('postReplies')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => PostReply.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateReply({
    required String replyId,
    required String content,
  }) async {
    await _db.collection('postReplies').doc(replyId).update({
      'content': content,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<void> deleteReply(String replyId) async {
    final reply = await getReply(replyId);
    if (reply != null) {
      await _db.collection('postReplies').doc(replyId).delete();

      // Update post reply count
      await _db.collection('channelPosts').doc(reply.postId).update({
        'replies': FieldValue.increment(-1),
      });
    }
  }

  @override
  Future<void> likeReply(String replyId, String userId) async {
    await _db.collection('postReplies').doc(replyId).update({
      'likes': FieldValue.increment(1),
      'likedBy': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> unlikeReply(String replyId, String userId) async {
    await _db.collection('postReplies').doc(replyId).update({
      'likes': FieldValue.increment(-1),
      'likedBy': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<String> createModerationRecord({
    required String channelId,
    required String targetUserId,
    required String actionBy,
    required ModerationAction action,
    String? reason,
    DateTime? expiresAt,
  }) async {
    final recordId = _db.collection('moderationRecords').doc().id;
    final record = ModerationRecord(
      recordId: recordId,
      channelId: channelId,
      targetUserId: targetUserId,
      actionBy: actionBy,
      action: action,
      reason: reason,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
    );

    await _db.collection('moderationRecords').doc(recordId).set(record.toMap());

    return recordId;
  }

  @override
  Future<ModerationRecord?> getModerationRecord(String recordId) async {
    final doc = await _db.collection('moderationRecords').doc(recordId).get();
    if (!doc.exists) return null;
    return ModerationRecord.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<ModerationRecord>> getChannelModerationRecords(
    String channelId, {
    int limit = 50,
  }) async {
    final query = _db
        .collection('moderationRecords')
        .where('channelId', isEqualTo: channelId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ModerationRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ModerationRecord>> getUserModerationRecords(
    String userId, {
    int limit = 50,
  }) async {
    final query = _db
        .collection('moderationRecords')
        .where('targetUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ModerationRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> closeModerationRecord(String recordId) async {
    await _db.collection('moderationRecords').doc(recordId).update({
      'isActive': false,
    });
  }

  @override
  Future<void> updateChannelStats(String channelId) async {
    final postsCount = await getChannelPostsCount(channelId);
    final membersCount = await getChannelMembersCount(channelId);

    final query = _db
        .collection('channelStats')
        .where('channelId', isEqualTo: channelId);
    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      await _db.collection('channelStats').doc(doc.id).update({
        'totalMembers': membersCount,
        'totalPosts': postsCount,
        'updatedAt': Timestamp.now(),
      });
    }
  }

  @override
  Future<ChannelStats?> getChannelStats(String channelId) async {
    final query = _db
        .collection('channelStats')
        .where('channelId', isEqualTo: channelId);

    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) return null;
    return ChannelStats.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
  }

  @override
  Future<int> getTotalChannelsCount() async {
    final query = _db.collection('communityChannels').where('isArchived', isEqualTo: false);
    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<int> getChannelMembersCount(String channelId) async {
    final query = _db
        .collection('channelMembers')
        .where('channelId', isEqualTo: channelId)
        .where('isBanned', isEqualTo: false);

    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<int> getChannelPostsCount(String channelId) async {
    final query = _db
        .collection('channelPosts')
        .where('channelId', isEqualTo: channelId)
        .where('status', isEqualTo: PostStatus.published.index);

    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<List<ChannelPost>> searchPosts({
    required String channelId,
    required String query,
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('channelPosts')
        .where('channelId', isEqualTo: channelId)
        .where('status', isEqualTo: PostStatus.published.index)
        .limit(limit)
        .get();

    final allPosts = snapshot.docs
        .map((doc) => ChannelPost.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    return allPosts
        .where((post) => post.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<PostReply>> searchReplies({
    required String query,
    int limit = 50,
  }) async {
    final snapshot = await _db.collection('postReplies').limit(limit).get();

    final allReplies = snapshot.docs
        .map((doc) => PostReply.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    return allReplies
        .where((reply) => reply.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // ============ MENTION OPERATIONS (Phase 11 Step 2) ============

  @override
  Future<List<Mention>> extractMentions(
    String content, {
    required String channelId,
  }) async {
    final regex = RegExp(r'@(\w+)');
    final matches = regex.allMatches(content);
    final mentions = <Mention>[];
    final seenUsernames = <String>{};

    // Get channel members
    final memberSnapshot = await _db
        .collection('channelMembers')
        .where('channelId', isEqualTo: channelId)
        .get();

    final memberUserIds = memberSnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['userId'] as String)
        .toSet();

    for (final match in matches) {
      final username = match.group(1)!.toLowerCase();
      if (seenUsernames.add(username) && memberUserIds.contains(username)) {
        mentions.add(
          Mention(
            mentionId: 'mention_${DateTime.now().millisecondsSinceEpoch}',
            mentionedUserId: username,
            mentionedUsername: username,
            channelId: channelId,
            authorId: '',
            mentionedAt: DateTime.now(),
          ),
        );
      }
    }
    return mentions;
  }

  @override
  Future<String> createMention({
    required String mentionedUserId,
    required String mentionedUsername,
    required String channelId,
    required String authorId,
    String? authorName,
    String? postId,
    String? replyId,
    String? notificationId,
  }) async {
    final mentionId = 'mention_${DateTime.now().millisecondsSinceEpoch}';
    await _db.collection('mentions').doc(mentionId).set({
      'mentionId': mentionId,
      'mentionedUserId': mentionedUserId,
      'mentionedUsername': mentionedUsername,
      'postId': postId,
      'replyId': replyId,
      'channelId': channelId,
      'authorId': authorId,
      'authorName': authorName,
      'mentionedAt': Timestamp.now(),
      'notificationId': notificationId,
    });
    return mentionId;
  }

  @override
  Future<List<Mention>> getPostMentions(String postId) async {
    final snapshot = await _db
        .collection('mentions')
        .where('postId', isEqualTo: postId)
        .where('replyId', isEqualTo: null)
        .get();

    return snapshot.docs
        .map((doc) => Mention.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<Mention>> getReplyMentions(String replyId) async {
    final snapshot = await _db
        .collection('mentions')
        .where('replyId', isEqualTo: replyId)
        .get();

    return snapshot.docs
        .map((doc) => Mention.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<Mention>> getUserMentions(
    String userId, {
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('mentions')
        .where('mentionedUserId', isEqualTo: userId)
        .orderBy('mentionedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => Mention.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<Mention>> getChannelMentions(
    String channelId, {
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('mentions')
        .where('channelId', isEqualTo: channelId)
        .orderBy('mentionedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => Mention.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<int> getMentionCount(String userId) async {
    final snapshot = await _db
        .collection('mentions')
        .where('mentionedUserId', isEqualTo: userId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  @override
  Future<bool> validateMention(
    String username, {
    required String channelId,
  }) async {
    final snapshot = await _db
        .collection('channelMembers')
        .where('channelId', isEqualTo: channelId)
        .where('userId', isEqualTo: username)
        .where('isBanned', isEqualTo: false)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  @override
  Future<List<ChannelMember>> getMentionableCommunityUsers(
    String channelId,
  ) async {
    final snapshot = await _db
        .collection('channelMembers')
        .where('channelId', isEqualTo: channelId)
        .where('isBanned', isEqualTo: false)
        .get();

    return snapshot.docs
        .map((doc) => ChannelMember.fromMap(doc.data()))
        .toList();
  }

  // ============ NOTIFICATION OPERATIONS (Phase 11 Step 2) ============

  @override
  Future<List<UserNotification>> getUserNotifications(
    String userId, {
    bool unreadOnly = false,
    int limit = 50,
    int offset = 0,
  }) async {
    var query = _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true);

    if (unreadOnly) {
      query = query.where('isRead', isEqualTo: false);
    }

    final snapshot = await query
        .limit(limit + offset)
        .get();

    return snapshot.docs
        .skip(offset)
        .map((doc) => UserNotification.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<UserNotification?> getNotification(String notificationId) async {
    // Search across all users (inefficient but works for now)
    // In production, store notificationId -> userId mapping
    final snapshot = await _db
        .collectionGroup('notifications')
        .where('notificationId', isEqualTo: notificationId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return UserNotification.fromMap(snapshot.docs.first.data());
  }

  @override
  Future<String> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String description,
    required String relatedId,
    required String relatedType,
    String? channelId,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) async {
    // Check preferences
    final prefs = await getUserNotificationPreferences(userId);
    if (prefs?.isCurrentlyMuted ?? false) {
      return '';
    }

    // Check type-specific preferences
    bool shouldCreate = true;
    if (prefs != null) {
      switch (type) {
        case NotificationType.mention:
          shouldCreate = prefs.mentionNotifications;
          break;
        case NotificationType.reply:
          shouldCreate = prefs.replyNotifications;
          break;
        case NotificationType.likePost:
        case NotificationType.likeReply:
          shouldCreate = prefs.likeNotifications;
          break;
        case NotificationType.moderation:
          shouldCreate = prefs.moderationNotifications;
          break;
        case NotificationType.channelEvent:
        case NotificationType.channelAnnounce:
          shouldCreate = prefs.channelAnnouncements;
          break;
      }
    }

    if (!shouldCreate) {
      return '';
    }

    // Check for duplicates
    final dupSnapshot = await _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .where('type', isEqualTo: type.index)
        .where('relatedId', isEqualTo: relatedId)
        .where('isRead', isEqualTo: false)
        .limit(1)
        .get();

    if (dupSnapshot.docs.isNotEmpty) {
      return '';
    }

    final notificationId = 'notif_${DateTime.now().millisecondsSinceEpoch}';
    await _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .set({
      'notificationId': notificationId,
      'userId': userId,
      'type': type.index,
      'title': title,
      'description': description,
      'relatedId': relatedId,
      'relatedType': relatedType,
      'channelId': channelId,
      'isRead': false,
      'createdAt': Timestamp.now(),
      'readAt': null,
      'actionUrl': actionUrl,
      'metadata': metadata,
    });

    return notificationId;
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    // Need to find the notification first (inefficient in production)
    final snapshot = await _db
        .collectionGroup('notifications')
        .where('notificationId', isEqualTo: notificationId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final userId = doc.reference.parent.parent?.id;
      if (userId != null) {
        await doc.reference.update({
          'isRead': true,
          'readAt': Timestamp.now(),
        });
      }
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
    final snapshot = await _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': Timestamp.now(),
      });
    }
    await batch.commit();
  }

  @override
  Future<void> markPostNotificationsAsRead({
    required String userId,
    required String postId,
  }) async {
    final snapshot = await _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .where('relatedId', isEqualTo: postId)
        .get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': Timestamp.now(),
      });
    }
    await batch.commit();
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final snapshot = await _db
        .collectionGroup('notifications')
        .where('notificationId', isEqualTo: notificationId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();
    }
  }

  @override
  Future<void> deleteUserNotifications(String userId) async {
    final snapshot = await _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<void> archiveOldNotifications({
    int olderThanDays = 30,
  }) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));

    // This would need to be done per-user in production
    // For now, this is a placeholder
  }

  @override
  Future<void> clearReadNotifications(String userId) async {
    final snapshot = await _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: true)
        .get();

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<Map<String, int>> getNotificationSummary(String userId) async {
    final snapshot = await _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .get();

    final notifs = snapshot.docs
        .map((doc) => UserNotification.fromMap(doc.data()))
        .toList();

    return {
      'mentions': notifs
          .where((n) => n.type == NotificationType.mention)
          .length,
      'replies': notifs
          .where((n) => n.type == NotificationType.reply)
          .length,
      'likes': notifs
          .where((n) =>
              n.type == NotificationType.likePost ||
              n.type == NotificationType.likeReply)
          .length,
      'moderation': notifs
          .where((n) => n.type == NotificationType.moderation)
          .length,
      'total': notifs.length,
      'unread': notifs.where((n) => n.isUnread).length,
    };
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final snapshot = await _db
        .collection('userNotifications')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  // ============ NOTIFICATION PREFERENCE OPERATIONS (Phase 11 Step 2) ============

  @override
  Future<NotificationPreferences?> getUserNotificationPreferences(
    String userId,
  ) async {
    final doc = await _db
        .collection('notificationPreferences')
        .doc(userId)
        .get();

    if (!doc.exists) return null;
    return NotificationPreferences.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> updateNotificationPreferences(
    String userId,
    NotificationPreferences preferences,
  ) async {
    await _db
        .collection('notificationPreferences')
        .doc(userId)
        .set(preferences.toMap(), SetOptions(merge: true));
  }

  @override
  Future<List<String>> getUsersWithNotificationsEnabled(
    String channelId,
  ) async {
    final memberSnapshot = await _db
        .collection('channelMembers')
        .where('channelId', isEqualTo: channelId)
        .where('isBanned', isEqualTo: false)
        .get();

    final enabledUsers = <String>[];
    for (final memberDoc in memberSnapshot.docs) {
      final userId = (memberDoc.data() as Map<String, dynamic>)['userId'] as String;
      final prefs = await getUserNotificationPreferences(userId);

      if (prefs == null || prefs.hasAnyNotificationsEnabled) {
        enabledUsers.add(userId);
      }
    }

    return enabledUsers;
  }

  @override
  Future<void> muteUserNotifications(
    String userId, {
    required Duration duration,
  }) async {
    final prefs = await getUserNotificationPreferences(userId) ??
        NotificationPreferences.empty(userId);

    final muteUntil = DateTime.now().add(duration);
    await updateNotificationPreferences(
      userId,
      prefs.copyWith(muteUntil: muteUntil),
    );
  }

  @override
  Future<void> unmuteUserNotifications(String userId) async {
    final prefs = await getUserNotificationPreferences(userId);
    if (prefs != null) {
      await updateNotificationPreferences(
        userId,
        prefs.copyWith(muteUntil: null),
      );
    }
  }

  // ============ REACTION OPERATIONS (Phase 11 Step 3) ============

  @override
  Future<String> addPostReaction({
    required String postId,
    required String userId,
    required String emoji,
    ReactionType reactionType = ReactionType.emoji,
  }) async {
    final reactionId = 'reaction_${DateTime.now().millisecondsSinceEpoch}';
    await _db.collection('postReactions').doc(reactionId).set({
      'reactionId': reactionId,
      'postId': postId,
      'userId': userId,
      'emoji': emoji,
      'reactionType': reactionType.index,
      'createdAt': Timestamp.now(),
    });
    return reactionId;
  }

  @override
  Future<String> addReplyReaction({
    required String replyId,
    required String postId,
    required String userId,
    required String emoji,
    ReactionType reactionType = ReactionType.emoji,
  }) async {
    final reactionId = 'reaction_${DateTime.now().millisecondsSinceEpoch}';
    await _db.collection('replyReactions').doc(reactionId).set({
      'reactionId': reactionId,
      'replyId': replyId,
      'postId': postId,
      'userId': userId,
      'emoji': emoji,
      'reactionType': reactionType.index,
      'createdAt': Timestamp.now(),
    });
    return reactionId;
  }

  @override
  Future<void> removePostReaction(String postId, String userId, String emoji) async {
    final snapshot = await _db
        .collection('postReactions')
        .where('postId', isEqualTo: postId)
        .where('userId', isEqualTo: userId)
        .where('emoji', isEqualTo: emoji)
        .limit(1)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<void> removeReplyReaction(String replyId, String userId, String emoji) async {
    final snapshot = await _db
        .collection('replyReactions')
        .where('replyId', isEqualTo: replyId)
        .where('userId', isEqualTo: userId)
        .where('emoji', isEqualTo: emoji)
        .limit(1)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<List<PostReaction>> getPostReactions(String postId) async {
    final snapshot = await _db
        .collection('postReactions')
        .where('postId', isEqualTo: postId)
        .get();

    return snapshot.docs
        .map((doc) => PostReaction.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<ReplyReaction>> getReplyReactions(String replyId) async {
    final snapshot = await _db
        .collection('replyReactions')
        .where('replyId', isEqualTo: replyId)
        .get();

    return snapshot.docs
        .map((doc) => ReplyReaction.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<String>> getReactionUsers(String postId, String emoji) async {
    final snapshot = await _db
        .collection('postReactions')
        .where('postId', isEqualTo: postId)
        .where('emoji', isEqualTo: emoji)
        .get();

    return snapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['userId'] as String)
        .toList();
  }

  @override
  Future<int> getReactionCount(String postId) async {
    final snapshot = await _db
        .collection('postReactions')
        .where('postId', isEqualTo: postId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  @override
  Future<PostReaction?> getUserPostReaction(
    String postId,
    String userId,
    String emoji,
  ) async {
    final snapshot = await _db
        .collection('postReactions')
        .where('postId', isEqualTo: postId)
        .where('userId', isEqualTo: userId)
        .where('emoji', isEqualTo: emoji)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return PostReaction.fromMap(snapshot.docs.first.data());
  }

  @override
  Future<ReplyReaction?> getUserReplyReaction(
    String replyId,
    String userId,
    String emoji,
  ) async {
    final snapshot = await _db
        .collection('replyReactions')
        .where('replyId', isEqualTo: replyId)
        .where('userId', isEqualTo: userId)
        .where('emoji', isEqualTo: emoji)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return ReplyReaction.fromMap(snapshot.docs.first.data());
  }

  // ============ REPORT OPERATIONS (Phase 11 Step 3) ============

  @override
  Future<String> reportPost({
    required String postId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
    String? attachmentUrl,
  }) async {
    final post = await getPost(postId);
    final reportId = 'report_${DateTime.now().millisecondsSinceEpoch}';

    await _db.collection('contentReports').doc(reportId).set({
      'reportId': reportId,
      'contentId': postId,
      'contentType': 'post',
      'reportedByUserId': reportedByUserId,
      'channelId': post?.channelId ?? '',
      'category': category.index,
      'description': description,
      'attachmentUrl': attachmentUrl,
      'status': ReportStatus.pending.index,
      'createdAt': Timestamp.now(),
    });

    return reportId;
  }

  @override
  Future<String> reportReply({
    required String replyId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
    String? attachmentUrl,
  }) async {
    final reply = await getReply(replyId);
    final reportId = 'report_${DateTime.now().millisecondsSinceEpoch}';

    await _db.collection('contentReports').doc(reportId).set({
      'reportId': reportId,
      'contentId': replyId,
      'contentType': 'reply',
      'reportedByUserId': reportedByUserId,
      'channelId': reply?.channelId ?? '',
      'category': category.index,
      'description': description,
      'attachmentUrl': attachmentUrl,
      'status': ReportStatus.pending.index,
      'createdAt': Timestamp.now(),
    });

    return reportId;
  }

  @override
  Future<String> reportUser({
    required String reportedUserId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
  }) async {
    final reportId = 'report_${DateTime.now().millisecondsSinceEpoch}';

    await _db.collection('contentReports').doc(reportId).set({
      'reportId': reportId,
      'contentId': reportedUserId,
      'contentType': 'user',
      'reportedByUserId': reportedByUserId,
      'reportedUserId': reportedUserId,
      'category': category.index,
      'description': description,
      'status': ReportStatus.pending.index,
      'createdAt': Timestamp.now(),
    });

    return reportId;
  }

  @override
  Future<ContentReport?> getReport(String reportId) async {
    final doc = await _db.collection('contentReports').doc(reportId).get();
    if (!doc.exists) return null;
    return ContentReport.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<ContentReport>> getChannelReports(
    String channelId, {
    ReportStatus? statusFilter,
    int limit = 50,
  }) async {
    var query = _db
        .collection('contentReports')
        .where('channelId', isEqualTo: channelId);

    if (statusFilter != null) {
      query = query.where('status', isEqualTo: statusFilter.index);
    }

    final snapshot = await query.limit(limit).get();

    return snapshot.docs
        .map((doc) => ContentReport.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<ContentReport>> getUserReports(
    String reportedUserId, {
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('contentReports')
        .where('reportedUserId', isEqualTo: reportedUserId)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ContentReport.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<ContentReport>> getReportedContentReports(
    String contentId, {
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('contentReports')
        .where('contentId', isEqualTo: contentId)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ContentReport.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<void> actionReport({
    required String reportId,
    required ReportAction action,
    required String moderatorId,
    String? reason,
    String? actionDetails,
  }) async {
    await _db.collection('contentReports').doc(reportId).update({
      'status': ReportStatus.upheld.index,
      'reviewedAt': Timestamp.now(),
      'reviewedBy': moderatorId,
      'action': action.index,
      'actionReason': reason,
      'actionDetails': actionDetails,
    });
  }

  @override
  Future<void> dismissReport({
    required String reportId,
    required String moderatorId,
    String? reason,
  }) async {
    await _db.collection('contentReports').doc(reportId).update({
      'status': ReportStatus.dismissed.index,
      'reviewedAt': Timestamp.now(),
      'reviewedBy': moderatorId,
      'actionReason': reason,
    });
  }

  @override
  Future<Map<String, int>> getReportStats(String channelId) async {
    final snapshot = await _db
        .collection('contentReports')
        .where('channelId', isEqualTo: channelId)
        .get();

    final reports = snapshot.docs;
    return {
      'total': reports.length,
      'pending': reports
          .where((r) =>
              (r.data() as Map<String, dynamic>)['status'] ==
              ReportStatus.pending.index)
          .length,
      'upheld': reports
          .where((r) =>
              (r.data() as Map<String, dynamic>)['status'] ==
              ReportStatus.upheld.index)
          .length,
      'dismissed': reports
          .where((r) =>
              (r.data() as Map<String, dynamic>)['status'] ==
              ReportStatus.dismissed.index)
          .length,
    };
  }

  // ============ TRENDING OPERATIONS (Phase 11 Step 3) ============

  @override
  Future<List<ChannelPost>> getTrendingPosts(
    String channelId, {
    String timeRange = 'day',
    int limit = 20,
  }) async {
    final posts = await getChannelPosts(channelId, statusFilter: PostStatus.published);
    posts.sort((a, b) {
      final scoreA = (a.likes * 1) + (a.replies * 3) + (a.views * 0.1);
      final scoreB = (b.likes * 1) + (b.replies * 3) + (b.views * 0.1);
      return scoreB.compareTo(scoreA);
    });
    return posts.take(limit).toList();
  }

  @override
  Future<List<ChannelPost>> getGlobalTrendingPosts({
    String timeRange = 'week',
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('channelPosts')
        .where('status', isEqualTo: PostStatus.published.index)
        .limit(limit * 2)
        .get();

    final posts = snapshot.docs
        .map((doc) => ChannelPost.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    posts.sort((a, b) {
      final scoreA = (a.likes * 1) + (a.replies * 3) + (a.views * 0.1);
      final scoreB = (b.likes * 1) + (b.replies * 3) + (b.views * 0.1);
      return scoreB.compareTo(scoreA);
    });

    return posts.take(limit).toList();
  }

  @override
  Future<List<ChannelPost>> getTrendingByCategory(
    String category, {
    String timeRange = 'week',
    int limit = 20,
  }) async {
    final channelSnapshot = await _db
        .collection('communityChannels')
        .where('category', isEqualTo: category)
        .get();

    final channelIds = channelSnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['channelId'] as String)
        .toSet();

    if (channelIds.isEmpty) return [];

    final posts = <ChannelPost>[];
    for (final channelId in channelIds) {
      posts.addAll(await getChannelPosts(channelId, statusFilter: PostStatus.published));
    }

    posts.sort((a, b) {
      final scoreA = (a.likes * 1) + (a.replies * 3) + (a.views * 0.1);
      final scoreB = (b.likes * 1) + (b.replies * 3) + (b.views * 0.1);
      return scoreB.compareTo(scoreA);
    });

    return posts.take(limit).toList();
  }

  @override
  Future<List<String>> getTrendingTags(
    String channelId, {
    int limit = 10,
  }) async {
    final posts = await getChannelPosts(channelId);
    final tagCounts = <String, int>{};

    for (final post in posts) {
      for (final tag in post.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    final sorted = tagCounts.entries.toList();
    sorted.sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((e) => e.key).take(limit).toList();
  }

  @override
  Future<double> calculateTrendingScore(String postId) async {
    final post = await getPost(postId);
    if (post == null) return 0.0;

    final engagementScore = (post.likes * 1) + (post.replies * 3) + (post.views * 0.1);
    final ageHours = DateTime.now().difference(post.createdAt).inHours;
    final timeDecay = 1.0 / (1.0 + (ageHours / 24.0));

    return engagementScore * timeDecay;
  }

  @override
  Future<PostEngagementAnalytics?> getPostEngagementAnalytics(
    String postId,
  ) async {
    final doc = await _db
        .collection('postEngagementAnalytics')
        .doc(postId)
        .get();

    if (!doc.exists) return null;
    return PostEngagementAnalytics.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> updateEngagementAnalytics(String postId) async {
    final post = await getPost(postId);
    if (post == null) return;

    final trendingScore = await calculateTrendingScore(postId);
    final reactionCount = await getReactionCount(postId);

    await _db.collection('postEngagementAnalytics').doc(postId).set({
      'analyticsId': postId,
      'postId': postId,
      'channelId': post.channelId,
      'reactionCount': reactionCount,
      'replyCount': post.replies,
      'likeCount': post.likes,
      'viewCount': post.views,
      'trendingScore': trendingScore,
      'lastUpdatedAt': Timestamp.now(),
    });
  }

  // Phase 11 Step 4: Channel Access Control & Invitations

  @override
  Future<String> createInvitation({
    required String channelId,
    required String invitedUserId,
    required String invitedByUserId,
    required String inviterName,
    String role = 'member',
    String? message,
  }) async {
    final invitationId = _db.collection('channels').doc().id;
    final invitationCode = _generateInvitationCode();

    await _db.collection('channels').doc(channelId).collection('invitations').doc(invitationId).set({
      'invitationId': invitationId,
      'channelId': channelId,
      'invitedUserId': invitedUserId,
      'invitedByUserId': invitedByUserId,
      'inviterName': inviterName,
      'role': role,
      'message': message,
      'status': 'pending',
      'createdAt': Timestamp.now(),
      'expiresAt': Timestamp.fromDate(DateTime.now().add(Duration(days: 14))),
      'invitationCode': invitationCode,
    });

    return invitationId;
  }

  @override
  Future<List<String>> inviteMultipleUsers({
    required String channelId,
    required List<String> invitedUserIds,
    required String invitedByUserId,
    required String inviterName,
    String role = 'member',
  }) async {
    final invitationIds = <String>[];

    for (final userId in invitedUserIds) {
      final id = await createInvitation(
        channelId: channelId,
        invitedUserId: userId,
        invitedByUserId: invitedByUserId,
        inviterName: inviterName,
        role: role,
      );
      invitationIds.add(id);
    }

    return invitationIds;
  }

  @override
  Future<ChannelInvitation?> getInvitation(String invitationId) async {
    // Note: In real implementation, would need to search across channels
    // For now, returning null as this is a simplified version
    return null;
  }

  @override
  Future<List<ChannelInvitation>> getUserInvitations(
    String userId, {
    bool includeExpired = false,
    int limit = 20,
  }) async {
    final snapshot = await _db
        .collectionGroup('invitations')
        .where('invitedUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ChannelInvitation.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ChannelInvitation>> getChannelInvitations(
    String channelId, {
    String? status,
    int limit = 20,
  }) async {
    var query = _db.collection('channels').doc(channelId).collection('invitations').limit(limit);

    if (status != null) {
      query = query.where('status', isEqualTo: status) as Query;
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => ChannelInvitation.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> acceptInvitation(String invitationId, String userId) async {
    // Find and update the invitation
    final snapshot = await _db
        .collectionGroup('invitations')
        .where('invitationId', isEqualTo: invitationId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final invitation = ChannelInvitation.fromMap(doc.data() as Map<String, dynamic>);

      // Add user as member
      await addChannelMember(
        invitation.channelId,
        userId,
        invitation.inviterName,
        invitation.role,
      );

      // Update invitation status
      await doc.reference.update({
        'status': 'accepted',
        'respondedAt': Timestamp.now(),
      });

      // Add to access history
      await _addAccessHistory(
        invitation.channelId,
        userId,
        'system',
        'joined',
        invitation.role,
        'Accepted invitation',
      );
    }
  }

  @override
  Future<void> declineInvitation(String invitationId, String userId) async {
    final snapshot = await _db
        .collectionGroup('invitations')
        .where('invitationId', isEqualTo: invitationId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'status': 'declined',
        'respondedAt': Timestamp.now(),
      });
    }
  }

  @override
  Future<void> cancelInvitation(String invitationId, String cancelledByUserId) async {
    final snapshot = await _db
        .collectionGroup('invitations')
        .where('invitationId', isEqualTo: invitationId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'status': 'cancelled',
      });
    }
  }

  @override
  Future<String> createAccessRequest({
    required String channelId,
    required String requestedByUserId,
    required String requesterName,
    String? reason,
  }) async {
    final requestId = _db.collection('channels').doc().id;

    await _db.collection('channels').doc(channelId).collection('accessRequests').doc(requestId).set({
      'requestId': requestId,
      'channelId': channelId,
      'requestedByUserId': requestedByUserId,
      'requesterName': requesterName,
      'reason': reason,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

    return requestId;
  }

  @override
  Future<AccessRequest?> getAccessRequest(String requestId) async {
    // Simplified: would need to search across channels
    return null;
  }

  @override
  Future<List<AccessRequest>> getChannelAccessRequests(
    String channelId, {
    String? status,
    int limit = 20,
  }) async {
    var query = _db.collection('channels').doc(channelId).collection('accessRequests').limit(limit);

    if (status != null) {
      query = query.where('status', isEqualTo: status) as Query;
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => AccessRequest.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AccessRequest>> getUserAccessRequests(
    String userId, {
    String? status,
    int limit = 10,
  }) async {
    final snapshot = await _db
        .collectionGroup('accessRequests')
        .where('requestedByUserId', isEqualTo: userId)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => AccessRequest.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> approveAccessRequest(
    String requestId,
    String approvedByUserId, {
    String role = 'member',
  }) async {
    // Find request
    final snapshot = await _db
        .collectionGroup('accessRequests')
        .where('requestId', isEqualTo: requestId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final request = AccessRequest.fromMap(doc.data() as Map<String, dynamic>);

      // Add user as member
      await addChannelMember(
        request.channelId,
        request.requestedByUserId,
        request.requesterName,
        role,
      );

      // Update request
      await doc.reference.update({
        'status': 'approved',
        'respondedAt': Timestamp.now(),
        'respondedByUserId': approvedByUserId,
        'approvedRole': role,
      });

      // Add to history
      await _addAccessHistory(
        request.channelId,
        request.requestedByUserId,
        approvedByUserId,
        'joined',
        role,
        'Access request approved',
      );
    }
  }

  @override
  Future<void> rejectAccessRequest(
    String requestId,
    String rejectedByUserId, {
    String? reason,
  }) async {
    final snapshot = await _db
        .collectionGroup('accessRequests')
        .where('requestId', isEqualTo: requestId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'status': 'rejected',
        'respondedAt': Timestamp.now(),
        'respondedByUserId': rejectedByUserId,
        'rejectionReason': reason,
      });
    }
  }

  @override
  Future<void> cancelAccessRequest(String requestId, String cancelledByUserId) async {
    final snapshot = await _db
        .collectionGroup('accessRequests')
        .where('requestId', isEqualTo: requestId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'status': 'cancelled',
      });
    }
  }

  Future<void> addChannelMember(
    String channelId,
    String userId,
    String userName,
    String role,
  ) async {
    final memberId = _db.collection('channels').doc().id;

    await _db.collection('channels').doc(channelId).collection('members').doc(memberId).set({
      'memberId': memberId,
      'userId': userId,
      'userName': userName,
      'role': role,
      'joinedAt': Timestamp.now(),
      'status': 'active',
    });
  }

  @override
  Future<List<ChannelMember>> getChannelMembers(
    String channelId, {
    String? role,
    int limit = 50,
  }) async {
    var query = _db.collection('channels').doc(channelId).collection('members').limit(limit);

    if (role != null) {
      query = query.where('role', isEqualTo: role) as Query;
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => ChannelMember.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ChannelMember?> getChannelMember(String channelId, String userId) async {
    final snapshot = await _db
        .collection('channels')
        .doc(channelId)
        .collection('members')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return ChannelMember.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
  }

  @override
  Future<void> updateMemberRole(
    String channelId,
    String userId,
    String newRole,
    String updatedByUserId,
  ) async {
    final snapshot = await _db
        .collection('channels')
        .doc(channelId)
        .collection('members')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final oldRole = (doc.data() as Map<String, dynamic>)['role'] as String?;

      await doc.reference.update({'role': newRole});

      // Add to history
      await _addAccessHistory(
        channelId,
        userId,
        updatedByUserId,
        'promoted',
        newRole,
        'Role updated',
        oldRole: oldRole,
      );
    }
  }

  @override
  Future<void> removeMember(
    String channelId,
    String userId,
    String removedByUserId,
  ) async {
    final snapshot = await _db
        .collection('channels')
        .doc(channelId)
        .collection('members')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      await doc.reference.delete();

      // Add to history
      await _addAccessHistory(
        channelId,
        userId,
        removedByUserId,
        'removed',
      );
    }
  }

  @override
  Future<void> leaveChannel(String channelId, String userId) async {
    final snapshot = await _db
        .collection('channels')
        .doc(channelId)
        .collection('members')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();

      // Add to history
      await _addAccessHistory(
        channelId,
        userId,
        userId,
        'left',
      );
    }
  }

  @override
  Future<bool> isChannelMember(String channelId, String userId) async {
    final snapshot = await _db
        .collection('channels')
        .doc(channelId)
        .collection('members')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  @override
  Future<String?> getUserRoleInChannel(String channelId, String userId) async {
    final member = await getChannelMember(channelId, userId);
    return member?.role;
  }

  @override
  Future<List<CommunityChannel>> getUserChannels(
    String userId, {
    String? role,
    int limit = 50,
  }) async {
    // Simplified: would need proper implementation
    return [];
  }

  @override
  Future<bool> canUserInvite(String channelId, String userId) async {
    final role = await getUserRoleInChannel(channelId, userId);
    return role == 'owner' || role == 'moderator';
  }

  @override
  Future<bool> canUserModerate(String channelId, String userId) async {
    final role = await getUserRoleInChannel(channelId, userId);
    return role == 'owner' || role == 'moderator';
  }

  @override
  Future<bool> canUserRemoveMembers(String channelId, String userId) async {
    final role = await getUserRoleInChannel(channelId, userId);
    return role == 'owner' || role == 'moderator';
  }

  @override
  Future<bool> hasPermission(
    String channelId,
    String userId,
    String permission,
  ) async {
    final role = await getUserRoleInChannel(channelId, userId);
    if (role == null) return false;

    // Basic permission mapping
    switch (permission) {
      case 'post_content':
        return role != 'guest';
      case 'invite':
        return role == 'owner' || role == 'moderator';
      case 'moderate':
        return role == 'owner' || role == 'moderator';
      case 'manage_roles':
        return role == 'owner';
      default:
        return false;
    }
  }

  @override
  Future<List<AccessHistoryEntry>> getChannelAccessHistory(
    String channelId, {
    String? actionType,
    int limit = 50,
  }) async {
    var query = _db.collection('accessHistory').where('channelId', isEqualTo: channelId).limit(limit);

    if (actionType != null) {
      query = query.where('action', isEqualTo: actionType) as Query;
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => AccessHistoryEntry.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<AccessHistoryEntry>> getUserAccessHistory(
    String userId, {
    int limit = 30,
  }) async {
    final snapshot = await _db
        .collection('accessHistory')
        .where('userId', isEqualTo: userId)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => AccessHistoryEntry.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AccessHistoryEntry?> getAccessHistoryEntry(String historyId) async {
    final doc = await _db.collection('accessHistory').doc(historyId).get();

    if (!doc.exists) return null;

    return AccessHistoryEntry.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<void> _addAccessHistory(
    String channelId,
    String userId,
    String actor,
    String action, [
    String? newRole,
    String? reason,
    String? oldRole,
  ]) async {
    final historyId = _db.collection('accessHistory').doc().id;

    await _db.collection('accessHistory').doc(historyId).set({
      'historyId': historyId,
      'channelId': channelId,
      'userId': userId,
      'actor': actor,
      'action': action,
      'oldRole': oldRole,
      'newRole': newRole,
      'reason': reason,
      'createdAt': Timestamp.now(),
      'metadata': {},
    });
  }

  String _generateInvitationCode() {
    return 'inv_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 10000).toString().padLeft(4, '0')}';
  }

  // Phase 11 Step 5: Advanced Search & Content Discovery

  @override
  Future<List<SearchResult>> searchPosts(
    String query, {
    String? channelId,
    String? authorId,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    String sortBy = 'relevance',
    int limit = 20,
  }) async {
    // Simplified full-text search implementation
    var postQuery = _db.collection('posts');

    if (channelId != null) {
      postQuery = postQuery.where('channelId', isEqualTo: channelId) as Query;
    }
    if (authorId != null) {
      postQuery = postQuery.where('authorId', isEqualTo: authorId) as Query;
    }
    if (status != null) {
      postQuery = postQuery.where('status', isEqualTo: status) as Query;
    }
    if (fromDate != null) {
      postQuery = postQuery.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate)) as Query;
    }
    if (toDate != null) {
      postQuery = postQuery.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(toDate)) as Query;
    }

    final snapshot = await (postQuery as Query).limit(limit).get();

    final results = <SearchResult>[];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      // Simple relevance scoring based on content
      final content = '${data['title']} ${data['content']}'.toLowerCase();
      final relevance = query.toLowerCase().split(' ').fold<double>(0.0, (score, term) {
        return score + (content.contains(term) ? 1.0 : 0.0);
      }) / query.split(' ').length;

      results.add(SearchResult(
        resultId: doc.id,
        query: query,
        contentType: 'post',
        contentId: doc.id,
        title: data['title'] as String? ?? '',
        snippet: (data['content'] as String? ?? '').substring(0, 150),
        relevanceScore: relevance,
        author: data['authorName'] as String? ?? '',
        authorId: data['authorId'] as String? ?? '',
        channelId: data['channelId'] as String? ?? '',
        tags: (data['tags'] as List?)?.cast<String>() ?? [],
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        replyCount: data['replies'] as int? ?? 0,
        reactionCount: data['likes'] as int? ?? 0,
        viewCount: data['views'] as int? ?? 0,
        url: '/post/${doc.id}',
      ));
    }

    // Sort by relevance
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    return results;
  }

  @override
  Future<List<SearchResult>> searchPostsByDateRange({
    required String query,
    required DateTime fromDate,
    required DateTime toDate,
    int limit = 20,
  }) async {
    return searchPosts(query, fromDate: fromDate, toDate: toDate, limit: limit);
  }

  @override
  Future<List<SearchResult>> searchPostsByTags({
    required List<String> tags,
    int limit = 20,
  }) async {
    // Simplified tag search
    final snapshot = await _db
        .collection('posts')
        .where('tags', arrayContainsAny: tags)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return SearchResult(
            resultId: doc.id,
            query: tags.join(','),
            contentType: 'post',
            contentId: doc.id,
            title: data['title'] as String? ?? '',
            snippet: (data['content'] as String? ?? '').substring(0, 150),
            relevanceScore: 1.0,
            author: data['authorName'] as String? ?? '',
            authorId: data['authorId'] as String? ?? '',
            channelId: data['channelId'] as String? ?? '',
            tags: (data['tags'] as List?)?.cast<String>() ?? [],
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            replyCount: data['replies'] as int? ?? 0,
            reactionCount: data['likes'] as int? ?? 0,
            viewCount: data['views'] as int? ?? 0,
            url: '/post/${doc.id}',
          );
        })
        .toList();
  }

  @override
  Future<SearchResult?> getSearchResult(String resultId) async {
    final doc = await _db.collection('posts').doc(resultId).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return SearchResult(
      resultId: doc.id,
      query: '',
      contentType: 'post',
      contentId: doc.id,
      title: data['title'] as String? ?? '',
      snippet: (data['content'] as String? ?? '').substring(0, 150),
      relevanceScore: 1.0,
      author: data['authorName'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      channelId: data['channelId'] as String? ?? '',
      tags: (data['tags'] as List?)?.cast<String>() ?? [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      replyCount: data['replies'] as int? ?? 0,
      reactionCount: data['likes'] as int? ?? 0,
      viewCount: data['views'] as int? ?? 0,
      url: '/post/${doc.id}',
    );
  }

  @override
  Future<List<CommunityChannel>> searchChannels(
    String query, {
    String? category,
    String sortBy = 'relevance',
    int limit = 20,
  }) async {
    var channelQuery = _db.collection('communityChannels').where('isArchived', isEqualTo: false);

    if (category != null) {
      channelQuery = channelQuery.where('category', isEqualTo: category) as Query;
    }

    final snapshot = await (channelQuery as Query).limit(limit).get();

    return snapshot.docs
        .map((doc) => CommunityChannel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CommunityChannel>> getPopularChannels({int limit = 10}) async {
    final snapshot = await _db
        .collection('communityChannels')
        .where('isArchived', isEqualTo: false)
        .orderBy('memberCount', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => CommunityChannel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CommunityChannel>> getTrendingChannels({int limit = 10}) async {
    final snapshot = await _db
        .collection('communityChannels')
        .where('isArchived', isEqualTo: false)
        .orderBy('lastActivityAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => CommunityChannel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(
    String query, {
    int limit = 20,
  }) async {
    // Simplified user search
    return [];
  }

  @override
  Future<Map<String, dynamic>?> searchUserByUsername(String username) async {
    // Simplified username search
    return null;
  }

  @override
  Future<List<SearchSuggestion>> getSearchSuggestions(
    String partialQuery, {
    String category = 'all',
    int limit = 10,
  }) async {
    final snapshot = await _db
        .collection('searchSuggestions')
        .where('text', isGreaterThanOrEqualTo: partialQuery)
        .where('text', isLessThan: '${partialQuery}z')
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => SearchSuggestion.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> recordSearch({
    required String userId,
    required String query,
    required int resultCount,
    Map<String, dynamic>? filters,
  }) async {
    final queryId = _db.collection('searchQueries').doc().id;
    final timeMs = DateTime.now().millisecondsSinceEpoch;

    await _db.collection('searchQueries').doc(queryId).set({
      'queryId': queryId,
      'userId': userId,
      'query': query,
      'resultCount': resultCount,
      'timeMs': timeMs,
      'filters': filters ?? {},
      'createdAt': Timestamp.now(),
    });
  }

  @override
  Future<List<SearchQuery>> getUserSearchHistory(
    String userId, {
    int limit = 20,
  }) async {
    final snapshot = await _db
        .collection('searchQueries')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => SearchQuery.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SearchQuery>> getTrendingSearches({
    String timeRange = 'week',
    int limit = 10,
  }) async {
    final snapshot = await _db.collection('searchAnalytics').limit(limit).get();

    return [];
  }

  @override
  Future<void> clearSearchHistory(String userId) async {
    final snapshot = await _db
        .collection('searchQueries')
        .where('userId', isEqualTo: userId)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<String> saveSearch({
    required String userId,
    required String query,
    required String name,
    String? description,
    Map<String, dynamic>? filters,
  }) async {
    final savedSearchId = _db.collection('savedSearches').doc().id;

    await _db.collection('savedSearches').doc(savedSearchId).set({
      'savedSearchId': savedSearchId,
      'userId': userId,
      'query': query,
      'name': name,
      'description': description,
      'filters': filters ?? {},
      'createdAt': Timestamp.now(),
      'useCount': 0,
    });

    return savedSearchId;
  }

  @override
  Future<SavedSearch?> getSavedSearch(String savedSearchId) async {
    final doc = await _db.collection('savedSearches').doc(savedSearchId).get();
    if (!doc.exists) return null;

    return SavedSearch.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<SavedSearch>> getSavedSearches(String userId) async {
    final snapshot = await _db
        .collection('savedSearches')
        .where('userId', isEqualTo: userId)
        .orderBy('lastUsedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SavedSearch.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> updateSavedSearch(
    String savedSearchId, {
    String? name,
    String? description,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;

    if (updates.isNotEmpty) {
      await _db.collection('savedSearches').doc(savedSearchId).update(updates);
    }
  }

  @override
  Future<void> deleteSavedSearch(String savedSearchId) async {
    await _db.collection('savedSearches').doc(savedSearchId).delete();
  }

  @override
  Future<void> useSavedSearch(String savedSearchId) async {
    await _db.collection('savedSearches').doc(savedSearchId).update({
      'lastUsedAt': Timestamp.now(),
      'useCount': FieldValue.increment(1),
    });
  }

  @override
  Future<List<SearchQuery>> getSearchAnalytics({
    String? query,
    String timeRange = 'week',
    int limit = 20,
  }) async {
    // Simplified analytics
    return [];
  }

  @override
  Future<Map<String, dynamic>> getSearchStats() async {
    return {
      'totalSearches': 0,
      'uniqueUsers': 0,
      'averageResults': 0.0,
      'trendingSearches': [],
    };
  }

  // Report Appeals
  @override
  Future<String> createReportAppeal({
    required String reportId,
    required String userId,
    String? userName,
    required String reason,
    String? attachmentUrl,
  }) async {
    final appealId = _db.collection('reportAppeals').doc().id;

    await _db.collection('reportAppeals').doc(appealId).set({
      'appealId': appealId,
      'reportId': reportId,
      'userId': userId,
      'userName': userName,
      'reason': reason,
      'attachmentUrl': attachmentUrl,
      'status': AppealStatus.pending.index,
      'createdAt': Timestamp.now(),
      'canAppealFurther': true,
    });

    return appealId;
  }

  @override
  Future<ReportAppeal?> getReportAppeal(String appealId) async {
    final doc = await _db.collection('reportAppeals').doc(appealId).get();
    if (!doc.exists) return null;
    return ReportAppeal.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<ReportAppeal>> getReportAppeals({
    required String reportId,
    String? status,
    int limit = 20,
  }) async {
    var query = _db
        .collection('reportAppeals')
        .where('reportId', isEqualTo: reportId) as Query<Map<String, dynamic>>;

    if (status != null && status.isNotEmpty) {
      final statusIndex = AppealStatus.values.indexWhere((s) => s.toString().split('.').last == status);
      if (statusIndex >= 0) {
        query = query.where('status', isEqualTo: statusIndex);
      }
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs
        .map((doc) => ReportAppeal.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<ReportAppeal>> getUserAppeals({
    required String userId,
    String status = 'all',
    int limit = 20,
  }) async {
    var query = _db
        .collection('reportAppeals')
        .where('userId', isEqualTo: userId) as Query<Map<String, dynamic>>;

    if (status != 'all' && status.isNotEmpty) {
      final statusIndex = AppealStatus.values.indexWhere((s) => s.toString().split('.').last == status);
      if (statusIndex >= 0) {
        query = query.where('status', isEqualTo: statusIndex);
      }
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs
        .map((doc) => ReportAppeal.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<void> respondToAppeal({
    required String appealId,
    required String respondedByUserId,
    required String decision,
    String? reasoning,
    String? newAction,
  }) async {
    final appealStatus = AppealStatus.values
        .firstWhere((s) => s.toString().split('.').last == decision, orElse: () => AppealStatus.pending);

    await _db.collection('reportAppeals').doc(appealId).update({
      'status': appealStatus.index,
      'respondedByUserId': respondedByUserId,
      'respondedAt': Timestamp.now(),
      'reasoning': reasoning,
      'newAction': newAction,
    });
  }

  // Moderation Dashboard
  @override
  Future<ModerationSummary?> getModerationSummary({
    String timeRange = 'day',
  }) async {
    final snapshot = await _db
        .collection('moderationSummaries')
        .where('timeRange', isEqualTo: timeRange)
        .orderBy('startDate', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return ModerationSummary.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
  }

  @override
  Future<ModerationSummary?> getModerationAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final snapshot = await _db
        .collection('moderationSummaries')
        .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('endDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return ModerationSummary.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
  }

  @override
  Future<ModeratorStats?> getModeratorStats({
    required String userId,
    String timeRange = 'month',
  }) async {
    final doc = await _db
        .collection('moderatorStats')
        .where('moderatorId', isEqualTo: userId)
        .where('timeRange', isEqualTo: timeRange)
        .limit(1)
        .get();

    if (doc.docs.isEmpty) return null;
    return ModeratorStats.fromMap(doc.docs.first.data() as Map<String, dynamic>);
  }

  @override
  Future<List<ModeratorStats>> getTeamModerationStats({
    String timeRange = 'month',
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('moderatorStats')
        .where('timeRange', isEqualTo: timeRange)
        .orderBy('totalActionsCount', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ModeratorStats.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> compareModerators({
    required List<String> moderatorIds,
    required String metric,
  }) async {
    final statsList = <ModeratorStats>[];
    for (final modId in moderatorIds) {
      final stats = await getModeratorStats(userId: modId);
      if (stats != null) {
        statsList.add(stats);
      }
    }

    return {
      'moderators': statsList.map((s) => s.toMap()).toList(),
      'metric': metric,
    };
  }

  // Action History & Audit Trail
  @override
  Future<List<ModerationActionRecord>> getModerationActionHistory({
    int limit = 100,
    String? actionType,
  }) async {
    var query = _db.collection('moderationActions') as Query<Map<String, dynamic>>;

    if (actionType != null) {
      final typeIndex = ModerationActionType.values
          .indexWhere((t) => t.toString().split('.').last == actionType);
      if (typeIndex >= 0) {
        query = query.where('actionType', isEqualTo: typeIndex);
      }
    }

    final snapshot = await query.orderBy('createdAt', descending: true).limit(limit).get();
    return snapshot.docs
        .map((doc) => ModerationActionRecord.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<ModerationActionRecord>> getModeratorActionHistory({
    required String userId,
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('moderationActions')
        .where('moderatorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ModerationActionRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ModerationActionRecord>> getUserModerationHistory({
    required String userId,
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('moderationActions')
        .where('targetUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ModerationActionRecord.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ModerationActionRecord?> getModerationAction(String actionId) async {
    final doc = await _db.collection('moderationActions').doc(actionId).get();
    if (!doc.exists) return null;
    return ModerationActionRecord.fromMap(doc.data() as Map<String, dynamic>);
  }

  // Escalation Management
  @override
  Future<void> escalateReport({
    required String reportId,
    required String escalatedByUserId,
    required String reason,
    required String escalateTo,
  }) async {
    final escalationId = _db.collection('escalations').doc().id;
    final targetIndex = EscalationTarget.values
        .indexWhere((t) => t.toString().split('.').last == escalateTo);

    await _db.collection('escalations').doc(escalationId).set({
      'escalationId': escalationId,
      'reportId': reportId,
      'escalatedByUserId': escalatedByUserId,
      'escalatedAt': Timestamp.now(),
      'escalateTo': targetIndex >= 0 ? targetIndex : EscalationTarget.adminReview.index,
      'reason': reason,
      'status': EscalationStatus.pending.index,
    });
  }

  @override
  Future<List<Escalation>> getEscalations({
    String status = 'pending',
    int limit = 50,
  }) async {
    final statusIndex = EscalationStatus.values
        .indexWhere((s) => s.toString().split('.').last == status);

    var query = _db.collection('escalations') as Query<Map<String, dynamic>>;
    if (statusIndex >= 0) {
      query = query.where('status', isEqualTo: statusIndex);
    }

    final snapshot = await query.orderBy('escalatedAt', descending: true).limit(limit).get();
    return snapshot.docs
        .map((doc) => Escalation.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<void> processEscalation({
    required String escalationId,
    required String processedByUserId,
    required String decision,
    String? notes,
  }) async {
    final decisionStatus = EscalationStatus.values
        .firstWhere((s) => s.toString().split('.').last == decision, orElse: () => EscalationStatus.pending);

    await _db.collection('escalations').doc(escalationId).update({
      'status': decisionStatus.index,
      'processedByUserId': processedByUserId,
      'processedAt': Timestamp.now(),
      'decision': decision,
      'notes': notes,
    });
  }

  // User Reputation & Gamification
  @override
  Future<String> addReputationEvent({
    required String userId,
    required String eventType,
    required int points,
    required String reason,
    String? relatedContentId,
    Map<String, dynamic>? metadata,
  }) async {
    final eventId = _db.collection('reputationEvents').doc().id;
    final typeIndex = ReputationEventType.values.indexWhere((t) => t.toString().split('.').last == eventType);

    await _db.collection('reputationEvents').doc(eventId).set({
      'eventId': eventId,
      'userId': userId,
      'eventType': typeIndex >= 0 ? typeIndex : ReputationEventType.postCreated.index,
      'points': points,
      'reason': reason,
      'relatedContentId': relatedContentId,
      'createdAt': Timestamp.now(),
      'metadata': metadata ?? {},
    });

    await _updateUserReputation(userId, points);
    return eventId;
  }

  Future<void> _updateUserReputation(String userId, int points) async {
    final repDoc = await _db.collection('userReputation').where('userId', isEqualTo: userId).limit(1).get();

    if (repDoc.docs.isEmpty) {
      final repId = _db.collection('userReputation').doc().id;
      await _db.collection('userReputation').doc(repId).set({
        'reputationId': repId,
        'userId': userId,
        'totalScore': points,
        'currentLevel': 1,
        'levelTitle': 'Novice',
        'postsCount': 0,
        'repliesCount': 0,
        'upvotesReceived': 0,
        'badgesCount': 0,
        'createdAt': Timestamp.now(),
        'lastActivityAt': Timestamp.now(),
      });
    } else {
      final doc = repDoc.docs.first;
      final currentScore = (doc['totalScore'] as int? ?? 0) + points;
      await doc.reference.update({
        'totalScore': currentScore,
        'lastActivityAt': Timestamp.now(),
      });
    }
  }

  @override
  Future<UserReputation?> getUserReputation(String userId) async {
    final doc = await _db.collection('userReputation').where('userId', isEqualTo: userId).limit(1).get();
    if (doc.docs.isEmpty) return null;
    return UserReputation.fromMap(doc.docs.first.data() as Map<String, dynamic>);
  }

  @override
  Future<List<ReputationEvent>> getReputationEvents({
    required String userId,
    int limit = 50,
  }) async {
    final snapshot = await _db
        .collection('reputationEvents')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ReputationEvent.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    final rep = await getUserReputation(userId);
    if (rep == null) {
      return {
        'totalReputation': 0,
        'level': 1,
        'posts': 0,
        'replies': 0,
        'badges': 0,
      };
    }

    return {
      'totalReputation': rep.totalScore,
      'level': rep.currentLevel,
      'levelTitle': rep.levelTitle,
      'posts': rep.postsCount,
      'replies': rep.repliesCount,
      'upvotes': rep.upvotesReceived,
      'badges': rep.badgesCount,
    };
  }

  @override
  Future<int> getTotalReputation(String userId) async {
    final rep = await getUserReputation(userId);
    return rep?.totalScore ?? 0;
  }

  // Badges
  @override
  Future<String> createBadgeDefinition({
    required String name,
    required String description,
    required String category,
    required String rarity,
    required int pointsValue,
    required String iconUrl,
    Map<String, dynamic>? requirements,
  }) async {
    final badgeId = _db.collection('badgeDefinitions').doc().id;
    final categoryIndex = BadgeCategory.values.indexWhere((c) => c.toString().split('.').last == category);
    final rarityIndex = BadgeRarity.values.indexWhere((r) => r.toString().split('.').last == rarity);

    await _db.collection('badgeDefinitions').doc(badgeId).set({
      'badgeId': badgeId,
      'name': name,
      'description': description,
      'category': categoryIndex >= 0 ? categoryIndex : BadgeCategory.social.index,
      'rarity': rarityIndex >= 0 ? rarityIndex : BadgeRarity.common.index,
      'pointsValue': pointsValue,
      'iconUrl': iconUrl,
      'requirements': requirements ?? {},
      'createdAt': Timestamp.now(),
      'isActive': true,
    });

    return badgeId;
  }

  @override
  Future<BadgeDefinition?> getBadgeDefinition(String badgeId) async {
    final doc = await _db.collection('badgeDefinitions').doc(badgeId).get();
    if (!doc.exists) return null;
    return BadgeDefinition.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<BadgeDefinition>> getBadgeDefinitions({
    String? category,
    int limit = 50,
  }) async {
    var query = _db.collection('badgeDefinitions') as Query<Map<String, dynamic>>;

    if (category != null && category.isNotEmpty) {
      final categoryIndex = BadgeCategory.values.indexWhere((c) => c.toString().split('.').last == category);
      if (categoryIndex >= 0) {
        query = query.where('category', isEqualTo: categoryIndex);
      }
    }

    final snapshot = await query.limit(limit).get();
    return snapshot.docs
        .map((doc) => BadgeDefinition.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<List<UserBadge>> getUserBadges(String userId) async {
    final snapshot = await _db
        .collection('userBadges')
        .where('userId', isEqualTo: userId)
        .orderBy('earnedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => UserBadge.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> awardBadge({
    required String userId,
    required String badgeId,
    String? awardedBy,
    String? reason,
  }) async {
    final userBadgeId = _db.collection('userBadges').doc().id;

    await _db.collection('userBadges').doc(userBadgeId).set({
      'userBadgeId': userBadgeId,
      'badgeId': badgeId,
      'userId': userId,
      'earnedAt': Timestamp.now(),
      'awardedBy': awardedBy,
      'reason': reason,
      'isDisplayed': true,
      'level': 1,
    });

    final rep = await getUserReputation(userId);
    if (rep != null) {
      await _db.collection('userReputation').doc(rep.reputationId).update({
        'badgesCount': rep.badgesCount + 1,
      });
    }
  }

  @override
  Future<Map<String, dynamic>> getBadgeProgress({
    required String userId,
    required String badgeId,
  }) async {
    final badges = await getUserBadges(userId);
    final earned = badges.any((b) => b.badgeId == badgeId);

    return {
      'badgeId': badgeId,
      'userId': userId,
      'earned': earned,
      'progress': earned ? 1.0 : 0.0,
    };
  }

  // Leaderboards
  @override
  Future<List<Map<String, dynamic>>> getTopContributors({
    int limit = 100,
    String timeRange = 'all',
  }) async {
    final snapshot = await _db
        .collection('userReputation')
        .orderBy('totalScore', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.asMap().entries.map((e) {
      final data = e.value.data() as Map<String, dynamic>;
      return {
        ...data,
        'rank': e.key + 1,
      };
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getLeaderboard({
    required String metric,
    int limit = 50,
    String timeRange = 'month',
  }) async {
    var query = _db.collection('userReputation') as Query<Map<String, dynamic>>;

    if (metric == 'reputation') {
      query = query.orderBy('totalScore', descending: true);
    } else if (metric == 'posts') {
      query = query.orderBy('postsCount', descending: true);
    } else if (metric == 'badges') {
      query = query.orderBy('badgesCount', descending: true);
    } else {
      query = query.orderBy('totalScore', descending: true);
    }

    final snapshot = await query.limit(limit).get();

    return snapshot.docs.asMap().entries.map((e) {
      final data = e.value.data();
      return {
        ...data,
        'rank': e.key + 1,
      };
    }).toList();
  }

  @override
  Future<Map<String, dynamic>?> getUserRank({
    required String userId,
    required String metric,
  }) async {
    final leaderboard = await getLeaderboard(metric: metric, limit: 10000);
    for (final entry in leaderboard) {
      if (entry['userId'] == userId) {
        return entry;
      }
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getNearbyRanks({
    required String userId,
    required String metric,
    int range = 5,
  }) async {
    final userRank = await getUserRank(userId: userId, metric: metric);
    if (userRank == null) return [];

    final rank = (userRank['rank'] as int?) ?? 0;
    final leaderboard = await getLeaderboard(metric: metric, limit: 10000);

    return leaderboard
        .where((e) {
          final entryRank = (e['rank'] as int?) ?? 0;
          return (entryRank >= rank - range) && (entryRank <= rank + range);
        })
        .toList();
  }

  // Levels & Progression
  @override
  Future<Map<String, dynamic>> getUserLevel(String userId) async {
    final rep = await getUserReputation(userId);
    if (rep == null) {
      return {
        'level': 1,
        'title': 'Novice',
        'experience': 0,
        'nextLevelAt': 50,
      };
    }

    return {
      'level': rep.currentLevel,
      'title': rep.levelTitle,
      'experience': rep.totalScore,
      'nextLevelAt': rep.currentLevel * 50,
    };
  }

  @override
  Future<void> checkAndProcessLevelUp(String userId) async {
    final rep = await getUserReputation(userId);
    if (rep == null) return;

    final nextLevelThreshold = rep.currentLevel * 50;
    if (rep.totalScore >= nextLevelThreshold) {
      final newLevel = rep.currentLevel + 1;
      final levelTitles = ['Novice', 'Contributor', 'Expert', 'Authority', 'Specialist', 'Legend'];
      final titleIndex = ((newLevel - 1) ~/ 5).clamp(0, levelTitles.length - 1);

      await _db.collection('userReputation').doc(rep.reputationId).update({
        'currentLevel': newLevel,
        'levelTitle': levelTitles[titleIndex],
      });
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLevelDefinitions() async {
    return [
      {'level': 1, 'title': 'Novice', 'minXP': 0},
      {'level': 2, 'title': 'Novice', 'minXP': 50},
      {'level': 3, 'title': 'Contributor', 'minXP': 150},
      {'level': 4, 'title': 'Contributor', 'minXP': 300},
      {'level': 5, 'title': 'Expert', 'minXP': 500},
      {'level': 6, 'title': 'Expert', 'minXP': 750},
    ];
  }

  // Community Analytics & Insights
  @override
  Future<Map<String, dynamic>> getPlatformOverview({
    String timeRange = 'week',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return {
      'dau': 0,
      'mau': 0,
      'newUsers': 0,
      'totalUsers': 0,
      'postsCreated': 0,
      'repliesCreated': 0,
      'reportsSubmitted': 0,
      'moderationActions': 0,
      'revenue': 0.0,
      'subscriptions': 0,
    };
  }

  @override
  Future<Map<String, dynamic>> getKeyMetrics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return {
      'period': 'custom',
      'metrics': [],
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getMetricTrends({
    required String metric,
    String timeRange = 'month',
    String granularity = 'daily',
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getUserEngagementStats({
    String timeRange = 'week',
  }) async {
    return {
      'avgPostsPerUser': 0.0,
      'avgRepliesPerUser': 0.0,
      'engagementRate': 0.0,
    };
  }

  @override
  Future<Map<String, dynamic>> getUserRetention({
    required DateTime cohortDate,
  }) async {
    return {};
  }

  @override
  Future<List<Map<String, dynamic>>> getEngagementBySegment({
    required String segment,
    int limit = 50,
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getContentAnalytics({
    String timeRange = 'week',
  }) async {
    return {
      'totalPosts': 0,
      'totalReplies': 0,
      'avgEngagement': 0.0,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getTrendingContent({
    String timeRange = 'day',
    int limit = 20,
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getChannelContentAnalytics({
    required String channelId,
    String timeRange = 'month',
  }) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> getCommunityHealthScore({
    String timeRange = 'week',
  }) async {
    return {
      'overallScore': 75.0,
      'sentimentScore': 0.7,
      'toxicityLevel': 0.1,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getCommunityHealthTrends({
    String timeRange = 'month',
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getChannelHealthMetrics({
    required String channelId,
  }) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> getUserGrowthMetrics({
    String timeRange = 'month',
  }) async {
    return {
      'newUsersPerDay': 0.0,
      'churnRate': 0.0,
      'netGrowth': 0.0,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getCohortRetention({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getUserAcquisitionAnalytics({
    String timeRange = 'month',
  }) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> getModerationAnalyticsOverview({
    String timeRange = 'week',
  }) async {
    return {
      'reportsPerDay': 0.0,
      'actionsPerDay': 0.0,
      'appealRate': 0.0,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getModeratorEffectiveness({
    String timeRange = 'month',
    int limit = 50,
  }) async {
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getModerationHotspots({
    String timeRange = 'week',
    int limit = 20,
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getRevenueAnalytics({
    String timeRange = 'month',
  }) async {
    return {
      'totalRevenue': 0.0,
      'subscriptionRevenue': 0.0,
      'arpu': 0.0,
    };
  }

  @override
  Future<Map<String, dynamic>> getSubscriptionAnalytics({
    String timeRange = 'month',
  }) async {
    return {
      'activeSubscriptions': 0,
      'churnRate': 0.0,
      'upgradeRate': 0.0,
    };
  }

  @override
  Future<Map<String, dynamic>> getConversionFunnel({
    String timeRange = 'week',
  }) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> generateCustomReport({
    required String name,
    required List<String> metrics,
    Map<String, dynamic>? filters,
    String timeRange = 'week',
    String format = 'json',
  }) async {
    return {
      'reportId': 'report_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'metrics': metrics,
      'format': format,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getSavedReports({
    int limit = 20,
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> exportAnalyticsData({
    List<String> metrics = const ['all'],
    String timeRange = 'month',
    String format = 'csv',
  }) async {
    return {
      'exportId': 'export_${DateTime.now().millisecondsSinceEpoch}',
      'format': format,
      'metricsCount': 0,
    };
  }

  // Practice Test & Mock Exam Implementation
  @override
  Future<String> createQuestion({
    required String questionText,
    required QuestionType questionType,
    required String topic,
    required QuestionDifficulty difficulty,
    List<String> options = const [],
    int? correctAnswerIndex,
    String? correctAnswer,
    String explanation = '',
    List<String> tags = const [],
  }) async {
    return 'question_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<Question?> getQuestion(String questionId) async {
    return null;
  }

  @override
  Future<List<Question>> getQuestions({
    String? topic,
    QuestionDifficulty? difficulty,
    int limit = 50,
  }) async {
    return [];
  }

  @override
  Future<List<Question>> getQuestionsByTopic(String topic) async {
    return [];
  }

  @override
  Future<List<Question>> getQuestionsByDifficulty(QuestionDifficulty difficulty) async {
    return [];
  }

  @override
  Future<List<Question>> searchQuestions(String query) async {
    return [];
  }

  @override
  Future<String> startPracticeTest({
    required String userId,
    required String topic,
    required QuestionDifficulty difficulty,
    int questionCount = 10,
    int timeLimit = 600,
  }) async {
    return 'test_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> submitAnswer({
    required String testId,
    required String questionId,
    dynamic selectedAnswer,
    int timeTaken = 0,
  }) async {
    // No-op for Firebase stub
  }

  @override
  Future<Map<String, dynamic>> completePracticeTest(String testId) async {
    return {
      'score': 0,
      'percentage': 0.0,
      'passed': false,
    };
  }

  @override
  Future<Map<String, dynamic>?> getPracticeTestResults(String testId) async {
    return null;
  }

  @override
  Future<List<PracticeTest>> getPracticeTestHistory({
    required String userId,
    int limit = 50,
  }) async {
    return [];
  }

  @override
  Future<Map<String, double>> getTopicPerformance(
    String userId,
    String topic,
  ) async {
    return {};
  }

  @override
  Future<String> startMockExam({
    required String userId,
    required ExamType examType,
    bool randomizeQuestions = true,
    bool showTimer = true,
  }) async {
    return 'exam_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<List<Question>> getMockExamQuestions(String examId) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> completeMockExam(String examId) async {
    return {
      'score': 0,
      'percentage': 0.0,
      'passed': false,
    };
  }

  @override
  Future<Map<String, dynamic>> getTestStatistics({
    required String userId,
    String timeRange = 'month',
  }) async {
    return {
      'totalTests': 0,
      'averageScore': 0.0,
      'passRate': 0.0,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getScoreTrends({
    required String userId,
    int limit = 30,
  }) async {
    return [];
  }

  @override
  Future<Map<String, double>> getPerformanceByTopic(String userId) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> generateStudyPlan(String userId) async {
    return {
      'planId': 'plan_${DateTime.now().millisecondsSinceEpoch}',
      'topics': [],
      'estimatedHours': 0.0,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getWeakAreas({
    required String userId,
    double threshold = 70.0,
  }) async {
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getTestAchievements(String userId) async {
    return [];
  }
}

/// Stub implementation for testing
class StubCommunityService implements CommunityService {
  final Map<String, CommunityChannel> _channels = {};
  final Map<String, ChannelMember> _members = {};
  final Map<String, ChannelPost> _posts = {};
  final Map<String, PostReply> _replies = {};
  final Map<String, ModerationRecord> _records = {};
  final Map<String, ChannelStats> _stats = {};
  final Map<String, Mention> _mentions = {}; // Phase 11 Step 2
  final Map<String, UserNotification> _notifications = {}; // Phase 11 Step 2
  final Map<String, NotificationPreferences> _preferences = {}; // Phase 11 Step 2
  final Map<String, PostReaction> _postReactions = {}; // Phase 11 Step 3
  final Map<String, ReplyReaction> _replyReactions = {}; // Phase 11 Step 3
  final Map<String, ContentReport> _reports = {}; // Phase 11 Step 3
  final Map<String, PostEngagementAnalytics> _analytics = {}; // Phase 11 Step 3

  @override
  Future<String> createChannel({
    required String name,
    required String ownerId,
    String? description,
    required ChannelType type,
    String? bannerUrl,
    String? iconUrl,
    String? category,
    List<String> tags = const [],
  }) async {
    final channelId = 'channel_${_channels.length}';
    _channels[channelId] = CommunityChannel(
      channelId: channelId,
      name: name,
      description: description,
      type: type,
      ownerId: ownerId,
      memberIds: [ownerId],
      bannerUrl: bannerUrl,
      iconUrl: iconUrl,
      memberCount: 1,
      createdAt: DateTime.now(),
      category: category,
      tags: tags,
    );

    final memberId = 'member_${_members.length}';
    _members[memberId] = ChannelMember(
      memberId: memberId,
      channelId: channelId,
      userId: ownerId,
      role: MemberRole.owner,
      joinedAt: DateTime.now(),
    );

    final statsId = 'stats_$channelId';
    _stats[statsId] = ChannelStats(
      statsId: statsId,
      channelId: channelId,
      totalMembers: 1,
      updatedAt: DateTime.now(),
    );

    return channelId;
  }

  @override
  Future<CommunityChannel?> getChannel(String channelId) async {
    return _channels[channelId];
  }

  @override
  Future<List<CommunityChannel>> getChannelsByCategory(
    String category, {
    int limit = 50,
  }) async {
    return _channels.values
        .where((ch) => ch.category == category && !ch.isArchived)
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<CommunityChannel>> searchChannels(
    String query, {
    int limit = 50,
  }) async {
    return _channels.values
        .where((ch) =>
            !ch.isArchived &&
            (ch.name.toLowerCase().contains(query.toLowerCase()) ||
                ch.description?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<CommunityChannel>> getPublicChannels({int limit = 50}) async {
    return _channels.values
        .where((ch) => ch.isPublic && !ch.isArchived)
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<void> updateChannel(String channelId, CommunityChannel channel) async {
    _channels[channelId] = channel;
  }

  @override
  Future<void> archiveChannel(String channelId) async {
    final channel = _channels[channelId];
    if (channel != null) {
      _channels[channelId] = channel.copyWith(isArchived: true);
    }
  }

  @override
  Future<String> addMemberToChannel({
    required String channelId,
    required String userId,
    MemberRole role = MemberRole.member,
  }) async {
    final memberId = 'member_${_members.length}';
    _members[memberId] = ChannelMember(
      memberId: memberId,
      channelId: channelId,
      userId: userId,
      role: role,
      joinedAt: DateTime.now(),
    );

    final channel = _channels[channelId];
    if (channel != null) {
      final updatedMembers = [...channel.memberIds];
      if (!updatedMembers.contains(userId)) {
        updatedMembers.add(userId);
      }
      _channels[channelId] = channel.copyWith(
        memberIds: updatedMembers,
        memberCount: updatedMembers.length,
      );
    }

    return memberId;
  }

  @override
  Future<ChannelMember?> getChannelMember(String channelId, String userId) async {
    return _members.values.firstWhere(
      (m) => m.channelId == channelId && m.userId == userId,
      orElse: () => ChannelMember.empty(),
    ) as ChannelMember?;
  }

  @override
  Future<List<ChannelMember>> getChannelMembers(
    String channelId, {
    int limit = 50,
  }) async {
    return _members.values
        .where((m) => m.channelId == channelId && !m.isBanned)
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<ChannelMember>> getChannelModerators(String channelId) async {
    return _members.values
        .where((m) =>
            m.channelId == channelId &&
            (m.isOwner || m.isModerator))
        .toList();
  }

  @override
  Future<void> updateMemberRole({
    required String channelId,
    required String userId,
    required MemberRole newRole,
  }) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      _members[member.memberId] = member.copyWith(role: newRole);
    }
  }

  @override
  Future<void> removeMemberFromChannel(String channelId, String userId) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      _members.remove(member.memberId);

      final channel = _channels[channelId];
      if (channel != null) {
        final updatedMembers =
            channel.memberIds.where((id) => id != userId).toList();
        _channels[channelId] = channel.copyWith(
          memberIds: updatedMembers,
          memberCount: updatedMembers.length,
        );
      }
    }
  }

  @override
  Future<void> muteChannelMember({
    required String channelId,
    required String userId,
  }) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      _members[member.memberId] = member.copyWith(isMuted: true);
    }
  }

  @override
  Future<void> unmuteChannelMember({
    required String channelId,
    required String userId,
  }) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      _members[member.memberId] = member.copyWith(isMuted: false);
    }
  }

  @override
  Future<void> banChannelMember({
    required String channelId,
    required String userId,
    String? reason,
  }) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      _members[member.memberId] =
          member.copyWith(isBanned: true, banReason: reason);
    }
  }

  @override
  Future<void> unbanChannelMember(String channelId, String userId) async {
    final member = await getChannelMember(channelId, userId);
    if (member != null) {
      _members[member.memberId] = member.copyWith(isBanned: false);
    }
  }

  @override
  Future<String> createPost({
    required String channelId,
    required String authorId,
    String? authorName,
    required String content,
    String? mediaUrl,
    List<String> tags = const [],
  }) async {
    final postId = 'post_${_posts.length}';
    _posts[postId] = ChannelPost(
      postId: postId,
      channelId: channelId,
      authorId: authorId,
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
      mediaUrl: mediaUrl,
      tags: tags,
    );

    await updateChannelStats(channelId);
    return postId;
  }

  @override
  Future<ChannelPost?> getPost(String postId) async {
    return _posts[postId];
  }

  @override
  Future<List<ChannelPost>> getChannelPosts(
    String channelId, {
    PostStatus? statusFilter,
    int limit = 50,
  }) async {
    var filtered = _posts.values.where((p) => p.channelId == channelId).toList();

    if (statusFilter != null) {
      filtered = filtered.where((p) => p.status == statusFilter).toList();
    }

    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered.take(limit).toList();
  }

  @override
  Future<List<ChannelPost>> getPinnedPosts(String channelId) async {
    return _posts.values
        .where((p) => p.channelId == channelId && p.isPinned)
        .toList();
  }

  @override
  Future<void> updatePost({
    required String postId,
    required String content,
  }) async {
    final post = _posts[postId];
    if (post != null) {
      _posts[postId] = post.copyWith(updatedAt: DateTime.now());
    }
  }

  @override
  Future<void> publishPost(String postId) async {
    final post = _posts[postId];
    if (post != null) {
      _posts[postId] = post.copyWith(status: PostStatus.published);
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    final post = _posts[postId];
    if (post != null) {
      _posts[postId] = post.copyWith(status: PostStatus.archived);
    }
  }

  @override
  Future<void> pinPost({
    required String postId,
    required int position,
  }) async {
    final post = _posts[postId];
    if (post != null) {
      _posts[postId] =
          post.copyWith(isPinned: true, pinPosition: position);
    }
  }

  @override
  Future<void> unpinPost(String postId) async {
    final post = _posts[postId];
    if (post != null) {
      _posts[postId] = post.copyWith(isPinned: false);
    }
  }

  @override
  Future<void> incrementPostViews(String postId) async {
    final post = _posts[postId];
    if (post != null) {
      _posts[postId] = post.copyWith(views: post.views + 1);
    }
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    final post = _posts[postId];
    if (post != null) {
      final updatedLikedBy = [...post.likedBy];
      if (!updatedLikedBy.contains(userId)) {
        updatedLikedBy.add(userId);
      }
      _posts[postId] = post.copyWith(
        likes: post.likes + 1,
        likedBy: updatedLikedBy,
      );
    }
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    final post = _posts[postId];
    if (post != null) {
      final updatedLikedBy = post.likedBy.where((id) => id != userId).toList();
      _posts[postId] = post.copyWith(
        likes: post.likes - 1,
        likedBy: updatedLikedBy,
      );
    }
  }

  @override
  Future<String> createReply({
    required String postId,
    required String channelId,
    required String authorId,
    String? authorName,
    required String content,
    String? mediaUrl,
  }) async {
    final replyId = 'reply_${_replies.length}';
    _replies[replyId] = PostReply(
      replyId: replyId,
      postId: postId,
      channelId: channelId,
      authorId: authorId,
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
      mediaUrl: mediaUrl,
    );

    final post = _posts[postId];
    if (post != null) {
      _posts[postId] = post.copyWith(replies: post.replies + 1);
    }

    return replyId;
  }

  @override
  Future<PostReply?> getReply(String replyId) async {
    return _replies[replyId];
  }

  @override
  Future<List<PostReply>> getPostReplies(
    String postId, {
    int limit = 50,
  }) async {
    return _replies.values
        .where((r) => r.postId == postId)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  @override
  Future<void> updateReply({
    required String replyId,
    required String content,
  }) async {
    final reply = _replies[replyId];
    if (reply != null) {
      _replies[replyId] = reply.copyWith(updatedAt: DateTime.now());
    }
  }

  @override
  Future<void> deleteReply(String replyId) async {
    final reply = _replies[replyId];
    if (reply != null) {
      _replies.remove(replyId);

      final post = _posts[reply.postId];
      if (post != null) {
        _posts[reply.postId] = post.copyWith(replies: post.replies - 1);
      }
    }
  }

  @override
  Future<void> likeReply(String replyId, String userId) async {
    final reply = _replies[replyId];
    if (reply != null) {
      final updatedLikedBy = [...reply.likedBy];
      if (!updatedLikedBy.contains(userId)) {
        updatedLikedBy.add(userId);
      }
      _replies[replyId] = reply.copyWith(
        likes: reply.likes + 1,
        likedBy: updatedLikedBy,
      );
    }
  }

  @override
  Future<void> unlikeReply(String replyId, String userId) async {
    final reply = _replies[replyId];
    if (reply != null) {
      final updatedLikedBy = reply.likedBy.where((id) => id != userId).toList();
      _replies[replyId] = reply.copyWith(
        likes: reply.likes - 1,
        likedBy: updatedLikedBy,
      );
    }
  }

  @override
  Future<String> createModerationRecord({
    required String channelId,
    required String targetUserId,
    required String actionBy,
    required ModerationAction action,
    String? reason,
    DateTime? expiresAt,
  }) async {
    final recordId = 'record_${_records.length}';
    _records[recordId] = ModerationRecord(
      recordId: recordId,
      channelId: channelId,
      targetUserId: targetUserId,
      actionBy: actionBy,
      action: action,
      reason: reason,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
    );
    return recordId;
  }

  @override
  Future<ModerationRecord?> getModerationRecord(String recordId) async {
    return _records[recordId];
  }

  @override
  Future<List<ModerationRecord>> getChannelModerationRecords(
    String channelId, {
    int limit = 50,
  }) async {
    return _records.values
        .where((r) => r.channelId == channelId)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  @override
  Future<List<ModerationRecord>> getUserModerationRecords(
    String userId, {
    int limit = 50,
  }) async {
    return _records.values
        .where((r) => r.targetUserId == userId)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  @override
  Future<void> closeModerationRecord(String recordId) async {
    final record = _records[recordId];
    if (record != null) {
      _records[recordId] = record.copyWith(isActive: false);
    }
  }

  @override
  Future<void> updateChannelStats(String channelId) async {
    final postCount = await getChannelPostsCount(channelId);
    final memberCount = await getChannelMembersCount(channelId);

    final statsKey = _stats.keys.firstWhere(
      (k) => _stats[k]!.channelId == channelId,
      orElse: () => 'stats_$channelId',
    );

    _stats[statsKey] = ChannelStats(
      statsId: statsKey,
      channelId: channelId,
      totalMembers: memberCount,
      totalPosts: postCount,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<ChannelStats?> getChannelStats(String channelId) async {
    final statsKey = _stats.keys.firstWhere(
      (k) => _stats[k]!.channelId == channelId,
      orElse: () => '',
    );
    return statsKey.isEmpty ? null : _stats[statsKey];
  }

  @override
  Future<int> getTotalChannelsCount() async {
    return _channels.values.where((ch) => !ch.isArchived).length;
  }

  @override
  Future<int> getChannelMembersCount(String channelId) async {
    return _members.values
        .where((m) => m.channelId == channelId && !m.isBanned)
        .length;
  }

  @override
  Future<int> getChannelPostsCount(String channelId) async {
    return _posts.values
        .where((p) => p.channelId == channelId && p.isPublished)
        .length;
  }

  @override
  Future<List<ChannelPost>> searchPosts({
    required String channelId,
    required String query,
    int limit = 50,
  }) async {
    return _posts.values
        .where((p) =>
            p.channelId == channelId &&
            p.isPublished &&
            p.content.toLowerCase().contains(query.toLowerCase()))
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<PostReply>> searchReplies({
    required String query,
    int limit = 50,
  }) async {
    return _replies.values
        .where((r) => r.content.toLowerCase().contains(query.toLowerCase()))
        .toList()
        .take(limit)
        .toList();
  }

  // ============ MENTION OPERATIONS (Phase 11 Step 2) ============

  @override
  Future<List<Mention>> extractMentions(
    String content, {
    required String channelId,
  }) async {
    final regex = RegExp(r'@(\w+)');
    final matches = regex.allMatches(content);
    final mentions = <Mention>[];
    final seenUsernames = <String>{};

    for (final match in matches) {
      final username = match.group(1)!.toLowerCase();
      if (seenUsernames.add(username)) {
        // Check if user is a channel member
        final isMember = _members.values.any((m) =>
            m.channelId == channelId &&
            m.userId == username);
        if (isMember) {
          mentions.add(
            Mention(
              mentionId: 'mention_${_mentions.length}',
              mentionedUserId: username,
              mentionedUsername: username,
              channelId: channelId,
              authorId: '', // Will be set during create
              mentionedAt: DateTime.now(),
            ),
          );
        }
      }
    }
    return mentions;
  }

  @override
  Future<String> createMention({
    required String mentionedUserId,
    required String mentionedUsername,
    required String channelId,
    required String authorId,
    String? authorName,
    String? postId,
    String? replyId,
    String? notificationId,
  }) async {
    final mentionId = 'mention_${_mentions.length}';
    _mentions[mentionId] = Mention(
      mentionId: mentionId,
      mentionedUserId: mentionedUserId,
      mentionedUsername: mentionedUsername,
      postId: postId,
      replyId: replyId,
      channelId: channelId,
      authorId: authorId,
      authorName: authorName,
      mentionedAt: DateTime.now(),
      notificationId: notificationId,
    );
    return mentionId;
  }

  @override
  Future<List<Mention>> getPostMentions(String postId) async {
    return _mentions.values
        .where((m) => m.postId == postId && m.replyId == null)
        .toList();
  }

  @override
  Future<List<Mention>> getReplyMentions(String replyId) async {
    return _mentions.values
        .where((m) => m.replyId == replyId)
        .toList();
  }

  @override
  Future<List<Mention>> getUserMentions(
    String userId, {
    int limit = 50,
  }) async {
    return _mentions.values
        .where((m) => m.mentionedUserId == userId)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  @override
  Future<List<Mention>> getChannelMentions(
    String channelId, {
    int limit = 50,
  }) async {
    return _mentions.values
        .where((m) => m.channelId == channelId)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  @override
  Future<int> getMentionCount(String userId) async {
    return _mentions.values
        .where((m) => m.mentionedUserId == userId)
        .length;
  }

  @override
  Future<bool> validateMention(
    String username, {
    required String channelId,
  }) async {
    return _members.values.any((m) =>
        m.channelId == channelId &&
        m.userId == username &&
        !m.isBanned);
  }

  @override
  Future<List<ChannelMember>> getMentionableCommunityUsers(
    String channelId,
  ) async {
    return _members.values
        .where((m) => m.channelId == channelId && !m.isBanned)
        .toList();
  }

  // ============ NOTIFICATION OPERATIONS (Phase 11 Step 2) ============

  @override
  Future<List<UserNotification>> getUserNotifications(
    String userId, {
    bool unreadOnly = false,
    int limit = 50,
    int offset = 0,
  }) async {
    var results = _notifications.values
        .where((n) => n.userId == userId)
        .toList();

    if (unreadOnly) {
      results = results.where((n) => n.isUnread).toList();
    }

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return results
        .skip(offset)
        .take(limit)
        .toList();
  }

  @override
  Future<UserNotification?> getNotification(String notificationId) async {
    return _notifications[notificationId];
  }

  @override
  Future<String> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String description,
    required String relatedId,
    required String relatedType,
    String? channelId,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) async {
    // Check if user has notifications enabled
    final prefs = await getUserNotificationPreferences(userId);
    final prefsToUse = prefs ?? NotificationPreferences.empty(userId);

    // Check if user is muted
    if (prefsToUse.isCurrentlyMuted) {
      return '';
    }

    // Check type-specific preferences
    bool shouldCreate = false;
    switch (type) {
      case NotificationType.mention:
        shouldCreate = prefsToUse.mentionNotifications;
        break;
      case NotificationType.reply:
        shouldCreate = prefsToUse.replyNotifications;
        break;
      case NotificationType.likePost:
      case NotificationType.likeReply:
        shouldCreate = prefsToUse.likeNotifications;
        break;
      case NotificationType.moderation:
        shouldCreate = prefsToUse.moderationNotifications;
        break;
      case NotificationType.channelEvent:
      case NotificationType.channelAnnounce:
        shouldCreate = prefsToUse.channelAnnouncements;
        break;
    }

    if (!shouldCreate) {
      return '';
    }

    // Prevent duplicates
    final exists = _notifications.values.any((n) =>
        n.userId == userId &&
        n.type == type &&
        n.relatedId == relatedId &&
        n.isUnread);

    if (exists) {
      return '';
    }

    final notificationId = 'notif_${_notifications.length}';
    _notifications[notificationId] = UserNotification(
      notificationId: notificationId,
      userId: userId,
      type: type,
      title: title,
      description: description,
      relatedId: relatedId,
      relatedType: relatedType,
      channelId: channelId,
      isRead: false,
      createdAt: DateTime.now(),
      actionUrl: actionUrl,
      metadata: metadata,
    );

    return notificationId;
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    final notification = _notifications[notificationId];
    if (notification != null) {
      _notifications[notificationId] = notification.copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
    for (final entry in _notifications.entries) {
      if (entry.value.userId == userId) {
        _notifications[entry.key] = entry.value.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }
    }
  }

  @override
  Future<void> markPostNotificationsAsRead({
    required String userId,
    required String postId,
  }) async {
    for (final entry in _notifications.entries) {
      if (entry.value.userId == userId &&
          entry.value.relatedId == postId) {
        _notifications[entry.key] = entry.value.copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    _notifications.remove(notificationId);
  }

  @override
  Future<void> deleteUserNotifications(String userId) async {
    _notifications.removeWhere((_, n) => n.userId == userId);
  }

  @override
  Future<void> archiveOldNotifications({
    int olderThanDays = 30,
  }) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
    final toRemove = _notifications.entries
        .where((e) =>
            e.value.isRead &&
            e.value.createdAt.isBefore(cutoffDate))
        .map((e) => e.key)
        .toList();

    for (final id in toRemove) {
      _notifications.remove(id);
    }
  }

  @override
  Future<void> clearReadNotifications(String userId) async {
    _notifications.removeWhere((_, n) =>
        n.userId == userId && n.isRead);
  }

  @override
  Future<Map<String, int>> getNotificationSummary(String userId) async {
    final userNotifs = _notifications.values
        .where((n) => n.userId == userId)
        .toList();

    return {
      'mentions': userNotifs
          .where((n) => n.type == NotificationType.mention)
          .length,
      'replies': userNotifs
          .where((n) => n.type == NotificationType.reply)
          .length,
      'likes': userNotifs
          .where((n) =>
              n.type == NotificationType.likePost ||
              n.type == NotificationType.likeReply)
          .length,
      'moderation': userNotifs
          .where((n) => n.type == NotificationType.moderation)
          .length,
      'total': userNotifs.length,
      'unread': userNotifs.where((n) => n.isUnread).length,
    };
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return _notifications.values
        .where((n) => n.userId == userId && n.isUnread)
        .length;
  }

  // ============ NOTIFICATION PREFERENCE OPERATIONS (Phase 11 Step 2) ============

  @override
  Future<NotificationPreferences?> getUserNotificationPreferences(
    String userId,
  ) async {
    return _preferences[userId];
  }

  @override
  Future<void> updateNotificationPreferences(
    String userId,
    NotificationPreferences preferences,
  ) async {
    _preferences[userId] = preferences;
  }

  @override
  Future<List<String>> getUsersWithNotificationsEnabled(
    String channelId,
  ) async {
    final channelMembers = _members.values
        .where((m) => m.channelId == channelId && !m.isBanned)
        .map((m) => m.userId)
        .toSet();

    final enabledUsers = <String>[];
    for (final userId in channelMembers) {
      final prefs = await getUserNotificationPreferences(userId);
      if (prefs == null || prefs.hasAnyNotificationsEnabled) {
        enabledUsers.add(userId);
      }
    }

    return enabledUsers;
  }

  @override
  Future<void> muteUserNotifications(
    String userId, {
    required Duration duration,
  }) async {
    final prefs = await getUserNotificationPreferences(userId) ??
        NotificationPreferences.empty(userId);

    final muteUntil = DateTime.now().add(duration);
    _preferences[userId] = prefs.copyWith(
      muteUntil: muteUntil,
    );
  }

  @override
  Future<void> unmuteUserNotifications(String userId) async {
    final prefs = await getUserNotificationPreferences(userId);
    if (prefs != null) {
      _preferences[userId] = prefs.copyWith(
        muteUntil: null,
      );
    }
  }

  // ============ REACTION OPERATIONS (Phase 11 Step 3) ============

  @override
  Future<String> addPostReaction({
    required String postId,
    required String userId,
    required String emoji,
    ReactionType reactionType = ReactionType.emoji,
  }) async {
    final reactionId = 'reaction_${_postReactions.length}';
    _postReactions[reactionId] = PostReaction(
      reactionId: reactionId,
      postId: postId,
      userId: userId,
      channelId: '', // Would be populated from post
      emoji: emoji,
      reactionType: reactionType,
      createdAt: DateTime.now(),
    );
    return reactionId;
  }

  @override
  Future<String> addReplyReaction({
    required String replyId,
    required String postId,
    required String userId,
    required String emoji,
    ReactionType reactionType = ReactionType.emoji,
  }) async {
    final reactionId = 'reaction_${_replyReactions.length}';
    _replyReactions[reactionId] = ReplyReaction(
      reactionId: reactionId,
      replyId: replyId,
      postId: postId,
      userId: userId,
      emoji: emoji,
      reactionType: reactionType,
      createdAt: DateTime.now(),
    );
    return reactionId;
  }

  @override
  Future<void> removePostReaction(String postId, String userId, String emoji) async {
    _postReactions.removeWhere((_, r) =>
        r.postId == postId && r.userId == userId && r.emoji == emoji);
  }

  @override
  Future<void> removeReplyReaction(String replyId, String userId, String emoji) async {
    _replyReactions.removeWhere((_, r) =>
        r.replyId == replyId && r.userId == userId && r.emoji == emoji);
  }

  @override
  Future<List<PostReaction>> getPostReactions(String postId) async {
    return _postReactions.values.where((r) => r.postId == postId).toList();
  }

  @override
  Future<List<ReplyReaction>> getReplyReactions(String replyId) async {
    return _replyReactions.values.where((r) => r.replyId == replyId).toList();
  }

  @override
  Future<List<String>> getReactionUsers(String postId, String emoji) async {
    return _postReactions.values
        .where((r) => r.postId == postId && r.emoji == emoji)
        .map((r) => r.userId)
        .toList();
  }

  @override
  Future<int> getReactionCount(String postId) async {
    return _postReactions.values.where((r) => r.postId == postId).length;
  }

  @override
  Future<PostReaction?> getUserPostReaction(
    String postId,
    String userId,
    String emoji,
  ) async {
    try {
      return _postReactions.values.firstWhere((r) =>
          r.postId == postId && r.userId == userId && r.emoji == emoji);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ReplyReaction?> getUserReplyReaction(
    String replyId,
    String userId,
    String emoji,
  ) async {
    try {
      return _replyReactions.values.firstWhere((r) =>
          r.replyId == replyId && r.userId == userId && r.emoji == emoji);
    } catch (e) {
      return null;
    }
  }

  // ============ REPORT OPERATIONS (Phase 11 Step 3) ============

  @override
  Future<String> reportPost({
    required String postId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
    String? attachmentUrl,
  }) async {
    final post = await getPost(postId);
    final reportId = 'report_${_reports.length}';
    _reports[reportId] = ContentReport(
      reportId: reportId,
      contentId: postId,
      contentType: 'post',
      reportedByUserId: reportedByUserId,
      channelId: post?.channelId ?? '',
      category: category,
      description: description,
      attachmentUrl: attachmentUrl,
      createdAt: DateTime.now(),
    );
    return reportId;
  }

  @override
  Future<String> reportReply({
    required String replyId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
    String? attachmentUrl,
  }) async {
    final reply = await getReply(replyId);
    final reportId = 'report_${_reports.length}';
    _reports[reportId] = ContentReport(
      reportId: reportId,
      contentId: replyId,
      contentType: 'reply',
      reportedByUserId: reportedByUserId,
      channelId: reply?.channelId ?? '',
      category: category,
      description: description,
      attachmentUrl: attachmentUrl,
      createdAt: DateTime.now(),
    );
    return reportId;
  }

  @override
  Future<String> reportUser({
    required String reportedUserId,
    required String reportedByUserId,
    required ReportCategory category,
    String? description,
  }) async {
    final reportId = 'report_${_reports.length}';
    _reports[reportId] = ContentReport(
      reportId: reportId,
      contentId: reportedUserId,
      contentType: 'user',
      reportedByUserId: reportedByUserId,
      reportedUserId: reportedUserId,
      channelId: '', // N/A for user reports
      category: category,
      description: description,
      createdAt: DateTime.now(),
    );
    return reportId;
  }

  @override
  Future<ContentReport?> getReport(String reportId) async {
    return _reports[reportId];
  }

  @override
  Future<List<ContentReport>> getChannelReports(
    String channelId, {
    ReportStatus? statusFilter,
    int limit = 50,
  }) async {
    var results = _reports.values
        .where((r) => r.channelId == channelId)
        .toList();

    if (statusFilter != null) {
      results = results.where((r) => r.status == statusFilter).toList();
    }

    return results.take(limit).toList();
  }

  @override
  Future<List<ContentReport>> getUserReports(
    String reportedUserId, {
    int limit = 50,
  }) async {
    return _reports.values
        .where((r) => r.reportedUserId == reportedUserId)
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<ContentReport>> getReportedContentReports(
    String contentId, {
    int limit = 50,
  }) async {
    return _reports.values
        .where((r) => r.contentId == contentId)
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<void> actionReport({
    required String reportId,
    required ReportAction action,
    required String moderatorId,
    String? reason,
    String? actionDetails,
  }) async {
    final report = _reports[reportId];
    if (report != null) {
      _reports[reportId] = report.copyWith(
        status: ReportStatus.upheld,
        reviewedAt: DateTime.now(),
        reviewedBy: moderatorId,
        action: action,
        actionReason: reason,
        actionDetails: actionDetails,
      );
    }
  }

  @override
  Future<void> dismissReport({
    required String reportId,
    required String moderatorId,
    String? reason,
  }) async {
    final report = _reports[reportId];
    if (report != null) {
      _reports[reportId] = report.copyWith(
        status: ReportStatus.dismissed,
        reviewedAt: DateTime.now(),
        reviewedBy: moderatorId,
        actionReason: reason,
      );
    }
  }

  @override
  Future<Map<String, int>> getReportStats(String channelId) async {
    final channelReports = _reports.values
        .where((r) => r.channelId == channelId)
        .toList();

    return {
      'total': channelReports.length,
      'pending': channelReports.where((r) => r.isPending).length,
      'upheld': channelReports.where((r) => r.isUpheld).length,
      'dismissed': channelReports.where((r) => r.isDismissed).length,
    };
  }

  // ============ TRENDING OPERATIONS (Phase 11 Step 3) ============

  @override
  Future<List<ChannelPost>> getTrendingPosts(
    String channelId, {
    String timeRange = 'day',
    int limit = 20,
  }) async {
    final posts = await getChannelPosts(channelId, statusFilter: PostStatus.published);

    // Score posts by engagement
    final scored = <(ChannelPost, double)>[];
    for (final post in posts) {
      final score = await calculateTrendingScore(post.postId);
      scored.add((post, score));
    }

    // Sort by score descending
    scored.sort((a, b) => b.$2.compareTo(a.$2));

    return scored.map((s) => s.$1).take(limit).toList();
  }

  @override
  Future<List<ChannelPost>> getGlobalTrendingPosts({
    String timeRange = 'week',
    int limit = 50,
  }) async {
    final allPosts = _posts.values
        .where((p) => p.isPublished)
        .toList();

    final scored = <(ChannelPost, double)>[];
    for (final post in allPosts) {
      final score = await calculateTrendingScore(post.postId);
      scored.add((post, score));
    }

    scored.sort((a, b) => b.$2.compareTo(a.$2));

    return scored.map((s) => s.$1).take(limit).toList();
  }

  @override
  Future<List<ChannelPost>> getTrendingByCategory(
    String category, {
    String timeRange = 'week',
    int limit = 20,
  }) async {
    final channels = _channels.values
        .where((ch) => ch.category == category)
        .map((ch) => ch.channelId)
        .toSet();

    final posts = _posts.values
        .where((p) => channels.contains(p.channelId) && p.isPublished)
        .toList();

    final scored = <(ChannelPost, double)>[];
    for (final post in posts) {
      final score = await calculateTrendingScore(post.postId);
      scored.add((post, score));
    }

    scored.sort((a, b) => b.$2.compareTo(a.$2));

    return scored.map((s) => s.$1).take(limit).toList();
  }

  @override
  Future<List<String>> getTrendingTags(
    String channelId, {
    int limit = 10,
  }) async {
    final posts = await getChannelPosts(channelId);

    final tagCounts = <String, int>{};
    for (final post in posts) {
      for (final tag in post.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    final sorted = tagCounts.entries.toList();
    sorted.sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((e) => e.key).take(limit).toList();
  }

  @override
  Future<double> calculateTrendingScore(String postId) async {
    final post = await getPost(postId);
    if (post == null) return 0.0;

    // Get engagement metrics
    final reactionCount = await getReactionCount(postId);
    final likeCount = post.likes;
    final replyCount = post.replies;
    final viewCount = post.views;

    // Calculate score: weighted sum of engagement
    // Reactions: 2x, Replies: 3x, Likes: 1x, Views: 0.1x
    final engagementScore = (reactionCount * 2) +
        (replyCount * 3) +
        (likeCount * 1) +
        (viewCount * 0.1);

    // Time decay: newer posts score higher
    final ageHours = DateTime.now().difference(post.createdAt).inHours;
    final timeDecay = 1.0 / (1.0 + (ageHours / 24.0));

    final score = engagementScore * timeDecay;

    // Store analytics
    await updateEngagementAnalytics(postId);

    return score;
  }

  @override
  Future<PostEngagementAnalytics?> getPostEngagementAnalytics(
    String postId,
  ) async {
    try {
      return _analytics.values.firstWhere((a) => a.postId == postId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateEngagementAnalytics(String postId) async {
    final post = await getPost(postId);
    if (post == null) return;

    final analyticsId = 'analytics_$postId';
    final reactionCount = await getReactionCount(postId);
    final trendingScore = await calculateTrendingScore(postId);

    _analytics[analyticsId] = PostEngagementAnalytics(
      analyticsId: analyticsId,
      postId: postId,
      channelId: post.channelId,
      reactionCount: reactionCount,
      replyCount: post.replies,
      likeCount: post.likes,
      viewCount: post.views,
      trendingScore: trendingScore,
      lastUpdatedAt: DateTime.now(),
    );
  }

  // Phase 11 Step 4: Channel Access Control & Invitations

  final Map<String, ChannelInvitation> _invitations = {};
  final Map<String, AccessRequest> _accessRequests = {};
  final Map<String, ChannelMember> _members = {};
  final Map<String, AccessHistoryEntry> _accessHistory = {};

  @override
  Future<String> createInvitation({
    required String channelId,
    required String invitedUserId,
    required String invitedByUserId,
    required String inviterName,
    String role = 'member',
    String? message,
  }) async {
    final invitationId = 'inv_${DateTime.now().millisecondsSinceEpoch}';
    final invitationCode = _generateInvitationCode();

    final invitation = ChannelInvitation(
      invitationId: invitationId,
      channelId: channelId,
      invitedUserId: invitedUserId,
      invitedByUserId: invitedByUserId,
      inviterName: inviterName,
      role: role,
      message: message,
      status: 'pending',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: 14)),
      invitationCode: invitationCode,
    );

    _invitations[invitationId] = invitation;
    return invitationId;
  }

  @override
  Future<List<String>> inviteMultipleUsers({
    required String channelId,
    required List<String> invitedUserIds,
    required String invitedByUserId,
    required String inviterName,
    String role = 'member',
  }) async {
    final invitationIds = <String>[];

    for (final userId in invitedUserIds) {
      final id = await createInvitation(
        channelId: channelId,
        invitedUserId: userId,
        invitedByUserId: invitedByUserId,
        inviterName: inviterName,
        role: role,
      );
      invitationIds.add(id);
    }

    return invitationIds;
  }

  @override
  Future<ChannelInvitation?> getInvitation(String invitationId) async {
    return _invitations[invitationId];
  }

  @override
  Future<List<ChannelInvitation>> getUserInvitations(
    String userId, {
    bool includeExpired = false,
    int limit = 20,
  }) async {
    final invitations = _invitations.values
        .where((inv) =>
            inv.invitedUserId == userId &&
            (includeExpired || inv.isActive) &&
            inv.status == 'pending')
        .take(limit)
        .toList();

    return invitations;
  }

  @override
  Future<List<ChannelInvitation>> getChannelInvitations(
    String channelId, {
    String? status,
    int limit = 20,
  }) async {
    var invitations = _invitations.values.where((inv) => inv.channelId == channelId);

    if (status != null) {
      invitations = invitations.where((inv) => inv.status == status);
    }

    return invitations.take(limit).toList();
  }

  @override
  Future<void> acceptInvitation(String invitationId, String userId) async {
    final invitation = _invitations[invitationId];
    if (invitation == null) return;

    // Add user as member
    final memberId = 'member_${DateTime.now().millisecondsSinceEpoch}';
    _members[memberId] = ChannelMember(
      memberId: memberId,
      channelId: invitation.channelId,
      userId: userId,
      userName: invitation.inviterName,
      role: invitation.role,
      joinedAt: DateTime.now(),
      invitedAt: invitation.createdAt,
      invitedByUserId: invitation.invitedByUserId,
      status: 'active',
    );

    // Update invitation
    _invitations[invitationId] = invitation.copyWith(
      status: 'accepted',
      respondedAt: DateTime.now(),
    );

    // Add to history
    _addAccessHistoryEntry(
      invitation.channelId,
      userId,
      'system',
      'joined',
      invitation.role,
      'Accepted invitation',
    );
  }

  @override
  Future<void> declineInvitation(String invitationId, String userId) async {
    final invitation = _invitations[invitationId];
    if (invitation == null) return;

    _invitations[invitationId] = invitation.copyWith(
      status: 'declined',
      respondedAt: DateTime.now(),
    );
  }

  @override
  Future<void> cancelInvitation(String invitationId, String cancelledByUserId) async {
    final invitation = _invitations[invitationId];
    if (invitation == null) return;

    _invitations[invitationId] = invitation.copyWith(status: 'cancelled');
  }

  @override
  Future<String> createAccessRequest({
    required String channelId,
    required String requestedByUserId,
    required String requesterName,
    String? reason,
  }) async {
    final requestId = 'req_${DateTime.now().millisecondsSinceEpoch}';

    final request = AccessRequest(
      requestId: requestId,
      channelId: channelId,
      requestedByUserId: requestedByUserId,
      requesterName: requesterName,
      reason: reason,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    _accessRequests[requestId] = request;
    return requestId;
  }

  @override
  Future<AccessRequest?> getAccessRequest(String requestId) async {
    return _accessRequests[requestId];
  }

  @override
  Future<List<AccessRequest>> getChannelAccessRequests(
    String channelId, {
    String? status,
    int limit = 20,
  }) async {
    var requests = _accessRequests.values.where((req) => req.channelId == channelId);

    if (status != null) {
      requests = requests.where((req) => req.status == status);
    }

    return requests.take(limit).toList();
  }

  @override
  Future<List<AccessRequest>> getUserAccessRequests(
    String userId, {
    String? status,
    int limit = 10,
  }) async {
    var requests = _accessRequests.values.where((req) => req.requestedByUserId == userId);

    if (status != null) {
      requests = requests.where((req) => req.status == status);
    }

    return requests.take(limit).toList();
  }

  @override
  Future<void> approveAccessRequest(
    String requestId,
    String approvedByUserId, {
    String role = 'member',
  }) async {
    final request = _accessRequests[requestId];
    if (request == null) return;

    // Add user as member
    final memberId = 'member_${DateTime.now().millisecondsSinceEpoch}';
    _members[memberId] = ChannelMember(
      memberId: memberId,
      channelId: request.channelId,
      userId: request.requestedByUserId,
      userName: request.requesterName,
      role: role,
      joinedAt: DateTime.now(),
      status: 'active',
    );

    // Update request
    _accessRequests[requestId] = request.copyWith(
      status: 'approved',
      respondedAt: DateTime.now(),
      respondedByUserId: approvedByUserId,
      approvedRole: role,
    );

    // Add to history
    _addAccessHistoryEntry(
      request.channelId,
      request.requestedByUserId,
      approvedByUserId,
      'joined',
      role,
      'Access request approved',
    );
  }

  @override
  Future<void> rejectAccessRequest(
    String requestId,
    String rejectedByUserId, {
    String? reason,
  }) async {
    final request = _accessRequests[requestId];
    if (request == null) return;

    _accessRequests[requestId] = request.copyWith(
      status: 'rejected',
      respondedAt: DateTime.now(),
      respondedByUserId: rejectedByUserId,
      rejectionReason: reason,
    );
  }

  @override
  Future<void> cancelAccessRequest(String requestId, String cancelledByUserId) async {
    final request = _accessRequests[requestId];
    if (request == null) return;

    _accessRequests[requestId] = request.copyWith(status: 'cancelled');
  }

  @override
  Future<List<ChannelMember>> getChannelMembers(
    String channelId, {
    String? role,
    int limit = 50,
  }) async {
    var members = _members.values.where((m) => m.channelId == channelId);

    if (role != null) {
      members = members.where((m) => m.role == role);
    }

    return members.take(limit).toList();
  }

  @override
  Future<ChannelMember?> getChannelMember(String channelId, String userId) async {
    try {
      return _members.values.firstWhere(
        (m) => m.channelId == channelId && m.userId == userId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateMemberRole(
    String channelId,
    String userId,
    String newRole,
    String updatedByUserId,
  ) async {
    try {
      final member = _members.values.firstWhere(
        (m) => m.channelId == channelId && m.userId == userId,
      );

      final oldRole = member.role;

      // Update member
      for (final entry in _members.entries) {
        if (entry.value.channelId == channelId && entry.value.userId == userId) {
          _members[entry.key] = member.copyWith(role: newRole);
          break;
        }
      }

      // Add to history
      _addAccessHistoryEntry(
        channelId,
        userId,
        updatedByUserId,
        'promoted',
        newRole,
        'Role updated',
        oldRole: oldRole,
      );
    } catch (e) {
      // Member not found
    }
  }

  @override
  Future<void> removeMember(
    String channelId,
    String userId,
    String removedByUserId,
  ) async {
    final toRemove = _members.entries
        .where((e) => e.value.channelId == channelId && e.value.userId == userId)
        .toList();

    for (final entry in toRemove) {
      _members.remove(entry.key);
    }

    // Add to history
    _addAccessHistoryEntry(
      channelId,
      userId,
      removedByUserId,
      'removed',
    );
  }

  @override
  Future<void> leaveChannel(String channelId, String userId) async {
    final toRemove = _members.entries
        .where((e) => e.value.channelId == channelId && e.value.userId == userId)
        .toList();

    for (final entry in toRemove) {
      _members.remove(entry.key);
    }

    // Add to history
    _addAccessHistoryEntry(
      channelId,
      userId,
      userId,
      'left',
    );
  }

  @override
  Future<bool> isChannelMember(String channelId, String userId) async {
    return _members.values.any(
      (m) => m.channelId == channelId && m.userId == userId && m.isActive,
    );
  }

  @override
  Future<String?> getUserRoleInChannel(String channelId, String userId) async {
    try {
      final member = _members.values.firstWhere(
        (m) => m.channelId == channelId && m.userId == userId,
      );
      return member.role;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CommunityChannel>> getUserChannels(
    String userId, {
    String? role,
    int limit = 50,
  }) async {
    final userChannelIds = _members.values
        .where((m) => m.userId == userId && (role == null || m.role == role))
        .map((m) => m.channelId)
        .take(limit)
        .toSet();

    final channels = <CommunityChannel>[];
    for (final id in userChannelIds) {
      final channel = await getChannel(id);
      if (channel != null) {
        channels.add(channel);
      }
    }

    return channels;
  }

  @override
  Future<bool> canUserInvite(String channelId, String userId) async {
    final role = await getUserRoleInChannel(channelId, userId);
    return role == 'owner' || role == 'moderator';
  }

  @override
  Future<bool> canUserModerate(String channelId, String userId) async {
    final role = await getUserRoleInChannel(channelId, userId);
    return role == 'owner' || role == 'moderator';
  }

  @override
  Future<bool> canUserRemoveMembers(String channelId, String userId) async {
    final role = await getUserRoleInChannel(channelId, userId);
    return role == 'owner' || role == 'moderator';
  }

  @override
  Future<bool> hasPermission(
    String channelId,
    String userId,
    String permission,
  ) async {
    final role = await getUserRoleInChannel(channelId, userId);
    if (role == null) return false;

    switch (permission) {
      case 'post_content':
        return role != 'guest';
      case 'invite':
        return role == 'owner' || role == 'moderator';
      case 'moderate':
        return role == 'owner' || role == 'moderator';
      case 'manage_roles':
        return role == 'owner';
      default:
        return false;
    }
  }

  @override
  Future<List<AccessHistoryEntry>> getChannelAccessHistory(
    String channelId, {
    String? actionType,
    int limit = 50,
  }) async {
    var entries = _accessHistory.values.where((h) => h.channelId == channelId);

    if (actionType != null) {
      entries = entries.where((h) => h.action == actionType);
    }

    return entries.take(limit).toList();
  }

  @override
  Future<List<AccessHistoryEntry>> getUserAccessHistory(
    String userId, {
    int limit = 30,
  }) async {
    return _accessHistory.values
        .where((h) => h.userId == userId)
        .take(limit)
        .toList();
  }

  @override
  Future<AccessHistoryEntry?> getAccessHistoryEntry(String historyId) async {
    return _accessHistory[historyId];
  }

  void _addAccessHistoryEntry(
    String channelId,
    String userId,
    String actor,
    String action, [
    String? newRole,
    String? reason,
    String? oldRole,
  ]) {
    final historyId = 'hist_${DateTime.now().millisecondsSinceEpoch}';

    _accessHistory[historyId] = AccessHistoryEntry(
      historyId: historyId,
      channelId: channelId,
      userId: userId,
      actor: actor,
      action: action,
      oldRole: oldRole,
      newRole: newRole,
      reason: reason,
      createdAt: DateTime.now(),
    );
  }

  String _generateInvitationCode() {
    return 'inv_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 10000).toString().padLeft(4, '0')}';
  }

  // Phase 11 Step 5: Advanced Search & Content Discovery

  final Map<String, SearchQuery> _searchQueries = {};
  final Map<String, SavedSearch> _savedSearches = {};
  final Map<String, SearchSuggestion> _suggestions = {};

  @override
  Future<List<SearchResult>> searchPosts(
    String query, {
    String? channelId,
    String? authorId,
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    String sortBy = 'relevance',
    int limit = 20,
  }) async {
    var posts = _posts.values.toList();

    if (channelId != null) {
      posts = posts.where((p) => p.channelId == channelId).toList();
    }
    if (authorId != null) {
      posts = posts.where((p) => p.authorId == authorId).toList();
    }
    if (status != null) {
      posts = posts.where((p) => p.status.name == status).toList();
    }
    if (fromDate != null) {
      posts = posts.where((p) => p.createdAt.isAfter(fromDate)).toList();
    }
    if (toDate != null) {
      posts = posts.where((p) => p.createdAt.isBefore(toDate)).toList();
    }

    final results = <SearchResult>[];
    for (final post in posts) {
      final content = '${post.title} ${post.content}'.toLowerCase();
      final queryTerms = query.toLowerCase().split(' ');
      var relevance = 0.0;

      for (final term in queryTerms) {
        if (content.contains(term)) {
          relevance += 1.0;
        }
      }
      relevance = relevance / queryTerms.length;

      results.add(SearchResult(
        resultId: post.postId,
        query: query,
        contentType: 'post',
        contentId: post.postId,
        title: post.title,
        snippet: post.content.substring(0, min(150, post.content.length)),
        relevanceScore: relevance,
        author: post.authorName ?? '',
        authorId: post.authorId,
        channelId: post.channelId,
        tags: post.tags,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        replyCount: post.replies,
        reactionCount: post.likes,
        viewCount: post.views,
        url: '/post/${post.postId}',
      ));
    }

    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    return results.take(limit).toList();
  }

  @override
  Future<List<SearchResult>> searchPostsByDateRange({
    required String query,
    required DateTime fromDate,
    required DateTime toDate,
    int limit = 20,
  }) async {
    return searchPosts(query, fromDate: fromDate, toDate: toDate, limit: limit);
  }

  @override
  Future<List<SearchResult>> searchPostsByTags({
    required List<String> tags,
    int limit = 20,
  }) async {
    final results = <SearchResult>[];

    for (final post in _posts.values) {
      for (final tag in tags) {
        if (post.tags.contains(tag)) {
          results.add(SearchResult(
            resultId: post.postId,
            query: tags.join(','),
            contentType: 'post',
            contentId: post.postId,
            title: post.title,
            snippet: post.content.substring(0, min(150, post.content.length)),
            relevanceScore: 1.0,
            author: post.authorName ?? '',
            authorId: post.authorId,
            channelId: post.channelId,
            tags: post.tags,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            replyCount: post.replies,
            reactionCount: post.likes,
            viewCount: post.views,
            url: '/post/${post.postId}',
          ));
          break;
        }
      }
    }

    return results.take(limit).toList();
  }

  @override
  Future<SearchResult?> getSearchResult(String resultId) async {
    final post = await getPost(resultId);
    if (post == null) return null;

    return SearchResult(
      resultId: post.postId,
      query: '',
      contentType: 'post',
      contentId: post.postId,
      title: post.title,
      snippet: post.content.substring(0, min(150, post.content.length)),
      relevanceScore: 1.0,
      author: post.authorName ?? '',
      authorId: post.authorId,
      channelId: post.channelId,
      tags: post.tags,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
      replyCount: post.replies,
      reactionCount: post.likes,
      viewCount: post.views,
      url: '/post/${post.postId}',
    );
  }

  @override
  Future<List<CommunityChannel>> searchChannels(
    String query, {
    String? category,
    String sortBy = 'relevance',
    int limit = 20,
  }) async {
    var channels = _channels.values
        .where((c) => !c.isArchived && c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (category != null) {
      channels = channels.where((c) => c.category == category).toList();
    }

    return channels.take(limit).toList();
  }

  @override
  Future<List<CommunityChannel>> getPopularChannels({int limit = 10}) async {
    return _channels.values
        .where((c) => !c.isArchived)
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<CommunityChannel>> getTrendingChannels({int limit = 10}) async {
    return _channels.values
        .where((c) => !c.isArchived)
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(
    String query, {
    int limit = 20,
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>?> searchUserByUsername(String username) async {
    return null;
  }

  @override
  Future<List<SearchSuggestion>> getSearchSuggestions(
    String partialQuery, {
    String category = 'all',
    int limit = 10,
  }) async {
    return _suggestions.values
        .where((s) => s.text.toLowerCase().startsWith(partialQuery.toLowerCase()))
        .take(limit)
        .toList();
  }

  @override
  Future<void> recordSearch({
    required String userId,
    required String query,
    required int resultCount,
    Map<String, dynamic>? filters,
  }) async {
    final queryId = 'query_${DateTime.now().millisecondsSinceEpoch}';

    _searchQueries[queryId] = SearchQuery(
      queryId: queryId,
      userId: userId,
      query: query,
      resultCount: resultCount,
      timeMs: DateTime.now().millisecondsSinceEpoch,
      filters: filters ?? {},
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<SearchQuery>> getUserSearchHistory(
    String userId, {
    int limit = 20,
  }) async {
    return _searchQueries.values
        .where((q) => q.userId == userId)
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<SearchQuery>> getTrendingSearches({
    String timeRange = 'week',
    int limit = 10,
  }) async {
    return _searchQueries.values
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<void> clearSearchHistory(String userId) async {
    final toRemove = _searchQueries.entries
        .where((e) => e.value.userId == userId)
        .map((e) => e.key)
        .toList();

    for (final key in toRemove) {
      _searchQueries.remove(key);
    }
  }

  @override
  Future<String> saveSearch({
    required String userId,
    required String query,
    required String name,
    String? description,
    Map<String, dynamic>? filters,
  }) async {
    final savedSearchId = 'saved_${DateTime.now().millisecondsSinceEpoch}';

    _savedSearches[savedSearchId] = SavedSearch(
      savedSearchId: savedSearchId,
      userId: userId,
      query: query,
      name: name,
      description: description,
      filters: filters ?? {},
      createdAt: DateTime.now(),
    );

    return savedSearchId;
  }

  @override
  Future<SavedSearch?> getSavedSearch(String savedSearchId) async {
    return _savedSearches[savedSearchId];
  }

  @override
  Future<List<SavedSearch>> getSavedSearches(String userId) async {
    return _savedSearches.values
        .where((s) => s.userId == userId)
        .toList();
  }

  @override
  Future<void> updateSavedSearch(
    String savedSearchId, {
    String? name,
    String? description,
  }) async {
    final saved = _savedSearches[savedSearchId];
    if (saved == null) return;

    _savedSearches[savedSearchId] = SavedSearch(
      savedSearchId: saved.savedSearchId,
      userId: saved.userId,
      query: saved.query,
      name: name ?? saved.name,
      description: description ?? saved.description,
      filters: saved.filters,
      createdAt: saved.createdAt,
      lastUsedAt: saved.lastUsedAt,
      useCount: saved.useCount,
    );
  }

  @override
  Future<void> deleteSavedSearch(String savedSearchId) async {
    _savedSearches.remove(savedSearchId);
  }

  @override
  Future<void> useSavedSearch(String savedSearchId) async {
    final saved = _savedSearches[savedSearchId];
    if (saved == null) return;

    _savedSearches[savedSearchId] = saved.copyWith(
      lastUsedAt: DateTime.now(),
      useCount: saved.useCount + 1,
    );
  }

  @override
  Future<List<SearchQuery>> getSearchAnalytics({
    String? query,
    String timeRange = 'week',
    int limit = 20,
  }) async {
    return _searchQueries.values
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getSearchStats() async {
    return {
      'totalSearches': _searchQueries.length,
      'uniqueUsers': _searchQueries.values.map((q) => q.userId).toSet().length,
      'averageResults': _searchQueries.values.isEmpty
          ? 0.0
          : _searchQueries.values.fold<int>(0, (sum, q) => sum + q.resultCount) / _searchQueries.length,
      'trendingSearches': _searchQueries.values
          .map((q) => q.query)
          .toSet()
          .take(10)
          .toList(),
    };
  }

  // Report Appeals
  final Map<String, ReportAppeal> _appeals = {};

  @override
  Future<String> createReportAppeal({
    required String reportId,
    required String userId,
    String? userName,
    required String reason,
    String? attachmentUrl,
  }) async {
    final appealId = 'appeal_${DateTime.now().millisecondsSinceEpoch}';

    _appeals[appealId] = ReportAppeal(
      appealId: appealId,
      reportId: reportId,
      userId: userId,
      userName: userName,
      reason: reason,
      attachmentUrl: attachmentUrl,
      createdAt: DateTime.now(),
    );

    return appealId;
  }

  @override
  Future<ReportAppeal?> getReportAppeal(String appealId) async {
    return _appeals[appealId];
  }

  @override
  Future<List<ReportAppeal>> getReportAppeals({
    required String reportId,
    String? status,
    int limit = 20,
  }) async {
    var results = _appeals.values.where((a) => a.reportId == reportId).toList();

    if (status != null && status.isNotEmpty) {
      results = results.where((a) {
        final statusStr = a.status.toString().split('.').last;
        return statusStr == status;
      }).toList();
    }

    return results.take(limit).toList();
  }

  @override
  Future<List<ReportAppeal>> getUserAppeals({
    required String userId,
    String status = 'all',
    int limit = 20,
  }) async {
    var results = _appeals.values.where((a) => a.userId == userId).toList();

    if (status != 'all' && status.isNotEmpty) {
      results = results.where((a) {
        final statusStr = a.status.toString().split('.').last;
        return statusStr == status;
      }).toList();
    }

    return results.take(limit).toList();
  }

  @override
  Future<void> respondToAppeal({
    required String appealId,
    required String respondedByUserId,
    required String decision,
    String? reasoning,
    String? newAction,
  }) async {
    final appeal = _appeals[appealId];
    if (appeal == null) return;

    final status = AppealStatus.values
        .firstWhere((s) => s.toString().split('.').last == decision, orElse: () => AppealStatus.pending);

    _appeals[appealId] = appeal.copyWith(
      status: status,
      respondedByUserId: respondedByUserId,
      respondedAt: DateTime.now(),
      reasoning: reasoning,
      newAction: newAction,
    );
  }

  // Moderation Dashboard
  final Map<String, ModerationSummary> _summaries = {};
  final Map<String, ModeratorStats> _stats = {};

  @override
  Future<ModerationSummary?> getModerationSummary({
    String timeRange = 'day',
  }) async {
    return _summaries.values.firstWhere(
      (s) => s.timeRange == timeRange,
      orElse: () => ModerationSummary.empty(),
    ) as ModerationSummary?;
  }

  @override
  Future<ModerationSummary?> getModerationAnalytics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return _summaries.values.firstWhere(
      (s) => s.startDate.isBefore(endDate) && s.endDate.isAfter(startDate),
      orElse: () => ModerationSummary.empty(),
    ) as ModerationSummary?;
  }

  @override
  Future<ModeratorStats?> getModeratorStats({
    required String userId,
    String timeRange = 'month',
  }) async {
    return _stats.values.firstWhere(
      (s) => s.moderatorId == userId && s.timeRange == timeRange,
      orElse: () => ModeratorStats.empty(),
    ) as ModeratorStats?;
  }

  @override
  Future<List<ModeratorStats>> getTeamModerationStats({
    String timeRange = 'month',
    int limit = 50,
  }) async {
    return _stats.values
        .where((s) => s.timeRange == timeRange)
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<Map<String, dynamic>> compareModerators({
    required List<String> moderatorIds,
    required String metric,
  }) async {
    final statsList = <ModeratorStats>[];
    for (final modId in moderatorIds) {
      final stats = await getModeratorStats(userId: modId);
      if (stats != null) {
        statsList.add(stats);
      }
    }

    return {
      'moderators': statsList.map((s) => s.toMap()).toList(),
      'metric': metric,
    };
  }

  // Action History & Audit Trail
  final Map<String, ModerationActionRecord> _actions = {};

  @override
  Future<List<ModerationActionRecord>> getModerationActionHistory({
    int limit = 100,
    String? actionType,
  }) async {
    var results = _actions.values.toList();

    if (actionType != null && actionType.isNotEmpty) {
      results = results.where((a) {
        final typeStr = a.actionType.toString().split('.').last;
        return typeStr == actionType;
      }).toList();
    }

    return results
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt))
        .take(limit)
        .toList();
  }

  @override
  Future<List<ModerationActionRecord>> getModeratorActionHistory({
    required String userId,
    int limit = 50,
  }) async {
    return _actions.values
        .where((a) => a.moderatorId == userId)
        .toList()
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt))
        .take(limit)
        .toList();
  }

  @override
  Future<List<ModerationActionRecord>> getUserModerationHistory({
    required String userId,
    int limit = 50,
  }) async {
    return _actions.values
        .where((a) => a.targetUserId == userId)
        .toList()
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt))
        .take(limit)
        .toList();
  }

  @override
  Future<ModerationActionRecord?> getModerationAction(String actionId) async {
    return _actions[actionId];
  }

  // Escalation Management
  final Map<String, Escalation> _escalations = {};

  @override
  Future<void> escalateReport({
    required String reportId,
    required String escalatedByUserId,
    required String reason,
    required String escalateTo,
  }) async {
    final escalationId = 'escalation_${DateTime.now().millisecondsSinceEpoch}';
    final targetIndex = EscalationTarget.values
        .indexWhere((t) => t.toString().split('.').last == escalateTo);

    _escalations[escalationId] = Escalation(
      escalationId: escalationId,
      reportId: reportId,
      escalatedByUserId: escalatedByUserId,
      escalatedAt: DateTime.now(),
      escalateTo: targetIndex >= 0 ? EscalationTarget.values[targetIndex] : EscalationTarget.adminReview,
      reason: reason,
    );
  }

  @override
  Future<List<Escalation>> getEscalations({
    String status = 'pending',
    int limit = 50,
  }) async {
    var results = _escalations.values.toList();

    if (status.isNotEmpty) {
      results = results.where((e) {
        final statusStr = e.status.toString().split('.').last;
        return statusStr == status;
      }).toList();
    }

    return results
        .sorted((a, b) => b.escalatedAt.compareTo(a.escalatedAt))
        .take(limit)
        .toList();
  }

  @override
  Future<void> processEscalation({
    required String escalationId,
    required String processedByUserId,
    required String decision,
    String? notes,
  }) async {
    final escalation = _escalations[escalationId];
    if (escalation == null) return;

    final decisionStatus = EscalationStatus.values
        .firstWhere((s) => s.toString().split('.').last == decision, orElse: () => EscalationStatus.pending);

    _escalations[escalationId] = escalation.copyWith(
      status: decisionStatus,
      processedByUserId: processedByUserId,
      processedAt: DateTime.now(),
      decision: decision,
      notes: notes,
    );
  }

  // User Reputation & Gamification
  final Map<String, UserReputation> _reputations = {};
  final Map<String, ReputationEvent> _reputationEvents = {};
  final Map<String, BadgeDefinition> _badgeDefinitions = {};
  final Map<String, UserBadge> _userBadges = {};

  @override
  Future<String> addReputationEvent({
    required String userId,
    required String eventType,
    required int points,
    required String reason,
    String? relatedContentId,
    Map<String, dynamic>? metadata,
  }) async {
    final eventId = 'event_${DateTime.now().millisecondsSinceEpoch}';
    final typeIndex = ReputationEventType.values.indexWhere((t) => t.toString().split('.').last == eventType);

    _reputationEvents[eventId] = ReputationEvent(
      eventId: eventId,
      userId: userId,
      eventType: typeIndex >= 0 ? ReputationEventType.values[typeIndex] : ReputationEventType.postCreated,
      points: points,
      reason: reason,
      relatedContentId: relatedContentId,
      createdAt: DateTime.now(),
      metadata: metadata ?? {},
    );

    final rep = _reputations[userId] ?? UserReputation(
      reputationId: 'rep_$userId',
      userId: userId,
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );

    _reputations[userId] = rep.copyWith(
      totalScore: rep.totalScore + points,
      lastActivityAt: DateTime.now(),
    );

    return eventId;
  }

  @override
  Future<UserReputation?> getUserReputation(String userId) async {
    return _reputations[userId];
  }

  @override
  Future<List<ReputationEvent>> getReputationEvents({
    required String userId,
    int limit = 50,
  }) async {
    return _reputationEvents.values
        .where((e) => e.userId == userId)
        .toList()
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt))
        .take(limit)
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    final rep = _reputations[userId];
    if (rep == null) {
      return {
        'totalReputation': 0,
        'level': 1,
        'posts': 0,
        'replies': 0,
        'badges': 0,
      };
    }

    return {
      'totalReputation': rep.totalScore,
      'level': rep.currentLevel,
      'levelTitle': rep.levelTitle,
      'posts': rep.postsCount,
      'replies': rep.repliesCount,
      'upvotes': rep.upvotesReceived,
      'badges': rep.badgesCount,
    };
  }

  @override
  Future<int> getTotalReputation(String userId) async {
    return _reputations[userId]?.totalScore ?? 0;
  }

  // Badges
  @override
  Future<String> createBadgeDefinition({
    required String name,
    required String description,
    required String category,
    required String rarity,
    required int pointsValue,
    required String iconUrl,
    Map<String, dynamic>? requirements,
  }) async {
    final badgeId = 'badge_${DateTime.now().millisecondsSinceEpoch}';
    final categoryIndex = BadgeCategory.values.indexWhere((c) => c.toString().split('.').last == category);
    final rarityIndex = BadgeRarity.values.indexWhere((r) => r.toString().split('.').last == rarity);

    _badgeDefinitions[badgeId] = BadgeDefinition(
      badgeId: badgeId,
      name: name,
      description: description,
      category: categoryIndex >= 0 ? BadgeCategory.values[categoryIndex] : BadgeCategory.social,
      rarity: rarityIndex >= 0 ? BadgeRarity.values[rarityIndex] : BadgeRarity.common,
      pointsValue: pointsValue,
      iconUrl: iconUrl,
      requirements: requirements ?? {},
      createdAt: DateTime.now(),
    );

    return badgeId;
  }

  @override
  Future<BadgeDefinition?> getBadgeDefinition(String badgeId) async {
    return _badgeDefinitions[badgeId];
  }

  @override
  Future<List<BadgeDefinition>> getBadgeDefinitions({
    String? category,
    int limit = 50,
  }) async {
    var results = _badgeDefinitions.values.toList();

    if (category != null && category.isNotEmpty) {
      results = results.where((b) {
        final catStr = b.category.toString().split('.').last;
        return catStr == category;
      }).toList();
    }

    return results.take(limit).toList();
  }

  @override
  Future<List<UserBadge>> getUserBadges(String userId) async {
    return _userBadges.values
        .where((b) => b.userId == userId)
        .toList()
        .sorted((a, b) => b.earnedAt.compareTo(a.earnedAt));
  }

  @override
  Future<void> awardBadge({
    required String userId,
    required String badgeId,
    String? awardedBy,
    String? reason,
  }) async {
    final userBadgeId = 'ubadge_${DateTime.now().millisecondsSinceEpoch}';

    _userBadges[userBadgeId] = UserBadge(
      userBadgeId: userBadgeId,
      badgeId: badgeId,
      userId: userId,
      earnedAt: DateTime.now(),
      awardedBy: awardedBy,
      reason: reason,
    );

    final rep = _reputations[userId];
    if (rep != null) {
      _reputations[userId] = rep.copyWith(badgesCount: rep.badgesCount + 1);
    }
  }

  @override
  Future<Map<String, dynamic>> getBadgeProgress({
    required String userId,
    required String badgeId,
  }) async {
    final earned = _userBadges.values.any((b) => b.userId == userId && b.badgeId == badgeId);
    return {
      'badgeId': badgeId,
      'userId': userId,
      'earned': earned,
      'progress': earned ? 1.0 : 0.0,
    };
  }

  // Leaderboards
  @override
  Future<List<Map<String, dynamic>>> getTopContributors({
    int limit = 100,
    String timeRange = 'all',
  }) async {
    final sorted = _reputations.values
        .toList()
        .sorted((a, b) => b.totalScore.compareTo(a.totalScore))
        .take(limit);

    return sorted.asMap().entries.map((e) {
      final rep = e.value;
      return {
        'userId': rep.userId,
        'totalScore': rep.totalScore,
        'level': rep.currentLevel,
        'rank': e.key + 1,
      };
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getLeaderboard({
    required String metric,
    int limit = 50,
    String timeRange = 'month',
  }) async {
    final reps = _reputations.values.toList();

    if (metric == 'reputation') {
      reps.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    } else if (metric == 'posts') {
      reps.sort((a, b) => b.postsCount.compareTo(a.postsCount));
    } else if (metric == 'badges') {
      reps.sort((a, b) => b.badgesCount.compareTo(a.badgesCount));
    } else {
      reps.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    }

    return reps.take(limit).asMap().entries.map((e) {
      final rep = e.value;
      return {
        'userId': rep.userId,
        'score': metric == 'posts' ? rep.postsCount : metric == 'badges' ? rep.badgesCount : rep.totalScore,
        'level': rep.currentLevel,
        'rank': e.key + 1,
      };
    }).toList();
  }

  @override
  Future<Map<String, dynamic>?> getUserRank({
    required String userId,
    required String metric,
  }) async {
    final leaderboard = await getLeaderboard(metric: metric, limit: 10000);
    for (final entry in leaderboard) {
      if (entry['userId'] == userId) {
        return entry;
      }
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getNearbyRanks({
    required String userId,
    required String metric,
    int range = 5,
  }) async {
    final userRank = await getUserRank(userId: userId, metric: metric);
    if (userRank == null) return [];

    final rank = (userRank['rank'] as int?) ?? 0;
    final leaderboard = await getLeaderboard(metric: metric, limit: 10000);

    return leaderboard
        .where((e) {
          final entryRank = (e['rank'] as int?) ?? 0;
          return (entryRank >= rank - range) && (entryRank <= rank + range);
        })
        .toList();
  }

  // Levels & Progression
  @override
  Future<Map<String, dynamic>> getUserLevel(String userId) async {
    final rep = _reputations[userId];
    if (rep == null) {
      return {
        'level': 1,
        'title': 'Novice',
        'experience': 0,
        'nextLevelAt': 50,
      };
    }

    return {
      'level': rep.currentLevel,
      'title': rep.levelTitle,
      'experience': rep.totalScore,
      'nextLevelAt': rep.currentLevel * 50,
    };
  }

  @override
  Future<void> checkAndProcessLevelUp(String userId) async {
    final rep = _reputations[userId];
    if (rep == null) return;

    final nextLevelThreshold = rep.currentLevel * 50;
    if (rep.totalScore >= nextLevelThreshold) {
      final newLevel = rep.currentLevel + 1;
      final levelTitles = ['Novice', 'Contributor', 'Expert', 'Authority', 'Specialist', 'Legend'];
      final titleIndex = ((newLevel - 1) ~/ 5).clamp(0, levelTitles.length - 1);

      _reputations[userId] = rep.copyWith(
        currentLevel: newLevel,
        levelTitle: levelTitles[titleIndex],
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLevelDefinitions() async {
    return [
      {'level': 1, 'title': 'Novice', 'minXP': 0},
      {'level': 2, 'title': 'Novice', 'minXP': 50},
      {'level': 3, 'title': 'Contributor', 'minXP': 150},
      {'level': 4, 'title': 'Contributor', 'minXP': 300},
      {'level': 5, 'title': 'Expert', 'minXP': 500},
      {'level': 6, 'title': 'Expert', 'minXP': 750},
    ];
  }

  // Community Analytics & Insights
  final Map<String, PlatformMetrics> _metrics = {};
  final Map<String, UserEngagementMetrics> _engagementMetrics = {};
  final Map<String, ContentAnalytics> _contentAnalytics = {};
  final Map<String, CommunityHealthMetrics> _healthMetrics = {};

  @override
  Future<Map<String, dynamic>> getPlatformOverview({
    String timeRange = 'week',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return {
      'dau': 0,
      'mau': 0,
      'newUsers': 0,
      'totalUsers': 0,
      'postsCreated': 0,
      'repliesCreated': 0,
      'reportsSubmitted': 0,
      'moderationActions': 0,
      'revenue': 0.0,
      'subscriptions': 0,
    };
  }

  @override
  Future<Map<String, dynamic>> getKeyMetrics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return {'period': 'custom', 'metrics': []};
  }

  @override
  Future<List<Map<String, dynamic>>> getMetricTrends({
    required String metric,
    String timeRange = 'month',
    String granularity = 'daily',
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getUserEngagementStats({
    String timeRange = 'week',
  }) async {
    return {
      'avgPostsPerUser': 0.0,
      'avgRepliesPerUser': 0.0,
      'engagementRate': 0.0,
    };
  }

  @override
  Future<Map<String, dynamic>> getUserRetention({
    required DateTime cohortDate,
  }) async {
    return {};
  }

  @override
  Future<List<Map<String, dynamic>>> getEngagementBySegment({
    required String segment,
    int limit = 50,
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getContentAnalytics({
    String timeRange = 'week',
  }) async {
    return {
      'totalPosts': 0,
      'totalReplies': 0,
      'avgEngagement': 0.0,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getTrendingContent({
    String timeRange = 'day',
    int limit = 20,
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getChannelContentAnalytics({
    required String channelId,
    String timeRange = 'month',
  }) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> getCommunityHealthScore({
    String timeRange = 'week',
  }) async {
    return {
      'overallScore': 75.0,
      'sentimentScore': 0.7,
      'toxicityLevel': 0.1,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getCommunityHealthTrends({
    String timeRange = 'month',
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getChannelHealthMetrics({
    required String channelId,
  }) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> getUserGrowthMetrics({
    String timeRange = 'month',
  }) async {
    return {
      'newUsersPerDay': 0.0,
      'churnRate': 0.0,
      'netGrowth': 0.0,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getCohortRetention({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getUserAcquisitionAnalytics({
    String timeRange = 'month',
  }) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> getModerationAnalyticsOverview({
    String timeRange = 'week',
  }) async {
    return {
      'reportsPerDay': 0.0,
      'actionsPerDay': 0.0,
      'appealRate': 0.0,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getModeratorEffectiveness({
    String timeRange = 'month',
    int limit = 50,
  }) async {
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getModerationHotspots({
    String timeRange = 'week',
    int limit = 20,
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getRevenueAnalytics({
    String timeRange = 'month',
  }) async {
    return {
      'totalRevenue': 0.0,
      'subscriptionRevenue': 0.0,
      'arpu': 0.0,
    };
  }

  @override
  Future<Map<String, dynamic>> getSubscriptionAnalytics({
    String timeRange = 'month',
  }) async {
    return {
      'activeSubscriptions': 0,
      'churnRate': 0.0,
      'upgradeRate': 0.0,
    };
  }

  @override
  Future<Map<String, dynamic>> getConversionFunnel({
    String timeRange = 'week',
  }) async {
    return {};
  }

  @override
  Future<Map<String, dynamic>> generateCustomReport({
    required String name,
    required List<String> metrics,
    Map<String, dynamic>? filters,
    String timeRange = 'week',
    String format = 'json',
  }) async {
    return {
      'reportId': 'report_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'metrics': metrics,
      'format': format,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getSavedReports({
    int limit = 20,
  }) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> exportAnalyticsData({
    List<String> metrics = const ['all'],
    String timeRange = 'month',
    String format = 'csv',
  }) async {
    return {
      'exportId': 'export_${DateTime.now().millisecondsSinceEpoch}',
      'format': format,
      'metricsCount': 0,
    };
  }

  // Practice Test & Mock Exam Implementation (Stub)
  final Map<String, Question> _questions = {};
  final Map<String, PracticeTest> _practiceTests = {};
  final Map<String, MockExam> _mockExams = {};
  final Map<String, TestResult> _testResults = {};
  final Map<String, StudyPlan> _studyPlans = {};

  @override
  Future<String> createQuestion({
    required String questionText,
    required QuestionType questionType,
    required String topic,
    required QuestionDifficulty difficulty,
    List<String> options = const [],
    int? correctAnswerIndex,
    String? correctAnswer,
    String explanation = '',
    List<String> tags = const [],
  }) async {
    final questionId = 'question_${DateTime.now().millisecondsSinceEpoch}';
    _questions[questionId] = Question(
      questionId: questionId,
      questionText: questionText,
      questionType: questionType,
      topic: topic,
      difficulty: difficulty,
      options: options,
      correctAnswerIndex: correctAnswerIndex,
      correctAnswer: correctAnswer,
      explanation: explanation,
      tags: tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return questionId;
  }

  @override
  Future<Question?> getQuestion(String questionId) async {
    return _questions[questionId];
  }

  @override
  Future<List<Question>> getQuestions({
    String? topic,
    QuestionDifficulty? difficulty,
    int limit = 50,
  }) async {
    return _questions.values
        .where((q) => (topic == null || q.topic == topic) && (difficulty == null || q.difficulty == difficulty))
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<List<Question>> getQuestionsByTopic(String topic) async {
    return _questions.values.where((q) => q.topic == topic).toList();
  }

  @override
  Future<List<Question>> getQuestionsByDifficulty(QuestionDifficulty difficulty) async {
    return _questions.values.where((q) => q.difficulty == difficulty).toList();
  }

  @override
  Future<List<Question>> searchQuestions(String query) async {
    final queryLower = query.toLowerCase();
    return _questions.values
        .where((q) => q.questionText.toLowerCase().contains(queryLower) || q.tags.any((t) => t.toLowerCase().contains(queryLower)))
        .toList();
  }

  @override
  Future<String> startPracticeTest({
    required String userId,
    required String topic,
    required QuestionDifficulty difficulty,
    int questionCount = 10,
    int timeLimit = 600,
  }) async {
    final testId = 'test_${DateTime.now().millisecondsSinceEpoch}';
    final questions = await getQuestions(topic: topic, difficulty: difficulty, limit: questionCount);
    _practiceTests[testId] = PracticeTest(
      testId: testId,
      userId: userId,
      topic: topic,
      difficulty: difficulty,
      questionIds: questions.map((q) => q.questionId).toList(),
      startTime: DateTime.now(),
      answers: {},
      timePerQuestion: {},
    );
    return testId;
  }

  @override
  Future<void> submitAnswer({
    required String testId,
    required String questionId,
    dynamic selectedAnswer,
    int timeTaken = 0,
  }) async {
    final test = _practiceTests[testId];
    if (test != null) {
      test.answers[questionId] = selectedAnswer;
      test.timePerQuestion[questionId] = timeTaken;
      return;
    }
    final exam = _mockExams[testId];
    if (exam != null) {
      exam.answers[questionId] = selectedAnswer;
    }
  }

  @override
  Future<Map<String, dynamic>> completePracticeTest(String testId) async {
    final test = _practiceTests[testId];
    if (test == null) return {};

    int correct = 0;
    for (final questionId in test.questionIds) {
      final question = _questions[questionId];
      if (question != null && test.answers[questionId] != null) {
        if (test.answers[questionId] == question.correctAnswerIndex || test.answers[questionId] == question.correctAnswer) {
          correct++;
        }
      }
    }

    final percentage = (correct / test.questionIds.length * 100).toDouble();
    final result = TestResult(
      resultId: 'result_${DateTime.now().millisecondsSinceEpoch}',
      userId: test.userId,
      testId: testId,
      score: correct,
      percentage: percentage,
      questions: test.questionIds.length,
      correctAnswers: correct,
      wrongAnswers: test.questionIds.length - correct,
      unanswered: 0,
      duration: test.duration,
      isPassed: percentage >= 70,
      createdAt: DateTime.now(),
    );
    _testResults[result.resultId] = result;

    return {
      'score': correct,
      'percentage': percentage,
      'passed': percentage >= 70,
      'correctCount': correct,
      'totalCount': test.questionIds.length,
    };
  }

  @override
  Future<Map<String, dynamic>?> getPracticeTestResults(String testId) async {
    final test = _practiceTests[testId];
    if (test == null) return null;
    return {
      'testId': testId,
      'score': test.score,
      'percentage': test.percentage,
      'passed': test.passFail,
    };
  }

  @override
  Future<List<PracticeTest>> getPracticeTestHistory({
    required String userId,
    int limit = 50,
  }) async {
    return _practiceTests.values
        .where((t) => t.userId == userId)
        .toList()
        .take(limit)
        .toList();
  }

  @override
  Future<Map<String, double>> getTopicPerformance(
    String userId,
    String topic,
  ) async {
    final userTests = await getPracticeTestHistory(userId: userId);
    final topicTests = userTests.where((t) => t.topic == topic).toList();

    if (topicTests.isEmpty) return {};

    final avgScore = topicTests.fold(0.0, (sum, t) => sum + t.percentage) / topicTests.length;
    return {'topic': topic, 'averageScore': avgScore, 'testsCount': topicTests.length};
  }

  @override
  Future<String> startMockExam({
    required String userId,
    required ExamType examType,
    bool randomizeQuestions = true,
    bool showTimer = true,
  }) async {
    final examId = 'exam_${DateTime.now().millisecondsSinceEpoch}';
    final questions = _questions.values.toList();
    _mockExams[examId] = MockExam(
      examId: examId,
      userId: userId,
      examType: examType,
      totalQuestions: questions.length,
      questionIds: questions.map((q) => q.questionId).toList(),
      startTime: DateTime.now(),
      answers: {},
    );
    return examId;
  }

  @override
  Future<List<Question>> getMockExamQuestions(String examId) async {
    final exam = _mockExams[examId];
    if (exam == null) return [];
    return exam.questionIds.map((id) => _questions[id]).whereType<Question>().toList();
  }

  @override
  Future<Map<String, dynamic>> completeMockExam(String examId) async {
    final exam = _mockExams[examId];
    if (exam == null) return {};

    int correct = 0;
    for (final questionId in exam.questionIds) {
      final question = _questions[questionId];
      if (question != null && exam.answers[questionId] != null) {
        if (exam.answers[questionId] == question.correctAnswerIndex || exam.answers[questionId] == question.correctAnswer) {
          correct++;
        }
      }
    }

    final percentage = (correct / exam.questionIds.length * 100).toDouble();
    return {
      'score': correct,
      'percentage': percentage,
      'passed': percentage >= 70,
    };
  }

  @override
  Future<Map<String, dynamic>> getTestStatistics({
    required String userId,
    String timeRange = 'month',
  }) async {
    final userTests = await getPracticeTestHistory(userId: userId);
    if (userTests.isEmpty) {
      return {'totalTests': 0, 'averageScore': 0.0, 'passRate': 0.0};
    }

    final avgScore = userTests.fold(0.0, (sum, t) => sum + t.percentage) / userTests.length;
    final passCount = userTests.where((t) => t.passFail).length;
    final passRate = (passCount / userTests.length * 100).toDouble();

    return {
      'totalTests': userTests.length,
      'averageScore': avgScore,
      'passRate': passRate,
      'highestScore': userTests.map((t) => t.percentage).reduce((a, b) => a > b ? a : b),
      'lowestScore': userTests.map((t) => t.percentage).reduce((a, b) => a < b ? a : b),
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getScoreTrends({
    required String userId,
    int limit = 30,
  }) async {
    final userTests = await getPracticeTestHistory(userId: userId, limit: limit);
    return userTests
        .map((t) => {
          'date': t.startTime.toIso8601String(),
          'score': t.percentage,
          'topic': t.topic,
        })
        .toList();
  }

  @override
  Future<Map<String, double>> getPerformanceByTopic(String userId) async {
    final userTests = await getPracticeTestHistory(userId: userId);
    final topicScores = <String, List<double>>{};

    for (final test in userTests) {
      if (!topicScores.containsKey(test.topic)) {
        topicScores[test.topic] = [];
      }
      topicScores[test.topic]!.add(test.percentage);
    }

    return topicScores.map((topic, scores) => MapEntry(topic, scores.fold(0.0, (sum, s) => sum + s) / scores.length));
  }

  @override
  Future<Map<String, dynamic>> generateStudyPlan(String userId) async {
    final userTests = await getPracticeTestHistory(userId: userId);
    final performance = await getPerformanceByTopic(userId);

    final weakAreas = performance.entries.where((e) => e.value < 70).map((e) => e.key).toList();
    final planId = 'plan_${DateTime.now().millisecondsSinceEpoch}';

    _studyPlans[planId] = StudyPlan(
      planId: planId,
      userId: userId,
      createdAt: DateTime.now(),
      topics: weakAreas,
      estimatedHours: weakAreas.length * 2.0,
    );

    return {
      'planId': planId,
      'topics': weakAreas,
      'estimatedHours': weakAreas.length * 2.0,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getWeakAreas({
    required String userId,
    double threshold = 70.0,
  }) async {
    final performance = await getPerformanceByTopic(userId);
    return performance.entries
        .where((e) => e.value < threshold)
        .map((e) => {'topic': e.key, 'score': e.value})
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getTestAchievements(String userId) async {
    final userTests = await getPracticeTestHistory(userId: userId);
    final achievements = <Map<String, dynamic>>[];

    if (userTests.length >= 5) {
      achievements.add({'type': 'first_five_tests', 'earned': true});
    }
    if (userTests.any((t) => t.passFail)) {
      achievements.add({'type': 'first_pass', 'earned': true});
    }

    return achievements;
  }
}

import 'dart:math' show min;
