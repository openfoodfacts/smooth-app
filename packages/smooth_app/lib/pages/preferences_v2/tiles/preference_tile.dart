import 'package:flutter/material.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';

abstract class PreferenceTile extends StatelessWidget {
  String get keywords;
}

class NavigationPreferenceTile extends PreferenceTile {
  NavigationPreferenceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.root,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final PreferencesRoot root;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {},
    );
  }

  @override
  String get keywords => '${title.toLowerCase()} ${subtitle.toLowerCase()}';
}
