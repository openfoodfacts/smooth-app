import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/hunger_games/question_image_full_page.dart';

/// Thumbnail of a question image.
class QuestionImageThumbnail extends StatelessWidget {
  const QuestionImageThumbnail(this.question);

  final RobotoffQuestion question;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
      decoration: const BoxDecoration(color: Colors.black12),
      child: GestureDetector(
        onTap: () async => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => QuestionImageFullPage(question),
            fullscreenDialog: true,
          ),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Image.network(
                question.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => EMPTY_WIDGET,
                loadingBuilder: (
                  BuildContext context,
                  Widget child,
                  ImageChunkEvent? loadingProgress,
                ) {
                  if (loadingProgress == null) {
                    // TODO(monsieurtanuki): remove this when the image is not null anymore
                    return child;
                  }
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
