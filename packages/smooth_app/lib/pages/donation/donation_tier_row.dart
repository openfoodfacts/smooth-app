import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// The outline every pickable thing in a donation ladder shares.
class DonationLadderOutline extends StatelessWidget {
  const DonationLadderOutline({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: ROUNDED_BORDER_RADIUS,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: ROUNDED_BORDER_RADIUS,
          // Everything is outlined so it all reads as pickable; only the
          // opacity moves, so choosing never shifts the list.
          border: Border.all(
            width: 2.0,
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: active ? 1.0 : 0.25),
          ),
        ),
        child: child,
      ),
    );
  }
}

class DonationTierRow extends StatelessWidget {
  const DonationTierRow({
    required this.selected,
    required this.amount,
    required this.scans,
    required this.onTap,
  });

  final bool selected;
  final String amount;
  final String scans;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        selected: selected,
        child: DonationLadderOutline(
          active: selected,
          child: PreferenceTile(
            leading: selected
                ? const icons.CheckBox.filled()
                : const icons.CheckBox(),
            title: amount,
            subtitleText: scans,
            trailing: EMPTY_WIDGET,
            borderRadius: ROUNDED_BORDER_RADIUS,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
