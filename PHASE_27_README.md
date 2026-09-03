# Phase 27: バックエンド統合・API・データベース・通知機能

Phase 27では、バックエンド統合を完成させるための3つの主要な機能セットを実装しました：

1. **API統合** - REST APIクライアント実装
2. **データベース・リポジトリパターン** - データアクセス層の抽象化
3. **通知・スケジュール機能** - リアルタイム通知とジョブスケジューリング

## 実装内容

### 1. API統合 (`lib/models/api_models.dart`, `lib/services/api_service.dart`)

#### APIモデル
- **認証**: `LoginRequest`, `LoginResponse`, `RefreshTokenRequest`
- **ジョブ操作**: `CreateJobRequest`, `JobListResponse`, `UpdateJobRequest`
- **分析**: `AnalyticsReportRequest`, `AnalyticsReportResponse`
- **検索**: `SearchRequest`, `SearchResponse`
- **エクスポート**: `ExportRequest`, `ExportResponse`
- **エラーハンドリング**: `ApiErrorResponse` (ステータスコードと詳細エラー情報)
- **ページング**: `PaginationInfo`

#### APIサービス実装

**ApiService インターフェース**:
```dart
abstract class ApiService {
  Future<LoginResponse> login(LoginRequest request);
  Future<LoginResponse> refreshToken(RefreshTokenRequest request);
  Future<AsyncJob> createJob(CreateJobRequest request);
  Future<AsyncJob> getJob(String jobId);
  Future<JobListResponse> listJobs({...});
  Future<AsyncJob> updateJob(UpdateJobRequest request);
  Future<void> deleteJob(String jobId);
  Future<AnalyticsReportResponse> getAnalyticsReport(...);
  Future<SearchResponse> search(SearchRequest request);
  Future<ExportResponse> export(ExportRequest request);
  Future<bool> healthCheck();
}
```

**MemoryApiService** - 開発/テスト用メモリ実装
- ユーザー認証情報をメモリに保存
- トークン生成とリフレッシュ機能
- ジョブのメモリ内管理
- 分析レポートの生成
- 検索とエクスポート機能

**HttpApiService** - HTTP実装スケルトン
- 構造と型シグネチャを定義
- 実装は`UnimplementedError`で予約（将来実装予定）

### 2. データベース・リポジトリパターン (`lib/services/database_service.dart`)

#### リポジトリインターフェース

**JobRepository**:
```dart
abstract class JobRepository {
  Future<void> insert(AsyncJob job);
  Future<AsyncJob?> getById(String jobId);
  Future<List<AsyncJob>> getUserJobs(String userId);
  Future<void> update(AsyncJob job);
  Future<void> delete(String jobId);
  Future<List<AsyncJob>> getAll();
  Future<List<AsyncJob>> query({
    String? userId,
    AsyncJobStatus? status,
    AsyncJobType? jobType,
    DateTime? createdAfter,
  });
}
```

**AnalyticsRepository**:
- 実行時間分析の保存/取得
- 成功率統計の保存
- パフォーマンスメトリクスの保存
- 分析レポートの管理
- 日付範囲別レポート取得

**SearchRepository**:
- 検索クエリの保存
- 検索履歴エントリの管理
- ユーザー別検索履歴取得

**ExportRepository**:
- エクスポート結果の保存/更新
- ユーザー別エクスポート履歴の取得

#### データベースサービス
```dart
class DatabaseService {
  late JobRepository jobRepository;
  late AnalyticsRepository analyticsRepository;
  late SearchRepository searchRepository;
  late ExportRepository exportRepository;
}
```

リポジトリのファサードとして機能し、すべてのデータアクセス操作を一元管理します。

#### JobQueryBuilder - 型安全なクエリビルダー

```dart
final results = await databaseService.jobRepository.query(
  userId: 'user_1',
  status: AsyncJobStatus.completed,
);

// またはクエリビルダー使用:
final builder = JobQueryBuilder()
  .withUserId('user_1')
  .withStatus(AsyncJobStatus.completed)
  .withLimit(20)
  .orderBy('createdAt', descending: true);

final query = builder.build();
```

### 3. 通知サービス (`lib/services/notification_service.dart`)

#### 通知モデル

**Notification**:
```dart
class Notification {
  final String notificationId;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final NotificationPriority priority; // low, normal, high, urgent
  final List<NotificationChannel> channels; // push, email, webhook, inApp
  final DateTime createdAt;
  final DateTime? sentAt;
  final Map<String, dynamic>? metadata;
  final bool read;
}
```

**NotificationPreferences**:
```dart
class NotificationPreferences {
  final String userId;
  final bool enablePushNotifications;
  final bool enableEmailNotifications;
  final bool enableWebhooks;
  final List<NotificationType> preferredTypes;
  final Map<NotificationChannel, bool> channelPreferences;
}
```

#### 通知サービスインターフェース

**NotificationService**:
- 通知送信
- ジョブ完了/失敗通知
- ユーザーの通知取得と既読管理
- 通知設定の管理

**PushNotificationService**:
- デバイストークンの登録/管理
- プッシュ通知送信
- トピック購読機能

**EmailNotificationService**:
- メール送信
- テンプレートメール送信
- 一括メール送信

**WebhookService**:
- Webhook登録/削除
- イベント送信

#### 使用例

```dart
// 通知を送信
final notification = Notification(
  notificationId: 'notif_1',
  userId: 'user_1',
  type: NotificationType.jobCompleted,
  title: 'ジョブ完了',
  message: 'ジョブが完了しました',
  priority: NotificationPriority.normal,
  channels: [NotificationChannel.push, NotificationChannel.email],
  createdAt: DateTime.now(),
);
await notificationService.sendNotification(notification);

// ジョブ完了通知（便利メソッド）
await notificationService.notifyJobCompleted(job);

// 通知設定を更新
final prefs = NotificationPreferences(
  userId: 'user_1',
  enablePushNotifications: true,
  enableEmailNotifications: false,
  updatedAt: DateTime.now(),
);
await notificationService.updatePreferences(prefs);
```

### 4. スケジュール・バッチ処理 (`lib/services/scheduling_service.dart`)

#### スケジュール設定

**ScheduleConfig**:
```dart
class ScheduleConfig {
  final String scheduleId;
  final String userId;
  final AsyncJobType jobType;
  final String jobName;
  final ScheduleFrequency frequency; // once, hourly, daily, weekly, monthly
  final DateTime? startTime;
  final DateTime? endTime;
  final String? cronExpression;
  final Map<String, dynamic>? parameters;
  final bool retryOnFailure;
  final int maxRetries;
  final DateTime createdAt;
  final DateTime? lastRunAt;
  final DateTime? nextRunAt;
  final ScheduleStatus status; // active, paused, completed, cancelled, failed
}
```

#### スケジュール管理サービス

```dart
abstract class SchedulingService {
  Future<ScheduleConfig> createSchedule(ScheduleConfig config);
  Future<ScheduleConfig?> getSchedule(String scheduleId);
  Future<List<ScheduleConfig>> getUserSchedules(String userId);
  Future<void> updateSchedule(ScheduleConfig config);
  Future<void> deleteSchedule(String scheduleId);
  Future<void> enableSchedule(String scheduleId);
  Future<void> disableSchedule(String scheduleId);
  Future<AsyncJob> executeSchedule(String scheduleId);
  DateTime calculateNextRunTime(ScheduleConfig config);
}
```

#### バッチ処理

**BatchJobConfig**:
```dart
class BatchJobConfig {
  final String batchId;
  final String userId;
  final List<AsyncJobType> jobTypes;
  final int batchSize;
  final int maxConcurrent;
  final bool continueOnError;
  final Duration? timeout;
}
```

**BatchExecutionResult**:
```dart
class BatchExecutionResult {
  final String batchId;
  final int totalJobs;
  final int successfulJobs;
  final int failedJobs;
  final int skippedJobs;
  final Duration executionTime;
  final DateTime startedAt;
  final DateTime completedAt;
  final double successRate; // 計算プロパティ
}
```

#### 使用例

```dart
// スケジュール作成
final schedule = ScheduleConfig(
  scheduleId: 'schedule_1',
  userId: 'user_1',
  jobType: AsyncJobType.reportGeneration,
  jobName: '日次レポート生成',
  frequency: ScheduleFrequency.daily,
  createdAt: DateTime.now(),
);
await schedulingService.createSchedule(schedule);

// スケジュール実行
final job = await schedulingService.executeSchedule('schedule_1');

// バッチ処理実行
final batch = BatchJobConfig(
  batchId: 'batch_1',
  userId: 'user_1',
  jobTypes: [AsyncJobType.reportGeneration],
  batchSize: 100,
  maxConcurrent: 5,
  createdAt: DateTime.now(),
);
await batchService.createBatch(batch);
final result = await batchService.executeBatch('batch_1');

print('成功率: ${(result.successRate * 100).toStringAsFixed(2)}%');
```

## テスト カバレッジ

`test/phase_27_backend_integration_test.dart` - 30個のテストケース

### API サービス（13テスト）
1. ログイン - 有効な認証情報
2. ログイン - 無効な認証情報
3. トークンをリフレッシュ
4. ジョブを作成
5. ジョブを取得
6. ジョブを取得 - 存在しないジョブ
7. ジョブリストを取得
8. ジョブを更新
9. ジョブを削除
10. 分析レポートを取得
11. 検索を実行
12. エクスポートを実行
13. ヘルスチェック

### データベース（6テスト）
14. ジョブをデータベースに挿入
15. ジョブを更新
16. ジョブを削除
17. ユーザーのジョブを取得
18. ジョブクエリビルダー

### 通知サービス（5テスト）
19. 通知を送信
20. ジョブ完了通知を送信
21. ジョブ失敗通知を送信
22. 通知を既読にマーク
23. 通知設定を更新

### スケジュール・バッチ処理（6テスト）
24. スケジュールを作成
25. スケジュールを取得
26. スケジュールを実行
27. 次の実行時刻を計算
28. バッチジョブを作成
29. バッチジョブを実行
30. バッチ実行結果を取得

## アーキテクチャパターン

### リポジトリパターン
- インターフェースで契約を定義
- メモリ実装で開発・テストを効率化
- HTTP実装でスケルトン提供（将来実装予定）
- 依存性の注入により実装の切り替え可能

### ファサードパターン
- `DatabaseService` がすべてのリポジトリを管理
- クライアントは単一のエントリーポイント経由でアクセス
- 内部構造の複雑さを隠蔽

### クエリビルダーパターン
- `JobQueryBuilder` で型安全なクエリ構築
- メソッドチェーン（Fluent API）で読みやすいコード
- フィルタリング・ソート・ペーストを一元管理

### 通知チャネルの分離
- 異なる通知手段を独立したサービスで実装
- チャネル選択を通知モデルで柔軟に設定
- 複数チャネルの同時利用に対応

## 統合例

### 完全なジョブ作成・実行・通知フロー

```dart
// 1. APIでジョブを作成
final createRequest = CreateJobRequest(
  userId: 'user_1',
  jobType: AsyncJobType.reportGeneration,
  parameters: {'templateId': 'template_1'},
);
final job = await apiService.createJob(createRequest);

// 2. データベースに保存
await databaseService.jobRepository.insert(job);

// 3. 実行スケジュール設定
final schedule = ScheduleConfig(
  scheduleId: 'schedule_${job.jobId}',
  userId: job.userId,
  jobType: job.jobType,
  jobName: 'ジョブ ${job.jobId}',
  frequency: ScheduleFrequency.once,
  startTime: DateTime.now().add(Duration(minutes: 5)),
  createdAt: DateTime.now(),
);
await schedulingService.createSchedule(schedule);

// 4. スケジュール実行時にジョブを実行
final executedJob = await schedulingService.executeSchedule(schedule.scheduleId);

// 5. 実行完了時に通知を送信
if (executedJob.status == AsyncJobStatus.completed) {
  await notificationService.notifyJobCompleted(executedJob);
}
```

### バッチ分析レポート生成

```dart
// 複数のレポート生成をバッチ処理
final batchConfig = BatchJobConfig(
  batchId: 'batch_daily_reports',
  userId: 'admin',
  jobTypes: [AsyncJobType.reportGeneration],
  batchSize: 200,
  maxConcurrent: 10,
  createdAt: DateTime.now(),
);
await batchService.createBatch(batchConfig);

// バッチ実行
final result = await batchService.executeBatch('batch_daily_reports');

// 結果を分析レポートとして保存
final report = AnalyticsReport(
  reportId: 'report_${DateTime.now().millisecondsSinceEpoch}',
  reportType: ReportType.batchExecution,
  successRateStats: SuccessRateStatistics(
    totalJobs: result.totalJobs,
    successJobs: result.successfulJobs,
    failedJobs: result.failedJobs,
    cancelledJobs: result.skippedJobs,
    avgExecutionTimeMs: result.executionTime.inMilliseconds / result.totalJobs,
    maxExecutionTimeMs: result.executionTime.inMilliseconds,
    minExecutionTimeMs: 0,
    period: DateRange(
      startDate: result.startedAt,
      endDate: result.completedAt,
    ),
  ),
  generatedAt: DateTime.now(),
  period: DateRange(
    startDate: result.startedAt,
    endDate: result.completedAt,
  ),
);
await databaseService.analyticsRepository.saveReport(report);

// 管理者に通知を送信
await notificationService.sendNotification(Notification(
  notificationId: 'notif_batch_complete',
  userId: 'admin',
  type: NotificationType.reportGenerated,
  title: 'バッチ処理完了',
  message: '${result.successfulJobs}/${result.totalJobs} ジョブが正常に完了しました',
  priority: NotificationPriority.normal,
  channels: [NotificationChannel.email],
  createdAt: DateTime.now(),
));
```

## 今後の拡張ポイント

1. **HTTP実装** - `HttpApiService` の実装化（HTTP パッケージ使用）
2. **データベース実装** - SQLite/Firebaseリポジトリの実装
3. **認証** - JWT トークン検証、リフレッシュトークンローテーション
4. **レート制限** - API呼び出しの制限機能
5. **キャッシング** - 応答キャッシング機能
6. **ロギング・監視** - 詳細なログとメトリクス収集
7. **エラーハンドリング** - より詳細なエラーコードと回復戦略
8. **トランザクション** - データベーストランザクション処理

## 終了

Phase 27でバックエンド統合の基本実装が完成しました。メモリベースの実装により、追加のバックエンドなしでテストと開発が可能です。
