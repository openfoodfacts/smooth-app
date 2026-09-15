#!/bin/bash
set -e

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

if [[ -n "$CI" ]]; then
  echo "Updating PATH."
  export PATH="$FLUTTER_ROOT/bin:$FLUTTER_ROOT/bin/cache/dart-sdk/bin:$PATH"
else
  echo "Updating packages."
  "$SCRIPT_DIR/pub_upgrade.sh"
fi

# Default to the first arg if SHARD isn't set, and to "test" if neither are set.
SHARD="${SHARD:-${1:-test}}"

if [[ "$SHARD" == "test" ]]; then
  echo "Running tests."

  # Run main application tests with coverage
  echo "Testing packages/smooth_app with coverage..."
  (cd "$REPO_DIR/packages/smooth_app" && flutter test --coverage)

  # Run tests in other packages if they have real tests (not just dummy tests)
  for pkg_group in "$REPO_DIR/packages/app_store" "$REPO_DIR/packages/scanner"; do
    if [[ -d "$pkg_group" ]]; then
      for pkg in "$pkg_group/"*; do
        if [[ -d "$pkg/test" ]]; then
          # Skip packages that only contain the placeholder dummy 'Fake test'
          if grep -rq "Fake test" "$pkg/test" && [[ $(find "$pkg/test" -name "*_test.dart" | wc -l) -eq 1 ]]; then
            echo "Skipping dummy tests in $(basename "$pkg_group")/$(basename "$pkg")"
          else
            echo "Testing $(basename "$pkg_group")/$(basename "$pkg")..."
            (cd "$pkg" && flutter test)
          fi
        fi
      done
    fi
  done
fi
