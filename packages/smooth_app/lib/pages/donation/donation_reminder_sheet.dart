import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/donation/donation_campaign_meter.dart';
import 'package:smooth_app/pages/donation/donation_offer.dart';
import 'package:smooth_app/pages/donation/donation_tier_chip.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// Never reads a [Product] - a donation ask must read as support for Open
/// Food Facts, not for whatever brand is on screen.
class DonationReminderSheet extends StatefulWidget {
  const DonationReminderSheet({required this.offer});

  final DonationOffer offer;

  @override
  State<DonationReminderSheet> createState() => _DonationReminderSheetState();
}

class _DonationReminderSheetState extends State<DonationReminderSheet> {
  static final ButtonStyle _linkStyle = TextButton.styleFrom(
    minimumSize: const Size(0, MINIMUM_TOUCH_SIZE),
    padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
    textStyle: const TextStyle(
      fontSize: 13.0,
      decoration: TextDecoration.underline,
    ),
  );

  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.offer.defaultAmount;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DonationOffer offer = widget.offer;
    final int? donorCount = offer.donorCount;
    final AppNewsFunding? funding = offer.funding;
    final NumberFormat amountFormat = offer.amountFormat(
      appLocalizations.localeName,
    );
    final NumberFormat numberFormat = offer.numberFormat(
      appLocalizations.localeName,
    );

    return SmoothModalSheet(
      title: appLocalizations.contribute_donate_header,
      bodyPadding: EdgeInsetsDirectional.zero,
      body: SmoothModalSheetBodyContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: LARGE_SPACE),
            Text(
              donorCount == null
                  ? appLocalizations.donation_reminder_title_generic
                  : appLocalizations.donation_reminder_title(donorCount),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: MEDIUM_SPACE),
            Text(appLocalizations.donation_reminder_body),
            if (funding != null) ...<Widget>[
              const SizedBox(height: LARGE_SPACE),
              DonationCampaignMeter(
                funding: funding,
                monthsLeft: offer.monthsLeft,
                amountFormat: amountFormat,
              ),
            ],
            const SizedBox(height: VERY_LARGE_SPACE),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: SMALL_SPACE,
                children: <Widget>[
                  for (final DonationTier tier in offer.tiers)
                    Expanded(
                      child: DonationTierChip(
                        selected: tier.amount == _selected,
                        amount: amountFormat.format(tier.amount),
                        scans: numberFormat.format(tier.scans),
                        onTap: () => setState(() => _selected = tier.amount),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: VERY_LARGE_SPACE),
            ElevatedButton.icon(
              icon: icons.Donate(color: colorScheme.onSecondary),
              label: Text(
                appLocalizations.donation_reminder_cta(
                  amountFormat.format(_selected),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                minimumSize: const Size.fromHeight(MINIMUM_TOUCH_SIZE),
                shape: const RoundedRectangleBorder(
                  borderRadius: ROUNDED_BORDER_RADIUS,
                ),
              ),
              onPressed: () => _handoff(
                context,
                offer.tier(_selected).url(source: DonationSource.reminder),
                _selected,
              ),
            ),
            TextButton(
              onPressed: () => _handoff(
                context,
                offer.oneOffUrl(source: DonationSource.reminder),
                0,
              ),
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(MINIMUM_TOUCH_SIZE),
              ),
              child: Text(appLocalizations.donation_cta_one_off),
            ),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: SMALL_SPACE,
                children: <Widget>[
                  TextButton(
                    onPressed: () => _alreadyDonated(context),
                    style: _linkStyle,
                    child: Text(appLocalizations.donation_already_donated),
                  ),
                  const ExcludeSemantics(child: Text('·')),
                  TextButton(
                    onPressed: () => _notNow(context),
                    style: _linkStyle,
                    child: Text(appLocalizations.donation_reminder_not_now),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pops before launching, so Donorbox returns to the product list rather
  /// than a stale sheet. [monthlyAmount] is 0 for a one-off, as on the
  /// Support screen.
  Future<void> _handoff(
    BuildContext context,
    String url,
    int monthlyAmount,
  ) async {
    AnalyticsHelper.trackEvent(
      AnalyticsEvent.donationReminderHandoff,
      eventValue: monthlyAmount,
    );
    final UserPreferences preferences = context.read<UserPreferences>();
    Navigator.of(context).pop();
    unawaited(LaunchUrlHelper.launchURLInBrowserView(url));
    await preferences.muteDonationAsks(const Duration(days: 90));
  }

  void _notNow(BuildContext context) {
    AnalyticsHelper.trackEvent(AnalyticsEvent.donationReminderNotNow);
    Navigator.of(context).pop();
  }

  Future<void> _alreadyDonated(BuildContext context) async {
    AnalyticsHelper.trackEvent(
      AnalyticsEvent.donationAlreadyDonated,
      eventValue: DonationSource.reminder.analyticsValue,
    );
    final UserPreferences preferences = context.read<UserPreferences>();
    Navigator.of(context).pop();
    await preferences.muteDonationAsks(const Duration(days: 365));
  }
}
