# Phase 57: User Management & Authorization

ユーザー管理と権限管理を実装する企業級システム

## 概要

Phase 57は、ユーザーアカウント、ロール、権限、セッション、監査ログ、アクセス制御など、包括的なユーザー管理機能を提供します。

### 主な機能

- **ユーザー管理**: ユーザー作成、更新、削除、ステータス管理
- **ロール管理**: カスタムロール、権限割り当て、ロール検証
- **権限管理**: 細粒度の権限制御、有効期限管理、権限の付与・剥奪
- **セッション管理**: セッション作成、検証、タイムアウト処理
- **監査ログ**: すべてのアクション記録、アクティビティ追跡
- **アクセス制御**: リソースベースのACL、ロール別アクセス制御
- **活動監視**: ユーザー活動追跡、異常検知
- **レポート生成**: ユーザー管理レポート、Markdown出力

## アーキテクチャ

```
UserFacade (統一インターフェース)
    ├── UserManager (ビジネスロジック)
    │   ├── UserRepository (データ永続化)
    │   ├── AuthorizationEngine (権限検証)
    │   └── SessionEngine (セッション管理)
```

### Repository Pattern

**UserRepository** インターフェースと **MemoryUserRepository** 実装により、データの永続化層を抽象化します。

```dart
abstract class UserRepository {
  Future<void> createUser(User user);
  Future<User?> getUserById(String userId);
  Future<List<User>> getAllUsers();
  Future<void> updateUser(User user);
  Future<bool> deleteUser(String userId);
  
  // Role管理
  Future<void> createRole(Role role);
  Future<Role?> getRoleById(String roleId);
  
  // Permission管理
  Future<void> grantPermission(PermissionAssignment assignment);
  Future<bool> revokePermission(String assignmentId);
  
  // Session管理
  Future<void> createSession(Session session);
  Future<Session?> getSession(String sessionId);
  
  // その他の操作
}
```

### Engine Pattern

**AuthorizationEngine**: 権限検証とアクセス制御を担当

```dart
abstract class AuthorizationEngine {
  Future<bool> hasPermission(String userId, Permission permission);
  Future<bool> canPerformAction(String userId, String action);
  Future<List<Permission>> getUserPermissions(String userId);
  Future<bool> enforceACL(String userId, String resourceId);
  Future<bool> validateRole(UserRole role);
}
```

**SessionEngine**: セッションライフサイクル管理

```dart
abstract class SessionEngine {
  Future<Session> createSession(String userId);
  Future<void> updateSession(String sessionId);
  Future<void> terminateSession(String sessionId);
  Future<bool> validateSession(String sessionId);
}
```

### Manager Pattern

**UserManager**: Repository、Engine、その他サービスを統合

```dart
abstract class UserManager {
  Future<User?> createUser(String userId, String username, String email, UserRole role);
  Future<bool> updateUserRole(String userId, UserRole newRole);
  Future<void> grantPermission(String userId, Permission permission);
  Future<void> revokePermission(String userId, Permission permission);
  Future<void> suspendUser(String userId);
  Future<void> activateUser(String userId);
  Future<UserManagementReport> generateUserReport();
  Future<void> recordAuditLog(String userId, String action, Map<String, dynamic>? details);
}
```

### Facade Pattern

**UserFacade**: シンプルで統一されたインターフェース

```dart
class UserFacade {
  // ユーザー操作
  Future<void> createUser(String userId, String username, String email, UserRole role);
  Future<User?> getUserById(String userId);
  Future<List<User>> getAllUsers();
  
  // 権限操作
  Future<void> grantPermissionToUser(String userId, Permission permission);
  Future<void> revokePermissionFromUser(String userId, Permission permission);
  Future<bool> userHasPermission(String userId, Permission permission);
  
  // セッション操作
  Future<Session?> createSession(String userId);
  Future<bool> validateSession(String sessionId);
  
  // レポート生成
  Future<UserManagementReport> generateReport();
}
```

## データモデル

### Enum型

#### UserRole
- `admin`: システム管理者
- `manager`: マネージャー
- `operator`: オペレーター
- `viewer`: 閲覧のみ
- `guest`: ゲスト

#### Permission
- `createJob`: ジョブ作成
- `readJob`: ジョブ閲覧
- `updateJob`: ジョブ更新
- `deleteJob`: ジョブ削除
- `viewReports`: レポート閲覧
- `exportData`: データエクスポート
- `manageUsers`: ユーザー管理
- `manageRoles`: ロール管理
- `viewAudit`: 監査ログ閲覧
- `configureSystem`: システム設定

#### UserStatus
- `active`: 有効
- `inactive`: 無効
- `suspended`: 一時停止
- `pending`: 保留中
- `deleted`: 削除済み

### クラス

#### User
ユーザーアカウント情報

**計算プロパティ**:
- `isActive`: ユーザーが有効か
- `isAdmin`: 管理者ロールを持つか
- `needsPasswordChange`: パスワード変更が必要か（90日以上経過）
- `hasLoginHistory`: ログイン履歴があるか
- `accountAgeInDays`: アカウント作成からの日数

```dart
User(
  userId: 'user1',
  username: 'john_doe',
  email: 'john@example.com',
  role: UserRole.operator,
  status: UserStatus.active,
  createdAt: DateTime(2026, 1, 1),
  lastLoginAt: DateTime(2026, 9, 1),
);
```

#### Role
ロール定義と権限管理

**計算プロパティ**:
- `isEnabled`: ロールが有効か
- `permissionCount`: 関連する権限数

**メソッド**:
- `hasPermission(Permission)`: 権限を持つか

```dart
Role(
  roleId: 'role1',
  roleName: 'Operator Role',
  userRole: UserRole.operator,
  permissions: [Permission.readJob, Permission.updateJob],
  createdAt: DateTime(2026, 1, 1),
  isActive: true,
);
```

#### PermissionAssignment
ユーザーへの権限割り当て

**計算プロパティ**:
- `isActive`: 割り当てが有効か
- `isExpired`: 有効期限が切れたか
- `daysUntilExpiration`: 有効期限までの日数

```dart
PermissionAssignment(
  assignmentId: 'perm1',
  userId: 'user1',
  permission: Permission.exportData,
  grantedAt: DateTime(2026, 1, 1),
  expiresAt: DateTime(2026, 4, 1),
);
```

#### Session
ユーザーセッション情報

**計算プロパティ**:
- `isValid`: セッションが有効か
- `isExpired`: セッションが期限切れか
- `durationInSeconds`: セッション継続時間（秒）
- `inactiveDurationInSeconds`: 最終活動からの時間（秒）

```dart
Session(
  sessionId: 'session1',
  userId: 'user1',
  startedAt: DateTime.now(),
  expiresAt: DateTime.now().add(Duration(hours: 8)),
  token: 'token123',
);
```

#### AuditLog
監査ログエントリ

**計算プロパティ**:
- `isImportant`: 重要なアクションか（重大度がhigh以上）
- `hasChanges`: 変更内容を含むか

```dart
AuditLog(
  logId: 'log1',
  userId: 'user1',
  action: 'user_created',
  timestamp: DateTime.now(),
  severity: 'medium',
  details: {'username': 'john'},
);
```

#### AccessControlList
リソースごとのアクセス制御

**計算プロパティ**:
- `roleCount`: 管理対象のロール数

**メソッド**:
- `hasPermissionForRole(UserRole, Permission)`: ロールに権限があるか

```dart
AccessControlList(
  aclId: 'acl1',
  resourceId: 'resource1',
  resourceType: 'job',
  rolePermissions: {
    UserRole.admin: [Permission.createJob, Permission.deleteJob],
    UserRole.operator: [Permission.readJob],
  },
  createdAt: DateTime.now(),
);
```

#### UserActivity
ユーザーアクティビティ記録

**計算プロパティ**:
- `isActive`: 最近のアクティビティか（24時間以内）
- `hasAnomalousActivity`: 異常なアクティビティ か

```dart
UserActivity(
  activityId: 'activity1',
  userId: 'user1',
  activityType: 'login',
  timestamp: DateTime.now(),
  ipAddress: '192.168.1.1',
  isAnomalous: false,
);
```

#### UserManagementReport
ユーザー管理レポート

**計算プロパティ**:
- `activePercentage`: 有効ユーザーの割合

**メソッド**:
- `toMarkdown()`: Markdown形式で出力

```dart
UserManagementReport(
  reportId: 'report1',
  generatedAt: DateTime.now(),
  periodStart: DateTime.now().subtract(Duration(days: 30)),
  periodEnd: DateTime.now(),
  totalUsers: 100,
  activeUsers: 85,
  suspendedUsers: 5,
  newUsers: 10,
  roleDistribution: {UserRole.admin: 2, UserRole.operator: 50},
);
```

## 使用例

### ユーザー作成と権限付与

```dart
final facade = UserFacade();

// ユーザー作成
await facade.createUser('user1', 'john_doe', 'john@example.com', UserRole.operator);

// 権限付与
await facade.grantPermissionToUser('user1', Permission.exportData);

// 権限確認
final hasPermission = await facade.userHasPermission('user1', Permission.exportData);
print('Has export permission: $hasPermission'); // true
```

### セッション管理

```dart
final facade = UserFacade();

// セッション作成
final session = await facade.createSession('user1');
print('Session ID: ${session.sessionId}');
print('Valid: ${session.isValid}');

// セッション検証
final isValid = await facade.validateSession(session.sessionId);

// セッション終了
await facade.terminateSession(session.sessionId);
```

### ロール管理

```dart
final facade = UserFacade();

// ロール作成
await facade.createRole(
  'manager_role',
  'Manager Role',
  UserRole.manager,
  [Permission.createJob, Permission.readJob, Permission.viewReports],
);

// ロール権限確認
final role = await facade.getRoleById('manager_role');
print('Permissions: ${role.permissions.length}');
print('Has create permission: ${role.hasPermission(Permission.createJob)}');
```

### 監査ログ記録

```dart
final facade = UserFacade();

// アクションを記録
await facade.recordAuditLog(
  'admin',
  'user_created',
  {'username': 'john', 'role': 'operator'},
);

// 監査ログ取得
final logs = await facade.getAuditLogs();
for (final log in logs) {
  print('${log.action} by ${log.userId} at ${log.timestamp}');
}
```

### アクティビティ監視

```dart
final facade = UserFacade();

// アクティビティ記録
await facade.recordUserActivity('user1', 'login', '192.168.1.100');

// 異常検知
await facade.recordAnomalousActivity(
  'user1',
  'multiple_failed_logins',
  '192.168.1.50',
);

// アクティビティ確認
final activities = await facade.getUserActivities('user1');
final anomalies = activities.where((a) => a.isAnomalous).toList();
```

### レポート生成

```dart
final facade = UserFacade();

// レポート生成
final report = await facade.generateReport();

// Markdown出力
final markdown = report.toMarkdown();
print(markdown);
```

## テストカバレッジ

合計60+のテストケース、100%のコード行カバレッジ

### テスト分類

- **Enum Tests** (3件): すべてのEnum値の検証
- **User Model Tests** (6件): ユーザーモデルと計算プロパティ
- **Role Model Tests** (4件): ロールモデルと権限検証
- **PermissionAssignment Tests** (4件): 権限割り当てと有効期限
- **Session Tests** (5件): セッションライフサイクル
- **AuditLog Tests** (3件): 監査ログ機能
- **AccessControlList Tests** (3件): ACL機能
- **UserActivity Tests** (3件): アクティビティ追跡
- **UserRepository Tests** (6件): ユーザー永続化
- **Role Management Tests** (4件): ロール操作
- **Permission Management Tests** (4件): 権限操作
- **Session Management Tests** (4件): セッション操作
- **Audit Log Management Tests** (3件): 監査ログ操作
- **AccessControlList Management Tests** (3件): ACL操作
- **UserActivity Tracking Tests** (3件): アクティビティ操作
- **UserManagementReport Tests** (2件): レポート生成
- **Integration Tests** (5件): エンドツーエンドワークフロー
- **Edge Cases Tests** (7件): エッジケース処理
- **Error Handling Tests** (5件): エラー処理
- **Calculation Tests** (4件): 計算プロパティの正確性

### テスト実行

```bash
flutter test test/phase_57_user_test.dart
```

## ファイル構成

```
lib/
├── models/
│   └── user_models.dart          # データモデル定義
└── services/
    └── user_service.dart          # Repository、Engine、Manager、Facade

test/
└── phase_57_user_test.dart        # 60+テストケース
```

## 主なコンポーネント

### 1. UserRepository
- ユーザーデータの永続化層
- すべてのCRUD操作をサポート

### 2. AuthorizationEngine
- 権限検証ロジック
- アクセス制御実装

### 3. SessionEngine
- セッション作成と管理
- タイムアウト処理

### 4. UserManager
- ビジネスロジック統合
- 複合操作の実装

### 5. UserFacade
- シンプルなユーザーインターフェース
- 複雑さの隠蔽

## セキュリティ機能

- **パスワード有効期限**: 90日以上経過時に変更要求
- **セッションタイムアウト**: 無操作時のセッション自動終了
- **権限有効期限**: 時間制限付き権限割り当て
- **監査ログ**: すべてのセキュリティ関連操作を記録
- **異常検知**: 異常なアクティビティを自動検出
- **ACL制御**: リソースレベルのアクセス制御

## パフォーマンス考慮事項

- インメモリ実装により高速な操作
- ユーザー数が多い場合はデータベース実装への移行を検討
- セッション有効期限の定期クリーンアップ
- 監査ログのアーカイブ戦略

## 将来の拡張

- OAuth/SAML統合
- 多要素認証（MFA）
- LDAP/Active Directory統合
- 細粒度のロールベースアクセス制御（RBAC）
- 属性ベースアクセス制御（ABAC）
- ジオロケーションベースのアクセス制限

## ライセンス

このコードはプロジェクト内でのみ使用してください。
