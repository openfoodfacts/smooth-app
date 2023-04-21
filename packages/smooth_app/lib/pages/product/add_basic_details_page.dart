import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/language_selector.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/pages/text_field_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Input of a product's basic details, like name, quantity and brands.
///
/// There are 2 versions of the product name input:
/// 1. the old one - only one name per product
/// 2. the multilingual one
/// Typically, the old version will be used with "old" data, that have not
/// downloaded yet the "recent" [ProductField.NAME_ALL_LANGUAGES] field.
class AddBasicDetailsPage extends StatefulWidget {
  const AddBasicDetailsPage(
    this.product, {
    this.isLoggedInMandatory = true,
  });

  final Product product;
  final bool isLoggedInMandatory;

  @override
  State<AddBasicDetailsPage> createState() => _AddBasicDetailsPageState();
}

class _AddBasicDetailsPageState extends State<AddBasicDetailsPage> {
  final TextEditingController _productNameController = TextEditingController();
  late final TextEditingControllerWithInitialValue _brandNameController;
  late final TextEditingControllerWithInitialValue _weightController;

  final double _heightSpace = LARGE_SPACE;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final Product _product;

  /// Current language; only relevant/valid if _names is not empty.
  late OpenFoodFactsLanguage _currentLanguage;

  /// Current product name translations.
  final Map<OpenFoodFactsLanguage, String> _names =
      <OpenFoodFactsLanguage, String>{};

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _weightController = TextEditingControllerWithInitialValue(
      text: _getCleanName(_product.quantity ?? ''),
    );
    _brandNameController = TextEditingControllerWithInitialValue(
      text: _formatProductBrands(_product.brands),
    );
    // checking if we use the multilingual version...
    if (_product.productNameInLanguages != null) {
      for (final OpenFoodFactsLanguage language
          in _product.productNameInLanguages!.keys) {
        final String name =
            _getCleanName(_product.productNameInLanguages![language]);
        if (name.isNotEmpty) {
          _names[language] = name;
        }
      }
      if (_names.isNotEmpty) {
        final OpenFoodFactsLanguage language = ProductQuery.getLanguage()!;
        if (_names.containsKey(language)) {
          // best choice
          _currentLanguage = language;
        } else {
          // fallback
          _currentLanguage = _names.keys.first;
        }
        _productNameController.text = _names[_currentLanguage] ?? '';
      }
    }
    // Fallback: we may have old data where there are no translations.
    if (_names.isEmpty) {
      _productNameController.text = _product.productName ?? '';
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _weightController.dispose();
    _brandNameController.dispose();
    super.dispose();
  }

  String _formatProductBrands(String? text) =>
      _getCleanName(text == null ? '' : formatProductBrands(text));

  String _getCleanName(final String? name) => (name ?? '').trim();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async => _mayExitPage(saving: false),
      child: SmoothScaffold(
        appBar: SmoothAppBar(
          title: Text(appLocalizations.basic_details),
          subTitle: widget.product.productName != null
              ? Text(widget.product.productName!,
                  overflow: TextOverflow.ellipsis, maxLines: 1)
              : null,
        ),
        body: Form(
          key: _formKey,
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
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Column(
                  children: <Widget>[
                    Text(
                      appLocalizations.barcode_barcode(_product.barcode!),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: _heightSpace),
                    if (_names.isEmpty)
                      SmoothTextFormField(
                        controller: _productNameController,
                        type: TextFieldTypes.PLAIN_TEXT,
                        hintText: appLocalizations.product_name,
                      )
                    else
                      Card(
                        child: Column(
                          children: [
                            LanguageSelector(
                              setLanguage: (
                                final OpenFoodFactsLanguage? newLanguage,
                              ) async {
                                if (newLanguage == null) {
                                  return;
                                }
                                if (_currentLanguage == newLanguage) {
                                  return;
                                }
                                _saveCurrentName();
                                setState(() {
                                  _currentLanguage = newLanguage;
                                  _names[_currentLanguage] ??= '';
                                  _productNameController.text =
                                      _names[_currentLanguage]!;
                                });
                              },
                              selectedLanguages: _names.keys,
                              displayedLanguage: _currentLanguage,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SmoothTextFormField(
                                controller: _productNameController,
                                type: TextFieldTypes.PLAIN_TEXT,
                                hintText: appLocalizations.product_name,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: _heightSpace),
                    SmoothTextFormField(
                      controller: _brandNameController,
                      type: TextFieldTypes.PLAIN_TEXT,
                      hintText: appLocalizations.brand_name,
                    ),
                    SizedBox(height: _heightSpace),
                    SmoothTextFormField(
                      controller: _weightController,
                      type: TextFieldTypes.PLAIN_TEXT,
                      hintText: appLocalizations.quantity,
                    ),
                    SizedBox(height: _heightSpace),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LARGE_SPACE,
                ),
                child: SmoothActionButtonsBar(
                  negativeAction: SmoothActionButton(
                    text: appLocalizations.cancel,
                    onPressed: () async => _exitPage(
                      await _mayExitPage(saving: false),
                    ),
                  ),
                  positiveAction: SmoothActionButton(
                    text: appLocalizations.save,
                    onPressed: () async => _exitPage(
                      await _mayExitPage(saving: true),
                    ),
                  ),
                ),
              ),
            ],
          ),
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

  /// Saves the current input for the current language.
  void _saveCurrentName() =>
      _names[_currentLanguage] = _productNameController.text;

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

    if (widget.isLoggedInMandatory) {
      if (!mounted) {
        return false;
      }
      final bool loggedIn = await ProductRefresher().checkIfLoggedIn(context);
      if (!loggedIn) {
        return false;
      }
    }

    AnalyticsHelper.trackProductEdit(
      AnalyticsEditEvents.basicDetails,
      _product.barcode!,
      true,
    );
    await BackgroundTaskDetails.addTask(
      minimalistProduct,
      widget: this,
      stamp: BackgroundTaskDetailsStamp.basicDetails,
    );

    return true;
  }

  /// Returns a [Product] with the values from the text fields.
  Product? _getMinimalistProduct() {
    Product? result;

    Product getBasicProduct() => Product(barcode: _product.barcode);

    if (_weightController.valueHasChanged) {
      result ??= getBasicProduct();
      result.quantity = _weightController.text;
    }
    if (_brandNameController.valueHasChanged) {
      result ??= getBasicProduct();
      result.brands = _formatProductBrands(_brandNameController.text);
    }
    if (_names.isEmpty) {
      if (_getCleanName(_productNameController.text) !=
          _getCleanName(_product.productName)) {
        result ??= getBasicProduct();
        result.productName = _productNameController.text;
      }
    } else {
      _saveCurrentName();
      final Map<OpenFoodFactsLanguage, String>? newNames =
          _getNewNamesIfChanged();
      if (newNames != null) {
        result ??= getBasicProduct();
        result.productNameInLanguages = newNames;
      }
    }
    return result;
  }

  /// Returns all the new names, if any change happened.
  Map<OpenFoodFactsLanguage, String>? _getNewNamesIfChanged() {
    bool changed = false;
    final Map<OpenFoodFactsLanguage, String> result =
        <OpenFoodFactsLanguage, String>{};
    final Map<OpenFoodFactsLanguage, String> oldNames =
        _product.productNameInLanguages!;

    void setNewName(final OpenFoodFactsLanguage language) {
      final String newName = _getCleanName(_names[language]);
      final String oldName = _getCleanName(oldNames[language]);
      if (newName != oldName) {
        changed = true;
      }
      // For the record: if name is empty, will remove the translation (sometimes).
      result[language] = newName;
    }

    // setting new names, comparing them to old names for change flag.
    _names.keys.forEach(setNewName);
    // double-checking old names: have some old names been removed?
    oldNames.keys.forEach(setNewName);

    if (!changed) {
      return null;
    }
    return result;
  }
}
