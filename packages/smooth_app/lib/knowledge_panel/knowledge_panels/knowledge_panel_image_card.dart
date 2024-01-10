import 'package:flutter/foundation.dart';
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('url', imageElement.url));
    properties.add(IntProperty('width', imageElement.width));
    properties.add(IntProperty('height', imageElement.height));
  }
}
