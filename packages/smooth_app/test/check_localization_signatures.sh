#!/bin/bash
# Simple bash script to check for inconsistent method signatures in generated localization files
# This helps identify which ARB file has incorrect placeholder definitions.

set -e

echo "Checking localization method signatures..."
echo ""

# Methods to check
METHODS=(
    "pct_match"
    "sign_up_page_username_length_invalid"
    "contact_form_body_android"
    "contact_form_body_ios"
    "contact_form_body"
    "knowledge_panel_text_source"
    "user_profile_title_id_email"
    "user_profile_title_id_default"
    "email_body_account_deletion"
    "permission_photo_denied_message"
    "category_picker_no_category_found_message"
    "dev_preferences_test_environment_subtitle"
    "dev_preferences_migration_subtitle"
    "product_search_no_more_results"
    "product_search_button_download_more"
    "knowledge_panel_page_loading_error"
    "preferences_page_loading_error"
    "barcode_barcode"
    "importance_label"
    "user_list_length"
    "share_product_text"
)

cd "$(dirname "$0")/.."

FOUND_ISSUES=0

for METHOD in "${METHODS[@]}"; do
    echo "Checking method: $METHOD"
    
    # Find all method signatures
    SIGNATURES=$(grep -h "String $METHOD(" lib/l10n/app_localizations_*.dart 2>/dev/null || echo "")
    
    if [ -z "$SIGNATURES" ]; then
        echo "  ⚠️  Method not found in any localization file"
        FOUND_ISSUES=1
        continue
    fi
    
    # Count unique signatures
    UNIQUE_SIGS=$(echo "$SIGNATURES" | sort -u)
    SIG_COUNT=$(echo "$UNIQUE_SIGS" | wc -l)
    
    if [ "$SIG_COUNT" -gt 1 ]; then
        echo "  ❌ ERROR: Method has inconsistent signatures:"
        echo "$UNIQUE_SIGS" | while read -r SIG; do
            echo "    $SIG"
            # Find which files have this signature
            FILES=$(grep -l "$SIG" lib/l10n/app_localizations_*.dart | sed 's/.*app_localizations_//' | sed 's/\.dart$//' | tr '\n' ', ')
            echo "      Used by locales: $FILES"
            echo "      Check ARB files: $(echo "$FILES" | sed 's/,/, app_/g' | sed 's/^/app_/' | sed 's/, $//')arb"
        done
        FOUND_ISSUES=1
    else
        echo "  ✓ Consistent across all locales"
    fi
    echo ""
done

echo ""
if [ "$FOUND_ISSUES" -eq 1 ]; then
    echo "❌ Found inconsistencies in localization files."
    echo "   Check the ARB files listed above for incorrect placeholder definitions."
    exit 1
else
    echo "✅ All checked methods have consistent signatures across all locales."
    exit 0
fi
