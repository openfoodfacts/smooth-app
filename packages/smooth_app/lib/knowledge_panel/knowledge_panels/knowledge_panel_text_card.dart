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
    final Widget text = SmoothHtmlWidget(
      textElement.html,
      textStyle: WellSpacedTextHelper.TEXT_STYLE_WITH_WELL_SPACED,
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
              false,
            ),
          ),
        ),
      ],
    );
  }

  bool get _hasSource =>
      textElement.sourceText?.isNotEmpty == true &&
      textElement.sourceUrl?.isNotEmpty == true;
}
