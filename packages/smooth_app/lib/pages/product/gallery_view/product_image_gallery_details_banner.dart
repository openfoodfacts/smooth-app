part of 'package:smooth_app/pages/product/gallery_view/product_image_gallery_photo_row.dart';

Future<_PhotoRowActions?> _showPhotoBanner({
  required final BuildContext context,
  required final Product product,
  required final ImageField imageField,
  required final OpenFoodFactsLanguage language,
  required final TransientFile transientFile,
}) async {
  final SmoothColorsThemeExtension extension =
      context.extension<SmoothColorsThemeExtension>();
  final bool lightTheme = context.lightTheme(listen: false);
  final bool imageAvailable = transientFile.isImageAvailable();

  final AppLocalizations appLocalizations = AppLocalizations.of(context);

  final _PhotoRowActions? action =
      await showSmoothListOfChoicesModalSheet<_PhotoRowActions>(
    context: context,
    title: imageAvailable
        ? appLocalizations.product_image_action_replace_photo(
            imageField.getProductImageTitle(appLocalizations))
        : appLocalizations.product_image_action_add_photo(
            imageField.getProductImageTitle(appLocalizations)),
    values: _PhotoRowActions.values,
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
    addEndArrowToItems: true,
    footer: _PhotoRowBanner(
      children: <Widget>[
        _PhotoRowDate(transientFile: transientFile),
        _PhotoRowLockedStatus(
          product: product,
          imageField: imageField,
          language: language,
        ),
      ],
    ),
  );

  return action;
}

class _PhotoRowBanner extends StatelessWidget {
  const _PhotoRowBanner({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: MEDIUM_SPACE,
        bottom: !(Platform.isIOS || Platform.isMacOS) ? 0.0 : VERY_SMALL_SPACE,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

enum _PhotoRowActions {
  takePicture,
  selectFromGallery,
  selectFromProductPhotos,
}

/// The date of the photo (used in the modal sheet)
class _PhotoRowDate extends StatelessWidget {
  const _PhotoRowDate({
    required this.transientFile,
  });

  final TransientFile transientFile;

  @override
  Widget build(BuildContext context) {
    if (!transientFile.isImageAvailable() ||
        transientFile.uploadedDate == null) {
      return EMPTY_WIDGET;
    }

    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool outdated = transientFile.expired;

    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return _PhotoRowInfo(
      icon: outdated ? _outdatedIcon : _successIcon,
      iconBackgroundColor: outdated ? extension.warning : extension.success,
      text: Padding(
        /// Padding required by the use of [RichText]
        padding: const EdgeInsetsDirectional.only(bottom: 2.75),
        child: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: '${appLocalizations.date}${appLocalizations.sep}: ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: DateFormat.yMd(ProductQuery.getLocaleString())
                    .format(transientFile.uploadedDate!),
              ),
            ],
            style: DefaultTextStyle.of(context).style.merge(
                  const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget get _outdatedIcon => const Padding(
        padding: EdgeInsetsDirectional.only(
          bottom: 1.5,
          start: 1.5,
        ),
        child: icons.Outdated(
          color: Colors.white,
          size: 19.0,
        ),
      );

  Widget get _successIcon => const Padding(
        padding: EdgeInsetsDirectional.only(
          bottom: 0.5,
          start: 0.5,
        ),
        child: icons.Clock(
          color: Colors.white,
          size: 19.0,
        ),
      );
}

/// If the photo is locked by the owner (used in the modal sheet)
class _PhotoRowLockedStatus extends StatelessWidget {
  const _PhotoRowLockedStatus({
    required this.product,
    required this.imageField,
    required this.language,
  });

  final Product product;
  final ImageField imageField;
  final OpenFoodFactsLanguage language;

  @override
  Widget build(BuildContext context) {
    if (product.isImageLocked(imageField, language) != true) {
      return EMPTY_WIDGET;
    }

    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: SMALL_SPACE),
      child: _PhotoRowInfo(
        icon: const IconTheme(
          data: IconThemeData(
            size: 19.0,
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.only(bottom: 2.0),
            child: OwnerFieldIcon(),
          ),
        ),
        iconBackgroundColor: extension.warning,
        text: Text(
          appLocalizations.owner_field_image,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        wrapTextInExpanded: true,
      ),
    );
  }
}

/// Show an info in the modal sheet
class _PhotoRowInfo extends StatelessWidget {
  const _PhotoRowInfo({
    required this.icon,
    required this.iconBackgroundColor,
    required this.text,
    this.wrapTextInExpanded = false,
  });

  final Widget icon;
  final Color iconBackgroundColor;
  final Widget text;
  final bool wrapTextInExpanded;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: SMALL_SPACE),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: extension.primaryDark,
          borderRadius: BorderRadius.all(
            Radius.circular(MediaQuery.of(context).size.height),
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 47.5,
            maxWidth: MediaQuery.sizeOf(context).width * 0.95,
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox.square(
                  dimension: 47.5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: icon),
                  ),
                ),
                _textWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _textWidget {
    final Widget textWidget = Padding(
      padding: const EdgeInsetsDirectional.only(
        start: MEDIUM_SPACE,
        end: VERY_LARGE_SPACE,
      ),
      child: text,
    );

    if (wrapTextInExpanded) {
      return Expanded(
        child: textWidget,
      );
    }

    return textWidget;
  }
}
