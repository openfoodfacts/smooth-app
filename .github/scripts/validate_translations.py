#!/usr/bin/env python3
"""
Translation validation script for Open Food Facts mobile app.

This script validates translation files (.arb) for common issues:
1. app_name should always be "Open Food Facts" (not translated)
2. Brand terms (Nutri-Score, NOVA, Open Food Facts, etc.) should be preserved
3. URLs should be valid and not broken
4. All ARB files should have required keys
5. Locale-specific URLs should use correct language codes
6. Open Prices URLs should never be translated
7. Translated URL paths should not result in 404 errors

The script outputs validation warnings in a format suitable for GitHub PR comments.
"""

import json
import os
import re
import sys
import urllib.request
import urllib.error
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
from urllib.parse import urlparse


# Brand terms that should be preserved in translations
BRAND_TERMS = {
    'Nutri-Score': [
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
    'NOVA': [
        'nova_group_1',
        'nova_group_2',
        'nova_group_3',
        'nova_group_4',
        'nova_group_unknown',
        'nova_group_generic_new',
        'new_product_title_nova',
    ],
    'Open Food Facts': [
        'help_improve_country',
        'contribute_join_skill_pool',
        'new_product_title_pictures_details',
        'preferences_page_contribute_project_subtitle',
    ],
    'Open Products Facts': [
        'search_product_filter_visibility_subtitle',
    ],
    'Open Beauty Facts': [
        'search_product_filter_visibility_subtitle',
    ],
    'Open Pet Food Facts': [
        'search_product_filter_visibility_subtitle',
    ],
    'Open Prices': [
        'guide_open_prices_how_title',
        'guide_open_prices_scrapping_paragraph1',
        'guide_open_prices_scrapping_paragraph2',
        'guide_open_prices_title',
        'guide_open_prices_what_is_open_prices_paragraph1',
        'guide_open_prices_what_is_open_prices_title',
        'preferences_faq_discover_op_title',
        'preferences_prices_newest_subtitle',
        'prices_menu_know_more',
    ],
}

# URL keys to validate
URL_KEYS = [
    'donate_url',
    'tiktok_link',
    'instagram_link',
    'twitter_link',
    'mastodon_link',
    'bsky_link',
]

# URL regex patterns (extracted as constants for maintainability)
# Character class for valid URL characters
URL_CHAR_CLASS = r'[^\s<>"{}|\\^`\[\]]'
URL_PATTERN_STR = rf'https?://{URL_CHAR_CLASS}+'

# Crowdin project details for generating links
CROWDIN_PROJECT_ID = '2977'
CROWDIN_BASE_URL = 'https://crowdin.com/editor/openfoodfacts'

# Cache for URL existence checks to avoid redundant HTTP requests
_url_check_cache: Dict[str, bool] = {}

# Mapping of ARB language codes to Crowdin language codes
# Format: {arb_code: crowdin_code}
LANGUAGE_CODE_MAPPING = {
    'en': 'en',
    'cy': 'cy',
    'fr': 'fr',
    'de': 'de',
    'es': 'es',
    'it': 'it',
    'pt': 'pt',
    # Add more mappings as needed
}

def get_locale_from_filename(filename: str) -> Optional[str]:
    """Extract locale code from ARB filename (e.g., 'app_fr.arb' -> 'fr')."""
    match = re.match(r'app_([a-z]{2,3})\.arb', filename)
    return match.group(1) if match else None

def generate_crowdin_link(locale: str, string_key: str) -> str:
    """Generate a Crowdin editor link for a specific string key and locale.
    
    Example: https://crowdin.com/editor/openfoodfacts/2977/en-fr?view=comfortable&filter=basic&value=3&search_scope=everything&search_strict=0&search_full_match=0&case_sensitive=0#q=app_name
    """
    # Map locale to Crowdin language code (en-XX format)
    crowdin_locale = LANGUAGE_CODE_MAPPING.get(locale, locale)
    
    # Generate the URL
    url = f"{CROWDIN_BASE_URL}/{CROWDIN_PROJECT_ID}/en-{crowdin_locale}"
    url += f"?view=comfortable&filter=basic&value=3&search_scope=everything"
    url += f"&search_strict=0&search_full_match=0&case_sensitive=0#q={string_key}"
    
    return url


def load_arb_file(file_path: Path) -> Dict:
    """Load and parse an ARB file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading {file_path}: {e}", file=sys.stderr)
        return {}


def get_arb_files(l10n_dir: Path) -> List[Path]:
    """Get all ARB files from the l10n directory."""
    return [f for f in l10n_dir.glob('*.arb') if not f.name.endswith('_template.arb')]


def validate_app_name(arb_files: List[Path]) -> List[Tuple[str, str, str, str]]:
    """Validate that app_name is always 'Open Food Facts'.
    
    Returns: List of tuples (filename, locale, actual_value, crowdin_link)
    """
    issues = []
    
    for arb_file in arb_files:
        # Skip English file
        if arb_file.name == 'app_en.arb':
            continue
            
        translations = load_arb_file(arb_file)
        if 'app_name' in translations:
            app_name = translations['app_name']
            # Normalize spaces (including non-breaking spaces) for comparison
            normalized_app_name = re.sub(r'\s+', ' ', app_name)
            if normalized_app_name != 'Open Food Facts':
                locale = get_locale_from_filename(arb_file.name)
                if locale:
                    crowdin_link = generate_crowdin_link(locale, 'app_name')
                    issues.append((arb_file.name, locale, app_name, crowdin_link))
    
    return issues


def validate_brand_terms(arb_files: List[Path], en_translations: Dict) -> Dict[str, List[Tuple[str, str, str, str, str, str]]]:
    """Validate that brand terms are preserved in translations.
    
    Returns: Dict mapping brand_term -> List of tuples (filename, locale, key, en_value, translated_value, crowdin_link)
    """
    all_issues = {}
    
    for brand_term, keys_to_check in BRAND_TERMS.items():
        issues = []
        
        for arb_file in arb_files:
            if arb_file.name == 'app_en.arb':
                continue
                
            translations = load_arb_file(arb_file)
            locale = get_locale_from_filename(arb_file.name)
            
            for key in keys_to_check:
                if key not in translations:
                    continue
                
                en_value = en_translations.get(key)
                if not en_value or not isinstance(en_value, str):
                    continue
                    
                if brand_term not in en_value or en_value.startswith('{'):
                    continue
                
                translated_value = translations[key]
                if not isinstance(translated_value, str) or translated_value.startswith('{'):
                    continue
                
                if brand_term not in translated_value:
                    crowdin_link = generate_crowdin_link(locale, key) if locale else ''
                    issues.append((arb_file.name, locale, key, en_value, translated_value, crowdin_link))
        
        if issues:
            all_issues[brand_term] = issues
    
    return all_issues


def check_url_exists(url: str, timeout: int = 5) -> bool:
    """Check if a URL returns a successful response (not 404).
    
    Uses a cache to avoid redundant HTTP requests for the same URL.
    
    Returns True if URL is accessible, False if it returns 404.
    For other errors (connection errors, timeouts), returns True to avoid false positives.
    """
    # Check cache first
    if url in _url_check_cache:
        return _url_check_cache[url]
    
    try:
        req = urllib.request.Request(url, method='HEAD')
        req.add_header('User-Agent', 'Mozilla/5.0 (compatible; TranslationValidator/1.0)')
        with urllib.request.urlopen(req, timeout=timeout) as response:
            result = response.status < 400
            _url_check_cache[url] = result
            return result
    except urllib.error.HTTPError as e:
        # Return False only for 404 errors
        result = e.code != 404
        _url_check_cache[url] = result
        return result
    except Exception:
        # For connection errors, timeouts, etc., return True (assume URL is valid)
        # We only want to report actual 404s, not connection problems
        _url_check_cache[url] = True
        return True


def validate_locale_specific_urls(arb_files: List[Path], en_translations: Dict) -> List[Tuple[str, str, str, str, str, str]]:
    """Validate that locale-specific URLs use the correct language code.
    
    For example, in app_fr.arb:
    - https://world-en.openfoodfacts.org/nova should be https://world-fr.openfoodfacts.org/nova
    
    Returns: List of tuples (filename, locale, key, en_url, translated_url, crowdin_link)
    """
    issues = []
    
    # Pattern to match world-XX URLs
    locale_url_pattern = re.compile(rf'https://world-([a-z]{{2,3}})\.([a-z]+facts\.org)(/{URL_CHAR_CLASS}*)?')
    # Pattern to match non-world locale URLs (e.g., https://en.openfoodfacts.org/)
    simple_locale_pattern = re.compile(rf'https://([a-z]{{2,3}})\.([a-z]+facts\.org)(/{URL_CHAR_CLASS}*)?')
    
    for arb_file in arb_files:
        if arb_file.name == 'app_en.arb':
            continue
            
        locale = get_locale_from_filename(arb_file.name)
        if not locale:
            continue
            
        translations = load_arb_file(arb_file)
        
        for key, value in translations.items():
            if key.startswith('@') or not isinstance(value, str):
                continue
            
            # Check if this key has a URL in English
            en_value = en_translations.get(key)
            if not en_value or not isinstance(en_value, str):
                continue
            
            # Find locale-specific URLs in English version
            en_match = locale_url_pattern.search(en_value)
            if en_match:
                en_lang_code = en_match.group(1)
                domain = en_match.group(2)
                path = en_match.group(3) or ''
                
                # The English version has a world-XX URL
                # Check what the translation has
                trans_match = locale_url_pattern.search(value)
                trans_simple_match = simple_locale_pattern.search(value)
                
                if trans_match:
                    # Translation also uses world-XX format
                    trans_lang_code = trans_match.group(1)
                    trans_domain = trans_match.group(2)
                    
                    # The language code should match the file's locale for openfoodfacts.org domains
                    # For other domains, we're more lenient
                    if 'openfoodfacts.org' in domain and trans_lang_code != locale:
                        # They're using world-XX but with the wrong language code
                        crowdin_link = generate_crowdin_link(locale, key)
                        issues.append((arb_file.name, locale, key, en_value, value, crowdin_link))
                    elif trans_domain != domain:
                        # They changed the domain (e.g., openfoodfacts.org to openbeautyfacts.org)
                        crowdin_link = generate_crowdin_link(locale, key)
                        issues.append((arb_file.name, locale, key, en_value, value, crowdin_link))
                elif trans_simple_match:
                    # Translation uses simple format (e.g., https://en.openfoodfacts.org/)
                    # This is not ideal - should use world-XX format for openfoodfacts.org
                    trans_lang_code = trans_simple_match.group(1)
                    trans_domain = trans_simple_match.group(2)
                    
                    if 'openfoodfacts.org' in domain:
                        # Flag this - should use world-XX format
                        crowdin_link = generate_crowdin_link(locale, key)
                        issues.append((arb_file.name, locale, key, en_value, value, crowdin_link))
                # else: Translation doesn't have a recognizable URL pattern, might be completely different
                # We don't flag this as it might be intentional
    
    return issues


def validate_open_prices_urls(arb_files: List[Path], en_translations: Dict) -> List[Tuple[str, str, str, str, str, str]]:
    """Validate that Open Prices URLs are never translated.
    
    Open Prices URLs (prices.openfoodfacts.org) should always remain in English/unchanged.
    
    Returns: List of tuples (filename, locale, key, en_url, translated_url, crowdin_link)
    """
    issues = []
    
    # Pattern to match Open Prices URLs
    prices_url_pattern = re.compile(r'prices\.openfoodfacts\.org')
    
    for arb_file in arb_files:
        if arb_file.name == 'app_en.arb':
            continue
            
        locale = get_locale_from_filename(arb_file.name)
        if not locale:
            continue
            
        translations = load_arb_file(arb_file)
        
        for key, value in translations.items():
            if key.startswith('@') or not isinstance(value, str):
                continue
            
            # Check if English version has prices.openfoodfacts.org URL
            en_value = en_translations.get(key)
            if not en_value or not isinstance(en_value, str):
                continue
            
            if prices_url_pattern.search(en_value):
                # English has Open Prices URL
                # Check if translation changed it
                if not prices_url_pattern.search(value):
                    # The URL was changed/translated
                    crowdin_link = generate_crowdin_link(locale, key)
                    issues.append((arb_file.name, locale, key, en_value, value, crowdin_link))
                elif en_value != value:
                    # The URL contains prices.openfoodfacts.org but was modified
                    # Extract just the URL parts to compare
                    en_urls = re.findall(URL_PATTERN_STR, en_value)
                    trans_urls = re.findall(URL_PATTERN_STR, value)
                    
                    # Check if any prices.openfoodfacts.org URL was changed
                    for en_url in en_urls:
                        if 'prices.openfoodfacts.org' in en_url:
                            # Find corresponding URL in translation
                            found_exact = False
                            for trans_url in trans_urls:
                                if trans_url == en_url:
                                    found_exact = True
                                    break
                            
                            if not found_exact:
                                # The Open Prices URL was modified
                                crowdin_link = generate_crowdin_link(locale, key)
                                issues.append((arb_file.name, locale, key, en_value, value, crowdin_link))
                                break
    
    return issues


def validate_translated_url_paths(arb_files: List[Path], en_translations: Dict) -> List[Tuple[str, str, str, str, str, str, str]]:
    """Validate that translated URL paths don't result in 404 errors.
    
    Only checks URLs that have translated path components.
    Returns: List of tuples (filename, locale, key, en_url, translated_url, status, crowdin_link)
    where status is '404' if the URL returns 404
    """
    issues = []
    
    # Compile URL pattern once using constant
    url_pattern = re.compile(URL_PATTERN_STR)
    url_with_path_pattern = re.compile(r'https?://[^/]+/(.+?)(?:\s|$|[.,;!?])')
    
    for arb_file in arb_files:
        if arb_file.name == 'app_en.arb':
            continue
            
        locale = get_locale_from_filename(arb_file.name)
        if not locale:
            continue
            
        translations = load_arb_file(arb_file)
        
        for key, value in translations.items():
            if key.startswith('@') or not isinstance(value, str):
                continue
            
            en_value = en_translations.get(key)
            if not en_value or not isinstance(en_value, str):
                continue
            
            # Find URLs with paths in both versions
            en_urls = re.findall(URL_PATTERN_STR, en_value)
            trans_urls = re.findall(URL_PATTERN_STR, value)
            
            # Check each translated URL
            for trans_url in trans_urls:
                trans_url_clean = re.sub(r'[.,;!?]+$', '', trans_url)
                
                # Parse the URL
                parsed = urlparse(trans_url_clean)
                if not parsed.path or parsed.path == '/':
                    continue
                
                # Check if this URL has a translated path component
                # by comparing with English URLs
                has_translated_path = False
                for en_url in en_urls:
                    en_url_clean = re.sub(r'[.,;!?]+$', '', en_url)
                    en_parsed = urlparse(en_url_clean)
                    
                    # Skip if English URL doesn't have a path
                    if not en_parsed.path or en_parsed.path == '/':
                        continue
                    
                    # Same domain but different path = translated path
                    if (parsed.netloc == en_parsed.netloc and 
                        parsed.path != en_parsed.path):
                        has_translated_path = True
                        break
                
                # Only check URLs with translated paths
                if has_translated_path:
                    # Check if URL returns 404
                    if not check_url_exists(trans_url_clean):
                        crowdin_link = generate_crowdin_link(locale, key)
                        issues.append((arb_file.name, locale, key, en_value, trans_url_clean, '404', crowdin_link))
    
    return issues


def validate_urls(arb_files: List[Path]) -> Tuple[List[Tuple[str, str, str, str, str]], List[Tuple[str, str, str, str, str]]]:
    """Validate URLs in translation files.
    
    Returns: Tuple of (url_key_issues, url_text_issues)
    Each issue is a tuple of (filename, locale, key, value, crowdin_link)
    """
    url_pattern = re.compile(rf'^{URL_PATTERN_STR}$', re.IGNORECASE)
    url_in_text_pattern = re.compile(URL_PATTERN_STR, re.IGNORECASE)
    domain_pattern = re.compile(r'^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}')
    
    url_key_issues = []
    url_text_issues = []
    
    for arb_file in arb_files:
        translations = load_arb_file(arb_file)
        locale = get_locale_from_filename(arb_file.name)
        
        # Check URL keys
        for url_key in URL_KEYS:
            if url_key in translations:
                value = translations[url_key]
                if value and not url_pattern.match(value):
                    crowdin_link = generate_crowdin_link(locale, url_key) if locale else ''
                    url_key_issues.append((arb_file.name, locale, url_key, value, crowdin_link))
        
        # Check URLs in text
        for key, value in translations.items():
            if key.startswith('@') or not isinstance(value, str):
                continue
            
            matches = url_in_text_pattern.findall(value)
            for url in matches:
                clean_url = re.sub(r'[.,;!?]+$', '', url)
                if not domain_pattern.match(clean_url):
                    crowdin_link = generate_crowdin_link(locale, key) if locale else ''
                    url_text_issues.append((arb_file.name, locale, key, clean_url, crowdin_link))
    
    return url_key_issues, url_text_issues


def validate_required_keys(arb_files: List[Path]) -> List[Tuple[str, str]]:
    """Validate that all ARB files have required keys.
    
    Returns: List of tuples (filename, locale)
    """
    missing = []
    
    for arb_file in arb_files:
        translations = load_arb_file(arb_file)
        locale = get_locale_from_filename(arb_file.name)
        if 'app_name' not in translations:
            missing.append((arb_file.name, locale))
    
    return missing


def format_validation_comment(
    app_name_issues: List[Tuple[str, str, str, str]],
    brand_term_issues: Dict[str, List[Tuple[str, str, str, str, str, str]]],
    url_key_issues: List[Tuple[str, str, str, str, str]],
    url_text_issues: List[Tuple[str, str, str, str, str]],
    missing_keys: List[Tuple[str, str]],
    locale_url_issues: List[Tuple[str, str, str, str, str, str]],
    open_prices_issues: List[Tuple[str, str, str, str, str, str]],
    translated_path_404_issues: List[Tuple[str, str, str, str, str, str, str]]
) -> str:
    """Format validation results as a GitHub PR comment."""
    sections = []
    
    # Header
    sections.append("## 🔍 Translation Validation Report")
    sections.append("")
    sections.append("This is an automated check of translation quality. Issues found are informational and don't block the PR.")
    sections.append("")
    
    has_issues = False
    
    # App name issues
    if app_name_issues:
        has_issues = True
        sections.append("### ⚠️ App Name Should Not Be Translated")
        sections.append("")
        sections.append("The `app_name` key should always be `\"Open Food Facts\"` (not translated).")
        sections.append("")
        sections.append(f"Found {len(app_name_issues)} file(s) with translated app_name:")
        sections.append("")
        for filename, locale, app_name, crowdin_link in app_name_issues:
            sections.append(f"  - `{filename}`: \"{app_name}\" - [Fix on Crowdin]({crowdin_link})")
        sections.append("")
    
    # Brand term issues
    for brand_term, issues in brand_term_issues.items():
        if issues:
            has_issues = True
            sections.append(f"### ⚠️ Brand Term \"{brand_term}\" Should Be Preserved")
            sections.append("")
            sections.append(f"Found {len(issues)} translation(s) where \"{brand_term}\" was not preserved:")
            sections.append("")
            for filename, locale, key, en_value, trans_value, crowdin_link in issues:
                sections.append(f"  - `{filename}`: `{key}` - [Fix on Crowdin]({crowdin_link})")
                sections.append(f"    - English: \"{en_value}\"")
                sections.append(f"    - Translation: \"{trans_value}\"")
            sections.append("")
    
    # Locale-specific URL issues
    if locale_url_issues:
        has_issues = True
        sections.append("### ⚠️ Locale-Specific URLs Should Use Correct Language Code")
        sections.append("")
        sections.append("URLs like `https://world-en.openfoodfacts.org/...` should be translated to use the file's language code (e.g., `https://world-fr.openfoodfacts.org/...` for French).")
        sections.append("")
        sections.append(f"Found {len(locale_url_issues)} issue(s):")
        sections.append("")
        for filename, locale, key, en_value, trans_value, crowdin_link in locale_url_issues:
            sections.append(f"  - `{filename}`: `{key}` - [Fix on Crowdin]({crowdin_link})")
            sections.append(f"    - Expected language code: `{locale}`")
            sections.append(f"    - English: \"{en_value}\"")
            sections.append(f"    - Translation: \"{trans_value}\"")
        sections.append("")
    
    # Open Prices URL issues
    if open_prices_issues:
        has_issues = True
        sections.append("### ⚠️ Open Prices URLs Should Never Be Translated")
        sections.append("")
        sections.append("URLs containing `prices.openfoodfacts.org` should remain exactly as in the English version.")
        sections.append("")
        sections.append(f"Found {len(open_prices_issues)} issue(s):")
        sections.append("")
        for filename, locale, key, en_value, trans_value, crowdin_link in open_prices_issues:
            sections.append(f"  - `{filename}`: `{key}` - [Fix on Crowdin]({crowdin_link})")
            sections.append(f"    - English: \"{en_value}\"")
            sections.append(f"    - Translation: \"{trans_value}\"")
        sections.append("")
    
    # Translated URL path 404 issues
    if translated_path_404_issues:
        has_issues = True
        sections.append("### ⚠️ Translated URL Paths Return 404 Errors")
        sections.append("")
        sections.append("The following URLs with translated paths are not accessible (return 404):")
        sections.append("")
        sections.append(f"Found {len(translated_path_404_issues)} issue(s):")
        sections.append("")
        for filename, locale, key, en_value, trans_url, status, crowdin_link in translated_path_404_issues:
            sections.append(f"  - `{filename}`: `{key}` - [Fix on Crowdin]({crowdin_link})")
            sections.append(f"    - URL returns {status}: \"{trans_url}\"")
            sections.append(f"    - English: \"{en_value}\"")
        sections.append("")
    
    # URL format issues
    if url_key_issues:
        has_issues = True
        sections.append("### ⚠️ Invalid URLs in URL Fields")
        sections.append("")
        sections.append(f"Found {len(url_key_issues)} invalid URL(s):")
        sections.append("")
        for filename, locale, key, value, crowdin_link in url_key_issues:
            sections.append(f"  - `{filename}`: `{key}` = \"{value}\" - [Fix on Crowdin]({crowdin_link})")
        sections.append("")
    
    if url_text_issues:
        has_issues = True
        sections.append("### ⚠️ Invalid URLs in Text Strings")
        sections.append("")
        sections.append(f"Found {len(url_text_issues)} issue(s):")
        sections.append("")
        for filename, locale, key, clean_url, crowdin_link in url_text_issues:
            sections.append(f"  - `{filename}`: `{key}` - [Fix on Crowdin]({crowdin_link})")
            sections.append(f"    - URL: \"{clean_url}\"")
        sections.append("")
    
    # Missing keys
    if missing_keys:
        has_issues = True
        sections.append("### ⚠️ Missing Required Keys")
        sections.append("")
        sections.append(f"Found {len(missing_keys)} file(s) without `app_name` key:")
        sections.append("")
        for filename, locale in missing_keys:
            sections.append(f"  - `{filename}`")
        sections.append("")
    
    # Footer
    if has_issues:
        sections.append("---")
        sections.append("")
        sections.append("**Note:** These are informational warnings to help improve translation quality. ")
        sections.append("Some variations may be acceptable based on language requirements. ")
        sections.append("Please review and decide if any action is needed.")
    else:
        sections.append("### ✅ No Issues Found")
        sections.append("")
        sections.append("All translations look good!")
    
    return "\n".join(sections)


def main():
    """Main function to run translation validation."""
    # Find the l10n directory
    repo_root = Path(__file__).parent.parent.parent
    l10n_dir = repo_root / 'packages' / 'smooth_app' / 'lib' / 'l10n'
    
    if not l10n_dir.exists():
        print(f"Error: l10n directory not found at {l10n_dir}", file=sys.stderr)
        sys.exit(1)
    
    # Get all ARB files
    arb_files = get_arb_files(l10n_dir)
    
    # Load English translations for reference
    en_file = l10n_dir / 'app_en.arb'
    en_translations = load_arb_file(en_file)
    
    # Run validations
    print("Running validation checks...", file=sys.stderr)
    app_name_issues = validate_app_name(arb_files)
    print(f"  - App name check: {len(app_name_issues)} issues", file=sys.stderr)
    
    brand_term_issues = validate_brand_terms(arb_files, en_translations)
    total_brand_issues = sum(len(issues) for issues in brand_term_issues.values())
    print(f"  - Brand terms check: {total_brand_issues} issues", file=sys.stderr)
    
    url_key_issues, url_text_issues = validate_urls(arb_files)
    print(f"  - URL format check: {len(url_key_issues) + len(url_text_issues)} issues", file=sys.stderr)
    
    locale_url_issues = validate_locale_specific_urls(arb_files, en_translations)
    print(f"  - Locale-specific URLs check: {len(locale_url_issues)} issues", file=sys.stderr)
    
    open_prices_issues = validate_open_prices_urls(arb_files, en_translations)
    print(f"  - Open Prices URLs check: {len(open_prices_issues)} issues", file=sys.stderr)
    
    print("  - Checking translated URL paths for 404 errors (may take a moment)...", file=sys.stderr)
    translated_path_404_issues = validate_translated_url_paths(arb_files, en_translations)
    print(f"  - Translated URL paths check: {len(translated_path_404_issues)} issues", file=sys.stderr)
    
    missing_keys = validate_required_keys(arb_files)
    print(f"  - Missing keys check: {len(missing_keys)} issues", file=sys.stderr)
    
    # Format and output comment
    comment = format_validation_comment(
        app_name_issues,
        brand_term_issues,
        url_key_issues,
        url_text_issues,
        missing_keys,
        locale_url_issues,
        open_prices_issues,
        translated_path_404_issues
    )
    
    print(comment)
    
    # Exit with 0 (success) - we don't want to block PRs
    sys.exit(0)


if __name__ == '__main__':
    main()
