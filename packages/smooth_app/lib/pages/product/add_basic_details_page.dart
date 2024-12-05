import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
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

    Widget child = _buildForm(appLocalizations, context);
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
          ),
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

  Form _buildForm(AppLocalizations appLocalizations, BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Form(
      key: _formKey,
      child: Scrollbar(
        child: ListView(
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.topStart,
              child: ProductImageCarousel(
                _product,
                height: size.height * 0.20,
              ),
            ),
            SizedBox(height: _heightSpace),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    appLocalizations.barcode_barcode(_product.barcode!),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: _heightSpace),
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
                        return SmoothTextFormField(
                          suffixIcon: _getOwnerFieldIcon(
                            ProductField.NAME,
                          ),
                          controller: _productNameController,
                          type: TextFieldTypes.PLAIN_TEXT,
                          hintText: appLocalizations.product_name,
                          spellCheckConfiguration: (prefs.getFlag(
                                          UserPreferencesDevMode
                                              .userPreferencesFlagSpellCheckerOnOcr) ??
                                      false) &&
                                  (Platform.isAndroid || Platform.isIOS)
                              ? const SpellCheckConfiguration()
                              : const SpellCheckConfiguration.disabled(),
                        );
                      } else {
                        return Card(
                          child: Column(
                            children: <Widget>[
                              _multilingualHelper.getLanguageSelector(
                                setState: setState,
                                product: _product,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SmoothTextFormField(
                                  suffixIcon: _getOwnerFieldIcon(
                                    ProductField.NAME_IN_LANGUAGES,
                                    language: _multilingualHelper
                                        .getCurrentLanguage(),
                                  ),
                                  controller: _productNameController,
                                  type: TextFieldTypes.PLAIN_TEXT,
                                  hintText: appLocalizations.product_name,
                                  spellCheckConfiguration: (prefs.getFlag(
                                                  UserPreferencesDevMode
                                                      .userPreferencesFlagSpellCheckerOnOcr) ??
                                              false) &&
                                          (Platform.isAndroid || Platform.isIOS)
                                      ? const SpellCheckConfiguration()
                                      : const SpellCheckConfiguration
                                          .disabled(),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: _heightSpace),
                  LayoutBuilder(
                    builder: (
                      final BuildContext context,
                      final BoxConstraints constraints,
                    ) =>
                        SmoothAutocompleteTextField(
                      focusNode: _focusNode,
                      controller: _brandNameController,
                      autocompleteKey: _autocompleteKey,
                      allowEmojis: false,
                      hintText: appLocalizations.brand_name,
                      constraints: constraints,
                      suffixIcon: _getOwnerFieldIcon(
                        ProductField.BRANDS,
                      ),
                      manager: AutocompleteManager(
                        TaxonomyNameAutocompleter(
                          taxonomyNames: <TaxonomyName>[TaxonomyName.brand],
                          // for brands, language must be English
                          language: OpenFoodFactsLanguage.ENGLISH,
                          user: ProductQuery.getReadUser(),
                          limit: 25,
                          fuzziness: Fuzziness.none,
                          uriHelper: ProductQuery.getUriProductHelper(
                            productType: _product.productType,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: _heightSpace),
                  SmoothTextFormField(
                    suffixIcon: _getOwnerFieldIcon(
                      ProductField.QUANTITY,
                    ),
                    controller: _weightController,
                    type: TextFieldTypes.PLAIN_TEXT,
                    hintText: appLocalizations.quantity,
                  ),
                  // in order to be able to scroll suggestions
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ],
        ),
      ),
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

  Widget? _getOwnerFieldIcon(
    final ProductField productField, {
    final OpenFoodFactsLanguage? language,
  }) =>
      _isOwnerField(productField, language: language)
          ? const OwnerFieldIcon()
          : null;

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
