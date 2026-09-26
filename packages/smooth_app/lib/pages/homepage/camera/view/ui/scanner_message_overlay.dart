import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class HomePageScannerMessageOverlay extends StatelessWidget {
  const HomePageScannerMessageOverlay({required this.message, super.key})
    : assert(message.length > 0);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      tooltip: message,
      excludeSemantics: true,
      child: IgnorePointer(
        ignoring: true,
        child: FractionallySizedBox(
          widthFactor: 0.85,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: ROUNDED_BORDER_RADIUS,
              border: Border.all(color: const Color(0x33FFFFFF), width: 1.0),
              color: const Color(0x33FFFFFF),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: <Widget>[
                  const Expanded(
                    flex: 15,
                    child: Center(
                      child: icons.Info(size: 28.0, color: Colors.white),
                    ),
                  ),
                  const VerticalDivider(color: Color(0x33FFFFFF), width: 1.0),
                  Expanded(
                    flex: 75,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          vertical: 14.0,
                          horizontal: 20.0,
                        ),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            shadows: <Shadow>[
                              Shadow(color: Colors.black, blurRadius: 10.0),
                            ],
                          ),
                        ),
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
