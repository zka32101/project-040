/// Phase 43: Database Schema Management データベーススキーマモデル定義
///
/// スキーマ定義、マイグレーション、インデックス、制約

/// カラムタイプ
enum ColumnType {
  string('string'),
  integer('integer'),
  decimal('decimal'),
  boolean('boolean'),
  datetime('datetime'),
  json('json'),
  bytes('bytes'),
  uuid('uuid');

  final String value;
  const ColumnType(this.value);
}

/// 制約タイプ
enum ConstraintType {
  primaryKey('primary_key'),
  unique('unique'),
  notNull('not_null'),
  foreignKey('foreign_key'),
  check('check'),
  defaultValue('default');

  final String value;
  const ConstraintType(this.value);
}

/// インデックスタイプ
enum IndexType {
  btree('btree'),        // B-tree インデックス
  hash('hash'),          // ハッシュインデックス
  fulltext('fulltext'),  // 全文検索インデックス
  spatial('spatial');    // 空間インデックス

  final String value;
  const IndexType(this.value);
}

/// マイグレーション状態
enum MigrationStatus {
  pending('pending'),
  running('running'),
  completed('completed'),
  rollback('rollback'),
  failed('failed');

  final String value;
  const MigrationStatus(this.value);
}

/// データベース操作タイプ
enum DatabaseOperation {
  create('create'),
  read('read'),
  update('update'),
  delete('delete'),
  migrate('migrate');

  final String value;
  const DatabaseOperation(this.value);
}

/// カラム定義
class Column {
  final String columnId;
  final String name;
  final ColumnType type;
  final bool nullable;
  final dynamic defaultValue;
  final List<ConstraintType> constraints;
  final int? maxLength;
  final DateTime createdAt;

  Column({
    required this.columnId,
    required this.name,
    required this.type,
    this.nullable = true,
    this.defaultValue,
    List<ConstraintType>? constraints,
    this.maxLength,
    required this.createdAt,
  }) : constraints = constraints ?? [];

  /// NotNull 制約があるか
  bool get hasNotNull => constraints.contains(ConstraintType.notNull);

  /// ユニーク制約があるか
  bool get hasUnique => constraints.contains(ConstraintType.unique);

  /// プライマリキー制約があるか
  bool get isPrimaryKey => constraints.contains(ConstraintType.primaryKey);
}

/// テーブル定義
class Table {
  final String tableId;
  final String name;
  final List<Column> columns;
  final String? primaryKey;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Table({
    required this.tableId,
    required this.name,
    required this.columns,
    this.primaryKey,
    required this.createdAt,
    this.updatedAt,
  });

  /// カラン数
  int get columnCount => columns.length;

  /// 特定の名前のカラムを取得
  Column? getColumnByName(String name) {
    try {
      return columns.firstWhere((c) => c.name == name);
    } catch (e) {
      return null;
    }
  }

  /// すべてのインデックス対象カランを取得
  List<Column> getIndexableColumns() {
    return columns.where((c) => !c.type.toString().contains('json')).toList();
  }
}

/// インデックス定義
class Index {
  final String indexId;
  final String name;
  final String tableId;
  final List<String> columns;  // カラム名のリスト
  final IndexType type;
  final bool unique;
  final DateTime createdAt;

  Index({
    required this.indexId,
    required this.name,
    required this.tableId,
    required this.columns,
    required this.type,
    this.unique = false,
    required this.createdAt,
  });

  /// 複合インデックスか
  bool get isComposite => columns.length > 1;

  /// インデックスサイズ推定 (バイト)
  int get estimatedSizeBytes => columns.length * 1000;
}

/// 外部キー定義
class ForeignKey {
  final String foreignKeyId;
  final String name;
  final String tableId;
  final String columnId;
  final String referencedTableId;
  final String referencedColumnId;
  final String onDelete;  // CASCADE, SET NULL, RESTRICT
  final String onUpdate;  // CASCADE, SET NULL, RESTRICT
  final DateTime createdAt;

  ForeignKey({
    required this.foreignKeyId,
    required this.name,
    required this.tableId,
    required this.columnId,
    required this.referencedTableId,
    required this.referencedColumnId,
    this.onDelete = 'CASCADE',
    this.onUpdate = 'CASCADE',
    required this.createdAt,
  });
}

/// マイグレーション定義
class Migration {
  final String migrationId;
  final String version;
  final String description;
  final String upScript;
  final String downScript;
  MigrationStatus status;
  final DateTime createdAt;
  DateTime? appliedAt;
  DateTime? rolledbackAt;
  String? errorMessage;

  Migration({
    required this.migrationId,
    required this.version,
    required this.description,
    required this.upScript,
    required this.downScript,
    this.status = MigrationStatus.pending,
    required this.createdAt,
    this.appliedAt,
    this.rolledbackAt,
    this.errorMessage,
  });

  /// マイグレーション実行
  void apply() {
    status = MigrationStatus.running;
    appliedAt = DateTime.now();
    status = MigrationStatus.completed;
  }

  /// マイグレーションロールバック
  void rollback() {
    status = MigrationStatus.rollback;
    rolledbackAt = DateTime.now();
  }

  /// 実行可能か
  bool get isApplicable => status == MigrationStatus.pending;

  /// ロールバック可能か
  bool get isRollbackable => status == MigrationStatus.completed;
}

/// スキーマバージョン
class SchemaVersion {
  final String versionId;
  final String version;
  final List<Table> tables;
  final List<Index>? indexes;
  final List<ForeignKey>? foreignKeys;
  final DateTime appliedAt;
  final String? description;

  SchemaVersion({
    required this.versionId,
    required this.version,
    required this.tables,
    this.indexes,
    this.foreignKeys,
    required this.appliedAt,
    this.description,
  });

  /// テーブル数
  int get tableCount => tables.length;

  /// インデックス数
  int get indexCount => indexes?.length ?? 0;

  /// 外部キー数
  int get foreignKeyCount => foreignKeys?.length ?? 0;

  /// スキーマの複雑度スコア（0-100）
  int get complexityScore {
    final tableScore = tableCount * 5;
    final columnScore = tables.fold(0, (sum, t) => sum + t.columnCount);
    final indexScore = indexCount * 3;
    final fkScore = foreignKeyCount * 2;

    final total = tableScore + columnScore + indexScore + fkScore;
    return (total / 5).toInt().clamp(0, 100);
  }
}

/// データベースメトリクス
class DatabaseMetrics {
  final String metricsId;
  final int totalTables;
  final int totalColumns;
  final int totalIndexes;
  final int totalForeignKeys;
  final double averageColumnCount;
  final double averageIndexCount;
  final DateTime createdAt;

  DatabaseMetrics({
    required this.metricsId,
    required this.totalTables,
    required this.totalColumns,
    required this.totalIndexes,
    required this.totalForeignKeys,
    required this.averageColumnCount,
    required this.averageIndexCount,
    required this.createdAt,
  });

  /// スキーマの正常性スコア（0-100）
  int get healthScore {
    // インデックス対テーブル比率が良いか、適切なテーブル設計か、などを評価
    final indexRatio = totalTables > 0 ? totalIndexes / totalTables : 0;
    final score = (indexRatio * 100).clamp(0.0, 100.0);
    return score.toInt();
  }
}

/// データベースレポート
class DatabaseReport {
  final String reportId;
  final DateTime generatedAt;
  final SchemaVersion schemaVersion;
  final DatabaseMetrics metrics;
  final List<String> recommendations;

  DatabaseReport({
    required this.reportId,
    required this.generatedAt,
    required this.schemaVersion,
    required this.metrics,
    List<String>? recommendations,
  }) : recommendations = recommendations ?? [];

  /// Markdown形式でレポートを生成
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Database Schema Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');
    buffer.writeln('## Schema Version');
    buffer.writeln('');
    buffer.writeln('- Version: ${schemaVersion.version}');
    buffer.writeln('- Tables: ${schemaVersion.tableCount}');
    buffer.writeln('- Indexes: ${schemaVersion.indexCount}');
    buffer.writeln('- Foreign Keys: ${schemaVersion.foreignKeyCount}');
    buffer.writeln('- Complexity Score: ${schemaVersion.complexityScore}/100');
    buffer.writeln('');

    buffer.writeln('## Metrics');
    buffer.writeln('');
    buffer.writeln('- Total Tables: ${metrics.totalTables}');
    buffer.writeln('- Total Columns: ${metrics.totalColumns}');
    buffer.writeln('- Average Columns per Table: ${metrics.averageColumnCount.toStringAsFixed(2)}');
    buffer.writeln('- Health Score: ${metrics.healthScore}/100');
    buffer.writeln('');

    if (recommendations.isNotEmpty) {
      buffer.writeln('## Recommendations');
      buffer.writeln('');
      for (final rec in recommendations) {
        buffer.writeln('- $rec');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}
