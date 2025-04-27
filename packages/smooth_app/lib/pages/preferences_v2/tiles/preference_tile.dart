import 'package:flutter/material.dart';

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

    return ListTile(
      leading: icon != null
          ? Icon(
              icon,
              color: theme.primaryColor,
            )
          : null,
      title: Text(title),
      subtitle: subtitle ?? (subtitleText != null ? Text(subtitleText!) : null),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
