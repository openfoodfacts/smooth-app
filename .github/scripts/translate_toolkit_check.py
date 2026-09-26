#!/usr/bin/env python3
"""
Comprehensive Translation Quality Checker using translate-toolkit.

This script converts ARB files to PO format and uses translate-toolkit's
pofilter to check for various translation quality issues.

Usage:
    python3 translate_toolkit_check.py [--verbose] [--filters FILTER1,FILTER2,...]
"""

import argparse
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Dict, List, Set


class TranslateToolkitChecker:
    """Wrapper for translate-toolkit quality checks on ARB files."""
    
    # Default filters to run
    DEFAULT_FILTERS = [
        'variables',      # Check placeholder consistency
        'brackets',       # Check bracket matching
        'urls',           # Check URL consistency
        'endwhitespace',  # Check trailing whitespace
        'startwhitespace',# Check leading whitespace
        'doublespacing',  # Check for double spaces
        'endpunc',        # Check ending punctuation
        'numbers',        # Check number consistency
        'emails',         # Check email addresses not translated
        'unchanged',      # Check for untranslated strings
        'long',           # Check for very long translations
        'short',          # Check for very short translations
    ]
    
    def __init__(self, l10n_dir: Path, verbose: bool = False):
        self.l10n_dir = l10n_dir
        self.verbose = verbose
        self.temp_dir = None
        
    def log(self, message: str):
        """Log message if verbose mode is enabled."""
        if self.verbose:
            print(message, file=sys.stderr)
    
    def check_dependencies(self) -> bool:
        """Check if required tools are available."""
        required_tools = ['json2po', 'pofilter', 'pocount']
        
        for tool in required_tools:
            if not shutil.which(tool):
                print(f"Error: {tool} not found. Install translate-toolkit:", file=sys.stderr)
                print(f"  apt-get install translate-toolkit", file=sys.stderr)
                print(f"  or pip install translate-toolkit", file=sys.stderr)
                return False
        
        return True
    
    def convert_arb_to_po(self, en_arb: Path, target_arb: Path, output_po: Path) -> bool:
        """Convert ARB files to PO format for translate-toolkit processing."""
        try:
            # Create temp JSON files (translate-toolkit needs .json extension)
            en_json = self.temp_dir / f"{en_arb.stem}.json"
            target_json = self.temp_dir / f"{target_arb.stem}.json"
            
            shutil.copy(en_arb, en_json)
            shutil.copy(target_arb, target_json)
            
            # Convert to PO
            cmd = ['json2po', '-t', str(en_json), str(target_json), str(output_po)]
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode != 0:
                self.log(f"Warning: json2po failed for {target_arb.name}: {result.stderr}")
                return False
            
            return output_po.exists()
            
        except Exception as e:
            self.log(f"Error converting {target_arb.name}: {e}")
            return False
    
    def run_pofilter(self, po_file: Path, filter_name: str) -> tuple[bool, int, Path]:
        """Run a specific pofilter check."""
        output_file = self.temp_dir / f"{po_file.stem}_{filter_name}.po"
        
        try:
            cmd = ['pofilter', '-t', filter_name, str(po_file), str(output_file)]
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode != 0:
                self.log(f"Warning: pofilter -{filter_name} had issues: {result.stderr}")
            
            # Count issues
            if output_file.exists():
                with open(output_file, 'r') as f:
                    content = f.read()
                    # Count msgid entries (each represents an issue)
                    issue_count = content.count('\nmsgid ') - 1  # -1 for header
                    return True, issue_count, output_file
            
            return True, 0, None
            
        except Exception as e:
            self.log(f"Error running pofilter {filter_name}: {e}")
            return False, 0, None
    
    def get_po_statistics(self, po_file: Path) -> Dict:
        """Get translation statistics using pocount."""
        try:
            cmd = ['pocount', '--short', str(po_file)]
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                # Parse output
                stats = {}
                for line in result.stdout.strip().split('\n'):
                    if ':' in line:
                        key, value = line.split(':', 1)
                        stats[key.strip()] = value.strip()
                return stats
            
        except Exception as e:
            self.log(f"Error running pocount: {e}")
        
        return {}
    
    def check_all_translations(self, filters: List[str]) -> Dict:
        """Check all translation files with specified filters."""
        en_file = self.l10n_dir / 'app_en.arb'
        if not en_file.exists():
            print(f"Error: English source file not found: {en_file}", file=sys.stderr)
            return {}
        
        results = {}
        arb_files = sorted(f for f in self.l10n_dir.glob('app_*.arb') 
                          if f.name != 'app_en.arb')
        
        self.log(f"Checking {len(arb_files)} translation files...")
        
        for arb_file in arb_files:
            locale = arb_file.stem.replace('app_', '')
            self.log(f"Processing {locale}...")
            
            # Convert to PO
            po_file = self.temp_dir / f"{locale}.po"
            if not self.convert_arb_to_po(en_file, arb_file, po_file):
                continue
            
            # Get statistics
            stats = self.get_po_statistics(po_file)
            
            # Run filters
            filter_results = {}
            for filter_name in filters:
                success, count, output = self.run_pofilter(po_file, filter_name)
                if success and count > 0:
                    filter_results[filter_name] = {
                        'count': count,
                        'output_file': output
                    }
            
            if stats or filter_results:
                results[locale] = {
                    'file': arb_file.name,
                    'statistics': stats,
                    'issues': filter_results
                }
        
        return results
    
    def format_report(self, results: Dict) -> str:
        """Format results as markdown report."""
        lines = []
        lines.append("## 🛠️ Translate-Toolkit Quality Report")
        lines.append("")
        lines.append("Using translate-toolkit pofilter to check translation quality.")
        lines.append("")
        
        if not results:
            lines.append("### ✅ No Issues Found")
            lines.append("")
            lines.append("All translations passed translate-toolkit quality checks!")
            return "\n".join(lines)
        
        # Summary
        total_files = len(results)
        total_issues = sum(
            sum(f['count'] for f in r['issues'].values())
            for r in results.values()
        )
        
        lines.append(f"**Files checked**: {total_files}")
        lines.append(f"**Total issues found**: {total_issues}")
        lines.append("")
        
        # Issues by type
        issues_by_type = {}
        for locale, data in results.items():
            for filter_name, filter_data in data['issues'].items():
                if filter_name not in issues_by_type:
                    issues_by_type[filter_name] = []
                issues_by_type[filter_name].append({
                    'locale': locale,
                    'file': data['file'],
                    'count': filter_data['count']
                })
        
        if issues_by_type:
            lines.append("### Issues by Type")
            lines.append("")
            
            filter_descriptions = {
                'variables': '**Placeholder/Variable Issues** - `{variable}` placeholders don\'t match',
                'brackets': '**Bracket Mismatch** - Number of brackets differs',
                'urls': '**URL Issues** - URLs may be incorrectly translated',
                'endwhitespace': '**Trailing Whitespace** - Extra spaces at end',
                'startwhitespace': '**Leading Whitespace** - Extra spaces at start',
                'doublespacing': '**Double Spacing** - Multiple consecutive spaces',
                'endpunc': '**Ending Punctuation** - Punctuation doesn\'t match',
                'numbers': '**Number Inconsistency** - Numbers may be incorrectly translated',
                'emails': '**Email Translation** - Email addresses should not be translated',
                'unchanged': '**Untranslated** - String is identical to English',
                'long': '**Too Long** - Translation is much longer than source',
                'short': '**Too Short** - Translation is much shorter than source',
            }
            
            for filter_name, locales in sorted(issues_by_type.items()):
                desc = filter_descriptions.get(filter_name, f'**{filter_name}**')
                total = sum(l['count'] for l in locales)
                lines.append(f"#### {desc}")
                lines.append(f"Found {total} issue(s) in {len(locales)} file(s):")
                lines.append("")
                
                for item in sorted(locales, key=lambda x: x['count'], reverse=True)[:10]:
                    lines.append(f"  - `{item['file']}`: {item['count']} issue(s)")
                
                if len(locales) > 10:
                    lines.append(f"  - ... and {len(locales) - 10} more file(s)")
                
                lines.append("")
        
        # Top problematic files
        files_by_issue_count = [
            (locale, data['file'], sum(f['count'] for f in data['issues'].values()))
            for locale, data in results.items()
            if data['issues']
        ]
        files_by_issue_count.sort(key=lambda x: x[2], reverse=True)
        
        if files_by_issue_count:
            lines.append("### Files with Most Issues")
            lines.append("")
            for locale, filename, count in files_by_issue_count[:15]:
                lines.append(f"  - `{filename}`: {count} issue(s)")
            lines.append("")
        
        lines.append("---")
        lines.append("")
        lines.append("**Tool**: translate-toolkit (pofilter)")
        lines.append("")
        lines.append("*These checks help identify potential translation issues. Some flagged items may be acceptable based on language requirements.*")
        
        return "\n".join(lines)
    
    def run(self, filters: List[str] = None) -> str:
        """Run all checks and return formatted report."""
        if not self.check_dependencies():
            return "Error: Missing required dependencies"
        
        if filters is None:
            filters = self.DEFAULT_FILTERS
        
        # Create temporary directory
        self.temp_dir = Path(tempfile.mkdtemp(prefix='arb_po_check_'))
        self.log(f"Using temporary directory: {self.temp_dir}")
        
        try:
            results = self.check_all_translations(filters)
            report = self.format_report(results)
            return report
        finally:
            # Cleanup
            if self.temp_dir and self.temp_dir.exists():
                shutil.rmtree(self.temp_dir)
                self.log("Cleaned up temporary files")


def main():
    """Main function."""
    parser = argparse.ArgumentParser(
        description='Check ARB translation quality using translate-toolkit'
    )
    parser.add_argument('--verbose', action='store_true',
                       help='Enable verbose output')
    parser.add_argument('--filters', type=str,
                       help='Comma-separated list of filters to run (default: all)')
    parser.add_argument('--list-filters', action='store_true',
                       help='List available filters and exit')
    
    args = parser.parse_args()
    
    if args.list_filters:
        print("Available translate-toolkit filters:")
        print("  variables, brackets, urls, endwhitespace, startwhitespace,")
        print("  doublespacing, endpunc, numbers, emails, unchanged, long, short")
        print("\nFor full list, run: pofilter --list")
        sys.exit(0)
    
    # Find l10n directory
    repo_root = Path(__file__).parent.parent.parent
    l10n_dir = repo_root / 'packages' / 'smooth_app' / 'lib' / 'l10n'
    
    if not l10n_dir.exists():
        print(f"Error: l10n directory not found at {l10n_dir}", file=sys.stderr)
        sys.exit(1)
    
    # Parse filters
    filters = None
    if args.filters:
        filters = [f.strip() for f in args.filters.split(',')]
    
    # Run checks
    checker = TranslateToolkitChecker(l10n_dir, verbose=args.verbose)
    report = checker.run(filters=filters)
    
    print(report)
    sys.exit(0)


if __name__ == '__main__':
    main()
