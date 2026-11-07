import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/text/text_highlighter.dart';

/// The home card's meter without its shortfall line.
class DonationCampaignMeter extends StatelessWidget {
  const DonationCampaignMeter({
    required this.funding,
    required this.monthsLeft,
    required this.amountFormat,
  });

  final AppNewsFunding funding;
  final int? monthsLeft;
  final NumberFormat amountFormat;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final TextStyle? small = Theme.of(context).textTheme.bodySmall;
    final int? months = monthsLeft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: VERY_SMALL_SPACE,
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: SMALL_SPACE,
          runSpacing: VERY_SMALL_SPACE,
          children: <Widget>[
            TextWithBoldParts(
              text: appLocalizations.donation_reminder_funding(
                amountFormat.format(funding.raised),
                amountFormat.format(funding.goal),
              ),
              textStyle: small,
              boldTextStyle: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (months != null && months >= 1 && months <= 12)
              Text(
                appLocalizations.tagline_feed_funding_months_left(months),
                style: small,
              ),
          ],
        ),
        LinearProgressIndicator(
          value: funding.progress,
          semanticsValue: (funding.ratio * 100).round().toString(),
          minHeight: SMALL_SPACE,
          borderRadius: MAX_BORDER_RADIUS,
          color: context
              .extension<SmoothColorsThemeExtension>()
              .secondaryVibrant,
        ),
      ],
    );
  }
}
