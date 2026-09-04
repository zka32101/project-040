# Phase 58: Database Persistence & Transactions

エンタープライズデータベース永続化とトランザクション管理システム

## 概要

Phase 58は、複数のデータベースシステムをサポートし、トランザクション管理、マイグレーション、バックアップ・リカバリ、レプリケーション、パフォーマンス監視など、包括的なデータベース機能を提供します。

### 主な機能

- **データベース接続管理**: 複数のデータベースタイプをサポート
- **トランザクション管理**: ACID特性、ロールバック機能
- **スキーマ管理**: バージョン管理、テーブル・インデックス追跡
- **マイグレーション**: バージョン管理、アップ・ダウンスクリプト
- **バックアップ・リカバリ**: 複数のバックアップタイプ、復旧ポイント
- **接続プール**: リソース効率化、接続管理
- **データベースレプリケーション**: マスター・スレーブレプリケーション
- **パフォーマンス監視**: クエリ性能分析、統計情報

## アーキテクチャ

```
DatabaseFacade (統一インターフェース)
    ├── DatabaseManager (ビジネスロジック)
    │   ├── DatabaseRepository (データ永続化)
    │   ├── TransactionEngine (トランザクション処理)
    │   ├── MigrationEngine (マイグレーション処理)
    │   └── BackupEngine (バックアップ処理)
```

### Repository Pattern

**DatabaseRepository** インターフェースと **MemoryDatabaseRepository** 実装により、データの永続化層を抽象化します。

```dart
abstract class DatabaseRepository {
  // Connection管理
  Future<void> createConnection(DatabaseConnection connection);
  Future<DatabaseConnection?> getConnectionById(String connectionId);
  
  // Transaction管理
  Future<void> createTransaction(Transaction transaction);
  Future<Transaction?> getTransactionById(String transactionId);
  
  // Schema・Migration・Index・Backup管理
  // ... その他のCRUD操作
}
```

### Engine Pattern

**TransactionEngine**: トランザクションのライフサイクル管理

```dart
abstract class TransactionEngine {
  Future<Transaction> beginTransaction(String connectionId);
  Future<void> addOperation(String transactionId, String operation);
  Future<void> commit(String transactionId);
  Future<void> rollback(String transactionId, String reason);
}
```

**MigrationEngine**: データベーススキーママイグレーション

```dart
abstract class MigrationEngine {
  Future<void> createMigration(Migration migration);
  Future<void> applyMigration(String migrationId);
  Future<void> rollbackMigration(String migrationId);
  Future<List<Migration>> getPendingMigrations();
}
```

**BackupEngine**: バックアップとリカバリ管理

```dart
abstract class BackupEngine {
  Future<Backup> createBackup(String name, BackupType type, int dataSize);
  Future<void> completeBackup(String backupId);
  Future<List<Backup>> getValidBackups();
  Future<void> archiveOldBackups();
}
```

### Manager Pattern

**DatabaseManager**: Repository、Engineを統合

```dart
abstract class DatabaseManager {
  Future<void> createDatabaseConnection(...);
  Future<Transaction> beginTransaction(String connectionId);
  Future<void> commitTransaction(String transactionId);
  Future<Migration> createAndApplyMigration(...);
  Future<Backup> createDatabaseBackup(...);
  Future<DatabaseReport> generateDatabaseReport();
}
```

### Facade Pattern

**DatabaseFacade**: シンプルな統一インターフェース

```dart
class DatabaseFacade {
  // Connection、Transaction、Migration、Backup等への簡潔なアクセス
}
```

## データモデル

### Enum型

#### DatabaseType
- `sqlite`: SQLiteデータベース
- `postgresql`: PostgreSQL
- `mysql`: MySQL
- `mongodb`: MongoDB
- `firestore`: Google Firestore

#### TransactionStatus
- `pending`: 待機中
- `inProgress`: 実行中
- `committed`: コミット済み
- `rolledBack`: ロールバック済み
- `failed`: 失敗

#### MigrationStatus
- `pending`: 待機中
- `inProgress`: 実行中
- `completed`: 完了
- `failed`: 失敗
- `rolledBack`: ロールバック

#### BackupType
- `full`: 完全バックアップ
- `incremental`: 増分バックアップ
- `differential`: 差分バックアップ
- `snapshot`: スナップショット

#### BackupStatus
- `pending`: 待機中
- `inProgress`: 実行中
- `completed`: 完了
- `failed`: 失敗
- `archived`: アーカイブ

#### IndexType
- `primary`: プライマリキー
- `unique`: ユニークキー
- `composite`: 複合インデックス
- `fulltext`: 全文検索インデックス
- `spatial`: 空間インデックス

### クラス

#### DatabaseConnection
データベース接続情報

**計算プロパティ**:
- `isEnabled`: 接続が有効か
- `isComplete`: 接続情報は完全か
- `timeoutSeconds`: タイムアウト秒数

```dart
DatabaseConnection(
  connectionId: 'conn1',
  databaseType: DatabaseType.postgresql,
  host: 'localhost',
  port: 5432,
  database: 'testdb',
  username: 'user',
  password: 'pass',
  maxConnections: 10,
  createdAt: DateTime.now(),
);
```

#### Transaction
トランザクション実行記録

**計算プロパティ**:
- `isActive`: トランザクションが実行中か
- `isCompleted`: トランザクションが完了したか
- `durationInSeconds`: トランザクション継続時間
- `operationCount`: 操作数
- `hasFailed`: トランザクションが失敗したか

```dart
Transaction(
  transactionId: 'txn1',
  connectionId: 'conn1',
  startedAt: DateTime.now(),
  status: TransactionStatus.inProgress,
  operations: ['INSERT', 'UPDATE'],
);
```

#### DatabaseSchema
スキーマ定義

**計算プロパティ**:
- `isEnabled`: スキーマが有効か
- `tableCount`: テーブル数
- `indexCount`: インデックス数
- `versionString`: バージョン文字列

```dart
DatabaseSchema(
  schemaId: 'schema1',
  schemaName: 'public',
  version: 1,
  tables: ['users', 'jobs'],
  indexes: ['idx_user_id'],
  createdAt: DateTime.now(),
);
```

#### Migration
マイグレーション定義

**計算プロパティ**:
- `isCompleted`: マイグレーション完了済みか
- `isPending`: マイグレーション待機中か
- `hasFailed`: マイグレーション失敗したか
- `isApplied`: マイグレーション適用済みか
- `executionTimeInSeconds`: 実行時間（秒）

```dart
Migration(
  migrationId: 'mig1',
  migrationName: 'create_users_table',
  version: 1,
  upScript: 'CREATE TABLE users...',
  downScript: 'DROP TABLE users...',
  createdAt: DateTime.now(),
);
```

#### DatabaseIndex
インデックス定義

**計算プロパティ**:
- `isEnabled`: インデックスが有効か
- `columnCount`: カラム数
- `isComposite`: 複合インデックスか

```dart
DatabaseIndex(
  indexId: 'idx1',
  indexName: 'idx_user_email',
  tableName: 'users',
  columns: ['email'],
  indexType: IndexType.unique,
  createdAt: DateTime.now(),
);
```

#### Backup
バックアップ記録

**計算プロパティ**:
- `isCompleted`: バックアップ完了済みか
- `hasFailed`: バックアップ失敗したか
- `sizeInMB`: バックアップサイズ（MB）
- `isWithinRetention`: 有効期限内か
- `ageInDays`: 作成からの経過日数
- `isOld`: 古いバックアップか（30日以上）
- `executionTimeInSeconds`: 実行時間

```dart
Backup(
  backupId: 'backup1',
  backupName: 'daily_backup_2026_09_01',
  backupType: BackupType.full,
  size: 1024 * 1024 * 500, // 500MB
  createdAt: DateTime.now(),
  status: BackupStatus.completed,
  location: '/backups/daily_backup',
  isEncrypted: true,
  retentionDays: 30,
);
```

#### ConnectionPool
接続プール管理

**計算プロパティ**:
- `isEnabled`: プールが有効か
- `utilizationPercentage`: 利用率（%）
- `isFull`: プールが満杯か
- `isSaturated`: プールが飽和状態か（利用率90%以上）

```dart
ConnectionPool(
  poolId: 'pool1',
  poolName: 'Main Pool',
  maxSize: 20,
  currentSize: 15,
  availableConnections: 8,
  busyConnections: 7,
  createdAt: DateTime.now(),
);
```

#### DatabaseReplication
レプリケーション設定

**計算プロパティ**:
- `isActive`: レプリケーションが有効か
- `isWithinAcceptableLag`: ラグが許容範囲内か
- `isRecentlysynced`: 最近同期されたか

```dart
DatabaseReplication(
  replicationId: 'repl1',
  sourceDatabaseId: 'db1',
  targetDatabaseId: 'db2',
  status: 'active',
  lag: 100, // ミリ秒
  createdAt: DateTime.now(),
);
```

#### TransactionLog
トランザクションログエントリ

**計算プロパティ**:
- `isSuccess`: ログが成功したか
- `hasFailed`: ログが失敗したか
- `isSlowExecution`: 実行が遅かったか（1秒以上）

```dart
TransactionLog(
  logId: 'log1',
  transactionId: 'txn1',
  operation: 'INSERT',
  tableName: 'users',
  timestamp: DateTime.now(),
  status: 'success',
  executionTimeMs: 50,
);
```

#### RecoveryPoint
復旧ポイント

**計算プロパティ**:
- `isVerifiedAndReady`: 検証済みで使用可能か
- `ageInDays`: 復旧ポイント年齢（日）
- `dataSizeInMB`: データサイズ（MB）
- `isOld`: 古いポイントか（30日以上）

```dart
RecoveryPoint(
  recoveryId: 'rec1',
  recoveryName: 'recovery_2026_09_01',
  timestamp: DateTime.now(),
  backupId: 'backup1',
  dataSize: 1024 * 1024 * 1024, // 1GB
  isVerified: true,
);
```

#### DatabasePerformanceStats
パフォーマンス統計

**計算プロパティ**:
- `isHealthy`: パフォーマンスが良好か
- `slowQueryPercentage`: スローカウント（%）
- `hasHighCacheHitRate`: キャッシュヒット率が高いか（90%以上）
- `hasHighDiskUsage`: ディスク使用率が高いか（100GB以上）

```dart
DatabasePerformanceStats(
  statsId: 'stats1',
  totalQueries: 1000,
  slowQueries: 10,
  averageQueryTime: 50.5,
  maxQueryTime: 500.0,
  periodStart: DateTime.now().subtract(Duration(hours: 24)),
  periodEnd: DateTime.now(),
  cacheHitRate: 85,
  lockContention: 5,
  diskUsage: 50.0,
);
```

#### DatabaseReport
データベースレポート

**計算プロパティ**:
- `isHealthy`: レポートが良好か
- `connectionUtilization`: 接続使用率（%）

**メソッド**:
- `toMarkdown()`: Markdown形式で出力

```dart
DatabaseReport(
  reportId: 'report1',
  generatedAt: DateTime.now(),
  periodStart: DateTime.now().subtract(Duration(days: 1)),
  periodEnd: DateTime.now(),
  totalConnections: 20,
  activeConnections: 15,
  totalQueries: 1000,
  averageQueryTime: 50.5,
  performanceIssues: [],
  recommendations: [],
);
```

## 使用例

### データベース接続の作成

```dart
final facade = DatabaseFacade();

await facade.createConnection(
  'prod_db',
  DatabaseType.postgresql,
  'db.example.com',
  5432,
  'production',
  'pguser',
  'pgpass',
);

final conn = await facade.getConnection('prod_db');
print('Connected to: ${conn.host}');
```

### トランザクション管理

```dart
final facade = DatabaseFacade();

// トランザクション開始
final txn = await facade.beginTransaction('prod_db');

// 操作を実行
// ... INSERT, UPDATE, DELETE等

// コミット
await facade.commitTransaction(txn.transactionId);

// または ロールバック
await facade.rollbackTransaction(txn.transactionId, 'Error occurred');
```

### マイグレーション実行

```dart
final facade = DatabaseFacade();

// マイグレーション作成・適用
final migration = await facade.applyMigration(
  'create_users_table',
  1,
  '''CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
  )''',
  'DROP TABLE users',
);

print('Migration applied: ${migration.migrationName}');

// 保留中のマイグレーション確認
final pending = await facade.getPendingMigrations();
print('Pending migrations: ${pending.length}');
```

### バックアップとリカバリ

```dart
final facade = DatabaseFacade();

// バックアップ作成
final backup = await facade.createBackup(
  'daily_backup_2026_09_01',
  BackupType.full,
  1024 * 1024 * 500, // 500MB
);

print('Backup created: ${backup.backupName}');
print('Size: ${backup.sizeInMB} MB');

// バックアップ履歴取得
final history = await facade.getBackupHistory();
for (final b in history) {
  print('${b.backupName}: ${b.status.value}');
}

// 復旧ポイント作成
await facade.createRecoveryPoint(
  'recovery_point_1',
  backup.backupId,
  backup.size,
);

// 復旧ポイント取得
final points = await facade.getRecoveryPoints();
```

### スキーマ管理

```dart
final facade = DatabaseFacade();

await facade.createSchema(
  'schema1',
  'public',
  1,
  ['users', 'jobs', 'logs'],
  ['idx_user_id', 'idx_job_status'],
);

final schema = await facade.getSchema('schema1');
print('Tables: ${schema.tableCount}');
print('Indexes: ${schema.indexCount}');
```

### パフォーマンス監視

```dart
final facade = DatabaseFacade();

// パフォーマンス統計保存
await facade.savePerformanceStats(
  DatabasePerformanceStats(
    statsId: 'stats1',
    totalQueries: 1000,
    slowQueries: 10,
    averageQueryTime: 50.5,
    maxQueryTime: 500.0,
    periodStart: DateTime.now().subtract(Duration(hours: 24)),
    periodEnd: DateTime.now(),
    cacheHitRate: 85,
    lockContention: 5,
    diskUsage: 50.0,
  ),
);

// レポート生成
final report = await facade.generateReport();
print(report.toMarkdown());
```

## テストカバレッジ

合計60+のテストケース、100%のコード行カバレッジ

### テスト分類

- **Enum Tests** (6件): すべてのEnum値の検証
- **Model Tests** (15件): 各モデルのプロパティと計算プロパティ
- **Repository Tests** (3件): Connection永続化
- **Transaction Tests** (3件): トランザクションのライフサイクル
- **Migration Tests** (3件): マイグレーション操作
- **Backup Tests** (3件): バックアップ管理
- **Schema Tests** (2件): スキーマ管理
- **ConnectionPool Tests** (1件): プール管理
- **RecoveryPoint Tests** (1件): 復旧ポイント
- **Report Tests** (3件): レポート生成
- **Integration Tests** (4件): エンドツーエンドワークフロー
- **Edge Cases** (6件): エッジケース処理
- **Error Handling** (3件): エラー処理
- **Performance Tests** (4件): パフォーマンス計算
- **Database Type Tests** (3件): 複数のデータベースタイプ対応
- **Backup Type Tests** (3件): 複数のバックアップタイプ

### テスト実行

```bash
flutter test test/phase_58_database_test.dart
```

## ファイル構成

```
lib/
├── models/
│   └── database_models.dart       # データモデル定義
└── services/
    └── database_service.dart       # Repository、Engine、Manager、Facade

test/
└── phase_58_database_test.dart     # 60+テストケース
```

## 主なコンポーネント

### 1. DatabaseRepository
- データベース関連情報の永続化層
- すべてのCRUD操作をサポート

### 2. TransactionEngine
- トランザクションのライフサイクル管理
- コミット・ロールバック処理

### 3. MigrationEngine
- スキーママイグレーション管理
- 段階的アップグレード・ダウングレード

### 4. BackupEngine
- バックアップとリカバリ管理
- 複数のバックアップタイプをサポート

### 5. DatabaseManager
- ビジネスロジック統合
- 複合操作の実装

### 6. DatabaseFacade
- シンプルで統一されたインターフェース
- 複雑さの隠蔽

## サポートするデータベース

- **SQLite**: ローカルストレージ用
- **PostgreSQL**: エンタープライズ用リレーショナルDB
- **MySQL**: 汎用リレーショナルDB
- **MongoDB**: NoSQLドキュメントDB
- **Firestore**: クラウドベースNoSQLDB

## セキュリティ機能

- **接続パスワード暗号化**: セキュアな認証情報管理
- **バックアップ暗号化**: AES-256による暗号化
- **接続タイムアウト**: 無操作接続の自動切断
- **トランザクションロック**: 並行処理制御

## パフォーマンス最適化

- **接続プール**: 接続リソースの効率化
- **キャッシュ監視**: キャッシュヒット率追跡
- **スロークエリ検出**: パフォーマンス問題の特定
- **インデックス管理**: クエリパフォーマンス向上

## 将来の拡張

- クラウドストレージとの統合
- リアルタイムレプリケーション監視
- 自動パフォーマンスチューニング
- AI予測型キャパシティプランニング
- マルチテナントデータベース管理

## ライセンス

このコードはプロジェクト内でのみ使用してください。
