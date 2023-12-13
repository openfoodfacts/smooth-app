import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/pages/product/reorderable_knowledge_panel_model.dart';
import 'package:smooth_app/pages/product/selectable_knowledge_panel_page.dart';

/// Knowledge Panel Cards as reordered by the user.
class ReorderedKnowledgePanelCards extends StatelessWidget {
  const ReorderedKnowledgePanelCards(this.product);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final List<String> order =
        ReorderableKnowledgePanelModel.getList(userPreferences);
    final List<Widget> children = <Widget>[];
    children.add(
      Text(
        'For me',
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
    for (final String panelId in order) {
      children.add(
        KnowledgePanelCard(
          panelId: panelId,
          product: product,
          isClickable: true,
        ),
      );
    }
    children.add(
      Padding(
        padding: const EdgeInsets.all(SMALL_SPACE),
        child: SmoothLargeButtonWithIcon(
          text: AppLocalizations.of(context).select_attribute_action,
          icon: Icons.sort,
          onPressed: () async => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => SelectableKnowledgePanelPage(product),
            ),
          ),
        ),
      ),
    );
    return SmoothCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
