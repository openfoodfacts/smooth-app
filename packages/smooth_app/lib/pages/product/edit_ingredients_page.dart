import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/explanation_widget.dart';
import 'package:smooth_app/pages/product/multilingual_helper.dart';
import 'package:smooth_app/pages/product/ocr_helper.dart';
import 'package:smooth_app/pages/product/product_image_local_button.dart';
import 'package:smooth_app/pages/product/product_image_server_button.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

// TODO(monsieurtanuki): rename file as `edit_ocr_page.dart`
/// Editing with OCR a product field and the corresponding image.
///
/// Typical use-cases: ingredients and packaging.
class EditOcrPage extends StatefulWidget {
  const EditOcrPage({
    required this.product,
    required this.helper,
  });

  final Product product;
  final OcrHelper helper;

  @override
  State<EditOcrPage> createState() => _EditOcrPageState();
}

class _EditOcrPageState extends State<EditOcrPage> {
  final TextEditingController _controller = TextEditingController();
  late Product _product;
  late final Product _initialProduct;
  late final LocalDatabase _localDatabase;
  late final MultilingualHelper _multilingualHelper;

  OcrHelper get _helper => widget.helper;

  @override
  void initState() {
    super.initState();
    _initialProduct = widget.product;
    _localDatabase = context.read<LocalDatabase>();
    _localDatabase.upToDate.showInterest(_initialProduct.barcode!);

    _multilingualHelper = MultilingualHelper(controller: _controller);
    _multilingualHelper.init(
      multilingualTexts: _helper.getMultilingualTexts(widget.product),
      monolingualText: _helper.getMonolingualText(widget.product),
    );
  }

  @override
  void dispose() {
    _localDatabase.upToDate.loseInterest(_product.barcode!);
    super.dispose();
  }

  /// Extracts data with OCR from the image stored on the server.
  ///
  /// When done, populates the related page field.
  Future<void> _extractData() async {
    // TODO(monsieurtanuki): hide the "extract" button while extracting, or display a loading dialog on top
    try {
      final String? extractedText = await _helper.getExtractedText(
        widget.product,
        _multilingualHelper.getCurrentLanguage(),
      );
      if (!mounted) {
        return;
      }

      if (extractedText == null || extractedText.isEmpty) {
        await LoadingDialog.error(
          context: context,
          title: AppLocalizations.of(context).edit_ocr_extract_failed,
        );
        return;
      }

      if (_controller.text != extractedText) {
        setState(() => _controller.text = extractedText);
      }
    } catch (e) {
      //
    }
  }

  /// Updates the product field on the server.
  Future<void> _updateText() async {
    final Product? changedProduct = _getMinimalistProduct();
    if (changedProduct == null) {
      return;
    }
    AnalyticsHelper.trackProductEdit(
      _helper.getEditEventAnalyticsTag(),
      _product.barcode!,
      true,
    );
    await BackgroundTaskDetails.addTask(
      changedProduct,
      widget: this,
      stamp: _helper.getStamp(),
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    _product = _localDatabase.upToDate.getLocalUpToDate(_initialProduct);
    final ProductImageData productImageData = getProductImageData(
      _product,
      _helper.getImageField(),
      _multilingualHelper.getCurrentLanguage(),
    );

    // TODO(monsieurtanuki): add WillPopScope / MayExitPage system
    return SmoothScaffold(
      extendBodyBehindAppBar: true,
      appBar: SmoothAppBar(
        title: Text(_helper.getTitle(appLocalizations)),
        subTitle: _product.productName != null
            ? Text(
                _product.productName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          _getImageWidget(productImageData),
          _getOcrWidget(productImageData),
        ],
      ),
    );
  }

  Widget _getImageWidget(final ProductImageData productImageData) {
    final Size size = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ImageProvider? imageProvider = TransientFile.getImageProvider(
      productImageData,
      _initialProduct.barcode!,
      _multilingualHelper.getCurrentLanguage(),
    );

    if (imageProvider != null) {
      return ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.only(
            left: VERY_LARGE_SPACE,
            top: 10,
            right: VERY_LARGE_SPACE,
            bottom: 200,
          ),
          minScale: 0.1,
          maxScale: 5,
          child: Image(
            fit: BoxFit.contain,
            image: imageProvider,
          ),
        ),
      );
    }

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: size.height * 0.25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: size.height / 4,
            child: const PictureNotFound(),
          ),
          Text(
            appLocalizations.ocr_image_upload_instruction,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget _getOcrWidget(final ProductImageData productImageData) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final OpenFoodFactsLanguage language = ProductQuery.getLanguage();
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
                          imageField: _helper.getImageField(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                        child: ProductImageLocalButton(
                          firstPhoto: !TransientFile.isImageAvailable(
                            productImageData,
                            widget.product.barcode!,
                            language,
                          ),
                          barcode: widget.product.barcode!,
                          imageField: _helper.getImageField(),
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
                      if (!_multilingualHelper.isMonolingual())
                        _multilingualHelper.getLanguageSelector(setState),
                      if (TransientFile.isServerImage(
                        productImageData,
                        widget.product.barcode!,
                        language,
                      ))
                        SmoothActionButtonsBar.single(
                          action: SmoothActionButton(
                            text:
                                _helper.getActionExtractText(appLocalizations),
                            onPressed: () async => _extractData(),
                          ),
                        )
                      else if (TransientFile.isImageAvailable(
                        productImageData,
                        widget.product.barcode!,
                        language,
                      ))
                        // TODO(monsieurtanuki): what if slow upload? text instead?
                        const CircularProgressIndicator.adaptive(),
                      const SizedBox(height: MEDIUM_SPACE),
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          fillColor: Colors.white.withOpacity(0.2),
                          filled: true,
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: ANGULAR_BORDER_RADIUS,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) async => _updateText(),
                      ),
                      const SizedBox(height: SMALL_SPACE),
                      ExplanationWidget(
                        _helper.getInstructions(appLocalizations),
                      ),
                      if (_helper.hasAddExtraPhotoButton())
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
                            await _updateText();
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

  /// Returns a [Product] with the values from the text fields.
  Product? _getMinimalistProduct() {
    Product? result;

    Product getBasicProduct() => Product(barcode: widget.product.barcode);

    if (_multilingualHelper.isMonolingual()) {
      final String? changed = _multilingualHelper.getChangedMonolingualText();
      if (changed != null) {
        result ??= getBasicProduct();
        _helper.setMonolingualText(result, changed);
      }
    } else {
      final Map<OpenFoodFactsLanguage, String>? changed =
          _multilingualHelper.getChangedMultilingualText();
      if (changed != null) {
        result ??= getBasicProduct();
        _helper.setMultilingualTexts(result, changed);
      }
    }
    return result;
  }
}
