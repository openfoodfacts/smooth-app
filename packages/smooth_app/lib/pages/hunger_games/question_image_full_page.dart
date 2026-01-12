import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/helpers/launch_url_helper.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

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
  Widget build(BuildContext context) => SmoothScaffold(
    appBar: SmoothAppBar(
      title: AutoSizeText(
        '${question.question!} (${question.value!})',
        maxLines: 2,
      ),
    ),
    floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.zoom_in),
      onPressed: () async => LaunchUrlHelper.launchURL(
        _getBetterUrl(question.imageUrl!) ?? question.imageUrl!,
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

  // cf. https://github.com/openfoodfacts/smooth-app/issues/3065
  String? _getBetterUrl(final String url) {
    const int ascii0 = 48;
    const int ascii9 = 57;

    if (!url.endsWith('.400.jpg')) {
      return null;
    }
    final int pos = url.lastIndexOf('/');
    if (pos == -1) {
      return null;
    }
    final String newLastPart;
    final String lastPart = url.substring(pos + 1);
    final int firstChar = lastPart.codeUnitAt(0);
    if (firstChar >= ascii0 && firstChar <= ascii9) {
      // example: from 2.400.jpg to 2.jpg
      newLastPart = lastPart.replaceAll('.400.', '.');
    } else {
      // example: from front_fr.4.400.jpg to front_fr.4.full.jpg
      newLastPart = lastPart.replaceAll('.400.', '.full.');
    }
    return url.replaceFirst(lastPart, newLastPart);
  }
}
