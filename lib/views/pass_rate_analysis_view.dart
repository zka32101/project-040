import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/license_category.dart';
import '../models/analytics_snapshot.dart';
import '../viewmodels/providers.dart';

/// 合格率分析詳細画面。
/// 全体正答率、区分別、段階別の詳細な分析を表示。
class PassRateAnalysisView extends ConsumerWidget {
  const PassRateAnalysisView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreAsync = ref.watch(savedPredictionScoreProvider);
    final answersAsync = ref.watch(answerLogsProvider);
    final analyticsAsync = ref.watch(analyticsSnapshotProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('合格率分析')),
      body: ScaffoldMessenger(
        child: scoreAsync.when(
          data: (score) => _buildContent(context, ref, score, answersAsync, analyticsAsync),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('読み込みに失敗しました: $e')),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    dynamic score,
    AsyncValue answersAsync,
    AsyncValue<AnalyticsSnapshot> analyticsAsync,
  ) {
    if (score == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 48),
              const SizedBox(height: 16),
              Text(
                'まだ十分な回答データがありません',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '10問以上回答して、分析を確認してください。',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(savedPredictionScoreProvider);
        ref.invalidate(answerLogsProvider);
        ref.invalidate(analyticsSnapshotProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 全体スコア
          _buildOverallScoreSection(context, score),
          const SizedBox(height: 20),

          // 正答率統計
          answersAsync.when(
            data: (logs) => _buildAccuracyStats(context, logs),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),

          // 区分別分析
          _buildCategoryAnalysis(context, score),
          const SizedBox(height: 20),

          // 段階別分析
          analyticsAsync.when(
            data: (snapshot) => _buildStageAnalysis(context, snapshot),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallScoreSection(BuildContext context, dynamic score) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '合格予測スコア',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    '${score.score.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: _getScoreColor(score.score),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getScoreInterpretation(score.score),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score.score / 100,
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score.score)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracyStats(BuildContext context, List logs) {
    final totalAttempts = logs.length;
    final correctCount = logs.where((l) => l.isCorrect).length;
    final accuracy = totalAttempts > 0 ? (correctCount / totalAttempts * 100) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '正答率統計',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              context,
              '正答数',
              '$correctCount / $totalAttempts',
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              context,
              '正答率',
              '${accuracy.toStringAsFixed(1)}%',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAnalysis(BuildContext context, dynamic score) {
    if (score.breakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '区分別分析',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            ...score.breakdown.entries
                .where((e) {
                  try {
                    LicenseCategory.fromId(e.key);
                    return true;
                  } catch (_) {
                    return false;
                  }
                })
                .map((entry) {
                  final category = LicenseCategory.fromId(entry.key);
                  final accuracy = (entry.value * 100).toStringAsFixed(1);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category.label,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              '$accuracy%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: entry.value,
                            minHeight: 4,
                            backgroundColor:
                                Theme.of(context).colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getAccuracyColor(entry.value),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                })
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStageAnalysis(BuildContext context, AnalyticsSnapshot snapshot) {
    if (snapshot.stages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '段階別分析',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            ...snapshot.stages.map((stage) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          stage.stageTag,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${stage.stat.accuracy.toStringAsFixed(1)}% (${stage.stat.correctCount}/${stage.stat.attempts})',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: stage.stat.accuracy / 100,
                        minHeight: 4,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getAccuracyColor(stage.stat.accuracy / 100),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
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

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) {
      return Colors.green;
    } else if (accuracy >= 0.6) {
      return Colors.orange;
    } else if (accuracy >= 0.4) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }

  String _getScoreInterpretation(double score) {
    if (score >= 80) {
      return '合格まであと一歩！';
    } else if (score >= 60) {
      return '順調に進んでいます';
    } else if (score >= 40) {
      return 'もっと練習が必要です';
    } else {
      return 'コツコツ続けましょう';
    }
  }
}
