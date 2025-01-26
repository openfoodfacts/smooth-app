import 'dart:async';
import 'dart:io';

import 'package:app_store_shared/app_store_shared.dart';
import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:rive/rive.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:smooth_app/data_models/continuous_scan_model.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/data_models/product_preferences.dart';
import 'package:smooth_app/data_models/user_management_provider.dart';
import 'package:smooth_app/database/dao_string.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/helpers/analytics_helper.dart';
import 'package:smooth_app/helpers/camera_helper.dart';
import 'package:smooth_app/helpers/entry_points_helper.dart';
import 'package:smooth_app/helpers/global_vars.dart';
import 'package:smooth_app/helpers/network_config.dart';
import 'package:smooth_app/helpers/permission_helper.dart';
import 'package:smooth_app/pages/navigator/app_navigator.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_animations.dart';
import 'package:smooth_app/services/smooth_services.dart';
import 'package:smooth_app/themes/color_provider.dart';
import 'package:smooth_app/themes/contrast_provider.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

void main() {
  debugPrint('--------');
  debugPrint('The app must not be started using the main.dart file');
  debugPrint('Please start the app using:');
  debugPrint(' - flutter run -t lib/entrypoints/android/main_google_play.dart');
  debugPrint(' - flutter run -t lib/entrypoints/ios/main_ios.dart');
  debugPrint(
      'More information here: https://github.com/openfoodfacts/smooth-app#how-to-run-the-project');
  debugPrint('--------');

  if (Platform.isAndroid) {
    SystemNavigator.pop();
  } else {
    exit(2);
  }
}

late final bool _screenshots;

Future<void> launchSmoothApp({
  required Scanner barcodeScanner,
  required AppStore appStore,
  required StoreLabel storeLabel,
  required ScannerLabel scannerLabel,
  final bool screenshots = false,
}) async {
  unawaited(RiveFile.initialize());

  _screenshots = screenshots;

  GlobalVars.barcodeScanner = barcodeScanner;
  GlobalVars.appStore = appStore;
  GlobalVars.storeLabel = storeLabel;
  GlobalVars.scannerLabel = scannerLabel;

  if (_screenshots) {
    await _init1();
    runApp(const SmoothApp());
    return;
  }
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  _enableEdgeToEdgeMode();

  if (kReleaseMode) {
    await AnalyticsHelper.initSentry(
        appRunner: () => runApp(const SmoothApp()));
  } else {
    runApp(const SmoothApp());
  }
}

void _enableEdgeToEdgeMode() {
  if (Platform.isAndroid) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }
}

class SmoothApp extends StatefulWidget {
  const SmoothApp();

  // This widget is the root of your application
  @override
  State<SmoothApp> createState() => _SmoothAppState();
}

late UserPreferences _userPreferences;
late ProductPreferences _productPreferences;
late LocalDatabase _localDatabase;
late ThemeProvider _themeProvider;
final ContinuousScanModel _continuousScanModel = ContinuousScanModel();
bool _init1done = false;

// Had to split init in 2 methods, for test/screenshots reasons.
// Don't know why, but some init codes seem to freeze the test.
// Now we run them before running the app, during the tests.
Future<bool> _init1() async {
  if (_init1done) {
    return false;
  }

  DartPingIOS.register();
  await SmoothServices().init(GlobalVars.appStore);
  await setupAppNetworkConfig();
  await UserManagementProvider.mountCredentials();
  _userPreferences = await UserPreferences.getUserPreferences();
  _localDatabase = await LocalDatabase.getLocalDatabase();
  await _continuousScanModel.load(_localDatabase);
  _productPreferences = ProductPreferences(
    ProductPreferencesSelection(
      setImportance: _userPreferences.setImportance,
      getImportance: _userPreferences.getImportance,
      notify: () => _productPreferences.notifyListeners(),
    ),
    daoString: DaoString(_localDatabase),
  );
  ProductQuery.setQueryType(_userPreferences);
  UserManagementProvider().checkUserLoginValidity();

  await AnalyticsHelper.linkPreferences(_userPreferences);

  await ProductQuery.initCountry(_userPreferences);
  _themeProvider = ThemeProvider(_userPreferences);

  await CameraHelper.init();
  await ProductQuery.setUuid(_localDatabase);
  _init1done = true;
  return true;
}

class _SmoothAppState extends State<SmoothApp> {
  final UserManagementProvider _userManagementProvider =
      UserManagementProvider();

  bool systemDarkmodeOn = false;
  final Brightness brightness = PlatformDispatcher.instance.platformBrightness;

  // We store the argument of FutureBuilder to avoid re-initialization on
  // subsequent builds. This enables hot reloading. See
  // https://github.com/openfoodfacts/smooth-app/issues/473
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _init2();
  }

  Future<bool> _init2() async {
    await _init1();
    systemDarkmodeOn = brightness == Brightness.dark;
    if (!mounted) {
      return false;
    }
    await _productPreferences.init(DefaultAssetBundle.of(context));
    await AnalyticsHelper.initMatomo(_screenshots);
    if (!_screenshots) {
      await _userPreferences.init(_productPreferences);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.hasError) {
          Logs.e(
            'The app initialisation failed',
            ex: snapshot.error,
            stacktrace: snapshot.stackTrace,
          );
          FlutterNativeSplash.remove();
          return _buildError(snapshot);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          //We don't need a loading indicator since the splash screen is still visible
          return EMPTY_WIDGET;
        }

        if (!_screenshots) {
          // ending FlutterNativeSplash.preserve()
          FlutterNativeSplash.remove();
        }

        return MultiProvider(
          providers: <SingleChildWidget>[
            _provide<UserPreferences>(_userPreferences),
            _provide<ProductPreferences>(_productPreferences),
            _provide<UserManagementProvider>(_userManagementProvider),
            _provide<LocalDatabase>(_localDatabase),
            _lazyProvide<PermissionListener>(
              (_) => PermissionListener(permission: Permission.camera),
            ),
            _provide<ThemeProvider>(_themeProvider),

            /// The next two providers are only used with the AMOLED theme
            _lazyProvide<ColorProvider>(
              (_) => ColorProvider(_userPreferences),
            ),
            _lazyProvide<TextContrastProvider>(
              (_) => TextContrastProvider(_userPreferences),
            ),
            _provide<ContinuousScanModel>(_continuousScanModel),

            /// Only used after the onboarding
            _lazyProvide<AppNewsProvider>(
              (_) => AppNewsProvider(_userPreferences),
            ),
          ],
          child: AnimationsLoader(
            child: AppNavigator(
              observers: <NavigatorObserver>[
                SentryNavigatorObserver(),
                matomoObserver,
              ],
              child: Builder(builder: _buildApp),
            ),
          ),
        );
      },
    );
  }

  ChangeNotifierProvider<T> _provide<T extends ChangeNotifier>(T value) =>
      ChangeNotifierProvider<T>(
        create: (BuildContext context) => value,
      );

  ChangeNotifierProvider<T> _lazyProvide<T extends ChangeNotifier>(
    T Function(BuildContext) valueBuilder,
  ) =>
      ChangeNotifierProvider<T>(
        create: valueBuilder,
        lazy: true,
      );

  Widget _buildApp(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final OnboardingPage lastVisitedOnboardingPage =
        _userPreferences.lastVisitedOnboardingPage;
    OnboardingFlowNavigator(_userPreferences);
    final bool isOnboardingComplete =
        lastVisitedOnboardingPage.isOnboardingComplete();
    themeProvider.setOnboardingComplete(isOnboardingComplete);

    // Still need the value from the UserPreferences here, not the ProductQuery
    // as the value is not available at this time
    // will refresh each time the language changes
    final String? languageCode =
        context.select((UserPreferences up) => up.appLanguageCode);

    return SentryScreenshotWidget(
      child: MaterialApp.router(
        locale: languageCode != null ? Locale(languageCode) : null,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: !(kReleaseMode || _screenshots),
        theme: SmoothTheme.getThemeData(
          Brightness.light,
          themeProvider,
          () => context.watch<ColorProvider>(),
          () => context.watch<TextContrastProvider>(),
        ),
        darkTheme: SmoothTheme.getThemeData(
          Brightness.dark,
          themeProvider,
          () => context.watch<ColorProvider>(),
          () => context.watch<TextContrastProvider>(),
        ),
        themeMode: themeProvider.currentThemeMode,
        routerConfig: AppNavigator.of(context).router,
      ),
    );
  }

  Widget _buildError(AsyncSnapshot<void> snapshot) {
    return MaterialApp(
      theme: ThemeData(),
      home: SmoothScaffold(
        body: Center(
          child: Text(
            'Fatal Error: ${snapshot.error}',
          ),
        ),
      ),
    );
  }
}
