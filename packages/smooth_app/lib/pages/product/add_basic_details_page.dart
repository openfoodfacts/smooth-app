import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
            SizedBox(height: size.height * 0.02),
            if (widget.product.barcode != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                child: Text(
                  '${appLocalizations.barcode}: ${widget.product.barcode!}',
                  style: TextStyle(
                    color: colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(height: size.height * 0.02),
            SmoothTextFormField(
              controller: _productNameController,
              type: TextFieldTypes.PLAIN_TEXT,
              hintText: appLocalizations.product_name,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return appLocalizations.add_basic_details_product_name_error;
                }
                return null;
              },
            ),
            SizedBox(height: size.height * 0.02),
            SmoothTextFormField(
              controller: _brandNameController,
              type: TextFieldTypes.PLAIN_TEXT,
              hintText: appLocalizations.brand_name,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return appLocalizations.add_basic_details_brand_name_error;
                }
                return null;
              },
            ),
            SizedBox(height: size.height * 0.02),
            SmoothTextFormField(
              controller: _weightController,
              type: TextFieldTypes.PLAIN_TEXT,
              hintText: appLocalizations.weight_gram,
              textInputType: TextInputType.number,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return appLocalizations.add_basic_details_weight_gram_error;
                }
                return null;
              },
            ),
            SizedBox(height: size.height * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildButton(
                  appLocalizations.cancel,
                  () => Navigator.pop(context),
                ),
                _buildButton(appLocalizations.save, () {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  saveData();
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
          close: false,
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

  Future<void> saveData() async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    widget.product.productName = _productNameController.text;
    widget.product.quantity = _weightController.text;
    widget.product.brands = _brandNameController.text;
    final Status status = await OpenFoodAPIClient.saveProduct(
      ProductQuery.getUser(),
      widget.product,
    );
    if (status.error != null) {
      _errormessageAlert(appLocalizations.basic_details_add_error);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.basic_details_add_success)));
    Navigator.pop(context);
  }

  Widget _buildButton(String btnLabel, void Function() onPressFunc) {
    final Size size = MediaQuery.of(context).size;
    return ElevatedButton(
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all<Size>(
          Size(size.width * 0.3, size.height * 0.05),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          const RoundedRectangleBorder(
            borderRadius: CIRCULAR_BORDER_RADIUS,
          ),
        ),
      ),
      onPressed: onPressFunc,
      child: Text(btnLabel),
    );
  }
}
