import 'package:flutter/material.dart';

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
