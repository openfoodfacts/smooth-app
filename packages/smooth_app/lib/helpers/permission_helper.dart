import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/services/smooth_services.dart';

class PermissionListener extends ValueNotifier<DevicePermission> {
  PermissionListener({required this.permission})
    : _status = _DevicePermissionStatus.initial,
      super(DevicePermission._initial(permission));

  final Permission permission;
  _DevicePermissionStatus _status = _DevicePermissionStatus.initial;

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);

    if (_status == _DevicePermissionStatus.initial) {
      _refreshPermissionStatus();
    }
  }

  Future<void> _refreshPermissionStatus() async {
    bool permissionGranted;
    if (permission == Permission.camera && !CameraHelper.hasACamera) {
      /// If a device doesn't have a camera, let's pretend the permission is
      /// granted.
      permissionGranted = true;
    } else {
      permissionGranted = await permission.isGranted;
    }

    value = DevicePermission._(
      permission,
      permissionGranted
          ? DevicePermissionStatus.granted
          : DevicePermissionStatus.unknown,
    );

    _status = _DevicePermissionStatus.answered;
  }

  Future<void> askPermission({
    Future<bool?> Function()? onRationaleNotAvailable,
  }) async {
    // Prevent multiples calls to this method
    if (_status == _DevicePermissionStatus.asked) {
      return;
    }

    _status = _DevicePermissionStatus.asked;

    // On non-Android platforms, this call will always return false
    final bool showRationale = await permission.shouldShowRequestRationale;

    // Directly ask for the permission on Android (first time) and iOS
    if (showRationale ||
        !Platform.isAndroid ||
        value.status == DevicePermissionStatus.unknown) {
      await _requestPermission();
    }

    if (!value.isGranted && onRationaleNotAvailable != null) {
      final bool? shouldOpenSettings = await onRationaleNotAvailable.call();

      if (shouldOpenSettings == true) {
        await openAppSettings();
        await _refreshPermissionStatus();

        if (!value.isGranted) {
          await _requestPermission();
          return;
        }
      }
    }

    _status = _DevicePermissionStatus.answered;
  }

  Future<void> _requestPermission() async {
    final PermissionStatus status = await permission.request();

    value = DevicePermission._fromPermissionStatus(permission, status);
  }

  @override
  set value(DevicePermission newValue) {
    super.value = newValue;

    Logs.d('New permission value: $newValue', tag: 'PermissionListener');
  }
}

class DevicePermission {
  const DevicePermission._(this.permission, this.status);

  const DevicePermission._initial(this.permission)
    : status = DevicePermissionStatus.checking;

  DevicePermission._fromPermissionStatus(
    this.permission,
    PermissionStatus status,
  ) : status = _extractFromPermissionStatus(status);

  final Permission permission;
  final DevicePermissionStatus status;

  static DevicePermissionStatus _extractFromPermissionStatus(
    PermissionStatus status,
  ) {
    switch (status) {
      case PermissionStatus.denied:
        return DevicePermissionStatus.denied;
      case PermissionStatus.granted:
        return DevicePermissionStatus.granted;
      case PermissionStatus.restricted:
        return DevicePermissionStatus.restricted;
      case PermissionStatus.limited:
        return DevicePermissionStatus.limited;
      case PermissionStatus.permanentlyDenied:
        return DevicePermissionStatus.permanentlyDenied;
      case PermissionStatus.provisional:
        return DevicePermissionStatus.provisional;
    }
  }

  bool get isGranted => status == DevicePermissionStatus.granted;

  @override
  String toString() {
    return 'DevicePermission{permission: $permission, status: $status}';
  }
}

enum DevicePermissionStatus {
  checking,
  denied,
  granted,
  restricted,
  limited,
  permanentlyDenied,
  provisional,

  /// Unknown means that a call to [PermissionListener.askPermission] is required
  unknown,
}

/// Enum allowing to track the status of the [askPermission] method
enum _DevicePermissionStatus {
  // Never called
  initial,
  // Call in progress
  asked,
  // Finished
  // /!\ it doesn't mean the permission is granted
  answered,
}
