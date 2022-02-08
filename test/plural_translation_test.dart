import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// When localizing plural messages we allow the translators to put the count
  /// variable at any point they want so that the strings make sense
  /// in any language. This test checks if there is a number at any value
  /// between -1 and 1000, this is to prevent the plural strings in a language
  /// from breaking by translating the variable name as well.
  group('Plural test', () {
    const List<Locale> locales = AppLocalizations.supportedLocales;

    const List<LocalizationsDelegate<dynamic>> delegates =
        AppLocalizations.localizationsDelegates;

    for (final Locale locale in locales) {
      late AppLocalizations? appLocalizations;

      for (final LocalizationsDelegate<dynamic> delegate in delegates) {
        if (delegate.isSupported(locale)) {
          testWidgets('$locale plural test ', (WidgetTester tester) async {
            await tester.pumpWidget(
              MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                locale: locale,
                builder: (BuildContext context, Widget? child) {
                  appLocalizations = AppLocalizations.of(context);

                  return const Placeholder();
                },
              ),
            );

            expect(appLocalizations, isNotNull);

            final List<String> minutes = <String>[];
            final List<String> hours = <String>[];
            final List<String> days = <String>[];
            final List<String> weeks = <String>[];
            final List<String> months = <String>[];
            final List<String> compare = <String>[];

            for (int i = -1; i < 1001; i++) {
              minutes.add(appLocalizations!.plural_ago_minutes(i));
              hours.add(appLocalizations!.plural_ago_hours(i));
              days.add(appLocalizations!.plural_ago_days(i));
              weeks.add(appLocalizations!.plural_ago_weeks(i));
              months.add(appLocalizations!.plural_ago_months(i));
              compare.add(appLocalizations!.plural_compare_x_products(i));
            }

            //Check if any translation contains numbers
            expect(
                minutes.any((String x) => x.contains(RegExp(r'[0-9]'))), true);
            expect(hours.any((String x) => x.contains(RegExp(r'[0-9]'))), true);
            expect(days.any((String x) => x.contains(RegExp(r'[0-9]'))), true);
            expect(weeks.any((String x) => x.contains(RegExp(r'[0-9]'))), true);
            expect(
                months.any((String x) => x.contains(RegExp(r'[0-9]'))), true);
            expect(
                compare.any((String x) => x.contains(RegExp(r'[0-9]'))), true);
          });
          break;
        }
      }
    }
  });
}
