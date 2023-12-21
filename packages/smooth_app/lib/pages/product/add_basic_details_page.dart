import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/input/agnostic_suggestion_manager.dart';
import 'package:smooth_app/pages/input/smooth_autocomplete_text_field.dart';
import 'package:smooth_app/pages/input/unfocus_when_tap_outside.dart';
import 'package:smooth_app/pages/product/common/product_buttons.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/pages/product/multilingual_helper.dart';
import 'package:smooth_app/pages/text_field_helper.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

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
  late final TextEditingControllerWithInitialValue _brandNameController;
  late final TextEditingControllerWithInitialValue _weightController;

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
    _weightController = TextEditingControllerWithInitialValue(
      text: MultilingualHelper.getCleanText(_product.quantity ?? ''),
    );
    _brandNameController = TextEditingControllerWithInitialValue(
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
    final Size size = MediaQuery.sizeOf(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async => _mayExitPage(saving: false),
      child: UnfocusWhenTapOutside(
        child: SmoothScaffold(
          fixKeyboard: true,
          appBar: SmoothAppBar(
            centerTitle: false,
            title: Text(appLocalizations.basic_details),
            subTitle: buildProductTitle(widget.product, appLocalizations),
          ),
          body: Form(
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
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        SizedBox(height: _heightSpace),
                        if (_multilingualHelper.isMonolingual())
                          SmoothTextFormField(
                            controller: _productNameController,
                            type: TextFieldTypes.PLAIN_TEXT,
                            hintText: appLocalizations.product_name,
                          )
                        else
                          Card(
                            child: Column(
                              children: <Widget>[
                                _multilingualHelper
                                    .getLanguageSelector(setState),
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
                        LayoutBuilder(
                          builder: (
                            final BuildContext context,
                            final BoxConstraints constraints,
                          ) =>
                              SmoothAutocompleteTextField(
                            focusNode: _focusNode,
                            controller: _brandNameController,
                            autocompleteKey: _autocompleteKey,
                            hintText: appLocalizations.brand_name,
                            constraints: constraints,
                            manager: AgnosticSuggestionManager.brand(),
                          ),
                        ),
                        SizedBox(height: _heightSpace),
                        SmoothTextFormField(
                          controller: _weightController,
                          type: TextFieldTypes.PLAIN_TEXT,
                          hintText: appLocalizations.quantity,
                        ),
                        // in order to be able to scroll suggestions
                        SizedBox(height: MediaQuery.sizeOf(context).height),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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

    if (!context.mounted) {
      return false;
    }

    AnalyticsHelper.trackProductEdit(
      AnalyticsEditEvents.basicDetails,
      _product.barcode!,
      true,
    );
    await BackgroundTaskDetails.addTask(
      minimalistProduct,
      context: context,
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
}
