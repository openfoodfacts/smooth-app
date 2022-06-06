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

/// Simple input page: we have a list of labels, we add, we remove, we save.
class SimpleInputPage extends StatefulWidget {
  const SimpleInputPage(this.helper) : super();

  final AbstractSimpleInputPageHelper helper;

  @override
  State<SimpleInputPage> createState() => _SimpleInputPageState();
}

class _SimpleInputPageState extends State<SimpleInputPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final LocalDatabase localDatabase = context.watch<LocalDatabase>();
    // that's a bit tricky here.
    // 1. we want to decide if we can go out of this page.
    // 1a. for this, we return an async bool, according to onWillPop.
    // 2. but we also want to return the changed Product.
    return WillPopScope(
      onWillPop: () async {
        final Product? changedProduct = widget.helper.getChangedProduct();
        if (changedProduct == null) {
          return true;
        }
        final bool? pleaseSave = await showDialog<bool>(
          context: context,
          builder: (final BuildContext context) => SmoothAlertDialog(
            body:
                const Text('You are about to leave this page without saving.'),
            title: widget.helper.getTitle(),
            negativeAction: SmoothActionButton(
              text: 'Ignore',
              onPressed: () => Navigator.pop(context, false),
            ),
            positiveAction: SmoothActionButton(
              text: 'Save',
              onPressed: () => Navigator.pop(context, true),
            ),
            neutralAction: SmoothActionButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(context, null),
            ),
          ),
        );
        if (pleaseSave == null) {
          return false;
        }
        if (pleaseSave == false) {
          return true;
        }
        final Product? savedAndRefreshed =
            await ProductRefresher().saveAndRefresh(
          context: context,
          localDatabase: localDatabase,
          product: changedProduct,
        );
        if (savedAndRefreshed == null) {
          // it failed: we stay on the same page
          return false;
        }
        // tricky part (cf. https://stackoverflow.com/questions/53995673/willpopscope-should-i-use-return-future-valuetrue-after-navigator-pop)
        // 1. we return true to get out of this page.
        // 2. we pop the product because the calling page needs it.
        //ignore: use_build_context_synchronously
        Navigator.pop(context, savedAndRefreshed);
        return Future<bool>(() => true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            getProductName(widget.helper.product, appLocalizations),
            maxLines: 2,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(SMALL_SPACE),
          child: ListView(
            children: <Widget>[
              Text(
                widget.helper.getTitle(),
                style: themeData.textTheme.headline1,
              ),
              const SizedBox(height: LARGE_SPACE),
              Text(widget.helper.getAddTitle()),
              Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      if (widget.helper.addLabel(_controller.text)) {
                        setState(() => _controller.text = '');
                      }
                    },
                    child: const Icon(Icons.add),
                  ),
                  Flexible(
                    flex: 1, // maximum size, as the other guy has no flex
                    child: Padding(
                      padding: const EdgeInsets.all(LARGE_SPACE),
                      child: TextField(
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
                          hintText: widget.helper.getAddHint(),
                        ),
                        controller: _controller,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(color: themeData.colorScheme.onBackground),
              Wrap(
                direction: Axis.horizontal,
                spacing: LARGE_SPACE,
                runSpacing: VERY_SMALL_SPACE,
                children: List<Widget>.generate(
                  widget.helper.getLabels().length,
                  (final int index) {
                    final String label = widget.helper.getLabels()[index];
                    return ElevatedButton.icon(
                      icon: const Icon(Icons.clear),
                      label: Text(label),
                      onPressed: () async {
                        if (widget.helper.removeLabel(label)) {
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
      ),
    );
  }
}
