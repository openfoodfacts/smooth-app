import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/collections_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/input/unfocus_field_when_tap_outside.dart';
import 'package:smooth_app/pages/product/common/product_buttons.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/pages/product/simple_input_widget.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/will_pop_scope.dart';

/// Simple input page: we have a list of terms, we add, we remove, we save.
class SimpleInputPage extends StatefulWidget {
  SimpleInputPage({
    required final AbstractSimpleInputPageHelper helper,
    required final Product product,
  }) : this.multiple(
          helpers: <AbstractSimpleInputPageHelper>[helper],
          product: product,
        );

  SimpleInputPage.multiple({
    required this.helpers,
    required this.product,
  }) : assert(helpers.isNotEmpty);

  final List<AbstractSimpleInputPageHelper> helpers;
  final Product product;

  @override
  State<SimpleInputPage> createState() => _SimpleInputPageState();
}

class _SimpleInputPageState extends State<SimpleInputPage> {
  final List<TextEditingController> _controllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.helpers.length; i++) {
      _controllers.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<Widget> simpleInputs = <Widget>[];
    final List<String> titles = <String>[];

    for (int i = 0; i < widget.helpers.length; i++) {
      titles.add(widget.helpers[i].getTitle(appLocalizations));
      simpleInputs.add(
        Padding(
          padding: i == 0
              ? EdgeInsets.zero
              : const EdgeInsets.only(top: LARGE_SPACE),
          // This provider will handle the dispose() call for us
          child: MultiProvider(
            providers: <ChangeNotifierProvider<dynamic>>[
              ChangeNotifierProvider<TextEditingController>(
                create: (_) {
                  _controllers.replace(i, TextEditingController());
                  return _controllers[i];
                },
              ),
              ChangeNotifierProvider<AbstractSimpleInputPageHelper>(
                create: (_) => widget.helpers[i],
              ),
            ],
            child: SimpleInputWidget(
              helper: widget.helpers[i],
              product: widget.product,
              controller: _controllers[i],
              displayTitle: true,
            ),
          ),
        ),
      );
    }

    return WillPopScope2(
      onWillPop: () async => (await _mayExitPage(saving: false), null),
      child: UnfocusFieldWhenTapOutside(
        child: SmoothScaffold(
          fixKeyboard: true,
          appBar: buildEditProductAppBar(
            context: context,
            title: titles.join(', '),
            product: widget.product,
          ),
          backgroundColor: context.lightTheme()
              ? Theme.of(context)
                  .extension<SmoothColorsThemeExtension>()!
                  .primaryLight
              : null,
          body: Scrollbar(
            child: ListView(
              padding: const EdgeInsetsDirectional.all(MEDIUM_SPACE),
              children: simpleInputs,
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
      ),
    );
  }

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
    final Map<BackgroundTaskDetailsStamp, Product> changedProducts =
        <BackgroundTaskDetailsStamp, Product>{};
    bool added = false;
    for (int i = 0; i < widget.helpers.length; i++) {
      final AbstractSimpleInputPageHelper helper = widget.helpers[i];
      if (helper.addItemsFromController(
        _controllers[i],
        clearController: false,
      )) {
        added = true;
      }
      final Product changedProduct = Product(barcode: widget.product.barcode);
      if (helper.getChangedProduct(changedProduct)) {
        changedProducts[helper.getStamp()] = changedProduct;
      }
    }
    if (added) {
      setState(() {});
    }
    if (changedProducts.isEmpty) {
      return true;
    }

    if (!saving) {
      final bool? pleaseSave =
          await MayExitPageHelper().openSaveBeforeLeavingDialog(context);
      if (pleaseSave == null) {
        for (int i = 0; i < widget.helpers.length; i++) {
          widget.helpers[i].restoreItemsBeforeLastAddition();
        }
        return false;
      }
      if (pleaseSave == false) {
        return true;
      }
      if (!mounted) {
        return false;
      }
    }

// If there is more than one helper, we are in the power edit mode.
// else we take the only helper ie 0th element of the [helpers] list
// and get the analytics event from it.

    if (widget.helpers.length > 1) {
      AnalyticsHelper.trackProductEdit(
        AnalyticsEditEvents.powerEditScreen,
        widget.product,
        true,
      );
    } else {
      AnalyticsHelper.trackProductEdit(
        widget.helpers[0].getAnalyticsEditEvent(),
        widget.product,
        true,
      );
    }

    bool first = true;
    for (final MapEntry<BackgroundTaskDetailsStamp, Product> entry
        in changedProducts.entries) {
      await BackgroundTaskDetails.addTask(
        entry.value,
        context: context,
        stamp: entry.key,
        showSnackBar: first,
        productType: widget.product.productType,
      );
      first = false;
    }
    return true;
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }
}
