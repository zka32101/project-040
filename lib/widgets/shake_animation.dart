import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 不正解時のシェイクアニメーション演出。
/// Lottieまたはカスタム Transform アニメーションで実装。
class ShakeAnimation extends StatefulWidget {
  const ShakeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.intensity = 10.0,
    this.onComplete,
  });

  final Widget child;
  final Duration duration;
  final double intensity;
  final VoidCallback? onComplete;

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        // Shake pattern: oscillate left and right
        final shake = _calculateShakeOffset(_shakeAnimation.value);
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  double _calculateShakeOffset(double progress) {
    // Create a shake pattern using sine wave
    // 3 shakes during the animation
    const shakes = 3;
    final shakeAngle = progress * shakes * 2 * math.pi; // 2π for full oscillation
    return (math.sin(shakeAngle) * widget.intensity) * (1 - progress); // Fade out shake
  }
}
