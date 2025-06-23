import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/svg_icon_chip.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_animations.dart';

/// Tracks (only the first time) when a [check] is true.
class AnalyticsProductTracker {
  AnalyticsProductTracker({
    required this.analyticsEvent,
    required this.barcode,
    required this.check,
  });

  final AnalyticsEvent analyticsEvent;
  final String barcode;
  final bool Function() check;

  bool _already = false;

  void track() {
    if (_already) {
      return;
    }
    if (!check()) {
      return;
    }
    _already = true;
    AnalyticsHelper.trackEvent(analyticsEvent, barcode: barcode);
  }
}

/// Card title for "Add new product" page.
class AddNewProductTitle extends StatelessWidget {
  const AddNewProductTitle(this.label, {this.maxLines});

  final String label;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: Theme.of(context).textTheme.displaySmall?.copyWith(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
    ),
    maxLines: maxLines,
  );
}

/// Card subtitle for "Add new product" page.
class AddNewProductSubTitle extends StatelessWidget {
  const AddNewProductSubTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(label);
}

/// Standard button in the "Add new product" page.
class AddNewProductButton extends StatelessWidget {
  const AddNewProductButton(
    this.label,
    this.iconData,
    this.onPressed, {
    required this.done,
    this.showTrailing = true,
  });

  final String label;
  final IconData iconData;
  final VoidCallback? onPressed;
  final bool done;
  final bool showTrailing;

  static const IconData doneIconData = Icons.check;
  static const IconData todoIconData = Icons.add;
  static IconData cameraIconData = Icons.add_a_photo_outlined;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final bool dark = themeData.brightness == Brightness.dark;
    final Color? darkGrey = Colors.grey[700];
    final Color? lightGrey = Colors.grey[300];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: SmoothLargeButtonWithIcon(
        text: label,
        leadingIcon: Icon(iconData),
        onPressed: onPressed,
        trailingIcon: showTrailing ? const Icon(Icons.edit) : null,
        backgroundColor: onPressed == null
            ? (dark ? darkGrey : lightGrey)
            : done
            ? Colors.green[700]
            : themeData.colorScheme.secondary,
        foregroundColor: onPressed == null
            ? (dark ? lightGrey : darkGrey)
            : done
            ? Colors.white
            : themeData.colorScheme.onSecondary,
      ),
    );
  }
}

/// Standard "editor" button in the "Add new product" page.
class AddNewProductEditorButton extends StatelessWidget {
  const AddNewProductEditorButton(
    this.product,
    this.editor, {
    this.forceIconData,
    this.disabled = false,
    required this.isLoggedInMandatory,
  });

  final Product product;
  final ProductFieldEditor editor;
  final IconData? forceIconData;
  final bool disabled;
  final bool isLoggedInMandatory;

  @override
  Widget build(BuildContext context) {
    final bool done = editor.isPopulated(product);
    return AddNewProductButton(
      editor.getLabel(AppLocalizations.of(context)),
      forceIconData ??
          (done
              ? AddNewProductButton.doneIconData
              : AddNewProductButton.todoIconData),
      disabled
          ? null
          : () async => editor.edit(
              context: context,
              product: product,
              isLoggedInMandatory: isLoggedInMandatory,
            ),
      done: done,
    );
  }
}

class AddNewProductScoreIcon extends StatelessWidget {
  const AddNewProductScoreIcon({
    required this.iconUrl,
    required this.defaultIconUrl,
  });

  final String? iconUrl;
  final String defaultIconUrl;

  @override
  Widget build(BuildContext context) {
    final String url = iconUrl ?? defaultIconUrl;
    final String fileName = Uri.parse(url).pathSegments.last;
    final double height = MediaQuery.sizeOf(context).height * .2;

    if (fileName.startsWith('nutriscore')) {
      return _AddNewProductNutriScoreIcon(fileName: fileName, height: height);
    } else {
      return SvgIconChip(iconUrl ?? defaultIconUrl, height: height);
    }
  }
}

class _AddNewProductNutriScoreIcon extends StatelessWidget {
  _AddNewProductNutriScoreIcon({required String fileName, required this.height})
    : nutriScore = extractValue(fileName);

  final NutriScoreValue nutriScore;
  final double height;

  static NutriScoreValue extractValue(String fileName) {
    if (fileName.startsWith('nutriscore-a')) {
      return NutriScoreValue.a;
    } else if (fileName.startsWith('nutriscore-b')) {
      return NutriScoreValue.b;
    } else if (fileName.startsWith('nutriscore-c')) {
      return NutriScoreValue.c;
    } else if (fileName.startsWith('nutriscore-d')) {
      return NutriScoreValue.d;
    } else if (fileName.startsWith('nutriscore-e')) {
      return NutriScoreValue.e;
    } else {
      return NutriScoreValue.unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NutriScoreAnimation(
      value: nutriScore,
      size: Size.fromHeight(math.min(height, 200.0)),
    );
  }
}

/// Helper for the "Add new product" page.
class AddNewProductHelper {
  bool isMainImagePopulated(
    final ProductImageData productImageData,
    final Product product,
  ) =>
      getProductImageLanguages(product, productImageData.imageField).isNotEmpty;

  bool isOneMainImagePopulated(final Product product) {
    final List<ProductImageData> productImagesData = getProductMainImagesData(
      product,
      // TODO(monsieurtanuki): check somehow with all languages
      ProductQuery.getLanguage(),
    );
    for (final ProductImageData productImageData in productImagesData) {
      if (isMainImagePopulated(productImageData, product)) {
        return true;
      }
    }
    return false;
  }
}

/// Possible actions on that page.
enum EditProductAction {
  openPage,
  leaveEmpty,
  ingredients,
  category,
  nutritionFacts,
}
