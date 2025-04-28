import 'package:flutter/material.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// A tile for preferences in the settings page.
/// It can be used to display a title, an icon, a subtitle, and a trailing widget.
/// It can also be used to handle tap events.
/// The tiles are used inside a [PreferenceCard]. It will also be displayed
/// outside of a card when the user is searching for a tile.
class PreferenceTile extends StatelessWidget {
  const PreferenceTile({
    super.key,
    this.icon,
    required this.title,
    this.subtitleText,
    this.subtitle,
    this.trailing,
    this.onTap,
  }) : assert(
          (subtitleText != null && subtitle == null) ||
              (subtitleText == null && subtitle != null) ||
              (subtitleText == null && subtitle == null),
          'Either subtitleText or subtitle must be provided, not both.',
        );

  final IconData? icon;
  final String title;
  final String? subtitleText;
  final Widget? subtitle;
  final Widget? trailing;
  final Function()? onTap;

  String get keywords =>
      '${title.toLowerCase()} ${subtitleText?.toLowerCase() ?? ''}';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool lightTheme = context.lightTheme(listen: true);

    return ListTile(
      leading: icon != null
          ? Icon(
              icon,
              color: lightTheme ? theme.primaryColor : Colors.white,
            )
          : null,
      title: Text(title),
      subtitle: subtitle ?? (subtitleText != null ? Text(subtitleText!) : null),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
