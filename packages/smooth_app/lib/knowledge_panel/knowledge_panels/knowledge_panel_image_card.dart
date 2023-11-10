import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Card that displays a Knowledge Panel _Image_ element.
class KnowledgePanelImageCard extends StatelessWidget {
  const KnowledgePanelImageCard({
    required this.imageElement,
  });

  final KnowledgePanelImageElement imageElement;

  // TODO(g123k): It would be nice to provide a Placeholder
  @override
  Widget build(BuildContext context) => Image.network(
        imageElement.url,
        width: imageElement.width?.toDouble(),
        height: imageElement.height?.toDouble(),
      );
}
