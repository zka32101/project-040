# RevenueCat 統合ガイド

このドキュメントは、**原付・バイク免許コレ！** の In-app Purchases (非消費型パス) を RevenueCat で統合する手順を説明します。

## 概要

### 課金体系

- **単一区分パス**: ¥980（1区分・合格まで無制限・広告非表示）
- **全区分セットパス**: ¥1,980（全区分・合格まで無制限・広告非表示）

### 非消費型パス (Non-Consumable)

- 一度購入すると永続的に保持
- サブスクリプション不使用（期間制限なし）
- 削除・再インストール後も復元可能

---

## 前提条件

- Apple Developer Program 登録済み（iOS リリース時）
- Google Play Developer Console アカウント登録済み（Android リリース時）
- RevenueCat アカウント登録済み
- Firebase 統合済み（FIREBASE_SETUP.md を先に実施）

---

## Step 1: RevenueCat 公式アカウント作成

### 1.1 RevenueCat アカウント登録

https://www.revenuecat.com に アクセスして、アカウントを作成します。

**Email**: 開発者メールアドレス
**Password**: セキュアなパスワード

### 1.2 新規プロジェクト作成

Dashboard > Projects > Create New Project

**Project Name**: `bike-license-kore`

### 1.3 プラットフォーム追加

左のメニューから以下を追加：

- **iOS** ✓
- **Android** ✓

---

## Step 2: In-app Products 設定

### 2.1 App Store Connect (iOS)

#### 2.1.1 アプリ作成

https://appstoreconnect.apple.com/

- **App Name**: 原付・バイク免許コレ
- **Bundle ID**: `com.example.bike-license-kore` (or your bundle ID)
- **SKU**: `bike-license-kore`

#### 2.1.2 In-app Purchases 作成

**App Store Connect > Your App > In-App Purchases**

**Product 1 - 単一区分パス**

```
Type: Non-Consumable
Reference Name: Single Category Pass ¥980
Product ID: single_category_pass_980
Price: ¥980 (JP)
Description: 1区分の問題・教習段階・試験日対策が無制限で利用できます。広告も非表示になります。
```

**Product 2 - 全区分セットパス**

```
Type: Non-Consumable
Reference Name: All Category Set Pass ¥1,980
Product ID: all_category_set_pass_1980
Price: ¥1,980 (JP)
Description: 全ての免許区分の問題・教習段階・試験日対策が無制限で利用できます。広告も非表示になります。
```

### 2.2 Google Play Console (Android)

#### 2.2.1 アプリ作成

https://play.google.com/console/

- **App Name**: 原付・バイク免許コレ
- **Package Name**: `com.example.bike_license_kore`

#### 2.2.2 In-app Products 作成

**Google Play Console > Your App > Monetize > In-app products**

**Product 1 - 単一区分パス**

```
Product ID: single_category_pass_980
Product Type: Managed Product
Default Language Title: Single Category Pass ¥980
Default Language Description: 1区分の問題・教習段階・試験日対策が無制限で利用できます。広告も非表示になります。
Price: ¥980
```

**Product 2 - 全区分セットパス**

```
Product ID: all_category_set_pass_1980
Product Type: Managed Product
Default Language Title: All Category Set Pass ¥1,980
Default Language Description: 全ての免許区分の問題・教習段階・試験日対策が無制限で利用できます。広告も非表示になります。
Price: ¥1,980
```

---

## Step 3: RevenueCat Dashboard 設定

### 3.1 iOS In-app Purchase 連携

**RevenueCat Dashboard > [Project] > Apps > iOS**

#### 3.1.1 App Store Connect API 認証

1. **App Store Connect > Users & Access > API Keys**
2. **API Keys > Issuer ID** を控える
3. **API Keys > Create API Key** で Payments キーを生成
4. `.p8` ファイルをダウンロード

**RevenueCat > iOS Settings > App Store Connect API Key**

- **Key ID**: App Store Connect API Key ID
- **Issuer ID**: Issuer ID
- **Private Key (.p8)**: アップロード

#### 3.1.2 Products マッピング

**RevenueCat > Products**

```
single_category_pass_980 → App Store: single_category_pass_980
all_category_set_pass_1980 → App Store: all_category_set_pass_1980
```

### 3.2 Android Google Play 連携

**RevisioneCat Dashboard > [Project] > Apps > Android**

#### 3.2.1 Service Account JSON キー

1. **Google Cloud Console > Service Accounts**
2. **New Service Account** を作成
3. **Roles**: "Editor" を選択
4. **Create JSON Key** でキーファイルをダウンロード

**RevenueCat > Google Play Settings > Service Account JSON**

- JSON ファイルをアップロード

#### 3.2.2 Products マッピング

**RevenueCat > Products**

```
single_category_pass_980 → Google Play: single_category_pass_980
all_category_set_pass_1980 → Google Play: all_category_set_pass_1980
```

### 3.3 Entitlements 設定

**RevenueCat > Entitlements**

```
all_pass
├── all_category_set_pass_1980

single_pass
├── single_category_pass_980
```

---

## Step 4: Flutter アプリ設定

### 4.1 API Key 取得

**RevenueCat Dashboard > Projects > [Your Project] > API Keys**

- **Public API Key** (iOS / Android 共通) をコピー

### 4.2 main.dart 設定

```dart
import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';

const String _revenueCatApiKey = 'YOUR_REVENUECAT_PUBLIC_API_KEY';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 初期化...

  // RevenueCat 初期化
  await Purchases.configure(
    PurchasesConfiguration(
      apiKey: _revenueCatApiKey,
    ),
  );

  // Provider overrides...
  // purchaseServiceProvider.overrideWithValue(RevenueCatPurchaseService()),
}
```

### 4.3 pubspec.yaml 確認

```yaml
dependencies:
  purchases_flutter: ^6.29.1  # ✓ 既に存在
```

---

## Step 5: Test Flight テスト (iOS)

### 5.1 Xcode 設定

**Xcode > Signing & Capabilities**

- **Signing Certificate**: Apple Developer 証明書
- **Provisioning Profile**: In-app Purchases 対応プロファイル
- **Capability**: "In-App Purchases" を追加

### 5.2 ビルドと Test Flight 投入

```bash
flutter build ios --release
# Then upload to Test Flight via Xcode or Transporter
```

### 5.3 テスターで検証

Test Flight テスターは実際の決済ではなく、Apple の **Sandbox 環境**で購入テストができます。

---

## Step 6: Google Play 内部テスト (Android)

### 6.1 Release APK ビルド

```bash
flutter build apk --release
# または
flutter build appbundle --release
```

### 6.2 Google Play Console にアップロード

**Google Play Console > [Your App] > Internal Testing**

- APK またはアプリバンドルをアップロード
- 内部テストユーザーを追加

### 6.3 テストアカウントで検証

Google Play Billing Library は **テストアカウント**（特定の Google アカウント）で Sandbox 購入をシミュレートします。

---

## Step 7: コード実装

### 7.1 RevenueCatPurchaseService 統合

```dart
// lib/main.dart
purchaseServiceProvider.overrideWithValue(RevenueCatPurchaseService()),
```

### 7.2 PaywallView で購入フロー実装済み

```dart
// lib/views/paywall_view.dart
onTap: () => _purchase(context, ref, isSet: true),
```

内部処理：

```dart
Future<void> _purchase(BuildContext context, WidgetRef ref, {required bool isSet}) async {
  try {
    final purchaseService = ref.read(purchaseServiceProvider);
    final status = isSet
        ? await purchaseService.purchaseAllCategorySetPass()
        : await purchaseService.purchaseSingleCategoryPass();
    
    // ユーザー情報更新
    await ref.read(userControllerProvider.notifier).setPurchaseStatus(status);
    
    // Analytics イベント送信
    await ref.read(analyticsServiceProvider).logEvent('paywall_converted');
  } catch (e) {
    // エラーハンドリング
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('購入に失敗しました: $e')),
    );
  }
}
```

### 7.3 Purchase Restore フロー

```dart
// 設定画面に "購入を復元" ボタン
onTap: () async {
  final purchaseService = ref.read(purchaseServiceProvider);
  final status = await purchaseService.restorePurchases();
  await ref.read(userControllerProvider.notifier).setPurchaseStatus(status);
},
```

---

## Step 8: エンタイトルメント確認

アプリ起動時に現在のエンタイトルメント（購入状態）を確認：

```dart
// lib/viewmodels/providers.dart (userControllerProvider 初期化時)
final customerInfo = await Purchases.getCustomerInfo();
if (customerInfo.entitlements.all['all_pass']?.isActive ?? false) {
  return AppUser(..., purchaseStatus: PurchaseStatus.allCategorySetPass);
}
if (customerInfo.entitlements.all['single_pass']?.isActive ?? false) {
  return AppUser(..., purchaseStatus: PurchaseStatus.singleCategoryPass);
}
```

---

## トラブルシューティング

### iOS: "SKReceiptRefreshRequest failed"

**原因**: App Store Connect API Key の設定が不正

**対策**:
1. App Store Connect > Users & Access > API Keys で新しいキーを生成
2. RevenueCat > iOS Settings で更新

### Android: "BILLING_SERVICE_DISCONNECTED"

**原因**: Google Play Billing Library が初期化されていない

**対策**:
1. Google Play Services アップデート確認
2. アプリの Google Play Console 設定確認
3. 内部テストユーザーで再度テスト

### Sandbox Purchase が反映されない

**原因**: エンタイトルメント同期遅延

**対策**:
1. `Purchases.restorePurchases()` を呼び出す
2. アプリを再起動
3. 数分待つ（RevenueCat サーバーとの同期時間）

### Production環境での決済が失敗

**原因**: API Key を本番用に切り替え忘れ

**対策**: 公開ビルド前に以下を確認

```dart
const String _revenueCatApiKey = 'YOUR_PRODUCTION_API_KEY'; // Sandbox ではなく本番キー
```

---

## 本番リリース前チェックリスト

- [ ] RevenueCat プロジェクト作成済み
- [ ] iOS App Store In-App Purchases 登録済み
- [ ] Android Google Play In-App Products 登録済み
- [ ] API Key を pubspec.yaml または 環境変数に設定
- [ ] Test Flight / 内部テストで購入動作確認済み
- [ ] エンタイトルメント同期確認済み
- [ ] "購入を復服" ボタン動作確認済み
- [ ] Analytics イベント（paywall_converted）送信確認済み

---

## 参考リンク

- [RevenueCat Docs](https://docs.revenuecat.com/)
- [purchases_flutter GitHub](https://github.com/RevenueCat/purchases-flutter)
- [App Store Connect - In-App Purchases](https://developer.apple.com/app-store-connect/in-app-purchases/)
- [Google Play Billing - Setup Guide](https://developer.android.com/google/play/billing/billing_library_overview)

---

**Last Updated**: 2026-08-22
**Status**: RevenueCat 統合実装済み、リリース待ち
