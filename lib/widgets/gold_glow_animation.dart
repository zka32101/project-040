import 'dart:math' as math;

import 'package:flutter/material.dart';

/// バイク解放時のゴールド光演出アニメーション。
/// 金色のグロー効果とパルスアニメーション。
class GoldGlowAnimation extends StatefulWidget {
  const GoldGlowAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.maxBlur = 20.0,
  });

  final Widget child;
  final Duration duration;
  final double maxBlur;

  @override
  State<GoldGlowAnimation> createState() => _GoldGlowAnimationState();
}

class _GoldGlowAnimationState extends State<GoldGlowAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowIntensity = ((_glowAnimation.value * 2 - 1).abs() - 0.5).abs() * 2;
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withAlpha((255 * 0.6 * glowIntensity).toInt()),
                blurRadius: widget.maxBlur * glowIntensity,
                spreadRadius: 4 * glowIntensity,
              ),
              BoxShadow(
                color: Colors.yellow.withAlpha((255 * 0.3 * glowIntensity).toInt()),
                blurRadius: widget.maxBlur * 0.5 * glowIntensity,
                spreadRadius: 2 * glowIntensity,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// スターバーストアニメーション（バイク解放時のスター演出）。
class StarBurstAnimation extends StatefulWidget {
  const StarBurstAnimation({
    super.key,
    this.duration = const Duration(milliseconds: 2000),
  });

  final Duration duration;

  @override
  State<StarBurstAnimation> createState() => _StarBurstAnimationState();
}

class _StarBurstAnimationState extends State<StarBurstAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(8, (index) {
        final angle = (index / 8) * 2 * math.pi;
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final distance = _controller.value * 100.0;
            final opacity = (1.0 - _controller.value).clamp(0.0, 1.0);
            final offsetX = distance * math.cos(angle);
            final offsetY = distance * math.sin(angle);

            return Positioned(
              left: 50.0 + offsetX - 12.0,
              top: 50.0 + offsetY - 12.0,
              child: Opacity(
                opacity: opacity,
                child: const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
