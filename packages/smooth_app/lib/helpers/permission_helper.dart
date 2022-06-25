import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smooth_app/helpers/camera_helper.dart';

class PermissionListener extends ValueNotifier<DevicePermission> {
  PermissionListener({
    required this.permission,
  })  : _status = _DevicePermissionStatus.initial,
        super(DevicePermission._initial(permission));

  final Permission permission;
  _DevicePermissionStatus _status = _DevicePermissionStatus.initial;

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);

    if (_status == _DevicePermissionStatus.initial) {
      checkPermission();
    }
  }

  Future<void> checkPermission() async {
    /// If a device doesn't have a camera, let's pretend the permission is
    /// granted
    if (permission == Permission.camera && !CameraHelper.hasACamera) {
      value = DevicePermission._(
        permission,
        DevicePermissionStatus.granted,
      );
    } else {
      value = DevicePermission._(
        permission,
        DevicePermissionStatus.checking,
      );

      _onNewPermissionStatus(await permission.request());
    }
  }

  Future<void> askPermission(
    Future<bool?> Function() onRationaleNotAvailable,
  ) async {
    // Prevent multiples calls to this method
    if (_status == _DevicePermissionStatus.asked) {
      return;
    }

    _status = _DevicePermissionStatus.asked;

    final bool showRationale = await permission.shouldShowRequestRationale;

    if (showRationale) {
      _onNewPermissionStatus(await permission.request());
    } else {
      final bool? shouldOpenSettings = await onRationaleNotAvailable.call();

      if (shouldOpenSettings == true) {
        await openAppSettings();
        await checkPermission();
      }
    }

    _status = _DevicePermissionStatus.answered;
  }

  void _onNewPermissionStatus(PermissionStatus status) {
    value = DevicePermission._fromPermissionStatus(
      permission,
      status,
    );
  }
}

class DevicePermission {
  const DevicePermission._(this.permission, this.status);

  const DevicePermission._initial(this.permission)
      : status = DevicePermissionStatus.checking;

  DevicePermission._fromPermissionStatus(
      this.permission, PermissionStatus status)
      : status = _extractFromPermissionStatus(status);

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
