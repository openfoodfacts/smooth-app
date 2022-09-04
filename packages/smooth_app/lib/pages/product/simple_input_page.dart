import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/up_to_date_product_provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/background_task_helper.dart';
import 'package:smooth_app/helpers/collections_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/pages/product/simple_input_widget.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:task_manager/task_manager.dart';

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

    for (final AbstractSimpleInputPageHelper helper in widget.helpers) {
      helper.reInit(widget.product);
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
              ),
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => _mayExitPage(saving: false),
      child: SmoothScaffold(
        appBar: AppBar(
          title: AutoSizeText(
            getProductName(widget.product, appLocalizations),
            maxLines: 2,
          ),
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

  /// Merge the changes from [newProduct] into [productInCache].
  Product _mergeProducts(Product productInCache, Product newProduct) {
    // We take the json representation of both products
    final Map<String, dynamic> newProductMap = newProduct.toJson();
    final Map<String, dynamic> productInCacheMap = productInCache.toJson();
    for (final String key in newProductMap.keys) {
      if (newProductMap[key] != null) {
        productInCacheMap[key] = newProductMap[key];
      }
    }
    // Here we do the extra step of json encoding and decoding
    // cause for some reason the product.fromJson constructor does not work
    final String encodedJson = jsonEncode(productInCacheMap);
    final Map<String, dynamic> decodedJson =
        json.decode(encodedJson) as Map<String, dynamic>;
    return Product.fromJson(decodedJson);
  }

  /// Returns `true` if we should really exit the page.
  ///
  /// Parameter [saving] tells about the context: are we leaving the page,
  /// or have we clicked on the "save" button?
  Future<bool> _mayExitPage({required final bool saving}) async {
    final Product changedProduct = Product(barcode: widget.product.barcode);
    bool changed = false;
    bool added = false;
    String pageName = '';
    for (int i = 0; i < widget.helpers.length; i++) {
      if (widget.helpers[i].addItemsFromController(_controllers[i])) {
        added = true;
      }
      if (widget.helpers[i].getChangedProduct(changedProduct)) {
        changed = true;
      }
      pageName = widget.helpers[i].getTitle(AppLocalizations.of(context));
    }
    if (added) {
      setState(() {});
    }
    if (!changed) {
      return true;
    }
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final UpToDateProductProvider provider =
        context.read<UpToDateProductProvider>();
    if (!saving) {
      final bool? pleaseSave = await showDialog<bool>(
        context: context,
        builder: (final BuildContext context) => SmoothAlertDialog(
          close: true,
          body: Text(appLocalizations.edit_product_form_item_exit_confirmation),
          title: appLocalizations.edit_product_label,
          negativeAction: SmoothActionButton(
            text: appLocalizations
                .edit_product_form_item_exit_confirmation_negative_button,
            onPressed: () => Navigator.pop(context, false),
          ),
          positiveAction: SmoothActionButton(
            text: appLocalizations
                .edit_product_form_item_exit_confirmation_positive_button,
            onPressed: () => Navigator.pop(context, true),
          ),
          actionsAxis: Axis.vertical,
          actionsOrder: SmoothButtonsBarOrder.numerical,
        ),
      );
      if (pleaseSave == null) {
        return false;
      }
      if (pleaseSave == false) {
        return true;
      }
    }
    final String uniqueId =
        UniqueIdGenerator.generateUniqueId(changedProduct.barcode!, pageName);
    final BackgroundOtherDetailsInput backgroundOtherDetailsInput =
        BackgroundOtherDetailsInput(
      processName: PRODUCT_EDIT_TASK,
      uniqueId: uniqueId,
      barcode: changedProduct.barcode!,
      languageCode: ProductQuery.getLanguage().code,
      inputMap: jsonEncode(changedProduct.toJson()),
      user: jsonEncode(ProductQuery.getUser().toJson()),
      country: ProductQuery.getCountry()!.iso2Code,
    );
    await TaskManager().addTask(
      Task(
        data: backgroundOtherDetailsInput.toJson(),
        uniqueId: uniqueId,
      ),
    );

    final DaoProduct daoProduct = DaoProduct(localDatabase);
    final Product? product = await daoProduct.get(
      changedProduct.barcode!,
    );
    // We go and chek in the local database if the product is
    // already in the database. If it is, we update the fields of the product.
    //And if it is not, we create a new product with the fields of the changed product.
    // and we insert it in the database. (Giving the user an immediate feedback)
    if (product == null) {
      daoProduct.put(changedProduct);
      provider.set(changedProduct);
    } else {
      final Product mergedProduct = _mergeProducts(product, changedProduct);
      daoProduct.put(mergedProduct);
      provider.set(mergedProduct);
    }
    localDatabase.notifyListeners();
    if (!mounted) {
      return false;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appLocalizations.product_task_background_schedule,
        ),
        duration: SnackBarDuration.medium,
      ),
    );
    return true;
  }

  @override
  void dispose() {
    // Disposed is managed by the provider
    _controllers.clear();
    super.dispose();
  }
}
