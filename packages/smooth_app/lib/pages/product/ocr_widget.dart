import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/explanation_widget.dart';
import 'package:smooth_app/pages/product/ocr_helper.dart';
import 'package:smooth_app/pages/product/product_image_local_button.dart';
import 'package:smooth_app/pages/product/product_image_server_button.dart';

/// Widget dedicated to OCR, with 3 actions: upload image, extract data, save.
///
/// Potential extra action: add extra photos.
class OcrWidget extends StatefulWidget {
  const OcrWidget({
    required this.controller,
    required this.onSubmitField,
    required this.onTapExtractData,
    required this.productImageData,
    required this.product,
    required this.helper,
  });

  final TextEditingController controller;
  final Future<void> Function() onTapExtractData;
  final Future<void> Function(ImageField) onSubmitField;
  final ProductImageData productImageData;
  final Product product;
  final OcrHelper helper;

  @override
  State<OcrWidget> createState() => _OcrWidgetState();
}

class _OcrWidgetState extends State<OcrWidget> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Align(
      alignment: AlignmentDirectional.bottomStart,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  bottom: LARGE_SPACE,
                  start: LARGE_SPACE,
                  end: LARGE_SPACE,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                        child: ProductImageServerButton(
                          barcode: widget.product.barcode!,
                          imageField: widget.helper.getImageField(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                        child: ProductImageLocalButton(
                          firstPhoto: !TransientFile.isImageAvailable(
                            widget.productImageData,
                            widget.product.barcode!,
                          ),
                          barcode: widget.product.barcode!,
                          imageField: widget.helper.getImageField(),
                        ),
                      ),
                    ),
                  ],
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
                      if (TransientFile.isServerImage(
                        widget.productImageData,
                        widget.product.barcode!,
                      ))
                        SmoothActionButtonsBar.single(
                          action: SmoothActionButton(
                            text: widget.helper
                                .getActionExtractText(appLocalizations),
                            onPressed: () async => widget.onTapExtractData(),
                          ),
                        )
                      else if (TransientFile.isImageAvailable(
                        widget.productImageData,
                        widget.product.barcode!,
                      ))
                        // TODO(monsieurtanuki): what if slow upload? text instead?
                        const CircularProgressIndicator.adaptive(),
                      const SizedBox(height: MEDIUM_SPACE),
                      TextField(
                        controller: widget.controller,
                        decoration: InputDecoration(
                          fillColor: Colors.white.withOpacity(0.2),
                          filled: true,
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: ANGULAR_BORDER_RADIUS,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) =>
                            widget.onSubmitField(widget.helper.getImageField()),
                      ),
                      const SizedBox(height: SMALL_SPACE),
                      ExplanationWidget(
                        widget.helper.getInstructions(appLocalizations),
                      ),
                      if (widget.helper.hasAddExtraPhotoButton())
                        Padding(
                          padding: const EdgeInsets.only(top: SMALL_SPACE),
                          child: addPanelButton(
                            appLocalizations.add_packaging_photo_button_label
                                .toUpperCase(),
                            onPressed: () async => confirmAndUploadNewPicture(
                              this,
                              imageField: ImageField.OTHER,
                              barcode: widget.product.barcode!,
                            ),
                            iconData: Icons.add_a_photo,
                          ),
                        ),
                      const SizedBox(height: MEDIUM_SPACE),
                      SmoothActionButtonsBar(
                        axis: Axis.horizontal,
                        negativeAction: SmoothActionButton(
                          text: appLocalizations.cancel,
                          onPressed: () => Navigator.pop(context),
                        ),
                        positiveAction: SmoothActionButton(
                          text: appLocalizations.save,
                          onPressed: () async {
                            await widget
                                .onSubmitField(widget.helper.getImageField());
                            if (!mounted) {
                              return;
                            }
                            Navigator.pop(context);
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
