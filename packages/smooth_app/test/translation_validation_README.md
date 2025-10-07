# Translation Validation Tests

## Overview

The `translation_validation_test.dart` file contains non-blocking tests that validate translation quality across all language files (`.arb` files) in the `lib/l10n/` directory.

## Purpose

These tests serve as **informational annotations** on translation pull requests. They:

- ✅ Always pass (green) - they never block CI/CD
- ⚠️  Print warnings when issues are detected
- 📊 Help maintain translation quality and consistency
- 🔍 Catch common translation mistakes early

## What is Validated

### 1. App Name Consistency

**Rule:** The `app_name` key should always be `"Open Food Facts"` (not translated)

**Why:** The app name is a brand name and should remain consistent across all languages.

**Example Issue:**
```
⚠️  Translation validation: app_name should be "Open Food Facts"
   Found 120 file(s) with translated app_name:
  - app_fr.arb: "Informations sur les aliments ouverts"
  - app_es.arb: "Datos alimentarios abiertos"
```

### 2. Brand Term Preservation

**Rule:** Specific brand terms should be preserved (not translated) in translations:

- `Nutri-Score` - Official nutrition scoring system
- `NOVA` - Food processing classification
- `Open Food Facts` - The organization/brand name
- `Open Products Facts` - Sister project name
- `Open Beauty Facts` - Sister project name
- `Open Pet Food Facts` - Sister project name
- `Open Prices` - Related project name

**Why:** These are registered trademarks, official names, or standardized terms that should remain recognizable across languages.

**Example Issue:**
```
⚠️  Translation validation: "Nutri-Score" should be preserved
   Found 5 translation(s) missing "Nutri-Score":
  - app_fi.arb: product_improvement_add_category
    English: "Add a category to calculate the Nutri-Score."
    Translation: "Lisää luokka laskeaksesi Nutri-pisteytyksen."
```

### 3. URL Validation

**Rule:** All URLs in translations should be:
- Properly formatted (start with `http://` or `https://`)
- Have valid domain structure
- Not broken or malformed

**Why:** Broken URLs lead to poor user experience and may indicate copy-paste errors.

**Example Keys with URLs:**
- `donate_url`
- `tiktok_link`
- `instagram_link`
- `twitter_link`
- `mastodon_link`
- `bsky_link`
- `contribute_share_content` (contains URL in text)

### 4. Required Keys

**Rule:** All `.arb` files should contain the `app_name` key.

**Why:** This is a fundamental key that should be present in all translation files.

### 5. File Count Consistency

**Rule:** The number of `.arb` files should match the number of supported locales.

**Why:** Helps detect when a locale is added but the corresponding `.arb` file is missing or vice versa.

## How to Use

### Running the Tests

```bash
# Run only translation validation tests
flutter test test/translation_validation_test.dart

# Run all tests (includes translation validation)
flutter test
```

### Interpreting Results

All tests will **always pass** ✅, but look for warning messages in the output:

```
⚠️  Translation validation: [Issue Type]
   Found X issue(s):
  - file.arb: details...
   Note: This is informational only and does not fail the build.
```

### In Pull Requests

When reviewing translation PRs:

1. Check the test output for warnings
2. Review any flagged issues
3. Decide if the warnings require action:
   - **Brand terms:** Usually should be preserved
   - **app_name:** Should always be "Open Food Facts"
   - **URLs:** Must be valid
   - **Others:** Use judgment based on language requirements

## False Positives

Some warnings may be acceptable:

- **Brand term translations:** Some languages may legitimately need to adapt terms for readability while keeping the original in parentheses
- **URL variations:** Regional URLs or localized landing pages may be appropriate

In these cases, the warnings are still useful for review, but no action is needed.

## Adding New Validations

To add new validation rules:

1. Add a new test in `translation_validation_test.dart`
2. Follow the pattern: collect issues, print warnings, always pass
3. Use clear warning messages with file names and context
4. Document the new validation in this README

## Technical Details

### Test Structure

Each validation test:
1. Reads all `.arb` files from `lib/l10n/`
2. Parses JSON and extracts translation keys
3. Checks for specific issues
4. Collects issues into a list
5. If issues exist, prints warnings using `print()`
6. **Always** ends with `expect(true, isTrue)` to pass

### Why Non-Blocking?

Translation quality is important but subjective. Different languages have different requirements for:
- Brand name adaptation
- Cultural appropriateness  
- Grammar and readability

By making tests non-blocking, we:
- Provide helpful guidance without being dogmatic
- Allow human review and decision-making
- Avoid blocking urgent translation updates
- Enable gradual improvement over time

## Related Files

- `test/plural_translation_test.dart` - Validates plural forms in translations
- `lib/l10n/app_*.arb` - Translation files for each language
- `lib/l10n/app_localizations.dart` - Generated localization code

## Questions?

For questions about translation validation:
- Open an issue on GitHub
- Ask in the Open Food Facts Slack
- Join the weekly community meetings
