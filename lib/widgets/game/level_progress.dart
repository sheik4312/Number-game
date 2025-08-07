import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/level_providers.dart';

class LevelProgress extends ConsumerWidget {
  const LevelProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedLevels = ref.watch(completedLevelsProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: List.generate(3, (index) {
          final level = index + 1;
          final isCompleted = completedLevels.contains(level);
          final isLast = index == 2;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                if (!isLast) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }
}
