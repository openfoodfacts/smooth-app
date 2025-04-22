import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/hunger_games/question_image_full_page.dart';

/// Thumbnail of a question image.
class QuestionImageThumbnail extends StatelessWidget {
  const QuestionImageThumbnail(this.question);

  final RobotoffQuestion question;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
        decoration: const BoxDecoration(color: Colors.black12),
        child: GestureDetector(
            onTap: () async => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        QuestionImageFullPage(question),
                    fullscreenDialog: true,
                  ),
                ),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image(
                image: NetworkImage(question.imageUrl!),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => EMPTY_WIDGET,
                loadingBuilder: (
                  _,
                  Widget child,
                  ImageChunkEvent? progress,
                ) =>
                    progress == null
                        ? child
                        : const CircularProgressIndicator.adaptive(),
              ),
            )),
      );
}
