import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Simple input page: we have a list of terms, we add, we remove, we save.
class SimpleInputPage extends StatefulWidget {
  const SimpleInputPage({
    required this.helper,
    required this.product,
  });

  final AbstractSimpleInputPageHelper helper;
  final Product product;

  @override
  State<SimpleInputPage> createState() => _SimpleInputPageState();
}

class _SimpleInputPageState extends State<SimpleInputPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.helper.reInit(widget.product);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async => _mayExitPage(saving: false),
      child: SmoothScaffold(
        appBar: AppBar(
          title: AutoSizeText(
            getProductName(widget.helper.product, appLocalizations),
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
                child: ListView(
                  children: <Widget>[
                    Text(
                      widget.helper.getTitle(appLocalizations),
                      style: themeData.textTheme.headline1,
                    ),
                    if (widget.helper.getSubtitle(appLocalizations) != null)
                      Text(widget.helper.getSubtitle(appLocalizations)!),
                    ListTile(
                      onTap: () => _addItemsFromController(),
                      trailing: const Icon(Icons.add_circle),
                      title: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          border: const OutlineInputBorder(
                            borderRadius: CIRCULAR_BORDER_RADIUS,
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: SMALL_SPACE,
                            vertical: SMALL_SPACE,
                          ),
                          hintText: widget.helper.getAddHint(appLocalizations),
                        ),
                        controller: _controller,
                      ),
                    ),
                    if (widget.helper.getAddExplanations(appLocalizations) !=
                        null)
                      Text(widget.helper.getAddExplanations(appLocalizations)!),
                    Divider(color: themeData.colorScheme.onBackground),
                    Column(
                      children: List<Widget>.generate(
                        widget.helper.terms.length,
                        (final int index) {
                          final String term = widget.helper.terms[index];
                          return ListTile(
                            leading: const Icon(Icons.delete),
                            title: Text(term),
                            onTap: () async {
                              if (widget.helper.removeTerm(term)) {
                                setState(() {});
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SmoothActionButtonsBar(
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
    _addItemsFromController();
    final Product? changedProduct = widget.helper.getChangedProduct();
    if (changedProduct == null) {
      return true;
    }
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    if (!saving) {
      final bool? pleaseSave = await showDialog<bool>(
        context: context,
        builder: (final BuildContext context) => SmoothAlertDialog(
          close: true,
          body: Text(appLocalizations.edit_product_form_item_exit_confirmation),
          title: widget.helper.getTitle(appLocalizations),
          negativeAction: SmoothActionButton(
            text: appLocalizations.ignore,
            onPressed: () => Navigator.pop(context, false),
          ),
          positiveAction: SmoothActionButton(
            text: appLocalizations.save,
            onPressed: () => Navigator.pop(context, true),
          ),
        ),
      );
      if (pleaseSave == null) {
        return false;
      }
      if (pleaseSave == false) {
        return true;
      }
    }
    // if it fails, we stay on the same page
    return ProductRefresher().saveAndRefresh(
      context: context,
      localDatabase: localDatabase,
      product: changedProduct,
    );
  }

  /// Adds all the non-already existing items from the controller.
  ///
  /// The item separator is the comma.
  void _addItemsFromController() {
    final List<String> input = _controller.text.split(',');
    bool result = false;
    for (final String item in input) {
      if (widget.helper.addTerm(item.trim())) {
        result = true;
      }
    }
    if (result) {
      setState(() => _controller.text = '');
    }
  }
}
