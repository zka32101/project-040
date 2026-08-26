import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/analytics_events.dart';
import '../models/analytics_snapshot.dart';
import '../viewmodels/providers.dart';
import '../widgets/analytics/overall_summary_card.dart';
import '../widgets/analytics/accuracy_bar_list.dart';
import '../widgets/analytics/period_filter_selector.dart';
import '../widgets/analytics/weak_area_card.dart';
import '../widgets/analytics/review_recommendation_card.dart';

/// 学習分析ダッシュボード
/// ユーザーの全体成績、ステージ別・カテゴリ別パフォーマンス、
/// 弱点分析、復習推奨を一つの画面で確認できます。
class AnalyticsDashboardView extends ConsumerWidget {
  const AnalyticsDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(analyticsSnapshotProvider);
    final isLoading = snapshot.isLoading;
    final hasError = snapshot.isRefreshing || snapshot.hasError;

    return Scaffold(
      appBar: AppBar(
        title: const Text('学習分析'),
        actions: [
          // 再読み込みボタン
          if (!isLoading)
            IconButton(
              onPressed: () {
                ref
                    .read(analyticsSnapshotProvider.notifier)
                    .refresh(force: true);
              },
              icon: const Icon(Icons.refresh),
              tooltip: '再計算',
            ),
        ],
      ),
      body: snapshot.when(
        data: (data) => _buildContent(context, ref, data),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('分析データを計算中...'),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('分析データの読み込みに失敗しました'),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(analyticsSnapshotProvider);
                  },
                  child: const Text('再度お試しください'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AnalyticsSnapshot data,
  ) {
    // 分析ダッシュボード表示イベントを記録
    Future.microtask(() {
      final user = ref.read(userControllerProvider).valueOrNull;
      final categories =
          user?.licenseCategories.join(',') ?? 'unknown';
      ref.read(analyticsServiceProvider).logEvent(
            AnalyticsEvents.analyticsDashboardOpened,
            parameters: {'license_category': categories},
          );
    });

    // データ不足の場合の案内
    if (data.overall.attempts < 10) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                '分析データが不足しています',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'あと${10 - data.overall.attempts}問で分析が表示されます。\nもう少し学習を進めてください！',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('ホームに戻る'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(analyticsSnapshotProvider.notifier)
            .refresh(force: true);
      },
      child: CustomScrollView(
        slivers: [
          // 期間フィルター
          SliverToBoxAdapter(
            child: PeriodFilterSelector(),
          ),

          // 全体統計カード
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: OverallSummaryCard(snapshot: data),
            ),
          ),

          // ステージ別パフォーマンス
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '段階別',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  AccuracyBarList(
                    items: data.stages
                        .map((s) => AccuracyBarItem(
                          label: s.stageTag,
                          accuracy: s.stat.accuracy,
                          attempts: s.stat.attempts,
                          correctCount: s.stat.correctCount,
                        ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 20)),

          // カテゴリ別パフォーマンス
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '区分別',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '※複数区分に該当する問題があるため、\n合計は全問題数と異なる場合があります',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AccuracyBarList(
                    items: data.categories
                        .map((c) => AccuracyBarItem(
                          label: c.categoryId,
                          accuracy: c.stat.accuracy,
                          attempts: c.stat.attempts,
                          correctCount: c.stat.correctCount,
                        ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 24)),

          // 弱点一覧
          if (data.weakAreas.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '弱点TOP${data.weakAreas.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

          if (data.weakAreas.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: data.weakAreas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final weakArea = data.weakAreas[index];
                  return WeakAreaCard(weakArea: weakArea);
                },
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(top: 24)),

          // 復習推奨
          if (data.recommendations.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'おすすめ復習',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),

          if (data.recommendations.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              sliver: SliverList.separated(
                itemCount: data.recommendations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final rec = data.recommendations[index];
                  return ReviewRecommendationCard(recommendation: rec);
                },
              ),
            ),

          // 下部余白
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }
}
