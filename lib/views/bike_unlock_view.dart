import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/license_category.dart';
import '../viewmodels/providers.dart';

/// 憧れバイク解放：正解を積むと乗れるバイクのシルエットが解放される
/// （原付→125→250→400→大型、進捗グリッド）。
class BikeUnlockView extends ConsumerWidget {
  const BikeUnlockView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(bikeUnlockControllerProvider);
    final logsAsync = ref.watch(answerLogsProvider);

    // 通算正解数が変わったら解放判定を再実行。
    ref.listen(answerLogsProvider, (prev, next) {
      final logs = next.valueOrNull;
      if (logs == null) return;
      final totalCorrect = logs.where((l) => l.isCorrect).length;
      ref
          .read(bikeUnlockControllerProvider.notifier)
          .refreshFromTotalCorrectCount(totalCorrect);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('バイク解放')),
      body: progressAsync.when(
        data: (progress) {
          final totalCorrect =
              logsAsync.valueOrNull?.where((l) => l.isCorrect).length ?? 0;
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: progress.length,
            itemBuilder: (context, i) {
              final p = progress[i];
              final tier =
                  BikeTier.values.firstWhere((t) => t.name == p.bikeId);
              return _BikeTile(unlocked: p.isUnlocked, tier: tier);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('読み込みに失敗しました: $e')),
      ),
    );
  }
}

class _BikeTile extends StatelessWidget {
  const _BikeTile({required this.unlocked, required this.tier});

  final bool unlocked;
  final BikeTier tier;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: unlocked
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.two_wheeler,
              size: 56,
              color: unlocked
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              tier.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (!unlocked)
              Text(
                '正解${tier.requiredCorrectCount}問で解放',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}
