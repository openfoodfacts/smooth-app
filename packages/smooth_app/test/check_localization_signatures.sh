#!/bin/bash
# Wrapper around the shared localization signature checker.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
python3 "$REPO_ROOT/.github/scripts/localization_signature_check.py"
