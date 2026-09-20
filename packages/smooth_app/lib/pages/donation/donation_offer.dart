import 'package:intl/intl.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';

/// Entry point the donation page was opened from.
enum DonationSource {
  settings(analyticsValue: 1),
  tagline(analyticsValue: 2),
  reminder(analyticsValue: 3);

  const DonationSource({required this.analyticsValue});

  final int analyticsValue;
}

/// `/embed/` rather than the hosted campaign page: same Donorbox campaign, but
/// it opens on the amount step instead of below a full marketing layout, and it
/// is what Open Food Facts' own donate page renders through `widgets.js`.
const String _campaignUrl =
    'https://donorbox.org/embed/help-open-food-facts-stay-afloat';

/// Built by hand rather than with [Uri]: the parameter order is part of the
/// contract and [Uri] both reorders and re-encodes the query.
String _utm(DonationSource? source) =>
    'utm_source=off&utm_medium=smooth-app&utm_campaign=donation-2026'
    '&utm_content=donation-screen${source == null ? '' : '-${source.name}'}';

/// What the donation page offers, as the news feed declares it.
///
/// Donorbox charges in the campaign's own currency, so a non-Euro campaign is
/// a change Open Food Facts makes on both sides at once: the feed says what the
/// app shows, the campaign says what the donor is charged.
class DonationOffer {
  const DonationOffer({
    required this.currency,
    required this.amounts,
    required this.scansPerUnit,
    required this.whereItGoes,
    required this.reminderEvery,
    required this.donorCount,
  });

  /// Falls back field by field, so a feed carrying none of this renders the
  /// screen exactly as it shipped.
  factory DonationOffer.fromNews(AppNewsItem? item) {
    final String? currency = item?.currency;
    final List<int> amounts = _ladder(item?.donationAmounts);
    final num? scansPerUnit = item?.donationScansPerUnit;
    final num? reminderEvery = item?.donationReminderEvery;
    final num? donorCount = item?.count;

    return DonationOffer(
      currency: currency != null && currency.length == 3
          ? currency
          : _fallbackCurrency,
      amounts: amounts.isEmpty ? _fallbackAmounts : amounts,
      scansPerUnit: scansPerUnit != null && _isUsable(scansPerUnit)
          ? scansPerUnit.toInt()
          : _fallbackScansPerUnit,
      whereItGoes: item?.donationWhereItGoes ?? const <String>[],
      reminderEvery: reminderEvery != null && _isUsableCount(reminderEvery)
          ? reminderEvery.toInt()
          : _fallbackReminderEvery,
      donorCount: donorCount != null && _isUsableCount(donorCount)
          ? donorCount.toInt()
          : null,
    );
  }

  /// Tolerant of the container, not only of its elements: a cast in front of
  /// `whereType` throws on `"donation_amounts": 5`, and the news parser answers
  /// any throw with an empty feed for every user.
  static List<T>? feedList<T>(dynamic value) => value is Iterable<dynamic>
      ? value.whereType<T>().toList(growable: false)
      : null;

  static const String _fallbackCurrency = 'EUR';
  static const List<int> _fallbackAmounts = <int>[3, 5, 10];

  /// Scans a month of one currency unit covers, from Open Food Facts'
  /// published 2026 infrastructure budget over their published scan volume.
  static const int _fallbackScansPerUnit = 270;

  static const int _fallbackReminderEvery = 10;

  /// Sorted and deduplicated: the slider walks the ladder by index, so an
  /// unordered feed makes dragging right ask for less money, and a repeated
  /// amount selects two rows at once.
  static List<int> _ladder(List<num>? amounts) {
    if (amounts == null || amounts.isEmpty || !amounts.every(_isUsable)) {
      return const <int>[];
    }
    return amounts.map((num amount) => amount.toInt()).toSet().toList()..sort();
  }

  /// `isFinite` because `toInt()` throws on the infinity a JSON `1e400` decodes
  /// to, the same guard [AppNewsFunding.tryFrom] carries.
  static bool _isUsable(num amount) => amount.isFinite && amount > 0;

  /// Stricter than [_isUsable]: a count is read out loud as a whole number,
  /// so `0.5` (which `_isUsable` would accept) must not truncate to a
  /// displayed `0`.
  static bool _isUsableCount(num value) => value.isFinite && value >= 1;

  final String currency;
  final List<int> amounts;
  final int scansPerUnit;

  /// Empty when the feed says nothing, in which case the page keeps its own
  /// translated lines.
  final List<String> whereItGoes;

  final int reminderEvery;

  /// Donors so far, for the reminder sheet's headline. Null when the feed
  /// carries nothing usable, which falls back to a generic headline.
  final int? donorCount;

  List<DonationTier> get tiers => amounts.map(tier).toList(growable: false);

  DonationTier tier(int amount) => DonationTier(
    amount: amount,
    currency: currency,
    scansPerUnit: scansPerUnit,
  );

  int get defaultAmount => amounts[amounts.length ~/ 2];

  /// Donation form with no amount and no interval, so it opens on its own
  /// one-time default.
  String oneOffUrl({DonationSource? source}) =>
      '$_campaignUrl?currency=${currency.toLowerCase()}&${_utm(source)}';

  /// [AppLocalizations.localeName] rather than [ProductQuery]: it is the
  /// locale the sentence itself is in. `intl` ships no number symbols for 46
  /// of the app's 128 locales and both constructors throw there, so fall back
  /// rather than lose the tier picker to an ErrorWidget.
  String _usableLocale(String localeName) =>
      NumberFormat.localeExists(localeName) ? localeName : 'en';

  NumberFormat amountFormat(String localeName) => NumberFormat.simpleCurrency(
    locale: _usableLocale(localeName),
    name: currency,
    decimalDigits: 0,
  );

  NumberFormat numberFormat(String localeName) =>
      NumberFormat.decimalPattern(_usableLocale(localeName));
}

class DonationTier {
  const DonationTier({
    required this.amount,
    required this.currency,
    required this.scansPerUnit,
  });

  final int amount;
  final String currency;
  final int scansPerUnit;

  /// Rounded down to the hundred, so the figure reads as an order of magnitude
  /// and always understates what the money covers.
  int get scans => amount * scansPerUnit ~/ 100 * 100;

  String url({DonationSource? source}) =>
      '$_campaignUrl?amount=$amount&default_interval=m'
      '&currency=${currency.toLowerCase()}&${_utm(source)}';
}
