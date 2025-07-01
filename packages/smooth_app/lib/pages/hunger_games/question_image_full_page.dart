import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';

/// Zoomable full page of a question image.
class QuestionImageFullPage extends StatelessWidget {
  const QuestionImageFullPage({
    required this.question,
    this.heroTag,
    super.key,
  });

  final RobotoffQuestion question;
  final String? heroTag;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: SmoothAppBar(
      title: AutoSizeText(
        '${question.question!} (${question.value!})',
        maxLines: 2,
      ),
    ),
    body: ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: InteractiveViewer(
        minScale: 0.1,
        maxScale: 5,
        child: HeroMode(
          enabled: heroTag?.isNotEmpty == true,
          child: Hero(
            tag: heroTag ?? '',
            child: Image(
              fit: BoxFit.contain,
              image: NetworkImage(question.imageUrl!),
            ),
          ),
        ),
      ),
    ),
  );
}
