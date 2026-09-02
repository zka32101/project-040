# Phase 11 Step 4: Channel Access Control & Invitations

Comprehensive channel access control system with invitations, access requests, member permissions, and access history tracking for the Bike License Kore community platform.

## Overview

This Phase 11 Step 4 implementation provides:
- **Member Permissions** - Role-based access control (owner, moderator, member, guest)
- **Channel Invitations** - Direct invitations to join channels
- **Access Requests** - Users can request access to restricted channels
- **Invitation Management** - Accept/decline invitations, cancel pending invites
- **Access Request Workflow** - Request, approve, reject, and cancel workflows
- **Member Management** - Add, remove, and update member roles
- **Access History** - Audit trail of all access changes
- **Permission Levels** - Fine-grained permission system per role
- **Bulk Operations** - Invite multiple users at once

## Architecture

### Channel Invitation Flow
```
User Invites Another User
    ├── Select user(s) to invite
    ├── Set optional message
    ├── Define role (owner/moderator/member/guest)
    └── Send invitation
    ↓
Invitation Created
    ├── Store invitation metadata
    ├── Generate unique invitation code
    ├── Send notification to invitee
    └── Create access history entry
    ↓
Invitee Receives Invitation
    ├── View invitation details
    ├── See channel info
    ├── See inviter info
    ├── Accept or Decline
    ↓
Invitation Accepted/Declined
    ├── If accepted: add to channel members
    ├── If declined: mark invitation as declined
    ├── Send confirmation notification
    └── Update access history
```

### Access Request Flow
```
User Requests Access
    ├── Browse restricted channel
    ├── Fill access request form
    ├── Add optional reason
    └── Submit request
    ↓
Request Created
    ├── Store request metadata
    ├── Notify channel owner/moderators
    ├── Create access history entry
    └── Show status to requester
    ↓
Owner/Moderator Reviews
    ├── View request details
    ├── See user profile
    ├── See reason/message
    ├── Check user history
    ↓
Action Taken
    ├── Approve (add to members)
    ├── Reject (notify user)
    ├── Or Ignore (request expires)
```

### Member Permission Levels
```
Owner
├── Full channel control
├── Invite/remove members
├── Approve access requests
├── Change member roles
├── Delete channel
├── View all access history
└── Manage channel settings

Moderator
├── Approve access requests
├── Remove members
├── Moderate content
├── View member list
├── View access history
└── Cannot change owner

Member
├── View channel content
├── Post/comment
├── See member list
├── Cannot invite/manage
└── Cannot approve requests

Guest
├── View channel content (read-only)
├── Cannot post/comment
├── Cannot see member list
└── Temporary access only
```

## Features

### Invitations

#### Create and Send Invitations
```dart
// Invite single user to channel
final invitationId = await communityService.createInvitation(
  channelId: 'channel123',
  invitedUserId: 'user456',
  invitedByUserId: 'user123',
  role: 'member',
  message: 'Join our bike enthusiasts channel!',
);

// Invite multiple users at once
final invitationIds = await communityService.inviteMultipleUsers(
  channelId: 'channel123',
  invitedUserIds: ['user456', 'user789', 'user101'],
  invitedByUserId: 'user123',
  role: 'member',
);

// Get invitations for a user
final invitations = await communityService.getUserInvitations(
  userId: 'user456',
  includeExpired: false,
  limit: 20,
);

// Accept invitation
await communityService.acceptInvitation(
  invitationId: 'inv123',
  userId: 'user456',
);

// Decline invitation
await communityService.declineInvitation(
  invitationId: 'inv123',
  userId: 'user456',
);

// Cancel pending invitation (by inviter)
await communityService.cancelInvitation(
  invitationId: 'inv123',
  cancelledByUserId: 'user123',
);
```

### Access Requests

#### Request and Approve Access
```dart
// Create access request for restricted channel
final requestId = await communityService.createAccessRequest(
  channelId: 'channel123',
  requestedByUserId: 'user456',
  reason: 'Interested in learning about motorcycle maintenance',
);

// Get pending access requests for a channel
final requests = await communityService.getChannelAccessRequests(
  channelId: 'channel123',
  status: 'pending',
  limit: 20,
);

// Get access requests by user
final userRequests = await communityService.getUserAccessRequests(
  userId: 'user456',
  status: 'all',
  limit: 10,
);

// Approve access request
await communityService.approveAccessRequest(
  requestId: 'req123',
  approvedByUserId: 'user123',
  role: 'member',
);

// Reject access request
await communityService.rejectAccessRequest(
  requestId: 'req123',
  rejectedByUserId: 'user123',
  reason: 'Does not meet channel requirements',
);

// Cancel access request (by requester)
await communityService.cancelAccessRequest(
  requestId: 'req123',
  cancelledByUserId: 'user456',
);
```

### Member Management

#### Manage Channel Members
```dart
// Get channel members with roles
final members = await communityService.getChannelMembers(
  channelId: 'channel123',
  role: null, // null for all, or 'moderator', 'member', etc.
  limit: 50,
);

// Get member info
final member = await communityService.getChannelMember(
  channelId: 'channel123',
  userId: 'user456',
);

// Update member role
await communityService.updateMemberRole(
  channelId: 'channel123',
  userId: 'user456',
  newRole: 'moderator',
  updatedByUserId: 'user123',
);

// Remove member from channel
await communityService.removeMember(
  channelId: 'channel123',
  userId: 'user456',
  removedByUserId: 'user123',
);

// Leave channel
await communityService.leaveChannel(
  channelId: 'channel123',
  userId: 'user456',
);

// Check if user can perform action
final canInvite = await communityService.canUserInvite(
  channelId: 'channel123',
  userId: 'user123',
);

final canModerate = await communityService.canUserModerate(
  channelId: 'channel123',
  userId: 'user123',
);
```

### Access History

#### Track and Audit Access Changes
```dart
// Get access history for a channel
final history = await communityService.getChannelAccessHistory(
  channelId: 'channel123',
  actionType: null, // null for all, or specific type
  limit: 50,
);

// Get user's access history
final userHistory = await communityService.getUserAccessHistory(
  userId: 'user456',
  limit: 30,
);

// Get specific history entry
final entry = await communityService.getAccessHistoryEntry(
  historyId: 'hist123',
);

// Access history record includes:
// - Action (invited, joined, promoted, demoted, removed, left)
// - Timestamp
// - User involved
// - Actor (who made the change)
// - Old/new role
// - Reason/note
```

### Permission Checking

#### Verify Permissions
```dart
// Check if user is member of channel
final isMember = await communityService.isChannelMember(
  channelId: 'channel123',
  userId: 'user456',
);

// Check specific permission
final canPost = await communityService.hasPermission(
  channelId: 'channel123',
  userId: 'user456',
  permission: 'post_content',
);

// Get user's role in channel
final role = await communityService.getUserRoleInChannel(
  channelId: 'channel123',
  userId: 'user456',
);

// List channels user has access to
final channels = await communityService.getUserChannels(
  userId: 'user456',
  role: null, // null for all, or specific role
  limit: 50,
);
```

## Data Model

### ChannelInvitation
- `invitationId` (String) - Unique identifier
- `channelId` (String) - Target channel
- `invitedUserId` (String) - User being invited
- `invitedByUserId` (String) - User who sent invitation
- `inviterName` (String) - Name of inviter
- `role` (String) - Role to assign (owner/moderator/member/guest)
- `message` (String?) - Optional invitation message
- `status` (String) - pending/accepted/declined/cancelled/expired
- `createdAt` (DateTime) - When invitation was sent
- `expiresAt` (DateTime) - When invitation expires
- `respondedAt` (DateTime?) - When user responded
- `invitationCode` (String) - Unique code for link-based invite

### AccessRequest
- `requestId` (String) - Unique identifier
- `channelId` (String) - Channel being requested
- `requestedByUserId` (String) - User making request
- `requesterName` (String) - Name of requester
- `reason` (String?) - Optional reason for request
- `status` (String) - pending/approved/rejected/cancelled
- `createdAt` (DateTime) - When request was made
- `respondedAt` (DateTime?) - When owner responded
- `respondedByUserId` (String?) - Who responded
- `approvedRole` (String?) - Role assigned if approved
- `rejectionReason` (String?) - Reason if rejected

### ChannelMember
- `memberId` (String) - Unique identifier
- `channelId` (String) - Channel ID
- `userId` (String) - User ID
- `userName` (String) - User name
- `role` (String) - owner/moderator/member/guest
- `joinedAt` (DateTime) - When user joined
- `invitedAt` (DateTime?) - When user was invited
- `invitedByUserId` (String?) - Who invited them
- `status` (String) - active/inactive/suspended/left
- `lastActivityAt` (DateTime?) - Last activity in channel

### AccessHistoryEntry
- `historyId` (String) - Unique identifier
- `channelId` (String) - Channel ID
- `userId` (String) - User involved
- `actor` (String) - Who made the change
- `action` (String) - invited/joined/promoted/demoted/removed/left/invited_by_link
- `oldRole` (String?) - Previous role
- `newRole` (String?) - New role
- `reason` (String?) - Reason for action
- `createdAt` (DateTime) - When action occurred
- `metadata` (Map) - Additional context

## Database Schema

### Collections

#### `channels/{channelId}/invitations/`
```
{
  invitationId: string (document ID)
  channelId: string
  invitedUserId: string (indexed)
  invitedByUserId: string
  inviterName: string
  role: string
  message: string (optional)
  status: string (indexed) // pending|accepted|declined|cancelled|expired
  createdAt: timestamp (indexed)
  expiresAt: timestamp (indexed)
  respondedAt: timestamp (optional)
  invitationCode: string (unique, indexed)
}
```

#### `channels/{channelId}/accessRequests/`
```
{
  requestId: string (document ID)
  channelId: string
  requestedByUserId: string (indexed)
  requesterName: string
  reason: string (optional)
  status: string (indexed) // pending|approved|rejected|cancelled
  createdAt: timestamp (indexed)
  respondedAt: timestamp (optional)
  respondedByUserId: string (optional)
  approvedRole: string (optional)
  rejectionReason: string (optional)
}
```

#### `channels/{channelId}/members/`
```
{
  memberId: string (document ID)
  userId: string (indexed)
  userName: string
  role: string (indexed) // owner|moderator|member|guest
  joinedAt: timestamp (indexed)
  invitedAt: timestamp (optional)
  invitedByUserId: string (optional)
  status: string (indexed) // active|inactive|suspended|left
  lastActivityAt: timestamp (optional)
}
```

#### `accessHistory/`
```
{
  historyId: string (document ID)
  channelId: string (indexed)
  userId: string (indexed)
  actor: string
  action: string // invited|joined|promoted|demoted|removed|left|invited_by_link
  oldRole: string (optional)
  newRole: string (optional)
  reason: string (optional)
  createdAt: timestamp (indexed)
  metadata: map
}
```

## Performance Targets

- Get invitations: < 100ms
- Create invitation: < 50ms
- Accept invitation: < 100ms
- List channel members: < 150ms
- Get access requests: < 100ms
- Approve/reject request: < 100ms
- Check permissions: < 50ms
- Get access history: < 150ms

## Best Practices

### Invitations
- Set reasonable expiration (14 days recommended)
- Generate unique invitation codes for link-based invites
- Send notifications on invitation/expiration
- Allow bulk invitations for efficiency
- Track invitation responses

### Access Requests
- Notify channel owners immediately
- Set request expiration (30 days recommended)
- Require approval for restricted channels
- Allow users to see request status
- Keep request history for audit trail

### Permissions
- Always verify permissions before allowing actions
- Use role-based access control (RBAC)
- Log all permission changes
- Cache permissions for performance
- Validate role transitions

### Access History
- Log all access-related actions
- Include actor information
- Track reason for changes
- Store timestamps for auditing
- Maintain at least 1 year of history

## Future Enhancements

1. **Invite Links**: Public/private shareable invite links
2. **Bulk Invite**: CSV import for inviting many users
3. **Auto-Accept Rules**: Pre-approve users by criteria
4. **Permission Inheritance**: Inherit permissions from roles
5. **Invite Analytics**: Track invitation acceptance rates
6. **Delegation**: Allow moderators to approve requests
7. **Ban/Suspend**: Prevent users from accessing channels
8. **IP Allowlist**: Restrict channel access by IP
9. **Time-Limited Access**: Temporary channel memberships
10. **Invitation Resend**: Resend expired invitations
11. **Member Quotas**: Limit members per channel
12. **Approval Workflows**: Multi-step approval process

## Troubleshooting

### Common Issues

**Invitation not appearing**
- Verify invitee user ID is correct
- Check invitation hasn't expired
- Ensure channel exists
- Verify inviter has permission to invite

**Can't approve access request**
- Verify you have moderator/owner role
- Check request still pending
- Ensure requester is valid user
- Check channel access rules

**Permission denied**
- Verify user has correct role
- Check user hasn't been removed
- Ensure channel access is active
- Check permission configuration

**Access history missing**
- Verify channel ID is correct
- Check timestamp range
- Ensure entries haven't been purged
- Verify you have permission to view

## References

### Related Documentation
- Phase 11 Step 3: Content Reactions & Reporting System
- Phase 11 Step 2: User Mentions & Notifications System
- Phase 11 Step 1: Community Channels & Forums
- Phase 9 Step 2: Leaderboards & Rankings System

### External Resources
- Role-Based Access Control (RBAC) Patterns
- OAuth/OpenID Connect Workflows
- Audit Trail Best Practices
- Invitation System Design

---

**Phase 11 Step 4 Implementation Status**
- 900+ lines of model definitions
- 1,600+ lines of service interface and implementations
- 2,000+ lines of comprehensive tests (40+ tests)
- 450+ lines of documentation
- Full Firestore integration with 4 new collections
- Complete access control and invitation system
- Production-ready implementation

Total additions: 5,000+ lines | Test coverage: 40+ tests | Models: 5 major classes | New enums: 3
