import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/common/search_helper.dart';
import 'package:smooth_app/pages/search/search_icon.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_hero.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    required this.searchHelper,
    this.autofocus = false,
    this.showClearButton = true,
    this.searchOnChange = false,
    this.leading,
    this.height,
    this.heroTag,
    this.onFocus,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.focusNode,
    this.enableSuggestions = false,
    this.autocorrect = false,
    this.hintTextStyle,
  });

  final SearchHelper searchHelper;
  final bool autofocus;
  final bool showClearButton;
  final bool searchOnChange;
  final bool enableSuggestions;
  final bool autocorrect;

  final double? height;
  final String? heroTag;
  final void Function()? onFocus;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final TextStyle? hintTextStyle;

  final Widget? leading;

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

    final TextStyle textStyle = SearchFieldUIHelper.textStyle;

    final Widget? leadingWidget = widget.searchHelper.getLeadingWidget(context);
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

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
        child: SizedBox(
          height: widget.height ?? SearchFieldUIHelper.SEARCH_BAR_HEIGHT,
          child: Material(
            // ↑ Needed by the Hero Widget
            borderRadius: MAX_BORDER_RADIUS,
            color: widget.borderColor ?? Colors.white,
            child: Padding(
              padding: const EdgeInsetsDirectional.all(1.0),
              child: Material(
                borderRadius: MAX_BORDER_RADIUS,
                color: widget.backgroundColor ?? Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (leadingWidget != null)
                      SizedBox(
                        height: double.infinity,
                        child: icons.AppIconTheme(
                          color: context.lightTheme()
                              ? theme.primaryBlack
                              : theme.primaryUltraBlack,
                          child: leadingWidget,
                        ),
                      )
                    else
                      const SizedBox(width: SMALL_SPACE),
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: SMALL_SPACE,
                          ),
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            onChanged: widget.searchOnChange
                                ? (String query) =>
                                      _performSearch(context, query)
                                : null,
                            onSubmitted: (String query) =>
                                _performSearch(context, query),
                            textInputAction: TextInputAction.search,
                            enableSuggestions: widget.enableSuggestions,
                            autocorrect: widget.autocorrect,
                            style: textStyle,
                            textAlignVertical: TextAlignVertical.center,
                            scrollPadding: EdgeInsets.zero,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: widget.searchHelper.getHintText(
                                localizations,
                              ),
                              hintStyle:
                                  widget.hintTextStyle ??
                                  SearchFieldUIHelper.hintTextStyle,
                              border: InputBorder.none,
                            ),

                            cursorColor: textStyle.color,
                          ),
                        ),
                      ),
                    ),
                    _SearchIcon(
                      onTap: () => _performSearch(context, _controller!.text),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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

class _SearchIcon extends StatelessWidget {
  const _SearchIcon({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);

    return SearchBarIcon(
      icon: const icons.Search.offRounded(),
      padding: const EdgeInsetsDirectional.only(bottom: 2.0),
      label: localizations.search,
      onTap: onTap,
    );
  }
}

/// Constants shared between [SearchField] and [_SearchBar]
class SearchFieldUIHelper {
  const SearchFieldUIHelper._();

  static const double SEARCH_BAR_HEIGHT = 48.0;
  static const BorderRadius SEARCH_BAR_BORDER_RADIUS = BorderRadius.all(
    Radius.circular(30.0),
  );
  static const EdgeInsetsDirectional SEARCH_BAR_PADDING =
      EdgeInsetsDirectional.only(start: 20.0, end: BALANCED_SPACE, bottom: 3.0);

  static TextStyle get hintTextStyle => const TextStyle(
    fontSize: 15.0,
    fontStyle: FontStyle.italic,
    color: Colors.black54,
  );

  static TextStyle get textStyle => const TextStyle(color: Colors.black);

  static BoxDecoration decoration(BuildContext context) {
    final SmoothColorsThemeExtension theme = Theme.of(
      context,
    ).extension<SmoothColorsThemeExtension>()!;
    final bool lightTheme = context.lightTheme();

    return BoxDecoration(
      borderRadius: SearchFieldUIHelper.SEARCH_BAR_BORDER_RADIUS,
      color: Colors.white,
      border: Border.all(
        color: lightTheme ? theme.primaryBlack : theme.primarySemiDark,
      ),
    );
  }
}
