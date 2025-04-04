import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rive/rive.dart' show RiveAnimation;
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/smooth_indicator_icon.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

class PinchToZoomExplainer extends StatelessWidget {
  const PinchToZoomExplainer();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return ExcludeSemantics(
      child: Tooltip(
        message: appLocalizations
            .edit_product_form_item_ingredients_pinch_to_zoom_tooltip,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            showSmoothModalSheet(
              context: context,
              builder: (BuildContext context) {
                final double width = MediaQuery.sizeOf(context).width * 0.5;

                return SmoothModalSheet(
                  title: appLocalizations
                      .edit_product_form_item_ingredients_pinch_to_zoom_title,
                  prefixIndicator: true,
                  body: SafeArea(
                    child: Column(
                      children: <Widget>[
                        TextWithBoldParts(
                          text: appLocalizations
                              .edit_product_form_item_ingredients_pinch_to_zoom_message,
                          textStyle: const TextStyle(fontSize: 15.0),
                        ),
                        const SizedBox(height: LARGE_SPACE),
                        ExcludeSemantics(
                          child: SizedBox(
                            width: width,
                            height: (width * 172.0) / 247.0,
                            child: const RiveAnimation.asset(
                              'assets/animations/explanations.riv',
                              artboard: 'pinch-to-zoom',
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: const SmoothIndicatorIcon(
            icon: icons.PinchToZoom(),
          ),
        ),
      ),
    );
  }
}
