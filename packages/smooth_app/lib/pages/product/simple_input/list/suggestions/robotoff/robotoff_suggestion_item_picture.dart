import 'package:flutter/material.dart' hide Listener;
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/images/smooth_image.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class RobotoffSuggestionListItemPicture extends StatelessWidget {
  const RobotoffSuggestionListItemPicture({
    required this.onTap,
  });

  final Function(String heroTag) onTap;

  @override
  Widget build(BuildContext context) {
    final RobotoffQuestion question = context.watch<RobotoffQuestion>();

    final String? imageUrl = question.imageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return EMPTY_WIDGET;
    }

    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String heroTag = '$imageUrl ${question.insightId}';

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Material(
            child: Hero(
              tag: heroTag,
              child: Material(
                type: MaterialType.transparency,
                child: SmoothImage(
                  imageProvider: NetworkImage(imageUrl),
                  rounded: false,
                ),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          end: 0.0,
          bottom: 0.0,
          child: InkWell(
            onTap: () => onTap(heroTag),
            child: Tooltip(
              message: appLocalizations.product_edit_robotoff_expand_proof,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 20.0,
                  vertical: MEDIUM_SPACE,
                ),
                child: const ExcludeSemantics(
                  child: icons.Expand(
                    color: Colors.white,
                    size: 14.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
