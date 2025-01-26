import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/html/smooth_html_widget.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

/// Card that displays a Knowledge Panel _Text_ element.
class KnowledgePanelTextCard extends StatelessWidget {
  const KnowledgePanelTextCard({
    required this.textElement,
  });

  final KnowledgePanelTextElement textElement;

  @override
  Widget build(BuildContext context) {
    final String warningLabel =
        AppLocalizations.of(context).knowledge_panel_warning_text;
    final RegExp regExp = RegExp('$warningLabel\\s?:\\s?');

    final Widget text;

    if (textElement.html.startsWith(regExp)) {
      text = _KnowledgePanelWarningTextCard(
        title: warningLabel,
        text: textElement.html.replaceFirst(regExp, '').trim(),
      );
    } else {
      text = Padding(
        padding: const EdgeInsetsDirectional.only(
          top: SMALL_SPACE,
          start: SMALL_SPACE,
          end: SMALL_SPACE,
        ),
        child: MergeSemantics(
          child: SmoothHtmlWidget(
            textElement.html,
            textStyle:
                WellSpacedTextHelper.TEXT_STYLE_WITH_WELL_SPACED.copyWith(
              fontSize: 15.5,
            ),
          ),
        ),
      );
    }

    if (!_hasSource) {
      return text;
    }

    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        text,
        const SizedBox(height: MEDIUM_SPACE),
        // TODO(g123k): Would it be difficult to remove the Icon directly?
        // Remove Icon
        IconTheme.merge(
          data: const IconThemeData(
            size: 0.0,
          ),
          child: addPanelButton(
            appLocalizations
                .knowledge_panel_text_source(textElement.sourceText!),
            trailingIcon: Icon(ConstantIcons.forwardIcon),
            onPressed: () async => LaunchUrlHelper.launchURLInWebViewOrBrowser(
              context,
              textElement.sourceUrl!,
            ),
            borderRadius: ANGULAR_BORDER_RADIUS,
            elevation: const WidgetStatePropertyAll<double>(0.5),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 0,
              vertical: BALANCED_SPACE,
            ),
          ),
        ),
      ],
    );
  }

  bool get _hasSource =>
      textElement.sourceText?.isNotEmpty == true &&
      textElement.sourceUrl?.isNotEmpty == true;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('text', textElement.sourceText));
    properties.add(StringProperty('url', textElement.sourceUrl));
  }
}

/// Custom layout for texts starting with "Warning: ".
class _KnowledgePanelWarningTextCard extends StatelessWidget {
  const _KnowledgePanelWarningTextCard({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: BALANCED_SPACE),
      child: SelectionArea(
        child: SmoothCardWithRoundedHeader(
          title: title,
          titleBackgroundColor: const Color(0xFF666666),
          contentBackgroundColor: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(14.0),
          leading: const Padding(
            padding: EdgeInsetsDirectional.only(
              bottom: 1.0,
              end: 1.0,
            ),
            child: icons.Warning(size: 15.0),
          ),
          contentPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: LARGE_SPACE,
            vertical: BALANCED_SPACE,
          ),
          child: Text(
            text.firstLetterInUppercase(),
            style: const TextStyle(
              color: Colors.black,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
