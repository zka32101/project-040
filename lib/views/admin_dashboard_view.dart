import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/report_model.dart';
import '../viewmodels/providers.dart';

/// 管理者ダッシュボードビュー
/// 教師・管理者向けのクラス管理・分析ツール
class AdminDashboardView extends ConsumerStatefulWidget {
  const AdminDashboardView({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboardView> createState() =>
      _AdminDashboardViewState();
}

class _AdminDashboardViewState extends ConsumerState<AdminDashboardView> {
  late String selectedClassId = 'class_001';
  late String selectedClassName = 'Biology 101';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理者ダッシュボード'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'export',
                child: Text('データをエクスポート'),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Text('レポート生成'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('設定'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // クラス選択
            _buildClassSelector(),

            const SizedBox(height: 24),

            // クラス統計カード
            _buildClassStatsCards(),

            const SizedBox(height: 24),

            // 学生成績分布
            _buildScoreDistribution(),

            const SizedBox(height: 24),

            // 成績上位学生
            _buildTopPerformers(),

            const SizedBox(height: 24),

            // 支援が必要な学生
            _buildStudentsNeedingSupport(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSelector() {
    return Card(
      elevation: 2,
      child: ListTile(
        title: const Text('クラス選択'),
        subtitle: Text(selectedClassName),
        trailing: const Icon(Icons.arrow_drop_down),
        onTap: _showClassSelector,
      ),
    );
  }

  Widget _buildClassStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'クラス統計',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              title: '総学生数',
              value: '28',
              color: Colors.blue,
            ),
            _buildStatCard(
              title: '平均成績',
              value: '75.2%',
              color: Colors.green,
            ),
            _buildStatCard(
              title: 'アクティブ学生',
              value: '24',
              color: Colors.orange,
            ),
            _buildStatCard(
              title: '合格見込み',
              value: '22',
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDistribution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '成績分布',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildScoreBar('90-100点', 8, Colors.green),
                const SizedBox(height: 12),
                _buildScoreBar('80-89点', 10, Colors.lightGreen),
                const SizedBox(height: 12),
                _buildScoreBar('70-79点', 6, Colors.orange),
                const SizedBox(height: 12),
                _buildScoreBar('60-69点', 3, Colors.red),
                const SizedBox(height: 12),
                _buildScoreBar('0-59点', 1, Colors.darkRed),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBar(String label, int count, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: count / 28,
              minHeight: 20,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 30,
          child: Text(
            count.toString(),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildTopPerformers() {
    final topStudents = [
      {'name': '田中太郎', 'score': 95},
      {'name': '山田花子', 'score': 92},
      {'name': '鈴木次郎', 'score': 88},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '成績上位学生',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topStudents.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final student = topStudents[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(student['name'] as String),
                trailing: Text(
                  '${student['score']}%',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsNeedingSupport() {
    final needsSupport = [
      {'name': '佐藤太郎', 'score': 45},
      {'name': '中村次郎', 'score': 38},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '支援が必要な学生',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.red.withOpacity(0.05),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: needsSupport.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final student = needsSupport[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red,
                  child: const Icon(
                    Icons.warning,
                    color: Colors.white,
                  ),
                ),
                title: Text(student['name'] as String),
                subtitle: const Text('サポートが必要です'),
                trailing: Text(
                  '${student['score']}%',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  // TODO: Show support options
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showClassSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('クラスを選択'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('Biology 101'),
                onTap: () {
                  setState(() {
                    selectedClassId = 'class_001';
                    selectedClassName = 'Biology 101';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Chemistry 202'),
                onTap: () {
                  setState(() {
                    selectedClassId = 'class_002';
                    selectedClassName = 'Chemistry 202';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'export':
        Navigator.of(context).pushNamed('/export');
        break;
      case 'report':
        Navigator.of(context).pushNamed('/report-generator');
        break;
      case 'settings':
        Navigator.of(context).pushNamed('/settings');
        break;
    }
  }
}
