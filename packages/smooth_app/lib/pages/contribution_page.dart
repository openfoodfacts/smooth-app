import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/pages/scan/scan_page.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';

// TODO(stephanegigandet): not used, to be deleted?
class CollaborationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmoothRevealAnimation(
        animationCurve: Curves.easeInOutBack,
        startOffset: const Offset(0.0, 0.1),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                'assets/misc/work_in_progress_alt_2.svg',
                width: MediaQuery.of(context).size.width * 0.6,
              ),
              const SizedBox(
                height: 28.0,
              ),
              Text(
                AppLocalizations.of(context)!.featureInProgress,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 28.0,
              ),
              SmoothSimpleButton(
                text: 'Try the contribution scanner',
                minWidth: 240.0,
                onPressed: () => Navigator.push<Widget>(
                  context,
                  MaterialPageRoute<Widget>(
                    builder: (BuildContext context) => const ScanPage(
                      contributionMode: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
