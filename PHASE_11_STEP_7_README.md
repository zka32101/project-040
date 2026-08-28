# Phase 11 Step 7: Community Gamification & User Badges

Comprehensive gamification system for the Bike License Kore community platform, enabling user reputation tracking, achievement badges, leaderboards, and contribution-based rewards to drive engagement and recognize community participation.

## Overview

This Phase 11 Step 7 implementation provides:
- **User Reputation System** - Track user credibility and contribution scores
- **Achievement Badges** - Unlock badges for community milestones and actions
- **Community Leaderboards** - Display top contributors and active users
- **User Levels** - Progress through levels based on total contributions
- **Contribution Tracking** - Measure user engagement metrics
- **Badge Categories** - Organize badges by type and difficulty
- **Reputation Events** - Track reputation changes and triggers
- **Rewards & Incentives** - Gamification rewards for participation
- **User Statistics** - Comprehensive user performance metrics
- **Badge Analytics** - Track badge earning patterns and trends

## Architecture

### User Reputation Flow
```
User Takes Action
    ├── Create post
    ├── Reply to post
    ├── Receive reaction
    ├── Help other user
    └── Earn upvotes/approval
    ↓
Reputation Event Generated
    ├── Determine point value
    ├── Check for milestone
    ├── Calculate level change
    └── Check badge requirements
    ↓
Update User Reputation
    ├── Add reputation points
    ├── Update total score
    ├── Update user level
    └── Store reputation event
    ↓
Check Badge Requirements
    ├── Verify conditions met
    ├── Create badge record
    ├── Notify user
    └── Add to achievements
    ↓
User Progression
    ├── Level up notification
    ├── Achievement displayed
    ├── Leaderboard updated
    └── Stats recalculated
```

### Badge Earning Flow
```
Badge Definition
    ├── Category (social, expertise, moderation, etc.)
    ├── Conditions (criteria to earn)
    ├── Rarity (common, uncommon, rare, epic, legendary)
    ├── Points (reputation value)
    └── Icon/description
    ↓
User Action Triggers Badge Check
    ├── Accumulate required points
    ├── Reach contribution threshold
    ├── Achieve milestone
    └── Complete special task
    ↓
Badge Earned
    ├── Create badge record
    ├── Add to user achievements
    ├── Increment badge count
    ├── Trigger notification
    └── Update leaderboards
    ↓
Display Achievement
    ├── Show badge in profile
    ├── Display badge progress
    ├── Share achievement
    └── Celebrate milestone
```

### Leaderboard Generation Flow
```
Calculate Metrics
    ├── Total reputation points
    ├── Contribution count
    ├── Posts created
    ├── Helpful replies
    ├── Badges earned
    └── Level achieved
    ↓
Rank Users
    ├── Sort by metric
    ├── Calculate percentile
    ├── Determine tier
    └── Show rankings
    ↓
Display Leaderboards
    ├── Overall top contributors
    ├── Weekly/monthly actives
    ├── Category leaders
    ├── Newest members
    └── Rising stars
```

## Features

### User Reputation System

#### Create & Track Reputation
```dart
// Create reputation event
final reputationId = await communityService.addReputationEvent(
  userId: 'user123',
  eventType: 'post_created', // post_created, reply_helpful, content_approved, etc.
  points: 10,
  reason: 'Created high-quality post',
  relatedContentId: 'post456',
);

// Get user reputation
final reputation = await communityService.getUserReputation('user123');

// Get reputation events
final events = await communityService.getReputationEvents(
  userId: 'user123',
  limit: 50,
);

// Get user stats
final stats = await communityService.getUserStatistics('user123');
```

#### Reputation Point System
```dart
// Get total reputation
final totalRep = await communityService.getTotalReputation('user123');

// Get reputation timeline
final timeline = await communityService.getReputationTimeline(
  userId: 'user123',
  timeRange: 'month',
);

// Check reputation tier
final tier = await communityService.getUserReputationTier('user123');
// Returns: novice, contributor, expert, moderator, leader
```

### Achievement Badges

#### Badge Management
```dart
// Create badge definition
final badgeId = await communityService.createBadgeDefinition(
  name: 'First Post',
  category: 'social',
  description: 'Created your first post',
  rarity: 'common', // common, uncommon, rare, epic, legendary
  pointsValue: 5,
  iconUrl: 'url_to_icon',
  requirements: {
    'posts_created': 1,
  },
);

// Get badge definitions
final badges = await communityService.getBadgeDefinitions(
  category: 'expertise',
  limit: 50,
);

// Get single badge
final badge = await communityService.getBadgeDefinition(badgeId);
```

#### User Badges
```dart
// Get user badges
final userBadges = await communityService.getUserBadges('user123');

// Get user achievements
final achievements = await communityService.getUserAchievements(
  userId: 'user123',
  limit: 50,
);

// Check badge progress
final progress = await communityService.getBadgeProgress(
  userId: 'user123',
  badgeId: 'badge456',
);

// Award badge manually
await communityService.awardBadge(
  userId: 'user123',
  badgeId: 'badge456',
  awardedBy: 'admin123',
  reason: 'Exceptional contribution',
);
```

### Community Leaderboards

#### View Leaderboards
```dart
// Get top contributors
final topContributors = await communityService.getTopContributors(
  limit: 100,
  timeRange: 'all', // all, week, month, year
);

// Get leaderboard by metric
final leaderboard = await communityService.getLeaderboard(
  metric: 'reputation', // reputation, posts, helpful_replies, badges
  limit: 50,
  timeRange: 'month',
);

// Get user rank
final rank = await communityService.getUserRank(
  userId: 'user123',
  metric: 'reputation',
);

// Get nearby ranks
final nearby = await communityService.getNearbyRanks(
  userId: 'user123',
  metric: 'reputation',
  range: 5, // show 5 users above and below
);
```

#### Leaderboard Filters
```dart
// Get leaderboard by category
final categoryLeaders = await communityService.getCategoryLeaders(
  category: 'maintenance',
  limit: 50,
);

// Get new members leaderboard
final newMembers = await communityService.getNewMembersLeaderboard(
  days: 30,
  limit: 50,
);

// Get rising stars
final risingStar = await communityService.getRisingStars(
  timeRange: 'week',
  limit: 20,
);
```

### User Levels & Progression

#### Level System
```dart
// Get user level
final level = await communityService.getUserLevel('user123');
// Returns: { level: 5, title: 'Expert', experience: 450, nextLevelAt: 500 }

// Get level progression
final progression = await communityService.getLevelProgression('user123');

// Get level definitions
final levels = await communityService.getLevelDefinitions();

// Check level up
await communityService.checkAndProcessLevelUp('user123');
```

### Badge Categories

#### Predefined Badge Categories
```dart
// Social Badges
// - First Post, 10 Posts, 100 Posts
// - Popular Post, Trending Topic
// - Helpful Reply, Expert Answer

// Expertise Badges  
// - 10 Day Streak, Consistent Contributor
// - Subject Matter Expert
// - Category Specialist

// Moderation Badges
// - Helpful Reviewer, Report Approver
// - Community Guardian
// - Moderator Medal

// Milestone Badges
// - 1 Month Member, 1 Year Member
// - 100 Reputation, 1000 Reputation
// - Level Milestones

// Achievement Badges
// - Achievement Unlocked series
// - Special event badges
// - Challenge completion badges
```

## Data Model

### UserReputation
- `reputationId` (String) - Unique identifier
- `userId` (String) - User being tracked
- `totalScore` (int) - Total reputation points
- `currentLevel` (int) - User level (1-100)
- `levelTitle` (String) - Level name (novice, contributor, expert, etc.)
- `postsCount` (int) - Total posts created
- `repliesCount` (int) - Total replies written
- `upvotesReceived` (int) - Upvotes on user content
- `badgesCount` (int) - Total badges earned
- `createdAt` (DateTime) - Account creation date
- `lastActivityAt` (DateTime) - Last contribution time

### ReputationEvent
- `eventId` (String) - Unique identifier
- `userId` (String) - User gaining reputation
- `eventType` (String) - Type of action (post_created, reply_helpful, etc.)
- `points` (int) - Points awarded
- `reason` (String) - Why points were awarded
- `relatedContentId` (String?) - Related post/comment ID
- `createdAt` (DateTime) - When event occurred
- `metadata` (Map) - Additional event data

### BadgeDefinition
- `badgeId` (String) - Unique identifier
- `name` (String) - Badge name
- `description` (String) - Badge description
- `category` (String) - Badge category
- `rarity` (String) - Rarity level (common to legendary)
- `pointsValue` (int) - Reputation points for earning
- `iconUrl` (String) - Badge icon URL
- `requirements` (Map) - Conditions to earn badge
- `createdAt` (DateTime) - When badge was defined
- `isActive` (bool) - Is badge currently awardable

### UserBadge
- `badgeId` (String) - Badge earned
- `userId` (String) - User who earned it
- `earnedAt` (DateTime) - When badge was earned
- `awardedBy` (String?) - Who awarded it (if manual)
- `reason` (String?) - Reason for award
- `isDisplayed` (bool) - Show in profile
- `level` (int) - Badge level if repeatable

### UserLevel
- `userId` (String) - User ID
- `currentLevel` (int) - Current level (1-100)
- `title` (String) - Level title
- `totalExperience` (int) - Total XP earned
- `experienceForNextLevel` (int) - XP needed to level up
- `percentToNextLevel` (double) - Progress percentage (0-1)
- `levelUpAt` (DateTime) - When last leveled up

### Leaderboard
- `leaderboardId` (String) - Unique identifier
- `metric` (String) - Leaderboard type (reputation, posts, etc.)
- `entries` (List) - Ranked user entries
- `generatedAt` (DateTime) - When leaderboard was generated
- `timeRange` (String) - Time period (all, week, month, year)

## Database Schema

### Collections

#### `userReputation/`
```
{
  reputationId: string (document ID)
  userId: string (indexed)
  totalScore: int (indexed)
  currentLevel: int (indexed)
  levelTitle: string
  postsCount: int
  repliesCount: int
  upvotesReceived: int
  badgesCount: int
  createdAt: timestamp (indexed)
  lastActivityAt: timestamp (indexed)
}
```

#### `reputationEvents/`
```
{
  eventId: string (document ID)
  userId: string (indexed)
  eventType: string (indexed)
  points: int
  reason: string
  relatedContentId: string (optional)
  createdAt: timestamp (indexed)
  metadata: map
}
```

#### `badgeDefinitions/`
```
{
  badgeId: string (document ID)
  name: string (indexed)
  category: string (indexed)
  description: string
  rarity: string (indexed)
  pointsValue: int
  iconUrl: string
  requirements: map
  createdAt: timestamp (indexed)
  isActive: boolean (indexed)
}
```

#### `userBadges/`
```
{
  userBadgeId: string (document ID)
  badgeId: string (indexed)
  userId: string (indexed)
  earnedAt: timestamp (indexed)
  awardedBy: string (optional)
  reason: string (optional)
  isDisplayed: boolean
  level: int (optional)
}
```

#### `leaderboards/`
```
{
  leaderboardId: string (document ID)
  metric: string (indexed)
  timeRange: string (indexed)
  entries: array<{userId, rank, score, percentage}>
  generatedAt: timestamp (indexed)
}
```

## Performance Targets

- Add reputation event: < 50ms
- Get user reputation: < 50ms
- Get reputation events: < 100ms
- Award badge: < 75ms
- Get user badges: < 100ms
- Generate leaderboard: < 500ms
- Get leaderboard: < 100ms
- Get user rank: < 75ms

## Reputation Point System

### Standard Events
- Create post: 10 points
- Create reply: 5 points
- Receive upvote on post: 2 points
- Receive upvote on reply: 1 point
- Answer marked helpful: 15 points
- Content approved by moderator: 20 points
- Report approved/upheld: 10 points
- Moderate content successfully: 5 points
- Receive mention/tag: 1 point

### Bonus Events
- Post reaches 50 reactions: 50 points
- Reply reaches 20 reactions: 30 points
- 7-day contribution streak: 25 points
- Help solve community issue: 50 points
- Welcome new member: 10 points

### Penalty Events
- Content removed: -10 points
- Moderation action taken: -20 points
- Report dismissed (user created false report): -15 points
- Comment marked unhelpful: -2 points

## Badge Rarity System

### Common (Gray)
- Earn rate: > 30% of users
- Examples: First Post, 5 Posts, 1 Week Member

### Uncommon (Green)
- Earn rate: 10-30% of users
- Examples: 10 Posts, Helpful Reply, Contributor

### Rare (Blue)
- Earn rate: 3-10% of users
- Examples: Expert Answer, 100 Reputation, Rising Star

### Epic (Purple)
- Earn rate: 1-3% of users
- Examples: 1000 Reputation, Category Expert, Streak Master

### Legendary (Gold)
- Earn rate: < 1% of users
- Examples: 10000 Reputation, Hall of Fame, Lifetime Achievement

## Level System

### Experience Calculation
```
Levels 1-10: 50 XP per level
Levels 11-25: 100 XP per level
Levels 26-50: 250 XP per level
Levels 51-75: 500 XP per level
Levels 76-100: 1000 XP per level

Total to Max: ~150,000 XP
```

### Level Titles
- Levels 1-5: Novice
- Levels 6-15: Contributor
- Levels 16-30: Expert
- Levels 31-50: Authority
- Levels 51-75: Specialist
- Levels 76-100: Legend

## Best Practices

### Reputation System
- Award points immediately for actions
- Provide feedback on point gains
- Show progression clearly
- Celebrate milestone achievements
- Balance earning with difficulty

### Badge Design
- Clear earning conditions
- Attractive icon/design
- Meaningful categories
- Mix common and rare badges
- Track earning patterns

### Leaderboard Usage
- Update frequently (daily/weekly)
- Show multiple metrics
- Include contextual rankings
- Celebrate achievements publicly
- Avoid gaming mechanics

### Gamification Strategy
- Keep engagement positive
- Recognize all contribution types
- Provide multiple paths to achievement
- Celebrate milestones
- Allow profile customization

## Future Enhancements

1. **Seasonal Badges** - Limited-time achievement badges
2. **Custom Avatars** - Unlock avatar customization with levels
3. **Challenge Events** - Time-limited reputation challenges
4. **Team Competitions** - Group-based leaderboards
5. **Achievement Sharing** - Share achievements on social media
6. **Badge Marketplace** - Trade or purchase badges
7. **Mentorship System** - Senior users mentor newcomers
8. **Reputation Decay** - Reduce reputation for inactivity
9. **Referral Rewards** - Earn badges for referrals
10. **Special Events** - Holiday/seasonal badges
11. **User Titles** - Custom titles for high-level users
12. **Achievement Streaks** - Track consecutive achievements

## Troubleshooting

### Common Issues

**Badge not appearing**
- Verify user meets all requirements
- Check badge is active/published
- Ensure reputation event was recorded
- Verify user can view badge category

**Reputation not updating**
- Check reputation events are being created
- Verify point values are correct
- Ensure user account is active
- Check for reputation caps

**Leaderboard incorrect**
- Verify calculation formula
- Check data for anomalies
- Ensure time period is accurate
- Rebuild leaderboard cache

**User stuck on level**
- Check XP calculation
- Verify point values
- Review level requirements
- Check for level cap issues

## References

### Related Documentation
- Phase 11 Step 1: Community Channels & Forums
- Phase 11 Step 2: User Mentions & Notifications System
- Phase 11 Step 3: Content Reactions & Reporting System
- Phase 11 Step 4: Channel Access Control & Invitations
- Phase 11 Step 5: Advanced Search & Content Discovery
- Phase 11 Step 6: Report Appeals & Moderation Dashboard

### External Resources
- Gamification Best Practices
- Leaderboard Design Patterns
- Badge Design Principles
- User Engagement Mechanics

---

**Phase 11 Step 7 Implementation Status**
- 700+ lines of documentation
- 1,200+ lines of model definitions
- 2,000+ lines of service interface and implementations
- 2,000+ lines of comprehensive tests (40+ tests)
- Full Firestore integration with 5 new collections
- Complete gamification and reputation system
- Production-ready implementation

Total additions: 5,900+ lines | Test coverage: 40+ tests | Models: 5 major classes | New enums: 3
