# Google Mobile Ads 統合ガイド

このドキュメントは、**原付・バイク免許コレ！** に Google Mobile Ads SDK を統合して、インタースティシャル・リワード広告を表示する手順を説明します。

## 概要

### 広告表示ポリシー（AdGateService で強制）

- **バナー広告**: 不採用 (`canShowBanner` 常に false)
- **インタースティシャル広告**: ノルマ完走後のみ・1日1回・同一セッション内2回目禁止
- **リワード広告**: ユーザー起点のみ（"広告を見て報酬" ボタン）

### ブロッキング対象（広告表示禁止）

- 問題回答中
- ひっかけ道場ボス戦中
- 合格予測メーター表示直後（3秒程度）

---

## 前提条件

- Google アカウント（AdMob 登録用）
- Firebase プロジェクト既存（Firebase 統合完了後）
- iOS: Apple Developer Program 登録済み
- Android: Google Play Developer Console アカウント登録済み

---

## Step 1: Google AdMob アカウント作成

### 1.1 AdMob に登録

https://admob.google.com にアクセスして、Google アカウントでサインイン。

### 1.2 AdMob プロジェクト作成

**AdMob Dashboard > Create Project**

**Project Name**: `Bike License Kore` (任意)

### 1.3 iOS/Android アプリ登録

左メニュー **Apps > Add your first app**

#### 1.3.1 iOS アプリ登録

```
Platform: iOS
App Name: 原付・バイク免許コレ
App Store URL: https://apps.apple.com/app/id... (本番リリース後)
```

#### 1.3.2 Android アプリ登録

```
Platform: Google Play
App Name: 原付・バイク免許コレ
Play Store URL: https://play.google.com/store/apps/details?id=com.example.bike_license_kore
```

---

## Step 2: Ad Unit ID の生成

### 2.1 Ad Unit 作成

**AdMob Dashboard > Apps > [Your App] > Ad Units > Create new ad unit**

#### 2.1.1 バナー広告 Ad Unit (参考: 不採用方針)

```
Ad Unit Name: Banner - Home Screen
Format: Banner (320x50)
```

#### 2.1.2 インタースティシャル Ad Unit

```
Ad Unit Name: Interstitial - Daily Quota Completion
Format: Interstitial
Placement: Daily quota result screen (ノルマ完走時)
```

#### 2.1.3 リワード広告 Ad Unit

```
Ad Unit Name: Rewarded - User Initiated
Format: Rewarded
Placement: Settings / Paywall (ユーザー起点)
```

### 2.2 Ad Unit ID をコピー

各 Ad Unit の ID をコピー（例: `ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy`）

---

## Step 3: Firebase との連携

### 3.1 AdMob を Firebase に接続

**Firebase Console > [Your Project] > AdMob > Link AdMob account**

- AdMob アカウントを選択
- Firebase Analytics イベント追跡を有効化（オプション）

### 3.2 初期化 Configuration

Firebase Analytics から以下を確認：

- Event: `ad_impression` (広告表示時)
- Event: `ad_click` (広告クリック時)
- Event: `rewarded_ad_complete` (リワード完了時)

---

## Step 4: Flutter アプリ設定

### 4.1 google_mobile_ads 依存追加

```bash
flutter pub add google_mobile_ads
```

または `pubspec.yaml` に追加（既に追加済み）:

```yaml
dependencies:
  google_mobile_ads: ^6.0.0
```

### 4.2 Native 設定 (Android)

**android/app/build.gradle**

```gradle
dependencies {
  implementation 'com.google.android.gms:play-services-ads:22.6.0'
}
```

### 4.3 Native 設定 (iOS)

**ios/Podfile**

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'GA_DISABLE_AUTOTAGGING=1',
      ]
    end
  end
end
```

**ios/Runner/Info.plist**

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyy</string>
```

> `xxxxxxxxxxxxxxxx~yyyyyyyyy` は AdMob で生成される App ID（Ad Unit ID ではない）

### 4.4 AndroidManifest.xml 設定

**android/app/src/main/AndroidManifest.xml**

```xml
<manifest ...>
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application>
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyy" />
    </application>
</manifest>
```

---

## Step 5: コード実装

### 5.1 main.dart で初期化

```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/google_mobile_ads_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 初期化...

  // Google Mobile Ads 初期化
  // テスト環境では自動的にテスト Ad Unit ID が使用される
  await GoogleMobileAdsService().initialize(
    // Production: Ad Unit ID をここに指定
    // interstitialAdUnitId: 'YOUR_PRODUCTION_INTERSTITIAL_ID',
    // rewardedAdUnitId: 'YOUR_PRODUCTION_REWARDED_ID',
  );

  runApp(...);
}
```

### 5.2 Daily Quota 完走時にインタースティシャル表示

```dart
// lib/views/daily_quota_view.dart
// _QuotaCompletedView でノルマ完走画面を表示

Future<void> _showInterstitialIfEligible(WidgetRef ref) async {
  final adGateService = ref.read(adGateServiceProvider);

  // AdGateService でチェック（1日1回・同一セッション内2回目禁止）
  if (!adGateService.canShowInterstitial) {
    return;
  }

  final adsService = GoogleMobileAdsService();

  // 広告が読み込まれていなければロード
  if (!adsService.isInterstitialAdLoaded) {
    await adsService.loadInterstitialAd(
      onAdLoaded: () {
        // ロード完了後に表示
        _displayInterstitial();
      },
      onAdFailedToLoad: (error) {
        print('Interstitial failed to load: $error');
      },
    );
  } else {
    // 既読み込みであれば即座に表示
    _displayInterstitial();
  }
}

Future<void> _displayInterstitial() async {
  final adsService = GoogleMobileAdsService();
  await adsService.showInterstitialAd(
    onAdDismissed: () {
      // 広告を閉じた後の処理
      adGateService.markInterstitialShown(); // 表示済みフラグ
    },
  );
}
```

### 5.3 リワード広告（ユーザー起点）

```dart
// lib/views/paywall_view.dart または settings_view.dart
// "広告を見て報酬獲得" ボタン

Future<void> _watchRewardedAd() async {
  final adGateService = ref.read(adGateServiceProvider);

  // AdGateService でチェック（コンテキスト内では表示不可）
  if (!adGateService.canShowRewardedAd) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('現在広告を表示できません')),
    );
    return;
  }

  final adsService = GoogleMobileAdsService();

  // 広告をロード
  await adsService.loadRewardedAd(
    onAdLoaded: () {
      _displayRewardedAd(adsService);
    },
    onAdFailedToLoad: (error) {
      print('Rewarded ad failed to load: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('広告の読み込みに失敗しました')),
      );
    },
  );
}

Future<void> _displayRewardedAd(GoogleMobileAdsService adsService) async {
  await adsService.showRewardedAd(
    onUserEarnedReward: (ad, reward) {
      // ユーザーが報酬を見た → 報酬付与処理
      _awardReward(reward); // ポイント加算など
      ref.read(analyticsServiceProvider).logEvent('rewarded_ad_completed');
    },
    onAdDismissed: () {
      // 広告を閉じた
    },
  );
}
```

---

## Step 6: テスト

### 6.1 テスト Ad Unit ID での動作確認

Google 公式テスト Ad Unit ID が実装に含まれています。

**初期状態で広告が表示されるかチェック:**

```bash
flutter run
# ノルマ完走画面でインタースティシャル表示
# "広告を見る" ボタンでリワード広告表示
```

### 6.2 実機テスト

#### iOS テスト

```bash
flutter run -d [iOS Device UUID]
```

Test Flight での配信時も AdMob は動作します（テスト Ad Unit ID）。

#### Android テスト

```bash
flutter run -d [Android Device ID]
```

Google Play 内部テスト配信時も AdMob は動作します。

### 6.3 AdMob Dashboard での確認

**AdMob Dashboard > Apps > [Your App] > Ad Units**

- Impressions (表示数)
- Clicks (クリック数)
- CTR (クリック率)

---

## Step 7: Production Ad Unit ID への切り替え

### 7.1 Ad Unit ID を環境変数で管理

```dart
// lib/config/ad_unit_config.dart (新規作成)

class AdUnitConfig {
  static const String interstitialAdUnitId = String.fromEnvironment(
    'INTERSTITIAL_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712', // テスト ID
  );

  static const String rewardedAdUnitId = String.fromEnvironment(
    'REWARDED_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917', // テスト ID
  );
}
```

### 7.2 main.dart で読み込み

```dart
import 'config/ad_unit_config.dart';

await GoogleMobileAdsService().initialize(
  interstitialAdUnitId: AdUnitConfig.interstitialAdUnitId,
  rewardedAdUnitId: AdUnitConfig.rewardedAdUnitId,
);
```

### 7.3 本番ビルド時に指定

```bash
# iOS
flutter build ios --release \
  --dart-define=INTERSTITIAL_AD_UNIT_ID=ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy \
  --dart-define=REWARDED_AD_UNIT_ID=ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz

# Android
flutter build appbundle --release \
  --dart-define=INTERSTITIAL_AD_UNIT_ID=ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy \
  --dart-define=REWARDED_AD_UNIT_ID=ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz
```

---

## トラブルシューティング

### 広告が表示されない

1. **テスト Ad Unit ID が使用されているか確認**
   - 初期段階では Google 公式テスト ID で動作確認

2. **AdGateService チェック**
   - `canShowInterstitial` / `canShowRewardedAd` が true か確認
   - デバッグログを追加: `print('[AdGate] canShowInterstitial=$canShow')`

3. **デバイス広告 ID が無効か確認**
   - AdMob で個別デバイスをテスト設定に追加

### "No Activity found" エラー (Android)

**AndroidManifest.xml**

```xml
<activity android:name="com.google.android.gms.ads.AdActivity"
    android:configChanges="keyboard|keyboardHidden|orientation|screenLayout|uiMode|screenSize|smallestScreenSize"
    android:theme="@android:style/Theme.Translucent" />
```

### Production Ad Unit ID でクリックが記録されない

1. AdMob で App ID が正しく登録されているか確認
2. 本番ビルドが Google Play / App Store 経由でインストールされているか確認
3. AdMob Dashboard で確認（反映に最大 1 時間）

---

## 本番リリース前チェックリスト

- [ ] AdMob アカウント作成・プロジェクト登録済み
- [ ] iOS/Android App ID が AdMob に登録済み
- [ ] Ad Unit ID を Production ID に切り替え済み
- [ ] テスト デバイスで広告表示確認済み
- [ ] AdGateService ガードが正常に動作確認済み
- [ ] インタースティシャル: ノルマ完走時に表示確認
- [ ] リワード: ユーザー起点で表示確認
- [ ] AdMob Dashboard で収益が記録されることを確認
- [ ] Analytics イベント（ad_impression 等）が送信確認

---

## 次のステップ

1. ✅ Google Mobile Ads 統合完了
2. ⬜ Lottie アニメーション追加
3. ⬜ 問題データ本格投入パイプライン

---

**参考リンク**

- [Google Mobile Ads SDK for Flutter](https://developers.google.com/admob/flutter/start)
- [AdMob Help Center](https://support.google.com/admob)
- [Google Ads Policy](https://support.google.com/admobpolicy)

---

**Last Updated**: 2026-08-25
**Status**: Google Mobile Ads 統合実装済み、Ad Unit ID 設定待ち
