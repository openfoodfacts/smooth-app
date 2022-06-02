extension StringExt on String {
  /// Returns a list containing all positions of the [charCode]
  List<int> indexesOf(String charCode) {
    assert(charCode.length == 1);

    final List<int> positions = <int>[];
    int i = 0;

    for (; i != length; i++) {
      if (this[i] == charCode) {
        positions.add(i);
      }
    }

    return positions;
  }

  /// Removes a character by giving its position
  String removeCharacterAt(int position) {
    assert(position >= 0 && position < length);
    return substring(0, position) + substring(position + 1);
  }
}
