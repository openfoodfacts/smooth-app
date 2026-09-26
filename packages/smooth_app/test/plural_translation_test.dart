import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

/// Test to ensure all localizations properly include placeholder variables.
///
/// When localizing plural messages we allow the translators to put the count
/// variable at any point they want so that the strings make sense
/// in any language. This test checks if there is a number at any value
/// between -1 and 1000, this is to prevent the plural strings in a language
/// from breaking by translating the variable name as well.
///
/// ## Debugging flutter analyze errors
///
/// If `flutter analyze` fails with an error like:
/// "N positional arguments expected by 'method_name', but M found"
///
/// This means one or more ARB files have incorrect placeholder definitions.
/// To find which langfile is causing the issue:
///
/// 1. Check the method name in the error (e.g., 'pct_match')
/// 2. Look at the comments in this test file near the failing line
/// 3. Run the diagnostic script to identify inconsistent method signatures:
///    - Bash (faster): `./test/check_localization_signatures.sh`
///    - Dart: `dart test/check_localization_signatures.dart`
/// 4. Fix the placeholder definitions in the corresponding app_XX.arb file
///
/// The test name includes the locale (e.g., 'plural test en'), so runtime
/// errors will clearly indicate which language is failing.
void main() {
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
          // Load localizations for the current locale
          // If this fails, the error will indicate the locale in the test name
          // For ARB file errors: check app_${locale.languageCode}.arb
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

          // Testing sign_up_page_username_length_invalid
          // If error: check app_${locale.languageCode}.arb
          expect(
            appLocalizations.sign_up_page_username_length_invalid(crazyInt),
            contains(crazyInt.toString()),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing pct_match
          // If error: check "pct_match" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.pct_match(crazyObject),
            contains(crazyObject.toString()),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing contact_form_body_android
          // If error: check "contact_form_body_android" entry in app_${locale.languageCode}.arb
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
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
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
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
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
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
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
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
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
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
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
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing contact_form_body_ios
          // If error: check "contact_form_body_ios" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.contact_form_body_ios(crazyString, '', ''),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );
          expect(
            appLocalizations.contact_form_body_ios('', crazyString, ''),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );
          expect(
            appLocalizations.contact_form_body_ios('', '', crazyString),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing contact_form_body
          // If error: check "contact_form_body" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.contact_form_body(crazyString, '', '', ''),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );
          expect(
            appLocalizations.contact_form_body('', crazyString, '', ''),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );
          expect(
            appLocalizations.contact_form_body('', '', crazyString, ''),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );
          expect(
            appLocalizations.contact_form_body('', '', '', crazyString),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing knowledge_panel_text_source
          // If error: check "knowledge_panel_text_source" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.knowledge_panel_text_source(crazyString),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );
          // product_list_reloading_in_progress_multiple: no number displayed.
          // product_list_reloading_success_multiple: no number displayed.

          // Testing user_profile_title_id_email
          // If error: check "user_profile_title_id_email" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.user_profile_title_id_email(crazyString),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing user_profile_title_id_default
          // If error: check "user_profile_title_id_default" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.user_profile_title_id_default(crazyString),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing email_body_account_deletion
          // If error: check "email_body_account_deletion" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.email_body_account_deletion(crazyString),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing permission_photo_denied_message
          // If error: check "permission_photo_denied_message" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.permission_photo_denied_message(crazyString),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing category_picker_no_category_found_message
          // If error: check "category_picker_no_category_found_message" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.category_picker_no_category_found_message(
              crazyString,
            ),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing dev_preferences_test_environment_subtitle
          // If error: check "dev_preferences_test_environment_subtitle" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.dev_preferences_test_environment_subtitle(
              crazyString,
            ),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing dev_preferences_migration_subtitle
          // If error: check "dev_preferences_migration_subtitle" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.dev_preferences_migration_subtitle(crazyString),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing product_search_no_more_results
          // If error: check "product_search_no_more_results" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.product_search_no_more_results(crazyInt),
            contains(crazyInt.toString()),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing product_search_button_download_more
          // If error: check "product_search_button_download_more" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.product_search_button_download_more(
              crazyInt,
              0,
              0,
            ),
            contains(crazyInt.toString()),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );
          expect(
            appLocalizations.product_search_button_download_more(
              0,
              crazyInt,
              0,
            ),
            contains(crazyInt.toString()),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );
          expect(
            appLocalizations.product_search_button_download_more(
              0,
              0,
              crazyInt,
            ),
            contains(crazyInt.toString()),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing knowledge_panel_page_loading_error
          // If error: check "knowledge_panel_page_loading_error" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.knowledge_panel_page_loading_error(crazyObject),
            contains(crazyObject.toString()),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing preferences_page_loading_error
          // If error: check "preferences_page_loading_error" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.preferences_page_loading_error(crazyObject),
            contains(crazyObject.toString()),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing barcode_barcode
          // If error: check "barcode_barcode" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.barcode_barcode(crazyString),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing importance_label
          // If error: check "importance_label" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.importance_label(crazyString, ''),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );
          expect(
            appLocalizations.importance_label('', crazyString),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing user_list_length
          // If error: check "user_list_length" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.user_list_length(crazyInt),
            contains(crazyInt.toString()),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );

          // Testing share_product_text
          // If error: check "share_product_text" entry in app_${locale.languageCode}.arb
          expect(
            appLocalizations.share_product_text(crazyString),
            contains(crazyString),
            reason: 'Failed for locale: ${locale.toLanguageTag()}',
          );
          return;
        }
        fail('could not find delegate');
      });
    }
  });
}
