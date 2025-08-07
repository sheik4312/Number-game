// Add this to your providers file
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final gameTimerProvider = StateNotifierProvider<GameTimerNotifier, int>((ref) {
  return GameTimerNotifier();
});

class GameTimerNotifier extends StateNotifier<int> {
  GameTimerNotifier() : super(120);
  Timer? _timer;

  void start() {
    if (_timer?.isActive ?? false) return;
    _timer?.cancel();
    state = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state > 0) {
        state--;
      } else {
        _timer?.cancel();
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    stop();
    state = 120;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
