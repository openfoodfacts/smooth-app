import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SmoothDropdownButton<T> extends StatelessWidget {
  const SmoothDropdownButton({
    required this.value,
    required this.items,
    this.onChanged,
    this.textAlignment,
    this.loading = false,
    this.isExpanded = false,
    super.key,
  }) : assert(items.length > 0);

  final T value;
  final List<SmoothDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final AlignmentGeometry? textAlignment;
  final bool loading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final Widget child;

    if (items.length == 1) {
      final bool singleChar = items.first.label.length == 1;

      child = Padding(
        padding: EdgeInsetsDirectional.only(
          start: VERY_LARGE_SPACE,
          end: VERY_LARGE_SPACE + (singleChar ? 0.0 : (MEDIUM_SPACE + 14.0)),
        ),
        child: SizedBox(
          height: SMALL_SPACE * 2 + 14.0 + MEDIUM_SPACE,
          child: Center(
            child: Text(
              items.first.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
              ),
            ),
          ),
        ),
      );
    } else {
      child = _createDropdownMenu(context);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.extension<SmoothColorsThemeExtension>().primarySemiDark,
        borderRadius: CIRCULAR_BORDER_RADIUS,
      ),
      child: Material(type: MaterialType.transparency, child: child),
    );
  }

  DropdownButton<dynamic> _createDropdownMenu(BuildContext context) {
    return DropdownButton<T>(
      icon: const icons.Chevron.down(color: Colors.white, size: 14.0),
      elevation: 4,
      isDense: true,
      isExpanded: isExpanded,
      underline: EMPTY_WIDGET,
      borderRadius: ROUNDED_BORDER_RADIUS,
      padding: const EdgeInsetsDirectional.only(
        start: LARGE_SPACE,
        end: LARGE_SPACE,
        top: SMALL_SPACE,
        bottom: SMALL_SPACE,
      ),
      enableFeedback: true,
      alignment: textAlignment ?? AlignmentDirectional.centerStart,
      selectedItemBuilder: (BuildContext context) {
        if (loading) {
          return items
              .map(
                (SmoothDropdownItem<T> item) => const Padding(
                  padding: EdgeInsetsDirectional.only(end: MEDIUM_SPACE),
                  child: SizedBox.square(
                    dimension: 12.0,
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
              .toList(growable: false);
        }

        return items
            .map((SmoothDropdownItem<T> item) {
              return SizedBox(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: MEDIUM_SPACE),
                  child: Center(
                    child: Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false);
      },
      style: TextStyle(
        fontSize: 14.0,
        color: context.lightTheme() ? Colors.black : null,
      ),
      items: items
          .map(
            (SmoothDropdownItem<T> item) => DropdownMenuItem<T>(
              value: item.value,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: SMALL_SPACE,
                ),
                child: Text(item.label),
              ),
            ),
          )
          .toList(growable: false),
      value: value,
      onChanged: loading ? null : onChanged,
    );
  }
}

class SmoothDropdownItem<T> {
  SmoothDropdownItem({required this.value, required this.label, this.onTap});

  final T value;
  final String label;
  final VoidCallback? onTap;

  @override
  String toString() {
    return 'SmoothDropdownItem{value: $value, label: $label, onTap: $onTap}';
  }
}
