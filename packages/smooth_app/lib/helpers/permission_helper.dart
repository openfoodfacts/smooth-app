import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionListener extends ValueNotifier<DevicePermission> {
  PermissionListener({
    required this.permission,
  }) : super(DevicePermission._initial(permission)) {
    checkPermission();
  }

  final Permission permission;

  Future<void> checkPermission() async {
    value = DevicePermission._(
      permission,
      DevicePermissionStatus.checking,
    );

    _onNewPermissionStatus(await permission.request());
  }

  Future<void> askPermission(
    Future<bool?> Function() onRationaleNotAvailable,
  ) async {
    final bool showRationale = await permission.shouldShowRequestRationale;

    if (showRationale) {
      _onNewPermissionStatus(await permission.request());
    } else {
      final bool? shouldOpenSettings = await onRationaleNotAvailable.call();

      if (shouldOpenSettings == true) {
        await openAppSettings();
        return checkPermission();
      }
    }
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
