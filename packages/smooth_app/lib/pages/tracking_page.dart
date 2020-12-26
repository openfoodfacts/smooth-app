import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_app/generated/l10n.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';

class TrackingPage extends StatelessWidget {
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
                'assets/misc/work_in_progress_alt_3.svg',
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
            ],
          ),
        ),
      ),
    );
  }
}
