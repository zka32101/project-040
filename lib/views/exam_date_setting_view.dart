import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/providers.dart';
import 'home_view.dart';

/// 教習段階入力(任意・スキップ可) ＋ 試験日設定。
/// 逆算ノルマ = 残日数 ÷ 未習得問題数（実装は HomeView 側の集計で行う）。
class ExamDateSettingView extends ConsumerStatefulWidget {
  const ExamDateSettingView({super.key, this.isOnboardingFlow = false});

  /// 初回オンボーディング経由かどうか（trueならHomeへ、falseなら戻るだけ）。
  final bool isOnboardingFlow;

  @override
  ConsumerState<ExamDateSettingView> createState() =>
      _ExamDateSettingViewState();
}

class _ExamDateSettingViewState extends ConsumerState<ExamDateSettingView> {
  DateTime? _examDate;
  String? _trainingStage;

  static const _stages = ['第一段階', '第二段階', '卒業検定前', '未定'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('教習の状況（任意）')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('今の教習段階', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final stage in _stages)
                  ChoiceChip(
                    label: Text(stage),
                    selected: _trainingStage == stage,
                    onSelected: (_) => setState(() => _trainingStage = stage),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('試験・検定日（任意）', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.event),
              label: Text(
                _examDate == null
                    ? '日付を選ぶ'
                    : '${_examDate!.year}/${_examDate!.month}/${_examDate!.day}',
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 14)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _examDate = picked);
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final notifier = ref.read(userControllerProvider.notifier);
                  if (_trainingStage != null) {
                    await notifier.setTrainingStage(_trainingStage);
                  }
                  if (_examDate != null) {
                    await notifier.setExamDate(_examDate);
                  }
                  if (!context.mounted) return;
                  if (widget.isOnboardingFlow) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeView()),
                      (route) => false,
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('保存してホームへ'),
              ),
            ),
            TextButton(
              onPressed: () {
                if (widget.isOnboardingFlow) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomeView()),
                    (route) => false,
                  );
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('あとで設定する'),
            ),
          ],
        ),
      ),
    );
  }
}
