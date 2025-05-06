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
                flightShuttleBuilder: (
                  BuildContext flightContext,
                  Animation<double> animation,
                  HeroFlightDirection flightDirection,
                  BuildContext fromHeroContext,
                  BuildContext toHeroContext,
                ) {
                  return AnimatedBuilder(
                      animation: animation,
                      builder: (BuildContext context, _) {
                        if (flightDirection == HeroFlightDirection.push) {
                          return ClipRect(
                              clipper: MyRectClipper(animation.value, fromHeroContext.widget),
                              child: toHeroContext.widget);
                        } else {
                          return ClipRect(
                            clipper: MyRectClipper(animation.value, toHeroContext.widget.),
                            child: toHeroContext.widget,
                          );
                        }
                      });
                },
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

class MyRectClipper extends CustomClipper<Rect> {
  MyRectClipper(this.progress, this.size);

  final double progress;
  final Size size;

  @override
  Rect getClip(Size size) {
    print(size);
    return Rect.fromLTWH(0, 0, size.width, size.height * progress);
  }

  @override
  bool shouldReclip(MyRectClipper oldClipper) =>
      progress != oldClipper.progress;
}
