import 'package:flutter_test/flutter_test.dart';
import '../lib/models/database_models.dart';
import '../lib/services/database_service.dart';

void main() {
  group('Phase 58: Database Persistence & Transactions', () {
    late DatabaseFacade databaseFacade;

    setUp(() {
      databaseFacade = DatabaseFacade();
    });

    // ===== Enum Tests =====
    group('Enums', () {
      test('DatabaseType enum values', () {
        expect(DatabaseType.sqlite.value, 'sqlite');
        expect(DatabaseType.postgresql.value, 'postgresql');
        expect(DatabaseType.mysql.value, 'mysql');
        expect(DatabaseType.mongodb.value, 'mongodb');
        expect(DatabaseType.firestore.value, 'firestore');
      });

      test('TransactionStatus enum values', () {
        expect(TransactionStatus.pending.value, 'pending');
        expect(TransactionStatus.inProgress.value, 'in_progress');
        expect(TransactionStatus.committed.value, 'committed');
        expect(TransactionStatus.rolledBack.value, 'rolled_back');
      });

      test('MigrationStatus enum values', () {
        expect(MigrationStatus.pending.value, 'pending');
        expect(MigrationStatus.completed.value, 'completed');
        expect(MigrationStatus.failed.value, 'failed');
      });

      test('BackupType enum values', () {
        expect(BackupType.full.value, 'full');
        expect(BackupType.incremental.value, 'incremental');
        expect(BackupType.snapshot.value, 'snapshot');
      });

      test('BackupStatus enum values', () {
        expect(BackupStatus.pending.value, 'pending');
        expect(BackupStatus.completed.value, 'completed');
        expect(BackupStatus.archived.value, 'archived');
      });

      test('IndexType enum values', () {
        expect(IndexType.primary.value, 'primary');
        expect(IndexType.unique.value, 'unique');
        expect(IndexType.composite.value, 'composite');
      });
    });

    // ===== DatabaseConnection Tests =====
    group('DatabaseConnection Model', () {
      test('DatabaseConnection creation', () {
        final conn = DatabaseConnection(
          connectionId: 'conn1',
          databaseType: DatabaseType.postgresql,
          host: 'localhost',
          port: 5432,
          database: 'testdb',
          username: 'user',
          password: 'pass',
          createdAt: DateTime(2026, 1, 1),
        );

        expect(conn.connectionId, 'conn1');
        expect(conn.host, 'localhost');
        expect(conn.port, 5432);
      });

      test('DatabaseConnection isEnabled computed property', () {
        final activeConn = DatabaseConnection(
          connectionId: 'conn1',
          databaseType: DatabaseType.postgresql,
          host: 'localhost',
          port: 5432,
          database: 'testdb',
          username: 'user',
          password: 'pass',
          createdAt: DateTime(2026, 1, 1),
          isActive: true,
        );

        expect(activeConn.isEnabled, true);
      });

      test('DatabaseConnection isComplete computed property', () {
        final complete = DatabaseConnection(
          connectionId: 'conn1',
          databaseType: DatabaseType.postgresql,
          host: 'localhost',
          port: 5432,
          database: 'testdb',
          username: 'user',
          password: 'pass',
          createdAt: DateTime(2026, 1, 1),
        );

        expect(complete.isComplete, true);
      });
    });

    // ===== Transaction Tests =====
    group('Transaction Model', () {
      test('Transaction creation', () {
        final txn = Transaction(
          transactionId: 'txn1',
          connectionId: 'conn1',
          startedAt: DateTime(2026, 9, 1),
          status: TransactionStatus.inProgress,
          operations: ['INSERT', 'UPDATE'],
        );

        expect(txn.transactionId, 'txn1');
        expect(txn.operationCount, 2);
      });

      test('Transaction isActive computed property', () {
        final activeTxn = Transaction(
          transactionId: 'txn1',
          connectionId: 'conn1',
          startedAt: DateTime.now(),
          status: TransactionStatus.inProgress,
        );

        expect(activeTxn.isActive, true);
      });

      test('Transaction isCompleted computed property', () {
        final completedTxn = Transaction(
          transactionId: 'txn1',
          connectionId: 'conn1',
          startedAt: DateTime.now(),
          committedAt: DateTime.now(),
          status: TransactionStatus.committed,
        );

        expect(completedTxn.isCompleted, true);
      });

      test('Transaction durationInSeconds computed property', () {
        final start = DateTime(2026, 9, 1, 10, 0, 0);
        final end = DateTime(2026, 9, 1, 10, 5, 0);
        final txn = Transaction(
          transactionId: 'txn1',
          connectionId: 'conn1',
          startedAt: start,
          committedAt: end,
          status: TransactionStatus.committed,
        );

        expect(txn.durationInSeconds, 300);
      });

      test('Transaction hasFailed computed property', () {
        final failedTxn = Transaction(
          transactionId: 'txn1',
          connectionId: 'conn1',
          startedAt: DateTime.now(),
          status: TransactionStatus.failed,
        );

        expect(failedTxn.hasFailed, true);
      });
    });

    // ===== DatabaseSchema Tests =====
    group('DatabaseSchema Model', () {
      test('DatabaseSchema creation', () {
        final schema = DatabaseSchema(
          schemaId: 'schema1',
          schemaName: 'public',
          version: 1,
          tables: ['users', 'jobs', 'logs'],
          indexes: ['idx_user_id', 'idx_job_status'],
          createdAt: DateTime(2026, 1, 1),
        );

        expect(schema.tableCount, 3);
        expect(schema.indexCount, 2);
      });

      test('DatabaseSchema isEnabled computed property', () {
        final schema = DatabaseSchema(
          schemaId: 'schema1',
          schemaName: 'public',
          version: 1,
          tables: [],
          indexes: [],
          createdAt: DateTime(2026, 1, 1),
          isActive: true,
        );

        expect(schema.isEnabled, true);
      });
    });

    // ===== Migration Tests =====
    group('Migration Model', () {
      test('Migration creation', () {
        final migration = Migration(
          migrationId: 'mig1',
          migrationName: 'create_users_table',
          version: 1,
          upScript: 'CREATE TABLE users...',
          downScript: 'DROP TABLE users...',
          createdAt: DateTime(2026, 1, 1),
        );

        expect(migration.migrationId, 'mig1');
        expect(migration.isPending, true);
      });

      test('Migration isCompleted computed property', () {
        final completed = Migration(
          migrationId: 'mig1',
          migrationName: 'create_users_table',
          version: 1,
          upScript: 'CREATE TABLE users...',
          downScript: 'DROP TABLE users...',
          status: MigrationStatus.completed,
          createdAt: DateTime(2026, 1, 1),
          appliedAt: DateTime(2026, 1, 2),
        );

        expect(completed.isCompleted, true);
      });

      test('Migration executionTimeInSeconds computed property', () {
        final created = DateTime(2026, 1, 1, 10, 0, 0);
        final applied = DateTime(2026, 1, 1, 10, 2, 30);
        final migration = Migration(
          migrationId: 'mig1',
          migrationName: 'create_users_table',
          version: 1,
          upScript: 'CREATE TABLE users...',
          downScript: 'DROP TABLE users...',
          status: MigrationStatus.completed,
          createdAt: created,
          appliedAt: applied,
        );

        expect(migration.executionTimeInSeconds, 150);
      });
    });

    // ===== DatabaseIndex Tests =====
    group('DatabaseIndex Model', () {
      test('DatabaseIndex creation', () {
        final index = DatabaseIndex(
          indexId: 'idx1',
          indexName: 'idx_user_email',
          tableName: 'users',
          columns: ['email'],
          indexType: IndexType.unique,
          createdAt: DateTime(2026, 1, 1),
        );

        expect(index.isComposite, false);
        expect(index.columnCount, 1);
      });

      test('DatabaseIndex isComposite computed property', () {
        final composite = DatabaseIndex(
          indexId: 'idx1',
          indexName: 'idx_user_created',
          tableName: 'users',
          columns: ['user_id', 'created_at'],
          indexType: IndexType.composite,
          createdAt: DateTime(2026, 1, 1),
        );

        expect(composite.isComposite, true);
      });
    });

    // ===== Backup Tests =====
    group('Backup Model', () {
      test('Backup creation', () {
        final backup = Backup(
          backupId: 'backup1',
          backupName: 'daily_backup_2026_09_01',
          backupType: BackupType.full,
          size: 1024 * 1024 * 500, // 500MB
          createdAt: DateTime(2026, 9, 1),
          status: BackupStatus.completed,
          location: '/backups/daily_backup',
        );

        expect(backup.backupId, 'backup1');
        expect(backup.sizeInMB, 500.0);
      });

      test('Backup isCompleted computed property', () {
        final completed = Backup(
          backupId: 'backup1',
          backupName: 'daily_backup',
          backupType: BackupType.full,
          size: 1000000,
          createdAt: DateTime(2026, 9, 1),
          completedAt: DateTime(2026, 9, 1, 1, 0, 0),
          status: BackupStatus.completed,
          location: '/backups/daily',
        );

        expect(completed.isCompleted, true);
      });

      test('Backup isWithinRetention computed property', () {
        final recent = Backup(
          backupId: 'backup1',
          backupName: 'daily_backup',
          backupType: BackupType.full,
          size: 1000000,
          createdAt: DateTime.now(),
          status: BackupStatus.completed,
          location: '/backups/daily',
          retentionDays: 30,
        );

        expect(recent.isWithinRetention, true);
      });

      test('Backup ageInDays computed property', () {
        final createdAt = DateTime.now().subtract(Duration(days: 15));
        final backup = Backup(
          backupId: 'backup1',
          backupName: 'daily_backup',
          backupType: BackupType.full,
          size: 1000000,
          createdAt: createdAt,
          status: BackupStatus.completed,
          location: '/backups/daily',
        );

        expect(backup.ageInDays, 15);
      });
    });

    // ===== ConnectionPool Tests =====
    group('ConnectionPool Model', () {
      test('ConnectionPool creation', () {
        final pool = ConnectionPool(
          poolId: 'pool1',
          poolName: 'Main Pool',
          maxSize: 20,
          currentSize: 15,
          availableConnections: 8,
          busyConnections: 7,
          createdAt: DateTime(2026, 1, 1),
        );

        expect(pool.poolId, 'pool1');
        expect(pool.utilizationPercentage, 35.0);
      });

      test('ConnectionPool utilizationPercentage computed property', () {
        final pool = ConnectionPool(
          poolId: 'pool1',
          poolName: 'Main Pool',
          maxSize: 100,
          currentSize: 100,
          availableConnections: 10,
          busyConnections: 90,
          createdAt: DateTime(2026, 1, 1),
        );

        expect(pool.utilizationPercentage, 90.0);
      });

      test('ConnectionPool isSaturated computed property', () {
        final saturated = ConnectionPool(
          poolId: 'pool1',
          poolName: 'Main Pool',
          maxSize: 100,
          currentSize: 100,
          availableConnections: 5,
          busyConnections: 95,
          createdAt: DateTime(2026, 1, 1),
        );

        expect(saturated.isSaturated, true);
      });
    });

    // ===== DatabaseReplication Tests =====
    group('DatabaseReplication Model', () {
      test('DatabaseReplication creation', () {
        final replication = DatabaseReplication(
          replicationId: 'repl1',
          sourceDatabaseId: 'db1',
          targetDatabaseId: 'db2',
          status: 'active',
          lag: 100,
          createdAt: DateTime(2026, 1, 1),
        );

        expect(replication.replicationId, 'repl1');
        expect(replication.isActive, true);
      });

      test('DatabaseReplication isWithinAcceptableLag computed property', () {
        final lowLag = DatabaseReplication(
          replicationId: 'repl1',
          sourceDatabaseId: 'db1',
          targetDatabaseId: 'db2',
          status: 'active',
          lag: 2000, // 2秒
          createdAt: DateTime(2026, 1, 1),
        );

        expect(lowLag.isWithinAcceptableLag, true);
      });
    });

    // ===== TransactionLog Tests =====
    group('TransactionLog Model', () {
      test('TransactionLog creation', () {
        final log = TransactionLog(
          logId: 'log1',
          transactionId: 'txn1',
          operation: 'INSERT',
          tableName: 'users',
          timestamp: DateTime(2026, 9, 1),
          status: 'success',
          executionTimeMs: 50,
        );

        expect(log.isSuccess, true);
        expect(log.isSlowExecution, false);
      });

      test('TransactionLog isSlowExecution computed property', () {
        final slow = TransactionLog(
          logId: 'log1',
          transactionId: 'txn1',
          operation: 'UPDATE',
          tableName: 'users',
          timestamp: DateTime(2026, 9, 1),
          executionTimeMs: 2000,
        );

        expect(slow.isSlowExecution, true);
      });
    });

    // ===== RecoveryPoint Tests =====
    group('RecoveryPoint Model', () {
      test('RecoveryPoint creation', () {
        final point = RecoveryPoint(
          recoveryId: 'rec1',
          recoveryName: 'recovery_2026_09_01',
          timestamp: DateTime(2026, 9, 1),
          backupId: 'backup1',
          dataSize: 1024 * 1024 * 1024, // 1GB
          isVerified: true,
        );

        expect(point.isVerified, true);
        expect(point.dataSizeInMB, 1024.0);
      });

      test('RecoveryPoint isOld computed property', () {
        final old = RecoveryPoint(
          recoveryId: 'rec1',
          recoveryName: 'recovery_old',
          timestamp: DateTime.now().subtract(Duration(days: 60)),
          backupId: 'backup1',
          dataSize: 1000000,
          isVerified: true,
        );

        expect(old.isOld, true);
      });
    });

    // ===== Repository Tests =====
    group('DatabaseRepository', () {
      test('Create and retrieve connection', () async {
        await databaseFacade.createConnection(
          'conn1',
          DatabaseType.postgresql,
          'localhost',
          5432,
          'testdb',
          'user',
          'pass',
        );

        final conn = await databaseFacade.getConnection('conn1');
        expect(conn, isNotNull);
        expect(conn!.host, 'localhost');
      });

      test('Get all connections', () async {
        await databaseFacade.createConnection(
          'conn1',
          DatabaseType.postgresql,
          'localhost',
          5432,
          'testdb',
          'user',
          'pass',
        );
        await databaseFacade.createConnection(
          'conn2',
          DatabaseType.mysql,
          'localhost',
          3306,
          'testdb',
          'user',
          'pass',
        );

        final conns = await databaseFacade.getAllConnections();
        expect(conns.length, greaterThanOrEqualTo(2));
      });

      test('Get non-existent connection returns null', () async {
        final conn = await databaseFacade.getConnection('nonexistent');
        expect(conn, isNull);
      });
    });

    // ===== Transaction Tests =====
    group('Transaction Management', () {
      test('Begin transaction', () async {
        await databaseFacade.createConnection(
          'conn1',
          DatabaseType.postgresql,
          'localhost',
          5432,
          'testdb',
          'user',
          'pass',
        );

        final txn = await databaseFacade.beginTransaction('conn1');
        expect(txn.isActive, true);
        expect(txn.connectionId, 'conn1');
      });

      test('Commit transaction', () async {
        await databaseFacade.createConnection(
          'conn1',
          DatabaseType.postgresql,
          'localhost',
          5432,
          'testdb',
          'user',
          'pass',
        );

        final txn = await databaseFacade.beginTransaction('conn1');
        await databaseFacade.commitTransaction(txn.transactionId);

        final retrieved = await databaseFacade.getTransaction(txn.transactionId);
        expect(retrieved!.status, TransactionStatus.committed);
      });

      test('Rollback transaction', () async {
        await databaseFacade.createConnection(
          'conn1',
          DatabaseType.postgresql,
          'localhost',
          5432,
          'testdb',
          'user',
          'pass',
        );

        final txn = await databaseFacade.beginTransaction('conn1');
        await databaseFacade.rollbackTransaction(txn.transactionId, 'User request');

        final retrieved = await databaseFacade.getTransaction(txn.transactionId);
        expect(retrieved!.status, TransactionStatus.rolledBack);
      });
    });

    // ===== Migration Tests =====
    group('Migration Management', () {
      test('Apply migration', () async {
        final migration = await databaseFacade.applyMigration(
          'create_users_table',
          1,
          'CREATE TABLE users...',
          'DROP TABLE users...',
        );

        expect(migration.isCompleted, true);
        expect(migration.appliedAt, isNotNull);
      });

      test('Get pending migrations', () async {
        final pending = await databaseFacade.getPendingMigrations();
        expect(pending, isNotNull);
      });

      test('Get applied migrations', () async {
        await databaseFacade.applyMigration(
          'create_users_table',
          1,
          'CREATE TABLE users...',
          'DROP TABLE users...',
        );

        final applied = await databaseFacade.getAppliedMigrations();
        expect(applied.isNotEmpty, true);
      });
    });

    // ===== Backup Tests =====
    group('Backup Management', () {
      test('Create backup', () async {
        final backup = await databaseFacade.createBackup(
          'daily_backup',
          BackupType.full,
          1024 * 1024 * 500,
        );

        expect(backup.isCompleted, true);
        expect(backup.backupName, 'daily_backup');
      });

      test('Get backup history', () async {
        await databaseFacade.createBackup(
          'backup1',
          BackupType.full,
          1000000,
        );
        await databaseFacade.createBackup(
          'backup2',
          BackupType.incremental,
          500000,
        );

        final history = await databaseFacade.getBackupHistory();
        expect(history.length, greaterThanOrEqualTo(2));
      });

      test('Get valid backups', () async {
        await databaseFacade.createBackup(
          'valid_backup',
          BackupType.full,
          1000000,
        );

        final valid = await databaseFacade.getValidBackups();
        expect(valid.isNotEmpty, true);
      });
    });

    // ===== Schema Tests =====
    group('Schema Management', () {
      test('Create schema', () async {
        await databaseFacade.createSchema(
          'schema1',
          'public',
          1,
          ['users', 'jobs'],
          ['idx_user_id'],
        );

        final schema = await databaseFacade.getSchema('schema1');
        expect(schema, isNotNull);
        expect(schema!.tableCount, 2);
      });

      test('Get all schemas', () async {
        await databaseFacade.createSchema(
          'schema1',
          'public',
          1,
          ['users'],
          [],
        );
        await databaseFacade.createSchema(
          'schema2',
          'private',
          1,
          ['logs'],
          [],
        );

        final schemas = await databaseFacade.getAllSchemas();
        expect(schemas.length, greaterThanOrEqualTo(2));
      });
    });

    // ===== ConnectionPool Tests =====
    group('ConnectionPool Management', () {
      test('Create connection pool', () async {
        await databaseFacade.createConnectionPool('pool1', 'Main Pool', 20);

        final pool = await databaseFacade.getConnectionPool('pool1');
        expect(pool, isNotNull);
        expect(pool!.maxSize, 20);
      });
    });

    // ===== RecoveryPoint Tests =====
    group('RecoveryPoint Management', () {
      test('Create recovery point', () async {
        await databaseFacade.createRecoveryPoint('recovery1', 'backup1', 1000000);

        final points = await databaseFacade.getRecoveryPoints();
        expect(points.isNotEmpty, true);
      });
    });

    // ===== Report Tests =====
    group('Database Report', () {
      test('Generate database report', () async {
        final report = await databaseFacade.generateReport();

        expect(report, isNotNull);
        expect(report.reportId, isNotEmpty);
      });

      test('Report toMarkdown output', () async {
        final report = await databaseFacade.generateReport();
        final markdown = report.toMarkdown();

        expect(markdown.contains('Database Report'), true);
        expect(markdown.contains('Summary'), true);
      });

      test('Get latest report', () async {
        await databaseFacade.generateReport();

        final latest = await databaseFacade.getLatestReport();
        expect(latest, isNotNull);
      });
    });

    // ===== Integration Tests =====
    group('Integration Tests', () {
      test('Complete database connection workflow', () async {
        await databaseFacade.createConnection(
          'conn1',
          DatabaseType.postgresql,
          'localhost',
          5432,
          'testdb',
          'user',
          'pass',
        );

        final conn = await databaseFacade.getConnection('conn1');
        expect(conn!.isComplete, true);

        await databaseFacade.createConnectionPool('pool1', 'Main', 20);
        final pool = await databaseFacade.getConnectionPool('pool1');
        expect(pool, isNotNull);
      });

      test('Complete transaction workflow', () async {
        await databaseFacade.createConnection(
          'conn1',
          DatabaseType.postgresql,
          'localhost',
          5432,
          'testdb',
          'user',
          'pass',
        );

        final txn = await databaseFacade.beginTransaction('conn1');
        expect(txn.isActive, true);

        await databaseFacade.commitTransaction(txn.transactionId);
        final committed = await databaseFacade.getTransaction(txn.transactionId);
        expect(committed!.isCompleted, true);
      });

      test('Complete migration workflow', () async {
        final migration = await databaseFacade.applyMigration(
          'create_users_table',
          1,
          'CREATE TABLE users...',
          'DROP TABLE users...',
        );

        expect(migration.isCompleted, true);

        final applied = await databaseFacade.getAppliedMigrations();
        expect(applied.isNotEmpty, true);
      });

      test('Complete backup and recovery workflow', () async {
        final backup = await databaseFacade.createBackup(
          'daily_backup',
          BackupType.full,
          1000000,
        );

        expect(backup.isCompleted, true);

        await databaseFacade.createRecoveryPoint('rec1', backup.backupId, backup.size);
        final points = await databaseFacade.getRecoveryPoints();
        expect(points.isNotEmpty, true);
      });
    });

    // ===== Edge Case Tests =====
    group('Edge Cases', () {
      test('Connection with special characters in password', () async {
        await databaseFacade.createConnection(
          'conn1',
          DatabaseType.postgresql,
          'localhost',
          5432,
          'testdb',
          'user',
          'p@$$w0rd!#%&',
        );

        final conn = await databaseFacade.getConnection('conn1');
        expect(conn!.password, 'p@$$w0rd!#%&');
      });

      test('Backup size calculation for very large database', () {
        final largeBackup = Backup(
          backupId: 'backup1',
          backupName: 'large_backup',
          backupType: BackupType.full,
          size: 1024 * 1024 * 1024 * 500, // 500GB
          createdAt: DateTime(2026, 9, 1),
          status: BackupStatus.completed,
          location: '/backups/large',
        );

        expect(largeBackup.sizeInMB, 512000.0);
      });

      test('Transaction with many operations', () async {
        await databaseFacade.createConnection(
          'conn1',
          DatabaseType.postgresql,
          'localhost',
          5432,
          'testdb',
          'user',
          'pass',
        );

        final txn = await databaseFacade.beginTransaction('conn1');
        expect(txn.operationCount, 0);

        await databaseFacade.commitTransaction(txn.transactionId);
      });

      test('Multiple concurrent connections', () async {
        for (int i = 0; i < 10; i++) {
          await databaseFacade.createConnection(
            'conn$i',
            DatabaseType.postgresql,
            'localhost',
            5432,
            'testdb',
            'user',
            'pass',
          );
        }

        final conns = await databaseFacade.getAllConnections();
        expect(conns.length, greaterThanOrEqualTo(10));
      });

      test('Schema with maximum table count', () async {
        final tables = List.generate(100, (i) => 'table_$i');
        await databaseFacade.createSchema(
          'schema1',
          'large_schema',
          1,
          tables,
          [],
        );

        final schema = await databaseFacade.getSchema('schema1');
        expect(schema!.tableCount, 100);
      });

      test('Backup retention period handling', () {
        final withRetention = Backup(
          backupId: 'backup1',
          backupName: 'backup',
          backupType: BackupType.full,
          size: 1000000,
          createdAt: DateTime.now().subtract(Duration(days: 25)),
          status: BackupStatus.completed,
          location: '/backups/backup',
          retentionDays: 30,
        );

        expect(withRetention.isWithinRetention, true);
      });
    });

    // ===== Error Handling Tests =====
    group('Error Handling', () {
      test('Duplicate connection creation throws exception', () async {
        await databaseFacade.createConnection(
          'conn1',
          DatabaseType.postgresql,
          'localhost',
          5432,
          'testdb',
          'user',
          'pass',
        );

        expect(
          () => databaseFacade.createConnection(
            'conn1',
            DatabaseType.mysql,
            'localhost',
            3306,
            'testdb',
            'user',
            'pass',
          ),
          throwsException,
        );
      });

      test('Non-existent transaction handling', () async {
        final txn = await databaseFacade.getTransaction('nonexistent');
        expect(txn, isNull);
      });

      test('Empty connection list', () async {
        final conns = await databaseFacade.getAllConnections();
        expect(conns, isNotNull);
      });
    });

    // ===== Performance Tests =====
    group('Performance Calculations', () {
      test('Connection pool utilization calculation', () {
        final pool = ConnectionPool(
          poolId: 'pool1',
          poolName: 'Main',
          maxSize: 100,
          currentSize: 100,
          availableConnections: 25,
          busyConnections: 75,
          createdAt: DateTime(2026, 1, 1),
        );

        expect(pool.utilizationPercentage, 75.0);
      });

      test('Backup size conversion accuracy', () {
        const sizeBytes = 1024 * 1024 * 250; // 250MB
        final backup = Backup(
          backupId: 'backup1',
          backupName: 'backup',
          backupType: BackupType.full,
          size: sizeBytes,
          createdAt: DateTime(2026, 9, 1),
          status: BackupStatus.completed,
          location: '/backups/backup',
        );

        expect(backup.sizeInMB, 250.0);
      });

      test('DatabasePerformanceStats health check', () {
        final healthy = DatabasePerformanceStats(
          statsId: 'stats1',
          totalQueries: 1000,
          slowQueries: 10,
          averageQueryTime: 50.0,
          maxQueryTime: 500.0,
          periodStart: DateTime(2026, 9, 1),
          periodEnd: DateTime(2026, 9, 2),
          cacheHitRate: 85,
          lockContention: 5,
          diskUsage: 50.0,
        );

        expect(healthy.isHealthy, true);
      });

      test('Recovery point age calculation', () {
        final point = RecoveryPoint(
          recoveryId: 'rec1',
          recoveryName: 'recovery',
          timestamp: DateTime.now().subtract(Duration(days: 15)),
          backupId: 'backup1',
          dataSize: 1000000,
        );

        expect(point.ageInDays, 15);
      });
    });

    // ===== Database Type Support Tests =====
    group('Database Type Support', () {
      test('SQLite connection', () async {
        await databaseFacade.createConnection(
          'sqlite_conn',
          DatabaseType.sqlite,
          'local',
          0,
          'app.db',
          '',
          '',
        );

        final conn = await databaseFacade.getConnection('sqlite_conn');
        expect(conn!.databaseType, DatabaseType.sqlite);
      });

      test('PostgreSQL connection', () async {
        await databaseFacade.createConnection(
          'pg_conn',
          DatabaseType.postgresql,
          'db.example.com',
          5432,
          'production',
          'pguser',
          'pgpass',
        );

        final conn = await databaseFacade.getConnection('pg_conn');
        expect(conn!.databaseType, DatabaseType.postgresql);
      });

      test('Multiple database type connections', () async {
        await databaseFacade.createConnection(
          'conn1',
          DatabaseType.postgresql,
          'localhost',
          5432,
          'db1',
          'user',
          'pass',
        );
        await databaseFacade.createConnection(
          'conn2',
          DatabaseType.mysql,
          'localhost',
          3306,
          'db2',
          'user',
          'pass',
        );
        await databaseFacade.createConnection(
          'conn3',
          DatabaseType.mongodb,
          'localhost',
          27017,
          'db3',
          'user',
          'pass',
        );

        final conns = await databaseFacade.getAllConnections();
        expect(conns.length, greaterThanOrEqualTo(3));
      });
    });

    // ===== Backup Type Tests =====
    group('Backup Types', () {
      test('Full backup', () async {
        final backup = await databaseFacade.createBackup(
          'full_backup',
          BackupType.full,
          1000000,
        );

        expect(backup.backupType, BackupType.full);
      });

      test('Incremental backup', () async {
        final backup = await databaseFacade.createBackup(
          'incremental_backup',
          BackupType.incremental,
          100000,
        );

        expect(backup.backupType, BackupType.incremental);
      });

      test('Snapshot backup', () async {
        final backup = await databaseFacade.createBackup(
          'snapshot_backup',
          BackupType.snapshot,
          500000,
        );

        expect(backup.backupType, BackupType.snapshot);
      });
    });
  });
}
