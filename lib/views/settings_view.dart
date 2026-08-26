import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../viewmodels/providers.dart';
import 'exam_date_setting_view.dart';
import 'license_category_select_view.dart';
import 'paywall_view.dart';

/// 設定(区分管理／通知／サブスク・パス管理)。
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userControllerProvider);
    final user = userAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('免許区分の管理'),
            subtitle: Text(user?.licenseCategories.join(' / ') ?? '未設定'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LicenseCategorySelectView()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('教習段階・試験日'),
            subtitle: Text(
              user?.examDate != null
                  ? '${user!.examDate!.year}/${user.examDate!.month}/${user.examDate!.day}'
                  : '未設定',
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExamDateSettingView()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text('効果音'),
            trailing: Consumer(
              builder: (context, ref, _) {
                final isMuted = ref.watch(soundMutedProvider);
                return Switch(
                  value: !isMuted,
                  onChanged: (value) async {
                    ref.read(soundMutedProvider.notifier).state = !value;
                    // サウンドサービスの状態も更新
                    try {
                      final soundService = await ref.read(soundEffectsServiceProvider.future);
                      await soundService.setMuted(!value);
                    } catch (_) {
                      // Ignore errors during sound service update
                    }
                  },
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('通知'),
            trailing: Switch(
              value: true,
              onChanged: (_) {
                // TODO: 通知許可プレプロンプト→OS許可の実装
                // （価値説明→OS許可、企画設計書 R①）
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('プラン'),
            subtitle: Text(_planLabel(user?.purchaseStatus)),
            trailing: user?.purchaseStatus == PurchaseStatus.free
                ? const Icon(Icons.chevron_right)
                : const Icon(Icons.check_circle, color: Colors.green),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PaywallView()),
            ),
          ),
        ],
      ),
    );
  }

  String _planLabel(PurchaseStatus? status) {
    switch (status) {
      case PurchaseStatus.singleCategoryPass:
        return '単一区分パス';
      case PurchaseStatus.allCategorySetPass:
        return '全区分セットパス';
      case PurchaseStatus.free:
      case null:
        return '無料版';
    }
  }
}
