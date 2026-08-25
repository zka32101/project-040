# Firebase 統合ガイド

このドキュメントは、**原付・バイク免許コレ！** MVP を Firebase と統合するための手順を説明します。

## 前提条件

- Flutter 3.24.0 以上がインストール済み
- Firebase CLI がインストール済み（`npm install -g firebase-tools`）
- Google アカウント（Firebase プロジェクト作成用）

## Step 1: Firebase プロジェクトの作成

### 1.1 Firebase Console にアクセス

https://console.firebase.google.com にアクセスして、新規プロジェクトを作成します。

**プロジェクト名**: `bike-license-kore` （または任意の名前）

### 1.2 Google Analytics の有効化

オプションですが、推奨します。Firebase Analytics 統合に必要な場合は有効にします。

### 1.3 Firebase Streaming API キーの生成

後の `flutterfire configure` で必要になります。

---

## Step 2: Firebase CLI の認証と configure

### 2.1 Firebase CLI にログイン

```bash
firebase login
```

Google アカウントで認証します。

### 2.2 `flutterfire configure` で自動セットアップ

プロジェクトルートで実行：

```bash
flutterfire configure
```

このコマンドが以下を自動実行します：

1. Firebase プロジェクトを選択
2. iOS/Android それぞれの App ID を入力（またはデフォルト）
3. `lib/firebase_options.dart` を自動生成
4. `google-services.json` (Android) を生成
5. `GoogleService-Info.plist` (iOS) を生成

---

## Step 3: ファイル配置

`flutterfire configure` 後、以下のファイルが自動配置されます：

### Android

- `android/app/google-services.json` - Firebase config
- `android/build.gradle` - Google Services Plugin 追加
- `android/app/build.gradle` - Firebase Dependencies 追加

### iOS

- `ios/Runner/GoogleService-Info.plist` - Firebase config
- `ios/Podfile` - Firebase Pods 追加

### Flutter

- `lib/firebase_options.dart` - Firebase 初期化用設定（自動生成）

---

## Step 4: iOS 追加設定（iOS ビルド時のみ）

iOS アプリをビルドする場合、以下の追加設定が必要です：

### 4.1 Podfile の確認

```bash
cd ios && pod install && cd ..
```

### 4.2 Minimum Deployment Target の確認

`ios/Podfile` で、minimum deployment target が **11.0 以上** であることを確認：

```ruby
platform :ios, '12.0'
```

### 4.3 Info.plist 確認（必要に応じて）

`ios/Runner/Info.plist` に以下が設定されていることを確認：

```xml
<key>FirebaseIsAnalyticsCollectionEnabled</key>
<true/>
```

---

## Step 5: Firestore セキュリティルールの設定

Firebase Console > Firestore Database > Rules で、以下のセキュリティルールを設定：

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Authenticated users can only access their own user document
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
      
      // Subcollections (answerLogs, bikeProgress, trapDojo, etc.)
      match /{document=**} {
        allow read, write: if request.auth.uid == uid;
      }
    }

    // Questions (read-only for all authenticated users)
    match /questions/{document=**} {
      allow read: if request.auth.uid != null;
      allow write: if false; // Admin only (set via Firebase Console or backend)
    }
  }
}
```

---

## Step 6: Firebase Authentication の有効化

### 6.1 Anonymous Sign-In の有効化

Firebase Console > Authentication > Sign-in method > Anonymous を有効にします。

これにより、ユーザーのアカウント登録なしにアプリが動作します。

**現状**: `currentUidProvider` は固定値ですが、後で Anonymous Auth に差し替え予定。

---

## Step 7: Firestore Database の初期化

### 7.1 データベースの作成

Firebase Console > Firestore Database > Create Database

- **Location**: asia-northeast1 (Tokyo) 推奨
- **セキュリティモード**: "本番環境モード" (後のルール設定に従う)

### 7.2 初期コレクション構造

Firestore 内に以下のコレクション構造を作成します（自動）：

```
firestore/
├── users/
│   ├── {uid}/
│   │   ├── {uid} → AppUser (JSON)
│   │   ├── answerLogs/ → UserAnswerLog[] (自動)
│   │   ├── bikeProgress/ → BikeUnlockProgress[] (自動)
│   │   ├── trapDojo/ → TrapDojoSession[] (自動)
│   │   └── metadata/
│   │       └── predictionScore → PassPredictionScore (自動)
│
└── questions/ ← 今後、本格投入時に追加
    ├── futsuuNirin/
    │   ├── futsuu_001 → Question JSON
    │   └── ...
    └── ogataNirin/
        ├── ogata_001 → Question JSON
        └── ...
```

---

## Step 8: アプリで Firebase 接続確認

### 8.1 ビルド

```bash
# Dependencies 更新
flutter pub get

# Analyze 実行
flutter analyze

# Android: flutterfire configure で google-services.json が自動リンクされているため
flutter run -d android

# iOS: 必要に応じて Pod update
cd ios && pod update && cd ..
flutter run -d ios
```

### 8.2 ログ確認

アプリ起動時、以下のログが表示されれば正常：

```
I/Firestore(PID): [Firestore]: Firestore initialized
I/FA(PID): App measurement is starting up
```

---

## Step 9: 本格投入準備（将来フェーズ）

### 9.1 問題データの Firestore 投入

現在、`assets/questions/*.json` からローカルロードしています。

本格投入時：

1. スプレッドシート → JSON 検証 → Firestore 一括投入パイプラインを構築
2. `FirestoreDataService.loadQuestions()` を Firestore から取得に変更
3. `LocalDataService` のキャッシュ機構で対応

### 9.2 Firebase Remote Config 設定

以下を Remote Config で管理予定：

- `minAnswersForPrediction` (現在: 10)
- `freeDailyQuotaLimit` (現在: 10)
- A/B テスト用フラグ

### 9.3 Crashlytics 統合

本格運用前に Firebase Crashlytics を有効にして、本番環境での障害追跡を設定。

---

## トラブルシューティング

### `flutterfire configure` でエラーが出た

1. Firebase CLI が最新版か確認：`firebase --version`
2. ログイン確認：`firebase login`
3. プロジェクトの選択を正確に

### iOS ビルドエラー: "FirebaseCore not found"

```bash
cd ios
rm -rf Pods Pod.lock
pod install
cd ..
flutter clean
flutter pub get
flutter run -d ios
```

### Android ビルドエラー: "google-services.json not found"

1. `android/app/google-services.json` が存在することを確認
2. `android/build.gradle` に以下が含まれているか確認：
   ```gradle
   buildscript {
     dependencies {
       classpath 'com.google.gms:google-services:4.3.14'
     }
   }
   ```
3. `android/app/build.gradle` に以下が含まれているか確認：
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### Firestore ルールエラー: "Permission denied"

Firebase Console の Firestore > Rules が正しく設定されているか確認。
テスト時は以下の緩いルールで確認後、本番用に設定：

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write;
    }
  }
}
```

> ⚠️ 本番環境では絶対に使用しないでください。

---

## 次のステップ

1. ✅ Firebase 統合完了
2. ⬜ RevenueCat 統合（In-app Purchases）
3. ⬜ 広告 SDK 統合（Google Mobile Ads）
4. ⬜ Lottie アニメーション追加
5. ⬜ 問題データ本格投入パイプライン構築

---

**Last Updated**: 2026-08-22
**Status**: Firebase 統合実装済み、リリース待ち
