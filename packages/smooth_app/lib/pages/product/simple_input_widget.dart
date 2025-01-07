import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/helpers/collections_helper.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/pages/product/explanation_widget.dart';
import 'package:smooth_app/pages/product/owner_field_info.dart';
import 'package:smooth_app/pages/product/simple_input_page_helpers.dart';
import 'package:smooth_app/pages/product/simple_input_text_field.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

/// Simple input widget: we have a list of terms, we add, we remove.
class SimpleInputWidget extends StatefulWidget {
  const SimpleInputWidget({
    required this.helper,
    required this.product,
    required this.controller,
    required this.displayTitle,
  });

  final AbstractSimpleInputPageHelper helper;
  final Product product;
  final TextEditingController controller;
  final bool displayTitle;

  @override
  State<SimpleInputWidget> createState() => _SimpleInputWidgetState();
}

class _SimpleInputWidgetState extends State<SimpleInputWidget> {
  late final FocusNode _focusNode;

  /// In order to add new items to the top of the list, we have our custom copy
  /// Because the [AbstractSimpleInputPageHelper] always add new items to the
  /// bottom of the list.
  late final List<String> _localTerms;

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final Key _autocompleteKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    widget.helper.reInit(widget.product);
    _localTerms = List<String>.of(widget.helper.terms);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String? explanations =
        widget.helper.getAddExplanations(appLocalizations);
    final Widget? extraWidget = widget.helper.getExtraWidget(
      context,
      widget.product,
    );
    final bool isOwnerField = widget.helper.isOwnerField(widget.product);

    final Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (explanations != null && !widget.displayTitle)
          Padding(
            padding:
                const EdgeInsetsDirectional.symmetric(horizontal: SMALL_SPACE),
            child: ExplanationWidget(explanations),
          ),
        LayoutBuilder(
          builder: (_, BoxConstraints constraints) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(
                start: SMALL_SPACE,
                end: 4.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: SimpleInputTextField(
                      autocompleteKey: _autocompleteKey,
                      focusNode: _focusNode,
                      constraints: constraints,
                      tagType: widget.helper.getTagType(),
                      hintText: widget.helper.getAddHint(appLocalizations),
                      controller: widget.controller,
                      padding: const EdgeInsets.symmetric(
                        horizontal: MEDIUM_SPACE,
                        vertical: SMALL_SPACE,
                      ),
                      margin: const EdgeInsetsDirectional.only(
                        start: 3.0,
                      ),
                      productType: widget.product.productType,
                      suffixIcon: !isOwnerField ? null : const OwnerFieldIcon(),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                  ),
                  Tooltip(
                    message: appLocalizations.edit_product_form_item_add_action(
                        widget.helper.getTypeLabel(appLocalizations)),
                    child: IconButton(
                      onPressed: _onAddItem,
                      splashRadius: 20.0,
                      icon: ListenableBuilder(
                        listenable: widget.controller,
                        builder: (
                          BuildContext context,
                          _,
                        ) =>
                            Icon(
                          Icons.add_circle,
                          color: IconTheme.of(context).color?.withValues(
                                alpha:
                                    widget.controller.text.isEmpty ? 0.7 : 1.0,
                              ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
        AnimatedList(
          key: _listKey,
          initialItemCount: _localTerms.length,
          padding:
              const EdgeInsetsDirectional.symmetric(horizontal: SMALL_SPACE),
          itemBuilder: (
            BuildContext context,
            int position,
            Animation<double> animation,
          ) {
            final String term = _localTerms[position];
            final Widget child = Text(term);

            return KeyedSubtree(
              key: ValueKey<String>(term),
              child: SizeTransition(
                sizeFactor: animation,
                child: ListTile(
                  trailing: Tooltip(
                    message: appLocalizations
                        .edit_product_form_item_remove_item_tooltip,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _onRemoveItem(term, child),
                      child: const Padding(
                        padding: EdgeInsets.all(SMALL_SPACE),
                        child: Icon(Icons.delete),
                      ),
                    ),
                  ),
                  contentPadding: const EdgeInsetsDirectional.only(
                    start: LARGE_SPACE,
                  ),
                  title: child,
                ),
              ),
            );
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
        if (extraWidget != null)
          extraWidget
        else
          const SizedBox(height: MEDIUM_SPACE),
      ],
    );

    return SmoothCardWithRoundedHeader(
      leading: widget.helper.getIcon(),
      title: widget.helper.getTitle(appLocalizations),
      trailing: explanations != null && widget.displayTitle
          ? _ExplanationTitleIcon(
              text: explanations,
              type: widget.helper.getTitle(appLocalizations),
            )
          : null,
      titlePadding: explanations != null
          ? const EdgeInsetsDirectional.only(
              top: SMALL_SPACE,
              bottom: SMALL_SPACE,
              start: LARGE_SPACE,
              end: SMALL_SPACE,
            )
          : null,
      child: child,
    );
  }

  void _onAddItem() {
    if (widget.controller.text.trim().isEmpty) {
      final AppLocalizations appLocalizations = AppLocalizations.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SmoothFloatingSnackbar.error(
          context: context,
          text: appLocalizations.edit_product_form_item_error_empty,
        ),
      );

      return;
    }

    if (widget.helper.addItemsFromController(widget.controller)) {
      // Add new items to the top of our list
      final Iterable<String> newTerms = widget.helper.terms.diff(_localTerms);
      final int newTermsCount = newTerms.length;
      _localTerms.insertAll(0, newTerms);
      _listKey.currentState?.insertAllItems(0, newTermsCount);
    }

    SmoothHapticFeedback.lightNotification();
  }

  void _onRemoveItem(String term, Widget child) {
    if (widget.helper.removeTerm(term)) {
      final int position = _localTerms.indexOf(term);
      if (position >= 0) {
        _localTerms.remove(term);
        _listKey.currentState?.removeItem(position,
            (_, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              child: ListTile(title: child),
            ),
          );
        });
      }

      SmoothHapticFeedback.lightNotification();
    }
  }
}

class _ExplanationTitleIcon extends StatelessWidget {
  const _ExplanationTitleIcon({
    required this.type,
    required this.text,
  });

  final String type;
  final String text;

  @override
  Widget build(BuildContext context) {
    final String title =
        AppLocalizations.of(context).edit_product_form_item_help(type);

    return Material(
      type: MaterialType.transparency,
      child: Semantics(
        label: title,
        button: true,
        excludeSemantics: true,
        child: Tooltip(
          message: title,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              showSmoothModalSheet(
                context: context,
                builder: (BuildContext context) {
                  return SmoothModalSheet(
                    title: title,
                    prefixIndicator: true,
                    body: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: MEDIUM_SPACE,
                        end: MEDIUM_SPACE,
                        top: VERY_SMALL_SPACE,
                        bottom: VERY_SMALL_SPACE +
                            MediaQuery.viewPaddingOf(context).bottom,
                      ),
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 15.0,
                          height: 1.7,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            child: const Padding(
              padding: EdgeInsetsDirectional.all(MEDIUM_SPACE),
              child: icons.Help(),
            ),
          ),
        ),
      ),
    );
  }
}
