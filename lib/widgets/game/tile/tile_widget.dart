import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/game_controller.dart';
import '../../../models/game_tile.dart';
import 'tile_animations.dart';
import 'tile_content.dart';

class TileWidget extends ConsumerStatefulWidget {
  final GameTile tile;

  const TileWidget({
    super.key,
    required this.tile,
    required void Function() onTap,
  });

  @override
  ConsumerState<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends ConsumerState<TileWidget>
    with TickerProviderStateMixin {
  late TileAnimations _animations;

  @override
  void initState() {
    super.initState();
    _animations = TileAnimations(this);
  }

  @override
  void didUpdateWidget(TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tile.isMatched && !oldWidget.tile.isMatched) {
      _animations.matchController.forward();
    }
  }

  @override
  void dispose() {
    _animations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tile = widget.tile;

    return GestureDetector(
      onTap: () {
        ref.read(gameControllerProvider.notifier).onTileTap(tile.id);

        if (tile.isMatched) {
          _animations.scaleController.forward();
        } else if (!tile.isSelected) {
          _animations.shakeController.forward();
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _animations.shakeController,
          _animations.scaleController,
          _animations.matchController,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_animations.shakeAnimation.value, 0),
            child: Transform.scale(
              scale: _animations.scaleAnimation.value,
              child: TileContent(
                tile: tile,
                matchScaleAnimation: _animations.matchScaleAnimation,
                matchOpacityAnimation: _animations.matchOpacityAnimation,
              ),
            ),
          );
        },
      ),
    );
  }
}
