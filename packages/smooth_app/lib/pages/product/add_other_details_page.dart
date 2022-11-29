import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Input of a product's less significant details, like website.
class AddOtherDetailsPage extends StatefulWidget {
  const AddOtherDetailsPage(
    this.product,
  );

  final Product product;

  @override
  State<AddOtherDetailsPage> createState() => _AddOtherDetailsPageState();
}

class _AddOtherDetailsPageState extends State<AddOtherDetailsPage> {
  final TextEditingController _websiteController = TextEditingController();

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
    _websiteController.text = _product.website ?? '';
  }

  /// Returns a [Product] with the values from the text fields.
  Product _getMinimalistProduct() => Product()
    ..barcode = _product.barcode
    ..website = _websiteController.text;

  @override
  Widget build(BuildContext context) {
    _initializeProduct();
    final Size size = MediaQuery.of(context).size;
    return SmoothScaffold(
      appBar: SmoothAppBar(
        title:
            Text(appLocalizations.edit_product_form_item_other_details_title),
        subTitle: widget.product.productName != null
            ? Text(widget.product.productName!,
                overflow: TextOverflow.ellipsis, maxLines: 1)
            : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
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
                    controller: _websiteController,
                    type: TextFieldTypes.PLAIN_TEXT,
                    hintText: appLocalizations.product_field_website_title,
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
