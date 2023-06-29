import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/add_new_product_helper.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/product_image_swipeable_view.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// "Create a product we couldn't find on the server" page.
class AddNewProductPage extends StatefulWidget {
  AddNewProductPage.fromBarcode(final String barcode)
      : assert(barcode != ''),
        product = Product(barcode: barcode),
        events = const <EditProductAction, AnalyticsEvent>{
          EditProductAction.openPage: AnalyticsEvent.openNewProductPage,
          EditProductAction.leaveEmpty: AnalyticsEvent.closeEmptyNewProductPage,
          EditProductAction.ingredients:
              AnalyticsEvent.ingredientsNewProductPage,
          EditProductAction.category: AnalyticsEvent.categoriesNewProductPage,
          EditProductAction.nutritionFacts:
              AnalyticsEvent.nutritionNewProductPage,
        },
        displayPictures = true,
        displayMisc = true,
        isLoggedInMandatory = false;

  const AddNewProductPage.fromProduct(
    this.product, {
    required this.isLoggedInMandatory,
  })  : events = const <EditProductAction, AnalyticsEvent>{
          EditProductAction.openPage:
              AnalyticsEvent.openFastTrackProductEditPage,
          EditProductAction.leaveEmpty:
              AnalyticsEvent.closeEmptyFastTrackProductPage,
          EditProductAction.ingredients:
              AnalyticsEvent.ingredientsFastTrackProductPage,
          EditProductAction.category:
              AnalyticsEvent.categoriesFastTrackProductPage,
          EditProductAction.nutritionFacts:
              AnalyticsEvent.nutritionFastTrackProductPage,
        },
        displayPictures = false,
        displayMisc = false;

  final Product product;
  final bool displayPictures;
  final bool displayMisc;
  final bool isLoggedInMandatory;
  final Map<EditProductAction, AnalyticsEvent> events;

  @override
  State<AddNewProductPage> createState() => _AddNewProductPageState();
}

class _AddNewProductPageState extends State<AddNewProductPage>
    with TraceableClientMixin {
  /// Count of "other" pictures uploaded.
  int _otherCount = 0;

  late Product _product;
  late final Product _initialProduct;
  late final LocalDatabase _localDatabase;
  late DaoProductList _daoProductList;

  final ProductList _history = ProductList.history();

  final ProductFieldEditor _packagingEditor = ProductFieldPackagingEditor();
  final ProductFieldEditor _ingredientsEditor =
      ProductFieldOcrIngredientEditor();
  final ProductFieldEditor _originEditor =
      ProductFieldSimpleEditor(SimpleInputPageOriginHelper());
  final ProductFieldEditor _categoryEditor =
      ProductFieldSimpleEditor(SimpleInputPageCategoryHelper());
  final ProductFieldEditor _labelEditor =
      ProductFieldSimpleEditor(SimpleInputPageLabelHelper());
  final ProductFieldEditor _detailsEditor = ProductFieldDetailsEditor();
  final ProductFieldEditor _nutritionEditor = ProductFieldNutritionEditor();
  late final List<ProductFieldEditor> _editors;
  late final List<AnalyticsProductTracker> _trackers;
  final AddNewProductHelper _helper = AddNewProductHelper();

  bool _alreadyPushedToHistory = false;

  bool _ecoscoreExpanded = false;

  @override
  String get traceName => 'Opened add_new_product_page';

  @override
  String get traceTitle => 'add_new_product_page';

  @override
  void initState() {
    super.initState();
    _editors = <ProductFieldEditor>[
      _packagingEditor,
      _ingredientsEditor,
      _originEditor,
      _categoryEditor,
      _labelEditor,
      _detailsEditor,
      _nutritionEditor,
    ];
    _trackers = <AnalyticsProductTracker>[
      AnalyticsProductTracker(
        analyticsEvent: widget.events[EditProductAction.category]!,
        barcode: barcode,
        check: () => _categoryEditor.isPopulated(_product),
      ),
      AnalyticsProductTracker(
        analyticsEvent: widget.events[EditProductAction.ingredients]!,
        barcode: barcode,
        check: () => _ingredientsEditor.isPopulated(_product),
      ),
      AnalyticsProductTracker(
        analyticsEvent: widget.events[EditProductAction.nutritionFacts]!,
        barcode: barcode,
        check: () => _nutritionEditor.isPopulated(_product),
      ),
      AnalyticsProductTracker(
        analyticsEvent: AnalyticsEvent.imagesNewProductPage,
        barcode: barcode,
        check: () =>
            _otherCount > 0 || _helper.isOneMainImagePopulated(_product),
      ),
    ];
    _initialProduct = widget.product;
    _localDatabase = context.read<LocalDatabase>();
    _localDatabase.upToDate.showInterest(barcode);
    _daoProductList = DaoProductList(_localDatabase);
    AnalyticsHelper.trackEvent(
      widget.events[EditProductAction.openPage]!,
      barcode: barcode,
    );
  }

  @override
  void dispose() {
    _localDatabase.upToDate.loseInterest(barcode);
    super.dispose();
  }

  String get barcode => widget.product.barcode!;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    _product = _localDatabase.upToDate.getLocalUpToDate(_initialProduct);

    _addToHistory();
    for (final AnalyticsProductTracker tracker in _trackers) {
      tracker.track();
    }

    return WillPopScope(
      onWillPop: () async {
        if (_isPopulated) {
          return true;
        }
        final bool? leaveThePage = await showDialog<bool>(
          context: context,
          builder: (final BuildContext context) => SmoothAlertDialog(
            title: appLocalizations.new_product,
            actionsAxis: Axis.vertical,
            body: Text(appLocalizations.new_product_leave_message),
            positiveAction: SmoothActionButton(
              text: appLocalizations.yes,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            negativeAction: SmoothActionButton(
              text: appLocalizations.cancel,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
        );
        if (leaveThePage == true) {
          AnalyticsHelper.trackEvent(
            widget.events[EditProductAction.leaveEmpty]!,
            barcode: barcode,
          );
        }
        return leaveThePage ?? false;
      },
      child: SmoothScaffold(
        appBar: SmoothAppBar(
          title: ListTile(
            title: Text(_product.productName ?? appLocalizations.new_product),
            subtitle: Text(barcode),
          ),
        ),
        body: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: VERY_LARGE_SPACE,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (widget.displayPictures) _buildCard(_getImageRows(context)),
                _buildCard(_getNutriscoreRows(context)),
                _buildCard(_getEcoscoreRows(context)),
                _buildCard(_getNovaRows(context)),
                if (widget.displayMisc) _buildCard(_getMiscRows(context)),
                const SizedBox(height: MINIMUM_TOUCH_SIZE),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Adds the product to history if at least one of the fields is set.
  Future<void> _addToHistory() async {
    if (_alreadyPushedToHistory) {
      return;
    }
    if (_isPopulated) {
      _product.productName = _product.productName?.trim();
      _product.brands = _product.brands?.trim();
      await _daoProductList.push(_history, barcode);
      _alreadyPushedToHistory = true;
    }
  }

  /// Returns true if at least one field is populated.
  bool get _isPopulated {
    for (final ProductFieldEditor editor in _editors) {
      if (editor.isPopulated(_product)) {
        return true;
      }
    }
    if (widget.displayPictures) {
      return _helper.isOneMainImagePopulated(_product) || _otherCount > 0;
    }
    return false;
  }

  Widget _buildCard(
    final List<Widget> children,
  ) =>
      SmoothCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );

  Attribute? _getAttribute(final String tag) =>
      _product.getAttributes(<String>[tag])[tag];

  List<Widget> _getNutriscoreRows(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Attribute? attribute = _getAttribute(Attribute.ATTRIBUTE_NUTRISCORE);
    return <Widget>[
      AddNewProductTitle(appLocalizations.new_product_title_nutriscore),
      AddNewProductSubTitle(appLocalizations.new_product_subtitle_nutriscore),
      _buildCategoriesButton(context),
      AddNewProductButton(
        AppLocalizations.of(context).nutritional_facts_input_button_label,
        Icons.filter_2,
        // deactivated when the categories were not set beforehand
        !_categoryEditor.isPopulated(_product)
            ? null
            : () async => NutritionPageLoaded.showNutritionPage(
                  product: _product,
                  isLoggedInMandatory: widget.isLoggedInMandatory,
                  context: context,
                ),
        done: _nutritionEditor.isPopulated(_product),
      ),
      Center(
        child: AddNewProductScoreIcon(
          iconUrl: attribute?.iconUrl,
          defaultIconUrl: ProductDialogHelper.unknownSvgNutriscore,
        ),
      ),
    ];
  }

  List<Widget> _getEcoscoreRows(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Attribute? attribute = _getAttribute(Attribute.ATTRIBUTE_ECOSCORE);
    return <Widget>[
      AddNewProductTitle(appLocalizations.new_product_title_ecoscore),
      AddNewProductSubTitle(appLocalizations.new_product_subtitle_ecoscore),
      _buildCategoriesButton(context),
      Center(
        child: AddNewProductScoreIcon(
          iconUrl: attribute?.iconUrl,
          defaultIconUrl: ProductDialogHelper.unknownSvgEcoscore,
        ),
      ),
      ListTile(
        title: Text(appLocalizations.new_product_additional_ecoscore),
        trailing: Icon(
          _ecoscoreExpanded ? Icons.expand_less : Icons.expand_more,
        ),
        onTap: () => setState(() => _ecoscoreExpanded = !_ecoscoreExpanded),
      ),
      if (_ecoscoreExpanded)
        AddNewProductEditorButton(
          _product,
          _originEditor,
          isLoggedInMandatory: widget.isLoggedInMandatory,
        ),
      if (_ecoscoreExpanded)
        AddNewProductEditorButton(
          _product,
          _labelEditor,
          isLoggedInMandatory: widget.isLoggedInMandatory,
        ),
      if (_ecoscoreExpanded)
        AddNewProductEditorButton(
          _product,
          _packagingEditor,
          isLoggedInMandatory: widget.isLoggedInMandatory,
        ),
      if (_ecoscoreExpanded) _buildIngredientsButton(context),
    ];
  }

  List<Widget> _getNovaRows(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Attribute? attribute = _getAttribute(Attribute.ATTRIBUTE_NOVA);
    return <Widget>[
      AddNewProductTitle(appLocalizations.new_product_title_nova),
      AddNewProductSubTitle(appLocalizations.new_product_subtitle_nova),
      _buildCategoriesButton(context),
      _buildIngredientsButton(
        context,
        forceIconData: Icons.filter_2,
        disabled: !_categoryEditor.isPopulated(_product),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AddNewProductScoreIcon(
            iconUrl: attribute?.iconUrl,
            defaultIconUrl: ProductDialogHelper.unknownSvgNova,
          ),
          Expanded(
            child: AddNewProductTitle(
              attribute?.descriptionShort ??
                  appLocalizations.new_product_desc_nova_unknown,
              maxLines: 5,
            ),
          )
        ],
      ),
    ];
  }

  List<Widget> _getImageRows(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<Widget> rows = <Widget>[];
    rows.add(AddNewProductTitle(appLocalizations.new_product_title_pictures));
    // Main 4 images first.
    final List<ProductImageData> productImagesData = getProductMainImagesData(
      _product,
      ProductQuery.getLanguage(),
      includeOther: false,
    );
    for (final ProductImageData data in productImagesData) {
      // Everything else can only be uploaded once
      rows.add(_buildMainImageButton(context, data));
    }
    // Then all the OTHERs.
    rows.add(_buildOtherImageButton(context, done: false));
    for (int i = 0; i < _otherCount; i++) {
      rows.add(_buildOtherImageButton(context, done: true));
    }
    return rows;
  }

  /// Button specific to OTHER images.
  Widget _buildOtherImageButton(
    final BuildContext context, {
    required final bool done,
  }) =>
      AddNewProductButton(
        ImageField.OTHER.getAddPhotoButtonText(AppLocalizations.of(context)),
        done
            ? AddNewProductButton.doneIconData
            : AddNewProductButton.cameraIconData,
        () async {
          final File? finalPhoto = await confirmAndUploadNewPicture(
            this,
            barcode: barcode,
            imageField: ImageField.OTHER,
            language: ProductQuery.getLanguage(),
            isLoggedInMandatory: widget.isLoggedInMandatory,
          );
          if (finalPhoto != null) {
            setState(() => ++_otherCount);
          }
        },
        done: done,
      );

  /// Button specific to one of the main 4 images.
  Widget _buildMainImageButton(
    final BuildContext context,
    final ProductImageData productImageData,
  ) {
    final bool done = _helper.isMainImagePopulated(productImageData, barcode);
    return AddNewProductButton(
      productImageData.imageField
          .getAddPhotoButtonText(AppLocalizations.of(context)),
      done
          ? AddNewProductButton.doneIconData
          : AddNewProductButton.cameraIconData,
      () async => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => ProductImageSwipeableView.imageField(
            imageField: productImageData.imageField,
            product: _product,
            isLoggedInMandatory: widget.isLoggedInMandatory,
          ),
        ),
      ),
      done: done,
    );
  }

  Widget _buildCategoriesButton(final BuildContext context) =>
      AddNewProductEditorButton(
        _product,
        _categoryEditor,
        forceIconData: Icons.filter_1,
        isLoggedInMandatory: widget.isLoggedInMandatory,
      );

  List<Widget> _getMiscRows(final BuildContext context) => <Widget>[
        AddNewProductTitle(
          AppLocalizations.of(context).new_product_title_misc,
        ),
        AddNewProductEditorButton(
          _product,
          _detailsEditor,
          isLoggedInMandatory: widget.isLoggedInMandatory,
        ),
      ];

  Widget _buildIngredientsButton(
    final BuildContext context, {
    final IconData? forceIconData,
    final bool disabled = false,
  }) =>
      AddNewProductEditorButton(
        _product,
        _ingredientsEditor,
        forceIconData: forceIconData,
        disabled: disabled,
        isLoggedInMandatory: widget.isLoggedInMandatory,
      );
}
