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
sed $SEDOPTION 's|^  scanner_zxing|  #scanner_zxing|g' packages/smooth_app/pubspec.yaml
sed $SEDOPTION 's|^    path: ../scanner/zxing|    #path: ../scanner/zxing|g' packages/smooth_app/pubspec.yaml
sed $SEDOPTION 's|^  #scanner_tapirscan|  scanner_tapirscan|g' packages/smooth_app/pubspec.yaml
sed $SEDOPTION 's|^    #path: ../scanner/tapirscan|    path: ../scanner/tapirscan|g' packages/smooth_app/pubspec.yaml

# The entrypoint is written here rather than committed: with the default
# dependencies, its import would fail `flutter analyze`.
cat > packages/smooth_app/lib/entrypoints/android/main_tapirscan.dart <<'EOF'
import 'package:app_store_uri/app_store_uri.dart';
import 'package:scanner_tapirscan/scanner_tapirscan.dart';
import 'package:smooth_app/helpers/entry_points_helper.dart';
import 'package:smooth_app/main.dart';

/// Android build with the Tapirscan scanner, without Google code in the
/// scanner, like the F-Droid build.
void main() {
  launchSmoothApp(
    barcodeScanner: const ScannerTapirscan(),
    appStore: URIAppStore(
      Uri.parse(
        'https://f-droid.org/fr/packages/openfoodfacts.github.scrachx.openfood/',
      ),
    ),
    scannerLabel: ScannerLabel.Tapirscan,
    storeLabel: StoreLabel.FDroid,
  );
}
EOF
