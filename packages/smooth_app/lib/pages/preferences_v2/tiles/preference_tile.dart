import 'package:flutter/material.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// A tile for preferences in the settings page.
/// It can be used to display a title, an icon, a subtitle, and a trailing widget.
/// It can also be used to handle tap events.
/// The tiles are used inside a [PreferenceCard]. It will also be displayed
/// outside of a card when the user is searching for a tile.
class PreferenceTile extends StatelessWidget {
  const PreferenceTile({
    required this.title,
    this.leading,
    this.icon,
    this.subtitleText,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  }) : assert(
         (subtitleText != null && subtitle == null) ||
             (subtitleText == null && subtitle != null) ||
             (subtitleText == null && subtitle == null),
         'Either subtitleText or subtitle must be provided, not both.',
       ),
       assert(
         leading == null || icon == null,
         'Either leading or icon must be provided.',
       );

  final Widget? leading;
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

    final Color color = context.lightTheme()
        ? theme.primaryColor
        : Colors.white;

    return ListTile(
      leading: leading ?? (icon != null ? Icon(icon, color: color) : null),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      subtitle:
          subtitle ??
          (subtitleText != null
              ? Text(
                  subtitleText!,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                )
              : null),
      trailing: trailing,

      onTap: onTap,
    );
  }
}
