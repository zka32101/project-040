/// Phase 23: 通知・履歴管理プロバイダー
/// FCM とローカル通知、ジョブ履歴を管理

import 'package:riverpod/riverpod.dart';
import '../models/async_job_model.dart';
import '../models/job_history_model.dart';
import '../services/fcm_notification_service.dart';

/// 通知状態
class NotificationState {
  /// ローカル通知リスト
  final List<LocalNotification> notifications;

  /// 未読カウント
  final int unreadCount;

  /// 最後に更新された時刻
  final DateTime? lastUpdatedAt;

  /// エラーメッセージ
  final String? errorMessage;

  /// ローディング状態
  final bool isLoading;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.lastUpdatedAt,
    this.errorMessage,
    this.isLoading = false,
  });

  /// コピー
  NotificationState copyWith({
    List<LocalNotification>? notifications,
    int? unreadCount,
    DateTime? lastUpdatedAt,
    String? errorMessage,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// ジョブ履歴状態
class JobHistoryState {
  /// 履歴エントリリスト
  final List<JobHistoryEntry> entries;

  /// 全エントリ数
  final int totalCount;

  /// 現在のフィルター
  final JobHistoryFilter filter;

  /// ローディング状態
  final bool isLoading;

  /// エラーメッセージ
  final String? errorMessage;

  /// 最後に更新された時刻
  final DateTime? lastUpdatedAt;

  const JobHistoryState({
    this.entries = const [],
    this.totalCount = 0,
    this.filter = const JobHistoryFilter(),
    this.isLoading = false,
    this.errorMessage,
    this.lastUpdatedAt,
  });

  /// コピー
  JobHistoryState copyWith({
    List<JobHistoryEntry>? entries,
    int? totalCount,
    JobHistoryFilter? filter,
    bool? isLoading,
    String? errorMessage,
    DateTime? lastUpdatedAt,
  }) {
    return JobHistoryState(
      entries: entries ?? this.entries,
      totalCount: totalCount ?? this.totalCount,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}

/// 通知 StateNotifier
class NotificationNotifier extends StateNotifier<NotificationState> {
  /// ローカル通知サービス
  final LocalNotificationService localNotificationService;

  NotificationNotifier(this.localNotificationService) : super(const NotificationState());

  /// 通知を取得
  Future<void> fetchNotifications() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final notifications = await localNotificationService.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        isLoading: false,
        lastUpdatedAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 通知を既読
  Future<void> markAsRead(int notificationId) async {
    try {
      await localNotificationService.markAsRead(notificationId);
      await fetchNotifications();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// すべてを既読
  Future<void> markAllAsRead() async {
    try {
      await localNotificationService.markAllAsRead();
      await fetchNotifications();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// 通知をキャンセル
  Future<void> cancelNotification(int notificationId) async {
    try {
      await localNotificationService.cancelNotification(notificationId);
      await fetchNotifications();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// すべてをキャンセル
  Future<void> cancelAllNotifications() async {
    try {
      await localNotificationService.cancelAllNotifications();
      state = state.copyWith(
        notifications: [],
        unreadCount: 0,
        lastUpdatedAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// 通知を追加
  Future<void> addNotification(LocalNotification notification) async {
    try {
      await localNotificationService.showNotification(notification);
      await fetchNotifications();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

/// ジョブ履歴 StateNotifier
class JobHistoryNotifier extends StateNotifier<JobHistoryState> {
  /// ジョブ履歴リスト（メモリ内）
  static final List<JobHistoryEntry> _historyEntries = [];

  JobHistoryNotifier() : super(const JobHistoryState());

  /// 履歴エントリを追加
  void addEntry(JobHistoryEntry entry) {
    _historyEntries.add(entry);
    _refreshState();
  }

  /// ジョブの履歴を取得
  Future<void> loadHistory(JobHistoryFilter filter) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, filter: filter);

      // フィルター適用
      final filtered = _historyEntries.where((e) => filter.matches(e)).toList();

      // ソート
      if (filter.sortOrder == 'asc') {
        filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      } else {
        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }

      // ページング
      final start = filter.offset;
      final end = (start + filter.limit).clamp(0, filtered.length);
      final paginated = filtered.sublist(start, end);

      state = state.copyWith(
        entries: paginated,
        totalCount: filtered.length,
        isLoading: false,
        lastUpdatedAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// フィルター更新
  Future<void> updateFilter(JobHistoryFilter newFilter) async {
    await loadHistory(newFilter);
  }

  /// 状態を更新
  void _refreshState() {
    state = state.copyWith(
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// ジョブ ID でフィルター
  Future<void> filterByJobId(String jobId) async {
    final filter = state.filter.copyWith(jobId: jobId);
    await loadHistory(filter);
  }

  /// イベントタイプでフィルター
  Future<void> filterByEventTypes(List<JobHistoryEventType> types) async {
    final filter = state.filter.copyWith(eventTypes: types);
    await loadHistory(filter);
  }

  /// 日付範囲でフィルター
  Future<void> filterByDateRange(DateTime startDate, DateTime endDate) async {
    final filter = state.filter.copyWith(
      startDate: startDate,
      endDate: endDate,
    );
    await loadHistory(filter);
  }

  /// テスト用：すべての履歴をクリア
  void clearHistory() {
    _historyEntries.clear();
    state = const JobHistoryState();
  }
}

/// 高度なジョブフィルター状態
class AdvancedFilterState {
  /// 現在のフィルター
  final AdvancedJobFilter filter;

  /// フィルター済みジョブリスト
  final List<AsyncJob> filteredJobs;

  /// 全ジョブ数
  final int totalCount;

  /// ローディング状態
  final bool isLoading;

  const AdvancedFilterState({
    this.filter = const AdvancedJobFilter(),
    this.filteredJobs = const [],
    this.totalCount = 0,
    this.isLoading = false,
  });

  /// コピー
  AdvancedFilterState copyWith({
    AdvancedJobFilter? filter,
    List<AsyncJob>? filteredJobs,
    int? totalCount,
    bool? isLoading,
  }) {
    return AdvancedFilterState(
      filter: filter ?? this.filter,
      filteredJobs: filteredJobs ?? this.filteredJobs,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 高度なジョブフィルター StateNotifier
class AdvancedFilterNotifier extends StateNotifier<AdvancedFilterState> {
  /// すべてのジョブ
  final List<AsyncJob> _allJobs;

  AdvancedFilterNotifier(this._allJobs) : super(const AdvancedFilterState());

  /// フィルターを適用
  void applyFilter(AdvancedJobFilter filter) {
    state = state.copyWith(isLoading: true, filter: filter);

    try {
      // フィルター適用
      final filtered = _allJobs.where((job) => filter.matches(job)).toList();

      // ソート
      _sortJobs(filtered, filter);

      state = state.copyWith(
        filteredJobs: filtered,
        totalCount: filtered.length,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// ジョブをソート
  void _sortJobs(List<AsyncJob> jobs, AdvancedJobFilter filter) {
    jobs.sort((a, b) {
      int comparison = 0;
      switch (filter.sortBy) {
        case JobSortField.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case JobSortField.startedAt:
          comparison = (a.startedAt ?? DateTime.now()).compareTo(b.startedAt ?? DateTime.now());
          break;
        case JobSortField.completedAt:
          comparison = (a.completedAt ?? DateTime.now()).compareTo(b.completedAt ?? DateTime.now());
          break;
        case JobSortField.progressPercent:
          comparison = a.progressPercent.compareTo(b.progressPercent);
          break;
        case JobSortField.retryCount:
          comparison = a.retryCount.compareTo(b.retryCount);
          break;
        case JobSortField.status:
          comparison = a.status.index.compareTo(b.status.index);
          break;
      }
      return filter.sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
  }

  /// 検索テキストで更新
  void updateSearchText(String text) {
    final newFilter = state.filter.copyWith(searchText: text.isEmpty ? null : text);
    applyFilter(newFilter);
  }

  /// ジョブタイプでフィルター
  void filterByJobTypes(List<AsyncJobType> types) {
    final newFilter = state.filter.copyWith(jobTypes: types);
    applyFilter(newFilter);
  }

  /// ステータスでフィルター
  void filterByStatuses(List<AsyncJobStatus> statuses) {
    final newFilter = state.filter.copyWith(statuses: statuses);
    applyFilter(newFilter);
  }

  /// 日付範囲でフィルター
  void filterByDateRange(DateTime? fromDate, DateTime? toDate) {
    final newFilter = state.filter.copyWith(
      createdFromDate: fromDate,
      createdToDate: toDate,
    );
    applyFilter(newFilter);
  }

  /// エラーのみを表示
  void showErrorsOnly(bool value) {
    final newFilter = state.filter.copyWith(errorsOnly: value);
    applyFilter(newFilter);
  }

  /// フィルターをリセット
  void resetFilter() {
    applyFilter(const AdvancedJobFilter());
  }
}

// プロバイダーの定義

/// ローカル通知サービスプロバイダー
final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  return StubLocalNotificationService();
});

/// 通知プロバイダー
final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final service = ref.watch(localNotificationServiceProvider);
  return NotificationNotifier(service);
});

/// ジョブ履歴プロバイダー
final jobHistoryProvider = StateNotifierProvider<JobHistoryNotifier, JobHistoryState>((ref) {
  return JobHistoryNotifier();
});

/// 高度なフィルタープロバイダー
final advancedFilterProvider = StateNotifierProvider<AdvancedFilterNotifier, AdvancedFilterState>((ref) {
  // 実際の実装ではジョブリストを受け取ります
  return AdvancedFilterNotifier([]);
});

/// FCM トークンプロバイダー
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  // 実装では FCM サービスから取得
  return 'stub_token_${DateTime.now().millisecondsSinceEpoch}';
});

/// 未読通知カウントプロバイダー
final unreadNotificationCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationProvider);
  return state.unreadCount;
});

/// 履歴統計プロバイダー
final historyStatisticsProvider = Provider<HistoryStatistics>((ref) {
  final state = ref.watch(jobHistoryProvider);
  return HistoryStatistics.fromEntries(state.entries);
});

/// 履歴統計
class HistoryStatistics {
  /// イベントタイプ別カウント
  final Map<JobHistoryEventType, int> eventTypeCounts;

  /// 最初のイベント
  final JobHistoryEntry? firstEvent;

  /// 最後のイベント
  final JobHistoryEntry? lastEvent;

  /// 合計イベント数
  final int totalEvents;

  const HistoryStatistics({
    required this.eventTypeCounts,
    required this.firstEvent,
    required this.lastEvent,
    required this.totalEvents,
  });

  /// エントリからインスタンスを作成
  factory HistoryStatistics.fromEntries(List<JobHistoryEntry> entries) {
    final eventTypeCounts = <JobHistoryEventType, int>{};
    for (final entry in entries) {
      eventTypeCounts[entry.eventType] = (eventTypeCounts[entry.eventType] ?? 0) + 1;
    }

    return HistoryStatistics(
      eventTypeCounts: eventTypeCounts,
      firstEvent: entries.isNotEmpty ? entries.last : null,
      lastEvent: entries.isNotEmpty ? entries.first : null,
      totalEvents: entries.length,
    );
  }
}
