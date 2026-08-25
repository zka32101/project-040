import 'package:flutter/material.dart';

import 'confetti_animation.dart';
import 'shake_animation.dart';

/// 正誤演出。
/// 正解=紙吹雪風演出／不正解=シェイク（Step5.5 A.ビジュアル）。
/// Lottieを活用したアニメーション実装。
class AnswerResultOverlay extends StatefulWidget {
  const AnswerResultOverlay({
    super.key,
    required this.isCorrect,
    required this.explanation,
    required this.onNext,
  });

  final bool isCorrect;
  final String explanation;
  final VoidCallback onNext;

  @override
  State<AnswerResultOverlay> createState() => _AnswerResultOverlayState();
}

class _AnswerResultOverlayState extends State<AnswerResultOverlay> {
  void _onAnimationComplete() {
    // Animation complete - could be used for additional feedback if needed
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isCorrect ? Colors.green : Theme.of(context).colorScheme.error;

    // コンテンツ部分
    final content = Card(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.isCorrect ? Icons.check_circle : Icons.cancel,
              color: color,
              size: 64,
            ),
            const SizedBox(height: 12),
            Text(
              widget.isCorrect ? '正解！' : '不正解',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            if (widget.explanation.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(widget.explanation, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onNext,
                child: const Text('次へ'),
              ),
            ),
          ],
        ),
      ),
    );

    // 不正解時はシェイクアニメーション、正解時は紙吹雪
    final animatedContent = widget.isCorrect
        ? Stack(
            children: [
              content,
              ConfettiAnimation(
                duration: const Duration(milliseconds: 2000),
                onComplete: _onAnimationComplete,
              ),
            ],
          )
        : ShakeAnimation(
            duration: const Duration(milliseconds: 500),
            intensity: 12.0,
            onComplete: _onAnimationComplete,
            child: content,
          );

    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: animatedContent,
    );
  }
}
