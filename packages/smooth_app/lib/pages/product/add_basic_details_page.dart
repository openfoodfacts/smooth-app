import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

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
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final double _heightSpace = LARGE_SPACE;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Product _product;
  late AppLocalizations appLocalizations = AppLocalizations.of(context);

  void _initializeProduct() {
    _product = widget.product;
    _productNameController.text = _product.productName ?? '';
    _weightController.text = _product.quantity ?? '';
    _brandNameController.text = _formatProductBrands(_product.brands);
  }

  /// Sets a [Product] with the values from the text fields.
  void _setChangedProduct(Product product) {
    product.productName = _productNameController.text;
    product.quantity = _weightController.text;
    product.brands = _formatProductBrands(_brandNameController.text);
  }

  String _formatProductBrands(String? text) {
    return text == null ? '' : formatProductBrands(text, appLocalizations);
  }

  @override
  Widget build(BuildContext context) {
    _initializeProduct();
    final Size size = MediaQuery.of(context).size;
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    final DaoProduct daoProduct = DaoProduct(localDatabase);
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
                onUpload: (_) {},
              ),
            ),
            SizedBox(height: _heightSpace),
            if (_product.barcode != null)
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
                        if (value == null || value.isEmpty) {
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
                        if (value == null || value.isEmpty) {
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
                    final Product inputProduct = Product(
                      barcode: _product.barcode,
                    );
                    _setChangedProduct(inputProduct);
                    final Product? cachedProduct =
                        await daoProduct.get(_product.barcode!);
                    if (cachedProduct != null) {
                      _setChangedProduct(cachedProduct);
                    }
                    await BackgroundTaskDetails.addTask(
                      inputProduct,
                      productEditTask: ProductEditTask.basic,
                      widget: this,
                    );
                    final Product upToDateProduct =
                        cachedProduct ?? inputProduct;
                    await daoProduct.put(upToDateProduct);
                    localDatabase.upToDate.set(upToDateProduct);
                    if (!mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          appLocalizations.basic_details_add_success,
                        ),
                        duration: SnackBarDuration.medium,
                      ),
                    );
                    Navigator.pop(context, upToDateProduct);
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
