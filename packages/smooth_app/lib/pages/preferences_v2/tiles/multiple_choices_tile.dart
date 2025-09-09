import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/preferences_v2/tiles/preference_tile.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class MultipleChoicesTile<T> extends PreferenceTile {
  const MultipleChoicesTile({
    required super.title,
    required this.leadingBuilder,
    required this.labels,
    required this.values,
    required this.currentValue,
    required this.onChanged,
    this.descriptions,
  });

  final Iterable<WidgetBuilder>? leadingBuilder;
  final Iterable<String> labels;
  final Iterable<String>? descriptions;
  final Iterable<T> values;
  final T? currentValue;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final int currentValueIndex = _findCurrentValueIndex();

    return PreferenceTile(
      leading: leadingBuilder != null
          ? Builder(builder: leadingBuilder!.elementAt(currentValueIndex))
          : null,
      title: title,
      subtitleText: labels.elementAt(currentValueIndex),
      onTap: () async {
        final double itemHeight =
            (descriptions != null ? 15.0 : 0.0) +
            (5.0 * 2) +
            1.0 +
            (56.0 + Theme.of(context).visualDensity.baseSizeAdjustment.dy);

        final MediaQueryData queryData = MediaQueryData.fromView(
          WidgetsBinding.instance.platformDispatcher.implicitView!,
        );

        // If there is not enough space, we use the scrolling sheet
        final T? res;
        final SmoothModalSheetHeader header = SmoothModalSheetHeader(
          title: title,
          prefix: const SmoothModalSheetHeaderPrefixIndicator(),
        );

        if ((itemHeight * labels.length + header.computeHeight(context)) >
            (queryData.size.height * 0.9) - queryData.viewPadding.top) {
          res = await showSmoothDraggableModalSheet<T>(
            context: context,
            header: header,
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
                              builder: leadingBuilder!.elementAt(position),
                            )
                          : null,
                      hasDivider: position < labels.length - 1,
                    );
                  },
                ),
              );
            },
          );
        } else {
          final SmoothModalSheet smoothModalSheet = SmoothModalSheet(
            title: title,
            prefixIndicator: true,
            bodyPadding: EdgeInsets.zero,
            body: SizedBox(
              height: itemHeight * labels.length,
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
                        ? Builder(builder: leadingBuilder!.elementAt(position))
                        : null,
                    hasDivider: false,
                  );
                },
                separatorBuilder: (_, _) => const Divider(height: 1.0),
              ),
            ),
          );

          res = await showSmoothModalSheet<T>(
            context: context,
            minHeight:
                smoothModalSheet.computeHeaderHeight(context) +
                itemHeight * labels.length,
            builder: (BuildContext context) {
              return smoothModalSheet;
            },
          );
        }

        if (res != null) {
          onChanged?.call(res);
        }
      },
      trailing: const icons.Edit(),
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
    final SmoothColorsThemeExtension extension = theme
        .extension<SmoothColorsThemeExtension>()!;
    final bool lightTheme = context.lightTheme();

    final Color backgroundColor = selected
        ? (lightTheme ? extension.primaryMedium : extension.primaryTone)
        : context.lightTheme()
        ? Colors.transparent
        : extension.primaryUltraBlack;

    return Semantics(
      value: label,
      selected: selected,
      button: true,
      excludeSemantics: true,
      child: Ink(
        color: backgroundColor,
        child: Column(
          children: <Widget>[
            ListTile(
              leading: leading,
              titleAlignment: ListTileTitleAlignment.center,
              title: Text(
                label,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: !lightTheme ? Colors.white : null,
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
