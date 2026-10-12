import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smooth_app/generic_lib/empty_screen_layout.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:vector_graphics/vector_graphics.dart';

class FolksonomyEmptyPage extends StatelessWidget {
  const FolksonomyEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return EmptyScreenLayout(
      icon: const SvgPicture(
        AssetBytesLoader('assets/icons/property_empty.svg.vec'),
      ),
      title: appLocalizations.product_tags_empty,
      explanation: appLocalizations.product_tags_explanation,
    );
  }
}
