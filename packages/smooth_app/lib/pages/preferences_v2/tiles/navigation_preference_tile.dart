import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';

class NavigationPreferenceTile extends PreferenceTile {
  const NavigationPreferenceTile({
    required super.title,
    required super.subtitleText,
    super.icon,
    super.leading,
    this.root,
    this.target,
  }) : assert(
         (root != null && target == null) || (root == null && target != null),
         'Either root or target must be provided, not both.',
       );

  final PreferencesRoot? root;
  final Widget? target;

  @override
  Widget build(BuildContext context) {
    return PreferenceTile(
      icon: icon,
      leading: leading,
      title: title,
      subtitleText: subtitleText,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) => root != null
                ? ChangeNotifierProvider<PreferencesRootSearchController>(
                    create: (_) => PreferencesRootSearchController(),
                    child: root,
                  )
                : target!,
          ),
        );
      },
    );
  }
}
