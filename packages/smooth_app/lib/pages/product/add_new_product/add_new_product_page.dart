import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/data_models/product_image_data.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/data_models/up_to_date_mixin.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/crop_parameters.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/preferences/user_preferences_widgets.dart';
import 'package:smooth_app/pages/product/add_new_product/product_type_radio_list_tile.dart';
import 'package:smooth_app/pages/product/add_new_product_helper.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/product_image_swipeable_view.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/v2/smooth_buttons_bar.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';
import 'package:smooth_app/widgets/will_pop_scope.dart';

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
        displayProductType = true,
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
        displayProductType = false,
        displayPictures = false,
        displayMisc = false;

  final Product product;
  final bool displayProductType;
  final bool displayPictures;
  final bool displayMisc;
  final bool isLoggedInMandatory;
  final Map<EditProductAction, AnalyticsEvent> events;

  @override
  State<AddNewProductPage> createState() => _AddNewProductPageState();
}

class _AddNewProductPageState extends State<AddNewProductPage>
    with TraceableClientMixin, UpToDateMixin {
  /// Count of "other" pictures uploaded.
  int _otherCount = 0;

  /// The behavior is different for FOOD. And we don't know about it at first.
  bool get _probablyFood =>
      (_inputProductType ?? ProductType.food) == ProductType.food;

  /// Total number of pages: depends on product type.
  int get _totalPages =>
      (_probablyFood ? 3 : 1) +
      (widget.displayProductType ? 1 : 0) +
      (_probablyFood && widget.displayMisc ? 1 : 0) +
      (widget.displayPictures ? 1 : 0);

  double get _progress => (_pageNumber + 1) / _totalPages;

  bool get _isLastPage => (_pageNumber + 1) == _totalPages;
  ProductType? _inputProductType;
  late ColorScheme _colorScheme;

  late DaoProductList _daoProductList;

  final ProductList _history = ProductList.history();

  List<String>? _appBarTitles;

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
  final PageController _pageController = PageController();

  bool _alreadyPushedToHistory = false;

  bool _environmentalScoreExpanded = false;

  int get _pageNumber =>
      _pageController.hasClients ? _pageController.page!.round() : 0;

  @override
  String get actionName => 'Opened add_new_product_page';

  @override
  void initState() {
    super.initState();
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    initUpToDate(widget.product, localDatabase);

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
        check: () => _categoryEditor.isPopulated(upToDateProduct),
      ),
      AnalyticsProductTracker(
        analyticsEvent: widget.events[EditProductAction.ingredients]!,
        barcode: barcode,
        check: () => _ingredientsEditor.isPopulated(upToDateProduct),
      ),
      AnalyticsProductTracker(
        analyticsEvent: widget.events[EditProductAction.nutritionFacts]!,
        barcode: barcode,
        check: () => _nutritionEditor.isPopulated(upToDateProduct),
      ),
      AnalyticsProductTracker(
        analyticsEvent: AnalyticsEvent.imagesNewProductPage,
        barcode: barcode,
        check: () =>
            _otherCount > 0 || _helper.isOneMainImagePopulated(upToDateProduct),
      ),
    ];
    _daoProductList = DaoProductList(localDatabase);
    AnalyticsHelper.trackProductEvent(
      widget.events[EditProductAction.openPage]!,
      product: upToDateProduct,
    );
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    if (widget.displayProductType &&
        _inputProductType != null &&
        _pageController.page != null &&
        _pageController.page! <= 1) {
      _pageController.jumpToPage(1);
    }
    setState(() {});
  }

  Future<bool> _onWillPop() async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    if (_isPopulated) {
      return true;
    }
    final bool? leaveThePage = await showDialog<bool>(
      context: context,
      builder: (final BuildContext context) => SmoothAlertDialog(
        title: appLocalizations.new_product_leave_title,
        actionsAxis: Axis.vertical,
        body: Padding(
          padding: const EdgeInsetsDirectional.only(
            bottom: MEDIUM_SPACE,
            start: MEDIUM_SPACE,
            end: MEDIUM_SPACE,
          ),
          child: Text(appLocalizations.new_product_leave_message),
        ),
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
      AnalyticsHelper.trackProductEvent(
        widget.events[EditProductAction.leaveEmpty]!,
        product: upToDateProduct,
      );
    }
    return leaveThePage ?? false;
  }

  @override
  Widget build(BuildContext context) {
    _colorScheme = Theme.of(context).colorScheme;
    _appBarTitles ??= _generateAppBarTitles(AppLocalizations.of(context));

    context.watch<LocalDatabase>();
    refreshUpToDate();
    _inputProductType ??= upToDateProduct.productType;

    _addToHistory();
    for (final AnalyticsProductTracker tracker in _trackers) {
      tracker.track();
    }

    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return WillPopScope2(
      onWillPop: () async => (await _onWillPop(), null),
      child: SmoothScaffold(
        appBar: SmoothTopBar2(
          title: _appBarTitles![_pageNumber],
          forceMultiLines: true,
          leadingAction: SmoothTopBarLeadingAction.back,
          topWidget: PreferredSize(
            preferredSize: const Size(
              double.infinity,
              10.0 + SMALL_SPACE + VERY_SMALL_SPACE,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: MEDIUM_SPACE,
                end: MEDIUM_SPACE,
                top: SMALL_SPACE,
                bottom: VERY_SMALL_SPACE,
              ),
              child: FAProgressBar(
                animatedDuration: SmoothAnimationsDuration.short,
                progressColor: lightTheme
                    ? extension.primaryDark
                    : extension.primaryNormal,
                backgroundColor: lightTheme
                    ? extension.primaryLight
                    : extension.primarySemiDark,
                currentValue: _progress,
                maxValue: 1,
              ),
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics:
                      widget.displayProductType && _inputProductType == null
                          ? const NeverScrollableScrollPhysics()
                          : null,
                  children: <Widget>[
                    if (widget.displayProductType)
                      _buildCard(_getProductTypes(context)),
                    if (widget.displayPictures)
                      _buildCard(_getImageRows(context)),
                    if (_probablyFood) _buildCard(_getNutriscoreRows(context)),
                    if (_probablyFood)
                      _buildCard(_getEnvironmentalScoreRows(context)),
                    if (_probablyFood) _buildCard(_getNovaRows(context)),
                    if (!_probablyFood) _buildCard(_getOxFRows(context)),
                    if (_probablyFood && widget.displayMisc)
                      _buildCard(_getMiscRows(context)),
                  ],
                ),
              ),
              _getButtons(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> _generateAppBarTitles(AppLocalizations appLocalizations) {
    return <String>[
      if (widget.displayProductType)
        appLocalizations.product_type_selection_subtitle,
      if (widget.displayPictures) appLocalizations.new_product_title_pictures,
      if (_probablyFood) appLocalizations.new_product_title_nutriscore,
      if (_probablyFood) appLocalizations.new_product_title_environmental_score,
      if (_probablyFood) appLocalizations.new_product_title_nova,
      if (!_probablyFood) appLocalizations.new_product_title_misc,
      if (_probablyFood && widget.displayMisc)
        appLocalizations.new_product_title_misc,
    ];
  }

  /// Adds the product to history if at least one of the fields is set.
  Future<void> _addToHistory() async {
    if (_alreadyPushedToHistory) {
      return;
    }
    if (_isPopulated) {
      upToDateProduct.productName = upToDateProduct.productName?.trim();
      upToDateProduct.brands = upToDateProduct.brands?.trim();
      await _daoProductList.push(_history, barcode);
      _alreadyPushedToHistory = true;
    }
  }

  /// Returns true if at least one field is populated.
  bool get _isPopulated {
    for (final ProductFieldEditor editor in _editors) {
      if (editor.isPopulated(upToDateProduct)) {
        return true;
      }
    }
    if (widget.displayPictures) {
      return _helper.isOneMainImagePopulated(upToDateProduct) ||
          _otherCount > 0;
    }
    return false;
  }

  Widget _buildCard(
    final List<Widget> children,
  ) =>
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(LARGE_SPACE),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      );

  Attribute? _getAttribute(final String tag) =>
      upToDateProduct.getAttributes(<String>[tag])[tag];

  Widget _getButtons() {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    String negativeLabel;
    if (_pageNumber == 0) {
      negativeLabel = appLocalizations.cancel;
    } else if (widget.displayProductType && _pageNumber == 1) {
      negativeLabel = appLocalizations.close;
    } else {
      negativeLabel = appLocalizations.previous_label;
    }

    return SmoothButtonsBar2(
      negativeButton: SmoothActionButton2(
        text: negativeLabel,
        onPressed: () async {
          if (_pageNumber == 0) {
            Navigator.of(context).maybePop();
            return;
          }
          if (widget.displayProductType && _pageNumber == 1) {
            Navigator.of(context).pop();
          } else {
            _pageController.previousPage(
              duration: SmoothAnimationsDuration.short,
              curve: Curves.easeOut,
            );
          }
        },
      ),
      positiveButton: SmoothActionButton2(
        text:
            _isLastPage ? appLocalizations.finish : appLocalizations.next_label,
        onPressed: () async {
          if (_isLastPage) {
            Navigator.of(context).pop();
            return;
          }
          if (widget.displayProductType && _pageNumber == 0) {
            if (_inputProductType == null) {
              return showDialog(
                context: context,
                builder: (final BuildContext context) => SmoothAlertDialog(
                  title: appLocalizations.product_type_selection_title,
                  body: Text(
                    appLocalizations.product_type_selection_empty,
                  ),
                  positiveAction: SmoothActionButton(
                    text: appLocalizations.okay,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              );
            }
            await BackgroundTaskDetails.addTask(
              Product(barcode: barcode)..productType = _inputProductType,
              context: context,
              stamp: BackgroundTaskDetailsStamp.productType,
              productType: _inputProductType,
            );
          }
          _pageController.nextPage(
            duration: SmoothAnimationsDuration.short,
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }

  List<Widget> _getNutriscoreRows(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Attribute? attribute = _getAttribute(Attribute.ATTRIBUTE_NUTRISCORE);
    return <Widget>[
      AddNewProductSubTitle(appLocalizations.new_product_subtitle_nutriscore),
      const SizedBox(height: 15.0),
      _buildCategoriesButton(context),
      AddNewProductButton(
        appLocalizations.nutritional_facts_input_button_label,
        Icons.filter_2,
        // deactivated when the categories were not set beforehand
        !_categoryEditor.isPopulated(upToDateProduct)
            ? null
            : () async => NutritionPageLoaded.showNutritionPage(
                  product: upToDateProduct,
                  isLoggedInMandatory: widget.isLoggedInMandatory,
                  context: context,
                ),
        done: _nutritionEditor.isPopulated(upToDateProduct),
      ),
      _buildIngredientsButton(
        context,
        forceIconData: Icons.filter_3,
        disabled: (!_categoryEditor.isPopulated(upToDateProduct)) ||
            (!_nutritionEditor.isPopulated(upToDateProduct)),
      ),
      Center(
        child: AddNewProductScoreIcon(
          iconUrl: attribute?.iconUrl,
          defaultIconUrl: ProductDialogHelper.unknownSvgNutriscore,
        ),
      ),
    ];
  }

  List<Widget> _getEnvironmentalScoreRows(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();

    final Attribute? attribute = _getAttribute(Attribute.ATTRIBUTE_ECOSCORE);
    return <Widget>[
      const SizedBox(height: 15.0),
      AddNewProductSubTitle(
          appLocalizations.new_product_subtitle_environmental_score),
      const SizedBox(height: 15.0),
      _buildCategoriesButton(context),
      Center(
        child: AddNewProductScoreIcon(
          iconUrl: attribute?.iconUrl,
          defaultIconUrl: ProductDialogHelper.unknownSvgEnvironmentalScore,
        ),
      ),
      const SizedBox(height: 15.0),
      InkWell(
        borderRadius: ROUNDED_BORDER_RADIUS,
        onTap: () {
          setState(
              () => _environmentalScoreExpanded = !_environmentalScoreExpanded);
        },
        child: Ink(
          padding: const EdgeInsets.symmetric(
            vertical: BALANCED_SPACE,
            horizontal: 15.0,
          ),
          decoration: BoxDecoration(
            borderRadius: ROUNDED_BORDER_RADIUS,
            color: context.lightTheme()
                ? extension.primaryNormal
                : extension.primaryMedium,
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.filter_2,
                color: _colorScheme.onPrimary,
              ),
              const SizedBox(width: 15.0),
              Flexible(
                child: Text(
                  appLocalizations.new_product_additional_environmental_score,
                  style: TextStyle(
                    color: _colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 5.0),
              Icon(
                _environmentalScoreExpanded
                    ? Icons.expand_less
                    : Icons.expand_more,
                color: _colorScheme.onPrimary,
              ),
            ],
          ),
        ),
      ),
      if (_environmentalScoreExpanded)
        AddNewProductEditorButton(
          upToDateProduct,
          _originEditor,
          isLoggedInMandatory: widget.isLoggedInMandatory,
        ),
      if (_environmentalScoreExpanded)
        AddNewProductEditorButton(
          upToDateProduct,
          _labelEditor,
          isLoggedInMandatory: widget.isLoggedInMandatory,
        ),
      if (_environmentalScoreExpanded)
        AddNewProductEditorButton(
          upToDateProduct,
          _packagingEditor,
          isLoggedInMandatory: widget.isLoggedInMandatory,
        ),
      if (_environmentalScoreExpanded) _buildIngredientsButton(context),
    ];
  }

  List<Widget> _getNovaRows(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Attribute? attribute = _getAttribute(Attribute.ATTRIBUTE_NOVA);
    return <Widget>[
      AddNewProductSubTitle(appLocalizations.new_product_subtitle_nova),
      const SizedBox(height: 15.0),
      _buildCategoriesButton(context),
      _buildIngredientsButton(
        context,
        forceIconData: Icons.filter_2,
        disabled: !_categoryEditor.isPopulated(upToDateProduct),
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

  List<Widget> _getProductTypes(final BuildContext context) {
    final List<Widget> rows = <Widget>[];
    for (final ProductType productType in ProductType.values) {
      rows.add(
        ProductTypeRadioListTile(
          productType: productType,
          checked: productType == _inputProductType,
          onChanged: (ProductType value) {
            setState(() => _inputProductType = value);
          },
        ),
      );
    }
    return rows;
  }

  /// More compact, for non-FOOD only.
  List<Widget> _getOxFRows(final BuildContext context) {
    return <Widget>[
      AddNewProductEditorButton(
        upToDateProduct,
        _categoryEditor,
        isLoggedInMandatory: widget.isLoggedInMandatory,
      ),
      if (_inputProductType != ProductType.product)
        AddNewProductEditorButton(
          upToDateProduct,
          _ingredientsEditor,
          isLoggedInMandatory: widget.isLoggedInMandatory,
        ),
      if (_inputProductType == ProductType.petFood)
        AddNewProductEditorButton(
          upToDateProduct,
          _nutritionEditor,
          isLoggedInMandatory: widget.isLoggedInMandatory,
        ),
      _buildDetailsButton(context),
    ];
  }

  List<Widget> _getImageRows(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<Widget> rows = <Widget>[];
    rows.add(const SizedBox(height: 15.0));
    rows.add(
      AddNewProductSubTitle(
          appLocalizations.new_product_title_pictures_details),
    );

    // Main images first.
    final List<ProductImageData> productImagesData = getProductMainImagesData(
      upToDateProduct,
      ProductQuery.getLanguage(),
    );
    for (final ProductImageData data in productImagesData) {
      // Everything else can only be uploaded once
      rows.add(_buildMainImageButton(context, upToDateProduct, data));
      rows.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: BALANCED_SPACE),
          child: UserPreferencesListItemDivider(),
        ),
      );
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
          final CropParameters? cropParameters =
              await confirmAndUploadNewPicture(
            context,
            barcode: barcode,
            productType: upToDateProduct.productType,
            imageField: ImageField.OTHER,
            language: ProductQuery.getLanguage(),
            isLoggedInMandatory: widget.isLoggedInMandatory,
          );
          if (cropParameters != null) {
            setState(() => ++_otherCount);
          }
        },
        done: done,
        showTrailing: false,
      );

  /// Button specific to one of the main 4 images.
  Widget _buildMainImageButton(
    final BuildContext context,
    final Product product,
    final ProductImageData productImageData,
  ) {
    final bool done = _helper.isMainImagePopulated(productImageData, product);
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
            product: upToDateProduct,
            isLoggedInMandatory: widget.isLoggedInMandatory,
          ),
        ),
      ),
      done: done,
      showTrailing: false,
    );
  }

  Widget _buildCategoriesButton(final BuildContext context) =>
      AddNewProductEditorButton(
        upToDateProduct,
        _categoryEditor,
        forceIconData: Icons.filter_1,
        isLoggedInMandatory: widget.isLoggedInMandatory,
      );

  List<Widget> _getMiscRows(final BuildContext context) => <Widget>[
        AddNewProductTitle(
          AppLocalizations.of(context).new_product_title_misc,
        ),
        _buildDetailsButton(context),
      ];

  Widget _buildDetailsButton(final BuildContext context) =>
      AddNewProductEditorButton(
        upToDateProduct,
        _detailsEditor,
        isLoggedInMandatory: widget.isLoggedInMandatory,
      );

  Widget _buildIngredientsButton(
    final BuildContext context, {
    final IconData? forceIconData,
    final bool disabled = false,
  }) =>
      AddNewProductEditorButton(
        upToDateProduct,
        _ingredientsEditor,
        forceIconData: forceIconData,
        disabled: disabled,
        isLoggedInMandatory: widget.isLoggedInMandatory,
      );
}
