import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// A wrapper for testing various pages of the app with a simple state.
class MockSmoothApp extends StatelessWidget {
  MockSmoothApp(
    this.userPreferences,
    this.userManagementProvider,
    this.productPreferences,
    this.themeProvider,
    this.textContrastProvider,
    this.colorProvider,
    this.child, {
    this.localDatabase,
  }) {
    mockMatomo();
  }

  final UserPreferences userPreferences;
  final UserManagementProvider userManagementProvider;
  final ProductPreferences productPreferences;
  final ThemeProvider themeProvider;
  final ColorProvider colorProvider;
  final TextContrastProvider textContrastProvider;
  final LocalDatabase? localDatabase;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: <ChangeNotifierProvider<dynamic>>[
          ChangeNotifierProvider<UserPreferences>.value(value: userPreferences),
          ChangeNotifierProvider<ProductPreferences>.value(
              value: productPreferences),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ChangeNotifierProvider<UserManagementProvider>.value(
              value: userManagementProvider),
          if (localDatabase != null)
            ChangeNotifierProvider<LocalDatabase>.value(value: localDatabase!),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: SmoothTheme.getThemeData(
            Brightness.light,
            themeProvider,
            () => colorProvider,
            () => textContrastProvider,
          ),
          darkTheme: SmoothTheme.getThemeData(
            Brightness.dark,
            themeProvider,
            () => colorProvider,
            () => textContrastProvider,
          ),
          themeMode: themeProvider.currentThemeMode,
          home: child,
        ));
  }
}

Map<String, Object> mockSharedPreferences({
  bool init = true,
  bool themeDark = false,
}) =>
    <String, Object>{
      // Configured by test
      'init': init,
      'currentThemeMode': themeDark ? 'Dark' : 'Light',

      // Very important by default
      'IMPORTANCE_AS_STRINGnutriscore': 'very_important',

      // Important by default
      'IMPORTANCE_AS_STRINGecoscore': 'important',
      'IMPORTANCE_AS_STRINGnova': 'important',

      // Not important by default
      'IMPORTANCE_AS_STRINGadditives': 'not_important',
      'IMPORTANCE_AS_STRINGallergens_no_celery': 'not_important',
      'IMPORTANCE_AS_STRINGallergens_no_crustaceans': 'not_important',
      'IMPORTANCE_AS_STRINGallergens_no_eggs': 'not_important',
      'IMPORTANCE_AS_STRINGallergens_no_fish': 'not_important',
      'IMPORTANCE_AS_STRINGallergens_no_gluten': 'not_important',
      'IMPORTANCE_AS_STRINGallergens_no_lupin': 'not_important',
      'IMPORTANCE_AS_STRINGallergens_no_milk': 'not_important',
      'IMPORTANCE_AS_STRINGallergens_no_molluscs': 'not_important',
      'IMPORTANCE_AS_STRINGallergens_no_mustard': 'not_important',
      'IMPORTANCE_AS_STRINGallergens_no_nuts': 'not_important',
      'IMPORTANCE_AS_STRINGallergens_no_peanuts': 'not_important',
      'IMPORTANCE_AS_STRINGallergens_no_sesame_seeds': 'not_important',
      'IMPORTANCE_AS_STRINGallergens_no_soybeans': 'not_important',
      'IMPORTANCE_AS_STRINGallergens_no_sulphur_dioxide_and_sulphites':
          'not_important',
      'IMPORTANCE_AS_STRINGforest_footprint': 'not_important',
      'IMPORTANCE_AS_STRINGlabels_fair_trade': 'not_important',
      'IMPORTANCE_AS_STRINGlabels_organic': 'not_important',
      'IMPORTANCE_AS_STRINGlow_fat': 'not_important',
      'IMPORTANCE_AS_STRINGlow_salt': 'not_important',
      'IMPORTANCE_AS_STRINGlow_saturated_fat': 'not_important',
      'IMPORTANCE_AS_STRINGlow_sugars': 'not_important',
      'IMPORTANCE_AS_STRINGpalm_oil_free': 'not_important',
      'IMPORTANCE_AS_STRINGvegan': 'not_important',
      'IMPORTANCE_AS_STRINGvegetarian': 'not_important',
    };

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? _) => _MockHttpClient();
}

class _MockHttpClient extends Mock implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    if (url.toString().endsWith('.svg')) {
      return Future<HttpClientRequest>.value(_MockHttpClientSVGRequest());
    } else {
      throw UnimplementedError(
          'A mock for this request has not been created yet.');
    }
  }
}

class _MockHttpClientSVGRequest extends Mock implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() =>
      Future<HttpClientResponse>.value(_MockHttpClientSVGResponse());
}

class _MockHttpClientSVGResponse extends Mock implements HttpClientResponse {
  @override
  int statusCode = 200;

  @override
  int contentLength = svgStr.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<Uint8List>.fromIterable(<Uint8List>[svgBytes]).listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  }

  static const String svgStr = '''
  <svg width="400" height="400">
    <rect width="400" height="400" style="fill:rgb(128,128,128);stroke-width:3;stroke:rgb(0,0,0)" />
  </svg>
  ''';

  final Uint8List svgBytes = utf8.encode(svgStr);
}

Future<void> mockMatomo() async {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/device_info'),
          (MethodCall call) async {
    if (call.method == 'getDeviceInfo') {
      return <String, dynamic>{
        'computerName': '_',
        'hostName': '_',
        'arch': '_',
        'model': '_',
        'kernelVersion': '_',
        'osRelease': '_',
        'activeCPUs': 1,
        'memorySize': 1,
        'cpuFrequency': 1,
      };
    }
    return null;
  });

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/package_info'),
          (MethodCall call) async {
    if (call.method == 'getAll') {
      return <String, dynamic>{
        'appName': '_',
        'packageName': '_',
        'version': '_',
        'buildNumber': '_',
        'buildSignature': '_',
        'installerStore': '_',
      };
    }
    return null;
  });

  await AnalyticsHelper.initMatomo(false);
  MatomoTracker.instance.setOptOut(optOut: true);
  MatomoTracker.instance.dequeueTimer.cancel();
  MatomoTracker.instance.pingTimer?.cancel();
}
