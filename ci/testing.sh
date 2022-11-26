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

  # Ignore scanner/ folder and navigate instead to the sub-folders
  for file in "$REPO_DIR/packages/"*; do
    if [[ "$file" == *app_store || "$file" == *scanner ]]; then
      for file in "$file/"*; do
        if [[ -d $file ]]; then
          (cd "$file" && flutter test --coverage)
        fi
      done
    elif [[ -d $file ]]; then
      (cd "$file" && flutter test --coverage)
    fi
  done
fi
