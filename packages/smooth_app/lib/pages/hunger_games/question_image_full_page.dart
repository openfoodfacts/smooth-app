import 'package:flutter/material.dart';
import 'package:smooth_app/themes/constant_icons.dart';

/// Zoomable full page of a question image.
class QuestionImageFullPage extends StatelessWidget {
  const QuestionImageFullPage(this.imageUrl);

  final String imageUrl;

  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(ConstantIcons.instance.getBackIcon()),
          onPressed: () => Navigator.of(context).pop(),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: InteractiveViewer(
            minScale: 0.1,
            maxScale: 5,
            child: Image(
              fit: BoxFit.contain,
              image: NetworkImage(imageUrl),
            ),
          ),
        ),
      );
}
