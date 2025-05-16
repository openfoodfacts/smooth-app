import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/pages/product/simple_input/list/simple_input_list_item.dart';
import 'package:smooth_app/pages/product/simple_input/list/suggestions/list_suggestions.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_page_helpers.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// A list used in the [SimpleInputPage] to display a list of items.
class SimpleInputList extends StatelessWidget {
  const SimpleInputList({
    required this.listKey,
    required this.helper,
    required this.product,
    required this.controller,
    required this.onAddItem,
    required this.setState,
    super.key,
  });

  final GlobalKey<AnimatedListState> listKey;
  final AbstractSimpleInputPageHelper helper;
  final Product product;
  final TextEditingController controller;
  final VoidCallback onAddItem;
  final Function(VoidCallback fn) setState;

  @override
  Widget build(BuildContext context) {
    final List<String> localTerms =
        context.watch<ValueNotifier<List<String>>>().value;

    if (!helper.reorderable) {
      return Column(
        children: <Widget>[
          SimpleInputListSuggestions(
            (String suggestion) {
              controller.text = suggestion;
              onAddItem.call();
            },
          ),
          AnimatedList(
            key: listKey,
            initialItemCount: localTerms.length,
            padding: EdgeInsets.zero,
            itemBuilder: (
              BuildContext context,
              int position,
              Animation<double> animation,
            ) {
              return KeyedSubtree(
                key: ValueKey<String>(localTerms[position]),
                child: SizeTransition(
                  sizeFactor: animation,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: SMALL_SPACE,
                    ),
                    child: _getItem(context, localTerms, position),
                  ),
                ),
              );
            },
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ],
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
      buildDefaultDragHandles: false,
      itemBuilder: (BuildContext context, int index) {
        return KeyedSubtree(
          key: ValueKey<String>(localTerms[index]),
          child: _getItem(context, localTerms, index),
        );
      },
      itemCount: localTerms.length,
      onReorder: (int oldIndex, int newIndex) {
        if (oldIndex < newIndex) {
          newIndex--;
        }

        final String oldValue = localTerms[oldIndex];
        localTerms.removeAt(oldIndex);
        localTerms.insert(newIndex, oldValue);
        helper.replaceItems(localTerms);
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
    List<String> localTerms,
    int position,
  ) {
    final String localTerm = localTerms[position];

    return SimpleInputListItem(
      term: localTerm,
      isNew: helper.isNewTerm(localTerm),
      reorderable: helper.reorderable,
      editable: helper.editable,
      position: position,
      onChanged: (int position, String term) {
        helper.replaceItem(position, term);
      },
      onRemoveItem: (String term, Widget child) =>
          _onRemoveItem(localTerms, term, child),
    );
  }

  void _onRemoveItem(List<String> localTerms, String term, Widget child) {
    if (helper.removeTerm(term)) {
      final int position = localTerms.indexOf(term);
      if (position >= 0) {
        localTerms.removeAt(position);
        listKey.currentState?.removeItem(position, (
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
}
