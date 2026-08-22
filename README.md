# 原付・バイク免許コレ！

二輪免許（原付〜大型二輪）特化の学科試験対策アプリ（Flutter/Dart）。

準拠ドキュメント：
- 企画設計書 v1.1（Vision/Mission・OKR・機能リスト・グロース設計・批判的レビュー）
- Code 実装引き継ぎ書 v1.1（スタック・ディレクトリ構成・実装順序）

## コンセプト

既存の学科試験問題集アプリは普通車問題の使い回しが大半で、**普通二輪・大型二輪・AT限定**
特化のアプリは市場にほぼ存在しない（白地市場）。一方、**原付単体**は業界団体・メーカーの
無料公式アプリ（ゲンチャレ／ゲンツキ免許チャレンジ）が強く価格競争できないため、原付は
名前上の入口機能に留め、コンテンツ投入・ASO投資は普通二輪・大型二輪側に優先配分する方針。

## 差別化の4本柱（Must機能）

1. 免許区分選択＋出題フィルタ（区分ごとに問題を絞り込み）
2. 合格予測メーター＋試験日逆算ノルマ
3. 教習所段階別モード
4. 憧れバイク解放（原付→125→250→400→大型二輪）
5. ひっかけ道場（二輪特有の間違えやすい数字を対戦形式で反復、誤答は自動ボス化）

## 技術スタック

Flutter/Dart 3.x + Riverpod + Firebase (Firestore/Auth/Analytics/Crashlytics/Remote Config/
Cloud Functions) + RevenueCat + Lottie。MVVM。

## 現在の実装状況（このコミット時点）

このリポジトリには **Flutter SDK が未セットアップの環境で作成されたコード一式**が入っています。
`flutter pub get` / `flutter analyze` / `flutter test` はまだ実行できていません。
取得後、必ずローカル環境で以下を実行して検証してください。

```bash
flutter pub get
flutter analyze
flutter test
```

### 動作する部分

- Aha Moment最短動線：オンボーディング→免許区分選択→教習段階/試験日(任意)→ホーム
  →今日のノルマ→3問正解で合格予測メーター初表示、までを **Firebase未接続でも**
  端末ローカル（`SharedPreferences` + 同梱JSON問題データ）だけで一通り動かせます。
- 合格予測ロジック（`PredictionScoreService`）と広告表示ガード（`AdGateService`）は
  ユニットテスト付きで実装済み（`test/`）。
- ひっかけ道場・バイク解放・ペイウォール（買い切り期間パス）・設定画面も一通り実装。

### 未実装・要対応（本番リリース前に必須）

- **Firebase接続**：`google-services.json` / `GoogleService-Info.plist` を追加し、
  `main.dart` で `Firebase.initializeApp()` を呼んで `dataServiceProvider` /
  `analyticsServiceProvider` を Firestore/Firebase Analytics 実装に override する
  （`lib/services/local_data_service.dart`, `lib/services/analytics_service.dart` の
  TODOコメント参照）。
- **RevenueCat接続**：`purchases_flutter` の実配線（`lib/services/purchase_service.dart`）。
  非消費型(non-consumable)の単一区分パス(¥980)・全区分セットパス(¥1,980)。
- **広告SDK導入**：インタースティシャル/リワード広告本体の実装。表示直前に必ず
  `AdGateService.canShowInterstitial` / `canShowRewardedAd` を通すこと
  （バナー広告は方針上不採用＝ `canShowBanner` は常に `false`）。
- **Lottie演出アセット**：正解=紙吹雪風、バイク解放=ゴールド演出などのLottieファイル
  （`AnswerResultOverlay` は現状アイコンのプレースホルダ）。
- **問題データの本格入稿**：`assets/questions/*.json` はサンプル問題のみ（各区分6〜10問）。
  本番はスプレッドシート→検証スクリプト→Firestore一括投入のパイプラインに移行。
- **認証**：`currentUidProvider` は固定uid。Firebase Auth 匿名認証に差し替える。
- **サウンド・ハプティクス**：SE・ミュートスイッチ未実装。
- **通知プレプロンプト**：設定画面のトグルはUIのみ、OS許可フローは未実装。

## ディレクトリ構成

```
lib/
  core/         // テーマ、定数（免許区分・バイク段階・Analyticsイベント名）
  models/       // User, Question, UserAnswerLog, PassPredictionScore,
                // BikeUnlockProgress, TrapDojoSession
  services/     // DataService(Local実装), AnalyticsService, PredictionScoreService,
                // PurchaseService, AdGateService
  viewmodels/   // Riverpod Provider群（providers.dart）
  views/        // Onboarding, LicenseCategorySelect, Home, DailyQuota,
                // TrapDojo, BikeUnlock, ExamDateSetting, Settings, Paywall
  widgets/      // PassPredictionMeter, AnswerResultOverlay
assets/questions/  // 区分別サンプル問題（JSON）
test/              // PredictionScoreService, AdGateService のユニットテスト
```

## 広告表示制御方針（コードレベルで担保）

批判的レビューで指摘された致命論点のため、`AdGateService` で以下をコードレベルに強制：

- 問題回答中／ひっかけ道場ボス戦中／合格予測メーター表示直後は広告表示を禁止
- インタースティシャルは「1日ノルマ完走後の結果画面」でのみ・1日1回・同一セッション内2回目禁止
- リワード広告はユーザー起点のみ
- バナー広告は不採用（`canShowBanner` は常に `false`）
