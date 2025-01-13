import 'dart:ui';

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
import 'package:smooth_app/themes/theme_provider.dart';

/// Simple input widget: we have a list of terms, we add, we remove.
class SimpleInputWidget extends StatefulWidget {
  const SimpleInputWidget({
    required this.helper,
    required this.product,
    required this.controller,
    required this.displayTitle,
    this.newElementsToTop = true,
  });

  final AbstractSimpleInputPageHelper helper;
  final Product product;
  final TextEditingController controller;
  final bool displayTitle;
  final bool newElementsToTop;

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
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String? explanations =
        widget.helper.getAddExplanations(appLocalizations);
    final Widget? extraWidget = widget.helper.getExtraWidget(
      context,
      widget.product,
    );

    final Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (explanations != null && !widget.displayTitle)
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: SMALL_SPACE,
            ),
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
                      autocompleteManager:
                          widget.helper.getAutocompleteManager(),
                      textCapitalization: widget.helper.getTextCapitalization(),
                      allowEmojis: widget.helper.getAllowEmojis(),
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
        _getList(appLocalizations),
        if (extraWidget != null)
          Padding(
            padding: EdgeInsetsDirectional.only(
              top: _localTerms.isEmpty ? SMALL_SPACE : 0.0,
            ),
            child: extraWidget,
          )
        else if (_localTerms.isEmpty)
          const SizedBox(height: MEDIUM_SPACE)
        else
          const SizedBox(height: VERY_SMALL_SPACE),
      ],
    );

    final Widget? trailingHeader = _getTrailingHeader(
      explanations,
      appLocalizations,
    );

    return SmoothCardWithRoundedHeader(
      leading: widget.helper.getIcon(),
      title: widget.helper.getTitle(appLocalizations),
      trailing: trailingHeader,
      titlePadding: trailingHeader != null
          ? const EdgeInsetsDirectional.only(
              top: 2.0,
              start: LARGE_SPACE,
              end: SMALL_SPACE,
              bottom: 2.0,
            )
          : null,
      child: child,
    );
  }

  Widget? _getTrailingHeader(
    String? explanations,
    AppLocalizations appLocalizations,
  ) {
    if (!widget.displayTitle) {
      return null;
    }

    final List<Widget> children = <Widget>[
      if (widget.helper.isOwnerField(widget.product))
        const OwnerFieldSmoothCardIcon(),
      if (explanations != null)
        ExplanationTitleIcon(
          text: explanations,
          type: widget.helper.getTitle(appLocalizations),
        ),
    ];

    if (children.isEmpty) {
      return null;
    } else if (children.length == 1) {
      return children.first;
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }
  }

  Widget _getList(AppLocalizations appLocalizations) {
    if (!widget.helper.reorderable) {
      return AnimatedList(
        key: _listKey,
        initialItemCount: _localTerms.length,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: SMALL_SPACE),
        itemBuilder: (
          BuildContext context,
          int position,
          Animation<double> animation,
        ) {
          return KeyedSubtree(
            key: ValueKey<String>(_localTerms[position]),
            child: SizeTransition(
              sizeFactor: animation,
              child: _getItem(context, position),
            ),
          );
        },
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
      buildDefaultDragHandles: false,
      itemBuilder: (BuildContext context, int index) {
        return KeyedSubtree(
          key: ValueKey<String>(_localTerms[index]),
          child: _getItem(context, index),
        );
      },
      itemCount: _localTerms.length,
      onReorder: (int oldIndex, int newIndex) {
        if (oldIndex < newIndex) {
          newIndex--;
        }

        final String oldValue = _localTerms[oldIndex];
        _localTerms.removeAt(oldIndex);
        _localTerms.insert(newIndex, oldValue);
        widget.helper.replaceItems(_localTerms);
        setState(() {});
      },
      onReorderStart: (_) => SmoothHapticFeedback.lightNotification(),
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 1, animValue)!;

        return Material(
          elevation: elevation,
          shadowColor: context.darkTheme() ? Colors.white24 : null,
          borderRadius: ANGULAR_BORDER_RADIUS,
          child: child,
        );
      },
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget _getItem(
    BuildContext context,
    int position,
  ) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final String term = _localTerms[position];
    final Text child = Text(term);

    return ListTile(
      leading: widget.helper.reorderable
          ? ReorderableDelayedDragStartListener(
              index: position,
              child: const icons.Menu.hamburger(),
            )
          : null,
      trailing: Tooltip(
        message: appLocalizations.edit_product_form_item_remove_item_tooltip,
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
      minTileHeight: 48.0,
      title: child,
    );
  }

  void _onAddItem() {
    _focusNode.unfocus();

    if (widget.controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SmoothFloatingSnackbar.error(
          context: context,
          text: AppLocalizations.of(context).edit_product_form_item_error_empty,
        ),
      );

      return;
    }

    if (widget.helper.addItemsFromController(widget.controller)) {
      // Add new items to the top of our list
      final Iterable<String> newTerms = widget.helper.terms.diff(_localTerms);
      final int newTermsCount = newTerms.length;

      if (widget.newElementsToTop) {
        _localTerms.insertAll(0, newTerms);
        _listKey.currentState?.insertAllItems(0, newTermsCount);
      } else {
        _localTerms.addAll(newTerms);
        _listKey.currentState?.insertItem(_localTerms.length - newTermsCount);
      }

      SmoothHapticFeedback.lightNotification();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SmoothFloatingSnackbar.error(
          context: context,
          text: AppLocalizations.of(context)
              .edit_product_form_item_error_existing,
        ),
      );

      SmoothHapticFeedback.error();
    }
  }

  void _onRemoveItem(String term, Widget child) {
    if (widget.helper.removeTerm(term)) {
      final int position = _localTerms.indexOf(term);
      if (position >= 0) {
        _localTerms.removeAt(position);
        _listKey.currentState?.removeItem(position, (
          _,
          Animation<double> animation,
        ) {
          return FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              child: ListTile(title: child),
            ),
          );
        });

        setState(() {});
      }

      SmoothHapticFeedback.lightNotification();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}

class ExplanationTitleIcon extends StatelessWidget {
  const ExplanationTitleIcon({
    required this.type,
    required this.text,
  });

  final String type;
  final String text;

  @override
  Widget build(BuildContext context) {
    final String title =
        AppLocalizations.of(context).edit_product_form_item_help(type);

    return SmoothCardHeaderButton(
      tooltip: title,
      child: const icons.Help(),
      onTap: () {
        showSmoothModalSheet(
          context: context,
          builder: (BuildContext context) {
            return SmoothModalSheet(
              title: title,
              prefixIndicator: true,
              headerBackgroundColor: SmoothCardWithRoundedHeader.getHeaderColor(
                context,
              ),
              body: SmoothModalSheetBodyContainer(
                child: Text(text),
              ),
            );
          },
        );
      },
    );
  }
}
