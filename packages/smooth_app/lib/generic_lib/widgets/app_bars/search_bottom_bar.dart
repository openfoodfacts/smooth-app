import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_background.dart';
import 'package:smooth_app/generic_lib/widgets/app_bars/app_bar_constanst.dart';
import 'package:smooth_app/pages/preferences_v2/roots/preferences_root.dart';
import 'package:smooth_app/pages/search/search_field.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SearchBottomBar extends StatelessWidget {
  const SearchBottomBar({required this.onClose, super.key});

  final VoidCallback onClose;

  static double get totalHeight =>
      SEARCH_BOTTOM_HEIGHT + AppBarBackground.RADIUS.y;

  @override
  Widget build(BuildContext context) {
    final FocusNode focusNode = context.watch<FocusNode>();

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: SMALL_SPACE,
        horizontal: MEDIUM_SPACE,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            Offstage(
              offstage: !focusNode.hasFocus,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  end: VERY_SMALL_SPACE,
                ),
                child: Tooltip(
                  message: MaterialLocalizations.of(context).closeButtonTooltip,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onClose,
                    child: SizedBox.square(
                      dimension: 25.0,
                      child: Material(
                        color: context.lightTheme()
                            ? Colors.white
                            : context
                                  .extension<SmoothColorsThemeExtension>()
                                  .primarySemiDark,
                        shape: const CircleBorder(),
                        child: const icons.Close(size: 12.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SearchField(
                focusNode: focusNode,
                searchHelper: context.read<PreferencesRootSearchController>(),
                showNavigationButton: false,
                searchOnChange: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
