import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_back_button.dart';
import 'package:smooth_app/pages/product/common/search_helper.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({required this.searchBar, this.backButtonType, super.key});

  final Widget searchBar;
  final BackButtonType? backButtonType;

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension extension = context
        .extension<SmoothColorsThemeExtension>();

    return Material(
      color: context.lightTheme()
          ? extension.primaryBlack
          : extension.primaryUltraBlack,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26.0)),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 0.0, end: 8.0),
          child: Row(
            children: <Widget>[
              Consumer<SearchHelper>(
                builder: (BuildContext context, SearchHelper searchHelper, _) {
                  if (searchHelper.value == null) {
                    return SmoothBackButton(
                      backButtonType: backButtonType ?? BackButtonType.close,
                    );
                  } else {
                    return const SmoothBackButton(
                      backButtonType: BackButtonType.back,
                    );
                  }
                },
              ),
              Expanded(child: searchBar),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
