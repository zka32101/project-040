import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/license_category.dart';
import '../models/user.dart';
import '../viewmodels/providers.dart';
import 'exam_date_setting_view.dart';

/// 免許区分選択（複数選択可）。
///
/// 【差別化の重心】表示順は普通二輪・大型二輪を先頭に置き、原付は
/// 入口として残しつつ主役にしない（企画設計書 v1.1）。
/// 無料枠は区分1つまで。2つ目以降を選ぶとペイウォールへ誘導する。
class LicenseCategorySelectView extends ConsumerStatefulWidget {
  const LicenseCategorySelectView({super.key});

  @override
  ConsumerState<LicenseCategorySelectView> createState() =>
      _LicenseCategorySelectViewState();
}

class _LicenseCategorySelectViewState
    extends ConsumerState<LicenseCategorySelectView> {
  final Set<LicenseCategory> _selected = {};

  static const _displayOrder = [
    LicenseCategory.futsuuNirin,
    LicenseCategory.ogataNirin,
    LicenseCategory.atGentei,
    LicenseCategory.kogataGentsukiNirin,
    LicenseCategory.gentsuki,
  ];

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userControllerProvider);
    final isFree = userAsync.valueOrNull?.purchaseStatus == PurchaseStatus.free;

    return Scaffold(
      appBar: AppBar(title: const Text('免許区分を選ぶ')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今、対策したい免許区分を選んでください（複数選択可）',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (isFree)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '無料版では1区分まで対策できます。2区分目以降はパスが必要です。',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  for (final category in _displayOrder)
                    _CategoryTile(
                      category: category,
                      selected: _selected.contains(category),
                      onChanged: (checked) {
                        setState(() {
                          if (checked) {
                            _selected.add(category);
                          } else {
                            _selected.remove(category);
                          }
                        });
                      },
                    ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () async {
                        await ref
                            .read(userControllerProvider.notifier)
                            .setLicenseCategories(
                              _selected.map((e) => e.name).toList(),
                            );
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ExamDateSettingView(
                                isOnboardingFlow: true,
                              ),
                            ),
                          );
                        }
                      },
                child: const Text('次へ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onChanged,
  });

  final LicenseCategory category;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: CheckboxListTile(
        value: selected,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(category.label),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
