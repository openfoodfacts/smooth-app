import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

void main() {
  /// When localizing plural messages we allow the translators to put the count
  /// variable at any point they want so that the strings make sense
  /// in any language. This test checks if there is a number at any value
  /// between -1 and 1000, this is to prevent the plural strings in a language
  /// from breaking by translating the variable name as well.
  group('Localization tests', () {
    const List<Locale> locales = AppLocalizations.supportedLocales;

    const List<LocalizationsDelegate<dynamic>> delegates =
        AppLocalizations.localizationsDelegates;

    for (final Locale locale in locales) {
      testWidgets('plural test $locale', (WidgetTester tester) async {
        for (final LocalizationsDelegate<dynamic> delegate in delegates) {
          if (!delegate.isSupported(locale)) {
            continue;
          }
          final AppLocalizations appLocalizations = lookupAppLocalizations(
            locale,
          );

          final List<String> minutes = <String>[];
          final List<String> hours = <String>[];
          final List<String> days = <String>[];
          final List<String> weeks = <String>[];
          final List<String> months = <String>[];
          final List<String> compare = <String>[];

          for (int i = -1; i < 1001; i++) {
            minutes.add(appLocalizations.plural_ago_minutes(i));
            hours.add(appLocalizations.plural_ago_hours(i));
            days.add(appLocalizations.plural_ago_days(i));
            weeks.add(appLocalizations.plural_ago_weeks(i));
            months.add(appLocalizations.plural_ago_months(i));
            compare.add(appLocalizations.plural_compare_x_products(i));
          }

          //Check if any translation contains numbers
          expect(minutes.any((String x) => x.contains(RegExp(r'[0-9]'))), true);
          expect(hours.any((String x) => x.contains(RegExp(r'[0-9]'))), true);
          expect(days.any((String x) => x.contains(RegExp(r'[0-9]'))), true);
          expect(weeks.any((String x) => x.contains(RegExp(r'[0-9]'))), true);
          expect(months.any((String x) => x.contains(RegExp(r'[0-9]'))), true);
          expect(compare.any((String x) => x.contains(RegExp(r'[0-9]'))), true);

          const String crazyString = 'の中ழ்';
          const Object crazyObject = crazyString;

          /// int value designed to trigger the "OTHER" case in plural labels.
          ///
          /// That's not that easy for some languages,
          /// cf. https://github.com/dart-lang/intl/blob/master/lib/src/plural_rules.dart
          /// The value should
          /// * end with a 4, 6 or 9 for 'fil' and 'tl',
          ///   cf. PluralCase _fil_rule()
          /// * not end with 0, 1, 11-19 for 'lv',
          ///   cf. PluralCase _lv_rule()
          const int crazyInt = 2080706059;

          expect(
            appLocalizations.sign_up_page_username_length_invalid(crazyInt),
            contains(crazyInt.toString()),
          );
          expect(
            appLocalizations.pct_match(crazyObject),
            contains(crazyObject.toString()),
          );
          expect(
            appLocalizations.contact_form_body_android(
              crazyInt,
              '',
              '',
              '',
              '',
              '',
            ),
            contains(crazyInt.toString()),
          );
          expect(
            appLocalizations.contact_form_body_android(
              0,
              crazyString,
              '',
              '',
              '',
              '',
            ),
            contains(crazyString),
          );
          expect(
            appLocalizations.contact_form_body_android(
              0,
              '',
              crazyString,
              '',
              '',
              '',
            ),
            contains(crazyString),
          );
          expect(
            appLocalizations.contact_form_body_android(
              0,
              '',
              '',
              crazyString,
              '',
              '',
            ),
            contains(crazyString),
          );
          expect(
            appLocalizations.contact_form_body_android(
              0,
              '',
              '',
              '',
              crazyString,
              '',
            ),
            contains(crazyString),
          );
          expect(
            appLocalizations.contact_form_body_android(
              0,
              '',
              '',
              '',
              '',
              crazyString,
            ),
            contains(crazyString),
          );
          expect(
            appLocalizations.contact_form_body_ios(crazyString, '', ''),
            contains(crazyString),
          );
          expect(
            appLocalizations.contact_form_body_ios('', crazyString, ''),
            contains(crazyString),
          );
          expect(
            appLocalizations.contact_form_body_ios('', '', crazyString),
            contains(crazyString),
          );
          expect(
            appLocalizations.contact_form_body(crazyString, '', '', ''),
            contains(crazyString),
          );
          expect(
            appLocalizations.contact_form_body('', crazyString, '', ''),
            contains(crazyString),
          );
          expect(
            appLocalizations.contact_form_body('', '', crazyString, ''),
            contains(crazyString),
          );
          expect(
            appLocalizations.contact_form_body('', '', '', crazyString),
            contains(crazyString),
          );
          expect(
            appLocalizations.knowledge_panel_text_source(crazyString),
            contains(crazyString),
          );
          // product_list_reloading_in_progress_multiple: no number displayed.
          // product_list_reloading_success_multiple: no number displayed.
          expect(
            appLocalizations.user_profile_title_id_email(crazyString),
            contains(crazyString),
          );
          expect(
            appLocalizations.user_profile_title_id_default(crazyString),
            contains(crazyString),
          );
          expect(
            appLocalizations.email_body_account_deletion(crazyString),
            contains(crazyString),
          );
          expect(
            appLocalizations.permission_photo_denied_message(crazyString),
            contains(crazyString),
          );
          expect(
            appLocalizations.category_picker_no_category_found_message(
              crazyString,
            ),
            contains(crazyString),
          );
          expect(
            appLocalizations.dev_preferences_test_environment_subtitle(
              crazyString,
            ),
            contains(crazyString),
          );
          expect(
            appLocalizations.dev_preferences_migration_subtitle(crazyString),
            contains(crazyString),
          );
          expect(
            appLocalizations.product_search_no_more_results(crazyInt),
            contains(crazyInt.toString()),
          );
          expect(
            appLocalizations.product_search_button_download_more(
              crazyInt,
              0,
              0,
            ),
            contains(crazyInt.toString()),
          );
          expect(
            appLocalizations.product_search_button_download_more(
              0,
              crazyInt,
              0,
            ),
            contains(crazyInt.toString()),
          );
          expect(
            appLocalizations.product_search_button_download_more(
              0,
              0,
              crazyInt,
            ),
            contains(crazyInt.toString()),
          );
          expect(
            appLocalizations.knowledge_panel_page_loading_error(crazyObject),
            contains(crazyObject.toString()),
          );
          expect(
            appLocalizations.preferences_page_loading_error(crazyObject),
            contains(crazyObject.toString()),
          );
          expect(
            appLocalizations.barcode_barcode(crazyString),
            contains(crazyString),
          );
          expect(
            appLocalizations.importance_label(crazyString, ''),
            contains(crazyString),
          );
          expect(
            appLocalizations.importance_label('', crazyString),
            contains(crazyString),
          );
          expect(
            appLocalizations.user_list_length(crazyInt),
            contains(crazyInt.toString()),
          );
          expect(
            appLocalizations.share_product_text(crazyString),
            contains(crazyString),
          );
          return;
        }
        fail('could not find delegate');
      });
    }
  });
}
