import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_list.dart';
import 'package:smooth_app/database/dao_product_list.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/svg_icon_chip.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/image_field_extension.dart';
import 'package:smooth_app/pages/image_crop_page.dart';
import 'package:smooth_app/pages/product/add_basic_details_page.dart';
import 'package:smooth_app/pages/product/common/product_dialog_helper.dart';
import 'package:smooth_app/pages/product/nutrition_page_loaded.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

const IconData _doneIcon = Icons.check;
const IconData _todoIcon = Icons.add;

TextStyle? _getTitleStyle(final BuildContext context) =>
    Theme.of(context).textTheme.displaySmall;
TextStyle? _getSubtitleStyle(final BuildContext context) => null;

double _getScoreIconHeight(final BuildContext context) =>
    MediaQuery.of(context).size.height * .2;

/// Returns true if the [field] is valid (= not empty).
bool _isProductFieldValid(final String? field) =>
    field != null && field.trim().isNotEmpty;

/// "Create a product we couldn't find on the server" page.
class AddNewProductPage extends StatefulWidget {
  const AddNewProductPage({
    required this.barcode,
  }) : assert(barcode != '');

  final String barcode;

  @override
  State<AddNewProductPage> createState() => _AddNewProductPageState();
}

class _AddNewProductPageState extends State<AddNewProductPage> {
  // Just one file per main image field
  final Map<ImageField, File> _uploadedImages = <ImageField, File>{};

  // Many possible files for "other" image field
  final List<File> _otherUploadedImages = <File>[];

  late Product _product;
  late final Product _initialProduct;
  late final LocalDatabase _localDatabase;
  late DaoProductList _daoProductList;

  final ProductList _history = ProductList.history();

  bool get _nutritionFactsAdded => _product.nutriments?.isEmpty() == false;

  bool get _categoriesAdded =>
      _product.categoriesTagsInLanguages?.isEmpty == false;

  bool get _basicDetailsAdded =>
      _isProductFieldValid(_product.productName) ||
      _isProductFieldValid(_product.brands);

  bool _alreadyPushedToHistory = false;

  @override
  void initState() {
    super.initState();
    _initialProduct = Product(barcode: barcode);
    _localDatabase = context.read<LocalDatabase>();
    _localDatabase.upToDate.showInterest(barcode);
    _daoProductList = DaoProductList(_localDatabase);
  }

  @override
  void dispose() {
    _localDatabase.upToDate.loseInterest(barcode);
    super.dispose();
  }

  String get barcode => widget.barcode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    context.watch<LocalDatabase>();
    _product = _localDatabase.upToDate.getLocalUpToDate(_initialProduct);

    _addToHistory();

    return SmoothScaffold(
      appBar: AppBar(
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
              _buildCard(_getNutriscoreRows(context)),
              _buildCard(_getEcoscoreRows(context)),
              _buildCard(_getImageRows(context)),
              _buildCard(_getMiscRows(context)),
              const SizedBox(height: MINIMUM_TOUCH_SIZE),
            ],
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
    if (_basicDetailsAdded ||
        _nutritionFactsAdded ||
        _categoriesAdded ||
        _uploadedImages.isNotEmpty ||
        _otherUploadedImages.isNotEmpty) {
      _product.productName = _product.productName?.trim();
      _product.brands = _product.brands?.trim();
      await _daoProductList.push(_history, barcode);
      _alreadyPushedToHistory = true;
    }
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
    final Attribute? attribute = _getAttribute(Attribute.ATTRIBUTE_NUTRISCORE);
    return <Widget>[
      Text(
        'Compute the Nutri-Score',
        style: _getTitleStyle(context),
      ),
      Text(
        'Help us by filling at least a category and nutritional values',
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
    final Attribute? attribute = _getAttribute(Attribute.ATTRIBUTE_ECOSCORE);
    return <Widget>[
      Text(
        'Compute the Eco-Score',
        style: _getTitleStyle(context),
      ),
      Text(
        'Help us by filling at least a category',
        style: _getSubtitleStyle(context),
      ),
      _buildCategoriesButton(context),
      Center(
        child: SvgIconChip(
          attribute?.iconUrl ?? ProductDialogHelper.unknownSvgEcoscore,
          height: _getScoreIconHeight(context),
        ),
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

  // we let the user change the values
  Widget _buildNutritionInputButton(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return _MyButton(
      appLocalizations.nutritional_facts_input_button_label,
      Icons.filter_2,
      // deactivated when the categories were not set beforehand
      !_categoriesAdded
          ? null
          : () async => NutritionPageLoaded.showNutritionPage(
                product: _product,
                isLoggedInMandatory: false,
                widget: this,
              ),
      done: _nutritionFactsAdded,
    );
  }

  Widget _buildCategoriesButton(final BuildContext context) {
    final SimpleInputPageCategoryHelper helper =
        SimpleInputPageCategoryHelper();
    return _MyButton(
      helper.getAddButtonLabel(AppLocalizations.of(context)),
      Icons.filter_1,
      () async => helper.showEditPage(
        context: context,
        product: _product,
        isLoggedInMandatory: false,
      ),
      done: _categoriesAdded,
    );
  }

  List<Widget> _getMiscRows(final BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return <Widget>[
      Text(
        appLocalizations.new_product_title_misc,
        style: _getTitleStyle(context),
      ),
      _MyButton(
        appLocalizations.completed_basic_details_btn_text,
        _basicDetailsAdded ? _doneIcon : _todoIcon,
        () async => Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => AddBasicDetailsPage(
              _product,
              isLoggedInMandatory: false,
            ),
          ),
        ),
        done: _basicDetailsAdded,
      ),
    ];
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: SmoothLargeButtonWithIcon(
        text: label,
        icon: iconData,
        onPressed: onPressed,
        trailing: Icons.edit,
        backgroundColor: onPressed == null
            ? Colors.grey[300] // TODO dark
            : done
                ? Colors.green[700] // TODO dark
                : themeData.colorScheme.secondary,
        foregroundColor: onPressed == null
            ? Colors.grey[700]
            : done
                ? Colors.white
                : themeData.colorScheme.onSecondary,
      ),
    );
  }
}
