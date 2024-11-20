import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ProductTypeRadioListTile extends StatefulWidget {
  const ProductTypeRadioListTile({
    required this.productType,
    required this.checked,
    required this.onChanged,
    super.key,
  });

  final ProductType productType;
  final bool checked;
  final void Function(ProductType) onChanged;

  @override
  State<ProductTypeRadioListTile> createState() => _AddNewProductType();
}

class _AddNewProductType extends State<ProductTypeRadioListTile>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _opacityAnimation;
  bool? _currentTheme;

  @override
  void didUpdateWidget(ProductTypeRadioListTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.checked != widget.checked) {
      if (widget.checked) {
        _controller?.forward();
      } else {
        _controller?.reverse();
      }
    }
  }

  // To reset animations when theme changes
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_currentTheme != context.lightTheme()) {
      _controller = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool lightTheme = context.lightTheme();
    _initAnimationsIfNecessary(lightTheme);

    final SmoothColorsThemeExtension theme =
        Theme.of(context).extension<SmoothColorsThemeExtension>()!;

    return Semantics(
      label:
          '${widget.productType.getTitle(appLocalizations)} ${widget.productType.getSubtitle(appLocalizations)}',
      checked: widget.checked,
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _colorAnimation.value,
          borderRadius: ANGULAR_BORDER_RADIUS,
          border: Border.all(
            color: lightTheme ? theme.primarySemiDark : theme.primaryNormal,
            width: 2.0,
          ),
        ),
        margin: const EdgeInsetsDirectional.only(
          start: VERY_LARGE_SPACE,
          end: VERY_LARGE_SPACE,
          top: VERY_LARGE_SPACE,
        ),
        child: InkWell(
          onTap: () => widget.onChanged(widget.productType),
          child: Stack(
            children: <Widget>[
              PositionedDirectional(
                bottom: 0.0,
                end: 0.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(ANGULAR_RADIUS.x - 2.0),
                  ),
                  child: SvgPicture.asset(
                    widget.productType.getIllustration(),
                    width: 50.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  top: LARGE_SPACE,
                  start: MEDIUM_SPACE,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: lightTheme
                              ? theme.primarySemiDark
                              : theme.primaryMedium,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: const icons.Check(
                          size: 9.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: MEDIUM_SPACE),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          bottom: LARGE_SPACE,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.productType.getTitle(appLocalizations),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightTheme ? Colors.black : Colors.white,
                              ),
                            ),
                            const SizedBox(height: SMALL_SPACE),
                            Text(
                              widget.productType.getSubtitle(appLocalizations),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: lightTheme
                                    ? Colors.black54
                                    : Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initAnimationsIfNecessary(bool lightTheme) {
    if (_controller != null) {
      return;
    }

    _currentTheme = lightTheme;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() => setState(() {}));

    final ThemeData themeData = Theme.of(context);

    _colorAnimation = ColorTween(
      begin: themeData.scaffoldBackgroundColor.withOpacity(0.0),
      end: lightTheme
          ? themeData.extension<SmoothColorsThemeExtension>()!.primaryMedium
          : themeData.extension<SmoothColorsThemeExtension>()!.primarySemiDark,
    ).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.fastOutSlowIn),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.fastOutSlowIn),
    );
  }
}

extension ProductTypeExtension on ProductType {
  String getTitle(AppLocalizations appLocalizations) {
    return switch (this) {
      ProductType.food => appLocalizations.product_type_label_food,
      ProductType.beauty => appLocalizations.product_type_label_beauty,
      ProductType.petFood => appLocalizations.product_type_label_pet_food,
      ProductType.product => appLocalizations.product_type_label_product,
    };
  }

  String getSubtitle(AppLocalizations appLocalizations) {
    return switch (this) {
      ProductType.food => appLocalizations.product_type_subtitle_food,
      ProductType.beauty => appLocalizations.product_type_subtitle_beauty,
      ProductType.petFood => appLocalizations.product_type_subtitle_pet_food,
      ProductType.product => appLocalizations.product_type_subtitle_product,
    };
  }

  String getIllustration() {
    return switch (this) {
      ProductType.food => 'assets/misc/logo_off_half.svg',
      ProductType.beauty => 'assets/misc/logo_obf_half.svg',
      ProductType.petFood => 'assets/misc/logo_opff_half.svg',
      ProductType.product => 'assets/misc/logo_opf_half.svg',
    };
  }
}
