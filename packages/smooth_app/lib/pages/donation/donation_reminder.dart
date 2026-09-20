import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/donation/donation_offer.dart';
import 'package:smooth_app/pages/donation/donation_tier_row.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

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

/// The reminder itself: donor count, a body line, the three tiers, and the
/// three ways to close it. Never reads a [Product] - a donation ask must read
/// as support for Open Food Facts, not for whatever brand is on screen.
class DonationReminderSheet extends StatefulWidget {
  const DonationReminderSheet({required this.offer});

  final DonationOffer offer;

  @override
  State<DonationReminderSheet> createState() => _DonationReminderSheetState();
}

class _DonationReminderSheetState extends State<DonationReminderSheet> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.offer.defaultAmount;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final DonationOffer offer = widget.offer;
    final int? donorCount = offer.donorCount;
    final NumberFormat amountFormat = offer.amountFormat(
      appLocalizations.localeName,
    );
    final NumberFormat numberFormat = offer.numberFormat(
      appLocalizations.localeName,
    );

    return SmoothModalSheet(
      title: appLocalizations.contribute_donate_header,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: MEDIUM_SPACE,
        children: <Widget>[
          Text(
            donorCount == null
                ? appLocalizations.donation_reminder_title_generic
                : appLocalizations.donation_reminder_title(donorCount),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(appLocalizations.donation_reminder_body),
          for (final DonationTier tier in offer.tiers)
            DonationTierRow(
              selected: tier.amount == _selected,
              amount: appLocalizations.donation_tier_amount_monthly(
                amountFormat.format(tier.amount),
              ),
              scans: appLocalizations.donation_tier_scans(
                numberFormat.format(tier.scans),
              ),
              onTap: () => setState(() => _selected = tier.amount),
            ),
          SmoothLargeButtonWithIcon(
            text: appLocalizations.donation_cta_monthly,
            leadingIcon: const icons.Donate(),
            onPressed: () => _handoff(context),
          ),
          TextButton(
            onPressed: () => _notNow(context),
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(MINIMUM_TOUCH_SIZE),
            ),
            child: Text(appLocalizations.donation_reminder_not_now),
          ),
          Wrap(
            spacing: MEDIUM_SPACE,
            children: <Widget>[
              TextButton(
                onPressed: () => _alreadyDonated(context),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(MINIMUM_TOUCH_SIZE),
                ),
                child: Text(appLocalizations.donation_already_donated),
              ),
              TextButton(
                onPressed: () => _neverAgain(context),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(MINIMUM_TOUCH_SIZE),
                ),
                child: Text(appLocalizations.donation_reminder_never_again),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Pops before launching, so Donorbox returns to the product list rather
  /// than a stale sheet.
  Future<void> _handoff(BuildContext context) async {
    AnalyticsHelper.trackEvent(
      AnalyticsEvent.donationReminderHandoff,
      eventValue: _selected,
    );
    final UserPreferences preferences = context.read<UserPreferences>();
    final String url = widget.offer
        .tier(_selected)
        .url(source: DonationSource.reminder);
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

  Future<void> _neverAgain(BuildContext context) async {
    AnalyticsHelper.trackEvent(AnalyticsEvent.donationReminderNeverAgain);
    final UserPreferences preferences = context.read<UserPreferences>();
    Navigator.of(context).pop();
    await preferences.setDonationRemindersDisabled(true);
  }
}
