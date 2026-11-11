import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/donation/donation_ladder_outline.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

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
