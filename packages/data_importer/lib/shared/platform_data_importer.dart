import 'dart:io';

import 'package:data_importer/android/android_data_importer.dart';
import 'package:data_importer/ios/ios_data_importer.dart';
import 'package:data_importer/shared/model.dart';

abstract class PlatformDataImporter {
  factory PlatformDataImporter() {
    if (Platform.isAndroid) {
      return AndroidDataImporter();
    } else if (Platform.isIOS) {
      return IOSDataImporter();
    } else {
      throw UnimplementedError('Unsupported platform!');
    }
  }

  Future<ImportableUser?> importUser();
  Future<ImportableUserData?> importLists();
  Future<bool> deleteOldDataOnDevice();
}
