import 'package:material_ui/material_ui.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_manager.dart';
import 'package:smooth_app/pages/prices/infinite_scroll_sliver_list.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/v2/smooth_leading_button.dart';
import 'package:smooth_app/widgets/v2/smooth_scaffold2.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';

/// Shared V2 scaffold for infinite-scrolling Open Prices list pages.
class PricesListScaffold<T> extends StatelessWidget {
  const PricesListScaffold({
    required this.title,
    required this.manager,
    super.key,
  });

  final String title;
  final InfiniteScrollManager<T> manager;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return SmoothScaffold2(
      backgroundColor: lightTheme ? extension.primaryLight : null,
      topBar: SmoothTopBar2(
        leadingAction: SmoothLeadingAction.back,
        backgroundColor: lightTheme
            ? extension.primaryBlack
            : extension.primaryUltraBlack,
        foregroundColor: lightTheme ? Colors.white : null,
        elevationColor: lightTheme ? Colors.black54 : Colors.white12,
        title: title,
        elevationOnScroll: true,
        productType: null,
      ),
      padding: EdgeInsetsDirectional.zero,
      children: <Widget>[
        InfiniteScrollSliverList<T>(manager: manager),
        const SliverPadding(
          padding: EdgeInsetsDirectional.only(bottom: MEDIUM_SPACE),
        ),
      ],
    );
  }
}

/// Shared V2 card container for Open Prices list items.
class PricesListCard extends StatelessWidget {
  const PricesListCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsetsDirectional.all(SMALL_SPACE),
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();
    final bool lightTheme = context.lightTheme();

    return SmoothCard(
      elevation: 5.0,
      elevationColor: Colors.black26,
      margin: const EdgeInsetsDirectional.only(
        top: MEDIUM_SPACE,
        start: LARGE_SPACE,
        end: LARGE_SPACE,
      ),
      padding: EdgeInsets.zero,
      color: lightTheme ? null : extension.primaryUltraBlack,
      child: InkWell(
        borderRadius: ROUNDED_BORDER_RADIUS,
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
