// ignore_for_file: avoid_print

// Script to check for inconsistent method signatures in generated localization files.
// This helps identify which ARB file has incorrect placeholder definitions.
//
// Usage: dart test/check_localization_signatures.dart
//
// This script checks all generated app_localizations_*.dart files to ensure
// that methods have consistent signatures across all locales.

import 'dart:io';

void main() {
  print('Checking localization method signatures...\n');

  // Find all generated localization files
  final Directory libDir = Directory('lib/l10n');
  if (!libDir.existsSync()) {
    print('Error: lib/l10n directory not found');
    exit(1);
  }

  final List<File> localizationFiles = libDir
      .listSync()
      .whereType<File>()
      .where(
        (File f) =>
            f.path.endsWith('.dart') && f.path.contains('app_localizations_'),
      )
      .toList();

  print('Found ${localizationFiles.length} localization files\n');

  // Methods to check (add more as needed)
  final List<String> methodsToCheck = <String>[
    'pct_match',
    'sign_up_page_username_length_invalid',
    'contact_form_body_android',
    'contact_form_body_ios',
    'contact_form_body',
    'knowledge_panel_text_source',
    'user_profile_title_id_email',
    'user_profile_title_id_default',
    'email_body_account_deletion',
    'permission_photo_denied_message',
    'category_picker_no_category_found_message',
    'dev_preferences_test_environment_subtitle',
    'dev_preferences_migration_subtitle',
    'product_search_no_more_results',
    'product_search_button_download_more',
    'knowledge_panel_page_loading_error',
    'preferences_page_loading_error',
    'barcode_barcode',
    'importance_label',
    'user_list_length',
    'share_product_text',
  ];

  final Map<String, Map<String, List<String>>> methodSignatures =
      <String, Map<String, List<String>>>{};

  // Extract method signatures from each file
  for (final File file in localizationFiles) {
    final String content = file.readAsStringSync();
    final String fileName = file.path.split('/').last;
    final String locale = fileName
        .replaceAll('app_localizations_', '')
        .replaceAll('.dart', '');

    for (final String method in methodsToCheck) {
      // Look for method signatures like: String methodName(Type param1, Type param2)
      final RegExp regex = RegExp(r'String\s+' + method + r'\s*\([^)]*\)');
      final RegExpMatch? match = regex.firstMatch(content);

      if (match != null) {
        final String signature = match.group(0)!;
        methodSignatures.putIfAbsent(method, () => <String, List<String>>{});
        methodSignatures[method]!.putIfAbsent(signature, () => <String>[]);
        methodSignatures[method]![signature]!.add(locale);
      }
    }
  }

  // Check for inconsistencies
  bool foundIssues = false;

  for (final String method in methodsToCheck) {
    if (!methodSignatures.containsKey(method)) {
      print('⚠️  Method "$method" not found in any localization file');
      foundIssues = true;
      continue;
    }

    final Map<String, List<String>> signatures = methodSignatures[method]!;

    if (signatures.length > 1) {
      print('❌ ERROR: Method "$method" has inconsistent signatures:');
      foundIssues = true;

      for (final MapEntry<String, List<String>> entry in signatures.entries) {
        print('   ${entry.key}');
        print('   Used by: ${entry.value.join(", ")}');
        print(
          '   ARB files to check: ${entry.value.map((String l) => "app_$l.arb").join(", ")}',
        );
        print('');
      }
    } else {
      print('✓ Method "$method" is consistent across all locales');
    }
  }

  print('');
  if (foundIssues) {
    print('❌ Found inconsistencies in localization files.');
    print(
      '   Check the ARB files listed above for incorrect placeholder definitions.',
    );
    exit(1);
  } else {
    print(
      '✅ All checked methods have consistent signatures across all locales.',
    );
    exit(0);
  }
}
