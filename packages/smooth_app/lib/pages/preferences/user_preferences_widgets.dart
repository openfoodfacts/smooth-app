import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
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
        padding: const EdgeInsetsDirectional.only(
          top: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
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
      activeColor: Theme.of(context).primaryColor,
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
    required this.labels,
    required this.values,
    required this.currentValue,
    required this.onChanged,
    this.leading,
    this.leadingBuilder,
    this.descriptions,
    this.dialogHeight,
    Key? key,
  })  : assert(labels.length > 0),
        assert(values.length == labels.length),
        assert(descriptions == null || descriptions.length == labels.length),
        assert(dialogHeight == null || dialogHeight > 0.0),
        super(key: key);

  final String title;
  final IconData? leading;
  final Iterable<WidgetBuilder>? leadingBuilder;
  final Iterable<String> labels;
  final Iterable<String>? descriptions;
  final Iterable<T> values;
  final T? currentValue;
  final ValueChanged<T>? onChanged;
  final double? dialogHeight;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int currentValueIndex = _findCurrentValueIndex();

    return ListTile(
      title: Padding(
        padding: const EdgeInsetsDirectional.only(
          top: SMALL_SPACE,
          bottom: SMALL_SPACE,
        ),
        child: Text(
          title,
          style: theme.textTheme.headlineMedium,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: SMALL_SPACE,
          top: SMALL_SPACE,
          bottom: LARGE_SPACE,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (leadingBuilder != null)
              Builder(builder: leadingBuilder!.elementAt(currentValueIndex))
            else if (leading != null)
              Icon(leading),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: leadingBuilder != null || leading != null
                      ? LARGE_SPACE
                      : 0.0,
                  end: LARGE_SPACE,
                ),
                child: Text(
                  labels.elementAt(currentValueIndex),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const Icon(Icons.edit)
          ],
        ),
      ),
      onTap: () async {
        final double itemHeight = (descriptions != null ? 15.0 : 0.0) +
            (5.0 * 2) +
            (56.0 + Theme.of(context).visualDensity.baseSizeAdjustment.dy);

        final T? res;
        if (itemHeight * labels.length >
            MediaQuery.of(context).size.height * 0.8) {
          res = await showSmoothDraggableModalSheet<T>(
              context: context,
              header: SmoothModalSheetHeader(title: title),
              bodyBuilder: (BuildContext context) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: labels.length,
                    (BuildContext context, int position) {
                      final bool selected =
                          currentValue == values.elementAt(position);

                      return _ChoiceItem<T>(
                        selected: selected,
                        label: labels.elementAt(position),
                        value: values.elementAt(position),
                        description: descriptions?.elementAt(position),
                        leading: leadingBuilder != null
                            ? Builder(
                                builder: leadingBuilder!.elementAt(position))
                            : null,
                        hasDivider: position < labels.length - 1,
                      );
                    },
                  ),
                );
              });
        } else {
          res = await showSmoothModalSheet<T>(
            context: context,
            builder: (BuildContext context) {
              return SmoothModalSheet(
                title: title,
                bodyPadding: EdgeInsets.zero,
                body: SizedBox(
                  height: (itemHeight + 1.0) * labels.length,
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: labels.length,
                    itemBuilder: (BuildContext context, int position) {
                      final bool selected =
                          currentValue == values.elementAt(position);

                      return _ChoiceItem<T>(
                        selected: selected,
                        label: labels.elementAt(position),
                        value: values.elementAt(position),
                        description: descriptions?.elementAt(position),
                        leading: leadingBuilder != null
                            ? Builder(
                                builder: leadingBuilder!.elementAt(position))
                            : null,
                        hasDivider: false,
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1.0),
                  ),
                ),
              );
            },
          );
        }

        if (res != null) {
          onChanged?.call(res);
        }
      },
      isThreeLine: true,
    );
  }

  int _findCurrentValueIndex() {
    for (int i = 0; i < values.length; i++) {
      if (values.elementAt(i) == currentValue) {
        return i;
      }
    }
    return 0;
  }
}

class _ChoiceItem<T> extends StatelessWidget {
  const _ChoiceItem({
    required this.value,
    required this.label,
    required this.selected,
    this.description,
    this.leading,
    this.hasDivider = true,
  });

  final T value;
  final String label;
  final String? description;
  final Widget? leading;
  final bool selected;
  final bool hasDivider;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color? selectedColor = selected ? theme.primaryColor : null;

    return Semantics(
      value: label,
      selected: selected,
      button: true,
      excludeSemantics: true,
      child: Ink(
        color: selectedColor?.withOpacity(0.1) ?? Colors.transparent,
        child: Column(
          children: <Widget>[
            ListTile(
              leading: leading,
              titleAlignment: ListTileTitleAlignment.center,
              title: Text(
                label,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: description != null ? Text(description!) : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: LARGE_SPACE,
                vertical: 5.0,
              ),
              onTap: () => Navigator.of(context).pop(value),
            ),
            if (hasDivider) const Divider(height: 1.0),
          ],
        ),
      ),
    );
  }
}

class UserPreferencesTitle extends StatelessWidget {
  const UserPreferencesTitle({
    required this.label,
    this.addExtraPadding = true,
    Key? key,
  })  : assert(label.length > 0),
        super(key: key);

  const UserPreferencesTitle.firstItem({
    required String label,
    Key? key,
  }) : this(label: label, addExtraPadding: false, key: key);

  final String label;
  final bool addExtraPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          top: addExtraPadding ? LARGE_SPACE : LARGE_SPACE,
          bottom: SMALL_SPACE,
          // Horizontal = same as ListTile
          start: LARGE_SPACE,
          end: LARGE_SPACE,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }
}

class UserPreferenceListTile extends StatelessWidget {
  const UserPreferenceListTile({
    required this.title,
    required this.leading,
    required this.onTap,
    required this.showDivider,
    super.key,
  });

  final String title;
  final Widget leading;
  final Future<void> Function(BuildContext) onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Padding(
            padding: const EdgeInsets.all(VERY_SMALL_SPACE),
            child: leading,
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () => onTap(context),
        ),
        if (showDivider) const UserPreferencesListItemDivider(),
      ],
    );
  }
}
