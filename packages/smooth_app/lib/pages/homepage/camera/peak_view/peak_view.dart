import 'package:flutter/material.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/homepage/homepage.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/text/text_highlighter.dart';

class HomePageScannerPeakView extends StatelessWidget {
  const HomePageScannerPeakView({
    required this.progress,
    required this.opacity,
    required this.onTap,
    super.key,
  });

  final double opacity;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Offstage(
      offstage: progress == 1.0 || progress == 0.0,
      child: Opacity(
        opacity: opacity,
        child: InkWell(
          onTap: opacity > 0.0 ? onTap : null,
          child: SizedBox(
            height: size.height * HomePage.CAMERA_PEAK,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    margin: EdgeInsetsDirectional.only(
                      top: MediaQuery.viewPaddingOf(context).top * 0.25,
                    ),
                    padding: const EdgeInsetsDirectional.all(25.0),
                    child: icons.Barcode.withCorners(
                      size: 37.0,
                      color: Colors.white,
                      shadow: Shadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  FractionallySizedBox(
                    widthFactor: 0.75,
                    child: TextWithBoldParts(
                      text: AppLocalizations.of(
                        context,
                      ).homepage_scanner_overlay_message,
                      textAlign: TextAlign.center,
                      textStyle: DefaultTextStyle.of(context).style.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.5,
                        height: 1.7,
                        shadows: <Shadow>[
                          const Shadow(color: Colors.black, blurRadius: 10.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
