import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_action_button.dart';
import 'package:smooth_app/generic_lib/dialogs/smooth_alert_dialog.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/permission_helper.dart';
import 'package:smooth_app/pages/scan/continuous_scan_page.dart';
import 'package:smooth_app/pages/scan/ml_kit_scan_page.dart';
import 'package:smooth_app/pages/scan/scanner_overlay.dart';
import 'package:smooth_app/pages/user_preferences_dev_mode.dart';
import 'package:smooth_app/widgets/smooth_product_carousel.dart';

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: MultiProvider(
          providers: <ChangeNotifierProvider<ChangeNotifier>>[
            ChangeNotifierProvider<PermissionListener>(
              create: (_) => PermissionListener(
                permission: Permission.camera,
              ),
            ),
            ChangeNotifierProvider<ContinuousScanModel>(
              create: (BuildContext context) => _model!,
            )
          ],
          child: const ScannerOverlay(
            backgroundChild: _ScanPageBackgroundWidget(),
            topChild: _ScanPageTopWidget(),
          ),
        ),
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
        final UserPreferences userPreferences = context.read<UserPreferences>();

        if (listener.value.isGranted) {
          if (userPreferences.getFlag(
                UserPreferencesDevMode.userPreferencesFlagUseMLKit,
              ) ??
              true) {
            return const MLKitScannerPage();
          } else {
            return const ContinuousScanPage();
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }
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
          final AppLocalizations localizations = AppLocalizations.of(context)!;

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
                      start: 8.0,
                      end: 8.0,
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
                                    localizations.app_name,
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
                          SmoothActionButton(
                            text: localizations.permission_photo_denied_button,
                            onPressed: () => _askPermission(context),
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
            final AppLocalizations localizations =
                AppLocalizations.of(context)!;

            return SmoothAlertDialog(
              title:
                  localizations.permission_photo_denied_dialog_settings_title,
              body: Text(
                localizations.permission_photo_denied_dialog_settings_message,
                style: const TextStyle(
                  height: 1.6,
                ),
              ),
              actions: <SmoothActionButton>[
                SmoothActionButton(
                  text: localizations
                      .permission_photo_denied_dialog_settings_button_cancel,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                SmoothActionButton(
                  text: localizations
                      .permission_photo_denied_dialog_settings_button_open,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          });
    });
  }
}
