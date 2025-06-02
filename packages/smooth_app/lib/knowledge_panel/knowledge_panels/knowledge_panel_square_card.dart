import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class KnowledgePanelSquareCard extends StatelessWidget {
  const KnowledgePanelSquareCard({
    required this.panels,
  }) : assert(panels.length == 4);

  final List<KnowledgePanel> panels;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            _buildPanel(panels[0]),
            const SizedBox(width: 8.0),
            _buildPanel(panels[1]),
          ],
        ),
        Row(
          children: <Widget>[
            _buildPanel(panels[2]),
            const SizedBox(width: 8.0),
            _buildPanel(panels[3]),
          ],
        )
      ],
    );
  }

  Widget _buildPanel(KnowledgePanel panel) {
    return Expanded(
      child: Container(
        height: 100.0,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(panel.titleElement?.title ?? 'No Title'),
            Text(panel.titleElement?.subtitle ?? 'No Title'),
          ],
        ),
      ),
    );
  }
}
