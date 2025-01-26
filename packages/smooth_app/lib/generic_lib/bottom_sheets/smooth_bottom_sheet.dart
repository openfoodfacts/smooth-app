import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_draggable_bottom_sheet_route.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/color_extension.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

Future<T?> showSmoothModalSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double? minHeight,
  double? maxHeight,
  bool? isScrollControlled,
  bool? useRootNavigator,
}) {
  BoxConstraints? constraints;

  // We can't provide a null value to a [BoxConstraints] constructor
  if (minHeight != null && maxHeight != null) {
    constraints = BoxConstraints(
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  } else if (minHeight != null) {
    constraints = BoxConstraints(
      minHeight: minHeight,
    );
  } else if (maxHeight != null) {
    constraints = BoxConstraints(
      maxHeight: maxHeight,
    );
  }

  return showModalBottomSheet<T>(
    constraints: constraints,
    isScrollControlled: isScrollControlled ?? minHeight != null,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: ROUNDED_RADIUS),
    ),
    builder: builder,
    useRootNavigator: useRootNavigator ?? false,
    useSafeArea: true,
  );
}

Future<T?> showSmoothModalSheetForTextField<T>({
  required BuildContext context,
  required SmoothModalSheetHeader header,
  required WidgetBuilder bodyBuilder,
}) {
  return showSmoothModalSheet<T>(
    context: context,
    builder: (BuildContext context) => SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: ROUNDED_RADIUS),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            header,
            bodyBuilder(context),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

Future<T?> showSmoothDraggableModalSheet<T>({
  required BuildContext context,
  required SmoothModalSheetHeader header,

  /// You must return a Sliver Widget
  required WidgetBuilder bodyBuilder,
  double? initHeight,
  double? minHeight,
  double? maxHeight,
  DraggableScrollableController? draggableScrollableController,
}) {
  return showDraggableModalSheet<T>(
    context: context,
    draggableScrollableController: draggableScrollableController,
    borderRadius: const BorderRadius.vertical(top: ROUNDED_RADIUS),
    headerBuilder: (_) => header,
    headerHeight: header.computeHeight(context),
    bodyBuilder: bodyBuilder,
    initHeight: initHeight,
    minHeight: minHeight,
    maxHeight: maxHeight,
  );
}

/// A modal sheet with a limited list (no scroll)
Future<T?> showSmoothListOfChoicesModalSheet<T>({
  required BuildContext context,
  required String title,
  required Iterable<String> labels,
  required Iterable<T> values,
  bool addEndArrowToItems = false,
  Widget? header,
  Widget? footer,
  List<Widget>? prefixIcons,
  Color? prefixIconTint,
  List<Widget>? suffixIcons,
  Color? suffixIconTint,
  EdgeInsetsGeometry? padding,
  EdgeInsetsGeometry? contentPadding,
  EdgeInsetsGeometry? dividerPadding,
  TextStyle? textStyle,
  Color? headerBackgroundColor,
  Color? footerBackgroundColor,
  Color? prefixIndicatorColor,
  double footerSpace = 0.0,
  SmoothModalSheetType type = SmoothModalSheetType.info,
  bool safeArea = false,
}) {
  assert(labels.length == values.length);
  assert(prefixIcons == null || values.length == prefixIcons.length);
  assert(suffixIcons == null || values.length == suffixIcons.length);
  assert(prefixIconTint == null || prefixIcons != null);
  assert(suffixIconTint == null || suffixIcons != null);

  final List<Widget> items = <Widget>[];

  if (header != null) {
    items.add(header);
  }

  for (int i = 0; i < labels.length; i++) {
    items.add(
      ListTile(
        leading: prefixIcons != null
            ? IconTheme.merge(
                data: IconThemeData(color: prefixIconTint),
                child: prefixIcons[i],
              )
            : null,
        title: Text(
          labels.elementAt(i),
          style: textStyle ?? const TextStyle(fontWeight: FontWeight.w500),
        ),
        contentPadding: contentPadding ??
            EdgeInsetsDirectional.only(
              start: LARGE_SPACE,
              end: addEndArrowToItems ? 17.0 : LARGE_SPACE,
            ),
        trailing: (suffixIcons != null
            ? IconTheme.merge(
                data: IconThemeData(color: suffixIconTint),
                child: suffixIcons[i])
            : (addEndArrowToItems
                ? const _SmoothListOfChoicesEndArrow()
                : null)),
        onTap: () {
          Navigator.of(context).pop(values.elementAt(i));
        },
      ),
    );

    if (i < labels.length - 1) {
      const Widget divider = Divider(height: 1.0);

      if (dividerPadding != null) {
        items.add(Padding(padding: dividerPadding, child: divider));
      } else {
        items.add(divider);
      }
    }
  }

  double bottomPadding = MediaQuery.paddingOf(context).bottom;

  if (safeArea && bottomPadding == 0.0) {
    bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
  }

  if (footer != null) {
    if (footerSpace > 0.0) {
      items.add(SizedBox(height: footerSpace));
    }

    Widget footerChild = Column(
      children: <Widget>[
        footer,
        SizedBox(height: bottomPadding),
      ],
    );

    if (footerBackgroundColor != null) {
      footerChild = ColoredBox(
        color: footerBackgroundColor,
        child: footerChild,
      );
    }

    items.add(footerChild);
  } else {
    items.add(SizedBox(height: bottomPadding));
  }

  return showSmoothModalSheet<T>(
    context: context,
    builder: (BuildContext context) => SmoothModalSheet(
      title: title,
      type: type,
      prefixIndicator: true,
      prefixIndicatorColor: prefixIndicatorColor,
      headerBackgroundColor: headerBackgroundColor,
      bodyPadding: EdgeInsets.zero,
      body: Column(children: items),
    ),
  );
}

/// A modal sheet asking for a confirmation
Future<T?> showSmoothAlertModalSheet<T>({
  required BuildContext context,
  required String title,
  required Widget message,
  required Iterable<String> actionLabels,
  required Iterable<T> actionValues,
  required List<Widget> actionIcons,
  SmoothModalSheetType type = SmoothModalSheetType.info,
  bool safeArea = true,
}) {
  final bool lightTheme = context.lightTheme(listen: false);
  final Color headerBackgroundColor = switch (type) {
    SmoothModalSheetType.error when lightTheme =>
      SmoothModalSheetHeader.ERROR_COLOR.lighten(0.55),
    SmoothModalSheetType.error =>
      SmoothModalSheetHeader.ERROR_COLOR.darken(0.3),
    SmoothModalSheetType.info when lightTheme =>
      context.extension<SmoothColorsThemeExtension>().primaryLight,
    SmoothModalSheetType.info =>
      context.extension<SmoothColorsThemeExtension>().primaryDark.darken(0.1),
  };

  return showSmoothListOfChoicesModalSheet<T>(
    context: context,
    title: title,
    type: type,
    header: ColoredBox(
      color: headerBackgroundColor,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: LARGE_SPACE,
          vertical: MEDIUM_SPACE,
        ),
        child: DefaultTextStyle.merge(
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          child: message,
        ),
      ),
    ),
    labels: actionLabels,
    values: actionValues,
    prefixIcons: actionIcons,
    dividerPadding: const EdgeInsetsDirectional.symmetric(
      horizontal: MEDIUM_SPACE,
    ),
    textStyle: const TextStyle(fontWeight: FontWeight.w600),
    safeArea: true,
  );
}

class _SmoothListOfChoicesEndArrow extends StatelessWidget {
  const _SmoothListOfChoicesEndArrow();

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return ExcludeSemantics(
      child: icons.CircledArrow.right(
        color: lightTheme ? extension.primaryLight : extension.primaryDark,
        type: icons.CircledArrowType.normal,
        circleColor:
            lightTheme ? extension.primaryDark : extension.primaryMedium,
        size: 24.0,
        padding: const EdgeInsetsDirectional.only(
          start: 6.0,
          end: 6.0,
          top: 6.5,
          bottom: 7.5,
        ),
      ),
    );
  }
}

/// A non scrollable modal sheet
class SmoothModalSheet extends StatelessWidget {
  SmoothModalSheet({
    required String title,
    required this.body,
    SmoothModalSheetType type = SmoothModalSheetType.info,
    bool prefixIndicator = false,
    bool closeButton = true,
    Color? prefixIndicatorColor,
    Color? headerBackgroundColor,
    Color? headerForegroundColor,
    this.bodyPadding,
    this.expandBody = false,
    double? closeButtonSemanticsOrder,
  }) : header = SmoothModalSheetHeader(
          title: title,
          prefix: prefixIndicator
              ? SmoothModalSheetHeaderPrefixIndicator(
                  color: prefixIndicatorColor,
                )
              : null,
          suffix: closeButton
              ? SmoothModalSheetHeaderCloseButton(
                  semanticsOrder: closeButtonSemanticsOrder,
                )
              : null,
          backgroundColor: headerBackgroundColor,
          foregroundColor: headerForegroundColor,
          type: type,
        );

  final SmoothModalSheetHeader header;
  final Widget body;
  final EdgeInsetsGeometry? bodyPadding;
  final bool expandBody;

  @override
  Widget build(BuildContext context) {
    Widget bodyChild = Padding(
      padding: bodyPadding ?? const EdgeInsetsDirectional.all(MEDIUM_SPACE),
      child: body,
    );

    if (expandBody) {
      bodyChild = Expanded(child: bodyChild);
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: ROUNDED_RADIUS),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: ROUNDED_RADIUS),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            header,
            bodyChild,
          ],
        ),
      ),
    );
  }

  double computeHeaderHeight(BuildContext context) =>
      header.computeHeight(context);
}

class SmoothModalSheetHeader extends StatelessWidget implements SizeWidget {
  const SmoothModalSheetHeader({
    required this.title,
    this.prefix,
    this.suffix,
    this.foregroundColor,
    this.backgroundColor,
    this.type = SmoothModalSheetType.info,
  });

  static const double MIN_HEIGHT = 55.0;
  static const Color ERROR_COLOR = Color(0xFFB81D1D);

  final String title;
  final SizeWidget? prefix;
  final SizeWidget? suffix;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final SmoothModalSheetType type;

  @override
  Widget build(BuildContext context) {
    final Color tintColor = foregroundColor ?? Colors.white;

    return IconTheme(
      data: IconThemeData(color: tintColor),
      child: Container(
        height: suffix is SmoothModalSheetHeaderButton ? double.infinity : null,
        constraints: const BoxConstraints(minHeight: MIN_HEIGHT),
        decoration: BoxDecoration(
          color: _backgroundColor(context),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 5.0,
            ),
          ],
        ),
        padding: EdgeInsetsDirectional.only(
          start: (prefix?.requiresPadding == true ? 0 : VERY_LARGE_SPACE),
          top: VERY_SMALL_SPACE,
          bottom: VERY_SMALL_SPACE,
          end: VERY_LARGE_SPACE -
              (suffix?.requiresPadding == true ? 0 : LARGE_SPACE),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (prefix != null)
                Padding(
                  padding:
                      const EdgeInsetsDirectional.only(end: BALANCED_SPACE),
                  child: prefix,
                ),
              Expanded(
                child: Semantics(
                  sortKey: const OrdinalSortKey(1.0),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: tintColor,
                        ),
                  ),
                ),
              ),
              if (suffix != null) suffix!
            ],
          ),
        ),
      ),
    );
  }

  Color _backgroundColor(BuildContext context) {
    if (backgroundColor != null) {
      return backgroundColor!;
    }

    return switch (type) {
      SmoothModalSheetType.error => ERROR_COLOR,
      SmoothModalSheetType.info =>
        context.extension<SmoothColorsThemeExtension>().primaryDark,
    };
  }

  double computeHeight(BuildContext context) {
    return math.max(
      widgetHeight(context),
      suffix?.widgetHeight(context) ?? 0.0,
    );
  }

  @override
  double widgetHeight(BuildContext context) {
    final double size = VERY_SMALL_SPACE * 2 +
        (Theme.of(context).textTheme.titleLarge?.fontSize ?? 15.0);

    return math.max(MIN_HEIGHT, size);
  }

  @override
  bool get requiresPadding => true;
}

class SmoothModalSheetHeaderButton extends StatelessWidget
    implements SizeWidget {
  const SmoothModalSheetHeaderButton({
    required this.label,
    this.prefix,
    this.suffix,
    this.onTap,
    this.tooltip,
  });

  static const EdgeInsetsGeometry _padding = EdgeInsetsDirectional.only(
    start: LARGE_SPACE - 1,
    end: LARGE_SPACE,
    top: BALANCED_SPACE,
    bottom: BALANCED_SPACE,
  );

  final String label;
  final Widget? prefix;
  final Widget? suffix;
  final String? tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension =
        context.extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return Semantics(
      value: tooltip,
      button: true,
      excludeSemantics: true,
      child: Tooltip(
        message: tooltip ?? '',
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: _padding,
            shape: const RoundedRectangleBorder(
              borderRadius: ROUNDED_BORDER_RADIUS,
            ),
            foregroundColor: lightTheme ? Colors.black : Colors.white,
            backgroundColor:
                lightTheme ? extension.primaryMedium : extension.primaryBlack,
            iconColor: lightTheme ? Colors.black : Colors.white,
          ),
          child: Row(
            children: <Widget>[
              if (prefix != null) ...<Widget>[
                prefix!,
                const SizedBox(
                  width: SMALL_SPACE,
                ),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
              if (suffix != null) ...<Widget>[
                const SizedBox(
                  width: SMALL_SPACE,
                ),
                suffix!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  double widgetHeight(BuildContext context) {
    return math.max(MediaQuery.textScalerOf(context).scale(17.0),
            suffix is Icon || prefix is Icon ? 20.0 : 0.0) +
        _padding.vertical;
  }

  @override
  bool get requiresPadding => true;
}

class SmoothModalSheetHeaderCloseButton extends StatelessWidget
    implements SizeWidget {
  const SmoothModalSheetHeaderCloseButton({
    this.semanticsOrder,
    this.addPadding,
    this.circled = true,
  });

  final double? semanticsOrder;
  final bool? addPadding;
  final bool circled;

  @override
  Widget build(BuildContext context) {
    final Widget icon;

    if (circled == true) {
      icon = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: IconTheme.of(context).color ?? Colors.white,
            width: 1.5,
          ),
        ),
        margin: const EdgeInsetsDirectional.all(VERY_SMALL_SPACE),
        padding: const EdgeInsetsDirectional.all(6.0),
        child: const icons.Close(
          size: 13.0,
        ),
      );
    } else {
      icon = const Padding(
        padding: EdgeInsetsDirectional.all(MEDIUM_SPACE),
        child: icons.Close(
          size: 15.0,
        ),
      );
    }

    return Semantics(
      value: MaterialLocalizations.of(context).closeButtonTooltip,
      button: true,
      excludeSemantics: true,
      sortKey: OrdinalSortKey(semanticsOrder ?? 2.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(end: SMALL_SPACE),
        child: Tooltip(
          message: MaterialLocalizations.of(context).closeButtonTooltip,
          enableFeedback: true,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () {
                SmoothHapticFeedback.click();
                Navigator.of(context).pop();
              },
              customBorder: const CircleBorder(),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }

  @override
  double widgetHeight(BuildContext context) =>
      (MEDIUM_SPACE * 2) + (Theme.of(context).iconTheme.size ?? 20.0);

  @override
  bool get requiresPadding => addPadding ?? false;
}

class SmoothModalSheetHeaderPrefixIndicator extends StatelessWidget
    implements SizeWidget {
  const SmoothModalSheetHeaderPrefixIndicator({
    this.color,
    super.key,
  });

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: VERY_SMALL_SPACE),
      child: SizedBox(
        width: 10.0,
        height: 10.0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color ?? Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  bool get requiresPadding => false;

  @override
  double widgetHeight(BuildContext context) => 10.0;
}

abstract class SizeWidget implements Widget {
  double widgetHeight(BuildContext context);

  bool get requiresPadding;
}

/// With a [SmoothModalSheet], if you want to display simple things (eg: text),
/// you can use this widget
class SmoothModalSheetBodyContainer extends StatelessWidget {
  const SmoothModalSheetBodyContainer({
    required this.child,
    this.padding,
    this.safeArea = true,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry padding = this.padding ??
        const EdgeInsetsDirectional.only(
          start: MEDIUM_SPACE,
          end: MEDIUM_SPACE,
          top: VERY_SMALL_SPACE,
          bottom: VERY_SMALL_SPACE,
        );

    if (safeArea) {
      padding = padding.add(
        EdgeInsetsDirectional.only(
          bottom: MediaQuery.viewPaddingOf(context).bottom,
        ),
      );
    }
    return Padding(
      padding: padding,
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          fontSize: 15.0,
          height: 1.7,
        ),
        child: child,
      ),
    );
  }
}

enum SmoothModalSheetType {
  error,
  info,
}
