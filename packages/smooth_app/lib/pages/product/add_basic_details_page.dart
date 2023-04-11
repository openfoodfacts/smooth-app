import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/cards/product_cards/product_image_carousel.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/pages/text_field_helper.dart';
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

  @override
  State<AddBasicDetailsPage> createState() => _AddBasicDetailsPageState();
}

class _AddBasicDetailsPageState extends State<AddBasicDetailsPage> {
  late final TextEditingControllerWithInitialValue _productNameController;
  late final TextEditingControllerWithInitialValue _brandNameController;
  late final TextEditingControllerWithInitialValue _weightController;

  final double _heightSpace = LARGE_SPACE;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _productNameController =
        TextEditingControllerWithInitialValue(text: _product.productName ?? '');
    _weightController =
        TextEditingControllerWithInitialValue(text: _product.quantity ?? '');
    _brandNameController = TextEditingControllerWithInitialValue(
        text: _formatProductBrands(_product.brands));
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _weightController.dispose();
    _brandNameController.dispose();
    super.dispose();
  }

  /// Returns a [Product] with the values from the text fields.
  Product _getMinimalistProduct() => Product()
    ..barcode = _product.barcode
    ..productName = _productNameController.text
    ..quantity = _weightController.text
    ..brands = _formatProductBrands(_brandNameController.text);

  String _formatProductBrands(String? text) =>
      text == null ? '' : formatProductBrands(text);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async => _mayExitPage(saving: false),
      child: SmoothScaffold(
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: _heightSpace),
                    SmoothTextFormField(
                      controller: _productNameController,
                      type: TextFieldTypes.PLAIN_TEXT,
                      hintText: appLocalizations.product_name,
                    ),
                    SizedBox(height: _heightSpace),
                    SmoothTextFormField(
                      controller: _brandNameController,
                      type: TextFieldTypes.PLAIN_TEXT,
                      hintText: appLocalizations.brand_name,
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
                    onPressed: () async => _exitPage(
                      await _mayExitPage(saving: false),
                    ),
                  ),
                  positiveAction: SmoothActionButton(
                    text: appLocalizations.save,
                    onPressed: () async => _exitPage(
                      await _mayExitPage(saving: true),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns `true` if any value differs with initial state.
  bool _isEdited() =>
      _productNameController.valueHasChanged ||
      _brandNameController.valueHasChanged ||
      _weightController.valueHasChanged;

  /// Exits the page if the [flag] is `true`.
  void _exitPage(final bool flag) {
    if (flag) {
      Navigator.of(context).pop();
    }
  }

  /// Returns `true` if we should really exit the page.
  ///
  /// Parameter [saving] tells about the context: are we leaving the page,
  /// or have we clicked on the "save" button?
  Future<bool> _mayExitPage({required final bool saving}) async {
    if (!_isEdited()) {
      return true;
    }

    if (!saving) {
      final bool? pleaseSave =
          await MayExitPageHelper().openSaveBeforeLeavingDialog(context);
      if (pleaseSave == null) {
        return false;
      }
      if (pleaseSave == false) {
        return true;
      }
      if (!mounted) {
        return false;
      }
    }

    if (widget.isLoggedInMandatory) {
      if (!mounted) {
        return false;
      }
      final bool loggedIn = await ProductRefresher().checkIfLoggedIn(context);
      if (!loggedIn) {
        return false;
      }
    }

    AnalyticsHelper.trackProductEdit(
      AnalyticsEditEvents.basicDetails,
      _product.barcode!,
      true,
    );
    await BackgroundTaskDetails.addTask(
      _getMinimalistProduct(),
      widget: this,
      stamp: BackgroundTaskDetailsStamp.basicDetails,
    );

    return true;
  }
}
