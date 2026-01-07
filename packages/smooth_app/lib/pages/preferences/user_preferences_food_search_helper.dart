import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// Helper around looking for a term in the food attribute page.
class UserPreferencesFoodSearchHelper {
  UserPreferencesFoodSearchHelper(final String query)
    : lowerCaseQuery = query.toLowerCase();

  final String lowerCaseQuery;

  bool matches(final List<String?> labels) =>
      labels.firstWhereOrNull(
        (final String? label) =>
            label != null && label.toLowerCase().contains(lowerCaseQuery),
      ) !=
      null;

  PreferenceTile getPreferenceTile({
    required final String title,
    required final BuildContext context,
    final Widget? icon,
  }) => PreferenceTile(
    title: title,
    onTap: () async => Navigator.of(context).push(
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => const UserPreferencesFoodPage(),
      ),
    ),
    icon: icon ?? const icons.HappyToast(),
  );
}
