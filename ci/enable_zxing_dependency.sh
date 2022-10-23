#!/bin/bash
set -e

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

sed -i '' 's|^  scanner_mlkit|  #scanner_mlkit|g' packages/app/pubspec.yaml
sed -i '' 's|^    path: ../scanner/mlkit|    #path: ../scanner/mlkit|g' packages/app/pubspec.yaml
sed -i '' 's|^  #scanner_zxing|  scanner_zxing|g' packages/app/pubspec.yaml
sed -i '' 's|^    #path: ../scanner/zxing|    path: ../scanner/zxing|g' packages/app/pubspec.yaml