import 'package:flutter/material.dart';

/// Item for preferences, with labels for pre-filtering and widget builder.
abstract interface class UserPreferencesItem {
  Iterable<String> get labels;
  Widget Function(BuildContext) get builder;
}

/// Simplest implementation of a [UserPreferencesItem].
class UserPreferencesItemSimple implements UserPreferencesItem {
  const UserPreferencesItemSimple({
    required this.labels,
    required this.builder,
  });

  @override
  final Iterable<String> labels;

  @override
  final WidgetBuilder builder;
}
