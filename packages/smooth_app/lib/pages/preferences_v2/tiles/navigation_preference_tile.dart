import 'package:flutter/material.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';

class NavigationPreferenceTile extends PreferenceTile {
  const NavigationPreferenceTile({
    required super.icon,
    required super.title,
    required super.subtitle,
    required this.root,
  });

  final PreferencesRoot root;

  @override
  Widget build(BuildContext context) {
    return PreferenceTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) => root,
          ),
        );
      },
    );
  }
}
