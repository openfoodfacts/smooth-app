import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/generated/l10n.dart';
import 'package:smooth_app/pages/alternative_continuous_scan_page.dart';
import 'package:smooth_app/pages/continuous_scan_page.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';

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
                S.of(context).featureInProgress,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(color: Colors.black),
              ),
              const SizedBox(
                height: 28.0,
              ),
              SmoothSimpleButton(
                text: 'Try the contribution scanner',
                width: 240.0,
                onPressed: () async {
                  final SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  final Widget newPage =
                      sharedPreferences.getBool('useMlKit') ?? true
                          ? ContinuousScanPage(
                              initializeWithContributionMode: true,
                            )
                          : AlternativeContinuousScanPage(
                              initializeWithContributionMode: true,
                            );
                  Navigator.push<Widget>(
                    context,
                    MaterialPageRoute<Widget>(
                        builder: (BuildContext context) => newPage),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
