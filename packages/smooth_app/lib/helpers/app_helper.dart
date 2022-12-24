class AppHelper {
  const AppHelper._();

  //static const String APP_PACKAGE = 'smooth_app';
  static const String? APP_PACKAGE = null;

  static String getAssetPath(String asset) {
    if (asset.startsWith('/')) {
      asset = asset.substring(1);
    } else if (asset.startsWith('packages/')) {
      return asset;
    }

    assert(asset.isNotEmpty);
    return asset;
  }

  static String get defaultAssetPath => getAssetPath('assets/');
}
