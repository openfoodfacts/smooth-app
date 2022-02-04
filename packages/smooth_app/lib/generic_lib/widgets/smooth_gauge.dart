import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class SmoothGauge extends StatelessWidget {
  const SmoothGauge({
    required this.value,
    this.size = 80.0,
    required this.color,
    this.backgroundColor,
    this.circular = true,
    this.width = 100.0,
  });

  final double value;
  final double size;
  final Color color;
  final Color? backgroundColor;
  final bool circular;
  final double width;

  @override
  Widget build(BuildContext context) {
    return circular
        ? CircularPercentIndicator(
            radius: size,
            lineWidth: 5.0,
            percent: value <= 1.0 ? value : 1.0,
            center: Text(
              '${(value * 100).floor()}%',
              style: TextStyle(color: color),
            ),
            progressColor: color,
            backgroundColor: backgroundColor ?? color.withAlpha(50),
            circularStrokeCap: CircularStrokeCap.round,
          )
        : LinearPercentIndicator(
            width: width,
            percent: value <= 1.0 ? value : 1.0,
            progressColor: color,
            backgroundColor: backgroundColor ?? color.withAlpha(50),
          );
  }
}
