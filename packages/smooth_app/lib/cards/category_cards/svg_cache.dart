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

    final String fileName = Uri.parse(iconUrl).pathSegments.last;
    return switch (fileName) {
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
      String _ when fileName.startsWith('nutriscore-') =>
        _extractNutriScore(localizations, fileName),
      _ => null,
    };
  }

  static String _extractNutriScore(
    AppLocalizations localizations,
    String fileName,
  ) {
    // Old NutriScore
    if (fileName == 'nutriscore-a.svg') {
      return localizations.nutriscore_a;
    } else if (fileName == 'nutriscore-b.svg') {
      return localizations.nutriscore_b;
    } else if (fileName == 'nutriscore-c.svg') {
      return localizations.nutriscore_c;
    } else if (fileName == 'nutriscore-d.svg') {
      return localizations.nutriscore_d;
    } else if (fileName == 'nutriscore-e.svg') {
      return localizations.nutriscore_e;
    } else if (fileName == 'nutriscore-unknown.svg') {
      return localizations.nutriscore_unknown;
    } else if (fileName == 'nutriscore-not-applicable.svg') {
      return localizations.nutriscore_not_applicable;
    }

    // NutriScore V2
    if (fileName == 'nutriscore-unknown-') {
      return localizations.nutriscore_unknown_new_formula;
    } else if (fileName == 'nutriscore-not-applicable-') {
      return localizations.nutriscore_not_applicable_new_formula;
    } else {
      final String? letter;

      if (fileName.startsWith('nutriscore-a-new')) {
        letter = 'A';
      } else if (fileName.startsWith('nutriscore-b-new')) {
        letter = 'B';
      } else if (fileName.startsWith('nutriscore-c-new')) {
        letter = 'C';
      } else if (fileName.startsWith('nutriscore-d-new')) {
        letter = 'D';
      } else if (fileName.startsWith('nutriscore-e-new')) {
        letter = 'E';
      } else {
        return localizations.nutriscore_unknown;
      }

      return localizations.nutriscore_new_formula(letter);
    }
  }
}
