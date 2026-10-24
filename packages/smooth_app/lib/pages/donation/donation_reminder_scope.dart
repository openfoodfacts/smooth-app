import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/donation/donation_offer.dart';
import 'package:smooth_app/pages/donation/donation_reminder_conditions.dart';
import 'package:smooth_app/pages/donation/donation_reminder_sheet.dart';

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
  bool _asked = false;

  @override
  void initState() {
    super.initState();

    final UserPreferences preferences = context.read<UserPreferences>();
    unawaited(preferences.countProductLookedUp(widget.barcode));

    _eligible = _isEligibleNow(DonationOffer.fromNews(_liveDonation()));
  }

  AppNewsItem? _liveDonation() {
    final AppNewsState? state = context.read<AppNewsProvider?>()?.state;
    return state is AppNewsStateLoaded ? state.content.donation : null;
  }

  bool _isEligibleNow(DonationOffer offer) {
    final UserPreferences preferences = context.read<UserPreferences>();
    final DateTime now = DateTime.now();
    return DonationReminderConditions(
      campaignLive: _liveDonation() != null,
      productsLookedUp: preferences.productsLookedUpSinceAsk,
      every: offer.reminderEvery,
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

        // A product page opened from this one may have shown the sheet (or
        // muted it) since [initState], and the feed may have reloaded.
        final DonationOffer offer = DonationOffer.fromNews(_liveDonation());
        if (!_isEligibleNow(offer)) {
          Navigator.of(context).pop();
          return;
        }

        final UserPreferences preferences = context.read<UserPreferences>();
        AnalyticsHelper.trackEvent(
          AnalyticsEvent.donationReminderShown,
          eventValue: offer.reminderEvery,
        );
        await preferences.markDonationReminderShown();
        if (!context.mounted) {
          return;
        }
        await showSmoothModalSheet<void>(
          context: context,
          builder: (BuildContext _) => DonationReminderSheet(offer: offer),
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
