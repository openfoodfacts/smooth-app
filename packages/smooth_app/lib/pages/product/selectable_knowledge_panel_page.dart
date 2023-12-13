import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/pages/product/reorderable_knowledge_panel_model.dart';
import 'package:smooth_app/pages/product/reorderable_knowledge_panel_page.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page where the user can select the Knowledge Panel Cards to reorder.
class SelectableKnowledgePanelPage extends StatefulWidget {
  const SelectableKnowledgePanelPage(this.product);

  final Product product;

  @override
  State<SelectableKnowledgePanelPage> createState() =>
      _SelectableKnowledgePanelPageState();
}

class _SelectableKnowledgePanelPageState
    extends State<SelectableKnowledgePanelPage> {
  late final ReorderableKnowledgePanelModel _model;

  @override
  void initState() {
    super.initState();
    _model = ReorderableKnowledgePanelModel(context.read<UserPreferences>());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final List<Widget> children = <Widget>[];
    final KnowledgePanels? panels = widget.product.knowledgePanels;
    if (panels != null) {
      for (final String panelId
          in ReorderableKnowledgePanelModel.initialOrder) {
        if (!panels.panelIdToPanelMap.containsKey(panelId)) {
          continue;
        }
        children.add(
          CheckboxListTile(
            title: KnowledgePanelCard(
              panelId: panelId,
              product: widget.product,
              isClickable: false,
            ),
            value: _model.selected.contains(panelId),
            onChanged: (final bool? value) => setState(
              () {
                if (value == null) {
                  return;
                }
                if (value) {
                  _model.addSelected(panelId);
                } else {
                  _model.removeSelected(panelId);
                }
                _model.saveSelected();
              },
            ),
          ),
        );
      }
    }
    if (children.isNotEmpty) {
      // for the FAB
      children.add(
        const SizedBox(height: VERY_LARGE_SPACE * 5),
      );
    }
    return SmoothScaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations.select_attribute_action,
          maxLines: 2,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => setState(() {
              _model.clearSelected();
              _model.saveSelected();
            }),
          )
        ],
      ),
      floatingActionButton: children.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () async => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ReorderableKnowledgePanelPage(widget.product),
                ),
              ),
              label: Text(appLocalizations.reorder_attribute_action),
            ),
      body: children.isEmpty ? null : ListView(children: children),
    );
  }
}
