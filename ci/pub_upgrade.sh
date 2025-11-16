#!/bin/bash
# Copyright 2020 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# A script that will run pub upgrade for each package in the repo.
# NOTE: This script updates dependencies and modifies lockfiles.
# For CI/CD workflows, use pub_get.sh instead to ensure reproducible builds.
# This script is intended for manual dependency updates by developers.
set -e

if [[ -n '$CI' ]]; then
  export PATH="$FLUTTER_ROOT/bin:$FLUTTER_ROOT/bin/cache/dart-sdk/bin:$PATH"
fi

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

function pub_upgrade() {
  local dir="$1"
  if [[ -e "$dir/pubspec.yaml" ]]; then
    echo "Running 'flutter pub upgrade' in $dir"
    (cd $dir; flutter pub upgrade)
  fi
}

for dir in $(find "$REPO_DIR" -type d -not -path "*/.dart_tool/*"); do
  pub_upgrade "$dir"
done

