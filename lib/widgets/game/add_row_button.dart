import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_game/controllers/game_controller.dart';
import '../../providers/game_providers.dart';

class AddRowButton extends ConsumerWidget {
  const AddRowButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: ref.watch(buttonAnimationControllerProvider),
        curve: Curves.easeInOut,
      ),
    );

    return ScaleTransition(
      scale: animation,
      child: FloatingActionButton.extended(
        onPressed: () =>
            ref.read(gameControllerProvider.notifier).addRowBelow(),
        icon: const Icon(Icons.add),
        label: const Text('Add Row'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4,
      ),
    );
  }
}
