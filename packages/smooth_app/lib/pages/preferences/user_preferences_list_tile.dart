import 'package:flutter/material.dart';

/// Custom [ListTile] for preferences.
class UserPreferencesListTile extends StatelessWidget {
  const UserPreferencesListTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.onLongPress,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Icon (leading or trailing) with the standard color.
  static Icon getTintedIcon(
    final IconData iconData,
    final BuildContext context,
  ) =>
      Icon(
        iconData,
        color: Theme.of(context).iconTheme.color,
      );

  @override
  Widget build(BuildContext context) => ListTile(
        leading: leading,
        title: DefaultTextStyle.merge(
          style: Theme.of(context).textTheme.headline4,
          child: title,
        ),
        trailing: trailing,
        onTap: onTap,
        onLongPress: onLongPress,
        subtitle: subtitle,
      );
}
