import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/pages/product/product_type_extensions.dart';
import 'package:smooth_app/pages/user_management/login_page.dart';
import 'package:smooth_app/pages/user_management/sign_up_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/smooth_text.dart';

class AuthenticationBottomSheet {
  AuthenticationBottomSheet(this.context);

  final BuildContext context;

  void show() {
    showSmoothModalSheet<void>(
      context: context,
      isScrollControlled: false,
      builder: (BuildContext context) =>
          const _AuthenticationBottomSheetContent(),
    );
  }
}

class _AuthenticationBottomSheetContent extends StatefulWidget {
  const _AuthenticationBottomSheetContent();

  @override
  __AuthenticationBottomSheetContentState createState() =>
      __AuthenticationBottomSheetContentState();
}

class __AuthenticationBottomSheetContentState
    extends State<_AuthenticationBottomSheetContent> {
  late final List<Offset> chipOffsets;
  late final List<double> chipRotations;
  final ProductType productType = ProductType.food;

  @override
  void initState() {
    super.initState();
    final Random random = Random();
    chipOffsets = List<Offset>.generate(3, (int index) {
      return Offset(
        random.nextDouble() * 10 - 5,
        random.nextDouble() * 10 - 5,
      );
    });
    chipRotations = List<double>.generate(3, (int index) {
      return random.nextDouble() * 0.2 - 0.1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final SmoothColorsThemeExtension colors =
        context.extension<SmoothColorsThemeExtension>();
    final ThemeData theme = Theme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsetsDirectional.all(VERY_SMALL_SPACE),
                decoration: BoxDecoration(
                  color: colors.primaryBlack,
                  borderRadius: const BorderRadius.only(
                    topLeft: ROUNDED_RADIUS,
                    topRight: ROUNDED_RADIUS,
                  ),
                ),
                child: Transform.translate(
                  offset: const Offset(0.0, 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            appLocalizations.authentication_bottom_sheet_header,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SvgPicture.asset(
                        productType.getIllustration(),
                        width: 100.0,
                      ),
                    ],
                  ),
                ),
              ),
              // Content section
              Container(
                width: constraints.maxWidth,
                padding: const EdgeInsetsDirectional.all(LARGE_SPACE),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: ROUNDED_RADIUS,
                    topRight: ROUNDED_RADIUS,
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: TextWithBubbleParts(
                              text: appLocalizations
                                  .authentication_bottom_sheet_title,
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                              ),
                              bubbleTextStyle: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                              backgroundColor: Colors.transparent,
                              bubblePadding: EdgeInsets.zero,
                              // Allow multiple lines
                            ),
                          ),
                          const SizedBox(width: MEDIUM_SPACE),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close,
                                color: Colors.white, size: 28.0),
                            style: IconButton.styleFrom(
                                backgroundColor: colors.primaryBlack),
                          ),
                        ],
                      ),
                      const SizedBox(height: LARGE_SPACE),
                      Text(
                        appLocalizations
                            .authentication_bottom_sheet_title_addition,
                        style: const TextStyle(color: Colors.black),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: LARGE_SPACE * 2),
                      _buildResponsiveChips(appLocalizations, colors),
                      const SizedBox(height: LARGE_SPACE * 2),
                      TextWithBubbleParts(
                        text: appLocalizations
                            .authentication_bottom_sheet_subtitle,
                        textStyle: const TextStyle(color: Colors.black),
                        bubbleTextStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      _buildActionButtons(
                          context, appLocalizations, colors, theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResponsiveChips(
      AppLocalizations appLocalizations, SmoothColorsThemeExtension colors) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Wrap(
          spacing: LARGE_SPACE,
          runSpacing: LARGE_SPACE,
          alignment: WrapAlignment.center,
          children: <Widget>[
            _StampChip(
              text: appLocalizations.authentication_bottom_sheet_first_chip,
              offset: chipOffsets[0],
              rotation: chipRotations[0],
              delay: 0,
            ),
            _StampChip(
              text: appLocalizations.authentication_bottom_sheet_second_chip,
              offset: chipOffsets[1],
              rotation: chipRotations[1],
              delay: 300,
            ),
            _StampChip(
              text: appLocalizations.authentication_bottom_sheet_third_chip,
              offset: chipOffsets[2],
              rotation: chipRotations[2],
              delay: 600,
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppLocalizations appLocalizations,
    SmoothColorsThemeExtension colors,
    ThemeData theme,
  ) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Navigator.of(
                    context,
                    rootNavigator: true,
                  ).push<dynamic>(
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => const LoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  backgroundColor: colors.primaryLight,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                ),
                child: Text(
                  appLocalizations.login,
                  style: TextStyle(
                    color: colors.primaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Navigator.of(
                    context,
                    rootNavigator: true,
                  ).push<dynamic>(
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => const SignUpPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primaryBlack,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          appLocalizations.create_account,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: colors.primaryBlack,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StampChip extends StatefulWidget {
  const _StampChip({
    required this.text,
    required this.offset,
    required this.rotation,
    required this.delay,
  });

  final String text;
  final Offset offset;
  final double rotation;
  final int delay;

  @override
  __StampChipState createState() => __StampChipState();
}

class __StampChipState extends State<_StampChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    final CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _scaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);
    _offsetAnimation = Tween<Offset>(
      begin: Offset(widget.offset.dx, widget.offset.dy - 50),
      end: widget.offset,
    ).animate(curvedAnimation);

    _rotationAnimation = Tween<double>(
      begin: widget.rotation + 0.2,
      end: widget.rotation,
    ).animate(curvedAnimation);

    Future<void>.delayed(
      Duration(milliseconds: widget.delay),
      () => _controller.forward(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SmoothColorsThemeExtension colors =
        context.extension<SmoothColorsThemeExtension>();

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: _offsetAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _controller.value,
                child: child,
              ),
            ),
          ),
        );
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 100,
          maxWidth: 250,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: SMALL_SPACE,
            horizontal: VERY_LARGE_SPACE,
          ),
          decoration: BoxDecoration(
            color: colors.success,
            borderRadius: ROUNDED_BORDER_RADIUS,
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              )
            ],
          ),
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
