import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_game/models/game_tile.dart';
import 'dart:math';

import 'package:number_game/providers/timer_provider.dart';

final gameControllerProvider =
    StateNotifierProvider<GameController, List<GameTile>>(
      (ref) => GameController(gridSize: 9, level: 1, ref: ref),
    );

class GameController extends StateNotifier<List<GameTile>> {
  final int gridSize;
  int level;
  int unlockedLevel = 1;
  int? firstSelectedId; // Add this line
  final Map<int, List<GameTile>> _savedLevels = {};
  late final Ref _ref;
  bool _disposed = false;
  GameController({
    required this.gridSize,
    required this.level,
    required Ref ref,
  }) : super([]) {
    _ref = ref;
    _loadLevel(level);
    _startTimer();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _stopTimer() {
    _ref.read(gameTimerProvider.notifier).stop();
  }

  void _safeTimerAction(void Function() action) {
    if (!_disposed) {
      action();
    }
  }

  void _loadLevel(int lvl) {
    if (_savedLevels.containsKey(lvl)) {
      state = _savedLevels[lvl]!;
      level = lvl;
    } else {
      _initGame(lvl);
    }
  }

  void _startTimer() {
    _ref.read(gameTimerProvider.notifier).start();
  }

  void _initGame(int lvl) {
    final random = Random();
    final rows = lvl + 1;
    final totalTiles = gridSize * rows;
    List<int> values = [];

    if (lvl == 1) {
      for (int i = 1; i <= 9; i++) {
        values.add(i);
        values.add(i);
      }
      while (values.length < totalTiles) {
        values.add(random.nextInt(9) + 1);
      }
    } else if (lvl == 2) {
      final used = <int>[];
      while (values.length < totalTiles - 6) {
        int val = random.nextInt(9) + 1;
        values.add(val);
        values.add(val);
        used.add(val);
      }
      while (values.length < totalTiles) {
        values.add(random.nextInt(9) + 1);
      }
    } else {
      while (values.length < totalTiles) {
        values.add(random.nextInt(9) + 1);
      }
    }

    values.shuffle();

    state = List.generate(totalTiles, (i) {
      return GameTile(id: i, value: values[i]);
    });

    level = lvl;
    _savedLevels[lvl] = state;
  }

  void onTileTap(int id) {
    final tapped = state.firstWhere((t) => t.id == id);
    if (tapped.isMatched) return;

    if (firstSelectedId == null) {
      _selectTile(id);
      firstSelectedId = id;
    } else if (firstSelectedId == id) {
      _deselectTile(id);
      firstSelectedId = null;
    } else {
      final firstTile = state.firstWhere((t) => t.id == firstSelectedId);
      final secondTile = tapped;

      final match = _checkMatch(firstTile, secondTile);

      if (match) {
        _markMatched(firstTile.id, secondTile.id);
      } else {
        _animateInvalid(firstTile.id, secondTile.id);
      }

      firstSelectedId = null;
    }

    _savedLevels[level] = state;
  }

  bool _checkMatch(GameTile first, GameTile second) {
    if (first.id == second.id) return false;
    if (first.isMatched || second.isMatched) return false;

    // Value match logic (sum to 10 or equal)
    bool isValueMatch =
        (first.value + second.value == 10) || (first.value == second.value);
    if (!isValueMatch) return false;

    int row1 = first.id ~/ gridSize;
    int col1 = first.id % gridSize;
    int row2 = second.id ~/ gridSize;
    int col2 = second.id % gridSize;

    bool pathIsClear = false;

    final lastId = state.length - 1;

    // Horizontal (same row)
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
    // Vertical (same column)
    else if (col1 == col2) {
      pathIsClear = true;
      int startRow = row1 < row2 ? row1 : row2;
      int endRow = row1 > row2 ? row1 : row2;
      for (int r = startRow + 1; r < endRow; r++) {
        int index = r * gridSize + col1;
        if (!state[index].isMatched) {
          pathIsClear = false;
          break;
        }
      }
      if (pathIsClear) return true;
    }
    // Diagonal
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

    // Linear forward or backward path check in the flat list (1D)
    {
      int low = first.id < second.id ? first.id : second.id;
      int high = first.id > second.id ? first.id : second.id;

      bool forwardClear = true;
      for (int i = low + 1; i < high; i++) {
        if (!state[i].isMatched) {
          forwardClear = false;
          break;
        }
      }

      bool backwardClear = true;

      // Check indices from 0 to low-1
      for (int i = 0; i < low; i++) {
        if (!state[i].isMatched) {
          backwardClear = false;
          break;
        }
      }

      // Check indices from high+1 to lastId
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

  void _selectTile(int id) {
    state = state
        .map((t) => t.id == id ? t.copyWith(isSelected: true) : t)
        .toList();
  }

  void _deselectTile(int id) {
    state = state
        .map((t) => t.id == id ? t.copyWith(isSelected: false) : t)
        .toList();
  }

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

  void _checkAndClearFullRows() {
    List<List<GameTile>> grid = [];
    final numRows = (state.length / gridSize)
        .ceil(); // Use ceil to include partial last row

    debugPrint('--- _checkAndClearFullRows START ---');
    debugPrint(
      'Total tiles: ${state.length}, Grid size: $gridSize, Number of rows: $numRows',
    );

    // Split tiles into rows (including partial last row)
    for (int r = 0; r < numRows; r++) {
      final start = r * gridSize;
      final end = (start + gridSize <= state.length)
          ? (start + gridSize)
          : state.length;
      grid.add(state.sublist(start, end));
      debugPrint(
        'Row $r extracted with IDs: ' + grid[r].map((t) => t.id).join(', '),
      );
    }

    final originalRowCount = grid.length;
    debugPrint('Original row count: $originalRowCount');

    // Print matched states for each row before removal
    for (int r = 0; r < grid.length; r++) {
      String matchedStates = grid[r]
          .map((t) => t.isMatched ? 'T' : 'F')
          .join(' ');
      debugPrint('Row $r matched states: $matchedStates');
    }

    grid.removeWhere((row) {
      bool allMatched = row.every((tile) => tile.isMatched);
      if (allMatched) {
        debugPrint(
          'Removing matched row (any length): IDs ' +
              row.map((t) => t.id).join(', '),
        );
      }
      return allMatched;
    });

    int removedRowsCount = originalRowCount - grid.length;
    if (removedRowsCount > 0) {
      debugPrint('Removed $removedRowsCount fully matched row(s).');
    } else {
      debugPrint('No fully matched rows to remove.');
    }

    // Rebuild newState list from remaining rows (including partial rows)
    List<GameTile> newState = [];
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        final oldTile = grid[r][c];
        final newId = r * gridSize + c;
        newState.add(oldTile.copyWith(id: newId));
        debugPrint(
          'Keeping tile ID ${oldTile.id} with value ${oldTile.value} at new ID $newId, isMatched=${oldTile.isMatched}',
        );
      }
    }

    state = newState;
    debugPrint('New state length: ${state.length} after clearing rows.');

    // Unlock next level if all rows cleared
    if (grid.isEmpty && originalRowCount > 0) {
      debugPrint('All rows cleared! Unlocking next level...');
      _unlockNextLevel();
    }

    debugPrint('--- _checkAndClearFullRows END ---');
  }

  final List<String> _completionQuotes = [
    "Great job! You've mastered all levels!",
    "Success is the sum of small efforts repeated daily.",
    "The expert in anything was once a beginner.",
    "You've shown incredible persistence!",
    "Well done! Your skills are impressive!",
    "Every puzzle you solve makes you better at solving the next one.",
    "Congratulations! You're a number matching champion!",
  ];

  void _unlockNextLevel() {
    if (unlockedLevel < 3) {
      unlockedLevel++;
      _ref.read(gameTimerProvider.notifier).stop();
      Future.microtask(() {
        _completedLevelsCallback?.call(unlockedLevel);
      });

      Future.delayed(const Duration(seconds: 1), () {
        _loadLevel(unlockedLevel);
        _ref.read(gameTimerProvider.notifier).reset();
        _ref.read(gameTimerProvider.notifier).start();
      });
    } else {
      // All levels completed - show quote
      _ref.read(gameTimerProvider.notifier).stop();
      final random = Random();
      final quote = _completionQuotes[random.nextInt(_completionQuotes.length)];
      _completedLevelsCallback?.call(
        -1,
        quote,
      ); // Use -1 to indicate game completion
    }
  }

  void Function(int level, [String? message])? _completedLevelsCallback;
  set completedLevelsCallback(void Function(int level, [String? message]) cb) {
    _completedLevelsCallback = cb;
  }

  void restartWithLevel(int newLevel) {
    _ref.read(gameTimerProvider.notifier).reset();
    _initGame(newLevel);
    _ref.read(gameTimerProvider.notifier).start();
  }

  void switchLevel(int newLevel) {
    _safeTimerAction(() {
      _ref.read(gameTimerProvider.notifier).reset();
      _loadLevel(newLevel);
      _ref.read(gameTimerProvider.notifier).start();
    });
  }

  void _animateInvalid(int id1, int id2) {
    // First show invalid state
    state = state.map((t) {
      if (t.id == id1 || t.id == id2) {
        return t.copyWith(isInvalid: true);
      }
      return t;
    }).toList();

    // Then reset after animation
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

  void addRowBelow() {
    final currentTiles = state;
    final unmatchedValues = currentTiles
        .where((tile) => !tile.isMatched)
        .map((tile) => tile.value)
        .toList();

    if (unmatchedValues.isEmpty) return;

    final List<GameTile> newTiles = unmatchedValues
        .map((value) => GameTile(id: 0, value: value)) // Temporary IDs
        .toList();

    final updatedState = [...currentTiles, ...newTiles];

    state = List.generate(updatedState.length, (index) {
      final tile = updatedState[index];
      return tile.copyWith(id: index);
    });
  }

  bool isLevelUnlocked(int levelToCheck) {
    return levelToCheck <= unlockedLevel;
  }
}
