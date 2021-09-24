import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_app/pages/scan/search_panel.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_product_carousel.dart';
import 'package:smooth_ui_library/smooth_ui_library.dart';

class ContinuousScanPage extends StatelessWidget {
  final GlobalKey _scannerViewKey = GlobalKey(debugLabel: 'Barcode Scanner');

  @override
  Widget build(BuildContext context) {
    final ContinuousScanModel model = context.watch<ContinuousScanModel>();
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0.0),
      body: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            color: Colors.black,
            child: SvgPicture.asset(
              'assets/actions/scanner_alt_2.svg',
              width: 60.0,
              height: 60.0,
              color: Colors.white,
            ),
          ),
          if (model.cameraStatus.isGranted)
            SmoothRevealAnimation(
              delay: 400,
              startOffset: Offset.zero,
              animationCurve: Curves.easeInOutBack,
              child: QRView(
                key: _scannerViewKey,
                onQRViewCreated: model.setupScanner,
              ),
            ),
          SmoothRevealAnimation(
            delay: 400,
            startOffset: const Offset(0.0, 0.1),
            animationCurve: Curves.easeInOutBack,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: SmoothViewFinder(
                    boxSize:
                        Size(screenSize.width * 0.6, screenSize.width * 0.33),
                    lineLength: screenSize.width * 0.8,
                  ),
                )
              ],
            ),
          ),
          SmoothRevealAnimation(
            delay: 400,
            startOffset: const Offset(0.0, -0.1),
            animationCurve: Curves.easeInOutBack,
            child: Column(
              children: <Widget>[
                if (model.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cancel_outlined),
                        onPressed: model.clearScanSession,
                        label: const Text('Clear'),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.emoji_events_outlined),
                        onPressed: () => _openPersonalizedRankingPage(context),
                        label: Text(localizations.myPersonalizedRanking),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  const SmoothProductCarousel(),
                ],
              ],
            ),
          ),
          SearchPanel(),
          if (!model.cameraStatus.isGranted) CameraRequestButton(),
        ],
      ),
    );
  }

  Future<void> _openPersonalizedRankingPage(BuildContext context) async {
    final ContinuousScanModel model = context.read<ContinuousScanModel>();
    await model.refreshProductList();
    await Navigator.push<Widget>(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => PersonalizedRankingPage(
          model.productList,
        ),
      ),
    );
    await model.refresh();
  }
}

class CameraRequestButton extends StatefulWidget {
  @override
  State<CameraRequestButton> createState() => _CameraRequestButtonState();
}

class _CameraRequestButtonState extends State<CameraRequestButton> {
  late PermissionStatus _permissionStatus;
  late ContinuousScanModel _model;
  late AppLocalizations _appLocalizations;

  @override
  Widget build(BuildContext context) {
    _model = context.watch<ContinuousScanModel>();
    _permissionStatus = _model.cameraStatus;
    // We should only be here if we don't have permission.
    assert(!_permissionStatus.isGranted);


    _appLocalizations = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final MaterialColor materialColor = SmoothTheme.getMaterialColor(themeProvider);
    final Color? strongBackgroundColor = SmoothTheme.getColor(
      colorScheme,
      materialColor,
      ColorDestination.SURFACE_BACKGROUND,
    );
    final Color? strongForegroundColor = SmoothTheme.getColor(
      colorScheme,
      materialColor,
      ColorDestination.SURFACE_FOREGROUND,
    );

    return Column(
      children: <Widget>[
        const Spacer(flex: 2),
        Center(
          child: FloatingActionButton.extended(
            backgroundColor: strongBackgroundColor,
            onPressed: (){
              _requestCameraPermission();
            },
            label: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Icon(Icons.camera_alt, color: strongForegroundColor),
                  const SizedBox(width: 10.0),
                  // TODO(Piinks): Localize this text once settled on
                   Text(
                     'Grant camera permission to scan',
                     style: SmoothTheme.getThemeData(
                         themeProvider.darkTheme ? Brightness.dark : Brightness.light,
                         themeProvider.colorTag
                     ).textTheme.subtitle1!.copyWith(color: strongForegroundColor),
                   ),
                ]
              ),
            )
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Future<void> _requestCameraPermission() async {
    PermissionStatus? status;
    switch (_permissionStatus) {
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
        // Request status
        status = await Permission.camera.request();
        break;
      case PermissionStatus.permanentlyDenied:
        // We cannot resolve this here, show a dialog directing the user to
        // system preferences to fix camera permissions.
        _redirectToSettings();
        break;
      case PermissionStatus.granted:
        // Something has gone wrong if we are here and permission is already
        // granted.
        // throw?
        break;
    }

    setState(() {
      // If the user could not update the status here in the app
      // (PermissionStatus.permanentlyDenied), then when they return to the
      // app it will update.
      if (status != null) {
        _model.setCameraStatus(status);
        _permissionStatus = status;
      }
    });
  }

  void _redirectToSettings() {
    // TODO(Piinks): Localize strings once determined
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Unable to grant camera permission'),
        content: const Text(
          'Permission was previously denied, please visit system settings to '
          'enable camera access.'
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, _appLocalizations.cancel),
            child: Text(_appLocalizations.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'Go to System Settings');
              openAppSettings();
            },
            child: const Text('Go To System Settings'),
          ),
        ],
      ),
    );
  }

}
