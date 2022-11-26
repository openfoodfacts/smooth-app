import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Input of a product's basic details, like name, quantity and brands.
class AddBasicDetailsPage extends StatefulWidget {
  const AddBasicDetailsPage(
    this.product, {
    this.isLoggedInMandatory = true,
  });

  final Product product;
  final bool isLoggedInMandatory;

  /// Returns true if the [field] is valid (= not empty).
  static bool _isProductFieldValid(final String? field) =>
      field != null && field.trim().isNotEmpty;

  /// Returns true if the [product] basic details are valid (= not empty).
  static bool isProductBasicValid(final Product product) =>
      _isProductFieldValid(product.productName) &&
      _isProductFieldValid(product.brands);

  @override
  State<AddBasicDetailsPage> createState() => _AddBasicDetailsPageState();
}

class _AddBasicDetailsPageState extends State<AddBasicDetailsPage> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final double _heightSpace = LARGE_SPACE;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Product _product;
  late AppLocalizations appLocalizations = AppLocalizations.of(context);

  bool _initDone = false;

  void _initializeProduct() {
    if (_initDone) {
      return;
    }
    _initDone = true;
    _product = widget.product;
    _productNameController.text = _product.productName ?? '';
    _weightController.text = _product.quantity ?? '';
    _brandNameController.text = _formatProductBrands(_product.brands);
  }

  /// Returns a [Product] with the values from the text fields.
  Product _getMinimalistProduct() => Product()
    ..barcode = _product.barcode
    ..productName = _productNameController.text
    ..quantity = _weightController.text
    ..brands = _formatProductBrands(_brandNameController.text);

  String _formatProductBrands(String? text) =>
      text == null ? '' : formatProductBrands(text, appLocalizations);

  @override
  Widget build(BuildContext context) {
    _initializeProduct();
    final Size size = MediaQuery.of(context).size;
    return SmoothScaffold(
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
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: _heightSpace),
                  SmoothTextFormField(
                    controller: _productNameController,
                    type: TextFieldTypes.PLAIN_TEXT,
                    hintText: appLocalizations.product_name,
                    validator: (String? value) {
                      if (!AddBasicDetailsPage._isProductFieldValid(value)) {
                        return appLocalizations
                            .add_basic_details_product_name_error;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: _heightSpace),
                  SmoothTextFormField(
                    controller: _brandNameController,
                    type: TextFieldTypes.PLAIN_TEXT,
                    hintText: appLocalizations.brand_name,
                    validator: (String? value) {
                      if (!AddBasicDetailsPage._isProductFieldValid(value)) {
                        return appLocalizations
                            .add_basic_details_brand_name_error;
                      }
                      return null;
                    },
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
                  onPressed: () => Navigator.pop(context),
                ),
                positiveAction: SmoothActionButton(
                  text: appLocalizations.save,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    await BackgroundTaskDetails.addTask(
                      _getMinimalistProduct(),
                      widget: this,
                    );
                    if (!mounted) {
                      return;
                    }
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
