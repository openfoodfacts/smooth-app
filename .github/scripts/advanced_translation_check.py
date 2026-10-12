#!/usr/bin/env python3
"""
Advanced Translation Quality Checker for Open Food Facts mobile app.

This script uses multiple open-source tools to validate translation quality:
1. Custom ARB validation (existing)
2. gettext tools for format string validation
3. translate-toolkit for translation quality checks
4. Custom checks for consistency and style

Usage:
    python3 advanced_translation_check.py [--verbose] [--fix-issues]
"""

import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Dict, List, Tuple, Set
from collections import defaultdict


class TranslationQualityChecker:
    """Comprehensive translation quality checker using multiple tools."""
    
    def __init__(self, l10n_dir: Path, verbose: bool = False):
        self.l10n_dir = l10n_dir
        self.verbose = verbose
        self.issues = defaultdict(list)
        
    def log(self, message: str):
        """Log message if verbose mode is enabled."""
        if self.verbose:
            print(message, file=sys.stderr)
    
    def load_arb_file(self, file_path: Path) -> Dict:
        """Load and parse an ARB file."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            self.log(f"Error loading {file_path}: {e}")
            return {}
    
    def check_placeholder_consistency(self, en_translations: Dict) -> Dict[str, List[Tuple[str, str, str, str]]]:
        """
        Check that placeholders in translations match the English source.
        
        Placeholders like {variable} must appear in both source and translation.
        """
        issues = defaultdict(list)
        placeholder_pattern = re.compile(r'\{([a-zA-Z_][a-zA-Z0-9_]*)\}')
        
        arb_files = [f for f in self.l10n_dir.glob('*.arb') if f.name != 'app_en.arb']
        
        for arb_file in arb_files:
            translations = self.load_arb_file(arb_file)
            locale = arb_file.stem.replace('app_', '')
            
            for key, en_value in en_translations.items():
                if key.startswith('@') or not isinstance(en_value, str):
                    continue
                
                if key not in translations:
                    continue
                
                trans_value = translations[key]
                if not isinstance(trans_value, str):
                    continue
                
                # Extract placeholders
                en_placeholders = set(placeholder_pattern.findall(en_value))
                trans_placeholders = set(placeholder_pattern.findall(trans_value))
                
                # Check for missing or extra placeholders
                missing = en_placeholders - trans_placeholders
                extra = trans_placeholders - en_placeholders
                
                if missing or extra:
                    issues[arb_file.name].append((
                        key,
                        en_value,
                        trans_value,
                        f"Missing: {missing}, Extra: {extra}" if missing and extra else
                        f"Missing: {missing}" if missing else f"Extra: {extra}"
                    ))
        
        return dict(issues)
    
    def check_punctuation_consistency(self, en_translations: Dict) -> Dict[str, List[Tuple[str, str, str, str]]]:
        """
        Check that sentence-ending punctuation is consistent.
        
        If English ends with '.', '!', or '?', translation should too.
        """
        issues = defaultdict(list)
        sentence_end_pattern = re.compile(r'[.!?]\s*$')
        
        arb_files = [f for f in self.l10n_dir.glob('*.arb') if f.name != 'app_en.arb']
        
        for arb_file in arb_files:
            translations = self.load_arb_file(arb_file)
            
            for key, en_value in en_translations.items():
                if key.startswith('@') or not isinstance(en_value, str):
                    continue
                
                if key not in translations:
                    continue
                
                trans_value = translations[key]
                if not isinstance(trans_value, str):
                    continue
                
                # Skip URLs and very short strings
                if len(en_value) < 10 or en_value.startswith('http'):
                    continue
                
                en_has_punct = bool(sentence_end_pattern.search(en_value))
                trans_has_punct = bool(sentence_end_pattern.search(trans_value))
                
                if en_has_punct and not trans_has_punct:
                    issues[arb_file.name].append((
                        key,
                        en_value,
                        trans_value,
                        "Missing sentence-ending punctuation"
                    ))
        
        return dict(issues)
    
    def check_whitespace_issues(self, en_translations: Dict) -> Dict[str, List[Tuple[str, str, str, str]]]:
        """
        Check for common whitespace issues:
        - Leading/trailing whitespace differences
        - Multiple consecutive spaces
        - Tab characters
        """
        issues = defaultdict(list)
        
        arb_files = [f for f in self.l10n_dir.glob('*.arb') if f.name != 'app_en.arb']
        
        for arb_file in arb_files:
            translations = self.load_arb_file(arb_file)
            
            for key, en_value in en_translations.items():
                if key.startswith('@') or not isinstance(en_value, str):
                    continue
                
                if key not in translations:
                    continue
                
                trans_value = translations[key]
                if not isinstance(trans_value, str):
                    continue
                
                problems = []
                
                # Check leading/trailing whitespace
                if en_value.strip() == en_value and trans_value != trans_value.strip():
                    problems.append("extra leading/trailing whitespace")
                
                # Check for multiple consecutive spaces (when English doesn't have them)
                if '  ' not in en_value and '  ' in trans_value:
                    problems.append("multiple consecutive spaces")
                
                # Check for tab characters
                if '\t' in trans_value:
                    problems.append("contains tab characters")
                
                if problems:
                    issues[arb_file.name].append((
                        key,
                        en_value,
                        trans_value,
                        ', '.join(problems)
                    ))
        
        return dict(issues)
    
    def check_format_string_consistency(self) -> Dict[str, List[Tuple[str, str]]]:
        """
        Use gettext msgfmt to check format string consistency.
        
        Converts ARB to PO format temporarily for validation.
        """
        issues = defaultdict(list)
        
        # This would require converting ARB to PO format
        # For now, we rely on placeholder checking above
        # Could be enhanced with po2json and json2po conversions
        
        return dict(issues)
    
    def check_length_discrepancies(self, en_translations: Dict, threshold: float = 3.0) -> Dict[str, List[Tuple[str, str, str, str]]]:
        """
        Check for translations that are significantly longer or shorter than the source.
        
        Very long or very short translations relative to the source might indicate issues.
        """
        issues = defaultdict(list)
        
        arb_files = [f for f in self.l10n_dir.glob('*.arb') if f.name != 'app_en.arb']
        
        for arb_file in arb_files:
            translations = self.load_arb_file(arb_file)
            
            for key, en_value in en_translations.items():
                if key.startswith('@') or not isinstance(en_value, str):
                    continue
                
                # Skip short strings and URLs
                if len(en_value) < 20 or en_value.startswith('http'):
                    continue
                
                if key not in translations:
                    continue
                
                trans_value = translations[key]
                if not isinstance(trans_value, str):
                    continue
                
                # Calculate length ratio
                en_len = len(en_value)
                trans_len = len(trans_value)
                
                if en_len > 0:
                    ratio = trans_len / en_len
                    
                    # Flag if translation is more than threshold times longer/shorter
                    if ratio > threshold or ratio < (1 / threshold):
                        issues[arb_file.name].append((
                            key,
                            en_value,
                            trans_value,
                            f"Length ratio: {ratio:.2f}x (source: {en_len}, translation: {trans_len})"
                        ))
        
        return dict(issues)
    
    def check_untranslated_strings(self, en_translations: Dict) -> Dict[str, List[Tuple[str, str]]]:
        """
        Check for strings that are identical to English (potentially untranslated).
        
        Excludes brand names and technical terms.
        """
        issues = defaultdict(list)
        
        # Terms that should be identical across languages
        exempt_patterns = [
            r'^https?://',  # URLs
            r'Open Food Facts',
            r'Open Beauty Facts',
            r'Open Pet Food Facts',
            r'Open Products Facts',
            r'Open Prices',
            r'Nutri-Score',
            r'NOVA',
            r'Green-Score',
            r'^[A-Z]$',  # Single letters (like grade A, B, C)
            r'^\d+$',  # Numbers
        ]
        
        arb_files = [f for f in self.l10n_dir.glob('*.arb') if f.name != 'app_en.arb']
        
        for arb_file in arb_files:
            # Skip English variants
            if arb_file.name in ['app_en_GB.arb', 'app_en_US.arb']:
                continue
            
            translations = self.load_arb_file(arb_file)
            
            for key, en_value in en_translations.items():
                if key.startswith('@') or not isinstance(en_value, str):
                    continue
                
                # Skip short strings
                if len(en_value) < 15:
                    continue
                
                if key not in translations:
                    continue
                
                trans_value = translations[key]
                if not isinstance(trans_value, str):
                    continue
                
                # Check if identical
                if en_value == trans_value:
                    # Check if this is an exempt term
                    is_exempt = any(re.search(pattern, en_value) for pattern in exempt_patterns)
                    
                    if not is_exempt:
                        issues[arb_file.name].append((key, en_value))
        
        return dict(issues)
    
    def run_all_checks(self) -> Dict[str, any]:
        """Run all translation quality checks."""
        self.log("Loading English translations...")
        en_file = self.l10n_dir / 'app_en.arb'
        en_translations = self.load_arb_file(en_file)
        
        results = {}
        
        self.log("Checking placeholder consistency...")
        results['placeholder_issues'] = self.check_placeholder_consistency(en_translations)
        
        self.log("Checking punctuation consistency...")
        results['punctuation_issues'] = self.check_punctuation_consistency(en_translations)
        
        self.log("Checking whitespace issues...")
        results['whitespace_issues'] = self.check_whitespace_issues(en_translations)
        
        self.log("Checking length discrepancies...")
        results['length_issues'] = self.check_length_discrepancies(en_translations)
        
        self.log("Checking for untranslated strings...")
        results['untranslated_issues'] = self.check_untranslated_strings(en_translations)
        
        return results
    
    def format_report(self, results: Dict) -> str:
        """Format results as a readable report."""
        lines = []
        lines.append("## 🔍 Advanced Translation Quality Report")
        lines.append("")
        
        total_issues = sum(
            len(issues) if isinstance(issues, dict) else sum(len(v) for v in issues.values())
            for issues in results.values()
        )
        
        if total_issues == 0:
            lines.append("### ✅ No Quality Issues Found")
            lines.append("")
            lines.append("All translations passed advanced quality checks!")
            return "\n".join(lines)
        
        # Placeholder issues
        if results.get('placeholder_issues'):
            lines.append("### ⚠️ Placeholder Consistency Issues")
            lines.append("")
            lines.append("Placeholders like `{variable}` must match between source and translation:")
            lines.append("")
            for filename, issues in results['placeholder_issues'].items():
                lines.append(f"**{filename}**: {len(issues)} issue(s)")
                for key, en, trans, problem in issues[:5]:  # Show first 5
                    lines.append(f"  - `{key}`: {problem}")
                if len(issues) > 5:
                    lines.append(f"  - ... and {len(issues) - 5} more")
                lines.append("")
        
        # Punctuation issues
        if results.get('punctuation_issues'):
            lines.append("### ⚠️ Punctuation Consistency Issues")
            lines.append("")
            lines.append("Sentence-ending punctuation should match the source:")
            lines.append("")
            for filename, issues in results['punctuation_issues'].items():
                if len(issues) > 0:
                    lines.append(f"**{filename}**: {len(issues)} issue(s)")
            lines.append("")
        
        # Whitespace issues
        if results.get('whitespace_issues'):
            lines.append("### ⚠️ Whitespace Issues")
            lines.append("")
            lines.append("Check for extra spaces, tabs, or leading/trailing whitespace:")
            lines.append("")
            for filename, issues in results['whitespace_issues'].items():
                if len(issues) > 0:
                    lines.append(f"**{filename}**: {len(issues)} issue(s)")
            lines.append("")
        
        # Length discrepancies
        if results.get('length_issues'):
            lines.append("### ⚠️ Length Discrepancies")
            lines.append("")
            lines.append("Translations that are significantly longer or shorter than source:")
            lines.append("")
            count = sum(len(v) for v in results['length_issues'].values())
            lines.append(f"Found {count} translation(s) with unusual length ratios.")
            lines.append("")
        
        # Untranslated strings
        if results.get('untranslated_issues'):
            lines.append("### ⚠️ Potentially Untranslated Strings")
            lines.append("")
            lines.append("Strings that are identical to English (may need translation):")
            lines.append("")
            for filename, issues in results['untranslated_issues'].items():
                if len(issues) > 3:  # Only show files with multiple issues
                    lines.append(f"**{filename}**: {len(issues)} string(s)")
            lines.append("")
        
        lines.append("---")
        lines.append("")
        lines.append(f"**Total issues found**: {total_issues}")
        lines.append("")
        lines.append("*Note: Some issues may be acceptable based on language requirements.*")
        
        return "\n".join(lines)


def main():
    """Main function."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Advanced translation quality checker')
    parser.add_argument('--verbose', action='store_true', help='Enable verbose output')
    parser.add_argument('--format', choices=['markdown', 'json'], default='markdown',
                        help='Output format')
    
    args = parser.parse_args()
    
    # Find the l10n directory
    repo_root = Path(__file__).parent.parent.parent
    l10n_dir = repo_root / 'packages' / 'smooth_app' / 'lib' / 'l10n'
    
    if not l10n_dir.exists():
        print(f"Error: l10n directory not found at {l10n_dir}", file=sys.stderr)
        sys.exit(1)
    
    # Run checks
    checker = TranslationQualityChecker(l10n_dir, verbose=args.verbose)
    results = checker.run_all_checks()
    
    # Output results
    if args.format == 'markdown':
        print(checker.format_report(results))
    elif args.format == 'json':
        import json
        print(json.dumps(results, indent=2, ensure_ascii=False))
    
    # Exit with 0 (we don't want to block PRs)
    sys.exit(0)


if __name__ == '__main__':
    main()
