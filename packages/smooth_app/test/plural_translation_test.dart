import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Plural test', () {
    const List<Locale> locales = AppLocalizations.supportedLocales;

    for (final Locale locale in locales) {
      late AppLocalizations? appLocalizations;

      testWidgets('$locale plural test ', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
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
        expect(minutes.any((String x) => x.contains(RegExp(r'[0-9]'))), true);
        expect(hours.any((String x) => x.contains(RegExp(r'[0-9]'))), true);
        expect(days.any((String x) => x.contains(RegExp(r'[0-9]'))), true);
        expect(weeks.any((String x) => x.contains(RegExp(r'[0-9]'))), true);
        expect(months.any((String x) => x.contains(RegExp(r'[0-9]'))), true);
        expect(compare.any((String x) => x.contains(RegExp(r'[0-9]'))), true);
      });
    }
  });
}
