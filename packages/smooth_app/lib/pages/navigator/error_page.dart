import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_large_button_with_icon.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';

/// Similar to a 404 page
class ErrorPage extends StatelessWidget {
  const ErrorPage({
    required this.url,
    super.key,
  });

  final String url;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SvgPicture.asset('assets/misc/error.svg'),
              const SizedBox(height: VERY_LARGE_SPACE),
              Text(
                localizations.page_not_found_title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: LARGE_SPACE),
              Text(
                url,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: VERY_LARGE_SPACE * 2),
              SmoothLargeButtonWithIcon(
                text: localizations.page_not_found_button,
                leadingIcon: const Icon(Icons.home),
                padding: const EdgeInsets.symmetric(vertical: LARGE_SPACE),
                onPressed: () {
                  AppNavigator.of(context).pop();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
