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
    contentPadding: const EdgeInsetsDirectional.symmetric(
      horizontal: LARGE_SPACE,
    ),
    addEndArrowToItems: true,
    footerBackgroundColor: lightTheme ? extension.primaryLight : null,
    footerSpace: VERY_SMALL_SPACE,
    footer: _PhotoRowBanner(
      children: <Widget>[
        _PhotoRowDate(transientFile: transientFile),
        const Divider(color: Colors.white),
        _PhotoRowContributor(
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
          Container(
            width: double.infinity,
            color: extension.primaryDark,
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: MEDIUM_SPACE,
              vertical: MEDIUM_SPACE,
            ),
            child: Text(
              AppLocalizations.of(context).product_image_details_label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

enum _PhotoRowActions {
  takePicture,
  selectFromGallery,
  selectFromProductPhotos,
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    final bool isLocked = product.isImageLocked(imageField, language) == true;

    return ListTile(
      leading: _PhotoRowDetailsIcon(
        color: extension.primaryDark,
        icon: const OwnerFieldIcon(
          color: Colors.white,
          size: 19.0,
        ),
        padding: const EdgeInsetsDirectional.only(bottom: 1.0, end: 1.0),
      ),
      title: Text(appLocalizations.product_image_details_from_producer),
      trailing: Text(
        isLocked ? appLocalizations.yes : appLocalizations.no,
      ),
    );
  }
}

/// The date of the photo (used in the modal sheet)
class _PhotoRowDate extends StatelessWidget {
  const _PhotoRowDate({
    required this.transientFile,
  });

  final TransientFile transientFile;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    final bool outdated = transientFile.expired;

    return ListTile(
      leading: _PhotoRowDetailsIcon(
        color: outdated ? extension.warning : extension.primaryDark,
        icon: outdated ? _outdatedIcon : _successIcon,
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
        child: icons.Outdated(
          size: 19.0,
          color: Colors.white,
        ),
      );

  Widget get _successIcon => const Padding(
        padding: EdgeInsetsDirectional.only(bottom: 0.5),
        child: icons.Clock(
          size: 19.0,
          color: Colors.white,
        ),
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
          child: icon,
        ),
      ),
    );
  }
}
