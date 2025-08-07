import 'package:flutter/material.dart';
import '../../models/game_tile.dart';

class TileWidget extends StatefulWidget {
  final GameTile tile;
  final bool isInvalidSelection;

  const TileWidget({
    super.key,
    required this.tile,
    this.isInvalidSelection = false,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _flashController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.red.withOpacity(0.7),
    ).animate(CurvedAnimation(parent: _flashController, curve: Curves.easeOut));

    if (widget.isInvalidSelection) {
      _triggerFlash();
    }
  }

  @override
  void didUpdateWidget(covariant TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isInvalidSelection && !oldWidget.isInvalidSelection) {
      _triggerFlash();
    }
  }

  void _triggerFlash() {
    _flashController.reset();
    _flashController.forward();
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final faded = widget.tile.isMatched;
    final selected = widget.tile.isSelected;

    return AnimatedBuilder(
      animation: _flashController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _colorAnimation.value,
          ),
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.yellow[200]
              : (faded ? Colors.grey[300] : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Colors.orange : Colors.black12,
            width: 2.5,
          ),
        ),
        child: Center(
          child: Text(
            widget.tile.value.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: faded ? Colors.grey : Colors.black,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
