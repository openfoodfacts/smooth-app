import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/svg_icon_chip.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';
import 'package:smooth_app/pages/product/product_field_editor.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

const IconData _doneIcon = Icons.check;
const IconData _todoIcon = Icons.add;

TextStyle? _getTitleStyle(final BuildContext context) =>
    Theme.of(context).textTheme.displaySmall;
TextStyle? _getSubtitleStyle(final BuildContext context) => null;

double _getScoreIconHeight(final BuildContext context) =>
    MediaQuery.of(context).size.height * .2;

/// Possible actions on that page.
enum EditProductAction {
  openPage,
  leaveEmpty,
  ingredients,
  category,
  nutritionFacts;
}

/// Events for each action, on the "add new product" page.
const Map<EditProductAction, AnalyticsEvent> _addNewProductEvents =
    <EditProductAction, AnalyticsEvent>{
  EditProductAction.openPage: AnalyticsEvent.openNewProductPage,
  EditProductAction.leaveEmpty: AnalyticsEvent.closeEmptyNewProductPage,
  EditProductAction.ingredients: AnalyticsEvent.ingredientsNewProductPage,
  EditProductAction.category: AnalyticsEvent.categoriesNewProductPage,
  EditProductAction.nutritionFacts: AnalyticsEvent.nutritionNewProductPage,
};

/// Events for each action, on the "fast-track edit product" page.
const Map<EditProductAction, AnalyticsEvent> _fastTrackEditEvents =
    <EditProductAction, AnalyticsEvent>{
  EditProductAction.openPage: AnalyticsEvent.openFastTrackProductEditPage,
  EditProductAction.leaveEmpty: AnalyticsEvent.closeEmptyFastTrackProductPage,
  EditProductAction.ingredients: AnalyticsEvent.ingredientsFastTrackProductPage,
  EditProductAction.category: AnalyticsEvent.categoriesFastTrackProductPage,
  EditProductAction.nutritionFacts:
      AnalyticsEvent.nutritionFastTrackProductPage,
};

/// "Create a product we couldn't find on the server" page.
class AddNewProductPage extends StatefulWidget {
  AddNewProductPage.fromBarcode(final String barcode)
      : assert(barcode != ''),
        product = Product(barcode: barcode),
        events = _addNewProductEvents,
        displayPictures = true,
        displayMisc = true,
        isLoggedInMandatory = false;

  const AddNewProductPage.fromProduct(
    this.product, {
    this.isLoggedInMandatory = true,
  })  : events = _fastTrackEditEvents,
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
  // Just one file per main image field
  final Map<ImageField, File> _uploadedImages = <ImageField, File>{};

  // Many possible files for "other" image field
  final List<File> _otherUploadedImages = <File>[];

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

  bool _alreadyPushedToHistory = false;

  bool _ecoscoreExpanded = false;

  bool _trackedPopulatedCategories = false;
  bool _trackedPopulatedIngredients = false;
  bool _trackedPopulatedNutrition = false;
  bool _trackedPopulatedImages = false;

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
      return _uploadedImages.isNotEmpty || _otherUploadedImages.isNotEmpty;
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
      Text(
        appLocalizations.new_product_title_nutriscore,
        style: _getTitleStyle(context),
      ),
      Text(
        appLocalizations.new_product_subtitle_nutriscore,
        style: _getSubtitleStyle(context),
      ),
      _buildCategoriesButton(context),
      _buildNutritionInputButton(context),
      Center(
        child: SvgIconChip(
          attribute?.iconUrl ?? ProductDialogHelper.unknownSvgNutriscore,
          height: _getScoreIconHeight(context),
        ),
      ),
    ];
  }

  List<Widget> _getEcoscoreRows(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Attribute? attribute = _getAttribute(Attribute.ATTRIBUTE_ECOSCORE);
    return <Widget>[
      Text(
        appLocalizations.new_product_title_ecoscore,
        style: _getTitleStyle(context),
      ),
      Text(
        appLocalizations.new_product_subtitle_ecoscore,
        style: _getSubtitleStyle(context),
      ),
      _buildCategoriesButton(context),
      Center(
        child: SvgIconChip(
          attribute?.iconUrl ?? ProductDialogHelper.unknownSvgEcoscore,
          height: _getScoreIconHeight(context),
        ),
      ),
      ListTile(
        title: Text(appLocalizations.new_product_additional_ecoscore),
        trailing: Icon(
          _ecoscoreExpanded ? Icons.expand_less : Icons.expand_more,
        ),
        onTap: () => setState(() => _ecoscoreExpanded = !_ecoscoreExpanded),
      ),
      if (_ecoscoreExpanded) _buildEditorButton(context, _originEditor),
      if (_ecoscoreExpanded) _buildEditorButton(context, _labelEditor),
      if (_ecoscoreExpanded) _buildEditorButton(context, _packagingEditor),
      if (_ecoscoreExpanded) _buildIngredientsButton(context),
    ];
  }

  List<Widget> _getNovaRows(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Attribute? attribute = _getAttribute(Attribute.ATTRIBUTE_NOVA);
    return <Widget>[
      Text(
        appLocalizations.new_product_title_nova,
        style: _getTitleStyle(context),
      ),
      Text(
        appLocalizations.new_product_subtitle_nova,
        style: _getSubtitleStyle(context),
      ),
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
          SvgIconChip(
            attribute?.iconUrl ?? ProductDialogHelper.unknownSvgNova,
            height: _getScoreIconHeight(context),
          ),
          Expanded(
            child: Text(
              attribute?.descriptionShort ??
                  appLocalizations.new_product_desc_nova_unknown,
              maxLines: 5,
              style: _getTitleStyle(context),
            ),
          )
        ],
      ),
    ];
  }

  List<Widget> _getImageRows(final BuildContext context) {
    final List<Widget> rows = <Widget>[];
    rows.add(
      Text(
        AppLocalizations.of(context).new_product_title_pictures,
        style: _getTitleStyle(context),
      ),
    );
    // First build rows for buttons to ask user to upload images.
    for (final ImageField imageField
        in ImageFieldSmoothieExtension.orderedAll) {
      // Always add a button to "Add other photos" because there can be multiple
      // "other photos" uploaded by the user.
      if (imageField == ImageField.OTHER) {
        rows.add(_buildImageButton(context, imageField, null));
        for (final File image in _otherUploadedImages) {
          rows.add(_buildImageButton(context, imageField, image));
        }
        continue;
      }

      // Everything else can only be uploaded once
      final File? imageFile = _uploadedImages[imageField];
      rows.add(_buildImageButton(context, imageField, imageFile));
    }
    return rows;
  }

  Widget _buildImageButton(
    BuildContext context,
    ImageField imageField,
    final File? imageFile,
  ) =>
      _MyButton(
        imageField.getAddPhotoButtonText(AppLocalizations.of(context)),
        imageFile == null ? Icons.camera_alt : _doneIcon,
        () async {
          final File? finalPhoto = await confirmAndUploadNewPicture(
            this,
            barcode: barcode,
            imageField: imageField,
            language: ProductQuery.getLanguage(),
          );
          if (finalPhoto != null) {
            setState(() {
              if (!_trackedPopulatedImages) {
                _trackedPopulatedImages = true;
                AnalyticsHelper.trackEvent(
                  AnalyticsEvent.imagesNewProductPage,
                  barcode: barcode,
                );
              }
              if (imageField == ImageField.OTHER) {
                _otherUploadedImages.add(finalPhoto);
              } else {
                _uploadedImages[imageField] = finalPhoto;
              }
            });
          }
        },
        done: imageFile != null,
      );

  Widget _buildNutritionInputButton(final BuildContext context) {
    if (!_trackedPopulatedNutrition) {
      if (_nutritionEditor.isPopulated(_product)) {
        _trackedPopulatedNutrition = true;
        AnalyticsHelper.trackEvent(
          widget.events[EditProductAction.nutritionFacts]!,
          barcode: barcode,
        );
      }
    }
    return _buildEditorButton(
      context,
      _nutritionEditor,
      forceIconData: Icons.filter_2,
      disabled: !_categoryEditor.isPopulated(_product),
    );
  }

  Widget _buildEditorButton(
    final BuildContext context,
    final ProductFieldEditor editor, {
    final IconData? forceIconData,
    final bool disabled = false,
  }) {
    final bool done = editor.isPopulated(_product);
    return _MyButton(
      editor.getLabel(AppLocalizations.of(context)),
      forceIconData ?? (done ? _doneIcon : _todoIcon),
      disabled
          ? null
          : () async => editor.edit(
                context: context,
                product: _product,
                isLoggedInMandatory: widget.isLoggedInMandatory,
              ),
      done: done,
    );
  }

  Widget _buildCategoriesButton(final BuildContext context) {
    if (!_trackedPopulatedCategories) {
      if (_categoryEditor.isPopulated(_product)) {
        _trackedPopulatedCategories = true;
        AnalyticsHelper.trackEvent(
          widget.events[EditProductAction.category]!,
          barcode: barcode,
        );
      }
    }
    return _buildEditorButton(
      context,
      _categoryEditor,
      forceIconData: Icons.filter_1,
    );
  }

  List<Widget> _getMiscRows(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return <Widget>[
      Text(
        appLocalizations.new_product_title_misc,
        style: _getTitleStyle(context),
      ),
      _buildEditorButton(context, _detailsEditor),
    ];
  }

  Widget _buildIngredientsButton(
    final BuildContext context, {
    final IconData? forceIconData,
    final bool disabled = false,
  }) {
    if (!_trackedPopulatedIngredients) {
      if (_ingredientsEditor.isPopulated(_product)) {
        _trackedPopulatedIngredients = true;
        AnalyticsHelper.trackEvent(
          widget.events[EditProductAction.ingredients]!,
          barcode: barcode,
        );
      }
    }
    return _buildEditorButton(
      context,
      _ingredientsEditor,
      forceIconData: forceIconData,
      disabled: disabled,
    );
  }
}

/// Standard button.
class _MyButton extends StatelessWidget {
  const _MyButton(
    this.label,
    this.iconData,
    this.onPressed, {
    required this.done,
  });

  final String label;
  final IconData iconData;
  final VoidCallback? onPressed;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final bool dark = themeData.brightness == Brightness.dark;
    final Color? darkGrey = Colors.grey[700];
    final Color? lightGrey = Colors.grey[300];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: SmoothLargeButtonWithIcon(
        text: label,
        icon: iconData,
        onPressed: onPressed,
        trailing: Icons.edit,
        backgroundColor: onPressed == null
            ? (dark ? darkGrey : lightGrey)
            : done
                ? Colors.green[700]
                : themeData.colorScheme.secondary,
        foregroundColor: onPressed == null
            ? (dark ? lightGrey : darkGrey)
            : done
                ? Colors.white
                : themeData.colorScheme.onSecondary,
      ),
    );
  }
}
