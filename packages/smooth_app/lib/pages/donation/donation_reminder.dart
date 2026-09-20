import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/donation/donation_offer.dart';
import 'package:smooth_app/pages/donation/donation_tier_row.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';

/// The five conditions that gate the donation reminder sheet, computed once
/// per product page so [PopScope.canPop] never re-evaluates mid-visit.
class DonationReminderConditions {
  const DonationReminderConditions({
    required this.campaignLive,
    required this.productsLookedUp,
    required this.every,
    required this.muted,
    required this.appLaunches,
    required this.lastShownAt,
    required this.now,
  });

  /// Reminders never fire in the install session, however many products a
  /// user looks up before the app counts a second launch.
  static const int minLaunches = 2;
  static const Duration gap = Duration(days: 30);

  final bool campaignLive;
  final int productsLookedUp;
  final int every;
  final bool muted;
  final int appLaunches;
  final DateTime? lastShownAt;
  final DateTime now;

  bool get eligible =>
      campaignLive &&
      productsLookedUp >= every &&
      !muted &&
      appLaunches >= minLaunches &&
      (lastShownAt == null || now.difference(lastShownAt!) >= gap);
}

/// Wraps a product page: counts the lookup, and - if the visit is the one
/// that crosses the threshold - shows the reminder sheet on the way out
/// instead of popping immediately.
class DonationReminderScope extends StatefulWidget {
  const DonationReminderScope({required this.barcode, required this.child});

  final String barcode;
  final Widget child;

  @override
  State<DonationReminderScope> createState() => _DonationReminderScopeState();
}

class _DonationReminderScopeState extends State<DonationReminderScope> {
  late final bool _eligible;
  late final DonationOffer _offer;
  bool _asked = false;

  @override
  void initState() {
    super.initState();

    final UserPreferences preferences = context.read<UserPreferences>();
    unawaited(preferences.countProductLookedUp(widget.barcode));

    final AppNewsState? state = context.read<AppNewsProvider?>()?.state;
    final AppNewsItem? donation = state is AppNewsStateLoaded
        ? state.content.donation
        : null;
    _offer = DonationOffer.fromNews(donation);

    final DateTime now = DateTime.now();
    _eligible = DonationReminderConditions(
      campaignLive: donation != null,
      productsLookedUp: preferences.productsLookedUpSinceAsk,
      every: _offer.reminderEvery,
      muted: preferences.donationAsksMuted(now),
      appLaunches: preferences.appLaunches,
      lastShownAt: preferences.lastReminderShownAt,
      now: now,
    ).eligible;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_eligible,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop || _asked) {
          return;
        }
        _asked = true;

        final UserPreferences preferences = context.read<UserPreferences>();
        AnalyticsHelper.trackEvent(
          AnalyticsEvent.donationReminderShown,
          eventValue: _offer.reminderEvery,
        );
        await preferences.markDonationReminderShown();
        if (!context.mounted) {
          return;
        }
        await showSmoothModalSheet<void>(
          context: context,
          builder: (BuildContext _) => DonationReminderSheet(offer: _offer),
        );
        if (!context.mounted) {
          return;
        }
        Navigator.of(context).pop();
      },
      child: widget.child,
    );
  }
}

/// The reminder itself: headline, one body line, the campaign meter, the
/// tiers, and the ways to close it. Never reads a [Product] - a donation ask
/// must read as support for Open Food Facts, not for whatever brand is on
/// screen.
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
              _CampaignMeter(
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
                      child: _TierChip(
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
                  const Text('·'),
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

/// Raised over goal, the bar, and the months left - the home card's meter
/// without its shortfall line.
class _CampaignMeter extends StatelessWidget {
  const _CampaignMeter({
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
        Row(
          spacing: VERY_SMALL_SPACE,
          children: <Widget>[
            Text(
              amountFormat.format(funding.raised),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                appLocalizations.tagline_feed_funding_goal(
                  amountFormat.format(funding.goal),
                ),
                style: small,
              ),
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

/// One tier of the ladder, sized for three in a row: the amount and the scans
/// it covers. "A month" is on the button below, not repeated three times.
class _TierChip extends StatelessWidget {
  const _TierChip({
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
                Text.rich(
                  TextSpan(
                    text: amount,
                    style: textTheme.headlineMedium,
                    children: <InlineSpan>[
                      TextSpan(
                        text: ' ${appLocalizations.donation_tier_per_month}',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
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
