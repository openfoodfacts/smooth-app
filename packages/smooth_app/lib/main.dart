import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sentry/sentry.dart';
import 'package:provider/provider.dart';

import 'package:smooth_app/data_models/user_preferences_model.dart';
import 'package:smooth_app/pages/scan_page.dart';
import 'package:smooth_app/pages/choose_page.dart';
import 'package:smooth_app/pages/contribution_page.dart';
import 'package:smooth_app/pages/profile_page.dart';
import 'package:smooth_app/pages/list_page.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/temp/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_ui_library/navigation/smooth_bottom_app_bar.dart';
import 'package:smooth_ui_library/navigation/models/smooth_bottom_app_bar_item.dart';

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
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UserPreferences _userPreferences;
  UserPreferencesModel _userPreferencesModel;
  LocalDatabase _localDatabase;
  final DarkThemeProvider themeChangeProvider = DarkThemeProvider();
  bool systemDarkmodeOn = false;

  Future<void> _init(BuildContext context) async {
    _userPreferences = await UserPreferences.getUserPreferences();
    _userPreferencesModel = await UserPreferencesModel.getUserPreferencesModel(
        DefaultAssetBundle.of(context));
    await _userPreferences.init(_userPreferencesModel);
    _localDatabase = await LocalDatabase.getLocalDatabase();
    themeChangeProvider.darkTheme =
        await themeChangeProvider.userThemePreference.getTheme();
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
              ChangeNotifierProvider<UserPreferencesModel>.value(
                  value: _userPreferencesModel),
              ChangeNotifierProvider<LocalDatabase>.value(
                  value: _localDatabase),
              ChangeNotifierProvider<DarkThemeProvider>.value(
                  value: themeChangeProvider),
            ],
            child: Consumer<DarkThemeProvider>(
              builder: (
                BuildContext context,
                DarkThemeProvider value,
                Widget child,
              ) {
                return MaterialApp(
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  theme: SmoothTheme.getThemeData(Brightness.light),
                  darkTheme: SmoothTheme.getThemeData(Brightness.dark),
                  themeMode: themeChangeProvider.darkTheme
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
    final UserPreferencesModel userPreferencesModel =
        context.watch<UserPreferencesModel>();
    final Locale myLocale = Localizations.localeOf(context);
    final String languageCode = myLocale.languageCode;
    userPreferencesModel.refresh(DefaultAssetBundle.of(context), languageCode);
    return SmoothApp();
  }
}

class SmoothApp extends StatefulWidget {
  @override
  _SmoothAppState createState() => _SmoothAppState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _SmoothAppState extends State<SmoothApp> {
  @override
  Widget build(BuildContext context) {
    final UserPreferences userPreferences = context.watch<UserPreferences>();
    final bool mlKitState = userPreferences.getMlKitState();
    return Scaffold(
      body: Center(
        child: Container(),
      ),
      bottomNavigationBar: SmoothBottomAppBar(
        <SmoothBottomAppBarItem>[
          SmoothBottomAppBarItem(
            name: 'Choose',
            body: ChoosePage(),
            iconPath: 'assets/ikonate_thin/search.svg',
          ),
          SmoothBottomAppBarItem(
            name: 'Contribute',
            body: CollaborationPage(),
            iconPath: 'assets/ikonate_thin/add.svg',
          ),
          SmoothBottomAppBarItem(
            name: 'Lists',
            body: ListPage(),
            iconPath: 'assets/navigation/organize.svg',
          ),
          SmoothBottomAppBarItem(
            name: 'Profile',
            body: ProfilePage(),
            iconPath: 'assets/ikonate_thin/person.svg',
          ),
        ],
        fabAction: () => Navigator.push<Widget>(
          context,
          MaterialPageRoute<Widget>(
            builder: (BuildContext context) => ScanPage(
              contributionMode: false,
              mlKit: mlKitState,
            ),
          ),
        ),
      ),
    );
  }
}
