import 'package:flutter/material.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/homepage/header/homepage_flexible_header.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/product/product_page/new_product_header.dart';
import 'package:smooth_app/pages/scan/carousel/main_card/top_card/scan_search_card.dart';
import 'package:smooth_app/pages/search/search_field.dart';
import 'package:smooth_app/pages/search/search_icon.dart';
import 'package:smooth_app/pages/search/search_page.dart';
import 'package:smooth_app/pages/search/search_product_helper.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class HomePageHeaderSearchBar extends StatelessWidget {
  const HomePageHeaderSearchBar({
    required this.progress,
    required this.autofocus,
  });

  static const String HERO_TAG = 'homepage_search_field';

  static const double SEARCH_BAR_HEIGHT = 50.0;
  final double progress;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension theme = context
        .extension<SmoothColorsThemeExtension>();

    final AppLocalizations localizations = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: HomePageFlexibleHeader.CONTENT_PADDING.start,
      ),
      child: Semantics(
        button: true,
        child: Hero(
          tag: HERO_TAG,
          child: Material(
            // ↑ Needed by the Hero Widget
            type: MaterialType.transparency,
            child: SizedBox(
              height: SEARCH_BAR_HEIGHT,
              child: InkWell(
                onTap: () => AppNavigator.of(context).push(
                  AppRoutes.SEARCH(transition: ProductPageTransition.slideUp),
                  extra: SearchPageExtra(
                    searchHelper: SearchProductHelper(),
                    autofocus: true,
                    heroTag: HERO_TAG,
                    backButtonType: BackButtonType.minimize,
                  ),
                ),
                borderRadius: HEADER_BORDER_RADIUS,
                child: Ink(
                  decoration: SearchFieldUIHelper.decoration(context),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(1.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: SMALL_SPACE,
                          ),
                          child: icons.AppIconTheme(
                            color: context.lightTheme()
                                ? theme.primaryBlack
                                : theme.primaryUltraBlack,
                            child: const OxFLogosAnimation(),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            localizations.homepage_main_card_search_field_hint,
                            maxLines: 1,
                            textScaler: TextScaler.noScaling,
                            overflow: TextOverflow.ellipsis,
                            style: SearchFieldUIHelper.hintTextStyle,
                          ),
                        ),
                        const SearchBarIcon(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
