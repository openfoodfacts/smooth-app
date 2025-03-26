import 'package:flutter/material.dart';

class PreferenceTile extends StatelessWidget {
  const PreferenceTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Function()? onTap;

  String get keywords =>
      '${title.toLowerCase()} ${subtitle?.toLowerCase() ?? ''}';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: theme.primaryColor,
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
