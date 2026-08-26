import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/license_category.dart';
import '../models/pass_prediction_score.dart';
import '../views/pass_rate_analysis_view.dart';
import '../viewmodels/providers.dart';

/// 合格率予測カード。
/// 全体的な正答率と区分別の詳細を表示。
class PassRateCard extends ConsumerWidget {
  const PassRateCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreAsync = ref.watch(savedPredictionScoreProvider);
    final answerLogsAsync = ref.watch(answerLogsProvider);

    return scoreAsync.when(
      data: (score) {
        if (score == null) {
          // スコア未計算の場合は何も表示しない
          return const SizedBox.shrink();
        }

        final logs = answerLogsAsync.valueOrNull ?? [];
        final totalAttempts = logs.length;
        final correctCount = logs.where((l) => l.isCorrect).length;
        final accuracy = totalAttempts > 0 ? correctCount / totalAttempts : 0.0;

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PassRateAnalysisView()),
            );
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ヘッダー
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '合格率予測',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${score.score.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: _getScoreColor(score.score),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 正答率
                Text(
                  '正答率: ${(accuracy * 100).toStringAsFixed(1)}% ($correctCount/$totalAttempts問)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),

                // プログレスバー
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score.score / 100,
                    minHeight: 6,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score.score)),
                  ),
                ),
                const SizedBox(height: 12),

                // 区分別の詳細（表示可能なもののみ）
                if (score.breakdown.isNotEmpty) ...[
                  Text(
                    '区分別正答率',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 8),
                  ..._buildCategoryBreakdown(context, score.breakdown),
                ],
              ],
            ),
          ),
            ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  List<Widget> _buildCategoryBreakdown(
    BuildContext context,
    Map<String, double> breakdown,
  ) {
    return breakdown.entries
        .where((e) {
          // 有効な区分のみ表示
          try {
            LicenseCategory.fromId(e.key);
            return true;
          } catch (_) {
            return false;
          }
        })
        .map(
          (entry) {
            final category = LicenseCategory.fromId(entry.key);
            final accuracy = (entry.value * 100).toStringAsFixed(0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '$accuracy%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            );
          },
        )
        .toList();
  }

  Color _getScoreColor(double score) {
    if (score >= 80) {
      return Colors.green;
    } else if (score >= 60) {
      return Colors.orange;
    } else if (score >= 40) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }
}
