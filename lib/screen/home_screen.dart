import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_game/screen/gamescreen.dart';
import '../widgets/home/animated_button.dart';
import '../widgets/home/animated_logo.dart';
import '../widgets/home/instruction_row.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.purple.shade700],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white70,
                      size: 28,
                    ),
                    onPressed: () {
                      // Add settings functionality
                    },
                  ),
                ),
                const Spacer(),
                const AnimatedLogo(),
                const SizedBox(height: 30),
                const Text(
                  'NUMBER MATCH',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        blurRadius: 5,
                        color: Colors.black45,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                AnimatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const GameScreen(),
                        transitionsBuilder: (_, animation, __, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  label: 'START GAME',
                  icon: Icons.play_arrow_rounded,
                ),
                const SizedBox(height: 20),
                AnimatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.grey[900]!.withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.help_outline,
                                    color: Colors.blueAccent,
                                    size: 30,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "How to Play",
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade200,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const InstructionRow(
                                number: "1",
                                text: "Match tiles with same value",
                              ),
                              const InstructionRow(
                                number: "2",
                                text: "Match tiles that sum to 10",
                              ),
                              const InstructionRow(
                                number: "3",
                                text:
                                    "Match vertically, horizontally, or diagonally",
                              ),
                              const InstructionRow(
                                number: "4",
                                text: "Clear all rows to advance",
                              ),
                              const SizedBox(height: 30),
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'GOT IT',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  label: 'HOW TO PLAY',
                  icon: Icons.help_outline_rounded,
                  isPrimary: false,
                ),
                const Spacer(flex: 2),
                Text(
                  '© 2025 NUMBER MATCH',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
