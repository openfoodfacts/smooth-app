import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Custom [ListTile] for preferences.
class UserPreferencesListTile extends StatelessWidget {
  const UserPreferencesListTile({
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.onLongPress,
    this.isCompactTitle = false,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isCompactTitle;

  @override
  Widget build(BuildContext context) {
    final Widget tmpTitle;
    if (icon == null) {
      tmpTitle = title;
    } else {
      tmpTitle = Row(
        mainAxisAlignment: isCompactTitle
            ? MainAxisAlignment.start
            : MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[title, icon!],
      );
    }
    final Widget displayed = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LARGE_SPACE,
        vertical: SMALL_SPACE,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: SMALL_SPACE),
          tmpTitle,
          const SizedBox(height: VERY_SMALL_SPACE),
          if (subtitle != null) subtitle!,
        ],
      ),
    );
    if (onTap == null && onLongPress == null) {
      return displayed;
    }
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: displayed,
    );
  }
}
