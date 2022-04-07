import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
            SizedBox(height: size.height * 0.05),
            if (widget.product.barcode != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${appLocalizations.barcode}: ${widget.product.barcode!}',
                  style: TextStyle(
                    color: colorScheme.onBackground,
                  ),
                ),
              ),
            SmoothTextFormField(
              controller: _productNameController,
              type: TextFieldTypes.PLAIN_TEXT,
              hintText: appLocalizations.product_name,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return appLocalizations.sign_up_page_display_name_error_empty;
                }
                return null;
              },
            ),
            SizedBox(height: size.height * 0.05),
            SmoothTextFormField(
              controller: _brandNameController,
              type: TextFieldTypes.PLAIN_TEXT,
              hintText: appLocalizations.brand_name,
            ),
            SizedBox(height: size.height * 0.05),
            SmoothTextFormField(
              controller: _weightController,
              type: TextFieldTypes.PLAIN_TEXT,
              hintText: appLocalizations.weight_kg,
              textInputType: TextInputType.number,
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
                _buildButton(appLocalizations.save, () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                }),
              ],
            ),
          ],
        ),
      ),
    );
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
