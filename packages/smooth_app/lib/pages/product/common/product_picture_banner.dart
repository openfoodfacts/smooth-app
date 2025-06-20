import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/image/product_image_helper.dart';
import 'package:smooth_app/pages/product/gallery_view/product_image_gallery_view.dart';
import 'package:smooth_app/pages/product/owner_field_info.dart';
import 'package:smooth_app/pages/product/product_image_server_button.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

Future<File?> showPhotoBanner({
  required final BuildContext context,
  required final Product product,
  required final ImageField imageField,
  required final OpenFoodFactsLanguage language,
  final TransientFile? transientFile,
}) async {
  final PhotoRowActions? action = await _showPhotoBanner(
    context: context,
    product: product,
    imageField: imageField,
    language: language,
    transientFile: transientFile,
  );

  if (!context.mounted || action == null) {
    return null;
  }

  return switch (action) {
    PhotoRowActions.takePicture => _takePicture(
        context: context,
        product: product,
        imageField: imageField,
        language: language,
        pictureSource: UserPictureSource.CAMERA,
      ),
    PhotoRowActions.selectFromGallery => _takePicture(
        context: context,
        product: product,
        imageField: imageField,
        language: language,
        pictureSource: UserPictureSource.GALLERY,
      ),
    PhotoRowActions.selectFromProductPhotos => _selectPictureFromProductGallery(
        context: context,
        product: product,
        imageField: imageField,
        language: language,
      ),
  };
}

Future<File?> _takePicture({
  required final BuildContext context,
  required final Product product,
  required final ImageField imageField,
  required final OpenFoodFactsLanguage language,
  required final UserPictureSource pictureSource,
}) async {
  return ProductImageGalleryView.takePicture(
    context: context,
    product: product,
    language: language,
    imageField: imageField,
    pictureSource: pictureSource,
  );
}

Future<File?> _selectPictureFromProductGallery({
  required final BuildContext context,
  required final Product product,
  required final ImageField imageField,
  required final OpenFoodFactsLanguage language,
}) async {
  final CropParameters? parameters =
      await ProductImageServerButton.selectImageFromGallery(
    context: context,
    product: product,
    imageField: imageField,
    language: language,
    isLoggedInMandatory: true,
  );

  return parameters?.smallCroppedFile;
}

Future<PhotoRowActions?> _showPhotoBanner({
  required final BuildContext context,
  required final Product product,
  required final ImageField imageField,
  required final OpenFoodFactsLanguage language,
  required TransientFile? transientFile,
}) async {
  final SmoothColorsThemeExtension extension =
      context.extension<SmoothColorsThemeExtension>();
  final bool lightTheme = context.lightTheme(listen: false);
  final bool imageAvailable = transientFile?.isImageAvailable() ?? false;

  final AppLocalizations appLocalizations = AppLocalizations.of(context);

  final PhotoRowActions? action =
      await showSmoothListOfChoicesModalSheet<PhotoRowActions>(
    context: context,
    title: imageAvailable
        ? appLocalizations.product_image_action_replace_photo(
            imageField.getProductImageTitle(appLocalizations))
        : appLocalizations.product_image_action_add_photo(
            imageField.getProductImageTitle(appLocalizations)),
    values: PhotoRowActions.values,
    labels: <String>[
      if (imageAvailable)
        appLocalizations.product_image_action_take_new_picture
      else
        appLocalizations.product_image_action_take_picture,
      appLocalizations.product_image_action_from_gallery,
      appLocalizations.product_image_action_choose_existing_photo,
    ],
    prefixIconTint:
        lightTheme ? extension.primaryDark : extension.primaryMedium,
    prefixIcons: <Widget>[
      const Icon(Icons.camera),
      const Icon(Icons.perm_media_rounded),
      const Icon(Icons.image_search_rounded),
    ],
    contentPadding: const EdgeInsetsDirectional.symmetric(
      horizontal: LARGE_SPACE,
    ),
    addEndArrowToItems: true,
    footerBackgroundColor: lightTheme ? extension.primaryLight : null,
    footerSpace: VERY_SMALL_SPACE,
    footer: transientFile?.isImageAvailable() == true
        ? _PhotoRowBanner(
            product: product,
            imageField: imageField,
            language: language,
            transientFile: transientFile!,
          )
        : null,
  );

  return action;
}

enum PhotoRowActions {
  takePicture,
  selectFromGallery,
  selectFromProductPhotos,
}

class _PhotoRowBanner extends StatefulWidget {
  const _PhotoRowBanner({
    required this.product,
    required this.imageField,
    required this.language,
    required this.transientFile,
  });

  final Product product;
  final ImageField imageField;
  final OpenFoodFactsLanguage language;
  final TransientFile transientFile;

  @override
  State<_PhotoRowBanner> createState() => _PhotoRowBannerState();
}

class _PhotoRowBannerState extends State<_PhotoRowBanner> {
  late bool _expanded;
  late final bool _dateInitiallyVisible;
  late final bool _contributorInitiallyVisible;

  @override
  void initState() {
    super.initState();

    _dateInitiallyVisible = _PhotoRowDate.isVisible(widget.transientFile);
    _contributorInitiallyVisible = _PhotoRowContributor.isVisible(
      widget.product,
      widget.imageField,
      widget.language,
    );
    _expanded = _dateInitiallyVisible && _contributorInitiallyVisible;
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return ListTileTheme.merge(
      titleTextStyle: TextStyle(
        inherit: true,
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: lightTheme ? Colors.black : Colors.white,
        fontFamily: 'OpenSans',
      ),
      leadingAndTrailingTextStyle: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: lightTheme ? Colors.black : Colors.white,
        fontFamily: 'OpenSans',
      ),
      contentPadding: const EdgeInsetsDirectional.only(
        start: BALANCED_SPACE,
        end: LARGE_SPACE,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: !_expanded
                  ? () => setState(() => _expanded = !_expanded)
                  : null,
              child: Ink(
                width: double.infinity,
                color: extension.primaryDark,
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: MEDIUM_SPACE,
                  vertical: MEDIUM_SPACE,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)
                            .product_image_details_label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!_expanded)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          end: 9.0,
                        ),
                        child: Semantics(
                          value: MaterialLocalizations.of(context)
                              .expandedIconTapHint,
                          excludeSemantics: true,
                          child: const icons.Chevron.down(
                            size: 18.0,
                            color: Colors.white,
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
          if (_expanded || _dateInitiallyVisible)
            _PhotoRowDate(
              transientFile: widget.transientFile,
            ),
          if (_expanded) const Divider(color: Colors.white),
          if (_expanded || _contributorInitiallyVisible)
            _PhotoRowContributor(
              product: widget.product,
              imageField: widget.imageField,
              language: widget.language,
            ),
        ],
      ),
    );
  }
}

class _PhotoRowContributor extends StatelessWidget {
  const _PhotoRowContributor({
    required this.product,
    required this.imageField,
    required this.language,
  });

  final Product product;
  final ImageField imageField;
  final OpenFoodFactsLanguage language;

  static bool isVisible(Product product, ImageField imageField,
          OpenFoodFactsLanguage language) =>
      product.isImageLocked(imageField, language) == true;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    final bool isLocked = isVisible(product, imageField, language);
    final String? contributor = _contributor;

    final String title;
    final String value;
    final Widget icon;
    final EdgeInsetsGeometry padding;

    if (contributor?.isNotEmpty == true) {
      title = isLocked
          ? appLocalizations.product_image_details_contributor_producer
          : appLocalizations.product_image_details_contributor;
      value = contributor!;
    } else {
      title = appLocalizations.product_image_details_from_producer;
      value = isLocked ? appLocalizations.yes : appLocalizations.no;
    }

    if (isLocked) {
      icon = const OwnerFieldIcon(size: 19.0);
      padding = const EdgeInsetsDirectional.only(bottom: 1.0, end: 1.0);
    } else {
      icon = const Icon(Icons.person);
      padding = EdgeInsets.zero;
    }

    return ListTile(
      leading: _PhotoRowDetailsIcon(
        color: extension.primaryDark,
        icon: icon,
        padding: padding,
      ),
      title: Text(title),
      trailing: Text(value),
    );
  }

  String? get _contributor {
    if (product.images == null) {
      return null;
    }

    for (final ProductImage productImage in product.images!) {
      if (productImage.field == imageField &&
          productImage.language == language) {
        if (productImage.contributor != null) {
          /// Always null in my tests
          return productImage.contributor;
        }

        /// Let's try to find by the image id
        return product.images!.firstWhereOrNull((ProductImage img) {
          return productImage.imgid == img.imgid;
        })?.contributor;
      }
    }

    return null;
  }
}

/// The date of the photo (used in the modal sheet)
class _PhotoRowDate extends StatelessWidget {
  const _PhotoRowDate({
    required this.transientFile,
  });

  final TransientFile transientFile;

  static bool isVisible(TransientFile transientFile) => transientFile.expired;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    final bool outdated = isVisible(transientFile);

    return ListTile(
      leading: _PhotoRowDetailsIcon(
        color: outdated ? extension.warning : extension.primaryDark,
        icon: outdated ? _outdatedIcon : _successIcon,
        padding: outdated
            ? const EdgeInsetsDirectional.only(
                top: 0.5,
                end: 1.0,
              )
            : null,
      ),
      title: Text(appLocalizations.date),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            transientFile.uploadedDate != null
                ? DateFormat.yMd().format(transientFile.uploadedDate!)
                : appLocalizations.product_image_details_date_unknown,
          ),
          if (outdated)
            Text(
              '(${appLocalizations.outdated_image_short_label})',
              style: const TextStyle(fontSize: 15.0),
            ),
        ],
      ),
    );
  }

  Widget get _outdatedIcon => const Padding(
        padding: EdgeInsetsDirectional.only(
          bottom: 1.5,
          start: 1.5,
        ),
        child: icons.Outdated(size: 19.0),
      );

  Widget get _successIcon => const Padding(
        padding: EdgeInsetsDirectional.only(bottom: 0.5),
        child: icons.Clock(size: 19.0),
      );
}

class _PhotoRowDetailsIcon extends StatelessWidget {
  const _PhotoRowDetailsIcon({
    required this.icon,
    required this.color,
    this.padding,
  });

  final Widget icon;
  final Color color;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: 35.0,
        child: Padding(
          padding: padding ?? const EdgeInsetsDirectional.all(SMALL_SPACE),
          child: IconTheme.merge(
            data: const IconThemeData(color: Colors.white),
            child: icon,
          ),
        ),
      ),
    );
  }
}
