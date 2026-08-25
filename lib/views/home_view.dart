import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/license_category.dart';
import '../viewmodels/providers.dart';
import '../widgets/pass_prediction_meter.dart';
import 'analytics_dashboard_view.dart';
import 'bike_unlock_view.dart';
import 'daily_quota_view.dart';
import 'exam_date_setting_view.dart';
import 'settings_view.dart';
import 'trap_dojo_view.dart';

/// ホーム画面：合格予測メーター／今日のノルマ／バイク解放進捗／ひっかけ道場入口。
/// ホーム→ノルマ→正誤演出＝3タップ以内でAhaに到達する動線の起点。
class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userControllerProvider);
    final scoreAsync = ref.watch(savedPredictionScoreProvider);
    final answerLogsAsync = ref.watch(answerLogsProvider);
    final bikeProgressAsync = ref.watch(bikeUnlockControllerProvider);

    final user = userAsync.valueOrNull;
    final primaryCategoryId = user?.licenseCategories.isNotEmpty == true
        ? user!.licenseCategories.first
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('原付・バイク免許コレ！'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsView()),
            ),
          ),
        ],
      ),
      body: userAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(savedPredictionScoreProvider);
                ref.invalidate(answerLogsProvider);
              },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (primaryCategoryId == null)
                    _NoCategoryCard(context: context)
                  else ...[
                    PassPredictionMeter(
                      score: scoreAsync.valueOrNull,
                      answeredCount: answerLogsAsync.valueOrNull?.length ?? 0,
                    ),
                    const SizedBox(height: 16),
                    _ExamCountdownCard(examDate: user?.examDate),
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.checklist_rtl, size: 32),
                        title: Text(
                          '今日のノルマ（${LicenseCategory.fromId(primaryCategoryId).label}）',
                        ),
                        subtitle: const Text('無料版は1日10問まで'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                DailyQuotaView(licenseCategory: primaryCategoryId),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.sports_martial_arts, size: 32),
                        title: const Text('ひっかけ道場'),
                        subtitle: const Text('誤答はボス化して再挑戦キューへ'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                TrapDojoView(licenseCategory: primaryCategoryId),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    bikeProgressAsync.when(
                      data: (progress) {
                        final unlockedCount =
                            progress.where((p) => p.isUnlocked).length;
                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: const Icon(Icons.two_wheeler, size: 32),
                            title: const Text('バイク解放'),
                            subtitle: Text('$unlockedCount / ${progress.length} 台解放中'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const BikeUnlockView(),
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(Icons.insights, size: 32),
                        title: const Text('学習分析'),
                        subtitle: const Text('弱点と伸びを確認'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsDashboardView(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _NoCategoryCard extends StatelessWidget {
  const _NoCategoryCard({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('免許区分が未設定です。設定から選んでください。'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsView()),
              ),
              child: const Text('区分を設定する'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamCountdownCard extends StatelessWidget {
  const _ExamCountdownCard({required this.examDate});
  final DateTime? examDate;

  @override
  Widget build(BuildContext context) {
    if (examDate == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.event_available),
          title: const Text('試験日を登録すると逆算ノルマを自動計算します'),
          trailing: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ExamDateSettingView(),
              ),
            ),
            child: const Text('設定'),
          ),
        ),
      );
    }
    final daysLeft = examDate!.difference(DateTime.now()).inDays;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event_available),
        title: Text('試験日まであと$daysLeft日'),
        subtitle: const Text('残日数÷未習得問題数でノルマを逆算しています'),
      ),
    );
  }
}
