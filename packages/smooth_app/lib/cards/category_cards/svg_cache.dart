import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/cards/category_cards/abstract_cache.dart';
import 'package:smooth_app/cards/category_cards/asset_cache_helper.dart';
import 'package:smooth_app/cards/category_cards/svg_safe_network.dart';

/// Widget that displays a svg from network (and cache while waiting).
class SvgCache extends AbstractCache {
  const SvgCache(
    super.iconUrl, {
    super.width,
    super.height,
    this.color,
  });

  final Color? color;

  @override
  List<String> getCachedFilenames() {
    final List<String> result = <String>[];
    final String? filename = getFilename();
    if (filename == null) {
      return result;
    }
    final String cacheFilename = getCacheFilename(filename);
    final String cacheTintableFilename = getCacheTintableFilename(filename);
    if (color == null) {
      result.add(cacheFilename);
      result.add(cacheTintableFilename);
    } else {
      result.add(cacheTintableFilename);
      result.add(cacheFilename);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> cachedFilenames = getCachedFilenames();
    if (cachedFilenames.isEmpty) {
      return getDefaultUnknown();
    }
    Color? forcedColor = color;
    // cf. https://github.com/openfoodfacts/smooth-app/issues/2268
    // For tinted icons, when there's no color it's not good, as it will always
    // be black - not good for dark mode.
    // Here we detect lazily tinted icons if the URL contains "/icons/"
    // e.g. https://static.openfoodfacts.org/images/icons/dist/nutrition.svg
    if (forcedColor == null && iconUrl!.contains('/icons/')) {
      forcedColor = Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;
    }
    final AssetCacheHelper helper = AssetCacheHelper(
      cachedFilenames,
      iconUrl!,
      width: width,
      height: height,
      color: forcedColor,
    );
    return SvgSafeNetwork(
      helper,
      key: helper.getKey(),
    );
  }

  static String? getSemanticsLabel(BuildContext context, String iconUrl) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return switch (Uri.parse(iconUrl).pathSegments.last) {
      'ecoscore-a.svg' => localizations.ecoscore_a,
      'ecoscore-b.svg' => localizations.ecoscore_b,
      'ecoscore-c.svg' => localizations.ecoscore_c,
      'ecoscore-d.svg' => localizations.ecoscore_d,
      'ecoscore-e.svg' => localizations.ecoscore_e,
      'ecoscore-unknown.svg' => localizations.ecoscore_unknown,
      'ecoscore-not-applicable.svg' => localizations.ecoscore_not_applicable,
      'nova-group-1.svg' => localizations.nova_group_1,
      'nova-group-2.svg' => localizations.nova_group_2,
      'nova-group-3.svg' => localizations.nova_group_3,
      'nova-group-4.svg' => localizations.nova_group_4,
      'nova-group-unknown.svg' => localizations.nova_group_unknown,
      'nutriscore-a.svg' => localizations.nutriscore_a,
      'nutriscore-b.svg' => localizations.nutriscore_b,
      'nutriscore-c.svg' => localizations.nutriscore_c,
      'nutriscore-d.svg' => localizations.nutriscore_d,
      'nutriscore-e.svg' => localizations.nutriscore_e,
      'nutriscore-unknown.svg' => localizations.nutriscore_unknown,
      'nutriscore-not-applicable.svg' => localizations.ecoscore_not_applicable,
      _ => null,
    };
  }
}
