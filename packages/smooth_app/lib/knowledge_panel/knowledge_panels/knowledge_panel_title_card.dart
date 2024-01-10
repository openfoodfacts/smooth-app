import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/category_cards/abstract_cache.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/pages/product/big_redesign/evaluation_extension.dart';
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

class KnowledgePanelTitleCard extends StatelessWidget {
  const KnowledgePanelTitleCard({
    required this.knowledgePanelTitleElement,
    required this.isClickable,
    this.evaluation,
  });

  final TitleElement knowledgePanelTitleElement;
  final Evaluation? evaluation;
  final bool isClickable;

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    Color? colorFromEvaluation;
    IconData? iconData;
    if (userPreferences.getFlag(
            UserPreferencesDevMode.userPreferencesFlagAccessibilityEmoji) ??
        false) {
      iconData = evaluation.getA11YIconData();
    }
    if (!(userPreferences.getFlag(
            UserPreferencesDevMode.userPreferencesFlagAccessibilityNoColor) ??
        false)) {
      final ThemeData themeData = Theme.of(context);
      if (knowledgePanelTitleElement.iconColorFromEvaluation ?? false) {
        colorFromEvaluation = evaluation.getColor(themeData.brightness);
      }
    }
    List<Widget> iconWidget;
    if (knowledgePanelTitleElement.iconUrl != null) {
      iconWidget = <Widget>[
        Expanded(
          flex: IconWidgetSizer.getIconFlex(),
          child: Center(
            child: AbstractCache.best(
              iconUrl: knowledgePanelTitleElement.iconUrl,
              width: 36,
              height: 36,
              color: colorFromEvaluation,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsetsDirectional.only(start: SMALL_SPACE),
        ),
        if (iconData != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: SMALL_SPACE),
            child: Icon(iconData),
          ),
      ];
    } else {
      iconWidget = <Widget>[];
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: VERY_SMALL_SPACE,
        bottom: VERY_SMALL_SPACE,
      ),
      child: Semantics(
        value: _generateSemanticsValue(context),
        button: isClickable,
        excludeSemantics: true,
        child: Row(
          children: <Widget>[
            ...iconWidget,
            Expanded(
              flex: IconWidgetSizer.getRemainingWidgetFlex(),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Wrap(
                    direction: Axis.vertical,
                    children: <Widget>[
                      SizedBox(
                        width: constraints.maxWidth,
                        child: Text(
                          knowledgePanelTitleElement.title,
                          style: TextStyle(color: colorFromEvaluation),
                        ),
                      ),
                      if (knowledgePanelTitleElement.subtitle != null)
                        SizedBox(
                          width: constraints.maxWidth,
                          child: Text(
                            knowledgePanelTitleElement.subtitle!,
                            style: WellSpacedTextHelper
                                .TEXT_STYLE_WITH_WELL_SPACED,
                          ).selectable(isSelectable: !isClickable),
                        ),
                    ],
                  );
                },
              ),
            ),
            if (isClickable) Icon(ConstantIcons.instance.getForwardIcon()),
          ],
        ),
      ),
    );
  }

  String _generateSemanticsValue(BuildContext context) {
    final StringBuffer buffer = StringBuffer();

    if (knowledgePanelTitleElement.iconUrl != null) {
      final String? label = SvgCache.getSemanticsLabel(
        context,
        knowledgePanelTitleElement.iconUrl!,
      );
      if (label != null) {
        buffer.write('$label: ');
      }
    }

    buffer.write(knowledgePanelTitleElement.title);
    if (knowledgePanelTitleElement.subtitle != null) {
      buffer.write('\n${knowledgePanelTitleElement.subtitle}');
    }

    return buffer.toString();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(
      StringProperty('iconUrl', knowledgePanelTitleElement.iconUrl),
    );
    properties.add(
      EnumProperty<TitleElementType>('type', knowledgePanelTitleElement.type),
    );
    properties.add(
      EnumProperty<Grade>('grade', knowledgePanelTitleElement.grade),
    );
    properties.add(
      DiagnosticsProperty<bool>('clickable', isClickable),
    );
    properties.add(EnumProperty<Evaluation>('evaluation', evaluation));
  }
}
