import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';

AppNewsItem _newsItem({
  String id = 'donation_campaign_2026',
  DateTime? endDate,
  num? raised,
  num? goal,
  String? currency,
}) => AppNewsItem(
  id: id,
  title: 'Our application needs you!',
  message: 'Help us inform millions of consumers on what they eat!',
  url: 'https://world.openfoodfacts.org/donate-to-open-food-facts',
  endDate: endDate,
  raised: raised,
  goal: goal,
  currency: currency,
);

void main() {
  group('AppNewsFunding.tryFrom', () {
    test('accepts a full valid set', () {
      final AppNewsFunding? funding = AppNewsFunding.tryFrom(
        44059.47,
        170000.0,
        'EUR',
      );

      expect(funding, isNotNull);
      expect(funding!.raised, 44059.47);
      expect(funding.goal, 170000.0);
      expect(funding.currency, 'EUR');
      expect(funding.ratio, closeTo(0.259, 0.001));
      expect(funding.progress, closeTo(0.259, 0.001));
      expect(funding.shortfall, closeTo(125940.53, 0.01));
    });

    test('refuses a missing raised', () {
      expect(AppNewsFunding.tryFrom(null, 170000.0, 'EUR'), isNull);
    });

    test('refuses a missing goal', () {
      expect(AppNewsFunding.tryFrom(44059.47, null, 'EUR'), isNull);
    });

    test('refuses a missing currency', () {
      expect(AppNewsFunding.tryFrom(44059.47, 170000.0, null), isNull);
    });

    test('refuses a zero or negative goal', () {
      expect(AppNewsFunding.tryFrom(44059.47, 0.0, 'EUR'), isNull);
      expect(AppNewsFunding.tryFrom(44059.47, -170000.0, 'EUR'), isNull);
    });

    test('refuses a negative raised', () {
      expect(AppNewsFunding.tryFrom(-1.0, 170000.0, 'EUR'), isNull);
    });

    test('refuses non finite values', () {
      expect(AppNewsFunding.tryFrom(double.infinity, 170000.0, 'EUR'), isNull);
      expect(AppNewsFunding.tryFrom(double.nan, 170000.0, 'EUR'), isNull);
      expect(AppNewsFunding.tryFrom(44059.47, double.infinity, 'EUR'), isNull);
      expect(AppNewsFunding.tryFrom(44059.47, double.nan, 'EUR'), isNull);
    });

    test('refuses a currency that is not a 3 letter code', () {
      expect(AppNewsFunding.tryFrom(44059.47, 170000.0, ''), isNull);
      expect(AppNewsFunding.tryFrom(44059.47, 170000.0, '€'), isNull);
      expect(AppNewsFunding.tryFrom(44059.47, 170000.0, 'EURO'), isNull);
    });

    test('clamps the bar but not the percentage when overfunded', () {
      final AppNewsFunding funding = AppNewsFunding.tryFrom(
        190400.0,
        170000.0,
        'EUR',
      )!;

      expect(funding.ratio, closeTo(1.12, 0.001));
      expect(funding.progress, 1.0);
      expect(funding.shortfall, lessThan(0.0));
    });
  });

  group('AppNewsItem.funding', () {
    test('is available when the three fields are there', () {
      expect(
        _newsItem(raised: 44059.47, goal: 170000.0, currency: 'EUR').funding,
        isNotNull,
      );
    });

    test('is absent without the fields', () {
      expect(_newsItem().funding, isNull);
    });
  });

  group('AppNewsStyle.fromHex', () {
    test('keeps a feed colour opaque', () {
      final AppNewsStyle style = AppNewsStyle.fromHex(
        messageTextColor: '#123456',
        titleIndicatorColor: '#FFFFFF',
      );

      expect(style.messageTextColor, const Color(0xFF123456));
      expect(style.titleIndicatorColor, const Color(0xFFFFFFFF));
    });

    test('ignores a value it cannot read', () {
      expect(AppNewsStyle.fromHex().messageTextColor, isNull);
      expect(
        AppNewsStyle.fromHex(messageTextColor: '123456').messageTextColor,
        isNull,
      );
      expect(
        AppNewsStyle.fromHex(messageTextColor: '#GGGGGG').messageTextColor,
        isNull,
      );
    });
  });

  group('AppNewsItem.monthsLeft', () {
    /// [months] calendar months from today, whatever the day the test runs on.
    AppNewsItem endingIn(int months) {
      final DateTime now = DateTime.now();
      return _newsItem(
        endDate: DateTime(now.year, now.month + months, now.day, 23, 59, 59),
      );
    }

    test('is null without an end date', () {
      expect(_newsItem().monthsLeft, isNull);
    });

    test('is 0 for the current month', () {
      expect(endingIn(0).monthsLeft, 0);
    });

    test('is 1 for the next month', () {
      expect(endingIn(1).monthsLeft, 1);
    });

    test('is 5 across a year boundary', () {
      expect(endingIn(5).monthsLeft, 5);
    });

    test('rounds to the nearest month, and the card hides 0', () {
      // The extra hour keeps `inDays` off the boundary whatever time it runs.
      expect(
        _newsItem(
          endDate: DateTime.now().add(const Duration(days: 16, hours: 1)),
        ).monthsLeft,
        1,
      );
      expect(
        _newsItem(
          endDate: DateTime.now().add(const Duration(days: 15, hours: 1)),
        ).monthsLeft,
        0,
      );
    });

    test('floors at 0 for a past end date', () {
      expect(endingIn(-2).monthsLeft, 0);
    });
  });

  group('AppNewsItem.isDonation', () {
    test('matches the live donation item', () {
      expect(_newsItem().isDonation, isTrue);
    });

    test('is case insensitive and future-campaign proof', () {
      expect(_newsItem(id: 'DONATION_CAMPAIGN_2027').isDonation, isTrue);
      expect(_newsItem(id: 'donation_campaign_2027').isDonation, isTrue);
      expect(_newsItem(id: 'donations-are-great').isDonation, isTrue);
    });

    test('does not match the other items live in the feed', () {
      expect(_newsItem(id: 'nutriscore_petition_2025').isDonation, isFalse);
      expect(_newsItem(id: 'openprices_challenge_01_06').isDonation, isFalse);
      expect(_newsItem(id: 'divinfood_survey_2026').isDonation, isFalse);
    });

    test('matches a prefix, not a substring', () {
      expect(_newsItem(id: 'campaign_donation_2026').isDonation, isFalse);
    });
  });

  group('AppNews.donation', () {
    AppNews newsWith(List<String> ids) => AppNews(
      news: const AppNewsList(<String, AppNewsItem>{}),
      feed: AppNewsFeed(
        ids
            .map((String id) => AppNewsFeedItem(news: _newsItem(id: id)))
            .toList(),
      ),
    );

    test('finds the donation item wherever it sits in the feed', () {
      expect(
        newsWith(<String>[
          'divinfood_survey_2026',
          'donation_campaign_2026',
        ]).donation?.id,
        'donation_campaign_2026',
      );
    });

    test('is null when the feed has no donation ask', () {
      expect(newsWith(<String>['divinfood_survey_2026']).donation, isNull);
      expect(newsWith(<String>[]).donation, isNull);
    });
  });
}
