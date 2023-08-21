import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/pages/product/common/product_buttons.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/pages/text_field_helper.dart';
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
  late final TextEditingControllerWithInitialValue _websiteController;

  final double _heightSpace = LARGE_SPACE;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _websiteController =
        TextEditingControllerWithInitialValue(text: _product.website ?? '');
  }

  @override
  void dispose() {
    _websiteController.dispose();
    super.dispose();
  }

  /// Returns a [Product] with the values from the text fields.
  Product _getMinimalistProduct() => Product()
    ..barcode = _product.barcode
    ..website = _websiteController.text;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async => _mayExitPage(saving: false),
      child: SmoothScaffold(
        fixKeyboard: true,
        appBar: SmoothAppBar(
          centerTitle: false,
          title:
              Text(appLocalizations.edit_product_form_item_other_details_title),
          subTitle: widget.product.productName != null
              ? Text(
                  '${widget.product.productName!.trim()}, ${widget.product.brands!.trim()}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1)
              : null,
          ignoreSemanticsForSubtitle: true,
        ),
        body: Form(
          key: _formKey,
          child: Scrollbar(
            child: ListView(
              children: <Widget>[
                SizedBox(height: _heightSpace),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Column(
                    children: <Widget>[
                      ExcludeSemantics(
                        child: Text(
                          appLocalizations.barcode_barcode(_product.barcode!),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
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
              ],
            ),
          ),
        ),
        bottomNavigationBar: ProductBottomButtonsBar(
          onSave: () async => _exitPage(
            await _mayExitPage(saving: true),
          ),
          onCancel: () async => _exitPage(
            await _mayExitPage(saving: false),
          ),
        ),
      ),
    );
  }

  /// Returns `true` if any value differs with initial state.
  bool _isEdited() => _websiteController.valueHasChanged;

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

    AnalyticsHelper.trackProductEdit(
      AnalyticsEditEvents.otherDetails,
      widget.product.barcode!,
      true,
    );
    await BackgroundTaskDetails.addTask(
      _getMinimalistProduct(),
      widget: this,
      stamp: BackgroundTaskDetailsStamp.otherDetails,
    );

    return true;
  }
}
