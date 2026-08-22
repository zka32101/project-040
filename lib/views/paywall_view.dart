import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/analytics_events.dart';
import '../viewmodels/providers.dart';

/// ペイウォール：期間パス（非消費型・買い切り）。サブスクではない。
/// - 単一区分パス：¥980（合格まで無制限・広告完全非表示）
/// - 全区分セットパス：¥1,980
class PaywallView extends ConsumerWidget {
  const PaywallView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('プランを選ぶ')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '広告なしで合格まで学習し放題',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _PlanCard(
              title: '単一区分パス',
              price: '¥980',
              description: '選んだ1区分を合格まで無制限・広告完全非表示',
              onTap: () => _purchase(context, ref, isSet: false),
            ),
            const SizedBox(height: 16),
            _PlanCard(
              title: '全区分セットパス',
              price: '¥1,980',
              description: '複数区分を並行/段階取得する人向け',
              highlighted: true,
              onTap: () => _purchase(context, ref, isSet: true),
            ),
            const Spacer(),
            TextButton(
              onPressed: () async {
                await ref.read(purchaseServiceProvider).restorePurchases();
              },
              child: const Text('購入を復元'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchase(
    BuildContext context,
    WidgetRef ref, {
    required bool isSet,
  }) async {
    final purchaseService = ref.read(purchaseServiceProvider);
    final status = isSet
        ? await purchaseService.purchaseAllCategorySetPass()
        : await purchaseService.purchaseSingleCategoryPass();

    await ref.read(userControllerProvider.notifier).setPurchaseStatus(status);
    await ref.read(analyticsServiceProvider).logEvent(
      AnalyticsEvents.paywallConverted,
      parameters: {'plan': isSet ? 'all_category_set' : 'single_category'},
    );

    if (context.mounted) Navigator.of(context).pop();
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.description,
    required this.onTap,
    this.highlighted = false,
  });

  final String title;
  final String price;
  final String description;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlighted ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    price,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(description),
            ],
          ),
        ),
      ),
    );
  }
}
