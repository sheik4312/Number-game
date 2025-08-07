import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_game/controllers/game_controller.dart';
import 'package:number_game/models/game_tile.dart';
import 'package:number_game/providers/timer_provider.dart';
import '../providers/game_providers.dart';
import '../providers/level_providers.dart';
import '../widgets/game/add_row_button.dart';
import '../widgets/game/game_grid.dart';
import '../widgets/game/level_progress.dart';
import '../widgets/game/level_selector.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  late AnimationController _buttonAnimationController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start timer after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        ref.read(gameTimerProvider.notifier).start();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;

    // 1. Dispose animation controller first
    _buttonAnimationController.dispose();

    // 2. Schedule timer stop to run after current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(gameTimerProvider.notifier).stop();
      }
    });

    // 3. Call super.dispose() last
    super.dispose();
  }

  Future<void> _showTimeUpDialog() async {
    if (_isDisposed) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Time Up!'),
        content: const Text('You failed to complete the level in time.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (!_isDisposed) {
                final currentLevel = ref.read(levelProvider);
                ref
                    .read(gameControllerProvider.notifier)
                    .restartWithLevel(currentLevel);
              }
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeLeft = ref.watch(gameTimerProvider);

    // Properly placed listeners inside build method
    ref.listen<int>(gameTimerProvider, (_, current) {
      if (current == 0 && !_isDisposed) {
        _showTimeUpDialog();
      }
    });

    ref.listen<List<GameTile>>(gameControllerProvider, (_, __) {
      final controller = ref.read(gameControllerProvider.notifier);

      controller.completedLevelsCallback = (level, [message]) {
        if (level == -1 && message != null) {
          // Show completion quote
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              elevation: 10,
            ),
          );
          return;
        }

        final current = ref.read(completedLevelsProvider);
        if (!current.contains(level)) {
          ref.read(completedLevelsProvider.notifier).state = [
            ...current,
            level,
          ];
        }

        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.emoji_events_rounded, color: Colors.amber),
                const SizedBox(width: 12),
                Text('Level $level Unlocked!'),
              ],
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            elevation: 10,
          ),
        );

        Future.delayed(const Duration(milliseconds: 800), () {
          ref.read(levelProvider.notifier).state = level;
          controller.switchLevel(level);
        });
      };
    });

    return WillPopScope(
      onWillPop: () async {
        ref.read(gameTimerProvider.notifier).stop();
        return true;
      },
      child: ProviderScope(
        overrides: [
          buttonAnimationControllerProvider.overrideWithValue(
            _buttonAnimationController,
          ),
        ],
        child: Scaffold(
          backgroundColor: colorScheme.surfaceVariant,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                title: const Text('Number Match'),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    ref.read(gameTimerProvider.notifier).stop();
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      final currentLevel = ref.read(levelProvider);
                      ref
                          .read(gameControllerProvider.notifier)
                          .restartWithLevel(currentLevel);
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(height: 60),
                      const LevelProgress(),
                      const SizedBox(height: 8),
                      Text(
                        '${(timeLeft ~/ 60).toString().padLeft(2, '0')}:${(timeLeft % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 20,
                          color: timeLeft <= 30
                              ? Colors.red
                              : colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: const [
                    SizedBox(height: 24),
                    LevelSelector(),
                    SizedBox(height: 24),
                    GameGrid(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: const AddRowButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}
