class AppHelper {
  const AppHelper._();

  static const String APP_PACKAGE = 'smooth_app';

  static String getAssetPath(String asset) {
    if (asset.startsWith('/')) {
      asset = asset.substring(0);
    }

    assert(asset.isNotEmpty);
    return 'packages/$APP_PACKAGE/$asset';
  }
}
