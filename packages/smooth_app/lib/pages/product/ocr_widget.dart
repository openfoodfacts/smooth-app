import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/pages/product/explanation_widget.dart';
import 'package:smooth_app/pages/product/ocr_helper.dart';

/// Widget dedicated to OCR, with 3 actions: upload image, extract data, save.
class OcrWidget extends StatelessWidget {
  const OcrWidget({
    required this.controller,
    required this.onSubmitField,
    required this.onTapNewImage,
    required this.onTapExtractData,
    required this.productImageData,
    required this.product,
    required this.helper,
  });

  final TextEditingController controller;
  final Future<void> Function() onTapNewImage;
  final Future<void> Function() onTapExtractData;
  final Future<void> Function(ImageField) onSubmitField;
  final ProductImageData productImageData;
  final Product product;
  final OcrHelper helper;

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
                child: SmoothActionButtonsBar(
                  positiveAction: SmoothActionButton(
                    text: (TransientFile.isImageAvailable(
                      productImageData,
                      product.barcode!,
                    ))
                        ? helper.getActionRefreshPhoto(appLocalizations)
                        : appLocalizations.upload_image,
                    onPressed: () async => onTapNewImage(),
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
                      if (TransientFile.isServerImage(
                        productImageData,
                        product.barcode!,
                      ))
                        SmoothActionButtonsBar.single(
                          action: SmoothActionButton(
                            text: helper.getActionExtractText(appLocalizations),
                            onPressed: () async => onTapExtractData(),
                          ),
                        )
                      else if (TransientFile.isImageAvailable(
                        productImageData,
                        product.barcode!,
                      ))
                        // TODO(monsieurtanuki): what if slow upload? text instead?
                        const CircularProgressIndicator.adaptive(),
                      const SizedBox(height: MEDIUM_SPACE),
                      TextField(
                        controller: controller,
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
                            onSubmitField(helper.getImageField()),
                      ),
                      const SizedBox(height: SMALL_SPACE),
                      ExplanationWidget(
                        helper.getInstructions(appLocalizations),
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
                            await onSubmitField(helper.getImageField());
                            ////ignore: use_build_context_synchronously
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
