/// Phase 21: ジョブ監視 Riverpod プロバイダ
/// ジョブの進捗状態を管理し、UI に状態を提供

import 'package:riverpod/riverpod.dart';
import '../models/async_job_model.dart';
import '../models/job_monitoring_model.dart';
import '../services/cloud_functions_service.dart';

/// Cloud Functions サービスのプロバイダ
final cloudFunctionsServiceProvider = Provider<CloudFunctionsService>((ref) {
  // 本番環境では FirebaseCloudFunctionsService を使用
  // テスト環境では StubCloudFunctionsService を使用
  return FirebaseCloudFunctionsService();
});

/// バックグラウンドジョブサービスのプロバイダ
final backgroundJobServiceProvider = Provider<BackgroundJobService>((ref) {
  final service = ref.watch(cloudFunctionsServiceProvider);
  return BackgroundJobService(service);
});

/// ユーザー ID のプロバイダ（実装時に実際のユーザー ID に置き換える）
final currentUserIdProvider = Provider<String>((ref) {
  return 'test-user-123'; // テスト用のデフォルト値
});

/// ジョブ監視ダッシュボード状態のプロバイダ
class JobMonitoringNotifier extends StateNotifier<JobMonitoringState> {
  final CloudFunctionsService _functionsService;
  final String _userId;

  JobMonitoringNotifier(this._functionsService, this._userId)
      : super(
          JobMonitoringState(
            activeJobs: [],
            completedJobs: [],
            failedJobs: [],
          ),
        );

  /// ジョブ一覧を更新
  Future<void> refreshJobs() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // ユーザーのジョブ一覧を取得
      final jobs = await _functionsService.getUserJobs(_userId, limit: 50);

      // ステータスごとにジョブを分類
      final activeJobs = <AsyncJob>[];
      final completedJobs = <AsyncJob>[];
      final failedJobs = <AsyncJob>[];

      for (final job in jobs) {
        if (job.status == AsyncJobStatus.queued || job.status == AsyncJobStatus.processing) {
          activeJobs.add(job);
        } else if (job.status == AsyncJobStatus.completed) {
          completedJobs.add(job);
        } else if (job.status == AsyncJobStatus.failed) {
          failedJobs.add(job);
        }
      }

      state = state.copyWith(
        activeJobs: activeJobs,
        completedJobs: completedJobs,
        failedJobs: failedJobs,
        isLoading: false,
        lastUpdatedAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'ジョブ一覧の取得に失敗しました: $e',
      );
    }
  }

  /// 特定のジョブのステータスを更新
  Future<void> updateJobStatus(String jobId) async {
    try {
      final job = await _functionsService.getJobStatus(jobId);

      // アクティブジョブから検索して更新
      final activeJobIndex = state.activeJobs.indexWhere((j) => j.jobId == jobId);
      if (activeJobIndex != -1) {
        final updatedActiveJobs = List<AsyncJob>.from(state.activeJobs);
        updatedActiveJobs[activeJobIndex] = job;

        // ステータスが changed したら移動
        if (job.status != AsyncJobStatus.processing && job.status != AsyncJobStatus.queued) {
          updatedActiveJobs.removeAt(activeJobIndex);

          if (job.status == AsyncJobStatus.completed) {
            final updatedCompletedJobs = List<AsyncJob>.from(state.completedJobs);
            updatedCompletedJobs.add(job);
            state = state.copyWith(
              activeJobs: updatedActiveJobs,
              completedJobs: updatedCompletedJobs,
            );
          } else if (job.status == AsyncJobStatus.failed) {
            final updatedFailedJobs = List<AsyncJob>.from(state.failedJobs);
            updatedFailedJobs.add(job);
            state = state.copyWith(
              activeJobs: updatedActiveJobs,
              failedJobs: updatedFailedJobs,
            );
          }
        } else {
          state = state.copyWith(activeJobs: updatedActiveJobs);
        }
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'ジョブステータスの更新に失敗しました: $e',
      );
    }
  }

  /// ジョブを選択
  void selectJob(String jobId) {
    state = state.copyWith(selectedJobId: jobId);
  }

  /// ジョブの選択を解除
  void deselectJob() {
    state = state.copyWith(selectedJobId: null);
  }

  /// ジョブをキャンセル
  Future<void> cancelJob(String jobId) async {
    try {
      await _functionsService.cancelJob(jobId);

      // ローカル状態を更新
      final activeJobIndex = state.activeJobs.indexWhere((j) => j.jobId == jobId);
      if (activeJobIndex != -1) {
        final updatedActiveJobs = List<AsyncJob>.from(state.activeJobs);
        final job = updatedActiveJobs[activeJobIndex];
        job.status = AsyncJobStatus.cancelled;

        updatedActiveJobs.removeAt(activeJobIndex);
        state = state.copyWith(activeJobs: updatedActiveJobs);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'ジョブのキャンセルに失敗しました: $e',
      );
    }
  }

  /// フィルタモードを変更
  void setFilterMode(JobFilterMode mode) {
    state = state.copyWith(filterMode: mode);
  }

  /// 定期的にジョブ情報を更新（ポーリング）
  Future<void> startPolling({Duration interval = const Duration(seconds: 2)}) async {
    while (true) {
      await refreshJobs();
      await Future.delayed(interval);
    }
  }
}

/// ジョブ監視ダッシュボード状態のプロバイダ
final jobMonitoringProvider =
    StateNotifierProvider<JobMonitoringNotifier, JobMonitoringState>((ref) {
  final service = ref.watch(cloudFunctionsServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return JobMonitoringNotifier(service, userId);
});

/// フィルタ済みジョブリストのプロバイダ
final filteredJobsProvider = Provider<List<AsyncJob>>((ref) {
  final state = ref.watch(jobMonitoringProvider);

  switch (state.filterMode) {
    case JobFilterMode.all:
      return [...state.activeJobs, ...state.completedJobs, ...state.failedJobs];
    case JobFilterMode.active:
      return state.activeJobs;
    case JobFilterMode.completed:
      return state.completedJobs;
    case JobFilterMode.failed:
      return state.failedJobs;
  }
});

/// 選択されたジョブの詳細情報プロバイダ
final selectedJobDetailsProvider = Provider<JobMonitoringDetails?>((ref) {
  final state = ref.watch(jobMonitoringProvider);
  final selectedJob = state.getSelectedJob();

  if (selectedJob == null) return null;

  final elapsedTime = selectedJob.completedAt != null
      ? selectedJob.completedAt!.difference(selectedJob.createdAt)
      : DateTime.now().difference(selectedJob.createdAt);

  return JobMonitoringDetails(
    jobId: selectedJob.jobId,
    jobType: selectedJob.jobType,
    status: selectedJob.status,
    progressPercent: selectedJob.progressPercent,
    elapsedTime: elapsedTime,
    lastUpdatedAt: selectedJob.completedAt ?? DateTime.now(),
    errorMessage: selectedJob.errorMessage,
  );
});

/// ジョブ通知イベントの履歴プロバイダ
final jobNotificationHistoryProvider = StateProvider<List<JobNotificationEvent>>((ref) {
  return [];
});

/// 通知イベントを記録
final addNotificationEventProvider = Provider<void Function(JobNotificationEvent)>((ref) {
  return (event) {
    ref.read(jobNotificationHistoryProvider.notifier).update((list) {
      return [event, ...list].take(100).toList(); // 最新100件を保持
    });
  };
});

/// ジョブ進捗ストリームのプロバイダ
final jobProgressStreamProvider = StreamProvider.family<AsyncJob, String>((ref, jobId) async* {
  final service = ref.watch(cloudFunctionsServiceProvider);

  yield* service.watchJobProgress(jobId);
});

/// 複数ジョブの進捗を監視するプロバイダ
final allJobsProgressProvider = StreamProvider<List<AsyncJob>>((ref) async* {
  final state = ref.watch(jobMonitoringProvider);
  final service = ref.watch(cloudFunctionsServiceProvider);

  if (state.activeJobs.isEmpty) {
    yield [];
    return;
  }

  // 最初の1つのジョブの進捗を監視
  if (state.activeJobs.isNotEmpty) {
    yield* service.watchJobProgress(state.activeJobs.first.jobId).map((_) async* {
      // 定期的にすべてのジョブを更新
      await ref.read(jobMonitoringProvider.notifier).refreshJobs();
      yield state.activeJobs;
    }).expand((i) => i);
  }
});

/// ジョブ統計情報のプロバイダ
final jobStatisticsProvider = Provider<JobStatistics>((ref) {
  final state = ref.watch(jobMonitoringProvider);

  final totalJobs = state.totalJobCount;
  final activeCount = state.activeJobs.length;
  final completedCount = state.completedJobs.length;
  final failedCount = state.failedJobs.length;
  final successRate = totalJobs == 0 ? 0.0 : (completedCount / totalJobs) * 100;
  final averageProgress = state.averageProgress;

  return JobStatistics(
    totalJobs: totalJobs,
    activeJobs: activeCount,
    completedJobs: completedCount,
    failedJobs: failedCount,
    successRate: successRate,
    averageProgress: averageProgress,
  );
});

/// ジョブ統計情報
class JobStatistics {
  final int totalJobs;
  final int activeJobs;
  final int completedJobs;
  final int failedJobs;
  final double successRate;
  final double averageProgress;

  JobStatistics({
    required this.totalJobs,
    required this.activeJobs,
    required this.completedJobs,
    required this.failedJobs,
    required this.successRate,
    required this.averageProgress,
  });
}
