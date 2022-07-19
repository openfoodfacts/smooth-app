import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';

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
        padding: const EdgeInsetsDirectional.only(
          top: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
        child: Text(title, style: Theme.of(context).textTheme.headline4),
      ),
      subtitle: Padding(
        padding: const EdgeInsetsDirectional.only(
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

/// A preference allowing to choose between a list of items.
/// Before clicking on an item, the selected value is displayed via its [title]
/// and [subtitle]
///
/// [labels] contains all the visible labels for the user in the dialog
/// For each item, a [descriptions] can be provided (displayed below [labels])
/// [values] are of type [T] and are returned according to the selected value
/// A [currentValue] can be provided to auto-select a value
class UserPreferencesMultipleChoicesItem<T> extends StatelessWidget {
  const UserPreferencesMultipleChoicesItem({
    required this.title,
    required this.subtitle,
    required this.labels,
    required this.values,
    required this.currentValue,
    required this.onChanged,
    this.descriptions,
    this.dialogHeight,
    Key? key,
  })  : assert(labels.length > 0),
        assert(values.length == labels.length),
        assert(descriptions == null || descriptions.length == labels.length),
        assert(dialogHeight == null || dialogHeight > 0.0),
        super(key: key);

  final String title;
  final String subtitle;
  final Iterable<String> labels;
  final Iterable<String>? descriptions;
  final Iterable<T> values;
  final T? currentValue;
  final ValueChanged<T>? onChanged;
  final double? dialogHeight;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
        child: Text(title, style: Theme.of(context).textTheme.headline4),
      ),
      subtitle: Padding(
        padding: const EdgeInsetsDirectional.only(
          bottom: SMALL_SPACE,
        ),
        child: Text(
          subtitle,
          style: const TextStyle(height: 1.5),
        ),
      ),
      onTap: () async {
        final T? res = await showDialog<T>(
            context: context,
            builder: (BuildContext context) {
              final AppLocalizations appLocalizations =
                  AppLocalizations.of(context);

              return SmoothAlertDialog(
                title: title,
                body: SizedBox(
                  height: dialogHeight ?? 250.0,
                  child: Scrollbar(
                    child: ListView.builder(
                        itemCount: labels.length,
                        itemBuilder: (BuildContext context, int position) {
                          final bool selected =
                              currentValue == values.elementAt(position);
                          final Color? selectedColor =
                              selected ? Theme.of(context).primaryColor : null;

                          return ColoredBox(
                            color: selectedColor?.withOpacity(0.1) ??
                                Colors.transparent,
                            child: ListTile(
                              title: Text(
                                labels.elementAt(position),
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              subtitle: descriptions != null
                                  ? Text(descriptions!.elementAt(position))
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: LARGE_SPACE,
                                vertical: 5.0,
                              ),
                              onTap: () {
                                Navigator.of(context)
                                    .pop(values.elementAt(position));
                              },
                            ),
                          );
                        }),
                  ),
                ),
                negativeAction: SmoothActionButton(
                  text: appLocalizations.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              );
            });

        if (res != null) {
          onChanged?.call(res);
        }
      },
      isThreeLine: true,
    );
  }
}

class UserPreferencesTitle extends StatelessWidget {
  const UserPreferencesTitle({required this.label, Key? key})
      : assert(label.length > 0),
        super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: SMALL_SPACE,
          bottom: MEDIUM_SPACE,
          // Horizontal = same as ListTile
          start: LARGE_SPACE,
          end: LARGE_SPACE,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.headline3?.copyWith(
                height: 2.5,
              ),
        ),
      ),
    );
  }
}
