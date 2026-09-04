/// Phase 52: Database Persistence & Transaction Management データベース永続化・トランザクション管理
///
/// データベース接続、トランザクション管理、永続化、コネクションプール機能

/// トランザクション状態
enum TransactionState {
  pending('pending'),
  committed('committed'),
  rolledBack('rolled_back'),
  failed('failed');

  final String value;
  const TransactionState(this.value);
}

/// トランザクション分離レベル
enum IsolationLevel {
  readUncommitted('read_uncommitted'),
  readCommitted('read_committed'),
  repeatableRead('repeatable_read'),
  serializable('serializable');

  final String value;
  const IsolationLevel(this.value);
}

/// データベース操作種別
enum DatabaseOperationType {
  create('create'),
  read('read'),
  update('update'),
  delete('delete');

  final String value;
  const DatabaseOperationType(this.value);
}

/// データベース接続
class DatabaseConnection {
  final String connectionId;
  final String host;
  final int port;
  final String database;
  final DateTime createdAt;
  final DateTime? closedAt;
  final bool isActive;

  DatabaseConnection({
    required this.connectionId,
    required this.host,
    required this.port,
    required this.database,
    required this.createdAt,
    this.closedAt,
    this.isActive = true,
  });

  /// 接続がアクティブか
  bool get isOpen => isActive && closedAt == null;

  /// 接続時間
  Duration get connectionDuration => (closedAt ?? DateTime.now()).difference(createdAt);

  /// アイドル時間
  Duration? get idleTime {
    if (closedAt == null) return null;
    return closedAt!.difference(createdAt);
  }
}

/// トランザクション
class Transaction {
  final String transactionId;
  final String connectionId;
  final TransactionState state;
  final IsolationLevel isolationLevel;
  final DateTime startedAt;
  final DateTime? committedAt;
  final DateTime? rolledBackAt;
  final List<String> operationIds;
  final bool isReadOnly;

  Transaction({
    required this.transactionId,
    required this.connectionId,
    required this.state,
    required this.isolationLevel,
    required this.startedAt,
    this.committedAt,
    this.rolledBackAt,
    required this.operationIds,
    this.isReadOnly = false,
  });

  /// トランザクションがアクティブか
  bool get isActive => state == TransactionState.pending;

  /// トランザクションが成功したか
  bool get isSuccessful => state == TransactionState.committed;

  /// トランザクションが失敗したか
  bool get isFailed => state == TransactionState.failed || state == TransactionState.rolledBack;

  /// 操作数
  int get operationCount => operationIds.length;

  /// トランザクション実行時間
  Duration get executionTime {
    final endTime = committedAt ?? rolledBackAt ?? DateTime.now();
    return endTime.difference(startedAt);
  }
}

/// データベース操作
class DatabaseOperation {
  final String operationId;
  final String transactionId;
  final DatabaseOperationType type;
  final String table;
  final String? query;
  final Map<String, dynamic>? parameters;
  final DateTime executedAt;
  final Duration? executionTime;
  final bool isSuccessful;
  final String? errorMessage;

  DatabaseOperation({
    required this.operationId,
    required this.transactionId,
    required this.type,
    required this.table,
    this.query,
    this.parameters,
    required this.executedAt,
    this.executionTime,
    required this.isSuccessful,
    this.errorMessage,
  });

  /// 操作が成功したか
  bool get success => isSuccessful;

  /// 操作がエラーか
  bool get hasError => !isSuccessful && errorMessage != null;

  /// 実行時間（ミリ秒）
  int? get executionTimeMs => executionTime?.inMilliseconds;
}

/// コネクションプール
class ConnectionPool {
  final String poolId;
  final int maxConnections;
  final List<String> availableConnectionIds;
  final List<String> activeConnectionIds;
  final DateTime createdAt;
  final DateTime? lastAccessedAt;

  ConnectionPool({
    required this.poolId,
    required this.maxConnections,
    required this.availableConnectionIds,
    required this.activeConnectionIds,
    required this.createdAt,
    this.lastAccessedAt,
  });

  /// 利用可能な接続数
  int get availableCount => availableConnectionIds.length;

  /// アクティブな接続数
  int get activeCount => activeConnectionIds.length;

  /// 総接続数
  int get totalConnections => availableCount + activeCount;

  /// プール利用率
  double get utilizationRate {
    if (maxConnections == 0) return 0.0;
    return activeCount / maxConnections;
  }

  /// プールがいっぱいか
  bool get isFull => activeCount >= maxConnections;

  /// 利用可能か
  bool get hasAvailable => availableCount > 0;
}

/// 永続化統計
class PersistenceStats {
  final String statsId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalTransactions;
  final int successfulTransactions;
  final int failedTransactions;
  final int totalOperations;
  final Map<DatabaseOperationType, int> operationsByType;
  final double averageTransactionTime; // milliseconds
  final double successRate; // 0.0-1.0

  PersistenceStats({
    required this.statsId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalTransactions,
    required this.successfulTransactions,
    required this.failedTransactions,
    required this.totalOperations,
    required this.operationsByType,
    required this.averageTransactionTime,
    required this.successRate,
  });

  /// 失敗率
  double get failureRate {
    if (totalTransactions == 0) return 0.0;
    return failedTransactions / totalTransactions;
  }

  /// 最も多い操作タイプ
  DatabaseOperationType? get mostCommonOperation {
    if (operationsByType.isEmpty) return null;
    return operationsByType.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

/// トランザクションログ
class TransactionLog {
  final String logId;
  final List<Transaction> transactions;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  TransactionLog({
    required this.logId,
    required this.transactions,
    required this.createdAt,
    this.lastUpdated,
  });

  /// トランザクション数
  int get transactionCount => transactions.length;

  /// 成功数
  int get successCount => transactions.where((t) => t.isSuccessful).length;

  /// 失敗数
  int get failureCount => transactions.where((t) => t.isFailed).length;

  /// 成功率
  double get successRate {
    if (transactions.isEmpty) return 0.0;
    return successCount / transactions.length;
  }
}

/// データベース永続化レポート
class DatabasePersistenceReport {
  final String reportId;
  final DateTime generatedAt;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int activeConnections;
  final TransactionLog transactionLog;
  final PersistenceStats stats;
  final List<String>? recommendations;

  DatabasePersistenceReport({
    required this.reportId,
    required this.generatedAt,
    required this.periodStart,
    required this.periodEnd,
    required this.activeConnections,
    required this.transactionLog,
    required this.stats,
    this.recommendations,
  });

  /// Markdown形式で出力
  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Database Persistence Report');
    buffer.writeln('');
    buffer.writeln('**Generated**: ${generatedAt.toIso8601String()}');
    buffer.writeln('');

    buffer.writeln('## Summary');
    buffer.writeln('');
    buffer.writeln('- Active Connections: $activeConnections');
    buffer.writeln('- Total Transactions: ${stats.totalTransactions}');
    buffer.writeln('- Successful: ${stats.successfulTransactions}');
    buffer.writeln('- Failed: ${stats.failedTransactions}');
    buffer.writeln('- Success Rate: ${(stats.successRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('- Average Transaction Time: ${stats.averageTransactionTime.toStringAsFixed(0)}ms');
    buffer.writeln('');

    buffer.writeln('## Operations');
    buffer.writeln('');
    buffer.writeln('- Total Operations: ${stats.totalOperations}');
    for (final entry in stats.operationsByType.entries) {
      buffer.writeln('- ${entry.key.value}: ${entry.value}');
    }
    buffer.writeln('');

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

/// コネクション接続履歴
class ConnectionHistory {
  final String historyId;
  final List<DatabaseConnection> connections;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  ConnectionHistory({
    required this.historyId,
    required this.connections,
    required this.createdAt,
    this.lastUpdated,
  });

  /// 接続数
  int get connectionCount => connections.length;

  /// アクティブな接続数
  int get activeConnectionCount => connections.where((c) => c.isOpen).length;

  /// 閉じられた接続数
  int get closedConnectionCount => connections.where((c) => !c.isOpen).length;

  /// 平均接続時間
  double get averageConnectionDuration {
    if (connections.isEmpty) return 0.0;
    final totalDuration = connections.fold<int>(0, (sum, c) => sum + c.connectionDuration.inMilliseconds);
    return totalDuration / connections.length;
  }
}
