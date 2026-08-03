import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';

/// Monthly donation tiers offered on the donation page.
///
/// [scans] is how many server-side scans a month of that tier covers, derived
/// from Open Food Facts' published 2026 infrastructure budget and scan volume
/// and rounded down.
enum DonationTier {
  eur3(monthlyAmount: 3, scans: 800),
  eur5(monthlyAmount: 5, scans: 1300),
  eur10(monthlyAmount: 10, scans: 2700);

  const DonationTier({required this.monthlyAmount, required this.scans});

  final int monthlyAmount;
  final int scans;
}

const String _campaignUrl =
    'https://donorbox.org/help-open-food-facts-stay-afloat';

const String _utm =
    'utm_source=off&utm_medium=smooth-app&utm_campaign=donation-2026'
    '&utm_content=donation-screen';

/// Donorbox URL preselecting [tier], or the plain one-off form when null.
///
/// Concatenated rather than built with [Uri] because the parameter order is
/// part of the contract and [Uri] both reorders and re-encodes the query.
String buildDonationUrl(DonationTier? tier) => tier == null
    ? '$_campaignUrl?currency=eur&$_utm'
    : '$_campaignUrl?amount=${tier.monthlyAmount}&default_interval=m'
          '&currency=eur&$_utm';

/// Whether [item] is the donation ask, and therefore opens the donation page
/// instead of its own URL.
///
/// Keyed on the id prefix so it survives the ~22 localized campaign URLs; a
/// renamed id simply falls back to the browser handoff.
bool isDonationNewsItem(AppNewsItem item) =>
    item.id.toLowerCase().startsWith('donation');
