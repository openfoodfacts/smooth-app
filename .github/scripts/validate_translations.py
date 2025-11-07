#!/usr/bin/env python3
"""
Translation validation script for Open Food Facts mobile app.

This script validates translation files (.arb) for common issues:
1. app_name should always be "Open Food Facts" (not translated)
2. Brand terms (Nutri-Score, NOVA, Open Food Facts, etc.) should be preserved
3. URLs should be valid and not broken
4. All ARB files should have required keys

The script outputs validation warnings in a format suitable for GitHub PR comments.
"""

import json
import os
import re
import sys
from pathlib import Path
from typing import Dict, List, Set, Tuple


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


def validate_app_name(arb_files: List[Path]) -> List[str]:
    """Validate that app_name is always 'Open Food Facts'."""
    issues = []
    
    for arb_file in arb_files:
        translations = load_arb_file(arb_file)
        if 'app_name' in translations:
            app_name = translations['app_name']
            if app_name != 'Open Food Facts':
                issues.append(f"  - `{arb_file.name}`: \"{app_name}\"")
    
    return issues


def validate_brand_terms(arb_files: List[Path], en_translations: Dict) -> Dict[str, List[str]]:
    """Validate that brand terms are preserved in translations."""
    all_issues = {}
    
    for brand_term, keys_to_check in BRAND_TERMS.items():
        issues = []
        
        for arb_file in arb_files:
            if arb_file.name == 'app_en.arb':
                continue
                
            translations = load_arb_file(arb_file)
            
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
                    issues.append(f"  - `{arb_file.name}`: `{key}`")
                    issues.append(f"    - English: \"{en_value}\"")
                    issues.append(f"    - Translation: \"{translated_value}\"")
        
        if issues:
            all_issues[brand_term] = issues
    
    return all_issues


def validate_urls(arb_files: List[Path]) -> Tuple[List[str], List[str]]:
    """Validate URLs in translation files."""
    url_pattern = re.compile(r'^https?://[^\s<>"{}|\\^`\[\]]+$', re.IGNORECASE)
    url_in_text_pattern = re.compile(r'https?://[^\s<>"{}|\\^`\[\]]+', re.IGNORECASE)
    domain_pattern = re.compile(r'^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}')
    
    url_key_issues = []
    url_text_issues = []
    
    for arb_file in arb_files:
        translations = load_arb_file(arb_file)
        
        # Check URL keys
        for url_key in URL_KEYS:
            if url_key in translations:
                value = translations[url_key]
                if value and not url_pattern.match(value):
                    url_key_issues.append(f"  - `{arb_file.name}`: `{url_key}` = \"{value}\"")
        
        # Check URLs in text
        for key, value in translations.items():
            if key.startswith('@') or not isinstance(value, str):
                continue
            
            matches = url_in_text_pattern.findall(value)
            for url in matches:
                clean_url = re.sub(r'[.,;!?]+$', '', url)
                if not domain_pattern.match(clean_url):
                    url_text_issues.append(f"  - `{arb_file.name}`: `{key}`")
                    url_text_issues.append(f"    - URL: \"{clean_url}\"")
    
    return url_key_issues, url_text_issues


def validate_required_keys(arb_files: List[Path]) -> List[str]:
    """Validate that all ARB files have required keys."""
    missing = []
    
    for arb_file in arb_files:
        translations = load_arb_file(arb_file)
        if 'app_name' not in translations:
            missing.append(f"  - `{arb_file.name}`")
    
    return missing


def format_validation_comment(
    app_name_issues: List[str],
    brand_term_issues: Dict[str, List[str]],
    url_key_issues: List[str],
    url_text_issues: List[str],
    missing_keys: List[str]
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
        sections.extend(app_name_issues[:10])  # Limit to 10 examples
        if len(app_name_issues) > 10:
            sections.append(f"  - ... and {len(app_name_issues) - 10} more")
        sections.append("")
    
    # Brand term issues
    for brand_term, issues in brand_term_issues.items():
        if issues:
            has_issues = True
            num_issues = len(issues) // 3  # Each issue has 3 lines
            sections.append(f"### ⚠️ Brand Term \"{brand_term}\" Should Be Preserved")
            sections.append("")
            sections.append(f"Found {num_issues} translation(s) where \"{brand_term}\" was not preserved:")
            sections.append("")
            sections.extend(issues[:15])  # Limit to 5 examples (3 lines each)
            if len(issues) > 15:
                sections.append(f"  - ... and {num_issues - 5} more")
            sections.append("")
    
    # URL issues
    if url_key_issues:
        has_issues = True
        sections.append("### ⚠️ Invalid URLs in URL Fields")
        sections.append("")
        sections.append(f"Found {len(url_key_issues)} invalid URL(s):")
        sections.append("")
        sections.extend(url_key_issues[:10])
        if len(url_key_issues) > 10:
            sections.append(f"  - ... and {len(url_key_issues) - 10} more")
        sections.append("")
    
    if url_text_issues:
        has_issues = True
        num_issues = len(url_text_issues) // 2
        sections.append("### ⚠️ Invalid URLs in Text Strings")
        sections.append("")
        sections.append(f"Found {num_issues} issue(s):")
        sections.append("")
        sections.extend(url_text_issues[:10])
        if len(url_text_issues) > 10:
            sections.append(f"  - ... and {num_issues - 5} more")
        sections.append("")
    
    # Missing keys
    if missing_keys:
        has_issues = True
        sections.append("### ⚠️ Missing Required Keys")
        sections.append("")
        sections.append(f"Found {len(missing_keys)} file(s) without `app_name` key:")
        sections.append("")
        sections.extend(missing_keys[:10])
        if len(missing_keys) > 10:
            sections.append(f"  - ... and {len(missing_keys) - 10} more")
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
    app_name_issues = validate_app_name(arb_files)
    brand_term_issues = validate_brand_terms(arb_files, en_translations)
    url_key_issues, url_text_issues = validate_urls(arb_files)
    missing_keys = validate_required_keys(arb_files)
    
    # Format and output comment
    comment = format_validation_comment(
        app_name_issues,
        brand_term_issues,
        url_key_issues,
        url_text_issues,
        missing_keys
    )
    
    print(comment)
    
    # Exit with 0 (success) - we don't want to block PRs
    sys.exit(0)


if __name__ == '__main__':
    main()
