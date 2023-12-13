import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/knowledge_panel/knowledge_panels/knowledge_panel_card.dart';
import 'package:smooth_app/pages/product/reorderable_knowledge_panel_model.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

/// Page where the user can reorder the Knowledge Panel Cards.
class ReorderableKnowledgePanelPage extends StatefulWidget {
  const ReorderableKnowledgePanelPage(this.product);

  final Product product;

  @override
  State<ReorderableKnowledgePanelPage> createState() =>
      _ReorderableKnowledgePanelPageState();
}

class _ReorderableKnowledgePanelPageState
    extends State<ReorderableKnowledgePanelPage> {
  late final ReorderableKnowledgePanelModel _model;

  @override
  void initState() {
    super.initState();
    _model = ReorderableKnowledgePanelModel(context.read<UserPreferences>());
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    int index = 0;
    for (final String panelId in _model.ordered) {
      children.add(
        ListTile(
          key: Key(panelId),
          title: KnowledgePanelCard(
            panelId: panelId,
            product: widget.product,
            isClickable: false,
          ),
          trailing: ReorderableDragStartListener(
            key: ValueKey<int>(index),
            index: index++,
            child: const Icon(Icons.drag_handle),
          ),
        ),
      );
    }
    return SmoothScaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).reorder_attribute_action,
          maxLines: 2,
        ),
      ),
      body: ReorderableListView(
        buildDefaultDragHandles: false,
        children: children,
        onReorder: (int oldIndex, int newIndex) => setState(
          () {
            _model.reorder(oldIndex, newIndex);
            _model.saveOrder();
          },
        ),
      ),
    );
  }
}
