/// Phase 58: Database Persistence & Transactions データベース永続化・トランザクション管理
///
/// データベース接続、トランザクション、マイグレーション、バックアップ機能

/// データベースタイプ
enum DatabaseType {
  sqlite('sqlite'),
  postgresql('postgresql'),
  mysql('mysql'),
  mongodb('mongodb'),
  firestore('firestore');

  final String value;
  const DatabaseType(this.value);
}

/// トランザクションステータス
enum TransactionStatus {
  pending('pending'),
  inProgress('in_progress'),
  committed('committed'),
  rolledBack('rolled_back'),
  failed('failed');

  final String value;
  const TransactionStatus(this.value);
}

/// マイグレーションステータス
enum MigrationStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  failed('failed'),
  rolledBack('rolled_back');

  final String value;
  const MigrationStatus(this.value);
}

/// バックアップタイプ
enum BackupType {
  full('full'),
  incremental('incremental'),
  differential('differential'),
  snapshot('snapshot');

  final String value;
  const BackupType(this.value);
}

/// バックアップステータス
enum BackupStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  failed('failed'),
  archived('archived');

  final String value;
  const BackupStatus(this.value);
}

/// インデックスタイプ
enum IndexType {
  primary('primary'),
  unique('unique'),
  composite('composite'),
  fulltext('fulltext'),
  spatial('spatial');

  final String value;
  const IndexType(this.value);
}

/// データベース接続設定
class DatabaseConnection {
  final String connectionId;
  final DatabaseType databaseType;
  final String host;
  final int port;
  final String database;
  final String username;
  final String password;
  final int maxConnections;
  final int connectionTimeout;
  final DateTime createdAt;
  final bool isActive;
  final String? ssl;

  DatabaseConnection({
    required this.connectionId,
    required this.databaseType,
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.password,
    this.maxConnections = 10,
    this.connectionTimeout = 30,
    required this.createdAt,
    this.isActive = true,
    this.ssl,
  });

  /// 接続が有効か
  bool get isEnabled => isActive;

  /// 接続情報は完全か
  bool get isComplete => host.isNotEmpty && database.isNotEmpty && username.isNotEmpty;

  /// 接続タイムアウト秒数
  int get timeoutSeconds => connectionTimeout;
}

/// トランザクション
class Transaction {
  final String transactionId;
  final String connectionId;
  final DateTime startedAt;
  final DateTime? committedAt;
  final DateTime? rolledBackAt;
  final TransactionStatus status;
  final List<String> operations;
  final String? rollbackReason;
  final int isolationLevel;

  Transaction({
    required this.transactionId,
    required this.connectionId,
    required this.startedAt,
    this.committedAt,
    this.rolledBackAt,
    this.status = TransactionStatus.pending,
    this.operations = const [],
    this.rollbackReason,
    this.isolationLevel = 1,
  });

  /// トランザクションが有効か
  bool get isActive => status == TransactionStatus.inProgress;

  /// トランザクションが完了したか
  bool get isCompleted => status == TransactionStatus.committed || status == TransactionStatus.rolledBack;

  /// トランザクション継続時間（秒）
  int get durationInSeconds {
    final endTime = committedAt ?? rolledBackAt ?? DateTime.now();
    return endTime.difference(startedAt).inSeconds;
  }

  /// 操作数
  int get operationCount => operations.length;

  /// トランザクションが失敗したか
  bool get hasFailed => status == TransactionStatus.failed;
}

/// データベーススキーマ
class DatabaseSchema {
  final String schemaId;
  final String schemaName;
  final int version;
  final List<String> tables;
  final List<String> indexes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  DatabaseSchema({
    required this.schemaId,
    required this.schemaName,
    required this.version,
    required this.tables,
    required this.indexes,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  /// スキーマが有効か
  bool get isEnabled => isActive;

  /// テーブル数
  int get tableCount => tables.length;

  /// インデックス数
  int get indexCount => indexes.length;

  /// スキーマバージョン
  String get versionString => 'v$version';
}

/// マイグレーション
class Migration {
  final String migrationId;
  final String migrationName;
  final int version;
  final String upScript;
  final String downScript;
  final MigrationStatus status;
  final DateTime createdAt;
  final DateTime? appliedAt;
  final DateTime? rolledBackAt;
  final String? errorMessage;

  Migration({
    required this.migrationId,
    required this.migrationName,
    required this.version,
    required this.upScript,
    required this.downScript,
    this.status = MigrationStatus.pending,
    required this.createdAt,
    this.appliedAt,
    this.rolledBackAt,
    this.errorMessage,
  });

  /// マイグレーションが完了したか
  bool get isCompleted => status == MigrationStatus.completed;

  /// マイグレーションが保留中か
  bool get isPending => status == MigrationStatus.pending;

  /// マイグレーションが失敗したか
  bool get hasFailed => status == MigrationStatus.failed;

  /// 適用済みか
  bool get isApplied => appliedAt != null;

  /// 実行時間（秒）
  int? get executionTimeInSeconds {
    if (appliedAt == null) return null;
    return appliedAt!.difference(createdAt).inSeconds;
  }
}

/// データベースインデックス
class DatabaseIndex {
  final String indexId;
  final String indexName;
  final String tableName;
  final List<String> columns;
  final IndexType indexType;
  final bool isUnique;
  final bool isActive;
  final DateTime createdAt;

  DatabaseIndex({
    required this.indexId,
    required this.indexName,
    required this.tableName,
    required this.columns,
    required this.indexType,
    this.isUnique = false,
    this.isActive = true,
    required this.createdAt,
  });

  /// インデックスが有効か
  bool get isEnabled => isActive;

  /// カラム数
  int get columnCount => columns.length;

  /// 複合インデックスか
  bool get isComposite => columns.length > 1;
}

/// バックアップ
class Backup {
  final String backupId;
  final String backupName;
  final BackupType backupType;
  final int size; // バイト単位
  final DateTime createdAt;
  final DateTime? completedAt;
  final BackupStatus status;
  final String location;
  final bool isEncrypted;
  final String? encryptionMethod;
  final int? retentionDays;

  Backup({
    required this.backupId,
    required this.backupName,
    required this.backupType,
    required this.size,
    required this.createdAt,
    this.completedAt,
    this.status = BackupStatus.pending,
    required this.location,
    this.isEncrypted = false,
    this.encryptionMethod,
    this.retentionDays,
  });

  /// バックアップが完了したか
  bool get isCompleted => status == BackupStatus.completed;

  /// バックアップが失敗したか
  bool get hasFailed => status == BackupStatus.failed;

  /// バックアップサイズ（MB）
  double get sizeInMB => size / (1024 * 1024);

  /// バックアップが有効期限内か
  bool get isWithinRetention {
    if (retentionDays == null) return true;
    final expiryDate = createdAt.add(Duration(days: retentionDays!));
    return DateTime.now().isBefore(expiryDate);
  }

  /// 作成から経過日数
  int get ageInDays => DateTime.now().difference(createdAt).inDays;

  /// 実行時間（秒）
  int? get executionTimeInSeconds {
    if (completedAt == null) return null;
    return completedAt!.difference(createdAt).inSeconds;
  }
}

/// データベースパフォーマンス統計
class DatabasePerformanceStats {
  final String statsId;
  final int totalQueries;
  final int slowQueries; // >1秒
  final double averageQueryTime; // ミリ秒
  final double maxQueryTime;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int cacheHitRate; // 0-100
  final int lockContention;
  final double diskUsage; // GB

  DatabasePerformanceStats({
    required this.statsId,
    required this.totalQueries,
    required this.slowQueries,
    required this.averageQueryTime,
    required this.maxQueryTime,
    required this.periodStart,
    required this.periodEnd,
    required this.cacheHitRate,
    required this.lockContention,
    required this.diskUsage,
  });

  /// パフォーマンスが良好か
  bool get isHealthy => averageQueryTime < 100 && cacheHitRate > 80;

  /// スローカウント（%）
  double get slowQueryPercentage {
    if (totalQueries == 0) return 0.0;
    return (slowQueries / totalQueries) * 100;
  }

  /// キャッシュヒット率は高いか
  bool get hasHighCacheHitRate => cacheHitRate > 90;

  /// ディスク使用率は高いか
  bool get hasHighDiskUsage => diskUsage > 100; // 100GB以上
}

/// データベース接続プール
class ConnectionPool {
  final String poolId;
  final String poolName;
  final int maxSize;
  final int currentSize;
  final int availableConnections;
  final int busyConnections;
  final DateTime createdAt;
  final bool isActive;

  ConnectionPool({
    required this.poolId,
    required this.poolName,
    required this.maxSize,
    required this.currentSize,
    required this.availableConnections,
    required this.busyConnections,
    required this.createdAt,
    this.isActive = true,
  });

  /// プールが有効か
  bool get isEnabled => isActive;

  /// 利用率（%）
  double get utilizationPercentage {
    if (maxSize == 0) return 0.0;
    return (busyConnections / maxSize) * 100;
  }

  /// プールは満杯か
  bool get isFull => currentSize >= maxSize;

  /// プールは飽和状態か
  bool get isSaturated => utilizationPercentage > 90;

  /// 平均アイドル接続数
  int get averageIdleConnections => availableConnections;
}

/// データベースレプリケーション
class DatabaseReplication {
  final String replicationId;
  final String sourceDatabaseId;
  final String targetDatabaseId;
  final String status; // active, paused, failed
  final int lag; // ミリ秒
  final DateTime createdAt;
  final DateTime? lastSyncAt;
  final bool isBidirectional;
  final int replicationFactor;

  DatabaseReplication({
    required this.replicationId,
    required this.sourceDatabaseId,
    required this.targetDatabaseId,
    required this.status,
    required this.lag,
    required this.createdAt,
    this.lastSyncAt,
    this.isBidirectional = false,
    this.replicationFactor = 1,
  });

  /// レプリケーションが有効か
  bool get isActive => status == 'active';

  /// ラグは許容範囲か
  bool get isWithinAcceptableLag => lag < 5000; // 5秒以内

  /// 同期が最近か
  bool get isRecentlysynced {
    if (lastSyncAt == null) return false;
    return DateTime.now().difference(lastSyncAt!).inMinutes < 5;
  }
}

/// トランザクションログ
class TransactionLog {
  final String logId;
  final String transactionId;
  final String operation; // INSERT, UPDATE, DELETE, SELECT
  final String tableName;
  final Map<String, dynamic>? changes;
  final DateTime timestamp;
  final String status; // success, failure
  final String? errorMessage;
  final int executionTimeMs;

  TransactionLog({
    required this.logId,
    required this.transactionId,
    required this.operation,
    required this.tableName,
    this.changes,
    required this.timestamp,
    this.status = 'success',
    this.errorMessage,
    this.executionTimeMs = 0,
  });

  /// ログが成功したか
  bool get isSuccess => status == 'success';

  /// ログが失敗したか
  bool get hasFailed => status == 'failure';

  /// 実行が遅かったか
  bool get isSlowExecution => executionTimeMs > 1000;
}

/// データベース復旧ポイント
class RecoveryPoint {
  final String recoveryId;
  final String recoveryName;
  final DateTime timestamp;
  final String backupId;
  final int dataSize; // バイト
  final bool isVerified;
  final String? verificationMethod;
  final DateTime? testedAt;

  RecoveryPoint({
    required this.recoveryId,
    required this.recoveryName,
    required this.timestamp,
    required this.backupId,
    required this.dataSize,
    this.isVerified = false,
    this.verificationMethod,
    this.testedAt,
  });

  /// 復旧ポイントが検証済みか
  bool get isVerifiedAndReady => isVerified && testedAt != null;

  /// 復旧ポイント年齢（日）
  int get ageInDays => DateTime.now().difference(timestamp).inDays;

  /// データサイズ（MB）
  double get dataSizeInMB => dataSize / (1024 * 1024);

  /// 復旧ポイントは古いか（30日以上）
  bool get isOld => ageInDays > 30;
}

/// データベースレポート
class DatabaseReport {
  final String reportId;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalConnections;
  final int activeConnections;
  final int totalQueries;
  final double averageQueryTime;
  final List<String> performanceIssues;
  final List<String>? recommendations;

  DatabaseReport({
    required this.reportId,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.totalConnections,
    required this.activeConnections,
    required this.totalQueries,
    required this.averageQueryTime,
    required this.performanceIssues,
    this.recommendations,
  });

  /// レポートが良好か
  bool get isHealthy => performanceIssues.isEmpty;

  /// 接続使用率（%）
  double get connectionUtilization {
    if (totalConnections == 0) return 0.0;
    return (activeConnections / totalConnections) * 100;
  }

  /// Markdown形式で出力
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Database Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');

    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Period: ${periodStart.toIso8601String()} to ${periodEnd.toIso8601String()}');
    buffer.writeln('- Total Connections: $totalConnections');
    buffer.writeln('- Active Connections: $activeConnections');
    buffer.writeln('- Connection Utilization: ${connectionUtilization.toStringAsFixed(1)}%');
    buffer.writeln('- Total Queries: $totalQueries');
    buffer.writeln('- Average Query Time: ${averageQueryTime.toStringAsFixed(2)}ms');
    buffer.writeln('');

    if (performanceIssues.isNotEmpty) {
      buffer.writeln('## Performance Issues');
      buffer.writeln('');
      for (final issue in performanceIssues.take(10)) {
        buffer.writeln('- $issue');
      }
      buffer.writeln('');
    }

    if (recommendations != null && recommendations!.isNotEmpty) {
      buffer.writeln('## Recommendations');
      buffer.writeln('');
      for (final rec in recommendations!.take(5)) {
        buffer.writeln('- $rec');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}
