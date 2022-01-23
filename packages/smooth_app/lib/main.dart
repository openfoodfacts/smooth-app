import 'dart:async';

import 'package:camera/camera.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:openfoodfacts/personalized_search/product_preferences_selection.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

List<CameraDescription> cameras = <CameraDescription>[];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();

  if (kReleaseMode) {
    await SentryFlutter.init(
      (SentryOptions options) {
        options.dsn =
            'https://22ec5d0489534b91ba455462d3736680@o241488.ingest.sentry.io/5376745';
        options.sentryClientName =
            'sentry.dart.smoothie/${packageInfo.version}';
      },
      appRunner: () => runApp(const SmoothApp()),
    );

    /* TODO: put back when we have clearer ideas about analytics
    await MatomoTracker().initialize(
      siteId: 2,
      url: 'https://analytics.openfoodfacts.org/',
    );
    */
  } else {
    runApp(DevicePreview(enabled: true, builder: (_) => const SmoothApp()));
  }
}

class SmoothApp extends StatefulWidget {
  const SmoothApp();

  // This widget is the root of your application
  @override
  State<SmoothApp> createState() => _SmoothAppState();
}

class _SmoothAppState extends State<SmoothApp> {
  late UserPreferences _userPreferences;
  late ProductPreferences _productPreferences;
  late LocalDatabase _localDatabase;
  late ThemeProvider _themeProvider;
  bool systemDarkmodeOn = false;

  // We store the argument of FutureBuilder to avoid re-initialization on
  // subsequent builds. This enables hot reloading. See
  // https://github.com/openfoodfacts/smooth-app/issues/473
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  Future<void> _init() async {
    final Brightness brightness =
        SchedulerBinding.instance?.window.platformBrightness ??
            Brightness.light;
    systemDarkmodeOn = brightness == Brightness.dark;
    _userPreferences = await UserPreferences.getUserPreferences();
    _productPreferences = ProductPreferences(ProductPreferencesSelection(
      setImportance: _userPreferences.setImportance,
      getImportance: _userPreferences.getImportance,
      notify: () => _productPreferences.notifyListeners(),
    ));
    await _productPreferences
        .loadReferenceFromAssets(DefaultAssetBundle.of(context));
    await _userPreferences.init(_productPreferences);
    ProductQuery.setCountry(_userPreferences.userCountryCode);
    _localDatabase = await LocalDatabase.getLocalDatabase();
    _themeProvider = ThemeProvider(_userPreferences);
    ProductQuery.setQueryType(_userPreferences);

    UserManagementHelper.mountCredentials();
    cameras = await availableCameras();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.hasError) {
          return _buildError(snapshot);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildLoader();
        }

        // The `create` constructor of [ChangeNotifierProvider] takes care of
        // disposing the value.
        ChangeNotifierProvider<T> provide<T extends ChangeNotifier>(T value) =>
            ChangeNotifierProvider<T>(create: (BuildContext context) => value);

        return MultiProvider(
          providers: <ChangeNotifierProvider<ChangeNotifier>>[
            provide<UserPreferences>(_userPreferences),
            provide<ProductPreferences>(_productPreferences),
            provide<LocalDatabase>(_localDatabase),
            provide<ThemeProvider>(_themeProvider),
          ],
          builder: _buildApp,
        );
      },
    );
  }

  Widget _buildApp(BuildContext context, Widget? child) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final Widget appWidget = OnboardingFlowNavigator(_userPreferences)
        .getPageWidget(context, _userPreferences.lastVisitedOnboardingPage);
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      navigatorObservers: <NavigatorObserver>[
        SentryNavigatorObserver(),
      ],
      theme: SmoothTheme.getThemeData(
        Brightness.light,
        themeProvider.colorTag,
      ),
      darkTheme: SmoothTheme.getThemeData(
        Brightness.dark,
        themeProvider.colorTag,
      ),
      themeMode: themeProvider.darkTheme ? ThemeMode.dark : ThemeMode.light,
      home: SmoothAppGetLanguage(appWidget),
    );
  }

  Widget _buildLoader() {
    return Container(
      color: systemDarkmodeOn ? const Color(0xFF181818) : Colors.white,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildError(AsyncSnapshot<void> snapshot) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Fatal Error: ${snapshot.error}',
          ),
        ),
      ),
    );
  }
}

/// Layer needed because we need to know the language. Language isn't available
/// in the [context] in top level widget ([SmoothApp])
class SmoothAppGetLanguage extends StatelessWidget {
  const SmoothAppGetLanguage(this.appWidget);

  final Widget appWidget;

  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final Locale myLocale = Localizations.localeOf(context);
    final String languageCode = myLocale.languageCode;
    ProductQuery.setLanguage(languageCode);
    _refresh(
      productPreferences,
      DefaultAssetBundle.of(context),
      languageCode,
    );
    return appWidget;
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
