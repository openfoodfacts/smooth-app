import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';

/// OCR Helper, to be implemented for ingredients and packaging for instance.
abstract class OcrHelper {
  /// Returns the initial text value of the field for this [product].
  String getText(final Product product);

  /// Returns a [Product] with the same barcode and the [text] as field value.
  ///
  /// Nothing more, and that's perfect for server update.
  Product getMinimalistProduct(final Product product, final String text);

  /// Returns the image url of this field for this [product].
  String? getImageUrl(final Product product);

  /// Returns the error to display when the image upload + OCR failed.
  String getImageError(final AppLocalizations appLocalizations);

  /// Returns the error when the server product refresh failed.
  ///
  /// E.g. no internet connection.
  String getError(final AppLocalizations appLocalizations);

  /// Returns the "extract text" button label
  String getActionExtractText(final AppLocalizations appLocalizations);

  /// Returns the "refresh photo" button label
  String getActionRefreshPhoto(final AppLocalizations appLocalizations);

  /// Returns instructions about the text input.
  String getInstructions(final AppLocalizations appLocalizations);

  /// Returns the page title.
  String getTitle(final AppLocalizations appLocalizations);

  /// Returns the image field we try to run OCR on.
  ImageField getImageField();

  /// Returns the text that the server OCR managed to extract from the image.
  Future<String?> getExtractedText(final Product product);

  /// Returns the OCR widget with input and buttons.
  Widget getOcrWidget({
    required final TextEditingController controller,
    required final bool updatingText,
    required final Future<void> Function(bool) onTapGetImage,
    required final Future<void> Function() onSubmitField,
    required final ImageProvider? imageProvider,
    required final Product product,
  }) =>
      _OcrWidget(
        controller: controller,
        onTapGetImage: onTapGetImage,
        onSubmitField: onSubmitField,
        updatingText: updatingText,
        hasImageProvider: imageProvider != null,
        product: product,
        helper: this,
      );

  @protected
  OpenFoodFactsLanguage getLanguage() => ProductQuery.getLanguage()!;

  @protected
  User getUser() => ProductQuery.getUser();
}

class _OcrWidget extends StatelessWidget {
  const _OcrWidget({
    required this.controller,
    required this.onSubmitField,
    required this.onTapGetImage,
    required this.updatingText,
    required this.hasImageProvider,
    required this.product,
    required this.helper,
  });

  final TextEditingController controller;
  final bool updatingText;
  final Future<void> Function(bool) onTapGetImage;
  final Future<void> Function() onSubmitField;
  final bool hasImageProvider;
  final Product product;
  final OcrHelper helper;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Align(
      alignment: Alignment.bottomLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: LARGE_SPACE,
                  right: LARGE_SPACE,
                  left: LARGE_SPACE,
                ),
                child: SmoothActionButtonsBar(
                  positiveAction: SmoothActionButton(
                    text: helper.getActionRefreshPhoto(appLocalizations),
                    onPressed: () => onTapGetImage(true),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: ANGULAR_RADIUS,
                      topRight: ANGULAR_RADIUS,
                    )),
                child: Padding(
                  padding: const EdgeInsets.all(LARGE_SPACE),
                  child: Column(
                    children: <Widget>[
                      if (hasImageProvider ||
                          helper.getImageUrl(product) != null)
                        SmoothActionButtonsBar.single(
                          action: SmoothActionButton(
                            text: helper.getActionExtractText(appLocalizations),
                            onPressed: () => onTapGetImage(false),
                          ),
                        ),
                      const SizedBox(height: MEDIUM_SPACE),
                      TextField(
                        enabled: !updatingText,
                        controller: controller,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: ANGULAR_BORDER_RADIUS,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => onSubmitField,
                      ),
                      const SizedBox(height: SMALL_SPACE),
                      Text(
                        helper.getInstructions(appLocalizations),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      const SizedBox(height: MEDIUM_SPACE),
                      SmoothActionButtonsBar(
                        negativeAction: SmoothActionButton(
                          text: appLocalizations.cancel,
                          onPressed: () => Navigator.pop(context),
                        ),
                        positiveAction: SmoothActionButton(
                          text: appLocalizations.save,
                          onPressed: () async {
                            await onSubmitField();
                            //ignore: use_build_context_synchronously
                            Navigator.pop(context, product);
                          },
                        ),
                      ),
                      const SizedBox(height: MEDIUM_SPACE),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
