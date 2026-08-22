import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pass_prediction_score.dart';
import '../viewmodels/providers.dart';
import '../widgets/answer_result_overlay.dart';
import '../widgets/pass_prediction_meter.dart';
import 'paywall_view.dart';

/// 出題(区分×段階フィルタ済み) → 正誤演出 → 3問クリアで合格予測メーター
/// 初表示（Aha Moment）→ペイウォール導線、までを担う画面。
///
/// 【広告制御・厳守】このView表示中は AdGateService が
/// AdBlockingContext.answeringQuestion を保持しており、
/// 広告は一切表示されない（実装引き継ぎ書 固有事項）。
class DailyQuotaView extends ConsumerWidget {
  const DailyQuotaView({super.key, required this.licenseCategory});

  final String licenseCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyQuotaControllerProvider(licenseCategory));
    final controller =
        ref.read(dailyQuotaControllerProvider(licenseCategory).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('今日のノルマ')),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.questions.isEmpty
              ? const Center(child: Text('この区分の問題がまだありません'))
              : Stack(
                  children: [
                    if (state.isQuotaCompleted)
                      _QuotaCompletedView(
                        correctCount: state.correctCount,
                        total: state.questions.length,
                      )
                    else ...[
                      _QuestionBody(state: state, controller: controller),
                      if (state.lastResult != AnswerResult.none)
                        // Aha Moment（初回3問正解の瞬間）は合格予測メーターを
                        // 表示する専用シートを、通常の正誤演出の代わりに出す。
                        state.ahaMomentShown && state.correctCount == 3
                            ? _AhaMomentSheet(
                                score: state.predictionScore,
                                onContinue: controller.advanceToNextQuestion,
                              )
                            : _QuestionResultLayer(
                                state: state,
                                controller: controller,
                              ),
                    ],
                  ],
                ),
    );
  }
}

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({required this.state, required this.controller});

  final DailyQuotaState state;
  final DailyQuotaController controller;

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion!;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: state.currentIndex / state.questions.length,
          ),
          const SizedBox(height: 8),
          Text('${state.currentIndex + 1} / ${state.questions.length}問'),
          const SizedBox(height: 20),
          Text(question.questionText, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: question.choices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: state.lastResult == AnswerResult.none
                        ? () => controller.answer(i)
                        : null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(question.choices[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 正誤演出＋次の問題へ（Aha Momentが同時に発生するタイミングはこの上に重ねて表示）。
class _QuestionResultLayer extends StatelessWidget {
  const _QuestionResultLayer({required this.state, required this.controller});

  final DailyQuotaState state;
  final DailyQuotaController controller;

  @override
  Widget build(BuildContext context) {
    final question = state.currentQuestion!;
    return AnswerResultOverlay(
      isCorrect: state.lastResult == AnswerResult.correct,
      explanation: question.explanation,
      onNext: controller.advanceToNextQuestion,
    );
  }
}

class _AhaMomentSheet extends StatelessWidget {
  const _AhaMomentSheet({required this.score, required this.onContinue});

  final PassPredictionScore? score;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🎉 3問正解！',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            PassPredictionMeter(score: score, answeredCount: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                child: const Text('続ける'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaywallView()),
              ),
              child: const Text(
                '広告なしで続けるプランを見る',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuotaCompletedView extends ConsumerWidget {
  const _QuotaCompletedView({required this.correctCount, required this.total});

  final int correctCount;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 【広告制御】ノルマ完走後の結果画面でのみインタースティシャル対象
    // （実際の広告SDK呼び出しはSDK導入時に canShowInterstitial を確認して行う）。
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 72, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              '今日のノルマ完走！',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('$correctCount / $total 問正解'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ホームに戻る'),
            ),
          ],
        ),
      ),
    );
  }
}
