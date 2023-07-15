import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';

class SmoothProductCardLoading extends StatefulWidget {
  const SmoothProductCardLoading({required this.barcode});

  final String barcode;

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

    return DefaultTextStyle.merge(
      textAlign: TextAlign.center,
      style: const TextStyle(height: 1.4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: SMALL_SPACE,
          horizontal: MEDIUM_SPACE,
        ),
        decoration: BoxDecoration(
          color: themeData.brightness == Brightness.light
              ? Colors.white
              : Colors.black,
          borderRadius: ROUNDED_BORDER_RADIUS,
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
              transitionBuilder: (Widget child, Animation<double> animation) {
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
            if (_progress == _SmoothProductCardLoadingProgress.unresponsive)
              SmoothSimpleButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.restart_alt),
                    const SizedBox(
                      width: SMALL_SPACE,
                    ),
                    Text(appLocalizations.scan_product_loading_restart_button)
                  ],
                ),
                onPressed: () {
                  final ContinuousScanModel model =
                      context.read<ContinuousScanModel>();

                  model.retryBarcodeFetch(widget.barcode);
                },
              ),
            const Spacer(),
            Expanded(
              flex: 10,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 300,
                ),
                child: const RiveAnimation.asset(
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
