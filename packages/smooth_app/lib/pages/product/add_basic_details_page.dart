import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/provider_helper.dart';
import 'package:smooth_app/pages/input/smooth_autocomplete_text_field.dart';
import 'package:smooth_app/pages/input/unfocus_field_when_tap_outside.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/product/common/product_buttons.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/pages/product/multilingual_helper.dart';
import 'package:smooth_app/pages/product/owner_field_info.dart';
import 'package:smooth_app/pages/text_field_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/will_pop_scope.dart';

/// Input of a product's basic details, like name, quantity and brands.
///
/// The product name input is either monolingual or multilingual, depending on
/// the product data version.
class AddBasicDetailsPage extends StatefulWidget {
  const AddBasicDetailsPage(
    this.product, {
    required this.isLoggedInMandatory,
  });

  final Product product;
  final bool isLoggedInMandatory;

  @override
  State<AddBasicDetailsPage> createState() => _AddBasicDetailsPageState();
}

class _AddBasicDetailsPageState extends State<AddBasicDetailsPage> {
  final TextEditingController _productNameController = TextEditingController();
  late final TextEditingControllerWithHistory _brandNameController;
  late final TextEditingControllerWithHistory _weightController;

  final double _heightSpace = LARGE_SPACE;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final Product _product;

  late final MultilingualHelper _multilingualHelper;
  final Key _autocompleteKey = UniqueKey();
  late final FocusNode _focusNode;

  /// Only used when there's not enough place
  bool _showPhotosBanner = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _weightController = TextEditingControllerWithHistory(
      text: MultilingualHelper.getCleanText(_product.quantity ?? ''),
    );
    _brandNameController = TextEditingControllerWithHistory(
      text: _formatProductBrands(_product.brands),
    );
    _multilingualHelper = MultilingualHelper(
      controller: _productNameController,
    );
    _multilingualHelper.init(
      multilingualTexts: _product.productNameInLanguages,
      monolingualText: _product.productName,
      productLanguage: _product.lang,
    );
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _weightController.dispose();
    _brandNameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatProductBrands(String? text) => MultilingualHelper.getCleanText(
        text == null ? '' : formatProductBrands(text),
      );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    Widget child = _buildForm(
      context: context,
      appLocalizations: appLocalizations,
      showPhotos: _showPhotosBanner,
    );

    if (_hasOwnerField()) {
      child = Column(
        children: <Widget>[
          Expanded(child: child),
          const OwnerFieldBanner(),
        ],
      );
    }

    return WillPopScope2(
      onWillPop: () async => (await _mayExitPage(saving: false), null),
      child: UnfocusFieldWhenTapOutside(
        child: SmoothScaffold(
          fixKeyboard: true,
          appBar: buildEditProductAppBar(
            context: context,
            title: appLocalizations.basic_details,
            product: _product,
            actions: <Widget>[
              IconButton(
                onPressed: () => setState(() {
                  _showPhotosBanner = !_showPhotosBanner;
                }),
                icon: const icons.ImageGallery(),
                tooltip: appLocalizations.show_product_pictures,
                enableFeedback: true,
              ),
            ],
          ),
          backgroundColor: context.lightTheme()
              ? context.extension<SmoothColorsThemeExtension>().primaryLight
              : null,
          body: child,
          bottomNavigationBar: ProductBottomButtonsBar(
            onSave: () async => _exitPage(
              await _mayExitPage(saving: true),
            ),
            onCancel: () async => _exitPage(
              await _mayExitPage(saving: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm({
    required BuildContext context,
    required AppLocalizations appLocalizations,
    required bool showPhotos,
  }) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Form(
            key: _formKey,
            child: Scrollbar(
              child: ListView(
                padding: const EdgeInsetsDirectional.only(
                  top: MEDIUM_SPACE,
                  start: MEDIUM_SPACE,
                  end: MEDIUM_SPACE,
                ),
                children: <Widget>[
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
                    builder: (BuildContext context, UserPreferences prefs,
                        Widget? child) {
                      if (_multilingualHelper.isMonolingual()) {
                        return _ProductMonolingualNameInputWidget(
                          textController: _productNameController,
                          ownerField: _isOwnerField(ProductField.NAME),
                        );
                      } else {
                        return _ProductMultilingualNameInputWidget(
                          textController: _productNameController,
                          ownerField: _isOwnerField(
                            ProductField.NAME_IN_LANGUAGES,
                            language: _multilingualHelper.getCurrentLanguage(),
                          ),
                          multilingualHelper: _multilingualHelper,
                          product: _product,
                          setState: setState,
                        );
                      }
                    },
                  ),
                  SizedBox(height: _heightSpace),
                  _ProductBrandsInputWidget(
                    autocompleteKey: _autocompleteKey,
                    focusNode: _focusNode,
                    textController: _brandNameController,
                    productType: _product.productType,
                    ownerField: _isOwnerField(ProductField.BRANDS),
                  ),
                  SizedBox(height: _heightSpace),
                  _ProductQuantityInputWidget(
                    textController: _weightController,
                    ownerField: _isOwnerField(ProductField.QUANTITY),
                  ),
                  // in order to be able to scroll suggestions
                  const SizedBox(height: 50.0),
                ],
              ),
            ),
          ),
        ),
        Offstage(
          offstage: !showPhotos,
          child: AnimatedOpacity(
            duration: SmoothAnimationsDuration.short,
            opacity: showPhotos ? 1.0 : 0.0,
            child: Padding(
              padding: const EdgeInsets.all(MEDIUM_SPACE),
              child: SmoothCardWithRoundedHeader(
                title: appLocalizations.edit_product_form_item_photos_title,
                leading: const icons.Camera.happy(),
                contentPadding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: ROUNDED_BORDER_RADIUS,
                  child: ProductImageCarousel(
                    _product,
                    height: MediaQuery.sizeOf(context).height * 0.10,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
    final Product? minimalistProduct = _getMinimalistProduct();
    if (minimalistProduct == null) {
      return true;
    }

    if (!saving) {
      final bool? pleaseSave =
          await MayExitPageHelper().openSaveBeforeLeavingDialog(context);
      if (pleaseSave == null) {
        return false;
      }
      if (pleaseSave == false) {
        return true;
      }
      if (!mounted) {
        return false;
      }
    }

    if (!mounted) {
      return false;
    }
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: widget.isLoggedInMandatory,
    )) {
      return false;
    }

    if (!mounted) {
      return false;
    }

    AnalyticsHelper.trackProductEdit(
      AnalyticsEditEvents.basicDetails,
      _product,
      true,
    );
    await BackgroundTaskDetails.addTask(
      minimalistProduct,
      context: context,
      stamp: BackgroundTaskDetailsStamp.basicDetails,
      productType: _product.productType,
    );

    return true;
  }

  /// Returns a [Product] with the values from the text fields.
  Product? _getMinimalistProduct() {
    Product? result;

    Product getBasicProduct() => Product(barcode: _product.barcode);

    if (_weightController.isDifferentFromInitialValue) {
      result ??= getBasicProduct();
      result.quantity = _weightController.text;
    }
    if (_brandNameController.isDifferentFromInitialValue) {
      result ??= getBasicProduct();
      result.brands = _formatProductBrands(_brandNameController.text);
    }
    if (_multilingualHelper.isMonolingual()) {
      final String? changed = _multilingualHelper.getChangedMonolingualText();
      if (changed != null) {
        result ??= getBasicProduct();
        result.productName = changed;
      }
    } else {
      final Map<OpenFoodFactsLanguage, String>? changed =
          _multilingualHelper.getChangedMultilingualText();
      if (changed != null) {
        result ??= getBasicProduct();
        result.productNameInLanguages = changed;
      }
    }
    return result;
  }

  bool _hasOwnerField() {
    if (_multilingualHelper.isMonolingual()) {
      if (_isOwnerField(ProductField.NAME)) {
        return true;
      }
    } else {
      if (_isOwnerField(
        ProductField.NAME_IN_LANGUAGES,
        language: _multilingualHelper.getCurrentLanguage(),
      )) {
        return true;
      }
    }
    return _isOwnerField(ProductField.BRANDS) ||
        _isOwnerField(ProductField.QUANTITY);
  }

  bool _isOwnerField(
    final ProductField productField, {
    final OpenFoodFactsLanguage? language,
  }) =>
      _product.getOwnerFieldTimestamp(
        OwnerField.productField(
          productField,
          language ?? ProductQuery.getLanguage(),
        ),
      ) !=
      null;
}

class _ProductMonolingualNameInputWidget extends StatelessWidget {
  const _ProductMonolingualNameInputWidget({
    required this.textController,
    required this.ownerField,
  });

  final TextEditingController textController;
  final bool ownerField;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return _BasicDetailInputWrapper(
      title: appLocalizations.quantity,
      icon: const icons.Scale.alt(),
      ownerField: ownerField,
      child: SmoothTextFormField(
        controller: textController,
        type: TextFieldTypes.PLAIN_TEXT,
        hintText: appLocalizations.add_basic_details_product_name_hint,
        spellCheckConfiguration: (context.read<UserPreferences>().getFlag(
                        UserPreferencesDevMode
                            .userPreferencesFlagSpellCheckerOnOcr) ??
                    false) &&
                (Platform.isAndroid || Platform.isIOS)
            ? const SpellCheckConfiguration()
            : const SpellCheckConfiguration.disabled(),
      ),
    );
  }
}

class _ProductMultilingualNameInputWidget extends StatelessWidget {
  const _ProductMultilingualNameInputWidget({
    required this.product,
    required this.textController,
    required this.multilingualHelper,
    required this.setState,
    required this.ownerField,
  });

  final Product product;
  final TextEditingController textController;
  final MultilingualHelper multilingualHelper;
  final void Function(void Function()) setState;
  final bool ownerField;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return _BasicDetailInputWrapper(
      title: appLocalizations.product_name,
      icon: const icons.Milk.happy(),
      ownerField: ownerField,
      contentPadding: const EdgeInsetsDirectional.only(
        bottom: MEDIUM_SPACE,
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: multilingualHelper.getLanguageSelector(
              setState: setState,
              product: product,
              icon: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                child: const Padding(
                  padding: EdgeInsetsDirectional.only(top: 0.5),
                  child: Icon(Icons.expand_more_outlined),
                ),
              ),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 21.0,
                vertical: SMALL_SPACE,
              ),
              borderRadius: BorderRadius.vertical(
                top: ROUNDED_BORDER_RADIUS.topLeft,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              top: VERY_SMALL_SPACE,
              start: MEDIUM_SPACE,
              end: MEDIUM_SPACE,
            ),
            child: SmoothTextFormField(
              controller: textController,
              type: TextFieldTypes.PLAIN_TEXT,
              hintText: appLocalizations.add_basic_details_product_name_hint,
              hintTextStyle: SmoothTextFormField.defaultHintTextStyle(context),
              spellCheckConfiguration: (context.read<UserPreferences>().getFlag(
                              UserPreferencesDevMode
                                  .userPreferencesFlagSpellCheckerOnOcr) ??
                          false) &&
                      (Platform.isAndroid || Platform.isIOS)
                  ? const SpellCheckConfiguration()
                  : const SpellCheckConfiguration.disabled(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductBrandsInputWidget extends StatelessWidget {
  const _ProductBrandsInputWidget({
    required this.autocompleteKey,
    required this.focusNode,
    required this.textController,
    required this.productType,
    required this.ownerField,
  });

  final Key autocompleteKey;
  final FocusNode focusNode;
  final TextEditingController textController;
  final ProductType? productType;
  final bool ownerField;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (
      final BuildContext context,
      final BoxConstraints constraints,
    ) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);

      return _BasicDetailInputWrapper(
        title: appLocalizations.brand_names,
        icon: const icons.Fruit(),
        ownerField: ownerField,
        child: SmoothAutocompleteTextField(
          focusNode: focusNode,
          controller: textController,
          autocompleteKey: autocompleteKey,
          allowEmojis: false,
          borderRadius: CIRCULAR_BORDER_RADIUS,
          padding: const EdgeInsets.symmetric(
            horizontal: LARGE_SPACE,
            vertical: SMALL_SPACE,
          ),
          textStyle: DefaultTextStyle.of(context).style,
          hintText: appLocalizations.add_basic_details_brand_names_hint,
          constraints: constraints,
          manager: AutocompleteManager(
            TaxonomyNameAutocompleter(
              taxonomyNames: <TaxonomyName>[TaxonomyName.brand],
              // for brands, language must be English
              language: OpenFoodFactsLanguage.ENGLISH,
              user: ProductQuery.getReadUser(),
              limit: 25,
              fuzziness: Fuzziness.none,
              uriHelper: ProductQuery.getUriProductHelper(
                productType: productType,
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _ProductQuantityInputWidget extends StatelessWidget {
  const _ProductQuantityInputWidget({
    required this.textController,
    required this.ownerField,
  });

  final TextEditingController textController;
  final bool ownerField;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return _BasicDetailInputWrapper(
      title: appLocalizations.quantity,
      icon: const icons.Scale.alt(),
      ownerField: ownerField,
      child: SmoothTextFormField(
        controller: textController,
        type: TextFieldTypes.PLAIN_TEXT,
        hintText: appLocalizations.add_basic_details_quantity_hint,
        hintTextStyle: SmoothTextFormField.defaultHintTextStyle(context),
      ),
    );
  }
}

class _BasicDetailInputWrapper extends StatelessWidget {
  const _BasicDetailInputWrapper({
    required this.title,
    required this.icon,
    required this.child,
    required this.ownerField,
    this.contentPadding,
  });

  final String title;
  final Widget icon;
  final Widget child;
  final bool ownerField;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return SmoothCardWithRoundedHeader(
      title: title,
      leading: icon,
      trailing: ownerField
          ? const Padding(
              padding: EdgeInsetsDirectional.only(end: 7.0),
              child: OwnerFieldIcon(),
            )
          : null,
      contentPadding: EdgeInsets.zero,
      child: Padding(
        padding: contentPadding ??
            const EdgeInsetsDirectional.all(
              MEDIUM_SPACE,
            ),
        child: child,
      ),
    );
  }
}
