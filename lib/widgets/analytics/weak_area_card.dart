import 'package:flutter/material.dart';

import '../../models/analytics_snapshot.dart';

/// 弱点領域を表示するカード
class WeakAreaCard extends StatelessWidget {
  const WeakAreaCard({
    super.key,
    required this.weakArea,
  });

  final WeakArea weakArea;

  @override
  Widget build(BuildContext context) {
    final accuracy = weakArea.stat.accuracyPercent;
    final severity = weakArea.severity;

    // 重大度に応じた色を決定
    final severityColor = _getSeverityColor(severity);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                // 重大度インジケーター
                Container(
                  width: 12,
                  height: 50,
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // ラベルと重大度
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weakArea.label,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getSeverityLabel(severity),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: severityColor),
                      ),
                    ],
                  ),
                ),
                // 正答率
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${accuracy.toStringAsFixed(1)}%',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getAccuracyColor(accuracy),
                          ),
                    ),
                    Text(
                      '${weakArea.stat.correctCount}/${weakArea.stat.attempts}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // プログレスバー
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: weakArea.stat.accuracy,
                minHeight: 6,
                color: _getAccuracyColor(accuracy),
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            // 説明テキスト
            Text(
              _buildDescription(weakArea.kind, weakArea.label),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  /// 重大度スコアに基づいて色を決定
  Color _getSeverityColor(double severity) {
    if (severity >= 0.7) return Colors.red;
    if (severity >= 0.4) return Colors.orange;
    return Colors.amber;
  }

  /// 重大度スコアに基づいてラベルを生成
  String _getSeverityLabel(double severity) {
    if (severity >= 0.7) return '緊急';
    if (severity >= 0.4) return '中程度';
    return '軽微';
  }

  /// 正答率に基づいて色を決定
  Color _getAccuracyColor(double accuracyPercent) {
    if (accuracyPercent >= 70) return Colors.amber;
    if (accuracyPercent >= 40) return Colors.deepOrange;
    return Colors.red;
  }

  /// 弱点の種別に応じた説明を生成
  String _buildDescription(WeakAreaKind kind, String label) {
    switch (kind) {
      case WeakAreaKind.stage:
        return '$labelでの出題パターンの理解が不足しています。';
      case WeakAreaKind.category:
        return '$labelの問題で正答率が低下しています。';
      case WeakAreaKind.trapType:
        return '$labelに該当する問題で間違いやすくなっています。';
      case WeakAreaKind.difficulty:
        return '$labelの難易度の問題に対応する力が不足しています。';
      case WeakAreaKind.topic:
        return 'このテーマについて、もっと学習が必要です。';
    }
  }
}
