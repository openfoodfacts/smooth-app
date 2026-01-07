import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/input/unfocus_field_when_tap_outside.dart';
import 'package:smooth_app/pages/product/common/product_buttons.dart';
import 'package:smooth_app/pages/product/common/product_picture_banner.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_ocr/edit_ocr_image.dart';
import 'package:smooth_app/pages/product/edit_ocr/edit_ocr_tabbar.dart';
import 'package:smooth_app/pages/product/edit_ocr/edit_ocr_textfield.dart';
import 'package:smooth_app/pages/product/edit_ocr/ocr_helper.dart';
import 'package:smooth_app/pages/product/gallery_view/product_image_gallery_view.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/pages/product/multilingual_helper.dart';
import 'package:smooth_app/pages/product/product_image_swipeable_view.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/will_pop_scope.dart';

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
  late final TextEditingController _controller;
  late final MultilingualHelper _multilingualHelper;
  late final WillPopScope2Controller _willPopScope2Controller;

  OcrHelper get _helper => widget.helper;
  bool _extractingData = false;

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());

    _willPopScope2Controller = WillPopScope2Controller(canPop: true);
    _controller = TextEditingController()..addListener(_onValueChanged);

    _multilingualHelper = MultilingualHelper(controller: _controller);
    _multilingualHelper.init(
      multilingualTexts: _helper.getMultilingualTexts(upToDateProduct),
      monolingualText: _helper.getMonolingualText(upToDateProduct),
      selectedImages: upToDateProduct.selectedImages,
      imageField: _helper.getImageField(),
      productLanguage: upToDateProduct.lang,
    );
    _multilingualHelper.addListener(_onValueChanged);
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

    return WillPopScope2(
      onWillPop: () async => (await _mayExitPage(saving: false), null),
      controller: _willPopScope2Controller,
      child: MultiProvider(
        providers: <SingleChildWidget>[
          Provider<Product>(create: (BuildContext context) => upToDateProduct),
          Provider<OcrState>.value(value: _extractState(transientFile)),
        ],
        child: UnfocusFieldWhenTapOutside(
          child: SmoothScaffold(
            extendBodyBehindAppBar: false,
            appBar: buildEditProductAppBar(
              context: context,
              title: _helper.getTitle(appLocalizations),
              product: upToDateProduct,
              bottom: !_multilingualHelper.isMonolingual()
                  ? EditOcrTabBar(
                      onTabChanged: (OpenFoodFactsLanguage language) {
                        if (_multilingualHelper.changeLanguage(language)) {
                          onNextFrame(() => setState(() {}), forceRedraw: true);
                        }
                      },
                      imageField: _helper.getImageField(),
                      languagesWithText: _getLanguagesWithText(),
                    )
                  : null,
            ),
            backgroundColor: context.lightTheme()
                ? context.extension<SmoothColorsThemeExtension>().primaryLight
                : null,
            body: ListView(
              padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
              children: <Widget>[
                EditOCRImageWidget(
                  helper: _helper,
                  transientFile: transientFile,
                  ownerField:
                      upToDateProduct.isImageLocked(
                        _helper.getImageField(),
                        _multilingualHelper.getCurrentLanguage(),
                      ) ??
                      false,
                  onEditImage: () async => _openImageViewer(),
                  onExtractText: () async => _extractData(),
                  onTakePicture: () async => _takePicture(),
                  onTakePictureWithChoices: () async => _listPictureChoices(),
                ),
                const SizedBox(height: MEDIUM_SPACE),
                EditOCRTextField(
                  helper: _helper,
                  controller: _controller,
                  extraButton: _helper.hasAddExtraPhotoButton()
                      ? EditOCRExtraButton(
                          barcode: upToDateProduct.barcode!,
                          productType: upToDateProduct.productType,
                          multilingualHelper: _multilingualHelper,
                          isLoggedInMandatory: widget.isLoggedInMandatory,
                        )
                      : null,
                  isOwnerField: _helper.isOwnerField(
                    upToDateProduct,
                    _multilingualHelper.getCurrentLanguage(),
                  ),
                ),
              ],
            ),
            resizeToAvoidBottomInset: true,
            bottomNavigationBar: ProductBottomButtonsBar(
              onSave: () async => _exitPage(await _mayExitPage(saving: true)),
              onCancel: () async =>
                  _exitPage(await _mayExitPage(saving: false)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openImageViewer() {
    return Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ProductImageSwipeableView.imageField(
          imageField: _helper.getImageField(),
          product: upToDateProduct,
          initialLanguage: _multilingualHelper.getCurrentLanguage(),
          isLoggedInMandatory: widget.isLoggedInMandatory,
        ),
      ),
    );
  }

  /// Extracts data with OCR from the image stored on the server.
  ///
  /// When done, populates the related page field.
  Future<void> _extractData() async {
    setState(() => _extractingData = true);

    try {
      final String? extractedText = await _helper.getExtractedText(
        upToDateProduct,
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
    } catch (_) {
    } finally {
      setState(() => _extractingData = false);
    }
  }

  Future<File?> _takePicture() async {
    return ProductImageGalleryView.takePicture(
      context: context,
      product: upToDateProduct,
      language: _multilingualHelper.getCurrentLanguage(),
      imageField: _helper.getImageField(),
      pictureSource: UserPictureSource.SELECT,
    );
  }

  Future<void> _listPictureChoices() async {
    showPhotoBanner(
      context: context,
      product: upToDateProduct,
      imageField: _helper.getImageField(),
      language: _multilingualHelper.getCurrentLanguage(),
    );
  }

  /// Exits the page if the [flag] is `true`.
  void _exitPage(final bool flag) {
    if (flag) {
      Navigator.of(context).pop();
    }
  }

  /// Returns `true` if we should really exit the page.
  ///
  /// Parameter [saving] tells about the context: are we leaving the page,
  /// or have we clicked on the "save" button?
  Future<bool> _mayExitPage({required final bool saving}) async {
    final Product? changedProduct = _getMinimalistProduct();
    if (changedProduct == null) {
      return true;
    }

    if (!saving) {
      final bool? pleaseSave = await MayExitPageHelper()
          .openSaveBeforeLeavingDialog(context);

      if (pleaseSave == false) {
        return true;
      }
      if (!mounted) {
        return false;
      }
    }

    await _saveChanges();
    return true;
  }

  /// Updates the product field on the server.
  Future<void> _saveChanges() async {
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
    if (!mounted) {
      return;
    }
    AnalyticsHelper.trackProductEdit(
      _helper.getEditEventAnalyticsTag(),
      upToDateProduct,
      true,
    );
    await BackgroundTaskDetails.addTask(
      changedProduct,
      context: context,
      stamp: _helper.getStamp(),
      productType: upToDateProduct.productType,
    );
    return;
  }

  List<OpenFoodFactsLanguage> _getLanguagesWithText() {
    final Map<OpenFoodFactsLanguage, String> allLanguages = _multilingualHelper
        .getInitialMultiLingualTexts();

    final List<OpenFoodFactsLanguage> languages = <OpenFoodFactsLanguage>[];

    for (final OpenFoodFactsLanguage language in allLanguages.keys) {
      if (allLanguages[language]?.isNotEmpty == true) {
        languages.add(language);
      }
    }

    return languages;
  }

  /// Returns a [Product] with the values from the text fields.
  Product? _getMinimalistProduct() {
    Product? result;

    Product getBasicProduct() => Product(barcode: barcode);

    if (_multilingualHelper.isMonolingual()) {
      final String? changed = _multilingualHelper.getChangedMonolingualText();
      if (changed != null) {
        result ??= getBasicProduct();
        _helper.setMonolingualText(result, changed);
      }
    } else {
      final Map<OpenFoodFactsLanguage, String>? changed = _multilingualHelper
          .getChangedMultilingualText();
      if (changed != null) {
        result ??= getBasicProduct();
        _helper.setMultilingualTexts(result, changed);
      }
    }
    return result;
  }

  void _onValueChanged() {
    _willPopScope2Controller.canPop(!_multilingualHelper.hasChanged());
  }

  OcrState _extractState(TransientFile transientFile) {
    if (_extractingData) {
      return OcrState.EXTRACTING_DATA;
    } else if (transientFile.isServerImage()) {
      return OcrState.IMAGE_LOADED;
    } else if (transientFile.isImageAvailable()) {
      return OcrState.IMAGE_LOADING;
    } else {
      return OcrState.OTHER;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _multilingualHelper.dispose();
    _willPopScope2Controller.dispose();
    super.dispose();
  }
}

enum OcrState { IMAGE_LOADING, IMAGE_LOADED, EXTRACTING_DATA, OTHER }
