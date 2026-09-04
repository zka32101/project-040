/// Phase 43: Database Schema Management データベーススキーマサービス実装
///
/// スキーマ操作、マイグレーション、リポジトリ、エンジン

import 'package:project_040/models/database_models.dart';

/// データベースリポジトリインターフェース
abstract class DatabaseRepository {
  /// テーブルを保存
  Future<void> saveTable(Table table);

  /// テーブルを取得
  Future<Table?> getTable(String tableId);

  /// すべてのテーブルを取得
  Future<List<Table>> getAllTables();

  /// テーブルを削除
  Future<void> deleteTable(String tableId);

  /// インデックスを保存
  Future<void> saveIndex(Index index);

  /// テーブルのインデックスを取得
  Future<List<Index>> getIndexesByTable(String tableId);

  /// インデックスを削除
  Future<void> deleteIndex(String indexId);

  /// 外部キーを保存
  Future<void> saveForeignKey(ForeignKey foreignKey);

  /// テーブルの外部キーを取得
  Future<List<ForeignKey>> getForeignKeysByTable(String tableId);

  /// マイグレーションを保存
  Future<void> saveMigration(Migration migration);

  /// すべてのマイグレーションを取得
  Future<List<Migration>> getMigrations();

  /// マイグレーションを取得
  Future<Migration?> getMigration(String migrationId);

  /// スキーマバージョンを保存
  Future<void> saveSchemaVersion(SchemaVersion version);

  /// スキーマバージョンを取得
  Future<SchemaVersion?> getSchemaVersion(String versionId);

  /// 最新のスキーマバージョンを取得
  Future<SchemaVersion?> getLatestSchemaVersion();
}

/// メモリ実装のデータベースリポジトリ
class MemoryDatabaseRepository implements DatabaseRepository {
  final Map<String, Table> _tables = {};
  final Map<String, Index> _indexes = {};
  final Map<String, List<Index>> _indexesByTable = {};
  final Map<String, ForeignKey> _foreignKeys = {};
  final Map<String, List<ForeignKey>> _foreignKeysByTable = {};
  final Map<String, Migration> _migrations = {};
  final Map<String, SchemaVersion> _schemaVersions = {};
  String? _latestSchemaVersionId;

  @override
  Future<void> saveTable(Table table) async {
    _tables[table.tableId] = table;
  }

  @override
  Future<Table?> getTable(String tableId) async => _tables[tableId];

  @override
  Future<List<Table>> getAllTables() async => _tables.values.toList();

  @override
  Future<void> deleteTable(String tableId) async {
    _tables.remove(tableId);
    _indexesByTable.remove(tableId);
    _foreignKeysByTable.remove(tableId);
  }

  @override
  Future<void> saveIndex(Index index) async {
    _indexes[index.indexId] = index;
    _indexesByTable.putIfAbsent(index.tableId, () => []).add(index);
  }

  @override
  Future<List<Index>> getIndexesByTable(String tableId) async =>
      _indexesByTable[tableId] ?? [];

  @override
  Future<void> deleteIndex(String indexId) async {
    final index = _indexes.remove(indexId);
    if (index != null) {
      _indexesByTable[index.tableId]?.removeWhere((i) => i.indexId == indexId);
    }
  }

  @override
  Future<void> saveForeignKey(ForeignKey foreignKey) async {
    _foreignKeys[foreignKey.foreignKeyId] = foreignKey;
    _foreignKeysByTable.putIfAbsent(foreignKey.tableId, () => []).add(foreignKey);
  }

  @override
  Future<List<ForeignKey>> getForeignKeysByTable(String tableId) async =>
      _foreignKeysByTable[tableId] ?? [];

  @override
  Future<void> saveMigration(Migration migration) async {
    _migrations[migration.migrationId] = migration;
  }

  @override
  Future<List<Migration>> getMigrations() async => _migrations.values.toList();

  @override
  Future<Migration?> getMigration(String migrationId) async =>
      _migrations[migrationId];

  @override
  Future<void> saveSchemaVersion(SchemaVersion version) async {
    _schemaVersions[version.versionId] = version;
    _latestSchemaVersionId = version.versionId;
  }

  @override
  Future<SchemaVersion?> getSchemaVersion(String versionId) async =>
      _schemaVersions[versionId];

  @override
  Future<SchemaVersion?> getLatestSchemaVersion() async {
    if (_latestSchemaVersionId == null) return null;
    return _schemaVersions[_latestSchemaVersionId];
  }
}

/// スキーマエンジンインターフェース
abstract class SchemaEngine {
  /// テーブルを作成
  Future<void> createTable(Table table);

  /// テーブルを削除
  Future<void> dropTable(String tableId);

  /// カラムを追加
  Future<void> addColumn(String tableId, Column column);

  /// カラムを削除
  Future<void> dropColumn(String tableId, String columnName);

  /// インデックスを作成
  Future<void> createIndex(Index index);

  /// インデックスを削除
  Future<void> dropIndex(String indexId);

  /// スキーマを取得
  Future<List<Table>> getSchema();

  /// メトリクスを計算
  Future<DatabaseMetrics> calculateMetrics();

  /// テーブルを取得
  Future<Table?> getTable(String tableId);
}

/// メモリ実装のスキーマエンジン
class MemorySchemaEngine implements SchemaEngine {
  final DatabaseRepository _repository;
  int _totalOperations = 0;

  MemorySchemaEngine(this._repository);

  @override
  Future<void> createTable(Table table) async {
    await _repository.saveTable(table);
    _totalOperations++;
  }

  @override
  Future<void> dropTable(String tableId) async {
    await _repository.deleteTable(tableId);
    _totalOperations++;
  }

  @override
  Future<void> addColumn(String tableId, Column column) async {
    final table = await _repository.getTable(tableId);
    if (table != null) {
      final updatedTable = Table(
        tableId: table.tableId,
        name: table.name,
        columns: [...table.columns, column],
        primaryKey: table.primaryKey,
        createdAt: table.createdAt,
        updatedAt: DateTime.now(),
      );
      await _repository.saveTable(updatedTable);
      _totalOperations++;
    }
  }

  @override
  Future<void> dropColumn(String tableId, String columnName) async {
    final table = await _repository.getTable(tableId);
    if (table != null) {
      final updatedTable = Table(
        tableId: table.tableId,
        name: table.name,
        columns: table.columns.where((c) => c.name != columnName).toList(),
        primaryKey: table.primaryKey,
        createdAt: table.createdAt,
        updatedAt: DateTime.now(),
      );
      await _repository.saveTable(updatedTable);
      _totalOperations++;
    }
  }

  @override
  Future<void> createIndex(Index index) async {
    await _repository.saveIndex(index);
    _totalOperations++;
  }

  @override
  Future<void> dropIndex(String indexId) async {
    await _repository.deleteIndex(indexId);
    _totalOperations++;
  }

  @override
  Future<List<Table>> getSchema() async => _repository.getAllTables();

  @override
  Future<DatabaseMetrics> calculateMetrics() async {
    final tables = await _repository.getAllTables();
    final totalTables = tables.length;
    final totalColumns = tables.fold(0, (sum, t) => sum + t.columnCount);

    int totalIndexes = 0;
    int totalForeignKeys = 0;
    for (final table in tables) {
      final indexes = await _repository.getIndexesByTable(table.tableId);
      final foreignKeys = await _repository.getForeignKeysByTable(table.tableId);
      totalIndexes += indexes.length;
      totalForeignKeys += foreignKeys.length;
    }

    final avgColumnCount =
        totalTables > 0 ? totalColumns / totalTables : 0.0;
    final avgIndexCount =
        totalTables > 0 ? totalIndexes / totalTables : 0.0;

    return DatabaseMetrics(
      metricsId: 'metrics:${DateTime.now().millisecondsSinceEpoch}',
      totalTables: totalTables,
      totalColumns: totalColumns,
      totalIndexes: totalIndexes,
      totalForeignKeys: totalForeignKeys,
      averageColumnCount: avgColumnCount,
      averageIndexCount: avgIndexCount,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Table?> getTable(String tableId) async =>
      _repository.getTable(tableId);
}

/// マイグレーションエンジンインターフェース
abstract class MigrationEngine {
  /// マイグレーションを実行
  Future<void> applyMigration(Migration migration);

  /// マイグレーションをロールバック
  Future<void> rollbackMigration(Migration migration);

  /// ペンディングのマイグレーションを取得
  Future<List<Migration>> getPendingMigrations();

  /// 実行済みマイグレーションを取得
  Future<List<Migration>> getAppliedMigrations();

  /// 現在のバージョンを取得
  Future<SchemaVersion?> getCurrentVersion();
}

/// メモリ実装のマイグレーションエンジン
class MemoryMigrationEngine implements MigrationEngine {
  final DatabaseRepository _repository;

  MemoryMigrationEngine(this._repository);

  @override
  Future<void> applyMigration(Migration migration) async {
    final updatedMigration = Migration(
      migrationId: migration.migrationId,
      version: migration.version,
      description: migration.description,
      upScript: migration.upScript,
      downScript: migration.downScript,
      status: MigrationStatus.running,
      createdAt: migration.createdAt,
    );

    try {
      updatedMigration.apply();
      await _repository.saveMigration(updatedMigration);
    } catch (e) {
      updatedMigration.status = MigrationStatus.failed;
      updatedMigration.errorMessage = e.toString();
      await _repository.saveMigration(updatedMigration);
      rethrow;
    }
  }

  @override
  Future<void> rollbackMigration(Migration migration) async {
    if (!migration.isRollbackable) {
      throw Exception('Migration is not rollbackable');
    }

    final updatedMigration = Migration(
      migrationId: migration.migrationId,
      version: migration.version,
      description: migration.description,
      upScript: migration.upScript,
      downScript: migration.downScript,
      status: migration.status,
      createdAt: migration.createdAt,
      appliedAt: migration.appliedAt,
    );

    updatedMigration.rollback();
    await _repository.saveMigration(updatedMigration);
  }

  @override
  Future<List<Migration>> getPendingMigrations() async {
    final migrations = await _repository.getMigrations();
    return migrations
        .where((m) => m.status == MigrationStatus.pending)
        .toList();
  }

  @override
  Future<List<Migration>> getAppliedMigrations() async {
    final migrations = await _repository.getMigrations();
    return migrations
        .where((m) => m.status == MigrationStatus.completed)
        .toList();
  }

  @override
  Future<SchemaVersion?> getCurrentVersion() async {
    return _repository.getLatestSchemaVersion();
  }
}

/// データベースマネージャーインターフェース
abstract class DatabaseManager {
  /// スキーマを作成
  Future<void> createSchema(SchemaVersion version);

  /// スキーマをマイグレーション
  Future<void> migrateSchema(String targetVersion);

  /// マイグレーション履歴を取得
  Future<List<Migration>> getMigrationHistory();

  /// メトリクスを取得
  Future<DatabaseMetrics?> getMetrics();

  /// レポートを生成
  Future<DatabaseReport> generateReport();
}

/// メモリ実装のデータベースマネージャー
class MemoryDatabaseManager implements DatabaseManager {
  final DatabaseRepository _repository;
  final SchemaEngine _schemaEngine;
  final MigrationEngine _migrationEngine;

  MemoryDatabaseManager(
    this._repository,
    this._schemaEngine,
    this._migrationEngine,
  );

  @override
  Future<void> createSchema(SchemaVersion version) async {
    for (final table in version.tables) {
      await _schemaEngine.createTable(table);
    }

    if (version.indexes != null) {
      for (final index in version.indexes!) {
        await _schemaEngine.createIndex(index);
      }
    }

    await _repository.saveSchemaVersion(version);
  }

  @override
  Future<void> migrateSchema(String targetVersion) async {
    final pendingMigrations = await _migrationEngine.getPendingMigrations();

    for (final migration in pendingMigrations) {
      if (migration.version == targetVersion) {
        await _migrationEngine.applyMigration(migration);
      }
    }
  }

  @override
  Future<List<Migration>> getMigrationHistory() async {
    return _repository.getMigrations();
  }

  @override
  Future<DatabaseMetrics?> getMetrics() async {
    try {
      return await _schemaEngine.calculateMetrics();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<DatabaseReport> generateReport() async {
    final currentVersion = await _migrationEngine.getCurrentVersion();
    final metrics = await getMetrics();

    if (currentVersion == null || metrics == null) {
      return DatabaseReport(
        reportId: 'report:${DateTime.now().millisecondsSinceEpoch}',
        generatedAt: DateTime.now(),
        schemaVersion: SchemaVersion(
          versionId: 'empty',
          version: '0.0.0',
          tables: [],
          appliedAt: DateTime.now(),
        ),
        metrics: DatabaseMetrics(
          metricsId: 'empty',
          totalTables: 0,
          totalColumns: 0,
          totalIndexes: 0,
          totalForeignKeys: 0,
          averageColumnCount: 0.0,
          averageIndexCount: 0.0,
          createdAt: DateTime.now(),
        ),
        recommendations: ['Initialize schema first'],
      );
    }

    final recommendations = _generateRecommendations(metrics);

    return DatabaseReport(
      reportId: 'report:${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: DateTime.now(),
      schemaVersion: currentVersion,
      metrics: metrics,
      recommendations: recommendations,
    );
  }

  List<String> _generateRecommendations(DatabaseMetrics metrics) {
    final recommendations = <String>[];

    if (metrics.totalIndexes < metrics.totalTables) {
      recommendations.add('Consider adding more indexes for better performance');
    }

    if (metrics.averageColumnCount > 20) {
      recommendations.add('Tables have many columns; consider normalization');
    }

    if (metrics.healthScore < 50) {
      recommendations.add('Schema health score is low; review table structure');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Schema is well-designed');
    }

    return recommendations;
  }
}

/// データベースマネージャーファサード
class DatabaseManagerFacade {
  late DatabaseRepository _repository;
  late SchemaEngine _schemaEngine;
  late MigrationEngine _migrationEngine;
  late DatabaseManager _manager;

  DatabaseManagerFacade({
    DatabaseRepository? repository,
    SchemaEngine? schemaEngine,
    MigrationEngine? migrationEngine,
    DatabaseManager? manager,
  }) {
    _repository = repository ?? MemoryDatabaseRepository();
    _schemaEngine = schemaEngine ?? MemorySchemaEngine(_repository);
    _migrationEngine = migrationEngine ?? MemoryMigrationEngine(_repository);
    _manager = manager ??
        MemoryDatabaseManager(_repository, _schemaEngine, _migrationEngine);
  }

  /// テーブルを作成
  Future<void> createTable(Table table) => _schemaEngine.createTable(table);

  /// テーブルを削除
  Future<void> dropTable(String tableId) => _schemaEngine.dropTable(tableId);

  /// テーブルを取得
  Future<Table?> getTable(String tableId) => _schemaEngine.getTable(tableId);

  /// すべてのテーブルを取得
  Future<List<Table>> getAllTables() => _schemaEngine.getSchema();

  /// カラムを追加
  Future<void> addColumn(String tableId, Column column) =>
      _schemaEngine.addColumn(tableId, column);

  /// カラムを削除
  Future<void> dropColumn(String tableId, String columnName) =>
      _schemaEngine.dropColumn(tableId, columnName);

  /// インデックスを作成
  Future<void> createIndex(Index index) => _schemaEngine.createIndex(index);

  /// インデックスを削除
  Future<void> dropIndex(String indexId) => _schemaEngine.dropIndex(indexId);

  /// テーブルのインデックスを取得
  Future<List<Index>> getIndexesByTable(String tableId) =>
      _repository.getIndexesByTable(tableId);

  /// 外部キーを作成
  Future<void> createForeignKey(ForeignKey foreignKey) =>
      _repository.saveForeignKey(foreignKey);

  /// テーブルの外部キーを取得
  Future<List<ForeignKey>> getForeignKeysByTable(String tableId) =>
      _repository.getForeignKeysByTable(tableId);

  /// スキーマを作成
  Future<void> createSchema(SchemaVersion version) =>
      _manager.createSchema(version);

  /// マイグレーションを実行
  Future<void> applyMigration(Migration migration) =>
      _migrationEngine.applyMigration(migration);

  /// マイグレーションをロールバック
  Future<void> rollbackMigration(Migration migration) =>
      _migrationEngine.rollbackMigration(migration);

  /// スキーマをマイグレーション
  Future<void> migrateSchema(String targetVersion) =>
      _manager.migrateSchema(targetVersion);

  /// ペンディングマイグレーションを取得
  Future<List<Migration>> getPendingMigrations() =>
      _migrationEngine.getPendingMigrations();

  /// 実行済みマイグレーションを取得
  Future<List<Migration>> getAppliedMigrations() =>
      _migrationEngine.getAppliedMigrations();

  /// マイグレーション履歴を取得
  Future<List<Migration>> getMigrationHistory() =>
      _manager.getMigrationHistory();

  /// 現在のスキーマバージョンを取得
  Future<SchemaVersion?> getCurrentVersion() =>
      _migrationEngine.getCurrentVersion();

  /// メトリクスを取得
  Future<DatabaseMetrics?> getMetrics() => _manager.getMetrics();

  /// レポートを生成
  Future<DatabaseReport> generateReport() => _manager.generateReport();

  /// スキーマ操作を実行
  Future<void> executeSchemaOperation(
    DatabaseOperation operation,
    dynamic data,
  ) async {
    switch (operation) {
      case DatabaseOperation.create:
        if (data is Table) {
          await createTable(data);
        } else if (data is Index) {
          await createIndex(data);
        } else if (data is ForeignKey) {
          await createForeignKey(data);
        }
        break;
      case DatabaseOperation.read:
        // Read operations return values
        break;
      case DatabaseOperation.update:
        // Update operations (e.g., alter table)
        break;
      case DatabaseOperation.delete:
        if (data is String) {
          // Assuming it's a table ID
          await dropTable(data);
        }
        break;
      case DatabaseOperation.migrate:
        if (data is Migration) {
          await applyMigration(data);
        }
        break;
    }
  }
}
