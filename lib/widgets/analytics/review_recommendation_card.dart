import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/analytics_events.dart';
import '../../models/analytics_snapshot.dart';
import '../../viewmodels/providers.dart';
import '../../views/daily_quota_view.dart';
import '../../views/trap_dojo_view.dart';

/// 復習推奨カード
/// ユーザーの弱点に基づいた復習アクションを提案
class ReviewRecommendationCard extends ConsumerWidget {
  const ReviewRecommendationCard({
    super.key,
    required this.recommendation,
  });

  final ReviewRecommendation recommendation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildIconForAction(recommendation.action),
        title: Text(
          recommendation.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            recommendation.body,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.outline,
        ),
        onTap: () => _handleActionTap(context, ref, recommendation),
      ),
    );
  }

  /// アクションタイプに応じたアイコンを生成
  Widget _buildIconForAction(ReviewActionType action) {
    IconData iconData;
    Color color;

    switch (action) {
      case ReviewActionType.dailyQuota:
        iconData = Icons.quiz;
        color = Colors.blue;
        break;
      case ReviewActionType.trapDojo:
        iconData = Icons.school;
        color = Colors.purple;
        break;
      case ReviewActionType.stageDrill:
        iconData = Icons.trending_up;
        color = Colors.green;
        break;
      case ReviewActionType.masteryReview:
        iconData = Icons.bookmark;
        color = Colors.amber;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color),
    );
  }

  /// アクションタップ時の処理
  void _handleActionTap(
    BuildContext context,
    WidgetRef ref,
    ReviewRecommendation recommendation,
  ) {
    // 弱点復習開始イベントを記録
    final weakAreaKind = recommendation.payload['weakAreaKind'] ?? 'unknown';
    ref.read(analyticsServiceProvider).logEvent(
          AnalyticsEvents.weakAreaReviewStarted,
          parameters: {
            'weak_area_kind': weakAreaKind,
            'action_type': recommendation.action.name,
          },
        );

    switch (recommendation.action) {
      case ReviewActionType.dailyQuota:
        // 日々のノルマに遷移
        final licenseCategory =
            recommendation.payload['licenseCategory'] ?? 'futsuuNirin';
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DailyQuotaView(licenseCategory: licenseCategory),
          ),
        );
        break;

      case ReviewActionType.trapDojo:
        // ひっかけ道場に遷移
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const TrapDojoView(),
          ),
        );
        break;

      case ReviewActionType.stageDrill:
        // ステージドリル（現在は通常の日々のノルマにフォールバック）
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const DailyQuotaView(licenseCategory: 'futsuuNirin'),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ステージドリルは準備中です。通常の学習を進めてください。'),
            duration: Duration(seconds: 2),
          ),
        );
        break;

      case ReviewActionType.masteryReview:
        // 復習（ホームに戻る）
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('このテーマについて、詳しく学習してみましょう。'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
        break;
    }
  }
}
