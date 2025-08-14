import 'package:flutter/material.dart';
import 'package:number_game/models/game_tile.dart';

class TileWidget extends StatefulWidget {
  final GameTile tile;
  final bool isInvalidSelection;
  final VoidCallback? onTap;

  /// Column index used to stagger the entry animation (left → right shockwave)
  final int columnIndex;

  const TileWidget({
    super.key,
    required this.tile,
    this.isInvalidSelection = false,
    this.onTap,
    this.columnIndex = 0, // <- default so older calls still compile
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  // For shake animation on invalid selection
  final _shakeKey = GlobalKey<ShakeWidgetState>();

  // Entry (shock) animation
  late AnimationController _appearController;
  late Animation<double> _appearScale;
  late Animation<double> _appearOpacity;

  @override
  void initState() {
    super.initState();

    // Entry animation controller
    _appearController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _appearScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _appearController, curve: Curves.easeOutBack),
    );
    _appearOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _appearController, curve: Curves.easeOut),
    );

    // Stagger start based on column index → creates left-to-right “shock”
    Future.delayed(Duration(milliseconds: widget.columnIndex * 80), () {
      if (mounted) _appearController.forward();
    });
  }

  @override
  void didUpdateWidget(covariant TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger shake when invalid flag flips to true
    if (widget.isInvalidSelection && !oldWidget.isInvalidSelection) {
      _shakeKey.currentState?.shake();
    }
  }

  @override
  void dispose() {
    _appearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final faded = widget.tile.isMatched;
    final selected = widget.tile.isSelected;

    return GestureDetector(
      onTap: widget.onTap,
      child: FadeTransition(
        opacity: _appearOpacity,
        child: ScaleTransition(
          scale: _appearScale,
          child: ShakeWidget(
            key: _shakeKey,
            child: Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.yellow[200]
                    : (faded ? Colors.grey[300] : Colors.white),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? Colors.orange
                      : (widget.isInvalidSelection
                            ? Colors.red
                            : Colors.black12),
                  width: widget.isInvalidSelection ? 3.0 : 2.5,
                ),
                boxShadow: widget.isInvalidSelection
                    ? [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.tile.value.toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: faded
                          ? Colors.grey
                          : (widget.isInvalidSelection
                                ? Colors.red[800]
                                : Colors.black),
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Shake animation widget for invalid selections
class ShakeWidget extends StatefulWidget {
  final Widget child;

  const ShakeWidget({super.key, required this.child});

  @override
  ShakeWidgetState createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void shake() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: child,
        );
      },
    );
  }
}
