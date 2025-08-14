import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_game/controllers/game_controller.dart';
import 'package:number_game/models/game_tile.dart';
import 'package:number_game/providers/timer_provider.dart';
import '../providers/game_providers.dart';
import '../providers/level_providers.dart';
import '../widgets/game/game_grid.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        ref.read(gameTimerProvider.notifier).start();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _buttonAnimationController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(gameTimerProvider.notifier).stop();
      }
    });
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

    // Timer listener
    ref.listen<int>(gameTimerProvider, (_, current) {
      if (current == 0 && !_isDisposed) {
        _showTimeUpDialog();
      }
    });

    // Game state listener
    ref.listen<List<GameTile>>(gameControllerProvider, (_, __) {
      final controller = ref.read(gameControllerProvider.notifier);

      controller.completedLevelsCallback = (level, [message]) {
        if (level == -1 && message != null) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              backgroundColor: colorScheme.primaryContainer,
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
            backgroundColor: colorScheme.primaryContainer,
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
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D47A1), // Deep blue
                  Color(0xFF1976D2), // Vibrant blue
                  Color(0xFF42A5F5), // Light blue
                ],
                stops: [0.0, 0.5, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 140,
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade900.withOpacity(0.8),
                          Colors.blue.shade700.withOpacity(0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  title: Text(
                    'Number Match',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      ref.read(gameTimerProvider.notifier).stop();
                      Navigator.pop(context);
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        final currentLevel = ref.read(levelProvider);
                        ref
                            .read(gameControllerProvider.notifier)
                            .restartWithLevel(currentLevel);
                      },
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Column(
                      children: [
                        // Timer and Level Info Card
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Current Level
                              Consumer(
                                builder: (context, ref, _) {
                                  final currentLevel = ref.watch(levelProvider);
                                  return Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Level $currentLevel',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              // Timer
                              Row(
                                children: [
                                  const Icon(Icons.timer, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${(timeLeft ~/ 60).toString().padLeft(2, '0')}:${(timeLeft % 60).toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: timeLeft <= 30
                                          ? const Color(0xFFFF6B6B) // Coral red
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        const GameGrid(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Consumer(
            builder: (context, ref, _) {
              final controller = ref.watch(gameControllerProvider.notifier);
              final remaining = (controller.maxAddRow - controller.addRowUsed)
                  .clamp(0, controller.maxAddRow);

              return Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF9800), // Amber
                      Color(0xFFFF5722), // Deep orange
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: remaining > 0
                      ? () => controller.addRowBelow()
                      : null, // disable button when no clicks left
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Add Row ($remaining)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
