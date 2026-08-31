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

  // Video explanation methods
  Future<String> addVideoExplanation({
    required String questionId,
    required String title,
    required String description,
    required int duration,
    required String url,
    String? transcript,
    String? thumbnailUrl,
    required List<String> topics,
    String language = 'japanese',
  });

  Future<VideoExplanation?> getVideoExplanation(String videoId);

  Future<List<VideoExplanation>> getVideosByQuestion(String questionId);

  Future<List<VideoExplanation>> getVideosByTopic({
    required String topic,
    int limit = 50,
  });

  Future<void> updateVideoMetadata({
    required String videoId,
    String? title,
    String? description,
    String? transcript,
    String? status,
  });

  Future<void> publishVideo(String videoId);

  Future<List<VideoExplanation>> listVideosByStatus({
    required String status,
    int limit = 50,
  });

  Future<Map<String, dynamic>> getVideoAnalytics(String videoId);

  // ============ Progress Tracking Methods ============

  /// ユーザーの分野別学習進捗を記録または更新
  Future<void> updateProgressTracker({
    required String userId,
    required String category,
    required bool isCorrect,
    required int timeSpentSeconds,
  });

  /// 指定されたカテゴリの学習進捗を取得
  Future<ProgressTracker?> getProgressTracker({
    required String userId,
    required String category,
  });

  /// ユーザーの全カテゴリの学習進捗を取得
  Future<List<ProgressTracker>> getUserProgressTrackers(String userId);

  /// 複数カテゴリの進捗を効率的に取得
  Future<Map<String, ProgressTracker>> getProgressTrackersByCategories({
    required String userId,
    required List<String> categories,
  });

  // ============ Weak Area Detection Methods ============

  /// 弱点分野を検出し、優先度付けして返す
  Future<List<WeakArea>> detectWeakAreas({
    required String userId,
    double accuracyThreshold = 0.7,
    int minAttempts = 5,
  });

  /// 指定されたカテゴリの弱点を取得
  Future<WeakArea?> getWeakArea({
    required String userId,
    required String category,
  });

  /// ユーザーの全弱点分野を取得
  Future<List<WeakArea>> getUserWeakAreas(String userId);

  /// 弱点分野を優先度順にソート して返す
  Future<List<WeakArea>> getWeakAreasByPriority({
    required String userId,
    int limit = 5,
  });

  /// 弱点分野を解決済みにマーク
  Future<void> resolveWeakArea({
    required String userId,
    required String weakAreaId,
  });

  /// 弱点分野の推奨学習トピックを取得
  Future<List<String>> getRecommendedTopicsForWeakArea(String weakAreaId);

  // ============ Review Schedule Methods ============

  /// 復習スケジュールを作成（スペーシング・リピティション）
  Future<List<ReviewScheduleItem>> createReviewSchedule({
    required String userId,
    required List<String> questionIds,
    required String baseTopic,
  });

  /// ユーザーの復習スケジュールを全て取得
  Future<List<ReviewScheduleItem>> getUserReviewSchedules(String userId);

  /// 指定された日付の復習スケジュールを取得
  Future<List<ReviewScheduleItem>> getReviewScheduleForDate({
    required String userId,
    required DateTime date,
  });

  /// 今日の復習スケジュールを取得
  Future<List<ReviewScheduleItem>> getTodayReviewSchedule(String userId);

  /// 復習を実施済みにマーク
  Future<void> completeReviewSchedule({
    required String reviewId,
  });

  /// 期限切れの復習スケジュールを取得
  Future<List<ReviewScheduleItem>> getOverdueReviewSchedules(String userId);

  /// 復習スケジュール内の間違った問題を取得
  Future<List<String>> getIncorrectQuestionsFromReview(String reviewId);

  // ============ Adaptive Learning Methods ============

  /// 学習準備度を予測（0.0～1.0）
  Future<double> predictReadinessProbability(String userId);

  /// 推奨学習時間を計算
  Future<int> calculateRecommendedStudyMinutes(String userId);

  /// パーソナライズされた学習計画を作成
  Future<StudyPlan> generatePersonalizedStudyPlan(String userId);

  // ============ Exam Readiness Prediction Methods ============

  /// 総合的な試験合格可能性を予測
  Future<ExamReadinessPrediction> predictExamReadiness(String userId);

  /// 分野別の試験合格可能性を予測
  Future<ExamReadinessPrediction> predictCategoryReadiness({
    required String userId,
    required String category,
  });

  /// 各分野のReadinessFactorsを計算
  Future<ReadinessFactors> calculateReadinessFactors({
    required String userId,
    required String category,
  });

  /// 目標正答率に達するまでの時間を推定
  Future<TimeToReadiness> estimateTimeToReadiness({
    required String userId,
    required String category,
    required int targetAccuracyPercent,
  });

  /// 複数分野の統合readiness予測
  Future<Map<String, ExamReadinessPrediction>> predictCategoryReadinessList(
    String userId,
  );

  /// ユーザーの試験合格予測を更新
  Future<void> updateReadinessPrediction({
    required String userId,
    required ExamReadinessPrediction prediction,
  });

  /// 試験readiness予測を取得
  Future<ExamReadinessPrediction?> getReadinessPrediction(String userId);

  /// Readiness改善トレンドを取得（過去14日）
  Future<List<Map<String, dynamic>>> getReadinessTrend(String userId);

  /// 合格確実と判定されるreadiness閾値
  Future<bool> isPassProbableReady(String userId);

  // ============ Gamification & Achievement Methods ============

  /// バッジを獲得済みにマーク
  Future<void> earnBadge({
    required String userId,
    required BadgeType type,
    required String displayName,
    required String description,
    required BadgeRarityLevel rarity,
    required int points,
  });

  /// ユーザーが獲得したバッジを取得
  Future<List<AchievementBadge>> getUserBadges(String userId);

  /// 特定のバッジを取得
  Future<AchievementBadge?> getBadge(String badgeId);

  /// バッジを固定/解除（プロフィール表示）
  Future<void> toggleBadgePinned({
    required String badgeId,
    required bool isPinned,
  });

  /// ストリークを更新
  Future<void> updateStreak({
    required String userId,
    required bool studiedToday,
  });

  /// ユーザーのストリークを取得
  Future<StudyStreak?> getUserStreak(String userId);

  /// ストリークをリセット
  Future<void> resetStreak(String userId);

  // ============ Achievement Statistics Methods ============

  /// ユーザーのアチーブメント統計を取得
  Future<AchievementStats?> getAchievementStats(String userId);

  /// アチーブメント統計を初期化
  Future<void> initializeAchievementStats(String userId);

  /// XP報酬マルチプライヤーを取得
  Future<RewardMultiplier?> getRewardMultiplier(String userId);

  /// XP報酬マルチプライヤーを設定
  Future<void> setRewardMultiplier({
    required String userId,
    required double multiplier,
    required List<String> boosts,
    DateTime? expiresAt,
    required String reason,
  });

  /// ユーザーにXPを付与
  Future<int> awardXP({
    required String userId,
    required int baseXP,
  });

  /// パーフェクトスコアを記録
  Future<void> recordPerfectScore(String userId);

  /// 最高記録を更新
  Future<void> updateFastestTime({
    required String userId,
    required int timeInSeconds,
  });

  /// マイルストーン達成を検查（50問、100問など）
  Future<List<String>> checkMilestoneAchievements(String userId);

  /// ユーザーレベルを取得
  Future<int> getUserLevel(String userId);

  /// ユーザーの総XPを取得
  Future<int> getUserTotalXP(String userId);

  // ============ B2B Partnership Methods ============

  /// パートナーシップを作成
  Future<String> createPartnership({
    required String schoolName,
    required String contactEmail,
    required PartnershipTier tier,
    required int maxStudents,
  });

  /// パートナーシップを取得
  Future<PartnershipAgreement?> getPartnership(String partnershipId);

  /// パートナーシップを更新
  Future<void> updatePartnership({
    required String partnershipId,
    required PartnershipAgreement agreement,
  });

  /// 全パートナーシップを取得
  Future<List<PartnershipAgreement>> getAllPartnerships();

  /// アクティブなパートナーシップを取得
  Future<List<PartnershipAgreement>> getActivePartnerships();

  /// パートナーシップを一時停止
  Future<void> suspendPartnership(String partnershipId);

  /// パートナーシップを再開
  Future<void> resumePartnership(String partnershipId);

  // ============ Institutional License Methods ============

  /// ライセンスを発行
  Future<String> issueLicense({
    required String partnershipId,
    required String userId,
    required String userName,
    required LicenseType type,
  });

  /// ライセンスを取得
  Future<InstitutionalLicense?> getLicense(String licenseId);

  /// パートナーシップの全ライセンスを取得
  Future<List<InstitutionalLicense>> getPartnershipLicenses(String partnershipId);

  /// ライセンスを無効化
  Future<void> revokeLicense(String licenseId);

  /// ライセンスを更新（ログイン記録など）
  Future<void> updateLicense({
    required String licenseId,
    required InstitutionalLicense license,
  });

  // ============ Analytics Methods ============

  /// 機関別分析を生成
  Future<InstitutionalAnalytics> generateInstitutionalAnalytics({
    required String partnershipId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// 機関別分析を取得
  Future<InstitutionalAnalytics?> getInstitutionalAnalytics(String analyticsId);

  /// 学生パフォーマンスサマリーを取得
  Future<Map<String, dynamic>> getStudentPerformanceSummary({
    required String partnershipId,
    required String userId,
  });

  // ============ Billing Methods ============

  /// 請求書を生成
  Future<PartnershipBilling> generateBilling({
    required String partnershipId,
    required DateTime billingPeriodStart,
    required DateTime billingPeriodEnd,
  });

  /// 請求情報を取得
  Future<PartnershipBilling?> getBilling(String billingId);

  /// パートナーシップの請求履歴を取得
  Future<List<PartnershipBilling>> getPartnershipBillingHistory(String partnershipId);

  /// 支払いを確認
  Future<void> confirmPayment({
    required String billingId,
    required DateTime paidAt,
  });

  // ============ Seat Management ============

  /// ライセンスを消費（学生を追加）
  Future<void> consumeSeat(String partnershipId);

  /// ライセンスを返却（学生を削除）
  Future<void> releaseSeat(String partnershipId);

  /// シート利用状況を取得
  Future<Map<String, int>> getSeatUsage(String partnershipId);

  /// シート追加購入
  Future<void> purchaseAdditionalSeats({
    required String partnershipId,
    required int numSeats,
  });

  // ============ Admin Dashboard ============

  /// Instructor dashboard を生成
  Future<InstructorDashboard?> generateInstructorDashboard({
    required String instructorId,
    required String partnershipId,
  });

  /// Instructor dashboard を取得
  Future<InstructorDashboard?> getInstructorDashboard(String instructorId);

  /// Admin dashboard を生成
  Future<AdminDashboard?> generateAdminDashboard({
    required String partnershipId,
  });

  /// Admin dashboard を取得
  Future<AdminDashboard?> getAdminDashboard(String partnershipId);

  /// 学生の進度ウィジェットを取得
  Future<StudentProgressWidget?> getStudentProgressWidget({
    required String studentId,
    required String partnershipId,
  });

  /// クラスの学生進度一覧を取得
  Future<List<StudentProgressWidget>> getClassStudentProgress({
    required String instructorId,
    required String partnershipId,
  });

  /// 学生のエンゲージメント指標を取得
  Future<StudentEngagementMetrics?> getStudentEngagementMetrics(String studentId);

  /// 危機的な学生を取得
  Future<List<StudentProgressWidget>> getAtRiskStudents({
    required String partnershipId,
  });

  /// トップパフォーマーを取得
  Future<List<StudentProgressWidget>> getTopPerformers({
    required String partnershipId,
    int limit = 10,
  });

  /// カテゴリー別パフォーマンスを取得
  Future<Map<String, CategoryPerformanceChart>> getCategoryPerformance({
    required String partnershipId,
  });

  /// カスタムレポートを生成
  Future<String> generateCustomReport({
    required String partnershipId,
    required String reportName,
    required ReportType reportType,
    required Map<String, dynamic> filters,
  });

  /// レポートを取得
  Future<CustomReport?> getCustomReport(String reportId);

  /// パートナーシップのレポート履歴を取得
  Future<List<CustomReport>> getPartnershipReports({
    required String partnershipId,
  });

  /// レポートをエクスポート (PDF, CSV, XLSX)
  Future<String?> exportReport({
    required String reportId,
    required String format, // 'pdf', 'csv', 'xlsx'
  });

  /// 教員にアサインされた学生を取得
  Future<List<String>> getAssignedStudents(String instructorId);

  /// ダッシュボードウィジェットを更新
  Future<void> updateDashboardWidget({
    required String dashboardId,
    required DashboardWidget widget,
  });

  /// インスティテューショナルアナリティクスをリアルタイム更新
  Future<void> refreshInstitutionalMetrics(String partnershipId);

  // ============ Content Management ============

  /// 機関向け問題を作成
  Future<String> createInstitutionalQuestion({
    required String partnershipId,
    required String createdByUserId,
    required String questionText,
    required QuestionType type,
    required QuestionDifficulty difficulty,
    required String category,
    String? subcategory,
    required List<String> answerOptions,
    required String correctAnswer,
    String? explanation,
    List<String>? keywords,
    required ContentAccessLevel accessLevel,
  });

  /// 機関向け問題を取得
  Future<InstitutionalQuestion?> getInstitutionalQuestion(String questionId);

  /// パートナーシップの問題を取得
  Future<List<InstitutionalQuestion>> getPartnershipQuestions({
    required String partnershipId,
    String? category,
    QuestionDifficulty? difficulty,
    int limit = 50,
  });

  /// 問題を公開
  Future<void> publishQuestion(String questionId);

  /// 問題を承認
  Future<void> approveQuestion({
    required String questionId,
    required String reviewedByUserId,
    String? reviewNotes,
  });

  /// 問題バンクを作成
  Future<String> createQuestionBank({
    required String partnershipId,
    required String bankName,
    required String description,
  });

  /// 問題バンクを取得
  Future<InstitutionalQuestionBank?> getQuestionBank(String bankId);

  /// パートナーシップの問題バンクを取得
  Future<List<InstitutionalQuestionBank>> getPartnershipQuestionBanks(
    String partnershipId,
  );

  /// コースを作成
  Future<String> createCourse({
    required String partnershipId,
    required String courseName,
    required String description,
    required List<String> topicIds,
    required int totalLessons,
    required int estimatedHours,
    required String instructorId,
    required ContentAccessLevel accessLevel,
  });

  /// コースを取得
  Future<Course?> getCourse(String courseId);

  /// パートナーシップのコースを取得
  Future<List<Course>> getPartnershipCourses(String partnershipId);

  /// コースを公開
  Future<void> publishCourse(String courseId);

  /// コースに問題を追加
  Future<void> addQuestionToCourse({
    required String courseId,
    required String questionId,
  });

  /// カリキュラムを作成
  Future<String> createCurriculum({
    required String partnershipId,
    required String curriculumName,
    required String description,
    required CurriculumType type,
    required List<String> courseIds,
    required int totalHours,
    required int targetLevel,
    String? targetExamType,
  });

  /// カリキュラムを取得
  Future<Curriculum?> getCurriculum(String curriculumId);

  /// パートナーシップのカリキュラムを取得
  Future<List<Curriculum>> getPartnershipCurricula(String partnershipId);

  /// カリキュラムを公開
  Future<void> publishCurriculum(String curriculumId);

  /// コースにエンロール
  Future<String> enrollInCourse({
    required String courseId,
    required String studentId,
    required String partnershipId,
  });

  /// コースエンロールメントを取得
  Future<CourseEnrollment?> getCourseEnrollment(String enrollmentId);

  /// 学生のコースエンロールメントを取得
  Future<List<CourseEnrollment>> getStudentCourseEnrollments(String studentId);

  /// コースエンロールメントを更新
  Future<void> updateCourseProgress({
    required String enrollmentId,
    required double completionPercentage,
    required double currentScore,
    required int lessonsCompleted,
  });

  /// カリキュラムプログレスを追跡開始
  Future<String> startCurriculumProgress({
    required String curriculumId,
    required String studentId,
    required String partnershipId,
  });

  /// カリキュラムプログレスを取得
  Future<CurriculumProgress?> getCurriculumProgress(String progressId);

  /// 学生のカリキュラムプログレスを取得
  Future<CurriculumProgress?> getStudentCurriculumProgress({
    required String studentId,
    required String curriculumId,
  });

  /// カリキュラムプログレスを更新
  Future<void> updateCurriculumProgress({
    required String progressId,
    required int currentCourseIndex,
    required double overallProgress,
    required double currentScore,
    required int hoursSpent,
  });

  /// 問題の使用統計を更新
  Future<void> updateQuestionUsageStats({
    required String questionId,
    required double timeSpent,
    required bool wasCorrect,
  });

  /// カテゴリ別問題統計を取得
  Future<Map<String, int>> getQuestionStatsByCategory(String partnershipId);

  /// 難易度別問題統計を取得
  Future<Map<String, int>> getQuestionStatsByDifficulty(String partnershipId);

  /// コース完了率を取得
  Future<double> getCourseCompletionRate(String courseId);

  /// カリキュラム完了率を取得
  Future<double> getCurriculumCompletionRate(String curriculumId);
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

  // Video explanation implementations
  @override
  Future<String> addVideoExplanation({
    required String questionId,
    required String title,
    required String description,
    required int duration,
    required String url,
    String? transcript,
    String? thumbnailUrl,
    required List<String> topics,
    String language = 'japanese',
  }) async {
    final videoId = 'vid_${DateTime.now().millisecondsSinceEpoch}';
    final video = VideoExplanation(
      videoId: videoId,
      questionId: questionId,
      title: title,
      description: description,
      duration: duration,
      url: url,
      transcript: transcript,
      thumbnailUrl: thumbnailUrl,
      topics: topics,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: VideoStatus.draft,
      language: language == 'english' ? VideoLanguage.english : VideoLanguage.japanese,
    );
    _videos[videoId] = video;
    return videoId;
  }

  @override
  Future<VideoExplanation?> getVideoExplanation(String videoId) async {
    return _videos[videoId];
  }

  @override
  Future<List<VideoExplanation>> getVideosByQuestion(String questionId) async {
    return _videos.values
        .where((v) => v.questionId == questionId)
        .toList();
  }

  @override
  Future<List<VideoExplanation>> getVideosByTopic({
    required String topic,
    int limit = 50,
  }) async {
    return _videos.values
        .where((v) => v.topics.contains(topic))
        .take(limit)
        .toList();
  }

  @override
  Future<void> updateVideoMetadata({
    required String videoId,
    String? title,
    String? description,
    String? transcript,
    String? status,
  }) async {
    final video = _videos[videoId];
    if (video != null) {
      final updatedStatus = status != null
          ? VideoStatus.values.firstWhere(
              (e) => e.name == status,
              orElse: () => video.status,
            )
          : video.status;

      _videos[videoId] = VideoExplanation(
        videoId: video.videoId,
        questionId: video.questionId,
        title: title ?? video.title,
        description: description ?? video.description,
        duration: video.duration,
        url: video.url,
        transcript: transcript ?? video.transcript,
        thumbnailUrl: video.thumbnailUrl,
        status: updatedStatus,
        language: video.language,
        topics: video.topics,
        createdAt: video.createdAt,
        updatedAt: DateTime.now(),
        viewCount: video.viewCount,
        averageRating: video.averageRating,
      );
    }
  }

  @override
  Future<void> publishVideo(String videoId) async {
    await updateVideoMetadata(
      videoId: videoId,
      status: 'published',
    );
  }

  @override
  Future<List<VideoExplanation>> listVideosByStatus({
    required String status,
    int limit = 50,
  }) async {
    final statusEnum = VideoStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => VideoStatus.draft,
    );
    return _videos.values
        .where((v) => v.status == statusEnum)
        .take(limit)
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getVideoAnalytics(String videoId) async {
    final video = _videos[videoId];
    if (video == null) return {};
    return {
      'videoId': videoId,
      'viewCount': video.viewCount,
      'averageRating': video.averageRating,
      'duration': video.duration,
      'questionsLinked': 1,
      'engagementRate': (video.viewCount > 0 ? video.averageRating / 5.0 : 0.0) * 100,
    };
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
  final Map<String, VideoExplanation> _videos = {}; // Phase 11 Step 9 - Video Explanations

  // Phase 11 Step 14 - Admin Dashboard
  final Map<String, InstructorDashboard> _instructorDashboards = {};
  final Map<String, AdminDashboard> _adminDashboards = {};
  final Map<String, StudentProgressWidget> _studentProgressWidgets = {};
  final Map<String, StudentEngagementMetrics> _studentEngagement = {};
  final Map<String, CustomReport> _reports = {};
  final Map<String, List<String>> _instructorStudentAssignments = {}; // instructorId -> [studentIds]

  // Phase 12 - Content Management
  final Map<String, InstitutionalQuestion> _institutionalQuestions = {};
  final Map<String, InstitutionalQuestionBank> _questionBanks = {};
  final Map<String, Course> _courses = {};
  final Map<String, Curriculum> _curricula = {};
  final Map<String, CourseEnrollment> _enrollments = {};
  final Map<String, CurriculumProgress> _curriculumProgress = {};
  final Map<String, Map<String, dynamic>> _questionUsageStats = {}; // questionId -> stats

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

  // ============ Progress Tracking Implementation ============

  final Map<String, ProgressTracker> _progressTrackers = {};

  @override
  Future<void> updateProgressTracker({
    required String userId,
    required String category,
    required bool isCorrect,
    required int timeSpentSeconds,
  }) async {
    final key = '$userId:$category';
    final existing = _progressTrackers[key];

    if (existing == null) {
      _progressTrackers[key] = ProgressTracker(
        trackerId: 'pt_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        category: category,
        correctCount: isCorrect ? 1 : 0,
        totalAttempts: 1,
        minutesSpent: timeSpentSeconds ~/ 60,
        lastStudiedAt: DateTime.now(),
        lastFiveScores: isCorrect ? [100] : [0],
        consecutiveCorrect: isCorrect ? 1 : 0,
        longestStreak: isCorrect ? 1 : 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else {
      final newCorrectCount = existing.correctCount + (isCorrect ? 1 : 0);
      final newTotalAttempts = existing.totalAttempts + 1;
      final newScore = isCorrect ? 100 : 0;
      final newScores = existing.lastFiveScores.length >= 5
          ? existing.lastFiveScores.sublist(1) + [newScore]
          : existing.lastFiveScores + [newScore];

      _progressTrackers[key] = ProgressTracker(
        trackerId: existing.trackerId,
        userId: userId,
        category: category,
        correctCount: newCorrectCount,
        totalAttempts: newTotalAttempts,
        minutesSpent: existing.minutesSpent + (timeSpentSeconds ~/ 60),
        lastStudiedAt: DateTime.now(),
        lastFiveScores: newScores,
        consecutiveCorrect: isCorrect ? existing.consecutiveCorrect + 1 : 0,
        longestStreak: isCorrect
            ? (existing.longestStreak + 1).clamp(0, 999)
            : existing.longestStreak,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<ProgressTracker?> getProgressTracker({
    required String userId,
    required String category,
  }) async {
    return _progressTrackers['$userId:$category'];
  }

  @override
  Future<List<ProgressTracker>> getUserProgressTrackers(String userId) async {
    return _progressTrackers.values
        .where((t) => t.userId == userId)
        .toList();
  }

  @override
  Future<Map<String, ProgressTracker>> getProgressTrackersByCategories({
    required String userId,
    required List<String> categories,
  }) async {
    final result = <String, ProgressTracker>{};
    for (final category in categories) {
      final tracker = _progressTrackers['$userId:$category'];
      if (tracker != null) {
        result[category] = tracker;
      }
    }
    return result;
  }

  // ============ Weak Area Detection Implementation ============

  final Map<String, WeakArea> _weakAreas = {};

  @override
  Future<List<WeakArea>> detectWeakAreas({
    required String userId,
    double accuracyThreshold = 0.7,
    int minAttempts = 5,
  }) async {
    final trackers = await getUserProgressTrackers(userId);
    final weakAreas = <WeakArea>[];

    for (final tracker in trackers) {
      if (tracker.totalAttempts >= minAttempts &&
          tracker.accuracyRate < accuracyThreshold) {
        final currentAccuracy = tracker.accuracyPercentage;
        final targetAccuracy = 85;
        final gap = targetAccuracy - currentAccuracy;
        final priorityScore = (gap * 2).toInt().clamp(0, 100);

        String priority;
        if (currentAccuracy < 60) {
          priority = '最優先';
        } else if (currentAccuracy < 75) {
          priority = '重要';
        } else {
          priority = '進捗中';
        }

        final estimatedMinutes = (gap * 3).toInt().clamp(15, 120);
        final suggestedTopics =
            _generateSuggestedTopics(tracker.category, tracker.lastFiveScores);

        final weakArea = WeakArea(
          weakAreaId: 'wa_${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          category: tracker.category,
          currentAccuracy: currentAccuracy,
          targetAccuracy: targetAccuracy,
          attemptCount: tracker.totalAttempts,
          priorityScore: priorityScore,
          priority: priority,
          estimatedMinutesNeeded: estimatedMinutes,
          suggestedTopics: suggestedTopics,
          identifiedAt: DateTime.now(),
          targetCompletionDate:
              DateTime.now().add(Duration(days: (estimatedMinutes ~/ 30))),
          isResolved: false,
        );

        _weakAreas[weakArea.weakAreaId] = weakArea;
        weakAreas.add(weakArea);
      }
    }

    return weakAreas;
  }

  List<String> _generateSuggestedTopics(
    String category,
    List<int> lastFiveScores,
  ) {
    // 最近のスコアに基づいて弱い分野を提案
    if (lastFiveScores.isEmpty) {
      return [category];
    }

    final recentAverage =
        lastFiveScores.reduce((a, b) => a + b) ~/ lastFiveScores.length;
    final suggestedTopics = <String>[];

    if (category.contains('交通規則')) {
      if (recentAverage < 70) {
        suggestedTopics.addAll(['速度制限', '一時停止', '標識の意味']);
      }
    } else if (category.contains('危機回避')) {
      if (recentAverage < 70) {
        suggestedTopics.addAll(['急ブレーキ', 'スリップ対策', '雨天運転']);
      }
    } else if (category.contains('機械知識')) {
      if (recentAverage < 70) {
        suggestedTopics.addAll(['エンジン', 'ブレーキシステム', 'タイヤ管理']);
      }
    }

    return suggestedTopics.isNotEmpty ? suggestedTopics : [category];
  }

  @override
  Future<WeakArea?> getWeakArea({
    required String userId,
    required String category,
  }) async {
    try {
      return _weakAreas.values.firstWhere(
        (wa) => wa.userId == userId && wa.category == category && !wa.isResolved,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<WeakArea>> getUserWeakAreas(String userId) async {
    return _weakAreas.values
        .where((wa) => wa.userId == userId && !wa.isResolved)
        .toList();
  }

  @override
  Future<List<WeakArea>> getWeakAreasByPriority({
    required String userId,
    int limit = 5,
  }) async {
    final weakAreas = await getUserWeakAreas(userId);
    weakAreas.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
    return weakAreas.take(limit).toList();
  }

  @override
  Future<void> resolveWeakArea({
    required String userId,
    required String weakAreaId,
  }) async {
    final weakArea = _weakAreas[weakAreaId];
    if (weakArea != null && weakArea.userId == userId) {
      _weakAreas[weakAreaId] = WeakArea(
        weakAreaId: weakArea.weakAreaId,
        userId: weakArea.userId,
        category: weakArea.category,
        currentAccuracy: weakArea.currentAccuracy,
        targetAccuracy: weakArea.targetAccuracy,
        attemptCount: weakArea.attemptCount,
        priorityScore: weakArea.priorityScore,
        priority: weakArea.priority,
        estimatedMinutesNeeded: weakArea.estimatedMinutesNeeded,
        suggestedTopics: weakArea.suggestedTopics,
        identifiedAt: weakArea.identifiedAt,
        targetCompletionDate: weakArea.targetCompletionDate,
        isResolved: true,
      );
    }
  }

  @override
  Future<List<String>> getRecommendedTopicsForWeakArea(
    String weakAreaId,
  ) async {
    return _weakAreas[weakAreaId]?.suggestedTopics ?? [];
  }

  // ============ Review Schedule Implementation ============

  final Map<String, ReviewScheduleItem> _reviewSchedules = {};

  @override
  Future<List<ReviewScheduleItem>> createReviewSchedule({
    required String userId,
    required List<String> questionIds,
    required String baseTopic,
  }) async {
    final schedules = <ReviewScheduleItem>[];
    final now = DateTime.now();

    // 明日（1日後）
    final tomorrow = ReviewScheduleItem(
      reviewId: 'rs_${DateTime.now().millisecondsSinceEpoch}_1',
      userId: userId,
      questionIds: questionIds,
      scheduledFor: now.add(Duration(days: 1)),
      interval: '明日',
      questionCount: questionIds.length,
      estimatedMinutes: (questionIds.length * 1.5).toInt(),
    );
    _reviewSchedules[tomorrow.reviewId] = tomorrow;
    schedules.add(tomorrow);

    // 3日後
    final threeDays = ReviewScheduleItem(
      reviewId: 'rs_${DateTime.now().millisecondsSinceEpoch}_3',
      userId: userId,
      questionIds: questionIds,
      scheduledFor: now.add(Duration(days: 3)),
      interval: '3日後',
      questionCount: questionIds.length,
      estimatedMinutes: (questionIds.length * 1.5).toInt(),
    );
    _reviewSchedules[threeDays.reviewId] = threeDays;
    schedules.add(threeDays);

    // 1週間後
    final oneWeek = ReviewScheduleItem(
      reviewId: 'rs_${DateTime.now().millisecondsSinceEpoch}_7',
      userId: userId,
      questionIds: questionIds,
      scheduledFor: now.add(Duration(days: 7)),
      interval: '1週間後',
      questionCount: questionIds.length,
      estimatedMinutes: (questionIds.length * 1.5).toInt(),
    );
    _reviewSchedules[oneWeek.reviewId] = oneWeek;
    schedules.add(oneWeek);

    return schedules;
  }

  @override
  Future<List<ReviewScheduleItem>> getUserReviewSchedules(
    String userId,
  ) async {
    return _reviewSchedules.values
        .where((rs) => rs.userId == userId)
        .toList();
  }

  @override
  Future<List<ReviewScheduleItem>> getReviewScheduleForDate({
    required String userId,
    required DateTime date,
  }) async {
    return _reviewSchedules.values
        .where((rs) =>
            rs.userId == userId &&
            rs.scheduledFor.year == date.year &&
            rs.scheduledFor.month == date.month &&
            rs.scheduledFor.day == date.day)
        .toList();
  }

  @override
  Future<List<ReviewScheduleItem>> getTodayReviewSchedule(
    String userId,
  ) async {
    final today = DateTime.now();
    return getReviewScheduleForDate(userId: userId, date: today);
  }

  @override
  Future<void> completeReviewSchedule({
    required String reviewId,
  }) async {
    final schedule = _reviewSchedules[reviewId];
    if (schedule != null) {
      _reviewSchedules[reviewId] = ReviewScheduleItem(
        reviewId: schedule.reviewId,
        userId: schedule.userId,
        questionIds: schedule.questionIds,
        scheduledFor: schedule.scheduledFor,
        interval: schedule.interval,
        questionCount: schedule.questionCount,
        isCompleted: true,
        completedAt: DateTime.now(),
        estimatedMinutes: schedule.estimatedMinutes,
      );
    }
  }

  @override
  Future<List<ReviewScheduleItem>> getOverdueReviewSchedules(
    String userId,
  ) async {
    final now = DateTime.now();
    return _reviewSchedules.values
        .where((rs) => rs.userId == userId && rs.isOverdue)
        .toList();
  }

  @override
  Future<List<String>> getIncorrectQuestionsFromReview(
    String reviewId,
  ) async {
    // スタブ実装：実際のテスト結果から間違った問題を取得
    return [];
  }

  // ============ Adaptive Learning Implementation ============

  @override
  Future<double> predictReadinessProbability(String userId) async {
    final trackers = await getUserProgressTrackers(userId);
    if (trackers.isEmpty) return 0.0;

    double totalAccuracy = 0;
    for (final tracker in trackers) {
      totalAccuracy += tracker.accuracyRate;
    }
    final avgAccuracy = totalAccuracy / trackers.length;

    // 簡易的な準備度予測: 平均正答率 + トレンド
    final trend = _calculateAccuracyTrend(trackers);
    final readiness = (avgAccuracy * 0.7) + (trend * 0.3);

    return readiness.clamp(0.0, 1.0);
  }

  double _calculateAccuracyTrend(List<ProgressTracker> trackers) {
    // 最近のスコアが高いほど、トレンドはポジティブ
    double totalTrend = 0;
    int count = 0;

    for (final tracker in trackers) {
      if (tracker.lastFiveScores.isNotEmpty) {
        final scores = tracker.lastFiveScores;
        if (scores.length >= 2) {
          final recent = scores.sublist(scores.length - 2);
          final trend = recent.last > recent.first ? 0.1 : -0.05;
          totalTrend += trend;
          count++;
        }
      }
    }

    return count > 0 ? (totalTrend / count).clamp(-1.0, 1.0) : 0.0;
  }

  @override
  Future<int> calculateRecommendedStudyMinutes(String userId) async {
    final trackers = await getUserProgressTrackers(userId);
    int totalMinutes = 0;

    for (final tracker in trackers) {
      totalMinutes += tracker.recommendedStudyMinutes;
    }

    return totalMinutes.clamp(0, 180);
  }

  @override
  Future<StudyPlan> generatePersonalizedStudyPlan(String userId) async {
    final weakAreas = await getWeakAreasByPriority(userId: userId, limit: 5);
    final recommendedMinutes = await calculateRecommendedStudyMinutes(userId);

    final topics = weakAreas.map((wa) => wa.category).toList();
    final priority = {
      for (final wa in weakAreas)
        wa.category: wa.priorityScore
    };

    return StudyPlan(
      planId: 'sp_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      createdAt: DateTime.now(),
      topics: topics,
      priority: priority,
      recommendedTests: [],
      estimatedHours: (recommendedMinutes / 60).toDouble(),
      deadline: DateTime.now().add(Duration(days: 14)),
    );
  }

  // ============ Exam Readiness Prediction Implementation ============

  final Map<String, ExamReadinessPrediction> _readinessPredictions = {};
  final Map<String, List<DateTime>> _readinessTrendHistory = {};

  @override
  Future<ExamReadinessPrediction> predictExamReadiness(String userId) async {
    final trackers = await getUserProgressTrackers(userId);
    if (trackers.isEmpty) {
      return ExamReadinessPrediction(
        predictionId: 'erp_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        passProbability: 0.0,
        estimatedHoursNeeded: 0,
        predictedReadyDate: DateTime.now().add(Duration(days: 30)),
        criticalWeakAreas: [],
        recommendedFocusTopics: [],
        factors: ReadinessFactors.empty(),
        calculatedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    // Calculate overall readiness from all categories
    double totalProbability = 0;
    final criticalWeakAreas = <String>[];
    final focusTopics = <String>[];
    int totalHours = 0;

    for (final tracker in trackers) {
      final categoryFactors = await calculateReadinessFactors(
        userId: userId,
        category: tracker.category,
      );

      final categoryProbability = categoryFactors.compositeScore;
      totalProbability += categoryProbability;

      if (categoryProbability < 0.70) {
        criticalWeakAreas.add(tracker.category);
      }

      final timeEstimate = await estimateTimeToReadiness(
        userId: userId,
        category: tracker.category,
        targetAccuracyPercent: 85,
      );
      totalHours += timeEstimate.totalHoursNeeded;
      focusTopics.addAll(timeEstimate.milestones);
    }

    final avgProbability = totalProbability / trackers.length;
    final readyDate =
        DateTime.now().add(Duration(hours: totalHours));

    final prediction = ExamReadinessPrediction(
      predictionId: 'erp_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      passProbability: avgProbability.clamp(0.0, 1.0),
      estimatedHoursNeeded: totalHours.clamp(0, 180),
      predictedReadyDate: readyDate,
      criticalWeakAreas: criticalWeakAreas,
      recommendedFocusTopics: focusTopics.toSet().toList(),
      factors: ReadinessFactors(
        accuracyWeighting: _calculateCategoryAverage(
          trackers,
          (t) => t.accuracyRate,
        ),
        consistencyScore: _calculateConsistencyScore(trackers),
        trendScore: _calculateTrendScore(trackers),
        timeSpentScore: _calculateTimeSpentScore(trackers),
        weakAreaCoverageScore: 1.0 - (criticalWeakAreas.length / trackers.length),
      ),
      calculatedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _readinessPredictions[userId] = prediction;
    _recordReadinessTrend(userId, prediction.passProbability);

    return prediction;
  }

  @override
  Future<ExamReadinessPrediction> predictCategoryReadiness({
    required String userId,
    required String category,
  }) async {
    final tracker = await getProgressTracker(
      userId: userId,
      category: category,
    );

    if (tracker == null) {
      return ExamReadinessPrediction(
        predictionId: 'erp_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        passProbability: 0.0,
        estimatedHoursNeeded: 0,
        predictedReadyDate: DateTime.now(),
        criticalWeakAreas: [],
        recommendedFocusTopics: [],
        factors: ReadinessFactors.empty(),
        calculatedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final factors = await calculateReadinessFactors(
      userId: userId,
      category: category,
    );
    final timeEstimate = await estimateTimeToReadiness(
      userId: userId,
      category: category,
      targetAccuracyPercent: 85,
    );

    return ExamReadinessPrediction(
      predictionId: 'erp_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      passProbability: factors.compositeScore,
      estimatedHoursNeeded: timeEstimate.totalHoursNeeded,
      predictedReadyDate: timeEstimate.estimatedCompletionDate,
      criticalWeakAreas: tracker.accuracyPercentage < 70 ? [category] : [],
      recommendedFocusTopics: timeEstimate.milestones,
      factors: factors,
      calculatedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<ReadinessFactors> calculateReadinessFactors({
    required String userId,
    required String category,
  }) async {
    final tracker = await getProgressTracker(
      userId: userId,
      category: category,
    );

    if (tracker == null) {
      return ReadinessFactors.empty();
    }

    // 正答率の重み付け (40%)
    final accuracyWeighting = tracker.accuracyRate;

    // 連続正解率スコア (20%)
    final consistencyScore = tracker.consecutiveCorrect > 0
        ? (tracker.consecutiveCorrect / 10).clamp(0.0, 1.0)
        : 0.0;

    // トレンドスコア (20%)
    double trendScore = 0.0;
    if (tracker.lastFiveScores.length >= 2) {
      final recent = tracker.lastFiveScores.sublist(
          (tracker.lastFiveScores.length - 2).clamp(0, tracker.lastFiveScores.length));
      if (recent.isNotEmpty && recent.length >= 2) {
        trendScore = recent.last > recent.first ? 0.7 : 0.3;
      }
    }

    // 学習時間スコア (10%)
    final timeSpentScore = (tracker.minutesSpent / 120).clamp(0.0, 1.0);

    // 試行回数による信頼度スコア (10%)
    final weakAreaCoverageScore =
        (tracker.totalAttempts / 20).clamp(0.0, 1.0);

    return ReadinessFactors(
      accuracyWeighting: accuracyWeighting * 0.4,
      consistencyScore: consistencyScore * 0.2,
      trendScore: trendScore * 0.2,
      timeSpentScore: timeSpentScore * 0.1,
      weakAreaCoverageScore: weakAreaCoverageScore * 0.1,
    );
  }

  double _calculateCategoryAverage(
    List<ProgressTracker> trackers,
    double Function(ProgressTracker) getValue,
  ) {
    if (trackers.isEmpty) return 0.0;
    final sum = trackers.fold(0.0, (a, t) => a + getValue(t));
    return sum / trackers.length;
  }

  double _calculateConsistencyScore(List<ProgressTracker> trackers) {
    if (trackers.isEmpty) return 0.0;
    double totalConsistency = 0;
    for (final tracker in trackers) {
      if (tracker.totalAttempts > 0) {
        final consistency = tracker.consecutiveCorrect / tracker.totalAttempts;
        totalConsistency += consistency;
      }
    }
    return (totalConsistency / trackers.length).clamp(0.0, 1.0);
  }

  double _calculateTrendScore(List<ProgressTracker> trackers) {
    if (trackers.isEmpty) return 0.0;
    double positiveTrends = 0;

    for (final tracker in trackers) {
      if (tracker.lastFiveScores.length >= 2) {
        final recent = tracker.lastFiveScores;
        final recent2 = recent.sublist(
          (recent.length - 2).clamp(0, recent.length),
        );
        if (recent2.length >= 2 && recent2.last > recent2.first) {
          positiveTrends++;
        }
      }
    }

    return (positiveTrends / trackers.length).clamp(0.0, 1.0);
  }

  double _calculateTimeSpentScore(List<ProgressTracker> trackers) {
    if (trackers.isEmpty) return 0.0;
    double totalTime = 0;
    for (final tracker in trackers) {
      totalTime += tracker.minutesSpent;
    }
    return (totalTime / (trackers.length * 120)).clamp(0.0, 1.0);
  }

  @override
  Future<TimeToReadiness> estimateTimeToReadiness({
    required String userId,
    required String category,
    required int targetAccuracyPercent,
  }) async {
    final tracker = await getProgressTracker(
      userId: userId,
      category: category,
    );

    if (tracker == null) {
      return TimeToReadiness(
        estimateId: 'ttr_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        category: category,
        daysToTargetAccuracy: 30,
        recommendedDailyMinutes: 60,
        totalHoursNeeded: 30,
        estimatedCompletionDate: DateTime.now().add(Duration(days: 30)),
        milestones: ['基礎習得', '弱点克服', '本試験対策'],
        confidenceLevel: 'low',
        calculatedAt: DateTime.now(),
      );
    }

    final currentAccuracy = tracker.accuracyPercentage;
    final gap = (targetAccuracyPercent - currentAccuracy).abs();

    // 正答率の改善度から日数を推定
    int daysToTarget = 1;
    if (gap > 0) {
      // 1日で1%改善できると仮定
      daysToTarget = gap;
    }

    final dailyMinutes = _calculateRecommendedDailyMinutes(tracker);
    final totalHours = (daysToTarget * dailyMinutes) ~/ 60;

    final milestones = _generateMilestones(currentAccuracy, targetAccuracyPercent);
    final confidence =
        tracker.totalAttempts >= 10 ? 'high' : 'medium';

    return TimeToReadiness(
      estimateId: 'ttr_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      category: category,
      daysToTargetAccuracy: daysToTarget.clamp(1, 60),
      recommendedDailyMinutes: dailyMinutes.clamp(15, 120),
      totalHoursNeeded: totalHours.clamp(1, 180),
      estimatedCompletionDate:
          DateTime.now().add(Duration(days: daysToTarget)),
      milestones: milestones,
      confidenceLevel: confidence,
      calculatedAt: DateTime.now(),
    );
  }

  int _calculateRecommendedDailyMinutes(ProgressTracker tracker) {
    final gap = 85 - tracker.accuracyPercentage;
    if (gap <= 0) return 0;
    return (gap * 0.8).toInt().clamp(15, 120);
  }

  List<String> _generateMilestones(int current, int target) {
    final milestones = <String>[];
    if (current < 60) {
      milestones.add('基礎習得 (60%)');
    }
    if (current < 75) {
      milestones.add('弱点克服 (75%)');
    }
    if (current < target) {
      milestones.add('本試験対策 ($target%)');
    }
    return milestones.isNotEmpty
        ? milestones
        : ['維持・発展学習'];
  }

  @override
  Future<Map<String, ExamReadinessPrediction>>
      predictCategoryReadinessList(String userId) async {
    final trackers = await getUserProgressTrackers(userId);
    final result = <String, ExamReadinessPrediction>{};

    for (final tracker in trackers) {
      final prediction = await predictCategoryReadiness(
        userId: userId,
        category: tracker.category,
      );
      result[tracker.category] = prediction;
    }

    return result;
  }

  @override
  Future<void> updateReadinessPrediction({
    required String userId,
    required ExamReadinessPrediction prediction,
  }) async {
    _readinessPredictions[userId] = prediction;
  }

  @override
  Future<ExamReadinessPrediction?> getReadinessPrediction(
    String userId,
  ) async {
    return _readinessPredictions[userId];
  }

  void _recordReadinessTrend(String userId, double probability) {
    if (!_readinessTrendHistory.containsKey(userId)) {
      _readinessTrendHistory[userId] = [];
    }
    _readinessTrendHistory[userId]!.add(DateTime.now());

    // Keep only last 14 days
    final twoWeeksAgo = DateTime.now().subtract(Duration(days: 14));
    _readinessTrendHistory[userId]!
        .removeWhere((date) => date.isBefore(twoWeeksAgo));
  }

  @override
  Future<List<Map<String, dynamic>>> getReadinessTrend(
    String userId,
  ) async {
    final trend = _readinessTrendHistory[userId] ?? [];
    return trend.map((date) {
      return {
        'date': date.toIso8601String(),
        'timestamp': date.millisecondsSinceEpoch,
      };
    }).toList();
  }

  @override
  Future<bool> isPassProbableReady(String userId) async {
    final prediction = await predictExamReadiness(userId);
    return prediction.isPassReady;
  }

  // ============ Gamification & Achievement Implementation ============

  final Map<String, List<AchievementBadge>> _userBadges = {};
  final Map<String, StudyStreak> _userStreaks = {};
  final Map<String, AchievementStats> _achievementStats = {};
  final Map<String, RewardMultiplier> _rewardMultipliers = {};

  @override
  Future<void> earnBadge({
    required String userId,
    required BadgeType type,
    required String displayName,
    required String description,
    required BadgeRarityLevel rarity,
    required int points,
  }) async {
    final badge = AchievementBadge(
      badgeId: 'badge_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: type,
      displayName: displayName,
      description: description,
      iconUrl: _getIconForBadge(type),
      rarity: rarity,
      points: points,
      earnedAt: DateTime.now(),
    );

    if (!_userBadges.containsKey(userId)) {
      _userBadges[userId] = [];
    }
    _userBadges[userId]!.add(badge);

    // Update achievement stats
    if (_achievementStats.containsKey(userId)) {
      final stats = _achievementStats[userId]!;
      _achievementStats[userId] = AchievementStats(
        statsId: stats.statsId,
        userId: userId,
        totalBadgesEarned: stats.totalBadgesEarned + 1,
        totalPoints: stats.totalPoints + points,
        totalLevel: (stats.totalPoints + points) ~/ 1000 + 1,
        badges: [...stats.badges, badge],
        currentStreak: stats.currentStreak,
        perfectScoreSessions: stats.perfectScoreSessions,
        fastestTimeRecord: stats.fastestTimeRecord,
        createdAt: stats.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  String _getIconForBadge(BadgeType type) {
    const icons = {
      BadgeType.firstQuestion: '🎯',
      BadgeType.tenQuestions: '✅',
      BadgeType.fiftyQuestions: '🔟',
      BadgeType.hundredQuestions: '💯',
      BadgeType.fiveHundredQuestions: '🚀',
      BadgeType.threeStreak: '🔥',
      BadgeType.sevenStreak: '🌟',
      BadgeType.thirtyStreak: '⭐',
      BadgeType.hundredStreak: '👑',
      BadgeType.seventyPercent: '📈',
      BadgeType.eightyPercent: '📊',
      BadgeType.ninetyPercent: '📍',
      BadgeType.perfectScore: '💎',
      BadgeType.trafficRulesMastery: '🚗',
      BadgeType.crisisAvoidanceMastery: '⚠️',
      BadgeType.mechanicalKnowledgeMastery: '🔧',
      BadgeType.allCategoriesMastery: '🏆',
      BadgeType.dailyStudier: '📅',
      BadgeType.weeklyConsistent: '📆',
      BadgeType.monthlyDedicated: '🗓️',
      BadgeType.speedDemon: '⚡',
      BadgeType.nightOwl: '🌙',
      BadgeType.morningStudier: '🌅',
      BadgeType.weekendWarrior: '💪',
    };
    return icons[type] ?? '🏅';
  }

  @override
  Future<List<AchievementBadge>> getUserBadges(String userId) async {
    return _userBadges[userId] ?? [];
  }

  @override
  Future<AchievementBadge?> getBadge(String badgeId) async {
    for (final badges in _userBadges.values) {
      try {
        return badges.firstWhere((b) => b.badgeId == badgeId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  @override
  Future<void> toggleBadgePinned({
    required String badgeId,
    required bool isPinned,
  }) async {
    for (final userId in _userBadges.keys) {
      final badgeIndex = _userBadges[userId]!
          .indexWhere((b) => b.badgeId == badgeId);
      if (badgeIndex != -1) {
        final badge = _userBadges[userId]![badgeIndex];
        _userBadges[userId]![badgeIndex] = AchievementBadge(
          badgeId: badge.badgeId,
          userId: badge.userId,
          type: badge.type,
          displayName: badge.displayName,
          description: badge.description,
          iconUrl: badge.iconUrl,
          rarity: badge.rarity,
          points: badge.points,
          earnedAt: badge.earnedAt,
          level: badge.level,
          isPinned: isPinned,
        );
        break;
      }
    }
  }

  @override
  Future<void> updateStreak({
    required String userId,
    required bool studiedToday,
  }) async {
    final streak = _userStreaks[userId] ??
        StudyStreak.empty(streakId: 'ss_$userId', userId: userId);

    if (!studiedToday) {
      _userStreaks[userId] = StudyStreak(
        streakId: streak.streakId,
        userId: userId,
        currentStreak: 0,
        longestStreak: streak.longestStreak,
        lastStudyDate: streak.lastStudyDate,
        studyDates: streak.studyDates,
        totalDaysStudied: streak.totalDaysStudied,
        createdAt: streak.createdAt,
        updatedAt: DateTime.now(),
      );
      return;
    }

    final today = DateTime.now();
    final yesterday = today.subtract(Duration(days: 1));
    final isConsecutive = streak.lastStudyDate.year == yesterday.year &&
        streak.lastStudyDate.month == yesterday.month &&
        streak.lastStudyDate.day == yesterday.day;

    final newStreak = isConsecutive ? streak.currentStreak + 1 : 1;
    final newLongestStreak = newStreak > streak.longestStreak ? newStreak : streak.longestStreak;

    _userStreaks[userId] = StudyStreak(
      streakId: streak.streakId,
      userId: userId,
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastStudyDate: today,
      studyDates: [...streak.studyDates, today]
          .where((d) => d.isAfter(today.subtract(Duration(days: 90))))
          .toList(),
      totalDaysStudied: streak.totalDaysStudied + 1,
      createdAt: streak.createdAt,
      updatedAt: DateTime.now(),
    );

    // Check for streak badges
    if (newStreak == 3) {
      await earnBadge(
        userId: userId,
        type: BadgeType.threeStreak,
        displayName: '3連勝達成',
        description: '3日連続で学習した',
        rarity: BadgeRarityLevel.uncommon,
        points: 50,
      );
    } else if (newStreak == 7) {
      await earnBadge(
        userId: userId,
        type: BadgeType.sevenStreak,
        displayName: '1週間連勝',
        description: '7日連続で学習した',
        rarity: BadgeRarityLevel.rare,
        points: 150,
      );
    } else if (newStreak == 30) {
      await earnBadge(
        userId: userId,
        type: BadgeType.thirtyStreak,
        displayName: '1ヶ月チャレンジ',
        description: '30日連続で学習した',
        rarity: BadgeRarityLevel.epic,
        points: 500,
      );
    }
  }

  @override
  Future<StudyStreak?> getUserStreak(String userId) async {
    return _userStreaks[userId];
  }

  @override
  Future<void> resetStreak(String userId) async {
    final streak = _userStreaks[userId];
    if (streak != null) {
      _userStreaks[userId] = StudyStreak(
        streakId: streak.streakId,
        userId: userId,
        currentStreak: 0,
        longestStreak: streak.longestStreak,
        lastStudyDate: DateTime.now().subtract(Duration(days: 2)),
        studyDates: [],
        totalDaysStudied: streak.totalDaysStudied,
        createdAt: streak.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<AchievementStats?> getAchievementStats(String userId) async {
    return _achievementStats[userId];
  }

  @override
  Future<void> initializeAchievementStats(String userId) async {
    if (!_achievementStats.containsKey(userId)) {
      _achievementStats[userId] = AchievementStats.empty(
        statsId: 'as_$userId',
        userId: userId,
      );
      _userStreaks.putIfAbsent(
        userId,
        () => StudyStreak.empty(streakId: 'ss_$userId', userId: userId),
      );
      _rewardMultipliers[userId] = RewardMultiplier.empty(
        multiplierId: 'rm_$userId',
        userId: userId,
      );
    }
  }

  @override
  Future<RewardMultiplier?> getRewardMultiplier(String userId) async {
    return _rewardMultipliers[userId];
  }

  @override
  Future<void> setRewardMultiplier({
    required String userId,
    required double multiplier,
    required List<String> boosts,
    DateTime? expiresAt,
    required String reason,
  }) async {
    _rewardMultipliers[userId] = RewardMultiplier(
      multiplierId: 'rm_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      baseMultiplier: multiplier,
      activeBoosts: boosts,
      activatedAt: DateTime.now(),
      expiresAt: expiresAt,
      reason: reason,
    );
  }

  @override
  Future<int> awardXP({
    required String userId,
    required int baseXP,
  }) async {
    final multiplier = await getRewardMultiplier(userId);
    final effectiveMultiplier = multiplier?.effectiveMultiplier ?? 1.0;
    final totalXP = (baseXP * effectiveMultiplier).toInt();

    if (_achievementStats.containsKey(userId)) {
      final stats = _achievementStats[userId]!;
      final newTotal = stats.totalPoints + totalXP;
      _achievementStats[userId] = AchievementStats(
        statsId: stats.statsId,
        userId: userId,
        totalBadgesEarned: stats.totalBadgesEarned,
        totalPoints: newTotal,
        totalLevel: newTotal ~/ 1000 + 1,
        badges: stats.badges,
        currentStreak: stats.currentStreak,
        perfectScoreSessions: stats.perfectScoreSessions,
        fastestTimeRecord: stats.fastestTimeRecord,
        createdAt: stats.createdAt,
        updatedAt: DateTime.now(),
      );
    }

    return totalXP;
  }

  @override
  Future<void> recordPerfectScore(String userId) async {
    if (_achievementStats.containsKey(userId)) {
      final stats = _achievementStats[userId]!;
      _achievementStats[userId] = AchievementStats(
        statsId: stats.statsId,
        userId: userId,
        totalBadgesEarned: stats.totalBadgesEarned,
        totalPoints: stats.totalPoints,
        totalLevel: stats.totalLevel,
        badges: stats.badges,
        currentStreak: stats.currentStreak,
        perfectScoreSessions: stats.perfectScoreSessions + 1,
        fastestTimeRecord: stats.fastestTimeRecord,
        createdAt: stats.createdAt,
        updatedAt: DateTime.now(),
      );

      if (stats.perfectScoreSessions + 1 == 1) {
        await earnBadge(
          userId: userId,
          type: BadgeType.perfectScore,
          displayName: '満点達成',
          description: '100%の正答率でテストを完了した',
          rarity: BadgeRarityLevel.legendary,
          points: 300,
        );
      }
    }
  }

  @override
  Future<void> updateFastestTime({
    required String userId,
    required int timeInSeconds,
  }) async {
    if (_achievementStats.containsKey(userId)) {
      final stats = _achievementStats[userId]!;
      final newFastestTime = stats.fastestTimeRecord == 0
          ? timeInSeconds
          : timeInSeconds < stats.fastestTimeRecord
              ? timeInSeconds
              : stats.fastestTimeRecord;

      _achievementStats[userId] = AchievementStats(
        statsId: stats.statsId,
        userId: userId,
        totalBadgesEarned: stats.totalBadgesEarned,
        totalPoints: stats.totalPoints,
        totalLevel: stats.totalLevel,
        badges: stats.badges,
        currentStreak: stats.currentStreak,
        perfectScoreSessions: stats.perfectScoreSessions,
        fastestTimeRecord: newFastestTime,
        createdAt: stats.createdAt,
        updatedAt: DateTime.now(),
      );

      if (newFastestTime < 60) {
        await earnBadge(
          userId: userId,
          type: BadgeType.speedDemon,
          displayName: '速度の魔神',
          description: '全問を60秒以内に完了した',
          rarity: BadgeRarityLevel.rare,
          points: 200,
        );
      }
    }
  }

  @override
  Future<List<String>> checkMilestoneAchievements(String userId) async {
    final badges = await getUserBadges(userId);
    final earnedTypes = badges.map((b) => b.type).toSet();
    final trackers = await getUserProgressTrackers(userId);

    int totalQuestions = 0;
    for (final tracker in trackers) {
      totalQuestions += tracker.totalAttempts;
    }

    final achievements = <String>[];

    if (totalQuestions >= 10 && !earnedTypes.contains(BadgeType.tenQuestions)) {
      achievements.add('tenQuestions');
    }
    if (totalQuestions >= 50 && !earnedTypes.contains(BadgeType.fiftyQuestions)) {
      achievements.add('fiftyQuestions');
    }
    if (totalQuestions >= 100 && !earnedTypes.contains(BadgeType.hundredQuestions)) {
      achievements.add('hundredQuestions');
    }
    if (totalQuestions >= 500 && !earnedTypes.contains(BadgeType.fiveHundredQuestions)) {
      achievements.add('fiveHundredQuestions');
    }

    return achievements;
  }

  @override
  Future<int> getUserLevel(String userId) async {
    final stats = await getAchievementStats(userId);
    return stats?.totalLevel ?? 1;
  }

  @override
  Future<int> getUserTotalXP(String userId) async {
    final stats = await getAchievementStats(userId);
    return stats?.totalPoints ?? 0;
  }

  // ============ B2B Partnership Implementation ============

  final Map<String, PartnershipAgreement> _partnerships = {};
  final Map<String, InstitutionalLicense> _licenses = {};
  final Map<String, InstitutionalAnalytics> _analytics = {};
  final Map<String, PartnershipBilling> _billingRecords = {};

  @override
  Future<String> createPartnership({
    required String schoolName,
    required String contactEmail,
    required PartnershipTier tier,
    required int maxStudents,
  }) async {
    final partnerId = 'partner_${DateTime.now().millisecondsSinceEpoch}';

    int annualCost = 0;
    int maxSeats = 0;

    switch (tier) {
      case PartnershipTier.starter:
        annualCost = 300000; // 30万円
        maxSeats = 50;
        break;
      case PartnershipTier.professional:
        annualCost = 800000; // 80万円
        maxSeats = 200;
        break;
      case PartnershipTier.enterprise:
        annualCost = 2000000; // 200万円
        maxSeats = 1000;
        break;
    }

    final partnership = PartnershipAgreement(
      partnershipId: partnerId,
      schoolId: 'school_${DateTime.now().millisecondsSinceEpoch}',
      schoolName: schoolName,
      contactEmail: contactEmail,
      status: PartnershipStatus.pending,
      tier: tier,
      maxStudents: maxSeats,
      currentStudents: 0,
      startDate: DateTime.now(),
      expiryDate: DateTime.now().add(Duration(days: 365)),
      annualCostJPY: annualCost,
      isCustomBrandingAllowed: tier != PartnershipTier.starter,
      isPrivateContentAllowed: tier == PartnershipTier.enterprise,
      authorizedInstructors: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _partnerships[partnerId] = partnership;
    return partnerId;
  }

  @override
  Future<PartnershipAgreement?> getPartnership(String partnershipId) async {
    return _partnerships[partnershipId];
  }

  @override
  Future<void> updatePartnership({
    required String partnershipId,
    required PartnershipAgreement agreement,
  }) async {
    _partnerships[partnershipId] = agreement;
  }

  @override
  Future<List<PartnershipAgreement>> getAllPartnerships() async {
    return _partnerships.values.toList();
  }

  @override
  Future<List<PartnershipAgreement>> getActivePartnerships() async {
    return _partnerships.values
        .where((p) => p.isActive)
        .toList();
  }

  @override
  Future<void> suspendPartnership(String partnershipId) async {
    final partnership = _partnerships[partnershipId];
    if (partnership != null) {
      _partnerships[partnershipId] = PartnershipAgreement(
        partnershipId: partnership.partnershipId,
        schoolId: partnership.schoolId,
        schoolName: partnership.schoolName,
        contactEmail: partnership.contactEmail,
        status: PartnershipStatus.suspended,
        tier: partnership.tier,
        maxStudents: partnership.maxStudents,
        currentStudents: partnership.currentStudents,
        startDate: partnership.startDate,
        expiryDate: partnership.expiryDate,
        annualCostJPY: partnership.annualCostJPY,
        isCustomBrandingAllowed: partnership.isCustomBrandingAllowed,
        isPrivateContentAllowed: partnership.isPrivateContentAllowed,
        authorizedInstructors: partnership.authorizedInstructors,
        createdAt: partnership.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> resumePartnership(String partnershipId) async {
    final partnership = _partnerships[partnershipId];
    if (partnership != null) {
      _partnerships[partnershipId] = PartnershipAgreement(
        partnershipId: partnership.partnershipId,
        schoolId: partnership.schoolId,
        schoolName: partnership.schoolName,
        contactEmail: partnership.contactEmail,
        status: PartnershipStatus.active,
        tier: partnership.tier,
        maxStudents: partnership.maxStudents,
        currentStudents: partnership.currentStudents,
        startDate: partnership.startDate,
        expiryDate: partnership.expiryDate,
        annualCostJPY: partnership.annualCostJPY,
        isCustomBrandingAllowed: partnership.isCustomBrandingAllowed,
        isPrivateContentAllowed: partnership.isPrivateContentAllowed,
        authorizedInstructors: partnership.authorizedInstructors,
        createdAt: partnership.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<String> issueLicense({
    required String partnershipId,
    required String userId,
    required String userName,
    required LicenseType type,
  }) async {
    final licenseId = 'lic_${DateTime.now().millisecondsSinceEpoch}';

    final license = InstitutionalLicense(
      licenseId: licenseId,
      partnershipId: partnershipId,
      userId: userId,
      userName: userName,
      type: type,
      issuedAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: 365)),
      isActive: true,
      loginCount: 0,
      permissions: _getDefaultPermissions(type),
    );

    _licenses[licenseId] = license;

    // Consume seat if student
    if (type == LicenseType.studentAccess) {
      await consumeSeat(partnershipId);
    }

    return licenseId;
  }

  Map<String, dynamic> _getDefaultPermissions(LicenseType type) {
    switch (type) {
      case LicenseType.studentAccess:
        return {
          'canTakePracticeTests': true,
          'canViewAnalytics': false,
          'canManageUsers': false,
        };
      case LicenseType.instructorAccess:
        return {
          'canTakePracticeTests': true,
          'canViewAnalytics': true,
          'canManageUsers': false,
          'canCreateCustomContent': true,
        };
      case LicenseType.administratorAccess:
        return {
          'canTakePracticeTests': true,
          'canViewAnalytics': true,
          'canManageUsers': true,
          'canCreateCustomContent': true,
          'canManageBilling': true,
        };
    }
  }

  @override
  Future<InstitutionalLicense?> getLicense(String licenseId) async {
    return _licenses[licenseId];
  }

  @override
  Future<List<InstitutionalLicense>> getPartnershipLicenses(String partnershipId) async {
    return _licenses.values
        .where((l) => l.partnershipId == partnershipId)
        .toList();
  }

  @override
  Future<void> revokeLicense(String licenseId) async {
    final license = _licenses[licenseId];
    if (license != null) {
      _licenses[licenseId] = InstitutionalLicense(
        licenseId: license.licenseId,
        partnershipId: license.partnershipId,
        userId: license.userId,
        userName: license.userName,
        type: license.type,
        issuedAt: license.issuedAt,
        expiresAt: license.expiresAt,
        isActive: false,
        loginCount: license.loginCount,
        lastLoginAt: license.lastLoginAt,
        permissions: license.permissions,
      );

      // Release seat if student
      if (license.type == LicenseType.studentAccess) {
        await releaseSeat(license.partnershipId);
      }
    }
  }

  @override
  Future<void> updateLicense({
    required String licenseId,
    required InstitutionalLicense license,
  }) async {
    _licenses[licenseId] = license;
  }

  @override
  Future<InstitutionalAnalytics> generateInstitutionalAnalytics({
    required String partnershipId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final partnership = _partnerships[partnershipId];
    if (partnership == null) {
      return InstitutionalAnalytics.empty(
        analyticsId: 'ia_${DateTime.now().millisecondsSinceEpoch}',
        partnershipId: partnershipId,
      );
    }

    final licenses = _licenses.values
        .where((l) => l.partnershipId == partnershipId && l.type == LicenseType.studentAccess)
        .toList();

    int activeStudents = 0;
    double totalAccuracy = 0;
    int totalAttempts = 0;

    for (final license in licenses) {
      final trackers = await getUserProgressTrackers(license.userId);
      if (trackers.isNotEmpty) {
        activeStudents++;
        for (final tracker in trackers) {
          totalAttempts += tracker.totalAttempts;
          totalAccuracy += tracker.accuracyRate;
        }
      }
    }

    final avgAccuracy = licenses.isNotEmpty && totalAttempts > 0
        ? totalAccuracy / trackers.length
        : 0.0;

    final analytics = InstitutionalAnalytics(
      analyticsId: 'ia_${DateTime.now().millisecondsSinceEpoch}',
      partnershipId: partnershipId,
      totalStudentsEnrolled: partnership.currentStudents,
      activeStudents: activeStudents,
      averageCompletionRate: avgAccuracy,
      averageExamReadiness: avgAccuracy,
      totalQuestionsAnswered: totalAttempts,
      averageHoursPerStudent: activeStudents > 0 ? (totalAttempts ~/ activeStudents) : 0,
      topPerformingStudents: [],
      categoryPerformance: {},
      startDate: startDate,
      endDate: endDate,
      generatedAt: DateTime.now(),
    );

    _analytics[analytics.analyticsId] = analytics;
    return analytics;
  }

  @override
  Future<InstitutionalAnalytics?> getInstitutionalAnalytics(String analyticsId) async {
    return _analytics[analyticsId];
  }

  @override
  Future<Map<String, dynamic>> getStudentPerformanceSummary({
    required String partnershipId,
    required String userId,
  }) async {
    final trackers = await getUserProgressTrackers(userId);
    final prediction = await predictExamReadiness(userId);

    return {
      'userId': userId,
      'categoriesStudied': trackers.map((t) => t.category).toList(),
      'overallAccuracy': trackers.isNotEmpty
          ? (trackers.fold(0, (sum, t) => sum + t.correctCount) /
                  trackers.fold(0, (sum, t) => sum + t.totalAttempts))
              .toString()
          : '0',
      'passProbability': prediction.passProbability,
      'readyForExam': prediction.isPassReady,
      'estimatedHoursNeeded': prediction.estimatedHoursNeeded,
    };
  }

  @override
  Future<PartnershipBilling> generateBilling({
    required String partnershipId,
    required DateTime billingPeriodStart,
    required DateTime billingPeriodEnd,
  }) async {
    final partnership = _partnerships[partnershipId];
    if (partnership == null) {
      return PartnershipBilling.empty(
        billingId: 'bill_${DateTime.now().millisecondsSinceEpoch}',
        partnershipId: partnershipId,
      );
    }

    final billing = PartnershipBilling(
      billingId: 'bill_${DateTime.now().millisecondsSinceEpoch}',
      partnershipId: partnershipId,
      basePlanCostJPY: partnership.annualCostJPY,
      additionalSeatsJPY: partnership.currentStudents > partnership.maxStudents
          ? (partnership.currentStudents - partnership.maxStudents) * 1000
          : 0,
      totalStudentsInBillingPeriod: partnership.currentStudents,
      totalCostJPY: partnership.annualCostJPY,
      billingPeriodStart: billingPeriodStart,
      billingPeriodEnd: billingPeriodEnd,
      isPaid: false,
      invoiceUrl: 'https://example.com/invoices/bill_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    _billingRecords[billing.billingId] = billing;
    return billing;
  }

  @override
  Future<PartnershipBilling?> getBilling(String billingId) async {
    return _billingRecords[billingId];
  }

  @override
  Future<List<PartnershipBilling>> getPartnershipBillingHistory(String partnershipId) async {
    return _billingRecords.values
        .where((b) => b.partnershipId == partnershipId)
        .toList();
  }

  @override
  Future<void> confirmPayment({
    required String billingId,
    required DateTime paidAt,
  }) async {
    final billing = _billingRecords[billingId];
    if (billing != null) {
      _billingRecords[billingId] = PartnershipBilling(
        billingId: billing.billingId,
        partnershipId: billing.partnershipId,
        basePlanCostJPY: billing.basePlanCostJPY,
        additionalSeatsJPY: billing.additionalSeatsJPY,
        totalStudentsInBillingPeriod: billing.totalStudentsInBillingPeriod,
        totalCostJPY: billing.totalCostJPY,
        billingPeriodStart: billing.billingPeriodStart,
        billingPeriodEnd: billing.billingPeriodEnd,
        isPaid: true,
        paidAt: paidAt,
        invoiceUrl: billing.invoiceUrl,
      );
    }
  }

  @override
  Future<void> consumeSeat(String partnershipId) async {
    final partnership = _partnerships[partnershipId];
    if (partnership != null) {
      _partnerships[partnershipId] = PartnershipAgreement(
        partnershipId: partnership.partnershipId,
        schoolId: partnership.schoolId,
        schoolName: partnership.schoolName,
        contactEmail: partnership.contactEmail,
        status: partnership.status,
        tier: partnership.tier,
        maxStudents: partnership.maxStudents,
        currentStudents: partnership.currentStudents + 1,
        startDate: partnership.startDate,
        expiryDate: partnership.expiryDate,
        annualCostJPY: partnership.annualCostJPY,
        isCustomBrandingAllowed: partnership.isCustomBrandingAllowed,
        isPrivateContentAllowed: partnership.isPrivateContentAllowed,
        authorizedInstructors: partnership.authorizedInstructors,
        createdAt: partnership.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> releaseSeat(String partnershipId) async {
    final partnership = _partnerships[partnershipId];
    if (partnership != null && partnership.currentStudents > 0) {
      _partnerships[partnershipId] = PartnershipAgreement(
        partnershipId: partnership.partnershipId,
        schoolId: partnership.schoolId,
        schoolName: partnership.schoolName,
        contactEmail: partnership.contactEmail,
        status: partnership.status,
        tier: partnership.tier,
        maxStudents: partnership.maxStudents,
        currentStudents: partnership.currentStudents - 1,
        startDate: partnership.startDate,
        expiryDate: partnership.expiryDate,
        annualCostJPY: partnership.annualCostJPY,
        isCustomBrandingAllowed: partnership.isCustomBrandingAllowed,
        isPrivateContentAllowed: partnership.isPrivateContentAllowed,
        authorizedInstructors: partnership.authorizedInstructors,
        createdAt: partnership.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<Map<String, int>> getSeatUsage(String partnershipId) async {
    final partnership = _partnerships[partnershipId];
    if (partnership == null) {
      return {'used': 0, 'available': 0, 'total': 0};
    }

    return {
      'used': partnership.currentStudents,
      'available': partnership.remainingSeats,
      'total': partnership.maxStudents,
    };
  }

  @override
  Future<void> purchaseAdditionalSeats({
    required String partnershipId,
    required int numSeats,
  }) async {
    final partnership = _partnerships[partnershipId];
    if (partnership != null) {
      _partnerships[partnershipId] = PartnershipAgreement(
        partnershipId: partnership.partnershipId,
        schoolId: partnership.schoolId,
        schoolName: partnership.schoolName,
        contactEmail: partnership.contactEmail,
        status: partnership.status,
        tier: partnership.tier,
        maxStudents: partnership.maxStudents + numSeats,
        currentStudents: partnership.currentStudents,
        startDate: partnership.startDate,
        expiryDate: partnership.expiryDate,
        annualCostJPY: partnership.annualCostJPY + (numSeats * 60000),
        isCustomBrandingAllowed: partnership.isCustomBrandingAllowed,
        isPrivateContentAllowed: partnership.isPrivateContentAllowed,
        authorizedInstructors: partnership.authorizedInstructors,
        createdAt: partnership.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  // ============ Admin Dashboard Methods ============

  @override
  Future<InstructorDashboard?> generateInstructorDashboard({
    required String instructorId,
    required String partnershipId,
  }) async {
    final assignedStudents = _instructorStudentAssignments[instructorId] ?? [];
    final studentSnapshots = <StudentProgressWidget>[];
    final categoryBreakdown = <String, CategoryPerformanceChart>{};

    double totalAccuracy = 0.0;
    double totalReadiness = 0.0;

    for (final studentId in assignedStudents) {
      final progress = _studentProgressWidgets[studentId];
      if (progress != null) {
        studentSnapshots.add(progress);
        totalAccuracy += progress.overallAccuracy;
        totalReadiness += progress.readinessProbability;
      }
    }

    final classSize = assignedStudents.length;
    final classAverageAccuracy = classSize > 0 ? totalAccuracy / classSize : 0.0;
    final classAverageReadiness = classSize > 0 ? totalReadiness / classSize : 0.0;

    final widgets = [
      DashboardWidget(
        widgetId: 'w_accuracy_${instructorId}',
        title: 'Class Average Accuracy',
        description: 'Current class average accuracy rate',
        metricType: DashboardMetricType.performance,
        currentValue: (classAverageAccuracy * 100).toStringAsFixed(1) + '%',
        trend: 'up',
      ),
      DashboardWidget(
        widgetId: 'w_readiness_${instructorId}',
        title: 'Average Readiness',
        description: 'Predicted pass probability',
        metricType: DashboardMetricType.performance,
        currentValue: (classAverageReadiness * 100).toStringAsFixed(1) + '%',
        trend: 'up',
      ),
      DashboardWidget(
        widgetId: 'w_active_${instructorId}',
        title: 'Active This Week',
        description: 'Students who studied this week',
        metricType: DashboardMetricType.engagement,
        currentValue: studentSnapshots.where((s) => s.isActive).length.toString(),
      ),
    ];

    final dashboard = InstructorDashboard(
      dashboardId: 'dashboard_${instructorId}',
      instructorId: instructorId,
      partnershipId: partnershipId,
      instructorName: 'Instructor $instructorId',
      assignedStudentIds: assignedStudents,
      widgets: widgets,
      studentSnapshots: studentSnapshots,
      categoryBreakdown: categoryBreakdown,
      totalStudentsAssigned: classSize,
      activeStudentsThisWeek: studentSnapshots.where((s) => s.isActive).length,
      classAverageAccuracy: classAverageAccuracy,
      classAverageReadiness: classAverageReadiness,
      generatedAt: DateTime.now(),
    );

    _instructorDashboards[instructorId] = dashboard;
    return dashboard;
  }

  @override
  Future<InstructorDashboard?> getInstructorDashboard(String instructorId) async {
    return _instructorDashboards[instructorId];
  }

  @override
  Future<AdminDashboard?> generateAdminDashboard({
    required String partnershipId,
  }) async {
    final partnership = _partnerships[partnershipId];
    if (partnership == null) return null;

    final allStudents = <String>[];
    for (final assignment in _instructorStudentAssignments.values) {
      allStudents.addAll(assignment);
    }

    final studentSnapshots = <StudentProgressWidget>[];
    double totalAccuracy = 0.0;
    double totalReadiness = 0.0;
    int activeStudents = 0;

    for (final studentId in allStudents) {
      final progress = _studentProgressWidgets[studentId];
      if (progress != null) {
        studentSnapshots.add(progress);
        totalAccuracy += progress.overallAccuracy;
        totalReadiness += progress.readinessProbability;
        if (progress.isActive) activeStudents++;
      }
    }

    final studentCount = allStudents.length;
    final avgAccuracy = studentCount > 0 ? totalAccuracy / studentCount : 0.0;
    final avgReadiness = studentCount > 0 ? totalReadiness / studentCount : 0.0;

    final topPerformers = studentSnapshots
      .where((s) => s.status == StudentPerformanceStatus.excellent ||
                   s.status == StudentPerformanceStatus.good)
      .take(10)
      .toList();

    final atRiskStudents = studentSnapshots
      .where((s) => s.status == StudentPerformanceStatus.atRisk ||
                   s.status == StudentPerformanceStatus.critical)
      .toList();

    final widgets = [
      DashboardWidget(
        widgetId: 'w_revenue',
        title: 'Monthly Revenue',
        description: 'Projected revenue from this partnership',
        metricType: DashboardMetricType.revenue,
        currentValue: '¥${(partnership.annualCostJPY / 12).toStringAsFixed(0)}',
      ),
      DashboardWidget(
        widgetId: 'w_utilization',
        title: 'Seat Utilization',
        description: 'Percentage of available seats used',
        metricType: DashboardMetricType.engagement,
        currentValue: partnership.utilizationPercent.toStringAsFixed(1) + '%',
      ),
      DashboardWidget(
        widgetId: 'w_completion',
        title: 'Completion Rate',
        description: 'Students completing exams',
        metricType: DashboardMetricType.completion,
        currentValue: (avgAccuracy * 100).toStringAsFixed(1) + '%',
      ),
    ];

    final dashboard = AdminDashboard(
      dashboardId: 'admin_dashboard_$partnershipId',
      partnershipId: partnershipId,
      schoolName: partnership.schoolName,
      widgets: widgets,
      financialMetrics: {
        'annualCostJPY': partnership.annualCostJPY,
        'monthlyCost': partnership.annualCostJPY / 12,
        'costPerSeat': partnership.annualCostJPY / partnership.maxStudents,
      },
      topPerformers: topPerformers,
      atRiskStudents: atRiskStudents,
      schoolWideCategoryPerformance: {},
      totalEnrolledStudents: studentCount,
      activeStudentsThisMonth: activeStudents,
      overallCompletionRate: avgAccuracy,
      overallReadinessProbability: avgReadiness,
      monthlyRevenueJPY: partnership.annualCostJPY / 12,
      seatUtilizationPercent: partnership.utilizationPercent,
      recentInstructorActivity: [],
      generatedAt: DateTime.now(),
    );

    _adminDashboards[partnershipId] = dashboard;
    return dashboard;
  }

  @override
  Future<AdminDashboard?> getAdminDashboard(String partnershipId) async {
    return _adminDashboards[partnershipId];
  }

  @override
  Future<StudentProgressWidget?> getStudentProgressWidget({
    required String studentId,
    required String partnershipId,
  }) async {
    return _studentProgressWidgets[studentId];
  }

  @override
  Future<List<StudentProgressWidget>> getClassStudentProgress({
    required String instructorId,
    required String partnershipId,
  }) async {
    final studentIds = _instructorStudentAssignments[instructorId] ?? [];
    return studentIds
      .map((id) => _studentProgressWidgets[id])
      .whereType<StudentProgressWidget>()
      .toList();
  }

  @override
  Future<StudentEngagementMetrics?> getStudentEngagementMetrics(String studentId) async {
    return _studentEngagement[studentId];
  }

  @override
  Future<List<StudentProgressWidget>> getAtRiskStudents({
    required String partnershipId,
  }) async {
    return _studentProgressWidgets.values
      .where((s) => s.status == StudentPerformanceStatus.atRisk ||
                   s.status == StudentPerformanceStatus.critical)
      .toList();
  }

  @override
  Future<List<StudentProgressWidget>> getTopPerformers({
    required String partnershipId,
    int limit = 10,
  }) async {
    return _studentProgressWidgets.values
      .where((s) => s.status == StudentPerformanceStatus.excellent ||
                   s.status == StudentPerformanceStatus.good)
      .take(limit)
      .toList();
  }

  @override
  Future<Map<String, CategoryPerformanceChart>> getCategoryPerformance({
    required String partnershipId,
  }) async {
    return {
      '交通規則': CategoryPerformanceChart(
        category: '交通規則',
        accuracy: 0.82,
        questionsAnswered: 1200,
        trend: 0.05,
        averageTimePerQuestion: 45.0,
      ),
      '危機回避': CategoryPerformanceChart(
        category: '危機回避',
        accuracy: 0.75,
        questionsAnswered: 800,
        trend: 0.08,
        averageTimePerQuestion: 60.0,
      ),
      '機械知識': CategoryPerformanceChart(
        category: '機械知識',
        accuracy: 0.79,
        questionsAnswered: 900,
        trend: 0.03,
        averageTimePerQuestion: 50.0,
      ),
    };
  }

  @override
  Future<String> generateCustomReport({
    required String partnershipId,
    required String reportName,
    required ReportType reportType,
    required Map<String, dynamic> filters,
  }) async {
    final reportId = 'report_${DateTime.now().millisecondsSinceEpoch}';
    _reports[reportId] = CustomReport(
      reportId: reportId,
      partnershipId: partnershipId,
      reportName: reportName,
      reportType: reportType,
      generatedAt: DateTime.now(),
      reportData: filters,
      fileFormat: 'pdf',
    );
    return reportId;
  }

  @override
  Future<CustomReport?> getCustomReport(String reportId) async {
    return _reports[reportId];
  }

  @override
  Future<List<CustomReport>> getPartnershipReports({
    required String partnershipId,
  }) async {
    return _reports.values
      .where((r) => r.partnershipId == partnershipId)
      .toList();
  }

  @override
  Future<String?> exportReport({
    required String reportId,
    required String format,
  }) async {
    final report = _reports[reportId];
    if (report == null) return null;
    return 'https://storage.example.com/reports/$reportId.$format';
  }

  @override
  Future<List<String>> getAssignedStudents(String instructorId) async {
    return _instructorStudentAssignments[instructorId] ?? [];
  }

  @override
  Future<void> updateDashboardWidget({
    required String dashboardId,
    required DashboardWidget widget,
  }) async {
    // In stub implementation, dashboard widgets are rebuilt on demand
  }

  @override
  Future<void> refreshInstitutionalMetrics(String partnershipId) async {
    // In stub implementation, metrics are calculated on demand
  }

  // ============ Content Management Methods ============

  @override
  Future<String> createInstitutionalQuestion({
    required String partnershipId,
    required String createdByUserId,
    required String questionText,
    required QuestionType type,
    required QuestionDifficulty difficulty,
    required String category,
    String? subcategory,
    required List<String> answerOptions,
    required String correctAnswer,
    String? explanation,
    List<String>? keywords,
    required ContentAccessLevel accessLevel,
  }) async {
    final questionId = 'iq_${_institutionalQuestions.length}_${DateTime.now().millisecondsSinceEpoch}';
    _institutionalQuestions[questionId] = InstitutionalQuestion(
      questionId: questionId,
      partnershipId: partnershipId,
      createdByUserId: createdByUserId,
      questionText: questionText,
      type: type,
      difficulty: difficulty,
      category: category,
      subcategory: subcategory,
      answerOptions: answerOptions,
      correctAnswer: correctAnswer,
      explanation: explanation,
      keywords: keywords,
      status: ContentStatus.draft,
      accessLevel: accessLevel,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return questionId;
  }

  @override
  Future<InstitutionalQuestion?> getInstitutionalQuestion(String questionId) async {
    return _institutionalQuestions[questionId];
  }

  @override
  Future<List<InstitutionalQuestion>> getPartnershipQuestions({
    required String partnershipId,
    String? category,
    QuestionDifficulty? difficulty,
    int limit = 50,
  }) async {
    var questions = _institutionalQuestions.values
      .where((q) => q.partnershipId == partnershipId);

    if (category != null) {
      questions = questions.where((q) => q.category == category);
    }
    if (difficulty != null) {
      questions = questions.where((q) => q.difficulty == difficulty);
    }

    return questions.take(limit).toList();
  }

  @override
  Future<void> publishQuestion(String questionId) async {
    final question = _institutionalQuestions[questionId];
    if (question != null) {
      _institutionalQuestions[questionId] = InstitutionalQuestion(
        questionId: question.questionId,
        partnershipId: question.partnershipId,
        createdByUserId: question.createdByUserId,
        questionText: question.questionText,
        type: question.type,
        difficulty: question.difficulty,
        category: question.category,
        subcategory: question.subcategory,
        answerOptions: question.answerOptions,
        correctAnswer: question.correctAnswer,
        explanation: question.explanation,
        keywords: question.keywords,
        status: ContentStatus.published,
        accessLevel: question.accessLevel,
        usageCount: question.usageCount,
        averageTimeSpent: question.averageTimeSpent,
        averageAccuracy: question.averageAccuracy,
        reviewedAt: question.reviewedAt,
        reviewedByUserId: question.reviewedByUserId,
        reviewNotes: question.reviewNotes,
        createdAt: question.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> approveQuestion({
    required String questionId,
    required String reviewedByUserId,
    String? reviewNotes,
  }) async {
    final question = _institutionalQuestions[questionId];
    if (question != null) {
      _institutionalQuestions[questionId] = InstitutionalQuestion(
        questionId: question.questionId,
        partnershipId: question.partnershipId,
        createdByUserId: question.createdByUserId,
        questionText: question.questionText,
        type: question.type,
        difficulty: question.difficulty,
        category: question.category,
        subcategory: question.subcategory,
        answerOptions: question.answerOptions,
        correctAnswer: question.correctAnswer,
        explanation: question.explanation,
        keywords: question.keywords,
        status: ContentStatus.published,
        accessLevel: question.accessLevel,
        usageCount: question.usageCount,
        averageTimeSpent: question.averageTimeSpent,
        averageAccuracy: question.averageAccuracy,
        reviewedAt: DateTime.now(),
        reviewedByUserId: reviewedByUserId,
        reviewNotes: reviewNotes,
        createdAt: question.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<String> createQuestionBank({
    required String partnershipId,
    required String bankName,
    required String description,
  }) async {
    final bankId = 'qb_${_questionBanks.length}';
    _questionBanks[bankId] = InstitutionalQuestionBank(
      bankId: bankId,
      partnershipId: partnershipId,
      bankName: bankName,
      description: description,
      totalQuestions: 0,
      questionsByDifficulty: {},
      questionsByCategory: {},
      creatorIds: [],
      status: ContentStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return bankId;
  }

  @override
  Future<InstitutionalQuestionBank?> getQuestionBank(String bankId) async {
    return _questionBanks[bankId];
  }

  @override
  Future<List<InstitutionalQuestionBank>> getPartnershipQuestionBanks(
    String partnershipId,
  ) async {
    return _questionBanks.values
      .where((b) => b.partnershipId == partnershipId)
      .toList();
  }

  @override
  Future<String> createCourse({
    required String partnershipId,
    required String courseName,
    required String description,
    required List<String> topicIds,
    required int totalLessons,
    required int estimatedHours,
    required String instructorId,
    required ContentAccessLevel accessLevel,
  }) async {
    final courseId = 'course_${_courses.length}';
    _courses[courseId] = Course(
      courseId: courseId,
      partnershipId: partnershipId,
      courseName: courseName,
      description: description,
      topicIds: topicIds,
      questionIds: [],
      totalLessons: totalLessons,
      estimatedHours: estimatedHours,
      status: CourseStatus.draft,
      instructorId: instructorId,
      accessLevel: accessLevel,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return courseId;
  }

  @override
  Future<Course?> getCourse(String courseId) async {
    return _courses[courseId];
  }

  @override
  Future<List<Course>> getPartnershipCourses(String partnershipId) async {
    return _courses.values
      .where((c) => c.partnershipId == partnershipId)
      .toList();
  }

  @override
  Future<void> publishCourse(String courseId) async {
    final course = _courses[courseId];
    if (course != null) {
      _courses[courseId] = Course(
        courseId: course.courseId,
        partnershipId: course.partnershipId,
        courseName: course.courseName,
        description: course.description,
        topicIds: course.topicIds,
        questionIds: course.questionIds,
        totalLessons: course.totalLessons,
        estimatedHours: course.estimatedHours,
        status: CourseStatus.active,
        instructorId: course.instructorId,
        accessLevel: course.accessLevel,
        enrolledStudents: course.enrolledStudents,
        averageCompletion: course.averageCompletion,
        averageScore: course.averageScore,
        createdAt: course.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> addQuestionToCourse({
    required String courseId,
    required String questionId,
  }) async {
    final course = _courses[courseId];
    if (course != null && !course.questionIds.contains(questionId)) {
      final updatedQuestions = [...course.questionIds, questionId];
      _courses[courseId] = Course(
        courseId: course.courseId,
        partnershipId: course.partnershipId,
        courseName: course.courseName,
        description: course.description,
        topicIds: course.topicIds,
        questionIds: updatedQuestions,
        totalLessons: course.totalLessons,
        estimatedHours: course.estimatedHours,
        status: course.status,
        instructorId: course.instructorId,
        accessLevel: course.accessLevel,
        enrolledStudents: course.enrolledStudents,
        averageCompletion: course.averageCompletion,
        averageScore: course.averageScore,
        createdAt: course.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<String> createCurriculum({
    required String partnershipId,
    required String curriculumName,
    required String description,
    required CurriculumType type,
    required List<String> courseIds,
    required int totalHours,
    required int targetLevel,
    String? targetExamType,
  }) async {
    final curriculumId = 'curr_${_curricula.length}';
    _curricula[curriculumId] = Curriculum(
      curriculumId: curriculumId,
      partnershipId: partnershipId,
      curriculumName: curriculumName,
      description: description,
      type: type,
      courseIds: courseIds,
      totalHours: totalHours,
      targetLevel: targetLevel,
      targetExamType: targetExamType,
      status: ContentStatus.draft,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return curriculumId;
  }

  @override
  Future<Curriculum?> getCurriculum(String curriculumId) async {
    return _curricula[curriculumId];
  }

  @override
  Future<List<Curriculum>> getPartnershipCurricula(String partnershipId) async {
    return _curricula.values
      .where((c) => c.partnershipId == partnershipId)
      .toList();
  }

  @override
  Future<void> publishCurriculum(String curriculumId) async {
    final curriculum = _curricula[curriculumId];
    if (curriculum != null) {
      _curricula[curriculumId] = Curriculum(
        curriculumId: curriculum.curriculumId,
        partnershipId: curriculum.partnershipId,
        curriculumName: curriculum.curriculumName,
        description: curriculum.description,
        type: curriculum.type,
        courseIds: curriculum.courseIds,
        totalHours: curriculum.totalHours,
        targetLevel: curriculum.targetLevel,
        targetExamType: curriculum.targetExamType,
        status: ContentStatus.published,
        enrolledStudents: curriculum.enrolledStudents,
        completionRate: curriculum.completionRate,
        passProbability: curriculum.passProbability,
        createdAt: curriculum.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<String> enrollInCourse({
    required String courseId,
    required String studentId,
    required String partnershipId,
  }) async {
    final enrollmentId = 'enr_${_enrollments.length}';
    _enrollments[enrollmentId] = CourseEnrollment(
      enrollmentId: enrollmentId,
      courseId: courseId,
      studentId: studentId,
      partnershipId: partnershipId,
      enrolledAt: DateTime.now(),
      completionPercentage: 0.0,
      currentScore: 0.0,
      lessonsCompleted: 0,
    );
    return enrollmentId;
  }

  @override
  Future<CourseEnrollment?> getCourseEnrollment(String enrollmentId) async {
    return _enrollments[enrollmentId];
  }

  @override
  Future<List<CourseEnrollment>> getStudentCourseEnrollments(String studentId) async {
    return _enrollments.values
      .where((e) => e.studentId == studentId)
      .toList();
  }

  @override
  Future<void> updateCourseProgress({
    required String enrollmentId,
    required double completionPercentage,
    required double currentScore,
    required int lessonsCompleted,
  }) async {
    final enrollment = _enrollments[enrollmentId];
    if (enrollment != null) {
      final isCompleted = completionPercentage >= 100.0;
      _enrollments[enrollmentId] = CourseEnrollment(
        enrollmentId: enrollment.enrollmentId,
        courseId: enrollment.courseId,
        studentId: enrollment.studentId,
        partnershipId: enrollment.partnershipId,
        enrolledAt: enrollment.enrolledAt,
        completedAt: isCompleted ? DateTime.now() : null,
        completionPercentage: completionPercentage,
        currentScore: currentScore,
        lessonsCompleted: lessonsCompleted,
        lastAccessedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<String> startCurriculumProgress({
    required String curriculumId,
    required String studentId,
    required String partnershipId,
  }) async {
    final progressId = 'cp_${_curriculumProgress.length}';
    _curriculumProgress[progressId] = CurriculumProgress(
      progressId: progressId,
      curriculumId: curriculumId,
      studentId: studentId,
      partnershipId: partnershipId,
      currentCourseIndex: 0,
      completedCourseIds: [],
      overallProgress: 0.0,
      currentScore: 0.0,
      hoursSpent: 0,
      startedAt: DateTime.now(),
    );
    return progressId;
  }

  @override
  Future<CurriculumProgress?> getCurriculumProgress(String progressId) async {
    return _curriculumProgress[progressId];
  }

  @override
  Future<CurriculumProgress?> getStudentCurriculumProgress({
    required String studentId,
    required String curriculumId,
  }) async {
    return _curriculumProgress.values.firstWhere(
      (p) => p.studentId == studentId && p.curriculumId == curriculumId,
      orElse: () => CurriculumProgress(
        progressId: '',
        curriculumId: '',
        studentId: '',
        partnershipId: '',
        currentCourseIndex: 0,
        completedCourseIds: [],
        overallProgress: 0.0,
        currentScore: 0.0,
        hoursSpent: 0,
        startedAt: DateTime.now(),
      ),
    ) as CurriculumProgress?;
  }

  @override
  Future<void> updateCurriculumProgress({
    required String progressId,
    required int currentCourseIndex,
    required double overallProgress,
    required double currentScore,
    required int hoursSpent,
  }) async {
    final progress = _curriculumProgress[progressId];
    if (progress != null) {
      final isCompleted = overallProgress >= 100.0;
      _curriculumProgress[progressId] = CurriculumProgress(
        progressId: progress.progressId,
        curriculumId: progress.curriculumId,
        studentId: progress.studentId,
        partnershipId: progress.partnershipId,
        currentCourseIndex: currentCourseIndex,
        completedCourseIds: progress.completedCourseIds,
        overallProgress: overallProgress,
        currentScore: currentScore,
        hoursSpent: hoursSpent,
        startedAt: progress.startedAt,
        completedAt: isCompleted ? DateTime.now() : null,
      );
    }
  }

  @override
  Future<void> updateQuestionUsageStats({
    required String questionId,
    required double timeSpent,
    required bool wasCorrect,
  }) async {
    final question = _institutionalQuestions[questionId];
    if (question != null) {
      _institutionalQuestions[questionId] = InstitutionalQuestion(
        questionId: question.questionId,
        partnershipId: question.partnershipId,
        createdByUserId: question.createdByUserId,
        questionText: question.questionText,
        type: question.type,
        difficulty: question.difficulty,
        category: question.category,
        subcategory: question.subcategory,
        answerOptions: question.answerOptions,
        correctAnswer: question.correctAnswer,
        explanation: question.explanation,
        keywords: question.keywords,
        status: question.status,
        accessLevel: question.accessLevel,
        usageCount: question.usageCount + 1,
        averageTimeSpent: (question.averageTimeSpent + timeSpent) / 2,
        averageAccuracy: wasCorrect ? question.averageAccuracy + 0.1 : question.averageAccuracy - 0.05,
        reviewedAt: question.reviewedAt,
        reviewedByUserId: question.reviewedByUserId,
        reviewNotes: question.reviewNotes,
        createdAt: question.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<Map<String, int>> getQuestionStatsByCategory(String partnershipId) async {
    final stats = <String, int>{};
    for (final question in _institutionalQuestions.values) {
      if (question.partnershipId == partnershipId) {
        stats[question.category] = (stats[question.category] ?? 0) + 1;
      }
    }
    return stats;
  }

  @override
  Future<Map<String, int>> getQuestionStatsByDifficulty(String partnershipId) async {
    final stats = <String, int>{};
    for (final question in _institutionalQuestions.values) {
      if (question.partnershipId == partnershipId) {
        final diffStr = question.difficulty.toString().split('.').last;
        stats[diffStr] = (stats[diffStr] ?? 0) + 1;
      }
    }
    return stats;
  }

  @override
  Future<double> getCourseCompletionRate(String courseId) async {
    final enrollments = _enrollments.values
      .where((e) => e.courseId == courseId)
      .toList();

    if (enrollments.isEmpty) return 0.0;

    final completed = enrollments.where((e) => e.isCompleted).length;
    return (completed / enrollments.length) * 100;
  }

  @override
  Future<double> getCurriculumCompletionRate(String curriculumId) async {
    final progress = _curriculumProgress.values
      .where((p) => p.curriculumId == curriculumId)
      .toList();

    if (progress.isEmpty) return 0.0;

    final totalProgress = progress.fold<double>(0, (sum, p) => sum + p.overallProgress);
    return totalProgress / progress.length;
  }
}

import 'dart:math' show min;
