import 'package:flutter/material.dart';
import 'package:number_game/models/game_tile.dart';

class TileContent extends StatefulWidget {
  final GameTile tile;
  final Animation<double> matchScaleAnimation;
  final Animation<double> matchOpacityAnimation;

  /// The column index for wave animation delay
  final int columnIndex;

  const TileContent({
    super.key,
    required this.tile,
    required this.matchScaleAnimation,
    required this.matchOpacityAnimation,
    required this.columnIndex,
  });

  @override
  State<TileContent> createState() => _TileContentState();
}

class _TileContentState extends State<TileContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveScale;
  late Animation<double> _waveOpacity;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _waveScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.elasticOut),
    );

    _waveOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.easeOut));

    // Start the animation with delay based on column index
    Future.delayed(Duration(milliseconds: widget.columnIndex * 80), () {
      if (mounted) _waveController.forward();
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = _getBaseColor(widget.tile);
    final isSelected = widget.tile.isSelected;
    final isMatched = widget.tile.isMatched;

    return ScaleTransition(
      scale: _waveScale,
      child: FadeTransition(
        opacity: _waveOpacity,
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // New gradient with depth effect
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _adjustColor(baseColor, 20), // Lighter top
                baseColor, // Base color
                _adjustColor(baseColor, -30), // Darker bottom
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            // Enhanced border
            border: Border.all(
              color: isSelected
                  ? Colors.amber.shade300
                  : Colors.white.withOpacity(0.6),
              width: isSelected ? 2.0 : 1.5,
            ),
            // Enhanced shadows
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
              if (isSelected && !isMatched)
                BoxShadow(
                  color: Colors.amber.withOpacity(0.8),
                  blurRadius: 16,
                  spreadRadius: 3,
                ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedOpacity(
                opacity: isMatched ? 0.4 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Text(
                    '${widget.tile.value}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (isMatched)
                FadeTransition(
                  opacity: widget.matchOpacityAnimation,
                  child: ScaleTransition(
                    scale: widget.matchScaleAnimation,
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 36,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),

              if (isSelected && !isMatched)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.star,
                    size: 18,
                    color: Colors.amber.shade200,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBaseColor(GameTile tile) {
    if (tile.isMatched) return const Color(0xFF4CAF50); // Vibrant green
    if (tile.isSelected) return const Color(0xFFFFC107); // Amber
    return const Color(0xFF2196F3); // Primary blue
  }

  Color _adjustColor(Color color, int amount) {
    return Color.fromARGB(
      color.alpha,
      _clamp(color.red + amount),
      _clamp(color.green + amount),
      _clamp(color.blue + amount),
    );
  }

  int _clamp(int value) {
    return value.clamp(0, 255);
  }
}
