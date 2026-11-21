#!/bin/bash
set -e

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

SEDOPTION=-i
if [[ "$OSTYPE" == "darwin"* ]]; then
  SEDOPTION="-i ''"
fi

sed $SEDOPTION 's|^  scanner_ml_kit|  #scanner_ml_kit|g' packages/smooth_app/pubspec.yaml
sed $SEDOPTION 's|^    path: ../scanner/ml_kit|    #path: ../scanner/ml_kit|g' packages/smooth_app/pubspec.yaml
sed $SEDOPTION 's|^  #scanner_zxing|  scanner_zxing|g' packages/smooth_app/pubspec.yaml
sed $SEDOPTION 's|^    #path: ../scanner/zxing|    path: ../scanner/zxing|g' packages/smooth_app/pubspec.yaml