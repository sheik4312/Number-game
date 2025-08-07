import 'package:flutter_riverpod/flutter_riverpod.dart';

final levelProvider = StateProvider<int>((ref) => 1);
final completedLevelsProvider = StateProvider<List<int>>((ref) => [1]);
