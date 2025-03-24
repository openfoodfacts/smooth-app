import 'package:flutter/material.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/widgets/smooth_switch.dart';

class TogglePreferenceTile extends PreferenceTile {
  TogglePreferenceTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.state,
    required this.onToggle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool state;
  final Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: SmoothSwitch(
        value: state,
        onChanged: (bool value) {
          onToggle(value);
        },
      ),
    );
  }

  @override
  String get keywords =>
      '${title.toLowerCase()} ${subtitle?.toLowerCase() ?? ''}';
}
