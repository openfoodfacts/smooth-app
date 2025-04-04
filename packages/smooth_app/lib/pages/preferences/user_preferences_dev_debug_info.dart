import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class UserPreferencesDebugInfo extends StatefulWidget {
  const UserPreferencesDebugInfo({
    super.key,
  });

  @override
  State<UserPreferencesDebugInfo> createState() =>
      _UserPreferencesDebugInfoState();
}

class _UserPreferencesDebugInfoState extends State<UserPreferencesDebugInfo> {
  Map<String, dynamic> infos = <String, dynamic>{
    'LocaleString': ProductQuery.getLocaleString(),
    'Language': ProductQuery.getLanguage().toString(),
    'Country': ProductQuery.getCountry().toString(),
    'IsLoggedIn': ProductQuery.isLoggedIn().toString(),
    'UUID': OpenFoodAPIConfiguration.uuid.toString(),
    'Matomo Visitor ID': AnalyticsHelper.matomoVisitorId,
    'QueryType': ProductQuery.getUriProductHelper(productType: ProductType.food)
            .isTestMode
        ? 'QueryType.TEST'
        : 'QueryType.PROD',
    'Domain':
        ProductQuery.getUriProductHelper(productType: ProductType.food).domain,
    'UserAgent-name': '${OpenFoodAPIConfiguration.userAgent?.name}',
    'UserAgent-system': '${OpenFoodAPIConfiguration.userAgent?.system}',
  };

  // TODO(m123): Add sentry id https://github.com/getsentry/sentry-dart/issues/1205
  Future<void> loadAsyncData() async {
    final BaseDeviceInfo deviceInfo = await DeviceInfoPlugin().deviceInfo;

    if (deviceInfo is AndroidDeviceInfo) {
      infos.putIfAbsent('Model', () => deviceInfo.model);
      infos.putIfAbsent('Product', () => deviceInfo.product);
      infos.putIfAbsent('Device', () => deviceInfo.device);
      infos.putIfAbsent('Brand', () => deviceInfo.brand);
      infos.putIfAbsent('SdkInt', () => deviceInfo.version.sdkInt);
      infos.putIfAbsent('Release', () => deviceInfo.version.release);
    } else if (deviceInfo is IosDeviceInfo) {
      infos.putIfAbsent('SystemVersion', () => deviceInfo.systemVersion);
      infos.putIfAbsent('Model', () => deviceInfo.model);
      infos.putIfAbsent('localizedModel', () => deviceInfo.localizedModel);
    }
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    infos.putIfAbsent('Version', () => packageInfo.version);
    infos.putIfAbsent('BuildNumber', () => packageInfo.buildNumber);
    infos.putIfAbsent('Scanner', () => GlobalVars.barcodeScanner.getType());
    infos.putIfAbsent('Store', () => GlobalVars.storeLabel);
    infos.putIfAbsent('PackageName', () => packageInfo.packageName);
  }

  @override
  Widget build(BuildContext context) {
    return SmoothScaffold(
      appBar: SmoothAppBar(
        title: const Text('Debugging information'),
        actions: <Widget>[
          IconButton(
              onPressed: () async {
                final StringBuffer buffer = StringBuffer();

                for (final MapEntry<String, dynamic> e in infos.entries) {
                  buffer.writeln('${e.key}: ${e.value}');
                }

                await Clipboard.setData(
                  ClipboardData(text: buffer.toString()),
                );
              },
              icon: const Icon(Icons.copy))
        ],
      ),
      body: FutureBuilder<void>(
          future: loadAsyncData(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView.builder(
              itemCount: infos.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    '${infos.keys.elementAt(index)}: ${infos.values.elementAt(index)}',
                  ),
                );
              },
            );
          }),
    );
  }
}
