import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class SmoothProductCardThanks extends StatelessWidget {
  const SmoothProductCardThanks();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: ROUNDED_BORDER_RADIUS,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(AppLocalizations.of(context)!.added_product_thanks),
          const SizedBox(
            height: 12.0,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                'assets/misc/checkmark.svg',
                width: 36.0,
                height: 36.0,
                color: Colors.greenAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
