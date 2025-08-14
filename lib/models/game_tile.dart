class GameTile {
  final int id;
  final int value;
  final bool isSelected;
  final bool isMatched;
  final bool isInvalid; // New property for invalid animation

  GameTile({
    required this.id,
    required this.value,
    this.isSelected = false,
    this.isMatched = false,
    this.isInvalid = false,
  });

  GameTile copyWith({
    int? id,
    int? value,
    bool? isSelected,
    bool? isMatched,
    bool? isInvalid,
  }) {
    return GameTile(
      id: id ?? this.id,
      value: value ?? this.value,
      isSelected: isSelected ?? this.isSelected,
      isMatched: isMatched ?? this.isMatched,
      isInvalid: isInvalid ?? this.isInvalid,
    );
  }
}
