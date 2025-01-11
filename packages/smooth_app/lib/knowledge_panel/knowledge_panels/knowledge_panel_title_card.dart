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
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/themes/theme_provider.dart';
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
      iconData = _getIconDataFromEvaluation(evaluation);
    }
    if (!(userPreferences.getFlag(
            UserPreferencesDevMode.userPreferencesFlagAccessibilityNoColor) ??
        false)) {
      if (knowledgePanelTitleElement.iconColorFromEvaluation ?? false) {
        if (context.darkTheme()) {
          colorFromEvaluation = _getColorFromEvaluationDarkMode(evaluation);
        } else {
          colorFromEvaluation = _getColorFromEvaluation(evaluation);
        }
      }
    }

    List<Widget> iconWidget;
    if (knowledgePanelTitleElement.iconUrl != null) {
      iconWidget = <Widget>[
        Expanded(
          flex: IconWidgetSizer.getIconFlex(),
          child: Center(
            child: AbstractCache.best(
              iconUrl: _rewriteIconUrl(
                context,
                knowledgePanelTitleElement.iconUrl,
              ),
              width: 36.0,
              height: 36.0,
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
        container: true,
        excludeSemantics: true,
        child: Row(
          children: <Widget>[
            ...iconWidget,
            Expanded(
              flex: IconWidgetSizer.getRemainingWidgetFlex(),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool hasSubtitle =
                      knowledgePanelTitleElement.subtitle != null;

                  return Wrap(
                    direction: Axis.vertical,
                    children: <Widget>[
                      SizedBox(
                        width: constraints.maxWidth,
                        child: Text(
                          knowledgePanelTitleElement.title,
                          style: TextStyle(
                            color: colorFromEvaluation,
                            fontSize: hasSubtitle ? 15.5 : 15.0,
                            fontWeight: hasSubtitle
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (hasSubtitle)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            top: VERY_SMALL_SPACE,
                          ),
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: Text(
                              knowledgePanelTitleElement.subtitle!,
                              style: WellSpacedTextHelper
                                  .TEXT_STYLE_WITH_WELL_SPACED,
                            ).selectable(isSelectable: !isClickable),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            if (isClickable) Icon(ConstantIcons.forwardIcon),
          ],
        ),
      ),
    );
  }

  Color _getColorFromEvaluation(Evaluation? evaluation) {
    switch (evaluation) {
      case Evaluation.BAD:
        return RED_COLOR;
      case Evaluation.AVERAGE:
        return LIGHT_ORANGE_COLOR;
      case Evaluation.GOOD:
        return LIGHT_GREEN_COLOR;
      case null:
      case Evaluation.NEUTRAL:
      case Evaluation.UNKNOWN:
        return PRIMARY_GREY_COLOR;
    }
  }

  Color _getColorFromEvaluationDarkMode(Evaluation? evaluation) {
    switch (evaluation) {
      case Evaluation.BAD:
        return RED_COLOR;
      case Evaluation.AVERAGE:
        return LIGHT_ORANGE_COLOR;
      case Evaluation.GOOD:
        return LIGHT_GREEN_COLOR;
      case null:
      case Evaluation.NEUTRAL:
      case Evaluation.UNKNOWN:
        return Colors.white;
    }
  }

  IconData? _getIconDataFromEvaluation(Evaluation? evaluation) {
    switch (evaluation) {
      case Evaluation.BAD:
        return Icons.sentiment_very_dissatisfied;
      case Evaluation.AVERAGE:
        return Icons.sentiment_satisfied;
      case Evaluation.GOOD:
        return Icons.sentiment_very_satisfied;
      case null:
      case Evaluation.NEUTRAL:
      case Evaluation.UNKNOWN:
        return null;
    }
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

  String? _rewriteIconUrl(BuildContext context, String? iconUrl) {
    final bool lightTheme = context.lightTheme();

    if (iconUrl ==
            'https://static.openfoodfacts.org/images/logos/off-logo-icon-light.svg' &&
        !lightTheme) {
      return 'https://static.openfoodfacts.org/images/logos/off-logo-icon-dark.svg';
    }

    return iconUrl;
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
