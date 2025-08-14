import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_game/controllers/game_controller.dart';
import 'package:number_game/models/game_tile.dart';
import 'package:number_game/widgets/game/tile/tile_widget.dart';

class GameGrid extends ConsumerWidget {
  const GameGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiles = ref.watch(gameControllerProvider);
    final theme = Theme.of(context);

    const columns = 9;
    const int maxVisibleRows = 30; // change as needed for your "unlimited" feel
    final int minItemCount = columns * maxVisibleRows;

    // Pad with empty tiles
    final List<GameTile?> paddedTiles = [
      ...tiles,
      ...List<GameTile?>.filled(
        (minItemCount - tiles.length).clamp(0, double.infinity).toInt(),
        null,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: paddedTiles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final tile = paddedTiles[index];
          final columnIndex = index % columns;

          if (tile == null) {
            // Blank white placeholder tile
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }

          return GestureDetector(
            onTap: () {
              ref.read(gameControllerProvider.notifier).onTileTap(tile.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  if (tile.isSelected)
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 6,
                    ),
                ],
                color: tile.isSelected
                    ? theme.colorScheme.primary.withOpacity(0.2)
                    : theme.colorScheme.surface,
              ),
              child: TileWidget(
                tile: tile,
                isInvalidSelection: tile.isInvalid,
                columnIndex: columnIndex,
              ),
            ),
          );
        },
      ),
    );
  }
}
