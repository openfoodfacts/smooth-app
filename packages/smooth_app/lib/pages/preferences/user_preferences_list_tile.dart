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
        children: <Widget>[
          title,
          icon!,
        ],
      );
    }

    final TextStyle textStyle = DefaultTextStyle.of(context).style;

    final Widget displayed = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LARGE_SPACE,
        vertical: LARGE_SPACE,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: SMALL_SPACE),
          DefaultTextStyle.merge(
            child: tmpTitle,
            style: Theme.of(context).textTheme.headline4,
          ),
          const SizedBox(height: VERY_SMALL_SPACE),
          if (subtitle != null)
            ConstrainedBox(
              // At least two lines for the subtitle
              constraints: BoxConstraints(
                minHeight: (textStyle.fontSize! * 2) + 1.5 * 2,
              ),
              child: DefaultTextStyle.merge(
                style: const TextStyle(
                  height: 1.5,
                ),
                child: subtitle!,
              ),
            ),
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
