import 'package:flutter/material.dart';

/// Row that displays two widgets on same width columns (half max width).
class KnowledgePanelSimplifiedRow extends StatelessWidget {
  const KnowledgePanelSimplifiedRow(this.widget1, this.widget2);

  final Widget widget1;
  final Widget widget2;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (
          final BuildContext context,
          final BoxConstraints constraints,
        ) =>
            Row(
          children: <Widget>[
            SizedBox(width: constraints.maxWidth / 2, child: widget1),
            SizedBox(width: constraints.maxWidth / 2, child: widget2),
          ],
        ),
      );
}
