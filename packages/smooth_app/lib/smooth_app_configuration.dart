import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class SmoothAppConfiguration {
  const SmoothAppConfiguration({
    this.fromPackage = false,
    this.appBuilder,
    this.screenshots = false,
  });

  /// Is the app launched from an external package or directly?
  final bool fromPackage;

  /// Custom builder to inject Widgets on top of the app (eg: DevicePreview)
  final WidgetBuilder? appBuilder;
  final bool screenshots;

  String? get package {
    if (fromPackage) {
      return 'packages/smooth_app';
    } else {
      return null;
    }
  }

  String getAsset(String assetName) {
    assert(assetName.isNotEmpty);

    if (assetName.startsWith('/')) {
      assetName = assetName.substring(1);
    }

    if (package == null) {
      return assetName;
    } else {
      return '$package/$assetName';
    }
  }

  static SmoothAppConfiguration of(BuildContext context) {
    try {
      return Provider.of<SmoothAppConfiguration>(context, listen: false);
    } on ProviderNotFoundException {
      // If run from tests
      return const SmoothAppConfiguration();
    }
  }
}
