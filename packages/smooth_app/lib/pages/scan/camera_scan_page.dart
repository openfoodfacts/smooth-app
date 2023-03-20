import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart' hide Listener;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/helpers/app_helper.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/pages/scan/smooth_barcode_scanner_mlkit.dart';
import 'package:smooth_app/pages/scan/smooth_barcode_scanner_mockup.dart';
import 'package:smooth_app/pages/scan/smooth_barcode_scanner_type.dart';
import 'package:smooth_app/pages/scan/smooth_barcode_scanner_zxing.dart';

/// A page showing the camera feed and decoding barcodes.
class CameraScannerPage extends StatefulWidget {
  const CameraScannerPage(this.scannerType);

  final SmoothBarcodeScannerType scannerType;

  @override
  CameraScannerPageState createState() => CameraScannerPageState();
}

class CameraScannerPageState extends State<CameraScannerPage>
    with TraceableClientMixin, WidgetsBindingObserver {
  /// Audio player to play the beep sound on scan
  /// This attribute is only initialized when a camera is available AND the
  /// setting is set to ON
  AudioPlayer? _musicPlayer;

  late ContinuousScanModel _model;
  late UserPreferences _userPreferences;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (mounted) {
      _model = context.watch<ContinuousScanModel>();
      _userPreferences = context.watch<UserPreferences>();
    }
  }

  @override
  String get traceTitle => 'ml_kit_scan_page';

  @override
  String get traceName => 'Opened ml_kit_scan_page';

  @override
  Widget build(BuildContext context) {
    if (!CameraHelper.hasACamera) {
      return Center(
        child: Text(AppLocalizations.of(context).permission_photo_none_found),
      );
    }
    switch (widget.scannerType) {
      case SmoothBarcodeScannerType.mlkit:
        return SmoothBarcodeScannerMLKit(_onNewBarcodeDetected);
      case SmoothBarcodeScannerType.zxing:
        return SmoothBarcodeScannerZXing(_onNewBarcodeDetected);
      case SmoothBarcodeScannerType.mockup:
        return const SmoothBarcodeScannerMocked();
    }
  }

  Future<bool> _onNewBarcodeDetected(final String barcode) async {
    if (!await _model.onScan(barcode)) {
      return false;
    }

    // Both are Future methods, but it doesn't matter to wait here
    SmoothHapticFeedback.lightNotification();

    if (_userPreferences.playCameraSound) {
      await _initSoundManagerIfNecessary();
      await _musicPlayer!.stop();
      await _musicPlayer!.resume();
    }

    _userPreferences.setFirstScanAchieved();
    return true;
  }

  /// Only initialize the "beep" player when needed
  /// (at least one camera available + settings set to ON)
  Future<void> _initSoundManagerIfNecessary() async {
    if (_musicPlayer != null) {
      return;
    }

    _musicPlayer = AudioPlayer(playerId: '1');
    _musicPlayer!.audioCache.prefix = AppHelper.defaultAssetPath;
    await _musicPlayer!.setSourceAsset('audio/beep.ogg');
    await _musicPlayer!.setPlayerMode(PlayerMode.lowLatency);
    await _musicPlayer!.setAudioContext(
      const AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.notificationEvent,
          audioFocus: AndroidAudioFocus.gainTransientExclusive,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.soloAmbient,
          options: <AVAudioSessionOptions>[
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.defaultToSpeaker,
          ],
        ),
      ),
    );
  }

  Future<void> _disposeSoundManager() async {
    await _musicPlayer?.release();
    await _musicPlayer?.dispose();
    _musicPlayer = null;
  }

  @override
  void dispose() {
    _disposeSoundManager();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
