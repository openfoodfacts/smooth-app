import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/pages/preferences/user_preferences_page.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// Helper around looking for a term in the food attribute page.
class UserPreferencesFoodSearchHelper {
  UserPreferencesFoodSearchHelper(String query)
    : lowerCaseQuery = query.toLowerCase();

  final String lowerCaseQuery;

  bool matches(List<String?> labels) =>
      labels.firstWhereOrNull(
        (String? label) =>
            label != null && label.toLowerCase().contains(lowerCaseQuery),
      ) !=
      null;

  PreferenceTile getPreferenceTile({
    required String title,
    required BuildContext context,
    Widget? icon,
    Future<void> Function()? onTapCallback,
  }) => PreferenceTile(
    title: title,
    onTap: () async {
      final NavigatorState navigator = Navigator.of(context);
      await onTapCallback?.call();
      if (!navigator.mounted) {
        return;
      }
      await navigator.push(
        MaterialPageRoute<Widget>(
          builder: (BuildContext context) => const UserPreferencesFoodPage(),
        ),
      );
    },
    icon: icon ?? const icons.HappyToast(),
  );
}
