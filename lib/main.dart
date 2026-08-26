import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/firebase_analytics_service.dart';
import 'services/firestore_data_service.dart';
import 'services/firestore_sync_service.dart';
import 'services/hybrid_data_service.dart';
import 'services/local_data_service.dart';
import 'viewmodels/providers.dart';

// RevenueCat API キー（iOS/Android）
// 設定方法: https://docs.revenuecat.com/docs/getting-started
// これらのキーは環境変数または FlutterFire Console から取得
// const String _revenueCatApiKeyiOS = 'TODO_IOS_API_KEY';
// const String _revenueCatApiKeyAndroid = 'TODO_ANDROID_API_KEY';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 初期化（google-services.json / GoogleService-Info.plist が必須）
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // RevenueCat 初期化（API キーは RevenueCat Dashboard から取得）
  // TODO(revenuecat-setup): API キーを設定して Purchases.configure() を有効化
  // await Purchases.configure(
  //   PurchasesConfiguration(
  //     apiKey: Platform.isIOS ? _revenueCatApiKeyiOS : _revenueCatApiKeyAndroid,
  //   ),
  // );

  runApp(
    ProviderScope(
      overrides: [
        // ハイブリッドデータサービス：Firestore 優先、ローカルにフォールバック
        dataServiceProvider.overrideWithValue(
          HybridDataService(
            localDataService: LocalDataService(),
            firestoreSyncService: LocalFirestoreSyncService(),
          ),
        ),

        // Firebase Analytics を計測サービスとして使用
        analyticsServiceProvider
            .overrideWithValue(FirebaseAnalyticsService()),

        // RevenueCat を購入サービスとして使用
        // TODO(revenuecat-setup): Purchases.configure() 有効化後にコメント解除
        // purchaseServiceProvider.overrideWithValue(RevenueCatPurchaseService()),
      ],
      child: const BikeLicenseKoreApp(),
    ),
  );
}
