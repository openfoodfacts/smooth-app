import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_details.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/collections_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/may_exit_page_helper.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/pages/product/simple_input_widget.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

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

    for (int i = 0; i < widget.helpers.length; i++) {
      simpleInputs.add(
        Padding(
          padding: i == 0
              ? EdgeInsets.zero
              : const EdgeInsets.only(top: LARGE_SPACE),
          child: SmoothCard(
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
              ),
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => _mayExitPage(saving: false),
      child: SmoothScaffold(
        appBar: SmoothAppBar(
          title: AutoSizeText(
            getProductName(widget.product, appLocalizations),
            maxLines: widget.product.barcode?.isNotEmpty == true ? 1 : 2,
          ),
          subTitle: widget.product.barcode != null
              ? Text(widget.product.barcode!)
              : null,
        ),
        body: Padding(
          padding: const EdgeInsets.all(SMALL_SPACE),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Scrollbar(
                  child: ListView(children: simpleInputs),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                child: SmoothActionButtonsBar(
                  axis: Axis.horizontal,
                  positiveAction: SmoothActionButton(
                    text: appLocalizations.save,
                    onPressed: () async => _exitPage(
                      await _mayExitPage(saving: true),
                    ),
                  ),
                  negativeAction: SmoothActionButton(
                    text: appLocalizations.cancel,
                    onPressed: () async => _exitPage(
                      await _mayExitPage(saving: false),
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
    final Product changedProduct = Product(barcode: widget.product.barcode);
    bool changed = false;
    bool added = false;
    for (int i = 0; i < widget.helpers.length; i++) {
      final AbstractSimpleInputPageHelper helper = widget.helpers[i];
      if (helper.addItemsFromController(_controllers[i])) {
        added = true;
      }
      if (helper.getChangedProduct(changedProduct)) {
        changed = true;
      }
    }
    if (added) {
      setState(() {});
    }
    if (!changed) {
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
    }
    await BackgroundTaskDetails.addTask(
      changedProduct,
      widget: this,
    );
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
