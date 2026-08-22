import 'package:flutter/material.dart';

/// 正誤演出。
/// 正解=紙吹雪風演出／不正解=シェイク（Step5.5 A.ビジュアル）。
/// Lottie導入までのプレースホルダとしてアイコン+アニメーションで実装。
class AnswerResultOverlay extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final color = isCorrect ? Colors.green : Theme.of(context).colorScheme.error;
    return Container(
      color: Colors.black54,
      alignment: Alignment.center,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: color,
                size: 64,
              ),
              const SizedBox(height: 12),
              Text(
                isCorrect ? '正解！' : '不正解',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
              if (explanation.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(explanation, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onNext,
                  child: const Text('次へ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
