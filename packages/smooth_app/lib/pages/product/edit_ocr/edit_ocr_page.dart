import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/picture_not_found.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_ocr/edit_ocr_tabbar.dart';
import 'package:smooth_app/pages/product/edit_ocr/ocr_helper.dart';
import 'package:smooth_app/pages/product/explanation_widget.dart';
import 'package:smooth_app/pages/product/multilingual_helper.dart';
import 'package:smooth_app/pages/product/product_image_button.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/v2/smooth_buttons_bar.dart';

part 'edit_ocr_main_action.dart';

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
  bool _extractingData = false;

  @override
  void initState() {
    super.initState();
    initUpToDate(widget.product, context.read<LocalDatabase>());
    _multilingualHelper = MultilingualHelper(controller: _controller);
    _multilingualHelper.init(
      multilingualTexts: _helper.getMultilingualTexts(upToDateProduct),
      monolingualText: _helper.getMonolingualText(upToDateProduct),
      selectedImages: upToDateProduct.selectedImages,
      imageField: _helper.getImageField(),
      productLanguage: upToDateProduct.lang,
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

    // TODO(monsieurtanuki): add WillPopScope / MayExitPage system
    return Provider<Product>(
      create: (BuildContext context) => upToDateProduct,
      child: SmoothScaffold(
        extendBodyBehindAppBar: true,
        appBar: buildEditProductAppBar(
          context: context,
          title: _helper.getTitle(appLocalizations),
          product: upToDateProduct,
          bottom: !_multilingualHelper.isMonolingual()
              ? EditOcrTabBar(
                  onTabChanged: (OpenFoodFactsLanguage language) {
                    if (_multilingualHelper.changeLanguage(language)) {
                      setState(() {});
                    }
                  },
                  imageField: _helper.getImageField(),
                  languagesWithText: _getLanguagesWithText(),
                )
              : null,
        ),
        body: Stack(
          children: <Widget>[
            _getImageWidget(transientFile),
            _getOcrWidget(transientFile),
          ],
        ),
      ),
    );
  }

  List<OpenFoodFactsLanguage> _getLanguagesWithText() {
    final Map<OpenFoodFactsLanguage, String> allLanguages =
        _multilingualHelper.getInitialMultiLingualTexts();

    final List<OpenFoodFactsLanguage> languages = <OpenFoodFactsLanguage>[];

    for (final OpenFoodFactsLanguage language in allLanguages.keys) {
      if (allLanguages[language]?.isNotEmpty == true) {
        languages.add(language);
      }
    }

    return languages;
  }

  Widget _getImageButton(
    final ProductImageButtonType type,
    final bool imageExists,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
        child: type.getButton(
          product: upToDateProduct,
          imageField: _helper.getImageField(),
          imageExists: imageExists,
          language: _multilingualHelper.getCurrentLanguage(),
          isLoggedInMandatory: widget.isLoggedInMandatory,
          borderWidth: 2,
        ),
      );

  Widget _getImageWidget(final TransientFile transientFile) {
    final Size size = MediaQuery.sizeOf(context);
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
            width: size.width,
            height: size.height / 4,
            child: const PictureNotFound(boxFit: BoxFit.fitHeight),
          ),
          Padding(
            padding: const EdgeInsets.all(LARGE_SPACE),
            child: Text(
              appLocalizations.ocr_image_upload_instruction,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget _getOcrWidget(final TransientFile transientFile) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final OpenFoodFactsLanguage language =
        _multilingualHelper.getCurrentLanguage();
    final ImageProvider? imageProvider = transientFile.getImageProvider();
    final bool imageExists = imageProvider != null;

    return Align(
      alignment: AlignmentDirectional.bottomStart,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                bottom: LARGE_SPACE,
                start: LARGE_SPACE,
                end: LARGE_SPACE,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: _getImageButton(
                          ProductImageButtonType.server,
                          imageExists,
                        ),
                      ),
                      Expanded(
                        child: _getImageButton(
                          ProductImageButtonType.local,
                          imageExists,
                        ),
                      ),
                    ],
                  ),
                  if (imageProvider != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: _getImageButton(
                            ProductImageButtonType.unselect,
                            imageExists,
                          ),
                        ),
                        Expanded(
                          child: _getImageButton(
                            ProductImageButtonType.edit,
                            imageExists,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadiusDirectional.only(
                  topStart: ANGULAR_RADIUS,
                  topEnd: ANGULAR_RADIUS,
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: LARGE_SPACE,
                    end: LARGE_SPACE,
                    top: LARGE_SPACE,
                  ),
                  child: Column(
                    children: <Widget>[
                      _EditOcrMainAction(
                        onPressed: _extractData,
                        helper: _helper,
                        state: _extractState(transientFile),
                      ),
                      const SizedBox(height: MEDIUM_SPACE),
                      ConsumerFilter<UserPreferences>(
                        buildWhen: (
                          UserPreferences? previousValue,
                          UserPreferences currentValue,
                        ) {
                          return previousValue?.getFlag(UserPreferencesDevMode
                                  .userPreferencesFlagSpellCheckerOnOcr) !=
                              currentValue.getFlag(UserPreferencesDevMode
                                  .userPreferencesFlagSpellCheckerOnOcr);
                        },
                        builder: (
                          BuildContext context,
                          UserPreferences prefs,
                          Widget? child,
                        ) {
                          final ThemeData theme = Theme.of(context);

                          return Theme(
                            data: theme.copyWith(
                              colorScheme: theme.colorScheme.copyWith(
                                onSurface: context
                                        .read<ThemeProvider>()
                                        .isDarkMode(context)
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                fillColor: Colors.white.withValues(alpha: 0.2),
                                filled: true,
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius: ANGULAR_BORDER_RADIUS,
                                ),
                              ),
                              maxLines: null,
                              textInputAction: TextInputAction.newline,
                              spellCheckConfiguration: (prefs.getFlag(
                                              UserPreferencesDevMode
                                                  .userPreferencesFlagSpellCheckerOnOcr) ??
                                          false) &&
                                      (Platform.isAndroid || Platform.isIOS)
                                  ? const SpellCheckConfiguration()
                                  : const SpellCheckConfiguration.disabled(),
                            ),
                          );
                        },
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
                              context,
                              imageField: ImageField.OTHER,
                              barcode: barcode,
                              productType: upToDateProduct.productType,
                              language: language,
                              isLoggedInMandatory: widget.isLoggedInMandatory,
                            ),
                            iconData: Icons.add_a_photo,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SmoothButtonsBar2(
            positiveButton: SmoothActionButton2(
              text: appLocalizations.save,
              onPressed: () async {
                await _updateText();
                if (!mounted) {
                  return;
                }
                Navigator.pop(context);
              },
            ),
            negativeButton: SmoothActionButton2(
              text: appLocalizations.cancel,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
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
      final Map<OpenFoodFactsLanguage, String>? changed =
          _multilingualHelper.getChangedMultilingualText();
      if (changed != null) {
        result ??= getBasicProduct();
        _helper.setMultilingualTexts(result, changed);
      }
    }
    return result;
  }

  _OcrState _extractState(TransientFile transientFile) {
    if (_extractingData) {
      return _OcrState.EXTRACTING_DATA;
    } else if (transientFile.isServerImage()) {
      return _OcrState.IMAGE_LOADED;
    } else if (transientFile.isImageAvailable()) {
      return _OcrState.IMAGE_LOADING;
    } else {
      return _OcrState.OTHER;
    }
  }
}
