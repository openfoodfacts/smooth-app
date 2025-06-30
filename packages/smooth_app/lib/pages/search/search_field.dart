import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/search_helper.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/constant_icons.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_hero.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    required this.searchHelper,
    this.autofocus = false,
    this.showClearButton = true,
    this.heroTag,
    this.onFocus,
    this.backgroundColor,
    this.foregroundColor,
    this.focusNode,
    this.enableSuggestions = false,
    this.autocorrect = false,
  });

  final SearchHelper searchHelper;
  final bool autofocus;
  final bool showClearButton;
  final bool enableSuggestions;
  final bool autocorrect;

  final String? heroTag;
  final void Function()? onFocus;
  final Color? backgroundColor;
  final Color? foregroundColor;

  final FocusNode? focusNode;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late FocusNode _focusNode;
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    try {
      _controller = Provider.of<TextEditingController>(context);
    } catch (err) {
      _controller = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    try {
      _controller ??= Provider.of<TextEditingController>(context);
    } catch (err) {
      _controller = TextEditingController();
    }

    final TextStyle textStyle = SearchFieldUIHelper.textStyle(context);

    final Widget? additionalFilter = widget.searchHelper.getAdditionalFilter();
    return ChangeNotifierProvider<TextEditingController>.value(
      value: _controller!,
      child: SmoothHero(
        tag: widget.heroTag,
        enabled: widget.heroTag != null,
        onAnimationEnded: widget.autofocus
            ? (HeroFlightDirection direction) {
                /// The autofocus should only be requested once the Animation is over
                if (direction == HeroFlightDirection.push) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _focusNode.requestFocus();
                  });
                }
              }
            : null,
        child: Material(
          // ↑ Needed by the Hero Widget
          color: Colors.transparent,
          child: Column(
            children: <Widget>[
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                onSubmitted: (String query) => _performSearch(context, query),
                textInputAction: TextInputAction.search,
                enableSuggestions: widget.enableSuggestions,
                autocorrect: widget.autocorrect,
                style: textStyle,
                decoration: _getInputDecoration(context, localizations),
                cursorColor: textStyle.color,
              ),
              if (additionalFilter != null) additionalFilter,
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final BoxDecoration decoration = SearchFieldUIHelper.decoration(context);
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: decoration.borderRadius! as BorderRadius,
      borderSide: decoration.border!.top.copyWith(width: 2.0),
    );

    return InputDecoration(
      fillColor: decoration.color,
      filled: true,
      constraints: const BoxConstraints.tightFor(
        height: SearchFieldUIHelper.SEARCH_BAR_HEIGHT,
      ),
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      contentPadding: SearchFieldUIHelper.SEARCH_BAR_PADDING,
      hintText: widget.searchHelper.getHintText(localizations),
      prefixIcon: const Align(
        alignment: AlignmentDirectional.centerStart,
        child: _BackIcon(),
      ),
      prefixIconConstraints: BoxConstraints.tightFor(
        width:
            SearchFieldUIHelper.SEARCH_BAR_HEIGHT +
            (SearchFieldUIHelper.SEARCH_BAR_PADDING.horizontal) / 2,
      ),
      suffixIcon: widget.showClearButton
          ? _SearchIcon(onTap: () => _performSearch(context, _controller!.text))
          : null,
    );
  }

  void _performSearch(BuildContext context, String query) => widget.searchHelper
      .searchWithController(context, query, _controller!, _focusNode);

  @override
  void dispose() {
    /// The [FocusNode] provided to this Widget is disposed elsewhere
    if (_focusNode != widget.focusNode) {
      _focusNode.dispose();
    }

    super.dispose();
  }
}

class _BackIcon extends StatelessWidget {
  const _BackIcon();

  @override
  Widget build(BuildContext context) {
    return SearchBarIcon(
      icon: Icon(ConstantIcons.backIcon),
      label: MaterialLocalizations.of(context).closeButtonTooltip,
      onTap: () => Navigator.of(context).pop(),
    );
  }
}

class _SearchIcon extends StatelessWidget {
  const _SearchIcon({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return SearchBarIcon(
      icon: const icons.Search(),
      label: localizations.search,
      onTap: onTap,
    );
  }
}

class SearchBarIcon extends StatelessWidget {
  const SearchBarIcon({this.icon, this.onTap, this.label, super.key})
    : assert(label == null || onTap != null);

  final VoidCallback? onTap;
  final String? label;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = Theme.of(
      context,
    ).extension<SmoothColorsThemeExtension>()!;

    final Widget widget = AspectRatio(
      aspectRatio: 1.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.primaryDark,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(BALANCED_SPACE),
          child: IconTheme(
            data: const IconThemeData(size: 20.0, color: Colors.white),
            child: icon ?? const icons.Search(),
          ),
        ),
      ),
    );

    if (onTap == null) {
      return widget;
    } else {
      return Semantics(
        label: label,
        button: true,
        excludeSemantics: true,
        child: Tooltip(
          message: label ?? '',
          child: InkWell(
            borderRadius: SearchFieldUIHelper.SEARCH_BAR_BORDER_RADIUS,
            onTap: onTap,
            child: widget,
          ),
        ),
      );
    }
  }
}

/// Constants shared between [SearchField] and [_SearchBar]
class SearchFieldUIHelper {
  const SearchFieldUIHelper._();

  static const double SEARCH_BAR_HEIGHT = 47.0;
  static const BorderRadius SEARCH_BAR_BORDER_RADIUS = BorderRadius.all(
    Radius.circular(30.0),
  );
  static const EdgeInsetsGeometry SEARCH_BAR_PADDING =
      EdgeInsetsDirectional.only(start: 20.0, end: BALANCED_SPACE, bottom: 3.0);

  static TextStyle textStyle(BuildContext context) {
    final bool lightTheme = !context.watch<ThemeProvider>().isDarkMode(context);
    return TextStyle(color: lightTheme ? Colors.black : Colors.white);
  }

  static BoxDecoration decoration(BuildContext context) {
    final SmoothColorsThemeExtension theme = Theme.of(
      context,
    ).extension<SmoothColorsThemeExtension>()!;
    final bool lightTheme = !context.watch<ThemeProvider>().isDarkMode(context);

    return BoxDecoration(
      borderRadius: SearchFieldUIHelper.SEARCH_BAR_BORDER_RADIUS,
      color: lightTheme ? Colors.white : theme.greyDark,
      border: Border.all(
        color: lightTheme ? theme.primaryBlack : theme.primarySemiDark,
      ),
    );
  }
}
