import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

// TODO(firebase-setup): google-services.json / GoogleService-Info.plist を
// 追加後、Firebase.initializeApp() をここで呼び、
// dataServiceProvider / analyticsServiceProvider を
// Firestore/Firebase Analytics 実装で override する。
// TODO(revenuecat-setup): Purchases.configure(...) をここで呼ぶ。
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BikeLicenseKoreApp()));
}
