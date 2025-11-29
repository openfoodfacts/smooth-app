#!/usr/bin/env python3
"""
Tagline JSON validation script for Open Food Facts mobile app.

This script validates tagline JSON files against the expected structure defined in:
packages/smooth_app/lib/data_models/news_feed/newsfeed_json.dart

The script fetches the tagline JSON from the assets repository and validates:
1. Root structure: must have 'news' and 'tagline_feed' objects
2. Each news item must have:
   - 'url': non-empty string
   - 'translations': object with at least a 'default' key
   - Default translation must have non-empty 'title' and 'message'
   - Optional: 'min_launches', 'start_date', 'end_date', 'min_version', 'max_version', 'style'
3. Each tagline_feed locale must have:
   - 'news': array with items that have non-empty 'id' strings
4. Style fields must start with '#' if present (for colors)
5. Image width must be between 0.0 and 1.0 if present

Usage:
    python validate_tagline_json.py [--url URL]

Exit codes:
    0: Validation passed (or only warnings)
    1: Validation failed
"""

import argparse
import json
import re
import sys
import urllib.request
import urllib.error
from typing import Dict, List, Optional, Tuple, Any

# URLs for the tagline JSON files
TAGLINE_URLS = {
    'android_prod': 'https://raw.githubusercontent.com/openfoodfacts/smooth-app_assets/refs/heads/main/prod/tagline/android/main.json',
    'ios_prod': 'https://raw.githubusercontent.com/openfoodfacts/smooth-app_assets/refs/heads/main/prod/tagline/ios/main.json',
    'android_dev': 'https://raw.githubusercontent.com/openfoodfacts/smooth-app_assets/refs/heads/main/dev/tagline/android/main.json',
    'ios_dev': 'https://raw.githubusercontent.com/openfoodfacts/smooth-app_assets/refs/heads/main/dev/tagline/ios/main.json',
}

# Color hex pattern
COLOR_HEX_PATTERN = re.compile(r'^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$')


class ValidationError:
    """Represents a validation error."""
    def __init__(self, path: str, message: str, severity: str = 'error'):
        self.path = path
        self.message = message
        self.severity = severity  # 'error' or 'warning'

    def __str__(self):
        return f"[{self.severity.upper()}] {self.path}: {self.message}"


def fetch_json(url: str, timeout: int = 30) -> Tuple[Optional[Dict], Optional[str]]:
    """Fetch and parse JSON from a URL.
    
    Returns: (parsed_json, error_message)
    """
    try:
        req = urllib.request.Request(url)
        req.add_header('User-Agent', 'Mozilla/5.0 (compatible; TaglineValidator/1.0)')
        with urllib.request.urlopen(req, timeout=timeout) as response:
            content = response.read().decode('utf-8')
            return json.loads(content), None
    except urllib.error.HTTPError as e:
        return None, f"HTTP error {e.code}: {e.reason}"
    except urllib.error.URLError as e:
        return None, f"URL error: {e.reason}"
    except json.JSONDecodeError as e:
        return None, f"JSON parse error: {e}"
    except Exception as e:
        return None, f"Error: {e}"


def validate_string_not_empty(value: Any, path: str) -> List[ValidationError]:
    """Validate that a value is a non-empty string."""
    errors = []
    if not isinstance(value, str):
        errors.append(ValidationError(path, f"Expected string, got {type(value).__name__}"))
    elif not value.strip():
        errors.append(ValidationError(path, "String is empty or whitespace only"))
    return errors


def validate_color_hex(value: Any, path: str) -> List[ValidationError]:
    """Validate that a value is a valid hex color (starts with #)."""
    errors = []
    if value is not None:
        if not isinstance(value, str):
            errors.append(ValidationError(path, f"Expected string, got {type(value).__name__}"))
        elif not value.startswith('#'):
            errors.append(ValidationError(path, f"Color must start with '#', got: {value}"))
        elif not COLOR_HEX_PATTERN.match(value):
            errors.append(ValidationError(path, f"Invalid hex color format: {value}", severity='warning'))
    return errors


def validate_image_width(value: Any, path: str) -> List[ValidationError]:
    """Validate that image width is between 0.0 and 1.0."""
    errors = []
    if value is not None:
        if not isinstance(value, (int, float)):
            errors.append(ValidationError(path, f"Expected number, got {type(value).__name__}"))
        elif value < 0.0 or value > 1.0:
            errors.append(ValidationError(path, f"Width must be between 0.0 and 1.0, got: {value}"))
    return errors


def validate_style(style: Any, path: str) -> List[ValidationError]:
    """Validate a style object."""
    errors = []
    if style is None:
        return errors
    
    if not isinstance(style, dict):
        errors.append(ValidationError(path, f"Expected object, got {type(style).__name__}"))
        return errors
    
    color_fields = [
        'title_background', 'title_text_color', 'title_indicator_color',
        'message_background', 'message_text_color',
        'button_background', 'button_text_color',
        'content_background_color'
    ]
    
    for field in color_fields:
        if field in style:
            errors.extend(validate_color_hex(style[field], f"{path}.{field}"))
    
    return errors


def validate_image(image: Any, path: str, require_url: bool = False) -> List[ValidationError]:
    """Validate an image object."""
    errors = []
    if image is None:
        return errors
    
    if not isinstance(image, dict):
        errors.append(ValidationError(path, f"Expected object, got {type(image).__name__}"))
        return errors
    
    # URL validation
    if require_url:
        if 'url' not in image:
            errors.append(ValidationError(f"{path}.url", "Required field 'url' is missing"))
        else:
            errors.extend(validate_string_not_empty(image['url'], f"{path}.url"))
    elif 'url' in image and image['url'] is not None:
        errors.extend(validate_string_not_empty(image['url'], f"{path}.url"))
    
    # Width validation
    if 'width' in image:
        errors.extend(validate_image_width(image['width'], f"{path}.width"))
    
    # Alt text validation
    if 'alt' in image and image['alt'] is not None:
        errors.extend(validate_string_not_empty(image['alt'], f"{path}.alt"))
    
    return errors


def validate_translation(trans: Any, path: str, is_default: bool = False) -> List[ValidationError]:
    """Validate a translation object."""
    errors = []
    
    if not isinstance(trans, dict):
        errors.append(ValidationError(path, f"Expected object, got {type(trans).__name__}"))
        return errors
    
    # Default translation must have title and message
    if is_default:
        if 'title' not in trans:
            errors.append(ValidationError(f"{path}.title", "Required field 'title' is missing in default translation"))
        else:
            errors.extend(validate_string_not_empty(trans['title'], f"{path}.title"))
        
        if 'message' not in trans:
            errors.append(ValidationError(f"{path}.message", "Required field 'message' is missing in default translation"))
        else:
            errors.extend(validate_string_not_empty(trans['message'], f"{path}.message"))
        
        # If image exists in default, it must have a URL
        if 'image' in trans and trans['image'] is not None:
            errors.extend(validate_image(trans['image'], f"{path}.image", require_url=True))
        if 'image_dark' in trans and trans['image_dark'] is not None:
            errors.extend(validate_image(trans['image_dark'], f"{path}.image_dark", require_url=True))
    else:
        # Non-default translations: optional fields, but if present must be valid
        if 'title' in trans and trans['title'] is not None:
            errors.extend(validate_string_not_empty(trans['title'], f"{path}.title"))
        if 'message' in trans and trans['message'] is not None:
            errors.extend(validate_string_not_empty(trans['message'], f"{path}.message"))
        if 'url' in trans and trans['url'] is not None:
            errors.extend(validate_string_not_empty(trans['url'], f"{path}.url"))
        if 'button_label' in trans and trans['button_label'] is not None:
            errors.extend(validate_string_not_empty(trans['button_label'], f"{path}.button_label"))
        if 'image' in trans:
            errors.extend(validate_image(trans['image'], f"{path}.image"))
        if 'image_dark' in trans:
            errors.extend(validate_image(trans['image_dark'], f"{path}.image_dark"))
    
    return errors


def validate_news_item(item_id: str, item: Any, path: str) -> List[ValidationError]:
    """Validate a single news item."""
    errors = []
    
    if not isinstance(item, dict):
        errors.append(ValidationError(path, f"Expected object, got {type(item).__name__}"))
        return errors
    
    # URL is required
    if 'url' not in item:
        errors.append(ValidationError(f"{path}.url", "Required field 'url' is missing"))
    else:
        errors.extend(validate_string_not_empty(item['url'], f"{path}.url"))
    
    # Translations are required
    if 'translations' not in item:
        errors.append(ValidationError(f"{path}.translations", "Required field 'translations' is missing"))
    elif not isinstance(item['translations'], dict):
        errors.append(ValidationError(f"{path}.translations", f"Expected object, got {type(item['translations']).__name__}"))
    else:
        translations = item['translations']
        
        # Default translation is required
        if 'default' not in translations:
            errors.append(ValidationError(f"{path}.translations.default", "Required 'default' translation is missing"))
        else:
            errors.extend(validate_translation(translations['default'], f"{path}.translations.default", is_default=True))
        
        # Validate other translations
        for locale, trans in translations.items():
            if locale != 'default':
                errors.extend(validate_translation(trans, f"{path}.translations.{locale}"))
    
    # Optional fields validation
    if 'min_launches' in item and item['min_launches'] is not None:
        if not isinstance(item['min_launches'], int):
            errors.append(ValidationError(f"{path}.min_launches", f"Expected integer, got {type(item['min_launches']).__name__}"))
    
    # Style validation
    if 'style' in item:
        errors.extend(validate_style(item['style'], f"{path}.style"))
    
    return errors


def validate_feed_item(item: Any, path: str) -> List[ValidationError]:
    """Validate a single feed item."""
    errors = []
    
    if not isinstance(item, dict):
        errors.append(ValidationError(path, f"Expected object, got {type(item).__name__}"))
        return errors
    
    # ID is required
    if 'id' not in item:
        errors.append(ValidationError(f"{path}.id", "Required field 'id' is missing"))
    else:
        errors.extend(validate_string_not_empty(item['id'], f"{path}.id"))
    
    # Override validation (optional)
    if 'override' in item and item['override'] is not None:
        override = item['override']
        if not isinstance(override, dict):
            errors.append(ValidationError(f"{path}.override", f"Expected object, got {type(override).__name__}"))
        else:
            if 'url' in override and override['url'] is not None:
                errors.extend(validate_string_not_empty(override['url'], f"{path}.override.url"))
            if 'style' in override:
                errors.extend(validate_style(override['style'], f"{path}.override.style"))
    
    return errors


def validate_feed_locale(locale: str, feed: Any, path: str) -> List[ValidationError]:
    """Validate a single feed locale."""
    errors = []
    
    if not isinstance(feed, dict):
        errors.append(ValidationError(path, f"Expected object, got {type(feed).__name__}"))
        return errors
    
    if 'news' not in feed:
        errors.append(ValidationError(f"{path}.news", "Required field 'news' is missing"))
    elif not isinstance(feed['news'], list):
        errors.append(ValidationError(f"{path}.news", f"Expected array, got {type(feed['news']).__name__}"))
    else:
        for i, item in enumerate(feed['news']):
            errors.extend(validate_feed_item(item, f"{path}.news[{i}]"))
    
    return errors


def validate_tagline_json(data: Dict) -> List[ValidationError]:
    """Validate the entire tagline JSON structure."""
    errors = []
    
    # Root structure validation
    if not isinstance(data, dict):
        errors.append(ValidationError("root", f"Expected object at root, got {type(data).__name__}"))
        return errors
    
    # 'news' is required
    if 'news' not in data:
        errors.append(ValidationError("news", "Required field 'news' is missing"))
    elif not isinstance(data['news'], dict):
        errors.append(ValidationError("news", f"Expected object, got {type(data['news']).__name__}"))
    else:
        for item_id, item in data['news'].items():
            errors.extend(validate_news_item(item_id, item, f"news.{item_id}"))
    
    # 'tagline_feed' is required
    if 'tagline_feed' not in data:
        errors.append(ValidationError("tagline_feed", "Required field 'tagline_feed' is missing"))
    elif not isinstance(data['tagline_feed'], dict):
        errors.append(ValidationError("tagline_feed", f"Expected object, got {type(data['tagline_feed']).__name__}"))
    else:
        feeds = data['tagline_feed']
        
        # Default feed is required
        if 'default' not in feeds:
            errors.append(ValidationError("tagline_feed.default", "Required 'default' feed is missing"))
        
        for locale, feed in feeds.items():
            errors.extend(validate_feed_locale(locale, feed, f"tagline_feed.{locale}"))
    
    # Cross-reference validation: check that feed item IDs exist in news
    if 'news' in data and isinstance(data['news'], dict) and 'tagline_feed' in data and isinstance(data['tagline_feed'], dict):
        news_ids = set(data['news'].keys())
        for locale, feed in data['tagline_feed'].items():
            if isinstance(feed, dict) and 'news' in feed and isinstance(feed['news'], list):
                for i, item in enumerate(feed['news']):
                    if isinstance(item, dict) and 'id' in item:
                        if item['id'] not in news_ids:
                            errors.append(ValidationError(
                                f"tagline_feed.{locale}.news[{i}].id",
                                f"News item with id '{item['id']}' not found in 'news' section",
                                severity='error'
                            ))
    
    return errors


def format_validation_report(source: str, errors: List[ValidationError]) -> str:
    """Format validation results as a report."""
    sections = []
    
    sections.append(f"## Tagline JSON Validation Report")
    sections.append("")
    sections.append(f"**Source:** `{source}`")
    sections.append("")
    
    error_count = sum(1 for e in errors if e.severity == 'error')
    warning_count = sum(1 for e in errors if e.severity == 'warning')
    
    if not errors:
        sections.append("### ✅ Validation Passed")
        sections.append("")
        sections.append("The tagline JSON structure is valid.")
    else:
        if error_count > 0:
            sections.append(f"### ❌ Validation Failed")
            sections.append("")
            sections.append(f"Found {error_count} error(s) and {warning_count} warning(s).")
        else:
            sections.append(f"### ⚠️ Validation Passed with Warnings")
            sections.append("")
            sections.append(f"Found {warning_count} warning(s).")
        
        sections.append("")
        
        # Group errors by severity
        actual_errors = [e for e in errors if e.severity == 'error']
        warnings = [e for e in errors if e.severity == 'warning']
        
        if actual_errors:
            sections.append("#### Errors")
            sections.append("")
            for err in actual_errors:
                sections.append(f"- `{err.path}`: {err.message}")
            sections.append("")
        
        if warnings:
            sections.append("#### Warnings")
            sections.append("")
            for warn in warnings:
                sections.append(f"- `{warn.path}`: {warn.message}")
            sections.append("")
    
    return "\n".join(sections)


def main():
    """Main function to run tagline JSON validation."""
    parser = argparse.ArgumentParser(description='Validate tagline JSON files')
    parser.add_argument('--url', type=str, help='Custom URL to validate')
    parser.add_argument('--env', type=str, choices=['prod', 'dev', 'all'], default='prod',
                        help='Environment to validate (prod, dev, or all)')
    args = parser.parse_args()
    
    urls_to_validate = {}
    
    if args.url:
        urls_to_validate['custom'] = args.url
    else:
        if args.env in ('prod', 'all'):
            urls_to_validate['android_prod'] = TAGLINE_URLS['android_prod']
            urls_to_validate['ios_prod'] = TAGLINE_URLS['ios_prod']
        if args.env in ('dev', 'all'):
            urls_to_validate['android_dev'] = TAGLINE_URLS['android_dev']
            urls_to_validate['ios_dev'] = TAGLINE_URLS['ios_dev']
    
    all_reports = []
    has_errors = False
    
    for name, url in urls_to_validate.items():
        print(f"Validating {name}...", file=sys.stderr)
        
        data, fetch_error = fetch_json(url)
        
        if fetch_error:
            all_reports.append(f"## Tagline JSON Validation Report\n\n**Source:** `{name}`\n\n### ❌ Fetch Failed\n\n{fetch_error}")
            has_errors = True
            continue
        
        errors = validate_tagline_json(data)
        report = format_validation_report(name, errors)
        all_reports.append(report)
        
        if any(e.severity == 'error' for e in errors):
            has_errors = True
        
        print(f"  - Found {sum(1 for e in errors if e.severity == 'error')} error(s), {sum(1 for e in errors if e.severity == 'warning')} warning(s)", file=sys.stderr)
    
    # Output combined report
    print("\n---\n".join(all_reports))
    
    # Exit with error code if there were errors
    sys.exit(1 if has_errors else 0)


if __name__ == '__main__':
    main()
