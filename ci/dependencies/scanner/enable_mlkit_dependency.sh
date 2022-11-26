#!/bin/bash
set -e

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

SEDOPTION=
if [[ "$OSTYPE" == "darwin"* ]]; then
  SEDOPTION="-i ''"
fi

sed $SEDOPTION 's|^  #scanner_mlkit|  scanner_mlkit|g' packages/app/pubspec.yaml
sed $SEDOPTION 's|^    #path: ../scanner/mlkit|    path: ../scanner/mlkit|g' packages/app/pubspec.yaml
sed $SEDOPTION 's|^  scanner_zxing|  #scanner_zxing|g' packages/app/pubspec.yaml
sed $SEDOPTION 's|^    path: ../scanner/zxing|    #path: ../scanner/zxing|g' packages/app/pubspec.yaml