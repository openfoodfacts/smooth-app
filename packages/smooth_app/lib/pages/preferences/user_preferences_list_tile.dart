import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// Custom [ListTile] for preferences.
class UserPreferencesListTile extends StatelessWidget {
  const UserPreferencesListTile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.onLongPress,
    this.shape,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ShapeBorder? shape;

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
          style: Theme.of(context).textTheme.headlineMedium,
          child: title,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: LARGE_SPACE,
          vertical: subtitle != null ? VERY_SMALL_SPACE : 2.0,
        ),
        trailing: trailing,
        onTap: onTap,
        onLongPress: onLongPress,
        subtitle: subtitle,
        shape: shape,
      );
}
