import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'views/onboarding_view.dart';
import 'viewmodels/providers.dart';

class BikeLicenseKoreApp extends ConsumerWidget {
  const BikeLicenseKoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // アプリ起動時に Firebase Auth 初期化を実行
    // エラー時は同期的にスナックバーを表示して続行
    ref.listen(authReadyProvider, (previous, next) {
      next.whenData((uid) {
        if (context.mounted) {
          debugPrint('Auth initialized with UID: $uid');
        }
      }).whenError((error, stackTrace) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('認証初期化に失敗: $error')),
          );
        }
      });
    });

    // アプリ起動時にネットワークキュープロセッサーを初期化
    // これでオフラインキューの自動処理が開始される
    ref.listen(networkQueueProcessorProvider, (previous, next) {
      next.whenData((processor) {
        if (context.mounted) {
          debugPrint('Network queue processor initialized');
        }
      }).whenError((error, stackTrace) {
        if (context.mounted) {
          debugPrint('Failed to initialize network queue processor: $error');
        }
      });
    });

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
