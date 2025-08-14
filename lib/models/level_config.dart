class LevelConfig {
  final int rows;
  final int minValue;
  final int maxValue;
  final bool requirePairs;
  final int extraRandomTiles;

  LevelConfig({
    required this.rows,
    required this.minValue,
    required this.maxValue,
    required this.requirePairs,
    this.extraRandomTiles = 0,
  });
}

final levelConfigs = {
  1: LevelConfig(
    rows: 2,
    minValue: 1,
    maxValue: 9,
    requirePairs: true,
    extraRandomTiles: 3,
  ),
  2: LevelConfig(
    rows: 3,
    minValue: 1,
    maxValue: 9,
    requirePairs: true,
    extraRandomTiles: 6,
  ),
  3: LevelConfig(
    rows: 4,
    minValue: 1,
    maxValue: 9,
    requirePairs: false,
    extraRandomTiles: 10,
  ),
  // extend to 100+ levels easily
};
