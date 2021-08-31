import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

/// A wrapper for testing various pages of the app with a simple state.
class MockSmoothApp extends StatelessWidget {
  const MockSmoothApp(
    this.userPreferences,
    this.productPreferences,
    this.themeProvider,
    this.child,
  );

  final UserPreferences userPreferences;
  final ProductPreferences productPreferences;
  final ThemeProvider themeProvider;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <ChangeNotifierProvider<dynamic>>[
        ChangeNotifierProvider<UserPreferences>.value(value: userPreferences),
        ChangeNotifierProvider<ProductPreferences>.value(value: productPreferences),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: SmoothTheme.getThemeData(
          Brightness.light,
          themeProvider.colorTag,
        ),
        darkTheme: SmoothTheme.getThemeData(
          Brightness.dark,
          themeProvider.colorTag,
        ),
        themeMode: themeProvider.darkTheme
          ? ThemeMode.dark
          : ThemeMode.light,
        home: child,
      )
    );
  }
}

Map<String, Object> mockSharedPreferences({
  String colorTag = 'blue',
  bool init = true,
  bool themeDark = false,
}) => <String, Object>{
  'IMPORTANCE_AS_STRINGallergens_no_fish' : 'not_important',
  'IMPORTANCE_AS_STRINGallergens_no_milk' : 'not_important',
  'IMPORTANCE_AS_STRINGnova' : 'important',
  'IMPORTANCE_AS_STRINGallergens_no_crustaceans' : 'not_important',
  'IMPORTANCE_AS_STRINGecoscore' : 'important',
  'IMPORTANCE_AS_STRINGlabels_fair_trade' : 'not_important',
  'IMPORTANCE_AS_STRINGallergens_no_celery' : 'not_important',
  'IMPORTANCE_AS_STRINGallergens_no_soybeans' : 'not_important',
  'IMPORTANCE_AS_STRINGlow_salt' : 'not_important',
  'IMPORTANCE_AS_STRINGlabels_organic' : 'not_important',
  'init' : init,
  'IMPORTANCE_AS_STRINGallergens_no_sesame_seeds' : 'not_important',
  'IMPORTANCE_AS_STRINGallergens_no_peanuts' : 'not_important',
  'themeColorTag' : colorTag,
  'IMPORTANCE_AS_STRINGadditives' : 'not_important',
  'IMPORTANCE_AS_STRINGallergens_no_gluten' : 'not_important',
  'IMPORTANCE_AS_STRINGallergens_no_molluscs' : 'not_important',
  'IMPORTANCE_AS_STRINGlow_saturated_fat' : 'not_important',
  'IMPORTANCE_AS_STRINGallergens_no_mustard' : 'not_important',
  'IMPORTANCE_AS_STRINGpalm_oil_free' : 'not_important',
  'IMPORTANCE_AS_STRINGlow_fat' : 'not_important',
  'themeDark' : themeDark,
  'IMPORTANCE_AS_STRINGallergens_no_lupin' : 'not_important',
  'IMPORTANCE_AS_STRINGlow_sugars' : 'not_important',
  'IMPORTANCE_AS_STRINGallergens_no_nuts' : 'not_important',
  'IMPORTANCE_AS_STRINGallergens_no_eggs' : 'not_important',
  'IMPORTANCE_AS_STRINGvegan' : 'not_important',
  'IMPORTANCE_AS_STRINGvegetarian' : 'not_important',
  'IMPORTANCE_AS_STRINGforest_footprint' : 'not_important',
  'IMPORTANCE_AS_STRINGnutriscore' : 'very_important',
  'IMPORTANCE_AS_STRINGallergens_no_sulphur_dioxide_and_sulphites' : 'not_important',
};

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? _) => _MockHttpClient();
}

class _MockHttpClient extends Mock implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) => Future<HttpClientRequest>.value(_MockHttpClientRequest());
}

class _MockHttpClientRequest extends Mock implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() => Future<HttpClientResponse>.value(_MockHttpClientResponse());
}

class _MockHttpClientResponse extends Mock implements HttpClientResponse {
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

  static const String svgStr =
  '''
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 166 202">
    <defs>
        <linearGradient id="triangleGradient">
            <stop offset="20%" stop-color="#000000" stop-opacity=".55" />
            <stop offset="85%" stop-color="#616161" stop-opacity=".01" />
        </linearGradient>
        <linearGradient id="rectangleGradient" x1="0%" x2="0%" y1="0%" y2="100%">
            <stop offset="20%" stop-color="#000000" stop-opacity=".15" />
            <stop offset="85%" stop-color="#616161" stop-opacity=".01" />
        </linearGradient>
    </defs>
    <path fill="#42A5F5" fill-opacity=".8" d="M37.7 128.9 9.8 101 100.4 10.4 156.2 10.4"/>
    <path fill="#42A5F5" fill-opacity=".8" d="M156.2 94 100.4 94 79.5 114.9 107.4 142.8"/>
    <path fill="#0D47A1" d="M79.5 170.7 100.4 191.6 156.2 191.6 156.2 191.6 107.4 142.8"/>
    <g transform="matrix(0.7071, -0.7071, 0.7071, 0.7071, -77.667, 98.057)">
        <rect width="39.4" height="39.4" x="59.8" y="123.1" fill="#42A5F5" />
        <rect width="39.4" height="5.5" x="59.8" y="162.5" fill="url(#rectangleGradient)" />
    </g>
    <path d="M79.5 170.7 120.9 156.4 107.4 142.8" fill="url(#triangleGradient)" />
  </svg>
  ''';

  final Uint8List svgBytes = utf8.encode(svgStr) as Uint8List;
}