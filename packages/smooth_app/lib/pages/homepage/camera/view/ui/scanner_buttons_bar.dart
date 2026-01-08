import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/homepage/camera/view/ui/camera_view.dart';
import 'package:smooth_app/pages/homepage/homepage.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_circled_icon.dart';

class HomePageScannerButtonBars extends StatefulWidget {
  const HomePageScannerButtonBars({required this.onClosed, super.key});

  final VoidCallback onClosed;

  @override
  State<HomePageScannerButtonBars> createState() =>
      _HomePageScannerButtonBarsState();
}

class _HomePageScannerButtonBarsState extends State<HomePageScannerButtonBars> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SafeArea(
      child: IconTheme(
        data: IconThemeData(
          color: context.lightTheme() ? Colors.black : Colors.white,
          shadows: const <Shadow>[
            Shadow(color: Colors.black26, blurRadius: 10.0),
          ],
        ),
        child: Container(
          padding: const EdgeInsetsDirectional.only(
            top: HomePage.TOP_ICON_PADDING,
            start: BALANCED_SPACE,
            end: BALANCED_SPACE,
          ),
          child: Row(
            children: <Widget>[
              CircledTextIcon(
                text: Text(
                  appLocalizations.homepage_scanner_back_to_home_button,
                ),
                icon: const icons.Arrow.down(size: 17.0),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () {
                  context.read<ContinuousScanModel>().lastConsultedBarcode =
                      null;
                  widget.onClosed.call();
                },
              ),
              const Spacer(),
              if (CameraHelper.hasMoreThanOneCamera)
                SmoothCircledIcon(
                  icon: const icons.ToggleCamera(size: 20.0),
                  onPressed: () {
                    context.read<CustomScannerController>().toggleCamera();
                  },
                  tooltip:
                      appLocalizations.homepage_scanner_toggle_camera_tooltip,
                ),
              const _TorchIcon(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TorchIcon extends StatefulWidget {
  const _TorchIcon();

  @override
  State<_TorchIcon> createState() => _TorchIconState();
}

class _TorchIconState extends State<_TorchIcon> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool?>(
      valueListenable: context.watch<CustomScannerController>().hasTorchState,
      builder: (BuildContext context, bool? hasTorch, _) {
        if (hasTorch == null) {
          return EMPTY_WIDGET;
        }

        final CustomScannerController controller = context
            .watch<CustomScannerController>();
        final bool isTorchOn = controller.isTorchOn;
        final Color color = context.lightTheme() ? Colors.black : Colors.white;

        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 10.0),
          child: SmoothCircledIcon(
            icon: switch (isTorchOn) {
              true => TorchAnimation.on(color: color),
              false => TorchAnimation.off(color: color),
            },
            padding: const EdgeInsetsDirectional.all(6.0),
            onPressed: () {
              if (isTorchOn) {
                controller.turnTorchOff();
              } else {
                controller.turnTorchOn();
              }
              HapticFeedback.selectionClick();
              setState(() {});
            },
            tooltip: _getLabel(controller.isTorchOn),
          ),
        );
      },
    );
  }

  String _getLabel(bool isTorchOn) {
    if (isTorchOn) {
      return AppLocalizations.of(context).camera_enable_flash;
    } else {
      return AppLocalizations.of(context).camera_disable_flash;
    }
  }
}
