extension StringExtension on String {
  String capitalize() => isEmpty
      ? this
      : this[0].toUpperCase() + (length == 1 ? '' : substring(1));
}
