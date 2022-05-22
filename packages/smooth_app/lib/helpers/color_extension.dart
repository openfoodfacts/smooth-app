import 'package:flutter/material.dart';

extension ColorExtension on Color {
  String get toPreferencesString => '$alpha;$red;$green;$blue';

  static Color? fromPreferencesString(String? text) {
    if (text == null || text.isEmpty) {
      return null;
    }

    final List<String> values = text.split(';');

    return Color.fromARGB(
      int.parse(values[0]),
      int.parse(values[1]),
      int.parse(values[2]),
      int.parse(values[3]),
    );
  }
}
