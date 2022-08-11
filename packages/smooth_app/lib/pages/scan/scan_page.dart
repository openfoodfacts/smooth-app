import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/permission_helper.dart';
import 'package:smooth_app/pages/scan/ml_kit_scan_page.dart';
import 'package:smooth_app/pages/scan/scan_visor.dart';
import 'package:smooth_app/pages/scan/scanner_overlay.dart';
import 'package:smooth_app/widgets/smooth_product_carousel.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class ScanPage extends StatefulWidget {
  const ScanPage();

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  ContinuousScanModel? _model;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateModel();
  }

  Future<void> _updateModel() async {
    if (_model == null) {
      _model = context.read<ContinuousScanModel>();
    } else {
      await _model!.refresh();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_model == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SmoothScaffold(
      brightness: Brightness.light,
      body: ScannerOverlay(
        backgroundChild: const _ScanPageBackgroundWidget(),
        foregroundChild: const _ScanPageForegroundWidget(),
        topChild: const _ScanPageTopWidget(),
      ),
    );
  }
}

class _ScanPageBackgroundWidget extends StatelessWidget {
  const _ScanPageBackgroundWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionListener>(
      builder: (BuildContext context, PermissionListener listener, _) {
        if (listener.value.isGranted) {
          return const MLKitScannerPage();
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

/// A semi-transparent Widget where the visor is fully visible
class _ScanPageForegroundWidget extends StatelessWidget {
  const _ScanPageForegroundWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Consumer<PermissionListener>(
            builder: (BuildContext context, PermissionListener listener, _) {
          // If permission is granted && the device has a camera
          if (listener.value.isGranted && CameraHelper.hasACamera) {
            return CustomPaint(
              painter: _ScanPageForegroundPainter(
                visorSize: ScannerVisorWidget.getSize(context),
                carouselHeight:
                    constraints.maxHeight * ScannerOverlay.carouselHeightPct,
                contentHeight: constraints.maxHeight,
                topOffset: MediaQuery.of(context).viewPadding.top,
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        });
      },
    );
  }
}

class _ScanPageForegroundPainter extends CustomPainter {
  _ScanPageForegroundPainter({
    required this.visorSize,
    required this.topOffset,
    required double carouselHeight,
    required double contentHeight,
  })  : availableHeightBeforeCarousel =
            contentHeight - carouselHeight - topOffset,
        _paint = Paint()..color = Colors.black.withOpacity(0.3);

  final Size visorSize;
  final double topOffset;
  final double availableHeightBeforeCarousel;

  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path.combine(
      PathOperation.difference,
      Path()
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      ScanVisorPainter.getPath(
        Rect.fromLTWH(
          (size.width - visorSize.width) / 2,
          0,
          visorSize.width,
          visorSize.height,
        ),
        true,
      ).shift(
        Offset(
          0,
          topOffset +
              ((availableHeightBeforeCarousel -
                      visorSize.height +
                      ScanVisorPainter.strokeWidth) /
                  2),
        ),
      ),
    );

    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanPageTopWidget extends StatelessWidget {
  const _ScanPageTopWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionListener>(
      builder: (BuildContext context, PermissionListener listener, _) {
        if (listener.value.isGranted) {
          return const ScannerVisorWidget();
        } else {
          final AppLocalizations localizations = AppLocalizations.of(context);

          return SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Container(
                  alignment: Alignment.topCenter,
                  constraints: BoxConstraints.tightForFinite(
                    width: constraints.maxWidth *
                        SmoothProductCarousel.carouselViewPortFraction,
                    height: math.min(constraints.maxHeight * 0.9, 200),
                  ),
                  padding: SmoothProductCarousel.carouselItemInternalPadding,
                  child: SmoothCard(
                    padding: const EdgeInsetsDirectional.only(
                      top: 10.0,
                      start: SMALL_SPACE,
                      end: SMALL_SPACE,
                      bottom: 5.0,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: <Widget>[
                          Text(
                            localizations.permission_photo_denied_title,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 10.0,
                                ),
                                child: Text(
                                  localizations.permission_photo_denied_message(
                                    APP_NAME,
                                  ),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    height: 1.4,
                                    fontSize: 15.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SmoothActionButtonsBar.single(
                            action: SmoothActionButton(
                              text:
                                  localizations.permission_photo_denied_button,
                              onPressed: () => _askPermission(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Future<void> _askPermission(BuildContext context) {
    return Provider.of<PermissionListener>(
      context,
      listen: false,
    ).askPermission(() async {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            final AppLocalizations localizations = AppLocalizations.of(context);

            return SmoothAlertDialog(
              title:
                  localizations.permission_photo_denied_dialog_settings_title,
              body: Text(
                localizations.permission_photo_denied_dialog_settings_message,
                style: const TextStyle(
                  height: 1.6,
                ),
              ),
              negativeAction: SmoothActionButton(
                text: localizations
                    .permission_photo_denied_dialog_settings_button_cancel,
                onPressed: () => Navigator.of(context).pop(false),
                lines: 2,
              ),
              positiveAction: SmoothActionButton(
                text: localizations
                    .permission_photo_denied_dialog_settings_button_open,
                onPressed: () => Navigator.of(context).pop(true),
                lines: 2,
              ),
            );
          });
    });
  }
}
