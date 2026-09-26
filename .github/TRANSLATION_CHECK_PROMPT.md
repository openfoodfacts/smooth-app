# Translation Quality Check Prompt

Use this prompt with AI tools or as a checklist when reviewing translations for Open Food Facts mobile app.

## Context
This repository contains translation files (`.arb` format) for the Open Food Facts mobile app in multiple languages. These translations must maintain brand consistency while being natural in each target language.

## Instructions for Translation Review

### 1. Brand Names (NEVER Translate)
The following brand names MUST remain in English/original form across ALL languages:

- **Open Food Facts** - The project name
- **Open Beauty Facts** - Sister project for beauty products
- **Open Pet Food Facts** - Sister project for pet food
- **Open Products Facts** - Sister project for other products
- **Open Prices** - Price collection project
- **Nutri-Score** - The nutrition labeling system (always with hyphen)
- **NOVA** - The food processing classification (all caps)
- **Green-Score** - The environmental impact score (with hyphen: Green-Score A, Green-Score B, etc.)

### 2. URLs Must Be Correctly Formatted

#### Never Translate These URLs:
- `prices.openfoodfacts.org` URLs should NEVER be translated or modified
- Social media URLs (Instagram, Twitter, TikTok, Mastodon, Bluesky) must remain unchanged
- Donation URLs should use correct language subdomain or remain as-is

#### Locale-Specific URLs Should Use Correct Language Code:
- Format: `https://world-{LANG}.openfoodfacts.org/...`
- Examples:
  - French (`app_fr.arb`): `https://world-fr.openfoodfacts.org/discover`
  - German (`app_de.arb`): `https://world-de.openfoodfacts.org/discover`
  - Spanish (`app_es.arb`): `https://world-es.openfoodfacts.org/discover`
  
Apply same logic for:
- `openbeautyfacts.org`
- `openpetfoodfacts.org`
- `openproductsfacts.org`

### 3. Common Translation Errors to Look For

#### ❌ Incorrect Patterns:
```
"Pontuação Verde A" → Should be "Green-Score A"
"åpne matfakta" → Should be "Open Food Facts"
"los faches de l'alimentacion dobèrta" → Should be "Open Food Facts"
"Næringsscore" → Should be "Nutri-Score"
"Skor Nutri" → Should be "Nutri-Score"
"Næringarstig" → Should be "Nutri-Score"
"https://prijzen.openfoodfacts.org/" → Should be "https://prices.openfoodfacts.org/"
```

#### ✅ Correct Patterns:
```
"Green-Score A" (keep as-is in all languages)
"Open Food Facts" (keep as-is in all languages)
"Nutri-Score" (keep as-is, with hyphen)
"NOVA" (keep as-is, all caps)
"https://prices.openfoodfacts.org/about" (never translate)
"https://world-fr.openfoodfacts.org/discover" (use correct language code)
```

### 4. Validation Commands

#### Basic Validation (Brand Names & URLs)
Run the automated validation script:
```bash
python3 .github/scripts/validate_translations.py
```

This script checks for:
- App name should not be translated
- Brand terms preservation
- URL format and correctness
- Locale-specific URL language codes
- Open Prices URL integrity
- 404 errors on translated URL paths

#### Advanced Quality Checks (Placeholders, Consistency, Style)
Run the advanced translation quality checker:
```bash
python3 .github/scripts/advanced_translation_check.py --verbose
```

This script uses gettext and translate-toolkit to check for:
- **Placeholder consistency**: `{variable}` must match between source and translation
- **Punctuation consistency**: Sentence-ending punctuation should match
- **Whitespace issues**: Extra spaces, tabs, leading/trailing whitespace
- **Length discrepancies**: Translations significantly longer or shorter than source
- **Untranslated strings**: Strings identical to English (potentially missed)

#### Using gettext Tools Directly

Check format strings with msgfmt (after converting ARB to PO):
```bash
# Convert ARB to PO format (requires custom converter)
# Then validate with msgfmt
msgfmt --check --check-format --check-domain translation.po
```

Count translation statistics with pocount:
```bash
pocount translation.po
```

Run quality filters with pofilter:
```bash
pofilter -t variables translation.po  # Check variable consistency
pofilter -t brackets translation.po   # Check bracket matching
pofilter -t printf translation.po     # Check printf format strings
pofilter -t urls translation.po       # Check URL consistency
```

#### Using translate-toolkit Tools

Debug translations with podebug (adds markers to help identify issues):
```bash
podebug input.po output.po
```

Check for translation conflicts:
```bash
poconflicts translation.po
```

Merge translations:
```bash
pomerge -t template.pot -i old.po -o new.po
```

### 5. Review Checklist

When reviewing translation files:

- [ ] Brand names (Open Food Facts, Nutri-Score, NOVA, Green-Score, etc.) are NOT translated
- [ ] `prices.openfoodfacts.org` URLs are unchanged
- [ ] `world-{LANG}` URLs use the correct language code matching the file
- [ ] Social media URLs are unchanged
- [ ] No spaces in brand names (e.g., "Nutri - Score" is wrong, should be "Nutri-Score")
- [ ] Capitalization is consistent with English source (e.g., "Green-Score" not "green-score")
- [ ] URLs are complete and not truncated
- [ ] URLs don't have translated path components that result in 404 errors

### 6. Language-Specific Considerations

Some languages may require special handling:

- **Right-to-left languages (Arabic, Hebrew)**: Brand names stay in left-to-right
- **Ideographic languages (Chinese, Japanese)**: Brand names typically kept in Latin script
- **Languages with no hyphen**: Keep the hyphen in brand names like "Nutri-Score" and "Green-Score"

### 7. When in Doubt

If unsure whether a term should be translated:
1. Check the English source file (`app_en.arb`)
2. Look at other major languages (French, German, Spanish) for guidance
3. Search the term online to see if it's an established brand name
4. Prefer NOT translating if the term appears to be a proper noun or brand

### 8. Tools and Resources

#### Validation Scripts
- **Basic Validation**: `.github/scripts/validate_translations.py`
  - Checks brand names, URLs, and project-specific rules
- **Advanced Quality Check**: `.github/scripts/advanced_translation_check.py`
  - Uses gettext and translate-toolkit for comprehensive quality analysis

#### GitHub Actions
- **Basic Validation**: `.github/workflows/translation-validation.yml`
  - Runs on every PR with translation changes
- **Advanced Check**: `.github/workflows/advanced-translation-check.yml`
  - Comprehensive quality check with multiple tools
- **Plural Check**: `.github/workflows/translation-plural-check.yml`
  - Checks for plural form issues

#### Open Source Tools Used
- **gettext** (msgfmt, msgcat, msgcmp, etc.)
  - Industry-standard translation tools
  - Format string validation
  - PO file manipulation
  - Installation: `apt-get install gettext`
  
- **translate-toolkit** (pocount, pofilter, podebug, etc.)
  - Translation quality analysis
  - Format checking and statistics
  - Automated quality filters
  - Installation: `apt-get install translate-toolkit` or `pip install translate-toolkit`
  
- **polib** (Python library)
  - Programmatic access to PO/POT files
  - Installation: `pip install polib`
  
- **babel** (Python library)
  - Internationalization utilities
  - Locale data and formatting
  - Installation: `pip install babel`

#### External Resources
- **Crowdin**: Translation platform used for managing translations
  - https://crowdin.com/project/openfoodfacts
- **Open Food Facts Wiki**: https://wiki.openfoodfacts.org/ (for project terminology)
- **gettext Manual**: https://www.gnu.org/software/gettext/manual/
- **translate-toolkit Docs**: https://docs.translatehouse.org/projects/translate-toolkit/

## Common Keys That Must Not Be Translated

Keys that typically contain brand names (non-exhaustive):
- `app_name`
- `nutriscore_*`
- `nova_group_*`
- `environmental_score_*_new` (for Green-Score)
- `guide_nutriscore_*`
- `guide_nova_*`
- `guide_greenscore_*`
- `guide_open_food_facts_*`
- `guide_open_beauty_facts_*`
- `guide_open_pet_food_facts_*`
- `guide_open_prices_*`
- `preferences_faq_discover_off_title`
- `preferences_faq_discover_obf_title`
- `preferences_faq_discover_opff_title`
- `preferences_faq_discover_op_title`
- Keys containing `_link` or `_url` suffixes

## Reporting Issues

If you find translation issues:
1. Run the validation script to get a comprehensive report
2. Create an issue with:
   - Language code (e.g., `fr`, `de`, `es`)
   - Specific keys affected
   - Suggested corrections
   - Reference to validation script output if available

## For AI Tools

When using this prompt with AI language models:

```
Review the translation files in packages/smooth_app/lib/l10n/ and:
1. Check all brand names are preserved correctly (Open Food Facts, Nutri-Score, NOVA, Green-Score, Open Prices)
2. Verify all URLs are properly formatted and use correct language codes
3. Ensure placeholders like {variable} match between source and translation
4. Check punctuation and whitespace consistency
5. Flag any literal translations of brand terms
6. Identify potentially untranslated strings (identical to English when they shouldn't be)
7. Check for length discrepancies (translations much longer/shorter than source)
8. Provide a summary of issues found with specific file names and keys
9. Run both validation scripts to get comprehensive coverage
```

## Automated Checks in CI/CD

All PRs with translation changes automatically trigger:
1. **Basic validation** - Brand names and URLs
2. **Advanced quality check** - Placeholders, consistency, style
3. **Plural form check** - Ensures proper plural handling

Results are posted as PR comments with actionable feedback.

## Quick Reference Card

| Issue Type | Tool | Command |
|------------|------|---------|
| Brand names not preserved | validate_translations.py | `python3 .github/scripts/validate_translations.py` |
| URLs incorrect | validate_translations.py | `python3 .github/scripts/validate_translations.py` |
| Placeholder mismatch | advanced_translation_check.py | `python3 .github/scripts/advanced_translation_check.py` |
| Punctuation issues | advanced_translation_check.py | `python3 .github/scripts/advanced_translation_check.py` |
| Format strings | gettext msgfmt | `msgfmt --check translation.po` |
| Translation statistics | translate-toolkit | `pocount translation.po` |
| Quality filters | translate-toolkit | `pofilter -t variables translation.po` |

---

**Last Updated**: 2026-01-04  
**Maintained By**: Open Food Facts Contributors  
**Related Files**: 
- `.github/scripts/validate_translations.py`
- `.github/scripts/advanced_translation_check.py`
- `.github/workflows/translation-validation.yml`
- `.github/workflows/advanced-translation-check.yml`
- `.github/workflows/translation-plural-check.yml`
