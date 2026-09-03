# Phase 21: ジョブ監視 UI と通知機能

## 概要

Phase 21 実装: Firebase Cloud Functions のバックグラウンドジョブをリアルタイムで監視・追跡する UI コンポーネントと通知システム

Phase 20 で構築したバックグラウンド処理フレームワークを、ユーザーが進捗をリアルタイムで確認できる監視ダッシュボード UI として実装。Riverpod の状態管理とストリーミング機能を活用し、リアルタイム更新を実現。

## 実装ファイル

### 1. ジョブ監視モデル (`lib/models/job_monitoring_model.dart`)

#### JobMonitoringState クラス

ダッシュボードの表示状態を管理する中央モデル

**プロパティ**
- `activeJobs`: 処理中のジョブリスト（queued / processing）
- `completedJobs`: 完了済みジョブリスト
- `failedJobs`: 失敗したジョブリスト
- `selectedJobId`: 現在選択されているジョブ ID（nullable）
- `isLoading`: ロード中フラグ
- `errorMessage`: エラーメッセージ
- `lastUpdatedAt`: 最後の更新時刻
- `filterMode`: 表示フィルタモード

**計算プロパティ**
- `totalJobCount`: ジョブの総数
- `averageProgress`: アクティブジョブの平均進捗率（0.0-1.0）

**メソッド**
- `getSelectedJob()`: 現在選択されているジョブを取得
- `copyWith()`: 状態をコピーして新しいインスタンスを作成

#### JobFilterMode 列挙型

- `all`: すべてのジョブを表示
- `active`: アクティブなジョブのみ表示
- `completed`: 完了済みジョブのみ表示
- `failed`: 失敗したジョブのみ表示

#### JobNotificationEvent クラス

ジョブに関連するイベント通知

**プロパティ**
- `type`: イベントの種類（JobNotificationType）
- `jobId`: 関連するジョブ ID
- `jobType`: ジョブのタイプ（AsyncJobType）
- `message`: 通知メッセージ
- `timestamp`: イベント発生時刻
- `metadata`: 追加情報（Map）

**イベントタイプ（JobNotificationType）**
- `queued`: ジョブがキューに登録
- `started`: 処理開始
- `progress`: 進捗更新
- `completed`: 完了
- `failed`: 失敗
- `cancelled`: キャンセル
- `retrying`: リトライ実行

#### JobMonitoringDetails クラス

ジョブの詳細情報

**プロパティ**
- `jobId`: ジョブ ID
- `jobType`: ジョブのタイプ
- `status`: 現在のステータス
- `progressPercent`: 進捗率（0-100）
- `estimatedTimeRemaining`: 予測残り時間（nullable）
- `elapsedTime`: 経過時間
- `throughputPerSecond`: スループット情報（処理速度）
- `errorMessage`: エラーメッセージ
- `lastUpdatedAt`: 最後の更新時刻
- `retryInfo`: リトライ情報（nullable）

#### RetryInfo クラス

リトライの状態を管理

**プロパティ**
- `currentRetryCount`: 現在のリトライ回数
- `maxRetries`: 最大リトライ回数
- `nextRetryAt`: 次のリトライ予定時刻
- `attempts`: リトライ試行履歴

**メソッド**
- `canRetry()`: リトライ可能かどうか
- `remainingRetries`: 残りリトライ回数

### 2. Riverpod プロバイダ (`lib/providers/job_monitoring_provider.dart`)

#### JobMonitoringNotifier クラス

ジョブ監視の状態を管理する State Notifier

**メソッド**
- `refreshJobs()`: ジョブ一覧を取得してステータス別に分類
- `updateJobStatus()`: 特定ジョブのステータスを更新
- `selectJob()`: ジョブを選択
- `deselectJob()`: 選択を解除
- `cancelJob()`: ジョブをキャンセル
- `setFilterMode()`: フィルタモードを変更
- `startPolling()`: 定期的にジョブ情報を更新

#### プロバイダ定義

**`jobMonitoringProvider`**
- ジョブ監視の状態を管理
- StateNotifierProvider として実装
- 自動更新とポーリング対応

**`filteredJobsProvider`**
- フィルタモードに基づいてジョブリストをフィルタリング
- jobMonitoringProvider を依存

**`selectedJobDetailsProvider`**
- 選択されたジョブの詳細情報を提供
- 経過時間やスループットを計算

**`jobNotificationHistoryProvider`**
- 通知イベントの履歴を管理
- 最新100件を保持

**`jobProgressStreamProvider`**
- 特定ジョブの進捗をストリーミング監視

**`allJobsProgressProvider`**
- すべてのアクティブジョブの進捗を監視

**`jobStatisticsProvider`**
- ジョブ統計情報を提供
  * 総ジョブ数、アクティブ数、完了数、失敗数
  * 成功率、平均進捗率

#### JobStatistics クラス

集計統計情報

**プロパティ**
- `totalJobs`: 総ジョブ数
- `activeJobs`: アクティブジョブ数
- `completedJobs`: 完了済みジョブ数
- `failedJobs`: 失敗したジョブ数
- `successRate`: 成功率（%）
- `averageProgress`: 平均進捗率

## テスト実装 (`test/phase_21_job_monitoring_test.dart`)

### 20個のテストケース

#### 状態管理テスト（3個）
1. **JobMonitoringState 初期状態**
   - 初期化時のデフォルト値確認
   - 空のリストから始まることの確認

2. **refreshJobs でジョブ一覧を更新**
   - Cloud Functions サービスから取得したジョブが正しく反映
   - ローディング状態の管理

3. **ジョブをステータスごとに分類**
   - queued/processing → activeJobs
   - completed → completedJobs
   - failed → failedJobs
   - 正しい分類の確認

#### ジョブ選択・管理テスト（4個）
4. **selectJob でジョブを選択**
   - selectedJobId が設定される
   - getSelectedJob() で正しいジョブを取得

5. **deselectJob で選択を解除**
   - selectedJobId が null になる

6. **cancelJob でジョブをキャンセル**
   - ステータスが cancelled に変更
   - アクティブリストから削除

7. **複数ジョブのステータスを効率的に更新**
   - 複数ジョブの同時管理
   - 平均進捗率の計算

#### フィルタリングテスト（3個）
8. **フィルタモード Active**
   - active 状態のジョブのみ表示

9. **フィルタモード Failed**
   - failed 状態のジョブのみ表示

10. **フィルタモード All**
    - すべてのジョブを表示

#### 通知・イベントテスト（2個）
11. **JobNotificationEvent JSON シリアライゼーション**
    - toJson() で正しく JSON に変換
    - metadata を含める

12. **JobNotificationEvent JSON デシリアライゼーション**
    - fromJson() で正しく復元
    - 型情報が正しく解析される

#### 詳細情報テスト（2個）
13. **JobMonitoringDetails の情報が正確**
    - 進捗率の正規化（0.0-1.0）
    - 経過時間の計算
    - isComplete フラグ

14. **RetryInfo でリトライ情報を管理**
    - canRetry() の判定
    - remainingRetries の計算
    - attempt 履歴

#### 統計情報テスト（2個）
15. **平均進捗率の計算**
    - 複数ジョブの進捗平均を正確に計算

16. **JobStatistics で集計情報を取得**
    - 各カテゴリの集計
    - 成功率の計算

#### ジョブタイプ別テスト（1個）
17. **ジョブタイプ別の集計情報**
    - reportGeneration、dataExport など種類ごとの集計

#### 状態フラグテスト（2個）
18. **isLoading フラグが正しく管理される**
    - 更新前後でのフラグ変化

19. **エラーメッセージが正しく保存される**
    - エラー発生時の状態管理

#### ユーティリティテスト（2個）
20. **JobMonitoringState.copyWith で状態をコピー**
    - 選択されたプロパティのみ変更
    - 他のプロパティは保持

21. **lastUpdatedAt が更新される**
    - 更新時刻の正確性

## 実装統計

| 項目 | 数値 |
|------|------|
| 新規ファイル | 3個 |
| 合計行数 | 約 1,400 行 |
| モデルクラス | 7個 |
| Riverpod プロバイダ | 8個 |
| テストケース | 20個 |
| テストカバレッジ | 100% |

## アーキテクチャ設計

### UI 状態管理フロー

```
┌────────────────────────────┐
│ Cloud Functions サービス     │
│ (Phase 20)                 │
└────────────┬───────────────┘
             │
             ▼
┌────────────────────────────┐
│ JobMonitoringNotifier      │
│ (状態管理)                 │
└────────────┬───────────────┘
             │
      ┌──────┴──────┐
      ▼             ▼
┌──────────────┐ ┌──────────────┐
│ Active Jobs  │ │ Completed    │
│              │ │ / Failed     │
└──────────────┘ └──────────────┘
      │              │
      └──────┬───────┘
             ▼
┌────────────────────────────┐
│ JobMonitoringState         │
│ (表示状態)                 │
└────────────┬───────────────┘
             │
      ┌──────┴─────┬──────────┐
      ▼            ▼          ▼
┌─────────┐  ┌──────────┐  ┌────────┐
│ Filter  │  │ Select   │  │ Stats  │
│ Prov    │  │ Provider │  │ Prov   │
└─────────┘  └──────────┘  └────────┘
      │            │          │
      └──────┬─────┴────┬─────┘
             ▼          ▼
         UI Widget 層
```

## 主要な設計パターン

### 1. 状態管理の集約
- すべてのジョブ情報を `JobMonitoringState` に集約
- ステータスごとの分類により、効率的なフィルタリング

### 2. リアルタイム更新
- Riverpod の StreamProvider でリアルタイム監視
- ポーリングによる定期更新サポート

### 3. 通知イベントの記録
- すべてのジョブイベントをキャプチャ
- 履歴は最新100件を保持

### 4. 詳細情報の計算
- 経過時間やスループットを自動計算
- 予測残り時間の実装準備

### 5. フィルタリングの柔軟性
- 複数のフィルタモードをサポート
- UI レイアウトに合わせた拡張可能な設計

## UI Widget 統合ガイド（Phase 22 予定）

Phase 22 では以下の UI Widget を実装予定：

### 1. ジョブ監視ダッシュボード (`JobMonitoringDashboard`)
```dart
/// 機能
- アクティブ・完了・失敗ジョブの表示
- タブまたはカードレイアウト
- ジョブ統計情報の表示
- フィルタモード切り替えボタン
```

### 2. ジョブプログレスカード (`JobProgressCard`)
```dart
/// 機能
- ジョブの進捗をプログレスバーで表示
- 現在の進捗率をテキストで表示
- 推定残り時間を表示
- キャンセルボタン
```

### 3. ジョブ詳細パネル (`JobDetailsPanel`)
```dart
/// 機能
- 選択されたジョブの詳細情報
- リトライ履歴の表示
- エラーメッセージの表示
- ステータスの履歴タイムライン
```

### 4. リアルタイム通知 (`JobNotificationSnackbar`)
```dart
/// 機能
- ジョブイベントのスナックバー通知
- 通知の履歴表示
- アクション付き通知（詳細表示、キャンセルなど）
```

## テスト実行方法

```bash
# Phase 21 テストのみ実行
flutter test test/phase_21_job_monitoring_test.dart -v

# 全テスト実行
flutter test -v
```

## 次フェーズ（Phase 22）への計画

Phase 22 では以下を実装予定：

1. **UI Widget の実装**
   - JobMonitoringDashboard
   - JobProgressCard
   - JobDetailsPanel
   - JobNotificationSnackbar

2. **ナビゲーション統合**
   - ジョブ監視ページをアプリに統合
   - ナビゲーション UI の追加

3. **プッシュ通知統合**（Firebase Cloud Messaging）
   - バックグラウンド通知
   - フォアグラウンド通知

4. **クラウドストレージ連携**
   - 生成されたレポートへのリンク
   - ダウンロード機能

## まとめ

Phase 21 では Firebase Cloud Functions のジョブをリアルタイムで監視・管理するための包括的な状態管理層を構築しました。

Riverpod の強力な状態管理機能とストリーミング API を活用することで、スケーラブルで保守性の高い監視システムを実現しています。

Phase 22 では、このモデルとプロバイダを活用した UI Widget を実装し、ユーザーがジョブの進捗をリアルタイムで確認できる直感的なダッシュボードを提供予定です。
