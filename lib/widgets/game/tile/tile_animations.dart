// tile_animations.dart

import 'package:flutter/material.dart';

class TileAnimations {
  final AnimationController shakeController;
  final Animation<double> shakeAnimation;

  final AnimationController scaleController;
  final Animation<double> scaleAnimation;

  final AnimationController matchController;
  final Animation<double> matchScaleAnimation;
  final Animation<double> matchOpacityAnimation;

  TileAnimations._({
    required this.shakeController,
    required this.shakeAnimation,
    required this.scaleController,
    required this.scaleAnimation,
    required this.matchController,
    required this.matchScaleAnimation,
    required this.matchOpacityAnimation,
  });

  factory TileAnimations(TickerProvider vsync) {
    final shakeCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: vsync,
    );

    final shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: shakeCtrl, curve: Curves.easeOut));

    final scaleCtrl = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );

    final scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.95), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: scaleCtrl, curve: Curves.easeOut));

    final matchCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: vsync,
    );

    final matchScaleAnim = CurvedAnimation(
      parent: matchCtrl,
      curve: Curves.elasticOut,
    );

    final matchOpacityAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: matchCtrl, curve: Curves.easeIn));

    return TileAnimations._(
      shakeController: shakeCtrl,
      shakeAnimation: shakeAnim,
      scaleController: scaleCtrl,
      scaleAnimation: scaleAnim,
      matchController: matchCtrl,
      matchScaleAnimation: matchScaleAnim,
      matchOpacityAnimation: matchOpacityAnim,
    );
  }

  void dispose() {
    shakeController.dispose();
    scaleController.dispose();
    matchController.dispose();
  }
}
