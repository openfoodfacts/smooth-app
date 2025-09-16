import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/widgets/smooth_switch.dart';

class TogglePreferenceTile extends PreferenceTile {
  const TogglePreferenceTile({
    required super.title,
    required this.state,
    required this.onToggle,
    super.leading,
    super.icon,
    super.subtitleText,
    super.key,
  });

  final bool state;
  final Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return PreferenceTile(
      leading: leading,
      icon: icon,
      title: title,
      subtitleText: subtitleText,
      onTap: () => onToggle(!state),
      padding: const EdgeInsetsDirectional.only(
        start: LARGE_SPACE,
        end: SMALL_SPACE,
      ),
      trailing: SmoothSwitch(
        value: state,
        onChanged: onToggle,
        size: const Size(38.0, 24.0),
      ),
    );
  }
}
