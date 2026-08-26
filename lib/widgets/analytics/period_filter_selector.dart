import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/analytics_events.dart';
import '../../viewmodels/providers.dart';

/// 分析期間フィルター選択ウィジェット
/// 7日、30日、全期間から選択可能
class PeriodFilterSelector extends ConsumerWidget {
  const PeriodFilterSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRange = ref.watch(analyticsRangeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text(
            '期間',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    context,
                    ref,
                    label: '7日',
                    range: AnalyticsRange.days7,
                    isSelected: currentRange == AnalyticsRange.days7,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    ref,
                    label: '30日',
                    range: AnalyticsRange.days30,
                    isSelected: currentRange == AnalyticsRange.days30,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    ref,
                    label: '全期間',
                    range: AnalyticsRange.allTime,
                    isSelected: currentRange == AnalyticsRange.allTime,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required AnalyticsRange range,
    required bool isSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          // 期間フィルター変更イベントをログ
          ref.read(analyticsServiceProvider).logEvent(
                AnalyticsEvents.analyticsRangeChanged,
                parameters: {'range': range.name},
              );

          // 状態を更新
          ref.read(analyticsRangeProvider.notifier).state = range;

          // スナップショットを再計算
          ref
              .read(analyticsSnapshotProvider.notifier)
              .refresh(force: true);
        }
      },
    );
  }
}
