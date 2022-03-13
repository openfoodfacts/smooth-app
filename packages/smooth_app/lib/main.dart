import 'dart:async';

import 'package:camera/camera.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:openfoodfacts/personalized_search/product_preferences_selection.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/database/dao_string.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/product_query.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/user_management_helper.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';

List<CameraDescription> cameras = <CameraDescription>[];

Future<void> main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  if (kReleaseMode) {
    await AnalyticsHelper.initSentry(
      appRunner: () => runApp(const SmoothApp()),
    );
  } else {
    runApp(DevicePreview(
      enabled: true,
      builder: (_) => const SmoothApp(),
    ));
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
    _localDatabase = await LocalDatabase.getLocalDatabase();
    _productPreferences = ProductPreferences(
      ProductPreferencesSelection(
        setImportance: _userPreferences.setImportance,
        getImportance: _userPreferences.getImportance,
        notify: () => _productPreferences.notifyListeners(),
      ),
      daoString: DaoString(_localDatabase),
    );
    await _productPreferences.init(DefaultAssetBundle.of(context));
    await _userPreferences.init(_productPreferences);
    ProductQuery.setCountry(_userPreferences.userCountryCode);
    _themeProvider = ThemeProvider(_userPreferences);
    ProductQuery.setQueryType(_userPreferences);

    cameras = await availableCameras();

    UserManagementHelper.mountCredentials();
    await ProductQuery.setUuid(_localDatabase);
    AnalyticsHelper.initMatomo(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.hasError) {
          FlutterNativeSplash.remove();
          return _buildError(snapshot);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildLoader();
        }

        // The `create` constructor of [ChangeNotifierProvider] takes care of
        // disposing the value.
        ChangeNotifierProvider<T> provide<T extends ChangeNotifier>(T value) =>
            ChangeNotifierProvider<T>(create: (BuildContext context) => value);

        FlutterNativeSplash.remove();
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
class SmoothAppGetLanguage extends StatefulWidget {
  const SmoothAppGetLanguage(this.appWidget);

  final Widget appWidget;

  @override
  State<SmoothAppGetLanguage> createState() => _SmoothAppGetLanguageState();
}

class _SmoothAppGetLanguageState extends State<SmoothAppGetLanguage> {
  @override
  void initState() {
    super.initState();

    // Currently converted into a StatefulWidget to call trackStart in initState
    // since this widget got rebuild multiple time which it shouldn't
    // TODO(open): Fix unnecessary rebuilds
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final LocalDatabase _localDatabase = Provider.of<LocalDatabase>(
        context,
        listen: false,
      );
      AnalyticsHelper.trackStart(_localDatabase, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final Locale myLocale = Localizations.localeOf(context);
    final String languageCode = myLocale.languageCode;
    ProductQuery.setLanguage(languageCode);
    productPreferences.refresh(languageCode);

    return widget.appWidget;
  }
}
