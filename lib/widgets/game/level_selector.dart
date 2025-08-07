import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_game/controllers/game_controller.dart';
import '../../providers/level_providers.dart';

class LevelSelector extends ConsumerWidget {
  const LevelSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedLevels = ref.watch(completedLevelsProvider);
    final currentLevel = ref.watch(levelProvider);
    final theme = Theme.of(context);

    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: List.generate(3, (index) {
          final level = index + 1;
          final isUnlocked = completedLevels.contains(level);
          final isCurrent = currentLevel == level;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: isUnlocked
                  ? () {
                      ref.read(levelProvider.notifier).state = level;
                      ref
                          .read(gameControllerProvider.notifier)
                          .switchLevel(level);
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isCurrent ? 100 : 80,
                height: isCurrent ? 100 : 80,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? theme.colorScheme.primary
                      : isUnlocked
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (isCurrent)
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                  ],
                  border: Border.all(
                    color: isCurrent
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.outline,
                    width: isCurrent ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isUnlocked ? Icons.star : Icons.lock,
                      color: isCurrent
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      size: isCurrent ? 24 : 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level $level',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isCurrent
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
