import 'package:flutter/material.dart';

import '../models/pass_prediction_score.dart';
import '../services/prediction_score_service.dart';

/// 合格予測メーター表示。
///
/// 【致命的リスク①対応】回答数が十分でない間は「予測」を名乗らず
/// 「習熟度」表記にフォールバックする（実装引き継ぎ書 固有事項）。
class PassPredictionMeter extends StatelessWidget {
  const PassPredictionMeter({
    super.key,
    required this.score,
    required this.answeredCount,
  });

  final PassPredictionScore? score;
  final int answeredCount;

  @override
  Widget build(BuildContext context) {
    final hasEnoughData = answeredCount >=
        PredictionScoreService.minAnswersForPrediction;
    final label = hasEnoughData ? '合格予測' : '今の習熟度';
    final value = score?.score ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6, left: 2),
                  child: Text('%'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (value / 100).clamp(0, 1),
                minHeight: 10,
              ),
            ),
            if (!hasEnoughData) ...[
              const SizedBox(height: 8),
              Text(
                'あと${(PredictionScoreService.minAnswersForPrediction - answeredCount).clamp(0, 999)}問で「合格予測」表示になります',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (score != null && score!.breakdown.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final entry in score!.breakdown.entries)
                    Chip(
                      label: Text(
                        '${entry.key} ${(entry.value * 100).toStringAsFixed(0)}%',
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
