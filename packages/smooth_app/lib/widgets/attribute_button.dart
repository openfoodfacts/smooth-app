import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/model/Attribute.dart';
import 'package:openfoodfacts/personalized_search/preference_importance.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';

const List<String> _importanceIds = <String>[
  PreferenceImportance.ID_NOT_IMPORTANT,
  PreferenceImportance.ID_IMPORTANT,
  PreferenceImportance.ID_VERY_IMPORTANT,
  PreferenceImportance.ID_MANDATORY,
];

/// Colored button for attribute importance, with corresponding action
class AttributeButton extends StatelessWidget {
  const AttributeButton(
    this.attribute,
    this.productPreferences,
  );

  final Attribute attribute;
  final ProductPreferences productPreferences;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final String importanceId =
        productPreferences.getImportanceIdForAttributeId(attribute.id!);
    final int index = productPreferences.getImportanceIndex(importanceId) ?? 0;
    const double horizontalPadding = LARGE_SPACE;
    final double widgetWidth =
        MediaQuery.of(context).size.width - 2 * horizontalPadding;
    final TextStyle style = themeData.textTheme.headline4!;
    final String? info = attribute.settingNote;
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: SMALL_SPACE,
        horizontal: horizontalPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            trailing: info == null ? null : const Icon(Icons.info_outline),
            title: AutoSizeText(
              attribute.settingName ?? attribute.name!,
              maxLines: 2,
              style: style,
            ),
            onTap: info == null
                ? null
                : () async => showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        final AppLocalizations appLocalizations =
                            AppLocalizations.of(context);
                        return SmoothAlertDialog(
                          body: Text(info),
                          positiveAction: SmoothActionButton(
                            text: appLocalizations.close,
                            onPressed: () => Navigator.pop(context),
                          ),
                        );
                      },
                    ),
          ),
          _ButtonRow(
            width: widgetWidth,
            productPreferences: productPreferences,
            attributeId: attribute.id!,
            selectedIndex: index,
          ),
          Center(
            child: Text(
              productPreferences
                  .getPreferenceImportanceFromImportanceId(
                      _importanceIds[index])!
                  .name!,
            ),
          ),
        ],
      ),
    );
  }
}

/// Row of importance buttons.
class _ButtonRow extends StatelessWidget {
  const _ButtonRow({
    required this.width,
    required this.selectedIndex,
    required this.attributeId,
    required this.productPreferences,
  });

  /// Row width.
  final double width;

  /// Current selected index.
  final int selectedIndex;
  final String attributeId;
  final ProductPreferences productPreferences;

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.primary;
    final int length = _importanceIds.length;
    const double spaceBetween = VERY_SMALL_SPACE;
    const double strokeWidth = spaceBetween / 2;
    final List<Widget> children = <Widget>[];
    final double trapezoidWidth = width / length - spaceBetween;
    double abscissaEvolution = 0;
    for (int i = 0; i < length; i++) {
      Widget child = SizedBox(
        width: trapezoidWidth,
        height: MINIMUM_TOUCH_SIZE,
        child: CustomPaint(
          painter: _TrapezoidPainter(
            empty: selectedIndex < i,
            color: color,
            yFactorLeft: abscissaEvolution / width,
            yFactorRight: (abscissaEvolution + trapezoidWidth) / width,
            strokeWidth: strokeWidth,
          ),
        ),
      );
      if (selectedIndex != i) {
        child = GestureDetector(
          onTap: () async => productPreferences.setImportance(
            attributeId,
            _importanceIds[i],
          ),
          child: child,
        );
      }
      children.add(child);
      children.add(const SizedBox(width: spaceBetween));
      abscissaEvolution += trapezoidWidth + spaceBetween;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

/// Paints a trapezoid with parallel vertical and a bottom horizontal lines.
///
/// The shape of the trapezoid comes from [yFactorLeft] and [yFactorRight].
/// Both are values between 0 and 1, to be applied to the height.
/// E.g. 0 means bottom, 1 means top.
/// E.g. the same value for both means a rectangle.
/// E.g. if one value is 0, then it's a right triangle.
/// E.g. if both values are 0, it's a flat line.
/// E.g. if both values are 1, it's a rectangle the size of its display box.
class _TrapezoidPainter extends CustomPainter {
  _TrapezoidPainter({
    required this.empty,
    required this.color,
    required this.strokeWidth,
    required this.yFactorLeft,
    required this.yFactorRight,
  });

  /// Is this trapezoid empty or full?
  final bool empty;

  /// Color of the trapezoid.
  final Color color;

  /// Stroke width.
  final double strokeWidth;

  /// Value between 0 and 1: y-factor for the left side.
  final double yFactorLeft;

  /// Value between 0 and 1: y-factor for the right side.
  final double yFactorRight;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * (1 - yFactorRight));
    path.lineTo(0, size.height * (1 - yFactorLeft));
    path.close();
    canvas.drawPath(path, paint);

    if (!empty) {
      final Paint paintFill = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paintFill);
    }
  }

  @override
  bool shouldRepaint(final CustomPainter oldDelegate) => true;
}
