import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

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
