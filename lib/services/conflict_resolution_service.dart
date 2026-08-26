import 'package:flutter/foundation.dart';

/// データコンフリクト解決戦略
enum ConflictResolutionStrategy {
  /// Last-Write-Wins：最新のタイムスタンプを持つデータを採用
  lastWriteWins,

  /// ローカルファースト：ローカルデータを常に優先
  localFirst,

  /// リモートファースト：リモートデータを常に優先
  remoteFirst,
}

/// コンフリクト解決サービス
///
/// ローカルデータとリモート（Firestore）データが異なる場合、
/// 指定された戦略に基づいてどちらを採用するかを決定します。
abstract class ConflictResolutionService {
  /// 2つのデータセットのコンフリクトを解決
  ///
  /// [local]: ローカルデータ
  /// [remote]: リモートデータ
  /// [localTimestamp]: ローカルデータの更新時刻
  /// [remoteTimestamp]: リモートデータの更新時刻
  ///
  /// 戻り値：解決済みデータ('local' または 'remote')
  String resolveConflict<T>({
    required T local,
    required T remote,
    required DateTime localTimestamp,
    required DateTime remoteTimestamp,
  });

  /// Last-Write-Wins戦略：より新しいタイムスタンプを持つデータを選択
  String resolveLastWriteWins({
    required DateTime localTimestamp,
    required DateTime remoteTimestamp,
  });
}

/// ConflictResolutionService の実装
class DefaultConflictResolutionService implements ConflictResolutionService {
  DefaultConflictResolutionService({
    this.strategy = ConflictResolutionStrategy.lastWriteWins,
  });

  final ConflictResolutionStrategy strategy;

  @override
  String resolveConflict<T>({
    required T local,
    required T remote,
    required DateTime localTimestamp,
    required DateTime remoteTimestamp,
  }) {
    final result = switch (strategy) {
      ConflictResolutionStrategy.lastWriteWins =>
        resolveLastWriteWins(
          localTimestamp: localTimestamp,
          remoteTimestamp: remoteTimestamp,
        ),
      ConflictResolutionStrategy.localFirst => 'local',
      ConflictResolutionStrategy.remoteFirst => 'remote',
    };

    if (kDebugMode) {
      debugPrint(
        'ConflictResolutionService: Resolved conflict using ${strategy.name} strategy. '
        'Selected: $result (local: $localTimestamp, remote: $remoteTimestamp)',
      );
    }

    return result;
  }

  @override
  String resolveLastWriteWins({
    required DateTime localTimestamp,
    required DateTime remoteTimestamp,
  }) {
    if (localTimestamp.isAfter(remoteTimestamp)) {
      return 'local';
    } else if (remoteTimestamp.isAfter(localTimestamp)) {
      return 'remote';
    } else {
      // タイムスタンプが同じ場合はローカルを優先（安定性のため）
      return 'local';
    }
  }
}

/// テスト用スタブ実装
class StubConflictResolutionService implements ConflictResolutionService {
  StubConflictResolutionService({
    this.strategy = ConflictResolutionStrategy.lastWriteWins,
  });

  final ConflictResolutionStrategy strategy;

  @override
  String resolveConflict<T>({
    required T local,
    required T remote,
    required DateTime localTimestamp,
    required DateTime remoteTimestamp,
  }) {
    if (kDebugMode) {
      print('Stub: Resolved conflict using ${strategy.name} strategy');
    }
    return 'local'; // デフォルトはローカルを優先
  }

  @override
  String resolveLastWriteWins({
    required DateTime localTimestamp,
    required DateTime remoteTimestamp,
  }) {
    return localTimestamp.isAfter(remoteTimestamp) ? 'local' : 'remote';
  }
}
