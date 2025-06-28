import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/*
For iOS:
go to flutter/packages/integration_test/ios/Classes/IntegrationTestPlugin.m
edit method registerWithRegistrar this way
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    [[IntegrationTestPlugin instance] setupChannels:registrar.messenger];
}
then flutter clean
 */

// cf. https://dev.to/mjablecnik/take-screenshot-during-flutter-integration-tests-435k
/// Screenshot driver.
Future<void> main() async => integrationDriver(
  onScreenshot:
      (
        String screenshotName,
        List<int> screenshotBytes, [
        Map<String, Object?>? args,
      ]) async {
        final File image = await File(
          'screenshots/$screenshotName.png',
        ).create(recursive: true);
        image.writeAsBytesSync(screenshotBytes);
        return true;
      },
);
