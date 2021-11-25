import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String getDaysAgoLabel(BuildContext context, final int daysAgo) {
  final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
  final int weeksAgo = (daysAgo.toDouble() / 7).round();
  final int monthsAgo = (daysAgo.toDouble() / (365.25 / 12)).round();
  if (daysAgo == 0) {
    return appLocalizations.today;
  }
  if (daysAgo == 1) {
    return appLocalizations.yesterday;
  }
  if (daysAgo < 7) {
    return appLocalizations.plural_ago_days(daysAgo);
  }
  if (weeksAgo == 1) {
    return appLocalizations.plural_ago_weeks(1);
  }
  if (monthsAgo == 0) {
    return appLocalizations.plural_ago_weeks(weeksAgo);
  }
  if (monthsAgo == 1) {
    return appLocalizations.plural_ago_months(1);
  }
  return appLocalizations.plural_ago_months(monthsAgo);
}