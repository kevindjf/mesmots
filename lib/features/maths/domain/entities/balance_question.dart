class BalanceQuestion {
  final int id;
  final int targetValue;
  final List<int> availableTiles;

  const BalanceQuestion({
    required this.id,
    required this.targetValue,
    required this.availableTiles,
  });

  bool isValidSolution(List<int> selectedTiles) {
    final sum = selectedTiles.fold(0, (a, b) => a + b);
    return sum == targetValue;
  }
}
