import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/category_cards/abstract_cache.dart';
import 'package:smooth_app/cards/category_cards/svg_cache.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/ui_helpers.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels_builder.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/text/text_extensions.dart';
import 'package:smooth_app/widgets/text/text_style_extensions.dart';

class KnowledgePanelTitleCard extends StatelessWidget {
  const KnowledgePanelTitleCard({
    required this.knowledgePanelTitleElement,
    required this.isClickable,
    this.evaluation,
    this.textStyleOverride,
  });

  final TitleElement knowledgePanelTitleElement;
  final Evaluation? evaluation;
  final bool isClickable;
  final TextStyle? textStyleOverride;

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    Color? colorFromEvaluation, backgroundIconColor, iconColor, textColor;

    IconData? iconData;
    if (userPreferences.getFlag(
          UserPreferencesDevMode.userPreferencesFlagAccessibilityEmoji,
        ) ??
        false) {
      iconData = _getIconDataFromEvaluation(evaluation);
    }
    if (!(userPreferences.getFlag(
          UserPreferencesDevMode.userPreferencesFlagAccessibilityNoColor,
        ) ??
        false)) {
      if (knowledgePanelTitleElement.iconColorFromEvaluation ?? false) {
        colorFromEvaluation = KnowledgePanelsBuilder.getColorFromEvaluation(
          context,
          evaluation,
        );
        backgroundIconColor = colorFromEvaluation;

        iconColor = colorFromEvaluation != null
            ? theme.primaryLight
            : theme.primaryDark;

        textColor =
            colorFromEvaluation ??
            (context.lightTheme()
                ? theme.primaryUltraBlack
                : theme.primaryLight);
      }
    }

    backgroundIconColor ??= lightTheme
        ? theme.primaryLight
        : theme.primaryMedium;

    textColor ??= lightTheme ? theme.primaryUltraBlack : theme.primaryLight;

    List<Widget>? iconWidget;
    if (knowledgePanelTitleElement.iconUrl != null) {
      iconWidget = <Widget>[
        Expanded(
          flex: IconWidgetSizer.getIconFlex(),
          child: _KnowledgePanelTitleIcon(
            url: knowledgePanelTitleElement.iconUrl!,
            backgroundColor: backgroundIconColor,
            tintColor: iconColor,
          ),
        ),
        const Padding(padding: EdgeInsetsDirectional.only(start: SMALL_SPACE)),
        if (iconData != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: SMALL_SPACE),
            child: Icon(iconData),
          ),
      ];
    }

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        vertical: iconWidget == null ? MEDIUM_SPACE : BALANCED_SPACE,
      ),
      child: Semantics(
        value: _generateSemanticsValue(context),
        button: isClickable,
        container: true,
        excludeSemantics: true,
        child: Row(
          children: <Widget>[
            if (iconWidget != null)
              ...iconWidget
            else
              const SizedBox(width: VERY_SMALL_SPACE),
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
                          style:
                              textStyleOverride ??
                              TextStyle(
                                color: textColor,
                                fontSize: hasSubtitle ? 15.5 : 15.0,
                                fontWeight: isClickable
                                    ? FontWeight.w600
                                    : hasSubtitle
                                    ? FontWeight.bold
                                    : FontWeight.w600,
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
                              style:
                                  (textStyleOverride ??
                                          WellSpacedTextHelper
                                              .TEXT_STYLE_WITH_WELL_SPACED
                                              .copyWith(color: textColor))
                                      .copyWith(fontWeight: FontWeight.w500),
                            ).selectable(isSelectable: !isClickable),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            if (isClickable)
              icons.AppIconTheme(
                color: lightTheme ? theme.greyDark : theme.greyLight,
                size: 15.0,
                child: icons.Chevron.horizontalDirectional(context),
              ),
          ],
        ),
      ),
    );
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
    properties.add(DiagnosticsProperty<bool>('clickable', isClickable));
    properties.add(EnumProperty<Evaluation>('evaluation', evaluation));
  }
}

class _KnowledgePanelTitleIcon extends StatelessWidget {
  const _KnowledgePanelTitleIcon({
    required this.url,
    this.backgroundColor,
    this.tintColor,
  });

  final Color? backgroundColor;
  final Color? tintColor;
  final String url;

  @override
  Widget build(BuildContext context) {
    final bool rounded =
        context.read<KnowledgePanelTitleConfig?>()?.roundedIcon ?? true;

    if (rounded) {
      return CircleAvatar(
        backgroundColor: backgroundColor,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(SMALL_SPACE),
          child: Center(child: _buildIcon(context, 24.0)),
        ),
      );
    } else {
      return Center(child: _buildIcon(context, 36.0));
    }
  }

  Widget _buildIcon(BuildContext context, double size) {
    if (url == 'https://static.openfoodfacts.org/images/misc/moderate.svg') {
      return CircleAvatar(
        backgroundColor: context
            .extension<SmoothColorsThemeExtension>()
            .warning,
      );
    } else if (url == 'https://static.openfoodfacts.org/images/misc/high.svg') {
      return CircleAvatar(
        backgroundColor: context.extension<SmoothColorsThemeExtension>().error,
      );
    } else if (url == 'https://static.openfoodfacts.org/images/misc/low.svg') {
      return CircleAvatar(
        backgroundColor: context
            .extension<SmoothColorsThemeExtension>()
            .success,
      );
    }

    return AbstractCache.best(
      iconUrl: url,
      width: size,
      height: size,
      color: tintColor,
    );
  }
}

@immutable
class KnowledgePanelTitleConfig {
  const KnowledgePanelTitleConfig({required this.roundedIcon});

  final bool roundedIcon;
}
