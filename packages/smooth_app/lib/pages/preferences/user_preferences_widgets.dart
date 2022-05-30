import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

/// A dashed line
class UserPreferencesListItemDivider extends StatelessWidget {
  const UserPreferencesListItemDivider({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LARGE_SPACE,
      ),
      child: CustomPaint(
        size: const Size(
          double.infinity,
          1.0,
        ),
        painter: _DashedLinePainter(
          color: Theme.of(context).dividerColor,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({
    required Color color,
  }) : _paint = Paint()
          ..color = color
          ..strokeWidth = 1.0;

  static const double _DASHED_WIDTH = 3.0;
  static const double _DASHED_SPACE = 3.0;

  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    double startX = 0.0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + _DASHED_WIDTH, 0),
        _paint,
      );

      startX += _DASHED_WIDTH + _DASHED_SPACE;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class UserPreferencesSwitchItem extends StatelessWidget {
  const UserPreferencesSwitchItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      title: Padding(
        padding: const EdgeInsets.only(
          top: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
        child: Text(title, style: Theme.of(context).textTheme.headline4),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(
          bottom: SMALL_SPACE,
        ),
        child: Text(
          subtitle,
          style: const TextStyle(height: 1.5),
        ),
      ),
      value: value,
      onChanged: onChanged,
      isThreeLine: true,
    );
  }
}
