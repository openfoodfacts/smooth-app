extension StringExtension on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);

  String removeSpaces() => replaceAll(RegExp(r' |\n|\r|\s|\t'), '');

  bool hasOnlyDigits() => int.tryParse(this) != null;
}
