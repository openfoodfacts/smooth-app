import 'package:flutter/material.dart';

/// Base class for the Scanner interface…
abstract class Scanner {
  const Scanner();

  Widget getScanner(Future<bool> Function(String) onScan);
}
