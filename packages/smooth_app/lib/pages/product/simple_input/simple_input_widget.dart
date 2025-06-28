import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_snackbar.dart';
import 'package:smooth_app/helpers/collections_helper.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/owner_field_info.dart';
import 'package:smooth_app/pages/product/simple_input/list/simple_input_list.dart';
import 'package:smooth_app/pages/product/simple_input/list/suggestions/robotoff/robotoff_suggestions_list.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_page_helpers.dart';
import 'package:smooth_app/pages/product/simple_input/simple_input_text_field.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/smooth_explanation_banner.dart';

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

class _SimpleInputWidgetState extends State<SimpleInputWidget>
    with AutomaticKeepAliveClientMixin {
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
    super.build(context);
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final Widget? extraWidget = widget.helper.getExtraWidget(
      context,
      widget.product,
    );

    final Widget child = MultiProvider(
      providers: <ChangeNotifierProvider<dynamic>>[
        ChangeNotifierProvider<ValueNotifier<SimpleInputSuggestionsState>>(
          create: (_) => widget.helper.getSuggestions(),
        ),
        ChangeNotifierProvider<ValueNotifier<List<String>>>(
          create: (_) => ValueNotifier<List<String>>(_localTerms),
        ),
        ChangeNotifierProvider<
          ValueNotifier<Map<RobotoffQuestion, InsightAnnotation?>>
        >.value(value: widget.helper.robotoffQuestionsNotifier),
      ],
      builder: (BuildContext context, Widget? child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          LayoutBuilder(
            builder: (_, BoxConstraints constraints) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: SMALL_SPACE,
                  end: 6.0,
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
                        autocompleteManager: widget.helper
                            .getAutocompleteManager(),
                        textCapitalization: widget.helper
                            .getTextCapitalization(),
                        allowEmojis: widget.helper.getAllowEmojis(),
                        hintText: widget.helper.getAddHint(appLocalizations),
                        controller: widget.controller,
                        padding: const EdgeInsets.symmetric(
                          horizontal: LARGE_SPACE,
                          vertical: MEDIUM_SPACE,
                        ),
                        margin: const EdgeInsetsDirectional.only(start: 3.0),
                        productType: widget.product.productType,
                        borderRadius: CIRCULAR_BORDER_RADIUS,
                      ),
                    ),
                    Tooltip(
                      message: widget.helper.getAddTooltip(appLocalizations),
                      child: IconButton(
                        onPressed: _onAddItem,
                        splashRadius: 20.0,
                        icon: ListenableBuilder(
                          listenable: widget.controller,
                          builder: (BuildContext context, _) => icons.Add(
                            size: 20.0,
                            color: IconTheme.of(context).color?.withValues(
                              alpha: widget.controller.text.isEmpty ? 0.7 : 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          RobotoffSuggestionList(helper: widget.helper),
          SimpleInputList(
            listKey: _listKey,
            helper: widget.helper,
            product: widget.product,
            controller: widget.controller,
            onAddItem: _onAddItem,
            setState: setState,
          ),
          if (extraWidget != null)
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: _localTerms.isEmpty ? SMALL_SPACE : 0.0,
              ),
              child: extraWidget,
            )
          else if (_localTerms.isEmpty)
            Consumer<ValueNotifier<Map<RobotoffQuestion, InsightAnnotation?>>>(
              builder:
                  (
                    BuildContext context,
                    ValueNotifier<Map<RobotoffQuestion, InsightAnnotation?>>
                    notif,
                    _,
                  ) {
                    if (notif.value.isEmpty) {
                      return const SizedBox(height: VERY_SMALL_SPACE);
                    } else {
                      return EMPTY_WIDGET;
                    }
                  },
            )
          else
            const SizedBox(height: VERY_SMALL_SPACE),
        ],
      ),
    );

    final Widget? trailingHeader = _getTrailingHeader(
      widget.helper.getAddExplanationsTitle(appLocalizations),
      widget.helper.getAddExplanationsContent(),
      appLocalizations,
    );

    return Column(
      children: <Widget>[
        SmoothCardWithRoundedHeader(
          leading: widget.helper.getIcon(),
          title: widget.helper.getTitle(appLocalizations),
          trailing: trailingHeader,
          contentPadding: const EdgeInsetsDirectional.only(top: BALANCED_SPACE),
          child: child,
        ),
        const SizedBox(height: MEDIUM_SPACE),
      ],
    );
  }

  Widget? _getTrailingHeader(
    String? title,
    WidgetBuilder? explanationsBuilder,
    AppLocalizations appLocalizations,
  ) {
    if (!widget.displayTitle) {
      return null;
    }

    final Widget? explanations = explanationsBuilder?.call(context);

    final List<Widget> children = <Widget>[
      if (widget.helper.isOwnerField(widget.product))
        const OwnerFieldSmoothCardIcon(),
      if (explanations != null)
        ExplanationTitleIcon(
          title: title ?? widget.helper.getTitle(appLocalizations),
          safeArea: explanations is! ExplanationBodyInfo,
          child: explanations,
        ),
    ];

    if (children.isEmpty) {
      return null;
    } else if (children.length == 1) {
      return children.first;
    } else {
      return Row(mainAxisSize: MainAxisSize.min, children: children);
    }
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
          text: AppLocalizations.of(
            context,
          ).edit_product_form_item_error_existing,
        ),
      );

      SmoothHapticFeedback.error();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
