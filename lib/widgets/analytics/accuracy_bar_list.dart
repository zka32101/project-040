import 'package:flutter/material.dart';

/// 正答率バーアイテムのデータモデル
class AccuracyBarItem {
  AccuracyBarItem({
    required this.label,
    required this.accuracy,
    required this.attempts,
    required this.correctCount,
  });

  final String label;
  final double accuracy; // 0.0 ~ 1.0
  final int attempts;
  final int correctCount;

  double get accuracyPercent => accuracy * 100;
  bool get isReliable => attempts >= 10;
}

/// 複数の正答率バーをリスト表示
/// ステージ別、カテゴリ別の情報表示に使用
class AccuracyBarList extends StatelessWidget {
  const AccuracyBarList({
    super.key,
    required this.items,
  });

  final List<AccuracyBarItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'データがありません',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    // 正答率が低い順にソート（弱点優先）
    final sorted = [...items]
        ..sort((a, b) => a.accuracy.compareTo(b.accuracy));

    return Column(
      children: List.generate(
        sorted.length,
        (index) => _buildAccuracyBar(context, sorted[index]),
      ),
    );
  }

  Widget _buildAccuracyBar(
    BuildContext context,
    AccuracyBarItem item,
  ) {
    final accuracyPercent = item.accuracyPercent;
    final color = _getAccuracyColor(accuracyPercent);
    final isLowData = !item.isReliable;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (isLowData)
                Chip(
                  label: const Text('データ不足'),
                  labelStyle: Theme.of(context).textTheme.bodySmall,
                  side: BorderSide.none,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceVariant,
                )
              else
                Text(
                  '${accuracyPercent.toStringAsFixed(1)}% (${item.correctCount}/${item.attempts})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.accuracy,
              minHeight: 6,
              color: color,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 正答率に基づいて色を決定
  Color _getAccuracyColor(double accuracyPercent) {
    if (accuracyPercent >= 80) return Colors.green;
    if (accuracyPercent >= 60) return Colors.amber;
    if (accuracyPercent >= 40) return Colors.deepOrange;
    return Colors.red;
  }
}
