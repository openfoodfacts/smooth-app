import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';

AppNewsItem _newsItem({
  DateTime? endDate,
  double? raised,
  double? goal,
  String? currency,
}) => AppNewsItem(
  id: 'donation_campaign_2026',
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

  group('AppNewsItem.monthsLeft', () {
    test('is null without an end date', () {
      expect(_newsItem().monthsLeft(DateTime(2026, 8, 2)), isNull);
    });

    test('is 0 for the same month', () {
      expect(
        _newsItem(
          endDate: DateTime(2026, 8, 2),
        ).monthsLeft(DateTime(2026, 8, 2)),
        0,
      );
    });

    test('is 1 for the next month', () {
      expect(
        _newsItem(
          endDate: DateTime(2026, 9, 2),
        ).monthsLeft(DateTime(2026, 8, 2)),
        1,
      );
    });

    test('is 5 across a year boundary', () {
      expect(
        _newsItem(
          endDate: DateTime(2027, 1, 2),
        ).monthsLeft(DateTime(2026, 8, 2)),
        5,
      );
    });

    test('decrements when the end day of month precedes the start one', () {
      expect(
        _newsItem(
          endDate: DateTime(2026, 9, 1),
        ).monthsLeft(DateTime(2026, 8, 15)),
        0,
      );
    });

    test('floors at 0 for a past end date', () {
      expect(
        _newsItem(
          endDate: DateTime(2026, 7, 1),
        ).monthsLeft(DateTime(2026, 8, 2)),
        0,
      );
    });
  });
}
