import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/background_task_helper.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:task_manager/task_manager.dart';

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

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _initializeProduct();
  }

  void _initializeProduct() {
    _productNameController.text = _product.productName ?? '';
    _weightController.text = _product.quantity ?? '';
    _brandNameController.text = _product.brands ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size size = MediaQuery.of(context).size;
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    return SmoothScaffold(
      appBar: AppBar(
        title: Text(appLocalizations.basic_details),
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
                      productName: _productNameController.text,
                      quantity: _weightController.text,
                      brands: _brandNameController.text,
                      barcode: _product.barcode,
                    );
                    final String uniqueId = UniqueIdGenerator.generateUniqueId(
                        _product.barcode!, BASIC_DETAILS);
                    final BackgroundOtherDetailsInput
                        backgroundBasicDetailsInput =
                        BackgroundOtherDetailsInput(
                      processName: PRODUCT_EDIT_TASK,
                      uniqueId: uniqueId,
                      barcode: _product.barcode!,
                      inputMap: jsonEncode(inputProduct.toJson()),
                      languageCode: ProductQuery.getLanguage().code,
                      user: jsonEncode(ProductQuery.getUser().toJson()),
                      country: ProductQuery.getCountry()!.iso2Code,
                    );
                    await TaskManager().addTask(
                      Task(
                        data: backgroundBasicDetailsInput.toJson(),
                        uniqueId: uniqueId,
                      ),
                    );

                    final DaoProduct daoProduct = DaoProduct(localDatabase);
                    final Product? product = await daoProduct.get(
                      _product.barcode!,
                    );
                    // We go and chek in the local database if the product is
                    // already in the database. If it is, we update the fields of the product.
                    //And if it is not, we create a new product with the fields of the _product
                    // and we insert it in the database. (Giving the user an immediate feedback)
                    if (product == null) {
                      daoProduct.put(Product(
                        barcode: _product.barcode,
                        productName: _productNameController.text,
                        brands: _brandNameController.text,
                        quantity: _weightController.text,
                        lang: ProductQuery.getLanguage(),
                      ));
                    } else {
                      product.productName = _productNameController.text;
                      product.brands = _brandNameController.text;
                      product.quantity = _weightController.text;
                      daoProduct.put(product);
                    }
                    localDatabase.notifyListeners();
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
                    Navigator.pop(context, product);
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
