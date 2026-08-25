import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/firebase_analytics_service.dart';
import 'services/firestore_data_service.dart';
import 'viewmodels/providers.dart';

// TODO(revenuecat-setup): Purchases.configure(...) をここで呼ぶ。
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 初期化（google-services.json / GoogleService-Info.plist が必須）
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(
      overrides: [
        // Firestore をデータサービスとして使用
        dataServiceProvider.overrideWithValue(FirestoreDataService()),

        // Firebase Analytics を計測サービスとして使用
        analyticsServiceProvider
            .overrideWithValue(FirebaseAnalyticsService()),
      ],
      child: const BikeLicenseKoreApp(),
    ),
  );
}
