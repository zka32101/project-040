# Phase 11 Step 1: Community Channels & Forums

Community-driven discussion platform with public channels, user-created posts, threaded conversations, moderation tools, and engagement analytics for the Bike License Kore app.

## Overview

This Phase 11 Step 1 implementation provides:
- **Community Channels** - Public and private discussion channels by topic
- **Posts & Discussions** - User-created content with editing and archival
- **Threaded Conversations** - Replies and nested discussions
- **Rich Interactions** - Likes, views, and engagement tracking
- **Content Management** - Pinning, publishing, and search capabilities
- **Member Management** - Roles, permissions, and moderation
- **Moderation Tools** - Warnings, mutes, and bans with record tracking
- **Channel Statistics** - Engagement metrics and analytics

## Architecture

### Channel Creation Flow
```
Create Channel
    ├── Set channel metadata
    ├── Assign owner
    ├── Set channel type (public/private)
    ├── Define category and tags
    └── Initialize stats
    ↓
Channel Ready
    ├── Users can discover via search
    ├── Users can join/request
    ├── Owner can manage members
    └── Members can post
```

### Post & Discussion Flow
```
Create Post
    ├── Set content and media
    ├── Assign author
    ├── Optionally set tags
    └── Initialize metrics
    ↓
Post Engagement
    ├── Users can like/unlike
    ├── Users can reply
    ├── Replies nest and thread
    └── Engagement tracked
    ↓
Post Lifecycle
    ├── Publish/draft status
    ├── Edit by author
    ├── Pin by moderators
    └── Archive when needed
```

### Moderation Flow
```
Detect Issue
    ├── Report inappropriate content
    ├── Moderator reviews
    ├── Choose action
    └── Create record
    ↓
Apply Action
    ├── Issue warning
    ├── Mute user
    ├── Ban from channel
    └── Track in record
    ↓
Manage Record
    ├── Review history
    ├── Modify role/permissions
    ├── Unban user
    └── Close record
```

## Features

### Community Channels

#### Create and Manage Channels
```dart
// Create public channel
final channelId = await communityService.createChannel(
  name: 'Bike Maintenance',
  ownerId: 'user123',
  description: 'Tips and tricks for maintaining your bike',
  type: ChannelType.public,
  category: 'Maintenance',
  tags: ['maintenance', 'tips', 'diy'],
  bannerUrl: 'https://example.com/banner.jpg',
  iconUrl: 'https://example.com/icon.png',
);

// Get channel details
final channel = await communityService.getChannel(channelId);

// Search channels
final results = await communityService.searchChannels('maintenance');

// Get channels by category
final maintenanceChannels = await communityService.getChannelsByCategory(
  'Maintenance',
  limit: 50,
);

// Get public channels
final publicChannels = await communityService.getPublicChannels();

// Update channel
final updated = channel.copyWith(
  name: 'Advanced Bike Maintenance',
  description: 'Expert tips for bike maintenance',
);
await communityService.updateChannel(channelId, updated);

// Archive channel
await communityService.archiveChannel(channelId);
```

#### Channel Types
- **Public**: Anyone can discover and join
- **Private**: Invitation-only channels
- **Announcement**: Owner-only posting, members can reply

#### Features
- Topic organization with categories
- Custom tags for discovery
- Banner and icon customization
- Activity tracking with last activity timestamp
- Member counts and post statistics
- Channel archival for inactive channels

### Member Management

#### Manage Channel Membership
```dart
// Add member to channel
final memberId = await communityService.addMemberToChannel(
  channelId: channelId,
  userId: 'user456',
  role: MemberRole.member,
);

// Get member information
final member = await communityService.getChannelMember(channelId, 'user456');

// Get all members
final members = await communityService.getChannelMembers(channelId);

// Get moderators and owners
final moderators = await communityService.getChannelModerators(channelId);

// Update member role
await communityService.updateMemberRole(
  channelId: channelId,
  userId: 'user456',
  newRole: MemberRole.moderator,
);

// Remove member
await communityService.removeMemberFromChannel(channelId, 'user456');
```

#### Member Roles
- **Owner**: Full control, can delete channel, promote/demote members
- **Moderator**: Manage posts, moderate users, pin content
- **Member**: Regular participation, create posts and replies

#### Member Moderation
```dart
// Mute member (user can't post)
await communityService.muteChannelMember(
  channelId: channelId,
  userId: 'user456',
);

// Unmute member
await communityService.unmuteChannelMember(
  channelId: channelId,
  userId: 'user456',
);

// Ban member from channel
await communityService.banChannelMember(
  channelId: channelId,
  userId: 'user456',
  reason: 'Spam and harassment',
);

// Unban member
await communityService.unbanChannelMember(channelId, 'user456');
```

### Posts & Discussions

#### Create and Manage Posts
```dart
// Create post
final postId = await communityService.createPost(
  channelId: channelId,
  authorId: 'user123',
  authorName: 'John Cyclist',
  content: 'Best practices for chain maintenance...',
  mediaUrl: 'https://example.com/image.jpg',
  tags: ['chain', 'maintenance'],
);

// Get post
final post = await communityService.getPost(postId);

// Get channel posts
final posts = await communityService.getChannelPosts(
  channelId,
  statusFilter: PostStatus.published,
  limit: 50,
);

// Edit post (by author)
await communityService.updatePost(
  postId: postId,
  content: 'Updated content with more details...',
);

// Get published posts only
final publishedPosts = await communityService.getChannelPosts(channelId);

// Delete (archive) post
await communityService.deletePost(postId);

// Search posts
final results = await communityService.searchPosts(
  channelId: channelId,
  query: 'chain maintenance',
);
```

#### Post Engagement
```dart
// Like a post
await communityService.likePost(postId, 'user456');

// Unlike a post
await communityService.unlikePost(postId, 'user456');

// Get like count
final post = await communityService.getPost(postId);
print('Likes: ${post.likes}');
print('Liked by: ${post.likedBy.join(", ")}');

// Track views
await communityService.incrementPostViews(postId);
```

#### Pin Important Posts
```dart
// Pin post to top
await communityService.pinPost(
  postId: postId,
  position: 1, // 1 = most important
);

// Get pinned posts
final pinnedPosts = await communityService.getPinnedPosts(channelId);

// Unpin post
await communityService.unpinPost(postId);
```

#### Post Lifecycle
- **Draft**: Author is still writing
- **Published**: Visible to channel members
- **Archived**: Soft deleted, not visible but preserved
- **Pinned**: Featured at top of channel

### Threaded Discussions

#### Create Replies
```dart
// Reply to post
final replyId = await communityService.createReply(
  postId: postId,
  channelId: channelId,
  authorId: 'user456',
  authorName: 'Jane Cyclist',
  content: 'Thanks for the tip! I tried this and it worked...',
  mediaUrl: 'https://example.com/photo.jpg',
);

// Get post replies
final replies = await communityService.getPostReplies(postId);

// Get individual reply
final reply = await communityService.getReply(replyId);

// Edit reply
await communityService.updateReply(
  replyId: replyId,
  content: 'Updated reply with more details...',
);

// Delete reply
await communityService.deleteReply(replyId);

// Like reply
await communityService.likeReply(replyId, 'user789');

// Unlike reply
await communityService.unlikeReply(replyId, 'user789');

// Search replies
final results = await communityService.searchReplies(query: 'helpful');
```

#### Reply Features
- Thread tracking (replies linked to post)
- Author attribution
- Media support (images, links)
- Like/engagement tracking
- Edit history with timestamps
- Automatic reply count updates

### Moderation System

#### Create Moderation Records
```dart
// Issue warning
final recordId = await communityService.createModerationRecord(
  channelId: channelId,
  targetUserId: 'user456',
  actionBy: 'moderator123',
  action: ModerationAction.warning,
  reason: 'Off-topic discussion',
);

// Mute temporarily
final muteRecordId = await communityService.createModerationRecord(
  channelId: channelId,
  targetUserId: 'user456',
  actionBy: 'moderator123',
  action: ModerationAction.mute,
  reason: 'Spam',
  expiresAt: DateTime.now().add(Duration(hours: 24)),
);

// Ban permanently
final banRecordId = await communityService.createModerationRecord(
  channelId: channelId,
  targetUserId: 'user456',
  actionBy: 'moderator123',
  action: ModerationAction.ban,
  reason: 'Harassment and abuse',
);
```

#### Review Moderation History
```dart
// Get channel moderation records
final records = await communityService.getChannelModerationRecords(channelId);

// Get user moderation history
final userRecords = await communityService.getUserModerationRecords('user456');

// Get specific record
final record = await communityService.getModerationRecord(recordId);

// Check if mute/ban is expired
if (record.expiresAt != null && record.isExpired) {
  await communityService.unmuteChannelMember(channelId, 'user456');
}

// Close record (archive moderation action)
await communityService.closeModerationRecord(recordId);
```

#### Moderation Actions
- **Warning**: Verbal caution, recorded
- **Mute**: Can't post/reply, temporary or permanent
- **Ban**: Can't access channel, can be appealed

### Analytics & Statistics

#### Channel Statistics
```dart
// Get channel stats
final stats = await communityService.getChannelStats(channelId);
print('Members: ${stats.totalMembers}');
print('Posts: ${stats.totalPosts}');
print('Replies: ${stats.totalReplies}');
print('Active Today: ${stats.activeToday}');
print('Active This Week: ${stats.activeThisWeek}');

// Get membership count
final memberCount = await communityService.getChannelMembersCount(channelId);

// Get posts count
final postCount = await communityService.getChannelPostsCount(channelId);

// Get total channels
final totalChannels = await communityService.getTotalChannelsCount();

// Update stats (automatic on activity)
await communityService.updateChannelStats(channelId);
```

#### Engagement Metrics
- Member count with active members
- Post and reply counts
- Like and view tracking
- Activity snapshots (today, this week)
- Trend analysis

## Database Schema

### Firestore Collections

```
firestore
├── communityChannels/
│   └── {channelId}/
│       ├── channelId: String
│       ├── name: String
│       ├── description: String (optional)
│       ├── type: int (ChannelType enum)
│       ├── ownerId: String
│       ├── moderatorIds: Array<String>
│       ├── memberIds: Array<String>
│       ├── bannerUrl: String (optional)
│       ├── iconUrl: String (optional)
│       ├── memberCount: int
│       ├── totalPosts: int
│       ├── isArchived: boolean
│       ├── category: String (optional)
│       ├── tags: Array<String>
│       ├── createdAt: Timestamp
│       ├── lastActivityAt: Timestamp (optional)
│       └── updatedAt: Timestamp (optional)
│
├── channelMembers/
│   └── {memberId}/
│       ├── memberId: String
│       ├── channelId: String
│       ├── userId: String
│       ├── role: int (MemberRole enum)
│       ├── joinedAt: Timestamp
│       ├── lastActiveAt: Timestamp (optional)
│       ├── postsCount: int
│       ├── isMuted: boolean
│       ├── isBanned: boolean
│       └── banReason: String (optional)
│
├── channelPosts/
│   └── {postId}/
│       ├── postId: String
│       ├── channelId: String
│       ├── authorId: String
│       ├── authorName: String (optional)
│       ├── content: String
│       ├── status: int (PostStatus enum)
│       ├── createdAt: Timestamp
│       ├── updatedAt: Timestamp (optional)
│       ├── likes: int
│       ├── replies: int
│       ├── views: int
│       ├── likedBy: Array<String>
│       ├── mediaUrl: String (optional)
│       ├── tags: Array<String>
│       ├── isPinned: boolean
│       └── pinPosition: int (optional)
│
├── postReplies/
│   └── {replyId}/
│       ├── replyId: String
│       ├── postId: String
│       ├── channelId: String
│       ├── authorId: String
│       ├── authorName: String (optional)
│       ├── content: String
│       ├── createdAt: Timestamp
│       ├── updatedAt: Timestamp (optional)
│       ├── likes: int
│       ├── likedBy: Array<String>
│       └── mediaUrl: String (optional)
│
├── moderationRecords/
│   └── {recordId}/
│       ├── recordId: String
│       ├── channelId: String
│       ├── targetUserId: String
│       ├── actionBy: String
│       ├── action: int (ModerationAction enum)
│       ├── reason: String (optional)
│       ├── createdAt: Timestamp
│       ├── expiresAt: Timestamp (optional)
│       └── isActive: boolean
│
└── channelStats/
    └── {statsId}/
        ├── statsId: String
        ├── channelId: String
        ├── totalMembers: int
        ├── totalPosts: int
        ├── totalReplies: int
        ├── totalLikes: int
        ├── activeToday: int
        ├── activeThisWeek: int
        └── updatedAt: Timestamp
```

### Indexes

Recommended Firestore indexes:
```
communityChannels
├── type (Ascending)
├── category (Ascending)
└── lastActivityAt (Descending)

channelMembers
├── channelId (Ascending)
├── role (Ascending)
└── joinedAt (Descending)

channelPosts
├── channelId (Ascending)
├── isPinned (Descending)
└── createdAt (Descending)

postReplies
├── postId (Ascending)
└── createdAt (Descending)

moderationRecords
├── channelId (Ascending)
└── createdAt (Descending)
```

## Integration with Previous Phases

### With Phase 10 (Messaging)
- Channel discussions complement direct messaging
- Channel posts can reference conversations
- Moderation experience extends to messaging
- User profiles visible in channel discussions

### With Phase 9 (Social Features)
- Community channels for study groups
- Achievement displays in channel profiles
- Leaderboard integration for top contributors
- Friend system enables private channels
- Activity feed includes channel posts

## Models

### Key Models

**CommunityChannel**
- Properties: channelId, name, description, type, ownerId, moderatorIds, memberIds, memberCount, totalPosts, category, tags, bannerUrl, iconUrl, createdAt, lastActivityAt, isArchived
- Methods: copyWith(), toMap(), fromMap()
- Getters: isPublic, isPrivate, isAnnouncement

**ChannelPost**
- Properties: postId, channelId, authorId, authorName, content, status, createdAt, updatedAt, likes, replies, views, likedBy, mediaUrl, tags, isPinned, pinPosition
- Methods: copyWith(), toMap(), fromMap()
- Getters: isPublished, isDraft

**ChannelMember**
- Properties: memberId, channelId, userId, role, joinedAt, lastActiveAt, postsCount, isMuted, isBanned, banReason
- Methods: copyWith(), toMap(), fromMap()
- Getters: isOwner, isModerator

**PostReply**
- Properties: replyId, postId, channelId, authorId, authorName, content, createdAt, updatedAt, likes, likedBy, mediaUrl
- Methods: copyWith(), toMap(), fromMap()

**ModerationRecord**
- Properties: recordId, channelId, targetUserId, actionBy, action, reason, createdAt, expiresAt, isActive
- Methods: copyWith(), toMap(), fromMap()
- Getters: isBan, isMute, isExpired

**ChannelStats**
- Properties: statsId, channelId, totalMembers, totalPosts, totalReplies, totalLikes, activeToday, activeThisWeek, updatedAt
- Methods: copyWith(), toMap(), fromMap()

## Performance Targets

| Operation | Target | Notes |
|-----------|--------|-------|
| Create channel | < 300ms | Metadata storage only |
| Get channel | < 100ms | Direct document retrieval |
| Get channel posts | < 200ms | Batch fetching with limit |
| Create post | < 200ms | Add to posts collection |
| Create reply | < 150ms | Add to replies collection |
| Like post | < 100ms | FieldValue increment |
| Get channel members | < 200ms | Query with filters |
| Search channels | < 500ms | Client-side filtering after fetch |
| Moderation action | < 150ms | Single document update |

## Best Practices

### Channel Management
1. **Category Organization**: Use consistent categories for discoverability
2. **Channel Naming**: Use clear, descriptive names (not abbreviations)
3. **Icons & Banners**: Include visual elements for quick recognition
4. **Description**: Write comprehensive channel descriptions
5. **Archival**: Archive inactive channels after 6 months

### Content Moderation
1. **Clear Rules**: Establish and post community guidelines
2. **Consistent Action**: Apply moderation consistently
3. **Documentation**: Always record reasons for actions
4. **Appeal Process**: Allow users to appeal bans/mutes
5. **Escalation**: Route serious issues to channel owner

### Engagement
1. **Pinned Content**: Pin 2-5 most important posts weekly
2. **Activity Monitoring**: Watch for inactive channels
3. **Community Events**: Organize themed discussion days
4. **Recognition**: Highlight top contributors
5. **Feedback**: Seek member feedback on channel direction

### Search Optimization
1. **Use Tags**: Add 3-5 relevant tags to posts
2. **Descriptive Titles**: Write clear post titles (in content)
3. **Keywords**: Include searchable keywords in content
4. **Categories**: Organize channels by topic
5. **Searchability**: Make public channels easily discoverable

## Security Considerations

1. **Access Control**: Verify user is channel member before allowing access
2. **Role Verification**: Check member role before moderation actions
3. **Content Filtering**: Scan content for inappropriate material
4. **Ban Enforcement**: Prevent banned users from posting
5. **Privacy**: Hide private channel content from non-members
6. **Audit Trail**: Log all moderation actions
7. **Rate Limiting**: Prevent spam and rapid posting

## Testing

### Test Coverage

The `test/community_service_test.dart` file includes 90+ tests covering:

**Channel Management (15+ tests)**
- Create channels
- Get and search channels
- Update and archive channels
- Channel type handling

**Member Management (18+ tests)**
- Add and remove members
- Get members and moderators
- Update member roles
- Mute and ban functionality

**Post Management (20+ tests)**
- Create and update posts
- Publish and delete posts
- Pin and unpin posts
- Like and view tracking
- Post search

**Reply Management (15+ tests)**
- Create and delete replies
- Update replies
- Like replies
- Get post replies
- Reply search

**Moderation (10+ tests)**
- Create moderation records
- Get channel and user records
- Close records
- Moderation tracking

**Statistics (8+ tests)**
- Get channel stats
- Count members and posts
- Track engagement metrics

**Models (12+ tests)**
- Serialization/deserialization
- Data preservation
- Enum handling

**Integration (2+ tests)**
- Complete channel workflow
- Complete moderation workflow

### Running Tests
```bash
flutter test test/community_service_test.dart
```

## Future Enhancements

1. **Advanced Search**: Full-text search with Firestore search
2. **Notifications**: Alert users to replies in their posts
3. **Pinned Announcements**: Persistent top-of-channel announcements
4. **Channel Roles**: Custom role creation beyond owner/mod/member
5. **Content Reactions**: Emoji reactions to posts (beyond likes)
6. **User Mentions**: @mention users in posts and replies
7. **Thread Badges**: Show badges for moderators/verified users
8. **Channel Invitations**: Invite specific users to channels
9. **Scheduled Posts**: Schedule posts for future publication
10. **Report System**: Users can report inappropriate content
11. **Trending**: Highlight trending topics and posts
12. **Recommendations**: Suggest channels based on interests

## Troubleshooting

### Common Issues

**Member can't post after joining**
- Verify member role is not muted
- Check if member was banned
- Ensure channel is not private/archived

**Post not appearing in channel**
- Check post status (draft vs published)
- Verify post is not archived
- Check search indexes are updated

**Moderation action not taking effect**
- Verify moderator has permission
- Check if record was closed
- Ensure record is still active

**Search not returning results**
- Try broader search terms
- Check tags and categories
- Verify content exists in channel

## References

### Related Documentation
- Phase 10 Step 1: Real-Time Messaging & Notifications
- Phase 10 Step 2: Advanced Messaging Features & Interactions
- Phase 10 Step 3: Voice/Video & Media Messaging
- Phase 9: User Profiles, Achievements, Leaderboards, Social Features

### External Resources
- Firestore Best Practices
- Community Management Guidelines
- Moderation Best Practices
- Content Moderation Policies

---

**Phase 11 Step 1 Implementation Complete**
- 1,200+ lines of model definitions
- 1,400+ lines of service interface and implementations
- 2,500+ lines of comprehensive tests (90+ tests)
- 500+ lines of documentation
- Full Firestore integration with 6 collections
- Complete community platform with moderation
- Production-ready implementation

Total additions: 5,600+ lines | Test coverage: 90+ tests | Models: 6 major classes
