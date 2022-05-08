import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/loading_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';

class AddBasicDetailsPage extends StatefulWidget {
  const AddBasicDetailsPage(this.product);
  final Product product;
  @override
  State<AddBasicDetailsPage> createState() => _AddBasicDetailsPageState();
}

class _AddBasicDetailsPageState extends State<AddBasicDetailsPage> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final double _heightSpace = LARGE_SPACE;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _initializeProduct();
  }

  void _initializeProduct() {
    _productNameController.text = widget.product.productName ?? '';
    _weightController.text = widget.product.quantity ?? '';
    _brandNameController.text = widget.product.brands ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final Size size = MediaQuery.of(context).size;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.basic_details)),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: ProductImageCarousel(
                widget.product,
                height: size.height * 0.20,
                onUpload: (_) {},
              ),
            ),
            SizedBox(height: _heightSpace),
            if (widget.product.barcode != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Column(
                  children: <Widget>[
                    Text(
                      '${appLocalizations.barcode}: ${widget.product.barcode!}',
                      style: TextStyle(
                        color: colorScheme.onBackground,
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
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return appLocalizations
                              .add_basic_details_quantity_error;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: _heightSpace),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SmoothActionButton(
                  text: appLocalizations.cancel,
                  onPressed: () => Navigator.pop(context),
                ),
                SmoothActionButton(
                    text: appLocalizations.save,
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      final Status? status = await _saveData();
                      if (status == null || status.error != null) {
                        _errormessageAlert(
                            appLocalizations.basic_details_add_error);
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              appLocalizations.basic_details_add_success)));
                      Navigator.pop(context);
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _errormessageAlert(final String message) => showDialog<void>(
        context: context,
        builder: (BuildContext context) => SmoothAlertDialog(
          body: ListTile(
            leading: const Icon(Icons.error_outline, color: Colors.red),
            title: Text(message),
          ),
          actions: <SmoothActionButton>[
            SmoothActionButton(
              text: AppLocalizations.of(context)!.close,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );

  Future<Status?> _saveData() async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final Product product = Product(
      productName: _productNameController.text,
      quantity: _weightController.text,
      brands: _brandNameController.text,
      barcode: widget.product.barcode,
    );
    final Status? status = await LoadingDialog.run<Status>(
      context: context,
      future: OpenFoodAPIClient.saveProduct(
        ProductQuery.getUser(),
        product,
      ),
      title: appLocalizations.nutrition_page_update_running,
    );
    return status;
  }
}
