import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';
import 'package:smooth_app/pages/donation/donation_links.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';

AppNewsItem _newsItem({
  String? currency,
  List<int>? donationAmounts,
  int? donationScansPerUnit,
  List<String>? donationWhereItGoes,
}) => AppNewsItem(
  id: 'donation_campaign_2026',
  title: 'title',
  message: 'message',
  url: 'https://world.openfoodfacts.org/',
  currency: currency,
  donationAmounts: donationAmounts,
  donationScansPerUnit: donationScansPerUnit,
  donationWhereItGoes: donationWhereItGoes,
);

const String _campaign =
    'https://donorbox.org/embed/help-open-food-facts-stay-afloat';
const String _utm =
    '&utm_source=off&utm_medium=smooth-app&utm_campaign=donation-2026';

void main() {
  group('DonationOffer.fromNews', () {
    test('falls back to the shipped offer when there is no news item', () {
      final DonationOffer offer = DonationOffer.fromNews(null);

      expect(offer.currency, 'EUR');
      expect(offer.amounts, <int>[3, 5, 10]);
      expect(offer.scansPerUnit, 270);
      expect(offer.whereItGoes, isEmpty);
      expect(offer.defaultAmount, 5);
    });

    test('falls back field by field when the feed carries none of it', () {
      final DonationOffer offer = DonationOffer.fromNews(_newsItem());

      expect(offer.currency, 'EUR');
      expect(offer.amounts, <int>[3, 5, 10]);
      expect(offer.scansPerUnit, 270);
      expect(offer.whereItGoes, isEmpty);
    });

    test('takes what the feed declares', () {
      final DonationOffer offer = DonationOffer.fromNews(
        _newsItem(
          currency: 'USD',
          donationAmounts: <int>[5, 10, 25, 50],
          donationScansPerUnit: 200,
          donationWhereItGoes: <String>['Servers', 'One engineer'],
        ),
      );

      expect(offer.currency, 'USD');
      expect(offer.amounts, <int>[5, 10, 25, 50]);
      expect(offer.scansPerUnit, 200);
      expect(offer.whereItGoes, <String>['Servers', 'One engineer']);
      expect(offer.defaultAmount, 25);
    });

    test('refuses a currency that is not a three letter code', () {
      expect(
        DonationOffer.fromNews(_newsItem(currency: 'EURO')).currency,
        'EUR',
      );
      expect(DonationOffer.fromNews(_newsItem(currency: '')).currency, 'EUR');
    });

    test('refuses amounts that are not all positive', () {
      expect(
        DonationOffer.fromNews(
          _newsItem(donationAmounts: <int>[3, 0, 10]),
        ).amounts,
        <int>[3, 5, 10],
      );
      expect(
        DonationOffer.fromNews(_newsItem(donationAmounts: <int>[])).amounts,
        <int>[3, 5, 10],
      );
    });

    test('refuses a scan anchor that is not positive', () {
      expect(
        DonationOffer.fromNews(_newsItem(donationScansPerUnit: 0)).scansPerUnit,
        270,
      );
    });
  });

  group('DonationTier.scans', () {
    test('cross-multiplies the shipped ladder', () {
      final DonationOffer offer = DonationOffer.fromNews(null);

      expect(offer.tiers.map((DonationTier tier) => tier.scans).toList(), <int>[
        800,
        1300,
        2700,
      ]);
    });

    test('rounds down to the hundred', () {
      final DonationOffer offer = DonationOffer.fromNews(
        _newsItem(donationAmounts: <int>[1, 7]),
      );

      expect(offer.tier(1).scans, 200);
      expect(offer.tier(7).scans, 1800);
    });

    test('follows the anchor the feed declares', () {
      expect(
        DonationOffer.fromNews(
          _newsItem(donationScansPerUnit: 200),
        ).tier(10).scans,
        2000,
      );
    });
  });

  group('DonationTier.url', () {
    test('preselects the amount, the monthly interval and the currency', () {
      final DonationOffer offer = DonationOffer.fromNews(null);

      expect(
        offer.tier(3).url(),
        '$_campaign?amount=3&default_interval=m&currency=eur'
        '$_utm&utm_content=donation-screen',
      );
      expect(
        offer.tier(5).url(),
        '$_campaign?amount=5&default_interval=m&currency=eur'
        '$_utm&utm_content=donation-screen',
      );
      expect(
        offer.tier(10).url(),
        '$_campaign?amount=10&default_interval=m&currency=eur'
        '$_utm&utm_content=donation-screen',
      );
    });

    test('carries the currency the feed declares', () {
      expect(
        DonationOffer.fromNews(_newsItem(currency: 'USD')).tier(5).url(),
        '$_campaign?amount=5&default_interval=m&currency=usd'
        '$_utm&utm_content=donation-screen',
      );
    });
  });

  group('DonationOffer.oneOffUrl', () {
    test('omits the amount and the interval', () {
      final String url = DonationOffer.fromNews(null).oneOffUrl();

      expect(url, '$_campaign?currency=eur$_utm&utm_content=donation-screen');
      expect(url.contains('amount'), isFalse);
      expect(url.contains('default_interval'), isFalse);
    });
  });

  group('DonationSource', () {
    test('gives each entry point its own analytics value', () {
      expect(
        DonationSource.values
            .map((DonationSource source) => source.analyticsValue)
            .toList(),
        <int>[1, 2],
      );
    });

    test('rides along as utm_content on a tier URL', () {
      expect(
        DonationOffer.fromNews(
          null,
        ).tier(3).url(source: DonationSource.settings),
        '$_campaign?amount=3&default_interval=m&currency=eur'
        '$_utm&utm_content=donation-screen-settings',
      );
    });

    test('rides along as utm_content on the one-off URL', () {
      expect(
        DonationOffer.fromNews(null).oneOffUrl(source: DonationSource.tagline),
        '$_campaign?currency=eur$_utm&utm_content=donation-screen-tagline',
      );
    });

    test('is carried by the route', () {
      expect(
        AppRoutes.DONATE(DonationSource.settings),
        '/_donate?source=settings',
      );
      expect(
        AppRoutes.DONATE(DonationSource.tagline),
        '/_donate?source=tagline',
      );
    });
  });
}
