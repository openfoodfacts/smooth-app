import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';

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
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final Size size = MediaQuery.of(context).size;
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.basic_details),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
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
                      appLocalizations.barcode_barcode(widget.product.barcode!),
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
                      final bool savedAndRefreshed =
                          await _saveData(localDatabase, widget.product);
                      if (savedAndRefreshed) {
                        if (!mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                appLocalizations.basic_details_add_success)));
                        Navigator.pop(context, true);
                      } else {
                        if (!mounted) {
                          return;
                        }
                        Navigator.pop(context);
                      }
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _errorMessageAlert(final String message) => showDialog<void>(
        context: context,
        builder: (BuildContext context) => SmoothAlertDialog(
          body: ListTile(
            leading: const Icon(Icons.error_outline, color: Colors.red),
            title: Text(message),
          ),
          positiveAction: SmoothActionButton(
            text: AppLocalizations.of(context).close,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );

  Future<bool> _saveData(
      LocalDatabase localDatabase, Product inputProduct) async {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    inputProduct.productName = _productNameController.text;
    inputProduct.quantity = _weightController.text;
    inputProduct.brands = _brandNameController.text;
    inputProduct.barcode = widget.product.barcode;
    final Product? savedAndRefreshed = await ProductRefresher().saveAndRefresh(
      context: context,
      localDatabase: localDatabase,
      product: inputProduct,
    );
    if (savedAndRefreshed != null) {
      return true;
    } else {
      _errorMessageAlert(appLocalizations.basic_details_add_error);
      return false;
    }
  }
}
