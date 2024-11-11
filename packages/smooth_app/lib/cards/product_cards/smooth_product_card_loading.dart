import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_base_card.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class SmoothProductCardLoading extends StatefulWidget {
  const SmoothProductCardLoading({
    required this.barcode,
    this.onRemoveProduct,
  });

  final String barcode;
  final OnRemoveCallback? onRemoveProduct;

  @override
  State<SmoothProductCardLoading> createState() =>
      _SmoothProductCardLoadingState();
}

class _SmoothProductCardLoadingState extends State<SmoothProductCardLoading> {
  late Timer _timer;
  _SmoothProductCardLoadingProgress _progress =
      _SmoothProductCardLoadingProgress.initial;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 7), _onLongRequest);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData themeData = Theme.of(context);
    final bool lightTheme = context.lightTheme();

    return DefaultTextStyle.merge(
      textAlign: TextAlign.center,
      style: const TextStyle(height: 1.4),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(top: VERY_SMALL_SPACE),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: <Widget>[
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: themeData.brightness == Brightness.light
                        ? Colors.white
                        : Colors.black,
                    borderRadius: ROUNDED_BORDER_RADIUS,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: themeData.shadowColor
                            .withOpacity(lightTheme ? 0.08 : 0.3),
                        offset: const Offset(0.0, 2.0),
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadiusDirectional.vertical(
                          top: ROUNDED_RADIUS,
                        ),
                        color: lightTheme
                            ? themeData
                                .extension<SmoothColorsThemeExtension>()!
                                .secondaryLight
                            : themeData
                                .extension<SmoothColorsThemeExtension>()!
                                .secondaryNormal,
                      ),
                      padding: const EdgeInsets.all(SMALL_SPACE),
                      child: Text(
                        AppLocalizations.of(context).loading_in_progress,
                        style: TextStyle(
                          color: lightTheme ? Colors.white : Colors.black,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: SMALL_SPACE,
                          horizontal: MEDIUM_SPACE,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            const Spacer(),
                            Text(
                              appLocalizations.scan_product_loading,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            const Spacer(flex: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SMALL_SPACE,
                                vertical: SMALL_SPACE,
                              ),
                              color: Colors.grey.withOpacity(0.2),
                              child: Text(
                                '<${widget.barcode}>',
                                style: const TextStyle(
                                  letterSpacing: 6.0,
                                  fontFeatures: <FontFeature>[
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(flex: 2),
                            AnimatedSwitcher(
                              duration: SmoothAnimationsDuration.long,
                              child: Text(_description(appLocalizations)),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: Tween<double>(
                                    begin: 0.0,
                                    end: 1.0,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                            ),
                            const Spacer(),
                            Expanded(
                              flex: 10,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 300,
                                ),
                                child: _progress ==
                                        _SmoothProductCardLoadingProgress
                                            .unresponsive
                                    ? Center(
                                        child: SmoothSimpleButton(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              const Icon(Icons.restart_alt),
                                              const SizedBox(
                                                width: SMALL_SPACE,
                                              ),
                                              Text(appLocalizations
                                                  .scan_product_loading_restart_button)
                                            ],
                                          ),
                                          onPressed: () {
                                            AnalyticsHelper.trackEvent(
                                              AnalyticsEvent
                                                  .restartProductLoading,
                                              barcode: widget.barcode,
                                            );

                                            final ContinuousScanModel model =
                                                context.read<
                                                    ContinuousScanModel>();

                                            model.retryBarcodeFetch(
                                                widget.barcode);
                                          },
                                        ),
                                      )
                                    : const RiveAnimation.asset(
                                        'assets/animations/off.riv',
                                        artboard: 'Loading',
                                        alignment: Alignment.topCenter,
                                        fit: BoxFit.fitHeight,
                                      ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_progress != _SmoothProductCardLoadingProgress.initial)
                Positioned.directional(
                  top: VERY_LARGE_SPACE,
                  end: 0.0,
                  textDirection: Directionality.of(context),
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      top: constraints.maxHeight * 0.05,
                      end: constraints.maxWidth * 0.05,
                    ),
                    child: ProductCardCloseButton(
                      onRemove: (BuildContext context) {
                        AnalyticsHelper.trackEvent(
                          AnalyticsEvent.ignoreProductLoading,
                          barcode: widget.barcode,
                        );

                        widget.onRemoveProduct?.call(context);
                      },
                      iconData: CupertinoIcons.clear_circled,
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  String _description(AppLocalizations appLocalizations) {
    return switch (_progress) {
      _SmoothProductCardLoadingProgress.longRequest =>
        appLocalizations.scan_product_loading_long_request,
      _SmoothProductCardLoadingProgress.unresponsive =>
        appLocalizations.scan_product_loading_unresponsive,
      _ => appLocalizations.scan_product_loading_initial,
    };
  }

  void _onLongRequest() {
    if (!mounted) {
      return;
    }
    setState(() => _progress = _SmoothProductCardLoadingProgress.longRequest);
    _timer = Timer(const Duration(seconds: 5), _onUnresponsiveRequest);
  }

  void _onUnresponsiveRequest() {
    if (!mounted) {
      return;
    }
    setState(() => _progress = _SmoothProductCardLoadingProgress.unresponsive);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

enum _SmoothProductCardLoadingProgress {
  initial,
  longRequest,
  unresponsive,
}
