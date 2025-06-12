import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/input/unfocus_field_when_tap_outside.dart';
import 'package:smooth_app/pages/product/add_basic_details/add_basic_details_name.dart';
import 'package:smooth_app/pages/product/add_basic_details/add_basic_details_quantity.dart';
import 'package:smooth_app/pages/product/common/product_buttons.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/edit_product_image_viewer.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/pages/product/multilingual_helper.dart';
import 'package:smooth_app/pages/product/owner_field_info.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_page_helpers.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_widget.dart';
import 'package:smooth_app/pages/text_field_helper.dart';
import 'package:smooth_app/query/product_query.dart';
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
  late final TextEditingController _brandsController;
  late final TextEditingControllerWithHistory _weightController;
  late final WillPopScope2Controller _willPopScope2Controller;

  final double _heightSpace = LARGE_SPACE;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final Product _product;
  late final SimpleInputPageBrandsHelper _brandsHelper;

  final ProductNameEditorProvider _productNameEditorProvider =
      ProductNameEditorProvider();

  /// Arg used to show the image preview.
  OpenFoodFactsLanguage? _imageLanguagePreview;

  @override
  void initState() {
    super.initState();
    _product = widget.product;

    _brandsHelper = SimpleInputPageBrandsHelper()..addListener(_onValueChanged);
    _brandsController = TextEditingController()..addListener(_onValueChanged);
    _productNameEditorProvider.addListener(_onValueChanged);
    _weightController = TextEditingControllerWithHistory(
      text: MultilingualHelper.getCleanText(_product.quantity ?? ''),
    )..addListener(_onValueChanged);

    _willPopScope2Controller = WillPopScope2Controller(canPop: true);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return WillPopScope2(
      onWillPop: () async => (await _mayExitPage(saving: false), null),
      controller: _willPopScope2Controller,
      child: UnfocusFieldWhenTapOutside(
        child: ChangeNotifierProvider<ProductNameEditorProvider>(
          create: (_) => _productNameEditorProvider
            ..loadLanguages(
              product: _product,
              userLanguage: ProductQuery.getLanguage(),
              imageField: ImageField.FRONT,
            ),
          child: SmoothScaffold(
            fixKeyboard: true,
            appBar: buildEditProductAppBar(
              context: context,
              title: appLocalizations.basic_details,
              product: _product,
            ),
            backgroundColor: context.lightTheme()
                ? context.extension<SmoothColorsThemeExtension>().primaryLight
                : null,
            body: Provider<Product>.value(
              value: _product,
              child: _buildForm(
                context: context,
                appLocalizations: appLocalizations,
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
      ),
    );
  }

  @override
  void dispose() {
    _brandsController.dispose();
    _weightController.dispose();
    _willPopScope2Controller.dispose();
    super.dispose();
  }

  Widget _buildForm({
    required BuildContext context,
    required AppLocalizations appLocalizations,
  }) {
    return Form(
      key: _formKey,
      child: Scrollbar(
        child: Column(
          children: <Widget>[
            EditProductImageViewer(
              visible: _imageLanguagePreview != null,
              onClose: () => setState(() => _imageLanguagePreview = null),
              imageField: ImageField.FRONT,
              language: _imageLanguagePreview,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsetsDirectional.only(
                  top: MEDIUM_SPACE,
                  start: MEDIUM_SPACE,
                  end: MEDIUM_SPACE,
                ),
                children: <Widget>[
                  AddProductNameInputWidget(
                    product: widget.product,
                    onShowImagePreview: (_, OpenFoodFactsLanguage language) =>
                        setState(() {
                      _imageLanguagePreview = language;
                    }),
                  ),
                  SizedBox(height: _heightSpace),
                  _ProductBrandsInputWidget(
                    textController: _brandsController,
                    helper: _brandsHelper,
                  ),
                  SizedBox(height: _heightSpace),
                  ProductQuantityInputWidget(
                    textController: _weightController,
                    ownerField: _isOwnerField(ProductField.QUANTITY),
                  ),
                  // in order to be able to scroll suggestions
                  const SizedBox(height: 50.0),
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
        _brandsHelper.restoreItemsBeforeLastAddition();
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

  void _onValueChanged() {
    onNextFrame(
      () => _willPopScope2Controller.canPop(!_hasProductChanged()),
    );
  }

  bool _hasProductChanged() =>
      _weightController.isDifferentFromInitialValue ||
      _brandsController.text.isNotEmpty ||
      _brandsHelper.hasChanged() ||
      _productNameEditorProvider.hasChanged();

  /// Returns a [Product] with the values from the text fields.
  Product? _getMinimalistProduct() {
    final Product result = Product(barcode: _product.barcode);
    bool hasChanged = false;

    if (_weightController.isDifferentFromInitialValue) {
      result.quantity = _weightController.text;
      hasChanged = true;
    }

    _brandsHelper.addItemsFromController(
      _brandsController,
      clearController: false,
    );
    if (_brandsHelper.getChangedProduct(result)) {
      hasChanged = true;
    }

    if (_productNameEditorProvider.hasChanged()) {
      hasChanged = true;
      result.productNameInLanguages =
          _productNameEditorProvider.getChangedProductNames();
    }

    if (hasChanged) {
      return result;
    } else {
      return null;
    }
  }

  bool _isOwnerField(
    final ProductField productField, {
    final OpenFoodFactsLanguage? language,
  }) =>
      _product.hasOwnerField(productField, language: language);
}

class _ProductBrandsInputWidget extends StatelessWidget {
  const _ProductBrandsInputWidget({
    required this.textController,
    required this.helper,
  });

  final TextEditingController textController;
  final SimpleInputPageBrandsHelper helper;

  @override
  Widget build(BuildContext context) {
    return SimpleInputWidget(
      helper: helper,
      product: context.watch<Product>(),
      controller: textController,
      displayTitle: true,
      newElementsToTop: false,
    );
  }
}
