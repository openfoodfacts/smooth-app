import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class KnowledgePanelProductCards extends StatelessWidget {
  const KnowledgePanelProductCards(this.knowledgePanelWidgets);

  final List<Widget> knowledgePanelWidgets;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    final List<Widget> widgetsWrappedInSmoothCards =
        knowledgePanelWidgets.map((Widget widget) {
      /// When we have a panel with a title (e.g. "Health"), we change
      /// a bit the layout
      final bool hasTitle =
          widget is Column && widget.children.first is KnowledgePanelTitle;
      final Widget content;

      if (hasTitle) {
        content = buildProductSmoothCard(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: context.lightTheme()
                      ? colors.primaryMedium
                      : colors.primarySemiDark,
                  borderRadius: const BorderRadius.vertical(
                    top: ROUNDED_RADIUS,
                  ),
                ),
                width: double.infinity,
                padding: const EdgeInsetsDirectional.symmetric(
                  vertical: SMALL_SPACE,
                ),
                child: Center(child: widget.children.first),
              ),
              Padding(
                padding: SMOOTH_CARD_PADDING,
                child: Column(
                  children: widget.children.sublist(1),
                ),
              ),
            ],
          ),
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
        );
      } else {
        content = buildProductSmoothCard(
          body: widget,
          padding: SMOOTH_CARD_PADDING,
          margin: EdgeInsets.zero,
        );
      }

      return Padding(
        padding: const EdgeInsetsDirectional.only(top: VERY_LARGE_SPACE),
        child: content,
      );
    }).toList(growable: false);

    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          bottom: SMALL_SPACE,
          start: SMALL_SPACE,
          end: SMALL_SPACE,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgetsWrappedInSmoothCards,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('count', knowledgePanelWidgets.length));
  }
}
