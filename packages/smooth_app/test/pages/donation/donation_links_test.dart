import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';
import 'package:smooth_app/pages/donation/donation_links.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';

AppNewsItem _newsItem(String id) => AppNewsItem(
  id: id,
  title: 'title',
  message: 'message',
  url: 'https://world.openfoodfacts.org/',
);

void main() {
  group('DonationTier', () {
    test('has three tiers with the shipped amounts and anchors', () {
      expect(DonationTier.values.length, 3);
      expect(
        DonationTier.values
            .map((DonationTier tier) => tier.monthlyAmount)
            .toList(),
        <int>[3, 5, 10],
      );
      expect(
        DonationTier.values.map((DonationTier tier) => tier.scans).toList(),
        <int>[800, 1300, 2700],
      );
    });
  });

  group('buildDonationUrl', () {
    test('3 EUR monthly', () {
      expect(
        buildDonationUrl(DonationTier.eur3),
        'https://donorbox.org/embed/help-open-food-facts-stay-afloat'
        '?amount=3&default_interval=m&currency=eur'
        '&utm_source=off&utm_medium=smooth-app&utm_campaign=donation-2026'
        '&utm_content=donation-screen',
      );
    });

    test('5 EUR monthly', () {
      expect(
        buildDonationUrl(DonationTier.eur5),
        'https://donorbox.org/embed/help-open-food-facts-stay-afloat'
        '?amount=5&default_interval=m&currency=eur'
        '&utm_source=off&utm_medium=smooth-app&utm_campaign=donation-2026'
        '&utm_content=donation-screen',
      );
    });

    test('10 EUR monthly', () {
      expect(
        buildDonationUrl(DonationTier.eur10),
        'https://donorbox.org/embed/help-open-food-facts-stay-afloat'
        '?amount=10&default_interval=m&currency=eur'
        '&utm_source=off&utm_medium=smooth-app&utm_campaign=donation-2026'
        '&utm_content=donation-screen',
      );
    });

    test('one-off omits amount and default_interval', () {
      final String url = buildDonationUrl(null);

      expect(
        url,
        'https://donorbox.org/embed/help-open-food-facts-stay-afloat'
        '?currency=eur'
        '&utm_source=off&utm_medium=smooth-app&utm_campaign=donation-2026'
        '&utm_content=donation-screen',
      );
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
        buildDonationUrl(DonationTier.eur3, source: DonationSource.settings),
        'https://donorbox.org/embed/help-open-food-facts-stay-afloat'
        '?amount=3&default_interval=m&currency=eur'
        '&utm_source=off&utm_medium=smooth-app&utm_campaign=donation-2026'
        '&utm_content=donation-screen-settings',
      );
    });

    test('rides along as utm_content on the one-off URL', () {
      expect(
        buildDonationUrl(null, source: DonationSource.tagline),
        'https://donorbox.org/embed/help-open-food-facts-stay-afloat'
        '?currency=eur'
        '&utm_source=off&utm_medium=smooth-app&utm_campaign=donation-2026'
        '&utm_content=donation-screen-tagline',
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

  group('isDonationNewsItem', () {
    test('matches the live donation item', () {
      expect(isDonationNewsItem(_newsItem('donation_campaign_2026')), isTrue);
    });

    test('is case insensitive and future-campaign proof', () {
      expect(isDonationNewsItem(_newsItem('DONATION_CAMPAIGN_2027')), isTrue);
      expect(isDonationNewsItem(_newsItem('donation_campaign_2027')), isTrue);
      expect(isDonationNewsItem(_newsItem('donations-are-great')), isTrue);
    });

    test('does not match the other items live in the feed', () {
      expect(
        isDonationNewsItem(_newsItem('nutriscore_petition_2025')),
        isFalse,
      );
      expect(
        isDonationNewsItem(_newsItem('openprices_challenge_01_06')),
        isFalse,
      );
      expect(isDonationNewsItem(_newsItem('divinfood_survey_2026')), isFalse);
    });

    test('matches a prefix, not a substring', () {
      expect(isDonationNewsItem(_newsItem('campaign_donation_2026')), isFalse);
    });
  });
}
