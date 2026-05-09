#!/usr/bin/env python3
"""Checks placeholder signature consistency across localization ARB files.

Emits GitHub Actions annotations that point directly to the failing ARB files.
"""

from __future__ import annotations

import json
from collections import Counter, defaultdict
from pathlib import Path
from typing import Dict, List, Tuple


REPO_ROOT = Path(__file__).resolve().parents[2]
L10N_DIR = REPO_ROOT / "packages" / "smooth_app" / "lib" / "l10n"
ARB_GLOB = "app_*.arb"

METHODS_TO_CHECK: List[str] = [
    "pct_match",
    "sign_up_page_username_length_invalid",
    "contact_form_body_android",
    "contact_form_body_ios",
    "contact_form_body",
    "knowledge_panel_text_source",
    "user_profile_title_id_email",
    "user_profile_title_id_default",
    "email_body_account_deletion",
    "permission_photo_denied_message",
    "category_picker_no_category_found_message",
    "dev_preferences_test_environment_subtitle",
    "dev_preferences_migration_subtitle",
    "product_search_no_more_results",
    "product_search_button_download_more",
    "knowledge_panel_page_loading_error",
    "preferences_page_loading_error",
    "barcode_barcode",
    "importance_label",
    "user_list_length",
    "share_product_text",
]


def _escape_annotation(text: str) -> str:
    return text.replace("%", "%25").replace("\r", "%0D").replace("\n", "%0A")


def _emit_error(file_path: Path, title: str, message: str) -> None:
    rel = file_path.relative_to(REPO_ROOT).as_posix()
    print(
        f"::error file={rel},title={_escape_annotation(title)}::"
        f"{_escape_annotation(message)}"
    )


def _load_arb(file_path: Path) -> Dict:
    with file_path.open(encoding="utf-8") as handle:
        return json.load(handle)


def _locale_from_arb(file_path: Path) -> str:
    # app_en.arb -> en
    return file_path.stem.removeprefix("app_")


def _placeholder_signature(arb_data: Dict, method: str) -> Tuple[str, ...] | None:
    metadata_key = f"@{method}"
    metadata = arb_data.get(metadata_key)
    if not isinstance(metadata, dict):
        return None
    placeholders = metadata.get("placeholders")
    if not isinstance(placeholders, dict):
        return tuple()
    return tuple(sorted(placeholders.keys()))


def main() -> int:
    arb_files = sorted(L10N_DIR.glob(ARB_GLOB))
    if not arb_files:
        print(f"No ARB files found in {L10N_DIR}")
        return 1

    locale_to_data: Dict[str, Dict] = {}
    locale_to_file: Dict[str, Path] = {}
    for arb_file in arb_files:
        locale = _locale_from_arb(arb_file)
        locale_to_data[locale] = _load_arb(arb_file)
        locale_to_file[locale] = arb_file

    errors = 0
    for method in METHODS_TO_CHECK:
        signature_to_locales: Dict[Tuple[str, ...] | None, List[str]] = defaultdict(list)
        for locale, data in locale_to_data.items():
            signature_to_locales[_placeholder_signature(data, method)].append(locale)

        if len(signature_to_locales) <= 1:
            continue

        # Prefer English as canonical when available and defined.
        expected_signature = _placeholder_signature(locale_to_data.get("en", {}), method)
        if expected_signature is None:
            expected_signature = Counter(
                {
                    signature: len(locales)
                    for signature, locales in signature_to_locales.items()
                }
            ).most_common(1)[0][0]

        expected_display = "missing metadata/placeholders"
        if expected_signature is not None:
            expected_display = ", ".join(expected_signature) if expected_signature else "none"

        for signature, locales in signature_to_locales.items():
            if signature == expected_signature:
                continue

            found_display = "missing metadata/placeholders"
            if signature is not None:
                found_display = ", ".join(signature) if signature else "none"

            for locale in sorted(locales):
                errors += 1
                file_path = locale_to_file[locale]
                _emit_error(
                    file_path=file_path,
                    title=f"Localization placeholder mismatch: {method}",
                    message=(
                        f'Expected placeholders [{expected_display}] but found '
                        f'[{found_display}] for key "{method}" in locale "{locale}".'
                    ),
                )

        print(
            f'Found inconsistent placeholders for "{method}". '
            f'Expected: [{expected_display}]'
        )

    if errors:
        print(f"\nFound {errors} localization signature issue(s).")
        return 1

    print("All checked localization signatures are consistent.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
