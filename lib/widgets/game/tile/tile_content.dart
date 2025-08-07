import 'package:flutter/material.dart';
import 'package:number_game/models/game_tile.dart';

class TileContent extends StatelessWidget {
  final GameTile tile;
  final Animation<double> matchScaleAnimation;
  final Animation<double> matchOpacityAnimation;

  const TileContent({
    super.key,
    required this.tile,
    required this.matchScaleAnimation,
    required this.matchOpacityAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = _getBaseColor(tile);

    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [baseColor.withOpacity(0.9), baseColor.withOpacity(0.7)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
          if (tile.isSelected)
            BoxShadow(
              color: Colors.amber.withOpacity(0.8),
              blurRadius: 12,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main tile content
          AnimatedOpacity(
            opacity: tile.isMatched ? 0.4 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Center(
              child: Text(
                '${tile.value}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 2,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Success checkmark
          if (tile.isMatched)
            FadeTransition(
              opacity: matchOpacityAnimation,
              child: ScaleTransition(
                scale: matchScaleAnimation,
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            ),

          // Selection indicator
          if (tile.isSelected && !tile.isMatched)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.star, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Color _getBaseColor(GameTile tile) {
    if (tile.isMatched) return Colors.green.shade600;
    if (tile.isSelected) return Colors.amber.shade600;
    return Colors.blue.shade600;
  }
}
