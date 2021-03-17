// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';

// Project imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/home_page.dart';
import 'package:smooth_app/temp/product_preferences.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

Future<void> main() async {
  await Sentry.init(
    (dynamic options) {
      options.dsn =
          'https://22ec5d0489534b91ba455462d3736680@o241488.ingest.sentry.io/5376745';
    },
  );
  try {
    runApp(MyApp());
  } catch (exception, stackTrace) {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
    );
  }
}

class MyApp extends StatefulWidget {
  static const String DEFAULT_LANGUAGE_CODE = 'en';
  static String getImportanceAssetPath(final String languageCode) =>
      'assets/metadata/init_preferences_$languageCode.json';
  static String getAttributeAssetPath(final String languageCode) =>
      'assets/metadata/init_attribute_groups_$languageCode.json';

  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UserPreferences _userPreferences;
  ProductPreferences _productPreferences;
  LocalDatabase _localDatabase;
  ThemeProvider _themeProvider;
  bool systemDarkmodeOn = false;

  Future<void> _init(BuildContext context) async {
    _userPreferences = await UserPreferences.getUserPreferences();
    _productPreferences = ProductPreferences(
      (
        String attributeId,
        int importanceIndex,
      ) async {
        await _userPreferences.setImportanceIndex(attributeId, importanceIndex);
        _productPreferences.notifyListeners();
      },
      (String attributeId) => _userPreferences.getImportanceIndex(attributeId),
    );
    if (!await _productPreferences.loadReferenceFromAssets(
      DefaultAssetBundle.of(context),
      MyApp.DEFAULT_LANGUAGE_CODE,
      MyApp.getImportanceAssetPath(MyApp.DEFAULT_LANGUAGE_CODE),
      MyApp.getAttributeAssetPath(MyApp.DEFAULT_LANGUAGE_CODE),
    )) {
      // we're really in trouble!
      return;
    }
    await _userPreferences.init(_productPreferences);
    _localDatabase = await LocalDatabase.getLocalDatabase();
    _themeProvider = ThemeProvider(_userPreferences);
  }

  @override
  void initState() {
    final Brightness brightness =
        SchedulerBinding.instance.window.platformBrightness;
    systemDarkmodeOn = brightness == Brightness.dark;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _init(context),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: <ChangeNotifierProvider<dynamic>>[
              ChangeNotifierProvider<UserPreferences>.value(
                  value: _userPreferences),
              ChangeNotifierProvider<ProductPreferences>.value(
                  value: _productPreferences),
              ChangeNotifierProvider<LocalDatabase>.value(
                  value: _localDatabase),
              ChangeNotifierProvider<ThemeProvider>.value(
                  value: _themeProvider),
            ],
            child: Consumer<ThemeProvider>(
              builder: (
                BuildContext context,
                ThemeProvider value,
                Widget child,
              ) {
                return MaterialApp(
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  theme: SmoothTheme.getThemeData(
                    Brightness.light,
                    _themeProvider.colorTag,
                  ),
                  darkTheme: SmoothTheme.getThemeData(
                    Brightness.dark,
                    _themeProvider.colorTag,
                  ),
                  themeMode: _themeProvider.darkTheme
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  home: SmoothAppGetLanguage(),
                );
              },
            ),
          );
        }
        return Container(
          color: systemDarkmodeOn ? const Color(0xFF181818) : Colors.white,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

/// Layer needed because we need to know the language
class SmoothAppGetLanguage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final Locale myLocale = Localizations.localeOf(context);
    final String languageCode = myLocale.languageCode;
    _refresh(
      productPreferences,
      DefaultAssetBundle.of(context),
      languageCode,
    );
    return HomePage();
  }

  Future<void> _refresh(
    final ProductPreferences productPreferences,
    final AssetBundle assetBundle,
    final String languageCode,
  ) async {
    if (productPreferences.languageCode != languageCode) {
      await productPreferences.loadReferenceFromAssets(
        assetBundle,
        languageCode,
        MyApp.getImportanceAssetPath(languageCode),
        MyApp.getAttributeAssetPath(languageCode),
      );
    }
    if (!productPreferences.isHttps) {
      await productPreferences.loadReferenceFromHttps(languageCode);
    }
  }
}
