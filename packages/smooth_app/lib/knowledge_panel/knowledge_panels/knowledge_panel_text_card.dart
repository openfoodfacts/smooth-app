import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/smooth_html_widget.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/helpers/product_cards_helper.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

/// Card that displays a Knowledge Panel _Text_ element.
class KnowledgePanelTextCard extends StatelessWidget {
  const KnowledgePanelTextCard({
    required this.textElement,
  });

  final KnowledgePanelTextElement textElement;

  @override
  Widget build(BuildContext context) {
    final Widget text = MergeSemantics(
      child: SmoothHtmlWidget(
        textElement.html,
        textStyle: WellSpacedTextHelper.TEXT_STYLE_WITH_WELL_SPACED.copyWith(
          fontSize: 15.0,
        ),
      ),
    );

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
            iconData: null,
            onPressed: () async => LaunchUrlHelper.launchURL(
              textElement.sourceUrl!,
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
