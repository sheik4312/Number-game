import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final levelProvider = StateNotifierProvider<LevelNotifier, int>((ref) {
  return LevelNotifier();
});

class LevelNotifier extends StateNotifier<int> {
  LevelNotifier() : super(1) {
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLevel = prefs.getInt('currentLevel') ?? 1;
    state = savedLevel;
    debugPrint('LevelProvider loaded level=$savedLevel');
  }

  void setLevel(int newLevel) async {
    state = newLevel;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentLevel', newLevel);
  }
}

final completedLevelsProvider = StateProvider<List<int>>((ref) => [1]);
