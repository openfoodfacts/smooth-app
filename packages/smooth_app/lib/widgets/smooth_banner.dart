import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class SmoothBanner extends StatelessWidget {
  const SmoothBanner({
    required this.icon,
    required this.title,
    required this.content,
    super.key,
  });

  final Widget icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 15,
            child: ExcludeSemantics(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFE4E4E4),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: LARGE_SPACE,
                  vertical: MEDIUM_SPACE,
                ),
                alignment: AlignmentDirectional.topCenter,
                child: IconTheme(
                  data: const IconThemeData(
                    color: Color(0xFF373737),
                  ),
                  child: icon,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 85,
            child: Container(
              width: double.infinity,
              color: const Color(0xFFECECEC),
              padding: const EdgeInsetsDirectional.only(
                start: MEDIUM_SPACE,
                end: MEDIUM_SPACE,
                top: BALANCED_SPACE,
                bottom: MEDIUM_SPACE,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF373737),
                    ),
                  ),
                  const SizedBox(height: VERY_SMALL_SPACE),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Color(0xFF373737),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
