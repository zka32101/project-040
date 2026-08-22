import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'views/onboarding_view.dart';

class BikeLicenseKoreApp extends StatelessWidget {
  const BikeLicenseKoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '原付・バイク免許コレ！',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system, // ダークモード必須（Step5.5）
      home: const OnboardingView(),
    );
  }
}
