import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/explanation_widget.dart';
import 'package:smooth_app/pages/product/multilingual_helper.dart';
import 'package:smooth_app/pages/product/ocr_helper.dart';
import 'package:smooth_app/pages/product/product_image_local_button.dart';
import 'package:smooth_app/pages/product/product_image_server_button.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Editing with OCR a product field and the corresponding image.
///
/// Typical use-cases: ingredients and packaging.
class EditOcrPage extends StatefulWidget {
  const EditOcrPage({
    required this.product,
    required this.helper,
    required this.isLoggedInMandatory,
  });

  final Product product;
  final OcrHelper helper;
  final bool isLoggedInMandatory;

  @override
  State<EditOcrPage> createState() => _EditOcrPageState();
}

class _EditOcrPageState extends State<EditOcrPage> with UpToDateMixin {
  final TextEditingController _controller = TextEditingController();
  late final MultilingualHelper _multilingualHelper;

  OcrHelper get _helper => widget.helper;

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
    _multilingualHelper = MultilingualHelper(controller: _controller);
    _multilingualHelper.init(
      multilingualTexts: _helper.getMultilingualTexts(widget.product),
      monolingualText: _helper.getMonolingualText(widget.product),
      selectedImages: widget.product.selectedImages,
      imageField: _helper.getImageField(),
      productLanguage: widget.product.lang,
    );
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
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: widget.isLoggedInMandatory,
    )) {
      return;
    }
    AnalyticsHelper.trackProductEdit(
      _helper.getEditEventAnalyticsTag(),
      barcode,
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
    refreshUpToDate();
    final TransientFile transientFile = TransientFile.fromProduct(
      upToDateProduct,
      _helper.getImageField(),
      _multilingualHelper.getCurrentLanguage(),
    );

    final TextStyle appbarTextStyle = TextStyle(shadows: <Shadow>[
      Shadow(
        color: Theme.of(context).colorScheme.brightness == Brightness.light
            ? Colors.white
            : Colors.black,
        offset: const Offset(0.5, 0.5),
        blurRadius: 5.0,
      )
    ]);

    // TODO(monsieurtanuki): add WillPopScope / MayExitPage system
    return SmoothScaffold(
      extendBodyBehindAppBar: true,
      appBar: SmoothAppBar(
        centerTitle: false,
        title: Text(
          _helper.getTitle(appLocalizations),
          style: appbarTextStyle,
        ),
        subTitle: upToDateProduct.productName != null
            ? Text(
                upToDateProduct.productName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: appbarTextStyle,
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
          _getImageWidget(transientFile),
          _getOcrWidget(transientFile),
        ],
      ),
    );
  }

  Widget _getImageWidget(final TransientFile transientFile) {
    final Size size = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ImageProvider? imageProvider = transientFile.getImageProvider();

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

  Widget _getOcrWidget(final TransientFile transientFile) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final OpenFoodFactsLanguage language =
        _multilingualHelper.getCurrentLanguage();
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
                          product: upToDateProduct,
                          imageField: _helper.getImageField(),
                          language: language,
                          isLoggedInMandatory: widget.isLoggedInMandatory,
                          borderWidth: 2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                        child: ProductImageLocalButton(
                          firstPhoto: !transientFile.isImageAvailable(),
                          barcode: widget.product.barcode!,
                          imageField: _helper.getImageField(),
                          language: language,
                          isLoggedInMandatory: widget.isLoggedInMandatory,
                          borderWidth: 2,
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
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: ANGULAR_RADIUS,
                    topRight: ANGULAR_RADIUS,
                  )),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(LARGE_SPACE),
                  child: Column(
                    children: <Widget>[
                      if (!_multilingualHelper.isMonolingual())
                        _multilingualHelper.getLanguageSelector(setState),
                      if (transientFile.isServerImage())
                        SmoothActionButtonsBar.single(
                          action: SmoothActionButton(
                            text:
                                _helper.getActionExtractText(appLocalizations),
                            onPressed: () async => _extractData(),
                          ),
                        )
                      else if (transientFile.isImageAvailable())
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
                        textInputAction: TextInputAction.newline,
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
                              language: language,
                              isLoggedInMandatory: widget.isLoggedInMandatory,
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
