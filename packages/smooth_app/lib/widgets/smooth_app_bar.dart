import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';

/// A custom [AppBar] with an action mode.
/// If [action mode] is true, please provide at least an [actionModeTitle].
class SmoothAppBar extends StatelessWidget implements PreferredSizeWidget {
  SmoothAppBar({
    this.leading,
    this.automaticallyImplyLeading = true,
    this.actionModeTitle,
    this.actionModeSubTitle,
    this.title,
    this.subTitle,
    this.actionModeActions,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.scrolledUnderElevation = 0.0,
    this.notificationPredicate,
    this.shadowColor,
    // this.surfaceTintColor,
    this.backgroundColor,
    this.foregroundColor,
    this.iconTheme,
    this.actionsIconTheme,
    this.primary = true,
    this.centerTitle,
    this.excludeHeaderSemantics = false,
    this.titleSpacing,
    this.shape,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
    this.toolbarHeight,
    this.leadingWidth,
    this.toolbarTextStyle,
    this.titleTextStyle,
    this.systemOverlayStyle,
    this.actionMode = false,
    this.actionModeCloseTooltip,
    this.onLeaveActionMode,
    this.ignoreSemanticsForSubtitle = false,
    this.forceMaterialTransparency = false,
    this.clipBehavior,
    super.key,
  })  : assert(!actionMode || actionModeTitle != null),
        preferredSize =
            _PreferredAppBarSize(toolbarHeight, bottom?.preferredSize.height);

  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Widget? title;
  final Widget? subTitle;
  final Widget? actionModeTitle;
  final Widget? actionModeSubTitle;
  final List<Widget>? actions;
  final List<Widget>? actionModeActions;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final double? scrolledUnderElevation;
  final ScrollNotificationPredicate? notificationPredicate;
  final Color? shadowColor;

  // Disabled as it will do unexpected things with [backgroundColor]
  // final Color? surfaceTintColor;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconThemeData? iconTheme;
  final IconThemeData? actionsIconTheme;
  final bool primary;
  final bool? centerTitle;
  final bool excludeHeaderSemantics;
  final double? titleSpacing;
  final double toolbarOpacity;
  final double bottomOpacity;
  @override
  final Size preferredSize;
  final ShapeBorder? shape;
  final double? toolbarHeight;
  final double? leadingWidth;
  final TextStyle? toolbarTextStyle;
  final TextStyle? titleTextStyle;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final bool? ignoreSemanticsForSubtitle;
  final bool forceMaterialTransparency;
  final Clip? clipBehavior;

  final VoidCallback? onLeaveActionMode;
  final String? actionModeCloseTooltip;
  final bool actionMode;

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(animation),
          child: child,
        );
      },
      child: actionMode
          ? _createActionModeAppBar(context)
          : _createAppBar(context, parentRoute),
    );
  }

  Widget _createAppBar(BuildContext context, ModalRoute<dynamic>? parentRoute) {
    final bool useCloseButton =
        parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;
    Widget? leadingWidget = leading;
    if (leadingWidget == null &&
        automaticallyImplyLeading &&
        parentRoute?.impliesAppBarDismissal == true &&
        !useCloseButton) {
      leadingWidget = const SmoothBackButton();
    }

    return AppBar(
      leading: leadingWidget,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: title != null
          ? _AppBarTitle(title: title!, subTitle: subTitle)
          : null,
      actions: actions,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      notificationPredicate:
          notificationPredicate ?? defaultScrollNotificationPredicate,
      shadowColor: shadowColor,
      surfaceTintColor:
          backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      primary: primary,
      centerTitle: centerTitle,
      excludeHeaderSemantics: excludeHeaderSemantics,
      titleSpacing: titleSpacing,
      shape: shape,
      toolbarOpacity: toolbarOpacity,
      bottomOpacity: bottomOpacity,
      toolbarHeight: toolbarHeight,
      leadingWidth: leadingWidth,
      toolbarTextStyle: toolbarTextStyle,
      systemOverlayStyle: systemOverlayStyle,
      forceMaterialTransparency: forceMaterialTransparency,
      clipBehavior: clipBehavior,
    );
  }

  Widget _createActionModeAppBar(BuildContext context) => IconTheme(
        data: IconThemeData(color: PopupMenuTheme.of(context).color),
        child: AppBar(
          leading: _ActionModeCloseButton(
            tooltip: AppLocalizations.of(context).cancel,
            onPressed: () {
              onLeaveActionMode?.call();
            },
          ),
          automaticallyImplyLeading: false,
          title: actionModeTitle != null
              ? _AppBarTitle(
                  title: actionModeTitle!,
                  subTitle: actionModeSubTitle,
                  ignoreSemanticsForSubtitle: ignoreSemanticsForSubtitle,
                )
              : null,
          actions: actionModeActions,
          flexibleSpace: flexibleSpace,
          bottom: bottom,
          elevation: elevation,
          scrolledUnderElevation: scrolledUnderElevation,
          shadowColor: shadowColor,
          surfaceTintColor:
              backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          iconTheme: iconTheme,
          actionsIconTheme: actionsIconTheme,
          primary: primary,
          centerTitle: centerTitle,
          excludeHeaderSemantics: excludeHeaderSemantics,
          titleSpacing: titleSpacing,
          shape: shape,
          toolbarOpacity: toolbarOpacity,
          bottomOpacity: bottomOpacity,
          toolbarHeight: toolbarHeight,
          leadingWidth: leadingWidth,
          toolbarTextStyle: toolbarTextStyle,
          titleTextStyle: titleTextStyle,
          systemOverlayStyle: systemOverlayStyle,
        ),
      );
}

class _PreferredAppBarSize extends Size {
  const _PreferredAppBarSize(this.toolbarHeight, this.bottomHeight)
      : super.fromHeight(
            (toolbarHeight ?? kToolbarHeight) + (bottomHeight ?? 0));

  final double? toolbarHeight;
  final double? bottomHeight;
}

class _ActionModeCloseButton extends StatelessWidget {
  const _ActionModeCloseButton({
    this.tooltip,
    this.onPressed,
  });

  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return IconButton(
      icon: const Icon(Icons.close),
      tooltip: tooltip ?? MaterialLocalizations.of(context).closeButtonTooltip,
      color: PopupMenuTheme.of(context).color,
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        } else {
          Navigator.maybePop(context);
        }
      },
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({
    required this.title,
    required this.subTitle,
    this.ignoreSemanticsForSubtitle,
  });

  final Widget title;
  final Widget? subTitle;
  final bool? ignoreSemanticsForSubtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        title,
        if (subTitle != null)
          DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
            child: ExcludeSemantics(
              excluding: ignoreSemanticsForSubtitle ?? false,
              child: subTitle,
            ),
          ),
      ],
    );
  }
}
