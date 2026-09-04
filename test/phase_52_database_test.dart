/// Phase 52: Database Persistence & Transaction Management Tests
import 'package:flutter_test/flutter_test.dart';
import 'package:project_040/models/database_models.dart';
import 'package:project_040/services/database_service.dart';

void main() {
  group('Phase 52: Database Persistence & Transaction Management', () {
    // ========== ENUM TESTS ==========
    group('Enum Tests', () {
      test('TransactionState enum values', () {
        expect(TransactionState.pending.value, 'pending');
        expect(TransactionState.committed.value, 'committed');
        expect(TransactionState.rolledBack.value, 'rolled_back');
        expect(TransactionState.failed.value, 'failed');
      });

      test('IsolationLevel enum values', () {
        expect(IsolationLevel.readUncommitted.value, 'read_uncommitted');
        expect(IsolationLevel.readCommitted.value, 'read_committed');
        expect(IsolationLevel.repeatableRead.value, 'repeatable_read');
        expect(IsolationLevel.serializable.value, 'serializable');
      });

      test('DatabaseOperationType enum values', () {
        expect(DatabaseOperationType.create.value, 'create');
        expect(DatabaseOperationType.read.value, 'read');
        expect(DatabaseOperationType.update.value, 'update');
        expect(DatabaseOperationType.delete.value, 'delete');
      });
    });

    // ========== MODEL TESTS ==========
    group('Model Tests', () {
      test('DatabaseConnection - basic properties', () {
        final conn = DatabaseConnection(
          connectionId: 'conn1',
          host: 'localhost',
          port: 5432,
          database: 'test_db',
          createdAt: DateTime.now(),
        );
        expect(conn.isOpen, true);
        expect(conn.isActive, true);
        expect(conn.closedAt, null);
      });

      test('DatabaseConnection - isOpen after close', () {
        final now = DateTime.now();
        final conn = DatabaseConnection(
          connectionId: 'conn1',
          host: 'localhost',
          port: 5432,
          database: 'test_db',
          createdAt: now,
          closedAt: now.add(Duration(minutes: 5)),
          isActive: false,
        );
        expect(conn.isOpen, false);
      });

      test('DatabaseConnection - connectionDuration', () {
        final now = DateTime.now();
        final conn = DatabaseConnection(
          connectionId: 'conn1',
          host: 'localhost',
          port: 5432,
          database: 'test_db',
          createdAt: now,
          closedAt: now.add(Duration(minutes: 10)),
        );
        expect(conn.connectionDuration.inMinutes, 10);
      });

      test('Transaction - isActive property', () {
        final txn = Transaction(
          transactionId: 'txn1',
          connectionId: 'conn1',
          state: TransactionState.pending,
          isolationLevel: IsolationLevel.readCommitted,
          startedAt: DateTime.now(),
          operationIds: [],
        );
        expect(txn.isActive, true);
      });

      test('Transaction - isSuccessful property', () {
        final now = DateTime.now();
        final txn = Transaction(
          transactionId: 'txn1',
          connectionId: 'conn1',
          state: TransactionState.committed,
          isolationLevel: IsolationLevel.readCommitted,
          startedAt: now,
          committedAt: now.add(Duration(milliseconds: 100)),
          operationIds: [],
        );
        expect(txn.isSuccessful, true);
      });

      test('Transaction - isFailed property', () {
        final txn = Transaction(
          transactionId: 'txn1',
          connectionId: 'conn1',
          state: TransactionState.failed,
          isolationLevel: IsolationLevel.readCommitted,
          startedAt: DateTime.now(),
          operationIds: [],
        );
        expect(txn.isFailed, true);
      });

      test('Transaction - operationCount', () {
        final txn = Transaction(
          transactionId: 'txn1',
          connectionId: 'conn1',
          state: TransactionState.pending,
          isolationLevel: IsolationLevel.readCommitted,
          startedAt: DateTime.now(),
          operationIds: ['op1', 'op2', 'op3'],
        );
        expect(txn.operationCount, 3);
      });

      test('DatabaseOperation - success property', () {
        final op = DatabaseOperation(
          operationId: 'op1',
          transactionId: 'txn1',
          type: DatabaseOperationType.create,
          table: 'users',
          executedAt: DateTime.now(),
          isSuccessful: true,
        );
        expect(op.success, true);
      });

      test('DatabaseOperation - hasError property', () {
        final op = DatabaseOperation(
          operationId: 'op1',
          transactionId: 'txn1',
          type: DatabaseOperationType.read,
          table: 'users',
          executedAt: DateTime.now(),
          isSuccessful: false,
          errorMessage: 'Connection timeout',
        );
        expect(op.hasError, true);
      });

      test('ConnectionPool - utilizationRate', () {
        final pool = ConnectionPool(
          poolId: 'pool1',
          maxConnections: 10,
          availableConnectionIds: ['c1', 'c2', 'c3'],
          activeConnectionIds: ['c4', 'c5'],
          createdAt: DateTime.now(),
        );
        expect(pool.utilizationRate, 0.2);
      });

      test('ConnectionPool - isFull property', () {
        final pool = ConnectionPool(
          poolId: 'pool1',
          maxConnections: 2,
          availableConnectionIds: [],
          activeConnectionIds: ['c1', 'c2'],
          createdAt: DateTime.now(),
        );
        expect(pool.isFull, true);
      });

      test('PersistenceStats - failureRate', () {
        final stats = PersistenceStats(
          statsId: 'stats1',
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          totalTransactions: 100,
          successfulTransactions: 90,
          failedTransactions: 10,
          totalOperations: 500,
          operationsByType: {},
          averageTransactionTime: 50.0,
          successRate: 0.9,
        );
        expect(stats.failureRate, 0.1);
      });

      test('TransactionLog - successRate', () {
        final now = DateTime.now();
        final txn1 = Transaction(
          transactionId: 'txn1',
          connectionId: 'conn1',
          state: TransactionState.committed,
          isolationLevel: IsolationLevel.readCommitted,
          startedAt: now,
          operationIds: [],
        );
        final txn2 = Transaction(
          transactionId: 'txn2',
          connectionId: 'conn1',
          state: TransactionState.failed,
          isolationLevel: IsolationLevel.readCommitted,
          startedAt: now,
          operationIds: [],
        );
        final log = TransactionLog(
          logId: 'log1',
          transactions: [txn1, txn2],
          createdAt: DateTime.now(),
        );
        expect(log.successRate, 0.5);
      });

      test('DatabasePersistenceReport - toMarkdown', () {
        final report = DatabasePersistenceReport(
          reportId: 'report1',
          generatedAt: DateTime.now(),
          periodStart: DateTime.now(),
          periodEnd: DateTime.now(),
          activeConnections: 5,
          transactionLog: TransactionLog(
            logId: 'log1',
            transactions: [],
            createdAt: DateTime.now(),
          ),
          stats: PersistenceStats(
            statsId: 'stats1',
            periodStart: DateTime.now(),
            periodEnd: DateTime.now(),
            totalTransactions: 100,
            successfulTransactions: 95,
            failedTransactions: 5,
            totalOperations: 500,
            operationsByType: {},
            averageTransactionTime: 50.0,
            successRate: 0.95,
          ),
        );
        final markdown = report.toMarkdown();
        expect(markdown.contains('Database Persistence Report'), true);
        expect(markdown.contains('Active Connections: 5'), true);
      });

      test('ConnectionHistory - averageConnectionDuration', () {
        final now = DateTime.now();
        final conn1 = DatabaseConnection(
          connectionId: 'c1',
          host: 'localhost',
          port: 5432,
          database: 'db',
          createdAt: now,
          closedAt: now.add(Duration(seconds: 10)),
        );
        final conn2 = DatabaseConnection(
          connectionId: 'c2',
          host: 'localhost',
          port: 5432,
          database: 'db',
          createdAt: now,
          closedAt: now.add(Duration(seconds: 20)),
        );
        final history = ConnectionHistory(
          historyId: 'hist1',
          connections: [conn1, conn2],
          createdAt: DateTime.now(),
        );
        expect(history.averageConnectionDuration, 15000.0);
      });
    });

    // ========== REPOSITORY TESTS ==========
    group('Repository Tests', () {
      late MemoryDatabaseRepository repository;

      setUp(() {
        repository = MemoryDatabaseRepository();
      });

      test('Repository - addConnection and getConnection', () async {
        final conn = DatabaseConnection(
          connectionId: 'conn1',
          host: 'localhost',
          port: 5432,
          database: 'test_db',
          createdAt: DateTime.now(),
        );
        await repository.addConnection(conn);
        final retrieved = await repository.getConnection('conn1');
        expect(retrieved?.connectionId, 'conn1');
      });

      test('Repository - getAllConnections', () async {
        final conn1 = DatabaseConnection(
          connectionId: 'conn1',
          host: 'localhost',
          port: 5432,
          database: 'db1',
          createdAt: DateTime.now(),
        );
        final conn2 = DatabaseConnection(
          connectionId: 'conn2',
          host: 'localhost',
          port: 5432,
          database: 'db2',
          createdAt: DateTime.now(),
        );
        await repository.addConnection(conn1);
        await repository.addConnection(conn2);
        final all = await repository.getAllConnections();
        expect(all.length, 2);
      });

      test('Repository - addTransaction and getTransaction', () async {
        final txn = Transaction(
          transactionId: 'txn1',
          connectionId: 'conn1',
          state: TransactionState.pending,
          isolationLevel: IsolationLevel.readCommitted,
          startedAt: DateTime.now(),
          operationIds: [],
        );
        await repository.addTransaction(txn);
        final retrieved = await repository.getTransaction('txn1');
        expect(retrieved?.transactionId, 'txn1');
      });

      test('Repository - getTransactionsByState', () async {
        final txn1 = Transaction(
          transactionId: 'txn1',
          connectionId: 'conn1',
          state: TransactionState.committed,
          isolationLevel: IsolationLevel.readCommitted,
          startedAt: DateTime.now(),
          operationIds: [],
        );
        final txn2 = Transaction(
          transactionId: 'txn2',
          connectionId: 'conn1',
          state: TransactionState.pending,
          isolationLevel: IsolationLevel.readCommitted,
          startedAt: DateTime.now(),
          operationIds: [],
        );
        await repository.addTransaction(txn1);
        await repository.addTransaction(txn2);
        final committed = await repository.getTransactionsByState(TransactionState.committed);
        expect(committed.length, 1);
      });

      test('Repository - addOperation and getOperation', () async {
        final op = DatabaseOperation(
          operationId: 'op1',
          transactionId: 'txn1',
          type: DatabaseOperationType.create,
          table: 'users',
          executedAt: DateTime.now(),
          isSuccessful: true,
        );
        await repository.addOperation(op);
        final retrieved = await repository.getOperation('op1');
        expect(retrieved?.operationId, 'op1');
      });

      test('Repository - getOperationsByTransaction', () async {
        final op1 = DatabaseOperation(
          operationId: 'op1',
          transactionId: 'txn1',
          type: DatabaseOperationType.create,
          table: 'users',
          executedAt: DateTime.now(),
          isSuccessful: true,
        );
        final op2 = DatabaseOperation(
          operationId: 'op2',
          transactionId: 'txn1',
          type: DatabaseOperationType.update,
          table: 'users',
          executedAt: DateTime.now(),
          isSuccessful: true,
        );
        await repository.addOperation(op1);
        await repository.addOperation(op2);
        final ops = await repository.getOperationsByTransaction('txn1');
        expect(ops.length, 2);
      });

      test('Repository - closeConnection', () async {
        final conn = DatabaseConnection(
          connectionId: 'conn1',
          host: 'localhost',
          port: 5432,
          database: 'test_db',
          createdAt: DateTime.now(),
        );
        await repository.addConnection(conn);
        await repository.closeConnection('conn1');
        final closed = await repository.getConnection('conn1');
        expect(closed?.isOpen, false);
      });
    });

    // ========== ENGINE TESTS ==========
    group('Engine Tests', () {
      late MemoryTransactionEngine engine;

      setUp(() {
        engine = MemoryTransactionEngine();
      });

      test('Engine - beginTransaction', () async {
        final txn = await engine.beginTransaction('conn1', IsolationLevel.readCommitted, false);
        expect(txn.state, TransactionState.pending);
        expect(txn.isActive, true);
      });

      test('Engine - commitTransaction', () async {
        final txn = await engine.beginTransaction('conn1', IsolationLevel.readCommitted, false);
        final committed = await engine.commitTransaction(txn.transactionId);
        expect(committed.state, TransactionState.committed);
        expect(committed.isSuccessful, true);
      });

      test('Engine - rollbackTransaction', () async {
        final txn = await engine.beginTransaction('conn1', IsolationLevel.readCommitted, false);
        final rolledBack = await engine.rollbackTransaction(txn.transactionId);
        expect(rolledBack.state, TransactionState.rolledBack);
        expect(rolledBack.isFailed, true);
      });

      test('Engine - executeOperation', () async {
        final txn = await engine.beginTransaction('conn1', IsolationLevel.readCommitted, false);
        final op = await engine.executeOperation(
          txn.transactionId,
          DatabaseOperationType.create,
          'users',
          'INSERT INTO users ...',
          {},
        );
        expect(op.isSuccessful, true);
        expect(op.type, DatabaseOperationType.create);
      });

      test('Engine - calculateStats', () async {
        final now = DateTime.now();
        final txn = Transaction(
          transactionId: 'txn1',
          connectionId: 'conn1',
          state: TransactionState.committed,
          isolationLevel: IsolationLevel.readCommitted,
          startedAt: now,
          committedAt: now.add(Duration(milliseconds: 50)),
          operationIds: ['op1', 'op2'],
        );
        final stats = await engine.calculateStats([txn], now.subtract(Duration(hours: 1)), now.add(Duration(hours: 1)));
        expect(stats.totalTransactions, 1);
        expect(stats.successfulTransactions, 1);
      });
    });

    // ========== MANAGER TESTS ==========
    group('Manager Tests', () {
      late MemoryDatabaseManager manager;
      late MemoryDatabaseRepository repository;
      late MemoryTransactionEngine engine;

      setUp(() {
        repository = MemoryDatabaseRepository();
        engine = MemoryTransactionEngine();
        manager = MemoryDatabaseManager(repository: repository, engine: engine);
      });

      test('Manager - createConnection', () async {
        final conn = await manager.createConnection('localhost', 5432, 'test_db');
        expect(conn.host, 'localhost');
        expect(conn.port, 5432);
      });

      test('Manager - startTransaction', () async {
        final conn = await manager.createConnection('localhost', 5432, 'test_db');
        final txn = await manager.startTransaction(conn.connectionId, IsolationLevel.serializable);
        expect(txn.state, TransactionState.pending);
      });

      test('Manager - commitTransaction', () async {
        final conn = await manager.createConnection('localhost', 5432, 'test_db');
        final txn = await manager.startTransaction(conn.connectionId, IsolationLevel.readCommitted);
        final committed = await manager.commitTransaction(txn.transactionId);
        expect(committed.isSuccessful, true);
      });

      test('Manager - executeQuery', () async {
        final conn = await manager.createConnection('localhost', 5432, 'test_db');
        final txn = await manager.startTransaction(conn.connectionId, IsolationLevel.readCommitted);
        final op = await manager.executeQuery(txn.transactionId, DatabaseOperationType.create, 'users', 'INSERT INTO users ...');
        expect(op.isSuccessful, true);
      });

      test('Manager - generateReport', () async {
        final now = DateTime.now();
        final report = await manager.generateReport(
          'report1',
          now.subtract(Duration(days: 1)),
          now,
        );
        expect(report.reportId, 'report1');
        expect(report.activeConnections, 0);
      });
    });

    // ========== FACADE TESTS ==========
    group('Facade Tests', () {
      late DatabaseFacade facade;

      setUp(() {
        facade = DatabaseFacade();
      });

      test('Facade - createConnection', () async {
        final conn = await facade.createConnection('localhost', 5432, 'test_db');
        expect(conn.host, 'localhost');
        expect(conn.isOpen, true);
      });

      test('Facade - startTransaction', () async {
        final conn = await facade.createConnection('localhost', 5432, 'test_db');
        final txn = await facade.startTransaction(conn.connectionId, IsolationLevel.readCommitted);
        expect(txn.state, TransactionState.pending);
      });

      test('Facade - executeQuery', () async {
        final conn = await facade.createConnection('localhost', 5432, 'test_db');
        final txn = await facade.startTransaction(conn.connectionId, IsolationLevel.readCommitted);
        final op = await facade.executeQuery(txn.transactionId, DatabaseOperationType.create, 'users', 'INSERT...');
        expect(op.type, DatabaseOperationType.create);
      });

      test('Facade - commitTransaction', () async {
        final conn = await facade.createConnection('localhost', 5432, 'test_db');
        final txn = await facade.startTransaction(conn.connectionId, IsolationLevel.readCommitted);
        final committed = await facade.commitTransaction(txn.transactionId);
        expect(committed.isSuccessful, true);
      });

      test('Facade - getAllConnections', () async {
        await facade.createConnection('localhost', 5432, 'db1');
        await facade.createConnection('localhost', 5432, 'db2');
        final all = await facade.getAllConnections();
        expect(all.length, 2);
      });

      test('Facade - generateReport', () async {
        final now = DateTime.now();
        final report = await facade.generateReport('report1', now.subtract(Duration(days: 1)), now);
        expect(report.reportId, 'report1');
      });
    });

    // ========== INTEGRATION TESTS ==========
    group('Integration Tests', () {
      late DatabaseFacade facade;

      setUp(() {
        facade = DatabaseFacade();
      });

      test('Integration - full transaction lifecycle', () async {
        final conn = await facade.createConnection('localhost', 5432, 'test_db');
        final txn = await facade.startTransaction(conn.connectionId, IsolationLevel.readCommitted);
        
        await facade.executeQuery(txn.transactionId, DatabaseOperationType.create, 'users', 'INSERT...');
        await facade.executeQuery(txn.transactionId, DatabaseOperationType.read, 'users', 'SELECT...');
        
        final committed = await facade.commitTransaction(txn.transactionId);
        expect(committed.isSuccessful, true);
        expect(committed.operationCount, 2);
      });

      test('Integration - multiple transactions', () async {
        final conn = await facade.createConnection('localhost', 5432, 'test_db');
        
        final txn1 = await facade.startTransaction(conn.connectionId, IsolationLevel.readCommitted);
        await facade.executeQuery(txn1.transactionId, DatabaseOperationType.create, 'users', 'INSERT...');
        await facade.commitTransaction(txn1.transactionId);
        
        final txn2 = await facade.startTransaction(conn.connectionId, IsolationLevel.readCommitted);
        await facade.executeQuery(txn2.transactionId, DatabaseOperationType.update, 'users', 'UPDATE...');
        await facade.rollbackTransaction(txn2.transactionId);
        
        final allConnections = await facade.getAllConnections();
        expect(allConnections.length, 1);
      });

      test('Integration - close connection', () async {
        final conn = await facade.createConnection('localhost', 5432, 'test_db');
        await facade.closeConnection(conn.connectionId);
        
        final closed = await facade.getConnection(conn.connectionId);
        expect(closed?.isOpen, false);
      });

      test('Integration - stats generation', () async {
        final now = DateTime.now();
        final stats = await facade.generateStats(now.subtract(Duration(days: 1)), now);
        expect(stats.totalTransactions >= 0, true);
      });

      test('Integration - report with recommendations', () async {
        final now = DateTime.now();
        final report = await facade.generateReport('report1', now.subtract(Duration(days: 1)), now);
        expect(report.stats.totalTransactions >= 0, true);
      });

      test('Integration - multiple connections and transactions', () async {
        final conn1 = await facade.createConnection('localhost', 5432, 'db1');
        final conn2 = await facade.createConnection('localhost', 5432, 'db2');
        
        final txn1 = await facade.startTransaction(conn1.connectionId, IsolationLevel.serializable);
        final txn2 = await facade.startTransaction(conn2.connectionId, IsolationLevel.readCommitted);
        
        await facade.executeQuery(txn1.transactionId, DatabaseOperationType.create, 'users', 'INSERT...');
        await facade.executeQuery(txn2.transactionId, DatabaseOperationType.delete, 'orders', 'DELETE...');
        
        await facade.commitTransaction(txn1.transactionId);
        await facade.commitTransaction(txn2.transactionId);
        
        final allConns = await facade.getAllConnections();
        expect(allConns.length, 2);
      });
    });
  });
}
