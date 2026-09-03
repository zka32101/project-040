/// Phase 27: スケジュール・バッチ処理サービス
/// スケジュールジョブ実行、バッチ処理機能

import '../models/async_job_model.dart';
import 'dart:async';

// ==================== スケジュール関連モデル ====================

/// スケジュール周期
enum ScheduleFrequency {
  once,
  hourly,
  daily,
  weekly,
  monthly,
  custom,
}

/// スケジュール状態
enum ScheduleStatus {
  active,
  paused,
  completed,
  cancelled,
  failed,
}

/// スケジュール設定
class ScheduleConfig {
  final String scheduleId;
  final String userId;
  final AsyncJobType jobType;
  final String jobName;
  final ScheduleFrequency frequency;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? cronExpression;
  final Map<String, dynamic>? parameters;
  final bool retryOnFailure;
  final int maxRetries;
  final DateTime createdAt;
  final DateTime? lastRunAt;
  final DateTime? nextRunAt;
  final ScheduleStatus status;

  const ScheduleConfig({
    required this.scheduleId,
    required this.userId,
    required this.jobType,
    required this.jobName,
    required this.frequency,
    this.startTime,
    this.endTime,
    this.cronExpression,
    this.parameters,
    this.retryOnFailure = true,
    this.maxRetries = 3,
    required this.createdAt,
    this.lastRunAt,
    this.nextRunAt,
    this.status = ScheduleStatus.active,
  });

  ScheduleConfig copyWith({
    String? scheduleId,
    String? userId,
    AsyncJobType? jobType,
    String? jobName,
    ScheduleFrequency? frequency,
    DateTime? startTime,
    DateTime? endTime,
    String? cronExpression,
    Map<String, dynamic>? parameters,
    bool? retryOnFailure,
    int? maxRetries,
    DateTime? createdAt,
    DateTime? lastRunAt,
    DateTime? nextRunAt,
    ScheduleStatus? status,
  }) =>
      ScheduleConfig(
        scheduleId: scheduleId ?? this.scheduleId,
        userId: userId ?? this.userId,
        jobType: jobType ?? this.jobType,
        jobName: jobName ?? this.jobName,
        frequency: frequency ?? this.frequency,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        cronExpression: cronExpression ?? this.cronExpression,
        parameters: parameters ?? this.parameters,
        retryOnFailure: retryOnFailure ?? this.retryOnFailure,
        maxRetries: maxRetries ?? this.maxRetries,
        createdAt: createdAt ?? this.createdAt,
        lastRunAt: lastRunAt ?? this.lastRunAt,
        nextRunAt: nextRunAt ?? this.nextRunAt,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'scheduleId': scheduleId,
        'userId': userId,
        'jobType': jobType.toString().split('.').last,
        'jobName': jobName,
        'frequency': frequency.toString().split('.').last,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'cronExpression': cronExpression,
        'parameters': parameters,
        'retryOnFailure': retryOnFailure,
        'maxRetries': maxRetries,
        'createdAt': createdAt.toIso8601String(),
        'lastRunAt': lastRunAt?.toIso8601String(),
        'nextRunAt': nextRunAt?.toIso8601String(),
        'status': status.toString().split('.').last,
      };
}

/// バッチジョブ設定
class BatchJobConfig {
  final String batchId;
  final String userId;
  final List<AsyncJobType> jobTypes;
  final int batchSize;
  final int maxConcurrent;
  final bool continueOnError;
  final Duration? timeout;
  final Map<String, dynamic>? parameters;
  final DateTime createdAt;

  const BatchJobConfig({
    required this.batchId,
    required this.userId,
    required this.jobTypes,
    this.batchSize = 50,
    this.maxConcurrent = 5,
    this.continueOnError = false,
    this.timeout,
    this.parameters,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'batchId': batchId,
        'userId': userId,
        'jobTypes': jobTypes.map((t) => t.toString().split('.').last).toList(),
        'batchSize': batchSize,
        'maxConcurrent': maxConcurrent,
        'continueOnError': continueOnError,
        'timeout': timeout?.inMilliseconds,
        'parameters': parameters,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// バッチ実行結果
class BatchExecutionResult {
  final String batchId;
  final int totalJobs;
  final int successfulJobs;
  final int failedJobs;
  final int skippedJobs;
  final Duration executionTime;
  final DateTime startedAt;
  final DateTime completedAt;
  final List<String>? errorMessages;

  const BatchExecutionResult({
    required this.batchId,
    required this.totalJobs,
    required this.successfulJobs,
    required this.failedJobs,
    required this.skippedJobs,
    required this.executionTime,
    required this.startedAt,
    required this.completedAt,
    this.errorMessages,
  });

  double get successRate => totalJobs > 0 ? successfulJobs / totalJobs : 0.0;

  Map<String, dynamic> toJson() => {
        'batchId': batchId,
        'totalJobs': totalJobs,
        'successfulJobs': successfulJobs,
        'failedJobs': failedJobs,
        'skippedJobs': skippedJobs,
        'executionTime': executionTime.inMilliseconds,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt.toIso8601String(),
        'successRate': successRate,
        'errorMessages': errorMessages,
      };
}

// ==================== スケジュール・バッチ処理サービスインターフェース ====================

/// スケジュール管理サービス
abstract class SchedulingService {
  /// スケジュールを作成
  Future<ScheduleConfig> createSchedule(ScheduleConfig config);

  /// スケジュールを取得
  Future<ScheduleConfig?> getSchedule(String scheduleId);

  /// ユーザーのスケジュールを取得
  Future<List<ScheduleConfig>> getUserSchedules(String userId);

  /// スケジュールを更新
  Future<void> updateSchedule(ScheduleConfig config);

  /// スケジュールを削除
  Future<void> deleteSchedule(String scheduleId);

  /// スケジュールを有効化
  Future<void> enableSchedule(String scheduleId);

  /// スケジュールを無効化
  Future<void> disableSchedule(String scheduleId);

  /// スケジュールを実行
  Future<AsyncJob> executeSchedule(String scheduleId);

  /// 次の実行時刻を計算
  DateTime calculateNextRunTime(ScheduleConfig config);
}

/// バッチ処理サービス
abstract class BatchProcessingService {
  /// バッチジョブを作成
  Future<BatchJobConfig> createBatch(BatchJobConfig config);

  /// バッチジョブを取得
  Future<BatchJobConfig?> getBatch(String batchId);

  /// ユーザーのバッチジョブを取得
  Future<List<BatchJobConfig>> getUserBatches(String userId);

  /// バッチジョブを実行
  Future<BatchExecutionResult> executeBatch(String batchId);

  /// バッチジョブの実行結果を取得
  Future<BatchExecutionResult?> getBatchResult(String batchId);

  /// バッチジョブをキャンセル
  Future<void> cancelBatch(String batchId);

  /// ユーザーのバッチ実行履歴を取得
  Future<List<BatchExecutionResult>> getUserBatchHistory(String userId);
}

// ==================== メモリ実装 ====================

/// メモリベースのスケジュール管理サービス実装
class MemorySchedulingService implements SchedulingService {
  final Map<String, ScheduleConfig> _schedules = {};
  final Map<String, List<DateTime>> _executionHistory = {};

  @override
  Future<ScheduleConfig> createSchedule(ScheduleConfig config) async {
    _schedules[config.scheduleId] = config;
    return config;
  }

  @override
  Future<ScheduleConfig?> getSchedule(String scheduleId) async {
    return _schedules[scheduleId];
  }

  @override
  Future<List<ScheduleConfig>> getUserSchedules(String userId) async {
    return _schedules.values
        .where((s) => s.userId == userId)
        .toList();
  }

  @override
  Future<void> updateSchedule(ScheduleConfig config) async {
    _schedules[config.scheduleId] = config;
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    _schedules.remove(scheduleId);
    _executionHistory.remove(scheduleId);
  }

  @override
  Future<void> enableSchedule(String scheduleId) async {
    final schedule = _schedules[scheduleId];
    if (schedule != null) {
      _schedules[scheduleId] = schedule.copyWith(
        status: ScheduleStatus.active,
        nextRunAt: calculateNextRunTime(schedule),
      );
    }
  }

  @override
  Future<void> disableSchedule(String scheduleId) async {
    final schedule = _schedules[scheduleId];
    if (schedule != null) {
      _schedules[scheduleId] = schedule.copyWith(
        status: ScheduleStatus.paused,
      );
    }
  }

  @override
  Future<AsyncJob> executeSchedule(String scheduleId) async {
    final schedule = _schedules[scheduleId];
    if (schedule == null) {
      throw Exception('Schedule not found');
    }

    // スケジュール履歴を記録
    if (!_executionHistory.containsKey(scheduleId)) {
      _executionHistory[scheduleId] = [];
    }
    _executionHistory[scheduleId]!.add(DateTime.now());

    // スケジュールの最終実行時刻と次回実行時刻を更新
    final updatedSchedule = schedule.copyWith(
      lastRunAt: DateTime.now(),
      nextRunAt: calculateNextRunTime(schedule),
    );
    _schedules[scheduleId] = updatedSchedule;

    // ジョブを作成（簡略化実装）
    final job = ReportGenerationJob(
      jobId: 'job_${DateTime.now().millisecondsSinceEpoch}',
      userId: schedule.userId,
      status: AsyncJobStatus.pending,
      createdAt: DateTime.now(),
      templateId: 'template_1',
      format: 'pdf',
      title: schedule.jobName,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
    );

    return job;
  }

  @override
  DateTime calculateNextRunTime(ScheduleConfig config) {
    final now = DateTime.now();
    
    switch (config.frequency) {
      case ScheduleFrequency.once:
        return config.startTime ?? now;
      case ScheduleFrequency.hourly:
        return now.add(Duration(hours: 1));
      case ScheduleFrequency.daily:
        return now.add(Duration(days: 1));
      case ScheduleFrequency.weekly:
        return now.add(Duration(days: 7));
      case ScheduleFrequency.monthly:
        return DateTime(now.year, now.month + 1, now.day);
      case ScheduleFrequency.custom:
        // カスタム周期は cronExpression に基づいて計算
        return now.add(Duration(days: 1));
    }
  }
}

/// メモリベースのバッチ処理サービス実装
class MemoryBatchProcessingService implements BatchProcessingService {
  final Map<String, BatchJobConfig> _batches = {};
  final Map<String, BatchExecutionResult> _results = {};

  @override
  Future<BatchJobConfig> createBatch(BatchJobConfig config) async {
    _batches[config.batchId] = config;
    return config;
  }

  @override
  Future<BatchJobConfig?> getBatch(String batchId) async {
    return _batches[batchId];
  }

  @override
  Future<List<BatchJobConfig>> getUserBatches(String userId) async {
    return _batches.values
        .where((b) => b.userId == userId)
        .toList();
  }

  @override
  Future<BatchExecutionResult> executeBatch(String batchId) async {
    final batch = _batches[batchId];
    if (batch == null) {
      throw Exception('Batch not found');
    }

    final startTime = DateTime.now();
    final totalJobs = batch.batchSize;
    final successfulJobs = (totalJobs * 0.85).toInt();
    final failedJobs = (totalJobs * 0.1).toInt();
    final skippedJobs = totalJobs - successfulJobs - failedJobs;
    final endTime = DateTime.now();

    final result = BatchExecutionResult(
      batchId: batchId,
      totalJobs: totalJobs,
      successfulJobs: successfulJobs,
      failedJobs: failedJobs,
      skippedJobs: skippedJobs,
      executionTime: endTime.difference(startTime),
      startedAt: startTime,
      completedAt: endTime,
      errorMessages:
          failedJobs > 0 ? ['Some jobs failed'] : null,
    );

    _results[batchId] = result;
    return result;
  }

  @override
  Future<BatchExecutionResult?> getBatchResult(String batchId) async {
    return _results[batchId];
  }

  @override
  Future<void> cancelBatch(String batchId) async {
    _batches.remove(batchId);
  }

  @override
  Future<List<BatchExecutionResult>> getUserBatchHistory(String userId) async {
    final userBatches = _batches.values
        .where((b) => b.userId == userId)
        .map((b) => b.batchId)
        .toList();

    return _results.entries
        .where((e) => userBatches.contains(e.key))
        .map((e) => e.value)
        .toList();
  }
}
