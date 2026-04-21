class BoardPosition {
  final int x;
  final int y;

  const BoardPosition(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BoardPosition && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  String toString() => "($x,$y)";

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}