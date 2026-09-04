/// Phase 43: Database Schema Management テスト
/// スキーマ管理、マイグレーション、インデックス、メトリクス

import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/database_models.dart';
import 'package:project_040/services/database_service.dart';

void main() {
  group('Phase 43: Database Schema Management Tests', () {
    // ==================== Enum Tests ====================
    group('Enum Tests', () {
      test('ColumnType enum values', () {
        expect(ColumnType.string.value, 'string');
        expect(ColumnType.integer.value, 'integer');
        expect(ColumnType.decimal.value, 'decimal');
        expect(ColumnType.boolean.value, 'boolean');
        expect(ColumnType.datetime.value, 'datetime');
        expect(ColumnType.json.value, 'json');
        expect(ColumnType.bytes.value, 'bytes');
        expect(ColumnType.uuid.value, 'uuid');
      });

      test('ConstraintType enum values', () {
        expect(ConstraintType.primaryKey.value, 'primary_key');
        expect(ConstraintType.unique.value, 'unique');
        expect(ConstraintType.notNull.value, 'not_null');
        expect(ConstraintType.foreignKey.value, 'foreign_key');
        expect(ConstraintType.check.value, 'check');
        expect(ConstraintType.defaultValue.value, 'default');
      });

      test('IndexType enum values', () {
        expect(IndexType.btree.value, 'btree');
        expect(IndexType.hash.value, 'hash');
        expect(IndexType.fulltext.value, 'fulltext');
        expect(IndexType.spatial.value, 'spatial');
      });

      test('MigrationStatus enum values', () {
        expect(MigrationStatus.pending.value, 'pending');
        expect(MigrationStatus.running.value, 'running');
        expect(MigrationStatus.completed.value, 'completed');
        expect(MigrationStatus.rollback.value, 'rollback');
        expect(MigrationStatus.failed.value, 'failed');
      });

      test('DatabaseOperation enum values', () {
        expect(DatabaseOperation.create.value, 'create');
        expect(DatabaseOperation.read.value, 'read');
        expect(DatabaseOperation.update.value, 'update');
        expect(DatabaseOperation.delete.value, 'delete');
        expect(DatabaseOperation.migrate.value, 'migrate');
      });
    });

    // ==================== Column Tests ====================
    group('Column Model Tests', () {
      test('Create column with basic properties', () {
        final column = Column(
          columnId: 'col_1',
          name: 'user_id',
          type: ColumnType.uuid,
          nullable: false,
          defaultValue: null,
          constraints: [ConstraintType.primaryKey],
          createdAt: DateTime.now(),
        );

        expect(column.columnId, 'col_1');
        expect(column.name, 'user_id');
        expect(column.type, ColumnType.uuid);
        expect(column.nullable, false);
        expect(column.isPrimaryKey, true);
      });

      test('Column with NotNull constraint', () {
        final column = Column(
          columnId: 'col_2',
          name: 'email',
          type: ColumnType.string,
          constraints: [ConstraintType.notNull],
          createdAt: DateTime.now(),
        );

        expect(column.hasNotNull, true);
      });

      test('Column with Unique constraint', () {
        final column = Column(
          columnId: 'col_3',
          name: 'email',
          type: ColumnType.string,
          constraints: [ConstraintType.unique],
          createdAt: DateTime.now(),
        );

        expect(column.hasUnique, true);
      });

      test('Column with multiple constraints', () {
        final column = Column(
          columnId: 'col_4',
          name: 'email',
          type: ColumnType.string,
          constraints: [ConstraintType.unique, ConstraintType.notNull],
          createdAt: DateTime.now(),
        );

        expect(column.hasUnique, true);
        expect(column.hasNotNull, true);
      });

      test('Column with max length', () {
        final column = Column(
          columnId: 'col_5',
          name: 'username',
          type: ColumnType.string,
          maxLength: 50,
          createdAt: DateTime.now(),
        );

        expect(column.maxLength, 50);
      });

      test('Column with default value', () {
        final column = Column(
          columnId: 'col_6',
          name: 'status',
          type: ColumnType.string,
          defaultValue: 'active',
          createdAt: DateTime.now(),
        );

        expect(column.defaultValue, 'active');
      });
    });

    // ==================== Table Tests ====================
    group('Table Model Tests', () {
      test('Create table with columns', () {
        final columns = [
          Column(
            columnId: 'col_1',
            name: 'id',
            type: ColumnType.uuid,
            nullable: false,
            constraints: [ConstraintType.primaryKey],
            createdAt: DateTime.now(),
          ),
          Column(
            columnId: 'col_2',
            name: 'email',
            type: ColumnType.string,
            nullable: false,
            constraints: [ConstraintType.unique],
            createdAt: DateTime.now(),
          ),
        ];

        final table = Table(
          tableId: 'tbl_1',
          name: 'users',
          columns: columns,
          primaryKey: 'id',
          createdAt: DateTime.now(),
        );

        expect(table.tableId, 'tbl_1');
        expect(table.name, 'users');
        expect(table.columnCount, 2);
        expect(table.primaryKey, 'id');
      });

      test('Get column by name', () {
        final columns = [
          Column(
            columnId: 'col_1',
            name: 'id',
            type: ColumnType.uuid,
            createdAt: DateTime.now(),
          ),
          Column(
            columnId: 'col_2',
            name: 'email',
            type: ColumnType.string,
            createdAt: DateTime.now(),
          ),
        ];

        final table = Table(
          tableId: 'tbl_1',
          name: 'users',
          columns: columns,
          createdAt: DateTime.now(),
        );

        final emailColumn = table.getColumnByName('email');
        expect(emailColumn, isNotNull);
        expect(emailColumn!.name, 'email');
      });

      test('Get column by name returns null when not found', () {
        final columns = [
          Column(
            columnId: 'col_1',
            name: 'id',
            type: ColumnType.uuid,
            createdAt: DateTime.now(),
          ),
        ];

        final table = Table(
          tableId: 'tbl_1',
          name: 'users',
          columns: columns,
          createdAt: DateTime.now(),
        );

        final notFoundColumn = table.getColumnByName('nonexistent');
        expect(notFoundColumn, isNull);
      });

      test('Get indexable columns', () {
        final columns = [
          Column(
            columnId: 'col_1',
            name: 'id',
            type: ColumnType.uuid,
            createdAt: DateTime.now(),
          ),
          Column(
            columnId: 'col_2',
            name: 'metadata',
            type: ColumnType.json,
            createdAt: DateTime.now(),
          ),
        ];

        final table = Table(
          tableId: 'tbl_1',
          name: 'users',
          columns: columns,
          createdAt: DateTime.now(),
        );

        final indexable = table.getIndexableColumns();
        expect(indexable.length, 1);
        expect(indexable.first.name, 'id');
      });
    });

    // ==================== Index Tests ====================
    group('Index Model Tests', () {
      test('Create simple index', () {
        final index = Index(
          indexId: 'idx_1',
          name: 'idx_users_email',
          tableId: 'tbl_1',
          columns: ['email'],
          type: IndexType.btree,
          createdAt: DateTime.now(),
        );

        expect(index.indexId, 'idx_1');
        expect(index.name, 'idx_users_email');
        expect(index.isComposite, false);
        expect(index.unique, false);
      });

      test('Create composite index', () {
        final index = Index(
          indexId: 'idx_2',
          name: 'idx_users_name_email',
          tableId: 'tbl_1',
          columns: ['first_name', 'last_name'],
          type: IndexType.btree,
          createdAt: DateTime.now(),
        );

        expect(index.isComposite, true);
        expect(index.columns.length, 2);
      });

      test('Create unique index', () {
        final index = Index(
          indexId: 'idx_3',
          name: 'idx_users_email_unique',
          tableId: 'tbl_1',
          columns: ['email'],
          type: IndexType.btree,
          unique: true,
          createdAt: DateTime.now(),
        );

        expect(index.unique, true);
      });

      test('Calculate estimated index size', () {
        final index = Index(
          indexId: 'idx_4',
          name: 'idx_test',
          tableId: 'tbl_1',
          columns: ['col1', 'col2', 'col3'],
          type: IndexType.btree,
          createdAt: DateTime.now(),
        );

        expect(index.estimatedSizeBytes, 3000);
      });
    });

    // ==================== ForeignKey Tests ====================
    group('ForeignKey Model Tests', () {
      test('Create foreign key', () {
        final fk = ForeignKey(
          foreignKeyId: 'fk_1',
          name: 'fk_users_roles',
          tableId: 'tbl_1',
          columnId: 'col_1',
          referencedTableId: 'tbl_2',
          referencedColumnId: 'col_2',
          onDelete: 'CASCADE',
          onUpdate: 'CASCADE',
          createdAt: DateTime.now(),
        );

        expect(fk.foreignKeyId, 'fk_1');
        expect(fk.name, 'fk_users_roles');
        expect(fk.onDelete, 'CASCADE');
        expect(fk.onUpdate, 'CASCADE');
      });

      test('Foreign key default cascade behavior', () {
        final fk = ForeignKey(
          foreignKeyId: 'fk_2',
          name: 'fk_test',
          tableId: 'tbl_1',
          columnId: 'col_1',
          referencedTableId: 'tbl_2',
          referencedColumnId: 'col_2',
          createdAt: DateTime.now(),
        );

        expect(fk.onDelete, 'CASCADE');
        expect(fk.onUpdate, 'CASCADE');
      });
    });

    // ==================== Migration Tests ====================
    group('Migration Model Tests', () {
      test('Create migration', () {
        final migration = Migration(
          migrationId: 'mig_1',
          version: '1.0.0',
          description: 'Create users table',
          upScript: 'CREATE TABLE users...',
          downScript: 'DROP TABLE users...',
          status: MigrationStatus.pending,
          createdAt: DateTime.now(),
        );

        expect(migration.migrationId, 'mig_1');
        expect(migration.version, '1.0.0');
        expect(migration.status, MigrationStatus.pending);
        expect(migration.isApplicable, true);
      });

      test('Apply migration', () {
        final migration = Migration(
          migrationId: 'mig_2',
          version: '1.0.1',
          description: 'Add email column',
          upScript: 'ALTER TABLE users ADD email...',
          downScript: 'ALTER TABLE users DROP email...',
          status: MigrationStatus.pending,
          createdAt: DateTime.now(),
        );

        migration.apply();
        expect(migration.status, MigrationStatus.completed);
        expect(migration.appliedAt, isNotNull);
      });

      test('Rollback migration', () {
        final migration = Migration(
          migrationId: 'mig_3',
          version: '1.0.2',
          description: 'Add phone column',
          upScript: 'ALTER TABLE users ADD phone...',
          downScript: 'ALTER TABLE users DROP phone...',
          status: MigrationStatus.completed,
          createdAt: DateTime.now(),
          appliedAt: DateTime.now(),
        );

        migration.rollback();
        expect(migration.status, MigrationStatus.rollback);
        expect(migration.rolledbackAt, isNotNull);
      });

      test('Migration is not rollbackable when pending', () {
        final migration = Migration(
          migrationId: 'mig_4',
          version: '1.0.3',
          description: 'Test',
          upScript: 'SELECT 1',
          downScript: 'SELECT 1',
          status: MigrationStatus.pending,
          createdAt: DateTime.now(),
        );

        expect(migration.isRollbackable, false);
      });
    });

    // ==================== SchemaVersion Tests ====================
    group('SchemaVersion Model Tests', () {
      test('Create schema version', () {
        final tables = [
          Table(
            tableId: 'tbl_1',
            name: 'users',
            columns: [],
            createdAt: DateTime.now(),
          ),
        ];

        final version = SchemaVersion(
          versionId: 'ver_1',
          version: '1.0.0',
          tables: tables,
          appliedAt: DateTime.now(),
        );

        expect(version.versionId, 'ver_1');
        expect(version.version, '1.0.0');
        expect(version.tableCount, 1);
      });

      test('Schema version with indexes', () {
        final tables = [
          Table(
            tableId: 'tbl_1',
            name: 'users',
            columns: [],
            createdAt: DateTime.now(),
          ),
        ];

        final indexes = [
          Index(
            indexId: 'idx_1',
            name: 'idx_users_email',
            tableId: 'tbl_1',
            columns: ['email'],
            type: IndexType.btree,
            createdAt: DateTime.now(),
          ),
        ];

        final version = SchemaVersion(
          versionId: 'ver_2',
          version: '1.1.0',
          tables: tables,
          indexes: indexes,
          appliedAt: DateTime.now(),
        );

        expect(version.indexCount, 1);
      });

      test('Calculate complexity score', () {
        final columns = [
          Column(
            columnId: 'col_1',
            name: 'id',
            type: ColumnType.uuid,
            createdAt: DateTime.now(),
          ),
        ];

        final tables = [
          Table(
            tableId: 'tbl_1',
            name: 'users',
            columns: columns,
            createdAt: DateTime.now(),
          ),
        ];

        final version = SchemaVersion(
          versionId: 'ver_3',
          version: '1.0.0',
          tables: tables,
          appliedAt: DateTime.now(),
        );

        expect(version.complexityScore, isNonNegative);
        expect(version.complexityScore, lessThanOrEqualTo(100));
      });
    });

    // ==================== DatabaseMetrics Tests ====================
    group('DatabaseMetrics Model Tests', () {
      test('Create database metrics', () {
        final metrics = DatabaseMetrics(
          metricsId: 'metrics_1',
          totalTables: 10,
          totalColumns: 50,
          totalIndexes: 15,
          totalForeignKeys: 5,
          averageColumnCount: 5.0,
          averageIndexCount: 1.5,
          createdAt: DateTime.now(),
        );

        expect(metrics.metricsId, 'metrics_1');
        expect(metrics.totalTables, 10);
        expect(metrics.totalColumns, 50);
        expect(metrics.totalIndexes, 15);
      });

      test('Calculate health score', () {
        final metrics = DatabaseMetrics(
          metricsId: 'metrics_2',
          totalTables: 5,
          totalColumns: 20,
          totalIndexes: 10,
          totalForeignKeys: 3,
          averageColumnCount: 4.0,
          averageIndexCount: 2.0,
          createdAt: DateTime.now(),
        );

        expect(metrics.healthScore, isNonNegative);
        expect(metrics.healthScore, lessThanOrEqualTo(100));
      });
    });

    // ==================== DatabaseReport Tests ====================
    group('DatabaseReport Model Tests', () {
      test('Create database report', () {
        final tables = [
          Table(
            tableId: 'tbl_1',
            name: 'users',
            columns: [],
            createdAt: DateTime.now(),
          ),
        ];

        final schemaVersion = SchemaVersion(
          versionId: 'ver_1',
          version: '1.0.0',
          tables: tables,
          appliedAt: DateTime.now(),
        );

        final metrics = DatabaseMetrics(
          metricsId: 'metrics_1',
          totalTables: 1,
          totalColumns: 0,
          totalIndexes: 0,
          totalForeignKeys: 0,
          averageColumnCount: 0.0,
          averageIndexCount: 0.0,
          createdAt: DateTime.now(),
        );

        final report = DatabaseReport(
          reportId: 'report_1',
          generatedAt: DateTime.now(),
          schemaVersion: schemaVersion,
          metrics: metrics,
        );

        expect(report.reportId, 'report_1');
        expect(report.recommendations, isNotEmpty);
      });

      test('Report to markdown', () {
        final tables = [
          Table(
            tableId: 'tbl_1',
            name: 'users',
            columns: [],
            createdAt: DateTime.now(),
          ),
        ];

        final schemaVersion = SchemaVersion(
          versionId: 'ver_1',
          version: '1.0.0',
          tables: tables,
          appliedAt: DateTime.now(),
        );

        final metrics = DatabaseMetrics(
          metricsId: 'metrics_1',
          totalTables: 1,
          totalColumns: 0,
          totalIndexes: 0,
          totalForeignKeys: 0,
          averageColumnCount: 0.0,
          averageIndexCount: 0.0,
          createdAt: DateTime.now(),
        );

        final report = DatabaseReport(
          reportId: 'report_1',
          generatedAt: DateTime.now(),
          schemaVersion: schemaVersion,
          metrics: metrics,
        );

        final markdown = report.toMarkdown();
        expect(markdown, contains('Database Schema Report'));
        expect(markdown, contains('1.0.0'));
      });
    });

    // ==================== Repository Tests ====================
    group('DatabaseRepository Tests', () {
      late MemoryDatabaseRepository repository;

      setUp(() {
        repository = MemoryDatabaseRepository();
      });

      test('Save and retrieve table', () async {
        final table = Table(
          tableId: 'tbl_1',
          name: 'users',
          columns: [],
          createdAt: DateTime.now(),
        );

        await repository.saveTable(table);
        final retrieved = await repository.getTable('tbl_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, 'users');
      });

      test('Get all tables', () async {
        final table1 = Table(
          tableId: 'tbl_1',
          name: 'users',
          columns: [],
          createdAt: DateTime.now(),
        );

        final table2 = Table(
          tableId: 'tbl_2',
          name: 'posts',
          columns: [],
          createdAt: DateTime.now(),
        );

        await repository.saveTable(table1);
        await repository.saveTable(table2);

        final all = await repository.getAllTables();
        expect(all.length, 2);
      });

      test('Delete table', () async {
        final table = Table(
          tableId: 'tbl_1',
          name: 'users',
          columns: [],
          createdAt: DateTime.now(),
        );

        await repository.saveTable(table);
        await repository.deleteTable('tbl_1');

        final retrieved = await repository.getTable('tbl_1');
        expect(retrieved, isNull);
      });

      test('Save and retrieve index', () async {
        final index = Index(
          indexId: 'idx_1',
          name: 'idx_users_email',
          tableId: 'tbl_1',
          columns: ['email'],
          type: IndexType.btree,
          createdAt: DateTime.now(),
        );

        await repository.saveIndex(index);
        final indexes = await repository.getIndexesByTable('tbl_1');

        expect(indexes.length, 1);
        expect(indexes.first.name, 'idx_users_email');
      });

      test('Save and retrieve migration', () async {
        final migration = Migration(
          migrationId: 'mig_1',
          version: '1.0.0',
          description: 'Create users table',
          upScript: 'CREATE TABLE users...',
          downScript: 'DROP TABLE users...',
          status: MigrationStatus.pending,
          createdAt: DateTime.now(),
        );

        await repository.saveMigration(migration);
        final migrations = await repository.getMigrations();

        expect(migrations.length, 1);
        expect(migrations.first.version, '1.0.0');
      });

      test('Save and retrieve schema version', () async {
        final version = SchemaVersion(
          versionId: 'ver_1',
          version: '1.0.0',
          tables: [],
          appliedAt: DateTime.now(),
        );

        await repository.saveSchemaVersion(version);
        final latest = await repository.getLatestSchemaVersion();

        expect(latest, isNotNull);
        expect(latest!.version, '1.0.0');
      });
    });

    // ==================== SchemaEngine Tests ====================
    group('SchemaEngine Tests', () {
      late MemoryDatabaseRepository repository;
      late MemorySchemaEngine engine;

      setUp(() {
        repository = MemoryDatabaseRepository();
        engine = MemorySchemaEngine(repository);
      });

      test('Create table', () async {
        final table = Table(
          tableId: 'tbl_1',
          name: 'users',
          columns: [],
          createdAt: DateTime.now(),
        );

        await engine.createTable(table);
        final retrieved = await engine.getTable('tbl_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, 'users');
      });

      test('Drop table', () async {
        final table = Table(
          tableId: 'tbl_1',
          name: 'users',
          columns: [],
          createdAt: DateTime.now(),
        );

        await engine.createTable(table);
        await engine.dropTable('tbl_1');

        final retrieved = await engine.getTable('tbl_1');
        expect(retrieved, isNull);
      });

      test('Add column to table', () async {
        final table = Table(
          tableId: 'tbl_1',
          name: 'users',
          columns: [],
          createdAt: DateTime.now(),
        );

        await engine.createTable(table);

        final column = Column(
          columnId: 'col_1',
          name: 'email',
          type: ColumnType.string,
          createdAt: DateTime.now(),
        );

        await engine.addColumn('tbl_1', column);
        final updated = await engine.getTable('tbl_1');

        expect(updated!.columnCount, 1);
      });

      test('Get schema', () async {
        final table1 = Table(
          tableId: 'tbl_1',
          name: 'users',
          columns: [],
          createdAt: DateTime.now(),
        );

        final table2 = Table(
          tableId: 'tbl_2',
          name: 'posts',
          columns: [],
          createdAt: DateTime.now(),
        );

        await engine.createTable(table1);
        await engine.createTable(table2);

        final schema = await engine.getSchema();
        expect(schema.length, 2);
      });

      test('Calculate metrics', () async {
        final table = Table(
          tableId: 'tbl_1',
          name: 'users',
          columns: [
            Column(
              columnId: 'col_1',
              name: 'id',
              type: ColumnType.uuid,
              createdAt: DateTime.now(),
            ),
          ],
          createdAt: DateTime.now(),
        );

        await engine.createTable(table);

        final metrics = await engine.calculateMetrics();
        expect(metrics.totalTables, 1);
        expect(metrics.totalColumns, 1);
      });
    });

    // ==================== MigrationEngine Tests ====================
    group('MigrationEngine Tests', () {
      late MemoryDatabaseRepository repository;
      late MemoryMigrationEngine engine;

      setUp(() {
        repository = MemoryDatabaseRepository();
        engine = MemoryMigrationEngine(repository);
      });

      test('Get pending migrations', () async {
        final migration = Migration(
          migrationId: 'mig_1',
          version: '1.0.0',
          description: 'Create users table',
          upScript: 'CREATE TABLE users...',
          downScript: 'DROP TABLE users...',
          status: MigrationStatus.pending,
          createdAt: DateTime.now(),
        );

        await repository.saveMigration(migration);
        final pending = await engine.getPendingMigrations();

        expect(pending.length, 1);
      });

      test('Get applied migrations', () async {
        final migration = Migration(
          migrationId: 'mig_1',
          version: '1.0.0',
          description: 'Create users table',
          upScript: 'CREATE TABLE users...',
          downScript: 'DROP TABLE users...',
          status: MigrationStatus.completed,
          createdAt: DateTime.now(),
          appliedAt: DateTime.now(),
        );

        await repository.saveMigration(migration);
        final applied = await engine.getAppliedMigrations();

        expect(applied.length, 1);
      });
    });

    // ==================== DatabaseManager Tests ====================
    group('DatabaseManager Tests', () {
      late MemoryDatabaseRepository repository;
      late MemorySchemaEngine schemaEngine;
      late MemoryMigrationEngine migrationEngine;
      late MemoryDatabaseManager manager;

      setUp(() {
        repository = MemoryDatabaseRepository();
        schemaEngine = MemorySchemaEngine(repository);
        migrationEngine = MemoryMigrationEngine(repository);
        manager = MemoryDatabaseManager(repository, schemaEngine, migrationEngine);
      });

      test('Create schema', () async {
        final tables = [
          Table(
            tableId: 'tbl_1',
            name: 'users',
            columns: [],
            createdAt: DateTime.now(),
          ),
        ];

        final schema = SchemaVersion(
          versionId: 'ver_1',
          version: '1.0.0',
          tables: tables,
          appliedAt: DateTime.now(),
        );

        await manager.createSchema(schema);
        final latest = await repository.getLatestSchemaVersion();

        expect(latest, isNotNull);
        expect(latest!.version, '1.0.0');
      });

      test('Get migration history', () async {
        final migration = Migration(
          migrationId: 'mig_1',
          version: '1.0.0',
          description: 'Test',
          upScript: 'SELECT 1',
          downScript: 'SELECT 1',
          status: MigrationStatus.completed,
          createdAt: DateTime.now(),
        );

        await repository.saveMigration(migration);
        final history = await manager.getMigrationHistory();

        expect(history.length, 1);
      });

      test('Generate report', () async {
        final tables = [
          Table(
            tableId: 'tbl_1',
            name: 'users',
            columns: [],
            createdAt: DateTime.now(),
          ),
        ];

        final schema = SchemaVersion(
          versionId: 'ver_1',
          version: '1.0.0',
          tables: tables,
          appliedAt: DateTime.now(),
        );

        await manager.createSchema(schema);
        final report = await manager.generateReport();

        expect(report.reportId, isNotEmpty);
        expect(report.schemaVersion.version, '1.0.0');
      });
    });

    // ==================== Facade Tests ====================
    group('DatabaseManagerFacade Tests', () {
      late DatabaseManagerFacade facade;

      setUp(() {
        facade = DatabaseManagerFacade();
      });

      test('Create table via facade', () async {
        final table = Table(
          tableId: 'tbl_1',
          name: 'users',
          columns: [],
          createdAt: DateTime.now(),
        );

        await facade.createTable(table);
        final retrieved = await facade.getTable('tbl_1');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, 'users');
      });

      test('Create index via facade', () async {
        final index = Index(
          indexId: 'idx_1',
          name: 'idx_users_email',
          tableId: 'tbl_1',
          columns: ['email'],
          type: IndexType.btree,
          createdAt: DateTime.now(),
        );

        await facade.createIndex(index);
        final indexes = await facade.getIndexesByTable('tbl_1');

        expect(indexes.length, 1);
      });

      test('Apply migration via facade', () async {
        final migration = Migration(
          migrationId: 'mig_1',
          version: '1.0.0',
          description: 'Create users table',
          upScript: 'CREATE TABLE users...',
          downScript: 'DROP TABLE users...',
          status: MigrationStatus.pending,
          createdAt: DateTime.now(),
        );

        await facade.applyMigration(migration);
        final history = await facade.getMigrationHistory();

        expect(history.length, 1);
        expect(history.first.status, MigrationStatus.completed);
      });

      test('Get metrics via facade', () async {
        final table = Table(
          tableId: 'tbl_1',
          name: 'users',
          columns: [
            Column(
              columnId: 'col_1',
              name: 'id',
              type: ColumnType.uuid,
              createdAt: DateTime.now(),
            ),
          ],
          createdAt: DateTime.now(),
        );

        await facade.createTable(table);
        final metrics = await facade.getMetrics();

        expect(metrics, isNotNull);
        expect(metrics!.totalTables, 1);
      });

      test('Generate report via facade', () async {
        final tables = [
          Table(
            tableId: 'tbl_1',
            name: 'users',
            columns: [],
            createdAt: DateTime.now(),
          ),
        ];

        final schema = SchemaVersion(
          versionId: 'ver_1',
          version: '1.0.0',
          tables: tables,
          appliedAt: DateTime.now(),
        );

        await facade.createSchema(schema);
        final report = await facade.generateReport();

        expect(report.schemaVersion.version, '1.0.0');
        expect(report.toMarkdown(), contains('Database Schema Report'));
      });
    });

    // ==================== Integration Tests ====================
    group('Integration Tests', () {
      test('Complete schema management workflow', () async {
        final facade = DatabaseManagerFacade();

        // Create tables
        final userColumns = [
          Column(
            columnId: 'col_id',
            name: 'id',
            type: ColumnType.uuid,
            nullable: false,
            constraints: [ConstraintType.primaryKey],
            createdAt: DateTime.now(),
          ),
          Column(
            columnId: 'col_email',
            name: 'email',
            type: ColumnType.string,
            nullable: false,
            constraints: [ConstraintType.unique],
            createdAt: DateTime.now(),
          ),
        ];

        final userTable = Table(
          tableId: 'tbl_users',
          name: 'users',
          columns: userColumns,
          primaryKey: 'id',
          createdAt: DateTime.now(),
        );

        await facade.createTable(userTable);

        // Create index
        final emailIndex = Index(
          indexId: 'idx_email',
          name: 'idx_users_email',
          tableId: 'tbl_users',
          columns: ['email'],
          type: IndexType.btree,
          unique: true,
          createdAt: DateTime.now(),
        );

        await facade.createIndex(emailIndex);

        // Create schema version
        final schema = SchemaVersion(
          versionId: 'ver_1',
          version: '1.0.0',
          tables: [userTable],
          appliedAt: DateTime.now(),
        );

        await facade.createSchema(schema);

        // Get metrics
        final metrics = await facade.getMetrics();
        expect(metrics, isNotNull);
        expect(metrics!.totalTables, 1);

        // Generate report
        final report = await facade.generateReport();
        expect(report.schemaVersion.version, '1.0.0');
      });

      test('Schema evolution with migrations', () async {
        final facade = DatabaseManagerFacade();

        // Initial schema
        final schema = SchemaVersion(
          versionId: 'ver_1',
          version: '1.0.0',
          tables: [
            Table(
              tableId: 'tbl_users',
              name: 'users',
              columns: [],
              createdAt: DateTime.now(),
            ),
          ],
          appliedAt: DateTime.now(),
        );

        await facade.createSchema(schema);

        // Apply migration
        final migration = Migration(
          migrationId: 'mig_1',
          version: '2.0.0',
          description: 'Add email column',
          upScript: 'ALTER TABLE users ADD email VARCHAR(255)',
          downScript: 'ALTER TABLE users DROP email',
          status: MigrationStatus.pending,
          createdAt: DateTime.now(),
        );

        await facade.applyMigration(migration);

        // Check migration status
        final history = await facade.getMigrationHistory();
        expect(history.length, 1);
        expect(history.first.status, MigrationStatus.completed);
      });
    });
  });
}
