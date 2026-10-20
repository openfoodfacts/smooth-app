import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/donation/donation_tier_row.dart';
import 'package:smooth_app/widgets/text/text_highlighter.dart';

class DonationTierChip extends StatelessWidget {
  const DonationTierChip({
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
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Semantics(
      selected: selected,
      button: true,
      label: appLocalizations.donation_tier_amount_monthly(amount),
      onTap: onTap,
      excludeSemantics: true,
      child: DonationLadderOutline(
        active: selected,
        child: InkWell(
          borderRadius: ROUNDED_BORDER_RADIUS,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: SMALL_SPACE,
              horizontal: VERY_SMALL_SPACE,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextWithBoldParts(
                  text: appLocalizations.donation_tier_chip_amount(amount),
                  textStyle: textTheme.bodySmall,
                  boldTextStyle: textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                Text(
                  appLocalizations.donation_tier_scans_short(scans),
                  style: textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
