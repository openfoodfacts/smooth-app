import 'package:flutter/material.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/widgets/smooth_switch.dart';

class TogglePreferenceTile extends PreferenceTile {
  const TogglePreferenceTile({
    required super.title,
    required this.state,
    required this.onToggle,
    super.icon,
    super.subtitleText,
  });

  final bool state;
  final Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return PreferenceTile(
      icon: icon,
      title: title,
      subtitleText: subtitleText,
      trailing: SmoothSwitch(value: state, onChanged: onToggle),
    );
  }
}
