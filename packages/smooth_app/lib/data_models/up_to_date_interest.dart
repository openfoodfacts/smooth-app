/// Management of the interest for a key.
class UpToDateInterest {
  /// Number of time an interest was shown for a given key.
  final Map<String, int> _interestCounts = <String, int>{};

  /// Shows an interest for a key.
  void add(final String key) {
    final int result = (_interestCounts[key] ?? 0) + 1;
    _interestCounts[key] = result;
  }

  /// Loses an interest for a key.
  ///
  /// Returns true if completely lost interest.
  bool remove(final String key) {
    final int result = (_interestCounts[key] ?? 0) - 1;
    if (result <= 0) {
      _interestCounts.remove(key);
      return true;
    }
    _interestCounts[key] = result;
    return false;
  }

  bool get isEmpty => _interestCounts.isEmpty;

  bool containsKey(final String key) => _interestCounts.containsKey(key);
}
