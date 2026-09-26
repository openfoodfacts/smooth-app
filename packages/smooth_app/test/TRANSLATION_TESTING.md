# Translation Testing and Debugging

This directory contains tests to ensure all language translations are correctly formatted and include necessary placeholders.

## Understanding flutter analyze errors

When `flutter analyze` fails with an error like:

```
error • 2 positional arguments expected by 'pct_match', but 1 found •
packages/smooth_app/test/plural_translation_test.dart:70:51 • not_enough_positional_arguments
```

This error means that one or more `.arb` files have incorrect placeholder definitions for the `pct_match` method.

### How to find which language file is failing

#### Method 1: Use the diagnostic script (Recommended)

Run one of the diagnostic scripts to automatically identify inconsistent method signatures:

**Option A: Bash script (faster, no dependencies)**
```bash
cd packages/smooth_app
./test/check_localization_signatures.sh
```

**Option B: Dart script (requires Dart SDK)**
```bash
cd packages/smooth_app
dart test/check_localization_signatures.dart
```

Both scripts will:
- Check all generated localization files
- Identify methods with inconsistent signatures
- Tell you which specific ARB files need to be fixed

Example output:
```
❌ ERROR: Method "pct_match" has inconsistent signatures:
   String pct_match(Object percent)
   Used by: en, de, it, ...
   ARB files to check: app_en.arb, app_de.arb, app_it.arb, ...

   String pct_match(Object percent, Object extra)
   Used by: fr
   ARB files to check: app_fr.arb
```

In this example, the `app_fr.arb` file has an extra placeholder that needs to be removed.

#### Method 2: Manual investigation

1. Look at the method name in the error (e.g., `pct_match`)
2. Check the expected number of parameters vs. the actual number
3. Search for the method definition in generated files:
   ```bash
   grep -n "String pct_match(" lib/l10n/app_localizations_*.dart
   ```
4. Compare signatures to find the inconsistent one
5. Check the corresponding ARB file (e.g., `app_es.arb`)
6. Fix the placeholders section in the ARB file

### Common issues

- **Missing placeholder**: ARB file doesn't define a required placeholder
- **Extra placeholder**: ARB file defines more placeholders than the base translation
- **Typo in placeholder name**: Placeholder name doesn't match the expected parameter name

### Fixing ARB files

Each translatable string in an ARB file should have:
1. The translation text with placeholders in `{curly braces}`
2. A metadata entry starting with `@` that defines the placeholders

Example of a correct definition:

```json
"pct_match": "{percent}% match",
"@pct_match": {
  "description": "This product has a x percent match with your preferences",
  "placeholders": {
    "percent": {}
  }
}
```

The number and names of placeholders must match across ALL language files.

## Running the tests

To run the translation tests:

```bash
cd packages/smooth_app
flutter test test/plural_translation_test.dart
```

## Adding new translatable methods

When adding a new method that takes parameters:

1. Add it to the base `app_en.arb` file with proper placeholders
2. Run the localization generator (usually automatic with `flutter pub get`)
3. Add a test case to `plural_translation_test.dart`
4. Add the method name to `check_localization_signatures.dart`
