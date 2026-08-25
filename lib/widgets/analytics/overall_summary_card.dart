import 'package:flutter/material.dart';

import '../../models/analytics_snapshot.dart';

/// 全体統計サマリーカード
/// 総回答数、正答率、学習日数を表示
class OverallSummaryCard extends StatelessWidget {
  const OverallSummaryCard({
    super.key,
    required this.snapshot,
  });

  final AnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final stat = snapshot.overall;
    final accuracy = stat.accuracyPercent;
    final uniqueDays = _countUniqueDays();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '学習進捗',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            // 正答率ゲージ
            _buildAccuracyGauge(context, accuracy),
            const SizedBox(height: 20),
            // 統計タイル
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    context,
                    icon: Icons.check_circle_outline,
                    label: '正答率',
                    value: '${accuracy.toStringAsFixed(1)}%',
                    color: _getAccuracyColor(accuracy),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile(
                    context,
                    icon: Icons.quiz_outlined,
                    label: '解答数',
                    value: '${stat.attempts}問',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile(
                    context,
                    icon: Icons.calendar_today,
                    label: '学習日数',
                    value: '$uniqueDays日',
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracyGauge(BuildContext context, double accuracy) {
    return Column(
      children: [
        // プログレスバー
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: accuracy / 100,
            minHeight: 8,
            color: _getAccuracyColor(accuracy),
            backgroundColor:
                Theme.of(context).colorScheme.surfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        // パーセンテージ表示
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '合格ライン: 80%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '現在: ${accuracy.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getAccuracyColor(accuracy),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 学習日数を計算
  int _countUniqueDays() {
    final days = <DateTime>{};
    for (final point in snapshot.dailyHistory) {
      days.add(
        DateTime(point.date.year, point.date.month, point.date.day),
      );
    }
    return days.length;
  }

  /// 正答率に基づいて色を決定
  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return Colors.green;
    if (accuracy >= 60) return Colors.amber;
    return Colors.red;
  }
}
