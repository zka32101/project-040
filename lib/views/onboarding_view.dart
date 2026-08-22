import 'package:flutter/material.dart';

import 'license_category_select_view.dart';

const _slides = [
  (
    title: '免許区分に迷わない',
    body: '原付〜大型二輪まで、自分の区分だけを的確に勉強できます',
  ),
  (
    title: '二輪特有のひっかけを潰す',
    body: '二人乗り条件・積載制限・二段階右折…間違えやすい数字を道場で反復',
  ),
  (
    title: '飽きずに続けられる',
    body: '合格予測メーター・バイク解放で、勉強がコレクションになる',
  ),
];

/// 起動 → オンボーディング(3枚) → 免許区分選択 の入口画面。
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _controller = PageController();
  int _page = 0;

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LicenseCategorySelectView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.two_wheeler_rounded,
                          size: 96,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          slide.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.body,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(_page == _slides.length - 1 ? 'はじめる' : '次へ'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
