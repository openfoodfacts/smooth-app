import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_app/l10n/app_localizations.dart';

/// Translation validation tests
///
/// These tests check for common translation issues but are NON-BLOCKING.
/// They serve as informational warnings to help improve translation quality
/// and should be reviewed when making translation changes.
///
/// The tests validate:
/// 1. app_name should always be "Open Food Facts" (not translated)
/// 2. Brand terms like "Nutri-Score", "NOVA", "Open Food Facts", etc.
///    should be preserved in translations
/// 3. URLs should be valid and not broken
/// 4. All ARB files should have the required keys
///
/// All tests pass (return green) but print warnings to stdout when issues
/// are detected. This allows them to be informational without blocking CI/CD.
void main() {
  group('Translation validation tests (non-blocking)', () {
    final Directory l10nDir = Directory('lib/l10n');
    final List<FileSystemEntity> arbFiles = l10nDir
        .listSync()
        .where(
          (FileSystemEntity file) =>
              file.path.endsWith('.arb') &&
              !file.path.endsWith('_template.arb'),
        )
        .toList();

    test('app_name should always be "Open Food Facts"', () {
      final List<String> issues = <String>[];

      for (final FileSystemEntity file in arbFiles) {
        final String content = File(file.path).readAsStringSync();
        final Map<String, dynamic> translations =
            json.decode(content) as Map<String, dynamic>;

        if (translations.containsKey('app_name')) {
          final String? appName = translations['app_name'] as String?;
          if (appName != 'Open Food Facts') {
            final String fileName = file.path.split('/').last;
            issues.add('  - $fileName: "$appName"');
          }
        }
      }

      if (issues.isNotEmpty) {
        // Use print instead of printOnFailure so it shows even when test passes
        print(
          '\n⚠️  Translation validation: app_name should be "Open Food Facts"',
        );
        print('   Found ${issues.length} file(s) with translated app_name:');
        for (final String issue in issues) {
          print(issue);
        }
        print(
          '   Note: This is informational only and does not fail the build.\n',
        );
      }

      // Always pass
      expect(true, isTrue);
    });

    group('Brand term consistency checks', () {
      // Terms that should be preserved in translations
      final Map<String, List<String>> brandTerms = <String, List<String>>{
        'Nutri-Score': <String>[
          'nutriscore_generic',
          'nutriscore_a',
          'nutriscore_b',
          'nutriscore_c',
          'nutriscore_d',
          'nutriscore_e',
          'nutriscore_new_formula',
          'nutriscore_new_formula_title',
          'nutriscore_unknown',
          'nutriscore_unknown_new_formula',
          'nutriscore_not_applicable',
          'nutriscore_not_applicable_new_formula',
          'new_product_title_nutriscore',
          'product_improvement_add_category',
          'product_improvement_add_nutrition_facts',
          'product_improvement_add_nutrition_facts_and_category',
        ],
        'NOVA': <String>[
          'nova_group_1',
          'nova_group_2',
          'nova_group_3',
          'nova_group_4',
          'nova_group_unknown',
          'nova_group_generic_new',
          'new_product_title_nova',
        ],
        'Open Food Facts': <String>[
          'help_improve_country',
          'contribute_join_skill_pool',
          'new_product_title_pictures_details',
          'preferences_page_contribute_project_subtitle',
        ],
        'Open Products Facts': <String>[
          'search_product_filter_visibility_subtitle',
        ],
        'Open Beauty Facts': <String>[
          'search_product_filter_visibility_subtitle',
        ],
        'Open Pet Food Facts': <String>[
          'search_product_filter_visibility_subtitle',
        ],
      };

      for (final MapEntry<String, List<String>> entry in brandTerms.entries) {
        final String brandTerm = entry.key;
        final List<String> keysToCheck = entry.value;

        if (keysToCheck.isEmpty) {
          continue;
        }

        test('Translations containing "$brandTerm" should preserve the term', () {
          final List<String> issues = <String>[];

          for (final FileSystemEntity file in arbFiles) {
            final String content = File(file.path).readAsStringSync();
            final Map<String, dynamic> translations =
                json.decode(content) as Map<String, dynamic>;

            // Get the English version for reference
            final String enContent = File(
              'lib/l10n/app_en.arb',
            ).readAsStringSync();
            final Map<String, dynamic> enTranslations =
                json.decode(enContent) as Map<String, dynamic>;

            for (final String key in keysToCheck) {
              if (!translations.containsKey(key)) {
                continue; // Skip if key doesn't exist in this translation
              }

              final String? enValue = enTranslations[key] as String?;
              if (enValue == null ||
                  !enValue.contains(brandTerm) ||
                  enValue.startsWith('{')) {
                continue; // Skip if English doesn't contain the term or is a placeholder
              }

              final String? translatedValue = translations[key] as String?;
              if (translatedValue == null || translatedValue.startsWith('{')) {
                continue; // Skip metadata and placeholders
              }

              if (!translatedValue.contains(brandTerm)) {
                final String fileName = file.path.split('/').last;
                issues.add('  - $fileName: $key');
                issues.add('    English: "$enValue"');
                issues.add('    Translation: "$translatedValue"');
              }
            }
          }

          if (issues.isNotEmpty) {
            print(
              '\n⚠️  Translation validation: "$brandTerm" should be preserved',
            );
            print(
              '   Found ${issues.length ~/ 3} translation(s) missing "$brandTerm":',
            );
            for (final String issue in issues) {
              print(issue);
            }
            print(
              '   Note: This is informational only and does not fail the build.\n',
            );
          }

          // Always pass
          expect(true, isTrue);
        });
      }
    });

    group('URL validation checks', () {
      final List<String> urlKeys = <String>[
        'donate_url',
        'tiktok_link',
        'instagram_link',
        'twitter_link',
        'mastodon_link',
        'bsky_link',
      ];

      test('URLs should be valid and not broken', () {
        final RegExp urlPattern = RegExp(
          r'^https?://[^\s<>"{}|\\^`\[\]]+$',
          caseSensitive: false,
        );
        final List<String> issues = <String>[];

        for (final FileSystemEntity file in arbFiles) {
          final String content = File(file.path).readAsStringSync();
          final Map<String, dynamic> translations =
              json.decode(content) as Map<String, dynamic>;

          for (final String key in urlKeys) {
            if (!translations.containsKey(key)) {
              continue;
            }

            final String? value = translations[key] as String?;
            if (value == null || value.isEmpty) {
              continue;
            }

            if (!urlPattern.hasMatch(value)) {
              final String fileName = file.path.split('/').last;
              issues.add('  - $fileName: $key = "$value"');
            }
          }
        }

        if (issues.isNotEmpty) {
          print('\n⚠️  Translation validation: Invalid URLs found');
          print('   Found ${issues.length} invalid URL(s):');
          for (final String issue in issues) {
            print(issue);
          }
          print(
            '   Note: This is informational only and does not fail the build.\n',
          );
        }

        // Always pass
        expect(true, isTrue);
      });

      test('URLs in text strings should be valid', () {
        // Pattern to find URLs within text
        final RegExp urlInTextPattern = RegExp(
          r'https?://[^\s<>"{}|\\^`\[\]]+',
          caseSensitive: false,
        );
        final List<String> issues = <String>[];

        for (final FileSystemEntity file in arbFiles) {
          final String content = File(file.path).readAsStringSync();
          final Map<String, dynamic> translations =
              json.decode(content) as Map<String, dynamic>;

          for (final MapEntry<String, dynamic> entry in translations.entries) {
            if (entry.key.startsWith('@')) {
              continue; // Skip metadata
            }

            final String? value = entry.value as String?;
            if (value == null) {
              continue;
            }

            final Iterable<RegExpMatch> matches = urlInTextPattern.allMatches(
              value,
            );
            for (final RegExpMatch match in matches) {
              final String url = match.group(0)!;
              // Basic validation: should not end with punctuation that's likely not part of URL
              final String cleanUrl = url.replaceAll(RegExp(r'[.,;!?]+$'), '');

              // Check that URL has a valid domain structure
              final RegExp domainPattern = RegExp(
                r'^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
              );
              if (!domainPattern.hasMatch(cleanUrl)) {
                final String fileName = file.path.split('/').last;
                issues.add('  - $fileName: ${entry.key}');
                issues.add('    URL: "$cleanUrl"');
              }
            }
          }
        }

        if (issues.isNotEmpty) {
          print('\n⚠️  Translation validation: Invalid URLs in text strings');
          print('   Found ${issues.length ~/ 2} issue(s):');
          for (final String issue in issues) {
            print(issue);
          }
          print(
            '   Note: This is informational only and does not fail the build.\n',
          );
        }

        // Always pass
        expect(true, isTrue);
      });
    });

    // Test that all locales have the app_name key
    test('All ARB files should have app_name defined', () {
      final List<String> missing = <String>[];

      for (final FileSystemEntity file in arbFiles) {
        final String content = File(file.path).readAsStringSync();
        final Map<String, dynamic> translations =
            json.decode(content) as Map<String, dynamic>;

        if (!translations.containsKey('app_name')) {
          final String fileName = file.path.split('/').last;
          missing.add('  - $fileName');
        }
      }

      if (missing.isNotEmpty) {
        print('\n⚠️  Translation validation: Missing app_name key');
        print('   Found ${missing.length} file(s) without app_name:');
        for (final String file in missing) {
          print(file);
        }
        print(
          '   Note: This is informational only and does not fail the build.\n',
        );
      }

      // Always pass
      expect(true, isTrue);
    });

    // Test that the number of supported locales matches the number of ARB files
    test('Number of ARB files should match supported locales', () {
      final int arbFileCount = arbFiles.length;
      final int supportedLocaleCount = AppLocalizations.supportedLocales.length;

      if (arbFileCount != supportedLocaleCount) {
        print('\n⚠️  Translation validation: ARB file count mismatch');
        print('   ARB files: $arbFileCount');
        print('   Supported locales: $supportedLocaleCount');
        print(
          '   Note: This is informational only and does not fail the build.\n',
        );
      }

      // Always pass
      expect(true, isTrue);
    });
  });
}
