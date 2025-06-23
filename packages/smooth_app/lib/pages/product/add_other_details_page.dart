import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_text_form_field.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/product_buttons.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/pages/text_field_helper.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/will_pop_scope.dart';

/// Input of a product's less significant details, like website.
class AddOtherDetailsPage extends StatefulWidget {
  const AddOtherDetailsPage(this.product);

  final Product product;

  @override
  State<AddOtherDetailsPage> createState() => _AddOtherDetailsPageState();
}

class _AddOtherDetailsPageState extends State<AddOtherDetailsPage> {
  late final TextEditingControllerWithHistory _websiteController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _websiteController = TextEditingControllerWithHistory(
      text: _product.website ?? '',
    );
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
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return WillPopScope2(
      onWillPop: () async => (await _mayExitPage(saving: false), null),
      child: SmoothScaffold(
        fixKeyboard: true,
        appBar: buildEditProductAppBar(
          context: context,
          title: appLocalizations.edit_product_form_item_other_details_title,
          product: widget.product,
        ),
        backgroundColor: context.lightTheme()
            ? Theme.of(
                context,
              ).extension<SmoothColorsThemeExtension>()!.primaryLight
            : null,
        body: Form(
          key: _formKey,
          child: Scrollbar(
            child: ListView(
              padding: const EdgeInsetsDirectional.only(
                top: MEDIUM_SPACE,
                start: MEDIUM_SPACE,
                end: MEDIUM_SPACE,
              ),
              children: <Widget>[
                SmoothCardWithRoundedHeader(
                  title: appLocalizations.product_field_website_title,
                  leading: const Icon(Icons.link),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: MEDIUM_SPACE,
                      start: MEDIUM_SPACE,
                      end: MEDIUM_SPACE,
                    ),
                    child: Column(
                      children: <Widget>[
                        SmoothTextFormField(
                          controller: _websiteController,
                          type: TextFieldTypes.PLAIN_TEXT,
                          hintText:
                              appLocalizations.product_field_website_title,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: ProductBottomButtonsBar(
          onSave: () async => _exitPage(await _mayExitPage(saving: true)),
          onCancel: () async => _exitPage(await _mayExitPage(saving: false)),
        ),
      ),
    );
  }

  /// Returns `true` if any value differs with initial state.
  bool _isEdited() => _websiteController.isDifferentFromInitialValue;

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
      final bool? pleaseSave = await MayExitPageHelper()
          .openSaveBeforeLeavingDialog(context);
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
      widget.product,
      true,
    );
    await BackgroundTaskDetails.addTask(
      _getMinimalistProduct(),
      context: context,
      stamp: BackgroundTaskDetailsStamp.otherDetails,
      productType: _product.productType,
    );

    return true;
  }
}
