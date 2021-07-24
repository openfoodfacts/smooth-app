import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/personalized_search/product_preferences_selection.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/home_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Sentry.init(
    (SentryOptions options) {
      options.dsn =
          'https://22ec5d0489534b91ba455462d3736680@o241488.ingest.sentry.io/5376745';
    },
  );
  /* TODO: put back when we have clearer ideas about analytics
  await MatomoTracker().initialize(
    siteId: 2,
    url: 'https://analytics.openfoodfacts.org/',
  );
   */
  try {
    runApp(const SmoothApp());
  } catch (exception, stackTrace) {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
    );
  }
}

class SmoothApp extends StatefulWidget {
  const SmoothApp();

  // This widget is the root of your application.
  @override
  State<SmoothApp> createState() => _SmoothAppState();
}

class _SmoothAppState extends State<SmoothApp> {
  late UserPreferences _userPreferences;
  late ProductPreferences _productPreferences;
  late LocalDatabase _localDatabase;
  late ThemeProvider _themeProvider;
  bool systemDarkmodeOn = false;

  Future<void> _init(BuildContext context) async {
    _userPreferences = await UserPreferences.getUserPreferences();
    _productPreferences = ProductPreferences(
      ProductPreferencesSelection(
        setImportance: (
          String attributeId,
          String importanceId,
        ) async =>
            _userPreferences.setImportance(attributeId, importanceId),
        getImportance: (String attributeId) =>
            _userPreferences.getImportance(attributeId),
        notify: () => _productPreferences.notifyListeners(),
      ),
    );
    try {
      await _productPreferences.loadReferenceFromAssets(
        DefaultAssetBundle.of(context),
      );
    } catch (e) {
      // this is problematic - we should always be able to load the default
      debugPrint('Could not load reference files: $e');
      rethrow;
    }
    await _userPreferences.init(_productPreferences);
    try {
      _localDatabase = await LocalDatabase.getLocalDatabase();
    } catch (e) {
      // this is problematic - we should always be able to init the database
      debugPrint('Cannot init database: $e');
      rethrow;
    }
    _themeProvider = ThemeProvider(_userPreferences);
  }

  @override
  void initState() {
    final Brightness brightness =
        SchedulerBinding.instance?.window.platformBrightness ??
            Brightness.light;
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
                Widget? child,
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
                  home: const SmoothAppGetLanguage(),
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
  const SmoothAppGetLanguage();

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
    return const HomePage();
  }

  Future<void> _refresh(
    final ProductPreferences productPreferences,
    final AssetBundle assetBundle,
    final String languageCode,
  ) async {
    if (productPreferences.languageCode != languageCode) {
      try {
        await productPreferences.loadReferenceFromAssets(
          assetBundle,
          languageCode: languageCode,
        );
      } catch (e) {
        // no problem, we were just trying
      }
    }
    if (!productPreferences.isNetwork) {
      try {
        await productPreferences.loadReferenceFromNetwork(languageCode);
      } catch (e) {
        // no problem, we were just trying
      }
    }
  }
}
