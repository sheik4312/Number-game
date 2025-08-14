import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_game/models/game_tile.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:number_game/providers/timer_provider.dart';

/// Provider for GameController using Riverpod's StateNotifierProvider
/// The state is a List<GameTile> representing the current grid.
final gameControllerProvider =
    StateNotifierProvider<GameController, List<GameTile>>(
      (ref) => GameController(gridSize: 9, level: 1, ref: ref),
    );

/// GameController handles all game logic:
/// - Managing tile states (selected, matched, invalid)
/// - Level progression and unlocking
/// - Timer interactions
/// - Adding extra rows
/// - Persisting progress via SharedPreferences
class GameController extends StateNotifier<List<GameTile>> {
  final int gridSize; // Number of columns in the grid
  int level; // Current level being played
  int unlockedLevel = 1; // Highest level unlocked
  int? firstSelectedId; // Tracks the first selected tile for matching
  final Map<int, List<GameTile>> _savedLevels =
      {}; // Cache of previously generated levels
  late final Ref _ref; // Riverpod reference for providers
  bool _disposed = false; // Track whether the controller is disposed

  int maxAddRow = 5; // Max number of extra rows player can add
  int addRowUsed = 0; // Number of times player has added a row

  /// Constructor initializes the controller and loads saved level
  GameController({
    required this.gridSize,
    required this.level,
    required Ref ref,
  }) : super([]) {
    _ref = ref;
    _initController();
  }

  /// Initializes controller asynchronously:
  /// - Loads saved progress
  /// - Starts the timer
  Future<void> _initController() async {
    await _loadSavedLevel();
    _startTimer();
  }

  /// Loads saved level and unlocked level from SharedPreferences
  Future<void> _loadSavedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    unlockedLevel = prefs.getInt('unlockedLevel') ?? 1;
    level = prefs.getInt('currentLevel') ?? 1;
    if (level > unlockedLevel) level = unlockedLevel;
    debugPrint('Loaded from prefs: current=$level, unlocked=$unlockedLevel');
    _loadLevel(level);
  }

  /// Saves unlocked level to SharedPreferences
  Future<void> _saveUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unlockedLevel', unlockedLevel);
    debugPrint('Saved unlockedLevel=$unlockedLevel');
  }

  /// Saves current level to SharedPreferences
  Future<void> _saveCurrentLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentLevel', level);
    debugPrint('Saved currentLevel=$level');
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  /// Stops the game timer
  void _stopTimer() {
    _ref.read(gameTimerProvider.notifier).stop();
  }

  /// Safely executes a function if the controller is not disposed
  void _safeTimerAction(void Function() action) {
    if (!_disposed) {
      action();
    }
  }

  /// Loads a level from cache or generates it if not already saved
  void _loadLevel(int lvl) {
    if (_savedLevels.containsKey(lvl)) {
      state = _savedLevels[lvl]!;
      level = lvl;
    } else {
      _initGame(lvl);
    }
  }

  /// Animates invalid tile selection (shake effect)
  void _animateInvalid(int id1, int id2) {
    // Mark tiles as invalid
    state = state.map((t) {
      if (t.id == id1 || t.id == id2) {
        return t.copyWith(isInvalid: true);
      }
      return t;
    }).toList();

    // Reset tile states after animation
    Future.delayed(const Duration(milliseconds: 500), () {
      state = state.map((t) {
        if (t.id == id1 || t.id == id2) {
          return t.copyWith(isSelected: false, isInvalid: false);
        }
        return t;
      }).toList();
      firstSelectedId = null;
    });
  }

  /// Starts the game timer
  void _startTimer() {
    _ref.read(gameTimerProvider.notifier).start();
  }

  /// Initializes a new game level
  /// Generates tile values with dynamic difficulty
  void _initGame(int lvl) {
    addRowUsed = 0;
    maxAddRow = 5; // Reset extra rows for new level
    final random = Random();

    // Determine number of rows (start with 3, increase every 3 levels)
    int rows = 3 + ((lvl - 1) ~/ 3).clamp(0, 5);
    final totalTiles = gridSize * rows;

    List<int> values = [];
    // Dynamic difficulty: reduce number of pairs as level increases
    final basePairRatio = 0.85;
    final decayRate = 0.015;
    final minPairRatio = 0.25;
    final effectivePairRatio = (basePairRatio - (decayRate * lvl)).clamp(
      minPairRatio,
      basePairRatio,
    );

    final pairCount = (totalTiles * effectivePairRatio ~/ 2).clamp(
      0,
      totalTiles ~/ 2,
    );
    final singleCount = totalTiles - (pairCount * 2);

    // Generate pairs
    for (int i = 0; i < pairCount; i++) {
      final val = random.nextInt(9) + 1;
      values.add(val);
      values.add(val);
    }

    // Generate single tiles
    for (int i = 0; i < singleCount; i++) {
      values.add(random.nextInt(9) + 1);
    }

    values.shuffle();

    // Initialize state with tiles
    state = List.generate(totalTiles, (i) => GameTile(id: i, value: values[i]));
    level = lvl;
    _savedLevels[lvl] = state;
  }

  /// Handles tile tap events
  void onTileTap(int id) {
    final tapped = state.firstWhere((t) => t.id == id);
    if (tapped.isMatched) return;

    // First tile selected
    if (firstSelectedId == null) {
      _selectTile(id);
      firstSelectedId = id;
    }
    // Same tile tapped again → deselect
    else if (firstSelectedId == id) {
      _deselectTile(id);
      firstSelectedId = null;
    }
    // Second tile tapped → check match
    else {
      final firstTile = state.firstWhere((t) => t.id == firstSelectedId);
      final secondTile = tapped;

      final match = _checkMatch(firstTile, secondTile);

      if (match) {
        _markMatched(firstTile.id, secondTile.id);
      } else {
        _animateInvalid(firstTile.id, secondTile.id);
      }

      // Deselect both tiles after second tap
      _deselectTile(firstTile.id);
      _deselectTile(secondTile.id);
      firstSelectedId = null;
    }

    // Persist level state
    _savedLevels[level] = state;
  }

  /// Checks if two tiles can be matched
  /// Matching rules: sum to 10 or same value and a clear path between tiles
  bool _checkMatch(GameTile first, GameTile second) {
    if (first.id == second.id || first.isMatched || second.isMatched)
      return false;

    bool isValueMatch =
        (first.value + second.value == 10) || (first.value == second.value);
    if (!isValueMatch) return false;

    int row1 = first.id ~/ gridSize;
    int col1 = first.id % gridSize;
    int row2 = second.id ~/ gridSize;
    int col2 = second.id % gridSize;

    bool pathIsClear = false;
    final lastId = state.length - 1;

    // Horizontal path
    if (row1 == row2) {
      int start = first.id < second.id ? first.id + 1 : second.id + 1;
      int end = first.id < second.id ? second.id : first.id;
      pathIsClear = true;
      for (int i = start; i < end; i++) {
        if (!state[i].isMatched) {
          pathIsClear = false;
          break;
        }
      }
      if (pathIsClear) return true;
    }
    // Vertical path
    else if (col1 == col2) {
      pathIsClear = true;
      int startRow = min(row1, row2);
      int endRow = max(row1, row2);
      for (int r = startRow + 1; r < endRow; r++) {
        int index = r * gridSize + col1;
        if (!state[index].isMatched) {
          pathIsClear = false;
          break;
        }
      }
      if (pathIsClear) return true;
    }
    // Diagonal path
    else if ((row2 - row1).abs() == (col2 - col1).abs()) {
      int stepRow = row2 > row1 ? 1 : -1;
      int stepCol = col2 > col1 ? 1 : -1;
      int steps = (row2 - row1).abs();

      pathIsClear = true;
      for (int i = 1; i < steps; i++) {
        int r = row1 + i * stepRow;
        int c = col1 + i * stepCol;
        int index = r * gridSize + c;
        if (index < 0 || index >= state.length || !state[index].isMatched) {
          pathIsClear = false;
          break;
        }
      }
      if (pathIsClear) return true;
    }

    // 1D forward/backward path check
    {
      int low = min(first.id, second.id);
      int high = max(first.id, second.id);

      bool forwardClear = true;
      for (int i = low + 1; i < high; i++) {
        if (!state[i].isMatched) {
          forwardClear = false;
          break;
        }
      }

      bool backwardClear = true;
      for (int i = 0; i < low; i++) {
        if (!state[i].isMatched) {
          backwardClear = false;
          break;
        }
      }
      if (backwardClear) {
        for (int i = high + 1; i <= lastId; i++) {
          if (!state[i].isMatched) {
            backwardClear = false;
            break;
          }
        }
      }

      pathIsClear = forwardClear || backwardClear;
    }

    return pathIsClear;
  }

  /// Marks a tile as selected
  void _selectTile(int id) {
    state = state.map((tile) {
      return tile.id == id ? tile.copyWith(isSelected: true) : tile;
    }).toList();
  }

  /// Deselects a tile
  void _deselectTile(int id) {
    state = state.map((tile) {
      return tile.id == id ? tile.copyWith(isSelected: false) : tile;
    }).toList();
  }

  /// Marks two tiles as matched
  /// Also triggers row check after short delay
  void _markMatched(int id1, int id2) {
    state = state.map((t) {
      if (t.id == id1 || t.id == id2) {
        return t.copyWith(isMatched: true, isSelected: false, isInvalid: false);
      }
      return t;
    }).toList();

    Future.delayed(const Duration(milliseconds: 300), () {
      _checkAndClearFullRows();
    });

    _savedLevels[level] = state;
  }

  /// Checks for fully matched rows and removes them
  /// Rebuilds grid and unlocks next level if all rows cleared
  void _checkAndClearFullRows() {
    List<List<GameTile>> grid = [];
    final numRows = (state.length / gridSize).ceil();

    // Split tiles into rows
    for (int r = 0; r < numRows; r++) {
      final start = r * gridSize;
      final end = min(start + gridSize, state.length);
      grid.add(state.sublist(start, end));
    }

    final originalRowCount = grid.length;

    // Remove fully matched rows
    grid.removeWhere((row) => row.every((tile) => tile.isMatched));

    // Rebuild state from remaining rows
    List<GameTile> newState = [];
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        final oldTile = grid[r][c];
        final newId = r * gridSize + c;
        newState.add(oldTile.copyWith(id: newId));
      }
    }

    state = newState;

    // Unlock next level if all rows cleared
    if (grid.isEmpty && originalRowCount > 0) {
      _unlockNextLevel();
    }
  }

  /// Unlocks the next level
  /// Resets timer, increments maxAddRow, and initializes new level
  void _unlockNextLevel() {
    level = level + 1;
    unlockedLevel = max(unlockedLevel, level);
    maxAddRow += 1;
    addRowUsed = 0;

    _saveUnlockedLevel();
    _saveCurrentLevel();
    _ref.read(gameTimerProvider.notifier).stop();

    Future.microtask(() {
      _completedLevelsCallback?.call(level);
    });

    Future.delayed(const Duration(seconds: 1), () {
      _initGame(level);
      _ref.read(gameTimerProvider.notifier).reset();
      _ref.read(gameTimerProvider.notifier).start();
    });
  }

  /// Callback for level completion (used by UI)
  void Function(int level, [String? message])? _completedLevelsCallback;
  set completedLevelsCallback(void Function(int level, [String? message]) cb) {
    _completedLevelsCallback = cb;
  }

  /// Restarts the current level
  void restartWithLevel(int newLevel) {
    _ref.read(gameTimerProvider.notifier).reset();
    _initGame(newLevel);
    _ref.read(gameTimerProvider.notifier).start();
  }

  /// Switches to another level
  void switchLevel(int newLevel) {
    _safeTimerAction(() {
      _ref.read(gameTimerProvider.notifier).reset();
      _loadLevel(newLevel);
      _ref.read(gameTimerProvider.notifier).start();
    });
  }

  /// Adds a new row below the current grid
  /// Only allowed if addRowUsed < maxAddRow
  void addRowBelow() {
    if (addRowUsed >= maxAddRow) return;

    final currentTiles = state;
    final unmatchedValues = currentTiles
        .where((tile) => !tile.isMatched)
        .map((tile) => tile.value)
        .toList();

    if (unmatchedValues.isEmpty) return;

    final List<GameTile> newTiles = unmatchedValues
        .map((value) => GameTile(id: 0, value: value))
        .toList();

    final updatedState = [...currentTiles, ...newTiles];

    // Reassign IDs
    state = List.generate(updatedState.length, (index) {
      final tile = updatedState[index];
      return tile.copyWith(id: index);
    });

    addRowUsed += 1;
  }

  /// Checks if a level is unlocked
  bool isLevelUnlocked(int levelToCheck) {
    return levelToCheck <= unlockedLevel;
  }
}
