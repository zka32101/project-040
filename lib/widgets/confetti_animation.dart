import 'package:flutter/material.dart';

/// 正解時の紙吹雪アニメーション演出。
/// Lottie JSON またはカスタムアニメーションで実装。
class ConfettiAnimation extends StatefulWidget {
  const ConfettiAnimation({
    super.key,
    this.duration = const Duration(milliseconds: 2000),
    this.onComplete,
  });

  final Duration duration;
  final VoidCallback? onComplete;

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Confetti> _confetti = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _initializeConfetti();
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  void _initializeConfetti() {
    final random = DateTime.now().microsecondsSinceEpoch % 100;
    _confetti = List.generate(30, (index) {
      return _Confetti(
        startX: (random + index * 7) % 100 / 100,
        startY: -0.1,
        endY: 1.2,
        duration: widget.duration,
        delay: Duration(milliseconds: index * 30),
        rotation: (random * (index + 1)) % 360 * 10,
        color: [Colors.yellow, Colors.blue, Colors.green, Colors.red, Colors.purple]
            [(random + index) % 5],
        size: 8 + (random + index) % 8,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _confetti.map((conf) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = (_controller.value * 1000 - conf.delay.inMilliseconds)
                .clamp(0.0, 1000.0) /
                1000.0;
            if (progress < 0 || progress > 1) {
              return const SizedBox.shrink();
            }

            return Positioned(
              left: MediaQuery.of(context).size.width * conf.startX +
                  progress * 20 - 10,
              top: MediaQuery.of(context).size.height * (conf.startY + progress * (conf.endY - conf.startY)),
              child: Transform.rotate(
                angle: (conf.rotation * progress) * 3.14159 / 180,
                child: Container(
                  width: conf.size,
                  height: conf.size,
                  decoration: BoxDecoration(
                    color: conf.color.withAlpha((255 * (1 - progress).clamp(0, 1)).toInt()),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class _Confetti {
  final double startX;
  final double startY;
  final double endY;
  final Duration duration;
  final Duration delay;
  final double rotation;
  final Color color;
  final double size;

  _Confetti({
    required this.startX,
    required this.startY,
    required this.endY,
    required this.duration,
    required this.delay,
    required this.rotation,
    required this.color,
    required this.size,
  });
}
